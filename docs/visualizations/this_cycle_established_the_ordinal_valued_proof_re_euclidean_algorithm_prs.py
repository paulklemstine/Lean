def euclid_prs(a, b):
    steps = 0
    trace = [b]
    while b > 0:
        a, b = b, a % b
        steps += 1
        trace.append(b)
    return (a, steps, trace)