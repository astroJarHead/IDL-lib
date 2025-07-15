;+
; :Author: bob.zavala
;-

;**************************************************************
;
; CODE FOR USE WITH DATABASE MANAGEMENT PROJECT
; 
; During summer 2025 NREIP Intern Isaac Akiyama created a Python 
; based database management Conda environment and code ISO 
; a project. This IDL code is written to perform some verifications
; on results produced by the database analysis.
; 
;**************************************************************
;

;**************************************************************
;+
; PRO prelude
;
; Sets up the COMMON statement and a template for reading in the statistics
; files.
;
; :Examples:
;
;   NOT REQUIRED: Called within PROCEDURE biasvary
; 
; :Params: NONE
;

PRO prelude

  COMPILE_OPT IDL3

  ; COMMON block definition
  COMMON SHARED,proDir,searchPath_2021,searchPath_2025,oneImstatLine
  ; Path to the pro file
  proDir = '/mnt/nofs/projects/cameraRFI/pro/'
  ; Path to the directories where the statistics files and other 
  ; required files for the 2021 images are stored. Not necessarily the 
  ; path to the images themselves. 
  searchPath_2021 = '/mnt/nofs/projects/cameraRFI/Marana-4BV11/t13/CSC-00343/2021'
  ; Search path for the files for the 2025 images
  searchPath_2025 = '/mnt/nofs/projects/cameraRFI/Marana-4BV11/t13/CSC-00343/2025'
  
  ; Create the one line structure to hold the imstat data for
  ; PTC analysis. As this is needed it may be replicated the
  ; required number of times to accomodate the size required.
  ; ULONG = unsigned LONG integer used as those values are positive.

  oneImstatLine = {filename:' ', npix:ULONG(0), mean:0.0, median:0.0, sigma:0.0, $
    min:ULONG(0), max:ULONG(0)}


END

;**************************************************************
;+
; PRO biasvary
;
; Variations in mean bias levels in the sCMOS camera used over a span 
; of 4 years in the database code are observed. Using statistics of the
; same bias images produced from IRAF's imstatisics task this procedure
; will produce plots to try and varify the same plots seen in the database
; plots from streamlit. 
; 
;
; :Examples:
;
;   IDL> biasvary
;
; :Params: NONE
;     
;
; :Returns: Two structure containing average of biases for nights and the
; standard errors of their means suitable for plotting. 
; 
; means_2021: Structure cotaining fields as defined in FUNCTION 
;             create_menas_of_biases and called within this PROCEDURE
;             
; means_2025: Structure cotaining fields as defined in FUNCTION
;             create_menas_of_biases and called within this PROCEDURE
;
; OUTPUT
;
; Plot(s) of the mean biases versus day number:
; 
;             Using the IDL ERRORPLOT functions a plot or plots of the 
;             mean of the biases and their Standard Error of the Mean 
;             (SEM) versus calendar year three digit day number is/are 
;             created. These may be safed, modified via the IDL GUI menus. 
;             
;             Logical tests within the code set some appropriate limits 
;             for the plotting axes and decide if one or two calnedar 
;             years require plotting. 
; 
;-

PRO biasvary

  prelude

  ; Initiate COMMON block 
  COMMON SHARED
  
  ; set the path to search for statistics files
  ; 2021 files
  print,' '
  print,'**********'
  print,' Checking statistics of biases to verify database results.'
  print,' As President Reagan said, `Trust, but verify.`'
  print,'**********'
  print,' '
  
  
  statsFilesPattern = '/???/g??d???.biasstats.txt'
  ; Search for the statistics files of the bias images
  statsFiles_2021 = FILE_SEARCH(searchPath_2021+statsFilesPattern,COUNT=countStatsFiles_2021)
  statsFiles_2025 = FILE_SEARCH(searchPath_2025+statsFilesPattern,COUNT=countStatsFiles_2025)
    
  ; Report the results of the bias statistics file searches
  ; 2021
  IF countStatsFiles_2021 GT 0 THEN BEGIN
    print,' For the search path: '
    print,' '+searchPath_2021
    print,' First 2021 stats file is: ',statsfiles_2021[0]
    print,' Number of bias statistics files found: '+STRTRIM(STRING(countStatsFiles_2021),1)
    print,' '    
    ; Get the means and error for the 2021 biases
    means_2021 = create_means_of_biases(statsFiles_2021,countStatsFiles_2021)
    IF TYPENAME(means_2021) EQ 'INT' THEN BEGIN
      ; Returning an integer is an error code
      error_create_means = DIALOG_MESSAGE('create_means_biases could not get a valid year.',/ERROR)
        EXIT
    ENDIF
    print,' means_2021 = ',means_2021
  ENDIF ELSE BEGIN
    print,' For the search path: '
    print,' '+searchPath_2021    
    print,' No stats files found for 2021.'
  ENDELSE
  ; 2025
  IF countStatsFiles_2025 GT 0 THEN BEGIN
    print,' '
    print,' For the search path: '
    print,' '+searchPath_2025
    print,' First 2021 stats file is: ',statsfiles_2025[0]
    print,' Number of bias statistics files found: '+STRTRIM(STRING(countStatsFiles_2025),1)
    print,' '
    ; Get the means and error for the 2025 biases
    means_2025 = create_means_of_biases(statsFiles_2025,countStatsFiles_2025)
    IF TYPENAME(means_2025) EQ 'INT' THEN BEGIN
      ; Returning an integer is an error code
      error_create_means = DIALOG_MESSAGE('create_means_biases could not get a valid year.',/ERROR)
      EXIT
    ENDIF
    ;print,' means_2025 = ',means_2025 
    ; prep for plotting
    ymin_2025 = LONG(min(means_2025.mean))    
  ENDIF ELSE BEGIN
    print,' '
    print,' For the search path: '
    print,' '+searchPath_2025
    print,' No stats files found for 2025.'
    print,' '
    ; prep for plotting
    ymin_2025 = -100
  ENDELSE
  
  ; Prep for plotting
  xmin_2021 = min(means_2021.daynum)-2
  xmax_2021 = max(means_2021.daynum)+2
  ymin_2021 = LONG(min(means_2021.mean))
  ymax_2021 = CEIL(max(means_2021.mean))+1
  ; Check if both years require plotting
  ; stop
  IF ymin_2025 NE -100 THEN BEGIN
    ymin_2025 = LONG(min(means_2025.mean))
    ymin = min(ymin_2021,ymin_2025)
    ymax_2025 = CEIL(max(means_2025.mean))+1
    ymax = max(ymax_2021,ymax_2025)
    xmin_2025 = min(means_2025.daynum)-2
    xmax_2025 = max(means_2025.daynum)+2 
    ; Plot 2021 means of bias   
    pl_bias_2021 = ERRORPLOT(means_2021.daynum,means_2021.mean,means_2021.sigma, $
      'o',/SYM_FILLED,XRANGE = [xmin_2021,xmax_2021],YRANGE=[ymin,ymax], $ 
      FONT_SIZE=16, FONT_STYLE='Bold', FONT_NAME='Times', $ 
      XTITLE='2021 Day Number', YTITLE='Mean of Bias Images (DN)', $
      XTHICK=2, YTHICK=2, ERRORBAR_THICK=2)
    ; Plot 2025 means of biases
    pl_bias_2025 = ERRORPLOT(means_2025.daynum,means_2025.mean,means_2025.sigma, $
      'o',/SYM_FILLED,       XRANGE = [xmin_2025,xmax_2025],YRANGE=[ymin,ymax], $ 
      FONT_SIZE=16, FONT_STYLE='Bold', FONT_NAME='Times', $ 
      XTITLE='2025 Day Number', YTITLE='Mean of Bias Images (DN)', $
      XTHICK=2, YTHICK=2, ERRORBAR_THICK=2)      
  ENDIF ELSE BEGIN
    ; Only 2021 will be plotted
    ymin = ymin_2021
    ymax = ymax_2021
    ; Create plot 2021 means of biases
    pl_bias_2021 = ERRORPLOT(means_2021.daynum,means_2021.mean,means_2021.sigma, $
      'o',/SYM_FILLED, XRANGE = [xmin_2021,xmax_2021],YRANGE=[ymin,ymax],$ 
      FONT_SIZE=16, FONT_STYLE='Bold', FONT_NAME='Times', $ 
      XTITLE='2021 Day Number', YTITLE='Mean of Bias Images (DN)', $
      XTHICK=2, YTHICK=2, ERRORBAR_THICK=2)
  ENDELSE
  
  print,' '

END

;**************************************************************
;+
; FUNCTION create_means_of_biases
;
; Take a list of files containing the statistics of the biases for a
; calendar year of observations and a count of the number of files. 
; Return a structure containg the day numbers and the corresponding
; means of the bias images for that day and the standard error of the mean 
; (SEM).  
; 
; :Examples:
;
;   means_2021 = create_means_of_biases(statsFiles_2021,countStatsFiles_2021)
;
; :Params: 
; 
; INPUT
;
; filelist: ascii list of the files containing the output from IRAF's 
;           IMSTATISTICS task. Included in the filename is the path to the file
;
; filecount: integer of the number of files in filelist
; 
; OUTPUT
; 
; theBiasStats: IDL structure containing the following fields:
;               
;               daynum: Integer, a 3 digit day number
;               mean:   A float of the mean of the biases for this day number
;               sigma:  A float of the Standard Error of the Mean
; 

FUNCTION create_means_of_biases,fileList,fileCount

  COMMON SHARED

  print,' '
  print,' *** In function create_means_of_biases ***'
  print,' '
  
  ; Restore the statistics file template
  RESTORE,FILENAME=proDir+'raw.imstat.template.sav';,/VERBOSE  
  
  ; Create a strucutre to hold the menas of the biases for return
  ; from this function
  firstLine = {daynum:ULONG(0), mean:0.0, sigma:0.0}
  theBiasStats = REPLICATE(firstLine,fileCount)
;  print,' Size of theBiasStats = ',size(theBiasStats)
  ;print,theBiasStats
  ; Get the first filename and determine the calendar year
  ; stop
  firstFile = fileList[0]
  theYear = STREGEX(firstFile,'202.',/EXTRACT)
  print,' The year is: ',theYear
  ; Now we know what directory to search for the files
  CASE theYear OF
    '2021': the_file_path = searchPath_2021
    '2025': the_file_path = searchPath_2025
    ELSE: RETURN,10
  ENDCASE
  
  counter = 0
  ; Loop through the files and get the statistics
  FOREACH statsFile, fileList DO BEGIN
    ; read the file
    statData = READ_ASCII(statsFile, TEMPLATE=stat_templ)
    ; Compute the moment array
    a_bias_moment = MOMENT(statData.mean)
    ; get the day number
    theBiasStats[counter].daynum = STRMID(statsFile,16,3,/REVERSE_OFFSET)
    ; Fill remaining data into the structure
    theBiasStats[counter].mean = a_bias_moment[0]    
    theBiasStats[counter].sigma = sqrt(a_bias_moment[1])/sqrt(n_elements(statData.mean))
    counter+=1
    ;stop
  ENDFOREACH
  
  print,' '
  ;stop
  RETURN,theBiasStats
  
  
END