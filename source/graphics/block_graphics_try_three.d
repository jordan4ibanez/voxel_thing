module graphics.block_graphics_try_three;

import std.stdio;
import raylib;
import helpers.structs;
import std.math: abs;

// Defines how many textures are in the texture map
const double TEXTURE_MAP_TILES = 32;
// Defines the width/height of each texture
const double TEXTURE_TILE_SIZE = 16;
// Defines the total width/height of the texture map in pixels
const double TEXTURE_MAP_SIZE = TEXTURE_TILE_SIZE * TEXTURE_MAP_TILES;

// Immutable face vertex positions
// This is documented as if you were facing the quad with it's texture position aligned to you
// Idices order = [ 3, 0, 1, 1, 2, 3 ]
immutable Vector3[4][6] FACE = [
    // Axis base:        X 0
    // Normal direction: X -1
    [
        Vector3(0,1,0), // Top Left     | 0
        Vector3(0,0,0), // Bottom Left  | 1
        Vector3(0,0,1), // Bottom Right | 2
        Vector3(0,1,1), // Top Right    | 3   
    ],
    // Axis base:        Y 0
    // Normal direction: Y -1
    [
        Vector3(1,0,1), // Top Left     | 0
        Vector3(0,0,1), // Bottom Left  | 1
        Vector3(0,0,0), // Bottom Right | 2
        Vector3(1,0,0), // Top Right    | 3
    ],
    // Axis base:        Z 0
    // Normal direction: Z -1
    [
        Vector3(1,1,0), // Top Left     | 0
        Vector3(1,0,0), // Bottom Left  | 1
        Vector3(0,0,0), // Bottom Right | 2
        Vector3(0,1,0), // Top Right    | 3
    ],


    // Axis base:        X 1
    // Normal direction: X 1
    [
        Vector3(1,1,1), // Top Left     | 0
        Vector3(1,0,1), // Bottom Left  | 1
        Vector3(1,0,0), // Bottom Right | 2
        Vector3(1,1,0), // Top Right    | 3
    ],
    // Axis base:        Z 1
    // Normal direction: Z 1
    [
        Vector3(0,1,1), // Top Left     | 0
        Vector3(0,0,1), // Bottom Left  | 1
        Vector3(1,0,1), // Bottom Right | 2
        Vector3(1,1,1), // Top Right    | 3
    ],
    // Axis base:        Y 1
    // Normal direction: Y 1
    [
        Vector3(1,1,0), // Top Left     | 0
        Vector3(0,1,0), // Bottom Left  | 1
        Vector3(0,1,1), // Bottom Right | 2
        Vector3(1,1,1), // Top Right    | 3
    ]
];