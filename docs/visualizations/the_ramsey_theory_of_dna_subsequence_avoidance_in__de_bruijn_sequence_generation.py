def generate_de_bruijn(alpha, k):
    seq = []
    a = [0] * (alpha * k)
    def db(t, p):
        if t > k:
            if k % p == 0:
                seq.extend(a[1:p+1])
        else:
            a[t] = a[t-p]
            db(t+1, p)
            for j in range(a[t-p]+1, alpha):
                a[t] = j
                db(t+1, t)
    db(1, 1)
    seq.extend(seq[:k-1])
    return seq