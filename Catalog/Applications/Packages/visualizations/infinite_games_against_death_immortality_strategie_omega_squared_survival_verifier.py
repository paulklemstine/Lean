def verify_omega_sq(mortal, eternity, max_m=20, max_n=20):
    for m in range(1, max_m+1):
        for n in range(1, max_n+1):
            banned = set()
            ok = True
            for _ in range(m*n):
                pos = mortal(banned)
                if pos in banned: ok = False; break
                banned.add(eternity(banned, pos))
            if not ok: return False, (m,n)
    return True, None