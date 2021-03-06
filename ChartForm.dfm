object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Graph'
  ClientHeight = 553
  ClientWidth = 982
  Color = clWhite
  Constraints.MinHeight = 600
  Constraints.MinWidth = 1000
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnPaint = FormPaint
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 16
  object Label1: TLabel
    Left = 0
    Top = 534
    Width = 982
    Height = 19
    Align = alBottom
    Alignment = taRightJustify
    Caption = '(c)Mikhail Kavaleuski '
    Color = clWindowFrame
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Calibri'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    ExplicitLeft = 840
    ExplicitWidth = 142
  end
  object GridPanel1: TGridPanel
    Left = 0
    Top = 0
    Width = 982
    Height = 534
    Align = alClient
    Color = clWhite
    ColumnCollection = <
      item
        Value = 10.000000000000000000
      end
      item
        Value = 9.999999999999998000
      end
      item
        Value = 9.999999999999998000
      end
      item
        Value = 10.000000000000000000
      end
      item
        Value = 10.000000000000000000
      end
      item
        Value = 10.000000000000000000
      end
      item
        Value = 10.000000000000000000
      end
      item
        Value = 10.000000000000000000
      end
      item
        Value = 10.000000000000000000
      end
      item
        Value = 10.000000000000000000
      end>
    ControlCollection = <
      item
        Column = 5
        ColumnSpan = 5
        Control = TimeGraphImage
        Row = 1
        RowSpan = 6
      end
      item
        Column = 0
        ColumnSpan = 5
        Control = SizeGraphImage
        Row = 1
        RowSpan = 6
      end
      item
        Column = 0
        Control = SizeLabel
        Row = 0
      end
      item
        Column = 5
        Control = TimeLabel
        Row = 0
      end>
    ParentBackground = False
    RowCollection = <
      item
        Value = 10.000000000000010000
      end
      item
        Value = 9.999999999999988000
      end
      item
        Value = 9.999999999999982000
      end
      item
        Value = 9.999999999999986000
      end
      item
        Value = 9.999999999999996000
      end
      item
        Value = 10.000000000000010000
      end
      item
        Value = 10.000000000000010000
      end
      item
        Value = 10.000000000000010000
      end
      item
        Value = 10.000000000000010000
      end
      item
        Value = 9.999999999999996000
      end>
    TabOrder = 0
    object TimeGraphImage: TImage
      AlignWithMargins = True
      Left = 492
      Top = 57
      Width = 486
      Height = 312
      Align = alClient
      ExplicitLeft = 336
      ExplicitTop = 216
      ExplicitWidth = 105
      ExplicitHeight = 105
    end
    object SizeGraphImage: TImage
      AlignWithMargins = True
      Left = 4
      Top = 57
      Width = 482
      Height = 312
      Align = alClient
      ExplicitLeft = 336
      ExplicitTop = 216
      ExplicitWidth = 105
      ExplicitHeight = 105
    end
    object SizeLabel: TLabel
      Left = 1
      Top = 38
      Width = 98
      Height = 16
      Align = alBottom
      Alignment = taCenter
      Caption = 'Size, kb'
      ExplicitWidth = 45
    end
    object TimeLabel: TLabel
      Left = 489
      Top = 38
      Width = 98
      Height = 16
      Align = alBottom
      Alignment = taCenter
      Caption = 'Time, ms'
    end
  end
end
