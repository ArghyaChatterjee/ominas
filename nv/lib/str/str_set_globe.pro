;=============================================================================
;+
; NAME:
;	str_set_globe
;
;
; PURPOSE:
;	Replaces the globe descriptor in each given star descriptor.
;
;
; CATEGORY:
;	NV/LIB/STR
;
;
; CALLING SEQUENCE:
;	str_set_globe, sx, gbd
;
;
; ARGUMENTS:
;  INPUT: 
;	sx:	 Array (nt) of any subclass of STAR.
;
;	gbd:	 Array (nt) of new globe descriptors.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN: NONE
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
;=============================================================================
pro str_set_globe, sxp, gbdp, noevent=noevent
@nv_lib.include
 sdp = class_extract(sxp, 'STAR')
 sd = nv_dereference(sdp)

 sd.gbd=gbdp

 nv_rereference, sdp, sd
 nv_notify, sdp, type = 0, noevent=noevent
end
;===========================================================================



