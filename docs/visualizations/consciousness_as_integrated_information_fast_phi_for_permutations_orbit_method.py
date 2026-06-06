def fast_phi_perm(f, n):
    if n < 2: return 0
    visited = set()
    num_orbits = 0
    for start in range(n):
        if start not in visited:
            num_orbits += 1
            curr = start
            while curr not in visited:
                visited.add(curr)
                curr = f(curr)
    return 2 if num_orbits == 1 else 0