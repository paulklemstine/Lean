def transition_spectrum(digits, N, k):
    counts = {}
    for i in range(N):
        t = digits[i+k] - digits[i]
        counts[t] = counts.get(t, 0) + 1
    return counts