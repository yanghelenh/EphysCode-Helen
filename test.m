% test code

[dataDir, exptFnDir, settings] = ephysSettings();

% aIn = {'ampScaledOut', 'ampI', 'amp10Vm'};
aIn = {};
aOut = {'ampExtCmdIn'};
% aOut = {};
% dIn = {'ficTracCamFrames', 'legCamFrames'};
dIn = {};
dOut = {'legCamFrameStartTrig'};
    
[userDAQ, aiCh, aoCh, diCh, doCh] = initUserDAQ(...
    settings, aIn, aOut, dIn, dOut);

userDAQ.IsContinuous = true;

outputData0 = zeros(20000,1);
outputData0(1:200:19999) = 1;
outputData1 = (linspace(-2,2,20000))';

queueOutputData(userDAQ,[outputData1,outputData0]);

lh = addlistener(userDAQ,'DataRequired', ...
			@(src,event) src.queueOutputData([outputData1,outputData0]));

userDAQ.startBackground();

pause(10)

userDAQ.stop();

delete(lh);