"""
Compression Beyond the Pigeonhole Bound: numerical demonstrations.

This self-contained script illustrates, by exhaustive computation on small
alphabets of bit strings, the three walls that limit compression:

  1. The pigeonhole ceiling.  For ANY decompressor D : Str -> Str, at most
     2^(s+1) - 1 objects have a D-program of length <= s.  Consequences:
     some string of length s+1 is always incompressible, and at most a
     2^-(c-1) fraction of length-n strings compress by c bits.

  2. The seed budget.  A seeded (randomized) family {D_r}_{r in R} compresses
     at most |R| * (2^(s+1) - 1) objects to s bits; the "seed carries the
     prefix" family attains a gain of exactly k bits with 2^k seeds; and a
     single deterministic decompressor simulates a seeded family at an
     additive cost of 2k + 1 bits.

  3. The cryptographic boundary.  Finding shortest programs is equivalent to
     inverting one-way functions.  We implement both reductions:
       - the guarded-search compressor, which turns inverters for the
         length-guarded functions f_l into an exact shortest-program finder;
       - the prefix-oracle reconstruction, which turns a yes/no
         prefix-compressibility oracle into an exact shortest-program finder.
     We also demonstrate the infinite-failure phenomenon: an algorithm that
     fails only finitely often can be repaired by a lookup table, so under
     patch closure every failure set must be infinite.

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, Iterable, List, Optional, Sequence, Tuple

Str = Tuple[int, ...]  # a bit string, e.g. (1, 0, 1)

EMPTY: Str = ()


# ---------------------------------------------------------------------------
# Basic machinery: strings, complexity, describability
# ---------------------------------------------------------------------------

def all_strings(max_len: int) -> List[Str]:
    """All bit strings of length <= max_len, in length-lexicographic order."""
    out: List[Str] = []
    for n in range(max_len + 1):
        for bits in product((0, 1), repeat=n):
            out.append(tuple(bits))
    return out


def strings_of_length(n: int) -> List[Str]:
    """All bit strings of length exactly n."""
    return [tuple(bits) for bits in product((0, 1), repeat=n)]


def show(s: Str) -> str:
    """Human-readable form of a bit string; the empty string prints as eps."""
    return "".join(str(b) for b in s) if s else "eps"


def nat_code(p: Str) -> int:
    """Leading-one numeral: an injection Str -> {1, 2, 3, ...}.

    nat_code(eps) = 1 and nat_code(b :: t) = 2 * nat_code(t) + b, so that
    nat_code(p) < 2^(|p| + 1).  This is the injection behind the pigeonhole
    ceiling: programs of length <= s inject into {1, ..., 2^(s+1) - 1}.
    """
    if not p:
        return 1
    return 2 * nat_code(p[1:]) + p[0]


def complexity_table(D: Callable[[Str], Str], prog_len: int) -> Dict[Str, int]:
    """K_D(y) for every y describable by a program of length <= prog_len.

    Enumerates programs in length-lexicographic order, so the first program
    producing y has minimal length.
    """
    table: Dict[Str, int] = {}
    for p in all_strings(prog_len):
        y = D(p)
        if y not in table:
            table[y] = len(p)
    return table


# ---------------------------------------------------------------------------
# 1. The pigeonhole ceiling
# ---------------------------------------------------------------------------

def demo_pigeonhole(max_prog_len: int = 12) -> None:
    print("=" * 74)
    print("1. THE PIGEONHOLE CEILING:  #{y : K_D(y) <= s}  <=  2^(s+1) - 1")
    print("=" * 74)

    # Three very different decompressors.
    def D_identity(p: Str) -> Str:
        return p

    def D_double(p: Str) -> Str:
        """Repeat every bit: a deliberately wasteful format."""
        return tuple(b for bit in p for b in (bit, bit))

    def D_scrambled(p: Str) -> Str:
        """A pseudo-random format: hash the program into a longer string."""
        h = (nat_code(p) * 2654435761) % (2 ** 20)
        length = (h % 7) + 1
        return tuple((h >> i) & 1 for i in range(length))

    formats: List[Tuple[str, Callable[[Str], Str]]] = [
        ("identity     p |-> p", D_identity),
        ("bit-doubling p |-> pp", D_double),
        ("scrambled hash format", D_scrambled),
    ]

    print(f"\n{'decompressor':<24}{'s':>3}{'compressed':>12}{'ceiling':>10}  ok")
    for name, D in formats:
        table = complexity_table(D, max_prog_len)
        for s in range(0, 5):
            count = sum(1 for k in table.values() if k <= s)
            ceiling = 2 ** (s + 1) - 1
            ok = "yes" if count <= ceiling else "VIOLATED"
            print(f"{name:<24}{s:>3}{count:>12}{ceiling:>10}  {ok}")
    print("\nThe ceiling is never violated -- it is pure counting, valid for")
    print("every decompressor whatsoever, however clever or however slow.")

    print("\nIncompressible strings exist: for each s some y with |y| = s+1")
    print("has no program of length <= s.")
    D = D_identity
    table = complexity_table(D, max_prog_len)
    for s in range(1, 6):
        witnesses = [y for y in strings_of_length(s + 1)
                     if table.get(y, 10 ** 9) > s]
        print(f"  s = {s}:  {len(witnesses):>3} of {2 ** (s + 1):>3} strings "
              f"of length {s + 1} resist; e.g. {show(witnesses[0])}")


def demo_density(n: int = 10, max_prog_len: int = 12) -> None:
    print("\n" + "=" * 74)
    print("   DENSITY OF INCOMPRESSIBILITY:  at most a 2^-(c-1) fraction of")
    print(f"   the 2^{n} strings of length {n} compress to {n} - c bits")
    print("=" * 74)

    def D_runlength(p: Str) -> Str:
        """A real compression format: run-length style expansion.

        Reads the program in blocks of three bits: the first bit is the symbol,
        the next two encode a repetition count in 1..4.
        """
        out: List[int] = []
        i = 0
        while i + 2 < len(p) + 1 and i + 3 <= len(p):
            sym = p[i]
            count = 1 + 2 * p[i + 1] + p[i + 2]
            out.extend([sym] * count)
            i += 3
        return tuple(out)

    table = complexity_table(D_runlength, max_prog_len)
    universe = strings_of_length(n)
    print(f"\n{'c':>3}{'compressible':>14}{'fraction':>12}"
          f"{'bound 2^-(c-1)':>18}{'ok':>6}")
    for c in range(1, 6):
        good = [y for y in universe if table.get(y, 10 ** 9) <= n - c]
        frac = len(good) / len(universe)
        bound = 2.0 ** (-(c - 1))
        print(f"{c:>3}{len(good):>14}{frac:>12.5f}{bound:>18.5f}"
              f"{'yes' if frac <= bound else 'VIOLATED':>6}")
    print("\nRun-length coding is excellent on the few highly structured")
    print("strings and useless on almost all of them -- it stays far below the")
    print("counting bound, which no format may exceed.")


# ---------------------------------------------------------------------------
# 2. Randomness: the seed budget, its tightness, and derandomization
# ---------------------------------------------------------------------------

def demo_seed_budget(k: int = 3, s: int = 4) -> None:
    print("\n" + "=" * 74)
    print("2. THE SEED BUDGET:  randomness helps by exactly the seed length")
    print("=" * 74)

    seeds = strings_of_length(k)
    targets = strings_of_length(k + s)

    # The prefix family: D_r(p) = r ++ p.
    def prefix_sys(r: Str) -> Callable[[Str], Str]:
        return lambda p: r + p

    covered = 0
    for y in targets:
        r, p = y[:k], y[k:]
        if prefix_sys(r)(p) == y and len(p) <= s:
            covered += 1

    deterministic_ceiling = 2 ** (s + 1) - 1
    seeded_ceiling = len(seeds) * deterministic_ceiling

    print(f"\n  seed length k                = {k}   (|R| = {len(seeds)} seeds)")
    print(f"  program budget s             = {s}")
    print(f"  strings of length k+s        = {len(targets)}")
    print(f"  compressed by prefix family  = {covered}")
    print(f"  deterministic ceiling        = {deterministic_ceiling}"
          "   (2^(s+1) - 1)")
    print(f"  seeded ceiling               = {seeded_ceiling}"
          "   (|R| * (2^(s+1) - 1))")
    print(f"\n  the seeded family compresses all {covered} strings of length "
          f"{k + s} to {s} bits,")
    print(f"  while NO deterministic format compresses more than "
          f"{deterministic_ceiling} objects to {s} bits;")
    print(f"  and the seeded count respects its own ceiling "
          f"{seeded_ceiling}: {covered <= seeded_ceiling}.")
    print(f"\n  A deterministic format would need budget "
          f"{k + s} - 1 = {k + s - 1} bits to cover this many strings, so the")
    print(f"  gain from {k} random bits is {k} bits -- exactly the seed length.")


def demo_derandomization(k: int = 3, s: int = 3) -> None:
    print("\n" + "=" * 74)
    print("   DERANDOMIZATION COST:  one deterministic format simulates the")
    print("   whole seeded family at an additive price of 2k + 1 bits")
    print("=" * 74)

    def sd_pair(p: Str, q: Str) -> Str:
        """Self-delimiting pair: |p| in unary, a 0 separator, then p ++ q."""
        return tuple([1] * len(p)) + (0,) + p + q

    def parse_sd(z: Str) -> Tuple[Str, Str]:
        i = 0
        while i < len(z) and z[i] == 1:
            i += 1
        rest = z[i + 1:]
        return rest[:i], rest[i:]

    def index_sys(D: Callable[[Str, Str], Str]) -> Callable[[Str], Str]:
        def U(z: Str) -> Str:
            r, p = parse_sd(z)
            return D(r, p)
        return U

    def seeded(r: Str, p: Str) -> Str:
        return r + p

    U = index_sys(seeded)

    print(f"\n{'y':<14}{'seed r':<10}{'program p':<12}"
          f"{'K_{D_r}(y)':>11}{'K_U(y) <=':>11}{'2k+1+s':>9}")
    targets = strings_of_length(k + s)
    lossless = True
    within_bound = True
    for i, y in enumerate(targets):
        r, p = y[:k], y[k:]
        z = sd_pair(r, p)
        lossless = lossless and (U(z) == y)
        bound = 2 * k + 1 + len(p)
        within_bound = within_bound and (len(z) <= bound)
        if i < 4:
            print(f"{show(y):<14}{show(r):<10}{show(p):<12}"
                  f"{len(p):>11}{len(z):>11}{bound:>9}")
    print(f"\n  packaging lossless on all {len(targets)} targets: {lossless}")
    print(f"  every packaged program has length at most 2k + 1 + |p| = "
          f"{2 * k + 1 + s}: {within_bound}")
    print("  so the seeded gain of k bits is recovered deterministically at a")
    print("  cost of 2k + 1 bits: randomness is bookkeeping, not magic.")


# ---------------------------------------------------------------------------
# 3. Compression search <-> inversion
# ---------------------------------------------------------------------------

def guard_fun(f: Callable[[Str], Str], l: int) -> Callable[[Str], Str]:
    """The length-guarded version f_l of f.

    f_l(p) = 1 :: f(p)  if |p| <= l, and 0 :: p otherwise.  The tag bit turns a
    length constraint into an inversion constraint: any preimage of 1 :: y under
    f_l is an f-program for y of length at most l.
    """
    def g(p: Str) -> Str:
        if len(p) <= l:
            return (1,) + f(p)
        return (0,) + p
    return g


def brute_inverter(g: Callable[[Str], Str], max_prog_len: int
                   ) -> Callable[[Str], Str]:
    """A (slow) inverter for g: return SOME preimage, with no length control."""
    def A(y: Str) -> Str:
        # Deliberately scan long programs first: a generic inverter gives no
        # guarantee at all about the length of what it returns.
        for p in reversed(all_strings(max_prog_len)):
            if g(p) == y:
                return p
        return EMPTY
    return A


def search_finder(f: Callable[[Str], Str],
                  inverter_for: Callable[[int], Callable[[Str], Str]],
                  fuel: int) -> Callable[[Str], Str]:
    """ALGORITHM A1: the guarded-search compressor.

    Given inverters for every guarded function f_l, find the least guard length
    l at which the inverter succeeds; that l equals K_f(y), and the program
    returned is a shortest f-program for y.
    """
    def A(y: Str) -> Str:
        tagged = (1,) + y
        for l in range(fuel + 1):
            A_l = inverter_for(l)
            p = A_l(tagged)
            if guard_fun(f, l)(p) == tagged:
                return p
        return EMPTY
    return A


def demo_search_reduction(max_prog_len: int = 6) -> None:
    print("\n" + "=" * 74)
    print("3. INVERSION SOLVES COMPRESSION SEARCH (guarded-search compressor)")
    print("=" * 74)

    def f(p: Str) -> Str:
        """A decompressor with lots of redundancy: many programs per output."""
        return tuple(b for b in p if b == 1) + (0,) * (len(p) % 2)

    table = complexity_table(f, max_prog_len)
    naive = brute_inverter(f, max_prog_len)
    finder = search_finder(
        f, lambda l: brute_inverter(guard_fun(f, l), max_prog_len),
        fuel=max_prog_len)

    print(f"\n{'y':<12}{'K_f(y)':>8}{'naive inverter':>18}{'len':>5}"
          f"{'guarded search':>18}{'len':>5}  optimal?")
    ok = True
    for y in sorted(table, key=lambda t: (len(t), t))[:12]:
        p_naive = naive(y)
        p_opt = finder(y)
        valid = (f(p_opt) == y)
        optimal = valid and len(p_opt) == table[y]
        ok = ok and optimal
        print(f"{show(y):<12}{table[y]:>8}{show(p_naive):>18}{len(p_naive):>5}"
              f"{show(p_opt):>18}{len(p_opt):>5}  {'yes' if optimal else 'NO'}")
    print(f"\n  all outputs shortest programs: {ok}")
    print("  The naive inverter returns valid but bloated programs; guarding")
    print("  the function by a length bound and searching over that bound")
    print("  upgrades it into an exactly optimal compressor.")


def prefix_oracle(D: Callable[[Str], Str]) -> Callable[[Str, Str, int], bool]:
    """The prefix-compressibility oracle: 'does w extend to a program for y?'"""
    def dec(y: Str, w: Str, n: int) -> bool:
        return any(D(w + p) == y for p in strings_of_length(n))
    return dec


def rebuild(dec: Callable[[Str, Str, int], bool], y: Str, n: int, w: Str) -> Str:
    """Bit-by-bit reconstruction: always take a branch that keeps a solution."""
    while n > 0:
        if dec(y, w + (0,), n - 1):
            w = w + (0,)
        else:
            w = w + (1,)
        n -= 1
    return w


def decision_to_finder(dec: Callable[[Str, Str, int], bool], fuel: int
                       ) -> Callable[[Str], Str]:
    """ALGORITHM A2: shortest-program finder from a yes/no decision oracle."""
    def A(y: Str) -> Str:
        for n in range(fuel + 1):
            if dec(y, EMPTY, n):
                return rebuild(dec, y, n, EMPTY)
        return EMPTY
    return A


def demo_search_to_decision(max_prog_len: int = 6) -> None:
    print("\n" + "=" * 74)
    print("   SEARCH TO DECISION: yes/no answers suffice to rebuild the program")
    print("=" * 74)

    def D(p: Str) -> Str:
        """Drop every third bit -- a lossy-looking but perfectly good format."""
        return tuple(b for i, b in enumerate(p) if i % 3 != 2)

    table = complexity_table(D, max_prog_len)
    dec = prefix_oracle(D)

    print(f"\n{'y':<12}{'K_D(y)':>8}{'rebuilt program':>18}{'len':>5}"
          f"{'valid':>8}{'oracle calls':>14}")
    calls_total = 0
    ok = True
    for y in sorted(table, key=lambda t: (len(t), t))[:10]:
        counter = {"n": 0}

        def counting_dec(yy: Str, w: Str, n: int) -> bool:
            counter["n"] += 1
            return dec(yy, w, n)

        p = decision_to_finder(counting_dec, fuel=max_prog_len)(y)
        good = (D(p) == y and len(p) == table[y])
        ok = ok and good
        calls_total += counter["n"]
        print(f"{show(y):<12}{table[y]:>8}{show(p):>18}{len(p):>5}"
              f"{'yes' if good else 'NO':>8}{counter['n']:>14}")
    print(f"\n  all reconstructions optimal: {ok}    total oracle calls: "
          f"{calls_total}")
    print("  One bit of information per bit of output (plus a length search):")
    print("  deciding compressibility is as hard as compressing.")


# ---------------------------------------------------------------------------
# 4. The description gap and infinite failure
# ---------------------------------------------------------------------------

def demo_infinite_failure(bound: int = 8) -> None:
    print("\n" + "=" * 74)
    print("4. THE DESCRIPTION GAP IS INFINITE, NOT A FINITE ARTEFACT")
    print("=" * 74)

    def tag_true(p: Str) -> Str:
        """The tagging function tau(p) = 1 :: p."""
        return (1,) + p

    def tail(y: Str) -> Str:
        return y[1:]

    def agreement_set(A: Callable[[Str], Str], upto: int) -> List[Str]:
        """Inputs on which A behaves like 'delete the first bit'."""
        return [y for y in all_strings(upto) if y and A(y) == tail(y)]

    # An algorithm that only sometimes deletes the first bit: it succeeds on a
    # finite set F and returns garbage elsewhere.
    F: List[Str] = [(1,), (1, 0), (1, 1), (1, 0, 1)]

    def A_partial(y: Str) -> Str:
        if y in F:
            return tail(y)
        return y + (0,)

    failures = [y for y in all_strings(bound)
                if y and y[0] == 1 and tag_true(A_partial(y)) != y]
    print(f"\n  A_partial succeeds exactly on {[show(y) for y in F]}")
    print(f"  its failure set among inputs of length <= {bound} has size "
          f"{len(failures)}")
    print(f"  first few failures: {[show(y) for y in failures[:6]]}")

    # Patching: hard-wire correct answers on a finite set.
    def patch(A: Callable[[Str], Str], finite_set: Sequence[Str],
              g: Callable[[Str], Str]) -> Callable[[Str], Str]:
        table = {y: g(y) for y in finite_set}
        return lambda y: table.get(y, A(y))

    patched = patch(A_partial, failures[:5], tail)
    still_failing = [y for y in failures[:5] if tag_true(patched(y)) != y]
    print(f"\n  after hard-wiring the first 5 failures, they all succeed: "
          f"{still_failing == []}")
    print("  -- this is why a FINITE failure set would be no obstacle at all.")

    print("\n  But the class of algorithms that agree with 'delete the first")
    print("  bit' only finitely often is closed under exactly this patching,")
    print("  and no member of it inverts tau.  Hence every member must fail on")
    print("  an INFINITE set.  Check: any inverter of tau must equal tail on")
    print("  the whole (infinite) range of tau.")
    perfect_inverter = tail
    print(f"  agreement set of the perfect inverter, up to length {bound}: "
          f"{len(agreement_set(perfect_inverter, bound))} inputs and growing "
          f"-- not finite, so tail is outside the class.")

    print("\n  Growth of the failure set of A_partial:")
    print(f"    {'max length':>12}{'failures':>12}")
    for m in range(1, bound + 1):
        cnt = sum(1 for y in all_strings(m)
                  if y and y[0] == 1 and tag_true(A_partial(y)) != y)
        print(f"    {m:>12}{cnt:>12}")


# ---------------------------------------------------------------------------
# 5. The calibration, side by side
# ---------------------------------------------------------------------------

def demo_calibration(s: int = 4, k: int = 3) -> None:
    print("\n" + "=" * 74)
    print("5. CALIBRATION: the three regimes at budget s and seed length k")
    print("=" * 74)
    det = 2 ** (s + 1) - 1
    seeded = (2 ** k) * det
    print(f"\n  budget s = {s}, seed length k = {k}")
    print(f"  (1) deterministic ceiling      : {det:>8} objects at <= {s} bits")
    print(f"  (2) seeded ceiling             : {seeded:>8} objects at <= {s} bits"
          f"   (x 2^{k})")
    print(f"      achieved by prefix seeding : {2 ** (k + s):>8} objects "
          f"(all strings of length {k + s})")
    print(f"  (3) derandomized cost of a seed: {2 * k + 1:>8} extra bits")
    print("  (4) computational boundary     : under a one-way function, some")
    print("      strings have descriptions of admissible length that no")
    print("      algorithm of the class ever outputs -- infinitely many each.")
    print("\n  Randomness helps by exactly the seed length; then compression")
    print("  stops again at the cryptographic hardness boundary.")


def main() -> None:
    demo_pigeonhole()
    demo_density()
    demo_seed_budget()
    demo_derandomization()
    demo_search_reduction()
    demo_search_to_decision()
    demo_infinite_failure()
    demo_calibration()
    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    main()
