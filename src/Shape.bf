using System;
using System.Collections;

namespace Chipmunk2D
{
	/// Fast collision filtering type that is used to determine if two objects collide before calling collision or query
	// callbacks.
	[CRepr]
	struct ShapeFilter
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

	abstract class Shape : ObjectBase
	{
		public Object UserObject { get; set; }

		public Real Mass
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

		public Real Density
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

		public Real Moment => cpShapeGetMoment(handle);

		public Real Area => cpShapeGetArea(handle);

		public Bounds Bounds => cpShapeGetBB(handle);

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

		public Real Elasticity
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

		public Real Friction
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

		public Vector2 SurfaceVelocity
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

		public ShapeFilter Filter
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
			cpSpaceRemoveShape(cpShapeGetSpace(handle), handle);
			cpShapeFree(handle);
			handle = null;
		}

		Bounds GetCacheBB()
		{
			return cpShapeCacheBB(handle);
		}

		Bounds GetUpdateBB(Transform transform)
		{
			return cpShapeUpdate(handle, transform);
		}

		Real PointQuery(Vector2 p, out PointQueryInfo info)
		{
			var internalInfo = Space.cpPointQueryInfo();
			var value = cpShapePointQuery(handle, p, &internalInfo);
			info.shape = null;
			info.point = internalInfo.point;
			info.distance = internalInfo.distance;
			info.gradient = internalInfo.gradient;
			return value;
		}

		bool SegmentQuery(Vector2 a, Vector2 b, Real radius, out SegmentQueryInfo info)
		{
			var internalInfo = Space.cpSegmentQueryInfo();
			var value = cpShapeSegmentQuery(handle, a, b, radius, &internalInfo);
			info.shape = null;
			info.point = internalInfo.point;
			info.normal = internalInfo.normal;
			info.alpha = internalInfo.alpha;
			return value;
		}

		public static Real MomentForCircle(Real m, Real r1, Real r2, Vector2 offset)
		{
			return cpMomentForCircle(m, r1, r2, offset);
		}

		public static Real AreaForCircle(Real r1, Real r2)
		{
			return cpAreaForCircle(r1, r2);
		}

		public static Real MomentForSegment(Real m, Vector2 a, Vector2 b, Real radius)
		{
			return MomentForSegment(m, a, b, radius);
		}

		public static Real AreaForSegment(Vector2 a, Vector2 b, Real radius)
		{
			return cpAreaForSegment(a, b, radius);
		}

		public static Real MomentForPoly(Real m, Vector2[] verts, Vector2 offset, Real radius)
		{
			return cpMomentForPoly(m, (int32)verts.Count, &verts[0], offset, radius);
		}

		public static Real AreaForPoly(Vector2[] verts, Real radius)
		{
			return cpAreaForPoly((int32)verts.Count, &verts[0], radius);
		}

		public static Vector2 CentroidForPoly(Vector2[] verts)
		{
			return cpCentroidForPoly((int32)verts.Count, &verts[0]);
		}

		public static Real MomentForBox(Real m, Real width, Real height)
		{
			return cpMomentForBox(m, width, height);
		}

		/// Remove a collision shape from the simulation.
		[CLink] private static extern void cpSpaceRemoveShape(void* space, void* shape);

		[CLink]
		private static extern void cpShapeFree(void* shape);

		/// Get the mass of the shape if you are having Chipmunk calculate mass properties for you.
		[CLink]
		private static extern Real cpShapeGetMass(void* shape);
		/// Set the mass of this shape to have Chipmunk calculate mass properties for you.
		[CLink]
		private static extern void cpShapeSetMass(void* shape, Real mass);

		/// Get the density of the shape if you are having Chipmunk calculate mass properties for you.
		[CLink]
		private static extern Real cpShapeGetDensity(void* shape);
		/// Set the density  of this shape to have Chipmunk calculate mass properties for you.
		[CLink]
		private static extern void cpShapeSetDensity(void* shape, Real density);

		/// Get the calculated moment of inertia for this shape.
		[CLink]
		private static extern Real cpShapeGetMoment(void* shape);
		/// Get the calculated area of this shape.
		[CLink]
		private static extern Real cpShapeGetArea(void* shape);
		/// Get the centroid of this shape.
		[CLink]
		private static extern Vector2 cpShapeGetCenterOfGravity(void* shape);

		/// Get the bounding box that contains the shape given it's current position and angle.
		[CLink]
		private static extern Bounds cpShapeGetBB(void* shape);

		/// Get if the shape is set to be a sensor or not.
		[CLink]
		private static extern bool cpShapeGetSensor(void* shape);
		/// Set if the shape is a sensor or not.
		[CLink]
		private static extern void cpShapeSetSensor(void* shape, bool sensor);

		/// Get the elasticity of this shape.
		[CLink]
		private static extern Real cpShapeGetElasticity(void* shape);
		/// Set the elasticity of this shape.
		[CLink]
		private static extern void cpShapeSetElasticity(void* shape, Real elasticity);

		/// Get the friction of this shape.
		[CLink]
		private static extern Real cpShapeGetFriction(void* shape);
		/// Set the friction of this shape.
		[CLink]
		private static extern void cpShapeSetFriction(void* shape, Real friction);

		/// Get the surface velocity of this shape.
		[CLink]
		private static extern Vector2 cpShapeGetSurfaceVelocity(void* shape);
		/// Set the surface velocity of this shape.
		[CLink]
		private static extern void cpShapeSetSurfaceVelocity(void* shape, Vector2 surfaceVelocity);

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
		private static extern ShapeFilter cpShapeGetFilter(void* shape);
		/// Set the collision filtering parameters of this shape.
		[CLink] private static extern void cpShapeSetFilter(void* shape, ShapeFilter filter);

		/// Update, cache and return the bounding box of a shape based on the body it's attached to.
		[CLink] private static extern Bounds cpShapeCacheBB(void* shape);
		/// Update, cache and return the bounding box of a shape with an explicit transformation.
		[CLink] private static extern Bounds cpShapeUpdate(void* shape, Transform transform);

		/// Perform a nearest point query. It finds the closest point on the surface of shape to a specific point.
		/// The value returned is the distance between the points. A negative distance means the point is inside the
		// shape.
		[CLink] private static extern Real cpShapePointQuery(void* shape, Vector2 p, Space.cpPointQueryInfo* outValue);

		/// Perform a segment query against a shape. @c info must be a pointer to a valid cpSegmentQueryInfo structure.
		[CLink] private static extern bool cpShapeSegmentQuery(void* shape, Vector2 a, Vector2 b, Real radius, Space.cpSegmentQueryInfo* info);

		/// Return contact information about two shapes.
		[CLink] private static extern ContactPointSet cpShapesCollide(void* a, void* b);

		/// The cpSpace this body is added to.
		[CLink] private static extern void* cpShapeGetSpace(void* shape);

		/// Calculate the moment of inertia for a circle.
		/// @c r1 and @c r2 are the inner and outer diameters. A solid circle has an inner diameter of 0.
		[CLink] private static extern Real cpMomentForCircle(Real m, Real r1, Real r2, Vector2 offset);

		/// Calculate area of a hollow circle.
		/// @c r1 and @c r2 are the inner and outer diameters. A solid circle has an inner diameter of 0.
		[CLink] private static extern Real cpAreaForCircle(Real r1, Real r2);


		/// Calculate the moment of inertia for a line segment.
		/// Beveling radius is not supported.
		[CLink] private static extern Real cpMomentForSegment(Real m, Vector2 a, Vector2 b, Real radius);

		/// Calculate the area of a fattened (capsule shaped) line segment.
		[CLink] private static extern Real cpAreaForSegment(Vector2 a, Vector2 b, Real radius);

		/// Calculate the moment of inertia for a solid polygon shape assuming it's center of gravity is at it's
		// centroid. The offset is added to each vertex.
		[CLink] private static extern Real cpMomentForPoly(Real m, int32 count, Vector2* verts, Vector2 offset, Real radius);

		/// Calculate the signed area of a polygon. A Clockwise winding gives positive area.
		/// This is probably backwards from what you expect, but matches Chipmunk's the winding for poly shapes.
		[CLink] private static extern Real cpAreaForPoly(int32 count, Vector2* verts, Real radius);

		/// Calculate the natural centroid of a polygon.
		[CLink] private static extern Vector2 cpCentroidForPoly(int32 count, Vector2* verts);

		/// Calculate the moment of inertia for a solid box.
		[CLink] private static extern Real cpMomentForBox(Real m, Real width, Real height);
	}

	class PolyShape : Shape
	{
		public int Count => (int)cpPolyShapeGetCount(handle);

		public Real Radius => cpPolyShapeGetRadius(handle);

		public this(void* _handle) : base(_handle)
		{
		}

		public Vector2 this[int index]
		{
			get
			{
				return cpPolyShapeGetVert(handle, (int32)index);
			}
		}

		/// Get the number of verts in a polygon shape.
		[CLink] private static extern int32 cpPolyShapeGetCount(void* shape);
		/// Get the @c ith vertex of a polygon shape.
		[CLink] private static extern Vector2 cpPolyShapeGetVert(void* shape, int32 index);
		/// Get the radius of a polygon shape.
		[CLink] private static extern Real cpPolyShapeGetRadius(void* shape);

	}

	class BoxShape : PolyShape
	{
		public this(void* _handle) : base(_handle)
		{
		}

	}
	class CircleShape : Shape
	{
		public Vector2 Offset => cpCircleShapeGetOffset(handle);

		public Real Radius => cpCircleShapeGetRadius(handle);

		public this(void* _handle) : base(_handle)
		{
		}

		/// Get the offset of a circle shape.
		[CLink] private static extern Vector2 cpCircleShapeGetOffset(void* shape);
		/// Get the radius of a circle shape.
		[CLink] private static extern Real cpCircleShapeGetRadius(void* shape);
	}

	class SegmentShape : Shape
	{
		public Vector2 EndPointA => cpSegmentShapeGetA(handle);

		public Vector2 EndPointB => cpSegmentShapeGetB(handle);

		public Vector2 Normal => cpSegmentShapeGetNormal(handle);

		public Real Radius => cpSegmentShapeGetRadius(handle);

		public this(void* _handle) : base(_handle)
		{
		}

		public void SetNeighbors(Vector2 prev, Vector2 next)
		{
			cpSegmentShapeSetNeighbors(handle, prev, next);
		}

		/// Let Chipmunk know about the geometry of adjacent segments to avoid colliding with endcaps.
		[CLink] private static extern void cpSegmentShapeSetNeighbors(void* shape, Vector2 prev, Vector2 next);

		/// Get the first endpoint of a segment shape.
		[CLink] private static extern Vector2 cpSegmentShapeGetA(void* shape);
		/// Get the second endpoint of a segment shape.
		[CLink] private static extern Vector2 cpSegmentShapeGetB(void* shape);
		/// Get the normal of a segment shape.
		[CLink] private static extern Vector2 cpSegmentShapeGetNormal(void* shape);
		/// Get the first endpoint of a segment shape.
		[CLink] private static extern Real cpSegmentShapeGetRadius(void* shape);
	}
}
