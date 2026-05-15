def sorted_matching_cost(x, y):
    xs, ys = sorted(x), sorted(y)
    return sum(abs(xs[i] - ys[i]) for i in range(len(xs)))