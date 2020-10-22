# ultrasonic-sensor
Code and data for the study "Development of a low cost open-source ultrasonic device for plant height measurements"

We here provide source code and source data for the study "Development of a low cost open-source ultrasonic device for plant height measurements"

Code:
- Arduino code (management of the electronic circuit): "Arduino_ultrasonic_sensor.ino"
- OpenSCAD code (3D-printing): "3DShells_ultrasonic_sensor.scad"
- R code (statistical analysis of field test): "Field_test_analysis.R"
--------------------------------------------------------------------------
Data:
- Plant height measurements performed on 26 sorghum genotypes (inbred lines) with a ruler ("Ruler.csv") and with the sensor ("Sensor.csv"). Measurements were performed on 24 September 2020, without wind, with an air humidity of 56%, and an air temperature of 24.6°C. All inbred lines were then at the grain filling stage and their vertical growth was completed. In each plot, a single operator selected three plants randomly, avoiding external rows to prevent border effects, and measured their heights using the ultrasonic device. After measuring the 26 plots, the operator repeated the exact same protocol with the ruler, measuring the same three plants in each plot. When using the ruler, plant height values were reported to a paper sheet by the operator. The height of a plant was defined as the perpendicular distance from the soil at its base to the highest point reached with all parts in their natural position.

The two data files have the same structure with 2 columns: "id_geno" which is the ID of the measurement, combining the identity of the genotype and the replicate (e.g. "Geno_07_2" = second replicate of Genotype 07), and "hauteur", the plant height value expressed in cm.

When using the ruler, the operator spent 15 min and 23 s to complete all measurements in the field, and 3 min and 27 s to enter all data manually in a digital file.
When using the sensor, the operator spent 10 min and 52 s to complete all measurements in the field, and manual transcription was not needed since all measurements are instantaneously saved on an SD card. 
