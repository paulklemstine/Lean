"""
The abelianization law at degree five: splitting-type channels of F20 = AGL(1,5),
their semiprime layer, the coset-swap audit, and the affine ladder AGL(1,q).

Self-contained numerical demonstration.  No third-party dependencies.

Everything below is exact combinatorics on finite "Chebotarev boxes" plus one
genuine arithmetic experiment over the primes.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from fractions import Fraction
from typing import Callable, Dict, Hashable, Iterable, List, Sequence, Tuple

Box = Sequence[int]
PairBox = Sequence[Tuple[int, int]]

LOG2_3 = math.log2(3.0)
LOG2_5 = math.log2(5.0)
LOG2_7 = math.log2(7.0)


# ----------------------------------------------------------------------------
# 1. Information-theoretic primitives on a uniformly weighted finite box
# ----------------------------------------------------------------------------

def entropy_of_counts(counts: Iterable[int]) -> float:
    """Shannon entropy (bits) of a distribution given by non-negative counts."""
    cs: List[int] = [c for c in counts if c > 0]
    total: int = sum(cs)
    return -sum((c / total) * math.log2(c / total) for c in cs)


def read_out_counts(box: Sequence[Hashable], f: Callable[[Hashable], Hashable]) -> Dict[Hashable, int]:
    """Fibre sizes of a read-out f on a uniformly weighted box."""
    counts: Dict[Hashable, int] = {}
    for x in box:
        counts[f(x)] = counts.get(f(x), 0) + 1
    return counts


def entropy(box: Sequence[Hashable], f: Callable[[Hashable], Hashable]) -> float:
    """H(f) in bits, under the uniform measure on `box`."""
    return entropy_of_counts(read_out_counts(box, f).values())


def joint_entropy(box: Sequence[Hashable],
                  f: Callable[[Hashable], Hashable],
                  g: Callable[[Hashable], Hashable]) -> float:
    """H(f, g) in bits."""
    return entropy(box, lambda x: (f(x), g(x)))


def mutual_information(box: Sequence[Hashable],
                       f: Callable[[Hashable], Hashable],
                       g: Callable[[Hashable], Hashable]) -> float:
    """I(f ; g) = H(f) + H(g) - H(f, g), in bits."""
    return entropy(box, f) + entropy(box, g) - joint_entropy(box, f, g)


def merge_counts(box: Sequence[Hashable],
                 typ: Callable[[Hashable], Hashable],
                 dial: Callable[[Hashable], Hashable]) -> Dict[Hashable, int]:
    """k(t): the number of distinct dial classes met by the fibre of each type value."""
    seen: Dict[Hashable, set] = {}
    for x in box:
        seen.setdefault(typ(x), set()).add(dial(x))
    return {t: len(s) for t, s in seen.items()}


def structural_loss(box: Sequence[Hashable],
                    typ: Callable[[Hashable], Hashable],
                    dial: Callable[[Hashable], Hashable]) -> float:
    """The merged-coset sum  sum_t P(t) log2 k(t):  H(D) - I(T;D) by the law."""
    n: int = len(box)
    sizes: Dict[Hashable, int] = read_out_counts(box, typ)
    ks: Dict[Hashable, int] = merge_counts(box, typ, dial)
    return sum((sizes[t] / n) * math.log2(ks[t]) for t in sizes)


def fibrewise_dial_uniform(box: Sequence[Hashable],
                           typ: Callable[[Hashable], Hashable],
                           dial: Callable[[Hashable], Hashable]) -> bool:
    """Hypothesis of the merged-coset law: inside each type fibre, all occurring
    dial classes have the same size."""
    per_type: Dict[Hashable, Dict[Hashable, int]] = {}
    for x in box:
        per_type.setdefault(typ(x), {})
        d = per_type[typ(x)]
        d[dial(x)] = d.get(dial(x), 0) + 1
    return all(len(set(d.values())) == 1 for d in per_type.values())


# ----------------------------------------------------------------------------
# 2. The AGL(1,q) Chebotarev box
# ----------------------------------------------------------------------------

def primitive_root(q: int) -> int:
    """A generator of the cyclic group (Z/qZ)^* for prime q."""
    for g in range(2, q):
        powers = {pow(g, k, q) for k in range(q - 1)}
        if len(powers) == q - 1:
            return g
    raise ValueError(f"no primitive root found for {q}")


def multiplicative_order(a: int, q: int) -> int:
    """The order of a in (Z/qZ)^*."""
    d, cur = 1, a % q
    while cur != 1:
        cur = (cur * a) % q
        d += 1
    return d


def agl_box(q: int) -> List[int]:
    """The q(q-1) Frobenius classes of AGL(1,q), encoded as x = q*e + b."""
    return list(range(q * (q - 1)))


def agl_dial(q: int) -> Callable[[int], int]:
    """The abelianization read-out: the C_{q-1} valuation e of the multiplier a = g^e,
    i.e. the residue p mod q transported by the discrete logarithm."""
    return lambda x: x // q


def agl_type(q: int) -> Callable[[int], Tuple[int, ...]]:
    """The splitting type of a generic radical polynomial x^q - a at the Frobenius
    class x = q*e + b: the cycle type of j -> (g^e) j + b on F_q, as a sorted tuple."""
    g: int = primitive_root(q)

    def typ(x: int) -> Tuple[int, ...]:
        e, b = x // q, x % q
        a = pow(g, e, q)
        if a == 1:
            return tuple([1] * q) if b == 0 else (q,)
        d = multiplicative_order(a, q)
        return tuple(sorted([1] + [d] * ((q - 1) // d), reverse=True))

    return typ


def agl_loss_totient(q: int) -> Fraction:
    """The closed form  sum_{d | q-1, d>1} (phi(d)/(q-1)) log2 phi(d),  which is rational
    whenever every phi(d) is a power of two (true for q = 5, 7, 11)."""
    def phi(n: int) -> int:
        return sum(1 for k in range(1, n + 1) if math.gcd(k, n) == 1)

    total = Fraction(0)
    for d in range(2, q):
        if (q - 1) % d == 0:
            pd = phi(d)
            total += Fraction(pd, q - 1) * Fraction(int(round(math.log2(pd))))
    return total


TYPE_NAMES: Dict[Tuple[int, ...], str] = {
    (1, 1, 1, 1, 1): "[1,1,1,1,1]",
    (5,): "[5]",
    (4, 1): "[1,4]",
    (2, 2, 1): "[1,2,2]",
    (1, 1, 1, 1, 1, 1, 1): "[1,1,1,1,1,1,1]",
    (7,): "[7]",
    (2, 2, 2, 1): "[1,2,2,2]",
    (3, 3, 1): "[1,3,3]",
    (6, 1): "[1,6]",
}


def name_of(t: Tuple[int, ...]) -> str:
    return TYPE_NAMES.get(t, str(list(t)))


# ----------------------------------------------------------------------------
# 3. Degree five: the prime-level channel of x^5 - 2
# ----------------------------------------------------------------------------

def demo_quintic_prime_level() -> None:
    q = 5
    box, T, D = agl_box(q), agl_type(q), agl_dial(q)

    print("=" * 78)
    print("1.  THE QUINTIC CHANNEL:  F20 = AGL(1,5) = Gal(x^5 - 2)")
    print("=" * 78)
    print(f"  box size |G| = {len(box)},  abelianization C4 read off by p mod 5\n")

    sizes = read_out_counts(box, T)
    ks = merge_counts(box, T, D)
    print("  type            density   merge count k(t)   cosets merged")
    for t in sorted(sizes, key=lambda u: -sizes[u]):
        cosets = sorted({D(x) for x in box if T(x) == t})
        print(f"  {name_of(t):<14} {sizes[t]:>2}/20      {ks[t]}                  {cosets}")

    HT, HD = entropy(box, T), entropy(box, D)
    I = mutual_information(box, T, D)
    loss = structural_loss(box, T, D)

    print()
    print(f"  fibrewise dial uniform:            {fibrewise_dial_uniform(box, T, D)}")
    print(f"  H(T)   measured {HT:.6f}   closed form 11/10 + (log2 5)/4 = "
          f"{11 / 10 + LOG2_5 / 4:.6f}")
    print(f"  H(D)   measured {HD:.6f}   closed form log2 4            = {2.0:.6f}")
    print(f"  I(T;D) measured {I:.6f}   LAW  3/2                      = {1.5:.6f}")
    print(f"  loss   measured {HD - I:.6f}   merged-coset sum              = {loss:.6f}")
    print(f"  H(T|D) measured {HT - I:.6f}   closed form (log2 5)/4 - 2/5  = "
          f"{LOG2_5 / 4 - 0.4:.6f}")
    print(f"  H(D|T) measured {HD - I:.6f}   closed form 1/2               = {0.5:.6f}")
    print("\n  The transcendental log2 5 cancels: I is the rational number 3/2, because the")
    print("  only merging type [1,4] fuses the two order-4 cosets {1,3} with probability 1/2.")


# ----------------------------------------------------------------------------
# 4. The arithmetic experiment over real primes
# ----------------------------------------------------------------------------

def primes_up_to(n: int) -> List[int]:
    """Sieve of Eratosthenes."""
    sieve = bytearray([1]) * (n + 1)
    sieve[0:2] = b"\x00\x00"
    for p in range(2, int(n ** 0.5) + 1):
        if sieve[p]:
            sieve[p * p::p] = bytearray(len(sieve[p * p::p]))
    return [i for i in range(2, n + 1) if sieve[i]]


def quintic_type_at_prime(p: int) -> str:
    """The factorisation shape of x^5 - 2 modulo an unramified prime p.

    p = 1 mod 5 : [1,1,1,1,1] if 2 is a fifth power mod p, else [5];
    p = 4 mod 5 : the multiplier has order 2 -> [1,2,2];
    p = 2,3 mod 5: the multiplier has order 4 -> [1,4].
    """
    r = p % 5
    if r == 1:
        return "[1,1,1,1,1]" if pow(2, (p - 1) // 5, p) == 1 else "[5]"
    if r == 4:
        return "[1,2,2]"
    return "[1,4]"


DLOG_BASE2_MOD5: Dict[int, int] = {1: 0, 2: 1, 4: 2, 3: 3}


def demo_prime_experiment(limit: int = 270_000) -> None:
    print()
    print("=" * 78)
    print(f"2.  THE ARITHMETIC EXPERIMENT:  x^5 - 2 over the primes below {limit}")
    print("=" * 78)

    joint: Dict[Tuple[str, int], int] = {}
    for p in primes_up_to(limit):
        if p in (2, 5):            # ramified
            continue
        key = (quintic_type_at_prime(p), DLOG_BASE2_MOD5[p % 5])
        joint[key] = joint.get(key, 0) + 1

    n = sum(joint.values())
    tcount: Dict[str, int] = {}
    dcount: Dict[int, int] = {}
    for (t, d), c in joint.items():
        tcount[t] = tcount.get(t, 0) + c
        dcount[d] = dcount.get(d, 0) + c

    HT = entropy_of_counts(tcount.values())
    HD = entropy_of_counts(dcount.values())
    HTD = entropy_of_counts(joint.values())
    I = HT + HD - HTD

    print(f"  {n} unramified primes used\n")
    print("  type            observed density   Chebotarev prediction")
    for t, pred in (("[1,1,1,1,1]", 1 / 20), ("[5]", 4 / 20), ("[1,4]", 10 / 20), ("[1,2,2]", 5 / 20)):
        print(f"  {t:<14} {tcount.get(t, 0) / n:.5f}            {pred:.5f}")
    print()
    print(f"  H(T)   = {HT:.4f}   predicted {11 / 10 + LOG2_5 / 4:.4f}")
    print(f"  H(D)   = {HD:.4f}   predicted {2.0:.4f}")
    print(f"  I(T;D) = {I:.4f}   LAW       {1.5:.4f}     margin {I - 1.5:+.4f}")


# ----------------------------------------------------------------------------
# 5. The semiprime layer: pair law, which-factor wall, the [1,2,2]-fork
# ----------------------------------------------------------------------------

def demo_semiprime_layer() -> None:
    q = 5
    box, T, D = agl_box(q), agl_type(q), agl_dial(q)
    pair_box: List[Tuple[int, int]] = [(x, y) for x in box for y in box]

    def pair_type(xy: Tuple[int, int]) -> Tuple[Tuple[int, ...], Tuple[int, ...]]:
        return (T(xy[0]), T(xy[1]))

    def pair_type_unordered(xy: Tuple[int, int]) -> Tuple[Tuple[int, ...], ...]:
        return tuple(sorted([T(xy[0]), T(xy[1])]))

    def product_dial(xy: Tuple[int, int]) -> int:
        return (D(xy[0]) + D(xy[1])) % 4

    def fork(xy: Tuple[int, int]) -> int:
        """How many of the two prime factors have splitting type [1,2,2],
        equivalently satisfy p = 4 mod 5."""
        return int(T(xy[0]) == (2, 2, 1)) + int(T(xy[1]) == (2, 2, 1))

    print()
    print("=" * 78)
    print("3.  THE SEMIPRIME LAYER:  N = p q, observer sees the pair of splitting types")
    print("=" * 78)

    Hpair = entropy(pair_box, pair_type)
    Ipair = mutual_information(pair_box, pair_type, product_dial)
    Iunord = mutual_information(pair_box, pair_type_unordered, product_dial)
    Hfork = entropy(pair_box, fork)
    Ifork = mutual_information(pair_box, fork, product_dial)

    print(f"  box size = {len(pair_box)},  product dial = sum of the two C4 classes\n")
    print(f"  H(pair)                  = {Hpair:.6f}   closed form 11/5 + (log2 5)/2 = "
          f"{11 / 5 + LOG2_5 / 2:.6f}")
    print(f"  I(pair ; N mod 5)        = {Ipair:.6f}   PAIR LAW 5/4                  = {1.25:.6f}")
    print(f"  I(unordered ; N mod 5)   = {Iunord:.6f}   which-factor wall             = "
          f"{Ipair - Iunord:.6f}")
    print(f"  H(fork)                  = {Hfork:.6f}   closed form 29/8 - (3/2)log2 3 = "
          f"{29 / 8 - 1.5 * LOG2_3:.6f}")
    print(f"  I(fork ; N mod 5)        = {Ifork:.6f}   order-4 split-count channel    = "
          f"{19 / 8 - (21 / 16) * LOG2_3:.6f}")
    print("\n  5/4 is verbatim the cyclotomic C4 pair channel of Q(zeta_5): the non-abelian")
    print("  quintic reads its own abelianization's semiprime channel exactly.")


# ----------------------------------------------------------------------------
# 6. The coset swap: invisible at the prime level, fatal at the pair level
# ----------------------------------------------------------------------------

def demo_coset_swap() -> None:
    q = 5
    box, T, D = agl_box(q), agl_type(q), agl_dial(q)

    def T_swapped(x: int) -> Tuple[int, ...]:
        """The mislabelled dictionary: [1,2,2] put on the coset e = 3 instead of e = 2."""
        e, b = x // 5, x % 5
        if e == 0:
            return tuple([1] * 5) if b == 0 else (5,)
        return (2, 2, 1) if e == 3 else (4, 1)

    pair_box: List[Tuple[int, int]] = [(x, y) for x in box for y in box]

    def product_dial(xy: Tuple[int, int]) -> int:
        return (D(xy[0]) + D(xy[1])) % 4

    def pair_true(xy: Tuple[int, int]):
        return (T(xy[0]), T(xy[1]))

    def pair_swapped(xy: Tuple[int, int]):
        return (T_swapped(xy[0]), T_swapped(xy[1]))

    print()
    print("=" * 78)
    print("4.  THE COSET-SWAP AUDIT")
    print("=" * 78)
    print("  Relabelling the two order-4 cosets against the C4 valuation:\n")
    print(f"  H(T)  true {entropy(box, T):.6f}   swapped {entropy(box, T_swapped):.6f}")
    print(f"  I(T;D) true {mutual_information(box, T, D):.6f}   swapped "
          f"{mutual_information(box, T_swapped, D):.6f}     <-- INVISIBLE")
    it = mutual_information(pair_box, pair_true, product_dial)
    isw = mutual_information(pair_box, pair_swapped, product_dial)
    print(f"  pair   true {it:.6f}   swapped {isw:.6f}     <-- DETECTED, gap "
          f"{it - isw:.6f} = 1/8")
    print("\n  Merged blocks: true labelling merges {1,3} (a subgroup coset of C4),")
    print("  the swap merges {1,2} (not a coset).  Only the convolution notices.")

    # Monte-Carlo confirmation with a fixed seed, as in the original experiment.
    rng = random.Random(20250916)
    m = 400_000
    counts: Dict[Tuple[Tuple[int, ...], Tuple[int, ...], int], int] = {}
    for _ in range(m):
        x, y = rng.randrange(20), rng.randrange(20)
        key = (T(x), T(y), (D(x) + D(y)) % 4)
        counts[key] = counts.get(key, 0) + 1
    mc_joint = entropy_of_counts(counts.values())
    a: Dict[Tuple, int] = {}
    b: Dict[int, int] = {}
    for (t1, t2, d), c in counts.items():
        a[(t1, t2)] = a.get((t1, t2), 0) + c
        b[d] = b.get(d, 0) + c
    mc_I = entropy_of_counts(a.values()) + entropy_of_counts(b.values()) - mc_joint
    print(f"\n  Monte Carlo, {m} semiprimes, fixed seed:  I(pair ; N mod 5) = {mc_I:.4f}")
    print(f"    exact (correct labelling)  1.2500   margin {mc_I - 1.25:+.4f}")
    print(f"    exact (swapped labelling)  1.1250   margin {mc_I - 1.125:+.4f}  <-- excluded")


# ----------------------------------------------------------------------------
# 7. The affine ladder AGL(1,q)
# ----------------------------------------------------------------------------

def demo_affine_ladder() -> None:
    print()
    print("=" * 78)
    print("5.  THE AFFINE LADDER:  AGL(1,q) for q = 5, 7, 11, 13")
    print("=" * 78)
    print("  loss(q) = sum over d | q-1, d > 1 of (phi(d)/(q-1)) log2 phi(d)\n")
    print("   q   |G|   H(T)      H(dial)   I(p mod q ; T)   loss(measured)  loss(totient)")
    for q in (5, 7, 11, 13):
        box, T, D = agl_box(q), agl_type(q), agl_dial(q)
        HT, HD = entropy(box, T), entropy(box, D)
        I = mutual_information(box, T, D)
        print(f"  {q:>2}  {len(box):>4}  {HT:.6f}  {HD:.6f}  {I:.6f}        "
              f"{HD - I:.6f}        {float(agl_loss_totient(q)):.6f}")

    print()
    print("  Closed forms:")
    print(f"    q = 5 :  H(T) = 11/10 + (log2 5)/4          = {11 / 10 + LOG2_5 / 4:.6f}")
    print(f"             I    = 3/2                          = {1.5:.6f}   loss 1/2")
    print(f"    q = 7 :  H(T) = 4/21 + (6/7)log2 3 + (log2 7)/6 = "
          f"{4 / 21 + (6 / 7) * LOG2_3 + LOG2_7 / 6:.6f}")
    print(f"             I    = 1/3 + log2 3                 = {1 / 3 + LOG2_3:.6f}   loss 2/3")
    print(f"    q = 11:  I    = log2 10 - 8/5 = log2 5 - 3/5 = {LOG2_5 - 0.6:.6f}   loss 8/5")
    print()
    print("  Septic transmits more than quintic:  "
          f"{1 / 3 + LOG2_3:.4f} > {1.5:.4f}")
    print("  ...yet wastes a larger FRACTION of its dial:  "
          f"{(2 / 3) / (1 + LOG2_3):.4f} > {0.5 / 2:.4f}")


# ----------------------------------------------------------------------------
# 8. The abelian control: Q(zeta_11)^+ with cyclic group C5
# ----------------------------------------------------------------------------

def demo_abelian_control() -> None:
    print()
    print("=" * 78)
    print("6.  THE ABELIAN CONTROL:  the real subfield of Q(zeta_11), group C5")
    print("=" * 78)

    box: List[int] = list(range(1, 11))          # residues mod 11

    def dial(r: int) -> int:
        return r

    def typ(r: int) -> str:
        """Splitting type in Q(zeta_11)^+ : [1^5] iff r = +-1 mod 11, else [5]."""
        return "[1,1,1,1,1]" if r in (1, 10) else "[5]"

    HT, HD = entropy(box, typ), entropy(box, dial)
    I = mutual_information(box, typ, dial)
    print(f"  H(T)   = {HT:.6f}   closed form log2 5 - 8/5 = {LOG2_5 - 1.6:.6f}")
    print(f"  H(dial)= {HD:.6f}   closed form log2 10      = {1 + LOG2_5:.6f}")
    print(f"  I      = {I:.6f}   PINNED: I = H(T)")
    print(f"  loss   = {HD - I:.6f}   closed form 13/5         = {2.6:.6f}")
    print("\n  The abelian control saturates its channel but sees only 0.72 of 3.32 dial bits;")
    print("  the non-abelian F20 fails to saturate yet transmits 1.50 of 2.00.  Merging costs,")
    print("  non-commutativity does not.")


# ----------------------------------------------------------------------------
# 9. The pinning criterion in action
# ----------------------------------------------------------------------------

def demo_pinning_criterion() -> None:
    print()
    print("=" * 78)
    print("7.  THE PINNING CRITERION:  I(T;D) = H(D)  <=>  no type merges two cosets")
    print("=" * 78)
    for q in (5, 7, 11):
        box, T, D = agl_box(q), agl_type(q), agl_dial(q)
        ks = merge_counts(box, T, D)
        merging = [name_of(t) for t, k in ks.items() if k >= 2]
        pinned = abs(mutual_information(box, T, D) - entropy(box, D)) < 1e-12
        print(f"  q = {q:>2}:  merging types {merging if merging else 'none'};  "
              f"pinned = {pinned}")
    # A synthetic pinned example: a type read-out that separates all cosets.
    box5 = agl_box(5)
    D5 = agl_dial(5)
    pinned_type: Callable[[int], int] = lambda x: x // 5
    print(f"  synthetic pinned channel on the F20 box:  "
          f"I = {mutual_information(box5, pinned_type, D5):.6f} = H(D) = "
          f"{entropy(box5, D5):.6f}")


def main() -> None:
    demo_quintic_prime_level()
    demo_prime_experiment()
    demo_semiprime_layer()
    demo_coset_swap()
    demo_affine_ladder()
    demo_abelian_control()
    demo_pinning_criterion()
    print()
    print("=" * 78)
    print("All exact values reproduce the closed forms of the abelianization law.")
    print("=" * 78)


if __name__ == "__main__":
    main()
