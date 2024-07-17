// Define variables
var counter:Int = 0;
var message:String = "Hello from script";

// Define functions
function onCreate():Void {
    state.missed.text = "Misses: 0 (Script onCreate)";
    trace("onCreate function executed");
}

function onUpdate():Void {
    counter++;
    if (counter % 60 == 0) {
        trace("onUpdate function executed: " + message);
    }
}

function onBeatHit():Void {
    state.missed.text = "Misses: " + counter;
    trace("onBeatHit function executed");
}
