
 add_fsm_encoding \
       {vc707_pcie_x8_gen2_rxeq_scan.fsm} \
       { }  \
       {{0000 00001} {0001 00010} {0010 00100} {0100 01000} {1000 10000} }

 add_fsm_encoding \
       {vc707_pcie_x8_gen2_pipe_eq.fsm_tx} \
       { }  \
       {{000000 0000001} {000001 0000010} {000010 0000100} {000100 0001000} {001000 0010000} {010000 0100000} {100000 1000000} }

 add_fsm_encoding \
       {vc707_pcie_x8_gen2_pipe_eq.fsm_rx} \
       { }  \
       {{000000 0000001} {000001 0000010} {000010 0000100} {000100 0001000} {001000 0010000} {010000 0100000} {100000 1000000} }
