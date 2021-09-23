ArrayList<Projectile> bullets;
int maxBullets = 6;

ArrayList<Mover> flock;

int flockSize = 20;

int numScore = 0;
int numLives = 3;
int numLevel = 1;

int cooldown = 0;

Vaisseau v;
Mover toRemove;

Text score;
Text lives;
Text level;

import processing.sound.*;

SoundFile file;
  //replace the sample.mp3 with your audio file name here
  String audioName = "lego-yoda-death-sound.mp3";
  String path;

void setup() {
  fullScreen(P2D);
  
    //size(800, 600);
  
  reset();
  
  score = new Text(0,0);
  lives = new Text(displayWidth -100, 0);
  level = new Text(displayWidth -100, 30);
  
}

void reset()
{
  currentTime = millis();
  previousTime = millis();
  
  bullets = new ArrayList<Projectile>();
  v = new Vaisseau();
  v.location.x = width / 2;
  v.location.y = height / 2;
  
  flock = new ArrayList<Mover>();
  
  for (int i = 0; i < flockSize; i++) {
    Mover m;
    do{
    m = new Mover(new PVector(random(0, width), random(0, height)), new PVector(random (-2, 2), random(-2, 2)));
    } while(PVector.dist(m.location, v.location) < (v.getSize()*10) );
    m.fillColor = color(random(255), random(255), random(255));
    flock.add(m);
  }
}

int currentTime;
int previousTime = 0;
int deltaTime;

void draw() {
  currentTime = millis();
  deltaTime = currentTime - previousTime;
  previousTime = currentTime;
  
  update(deltaTime);
  render();
}

PVector thrusters = new PVector(0, -0.02);

void update (float deltaTime) {
  
  for ( Projectile p : bullets) {
    p.update(deltaTime);
    for (Mover m : flock) {
      if (collisionCheckProjectile(m, p, m.r*2)==true)
      break;
    }
  }
  
    for (Mover m : flock) {
    m.flock(flock);
    m.update(deltaTime);
    collisionCheckVaisseau(v, m, m.r, v.getSize());
    
    }
  
  if (keyPressed) {
    switch (key) {
      case 'w':
        v.thrust();
        break;
      case 'a':
      v.pivote(-.03);
        break;
      case 'd':
      v.pivote(0.03);
        break;
    }
  }
  v.update(deltaTime);

}


void render() {
  background(0);
  
  v.display();
  for ( Projectile p : bullets) {
    p.display();
  }
  
  for (Mover m : flock) {
    m.display();
  }
  
  score.display("Score : ", numScore);
  lives.display("Lives : ", numLives);
  level.display("Level : ", numLevel);
  
  
}

void keyPressed() {
  if (keyPressed) {
    switch (key) {
      case ' ':
      fire (v);
      break;
      case 'r':
      flockSize=20;
      numLives=3;
      numScore=0;
      reset();
      break;
    }
  }
}

void fire(GraphicObject m) {
  v = (Vaisseau)m;
  
  if (bullets.size() < maxBullets) {
    Projectile p = new Projectile();
    
    p.location = v.getVaisseauTip().copy();
    p.topSpeed = 6;
    p.velocity.x = cos(v.getHeading()-HALF_PI) * p.topSpeed;
    p.velocity.y = sin(v.getHeading()-HALF_PI) * p.topSpeed;
   
    p.activate();
    
    bullets.add(p);
  } else {
    for ( Projectile p : bullets) {
      if (!p.isVisible) {
        p.location.x = v.getVaisseauTip().x;
        p.location.y = v.getVaisseauTip().y;
        p.velocity.x = cos(v.getHeading()-HALF_PI) * p.topSpeed;
        p.velocity.y = sin(v.getHeading()-HALF_PI) * p.topSpeed;
        p.activate();
        break;
      }
    }
  }
  
}


void keyReleased() {
    switch (key) {
      case 'w':
        v.noThrust();
        break;
    }  
}

boolean collisionCheckProjectile(GraphicObject g, GraphicObject p, float size) {
  
  if(PVector.dist(g.location, p.location) < size)
  {
    flock.remove(g);
    numScore++;
    if(numScore==100)
    {
      numScore = 0;
      numLives++;
    }
    
    if(flock.size()==0)
    {
      numLevel++;
      flockSize = flockSize + 5;
      reset();
    }
    return true;
  }
  return false;
  
}

boolean collisionCheckVaisseau(GraphicObject g, GraphicObject m, float msize, float gsize) {
  if(PVector.dist(g.location, m.location) < msize + gsize)
  {
    if(numLives==0)
    {
      flockSize = 20;
      numLives = 3;
      numScore = 0;
      numLevel = 0;
      cooldown = 0;
      reset();
    }
    else
    {
      if (cooldown <= 0) {
        numLives--;
        cooldown = 2000;
        path = sketchPath(audioName);
    file = new SoundFile(this, path);
    file.play();
      }
    }
    return true;
  }

  cooldown--;
   return false;
   
    }
