def compute_incompleteness_gap(pa):
    witnesses = pa.true_set - pa.provable
    return len(witnesses), witnesses