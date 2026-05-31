def preimage_tree(m, depth):
    current = {m}
    for _ in range(depth):
        nxt = set()
        for v in current:
            nxt.add(2 * v)
            if (v - 1) % 3 == 0:
                c = (v - 1) // 3
                if c > 0 and c % 2 == 1:
                    nxt.add(c)
        current = nxt
    return current