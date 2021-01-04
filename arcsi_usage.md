Docker:

```
sudo docker run -it --rm arcsi arcsi.py --sensor-list
```


## ARCSI usage

With Landsat-8 (see below for how to calculate AOT)
```
arcsi.py -s ls8 -f KEA --stats -p RAD TOA SREF --aeropro Maritime --atmospro MidlatitudeSummer --aot 0.25 --surfacealtitude 0.4 -o ./output -i ./LC82040242013139LGN01_MTL.txt

# Notes
#  -f output format --> main gdal format are supported but there is a bug 
#  in arcsi regarding GTiff so if you choose KEA format you can convert 
#  the output files later using gdal_translate
# gdal_translate -of GTiff -sds LS8_20130519_lat52lon42_r24p204_vmsk_rad_toa.kea LS8_20130519_lat52lon42_r24p204_vmsk_rad_toa.tif
```

KEA is multi-layer format: `-sds` creates individual output files for 
each subdataset (it's required to convert KEA into GTiff), the biggest 
files are the corrected bands. Th -sds option adds a numeric suffix to 
output files (from _01 to _n), the lower suffix among the biggest files 
is the band n° 1 and so on following the ascending order.

## SENTINEL ATMCOR USING DOS

```
Example: arcsi.py -s sen2 -p RAD TOA DOS --stats -f KEA --tmpath ./tmp -o S2A_MSIL1C_20170527T102031_N0205_R065_T32TMQ_20170527T102301.SAFE/DOSOutputs -i S2A_MSIL1C_20170527T102031_N0205_R065_T32TMQ_20170527T102301.SAFE/MTD_MSIL1C.xml
```

## SENTINEL ATMCOR USING 6S, with predefined atmosphere profile

```
arcsi.py -s sen2 -f KEA --stats -p RAD TOA SREF --aeropro Maritime --atmospro MidlatitudeWinter --aot 0.05 --surfacealtitude 0.38 -o S2A_MSIL1C_20170213T101121_N0204_R022_T32TPP_20170213T101553.SAFE/SREFOutputs_noDEM -i S2A_MSIL1C_20170213T101121_N0204_R022_T32TPP_20170213T101553.SAFE/MTD_MSIL1C.xml
```

## Recommended: SENTINEL ATMCOR: calculation of AOT using DOS (DEM based), followed by 6S

```
## remove RAD to not keep this tmp dataset
arcsi.py --sensor sen2 -i ${S2IMG}.SAFE/MTD_MSIL1C.xml -o ${S2IMG}.SAFE/OutputsAOTInv_sea --tmpath ./tmp -f KEA --stats -p RAD DOSAOTSGL SREF --aeroimg Documents/arcsi-1.4.2/data/WorldAerosolParams.kea --atmosimg Documents/arcsi-1.4.2/data/WorldAtmosphereParams.kea --dem ${S2IMG}.SAFE/dem_TR_sea --minaot 0.05 --maxaot 0.6 --simpledos
```

Usage as a script:

```
S2IMG=S2A_MSIL1C_20170613T101031_N0205_R022_T32TPR_20170613T101608 # omit: .SAFE
DEM=dem_VR_all_eudemv11.tif    # stored in S2...SAFE/ dir
OUTDIR=arcsi_output_AOT_inv
TMPDIR=~/tmp/arcsi

mkdir -p ${TMPDIR}
cd ${S2IMG}.SAFE/
# we use nice level 10
nice arcsi.py --sensor sen2 -i MTD_MSIL1C.xml -o ${OUTDIR} \
	 --tmpath ${TMPDIR} -f KEA --stats -p RAD DOSAOTSGL SREF \
	 --aeroimg ${CONDA_PREFIX}/share/arcsi/WorldAerosolParams.kea --atmosimg ${CONDA_PREFIX}/share/arcsi/WorldAtmosphereParams.kea \
	 --dem ${DEM} --minaot 0.05 --maxaot 0.6 --simpledos

# TODO:  --interp bilinear
```

For the resulting band assignments, use `gdalinfo`. E.g.

```
gdalinfo  output/*_rad_srefdem_stdsref.kea | grep 'Band \|Description'
```

Sentinel-2 bands:

- Band 1: Blue
- Band 2: Green
- Band 3: Red
- Band 4: RE_B5
- Band 5: RE_B6
- Band 6: RE_B7
- Band 7: NIR_B8
- Band 8: NIR_B8A
- Band 9: SWIR1
- Band 10: SWIR2


## SENTINEL CLOUDS MASKING (ONLY)

```
arcsi.py --sensor sen2 -i S2A_MSIL1C_20170613T101031_N0205_R022_T32TPR_20170613T101608.SAFE/MTD_MSIL1C.xml -o S2A_MSIL1C_20170613T101031_N0205_R022_T32TPR_20170613T101608.SAFE/Clouds --tmpath ./tmp -f KEA --stats -p CLOUDS 
```

## SENTINEL CLOUDS MASKING AND ATMCOR with 6S, with lookup of atmosphere profile

```
arcsi.py --sensor sen2 -i S2A_MSIL1C_20170613T101031_N0205_R022_T32TPR_20170613T101608.SAFE/MTD_MSIL1C.xml -o S2A_MSIL1C_20170613T101031_N0205_R022_T32TPR_20170613T101608.SAFE/OutputsAOTInvCL --tmpath ./tmp -f KEA --stats -p CLOUDS RAD DOSAOTSGL SREF --aeroimg Documents/arcsi-1.4.2/data/WorldAerosolParams.kea --atmosimg Documents/arcsi-1.4.2/data/WorldAtmosphereParams.kea --dem S2A_MSIL1C_20170613T101031_N0205_R022_T32TPR_20170613T101608.SAFE/dem_VR_all --minaot 0.05 --maxaot 0.6 --simpledos 
```

## SENTINEL CLOUDS MASKING AND ATMCOR with 6S but with fixed AOT (already known)

```
arcsi.py --sensor sen2 -i S2A_MSIL1C_20170613T101031_N0205_R022_T32TPR_20170613T101608.SAFE/MTD_MSIL1C.xml -o S2A_MSIL1C_20170613T101031_N0205_R022_T32TPR_20170613T101608.SAFE/OutputsAOTInvCL --tmpath ./tmp -f KEA --stats -p CLOUDS SREF --aeroimg Documents/arcsi-1.4.2/data/WorldAerosolParams.kea --atmosimg Documents/arcsi-1.4.2/data/WorldAtmosphereParams.kea --dem S2A_MSIL1C_20170613T101031_N0205_R022_T32TPR_20170613T101608.SAFE/dem_VR_all --aot 0.3
```

## SENTINEL, OLD S2 NAME style

```
arcsi.py --sensor sen2 -i S2A_OPER_PRD_MSIL1C_PDMC_20170119T125545_R097_V20161120T160552_20161120T160552.SAFE/S2A_OPER_MTD_SAFL1C_PDMC_20170119T125545_R097_V20161120T160552_20161120T160552.xml -o S2A_OPER_PRD_MSIL1C_PDMC_20170119T125545_R097_V20161120T160552_20161120T160552.SAFE/OutputsAOTInv --tmpath ./tmp -f KEA --stats -p RAD DOSAOTSGL SREF --aeroimg Documents/arcsi-1.4.2/data/WorldAerosolParams.kea --atmosimg Documents/arcsi-1.4.2/data/WorldAtmosphereParams.kea --dem S2A_OPER_PRD_MSIL1C_PDMC_20170119T125545_R097_V20161120T160552_20161120T160552.SAFE/srtm_21_05_utm17 --minaot 0.05 --maxaot 0.6 --simpledos
```
