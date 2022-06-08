;AthenaSenior
; The Business Investor Model Source Code

; I examined the results as slow mode (Like 30%) Normal mode is very fast so it's hard to observe.

;----------------------------------------------------------------------------------

;This model can be thought of as approximately representing people who buy and operate local businesses:
;it assumes investors are familiar with businesses they could buy within a limited range of their own experience.
;The investment “environment” assumes that there is no cost of entering or switching businesses
;(e.g., as if capital to buy a business is borrowed and the repayment is included in the annual profit calculation),
;that high profits are rarer than low profits, and that risk of failure is unrelated to profit.
;We can use the model to address questions such as how the average wealth of the investors,
;and how evenly wealth is distributed among individuals, depends on how much information the investors can sense.

;The entities in this model are investors
;and business alternatives that vary in profit and risk.

; Turtles: investors, Patches (in landscape): Business Alternatives


; -- First Step: Implement global variables and turtles' attributes.
globals [
  landscape ; Landscape (grid of businesses)
  out-of-landscape ; Outside of landscape (Blue part)
  labelpatch ; For optional label
  number-of-failed-investors ; A sum variable to count the investors whose failed at least once
]

turtles-own
; The investors have state variables for their location in the space and for
; their current wealth (W, in money units).
[
  failed? ; A boolean variable to decide the investors whose failed at least once
  current-location
  current-wealth ; Current wealth for each agent, it will be initialized by 0
  number-of-patches-used ; To report number of patches used by each agent
]

patches-own ; The landscape is a grid of business patches, each of which has two static variables: the annual net profit
; that a business there would provide (P, in money units such as dollars per year)
; and the annual risk of that business failing and its investor losing all its wealth (F, as probability per year).
[
  annual-net-profit ; P
  utilityOfPatch ; Return value of utility() will be stored in this for each patch
  annual-fail-risk-probability ; F
]


to setup
  clear-all
  set-default-shape turtles "person" ; Creating turtles - Investors, whose are humans.

;  This landscape is n × n patches (a parameter of the model set using the UI) in size with no wrapping at its edges.

; Building landscape with n x n patches -- n Will be given by user.



  let counter -16
  let counter2 16
  let edges nxn-patches

  repeat edges - 1 [
    ask patch counter counter2
    [
      set pcolor one-of remove blue base-colors
    ]
    set counter2 counter2 - 1
  ]

  set counter -16
  set counter2 16


  repeat edges - 1 [
    ask patch counter counter2
    [
    set pcolor one-of remove blue base-colors
    ]
    set counter counter + 1
  ]

  repeat edges - 1[
    ask patch counter counter2
    [
    set pcolor one-of remove blue base-colors
    ]
    set counter2 counter2 - 1
  ]

  ask patch (0.9 * max-pxcor) (-0.9 * max-pycor) [
    set labelpatch self
    set plabel-color white
  ]

  set out-of-landscape patches with [pcolor != one-of remove blue base-colors]
  ask out-of-landscape [ set pcolor blue]


  set landscape patches with [pcolor = blue and pxcor < counter + 1 and pycor > counter2]
  ask landscape [set pcolor one-of remove blue base-colors]

repeat edges [
    ask patch counter counter2
    [
    set pcolor one-of remove blue base-colors
    ]
    set counter counter - 1
  ]

  ;; Landscape build.

  ;A number of investor agents (a parameter of the model set using the UI) are initialized and put in random patches,
  ; but investors cannot be placed in a patch already occupied by another investor.
  ; Their wealth state variable W is initialized to zero.


    ;; Creating Investors.. Number of investors will be given by user.
  ;; Of course investors will be take action inside landscape.

 ifelse edges * edges < number-of-investors
    [show "ERROR: Please give valid inputs. Number of investors must be less than number of existing patches in landscape."]
  ; If landscape's area has not enough capacity to investors, then investors won't come to the landscape


  [ ; Else
     create-turtles number-of-investors [
    set color white
    set current-wealth 0 ; Initial wealth of each agent is between 0
    set number-of-patches-used 1 ; They use their initial business firstly
    ifelse nxn-patches = 1
    [move-to patch -16 16] ; If there is only 1 patch in landscape (1x1 input) , then our only investor initialized on the default
      ;location: -16,16.
    [
    move-to one-of landscape ; Initial locations are randomly created.
    ]
    while [any? other turtles-here] [
    move-to one-of landscape ; Initial locations are randomly created.
    ]
    ]
    ]


  ask patches with [pcolor != blue] ; The business patches inside landscape
  [
  set annual-net-profit random-exponential mean-value
; The values of P are drawn from an exponential distribution
    ;(use random-exponential function in NetLogo.
    ;Mean of distribution is a parameter of the model set using the UI),
    ;which produces many patches with low profits and a few patches with high profits.

  set annual-fail-risk-probability (0.01 + (random-float 0.09))
   ;  F is drawn randomly from a uniform real number distribution with a minimum of 0.01 and a maximum of 0.1
  ]


  ask labelpatch [ set plabel "The Business Investor Model" ] ; Optional label
 ;  ;; start the clock
  reset-ticks
end

to Start
  ; In each step, turtles will check their eight neighbors, if they are at edges, they check
  ; less neighbors. They check the patches that if not any investor at there,
  ; and not blue(not out of landscape)

  ask turtles [
    ;The investors decide whether any similar business (adjacent patch) offers a better tradeoff of profit and risk;
    ;if so, they “reposition” and transfer their investment to that patch, by moving there.
    ;g. An investor identifies all the businesses that it could invest in: any of the neighboring eight
    ;(or fewer if on the edge of the space) patches that are unoccupied, plus its current patch.
    ;The investor then determines which of these alternatives provides the highest value of the utility function (see below),
    ;and moves (or stays) there. Only one investor can occupy a patch at a time.
    ; The agents execute this repositioning action in randomized order.

    ; U = (W + TP)*(1 – F)^T


   let w current-wealth

    ask patch-here [
    set utilityOfPatch utility w ; Call the function utility() with parameter w(current wealth of each turtle)
      ; Set current patch's utility with the returned value of utility function - Its utilityOfPatch depends on its P and F directly
    ]

   ask neighbors [
      set utilityOfPatch utility w ; Call the function utility() with parameter w(current wealth of each turtle)
      ; Set all neighbors' utilities with the returned value of utility function - Their utilityOfPatch depends on their P and F directly
      ]


    ;; These commented parts are for test -- To verify if agent really chooses the highest utility business.
    ;; TEST With 1 investor - 4x4 Patch
    ;; He moves to his neighbor patch with greatest utility.
    ;; If the greatest utility in neighbors is still less than current patch's utility, then investor STAYS.

     ;  ask neighbors with [pcolor != blue] [
      ; show int utilityOfPatch
  ; ]
 ;ask patch-here[
 ; show int utilityOfPatch
 ;  ] ;
   ; show max-one-of neighbors [utilityOfPatch]

    ; Gives us each agent's highest-utility neighbor patch.

    ; Test end -----------------

    ;; Cont.

    let next-patch max-one-of neighbors [utilityOfPatch] ; The turtle will go to the next patch

    carefully[ ; Try-catch

      if ([pcolor] of next-patch != blue) and
      ([any? other turtles-here] of next-patch = false) and
      ([utilityOfPatch] of next-patch > [utilityOfPatch] of patch-here)

      [move-to max-one-of neighbors [utilityOfPatch]
        set number-of-patches-used number-of-patches-used + 1]

      ;If next-patch is not occupied by another investor, and if it's not blue(not outside of landscape),
      ; and utilityOfPatch of nextpatch is bigger than the current one, than investor moves to the new business.

    ]


    [
      show error-message
      ; Handle possible errors
    ]

    ; Business fails or not?
    ; This operation is executing with if-else
    ; If a uniform random number between zero and one is less than F,
    ; then the business fails: the investor’s W is set to zero,
    ; but the investor stays in the model and continues to behave in the same way.

    ifelse (random-float 1 < annual-fail-risk-probability)[
      set current-wealth 0 ; ; If a uniform random number between zero and one is less than F,
    ; then the business fails: the investor’s W is set to zero,
     ; show "'s business failed. But he will act like the same way. His wealth is now 0."
      ; Show the turtles with failed, alerts the user in each tick's failed investors

      set failed? true ; To show the number of failed investors, we collect the failed? = true ones.
    ]
    [set current-wealth current-wealth + annual-net-profit ; If a uniform random number between zero and one is equal or bigger than F,
      ; then business not fail and the investors update their wealth state variable.
     ;  W is set equal to the previous wealth plus the profit of the agent’s current patch.
   ]
  ]

  ;ask turtles [
   ; show current-wealth ;- This command shows each investor's wealth at each tick.
  ;]


  set number-of-failed-investors count turtles with [failed? = true] ; This one is for monitor.
  ;Reports us the number of investors failed at least once

  if ticks = simulation-run-for[
    ;show "Simulation ended. Turtles used the number of patches following: "
    ;ask turtles[
    ;show number-of-patches-used
    ;]
  stop
  ] ; The model time step is 1 year, and simulations run for given number of years
 ; (a parameter of the model set using the UI).

tick
end

; ########## UTILITY FUNCTION
; U = (W + TP) * (1 – F)^T

to-report utility [w] ; ( Parameter is wealth of investor )
  report (w + (annual-net-profit * t)) * ((1 - annual-fail-risk-probability) ^ T)
end
@#$#@#$#@
GRAPHICS-WINDOW
215
10
719
515
-1
-1
15.030303030303031
1
15
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

SLIDER
12
13
204
46
nxn-patches
nxn-patches
1
33
19.0
1
1
x
HORIZONTAL

SLIDER
9
195
197
228
simulation-run-for
simulation-run-for
0
75
75.0
1
1
years
HORIZONTAL

BUTTON
14
255
102
331
Setup Model
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
110
255
199
332
NIL
Start
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
18
104
190
137
number-of-investors
number-of-investors
0
30
25.0
1
1
NIL
HORIZONTAL

SLIDER
19
61
191
94
mean-value
mean-value
0
10000
5000.0
50
1
NIL
HORIZONTAL

SLIDER
15
152
192
185
T
T
1
40
5.0
1
1
NIL
HORIZONTAL

MONITOR
725
10
914
55
Failed Investors 
number-of-failed-investors
17
1
11

TEXTBOX
168
230
318
273
Inputs
15
0.0
1

PLOT
723
262
916
382
Standard Deviation
Time
Std.
0.0
50.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot standard-deviation [current-wealth] of turtles"

MONITOR
732
209
907
254
Average Investor Wealth as num
mean [current-wealth] of turtles
17
1
11

MONITOR
742
390
899
435
Standard Deviation as num
standard-deviation [current-wealth] of turtles
17
1
11

PLOT
11
350
202
470
Average Profit
Time
AvgProfit
0.0
50.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [annual-net-profit] of patches with [any? turtles-here]"

PLOT
726
68
912
202
Average Investor Wealth
Time
AvgWealth
0.0
50.0
0.0
1000.0
true
false
"" ""
PENS
"default" 1.0 0 -14439633 true "" "plot mean [current-wealth] of turtles"

MONITOR
742
462
900
507
AverageProfit as num
mean [annual-net-profit] of patches with [any? turtles-here]
17
1
11

TEXTBOX
790
439
940
482
Outputs
15
0.0
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
