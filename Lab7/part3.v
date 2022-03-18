//
// This is the template for Part 3 of Lab 7.
//
// Paul Chow
// November 2021
//

// iColour is the colour for the box
//
// oX, oY, oColour and oPlot should be wired to the appropriate ports on the VGA controller
//

// Some constants are set as parameters to accommodate the different implementations
// X_SCREENSIZE, Y_SCREENSIZE are the dimensions of the screen
//       Default is 160 x 120, which is size for fake_fpga and baseline for the DE1_SoC vga controller
// CLOCKS_PER_SECOND should be the frequency of the clock being used.

module part3(iColour,iResetn,iClock,oX,oY,oColour,oPlot);
    input wire [2:0] iColour;
    input wire iResetn, iClock;
    output wire [7:0] oX;         // VGA pixel coordinates
    output wire [6:0] oY;

    output wire [2:0] oColour;     // VGA pixel colour (0-7)
    output wire oPlot;       // Pixel drawn enable

    parameter   X_SCREENSIZE = 160,  // X screen width for starting resolution and fake_fpga
                Y_SCREENSIZE = 120,  // Y screen height for starting resolution and fake_fpga
                CLOCKS_PER_SECOND = 5000, // 5 KHZ for fake_fpga
                X_BOXSIZE = 8'd4,   // Box X dimension
                Y_BOXSIZE = 7'd4,   // Box Y dimension
                X_MAX = X_SCREENSIZE - 1 - X_BOXSIZE, // 0-based and account for box width
                Y_MAX = Y_SCREENSIZE - 1 - Y_BOXSIZE,
                PULSES_PER_SIXTIETH_SECOND = CLOCKS_PER_SECOND / 60;

    // ################################################################
    // MY CODE IS HERE 
    // ################################################################
    wire [3:0] drawClock;
    wire nextFrame, ldC, ldB, ldM, enable;

    Control U0(iClock, iResetn, drawClock, nextFrame, oPlot, ldC, ldB, ldM);
    Datapath U1(iClock, iResetn, iColour, X_MAX, Y_MAX, oX, oY, oColour, drawClock, ldC, ldB, ldM);
    FourHertzClock U2(iClock, iResetn, nextFrame, PULSES_PER_SIXTIETH_SECOND);
endmodule // part3

module Control (Clock, Resetn, drawClock, nextFrame, oP, ldC, ldB, ldM);
    input       Clock, Resetn, nextFrame;
    input [3:0] drawClock;

    output reg  oP, ldC, ldB, ldM;
    
    //State Parameters
    parameter   C_Draw      = 3'd0,
                C_Wait1     = 3'd1,
                C_Delete    = 3'd2,
                C_Wait2     = 3'd3,
                C_Move      = 3'd4;

    //Current State, Next State
    reg [2:0]   CS, NS;

    //State Table
    always @ *
    begin
        case (CS)
            C_Draw:     begin
                            if (drawClock == 4'd15)
                                NS = C_Wait1;
                            else
                                NS = CS;
                        end
            C_Wait1:    NS = nextFrame ? C_Delete : CS;
            C_Delete:   begin
                            if (drawClock == 4'd15)
                                NS = C_Wait2;
                            else
                                NS = CS;
                        end
            C_Wait2:    NS = C_Move;
            C_Move:     NS = C_Draw;
            default:    NS = C_Draw;
        endcase
    end

    //Datapath Control Signals
    always @ *
    begin
        ldC = 0;
        ldB = 0;
        ldM = 0;

        case (CS)
            C_Draw:    begin
                            ldC = 1;
                            oP = 1;
                        end   
            C_Delete:   begin
                            ldB = 1;
                            oP = 1;
                        end
            C_Move:    begin
                            ldM = 1;
                            oP = 0;
                        end
        endcase
    end

    //CS Registers
    always @ (posedge Clock)
    begin
        if (!Resetn) 
            CS <= C_Draw;
        else
            CS <= NS;
    end
endmodule

module Datapath (Clock, Resetn, iColour, X_MAX, Y_MAX, oX, oY, oC, drawClock, ldC, ldB, ldM);
    input               Clock, Resetn, ldC, ldB, ldM;
    input [7:0]         X_MAX;
    input [6:0]         Y_MAX;
    input [2:0]         iColour;

    output reg [7:0]    oX;
    output reg [6:0]    oY;
    output reg [3:0]    drawClock;
    output reg [2:0]    oC;

    reg [7:0]           regX;
    reg [6:0]           regY;
    reg                 DirH, DirY;

    //Registers
    always @ (posedge Clock)
    begin
        if (!Resetn)
        begin
            regX <= 0;
            regY <= 0;
        end
        else if (ldC)
        begin
            oX <= regX + drawClock[1:0];
            oY <= regY + drawClock[3:2];
            oC <= iColour;
        end
        else if (ldB)
        begin
            oX <= regX + drawClock[1:0];
            oY <= regY + drawClock[3:2];
            oC <= 0;
        end
        else if (ldM)
        begin
            regX <= regX + (DirH ? 1 : -1);
            regY <= regY + (DirY ? 1 : -1);
        end
    end
    
    //Change direction
    always @ (posedge Clock)
    begin
        if (!Resetn)
        begin
            DirH <= 1;
            DirY <= 1;
        end
        //at left
        if (!regX)
            DirH <= 1;
        //at right
        if (regX == X_MAX)
            DirH <= 0;
        //at top
        if (!regY)
            DirY <= 1;
        //at bottom
        if (regY == Y_MAX)
            DirY <= 0;
    end
    
    //Draw/Delete Counter
    always @ (posedge Clock)
    begin
        if (!Resetn)
            drawClock <= 4'd0;
        else if (drawClock == 4'd15)
            drawClock <= 4'd0;
        else if (ldC || ldB)
            drawClock <= drawClock + 1;
    end
endmodule

module FourHertzClock (Clock, Resetn, oClock, Frames);
    input           Clock, Resetn;
    input [31:0]    Frames;
    
    output          oClock;    

    reg [31:0]      FrameCounter;
    reg [3:0]       FourCounter;

    wire            FrameEnable;

    always @ (posedge Clock)
    begin
        if (!Resetn)
            FrameCounter <= 0;
        else if (FrameCounter == (Frames -1))
            FrameCounter <= 0;
        else
            FrameCounter <= FrameCounter + 1;
    end

    assign FrameEnable = (FrameCounter == (Frames -1)) ? 1 : 0;

    always @ (posedge Clock)
    begin
        if (!Resetn)
            FourCounter <= 0;
        else if (FourCounter == 4'd15)
            FourCounter <= 0;
        else if (FrameEnable)
            FourCounter <= FourCounter + 1;
    end

    assign oClock = (FourCounter == 4'd15) ? 1 : 0;
endmodule