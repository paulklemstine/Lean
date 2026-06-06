import math
def hamming_ball_volume(alpha, n, t):
    return sum(math.comb(n, k) * (alpha - 1) ** k for k in range(t + 1))