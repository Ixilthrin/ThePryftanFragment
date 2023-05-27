
class CommandPayload implements IPayload
{
  CommandTypeEnum type;
}

class ItemPayload implements IPayload
{
  ItemTypeEnum type;
  int quantity;
  public ItemPayload(ItemTypeEnum type, int quantity)
  {
    this.type = type;
    this.quantity = quantity;
  }
}

public class Connector
{
  int relativeX;
  int relativeY;
  Box theBox;
  Wire theWire;
  WireEndEnum wireEnd = WireEndEnum.None;
  ConnectionTypeEnum connectionType;
  DataDirectionEnum direction;
  OrientationEnum orientation;
  color _color;

  public Connector(Box box, ConnectionTypeEnum type, int relX, int relY, OrientationEnum orientation, DataDirectionEnum direction, color theColor)
  {
    theBox = box;
    connectionType = type;
    relativeX = relX;
    relativeY = relY;
    this.orientation = orientation;
    this.direction = direction;
    this._color = theColor;
  }

  public void transferItem(IPayload payload)
  {
    if (theBox != null)
    {
      theBox.receive(payload, this);
    }
  }
}

public class Wire implements IDrawable
{

  Connector end0;
  Connector end1;
  ArrayList<Point> points;

  private float payloadProgress = 0f;
  private int millisSinceLastUpdate = 0;
  float speed = 0f;
  private DataMovementEnum dataMovement = DataMovementEnum.None;

  IPayload payload;

  PayloadDirectionEnum payloadDirection = PayloadDirectionEnum.None;

  ConnectionTypeEnum connectionType;

  public Wire(ConnectionTypeEnum type)
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

  public boolean putItem(Connector origin, IPayload payload)
  {
    this.payload = payload;
    int payloadIndex = getPayloadIndex(payloadProgress);

    if (payloadIndex > 0 && payloadIndex < points.size() - 1)
      return false;

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
    OrientationEnum originDirection = OrientationEnum.None;
    OrientationEnum targetDirection = OrientationEnum.None;

    if (end0 == null)
    {
      originX = mouseX;
      originY = mouseY;
      targetX = end1.relativeX + end1.theBox.x + 5;
      targetY = end1.relativeY + end1.theBox.y + 5;
      originDirection = OrientationEnum.None;
      targetDirection = end1.orientation;
    } else if (end1 == null)
    {
      targetX = mouseX;
      targetY = mouseY;
      originX = end0.relativeX + end0.theBox.x + 5;
      originY = end0.relativeY + end0.theBox.y + 5;
      originDirection = end0.orientation;
      targetDirection = OrientationEnum.None;
    } else
    {
      targetX = end1.relativeX + end1.theBox.x + 5;
      targetY = end1.relativeY + end1.theBox.y + 5;
      originX = end0.relativeX + end0.theBox.x + 5;
      originY = end0.relativeY + end0.theBox.y + 5;
      originDirection = end0.orientation;
      targetDirection = end1.orientation;
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

  Point getBezierPoint(OrientationEnum originDirection, int originX, int originY, OrientationEnum targetDirection, int targetX, int targetY, float t)
  {
    int resultX = 0, resultY = 0;

    int originXControl = 0;
    int targetXControl = 0;
    int originYControl = 0;
    int targetYControl = 0;

    int controlValue = 70;

    if (originDirection == OrientationEnum.East)
    {
      originXControl = controlValue;
      originYControl = 0;
    } else if (originDirection == OrientationEnum.South)
    {
      originXControl = 0;
      originYControl = controlValue;
    } else if (originDirection == OrientationEnum.West)
    {
      originXControl = -controlValue;
      originYControl = 0;
    } else if (originDirection == OrientationEnum.North)
    {
      originXControl = 0;
      originYControl = -controlValue;
    }

    if (targetDirection == OrientationEnum.East)
    {
      targetXControl = controlValue;
      targetYControl = 0;
    } else if (targetDirection == OrientationEnum.South)
    {
      targetXControl = 0;
      targetYControl = controlValue;
    } else if (targetDirection == OrientationEnum.West)
    {
      targetXControl = -controlValue;
      targetYControl = 0;
    } else if (targetDirection == OrientationEnum.North)
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
        end1.transferItem(payload);
      } else if (dataMovement == DataMovementEnum.Backward && end0 != null)
      {
        end0.transferItem(payload);
      }
      payload = null;
      dataMovement = DataMovementEnum.None;
    }
    if (payloadProgress < 0)
      payloadProgress = 0;
    if (payloadProgress > 1)
      payloadProgress = 1;
  }

  public void draw()
  {
    if (connectionType == ConnectionTypeEnum.Ethernet)
    {
      stroke(40, 40, 220);
      fill(40, 40, 220);
    } else if (connectionType == ConnectionTypeEnum.Power)
    {
      stroke(0, 0, 0);
      fill(0, 0, 0);
    } else if (connectionType == ConnectionTypeEnum.TransportBelt)
    {
      int grayTint = 170;
      stroke(grayTint, grayTint, grayTint);
      fill(grayTint, grayTint, grayTint);
    }

    for (int i = 1; i < points.size(); ++i)
    {
      rect(points.get(i).x, points.get(i).y, 3, 3);
    }

    if (dataMovement != DataMovementEnum.None)
    {

      int payloadIndex = getPayloadIndex(payloadProgress);
      int size = 20;
      if (connectionType == ConnectionTypeEnum.TransportBelt)
      {
        stroke(0, 0, 0);
        fill(0, 0, 0);
      }
      stroke(0, 0, 0);
      fill(0, 0, 0);
      ellipse(points.get(payloadIndex).x, points.get(payloadIndex).y, size, size);
    }
  }
}
