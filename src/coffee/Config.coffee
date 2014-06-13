$Config =
    colors : ['noColor','white','green','red','blue','pink','orange']
    combos : ['Idle', 'Combo4', 'Combo5', 'Combo6']
    col: 8
    row: 8
    types: ["col", "row"]
    alternativeType: (type)->
        if type == "row"
            return "col"
        else
            return "row"

window.$Config = $Config


###
Suggestion
+ Segmented JPEG, to reducec loading memory requirement

###