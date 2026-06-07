def tropical_search(axioms, rules, target, max_iter=100):
    h = {p: 0 for p in axioms}
    for _ in range(max_iter):
        changed = False
        for p, q, c in rules:
            if p in h:
                new = h[p] + c
                if q not in h or new < h[q]:
                    h[q] = new
                    changed = True
        if not changed: break
    return h.get(target)