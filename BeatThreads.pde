/*************************************************************************
 * BeatThreads.pde 
 * 
 * Author: Eugene Jarder
 *
 * For completion of requirements for Creative Programming for Digital 
 * Media & Mobile Apps at Coursera.
 *
 * This is the product of the developer playing around with the gravity of
 * the world. Whenever the user presses the mouse down, the balls will
 * move towards the direction of the mouse. As you move the mouse around,
 * the balls will form threads on the screen. The color of the balls will
 * also change to the beat of the music.
 * 
 * The music used was taken from the following link:
 *   - https://www.freesound.org/people/bigjoedrummer/sounds/77293/
 * I chose a rock beat because the beat is more obvious to our ears.
 *
 * Known bug: There is a chance that the balls will not move when the
 * mouse is presses. The developer is not sure why this happens.
 *
 *************************************************************************/

import org.jbox2d.util.nonconvex.*;
import org.jbox2d.dynamics.contacts.*;
import org.jbox2d.testbed.*;
import org.jbox2d.collision.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.p5.*;
import org.jbox2d.dynamics.*;

private static final int BALL_COUNT = 7;
private static final int MIN_RADIUS = 15;
private static final int MAX_RADIUS = 20;
private static final float BEAT_THRESHOLD = 0.21;
private static final float GRAVITY_MULTIPLIER = 5.5;
private static final int BEAT_WAIT = 10;

Maxim maxim;
AudioPlayer player;

Physics physics;
Ball[] balls = new Ball[BALL_COUNT];

boolean gravityWell = false;
int background = (int) random(0, 100);
int beatWait = 0;

void setup()
{
  size(640, 360);    

  initializePhysics();
  initializeBalls();
  initializeMusic();
}

void initializePhysics()
{
  frameRate(60);
  physics = new Physics(this, width, height, 0, 0, width*2, height*2, width, height, 100);

  physics.setCustomRenderingMethod(this, "myCustomRenderer");
  physics.setDensity(10.0);
}

void initializeBalls()
{
  colorMode(HSB, 100);
  ellipseMode(RADIUS);
  
  for(int ballIndex = 0; ballIndex < BALL_COUNT; ++ballIndex)
  {
    balls[ballIndex] = generateBall();
  }
}

Ball generateBall()
{
  int radius = (int) random(MIN_RADIUS, MAX_RADIUS);
  int halfRadius = radius / 2;
  int x = (int) random(0 + halfRadius, width - halfRadius);
  int y = (int) random(0 + halfRadius, height - halfRadius); 
  int ballColor = (int) random(0, 100);
  return new Ball(physics, x, y, radius, ballColor);
}

void initializeMusic()
{
  maxim = new Maxim(this);
  player = maxim.loadFile("beat.wav");
  player.setLooping(true);
  player.setAnalysing(true);
}

void draw()
{
  
}

void myCustomRenderer(World world)
{
  if (gravityWell)
  {
    computeGravity();
  }
  
  renderBalls();
  handleBeat();
}

void computeGravity()
{
  Vec2 mouseOnScreen = new Vec2(mouseX, mouseY);
  Vec2 mouseOnWorld = physics.screenToWorld(mouseOnScreen);
  
  Vec2 ballCenter = getBallsCenterOfGravity();
  Vec2 ballOnScreen = physics.worldToScreen(ballCenter);
  
  Vec2 mouseDiff = mouseOnWorld.sub(ballCenter);
  mouseDiff.normalize();
  mouseDiff = mouseDiff.mul(GRAVITY_MULTIPLIER);
  
  physics.getWorld().setGravity(mouseDiff);
}

float getTotalMass()
{
  float totalMass = 0;
  
  for (Ball ball : balls)
  {
    float mass = (float) Math.pow(ball.getRadius(), 2) * PI;
    totalMass += mass;
  }
  
  return totalMass;
}

Vec2 getBallsCenterOfGravity()
{
  Vec2 sum = new Vec2(0, 0);
  
  for (Ball ball : balls)
  {
    Vec2 ballPos = ball.getBody().getWorldCenter();
    
    float mass = (float) Math.pow(ball.getRadius(), 2) * PI;
    ballPos = ballPos.mul(mass);   
    sum = sum.add(ballPos);
  }
  
  return sum.mul(1/getTotalMass());
}

void renderBalls()
{
  for (Ball ball : balls)
  {
    renderBall(ball);
  }
}

void renderBall(Ball ball)
{
  Vec2 ballPos = physics.worldToScreen(ball.getBody().getWorldCenter());
    
  float radius = ball.getRadius();
  int saturation = (int) map(beatWait, 0, BEAT_WAIT, 30, 70);
  
  fill(ball.getColor(), saturation, 100);

  pushMatrix();
  translate(ballPos.x, ballPos.y);
  ellipse(0, 0, radius, radius);
  popMatrix();
}

void handleBeat()
{
  boolean isBeat = false;
  
  if (player.isPlaying() && player.getAveragePower() > BEAT_THRESHOLD && beatWait == 0)
  {
    isBeat = true;
    beatWait = BEAT_WAIT;
  }
  
  if (beatWait > 0)
  {
    --beatWait;
  }
}

void mousePressed()
{
  gravityWell = true;  
  player.play();
}

void mouseReleased()
{
  gravityWell = false;
  physics.getWorld().setGravity(new Vec2(0, 0));
  player.stop();
}
