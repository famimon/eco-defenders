class Layer {
  PImage bkg;
  float id;

  Layer(float i, PImage bg) {
    id = i;
    bkg = bg;
  }

  void setup() {
    image(bkg, 0, 0, width, height);
  }


  void draw() {
    if (exploding && invaders[unluckyone].destroyed) {
      image(bkg, random(-5,5), random(-5,5), width+random(-5,5), height+random(-5,5));
    }
    else {
      image(bkg, 0, 0, width, height);
    }
    for (int i=0; i < MAX_INVADERS; i++) {
      if(id!=3) {
        // Check if any invader is shooting and if the beam is reaching a building
        if (invaders[i].layer == id && invaders[i].shooting) {
          float sx = invaders[i].shotX;
          float sy = invaders[i].shotY;
          if(getAlpha(int(sx), int(sy)) > 100) { 
            //Building
            setAlpha(int(sx), int(sy));
            invaders[i].shooting=false;
          } 
          else if (sy > height) {
            // Out of screen
            invaders[i].shooting=false;
          }
        }
      }
      // Finally update all invaders in layer
      if (invaders[i].layer == id) {
        invaders[i].update();
      }
    }
  }

  void setAlpha(int x, int y) {
    color c = color(0, 0, 0, 0);
    for (int i=x-3; i < x+3; i++) {
      for (int j=y-5; j < y+5; j++) {
        color c2 = color(0, 0, 0, int(random(0,100)));
        bkg.set(i, j, c);
        bkg.set(i+int(random(1,10)), j+int(random(1,10)), c2);
        bkg.set(i-int(random(1,10)), j+int(random(1,10)), c2);
      }
    }
  }

  float getAlpha(int x, int y) {
    // Returns the alpha value of a pixel in the background    
    color pixel = bkg.get(x, y);
    return alpha(pixel);
  }
}

