input_psf_file = "/Users/bryna/Projects/Physics/data_files/fhd_standard/2013_golden/fhd_standard_cal1/beams/1061316296_beams.sav"
restore, input_psf_file

input_obs_file = "/Users/bryna/Projects/Physics/data_files/fhd_standard/2013_golden/fhd_standard_cal1/metadata/1061316296_obs.sav"
restore, input_obs_file

; use smaller psf_resolution to keep files smaller
psf_resolution = 10

antenna=fhd_struct_init_antenna(obs,beam_model_version=psf.beam_model_version,psf_resolution=psf_resolution,psf_dim=psf.dim,$
    psf_intermediate_res=psf_intermediate_res,psf_image_resolution=psf_image_resolution,timing=t_ant,$
    ra_arr=ra_arr,dec_arr=dec_arr,beam_per_baseline=beam_per_baseline,beam_gaussian_decomp=beam_gaussian_decomp,$
    beam_gauss_param_transfer=beam_gauss_param_transfer,_Extra=extra)

; pick out one antenna (they're all the same)
antenna=antenna[0]
temp=antenna.gain
; pick freq values to be close to freq available in UVBeam test data
*temp[0] = (*temp[0])[167:168, *]
*temp[1] = (*temp[1])[167:168, *]

new_ant = {n_pol:antenna.n_pol,antenna_type:antenna.antenna_type,names:antenna.names,model_version:antenna.model_version,$
    freq:antenna.freq[167:168],nfreq_bin:2,n_ant_elements:antenna.n_ant_elements,Jones:antenna.jones[*,*,167:168],$
    coupling:antenna.coupling[*,167:168],gain:temp,coords:antenna.coords,delays:antenna.delays,$
    size_meters:antenna.size_meters,height:antenna.height,rotation:antenna.rotation,response:antenna.response[*, 167:168],group_id:antenna.group_id,$
    pix_window:antenna.pix_window,pix_use:antenna.pix_use,psf_image_dim:antenna.psf_image_dim,psf_scale:antenna.psf_scale}

antenna = new_ant

output_ant_file = "/Users/bryna/Projects/Physics/data_files/fhd_standard/2013_golden/fhd_standard_cal1/cut_down_antenna.sav"
save, antenna, filename=output_ant_file

psf_intermediate_res=(Ceil(Sqrt(psf_resolution)/2)*2.)<psf_resolution
image_res_scale=obs.dimension*psf_intermediate_res/antenna.psf_image_dim
zen_int_x=(obs.zenx-obs.obsx)/image_res_scale+antenna.psf_image_dim/2
zen_int_y=(obs.zeny-obs.obsy)/image_res_scale+antenna.psf_image_dim/2

psf_superres_dim=psf.dim*psf_resolution
res_super = 1/(Double(psf_resolution)/Double(psf_intermediate_res))

xvals_uv_superres=Float(meshgrid(psf_superres_dim,psf_superres_dim,1)*res_super-$
    Floor(psf.dim/2)*psf_intermediate_res+Floor(antenna.psf_image_dim/2))
yvals_uv_superres=Float(meshgrid(psf_superres_dim,psf_superres_dim,2)*res_super-$
    Floor(psf.dim/2)*psf_intermediate_res+Floor(antenna.psf_image_dim/2))

beam_mask_threshold=1e2

psf_base_superres = dcomplexarr(2,2,psf_superres_dim,psf_superres_dim)
psf_base_superres[0, 0, *, *] = beam_power(antenna, antenna, obs=obs, ant_pol1=0, ant_pol2=0,$
          psf_dim=psf.dim,freq_i=0,psf_intermediate_res=psf_intermediate_res,$
          psf_resolution=psf_resolution,xvals_uv_superres=xvals_uv_superres,yvals_uv_superres=yvals_uv_superres,$
          beam_mask_threshold=beam_mask_threshold,zen_int_x=zen_int_x,zen_int_y=zen_int_y, $
          image_power_beam=image_power_beam,pol_i=pol_i,beam_gaussian_params=beam_gaussian_params,$
          volume_beam=volume_beam,beam_gaussian_decomp=beam_gaussian_decomp,beam_gauss_param_transfer=beam_gauss_param_transfer,$
          sq_volume_beam=sq_volume_beam,res_super=res_super,psf_superres_dim=psf_superres_dim,_Extra=extra)
psf_base_superres[0,1, *, *] = beam_power(antenna, antenna, obs=obs, ant_pol1=0, ant_pol2=1,$
          psf_dim=psf.dim,freq_i=0,psf_intermediate_res=psf_intermediate_res,$
          psf_resolution=psf_resolution,xvals_uv_superres=xvals_uv_superres,yvals_uv_superres=yvals_uv_superres,$
          beam_mask_threshold=beam_mask_threshold,zen_int_x=zen_int_x,zen_int_y=zen_int_y, $
          image_power_beam=image_power_beam,pol_i=pol_i,beam_gaussian_params=beam_gaussian_params,$
          volume_beam=volume_beam,beam_gaussian_decomp=beam_gaussian_decomp,beam_gauss_param_transfer=beam_gauss_param_transfer,$
          sq_volume_beam=sq_volume_beam,res_super=res_super,psf_superres_dim=psf_superres_dim,_Extra=extra)
psf_base_superres[1,0, *, *] = beam_power(antenna, antenna, obs=obs, ant_pol1=1, ant_pol2=0,$
          psf_dim=psf.dim,freq_i=0,psf_intermediate_res=psf_intermediate_res,$
          psf_resolution=psf_resolution,xvals_uv_superres=xvals_uv_superres,yvals_uv_superres=yvals_uv_superres,$
          beam_mask_threshold=beam_mask_threshold,zen_int_x=zen_int_x,zen_int_y=zen_int_y, $
          image_power_beam=image_power_beam,pol_i=pol_i,beam_gaussian_params=beam_gaussian_params,$
          volume_beam=volume_beam,beam_gaussian_decomp=beam_gaussian_decomp,beam_gauss_param_transfer=beam_gauss_param_transfer,$
          sq_volume_beam=sq_volume_beam,res_super=res_super,psf_superres_dim=psf_superres_dim,_Extra=extra)
psf_base_superres[1,1, *, *] = beam_power(antenna, antenna, obs=obs, ant_pol1=1, ant_pol2=1,$
          psf_dim=psf.dim,freq_i=0,psf_intermediate_res=psf_intermediate_res,$
          psf_resolution=psf_resolution,xvals_uv_superres=xvals_uv_superres,yvals_uv_superres=yvals_uv_superres,$
          beam_mask_threshold=beam_mask_threshold,zen_int_x=zen_int_x,zen_int_y=zen_int_y, $
          image_power_beam=image_power_beam,pol_i=pol_i,beam_gaussian_params=beam_gaussian_params,$
          volume_beam=volume_beam,beam_gaussian_decomp=beam_gaussian_decomp,beam_gauss_param_transfer=beam_gauss_param_transfer,$
          sq_volume_beam=sq_volume_beam,res_super=res_super,psf_superres_dim=psf_superres_dim,_Extra=extra)

output_psf_base_file = "/Users/bryna/Projects/Physics/data_files/fhd_standard/2013_golden/fhd_standard_cal1/psf_base_superres.sav"
save, psf_base_superres, filename=output_psf_base_file


; pick out middle 2 freqs, 2 beams (all the same but shallow dimensions get destroyed by ptr_new)
temp = (*psf.beam_ptr)[*,192:193,0:1]

; pick out zero offset
*temp[0, 0, 0] = reform((*temp[0, 0, 0])[0,0],[1,1])
*temp[1, 0, 0] = reform((*temp[1, 0, 0])[0,0],[1,1])
*temp[0, 1, 0] = reform((*temp[0, 1, 0])[0,0],[1,1])
*temp[1, 1, 0] = reform((*temp[1, 1, 0])[0,0],[1,1])

temp_ptr = ptr_new(temp)

new_psf = fhd_struct_init_psf(beam_ptr=temp_ptr,complex_flag=complex_flag,$
    xvals=reform(psf.xvals[0],[1,1]),yvals=reform(psf.yvals[0],[1,1]),fbin_i=fbin_i,psf_resolution=0,psf_dim=psf.dim,$
    n_pol=psf.n_pol,n_freq=2,freq_cen=psf.freq[192:193],pol_norm=pol_norm,freq_norm=freq_norm,group_arr=psf.id[*,192:193,0:1],$
    interpolate_kernel=psf.interpolate_kernel,beam_mask_threshold=psf.beam_mask_threshold,beam_model_version=psf.beam_model_version,$
    import_pyuvdata_beam_filepath=psf.import_pyuvdata_beam_filepath,$
    pix_horizon=psf.pix_horizon)

psf = new_psf

output_psf_file = "/Users/bryna/Projects/Physics/data_files/fhd_standard/2013_golden/fhd_standard_cal1/cut_down_psf.sav"
save, psf, filename=output_psf_file


output_psf_file = "/Users/bryna/Projects/Physics/data_files/fhd_standard/2013_golden/fhd_standard_cal1/cut_down_psf.sav"
restore, output_psf_file

dimension = 256
beam_image_arr = dblarr(2, dimension, dimension)
beam_image_arr[0, *, *] = beam_image(psf, obs, pol_i=0, freq_i=0, dimension=dimension)
beam_image_arr[1, *, *] = beam_image(psf, obs, pol_i=1, freq_i=0, dimension=dimension)

output_beam_image_file = "/Users/bryna/Projects/Physics/data_files/fhd_standard/2013_golden/fhd_standard_cal1/beam_image.sav"
save, beam_image_arr, filename=output_beam_image_file
