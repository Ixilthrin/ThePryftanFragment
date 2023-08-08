public class App
{
  PImage backgroundImage = null;
  Scene scene = null;
  PFont font;
  MutableState mutableState = new MutableState();
  ISceneObject hover = null;
  int hoverDelay = 1000;
  int hoverTime = 0;
  int hoverStart = 0;
  PImage green_glow;
  color red_led;
  color green_led_off;

  //TextInputBox textBox = new TextInputBox();
  //TextSelectionBox selectionBox = new TextSelectionBox();
  //TextInputBox inputFocus = null;

  public void setup()
  {
    green_glow = loadImage("green_glow.png");
    red_led = color(232, 21, 21);
    green_led_off = color(19, 143, 65);
    surface.setTitle("Device Playground - An AV System Simulator");

    scene = new Scene();
    mutableState.heldWire = new Wire(ConnectionTypeEnum.None);
    backgroundImage = loadImage("workbench1600x1000-3.png");
    size(1600, 1000);  // for background must be exactly same as image
    //fullScreen();
    frameRate(30);
    font = createFont("Arial Bold", 16, true); // Arial, 16 point, anti-aliasing on

    populateScene();
  }

  public void populateScene()
  {
    scene.add(new PowerSupply(50, 100));
    scene.add(new PowerSupply(50, 300));
    scene.add(new PowerSupply(50, 500));
    scene.add(new WireBundle(50, 700, ConnectionTypeEnum.Ethernet));
    scene.add(new WireBundle(200, 700, ConnectionTypeEnum.Power));
    scene.add(new WireBundle(350, 700, ConnectionTypeEnum.HDMI));
    scene.add(new WireBundle(200, 850, ConnectionTypeEnum.RadioSignal));
    scene.add(new WireBundle(350, 850, ConnectionTypeEnum.RS232CaptiveScrew));
    scene.add(new Controller(300, 300));
    scene.add(new NetworkSwitch(600, 100));
    scene.add(new TLP(600, 300));
    scene.add(new CableBox(600, 700));
    scene.add(new Display(1000, 300));
    scene.add(new IREmitter(900, 700));
    scene.add(new Poe(1100, 100));
    scene.add(new Anchor(1400, 70));
    scene.add(new Anchor(1450, 90));
    scene.add(new Anchor(1450, 70));
    scene.add(new Anchor(1400, 90));
    scene.add(new Anchor(1400, 110));
    scene.add(new Anchor(1400, 130));
    scene.add(new Anchor(1400, 150));
    scene.add(new Anchor(1400, 170));
    scene.add(new Anchor(1400, 190));
  }

  public void addWire(Wire wire)
  {
    scene.wires.add(wire);
  }

  public Scene getScene()
  {
    return scene;
  }

  public void update()
  {
    int my = mouseY;
    int mx = mouseX;

    // Recalculate the connection line
    if (mutableState.connectorUpdateRequested || (mutableState.isHoldingConnectedWire && (mutableState.oldMouseY != my || mutableState.oldMouseX != mx)))
    {
      for (int i = 0; i < scene.wires.size(); ++i)
      {
        scene.wires.get(i).calculatePoints();
      }

      mutableState.oldMouseY = my;
      mutableState.oldMouseX = mx;
      mutableState.connectorUpdateRequested = false;
    }
    for (int i = 0; i < scene.wires.size(); ++i)
    {
      if (scene.wires.get(i).end0 != null || scene.wires.get(i).end1 != null)
        scene.wires.get(i).update();
    }
    mutableState.heldWire.update();

    for (int i = 0; i < scene.size(); ++i)
    {
      scene.get(i).update();
    }
  }

  public void draw()
  {

    clear();
    background(backgroundImage);
    //background(181, 125, 65);
    
    textFont(font, 24);
    fill(193, 46, 23);
    if (mutableState.isPaused)
    {
      text("PAUSED", 50, 50);
    }

    String state = "";
    if (mutableState.isHoldingWire)
    {
      state = "Wire Ready To Connect";
    } else if (mutableState.isHoldingConnectedWire)
    {
      state = "Holding Connected Wire";
    } else
    {
      state = "Not Holding Wire";
    }
    textFont(font, 24);
    text(state, 250, 50);

    text("Signal Speed: " + ((int)(app_global.mutableState.signalSpeed * 1000) + 1), 600, 50);

    stroke(0, 0, 0);
    fill(0, 0, 0);

    update();

    if (mutableState.isHoldingConnectedWire)
    {
      mutableState.heldWire.draw();
    }

    for (int i = 0; i < scene.wires.size(); ++i)
    {
      if (scene.wires.get(i).end0 != null || scene.wires.get(i).end1 != null)
        scene.wires.get(i).draw();
    }

    for (int i = 0; i < scene.size(); ++i)
    {
      scene.get(i).draw();
    }

    if (hover != null && hover.getHoverText().size() > 0 && mutableState.heldObject == null)
    {
      if (millis() - hoverStart > hoverDelay)
      {
        int x = mouseX;
        int y = mouseY;
        float textWidth = 0;
        for (int i = 0; i < hover.getHoverText().size(); ++i)
        {
          String text = hover.getHoverText().get(i);
          if (textWidth < textWidth(text))
          {
            textWidth = textWidth(text);
          }
        }
        fill(255);
        rect(x + 10, y, textWidth + 10, 30 * hover.getHoverText().size() + 10);
        fill(0);
        for (int i = 0; i < hover.getHoverText().size(); ++i)
        {
          text(hover.getHoverText().get(i), x + 15, y + 25 + 30 * i);
        }
      }
    }
  }
}

public class MutableState
{
  Wire heldWire = null;
  ISceneObject heldObject = null;
  float signalSpeed = .001f;
  float maxSpeed= .014f;

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
  int oldMouseX = 0;
  boolean hidePower = false;
  boolean isPaused = false;
}

public static class MacAddressProvider
{
  private static int macAddressMax = 0;

  public static int getMac()
  {
    macAddressMax += 1;
    return macAddressMax;
  }
}

class Scene
{
  ArrayList<ISceneObject> list = null;
  ArrayList<Wire> wires = null;
  public Scene()
  {
    list = new ArrayList<ISceneObject>();
    wires = new ArrayList<Wire>();
  }
  public void add(ISceneObject o)
  {
    list.add(o);
  }
  public ISceneObject get(int index)
  {
    return list.get(index);
  }
  public int size()
  {
    return list.size();
  }
  public void bringToFront(ISceneObject o)
  {
    list.remove(o);
    list.add(o);
  }
}
