;+
; :Author: bob.zavala
;-
pro radvel_plot

  ; Procedure to take results from a spectroscopic orbit
  ; ordered as HJD, vel and sigma_vel and overplot the
  ; expected radial velocity orbit. 

  ; Develpoed from radvel_grif.pro

  ; INPUTS: NONE

  ; REQUIRES:
  ;         Control file - *.control naming convention
  ;
  ;         Contains data required to model the system including
  ;         spectroscopic orbital elements, HD name and component
  ;         identifier, and name of file containing radial velocity data
  ;
  ;         FORMAT: ASCII text file
  ;         HD number (number only)
  ;         Component letter code e.g. A or B
  ;         Period (days)
  ;         time of periastron passage (JD)
  ;         eccentricity
  ;         argument of periastron (degrees)
  ;         K velocity amplitude (km/sec)
  ;         gamma system velocity (km/sec)
  ;         name of RV file (usually *.vel)

  ; OUTPUTS:
  ;         1) Radial velocity plot displayed on interactive GUI
  ;         2) Residual (obs. minus calc.) RV plot displayed
  ;            on interactive GUI
  ;         3) RV data saved to IDL Save file with naming format
  ;            rvdat.HD#####.A.idl.dat where ##### = the HD
  ;            number and A is the component read in from the control
  ;            file


COMPILE_OPT DEFINT32, STRICTARR, STRICTARRSUBS

; Define functiosn contained within the pro file
FORWARD_FUNCTION trueanom,my_chisqrd

; Procedure to take results from a spectroscopic orbit 
; ordered as HJD, vel and sigma_vel and overplot the 
; expected radial velocity orbit. Data plotted with 
; periastron passage at phase = 0.5.

; Open file1 called *.control as this has spectroscopic orbital elements 
; and it names the file where the RV's are kept. 

print,' '
print,'**********'
print,' Please select a *.control file for '
print,' the star of interest.'
print,' Plots for the single lined radial '
print,' velocity orbit will be created.'
print,'**********'
print,' '

; File selection GUI for user to pick a control file
file1=DIALOG_PICKFILE(FILTER='*.control')
openr, 1, file1

; Declare everything with a decimal point as double precision. 
; Avoid roundoff errors in significant digits, especially as 
; the HJD's are approximately 2^22, and roundoff errors were
; cropping up.

period=1.0D
epoch_periastron=1.0D
eccen=1.0D
w=1.0D
K=1.0D
gamrv=1.0D
file2=''
comp = ' '

READF, 1, star       ; starname (HD minus HD
READF, 1, comp       ; component letter id
READF, 1, period     ; in days
READF, 1, epoch_periastron     ; in HJD
READF, 1, eccen      ; eccentricity
READF, 1, w          ; longitude of periastron
READF, 1, K          ; semi-amplitude
READF, 1, gamrv      ; net RV of system
READF, 1, file2      ; File containing RV data
close, 1

;convert star HD number to a string, removing leading blanks

star=STRTRIM(STRING(LONG(star)),1)

; remove leading blanks from component

comp=STRTRIM(comp,1)

velcount=FILE_LINES(file2)
mu = 2*!pi/period    ; mean motion (rad/day)
w = w*!pi/180.       ; long. of periastron in radians
ecosw = eccen*cos(w) ; factor used in velocity equation

; Now create structure to hold RV data and calculated output 

rvdat = {rv, HJD:DBLARR(velcount), vel:DBLARR(velcount), $
         sigvel:DBLARR(velcount), phase:DBLARR(velcount), $ 
         t_anom:DBLARR(velcount), $
         myvel:DBLARR(velcount), myoc:DBLARR(velcount)}

; read in data

openr, 2, file2
i = 0
HJD=1.0D

while(not eof(2)) DO BEGIN
    ;print,'Will read in velocity data line ',STRTRIM(STRING(i+1),1)
    READF, 2, HJD, vel, sigvel
    rvdat.HJD[i] = HJD
    rvdat.vel[i] = vel
    rvdat.sigvel[i] = sigvel;*sqrt(5)
;    rvdat.phase[i] = abs((HJD - epoch) MOD period)/period
;    Above line commented out so that my radvel phase 
;    is defined the same way as Christian defines it in OYSTER
;    MOD returns remainder, thus phase goes from 0->just under 1.0
;    and we'll test for negatives later.
    rvdat.phase[i] = (HJD - epoch_periastron)/period MOD 1
    i = i + 1 
;    stop
endwhile
close, 2

print,'I will examine the star HD ',star
print,'Read in ',STRTRIM(STRING(i),2),' lines from the RV data file ',file2
;stop

; Now check for negative phases the same way Christian does in pro
; plotvel in plot.pro

index = where(rvdat.phase lt 0,count)
IF count GT 0 THEN rvdat.phase[index] = rvdat.phase[index]+1  

; For every epoch compute true anomaly, and using that get a predicted
; velocity. See Heintz, Double Stars, pp. 34-35 and 80

FOR j = 0, velcount-1 DO BEGIN
    tanom = trueanom(rvdat.HJD[j],mu,eccen,epoch_periastron,period)
    myvel = gamrv + K*(ecosw + cos(tanom + w))
    rvdat.myvel[j] = myvel
    rvdat.t_anom[j] = tanom
    rvdat.myoc[j] = rvdat.vel[j] - myvel
ENDFOR

; plot results

; First, loop to fill a high time resolution array with the 
; theoretical velocity values.

theovel = {theo, epoch:DBLARR(1500), phase:DBLARR(1500), $
           vel:DBLARR(1500)}

; set a step size to increment the epoch by. Use 1/1500 of 
; the 1.2 times the period

step_size = (period + 0.2*period)/1500.

start_HJD = epoch_periastron - period - 0.1*period

FOR m=0,1499 DO BEGIN
   theovel.epoch[m] = start_HJD+m*step_size
   theovel.phase[m] = (theovel.epoch[m] - epoch_periastron)/period + 1
   tanom = trueanom(theovel.epoch[m],mu,eccen,epoch_periastron,period)
   theovel.vel[m] = gamrv + K*(ecosw + cos(tanom + w))
ENDFOR

; check for negative phases in theoretical curve

;theo_index = where(theovel.phase LT 0,count)

;IF count GT 0 THEN theovel.phase[theo_index] = 
;  theovel.phase[theo_index] + 1

; set up vector to oplot gamma velocity
xphase=[-0.2,1.2]
gamma_line=0*xphase+gamrv

fase=rvdat.phase - fix(rvdat.phase)

; Plot the RV's 
rv_yrange=[FLOOR(MIN(theovel.vel)-max(rvdat.sigvel)), $ 
  ceil(MAX(theovel.vel)+max(rvdat.sigvel))]
rv_yrange=[28,46] ; tau pup
pl_rv = ERRORPLOT(fase, rvdat.vel, rvdat.sigvel,'*', FONT_NAME='Times', $
        FONT_SIZE=14, FONT_STYLE='Bold',xrange=[-0.05,1.05],yrange=rv_yrange, $ 
        xtitle='Orbital Phase', ytitle='Radial Velocity (km/sec)', $ 
        title='HD'+star+' '+comp+' RV''s and model', SYM_SIZE=2.0, $ 
        SYM_THICK=2.0,ERRORBAR_THICK=3.0,NAME='S$-$J')
; overplot the system velocity
p_gam = PLOT(xphase,gamma_line,'--',THICK=3.0,NAME='$\gamma$',/OVERPLOT)
; overplot the orbit model
p_mod = PLOT(theovel.phase, theovel.vel,'-r',THICK=3.0,NAME='Model',/OVERPLOT)

; plot the residuals
resid_yrange = [floor(min(rvdat.myoc)-max(rvdat.sigvel)), $ 
  ceil(max(rvdat.myoc)+max(rvdat.sigvel))]
resid_yrange=[resid_yrange[0]-3.0,resid_yrange[1]+3.0]

pl_resid = ERRORPLOT(fase, rvdat.myoc,rvdat.sigvel,'*', FONT_NAME='Times', $
    FONT_SIZE=14, FONT_STYLE='Bold',xrange=[-0.05,1.05], $ 
    yrange=[resid_yrange[0]-2,resid_yrange[1]+2], xtitle='Orbital Phase', $ 
    ytitle='Radial Velocity (km/sec)', title='HD'+star+' '+comp+' residuals', $ 
    SYM_SIZE=2.0,SYM_THICK=2.0,ERRORBAR_THICK=3.0,NAME='O$-$C')
    
; Get the chi-squared and the reduced chi-squared
the_chisqrd = my_chisqrd(rvdat.myoc, rvdat.sigvel)
; Six (6) elements are fit for a single lined orbit, so there
; are (number of data points) - 6 degrees of freedom
reduced_chisqrd = the_chisqrd/(n_elements(rvdat.myoc) - 6)

; What is the stddev of the O-C residuals?
sigma_resid = STDDEV(rvdat.myoc)

; Show the reduced chi-squared on the residual plot
chisq_str = STRTRIM(STRING(reduced_chisqrd,FORMAT='(F6.3)'),1)
resid_sig_str = STRTRIM(STRING(sigma_resid,FORMAT='(F6.3)'),1)
t1 = TEXT(0.2, 5.0, '$\chi^{2}_{\nu} = $'+chisq_str, FONT_STYLE='Bold', $ 
         FONT_SIZE=12, FONT_NAME='Times',/DATA)
tsig = TEXT(0.2, 4.0, '$\sigma = $'+resid_sig_str+' km/sec', $
           FONT_STYLE='Bold', FONT_SIZE=12, FONT_NAME='Times',/DATA)

save,rvdat,filename='rvdat.HD'+star+'.'+comp+'.idl.dat'
print,'**********'
print,'radvel complete. Plots and data saved.'
print,' '

stop

end

;--------------------------------------------------------

function trueanom,HJD,mu,eccen,epoch_periastron,period

; Function calculates true anomaly using iterative solution 
; detailed in Heintz reference above. 

; using modulus of period to avoid mean anomalies > 2pi

meananom = mu*((HJD - epoch_periastron) MOD period)

; initial guess for eccentric anomaly

ee0 = meananom + eccen*sin(meananom) + (eccen*eccen/2)*sin(2*meananom)

; I hope differences in mean and eccentric anomalies will never exceed
; 10 radians

testdiff = 10.0

while (testdiff GT 0.001) DO BEGIN
    mzero = ee0 - eccen*sin(ee0)
    eone = ee0 + (meananom - mzero)/(1 - eccen*cos(ee0))
    testdiff = abs(eone - ee0)
    ee0 = eone
endwhile

; solution converged, eccentric anomaly = eone

e_anom = eone

trueanom = 2*atan(tan(e_anom/2)*sqrt((1+eccen)/(1-eccen)))

return, trueanom

end

;--------------------------------------------------------

function my_chisqrd, residuals, sigmas

; Given the residuals of (data - model) and the uncertaintities 
; of the data (sigmas) determine the chi-squared and return that 
; when called

  numerator = residuals^2
  denominator = sigmas^2
  the_ratio = numerator/denominator
  ; chi-squared = the sum of the vector the_ratio
  return,TOTAL(the_ratio)

end

;--------------------------------------------------------

pro get_sj

; Uses external procedure writecol

; Read in an ASCII CSV file of velocities from Spencer-Jones 
; MNRAS Vol. 88 pg 644. Converted to CSV via genai.mil 
; and saved to a .vel file

; Check for a MNRAS Spencer-Jones file reading template. If template
; is not found, create a template

  mnras_templ = 'templ_sj.sav'

  ; Search for a saved template 
  templ_result = FILE_SEARCH(mnras_templ, COUNT=mnras_templ_count)

  ; Did we find a saved template file?
  IF mnras_templ_count EQ 0 THEN BEGIN
    ; No -- create a template
    print,' '
    print,'**********'
    print,' NO ASCII TEMPLATE FOUND!
    print,' WE NEED TO CEATE ONE NOW. '
    print,' Use the file selection GUI to pick a'
    print,' mnras csv file and create a TEMPLATE'
    print,'**********'
    print,' '        
    templ_mnras = ASCII_TEMPLATE()
    ; If the user closes ASCII_TEMPLATE without saving a 
    ; TEMPLATE do not SAVE the empty template
    size_templ = size(templ_mnras)
    IF size_templ[0] NE 0 THEN BEGIN
      ; user saved a useful template file
      SAVE, templ_mnras, FILENAME=mnras_templ,/VERBOSE
    ENDIF ELSE BEGIN
      ; remind user that a template was not saved
      print,'**********'
      print,'NO ASCII TEMPLATE SAVED'
      print,'**********'
    ENDELSE
  ENDIF ELSE BEGIN
    ; We found a saved template file
    ; Restore the saved template
    print,' '
    print,'**********'
    print,'A TEMPLATE EXISTS FOR READING THE SPENCER-JONES '
    print,'MNRAS RADIAL VELOCITIES: '
    print,' TEMPLATE FILENAME: ',mnras_templ
    print,' RESTORING THAT FILE NOW'
    print,'**********'
    print,' '
    RESTORE, FILENAME=mnras_templ,/VERBOSE
  ENDELSE

  ; Read in a Spencer-Jones MNRAS table of velocities and 
  ; save these data to a *.vel file 
  print,' '
  print,'**********'
  print,' Use the file selection GUI to select the  '
  print,' desired sj csv file to read in.'
  print,'**********'
  print,' '

  mnras_vel = READ_ASCII(TEMPLATE=templ_mnras)
  ; convert table JD -> JD
  jds = mnras_vel.jd + 2400000.0d
  ; Assume sigma of velocities = +/- 4.0 km/sec
  ; I did determine that 1.47 is good. Use 1.5
  sig_vel = MAKE_ARRAY(n_elements(mnras_vel.OBS_VEL),VALUE=1.5)
  
  ; write out the .vel file
  ; Get the common star name for the velocity file name
  star_name = ''
  print,' '
  READ, star_name, PROMPT='Enter star name for .vel file: '
  vel_file = star_name+'.sj.a.vel' ; assumes primary velocities
  OPENW, unit, vel_file, /GET_LUN
  WRITECOL, vel_file, jds, mnras_vel.obs_vel, sig_vel, FMT = '(F10.2,1x,F5.1,1x,F3.1)'
  CLOSE, unit, /ALL

  print,' '
  print,'**********'
  print,' Radial velocity file '+vel_file,' saved '
  print,' Ready for use with procedure radvel '
  print,'**********'
  print,' '   

END

;--------------------------------------------------------

pro get_harps

; Uses external procedure writecol

; Read in high precision HARPS radial velocities from a csv file.
; Convert the velocities and sigmas frmo m/sec -> km/sec and the 
; Modified Barycentric JD's -> BJD. Write these out to the 
; usual .vel file.

  harps_templ_file = 'templ_harps.sav'

  print,' '
  print,'**********'
  print,' Restoring the ASCII template file for reading '
  print,' the high precision HARPS RV data.'
  print,'**********'
  print,' '    
  RESTORE,filename=harps_templ_file,/VERBOSE
 
  ; Read in and convert the required data
  print,' '
  print,'**********'
  print,' Use the file selection GUI to select the  '
  print,' desired harps csv file to read in.'
  print,'**********'
  print,' '
  
  READ, gamma_vel, PROMPT='Enter star''s radial velocity (km/sec): ' 
  
  harps_rvdat = READ_ASCII(TEMPLATE=templ_harps)
  ; convert table MBJD -> BJD
  bjds = harps_rvdat.mbjd + 2400000.5d
  ; convert velocities and sigmas -> km/sec
  vels = harps_rvdat.rad_vel/1000.0 + gamma_vel
  sigmas = harps_rvdat.sig_vel/1000.0

  ; write out the .vel file
  ; Get the common star name for the velocity file name
  star_name = ''
  print,' '
  READ, star_name, PROMPT='Enter star name for .vel file: '
  vel_file = star_name+'.harps.a.vel' ; assumes primary velocities
  OPENW, unit, vel_file, /GET_LUN
  WRITECOL, vel_file, bjds, vels, sigmas, FMT = '(F13.5,1x,F12.6,1x,F9.6)'
  CLOSE, unit, /ALL

  print,' '
  print,'**********'
  print,' Radial velocity file '+vel_file,' saved '
  print,' Ready for use with procedure radvel '
  print,'**********'
  print,' '


end

