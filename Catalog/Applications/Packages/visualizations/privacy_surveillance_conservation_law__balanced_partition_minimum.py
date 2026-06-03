def balanced_privacy(n, k):
    q, r = divmod(n, k)
    return r * (q + 1) * q + (k - r) * q * (q - 1)