function optical_resources_arr = wrTransportUnitInOptChannel(counter_transport_unit, optical_resources_arr, this_node, i, max_num_tr_units_iteration)
%%% determination the number of transport unit per this iteration for this node %%%
local_counter = size(counter_transport_unit, 1);
%%% we start writing transport unit from first wavelength %%%
wave = 1;
%%% help variable - for counter_transport unit: determination
%%% place in array for writing payload
pointer_for_payload = 1;
i_load_wave = 1;
%%% we must write this transport units in optical channel -
%%% local counter will be decrease till moment when all
%%% transport units has been written. local counter has number
%%% of tr.unit for this iteration

while local_counter > 0
    %%% start - determination of payload opt channel in this
    %%% iteration 
     while optical_resources_arr(this_node, wave, i, i_load_wave, 1) ~= 0
         i_load_wave = i_load_wave + 1;
     end
     local_level_of_payload = i_load_wave;
    %%% end - determination of payload opt channel in this
    %%% iteration 

    %%% determination the space for payload in this opt channel
    %%% if free space is absent - next opt channel
    if i_load_wave > (max_num_tr_units_iteration - 1)
        wave = wave + 1;
        i_load_wave = 1;
        wave
        continue;
    else
        %%% start - writing directly payload %%% 
        if max_num_tr_units_iteration - local_level_of_payload >=  local_counter
            %%% determination the number of tr. units that will
            %%% be written in this wave
            pointer_number_block = local_counter;
            %%% writing
            optical_resources_arr(this_node, wave, i, local_level_of_payload:local_level_of_payload + pointer_number_block - 1, :) =  counter_transport_unit(pointer_for_payload:(pointer_for_payload + pointer_number_block - 1), :);
            %%% we subtract recorded load from local_counter
            local_counter = local_counter - pointer_number_block - 1;
            pointer_for_payload = pointer_for_payload + pointer_number_block;

        else
            pointer_number_block = max_num_tr_units_iteration - local_level_of_payload;
            optical_resources_arr(this_node, wave, i, local_level_of_payload:local_level_of_payload + pointer_number_block - 1, :) =  counter_transport_unit(pointer_for_payload:(pointer_for_payload + pointer_number_block - 1), :);
            local_counter = local_counter - pointer_number_block - 1 ;
            pointer_for_payload = pointer_for_payload + pointer_number_block;
        end
        %%% end - writing directly payload %%% 
    end
end