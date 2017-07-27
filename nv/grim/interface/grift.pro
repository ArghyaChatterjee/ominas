;=============================================================================
;+
; NAME:
;	grift
;
;
; PURPOSE:
;	External access to GRIM data.  Purloins object and array references
;	from GRIM so that they may be manipulated on the command line or by an
;	external agent.  The returned descriptors allow direct access to the 
;	memory images of GRIM's objects, so any changes made affect the 
;	objects that GRIM is using.  GRIM monitors those objects and updates 
;	itself whenever a change occurs.  
;
;
; CATEGORY:
;	NV/GR
;
;
; CALLING SEQUENCE:
;	grift, arg, <xd>=<xd>, <overlay>_ptd=<overlay>_ptd
;
;
; ARGUMENTS:
;  INPUT:
;	arg:	GRIM window number or GRIM data struture.  If not given, the 
;		most recently accessed grim instance is used.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	plane:	Grim plane structure(s) instead of giving pn.  Note all planes
;		must belong to the same grim instance.
;
;	pn:	Plane number(s) to access.  If not given, then current plane
;		is used.
;
;	all:	If set, all planes are used.
;
;	active:	If set, only active memebrs of the selected objects are
;		returned.
;
;  OUTPUT:
;	gd:	Generic descriptor containing all of GRIM's descriptors.  
;		For multiple planes, a list is returned with each element
;		corresponding to a plane.
;
;	<xd>:	Any descriptor maintained by GRIM.
;
;	<overlay>_ptd:
;		POINT object giving the points for the overlay of type <overlay>.
;
;	object_ptd:
;		POINT object giving all overlay points.
;
;	tie_ptd:
;		POINT object giving the tie points.  For multiple planes, a 
;		list is returned with each element corresponding to a plane.
;
;	curve_ptd:
;		POINT object giving the curve points.  For multiple planes, a 
;		list is returned with each element corresponding to a plane.
;
;
; EXAMPLE:
;	(1) Open a GRIM window, load an image, and compute limb points.
;
;	(2) At the command line, type:
;
;		IDL> grift, cd=cd
;		IDL> pg_repoint, [50,50], 0d, cd=cd
;
;	GRIM should detect the change to the camera descriptor and update
;	itself by recomputing the limb points and refreshing the display.
;
;
; SEE ALSO:
;	grim, graft
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2002
;	
;-
;=============================================================================
pro grift, arg, plane=planes, pn=pn, all=all, active=active, grn=grn, gd=gd, $
         dd=dd, $
         cd=cd, $
         pd=pd, $
         rd=rd, $
         sd=sd, $
         std=std, $
         ard=ard, $
         sund=sund, $
         od=od, $
         limb_ptd=limb_ptd, $
         ring_ptd=ring_ptd, $
         star_ptd=star_ptd, $
         station_ptd=station_ptd, $
         array_ptd=array_ptd, $
         term_ptd=term_ptd, $
         plgrid_ptd=plgrid_ptd, $
         center_ptd=center_ptd, $
         shadow_ptd=shadow_ptd, $
         reflection_ptd=reflection_ptd, $
         object_ptd=object_ptd, $
         tie_ptd=tie_ptd, $
         curve_ptd=curve_ptd


 ;--------------------------------------------
 ; clear output arrays
 ;--------------------------------------------
 dd = !null
 cd = !null
 pd = !null
 rd = !null
 sd = !null
 std = !null
 ard = !null
 sund = !null
 od = !null
 limb_ptd = !null
 ring_ptd = !null
 star_ptd = !null
 station_ptd = !null
 array_ptd = !null
 term_ptd = !null
 plgrid_ptd = !null
 center_ptd = !null
 shadow_ptd = !null
 reflection_ptd = !null
 object_ptd = !null
 tie_ptd = !null
 curve_ptd = !null

 ;----------------------------------------------------------------
 ; interpret argument
 ;----------------------------------------------------------------
 arg_type = size(arg, /type)
 if(arg_type EQ 8) then grim_data = arg $
 else if(arg_type NE 0) then grn = arg

 if(defined(grn)) then grim_data = grim_get_data(grim_grn_to_top(grn)) $
 else grim_data = grim_get_data(/primary)

 if(NOT keyword_set(grim_data)) then grim_data = grim_get_data(planes[0])

 grn = grim_data.grn

 
 ;----------------------------------------------------------------
 ; get planes
 ;----------------------------------------------------------------
 if(NOT keyword_set(planes)) then $
  begin
   if(keyword_set(all)) then planes = grim_get_plane(grim_data, /all) $
   else planes = grim_get_plane(grim_data)
  end
 nplanes = n_elements(planes)


 ;----------------------------------------------------------------
 ; build outputs
 ;----------------------------------------------------------------
 gd = list(length=nplanes)
 tie_ptd = list(length=nplanes)
 curve_ptd = list(length=nplanes)

 for i=0, nplanes-1 do $
  begin
   plane = planes[i]

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; active objects
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
   if(keyword_set(active)) then $
    begin
     ddi = (cdi = (sundi = (odi = !null)))
     pd = append_array(active_pd, (pdi=grim_get_active_xds(plane, 'planet')))
     rd = append_array(active_rd, (rdi=grim_get_active_xds(plane, 'ring')))
     sd = append_array(active_sd, (sdi=grim_get_active_xds(plane, 'star')))
     std = append_array(active_std, (stdi=grim_get_active_xds(plane, 'station')))
     ard = append_array(active_ard, (ardi=grim_get_active_xds(plane, 'array')))

     limb_ptd = append_array(limb_ptd, grim_get_active_overlays(grim_data, 'limb'))
     ring_ptd = append_array(ring_ptd, grim_get_active_overlays(grim_data, 'ring'))
     star_ptd = append_array(star_ptd, grim_get_active_overlays(grim_data, 'star'))
     term_ptd = append_array(term_ptd, grim_get_active_overlays(grim_data, 'terminator'))
     plgrid_ptd = append_array(plgrid_ptd, grim_get_active_overlays(grim_data, 'planet_grid'))
     center_ptd = append_array(center_ptd, grim_get_active_overlays(grim_data, 'planet_center'))
     shadow_ptd = append_array(shadow_ptd, grim_get_active_overlays(grim_data, 'shadow'))
     reflection_ptd = append_array(reflection_ptd, grim_get_active_overlays(grim_data, 'reflection'))
     station_ptd = append_array(station_ptd, grim_get_active_overlays(grim_data, 'station'))
     array_ptd = append_array(array_ptd, grim_get_active_overlays(grim_data, 'array'))
     object_ptd = append_array(object_ptd, *plane.active_xd_p)
    end $
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; all objects
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
   else $
    begin
     dd = cor_cull(append_array(dd, (ddi=plane.dd)))
     cd = cor_cull(append_array(cd, (cdi=*plane.cd_p)))
     pd = cor_cull(append_array(pd, (pdi=*plane.pd_p)))
     rd = cor_cull(append_array(rd, (rdi=*plane.rd_p)))
     sd = cor_cull(append_array(sd, (sdi=*plane.sd_p)))
     std = cor_cull(append_array(std, (stdi=*plane.std_p)))
     ard = cor_cull(append_array(ard, (ardi=*plane.ard_p)))
     sund = cor_cull(append_array(sund, (sundi=*plane.sund_p)))
     od = cor_cull(append_array(od, (odi=*plane.od_p)))

     limb_ptd = append_array(limb_ptd, *(grim_get_overlay_ptdp(grim_data, plane=plane, 'limb')))
     ring_ptd = append_array(ring_ptd, *(grim_get_overlay_ptdp(grim_data, plane=plane, 'ring')))
     star_ptd = append_array(star_ptd, *(grim_get_overlay_ptdp(grim_data, plane=plane, 'star'))) 
     term_ptd = append_array(term_ptd, *(grim_get_overlay_ptdp(grim_data, plane=plane, 'terminator'))) 
     plgrid_ptd = append_array(plgrid_ptd, *(grim_get_overlay_ptdp(grim_data, plane=plane, 'planet_grid'))) 
     center_ptd = append_array(center_ptd, *(grim_get_overlay_ptdp(grim_data, plane=plane, 'planet_center'))) 
     shadow_ptd = append_array(shadow_ptd, *(grim_get_overlay_ptdp(grim_data, plane=plane, 'shadow'))) 
     reflection_ptd = append_array(reflection_ptd, *(grim_get_overlay_ptdp(grim_data, plane=plane, 'reflection'))) 
     station_ptd = append_array(station_ptd, *(grim_get_overlay_ptdp(grim_data, plane=plane, 'station'))) 
     array_ptd = append_array(array_ptd, *(grim_get_overlay_ptdp(grim_data, plane=plane, 'array'))) 
     object_ptd = append_array(object_ptd, grim_cat_points(grim_data))
    end

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; tie points and curves
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
   tie_ptd[i] = *plane.tiepoint_ptdp
   curve_ptd[i] = *plane.curve_ptdp

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; generic descriptor
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - -
   gd[i] = cor_create_gd(dd=ddi, cd=cdi, pd=pdi, rd=rdi, $
                            sund=sundi, sd=sdi, ard=ardi, std=stdi, od=odi)
  end

 ;------------------------------------------------------------------
 ; don't return lists if only one plane
 ;------------------------------------------------------------------
 if(nplanes EQ 1) then $
  begin
   if((n_elements(gd) EQ 1) AND (NOT keyword_set(gd[0]))) then gd = !null $
   else gd = gd.ToArray()
   tie_ptd = tie_ptd.ToArray()
   curve_ptd = curve_ptd.ToArray()
  end


end
;=============================================================================