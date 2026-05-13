def compute_behavioral_equiv(states, T, refutes, max_depth=None):
    n = len(states)
    if max_depth is None:
        max_depth = n
    from collections import defaultdict
    classes = defaultdict(list)
    for i in range(n):
        key = tuple(refutes[apply_T_n(T, i, k)] for k in range(max_depth + 1))
        classes[key].append(i)
    return dict(classes)

def apply_T_n(T, x, n):
    for _ in range(n):
        x = T[x]
    return x