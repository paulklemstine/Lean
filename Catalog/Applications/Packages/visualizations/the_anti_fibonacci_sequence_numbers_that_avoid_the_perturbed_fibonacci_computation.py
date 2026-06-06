def perturbed_fibonacci(f, n, initial=(1,1)):
    if n <= 1: return initial[n]
    prev2, prev1 = initial
    for k in range(2, n+1):
        prev2, prev1 = prev1, prev1 + prev2 + f(k-2)
    return prev1