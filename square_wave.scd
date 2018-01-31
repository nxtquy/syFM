(
f = {
        ({arg i;
                var j = i * 2 + 1; // the odd harmonics (1,3,5,7,etc)
                SinOsc.ar(300 * j, 0, 1/j)
        } ! 20).sum;
};
)

f.plot;
f.play;