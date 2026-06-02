def cofinality_gap_witness(sequence, lower_bound):
    if not sequence: return None
    min_val = min(sequence)
    if min_val <= lower_bound: return None
    return (lower_bound + min_val) / 2