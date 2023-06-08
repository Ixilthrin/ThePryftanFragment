public static class ComponentProps //<>//
{
  public static int DepositWidth = 70;
  public static int DepositHeight = 70;
  public static int BoxWidth = 50;
  public static int BoxHeight = 50;
  public static int DrillWidth = 70;
  public static int DrillHeight = 70;
  public static int StoneFurnaceWidth = 50;
  public static int StoneFurnaceHeight = 50;
  public static int WireWidth = 80;
  public static int WireHeight = 80;
  public static int PowerSupplyWidth = 70;
  public static int PowerSupplyHeight = 75;
  public static int FunctionBoxWidth = 250;
  public static int FunctionBoxHeight = 60;
}


public class Anchor implements ISceneObject
{
  Box theBox;
  Connector west;
  Connector north;
  Connector east;
  Connector south;
  color unconnectedColor = color(150, 150, 150);

  public Anchor(int x, int y)
  {
    PImage image = loadImage("anchor-background.png");
    theBox = new Box(x, y, 30, 30, image);
    theBox.theProvider = this;

    theBox.addConnector(ConnectionTypeEnum.Any, new Point(0, 10), OrientationEnum.West, DataDirectionEnum.Twoway, unconnectedColor);
    theBox.addConnector(ConnectionTypeEnum.Any, new Point(10, 0), OrientationEnum.North, DataDirectionEnum.Twoway, unconnectedColor);
    theBox.addConnector(ConnectionTypeEnum.Any, new Point(theBox.width - 10, 10), OrientationEnum.East, DataDirectionEnum.Twoway, unconnectedColor);
    theBox.addConnector(ConnectionTypeEnum.Any, new Point(10, theBox.height - 10), OrientationEnum.South, DataDirectionEnum.Twoway, unconnectedColor);

    west = theBox.connectors.get(0);
    north = theBox.connectors.get(1);
    east = theBox.connectors.get(2);
    south = theBox.connectors.get(3);
  }

  public Box getBox()
  {
    return theBox;
  }

  public ArrayList<String> getHoverText()
  {
    ArrayList<String> text = new ArrayList<String>();
    text.add("Anchor / Splitter / Booster");
    return text;
  }
  
  public void connectionChanged()
  {
    ConnectionTypeEnum connectionType = ConnectionTypeEnum.Any;
    for (int i = 0; i < theBox.connectors.size(); ++i)
    {
      Wire theWire = theBox.connectors.get(i).theWire;
      if (theWire != null && theWire.connectionType != ConnectionTypeEnum.Any)
      {
        connectionType = theWire.connectionType;
        break;
      }
    }
    if (connectionType != ConnectionTypeEnum.Any)
    {
      setConnectionType(connectionType);
      color _color = color(0, 0, 0);
      if (connectionType == ConnectionTypeEnum.Ethernet)
         _color = color(0, 0, 255);
      else if (connectionType == ConnectionTypeEnum.Power)
          _color = color(0, 0, 0);
          
      west._color = _color;
      north._color = _color;
      east._color = _color;
      south._color = _color;
      
    }
    else
    {
      west._color = unconnectedColor;
      north._color = unconnectedColor;
      east._color = unconnectedColor;
      south._color = unconnectedColor;
      
      west.connectionType = ConnectionTypeEnum.Any;
      north.connectionType = ConnectionTypeEnum.Any;
      east.connectionType = ConnectionTypeEnum.Any;
      south.connectionType = ConnectionTypeEnum.Any;
    }
  }

  public void update()
  { //<>// //<>//
  }

  private void setConnectionType(ConnectionTypeEnum type)
  {
    for (int i = 0; i < theBox.connectors.size(); ++i)
    {
      theBox.connectors.get(i).connectionType = type;
    }
  }

  public void draw()
  {
    theBox.draw();
  }

  public boolean select(int x, int y)
  {
    if (theBox.contains(x, y))
    {
      return true;
    }
    return false;
  }

  public boolean receive(IPayload payload, Connector source)
  {
    Connector sender = null;

    if (west.theWire != null && west != source)
    {
      sender = west;
      theBox.send(sender, payload);
    }
    if (north.theWire != null && north != source)
    {
      sender = north;
      theBox.send(sender, payload);
    }
    if (east.theWire != null && east != source)
    {
      sender = east;
      theBox.send(sender, payload);
    }
    if (south.theWire != null && south != source)
    {
      sender = south;
      theBox.send(sender, payload);
    }


    return true;
  }
}

public class CodeBox implements ISceneObject, IKeyboardListener
{
  Box theBox;

  TextInputBox textInput;
  int previousUpdateTime = 0;
  int interval = 0;

  public CodeBox(int x, int y)
  {

    PImage image = loadImage("code.png");
    theBox = new Box(x, y, ComponentProps.FunctionBoxWidth, ComponentProps.FunctionBoxHeight, image);
    theBox.theProvider = this;
    theBox.addConnector(ConnectionTypeEnum.Ethernet, new Point(-10, 0), OrientationEnum.West, DataDirectionEnum.Input, color(255, 165, 0));
    theBox.addConnector(ConnectionTypeEnum.Ethernet, new Point(theBox.width, 0), OrientationEnum.East, DataDirectionEnum.Output, color(255, 165, 0));
    textInput = new TextInputBox(x + 5, y + 20, ComponentProps.FunctionBoxWidth - 10);
  }

  public Box getBox()
  {
    return theBox;
  }

  public ArrayList<String> getHoverText()
  {
    ArrayList<String> text = new ArrayList<String>();
    text.add("Code Box");
    return text;
  }
  
  public void connectionChanged()
  {
  }

  public void update()
  {
    textInput.x = theBox.x + 5;
    textInput.y = theBox.y + 20;

    int currentTime = millis();
    interval += currentTime - previousUpdateTime;
    if (interval > 2000)
    {
      //Connector connector = theBox.connectors.get(0);
      //ItemPayload payload = new ItemPayload(type, 20);
      interval = 0;
    }
    previousUpdateTime = currentTime;
  }

  public void draw()
  {
    theBox.draw();
    textInput.draw();
  }

  public void keyPress(int code)
  {
    textInput.keyPress(code);
  }

  public boolean select(int x, int y)
  {
    if (textInput.contains(x, y))
    {
      //app_global.inputFocus = textInput;
      return true;
    }
    if (theBox.contains(x, y))
    {
      return true;
    }
    return false;
  }

  public boolean receive(IPayload payload, Connector source)
  {
    return false;
  }
}

public class NaturalDeposit implements ISceneObject
{
  Box theBox;

  float amount = 5000;
  int previousUpdateTime = 0;
  int interval = 0;
  ItemTypeEnum type;

  public NaturalDeposit(int x, int y, ItemTypeEnum type)
  {
    this.type = type;
    PImage image = null;
    if (type == ItemTypeEnum.StoneDeposit)
    {
      image = loadImage("stone_deposit.png");
    } else if (type == ItemTypeEnum.CoalDeposit)
    {
      image = loadImage("coal.png");
    } else if (type == ItemTypeEnum.CopperDeposit)
    {
      image = loadImage("copper_ore.png");
    } else if (type == ItemTypeEnum.IronDeposit)
    {
      image = loadImage("iron_ore.png");
    }
    theBox = new Box(x, y, ComponentProps.DepositWidth, ComponentProps.DepositHeight, image);
    theBox.theProvider = this;
    theBox.addConnector(ConnectionTypeEnum.TransportBelt, new Point(theBox.width, 0), OrientationEnum.East, DataDirectionEnum.Output, color(255, 165, 0));
  }

  public Box getBox()
  {
    return theBox;
  }

  public ArrayList<String> getHoverText()
  {
    ArrayList<String> text = new ArrayList<String>();
    text.add(type + ": " + (int)amount);
    return text;
  }
  
  public void connectionChanged()
  {
  }

  public void update()
  {
    int currentTime = millis();
    interval += currentTime - previousUpdateTime;
    if (interval > 2000)
    {
      Connector connector = theBox.connectors.get(0);
      ItemPayload payload = new ItemPayload(type, 20, null);
      if (amount >= 20 && theBox.send(connector, payload))
      {
        amount -= 20;
      }
      interval = 0;
    }
    previousUpdateTime = currentTime;
  }

  public void draw()
  {
    theBox.draw();
  }

  public boolean select(int x, int y)
  {
    if (theBox.contains(x, y))
    {
      return true;
    }
    return false;
  }

  public boolean receive(IPayload payload, Connector source)
  {
    return false;
  }
}

public class WoodenBox implements ISceneObject
{
  Box theBox;
  int coal = 0;
  int iron = 0;
  int stone = 0;
  int copper = 0;
  int ironPlates = 0;
  int copperPlates = 0;
  int previousUpdateTime = 0;
  int interval = 0;

  public WoodenBox(int x, int y)
  {
    PImage image = loadImage("wooden_box.png");
    theBox = new Box(x, y, ComponentProps.BoxWidth, ComponentProps.BoxHeight, image);
    theBox.theProvider = this;
    theBox.addConnector(ConnectionTypeEnum.TransportBelt, new Point(-10, 10), OrientationEnum.West, DataDirectionEnum.Input, color(255, 165, 0));
  }

  public Box getBox()
  {
    return theBox;
  }

  public ArrayList<String> getHoverText()
  {
    ArrayList<String> text = new ArrayList<String>();
    text.add("iron plates: " + ironPlates);
    text.add("copper plates: " + copperPlates);
    text.add("stone: " + stone);
    return text;
  }
  
  public void connectionChanged()
  {
  }

  public void update()
  {
    int currentTime = millis();
    interval += currentTime - previousUpdateTime;
    if (interval > 2000)
    {
      interval = 0;
    }
    previousUpdateTime = currentTime;
  }

  public void draw()
  {
    theBox.draw();
  }

  public boolean select(int x, int y)
  {
    if (theBox.contains(x, y))
    {
      return true;
    }
    return false;
  }

  public boolean receive(IPayload payload, Connector source)
  {
    if (!(payload instanceof ItemPayload))
    {
      return false;
    }
    ItemPayload itemPayload = (ItemPayload)payload;
    ItemTypeEnum type = itemPayload.type;
    int quantity = itemPayload.quantity;
    if (type == ItemTypeEnum.Coal)
    {
      coal += quantity;
      return true;
    }
    if (type == ItemTypeEnum.Iron)
    {
      iron += quantity;
      return true;
    }
    if (type == ItemTypeEnum.Copper)
    {
      copper += quantity;
      return true;
    }
    if (type == ItemTypeEnum.IronPlate)
    {
      ironPlates += quantity;
      return true;
    }
    if (type == ItemTypeEnum.CopperPlate)
    {
      copperPlates += quantity;
      return true;
    }
    if (type == ItemTypeEnum.Stone)
    {
      stone += quantity;
      return true;
    }
    return false;
  }
}

public class CoalPoweredMiningDrill implements ISceneObject
{
  Box theBox;
  int previousUpdateTime = 0;
  int coalReserve = 0;
  int ironReserve = 0;
  int copperReserve = 0;
  int stoneReserve = 0;
  int interval = 0;

  public CoalPoweredMiningDrill(int x, int y)
  {
    PImage image = loadImage("coal_powered_mining_drill.png");
    theBox = new Box(x, y, ComponentProps.DrillWidth, ComponentProps.DrillHeight, image);
    theBox.theProvider = this;
    theBox.addConnector(ConnectionTypeEnum.TransportBelt, new Point(-10, 10), OrientationEnum.West, DataDirectionEnum.Input, color(255, 165, 0));
    theBox.addConnector(ConnectionTypeEnum.TransportBelt, new Point(theBox.width, 10), OrientationEnum.East, DataDirectionEnum.Output, color(255, 165, 0));
  }

  public Box getBox()
  {
    return theBox;
  }

  public ArrayList<String> getHoverText()
  {
    ArrayList<String> text = new ArrayList<String>();
    return text;
  }
  
  public void connectionChanged()
  {
  }

  public void update()
  {
    int currentTime = millis();
    interval += currentTime - previousUpdateTime;
    if (interval > 2000 && coalReserve > 20)
    {
      Connector connector = theBox.connectors.get(1);
      if (theBox.send(connector, new ItemPayload(ItemTypeEnum.Coal, 20, null)))
      {
        coalReserve -= 20;
      }
      interval = 0;
    } else if (interval > 2000 && ironReserve > 20)
    {
      Connector connector = theBox.connectors.get(1);
      if (theBox.send(connector, new ItemPayload(ItemTypeEnum.Iron, 20, null)))
      {
        ironReserve -= 20;
      }
      interval = 0;
    } else if (interval > 2000 && copperReserve > 20)
    {
      Connector connector = theBox.connectors.get(1);
      if (theBox.send(connector, new ItemPayload(ItemTypeEnum.Copper, 20, null)))
      {
        copperReserve -= 20;
      }
      interval = 0;
    } else if (interval > 2000 && stoneReserve > 20)
    {
      Connector connector = theBox.connectors.get(1);
      if (theBox.send(connector, new ItemPayload(ItemTypeEnum.Stone, 20, null)))
      {
        stoneReserve -= 20;
      }
      interval = 0;
    }
    previousUpdateTime = currentTime;
  }

  public void draw()
  {
    theBox.draw();
  }

  public boolean select(int x, int y)
  {
    if (theBox.contains(x, y))
    {
      return true;
    }
    return false;
  }

  public boolean receive(IPayload payload, Connector source)
  {
    if (!(payload instanceof ItemPayload))
    {
      return false;
    }
    ItemPayload itemPayload = (ItemPayload)payload;
    ItemTypeEnum type = itemPayload.type;
    if (type == ItemTypeEnum.CoalDeposit)
    {
      ironReserve = 0;
      copperReserve = 0;
      coalReserve += 20;
      if (coalReserve > 30)
        coalReserve = 30;
      return true;
    }
    if (type == ItemTypeEnum.IronDeposit)
    {
      coalReserve = 0;
      copperReserve = 0;
      ironReserve += 20;
      if (ironReserve > 40)
        ironReserve = 40;
      return true;
    }
    if (type == ItemTypeEnum.CopperDeposit)
    {
      coalReserve = 0;
      ironReserve = 0;
      copperReserve += 20;
      if (copperReserve > 40)
        copperReserve = 40;
      return true;
    }
    if (type == ItemTypeEnum.StoneDeposit)
    {
      coalReserve = 0;
      ironReserve = 0;
      copperReserve = 0;
      stoneReserve += 20;
      if (stoneReserve > 40)
        stoneReserve = 40;
      return true;
    }
    return false;
  }
}

public class StoneFurnace implements ISceneObject
{
  Box theBox;
  int previousUpdateTime = 0;
  float coalPower = 0;
  float iron = 0;
  float copper = 0;
  boolean isRunning = false;
  float plates = 0;
  PImage image = null;
  PImage image_running = null;
  FurnaceProductionEnum product = FurnaceProductionEnum.None;

  public StoneFurnace(int x, int y)
  {
    image = loadImage("stone_furnace.png");
    image_running = loadImage("stone_furnace_running.png");
    theBox = new Box(x, y, ComponentProps.StoneFurnaceWidth, ComponentProps.StoneFurnaceHeight, image);
    theBox.theProvider = this;
    theBox.addConnector(ConnectionTypeEnum.TransportBelt, new Point(-10, 0), OrientationEnum.West, DataDirectionEnum.Input, color(255, 165, 0));
    theBox.addConnector(ConnectionTypeEnum.TransportBelt, new Point(-10, 30), OrientationEnum.West, DataDirectionEnum.Input, color(255, 165, 0));
    theBox.addConnector(ConnectionTypeEnum.TransportBelt, new Point(theBox.width, 20), OrientationEnum.East, DataDirectionEnum.Output, color(255, 165, 0));
  }

  public Box getBox()
  {
    return theBox;
  }

  public ArrayList<String> getHoverText()
  {
    ArrayList<String> text = new ArrayList<String>();
    text.add("coalPower: " + (int)coalPower);
    text.add("iron: " + iron);
    text.add("copper: " + copper);
    return text;
  }
  
  public void connectionChanged()
  {
  }

  public void update()
  {
    int currentTime = millis();
    if ((iron >= 1 || copper >= 1) && coalPower > 1)
    {
      isRunning = true;
      ItemTypeEnum payloadType = ItemTypeEnum.None;
      if (product == FurnaceProductionEnum.IronPlates)
      {
        iron--;
        payloadType = ItemTypeEnum.IronPlate;
      } else if (product == FurnaceProductionEnum.CopperPlates)
      {
        copper--;
        payloadType = ItemTypeEnum.CopperPlate;
      }
      plates += .01;
      int wholePlates = (int)plates;
      if (wholePlates > 0)
      {
        Connector connector = theBox.connectors.get(2);
        if (connector != null)
        {
          theBox.send(connector, new ItemPayload(payloadType, wholePlates, null));
          plates -= (float) wholePlates;
        }
      }
    } else
    {
      isRunning = false;
    }

    float powerUsage = (float)(currentTime - previousUpdateTime) / 300.0f;
    coalPower -= powerUsage;
    if (coalPower < 0)
      coalPower = 0;
    previousUpdateTime = currentTime;
  }

  public void draw()
  {
    if (isRunning)
      theBox.image = image_running;
    else
      theBox.image = image;
    theBox.draw();
  }

  public boolean select(int x, int y)
  {
    if (theBox.contains(x, y))
    {
      return true;
    }
    return false;
  }

  public boolean receive(IPayload payload, Connector source)
  {
    if (!(payload instanceof ItemPayload))
    {
      return false;
    }
    ItemTypeEnum type = ((ItemPayload)payload).type;
    int quantity = ((ItemPayload)payload).quantity;
    if (type == ItemTypeEnum.Coal)
    {
      coalPower += quantity;
      return true;
    }
    if (type == ItemTypeEnum.Iron)
    {
      if (product != FurnaceProductionEnum.IronPlates)
      {
        plates = 0;
      }
      product = FurnaceProductionEnum.IronPlates;
      iron += quantity;
      copper = 0;
      return true;
    }
    if (type == ItemTypeEnum.Copper)
    {
      if (product != FurnaceProductionEnum.CopperPlates)
      {
        plates = 0;
      }
      product = FurnaceProductionEnum.CopperPlates;
      copper += quantity;
      iron = 0;
      return true;
    }
    return false;
  }
}

public class IBM704 implements ISceneObject
{
  Box theBox;
  public boolean isOn;

  float power = 0;
  float powerDrainRate = .005;
  int previousUpdateTime = 0;
  int width = 120;
  int height = 140;

  public IBM704(int x, int y)
  {
    PImage image = loadImage("panel.jpg");
    theBox = new Box(x, y, width, height, image);
    theBox.theProvider = this;

    theBox.addConnector(ConnectionTypeEnum.Ethernet, new Point(-10, 0), OrientationEnum.West, DataDirectionEnum.Twoway, color(0, 0, 255));
    theBox.addConnector(ConnectionTypeEnum.Ethernet, new Point(theBox.width, 0), OrientationEnum.East, DataDirectionEnum.Twoway, color(0, 0, 255));
    theBox.addConnector(ConnectionTypeEnum.Power, new Point(20, height), OrientationEnum.South, DataDirectionEnum.Input, color(0, 0, 0));
  }

  public IBM704(Box box)
  {
    theBox = box;
  }

  public Box getBox()
  {
    return theBox;
  }

  public ArrayList<String> getHoverText()
  {
    ArrayList<String> text = new ArrayList<String>();
    text.add("IBM 704");
    text.add("power: " + (int)power);
    return text;
  }
  
  public void connectionChanged()
  {
  }

  public void update()
  {
    int currentTime = millis();
    if (isOn)
    {
      float powerUsage = (float)(currentTime - previousUpdateTime) * powerDrainRate;
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
    rect(theBox.x + 35, theBox.y + 2, theBox.width - 38, 14);
  }

  public boolean select(int x, int y)
  {
    if (theBox.contains(x, y))
    {
      if (power < .0001)
        return false;
      if (!isOn)
      {
        //isOn = true;
        return true;
      }
      //Connector connector = theBox.connectors.get(0);
      //return theBox.send(connector, new CommandPayload());
      return true;
    }
    return false;
  }

  public boolean receive(IPayload payload, Connector source)
  {
    if (payload instanceof ItemPayload)
    {
      ItemPayload itemPayload = (ItemPayload)payload;
      ItemTypeEnum type = itemPayload.type;
      int quantity = itemPayload.quantity;
      if (type == ItemTypeEnum.Electricity)
      {
        power = quantity;
        return true;
      }
    }

    if (payload instanceof CommandPayload)
    {
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
    return false;
  }
}

public class PrimaryController implements ISceneObject
{
  Box theBox;
  public boolean isOn;

  float power = 0;
  float powerDrainRate = .005;
  int previousUpdateTime = 0;
  int width = 160;
  int height = 80;

  public PrimaryController(int x, int y)
  {
    PImage image = loadImage("primary-controller.png");
    theBox = new Box(x, y, width, height, image);
    theBox.theProvider = this;

    theBox.addConnector(ConnectionTypeEnum.Ethernet, new Point(theBox.width-42, height), OrientationEnum.South, DataDirectionEnum.Twoway, color(0, 0, 255));
    theBox.addConnector(ConnectionTypeEnum.Ethernet, new Point(theBox.width-28, height), OrientationEnum.South, DataDirectionEnum.Twoway, color(0, 0, 255));
    theBox.addConnector(ConnectionTypeEnum.Ethernet, new Point(theBox.width-14, height), OrientationEnum.South, DataDirectionEnum.Twoway, color(0, 0, 255));
    theBox.addConnector(ConnectionTypeEnum.Power, new Point(5, height), OrientationEnum.South, DataDirectionEnum.Input, color(0, 0, 0));
    theBox.addConnector(ConnectionTypeEnum.RS232Captive, new Point(30, height), OrientationEnum.South, DataDirectionEnum.Twoway, color(0, 0, 255));
  }

  public PrimaryController(Box box)
  {
    theBox = box;
  }

  public Box getBox()
  {
    return theBox;
  }

  public ArrayList<String> getHoverText()
  {
    ArrayList<String> text = new ArrayList<String>();
    text.add("Primary Controller");
    text.add("power: " + (int)power);
    return text;
  }
  
  public void connectionChanged()
  {
  }

  public void update()
  {
    int currentTime = millis();
    if (isOn)
    {
      float powerUsage = (float)(currentTime - previousUpdateTime) * powerDrainRate;
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
    ellipse(theBox.x + 5, theBox.y + height/2 - 10, 10, 10);
  }

  public boolean select(int x, int y)
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
      //Connector connector = theBox.connectors.get(1);
      //theBox.send(connector, new CommandPayload());
      return true;
    }
    return false;
  }

  public boolean receive(IPayload payload, Connector source)
  {
    if (payload instanceof ItemPayload)
    {
      ItemPayload itemPayload = (ItemPayload)payload;
      ItemTypeEnum type = itemPayload.type;
      int quantity = itemPayload.quantity;
      if (type == ItemTypeEnum.Electricity)
      {
        power = quantity;
        return true;
      }
    }

    if (payload instanceof CommandPayload && isOn)
    {
      Connector connector = theBox.connectors.get(4);
      theBox.send(connector, new CommandPayload());
      return true;
    }
    return false;
  }
}

public class NetworkSwitch implements ISceneObject
{
  Box theBox;
  public boolean isOn;

  float power = 0;
  float powerDrainRate = .005;
  int previousUpdateTime = 0;
  int width = 240;
  int height = 40;

  public NetworkSwitch(int x, int y)
  {
    PImage image = loadImage("network-switch.png");
    theBox = new Box(x, y, width, height, image);
    theBox.theProvider = this;

    theBox.addConnector(ConnectionTypeEnum.Ethernet, new Point(100, height), OrientationEnum.South, DataDirectionEnum.Twoway, color(0, 0, 255));
    theBox.addConnector(ConnectionTypeEnum.Ethernet, new Point(115, height), OrientationEnum.South, DataDirectionEnum.Twoway, color(0, 0, 255));
    theBox.addConnector(ConnectionTypeEnum.Ethernet, new Point(130, height), OrientationEnum.South, DataDirectionEnum.Twoway, color(0, 0, 255));
    theBox.addConnector(ConnectionTypeEnum.Power, new Point(5, height), OrientationEnum.South, DataDirectionEnum.Input, color(0, 0, 0));
  }

  public NetworkSwitch(Box box)
  {
    theBox = box;
  }

  public Box getBox()
  {
    return theBox;
  }

  public ArrayList<String> getHoverText()
  {
    ArrayList<String> text = new ArrayList<String>();
    text.add("Network Switch");
    text.add("power: " + (int)power);
    return text;
  }
  
  public void connectionChanged()
  {
  }

  public void update()
  {
    int currentTime = millis();
    if (isOn)
    {
      float powerUsage = (float)(currentTime - previousUpdateTime) * powerDrainRate;
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
    ellipse(theBox.x + 5, theBox.y + height/2 - 10, 10, 10);
  }

  public boolean select(int x, int y)
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
      //Connector connector = theBox.connectors.get(1);
      //theBox.send(connector, new CommandPayload());
      return true;
    }
    return false;
  }

  public boolean receive(IPayload payload, Connector source)
  {
    if (payload instanceof ItemPayload)
    {
      ItemPayload itemPayload = (ItemPayload)payload;
      ItemTypeEnum type = itemPayload.type;
      int quantity = itemPayload.quantity;
      if (type == ItemTypeEnum.Electricity)
      {
        power = quantity;
        return true;
      }
    }

    if (payload instanceof CommandPayload && isOn)
    {
      Connector connector = theBox.connectors.get(1);
      theBox.send(connector, new CommandPayload());
      return true;
    }
    return false;
  }
}

public class TLP implements ISceneObject
{
  Box theBox;
  public boolean isOn;

  float power = 0;
  float powerDrainRate = .005;
  int previousUpdateTime = 0;
  int width = 150;
  int height = 100;
    PImage image = loadImage("TLP.png");
    PImage image_off = loadImage("TLP-off.png");

  public TLP(int x, int y)
  {
    theBox = new Box(x, y, width, height, image_off);
    theBox.theProvider = this;

    theBox.addConnector(ConnectionTypeEnum.Ethernet, new Point(theBox.width-14, height), OrientationEnum.South, DataDirectionEnum.Twoway, color(0, 0, 255));
    theBox.addConnector(ConnectionTypeEnum.Power, new Point(5, height), OrientationEnum.South, DataDirectionEnum.Input, color(0, 0, 0));
  }

  public TLP(Box box)
  {
    theBox = box;
  }

  public Box getBox()
  {
    return theBox;
  }

  public ArrayList<String> getHoverText()
  {
    ArrayList<String> text = new ArrayList<String>();
    text.add("TLP");
    text.add("power: " + (int)power);
    return text;
  }
  
  public void connectionChanged()
  {
  }

  public void update()
  {
    int currentTime = millis();
    if (isOn)
    {
      float powerUsage = (float)(currentTime - previousUpdateTime) * powerDrainRate;
      power -= powerUsage;
      if (power < 0)
        power = 0;
    }
    if (power < .0001)
    {
      isOn = false;
      theBox.image = image_off;
    }
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
    rect(theBox.x + width /2 - 10, theBox.y + 2, 20, 8);
  }

  public boolean select(int x, int y)
  {
    if (theBox.contains(x, y))
    {
      if (power < .0001)
        return false;
      if (!isOn)
      {
        isOn = true;
        theBox.image = image;
        return true;
      }
      Connector connector = theBox.connectors.get(0);
      theBox.send(connector, new CommandPayload());
      return true;
    }
    return false;
  }

  public boolean receive(IPayload payload, Connector source)
  {
    if (payload instanceof ItemPayload)
    {
      ItemPayload itemPayload = (ItemPayload)payload;
      ItemTypeEnum type = itemPayload.type;
      int quantity = itemPayload.quantity;
      if (type == ItemTypeEnum.Electricity)
      {
        power = quantity;
        return true;
      }
    }
    return false;
  }
}

public class CableBox implements ISceneObject
{
  Box theBox;
  public boolean isOn;

  float power = 0;
  float powerDrainRate = .005;
  int previousUpdateTime = 0;
  int width = 160;
  int height = 40;
  PImage videoimage = loadImage("image_icon.png");

  public CableBox(int x, int y)
  {
    PImage image = loadImage("cablebox.png");
    theBox = new Box(x, y, width, height, image);
    theBox.theProvider = this;

    theBox.addConnector(ConnectionTypeEnum.HDMI, new Point(theBox.width-50, height), OrientationEnum.South, DataDirectionEnum.Twoway, color(0, 0, 255));
    theBox.addConnector(ConnectionTypeEnum.Power, new Point(5, height), OrientationEnum.South, DataDirectionEnum.Input, color(0, 0, 0));
    theBox.addConnector(ConnectionTypeEnum.RadioSignal, new Point(30, height), OrientationEnum.South, DataDirectionEnum.Input, color(0, 0, 0));
  }

  public CableBox(Box box)
  {
    theBox = box;
  }

  public Box getBox()
  {
    return theBox;
  }

  public ArrayList<String> getHoverText()
  {
    ArrayList<String> text = new ArrayList<String>();
    text.add("Cable Box");
    text.add("power: " + (int)power);
    return text;
  }
  
  public void connectionChanged()
  {
  }

  public void update()
  {
    int currentTime = millis();
    if (isOn)
    {
      float powerUsage = (float)(currentTime - previousUpdateTime) * powerDrainRate;
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
    
    ellipse(theBox.x + 5, theBox.y + height - 10, 10, 10);
  }

  public boolean select(int x, int y)
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
      return true;
    }
    return false;
  }

  public boolean receive(IPayload payload, Connector source)
  {
    if (payload instanceof ItemPayload)
    {
      ItemPayload itemPayload = (ItemPayload)payload;
      ItemTypeEnum type = itemPayload.type;
      int quantity = itemPayload.quantity;
      if (type == ItemTypeEnum.Electricity)
      {
        power = quantity;
        return true;
      }
    }
    
    if (!isOn)
    return false;

    if (payload instanceof CommandPayload)
    {
      Connector connector = theBox.connectors.get(0);
      theBox.send(connector, new ItemPayload(ItemTypeEnum.Video, 1, videoimage));
      return true;
    }
    return false;
  }
}

public class Display implements ISceneObject
{
  Box theBox;
  public boolean isOn;

  float power = 0;
  float powerDrainRate = .005;
  int previousUpdateTime = 0;
  int width = 216;
  int height = 170;
    PImage imageon = loadImage("monitor-on.png");
    PImage imageoff = loadImage("monitor-off.png");

  public Display(int x, int y)
  {
    theBox = new Box(x, y, width, height, imageoff);
    theBox.theProvider = this;

    theBox.addConnector(ConnectionTypeEnum.HDMI, new Point(20, height - 42), OrientationEnum.South, DataDirectionEnum.Twoway, color(0, 0, 255));
    theBox.addConnector(ConnectionTypeEnum.Power, new Point(5, height - 42), OrientationEnum.South, DataDirectionEnum.Input, color(0, 0, 0));
  }

  public Display(Box box)
  {
    theBox = box;
  }

  public Box getBox()
  {
    return theBox;
  }

  public ArrayList<String> getHoverText()
  {
    ArrayList<String> text = new ArrayList<String>();
    text.add("Display");
    text.add("power: " + (int)power);
    return text;
  }
  
  public void connectionChanged()
  {
  }

  public void update()
  {
    int currentTime = millis();
    if (isOn)
    {
      float powerUsage = (float)(currentTime - previousUpdateTime) * powerDrainRate;
      power -= powerUsage;
      if (power < 0)
        power = 0;
    }
    if (power < .0001)
    {
      isOn = false;
      theBox.image = imageoff;
    }
    previousUpdateTime = currentTime;
  }

  public void draw()
  {

    if (isOn)
    {
    } else
    {
      theBox.image = imageoff;
    }
    theBox.draw();
    if (isOn)
    {
      fill(0, 255, 0);
    } else
    {
      fill(255, 0, 0);
    }
    
    
    rect(theBox.x + width - 14, theBox.y + height - 48, 10, 5);
  }

  public boolean select(int x, int y)
  {
    if (theBox.contains(x, y))
    {
      if (power < .0001)
        return true;
      if (!isOn)
      {
        isOn = true;
        return true;
      }
      else
      {
        isOn = false;
        theBox.image = imageoff;
        return true;
      }
    }
    return false;
  }

  public boolean receive(IPayload payload, Connector source)
  {
    if (payload instanceof ItemPayload)
    {
      ItemPayload itemPayload = (ItemPayload)payload;
      ItemTypeEnum type = itemPayload.type;
      int quantity = itemPayload.quantity;
      if (type == ItemTypeEnum.Electricity)
      {
        power = quantity;
        return true;
      }
    }

    if (payload instanceof ItemPayload && isOn)
    {
      theBox.image = imageon;
    }
    return false;
  }
}

public class IREmitter implements ISceneObject
{
  Box theBox;
  public boolean isOn;

  float power = 0;
  float powerDrainRate = .005;
  int previousUpdateTime = 0;
  int width = 50;
  int height = 50;

  public IREmitter(int x, int y)
  {
    PImage image = loadImage("ir.png");
    theBox = new Box(x, y, width, height, image);
    theBox.theProvider = this;

    theBox.addConnector(ConnectionTypeEnum.RadioSignal, new Point(20, height - 42), OrientationEnum.North, DataDirectionEnum.Output, color(255, 255, 255));
    theBox.addConnector(ConnectionTypeEnum.Power, new Point(20, height), OrientationEnum.South, DataDirectionEnum.Input, color(0, 0, 0));
    theBox.addConnector(ConnectionTypeEnum.RS232Captive, new Point(-5, height/2), OrientationEnum.West, DataDirectionEnum.Twoway, color(0, 0, 0));
  }

  public IREmitter(Box box)
  {
    theBox = box;
  }

  public Box getBox()
  {
    return theBox;
  }

  public ArrayList<String> getHoverText()
  {
    ArrayList<String> text = new ArrayList<String>();
    text.add("IR Emitter");
    text.add("power: " + (int)power);
    return text;
  }
  
  public void connectionChanged()
  {
  }

  public void update()
  {
    int currentTime = millis();
    if (isOn)
    {
      float powerUsage = (float)(currentTime - previousUpdateTime) * powerDrainRate;
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
    rect(theBox.x + width - 15, theBox.y + height - 15, 5, 5);
  }

  public boolean select(int x, int y)
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
      else 
      {
        isOn = false;
      }
      return true;
    }
    return false;
  }

  public boolean receive(IPayload payload, Connector source)
  {
    if (payload instanceof ItemPayload)
    {
      ItemPayload itemPayload = (ItemPayload)payload;
      ItemTypeEnum type = itemPayload.type;
      int quantity = itemPayload.quantity;
      if (type == ItemTypeEnum.Electricity)
      {
        power = quantity;
        return true;
      }
    }

    if (payload instanceof CommandPayload && isOn)
    {
      Connector connector = theBox.connectors.get(0);
      theBox.send(connector, new CommandPayload());
      return true;
    }
    return false;
  }
}

public class WireBundle implements ISceneObject, IWireSource
{
  Box theBox;
  ConnectionTypeEnum type;

  public WireBundle(int x, int y, ConnectionTypeEnum type)
  {
    this.type = type;
    PImage image = null;
    if (type == ConnectionTypeEnum.Ethernet)
    {
      image = loadImage("blue-wire-bundle.png");
    } else if (type == ConnectionTypeEnum.Power)
    {
      image = loadImage("power_cable.png");
    } else if (type == ConnectionTypeEnum.TransportBelt)
    {
      image = loadImage("transport_belt.png");
    } else if (type == ConnectionTypeEnum.HDMI)
    {
      image = loadImage("hdmicable.png");
    } else if (type == ConnectionTypeEnum.RadioSignal)
    {
      image = loadImage("radiosignal.png");
    } else if (type == ConnectionTypeEnum.RS232Captive)
    {
      image = loadImage("rs-232-captive-screw.png");
    }
    theBox = new Box(x, y, ComponentProps.WireWidth, ComponentProps.WireHeight, image);
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

  public ArrayList<String> getHoverText()
  {
    ArrayList<String> text = new ArrayList<String>();
    text.add(type.toString());
    return text;
  }
  
  public void connectionChanged()
  {
  }

  public void update()
  {
  }

  public void draw()
  {
    theBox.draw();
  }

  public boolean select(int x, int y)
  {
    return false;
  }

  public boolean receive(IPayload payload, Connector source)
  {
    return false;
  }

  public Wire getNewWire()
  {
    return new Wire(type);
  }
}

public class PowerSupply implements ISceneObject
{
  Box theBox;
  public boolean isOn;
  PImage powerImageOff = null;
  PImage powerImageOn = null;
  int powerTimeInterval = 5000;
  int previousUpdateTime;
  int timeSinceLastPowerDelivery = 0;
  float suppliedPowerPerTurn = 50;
  PImage electricityImage = loadImage("electricity.png");

  public PowerSupply(int x, int y)
  {
    previousUpdateTime = powerTimeInterval;
    timeSinceLastPowerDelivery = powerTimeInterval;
    powerImageOff = loadImage("power_supply_off.png");
    powerImageOn = loadImage("power_supply.png");
    theBox = new Box(x, y, ComponentProps.PowerSupplyWidth, ComponentProps.PowerSupplyHeight, powerImageOff);
    theBox.theProvider = this;
    theBox.addConnector(ConnectionTypeEnum.Power, new Point(69, 10), OrientationEnum.East, DataDirectionEnum.Output, color(0, 0, 0));
    theBox.addConnector(ConnectionTypeEnum.Power, new Point(69, 30), OrientationEnum.East, DataDirectionEnum.Output, color(0, 0, 0));
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

  public ArrayList<String> getHoverText()
  {
    ArrayList<String> text = new ArrayList<String>();
    text.add("Power Supply");
    return text;
  }
  
  public void connectionChanged()
  {
  }

  public void update()
  {
    int currentTime = millis();
    if (isOn)
    {
      timeSinceLastPowerDelivery += currentTime - previousUpdateTime;
      if (timeSinceLastPowerDelivery > powerTimeInterval)
      {
        Connector connector = theBox.connectors.get(0);
        theBox.send(connector, new ItemPayload(ItemTypeEnum.Electricity, (int)suppliedPowerPerTurn, electricityImage));
        connector = theBox.connectors.get(1);
        theBox.send(connector, new ItemPayload(ItemTypeEnum.Electricity, (int)suppliedPowerPerTurn, electricityImage));
        timeSinceLastPowerDelivery = 0;
      }
    }
    previousUpdateTime = currentTime;
  }

  public void draw()
  {
    theBox.draw();
  }

  public boolean select(int x, int y)
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

  public boolean receive(IPayload payload, Connector source)
  {
    isOn = !isOn;
    return true;
  }
}
