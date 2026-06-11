catalog_path = "/Users/bryna/Projects/Physics/FHD/catalog_data/GLEAM_v2_plus_rlb2019.sav"

catalog = load_source_catalog(catalog_path, varname='catalog')

test_file = "gleam_v2_rlb2019_cut.sav"
n_src = n_elements(catalog)

; randomly select 100th of the sources for the test catalog
inds_use = cgRandomIndices(n_src, n_src/100, SEED=100)
catalog = catalog[inds_use]
save, catalog, filename = test_file
