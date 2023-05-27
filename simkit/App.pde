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
  

  //TextInputBox textBox = new TextInputBox();
  TextSelectionBox selectionBox = new TextSelectionBox();

  TextInputBox inputFocus = null;

  public void setup()
  {
    surface.setTitle("Device Playground");
    
    scene = new Scene();
    mutableState.heldWire = new Wire(ConnectionTypeEnum.None);
    backgroundImage = loadImage("workbench1600x1000.jpg");
    size(1600, 1000);  // for background must be exactly same as image
    //fullScreen();
    frameRate(60);
    font = createFont("Arial", 16, true); // Arial, 16 point, anti-aliasing on

    populateScene();
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

    // Recalculate the connection line
    if (mutableState.connectorUpdateRequested || (mutableState.isHoldingConnectedWire && mutableState.oldMouseY != my))
    {
      for (int i = 0; i < scene.wires.size(); ++i)
      {
        scene.wires.get(i).calculatePoints();
      }

      mutableState.oldMouseY = my;
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

    //clear();
    background(backgroundImage);
    textFont(font, 24);
    fill(0);

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
    text(state, 250, 100);

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

    //textBox.draw();
    //selectionBox.draw();

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

  public void populateScene()
  {
    scene.add(new PowerSupply(50, 550));
    scene.add(new WireBundle(50, 700, ConnectionTypeEnum.Ethernet));
    scene.add(new WireBundle(200, 700, ConnectionTypeEnum.Power));
    scene.add(new IBM704(600, 300));
    scene.add(new IBM704(800, 500));
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
}
