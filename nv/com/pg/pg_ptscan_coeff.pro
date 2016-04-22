;=============================================================================
;+
; NAME:
;	pg_ptscan_coeff
;
;
; PURPOSE:
;	Computes linear least-squares coefficients for a fit to the image
;	coordinate offset which matches a point to a feature in an image.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	result = pg_ptscan_coeff(pts_ps)
;
;
; ARGUMENTS:
;  INPUT:
;       pts_ps:         Array (n_pts) of points_struct output from
;                       pg_ptscan containing image points as well as
;                       other necessary data.;
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;       axis_ps:        points_struct containing a single image point
;                       to be used as the axis of rotation in the fit for
;                       every point.
;
;       fix:            Array specifying which parameters to fix in the
;                       fit as [dx,dy,dtheta].; 
;
;  OUTPUT: NONE
;
; RETURN:
;       Array (n_pts) of pg_fit_coeff_struct containing coefficients for
;       the least-square fit to be input to pg_fit.
;
;
; PROCEDURE:
;       pg_ptscan_coeff extracts the scan data from the given
;       scan_ps structure and uses ipt_coeff to compute the coefficients.
;       See the documentation for that routine for details.
;
;
; EXAMPLE:
;       The following command uses data from pg_ptscan to compute
;       least square coefficients for a fit such that only dx and dtheta
;       will be allowed to vary:
;
;       optic_ps = ps_init(points=cam_oaxis(cd))
;       ptscan_cf = pg_ptscan_coeff(pts_ps, axis=optic_ps, fix=[1])
;
;       In this call, pts_ps is a points_struct containing the point data
;       from pg_ptscan and optic_ps is a points_struct giving the optic axis
;       of the camera as computed by cam_oaxis.
;
;
; STATUS:
;	Complete.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Haemmerle, 5/1998
;	
;-
;=============================================================================
function pg_ptscan_coeff, pts_ps, axis_ps=axis_ps, fix=fix, model_ps=model_ps
                 
 if(keyword_set(_axis_ps)) then $
  begin     
   if(size(_axis_ps, /type) NE 7) then axis_ps = ps_init(points=_axis_ps) $ 
   else axis_ps = _axis_ps
  end

 n_objects = n_elements(pts_ps)
 pts_cf = replicate({pg_fit_coeff_struct}, n_objects)

 n_points = 0

 ;===============================================
 ; compute coefficients for each object
 ;===============================================
 for i=0, n_objects-1 do $
  begin
   ;----------------------------------------
   ; compute the least-squares coefficients
   ;----------------------------------------
   ps_get, pts_ps[i], data=pts_data, points=pts_pts, /visible

   if(keyword__set(pts_data)) then $
    begin
     pts_x = pts_data[0]
     pts_y = pts_data[1]
     scan_sigma = pts_data[4]
    end $
   else if(keyword__set(pts_pts)) then $
    begin
     model_pts = ps_points(model_ps[i], /visible)
     pts_x = pts_pts[0] - model_pts[0]
     pts_y = pts_pts[1] - model_pts[1]
scan_sigma = 1d
    end

   if(keyword__set(pts_x)) then $
    begin
     n_points = n_points + 1

     axis=dblarr(2)
     if(keyword__set(axis_ps)) then axi = ps_points(axis_ps0
     ipt_coeff, pts_x, pts_y, pts_pts, axis, sigma=scan_sigma, M=M, b=b

     ;--------------------------------------
     ; fix the specified rows and columns
     ;--------------------------------------
     if(keyword__set(fix)) then $
      begin
       nfix=n_elements(fix)

       for j=0, nfix-1 do $
        begin
         w = where([0,1,2] NE fix[j])
         M[fix[j],w]=0. & M[w,fix[j]]=0.
         M[fix[j],fix[j]]=1.
        end

       b[fix]=0.
      end

    end $
   ;---------------------------------------------------------------
   ; otherwise, set all coefficients to zero so that they do not
   ; contribute to a simultaneous fit
   ;---------------------------------------------------------------
   else $
    begin
     M=dblarr(3,3)
     b=dblarr(1,3)
    end

   ;--------------------
   ; save the scan data
   ;--------------------
   pts_cf[i].M=M
   pts_cf[i].b=b
  end

 ;---------------------------
 ; error if no points exist
 ;---------------------------
 if(n_points EQ 0) then return, 0
; if(n_points EQ 0) then nv_message, name='pg_ptscan_coeff', $
;                                      'No point data available - use pg_ptscan.'

 return, pts_cf
end
;===========================================================================
