def find_separating_threshold(v, x, y):
    vx, vy = v(x), v(y)
    assert vx != vy
    return min(vx, vy)