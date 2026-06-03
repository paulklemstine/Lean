def cycle_check(weights):
    if sum(weights) >= 0:
        sol = [0.0]
        s = 0.0
        for w in weights[:-1]:
            s += w
            sol.append(-s)
        return True, sol
    return False, None