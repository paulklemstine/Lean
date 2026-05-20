def power_sum_oracle(t, d, n):
    if n == 0: return 2
    if n == 1: return t
    prev, curr = 2, t
    for _ in range(n - 1):
        prev, curr = curr, t * curr - d * prev
    return curr

for n in range(8):
    print(f"S_{n} = {power_sum_oracle(5, 6, n)}")