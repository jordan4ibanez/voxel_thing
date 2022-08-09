import std.stdio;

import raylib;
import entity.mob.mob;
import entity.mob.mob_definitions.zombie;
import entity.mob.mob_factory;
import entity.player.player;
import entity.player.player_factory;
import world.chunk;
import world.chunk_factory;
import world.chunk;
import world.world_generation;
import raymath;
import delta_time;
import graphics.block_graphics;


void main(string[] args) {

    if (args.length > 1 && args[1] == "--server") {
        // Server loop
        bool serverShouldClose = false;

        while (!serverShouldClose) {
            calculateDelta();
            writeln("wow this is a server! ", getDelta());
        }
    } else {
        //WorldGenerator.generate(128,0);

        /*
        // Debug mobs
        MobFactory.spawnMob(new Zombie());
        MobFactory.debugFactory();

        // Debug players
        PlayerFactory.spawnPlayer(new Player("singleplayer"));
        PlayerFactory.debugFactory();


        ChunkFactory.newChunkGeneration(0,0);
        ChunkFactory.processStack();
        ChunkFactory.debugFactoryContainer();

        //Chunk chunky = new Chunk("default", Position2I(0,0));
        for ( int i = 0; i < 32_768; i++ ) {
            chunky.runADebug(i);
        }
        */



        InitWindow(1280,720, "Voxel Thing");
        SetTargetFPS(60);

        // Debug camera
        Camera camera = Camera(
            Vector3(5,2,0),
            Vector3(0.0,0.0,0.0),
            Vector3(0,1,0),
            73,
            CameraProjection.CAMERA_PERSPECTIVE
        );

        SetCameraMode(camera, CameraMode.CAMERA_FIRST_PERSON);

        // Testing the block graphics registration
        // This will get called automatically when blocks are registered
        testRegister();

        // Generating a grass block debug
        Model testingModel = LoadModelFromMesh(testAPI(1));
        Texture testingTexture = LoadTexture("textures/world_texture_map.png");
        testingModel.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = testingTexture;



        // Client loop
        while(!WindowShouldClose()) {


            UpdateCamera(&camera);
            // Delta calculation must come first
            calculateDelta();

            BeginDrawing();

            ClearBackground(Colors.RAYWHITE);

            BeginMode3D(camera);

            

            DrawCube(Vector3(0,0,-1),1,1,1,Colors.BLACK);

            DrawModel(testingModel,Vector3(0,0,1),1,Colors.WHITE);


            EndMode3D();

            EndDrawing();
        }

        CloseWindow();
    }
}
