; An example procedure to test out numerical integration using 
; Simpson's rule

; USES:
; 
; FUNCTION theFunc
;  
; A function defined below and called within the procedure that is 
; evaluated numerically via Simpson's rule. 

;**********

FUNCTION the_Func, X

  RETURN, SQRT(1.0 + x^3)

END

;**********

PRO a_num_int

COMPILE_OPT IDL2, hidden

  ; Set the limits of integration
  
  lowLim = 0.0
  uprLim = 10.0
  maxSteps = 40
  
  ; Set up an example function
  
  ; Numerically integrate using the built-in Simpson's rule
  
  the_numIntegral = QSIMP('the_Func',lowLim,uprLim,/DOUBLE,JMAX=maxSteps)
  
  print,' '
  print,'**********'
  print,' Simpson says the integral =: ',the_numIntegral
  print,'**********'
  print,' '
  
END

