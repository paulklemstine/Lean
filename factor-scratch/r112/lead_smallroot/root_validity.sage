# Is the GIFP wall a CONSTRUCTION failure or a PROBLEM-INFEASIBILITY?
#
# The r111c wall (alpha >= 0.15 fails at every feasible gamma, m) has two very
# different explanations:
#   (A) The construction is fine but the LATTICE fails to find the short vector.
#   (B) The TRUE SOLUTION IS NOT ACTUALLY A SMALL ROOT at alpha >= 0.15, i.e. the
#       problem instance itself is outside the regime the bound describes, so no
#       lattice could succeed.
#
# (B) is checkable DIRECTLY and cheaply, with no lattice at all. The bound's
# proof needs each shifted polynomial to be small at (x0,y0,z0,w0). If some
# shift is already >= the modulus there, the instance is infeasible by
# construction and the "wall" is a statement about the PARAMETERIZATION, not a
# weakness of the attack.
#
# This needs no reference implementation, so it is an independent check.
_g = globals()
_g['__name__'] = 'gifp_mod'
exec(compile(open('/home/raver1975/lean/Experiments/UMWWindow/gifp_ref/gifp.sage').read(), 'gifp.sage', 'exec'), _g)
_g['__name__'] = '__main__'

n = 200
b1, b2 = 0.10, 0.15


def q(v):
    """snap to the 1/n grid or the generator returns None for every seed"""
    return float(ZZ(round(v * n)) / n)


def check(alpha, gamma, m=4):
    alpha, gamma = q(alpha), q(gamma)
    if not (alpha + gamma + b2) < 1:
        return ("infeasible_budget", None)
    top2 = n - alpha * n - gamma * n - b2 * n
    top1 = n - alpha * n - gamma * n - b1 * n
    if top2 < 4 or top1 < 4:
        return ("no_headroom", None)

    gen = generate_gifp_instance(n, RR(alpha), RR(gamma), RR(b1), RR(b2),
                                 424242, max_attempts=10)
    if gen is None:
        return ("gen_none", None)
    N1_list, N2_list, share, ds = gen
    p1, q1, N1 = N1_list
    p2, q2, N2 = N2_list
    x0, y0, z0, w0 = ds

    X = Integer(2 ** int(b2 * n))
    Y = Integer(2 ** int(n - alpha * n - gamma * n - b1 * n))
    Z = Integer(2 ** int(alpha * n))
    W = Integer(2 ** int(n - alpha * n))
    M = Integer(2 ** int(b2 * n - b1 * n))
    t = round((1 - sqrt(RR(alpha))) * m)
    s = round(sqrt(RR(alpha)) * m)
    modular = M**m * N1**t

    # For each shift, how big is it at the TRUE root vs the modulus?
    # This is the quantity the size analysis must keep < modular.
    pr = ZZ["x", "y", "z", "w"]
    x, y, z, w = pr.gens()
    f = x * z + 2**(int(b2 * n) + int(gamma * n)) * y * z + N2
    qr = pr.quotient(z * w - N2)
    if gcd(N2, modular) != 1:
        return ("noninvertible", None)
    N2inv = inverse_mod(N2, modular)

    worst = 0
    ratios = []
    for ii in range(m + 1):
        for jj in range(m - ii + 1):
            g = (y * z)**jj * w**s * f**ii * M**(m - ii) * N1**max(t - ii, 0) * N2inv**min(ii + jj, s)
            g = qr(g).lift()
            g = eliminate_N2(g, modular)
            # exact value at the true root, over Z
            v = abs(ZZ(g(x0, y0, z0, w0)))
            worst = max(worst, v)
            ratios.append((ii, jj, int(v.nbits()) if v else 0))
    mb = int(modular.nbits())
    return ("ok", {"modular_bits": mb, "worst_shift_bits": int(worst.nbits()) if worst else 0,
                    "margin_bits": mb - (int(worst.nbits()) if worst else 0),
                    "top1": int(top1), "top2": int(top2)})


print("Does the TRUE solution remain a small root as alpha grows?")
print("(if worst_shift_bits >= modular_bits the instance is infeasible by")
print(" construction -- no lattice could ever find it)\n")
print("%-6s %-7s %-9s %-9s %-9s %-8s  %s" % ("alpha", "gamma", "mod_bits", "worst_bits", "margin", "top1/2", "verdict"))
for alpha in [0.05, 0.10, 0.15, 0.20]:
    for gamma in [0.50, 0.60]:
        st, info = check(alpha, gamma)
        if st != "ok":
            print("%-6.2f %-7.2f  %s" % (alpha, gamma, st))
            continue
        verdict = "INFEASIBLE (root not small)" if info["margin_bits"] <= 0 else "feasible root"
        print("%-6.2f %-7.2f %-9d %-9d %-9d %-8s %s" % (
            alpha, gamma, info["modular_bits"], info["worst_shift_bits"],
            info["margin_bits"], "%d/%d" % (info["top1"], info["top2"]), verdict))