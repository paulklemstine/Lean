def compile_circuit(gates, num_inputs, gadget_width=10, separation=15, runtime_per_gate=20):
    depths = [0] * (num_inputs + len(gates))
    for i, (in1, in2) in enumerate(gates):
        depths[num_inputs + i] = max(depths[in1], depths[in2]) + 1
    max_depth = max(depths)
    torus_m = separation * (max_depth + 2)
    torus_n = separation * (len(gates) + num_inputs + 1)
    runtime = (max_depth + 1) * runtime_per_gate
    return torus_m, torus_n, runtime