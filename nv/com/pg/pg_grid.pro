;=============================================================================
;+
; NAME:
;	pg_grid
;
;
; PURPOSE:
;	Computes image points on a surface coordinate grid.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	grid_ps = pg_grid(cd=cd, gbx=gbx)
;	grid_ps = pg_grid(gd=gd)
;
;
; ARGUMENTS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	cd:	Array (n_timesteps) of camera descriptors.
;
;	gbx:	Array (n_objects, n_timesteps) of descriptors of objects 
;		that must be a subclass of GLOBE.
;
;	dkx:	Array (n_objects, n_timesteps) of descriptors of objects 
;		that must be a subclass of DISK.
;
;	bx:	Array (n_objects, n_timesteps) of descriptors of objects 
;		that must be a subclass of BODY.
;
;	frame_bd:	Subclass of BODY giving the frame against which to 
;			measure inclinations and nodes, e.g., a planet 
;			descriptor.  One per bx.
;
;	gd:	Generic descriptor.  If given, the cd and gbx inputs 
;		are taken from the cd and gbx fields of this structure
;		instead of from those keywords.
;
;	lat:	Array giving grid-line latitudes in radians.
;
;	lon:	Array giving grid-line longitudes in radians.
;
;	nlat:	Number of equally-spaced latitude lines to generate if keyword
;		lat not given.  Default is 12.
;
;	flat:	This reference latitude line will be one of the latitude lines generated 
;		if nlat is specified.  Default is zero.
;
;	nlon:	Number of equally-spaced longitude lines to generate if keyword
;		lon not given.  Default is 12.
;
;	flon:	This reference longitude line will be one of the longitude lines generated 
;		if nlon is specified.  Default is zero.
;
;	fov:	 If set points are computed only within this many camera
;		 fields of view.
;
;	cull:	 If set, points structures excluded by the fov keyword
;		 are not returned.  Normally, empty points structures
;		 are returned as placeholders.
;
;	npoints: Number of points to compute in each latitude or longitude line,
;		 per 2*pi radians; default is 360.
;
;	slat:	Latitudes to compute on each longitude circle.
;
;	slon:	Longitudes to compute on each latitude circle.
;
;
;  OUTPUT: 
;	lat:	Array giving grid-line latitudes in radians.
;
;	lon:	Array giving grid-line longitudes in radians.
;
;
; RETURN:
;	Array (n_objects) of points_struct containing image points and
;	the corresponding inertial vectors.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/1998
;	
;-
;=============================================================================
function pg_grid, cd=cd, gbx=gbx, dkx=dkx, bx=bx, gd=gd, lat=_lat, lon=_lon, $
		nlat=nlat, nlon=nlon, flat=flat, flon=flon, npoints=npoints, $
		fov=fov, cull=cull, frame_bd=frame_bd, slat=slat, slon=slon
@ps_include.pro

 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 pgs_gd, gd, cd=cd, bx=bx, gbx=gbx, dkx=dkx, frame_bd=frame_bd
 if(NOT keyword_set(cd)) then cd = 0 
 if(keyword_set(gbx)) then if(NOT keyword_set(bx)) then bx = gbx
 if(keyword_set(dkx)) then if(NOT keyword_set(bx)) then bx = dkx

 if(NOT defined(flat)) then flat = 0d
 if(NOT defined(flon)) then flon = 0d

 if(keyword_set(fov)) then slop = (image_size(cd[0]))[0]*(fov-1) > 1

 if(NOT keyword_set(npoints)) then npoints = 360
 nplat = npoints
 nplon = npoints

 pgs_count_descriptors, bx, nd=n_objects, nt=nt


 ;-----------------------------------
 ; compute grid for each body
 ;-----------------------------------
 hide_flags = make_array(npoints, val=PS_MASK_INVISIBLE)

 grid_ps = ptrarr(n_objects)

 for i=0, n_objects-1 do $
  begin
   ranges = get_surface_ranges(cd, bx[i,0])
   dranges = ranges[1,*]-ranges[0,*]

   if(n_elements(_lat) EQ 0) then $
    begin
     if(n_elements(nlat) EQ 0) then nlat = 12

     if(nlat NE 0) then $  
       lat = dindgen(nlat+1)/nlat*dranges[0] + ranges[0,0] + flat
    end $
   else lat = _lat

   if(n_elements(_lon) EQ 0) then $
    begin
     if(n_elements(nlon) EQ 0) then nlon = 24

     if(nlon NE 0) then $  
       lon = dindgen(nlon+1)/nlon*dranges[1] + ranges[0,1] + flon
    end $
   else lon = _lon

   if(keyword_set(lat)) then $
    begin
     lat = reduce_range(lat, ranges[0,0], ranges[1,0], /inclusive)
     __lat = lat
    end

   if(keyword_set(lon)) then $
    begin
     lon = reduce_range(lon, ranges[0,1], ranges[1,1], /inclusive)
     __lon = lon
    end


   input = 0
   idp = 0
   if(keyword_set(bx)) then $
    begin
     xd = reform(bx[i,*], nt)
     input = pgs_desc_suffix(bx=bx[i,0], cd=cd[0])
     idp = cor_idp(xd)
    end

   ;- - - - - - - - - - - - - - - - -
   ; fov 
   ;- - - - - - - - - - - - - - - - -
   scan_ranges = ranges
   scan_dranges = dranges
   continue = 1
   if(keyword_set(fov)) then $
    begin
     surface_image_bounds, cd, xd, frame_bd=frame_bd, slop=slop, $
         latmin=latmin, latmax=latmax, lonmin=lonmin, lonmax=lonmax, status=status
     if(status NE 0) then continue = 0 $
    else $
     begin
      if(lonmax LT lonmin) then lonmin = lonmin - 2d*!dpi

      scan_ranges[*,0] = [latmin, latmax]
      scan_ranges[*,1] = [lonmin, lonmax]
      scan_dranges = scan_ranges[1,*]-scan_ranges[0,*]
     end
    end

   scan_lat = dindgen(nplat)/nplat*scan_dranges[0] + scan_ranges[0,0]
   scan_lon = dindgen(nplon)/nplon*scan_dranges[1] + scan_ranges[0,1]

   if(defined(slat)) then scan_lat = slat
   if(defined(slon)) then scan_lon = slon

   scan_lat = reduce_range(scan_lat, ranges[0,0], ranges[1,0], /inclusive)
   scan_lon = reduce_range(scan_lon, ranges[0,1], ranges[1,1], /inclusive)


   ;- - - - - - - - - - - - - - - - -
   ; compute points 
   ;- - - - - - - - - - - - - - - - -
   if(continue) then $
    begin
     grid_pts_map = map_get_grid_points(nt=nt, lat=lat, lon=lon, $
                                        scan_lat=scan_lat, scan_lon=scan_lon)
     flags = bytarr(n_elements(grid_pts_map[0,*]))
     points = map_to_image(cd, cd, xd, grid_pts_map, valid=valid, $
                                         body=grid_pts, frame_bd=frame_bd)
     inertial_pts = 0
     if(keyword_set(bx)) then $
      if(keyword_set(grid_pts)) then $
       inertial_pts = bod_body_to_inertial_pos(xd, grid_pts)
 
;     if(keyword__set(valid)) then $
;      begin
;       invalid = complement(points[0,*], valid)
;       if(invalid[0] NE -1) then flags[invalid] = PS_MASK_INVISIBLE
;      end

     ;-----------------------------------
     ; store grid
     ;-----------------------------------
     grid_ps[i] = ps_init(name = get_core_name(xd), $
		          desc = 'globe_grid', $
		          input = input, $
		          assoc_idp = idp, $
		          points = points, $
		          flags = flags, $
		          vectors = inertial_pts)
     if(keyword_set(bx)) then $
       if(NOT bod_opaque(bx[i,0])) then ps_set_flags, grid_ps[i], hide_flags
    end
  end


 ;------------------------------------------------------
 ; crop to fov, if desired
 ;  Note, that one image size is applied to all points
 ;------------------------------------------------------
 if(keyword_set(fov)) then $
  begin
   pg_crop_points, grid_ps, cd=cd[0], slop=slop
   if(keyword_set(cull)) then grid_ps = ps_cull(grid_ps)
  end


 if(keyword_set(__lat)) then _lat = __lat
 if(keyword_set(__lon)) then _lon = __lon

 return, grid_ps
end
;=============================================================================
