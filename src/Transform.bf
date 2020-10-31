using System;

namespace Chipmunk2D
{
	[CRepr]
	struct Transform
	{
		public Real a , b , c , d , tx , ty;

		public this(Real _a = 1.0f, Real _b = 0.0f, Real _c = 0.0f, Real _d = 1.0f, Real _tx = 0.0f, Real _ty = 0.0f)
		{
			a = _a;
			b = _b;
			c = _c;
			d = _d;
			tx = _tx;
			ty = _ty;
		}

		public override void ToString(String strBuffer)
		{
			strBuffer.AppendF("[({0}, {1}), ({2}, {3}), ({4}, {5})]", a, b, c, d, tx, ty);
		}

		public Transform Transpose()
		{
			return Transform(a, c, tx, b, d, ty);
		}

		public Transform Inverse()
		{
			Real inv_det = 1.0f / (a * d - c * b);
			return Transform(
				d * inv_det, -c * inv_det, (c * ty - tx * d) * inv_det,
				-b * inv_det, a * inv_det, (tx * b - a * ty) * inv_det).Transpose();
		}

		/// Transform an absolute point (i.e. a vertex)
		public Vector2 TransformPoint(Vector2 p)
		{
			return Vector2(a * p.x + c * p.y + tx, b * p.x + d * p.y + ty);
		}

		/// Transform a vector (i.e. a normal)
		Vector2 cpTransformVect(Vector2 v)
		{
			return Vector2(a * v.x + c * v.y, b * v.x + d * v.y);
		}

		public static Transform operator*(Transform t1, Transform t2)
		{
			return Transform(
				t1.a * t2.a + t1.c * t2.b, t1.a * t2.c + t1.c * t2.d, t1.a * t2.tx + t1.c * t2.ty + t1.tx,
				t1.b * t2.a + t1.d * t2.b, t1.b * t2.c + t1.d * t2.d, t1.b * t2.tx + t1.d * t2.ty + t1.ty).Transpose();
		}

	}
}
