;=============================================================================
; ext_write_jpg
;
;=============================================================================
pro ext_write_jpg, filename, dat

 dim = size(dat, /dim)
 if(n_elements(dim) EQ 3) then dat = transpose(dat, [2,0,1])

 write_jpeg, filename, dat
end
;=============================================================================
