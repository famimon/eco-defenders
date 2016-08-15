import org.openkinect.processing.*;
import hypermedia.video.*;
import ddf.minim.*;
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;
Minim minim;
AudioPlayer explosion, shot, attack, bomb;
Kinect kinect;
OpenCV opencv;


KinectManager kmanager;
Layer layer0, layer1, layer2, layer3;
PImage b, b2, g, g2, p, p2, l0, l1, l2, l3;
int MAX_INVADERS = 15;
boolean attacking=false;
boolean exploding = false;
Invader[] invaders = new Invader[MAX_INVADERS];
int rumbleDelay = 6000; // time for rumble in milliseconds
int unluckyone;
int explosion_time;
color color1= #EEB51B;
color color2= #CA0000;
int counter = 0;
int counter_threshold = 3;


void setup() {
  size(600, 200);
  oscP5 = new OscP5(this, 12000);

  myRemoteLocation = new NetAddress("192.168.1.245",12000);
  // Load the sounds
  minim = new Minim(this);
  explosion = minim.loadFile("Explosion.mp3", 2048);
  shot = minim.loadFile("Shot.mp3", 2048);
  bomb = minim.loadFile("Bomb.mp3", 2048);
  attack = minim.loadFile("Attack.mp3", 2048);

  // load layer backgrounds
  l0 = new PImage(width, height, 255);
  l1 = loadImage("layer1.png");
  l2 = loadImage("layer2.png");
  l3 = loadImage("layer3.png");

  // create layers
  layer0 = new Layer(0, l0);
  layer1 = new Layer(1, l1);
  layer2 = new Layer(2, l2);
  layer3 = new Layer(3, l3);

  // load invader's skins
  b = loadImage("blue_invader_skin1.png");
  b2 = loadImage("blue_invader_skin2.png");
  g = loadImage("green_invader_skin1.png");
  g2 = loadImage("green_invader_skin2.png");
  p = loadImage("pink_invader_skin1.png");
  p2 = loadImage("pink_invader_skin2.png");  

  // place invaders in random positions in layer0
  for (int i=0; i < MAX_INVADERS; i++) {
    switch(i%3) {
    case 0:
      invaders[i] = new Invader(random(0, width), random(0, height/2), 0, 10, "blue", b, b2);
      break;
    case 1:
      invaders[i] = new Invader(random(0, width), random(0, height/2), 0, 10, "green", g, g2);
      break;
    case 2:
      invaders[i] = new Invader(random(0, width), random(0, height/2), 0, 10, "pink", p, p2);
      break;
    }
  }

  // kinect handling
  kinect = new Kinect(this);
  opencv = new OpenCV(this);
  kinect.start();
  //  kinect.enableDepth(true);
  opencv.allocate(width, height);
  kmanager =  new KinectManager();
  // Start kinect manager thread
  kmanager.start();
}

void setBackground() {
  //Flickers background when Invader explodes
  explosion_time = invaders[unluckyone].destruction_time;
  if (exploding && invaders[unluckyone].destroyed) {
    for (int i=0; i<MAX_INVADERS; i++) {
      invaders[i].flee();
    }
    attack.pause();          
    attack.rewind();
    if (millis()%20==0) {
      background(color1);
    }
    else {      
      background(color2);
    }
    if (millis() - explosion_time > rumbleDelay) {
      exploding = false;
      explosion.rewind();
      explosion.pause();
    }
  }
  else {
    background(0);
  }
}


void draw() { 
  setBackground();
  layer0.draw();
  layer1.draw();
  layer2.draw();
  layer3.draw();
}

void updateCounter(){
  OscMessage myMessage = new OscMessage("/blinken");  
    myMessage.add(1); /* add an int to the osc message */
    /* send the message */
    oscP5.send(myMessage, myRemoteLocation);
    println("sent message: "+myMessage+" to "+myRemoteLocation);
    counter = 0;
}
void mousePressed() {
  while (!exploding) {
    unluckyone = int(random(0, MAX_INVADERS));
    if (!invaders[unluckyone].destroyed) {        
      invaders[unluckyone].destroy();
      shot.rewind();
      shot.play(); 
      exploding = true;
    }
  }
  if (++counter == counter_threshold) {
 updateCounter();   
  }
}

void stop() {  
  attack.close();
  explosion.close();
  shot.close();
  minim.stop();
  kmanager.quit();
  kinect.quit();
  super.stop();
}

