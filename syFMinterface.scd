/GUI to send MIDI
(
var w, k1, s1, b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15, b16;
var oct = 3;


w= Window("testgui",Rect(100,300,1000,500));

k1= Knob(w,Rect(110,50,80,80))
.keyDownAction_({})
.action={(127*k1.value).postln}
;

s1 = Slider(w,Rect(250,50,20,80))
.keyDownAction_({})
.action = {(127*s1.value).postln}
;

b1 = Button.new(w,Rect(10,300,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.value = 1})
.action_({arg b;
	case
	{b.value== 1} {(0+(oct*12)).postln}
	{b.value == 0} {};
});

b2 = Button.new(w,Rect(29,300,22,100))
.states_([["", Color.white, Color.black],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.value = 1})
.action_({arg b;
	case
	{b.value== 1} {(1+(oct*12)).postln}
	{b.value == 0} {};
});
b2.front;

b3 = Button.new(w,Rect(40,300,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.value = 1})
.action_({arg b;
	case
	{b.value== 1} {(2+(oct*12)).postln}
	{b.value == 0} {};
});

b4 = Button.new(w,Rect(59,300,22,100))
.states_([["", Color.white, Color.black],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.value = 1})
.action_({arg b;
	case
	{b.value== 1} {(3+(oct*12)).postln}
	{b.value == 0} {};
});
b4.front;

b5 = Button.new(w,Rect(70,300,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.value = 1})
.action_({arg b;
	case
	{b.value== 1} {(4+(oct*12)).postln}
	{b.value == 0} {};
});

b6 = Button.new(w,Rect(100,300,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.value = 1})
.action_({arg b;
	case
	{b.value== 1} {(5+(oct*12)).postln}
	{b.value == 0} {};
});

b7 = Button.new(w,Rect(119,300,22,100))
.states_([["", Color.white, Color.black],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.value = 1})
.action_({arg b;
	case
	{b.value== 1} {(3+(oct*12)).postln}
	{b.value == 0} {};
});
b7.front;

b8 = Button.new(w,Rect(130,300,30,150))
.states_([["", Color.grey, Color.white],["", Color.white, Color.grey]])
.mouseUpAction_({arg b; b.value = 1})
.action_({arg b;
	case
	{b.value== 1} {(5+(oct*12)).postln}
	{b.value == 0} {};
});


//Use computer keyboard to send commands
w.view.keyDownAction = { arg view, char, modifiers, unicode, keycode;
	//[char, modifiers, unicode, keycode].postln;
	case
	{keycode == 0} {b1.valueAction = 1}
	{keycode == 13} {b2.valueAction = 1}
	{keycode == 1} {b3.valueAction = 1}
	{keycode == 14} {b4.valueAction = 1}
	{keycode == 2} {b5.valueAction = 1}
	{keycode == 3} {b6.valueAction = 1}
	{keycode == 17} {b7.valueAction = 1}
	{keycode == 5} {b8.valueAction = 1}
	{keycode == 16} {b9.valueAction = 1}
	{keycode == 4} {b10.valueAction = 1}
	{keycode == 32} {b11.valueAction = 1}
	{keycode == 38} {b12.valueAction = 1}
	{keycode == 40} {b13.valueAction = 1};

};

w.view.keyUpAction = { arg view, char, modifiers, unicode, keycode;
	case
	{keycode == 0} {b1.valueAction = 0}
	{keycode == 13} {b2.valueAction = 0}
	{keycode == 1} {b3.valueAction = 0}
	{keycode == 14} {b4.valueAction = 0}
	{keycode == 2} {b5.valueAction = 0}
	{keycode == 3} {b6.valueAction = 0}
	{keycode == 17} {b7.valueAction = 0}
	{keycode == 5} {b8.valueAction = 0}
	{keycode == 16} {b9.valueAction = 0}
	{keycode == 4} {b10.valueAction = 0}
	{keycode == 32} {b11.valueAction = 0}
	{keycode == 38} {b12.valueAction = 0}
	{keycode == 40} {b13.valueAction = 0};

};

w.front;

w.onClose= {};

)









