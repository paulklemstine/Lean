"""
Seed-compressible data: detection, identification and exact seed recovery.
==========================================================================

Numerical companion to the paper "Seed-Compressible Data: Detection,
Identification and Exact Seed Recovery for Pseudo-Random Streams".

Everything here is self-contained (standard library only) and each section
demonstrates one theorem from the paper:

  1. Exact seed recovery for a shift register: replaying the register from the
     first L observed symbols reproduces the stream bit for bit.
  2. The 2L-sample identification theorem: two streams of linear complexity at
     most L that agree on 2L symbols agree forever.  Sharpness: two streams of
     complexity exactly L that agree on 2L-1 symbols and then diverge.
  3. Berlekamp-Massey: recovering the minimal connection polynomial (and hence
     the taps) from a finite observation window over GF(2).
  4. Tap uniqueness <=> the state windows span F^L (the Hankel-rank criterion),
     including the degenerate all-zero stream where every tap vector works.
  5. Linear congruential generators are order-2 linear recurrences with taps
     (-a, 1+a); exact backward seed recovery by modular inversion and exact
     forward seed recovery by pure periodicity.
  6. The census of seed-compressible files: 43 distinct streams from the 64
     order-3 binary parameter pairs, against the proved bound
     4^L - 2^L + 1 = 57, and the naive bound 4^L = 64.
  7. Periodic files are seed-compressible with a 2p-bit description.
  8. The classifier dichotomy: a counting certificate that the two boxes
     "seed-compressible" and "model-compressible" do not cover file space.

Run with:  python3 demo.py
"""

from __future__ import annotations

from typing import Dict, List, Optional, Sequence, Set, Tuple


# ----------------------------------------------------------------------------
# 1. Shift registers over GF(2) and exact seed recovery
# ----------------------------------------------------------------------------


def lfsr_run(taps: Sequence[int], seed: Sequence[int], n: int) -> List[int]:
    """Run the order-L register x_{n+L} = sum_i taps[i] * x_{n+i} over GF(2).

    `taps[i]` is the coefficient multiplying x_{n+i}; `seed` supplies the first
    L symbols.  Returns the first `n` symbols of the output stream.
    """
    L = len(taps)
    out: List[int] = list(seed[:L])[:n]
    while len(out) < n:
        m = len(out) - L
        nxt = 0
        for i in range(L):
            nxt ^= taps[i] & out[m + i]
        out.append(nxt & 1)
    return out


def demo_seed_recovery() -> None:
    print("=" * 74)
    print("1. EXACT SEED RECOVERY  (replay from the first L symbols is exact)")
    print("=" * 74)
    taps = [1, 1, 0, 0, 1]          # x_{n+5} = x_n + x_{n+1} + x_{n+4}
    seed = [1, 0, 0, 1, 1]
    L = len(taps)
    stream = lfsr_run(taps, seed, 40)
    print(f"  taps            : {taps}")
    print(f"  seed            : {seed}")
    print(f"  stream (40 bits): {''.join(map(str, stream))}")

    # Re-run the register from the stream's own first L symbols.
    replay = lfsr_run(taps, stream[:L], 40)
    print(f"  replay          : {''.join(map(str, replay))}")
    print(f"  bit-exact match : {replay == stream}")
    print(f"  stored bits     : {2 * L} (taps + seed) vs {len(stream)} bits of data")
    print()


# ----------------------------------------------------------------------------
# 2. The 2L-sample identification theorem and its sharpness
# ----------------------------------------------------------------------------


def demo_two_L_window() -> None:
    print("=" * 74)
    print("2. THE 2L WINDOW  (2L samples identify a stream of complexity <= L)")
    print("=" * 74)
    L = 3
    all_pairs = [
        (taps, seed)
        for taps in _all_vectors(L)
        for seed in _all_vectors(L)
    ]
    horizon = 24

    # Group the 4^L parameter pairs by their first 2L symbols; the theorem says
    # each group emits a single stream.
    groups: Dict[Tuple[int, ...], Set[Tuple[int, ...]]] = {}
    for taps, seed in all_pairs:
        s = tuple(lfsr_run(taps, seed, horizon))
        groups.setdefault(s[: 2 * L], set()).add(s)

    ambiguous = {k: v for k, v in groups.items() if len(v) > 1}
    print(f"  order L                       : {L}")
    print(f"  parameter pairs enumerated    : {len(all_pairs)}")
    print(f"  distinct {2*L}-symbol prefixes    : {len(groups)}")
    print(f"  prefixes with >1 continuation : {len(ambiguous)}  (theorem: 0)")

    # Sharpness at 2L-1: find two complexity-<= L streams agreeing on 2L-1
    # symbols but differing at position 2L-1.
    by_prefix: Dict[Tuple[int, ...], List[Tuple[int, ...]]] = {}
    for taps, seed in all_pairs:
        s = tuple(lfsr_run(taps, seed, horizon))
        by_prefix.setdefault(s[: 2 * L - 1], []).append(s)
    witness = None
    for pref, streams in by_prefix.items():
        distinct = sorted(set(streams))
        if len(distinct) > 1:
            witness = (pref, distinct[0], distinct[1])
            break
    if witness is not None:
        pref, a, b = witness
        print(f"  sharpness witness, common {2*L-1}-prefix : {''.join(map(str, pref))}")
        print(f"    stream A : {''.join(map(str, a[:12]))}...")
        print(f"    stream B : {''.join(map(str, b[:12]))}...")
        print(f"    first disagreement at index {min(i for i in range(horizon) if a[i] != b[i])}"
              f"  (= 2L-1 = {2*L-1})")
    print()


def _all_vectors(L: int) -> List[List[int]]:
    return [[(v >> i) & 1 for i in range(L)] for v in range(2 ** L)]


# ----------------------------------------------------------------------------
# 3. Berlekamp-Massey over GF(2)
# ----------------------------------------------------------------------------


def berlekamp_massey_gf2(s: Sequence[int]) -> Tuple[int, List[int]]:
    """Minimal linear complexity L and connection polynomial C of `s` over GF(2).

    Returns (L, C) with C[0] = 1 and the recurrence
        s_j = sum_{i=1}^{L} C[i] * s_{j-i}     for all j >= L.
    Runs in O(n^2) bit operations on a length-n observation window.
    """
    n = len(s)
    C = [1] + [0] * n
    B = [1] + [0] * n
    L, m, b = 0, 1, 1
    for j in range(n):
        d = s[j]
        for i in range(1, L + 1):
            d ^= C[i] & s[j - i]
        if d == 0:
            m += 1
        elif 2 * L <= j:
            T = C[:]
            for i in range(0, n + 1 - m):
                C[i + m] ^= B[i] & b
            L, B, b, m = j + 1 - L, T, d, 1
        else:
            for i in range(0, n + 1 - m):
                C[i + m] ^= B[i] & b
            m += 1
    return L, C[: L + 1]


def taps_from_connection(C: Sequence[int], L: int) -> List[int]:
    """Convert a connection polynomial into the tap vector of the paper.

    C encodes s_j = sum_{i=1}^{L} C[i] s_{j-i}; the paper's convention is
    x_{n+L} = sum_{i<L} taps[i] x_{n+i}, so taps[i] = C[L - i].
    """
    return [C[L - i] if 0 < L - i <= L else 0 for i in range(L)]


def demo_berlekamp_massey() -> None:
    print("=" * 74)
    print("3. BERLEKAMP-MASSEY  (recovering unknown taps from the data alone)")
    print("=" * 74)
    secret_taps = [1, 0, 1, 1, 0, 0, 1]      # order 7
    secret_seed = [1, 1, 0, 1, 0, 0, 1]
    L_true = len(secret_taps)
    stream = lfsr_run(secret_taps, secret_seed, 4 * L_true)

    window = stream[: 2 * L_true]
    L_found, C = berlekamp_massey_gf2(window)
    taps_found = taps_from_connection(C, L_found)
    replay = lfsr_run(taps_found, stream[:L_found], len(stream))

    print(f"  hidden taps        : {secret_taps}")
    print(f"  observation window : {''.join(map(str, window))}  ({2*L_true} bits)")
    print(f"  recovered order    : {L_found}")
    print(f"  recovered taps     : {taps_found}")
    print(f"  replay reproduces the full {len(stream)}-bit stream : "
          f"{replay == stream}")
    print()

    # Sample complexity: how many bits are needed before the answer stabilises?
    print("  Convergence of the fitted complexity as the window grows:")
    row = []
    for k in range(1, 2 * L_true + 1):
        Lk, _ = berlekamp_massey_gf2(stream[:k])
        row.append(f"{k:>2}:{Lk}")
    print("    " + "  ".join(row))
    print(f"    (stabilises no later than 2L = {2*L_true} observations)")
    print()


# ----------------------------------------------------------------------------
# 4. Tap uniqueness <=> the state windows span F^L
# ----------------------------------------------------------------------------


def rank_gf2(rows: Sequence[Sequence[int]]) -> int:
    """Rank over GF(2) of a list of row vectors, by Gaussian elimination."""
    mat = [list(r) for r in rows]
    if not mat:
        return 0
    ncols = len(mat[0])
    rank, pivot_row = 0, 0
    for col in range(ncols):
        piv = None
        for r in range(pivot_row, len(mat)):
            if mat[r][col]:
                piv = r
                break
        if piv is None:
            continue
        mat[pivot_row], mat[piv] = mat[piv], mat[pivot_row]
        for r in range(len(mat)):
            if r != pivot_row and mat[r][col]:
                mat[r] = [a ^ b for a, b in zip(mat[r], mat[pivot_row])]
        pivot_row += 1
        rank += 1
    return rank


def consistent_tap_vectors(stream: Sequence[int], L: int) -> List[List[int]]:
    """All order-L tap vectors consistent with the observed stream."""
    out = []
    n = len(stream)
    for taps in _all_vectors(L):
        ok = all(
            stream[m + L] == _dot_gf2(taps, stream[m:m + L])
            for m in range(n - L)
        )
        if ok:
            out.append(taps)
    return out


def _dot_gf2(u: Sequence[int], v: Sequence[int]) -> int:
    acc = 0
    for a, b in zip(u, v):
        acc ^= a & b
    return acc


def demo_uniqueness_criterion() -> None:
    print("=" * 74)
    print("4. WHEN ARE THE TAPS UNIQUE?  (Hankel window rank = L)")
    print("=" * 74)
    L = 4
    horizon = 24
    cases = {
        "maximal-length register": ([1, 1, 0, 0], [1, 0, 1, 1]),
        "all-zero stream        ": ([1, 0, 1, 1], [0, 0, 0, 0]),
        "period-2 stream        ": ([0, 1, 0, 0], [1, 0, 1, 0]),
    }
    for name, (taps, seed) in cases.items():
        s = lfsr_run(taps, seed, horizon)
        windows = [s[m:m + L] for m in range(horizon - L)]
        r = rank_gf2(windows)
        cons = consistent_tap_vectors(s, L)
        print(f"  {name}")
        print(f"    stream          : {''.join(map(str, s[:20]))}...")
        print(f"    window rank     : {r} of {L}")
        print(f"    consistent taps : {len(cons)}  "
              f"(= 2^(L - rank) = {2 ** (L - r)})")
        print(f"    uniqueness      : {'YES' if len(cons) == 1 else 'NO'}"
              f"   (rank = L: {'YES' if r == L else 'NO'})")
    print("  In every case uniqueness of the taps holds exactly when the")
    print("  state windows span the whole space -- the Hankel-rank criterion.")
    print()


# ----------------------------------------------------------------------------
# 5. Linear congruential generators
# ----------------------------------------------------------------------------


def lcg_run(a: int, b: int, m: int, seed: int, n: int) -> List[int]:
    """First n outputs of x -> a*x + b (mod m) from the given seed."""
    out, x = [], seed % m
    for _ in range(n):
        out.append(x)
        x = (a * x + b) % m
    return out


def check_order2_recurrence(seq: Sequence[int], a: int, m: int) -> bool:
    """Verify x_{n+2} = (1+a) x_{n+1} - a x_n (mod m) along the sequence."""
    return all(
        seq[n + 2] % m == ((1 + a) * seq[n + 1] - a * seq[n]) % m
        for n in range(len(seq) - 2)
    )


def lcg_recover_seed_backward(a: int, b: int, m: int, state: int, n: int) -> int:
    """Undo n LCG steps by modular inversion: x -> a^{-1}(x - b)."""
    ai = pow(a, -1, m)
    x = state % m
    for _ in range(n):
        x = (ai * (x - b)) % m
    return x


def lcg_period(a: int, b: int, m: int, seed: int) -> int:
    """Length of the (purely periodic) orbit through `seed`."""
    x, k = (a * seed + b) % m, 1
    while x != seed % m:
        x = (a * x + b) % m
        k += 1
    return k


def demo_lcg() -> None:
    print("=" * 74)
    print("5. LINEAR CONGRUENTIAL GENERATORS  (an order-2 linear recurrence)")
    print("=" * 74)
    a, b, m, seed = 1103515245, 12345, 2 ** 31, 987654321
    seq = lcg_run(a, b, m, seed, 12)
    print(f"  x -> {a}*x + {b}  (mod 2^31),  seed = {seed}")
    print(f"  first outputs : {seq[:5]} ...")
    print(f"  satisfies x_(n+2) = (1+a)x_(n+1) - a x_n mod m : "
          f"{check_order2_recurrence(seq, a, m)}")
    print("  -> the SAME linear-recurrence detector that finds shift registers")
    print("     also finds every linear congruential generator.")

    n = 7
    recovered = lcg_recover_seed_backward(a, b, m, seq[n], n)
    print(f"  backward recovery from x_{n} = {seq[n]}")
    print(f"    recovered seed = {recovered}, correct : {recovered == seed}")

    a2, b2, m2, s2 = 5, 3, 64, 17
    p = lcg_period(a2, b2, m2, s2)
    fwd = lcg_run(a2, b2, m2, s2, p + 1)
    print(f"  small generator x -> {a2}x + {b2} mod {m2}: orbit period {p}")
    print(f"    forward recovery: x_{{k}} returns to the seed at k = {p}: "
          f"{fwd[p] == s2 % m2}")
    print("  -> on a finite state space with invertible multiplier the orbit is")
    print("     PURELY periodic, so the seed is reachable by running forward.")
    print()


# ----------------------------------------------------------------------------
# 6. The census of seed-compressible files
# ----------------------------------------------------------------------------


def census(L: int, horizon: int) -> Tuple[int, int, int]:
    """(#distinct streams, naive bound 4^L, proved bound 4^L - 2^L + 1)."""
    seen: Set[Tuple[int, ...]] = set()
    for taps in _all_vectors(L):
        for seed in _all_vectors(L):
            seen.add(tuple(lfsr_run(taps, seed, horizon)))
    return len(seen), 4 ** L, 4 ** L - 2 ** L + 1


def demo_census() -> None:
    print("=" * 74)
    print("6. HOW MANY FILES ARE SEED-COMPRESSIBLE?  (the census)")
    print("=" * 74)
    print(f"  {'L':>2} | {'distinct streams':>17} | {'(2*4^L+1)/3':>12} | "
          f"{'proved bound':>13} | {'naive 4^L':>10}")
    print("  " + "-" * 70)
    for L in range(1, 8):
        d, naive, proved = census(L, 2 * L + 2)
        formula = (2 * 4 ** L + 1) // 3
        flag = "" if d == formula else "  <-- formula mismatch!"
        print(f"  {L:>2} | {d:>17} | {formula:>12} | {proved:>13} | "
              f"{naive:>10}{flag}")
    print("  Two symbols of the window suffice to separate streams (the 2L")
    print("  theorem), so these counts are counts of distinct INFINITE streams.")
    print("  At L = 3 the census gives 43, against the proved bound 57 and the")
    print("  naive bound 64: the parameter count 4^L is never tight.  The data")
    print("  matches (2*4^L + 1)/3 exactly for every L tested, i.e. asymptotic")
    print("  density 2/3 of the parameter space -- an observed regularity, not")
    print("  a proved theorem.")
    print()


# ----------------------------------------------------------------------------
# 7. Periodic files are seed-compressible
# ----------------------------------------------------------------------------


def demo_periodic() -> None:
    print("=" * 74)
    print("7. PERIODIC DATA IS SEED-COMPRESSIBLE  (a 2p-bit description)")
    print("=" * 74)
    p, N = 6, 96
    pattern = [1, 1, 0, 1, 0, 0]
    file_bits = [pattern[i % p] for i in range(N)]
    taps = [1] + [0] * (p - 1)      # the repeating register
    replay = lfsr_run(taps, pattern, N)
    print(f"  file length N = {N}, period p = {p}")
    print(f"  file   : {''.join(map(str, file_bits[:36]))}...")
    print(f"  replay : {''.join(map(str, replay[:36]))}...")
    print(f"  exact reproduction : {replay == file_bits}")
    print(f"  description length : {2 * p} bits for {N} bits of data "
          f"(ratio {2 * p / N:.3f})")
    print()


# ----------------------------------------------------------------------------
# 8. The classifier dichotomy: a counting certificate
# ----------------------------------------------------------------------------


def dichotomy_certificate(N: int, L: int, d: int) -> bool:
    """Check 2^d * 2^(2L) + 2^(N+1) < 2^d * 2^N, the counting hypothesis."""
    return 2 ** d * 2 ** (2 * L) + 2 ** (N + 1) < 2 ** d * 2 ** N


def demo_dichotomy() -> None:
    print("=" * 74)
    print("8. THE ROUTER'S TWO BOXES DO NOT COVER FILE SPACE")
    print("=" * 74)
    for (N, L, d) in [(64, 8, 4), (64, 16, 4), (128, 32, 8), (64, 30, 4)]:
        ok = dichotomy_certificate(N, L, d)
        verdict = ("certificate holds: some N-bit file is neither "
                   "seed- nor model-compressible") if ok else \
                  "certificate fails: budgets too generous"
        print(f"  N={N:>4}, L={L:>3}, d={d:>2}  ->  {verdict}")
    print("  At N = 64, L = 8, d = 4 the inequality reads")
    print(f"    2^4*2^16 + 2^65 = {2**4 * 2**16 + 2**65} < "
          f"{2**4 * 2**64} = 2^4*2^64  ->  "
          f"{2**4 * 2**16 + 2**65 < 2**4 * 2**64}")
    print("  Detecting pseudo-random data enlarges what we can compress, but it")
    print("  does not repeal the pigeonhole bound.")
    print()


def main() -> None:
    demo_seed_recovery()
    demo_two_L_window()
    demo_berlekamp_massey()
    demo_uniqueness_criterion()
    demo_lcg()
    demo_census()
    demo_periodic()
    demo_dichotomy()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
