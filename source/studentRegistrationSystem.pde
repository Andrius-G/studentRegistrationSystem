////////////////////////////////////////////////
// Student Registration System                //
// Author: Andrius Gasiukevičius              //
////////////////////////////////////////////////
import processing.core.PApplet;
import processing.core.PImage;
import Colourful.*;
import javax.swing.*;
import javax.swing.filechooser.*;
import java.io.FileReader;
import java.io.FileWriter;
import java.awt.*;
import java.util.*;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.FormulaEvaluator;
import org.apache.poi.ss.usermodel.Row;
import java.io.FileOutputStream;
import java.io.FileInputStream;
import com.itextpdf.kernel.pdf.PdfDocument; 
import com.itextpdf.kernel.pdf.PdfWriter; 
import com.itextpdf.layout.Document;

public class studentRegistrationSystem extends PApplet
{
  String path; /////////////////////// #Debug1 //////////////////////////
  PImage background;
  boolean haveReleasedKey=false;
  int lastKeyReleased=0;
  public static int SCALE=2;
  public boolean debugMode=true;
  public boolean developingMode=false;
  public static ArrayList<UIElement>allUI;
  void resizePoint(PImage img16, int scaleX, int scaleY) /////////////////////// #resize //////////////////////////
  {
    int resizeW = img16.width * scaleX;
    int resizeH = img16.height * scaleY;
    
    int imgW = img16.width;
    //int imgH = img16.height;
    
    img16.loadPixels();
    int[] oldPixels = img16.pixels;
    
    PImage resizedIMG = createImage(resizeW,resizeH,ARGB);
    
    resizedIMG.loadPixels();
    
    for(int i=0; i<resizeH; ++i)
      for(int j=0; j<resizeW; ++j)
        resizedIMG.pixels[i*resizeW+j] = oldPixels[(int)(((i/scaleY)*imgW)) + (int)(((j/scaleX)))];
    
    resizedIMG.updatePixels();
    
    img16.resize(resizeW,resizeH);
    
    img16.copy(resizedIMG,0,0,resizeW,resizeH,0,0,resizeW,resizeH);
  }
  abstract class StaticUIComponent implements UIElement /////////////////////// #StaticUIComponent #Sprite #Base //////////////////////////
  {
    int x;
    int y;
    int W;
    int H;
    Colour colour;
    Colour border;
    Boolean isActive;
    Boolean clickable;
    Boolean clicked=false;
    Boolean isVisible=true;
    StaticUIComponent(int x, int y, int W, int H)
    {
      this.x=x;
      this.y=y;
      this.W=W;
      this.H=H;
      this.border = new Colour("black");
      this.colour = new Colour(0,0,0,0);
      isActive=true;
      clickable=false;
      allUI.add(this);
    }
    boolean isActive()
    {
      return isActive;
    }
    void setColour(Colour c)
    {
      colour=c;
    }
    void setBorder(Colour c)
    {
      border=c;
    }
    void setW(int W)
    {
      this.W=W;
    }
    void setH(int H)
    {
      this.H=H;
    }
    void setActive(boolean state)
    {
      isActive=state;
    }
    void setVisible(boolean state)
    {
      isVisible=state;
    }
    boolean isVisible()
    {
      return isVisible;
    }
    boolean isClickable()
    {
      return clickable;
    }
    void click()
    {
      if(clickable&&mousePressed&&mouseX>=x&&mouseX<x+W&&mouseY>=y&&mouseY<y+H)
      {
        clicked=true;
      }
      if(clicked&&mousePressed==false)
      {
        clicked=false;
        onClick();
      }
    }
    abstract void onClick();
    abstract void Display();
  }
  public class Rectangle implements UIElement /////////////////////// #Rectangle //////////////////////////
  {
    int x;
    int y;
    int W;
    int H;
    Colour colour;
    Colour border;
    Boolean isActive;
    Boolean clickable;
    Boolean clicked=false;
    Boolean isVisible=true;
    Rectangle(int x, int y, int W, int H)
    {
      this.x=x;
      this.y=y;
      this.W=W;
      this.H=H;
      this.border = new Colour("black");
      this.colour = new Colour(0,0,0,0);
      isActive=true;
      clickable=false;
      allUI.add(this);
    }
    void setColour(Colour c)
    {
      colour=c;
    }
    void setBorder(Colour c)
    {
      border=c;
    }
    void setW(int W)
    {
      this.W=W;
    }
    void setH(int H)
    {
      this.H=H;
    }
    boolean isActive()
    {
      return isActive;
    }
    boolean isVisible()
    {
      return isVisible;
    }
    boolean isClickable()
    {
      return clickable;
    }
    void setActive(boolean state)
    {
      isActive=state;
    }
    void setVisible(boolean state)
    {
      isVisible=state;
    }
    void click()
    {
      if(clickable&&mousePressed&&mouseX>=x&&mouseX<x+W&&mouseY>=y&&mouseY<y+H)
      {
        clicked=true;
      }
      if(clicked&&mousePressed==false)
      {
        clicked=false;
        onClick();
      }
    }
    @Override void onClick()
    {
      
    }
    @Override void Display()
    {
      stroke(border.R,border.G,border.B,border.alpha);
      fill(colour.R,colour.G,colour.B,colour.alpha);
      rect(x,y,W,H);
    }
    void ShiftUp(int y)
    {
      this.y-=y;
    }
  }
  public class StudentCell extends Rectangle /////////////////////// #StudentCell //////////////////////////
  {
    public boolean cellSelected=false;
    StudentCell(int x, int y, int W, int H)
    {
      super(x,y,W,H);
      clickable=true;
    }
    @Override void onClick()
    {
      cellSelected=true;
      attendanceInterface.updateStudents(false);
      //System.out.println("Clicked "+this+" at "+str(x)+", "+str(y));
    }
  }
  class CreateGroupInterface extends Rectangle /////////////////////// #CreateGroupInterface #Interface #GroupInterface //////////////////////////
  {
    boolean creatingGroup = false;
    Text toBeAdded;
    Text groupNameText;
    ArrayList<Student>studentsBeingAdded = new ArrayList<Student>();
    InputField studentName;
    InputField studentID;
    InputField groupName;
    CreateGroupButton creatingGroupButton;
    AddGroupStudentButton addStudentButton;
    
    int padding = 10*SCALE;
    
    CreateGroupInterface(int x, int y, int W, int H)
    {
      super(x,y,W,H);
      toBeAdded = new Text("",x+padding,y+padding,(W-(2*padding)),(H-(2*padding))*3/4);
      toBeAdded.setActive(false);
      
      studentName = new InputField(x+4*padding,y+padding+((H-(2*padding))*3/4)+padding+padding,(W-(4*padding))/4,H-padding-(padding+((H-(2*padding))*3/4)+padding)-padding);
      studentName.setDisplayText("Name: ");
      studentName.displayText.setSize(8*SCALE);
      studentName.displayInput.setSize(6*SCALE);
      studentName.displayInput.colour=new Colour("black");
      studentName.setImage("square.png");
      studentName.colour = new Colour(0,0,0,32);
      studentName.centerDisplayText();
      studentName.setMode("string");
      studentName.setActive(false);
      
      studentID = new InputField(x+4*padding+((W-(4*padding))/4)+2*padding,y+padding+((H-(2*padding))*3/4)+padding+padding,(W-(4*padding))/4,H-padding-(padding+((H-(2*padding))*3/4)+padding)-padding);
      studentID.setDisplayText("ID: ");
      studentID.displayText.setSize(8*SCALE);
      studentID.displayInput.setSize(6*SCALE);
      studentID.displayInput.colour=new Colour("black");
      studentID.setImage("square.png");
      studentID.colour = new Colour(0,0,0,32);
      studentID.centerDisplayText();
      studentID.setActive(false);
      
      addStudentButton = new AddGroupStudentButton("",x+4*padding+((W-(4*padding))/4)+2*padding+((W-(4*padding))/4)+padding,y+padding+((H-(2*padding))*3/4)+padding+padding,(W-(4*padding))/12,H-padding-(padding+((H-(2*padding))*3/4)+padding)-padding);
      creatingGroupButton = new CreateGroupButton("",x+4*padding+((W-(4*padding))/4)+2*padding+((W-(4*padding))/4)+padding+((W-(4*padding))/12)+padding,y+padding+((H-(2*padding))*3/4)+padding+padding,(W-(4*padding))/12,H-padding-(padding+((H-(2*padding))*3/4)+padding)-padding);
      creatingGroupButton.setActive(false);
      addStudentButton.setActive(false);
      
      groupName = new InputField(x+4*padding+((W-(4*padding))/4)+2*padding+((W-(4*padding))/4)+padding+((W-(4*padding))/12)+padding+((W-(4*padding))/12)+padding,y+padding+((H-(2*padding))*3/4)+padding+padding+padding,(W-(4*padding))/6,H-padding-(padding+((H-(2*padding))*3/4)+padding)-padding-padding-padding);
      groupName.setDisplayText("");
      groupName.displayText.setSize(6*SCALE);
      groupName.displayInput.setSize(6*SCALE);
      groupName.displayInput.colour=new Colour("black");
      groupName.setImage("square.png");
      groupName.colour = new Colour(0,0,0,32);
      groupName.centerDisplayText();
      groupName.setMode("string");
      groupName.setActive(false);
      
      groupNameText = new Text("Group Name: ",x+4*padding+((W-(4*padding))/4)+2*padding+((W-(4*padding))/4)+padding+((W-(4*padding))/12)+padding+((W-(4*padding))/12)+padding,y+padding+((H-(2*padding))*3/4)+padding+padding,(W-(4*padding))/6,H-padding-(padding+((H-(2*padding))*3/4)+padding)-padding-padding-padding);
      groupNameText.setSize(6*SCALE);
      groupNameText.setActive(false);
    }
    @Override void setVisible(boolean state)
    {
      super.setVisible(state);
      toBeAdded.setVisible(state);
      groupNameText.setVisible(state);
      studentName.setVisible(state);
      studentID.setVisible(state);
      groupName.setVisible(state);
      creatingGroupButton.setVisible(state);
      addStudentButton.setVisible(state);
    }
    void addStudent(Student s)
    {
      if(studentsBeingAdded.size()==0)
      {
        toBeAdded.setText("'"+s.name+"' ("+s.id+")");
      }
      else
      {
        toBeAdded.setText(toBeAdded.text+", '"+s.name+"' ("+s.id+")");
      }
      studentsBeingAdded.add(s);
      studentName.displayInput.text="";
      studentName.inputName="";
      studentName.enteringText=false;
      studentID.displayInput.text="";
      studentID.input=0f;
      studentID.enteringText=false;
    }
    void createGroup()
    {
      Group G;
      if(findGroup(groupName.getInputName())==null)
      {
        G = new Group(groupName.getInputName(),studentsBeingAdded);
        for(int i=0; i<studentsBeingAdded.size(); ++i)
        {
          studentsBeingAdded.get(i).addGroup(G);
        }
      }
      else
      {
        G = findGroup(groupName.getInputName());
        for(int i=0; i<studentsBeingAdded.size(); ++i)
        {
          if(G.students.contains(studentsBeingAdded.get(i))==false)
          {
            studentsBeingAdded.get(i).addGroup(G);
            G.addStudent(studentsBeingAdded.get(i));
          }
        }
      }
      
      studentsBeingAdded = new ArrayList<Student>();
      groupName.displayInput.text="";
      groupName.inputName="";
      groupName.enteringText=false;
      toBeAdded.setText("");
    }
    @Override void Display()
    {
      super.Display();
      toBeAdded.Display();
      studentName.Display();
      studentID.Display();
      groupName.Display();
      addStudentButton.Display();
      groupNameText.Display();
      creatingGroupButton.Display();
      
      if(addStudentButton.addingStudentToGroup == true)
      {
        addStudentButton.addingStudentToGroup=false;
        if(findStudent((int)studentID.getInput(),studentName.getInputName())==null)
        {
          addStudent(new Student((int)studentID.getInput(),studentName.getInputName()));
        }
        else
        {
          addStudent(findStudent((int)studentID.getInput(),studentName.getInputName()));
        }
      }
      if(creatingGroupButton.creatingGroup == true)
      {
        creatingGroupButton.creatingGroup=false;
        createGroup();
      }
      if(groupName.doneEnteringText==true)
      {
        groupName.doneEnteringText=false;
        if(findGroup(groupName.getInputName())!=null)
        {
          Group G=findGroup(groupName.getInputName());
          for(int i=0; i<G.students.size(); ++i)
          {
            Student s=G.students.get(i);
            if(studentsBeingAdded.size()==0)
            {
              toBeAdded.setText("'"+s.name+"' ("+s.id+")");
            }
            else
            {
              toBeAdded.setText(toBeAdded.text+", '"+s.name+"' ("+s.id+")");
            }
            studentsBeingAdded.add(s);
          }
        }
      }
    }
  }
  class AttendanceTableInterface extends Rectangle /////////////////////// #AttendanceTableInterface #Interface #TableInterface #StudentInterface //////////////////////////
  {
    Tabular attendanceTable;
    InputField studentName;
    InputField studentID;
    InputField groupName;
    Checkbox groupFilter;
    Checkbox studentFilter;
    Checkbox markedFilter;
    RemoveStudentButton removingStudentButton;
    AddGroupStudentButton addingStudentButton;
    boolean markedDays[];
    
    int padding = 10*SCALE;
    
    AttendanceTableInterface(int x, int y, int W, int H)
    {
      super(x,y,W,H);
      String[] tempLabels = new String[33];
      markedDays = new boolean[32];
      tempLabels[0]="Student Name";
      tempLabels[1]="Student ID";
      for(int i=1; i<=31; ++i)
      {
        if(i<10)tempLabels[i+1]=str(0)+str(i);
        else tempLabels[i+1]=str(i);
      }
      attendanceTable = new Tabular(new Data(33),x+padding,y+padding,(W-(2*padding)),(H-(2*padding))*3/4,tempLabels);
      attendanceTable.updateCellWidths(0,0,50*SCALE);
      attendanceTable.updateCellWidths(1,1,50*SCALE);
      attendanceTable.updateCellWidths(2,32,((W-(2*padding))-100*SCALE)/31);
      attendanceTable.setActive(false);
      
      studentName = new InputField(x+4*padding,y+padding+((H-(2*padding))*3/4)+padding+padding,(W-(4*padding))/4,(H-padding-(padding+((H-(2*padding))*3/4)+padding)-padding)/2);
      studentName.setDisplayText("Name: ");
      studentName.displayText.setSize(8*SCALE);
      studentName.displayInput.setSize(6*SCALE);
      studentName.displayInput.colour=new Colour("black");
      studentName.setImage("square.png");
      studentName.colour = new Colour(0,0,0,32);
      studentName.centerDisplayText();
      studentName.setMode("string");
      studentName.setActive(false);
      
      groupName = new InputField(x+4*padding,y+padding+((H-(2*padding))*3/4)+padding+(padding/2)+(H-padding-(padding+((H-(2*padding))*3/4)+padding)-padding)/2+padding,(W-(4*padding))/4,(H-padding-(padding+((H-(2*padding))*3/4)+padding)-padding)/2);
      groupName.setDisplayText("Group: ");
      groupName.displayText.setSize(8*SCALE);
      groupName.displayInput.setSize(6*SCALE);
      groupName.displayInput.colour=new Colour("black");
      groupName.setImage("square.png");
      groupName.colour = new Colour(0,0,0,32);
      groupName.centerDisplayText();
      groupName.setMode("string");
      groupName.setActive(false);
      
      groupFilter = new Checkbox("Gr. Filter",x+4*padding+(W-(4*padding))/4+padding,y+padding+((H-(2*padding))*3/4)+padding+(padding/2)+(H-padding-(padding+((H-(2*padding))*3/4)+padding)-padding)/2+padding,(W-(4*padding))/4-2*padding,(H-padding-(padding+((H-(2*padding))*3/4)+padding)-padding)/2);
      groupFilter.setActive(false);
      
      studentFilter = new Checkbox("Stud. Filter",x+4*padding+(W-(4*padding))/4+(W-(4*padding))/4,y+padding+((H-(2*padding))*3/4)+padding+(padding/2)+(H-padding-(padding+((H-(2*padding))*3/4)+padding)-padding)/2+padding,(W-(4*padding))/4,(H-padding-(padding+((H-(2*padding))*3/4)+padding)-padding)/2);
      studentFilter.setActive(false);
      
      markedFilter = new Checkbox("Marked Filter",x+4*padding+(W-(4*padding))/4+padding+(W-(4*padding))/4+(W-(4*padding))/4,y+padding+((H-(2*padding))*3/4)+padding+(padding/2)+(H-padding-(padding+((H-(2*padding))*3/4)+padding)-padding)/2+padding,(W-(4*padding))/4,(H-padding-(padding+((H-(2*padding))*3/4)+padding)-padding)/2);
      markedFilter.setActive(false);
      
      studentID = new InputField(x+4*padding+((W-(4*padding))/4)+2*padding,y+padding+((H-(2*padding))*3/4)+padding+padding,(W-(4*padding))/4,(H-padding-(padding+((H-(2*padding))*3/4)+padding)-padding)/2);
      studentID.setDisplayText("ID: ");
      studentID.displayText.setSize(8*SCALE);
      studentID.displayInput.setSize(6*SCALE);
      studentID.displayInput.colour=new Colour("black");
      studentID.setImage("square.png");
      studentID.colour = new Colour(0,0,0,32);
      studentID.centerDisplayText();
      studentID.setActive(false);
      
      addingStudentButton = new AddGroupStudentButton("",x+4*padding+((W-(4*padding))/4)+2*padding+((W-(4*padding))/4)+padding,y+padding+((H-(2*padding))*3/4)+padding+padding,(H-padding-(padding+((H-(2*padding))*3/4)+padding)-padding)/2,(H-padding-(padding+((H-(2*padding))*3/4)+padding)-padding)/2);
      removingStudentButton = new RemoveStudentButton("",x+4*padding+((W-(4*padding))/4)+2*padding+((W-(4*padding))/4)+padding+((W-(4*padding))/12)+padding,y+padding+((H-(2*padding))*3/4)+padding+padding,(H-padding-(padding+((H-(2*padding))*3/4)+padding)-padding)/2,(H-padding-(padding+((H-(2*padding))*3/4)+padding)-padding)/2);
      addingStudentButton.setActive(false);
      removingStudentButton.setActive(false);
    }
    @Override void setVisible(boolean state)
    {
      super.setVisible(state);
      attendanceTable.setVisible(state);
      groupFilter.setVisible(state);
      studentFilter.setVisible(state);
      markedFilter.setVisible(state);
      studentName.setVisible(state);
      studentID.setVisible(state);
      groupName.setVisible(state);
      removingStudentButton.setVisible(state);
      addingStudentButton.setVisible(state);
    }
    void addStudent(Student s)
    {
      studentName.displayInput.text="";
      studentName.inputName="";
      studentName.enteringText=false;
      studentID.displayInput.text="";
      studentID.input=0f;
      studentID.enteringText=false;
    }
    void removeStudent(Student s)
    {
      for(int i=0; i<s.Groups.size(); ++i)
      {
        s.Groups.get(i).students.remove(s);
      }
      s.Groups.clear();
      allStudents.remove(s);
      studentName.displayInput.text="";
      studentName.inputName="";
      studentName.enteringText=false;
      studentID.displayInput.text="";
      studentID.input=0f;
      studentID.enteringText=false;
    }
    void updateStudents(boolean studentAdded)
    {
      int excludedDays=0;
      for(int i=1; i<=31; ++i)
      {
        if(!(markedFilter.pressed==false||(markedFilter.pressed&&markedDays[i])))
        {
          excludedDays++;
        }
      }
      String[] tempLabels = new String[33-excludedDays];
      tempLabels[0]="Student Name";
      tempLabels[1]="Student ID";
      excludedDays=0;
      for(int i=1; i<=31; ++i)
      {
        if(markedFilter.pressed==false||(markedFilter.pressed&&markedDays[i]))
        {
          if(i<10)tempLabels[i+1-excludedDays]=str(0)+str(i);
          else tempLabels[i+1-excludedDays]=str(i);
        }
        else
        {
          excludedDays++;
        }
      }
      Data studentData = new Data(33-excludedDays);
      if(attendanceTable!=null&&!studentAdded)
      {
        for(int i=0; i<allStudents.size(); ++i)
        {
          for(int d=1; d<=attendanceTable.cols-2; ++d)
          {
            if(attendanceTable.tableSquares[d+1][i+1].cellSelected==true)
            {
              int D=Integer.parseInt(attendanceTable.tableTexts[d+1][0].text);
              //attendanceTable.tableSquares[d+1][i+1].cellSelected=false;
              //System.out.println(attendanceTable.tableTexts[0][i+1].text+": "+str(D+1)+" "+str(i+1));
              allStudents.get(i).attendanceDays[D]=!allStudents.get(i).attendanceDays[D];
              markedDays[D]=true;
            }
          }
        }
      }
      for(int i=0; i<allStudents.size(); ++i)
      {
        boolean takeThisStudent=true;
        if(groupFilter.pressed)
        {
          Group G = findGroup(groupName.getInputName());
          if(G==null)takeThisStudent=false;
          else if(G.students.contains(allStudents.get(i))==false)
          {
            takeThisStudent=false;
          }
        }
        if(studentFilter.pressed)
        {
          Student S = findStudent((int)studentID.getInput(),studentName.getInputName());
          if(allStudents.get(i)!=S)
          {
            takeThisStudent=false;
          }
        }
        if(takeThisStudent==true)
        {
          studentData.setCurrentDataset(0);
          studentData.addData(allStudents.get(i).name);
          studentData.setCurrentDataset(1);
          studentData.addData(str(allStudents.get(i).id));
          int missedDays=0;
          for(int d=1; d<=31; ++d)
          {
            if(markedFilter.pressed==false||(markedFilter.pressed&&markedDays[d]))
            {
              studentData.setCurrentDataset(d+1-missedDays);
              if(allStudents.get(i).attendanceDays[d]==true)
              {
                studentData.addData("+");
              }
              else
              {
                studentData.addData("");
              }
            }
            else missedDays++;
          }
        }
      }
      attendanceTable.clearTabular();
      attendanceTable = new Tabular(studentData,x+padding,y+padding,(W-(2*padding)),(H-(2*padding))*3/4,tempLabels);
      attendanceTable.updateCellWidths(0,0,50*SCALE);
      attendanceTable.updateCellWidths(1,1,50*SCALE);
      attendanceTable.updateCellWidths(2,32-excludedDays,((W-(2*padding))-(100*SCALE))/31);
      attendanceTable.setActive(false);
    }
    @Override void Display()
    {
      super.Display();
      attendanceTable.Display();
      studentName.Display();
      groupName.Display();
      groupFilter.Display();
      studentFilter.Display();
      markedFilter.Display();
      studentID.Display();
      addingStudentButton.Display();
      removingStudentButton.Display();
      
      if(addingStudentButton.addingStudentToGroup == true)
      {
        addingStudentButton.addingStudentToGroup=false;
        if(findStudent((int)studentID.getInput(),studentName.getInputName())==null)
        {
          addStudent(new Student((int)studentID.getInput(),studentName.getInputName()));
        }
        else
        {
          addStudent(findStudent((int)studentID.getInput(),studentName.getInputName()));
        }
        updateStudents(true);
      }
      if(removingStudentButton.removingStudent == true)
      {
        removingStudentButton.removingStudent=false;
        if(findStudent((int)studentID.getInput(),studentName.getInputName())!=null)
        {
          removeStudent(findStudent((int)studentID.getInput(),studentName.getInputName()));
        }
        updateStudents(true);
      }
      if(groupFilter.justPressed == true || groupName.doneEnteringText == true)
      {
        groupFilter.justPressed=false;
        groupName.doneEnteringText=false;
        updateStudents(true);
      }
      if(studentFilter.justPressed == true || studentName.doneEnteringText == true || studentID.doneEnteringText == true)
      {
        studentFilter.justPressed=false;
        studentName.doneEnteringText=false;
        studentID.doneEnteringText=false;
        updateStudents(true);
      }
      if(markedFilter.justPressed == true)
      {
        markedFilter.justPressed=false;
        updateStudents(true);
      }
    }
  }
  Student findStudent(int id, String name)
  {
    for(int i=0; i<allStudents.size(); ++i)
    {
      if(allStudents.get(i).name.equals(name)&&allStudents.get(i).id==id)
      {
        return allStudents.get(i);
      }
    }
    return null;
  }
  Student findStudent(int id)
  {
    for(int i=0; i<allStudents.size(); ++i)
    {
      if(allStudents.get(i).id==id)
      {
        return allStudents.get(i);
      }
    }
    return null;
  }
  Group findGroup(String name)
  {
    for(int i=0; i<allGroups.size(); ++i)
    {
      if(allGroups.get(i).name.equals(name))
      {
        return allGroups.get(i);
      }
    }
    return null;
  }
  class Text extends StaticUIComponent /////////////////////// #Text //////////////////////////
  {
    String text;
    int size;
    int realW;
    Colour colour; //hiding fields
    Colour border;
    Text(String text, int x, int y, int W, int H)
    {
      super(x,y,W,H);
      realW=W;
      size=12*SCALE;
      this.setText(text);
      colour = new Colour("black");
      border = new Colour(0,0,0,0);
    }
    void setColour(Colour c)
    {
      colour=c;
    }
    void setSize(int size)
    {
      this.size=size;
    }
    void setText(String text)
    {
      this.text=text;
      textSize(size);
      realW=(int)textWidth(text);
    }
    void shiftUp(int y)
    {
      this.y+=y;
    }
    @Override void onClick()
    {
      
    }
    @Override void Display()
    {
      //super.Display(); //application of hiding fields - display bounding boxes (IF UNCOMMENTED)
      textSize(size);
      fill(colour.R,colour.G,colour.B,colour.alpha);
      stroke(border.R,border.G,border.B,border.alpha);
      text(text,x,y,W,H);
    }
  }
  abstract class StaticButton extends StaticUIComponent /////////////////////// #StaticButton //////////////////////////
  {
    PImage displayImage;
    Text displayText;
    Boolean hasImage;
    Boolean hasText;
    StaticButton(int x, int y, int W, int H)
    {
      super(x,y,W,H);
      clickable=true;
      hasImage=false;
      hasText=false;
    }
    StaticButton(String text, int x, int y, int W, int H)
    {
      super(x,y,W,H);
      clickable=true;
      displayText=new Text(text,x,y,W,H);
      displayText.setActive(false);
      hasImage=false;
      hasText=true;
      centerDisplayText();
    }
    @Override void setVisible(boolean state)
    {
      super.setVisible(state);
      displayText.setVisible(state);
    }
    void setImage(String s)
    {
      displayImage=loadImage(path+"Assets/"+s);
      resizePoint(displayImage,4,4);
      hasImage=true;
    }
    void centerDisplayText()
    {
      if(hasText==false)return;
      displayText.x=x+max(0,(W/2)-(displayText.realW/2));
      displayText.y=y+((H/2)-(displayText.size/2));
    }
    void offsetDisplayText(int dx, int dy)
    {
      if(hasText==false)return;
      displayText.x+=dx;
      displayText.y+=dy;
    }
    void setDisplayText(String s)
    {
      allUI.remove(displayText);
      displayText = new Text(s,x,y,W,H);
      displayText.setActive(false);
      hasText=true;
      centerDisplayText();
    }
    @Override void Display()
    {
      if(hasImage==false)
      {
        stroke(border.R,border.G,border.B,border.alpha);
        fill(colour.R,colour.G,colour.B,colour.alpha);
        rect(x,y,W,H);
      }
      else
      {
        image(displayImage,x,y,W,H);
      }
      if(hasText==true)
      {
        displayText.Display();
      }
    }
  }
  class RadioButton extends StaticButton /////////////////////// #RadioButton //////////////////////////
  {
    PImage activeImage;
    Boolean pressed=false;
    ArrayList<RadioButton>affectedButtons;
    RadioButton(int x, int y, int W, int H, ArrayList<RadioButton> aff)
    {
      super(x,y,W,H);
      setImage("circle.png");
      setActiveImage("radio_pressed.png");
      affectedButtons=aff;
    }
    RadioButton(String s, int x, int y, int W, int H, ArrayList<RadioButton> aff)
    {
      super(s,x,y,W,H);
      displayText=new Text(s,x,y,W,H);
      displayText.setActive(false);
      setImage("circle.png");
      setActiveImage("radio_pressed.png");
      offsetDisplayText(displayImage.width/8,0);
      affectedButtons=aff;
    }
    void setActiveImage(String s)
    {
      activeImage=loadImage(path+"Assets/"+s);
      resizePoint(activeImage,4,4);
    }
    @Override void onClick()
    {
      for(int i=0; i<affectedButtons.size(); ++i)
      {
        affectedButtons.get(i).pressed=false;
      }
      pressed=true;
    }
    @Override void Display()
    {
      if(!pressed)
      {
        image(displayImage,x,y,displayImage.width/8,displayImage.height/8);
      }
      else
      {
        image(activeImage,x,y,activeImage.width/8,activeImage.height/8);
      }
      if(hasText==true)
      {
        displayText.Display();
      }
    }
  }
  class InputField extends Rectangle /////////////////////// #InputField //////////////////////////
  {
    PImage displayImage;
    Text displayText;
    float input=0f;
    String inputName="";
    Text displayInput;
    Boolean hasImage;
    Boolean hasText;
    Boolean enteringText=false;
    Boolean doneEnteringText = false;
    Boolean floatPointPressed=false;
    Boolean justClicked=false;
    Boolean forgetful = false;
    float powOfTen=0.1f;
    String mode = "float";
    InputField(int x, int y, int W, int H)
    {
      super(x,y,W,H);
      clickable=true;
      hasImage=false;
      hasText=false;
      displayInput = new Text("",x,y,W,H);
      displayInput.setActive(false);
    }
    InputField(String text, int x, int y, int W, int H)
    {
      super(x,y,W,H);
      clickable=true;
      displayText=new Text(text,x,y,W,H);
      displayText.x-=displayText.realW;
      displayText.setActive(false);
      displayInput=new Text("",x,y,W,H);
      displayInput.setActive(false);
      hasImage=false;
      hasText=true;
    }
    @Override void setVisible(boolean state)
    {
      super.setVisible(state);
      displayText.setVisible(state);
      displayInput.setVisible(state);
    }
    float getInput()
    {
      return input;
    }
    String getInputName()
    {
      return inputName;
    }
    void setForgetful(boolean b)
    {
      forgetful=b;
    }
    void setImage(String s)
    {
      displayImage=loadImage(path+"Assets/"+s);
      resizePoint(displayImage,4,4);
      hasImage=true;
    }
    void offsetDisplayText(int dx, int dy)
    {
      if(hasText==false)return;
      displayText.x+=dx;
      displayText.y+=dy;
    }
    void setDisplayText(String s)
    {
      if(hasText)displayText.x+=displayText.realW;
      allUI.remove(displayText);
      displayText = new Text(s,x,y,W,H);
      //System.out.println(s+str(displayText.realW)+" "+str(W));
      displayText.x=x-min(W,displayText.realW);
      displayText.setActive(false);
      hasText=true;
    }
    void setMode(String s)
    {
      mode=s;
    }
    void centerDisplayText(int W)
    {
      if(hasText==false)return;
      Text previousDT = displayText;
      displayText=new Text(displayText.text,x,y,W,H);
      allUI.remove(previousDT);
      displayText.x-=displayText.realW;
      displayText.setActive(false);
      displayText.y=displayText.y+((H/2)-(displayText.size/2));
      displayInput.y=displayInput.y+((H/2)-(displayInput.size/2));
    }
    void centerDisplayText()
    {
      if(hasText==false)return;
      displayText.y=displayText.y+((H/2)-(displayText.size/2));
      displayInput.y=displayInput.y+((H/2)-(displayInput.size/2));
    }
    void centerDisplayInput()
    {
      displayInput.x=x+max(0,(W/2)-(displayInput.realW/2));
    }
    @Override void onClick()
    {
      enteringText=true;
      justClicked=true;
      doneEnteringText = false;
    }
    void enterInput()
    {
      if(justClicked)
      {
        haveReleasedKey=false;
        justClicked=false;
        return;
      }
      if(haveReleasedKey==false)return;
      haveReleasedKey=false;
      if(mode.equals("string"))
      {
        for(int i=0; i<26; ++i)
        {
          if(lastKeyReleased==i+'a')
          {
            inputName+=((char)(i+'a'));
            displayInput.setText(displayInput.text+(char)(i+'a'));
          }
          if(lastKeyReleased==i+'A')
          {
            inputName+=((char)(i+'A'));
            displayInput.setText(displayInput.text+(char)(i+'A'));
          }
        }
        for(int i=0; i<=9; ++i)
        {
          if(lastKeyReleased==i+'0')
          {
            inputName+=((char)(i+'0'));
            displayInput.setText(displayInput.text+(char)(i+'0'));
          }
        }
        if(lastKeyReleased==' ')
        {
          inputName+=" ";
          displayInput.setText(displayInput.text+(char)(' '));
        }
        if(lastKeyReleased==BACKSPACE)
        {
          if(inputName.length()>0)
          {
            inputName = inputName.substring(0,inputName.length()-1);
            displayInput.setText(inputName);
          }
        }
      }
      else
      {
        if(floatPointPressed==false)
        {
          for(int i=0; i<=9; ++i)
          {
            if(lastKeyReleased==i+'0')
            {
              input*=10;
              input+=i;
              displayInput.setText(displayInput.text+(char)(i+'0'));
            }
          }
          if(lastKeyReleased=='.'||lastKeyReleased==',')
          {
            floatPointPressed=true;
            displayInput.setText(displayInput.text+'.');
          }
          if(lastKeyReleased==BACKSPACE)
          {
            input=(int)(input/10);
            if(displayInput.text.length()>0)
            {
              String s="";
              for(int j=0; j<displayInput.text.length()-1; ++j)
              {
                s+=displayInput.text.charAt(j);
              }
              displayInput.setText(s);
            }
          }
        }
        else
        {
          for(int i=0; i<=9; ++i)
          {
            if(lastKeyReleased==i+'0')
            {
              input+=(powOfTen*i);
              powOfTen/=10;
              displayInput.setText(displayInput.text+(char)(i+'0'));
            }
          }
          if(lastKeyReleased==BACKSPACE)
          {
            if(displayInput.text.charAt(displayInput.text.length()-1)=='.')
            {
              floatPointPressed=false;
            }
            else
            {
              input=input-((((int)(input/(powOfTen*10)))%10)*(powOfTen*10));
              powOfTen*=10;
            }
            if(displayInput.text.length()>0)
            {
              String s="";
              for(int j=0; j<displayInput.text.length()-1; ++j)
              {
                s+=displayInput.text.charAt(j);
              }
              displayInput.setText(s);
            }
          }
        }
      }
      if(lastKeyReleased==ENTER||lastKeyReleased==RETURN)
      {
        enteringText=false;
        doneEnteringText = true;
      }
      centerDisplayInput();
      //System.out.println(input);
    }
    @Override void Display()
    {
      if(enteringText)
      {
        enterInput();
      }
      if(hasImage==false)
      {
        super.Display();
      }
      else
      {
        image(displayImage,x,y,W,H);
      }
      if(hasText==true)
      {
        displayText.Display();
      }
      displayInput.Display();
    }
  }
  class RadioButtonList extends StaticUIComponent /////////////////////// #RadioButtonList //////////////////////////
  {
    ArrayList<RadioButton>buttons;
    int textHeight=8*SCALE;
    Text displayText;
    boolean hasText=false;
    RadioButtonList(int x, int y, int W, int H)
    {
      super(x,y,W,H);
      buttons = new ArrayList<RadioButton>();
    }
    RadioButtonList(String text, int x, int y, int W, int H)
    {
      super(x,y,W,H);
      buttons = new ArrayList<RadioButton>();
      setDisplayText(text);
    }
    @Override void setVisible(boolean state)
    {
      super.setVisible(state);
      displayText.setVisible(state);
      for(int i=0; i<buttons.size(); ++i)
      {
        buttons.get(i).setVisible(state);
      }
    }
    void addButton(String text)
    {
      buttons.add(new RadioButton(text,x,y+(textHeight*buttons.size()),W,H,buttons));
      if(buttons.size()==1)buttons.get(0).pressed=true;
      buttons.get(buttons.size()-1).setActive(false);
    }
    void offsetDisplayText(int dx, int dy)
    {
      if(hasText==false)return;
      displayText.x+=dx;
      displayText.y+=dy;
    }
    int pressedButton()
    {
      for(int i=0; i<buttons.size(); ++i)
      {
        if(buttons.get(i).pressed==true)
        {
          return i;
        }
      }
      return -1;
    }
    void setDisplayText(String s)
    {
      if(hasText)displayText.x+=displayText.realW;
      Text previousDT = displayText;
      displayText = new Text(s,x,y,W,H);
      allUI.remove(previousDT);
      displayText.x-=displayText.realW;
      displayText.setActive(false);
      hasText=true;
    }
    void centerDisplayText()
    {
      if(hasText==false)return;
      displayText.y=displayText.y+((H/2)-(displayText.size/2));
    }
    @Override void onClick()
    {
      
    }
    @Override void Display()
    {
      for(int i=0; i<buttons.size(); ++i)
      {
        buttons.get(i).Display();
      }
      if(hasText==true)
      {
        displayText.Display();
      }
    }
  }
  class Point extends Rectangle /////////////////////// #Point //////////////////////////
  {
    PImage displayImage;
    boolean hasImage=false;
    boolean hasLabel=false;
    boolean labelHidden=false;
    Text label;
    float xFloat;
    float yFloat;
    int xLabelOffset=5;
    int yLabelOffset=5;
    int xImageOffset=0;
    int yImageOffset=0;
    int maxImageX=32;
    int maxImageY=32;
    int maxLabelW=100;
    int maxLabelH=100;
    Point(float x, float y)
    {
      super(int(x),int(y),1,1);
      xFloat=x;
      yFloat=y;
      hasImage=false;
    }
    Point(int x, int y)
    {
      super(x,y,1,1);
      xFloat=x;
      yFloat=y;
      hasImage=false;
    }
    Point(float x, float y, String img)
    {
      super(int(x),int(y),1,1);
      xFloat=x;
      yFloat=y;
      displayImage=loadImage(path+"Assets/"+img);
      resizePoint(displayImage,4,4);
      hasImage=true;
    }
    Point(int x, int y, String img)
    {
      super(x,y,1,1);
      xFloat=x;
      yFloat=y;
      displayImage=loadImage(path+"Assets/"+img);
      resizePoint(displayImage,4,4);
      hasImage=true;
    }
    Point(float x, float y, PImage img)
    {
      super(int(x),int(y),1,1);
      xFloat=x;
      yFloat=y;
      displayImage=img;
      hasImage=true;
    }
    Point(int x, int y, PImage img)
    {
      super(x,y,1,1);
      xFloat=x;
      yFloat=y;
      displayImage=img;
      hasImage=true;
    }
    Point(Point other)
    {
      super(other.x,other.y,1,1);
      this.xFloat=other.xFloat;
      this.yFloat=other.yFloat;
      this.displayImage=other.displayImage;
      this.hasImage=other.hasImage;
      this.hasLabel=other.hasLabel;
      this.labelHidden=other.labelHidden;
      this.label=other.label;
      this.xLabelOffset=other.xLabelOffset;
      this.yLabelOffset=other.yLabelOffset;
      this.xImageOffset=other.xImageOffset;
      this.yImageOffset=other.yImageOffset;
      this.maxImageX=other.maxImageX;
      this.maxImageY=other.maxImageY;
      this.maxLabelW=other.maxLabelW;
      this.maxLabelH=other.maxLabelH;
    }
    @Override void setVisible(boolean state)
    {
      super.setVisible(state);
      label.setVisible(state);
    }
    void Translate(int x, int y)
    {
      int dx=x-this.x;
      int dy=y-this.y;
      this.x=x;
      this.y=y;
      if(label!=null)
      {
        label.x+=dx;
        label.y+=dy;
      }
    }
    void setLabelOffset(int dx, int dy)
    {
      xLabelOffset=dx;
      yLabelOffset=dy;
      if(hasLabel)
      {
        label.x=x+xLabelOffset;
        label.y=y+yLabelOffset;
      }
    }
    void setImageOffset(int dx, int dy)
    {
      xImageOffset=dx;
      yImageOffset=dy;
    }
    void setImage(String s)
    {
      displayImage=loadImage(path+"Assets/"+s);
      resizePoint(displayImage,4,4);
      hasImage=true;
    }
    void setLabel(String s)
    {
      allUI.remove(label);
      Text t=new Text(s,x+xLabelOffset,y+yLabelOffset,maxLabelW,maxLabelH);
      label=t;
      t.setActive(false);
      hasLabel=true;
    }
    void setLabel(Text t)
    {
      label=t;
      t.setActive(false);
      hasLabel=true;
    }
    void hideLabel()
    {
      labelHidden=true;
    }
    void showLabel()
    {
      labelHidden=false;
    }
    @Override void Display()
    {
      if(hasImage==false)
      {
        super.Display();
      }
      else
      {
        image(displayImage,x+xImageOffset,y+yImageOffset,maxImageX,maxImageY);
      }
      if(hasLabel==true&&labelHidden==false)
      {
        label.Display();
      }
    }
  }
  String roundF(float f, int d) /////////////////////// #Rounding //////////////////////////
  {
    float ff=f;
    for(int i=0; i<d; ++i)
    {
      ff*=10;
    }
    int fff=round(ff);
    String ans="";
    for(int i=0; i<d; ++i)
    {
      char ch=(char)((fff%10)+'0');
      fff/=10;
      ans = ch + ans;
    }
    if(d>0)
    {
      ans = "." + ans;
    }
    ans = str(fff)+ans;
    return ans;
  }
  class Data /////////////////////// #Data //////////////////////////
  {
    int currentDataset=0;
    int maxDatasets=10;
    
    ArrayList<ArrayList<String>>dataPoints;
    
    Data(int maxDatasets)
    {
      dataPoints = new ArrayList<ArrayList<String>>();
      this.maxDatasets=maxDatasets;
      for(int i=0; i<maxDatasets; ++i)
      {
        dataPoints.add(new ArrayList<String>());
      }
    }
    void setMaxDatasets(int mx)
    {
      if(mx>maxDatasets)
      {
        for(int i=0; i<mx-maxDatasets; ++i)
        {
          dataPoints.add(new ArrayList<String>());
        }
      }
      else if(mx<maxDatasets)
      {
        for(int i=maxDatasets-1; i>=maxDatasets-(maxDatasets-mx); i--)
        {
          dataPoints.remove(i);
        }
      }
      maxDatasets=mx;
      currentDataset=0;
    }
    void setCurrentDataset(int ds)
    {
      currentDataset=ds;
    }
    void addData(String data)
    {
      dataPoints.get(currentDataset).add(data);
    }
  }
  class Tabular extends Rectangle /////////////////////// #Table #Tabular //////////////////////////
  {
    int cols;
    int rows;
    int cellH;
    int cellW;
    int startRow=0;
    Data D;
    String[] labels;
    int maxRows=20;
    StudentCell tableSquares[][];
    Text tableTexts[][];
    int cellWidths[];
    Tabular(Data D, int x, int y, int W, int H, String[] labels)
    {
      super(x,y,W,H);
      cols = D.maxDatasets;
      rows = D.dataPoints.get(0).size() + 1;
      if(labels.length<cols)
      {
        System.out.println(str(cols)+ "Uh Oh");
        return;
      }
      cellW = W / cols;
      cellH = H / maxRows;
      cellWidths = new int[cols];
      for(int i=0; i<cols; ++i)
      {
        cellWidths[i]=cellW;
      }
      tableSquares = new StudentCell[cols][rows];
      tableTexts = new Text[cols][rows];
      this.labels=labels;
      this.D=D;
    }
    @Override void setVisible(boolean state)
    {
      super.setVisible(state);
      for(int i=0; i<cols; ++i)
      {
        for(int j=0; j<rows; ++j)
        {
          tableSquares[i][j].setVisible(state);
          tableTexts[i][j].setVisible(state);
        }
      }
    }
    /*void bookmarkTabular(int book) // Becomes highlighted in Processing due to unused local variable. Doesn't work after implementing interfaces.
    {
      
    }*/
    void clearTabular()
    {
      for(int i=0; i<cols; ++i)
      {
        for(int j=0; j<rows; ++j)
        {
          allUI.remove(tableSquares[i][j]);
          allUI.remove(tableTexts[i][j]);
        }
      }
      allUI.remove(this);
    }
    void updateTabular()
    {
      int cellWSum=0;
      for(int i=0; i<cols; ++i)
      {
        for(int j=1; j<rows; ++j)
        {
          if(tableSquares[i][j]!=null)tableSquares[i][j].setActive(false);
          allUI.remove(tableSquares[i][j]);
          tableSquares[i][j] = new StudentCell(x+(cellWSum),y+(j*cellH)-(startRow*cellH),cellWidths[i],cellH);
          tableSquares[i][j].setColour(new Colour(255,255,240,240));
          tableSquares[i][j].setActive(false);
          if(D.dataPoints.get(i).size()<j)
          {
            D.dataPoints.get(i).add("");
          }
          if(tableTexts[i][j]!=null)tableTexts[i][j].setActive(false);
          allUI.remove(tableTexts[i][j]);
          tableTexts[i][j] = new Text(D.dataPoints.get(i).get(j-1),x+(cellWSum),y+(j*cellH)-(startRow*cellH),cellWidths[i],cellH);
          tableTexts[i][j].setSize(7*SCALE);
          tableTexts[i][j].setActive(false);
        }
        cellWSum+=cellWidths[i];
      }
      for(int j=1; j<rows; ++j) //first two cols
      {
        tableSquares[0][j].setColour(new Colour(240,150,255,255));
        tableTexts[0][j].setColour(new Colour("red"));
        tableTexts[0][j].setSize(7*SCALE);
        
        tableSquares[1][j].setColour(new Colour(240,150,255,255));
        tableTexts[1][j].setColour(new Colour("red"));
        tableTexts[1][j].setSize(7*SCALE);
      }
      cellWSum=0;
      for(int i=0; i<cols; ++i)
      {
        if(tableSquares[i][0]!=null)tableSquares[i][0].setActive(false);
        allUI.remove(tableSquares[i][0]);
        tableSquares[i][0] = new StudentCell(x+(cellWSum),y,cellWidths[i],cellH);
        tableSquares[i][0].setColour(new Colour(0,0,50,255));
        tableSquares[i][0].setActive(false);
        
        if(tableTexts[i][0]!=null)tableTexts[i][0].setActive(false);
        allUI.remove(tableTexts[i][0]);
        tableTexts[i][0] = new Text(labels[i],x+(cellWSum),y,cellWidths[i],cellH);
        tableTexts[i][0].setColour(new Colour("white"));
        tableTexts[i][0].setSize(7*SCALE);
        tableTexts[i][0].setActive(false);
        cellWSum+=cellWidths[i];
      }
    }
    void updateCellWidths(int colL, int colR, int wide)
    {
      for(int col=colL; col<=colR; ++col)
      {
        W+=(wide-cellWidths[col]);
        cellWidths[col]=wide;
      }
      updateTabular();
    }
    @Override void Display()
    {
      for(int i=0; i<cols; ++i)
      {
        for(int j=startRow; j<startRow+min(rows,maxRows); ++j)
        {
          tableSquares[i][j].Display();
          tableTexts[i][j].Display();
        }
        tableSquares[i][0].Display(); //layers
        tableTexts[i][0].Display();
      }
    }
  }
  class StringTable /////////////////////// #Table #StringTable //////////////////////////
  {
    Tabular UITable;
    String[][] table;
    StringTable(Tabular pt)
    {
      UITable=pt;
      table = new String[UITable.cols][UITable.rows];
      for(int i=0; i<UITable.cols; ++i)
      {
        for(int j=0; j<UITable.rows; ++j)
        {
          table[i][j]=UITable.tableTexts[i][j].text;
        }
      }
    }
  }
  class Checkbox extends StaticButton /////////////////////// #Checkbox //////////////////////////
  {
    PImage activeImage;
    Boolean pressed=false;
    Boolean justPressed=false;
    Checkbox(int x, int y, int W, int H)
    {
      super(x,y,W,H);
      setImage("rounded.png");
      setActiveImage("rounded_checker.png");
    }
    Checkbox(String s, int x, int y, int W, int H)
    {
      super(s,x,y,W,H);
      displayText=new Text(s,x,y,W,H);
      displayText.setActive(false);
      setImage("rounded.png");
      setActiveImage("rounded_checker.png");
      offsetDisplayText(displayImage.width/8,0);
    }
    void setActiveImage(String s)
    {
      activeImage=loadImage(path+"Assets/"+s);
      resizePoint(activeImage,4,4);
    }
    @Override void onClick()
    {
      pressed=!pressed;
      justPressed=true;
    }
    @Override void Display()
    {
      if(!pressed)
      {
        image(displayImage,x,y,displayImage.width/8,displayImage.height/8);
      }
      else
      {
        image(activeImage,x,y,activeImage.width/8,activeImage.height/8);
      }
      if(hasText==true)
      {
        displayText.Display();
      }
    }
  }
  class HiddenRangeInput extends StaticUIComponent /////////////////////// #HiddenRangeInput #HiddenInput //////////////////////////
  {
    Checkbox checker;
    InputField LRange;
    InputField RRange;
    HiddenRangeInput(int x, int y, int W, int H, String text, String left, String right)
    {
      super(x,y,W,H);
      checker = new Checkbox(text,x+(W/6),y,W/6,H);
      checker.setActive(false);
      
      LRange = new InputField(left,x+(3*(W/6)),y,(W/6),H);
      LRange.setDisplayText(left);
      LRange.displayText.setSize(10*SCALE);
      LRange.displayInput.colour=new Colour("black");
      LRange.setImage("rounded.png");
      LRange.centerDisplayText();
      
      RRange = new InputField(right,x+(5*(W/6)),y,(W/6),H);
      RRange.setDisplayText(right);
      RRange.displayText.setSize(10*SCALE);
      RRange.displayInput.colour=new Colour("black");
      RRange.setImage("rounded.png");
      RRange.centerDisplayText();
      
      LRange.setActive(false);
      RRange.setActive(false);
    }
    @Override void setVisible(boolean state)
    {
      super.setVisible(state);
      checker.setVisible(state);
      LRange.setVisible(state);
      RRange.setVisible(state);
    }
    void setTextSize(int sz)
    {
      checker.displayText.setSize(sz);
    }
    float[] getRange()
    {
      if(checker.pressed==false)
      {
        float[] f = {-1,-1};
        return f;
      }
      float[] f = {LRange.getInput(),RRange.getInput()};
      return f;
    }
    @Override void onClick()
    {
      
    }
    @Override void Display()
    {
      checker.Display();
      if(checker.pressed)
      {
        LRange.Display();
        RRange.Display();
      }
    }
  }
  class TableButton extends StaticButton /////////////////////// #TableButton #FunctionButton //////////////////////////
  {
    TableButton(int x, int y, int W, int H)
    {
      super(x,y,W,H);
    }
    TableButton(String text, int x, int y, int W, int H)
    {
      super(text,x,y,W,H);
    }
    @Override void onClick()
    {
      tabular=true;
    }
  }
  class CreateGroupButton extends StaticButton /////////////////////// #CreateGroupButton #FunctionButton //////////////////////////
  {
    boolean creatingGroup = false;
    CreateGroupButton(int x, int y, int W, int H)
    {
      super(x,y,W,H);
      setImage("tick_button.png");
    }
    CreateGroupButton(String text, int x, int y, int W, int H)
    {
      super(text,x,y,W,H);
      setImage("tick_button.png");
    }
    @Override void onClick()
    {
      creatingGroup=true;
    }
  }
  class AddGroupStudentButton extends StaticButton /////////////////////// #AddGroupStudentButton #FunctionButton //////////////////////////
  {
    boolean addingStudentToGroup = false;
    AddGroupStudentButton(int x, int y, int W, int H)
    {
      super(x,y,W,H);
      setImage("add_button.png");
    }
    AddGroupStudentButton(String text, int x, int y, int W, int H)
    {
      super(text,x,y,W,H);
      setImage("add_button.png");
    }
    @Override void onClick()
    {
      addingStudentToGroup=true;
    }
  }
  class RemoveStudentButton extends StaticButton /////////////////////// #AddGroupStudentButton #FunctionButton //////////////////////////
  {
    boolean removingStudent = false;
    RemoveStudentButton(int x, int y, int W, int H)
    {
      super(x,y,W,H);
      setImage("remove_button.png");
    }
    RemoveStudentButton(String text, int x, int y, int W, int H)
    {
      super(text,x,y,W,H);
      setImage("remove_button.png");
    }
    @Override void onClick()
    {
      removingStudent=true;
    }
  }
  class ExportTableButton extends StaticButton /////////////////////// #ExportTableButton #FunctionButton //////////////////////////
  {
    ExportTableButton(int x, int y, int W, int H)
    {
      super(x,y,W,H);
      setDisplayText("    Export Data...");
      displayText.setSize(8*SCALE);
      setImage("rounded.png");
      centerDisplayText();
    }
    @Override void onClick()
    {
      wantToSave=true;
    }
  }
  class ImportTableButton extends StaticButton /////////////////////// #ExportTableButton #FunctionButton //////////////////////////
  {
    ImportTableButton(int x, int y, int W, int H)
    {
      super(x,y,W,H);
      setDisplayText("    Import Data...");
      displayText.setSize(8*SCALE);
      setImage("rounded.png");
      centerDisplayText();
    }
    @Override void onClick()
    {
      wantToLoad=true;
    }
  }
  class ResetButton extends StaticButton /////////////////////// #ResetButton #FunctionButton //////////////////////////
  {
    ResetButton(int x, int y, int W, int H)
    {
      super(x,y,W,H);
    }
    ResetButton(String text, int x, int y, int W, int H)
    {
      super(text,x,y,W,H);
    }
    @Override void onClick()
    {
      unshowing=true;
    }
  }
  class ShowSaveLoadInterfaceButton extends StaticButton
  {
    ShowSaveLoadInterfaceButton(int x, int y, int W, int H)
    {
      super(x,y,W,H);
    }
    ShowSaveLoadInterfaceButton(String text, int x, int y, int W, int H)
    {
      super(text,x,y,W,H);
    }
    @Override void onClick()
    {
      showingSaveLoadInterface=true;
    }
  }
  class ShowGroupInterfaceButton extends StaticButton /////////////////////// #ResetButton #FunctionButton //////////////////////////
  {
    ShowGroupInterfaceButton(int x, int y, int W, int H)
    {
      super(x,y,W,H);
    }
    ShowGroupInterfaceButton(String text, int x, int y, int W, int H)
    {
      super(text,x,y,W,H);
    }
    @Override void onClick()
    {
      showingGroupInterface=true;
    }
  }
  class PortableFormatButton extends StaticButton
  {
    boolean savingToPDF=false;
    PortableFormatButton(int x, int y, int W, int H)
    {
      super(x,y,W,H);
      setDisplayText("           Save selected range as PDF");
      displayText.setSize(8*SCALE);
      setImage("rounded.png");
      centerDisplayText();
    }
    @Override void onClick()
    {
      savingToPDF=true;
    }
  }
  class Group /////////////////////// #Group //////////////////////////
  {
    String name;
    ArrayList<Student>students;
    Group(String name, ArrayList<Student>students)
    {
      this.name=name;
      this.students = students;
      allGroups.add(this);
    }
    Group(ArrayList<Student>students)
    {
      this.name="";
      this.students = students;
      allGroups.add(this);
    }
    Group()
    {
      this.name="";
      students = new ArrayList<Student>();
      allGroups.add(this);
    }
    void addStudent(Student s)
    {
      students.add(s);
    }
  }
  class Student /////////////////////// #Student //////////////////////////
  {
    int id;
    String name;
    ArrayList<Group>Groups;
    boolean attendanceDays[];
    Student(int id, String name)
    {
      this.id = id;
      this.name = name;
      Groups = new ArrayList<Group>();
      attendanceDays = new boolean[32];
      allStudents.add(this);
    }
    void addGroup(Group G)
    {
      Groups.add(G);
    }
    void setAttendanceDay(int d)
    {
      attendanceDays[d]=true;
    }
  }
  class ImportExportInterface extends Rectangle/////////////////////// #ImportInterface #ExportInterface #Interface //////////////////////////
  {
    InputField monthLFilter;
    InputField monthRFilter;
    ImportTableButton importButton;
    ExportTableButton exportButton;
    PortableFormatButton pdf;
    int padding = 10*SCALE;
    ImportExportInterface(int x, int y, int W, int H)
    {
      super(x,y,W,H);
      monthLFilter = new InputField(x+10*padding,y+8*padding,50*SCALE,20*SCALE);
      monthLFilter.setDisplayText("Only days from:");
      monthLFilter.centerDisplayText(100*SCALE);
      monthLFilter.displayText.setSize(10*SCALE);
      monthLFilter.displayInput.colour=new Colour("black");
      monthLFilter.setImage("rounded.png");
      monthLFilter.colour = new Colour(0,0,0,32);
      
      monthRFilter = new InputField(x+18*padding,y+8*padding,50*SCALE,20*SCALE);
      monthRFilter.setDisplayText("to:   ");
      monthRFilter.displayInput.colour=new Colour("black");
      monthRFilter.setImage("rounded.png");
      monthRFilter.colour = new Colour(0,0,0,32);
      monthRFilter.centerDisplayText();
      
      pdf = new PortableFormatButton(x+25*padding,y+8*padding,150*SCALE,20*SCALE);
      
      importButton = new ImportTableButton(x+10*padding,y+12*padding,60*SCALE,20*SCALE);
      exportButton = new ExportTableButton(x+20*padding,y+12*padding,60*SCALE,20*SCALE);
      
      monthLFilter.setActive(false);
      monthRFilter.setActive(false);
      pdf.setActive(false);
      importButton.setActive(false);
      exportButton.setActive(false);
    }
    @Override void setVisible(boolean state)
    {
      super.setVisible(state);
      monthLFilter.setVisible(state);
      monthRFilter.setVisible(state);
      importButton.setVisible(state);
      exportButton.setVisible(state);
      pdf.setVisible(state);
    }
    @Override void Display()
    {
      super.Display();
      monthLFilter.Display();
      monthRFilter.Display();
      pdf.Display();
      importButton.Display();
      exportButton.Display();
    }
  }
  /////////////////////// #Variables //////////////////////////
  boolean unshowing = false;
  boolean tabular = false;
  boolean grouping = false;
  boolean wantToSave = false;
  boolean idMode = false;
  boolean wantToLoad = false;
  boolean showingGroupInterface = false;
  boolean showingSaveLoadInterface = false;
  TableButton tableButton;
  ExportTableButton saveButton;
  ResetButton resetButton;
  StringTable output;
  InputField delayLRange;
  InputField delayRRange;
  CreateGroupInterface groupInterface;
  AttendanceTableInterface attendanceInterface;
  ShowGroupInterfaceButton showGroupInterface;
  ImportExportInterface saveLoadInterface;
  ShowSaveLoadInterfaceButton showSaveLoadInterface;
  ArrayList<Student>allStudents;
  ArrayList<Group>allGroups;
  //Point pp;
  /////////////////////// #Settings //////////////////////////
  public void settings()
  {
    size(SCALE*640, SCALE*360);
  }
  /////////////////////// #Setup //////////////////////////
  public void setup()
  {
    path = System.getProperty("user.dir").replace("\\","/");
    if(developingMode==true)
    {
      path += "/studentRegistrationSystem";
    }
    path += "/data/";
    
    background = loadImage(path+"Assets/classroom.png");
    resizePoint(background,SCALE,SCALE);
    
    allUI=new ArrayList<UIElement>();
    
    allStudents = new ArrayList<Student>();
    allGroups = new ArrayList<Group>();
    
    tableButton=new TableButton("'; drop all tables;",100*SCALE,25*SCALE,75*SCALE,25*SCALE);
    tableButton.setImage("classic.png");
    tableButton.setDisplayText("   Attendance Table");
    tableButton.displayText.setSize(8*SCALE);
    
    showGroupInterface=new ShowGroupInterfaceButton("hello world",200*SCALE,25*SCALE,75*SCALE,25*SCALE);
    showGroupInterface.setImage("classic.png");
    showGroupInterface.setDisplayText("   Group Interface");
    showGroupInterface.displayText.setSize(8*SCALE);
    showGroupInterface.displayText.setColour(new Colour(125,100,0));
    
    showSaveLoadInterface=new ShowSaveLoadInterfaceButton("hello world",300*SCALE,25*SCALE,75*SCALE,25*SCALE);
    showSaveLoadInterface.setImage("classic.png");
    showSaveLoadInterface.setDisplayText("      Save or Load...");
    showSaveLoadInterface.displayText.setSize(8*SCALE);
    showSaveLoadInterface.displayText.setColour(new Colour(0,100,125));
    
    resetButton=new ResetButton("here we go again",25*SCALE,100*SCALE,25*SCALE,25*SCALE);
    resetButton.setImage("reset.png");
    resetButton.setDisplayText("");
    resetButton.displayText.setSize(8*SCALE);
    resetButton.displayText.setColour(new Colour(125,100,0));
    
    //pp = new Point(60,60,"coin.png");
    
    attendanceInterface = new AttendanceTableInterface(120*SCALE,60*SCALE,400*SCALE,240*SCALE);
    attendanceInterface.setColour(new Colour(240,200,255));
    attendanceInterface.setActive(false);
    attendanceInterface.setVisible(false);
    
    output = new StringTable(attendanceInterface.attendanceTable);
    
    groupInterface = new CreateGroupInterface(120*SCALE,60*SCALE,400*SCALE,240*SCALE);
    groupInterface.setColour(new Colour(255,255,240));
    groupInterface.setActive(false);
    groupInterface.setVisible(false);
    
    saveLoadInterface = new ImportExportInterface(120*SCALE,60*SCALE,400*SCALE,240*SCALE);
    saveLoadInterface.setColour(new Colour(240,255,240));
    saveLoadInterface.setActive(false);
    saveLoadInterface.setVisible(false);
    
    background(background);
  }
  /////////////////////// #Draw #Update #Loop //////////////////////////
  public void draw()
  {
    background(background);
    renderUI();
    doClicks();
    updateMyTable();
    if(wantToSave)
    {
      saveTableToFile();
    }
    if(wantToLoad)
    {
      loadTableFromFile();
    }
    if(saveLoadInterface.pdf.savingToPDF==true)
    {
      saveLoadInterface.pdf.savingToPDF=false;
      saveTableToPDF((int)saveLoadInterface.monthLFilter.getInput(),(int)saveLoadInterface.monthRFilter.getInput());
    }
    if(debugMode==true&&key=='t')
    {
      doDebug();
    }
  }
  /////////////////////// #Export #Save #Load #Import //////////////////////////
  void saveTableToPDF(int L, int R)
  {
    JFileChooser chooseFile = new JFileChooser();
    File currentDirectory;
    currentDirectory = new File(System.getProperty("user.dir").replace("\\","/"));
    chooseFile.setCurrentDirectory(currentDirectory);
    chooseFile.setDialogTitle("Export as PDF");
    chooseFile.setFileFilter(new FileFilter() {
      
      public String getDescription()
      {
        return "Portable Document File (*.pdf)";
      }
      public boolean accept(File thisFile)
      {
        if(thisFile.isDirectory())
        {
          return true;
        }
        else
        {
          String filename = thisFile.getName().toLowerCase();
          return filename.endsWith(".pdf");
        }
      }
    });
    chooseFile.setCurrentDirectory(currentDirectory);
    int returnValue = chooseFile.showOpenDialog(null);
    if(returnValue == JFileChooser.APPROVE_OPTION)
    {
      File selectedFile = chooseFile.getSelectedFile();
      pdfSelected(L,R,selectedFile);
    }
    else
    {
      pdfSelected(L,R,null);
    }
  }
  void saveTableToFile()
  {
    JFileChooser chooseFile = new JFileChooser();
    File currentDirectory;
    currentDirectory = new File(System.getProperty("user.dir").replace("\\","/"));
    chooseFile.setCurrentDirectory(currentDirectory);
    chooseFile.setDialogTitle("Export Data");
    chooseFile.setFileFilter(new FileFilter() {
      
      public String getDescription()
      {
        return "Comma-Separated Value File (*.csv) or Excel Spreadsheet (*.xlsx)";
      }
      public boolean accept(File thisFile)
      {
        if(thisFile.isDirectory())
        {
          return true;
        }
        else
        {
          String filename = thisFile.getName().toLowerCase();
          return filename.endsWith(".csv") || filename.endsWith(".xlsx");
        }
      }
    });
    chooseFile.setCurrentDirectory(currentDirectory);
    int returnValue = chooseFile.showOpenDialog(null);
    if(returnValue == JFileChooser.APPROVE_OPTION)
    {
      File selectedFile = chooseFile.getSelectedFile();
      if(selectedFile.getName().endsWith(".xlsx"))
      {
        fileSelected(selectedFile,"Excel");
      }
      else
      {
        fileSelected(selectedFile,"CSV");
      }
    }
    else
    {
      fileSelected(null,"CSV");
    }
  }
  void loadTableFromFile()
  {
    JFileChooser chooseFile = new JFileChooser();
    File currentDirectory;
    currentDirectory = new File(System.getProperty("user.dir").replace("\\","/"));
    chooseFile.setCurrentDirectory(currentDirectory);
    chooseFile.setDialogTitle("Import Data");
    chooseFile.setFileFilter(new FileFilter() {
      
      public String getDescription()
      {
        return "CSV File (*.csv) or Excel Spreadsheet (*.xlsx)";
      }
      public boolean accept(File thisFile)
      {
        if(thisFile.isDirectory())
        {
          return true;
        }
        else
        {
          String filename = thisFile.getName().toLowerCase();
          return filename.endsWith(".csv") || filename.endsWith(".xlsx");
        }
      }
    });
    chooseFile.setCurrentDirectory(currentDirectory);
    int returnValue = chooseFile.showOpenDialog(null);
    if(returnValue == JFileChooser.APPROVE_OPTION)
    {
      File selectedFile = chooseFile.getSelectedFile();
      if(selectedFile.getName().endsWith(".xlsx"))
      {
        fileSelected(selectedFile,"Excel");
      }
      else
      {
        fileSelected(selectedFile,"CSV");
      }
    }
    else
    {
      fileSelected(null,"CSV");
    }
  }
  /////////////////////// #Export2 #Save2 #Import2 #Load2 //////////////////////////
  void pdfSelected(int L, int R, File selection)
  {
    if(selection == null)
    {
      System.out.println("Saving table as 'my_table.pdf'");
      selection = new File("my_table.pdf");
    }
    try{
    PdfWriter writer = new PdfWriter(selection);
    PdfDocument pdfDoc = new PdfDocument(writer);
    Document doc = new Document(pdfDoc);
    
    int dayL=max(L,1);
    int dayR=min(R,31);
    
    int[] pointColumnWidths = attendanceInterface.attendanceTable.cellWidths;
    float[] realWidths = new float[2+(max(dayR-dayL+1,0))];
    realWidths[0]=(float)pointColumnWidths[0];
    realWidths[1]=(float)pointColumnWidths[1];
    int count=2;
    for(int i=2; i<pointColumnWidths.length; ++i)
    {
      int dayC = i-1;
      if(dayL<=dayC&&dayC<=dayR)
      {
        realWidths[count]=(float)pointColumnWidths[i];
        count++;
      }
    }
    com.itextpdf.layout.element.Table table = new com.itextpdf.layout.element.Table(realWidths);
    
    for(int i=0; i<output.UITable.rows; ++i)
    {
      for(int j=0; j<output.UITable.cols; ++j)
      {
        if(j<2||(dayL<=j-1&&j-1<=dayR))
        {
          table.addCell(new com.itextpdf.layout.element.Cell().add(new com.itextpdf.layout.element.Paragraph(output.table[j][i])));
        }
      }
    }
    
    doc.add(table);
    doc.close();
    System.out.println("Exported to PDF successfully");
    }
    catch(IOException e)
    {
      System.out.println("An error occurred while trying to access the file: " + e.getMessage());
    }
  }
  void fileSelected(File selection, String mode)
  {
    if(wantToSave==true)
    {
      if(mode.equals("CSV"))
      {
        if(selection == null)
        {
          System.out.println("Saving table as 'my_table.csv'");
          selection = new File("my_table.csv");
        }
        try{
          FileWriter myWriter = new FileWriter(selection.getAbsolutePath());
        for(int i=0; i<output.UITable.rows; ++i)
        {
          for(int j=0; j<output.UITable.cols; ++j)
          {
            myWriter.write(output.table[j][i]);
            if(j+1<output.UITable.cols)myWriter.write(",");
            else myWriter.write("\n");
          }
        }
        myWriter.write("\n");
        for(int i=0; i<allGroups.size(); ++i)
        {
          Group G = allGroups.get(i);
          myWriter.write(G.name);
          if(G.students.size()>0)
          {
            myWriter.write(",");
          }
          else
          {
            myWriter.write("\n");
          }
          for(int j=0; j<G.students.size(); ++j)
          {
            myWriter.write(str(G.students.get(j).id));
            if(j+1<G.students.size())myWriter.write(",");
            else myWriter.write("\n");
          }
        }
        myWriter.write("\n");
        myWriter.close();
        }
        catch(IOException e)
        {
          System.out.println("An error occurred while trying to access the file: " + e.getMessage());
        }
      }
      else if(mode.equals("Excel"))
      {
        if(selection == null)
        {
          System.out.println("Saving table as 'my_table.xlsx'");
          selection = new File("my_table.xlsx");
        }
        XSSFWorkbook workbook = new XSSFWorkbook();
        XSSFSheet sheet = workbook.createSheet("Student Data");
        XSSFRow row;
        for(int i=0; i<output.UITable.rows; ++i)
        {
          row = sheet.createRow(i);
          for(int j=0; j<output.UITable.cols; ++j)
          {
            Cell cell = row.createCell(j);
            cell.setCellValue(output.table[j][i]);
          }
        }
        sheet = workbook.createSheet("Student Groups");
        for(int i=0; i<allGroups.size(); ++i)
        {
          row=sheet.createRow(i);
          Group G = allGroups.get(i);
          Cell cell=row.createCell(0);
          cell.setCellValue(G.name);
          for(int j=0; j<G.students.size(); ++j)
          {
            cell=row.createCell(j+1);
            cell.setCellValue((str(G.students.get(j).id)));
          }
        }
        try
        {
        FileOutputStream out = new FileOutputStream(selection);
        workbook.write(out);
        out.close();
        System.out.println("The Excel demons have been banished successfully. (Here's your table!)");
        }
        catch(IOException e)
        {
          System.out.println("An error occurred while trying to save the file: " + e.getMessage());
        }
      }
      wantToSave=false;
    }
    if(wantToLoad==true)
    {
      if(mode.equals("CSV"))
      {
        System.out.println("Loading CSV...");
        if(selection == null)
        {
          System.out.println("Failed to load selected data");
          wantToLoad=false;
        }
        else
        {
          try{
            Data D = new Data(0);
            Data GroupData = new Data(0);
            FileReader myReader = new FileReader(selection.getAbsolutePath());
            char ch=(char)myReader.read();
            System.out.println("Reading CSV data...");
            while(ch!='\n')
            {
              D.setMaxDatasets(D.maxDatasets+1);
              D.setCurrentDataset(D.maxDatasets-1);
              while(ch!='\n')
              {
                String s="";
                while(ch!=',')
                {
                  s+=ch;
                  ch=(char)myReader.read();
                  if(ch=='\n')
                  {
                    break;
                  }
                }
                if(s.equals("\n")==false)
                {
                  D.addData(s);
                }
                if(ch!='\n')
                {
                  ch=(char)myReader.read();
                }
              }
              ch=(char)myReader.read();
            }
            
            System.out.println("Reading CSV group data...");
            ch=(char)myReader.read();
            while(ch!='\n')
            {
              GroupData.setMaxDatasets(GroupData.maxDatasets+1);
              GroupData.setCurrentDataset(GroupData.maxDatasets-1);
              while(ch!='\n')
              {
                String s="";
                while(ch!=',')
                {
                  s+=ch;
                  ch=(char)myReader.read();
                  if(ch=='\n')
                  {
                    break;
                  }
                }
                if(s.equals("\n")==false)
                {
                  GroupData.addData(s);
                }
                if(ch!='\n')
                {
                  ch=(char)myReader.read();
                }
              }
              ch=(char)myReader.read();
            }
            
            /*for(int i=0; i<D.dataPoints.size(); ++i)
            {
              String s="";
              for(int j=0; j<D.dataPoints.get(i).size(); ++j)
              {
                s+=D.dataPoints.get(i).get(j);
                s+=" ";
              }
              System.out.println(s);
            }*///print everything
            
            System.out.println("Clearing old data...");
            groupInterface.createGroup(); //refresh createGroup buffer (everything is cleared immediately after anyways)
            for(int i=0; i<allStudents.size(); ++i)
            {
              Student s = allStudents.get(i);
              for(int j=0; j<s.Groups.size(); ++j)
              {
                s.Groups.get(j).students.remove(s);
              }
              s.Groups.clear();
              allStudents.remove(s);
            }
            allStudents.clear();
            
            System.out.println("Importing student data...");
            attendanceInterface.markedDays = new boolean[32];
            for(int i=1; i<D.maxDatasets; ++i)
            {
              Student S = new Student(Integer.parseInt(D.dataPoints.get(i).get(1)),D.dataPoints.get(i).get(0));
              for(int j=2; j<D.dataPoints.get(i).size(); ++j)
              {
                int day=Integer.parseInt(D.dataPoints.get(0).get(j));
                if(D.dataPoints.get(i).get(j).equals("+"))
                {
                  attendanceInterface.markedDays[day]=true;
                  allStudents.get(i-1).attendanceDays[day]=true;
                }
              }
            }//add students and attendance
            
            System.out.println("Importing groups...");
            for(int i=0; i<GroupData.maxDatasets; ++i)
            {
              groupInterface.groupName.inputName=GroupData.dataPoints.get(i).get(0);
              for(int j=1; j<GroupData.dataPoints.get(i).size(); ++j)
              {
                groupInterface.addStudent(findStudent(Integer.parseInt(GroupData.dataPoints.get(i).get(j))));
              }
              groupInterface.createGroup();
              groupInterface.groupName.inputName="";
            }//add groups
            
            myReader.close();
            attendanceInterface.updateStudents(true);
            System.out.println("Successfully loaded data from CSV file");
          }
          catch(IOException e)
          {
            System.out.println("An error occurred while trying to access the file: " + e.getMessage());
          }
        }
      }
      else if(mode.equals("Excel"))
      {
        System.out.println("Loading Excel...");
        if(selection == null)
        {
          System.out.println("Failed to load selected data");
          wantToLoad=false;
        }
        else
        {
          try{
            FileInputStream file = new FileInputStream(selection);
            
            XSSFWorkbook workbook = new XSSFWorkbook(file);
            XSSFSheet sheet = workbook.getSheetAt(0);
            Iterator<Row> rowIterator = sheet.iterator();
            
            Data D = new Data(0);
            Data GroupData = new Data(0);
            
            System.out.println("Reading Excel data...");
            while(rowIterator.hasNext())
            {
              D.setMaxDatasets(D.maxDatasets+1);
              D.setCurrentDataset(D.maxDatasets-1);
              Row row=rowIterator.next();
              Iterator<Cell>cellIterator=row.cellIterator();
              while(cellIterator.hasNext())
              {
                Cell cell=cellIterator.next();
                D.addData(cell.getStringCellValue());
              }
            }
            
            sheet = workbook.getSheetAt(1);
            rowIterator = sheet.iterator();
            System.out.println("Reading Excel group data...");
            while(rowIterator.hasNext())
            {
              GroupData.setMaxDatasets(GroupData.maxDatasets+1);
              GroupData.setCurrentDataset(GroupData.maxDatasets-1);
              Row row=rowIterator.next();
              Iterator<Cell>cellIterator=row.cellIterator();
              while(cellIterator.hasNext())
              {
                Cell cell=cellIterator.next();
                GroupData.addData(cell.getStringCellValue());
              }
            }
            
            /*for(int i=0; i<D.dataPoints.size(); ++i)
            {
              String s="";
              for(int j=0; j<D.dataPoints.get(i).size(); ++j)
              {
                s+=D.dataPoints.get(i).get(j);
                s+=" ";
              }
              System.out.println(s);
            }*///print everything
            
            System.out.println("Clearing old data...");
            groupInterface.createGroup(); //refresh createGroup buffer (everything is cleared immediately after anyways)
            for(int i=0; i<allStudents.size(); ++i)
            {
              Student s = allStudents.get(i);
              for(int j=0; j<s.Groups.size(); ++j)
              {
                s.Groups.get(j).students.remove(s);
              }
              s.Groups.clear();
              allStudents.remove(s);
            }
            allStudents.clear();
            
            System.out.println("Importing student data...");
            attendanceInterface.markedDays = new boolean[32];
            for(int i=1; i<D.maxDatasets; ++i)
            {
              Student S = new Student(Integer.parseInt(D.dataPoints.get(i).get(1)),D.dataPoints.get(i).get(0));
              for(int j=2; j<D.dataPoints.get(i).size(); ++j)
              {
                int day=Integer.parseInt(D.dataPoints.get(0).get(j));
                if(D.dataPoints.get(i).get(j).equals("+"))
                {
                  attendanceInterface.markedDays[day]=true;
                  allStudents.get(i-1).attendanceDays[day]=true;
                }
              }
            }//add students and attendance
            
            System.out.println("Importing groups...");
            for(int i=0; i<GroupData.maxDatasets; ++i)
            {
              groupInterface.groupName.inputName=GroupData.dataPoints.get(i).get(0);
              for(int j=1; j<GroupData.dataPoints.get(i).size(); ++j)
              {
                groupInterface.addStudent(findStudent(Integer.parseInt(GroupData.dataPoints.get(i).get(j))));
              }
              groupInterface.createGroup();
              groupInterface.groupName.inputName="";
            }//add groups
            
            attendanceInterface.updateStudents(true);
            System.out.println("Successfully loaded data from Excel file");
          }
          catch(IOException e)
          {
            System.out.println("An error occurred while trying to access the file: " + e.getMessage());
          }
        }
      }
      wantToLoad=false;
    }
  }
  /////////////////////// #Render #Active //////////////////////////
  void renderUI()
  {
    for(int i=0; i<allUI.size(); ++i)
    {
      if(allUI.get(i).isActive())
      {
        allUI.get(i).Display();
      }
    }
  }
  /////////////////////// #Click #Action //////////////////////////
  void doClicks()
  {
    for(int i=0; i<allUI.size(); ++i)
    {
      if(allUI.get(i).isClickable()&&allUI.get(i).isVisible())
      {
        allUI.get(i).click();
      }
    }
  }
  /////////////////////// #UpdateTable //////////////////////////
  void updateMyTable()
  {
    if(tabular)
    {
      //System.out.println("Whoops");
      if(tabular)
      {
        tabular=false;
        attendanceInterface.setActive(!attendanceInterface.isActive);
        attendanceInterface.setVisible(!attendanceInterface.isVisible);
        output = new StringTable(attendanceInterface.attendanceTable);
      }
    }
    if(showingGroupInterface)
    {
      showingGroupInterface = false;
      groupInterface.setActive(!groupInterface.isActive);
      groupInterface.setVisible(!groupInterface.isVisible);
    }
    if(showingSaveLoadInterface)
    {
      showingSaveLoadInterface=false;
      saveLoadInterface.setActive(!saveLoadInterface.isActive);
      saveLoadInterface.setVisible(!saveLoadInterface.isVisible);
    }
    if(unshowing)
    {
      unshowing = false;
      attendanceInterface.setActive(false);
      attendanceInterface.setVisible(false);
      groupInterface.setActive(false);
      groupInterface.setVisible(false);
      saveLoadInterface.setActive(false);
      saveLoadInterface.setVisible(false);
    }
  }
  /////////////////////// #Debug2 //////////////////////////
  void doDebug()
  {
    System.out.println("Debug Results:");
    /*System.out.println(linearLoan.stepX);
    System.out.println(linearLoan.scalingFX);
    System.out.println(yearsInput.displayText.realW);
    System.out.println(linearLoan.dataPoints.get(0).get(2).xFloat);
    System.out.println(linearLoan.xAxis.get(2).x);*/
    System.out.println("");
  }
  /////////////////////// #Input //////////////////////////
  public void mouseWheel(MouseEvent roll_down)
  {
    float value = roll_down.getCount();
    if(value < 0)
    {
      if(attendanceInterface.attendanceTable.rows>attendanceInterface.attendanceTable.maxRows)
      {
        attendanceInterface.attendanceTable.startRow=max(attendanceInterface.attendanceTable.startRow-ceil(abs(value)),0);
      }
    }
    else
    {
      if(attendanceInterface.attendanceTable.rows>attendanceInterface.attendanceTable.maxRows)
      {
        attendanceInterface.attendanceTable.startRow=min(attendanceInterface.attendanceTable.startRow+ceil(abs(value)),attendanceInterface.attendanceTable.rows-attendanceInterface.attendanceTable.maxRows);
      }
    }
    attendanceInterface.attendanceTable.updateTabular();
  }
  void keyReleased()
  {
    if(key==CODED)
    {
      lastKeyReleased=keyCode;
    }
    else
    {
      lastKeyReleased=key;
    }
    if(keyCode==123||keyCode==113) // F12 and F2
    {
      //save screenshot
      Calendar C = Calendar.getInstance();
      String name = "";
      name += C.get(Calendar.YEAR);
      name += "-";
      name += String.format("%02d",C.get(Calendar.MONTH)+1);
      name += "-";
      name += C.get(Calendar.DAY_OF_MONTH);
      name += "_";
      name += C.get(Calendar.HOUR_OF_DAY);
      name += C.get(Calendar.MINUTE);
      name += C.get(Calendar.SECOND);
      save(path+"screenshots/"+name+".jpg");
    }
    haveReleasedKey=true;
  }
  public static void main(String[] args)
  {
    PApplet.main("studentRegistrationSystem");
  }
  //(-yAxisStep.width/8)-(p1.label.realW)
}
