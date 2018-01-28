//Play sin osc with Midi
//Quy Chau, 1/27/18
//FM synth definable by MIDI parameters


//Connect all MIDI inputs
(
MIDIClient.init;
MIDIIn.connectAll;
)


//Define Synth to be played (4 oscillators)
(
SynthDef(\sinpk, { arg freq = 440, gate = 1, vel = 100, mix1 = 1, attack1 = 0.01, decay1 = 0.3, sustain1 = 0.5, release1 = 0.5, peakLevel1 = 1, curve1 = 0, bias1 = 0, mix2 = 1, attack2 = 0.01, decay2 = 3, sustain2 = 0.5, release2 = 0.5, peakLevel2 = 1, curve2 = 0, bias2 = 0, wave1 = 0, wave2 = 0, ratio1 = 1, algorithm = 1, noise = 0;

    var x, y;
	var env1 = Env.adsr(attack1, decay1, sustain1, release1,peakLevel1,curve1,bias1);
	var env2 = Env.adsr(attack2, decay2, sustain2, release2,peakLevel2,curve2,bias2);

	var freq1 = freq;
	var freq2 = freq1*ratio1;

	y = mix2*SinOsc.ar(freq2,0,2pi);
/*	y = Select.ar(wave2 > 0, [SinOsc.ar(freq2,0,2pi), LFPulse.ar(freq2,0,0.5,2pi)]);
	y = Select.ar(wave2 > 1, [y, LFSaw.ar(freq2,0,2pi)]);*/

	y = EnvGen.kr(env2, doneAction: 2) * y;


	x = mix1*SinOsc.ar(freq1,y,1);
/*	x = Select.ar(wave1 > 0, [SinOsc.ar(freq1,y,1), LFPulse.ar(freq1,y,0.5,1)]);
	x = Select.ar(wave1 > 1, [x, LFSaw.ar(freq1,y,1)]);*/
	//x = SinOsc.ar(freq1, y, 1);
	x = x + PinkNoise.ar(noise);
    x = EnvGen.kr(env1, gate, doneAction: 2) * x;

	Out.ar(0, (vel/127)*Pan2.ar(x));
	//Out.ar(0, Pan2.ar(y));

}).add;

)

//MIDI input notes/paramters passed to synth
(
// https://gist.github.com/umbrellaprocess/973d2aa16e95bf329ee2
var peakLevel1 = 1, mix1=1, attack1=0.01, decay1 = 0.3, sustain1=0.5, release1=0.5;
var ratio1=1, peakLevel2 = 1, mix2=1, attack2=0.01, decay2 = 0.3, sustain2=0.5, release2=0.5;
var noise = 0, wave1 = 0, wave2 = 0;

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

	node = Synth(\sinpk, [\freq, num.midicps, \vel, val, \ratio1, ratio1, \mix1, mix1, \peakLevel1, peakLevel1, \attack1, attack1, \decay1, decay1, \sustain1, sustain1, \release1, release1, \mix2, mix2, \peakLevel2, peakLevel2, \attack2, attack2, \decay2, decay2, \sustain2, sustain2, \release2, release2, \wave1, wave1, \wave2, wave2, \noise, noise]);
	keys.put(num, node);

};
MIDIdef.noteOn(\on, ~noteOnFunc);


//MIDI CC to change notesynth parameters live
MIDIdef.cc(\ccnoteon, {arg valcc, numcc, chancc, srccc;

	case
	{numcc == 21} {
		ratio1 = (valcc/10);
		for (0, 127, {arg i;
			keys[i].set(\ratio1, ratio1);
		}
		);
		('Ratio1: ').post; ratio1.postln;
	}

	{numcc == 22} {
		peakLevel1 = (valcc/127);
		for (0, 127, {arg i;
			keys[i].set(\peakLevel1, peakLevel1);
		}
		);
		('peakLevel1: ').post; peakLevel1.postln;
	}

	{numcc == 23} {
		mix1 = (valcc/127);
		for (0, 127, {arg i;
			keys[i].set(\mix1, mix1);
		}
		);
		('mix1: ').post; mix1.postln;
	}

	{numcc == 24} {
		mix2 = (valcc/127);
		for (0, 127, {arg i;
			keys[i].set(\mix2, mix2);
		}
		);
		('mix2: ').post; mix2.postln;
	}

	{numcc == 25} {
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

	{numcc == 26} {
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

	{numcc == 27} {
		sustain1 = valcc/127;
		for (0, 127, {arg i;
			keys[i].set(\sustain1, sustain1);
		}
		);
		('sustain1: ').post; sustain1.postln;
	}

	{numcc == 28} {
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

	{numcc == 1} {
		noise = (valcc/127);
		for (0, 127, {arg i;
			keys[i].set(\noise, noise);
		}
		);
		('noise: ').post; noise.postln;
	}

	{numcc == 2} {
		peakLevel2 = (valcc/127);
		for (0, 127, {arg i;
			keys[i].set(\peakLevel2, peakLevel2);
		}
		);
		('peakLevel2: ').post; peakLevel2.postln;
	}

	{numcc == 5} {
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

	{numcc == 6} {
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

	{numcc == 7} {
		sustain2 = valcc/127;
		for (0, 127, {arg i;
			keys[i].set(\sustain2, sustain2);
		}
		);
		('sustain2: ').post; sustain2.postln;
	}

	{numcc == 8} {
		case
		{valcc < 42} {release2 = 0.1*valcc/42+0}
		{valcc < 85} {release2 = 0.9*((valcc-42)/42)+0.1}
		{valcc < 128} {release2 = 9*((valcc-84)/43)+1};
		for (0, 127, {arg i;
			keys[i].set(\release2, release2);
		}
		);
		('release2: ').post; release2.postln;
	};


});

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


//Print CCs and notes
(
MIDIdef.noteOn(\test4, {arg val, num, chan, src;
	[src,chan, num, val].postln;
}, chan: 0);

MIDIdef.cc(\test5, {arg val, num, chan, src;
    [src,chan, num, val].postln;
}, chan: 0);
)