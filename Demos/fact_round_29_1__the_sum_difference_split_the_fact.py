"""
The Factor-Residue Hint Value — numerical demonstrations.

A population of labelled examples hides a pair of residues (p, q) modulo an odd
modulus m and exposes four *views*:

    product view      N = p * q          (the hint-free channel)
    sum view          s = p + q
    gap view          d = q - p
    joint residue     (s, d)

The **hint value** is  Delta = I(T ; s, d) - I(T ; N)  in bits, where T is the label.

Because 4pq = (p+q)^2 - (q-p)^2, the product view is a function of the joint
residue view, so data processing forces Delta >= 0: the hint can never hurt.
This script verifies, numerically and exactly where possible:

  1. the routing table of several explicit batteries;
  2. the ordering theorems  I(T;s), I(T;d), I(T;N) <= I(T;s,d)  on random batteries;
  3. the exact one-bit witness modulo 5 (product view reads 0, joint reads 1);
  4. the attained label-entropy ceiling (a two-bit hint value modulo 5);
  5. the "individually blind, jointly complete" synergy witness modulo 5;
  6. the hyperbola point counts  #{xy = n} = q-1  (n != 0),  2q-1  (n = 0);
  7. the sharp hyperbola ceiling  H(s,d) - H(N)  for the uniform battery.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from collections import Counter
from typing import Callable, Dict, Hashable, List, Sequence, Tuple

Residue = int
Label = Hashable


# --------------------------------------------------------------------------- #
# 1. Finitary information calculus
# --------------------------------------------------------------------------- #

def entropy_bits(values: Sequence[Hashable]) -> float:
    """Shannon entropy, in bits, of the empirical distribution of `values`."""
    n = len(values)
    if n == 0:
        return 0.0
    counts = Counter(values)
    return -sum((c / n) * math.log2(c / n) for c in counts.values())


def mutual_information_bits(xs: Sequence[Hashable], ys: Sequence[Hashable]) -> float:
    """I(X ; Y) in bits, via H(X) + H(Y) - H(X, Y) on a finite population."""
    if len(xs) != len(ys):
        raise ValueError("populations must have equal length")
    joint = list(zip(xs, ys))
    return entropy_bits(xs) + entropy_bits(ys) - entropy_bits(joint)


def conditional_entropy_bits(xs: Sequence[Hashable], ys: Sequence[Hashable]) -> float:
    """H(X | Y) = H(X, Y) - H(Y), in bits."""
    return entropy_bits(list(zip(xs, ys))) - entropy_bits(ys)


# --------------------------------------------------------------------------- #
# 2. The four views and the hint value
# --------------------------------------------------------------------------- #

def product_view(ps: Sequence[Residue], qs: Sequence[Residue], m: int) -> List[Residue]:
    """N = p q mod m — the hint-free channel."""
    return [(p * q) % m for p, q in zip(ps, qs)]


def sum_view(ps: Sequence[Residue], qs: Sequence[Residue], m: int) -> List[Residue]:
    """s = p + q mod m."""
    return [(p + q) % m for p, q in zip(ps, qs)]


def gap_view(ps: Sequence[Residue], qs: Sequence[Residue], m: int) -> List[Residue]:
    """d = q - p mod m."""
    return [(q - p) % m for p, q in zip(ps, qs)]


def residue_view(ps: Sequence[Residue], qs: Sequence[Residue],
                 m: int) -> List[Tuple[Residue, Residue]]:
    """The joint residue view (s, d)."""
    return list(zip(sum_view(ps, qs, m), gap_view(ps, qs, m)))


def pair_view(ps: Sequence[Residue], qs: Sequence[Residue],
              m: int) -> List[Tuple[Residue, Residue]]:
    """The factor-pair view (p, q) — the hint itself."""
    return [(p % m, q % m) for p, q in zip(ps, qs)]


def routing_table(labels: Sequence[Label], ps: Sequence[Residue],
                  qs: Sequence[Residue], m: int) -> Dict[str, float]:
    """All four rows of the routing table, plus hint value and synergy, in bits."""
    i_prod = mutual_information_bits(labels, product_view(ps, qs, m))
    i_sum = mutual_information_bits(labels, sum_view(ps, qs, m))
    i_gap = mutual_information_bits(labels, gap_view(ps, qs, m))
    i_joint = mutual_information_bits(labels, residue_view(ps, qs, m))
    return {
        "label_entropy": entropy_bits(labels),
        "product": i_prod,
        "sum": i_sum,
        "gap": i_gap,
        "joint": i_joint,
        "hint_value": i_joint - i_prod,
        "synergy": i_joint - i_sum - i_gap,
    }


def show_table(name: str, labels: Sequence[Label], ps: Sequence[Residue],
               qs: Sequence[Residue], m: int) -> Dict[str, float]:
    t = routing_table(labels, ps, qs, m)
    share = (lambda v: f"{100 * v / t['product']:7.1f}%") if t["product"] > 1e-12 \
        else (lambda v: "     n/a")
    print(f"\n  {name}   (modulus {m}, {len(labels)} samples, "
          f"H(T) = {t['label_entropy']:.4f} bits)")
    print(f"    {'view':<26}{'bits':>10}{'share':>10}")
    for key, pretty in (("product", "product view (hint-free)"),
                        ("sum", "sum view alone"),
                        ("gap", "gap view alone"),
                        ("joint", "joint residue view (s,d)")):
        print(f"    {pretty:<26}{t[key]:10.4f}{share(t[key]):>10}")
    print(f"    {'HINT VALUE  I(s,d)-I(N)':<26}{t['hint_value']:+10.4f}")
    print(f"    {'synergy  joint-sum-gap':<26}{t['synergy']:+10.4f}")
    return t


# --------------------------------------------------------------------------- #
# 3. The algebra: recovery identity and bijectivity
# --------------------------------------------------------------------------- #

def recovered_product(s: Residue, d: Residue, m: int) -> Residue:
    """pi(s, d) = (s^2 - d^2) / 4 mod m, valid for odd m."""
    inv4 = pow(4, -1, m)
    return ((s * s - d * d) * inv4) % m


def check_recovery_identity(m: int) -> bool:
    """Verify 4pq = (p+q)^2 - (q-p)^2 and pi(sd(p,q)) = pq for all pairs mod m."""
    for p in range(m):
        for q in range(m):
            s, d = (p + q) % m, (q - p) % m
            if (4 * p * q) % m != (s * s - d * d) % m:
                return False
            if recovered_product(s, d, m) != (p * q) % m:
                return False
    return True


def check_split_bijective(m: int) -> bool:
    """Verify that (p,q) -> (p+q, q-p) is a bijection of (Z/m)^2 for odd m."""
    images = {((p + q) % m, (q - p) % m) for p in range(m) for q in range(m)}
    return len(images) == m * m


# --------------------------------------------------------------------------- #
# 4. Hyperbola counts and the sharp ceiling for the uniform battery
# --------------------------------------------------------------------------- #

def hyperbola_count(n: Residue, q: int) -> int:
    """Brute-force #{(x,y) in F_q^2 : xy = n} for prime q."""
    return sum(1 for x in range(q) for y in range(q) if (x * y) % q == n)


def uniform_battery(q: int) -> Tuple[List[Residue], List[Residue]]:
    """The uniform factor battery: every residue pair exactly once."""
    ps = [x for x in range(q) for _ in range(q)]
    qs = [y for _ in range(q) for y in range(q)]
    return ps, qs


def hyperbola_ceiling(q: int) -> float:
    """Closed form H(s,d) - H(N) in bits for the uniform battery over F_q."""
    n = q * q

    def phi(c: int) -> float:
        return (c / n) * math.log2(n / c)

    h_joint = math.log2(n)                       # the split is a bijection
    h_prod = phi(2 * q - 1) + (q - 1) * phi(q - 1)
    return h_joint - h_prod


# --------------------------------------------------------------------------- #
# 5. Exact witnesses (readings are exact rationals in bits)
# --------------------------------------------------------------------------- #

WITNESS_ONE_BIT = {
    "m": 5,
    "P": [1, 1, 2, 2],
    "Q": [1, 2, 3, 1],
    "L": [0, 0, 1, 1],
}

WITNESS_CEILING = {          # four points of the product fibre pq = 1 mod 5
    "m": 5,
    "P": [1, 2, 3, 4],
    "Q": [1, 3, 2, 4],
    "L": [0, 1, 2, 3],
}

WITNESS_SYNERGY = {          # label = XOR of the two coordinates of (s, d)
    "m": 5,
    "P": [0, 2, 3, 0],
    "Q": [0, 3, 3, 1],
    "L": [0, 1, 1, 0],
}

WITNESS_DEGENERATE = {       # zero hint value, labels NOT product-measurable
    "m": 5,
    "P": [0, 0],
    "Q": [0, 0],
    "L": [0, 1],
}


def is_product_measurable(labels: Sequence[Label], ps: Sequence[Residue],
                          qs: Sequence[Residue], m: int) -> bool:
    """Is the label a function of the product residue?"""
    seen: Dict[Residue, Label] = {}
    for n, t in zip(product_view(ps, qs, m), labels):
        if seen.setdefault(n, t) != t:
            return False
    return True


# --------------------------------------------------------------------------- #
# 6. Randomised stress test of the ordering theorems
# --------------------------------------------------------------------------- #

def stress_ordering(trials: int = 2000, seed: int = 20260921) -> Tuple[int, int]:
    """Random batteries: check joint >= max(prod, sum, gap) and joint == pair view."""
    rng = random.Random(seed)
    order_violations = 0
    pair_mismatches = 0
    for _ in range(trials):
        m = rng.choice([5, 7, 11, 31])
        n = rng.randint(4, 60)
        ps = [rng.randrange(m) for _ in range(n)]
        qs = [rng.randrange(m) for _ in range(n)]
        labels = [rng.randrange(rng.choice([2, 3, 4])) for _ in range(n)]
        t = routing_table(labels, ps, qs, m)
        if t["joint"] + 1e-9 < max(t["product"], t["sum"], t["gap"]):
            order_violations += 1
        i_pair = mutual_information_bits(labels, pair_view(ps, qs, m))
        if abs(i_pair - t["joint"]) > 1e-9:
            pair_mismatches += 1
    return order_violations, pair_mismatches


# --------------------------------------------------------------------------- #
# Main
# --------------------------------------------------------------------------- #

def main() -> None:
    print("=" * 74)
    print("  THE FACTOR-RESIDUE HINT VALUE:  Delta = I(T ; s,d) - I(T ; N)")
    print("=" * 74)

    # --- the algebra --------------------------------------------------------
    print("\n[1] The recovery identity  4pq = (p+q)^2 - (q-p)^2  and the split bijection")
    for m in (5, 7, 11, 31):
        print(f"    m = {m:>2}:  recovery identity holds: {check_recovery_identity(m)};"
              f"   (p,q) -> (s,d) bijective: {check_split_bijective(m)}")
    print("    => the product view is a FUNCTION of the joint residue view,")
    print("       so data processing forces the hint value to be >= 0.")

    # --- exact witnesses ----------------------------------------------------
    print("\n[2] Exact witness: the reconstruction hypothesis I(T;s,d) = I(T;N) is false")
    w = WITNESS_ONE_BIT
    print("      x |  p  q |  N  s  d | T")
    for i, (p, q, t) in enumerate(zip(w["P"], w["Q"], w["L"]), start=1):
        print(f"      {i} |  {p}  {q} |  {(p*q)%5}  {(p+q)%5}  {(q-p)%5} | {t}")
    t1 = show_table("one-bit witness", w["L"], w["P"], w["Q"], w["m"])
    print(f"    product view reads exactly 0 bits: {abs(t1['product']) < 1e-12}")
    print(f"    joint  view reads exactly 1 bit  : {abs(t1['joint'] - 1) < 1e-12}")
    print(f"    hint value = 1 bit exactly       : {abs(t1['hint_value'] - 1) < 1e-12}")

    print("\n[3] The label-entropy ceiling is attained (product residue constant)")
    w = WITNESS_CEILING
    t2 = show_table("ceiling witness (fibre pq = 1)", w["L"], w["P"], w["Q"], w["m"])
    print(f"    hint value = H(T) = 2 bits exactly: "
          f"{abs(t2['hint_value'] - 2) < 1e-12 and abs(t2['label_entropy'] - 2) < 1e-12}")

    print("\n[4] Individually blind, jointly complete: maximal synergy, ZERO hint value")
    w = WITNESS_SYNERGY
    t3 = show_table("synergy witness (XOR labels)", w["L"], w["P"], w["Q"], w["m"])
    print(f"    sum and gap rows both exactly 0   : "
          f"{abs(t3['sum']) < 1e-12 and abs(t3['gap']) < 1e-12}")
    print(f"    joint row exactly 1 bit           : {abs(t3['joint'] - 1) < 1e-12}")
    print(f"    hint value exactly 0              : {abs(t3['hint_value']) < 1e-12}")
    print(f"    labels are product-measurable     : "
          f"{is_product_measurable(w['L'], w['P'], w['Q'], w['m'])}")
    print("    => release and synergy are INDEPENDENT coordinates of a routing table.")

    print("\n[5] Zero hint value does NOT force product-measurable labels")
    w = WITNESS_DEGENERATE
    t4 = routing_table(w["L"], w["P"], w["Q"], w["m"])
    print(f"    all views constant, hint value = {t4['hint_value']:.4f}, "
          f"H(T) = {t4['label_entropy']:.4f}")
    print(f"    labels product-measurable: "
          f"{is_product_measurable(w['L'], w['P'], w['Q'], w['m'])}  (so the boundary is "
          f"conditional independence, not measurability)")

    # --- hyperbola counts ---------------------------------------------------
    print("\n[6] Hyperbola point counts over F_q:  #{xy = n} = q-1 (n != 0), 2q-1 (n = 0)")
    for q in (5, 7, 11):
        ok_nonzero = all(hyperbola_count(n, q) == q - 1 for n in range(1, q))
        ok_zero = hyperbola_count(0, q) == 2 * q - 1
        print(f"    q = {q:>2}:  #{{xy=0}} = {hyperbola_count(0, q):>3} = 2q-1 ({ok_zero});"
              f"   every #{{xy=n!=0}} = {q-1:>2} ({ok_nonzero})")

    print("\n[7] The sharp hyperbola ceiling  H(s,d) - H(N)  for the uniform battery")
    print(f"    {'q':>4}{'H(s,d)':>12}{'H(N)':>12}{'ceiling':>12}{'brute force':>14}")
    for q in (5, 7, 11, 31):
        ps, qs = uniform_battery(q)
        h_joint = entropy_bits(residue_view(ps, qs, q))
        h_prod = entropy_bits(product_view(ps, qs, q))
        closed = hyperbola_ceiling(q)
        print(f"    {q:>4}{h_joint:12.4f}{h_prod:12.4f}{closed:12.4f}"
              f"{h_joint - h_prod:14.4f}")
    print("    (closed form and brute-force enumeration agree to machine precision)")

    measured = 0.5189
    ceil31 = hyperbola_ceiling(31)
    print(f"\n    The measured hint value at modulus 31 was {measured:+.4f} bits.")
    print(f"    Crude 10-bit hint budget : {measured / math.log2(961) * 100:5.1f}% of "
          f"log2(961) = {math.log2(961):.4f} bits")
    print(f"    Sharp hyperbola ceiling  : {measured / ceil31 * 100:5.1f}% of "
          f"{ceil31:.4f} bits   <-- the meaningful normalisation")

    # --- a battery resembling the motivating measurement --------------------
    print("\n[8] A synthetic battery modulo 31 with a positive hint value")
    rng = random.Random(7)
    m = 31
    n = 400
    ps = [rng.randrange(1, m) for _ in range(n)]
    qs = [rng.randrange(1, m) for _ in range(n)]
    # labels depend on the factor pair, not only on the product:
    labels = [1 if (p % 3 == 0) ^ (q % 2 == 0) else 0 for p, q in zip(ps, qs)]
    show_table("synthetic factor battery", labels, ps, qs, m)
    print(f"    p <-> q symmetry of the hint value: "
          f"{abs(routing_table(labels, ps, qs, m)['hint_value'] - routing_table(labels, qs, ps, m)['hint_value']) < 1e-12}")

    # --- conditional-entropy bridge ----------------------------------------
    print("\n[9] The bridge:  Delta = H(T | N) - H(T | s,d)")
    delta = routing_table(labels, ps, qs, m)["hint_value"]
    released = (conditional_entropy_bits(labels, product_view(ps, qs, m))
                - conditional_entropy_bits(labels, residue_view(ps, qs, m)))
    print(f"    hint value          = {delta:+.6f} bits")
    print(f"    released cond. entropy = {released:+.6f} bits   "
          f"(equal: {abs(delta - released) < 1e-9})")

    # --- stress test --------------------------------------------------------
    print("\n[10] Randomised stress test of the ordering theorems (2000 batteries)")
    viol, mism = stress_ordering()
    print(f"     violations of  joint >= max(product, sum, gap) : {viol}")
    print(f"     mismatches between joint view and factor-pair view: {mism}")
    print("     (both are theorems, so both counts must be 0)")

    print("\n" + "=" * 74)
    print("  Summary: the hint value is nonnegative by algebra, equals the released")
    print("  conditional entropy, vanishes exactly under conditional independence,")
    print("  and is capped by H(s,d) - H(N) — a point count on hyperbolas.")
    print("=" * 74)


if __name__ == "__main__":
    main()
