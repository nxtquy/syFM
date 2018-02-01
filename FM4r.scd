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

    var x, y, limited, out;
	var env1 = Env.adsr(aF*attack1, aF*decay1, aF*sustain1, aF*release1,aF*peakLevel1,aF*curve1,aF*bias1);
	var env2 = Env.adsr(aF*attack2, aF*decay2, aF*sustain2, aF*release2, aF*peakLevel2, aF*curve2, aF*bias2);

	var freq1 = freq*(ratio1+coarse1)*aF;
	var freq2 = freq1*(ratio2+coarse2);

	y = SinOsc.ar(freq2,0,1);
	y = Select.ar(wave2 > 0, [y, Pulse.ar(freq2,0.5,1)]);
	y = Select.ar(wave2 > 1, [y, Saw.ar(freq2,1)]);
	y = (mix2/10)*y;
	y = EnvGen.kr(env2, gate, doneAction: 0) * y;


	x = SinOsc.ar(freq1,y,1);
	x = Select.ar(wave1 > 0, [x, 5*Pulse.ar(freq1,0.5,y)]);
	x = Select.ar(wave1 > 1, [x, 5*Saw.ar(freq1,y)]);
	x = (mix1/10)*x;
	x = x + (aF*PinkNoise.ar(noise/10));
    x = EnvGen.kr(env1, gate, doneAction: 2) * x;

	//x = BLowPass.ar(x, filterFreq, filterRes);

	//master volume and clip limit
	x = LeakDC.ar(x,0.995,1,0);
	out = master*(vel/127)*x;
	Out.ar(0, out);

}).add;

//Algorithm 2
SynthDef(\sinpk2, { arg freq = 440, gate = 1, vel = 100, mix1 = 5, attack1 = 0.01, decay1 = 0.3, sustain1 = 0.5, release1 = 0.5, peakLevel1 = 1, curve1 = 0, bias1 = 0, mix2 = 5, attack2 = 0.01, decay2 = 3, sustain2 = 0.5, release2 = 0.5, peakLevel2 = 1, curve2 = 0, bias2 = 0, wave1 = 0, wave2 = 0, ratio2 = 1, coarse2 = 0, ratio1 = 1, coarse1 = 0, noise = 0, filterFreq = 20000, filterRes = 1, master = 0.5, aF = 1;

    var x, y, out, limited;
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

	x = (0.5*x) + (0.5*y);
	//x = BLowPass.ar(x, filterFreq, filterRes);

	x = LeakDC.ar(x,0.995,1,0);
	out = master*(vel/127)*x;
	Out.ar(0, out);

}).add;


  /////////////////////////////////
 //       LOWPASS FILTER        //
/////////////////////////////////

SynthDef(\lowpass, {arg freq = 10000, amount = 0, rate = 5, res = 1;
  var input, effect, sine;

  sine = SinOsc.kr(rate,0,0.5*amount,1); // LFO

  input = In.ar(0,1);
	effect = LPF.ar(input, Lag.kr((sine)*freq,0.2)); // Apply LFO and smooth

  ReplaceOut.ar(0,effect); // Replace output
}).add;


  /////////////////////////////////
 //           DELAY             //
/////////////////////////////////

SynthDef(\delay, {arg del = 0.001, dec = 0.01 ;
  var input, effect;

  input= In.ar(0,1); //get two channels of input starting (and ending) on bus 0

  // Add some smoothing to both the decay and delay time control
  effect = DelayN.ar(input, 1, Lag.kr(del, 2), Lag.kr(dec, 0.09)); // Max delay of one second

  Out.ar(0,effect); // Add to output
}).add;


  /////////////////////////////////
 //           REVERB            //
/////////////////////////////////
SynthDef(\reverb, {arg del=0.01, dec=1, wet = 0;
	var input;
	var numc,numa,temp, env;

	input=In.ar(0,1); //get two channels of input starting (and ending) on bus 0

	numc = 4; // number of comb delays
	numa = 6; // number of allpass delays

	// reverb predelay time :
	temp = DelayN.ar(input, 0.048,0.048);

	temp=Mix.fill(numc,{CombL.ar(temp,0.1,rrand(0.01, 0.1),5)});

	// chain of 4 allpass delays on each of two channels (8 total) :
	numa.do({ temp = AllpassN.ar(temp, 0.051, [rrand(0.01, 0.05),rrand(0.01, 0.05)], 1) });
	temp = 0.2*temp*wet;

	//temp = FreeVerb.ar(input, wet, del, dec, 1, 0);

	// add original sound to reverb and play it :
	Out.ar(0,(temp));
}).add;

  /////////////////////////////////
 //       FINAL LIMITER         //
/////////////////////////////////

SynthDef(\limiter, {arg gain = 1;
  var input, effect;

  input = In.ar(0,1); //get first channel on bus 0
  // Note the exclamation mark followed by 2 makes
  // the the final output stereo
  effect = Limiter.ar((gain*input), 0.9, 0.01 ! 2); // Apply gain

  ReplaceOut.ar(0,effect); // Replace output
}).add;

)



//-----------------------------------------------------------------------------//




//-----------------------------MIDI PARSING ------------------------------//

(
// https://gist.github.com/umbrellaprocess/973d2aa16e95bf329ee2
var ratio1 = 1, coarse1 = 0, peakLevel1 = 1, mix1=5, attack1=rrand(0.01,1), decay1 = rrand(0.25,5), sustain1=rrand(0.25,1), release1=rrand(0.25,5);
var ratio2 = round(rand(1,4)), coarse2 = 0, peakLevel2 = 1, mix2=5, attack2=rand(0.01,1), decay2 = rand(0.01,1), sustain2 = rrand(0.25,1), release2=rrand(0.25,5);
var noise = 0, wave1 = 0, wave2 = round(rrand(0,2)), filterFreq = rrand(100,10000), filterRes = 1, master = 0.5, analogFac = rrand(0,1);
var algorithm = round(rrand(1,2));
var lfoRate = rrand(0.01,10), lfoAmount = rrand(0,1);
var ddec = 0.01, ddel = 0.001;
var rdec = 1, rdel = 0.01, rwet = 0;


var ccres = 127;
var aF = 1;

var lp, hp, de, li, re;

var synthN = \sinpk;
var keys;
var ccs;
keys = Array.newClear(128);
ccs = Array.newClear(128);


//Effects to add
g = Group.basicNew(s,1);
lp = Synth.tail(g, \lowpass);
de = Synth.tail(g, \delay);
re = Synth.tail(g, \reverb);
li = Synth.tail(g, \limiter);

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

	node = Synth.head(g,synthN, [\freq, num.midicps, \vel, val, \ratio1, ratio1, \coarse1, coarse1, \ratio2, ratio2, \coarse2, coarse2, \mix1, mix1, \peakLevel1, peakLevel1, \attack1, attack1, \decay1, decay1, \sustain1, sustain1, \release1, release1, \mix2, mix2, \peakLevel2, peakLevel2, \attack2, attack2, \decay2, decay2, \sustain2, sustain2, \release2, release2, \wave1, wave1, \wave2, wave2, \noise, noise, \filterFreq, filterFreq, \filterRes, filterRes, \master, master, \aF, aF]);


	keys.put(num, node);

};
MIDIdef.noteOn(\on, ~noteOnFunc);


//MIDI CC to change notesynth parameters live
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
		case
		{valcc < 42} {filterFreq = (100*valcc/42)+50}
		{valcc < 85} {filterFreq = (850*((valcc-42)/42))+150}
		{valcc < 128} {filterFreq = 17000*((valcc-84)/43)+1000};

		for (0, 127, {arg i;
			keys[i].set(\filterFreq, filterFreq+20);
		}
		);
		lp.set(\freq,filterFreq);
		('filterFreq: ').post; filterFreq.postln;
	}

	{numcc == 26 && chancc == 2} {
		valcc = 127 - valcc;
		case
		{valcc < 42} {filterRes = 0.075*valcc/42+0.025}
		{valcc < 100} {filterRes = 0.9*((valcc-42)/42)+0.1}
		{valcc < 128} {filterRes = 39*((valcc-99)/28)+1};
		for (0, 127, {arg i;
			keys[i].set(\filterRes, filterRes);
		}
		);
		lp.set(\res, filterRes);
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

	//BANK 4: EFFECTS

	{numcc == 21 && chancc == 3} {
		ddel = valcc.linlin(0,127,0.0001,0.999);
		de.set(\del, ddel);
		('ddel: ').post; ddel.postln;
	}


	{numcc == 22 && chancc == 3} {
		ddec = valcc.linlin(0,127,0.01,0.999);
		de.set(\dec, ddec);
		('ddec: ').post; ddec.postln;
	}

	{numcc == 23 && chancc == 3} {
		rdel = (valcc/127);
		re.set(\del, rdel);
		('rdel: ').post; rdel.postln;
	}


	{numcc == 24 && chancc == 3} {
		rdec = (valcc/127);
		re.set(\dec, rdec);
		('rdec: ').post; rdec.postln;
	}

	{numcc == 25 && chancc == 3} {
		rwet = (valcc/127);
		re.set(\wet, rwet);
		('rwet: ').post; rwet.postln;
	}

	{numcc == 26 && chancc == 3} {
		lfoRate = 15*(valcc/127);

		case
		{valcc < 32} {lfoRate = (0.09*valcc/32)+0.01}
		{valcc < 64} {lfoRate = (0.9*((valcc-32)/32))+0.1}
		{valcc < 96} {lfoRate = 9*((valcc-64)/32)+1}
		{valcc < 128} {lfoRate = 90*((valcc-96)/32)+10};
		lp.set(\rate, lfoRate);
		('lfoRate: ').post; lfoRate.postln;
	}

	{numcc == 27 && chancc == 3} {
		lfoAmount = 0.99*(valcc/127);
		lp.set(\amount, lfoAmount);
		('lfoAmount: ').post; lfoAmount.postln;
	}

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












//Print CCs and notes
(
MIDIdef.noteOn(\test4, {arg val, num, chan, src;
	[src,chan, num, val].postln;
});

MIDIdef.cc(\test5, {arg val, num, chan, src;
    [src,chan, num, val].postln;
});
)