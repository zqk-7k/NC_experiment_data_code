# GWTC download links manifest

This directory consolidates the download links currently used by the project.

Main file:

```text
/root/autodl-tmp/gw-catalog/results/gwtc_download_links_20260702/gwtc_download_links_all.csv
```

Rows include dataset, data_type, event_name, detector, URL, DOI/source, local path, download status, duration, and GPS start when available.

Counts:

```json
[
  {
    "dataset": "GWTC-3/O1-O3",
    "data_type": "skymap_or_pe",
    "download_status": "",
    "count": 168
  },
  {
    "dataset": "GWTC-3/O1-O3",
    "data_type": "strain_hdf5_4khz",
    "download_status": "already_exists",
    "count": 118
  },
  {
    "dataset": "GWTC-3/O1-O3",
    "data_type": "strain_hdf5_4khz",
    "download_status": "no_gwosc_url",
    "count": 8
  },
  {
    "dataset": "GWTC-4.1/O4a",
    "data_type": "pe_hdf5_with_skymap_if_available",
    "download_status": "downloaded",
    "count": 88
  },
  {
    "dataset": "GWTC-4.1/O4a",
    "data_type": "strain_hdf5_4khz",
    "download_status": "already_exists",
    "count": 34
  },
  {
    "dataset": "GWTC-4.1/O4a",
    "data_type": "strain_hdf5_4khz",
    "download_status": "downloaded",
    "count": 241
  }
]
```
