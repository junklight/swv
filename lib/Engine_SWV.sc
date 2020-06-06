
Engine_SWV : CroneEngine {
	var pg;
	var ntes;
	
	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

	alloc {
		pg = ParGroup.tail(context.xg);
		ntes = [ nil,nil,nil,nil,nil , nil , nil];
		
    SynthDef( "SWV" , { | out = 0 , freq = 300, gate=1, amp=0.7, lwr=0.0, dst=1.0 , pan = 0.0 |
	    var s = SinOsc.ar(freq);
	    var ev = EnvGen.ar(Env.asr(4.0,1.0,4.0),gate:gate,doneAction:2);
	    var fld = Fold.ar(s,lwr,dst);
	    var sig = amp * fld * ev;
	    var op = Pan2.ar( sig, pan);
	    Out.ar(out, op );
    }).add;

		this.addCommand("note_on", "iff", { arg msg;
			var nte = msg[1];
			var freq = msg[2];
			var dst = msg[3];
			if ( ntes[nte].isNil == false , { 
			  ntes[nte].set("gate",0);
			  ntes[nte] = nil;
			});
      ntes[nte] = Synth("SWV", [\out, context.out_b, \freq,freq , \dst , dst ], target:pg);
		});

    this.addCommand("note_off", "i", { arg msg;
			var nte = msg[1];
			if ( ntes[nte].isNil == false , { 
			  ntes[nte].set("gate",0);
		    ntes[nte] = nil;
		  });
		});
		
		this.addCommand("freq", "if", { arg msg;
		  var nte = msg[1];
			var freq = msg[2];
			if ( ntes[nte].isNil == false , { 
        ntes[nte].set("freq",freq);
      });
		});
		
		this.addCommand("pan", "if", { arg msg;
		  var nte = msg[1];
			var pan = msg[2];
			if ( ntes[nte].isNil == false , { 
        ntes[nte].set("pan",pan);
      });
		});
	}
}
