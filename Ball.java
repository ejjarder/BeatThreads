import org.jbox2d.dynamics.*;
import org.jbox2d.p5.*;
import org.jbox2d.common.*;

class Ball
{
  private Body body;
  private Physics physics;
  private float radius;
  private int ballColor;

  public Ball(Physics physics, float x, float y, float radius, int ballColor)
  {
    this.physics = physics;
    this.radius = radius; 
    body = physics.createCircle(x, y, radius);
    this.ballColor = ballColor;
  }

  public Body getBody()
  {
    return body;
  }

  public float getRadius()
  {
    return radius;
  }
  
  public int getColor()
  {
    return ballColor;
  }
}

