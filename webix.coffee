webix.ui(
  type: "line"
  height: "100%"
  rows: [
      type: "line"
      cols: [
          header : "Object"
          body   : "content 3"
          width : 300
        ,
          view   : "resizer"
        ,
          body   : "Content 4" 
        ,
          header: "Properties"
          body : 
            width : 280
            view :"form"
            elements :[
                view:"checkbox"
                id:"lock"
                value:0
                label: "Lock"
              ,
                view: "checkbox"
                id : "visible"
                value: 0
                label: "visable"
              ,
                view : "label"
                label: "Position"
              ,
                cols: [
                    label         : "X"
                    labelWidth    : 16
                    view          : "counter"
                    value         : 1
                    step          : 1
                  ,
                    label         : "Y"
                    labelWidth    : 16
                    view          : "counter"
                    value         : 1
                    step          : 1
                ]
              ,
                view : "label"
                label: "Rotation" 
              ,
                cols: [
                    label         : "X"
                    labelWidth    : 16
                    view          : "counter"
                    value         : 1
                    step          : 0.1
                  ,
                    label         : "Y"
                    labelWidth    : 16
                    view          : "counter"
                    value         : 1
                    step          : 0.1
                ]                

              ,
                view : "label"
                label: "Scale" 
              ,
                cols: [
                    label         : "X"
                    labelWidth    : 16
                    view          : "counter"
                    value         : 1
                    step          : 0.01
                  ,
                    label         : "Y"
                    labelWidth    : 16
                    view          : "counter"
                    value         : 1
                    step          : 1
                ]                

              ,
                view : "label"
                label: "Skew" 
              ,
                cols: [
                    label         : "X"
                    labelWidth    : 16
                    view          : "counter"
                    value         : 1
                    step          : 0.01
                  ,
                    label         : "Y"
                    labelWidth    : 16
                    view          : "counter"
                    value         : 1
                    step          : 1
                ]                
              ,
                view : "label"
                label: "Anchor" 
              ,
                cols: [
                    label         : "X"
                    labelWidth    : 16
                    view          : "counter"
                    value         : 0.5
                    step          : 0.1
                  ,
                    label         : "Y"
                    labelWidth    : 16
                    view          : "counter"
                    value         : 0.5
                    step          : 0.1
                ]                


            ]
      ]
    ,
      view   :  "resizer"
    ,
      header : "Timeline"
      body   : "content 5"
      height : 250
  ]
);


###
{
                view:"radio"
                id:"radio1"
                value:1
                options:[
                  {
                    id:1
                    value:"One-Way"
                  }
                  {
                    id:2
                    value:"Return"
                  }
                ]
                label:"Trip"
              }
              {
                view:"combo"
                label:"From"
                options:cities
                placeholder:"Select departure point"
              }
              {
                view:"combo"
                label:"To"
                options:cities
                placeholder:"Select destination"
              }
              {
                view:"datepicker"
                label:"Departure Date"
                value:new Date()
                format:"%d  %M %Y"
              }
              {
                view:"datepicker"
                id:"datepicker2"
                label:"Return Date"
                value:new Date()
                format:"%d  %M %Y"
                hidden:true
              }
              { 
                view:"checkbox"
                id:"flexible"
                value:0
                label: "Flexible dates"
              }
              {
                cols:[
                  {
                    view          : "label"
                    value         : "Passengers"
                    width         : 100
                  }
                  {
                    view          : "counter"
                    labelPosition : "top"
                    label         : "Adults"
                    value         : 1
                    min           : 1
                  }

                  {
                    view          : "counter"
                    labelPosition : "top"
                    label         : "Children"
                  }
                ]
              {
                height: 10
              }
              {
                view:"button"
                type:"form"
                value:"Book Now"
                inputWidth:140
                align: "center"
              }

###              
