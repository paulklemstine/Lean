def check_balancing(rays):
    total_x = sum(w * d[0] for d, w in rays)
    total_y = sum(w * d[1] for d, w in rays)
    return total_x == 0 and total_y == 0