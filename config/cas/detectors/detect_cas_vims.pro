;===========================================================================
; detect_cas_vims.pro
;
;===========================================================================
function detect_cas_vims, dd

 label = strjoin(dat_header(dd),string(10B));[0]
 
 groupre='([[:<:]]GROUP[[:space:]]*=[[:space:]]*ISIS_INSTRUMENT[[:>:]])(.*)'+$
   '([[:<:]]END_GROUP[[:space:]]*=[[:space:]]*ISIS_INSTRUMENT[[:>:]])'
 if stregex(label,groupre,/boolean) then begin
   group=(stregex(label,groupre,/subexpr,/extract))[2]
   if stregex(group,'[[:<:]]INSTRUMENT_ID[[:space:]]*=[[:space:]]*("VIMS")|(VIMS)',/boolean) then begin
     channel=stregex(group,'[[:<:]]CHANNEL[[:space:]]*=[[:space:]]*(("([[:alnum:]]+)")|([[:alnum:]]+))',/extract,/subexpr)
     channel=channel[-1] ? channel[-1] : channel[-2]
     return,channel ? 'CAS_VIMS_'+channel : ''
   endif
 endif




 return, ''
end
;===========================================================================
