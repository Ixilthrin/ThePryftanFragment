public interface IBoxProvider
{
  Box getBox();
  boolean receive(IPayload payload, Connector source);
  boolean select(int x, int y);
  void connectionChanged();
}

public interface IDrawable
{
  void update();
  void draw();
}

public interface ISceneObject extends IBoxProvider, IDrawable
{
  ArrayList<String> getHoverText();
}

public interface IWireSource
{
  Wire getNewWire();
}

public interface IPayload
{
}

public interface IKeyboardListener
{
  void keyPress(int code);
}

public interface MouseListener
{
  void clicked(int x, int y);
}
