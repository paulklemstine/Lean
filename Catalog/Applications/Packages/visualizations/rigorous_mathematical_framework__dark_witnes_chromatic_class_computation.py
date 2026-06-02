def compute_chromatic_classes(witnesses, m, N):
    classes = {}
    for n in range(N):
        key = frozenset(a for a in range(m) if n not in witnesses[a])
        classes.setdefault(key, []).append(n)
    return classes