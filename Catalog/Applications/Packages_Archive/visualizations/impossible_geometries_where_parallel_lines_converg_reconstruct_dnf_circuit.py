def reconstruct_circuit(cl, universe):
    circuits = {}
    for x in sorted(universe):
        supports = find_minimal_supports(cl, x, universe)
        conjunctions = [conj_of_list(sorted(A)) for A in supports]
        circuits[x] = disj_of_list(conjunctions)
    return circuits