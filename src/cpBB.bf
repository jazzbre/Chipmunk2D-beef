using System;

namespace Chipmunk2D
{
	[CRepr]
	struct cpBB
	{
		float l , b , r , t;

		public cpVect Center => cpVect.Lerp(cpVect(l, b), cpVect(r, t), 0.5f);

		/// Returns the area of the bounding box.
		public float Area => (r - l) * (t - b);

		/// Merges @c a and @c b and returns the area of the merged bounding box.
		public this
		{
		}

		public this(float _l, float _b, float _r, float _t)
		{
			l = _l;
			b = _b;
			r = _r;
			t = _t;
		}

		public this(cpVect c, float hw, float hh)
		{
			l = c.x - hw;
			b = c.y - hh;
			r = c.x + hw;
			t = c.y + hh;
		}


		public this(cpVect c, float radius)
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

		public static float MergedArea(cpBB a, cpBB b)
		{
			return (Math.Max(a.r, b.r) - Math.Min(a.l, b.l)) * (Math.Max(a.t, b.t) - Math.Min(a.b, b.b));
		}

		/// Transform a cpBB.
		public static cpBB operator*(cpTransform t, cpBB bb)
		{
			var center = bb.Center;
			var hw = (bb.r - bb.l) * 0.5f;
			var hh = (bb.t - bb.b) * 0.5f;

			var a = t.a * hw, b = t.c * hh, d = t.b * hw, e = t.d * hh;
			var hw_max = Math.Max(Math.Abs(a + b), Math.Abs(a - b));
			var hh_max = Math.Max(Math.Abs(d + e), Math.Abs(d - e));
			return cpBB(t * center, hw_max, hh_max);
		}

	}
}
