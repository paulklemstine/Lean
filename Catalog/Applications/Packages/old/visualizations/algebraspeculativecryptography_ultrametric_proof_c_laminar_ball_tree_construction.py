def build_ball_tree(D, states):
    """Build laminar ball tree from ultrametric distance matrix."""
    if len(states) <= 1:
        return {"states": list(states), "children": []}
    states = list(states)
    # Find minimum positive distance
    dists = set()
    for x in states:
        for y in states:
            if x != y: dists.add(D[x][y])
    if not dists:
        return {"states": states, "children": []}
    d_min = min(dists)
    # Partition by connected components at distance < d_min
    remaining = set(states)
    groups = []
    for x in states:
        if x in remaining:
            group = {y for y in remaining if D[x][y] < d_min}
            groups.append(group)
            remaining -= group
    return {
        "states": states,
        "radius": max(dists),
        "children": [build_ball_tree(D, g) for g in groups]
    }

# Example: ultrametric on 4 points
D = [[0,1,2,2],[1,0,2,2],[2,2,0,1],[2,2,1,0]]
tree = build_ball_tree(D, {0,1,2,3})
print(f"Tree: {tree}")
