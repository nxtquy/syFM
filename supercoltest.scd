

(
SynthDef(\sinpk, { arg freq = 220, gate = 1;
    var x;
	var zx;
	var y;
    //x = SinOsc.ar(freq, 0, 1) + PinkNoise.ar(0.01);

/*	x = SinOsc.ar(freq, 0,1) + (1/3)*SinOsc.ar(3*freq, 0,1) + (1/5)*SinOsc.ar(5*freq, 0,1)  + (1/7)*SinOsc.ar(7*freq, 0,1) +
	(1/9)*SinOsc.ar(9*freq, 0,1) + (1/11)*SinOsc.ar(11*freq, 0,1) ;*/

	var fm = 220;
	var fc = 440;

	var ind = 2pi/6;

	y = SinOsc.ar(freq,0,1);
	zx = SinOsc.ar(fm,0, fm*ind, fc);
	x = SinOsc.ar(zx, 0,1,0);
	x = SinOsc.ar(zx,0,0.5,1,0);

	//x = LFPulse.ar(zx, 0,0.5, min(1/440*100, 1/fm * 50),0);
	//y = LFSaw.ar(440,0,1,0);

    //x = EnvGen.kr(Env.asr, gate, doneAction: 2) * x;

	//x = SinOsc.ar(440, SinOsc.ar(440,0,2*pi/4),1,0);

	Out.ar(0, Pan2.ar(x));
}).play;
)

(
g = { SinOsc.ar(440, 0, 0.1) + PinkNoise.ar(0.01) }.play;
g.free;
)

(
var env = Env.adsr(attackTime: 0.01, decayTime: 0.3, sustainLevel: 0.5, releaseTime: 1, peakLevel: 1, curve: 0, bias: 0);
var gen = EnvGen.kr(env, doneAction: Done.freeSelf);
SynthDef.new(\sinpk,
    { Out.ar(0, SinOsc.ar(440, 0, 0.1) + PinkNoise.ar(0.01)) }
).play;

)

(
SynthDef.new(\sinpk, { arg freq = 440;
	Out.ar(0, Pan2.ar(SinOsc.ar(freq, 0, 0.1) + PinkNoise.ar(0.01)));
}).add;
)




(
{
    var ctls, mods, chans, freq;
    freq = LFNoise0.kr(3).exprange(200, 310);
    ctls = [
        // freq, phase, amp
        [freq, 0, 1],
        [freq, 0, 1],
        [LFNoise2.kr(0.5).exprange(3, 80), 0, 1],
        [LFNoise2.kr(0.5).exprange(3, 800), 0, 1],
        [LFNoise2.kr(0.5).exprange(3, 800), 0, 1],
        [LFNoise2.kr(0.5).exprange(0.3, 10), 0, 1]
    ];
    mods = [
        { LFNoise1.kr(0.5).max(0) } ! 6 * MouseX.kr(0, 3),
        { LFNoise1.kr(0.5).max(0) } ! 6 * MouseY.kr(0, 3),
        { LFNoise1.kr(0.5).max(0) } ! 6 * MouseY.kr(0, 3),
        { LFNoise1.kr(0.5).max(0) } ! 6 * MouseX.kr(0, 3),
        { LFNoise1.kr(0.5).max(0) } ! 6 * MouseY.kr(0, 3),
        { LFNoise1.kr(0.5).max(0) } ! 6 * MouseY.kr(0, 3)
    ];
    chans = FM7.ar(ctls, mods).slice([0, 1]) * -12.dbamp;
}.play;
)



{ [SinOsc.ar(440, 0, 0.2), SinOsc.ar(442, 0, 0.2)] }.play;
{ Pan2.ar(LFPulse.ar(440*(1-0.1*SinOsc.ar(440,0,1)), 0, 0.5, 1, 0.1)) }.play; // modulate carfreq

(
{
	MouseButton.kr(minval: 0, maxval: 1, lag: 0.2)*SinOsc.ar(400 + SinOsc.ar(MouseX.kr(2,2000,1), 0, MouseY.kr(1,1000)), 0, 0.5)!2
}.play
)


MouseButton.kr(minval: 0, maxval: 1, lag: 0.2)

(
{SinOsc.ar}.play // Audio Rate
{K2A.ar(SinOsc.kr)}.play //Play a control rate with transformation
)

(
{ SinOsc.ar(800, 0, 3*KeyState.kr(38, 0, 0.1))!2 }.play
)

// an envelope in a synth
(

{
    var env = Env.adsr(attackTime: 0.01, decayTime: 0.3, sustainLevel: 0.5, releaseTime: 1, peakLevel: 1, curve: 0, bias: 0);
	//Env([0, 0.5, 0.2, 0.2, 0], [0.02, 0.25, 0.25, 0.5]);
	env.plot;
	SinOsc.ar(240,0, 0.5)!2 * EnvGen.kr(env, doneAction: Done.freeSelf);
	//EnvGen.kr(env, doneAction: Done.freeSelf)
}.play

)

(
Env.adsr(0.02, 0.2, 0.25, 0.5, 1, 0).test(2).plot;
)

(
(
SynthDef(\env_help, { |out, gate = 1, amp = 0.1, release = 0.1|
    var env = Env.adsr(0.02, release, amp);
    var gen = EnvGen.kr(env, gate, doneAction: Done.freeSelf);
    Out.ar(out, PinkNoise.ar(1 ! 2) * gen)
}).add
);

a = Synth(\env_help);
a.set(\gate, 0); // alternatively, you can write a.release;

{SinOsc.ar(240,0, 0.5)!2}.play;
)

