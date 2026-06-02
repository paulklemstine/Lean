def greedy_fib_avoidant(n: int) -> list:
    if n <= 0: return []
    seq = [1, 1]
    for _ in range(n - 2):
        forbidden = seq[-1] + seq[-2]
        candidate = seq[-1] + 1
        if candidate == forbidden: candidate += 1
        seq.append(candidate)
    return seq[:n]