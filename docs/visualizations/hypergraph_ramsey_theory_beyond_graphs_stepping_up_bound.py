def stepping_up_bound(base_ramsey, k, l):
    memo = {}
    def compute(k, l):
        if k <= 0 or l <= 0: return 0
        if (k, l) in memo: return memo[(k, l)]
        if k == 1 or l == 1: result = max(k, l)
        else: result = base_ramsey(compute(k-1, l), compute(k, l-1)) + 1
        memo[(k, l)] = result
        return result
    return compute(k, l)