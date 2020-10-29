using System;
using System.Collections;
using Chipmunk2D;

namespace Example
{
	class Program
	{
		static readonly cpVect[] positions = new cpVect[](
			cpVect(-154.275395f, -211.224674f),
			cpVect(-248.323826f, 62.732261f),
			cpVect(-81.664735f, -97.287018f),
			cpVect(283.133498f, -103.619042f),
			cpVect(253.344966f, -76.675636f),
			cpVect(208.617654f, -136.080354f),
			cpVect(-286.712395f, -196.958237f),
			cpVect(-8.235025f, 53.673591f),
			cpVect(176.300747f, -96.123994f),
			cpVect(-30.331598f, -172.987005f),
			cpVect(276.118147f, 59.346567f),
			cpVect(169.552478f, 68.120943f),
			cpVect(-268.159107f, 26.794797f),
			cpVect(-251.831502f, 161.498906f),
			cpVect(283.008860f, -86.044446f),
			cpVect(-281.210508f, -180.107301f),
			cpVect(39.234328f, -200.860831f),
			cpVect(86.418793f, 6.764927f),
			cpVect(-67.064259f, 93.397347f),
			cpVect(-276.278396f, -50.753107f),
			cpVect(-169.249785f, 169.924374f),
			cpVect(26.770507f, 152.995903f),
			cpVect(74.791828f, 196.596407f),
			cpVect(262.229890f, -53.906196f),
			cpVect(12.152225f, -113.789047f),
			cpVect(231.835972f, -113.130000f),
			cpVect(-51.253012f, -53.040389f),
			cpVect(-84.299943f, 103.438127f),
			cpVect(-163.943759f, -52.394264f),
			cpVect(51.288623f, -181.593388f),
			cpVect(-40.017768f, 74.052369f),
			cpVect(-272.094114f, 136.261269f),
			cpVect(-142.078656f, 68.082175f),
			cpVect(204.273122f, 102.779079f),
			cpVect(149.361088f, -139.375591f),
			cpVect(-56.452206f, -29.547289f),
			cpVect(5.688844f, -151.199676f),
			cpVect(-7.861110f, -14.518425f),
			cpVect(195.708697f, -176.217630f),
			cpVect(28.853745f, 161.369681f),
			cpVect(-235.592924f, 3.741063f),
			cpVect(126.783767f, -58.984737f),
			cpVect(-217.182080f, -208.627252f),
			cpVect(223.520823f, -175.481047f),
			cpVect(-107.696316f, -172.651020f),
			cpVect(89.196444f, 53.621901f),
			cpVect(-85.635352f, -4.697328f),
			cpVect(-43.133723f, 124.049509f),
			cpVect(-165.920165f, -203.652091f),
			cpVect(-63.271697f, 144.544590f),
			cpVect(-70.268043f, 93.863586f)
			) ~ delete _;


		static cpBody AddBox(cpSpace space, float size, float mass, int index)
		{
			var radius = cpVect(size, size).Length;
			var body = new cpBody(.Dynamic, mass, cpShape.MomentForBox(mass, size, size));
			space.AddBody(body);
			body.Position = positions[index];
			var shape = body.AddBoxShape(size, size, 0.0f);
			shape.Elasticity = 0.0f;
			shape.Friction = 0.7f;
			return body;
		}


		public static int Tank()
		{
			var space = scope cpSpace();
			space.Iterations = 10;
			space.SleepTimeThreshold = 0.5f;

			var filter = cpShapeFilter() { group = 0, categories = 0x7fffffff, mask = 0x7fffffff };

			var staticBody = space.StaticBody;
			var shape = staticBody.AddSegmentShape(cpVect(-320, -240), cpVect(-320, 240), 0.0f);
			shape.Elasticity = 1.0f;
			shape.Friction = 1.0f;
			shape.Filter = filter;

			shape = staticBody.AddSegmentShape(cpVect(320, -240), cpVect(320, 240), 0.0f);
			shape.Elasticity = 1.0f;
			shape.Friction = 1.0f;
			shape.Filter = filter;

			shape = staticBody.AddSegmentShape(cpVect(-320, -240), cpVect(320, -240), 0.0f);
			shape.Elasticity = 1.0f;
			shape.Friction = 1.0f;
			shape.Filter = filter;

			shape = staticBody.AddSegmentShape(cpVect(-320, 240), cpVect(320, 240), 0.0f);
			shape.Elasticity = 1.0f;
			shape.Friction = 1.0f;
			shape.Filter = filter;

			var bodies = scope List<cpBody>();
			var constraints = scope List<cpConstraint>();
			for (int i = 0; i < positions.Count - 1; i++)
			{
				var body = AddBox(space, 20, 1, i);
				bodies.Add(body);

				var pivot = new cpPivotJoint(staticBody, body, cpVect.Zero, cpVect.Zero);
				constraints.Add(pivot);
				space.AddConstraint(pivot);
				pivot.MaxBias = 0.0f;// disable joint correction
				pivot.MaxForce = 1000.0f;// emulate linear friction

				var gear = new cpGearJoint(staticBody, body, 0.0f, 1.0f);
				constraints.Add(gear);
				space.AddConstraint(gear);
				gear.MaxBias = 0.0f;// disable joint correction
				gear.MaxForce = 5000.0f;// emulate linear friction
			}

			// We joint the tank to the control body and control the tank indirectly by modifying the control body.
			var tankControlBody = scope cpBody(.Kinematic, 0.0f, 0.0f);
			space.AddBody(tankControlBody);
			var tankBody = AddBox(space, 30, 10, positions.Count - 1);
			bodies.Add(tankBody);

			var pivot = scope cpPivotJoint(tankControlBody, tankBody, cpVect.Zero, cpVect.Zero);
			space.AddConstraint(pivot);
			pivot.MaxBias = 0.0f;// disable joint correction
			pivot.MaxForce = 10000.0f;// emulate linear friction

			var gear = scope cpGearJoint(tankControlBody, tankBody, 0.0f, 1.0f);
			space.AddConstraint(gear);
			gear.ErrorBias = 0.0f;// attempt to fully correct the joint each step
			gear.MaxBias = 1.2f;// but limit it's angular correction rate
			gear.MaxForce = 50000.0f;// emulate angular friction

			var ChipmunkDemoMouse = cpVect(1000.0f, -1000.0f);
			var dt = 1.0f / 60.0f;

			for (int i = 0; i < 1000; ++i)
			{
				// turn the control body based on the angle relative to the actual body
				var mouseDelta = ChipmunkDemoMouse - tankBody.Position;
				var turn = cpVect.Unrotate(tankBody.Rotation, mouseDelta).Angle;
				tankControlBody.Angle = tankBody.Angle - turn;

				// drive the tank towards the mouse
				if (cpVect.Distance(ChipmunkDemoMouse, tankBody.Position) < 30.0f)
				{
					tankControlBody.Velocity = cpVect.Zero;
				} else
				{
					var direction = cpVect.Dot(mouseDelta, tankBody.Rotation) > 0.0f ? 1.0f : -1.0f;
					tankControlBody.Velocity = cpVect.Rotate(tankBody.Rotation, cpVect(30.0f * direction, 0.0f));
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