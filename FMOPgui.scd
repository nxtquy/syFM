//-----------------------------DIRECT GUI CONTROL ------------------------------//
(
var w;
var s2;
var knobArray;
var knobP;
var buttonArray;
var whiteKeys;
var blackKeys;

var oct = 3;
var s2text;

//Keyboard location
var o1s = 150; //X location
var o2s = 210+o1s;
var kY = 650; // Y location
var add = 0;

//Knobs location
var knbX = 50;
var knbY = 10;


w= Window("testgui",Rect(100,300,800,850));


//KNOB GUI

knobArray = Array.newClear(100);
knobP = Array.with(
	'WAV1','FINE1','COARSE1','DEL1','ATK1','DEC1','SUS1','REL1',
	'WAV2','FINE2','COARSE2','DEL2','ATK2','DEC2','SUS2','REL2',
	'WAV3','FINE3','COARSE3','DEL3','ATK3','DEC3','SUS3','REL3',
	'WAV4','FINE4','COARSE4','DEL4','ATK4','DEC4','SUS4','REL4',
	'MIX1','MIX2','MIX3','MIX4','PK1','PK2','PK3','PK4',
	'ALG','NOISE','LPF','RES','HPF','HPRES','ANLGFAC','MASTER',
	'DWET','DDEL','DDEC','RWET','RDEL','RDEC','LFOR','LFOA',


);


knobP.do( {arg item, i;
	var num = i.mod(8)+21;
	var chan = floor(i/8);

	knobArray[i] =Knob(w, Rect((knbX+(90*i.mod(8))),(knbY +(90*floor(i/8))),70,70))
	.keyDownAction_({})
	.action={~ccOnFunc.value(127*knobArray[i].value,num,chan,0)};


	TextField(knobArray[i],Rect(5, 55, 60, 15))
	.value = item;

});


s2 = Slider(w,Rect(100,kY,20,120))
.keyDownAction_({})
.action = {
	oct = floor(8*s2.value);
	s2text.value = oct}
;
s2text = TextField(s2, Rect(0, 0, 20, 20));
s2text.value= oct;

//KEYBOARD BUTTON GUI
buttonArray = Array.newClear(29);
whiteKeys = Array.with(0,2,4,5,7,9,11,12,14,16,17,19,21,23,24,26,28);
blackKeys = Array.with(1,3,6,8,10,13,15,18,20,22,25,27);

whiteKeys.do({arg item, i;
	buttonArray[item] = Button.new(w,Rect(o1s+(30*i),kY,30,150))
	.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
	.mouseUpAction_({arg b; b.valueAction = 1})
	.mouseDownAction_({arg b; b.valueAction = 1})
	.action_({arg b;
		case
		{b.value== 1} {
			~noteOnFunc.value(100, item+((oct+1)*12), 0, 0);
			//(item+((oct+1)*12)).postln;
		}
		{b.value == 0} {~noteOffFunc.value(0, item+((oct+1)*12), 0, 0)};
	});
});

blackKeys.do({arg item, i;
	case
	{item == 6} {add = add+30}
	{item == 13} {add = add+30}
	{item == 18} {add = add + 30}
	{item == 25} {add = add + 30};

	buttonArray[item] = Button.new(w,Rect(o1s+19+add+(30*i),kY,22,100))
	.states_([["", Color.white, Color.black],["", Color.white, Color.grey]])
	.mouseUpAction_({arg b; b.valueAction = 1})
	.mouseDownAction_({arg b; b.valueAction = 1})
	.action_({arg b;
		case
		{b.value== 1} {
			~noteOnFunc.value(100, item+((oct+1)*12), 0, 0);
			//(item+((oct+1)*12)).postln;
		}
		{b.value == 0} {~noteOffFunc.value(0, item+((oct+1)*12), 0, 0)};
	});
});


//Use computer keyboard to send commands
w.view.keyDownAction = { arg view, char, modifiers, unicode, keycode;
	//[char, modifiers, unicode, keycode].postln;
	case
	{unicode == 122 && buttonArray[0].value == 0} {buttonArray[0].valueAction = 1}
	{unicode == 115 && buttonArray[1].value == 0} {buttonArray[1].valueAction = 1}
	{unicode == 120 && buttonArray[2].value == 0} {buttonArray[2].valueAction = 1}
	{unicode == 100 && buttonArray[3].value == 0} {buttonArray[3].valueAction = 1}
	{unicode == 99 && buttonArray[4].value == 0} {buttonArray[4].valueAction = 1}
	{unicode == 118 && buttonArray[5].value == 0} {buttonArray[5].valueAction = 1}
	{unicode == 103 && buttonArray[6].value == 0} {buttonArray[6].valueAction = 1}
	{unicode == 98 && buttonArray[7].value == 0} {buttonArray[7].valueAction = 1}
	{unicode == 104 && buttonArray[8].value == 0} {buttonArray[8].valueAction = 1}
	{unicode == 110 && buttonArray[9].value == 0} {buttonArray[9].valueAction = 1}
	{unicode == 106 && buttonArray[10].value == 0} {buttonArray[10].valueAction = 1}
	{unicode == 109 && buttonArray[11].value == 0} {buttonArray[11].valueAction = 1}
	{unicode == 44 && buttonArray[12].value == 0} {buttonArray[12].valueAction = 1}

	{unicode == 113 && buttonArray[12].value == 0} {buttonArray[12].valueAction = 1}
	{unicode == 50 && buttonArray[13].value == 0} {buttonArray[13].valueAction = 1}
	{unicode == 119 && buttonArray[14].value == 0} {buttonArray[14].valueAction = 1}
	{unicode == 51 && buttonArray[15].value == 0} {buttonArray[15].valueAction = 1}
	{unicode == 101 && buttonArray[16].value == 0} {buttonArray[16].valueAction = 1}
	{unicode == 114 && buttonArray[17].value == 0} {buttonArray[17].valueAction = 1}
	{unicode == 53 && buttonArray[18].value == 0} {buttonArray[18].valueAction = 1}
	{unicode == 116 && buttonArray[19].value == 0} {buttonArray[19].valueAction = 1}
	{unicode == 54 && buttonArray[20].value == 0} {buttonArray[20].valueAction = 1}
	{unicode == 121 && buttonArray[21].value == 0} {buttonArray[21].valueAction = 1}
	{unicode == 55 && buttonArray[22].value == 0} {buttonArray[22].valueAction = 1}
	{unicode == 117 && buttonArray[23].value == 0} {buttonArray[23].valueAction = 1}
	{unicode == 105 && buttonArray[24].value == 0} {buttonArray[24].valueAction = 1}

	{unicode == 57 && buttonArray[25].value == 0} {buttonArray[25].valueAction = 1}
	{unicode == 111 && buttonArray[26].value == 0} {buttonArray[26].valueAction = 1}
	{unicode == 48 && buttonArray[27].value == 0} {buttonArray[27].valueAction = 1}
	{unicode== 112 && buttonArray[28].value == 0} {buttonArray[28].valueAction = 1}
	{unicode == 47} {oct = oct + 1; s2text.value=oct}
	{unicode == 46} {oct = oct - 1; s2text.value = oct};

};


w.view.keyUpAction = { arg view, char, modifiers, unicode, keycode;
	case
	{unicode == 122} {buttonArray[0].valueAction = 0}
	{unicode == 115} {buttonArray[1].valueAction = 0}
	{unicode == 120} {buttonArray[2].valueAction = 0}
	{unicode == 100} {buttonArray[3].valueAction = 0}
	{unicode == 99} {buttonArray[4].valueAction = 0}
	{unicode == 118} {buttonArray[5].valueAction = 0}
	{unicode == 103} {buttonArray[6].valueAction = 0}
	{unicode == 98} {buttonArray[7].valueAction = 0}
	{unicode == 104} {buttonArray[8].valueAction = 0}
	{unicode == 110} {buttonArray[9].valueAction = 0}
	{unicode == 106} {buttonArray[10].valueAction = 0}
	{unicode == 109} {buttonArray[11].valueAction = 0}
	{unicode == 44} {buttonArray[12].valueAction = 0}

	{unicode == 113} {buttonArray[12].valueAction = 0}
	{unicode == 50} {buttonArray[13].valueAction = 0}
	{unicode == 119} {buttonArray[14].valueAction = 0}
	{unicode == 51} {buttonArray[15].valueAction = 0}
	{unicode == 101} {buttonArray[16].valueAction = 0}
	{unicode == 114} {buttonArray[17].valueAction = 0}
	{unicode == 53} {buttonArray[18].valueAction = 0}
	{unicode == 116} {buttonArray[19].valueAction = 0}
	{unicode == 54} {buttonArray[20].valueAction = 0}
	{unicode == 121} {buttonArray[21].valueAction = 0}
	{unicode == 55} {buttonArray[22].valueAction = 0}
	{unicode == 117} {buttonArray[23].valueAction = 0}
	{unicode == 105} {buttonArray[24].valueAction = 0}

	{unicode == 57} {buttonArray[25].valueAction = 0}
	{unicode == 111} {buttonArray[26].valueAction = 0}
	{unicode == 48} {buttonArray[27].valueAction = 0}
	{unicode == 112} {buttonArray[28].valueAction = 0};


};

w.front;

w.onClose= {};
)

//-----------------------------------------------------------------------------//