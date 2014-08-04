{
  "variableDefault":{
    "state":"haveSentence"
  },
  "layers":{
    "flashcard":{
      "variableKeys":[
        
      ],
      "objectStates":{
        "":"res\/graphics\/flashcard\/flashcard\/fc_bg.png"
      }
    },
    "sentence":{
      "variableKeys":[
        "state"
      ],
      "objectStates":{
        "haveSentence":"res\/graphics\/flashcard\/flashcard\/fc_sentences_bg.png",
        "noSentence":"res\/graphics\/ui\/blank_cell.png"
      }
    }
  },
  "variables":{
    "state":[
      "haveSentence",
      "noSentence"
    ]
  },
  "animations":{
    "init":[
      {
        "time":0,
        "tag":"flashcard",
        "sprite":"res\/graphics\/flashcard\/flashcard\/fc_bg.png",
        "actions":{
          "x":{
            "start":0,
            "tween":"Linear"
          },
          "y":{
            "start":0,
            "tween":"Linear"
          },
          "anchorX":{
            "start":0.5,
            "tween":"Linear"
          },
          "anchorY":{
            "start":0.5,
            "tween":"Linear"
          },
          "scaleX":{
            "start":1,
            "tween":"Linear"
          },
          "scaleY":{
            "start":1,
            "tween":"Linear"
          },
          "skewX":{
            "start":0,
            "tween":"Linear"
          },
          "skewY":{
            "start":0,
            "tween":"Linear"
          },
          "rotationX":{
            "start":0,
            "tween":"Linear"
          },
          "rotationY":{
            "start":0,
            "tween":"Linear"
          },
          "rotation":{
            "start":0,
            "tween":"Linear"
          },
          "zIndex":{
            "start":1,
            "tween":"Linear"
          },
          "opacity":{
            "start":255,
            "tween":"Linear"
          },
          "r":{
            "start":255,
            "tween":"Linear"
          },
          "g":{
            "start":255,
            "tween":"Linear"
          },
          "b":{
            "start":255,
            "tween":"Linear"
          }
        },
        "objectState":{
          "state":"haveSentence"
        },
        "event":""
      },
      {
        "time":0,
        "tag":"sentence",
        "sprite":"res\/graphics\/flashcard\/flashcard\/fc_sentences_bg.png",
        "actions":{
          "x":{
            "start":-12,
            "tween":"Linear"
          },
          "y":{
            "start":-325,
            "tween":"Linear"
          },
          "anchorX":{
            "start":0.5,
            "tween":"Linear"
          },
          "anchorY":{
            "start":0.5,
            "tween":"Linear"
          },
          "scaleX":{
            "start":1,
            "tween":"Linear"
          },
          "scaleY":{
            "start":1,
            "tween":"Linear"
          },
          "skewX":{
            "start":0,
            "tween":"Linear"
          },
          "skewY":{
            "start":0,
            "tween":"Linear"
          },
          "rotationX":{
            "start":0,
            "tween":"Linear"
          },
          "rotationY":{
            "start":0,
            "tween":"Linear"
          },
          "rotation":{
            "start":0,
            "tween":"Linear"
          },
          "zIndex":{
            "start":0,
            "tween":"Linear"
          },
          "opacity":{
            "start":255,
            "tween":"Linear"
          },
          "r":{
            "start":255,
            "tween":"Linear"
          },
          "g":{
            "start":255,
            "tween":"Linear"
          },
          "b":{
            "start":255,
            "tween":"Linear"
          }
        },
        "objectState":{
          "state":"haveSentence"
        },
        "event":""
      }
    ]
  },
  "variableLock":{
    "state":true
  },
  "sounds":[
    
  ]
}