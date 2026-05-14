import itertools
def optimal_assignment(source, target, n=12):
    best_perm, best_cost = None, float('inf')
    for perm in itertools.permutations(range(len(source))):
        cost = sum(min((source[i]-target[perm[i]])%n, n-(source[i]-target[perm[i]])%n) for i in range(len(source)))
        if cost < best_cost:
            best_cost = cost
            best_perm = perm
    return best_perm, best_cost