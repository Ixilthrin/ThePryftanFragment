class TextInputBox implements IKeyboardListener
{
  char chars[] = new char[30];
  int index = 0;
  int x;
  int y;
  int width;
  int height;
  
  public TextInputBox(int x, int y, int width)
  {
    this.x = x;
    this.y = y;
    this.width = width;
    height = 30;
  }
  
  void add(char c)
  {
    if (index < 20)
    {
      chars[index] = c;
      ++index;
    }
  }
  void backspace()
  {
    chars[index] = ' ';
    if (index > 0)
    {
      --index;
    }
  }

  public boolean contains(int x, int y)
  {
    if (x < this.x)
      return false;
    if (x > this.x + width)
      return false;
    if (y < this.y)
      return false;
    if (y > this.y + height)
      return false;

    return true;
  }

  public void keyPress(int code)
  {
    if (code == 8)
    {
      backspace();
    } else if ((code > 64 && code < 91) || (code > 96 && code < 123) || code == 32)
    {
      add((char)code);
    }
  }

  void draw()
  {
    fill(0, 0, 0);
    rect(x, y, width, height);

    fill(255, 255, 255);
    String s = new String(chars).substring(0, index);
    text(s, x, y + 20);
  }
}

public class TextSelectionBox implements MouseListener
{
  ArrayList<String> strings = new ArrayList();
  int x;
  int y;
  String selectedText = "";


  public TextSelectionBox()
  {
    x = 900;
    y = 300;

    strings.add("hello");
    strings.add("Copper Plates");
    strings.add("Copper Ore");
  }

  int getWidth()
  {
    return 275;
  }

  int getHeight()
  {
    return 30 * strings.size() + 5;
  }

  public boolean contains(int x, int y)
  {
    if (x < this.x)
      return false;
    if (x > this.x + getWidth())
      return false;
    if (y < this.y)
      return false;
    if (y > this.y + getHeight())
      return false;

    return true;
  }

  public void clicked(int x, int y)
  {
    if (!contains(x, y))
      return;
      
    int index = (y - this.y) / 30;
    
    if (index >= 0 && index < strings.size())
    selectedText = strings.get(index);
  }

  public void draw()
  {
    fill(255, 255, 255);
    rect(x, y, getWidth(), getHeight());

    fill(0, 0, 0);
    for (int i = 0; i < strings.size(); ++i)
    {
      text(strings.get(i), x + 5, y + 25 + 30 * i);
    }
    //text(app_global.selectionBox.selectedText, 800, 100);
  }
}
