def verify_mconvex(S, n):
    S_frozen = frozenset(S)
    for alpha in S:
        for beta in S:
            for i in range(n):
                if alpha[i] > beta[i]:
                    found = False
                    for j in range(n):
                        if alpha[j] < beta[j]:
                            exchanged = list(alpha)
                            exchanged[i] -= 1
                            exchanged[j] += 1
                            if tuple(exchanged) in S_frozen:
                                found = True
                                break
                    if not found:
                        return False
    return True

# Example
S = {(2,0,0), (0,2,0), (0,0,2), (1,1,0), (1,0,1), (0,1,1)}
print(f"M-convex: {verify_mconvex(S, 3)}")  # True
