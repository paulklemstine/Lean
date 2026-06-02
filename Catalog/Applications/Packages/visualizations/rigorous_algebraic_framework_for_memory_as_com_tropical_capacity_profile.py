import math
def tropical_profile(f, n, depth):
    domain = list(range(n))
    current = {i: i for i in domain}
    profile = [math.log(n)]
    for _ in range(depth):
        current = {i: f(current[i]) for i in domain}
        r = len(set(current.values()))
        profile.append(math.log(r) if r > 0 else float('-inf'))
    return profile