using System;
using System.Collections;

namespace Chipmunk2D
{
	class CollisionHandler
	{
		public uint typeA;
		public uint typeB;
		public delegate void(Arbiter arb) beginFunc;
		public delegate void(Arbiter arb) preSolveFunc;
		public delegate void(Arbiter arb) postSolveFunc;
		public delegate void(Arbiter arb) separateFunc;
	}

	/// Point query info struct.
	struct PointQueryInfo
	{
		/// The nearest shape, NULL if no shape was within range.
		public Shape shape;
		/// The closest point on the shape's surface. (in world space coordinates)
		public Vector2 point;
		/// The distance to the point. The distance is negative if the point is inside the shape.
		public Real distance;
		/// The gradient of the signed distance function.
		/// The value should be similar to info.p/info.d, but accurate even for very small values of info.d.
		public Vector2 gradient;
	}

	/// Segment query info struct.
	struct SegmentQueryInfo
	{
		/// The shape that was hit, or NULL if no collision occured.
		public Shape shape;
		/// The point of impact.
		public Vector2 point;
		/// The normal of the surface hit.
		public Vector2 normal;
		/// The normalized distance along the query segment in the range [0, 1].
		public Real alpha;
	}

	struct ShapeQueryInfo
	{
		public Shape shape;
		public ContactPointSet contactPointSet;
	}

	class Space : ObjectBase
	{
		public Body StaticBody { get; private set; };
		private List<delegate void()> postStepCallbacks = new List<delegate void()>() ~ delete _;

		public int32 Iterations
		{
			get
			{
				return cpSpaceGetIterations(handle);
			}
			set
			{
				cpSpaceSetIterations(handle, value);
			}
		}

		public Vector2 Gravity
		{
			get
			{
				return cpSpaceGetGravity(handle);
			}
			set
			{
				cpSpaceSetGravity(handle, value);
			}
		}

		public Real Damping
		{
			get
			{
				return cpSpaceGetDamping(handle);
			}
			set
			{
				cpSpaceSetDamping(handle, value);
			}
		}

		public Real SleepTimeThreshold
		{
			get
			{
				return cpSpaceGetSleepTimeThreshold(handle);
			}
			set
			{
				cpSpaceSetSleepTimeThreshold(handle, value);
			}
		}

		public Real CollisionSlop
		{
			get
			{
				return cpSpaceGetCollisionSlop(handle);
			}
			set
			{
				cpSpaceSetCollisionSlop(handle, value);
			}
		}

		public Real CollisionBias
		{
			get
			{
				return cpSpaceGetCollisionBias(handle);
			}
			set
			{
				cpSpaceSetCollisionBias(handle, value);
			}
		}


		public uint32 CollisionPersistence
		{
			get
			{
				return cpSpaceGetCollisionPersistence(handle);
			}
			set
			{
				cpSpaceSetCollisionPersistence(handle, value);
			}
		}

		public Real CurrentTimeStep => cpSpaceGetCurrentTimeStep(handle);

		public bool IsLocked => cpSpaceIsLocked(handle);

		public this()
		{
			handle = cpSpaceNew();
			cpSpaceSetUserData(handle, Internal.UnsafeCastToPtr(this));
			StaticBody = new Body(cpSpaceGetStaticBody(handle), false);
		}

		public ~this()
		{
			delete StaticBody;
			cpSpaceFree(handle);
			handle = null;
		}

		public void AddBody(Body body)
		{
			cpSpaceAddBody(handle, body.Handle);
		}

		public void AddConstraint(Constraint constraint)
		{
			cpSpaceAddConstraint(handle, constraint.Handle);
		}

		public void RemoveBody(Body body)
		{
			cpSpaceRemoveBody(handle, body.Handle);
		}

		public void RemoveConstraint(Constraint constraint)
		{
			cpSpaceRemoveConstraint(handle, constraint.Handle);
		}

		public void Step(Real dt)
		{
			cpSpaceStep(handle, dt);
		}

		private static void OnBeginFuncCallback(void* arb, void* space, void* userData)
		{
			var collisionHandler = Internal.UnsafeCastToObject(userData) as CollisionHandler;
			if (collisionHandler.beginFunc != null)
			{
				collisionHandler.beginFunc(Arbiter(arb));
			}
		}

		private static void OnPreSolveFuncCallback(void* arb, void* space, void* userData)
		{
			var collisionHandler = Internal.UnsafeCastToObject(userData) as CollisionHandler;
			if (collisionHandler.preSolveFunc != null)
			{
				collisionHandler.preSolveFunc(Arbiter(arb));
			}
		}

		private static void OnPostSolveFuncCallback(void* arb, void* space, void* userData)
		{
			var collisionHandler = Internal.UnsafeCastToObject(userData) as CollisionHandler;
			if (collisionHandler.postSolveFunc != null)
			{
				collisionHandler.postSolveFunc(Arbiter(arb));
			}
		}

		private static void OnSeparateFuncCallback(void* arb, void* space, void* userData)
		{
			var collisionHandler = Internal.UnsafeCastToObject(userData) as CollisionHandler;
			if (collisionHandler.separateFunc != null)
			{
				collisionHandler.separateFunc(Arbiter(arb));
			}
		}

		private void SetCollisionHandlerInternal(CollisionHandler collisionHandler, cpCollisionHandler* collisionHandlerInternal)
		{
			collisionHandlerInternal.userData = Internal.UnsafeCastToPtr(collisionHandler);
			collisionHandlerInternal.typeA = collisionHandler.typeA;
			collisionHandlerInternal.typeB = collisionHandler.typeB;
			collisionHandlerInternal.beginFunc = => OnBeginFuncCallback;
			collisionHandlerInternal.preSolveFunc = => OnPreSolveFuncCallback;
			collisionHandlerInternal.postSolveFunc = => OnPostSolveFuncCallback;
			collisionHandlerInternal.separateFunc = => OnSeparateFuncCallback;
		}

		public void AddDefaultCollisionHandler(CollisionHandler collisionHandler)
		{
			SetCollisionHandlerInternal(collisionHandler, cpSpaceAddDefaultCollisionHandler(handle));
		}

		public void AddCollisionHandler(CollisionHandler collisionHandler, uint collisionTypeA, uint collisionTypeB)
		{
			SetCollisionHandlerInternal(collisionHandler, cpSpaceAddCollisionHandler(handle, collisionTypeA, collisionTypeB));
		}

		public void AddWildcardHandler(CollisionHandler collisionHandler, uint collisionType)
		{
			SetCollisionHandlerInternal(collisionHandler, cpSpaceAddWildcardHandler(handle, collisionType));
		}

		private static void OnPostStepCallback(void* _space, uint key, void* data)
		{
			var space = Internal.UnsafeCastToObject(data) as Space;
			for (var callback in space.postStepCallbacks)
			{
				callback();
			}
			space.postStepCallbacks.Clear();
		}

		public void AddPostStepCallback(delegate void() func)
		{
			postStepCallbacks.Add(func);
			if (postStepCallbacks.Count == 1)
			{
				cpSpaceAddPostStepCallback(handle, => OnPostStepCallback, 0, Internal.UnsafeCastToPtr(this));
			}
		}

		[CLink]
		private static extern void* cpSpaceNew();

		[CLink]
		private static extern void cpSpaceFree(void* space);


		/// Number of iterations to use in the impulse solver to solve contacts and other constraints.
		[CLink]
		private static extern int32 cpSpaceGetIterations(void* space);
		[CLink]
		private static extern void cpSpaceSetIterations(void* space, int32 iterations);

		/// Gravity to pass to rigid bodies when integrating velocity.
		[CLink]
		private static extern Vector2 cpSpaceGetGravity(void* space);
		[CLink]
		private static extern void cpSpaceSetGravity(void* space, Vector2 gravity);

		/// Damping rate expressed as the fraction of velocity bodies retain each second.
		/// A value of 0.9 would mean that each body's velocity will drop 10% per second.
		/// The default value is 1.0, meaning no damping is applied.
		/// @note This damping value is different than those of cpDampedSpring and cpDampedRotarySpring.
		[CLink]
		private static extern Real cpSpaceGetDamping(void* space);
		[CLink]
		private static extern void cpSpaceSetDamping(void* space, Real damping);

		/// Speed threshold for a body to be considered idle.
		/// The default value of 0 means to let the space guess a good threshold based on gravity.
		[CLink]
		private static extern Real cpSpaceGetIdleSpeedThreshold(void* space);
		[CLink]
		private static extern void cpSpaceSetIdleSpeedThreshold(void* space, Real idleSpeedThreshold);

		/// Time a group of bodies must remain idle in order to fall asleep.
		/// Enabling sleeping also implicitly enables the the contact graph.
		/// The default value of INFINITY disables the sleeping algorithm.
		[CLink]
		private static extern Real cpSpaceGetSleepTimeThreshold(void* space);
		[CLink]
		private static extern void cpSpaceSetSleepTimeThreshold(void* space, Real sleepTimeThreshold);

		/// Amount of encouraged penetration between colliding shapes.
		/// Used to reduce oscillating contacts and keep the collision cache warm.
		/// Defaults to 0.1. If you have poor simulation quality,
		/// increase this number as much as possible without allowing visible amounts of overlap.
		[CLink]
		private static extern Real cpSpaceGetCollisionSlop(void* space);
		[CLink]
		private static extern void cpSpaceSetCollisionSlop(void* space, Real collisionSlop);

		/// Determines how fast overlapping shapes are pushed apart.
		/// Expressed as a fraction of the error remaining after each second.
		/// Defaults to pow(1.0 - 0.1, 60.0) meaning that Chipmunk fixes 10% of overlap each frame at 60Hz.
		[CLink]
		private static extern Real cpSpaceGetCollisionBias(void* space);
		[CLink]
		private static extern void cpSpaceSetCollisionBias(void* space, Real collisionBias);

		/// Number of frames that contact information should persist.
		/// Defaults to 3. There is probably never a reason to change this value.
		[CLink]
		private static extern uint32 cpSpaceGetCollisionPersistence(void* space);
		[CLink]
		private static extern void cpSpaceSetCollisionPersistence(void* space, uint32 collisionPersistence);

		/// User definable data pointer.
		/// Generally this points to your game's controller or game state
		/// class so you can access it when given a Space reference in a callback.
		[CLink]
		private static extern void* cpSpaceGetUserData(void* space);
		[CLink]
		private static extern void cpSpaceSetUserData(void* space, void* userData);

		/// The Space provided static body for a given Space.
		/// This is merely provided for convenience and you are not required to use it.
		[CLink]
		private static extern void* cpSpaceGetStaticBody(void* space);

		/// Returns the current (or most recent) time step used with the given space.
		/// Useful from callbacks if your time step is not a compile-time global.
		[CLink]
		private static extern Real cpSpaceGetCurrentTimeStep(void* space);

		/// Struct that holds function callback pointers to configure custom collision handling.
		/// Collision handlers have a pair of types; when a collision occurs between two shapes that have these types,
		// the collision handler functions are triggered.
		[CRepr]
		public struct cpCollisionHandler
		{
			/// Collision type identifier of the first shape that this handler recognizes.
			/// In the collision handler callback, the shape with this type will be the first argument. Read only.
			public uint typeA;
			/// Collision type identifier of the second shape that this handler recognizes.
			/// In the collision handler callback, the shape with this type will be the second argument. Read only.
			public uint typeB;
			/// This function is called when two shapes with types that match this collision handler begin colliding.
			public function void(void* arb, void* space, void* userData) beginFunc;
			/// This function is called each step when two shapes with types that match this collision handler are
			// colliding. It's called before the collision solver runs so that you can affect a collision's outcome.
			public function void(void* arb, void* space, void* userData) preSolveFunc;
			/// This function is called each step when two shapes with types that match this collision handler are
			// colliding. It's called after the collision solver runs so that you can read back information about the
			// collision to trigger events in your game.
			public function void(void* arb, void* space, void* userData) postSolveFunc;
			/// This function is called when two shapes with types that match this collision handler stop colliding.
			public function void(void* arb, void* space, void* userData) separateFunc;
			/// This is a user definable context pointer that is passed to all of the collision handler functions.
			public void* userData;
		};

		/// Create or return the existing collision handler that is called for all collisions that are not handled by a
		// more specific collision handler.
		[CLink]
		private static extern cpCollisionHandler* cpSpaceAddDefaultCollisionHandler(void* space);
		/// Create or return the existing collision handler for the specified pair of collision types.
		/// If wildcard handlers are used with either of the collision types, it's the responibility of the custom
		// handler to invoke the wildcard handlers.
		[CLink]
		private static extern cpCollisionHandler* cpSpaceAddCollisionHandler(void* space, uint a, uint b);
		/// Create or return the existing wildcard collision handler for the specified type.
		[CLink]
		private static extern cpCollisionHandler* cpSpaceAddWildcardHandler(void* space, uint type);

		/// returns true from inside a callback when objects cannot be added/removed.
		[CLink] private static extern bool cpSpaceIsLocked(void* space);

		/// Add a rigid body to the simulation.
		[CLink] private static extern void* cpSpaceAddBody(void* space, void* body);
		/// Add a constraint to the simulation.
		[CLink] private static extern void* cpSpaceAddConstraint(void* space, void* constraint);

		/// Remove a rigid body from the simulation.
		[CLink] private static extern void cpSpaceRemoveBody(void* space, void* body);
		/// Remove a constraint from the simulation.
		[CLink] private static extern void cpSpaceRemoveConstraint(void* space, void* constraint);

		/// Step the space forward in time by @c dt.
		[CLink] private static extern void cpSpaceStep(void* space, Real dt);

		/// Schedule a post-step callback to be called when cpSpaceStep() finishes.
		/// You can only register one callback per unique value for @c key.
		/// Returns true only if @c key has never been scheduled before.
		/// It's possible to pass @c NULL for @c func if you only want to mark @c key as being used.
		[CLink] private static extern bool cpSpaceAddPostStepCallback(void* space, function void(void* space, uint key, void* data) func, uint key, void* data);

		/// Get the user definable data pointer of this shape.
		[CLink]
		private static extern void* cpShapeGetUserData(void* shape);

		[CRepr]
		public struct cpPointQueryInfo
		{
			public void* shapeHandle;
			public Vector2 point;
			public Real distance;
			public Vector2 gradient;
		}

		[CRepr]
		public struct cpSegmentQueryInfo
		{
			public void* shapeHandle;
			public Vector2 point;
			public Vector2 normal;
			public Real alpha;
		}

		private static void OnPointQuery(void* shape, Vector2 point, Real distance, Vector2 gradient, void* data)
		{
			var infos = Internal.UnsafeCastToObject(data) as List<PointQueryInfo>;
			infos.Add(PointQueryInfo() { shape = Internal.UnsafeCastToObject(cpShapeGetUserData(shape)) as Shape, point = point, distance = distance, gradient = gradient });
		}

		public void PointQuery(Vector2 point, Real maxDistance, ShapeFilter filter, ref List<PointQueryInfo> infos)
		{
			cpSpacePointQuery(handle, point, maxDistance, filter, => OnPointQuery, Internal.UnsafeCastToPtr(infos));
		}

		public bool PointQueryNearest(Vector2 point, Real maxDistance, ShapeFilter filter, out PointQueryInfo outValue)
		{
			outValue = PointQueryInfo();
			var infoInternal = cpPointQueryInfo();
			var shapeHandle = cpSpacePointQueryNearest(handle, point, maxDistance, filter, &infoInternal);
			var shape = Internal.UnsafeCastToObject(cpShapeGetUserData(shapeHandle)) as Shape;
			if (shape == null)
			{
				return false;
			}
			outValue.shape = shape;
			outValue.point = infoInternal.point;
			outValue.distance = infoInternal.distance;
			outValue.gradient = infoInternal.gradient;
			return true;
		}

		private static void OnSegmentQuery(void* shape, Vector2 point, Vector2 normal, Real alpha, void* data)
		{
			var infos = Internal.UnsafeCastToObject(data) as List<SegmentQueryInfo>;
			infos.Add(SegmentQueryInfo() { shape = Internal.UnsafeCastToObject(cpShapeGetUserData(shape)) as Shape, point = point, normal = normal, alpha = alpha });
		}

		public void SegmentQuery(Vector2 start, Vector2 end, Real radius, ShapeFilter filter, ref List<SegmentQueryInfo> infos)
		{
			cpSpaceSegmentQuery(handle, start, end, radius, filter, => OnSegmentQuery, Internal.UnsafeCastToPtr(infos));
		}

		public bool SegmentQueryFirst(Vector2 start, Vector2 end, Real radius, ShapeFilter filter, out SegmentQueryInfo outValue)
		{
			outValue = SegmentQueryInfo();
			var infoInternal = cpSegmentQueryInfo();
			var shapeHandle = cpSpaceSegmentQueryFirst(handle, start, end, radius, filter, &infoInternal);
			if (shapeHandle == null)
			{
				return false;
			}
			var shape = Internal.UnsafeCastToObject(cpShapeGetUserData(shapeHandle)) as Shape;
			if (shape == null)
			{
				return false;
			}
			outValue.shape = shape;
			outValue.point = infoInternal.point;
			outValue.normal = infoInternal.normal;
			outValue.alpha = infoInternal.alpha;
			return true;
		}

		private static void OnBBQuery(void* shape, void* data)
		{
			var shapes = Internal.UnsafeCastToObject(data) as List<Shape>;
			shapes.Add(Internal.UnsafeCastToObject(cpShapeGetUserData(shape)) as Shape);
		}

		public void BBQuery(void* space, Bounds bb, ShapeFilter filter, ref List<Shape> shapes)
		{
			cpSpaceBBQuery(handle, bb, filter, => OnBBQuery, Internal.UnsafeCastToPtr(shapes));
		}

		private static void OnShapeQuery(void* shape, ContactPointSet* points, void* data)
		{
			var infos = Internal.UnsafeCastToObject(data) as List<ShapeQueryInfo>;
			var info = ShapeQueryInfo();
			info.shape = Internal.UnsafeCastToObject(cpShapeGetUserData(shape)) as Shape;
			info.contactPointSet = *points;
			infos.Add(info);
		}

		public bool ShapeQuery(Shape shape, ref List<ShapeQueryInfo> infos)
		{
			return cpSpaceShapeQuery(handle, shape.Handle, => OnShapeQuery, Internal.UnsafeCastToPtr(infos));
		}

		public void DebugDraw(ref DebugDrawOptions options)
		{
			cpSpaceDebugDraw(handle, &options);
		}

		/// Nearest point query callback function type.
		/// Query the space at a point and call @c func for each shape found.
		[CLink] private static extern void cpSpacePointQuery(void* space, Vector2 point, Real maxDistance, ShapeFilter filter, function void(void* shape, Vector2 point, Real distance, Vector2 gradient, void* data) func, void* data);
		/// Query the space at a point and return the nearest shape found. Returns NULL if no shapes were found.
		[CLink] private static extern void* cpSpacePointQueryNearest(void* space, Vector2 point, Real maxDistance, ShapeFilter filter, cpPointQueryInfo* outValue);

		/// Segment query callback function type.
		/// Perform a directed line segment query (like a raycast) against the space calling @c func for each shape
		// intersected.
		[CLink] private static extern void cpSpaceSegmentQuery(void* space, Vector2 start, Vector2 end, Real radius, ShapeFilter filter, function void(void* shape, Vector2 point, Vector2 normal, Real alpha, void* data) func, void* data);
		/// Perform a directed line segment query (like a raycast) against the space and return the first shape hit.
		// Returns NULL if no shapes were hit.
		[CLink] private static extern void* cpSpaceSegmentQueryFirst(void* space, Vector2 start, Vector2 end, Real radius, ShapeFilter filter, cpSegmentQueryInfo* outValue);

		/// Rectangle Query callback function type.
		/// Perform a fast rectangle query on the space calling @c func for each shape found.
		/// Only the shape's bounding boxes are checked for overlap, not their full shape.
		[CLink] private static extern void cpSpaceBBQuery(void* space, Bounds bb, ShapeFilter filter, function void(void* shape, void* data) func, void* data);

		/// Shape query callback function type.
		/// Query a space for any shapes overlapping the given shape and call @c func for each shape found.
		[CLink] private static extern bool cpSpaceShapeQuery(void* space, void* shape, function void(void* shape, ContactPointSet* points, void* data) func, void* data);

		/// Debug draw the current state of the space using the supplied drawing options.
		[CLink] private static extern void cpSpaceDebugDraw(void* space, DebugDrawOptions* options);
	}
}
