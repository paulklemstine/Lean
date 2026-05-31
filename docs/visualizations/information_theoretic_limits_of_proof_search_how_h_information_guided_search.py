def info_guided_search(alphabet_size, max_length, prior, verify):
    candidates = []
    def enum(l):
        if l == 0: return [[]]
        return [s + [c] for s in enum(l-1) for c in range(alphabet_size)]
    for l in range(1, max_length + 1):
        for s in enum(l): candidates.append((prior(s), s))
    candidates.sort(key=lambda x: -x[0])
    for _, c in candidates:
        if verify(c): return c
    return None