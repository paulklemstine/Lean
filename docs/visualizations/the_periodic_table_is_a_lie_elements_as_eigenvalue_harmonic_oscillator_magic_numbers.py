def ho_magic(max_shell=6):
    return [sum((k+1)*(k+2) for k in range(N+1)) for N in range(max_shell+1)]