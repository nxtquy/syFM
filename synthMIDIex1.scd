
(
SynthDef.new(\sineMIDI, {
	arg noiseHz=8;
	var freq, amp, sig;
	freq = LFNoise0.kr(noiseHz).exprange(200,1000);
	amp = LFNoise1.kr(12).exprange(0.02,1);
	sig = SinOsc.ar(freq) * amp;
	Out.ar(0, sig);
}).add;
)

x = Synth.new(\sineMIDI);


(
var fader0, fader1, fader2, fader3;
MIDIdef.cc(\ccTest, {
	arg vel, ccNum, chan, srcID;

	[vel, ccNum, chan, srcID];
	(
	switch(ccNum,
		0, {fader0=vel},
		1, {fader1=vel},
		2, {fader2=vel},
		3, {fader3=vel}
	);
	);
	[fader0, fader1, fader2, fader3].postln;
	x.set(\noiseHz, fader0)
});
)

x.free;
