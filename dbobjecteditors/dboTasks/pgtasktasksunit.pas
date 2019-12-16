{ Free DB Manager

  Copyright (C) 2005-2019 Lagunov Aleksey  alexs75 at yandex.ru

  This source is free software; you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 2 of the License, or (at your option)
  any later version.

  This code is distributed in the hope that it will be useful, but WITHOUT ANY
  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
  details.

  A copy of the GNU General Public License is available on the World Wide Web
  at <http://www.gnu.org/copyleft/gpl.html>. You can also obtain it by writing
  to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
  MA 02111-1307, USA.
}

unit pgTaskTasksUnit;

{$I fbmanager_define.inc}

interface

uses
  Classes, SysUtils, FileUtil, rxtooledit, RxTimeEdit, rxtoolbar, Forms,
  Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, ComCtrls, CheckLst, Menus,
  ActnList, SQLEngineAbstractUnit, PostgreSQLEngineUnit, pg_tasks,
  fdmAbstractEditorUnit, fbmSqlParserUnit;

type

  { TpgTaskShedulePage }

  TpgTaskShedulePage = class(TEditorPage)
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    minUnselectAll: TAction;
    minSelectAll: TAction;
    hrSelectAll: TAction;
    hrUnselectAll: TAction;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    mnUnselectAll: TAction;
    mnSelectAll: TAction;
    domSelectAll: TAction;
    domUnSelectAll: TAction;
    dowSelectAll: TAction;
    dowUnSelectAll: TAction;
    ActionList1: TActionList;
    CheckBox1: TCheckBox;
    CheckListBox1: TCheckListBox;
    CheckListBox2: TCheckListBox;
    CheckListBox3: TCheckListBox;
    CheckListBox4: TCheckListBox;
    CheckListBox5: TCheckListBox;
    Edit1: TEdit;
    Edit2: TEdit;
    HeaderControl1: THeaderControl;
    HeaderControl2: THeaderControl;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    ListBox1: TListBox;
    Memo1: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    PopupMenu1: TPopupMenu;
    PopupMenu2: TPopupMenu;
    PopupMenu3: TPopupMenu;
    PopupMenu4: TPopupMenu;
    PopupMenu5: TPopupMenu;
    RxDateEdit1: TRxDateEdit;
    RxDateEdit2: TRxDateEdit;
    RxTimeEdit1: TRxTimeEdit;
    RxTimeEdit2: TRxTimeEdit;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    Splitter5: TSplitter;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    ToolPanel1: TToolPanel;
    ToolPanel2: TToolPanel;
    ToolPanel3: TToolPanel;
    ToolPanel4: TToolPanel;
    ToolPanel5: TToolPanel;
    procedure CheckListBox1Click(Sender: TObject);
    procedure dowSelectAllExecute(Sender: TObject);
    procedure HeaderControl1SectionResize(HeaderControl: TCustomHeaderControl;
      Section: THeaderSection);
    procedure ListBox1Click(Sender: TObject);
    procedure Panel1Resize(Sender: TObject);
  private
    FModified:boolean;
    FCurShedule:TPGTaskShedule;
    procedure LoadTaskData;
    procedure RefreshTaskData;
    procedure ClearData;
    procedure FillLists;
    procedure CompileShedule;
    procedure AddShedule;
    procedure DelShedule;
    function CurrentItem:TPGTaskShedule;
  public
    function PageName:string;override;
    function DoMetod(PageAction:TEditorPageAction):boolean;override;
    function ActionEnabled(PageAction:TEditorPageAction):boolean;override;
    procedure Localize;override;
    constructor CreatePage(TheOwner: TComponent; ADBObject:TDBObject); override;
    function SetupSQLObject(ASQLObject:TSQLCommandDDL):boolean; override;
  end;

implementation
uses fbmStrConstUnit;

{$R *.lfm}

{ TpgTaskShedulePage }

procedure TpgTaskShedulePage.ListBox1Click(Sender: TObject);
var
//  U: TPGTaskShedule;
  i: Integer;
begin
  if (ListBox1.Items.Count>0) and (ListBox1.ItemIndex>-1) and (ListBox1.ItemIndex<ListBox1.Items.Count) then
  begin
    if Assigned(FCurShedule) then
    begin
      if FModified then
        CompileShedule;
    end;

    FCurShedule:=TPGTaskShedule(ListBox1.Items.Objects[ListBox1.ItemIndex]);
    Edit1.Text:=FCurShedule.Name;
    Edit2.Text:=IntToStr(FCurShedule.ID);
    Memo1.Text:=FCurShedule.Description;
    CheckBox1.Checked:=FCurShedule.Enabled;
    RxDateEdit1.Date:=FCurShedule.DateStart;
    RxDateEdit2.Date:=FCurShedule.DateStart;

    for i:=1 to 7 do
      CheckListBox1.Checked[i-1]:=FCurShedule.DayWeek[i];

    for i:=1 to 32 do
      CheckListBox2.Checked[i-1]:=FCurShedule.DayMonth[i];

    for i:=1 to 12 do
      CheckListBox3.Checked[i-1]:=FCurShedule.Month[i];

    for i:=0 to 23 do
      CheckListBox4.Checked[i]:=FCurShedule.Hours[i];

    for i:=0 to 59 do
      CheckListBox5.Checked[i]:=FCurShedule.Minutes[i];
    FModified:=false
  end;
end;

procedure TpgTaskShedulePage.HeaderControl1SectionResize(
  HeaderControl: TCustomHeaderControl; Section: THeaderSection);
begin
  case Section.OriginalIndex of
    0:Panel1.Width:=Section.Width;
//    1;Panel3.Width:=Section.Width;
    2:Panel3.Width:=Section.Width;
  end;
end;

procedure TpgTaskShedulePage.CheckListBox1Click(Sender: TObject);
var
  U: TPGTaskShedule;
  i: Integer;
begin
  FModified:=true;
  U:=CurrentItem;
  if Assigned(U) then
  begin
    U.Name:=Edit1.Text;
    U.Enabled:=CheckBox1.Checked;
    U.DateStart:=RxDateEdit1.Date + RxTimeEdit1.Time;
    U.DateStop:=RxDateEdit2.Date + RxTimeEdit2.Time;
    U.Description:=Memo1.Lines.Text;

    for i:=0 to CheckListBox1.Items.Count-1 do
      U.DayWeek[i+1]:=CheckListBox1.Checked[i];

    for i:=0 to CheckListBox2.Items.Count-1 do
      U.DayMonth[i+1]:=CheckListBox2.Checked[i];
  end;
end;

procedure TpgTaskShedulePage.dowSelectAllExecute(Sender: TObject);
var
  L: TCheckListBox;
  B: PtrInt;
  i: Integer;
begin
  B:=(Sender as TComponent).Tag;
  case B of
    1, -1:L:=CheckListBox1;
    2, -2:L:=CheckListBox2;
    3, -3:L:=CheckListBox3;
    4, -4:L:=CheckListBox4;
    5, -5:L:=CheckListBox5;
  end;

  for i:=0 to L.Items.Count-1 do
    L.Checked[i]:=B > 0;
end;

procedure TpgTaskShedulePage.Panel1Resize(Sender: TObject);
begin
  HeaderControl1.Sections[0].Width:=Panel1.Width;
  HeaderControl1.Sections[1].Width:=Panel2.Width;
  HeaderControl1.Sections[2].Width:=Panel3.Width;
end;

procedure TpgTaskShedulePage.LoadTaskData;
var
  U, U1:TPGTaskShedule;
begin
  ClearData;
  for U1 in TPGTask(DBObject).Shedule do
  begin
    U:=TPGTaskShedule.Create(nil);
    U.Assign(U1);

    ListBox1.Items.AddObject(U.Name, U);
    U.Index:=ListBox1.Items.Count-1;
  end;

  if ListBox1.Items.Count>0 then
  begin
    ListBox1.ItemIndex:=0;
    ListBox1Click(nil);
  end;
end;

procedure TpgTaskShedulePage.RefreshTaskData;
begin
  DBObject.RefreshObject;
  LoadTaskData;
end;

procedure TpgTaskShedulePage.ClearData;
var
  i: Integer;
  U:TPGTaskShedule;
begin
  for i:=0 to ListBox1.Items.Count-1 do
  begin
    U:=TPGTaskShedule(ListBox1.Items.Objects[i]);
    ListBox1.Items.Objects[i]:=nil;
    if Assigned(U) then
      U.Free;
  end;
  ListBox1.Items.Clear;
end;

procedure TpgTaskShedulePage.FillLists;
var
  i: Integer;
begin
  CheckListBox1.Items.Clear;
  for i:=1 to 7 do
    CheckListBox1.Items.Add(DefaultFormatSettings.LongDayNames[i]);

  CheckListBox2.Items.Clear;
  for i:=1 to 31 do
    CheckListBox2.Items.Add(IntToStr(i));
  CheckListBox2.Items.Add('Last day');

  CheckListBox3.Items.Clear;
  for i:=1 to 12 do
    CheckListBox3.Items.Add(DefaultFormatSettings.LongMonthNames[i]);

  CheckListBox4.Items.Clear;
  for i:=0 to 23 do
    CheckListBox4.Items.Add(IntToStr(i));

  CheckListBox5.Items.Clear;
  for i:=0 to 59 do
    CheckListBox5.Items.Add(IntToStr(i));
end;

procedure TpgTaskShedulePage.CompileShedule;
var
  i, FIndex: Integer;
begin
  if FModified and Assigned(FCurShedule) then
  begin
    FIndex:=FCurShedule.Index;
    FCurShedule.Name         := Edit1.Text;
    FCurShedule.Description         := Memo1.Text;
    FCurShedule.Enabled      := CheckBox1.Checked;
    FCurShedule.DateStart    := RxDateEdit1.Date;
    FCurShedule.DateStop     := RxDateEdit2.Date;

    for i:=1 to 7 do
      FCurShedule.DayWeek[i]:=CheckListBox1.Checked[i-1];

    for i:=1 to 32 do
      FCurShedule.DayMonth[i]:=CheckListBox2.Checked[i-1];

    for i:=1 to 12 do
      FCurShedule.Month[i]:=CheckListBox3.Checked[i-1];

    for i:=0 to 23 do
      FCurShedule.Hours[i]:=CheckListBox4.Checked[i];

    for i:=0 to 59 do
      FCurShedule.Minutes[i]:=CheckListBox5.Checked[i];

    TPGTask(DBObject).CompileTaskShedule(FCurShedule);

    FModified:=false;
    LoadTaskData;
    ListBox1.ItemIndex:=FIndex;
    ListBox1Click(nil);
  end;
end;

procedure TpgTaskShedulePage.AddShedule;
var
  U: TPGTaskShedule;
begin
  U:=TPGTaskShedule.Create(TPGTask(DBObject));
  ListBox1.Items.Add(U.Name);
  ListBox1.Items.Objects[ListBox1.Items.Count-1]:=U;
  U.Index:=ListBox1.Items.Count-1;
  U.Name:=sShedule + ' '+IntToStr(U.Index+1);
  ListBox1.Items[U.Index]:=U.Name;
  ListBox1.ItemIndex:=U.Index;
  ListBox1Click(nil);
  FModified:=true;
  FCurShedule:=U;
end;

procedure TpgTaskShedulePage.DelShedule;
begin
  if Assigned(FCurShedule) then
  begin
    TPGTask(DBObject).DeleteTaskShedule(FCurShedule);
    FCurShedule:=nil;
    LoadTaskData;
  end;
end;

function TpgTaskShedulePage.CurrentItem: TPGTaskShedule;
begin
  Result:=nil;
  if (ListBox1.ItemIndex>-1) and (ListBox1.ItemIndex < ListBox1.Items.Count) then
    Result:=TPGTaskShedule(ListBox1.Items.Objects[ListBox1.ItemIndex]);
end;

function TpgTaskShedulePage.PageName: string;
begin
  Result:=sShedule;
end;

function TpgTaskShedulePage.DoMetod(PageAction: TEditorPageAction): boolean;
begin
  case PageAction of
    epaAdd:AddShedule;
    epaDelete:DelShedule;
    epaRefresh:RefreshTaskData;
//    epaPrint,
    epaCompile:CompileShedule;
  end;
end;

function TpgTaskShedulePage.ActionEnabled(PageAction: TEditorPageAction
  ): boolean;
begin
  Result:=PageAction in [epaRefresh, epaPrint, epaCompile, epaAdd, epaDelete ];
end;

procedure TpgTaskShedulePage.Localize;
begin
  inherited Localize;
  TabSheet1.Caption:=sProperty;
  TabSheet2.Caption:=sDays;
  TabSheet3.Caption:=sTimes;
  TabSheet4.Caption:=sExcep;
  HeaderControl1.Sections[0].Text:=sDayOfWeek;
  HeaderControl1.Sections[1].Text:=sDayOfMonth;
  HeaderControl1.Sections[2].Text:=sMonth;

  HeaderControl2.Sections[0].Text:=sHours;
  HeaderControl2.Sections[1].Text:=sMinutes;

  Label1.Caption:=sCaption;
  CheckBox1.Caption:=sEnabled;
  Label3.Caption:=sDateStart;
  Label5.Caption:=sDateFinish;
  Label4.Caption:=sTime;
  Label7.Caption:=sDescription;

  dowSelectAll.Caption:=sSelectAll;
  dowUnSelectAll.Caption:=sUnselectAll;
  domSelectAll.Caption:=sSelectAll;
  domUnSelectAll.Caption:=sUnselectAll;
  mnSelectAll.Caption:=sSelectAll;
  mnUnSelectAll.Caption:=sUnselectAll;
  hrSelectAll.Caption:=sSelectAll;
  hrUnSelectAll.Caption:=sUnselectAll;
  minSelectAll.Caption:=sSelectAll;
  minUnSelectAll.Caption:=sUnselectAll;
end;

constructor TpgTaskShedulePage.CreatePage(TheOwner: TComponent;
  ADBObject: TDBObject);
begin
  inherited CreatePage(TheOwner, ADBObject);
  FillLists;
  Panel1Resize(nil);

  LoadTaskData;
end;

function TpgTaskShedulePage.SetupSQLObject(ASQLObject: TSQLCommandDDL): boolean;
var
  FCmd: TPGSQLTaskCreate;
  U: TPGTaskShedule;
  I: Integer;
begin
  if ASQLObject is TPGSQLTaskCreate then
  begin
    Result:=true;
    FCmd:=TPGSQLTaskCreate(ASQLObject);
    for I:=0 to ListBox1.Items.Count -1 do
    begin
      U:=FCmd.TaskShedule.Add;
      U.Assign(TPGTaskShedule(ListBox1.Items.Objects[i]));
    end;
  end
  else
    Result:=false;
end;

end.

