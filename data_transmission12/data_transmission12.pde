App app_global = new App();

void setup() {
  app_global.setup();
}

void update()
{
  int my = mouseY;

  // Recalculate the connection line
  if (app_global.mutableState.connectorUpdateRequested || (app_global.mutableState.isHoldingConnectedWire && app_global.mutableState.oldMouseY != my))
  {
    for (int i = 0; i < app_global.wires.size(); ++i)
    {
      app_global.wires.get(i).calculatePoints();
    }

    app_global.mutableState.oldMouseY = my;
    app_global.mutableState.connectorUpdateRequested = false;
  }
  for (int i = 0; i < app_global.wires.size(); ++i)
  {
    if (app_global.wires.get(i).end0 != null || app_global.wires.get(i).end1 != null)
      app_global.wires.get(i).update();
  }
  app_global.mutableState.heldWire.update();

  for (int i = 0; i < app_global.scene.size(); ++i)
  {
    app_global.scene.get(i).update();
  }
}

void draw() {

  //clear();
  background(app_global.backgroundImage);
  textFont(app_global.font, 24);
  fill(0);

  String state = "";
  if (app_global.mutableState.isHoldingWire)
  {
    state = "Wire Ready To Connect";
  } else if (app_global.mutableState.isHoldingConnectedWire)
  {
    state = "Holding Connected Wire";
  } else
  {
    state = "Not Holding Wire";
  }
  text(state, 250, 100);

  update();

  if (app_global.mutableState.isHoldingConnectedWire)
  {
    app_global.mutableState.heldWire.draw();
  }
  for (int i = 0; i < app_global.wires.size(); ++i)
  {
    if (app_global.wires.get(i).end0 != null || app_global.wires.get(i).end1 != null)
      app_global.wires.get(i).draw();
  }

  for (int i = 0; i < app_global.scene.size(); ++i)
  {
    app_global.scene.get(i).draw();
  }
}
