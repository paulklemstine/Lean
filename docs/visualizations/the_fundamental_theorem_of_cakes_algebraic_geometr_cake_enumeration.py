def enumerate_cakes(N):
    for g in range(N//3+1):
        for b in range(N-3*g+1):
            for n in range(N-3*g-b+1):
                for k in range(1, N-3*g-b-n+1):
                    if 3*g+b+n+k <= N:
                        yield (g,b,n,k)