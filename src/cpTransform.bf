using System;

namespace Chipmunk2D
{
	[CRepr]
	struct cpTransform
	{
		public float a , b , c , d , tx , ty;

		public this(float _a = 1.0f, float _b = 0.0f, float _c = 0.0f, float _d = 1.0f, float _tx = 0.0f, float _ty = 0.0f)
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

		public cpTransform Transpose()
		{
			return cpTransform(a, c, tx, b, d, ty);
		}

		public cpTransform Inverse()
		{
			float inv_det = 1.0f / (a * d - c * b);
			return cpTransform(
				d * inv_det, -c * inv_det, (c * ty - tx * d) * inv_det,
				-b * inv_det, a * inv_det, (tx * b - a * ty) * inv_det).Transpose();
		}

		/// Transform an absolute point (i.e. a vertex)
		public cpVect TransformPoint(cpVect p)
		{
			return cpVect(a * p.x + c * p.y + tx, b * p.x + d * p.y + ty);
		}

		/// Transform a vector (i.e. a normal)
		cpVect cpTransformVect(cpVect v)
		{
			return cpVect(a * v.x + c * v.y, b * v.x + d * v.y);
		}

		public static cpTransform operator*(cpTransform t1, cpTransform t2)
		{
			return cpTransform(
				t1.a * t2.a + t1.c * t2.b, t1.a * t2.c + t1.c * t2.d, t1.a * t2.tx + t1.c * t2.ty + t1.tx,
				t1.b * t2.a + t1.d * t2.b, t1.b * t2.c + t1.d * t2.d, t1.b * t2.tx + t1.d * t2.ty + t1.ty).Transpose();
		}

	}
}
