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
        
%array_transport_units = [number_node_in_network, 1222, 3];
array_transport_units = zeros(5, 1222, 3);
array_pointers_for_tr_units = [1,1,1,1,1];  

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
        
        
        %%% start - GENERATION payload for every input ports FUNCTION!!!!!!!!!!!!%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Packet = funcGenTraffic(i, number_node_in_network, number_ports_in_node, k_speed, L, im);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% end - GENERATION payload for every input ports FUNCTION!!!!!!!!!!!%%%

        
        %%%%%%%%%%%%%%%%%   BUFER   %%%%%%%%%%%%%%%%%%%%%
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

           
         %%% start - FORMATION transport units from input payload %%%
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         for r = 1:MM
             %%% the transport unit OLS technology or other trasport
             %%% technology has length - in this sim.model average length of ip packet * 100
             %%% if transport unit has less payload than 78200 bytes we
             %%% continue to download the transport unit
                 %%% we 1)determinate the number of packets in this block 
                 %%% write this block in counter transport unit that determinate the number block in this iteration of simulation time
                 %%% destination node and number packets in block
             if sum(array_transport_units(Bufer(r,2), :, 3)) < 78200 
                 %%%FUNCTION!!!!!%%%
                 [array_transport_units, array_pointers_for_tr_units] = funcWritingPacketsInBlock(array_transport_units, array_pointers_for_tr_units, Bufer, r);
             else
                 %%% write this block in counter transport unit that determinate the number block in this iteration of simulation time
                 %%% destination node and number packets in block
                 counter_transport_unit  = [counter_transport_unit; Bufer(r, 2),  array_pointers_for_tr_units(Bufer(r,2)) + 1]; 
                 
                 array_transport_units(Bufer(r,2), 1:1222,  1) = 0;
                 array_transport_units(Bufer(r,2), 1:1222,  2) = 0;
                 array_transport_units(Bufer(r,2), 1:1222,  3) = 0;
                 array_pointers_for_tr_units(Bufer(r,2)) = 1;
                 %%%FUNCTION!!!!!%%%
                [array_transport_units, array_pointers_for_tr_units] = funcWritingPacketsInBlock(array_transport_units, array_pointers_for_tr_units, Bufer, r);
             end
         end
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         %%% end - FORMATION transport units from input payload %%%

         
        %%% SHIFT payload - we are deleting the payload from buffer that were processed
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
        %%%%%%%%%%%%%%%%%   BUFER   %%%%%%%%%%%%%%%%%%%%%
        
        
        %%% start - WRITING transport units in optical channels FUNCTION!!!!!!!!%%% 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          optical_resources_arr =  wrTransportUnitInOptChannel(counter_transport_unit, optical_resources_arr, this_node, i, max_num_tr_units_iteration); 
          counter_transport_unit = [];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% end - WRITING transport units in optical channels FUNCTION!!!!!!!!!!%%%
       
        
       %%% start - SWITCHING payload %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
               %%% start - we must switch traffic from every optical channel FUNCTION!!!!!!!!%%%
               [payload_for_next_fiber, payload_for_this_node] = funcSwitching(optical_resources_arr, number_wavelengths_fiber, max_num_tr_units_iteration, input_fiber, this_node, payload_for_next_fiber, payload_for_this_node);
               %%% end - we must switch traffic from every optical channel FUNCTION!!!!!!!!!%%%
               
               %%% start - writing transport units in optical channels - switching FUNCTION!!!!!!!!%%%
               optical_resources_arr =  wrTransportUnitInOptChannel(payload_for_next_fiber, optical_resources_arr, this_node, i, max_num_tr_units_iteration); 
               %%% end - writing transport units in optical channels - switching FUNCTION!!!!!!!!%%%        
           end   
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
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
