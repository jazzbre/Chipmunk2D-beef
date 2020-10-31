using System;
using System.Collections;
using Chipmunk2D;

namespace Example
{
	class Program
	{
		static readonly Vector2[] positions = new Vector2[](
			Vector2(-154.275395f, -211.224674f),
			Vector2(-248.323826f, 62.732261f),
			Vector2(-81.664735f, -97.287018f),
			Vector2(283.133498f, -103.619042f),
			Vector2(253.344966f, -76.675636f),
			Vector2(208.617654f, -136.080354f),
			Vector2(-286.712395f, -196.958237f),
			Vector2(-8.235025f, 53.673591f),
			Vector2(176.300747f, -96.123994f),
			Vector2(-30.331598f, -172.987005f),
			Vector2(276.118147f, 59.346567f),
			Vector2(169.552478f, 68.120943f),
			Vector2(-268.159107f, 26.794797f),
			Vector2(-251.831502f, 161.498906f),
			Vector2(283.008860f, -86.044446f),
			Vector2(-281.210508f, -180.107301f),
			Vector2(39.234328f, -200.860831f),
			Vector2(86.418793f, 6.764927f),
			Vector2(-67.064259f, 93.397347f),
			Vector2(-276.278396f, -50.753107f),
			Vector2(-169.249785f, 169.924374f),
			Vector2(26.770507f, 152.995903f),
			Vector2(74.791828f, 196.596407f),
			Vector2(262.229890f, -53.906196f),
			Vector2(12.152225f, -113.789047f),
			Vector2(231.835972f, -113.130000f),
			Vector2(-51.253012f, -53.040389f),
			Vector2(-84.299943f, 103.438127f),
			Vector2(-163.943759f, -52.394264f),
			Vector2(51.288623f, -181.593388f),
			Vector2(-40.017768f, 74.052369f),
			Vector2(-272.094114f, 136.261269f),
			Vector2(-142.078656f, 68.082175f),
			Vector2(204.273122f, 102.779079f),
			Vector2(149.361088f, -139.375591f),
			Vector2(-56.452206f, -29.547289f),
			Vector2(5.688844f, -151.199676f),
			Vector2(-7.861110f, -14.518425f),
			Vector2(195.708697f, -176.217630f),
			Vector2(28.853745f, 161.369681f),
			Vector2(-235.592924f, 3.741063f),
			Vector2(126.783767f, -58.984737f),
			Vector2(-217.182080f, -208.627252f),
			Vector2(223.520823f, -175.481047f),
			Vector2(-107.696316f, -172.651020f),
			Vector2(89.196444f, 53.621901f),
			Vector2(-85.635352f, -4.697328f),
			Vector2(-43.133723f, 124.049509f),
			Vector2(-165.920165f, -203.652091f),
			Vector2(-63.271697f, 144.544590f),
			Vector2(-70.268043f, 93.863586f)
			) ~ delete _;


		static Body AddBox(Space space, Real size, Real mass, int index)
		{
			var radius = Vector2(size, size).Length;
			var body = new Body(.Dynamic, mass, Shape.MomentForBox(mass, size, size));
			space.AddBody(body);
			body.Position = positions[index];
			var shape = body.AddBoxShape(size, size, 0.0f);
			shape.Elasticity = 0.0f;
			shape.Friction = 0.7f;
			return body;
		}


		public static int Tank()
		{
			var space = scope Space();
			space.Iterations = 10;
			space.SleepTimeThreshold = 0.5f;

			var filter = ShapeFilter() { group = 0, categories = 0x7fffffff, mask = 0x7fffffff };

			var staticBody = space.StaticBody;
			var shape = staticBody.AddSegmentShape(Vector2(-320, -240), Vector2(-320, 240), 0.0f);
			shape.Elasticity = 1.0f;
			shape.Friction = 1.0f;
			shape.Filter = filter;

			shape = staticBody.AddSegmentShape(Vector2(320, -240), Vector2(320, 240), 0.0f);
			shape.Elasticity = 1.0f;
			shape.Friction = 1.0f;
			shape.Filter = filter;

			shape = staticBody.AddSegmentShape(Vector2(-320, -240), Vector2(320, -240), 0.0f);
			shape.Elasticity = 1.0f;
			shape.Friction = 1.0f;
			shape.Filter = filter;

			shape = staticBody.AddSegmentShape(Vector2(-320, 240), Vector2(320, 240), 0.0f);
			shape.Elasticity = 1.0f;
			shape.Friction = 1.0f;
			shape.Filter = filter;

			var bodies = scope List<Body>();
			var constraints = scope List<Constraint>();
			for (int i = 0; i < positions.Count - 1; i++)
			{
				var body = AddBox(space, 20, 1, i);
				bodies.Add(body);

				var pivot = new PivotJoint(staticBody, body, Vector2.Zero, Vector2.Zero);
				constraints.Add(pivot);
				space.AddConstraint(pivot);
				pivot.MaxBias = 0.0f;// disable joint correction
				pivot.MaxForce = 1000.0f;// emulate linear friction

				var gear = new GearJoint(staticBody, body, 0.0f, 1.0f);
				constraints.Add(gear);
				space.AddConstraint(gear);
				gear.MaxBias = 0.0f;// disable joint correction
				gear.MaxForce = 5000.0f;// emulate linear friction
			}

			// We joint the tank to the control body and control the tank indirectly by modifying the control body.
			var tankControlBody = scope Body(.Kinematic, 0.0f, 0.0f);
			space.AddBody(tankControlBody);
			var tankBody = AddBox(space, 30, 10, positions.Count - 1);
			bodies.Add(tankBody);

			var pivot = scope PivotJoint(tankControlBody, tankBody, Vector2.Zero, Vector2.Zero);
			space.AddConstraint(pivot);
			pivot.MaxBias = 0.0f;// disable joint correction
			pivot.MaxForce = 10000.0f;// emulate linear friction

			var gear = scope GearJoint(tankControlBody, tankBody, 0.0f, 1.0f);
			space.AddConstraint(gear);
			gear.ErrorBias = 0.0f;// attempt to fully correct the joint each step
			gear.MaxBias = 1.2f;// but limit it's angular correction rate
			gear.MaxForce = 50000.0f;// emulate angular friction

			var ChipmunkDemoMouse = Vector2(1000.0f, -1000.0f);
			var dt = 1.0f / 60.0f;

			for (int i = 0; i < 1000; ++i)
			{
				// turn the control body based on the angle relative to the actual body
				var mouseDelta = ChipmunkDemoMouse - tankBody.Position;
				var turn = Vector2.Unrotate(tankBody.Rotation, mouseDelta).Angle;
				tankControlBody.Angle = tankBody.Angle - turn;

				// drive the tank towards the mouse
				if (Vector2.Distance(ChipmunkDemoMouse, tankBody.Position) < 30.0f)
				{
					tankControlBody.Velocity = Vector2.Zero;
				} else
				{
					var direction = Vector2.Dot(mouseDelta, tankBody.Rotation) > 0.0f ? 1.0f : -1.0f;
					tankControlBody.Velocity = Vector2.Rotate(tankBody.Rotation, Vector2(30.0f * direction, 0.0f));
				}

				Console.WriteLine("IT:{0}, P:{1}", i, tankBody.Position);

				space.Step(dt);
			}

			// Cleanup (note: Shapes are cleaned automatically when the body is deleted)
			space.RemoveBody(tankControlBody);
			space.RemoveConstraint(pivot);
			space.RemoveConstraint(gear);

			for(var constraint in constraints) {
				space.RemoveConstraint(constraint);
				delete constraint;
			}
			for(var body in bodies) {
				space.RemoveBody(body);
				delete body;
			}

			Console.Read();

			return 0;
		}

		public static int Main()
		{
			return Tank();
		}
	}
}