def rips_filtration(cloud: list) -> dict:
    distances = {}
    for i in range(len(cloud)):
        for j in range(i+1, len(cloud)):
            d = len(cloud[i].symmetric_difference(cloud[j]))
            distances[(i,j)] = d
    result = {}
    for eps in range(max(distances.values()) + 1):
        edges = [(i,j) for (i,j), d in distances.items() if d == eps]
        if edges: result[eps] = edges
    return result