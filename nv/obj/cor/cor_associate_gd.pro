;=============================================================================
;+
; NAME:
;	cor_associate_gd
;
;
; PURPOSE:
;	Selects all input descriptors whose gd contains the given assoc_xd.
;
;
; CATEGORY:
;	NV/OBJ/COR
;
;
; CALLING SEQUENCE:
;	xd = cor_associate_gd(xd, assoc_xd)
;
;
; ARGUMENTS:
;  INPUT:
;	xd:	 	Array of objects.
;
;	assoc_xd:	Object to test against.  If not given, all input 
;			descriptors are returned.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:  NONE
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Array of objets whose generic descriptors contain assoc_xd.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2017
;	
;-
;=============================================================================
function cor_associate_gd, xd, assoc_xd

 if(NOT keyword_set(assoc_xd)) then return, xd
 result = !null

 for i=0, n_elements(xd)-1 do $
  begin
   gd = cor_gd(xd[i])
   w = where(cor_dereference_gd(gd) EQ assoc_xd)
   if(w[0] NE -1) then result = append_array(result, xd[i])
  end

 return, result
end
;=============================================================================
