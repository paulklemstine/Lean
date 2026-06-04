def find_false_rankings(points):
    from itertools import combinations
    return [(x,y) for x,y in combinations(points,2)
            if sum(x)<sum(y) and not pareto_dominates(x,y)]