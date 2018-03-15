// Play sin osc with Midi
// Quy Chau, 1/27/18
// FM synth definable by MIDI parameters
// Credit for MIDI/synth setup to https://carlcolglazier.com/notes/acoustics/midi-instrument-control-supercollider/
// Credit for effects to https://github.com/mcfilib/modfm-synth


// Run this to boot server
(
s.boot;
s.options.sampleRate= 48000;
)

// Run this to connect all MIDI inputs
(
MIDIClient.init;
MIDIIn.connectAll;
)

/////////////////////////////////////////////////////////////////////////////////////
//-----------------------------FM SYNTHESIZER ------------------------------//
/////////////////////////////////////////////////////////////////////////////////////

// Run this to initiate synthesizer
(

// Initialize all synthesizer parameters to default patch (basic electric piano)
var ratio1 = 1, coarse1 = 0, peakLevel1 = 0.5, mix1=5, delay1 = 0.001, attack1=0.01, decay1 = 0.3, sustain1=0.5, release1=0.5;
var ratio2 = 1, coarse2 = 0, peakLevel2 = 0.5, mix2=5, delay2 = 0.001, attack2=0.01, decay2 = 0.3, sustain2=0.5, release2=0.5;
var ratio3 = 1, coarse3 = 0, peakLevel3 = 0.5, mix3 = 5, delay3 = 0.001, attack3 = 0.01, decay3 = 0.3, sustain3 = 0.5, release3 = 0.5;
var ratio4 = 1, coarse4 = 0, peakLevel4 = 0.5, mix4 = 5, delay4 = 0.001, attack4 = 0.01, decay4 = 0.3, sustain4 = 0.5, release4 = 0.5;
var noise = 0, wave1 = 0, wave2 = 0, wave3 = 0, wave4 = 0, analogFac = 0;

var algorithm = 0;
var filterFreq = 10000, filterRes = 1, fdelay = 0.001, fattack = 0.01, fdecay = 0.3, fsustain = 1, frelease = 0.2;
var hpFreq = 20, hpRes = 1;
var master = 0.5;
var lfoRate = 0.5, lfoAmount = 0, lfoShape = 0, lfoDuty = 0.5;
var dwet = 0, ddec = 0.01, ddel = 0.001;
var rdec = 2, rdel = 0.048, rwet = 0;


var ccres = 127;
var aF = 1;

var lp, hp, de, li, re;

var synthN = \sinpk;
var keys;
var ccs;

//-----------------------------SYNTH DEFINITION ------------------------------//

//Define Synth to be played (4 oscillators)
//much credit to https://carlcolglazier.com/notes/acoustics/midi-instrument-control-supercollider/

  /////////////////////////////////
 //       FM ALGORITHMS         //
/////////////////////////////////

//Algorithm 1
SynthDef(\sinpk, { arg freq = 440, gate = 1, vel = 100, mix1 = 5, delay1 = 0.001, attack1 = 0.01, decay1 = 0.3, sustain1 = 0.5, release1 = 0.5, peakLevel1 = 1, curve1 = 0, bias1 = 0, mix2 = 5, delay2 = 0.001, attack2 = 0.01, decay2 = 3, sustain2 = 0.5, release2 = 0.5, peakLevel2 = 1, curve2 = 0, bias2 = 0, mix3 = 5, delay3 = 0.001, attack3 = 0.01, decay3 = 0.3, sustain3 = 0.5, release3 = 0.5, peakLevel3 = 1, curve3 = 0, bias3 = 0, mix4 = 5, delay4 = 0.001, attack4 = 0.01, decay4 = 0.3, sustain4 = 0.5, release4 = 0.5, peakLevel4 = 1, curve4 = 0, bias4 = 0, wave1 = 0, wave2 = 0, wave3 = 0, wave4 = 0, ratio2 = 1, coarse2 = 0, ratio1 = 1, coarse1 = 0, ratio3 = 1, coarse3 = 0, ratio4 = 1, coarse4 = 0, noise = 0, aF = 1;

    var x, y, limited, out;
	var env1 = Env.dadsr(delay1, attack1, decay1, sustain1, release1,peakLevel1,curve1,bias1);
	var env2 = Env.dadsr(delay2, attack2, decay2, sustain2, release2, peakLevel2, curve2, bias2);
	var env3 = Env.dadsr(delay3, attack3, decay3, sustain3, release3, peakLevel3, curve3, bias3);
	var env4 = Env.dadsr(delay4, attack4, decay4, sustain4, release4, peakLevel4, curve4, bias4);

	var freq1 = freq*(ratio1+coarse1*aF);
	var freq2 = freq*(ratio2+coarse2*aF);
	var freq3 = freq*(ratio3+coarse3*aF);
	var freq4 = freq*(ratio4+coarse4*aF);

	w = SinOsc.ar(freq4,0,1);
	w = Select.ar(wave4 > 0, [w, LFPulse.ar(freq4, 0, 0.5,1)]);
	w = Select.ar(wave4 > 1, [w, LFSaw.ar(freq4, 0, 1)]);
	w= (mix4/10)*w;
	w= EnvGen.kr(env4, gate, doneAction: 0) * w;

	z = SinOsc.ar(freq3,w,1);
	z = Select.ar(wave3 > 0, [z, LFPulse.ar(freq3, w, 0.5,1)]);
	z = Select.ar(wave3 > 1, [z, LFSaw.ar(freq3, w, 1)]);
	z = (mix3/10)*z;
	z = EnvGen.kr(env3, gate, doneAction: 0) * z;

	y = SinOsc.ar(freq2,z,1);
	y = Select.ar(wave2 > 0, [y, LFPulse.ar(freq2, z, 0.5,1)]);
	y = Select.ar(wave2 > 1, [y, LFSaw.ar(freq2, z, 1)]);
	y = (mix2/10)*y;
	y = EnvGen.kr(env2, gate, doneAction: 0) * y;


	x = SinOsc.ar(freq1,y,1);
	x = Select.ar(wave1 > 0, [x, LFPulse.ar(freq1, y, 0.5, 1)]);
	x = Select.ar(wave1 > 1, [x, LFSaw.ar(freq1, y, 1)]);
	x = (mix1/10)*x;
	x = x + (aF*PinkNoise.ar(noise/10));
    x = EnvGen.kr(env1, gate, doneAction: 2) * x;

	//master volume and clip limit
	x = LeakDC.ar(x,0.995,1,0);
	out = (vel/127)*x;
	Out.ar(0, out);

}).add;

//ALGORITHM 2
SynthDef(\sinpk2, { arg freq = 440, gate = 1, vel = 100, mix1 = 5, delay1 = 0.001, attack1 = 0.01, decay1 = 0.3, sustain1 = 0.5, release1 = 0.5, peakLevel1 = 1, curve1 = 0, bias1 = 0, mix2 = 5, delay2 = 0.001, attack2 = 0.01, decay2 = 3, sustain2 = 0.5, release2 = 0.5, peakLevel2 = 1, curve2 = 0, bias2 = 0, mix3 = 5, delay3 = 0.001, attack3 = 0.01, decay3 = 0.3, sustain3 = 0.5, release3 = 0.5, peakLevel3 = 1, curve3 = 0, bias3 = 0, mix4 = 5, delay4 = 0.001, attack4 = 0.01, decay4 = 0.3, sustain4 = 0.5, release4 = 0.5, peakLevel4 = 1, curve4 = 0, bias4 = 0, wave1 = 0, wave2 = 0, wave3 = 0, wave4 = 0, ratio2 = 1, coarse2 = 0, ratio1 = 1, coarse1 = 0, ratio3 = 1, coarse3 = 0, ratio4 = 1, coarse4 = 0, noise = 0, aF = 1;

    var x, y, limited, out;
	var env1 = Env.dadsr(delay1, attack1, decay1, sustain1, release1,peakLevel1,curve1,bias1);
	var env2 = Env.dadsr(delay2, attack2, decay2, sustain2, release2, peakLevel2, curve2, bias2);
	var env3 = Env.dadsr(delay3, attack3, decay3, sustain3, release3, peakLevel3, curve3, bias3);
	var env4 = Env.dadsr(delay4, attack4, decay4, sustain4, release4, peakLevel4, curve4, bias4);

	var freq1 = freq*(ratio1+coarse1*aF);
	var freq2 = freq*(ratio2+coarse2*aF);
	var freq3 = freq*(ratio3+coarse3*aF);
	var freq4 = freq*(ratio4+coarse4*aF);

	w = SinOsc.ar(freq4,0,1);
	w = Select.ar(wave4 > 0, [w, LFPulse.ar(freq4, 0, 0.5,1)]);
	w = Select.ar(wave4 > 1, [w, LFSaw.ar(freq4, 0, 1)]);
	w= (mix4/10)*w;
	w= EnvGen.kr(env4, gate, doneAction: 0) * w;

	z = SinOsc.ar(freq3,0,1);
	z = Select.ar(wave3 > 0, [z, LFPulse.ar(freq3, 0, 0.5,1)]);
	z = Select.ar(wave3 > 1, [z, LFSaw.ar(freq3, 0, 1)]);
	z = (mix3/10)*z;
	z = EnvGen.kr(env3, gate, doneAction: 0) * z;

	y = SinOsc.ar(freq2,0,1);
	y = Select.ar(wave2 > 0, [y, LFPulse.ar(freq2, 0, 0.5,1)]);
	y = Select.ar(wave2 > 1, [y, LFSaw.ar(freq2, 0, 1)]);
	y = (mix2/10)*y;
	y = EnvGen.kr(env2, gate, doneAction: 0) * y;


	x = SinOsc.ar(freq1,0,1);
	x = Select.ar(wave1 > 0, [x, LFPulse.ar(freq1, 0, 0.5, 1)]);
	x = Select.ar(wave1 > 1, [x, LFSaw.ar(freq1, 0, 1)]);
	x = (mix1/10)*x;
	x = x + (aF*PinkNoise.ar(noise/10));
    x = EnvGen.kr(env1, gate, doneAction: 2) * x;

	x = x + y + z + w;
	x = x*((1/sqrt(2))**3);

	//master volume and clip limit
	x = LeakDC.ar(x,0.995,1,0);
	out = (vel/127)*x;
	Out.ar(0, out);

}).add;

//ALGORITHM 3
SynthDef(\sinpk3, { arg freq = 440, gate = 1, vel = 100, mix1 = 5, delay1 = 0.001, attack1 = 0.01, decay1 = 0.3, sustain1 = 0.5, release1 = 0.5, peakLevel1 = 1, curve1 = 0, bias1 = 0, mix2 = 5, delay2 = 0.001, attack2 = 0.01, decay2 = 3, sustain2 = 0.5, release2 = 0.5, peakLevel2 = 1, curve2 = 0, bias2 = 0, mix3 = 5, delay3 = 0.001, attack3 = 0.01, decay3 = 0.3, sustain3 = 0.5, release3 = 0.5, peakLevel3 = 1, curve3 = 0, bias3 = 0, mix4 = 5, delay4 = 0.001, attack4 = 0.01, decay4 = 0.3, sustain4 = 0.5, release4 = 0.5, peakLevel4 = 1, curve4 = 0, bias4 = 0, wave1 = 0, wave2 = 0, wave3 = 0, wave4 = 0, ratio2 = 1, coarse2 = 0, ratio1 = 1, coarse1 = 0, ratio3 = 1, coarse3 = 0, ratio4 = 1, coarse4 = 0, noise = 0, aF = 1;

    var x, y, limited, out;
	var env1 = Env.dadsr(delay1, attack1, decay1, sustain1, release1,peakLevel1,curve1,bias1);
	var env2 = Env.dadsr(delay2, attack2, decay2, sustain2, release2, peakLevel2, curve2, bias2);
	var env3 = Env.dadsr(delay3, attack3, decay3, sustain3, release3, peakLevel3, curve3, bias3);
	var env4 = Env.dadsr(delay4, attack4, decay4, sustain4, release4, peakLevel4, curve4, bias4);

	var freq1 = freq*(ratio1+coarse1*aF);
	var freq2 = freq*(ratio2+coarse2*aF);
	var freq3 = freq*(ratio3+coarse3*aF);
	var freq4 = freq*(ratio4+coarse4*aF);

	w = SinOsc.ar(freq4,0,1);
	w = Select.ar(wave4 > 0, [w, LFPulse.ar(freq4, 0, 0.5,1)]);
	w = Select.ar(wave4 > 1, [w, LFSaw.ar(freq4, 0, 1)]);
	w= (mix4/10)*w;
	w= EnvGen.kr(env4, gate, doneAction: 0) * w;

	z = SinOsc.ar(freq3,w,1);
	z = Select.ar(wave3 > 0, [z, LFPulse.ar(freq3, w, 0.5,1)]);
	z = Select.ar(wave3 > 1, [z, LFSaw.ar(freq3, w, 1)]);
	z = (mix3/10)*z;
	z = EnvGen.kr(env3, gate, doneAction: 0) * z;

	y = SinOsc.ar(freq2,0,1);
	y = Select.ar(wave2 > 0, [y, LFPulse.ar(freq2, 0, 0.5,1)]);
	y = Select.ar(wave2 > 1, [y, LFSaw.ar(freq2, 0, 1)]);
	y = (mix2/10)*y;
	y = EnvGen.kr(env2, gate, doneAction: 0) * y;


	x = SinOsc.ar(freq1,y,1);
	x = Select.ar(wave1 > 0, [x, LFPulse.ar(freq1, y, 0.5, 1)]);
	x = Select.ar(wave1 > 1, [x, LFSaw.ar(freq1, y, 1)]);
	x = (mix1/10)*x;
	x = x + (aF*PinkNoise.ar(noise/10));
    x = EnvGen.kr(env1, gate, doneAction: 2) * x;

	x = x  + z;
	x = x*(1/sqrt(2));

	//master volume and clip limit
	x = LeakDC.ar(x,0.995,1,0);
	out = (vel/127)*x;
	Out.ar(0, out);

}).add;

//ALGORITHM 4
SynthDef(\sinpk4, { arg freq = 440, gate = 1, vel = 100, mix1 = 5, delay1 = 0.001, attack1 = 0.01, decay1 = 0.3, sustain1 = 0.5, release1 = 0.5, peakLevel1 = 1, curve1 = 0, bias1 = 0, mix2 = 5, delay2 = 0.001, attack2 = 0.01, decay2 = 3, sustain2 = 0.5, release2 = 0.5, peakLevel2 = 1, curve2 = 0, bias2 = 0, mix3 = 5, delay3 = 0.001, attack3 = 0.01, decay3 = 0.3, sustain3 = 0.5, release3 = 0.5, peakLevel3 = 1, curve3 = 0, bias3 = 0, mix4 = 5, delay4 = 0.001, attack4 = 0.01, decay4 = 0.3, sustain4 = 0.5, release4 = 0.5, peakLevel4 = 1, curve4 = 0, bias4 = 0, wave1 = 0, wave2 = 0, wave3 = 0, wave4 = 0, ratio2 = 1, coarse2 = 0, ratio1 = 1, coarse1 = 0, ratio3 = 1, coarse3 = 0, ratio4 = 1, coarse4 = 0, noise = 0, aF = 1;

    var x, y, limited, out;
	var env1 = Env.dadsr(delay1, attack1, decay1, sustain1, release1,peakLevel1,curve1,bias1);
	var env2 = Env.dadsr(delay2, attack2, decay2, sustain2, release2, peakLevel2, curve2, bias2);
	var env3 = Env.dadsr(delay3, attack3, decay3, sustain3, release3, peakLevel3, curve3, bias3);
	var env4 = Env.dadsr(delay4, attack4, decay4, sustain4, release4, peakLevel4, curve4, bias4);

	var freq1 = freq*(ratio1+coarse1*aF);
	var freq2 = freq*(ratio2+coarse2*aF);
	var freq3 = freq*(ratio3+coarse3*aF);
	var freq4 = freq*(ratio4+coarse4*aF);

	w = SinOsc.ar(freq4,0,1);
	w = Select.ar(wave4 > 0, [w, LFPulse.ar(freq4, 0, 0.5,1)]);
	w = Select.ar(wave4 > 1, [w, LFSaw.ar(freq4, 0, 1)]);
	w= (mix4/10)*w;
	w= EnvGen.kr(env4, gate, doneAction: 0) * w;

	z = SinOsc.ar(freq3,0,1);
	z = Select.ar(wave3 > 0, [z, LFPulse.ar(freq3, 0, 0.5,1)]);
	z = Select.ar(wave3 > 1, [z, LFSaw.ar(freq3, 0, 1)]);
	z = (mix3/10)*z;
	z = EnvGen.kr(env3, gate, doneAction: 0) * z;

	y = SinOsc.ar(freq2,0,1);
	y = Select.ar(wave2 > 0, [y, LFPulse.ar(freq2, 0, 0.5,1)]);
	y = Select.ar(wave2 > 1, [y, LFSaw.ar(freq2, 0, 1)]);
	y = (mix2/10)*y;
	y = EnvGen.kr(env2, gate, doneAction: 0) * y;


	x = SinOsc.ar(freq1,y+z+w,1);
	x = Select.ar(wave1 > 0, [x, LFPulse.ar(freq1, y+z+w, 0.5, 1)]);
	x = Select.ar(wave1 > 1, [x, LFSaw.ar(freq1, y+z+w, 1)]);
	x = (mix1/10)*x;
	x = x + (aF*PinkNoise.ar(noise/10));
    x = EnvGen.kr(env1, gate, doneAction: 2) * x;

	x = x;

	//master volume and clip limit
	x = LeakDC.ar(x,0.995,1,0);
	out = (vel/127)*x;
	Out.ar(0, out);

}).add;


//ALGORITHM 5
SynthDef(\sinpk5, { arg freq = 440, gate = 1, vel = 100, mix1 = 5, delay1 = 0.001, attack1 = 0.01, decay1 = 0.3, sustain1 = 0.5, release1 = 0.5, peakLevel1 = 1, curve1 = 0, bias1 = 0, mix2 = 5, delay2 = 0.001, attack2 = 0.01, decay2 = 3, sustain2 = 0.5, release2 = 0.5, peakLevel2 = 1, curve2 = 0, bias2 = 0, mix3 = 5, delay3 = 0.001, attack3 = 0.01, decay3 = 0.3, sustain3 = 0.5, release3 = 0.5, peakLevel3 = 1, curve3 = 0, bias3 = 0, mix4 = 5, delay4 = 0.001, attack4 = 0.01, decay4 = 0.3, sustain4 = 0.5, release4 = 0.5, peakLevel4 = 1, curve4 = 0, bias4 = 0, wave1 = 0, wave2 = 0, wave3 = 0, wave4 = 0, ratio2 = 1, coarse2 = 0, ratio1 = 1, coarse1 = 0, ratio3 = 1, coarse3 = 0, ratio4 = 1, coarse4 = 0, noise = 0, aF = 1;

    var x, y, limited, out;
	var env1 = Env.dadsr(delay1, attack1, decay1, sustain1, release1,peakLevel1,curve1,bias1);
	var env2 = Env.dadsr(delay2, attack2, decay2, sustain2, release2, peakLevel2, curve2, bias2);
	var env3 = Env.dadsr(delay3, attack3, decay3, sustain3, release3, peakLevel3, curve3, bias3);
	var env4 = Env.dadsr(delay4, attack4, decay4, sustain4, release4, peakLevel4, curve4, bias4);

	var freq1 = freq*(ratio1+coarse1*aF);
	var freq2 = freq*(ratio2+coarse2*aF);
	var freq3 = freq*(ratio3+coarse3*aF);
	var freq4 = freq*(ratio4+coarse4*aF);

	w = SinOsc.ar(freq4,0,1);
	w = Select.ar(wave4 > 0, [w, LFPulse.ar(freq4, 0, 0.5,1)]);
	w = Select.ar(wave4 > 1, [w, LFSaw.ar(freq4, 0, 1)]);
	w= (mix4/10)*w;
	w= EnvGen.kr(env4, gate, doneAction: 0) * w;

	z = SinOsc.ar(freq3,w,1);
	z = Select.ar(wave3 > 0, [z, LFPulse.ar(freq3, w, 0.5,1)]);
	z = Select.ar(wave3 > 1, [z, LFSaw.ar(freq3, w, 1)]);
	z = (mix3/10)*z;
	z = EnvGen.kr(env3, gate, doneAction: 0) * z;

	y = SinOsc.ar(freq2,0,1);
	y = Select.ar(wave2 > 0, [y, LFPulse.ar(freq2, 0, 0.5,1)]);
	y = Select.ar(wave2 > 1, [y, LFSaw.ar(freq2, 0, 1)]);
	y = (mix2/10)*y;
	y = EnvGen.kr(env2, gate, doneAction: 0) * y;


	x = SinOsc.ar(freq1,y+z,1);
	x = Select.ar(wave1 > 0, [x, LFPulse.ar(freq1, y+z, 0.5, 1)]);
	x = Select.ar(wave1 > 1, [x, LFSaw.ar(freq1, y+z+w, 1)]);
	x = (mix1/10)*x;
	x = x + (aF*PinkNoise.ar(noise/10));
    x = EnvGen.kr(env1, gate, doneAction: 2) * x;

	x = x;

	//master volume and clip limit
	x = LeakDC.ar(x,0.995,1,0);
	out = (vel/127)*x;
	Out.ar(0, out);

}).add;

//ALGORITHM 6
SynthDef(\sinpk6, { arg freq = 440, gate = 1, vel = 100, mix1 = 5, delay1 = 0.001, attack1 = 0.01, decay1 = 0.3, sustain1 = 0.5, release1 = 0.5, peakLevel1 = 1, curve1 = 0, bias1 = 0, mix2 = 5, delay2 = 0.001, attack2 = 0.01, decay2 = 3, sustain2 = 0.5, release2 = 0.5, peakLevel2 = 1, curve2 = 0, bias2 = 0, mix3 = 5, delay3 = 0.001, attack3 = 0.01, decay3 = 0.3, sustain3 = 0.5, release3 = 0.5, peakLevel3 = 1, curve3 = 0, bias3 = 0, mix4 = 5, delay4 = 0.001, attack4 = 0.01, decay4 = 0.3, sustain4 = 0.5, release4 = 0.5, peakLevel4 = 1, curve4 = 0, bias4 = 0, wave1 = 0, wave2 = 0, wave3 = 0, wave4 = 0, ratio2 = 1, coarse2 = 0, ratio1 = 1, coarse1 = 0, ratio3 = 1, coarse3 = 0, ratio4 = 1, coarse4 = 0, noise = 0, aF = 1;

    var x, y, limited, out;
	var env1 = Env.dadsr(delay1, attack1, decay1, sustain1, release1,peakLevel1,curve1,bias1);
	var env2 = Env.dadsr(delay2, attack2, decay2, sustain2, release2, peakLevel2, curve2, bias2);
	var env3 = Env.dadsr(delay3, attack3, decay3, sustain3, release3, peakLevel3, curve3, bias3);
	var env4 = Env.dadsr(delay4, attack4, decay4, sustain4, release4, peakLevel4, curve4, bias4);

	var freq1 = freq*(ratio1+coarse1*aF);
	var freq2 = freq*(ratio2+coarse2*aF);
	var freq3 = freq*(ratio3+coarse3*aF);
	var freq4 = freq*(ratio4+coarse4*aF);

	w = SinOsc.ar(freq4,0,1);
	w = Select.ar(wave4 > 0, [w, LFPulse.ar(freq4, 0, 0.5,1)]);
	w = Select.ar(wave4 > 1, [w, LFSaw.ar(freq4, 0, 1)]);
	w= (mix4/10)*w;
	w= EnvGen.kr(env4, gate, doneAction: 0) * w;

	z = SinOsc.ar(freq3,0,1);
	z = Select.ar(wave3 > 0, [z, LFPulse.ar(freq3, 0, 0.5,1)]);
	z = Select.ar(wave3 > 1, [z, LFSaw.ar(freq3, 0, 1)]);
	z = (mix3/10)*z;
	z = EnvGen.kr(env3, gate, doneAction: 0) * z;

	y = SinOsc.ar(freq2,0,1);
	y = Select.ar(wave2 > 0, [y, LFPulse.ar(freq2, 0, 0.5,1)]);
	y = Select.ar(wave2 > 1, [y, LFSaw.ar(freq2, 0, 1)]);
	y = (mix2/10)*y;
	y = EnvGen.kr(env2, gate, doneAction: 0) * y;


	x = SinOsc.ar(freq1,y,1);
	x = Select.ar(wave1 > 0, [x, LFPulse.ar(freq1, y, 0.5, 1)]);
	x = Select.ar(wave1 > 1, [x, LFSaw.ar(freq1, y, 1)]);
	x = (mix1/10)*x;
	x = x + (aF*PinkNoise.ar(noise/10));
    x = EnvGen.kr(env1, gate, doneAction: 2) * x;

	x = x + z + w;
	x = x*((1/sqrt(2))**2);

	//master volume and clip limit
	x = LeakDC.ar(x,0.995,1,0);
	out = (vel/127)*x;
	Out.ar(0, out);

}).add;

//ALGORITHM 7
SynthDef(\sinpk7, { arg freq = 440, gate = 1, vel = 100, mix1 = 5, delay1 = 0.001, attack1 = 0.01, decay1 = 0.3, sustain1 = 0.5, release1 = 0.5, peakLevel1 = 1, curve1 = 0, bias1 = 0, mix2 = 5, delay2 = 0.001, attack2 = 0.01, decay2 = 3, sustain2 = 0.5, release2 = 0.5, peakLevel2 = 1, curve2 = 0, bias2 = 0, mix3 = 5, delay3 = 0.001, attack3 = 0.01, decay3 = 0.3, sustain3 = 0.5, release3 = 0.5, peakLevel3 = 1, curve3 = 0, bias3 = 0, mix4 = 5, delay4 = 0.001, attack4 = 0.01, decay4 = 0.3, sustain4 = 0.5, release4 = 0.5, peakLevel4 = 1, curve4 = 0, bias4 = 0, wave1 = 0, wave2 = 0, wave3 = 0, wave4 = 0, ratio2 = 1, coarse2 = 0, ratio1 = 1, coarse1 = 0, ratio3 = 1, coarse3 = 0, ratio4 = 1, coarse4 = 0, noise = 0, aF = 1;

    var x, y, limited, out;
	var env1 = Env.dadsr(delay1, attack1, decay1, sustain1, release1,peakLevel1,curve1,bias1);
	var env2 = Env.dadsr(delay2, attack2, decay2, sustain2, release2, peakLevel2, curve2, bias2);
	var env3 = Env.dadsr(delay3, attack3, decay3, sustain3, release3, peakLevel3, curve3, bias3);
	var env4 = Env.dadsr(delay4, attack4, decay4, sustain4, release4, peakLevel4, curve4, bias4);

	var freq1 = freq*(ratio1+coarse1*aF);
	var freq2 = freq*(ratio2+coarse2*aF);
	var freq3 = freq*(ratio3+coarse3*aF);
	var freq4 = freq*(ratio4+coarse4*aF);

	w = SinOsc.ar(freq4,0,1);
	w = Select.ar(wave4 > 0, [w, LFPulse.ar(freq4, 0, 0.5,1)]);
	w = Select.ar(wave4 > 1, [w, LFSaw.ar(freq4, 0, 1)]);
	w= (mix4/10)*w;
	w= EnvGen.kr(env4, gate, doneAction: 0) * w;

	z = SinOsc.ar(freq3,0,1);
	z = Select.ar(wave3 > 0, [z, LFPulse.ar(freq3, 0, 0.5,1)]);
	z = Select.ar(wave3 > 1, [z, LFSaw.ar(freq3, 0, 1)]);
	z = (mix3/10)*z;
	z = EnvGen.kr(env3, gate, doneAction: 0) * z;

	y = SinOsc.ar(freq2,z + w,1);
	y = Select.ar(wave2 > 0, [y, LFPulse.ar(freq2, z+w, 0.5,1)]);
	y = Select.ar(wave2 > 1, [y, LFSaw.ar(freq2, z+w, 1)]);
	y = (mix2/10)*y;
	y = EnvGen.kr(env2, gate, doneAction: 0) * y;


	x = SinOsc.ar(freq1,0,1);
	x = Select.ar(wave1 > 0, [x, LFPulse.ar(freq1, 0, 0.5, 1)]);
	x = Select.ar(wave1 > 1, [x, LFSaw.ar(freq1, 0, 1)]);
	x = (mix1/10)*x;
	x = x + (aF*PinkNoise.ar(noise/10));
    x = EnvGen.kr(env1, gate, doneAction: 2) * x;

	x = x + y;
	x = x*(1/sqrt(2));

	//master volume and clip limit
	x = LeakDC.ar(x,0.995,1,0);
	out = (vel/127)*x;
	Out.ar(0, out);

}).add;

//ALGORITHM 8
SynthDef(\sinpk8, { arg freq = 440, gate = 1, vel = 100, mix1 = 5, delay1 = 0.001, attack1 = 0.01, decay1 = 0.3, sustain1 = 0.5, release1 = 0.5, peakLevel1 = 1, curve1 = 0, bias1 = 0, mix2 = 5, delay2 = 0.001, attack2 = 0.01, decay2 = 3, sustain2 = 0.5, release2 = 0.5, peakLevel2 = 1, curve2 = 0, bias2 = 0, mix3 = 5, delay3 = 0.001, attack3 = 0.01, decay3 = 0.3, sustain3 = 0.5, release3 = 0.5, peakLevel3 = 1, curve3 = 0, bias3 = 0, mix4 = 5, delay4 = 0.001, attack4 = 0.01, decay4 = 0.3, sustain4 = 0.5, release4 = 0.5, peakLevel4 = 1, curve4 = 0, bias4 = 0, wave1 = 0, wave2 = 0, wave3 = 0, wave4 = 0, ratio2 = 1, coarse2 = 0, ratio1 = 1, coarse1 = 0, ratio3 = 1, coarse3 = 0, ratio4 = 1, coarse4 = 0, noise = 0, aF = 1;

    var x, y, limited, out;
	var env1 = Env.dadsr(delay1, attack1, decay1, sustain1, release1,peakLevel1,curve1,bias1);
	var env2 = Env.dadsr(delay2, attack2, decay2, sustain2, release2, peakLevel2, curve2, bias2);
	var env3 = Env.dadsr(delay3, attack3, decay3, sustain3, release3, peakLevel3, curve3, bias3);
	var env4 = Env.dadsr(delay4, attack4, decay4, sustain4, release4, peakLevel4, curve4, bias4);

	var freq1 = freq*(ratio1+coarse1*aF);
	var freq2 = freq*(ratio2+coarse2*aF);
	var freq3 = freq*(ratio3+coarse3*aF);
	var freq4 = freq*(ratio4+coarse4*aF);

	w = SinOsc.ar(freq4,0,1);
	w = Select.ar(wave4 > 0, [w, LFPulse.ar(freq4, 0, 0.5,1)]);
	w = Select.ar(wave4 > 1, [w, LFSaw.ar(freq4, 0, 1)]);
	w= (mix4/10)*w;
	w= EnvGen.kr(env4, gate, doneAction: 0) * w;

	z = SinOsc.ar(freq3,0,1);
	z = Select.ar(wave3 > 0, [z, LFPulse.ar(freq3, 0, 0.5,1)]);
	z = Select.ar(wave3 > 1, [z, LFSaw.ar(freq3, 0, 1)]);
	z = (mix3/10)*z;
	z = EnvGen.kr(env3, gate, doneAction: 0) * z;

	y = SinOsc.ar(freq2,z+w,1);
	y = Select.ar(wave2 > 0, [y, LFPulse.ar(freq2, z+w, 0.5,1)]);
	y = Select.ar(wave2 > 1, [y, LFSaw.ar(freq2, z+w, 1)]);
	y = (mix2/10)*y;
	y = EnvGen.kr(env2, gate, doneAction: 0) * y;


	x = SinOsc.ar(freq1,y,1);
	x = Select.ar(wave1 > 0, [x, LFPulse.ar(freq1, y, 0.5, 1)]);
	x = Select.ar(wave1 > 1, [x, LFSaw.ar(freq1, y, 1)]);
	x = (mix1/10)*x;
	x = x + (aF*PinkNoise.ar(noise/10));
    x = EnvGen.kr(env1, gate, doneAction: 2) * x;

	x = x;

	//master volume and clip limit
	x = LeakDC.ar(x,0.995,1,0);
	out = (vel/127)*x;
	Out.ar(0, out);

}).add;

//ALGORITHM 9
SynthDef(\sinpk9, { arg freq = 440, gate = 1, vel = 100, mix1 = 5, delay1 = 0.001, attack1 = 0.01, decay1 = 0.3, sustain1 = 0.5, release1 = 0.5, peakLevel1 = 1, curve1 = 0, bias1 = 0, mix2 = 5, delay2 = 0.001, attack2 = 0.01, decay2 = 3, sustain2 = 0.5, release2 = 0.5, peakLevel2 = 1, curve2 = 0, bias2 = 0, mix3 = 5, delay3 = 0.001, attack3 = 0.01, decay3 = 0.3, sustain3 = 0.5, release3 = 0.5, peakLevel3 = 1, curve3 = 0, bias3 = 0, mix4 = 5, delay4 = 0.001, attack4 = 0.01, decay4 = 0.3, sustain4 = 0.5, release4 = 0.5, peakLevel4 = 1, curve4 = 0, bias4 = 0, wave1 = 0, wave2 = 0, wave3 = 0, wave4 = 0, ratio2 = 1, coarse2 = 0, ratio1 = 1, coarse1 = 0, ratio3 = 1, coarse3 = 0, ratio4 = 1, coarse4 = 0, noise = 0, aF = 1;

    var x, y, limited, out;
	var env1 = Env.dadsr(delay1, attack1, decay1, sustain1, release1,peakLevel1,curve1,bias1);
	var env2 = Env.dadsr(delay2, attack2, decay2, sustain2, release2, peakLevel2, curve2, bias2);
	var env3 = Env.dadsr(delay3, attack3, decay3, sustain3, release3, peakLevel3, curve3, bias3);
	var env4 = Env.dadsr(delay4, attack4, decay4, sustain4, release4, peakLevel4, curve4, bias4);

	var freq1 = freq*(ratio1+coarse1*aF);
	var freq2 = freq*(ratio2+coarse2*aF);
	var freq3 = freq*(ratio3+coarse3*aF);
	var freq4 = freq*(ratio4+coarse4*aF);

	w = SinOsc.ar(freq4,0,1);
	w = Select.ar(wave4 > 0, [w, LFPulse.ar(freq4, 0, 0.5,1)]);
	w = Select.ar(wave4 > 1, [w, LFSaw.ar(freq4, 0, 1)]);
	w= (mix4/10)*w;
	w= EnvGen.kr(env4, gate, doneAction: 0) * w;

	z = SinOsc.ar(freq3,0,1);
	z = Select.ar(wave3 > 0, [z, LFPulse.ar(freq3, 0, 0.5,1)]);
	z = Select.ar(wave3 > 1, [z, LFSaw.ar(freq3, 0, 1)]);
	z = (mix3/10)*z;
	z = EnvGen.kr(env3, gate, doneAction: 0) * z;

	y = SinOsc.ar(freq2,z+w,1);
	y = Select.ar(wave2 > 0, [y, LFPulse.ar(freq2, z+w, 0.5,1)]);
	y = Select.ar(wave2 > 1, [y, LFSaw.ar(freq2, z+w, 1)]);
	y = (mix2/10)*y;
	y = EnvGen.kr(env2, gate, doneAction: 0) * y;


	x = SinOsc.ar(freq1,z+w,1);
	x = Select.ar(wave1 > 0, [x, LFPulse.ar(freq1, z+w, 0.5, 1)]);
	x = Select.ar(wave1 > 1, [x, LFSaw.ar(freq1, z+w, 1)]);
	x = (mix1/10)*x;
	x = x + (aF*PinkNoise.ar(noise/10));
    x = EnvGen.kr(env1, gate, doneAction: 2) * x;

	x = x + y;
	x = x*(1/sqrt(2));

	//master volume and clip limit
	x = LeakDC.ar(x,0.995,1,0);
	out = (vel/127)*x;
	Out.ar(0, out);

}).add;

//ALGORITHM 10
SynthDef(\sinpk10, { arg freq = 440, gate = 1, vel = 100, mix1 = 5, delay1 = 0.001, attack1 = 0.01, decay1 = 0.3, sustain1 = 0.5, release1 = 0.5, peakLevel1 = 1, curve1 = 0, bias1 = 0, mix2 = 5, delay2 = 0.001, attack2 = 0.01, decay2 = 3, sustain2 = 0.5, release2 = 0.5, peakLevel2 = 1, curve2 = 0, bias2 = 0, mix3 = 5, delay3 = 0.001, attack3 = 0.01, decay3 = 0.3, sustain3 = 0.5, release3 = 0.5, peakLevel3 = 1, curve3 = 0, bias3 = 0, mix4 = 5, delay4 = 0.001, attack4 = 0.01, decay4 = 0.3, sustain4 = 0.5, release4 = 0.5, peakLevel4 = 1, curve4 = 0, bias4 = 0, wave1 = 0, wave2 = 0, wave3 = 0, wave4 = 0, ratio2 = 1, coarse2 = 0, ratio1 = 1, coarse1 = 0, ratio3 = 1, coarse3 = 0, ratio4 = 1, coarse4 = 0, noise = 0, aF = 1;

    var x, y, limited, out;
	var env1 = Env.dadsr(delay1, attack1, decay1, sustain1, release1,peakLevel1,curve1,bias1);
	var env2 = Env.dadsr(delay2, attack2, decay2, sustain2, release2, peakLevel2, curve2, bias2);
	var env3 = Env.dadsr(delay3, attack3, decay3, sustain3, release3, peakLevel3, curve3, bias3);
	var env4 = Env.dadsr(delay4, attack4, decay4, sustain4, release4, peakLevel4, curve4, bias4);

	var freq1 = freq*(ratio1+coarse1*aF);
	var freq2 = freq*(ratio2+coarse2*aF);
	var freq3 = freq*(ratio3+coarse3*aF);
	var freq4 = freq*(ratio4+coarse4*aF);

	w = SinOsc.ar(freq4,0,1);
	w = Select.ar(wave4 > 0, [w, LFPulse.ar(freq4, 0, 0.5,1)]);
	w = Select.ar(wave4 > 1, [w, LFSaw.ar(freq4, 0, 1)]);
	w= (mix4/10)*w;
	w= EnvGen.kr(env4, gate, doneAction: 0) * w;

	z = SinOsc.ar(freq3,w,1);
	z = Select.ar(wave3 > 0, [z, LFPulse.ar(freq3, w, 0.5,1)]);
	z = Select.ar(wave3 > 1, [z, LFSaw.ar(freq3, w, 1)]);
	z = (mix3/10)*z;
	z = EnvGen.kr(env3, gate, doneAction: 0) * z;

	y = SinOsc.ar(freq2,w,1);
	y = Select.ar(wave2 > 0, [y, LFPulse.ar(freq2, w, 0.5,1)]);
	y = Select.ar(wave2 > 1, [y, LFSaw.ar(freq2, w, 1)]);
	y = (mix2/10)*y;
	y = EnvGen.kr(env2, gate, doneAction: 0) * y;


	x = SinOsc.ar(freq1,w,1);
	x = Select.ar(wave1 > 0, [x, LFPulse.ar(freq1, w, 0.5, 1)]);
	x = Select.ar(wave1 > 1, [x, LFSaw.ar(freq1, w, 1)]);
	x = (mix1/10)*x;
	x = x + (aF*PinkNoise.ar(noise/10));
    x = EnvGen.kr(env1, gate, doneAction: 2) * x;

	x = x + y + z;
	x = x*((1/sqrt(2))**2);

	//master volume and clip limit
	x = LeakDC.ar(x,0.995,1,0);
	out = (vel/127)*x;
	Out.ar(0, out);

}).add;

//ALGORITHM 11
SynthDef(\sinpk11, { arg freq = 440, gate = 1, vel = 100, mix1 = 5, delay1 = 0.001, attack1 = 0.01, decay1 = 0.3, sustain1 = 0.5, release1 = 0.5, peakLevel1 = 1, curve1 = 0, bias1 = 0, mix2 = 5, delay2 = 0.001, attack2 = 0.01, decay2 = 3, sustain2 = 0.5, release2 = 0.5, peakLevel2 = 1, curve2 = 0, bias2 = 0, mix3 = 5, delay3 = 0.001, attack3 = 0.01, decay3 = 0.3, sustain3 = 0.5, release3 = 0.5, peakLevel3 = 1, curve3 = 0, bias3 = 0, mix4 = 5, delay4 = 0.001, attack4 = 0.01, decay4 = 0.3, sustain4 = 0.5, release4 = 0.5, peakLevel4 = 1, curve4 = 0, bias4 = 0, wave1 = 0, wave2 = 0, wave3 = 0, wave4 = 0, ratio2 = 1, coarse2 = 0, ratio1 = 1, coarse1 = 0, ratio3 = 1, coarse3 = 0, ratio4 = 1, coarse4 = 0, noise = 0, aF = 1;

    var x, y, limited, out;
	var env1 = Env.dadsr(delay1, attack1, decay1, sustain1, release1,peakLevel1,curve1,bias1);
	var env2 = Env.dadsr(delay2, attack2, decay2, sustain2, release2, peakLevel2, curve2, bias2);
	var env3 = Env.dadsr(delay3, attack3, decay3, sustain3, release3, peakLevel3, curve3, bias3);
	var env4 = Env.dadsr(delay4, attack4, decay4, sustain4, release4, peakLevel4, curve4, bias4);

	var freq1 = freq*(ratio1+coarse1*aF);
	var freq2 = freq*(ratio2+coarse2*aF);
	var freq3 = freq*(ratio3+coarse3*aF);
	var freq4 = freq*(ratio4+coarse4*aF);

	w = SinOsc.ar(freq4,0,1);
	w = Select.ar(wave4 > 0, [w, LFPulse.ar(freq4, 0, 0.5,1)]);
	w = Select.ar(wave4 > 1, [w, LFSaw.ar(freq4, 0, 1)]);
	w= (mix4/10)*w;
	w= EnvGen.kr(env4, gate, doneAction: 0) * w;

	z = SinOsc.ar(freq3,w,1);
	z = Select.ar(wave3 > 0, [z, LFPulse.ar(freq3, w, 0.5,1)]);
	z = Select.ar(wave3 > 1, [z, LFSaw.ar(freq3, w, 1)]);
	z = (mix3/10)*z;
	z = EnvGen.kr(env3, gate, doneAction: 0) * z;

	y = SinOsc.ar(freq2,w,1);
	y = Select.ar(wave2 > 0, [y, LFPulse.ar(freq2, w, 0.5,1)]);
	y = Select.ar(wave2 > 1, [y, LFSaw.ar(freq2, w, 1)]);
	y = (mix2/10)*y;
	y = EnvGen.kr(env2, gate, doneAction: 0) * y;


	x = SinOsc.ar(freq1,0,1);
	x = Select.ar(wave1 > 0, [x, LFPulse.ar(freq1, 0, 0.5, 1)]);
	x = Select.ar(wave1 > 1, [x, LFSaw.ar(freq1, 0, 1)]);
	x = (mix1/10)*x;
	x = x + (aF*PinkNoise.ar(noise/10));
    x = EnvGen.kr(env1, gate, doneAction: 2) * x;

	x = x + y + z;
	x = x*((1/sqrt(2))**2);

	//master volume and clip limit
	x = LeakDC.ar(x,0.995,1,0);
	out = (vel/127)*x;
	Out.ar(0, out);

}).add;

//ALGORITHM 12
SynthDef(\sinpk12, { arg freq = 440, gate = 1, vel = 100, mix1 = 5, delay1 = 0.001, attack1 = 0.01, decay1 = 0.3, sustain1 = 0.5, release1 = 0.5, peakLevel1 = 1, curve1 = 0, bias1 = 0, mix2 = 5, delay2 = 0.001, attack2 = 0.01, decay2 = 3, sustain2 = 0.5, release2 = 0.5, peakLevel2 = 1, curve2 = 0, bias2 = 0, mix3 = 5, delay3 = 0.001, attack3 = 0.01, decay3 = 0.3, sustain3 = 0.5, release3 = 0.5, peakLevel3 = 1, curve3 = 0, bias3 = 0, mix4 = 5, delay4 = 0.001, attack4 = 0.01, decay4 = 0.3, sustain4 = 0.5, release4 = 0.5, peakLevel4 = 1, curve4 = 0, bias4 = 0, wave1 = 0, wave2 = 0, wave3 = 0, wave4 = 0, ratio2 = 1, coarse2 = 0, ratio1 = 1, coarse1 = 0, ratio3 = 1, coarse3 = 0, ratio4 = 1, coarse4 = 0, noise = 0, aF = 1;

    var x, y, limited, out;
	var env1 = Env.dadsr(delay1, attack1, decay1, sustain1, release1,peakLevel1,curve1,bias1);
	var env2 = Env.dadsr(delay2, attack2, decay2, sustain2, release2, peakLevel2, curve2, bias2);
	var env3 = Env.dadsr(delay3, attack3, decay3, sustain3, release3, peakLevel3, curve3, bias3);
	var env4 = Env.dadsr(delay4, attack4, decay4, sustain4, release4, peakLevel4, curve4, bias4);

	var freq1 = freq*(ratio1+coarse1*aF);
	var freq2 = freq*(ratio2+coarse2*aF);
	var freq3 = freq*(ratio3+coarse3*aF);
	var freq4 = freq*(ratio4+coarse4*aF);

	w = SinOsc.ar(freq4,0,1);
	w = Select.ar(wave4 > 0, [w, LFPulse.ar(freq4, 0, 0.5,1)]);
	w = Select.ar(wave4 > 1, [w, LFSaw.ar(freq4, 0, 1)]);
	w= (mix4/10)*w;
	w= EnvGen.kr(env4, gate, doneAction: 0) * w;

	z = SinOsc.ar(freq3,0,1);
	z = Select.ar(wave3 > 0, [z, LFPulse.ar(freq3, 0, 0.5,1)]);
	z = Select.ar(wave3 > 1, [z, LFSaw.ar(freq3, 0, 1)]);
	z = (mix3/10)*z;
	z = EnvGen.kr(env3, gate, doneAction: 0) * z;

	y = SinOsc.ar(freq2,z+w,1);
	y = Select.ar(wave2 > 0, [y, LFPulse.ar(freq2, z+w, 0.5,1)]);
	y = Select.ar(wave2 > 1, [y, LFSaw.ar(freq2, z+w, 1)]);
	y = (mix2/10)*y;
	y = EnvGen.kr(env2, gate, doneAction: 0) * y;


	x = SinOsc.ar(freq1,z,1);
	x = Select.ar(wave1 > 0, [x, LFPulse.ar(freq1, z, 0.5, 1)]);
	x = Select.ar(wave1 > 1, [x, LFSaw.ar(freq1, z, 1)]);
	x = (mix1/10)*x;
	x = x + (aF*PinkNoise.ar(noise/10));
    x = EnvGen.kr(env1, gate, doneAction: 2) * x;

	x = x + y;
	x = x*(1/sqrt(2));

	//master volume and clip limit
	x = LeakDC.ar(x,0.995,1,0);
	out = (vel/127)*x;
	Out.ar(0, out);

}).add;

//ALGORITHM 13
SynthDef(\sinpk13, { arg freq = 440, gate = 1, vel = 100, mix1 = 5, delay1 = 0.001, attack1 = 0.01, decay1 = 0.3, sustain1 = 0.5, release1 = 0.5, peakLevel1 = 1, curve1 = 0, bias1 = 0, mix2 = 5, delay2 = 0.001, attack2 = 0.01, decay2 = 3, sustain2 = 0.5, release2 = 0.5, peakLevel2 = 1, curve2 = 0, bias2 = 0, mix3 = 5, delay3 = 0.001, attack3 = 0.01, decay3 = 0.3, sustain3 = 0.5, release3 = 0.5, peakLevel3 = 1, curve3 = 0, bias3 = 0, mix4 = 5, delay4 = 0.001, attack4 = 0.01, decay4 = 0.3, sustain4 = 0.5, release4 = 0.5, peakLevel4 = 1, curve4 = 0, bias4 = 0, wave1 = 0, wave2 = 0, wave3 = 0, wave4 = 0, ratio2 = 1, coarse2 = 0, ratio1 = 1, coarse1 = 0, ratio3 = 1, coarse3 = 0, ratio4 = 1, coarse4 = 0, noise = 0, aF = 1;

    var x, y, limited, out;
	var env1 = Env.dadsr(delay1, attack1, decay1, sustain1, release1,peakLevel1,curve1,bias1);
	var env2 = Env.dadsr(delay2, attack2, decay2, sustain2, release2, peakLevel2, curve2, bias2);
	var env3 = Env.dadsr(delay3, attack3, decay3, sustain3, release3, peakLevel3, curve3, bias3);
	var env4 = Env.dadsr(delay4, attack4, decay4, sustain4, release4, peakLevel4, curve4, bias4);

	var freq1 = freq*(ratio1+coarse1*aF);
	var freq2 = freq*(ratio2+coarse2*aF);
	var freq3 = freq*(ratio3+coarse3*aF);
	var freq4 = freq*(ratio4+coarse4*aF);

	w = SinOsc.ar(freq4,0,1);
	w = Select.ar(wave4 > 0, [w, LFPulse.ar(freq4, 0, 0.5,1)]);
	w = Select.ar(wave4 > 1, [w, LFSaw.ar(freq4, 0, 1)]);
	w= (mix4/10)*w;
	w= EnvGen.kr(env4, gate, doneAction: 0) * w;

	z = SinOsc.ar(freq3,0,1);
	z = Select.ar(wave3 > 0, [z, LFPulse.ar(freq3, 0, 0.5,1)]);
	z = Select.ar(wave3 > 1, [z, LFSaw.ar(freq3, 0, 1)]);
	z = (mix3/10)*z;
	z = EnvGen.kr(env3, gate, doneAction: 0) * z;

	y = SinOsc.ar(freq2,z+w,1);
	y = Select.ar(wave2 > 0, [y, LFPulse.ar(freq2, z+w, 0.5,1)]);
	y = Select.ar(wave2 > 1, [y, LFSaw.ar(freq2, z+w, 1)]);
	y = (mix2/10)*y;
	y = EnvGen.kr(env2, gate, doneAction: 0) * y;


	x = SinOsc.ar(freq1,0,1);
	x = Select.ar(wave1 > 0, [x, LFPulse.ar(freq1, 0, 0.5, 1)]);
	x = Select.ar(wave1 > 1, [x, LFSaw.ar(freq1, 0, 1)]);
	x = (mix1/10)*x;
	x = x + (aF*PinkNoise.ar(noise/10));
    x = EnvGen.kr(env1, gate, doneAction: 2) * x;

	x = x + y;
	x = x*(1/sqrt(2));

	//master volume and clip limit
	x = LeakDC.ar(x,0.995,1,0);
	out = (vel/127)*x;
	Out.ar(0, out);

}).add;

//ALGORITHM 14
SynthDef(\sinpk14, { arg freq = 440, gate = 1, vel = 100, mix1 = 5, delay1 = 0.001, attack1 = 0.01, decay1 = 0.3, sustain1 = 0.5, release1 = 0.5, peakLevel1 = 1, curve1 = 0, bias1 = 0, mix2 = 5, delay2 = 0.001, attack2 = 0.01, decay2 = 3, sustain2 = 0.5, release2 = 0.5, peakLevel2 = 1, curve2 = 0, bias2 = 0, mix3 = 5, delay3 = 0.001, attack3 = 0.01, decay3 = 0.3, sustain3 = 0.5, release3 = 0.5, peakLevel3 = 1, curve3 = 0, bias3 = 0, mix4 = 5, delay4 = 0.001, attack4 = 0.01, decay4 = 0.3, sustain4 = 0.5, release4 = 0.5, peakLevel4 = 1, curve4 = 0, bias4 = 0, wave1 = 0, wave2 = 0, wave3 = 0, wave4 = 0, ratio2 = 1, coarse2 = 0, ratio1 = 1, coarse1 = 0, ratio3 = 1, coarse3 = 0, ratio4 = 1, coarse4 = 0, noise = 0, aF = 1;

    var x, y, limited, out;
	var env1 = Env.dadsr(delay1, attack1, decay1, sustain1, release1,peakLevel1,curve1,bias1);
	var env2 = Env.dadsr(delay2, attack2, decay2, sustain2, release2, peakLevel2, curve2, bias2);
	var env3 = Env.dadsr(delay3, attack3, decay3, sustain3, release3, peakLevel3, curve3, bias3);
	var env4 = Env.dadsr(delay4, attack4, decay4, sustain4, release4, peakLevel4, curve4, bias4);

	var freq1 = freq*(ratio1+coarse1*aF);
	var freq2 = freq*(ratio2+coarse2*aF);
	var freq3 = freq*(ratio3+coarse3*aF);
	var freq4 = freq*(ratio4+coarse4*aF);

	w = SinOsc.ar(freq4,0,1);
	w = Select.ar(wave4 > 0, [w, LFPulse.ar(freq4, 0, 0.5,1)]);
	w = Select.ar(wave4 > 1, [w, LFSaw.ar(freq4, 0, 1)]);
	w= (mix4/10)*w;
	w= EnvGen.kr(env4, gate, doneAction: 0) * w;

	z = SinOsc.ar(freq3,w,1);
	z = Select.ar(wave3 > 0, [z, LFPulse.ar(freq3, w, 0.5,1)]);
	z = Select.ar(wave3 > 1, [z, LFSaw.ar(freq3, w, 1)]);
	z = (mix3/10)*z;
	z = EnvGen.kr(env3, gate, doneAction: 0) * z;

	y = SinOsc.ar(freq2,w,1);
	y = Select.ar(wave2 > 0, [y, LFPulse.ar(freq2, w, 0.5,1)]);
	y = Select.ar(wave2 > 1, [y, LFSaw.ar(freq2, w, 1)]);
	y = (mix2/10)*y;
	y = EnvGen.kr(env2, gate, doneAction: 0) * y;


	x = SinOsc.ar(freq1,y+z,1);
	x = Select.ar(wave1 > 0, [x, LFPulse.ar(freq1, y+z, 0.5, 1)]);
	x = Select.ar(wave1 > 1, [x, LFSaw.ar(freq1, y+z, 1)]);
	x = (mix1/10)*x;
	x = x + (aF*PinkNoise.ar(noise/10));
    x = EnvGen.kr(env1, gate, doneAction: 2) * x;

	x = x;

	//master volume and clip limit
	x = LeakDC.ar(x,0.995,1,0);
	out = (vel/127)*x;
	Out.ar(0, out);

}).add;

//ALGORITHM 15
SynthDef(\sinpk15, { arg freq = 440, gate = 1, vel = 100, mix1 = 5, delay1 = 0.001, attack1 = 0.01, decay1 = 0.3, sustain1 = 0.5, release1 = 0.5, peakLevel1 = 1, curve1 = 0, bias1 = 0, mix2 = 5, delay2 = 0.001, attack2 = 0.01, decay2 = 3, sustain2 = 0.5, release2 = 0.5, peakLevel2 = 1, curve2 = 0, bias2 = 0, mix3 = 5, delay3 = 0.001, attack3 = 0.01, decay3 = 0.3, sustain3 = 0.5, release3 = 0.5, peakLevel3 = 1, curve3 = 0, bias3 = 0, mix4 = 5, delay4 = 0.001, attack4 = 0.01, decay4 = 0.3, sustain4 = 0.5, release4 = 0.5, peakLevel4 = 1, curve4 = 0, bias4 = 0, wave1 = 0, wave2 = 0, wave3 = 0, wave4 = 0, ratio2 = 1, coarse2 = 0, ratio1 = 1, coarse1 = 0, ratio3 = 1, coarse3 = 0, ratio4 = 1, coarse4 = 0, noise = 0, aF = 1;

    var x, y, limited, out;
	var env1 = Env.dadsr(delay1, attack1, decay1, sustain1, release1,peakLevel1,curve1,bias1);
	var env2 = Env.dadsr(delay2, attack2, decay2, sustain2, release2, peakLevel2, curve2, bias2);
	var env3 = Env.dadsr(delay3, attack3, decay3, sustain3, release3, peakLevel3, curve3, bias3);
	var env4 = Env.dadsr(delay4, attack4, decay4, sustain4, release4, peakLevel4, curve4, bias4);

	var freq1 = freq*(ratio1+coarse1*aF);
	var freq2 = freq*(ratio2+coarse2*aF);
	var freq3 = freq*(ratio3+coarse3*aF);
	var freq4 = freq*(ratio4+coarse4*aF);

	w = SinOsc.ar(freq4,0,1);
	w = Select.ar(wave4 > 0, [w, LFPulse.ar(freq4, 0, 0.5,1)]);
	w = Select.ar(wave4 > 1, [w, LFSaw.ar(freq4, 0, 1)]);
	w= (mix4/10)*w;
	w= EnvGen.kr(env4, gate, doneAction: 0) * w;

	z = SinOsc.ar(freq3,w,1);
	z = Select.ar(wave3 > 0, [z, LFPulse.ar(freq3, w, 0.5,1)]);
	z = Select.ar(wave3 > 1, [z, LFSaw.ar(freq3, w, 1)]);
	z = (mix3/10)*z;
	z = EnvGen.kr(env3, gate, doneAction: 0) * z;

	y = SinOsc.ar(freq2,w,1);
	y = Select.ar(wave2 > 0, [y, LFPulse.ar(freq2, w, 0.5,1)]);
	y = Select.ar(wave2 > 1, [y, LFSaw.ar(freq2, w, 1)]);
	y = (mix2/10)*y;
	y = EnvGen.kr(env2, gate, doneAction: 0) * y;


	x = SinOsc.ar(freq1,y,1);
	x = Select.ar(wave1 > 0, [x, LFPulse.ar(freq1, y, 0.5, 1)]);
	x = Select.ar(wave1 > 1, [x, LFSaw.ar(freq1, y, 1)]);
	x = (mix1/10)*x;
	x = x + (aF*PinkNoise.ar(noise/10));
    x = EnvGen.kr(env1, gate, doneAction: 2) * x;

	x = x + z;
	x = x*(1/sqrt(2));

	//master volume and clip limit
	x = LeakDC.ar(x,0.995,1,0);
	out = (vel/127)*x;
	Out.ar(0, out);

}).add;

//ALGORITHM 16
SynthDef(\sinpk16, { arg freq = 440, gate = 1, vel = 100, mix1 = 5, delay1 = 0.001, attack1 = 0.01, decay1 = 0.3, sustain1 = 0.5, release1 = 0.5, peakLevel1 = 1, curve1 = 0, bias1 = 0, mix2 = 5, delay2 = 0.001, attack2 = 0.01, decay2 = 3, sustain2 = 0.5, release2 = 0.5, peakLevel2 = 1, curve2 = 0, bias2 = 0, mix3 = 5, delay3 = 0.001, attack3 = 0.01, decay3 = 0.3, sustain3 = 0.5, release3 = 0.5, peakLevel3 = 1, curve3 = 0, bias3 = 0, mix4 = 5, delay4 = 0.001, attack4 = 0.01, decay4 = 0.3, sustain4 = 0.5, release4 = 0.5, peakLevel4 = 1, curve4 = 0, bias4 = 0, wave1 = 0, wave2 = 0, wave3 = 0, wave4 = 0, ratio2 = 1, coarse2 = 0, ratio1 = 1, coarse1 = 0, ratio3 = 1, coarse3 = 0, ratio4 = 1, coarse4 = 0, noise = 0, aF = 1;

    var x, y, limited, out;
	var env1 = Env.dadsr(delay1, attack1, decay1, sustain1, release1,peakLevel1,curve1,bias1);
	var env2 = Env.dadsr(delay2, attack2, decay2, sustain2, release2, peakLevel2, curve2, bias2);
	var env3 = Env.dadsr(delay3, attack3, decay3, sustain3, release3, peakLevel3, curve3, bias3);
	var env4 = Env.dadsr(delay4, attack4, decay4, sustain4, release4, peakLevel4, curve4, bias4);

	var freq1 = freq*(ratio1+coarse1*aF);
	var freq2 = freq*(ratio2+coarse2*aF);
	var freq3 = freq*(ratio3+coarse3*aF);
	var freq4 = freq*(ratio4+coarse4*aF);

	w = SinOsc.ar(freq4,0,1);
	w = Select.ar(wave4 > 0, [w, LFPulse.ar(freq4, 0, 0.5,1)]);
	w = Select.ar(wave4 > 1, [w, LFSaw.ar(freq4, 0, 1)]);
	w= (mix4/10)*w;
	w= EnvGen.kr(env4, gate, doneAction: 0) * w;

	z = SinOsc.ar(freq3,w,1);
	z = Select.ar(wave3 > 0, [z, LFPulse.ar(freq3, w, 0.5,1)]);
	z = Select.ar(wave3 > 1, [z, LFSaw.ar(freq3, w, 1)]);
	z = (mix3/10)*z;
	z = EnvGen.kr(env3, gate, doneAction: 0) * z;

	y = SinOsc.ar(freq2,z,1);
	y = Select.ar(wave2 > 0, [y, LFPulse.ar(freq2, z, 0.5,1)]);
	y = Select.ar(wave2 > 1, [y, LFSaw.ar(freq2, z, 1)]);
	y = (mix2/10)*y;
	y = EnvGen.kr(env2, gate, doneAction: 0) * y;


	x = SinOsc.ar(freq1,y+w,1);
	x = Select.ar(wave1 > 0, [x, LFPulse.ar(freq1, y+w, 0.5, 1)]);
	x = Select.ar(wave1 > 1, [x, LFSaw.ar(freq1, y+w, 1)]);
	x = (mix1/10)*x;
	x = x + (aF*PinkNoise.ar(noise/10));
    x = EnvGen.kr(env1, gate, doneAction: 2) * x;

	x = x;

	//master volume and clip limit
	x = LeakDC.ar(x,0.995,1,0);
	out = (vel/127)*x;
	Out.ar(0, out);

}).add;


// Effects credit to https://github.com/mcfilib/modfm-synth

  /////////////////////////////////
 //       LOWPASS FILTER        //
/////////////////////////////////

SynthDef(\lowpass, {arg t_reset = 0, lfoShape = 0, lfoDuty = 0.5, freq = 10000, amount = 0, rate = 5, res = 1, gate = 1, delay = 0.001, attack = 0.01, decay = 0.3, sustain = 1, release = 0.2;
	var input, effect, sine, amp, dc, env, cut, lagFactor, lagFactor2, lfoPhase;

	amp = 0.5*amount;
	dc= 0.5;

	//lfoPhase = Sweep.kr(t_reset, 2pi * rate).wrap(-pi, pi); // for reset sine LFO phase
	//sine = SinOsc.kr(0, lfoPhase, amp, dc); // keyboard reset LFO

	sine = SinOsc.kr(rate, 0, amp, dc); //free-running LFO
	sine = Select.kr(lfoShape> 0, [sine, (amp*0.5*Pulse.kr(rate, lfoDuty, 2, -1)  + dc) ]);
	sine = Select.kr(lfoShape > 1, [sine, VarSaw.kr(rate, 0, lfoDuty, amp, dc)]);
	sine = Select.kr(lfoShape > 2, [sine, VarSaw.kr(rate, 0, lfoDuty, -1*amp, dc)]);

	cut = sine*1.9*freq;
	cut = Clip.kr(cut, 20, 20000); // Clip
	cut = Lag.kr(cut,0.2); // Smooth

	input = In.ar(0,1);
	effect = LPF.ar(input, cut); //Low pass filter

	//env = Env.dadsr(delay, attack, decay, sustain, release);
	//effect = HPF.ar(input, freq, EnvGen.kr(env, gate, doneAction: 0));
	//effect = input - effect;

	//effect = EnvGen.kr(env, gate, doneAction: 2)*effect;


	ReplaceOut.ar(0,effect); // Replace output
}).add;

  /////////////////////////////////
 //       HIGHPASS FILTER        //
/////////////////////////////////

SynthDef(\highpass, {arg freq = 20, amount = 0, rate = 5, res = 1, gate = 1, delay = 0.001, attack = 0.01, decay = 0.3, sustain = 1, release = 0.2;
	var input, effect, sine, env, cut;

	cut = freq;
	cut = Clip.kr(cut, 20, 20000);
	cut = Lag.kr(cut,0.2); // Smooth

	input = In.ar(0,1);
	effect = HPF.ar(input, cut); //Low pass filter

	//env = Env.dadsr(delay, attack, decay, sustain, release);
	//effect = HPF.ar(input, freq, EnvGen.kr(env, gate, doneAction: 0));
	//effect = input - effect;

	//effect = EnvGen.kr(env, gate, doneAction: 2)*effect;


	ReplaceOut.ar(0,effect); // Replace output
}).add;


  /////////////////////////////////
 //           DELAY             //
/////////////////////////////////

SynthDef(\delay, {arg wet = 0, del = 0.001, dec = 0.01 ;
	var input, effect, effect2, effect3, effect4, effect5;

	input= In.ar(0,1); //get two channels of input starting (and ending) on bus 0

	// Add some smoothing to both the decay and delay time control

	effect = DelayL.ar(input, 2, Lag.kr(del, 2), Lag.kr(dec, 0.09)); // Max delay of one second
	effect2 = max(0,(dec-del))*DelayL.ar(input, 2, Lag.kr(2*del, 2), Lag.kr(dec, 0.09));
	effect3 = max(0,(dec-(2*del)))*DelayL.ar(input, 2, Lag.kr(3*del, 2), Lag.kr(dec, 0.09));
	effect4 = max(0,(dec-(4*del)))*DelayL.ar(input, 2, Lag.kr(4*del, 2), Lag.kr(dec, 0.09));
	effect5 = max(0,(dec-(5*del)))*DelayL.ar(input, 2, Lag.kr(5*del, 2), Lag.kr(dec, 0.09));

	Out.ar(0,wet*(effect+effect2+effect3+effect4+effect5)); // Add to output

}).add;


  /////////////////////////////////
 //           REVERB            //
/////////////////////////////////
SynthDef(\reverb, {arg del=0.048, dec=1, wet = 0;
	var input;
	var numc,numa,temp, env;

	input=In.ar(0,1); //get two channels of input starting (and ending) on bus 0

	numc = 6; // number of comb delays
	numa = 4; // number of allpass delays

	// reverb predelay time :

	temp = DelayN.ar(input, 1, del);

	temp=Mix.fill(numc,{CombL.ar(temp,0.1,rrand(0.01, 0.1),dec)});

	// chain of 4 allpass delays on each of two channels (8 total) :
	numa.do({ temp = AllpassN.ar(temp, 0.051, rrand(0.01, 0.05), dec) });
	temp = 0.2*temp*wet;

	//temp = FreeVerb.ar(input, wet, del, dec, 1, 0);

	// add original sound to reverb and play it :
	Out.ar(0,(temp));
}).add;

  /////////////////////////////////
 //       FINAL LIMITER         //
/////////////////////////////////

SynthDef(\limiter, {arg master = 0.5;
  var input, effect;

  input = In.ar(0,1); //get first channel on bus 0
  // Note the exclamation mark followed by 2 makes
  // the the final output stereo
  effect = Limiter.ar((master*input), 0.9, 0.01 ! 2); // Apply gain

  ReplaceOut.ar(0,effect); // Replace output
}).add;




//-----------------------------------------------------------------------------//






//-----------------------------MIDI PARSING ------------------------------//


// credit to https://gist.github.com/umbrellaprocess/973d2aa16e95bf329ee2

keys = Array.newClear(128);
ccs = Array.newClear(128);


//Effects to add
g = Group.basicNew(s,1);
lp = Synth.tail(g, \lowpass);
hp = Synth.tail(g, \highpass);
de = Synth.tail(g, \delay);
re = Synth.tail(g, \reverb);
li = Synth.tail(g, \limiter);


  /////////////////////////////////
 //       NOTE ON         //
/////////////////////////////////
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
	{algorithm == 0} {synthN =\sinpk}
	{algorithm == 1} {synthN = \sinpk2}
	{algorithm == 2} {synthN = \sinpk3}
	{algorithm == 3} {synthN = \sinpk4}
	{algorithm == 4} {synthN = \sinpk5}
	{algorithm == 5} {synthN = \sinpk6}
	{algorithm == 6} {synthN = \sinpk7}
	{algorithm == 7} {synthN = \sinpk8}
	{algorithm == 8} {synthN =\sinpk9}
	{algorithm == 9} {synthN = \sinpk10}
	{algorithm == 10} {synthN = \sinpk11}
	{algorithm == 11} {synthN = \sinpk12}
	{algorithm == 12} {synthN = \sinpk13}
	{algorithm == 13} {synthN = \sinpk14}
	{algorithm == 14} {synthN = \sinpk15}
	{algorithm == 15} {synthN = \sinpk16}

	;

	node = Synth.head(g,synthN, [\freq, num.midicps, \vel, val, \ratio1, ratio1, \coarse1, coarse1, \ratio2, ratio2, \coarse2, coarse2, \ratio3, ratio3, \coarse3, coarse3, \ratio4, ratio4, \coarse4, coarse4, \mix1, mix1, \peakLevel1, peakLevel1, \delay1, delay1, \attack1, attack1, \decay1, decay1, \sustain1, sustain1, \release1, release1, \mix2, mix2, \peakLevel2, peakLevel2, \delay2, delay2, \attack2, attack2, \decay2, decay2, \sustain2, sustain2, \release2, release2, \mix3, mix3, \peakLevel3, peakLevel3, \delay3, delay3, \attack3, attack3, \decay3, decay3, \sustain3, sustain3, \release3, release3, \mix4, mix4, \peakLevel4, peakLevel4, \delay4, delay4, \attack4, attack4, \decay4, decay4, \sustain4, sustain4, \release4, release4, \wave1, wave1, \wave2, wave2, \wave3, wave3, \wave4, wave4, \noise, noise, \aF, aF]);

	//lp.set('\t_reset', 1);

	keys.put(num, node);

};
MIDIdef.noteOn(\on, ~noteOnFunc);

  /////////////////////////////////
 //       MIDI CC         //
/////////////////////////////////
~ccOnFunc = {arg valcc, numcc, chancc, srccc;

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
		case
		{valcc < 42} {delay1 = 0.1*valcc/42+0}
		{valcc < 85} {delay1 = 0.9*((valcc-42)/42)+0.1}
		{valcc < 128} {delay1 = 9*((valcc-84)/43)+1};
		for (0, 127, {arg i;
			keys[i].set(\delay1, delay1);
		}
		);
		('delay1: ').post; delay1.postln;
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
		case
		{valcc < 42} {delay2 = 0.1*valcc/42+0}
		{valcc < 85} {delay2 = 0.9*((valcc-42)/42)+0.1}
		{valcc < 128} {delay2 = 9*((valcc-84)/43)+1};
		for (0, 127, {arg i;
			keys[i].set(\delay2, delay2);
		}
		);
		('delay2: ').post; delay2.postln;
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

	//BANK 3: OP3
	{numcc == 21 && chancc == 2} {
		wave3 = floor(valcc/43);
		for (0, 127, {arg i;
			keys[i].set(\wave3, wave3);
		}
		);
		('wave3: ').post; wave3.postln;
	}

	{numcc == 22 && chancc == 2} {
		ratio3 = floor((valcc+1)/8);
		for (0, 127, {arg i;
			keys[i].set(\ratio3, ratio3);
		}
		);
		('Ratio3: ').post; ratio3.postln;
	}

	{numcc == 23 && chancc == 2} {
		coarse3 = (valcc/127);
		for (0, 127, {arg i;
			keys[i].set(\coarse3, coarse3);
		}
		);
		('coarse3: ').post; coarse3.postln;
	}

	{numcc == 24 && chancc == 2} {
		case
		{valcc < 42} {delay3 = 0.1*valcc/42+0}
		{valcc < 85} {delay3 = 0.9*((valcc-42)/42)+0.1}
		{valcc < 128} {delay3 = 9*((valcc-84)/43)+1};
		for (0, 127, {arg i;
			keys[i].set(\delay3, delay3);
		}
		);
		('delay3: ').post; delay3.postln;
	}

	{numcc == 25 && chancc == 2} {
		case
		{valcc < 42} {attack3 = 0.1*valcc/42+0}
		{valcc < 85} {attack3 = 0.9*((valcc-42)/42)+0.1}
		{valcc < 128} {attack3 = 9*((valcc-84)/43)+1};
		for (0, 127, {arg i;
			keys[i].set(\attack3, attack3);
		}
		);
		('attack3: ').post; attack3.postln;
	}

	{numcc == 26 && chancc == 2} {
		case
		{valcc < 42} {decay3 = 0.1*valcc/42+0}
		{valcc < 85} {decay3 = 0.9*((valcc-42)/42)+0.1}
		{valcc < 128} {decay3 = 9*((valcc-84)/43)+1};
		for (0, 127, {arg i;
			keys[i].set(\decay3, decay3);
		}
		);
		('decay3: ').post; decay3.postln;
	}

	{numcc == 27 && chancc == 2} {
		sustain3 = valcc/127;
		for (0, 127, {arg i;
			keys[i].set(\sustain3, sustain3);
		}
		);
		('sustain3: ').post; sustain3.postln;
	}

	{numcc == 28 && chancc == 2} {
		case
		{valcc < 42} {release3 = 0.1*valcc/42+0}
		{valcc < 85} {release3 = 0.9*((valcc-42)/42)+0.1}
		{valcc < 128} {release3 = 9*((valcc-84)/43)+1};
		for (0, 127, {arg i;
			keys[i].set(\release3, release3);
		}
		);
		('release3: ').post; release3.postln;
	}
	//

	//BANK4: OP4
	{numcc == 21 && chancc == 3} {
		wave4 = floor(valcc/43);
		for (0, 127, {arg i;
			keys[i].set(\wave4, wave4);
		}
		);
		('wave4: ').post; wave4.postln;
	}

	{numcc == 22 && chancc == 3} {
		ratio4 = floor((valcc+1)/8);
		for (0, 127, {arg i;
			keys[i].set(\ratio4, ratio4);
		}
		);
		('Ratio4: ').post; ratio4.postln;
	}

	{numcc == 23 && chancc == 3} {
		coarse4 = (valcc/127);
		for (0, 127, {arg i;
			keys[i].set(\coarse4, coarse4);
		}
		);
		('coarse4: ').post; coarse4.postln;
	}

	{numcc == 24 && chancc == 3} {
		case
		{valcc < 42} {delay4 = 0.1*valcc/42+0}
		{valcc < 85} {delay4 = 0.9*((valcc-42)/42)+0.1}
		{valcc < 128} {delay4 = 9*((valcc-84)/43)+1};
		for (0, 127, {arg i;
			keys[i].set(\delay4, delay4);
		}
		);
		('delay4: ').post; delay4.postln;
	}

	{numcc == 25 && chancc == 3} {
		case
		{valcc < 42} {attack4 = 0.1*valcc/42+0}
		{valcc < 85} {attack4 = 0.9*((valcc-42)/42)+0.1}
		{valcc < 128} {attack4 = 9*((valcc-84)/43)+1};
		for (0, 127, {arg i;
			keys[i].set(\attack4, attack4);
		}
		);
		('attack4: ').post; attack4.postln;
	}

	{numcc == 26 && chancc == 3} {
		case
		{valcc < 42} {decay4 = 0.1*valcc/42+0}
		{valcc < 85} {decay4 = 0.9*((valcc-42)/42)+0.1}
		{valcc < 128} {decay4 = 9*((valcc-84)/43)+1};
		for (0, 127, {arg i;
			keys[i].set(\decay4, decay4);
		}
		);
		('decay4: ').post; decay4.postln;
	}

	{numcc == 27 && chancc == 3} {
		sustain4 = valcc/127;
		for (0, 127, {arg i;
			keys[i].set(\sustain4, sustain4);
		}
		);
		('sustain4: ').post; sustain4.postln;
	}

	{numcc == 28 && chancc == 3} {
		case
		{valcc < 42} {release4 = 0.1*valcc/42+0}
		{valcc < 85} {release4 = 0.9*((valcc-42)/42)+0.1}
		{valcc < 128} {release4 = 9*((valcc-84)/43)+1};
		for (0, 127, {arg i;
			keys[i].set(\release4, release4);
		}
		);
		('release4: ').post; release4.postln;
	}
	//

	//BANK5: OPMIX
	{numcc == 21 && chancc == 4} {
		mix1 = 10*(valcc/127);
		for (0, 127, {arg i;
			keys[i].set(\mix1, mix1);
		}
		);
		('mix1: ').post; mix1.postln;
	}

	{numcc == 22 && chancc == 4} {
		mix2 = 10*(valcc/127);
		for (0, 127, {arg i;
			keys[i].set(\mix2, mix2);
		}
		);
		('mix2: ').post; mix2.postln;
	}

	{numcc == 23 && chancc == 4} {
		mix3 = 10*(valcc/127);
		for (0, 127, {arg i;
			keys[i].set(\mix3, mix3);
		}
		);
		('mix3: ').post; mix3.postln;
	}

	{numcc == 24 && chancc == 4} {
		mix4 = 10*(valcc/127);
		for (0, 127, {arg i;
			keys[i].set(\mix4, mix4);
		}
		);
		('mix4: ').post; mix4.postln;
	}

	{numcc == 25 && chancc == 4} {
		peakLevel1 = (valcc/127);
		for (0, 127, {arg i;
			keys[i].set(\peakLevel1, peakLevel1);
		}
		);
		('peakLevel1: ').post; peakLevel1.postln;
	}

	{numcc == 26 && chancc == 4} {
		peakLevel2 = (valcc/127);
		for (0, 127, {arg i;
			keys[i].set(\peakLevel2, peakLevel2);
		}
		);
		('peakLevel2: ').post; peakLevel2.postln;
	}

	{numcc == 27 && chancc == 4} {
		peakLevel3 = (valcc/127);
		for (0, 127, {arg i;
			keys[i].set(\peakLevel3, peakLevel3);
		}
		);
		('peakLevel3: ').post; peakLevel3.postln;
	}

	{numcc == 28 && chancc == 4} {
		peakLevel4 = (valcc/127);
		for (0, 127, {arg i;
			keys[i].set(\peakLevel4, peakLevel4);
		}
		);
		('peakLevel4: ').post; peakLevel4.postln;
	}
	//

	//BANK 6: GLOBAL CONTROL

	{numcc == 21 && chancc == 5} {
			algorithm = floor((valcc/127)*15);
		('algorithm: ').post; algorithm.postln;
	}


	{numcc == 22 && chancc == 5} {
		noise = 10*(valcc/127);
		for (0, 127, {arg i;
			keys[i].set(\noise, noise);
		}
		);
		('noise: ').post; noise.postln;
	}

	{numcc == 23 && chancc == 5} {
		case
		{valcc < 42} {filterFreq = (80*valcc/42)+20}
		{valcc < 85} {filterFreq = (900*((valcc-42)/42))+100}
		{valcc < 128} {filterFreq = 19000*((valcc-84)/43)+1000};
		lp.set(\freq,filterFreq);
		('filterFreq: ').post; filterFreq.postln;
	}

	{numcc == 24 && chancc == 5} {
		valcc = 127 - valcc;
		case
		{valcc < 42} {filterRes = 0.05*valcc/42+0.05}
		{valcc < 100} {filterRes = 0.9*((valcc-42)/42)+0.1}
		{valcc < 128} {filterRes = 0*((valcc-99)/28)+1};
		lp.set(\res, filterRes);
		('filterRes: ').post; filterRes.postln;
	}

	{numcc == 25 && chancc == 5} {
		case
		{valcc < 42} {hpFreq = (80*valcc/42)+20}
		{valcc < 85} {hpFreq = (900*((valcc-42)/42))+100}
		{valcc < 128} {hpFreq = 19000*((valcc-84)/43)+1000};
		hp.set(\freq,hpFreq);
		('hpFreq: ').post; hpFreq.postln;
	}

/*	{numcc == 26 && chancc == 5} {
		valcc = 127 - valcc;
		case
		{valcc < 42} {hpRes = 0.05*valcc/42+0.05}
		{valcc < 100} {hpRes = 0.9*((valcc-42)/42)+0.1}
		{valcc < 128} {hpRes = 0*((valcc-99)/28)+1};
		hp.set(\res, hpRes);
		('hpRes: ').post; hpRes.postln;
	}*/

	{numcc == 26 && chancc == 5} {
		lfoShape = floor(valcc/32);
		lfoDuty = mod(valcc, 32)/31;

		lp.set(\lfoShape, lfoShape);
		lp.set(\lfoDuty, lfoDuty);
		('lfoShape: ').post; lfoShape.postln;
		('lfoDuty: ').post; lfoDuty.postln;
	}


	{numcc == 27 && chancc == 5} {
		analogFac = valcc/(127);
		('analogFac: ').post; analogFac.postln;
	}

	{numcc == 28 && chancc == 5} {
		master = (valcc/127);
		li.set(\master, master);
		('master: ').post; master.postln;
	}
	//

	//BANK 7: EFFECTS

	{numcc == 21 && chancc == 6} {
		dwet = (valcc.linlin(0,127,0,1));
		de.set(\wet, dwet);
		('dwet: ').post; dwet.postln;
	}

	{numcc == 22 && chancc == 6} {
		ddel = valcc.linlin(0,127,0.001,0.999);
		de.set(\del, ddel);
		('ddel: ').post; ddel.postln;
	}


	{numcc == 23 && chancc == 6} {
		ddec = valcc.linlin(0,127,0.01,0.999);
		de.set(\dec, ddec);
		('ddec: ').post; ddec.postln;
	}


	{numcc == 24 && chancc == 6} {
		rwet = (valcc/127);
		re.set(\wet, rwet);
		('rwet: ').post; rwet.postln;
	}

	{numcc == 25 && chancc == 6} {
		rdel = (valcc.linlin(0,127,0.048,0.999));
		re.set(\del, rdel);
		('rdel: ').post; rdel.postln;
	}


	{numcc == 26 && chancc == 6} {
		rdec = 10*(valcc/127);
		re.set(\dec, rdec);
		('rdec: ').post; rdec.postln;
	}

	{numcc == 27 && chancc == 6} {
		lfoRate = 15*(valcc/127);

		case
		{valcc < 32} {lfoRate = (0.09*valcc/32)+0.01}
		{valcc < 64} {lfoRate = (0.9*((valcc-32)/32))+0.1}
		{valcc < 96} {lfoRate = 9*((valcc-64)/32)+1}
		{valcc < 128} {lfoRate = 90*((valcc-96)/32)+10};
		lp.set(\rate, lfoRate);
		('lfoRate: ').post; lfoRate.postln;
	}

	{numcc == 28 && chancc == 6} {
		lfoAmount = 0.99*(valcc/127);
		lp.set(\amount, lfoAmount);
		('lfoAmount: ').post; lfoAmount.postln;
	}

	//

	// BANK 8: FILTER

/*	{numcc == 24 && chancc == 6} {
		case
		{valcc < 42} {fdelay = 0.1*valcc/42+0}
		{valcc < 85} {fdelay = 0.9*((valcc-42)/42)+0.1}
		{valcc < 128} {fdelay = 9*((valcc-84)/43)+1};
		lp.set(\delay, fdelay);
		('fdelay: ').post; fdelay.postln;
	}

	{numcc == 25 && chancc == 6} {
		case
		{valcc < 42} {fattack = 0.1*valcc/42+0}
		{valcc < 85} {fattack = 0.9*((valcc-42)/42)+0.1}
		{valcc < 128} {fattack = 9*((valcc-84)/43)+1};
		lp.set(\attack, fattack);
		('fattack: ').post; fattack.postln;
	}

	{numcc == 26 && chancc == 6} {
		case
		{valcc < 42} {fdecay = 0.1*valcc/42+0}
		{valcc < 85} {fdecay = 0.9*((valcc-42)/42)+0.1}
		{valcc < 128} {fdecay = 9*((valcc-84)/43)+1};
		lp.set(\decay, fdecay);
		('fdecay: ').post; fdecay.postln;
	}

	{numcc == 27 && chancc == 6} {
		fsustain = valcc/127;
		lp.set(\sustain, fsustain);
		('fsustain: ').post; fsustain.postln;
	}

	{numcc == 28 && chancc == 6} {
		case
		{valcc < 42} {frelease = 0.1*valcc/42+0}
		{valcc < 85} {frelease = 0.9*((valcc-42)/42)+0.1}
		{valcc < 128} {frelease = 9*((valcc-84)/43)+1};
		lp.set(\release, frelease);
		('frelease: ').post; frelease.postln;
	}*/

	//


	;
};

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
};*/

MIDIdef.cc(\ccOn, ~ccOnFunc);

)

//-----------------------------------------------------------------------------//


/////////////////////////////////////////////////////////////////////////////////////
//-----------------------------END ------------------------------//
/////////////////////////////////////////////////////////////////////////////////////









//Print CCs and notes
(
MIDIdef.noteOn(\test4, {arg val, num, chan, src;
	[src,chan, num, val].postln;
});

MIDIdef.cc(\test5, {arg val, num, chan, src;
    [src,chan, num, val].postln;
});
)