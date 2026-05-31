def condorcet_curvature(profile, n_alt):
    count = 0
    for a in range(n_alt):
        for b in range(n_alt):
            if b == a: continue
            for c in range(n_alt):
                if c == a or c == b: continue
                m_ab = sum(1 for r in profile if r.index(a) < r.index(b)) - sum(1 for r in profile if r.index(b) < r.index(a))
                m_bc = sum(1 for r in profile if r.index(b) < r.index(c)) - sum(1 for r in profile if r.index(c) < r.index(b))
                m_ca = sum(1 for r in profile if r.index(c) < r.index(a)) - sum(1 for r in profile if r.index(a) < r.index(c))
                if m_ab > 0 and m_bc > 0 and m_ca > 0:
                    count += 1
    return count