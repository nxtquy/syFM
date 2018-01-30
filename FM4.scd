//Play sin osc with Midi
//Quy Chau, 1/27/18
//FM synth definable by MIDI parameters
//Credit to https://carlcolglazier.com/notes/acoustics/midi-instrument-control-supercollider/ for MIDI/synth setup


//boot server
(
s.boot;
s.options.sampleRate= 48000;
)

//Connect all MIDI inputs
(
MIDIClient.init;
MIDIIn.connectAll;
)


//-----------------------------SYNTH DEFINITION ------------------------------//

//Define Synth to be played (4 oscillators)
(
//https://carlcolglazier.com/notes/acoustics/midi-instrument-control-supercollider/

//Algorithm 1
SynthDef(\sinpk, { arg freq = 440, gate = 1, vel = 100, mix1 = 5, attack1 = 0.01, decay1 = 0.3, sustain1 = 0.5, release1 = 0.5, peakLevel1 = 1, curve1 = 0, bias1 = 0, mix2 = 5, attack2 = 0.01, decay2 = 3, sustain2 = 0.5, release2 = 0.5, peakLevel2 = 1, curve2 = 0, bias2 = 0, wave1 = 0, wave2 = 0, ratio2 = 1, coarse2 = 0, ratio1 = 1, coarse1 = 0, noise = 0, filterFreq = 20000, filterRes = 1, master = 0.5, aF = 1;

    var x, y;
	var env1 = Env.adsr(attack1, decay1, sustain1, release1,peakLevel1,curve1,bias1);
	var env2 = Env.adsr(attack2, decay2, sustain2, release2,peakLevel2,curve2,bias2);

	var freq1 = freq*(ratio1+coarse1)*aF;
	var freq2 = freq1*(ratio2+coarse2);

	y = SinOsc.ar(freq2,0,1);
	y = Select.ar(wave2 > 0, [y, LFPulse.ar(freq2,0,0.5,1)]);
	y = Select.ar(wave2 > 1, [y, LFSaw.ar(freq2,0,1)]);
	y = (mix2/10)*y;
	y = EnvGen.kr(env2, gate, doneAction: 0) * y;


	x = SinOsc.ar(freq1,y,1);
	x = Select.ar(wave1 > 0, [x, LFPulse.ar(freq1,y,0.5,1)]);
	x = Select.ar(wave1 > 1, [x, LFSaw.ar(freq1,y,1)]);
	x = (mix1/10)*x;
	x = x + PinkNoise.ar(noise/10);
    x = EnvGen.kr(env1, gate, doneAction: 2) * x;

	x = BLowPass4.ar(x, filterFreq, filterRes);

	Out.ar(0, master*(vel/127)*Pan2.ar(x));
	//Out.ar(0, Pan2.ar(y));

}).add;

//Algorithm 2
SynthDef(\sinpk2, { arg freq = 440, gate = 1, vel = 100, mix1 = 5, attack1 = 0.01, decay1 = 0.3, sustain1 = 0.5, release1 = 0.5, peakLevel1 = 1, curve1 = 0, bias1 = 0, mix2 = 5, attack2 = 0.01, decay2 = 3, sustain2 = 0.5, release2 = 0.5, peakLevel2 = 1, curve2 = 0, bias2 = 0, wave1 = 0, wave2 = 0, ratio2 = 1, coarse2 = 0, ratio1 = 1, coarse1 = 0, noise = 0, filterFreq = 20000, filterRes = 1, master = 0.5, aF = 1;

    var x, y;
	var env1 = Env.adsr(attack1, decay1, sustain1, release1,peakLevel1,curve1,bias1);
	var env2 = Env.adsr(attack2, decay2, sustain2, release2,peakLevel2,curve2,bias2);

	var freq1 = freq*(ratio1+coarse1)*aF;
	var freq2 = freq*(ratio2+coarse2)*aF;

	y = SinOsc.ar(freq2,0,1);
	y = Select.ar(wave2 > 0, [y, LFPulse.ar(freq2,0,0.5,1)]);
	y = Select.ar(wave2 > 1, [y, LFSaw.ar(freq2,0,1)]);
	y = (mix2/10)*y;
	y = EnvGen.kr(env2, gate, doneAction: 0) * y;

	x = SinOsc.ar(freq1,0,1);
	x = Select.ar(wave1 > 0, [x, LFPulse.ar(freq1,0,0.5,1)]);
	x = Select.ar(wave1 > 1, [x, LFSaw.ar(freq1,0,1)]);
	x = (mix1/10)*x;
	x = x + PinkNoise.ar(noise/10);
    x = EnvGen.kr(env1, gate, doneAction: 2) * x;

	x = x + y;
	x = BLowPass4.ar(x, filterFreq, filterRes);

	Out.ar(0, master*(vel/127)*Pan2.ar(x));
	//Out.ar(0, Pan2.ar(y));

}).add;

)

//-----------------------------------------------------------------------------//




//-----------------------------MIDI PARSING ------------------------------//

(
// https://gist.github.com/umbrellaprocess/973d2aa16e95bf329ee2
var ratio1 = 1, coarse1 = 0, peakLevel1 = 1, mix1=5, attack1=0.01, decay1 = 0.3, sustain1=0.5, release1=0.5;
var ratio2 = 1, coarse2 = 0, peakLevel2 = 1, mix2=5, attack2=0.01, decay2 = 0.3, sustain2=0.5, release2=0.5;
var noise = 0, wave1 = 0, wave2 = 0, filterFreq = 20000, filterRes = 1, master = 0.5, analogFac = 0;
var algorithm = 1;

var ccres = 127;
var aF = 1;

var synthN = \sinpk;
var keys;
var ccs;
keys = Array.newClear(128);
ccs = Array.newClear(128);

~noteOnFunc = {arg val, num, chan, src;
	var node;
	node = keys.at(num);
	if (node.notNil, {
		node.release;
		keys.put(num, nil);
	});
	aF = 1-(analogFac*0.01*((1.0.sum3rand)-0.5));
	//('note analog factor: ').post;aF.postln;

	case
	{algorithm == 1} {synthN =\sinpk}
	{algorithm == 2} {synthN = \sinpk2};

	node = Synth(synthN, [\freq, num.midicps, \vel, val, \ratio1, ratio1, \coarse1, coarse1, \ratio2, ratio2, \coarse2, coarse2, \mix1, mix1, \peakLevel1, peakLevel1, \attack1, attack1, \decay1, decay1, \sustain1, sustain1, \release1, release1, \mix2, mix2, \peakLevel2, peakLevel2, \attack2, attack2, \decay2, decay2, \sustain2, sustain2, \release2, release2, \wave1, wave1, \wave2, wave2, \noise, noise, \filterFreq, filterFreq, \filterRes, filterRes, \master, master, \aF, aF]);

	keys.put(num, node);

};
MIDIdef.noteOn(\on, ~noteOnFunc);


//MIDI CC to change notesynth parameters live
MIDIdef.cc(\ccnoteon, {arg valcc, numcc, chancc, srccc;

	case

	//BANK 1: OP1
	{numcc == 21 && chancc == 0} {
		wave1 = floor(valcc/43);
		for (0, 127, {arg i;
			keys[i].set(\wave1, wave1);
		}
		);
		('wave1: ').post; wave1.postln;
	}

	{numcc == 22 && chancc == 0} {
		ratio1 = floor((valcc+1)/8);
		for (0, 127, {arg i;
			keys[i].set(\ratio1, ratio1);
		}
		);
		('Ratio1: ').post; ratio1.postln;
	}

	{numcc == 23 && chancc == 0} {
		coarse1 = (valcc/127);
		for (0, 127, {arg i;
			keys[i].set(\coarse1, coarse1);
		}
		);
		('coarse1: ').post; coarse1.postln;
	}

	{numcc == 24 && chancc == 0} {
		peakLevel1 = (valcc/127);
		for (0, 127, {arg i;
			keys[i].set(\peakLevel1, peakLevel1);
		}
		);
		('peakLevel1: ').post; peakLevel1.postln;
	}

	{numcc == 25 && chancc == 0} {
		case
		{valcc < 42} {attack1 = 0.1*valcc/42+0}
		{valcc < 85} {attack1 = 0.9*((valcc-42)/42)+0.1}
		{valcc < 128} {attack1 = 9*((valcc-84)/43)+1};
		for (0, 127, {arg i;
			keys[i].set(\attack1, attack1);
		}
		);
		('attack1: ').post; attack1.postln;
	}

	{numcc == 26 && chancc == 0} {
		case
		{valcc < 42} {decay1 = 0.1*valcc/42+0}
		{valcc < 85} {decay1 = 0.9*((valcc-42)/42)+0.1}
		{valcc < 128} {decay1 = 9*((valcc-84)/43)+1};
		for (0, 127, {arg i;
			keys[i].set(\decay1, decay1);
		}
		);
		('decay1: ').post; decay1.postln;
	}

	{numcc == 27 && chancc == 0} {
		sustain1 = valcc/127;
		for (0, 127, {arg i;
			keys[i].set(\sustain1, sustain1);
		}
		);
		('sustain1: ').post; sustain1.postln;
	}

	{numcc == 28 && chancc == 0} {
		case
		{valcc < 42} {release1 = 0.1*valcc/42+0}
		{valcc < 85} {release1 = 0.9*((valcc-42)/42)+0.1}
		{valcc < 128} {release1 = 9*((valcc-84)/43)+1};
		for (0, 127, {arg i;
			keys[i].set(\release1, release1);
		}
		);
		('release1: ').post; release1.postln;
	}
	//

	//BANK 2: OP2

	{numcc == 21 && chancc == 1} {
		wave2 = floor(valcc/43);
		for (0, 127, {arg i;
			keys[i].set(\wave2, wave2);
		}
		);
		('wave2: ').post; wave2.postln;
	}

	{numcc == 22 && chancc == 1} {
		ratio2 = floor((valcc+1)/8);
		for (0, 127, {arg i;
			keys[i].set(\ratio2, ratio2);
		}
		);
		('Ratio2: ').post; ratio2.postln;
	}

	{numcc == 23 && chancc == 1} {
		coarse2 = (valcc/127);
		for (0, 127, {arg i;
			keys[i].set(\coarse2, coarse2);
		}
		);
		('coarse2: ').post; coarse2.postln;
	}

	{numcc == 24 && chancc == 1} {
		peakLevel2 = (valcc/127);
		for (0, 127, {arg i;
			keys[i].set(\peakLevel2, peakLevel2);
		}
		);
		('peakLevel2: ').post; peakLevel2.postln;
	}

	{numcc == 25 && chancc == 1} {
		case
		{valcc < 42} {attack2 = 0.1*valcc/42+0}
		{valcc < 85} {attack2 = 0.9*((valcc-42)/42)+0.1}
		{valcc < 128} {attack2 = 9*((valcc-84)/43)+1};
		for (0, 127, {arg i;
			keys[i].set(\attack2, attack2);
		}
		);
		('attack2: ').post; attack2.postln;
	}

	{numcc == 26 && chancc == 1} {
		case
		{valcc < 42} {decay2 = 0.1*valcc/42+0}
		{valcc < 85} {decay2 = 0.9*((valcc-42)/42)+0.1}
		{valcc < 128} {decay2 = 9*((valcc-84)/43)+1};
		for (0, 127, {arg i;
			keys[i].set(\decay2, decay2);
		}
		);
		('decay2: ').post; decay2.postln;
	}

	{numcc == 27 && chancc == 1} {
		sustain2 = valcc/127;
		for (0, 127, {arg i;
			keys[i].set(\sustain2, sustain2);
		}
		);
		('sustain2: ').post; sustain2.postln;
	}

	{numcc == 28 && chancc == 1} {
		case
		{valcc < 42} {release2 = 0.1*valcc/42+0}
		{valcc < 85} {release2 = 0.9*((valcc-42)/42)+0.1}
		{valcc < 128} {release2 = 9*((valcc-84)/43)+1};
		for (0, 127, {arg i;
			keys[i].set(\release2, release2);
		}
		);
		('release2: ').post; release2.postln;
	}
	//

	//BANK 3: GLOBAL CONTROL/MIX

	{numcc == 21 && chancc == 2} {
		algorithm = 1+round(valcc/127);
		('algorithm: ').post; algorithm.postln;
	}


	{numcc == 22 && chancc == 2} {
		noise = 10*(valcc/127);
		for (0, 127, {arg i;
			keys[i].set(\noise, noise);
		}
		);
		('noise: ').post; noise.postln;
	}

	{numcc == 23 && chancc == 2} {
		mix1 = 10*(valcc/127);
		for (0, 127, {arg i;
			keys[i].set(\mix1, mix1);
		}
		);
		('mix1: ').post; mix1.postln;
	}

	{numcc == 24 && chancc == 2} {
		mix2 = 10*(valcc/127);
		for (0, 127, {arg i;
			keys[i].set(\mix2, mix2);
		}
		);
		('mix2: ').post; mix2.postln;
	}


	{numcc == 25 && chancc == 2} {
		filterFreq = 20000*(valcc/127);
/*		case
		{valcc < 42} {filterFreq = 100*valcc/42+0}
		{valcc < 85} {filterFreq = 900*((valcc-42)/42)+100}
		{valcc < 128} {filterFreq = 19000*((valcc-84)/43)+1000};*/

		for (0, 127, {arg i;
			keys[i].set(\filterFreq, filterFreq+20);
		}
		);
		('filterFreq: ').post; filterFreq.postln;
	}

	{numcc == 26 && chancc == 2} {
		valcc = 127- valcc;
		case
		{valcc < 42} {filterRes = 0.05*valcc/42+0.05}
		{valcc < 100} {filterRes = 0.9*((valcc-42)/42)+0.1}
		{valcc < 128} {filterRes = 9*((valcc-99)/28)+1};
		for (0, 127, {arg i;
			keys[i].set(\filterRes, filterRes);
		}
		);
		('filterRes: ').post; filterRes.postln;
	}



	{numcc == 27 && chancc == 2} {
		analogFac = valcc/(127);
		('analogFac: ').post; analogFac.postln;
	}

	{numcc == 28 && chancc == 2} {
		master = (valcc/127);
		for (0, 127, {arg i;
			keys[i].set(\master, master);
		}
		);
		('master: ').post; master.postln;
	}
	//

	;
});

//Release note will release synth node
~noteOffFunc = {arg val, num, chan, src;
	var node;
	node = keys.at(num);
	if (node.notNil, {
		node.release;
		keys.put(num, nil);
	});

};

MIDIdef.noteOff(\off, ~noteOffFunc);

/*~ccOnFunc = {arg val, num, chan, src;
	var node;
	node = ccs.at(num);
	if (node.notNil, {
		node.release;
		ccs.put(num,nil);
	});

	ccs.put(num, node);
	[src,chan, num, val].postln;
};

MIDIdef.cc(\ccOn, ~ccOnFunc);*/

)

//-----------------------------------------------------------------------------//



//-----------------------------DIRECT GUI CONTROL ------------------------------//
(
var w;
var k1, k2;
var s1, s2;
var b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12;
var b13, b14, b15, b16, b17, b18, b19, b20, b21, b22, b23, b24;
var b25, b26, b27, b28, b29, b30;

var oct = 3;
var s2text;

//Keyboard location
var o1s = 150; //X location
var o2s = 210+o1s;
var kY = 300; // Y location


w= Window("testgui",Rect(100,300,1000,500));

k1= Knob(w,Rect(110,50,80,80))
.keyDownAction_({})
.action={(127*k1.value).postln}
;

s1 = Slider(w,Rect(250,50,20,80))
.keyDownAction_({})
.action = {(127*s1.value).postln}
;

s2 = Slider(w,Rect(100,kY,20,80))
.keyDownAction_({})
.action = {
	oct = floor(6*s2.value);
	s2text.value = oct}
;
s2text = TextField(s2, Rect(0, 0, 20, 20));
s2text.value= oct;

//OCTAVE 1

b1 = Button.new(w,Rect(o1s+10,kY,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.mouseDownAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {
		//(0+(oct*12)).postln;
		~noteOnFunc.value(100, 0+(oct*12), 0, 0);
	}
	{b.value == 0} {~noteOffFunc.value(0, 0+(oct*12), 0, 0)};
});

b2 = Button.new(w,Rect(o1s+29,kY,22,100))
.states_([["", Color.white, Color.black],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(1+(oct*12)).postln}
	{b.value == 0} {};
});
b2.front;

b3 = Button.new(w,Rect(o1s+40,kY,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(2+(oct*12)).postln}
	{b.value == 0} {};
});

b4 = Button.new(w,Rect(o1s+59,kY,22,100))
.states_([["", Color.white, Color.black],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(3+(oct*12)).postln}
	{b.value == 0} {};
});
b4.front;

b5 = Button.new(w,Rect(o1s+70,kY,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(4+(oct*12)).postln}
	{b.value == 0} {};
});

b6 = Button.new(w,Rect(o1s+100,kY,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(5+(oct*12)).postln}
	{b.value == 0} {};
});

b7 = Button.new(w,Rect(o1s+119,kY,22,100))
.states_([["", Color.white, Color.black],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(6+(oct*12)).postln}
	{b.value == 0} {};
});
b7.front;

b8 = Button.new(w,Rect(o1s+130,kY,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(7+(oct*12)).postln}
	{b.value == 0} {};
});

b9 = Button.new(w,Rect(o1s+149,kY,22,100))
.states_([["", Color.white, Color.black],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(8+(oct*12)).postln}
	{b.value == 0} {};
});
b9.front;

b10 = Button.new(w,Rect(o1s+160,kY,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(9+(oct*12)).postln}
	{b.value == 0} {};
});

b11 = Button.new(w,Rect(o1s+179,kY,22,100))
.states_([["", Color.white, Color.black],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(10+(oct*12)).postln}
	{b.value == 0} {};
});
b11.front;

b12 = Button.new(w,Rect(o1s+190,kY,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(11+(oct*12)).postln}
	{b.value == 0} {};
});

b13 = Button.new(w,Rect(o1s+220,kY,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(12+(oct*12)).postln}
	{b.value == 0} {};
});

//OCTAVE 2

b14 = Button.new(w,Rect(o2s+29,kY,22,100))
.states_([["", Color.white, Color.black],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(13+(oct*12)).postln}
	{b.value == 0} {};
});
b14.front;

b15 = Button.new(w,Rect(o2s+40,kY,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(14+(oct*12)).postln}
	{b.value == 0} {};
});

b16 = Button.new(w,Rect(o2s+59,kY,22,100))
.states_([["", Color.white, Color.black],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(15+(oct*12)).postln}
	{b.value == 0} {};
});
b16.front;

b17 = Button.new(w,Rect(o2s+70,kY,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(16+(oct*12)).postln}
	{b.value == 0} {};
});

b18 = Button.new(w,Rect(o2s+100,kY,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(17+(oct*12)).postln}
	{b.value == 0} {};
});

b19 = Button.new(w,Rect(o2s+119,kY,22,100))
.states_([["", Color.white, Color.black],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(18+(oct*12)).postln}
	{b.value == 0} {};
});
b19.front;

b20 = Button.new(w,Rect(o2s+130,kY,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(19+(oct*12)).postln}
	{b.value == 0} {};
});

b21 = Button.new(w,Rect(o2s+149,kY,22,100))
.states_([["", Color.white, Color.black],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(20+(oct*12)).postln}
	{b.value == 0} {};
});
b21.front;

b22 = Button.new(w,Rect(o2s+160,kY,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(21+(oct*12)).postln}
	{b.value == 0} {};
});

b23 = Button.new(w,Rect(o2s+179,kY,22,100))
.states_([["", Color.white, Color.black],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(22+(oct*12)).postln}
	{b.value == 0} {};
});
b23.front;

b24 = Button.new(w,Rect(o2s+190,kY,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(23+(oct*12)).postln}
	{b.value == 0} {};
});

b25 = Button.new(w,Rect(o2s+220,kY,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(24+(oct*12)).postln}
	{b.value == 0} {};
});

b26 = Button.new(w,Rect(o2s+239,kY,22,100))
.states_([["", Color.white, Color.black],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(25+(oct*12)).postln}
	{b.value == 0} {};
});
b26.front;

b27 = Button.new(w,Rect(o2s+250,kY,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(26+(oct*12)).postln}
	{b.value == 0} {};
});

b28 = Button.new(w,Rect(o2s+269,kY,22,100))
.states_([["", Color.white, Color.black],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(27+(oct*12)).postln}
	{b.value == 0} {};
});
b28.front;

b29 = Button.new(w,Rect(o2s+280,kY,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(28+(oct*12)).postln}
	{b.value == 0} {};
});





//Use computer keyboard to send commands
w.view.keyDownAction = { arg view, char, modifiers, unicode, keycode;
	//[char, modifiers, unicode, keycode].postln;
	case
	{keycode == 6} {b1.valueAction = 1}
	{keycode == 1} {b2.valueAction = 1}
	{keycode == 7} {b3.valueAction = 1}
	{keycode == 2} {b4.valueAction = 1}
	{keycode == 8} {b5.valueAction = 1}
	{keycode == 9} {b6.valueAction = 1}
	{keycode == 5} {b7.valueAction = 1}
	{keycode == 11} {b8.valueAction = 1}
	{keycode == 4} {b9.valueAction = 1}
	{keycode == 45} {b10.valueAction = 1}
	{keycode == 38} {b11.valueAction = 1}
	{keycode == 46} {b12.valueAction = 1}
	{keycode == 43} {b13.valueAction = 1}

	{keycode == 12} {b13.valueAction = 1}
	{keycode == 19} {b14.valueAction = 1}
	{keycode == 13} {b15.valueAction = 1}
	{keycode == 20} {b16.valueAction = 1}
	{keycode == 14} {b17.valueAction = 1}
	{keycode == 15} {b18.valueAction = 1}
	{keycode == 23} {b19.valueAction = 1}
	{keycode == 17} {b20.valueAction = 1}
	{keycode == 22} {b21.valueAction = 1}
	{keycode == 16} {b22.valueAction = 1}
	{keycode == 26} {b23.valueAction = 1}
	{keycode == 32} {b24.valueAction = 1}
	{keycode == 34} {b25.valueAction = 1}

	{keycode == 25} {b26.valueAction = 1}
	{keycode == 31} {b27.valueAction = 1}
	{keycode == 29} {b28.valueAction = 1}
	{keycode == 35} {b29.valueAction = 1};

};

w.view.keyUpAction = { arg view, char, modifiers, unicode, keycode;
	case
	{keycode == 6} {b1.valueAction = 0}
	{keycode == 1} {b2.valueAction = 0}
	{keycode == 7} {b3.valueAction = 0}
	{keycode == 2} {b4.valueAction = 0}
	{keycode == 8} {b5.valueAction = 0}
	{keycode == 9} {b6.valueAction = 0}
	{keycode == 5} {b7.valueAction = 0}
	{keycode == 11} {b8.valueAction = 0}
	{keycode == 4} {b9.valueAction = 0}
	{keycode == 45} {b10.valueAction = 0}
	{keycode == 38} {b11.valueAction = 0}
	{keycode == 46} {b12.valueAction = 0}
	{keycode == 43} {b13.valueAction = 0}

	{keycode == 12} {b13.valueAction = 0}
	{keycode == 19} {b14.valueAction = 0}
	{keycode == 13} {b15.valueAction = 0}
	{keycode == 20} {b16.valueAction = 0}
	{keycode == 14} {b17.valueAction = 0}
	{keycode == 15} {b18.valueAction = 0}
	{keycode == 23} {b19.valueAction = 0}
	{keycode == 17} {b20.valueAction = 0}
	{keycode == 22} {b21.valueAction = 0}
	{keycode == 16} {b22.valueAction = 0}
	{keycode == 26} {b23.valueAction = 0}
	{keycode == 32} {b24.valueAction = 0}
	{keycode == 34} {b25.valueAction = 0}

	{keycode == 25} {b26.valueAction = 0}
	{keycode == 31} {b27.valueAction = 0}
	{keycode == 29} {b28.valueAction = 0}
	{keycode == 35} {b29.valueAction = 0};


};

w.front;

w.onClose= {};
)

//-----------------------------------------------------------------------------//








//Print CCs and notes
(
MIDIdef.noteOn(\test4, {arg val, num, chan, src;
	[src,chan, num, val].postln;
});

MIDIdef.cc(\test5, {arg val, num, chan, src;
    [src,chan, num, val].postln;
});
)