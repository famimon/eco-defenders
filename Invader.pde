class Invader {
  float x, y;  
  String type;  // Pink, Blue, Green
  float shotX, shotY;
  int layer;            // Layer number, from 0 to 3
  float SHOOT_PROBABILITY = 50; // the higher the value the less chances the Invader will shoot
  float SHOOT_TIMER = 5; // Amount in seconds until the Invader will attempt a shot
  float L0_SIZE = 10;
  float L1_SIZE = 20;
  float L2_SIZE = 40;
  float L3_SIZE = 60;  
  float DESTROY_SIZE = 60;
  float EXPLOSION_SIZE = 100;
  float xy_speed = .001;
  float z_speed = .05;
  float flee_speed = .5;
  float attack_speed = .3;
  float return_speed = .4;
  float explosion_speed = .6;
  float attack_factor = 100;
  float shot_speed = 1;
  float vx, vy;
  float scalar;
  float shotSize;
  PImage skin1, skin2;
  PImage shot1, shot2;
  PImage explosionImg;
  boolean moving_z = false;
  boolean destroyed = false;
  boolean shooting = false;
  boolean hit = false;
  boolean scared = false;
  int destruction_time = 120000;
  int destruction_timeDelay = 120000; // Amount in milliseconds before the invader regenerates
  float destX, destY;

  Invader(float cx, float cy, int l, float s, String t, PImage img1, PImage img2) {
    x = cx;
    y = cy;
    type = t;
    scalar = s;
    skin1 = img1;
    skin2 = img2;
    shot1 = loadImage("shot.png");   
    shot2 = loadImage("shot2.png");
    explosionImg = loadImage("explosion.png");
    layer = l;
  }

  void roam() {
    if (!moving_z) {
      destX = random(0, width);
      destY = random(0, height/2);
      float ax = x - destX;
      float ay = y - destY;
      vx = ax*xy_speed;
      vy = ay*xy_speed;
      layer = int(random(1, 3));
      moving_z = true;
    }
  }  

  void attack(float targetX, float targetY) {
    if(!scared && !hit) {
      float ax = x - targetX + random(-height,height);
      float ay = y - targetY + random(-height,height);
      vx = ax/attack_factor;
      vy = ay/attack_factor;
      layer = 3;
      moving_z = true;
      if (!attack.isPlaying() && !explosion.isPlaying()) {
        attack.play();
        attack.loop();
      }
    }
  }

  void scare(PImage diff, float amount) {
    if (layer==3 && !moving_z && !scared) {      
      attack.pause();
      boolean touched = false;
      float wx=0;
      float wy=0; // Coordinates of the nearest white pixel
      // Search for white pixels on the area 50 pixels around the Invader
      for (int j = int(y-scalar-50); j < int(y + scalar + 50); j++) {
        for (int i = int(x-scalar-50); i < int(x + scalar + 50); i++) {
          // if the pixel is in the screen and is white detect touch
          if  ((i > 0)&&(i < width)&&(j > 0)&&(j < height)&&(brightness(diff.pixels[i+j*width]) > 127)) {
            wx=i;
            wy=j;
            scared = true;
          }
        }
      }
      if (scared) { 
        float angle = atan2(wy, wx);
        float targetX = x + cos(angle) * scalar;
        float targetY = y + sin(angle) * scalar;
        float ax = (targetX - wx) * amount/1000000;
        float ay = (targetY - wy) * amount/1000000;
        vx -= ax;
        vy -= ay;
        layer = int(random(1, 3));
        moving_z = true;
      }
    }
  }


  void flee() {
    destX = random(0, width);
    destY = random(0, height/2);
    float ax = x - destX;
    float ay = y - destY;
    vx = ax*xy_speed*10;
    vy = ay*xy_speed*10;
    layer = 0;
    moving_z =true;
  }

  void destroy() {    
    layer=3;
    hit = true;
  }

  void regenerate() {
    layer=0;
    scalar=L0_SIZE;
    destroyed=false;
  }

  void shoot() {
    if (layer == 1 || layer == 2) {
      bomb.rewind();
      bomb.play();
      shotX=x;
      shotY=y;
      shotSize = scalar/2;
      shooting=true;
    }
  }

  void updateDepth() {

    switch (layer) {
    case 0:
      // Invader fleeing to background
      if (scalar > L0_SIZE) {
        scalar -= flee_speed;
      } 
      else {    
        moving_z=false;
      }  
      break;
    case 1:
      if (scared) {
        if (scalar > L1_SIZE) {
          scalar -= flee_speed;
        }
        else {
          moving_z = false;
          scared=false;
        }
      }
      else {
        // Invader roaming in between buildings
        if (scalar < L1_SIZE && scalar+z_speed < L1_SIZE) {
          // move from layer0 to layer1
          scalar += z_speed;
        } 
        else if (scalar > L1_SIZE && scalar-z_speed > L1_SIZE) {
          // move from layer2 to layer1
          scalar -= z_speed;
        }
        else {    
          moving_z=false;
        }
      }
      break; 
    case 2:
      if (scared) {
        if (scalar > L2_SIZE) {
          scalar -= flee_speed;
        }
        else {
          moving_z = false;
          scared=false;
        }
      }
      else {
        // Invader roaming in foreground
        if (scalar < L2_SIZE && scalar+z_speed < L2_SIZE) {
          // move from layer1 to layer2
          scalar += z_speed;
        } 
        else if (scalar > L2_SIZE && scalar-z_speed > L2_SIZE) {
          // move from layer3 to layer2
          scalar -= return_speed;
        }
        else {  
          moving_z=false;
        }
      }
      break; 
    case 3:
      // Invader attacking the viewer
      if (scalar < L3_SIZE) {
        scalar += attack_speed;
      } 
      else {          
        moving_z=false;
      }  
      break;
    }
  }

  void update() {
    // Only update the invader if not destroyed
    if (!destroyed) {
      PImage img, shotImg;
      // Alternates skin every second to animate the "legs" and the laser beam
      if (second()%2==0) {
        img = skin1;
        shotImg = shot1;
      } 
      else {
        img = skin2;
        shotImg = shot2;
      }
      if (hit) {
        if(!shot.isPlaying()){
        if (scalar < DESTROY_SIZE) {
          scalar += explosion_speed;
        } 
        else if (scalar < EXPLOSION_SIZE) {
//          shot.pause();
          explosion.play();
          img = explosionImg;
          scalar += explosion_speed;
        } 
        else {
          hit = false;
          destroyed = true;
          destruction_time = millis();
        }   
        }   
      } 
      else {  // Not hit
        // Move in Depth
        updateDepth();
        //  When reaching the edges a new destination is set
        if (((x+scalar > width) || (x-scalar < 0) || (y+scalar > height/2) || (y-scalar < 0) || (x == destX && y == destY))&& layer!=3 ) {         
          roam();
        }
        // Decide if shooting, every 5 seconds
        if (second()%SHOOT_TIMER==0 && !shooting) {
          if (int(random(0, SHOOT_PROBABILITY))==0) {
            shoot();
          }
        }
        // Update the bomb
        if (shooting) {
          shotY += shot_speed;
          image(shotImg, shotX, shotY, shotSize, shotSize);
        }
      }
      x -= vx;
      y -= vy;
      image(img, x, y, scalar, scalar);
    }
    else {
      if(millis()-destruction_time > destruction_timeDelay) {
        regenerate();
      }
    }
  }
}

