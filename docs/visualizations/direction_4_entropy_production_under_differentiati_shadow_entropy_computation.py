# See algorithms.py for full implementation
def shadow_entropy(S):
    if not S:
        return float('-inf')
    sh = one_shadow(S)
    if not sh:
        return float('-inf')
    return math.log(len(sh)) - math.log(len(S))