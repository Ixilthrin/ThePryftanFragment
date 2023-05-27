public class Connector
{
  int relativeX;
  int relativeY;
  Box theBox;
  Wire theWire;
  WireEndEnum wireEnd = WireEndEnum.None;
  ConnectionType connectionType;
  DirectionEnum direction;

  public Connector(Box box, ConnectionType type, int relX, int relY, DirectionEnum direction)
  {
    theBox = box;
    connectionType = type;
    relativeX = relX;
    relativeY = relY;
    this.direction = direction;
  }

  public void transferItem(int itemId)
  {
    if (theBox != null)
    {
      theBox.receive(itemId);
    }
  }
}

public class Wire implements IDrawable
{

  Connector end0;
  Connector end1;
  ArrayList<Point> points;

  // transport
  //private float payloadIndex = 0;
  private float payloadProgress = 0f;
  int itemId = 0;
  int itemQuantity = 0;
  private int millisSinceLastUpdate = 0;
  float speed = 0f;
  private DataMovementEnum dataMovement = DataMovementEnum.None;

  PayloadDirectionEnum payloadDirection = PayloadDirectionEnum.None;

  ConnectionType connectionType;

  public Wire(ConnectionType type)
  {
    connectionType = type;
    points = new ArrayList<Point>();
  }

  private int getPayloadIndex(float progress)
  {
    int payloadIndex = (int)(progress * (float)points.size());
    if (dataMovement == DataMovementEnum.Backward)
      payloadIndex = points.size() - payloadIndex;

    if (payloadIndex < 0)
      payloadIndex = 0;
    if (payloadIndex > points.size() - 1)
      payloadIndex = points.size() - 1;

    return payloadIndex;
  }

  public boolean putItem(Connector origin, int itemId, int itemQuantity)
  {
    int payloadIndex = getPayloadIndex(payloadProgress);

    if (payloadIndex > 0 && payloadIndex < points.size() - 1)
      return false;

    this.itemId = itemId;
    this.itemQuantity = itemQuantity;
    if (origin == end0)
    {
      dataMovement = DataMovementEnum.Forward;
    } else if (origin == end1)
    {
      dataMovement = DataMovementEnum.Backward;
    }
    payloadProgress = 0;
    return true;
  }

  public boolean isConnectedOnOnlyOneSide()
  {
    if (end0 == null && end1 != null)
    {
      return true;
    }
    if (end0 != null && end1 == null)
    {
      return true;
    }
    return false;
  }

  public boolean isConnectedOnBothSides()
  {
    return end0 != null && end1 != null;
  }

  public void calculatePoints()
  {
    if (end0 == null && end1 == null)
      return;

    int originX = 0;
    int originY = 0;
    int targetX = 0;
    int targetY = 0;
    DirectionEnum originDirection = DirectionEnum.None;
    DirectionEnum targetDirection = DirectionEnum.None;

    if (end0 == null)
    {
      originX = mouseX;
      originY = mouseY;
      targetX = end1.relativeX + end1.theBox.x + 5;
      targetY = end1.relativeY + end1.theBox.y + 5;
      originDirection = DirectionEnum.None;
      targetDirection = end1.direction;
    } else if (end1 == null)
    {
      targetX = mouseX;
      targetY = mouseY;
      originX = end0.relativeX + end0.theBox.x + 5;
      originY = end0.relativeY + end0.theBox.y + 5;
      originDirection = end0.direction;
      targetDirection = DirectionEnum.None;
    } else
    {
      targetX = end1.relativeX + end1.theBox.x + 5;
      targetY = end1.relativeY + end1.theBox.y + 5;
      originX = end0.relativeX + end0.theBox.x + 5;
      originY = end0.relativeY + end0.theBox.y + 5;
      originDirection = end0.direction;
      targetDirection = end1.direction;
    }

    points.clear();

    int previousX = -1;
    int previousY = -1;
    float t = 0;

    while (true)
    {
      Point point = getBezierPoint(originDirection, originX, originY, targetDirection, targetX, targetY, t);
      if (previousX != point.x || previousY != point.y)
      {
        points.add(point);
      }
      previousX = point.x;
      previousY = point.y;
      if (t > 1)
      {
        points.add(new Point(targetX, targetY));
        break;
      }
      t += .001;
    }

    // This is a simulation that should not depend on the distance between boxes
    // so speed is proportional to the length of the wire.
    speed = .002f;
  }

  Point getBezierPoint(DirectionEnum originDirection, int originX, int originY, DirectionEnum targetDirection, int targetX, int targetY, float t)
  {
    int resultX = 0, resultY = 0;

    int originXControl = 0;
    int targetXControl = 0;
    int originYControl = 0;
    int targetYControl = 0;

    int controlValue = 70;

    if (originDirection == DirectionEnum.East)
    {
      originXControl = controlValue;
      originYControl = 0;
    } else if (originDirection == DirectionEnum.South)
    {
      originXControl = 0;
      originYControl = controlValue;
    } else if (originDirection == DirectionEnum.West)
    {
      originXControl = -controlValue;
      originYControl = 0;
    } else if (originDirection == DirectionEnum.North)
    {
      originXControl = 0;
      originYControl = -controlValue;
    }

    if (targetDirection == DirectionEnum.East)
    {
      targetXControl = controlValue;
      targetYControl = 0;
    } else if (targetDirection == DirectionEnum.South)
    {
      targetXControl = 0;
      targetYControl = controlValue;
    } else if (targetDirection == DirectionEnum.West)
    {
      targetXControl = -controlValue;
      targetYControl = 0;
    } else if (targetDirection == DirectionEnum.North)
    {
      targetXControl = 0;
      targetYControl = -controlValue;
    }


    resultX = (int)bezierPoint(originX, originX + originXControl, targetX + targetXControl, targetX, t);
    resultY = (int)bezierPoint(originY, originY + originYControl, targetY + targetYControl, targetY, t);
    return new Point(resultX, resultY);
  }

  public void update()
  {
    int currentTime = millis();
    int deltaTime = currentTime - millisSinceLastUpdate;
    if (deltaTime == 0)
      return;
    float progressIncrease = speed * (float)deltaTime;
    if (dataMovement != DataMovementEnum.None && payloadProgress < 1)
    {
      payloadProgress += progressIncrease;
      millisSinceLastUpdate = currentTime;
    } else
    {
      millisSinceLastUpdate = currentTime;
      payloadProgress = 0;
      if (dataMovement == DataMovementEnum.Forward && end1 != null)
      {
        end1.transferItem(itemId);
      } else if (dataMovement == DataMovementEnum.Backward && end0 != null)
      {
        end0.transferItem(itemId);
      }
      itemId = 0;
      itemQuantity = 0;
      dataMovement = DataMovementEnum.None;
    }
    if (payloadProgress < 0)
      payloadProgress = 0;
    if (payloadProgress > 1)
      payloadProgress = 1;
  }

  public void draw()
  {
    if (connectionType == ConnectionType.Ethernet)
    {
      stroke(0, 0, 255);
      fill(0, 0, 255);
    } else
    {
      stroke(0, 0, 0);
      fill(0, 0, 0);
    }

    for (int i = 1; i < points.size(); ++i)
    {
      rect(points.get(i).x, points.get(i).y, 3, 3);
    }

    if (dataMovement != DataMovementEnum.None)
    {

      int payloadIndex = getPayloadIndex(payloadProgress);

      ellipse(points.get(payloadIndex).x, points.get(payloadIndex).y, 15, 15);
    }
  }
}
