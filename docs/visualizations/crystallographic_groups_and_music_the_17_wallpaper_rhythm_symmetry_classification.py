def symmetry_order(rhythm):
    n = len(rhythm)
    max_k = 1
    for k in range(2, n+1):
        if n % k == 0:
            shift = n // k
            if all(rhythm[i] == rhythm[(i+shift)%n] for i in range(n)):
                max_k = k
    return max_k