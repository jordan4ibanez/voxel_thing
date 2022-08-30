module game.graphics.chunk_mesh_generator;

// Normal external libraries
import std.algorithm;
import std.stdio;
import std.range: popFront;
import std.array: insertInPlace;
import vector_2i;
import vector_3i;

// Concurrency external libraries
import std.concurrency;
import std.algorithm.mutation: copy;
import core.time: Duration;
import asdf;

// Normal internal engine libraries
import Window = engine.window.window;

// Normal internal game libraries
import game.chunk.chunk_container;
import game.chunk.chunk;
import game.graphics.mesh_generation;


// Mesh Generation Factory

/*
How this works:

The entry point is the chunk factory. It gets processed via internalGenerateChunk().

It then comes here and becomes part of the newStack!

A chunk mesh is created using the api in block graphics.

Next we need to update the neighbors if they exist. This gets sent into updatingStack.

Updating stack does not update the neighbors. This avoids a recursion crash.

That's about it really
*/

// Thread spawner starts here
void startMeshGeneratorThread(Tid parentThread) {





// Gotta tell the main thread what has been created
Tid mainThread = parentThread;

// New meshes call this update to fully update neighbors on heap
// This needs to be a package of current and neighbors
Vector3i[] newStack = new Vector3i[0];

// Preexisting meshes call this update to only update necessary neighbors on heap
// This needs to be a package of current and neighbors
Vector3i[] updatingStack = new Vector3i[0];

void newChunkMeshUpdate(Vector3i position) {
    if (!newStack.canFind(position)) {
        newStack.insertInPlace(0, position);
        // newStack ~= position;
    }
}

void updateChunkMesh(Vector3i position) {
    if (!updatingStack.canFind(position)) {
        // newStack.insertInPlace(0, position);
        updatingStack ~= position;
    }
}


void internalGenerateChunkMesh(Vector3i position) {

    Chunk thisChunk = getChunk(Vector2i(position.x, position.z));

    // Get chunk neighbors
    // These do not exist by default
    Chunk neighborNegativeX = getChunk(Vector2i(position.x - 1, position.z));
    Chunk neighborPositiveX = getChunk(Vector2i(position.x + 1, position.z));
    Chunk neighborNegativeZ = getChunk(Vector2i(position.x, position.z - 1));
    Chunk neighborPositiveZ = getChunk(Vector2i(position.x, position.z + 1));

    generateChunkMesh(
        thisChunk,
        neighborNegativeX,
        neighborPositiveX,
        neighborNegativeZ,
        neighborPositiveZ,
        cast(ubyte)position.y
    );

    // Update neighbors
    if (neighborNegativeX.exists()) {
        updateChunkMesh(Vector3i(position.x - 1, position.y, position.z));
    }
    if (neighborPositiveX.exists()) {
        updateChunkMesh(Vector3i(position.x + 1, position.y, position.z));
    }
    if (neighborNegativeZ.exists()) {
        updateChunkMesh(Vector3i(position.x, position.y, position.z - 1));
    }
    if (neighborPositiveZ.exists()) {
        updateChunkMesh(Vector3i(position.x, position.y, position.z + 1));
    }
}

void internalUpdateChunkMesh(Vector3i position) {

    // This will use a serialized package soon
    Chunk thisChunk = getChunk(Vector2i(position.x, position.z));
    // Get chunk neighbors
    // These do not exist by default
    Chunk neighborNegativeX = getChunk(Vector2i(position.x - 1, position.z));
    Chunk neighborPositiveX = getChunk(Vector2i(position.x + 1, position.z));
    Chunk neighborNegativeZ = getChunk(Vector2i(position.x, position.z - 1));
    Chunk neighborPositiveZ = getChunk(Vector2i(position.x, position.z + 1));

    generateChunkMesh(
        thisChunk,
        neighborNegativeX,
        neighborPositiveX,
        neighborNegativeZ,
        neighborPositiveZ,
        cast(ubyte)position.y
    );
    // As you can see as listed above, this is the same function but without the recursive update.
    // This could have intook a boolean, but it's easier to understand it as a separate function.
}

void processChunkMeshUpdateStack(){
    // See if there are any new chunk generations
    if (newStack.length > 0) {

        Vector3i poppedValue = newStack[0];
        newStack.popFront();
        // writeln("New Chunk Mesh: ", poppedValue);

        // Ship them to the chunk generator process
        internalGenerateChunkMesh(poppedValue);
    }
    
    // See if there are any existing chunk mesh updates
    if (updatingStack.length > 0) {

        Vector3i poppedValue = updatingStack[0];
        updatingStack.popFront();
        // writeln("Updating Chunk Mesh: ", poppedValue);

        // Ship them to the chunk generator process
        internalUpdateChunkMesh(poppedValue);
    }
}

while(!Window.externalShouldClose()) {
    writeln("I'm alive!");

    receive(
        // If you send this thread a bool, it continues, then breaks
        (bool kill) {}
    );
}




}// Thread spawner ends here