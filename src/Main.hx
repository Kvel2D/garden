import haxegon.*;
import haxe.ds.Vector;

using haxegon.MathExtensions;


@:publicFields
class Growing_Plant {
    var x = 0;
    var y = 0;
    var power = 0;
    var color = 0;

    function new() {}
}


@:publicFields
class Main {
    static inline var tilesize = 16;
    static inline var world_width = 20;
    static inline var view_spacing = 5;
    static inline var island_width = 10;
    static inline var island_x = 5;
    static inline var island_y = 6;
    static inline var view_height = 38;
    static inline var initial_height = 50;

    static inline var screen_width = (view_spacing + world_width * 2) * tilesize;
    static inline var screen_height = view_height * tilesize;

    var tutorial_timer = 0;
    static inline var tutorial_timer_max = 10 * 60;

    static var island_tiles = [
    "..........",
    "#.........",
    "##......##",
    "####...###",
    ];



    var growing_plants = new Array<Growing_Plant>();
    var left_canvas_cache = [for (y in 0...view_height) [for (x in 0...world_width) Col.BLUE]];
    var right_canvas_cache = [for (y in 0...view_height) [for (x in 0...world_width) Col.BLUE]];
    var map = [for (y in 0...initial_height) [for (x in 0...world_width) Col.BLUE]];
    var player_x = island_x;
    var plant_grow_timer = 0;
    static inline var plant_grow_timer_max = 10;
    var scrollview_y = 0;


    function new() {
        Text.setfont("pixelFJ8", 8);
        Text.change_size(20);
        Gfx.resize_screen(screen_width, screen_height, 1);


        Gfx.create_image("left_canvas", world_width * tilesize, view_height * tilesize);
        Gfx.create_image("right_canvas", world_width * tilesize, view_height * tilesize);


        Gfx.draw_to_image("left_canvas");
        Gfx.clear_screen(Col.BLUE);
        Gfx.draw_to_image("right_canvas");
        Gfx.clear_screen(Col.BLUE);
        Gfx.draw_to_screen();



        for (x in 0...island_tiles[0].length) {
            for (y in 0...island_tiles.length) {
                if (island_tiles[y].charAt(x) == '.') {
                    map[island_y - y][island_x + x] = Col.BROWN;
                }
            }
        }
    }

    function update_left_canvas() {
        Gfx.draw_to_image("left_canvas");

        for (y in 0...view_height) {
            for (x in 0...map[y].length) {
                if (left_canvas_cache[y][x] != map[y][x]) {
                    left_canvas_cache[y][x] = map[y][x];
                    Gfx.fill_box(x * tilesize, (view_height - y - 1) * tilesize, tilesize, tilesize, left_canvas_cache[y][x]);
                }
            }
        }

        Gfx.draw_to_screen();
    }

    function update_right_canvas() {
        Gfx.draw_to_image("right_canvas");

        for (y in 0...view_height) {
            for (x in 0...map[y].length) {
                if (right_canvas_cache[y][x] != map[y + scrollview_y][x]) {
                    right_canvas_cache[y][x] = map[y + scrollview_y][x];
                    Gfx.fill_box(x * tilesize, (view_height - y - 1) * tilesize, tilesize, tilesize, right_canvas_cache[y][x]);
                }
            }
        }

        Gfx.draw_to_screen();
    }


    function render() {
        Gfx.clear_screen(Col.BLUE);


        // Ground view
        // for (y in 0...view_height) {
        //     for (x in 0...map[y].length) {
        //         if (map[y][x] != Col.BLUE) {
        //             Gfx.fill_box(x * tilesize, (view_height - y - 1) * tilesize, tilesize, tilesize, map[y][x]);
        //         }
        //     }
        // }
        update_left_canvas();
        Gfx.draw_image(0, 0, "left_canvas");
        Gfx.fill_box(player_x * tilesize, (view_height - island_y - 2) * tilesize, tilesize, tilesize, Col.WHITE);


        // Scroll view
        // for (y in 0...view_height) {
        //     for (x in 0...map[y].length) {
        //         if (map[y + scrollview_y][x] != Col.BLUE) {
        //             Gfx.fill_box((x + world_width + view_spacing) * tilesize, (view_height - y - 1) * tilesize, tilesize, tilesize, map[y + scrollview_y][x]);
        //         }
        //     }
        // }
        update_right_canvas();
        Gfx.draw_image((world_width + view_spacing) * tilesize, 0, "right_canvas");
        

        if (scrollview_y < 8) {
            Gfx.fill_box((player_x + world_width + view_spacing) * tilesize, (view_height - island_y - 2 + scrollview_y) * tilesize, tilesize, tilesize, Col.WHITE);
        }


        if (tutorial_timer < tutorial_timer_max) {
            tutorial_timer++;
            Text.display(40, 10, "WASD + Spacebar", Col.WHITE);
        }
    }



    function update() {
        var left = Input.delay_pressed(Key.LEFT, 5) || Input.delay_pressed(Key.A, 5);
        var right = Input.delay_pressed(Key.RIGHT, 5) || Input.delay_pressed(Key.D, 5);
        var up = Input.delay_pressed(Key.UP, 5) || Input.delay_pressed(Key.W, 5);
        var down = Input.delay_pressed(Key.DOWN, 5) || Input.delay_pressed(Key.S, 5);

        if (left && !right) {
            player_x--;
            if (player_x < island_x) {
                player_x = island_x;
            }
        } else if (right && !left) {
            player_x++;
            if (player_x > island_x + island_width - 1) {
                player_x = island_x + island_width - 1;
            }
        }

        var scrollview_dy = 0;
        if (up && !down) {
            scrollview_dy = 1;
        } else if (down && !up) {
            scrollview_dy = -1;
        }

        scrollview_y += scrollview_dy;
        if (scrollview_y > map.length - 1 - view_height) {
            scrollview_y = map.length - 1  - view_height;
            scrollview_dy = 0;
        } else if (scrollview_y < 0) {
            scrollview_y = 0;
            scrollview_dy = 0;
        }

        if (scrollview_dy != 0) {
            // Shift canvas image
            Gfx.draw_to_image("right_canvas");
            Gfx.draw_image(0, scrollview_dy * tilesize, "right_canvas");
            Gfx.draw_to_screen();

            // Shift canvas cache
            if (scrollview_dy > 0) {
                // scroll up
                // shift all levels down, clear top level
                var shifted_level = right_canvas_cache.pop();
                for (i in 0...shifted_level.length) {
                    shifted_level[i] = Col.BLACK;
                }
                right_canvas_cache.push(shifted_level);
            } else {
                // scroll down
                // shift all levels up, clear bottom level
                var shifted_level = right_canvas_cache.shift();
                for (i in 0...shifted_level.length) {
                    shifted_level[i] = Col.BLACK;
                }
                right_canvas_cache.unshift(shifted_level);
            }
        }

        if (Input.just_pressed(Key.T)) {
            trace('cache: ${right_canvas_cache[0]}');
            trace('current: ${map[scrollview_y]}');
        }



        plant_grow_timer++;
        if (plant_grow_timer > plant_grow_timer_max) {
            plant_grow_timer = 0;

            for (plant in growing_plants) {
                if (Random.chance(30)) {
                    plant.x = plant.x + Random.pick([-1, 1]);
                    if (plant.x < 0) {
                        plant.x = 0;
                    } else if (plant.x > world_width - 1) {
                        plant.x = world_width - 1;
                    }
                }
                plant.y++;

                if (plant.y > map.length - 10) {
                    // Reached end of world, add more layers
                    for (y in 0...30) {
                        var t = (map.length - initial_height) / 200;
                        if (t > 0.9) {
                            t = 0.9;
                        }
                        var r = Std.int(Math.lerp(Col.r(Col.BLUE), Col.r(Col.BLACK), t));
                        var g = Std.int(Math.lerp(Col.g(Col.BLUE), Col.g(Col.BLACK), t));
                        var b = Std.int(Math.lerp(Col.b(Col.BLUE), Col.b(Col.BLACK), t));
                        var color = Col.rgb(r, g, b);
                        map.push([for (x in 0...world_width) color]);
                    }
                }

                // Power decreases only when growing over empty space, growing over other plants is free
                if (map[plant.y][plant.x] == Col.BLUE) {
                    plant.power--;
                }

                map[plant.y][plant.x] = plant.color;
            }


            var removed_plants = new Array<Growing_Plant>();
            for (plant in growing_plants) {
                if (plant.power <= 0) {
                    removed_plants.push(plant);
                }
            }
            for (plant in removed_plants) {
                growing_plants.remove(plant);
            }
        }


        // New plant
        if (Input.just_pressed(Key.SPACE)) {
            var new_plant = new Growing_Plant();
            new_plant.x = player_x;
            new_plant.y = island_y;
            new_plant.power = Random.int(20, 40);
            new_plant.color = Random.pick([Col.GREEN, Col.ORANGE, Col.PINK, Col.RED, Col.DARKGREEN, Col.LIGHTGREEN]);

            growing_plants.push(new_plant);
        }


        render();
    }
}
