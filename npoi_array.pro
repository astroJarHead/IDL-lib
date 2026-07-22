; Author: Bob Zavala
; Naval Observatory Flagstaff Station

; Set of procedures and a function created to help illustrate 
; fundamental interferometry concepts. FIrst written during 
; summer 2026 to asssit NREIP student Maggie D'Amaro to assist 
; her in understanding interferometry principles as she worked 
; with NPOI data for binary stars observed in support of the 
; Washington Double Star program of the U. S. Naval Observatory

pro array_plot

  ; Procedure to generate a plot of the NPOI array
  ; used for high spatial resolution imaging
  
  ; Define a COMMON block
  COMMON SHARE1, rad_apert, L_ob1, L_ob2
  
  ; set the radius for the "aperture" of the 
  ; single mirror (dish)
  rad_apert = 80.0 ; meters
  
  print,'********************'
  print,' Procedure array_plot starting'
  print,' '
  print,' Plot of an example NPOI imaging aray will be created showing '
  print,' the baselines on the two output beams color coded. '
  print,' '
  print,' A plot of the synthesized aperture using these baselines '
  print,' will be created as the second plot to appear.'
  print,' '
  print,' Finally, a plot of the uv-sampling for a source at a given '
  print,' Hour angle and Declination observed with this sample array '
  print,' is created.'
  print,' '
  
  radius_str = STRMID(STRTRIM(STRING(rad_apert),1), 0, 6)
  
  print,' Example NPOI array uses an equivalent single mirror '
  print,' radius of: '+radius_str+' meters.'
  
  ; Define lines for the array arms
  ; 
  n_arm_xs = [0, -27.5]
  n_arm_ys = [0, 261.30]
  
  e_arm_xs = [0, 234.0]
  e_arm_ys = [0, -102.077]
  
  w_arm_xs = [0, -203.0]
  w_arm_ys = [0, -149.608] 
  
  ; Plot array arms
  pl_arr_narm = PLOT(n_arm_xs,n_arm_ys,"-4",FONT_NAME="Times",FONT_SIZE=16, $
       FONT_STYLE='BOLD',XTITLE='Distance (m)', YTITLE='Distance (m)',$ 
       Title='NPOI Array',XMINOR=1,YMINOR=1,XTHICK=2,YTHICK=2)
  pl_arr_earm = PLOT(e_arm_xs,e_arm_ys,"-4",/OVERPLOT)
  pl_arr_warm = PLOT(w_arm_xs,w_arm_ys,"-4",/OVERPLOT)
  
  ; Imaging station coordinates
  east_im_xs = [5.5995, 9.0577, 12.7875, 20.04, 32.8518, 52.73, 87.43, $ 
    142.10, 232.38]
  east_im_ys = [-1.7921, -3.2913, -4.9469, -8.13, -13.7441, -22.48, -37.72, $
    -61.72, -101.37]
  west_im_xs = [-1.24, -2.99, -5.35, -9.1188, -15.58, -26.79, -44.1908, $
      -74.91, -123.03, -201.70]
  west_im_ys = [-1.43, -2.72, -4.45, -7.2229, -11.97, -20.20, -32.9754, $
      -55.54, -90.88, -148.65]
  north_im_xs = [1.19, 0.94, 0.72, 0.4368, -0.13, -1.01, -2.53, $
      -4.92, -9.08, -15.62, -26.34]
  north_im_ys = [0.70, 2.91, 4.91, 7.6927, 12.65, 20.60, 34.42, $
      56.09, 93.76, 153.10, 250.28]
  
  ; Imaging station labels
  easts = ['E2', 'E3', 'E4', 'E5', 'E6', 'E7', 'E8', 'E9', 'E10']
  wests = ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7', 'W8', 'W9', 'W10']
  norths = ['N0', 'N1', 'N2', 'N3', 'N4', 'N5', 'N6', 'N7', 'N8', 'N9', 'N10']
  
  
  ; Overplot imaging station as open circles
  pl_im_e = PLOT(east_im_xs, east_im_ys, "o4", SYM_THICK=3, /OVERPLOT)
  pl_im_w = PLOT(west_im_xs, west_im_ys, "o4", SYM_THICK=3, /OVERPLOT)
  pl_im_n = PLOT(north_im_xs, north_im_ys, "o4", SYM_THICK=3, /OVERPLOT)
  
  pl_arr_narm.xrange = [-70,70]
  pl_arr_narm.yrange = [-70,70]
  
  ; Add imaging station labels
  tn = TEXT(north_im_xs+2.0, north_im_ys, norths, FONT_NAME="Times", $
    FONT_STYLE="BOLD", FONT_SIZE=11, /DATA)
  te = TEXT(east_im_xs+2.0, east_im_ys+2.0, easts, FONT_NAME="Times", $ 
    FONT_STYLE="BOLD", FONT_SIZE=11, /DATA)
  tw = TEXT(west_im_xs-5.0, west_im_ys+1.0, wests, FONT_NAME="Times", $
    FONT_STYLE="BOLD", FONT_SIZE=11, /DATA)
  
  
  ; Astrometric station coordinates
  astros_xs = [-0.4864, 16.9893, -20.3899, -0.6271]
  astros_ys = [-5.6270, -12.8964, -15.4976, 17.2126]
  ; astrometric station labels
  astros = ['AC', 'AE', 'AW', 'AN']
  
  ; Overplot astrometric station as filled squares
  pl_astros = PLOT(astros_xs, astros_ys, "s4", /SYM_FILLED, /OVERPLOT) 
  ; Add astrometric station labels
  a_xs = astros_xs + [2.0, 2.0, 2.0, 2.0]
  a_ys = astros_ys - [-1.0, 2.0, 4.0, 1.0]
  tastros = TEXT(a_xs, a_ys, astros, FONT_NAME="Times", $
    FONT_STYLE="BOLD", FONT_SIZE=11, /DATA)
  
  ; Plotting Spectrometer 1 OB1 with Blue
  ; Overplot AC-AE baseline
  bl_ac_ae_x = [astros_xs[0], astros_xs[1]]
  bl_ac_ae_y = [astros_ys[0], astros_ys[1]]
  
  pl_bl1_1 = PLOT(bl_ac_ae_x, bl_ac_ae_y, "b6-", /OVERPLOT, $
    NAME='OB1: SPEC1')
  
  ; Plotting Spectrometer 1 OB1 with Blue
  ; Overplot AE-W7 baseline
  bl_ae_w7_x = [astros_xs[1], west_im_xs[6]]
  bl_ae_w7_y = [astros_ys[1], west_im_ys[6]]
  
  pl_bl1_2 = PLOT(bl_ae_w7_x, bl_ae_w7_y, "b6-", /OVERPLOT)
  
  ; Plotting Spectrometer 1 OB1 with Blue
  ; Overplot AC-W7 baseline
  bl_ac_w7_x = [astros_xs[0], west_im_xs[6]]
  bl_ac_w7_y = [astros_ys[0], west_im_ys[6]]
  
  pl_bl1_3 = PLOT(bl_ac_w7_x, bl_ac_w7_y, "b6-", /OVERPLOT)
  
  ; Plotting Spectrometer 3 OB2 with Red  
  ; Overplot AC-E6 baseline
  bl_ac_e6_x = [astros_xs[0], east_im_xs[4]]
  bl_ac_e6_y = [astros_ys[0], east_im_ys[4]]
  
  pl_bl2_1 = PLOT(bl_ac_e6_x, bl_ac_e6_y, "r6-", /OVERPLOT, $
    NAME='OB2: SPEC3')
  
  ; Overplot AC-AW baseline
  bl_ac_aw_x = [astros_xs[0], astros_xs[2]]
  bl_ac_aw_y = [astros_ys[0], astros_ys[2]]
  
  pl_bl2_2 = PLOT(bl_ac_aw_x, bl_ac_aw_y, "r6-", /OVERPLOT)
  
  ; Overplot AW-E6 baseline
  bl_aw_e6_x = [astros_xs[2], east_im_xs[4]]
  bl_aw_e6_y = [astros_ys[2], east_im_ys[4]]
  
  pl_bl2_3 = PLOT(bl_aw_e6_x, bl_aw_e6_y, "r6-", /OVERPLOT)
  
  ; Overplot AC-W7 baseline
  bl_ac_w7_x = [astros_xs[0], west_im_xs[6]]
  bl_ac_w7_y = [astros_ys[0], west_im_ys[6]]
  
  pl_bl2_4 = PLOT(bl_ac_w7_x+0.5, bl_ac_w7_y-0.5, "r6--", /OVERPLOT)
  
  ; Overplot AW-W7 baseline
  bl_aw_w7_x = [astros_xs[2], west_im_xs[6]]
  bl_aw_w7_y = [astros_ys[2], west_im_ys[6]]
  
  pl_bl2_5 = PLOT(bl_aw_w7_x, bl_aw_w7_y, "r6-", /OVERPLOT)
  
  ; Overplot E6-W7 baseline
  bl_e6_w7_x = [east_im_xs[4], west_im_xs[6]]
  bl_e6_w7_y = [east_im_ys[4], west_im_ys[6]]
  
  pl_bl2_6 = PLOT(bl_e6_w7_x, bl_e6_w7_y, "r6-", /OVERPLOT)
  
  ; Display the plot legend
  leg = LEGEND(TARGET=[pl_bl1_1,pl_bl2_1], POSITION=[50,55], /DATA, $
    FONT_NAME='Times', FONT_STYLE="BOLD", FONT_SIZE=11, $
    SAMPLE_WIDTH=0.10, /AUTO_TEXT_COLOR)
    
  ; Coordinate differences of bl station positions
  ; OB1 Spec 1
  ; AC-AE
  L_bl1_1 = [astros_xs[1] - astros_xs[0], astros_ys[1] - astros_ys[0]]
  ; AE-W7
  L_bl1_2 = [west_im_xs[6] - astros_xs[1], west_im_ys[6] - astros_ys[1]]
  ; AC-W7
  L_bl1_3 = [west_im_xs[6] - astros_xs[0], west_im_ys[6] - astros_ys[0]]
  ; Load an array with the OB1 baseline coordiante differences (deltas)
  L_ob1 = [L_bl1_1, L_bl1_2, L_bl1_3]
  ; OB2 Spec 3
  ; AC-E6
  L_bl2_1 = [east_im_xs[4] - astros_xs[0], east_im_ys[4] - astros_ys[0]]
  ; AC-AW
  L_bl2_2 = [astros_xs[2] - astros_xs[0], astros_ys[2] - astros_ys[0]]
  ; AW-E6
  L_bl2_3 = [east_im_xs[4] - astros_xs[2], east_im_ys[4] - astros_ys[2]]
  ; AC-W7
  L_bl2_4 = [west_im_xs[6] - astros_xs[0], west_im_ys[6] - astros_ys[0]]
  ; AW-W7
  L_bl2_5 = [west_im_xs[6] - astros_xs[2], west_im_ys[6] - astros_ys[2]]
  ; E6-W7
  L_bl2_6 = [west_im_xs[6] - east_im_xs[4], west_im_ys[6] - east_im_ys[4]]
  ; Load an array with the OB2 baseline coordiante differences (deltas)
  L_ob2 = [L_bl2_1, L_bl2_2, L_bl2_3, L_bl2_4, L_bl2_5, L_bl2_6]
  
  print,' '
  print,' Using procedure apert for plotting the '
  print,' synthesized aperture of the NPOI example array.'
  
  apert 
  
  plot_uv
  ; stop

  print,' Procedure array_plot completed'
  print,'********************'

end

;***************************************

pro apert 

  ; Procedure plots the synthesized aperture points sampled by 
  ; the array plotted using array_plot. Plots are made to demonstrate 
  ; how a single channel, three channels and all 16 spectral channels 
  ; of the NPOI fill in the synthesized aperture. 
  
  ; Reference common block
  COMMON SHARE1, rad_apert, L_ob1, L_ob2
  
  ; set the samples along the circumference of the "dish"
  
  edge_samp = 1000
  
  ; call function to get the array of x's and y's for the 
  ; aperture plot
  
  apert_coords = apert_array(rad_apert,edge_samp)
  
  ; Plot the aperture of the synthesized single mirror
  pl_dish = PLOT(apert_coords[*,0], apert_coords[*,1],'ko',/SYM_FILLED, $
    FONT_NAME="Times",FONT_SIZE=16,FONT_STYLE='BOLD',XTITLE='Distance (m)', $
    YTITLE='Distance (m)',Title='NPOI Synthesized Aperture Sampling', $
    XMINOR=1,YMINOR=1,XTHICK=2,YTHICK=2)
    
  ; Plot OB1 Spec 1 aperture sampling using array 'stride' 
  ; index notation
  pl_ob1 = PLOT(L_ob1[0:n_elements(L_ob1)-1:2],L_ob1[1:n_elements(L_ob1)-1:2],$
    "bX4", /OVERPLOT, NAME='OB1: SPEC1', SYM_THICK=4)
    
  ; Plot OB2 Spec 2 aperture sampling
  pl_ob2 = PLOT(L_ob2[0:n_elements(L_ob2)-1:2],L_ob2[1:n_elements(L_ob2)-1:2],$
    "r+4", /OVERPLOT, NAME='OB2: SPEC3', SYM_THICK=4)
    
  ; Display the plot legend
  leg = LEGEND(TARGET=[pl_ob1,pl_ob2], POSITION=[80,90], /DATA, $
    FONT_NAME='Times', FONT_STYLE="BOLD", FONT_SIZE=12, $
    SAMPLE_WIDTH=0.10, /AUTO_TEXT_COLOR)
    
end

;***************************************

function apert_array, radius, samples

  ; FUNCTION RETURNS A 2-D ARRAY CONTAINING X AND Y COORDINATES
  ; DEFINING A CIRCLE. THE CIRCLE REPRESENTS THE CIRCUMFERENCE OF 
  ; A SINGLE MIRROR/DISH TO PLOT FOR A SYNTHESIZED NPOI ARRAY.
  ; Function returns a 2-d array containing x and y coordinates
  ; defining a circle. The circle represents the circumference of
  ; a single mirror/dish to plot for a synthesized NPOI array.
  
  xs_ys = FLTARR(samples,2)
  for_thetas = FINDGEN(samples)
  
  ; get 0 -> 2*pi for the thetas
  
  thetas = for_thetas*2.0/samples
  ; Fill in the coordinates for the aperture circumference
  ; using the parametric equation for a circle of a given radius
  xs_ys[*,0] = radius*cos(!dpi*thetas)
  xs_ys[*,1] = radius*sin(!dpi*thetas)

  return, xs_ys

end

;***************************************

pro plot_uv

  ; Run array_plot first as this 'primes' the COMMON 
  ; variable

  COMMON SHARE1, rad_apert, L_ob1, L_ob2

  ; Create a uv-plot for the sample array in array_plot 
  ; with an aperture sampling in apert. SOurce hour angle 
  ; HA and declination DEC are set within this procedure.
  ; This uv plot DOES NOT account for the LATITUDE of the 
  ; location of the array. Z station coordinates and w 
  ; spatial frequency coordinates are ignored for simplicity. 

  hour_angl = 0.50 ; hours 
  dec = 35.0 ; degrees
  ; dec = 5.0 ; degrees
  
  ; create the wavelengths for the u-v plane sampling 
  chan_one = 700.0e-9
  chan_three = [550.0e-9,700.0e-9,850.0e-9]
  chan_16 = [561.5,572.8,584.7,597.5,611.0,625.2,665.6,673.4,691.6,$
    710.8,732.5,754.1,777.8,803.6,831.3,859.1]*1e-9
    
  ; set the wavelengths in use
  chans = chan_one
  ; count the number of channels
  num_chan = n_elements(chans)
  
  ; Create an index for filling the u and v arrays
  IF num_chan EQ 3 THEN BEGIN
    range_to_fill = INDGEN(3)
  ENDIF ELSE BEGIN
    range_to_fill = INDGEN(16)
  ENDELSE
  
  dec_str = strmid(strtrim(dec,1), 0, 5)
  ha_str = strmid(strtrim(hour_angl,1), 0, 5)
  
  print,' '
  print,' In procedure plot_uv '
  print,' '
  print,' Source hour angle (ha) = ',ha_str,' hours.'
  print,' Source declination (dec) = ',dec_str,' degrees.'
  
  ; Change ha and dec to radians
  deg2rad = !dpi/180.0
  dec_rad = dec*deg2rad
  ha_rad = hour_angl*15.0*deg2rad*cos(dec_rad)
  
  ; Create the array to convert station differences to uv coordinates
  ; with Z coordiantes and w skipped for simplicity.
  ; Select top and bottom rows for ease of array multiplication.
  to_uv = [[sin(ha_rad), cos(ha_rad)], $
           [-1.0*(sin(dec_rad))*(cos(ha_rad)), sin(dec_rad)*sin(ha_rad)]]
  top_row = to_uv[*,0]
  bottom_row = to_uv[*,1]
  ; set sizes of u and v arryas for OB1
  u_s_ob1 = FLTARR(n_elements(chans)*(n_elements(l_ob1)/2))
  v_s_ob1 = u_s_ob1
  ; set sizes of u and v arryas for OB2
  u_s_ob2 = FLTARR(n_elements(chans)*(n_elements(l_ob2)/2))
  v_s_ob2 = u_s_ob2
  

  ; OB1 loop for one spectral channel
  FOR i=0,n_elements(l_ob1)-2,2 DO BEGIN
    a_u_nochan = total(top_row*[l_ob1[i],l_ob1[i+1]])
    a_v_nochan = total(bottom_row*[l_ob1[i],l_ob1[i+1]])
    IF i EQ 0 THEN BEGIN
      u_s_ob1[i] = a_u_nochan/chan_one
      v_s_ob1[i] = a_v_nochan/chan_one
    ENDIF ELSE BEGIN
      u_s_ob1[i-(i/2)] = a_u_nochan/chan_one
      v_s_ob1[i-(i/2)] = a_v_nochan/chan_one      
    ENDELSE
  ENDFOR
  
  ; OB2 loop for one spectral channel
  FOR j=0,n_elements(l_ob2)-2,2 DO BEGIN
    a_u_nochan = total(top_row*[l_ob2[j],l_ob2[j+1]])
    a_v_nochan = total(bottom_row*[l_ob2[j],l_ob2[j+1]])
    IF j EQ 0 THEN BEGIN
      u_s_ob2[j] = a_u_nochan/chan_one
      v_s_ob2[j] = a_v_nochan/chan_one
    ENDIF ELSE BEGIN
      u_s_ob2[j-(j/2)] = a_u_nochan/chan_one
      v_s_ob2[j-(j/2)] = a_v_nochan/chan_one
    ENDELSE
  ENDFOR
               
  ; Match the u-v sampling using the Hermitian property
  u_s_ob1_2 = -1*u_s_ob1
  v_s_ob1_2 = -1*v_s_ob1
  u_s_ob2_2 = -1*u_s_ob2
  v_s_ob2_2 = -1*v_s_ob2
  
  ; Plot the u-v plane
  us_ob1 = [u_s_ob1,u_s_ob1_2]/1e06
  vs_ob1 = [v_s_ob1,v_s_ob1_2]/1e06
  us_ob2 = [u_s_ob2,u_s_ob2_2]/1e06
  vs_ob2 = [v_s_ob2,v_s_ob2_2]/1e06
  
  title_str = 'NPOI u-v plane sampling @ 700 nm !C'+$
    '$\delta$ = '+dec_str+'$\deg$ HA = '+ha_str+' Hours'
  
  pl_uv_ob1 = PLOT(us_ob1,vs_ob1,'bX',FONT_NAME="Times",FONT_SIZE=16,$
    FONT_STYLE='BOLD',XTITLE='u (M$\lambda$)', $
    YTITLE='v (M$\lambda$)',Title=title_str, $
    SYM_THICK=4,XRANGE=[-80,80],YRANGE=[-80,80],NAME='OB1: SPEC1')
  
  pl_uv_ob2 = PLOT(us_ob2,vs_ob2,'r+',SYM_THICK=4,/OVERPLOT,$ 
    NAME='OB2: SPEC3')
    
  ; Display the plot legend
  leg = LEGEND(TARGET=[pl_uv_ob1,pl_uv_ob2], POSITION=[65,65], /DATA, $
    FONT_NAME='Times', FONT_STYLE="BOLD", FONT_SIZE=12, $
    SAMPLE_WIDTH=0.10, /AUTO_TEXT_COLOR)
  
  print,' '
  print,' procedure plot_uv completed'
  print,' '
  
  ; stop

end