public class App
{
  PImage backgroundImage = null;

  ArrayList<ISceneObject> scene = null;

  ArrayList<Wire> wires = null;

  PFont font;

  MutableState mutableState = new MutableState();

  public void setup()
  {
    size(1300, 866);
    //fullScreen();
    frameRate(60);
    font = createFont("Arial", 16, true); // Arial, 16 point, anti-aliasing on

    loadAssets();
  }
  
  public void addWire(Wire wire)
  {
    wires.add(wire);
  }
  
  public ArrayList<ISceneObject> getScene()
  {
    return scene;
  }

  public void loadAssets()
  {
    wires = new ArrayList<Wire>();
    scene = new ArrayList<ISceneObject>();

    backgroundImage = loadImage("wood.jpg");
    
    IBM704 ibm1 = new IBM704(50, 50, 140, 160);
    scene.add(ibm1);

    IBM704 ibm2 = new IBM704(800, 500, 140, 160);
    scene.add(ibm2);

    ibm1.getBox().addConnector(ConnectionType.Ethernet, new Point(ibm1.getBox().width, 0), DirectionEnum.East);
    ibm2.getBox().addConnector(ConnectionType.Ethernet, new Point(-10, 0), DirectionEnum.West);

    ibm1.getBox().addConnector(ConnectionType.Power, new Point(20, 160), DirectionEnum.South);
    ibm2.getBox().addConnector(ConnectionType.Power, new Point(20, 160), DirectionEnum.South);

    PowerSupply power_supply = new PowerSupply(50, 450, 140, 150);
    scene.add(power_supply);

    power_supply.getBox().addConnector(ConnectionType.Power, new Point(138, 20), DirectionEnum.East);
    power_supply.getBox().addConnector(ConnectionType.Power, new Point(138, 60), DirectionEnum.East);

    WireBundle blueWire = new WireBundle(50, 700, 100, 100);
    scene.add(blueWire);
    
    PowerCable powerCable = new PowerCable(200, 700, 100, 100);
    scene.add(powerCable);

    mutableState.heldWire = new Wire(ConnectionType.None);
  }
}

public class MutableState
{
  Wire heldWire = null;
  ISceneObject heldObject = null;

  boolean isConnecting = false;
  boolean isDataTransferStarted = false;
  boolean isHoldingConnectedWire = false;
  boolean isHoldingWire = false;
  boolean isHoldingPowerCable = false;
  boolean connectorUpdateRequested = false;

  boolean isMouseDown = false;
  int mouseDownX = 0;
  int mouseDownY = 0;
  int oldMouseY = 0;
}
