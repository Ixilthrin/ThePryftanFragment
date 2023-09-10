 //<>// //<>//
class CommandPayload implements IPayload
{
  CommandTypeEnum type;
  PImage image = loadImage("click_button.png");

  int sourceMac;
  int destinationMac;

  public CommandPayload(CommandTypeEnum type, int source, int destination)
  {
    this.type = type;
    sourceMac = source;
    destinationMac = destination;
  }

  public PImage getImage()
  {
    return image;
  }
}

class DriverCommandPayload implements IPayload
{
  CommandTypeEnum type;
  PImage image = loadImage("steering-wheel.png");
  public DriverCommandPayload()
  {
  }

  public PImage getImage()
  {
    return image;
  }
}

class ImagePayload implements IPayload
{
  CommandTypeEnum type;
  PImage image = loadImage("image_icon.png");
  PImage payload;

  public ImagePayload(PImage payload)
  {
    this.payload = payload;
  }

  public PImage getImage()
  {
    return image;
  }
}

class ItemPayload implements IPayload
{
  ItemTypeEnum type;
  int quantity;
  PImage icon;
  public ItemPayload(ItemTypeEnum type, int quantity, PImage icon)
  {
    this.type = type;
    this.quantity = quantity;
    this.icon = icon;
  }
  public PImage getImage()
  {
    return icon;
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
  PImage ethernetImage = loadImage("connector-blue.png");
  PImage powerImage = loadImage("connector-black.png");
  PImage anyImage = loadImage("connector-any.png");
  PImage hdmiImage = loadImage("connector-green.png");
  PImage radioImage = loadImage("connector-white.png");
  PImage rs232Image = loadImage("connector-yellow.png");
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

  public void draw(int x, int y)
  {
    pushMatrix();
    if (orientation == OrientationEnum.East)
    {
      translate(relativeX + x, relativeY + y + 10);
      rotate(-PI/2);
    } else if (orientation == OrientationEnum.North)
    {
      translate(relativeX + x + 10, relativeY + y + 10);
      rotate(-PI);
    } else if (orientation == OrientationEnum.West)
    {
      translate(relativeX + x + 10, relativeY + y);
      rotate(PI/2);
    } else if (orientation == OrientationEnum.South)
    {
      translate(relativeX + x, relativeY + y);
    }

    if (connectionType == ConnectionTypeEnum.Ethernet)
    {
      image(ethernetImage, 0, 0, 10, 10);
    } else if (connectionType == ConnectionTypeEnum.Power)
    {
      image(powerImage, 0, 0, 10, 10);
    } else if (connectionType == ConnectionTypeEnum.HDMI)
    {
      image(hdmiImage, 0, 0, 10, 10);
    } else if (connectionType == ConnectionTypeEnum.Any)
    {
      image(anyImage, 0, 0, 10, 10);
    } else if (connectionType == ConnectionTypeEnum.RadioSignal)
    {
      image(radioImage, 0, 0, 10, 10);
    } else if (connectionType == ConnectionTypeEnum.RS232CaptiveScrew)
    {
      image(rs232Image, 0, 0, 10, 10);
    } else
    {
      fill(_color);
      stroke(180, 180, 180);
      rect(relativeX + x, relativeY + y, 10, 10);
    }
    popMatrix();
  }
}

class PayloadProgress
{
  IPayload payload;
  float progress = 0f;
  DataMovementEnum dataMovement = DataMovementEnum.None;
}

public class Wire implements IDrawable
{
  Connector end0;
  Connector end1;
  ArrayList<Point> points;

  int maxPayloadsOnWire = 10;
  PayloadProgress payloads[] = new PayloadProgress[maxPayloadsOnWire];
  int nextPayloadIndex = 0;  // index of payload to be used for new payload put on the wire

  private int previousUpdateTime = 0;

  //PayloadDirectionEnum payloadDirection = PayloadDirectionEnum.None;

  ConnectionTypeEnum connectionType;

  public Wire(ConnectionTypeEnum type)
  {
    connectionType = type;
    points = new ArrayList<Point>();
    for (int i = 0; i < maxPayloadsOnWire; ++i)
    {
      payloads[i] = new PayloadProgress();
    }
  }

  // Get position on the curve for given progress value
  private int getPayloadCurveIndex(float progress, int payloadIndex)
  {
    int payloadCurveIndex = (int)(progress * (float)points.size());
    if (payloads[payloadIndex].dataMovement == DataMovementEnum.Backward)
      payloadCurveIndex = points.size() - payloadCurveIndex;

    if (payloadCurveIndex < 0)
      payloadCurveIndex = 0;
    if (payloadCurveIndex > points.size() - 1)
      payloadCurveIndex = points.size() - 1;

    return payloadCurveIndex;
  }

  // Put payload on the wire
  public boolean putItem(Connector origin, IPayload payload)
  {
    PayloadProgress payloadProgress = payloads[nextPayloadIndex];
    payloadProgress.payload = payload;

    if (origin == end0)
    {
      payloadProgress.progress = 0;
      payloadProgress.dataMovement = DataMovementEnum.Forward;
    } else if (origin == end1)
    {
      payloadProgress.progress = 0;
      payloadProgress.dataMovement = DataMovementEnum.Backward;
    }

    nextPayloadIndex++;
    if (nextPayloadIndex >= maxPayloadsOnWire)
    {
      nextPayloadIndex = 0;
    }
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
    //speed = .05f;
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
    if (app_global.workbench.isPaused)
    {
      previousUpdateTime = millis();
      return;
    }

    int currentTime = millis();
    int deltaTime = currentTime - previousUpdateTime;
    if (deltaTime == 0)
      return;

    //if (nextPayloadNumber == 0)
    //{

    for (int i = 0; i < maxPayloadsOnWire; ++i)
    {
      PayloadProgress payloadProgress = payloads[i];
      float progressIncrease = app_global.mutableState.signalSpeed * (float)deltaTime;
      if (payloadProgress.dataMovement != DataMovementEnum.None && payloadProgress.progress < 1)
      {
        payloadProgress.progress += progressIncrease;
        previousUpdateTime = currentTime;
      } else
      {
        previousUpdateTime = currentTime;
        payloadProgress.progress = 0;
        if (payloadProgress.dataMovement == DataMovementEnum.Forward && end1 != null)
        {
          end1.transferItem(payloadProgress.payload);
        } else if (payloadProgress.dataMovement == DataMovementEnum.Backward && end0 != null)
        {
          end0.transferItem(payloadProgress.payload);
        }
        payloadProgress.payload = null;
        payloadProgress.dataMovement = DataMovementEnum.None;
      }
      if (payloadProgress.progress < 0)
        payloadProgress.progress = 0;
      if (payloadProgress.progress > 1)
        payloadProgress.progress = 1;
    }
  }

  public void draw()
  {
    if (connectionType == ConnectionTypeEnum.Power && app_global.mutableState.powerVisibility == PowerVisibilityEnum.HideAll)
        return;
        
    color wireColor = color(0, 0, 0);
    if (connectionType == ConnectionTypeEnum.Ethernet)
    {
      wireColor = color(35, 68, 166);
    } else if (connectionType == ConnectionTypeEnum.Power)
    {
      wireColor = color(20, 20, 20, 150);
    } else if (connectionType == ConnectionTypeEnum.TransportBelt)
    {
      int grayTint = 170;
      stroke(grayTint, grayTint, grayTint);
      fill(grayTint, grayTint, grayTint);
    } else if (connectionType == ConnectionTypeEnum.HDMI)
    {
      wireColor = color(45, 186, 59);
    } else if (connectionType == ConnectionTypeEnum.RadioSignal)
    {
      wireColor = color(200, 200, 200);
    } else if (connectionType == ConnectionTypeEnum.RS232CaptiveScrew)
    {
      wireColor = color(224, 224, 40);
    }

    stroke(wireColor);
    fill(wireColor);

    for (int i = 1; i < points.size(); ++i)
    {
      rect(points.get(i).x, points.get(i).y, 3, 3);
    }

    drawSignal();
  }

  public void drawSignal()
  {
    for (int i = 0; i < maxPayloadsOnWire; ++i)
    {
      PayloadProgress payloadProgress = payloads[i];
      if (payloadProgress.dataMovement != DataMovementEnum.None && app_global.mutableState.signalSpeed < app_global.mutableState.maxSpeed)
      {
        int payloadIndex = getPayloadCurveIndex(payloadProgress.progress, i);
        int size = 20;
        if (connectionType == ConnectionTypeEnum.TransportBelt)
        {
          stroke(0, 0, 0);
          fill(0, 0, 0);
        }
        stroke(0, 0, 0);
        fill(0, 0, 0);
        PImage image = payloadProgress.payload.getImage();
        if (image != null)
        {
          int imageSize = 40;
          if (payloadProgress.payload instanceof ItemPayload)
          {
            if (((ItemPayload)payloadProgress.payload).type == ItemTypeEnum.Electricity)
            {
              imageSize = 30;
              if (app_global.mutableState.powerVisibility == PowerVisibilityEnum.HideSignal || app_global.mutableState.powerVisibility == PowerVisibilityEnum.HideAll)
                imageSize = 0;
            }
          }

          image(image, points.get(payloadIndex).x - imageSize/2, points.get(payloadIndex).y - imageSize/2, imageSize, imageSize);
        } else
        {
          ellipse(points.get(payloadIndex).x, points.get(payloadIndex).y, size, size);
        }
      }
    }
  }
}
