using System;

namespace Chipmunk2D
{
	[CRepr]
	struct Matrix2x2
	{
		// Row major [[a, b][c d]]
		float a , b , c , d;

		public this(float _a = 1.0f, float _b = 0.0f, float _c = 0.0f, float _d = 1.0f)
		{
			a = _a;
			b = _b;
			c = _c;
			d = _d;
		}

		public override void ToString(String strBuffer)
		{
			strBuffer.AppendF("[({0}, {1}), ({2}, {3})]", a, b, c, d);
		}

		public Vector2 TransformVector(Vector2 v)
		{
			return Vector2(v.x * a + v.y * b, v.x * c + v.y * d);
		}
	}
}
