;=============================================================================
; ext_write_png
;
;=============================================================================
pro ext_write_png, filename, dat

 dim = size(dat, /dim)
 if(n_elements(dim) EQ 3) then dat = transpose(dat, [2,0,1])

 write_png, filename, dat
end
;=============================================================================
