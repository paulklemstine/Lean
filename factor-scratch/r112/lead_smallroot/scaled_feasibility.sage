# CORRECTED small-root feasibility probe.
#
# My first version evaluated each shift g at the true root and compared to the
# modulus, and reported "INFEASIBLE everywhere" -- including at alpha=0.05
# where the attack demonstrably WORKS. So that measurement was wrong.
#
# The error: the lattice does NOT need g(x0,y0,z0,w0) < modular. It needs the
# SCALED coefficient vector to be small. create_lattice() sets
#     L[row,col] = g.monomial_coefficient(m) * monomial(*bounds)
# so the shift is evaluated with the monomial replaced by its value at the BOUNDS
# (X,Y,Z,W), i.e. it measures |coefficient| * X^a Y^b Z^c W^d. That is the
# quantity the LLL size analysis bounds.
#
# So the right probe is: for the row that should carry the solution, is
#     sum_col (scaled coeff)^2  <  modular^2 ?
# i.e. is the scaled shift actually short?
_g = globals()
_g['__name__'] = 'gifp_mod'
exec(compile(open('/home/raver1975/lean/Experiments/UMWWindow/gifp_ref/gifp.sage').read(), 'gifp.sage', 'exec'), _g)
_g['__name__'] = '__main__'

n = 200
b1v, b2v = RR(0.1), RR(0.15)


def q(v):
    return float(ZZ(round(v * n)) / n)


def probe(alpha, gamma, m=4, seed=424242):
    alpha, gamma = q(alpha), q(gamma)
    if not (alpha + gamma + 0.15) < 1:
        return ("infeasible_budget", None)
    if (n - alpha*n - gamma*n - 0.15*n) < 4 or (n - alpha*n - gamma*n - 0.1*n) < 4:
        return ("no_headroom", None)
    gen = generate_gifp_instance(n, RR(alpha), RR(gamma), b1v, RR(0.15), seed, max_attempts=10)
    if gen is None:
        return ("gen_none", None)
    N1_list, N2_list, share, ds = gen
    p1, q1, N1 = N1_list
    p2, q2, N2 = N2_list
    x0, y0, z0, w0 = ds

    pr = ZZ["x", "y", "z", "w"]
    x, y, z, w = pr.gens()
    f = x*z + 2**(int(0.15*n) + int(gamma*n))*y*z + N2
    X = Integer(2 ** int(0.15*n))
    Y = Integer(2 ** int(n - alpha*n - gamma*n - 0.1*n))
    Z = Integer(2 ** int(alpha*n))
    W = Integer(2 ** int(n - alpha*n))
    M = Integer(2 ** int(0.15*n - 0.1*n))
    t = round((1 - sqrt(RR(alpha)))*m)
    s = round(sqrt(RR(alpha))*m)
    modular = M**m * N1**t
    if gcd(N2, modular) != 1:
        return ("noninvertible", None)
    N2inv = inverse_mod(N2, modular)
    qr = pr.quotient(z*w - N2)

    # The target row is the one that vanishes at the true root: take the shift
    # with highest f-power and evaluate the SCALED norm of the row that contains
    # the solution's monomial. A cheap faithful proxy: for EVERY shift, compute
    # the scaled coefficient vector's Euclidean norm and report the SMALLEST
    # norm among shifts -- the true solution must appear as a short combination.
    bounds = [X, Y, Z, W]
    shifts = []
    for ii in range(m+1):
        for jj in range(m-ii+1):
            g = (y*z)**jj * w**s * f**ii * M**(m-ii) * N1**max(t-ii, 0) * N2inv**min(ii+jj, s)
            g = qr(g).lift()
            shifts.append(eliminate_N2(g, modular))

    monos = set()
    for sh in shifts:
        monos.update(sh.monomials())
    monos = sorted(monos)
    # scaled norm of each shift's coefficient row
    norms = []
    for sh in shifts:
        s2 = 0
        for m_ in monos:
            c = sh.monomial_coefficient(m_)
            if c:
                s2 += int((c * m_(*bounds))**2)
        norms.append((s2.bit_length(), sh))
    norms.sort(key=lambda z: z[0])
    shortest_bits = norms[0][0]
    mod_bits = int(modular.nbits())
    # reconstruct_polynomials drops rows with norm^2 * w >= modulus^2, i.e.
    # norm ~ modular. Shortest must be well under.
    return ("ok", {"mod_bits": mod_bits, "shortest_shift_bits": shortest_bits,
                   "lattice_dim": (len(shifts), len(monos)),
                   "ratio_pct": round(100.0*shortest_bits/mod_bits, 1)})


print("Scaled-norm feasibility: is the shortest shift row actually short?")
print("('ratio' = shortest shift bits / modulus bits; LLL needs this < 100)\n")
print("%-6s %-7s %-10s %-13s %-9s %-8s  %s" % ("alpha", "gamma", "mod_bits", "shortest", "ratio%", "dim", "verdict"))
for alpha in [0.05, 0.10, 0.15, 0.20]:
    for gamma in [0.50, 0.60]:
        st, info = probe(alpha, gamma)
        if st != "ok":
            print("%-6.2f %-7.2f  %s" % (alpha, gamma, st))
            continue
        v = "root COULD be short" if info["ratio_pct"] < 100 else "root NOT short (infeasible)"
        print("%-6.2f %-7.2f %-10d %-13d %-9s %-8s %s" % (
            alpha, gamma, info["mod_bits"], info["shortest_shift_bits"],
            info["ratio_pct"], "%dx%d" % info["lattice_dim"], v))