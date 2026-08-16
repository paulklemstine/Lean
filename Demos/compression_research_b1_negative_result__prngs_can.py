"""
Numerical demonstrations for
"Pseudo-Random Generators Cannot Beat the Pigeonhole Bound".

Everything in this file is self-contained: no third-party imports, no I/O.
Run with:  python3 demo.py

The demonstrations, in order:

  1. Counting core          -- there are exactly 2^(k+1)-1 bit strings of
                               length <= k; the self-delimiting index nu is
                               an injection into [1, 2^(k+1)-1].
  2. LCG reachability       -- a 4-bit-seed linear congruential generator
                               producing 8-bit outputs reaches exactly 16 of
                               the 256 values; 240 are unreachable.
  3. Exhaustive seed search -- the folklore algorithm, and its failure rate.
  4. Hybrid compressor      -- the honest "compress to the seed" scheme:
                               s+1 bits on generator outputs, n+1 bits
                               otherwise, complexity histogram, and the
                               explicit incompressible witness.
  5. Rate bounds            -- empirical check of the "at most 2^(1-d) of
                               files shrink by d bits" bound and of the
                               average-length bound (n-k)(1-2^-k).
  6. Generator libraries    -- a library of 2^m generators buys exactly m
                               bits, and one string is hard for all of them.
"""

from __future__ import annotations

from typing import Callable, Dict, Iterator, List, Optional, Sequence, Tuple

Bits = Tuple[int, ...]


# ---------------------------------------------------------------------------
# 0. Bit-string utilities
# ---------------------------------------------------------------------------


def all_strings(n: int) -> Iterator[Bits]:
    """Enumerate all 2^n bit strings of length n, as tuples of 0/1."""
    for v in range(1 << n):
        yield tuple((v >> i) & 1 for i in range(n))


def all_programs_upto(k: int) -> Iterator[Bits]:
    """Enumerate every bit string of length 0,1,...,k, shortest first."""
    for length in range(k + 1):
        for v in range(1 << length):
            yield tuple((v >> i) & 1 for i in range(length))


def nu(p: Sequence[int]) -> int:
    """Self-delimiting numeric index: prepend a leading 1 and read as binary.

    Satisfies 2^|p| <= nu(p) < 2^(|p|+1), and nu is injective.
    Defined by nu([]) = 1, nu(b::q) = 2*nu(q) + b.
    """
    value = 1
    for b in reversed(list(p)):
        value = 2 * value + b
    return value


def bits_to_int(p: Sequence[int]) -> int:
    """Little-endian numeric value of a bit string (used for display only)."""
    return sum(b << i for i, b in enumerate(p))


def pad(p: Sequence[int], n: int) -> Bits:
    """First n bits of p, zero-padded on the right."""
    q = list(p[:n])
    q.extend([0] * (n - len(q)))
    return tuple(q)


def int_to_bits(v: int, n: int) -> Bits:
    return tuple((v >> i) & 1 for i in range(n))


# ---------------------------------------------------------------------------
# 1. The counting core
# ---------------------------------------------------------------------------


def demo_counting_core(kmax: int = 8) -> None:
    """Verify the Counting Lemma exactly, and injectivity of the index nu."""
    print("=" * 72)
    print("1. COUNTING CORE:  #{p : |p| <= k} = 2^(k+1) - 1")
    print("=" * 72)
    print(f"{'k':>3} {'#programs':>12} {'2^(k+1)-1':>12} {'nu range':>18}")
    for k in range(kmax + 1):
        progs = list(all_programs_upto(k))
        indices = [nu(p) for p in progs]
        assert len(set(indices)) == len(indices), "nu must be injective"
        assert all(1 <= i <= (1 << (k + 1)) - 1 for i in indices)
        print(f"{k:>3} {len(progs):>12} {(1 << (k + 1)) - 1:>12}"
              f" {'[%d, %d]' % (min(indices), max(indices)):>18}")
    print("\nConsequence (Pigeonhole Bound): a lossless code on 2^n files")
    print("cannot fit them all into codewords of length <= n-1, since")
    print("2^n > 2^n - 1.  Some file always costs n bits or more.\n")


# ---------------------------------------------------------------------------
# 2. A hand-checkable generator: the 4-bit LCG
# ---------------------------------------------------------------------------


def lcg_step(x: int) -> int:
    """One step of the linear congruential generator x -> 5x + 3 mod 16."""
    return (5 * x + 3) % 16


def lcg_out(seed: int) -> int:
    """Two successive LCG states packed into an 8-bit output."""
    return lcg_step(seed) + 16 * lcg_step(lcg_step(seed))


def demo_lcg_reachability() -> None:
    """Enumerate the LCG image and count the unreachable 8-bit values."""
    print("=" * 72)
    print("2. LCG REACHABILITY:  16 seeds, 256 targets")
    print("=" * 72)
    image = sorted({lcg_out(seed) for seed in range(16)})
    missing = [v for v in range(256) if v not in set(image)]
    print(f"seed -> output table:")
    for seed in range(16):
        print(f"   seed {seed:>2}  ->  out {lcg_out(seed):>3}"
              f"  (binary {lcg_out(seed):08b})")
    print(f"\nimage size            : {len(image)}   (upper bound 2^4 = 16)")
    print(f"unreachable values    : {len(missing)}   (out of 256)")
    print(f"reachable fraction    : {len(image)}/256 = {len(image)/256:.4f}"
          f"  (bound 2^(s-n) = 2^(4-8) = {2**-4:.4f})")
    print(f"is 0 reachable?       : {0 in set(image)}")
    print(f"first ten unreachable : {missing[:10]}")
    assert len(image) == 16 and len(missing) == 240
    print("\nScaling up: a 64-bit seed and a 1 GB target give a reachable")
    print("fraction of 2^(64 - 8e9).  The seed you are looking for does")
    print("not exist -- this is not a hard search, it is an empty one.\n")


# ---------------------------------------------------------------------------
# 3. Exhaustive seed search: the folklore algorithm
# ---------------------------------------------------------------------------


def seed_search(target: Bits, generator: Callable[[int], Bits],
                seed_count: int) -> Optional[int]:
    """Return a seed generating `target`, or None.  Time Theta(seed_count)."""
    for seed in range(seed_count):
        if generator(seed) == target:
            return seed
    return None


def demo_seed_search(n: int = 10, s: int = 4) -> None:
    """Run the folklore compressor over every n-bit file and report success."""
    print("=" * 72)
    print(f"3. EXHAUSTIVE SEED SEARCH:  s = {s} seed bits, n = {n} data bits")
    print("=" * 72)
    gen = make_toy_generator(n, s)
    found = 0
    for x in all_strings(n):
        if seed_search(x, gen, 1 << s) is not None:
            found += 1
    total = 1 << n
    print(f"files with a seed     : {found} / {total}")
    print(f"success rate          : {found/total:.6f}")
    print(f"theoretical bound     : 2^(s-n) = {2.0**(s-n):.6f}")
    print("The algorithm is correct and exhaustive; it fails because the")
    print("object it seeks does not exist for almost every input.\n")


# ---------------------------------------------------------------------------
# 4. The hybrid compressor: the honest "compress to the seed" scheme
# ---------------------------------------------------------------------------


def make_toy_generator(n: int, s: int, mult: int = 1103515245,
                       inc: int = 12345) -> Callable[[int], Bits]:
    """A deterministic seed -> n-bit-string generator (an LCG bit stream)."""

    def gen(seed: int) -> Bits:
        state = (seed + 1) * 2654435761 % (1 << 32)
        out: List[int] = []
        while len(out) < n:
            state = (mult * state + inc) % (1 << 32)
            for shift in range(16, 32):          # use the high bits
                if len(out) == n:
                    break
                out.append((state >> shift) & 1)
        return tuple(out)

    return gen


def hybrid_decode(program: Sequence[int], generator: Callable[[int], Bits],
                  n: int, s: int) -> Bits:
    """The hybrid decompressor H_G.

    []        -> 0^n
    0 || q    -> G(seed given by the next s bits)      (seed mode)
    1 || q    -> the next n bits, zero-padded          (literal mode)
    """
    if len(program) == 0:
        return tuple([0] * n)
    flag, rest = program[0], program[1:]
    if flag == 0:
        return generator(bits_to_int(pad(rest, s)))
    return pad(rest, n)


def kolmogorov_profile(decoder: Callable[[Bits], Bits], n: int,
                       max_len: int) -> Dict[Bits, int]:
    """Exact K_D for every n-bit file, by running every program of length
    <= max_len in shortest-first order.  Theta(2^(max_len+1)) decoder calls."""
    best: Dict[Bits, int] = {}
    for p in all_programs_upto(max_len):
        x = decoder(p)
        if x not in best:
            best[x] = len(p)
    return best


def demo_hybrid_compressor(n: int = 12, s: int = 4) -> None:
    """All four properties of the hybrid scheme, verified by enumeration."""
    print("=" * 72)
    print(f"4. HYBRID COMPRESSOR:  n = {n}, s = {s}")
    print("=" * 72)
    gen = make_toy_generator(n, s)
    decoder = lambda p: hybrid_decode(p, gen, n, s)
    profile = kolmogorov_profile(decoder, n, n + 1)

    total = 1 << n
    assert len(profile) == total, "H_G must be complete (surjective)"

    gen_outputs = {gen(seed) for seed in range(1 << s)}
    short = [x for x, k in profile.items() if k <= s + 1]
    hardest = max(profile.items(), key=lambda kv: kv[1])

    print(f"(a) seed mode wins    : every generator output has K <= s+1 = {s+1}")
    print(f"    max K over image  : {max(profile[x] for x in gen_outputs)}")
    print(f"(b) literal mode safe : max K over all files = {max(profile.values())}"
          f"  (bound n+1 = {n+1})")
    print(f"(c) no free lunch     : some file has K >= n = {n}?  "
          f"{max(profile.values()) >= n}")
    print(f"    witness (K = {hardest[1]}) is a generator output?  "
          f"{hardest[0] in gen_outputs}")
    print(f"(d) the win is rare   : #{{K <= s+1}} = {len(short)} of {total}"
          f" = {len(short)/total:.6f}")
    print(f"    bound 2^(s+2-n)   = {2.0**(s+2-n):.6f}")

    print("\n    complexity histogram (K -> number of files):")
    hist: Dict[int, int] = {}
    for k in profile.values():
        hist[k] = hist.get(k, 0) + 1
    for k in sorted(hist):
        bar = "#" * min(50, hist[k])
        print(f"      K = {k:>3} : {hist[k]:>6}  {bar}")

    mean = sum(profile.values()) / total
    print(f"\n    mean description length = {mean:.4f} bits per file")
    print(f"    literal-only scheme     = {n+1} bits per file")
    print("    The flag bit costs 1 bit on every file to save n-s-1 bits on a")
    print("    vanishing fraction: the expected trade is a net loss.\n")


# ---------------------------------------------------------------------------
# 5. Rate bounds
# ---------------------------------------------------------------------------


def demo_rate_bounds(n: int = 12, s: int = 4) -> None:
    """Check the 2^(1-d) fraction bound and the average-length bound."""
    print("=" * 72)
    print(f"5. RATE BOUNDS:  n = {n}, s = {s}")
    print("=" * 72)
    gen = make_toy_generator(n, s)
    decoder = lambda p: hybrid_decode(p, gen, n, s)
    profile = kolmogorov_profile(decoder, n, n + 1)
    total = 1 << n

    print("  fraction of files whose description shrinks by d bits:")
    print(f"  {'d':>3} {'observed':>14} {'bound 2^(1-d)':>16}")
    for d in range(0, n + 1):
        count = sum(1 for k in profile.values() if k + d <= n)
        observed = count / total
        bound = 2.0 ** (1 - d)
        ok = "ok" if observed <= bound + 1e-12 else "VIOLATED"
        print(f"  {d:>3} {observed:>14.8f} {bound:>16.8f}   {ok}")

    mean = sum(profile.values()) / total
    print("\n  average description length vs the bound (n-k)(1 - 2^-k):")
    print(f"  {'k':>3} {'bound':>14} {'observed mean':>16}")
    for k in range(0, n):
        bound = (n - k) * (1 - 2.0 ** (-k))
        ok = "ok" if bound <= mean + 1e-9 else "VIOLATED"
        print(f"  {k:>3} {bound:>14.6f} {mean:>16.6f}   {ok}")
    best_k = max(range(0, n), key=lambda k: (n - k) * (1 - 2.0 ** (-k)))
    print(f"\n  best bound at k = {best_k}: "
          f"{(n-best_k)*(1-2.0**(-best_k)):.4f} bits per file")
    print(f"  (asymptotically n - O(log n); here n = {n})\n")


# ---------------------------------------------------------------------------
# 6. Libraries of generators
# ---------------------------------------------------------------------------


def demo_generator_library(n: int = 10, s: int = 3, m: int = 3) -> None:
    """A library of 2^m generators buys exactly m bits, and no more."""
    print("=" * 72)
    print(f"6. GENERATOR LIBRARY:  2^{m} generators, s = {s}, n = {n}")
    print("=" * 72)
    library = [make_toy_generator(n, s, mult=1103515245 + 2 * i,
                                  inc=12345 + 7 * i) for i in range(1 << m)]
    covered = set()
    for gen in library:
        for seed in range(1 << s):
            covered.add(gen(seed))
    total = 1 << n
    print(f"files reachable by SOME generator+seed : {len(covered)} / {total}")
    print(f"upper bound 2^(m+s) = 2^{m+s}            : {1 << (m + s)}")
    print(f"fraction                               : {len(covered)/total:.6f}")
    print(f"bound 2^(m+s-n)                        : {2.0**(m+s-n):.6f}")
    print(f"\nSurjectivity would force n <= m + s, i.e. {n} <= {m+s}:"
          f" {n <= m + s}")
    witness = next(x for x in all_strings(n) if x not in covered)
    print(f"a file unreachable by EVERY member of the library: "
          f"{''.join(map(str, witness))}")
    print("\nSelecting a generator is itself information: naming one of 2^m")
    print("costs exactly m bits, and that is the entire dividend.\n")


# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------


def main() -> None:
    print()
    print("PSEUDO-RANDOM GENERATORS CANNOT BEAT THE PIGEONHOLE BOUND")
    print("numerical demonstrations")
    print()
    demo_counting_core(kmax=8)
    demo_lcg_reachability()
    demo_seed_search(n=10, s=4)
    demo_hybrid_compressor(n=12, s=4)
    demo_rate_bounds(n=12, s=4)
    demo_generator_library(n=10, s=3, m=3)
    print("=" * 72)
    print("SUMMARY")
    print("=" * 72)
    print("A generator with an s-bit seed compresses its own <= 2^s outputs")
    print("perfectly, to s+1 bits, and helps with nothing else.  Every")
    print("refinement -- side patches, chaining, libraries, average-case")
    print("optimism -- is defeated by the same count: there are only")
    print("2^(k+1)-1 programs of length at most k, and 2^n files.")
    print()


if __name__ == "__main__":
    main()
