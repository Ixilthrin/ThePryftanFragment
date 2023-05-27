
public class Box
{
  int x;
  int y;
  int width;
  int height;
  boolean requestSendData = false;
  boolean requestConnectWire = false;
  boolean requestDisconnectWire = false;
  int connectorIndex = 0;
  ArrayList<Connector> connectors = new ArrayList<Connector>();
  PImage image;
  public IBoxProvider theProvider;


  public Box(int x, int y, int width, int height, PImage image)
  {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.image = image;
  }

  // Relative position to this Box
  public void addConnector(ConnectionTypeEnum type, Point point, OrientationEnum orientation, DataDirectionEnum direction)
  {
    connectors.add(new Connector(this, type, point.x, point.y, orientation, direction));
  }

  public boolean send(Connector connector, IPayload payload)
  {
    if (connector.theWire != null)
    {
      Wire wire = connector.theWire;
      if (wire.isConnectedOnBothSides())
      {
        wire.putItem(connector, payload);
        return true;
      }
    }
    return false;
  }

  public void receive(IPayload payload)
  {
    theProvider.receive(payload);
  }

  public void draw()
  {
    fill(0, 0, 255);
    stroke(0, 0, 255);
    image(image, x, y, width, height);

    fill(255, 165, 0);
    stroke(255, 77, 0);

    for (int i = 0; i < connectors.size(); ++i)
    {
      rect(connectors.get(i).relativeX + this.x, connectors.get(i).relativeY + this.y, 10, 10);
    }
  }

  public Connector getConnectorAt(int index)
  {
    return connectors.get(index);
  }

  public int getConnectorIndexAtPoint(int x, int y)
  {
    for (int i = 0; i < connectors.size(); ++i)
    {
      Connector conn = connectors.get(i);
      if (x > conn.relativeX + this.x && x < conn.relativeX + 10 + this.x && y > conn.relativeY + this.y && y < conn.relativeY + 10 + this.y)
      {
        return i;
      }
    }
    return -1;
  }

  public Connector getConnectorAtPoint(int x, int y)
  {
    int index = getConnectorIndexAtPoint(x, y);
    if (index == -1)
      return null;
    return getConnectorAt(index);
  }

  public boolean contains(int x, int y)
  {
    if (x < this.x)
    {
      return false;
    }
    if (x > this.x + width)
    {
      return false;
    }
    if (y < this.y)
    {
      return false;
    }
    if (y > this.y + height)
    {
      return false;
    }
    return true;
  }

  public boolean mouseClicked(int x, int y)
  {
    if (contains(x, y))
    {
      if (connectors.size() > 0)
      {
        Connector connector = connectors.get(0);
        if (connector.theWire != null)
        {
          connector.theWire.putItem(connector, new CommandPayload());
          return true;
        }
      }
    }
    return false;
  }

  public boolean tryConnectWire(Wire wire, int x, int y)
  {
    for (int i = 0; i < connectors.size(); ++i)
    {
      int c = getConnectorIndexAtPoint(x, y);
      if (c > -1 )
      {
        Connector connector = getConnectorAtPoint(x, y);
        if (connector.theWire == null)
        {
          if (wire.end0 == null && wire.connectionType == connector.connectionType)
          {
            if (canConnectWire(wire, connector))
            {
              wire.end0 = connector;
              connector.theWire = wire;
              wire.calculatePoints();
              return true;
            }
          }
          if (wire.end1 == null && wire.connectionType == connector.connectionType)
          {
            if (canConnectWire(wire, connector))
            {
              wire.end1 = connector;
              connector.theWire = wire;
              wire.calculatePoints();
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  private boolean canConnectWire(Wire wire, Connector connector)
  {
    if (wire.end0 == null && wire.end1 == null)
      return true;

    if (wire.end0 == null && wire.end1 != null)
    {
      if (wire.end1.direction == DataDirectionEnum.Input && connector.direction == DataDirectionEnum.Output)
      {
        return true;
      }
      if (wire.end1.direction == DataDirectionEnum.Output && connector.direction ==DataDirectionEnum.Input)
      {
        return true;
      }
      if (wire.end1.direction == DataDirectionEnum.Twoway && connector.direction == DataDirectionEnum.Twoway)
      {
        return true;
      }
    }

    if (wire.end0 != null && wire.end1 == null)
    {
      if (wire.end0.direction == DataDirectionEnum.Input && connector.direction == DataDirectionEnum.Output)
      {
        return true;
      }
      if (wire.end0.direction == DataDirectionEnum.Output && connector.direction ==DataDirectionEnum.Input)
      {
        return true;
      }
      if (wire.end0.direction == DataDirectionEnum.Twoway && connector.direction == DataDirectionEnum.Twoway)
      {
        return true;
      }
    }

    return false;
  }

  public Wire tryDisconnectWire(Wire heldWire, int x, int y)
  {
    for (int i = 0; i < connectors.size(); ++i)
    {
      int c = getConnectorIndexAtPoint(x, y);
      if (c > -1)
      {
        Connector connector = getConnectorAtPoint(x, y);
        if (connector.theWire != null && (heldWire == null || heldWire == connector.theWire))
        {
          Wire wire = connector.theWire;
          if (wire.end1 == connector)
          {
            wire.end1 = null;
            connector.theWire = null;
            return wire;
          } else if (wire.end0 == connector)
          {
            wire.end0 = null;
            connector.theWire = null;
            return wire;
          }
        }
      }
    }
    return null;
  }
}
