import math
import itertools

def minkowski_sum(A, B):
    return {tuple(ai+bi for ai,bi in zip(a,b)) for a in A for b in B}

def minkowski_dilate(t, P):
    if t == 0:
        n = len(next(iter(P)))
        return {tuple(0 for _ in range(n))}
    result = P.copy()
    for _ in range(t - 1):
        result = minkowski_sum(result, P)
    return result

def extract_hstar(P, max_t=8):
    counts = [len(minkowski_dilate(t, P)) for t in range(max_t + 1)]
    diffs = counts[:]
    degree = 0
    for k in range(1, len(counts)):
        new_diffs = [diffs[i+1] - diffs[i] for i in range(len(diffs)-1)]
        if all(d == 0 for d in new_diffs):
            degree = k - 1
            break
        diffs = new_diffs
        degree = k
    d = degree
    hstar = []
    for k in range(d + 1):
        val = sum((-1)**(k-j) * math.comb(d+1, k-j) * counts[j] for j in range(k+1))
        hstar.append(val)
    return hstar

# Example: standard simplex in R^3 with degree 2
P = {(2,0,0), (0,2,0), (0,0,2), (1,1,0), (1,0,1), (0,1,1)}
hstar = extract_hstar(P)
print(f"h*-vector: {hstar}")
print(f"All nonneg: {all(h >= 0 for h in hstar)}")
