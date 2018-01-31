// 2 synthdefs - the 1st to make grains and the 2nd to delay them

// the synthdef that makes the grains is on the left channel
// the synthdef that delays the grains is on the right channel
(
SynthDef("someGrains", { arg centerFreq = 777, freqDev = 200, grainFreq = 2;
    var gate;
    gate = Impulse.kr(grainFreq);
    Out.ar(
        0,
        SinOsc.ar(
            LFNoise0.kr(4, freqDev, centerFreq),
            0,
            EnvGen.kr(Env.sine(0.1), gate, 0.1)
        )
    )
}).add;

SynthDef("aDelay", { arg delay = 0.25;
    Out.ar(
        1,
        DelayN.ar(
            In.ar(0, 1),
            delay,
            delay
        )
    )
}).add;
)

////////////////////////////////////////////////
// test the grains ... and then turn them off
// ... they're all on the left channel ... good!
Synth("someGrains");
////////////////////////////////////////////////

// make 2 groups, the 1st for sources and the 2nd for effects
(
~source = Group.head(s);
~effects = Group.tail(s);
)

// place grains into the delay ... source is on the left and delayed source is on the right
(
Synth.head(~source, "someGrains");
Synth.head(~effects, "aDelay");
)