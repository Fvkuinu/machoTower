import fisica.*;
FWorld world;

String[] borderPixels;
PImage[] machoImage = new PImage[26];
ArrayList<FPoly> polys = new ArrayList<FPoly>();
float scale = 3;
PImage img;
int number = 0;
int posX;
int posY = 0;
float theta = 0;
int scrollY = 0;
int ct = 0;
int setCT = 45;
int scene = 1;
int timeLimit = 4;
int countDown;
int timeLimit2 = 30+timeLimit;
int countDown2;
float takasa = 1000;
int searchLimit = 1;
float startMillis;
boolean textBack = true;
FBox box;
void setup() {
  size(600, 900);
  posX = width/2;
  imageMode(CENTER);

  for (int i = 0; i < machoImage.length; i++) {
    machoImage[i] = loadImage((i+1)+".png");
    machoImage[i].resize((int)(50*scale), (int)(50*scale));
  }
  Fisica.init(this);
  world = new FWorld();
  world.setGrabbable(false);
  //world.setEdges();
  background(255);
  box = new FBox(50, 50);
  FBox land = new FBox(500, 50);
  land.setPosition(width/2, height-100);
  land.setRestitution(0);
  land.setStatic(true);
  land.setFriction(1.1);
  world.add(land);
  startMillis = millis();
}

void draw() {
  if (scene == 1) {
    scene1();
  }
  if (scene == 2) {
    scene2();
  }
  if (scene == 3) {
    scene3();
  }
  if (scene == 4) {
    scene4();
  }
}

void scene1() {
  background(255);
  textSize(40);
  textAlign(CENTER, CENTER);
  int ms = (int)(millis()/1000.0-startMillis/1000.0);
  fill(0);
  countDown = timeLimit - ms;
  if (countDown <= 0) {
    scene = 2;
  } else if (countDown <= 1) {
    text("START!", width/2, height/2);
    return;
  } else {
    text(countDown-1, width/2, height/2);
  }
}
void scene2() {
  translate(0, scrollY);
  background(255);
  pushMatrix();
  translate(posX, 100-scrollY);
  rotate(radians(theta));
  imageMode(CENTER);
  image(machoImage[number], 0, 0);
  imageMode(CORNER);
  popMatrix();
  world.step();
  world.draw();
  calCT();
  resetMatrix();
  textSize(30);
  textAlign(CENTER, CENTER);
  int ms = (int)(millis()/1000.0-startMillis/1000.0);
  fill(0);
  countDown = timeLimit2 - ms;
  if (countDown < 0) {
    scene = 3;
  } else {
    text(countDown, width-60, 0+60);
  }
}

void scene3() {
  background(255);
  world.step();
  world.draw();
  for(int i = 0; i < polys.size(); i++){
    if(polys.get(i).getY() > 775){
      continue;
    }
    if(sq(polys.get(i).getVelocityX())+sq(polys.get(i).getVelocityY()) > 50){
      return;
    }
  }
  boolean bbb = true;
  int search = 1;
  while (bbb) {
    if (polys.size()-search < 0) {
      break;
    }
    FBody b = polys.get(polys.size()-search);
    ArrayList<FContact>contacts=b.getContacts();
    if (contacts.size() == 0) {
    } else {
      searchLimit = search;
      bbb=false;
    }
    search++;
  }
  for (int i = 0; i <= polys.size()-searchLimit; i++) {
    if (takasa > polys.get(i).getY()) {
      takasa = polys.get(i).getY();
    }
  }
  scene = 4;
}

void scene4() {
  rectMode(CENTER);
  fill(255, 80);
  noStroke();
  if(textBack){
    rect(width/2, height/2, 400, 200);
    textBack = false;
  }
  textSize(60);
  textAlign(CENTER, CENTER);
  fill(0);
  text("SCORE", width/2, height/2-60);
  text((775-takasa+90)/100.0+"m", width/2, height/2);
}

void calCT() {
  if (ct > 0) {
    ct--;
  }
}
void mousePressed() {
}

void keyPressed() {
  if (!(scene == 2)) {
    return;
  }
  ddd:
  if (key == ENTER) {
    if (ct > 0) {
      break ddd;
    }
    borderPixels = loadStrings((number+1)+".txt");  
    for (int i=0; i<borderPixels.length; i++) {
      if (borderPixels[i].matches("beginShape")) {
        polys.add(new FPoly());     
        //polys.get(polys.size()-1).setStaticBody(true);
      } else if (borderPixels[i].matches("endShape")) {
        imageMode(CORNER);
        polys.get(polys.size()-1).attachImage(machoImage[number]);
        polys.get(polys.size()-1).setRestitution(0);
        polys.get(polys.size()-1).setPosition(posX, 100-scrollY);
        polys.get(polys.size()-1).setRotation(radians(theta));
        polys.get(polys.size()-1).setVelocity(0, 70);
        polys.get(polys.size()-1).setFriction(1.09);
        world.add(polys.get(polys.size()-1));
        ct = setCT;
      } else if (borderPixels[i].matches("beginContour") || borderPixels[i].matches("endContour")) {
        continue;
      } else {
        int x = int(borderPixels[i].split(",")[0]);
        int y = int(borderPixels[i].split(",")[1]);

        polys.get(polys.size()-1).vertex((x-35)*scale, (y-35)*scale);
      }
      //poly.vertex(, );
      //poly.vertex(1, 1);
    }
  }
  if (keyCode == CONTROL) {
    theta += 7;
  }
  if (keyCode == SHIFT) {
    theta -= 7;
  }
  switch(keyCode) {
  case UP:
    scrollY -= 10;
    break;
  case DOWN:
    scrollY += 10;
    break;
  case LEFT:
    posX -= 5;
    break;
  case RIGHT:
    posX += 5;
    break;
  }
  for (int i=0, c=65, C=97; i < 26; i++) {
    if (keyCode == c || keyCode == C) {
      number = c-65;
    }
    c++;  
    C++;
  }
}
