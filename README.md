Repository for k-tables for use with the suite of radiative transfer and
retrieval codes, NEMESIS.

These tables are for use with narrow-band imagers in the mid-IR (7-25 microns),
and have been generated for a number of different instruments based on their
filter profiles.

These ktables require a higher number of points in the initial line-by-line
calculation to ensure proper sampling of narrow, Doppler-broadened lines at low
pressures.  They also require large numbers of g-ordinates to ensure adequate
sampling of the tail ends of the g distribution (this requires changing NG to
600 in your radtran/includes/arrdef.f file and recompiling, otherwise these
tables will not be read properly).

Please send any queries to leigh.fletcher@le.ac.uk.
