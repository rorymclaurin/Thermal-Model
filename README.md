# Thermal-Model

This is the thermal model I developed as part of the Leicester MSc project 2020. It calculates transient temperatures at an approximately component level for systems on the surface of the moon. It was inspired by in part by a paper by C.B. VanOutryve (http://scholarworks.sjsu.edu/cgi/viewcontent.cgi?article=4615&context=etd_theses).


Inputs are taken via the Excel spreadsheet - specify a component for each major component in your system. To run it in its most basic form, fill in the spreadsheet, empty "intrinsic_changes" and "control", and run "landerthermal2" with the correct values at the top of the script. To add thermal control systems, use "control" to add heat directly and "intrinsic_changes" to edit the properties of components.

The model automatically calculates a timestep at which the solution will be stable. If excessively small components are added, this timestep will be extremely short, which may cause issues. 
The model assumes no significant thermal gradient across a component. As such, it cannot model insulation directly - you must calculate the effects of insulation on the conductance between components and account for this in the spreadsheet.
