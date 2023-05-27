public interface IBoxProvider
{
  Box getBox();
  boolean receive(int itemId);
  boolean mouseClicked(int x, int y);
}

public interface IDrawable
{
  void update();
  void draw();
}

public interface ISceneObject extends IBoxProvider, IDrawable
{
}

public interface IWireSource
{
  Wire getNewWire();
}
