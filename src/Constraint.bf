using System;

namespace Chipmunk2D
{
	class Constraint : ObjectBase
	{
		protected Body bodyA;
		protected Body bodyB;

		public Body BodyA => bodyA;

		public Body BodyB => bodyB;

		public Real MaxForce { get { return cpConstraintGetMaxForce(handle); } set { cpConstraintSetMaxForce(handle, value); } }

		public Real ErrorBias { get { return cpConstraintGetErrorBias(handle); } set { cpConstraintSetErrorBias(handle, value); } }

		public Real MaxBias { get { return cpConstraintGetMaxBias(handle); } set { cpConstraintSetMaxBias(handle, value); } }

		public bool CollideBodies { get { return cpConstraintGetCollideBodies(handle); } set { cpConstraintSetCollideBodies(handle, value); } }

		public Real Impulse => cpConstraintGetImpulse(handle);

		protected void Initialize(void* _handle, Body a, Body b)
		{
			handle = _handle;
			bodyA = a;
			bodyB = b;
			cpConstraintSetUserData(handle, Internal.UnsafeCastToPtr(this));
		}

		public ~this()
		{
			cpConstraintFree(handle);
			handle = null;
		}

		// // /// Destroy and free a constraint.
		[CLink] private static extern void cpConstraintFree(void* constraint);

		// // /// Get the user definable data pointer for this constraint
		[CLink] private static extern void* cpConstraintGetUserData(void* constraint);
		// // /// Set the user definable data pointer for this constraint
		[CLink] private static extern void cpConstraintSetUserData(void* constraint, void* userData);

		// // /// Get the maximum force that this constraint is allowed to use.
		[CLink] private static extern Real cpConstraintGetMaxForce(void* constraint);
		// // /// Set the maximum force that this constraint is allowed to use. (defaults to INFINITY)
		[CLink] private static extern void cpConstraintSetMaxForce(void* constraint, Real maxForce);

		// // /// Get rate at which joint error is corrected.
		[CLink] private static extern Real cpConstraintGetErrorBias(void* constraint);
		// // /// Set rate at which joint error is corrected. Defaults to pow(1.0 - 0.1, 60.0) meaning that it will
		// correct 10% of the error every 1/60th of a second.
		[CLink] private static extern void cpConstraintSetErrorBias(void* constraint, Real errorBias);

		// // /// Get the maximum rate at which joint error is corrected.
		[CLink] private static extern Real cpConstraintGetMaxBias(void* constraint);
		// // /// Set the maximum rate at which joint error is corrected. (defaults to INFINITY)
		[CLink] private static extern void cpConstraintSetMaxBias(void* constraint, Real maxBias);

		// // /// Get if the two bodies connected by the constraint are allowed to collide or not.
		[CLink] private static extern bool cpConstraintGetCollideBodies(void* constraint);
		// // /// Set if the two bodies connected by the constraint are allowed to collide or not. (defaults to cpFalse)
		[CLink] private static extern void cpConstraintSetCollideBodies(void* constraint, bool collideBodies);

		// // /// Get the last impulse applied by this constraint.
		[CLink] private static extern Real cpConstraintGetImpulse(void* constraint);
	}

	class DampedRotarySpring : Constraint
	{
		public this(Body a, Body b, Real restAngle, Real stiffness, Real damping)
		{
			Initialize(cpDampedRotarySpringNew(a.Handle, b.Handle, restAngle, stiffness, damping), a, b);
		}

		public Real RestAngle { get { return cpDampedRotarySpringGetRestAngle(handle); } set { cpDampedRotarySpringSetRestAngle(handle, value); } }

		public Real Stiffness { get { return cpDampedRotarySpringGetStiffness(handle); } set { cpDampedRotarySpringSetStiffness(handle, value); } }

		public Real Damping { get { return cpDampedRotarySpringGetDamping(handle); } set { cpDampedRotarySpringSetDamping(handle, value); } }

		// // /// Allocate and initialize a damped rotary spring.
		[CLink] private static extern void* cpDampedRotarySpringNew(void* a, void* b, Real restAngle, Real stiffness, Real damping);

		// // /// Get the rest length of the spring.
		[CLink] private static extern Real cpDampedRotarySpringGetRestAngle(void* constraint);
		// // /// Set the rest length of the spring.
		[CLink] private static extern void cpDampedRotarySpringSetRestAngle(void* constraint, Real restAngle);

		// // /// Get the stiffness of the spring in force/distance.
		[CLink] private static extern Real cpDampedRotarySpringGetStiffness(void* constraint);
		// // /// Set the stiffness of the spring in force/distance.
		[CLink] private static extern void cpDampedRotarySpringSetStiffness(void* constraint, Real stiffness);

		// // /// Get the damping of the spring.
		[CLink] private static extern Real cpDampedRotarySpringGetDamping(void* constraint);
		// // /// Set the damping of the spring.
		[CLink] private static extern void cpDampedRotarySpringSetDamping(void* constraint, Real damping);

	}

	class DampedSpring : Constraint
	{
		public this(Body a, Body b, Vector2 anchorA, Vector2 anchorB, Real restLength, Real stiffness, Real damping)
		{
			Initialize(cpDampedSpringNew(a.Handle, b.Handle, anchorA, anchorB, restLength, stiffness, damping), a, b);
		}

		public Vector2 AnchorA { get { return cpDampedSpringGetAnchorA(handle); } set { cpDampedSpringSetAnchorA(handle, value); } }

		public Vector2 AnchorB { get { return cpDampedSpringGetAnchorB(handle); } set { cpDampedSpringSetAnchorB(handle, value); } }

		public Real RestLength { get { return cpDampedSpringGetRestLength(handle); } set { cpDampedSpringSetRestLength(handle, value); } }

		public Real Stiffness { get { return cpDampedSpringGetStiffness(handle); } set { cpDampedSpringSetStiffness(handle, value); } }

		public Real Damping { get { return cpDampedSpringGetDamping(handle); } set { cpDampedSpringSetDamping(handle, value); } }

		/// Allocate and initialize a damped spring.
		[CLink] private static extern void* cpDampedSpringNew(void* a, void* b, Vector2 anchorA, Vector2 anchorB, Real restLength, Real stiffness, Real damping);

		/// Get the location of the first anchor relative to the first body.
		[CLink] private static extern Vector2 cpDampedSpringGetAnchorA(void* constraint);
		/// Set the location of the first anchor relative to the first body.
		[CLink] private static extern void cpDampedSpringSetAnchorA(void* constraint, Vector2 anchorA);

		/// Get the location of the second anchor relative to the second body.
		[CLink] private static extern Vector2 cpDampedSpringGetAnchorB(void* constraint);
		/// Set the location of the second anchor relative to the second body.
		[CLink] private static extern void cpDampedSpringSetAnchorB(void* constraint, Vector2 anchorB);

		/// Get the rest length of the spring.
		[CLink] private static extern Real cpDampedSpringGetRestLength(void* constraint);
		/// Set the rest length of the spring.
		[CLink] private static extern void cpDampedSpringSetRestLength(void* constraint, Real restLength);

		/// Get the stiffness of the spring in force/distance.
		[CLink] private static extern Real cpDampedSpringGetStiffness(void* constraint);
		/// Set the stiffness of the spring in force/distance.
		[CLink] private static extern void cpDampedSpringSetStiffness(void* constraint, Real stiffness);

		/// Get the damping of the spring.
		[CLink] private static extern Real cpDampedSpringGetDamping(void* constraint);
		/// Set the damping of the spring.
		[CLink] private static extern void cpDampedSpringSetDamping(void* constraint, Real damping);

	}

	class GearJoint : Constraint
	{
		public this(Body a, Body b, Real phase, Real ratio)
		{
			Initialize(cpGearJointNew(a.Handle, b.Handle, phase, ratio), a, b);
		}

		public Real Phase { get { return cpGearJointGetPhase(handle); } set { cpGearJointSetPhase(handle, value); } }

		public Real Ratio { get { return cpGearJointGetRatio(handle); } set { cpGearJointSetRatio(handle, value); } }

		/// Allocate and initialize a gear joint.
		[CLink] private static extern void* cpGearJointNew(void* a, void* b, Real phase, Real ratio);

		/// Get the phase offset of the gears.
		[CLink] private static extern Real cpGearJointGetPhase(void* constraint);
		/// Set the phase offset of the gears.
		[CLink] private static extern void cpGearJointSetPhase(void* constraint, Real phase);

		/// Get the angular distance of each ratchet.
		[CLink] private static extern Real cpGearJointGetRatio(void* constraint);
		/// Set the ratio of a gear joint.
		[CLink] private static extern void cpGearJointSetRatio(void* constraint, Real ratio);

	}

	class GrooveJoint : Constraint
	{
		public this(Body a, Body b, Vector2 groove_a, Vector2 groove_b, Vector2 anchorB)
		{
			Initialize(cpGrooveJointNew(a.Handle, b.Handle, groove_a, groove_b, anchorB), a, b);
		}

		public Vector2 GrooveA { get { return cpGrooveJointGetGrooveA(handle); } set { cpGrooveJointSetGrooveA(handle, value); } }

		public Vector2 GrooveB { get { return cpGrooveJointGetGrooveB(handle); } set { cpGrooveJointSetGrooveB(handle, value); } }

		public Vector2 AnchorB { get { return cpGrooveJointGetAnchorB(handle); } set { cpGrooveJointSetAnchorB(handle, value); } }

		/// Allocate and initialize a groove joint.
		[CLink] private static extern void* cpGrooveJointNew(void* a, void* b, Vector2 groove_a, Vector2 groove_b, Vector2 anchorB);

		/// Get the first endpoint of the groove relative to the first body.
		[CLink] private static extern Vector2 cpGrooveJointGetGrooveA(void* constraint);
		/// Set the first endpoint of the groove relative to the first body.
		[CLink] private static extern void cpGrooveJointSetGrooveA(void* constraint, Vector2 grooveA);

		/// Get the first endpoint of the groove relative to the first body.
		[CLink] private static extern Vector2 cpGrooveJointGetGrooveB(void* constraint);
		/// Set the first endpoint of the groove relative to the first body.
		[CLink] private static extern void cpGrooveJointSetGrooveB(void* constraint, Vector2 grooveB);

		/// Get the location of the second anchor relative to the second body.
		[CLink] private static extern Vector2 cpGrooveJointGetAnchorB(void* constraint);
		/// Set the location of the second anchor relative to the second body.
		[CLink] private static extern void cpGrooveJointSetAnchorB(void* constraint, Vector2 anchorB);

	}

	class PinJoint : Constraint
	{
		public this(Body a, Body b, Vector2 anchorA, Vector2 anchorB)
		{
			Initialize(cpPinJointNew(a.Handle, b.Handle, anchorA, anchorB), a, b);
		}

		public Vector2 AnchorA { get { return cpPinJointGetAnchorA(handle); } set { cpPinJointSetAnchorA(handle, value); } }

		public Vector2 AnchorB { get { return cpPinJointGetAnchorB(handle); } set { cpPinJointSetAnchorB(handle, value); } }

		public Real Distance { get { return cpPinJointGetDist(handle); } set { cpPinJointSetDist(handle, value); } }

		/// Allocate and initialize a pin joint.
		[CLink] private static extern void* cpPinJointNew(void* a, void* b, Vector2 anchorA, Vector2 anchorB);

		/// Get the location of the first anchor relative to the first body.
		[CLink] private static extern Vector2 cpPinJointGetAnchorA(void* constraint);
		/// Set the location of the first anchor relative to the first body.
		[CLink] private static extern void cpPinJointSetAnchorA(void* constraint, Vector2 anchorA);

		/// Get the location of the second anchor relative to the second body.
		[CLink] private static extern Vector2 cpPinJointGetAnchorB(void* constraint);
		/// Set the location of the second anchor relative to the second body.
		[CLink] private static extern void cpPinJointSetAnchorB(void* constraint, Vector2 anchorB);

		/// Get the distance the joint will maintain between the two anchors.
		[CLink] private static extern Real cpPinJointGetDist(void* constraint);
		/// Set the distance the joint will maintain between the two anchors.
		[CLink] private static extern void cpPinJointSetDist(void* constraint, Real dist);

	}

	class PivotJoint : Constraint
	{
		public this(Body a, Body b, Vector2 pivot)
		{
			Initialize(cpPivotJointNew(a.Handle, b.Handle, pivot), a, b);
		}

		public this(Body a, Body b, Vector2 anchorA, Vector2 anchorB)
		{
			Initialize(cpPivotJointNew2(a.Handle, b.Handle, anchorA, anchorB), a, b);
		}

		public Vector2 AnchorA { get { return cpPivotJointGetAnchorA(handle); } set { cpPivotJointSetAnchorA(handle, value); } }

		public Vector2 AnchorB { get { return cpPivotJointGetAnchorB(handle); } set { cpPivotJointSetAnchorB(handle, value); } }

		/// Allocate and initialize a pivot joint.
		[CLink] private static extern void* cpPivotJointNew(void* a, void* b, Vector2 pivot);
		/// Allocate and initialize a pivot joint with specific anchors.
		[CLink] private static extern void* cpPivotJointNew2(void* a, void* b, Vector2 anchorA, Vector2 anchorB);

		/// Get the location of the first anchor relative to the first body.
		[CLink] private static extern Vector2 cpPivotJointGetAnchorA(void* constraint);
		/// Set the location of the first anchor relative to the first body.
		[CLink] private static extern void cpPivotJointSetAnchorA(void* constraint, Vector2 anchorA);

		/// Get the location of the second anchor relative to the second body.
		[CLink] private static extern Vector2 cpPivotJointGetAnchorB(void* constraint);
		/// Set the location of the second anchor relative to the second body.
		[CLink] private static extern void cpPivotJointSetAnchorB(void* constraint, Vector2 anchorB);
	}

	class RatchetJoint : Constraint
	{
		public this(Body a, Body b, Real phase, Real ratchet)
		{
			Initialize(cpRatchetJointNew(a.Handle, b.Handle, phase, ratchet), a, b);
		}

		public Real Angle { get { return cpRatchetJointGetAngle(handle); } set { cpRatchetJointSetAngle(handle, value); } }

		public Real Phase { get { return cpRatchetJointGetPhase(handle); } set { cpRatchetJointSetPhase(handle, value); } }

		public Real Ratchet { get { return cpRatchetJointGetRatchet(handle); } set { cpRatchetJointSetRatchet(handle, value); } }

		/// Allocate and initialize a ratchet joint.
		[CLink] private static extern void* cpRatchetJointNew(void* a, void* b, Real phase, Real ratchet);

		/// Get the angle of the current ratchet tooth.
		[CLink] private static extern Real cpRatchetJointGetAngle(void* constraint);
		/// Set the angle of the current ratchet tooth.
		[CLink] private static extern void cpRatchetJointSetAngle(void* constraint, Real angle);

		/// Get the phase offset of the ratchet.
		[CLink] private static extern Real cpRatchetJointGetPhase(void* constraint);
		/// Get the phase offset of the ratchet.
		[CLink] private static extern void cpRatchetJointSetPhase(void* constraint, Real phase);

		/// Get the angular distance of each ratchet.
		[CLink] private static extern Real cpRatchetJointGetRatchet(void* constraint);
		/// Set the angular distance of each ratchet.
		[CLink] private static extern void cpRatchetJointSetRatchet(void* constraint, Real ratchet);
	}

	class RotaryLimitJoint : Constraint
	{
		public this(Body a, Body b, Real min, Real max)
		{
			Initialize(cpRotaryLimitJointNew(a.Handle, b.Handle, min, max), a, b);
		}

		public Real MinimumDistance { get { return cpRotaryLimitJointGetMin(handle); } set { cpRotaryLimitJointSetMin(handle, value); } }

		public Real MaximumDistance { get { return cpRotaryLimitJointGetMax(handle); } set { cpRotaryLimitJointSetMax(handle, value); } }

		/// Allocate and initialize a damped rotary limit joint.
		[CLink] private static extern void* cpRotaryLimitJointNew(void* a, void* b, Real min, Real max);

		/// Get the minimum distance the joint will maintain between the two anchors.
		[CLink] private static extern Real cpRotaryLimitJointGetMin(void* constraint);
		/// Set the minimum distance the joint will maintain between the two anchors.
		[CLink] private static extern void cpRotaryLimitJointSetMin(void* constraint, Real min);

		/// Get the maximum distance the joint will maintain between the two anchors.
		[CLink] private static extern Real cpRotaryLimitJointGetMax(void* constraint);
		/// Set the maximum distance the joint will maintain between the two anchors.
		[CLink] private static extern void cpRotaryLimitJointSetMax(void* constraint, Real max);

	}

	class SimpleMotor : Constraint
	{
		public this(Body a, Body b, Real rate)
		{
			Initialize(cpSimpleMotorNew(a.Handle, b.Handle, rate), a, b);
		}

		public Real MaximumDistance { get { return cpSimpleMotorGetRate(handle); } set { cpSimpleMotorSetRate(handle, value); } }

		/// Allocate and initialize a simple motor.
		[CLink] private static extern void* cpSimpleMotorNew(void* a, void* b, Real rate);

		/// Get the rate of the motor.
		[CLink] private static extern Real cpSimpleMotorGetRate(void* constraint);
		/// Set the rate of the motor.
		[CLink] private static extern void cpSimpleMotorSetRate(void* constraint, Real rate);

	}

	class SlideJoint : Constraint
	{
		public this(Body a, Body b, Vector2 anchorA, Vector2 anchorB, Real min, Real max)
		{
			Initialize(cpSlideJointNew(a.Handle, b.Handle, anchorA, anchorB, min, max), a, b);
		}

		public Vector2 AnchorA { get { return cpSlideJointGetAnchorA(handle); } set { cpSlideJointSetAnchorA(handle, value); } }

		public Vector2 AnchorB { get { return cpSlideJointGetAnchorB(handle); } set { cpSlideJointSetAnchorB(handle, value); } }

		public Real MinimumDistance { get { return cpSlideJointGetMin(handle); } set { cpSlideJointSetMin(handle, value); } }

		public Real MaximumDistance { get { return cpSlideJointGetMax(handle); } set { cpSlideJointSetMax(handle, value); } }

		/// Allocate and initialize a slide joint.
		[CLink] private static extern void* cpSlideJointNew(void* a, void* b, Vector2 anchorA, Vector2 anchorB, Real min, Real max);

		/// Get the location of the first anchor relative to the first body.
		[CLink] private static extern Vector2 cpSlideJointGetAnchorA(void* constraint);
		/// Set the location of the first anchor relative to the first body.
		[CLink] private static extern void cpSlideJointSetAnchorA(void* constraint, Vector2 anchorA);

		/// Get the location of the second anchor relative to the second body.
		[CLink] private static extern Vector2 cpSlideJointGetAnchorB(void* constraint);
		/// Set the location of the second anchor relative to the second body.
		[CLink] private static extern void cpSlideJointSetAnchorB(void* constraint, Vector2 anchorB);

		/// Get the minimum distance the joint will maintain between the two anchors.
		[CLink] private static extern Real cpSlideJointGetMin(void* constraint);
		/// Set the minimum distance the joint will maintain between the two anchors.
		[CLink] private static extern void cpSlideJointSetMin(void* constraint, Real min);

		/// Get the maximum distance the joint will maintain between the two anchors.
		[CLink] private static extern Real cpSlideJointGetMax(void* constraint);
		/// Set the maximum distance the joint will maintain between the two anchors.
		[CLink] private static extern void cpSlideJointSetMax(void* constraint, Real max);
	}
}
