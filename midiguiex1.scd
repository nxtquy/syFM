
(
s.boot;
s.options.sampleRate = 48000;
)

(
var w, knob, sound;


w= Window("testgui",Rect(100,300,300,200));

knob= Knob(w,Rect(110,50,80,80));

knob.action={'hi'.postln};

w.front;

w.onClose= {sound.free;};
)