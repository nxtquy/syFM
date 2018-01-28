//Play sin osc with Midi
//Quy Chau, 1/27/18
//FM synth definable by MIDI parameters

//Define Synth to be played (4 oscillators)
(
SynthDef(\sinpk, { arg freq = 440, gate = 1, vel = 100, attack1 = 0.01, decay1 = 0.25, sustain1 = 0.6, release1 = 0.2, peakLevel1 = 1, curve1 = 0, bias1 = 0, attack2 = 0.01, decay2 = 0.05, sustain2 = 0.5, release2 = 0.2, peakLevel2 = 1, curve2 = 0, bias2 = 0, wave2 = 0, ratio1 = 1, algorithm = 1, noise = 0;

    var x, y;
	var env1 = Env.adsr(attack1, decay1, sustain1, release1,peakLevel1,curve1,bias1);
	var env2 = Env.adsr(attack2, decay2, sustain2, release2,peakLevel2,curve2,bias2);

	var freq1 = freq;
	var freq2 = freq1*ratio1;

	y = SinOsc.ar(freq2,0,2pi);

    case
	{wave2 + 1} {y = SinOsc.ar(freq1,0,2pi)}
	{wave2 } {y = LFPulse.ar(freq1,0,0.5,2pi)}
	{wave2 -1} {y = LFSaw.ar(freq1,0,2pi)};

	y = EnvGen.kr(env2, gate, doneAction: 2) * y;

	x = SinOsc.ar(freq1, y, 1) + PinkNoise.ar(noise);
    x = EnvGen.kr(env1, gate, doneAction: 2) * x;

	Out.ar(0, (vel/127)*Pan2.ar(x));
	//Out.ar(0, Pan2.ar(y));

}).add;

)

//MIDI input notes/paramters passed to synth
(
// https://gist.github.com/umbrellaprocess/973d2aa16e95bf329ee2
var ratio1=1, peakLevel2=1, attack1=0.01, sustain1=0.5, decay1=0.25, release1=0.1;
var noise = 0;

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

	node = Synth(\sinpk, [\freq, num.midicps, \vel, val, \ratio1, ratio1, \peakLevel2, peakLevel2, \attack1, attack1, \decay1, decay1, \sustain1, sustain1, \release1, release1, \noise, noise]);
	keys.put(num, node);

};
MIDIdef.noteOn(\on, ~noteOnFunc);


//MIDI CC to change notesynth parameters live
MIDIdef.cc(\ccnoteon, {arg valcc, numcc, chancc, srccc;

	if (numcc == 21, {
		ratio1 = (valcc/10);
		for (0, 127, {arg i;
			keys[i].set(\ratio1, ratio1);
		}
		);
	});

	if (numcc == 22, {
		case
		{valcc < 42} {peakLevel2 = 1*valcc/42+0}
		{valcc < 85} {peakLevel2 = 9*((valcc-42)/42)+1}
		{valcc < 128} {peakLevel2 = 90*((valcc-84)/43)+10};
		for (0, 127, {arg i;
			keys[i].set(\peakLevel2, peakLevel2);
		}
		);
	});

	if (numcc == 23, {
		wave1 = floor(valcc/64);
		for (0, 127, {arg i;
			keys[i].set(\wave1, wave1);
		}
		);
	});

	if (numcc == 24, {
		wave2 = floor(valcc/64);
		for (0, 127, {arg i;
			keys[i].set(\wave2, wave2);
		}
		);
	});

	if (numcc == 25, {
		case
		{valcc < 42} {attack1 = 0.1*valcc/42+0}
		{valcc < 85} {attack1 = 0.9*((valcc-42)/42)+0.1}
		{valcc < 128} {attack1 = 9*((valcc-84)/43)+1};
		for (0, 127, {arg i;
			keys[i].set(\attack1, attack1);
		}
		);
	});

	if (numcc == 26, {
		case
		{valcc < 42} {decay1 = 0.1*valcc/42+0}
		{valcc < 85} {decay1 = 0.9*((valcc-42)/42)+0.1}
		{valcc < 128} {decay1 = 9*((valcc-84)/43)+1};
		for (0, 127, {arg i;
			keys[i].set(\decay1, decay1);
		}
		);
	});

	if (numcc == 27, {
		sustain1 = valcc/127;
		for (0, 127, {arg i;
			keys[i].set(\sustain1, sustain1);
		}
		);
	});

	if (numcc == 28, {
		case
		{valcc < 42} {release1 = 0.1*valcc/42+0}
		{valcc < 85} {release1 = 0.9*((valcc-42)/42)+0.1}
		{valcc < 128} {release1 = 9*((valcc-84)/43)+1};
		for (0, 127, {arg i;
			keys[i].set(\release1, release1);
		}
		);
	});

	if (numcc == 29, {
		noise = (valcc/127);
		for (0, 127, {arg i;
			keys[i].set(\noise, noise);
		}
		);
	});


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

~ccOnFunc = {arg val, num, chan, src;
	var node;
	node = ccs.at(num);
	if (node.notNil, {
		node.release;
		ccs.put(num,nil);
	});

	ccs.put(num, node);
	[src,chan, num, val].postln;
};

MIDIdef.cc(\ccOn, ~ccOnFunc);

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