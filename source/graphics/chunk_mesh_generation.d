module graphics.chunk_mesh_generation;

import raylib;
import std.stdio;
import graphics.block_graphics;
import chunk.chunk;
import helpers.structs;

private Texture TEXTURE_ATLAS;
private bool lock = false;

void loadTextureAtlas() {
    // Avoid memory leak
    if (!lock) {
        TEXTURE_ATLAS = LoadTexture("textures/world_texture_map.png");
        lock = true;
    }
}

void debugCreateBlockGraphics(){
    // Stone
    registerBlockGraphicsDefinition(
        1,
        [
            // [0,0,0,1,0.5,1],
            // [0,0,0,0.5,1,0.5]
        ],
        [
            Vector2I(0,0),
            Vector2I(0,0),
            Vector2I(0,0),
            Vector2I(0,0),
            Vector2I(0,0),
            Vector2I(0,0)
        ]
    );

    // Grass
    registerBlockGraphicsDefinition(
        2,
        [],
        [
            Vector2I(1,0),
            Vector2I(1,0),
            Vector2I(1,0),
            Vector2I(1,0),
            Vector2I(3,0),
            Vector2I(2,0)
        ]
    );

    // Dirt
    registerBlockGraphicsDefinition(
        3,
        [],
        [
            Vector2I(3,0),
            Vector2I(3,0),
            Vector2I(3,0),
            Vector2I(3,0),
            Vector2I(3,0),
            Vector2I(3,0)
        ]
    );
}

immutable Vector3I[6] checkPositions = [
    Vector3I(-1, 0, 0),
    Vector3I( 1, 0, 0),
    Vector3I( 0, 0,-1),
    Vector3I( 0, 0, 1),
    Vector3I( 0,-1, 0),
    Vector3I( 0, 1, 0)
];


void generateChunkMesh(ref Chunk chunk, ubyte yStack) {

    float[] vertices;
    ushort[] indices;
    // float[] normals;
    float[] textureCoordinates;
    // For dispatching colors ubyte[]

    int triangleCount = 0;
    int vertexCount   = 0;

    // Work goes here
    immutable int yMin = yStack * chunkStackSizeY;
    immutable int yMax = (yStack + 1) * chunkStackSizeY;

    for (int x = 0; x < chunkSizeX; x++){
        for (int z = 0; z < chunkSizeZ; z++) {
            for (int y = yMin; y < yMax; y++) {
                // writeln(x," ", y, " ", z);
                Vector3I position = Vector3I(x,y,z);
                uint currentBlock = chunk.getBlock(position.x,position.y,position.z);
                ubyte currentRotation = chunk.getRotation(position.x, position.y, position.z);

                bool[6] renderingPositions = [false,false,false,false,false,false];

                for (int w = 0; w < 6; w++) {
                    Vector3I selectedPosition = checkPositions[w];

                    Vector3I currentCheckPosition = Vector3I(
                        position.x + selectedPosition.x,
                        position.y + selectedPosition.y,
                        position.z + selectedPosition.z,
                    );

                    if (!collide(currentCheckPosition.x, currentCheckPosition.y, currentCheckPosition.z)) {
                        renderingPositions[w] = true;
                    } else {
                        if (chunk.getBlock(currentCheckPosition.x, currentCheckPosition.y, currentCheckPosition.z) == 0) {
                            renderingPositions[w] = true;
                        }
                    }
                }

                if (currentBlock != 0) {
                    buildBlock(
                        currentBlock,
                        vertices,
                        textureCoordinates,
                        indices,
                        triangleCount,
                        vertexCount,
                        position,
                        currentRotation,
                        renderingPositions
                    );
                }
            }
        }
    }

    // Discard old gpu data, OpenGL will silently fail internally with invalid VAO, this is wanted
    chunk.removeModel(yStack);

    writeln("vertex: ", vertexCount, " | triangle: ", triangleCount);

    // No more processing is required, it's nothing
    if (vertexCount == 0) {
        return;
    }

    Mesh thisChunkMesh = Mesh();

    thisChunkMesh.triangleCount = triangleCount;
    thisChunkMesh.vertexCount = vertexCount;

    thisChunkMesh.vertices  = vertices.ptr;
    thisChunkMesh.indices   = indices.ptr;
    // thisChunkMesh.normals   = normals.ptr;
    thisChunkMesh.texcoords = textureCoordinates.ptr;

    UploadMesh(&thisChunkMesh, false);

    Model thisChunkModel = LoadModelFromMesh(thisChunkMesh);

    thisChunkModel.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = TEXTURE_ATLAS;

    chunk.setModel(yStack, thisChunkModel);

}