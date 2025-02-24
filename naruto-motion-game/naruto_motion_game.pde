import processing.video.*;
import java.util.*;
import processing.sound.*;

PImage background;
boolean displayPowerUpText;

// Naruto
PImage body;
PImage right_hand;
PImage left_hand;
PImage right_leg;
PImage left_leg;
int naruto_right;
int naruto_left;
PVector narutoCenter;
boolean isNarutoPoweredUp = false;
int powerUpDuration = 300; 
int gameStartTime;
PVector narutoBodyCenter, narutoRightHandCenter, narutoLeftHandCenter, narutoRightLegCenter, narutoLeftLegCenter;

// side-characters
/// sasuke 
PImage sasuke;
int sasukeHurtCount = 0;
PVector sasukePosition = new PVector(100, height - 100);
boolean isShootingRasengan = false;
PImage rasengan;
PVector rasenganPosition = new PVector(-100, -100); 
float rasenganSpeed = 8;
int lastRasenganTime=0;
boolean showHitMessage = false;
int hitMessageTimer = 0;
PVector hitMessagePosition = new PVector(0, 0);
boolean rasenganHit = false;


PImage kunai;
PVector kunaiPosition = new PVector(-100, -100); 
float kunaiSpeed = 6.5;
int lastKunaiTime = 0; 
boolean isShootingKunai; 
ArrayList<PVector> kunaiPositions = new ArrayList<PVector>();

PImage kurama;
PVector kuramaPosition = new PVector(0, 0); 
boolean needNewTarget = true;
PVector kuramaTargetPosition = new PVector(0, 0); 

PImage fire;
PVector firePosition = new PVector(0,0);

PImage blood;
int bloodDisplayDuration = 3000; // 3 seconds in milliseconds
boolean showBlood = false;
int bloodTimer = 0;


int rasenganTimer = 0;
int narutoHealth = 100;
int sasukeHealth = 100;
int score = 0;

int p = 7;
int radius = 1;
int x_adjust = 100;
int y_adjust = -140;
PImage curr_frame;
int frame_num = 0;
boolean frames_loaded = true;

Movie monkey_movie;

ArrayList<Coord<Integer, Integer, Integer>> five_red_points = new ArrayList<>(5);
ArrayList<Coord<Integer, Integer, Integer>> curr_hands = new ArrayList<>(2);
ArrayList<Coord<Integer, Integer, Integer>> curr_legs = new ArrayList<>(2);

SoundFile naruto_song;
SoundFile hurt;
SoundFile narutooo;
SoundFile dattebayo;
SoundFile pain_theme;
SoundFile sasukeee;
SoundFile naruto_sasuke;

public class Coord<D, X, Y> {
  public D points;
  public X x;
  public Y y;
  
  public Coord(D points, X x, Y y) {
    this.points = points;
    this.x =x;
    this.y=y;
  }
}




void setup() {
  
  size(1127,634);
  
  background = loadImage("../images/konoha.jpg");
 
  // naruto 
  body = loadImage("../images/naruto-body.png");
  right_hand = loadImage("../images/right-hand.png");
  left_hand = loadImage("../images/left-hand.png");
  right_leg = loadImage("../images/right-leg.png");
  left_leg = loadImage("../images/left-leg.png");
  
  sasuke = loadImage("../images/sasuke-1.png");
  rasengan = loadImage("../images/rasengan.png");
  kunai = loadImage("../images/kunai-down.png");
  kurama = loadImage("../images/kurama.png");
  fire =  loadImage("../images/fire.png");
  blood = loadImage("../images/blood.png");
  
  naruto_song = new SoundFile(this, sketchPath("../sounds/Naruto Main Theme - EPIC VERSION.mp3"));
  naruto_song.play();
  hurt = new SoundFile(this, sketchPath("../sounds/ough.wav"));
  hurt.amp(0.5);
  narutooo = new SoundFile(this, sketchPath("../sounds/narutooo.wav"));
  
  monkey_movie = new Movie(this, sketchPath("../Opt1-MarionetteMovements.mov")); 
  monkey_movie.frameRate(30);
 
  monkey_movie.loop();
  monkey_movie.volume(0);
 
  gameStartTime = millis();
}


void drawBackground() {
   image(background, 0, 0, 1127, 634);
}


int whitePixelScore(color[] grid) {
  int score = 0;
  for (color pix: grid) {
    if (red(pix) == 255 && green(pix)== 255 && blue(pix) == 255) {
      score++;
    }
  }
  return score;
}


void makeBinaryImage() {
   curr_frame.loadPixels();
   
   for (int i = 0; i < curr_frame.width* curr_frame.height; i++) {
       color pix = curr_frame.pixels[i];
    
       if (red(pix) > 150 && green(pix) >40 && green(pix) < 200 && blue(pix) > 30
        && blue(pix) < 125) {
          curr_frame.pixels[i] = color(255,255,255);
        } 
        else {
           curr_frame.pixels[i] = color(0,0,0);
        }
    }
   curr_frame.updatePixels();
} 

private int[] findExtremePoints(ArrayList<Coord<Integer, Integer, Integer>> points, boolean findTop) {
    int[] indices = {0, 1}; 
    for (int i = 2; i < points.size(); i++) {
        Coord<Integer, Integer, Integer> currentPoint = points.get(i);
        Coord<Integer, Integer, Integer> firstExtreme = points.get(indices[0]);
        Coord<Integer, Integer, Integer> secondExtreme = points.get(indices[1]);
        
        // comp y values based on whether we're finding top or bottom points
        if ((findTop && currentPoint.y < firstExtreme.y) || (!findTop && currentPoint.y > firstExtreme.y)) {
            indices[1] = indices[0]; 
            indices[0] = i; 
        } else if ((findTop && currentPoint.y < secondExtreme.y) || (!findTop && currentPoint.y > secondExtreme.y)) {
            indices[1] = i; 
        }
    }
    return indices;
}

void updateHandsAndLegs() {
    curr_hands.clear();
    curr_legs.clear();

    // find top 2 points for hands
    int[] handIndices = findExtremePoints(five_red_points, true);
    curr_hands.add(five_red_points.get(handIndices[0]));
    curr_hands.add(five_red_points.get(handIndices[1]));

    // remove the hand points 
    if (handIndices[0] > handIndices[1]) {
        five_red_points.remove(handIndices[0]);
        five_red_points.remove(handIndices[1]);
    } else {
        five_red_points.remove(handIndices[1]);
        five_red_points.remove(handIndices[0]);
    }

    // find bottom two points for legs
    int[] legIndices = findExtremePoints(five_red_points, false);
    curr_legs.add(five_red_points.get(legIndices[0]));
    curr_legs.add(five_red_points.get(legIndices[1]));

}



void draw() {  
  
  surface.setTitle(String.format("Naruto vs. Cursed Sasuke"));

  //System.out.println(dist(511.34616, 362.49582, 231, 358));
  if (monkey_movie.available()) {
     
    if (frames_loaded == false) {
      monkey_movie.read();
      monkey_movie.save(sketchPath("") + "frames/" + (frame_num) + ".tif");
      image(monkey_movie,0,0);
      frame_num++;
    } else {
      ArrayList<Coord<Integer, Integer, Integer>> blockScores = new ArrayList<>();

      frame_num = frame_num%948;
      //if (frame_num >= 948) {
      //  frame_num = 0; 
      //}
  
      curr_frame = loadImage(sketchPath("") + "frames/"+ (frame_num) + ".tif");
      makeBinaryImage();
      
      drawBackground();
      
      for (int fx = 0; fx < curr_frame.width; fx += p) {
        for (int fy = 0; fy < curr_frame.height; fy += p) {
            color[] grid = new color[p*p];
            
            int index = 0; 
            for (int bx = fx; bx < fx + p; bx++) {
              for (int by = fy; by < fy + p; by++) {
                  int loc = fx + (fy*curr_frame.width);
                  if (loc >= 0) {
                    color c = curr_frame.pixels[loc];
                    grid[index]= c;
                  }
                  index++;
              }
             }
             
            int score = whitePixelScore(grid);
            blockScores.add(new Coord(score, fx, fy));
        }
      }
      
      blockScores.sort((a, b) -> Integer.compare(b.points, a.points));
      
      five_red_points.clear();
      for (int i=0; i<5; i++) {
        //System.out.println(blockScores.get(i));
        five_red_points.add(blockScores.get(i));
      }
      
      
      updateHandsAndLegs();
      

      if (isNarutoPoweredUp) {
        powerUpDuration--;
        if (powerUpDuration <= 0) {
          isNarutoPoweredUp = false;
        }
      }
      drawNaruto();
      drawSasuke();
      drawKurama();
      drawKunais();
      
      //System.out.println(isShootingRasengan==true);
     if (showHitMessage) {
       if (millis() - hitMessageTimer < 1500) { 
          fill(255, 0, 0); 
          textSize(32);
          text("Hit!", hitMessagePosition.x, hitMessagePosition.y);
        } else {
          showHitMessage = false; 
        }
        
     }

      if (millis() - lastRasenganTime > 10000) {
          isShootingRasengan = true;
      }
      
      shootRasengan();

      checkGameEnd();
      displayTimer();
      displayHealth();
      monkey_movie.read();
      frame_num++;
    }
  }
  
}



void drawNaruto(){
  if (curr_hands.get(0).x < curr_hands.get(1).x) {
    naruto_left = ((int)curr_hands.get(0).x + x_adjust + (int)five_red_points.get(0).x + x_adjust) / 2;
    naruto_right = (((int)curr_hands.get(1).x+ x_adjust + (int)five_red_points.get(0).x + x_adjust) / 2) + 125;
    
     narutoLeftHandCenter = new PVector(naruto_left + (left_hand.width * 0.25), (int)curr_hands.get(0).y + (left_hand.height * 0.3) + y_adjust-100);
    narutoRightHandCenter = new PVector(naruto_right + (right_hand.width * 0.25), (int)curr_hands.get(1).y + (right_hand.height * 0.3) + y_adjust-100);
    image(left_hand, naruto_left, (int)curr_hands.get(0).y + (left_hand.height * 0.6) + y_adjust-100, left_hand.width * 0.5, left_hand.height * 0.5);
    image(right_hand, naruto_right, (int)curr_hands.get(1).y+ (right_hand.height * 0.6) + y_adjust-100, right_hand.width * 0.5, right_hand.height * 0.5);
  } else {
    naruto_left = ((int)curr_hands.get(1).x + x_adjust + (int)five_red_points.get(0).x  + x_adjust) / 2;
    naruto_right = (((int)curr_hands.get(0).x + x_adjust + (int)five_red_points.get(0).x + x_adjust) / 2) + 125;
    image(left_hand, naruto_left, (int)curr_hands.get(1).y + (left_hand.height * 0.6) + y_adjust-100, left_hand.width * 0.5, left_hand.height * 0.5);
    image(right_hand, naruto_right, (int)curr_hands.get(0).y + (right_hand.height * 0.6) + y_adjust-100, right_hand.width * 0.5, right_hand.height * 0.5);
    narutoLeftHandCenter = new PVector(naruto_left + (left_hand.width * 0.25), (int)curr_hands.get(1).y + (left_hand.height * 0.3) + y_adjust-100);
    narutoRightHandCenter = new PVector(naruto_right + (right_hand.width * 0.25), (int)curr_hands.get(0).y + (right_hand.height * 0.3) + y_adjust-100);

  }
  
  if (curr_legs.get(0).x < curr_legs.get(1).x) {
     narutoLeftLegCenter = new PVector(((int)curr_legs.get(0).x + x_adjust-20 + (int)five_red_points.get(0).x + 110 + x_adjust) / 2 + (left_leg.width * 0.25), (int)curr_legs.get(0).y + y_adjust+370 + (left_leg.height * 0.25));
      narutoRightLegCenter = new PVector((((int)curr_legs.get(1).x + x_adjust-20 + (int)five_red_points.get(0).x + x_adjust) / 2) + 100 + (right_leg.width * 0.25), (int)curr_legs.get(1).y + y_adjust +365 + (right_leg.height * 0.25));
    image(left_leg, ((int)curr_legs.get(0).x + x_adjust-20 + (int)five_red_points.get(0).x + 110 + x_adjust) / 2, (int)curr_legs.get(0).y + y_adjust+370, left_leg.width * 0.5, left_leg.height * 0.5);
    image(right_leg, (((int)curr_legs.get(1).x + x_adjust-20 + (int)five_red_points.get(0).x + x_adjust) / 2) + 100, (int)curr_legs.get(1).y + y_adjust+365, right_leg.width * 0.5, right_leg.height * 0.5);
  } else {
    narutoLeftLegCenter = new PVector(((int)curr_legs.get(1).x + x_adjust-20 + (int)five_red_points.get(0).x + 110 + x_adjust) / 2 + (left_leg.width * 0.25), (int)curr_legs.get(1).y + y_adjust+370 + (left_leg.height * 0.25));
    narutoRightLegCenter = new PVector((((int)curr_legs.get(0).x + x_adjust-20 + (int)five_red_points.get(0).x + x_adjust) / 2) + 100 + (right_leg.width * 0.25), (int)curr_legs.get(0).y + y_adjust +365 + (right_leg.height * 0.25));
    image(left_leg, ((int)curr_legs.get(1).x + x_adjust-20 + (int)five_red_points.get(0).x + 110 + x_adjust) / 2, (int)curr_legs.get(1).y + y_adjust+370, left_leg.width * 0.5, left_leg.height * 0.5);
    image(right_leg, (((int)curr_legs.get(0).x + x_adjust-20 + (int)five_red_points.get(0).x + x_adjust) / 2) + 100, (int)curr_legs.get(0).y + y_adjust +365, right_leg.width * 0.5, right_leg.height * 0.5);
  }
  
  image(body, (int)five_red_points.get(0).x +x_adjust+65, (int)five_red_points.get(0).y-(body.height * 0.25)+270, body.width * 0.5, body.height * 0.5);
  narutoBodyCenter = new PVector((int)five_red_points.get(0).x + x_adjust + 65 + (body.width * 0.25), (int)five_red_points.get(0).y - (body.height * 0.25) + 270 + (body.height * 0.25));

}

void drawSasuke() {
   image(sasuke, sasukePosition.x, sasukePosition.y, sasuke.width * 0.4, sasuke.height * 0.4);
}


void drawKurama(){

  float movementSpeed = 2; 
  int narutoCenterX = (int)five_red_points.get(0).x +x_adjust+65;
  int narutoCenterY = (int)(five_red_points.get(0).y -(body.height * 0.25))+270;

  if (needNewTarget) {
    kuramaTargetPosition.x = random(0, width - kurama.width * 0.2);
    kuramaTargetPosition.y = random(0, height - kurama.height * 0.2);
    needNewTarget = false;
  }
  
  kuramaPosition.x += (kuramaTargetPosition.x - kuramaPosition.x) * movementSpeed / frameRate;
  kuramaPosition.y += (kuramaTargetPosition.y - kuramaPosition.y) * movementSpeed / frameRate;

  
  if (dist(kuramaPosition.x, kuramaPosition.y, kuramaTargetPosition.x, kuramaTargetPosition.y) < movementSpeed) {
    needNewTarget = true;
  }
  
  image(kurama, kuramaPosition.x, kuramaPosition.y, kurama.width * 0.2, kurama.height * 0.2);
    
  float touchThreshold = 250;
  //System.out.println("kurama x: " + kuramaPosition.x);
  //System.out.println("kurama y: " + kuramaPosition.y);
  //System.out.println("naruto x: " + narutoCenterX);
  //System.out.println("naruto y: " + narutoCenterY);

  if (dist(kuramaPosition.x, kuramaPosition.y, narutoCenterX, narutoCenterY) < touchThreshold) {
      if (narutoHealth < 100) narutoHealth++;
      
      fill(255, 0, 0);
      textSize(32); 
      textAlign(CENTER); 
      text("Naruto is powering up!", width / 2, 50); 
      image(fire, narutoBodyCenter.x-270, narutoBodyCenter.y-80, fire.width * 0.8, fire.height * 0.8);

  }
  
}



void keyPressed() {
  if (key == ' ') {
    shootKunai(); 
  }
 
  if (keyCode == LEFT) {
    // move sasuke left
    if (sasukePosition.x >= 10.0) {
      sasukePosition.x -= 10;
    }
  }
  if (keyCode == RIGHT) {
    // move sasuke right
    if (sasukePosition.x <= 710.0) {
       sasukePosition.x += 10; 
    }
  }
  
}



void displayHealth(){  
  fill(255); 
  textSize(20);
  text("Naruto Health: " + narutoHealth, 100, width / 2);
  text("Sasuke Health: " + sasukeHealth, 100, width / 2+30);
}


PVector getNarutoCenter() {
  float centerX = (int)five_red_points.get(0).x + x_adjust + (body.width * 0.5 * 0.5);
  float centerY = (int)five_red_points.get(0).y + (body.height * 0.5 * 0.5) + 270;
  return new PVector(centerX, centerY);
}


void shootRasengan() {
  rasenganTimer++;
  narutoCenter = getNarutoCenter();

  if (isShootingRasengan) {
    if (rasenganPosition.x == -100 && rasenganPosition.y == -100) { 
      rasenganPosition.set(narutoBodyCenter.x-70, narutoBodyCenter.y-250); 
     
    }

    rasenganPosition.y -= rasenganSpeed; // move up 
    
    //System.out.println("Rasengan pos:" + rasenganPosition.x + " " + rasenganPosition.y);
    //System.out.println("Sasuke pos:" + sasukePosition.x + " " + sasukePosition.y);
    //float diff = dist(rasenganPosition.x+100, rasenganPosition.y+200, 
    //sasukePosition.x , sasukePosition.y);
    
    float sasukeRight = sasukePosition.x + (sasuke.width * 0.4)/2;
    float sasukeBottom = sasukePosition.y + (sasuke.height * 0.4)/2;
    float rasenganRadius = (rasengan.width * 0.2) / 2;
    
    // find closest point to the Rasengan's center within the Sasuke's rectangle
    float closestX = constrain(rasenganPosition.x+100, sasukePosition.x, sasukeRight);
    float closestY = constrain(rasenganPosition.y+200, sasukePosition.y, sasukeBottom);
    
    // calculate the dist btw the center of Rasengan and closest point
    float distanceX = rasenganPosition.x+100 - closestX;
    float distanceY = rasenganPosition.y+200 - closestY;

    if (rasenganPosition.y < 0 && distanceX * distanceX + distanceY * distanceY < rasenganRadius * rasenganRadius ){
      if (rasenganPosition.x- sasukePosition.x < ((sasuke.width*0.4)/2)) {
          //System.out.println("HITTTTTTTTTTTTTTTTTTTTTTTTTTT");
          //System.out.println( "diff is : " + abs(rasenganPosition.x- sasukePosition.x));
          decrementSasukeHealth();
          rasenganHit = true;
      }
 
    }
    
    else if (rasenganPosition.y < 0 && sasukePosition.x <= rasenganPosition.x) {
        if (sasukePosition.x + ((sasuke.width*0.4)/2) >= rasenganPosition.x) {
          //System.out.println("EREEEEEEEEEEEEEEEEEEEE");
          float x = sasukePosition.x + ((sasuke.width*0.4)/2);
          //System.out.println( "x : " + x);
          decrementSasukeHealth();
          rasenganHit = true;
        
        }
      }

    if (rasenganPosition.y < -200 || !isShootingRasengan) {
      isShootingRasengan = false;
      rasenganHit = false;
      rasenganPosition.set(narutoBodyCenter.x-70, narutoBodyCenter.y-250); 
    } 
    image(rasengan, rasenganPosition.x +100, rasenganPosition.y+200, rasengan.width * 0.2, rasengan.height * 0.2);
    
  }
}


void decrementSasukeHealth(){
  if (rasenganHit == false) {
    sasukeHealth -= 5;
     
    if (sasukeHurtCount % 4 == 0) {
 
      narutooo.amp(0.5);
      narutooo.play();
    } else {
      hurt.play();
    }
    
    sasukeHurtCount++;
    showHitMessage = true;
    hitMessageTimer = millis();
    hitMessagePosition.set(rasenganPosition.x+100, rasenganPosition.y+200);
    
  }
}


void drawKunais() {
  for (int i =0; i < kunaiPositions.size(); i++) {
     image(kunai, kunaiPositions.get(i).x,  kunaiPositions.get(i).y, kunai.width * 0.05, kunai.height * 0.05);
      kunaiPositions.get(i).y += kunaiSpeed; // Move the Kunai downwards
      checkKunaiCollision(kunaiPositions.get(i));
  }
  if (showBlood) {
    if (millis() < bloodTimer + bloodDisplayDuration) {
      image(blood, 100, 100, blood.width * 0.6, blood.height * 0.6);
    } else {
      showBlood = false; // Stop showing the blood after 3 seconds
    }
  }

}


void checkKunaiCollision(PVector kunaiPosition) {
  // rectangle bound of Naruto
  float narutoLeft = narutoBodyCenter.x - (body.width * 0.25);
  float narutoRight = narutoBodyCenter.x + (body.width * 0.25);
  float narutoTop = narutoBodyCenter.y - (body.height * 0.25);
  float narutoBottom = narutoBodyCenter.y + (body.height * 0.25);

  // check if the kunai's curr pos. is within the bounds of Naruto
  if (kunaiPosition.x > narutoLeft && kunaiPosition.x < narutoRight &&
      kunaiPosition.y > narutoTop && kunaiPosition.y < narutoBottom) {

    narutoHealth -= 10; 
    showBlood = true;
    bloodTimer = millis();
    // remove the kunai from the array to avoid multiple hits
    kunaiPositions.remove(kunaiPosition);
  }
}



void shootKunai() {
   // starts at Sasuke's position
  kunaiPosition = new PVector(sasukePosition.x+180, sasukePosition.y+20); 

  int narutoCenterX = (int)five_red_points.get(0).x +x_adjust+65;
  int narutoCenterY = (int)(five_red_points.get(0).y -(body.height * 0.25))+270;
  //System.out.println("Kunai y: " + kunaiPosition.y);

  // check if Kunai touches Naruto
  if (dist(kunaiPosition.x, kunaiPosition.y, narutoCenterX, narutoCenterY) < 200) { // Adjust the distance threshold as needed
    if (narutoHealth > 0) {
      narutoHealth--;
     }
     
  }
 
  kunaiPositions.add(kunaiPosition);
}


boolean isGameOver() {
  int elapsedTime = millis() - gameStartTime;
  if (elapsedTime > 60000) {
    return true;
  } 
  else if (narutoHealth <= 0 || sasukeHealth <= 0) {
    return true;
  }
  else {
    return false;
  }
  
}


void checkGameEnd() {
  fill(255);
  textSize(25);
  if (isGameOver()){
    text("Game Over!", width / 2, height / 2);
    String msg = "";
    if (narutoHealth > sasukeHealth) {
      msg = "Naruto Wins!";
      dattebayo = new SoundFile(this, sketchPath("../sounds/dattebayo.wav"));
      dattebayo.amp(1);
      dattebayo.play();
    } else if (sasukeHealth > narutoHealth) {
      msg = "Sasuke Wins!";
      sasukeee = new SoundFile(this, sketchPath("../sounds/sasukeee.wav"));
      sasukeee.amp(0.9);
      sasukeee.play();
    } else {
      msg = "It's a tie!";
      naruto_sasuke = new SoundFile(this, sketchPath("../sounds/naruto-sasuke.wav"));
      naruto_sasuke.amp(0.9);
      naruto_sasuke.play();
    }
    text(msg, width / 2, (height / 2)+30);
    noLoop(); // Stop the draw loop
  }


}


void displayTimer() {
  int elapsedTime = millis() - gameStartTime;
  int seconds = (elapsedTime / 1000) % 60; // milliseconds to seconds
  int minutes = (elapsedTime / (1000*60)) % 60; // ms to minutes
  
  String timeText = nf(minutes, 2) + ":" + nf(seconds, 2); 

  fill(255); 
  textSize(20);
  textAlign(CENTER, CENTER);
  text("Timer: " + timeText, width / 2, 20);
}
