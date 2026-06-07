def de_bruijn(A, n):
    seq = []
    a = [0] * (A * n)
    def db(t, p):
        if t > n:
            if n % p == 0: seq.extend(a[1:p+1])
        else:
            a[t] = a[t-p]; db(t+1, p)
            for j in range(a[t-p]+1, A): a[t] = j; db(t+1, t)
    db(1, 1)
    return seq