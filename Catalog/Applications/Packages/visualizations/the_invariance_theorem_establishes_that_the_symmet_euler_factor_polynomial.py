def power_sum_oracle(t, d, n):
    if n == 0: return 2
    if n == 1: return t
    prev, curr = 2, t
    for _ in range(n - 1):
        prev, curr = curr, t * curr - d * prev
    return curr

def euler_factor_poly(t, d, n):
    if n == 0: return [1, -1]
    if n == 1: return [1, -t, d]
    s_n = power_sum_oracle(t, d, n)
    quad = [1, -s_n, d**n]
    inner = euler_factor_poly(t, d, n - 2)
    shifted = [c * d**j for j, c in enumerate(inner)]
    result = [0] * (len(quad) + len(shifted) - 1)
    for i, c1 in enumerate(quad):
        for j, c2 in enumerate(shifted):
            result[i + j] += c1 * c2
    return result

for n in range(6):
    print(f"Phi_{n} = {euler_factor_poly(5, 6, n)}")