# GENERAL RECURRENCE LAW (v2, correct derivation) -- r117/recurrence-law/law.sage
#
# I2 (verified, round 115) showed nonces obeying k_{i+1} = a*k_i + b (mod 2^m) with a KNOWN
# are broken: the key falls from 4-6 signatures with ZERO nonce leakage.  The mechanism is
# that the second difference is a HOMOGENEOUS linear relation with KNOWN coefficients.
#
# CLAIM: any nonce generator whose states obey a known homogeneous linear recurrence
#             k_{i+j} = sum_l c_l k_{i+l}   (mod M),      c_l, M known,
# is broken, and the number of signatures needed is t* = j + O(1).
#
# DERIVATION (this is what v1 got wrong): unknowns are (k_0..k_{t-1}, d) PLUS the slack
# variables of the congruences,
#     s_i k_i - r_i d - n u_i              = z_i        (mod nothing: over Z)
#     k_{i+j} - sum_l c_l k_{i+l} - M v_i   = 0
# so there are (t+1) + (t) + (t-j) = 2t+1-j unknowns and t + (t-j) = 2t-j equations.  The
# kernel has rank (2t+1-j) - (2t-j) = 1: the affine solution set is a LINE.  The true key is
# the SHORT point on that line, so it falls to Gauss reduction of a rank-1 lattice.
# Over-determined exactly when 2t-j >= t+1, i.e. t >= j+1  =>  prediction t* = j+1 (+margin).

def attack(n, t, j, c, M, s, r, z):
    """Unknowns (k_0..k_{t-1}, d) plus slacks u_i (mod n) and v_i (mod M).  The true
    solution satisfies the plain INTEGER equalities below, with bounded slacks:
        s_i k_i - r_i d - n u_i = z_i
        k_{i+j} - sum_l c_l k_{i+l} - M v_i = 0
    The homogeneous system then has a rank-1 kernel (for t >= j+1), so the affine solution
    set is a line and the true key is its short point."""
    nsig, nrec = t, t - j
    nk, nd, nu, nv = t, 1, t, nrec
    U = nk + nd + nu + nv
    A = Matrix(ZZ, nsig + nrec, U)
    b = vector(ZZ, nsig + nrec)
    for i in range(nsig):
        A[i, i] = s[i]
        A[i, nk] = -r[i]
        A[i, nk + nd + i] = -n
        b[i] = z[i]
    for i in range(nrec):
        A[nsig + i, i + j] = 1
        for l in range(j):
            A[nsig + i, i + l] -= c[l]
        A[nsig + i, nk + nd + nu + i] = -M
        b[nsig + i] = 0
    K = A.right_kernel()
    if K.dimension() == 0:
        return False                       # over-determined with no free direction
    R = K.basis_matrix().LLL()
    # particular solution: choose the slacks to be the exact quotients of the TRUE
    # solution is unknown; instead search short points on the affine line directly by
    # looking at the kernel: any solution = (particular) + kernel combination.  Obtain a
    # particular solution by setting the slacks to 0 and solving the resulting (t+1)-unknown
    # system over ZZ if possible; otherwise scan short kernel combinations against the
    # ORIGINAL congruences.
    seen = set()
    for row in R:
        for mlt in (1, -1, 1, -1, 2, -2, 3, -3, 4, -4):
            v = mlt * row
            key = tuple(int(v[i]) for i in range(t))
            if key in seen: continue
            seen.add(key)
            ks = [v[i] % M for i in range(t)]
            if all(x == 0 for x in ks): continue
            d = (s[0]*ks[0] - z[0]) * inverse_mod(r[0], n) % n
            if all((s[i]*ks[i] - z[i] - r[i]*d) % n == 0 for i in range(t)):
                return True
    return False

def trial(n, t, j, c, M, sd):
    set_random_seed(sd)
    d = ZZ(randint(1, n-1))
    ks = [ZZ(randint(1, M-1)) for _ in range(j)]
    for i in range(j, t):
        ks.append(sum(c[l]*ks[i-j+l] for l in range(j)) % M)
    rs, ss, zs = [], [], []
    for i in range(t):
        rr = ZZ(randint(1, n-1)); zz = ZZ(randint(0, n-1))
        s = (zz + rr*d) * inverse_mod(ks[i] % n, n) % n
        rs.append(rr); ss.append(s); zs.append(zz)
    return attack(n, t, j, c, M, ss, rs, zs)

n = ZZ(next_prime(2**40))
print(f"toy group order n = {n} ({n.nbits()} bits), ZERO nonce leakage", flush=True)
print("Prediction: t* = j+1 information-theoretically (LCG is j=2; measured there: t*=4)", flush=True)
print(f"{'order j':>8} {'coeffs':>24} | " + " ".join(f"t={t}" for t in range(2, 8)), flush=True)
for j, c in [(1, [ZZ(3)]), (2, [ZZ(3), ZZ(5)]), (3, [ZZ(1), ZZ(2), ZZ(3)]),
             (4, [ZZ(1), ZZ(1), ZZ(2), ZZ(5)]), (5, [ZZ(2), ZZ(3), ZZ(5), ZZ(7), ZZ(11)])]:
    M = ZZ(next_prime(2**30))
    row = []
    for t in range(2, 8):
        if t < j + 1:
            row.append(" - ")
            continue
        ok = sum(trial(n, t, j, c, M, sd) for sd in range(8))
        row.append(f"{ok}/8")
    print(f"{j:>8} {str(c):>24} | " + "  ".join(str(x) for x in row), flush=True)
