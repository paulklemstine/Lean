def check_diagonal_incompleteness(evaluator, n, diag_index, threshold=0.0):
    import numpy as np
    x0 = np.zeros(n)
    fp = evaluator(x0)
    if fp[diag_index] <= threshold:
        return 'UNSOUND'
    else:
        return 'INCOMPLETE'