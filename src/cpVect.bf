using System;

namespace Chipmunk2D
{
	[CRepr]
	struct cpVect
	{
		public float x , y;

		public static cpVect Zero = cpVect(0f, 0f);
		public static cpVect One = cpVect(1f, 1f);
		public static cpVect UnitX = cpVect(1f, 0f);
		public static cpVect UnitY = cpVect(0f, 1f);
		public static cpVect Up = cpVect(0f, 1f);
		public static cpVect Down = cpVect(0f, -1f);
		public static cpVect Right = cpVect(1f, 0f);
		public static cpVect Left = cpVect(-1f, 0f);

		public float Length
		{
			get
			{
				return (float)Math.Sqrt(x * x + y * y);
			}
		}

		public float LengthSquared
		{
			get
			{
				return x * x + y * y;
			}
		}

		public float Angle
		{
			get
			{
				return Math.Atan2(y, x);
			}
		}

		public this(float _x = 0.0f, float _y = 0.0f)
		{
			x = _x;
			y = _y;
		}

		public override void ToString(String strBuffer)
		{
			strBuffer.AppendF("({0}, {1})", x, y);
		}

		public static void DistanceSquared(cpVect value1, cpVect value2, out float result)
		{
			result = (value1.x - value2.x) * (value1.x - value2.x) +
				(value1.y - value2.y) * (value1.y - value2.y);
		}

		public static float Distance(cpVect vector1, cpVect cpVect)
		{
			float result;
			DistanceSquared(vector1, cpVect, out result);
			return (float)Math.Sqrt(result);
		}

		public static cpVect Add(cpVect vec1, cpVect vec2)
		{
			return cpVect(vec1.x + vec2.x, vec1.y + vec2.y);
		}

		public static cpVect Subtract(cpVect vec1, cpVect vec2)
		{
			return cpVect(vec1.x - vec2.x, vec1.y - vec2.y);
		}

		public static float Dot(cpVect vec1, cpVect vec2)
		{
			return vec1.x * vec2.x + vec1.y * vec2.y;
		}

		public static cpVect FromAngle(float angle, float length = 1.0f)
		{
			return cpVect((float)Math.Cos(angle) * length, (float)Math.Sin(angle) * length);
		}

		public static cpVect Lerp(cpVect vec1, cpVect vec2, float b)
		{
			return vec1 + (vec2 - vec1) * b;
		}

		/// Uses complex number multiplication to rotate v1 by v2. Scaling will occur if v1 is not a unit vector.
		public static cpVect Rotate(cpVect v1, cpVect v2)
		{
			return cpVect(v1.x*v2.x - v1.y*v2.y, v1.x*v2.y + v1.y*v2.x);
		}

		/// Inverse of cpvrotate().
		public static cpVect Unrotate(cpVect v1, cpVect v2)
		{
			return cpVect(v1.x*v2.x + v1.y*v2.y, v1.y*v2.x - v1.x*v2.y);
		}

		public static cpVect operator+(cpVect vec1, cpVect vec2)
		{
			return cpVect(vec1.x + vec2.x, vec1.y + vec2.y);
		}

		public static cpVect operator-(cpVect vec1, cpVect vec2)
		{
			return cpVect(vec1.x - vec2.x, vec1.y - vec2.y);
		}

		public static cpVect operator*(cpVect vec1, float factor)
		{
			return cpVect(vec1.x * factor, vec1.y * factor);
		}

		public static cpVect operator/(cpVect vec1, float factor)
		{
			return cpVect(vec1.x / factor, vec1.y / factor);
		}

		public static cpVect operator*(cpTransform t1, cpVect t2)
		{
			return t1.TransformPoint(t2);
		}

		public static cpVect operator*(cpMat2x2 t1, cpVect t2)
		{
			return t1.TransformVector(t2);
		}


	}
}
