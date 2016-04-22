;=============================================================================
; pgs_idp_to_ps
;
;=============================================================================
function pgs_idp_to_ps, idps, all_ps

 n = n_elements(all_ps)

 idp_used = make_array(n, val=nv_ptr_new())

 for i=0, n-1 do $
  begin
   idp = cor_idp(all_ps[i])
   ww = where(idp_used EQ idp)
   if(ww[0] EQ -1) then $
    begin
     idp_used[i] = idp
     w = where(idp EQ idps)
     if(w[0] NE -1) then ps = append_array(ps, all_ps[i])
    end
  end 


 if(keyword__set(ps)) then return, ps
end
;=============================================================================
