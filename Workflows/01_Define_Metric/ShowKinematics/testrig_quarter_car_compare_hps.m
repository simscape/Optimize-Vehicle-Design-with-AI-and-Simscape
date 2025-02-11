
Vehicle_data;
Vehicle1 = Vehicle;

defUWSIF = Vehicle.Chassis.SuspA1.Linkage.UpperWishbone.sInboardF.Value;
defUWSIR = Vehicle.Chassis.SuspA1.Linkage.UpperWishbone.sInboardR.Value;
defLWSIF = Vehicle.Chassis.SuspA1.Linkage.LowerWishbone.sInboardF.Value;
defLWSIR = Vehicle.Chassis.SuspA1.Linkage.LowerWishbone.sInboardR.Value;
defTRSIn = Vehicle.Chassis.SuspA1.Linkage.TrackRod.sInboard.Value;
defTRSOu = Vehicle.Chassis.SuspA1.Linkage.TrackRod.sOutboard.Value;

%Vehicle1.Chassis.SuspA1.Linkage.UpperWishbone.sInboardF.Value = defUWSIF+[0  0  0.05];
%Vehicle1.Chassis.SuspA1.Linkage.UpperWishbone.sInboardR.Value = defUWSIR+[0  0  0];
%Vehicle1.Chassis.SuspA1.Linkage.LowerWishbone.sInboardF.Value = defLWSIF+[0  0  0.05];
%Vehicle1.Chassis.SuspA1.Linkage.LowerWishbone.sInboardR.Value = defLWSIR+[0  0  0];
Vehicle1.Chassis.SuspA1.Linkage.TrackRod.sInboard.Value  = defTRSIn + [0  0  0.05];
Vehicle1.Chassis.SuspA1.Linkage.TrackRod.sOutboard.Value = defTRSOu + [0  0  0];

defArmRad = Visual.UpperArm.rad;

Visual.UpperArm.rad = defArmRad*0.5; 
Visual.LowerArm.rad = defArmRad*0.5; 
Visual.TrackRod.rad = defArmRad*0.5; 
Visual.Upright.rad  = defArmRad*0.5; 