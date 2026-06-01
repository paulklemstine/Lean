def infimal_convolution(pA, pB):
    m, n = len(pA)-1, len(pB)-1
    return [min(pA[i]+pB[k-i] for i in range(max(0,k-n), min(m,k)+1)) for k in range(m+n+1)]