def brute_force_search(alphabet_size, max_length, verify):
    def enum(l):
        if l == 0: return [[]]
        return [s + [c] for s in enum(l-1) for c in range(alphabet_size)]
    for l in range(1, max_length + 1):
        for candidate in enum(l):
            if verify(candidate): return candidate
    return None