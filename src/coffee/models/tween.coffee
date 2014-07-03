kiss.Tween =
  liner : (p)->
    p

  swing : (p)->
    0.5 - Math.cos( p * Math.PI ) / 2

tweenBase =
  sine : (p)->
    1 - Math.cos( p * Math.PI / 2 );

  circ : (p) ->
    1 - Math.sqrt( 1 - p * p )

  elastic : (p) ->
    if p == 0 or p == 1
      p
    else
      -Math.pow( 2, 8 * (p - 1) ) * Math.sin( ( (p - 1) * 80 - 7.5 ) * Math.PI / 15 );
  back : (p)->
    p * p * ( 3 * p - 2 );

  bounce: (p)->
    pow2 = 16
    bounce = 4

    while  p <  (pow2 - 1) / 11 
      pow2 = Math.pow( 2, --bounce )

    1 / Math.pow( 4, 3 - bounce ) - 7.5625 * Math.pow( ( pow2 * 3 - 2 ) / 22 - p, 2 );

for name, index in [ "quad", "cubic", "quart", "quint", "expo" ]
  do (name, index) ->
    tweenBase[ name ] = ( p ) ->
      Math.pow( p, index + 2 );

for name, method of tweenBase
  do (name, method) ->
    kiss.Tween[ name + "In" ] = method

    kiss.Tween[ name + "Out" ] = ( p ) ->
      1 - method( 1 - p );

    kiss.Tween[ name + "InOut" ] = ( p ) ->
      if p < 0.5
        method( p * 2 ) / 2
      else
        1 - method( p * -2 + 2 ) / 2

