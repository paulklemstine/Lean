def gap_aware_optimize(system, optimizer, proof, min_gap):
    max_steps = system.complexity(proof) // min_gap
    current = proof
    for i in range(max_steps + 1):
        if system.is_minimal(current):
            return i, current
        current = optimizer.optimize(current)
    return max_steps, current