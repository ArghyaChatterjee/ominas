;===========================================================================
; orb_get_lib_ap
;
;
;===========================================================================
function orb_get_lib_ap, xd, frame_bd

 nt = n_elements(xd)

 lib = bod_lib(xd)

 lib_ap = reform(lib[0,*], nt, /over) 

 return, lib_ap
end
;===========================================================================
