;===========================================================================
;+
; NAME:
;	surface_intersect
;
;
; PURPOSE:
;	Computes the intersection of rays with surface objects.
;
;
; CATEGORY:
;       NV/LIB/TOOLS/COMPOSITE
;
;
; CALLING SEQUENCE:
;	int_pts = surface_intersect(bx, view_pts, ray_pts)
;
;
; ARGUMENTS:
;  INPUT: 
;	bx:		Array (nt) of any subclass of BODY descriptors with
;			the expected surface parameters.
;
;	view_pts:	Array (nv,3,nt) giving ray origins in the BODY frame.
;
;	ray_pts:	Array (nv,3,nt) giving ray directions in the BODY frame.
;
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	back:	If set, only the "back" points are returned.  If the observer 
;		is exterior, these are the interesections on the back side
;		of the body (if applicable); if the observer is interior, these 
;		intersections are behind the observer.
;
;  OUTPUT:
;	hit:	Array giving the indices of rays that hit the object in 
;		the forward direction.
;
;
;	back_pts:
;		Array (nb,3,nt) of "back" points in order of distance from
;		the observer.  If the observer is exterior, these are the 
;		intersections on the back side of the body, or those behind
;		the observer; if the observer is interior, these intersections 
;		are behind the observer.
;
;
; RETURN: 
;	Array (nv,3,nt) of points in the BODY frame corresponding to the
;	first intersections with the ray.  Zero vector is returned for points 
;	with no solution.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2015
;	
;-
;===========================================================================
function surface_intersect, bx, view_pts, ray_pts, hit=hit, back_pts=back_pts

 body_pts = !null
 back_pts = !null
 if(cor_isa(bx[0], 'GLOBE')) then $
          body_pts = glb_intersect(bx, view_pts, ray_pts, back_pts=back_pts, hit=hit) $
 else if(cor_isa(bx[0], 'DISK')) then $
          body_pts = dsk_intersect(bx, view_pts, ray_pts, hit=hit)

 return, body_pts
end
;===========================================================================
