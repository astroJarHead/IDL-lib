pro fixWaves
  ;+
  ; :Description:
  ;    Used to reokace incorrect wavelengths data with correct numbers. 
  ; Helpful for use when an update is needed because the entries in 
  ;     
  ;    genconfig.wavelength[*,*]
  ;    
  ; do not match those measured by FTS scans. 
  ; 
  ; :How to use this procedure, you ask?
  ; 
  ;   1) Start OYSTER
  ;   2) Data -> INTERFEROMETRY 
  ;              load file that needs corrected wavelengths
  ;   3) OYSTER> .r /Path/to/This/pro/file/fixWaves
  ;   4) OYSTER> fixWaves
  ;   5) Access -> Write -> HDS
  ;              writes the corrected chameleon file to disk
  ;              the changes in genconfig.wavelength
  ;              
  ; :If you want to see that the changes took hold, print the 
  ;  wavelengths to the screen:
  ;      
  ;      OYSTER> for i=0,15 DO print,genconfig.wavelength[i,0],' ',genconfig.wavelength[i,1]
  ; 
  ; :Author: bob.zavala
  ;-

  print,'**********'
  print,' Beginnning procedure fixWaves '
  print,'**********'
  

  ; Some OYSTER common statements
  COMMON SysConfig,SystemId,Date,MetroConfig,GenConfig,GeoParms,GenInfo,GeoInfo
  COMMON ScanData,scans

  ; I may only need to fix one spectrometer. Or two. Thus I will makde to 
  ; arrays, one for each possible hybrid combiner output beam. Then I will fix 
  ; the required the number of spectrometers
  
  new_waves_ob1 = DBLARR(16)
  new_waves_ob2 = DBLARR(16)
  
  ; Make default entries for each array. For this I will use the wavelengths 
  ; needed to change the 2013-May NPOI observations of Beta Herculis from H-alpha 
  ; to Imaging and use measured results from 2013-05-19-025803Z.S1S2.30 FTS
  
  new_waves_ob1 = [8.454e-07,8.174e-07,7.907e-07,7.659e-07,7.427e-07,7.207e-07,7.017e-07, $ 
                   6.826e-07,6.649e-07,6.482e-07,6.179e-07,6.041e-07,5.910e-07,5.790e-07, $
                   5.679e-07,5.570e-07]

  new_waves_ob2 = [8.461e-07,8.180e-07,7.914e-07,7.669e-07,7.439e-07,7.221e-07,7.030e-07, $
                   6.837e-07,6.659e-07,6.489e-07,6.187e-07,6.048e-07,5.917e-07,5.796e-07, $
                   5.686e-07,5.577e-07]
                   
  new_waves = [[new_waves_ob1],[new_waves_ob2]]

  ; set the output beams to be repaired using the index numbers NOT the output 
  ; beam numbers
  fix_output_beams = [0,1]
  
  ; Select the chameleon files to fix
  ; Save this for later
  ; files_to_fix_waves = DIALOG_PICKFILE(/READ, FILTER='*.cha')
  
  ; Tell the user we are ready to fix those wavelegths
  
  print,' '
  print,' I will now fix those wavelegths.'
  print,' '
  
  ; Loop through these files
  ;FOR i=0,n_elements(files_to_fix_waves) - 1 DO BEGIN
   ;   get_data,files_to_fix_waves[i]
  
      ; Loop over the output beams for which we need to fix the wavelengths 
      FOR i=0,1 DO BEGIN
        genconfig.wavelength[*,i] = new_waves[*,i]
      ENDFOR  
  
  ;ENDFOR
  
  print,' '
  print,' Wavelengths should be fixed, for ',genconfig.date,'. Here, take a look.'
  print,' '
  print,'     Spec ',genconfig.spectrometerid[0],'           Spec ',genconfig.spectrometerid[1]
  for i=0,15 DO print,genconfig.wavelength[i,0],' ',genconfig.wavelength[i,1]
  print,' '
  
  ; Halfway there :)
  
end