;**********
; Read in an ephemeris for Jupiter and compute LST and HA for NOFS to determine 
; observability 
;**********

;**********
;
; Uses ct2lst.pro in idlastro
; if Preferences are set perhaps via the GUI
; for IDLDE IDL -> Preferences the path to idlastro 
; will be found and the code compiled
;
;**********

;**********
;
; Uses an ephemeris file computed from:
; https://pds-rings.seti.org/tools/ephem3_jup.shtml
;
;**********

PRO obs_lst_ha

  ; 

  COMPILE_OPT IDL2, hidden

  ; We will need the NOFS east Longitude in degrees
  
  nofs_e_long = -111.738281

  ; prepare ASCII template to read the data
  
  ephem_file = 'pds-rings.seti.org_work_viewer3_jup_Ephem.tab.txt'

  templ_file = 'ephem.templ.sav'

  IF ~FILE_TEST(templ_file) THEN BEGIN

      templ = ASCII_TEMPLATE(ephem_file)
    
      SAVE, templ, filename=templ_file, /VERBOSE
      
  ENDIF ELSE BEGIN
    
      print,' '
      print,' I already have a template for reading the ephemeris file.'
      print,' CONTINUING'
      print,' '
      
  ENDELSE

  ; Read the data

  restore,filename = templ_file

  ephem_dat = READ_ASCII(ephem_file,TEMPLATE=templ)
  
  print,' '
  print,' I read in the ephemeris file data.'
  print,' '

  ; Add useful columns to the structure that was read in 
  
  ; LST is postive so use unsigned 
  ; LST hours
  
  lst_hrs = ULONARR(n_elements(ephem_dat.mjd))
  
  ; LST min
  
  lst_min = ULONARR(n_elements(ephem_dat.mjd))

  ; Hour Angle hour and minutes are signed
  
  ha_hr = LONARR(n_elements(ephem_dat.mjd))
  
  ; Hour angle minute
  
  ha_min = LONARR(n_elements(ephem_dat.mjd))
  
  ; And add the deciaml hour angle
  
  ha_dec = FLTARR(n_elements(ephem_dat.mjd))
  
  ; Now concatenate these onto the ephem_dat structure and 
  ; save it with a new name
  
  ephem_lh_dat = CREATE_STRUCT(ephem_dat, 'LST_HR', lst_hrs, 'LST_MIN', lst_min, $ 
                 'HA_HR', ha_hr, 'HA_MIN', ha_min, 'HA_DEC', ha_dec)
  
  ; Now we'll get the MJD's, convert to JD, compute the LST's and insert those into 
  ; the structures 
  
  ; Get the JD's
  
  the_jds = ephem_lh_dat.mjd + 2400000.5
  ; Next one needed for a place holder for input to ct2lst
  the_dummy = FLTARR(n_elements(ephem_dat.mjd))
  ; prepare an array to receive the decimal LST's
  lst_dec_hr = FLTARR(n_elements(ephem_dat.mjd))
  
  ct2lst, lst_dec_hr, nofs_e_long, the_dummy, the_jds
  
  ;And the old HA = LST - RA
  ha_dec = lst_dec_hr - ephem_lh_dat.PLANET_RA
  
  ; If the HA > 12 the we're EAST of the meridian
  
  big_ha = WHERE(ha_dec GE 12.0)
  ha_dec[big_ha] = -1.0*(24.0 - ha_dec[big_ha])  
  
  ; Fill in the remaining fields 
  
  ephem_lh_dat.ha_dec   =  ha_dec
  ephem_lh_dat.ha_hr    =  FIX(ha_dec)
  ephem_lh_dat.ha_min   =  (ha_dec - FIX(ha_dec))*60.0
  ephem_lh_dat.lst_hr   =  FIX(lst_dec_hr)
  ephem_lh_dat.lst_min  =  (lst_dec_hr - FIX(lst_dec_hr))*60.0
  
  ; Now save all this hard work
  
  out_ephem_file = 'Jup_lst_ha-Nov-23-May-24.sav'
  
  SAVE, FILENAME=out_ephem_file, /VERBOSE
  
END 
