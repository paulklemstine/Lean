def allocate_registers(intervals, k):
    # Sort by right endpoint for PEO
    peo = sorted(range(len(intervals)), key=lambda i: intervals[i][1])
    adj = [[i != j and intervals[i][0] <= intervals[j][1] and intervals[j][0] <= intervals[i][1] for j in range(len(intervals))] for i in range(len(intervals))]
    color = [-1] * len(intervals)
    # Reverse PEO order for optimal greedy
    for idx in range(len(peo) - 1, -1, -1):
        v = peo[idx]
        used = {color[j] for j in range(len(intervals)) if adj[v][j] and color[j] >= 0}
        c = 0
        while c in used: c += 1
        color[v] = c
    return color