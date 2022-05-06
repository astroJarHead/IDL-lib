; Lines to use to create and save the ASCII template
; Uncomment/Comment as needed

;deltamag_temp = ASCII_TEMPLATE('73leo.deltaMags.csv')
;save,deltamag_temp,FILENAME='deltamag_temp.sav',/VERBOSE

pro delmag_avg

; PURPOSE: read in a CSV file of delta-mags fitted for 73 Leo.
; Compute a weighted mean of the delta-mags and other analysis 
; to improve the delta-mag estimate and uncertainty. 
; And make a plot too. 

; get the template
RESTORE,'deltamag_temp.sav',/VERBOSE
; Read in the csv data
; AND REMEMBER IF YOU DORK UP THE TEMPLATE EDIT THE VARIABLES 
; IN THE TEMPLATE AND SAVE THE TEMPLATE!!!
dmag_dat = READ_ASCII('73leo.deltaMags.csv',TEMPLATE=deltamag_temp)

; Now do some basic statistics

deltamag_mom = MOMENT(dmag_dat.dmagfit2)
the_sigma = SQRT(deltamag_mom[1])

print,' '
print,'**********'
print,'Mean delta_mag_fit_2     = ', deltamag_mom[0]
print,'StdDev delta_mag_fit_2   = ', the_sigma
print,'Skewness delta_mag_fit_2 = ', deltamag_mom[2]
print,'**********'

; Determine weighted mean and error in the weighted mean 
; per Bevington & Robinson "Data Reduction ... " Equations 
; 4.17 and 4.19, respectively.

; numerator for weighted mean
num_wt_mean = TOTAL(dmag_dat.dmagfit2/(dmag_dat.dmagfitsig2^2))
denom = TOTAL(1.0/(dmag_dat.dmagfitsig2^2))

wtd_mean = num_wt_mean/denom
wtd_mean_sigma = 1.0/SQRT(denom)

print,'Weighted mean delta_mag_fit_2        = ',wtd_mean
print,'StdDev Weighted mean delta_mag_fit_2 = ',wtd_mean_sigma
print,'**********'
print,' '

; Plot the results

p1 = ERRORPLOT(dmag_dat.dmagfit2,dmag_dat.dmagfitsig2,SYMBOL='circle', $ 
             /SYM_FILLED,YTITLE='$\Delta$mag',SYM_COLOR='red',$ 
             yrange=[1,6.5], xrange=[-5,50],FONT_SIZE=12, $
              TITLE='73 Leonis NPOI 700 nm. $\Delta$mags', $ 
              XTITLE='Observation #',LINESTYLE=' ')

; Overplot a line for the weighted mean delta-mag
; Array containing x values for the line
xs=[-5.0,50.0]
; And the y values are equal to the weighted delta mag
ys = [wtd_mean,wtd_mean]

p2 = PLOT(xs,ys,':',/OVERPLOT,THICK=3,NAME='Wtd. mean $\Delta$mag')

leg = LEGEND(TARGET=p2,POSITION=[45,6.0], /DATA)

; create data fir delta-mag histogram
; set the binsize
magbin = 0.4
histo = HISTOGRAM(dmag_dat.dmagfit2,BINSIZE=magbin, LOCATIONS=xbin)

phisto = PLOT(xbin,histo,TITLE='$\Delta$mag Histogram',XRANGE=[1,6], $ 
         YTITLE='Frequency', XTITLE='$\Delta$mag ', $ 
         AXIS_STYLE=1, COLOR='blue',/STAIRSTEP,XMINOR=4)
         
; Overplot a line for the weighted mean delta-mag
; Make the arrays for plotting
dmags = ys
freqs = [0,15]

p3 = PLOT(dmags,freqs,':',/OVERPLOT,THICK=3,NAME='Wtd. mean $\Delta$mag')

leg_hist = LEGEND(TARGET=p3,POSITION=[5.8,12], /DATA)

end
