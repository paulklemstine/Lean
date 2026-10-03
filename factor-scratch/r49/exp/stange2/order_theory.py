"""EXACT theory for the order step, no Monte Carlo.  p,q random odd primes."""
from functools import lru_cache


def phi2(k):
    return 1 if k == 0 else (1 << (k - 1))


def theory(M=22):
    pm = [0.0] * (M + 2)
    pm[1] = 1.0
    for j in range(2, M + 2):
        pm[j] = pm[j - 1] / 2
    tot = sum(pm)
    pm = [x / tot for x in pm]
    PS = PJ = PSJ = PSJp = Pordeven = 0.0
    for mp in range(1, M + 1):
        for mq in range(1, M + 1):
            w = pm[mp] * pm[mq]
            for kp in range(0, mp + 1):
                for kq in range(0, mq + 1):
                    u = w * phi2(kp) / 2 ** mp * phi2(kq) / 2 ** mq
                    split = kp != kq
                    PS += u * split
                    jac = (kp == mp) != (kq == mq)     # (g/p)=-1 xor (g/q)=-1
                    PJ += u * jac
                    PSJ += u * jac * split
                    PSJp += u * (not jac) * split
                    if max(kp, kq) >= 1:
                        Pordeven += u
    return {"P_split": PS, "P_jacobi_minus1": PJ,
            "P_split_given_jm1": PSJ / PJ, "P_split_given_jp1": PSJp / (1 - PJ),
            "P_ord_even": Pordeven}


if __name__ == "__main__":
    for M in (8, 12, 16, 20, 24):
        r = theory(M)
        print(f"M={M:3d}  P(split)={r['P_split']:.7f}  P(J=-1)={r['P_jacobi_minus1']:.7f}"
              f"  P(split|J=-1)={r['P_split_given_jm1']:.7f}"
              f"  P(split|J=+1)={r['P_split_given_jp1']:.7f}"
              f"  P(ord even)={r['P_ord_even']:.7f}")
    r = theory(24)
    print()
    print(f"EXACT:  P(factor)          = 20/27 = {20/27:.7f}   (measured baseline)")
    print(f"        P(factor | Jacobi(g/n)=-1) = {r['P_split_given_jm1']:.7f}  <-- non-residue bias")
    print(f"        P(factor | Jacobi(g/n)=+1) = {r['P_split_given_jp1']:.7f}")
    a = 1 / r['P_split']
    b = 1 / r['P_split_given_jm1']
    print(f"\n        cost per successful factor (in units of 'relations'):")
    print(f"          unbiased      1/P = {a:.4f}")
    print(f"          non-residue   1/P = {b:.4f}   -> {(b/a-1)*100:+.1f}% "
          f"({a/b:.3f}x cheaper)")
