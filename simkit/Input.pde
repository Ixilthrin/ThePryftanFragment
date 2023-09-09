void mousePressed()
{
  int x = mouseX;
  int y = mouseY;



  if (!app_global.mutableState.isHoldingWire && !app_global.mutableState.isHoldingConnectedWire)
  {
    for (int i = app_global.getScene().size() - 1; i >= 0; --i)
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
      if (sceneObject.getBox().contains(x, y))
      {
        break;
      }
    }
  }
  
  if (app_global.mutableState.isHoldingWire)
  {
    for (int i = app_global.getScene().size() - 1; i >= 0; --i)
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
    for (int i = app_global.getScene().size() - 1; i >= 0; --i)
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
    return;
  }
  
  
  if (app_global.mutableState.heldObject != null || app_global.mutableState.isHoldingConnectedWire || app_global.mutableState.isHoldingWire)
    return;
  app_global.mutableState.isMouseDown = true;
  
  
  app_global.mutableState.mouseDownX = x;
  app_global.mutableState.mouseDownY = y;

  ISceneObject objectToFront = null;

  for (int i = app_global.getScene().size() - 1; i >= 0; --i)
  {
    ISceneObject sceneObject = app_global.getScene().get(i);
    if (sceneObject.getBox().contains(x, y))
    {
      app_global.mutableState.heldObject = sceneObject;
      objectToFront = sceneObject;
      break;
    }
  }

  if (objectToFront != null)
    app_global.currentScene.bringToFront(objectToFront);
}

void mouseReleased()
{
  app_global.mutableState.heldObject = null;
  app_global.mutableState.isMouseDown = false;
  app_global.hoverStart = millis();
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
println("clicked!");
  int x = mouseX;
  int y = mouseY;

  //if (app_global.selectionBox.contains(x, y))
  //{
  //  app_global.selectionBox.clicked(x, y);
  //  return;
  //}

  //if (app_global.textBox.contains(x, y))
  //{
  //  app_global.textBoxHasFocus = true;
  // return;
  //}

  //app_global.inputFocus = null;

  if (!app_global.mutableState.isHoldingConnectedWire)
  {

    boolean itemWasSelected = false;
    int indexOfSceneObjectToMove = -1;
    for (int i = app_global.getScene().size() - 1; i >= 0; --i)
    {
      if (app_global.currentScene.get(i).select(x, y))
      {
        itemWasSelected = true;
        if (mouseButton == RIGHT)
        {
          indexOfSceneObjectToMove = i;
        }
        break;
      }
    }

    if (indexOfSceneObjectToMove >= 0)
    {
      Scene targetScene = null;
      if (app_global.currentScene.name == "workbench")
        targetScene = app_global.shelf;
      else
        targetScene = app_global.workbench;

      ISceneObject o = app_global.currentScene.get(indexOfSceneObjectToMove);
      if (o.getBox().isConnected())
        return;
      app_global.currentScene.remove(o);
      targetScene.add(o);
      return;
    }
    if (itemWasSelected)
    {
      return;
    }
  }

  for (int i = app_global.getScene().size() - 1; i >= 0; --i)
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
  }

  if (app_global.mutableState.isHoldingWire)
    app_global.mutableState.isHoldingWire = false;
}

void mouseMoved()
{
  if (app_global.mutableState.isHoldingWire || app_global.mutableState.isHoldingConnectedWire)
  {
    app_global.hover = null;
    return;
  }

  int x = mouseX;
  int y = mouseY;

  for (int i = 0; i < app_global.getScene().size(); ++i)
  {
    ISceneObject sceneObject = app_global.getScene().get(i);
    if (sceneObject.getBox().contains(x, y))
    {
      if (app_global.hover != sceneObject && app_global.mutableState.heldObject == null)
      {
        app_global.hoverStart = millis();
        app_global.hover = sceneObject;
      }
      return;
    }
  }
  app_global.hover = null;
}

void keyPressed()
{

  if ((int)key == 10 || (int)key == 9)  // enter or tab
  {
    if (!app_global.mutableState.isHoldingWire && !app_global.mutableState.isHoldingConnectedWire)
    {
      if (app_global.currentScene.name == "shelf")
      {
        app_global.currentScene = app_global.workbench;
      } else if (app_global.currentScene.name == "workbench")
      {
        app_global.currentScene = app_global.shelf;
      }
    }
  }

  if ((int)key == 112)  // P key
    app_global.mutableState.hidePower = !app_global.mutableState.hidePower;

  if ((int)key == 44) // , key
    app_global.mutableState.signalSpeed -= .0005;

  if ((int)key == 46) // . key
    app_global.mutableState.signalSpeed += .0005;

  if (app_global.mutableState.signalSpeed < .0005)
    app_global.mutableState.signalSpeed = .0005;

  if (app_global.mutableState.signalSpeed > app_global.mutableState.maxSpeed)
  {
    app_global.mutableState.signalSpeed = app_global.mutableState.maxSpeed;
  }

  if ((int)key == 32) // space
  {
    app_global.mutableState.isPaused = !app_global.mutableState.isPaused;
  }

  //for (int i = 0; i < app_global.getScene().size(); ++i)
  //{
  //ISceneObject sceneObject = app_global.getScene().get(i);
  //if (sceneObject instanceof IKeyboardListener && app_global.inputFocus == ((CodeBox)sceneObject).textInput)
  //{
  //  ((IKeyboardListener)sceneObject).keyPress(key);
  // return;
  //}
  //}
  println((int)key);
}
