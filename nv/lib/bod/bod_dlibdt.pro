;===========================================================================
;+
; NAME:
;	bod_dlibdt
;
;
; PURPOSE:
;       Returns the frequency of each libration vector for each given
;       body descriptor.
;
;
; CATEGORY:
;	NV/LIB/BOD
;
;
; CALLING SEQUENCE:
;	dlibdt = bod_dlibdt(bx)
;
;
; ARGUMENTS:
;  INPUT: NONE
;	bx:	 Array (nt) of any subclass of BODY descriptors.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;
;  OUTPUT: NONE
;
;
; RETURN:
;       Values of the frequency of each libration vector associated
;       with each given body descriptor.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/1998
;	
;-
;===========================================================================
function bod_dlibdt, bxp, noevent=noevent
@nv_lib.include
 bdp = class_extract(bxp, 'BODY')
 nv_notify, bdp, type = 1, noevent=noevent
 bd = nv_dereference(bdp)
 return, bd.dlibdt
end
;===========================================================================
