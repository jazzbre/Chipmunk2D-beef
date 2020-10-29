using System;

namespace Chipmunk2D
{
	[CRepr]
	struct Vector2
	{
		public float x , y;

		public static Vector2 Zero = Vector2(0f, 0f);
		public static Vector2 One = Vector2(1f, 1f);
		public static Vector2 UnitX = Vector2(1f, 0f);
		public static Vector2 UnitY = Vector2(0f, 1f);
		public static Vector2 Up = Vector2(0f, 1f);
		public static Vector2 Down = Vector2(0f, -1f);
		public static Vector2 Right = Vector2(1f, 0f);
		public static Vector2 Left = Vector2(-1f, 0f);

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

		public static void DistanceSquared(Vector2 value1, Vector2 value2, out float result)
		{
			result = (value1.x - value2.x) * (value1.x - value2.x) +
				(value1.y - value2.y) * (value1.y - value2.y);
		}

		public static float Distance(Vector2 vector1, Vector2 Vector2)
		{
			float result;
			DistanceSquared(vector1, Vector2, out result);
			return (float)Math.Sqrt(result);
		}

		public static Vector2 Add(Vector2 vec1, Vector2 vec2)
		{
			return Vector2(vec1.x + vec2.x, vec1.y + vec2.y);
		}

		public static Vector2 Subtract(Vector2 vec1, Vector2 vec2)
		{
			return Vector2(vec1.x - vec2.x, vec1.y - vec2.y);
		}

		public static float Dot(Vector2 vec1, Vector2 vec2)
		{
			return vec1.x * vec2.x + vec1.y * vec2.y;
		}

		public static Vector2 FromAngle(float angle, float length = 1.0f)
		{
			return Vector2((float)Math.Cos(angle) * length, (float)Math.Sin(angle) * length);
		}

		public static Vector2 Lerp(Vector2 vec1, Vector2 vec2, float b)
		{
			return vec1 + (vec2 - vec1) * b;
		}

		/// Uses complex number multiplication to rotate v1 by v2. Scaling will occur if v1 is not a unit vector.
		public static Vector2 Rotate(Vector2 v1, Vector2 v2)
		{
			return Vector2(v1.x*v2.x - v1.y*v2.y, v1.x*v2.y + v1.y*v2.x);
		}

		/// Inverse of cpvrotate().
		public static Vector2 Unrotate(Vector2 v1, Vector2 v2)
		{
			return Vector2(v1.x*v2.x + v1.y*v2.y, v1.y*v2.x - v1.x*v2.y);
		}

		public static Vector2 operator+(Vector2 vec1, Vector2 vec2)
		{
			return Vector2(vec1.x + vec2.x, vec1.y + vec2.y);
		}

		public static Vector2 operator-(Vector2 vec1, Vector2 vec2)
		{
			return Vector2(vec1.x - vec2.x, vec1.y - vec2.y);
		}

		public static Vector2 operator*(Vector2 vec1, float factor)
		{
			return Vector2(vec1.x * factor, vec1.y * factor);
		}

		public static Vector2 operator/(Vector2 vec1, float factor)
		{
			return Vector2(vec1.x / factor, vec1.y / factor);
		}

		public static Vector2 operator*(Transform t1, Vector2 t2)
		{
			return t1.TransformPoint(t2);
		}

		public static Vector2 operator*(Matrix2x2 t1, Vector2 t2)
		{
			return t1.TransformVector(t2);
		}


	}
}
