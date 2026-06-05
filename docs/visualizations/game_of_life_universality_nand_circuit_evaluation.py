def eval_nand_circuit(num_inputs, gates, output, inputs):
    wires = list(inputs)
    for g1, g2 in gates:
        wires.append(not (wires[g1] and wires[g2]))
    return wires[output]