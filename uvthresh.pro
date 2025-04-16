
pro uvthresh

; Procedure for evaluating UV threshold exposure for Optics 
; Lab ORM and SOP

; Read in UV threshold data if needed

CD, CURRENT=this_path ; & print,'We are working in this path: '+this_path

thresh_dat = 'UV-TLV.txt'
uv_tlv_dat_here = FILE_TEST(this_path+'/'+thresh_dat)

; Report that the UV threshold data file is not here, or read it in
IF NOT uv_tlv_dat_here THEN BEGIN
    ; print,'In the NOT part of the IF loop'
    msg_text = 'UV Threshold Data File not found'
    uv_thresh_dat_err = DIALOG_MESSAGE(msg_text, /CENTER, /ERROR, $ 
                      TITLE='FILE NOT FOUND')
    RETURN
ENDIF ELSE BEGIN
    print,' File '+thresh_dat,' exists. I will read it in. '
      ; read in the file using saved template the_templ.sav
      RESTORE,FILENAME='the_templ.sav',/VERBOSE
      tlv_data = READ_ASCII(thresh_dat, TEMPLATE=the_templ, COUNT=dat_count)
      print,'********************'
      print,' File '+thresh_dat+' read in and available for use. '
      print,'********************'
      print,' '
ENDELSE

; An interpolation of the TLV's is needed for every 1 nanometer
; The input TLV's aer on a slightly irregular grid but INTERPOL 
; is able ot handle this situation.
; Make an array of x values from 200-400 nanometers
uv_xs = INDGEN(201,START=200)
; Do the interpolations
new_tlvs = INTERPOL(tlv_data.tlv,tlv_data.lam,uv_xs)
new_rel_spec_eff = INTERPOL(tlv_data.rel_spec_eff,tlv_data.lam,uv_xs)
; test plot of TLV

;plt_tlv = PLOT(tlv_data.lam,tlv_data.tlv, YLOG=1, XRANGE=[190,410], $
plt_tlv = PLOT(uv_xs,new_tlvs, YLOG=1, XRANGE=[190,410], $
YRANGE=[10.0,1.2e06], THICK=3, FONT_NAME='TIMES',FONT_SIZE=14, $
FONT_STYLE='BOLD', XTITLE='$\lambda$ (nm)', $ 
YTITLE='THRESHOLD LIMIT VALUE ($J m^{-2}$ )', TITLE='UV Exposure Threshold') 

; Create data that estimates spectral irradiance of the 150 W Ozone free 
; Xenon arc lamp

; set the wavelength scale nm per mm
wave_scale = 9.2

; There are 5 segments for approximating the spectral irradiance 
; data. x-values are in nanometers, y-values are milliWatt per meter^2 
; per nm

; Segment 1
seg1_x_rng = [209.0,246.0]
seg1_y_rng = [1.0,8.0] 
del_x1 = seg1_x_rng[1] - seg1_x_rng[0]
seg1_xs = INDGEN(del_x1+1,START=seg1_x_rng[0])

the_ys_1 = the_segment(seg1_x_rng, seg1_y_rng, seg1_xs)

; Segment 2
seg2_x_rng = [247.0,296.0]
seg2_y_rng = [8.0,11.5]
del_x2 = seg2_x_rng[1] - seg2_x_rng[0]
seg2_xs = INDGEN(del_x2+1,START=seg2_x_rng[0])

the_ys_2 = the_segment(seg2_x_rng, seg2_y_rng, seg2_xs)

; Segment 3
seg3_x_rng = [297.0,386.0]
seg3_y_rng = [11.5,14.0]
del_x3 = seg3_x_rng[1] - seg3_x_rng[0]
seg3_xs = INDGEN(del_x3+1,START=seg3_x_rng[0])

the_ys_3 = the_segment(seg3_x_rng, seg3_y_rng, seg3_xs)

; Segment 4
seg4_x_rng = [387.0,395.0]
seg4_y_rng = [14.0,16.0]
del_x4 = seg4_x_rng[1] - seg4_x_rng[0]
seg4_xs = INDGEN(del_x4+1,START=seg4_x_rng[0])

the_ys_4 = the_segment(seg4_x_rng, seg4_y_rng, seg4_xs)

; Segment 5
seg5_x_rng = [396.0,400.0]
seg5_y_rng = [16.0,14.0]
del_x5 = seg5_x_rng[1] - seg5_x_rng[0]
seg5_xs = INDGEN(del_x5+1,START=seg5_x_rng[0])

the_ys_5 = the_segment(seg5_x_rng, seg5_y_rng, seg5_xs)


; Combine and Plot the segments

; Now 'stitch' together the segemets into a single irradiance 
; array

spec_irrad_ys = [the_ys_1,the_ys_2,the_ys_3,the_ys_4,the_ys_5]
spec_irrad_xs = [seg1_xs,seg2_xs,seg3_xs,seg4_xs,seg5_xs]

; Using Eqn. 1 of the Industrial Hygiene handbook 
; calculate the effective irradiance as a function of 
; wavelength and then overplot that on the spectral irradiance. 
; Integrate too, and plot Effective Irradiance and convert 
; to W/m^2 and check for limiting dose.

; Effective Spectral Irradiance = 
;      Spectral Irradiance *  Relative Spectral Effectiveness

eff_spec_irrad_vec = overlap(spec_irrad_xs,spec_irrad_ys, $
          uv_xs,new_rel_spec_eff)
          
; Pull from the returned 2-d vector the effective spectral irradiance 
; as a 1-d column vector. Jusrt personal preference here. y-values are 
; in column 1, x-values in column 0. 

eff_spec_irrad = eff_spec_irrad_vec[*,1]
         
spec_irr_txt = 'E$_{\lambda}$'
eff_spec_irrad_txt = 'E$_{Eff}$'

; Effective irradiance is te integral under the curve of the 
; effective spectral irradiance. As the bandwidths are 1 nanometer 
; in this example I can use the TOTAL function.

eff_irrad = TOTAL(eff_spec_irrad) ; mW/m^2
eff_irrad_W_per_cmsqrd = eff_irrad/1e07 ; W/cm^2


print,' '

; Estimate maximum exposure time at 0.5 meters from lamp given 
; Effective Irradiance. Dose limit is 0.003 J/cm^2

exptime_max = 0.003/eff_irrad_W_per_cmsqrd

exptime_str = STRTRIM(STRING(exptime_max),1)

print,'********************'
print,' Daily exposure in J/cm^2 is Eff. irrad. (W/cm^2)'
print,' multiplied by exposure time in seconds.'
print,' '
print,' Effective irradiance = '+STRING(eff_irrad)+' mW/m^2'
print,' Effective irradiance = '+STRING(eff_irrad_W_per_cmsqrd)+' W/cm^2'
print,' Maximum exposure time estimate at 0.5 m = '+exptime_str+' sec.'
print,'********************'

pl_spec_irr = PLOT(spec_irrad_xs,spec_irrad_ys,ylog=1,THICK=3,YRANGE=[0.5,200], $
  XRANGE=[200,420], FONT_NAME='TIMES',FONT_SIZE=14, $
  FONT_STYLE='BOLD', XTITLE='$\lambda$ (nm)', $
  YTITLE = 'IRRADIANCE AT 0.5 m (mW m$^{-2}$ nm$^{-1}$)', $
  TITLE='150 W Ozone Free Xe Arc Lamp', NAME=spec_irr_txt)
  
pl_eff_spec_irr = PLOT(spec_irrad_xs,eff_spec_irrad,'--', $
  COLOR='Red',NAME=eff_spec_irrad_txt,THICK=3,/OVERPLOT)
  
leg = LEGEND(TARGET=[pl_spec_irr,pl_eff_spec_irr], POSITION=[400,140], $
            /DATA, /AUTO_TEXT_COLOR,FONT_SIZE=14)

; stop
    
END

;***************************************************************************

FUNCTION the_segment, two_xs, two_ys, the_xs

  ; Take in pairs of x and y values and an array of input x values.
  ; Using the pairs of x and y values get a slope and y-intercept.
  ; With this inear fit create y values with the input
  ; aray of x-values and return them.

  ; INPUT PARAMETERS
  ; two_xs: the initial and final x values
  ; two_ys: the initial and final y values
  ; the_xs: an aray of x values to use for computing the y values
  ;         that will be returned

  ; RETURNS
  ; the_ys: Uses the computed slope and y-intercept
  ;         and the x-values, these are computed and returned
  ;         to the calling procedure.

  ; Conduct the linear fit. LINFIT is not used as the near perfect
  ; linear assumption produces errors when LINFIT does the statistics
  ; and the errors are distracting. 

  a_slope = (two_ys[1] - two_ys[0])/(two_xs[1] - two_xs[0])
  a_y_int = two_ys[0] -1.0*a_slope*two_xs[0]

  the_ys = a_slope*the_xs + a_y_int

  RETURN, the_ys

END

;***************************************************************************

FUNCTION overlap, x_1, y_1, x_2, y_2

  ; Using input arrays of x and y values on the same grid 
  ; that do not require interpolation, determine there 
  ; overlapping indices. Multiply the y values where these 
  ; arrays overlap and return the product y_1*y_2 where 
  ; the overlap occurs, and the correspnoding x-values
  
  ; INPUT PARAMETERS
  
  ; x_1, x_2: 1-dimensional arrays of x-values for which we 
  ;           want to determine the overlap
  ; y_1, y_2: 1-dimensional arrays of y-values to multiply together 
  ;           once the overlap is determined from the x-values
  
  ; RETURNS
  
  ; return_vec: A 2-d vector in which column 0 contains the x-values 
  ;             and column 1 contains the overlap product of y_1*y_2
  ;             A 2-d column vector is used as a function only returns 
  ;             one "value" or thing. 
  
  ; Determine overlap range
  x_min = max([min(x_1), min(x_2)])
  x_max = min([max(x_1), max(x_2)])
  
  ; Find indices of x1 and x2 that fall within the overlap
  indices1 = where((x_1 GE x_min) AND (x_1 LE x_max), count1)
  indices2 = where((x_2 GE x_min) AND (x_2 LE x_max), count2)
  
  ; Safety check
  if count1 NE count2 then message, 'Mismatch in overlapping sample count!'
  
  ; Multiply the overlapping sections
  y_product = y_1[indices1] * y_2[indices2]
  x_common = x_1[indices1]  ; or x2[indices2], they should be the same
  
  return_vec = [[x_common], [y_product]]
  
  RETURN, return_vec
  
END