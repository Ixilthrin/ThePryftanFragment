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
    Image
}

enum CommandTypeEnum
{
  None,
    Play,
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
    RS232CaptiveScrew,
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
