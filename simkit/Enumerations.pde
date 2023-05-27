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
  Stone
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
    Ethernet,
    Power,
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
