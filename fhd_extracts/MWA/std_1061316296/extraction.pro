input_psf_file = "/Users/bryna/Projects/Physics/data_files/fhd_standard/2013_golden/fhd_standard_cal1/beams/1061316296_beams.sav"
restore, input_psf_file

input_obs_file = "/Users/bryna/Projects/Physics/data_files/fhd_standard/2013_golden/fhd_standard_cal1/metadata/1061316296_obs.sav"
restore, input_obs_file

input_params_file = "/Users/bryna/Projects/Physics/data_files/fhd_standard/2013_golden/fhd_standard_cal1/metadata/1061316296_params.sav"
restore, input_params_file

; just keep 2 times:
last_ind = (*obs.baseline_info).bin_offset[2] - 1

new_params = {uu:params.uu[0:last_ind], vv:params.vv[0:last_ind], ww:params.ww[0:last_ind], $
    baseline_arr:params.baseline_arr[0:last_ind], time:params.time[0:last_ind], $
    antenna1:params.antenna1[0:last_ind], antenna2:params.antenna2[0:last_ind]}

params=new_params
output_params_file = "/Users/bryna/Projects/Physics/data_files/fhd_standard/2013_golden/fhd_standard_cal1/cut_down_params.sav"
save, params, filename=output_params_file

; update obs to drop number of times
obs.n_time = 2
orig_bi = (*obs.baseline_info)
new_bi = {tile_A:orig_bi.tile_A[0:last_ind],tile_B:orig_bi.tile_B[0:last_ind],$
bin_offset:orig_bi.bin_offset[0:1],Jdate:orig_bi.Jdate[0:1],freq:orig_bi.freq,$
fbin_i:orig_bi.fbin_i,freq_use:orig_bi.freq_use,tile_use:orig_bi.tile_use,$
time_use:orig_bi.time_use[0:1],tile_names:orig_bi.tile_names,$
tile_height:orig_bi.tile_height,tile_flag:orig_bi.tile_flag}
obs.baseline_info = ptr_new(new_bi)

output_obs_file = "/Users/bryna/Projects/Physics/data_files/fhd_standard/2013_golden/fhd_standard_cal1/cut_down_obs.sav"
save, obs, filename=output_obs_file


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


; setup for skymodel test
catalog_path="gleam_v2_rlb2019_cut.sav"
obs_file = "/Users/bryna/Projects/Physics/pyfhd-datasets/fhd_extracts/MWA/std_1061316296/1061316296_obs.sav"
psf_file = "/Users/bryna/Projects/Physics/pyfhd-datasets/fhd_extracts/MWA/std_1061316296/cut_down_psf.sav"

obs = getvar_savefile(obs_file, "obs")
psf = getvar_savefile(psf_file, "psf")

; set obs freq_array to match psf freq_array
freqs = psf.freq
n_freq = n_elements(freqs)
obs.n_freq = n_freq
obs.nf_vis = obs.nf_vis[*, 192:193]
obs.freq_center = mean(freqs)

orig_bi = (*obs.baseline_info)
new_bi = {tile_A:orig_bi.tile_A,tile_B:orig_bi.tile_B,bin_offset:orig_bi.bin_offset,Jdate:orig_bi.Jdate,freq:freqs,fbin_i:lindgen(n_freq),$
freq_use:fltarr(n_freq) + 1,tile_use:orig_bi.tile_use,time_use:orig_bi.time_use,tile_names:orig_bi.tile_names,tile_height:orig_bi.tile_height,tile_flag:orig_bi.tile_flag}
obs.baseline_info = ptr_new(new_bi)

source_array = generate_source_cal_list(obs, psf, catalog_path=catalog_path)

cal_src_list_file = "gleam_v2_rlb2019_cut_cal_src_list.sav"
save, filename = cal_src_list_file, source_array

; setup for dft of sources to uvplane test
x_vec = double(source_array.x)
y_vec = double(source_array.y)

dim_use = 2048
; use the full plane
uv_mask=Fltarr(dim_use,dim_use)+1

uv_i_use=where(uv_mask)
xvals=double(uv_i_use mod dim_use)-dim_use/2
yvals=double(Floor(uv_i_use/dim_use))-dim_use/2

; This source_array doesn't have XX & YY fluxes (they're all zero)
; So just use I flux because we're just checking the dft code.
flux_arr=Ptrarr(1, 1)
flux_arr[0,0]=Ptr_new(double(source_array.flux.I))


model_uv_vals=source_dft(x_vec,y_vec,xvals,yvals,dimension=dim_use,elements=dim_use,flux=flux_arr,$
                conserve_memory=conserve_memory,silent=silent,inds_use=inds_use,/double_precision,$
                gaussian_source_models=gaussian_source_models)

model_uv_arr = dcomplexarr(dim_use, dim_use)
model_uv_arr[uv_i_use] = *model_uv_vals[0]

; Save out the full uv array for early testing. It's too big for unit tests though
; save_file = "/Users/bryna/Projects/Physics/pyfhd-datasets/fhd_extracts/MWA/std_1061316296/gleam_v2_rlb2019_cut_cal_src_dft.sav"
; save, filename = save_file, model_uv_arr

; cut down uvplane to make it small enough for testing

save_file = "/Users/bryna/Projects/Physics/pyfhd-datasets/fhd_extracts/MWA/std_1061316296/gleam_v2_rlb2019_cut_cal_src_dft_cut.sav"

xrange = [1, 1024]
yrange = [961, 1024]
model_uv_cut = model_uv_arr[xrange[0]:xrange[1], yrange[0]:yrange[1]]

save, filename = save_file, model_uv_cut, xrange, yrange


; setup for degridding test
obs_file = "/Users/bryna/Projects/Physics/pyfhd-datasets/fhd_extracts/MWA/std_1061316296/cut_down_obs.sav"
obs = getvar_savefile(cut_obs_file, "obs")

; set freqs to match pyfhd test beam freqs
freqs = [1.6512e08, 1.8048e08]
n_freq = n_elements(freqs)

obs.n_freq = n_freq
; the input nf_vis has a pol axis, which we don't want.
obs.nf_vis = obs.nf_vis[0, 0:n_freq]
obs.freq_center = mean(freqs)

orig_bi = (*obs.baseline_info)
new_bi = {tile_A:orig_bi.tile_A,tile_B:orig_bi.tile_B,bin_offset:orig_bi.bin_offset,Jdate:orig_bi.Jdate,freq:freqs,fbin_i:lindgen(n_freq),$
freq_use:fltarr(n_freq) + 1,tile_use:orig_bi.tile_use,time_use:orig_bi.time_use,tile_names:orig_bi.tile_names,tile_height:orig_bi.tile_height,tile_flag:orig_bi.tile_flag}
obs.baseline_info = ptr_new(new_bi)

psf_dim = 14
psf_resolution = 10
beam_mask_threshold = 1e2
interpolate_kernel = 0

psf = beam_setup(obs,status_str,antenna,file_path_fhd=file_path_fhd,restore_last=0,timing=timing,$
  beam_mask_threshold=beam_mask_threshold,silent=silent,psf_dim=psf_dim,psf_resolution=psf_resolution,$
  psf_image_resolution=psf_image_resolution,swap_pol=swap_pol,no_save=no_save,$
  beam_model_version=beam_model_version,beam_dim_fit=beam_dim_fit,save_antenna_model=save_antenna_model,$
  interpolate_kernel=interpolate_kernel,transfer_psf=transfer_psf,beam_per_baseline=beam_per_baseline,$
  beam_function_decomp=beam_function_decomp,beam_param_transfer=beam_param_transfer,$
  save_beam_metadata_only=save_beam_metadata_only,_Extra=extra)


vis_dimension=obs.nbaselines*obs.n_time
vis_weights=dblarr(obs.n_freq,vis_dimension) + 1

vis_model = dcomplexarr(obs.n_pol, obs.n_freq, vis_dimension)

for pol_i=0, 1 do vis_model[pol_i,*,*]=*(visibility_degrid(model_uv_arr,vis_weights,obs,psf,params,polarization=pol_i,/fill_model_visibilities,_Extra=extra))


save_file = "/Users/bryna/Projects/Physics/pyfhd-datasets/fhd_extracts/MWA/std_1061316296/gleam_v2_rlb2019_cut_model_vis.sav"

save, filename = save_file, vis_model
