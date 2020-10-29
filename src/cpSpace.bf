using System;
using System.Collections;

namespace Chipmunk2D
{
	class cpCollisionHandler
	{
		public uint typeA;
		public uint typeB;
		public delegate void(cpArbiter arb) beginFunc;
		public delegate void(cpArbiter arb) preSolveFunc;
		public delegate void(cpArbiter arb) postSolveFunc;
		public delegate void(cpArbiter arb) separateFunc;
	}

	/// Point query info struct.
	struct cpPointQueryInfo
	{
		/// The nearest shape, NULL if no shape was within range.
		public cpShape shape;
		/// The closest point on the shape's surface. (in world space coordinates)
		public cpVect point;
		/// The distance to the point. The distance is negative if the point is inside the shape.
		public float distance;
		/// The gradient of the signed distance function.
		/// The value should be similar to info.p/info.d, but accurate even for very small values of info.d.
		public cpVect gradient;
	}

	/// Segment query info struct.
	struct cpSegmentQueryInfo
	{
		/// The shape that was hit, or NULL if no collision occured.
		public cpShape shape;
		/// The point of impact.
		public cpVect point;
		/// The normal of the surface hit.
		public cpVect normal;
		/// The normalized distance along the query segment in the range [0, 1].
		public float alpha;
	}

	struct cpShapeQueryInfo
	{
		public cpShape shape;
		public cpContactPointSet contactPointSet;
	}

	class cpSpace : cpObject
	{
		public cpBody StaticBody { get; private set; };
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

		public cpVect Gravity
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

		public float Damping
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

		public float SleepTimeThreshold
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

		public float CollisionSlop
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

		public float CollisionBias
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

		public float CurrentTimeStep => cpSpaceGetCurrentTimeStep(handle);

		public bool IsLocked => cpSpaceIsLocked(handle);

		public this()
		{
			handle = cpSpaceNew();
			cpSpaceSetUserData(handle, Internal.UnsafeCastToPtr(this));
			StaticBody = new cpBody(cpSpaceGetStaticBody(handle), false);
		}

		public ~this()
		{
			delete StaticBody;
			cpSpaceFree(handle);
			handle = null;
		}

		public void AddBody(cpBody body)
		{
			cpSpaceAddBody(handle, body.Handle);
		}

		public void AddConstraint(cpConstraint constraint)
		{
			cpSpaceAddConstraint(handle, constraint.Handle);
		}

		public void RemoveBody(cpBody body)
		{
			cpSpaceRemoveBody(handle, body.Handle);
		}

		public void RemoveConstraint(cpConstraint constraint)
		{
			cpSpaceRemoveConstraint(handle, constraint.Handle);
		}

		public void Step(float dt)
		{
			cpSpaceStep(handle, dt);
		}

		private static void OnBeginFuncCallback(void* arb, void* space, void* userData)
		{
			var collisionHandler = Internal.UnsafeCastToObject(userData) as cpCollisionHandler;
			if (collisionHandler.beginFunc != null)
			{
				collisionHandler.beginFunc(cpArbiter(arb));
			}
		}

		private static void OnPreSolveFuncCallback(void* arb, void* space, void* userData)
		{
			var collisionHandler = Internal.UnsafeCastToObject(userData) as cpCollisionHandler;
			if (collisionHandler.preSolveFunc != null)
			{
				collisionHandler.preSolveFunc(cpArbiter(arb));
			}
		}

		private static void OnPostSolveFuncCallback(void* arb, void* space, void* userData)
		{
			var collisionHandler = Internal.UnsafeCastToObject(userData) as cpCollisionHandler;
			if (collisionHandler.postSolveFunc != null)
			{
				collisionHandler.postSolveFunc(cpArbiter(arb));
			}
		}

		private static void OnSeparateFuncCallback(void* arb, void* space, void* userData)
		{
			var collisionHandler = Internal.UnsafeCastToObject(userData) as cpCollisionHandler;
			if (collisionHandler.separateFunc != null)
			{
				collisionHandler.separateFunc(cpArbiter(arb));
			}
		}

		private void SetCollisionHandlerInternal(cpCollisionHandler collisionHandler, cpCollisionHandlerInternal* collisionHandlerInternal)
		{
			collisionHandlerInternal.userData = Internal.UnsafeCastToPtr(collisionHandler);
			collisionHandlerInternal.typeA = collisionHandler.typeA;
			collisionHandlerInternal.typeB = collisionHandler.typeB;
			collisionHandlerInternal.beginFunc = => OnBeginFuncCallback;
			collisionHandlerInternal.preSolveFunc = => OnPreSolveFuncCallback;
			collisionHandlerInternal.postSolveFunc = => OnPostSolveFuncCallback;
			collisionHandlerInternal.separateFunc = => OnSeparateFuncCallback;
		}

		public void AddDefaultCollisionHandler(cpCollisionHandler collisionHandler)
		{
			SetCollisionHandlerInternal(collisionHandler, cpSpaceAddDefaultCollisionHandler(handle));
		}

		public void AddCollisionHandler(cpCollisionHandler collisionHandler, uint collisionTypeA, uint collisionTypeB)
		{
			SetCollisionHandlerInternal(collisionHandler, cpSpaceAddCollisionHandler(handle, collisionTypeA, collisionTypeB));
		}

		public void AddWildcardHandler(cpCollisionHandler collisionHandler, uint collisionType)
		{
			SetCollisionHandlerInternal(collisionHandler, cpSpaceAddWildcardHandler(handle, collisionType));
		}

		private static void OnPostStepCallback(void* _space, uint key, void* data)
		{
			var space = Internal.UnsafeCastToObject(data) as cpSpace;
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
		private static extern cpVect cpSpaceGetGravity(void* space);
		[CLink]
		private static extern void cpSpaceSetGravity(void* space, cpVect gravity);

		/// Damping rate expressed as the fraction of velocity bodies retain each second.
		/// A value of 0.9 would mean that each body's velocity will drop 10% per second.
		/// The default value is 1.0, meaning no damping is applied.
		/// @note This damping value is different than those of cpDampedSpring and cpDampedRotarySpring.
		[CLink]
		private static extern float cpSpaceGetDamping(void* space);
		[CLink]
		private static extern void cpSpaceSetDamping(void* space, float damping);

		/// Speed threshold for a body to be considered idle.
		/// The default value of 0 means to let the space guess a good threshold based on gravity.
		[CLink]
		private static extern float cpSpaceGetIdleSpeedThreshold(void* space);
		[CLink]
		private static extern void cpSpaceSetIdleSpeedThreshold(void* space, float idleSpeedThreshold);

		/// Time a group of bodies must remain idle in order to fall asleep.
		/// Enabling sleeping also implicitly enables the the contact graph.
		/// The default value of INFINITY disables the sleeping algorithm.
		[CLink]
		private static extern float cpSpaceGetSleepTimeThreshold(void* space);
		[CLink]
		private static extern void cpSpaceSetSleepTimeThreshold(void* space, float sleepTimeThreshold);

		/// Amount of encouraged penetration between colliding shapes.
		/// Used to reduce oscillating contacts and keep the collision cache warm.
		/// Defaults to 0.1. If you have poor simulation quality,
		/// increase this number as much as possible without allowing visible amounts of overlap.
		[CLink]
		private static extern float cpSpaceGetCollisionSlop(void* space);
		[CLink]
		private static extern void cpSpaceSetCollisionSlop(void* space, float collisionSlop);

		/// Determines how fast overlapping shapes are pushed apart.
		/// Expressed as a fraction of the error remaining after each second.
		/// Defaults to pow(1.0 - 0.1, 60.0) meaning that Chipmunk fixes 10% of overlap each frame at 60Hz.
		[CLink]
		private static extern float cpSpaceGetCollisionBias(void* space);
		[CLink]
		private static extern void cpSpaceSetCollisionBias(void* space, float collisionBias);

		/// Number of frames that contact information should persist.
		/// Defaults to 3. There is probably never a reason to change this value.
		[CLink]
		private static extern uint32 cpSpaceGetCollisionPersistence(void* space);
		[CLink]
		private static extern void cpSpaceSetCollisionPersistence(void* space, uint32 collisionPersistence);

		/// User definable data pointer.
		/// Generally this points to your game's controller or game state
		/// class so you can access it when given a cpSpace reference in a callback.
		[CLink]
		private static extern void* cpSpaceGetUserData(void* space);
		[CLink]
		private static extern void cpSpaceSetUserData(void* space, void* userData);

		/// The Space provided static body for a given cpSpace.
		/// This is merely provided for convenience and you are not required to use it.
		[CLink]
		private static extern void* cpSpaceGetStaticBody(void* space);

		/// Returns the current (or most recent) time step used with the given space.
		/// Useful from callbacks if your time step is not a compile-time global.
		[CLink]
		private static extern float cpSpaceGetCurrentTimeStep(void* space);

		/// Struct that holds function callback pointers to configure custom collision handling.
		/// Collision handlers have a pair of types; when a collision occurs between two shapes that have these types,
		// the collision handler functions are triggered.
		[CRepr]
		internal struct cpCollisionHandlerInternal
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
		private static extern cpCollisionHandlerInternal* cpSpaceAddDefaultCollisionHandler(void* space);
		/// Create or return the existing collision handler for the specified pair of collision types.
		/// If wildcard handlers are used with either of the collision types, it's the responibility of the custom
		// handler to invoke the wildcard handlers.
		[CLink]
		private static extern cpCollisionHandlerInternal* cpSpaceAddCollisionHandler(void* space, uint a, uint b);
		/// Create or return the existing wildcard collision handler for the specified type.
		[CLink]
		private static extern cpCollisionHandlerInternal* cpSpaceAddWildcardHandler(void* space, uint type);

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
		[CLink] private static extern void cpSpaceStep(void* space, float dt);

		/// Schedule a post-step callback to be called when cpSpaceStep() finishes.
		/// You can only register one callback per unique value for @c key.
		/// Returns true only if @c key has never been scheduled before.
		/// It's possible to pass @c NULL for @c func if you only want to mark @c key as being used.
		[CLink] private static extern bool cpSpaceAddPostStepCallback(void* space, function void(void* space, uint key, void* data) func, uint key, void* data);

		/// Get the user definable data pointer of this shape.
		[CLink]
		private static extern void* cpShapeGetUserData(void* shape);

		[CRepr]
		public struct cpPointQueryInfoInternal
		{
			public void* shapeHandle;
			public cpVect point;
			public float distance;
			public cpVect gradient;
		}

		[CRepr]
		public struct cpSegmentQueryInfoInternal
		{
			public void* shapeHandle;
			public cpVect point;
			public cpVect normal;
			public float alpha;
		}

		private static void OnPointQuery(void* shape, cpVect point, float distance, cpVect gradient, void* data)
		{
			var infos = Internal.UnsafeCastToObject(data) as List<cpPointQueryInfo>;
			infos.Add(cpPointQueryInfo() { shape = Internal.UnsafeCastToObject(cpShapeGetUserData(shape)) as cpShape, point = point, distance = distance, gradient = gradient });
		}

		public void PointQuery(cpVect point, float maxDistance, cpShapeFilter filter, ref List<cpPointQueryInfo> infos)
		{
			cpSpacePointQuery(handle, point, maxDistance, filter, => OnPointQuery, Internal.UnsafeCastToPtr(infos));
		}

		public bool PointQueryNearest(cpVect point, float maxDistance, cpShapeFilter filter, out cpPointQueryInfo outValue)
		{
			outValue = cpPointQueryInfo();
			var infoInternal = cpPointQueryInfoInternal();
			var shapeHandle = cpSpacePointQueryNearest(handle, point, maxDistance, filter, &infoInternal);
			var shape = Internal.UnsafeCastToObject(cpShapeGetUserData(shapeHandle)) as cpShape;
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

		private static void OnSegmentQuery(void* shape, cpVect point, cpVect normal, float alpha, void* data)
		{
			var infos = Internal.UnsafeCastToObject(data) as List<cpSegmentQueryInfo>;
			infos.Add(cpSegmentQueryInfo() { shape = Internal.UnsafeCastToObject(cpShapeGetUserData(shape)) as cpShape, point = point, normal = normal, alpha = alpha });
		}

		public void SegmentQuery(cpVect start, cpVect end, float radius, cpShapeFilter filter, ref List<cpSegmentQueryInfo> infos)
		{
			cpSpaceSegmentQuery(handle, start, end, radius, filter, => OnSegmentQuery, Internal.UnsafeCastToPtr(infos));
		}

		public bool SegmentQueryFirst(cpVect start, cpVect end, float radius, cpShapeFilter filter, out cpSegmentQueryInfo outValue)
		{
			outValue = cpSegmentQueryInfo();
			var infoInternal = cpSegmentQueryInfoInternal();
			var shapeHandle = cpSpaceSegmentQueryFirst(handle, start, end, radius, filter, &infoInternal);
			var shape = Internal.UnsafeCastToObject(cpShapeGetUserData(shapeHandle)) as cpShape;
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
			var shapes = Internal.UnsafeCastToObject(data) as List<cpShape>;
			shapes.Add(Internal.UnsafeCastToObject(cpShapeGetUserData(shape)) as cpShape);
		}

		public void BBQuery(void* space, cpBB bb, cpShapeFilter filter, ref List<cpShape> shapes)
		{
			cpSpaceBBQuery(handle, bb, filter, => OnBBQuery, Internal.UnsafeCastToPtr(shapes));
		}

		private static void OnShapeQuery(void* shape, cpContactPointSet* points, void* data)
		{
			var infos = Internal.UnsafeCastToObject(data) as List<cpShapeQueryInfo>;
			var info = cpShapeQueryInfo();
			info.shape = Internal.UnsafeCastToObject(cpShapeGetUserData(shape)) as cpShape;
			info.contactPointSet = *points;
			infos.Add(info);
		}

		public bool ShapeQuery(cpShape shape, ref List<cpShapeQueryInfo> infos)
		{
			return cpSpaceShapeQuery(handle, shape.Handle, => OnShapeQuery, Internal.UnsafeCastToPtr(infos));
		}

		/// Nearest point query callback function type.
		/// Query the space at a point and call @c func for each shape found.
		[CLink] private static extern void cpSpacePointQuery(void* space, cpVect point, float maxDistance, cpShapeFilter filter, function void(void* shape, cpVect point, float distance, cpVect gradient, void* data) func, void* data);
		/// Query the space at a point and return the nearest shape found. Returns NULL if no shapes were found.
		[CLink] private static extern void* cpSpacePointQueryNearest(void* space, cpVect point, float maxDistance, cpShapeFilter filter, cpPointQueryInfoInternal* outValue);

		/// Segment query callback function type.
		/// Perform a directed line segment query (like a raycast) against the space calling @c func for each shape
		// intersected.
		[CLink] private static extern void cpSpaceSegmentQuery(void* space, cpVect start, cpVect end, float radius, cpShapeFilter filter, function void(void* shape, cpVect point, cpVect normal, float alpha, void* data) func, void* data);
		/// Perform a directed line segment query (like a raycast) against the space and return the first shape hit.
		// Returns NULL if no shapes were hit.
		[CLink] private static extern void* cpSpaceSegmentQueryFirst(void* space, cpVect start, cpVect end, float radius, cpShapeFilter filter, cpSegmentQueryInfoInternal* outValue);

		/// Rectangle Query callback function type.
		/// Perform a fast rectangle query on the space calling @c func for each shape found.
		/// Only the shape's bounding boxes are checked for overlap, not their full shape.
		[CLink] private static extern void cpSpaceBBQuery(void* space, cpBB bb, cpShapeFilter filter, function void(void* shape, void* data) func, void* data);

		/// Shape query callback function type.
		/// Query a space for any shapes overlapping the given shape and call @c func for each shape found.
		[CLink] private static extern bool cpSpaceShapeQuery(void* space, void* shape, function void(void* shape, cpContactPointSet* points, void* data) func, void* data);
	}
}