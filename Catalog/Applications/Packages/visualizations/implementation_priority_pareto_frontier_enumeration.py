import itertools
def cyc_dist(a, b, n=12):
    r = (a - b) % n
    return min(r, n - r)

def pareto_frontier(source, target, n=12):
    k = len(source)
    perms = list(itertools.permutations(range(k)))
    frontier = []
    for tau in perms:
        dominated = False
        for sigma in perms:
            if sigma == tau: continue
            weakly = all(cyc_dist(source[i], target[sigma[i]], n) <= cyc_dist(source[i], target[tau[i]], n) for i in range(k))
            strictly = any(cyc_dist(source[i], target[sigma[i]], n) < cyc_dist(source[i], target[tau[i]], n) for i in range(k))
            if weakly and strictly:
                dominated = True
                break
        if not dominated:
            cost = sum(cyc_dist(source[i], target[tau[i]], n) for i in range(k))
            frontier.append((tau, cost))
    return frontier

# Example
print(pareto_frontier([0,4,7], [2,5,9]))