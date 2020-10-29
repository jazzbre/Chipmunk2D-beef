using System;

namespace Chipmunk2D
{
	struct ArbiterBodyInfo
	{
		public Body bodyA , bodyB;
	}

	struct ArbiterShapeInfo
	{
		public Shape shapeA , shapeB;
	}

	[CRepr]
	struct ContactPoint
	{
		/// The position of the contact on the surface of each shape.
		public Vector2 pointA;
		public Vector2 pointB;
		/// Penetration distance of the two shapes. Overlapping means it will be negative.
		/// This value is calculated as cpvdot(cpvsub(point2, point1), normal) and is ignored by
		// cpArbiterSetContactPointSet().
		public float distance;
	}

	/// A struct that wraps up the important collision data for an arbiter.
	[CRepr]
	struct ContactPointSet
	{
		/// The number of contact points in the set.
		int32 count;

		/// The normal of the collision.
		Vector2 normal;

		/// The array of contact points.
		ContactPoint[2] points;
	}

	struct Arbiter
	{
		private void* handle = null;

		public this(void* _handle)
		{
			handle = _handle;
		}

		public float Restituion
		{
			get
			{
				return cpArbiterGetRestitution(handle);
			}
			set
			{
				cpArbiterSetRestitution(handle, value);
			}
		}

		public float Friction
		{
			get
			{
				return cpArbiterGetFriction(handle);
			}
			set
			{
				cpArbiterSetFriction(handle, value);
			}
		}


		public Vector2 SurfaceVelocity
		{
			get
			{
				return cpArbiterGetSurfaceVelocity(handle);
			}
			set
			{
				cpArbiterSetSurfaceVelocity(handle, value);
			}
		}

		public Vector2 TotalImpulse
		{
			get
			{
				return cpArbiterTotalImpulse(handle);
			}
		}

		public float TotalKE
		{
			get
			{
				return cpArbiterTotalKE(handle);
			}
		}

		public bool Ignore
		{
			get
			{
				return cpArbiterIgnore(handle);
			}
		}

		public ArbiterBodyInfo Bodies
		{
			get
			{
				void* a = ?;
				void* b = ?;
				cpArbiterGetBodies(handle, &a, &b);
				var bodyInfo = ArbiterBodyInfo() { bodyA = Internal.UnsafeCastToObject(a) as Body, bodyB = Internal.UnsafeCastToObject(b) as Body };
				return bodyInfo;
			}
		}


		public ArbiterShapeInfo Shapes
		{
			get
			{
				void* a = ?;
				void* b = ?;
				cpArbiterGetShapes(handle, &a, &b);
				var shapeInfo = ArbiterShapeInfo() { shapeA = Internal.UnsafeCastToObject(a) as Shape, shapeB = Internal.UnsafeCastToObject(b) as Shape };
				return shapeInfo;
			}
		}

		public bool IsFirstContact => cpArbiterIsFirstContact(handle);

		public bool IsRemoval => cpArbiterIsRemoval(handle);


		public int Count => cpArbiterGetCount(handle);

		public Vector2 Normal => cpArbiterGetNormal(handle);

		public ContactPoint this[int index]
		{
			get
			{
				var contactPoint = ContactPoint();
				contactPoint.pointA = cpArbiterGetPointA(handle, (int32)index);
				contactPoint.pointB = cpArbiterGetPointB(handle, (int32)index);
				contactPoint.distance = cpArbiterGetDepth(handle, (int32)index);
				return contactPoint;
			}
		}

		public ContactPointSet ContactPointSet
		{
			get
			{
				return cpArbiterGetContactPointSet(handle);
			}
			set
			{
				var valueCopy = value;
				cpArbiterSetContactPointSet(handle, &valueCopy);
			}
		}

		/// Get the restitution (elasticity) that will be applied to the pair of colliding objects.
		[CLink]
		private static extern float cpArbiterGetRestitution(void* arb);
		/// Override the restitution (elasticity) that will be applied to the pair of colliding objects.
		[CLink]
		private static extern void cpArbiterSetRestitution(void* arb, float restitution);
		/// Get the friction coefficient that will be applied to the pair of colliding objects.
		[CLink]
		private static extern float cpArbiterGetFriction(void* arb);
		/// Override the friction coefficient that will be applied to the pair of colliding objects.
		[CLink]
		private static extern void cpArbiterSetFriction(void* arb, float friction);

		// Get the relative surface velocity of the two shapes in contact.
		[CLink]
		private static extern Vector2 cpArbiterGetSurfaceVelocity(void* arb);

		// Override the relative surface velocity of the two shapes in contact.
		// By default this is calculated to be the difference of the two surface velocities clamped to the tangent
		// plane.
		[CLink]
		private static extern void cpArbiterSetSurfaceVelocity(void* arb, Vector2 vr);

		/// Get the user data pointer associated with this pair of colliding objects.
		[CLink]
		private static extern void* cpArbiterGetUserData(void* arb);
		/// Set a user data point associated with this pair of colliding objects.
		/// If you need to perform any cleanup for this pointer, you must do it yourself, in the separate callback for
		// instance.
		[CLink]
		private static extern void cpArbiterSetUserData(void* arb, void* userData);

		/// Calculate the total impulse including the friction that was applied by this arbiter.
		/// This function should only be called from a post-solve, post-step or cpBodyEachArbiter callback.
		[CLink]
		private static extern Vector2 cpArbiterTotalImpulse(void* arb);
		/// Calculate the amount of energy lost in a collision including static, but not dynamic friction.
		/// This function should only be called from a post-solve, post-step or cpBodyEachArbiter callback.
		[CLink]
		private static extern float cpArbiterTotalKE(void* arb);

		/// Mark a collision pair to be ignored until the two objects separate.
		/// Pre-solve and post-solve callbacks will not be called, but the separate callback will be called.
		[CLink]
		private static extern bool cpArbiterIgnore(void* arb);

		/// Return the colliding shapes involved for this arbiter.
		/// The order of their Space.collision_type values will match
		/// the order set when the collision handler was registered.
		[CLink]
		private static extern void cpArbiterGetShapes(void* arb, void** a, void** b);

		/// Return the colliding bodies involved for this arbiter.
		/// The order of the Space.collision_type the bodies are associated with values will match
		/// the order set when the collision handler was registered.
		[CLink]
		private static extern void cpArbiterGetBodies(void* arb, void** a, void** b);

		/// Return a contact set from an arbiter.
		[CLink]
		private static extern ContactPointSet cpArbiterGetContactPointSet(void* arb);

		/// Replace the contact point set for an arbiter.
		/// This can be a very powerful feature, but use it with caution!
		[CLink]
		private static extern void cpArbiterSetContactPointSet(void* arb, ContactPointSet* set);

		/// Returns true if this is the first step a pair of objects started colliding.
		[CLink]
		private static extern bool cpArbiterIsFirstContact(void* arb);
		/// Returns true if the separate callback is due to a shape being removed from the space.
		[CLink]
		private static extern bool cpArbiterIsRemoval(void* arb);

		/// Get the number of contact points for this arbiter.
		[CLink]
		private static extern int32 cpArbiterGetCount(void* arb);
		/// Get the normal of the collision.
		[CLink]
		private static extern Vector2 cpArbiterGetNormal(void* arb);
		/// Get the position of the @c ith contact point on the surface of the first shape.
		[CLink]
		private static extern Vector2 cpArbiterGetPointA(void* arb, int32 i);
		/// Get the position of the @c ith contact point on the surface of the second shape.
		[CLink]
		private static extern Vector2 cpArbiterGetPointB(void* arb, int32 i);
		[CLink]
		/// Get the depth of the @c ith contact point.
		private static extern float cpArbiterGetDepth(void* arb, int32 i);

		/// If you want a custom callback to invoke the wildcard callback for the first collision type, you must call
		// this function explicitly. You must decide how to handle the wildcard's return value since it may disagree
		// with the other wildcard handler's return value or your own.
		[CLink]
		private static extern bool cpArbiterCallWildcardBeginA(void* arb, void* space);
		/// If you want a custom callback to invoke the wildcard callback for the second collision type, you must call
		// this function explicitly. You must decide how to handle the wildcard's return value since it may disagree
		// with the other wildcard handler's return value or your own.
		[CLink]
		private static extern bool cpArbiterCallWildcardBeginB(void* arb, void* space);

		/// If you want a custom callback to invoke the wildcard callback for the first collision type, you must call
		// this function explicitly. You must decide how to handle the wildcard's return value since it may disagree
		// with the other wildcard handler's return value or your own.
		[CLink]
		private static extern bool cpArbiterCallWildcardPreSolveA(void* arb, void* space);
		/// If you want a custom callback to invoke the wildcard callback for the second collision type, you must call
		// this function explicitly. You must decide how to handle the wildcard's return value since it may disagree
		// with the other wildcard handler's return value or your own.
		[CLink]
		private static extern bool cpArbiterCallWildcardPreSolveB(void* arb, void* space);

		/// If you want a custom callback to invoke the wildcard callback for the first collision type, you must call
		// this function explicitly.
		[CLink]
		private static extern void cpArbiterCallWildcardPostSolveA(void* arb, void* space);
		/// If you want a custom callback to invoke the wildcard callback for the second collision type, you must call
		// this function explicitly.
		[CLink]
		private static extern void cpArbiterCallWildcardPostSolveB(void* arb, void* space);

		/// If you want a custom callback to invoke the wildcard callback for the first collision type, you must call
		// this function explicitly.
		[CLink]
		private static extern void cpArbiterCallWildcardSeparateA(void* arb, void* space);
		/// If you want a custom callback to invoke the wildcard callback for the second collision type, you must call
		// this function explicitly.
		[CLink]
		private static extern void cpArbiterCallWildcardSeparateB(void* arb, void* space);
	}
}
