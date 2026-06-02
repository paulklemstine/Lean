def ntsha(m, h, p):
    return min((m[i] + h[i]) % p for i in range(len(m)))