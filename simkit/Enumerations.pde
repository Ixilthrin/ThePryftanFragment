enum ItemTypeEnum
{
  None,
    Electricity,
    CoalDeposit,
    Coal,
    IronDeposit,
    Iron,
    IronPlate,
    CopperDeposit,
    Copper,
    CopperPlate,
    StoneDeposit,
    Stone,
    Video
}

enum CommandTypeEnum
{
  None,
    TogglePower
}

enum DataDirectionEnum
{
  None,
    Input,
    Output,
    Twoway
}

enum WireEndEnum
{
  None,
    End0,
    End1
}

enum PayloadDirectionEnum
{
  None,
    Forward,
    Reverse
}

enum MessageEnum
{
  None,
    TryConnectWire
}

enum DataMovementEnum
{
  None,
    Forward,
    Backward
}

enum ConnectionTypeEnum
{
  None,
    Any,
    Ethernet,
    HDMI,
    Power,
    RadioSignal,
    RS232Captive,
    TransportBelt
}

enum OrientationEnum
{
  None,
    North,
    East,
    South,
    West
}

enum FurnaceProductionEnum
{
  None,
    IronPlates,
    CopperPlates,
    SteelPlates
}
