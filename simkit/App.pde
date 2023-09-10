public class App
{
  //PImage backgroundImage = null;
  Scene shelf;
  Scene workbench = null;
  Scene currentScene;
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
    surface.setTitle("Device Playground");

    workbench = new Scene("workbench", "workbench1600x1000-3.png");
    workbench.setup();

    shelf = new Scene("shelf", "shelf.png");
    shelf.setup();

    currentScene = shelf;

    mutableState.heldWire = new Wire(ConnectionTypeEnum.None);
    //backgroundImage = loadImage("workbench1600x1000-3.png");
    //backgroundImage = loadImage("shelf.png");
    size(1600, 1000);  // for background must be exactly same as image
    //fullScreen();
    frameRate(30);
    font = createFont("Arial Bold", 16, true); // Arial, 16 point, anti-aliasing on

    populateScene();
  }

  public void populateScene()
  {
    shelf.add(new PowerSupply(100, 83));
    shelf.add(new PowerSupply(250, 83));
    shelf.add(new PowerSupply(100, 446));
    shelf.add(new PowerSupply(1100, 650));
    shelf.add(new Controller(160, 275));
    shelf.add(new NetworkSwitch(600, 336));
    shelf.add(new TLP(600, 43));
    shelf.add(new CableBox(600, 730));
    shelf.add(new Display(1200, 304));
    shelf.add(new IREmitter(860, 700));
    shelf.add(new Poe(1200, 90));
    shelf.add(new IBM704(100, 645));
    shelf.add(new IBM704(300, 645));

    int bx = 50;
    int by = height - ComponentProps.WireHeight - 50;
    workbench.add(new WireBundle(bx, by, ConnectionTypeEnum.Ethernet));
    bx += ComponentProps.WireWidth + 50;
    workbench.add(new WireBundle(bx, by, ConnectionTypeEnum.Power));
    bx += ComponentProps.WireWidth + 50;
    workbench.add(new WireBundle(bx, by, ConnectionTypeEnum.HDMI));
    bx += ComponentProps.WireWidth + 50;
    workbench.add(new WireBundle(bx, by, ConnectionTypeEnum.RadioSignal));
    bx += ComponentProps.WireWidth + 50;
    workbench.add(new WireBundle(bx, by, ConnectionTypeEnum.RS232CaptiveScrew));

    workbench.add(new Anchor(1400, 70));
    workbench.add(new Anchor(1450, 90));
    workbench.add(new Anchor(1450, 70));
    workbench.add(new Anchor(1400, 90));
    workbench.add(new Anchor(1400, 110));
    workbench.add(new Anchor(1400, 130));
    workbench.add(new Anchor(1400, 150));
    workbench.add(new Anchor(1400, 170));
    workbench.add(new Anchor(1400, 190));
  }

  public void addWire(Wire wire)
  {
    currentScene.wires.add(wire);
  }

  public Scene getScene()
  {
    return currentScene;
  }

  public void update()
  {
    int my = mouseY;
    int mx = mouseX;

    if (currentScene.name == "shelf")
    {
      surface.setTitle("Device Playground - My Shelf");
    } else if (currentScene.name == "workbench")
    {
      surface.setTitle("Device Playground - My Workbench");
    } else
    {
      surface.setTitle("Device Playground");
    }

    // Recalculate the connection line
    if (mutableState.connectorUpdateRequested || (mutableState.isHoldingConnectedWire && (mutableState.oldMouseY != my || mutableState.oldMouseX != mx)))
    {
      for (int i = 0; i < currentScene.wires.size(); ++i)
      {
        workbench.wires.get(i).calculatePoints();
      }

      mutableState.oldMouseY = my;
      mutableState.oldMouseX = mx;
      mutableState.connectorUpdateRequested = false;
    }
    for (int i = 0; i < workbench.wires.size(); ++i)
    {
      if (workbench.wires.get(i).end0 != null || workbench.wires.get(i).end1 != null)
        workbench.wires.get(i).update();
    }
    if (mutableState.heldWire != null)
    {
      mutableState.heldWire.update();
    }

    for (int i = 0; i < workbench.size(); ++i)
    {
      workbench.get(i).update();
    }
  }

  public void draw()
  {

    clear();
    background(currentScene.backgroundImage);
    //background(181, 125, 65);

    textFont(font, 24);
    //fill(193, 46, 23); // shade of red
    fill(0, 100, 70);
    if (currentScene.isPaused && currentScene.name == "workbench")
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

    if (currentScene.name == "workbench")
    {
      textFont(font, 24);

      text(state, 250, 50);

      text("Signal Speed: " + ((int)(app_global.mutableState.signalSpeed * 1000) + 1), 600, 50);
    }

    stroke(0, 0, 0);
    fill(0, 0, 0);

    update();

    if (mutableState.isHoldingConnectedWire)
    {
      if (mutableState.heldWire == null)
      {
        mutableState.isHoldingConnectedWire = false;
      } else
      {
        mutableState.heldWire.draw();
      }
    }

    for (int i = 0; i < currentScene.wires.size(); ++i)
    {
      if (currentScene.wires.get(i).end0 != null || currentScene.wires.get(i).end1 != null)
        currentScene.wires.get(i).draw();
    }

    for (int i = 0; i < currentScene.size(); ++i)
    {
      currentScene.get(i).draw();
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
        stroke(0, 255, 0);
        fill(0, 255, 0, 125);
        float textBoxWidth = textWidth + 10;
        float textBoxHeight = 30 * hover.getHoverText().size() + 10;
        rect(x + 10 - textBoxWidth / 2, y - textBoxHeight, textBoxWidth, textBoxHeight);
        fill(0, 50, 32);
        for (int i = 0; i < hover.getHoverText().size(); ++i)
        {
          text(hover.getHoverText().get(i), x + 15 - textBoxWidth / 2, y - textBoxHeight + 25 + 30 * i);
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

  PowerVisibilityEnum powerVisibility = PowerVisibilityEnum.ShowAll;

  boolean previousWorkbenchPauseState = false;
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
  boolean isPaused = false;
  String name;
  PImage backgroundImage = null;
  String background;
  ArrayList<ISceneObject> list = null;
  ArrayList<Wire> wires = null;

  public Scene(String name, String background)
  {
    list = new ArrayList<ISceneObject>();
    wires = new ArrayList<Wire>();
    this.name = name;
    this.background = background;
  }
  public void setup()
  {
    backgroundImage = loadImage(background);
  }

  public void add(ISceneObject o)
  {
    list.add(o);
  }

  public void remove(ISceneObject o)
  {
    list.remove(o);
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
