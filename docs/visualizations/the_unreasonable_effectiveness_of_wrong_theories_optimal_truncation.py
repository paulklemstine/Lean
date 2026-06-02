def optimal_truncation(theory, tolerance=1e-10):
    true_val = theory.truth_value()
    best_order, best_error = 0, abs(true_val - theory.base)
    for n in range(1, len(theory.corrections) + 1):
        pred = theory.partial_sum(n)
        error = abs(true_val - pred)
        if error < best_error - tolerance:
            best_error = error
            best_order = n
    return best_order, best_error