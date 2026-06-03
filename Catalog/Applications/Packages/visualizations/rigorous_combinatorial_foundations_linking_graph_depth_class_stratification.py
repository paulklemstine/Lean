def depth_classes(adj, initial, max_depth):
    classes = [set(initial)]
    ball = set(initial)
    for k in range(1, max_depth + 1):
        neighbors = set()
        for v in ball:
            neighbors.update(adj.get(v, set()))
        new_ball = ball | neighbors
        dc = new_ball - ball
        classes.append(dc)
        if not dc: break
        ball = new_ball
    return classes