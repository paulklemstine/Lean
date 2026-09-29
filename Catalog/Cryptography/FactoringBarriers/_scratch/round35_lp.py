import itertools
import sympy as sp

x, y, V = sp.symbols('x y V', real=True)

# ---- Harvey arXiv:2010.05450, Prop 4.2 + final cost combination ----------
#   s = O(N^{1/2}/(r^{1/2} m) + r lg r)
#   total = O(s lg^3 N + m lg^2 N + r lg^3 N lg lg N)
# Exponents of N, with X = log_N r, Y = log_N m:
F1 = sp.Rational(1, 2) - x / 2 - y   # interior   N^{1/2}/(r^{1/2} m)
F2 = x                             # r-leg      r
F3 = y                             # m-LEG      m


def lin(t):
    """(coef_x, coef_y, const) of the affine form t."""
    p = sp.Poly(sp.expand(t), x, y)
    return p.coeff_monomial(x), p.coeff_monomial(y), p.coeff_monomial(1)


def minmax(terms, label):
    """Exact min of max(terms) over x,y >= 0, by active-set enumeration
    (active set = some terms tight, plus optionally a non-negativity
    constraint x=0 or y=0 tight)."""
    best = None
    n = len(terms)
    for k in range(1, n + 1):
        for S in itertools.combinations(range(n), k):
            for bnd in (None, x, y):  # None | x=0 | y=0
                eqs = [sp.Eq(terms[i], V) for i in S]
                if bnd is not None:
                    eqs = eqs + [sp.Eq(bnd, 0)]
                appearing = set()
                for i in S:
                    cx, cy, _ = lin(terms[i])
                    if cx != 0:
                        appearing.add(x)
                    if cy != 0:
                        appearing.add(y)
                unk = sorted(appearing | {V}, key=lambda e: (e != V, e != x, e != y))
                try:
                    sols = sp.solve(eqs, unk, dict=True)
                except Exception:
                    continue
                for s in sols:
                    xv, yv, vv = s.get(x, 0), s.get(y, 0), s.get(V)
                    if vv is None:
                        continue
                    xv, yv, vv = (sp.nsimplify(sp.simplify(e)) for e in (xv, yv, vv))
                    if any(e.free_symbols for e in (xv, yv, vv)):
                        continue
                    if bool(xv < 0) or bool(yv < 0) or bool(vv < 0):
                        continue
                    if any(bool(sp.simplify(t.subs({x: xv, y: yv}) - vv) > 0) for t in terms):
                        continue
                    if best is None or vv < best[0]:
                        best = (vv, xv, yv)
    if best is None:
        print(f"{label:34s} *** LP DEGENERATE (optimum on a ray, not attained) ***")
    else:
        print(f"{label:34s} min max = {best[0]}   at  X=log_N r = {best[1]},  Y=log_N m = {best[2]}")
    return best


print("=== DELETE-A-TERM LP on Harvey's 3-term minimax (all numbers = exponents of N) ===")
minmax([F1, F2, F3], "baseline (all three)")
minmax([F1, F2], "delete m-LEG  (f3 free)")
minmax([F2, F3], "delete INTERIOR (f1 free)")
minmax([F1, F3], "delete r-leg")
print()
print("=== Is the m-LEG ACTIVE at the optimum?  (round-34 slack-constraint lemma) ===")
xo = sp.Rational(1, 5)
for nm, f in [("f1 interior", F1), ("f2 r-leg", F2), ("f3 m-LEG", F3)]:
    v = sp.simplify(f.subs({x: xo, y: xo}))
    print(f"   at X=Y=1/5:  {nm:12s} = {v}   ACTIVE(==1/5)? {v == xo}")
print()
print("=== CONSERVATION LAW: the search pool ===")
print("   F1 + F3  (exponent of the pool N^{1/2}/r^{1/2}) =",
      sp.simplify((F1 + F3).subs(x, x)), "  <- INDEPENDENT of Y (=m).")
print("   => max(F1,F3) >= N^{1/4} r^{-1/4}:  the two-sided-search / meet-in-the-middle floor.")
minmax([sp.Rational(1, 4) - x / 4, x], "PERFECT (oracle, free) m-leg")
print("   ==> even a COST-FREE m-leg reproduces 1/5 EXACTLY. No m-splitting scheme beats it.")
print()
print("=== MULTI-LEVEL PENALTY on a split of the pool (Cauchy-Schwarz) ===")
S = sp.Symbol('S', positive=True)
for th in [sp.Rational(1, 2), sp.Rational(1, 5), sp.Rational(1, 100)]:
    b = sp.simplify(2 * sp.sqrt(S) * (sp.sqrt(th) + sp.sqrt(1 - th)))
    print(f"   k=2, theta={str(th):6s}: min(L+T) = {sp.nsimplify(sp.simplify(b/sp.sqrt(S)))}*sqrt(S)"
          f"   ratio to uniform-step = {sp.nsimplify(sp.simplify(b/(2*sp.sqrt(S))))}")
print("   k=1 (uniform step = Harvey): 2*sqrt(S), ratio 1.  Multi-level is STRICTLY WORSE.")
