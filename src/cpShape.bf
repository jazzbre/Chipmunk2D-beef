using System;
using System.Collections;

namespace Chipmunk2D
{
	/// Fast collision filtering type that is used to determine if two objects collide before calling collision or query
	// callbacks.
	[CRepr]
	struct cpShapeFilter
	{
		/// Two objects with the same non-zero group value do not collide.
		/// This is generally used to group objects in a composite object together to disable self collisions.
		public uint group = 0;
		/// A bitmask of user definable categories that this object belongs to.
		/// The category/mask combinations of both objects in a collision must agree for a collision to occur.
		public uint32 categories = 0xffffffff;
		/// A bitmask of user definable category types that this object object collides with.
		/// The category/mask combinations of both objects in a collision must agree for a collision to occur.
		public uint32 mask = 0xffffffff;
	}

	abstract class cpShape : cpObject
	{
		public float Mass
		{
			get
			{
				return cpShapeGetMass(handle);
			}
			set
			{
				cpShapeSetMass(handle, value);
			}
		}

		public float Density
		{
			get
			{
				return cpShapeGetDensity(handle);
			}
			set
			{
				cpShapeSetDensity(handle, value);
			}
		}

		public float Moment => cpShapeGetMoment(handle);

		public float Area => cpShapeGetArea(handle);

		public cpBB Bounds => cpShapeGetBB(handle);

		public bool Sensor
		{
			get
			{
				return cpShapeGetSensor(handle);
			}
			set
			{
				cpShapeSetSensor(handle, value);
			}
		}

		public float Elasticity
		{
			get
			{
				return cpShapeGetElasticity(handle);
			}
			set
			{
				cpShapeSetElasticity(handle, value);
			}
		}

		public float Friction
		{
			get
			{
				return cpShapeGetFriction(handle);
			}
			set
			{
				cpShapeSetFriction(handle, value);
			}
		}

		public cpVect SurfaceVelocity
		{
			get
			{
				return cpShapeGetSurfaceVelocity(handle);
			}
			set
			{
				cpShapeSetSurfaceVelocity(handle, value);
			}
		}

		public cpShapeFilter Filter
		{
			get
			{
				return cpShapeGetFilter(handle);
			}
			set
			{
				cpShapeSetFilter(handle, value);
			}
		}

		public uint CollisionType
		{
			get
			{
				return cpShapeGetCollisionType(handle);
			}
			set
			{
				cpShapeSetCollisionType(handle, value);
			}
		}

		public this(void* _handle)
		{
			handle = _handle;
			cpShapeSetUserData(handle, Internal.UnsafeCastToPtr(this));
		}

		public ~this()
		{
			cpShapeFree(handle);
			handle = null;
		}

		cpBB GetCacheBB()
		{
			return cpShapeCacheBB(handle);
		}

		cpBB GetUpdateBB(cpTransform transform)
		{
			return cpShapeUpdate(handle, transform);
		}

		float PointQuery(cpVect p, out cpPointQueryInfo info)
		{
			var internalInfo = cpSpace.cpPointQueryInfoInternal();
			var value = cpShapePointQuery(handle, p, &internalInfo);
			info.shape = null;
			info.point = internalInfo.point;
			info.distance = internalInfo.distance;
			info.gradient = internalInfo.gradient;
			return value;
		}

		bool SegmentQuery(cpVect a, cpVect b, float radius, out cpSegmentQueryInfo info)
		{
			var internalInfo = cpSpace.cpSegmentQueryInfoInternal();
			var value = cpShapeSegmentQuery(handle, a, b, radius, &internalInfo);
			info.shape = null;
			info.point = internalInfo.point;
			info.normal = internalInfo.normal;
			info.alpha = internalInfo.alpha;
			return value;
		}

		public static float MomentForCircle(float m, float r1, float r2, cpVect offset)
		{
			return cpMomentForCircle(m, r1, r2, offset);
		}

		public static float AreaForCircle(float r1, float r2)
		{
			return cpAreaForCircle(r1, r2);
		}

		public static float MomentForSegment(float m, cpVect a, cpVect b, float radius)
		{
			return MomentForSegment(m, a, b, radius);
		}

		public static float AreaForSegment(cpVect a, cpVect b, float radius)
		{
			return cpAreaForSegment(a, b, radius);
		}

		public static float MomentForPoly(float m, cpVect[] verts, cpVect offset, float radius)
		{
			return cpMomentForPoly(m, (int32)verts.Count, &verts[0], offset, radius);
		}

		public static float AreaForPoly(cpVect[] verts, float radius)
		{
			return cpAreaForPoly((int32)verts.Count, &verts[0], radius);
		}

		public static cpVect CentroidForPoly(cpVect[] verts)
		{
			return cpCentroidForPoly((int32)verts.Count, &verts[0]);
		}

		public static float MomentForBox(float m, float width, float height)
		{
			return cpMomentForBox(m, width, height);
		}

		[CLink]
		private static extern void cpShapeFree(void* shape);

		/// Get the mass of the shape if you are having Chipmunk calculate mass properties for you.
		[CLink]
		private static extern float cpShapeGetMass(void* shape);
		/// Set the mass of this shape to have Chipmunk calculate mass properties for you.
		[CLink]
		private static extern void cpShapeSetMass(void* shape, float mass);

		/// Get the density of the shape if you are having Chipmunk calculate mass properties for you.
		[CLink]
		private static extern float cpShapeGetDensity(void* shape);
		/// Set the density  of this shape to have Chipmunk calculate mass properties for you.
		[CLink]
		private static extern void cpShapeSetDensity(void* shape, float density);

		/// Get the calculated moment of inertia for this shape.
		[CLink]
		private static extern float cpShapeGetMoment(void* shape);
		/// Get the calculated area of this shape.
		[CLink]
		private static extern float cpShapeGetArea(void* shape);
		/// Get the centroid of this shape.
		[CLink]
		private static extern cpVect cpShapeGetCenterOfGravity(void* shape);

		/// Get the bounding box that contains the shape given it's current position and angle.
		[CLink]
		private static extern cpBB cpShapeGetBB(void* shape);

		/// Get if the shape is set to be a sensor or not.
		[CLink]
		private static extern bool cpShapeGetSensor(void* shape);
		/// Set if the shape is a sensor or not.
		[CLink]
		private static extern void cpShapeSetSensor(void* shape, bool sensor);

		/// Get the elasticity of this shape.
		[CLink]
		private static extern float cpShapeGetElasticity(void* shape);
		/// Set the elasticity of this shape.
		[CLink]
		private static extern void cpShapeSetElasticity(void* shape, float elasticity);

		/// Get the friction of this shape.
		[CLink]
		private static extern float cpShapeGetFriction(void* shape);
		/// Set the friction of this shape.
		[CLink]
		private static extern void cpShapeSetFriction(void* shape, float friction);

		/// Get the surface velocity of this shape.
		[CLink]
		private static extern cpVect cpShapeGetSurfaceVelocity(void* shape);
		/// Set the surface velocity of this shape.
		[CLink]
		private static extern void cpShapeSetSurfaceVelocity(void* shape, cpVect surfaceVelocity);

		/// Get the user definable data pointer of this shape.
		[CLink]
		private static extern void* cpShapeGetUserData(void* shape);
		/// Set the user definable data pointer of this shape.
		[CLink]
		private static extern void cpShapeSetUserData(void* shape, void* userData);

		/// Set the collision type of this shape.
		[CLink]
		private static extern uint cpShapeGetCollisionType(void* shape);
		/// Get the collision type of this shape.
		[CLink]
		private static extern void cpShapeSetCollisionType(void* shape, uint collisionType);

		/// Get the collision filtering parameters of this shape.
		[CLink]
		private static extern cpShapeFilter cpShapeGetFilter(void* shape);
		/// Set the collision filtering parameters of this shape.
		[CLink] private static extern void cpShapeSetFilter(void* shape, cpShapeFilter filter);

		/// Update, cache and return the bounding box of a shape based on the body it's attached to.
		[CLink] private static extern cpBB cpShapeCacheBB(void* shape);
		/// Update, cache and return the bounding box of a shape with an explicit transformation.
		[CLink] private static extern cpBB cpShapeUpdate(void* shape, cpTransform transform);

		/// Perform a nearest point query. It finds the closest point on the surface of shape to a specific point.
		/// The value returned is the distance between the points. A negative distance means the point is inside the
		// shape.
		[CLink] private static extern float cpShapePointQuery(void* shape, cpVect p, cpSpace.cpPointQueryInfoInternal* outValue);

		/// Perform a segment query against a shape. @c info must be a pointer to a valid cpSegmentQueryInfo structure.
		[CLink] private static extern bool cpShapeSegmentQuery(void* shape, cpVect a, cpVect b, float radius, cpSpace.cpSegmentQueryInfoInternal* info);

		/// Return contact information about two shapes.
		[CLink] private static extern cpContactPointSet cpShapesCollide(void* a, void* b);

		/// Calculate the moment of inertia for a circle.
		/// @c r1 and @c r2 are the inner and outer diameters. A solid circle has an inner diameter of 0.
		[CLink] private static extern float cpMomentForCircle(float m, float r1, float r2, cpVect offset);

		/// Calculate area of a hollow circle.
		/// @c r1 and @c r2 are the inner and outer diameters. A solid circle has an inner diameter of 0.
		[CLink] private static extern float cpAreaForCircle(float r1, float r2);


		/// Calculate the moment of inertia for a line segment.
		/// Beveling radius is not supported.
		[CLink] private static extern float cpMomentForSegment(float m, cpVect a, cpVect b, float radius);

		/// Calculate the area of a fattened (capsule shaped) line segment.
		[CLink] private static extern float cpAreaForSegment(cpVect a, cpVect b, float radius);

		/// Calculate the moment of inertia for a solid polygon shape assuming it's center of gravity is at it's
		// centroid. The offset is added to each vertex.
		[CLink] private static extern float cpMomentForPoly(float m, int32 count, cpVect* verts, cpVect offset, float radius);

		/// Calculate the signed area of a polygon. A Clockwise winding gives positive area.
		/// This is probably backwards from what you expect, but matches Chipmunk's the winding for poly shapes.
		[CLink] private static extern float cpAreaForPoly(int32 count, cpVect* verts, float radius);

		/// Calculate the natural centroid of a polygon.
		[CLink] private static extern cpVect cpCentroidForPoly(int32 count, cpVect* verts);

		/// Calculate the moment of inertia for a solid box.
		[CLink] private static extern float cpMomentForBox(float m, float width, float height);
	}

	class cpPolyShape : cpShape
	{
		public int Count => (int)cpPolyShapeGetCount(handle);

		public float Radius => cpPolyShapeGetRadius(handle);

		public this(void* _handle) : base(_handle)
		{
		}

		public cpVect this[int index]
		{
			get
			{
				return cpPolyShapeGetVert(handle, (int32)index);
			}
		}

		/// Get the number of verts in a polygon shape.
		[CLink] private static extern int32 cpPolyShapeGetCount(void* shape);
		/// Get the @c ith vertex of a polygon shape.
		[CLink] private static extern cpVect cpPolyShapeGetVert(void* shape, int32 index);
		/// Get the radius of a polygon shape.
		[CLink] private static extern float cpPolyShapeGetRadius(void* shape);

	}

	class cpBoxShape : cpPolyShape
	{
		public this(void* _handle) : base(_handle)
		{
		}

	}
	class cpCircleShape : cpShape
	{
		public cpVect Offset => cpCircleShapeGetOffset(handle);

		public float Radius => cpCircleShapeGetRadius(handle);

		public this(void* _handle) : base(_handle)
		{
		}

		/// Get the offset of a circle shape.
		[CLink] private static extern cpVect cpCircleShapeGetOffset(void* shape);
		/// Get the radius of a circle shape.
		[CLink] private static extern float cpCircleShapeGetRadius(void* shape);
	}

	class cpSegmentShape : cpShape
	{
		public cpVect EndPointA => cpSegmentShapeGetA(handle);

		public cpVect EndPointB => cpSegmentShapeGetB(handle);

		public cpVect Normal => cpSegmentShapeGetNormal(handle);

		public float Radius => cpSegmentShapeGetRadius(handle);

		public this(void* _handle) : base(_handle)
		{
		}

		public void SetNeighbors(cpVect prev, cpVect next)
		{
			cpSegmentShapeSetNeighbors(handle, prev, next);
		}

		/// Let Chipmunk know about the geometry of adjacent segments to avoid colliding with endcaps.
		[CLink] private static extern void cpSegmentShapeSetNeighbors(void* shape, cpVect prev, cpVect next);

		/// Get the first endpoint of a segment shape.
		[CLink] private static extern cpVect cpSegmentShapeGetA(void* shape);
		/// Get the second endpoint of a segment shape.
		[CLink] private static extern cpVect cpSegmentShapeGetB(void* shape);
		/// Get the normal of a segment shape.
		[CLink] private static extern cpVect cpSegmentShapeGetNormal(void* shape);
		/// Get the first endpoint of a segment shape.
		[CLink] private static extern float cpSegmentShapeGetRadius(void* shape);
	}
}
