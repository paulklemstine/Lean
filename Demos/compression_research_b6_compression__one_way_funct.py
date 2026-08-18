"""
Compression beyond the pigeonhole bound: numerical demonstrations.
==================================================================

Self-contained numerical exploration of the results on Las Vegas (zero-error,
seeded) compression and its collision with cryptographic hardness.

Everything is brute force over short binary strings, so every printed number is
an exact combinatorial fact, not an estimate.

Contents
--------
  1. The deterministic pigeonhole ceiling            |T| <= 2^(s+1) - 1
  2. The Las Vegas budget theorem      sum_y |G_s(y)| <= |R| (2^(s+1) - 1)
  3. Success probability, not seed length, is paid for
  4. Zero-error randomness gains nothing
  5. Tightness of the budget (seeded prefix system)
  6. Las Vegas incompressibility
  7. Average description length, deterministic and seeded
  8. Sharpness of the additive constant
  9. The strict seed hierarchy
 10. Bit-by-bit reconstruction from a decision oracle (search to decision)
 11. Local correctness suffices; a locally wrong oracle is detected
 12. Las Vegas simulation: derandomization by verification
 13. Total failure of Las Vegas algorithms against a one-way function

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, Iterable, List, Optional, Sequence, Tuple

# A "string" is a tuple of bits; a decompressor maps strings to strings.
Str = Tuple[int, ...]
Decompressor = Callable[[Str], Str]
# dec(y, w, n) : "is there p of length n with D(w + p) = y ?"
DecisionOracle = Callable[[Str, Str, int], bool]


# --------------------------------------------------------------------------- #
# Basic string utilities
# --------------------------------------------------------------------------- #
def all_strings(length: int) -> List[Str]:
    """All binary strings of exactly the given length."""
    return [tuple(bits) for bits in product((0, 1), repeat=length)]


def all_strings_upto(length: int) -> List[Str]:
    """All binary strings of length at most `length`, shortest first."""
    out: List[Str] = []
    for n in range(length + 1):
        out.extend(all_strings(n))
    return out


def show(s: Str) -> str:
    """Render a bit string, with a visible symbol for the empty string."""
    return "".join(str(b) for b in s) if s else "e"


# --------------------------------------------------------------------------- #
# Complexity relative to a decompressor
# --------------------------------------------------------------------------- #
def complexity(decoder: Decompressor, y: Str, max_len: int) -> Optional[int]:
    """K_D(y): least length of a program p with D(p) = y, searching |p| <= max_len.

    Returns None if y is not describable within the search horizon.
    """
    for n in range(max_len + 1):
        for p in all_strings(n):
            if decoder(p) == y:
                return n
    return None


def compressible_set(decoder: Decompressor, budget: int,
                     targets: Iterable[Str], max_len: int) -> List[Str]:
    """Those targets with K_D(y) <= budget."""
    out: List[Str] = []
    for y in targets:
        k = complexity(decoder, y, max_len)
        if k is not None and k <= budget:
            out.append(y)
    return out


def good_seeds(family: Sequence[Decompressor], budget: int, y: Str,
               max_len: int) -> List[int]:
    """G_s(y): indices of seeds that compress y to at most `budget` bits."""
    out: List[int] = []
    for i, decoder in enumerate(family):
        k = complexity(decoder, y, max_len)
        if k is not None and k <= budget:
            out.append(i)
    return out


def seeded_complexity(family: Sequence[Decompressor], y: Str,
                      max_len: int) -> Optional[int]:
    """K^seed(y): least program length over all seeds."""
    best: Optional[int] = None
    for decoder in family:
        k = complexity(decoder, y, max_len)
        if k is not None and (best is None or k < best):
            best = k
    return best


# --------------------------------------------------------------------------- #
# The seeded prefix system: D_(u,v)(p) = u ++ p, with v ignored
# --------------------------------------------------------------------------- #
def prefix_seeded_family(j: int, i: int) -> List[Decompressor]:
    """Seeds are pairs (u, v) with |u| = j, |v| = i; v is wasted randomness."""
    family: List[Decompressor] = []
    for u in all_strings(j):
        for _v in all_strings(i):
            def decoder(p: Str, u: Str = u) -> Str:
                return u + p
            family.append(decoder)
    return family


# --------------------------------------------------------------------------- #
# 1-2.  Pigeonhole ceiling and the Las Vegas budget theorem
# --------------------------------------------------------------------------- #
def demo_pigeonhole_and_budget() -> None:
    print("=" * 78)
    print("1-2.  Pigeonhole ceiling and the Las Vegas budget")
    print("=" * 78)

    identity: Decompressor = lambda p: p
    for s in range(4):
        targets = all_strings_upto(5)
        good = compressible_set(identity, s, targets, max_len=5)
        print(f"   identity decoder, s = {s}: "
              f"|{{y : K(y) <= s}}| = {len(good):3d}   ceiling 2^(s+1)-1 = "
              f"{2 ** (s + 1) - 1:3d}   {'OK' if len(good) <= 2**(s+1)-1 else 'VIOLATED'}")

    print()
    print("   Budget theorem:  sum_y |G_s(y)|  <=  |R| (2^(s+1) - 1)")
    for (j, i, s) in [(1, 0, 2), (2, 0, 2), (2, 1, 2), (1, 2, 3)]:
        family = prefix_seeded_family(j, i)
        targets = all_strings(j + s)
        demand = sum(len(good_seeds(family, s, y, max_len=s)) for y in targets)
        budget = len(family) * (2 ** (s + 1) - 1)
        print(f"   j={j} i={i} s={s}: |R| = {len(family):3d}   demand = {demand:4d}"
              f"   budget = {budget:4d}   ratio = {demand / budget:.3f}"
              f"   {'OK' if demand <= budget else 'VIOLATED'}")
    print()


# --------------------------------------------------------------------------- #
# 3-5.  Success probability, zero error, tightness
# --------------------------------------------------------------------------- #
def demo_success_probability() -> None:
    print("=" * 78)
    print("3-5.  Success probability is what you pay for; tightness")
    print("=" * 78)
    print("   Prefix system with j 'used' and i 'wasted' seed bits, budget s.")
    print("   Theory: success probability = 2^-j exactly, independent of i;")
    print("           gain over the deterministic ceiling <= log2(1/delta) + 1 bits.")
    print()
    s = 2
    for j in range(0, 3):
        for i in range(0, 3):
            family = prefix_seeded_family(j, i)
            targets = all_strings(j + s)
            m = min(len(good_seeds(family, s, y, max_len=s)) for y in targets)
            delta = m / len(family)
            lhs = m * len(targets)
            rhs = len(family) * (2 ** (s + 1) - 1)
            gain = (len(targets)) / (2 ** (s + 1) - 1)
            print(f"   j={j} i={i}: |R|={len(family):3d}  delta={delta:6.3f} "
                  f"(2^-j={2.0 ** -j:6.3f})  m|T|={lhs:4d} <= |R|(2^(s+1)-1)={rhs:4d}"
                  f"  |T|/ceiling={gain:5.2f} <= 1/delta={1/delta:5.2f}")
    print()
    print("   Zero-error randomness (every seed must work) collapses to the")
    print("   deterministic ceiling: j = 0 above, where delta = 1 and |T| <= 2^(s+1)-1.")
    print()


# --------------------------------------------------------------------------- #
# 6.  Las Vegas incompressibility
# --------------------------------------------------------------------------- #
def demo_incompressibility() -> None:
    print("=" * 78)
    print("6.  Incompressible strings survive randomization")
    print("=" * 78)
    print("   For every seeded family and all s, k: some y of length k+s+1 has")
    print("   success probability strictly below 2^-k.")
    print()
    s, k = 1, 1
    for (j, i) in [(1, 0), (1, 1), (2, 0)]:
        family = prefix_seeded_family(j, i)
        targets = all_strings(k + s + 1)
        witnesses = [y for y in targets
                     if 2 ** k * len(good_seeds(family, s, y, max_len=s)) < len(family)]
        best = min(len(good_seeds(family, s, y, max_len=s)) / len(family)
                   for y in targets)
        print(f"   prefix family j={j} i={i}, s={s}, k={k}: "
              f"{len(witnesses)} of {len(targets)} strings of length {k+s+1} "
              f"beat the threshold; min success prob = {best:.3f} < 2^-k = {2.0**-k:.3f}")
    print()


# --------------------------------------------------------------------------- #
# 7-8.  Average description length and its sharpness
# --------------------------------------------------------------------------- #
def demo_average_length() -> None:
    print("=" * 78)
    print("7-8.  Average description length, and sharpness of the constant")
    print("=" * 78)
    print("   Deterministic:  (n - 2) |T|  <=  sum_y K_D(y)   whenever |T| >= 2^n")
    print()
    identity: Decompressor = lambda p: p
    for m in range(1, 6):
        targets = all_strings_upto(m)
        total = sum(len(y) for y in targets)          # K_identity(y) = |y|
        n = m  # 2^m <= |T| = 2^(m+1) - 1
        lhs = max(n - 2, 0) * len(targets)
        print(f"   m={m}: |T|={len(targets):3d}  n={n}  (n-2)|T|={lhs:4d} "
              f"<= sum K = {total:4d}   average = {total/len(targets):5.2f} "
              f"(bound {max(n-2,0)})")
    print()
    print("   Exact sharpness identity, identity decoder on all strings of length <= m:")
    print("       sum_y K(y) + 2 * 2^(m+1)  =  (m+1) 2^(m+1) + 2,   |T| + 1 = 2^(m+1)")
    for m in range(0, 7):
        targets = all_strings_upto(m)
        total = sum(len(y) for y in targets)
        lhs = total + 2 * 2 ** (m + 1)
        rhs = (m + 1) * 2 ** (m + 1) + 2
        card_ok = len(targets) + 1 == 2 ** (m + 1)
        print(f"   m={m}: {lhs:6d} == {rhs:6d} : {lhs == rhs};  "
              f"|T|+1 = 2^(m+1) : {card_ok};  avg = {total/len(targets):6.3f} "
              f"~ n-2 with n = {m+1}")
    print()
    print("   Seeded:  (n - k - 3) |T|  <=  sum_y K^seed(y)   with |R| <= 2^k")
    s_cap = 4
    for (j, i, n) in [(1, 0, 3), (2, 0, 3), (2, 1, 3)]:
        family = prefix_seeded_family(j, i)
        k = j + i
        targets = all_strings(n)
        total = 0
        for y in targets:
            kk = seeded_complexity(family, y, max_len=s_cap)
            assert kk is not None
            total += kk
        lhs = max(n - k - 3, 0) * len(targets)
        print(f"   j={j} i={i} (|R| = 2^{k}), n={n}: (n-k-3)|T| = {lhs:3d} "
              f"<= sum K^seed = {total:3d}   average = {total/len(targets):5.2f}"
              f"   [conjectured sharper bound n-k-1 = {max(n-k-1,0)}]")
    print()


# --------------------------------------------------------------------------- #
# 9.  The strict seed hierarchy
# --------------------------------------------------------------------------- #
def demo_seed_hierarchy() -> None:
    print("=" * 78)
    print("9.  The strict seed hierarchy: each random bit buys exactly one bit")
    print("=" * 78)
    print("   With 2^k seeds the prefix system compresses EVERY string of length k+s")
    print("   to s bits; with 2^(k-1) seeds no family can (a counting fact).")
    print()
    s = 2
    for k in (1, 2, 3):
        family = prefix_seeded_family(k, 0)
        targets = all_strings(k + s)
        covered = all(len(good_seeds(family, s, y, max_len=s)) > 0 for y in targets)
        # counting certificate for the impossibility with half as many seeds
        supply = 2 ** (k - 1) * (2 ** (s + 1) - 1)
        demand = 2 ** (k + s)
        print(f"   k={k}, s={s}: 2^k = {len(family)} seeds cover all "
              f"{len(targets)} strings of length {k+s}: {covered}")
        print(f"            with 2^(k-1) = {2**(k-1)} seeds the supply is "
              f"{supply} < {demand} = number of targets -> impossible")
    print()


# --------------------------------------------------------------------------- #
# 10-11.  Search to decision: bit-by-bit reconstruction
# --------------------------------------------------------------------------- #
def rebuild(dec: Callable[[Str, int], bool], n: int, w: Str) -> Str:
    """Walk down the prefix tree, always keeping a live branch (n queries)."""
    while n > 0:
        if dec(w + (0,), n - 1):
            w = w + (0,)
        else:
            w = w + (1,)
        n -= 1
    return w


def ideal_oracle(decoder: Decompressor, max_len: int) -> DecisionOracle:
    """The ideal (brute-force) prefix-decision oracle for `decoder`."""
    def dec(y: Str, w: Str, n: int) -> bool:
        for p in all_strings(n):
            if decoder(w + p) == y:
                return True
        return False
    return dec


def decision_to_finder(dec: DecisionOracle, fuel: int, y: Str) -> Optional[Str]:
    """Least feasible length by bounded search, then bit-by-bit reconstruction."""
    for n in range(fuel + 1):
        if dec(y, (), n):
            return rebuild(lambda w, m, y=y: dec(y, w, m), n, ())
    return None


def demo_search_to_decision() -> None:
    print("=" * 78)
    print("10-11.  Search to decision, and local correctness")
    print("=" * 78)

    # A toy decompressor: drop a leading flag bit, or duplicate the payload.
    def toy(p: Str) -> Str:
        if not p:
            return ()
        return p[1:] if p[0] == 0 else p[1:] + p[1:]

    ideal = ideal_oracle(toy, max_len=6)
    print("   Toy decoder: D(0 x) = x,  D(1 x) = x x,  D(empty) = empty.")
    print("   Reconstruction from the ideal oracle (one query per output bit):")
    for y in [(1, 0), (1, 0, 1, 0), (0, 1, 1), (1, 1, 1, 1)]:
        prog = decision_to_finder(ideal, fuel=5, y=y)
        assert prog is not None
        k = complexity(toy, y, max_len=5)
        ok = toy(prog) == y and len(prog) == k
        print(f"      y = {show(y):6s}  program = {show(prog):6s}  "
              f"|program| = {len(prog)} = K(y) = {k}   valid: {ok}")

    print()
    print("   LOCAL correctness suffices: corrupt every answer about strings")
    print("   other than the target; the reconstruction at the target is unchanged.")
    target = (1, 0, 1, 0)

    def locally_correct_at(y0: Str) -> DecisionOracle:
        def dec(y: Str, w: Str, n: int) -> bool:
            if y == y0:
                return ideal(y, w, n)
            return (len(w) + n) % 2 == 0  # arbitrary garbage elsewhere
        return dec

    corrupted = locally_correct_at(target)
    prog_ideal = decision_to_finder(ideal, fuel=5, y=target)
    prog_local = decision_to_finder(corrupted, fuel=5, y=target)
    print(f"      ideal oracle            -> {show(prog_ideal or ())}")
    print(f"      locally correct oracle  -> {show(prog_local or ())}   "
          f"identical: {prog_ideal == prog_local}")

    print()
    print("   An oracle that is wrong AT the target produces a program that fails")
    print("   verification -- which is exactly why randomizing decision cannot help:")

    def wrong_at_target(y: Str, w: Str, n: int) -> bool:
        if y == target:
            return not ideal(y, w, n)
        return ideal(y, w, n)

    bad = decision_to_finder(wrong_at_target, fuel=5, y=target)
    print(f"      wrong-at-target oracle  -> {show(bad) if bad is not None else 'no answer'}"
          f"   decodes to {show(toy(bad)) if bad is not None else '-'}"
          f"   verifies: {bad is not None and toy(bad) == target}")
    print()


# --------------------------------------------------------------------------- #
# 12-13.  Las Vegas simulation and total failure against a one-way function
# --------------------------------------------------------------------------- #
def try_list(f: Decompressor, slices: Sequence[Callable[[Str], Str]],
             y: Str) -> Str:
    """Run every seed, return the first candidate that verifies; else echo y."""
    for slice_alg in slices:
        candidate = slice_alg(y)
        if f(candidate) == y:
            return candidate
    return y


def demo_las_vegas_simulation() -> None:
    print("=" * 78)
    print("12-13.  Derandomization by verification, and total failure")
    print("=" * 78)

    # tagTrue: y |-> 1 y.  Its range is exactly the strings beginning with 1.
    def tag_true(p: Str) -> Str:
        return (1,) + p

    print("   Target function f(p) = 1 p.  Its inverses must DELETE a bit, so no")
    print("   length-nondecreasing algorithm can invert it: f is one-way in that class.")
    print()

    # Three length-nondecreasing 'seeded' attempts.
    seeds: List[Callable[[Str], Str]] = [
        lambda y: y,                       # echo
        lambda y: y + (0,),                # pad
        lambda y: (1,) + y,                # tag again
    ]
    targets = [(1,), (1, 0), (1, 1, 0), (1, 0, 1, 1)]
    print("   Las Vegas simulation over 3 length-nondecreasing seeds:")
    for y in targets:
        out = try_list(tag_true, seeds, y)
        per_seed = [tag_true(s(y)) == y for s in seeds]
        print(f"      y = {show(y):6s}  seed successes = {per_seed}  "
              f"simulation output = {show(out):7s}  inverts: {tag_true(out) == y}")
    print("   Every seed fails on every input simultaneously: total failure, as the")
    print("   theory predicts for a one-way function against any finite seed list.")
    print()

    print("   Contrast: in the class of ALL functions the barrier disappears.")
    unrestricted: List[Callable[[Str], Str]] = [lambda y: y[1:] if y else y]
    for y in targets:
        out = try_list(tag_true, unrestricted, y)
        print(f"      y = {show(y):6s}  simulation output = {show(out):7s}  "
              f"inverts: {tag_true(out) == y}")
    print("   So the impossibility is genuinely the cryptographic assumption,")
    print("   not a hidden information-theoretic obstruction.")
    print()


# --------------------------------------------------------------------------- #
def main() -> None:
    print()
    print("COMPRESSION BEYOND THE PIGEONHOLE BOUND")
    print("Las Vegas randomness, search to decision, and the one-way boundary")
    print()
    demo_pigeonhole_and_budget()
    demo_success_probability()
    demo_incompressibility()
    demo_average_length()
    demo_seed_hierarchy()
    demo_search_to_decision()
    demo_las_vegas_simulation()
    print("=" * 78)
    print("Summary:  randomness buys log2(1/delta) + 1 bits of compression and")
    print("          nothing at all in computational power at the one-way boundary.")
    print("=" * 78)


if __name__ == "__main__":
    main()
