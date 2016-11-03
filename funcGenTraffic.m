function Packet = funcGenTraffic(i, number_ports_in_node, number_node_in_network, k_speed, L, im)      
    %%% start - generation payload for every input ports %%%
    Packet = [];
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