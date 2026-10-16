# VERIFICATION AXIS: does the published SHARED-BIAS model match the measured floor?
#
# Published nonce-leakage headlines (Breitner-Heninger ePrint 2019/023 "a bias of just 4
# bits") are about a SHARED UNKNOWN BIAS: the nonces share the same value in their top l
# bits and the attacker does NOT know it.  Round 15 measured the KNOWN-bits model:
# t*l* ~ 1.03-1.25 * log2 n.
#
# Unknowns (a, K_1..K_t, d), a < 2^l, K_i < 2^(nbits-l), d < 2^nbits:
#     s_i*(a*2^m + K_i) - r_i*d = z_i   (mod n),   m = nbits - l
#
# POSITIVE CONTROL (mandatory before any null is believed): the SAME construction with the
# bias value a HANDED TO THE ATTACKER must reproduce the round-15 known-bits threshold.  If
# the control does not fire, the bias measurement is meaningless.

def attack_bias(n, t, l, s, z, r, nbits, a_fixed=None):
    """a_fixed = None  -> bias unknown (the real test)
       a_fixed = value -> bias known  (the positive control; reduces to the round-15 model)"""
    m = nbits - l
    two_m = ZZ(1) << m
    nunk = (1 if a_fixed is None else 0) + t + 1          # [a], K_1..K_t, d
    ia = 0 if a_fixed is None else -1
    iK = 1 if a_fixed is None else 0
    id_ = iK + t
    ns = t
    N = nunk + ns + 1
    A = Matrix(ZZ, ns, N)
    rhs = vector(ZZ, ns)
    for i in range(ns):
        if a_fixed is None:
            A[i, ia] = (s[i] * two_m) % n
        else:
            rhs[i] = (z[i] - s[i] * (a_fixed % n) * two_m) % n
        A[i, iK + i] = s[i] % n
        A[i, id_] = (-r[i]) % n
        A[i, nunk + i] = -n
        if a_fixed is None:
            rhs[i] = z[i] % n
    K = A.right_kernel()
    B = K.basis_matrix().LLL()
    x0 = [ZZ(0)] * nunk
    for i in range(t):
        x0[iK + i] = (rhs[i] * inverse_mod(s[i], n)) % n
    x0[id_] = ZZ(0)
    Bemb = ZZ(1) << (nbits + 16)
    M = Matrix(ZZ, B.nrows() + 1, N)
    for i in range(B.nrows()):
        for c in range(N):
            M[i, c] = int(B[i, c])
    for c in range(nunk):
        M[B.nrows(), c] = int(x0[c])
    M[B.nrows(), N - 1] = int(Bemb)
    R = M.LLL()
    two_l = ZZ(1) << l if l > 0 else ZZ(1)
    for row in R:
        if row[N - 1] != Bemb and row[N - 1] != -Bemb:
            continue
        a_c = (row[ia] % two_l) if (a_fixed is None and l > 0) else (a_fixed % n if a_fixed is not None else ZZ(0))
        kk = [(a_c * two_m + (row[iK + i] % two_m)) % n for i in range(t)]
        d_c = (s[0] * kk[0] - z[0]) * inverse_mod(r[0], n) % n
        if all((s[i] * kk[i] - z[i] - r[i] * d_c) % n == 0 for i in range(t)):
            return True
    return False


def trial_bias(nbits, t, l, sd, a_known=False):
    set_random_seed(sd)
    n = ZZ(next_prime(2**nbits))
    m = nbits - l
    two_m = ZZ(1) << m
    a_fixed = ZZ(randint(0, (ZZ(1) << l) - 1)) if l > 0 else ZZ(0)   # the SECRET shared value
    d = ZZ(randint(1, n - 1))
    ks = [(a_fixed * two_m + ZZ(randint(0, two_m - 1))) % n for _ in range(t)]
    rs, ss, zs = [], [], []
    for i in range(t):
        rr = ZZ(randint(1, n - 1)); zz = ZZ(randint(0, n - 1))
        sv = (zz + rr * d) * inverse_mod(ks[i] % n, n) % n
        rs.append(rr); ss.append(sv); zs.append(zz)
    af = a_fixed if a_known else None
    return attack_bias(n, t, l, ss, zs, rs, nbits, a_fixed=af)


load("lib.sage")
NB = 128
print(f"nbits={NB}  -- POSITIVE CONTROL FIRST", flush=True)
print("control = the SAME construction, bias value handed to the attacker (=> the round-15 model)", flush=True)
print(f"{'l':>4} {'t':>3} {'t*l':>6} {'ratio':>7} | {'CONTROL (a known)':>18} | {'bias (a secret)':>15}", flush=True)
for (t, l) in [(2, 64), (2, 68), (2, 72), (4, 32), (4, 34), (4, 36), (8, 16), (8, 17), (8, 18), (16, 8), (16, 9)]:
    if t * l > int(1.15 * NB):
        continue
    hk = sum(trial_bias(NB, t, l, sd, a_known=True) for sd in range(8))
    hb = sum(trial_bias(NB, t, l, sd, a_known=False) for sd in range(8))
    print(f"{l:>4} {t:>3} {t*l:>6} {t*l/float(NB):>7.3f} | {hk:>10}/8        | {hb:>7}/8", flush=True)
