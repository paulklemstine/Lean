def observation_quotient(f, n):
    classes = {}
    for x in range(n):
        key = f(x)
        classes.setdefault(key, set()).add(x)
    return classes