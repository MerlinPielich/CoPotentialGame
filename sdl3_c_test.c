// sdl3_c_test.c
#include <SDL3/SDL.h>
#include <stdio.h>

int main(void) {
    if (SDL_Init(SDL_INIT_VIDEO) != 0) {
        fprintf(stderr, "SDL_Init failed: %s\n", SDL_GetError());
        return 1;
    }
    SDL_Quit();
    return 0;
}

