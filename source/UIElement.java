import Colourful.*;
public interface UIElement
{
  void setActive(boolean state);
  boolean isActive();
  boolean isVisible();
  boolean isClickable();
  void setVisible(boolean state);
  void click();
  void onClick();
  void Display();
}
