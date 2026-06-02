def find_collision(m, h, p):
    k = len(m)
    comps = [(m[i]+h[i])%p for i in range(k)]
    j = comps.index(min(comps))
    m2 = m.copy()
    for i in range(k):
        if i != j:
            m2[i] += p
            break
    return m2