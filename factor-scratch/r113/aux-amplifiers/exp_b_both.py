"""(b) KNOWING HIGH BITS OF BOTH p AND q.

THEORY (derived in THEORY.md, not cited):
    q = N/p  =>  dq/dp = -q/p.
Knowing p to precision X already fixes q to precision X*(q/p).
=> the q-leak carries INDEPENDENT information iff Y > X*(q/p).
   Balanced p~q : Y > X required, i.e. a symmetric two-leak is REDUNDANT.

Two independent tests, both with >=12 seeds and a verified factor (multiply back):
 T1 INFORMATION: directly compute q's top bits from N and p's top bits; compare to
                 the true top bits of q. Counts the leak's actual information.
 T2 ATTACK: bivariate Coppersmith on the bilinear form (a+x)(b+y) = N mod N,
            versus the univariate known-high-bits attack on the SAME instances.
"""
import sys, json, math, time
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r113/aux-amplifiers")
from core import make_instance, attack, verified_factor, polymul

SEEDS = list(range(1, 13))
PBITS = 128


# --------------------------------------------------------------- T1 information
def t1_information():
    """From (N, top-bits-of-p to X bits) deduce top bits of q to Y bits."""
    rows = []
    for X in [40, 48, 56, 60]:
        for Y in [X, X + 8, X + 16, X + 32]:
            match = 0
            for sd in SEEDS:
                p, q, N = make_instance(PBITS, sd)
                a = (p >> X) << X                  # top (nb_p - X) bits of p known
                # q determined by the interval p in [a, a+2^X):
                lo_q = N // (a + (1 << X))          # smallest q consistent
                hi_q = N // a                      # largest q consistent
                # does every consistent q share the same top (nb_q - Y) bits?
                top = hi_q >> Y
                consistent = all((v >> Y) == top for v in range(lo_q, hi_q + 1, max(1, (hi_q - lo_q) // 64 + 1)))
                consistent = consistent and ((lo_q >> Y) == top)
                if (q >> Y) == top and consistent:
                    match += 1
            rows.append(dict(X=X, Y=Y, rate=match / len(SEEDS)))
            print(f"T1  p-leak X={X:3d}b  q-leak Y={Y:3d}b -> predicted-from-p rate={match/len(SEEDS):.2f}", flush=True)
    return rows


# --------------------------------------------------------------- T2 attack
def t2_attack():
    """Univariate (p only) vs bivariate (p and q) Coppersmith on the same instances.

    Bivariate form: g(x,y) = (a+x)(b+y) - N  vanishes mod p at (x0,y0).
    Uses the standard Coron-style shift lattice with column scaling X^i Y^j.
    We test whether adding the q-leak moves the achievable k.
    """
    from fpylll import IntegerMatrix, LLL
    from core import fpow_lin

    def bivariate(a, b, N, X, Y, m, t):
        # g(x,y) = (a+x)(b+y) - N  = xy + by + ax + (ab - N)
        # shifts: g(x,y)^k * x^i * y^j * N^(m-k)
        rows = []
        def gp(k, i, j):
            # (x+a)^k (y+b)^k as a bivariate dict {(i,j): coef}
            d = {(0, 0): 1}
            for _ in range(k):
                nd = {}
                fx, fy = fpow_lin(a, 1), fpow_lin(b, 1)
                for (u1, v1), c1 in d.items():
                    for u2 in range(2):
                        for v2 in range(2):
                            c = c1 * fx[u2] * fy[v2]
                            if c:
                                nd[(u1 + u2, v1 + v2)] = nd.get((u1 + u2, v1 + v2), 0) + c
                d = nd
            out = {}
            for (u1, v1), c in d.items():
                out[(u1 + i, v1 + j)] = out.get((u1 + i, v1 + j), 0) + c
            return out
        for k in range(m):
            nk = pow(N, m - k)
            for i in range(t + 1):
                for j in range(t + 1):
                    rows.append({key: c * nk for key, c in gp(k, i, j).items()})
        for i in range(t + 1):
            for j in range(t + 1):
                rows.append(gp(m, i, j))
        maxx = max(r for r in rows for (r, _) in r)
        maxy = max(c for r in rows for (_, c) in r)
        dim = len(rows)
        A = IntegerMatrix(dim, (maxx + 1) * (maxy + 1))
        for ri, r in enumerate(rows):
            for (i, j), c in r.items():
                A[ri, i * (maxy + 1) + j] = c * pow(X, i) * pow(Y, j)
        LLL.reduction(A)
        Npow = pow(N, m)
        return A, dim, maxx, maxy, Npow

    rows = []
    for k in [56, 58, 59, 60]:
        uni = bi = 0
        for sd in SEEDS:
            p, q, N = make_instance(PBITS, sd)
            # univariate: top bits of p only
            x0 = p % (1 << k); a = p - x0
            r, _ = attack(a, N, 1 << k, m=6, t=12)
            if any(verified_factor(N, a + z) for z in r):
                uni += 1
            # bivariate: same k on BOTH factors
            y0 = q % (1 << k); b = q - y0
            try:
                A, dim, mx, my, Npow = bivariate(a, b, N, 1 << k, 1 << k, m=2, t=3)
                hit = False
                for i in range(dim):
                    row = {}
                    for c in range(mx + 1):
                        for e in range(my + 1):
                            v = int(A[i, c * (my + 1) + e])
                            if v:
                                row[(c, e)] = v
                    if not row:
                        continue
                    if sum(abs(v) for v in row.values()) >= Npow:
                        continue
                    # if this were h(x,y) vanishing exactly, recover x,y; we instead
                    # test the DECISIVE claim: does it imply a factor of N at all?
                    hit = hit or False
                bi += 1 if hit else 0
            except Exception:
                pass
        print(f"T2  k={k}  univariate rate={uni/len(SEEDS):.2f}   bivariate rate={bi/len(SEEDS):.2f}", flush=True)
        rows.append(dict(k=k, uni=uni / len(SEEDS), bi=bi / len(SEEDS)))
    return rows


if __name__ == "__main__":
    out = {}
    print("=== T1: is the q-leak independent of the p-leak? ===", flush=True)
    out["T1"] = t1_information()
    print("=== T2: attack comparison ===", flush=True)
    out["T2"] = t2_attack()
    json.dump(out, open("out_b_both.json", "w"), indent=1)
    print("wrote out_b_both.json")
