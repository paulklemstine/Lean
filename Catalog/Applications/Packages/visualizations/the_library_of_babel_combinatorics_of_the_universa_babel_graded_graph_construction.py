def build_babel_graded_graph(A, L):
    from math import comb
    shells = []
    for k in range(L + 1):
        shells.append({
            'distance': k,
            'size': comb(L, k) * (A - 1) ** k,
            'trans_up': (L - k) * (A - 1),
            'trans_down': k,
            'expansion_ratio': (L - k) * (A - 1) / (k + 1) if k < L else 0.0
        })
    return {'A': A, 'L': L, 'shells': shells, 'library_size': A ** L}