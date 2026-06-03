def brute_force_search(alphabet_size, max_len, verifier, max_candidates=None):
    checked = 0
    limit = max_candidates or alphabet_size ** max_len
    def generate(prefix, remaining):
        nonlocal checked
        if checked >= limit: return None
        if remaining == 0:
            checked += 1
            return list(prefix) if verifier(prefix) else None
        for sym in range(alphabet_size):
            result = generate(prefix + [sym], remaining - 1)
            if result is not None: return result
        return None
    return generate([], max_len)