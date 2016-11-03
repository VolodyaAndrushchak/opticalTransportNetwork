clear all,clc, warning off

%%% length of packets %%%
L=[64,1450,800,64];
%%% The intensity of incoming calls %%%
ly=[50,250,25,10];

%%% size of transport data block %%%
size_tr_unit = 78200;
%%% simulation step - 1ms %%%
simulation_step = 0.001;
%%% number of simulation steps per second %%%
simulation_steps_second = 1 /  simulation_step;
%%% speed of transfer - 100Gb/s%%%
speed_of_transfer_opt_channel = 100000000000;
%%% max number of transport block per iteration - simulation step %%%
max_num_tr_units_iteration =  eval(sprintf('%.0f',((speed_of_transfer_opt_channel / simulation_steps_second)/8)/size_tr_unit));

sizeBuffer = [];
sizePacket = [];
%%% Herst functions %%%
fBM1 = abs(wfbm(0.72, 20000));
%%% Herst parameter %%%
H = wfbmesti(fBM1);
%%% influence on payload of this node %%%
k_speed = 400; 
%%% number bit in byte %%%
lengthByte = 8;
%%% avarage length of ip packet %%%
averageLengthIpPacket = 782;
%%% number of iteration of simulation time %%%
simulation_time = 5;
%%% lengths of ip packets for different type of traffic %%% 
L=[64,1450,800,64];
%%% probability of different type of traffic %%%
im=[0, 0.5,0.8,1];
%%% number nodes in optical transport network %%%
number_node_in_network = 3;
%%% number wavelengths in fiber optic %%%
number_wavelengths_fiber = 10;
%%% number INPUT port in node %%%
number_ports_in_node = 4; 
transport_unit = [0,0,0];
optical_channel_1 = [0,0];
%counter_transport_unit = zeros(simulation_time, max_num_tr_units_iteration + 1);
%counter_transport_unit = zeros(max_num_tr_units_iteration + 1, 2);
counter_transport_unit = [];

%%% parameter of buffer processing  - number packets per iteration(simulation time) %%%
M = 50000;
MM = M;
Packet = [];
Bufer = [];
payload_for_next_fiber = [];
payload_for_this_node = [];

matrixResearchGraph = [0,1,0,0,1; 1,0,1,0,0; 0,1,0,1,0;0,0,1,0,1;1,0,0,1,0];
objResearchGraph = biograph(matrixResearchGraph);
%%% the general array of payload in network%%%
%%% 5D-array: number lines communication in networks (one fiber between two nodes);%%%
%%% number wavelengths in this fiber; simulation time; transport unit(block); [dest, length]%%%
%%% optical_resources_arr = zeros(number_node_in_network, number_wavelengths_fiber, simulation_time, max_num_tr_units_iteration + 1, 2);
optical_resources_arr = zeros(5, number_wavelengths_fiber, simulation_time, max_num_tr_units_iteration + 1, 2);
%%%--- start loop - 'simulation time' ---%%% 
for i = 1:simulation_time;
    
    %%%--- start loop - 'generation, aggregation, processing and switching payload' ---%%%
    for this_node = 1 : number_node_in_network          
        %%% start - generation payload for every input ports %%%
        for z = 1 : number_ports_in_node;
            fBM_local = abs(wfbm(0.72, 20000));
             for j = 1:fBM_local(i+900)*k_speed
                    %%% start - generation type of service %%%
                      n = 1;
                      p = rand();
                        while p > im(n);
                             n = n + 1;
                        end
                     k = n - 1;
                    %%% end - generation type of service %%%
                destination_Node = round(rand() * (number_node_in_network - 1) + 1); % генерація дестенейшн
                P = [1, destination_Node, L(k)];            
                Packet = [Packet; P];
             end
        end
        %%% end - generation payload for every input ports %%%

        %%% all packers are transfered in common buffer from input ports %%%
         Bufer = [Bufer; Packet];
         Packet = [];
        %%% determination the size of buffer %%%
         [m,~]=size(Bufer);

         %%% if number of packets in buffer are less than M-parameter
         %%% then... determination number of iterations MM for processing
         %%% packets in this iteration of simulation time
           if m<=M
             MM=m;      %якщо довжина буфера менше M
           end
        
         %array_transport_units = [number_node_in_network, 1222, 3];
         array_transport_units = zeros(5, 1222, 3);
         array_pointers_for_tr_units = [1,1,1,1,1];  
         %%% start - formation transport units from input payload %%%
         for r = 1:MM
             %%% the transport unit OLS technology or other trasport
             %%% technology has length - in this sim.model average length of ip packet * 100
             %%% if transport unit has less payload than 78200 bytes we
             %%% continue to download the transport unit
             %if sum(transport_unit(:, 3)) < 78200 
                % transport_unit = [transport_unit; Bufer(r, :)];
             %%% else 
            % else
                 %%% we 1)determinate the number of packets in this block 
                 %[l,~]=size(transport_unit);
                 %%% write this block in counter transport unit that determinate the number block in this iteration of simulation time
                 %%% destination node and number packets in block
                 %counter_transport_unit  = [counter_transport_unit; Bufer(r, 2), l]; 
                % transport_unit = [0,0,0];
             %end 
             if sum(array_transport_units(Bufer(r,2), :, 3)) < 78200
                 array_transport_units(Bufer(r,2), array_pointers_for_tr_units(Bufer(r,2)),  1) = Bufer(r,1);
                 array_transport_units(Bufer(r,2), array_pointers_for_tr_units(Bufer(r,2)),  2) = Bufer(r,2);
                 array_transport_units(Bufer(r,2), array_pointers_for_tr_units(Bufer(r,2)),  3) = Bufer(r,3);
                 
                 array_pointers_for_tr_units(Bufer(r,2)) = array_pointers_for_tr_units(Bufer(r,2)) + 1;
             else
                 %[l,b, ~]=size(array_transport_units(Bufer(r,2)));
                 %%% write this block in counter transport unit that determinate the number block in this iteration of simulation time
                 %%% destination node and number packets in block
                 counter_transport_unit  = [counter_transport_unit; Bufer(r, 2),  array_pointers_for_tr_units(Bufer(r,2)) + 1]; 
                 
                 array_transport_units(Bufer(r,2), 1:1222,  1) = 0;
                 array_transport_units(Bufer(r,2), 1:1222,  2) = 0;
                 array_transport_units(Bufer(r,2), 1:1222,  3) = 0;
                 array_pointers_for_tr_units(Bufer(r,2)) = 1;
                 
                 array_transport_units(Bufer(r,2), array_pointers_for_tr_units(Bufer(r,2)),  1) = Bufer(r,1);
                 array_transport_units(Bufer(r,2), array_pointers_for_tr_units(Bufer(r,2)),  2) = Bufer(r,2);
                 array_transport_units(Bufer(r,2), array_pointers_for_tr_units(Bufer(r,2)),  3) = Bufer(r,3);
                 
                 array_pointers_for_tr_units(Bufer(r,2)) = array_pointers_for_tr_units(Bufer(r,2)) + 1;
             end
         end
         %%% end - formation transport units from input payload %%%

        %%% shift payload - we are deleting the payload from buffer that were processed
        %%% in previous step. Payload that were not processed in previous
        %%% step (these packets were in queue) are being shifting
        if m<=M 
             Bufer=[];
         else
             Bufer(1:m-M,1)=Bufer(M:m-1,1);
             Bufer(1:m-M,2)=Bufer(M:m-1,2);    
             Bufer(1:m-M,3)=Bufer(M:m-1,3);    
             Bufer(m-M:m,:)=[];
        end
        %%% end shift %%%
        
        %%% start - writing transport units in optical channels %%% 
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
                 if local_level_of_payload == 2
                      local_level_of_payload = 1; 
                 end
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
                        optical_resources_arr(this_node, wave, i, local_level_of_payload:local_level_of_payload + pointer_number_block - 1, :) =  counter_transport_unit(pointer_for_payload:(pointer_for_payload+pointer_number_block - 1), :);
                        local_counter = local_counter - pointer_number_block - 1 ;
                        pointer_for_payload = pointer_for_payload + pointer_number_block;
                    end
                    %%% end - writing directly payload %%% 
                end
            end
            counter_transport_unit = [];
       %%% end - writing transport units in optical channels %%%
       
       %%% start - switching payload %%%
           %%% we miss firt step (i = 0) - on this step only generation
           %%% traffic
           if i ~= 1
               %%% input/output fiber for switching
               input_fiber = this_node - 1;
               output_fiber = this_node;
               %%% for first node input fiber must be 5 fiber
               if this_node == 1
                   input_fiber = 5; 
               end
               
                payload_for_next_fiber = [];
                payload_for_this_node = [];
               %%% start - we must switch traffic from every optical channel %%%
               for waveSwitch = 1:number_wavelengths_fiber
                   for loc_block = 1: max_num_tr_units_iteration
                       if optical_resources_arr(input_fiber, waveSwitch, i - 1, 1, 1) ~= 0
                           if optical_resources_arr(input_fiber, waveSwitch, i - 1, 1, 1) == this_node
                               payload_for_this_node = [payload_for_this_node; [optical_resources_arr(input_fiber, waveSwitch, i - 1, loc_block, 1), optical_resources_arr(input_fiber, waveSwitch, i - 1, loc_block, 2)]];
                           else
                               payload_for_next_fiber = [payload_for_next_fiber; [optical_resources_arr(input_fiber, waveSwitch, i - 1, loc_block, 1), optical_resources_arr(input_fiber, waveSwitch, i - 1, loc_block, 2)]];
                           end
                       else
                           break;
                      end
                   end
               end
               %%% end - we must switch traffic from every optical channel %%%
               
            %%% start - writing transport units in optical channels - switching %%% 
            %%% determination the number of transport unit per this iteration for this node %%%
            local_counter = size(payload_for_next_fiber, 1);
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
                 if local_level_of_payload == 2
                      local_level_of_payload = 1; 
                 end
                %%% end - determination of payload opt channel in this
                %%% iteration 
                
                %%% determination the space for payload in this opt channel
                %%% if free space is absent - next opt channel
                if i_load_wave > (max_num_tr_units_iteration - 1)
                    wave = wave + 1;
                    i_load_wave = 1;
                    wave
                    'this'
                    continue;
                else
                    %%% start - writing directly payload %%% 
                    if max_num_tr_units_iteration - local_level_of_payload >=  local_counter
                        %%% determination the number of tr. units that will
                        %%% be written in this wave
                        pointer_number_block = local_counter;
                        %%% writing
                        optical_resources_arr(this_node, wave, i, local_level_of_payload:local_level_of_payload+pointer_number_block - 1, :) =  payload_for_next_fiber(pointer_for_payload:(pointer_for_payload + pointer_number_block - 1), :);
                        %%% we subtract recorded load from local_counter
                        local_counter = local_counter - pointer_number_block - 1;
                        pointer_for_payload = pointer_for_payload + pointer_number_block;

                    else
                        pointer_number_block = max_num_tr_units_iteration - local_level_of_payload;
                        optical_resources_arr(this_node, wave, i, local_level_of_payload:local_level_of_payload+pointer_number_block - 1, :) =  payload_for_next_fiber(pointer_for_payload:(pointer_for_payload+pointer_number_block - 1), :);
                        local_counter = local_counter - pointer_number_block - 1 ;
                        pointer_for_payload = pointer_for_payload + pointer_number_block;
                    end
                    %%% end - writing directly payload %%% 
                end
            end
            counter_transport_unit = [];
       %%% end - writing transport units in optical channels - switching %%%
               

           end
      %optical_resources_arr(5, 1, 2, 1, 1)    
       %%% end - switching payload %%%
    end
    %%%--- end loop - 'generation, aggregation, processing and switching payload for every node' ---%%%
end
%%%--- end loop - 'simulation time' ---%%% 


arr = [];
for fiber1 = 1:5
    for time = 1:5 
        i_load_wave = 1;
        while optical_resources_arr(fiber1, 3, time, i_load_wave, 1) ~= 0
                     i_load_wave = i_load_wave + 1;
        end
       arr = [arr; i_load_wave];      
    end   
end

%plot(arr);
