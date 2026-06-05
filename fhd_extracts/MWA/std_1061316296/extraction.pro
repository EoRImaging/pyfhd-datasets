input_psf_file = "/Users/bryna/Projects/Physics/data_files/fhd_standard/2013_golden/fhd_standard_cal1/beams/1061316296_beams.sav"
restore, input_psf_file

input_obs_file = "/Users/bryna/Projects/Physics/data_files/fhd_standard/2013_golden/fhd_standard_cal1/metadata/1061316296_obs.sav"
restore, input_obs_file

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

