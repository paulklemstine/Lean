def find_compression_witness(balls):
    """Find minimal compression witness. Greedy algorithm."""
    ball_list = list(balls)
    ground = frozenset().union(*balls)
    witnesses = set()
    unseparated = {(i,j) for i in range(len(ball_list))
                   for j in range(i+1, len(ball_list))
                   if ball_list[i] != ball_list[j]}
    while unseparated:
        best_point, best_count = None, 0
        for p in ground:
            count = sum(1 for (i,j) in unseparated
                       if (p in ball_list[i]) != (p in ball_list[j]))
            if count > best_count:
                best_count = count
                best_point = p
        if best_point is None: break
        witnesses.add(best_point)
        unseparated = {(i,j) for (i,j) in unseparated
                       if (best_point in ball_list[i]) == (best_point in ball_list[j])}
    return witnesses