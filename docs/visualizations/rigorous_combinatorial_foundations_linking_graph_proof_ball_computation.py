def proof_ball(adj, initial, max_steps):
    balls = [set(initial)]
    for k in range(1, max_steps + 1):
        prev = balls[-1]
        neighbors = set()
        for v in prev:
            neighbors.update(adj.get(v, set()))
        new_ball = prev | neighbors
        balls.append(new_ball)
        if new_ball == prev:
            while len(balls) <= max_steps:
                balls.append(new_ball)
            break
    return balls