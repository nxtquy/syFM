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


//Define Synth to be played (4 oscillators)
(
//https://carlcolglazier.com/notes/acoustics/midi-instrument-control-supercollider/

SynthDef(\sinpk, { arg freq = 440, gate = 1, vel = 100, mix1 = 1, attack1 = 0.01, decay1 = 0.3, sustain1 = 0.5, release1 = 0.5, peakLevel1 = 1, curve1 = 0, bias1 = 0, mix2 = 1, attack2 = 0.01, decay2 = 3, sustain2 = 0.5, release2 = 0.5, peakLevel2 = 1, curve2 = 0, bias2 = 0, wave1 = 0, wave2 = 0, ratio1 = 1, coarse1 = 0, algorithm = 1, noise = 0, filterFreq = 20000, filterRes = 10, master = 0.5;

    var x, y;
	var env1 = Env.adsr(attack1, decay1, sustain1, release1,peakLevel1,curve1,bias1);
	var env2 = Env.adsr(attack2, decay2, sustain2, release2,peakLevel2,curve2,bias2);

	var freq1 = freq;
	var freq2 = freq1*(ratio1+coarse1);

	y = SinOsc.ar(freq2,0,1);
	y = Select.ar(wave2 > 0, [y, LFPulse.ar(freq2,0,0.5,1)]);
	y = Select.ar(wave2 > 1, [y, LFSaw.ar(freq2,0,1)]);
	y = mix2*y;

	y = EnvGen.kr(env2, gate, doneAction: 0) * y;


	x = SinOsc.ar(freq1,y,1);
	x = Select.ar(wave1 > 0, [x, LFPulse.ar(freq1,y,0.5,1)]);
	x = Select.ar(wave1 > 1, [x, LFSaw.ar(freq1,y,1)]);
	x = mix1*x;
	x = x + PinkNoise.ar(noise);
    x = EnvGen.kr(env1, gate, doneAction: 2) * x;
	x = BLowPass4.ar(x, filterFreq, filterRes);

	Out.ar(0, master*0.1*(vel/127)*Pan2.ar(x));
	//Out.ar(0, Pan2.ar(y));

}).add;

)

//MIDI input notes/paramters passed to synth
(
// https://gist.github.com/umbrellaprocess/973d2aa16e95bf329ee2
var peakLevel1 = 1, mix1=1, attack1=0.01, decay1 = 0.3, sustain1=0.5, release1=0.5;
var ratio1=1, coarse1 = 0, peakLevel2 = 1, mix2=1, attack2=0.01, decay2 = 0.3, sustain2=0.5, release2=0.5;
var noise = 0, wave1 = 0, wave2 = 0, filterFreq = 20000, filterRes = 10, master = 0.5;

var ccres = 127;
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

	node = Synth(\sinpk, [\freq, num.midicps, \vel, val, \ratio1, ratio1, \coarse1, coarse1, \mix1, mix1, \peakLevel1, peakLevel1, \attack1, attack1, \decay1, decay1, \sustain1, sustain1, \release1, release1, \mix2, mix2, \peakLevel2, peakLevel2, \attack2, attack2, \decay2, decay2, \sustain2, sustain2, \release2, release2, \wave1, wave1, \wave2, wave2, \noise, noise, \filterFreq, filterFreq, \filterRes, filterRes, \master, master]);
	keys.put(num, node);

};
MIDIdef.noteOn(\on, ~noteOnFunc);


//MIDI CC to change notesynth parameters live
MIDIdef.cc(\ccnoteon, {arg valcc, numcc, chancc, srccc;

	case
	{numcc == 12} {
		ratio1 = floor(valcc/10);
		for (0, 127, {arg i;
			keys[i].set(\ratio1, ratio1);
		}
		);
		('Ratio1: ').post; ratio1.postln;
	}

	{numcc == 4} {
		coarse1 = (valcc/127);
		for (0, 127, {arg i;
			keys[i].set(\coarse1, coarse1);
		}
		);
		('coarse1: ').post; coarse1.postln;
	}

	{numcc == 18} {
		peakLevel1 = (valcc/127);
		for (0, 127, {arg i;
			keys[i].set(\peakLevel1, peakLevel1);
		}
		);
		('peakLevel1: ').post; peakLevel1.postln;
	}

	{numcc == 15} {
		mix1 = 10*(valcc/127);
		for (0, 127, {arg i;
			keys[i].set(\mix1, mix1);
		}
		);
		('mix1: ').post; mix1.postln;
	}

	{numcc == 16} {
		mix2 = 10*(valcc/127);
		for (0, 127, {arg i;
			keys[i].set(\mix2, mix2);
		}
		);
		('mix2: ').post; mix2.postln;
	}

	{numcc == 23} {
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

	{numcc == 24} {
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

	{numcc == 25} {
		sustain1 = valcc/127;
		for (0, 127, {arg i;
			keys[i].set(\sustain1, sustain1);
		}
		);
		('sustain1: ').post; sustain1.postln;
	}

	{numcc == 26} {
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

	{numcc == 8} {
		noise = (valcc/127);
		for (0, 127, {arg i;
			keys[i].set(\noise, noise);
		}
		);
		('noise: ').post; noise.postln;
	}

	{numcc == 27} {
		peakLevel2 = (valcc/127);
		for (0, 127, {arg i;
			keys[i].set(\peakLevel2, peakLevel2);
		}
		);
		('peakLevel2: ').post; peakLevel2.postln;
	}

	{numcc == 19} {
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

	{numcc == 21} {
		valcc = 127- valcc;
		case
		{valcc < 42} {filterRes = 0.05*valcc/42+0.05}
		{valcc < 85} {filterRes = 0.9*((valcc-42)/42)+0.1}
		{valcc < 128} {filterRes = 9*((valcc-84)/43)+1};
		for (0, 127, {arg i;
			keys[i].set(\filterRes, filterRes);
		}
		);
		('filterRes: ').post; filterRes.postln;
	}

	{numcc == 9} {
		wave1 = floor(valcc/43);
		for (0, 127, {arg i;
			keys[i].set(\wave1, wave1);
		}
		);
		('wave1: ').post; wave1.postln;
	}

	{numcc == 14} {
		wave2 = floor(valcc/43);
		for (0, 127, {arg i;
			keys[i].set(\wave2, wave2);
		}
		);
		('wave2: ').post; wave2.postln;
	}

	{numcc == 28} {
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

	{numcc == 29} {
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

	{numcc == 30} {
		sustain2 = valcc/127;
		for (0, 127, {arg i;
			keys[i].set(\sustain2, sustain2);
		}
		);
		('sustain2: ').post; sustain2.postln;
	}

	{numcc == 31} {
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

	{numcc == 7} {
		master = (valcc/127);
		for (0, 127, {arg i;
			keys[i].set(\master, master);
		}
		);
		('master: ').post; master.postln;
	};


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


//Print CCs and notes
(
MIDIdef.noteOn(\test4, {arg val, num, chan, src;
	[src,chan, num, val].postln;
});

MIDIdef.cc(\test5, {arg val, num, chan, src;
    [src,chan, num, val].postln;
});
)