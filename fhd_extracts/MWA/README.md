# MWA FHD Extracts

## std_1061316296

This is a 2013 golden day zenith pointed obsid. The FHD run was a fairly standard
calibration run. The extraction was done to create input and output files to
test the beam_image method in beam_utils.py. Full extraction script in `extraction.pro`.

### Inputs

- `1061316296_obs.sav`: the unedited obs structure file
- `cut_down_psf.sav`: A file containing a dramatically cut down version of the
psf structure. Contains 2 pols, 2 frequencies and 2 baselines and just one pixel
offset (the zeroth one).

### Outputs

- `beam_image.sav`: The output of `beam_image` called with the obs and cut down
psf structures and dimension=256 for one frequency and 2 pols.
- `psf_base_superres.sav`: The output of `beam_power` called with the obs and a
cut down antenna -- biggest difference is a dramatically decreased psf_resolution
(10 vs the typical 100) to keep the file size down.
