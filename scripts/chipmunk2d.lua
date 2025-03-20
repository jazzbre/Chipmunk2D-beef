project "chipmunk2d"
	kind "StaticLib"
	windowstargetplatformversion("10.0")

	defines {
		"CP_USE_DOUBLES=1"
	}

	includedirs {
		path.join(SOURCE_DIR, "Chipmunk2D/include")
	}

	files {
		path.join(SOURCE_DIR, "Chipmunk2D/include/**.h"),
		path.join(SOURCE_DIR, "Chipmunk2D/src/chipmunk.c"),
		path.join(SOURCE_DIR, "Chipmunk2D/src/cpArbiter.c"),
		path.join(SOURCE_DIR, "Chipmunk2D/src/cpArray.c"),
		path.join(SOURCE_DIR, "Chipmunk2D/src/cpBBTree.c"),
		path.join(SOURCE_DIR, "Chipmunk2D/src/cpBody.c"),
		path.join(SOURCE_DIR, "Chipmunk2D/src/cpCollision.c"),
		path.join(SOURCE_DIR, "Chipmunk2D/src/cpConstraint.c"),
		path.join(SOURCE_DIR, "Chipmunk2D/src/cpDampedRotarySpring.c"),
		path.join(SOURCE_DIR, "Chipmunk2D/src/cpDampedSpring.c"),
		path.join(SOURCE_DIR, "Chipmunk2D/src/cpGearJoint.c"),
		path.join(SOURCE_DIR, "Chipmunk2D/src/cpGrooveJoint.c"),
		path.join(SOURCE_DIR, "Chipmunk2D/src/cpHashSet.c"),
		path.join(SOURCE_DIR, "Chipmunk2D/src/cpMarch.c"),
		path.join(SOURCE_DIR, "Chipmunk2D/src/cpPinJoint.c"),
		path.join(SOURCE_DIR, "Chipmunk2D/src/cpPivotJoint.c"),
		path.join(SOURCE_DIR, "Chipmunk2D/src/cpPolyShape.c"),
		path.join(SOURCE_DIR, "Chipmunk2D/src/cpRatchetJoint.c"),
		path.join(SOURCE_DIR, "Chipmunk2D/src/cpRobust.c"),
		path.join(SOURCE_DIR, "Chipmunk2D/src/cpRotaryLimitJoint.c"),
		path.join(SOURCE_DIR, "Chipmunk2D/src/cpShape.c"),
		path.join(SOURCE_DIR, "Chipmunk2D/src/cpSimpleMotor.c"),
		path.join(SOURCE_DIR, "Chipmunk2D/src/cpSlideJoint.c"),
		path.join(SOURCE_DIR, "Chipmunk2D/src/cpSpace.c"),
		path.join(SOURCE_DIR, "Chipmunk2D/src/cpSpaceComponent.c"),
		path.join(SOURCE_DIR, "Chipmunk2D/src/cpSpaceDebug.c"),
		path.join(SOURCE_DIR, "Chipmunk2D/src/cpSpaceHash.c"),
		path.join(SOURCE_DIR, "Chipmunk2D/src/cpSpaceQuery.c"),
		path.join(SOURCE_DIR, "Chipmunk2D/src/cpSpaceStep.c"),
		path.join(SOURCE_DIR, "Chipmunk2D/src/cpSpatialIndex.c"),
		path.join(SOURCE_DIR, "Chipmunk2D/src/cpSweep1D.c"),
		path.join(SOURCE_DIR, "Chipmunk2D-beef/*.cc")
	}

	configuration {}
