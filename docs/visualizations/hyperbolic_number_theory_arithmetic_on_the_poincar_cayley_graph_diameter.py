def cayley_diameter(n, generators):
    visited, frontier, depth = {0}, {0}, 0
    while len(visited) < n:
        nxt = set()
        for x in frontier:
            for g in generators:
                y = (x + g) % n
                if y not in visited:
                    visited.add(y); nxt.add(y)
        if not nxt: break
        frontier, depth = nxt, depth + 1
    return depth