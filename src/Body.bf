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
		/// Rigid body velocity update function type.
		typealias VelocityDelegate = delegate void(Vector2 gravity, Real damping, Real dt);
		/// Rigid body position update function type.
		typealias PositionDelegate = delegate void(Real dt);

		private List<Shape> shapes = new List<Shape>() ~ delete _;
		private bool canFree;

		private VelocityDelegate velocityDelegate;
		private PositionDelegate positionDelegate;

		public List<Shape> Shapes => shapes;

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

		public Real Mass
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

		public Real Moment
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

		public Real Angle
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

		public Real AngularVelocity
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

		public Real Torque
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

		public Real KineticEnergy => cpBodyKineticEnergy(handle);

		public VelocityDelegate VelocityCallback
		{
			get
			{
				return velocityDelegate;
			}
			set
			{
				if (value != null)
				{
					cpBodySetVelocityFunc(handle, => BodyVelocityFunc);
				} else
				{
					cpBodySetVelocityFunc(handle, null);
				}
				velocityDelegate = value;
			}
		}

		public PositionDelegate PositionCallback
		{
			get
			{
				return positionDelegate;
			}
			set
			{
				if (value != null)
				{
					cpBodySetPositionFunc(handle, => BodyPositionFunc);
				} else
				{
					cpBodySetPositionFunc(handle, null);
				}
				positionDelegate = value;
			}
		}

		public this(BodyType type, Real mass = 0.0f, Real moment = 0.0f)
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
			for (var shape in shapes)
			{
				delete shape;
			}
			if (canFree)
			{
				cpBodyFree(handle);
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

		public Shape AddBoxShape(Real width, Real height, Real radius)
		{
			var shape = new BoxShape(cpBoxShapeNew(handle, width, height, radius), this);
			cpSpaceAddShape(cpBodyGetSpace(handle), shape.Handle);
			shapes.Add(shape);
			return shape;
		}

		public Shape AddBoxShape(Bounds bounds, Real radius)
		{
			var shape = new BoxShape(cpBoxShapeNew2(handle, bounds, radius), this);
			cpSpaceAddShape(cpBodyGetSpace(handle), shape.Handle);
			shapes.Add(shape);
			return shape;
		}

		public Shape AddPolyShape(Vector2[] verts, Real radius)
		{
			var shape = new PolyShape(cpPolyShapeNewRaw(handle, (int32)verts.Count, &verts[0], radius), this);
			cpSpaceAddShape(cpBodyGetSpace(handle), shape.Handle);
			shapes.Add(shape);
			return shape;
		}

		public Shape AddCircleShape(Real radius, Vector2 offset = Vector2.Zero)
		{
			var shape = new CircleShape(cpCircleShapeNew(handle, radius, offset), this);
			cpSpaceAddShape(cpBodyGetSpace(handle), shape.Handle);
			shapes.Add(shape);
			return shape;
		}

		public Shape AddSegmentShape(Vector2 a, Vector2 b, Real radius)
		{
			var shape = new SegmentShape(cpSegmentShapeNew(handle, a, b, radius), this);
			cpSpaceAddShape(cpBodyGetSpace(handle), shape.Handle);
			shapes.Add(shape);
			return shape;
		}

		public void RemoveShape(Shape shape)
		{
			cpSpaceRemoveShape(cpBodyGetSpace(handle), shape.Handle);
			shapes.Remove(shape);
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

		public void EachConstraint(delegate void(Constraint constraint) func)
		{
			var constraints = scope List<void*>();
			cpBodyEachConstraint(handle, => OnEachConstraint, Internal.UnsafeCastToPtr(constraints));
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

		public void EachArbiter(delegate void(Arbiter arbiter) func)
		{
			var arbiters = scope List<void*>();
			cpBodyEachArbiter(handle, => OnEachArbiter, Internal.UnsafeCastToPtr(arbiters));
			for (var arbiter in arbiters)
			{
				func(Arbiter(arbiter));
			}
		}


		private static void BodyVelocityFunc(void* _body, Vector2 gravity, Real damping, Real dt)
		{
			var body = (Body)Internal.UnsafeCastToObject(cpBodyGetUserData(_body));
			body.velocityDelegate(gravity, damping, dt);
		}

		private static void BodyPositionFunc(void* _body, Real dt)
		{
			var body = (Body)Internal.UnsafeCastToObject(cpBodyGetUserData(_body));
			body.positionDelegate(dt);
		}

		public void UpdateVelocity(Vector2 gravity, Real damping, Real dt)
		{
			cpBodyUpdateVelocity(handle, gravity, damping, dt);
		}

		public void UpdatePosition(Real dt)
		{
			cpBodyUpdatePosition(handle, dt);
		}

		/// Rigid body velocity update function type.
		typealias cpBodyVelocityFuncInternal = function void(void* body, Vector2 gravity, Real damping, Real dt);
		/// Rigid body position update function type.
		typealias cpBodyPositionFuncInternal = function void(void* body, Real dt);

		[CLink]
		private static extern void* cpBodyNew(Real mass, Real moment);

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
		private static extern Real cpBodyGetMass(void* body);
		/// Set the mass of the body.
		[CLink]
		private static extern void cpBodySetMass(void* body, Real m);

		/// Get the moment of inertia of the body.
		[CLink]
		private static extern Real cpBodyGetMoment(void* body);
		/// Set the moment of inertia of the body.
		[CLink]
		private static extern void cpBodySetMoment(void* body, Real i);

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
		private static extern Real cpBodyGetAngle(void* body);
		/// Set the angle of a body.
		[CLink]
		private static extern void cpBodySetAngle(void* body, Real a);

		/// Get the angular velocity of the body.
		[CLink]
		private static extern Real cpBodyGetAngularVelocity(void* body);
		/// Set the angular velocity of the body.
		[CLink]
		private static extern void cpBodySetAngularVelocity(void* body, Real angularVelocity);

		/// Get the torque applied to the body for the next time step.
		[CLink]
		private static extern Real cpBodyGetTorque(void* body);
		/// Set the torque applied to the body for the next time step.
		[CLink]
		private static extern void cpBodySetTorque(void* body, Real torque);

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
		private static extern void cpBodyUpdateVelocity(void* body, Vector2 gravity, Real damping, Real dt);
		/// Default position integration function.
		[CLink]
		private static extern void cpBodyUpdatePosition(void* body, Real dt);

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
		private static extern Real cpBodyKineticEnergy(void* body);


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
		private static extern void* cpPolyShapeNewRaw(void* body, int32 count, Vector2* verts, Real radius);

		/// Allocate and initialize a box shaped polygon shape.
		[CLink]
		private static extern void* cpBoxShapeNew(void* body, Real width, Real height, Real radius);

		/// Allocate and initialize an offset box shaped polygon shape.
		[CLink]
		private static extern void* cpBoxShapeNew2(void* body, Bounds bounds, Real radius);


		/// Allocate and initialize a circle shape.
		[CLink]
		private static extern void* cpCircleShapeNew(void* body, Real radius, Vector2 offset);

		/// Allocate and initialize a segment shape.
		[CLink]
		private static extern void* cpSegmentShapeNew(void* body, Vector2 a, Vector2 b, Real radius);

		[CLink]
		private static extern void cpBodySetVelocityFunc(void* body, cpBodyVelocityFuncInternal func);

		[CLink]
		private static extern void cpBodySetPositionFunc(void* body, cpBodyPositionFuncInternal func);


	}
}
