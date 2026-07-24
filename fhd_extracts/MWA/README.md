# FHD Extracts: MWA

## std_1061316296

This is a 2013 golden day zenith pointed obsid. The FHD run was a fairly standard
calibration run. The extraction was done to create small input and output files
to test various function. Full extraction script in `extraction.pro`.

### Inputs

- `1061316296_obs.sav`: The unedited obs structure file. 
  - **Shapes**: *128 tiles, 56 times, 384 frequencies, 2 polarizations,
  8128 baselines, 455168 baseline-times.*
- `cut_down_obs.sav`: A file containing a cut down version of the obs structure
with just the first 2 times.
  - **Shapes**: *128 tiles, 2 times, 384 frequencies, 2 polarizations,
  8128 baselines, 16256 baseline-times.*
- `cut_down_params.sav`: A file containing a cut down version of the params
structure, with just the first 2 times.
  - **Shapes**: *128 tiles, 2 times, 8128 baselines, 16256 baseline-times.*
- `cut_down_psf.sav`: A file containing a cut down version of the psf structure
with just the middle 2 frequencies, first 2 beams (they're all the same) and
1 pixel offset (the zeroth one).
  - **Shapes**: *2 polarizations, 2 frequencies, 2 beams, 1 pixel offset, 196
  kernel elements (psf_dim=14).*
- `cut_down_vis_model.sav`: A file containing a cut down set of model visibilities
with all frequencies and pols but only 75 baselines and 1 time. Used for testing
delay filters.
  - **Shapes**: *2 polarizations, 384 frequencies, 1 time, 75 baselines, 75 
  baseline-times.*

### Outputs

- `beam_image.sav`: The output of `beam_image` called with the obs and cut down
psf structures and dimension=256 for one frequency and 2 pols.
  - **Shapes**: *2 polarizations, 1 frequencies, 256x256 pixels.*
- `psf_base_superres.sav`: The output of `beam_power` called with the obs and a
cut down version of the antenna structure with 2 frequencies and a psf resolution
of 10 (vs typical 100).
  - **Shapes**: *2 polarizations, 2 frequencies, 140x140 pixels.*
- `gleam_v2_rlb2019_cut_cal_src_list.sav`: The output of `generate_source_cal_list`
called with the obs and cut down psf structures and the
`fhd_extracts/fhd_catalogs/gleam_v2_rlb2019_cut.sav` catalog in this repo.
  - **Shapes**: *198 sources*
- `gleam_v2_rlb2019_cut_cal_src_dft_cut.sav`: A portion of the output of `source_dft`
called with the sources in `gleam_v2_rlb2019_cut_cal_src_list.sav` and info from
the obs structure.
  - **Shapes**: *1024x64 uv pixels*
- `gleam_v2_rlb2019_cut_model_vis`: Degridded visibilities from sources in
`gleam_v2_rlb2019_cut_cal_src_list.sav` and using `cut_down_obs.sav` and
`cut_down_params.sav` with 2 frequencies ([1.6512e08, 1.8048e08] Hz to match the
frequencies in the pyfhd test beams).
  - **Shapes**: *128 tiles, 2 times, 2 frequencies, 2 polarizations,
  8128 baselines, 16256 baseline-times.*
- `cut_down_filtered_vis_model.sav`: Output of `vis_delay_filter` called with
the cut down obs and params and `cut_down_vis_model.sav`.
  - **Shapes**: *2 polarizations, 192 frequencies, 1 time, 75 baselines, 75 
  baseline-times.*
