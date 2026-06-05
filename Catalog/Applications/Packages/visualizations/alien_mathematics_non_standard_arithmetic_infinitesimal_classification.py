def classify_element(x, max_n=10000):
    abs_x = abs(x)
    if all(n * abs_x < 1.0 for n in range(1, max_n + 1)):
        return "infinitesimal"
    if abs_x <= max_n:
        return "bounded"
    return "infinite"