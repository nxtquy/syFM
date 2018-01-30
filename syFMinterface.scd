/GUI to send MIDI


//boot server
(
s.boot;
s.options.sampleRate= 48000;
)

(

var w;
var k1, k2;
var s1, s2;
var b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12;
var b13, b14, b15, b16, b17, b18, b19, b20, b21, b22, b23, b24;
var b25, b26, b27, b28, b29, b30;

var oct = 3;
var s2text;

//Keyboard location
var o1s = 150; //X location
var o2s = 210+o1s;
var kY = 300; // Y location


w= Window("testgui",Rect(100,300,1000,500));

k1= Knob(w,Rect(110,50,80,80))
.keyDownAction_({})
.action={(127*k1.value).postln}
;

s1 = Slider(w,Rect(250,50,20,80))
.keyDownAction_({})
.action = {(127*s1.value).postln}
;

s2 = Slider(w,Rect(100,kY,20,80))
.keyDownAction_({})
.action = {
	oct = floor(6*s2.value);
	s2text.value = oct}
;
s2text = TextField(s2, Rect(0, 0, 20, 20));
s2text.value= oct;

//OCTAVE 1

b1 = Button.new(w,Rect(o1s+10,kY,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(0+(oct*12)).postln;
		~noteOnFunc1.value(0, 0+(oct*12), 0, 0);
	}
	{b.value == 0} {};
});

b2 = Button.new(w,Rect(o1s+29,kY,22,100))
.states_([["", Color.white, Color.black],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(1+(oct*12)).postln}
	{b.value == 0} {};
});
b2.front;

b3 = Button.new(w,Rect(o1s+40,kY,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(2+(oct*12)).postln}
	{b.value == 0} {};
});

b4 = Button.new(w,Rect(o1s+59,kY,22,100))
.states_([["", Color.white, Color.black],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(3+(oct*12)).postln}
	{b.value == 0} {};
});
b4.front;

b5 = Button.new(w,Rect(o1s+70,kY,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(4+(oct*12)).postln}
	{b.value == 0} {};
});

b6 = Button.new(w,Rect(o1s+100,kY,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(5+(oct*12)).postln}
	{b.value == 0} {};
});

b7 = Button.new(w,Rect(o1s+119,kY,22,100))
.states_([["", Color.white, Color.black],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(6+(oct*12)).postln}
	{b.value == 0} {};
});
b7.front;

b8 = Button.new(w,Rect(o1s+130,kY,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(7+(oct*12)).postln}
	{b.value == 0} {};
});

b9 = Button.new(w,Rect(o1s+149,kY,22,100))
.states_([["", Color.white, Color.black],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(8+(oct*12)).postln}
	{b.value == 0} {};
});
b9.front;

b10 = Button.new(w,Rect(o1s+160,kY,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(9+(oct*12)).postln}
	{b.value == 0} {};
});

b11 = Button.new(w,Rect(o1s+179,kY,22,100))
.states_([["", Color.white, Color.black],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(10+(oct*12)).postln}
	{b.value == 0} {};
});
b11.front;

b12 = Button.new(w,Rect(o1s+190,kY,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(11+(oct*12)).postln}
	{b.value == 0} {};
});

b13 = Button.new(w,Rect(o1s+220,kY,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(12+(oct*12)).postln}
	{b.value == 0} {};
});

//OCTAVE 2

b14 = Button.new(w,Rect(o2s+29,kY,22,100))
.states_([["", Color.white, Color.black],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(13+(oct*12)).postln}
	{b.value == 0} {};
});
b14.front;

b15 = Button.new(w,Rect(o2s+40,kY,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(14+(oct*12)).postln}
	{b.value == 0} {};
});

b16 = Button.new(w,Rect(o2s+59,kY,22,100))
.states_([["", Color.white, Color.black],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(15+(oct*12)).postln}
	{b.value == 0} {};
});
b16.front;

b17 = Button.new(w,Rect(o2s+70,kY,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(16+(oct*12)).postln}
	{b.value == 0} {};
});

b18 = Button.new(w,Rect(o2s+100,kY,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(17+(oct*12)).postln}
	{b.value == 0} {};
});

b19 = Button.new(w,Rect(o2s+119,kY,22,100))
.states_([["", Color.white, Color.black],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(18+(oct*12)).postln}
	{b.value == 0} {};
});
b19.front;

b20 = Button.new(w,Rect(o2s+130,kY,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(19+(oct*12)).postln}
	{b.value == 0} {};
});

b21 = Button.new(w,Rect(o2s+149,kY,22,100))
.states_([["", Color.white, Color.black],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(20+(oct*12)).postln}
	{b.value == 0} {};
});
b21.front;

b22 = Button.new(w,Rect(o2s+160,kY,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(21+(oct*12)).postln}
	{b.value == 0} {};
});

b23 = Button.new(w,Rect(o2s+179,kY,22,100))
.states_([["", Color.white, Color.black],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(22+(oct*12)).postln}
	{b.value == 0} {};
});
b23.front;

b24 = Button.new(w,Rect(o2s+190,kY,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(23+(oct*12)).postln}
	{b.value == 0} {};
});

b25 = Button.new(w,Rect(o2s+220,kY,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(24+(oct*12)).postln}
	{b.value == 0} {};
});

b26 = Button.new(w,Rect(o2s+239,kY,22,100))
.states_([["", Color.white, Color.black],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(25+(oct*12)).postln}
	{b.value == 0} {};
});
b26.front;

b27 = Button.new(w,Rect(o2s+250,kY,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(26+(oct*12)).postln}
	{b.value == 0} {};
});

b28 = Button.new(w,Rect(o2s+269,kY,22,100))
.states_([["", Color.white, Color.black],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(27+(oct*12)).postln}
	{b.value == 0} {};
});
b28.front;

b29 = Button.new(w,Rect(o2s+280,kY,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.valueAction = 1})
.action_({arg b;
	case
	{b.value== 1} {(28+(oct*12)).postln}
	{b.value == 0} {};
});





//Use computer keyboard to send commands
w.view.keyDownAction = { arg view, char, modifiers, unicode, keycode;
	//[char, modifiers, unicode, keycode].postln;
	case
	{keycode == 6} {b1.valueAction = 1}
	{keycode == 1} {b2.valueAction = 1}
	{keycode == 7} {b3.valueAction = 1}
	{keycode == 2} {b4.valueAction = 1}
	{keycode == 8} {b5.valueAction = 1}
	{keycode == 9} {b6.valueAction = 1}
	{keycode == 5} {b7.valueAction = 1}
	{keycode == 11} {b8.valueAction = 1}
	{keycode == 4} {b9.valueAction = 1}
	{keycode == 45} {b10.valueAction = 1}
	{keycode == 38} {b11.valueAction = 1}
	{keycode == 46} {b12.valueAction = 1}
	{keycode == 43} {b13.valueAction = 1}

	{keycode == 12} {b13.valueAction = 1}
	{keycode == 19} {b14.valueAction = 1}
	{keycode == 13} {b15.valueAction = 1}
	{keycode == 20} {b16.valueAction = 1}
	{keycode == 14} {b17.valueAction = 1}
	{keycode == 15} {b18.valueAction = 1}
	{keycode == 23} {b19.valueAction = 1}
	{keycode == 17} {b20.valueAction = 1}
	{keycode == 22} {b21.valueAction = 1}
	{keycode == 16} {b22.valueAction = 1}
	{keycode == 26} {b23.valueAction = 1}
	{keycode == 32} {b24.valueAction = 1}
	{keycode == 34} {b25.valueAction = 1}

	{keycode == 25} {b26.valueAction = 1}
	{keycode == 31} {b27.valueAction = 1}
	{keycode == 29} {b28.valueAction = 1}
	{keycode == 35} {b29.valueAction = 1};

};

w.view.keyUpAction = { arg view, char, modifiers, unicode, keycode;
	case
	{keycode == 6} {b1.valueAction = 0}
	{keycode == 1} {b2.valueAction = 0}
	{keycode == 7} {b3.valueAction = 0}
	{keycode == 2} {b4.valueAction = 0}
	{keycode == 8} {b5.valueAction = 0}
	{keycode == 9} {b6.valueAction = 0}
	{keycode == 5} {b7.valueAction = 0}
	{keycode == 11} {b8.valueAction = 0}
	{keycode == 4} {b9.valueAction = 0}
	{keycode == 45} {b10.valueAction = 0}
	{keycode == 38} {b11.valueAction = 0}
	{keycode == 46} {b12.valueAction = 0}
	{keycode == 43} {b13.valueAction = 0}

	{keycode == 12} {b13.valueAction = 0}
	{keycode == 19} {b14.valueAction = 0}
	{keycode == 13} {b15.valueAction = 0}
	{keycode == 20} {b16.valueAction = 0}
	{keycode == 14} {b17.valueAction = 0}
	{keycode == 15} {b18.valueAction = 0}
	{keycode == 23} {b19.valueAction = 0}
	{keycode == 17} {b20.valueAction = 0}
	{keycode == 22} {b21.valueAction = 0}
	{keycode == 16} {b22.valueAction = 0}
	{keycode == 26} {b23.valueAction = 0}
	{keycode == 32} {b24.valueAction = 0}
	{keycode == 34} {b25.valueAction = 0}

	{keycode == 25} {b26.valueAction = 0}
	{keycode == 31} {b27.valueAction = 0}
	{keycode == 29} {b28.valueAction = 0}
	{keycode == 35} {b29.valueAction = 0};


};

w.front;

w.onClose= {};

)









