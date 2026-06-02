def tropical_iterate(W, x0, max_iter=100):
    x = x0[:]
    for step in range(max_iter):
        new_x = [min(W[i][j] + x[j] for j in range(len(x))) for i in range(len(x))]
        if all(abs(a-b) < 1e-10 for a,b in zip(x, new_x)):
            return new_x, step+1
        x = new_x
    return x, max_iter