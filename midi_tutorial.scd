(
s.boot;
)

//Connect all MIDI inputs
(
MIDIClient.init;
MIDIIn.connectAll;
)

//Select only 1st midi in
(
MIDIClient.disposeClient;
MIDIClient.init(1, 1);
)

//Print input (src ID, channel, note number, velocity)
(
MIDIdef.noteOn(\print, {arg val, num, chan, src; [src,chan, num, val].postln});
)

//Print input pnly on channel 0 (src ID, channel, note number, velocity)
(
MIDIdef.noteOn(\test4, {arg val, num, chan, src;
    [src,chan, num, val].postln;
}, chan: 0);

MIDIdef.cc(\test5, {arg val, num, chan, src;
    [src,chan, num, val].postln;
}, chan: 0);
)

//Control sin osc frequency with Midi
(
SynthDef.new(\sinpk, { arg freq = 440;
	Out.ar(0, Pan2.ar(SinOsc.ar(freq, 0, 0.1) + PinkNoise.ar(0.01)));
}).add;

h = Synth(\sinpk, [\freq, 440]);
h.set("freq", (69).midicps);

MIDIdef.noteOn(\changefreq, {arg val, num, chan, src;
	h.set("freq", (num).midicps);
});
)

//Play sin osc with Midi

(
SynthDef(\sinpk, { arg freq = 440, gate = 1, attack = 0.01, decay = 0.25, sustain = 0.6, release = 0.2, peakLevel = 1, curve = 0, bias = 0;
    var x;
	var env1 = Env.adsr(attack, decay, sustain, release,peakLevel,curve,bias);
    x = SinOsc.ar(freq, 0, 0.1);
    x = EnvGen.kr(env1, gate, doneAction: 2) * x;
	Out.ar(0, Pan2.ar(x));
}).add;
)

(
// https://gist.github.com/umbrellaprocess/973d2aa16e95bf329ee2

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
	node = Synth(\sinpk, [\freq, num.midicps]);
	keys.put(num, node);
};

MIDIdef.noteOn(\on, ~noteOnFunc);

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
};

MIDIdef.cc(\ccOn, ~ccOnFunc);

)


