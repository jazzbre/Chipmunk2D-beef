using System;
using System.Collections;

namespace Chipmunk2D
{
	enum BodyType
	{
		/// A dynamic body is one that is affected by gravity, forces, and collisions.
		/// This is the default body type.
		Dynamic,
		/// A kinematic body is an infinite mass, user controlled body that is not affected by gravity, forces or
		// collisions. Instead the body only moves based on it's velocity. Dynamic bodies collide normally with
		// kinematic bodies, though the kinematic body will be unaffected. Collisions between two kinematic bodies, or a
		// kinematic body and a static body produce collision callbacks, but no collision response.
		Kinematic,
		/// A static body is a body that never (or rarely) moves. If you move a static body, you must call one of the
		// cpSpaceReindex*() functions. Chipmunk uses this information to optimize the collision detection. Static
		// bodies do not produce collision callbacks when colliding with other static bodies.
		Static,
	}

	class Body : ObjectBase
	{
		private List<Shape> shapes = new List<Shape>() ~ delete _;
		private bool canFree;

		public BodyType BodyType
		{
			get
			{
				return cpBodyGetType(handle);
			}
			set
			{
				cpBodySetType(handle, value);
			}
		}

		public bool IsSleeping => cpBodyIsSleeping(handle);

		public float Mass
		{
			get
			{
				return cpBodyGetMass(handle);
			}
			set
			{
				cpBodySetMass(handle, value);
			}
		}

		public float Moment
		{
			get
			{
				return cpBodyGetMoment(handle);
			}
			set
			{
				cpBodySetMoment(handle, value);
			}
		}

		public Vector2 Position
		{
			get
			{
				return cpBodyGetPosition(handle);
			}
			set
			{
				cpBodySetPosition(handle, value);
			}
		}

		public Vector2 CenterOfGravity
		{
			get
			{
				return cpBodyGetCenterOfGravity(handle);
			}
			set
			{
				cpBodySetCenterOfGravity(handle, value);
			}
		}

		public Vector2 Velocity
		{
			get
			{
				return cpBodyGetVelocity(handle);
			}
			set
			{
				cpBodySetVelocity(handle, value);
			}
		}

		public Vector2 Force
		{
			get
			{
				return cpBodyGetForce(handle);
			}
			set
			{
				cpBodySetForce(handle, value);
			}
		}

		public float Angle
		{
			get
			{
				return cpBodyGetAngle(handle);
			}
			set
			{
				cpBodySetAngle(handle, value);
			}
		}

		public float AngularVelocity
		{
			get
			{
				return cpBodyGetAngularVelocity(handle);
			}
			set
			{
				cpBodySetAngularVelocity(handle, value);
			}
		}

		public float Torque
		{
			get
			{
				return cpBodyGetTorque(handle);
			}
			set
			{
				cpBodySetTorque(handle, value);
			}
		}

		public Vector2 Rotation => cpBodyGetRotation(handle);

		public float KineticEnergy => cpBodyKineticEnergy(handle);

		public this(BodyType type, float mass = 0.0f, float moment = 0.0f)
		{
			switch (type) {
			case .Static:
				handle = cpBodyNewStatic();
				break;
			case .Kinematic:
				handle = cpBodyNewKinematic();
				break;
			case .Dynamic:
				handle = cpBodyNew(mass, moment);
				break;
			}
			cpBodySetUserData(handle, Internal.UnsafeCastToPtr(this));
		}

		public this(void* _handle, bool _canFree = true)
		{
			handle = _handle;
			canFree = _canFree;
		}

		public ~this()
		{
			if (canFree)
			{
				cpBodyFree(handle);
			}
			for (var shape in shapes)
			{
				delete shape;
			}
			shapes.Clear();
			handle = null;
		}

		public void Activate()
		{
			cpBodyActivate(handle);
		}

		public void Sleep()
		{
			cpBodySleep(handle);
		}

		public Shape AddBoxShape(float width, float height, float radius)
		{
			var shape = new BoxShape(cpBoxShapeNew(handle, width, height, radius));
			cpSpaceAddShape(cpBodyGetSpace(handle), shape.Handle);
			shapes.Add(shape);
			return shape;
		}

		public Shape AddPolyShape(Vector2[] verts, float radius)
		{
			var shape = new PolyShape(cpPolyShapeNewRaw(handle, (int32)verts.Count, &verts[0], radius));
			cpSpaceAddShape(cpBodyGetSpace(handle), shape.Handle);
			shapes.Add(shape);
			return shape;
		}

		public Shape AddCircleShape(float radius, Vector2 offset = Vector2.Zero)
		{
			var shape = new CircleShape(cpCircleShapeNew(handle, radius, offset));
			cpSpaceAddShape(cpBodyGetSpace(handle), shape.Handle);
			shapes.Add(shape);
			return shape;
		}

		public Shape AddSegmentShape(Vector2 a, Vector2 b, float radius)
		{
			var shape = new SegmentShape(cpSegmentShapeNew(handle, a, b, radius));
			cpSpaceAddShape(cpBodyGetSpace(handle), shape.Handle);
			shapes.Add(shape);
			return shape;
		}

		public void RemoveShape(Shape shape)
		{
			shapes.Remove(shape);
			cpSpaceRemoveShape(cpBodyGetSpace(handle), shape.Handle);
		}

		public Vector2 TransformLocalToWorld(Vector2 point)
		{
			return cpBodyLocalToWorld(handle, point);
		}

		public Vector2 TransformWorldToLocal(Vector2 point)
		{
			return cpBodyWorldToLocal(handle, point);
		}

		public void ApplyForceAtWorldPoint(Vector2 force, Vector2 point)
		{
			cpBodyApplyForceAtWorldPoint(handle, force, point);
		}

		public void ApplyForceAtLocalPoint(Vector2 force, Vector2 point)
		{
			cpBodyApplyForceAtLocalPoint(handle, force, point);
		}

		public void ApplyImpulseAtWorldPoint(Vector2 impulse, Vector2 point)
		{
			cpBodyApplyImpulseAtWorldPoint(handle, impulse, point);
		}

		public void ApplyImpulseAtLocalPoint(Vector2 impulse, Vector2 point)
		{
			cpBodyApplyImpulseAtLocalPoint(handle, impulse, point);
		}

		public Vector2 GetVelocityAtWorldPoint(Vector2 point)
		{
			return cpBodyGetVelocityAtWorldPoint(handle, point);
		}

		public Vector2 GetVelocityAtLocalPoint(Vector2 point)
		{
			return cpBodyGetVelocityAtLocalPoint(handle, point);
		}

		private static void OnEachShape(void* body, void* shape, void* data)
		{
			var list = Internal.UnsafeCastToObject(data) as List<void*>;
			list.Add(shape);
		}

		public void EachShape(delegate void(Shape shape) func)
		{
			var shapes = scope List<void*>();
			cpBodyEachShape(handle, => OnEachShape, Internal.UnsafeCastToPtr(shapes));
			for (var shape in shapes)
			{
				func(Internal.UnsafeCastToObject(shape) as Shape);
			}
		}

		private static void OnEachConstraint(void* body, void* constraint, void* data)
		{
			var list = Internal.UnsafeCastToObject(data) as List<void*>;
			list.Add(constraint);
		}

		public void EachConstraint(delegate void(Constraint shape) func)
		{
			var constraints = scope List<void*>();
			cpBodyEachShape(handle, => OnEachConstraint, Internal.UnsafeCastToPtr(shapes));
			for (var constraint in constraints)
			{
				func(Internal.UnsafeCastToObject(constraint) as Constraint);
			}
		}

		private static void OnEachArbiter(void* body, void* arbiter, void* data)
		{
			var list = Internal.UnsafeCastToObject(data) as List<void*>;
			list.Add(arbiter);
		}

		public void EachArbiter(delegate void(Arbiter shape) func)
		{
			var arbiters = scope List<void*>();
			cpBodyEachShape(handle, => OnEachArbiter, Internal.UnsafeCastToPtr(shapes));
			for (var arbiter in arbiters)
			{
				func(Arbiter(arbiter));
			}
		}

		[CLink]
		private static extern void* cpBodyNew(float mass, float moment);

		/// Allocate and initialize a Body, and set it as a kinematic body.
		[CLink]
		private static extern void* cpBodyNewKinematic();
		/// Allocate and initialize a Body, and set it as a static body.
		[CLink]
		private static extern void* cpBodyNewStatic();

		/// Destroy and free a Body.
		[CLink]
		private static extern void cpBodyFree(void* body);

		/// Wake up a sleeping or idle body.
		[CLink]
		private static extern void cpBodyActivate(void* body);
		/// Force a body to fall asleep immediately.
		[CLink]
		private static extern void cpBodySleep(void* body);

		/// Returns true if the body is sleeping.
		[CLink]
		private static extern bool cpBodyIsSleeping(void* body);

		/// Get the type of the body.
		[CLink]
		private static extern BodyType cpBodyGetType(void* body);
		/// Set the type of the body.
		[CLink]
		private static extern void cpBodySetType(void* body, BodyType type);

		/// Get the space this body is added to.
		[CLink]
		private static extern Space* cpBodyGetSpace(void* body);

		/// Get the mass of the body.
		[CLink]
		private static extern float cpBodyGetMass(void* body);
		/// Set the mass of the body.
		[CLink]
		private static extern void cpBodySetMass(void* body, float m);

		/// Get the moment of inertia of the body.
		[CLink]
		private static extern float cpBodyGetMoment(void* body);
		/// Set the moment of inertia of the body.
		[CLink]
		private static extern void cpBodySetMoment(void* body, float i);

		/// Set the position of a body.
		[CLink]
		private static extern Vector2 cpBodyGetPosition(void* body);
		/// Set the position of the body.
		[CLink]
		private static extern void cpBodySetPosition(void* body, Vector2 pos);

		/// Get the offset of the center of gravity in body local coordinates.
		[CLink]
		private static extern Vector2 cpBodyGetCenterOfGravity(void* body);
		/// Set the offset of the center of gravity in body local coordinates.
		[CLink]
		private static extern void cpBodySetCenterOfGravity(void* body, Vector2 cog);

		/// Get the velocity of the body.
		[CLink]
		private static extern Vector2 cpBodyGetVelocity(void* body);
		/// Set the velocity of the body.
		[CLink]
		private static extern void cpBodySetVelocity(void* body, Vector2 velocity);

		/// Get the force applied to the body for the next time step.
		[CLink]
		private static extern Vector2 cpBodyGetForce(void* body);
		/// Set the force applied to the body for the next time step.
		[CLink]
		private static extern void cpBodySetForce(void* body, Vector2 force);

		/// Get the angle of the body.
		[CLink]
		private static extern float cpBodyGetAngle(void* body);
		/// Set the angle of a body.
		[CLink]
		private static extern void cpBodySetAngle(void* body, float a);

		/// Get the angular velocity of the body.
		[CLink]
		private static extern float cpBodyGetAngularVelocity(void* body);
		/// Set the angular velocity of the body.
		[CLink]
		private static extern void cpBodySetAngularVelocity(void* body, float angularVelocity);

		/// Get the torque applied to the body for the next time step.
		[CLink]
		private static extern float cpBodyGetTorque(void* body);
		/// Set the torque applied to the body for the next time step.
		[CLink]
		private static extern void cpBodySetTorque(void* body, float torque);

		/// Get the rotation vector of the body. (The x basis vector of it's transform.)
		[CLink]
		private static extern Vector2 cpBodyGetRotation(void* body);

		/// Get the user data pointer assigned to the body.
		[CLink]
		private static extern void* cpBodyGetUserData(void* body);
		/// Set the user data pointer assigned to the body.
		[CLink]
		private static extern void cpBodySetUserData(void* body, void* userData);

		/// Default velocity integration function..
		[CLink]
		private static extern void cpBodyUpdateVelocity(void* body, Vector2 gravity, float damping, float dt);
		/// Default position integration function.
		[CLink]
		private static extern void cpBodyUpdatePosition(void* body, float dt);

		/// Convert body relative/local coordinates to absolute/world coordinates.
		[CLink]
		private static extern Vector2 cpBodyLocalToWorld(void* body, Vector2 point);
		/// Convert body absolute/world coordinates to  relative/local coordinates.
		[CLink]
		private static extern Vector2 cpBodyWorldToLocal(void* body, Vector2 point);

		/// Apply a force to a body. Both the force and point are expressed in world coordinates.
		[CLink]
		private static extern void cpBodyApplyForceAtWorldPoint(void* body, Vector2 force, Vector2 point);
		/// Apply a force to a body. Both the force and point are expressed in body local coordinates.
		[CLink]
		private static extern void cpBodyApplyForceAtLocalPoint(void* body, Vector2 force, Vector2 point);

		/// Apply an impulse to a body. Both the impulse and point are expressed in world coordinates.
		[CLink]
		private static extern void cpBodyApplyImpulseAtWorldPoint(void* body, Vector2 impulse, Vector2 point);
		/// Apply an impulse to a body. Both the impulse and point are expressed in body local coordinates.
		[CLink]
		private static extern void cpBodyApplyImpulseAtLocalPoint(void* body, Vector2 impulse, Vector2 point);

		/// Get the velocity on a body (in world units) at a point on the body in world coordinates.
		[CLink]
		private static extern Vector2 cpBodyGetVelocityAtWorldPoint(void* body, Vector2 point);
		/// Get the velocity on a body (in world units) at a point on the body in local coordinates.
		[CLink]
		private static extern Vector2 cpBodyGetVelocityAtLocalPoint(void* body, Vector2 point);

		/// Get the amount of kinetic energy contained by the body.
		[CLink]
		private static extern float cpBodyKineticEnergy(void* body);


		/// Call @c func once for each shape attached to @c body and added to the space.
		[CLink]
		private static extern void cpBodyEachShape(void* body, function void(void* body, void* shape, void* data) func, void* data);

		/// Call @c func once for each constraint attached to @c body and added to the space.
		[CLink]
		private static extern void cpBodyEachConstraint(void* body, function void(void* body, void* constraint, void* data) func, void* data);

		/// Call @c func once for each arbiter that is currently active on the body.
		[CLink]
		private static extern void cpBodyEachArbiter(void* body, function void(void* body, void* arbiter, void* data) func, void* data);

		// Shape

		/// Add a collision shape to the simulation.
		/// If the shape is attached to a static body, it will be added as a static shape.
		[CLink] private static extern void* cpSpaceAddShape(void* space, void* shape);

		/// Remove a collision shape from the simulation.
		[CLink] private static extern void cpSpaceRemoveShape(void* space, void* shape);

		/// Allocate and initialize a polygon shape with rounded corners.
		/// The vertexes must be convex with a counter-clockwise winding.
		[CLink]
		private static extern void* cpPolyShapeNewRaw(void* body, int32 count, Vector2* verts, float radius);

		/// Allocate and initialize a box shaped polygon shape.
		[CLink]
		private static extern void* cpBoxShapeNew(void* body, float width, float height, float radius);


		/// Allocate and initialize a circle shape.
		[CLink]
		private static extern void* cpCircleShapeNew(void* body, float radius, Vector2 offset);

		/// Allocate and initialize a segment shape.
		[CLink]
		private static extern void* cpSegmentShapeNew(void* body, Vector2 a, Vector2 b, float radius);

	}
}