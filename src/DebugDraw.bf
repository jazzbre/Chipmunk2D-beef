using System;

namespace Chipmunk2D
{
	[CRepr]
	struct DebugColor
	{
		public float r, g, b, a;

		public this(float _r = 0.0f, float _g = 0.0f, float _b = 0.0f, float _a = 0.0f)
		{
			r = _r;
			g = _g;
			b = _b;
			a = _a;
		}

		public uint32 ToRGBA()
		{
			return ((uint32)(a * 255) << 24) | ((uint32)(b * 255) << 16) | ((uint32)(g * 255) << 8) | ((uint32)(r * 255));
		}
	}

	enum DebugDrawFlags : int32
	{
		Shapes = 1 << 0,
		Constraints = 1 << 1,
		DrawCollisionPoints = 1 << 2,
	}

	/// Struct used with cpSpaceDebugDraw() containing drawing callbacks and other drawing settings.
	[CRepr]
	struct DebugDrawOptions
	{
		/// Callback type for a function that draws a filled, stroked circle.
		typealias DrawCircleCallback = function void(Vector2 pos, Real angle, Real radius, DebugColor outlineColor, DebugColor fillColor, void* data);
		/// Callback type for a function that draws a line segment.
		typealias DrawSegmentCallback = function void(Vector2 a, Vector2 b, DebugColor color, void* data);
		/// Callback type for a function that draws a thick line segment.
		typealias DrawFatSegmentCallback = function void(Vector2 a, Vector2 b, Real radius, DebugColor outlineColor, DebugColor fillColor, void* data);
		/// Callback type for a function that draws a convex polygon.
		typealias DrawPolygonCallback = function void(int32 count, Vector2* verts, Real radius, DebugColor outlineColor, DebugColor fillColor, void* data);
		/// Callback type for a function that draws a dot.
		typealias DebugDrawDotCallback = function void(Real size, Vector2 pos, DebugColor color, void* data);
		/// Callback type for a function that returns a color for a given shape. This gives you an opportunity to color
		// shapes based on how they are used in your engine.
		typealias DrawColorForShapeCallback = function DebugColor(void* shape, void* data);

		/// Function that will be invoked to draw circles.
		public DrawCircleCallback drawCircle;
		/// Function that will be invoked to draw line segments.
		public DrawSegmentCallback drawSegment;
		/// Function that will be invoked to draw thick line segments.
		public DrawFatSegmentCallback drawFatSegment;
		/// Function that will be invoked to draw convex polygons.
		public DrawPolygonCallback drawPolygon;
		/// Function that will be invoked to draw dots.
		public DebugDrawDotCallback drawDot;

		/// Flags that request which things to draw (collision shapes, constraints, contact points).
		public DebugDrawFlags flags;
		/// Outline color passed to the drawing function.
		public DebugColor shapeOutlineColor;
		/// Function that decides what fill color to draw shapes using.
		public DrawColorForShapeCallback colorForShape;
		/// Color passed to drawing functions for constraints.
		public DebugColor constraintColor;
		/// Color passed to drawing functions for collision points.
		public DebugColor collisionPointColor;

		/// User defined context pointer passed to all of the callback functions as the 'data' argument.
		public void* data;
	}
}
