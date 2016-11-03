function [array_transport_units, array_pointers_for_tr_units] = funcWritingPacketsInBlock(array_transport_units, array_pointers_for_tr_units, Bufer, r) 

array_transport_units(Bufer(r,2), array_pointers_for_tr_units(Bufer(r,2)),  1) = Bufer(r,1);
array_transport_units(Bufer(r,2), array_pointers_for_tr_units(Bufer(r,2)),  2) = Bufer(r,2);
array_transport_units(Bufer(r,2), array_pointers_for_tr_units(Bufer(r,2)),  3) = Bufer(r,3);

array_pointers_for_tr_units(Bufer(r,2)) = array_pointers_for_tr_units(Bufer(r,2)) + 1;