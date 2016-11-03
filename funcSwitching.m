function [payload_for_next_fiber, payload_for_this_node] = funcSwitching(optical_resources_arr, number_wavelengths_fiber, max_num_tr_units_iteration, input_fiber, this_node, payload_for_next_fiber, payload_for_this_node)
    for waveSwitch = 1:number_wavelengths_fiber
        for loc_block = 1: max_num_tr_units_iteration
           if optical_resources_arr(input_fiber, waveSwitch, i - 1, loc_block, 1) ~= 0
               if optical_resources_arr(input_fiber, waveSwitch, i - 1, loc_block, 1) == this_node
                   payload_for_this_node = [payload_for_this_node; [optical_resources_arr(input_fiber, waveSwitch, i - 1, loc_block, 1), optical_resources_arr(input_fiber, waveSwitch, i - 1, loc_block, 2)]];
               else
                   payload_for_next_fiber = [payload_for_next_fiber; [optical_resources_arr(input_fiber, waveSwitch, i - 1, loc_block, 1), optical_resources_arr(input_fiber, waveSwitch, i - 1, loc_block, 2)]];
               end
           else
               break;
          end
        end
    end