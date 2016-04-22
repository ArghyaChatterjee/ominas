;=============================================================================
;+
; NAME:
;	pg_ring_sector_radlon 
;
; PURPOSE:
;	Constructs a ring sector outline for use with pg_profile_ring given
;	radius and longitude bounds.
; 
; CATEGORY:
;       NV/PG
;
; CALLING SEQUENCE:
;     outline_ps=pg_ring_sector_radlon(cd=cd, dkx=dkx, gbx=gbx, rad, lon)
;
;
; ARGUMENTS:
;  INPUT:
;      rad:	2-element array giving the lower and upper radial bounds
;		for the sector.
;
;      lon:	2-elements array giving the lower and upper longitude bounds
;		for the sector in radians.
;
;  OUTPUT:
;	NONE
;
;
;
; KEYWORDS:
;  INPUT: 
;           cd:     Camera descriptor.
;
;	   dkx:     Disk descriptor describing the ring.
;
;          gbx:     Globe descriptor giving the primary for the ring.
;
;           gd:     Generic descriptor containnig the above descriptors.
;
;       sample:     Sets the grid sampling in pixels.  Default is one.
;
;         nlon:     Total number of samples in the longitude direction.  
;                   Determined by the 'sample' keyword by default.
;
;         nrad:     Total number of samples in the radial direction.  
;                   Determined by the 'sample' keyword by default.
;
;        slope:     This keyword allows the longitude to vary as a function 
;                   of radius as: lon = slope*(rad - rad0).
;
;        nodsk:     If set, image points will not be included in the output 
;                   points_struct.
;
;  OUTPUT:
;         NONE
;
;
; RETURN: 
;      points_struct containing points on the sector outline.  The point
;      spacing is determined by the sample keyword.  The points structure
;      also contains the disk coordinate for each point and the user fields
;      'nrad' and 'nlon' giving the number of points in radius and longitude.
;
;
; ORIGINAL AUTHOR : 
;	Spitale; 5/2005
;
;-
;=============================================================================



;=============================================================================
; pg_ring_sector_radlon
;
;=============================================================================
function pg_ring_sector_radlon, cd=cd, dkx=dkx, gbx=_gbx, gd=gd, $
                         rad, lon, sample=sample, slope=slope, nodsk=nodsk, $
                         nlon=__nlon, nrad=__nrad


 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 if(keyword__set(gd)) then $
  begin
   if(NOT keyword__set(cd)) then cd=gd.cd
   if(NOT keyword__set(dkx)) then dkx=gd.dkx
   if(NOT keyword__set(_gbx)) then _gbx=gd.gbx
  end

 if(NOT keyword__set(_gbx)) then $
            nv_message, name='pg_ring_sector_radlon', 'Globe descriptor required.'
 __gbx = get_primary(cd, _gbx, rx=dkx)
 if(keyword__set(__gbx)) then gbx = __gbx $
 else  gbx = _gbx[0,*]

 ;-----------------------------------
 ; validate descriptors
 ;-----------------------------------
 if(n_elements(dkx) GT 1) then nv_message, name='pg_ring_sector_rad', $
                          'No more than one ring descriptor may be specified.'
 if(n_elements(cds) GT 1) then nv_message, name='pg_ring_sector_rad', $
                        'No more than one camera descriptor may be specified.'
 rd = dkx[0]
 dkd = rng_disk(rd)



 ;--------------------------
 ; construct sector
 ;--------------------------
 _nlon = 10 & _nrad = 10
 outline_pts = get_ring_profile_outline(cd, dkd, $
                        rad=rad, lon=lon, nrad=_nrad, nlon=_nlon, $
                                                    slope=slope, frame_bd=gbx)
 dsk_outline_pts = image_to_disk(cd, dkd, frame_bd=gbx, outline_pts)
 rads = dsk_outline_pts[_nlon+lindgen(_nrad),0]
 lons = dsk_outline_pts[lindgen(_nlon), 1]

 nlonrad = get_ring_profile_n(reform(outline_pts), cd, dkd, $
                                lons, rads, oversamp=sample, frame_bd=gbx)
 nrad = long(nlonrad[1]) & nlon = long(nlonrad[0])

 if(keyword_set(__nlon)) then nlon = __nlon
 if(keyword_set(__nrad)) then nrad = __nrad

 outline_pts = get_ring_profile_outline(cd, dkd, $
                        rad=rad, lon=lon, nrad=nrad, nlon=nlon, $
                                                    slope=slope, frame_bd=gbx)


 ;-------------------------------------------
 ; Return outline points
 ;-------------------------------------------
 dsk_outline_pts = 0
 if(NOT keyword_set(nodsk)) then $
       dsk_outline_pts = image_to_disk(cd, dkd, frame_bd=gbx, outline_pts)

 outline_ps = ps_init(points = outline_pts, $
                      desc = 'pg_ring_sector_rad', $
                      data = transpose(dsk_outline_pts))
 cor_set_udata, outline_ps, 'nrad', [nrad]
 cor_set_udata, outline_ps, 'nlon', [nlon]

 return, outline_ps
end
;=====================================================================
