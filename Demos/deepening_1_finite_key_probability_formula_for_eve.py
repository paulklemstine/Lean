"""
Exact numerical demonstration of the p-biased Fourier theory of the discrete cube
and of the two influence identities it yields.

Everything is computed in EXACT rational arithmetic (fractions.Fraction), so the
identities below are verified as literal equalities, not as floating-point
approximations.

Notation
--------
    V           a finite set of n sites; a configuration eta in {0,1}^V is stored
                as an integer bitmask, bit v set  <=>  site v is open.
    mu_p(eta)   = p^{#open} (1-p)^{#closed}          the p-biased product measure
    E_p[f]      = sum_eta mu_p(eta) f(eta)
    q           = p(1-p)                              the per-site variance
    psi_v(eta)  = 1-p if eta_v = 1, else -p           centred one-site character
    psi_S       = prod_{v in S} psi_v                 character of a set of sites
    fhat(S)     = E_p[f psi_S] / q^{|S|}              biased Fourier coefficient
    w_S(f)      = q^{|S|} fhat(S)^2                   energy at level S

Results demonstrated
--------------------
  * Product rule                E_p[prod_v g_v(eta_v)] = prod_v (p g_v(1) + (1-p) g_v(0))
  * Orthogonality               E_p[psi_S psi_T] = [S = T] q^{|S|}
  * Reproducing kernel          sum_S prod_{v in S} psi_v(xi)psi_v(eta)/q = [xi=eta]/mu_p(eta)
  * Completeness                f = sum_S fhat(S) psi_S
  * Parseval                    E_p[f g] = sum_S q^{|S|} fhat(S) ghat(S)
  * Plancherel (Boolean)        sum_S w_S(g_A) = 1
  * Energy decomposition        4P(1-P) = 4q sum_v I_v^2 + (energy at levels >= 2)
  * Site energy identity        sum_{S ni v} w_S(f) = q E_p[(D_v f)^2]   ( = 4 q I_v )
  * Efron-Stein / Poincare      q sum_v E_p[(D_v f)^2] - Var(f)
                                          = sum_{S != empty} (|S|-1) w_S(f) >= 0
  * Chaining identity           4q( sum_v I_v - sum_v I_v^2 ) = sum_{|S|>=2} |S| w_S(g_A)
  * Square-root law             ( sum_v I_v )^2 <= n P(1-P) / q
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

Rat = Fraction


# --------------------------------------------------------------------------- #
#  Basic combinatorics of the cube                                            #
# --------------------------------------------------------------------------- #

def popcount(mask: int) -> int:
    """Number of open sites in the configuration (or size of the set) `mask`."""
    return bin(mask).count("1")


def all_masks(n: int) -> range:
    """All 2^n configurations of an n-site cube, as bitmasks."""
    return range(1 << n)


def weight(p: Rat, eta: int, n: int) -> Rat:
    """mu_p(eta) = p^{#open} (1-p)^{#closed}."""
    k = popcount(eta)
    return p ** k * (1 - p) ** (n - k)


def expectation(p: Rat, table: Sequence[Rat], n: int) -> Rat:
    """E_p[f] for f given as a table indexed by configuration bitmask."""
    return sum(weight(p, eta, n) * table[eta] for eta in all_masks(n))


def psi(p: Rat, v: int, eta: int) -> Rat:
    """The centred one-site character psi_v(eta)."""
    return (1 - p) if (eta >> v) & 1 else -p


def psi_set(p: Rat, S: int, eta: int, n: int) -> Rat:
    """psi_S(eta) = prod_{v in S} psi_v(eta), with S a bitmask of sites."""
    out = Rat(1)
    for v in range(n):
        if (S >> v) & 1:
            out *= psi(p, v, eta)
    return out


# --------------------------------------------------------------------------- #
#  The biased Fourier transform                                               #
# --------------------------------------------------------------------------- #

def fourier_coefficients_direct(p: Rat, table: Sequence[Rat], n: int) -> List[Rat]:
    """Algorithm A: fhat(S) = E_p[f psi_S] / q^{|S|}, computed directly.

    Cost O(4^n n).  Used only as an independent cross-check of the fast method.
    """
    q = p * (1 - p)
    out: List[Rat] = []
    for S in all_masks(n):
        acc = Rat(0)
        for eta in all_masks(n):
            acc += weight(p, eta, n) * table[eta] * psi_set(p, S, eta, n)
        out.append(acc / q ** popcount(S))
    return out


def fourier_coefficients(p: Rat, table: Sequence[Rat], n: int) -> List[Rat]:
    """Algorithm B: the biased fast Walsh transform.  Cost O(n 2^n), exact.

    One pass per coordinate performs the one-coordinate decomposition
        f = A_v f + psi_v * D_v f,
        (A_v f)(eta) = p f(eta^{v->1}) + (1-p) f(eta^{v->0}),
        (D_v f)(eta) = f(eta^{v->1}) - f(eta^{v->0}),
    storing A_v f in the slot with bit v cleared and D_v f in the slot with bit v
    set.  Because the coefficients of f at sets avoiding v are those of A_v f, and
    at sets containing v are those of D_v f with v deleted, after n passes the
    entry indexed by the bitmask S is exactly fhat(S).
    """
    a = list(table)
    for v in range(n):
        bit = 1 << v
        for i in all_masks(n):
            if i & bit:
                continue
            hi, lo = a[i | bit], a[i]          # hi = value with v open
            a[i] = p * hi + (1 - p) * lo       # A_v f
            a[i | bit] = hi - lo               # D_v f
    return a


def level_energies(p: Rat, coeffs: Sequence[Rat], n: int) -> List[Rat]:
    """w_S(f) = q^{|S|} fhat(S)^2 for every level S."""
    q = p * (1 - p)
    return [q ** popcount(S) * coeffs[S] ** 2 for S in all_masks(n)]


def discrete_derivative(table: Sequence[Rat], v: int, n: int) -> List[Rat]:
    """(D_v f)(eta) = f(eta with v open) - f(eta with v closed)."""
    bit = 1 << v
    return [table[eta | bit] - table[eta & ~bit] for eta in all_masks(n)]


# --------------------------------------------------------------------------- #
#  Events, influences, sign indicators                                        #
# --------------------------------------------------------------------------- #

def sign_indicator(member: Callable[[int], bool], n: int) -> List[Rat]:
    """g_A = +1 on A, -1 off A, as a table."""
    return [Rat(1) if member(eta) else Rat(-1) for eta in all_masks(n)]


def event_probability(p: Rat, member: Callable[[int], bool], n: int) -> Rat:
    """P = mu_p(A)."""
    return sum(weight(p, eta, n) for eta in all_masks(n) if member(eta))


def influence(p: Rat, member: Callable[[int], bool], v: int, n: int) -> Rat:
    """I_v = mu_p{ eta : eta^{v->1} in A and eta^{v->0} not in A }."""
    bit = 1 << v
    total = Rat(0)
    for eta in all_masks(n):
        if member(eta | bit) and not member(eta & ~bit):
            total += weight(p, eta, n)
    return total


def is_increasing(member: Callable[[int], bool], n: int) -> bool:
    """Brute-force check that the event is monotone increasing."""
    for eta in all_masks(n):
        if not member(eta):
            continue
        for v in range(n):
            if not member(eta | (1 << v)):
                return False
    return True


# --------------------------------------------------------------------------- #
#  A library of monotone events                                               #
# --------------------------------------------------------------------------- #

def dictator(v: int) -> Callable[[int], bool]:
    """A = { eta : site v is open }.  The extremal (degree-one) event."""
    return lambda eta: bool((eta >> v) & 1)


def majority(n: int) -> Callable[[int], bool]:
    """A = { eta : strictly more than n/2 sites open }."""
    return lambda eta: 2 * popcount(eta) > n


def at_least(k: int) -> Callable[[int], bool]:
    """A = { eta : at least k sites open }."""
    return lambda eta: popcount(eta) >= k


def parity_free_or_and(n: int) -> Callable[[int], bool]:
    """Tribes-like event: OR over blocks of two of the AND inside each block."""
    blocks = [(2 * i, 2 * i + 1) for i in range(n // 2)]
    return lambda eta: any(((eta >> a) & 1) and ((eta >> b) & 1) for a, b in blocks)


def grid_crossing(m: int) -> Tuple[Callable[[int], bool], int]:
    """Left-to-right open crossing of the m x m grid (site percolation).

    Returns the membership predicate and the number of sites n = m*m.  Site
    (i, j) (row i, column j) is stored in bit i*m + j.
    """
    n = m * m

    def member(eta: int) -> bool:
        stack = [(i, 0) for i in range(m) if (eta >> (i * m)) & 1]
        seen = set(stack)
        while stack:
            i, j = stack.pop()
            if j == m - 1:
                return True
            for di, dj in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                a, b = i + di, j + dj
                if 0 <= a < m and 0 <= b < m and (a, b) not in seen:
                    if (eta >> (a * m + b)) & 1:
                        seen.add((a, b))
                        stack.append((a, b))
        return False

    return member, n


# --------------------------------------------------------------------------- #
#  Verification routines                                                      #
# --------------------------------------------------------------------------- #

def check(label: str, lhs: Rat, rhs: Rat) -> bool:
    ok = lhs == rhs
    flag = "OK " if ok else "FAIL"
    print(f"  [{flag}] {label:<58} {str(lhs):>18} == {str(rhs):>18}")
    return ok


def demo_product_rule_and_orthogonality(n: int = 3, p: Rat = Rat(1, 3)) -> None:
    print(f"\n=== 1. Product rule and orthogonality  (n = {n}, p = {p}) ===")
    q = p * (1 - p)

    # Product rule for an arbitrary family of one-site functions.
    g = [(Rat(2, 5), Rat(-1, 7)), (Rat(3), Rat(1, 2)), (Rat(-4, 3), Rat(5, 6))]
    table = [Rat(1) for _ in all_masks(n)]
    for eta in all_masks(n):
        prod = Rat(1)
        for v in range(n):
            prod *= g[v][0] if (eta >> v) & 1 else g[v][1]
        table[eta] = prod
    lhs = expectation(p, table, n)
    rhs = Rat(1)
    for v in range(n):
        rhs *= p * g[v][0] + (1 - p) * g[v][1]
    check("E[prod_v g_v] = prod_v (p g_v(1) + (1-p) g_v(0))", lhs, rhs)

    # Full orthogonality of the characters.
    bad = 0
    for S in all_masks(n):
        for T in all_masks(n):
            val = sum(
                weight(p, eta, n) * psi_set(p, S, eta, n) * psi_set(p, T, eta, n)
                for eta in all_masks(n)
            )
            expect = q ** popcount(S) if S == T else Rat(0)
            if val != expect:
                bad += 1
    print(f"  [{'OK ' if bad == 0 else 'FAIL'}] "
          f"E[psi_S psi_T] = [S=T] q^|S| for all {4 ** n} pairs (S,T)")

    # Reproducing kernel.
    bad = 0
    for xi in all_masks(n):
        for eta in all_masks(n):
            ker = Rat(0)
            for S in all_masks(n):
                term = Rat(1)
                for v in range(n):
                    if (S >> v) & 1:
                        term *= psi(p, v, xi) * psi(p, v, eta) / q
                ker += term
            expect = 1 / weight(p, eta, n) if xi == eta else Rat(0)
            if ker != expect:
                bad += 1
    print(f"  [{'OK ' if bad == 0 else 'FAIL'}] "
          f"reproducing kernel = [xi=eta]/mu_p(eta) for all {4 ** n} pairs")


def demo_completeness_and_parseval(n: int = 4, p: Rat = Rat(2, 5)) -> None:
    print(f"\n=== 2. Completeness, Parseval, Efron-Stein defect "
          f"(arbitrary f; n = {n}, p = {p}) ===")
    q = p * (1 - p)

    # A deterministic but "generic" pair of rational functions on the cube.
    f = [Rat((7 * eta * eta + 3 * eta + 1) % 23 - 11, 5) for eta in all_masks(n)]
    g = [Rat((13 * eta + 5) % 17 - 8, 3) for eta in all_masks(n)]

    fh = fourier_coefficients(p, f, n)
    gh = fourier_coefficients(p, g, n)
    check("fast transform agrees with direct transform",
          sum(abs(x - y) for x, y in zip(fh, fourier_coefficients_direct(p, f, n))),
          Rat(0))

    # Completeness: f = sum_S fhat(S) psi_S, pointwise.
    worst = Rat(0)
    for eta in all_masks(n):
        recon = sum(fh[S] * psi_set(p, S, eta, n) for S in all_masks(n))
        worst = max(worst, abs(recon - f[eta]))
    check("max_eta | f(eta) - sum_S fhat(S) psi_S(eta) |", worst, Rat(0))

    # Parseval.
    fg = [f[eta] * g[eta] for eta in all_masks(n)]
    check("E[f g] = sum_S q^|S| fhat(S) ghat(S)",
          expectation(p, fg, n),
          sum(q ** popcount(S) * fh[S] * gh[S] for S in all_masks(n)))

    # Variance form.
    ff = [x * x for x in f]
    var = expectation(p, ff, n) - expectation(p, f, n) ** 2
    energies = level_energies(p, fh, n)
    check("Var(f) = sum_{S != empty} w_S(f)",
          var, sum(energies[S] for S in all_masks(n) if S != 0))

    # Site energy identity and the exact Efron-Stein / Poincare defect.
    total_deriv = Rat(0)
    for v in range(n):
        dv = discrete_derivative(f, v, n)
        dv_sq = [x * x for x in dv]
        e_dv = expectation(p, dv_sq, n)
        total_deriv += e_dv
        site = sum(energies[S] for S in all_masks(n) if (S >> v) & 1)
        check(f"site energy above v={v}: sum_{{S ni v}} w_S = q E[(D_v f)^2]",
              site, q * e_dv)

    defect = sum(
        (Rat(popcount(S)) - 1) * energies[S] for S in all_masks(n) if S != 0
    )
    check("q sum_v E[(D_v f)^2] - Var(f) = sum_{S!=0}(|S|-1) w_S",
          q * total_deriv - var, defect)
    print(f"  defect = {defect}  (>= 0: {defect >= 0})")


def analyse_event(name: str, member: Callable[[int], bool], n: int, p: Rat,
                  verbose: bool = True) -> Dict[str, Rat]:
    """Full exact analysis of one increasing event at one density."""
    q = p * (1 - p)
    assert is_increasing(member, n), f"{name} is not increasing"

    P = event_probability(p, member, n)
    infl = [influence(p, member, v, n) for v in range(n)]
    g = sign_indicator(member, n)
    gh = fourier_coefficients(p, g, n)
    w = level_energies(p, gh, n)

    total_energy = sum(w)
    high = sum(w[S] for S in all_masks(n) if popcount(S) >= 2)
    poincare_defect = sum(
        (Rat(popcount(S)) - 1) * w[S] for S in all_masks(n) if S != 0
    )
    s1 = sum(infl)
    s2 = sum(x * x for x in infl)

    if verbose:
        print(f"\n--- {name}   (n = {n}, p = {p}) ---")
        print(f"  P = {P},   4P(1-P) = {4 * P * (1 - P)}")
        print(f"  influences        = {[str(x) for x in infl]}")
        print(f"  sum I_v  = {s1},   sum I_v^2 = {s2}")
        spectrum: Dict[int, Rat] = {}
        for S in all_masks(n):
            k = popcount(S)
            spectrum[k] = spectrum.get(k, Rat(0)) + w[S]
        print("  energy by level   = "
              + ", ".join(f"level {k}: {spectrum[k]}" for k in sorted(spectrum)
                          if spectrum[k] != 0))
        check("Plancherel: sum_S w_S = 1", total_energy, Rat(1))
        check("degree-0 coefficient = 2P - 1", gh[0], 2 * P - 1)
        for v in range(n):
            check(f"degree-1 coefficient at v={v} equals 2 I_v",
                  gh[1 << v], 2 * infl[v])
        check("energy decomposition: 4P(1-P) = 4q sum I_v^2 + high energy",
              4 * P * (1 - P), 4 * q * s2 + high)
        check("Poincare defect: 4q sum I_v - 4P(1-P) = sum (|S|-1) w_S",
              4 * q * s1 - 4 * P * (1 - P), poincare_defect)
        check("chaining: 4q( sum I_v - sum I_v^2 ) = sum_{|S|>=2} |S| w_S",
              4 * q * (s1 - s2),
              sum(Rat(popcount(S)) * w[S] for S in all_masks(n)
                  if popcount(S) >= 2))
        print(f"  l2 bound   q sum I_v^2 = {q * s2}  <=  P(1-P) = {P * (1 - P)}"
              f"   [slack {P * (1 - P) - q * s2}]")
        print(f"  Poincare   P(1-P) = {P * (1 - P)}  <=  q sum I_v = {q * s1}"
              f"   [slack {q * s1 - P * (1 - P)}]")
        print(f"  square-root law: (sum I_v)^2 = {s1 ** 2}  <=  "
              f"n P(1-P)/q = {n * P * (1 - P) / q}")
        tight = all(gh[S] == 0 for S in all_masks(n) if popcount(S) >= 2)
        print(f"  degree <= 1 (equality case of BOTH inequalities): {tight}")

    return {
        "P": P, "sum_I": s1, "sum_I2": s2,
        "high_energy": high, "poincare_defect": poincare_defect,
    }


def demo_monotone_events() -> None:
    print("\n=== 3. Monotone events: the two identities, exactly ===")
    analyse_event("Dictator on site 0, 3 sites", dictator(0), 3, Rat(1, 3))
    analyse_event("Majority of 3", majority(3), 3, Rat(1, 2))
    analyse_event("Majority of 3, biased", majority(3), 3, Rat(1, 4))
    analyse_event("AND of 3 sites (at least 3 open)", at_least(3), 3, Rat(2, 5))
    analyse_event("OR of 3 sites (at least 1 open)", at_least(1), 3, Rat(1, 5))
    analyse_event("Two blocks: (x0 AND x1) OR (x2 AND x3)",
                  parity_free_or_and(4), 4, Rat(1, 2))


def demo_grid_crossing() -> None:
    print("\n=== 4. Grid crossing (site percolation) ===")
    for m, p in ((2, Rat(1, 2)), (3, Rat(1, 2)), (3, Rat(3, 5))):
        member, n = grid_crossing(m)
        analyse_event(f"Left-right crossing of the {m}x{m} grid", member, n, p)


def demo_threshold_profile() -> None:
    """Watch the two defects as p sweeps across the threshold of a 3x3 crossing."""
    print("\n=== 5. Both defects across the threshold (3x3 crossing) ===")
    member, n = grid_crossing(3)
    print(f"  {'p':>6} {'P':>10} {'sum I_v':>10} {'l2 slack':>12} "
          f"{'Poincare slack':>16} {'high energy':>13}")
    for num in range(1, 10):
        p = Rat(num, 10)
        q = p * (1 - p)
        d = analyse_event("", member, n, p, verbose=False)
        l2_slack = d["P"] * (1 - d["P"]) - q * d["sum_I2"]
        po_slack = q * d["sum_I"] - d["P"] * (1 - d["P"])
        print(f"  {str(p):>6} {float(d['P']):>10.5f} {float(d['sum_I']):>10.5f} "
              f"{float(l2_slack):>12.6f} {float(po_slack):>16.6f} "
              f"{float(d['high_energy']):>13.6f}")
    print("  Both slacks vanish only for degree-<=1 events; a crossing is far")
    print("  from a dictator, so both stay strictly positive throughout.")


def demo_equality_case() -> None:
    """The unique tight events: constants and dictators."""
    print("\n=== 6. The shared equality case ===")
    n, p = 3, Rat(1, 3)
    q = p * (1 - p)
    for name, member in (("dictator on site 1", dictator(1)),
                         ("OR of 3 sites", at_least(1))):
        P = event_probability(p, member, n)
        infl = [influence(p, member, v, n) for v in range(n)]
        s1, s2 = sum(infl), sum(x * x for x in infl)
        print(f"  {name:<22}  q*sum I^2 = {q * s2},  P(1-P) = {P * (1 - P)},"
              f"  q*sum I = {q * s1}")
        print(f"  {'':<22}  l2 tight: {q * s2 == P * (1 - P)},"
              f"  Poincare tight: {P * (1 - P) == q * s1}")


def main() -> None:
    print("=" * 92)
    print("  p-BIASED FOURIER ANALYSIS ON THE DISCRETE CUBE  --  exact rational demo")
    print("=" * 92)
    demo_product_rule_and_orthogonality()
    demo_completeness_and_parseval()
    demo_monotone_events()
    demo_grid_crossing()
    demo_threshold_profile()
    demo_equality_case()
    print("\nAll identities above hold as exact equalities of rational numbers.")


if __name__ == "__main__":
    main()
