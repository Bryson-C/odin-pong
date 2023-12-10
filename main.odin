package pong;

import "core:fmt"
import time "core:time"
import rand "core:math/rand"
import rl "vendor:raylib"


Rect :: struct {
	x: i32,
	y: i32,
	w: i32,
	h: i32,
}

Paddle :: struct {
	rect: Rect,
}


draw_rect :: proc(r: Rect, color: rl.Color) {
	rl.DrawRectangle(r.x, r.y, r.w, r.h, color);
}


time_now :: proc() -> f64 {
	dur := time.Duration(time.tick_now()._nsec);
	return time.duration_milliseconds(dur);
}

rects_collide :: proc(a: Rect, b: Rect) -> bool {
	return (
		(a.x + a.w >= b.x && a.y + a.h >= b.y) && 
		(a.x <= b.x + b.w && a.y <= b.y + b.h)
	);
}

main :: proc() {

	
	start_time := time_now();
	
	rl.InitWindow(800, 600, "pong");
	window_width := rl.GetScreenWidth();
	window_height := rl.GetScreenHeight();
	
	defer {
		rl.CloseWindow();
	}


	rl.SetTargetFPS(60);

	paddle_one := Paddle{{10, (window_height/2) - 50, 30, 100}};
	paddle_two := Paddle{{window_width - (30 + 10), (window_height/2) - 50, 30, 100}};

	ball := Rect{(window_width/2) - 16,(window_height/2) - 16,32,32};
	ball_velx : i32 = -10;
	ball_vely : i32 = auto_cast rand.float32_range(-5, 5);

	fmt.printf("Ball Velocity: %i, %i", ball_velx, ball_vely);

	player_one_points, player_two_points := 0, 0;

	end_time := time_now();

	fmt.println(end_time-start_time);

	PADDLE_SPEED :: 5;

	for !rl.WindowShouldClose() {

		
		// player controls
		// player 1
		if rl.IsKeyDown(rl.KeyboardKey.UP) && paddle_two.rect.y > 0 do paddle_two.rect.y -= PADDLE_SPEED;
		if rl.IsKeyDown(rl.KeyboardKey.DOWN) && paddle_two.rect.y+paddle_two.rect.h < window_height do paddle_two.rect.y += PADDLE_SPEED;
		
		// player 2
		if rl.IsKeyDown(rl.KeyboardKey.W) && paddle_one.rect.y > 0 do paddle_one.rect.y -= PADDLE_SPEED;
		if rl.IsKeyDown(rl.KeyboardKey.S) && paddle_one.rect.y+paddle_one.rect.h < window_height do paddle_one.rect.y += PADDLE_SPEED;

		if rl.IsKeyDown(rl.KeyboardKey.ESCAPE) do break;

		// ball events
		// horizontal events
		if rects_collide(paddle_one.rect, ball) {
			ball.x = paddle_one.rect.x + paddle_one.rect.w;
			ball_velx *= -1;
			ball_vely = auto_cast rand.float32_range(-4, 4);
		}
		else if rects_collide(paddle_two.rect, ball) {
			ball.x = paddle_two.rect.x - ball.w;
			ball_velx *= -1;
			ball_vely = auto_cast rand.float32_range(-4, 4);
		}
		// vertical events
		if ball.y <= 0 {
			ball_vely *= -1;
		} else if ball.y + ball.h > window_height {
			ball_vely *= -1;
		}
		ball.x += ball_velx;
		ball.y += ball_vely;

		// player scores
		if ball.x + ball.w <= 0 {
			player_two_points += 1;
			ball_velx *= -1;
			ball = Rect{(window_width/2) - 16,(window_height/2) - 16,32,32};

			// reset paddles
			paddle_one = Paddle{{10, (window_height/2) - 50, 30, 100}};
			paddle_two = Paddle{{window_width - (30 + 10), (window_height/2) - 50, 30, 100}};
		} else if (ball.x > window_width) {
			player_one_points += 1;
			ball_velx *= -1;
			ball = Rect{(window_width/2) - 16,(window_height/2) - 16,32,32};

			// reset paddles
			paddle_one = Paddle{{10, (window_height/2) - 50, 30, 100}};
			paddle_two = Paddle{{window_width - (30 + 10), (window_height/2) - 50, 30, 100}};
		}


		rl.BeginDrawing();
		rl.ClearBackground(rl.DARKGRAY);
	
		rl.DrawText(rl.TextFormat("%i:%i", player_one_points, player_two_points), 0, 0, 20, rl.RAYWHITE);
		draw_rect(paddle_one.rect, rl.RED);
		draw_rect(paddle_two.rect, rl.RED);
		draw_rect(ball, rl.RED);


		rl.EndDrawing();

	}



}