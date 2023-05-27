public class IBM704 implements ISceneObject
{
  Box theBox;
  public boolean isOn;

  float power = 0;
  int previousUpdateTime = 0;

  public IBM704(int x, int y, int width, int height)
  {
    PImage image = loadImage("panel.jpg");
    theBox = new Box(x, y, width, height, image);
    theBox.theProvider = this;
  }

  public IBM704(Box box)
  {
    theBox = box;
  }

  public Box getBox()
  {
    return theBox;
  }

  public void update()
  {
    int currentTime = millis();
    if (isOn)
    {
      float powerUsage = (float)(currentTime - previousUpdateTime) / 100.0f;
      power -= powerUsage;
      if (power < 0)
        power = 0;
    }
    if (power < .0001)
      isOn = false;
    previousUpdateTime = currentTime;
  }

  public void draw()
  {
    theBox.draw();

    if (isOn)
    {
      fill(0, 255, 0);
    } else
    {
      fill(255, 0, 0);
    }
    rect(theBox.x + 39, theBox.y + 2, theBox.width - 43, 16);
  }

  public boolean mouseClicked(int x, int y)
  {
    if (theBox.contains(x, y))
    {
      if (power < .0001)
        return false;
      if (!isOn)
      {
        isOn = true;
        return true;
      }
      Connector connector = theBox.connectors.get(0);
      return theBox.send(connector, 15);
    }
    return false;
  }

  public boolean receive(int itemId)
  {
    if (itemId == 25)
    {
      power = 50;
      return true;
    }
    if (isOn)
    {
      isOn = false;
    } else
    {
      if (power > .0001)
        isOn = true;
    }
    return true;
  }
}

public class WireBundle implements ISceneObject, IWireSource
{
  Box theBox;

  public WireBundle(int x, int y, int width, int height)
  {
    PImage image = loadImage("blue-wire-bundle.png");
    theBox = new Box(x, y, width, height, image);
    theBox.theProvider = this;
  }

  public WireBundle(Box box)
  {
    theBox = box;
  }

  public Box getBox()
  {
    return theBox;
  }

  public void update()
  {
  }

  public void draw()
  {
    theBox.draw();
  }

  public boolean mouseClicked(int x, int y)
  {
    return false;
  }

  public boolean receive(int itemId)
  {
    return false;
  }

  public Wire getNewWire()
  {
    return new Wire(ConnectionType.Ethernet);
  }
}


public class PowerCable implements ISceneObject, IWireSource
{
  Box theBox;

  public PowerCable(int x, int y, int width, int height)
  {
    PImage image = loadImage("power_cable.png");
    theBox = new Box(x, y, width, height, image);
    theBox.theProvider = this;
  }

  public PowerCable(Box box)
  {
    theBox = box;
  }

  public Box getBox()
  {
    return theBox;
  }

  public void update()
  {
  }

  public void draw()
  {
    theBox.draw();
  }

  public boolean mouseClicked(int x, int y)
  {
    return false;
  }

  public boolean receive(int itemId)
  {
    return false;
  }

  public Wire getNewWire()
  {
    return new Wire(ConnectionType.Power);
  }
}

public class PowerSupply implements ISceneObject
{
  Box theBox;
  public boolean isOn;
  PImage powerImageOff = null;
  PImage powerImageOn = null;
  int previousUpdateTime;
  int interval = 0;

  public PowerSupply(int x, int y, int width, int height)
  {
    powerImageOff = loadImage("power_supply_off.png");
    powerImageOn = loadImage("power_supply.png");
    theBox = new Box(x, y, width, height, powerImageOff);
    theBox.theProvider = this;
  }

  public PowerSupply(Box box)
  {
    theBox = box;
    powerImageOff = loadImage("power_supply_off.png");
    powerImageOn = loadImage("power_supply.png");
    previousUpdateTime = millis();
  }

  public Box getBox()
  {
    return theBox;
  }

  public void update()
  {
    int currentTime = millis();
    if (isOn)
    {
      interval += currentTime - previousUpdateTime;
      if (interval > 2000)
      {
        Connector connector = theBox.connectors.get(0);
        theBox.send(connector, 25);
        connector = theBox.connectors.get(1);
        theBox.send(connector, 25);
        interval = 0;
      }
    }
    previousUpdateTime = currentTime;
  }

  public void draw()
  {
    theBox.draw();
  }

  public boolean mouseClicked(int x, int y)
  {
    if (theBox.contains(x, y))
    {
      if (isOn)
      {
        theBox.image = powerImageOff;
        isOn = false;
        return true;
      } else
      {
        theBox.image = powerImageOn;
        isOn = true;
        return true;
      }
    }
    return false;
  }

  public boolean receive(int itemId)
  {
    isOn = !isOn;
    return true;
  }
}
