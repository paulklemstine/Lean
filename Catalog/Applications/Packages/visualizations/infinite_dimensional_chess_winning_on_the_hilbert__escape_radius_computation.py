def escape_radius(pieces, attack_fn, d, king_pos, max_r=20):
    attacked = set()
    for p in pieces: attacked |= attack_fn(p, d)
    for r in range(max_r+1):
        for pos in itertools.product(range(-r,r+1), repeat=d):
            if max(abs(c) for c in pos)==r or r==0:
                cand = tuple(king_pos[i]+pos[i] for i in range(d))
                if cand not in attacked: return r
    return max_r+1