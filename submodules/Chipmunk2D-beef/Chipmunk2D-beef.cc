#include <chipmunk/chipmunk.h>
#include <chipmunk/chipmunk_structs.h>

// Additional exposed functions

// Body
extern "C" void cpBodySetVelocityFunc(cpBody * body, cpBodyVelocityFunc func) {
	body->velocity_func = func;
}

extern "C" void cpBodySetPositionFunc(cpBody * body, cpBodyPositionFunc func) {
	body->position_func = func;
}