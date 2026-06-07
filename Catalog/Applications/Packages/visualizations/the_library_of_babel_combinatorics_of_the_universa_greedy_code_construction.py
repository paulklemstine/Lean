def greedy_code(A, L, d):
    from itertools import product
    code = []
    for v in product(range(A), repeat=L):
        vol = tuple(v)
        if all(sum(a != b for a, b in zip(vol, c)) >= d for c in code):
            code.append(vol)
    return code