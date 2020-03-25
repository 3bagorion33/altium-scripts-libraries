Procedure StartScript ();
var
   Board              : IPCB_Board;         //���������� ������� �������� �����
   X                  : Tcoord;             //���������� X - ����� ������ ����������
   Y                  : Tcoord;             //���������� Y - ����� ������ ����������

   ComponentIterator  : IPCB_BoardIterator; //�������� �����������
   Comp               : IPCB_Component;     //��������� ���������� ����� ��������
   CompItog           : IPCB_Component;     //��������� ���������
   X1                 : Tcoord;             //���������� X - ������� ��������� � ���������
   Y1                 : Tcoord;             //���������� Y - ������� ��������� � ���������
   d                  : real;               //����� �� ����������
   dOld               : real;               //����� �� ���������� � ����������� ������

   lyrMehPairs        : IPCB_MechanicalLayerPairs; // ���������� ���������� ���� ������������ �����
   LayerM1            : Tlayer;                    // ������ ������������ ����
   LayerM2            : Tlayer;                    // ������ ������������ ����
   CurrentLayer       : integer;            //������ �������� ����

   Area               : Tcoord;


Begin  // StartScript
       CurrentLayer  := eTopLayer;  //������������� ���������� �������� ���� ��������� �� ���������

       Board := PCBServer.GetCurrentPCBBoard;

       if Board = nil then // �������� �� ������� �������� �������� �����
          Begin
               ShowError('Open Board!');
               Exit;
          end;

       Area := Board.SnapGridSize*2.1;
       Board.ChooseLocation(X,Y,'Choose Component'); //�������� ��������� �� �����

       //*******����������� ������� ������� �����*****
       if (board.CurrentLayer = eTopLayer) | (board.CurrentLayer = eTopPaste) | (board.CurrentLayer =eTopOverlay)
       then CurrentLayer  := eTopLayer;
       if (board.CurrentLayer = eBottomLayer) | (board.CurrentLayer = eBottomPaste) | (board.CurrentLayer =eBottomOverlay)
       then CurrentLayer  := eBottomLayer;
       lyrMehPairs := Board.MechanicalPairs;
       for LayerM1 := 1 to 32 do
           for LayerM2 := LayerM1 to 32 do
           begin
                if lyrMehPairs.PairDefined(PCBServer.LayerUtils.MechanicalLayer(LayerM1),PCBServer.LayerUtils.MechanicalLayer(LayerM2)) then
                begin
                     if Board.CurrentLayer =  PCBServer.LayerUtils.MechanicalLayer(LayerM1) then CurrentLayer  := eTopLayer;
                     if Board.CurrentLayer =  PCBServer.LayerUtils.MechanicalLayer(LayerM2) then CurrentLayer  := eBottomLayer;
                end;
           end;
       //******����� ����������� ������� ������� �����*****

       ComponentIterator := Board.BoardIterator_Create; // ������� ���� �������� �� �����
       ComponentIterator.AddFilter_ObjectSet(MkSet(eComponentObject));  //������ �������� ������ �����������.
       ComponentIterator.AddFilter_LayerSet(MkSet(CurrentLayer));        //������ ������ ����������� �� ������������ ����.
       ComponentIterator.AddFilter_Method(eProcessAll);                 //����� ��������.

       Comp := ComponentIterator.FirstPCBObject;                        //��������� ������� ����������.
       CompItog := Comp;                                                //������������� ������� ��������.
       X1 := Comp.x;
       Y1 := Comp.y;
       dOld := sqrt(sqr(X1-X)+sqr(Y1-Y));
       While (Comp <> Nil) Do  //���� �������� �����������
       Begin
            X1:=Comp.x;
            Y1:=Comp.y;
            d := sqrt(sqr(X1-X)+sqr(Y1-Y));
            if d <= Area then   // ����������� ������ ������� ��� ������ �������� ����������.
            begin
               CompItog := Comp;
               Break;
            end;

            if d < dOld then   // ����� ���������� �� �������� - ��������� � �����
            begin
                 CompItog := Comp;
                 dOld := d;
            end;
        Comp := ComponentIterator.NextPCBObject;
       end;
       Board.BoardIterator_Destroy(ComponentIterator);

      If CompItog <> Nil then CompItog.Selected := true;
      Board.ViewManager_FullUpdate;
End;
