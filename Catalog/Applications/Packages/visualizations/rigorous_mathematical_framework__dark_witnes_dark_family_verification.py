def verify_dark_family(witnesses, N):
    m = len(witnesses)
    level = min(len(w) for w in witnesses)
    defects = [sum(1 for a in range(m) if n not in witnesses[a]) for n in range(N)]
    is_dark = all(d >= 1 for d in defects) and level > 0
    is_balanced = all(d == 1 for d in defects)
    return (is_dark, level, is_balanced)