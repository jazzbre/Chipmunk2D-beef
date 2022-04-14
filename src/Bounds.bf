using System;

namespace Chipmunk2D
{
	[CRepr]
	struct Bounds
	{
		public Real l, b, r, t;

		public Vector2 Center => Vector2.Lerp(Vector2(l, b), Vector2(r, t), 0.5f);
		public Vector2 Extents => (Vector2(r, t) - Vector2(l, b)) * 0.5;

		/// Returns the area of the bounding box.
		public Real Area => (r - l) * (t - b);

		/// Merges @c a and @c b and returns the area of the merged bounding box.
		public this(Real _l, Real _b, Real _r, Real _t)
		{
			l = _l;
			b = _b;
			r = _r;
			t = _t;
		}

		public this(Vector2 c, Real hw, Real hh)
		{
			l = c.x - hw;
			b = c.y - hh;
			r = c.x + hw;
			t = c.y + hh;
		}


		public this(Vector2 c, Real radius)
		{
			l = c.x - radius;
			b = c.y - radius;
			r = c.x + radius;
			t = c.y + radius;
		}

		public override void ToString(String strBuffer)
		{
			strBuffer.AppendF("({0}, {1}, {2}, {3})", l, b, r, t);
		}

		public static Real MergedArea(Bounds a, Bounds b)
		{
			return (Math.Max(a.r, b.r) - Math.Min(a.l, b.l)) * (Math.Max(a.t, b.t) - Math.Min(a.b, b.b));
		}

		/// Transform a cpBB.
		public static Bounds operator*(Transform t, Bounds bb)
		{
			var center = bb.Center;
			var hw = (bb.r - bb.l) * 0.5f;
			var hh = (bb.t - bb.b) * 0.5f;

			var a = t.a * hw, b = t.c * hh, d = t.b * hw, e = t.d * hh;
			var hw_max = Math.Max(Math.Abs(a + b), Math.Abs(a - b));
			var hh_max = Math.Max(Math.Abs(d + e), Math.Abs(d - e));
			return Bounds(t * center, hw_max, hh_max);
		}

	}
}
