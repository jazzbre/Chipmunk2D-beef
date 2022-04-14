using System;

namespace Chipmunk2D
{
	class ObjectBase
	{
		protected void* handle = null;

		public void* Handle => handle;

		public bool IsValid => handle != null;
	}
}
