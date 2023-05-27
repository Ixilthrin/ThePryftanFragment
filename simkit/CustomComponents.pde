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
    theBox.addConnector(ConnectionTypeEnum.Ethernet, new Point(-10, 0), OrientationEnum.West, DataDirectionEnum.Input);
    theBox.addConnector(ConnectionTypeEnum.Ethernet, new Point(theBox.width, 0), OrientationEnum.East, DataDirectionEnum.Output);
    textInput = new TextInputBox(x + 5, y + 20, ComponentProps.FunctionBoxWidth - 10);
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
      app_global.inputFocus = textInput;
      return true;
    }
    if (theBox.contains(x, y))
    {
      return true;
    }
    return false;
  }

  public boolean receive(IPayload payload)
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
    theBox.addConnector(ConnectionTypeEnum.TransportBelt, new Point(theBox.width, 0), OrientationEnum.East, DataDirectionEnum.Output);
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

  public void update()
  {
    int currentTime = millis();
    interval += currentTime - previousUpdateTime;
    if (interval > 2000)
    {
      Connector connector = theBox.connectors.get(0);
      ItemPayload payload = new ItemPayload(type, 20);
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

  public boolean receive(IPayload payload)
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
    theBox.addConnector(ConnectionTypeEnum.TransportBelt, new Point(-10, 10), OrientationEnum.West, DataDirectionEnum.Input);
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

  public boolean receive(IPayload payload)
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
    theBox.addConnector(ConnectionTypeEnum.TransportBelt, new Point(-10, 10), OrientationEnum.West, DataDirectionEnum.Input);
    theBox.addConnector(ConnectionTypeEnum.TransportBelt, new Point(theBox.width, 10), OrientationEnum.East, DataDirectionEnum.Output);
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

  public void update()
  {
    int currentTime = millis();
    interval += currentTime - previousUpdateTime;
    if (interval > 2000 && coalReserve > 20)
    {
      Connector connector = theBox.connectors.get(1);
      if (theBox.send(connector, new ItemPayload(ItemTypeEnum.Coal, 20)))
      {
        coalReserve -= 20;
      }
      interval = 0;
    } else if (interval > 2000 && ironReserve > 20)
    {
      Connector connector = theBox.connectors.get(1);
      if (theBox.send(connector, new ItemPayload(ItemTypeEnum.Iron, 20)))
      {
        ironReserve -= 20;
      }
      interval = 0;
    } else if (interval > 2000 && copperReserve > 20)
    {
      Connector connector = theBox.connectors.get(1);
      if (theBox.send(connector, new ItemPayload(ItemTypeEnum.Copper, 20)))
      {
        copperReserve -= 20;
      }
      interval = 0;
    } else if (interval > 2000 && stoneReserve > 20)
    {
      Connector connector = theBox.connectors.get(1);
      if (theBox.send(connector, new ItemPayload(ItemTypeEnum.Stone, 20)))
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

  public boolean receive(IPayload payload)
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
    theBox.addConnector(ConnectionTypeEnum.TransportBelt, new Point(-10, 0), OrientationEnum.West, DataDirectionEnum.Input);
    theBox.addConnector(ConnectionTypeEnum.TransportBelt, new Point(-10, 30), OrientationEnum.West, DataDirectionEnum.Input);
    theBox.addConnector(ConnectionTypeEnum.TransportBelt, new Point(theBox.width, 20), OrientationEnum.East, DataDirectionEnum.Output);
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
          theBox.send(connector, new ItemPayload(payloadType, wholePlates));
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

  public boolean receive(IPayload payload)
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

  public IBM704(int x, int y)
  {
    PImage image = loadImage("panel.jpg");
    theBox = new Box(x, y, 140, 160, image);
    theBox.theProvider = this;

    theBox.addConnector(ConnectionTypeEnum.Ethernet, new Point(theBox.width, 0), OrientationEnum.East, DataDirectionEnum.Twoway);
    theBox.addConnector(ConnectionTypeEnum.Power, new Point(20, 160), OrientationEnum.South, DataDirectionEnum.Input);
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
    text.add("power: " + (int)power);
    return text;
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
    rect(theBox.x + 40, theBox.y + 2, theBox.width - 42, 16);
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
      Connector connector = theBox.connectors.get(0);
      return theBox.send(connector, new CommandPayload());
    }
    return false;
  }

  public boolean receive(IPayload payload)
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

  public boolean receive(IPayload payload)
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
  int previousUpdateTime;
  int interval = 0;
  float suppliedPowerPerTurn = 20;

  public PowerSupply(int x, int y)
  {
    powerImageOff = loadImage("power_supply_off.png");
    powerImageOn = loadImage("power_supply.png");
    theBox = new Box(x, y, ComponentProps.PowerSupplyWidth, ComponentProps.PowerSupplyHeight, powerImageOff);
    theBox.theProvider = this;
    theBox.addConnector(ConnectionTypeEnum.Power, new Point(69, 10), OrientationEnum.East, DataDirectionEnum.Output);
    theBox.addConnector(ConnectionTypeEnum.Power, new Point(69, 30), OrientationEnum.East, DataDirectionEnum.Output);
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
    return text;
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
        theBox.send(connector, new ItemPayload(ItemTypeEnum.Electricity, (int)suppliedPowerPerTurn));
        connector = theBox.connectors.get(1);
        theBox.send(connector, new ItemPayload(ItemTypeEnum.Electricity, (int)suppliedPowerPerTurn));
        interval = 0;
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

  public boolean receive(IPayload payload)
  {
    isOn = !isOn;
    return true;
  }
}
