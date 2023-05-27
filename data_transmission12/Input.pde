void mousePressed()
{
  app_global.mutableState.isMouseDown = true;
  int x = mouseX;
  int y = mouseY;
  app_global.mutableState.mouseDownX = x;
  app_global.mutableState.mouseDownY = y;
  for (int i = 0; i < app_global.getScene().size(); ++i)
  {
    ISceneObject sceneObject = app_global.getScene().get(i);
    if (sceneObject.getBox().contains(x, y))
    {
      app_global.mutableState.heldObject = sceneObject;
      break;
    }
  }
}

void mouseReleased()
{
  app_global.mutableState.heldObject = null;
  app_global.mutableState.isMouseDown = false;
}

void mouseDragged()
{
  int x = mouseX;
  int y = mouseY;

  if (app_global.mutableState.heldObject != null)
  {
    app_global.mutableState.heldObject.getBox().x += x - app_global.mutableState.mouseDownX;
    app_global.mutableState.heldObject.getBox().y += y - app_global.mutableState.mouseDownY;
    app_global.mutableState.connectorUpdateRequested = true;
    app_global.mutableState.mouseDownX = x;
    app_global.mutableState.mouseDownY = y;
  }
}

void mouseClicked()
{
  int x = mouseX;
  int y = mouseY;
  if (app_global.mutableState.isHoldingWire)
  {
    for (int i = 0; i < app_global.getScene().size(); ++i)
    {
      ISceneObject sceneObject = app_global.getScene().get(i);
      if (sceneObject.getBox().tryConnectWire(app_global.mutableState.heldWire, x, y))
      {
        app_global.mutableState.isHoldingConnectedWire = true;
        app_global.mutableState.isHoldingWire = false;
        return;
      }
    }
  }

  if (app_global.mutableState.isHoldingConnectedWire)
  {
    for (int i = 0; i < app_global.getScene().size(); ++i)
    {
      ISceneObject sceneObject = app_global.getScene().get(i);
      if (sceneObject.getBox().tryConnectWire(app_global.mutableState.heldWire, x, y))
      {
        app_global.mutableState.isConnecting = true;
        app_global.mutableState.isHoldingConnectedWire = false;
        return;
      }
      Wire wire = sceneObject.getBox().tryDisconnectWire(app_global.mutableState.heldWire, x, y);
      if (wire != null)
      {
        app_global.mutableState.isConnecting = false;
        app_global.mutableState.isHoldingConnectedWire = wire.isConnectedOnOnlyOneSide();
        return;
      }
    }
  }

  if (!app_global.mutableState.isHoldingWire && !app_global.mutableState.isHoldingConnectedWire)
  {
    for (int i = 0; i < app_global.getScene().size(); ++i)
    {
      ISceneObject sceneObject = app_global.getScene().get(i);
      Wire wire = sceneObject.getBox().tryDisconnectWire(null, x, y);
      if (wire != null)
      {
        app_global.mutableState.heldWire = wire;
        app_global.mutableState.isHoldingConnectedWire = true;
        app_global.mutableState.isConnecting = false;
        return;
      }
    }
  }

  if (!app_global.mutableState.isHoldingConnectedWire)
  {
    for (int i = 0; i < app_global.getScene().size(); ++i)
    {
      if (app_global.getScene().get(i).mouseClicked(x, y))
        return;
    }
  }

  for (int i = 0; i < app_global.getScene().size(); ++i)
  {
    ISceneObject sceneObject = app_global.getScene().get(i);
    if (sceneObject.getBox().contains(x, y) && sceneObject instanceof IWireSource)
    {
      IWireSource wireSource = (IWireSource) sceneObject;
      app_global.mutableState.heldWire = wireSource.getNewWire();
      app_global.addWire(app_global.mutableState.heldWire);
      app_global.mutableState.isHoldingWire = true;
      return;
    }
    if (app_global.getScene().get(i).mouseClicked(x, y))
      return;
  }


  if (app_global.mutableState.isHoldingWire)
    app_global.mutableState.isHoldingWire = false;
}
