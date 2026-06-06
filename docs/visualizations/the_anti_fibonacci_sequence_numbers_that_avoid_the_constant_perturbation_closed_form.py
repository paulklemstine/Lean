def constant_pert_closed(c, n):
    def fib(k):
        a, b = 0, 1
        for _ in range(k): a, b = b, a+b
        return a
    return (1+c)*fib(n+1) - c