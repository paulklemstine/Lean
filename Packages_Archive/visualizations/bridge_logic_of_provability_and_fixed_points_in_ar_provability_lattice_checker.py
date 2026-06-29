def check_provability_lattice(n, le, meet, join, box, names=None):
    """Check all GL-relevant properties of a finite provability lattice."""
    if names is None:
        names = [str(i) for i in range(n)]
    bot, top = 0, n - 1
    results = {}
    results['nontrivial'] = bot != top
    results['consistent'] = box[bot] == bot
    results['box_top'] = box[top] == top
    results['monotone'] = all(
        not le[a][b] or le[box[a]][box[b]]
        for a in range(n) for b in range(n)
    )
    goedel_elements = []
    for g in range(n):
        if meet[g][box[g]] == bot and join[g][box[g]] == top:
            goedel_elements.append(g)
    results['goedel_elements'] = [names[g] for g in goedel_elements]
    independent = [
        g for g in range(n)
        if g != bot and g != top and box[g] != top
    ]
    results['independent_elements'] = [names[i] for i in independent]
    return results

# Example usage
le = [[True,True,True,True],[False,True,False,True],[False,False,True,True],[False,False,False,True]]
meet = [[0,0,0,0],[0,1,0,1],[0,0,2,2],[0,1,2,3]]
join = [[0,1,2,3],[1,1,3,3],[2,3,2,3],[3,3,3,3]]
box = [0, 2, 3, 3]
result = check_provability_lattice(4, le, meet, join, box, ['bot','g','box_g','top'])
for k, v in result.items():
    print(f'{k}: {v}')