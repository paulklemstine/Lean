def construct_layout(circuit, wire_delay):
    return [(wire_delay + 1) * i + 1 for i in range(len(circuit.gates))]