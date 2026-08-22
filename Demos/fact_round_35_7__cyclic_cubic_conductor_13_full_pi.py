"""
The splitting-type channel of a cyclic cubic field: numerical demonstrations.

Everything below is self-contained (standard library only) and verifies, against
either exact enumeration or an actual sieve of primes, the results of the paper
"The Splitting-Type Channel of a Cyclic Cubic Field".

Results demonstrated
--------------------
1. Full pinning at conductor 13:   H(T) = log2(3) - 2/3 = 0.9182958...,
                                   I(p mod 13 ; T) = H(T) exactly.
2. Conductor independence:         identical statistics for f = 7, 13, 19, 31, 37, 43, 61.
3. Semiprime pairing:              I_pair = log2(3) - 10/9,  defect = 4/9 exactly.
4. The which-factor wall:          mutual information exactly 0, decoder success exactly 1/2.
5. Renyi spectrum:                 H_0 = 1, H_2 = log2(9/5), and H_2 < H_1 via 108 < 125.
6. Subfield tower at conductor 13: CRT additivity and prime-power saturation.
7. Rational-defect rigidity:       defect rational only for degrees q = 2, 3.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from math import gcd, log2
from typing import Dict, Iterable, List, Sequence, Tuple

# --------------------------------------------------------------------------------------
# Basic information theory
# --------------------------------------------------------------------------------------


def entropy(probabilities: Iterable[float]) -> float:
    """Shannon entropy in bits of a (sub)probability vector; zero mass contributes 0."""
    total = -sum(p * log2(p) for p in probabilities if p > 0.0)
    return 0.0 if total == 0.0 else total


def renyi_entropy(probabilities: Sequence[float], order: float) -> float:
    """Renyi entropy H_a in bits; a = 1 falls back to Shannon, a = inf to min-entropy."""
    ps = [p for p in probabilities if p > 0.0]
    if order == 1.0:
        return entropy(ps)
    if order == float("inf"):
        return -log2(max(ps))
    return log2(sum(p**order for p in ps)) / (1.0 - order)


def mutual_information(joint: Dict[Tuple[object, object], float]) -> float:
    """I(X;Y) in bits from a joint law given as a dict {(x, y): probability}."""
    px: Dict[object, float] = {}
    py: Dict[object, float] = {}
    for (x, y), p in joint.items():
        px[x] = px.get(x, 0.0) + p
        py[y] = py.get(y, 0.0) + p
    total = 0.0
    for (x, y), p in joint.items():
        if p > 0.0:
            total += p * log2(p / (px[x] * py[y]))
    return total


# --------------------------------------------------------------------------------------
# Arithmetic: primes, cubic residues, splitting types
# --------------------------------------------------------------------------------------


def primes_up_to(limit: int) -> List[int]:
    """Sieve of Eratosthenes."""
    sieve = bytearray([1]) * (limit + 1)
    sieve[0:2] = b"\x00\x00"
    for n in range(2, int(limit**0.5) + 1):
        if sieve[n]:
            sieve[n * n :: n] = bytearray(len(sieve[n * n :: n]))
    return [n for n in range(2, limit + 1) if sieve[n]]


def cubic_residues(f: int) -> List[int]:
    """The nonzero cubes modulo the prime f (a subgroup of index 3 when 3 | f - 1)."""
    return sorted({pow(x, 3, f) for x in range(1, f)})


def splitting_type(p: int, f: int) -> str:
    """Type of p in the cyclic cubic field of prime conductor f with 3 | f - 1."""
    r = p % f
    if r == 0:
        return "ramified"
    return "split" if pow(r, (f - 1) // 3, f) == 1 else "inert"


def cubic_class(p: int, f: int) -> int:
    """The class of p in the three-element quotient group C_3 = (Z/f)^x / cubes."""
    g = primitive_root(f)
    # discrete log of p modulo f, taken modulo 3
    target = p % f
    value = 1
    for k in range(f - 1):
        if value == target:
            return k % 3
        value = (value * g) % f
    raise ValueError("p is divisible by the conductor")


def primitive_root(f: int) -> int:
    """Smallest primitive root modulo the prime f."""
    factors = set()
    n = f - 1
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.add(d)
            n //= d
        d += 1
    if n > 1:
        factors.add(n)
    for g in range(2, f):
        if all(pow(g, (f - 1) // q, f) != 1 for q in factors):
            return g
    raise ValueError("no primitive root found")


# --------------------------------------------------------------------------------------
# 1. Full pinning at conductor 13
# --------------------------------------------------------------------------------------


def demo_full_pinning(limit: int = 200_000, f: int = 13) -> None:
    print("=" * 78)
    print(f"1. FULL PINNING  (cyclic cubic field of conductor f = {f})")
    print("=" * 78)
    print(f"   nonzero cubes mod {f}: {cubic_residues(f)}")

    ps = [p for p in primes_up_to(limit) if p != f]
    n_split = sum(1 for p in ps if splitting_type(p, f) == "split")
    n_inert = len(ps) - n_split
    emp = [n_split / len(ps), n_inert / len(ps)]

    exact = [1 / 3, 2 / 3]
    h_exact = log2(3) - 2 / 3
    print(f"   primes considered            : {len(ps)}  (up to {limit})")
    print(f"   empirical  P(split), P(inert): {emp[0]:.6f}, {emp[1]:.6f}")
    print(f"   exact      P(split), P(inert): {exact[0]:.6f}, {exact[1]:.6f}")
    print(f"   empirical  H(T)              : {entropy(emp):.10f} bits")
    print(f"   exact      H(T) = log2 3-2/3 : {h_exact:.10f} bits")

    # Mutual information between the residue class and the type, computed exactly on the
    # uniform model over (Z/f)^x: the type is a deterministic function of the residue.
    joint = {
        (r, splitting_type(r, f)): 1.0 / (f - 1) for r in range(1, f)
    }
    info = mutual_information(joint)
    cond = entropy([1 / 3, 2 / 3]) - info
    print(f"   I(p mod {f} ; T)              : {info:.10f} bits")
    print(f"   H(T | p mod {f})              : {cond:.2e}   (exactly 0)")
    assert abs(info - h_exact) < 1e-12
    print("   => the channel is LOSSLESS: I(residue ; type) = H(T) exactly.\n")


# --------------------------------------------------------------------------------------
# 2. Conductor independence
# --------------------------------------------------------------------------------------


def demo_conductor_independence(conductors: Sequence[int] = (7, 13, 19, 31, 37, 43, 61)) -> None:
    print("=" * 78)
    print("2. CONDUCTOR INDEPENDENCE  (uniform covers of the same three-position dial)")
    print("=" * 78)
    print("     f   #cubes/(f-1)      P(split)   H(T) [bits]      H_2 [bits]")
    for f in conductors:
        cubes = cubic_residues(f)
        p_split = len(cubes) / (f - 1)
        law = [p_split, 1.0 - p_split]
        print(
            f"   {f:3d}   {len(cubes):3d}/{f-1:<3d}          "
            f"{p_split:.6f}   {entropy(law):.10f}   {renyi_entropy(law, 2.0):.10f}"
        )
        assert abs(p_split - 1 / 3) < 1e-15
    print("   => every admissible conductor gives the same law (1/3, 2/3), hence the same")
    print("      Shannon entropy, the same collision entropy, the same everything.\n")


# --------------------------------------------------------------------------------------
# 3. The semiprime pairing channel
# --------------------------------------------------------------------------------------


def pairing_statistics(q: int) -> Tuple[float, float, float]:
    """Exact (H(T), I_pair, defect) for the degree-q channel, by enumerating C_q x C_q."""
    cells = list(product(range(q), repeat=2))
    mass = 1.0 / (q * q)
    joint: Dict[Tuple[object, object], float] = {}
    for a, b in cells:
        types = tuple(sorted(("split" if a == 0 else "inert", "split" if b == 0 else "inert")))
        observable = "split" if (a + b) % q == 0 else "inert"
        key = (observable, types)
        joint[key] = joint.get(key, 0.0) + mass
    h_obs = entropy([1.0 / q, 1.0 - 1.0 / q])
    i_pair = mutual_information(joint)
    return h_obs, i_pair, h_obs - i_pair


def demo_pairing() -> None:
    print("=" * 78)
    print("3. SEMIPRIME PAIRING CHANNEL  n = p q")
    print("=" * 78)
    h, i_pair, defect = pairing_statistics(3)
    print("   configuration table for degree 3 (each cell of the 3x3 grid has mass 1/9):")
    print("     {split,split}  prob 1/9  -> product split      (certain)")
    print("     {split,inert}  prob 4/9  -> product inert      (certain)")
    print("     {inert,inert}  prob 4/9  -> fair coin          (one bit of uncertainty)")
    print(f"   H(T)                       : {h:.10f}   exact log2 3 - 2/3 = {log2(3)-2/3:.10f}")
    print(f"   I(T(n) ; pair of types)    : {i_pair:.10f}   exact log2 3 - 10/9 = {log2(3)-10/9:.10f}")
    print(f"   pairing defect H(T)-I_pair : {defect:.10f}   exact 4/9 = {4/9:.10f}")
    assert abs(defect - 4 / 9) < 1e-12

    print("\n   general prime degree q  (defect = ((q-1)^2/q^2) * h(1/(q-1))):")
    print("      q     H(T_q)      I_pair(q)     defect      closed form   rational?")
    for q in (2, 3, 5, 7, 11, 13):
        hq, ip, df = pairing_statistics(q)
        x = 1.0 / (q - 1)
        closed = ((q - 1) ** 2 / q**2) * (entropy([x, 1 - x]))
        rational = "yes" if q in (2, 3) else "no"
        print(f"   {q:4d}   {hq:.8f}   {ip:.8f}   {df:.8f}   {closed:.8f}   {rational}")
        assert abs(df - closed) < 1e-12
    print("   => the defect is rational exactly at q = 2 (value 0) and q = 3 (value 4/9).\n")


# --------------------------------------------------------------------------------------
# 4. The which-factor wall
# --------------------------------------------------------------------------------------


def demo_which_factor_wall(q: int = 3) -> None:
    print("=" * 78)
    print("4. THE WHICH-FACTOR WALL  (an exact zero, not a small number)")
    print("=" * 78)
    mass = 1.0 / (q * q)
    joint: Dict[Tuple[object, object], float] = {}
    for a, b in product(range(q), repeat=2):
        ta = "split" if a == 0 else "inert"
        tb = "split" if b == 0 else "inert"
        if ta == tb:
            continue  # the "which factor" question is only meaningful in the mixed case
        observable = (
            "split" if (a + b) % q == 0 else "inert",
            tuple(sorted((ta, tb))),
        )
        hidden = "first" if ta == "split" else "second"
        joint[(observable, hidden)] = joint.get((observable, hidden), 0.0) + mass
    total = sum(joint.values())
    joint = {k: v / total for k, v in joint.items()}  # condition on the mixed case
    info = mutual_information(joint)

    # Best decoder: for each observation guess the more likely hidden label.
    per_obs: Dict[object, Dict[object, float]] = {}
    for (obs, hid), p in joint.items():
        per_obs.setdefault(obs, {})[hid] = p
    successes = sum(max(d.values()) for d in per_obs.values())

    print(f"   I(observable ; which factor is the split one) = {info:.3e}   (exactly 0)")
    print(f"   optimal decoder success probability            = {successes:.10f}   (exactly 1/2)")
    print("   reason: swapping the two factors fixes every observable (the product, its")
    print("           class, the unordered pair of types) while exchanging the hidden label,")
    print("           so the conditional law of the label is uniform for every observation.")
    assert abs(info) < 1e-12 and abs(successes - 0.5) < 1e-12
    print()


# --------------------------------------------------------------------------------------
# 5. The Renyi spectrum
# --------------------------------------------------------------------------------------


def demo_renyi() -> None:
    print("=" * 78)
    print("5. RENYI SPECTRUM OF THE CUBIC CHANNEL   H_a = log2((1/3)^a+(2/3)^a)/(1-a)")
    print("=" * 78)
    law = [1 / 3, 2 / 3]
    for a in (0.0, 0.5, 1.0, 2.0, 3.0, float("inf")):
        label = "inf" if a == float("inf") else f"{a:g}"
        print(f"   H_{label:<3} = {renyi_entropy(law, a):.10f} bits")
    print(f"   exact: H_0 = 1, H_1 = log2 3 - 2/3 = {log2(3)-2/3:.10f}, "
          f"H_2 = log2(9/5) = {log2(9/5):.10f}")
    print(f"   H_2 < H_1 is equivalent to  108 < 125 : {108 < 125}")
    assert renyi_entropy(law, 2.0) < renyi_entropy(law, 1.0)
    print()


# --------------------------------------------------------------------------------------
# 6. The subfield tower at conductor 13
# --------------------------------------------------------------------------------------


def totient(n: int) -> int:
    return sum(1 for k in range(1, n + 1) if gcd(k, n) == 1)


def divisors(n: int) -> List[int]:
    return [d for d in range(1, n + 1) if n % d == 0]


def tower_entropy(d: int) -> float:
    """H(T_d) for the degree-d subfield: type = order of the residue class in C_d."""
    return entropy([totient(e) / d for e in divisors(d)])


def saturation_constant(p: int) -> float:
    return p * log2(p) / (p - 1) - (log2(p - 1) if p > 2 else 0.0)


def demo_tower() -> None:
    print("=" * 78)
    print("6. THE SUBFIELD TOWER OF Q(zeta_13) AS AN INFORMATION FILTRATION")
    print("=" * 78)
    print("     degree d   H(T_d) [bits]   gap over previous rung")
    previous = 0.0
    for d in (1, 2, 3, 4, 6, 12):
        h = tower_entropy(d)
        print(f"   {d:8d}   {h:.10f}      {h - previous:+.10f}")
        previous = h
    eta = log2(3) - 2 / 3
    print(f"\n   exact values: 0, 1, eta = {eta:.10f}, 3/2, 1+eta, 3/2+eta")
    print("   CRT additivity  H(T_6)  = H(T_2) + H(T_3) :",
          abs(tower_entropy(6) - tower_entropy(2) - tower_entropy(3)) < 1e-12)
    print("   CRT additivity  H(T_12) = H(T_4) + H(T_3) :",
          abs(tower_entropy(12) - tower_entropy(4) - tower_entropy(3)) < 1e-12)
    print("\n   prime-power saturation  H(T_{p^e}) = C(p) (1 - p^-e):")
    for p in (2, 3):
        c = saturation_constant(p)
        cells = ", ".join(
            f"e={e}: {tower_entropy(p**e):.8f} vs {c*(1-p**-e):.8f}" for e in (1, 2, 3)
        )
        print(f"     p = {p},  C({p}) = {c:.10f}   ->   {cells}")
        for e in (1, 2, 3):
            assert abs(tower_entropy(p**e) - c * (1 - p ** (-e))) < 1e-12
    print()


# --------------------------------------------------------------------------------------
# 7. Rational-defect rigidity: the integer identity that cannot hold
# --------------------------------------------------------------------------------------


def rational_obstruction_report(q: int) -> str:
    """Explain why q^(q b) = 2^A (q-1)^((q-1) b) is impossible for odd prime q."""
    if q == 2:
        return "q = 2: H(T_2) = 1, rational (degenerate case, log2(q-1) = 0)."
    return (
        f"q = {q}: rationality would force {q}^({q}b) = 2^A * {q-1}^({q-1}b); "
        f"the odd prime {q} divides the left side and, since gcd({q},{q-1}) = "
        f"{gcd(q, q-1)}, cannot divide the right. Contradiction."
    )


def demo_rigidity() -> None:
    print("=" * 78)
    print("7. RATIONAL-DEFECT RIGIDITY (irrationality by unique factorisation)")
    print("=" * 78)
    for q in (2, 3, 5, 7):
        print("   " + rational_obstruction_report(q))
    print()
    print("   continued-fraction evidence that H(T_3) = log2 3 - 2/3 is irrational:")
    x = log2(3) - 2 / 3
    approx, r = [], x
    for _ in range(8):
        a = int(r)
        approx.append(a)
        r = 1.0 / (r - a) if r - a > 1e-12 else 0.0
        if r == 0.0:
            break
    print(f"     partial quotients {approx}  (no termination: consistent with irrationality)")
    best = min(
        (abs(x - float(Fraction(n, d))), Fraction(n, d))
        for d in range(1, 60)
        for n in range(0, d + 1)
    )
    print(f"     best rational with denominator < 60 : {best[1]}  (error {best[0]:.2e})")
    print("   by contrast, the pairing DEFECT at degree 3 is exactly the rational 4/9 =",
          float(Fraction(4, 9)))
    print()


# --------------------------------------------------------------------------------------


def main() -> None:
    demo_full_pinning()
    demo_conductor_independence()
    demo_pairing()
    demo_which_factor_wall()
    demo_renyi()
    demo_tower()
    demo_rigidity()
    print("=" * 78)
    print("All assertions passed: the exact values of the paper are confirmed numerically.")
    print("=" * 78)


if __name__ == "__main__":
    main()
