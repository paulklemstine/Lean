"""
Seed-compressibility of pseudorandom streams: numerical demonstrations.

This self-contained script exhibits, by direct computation over small finite
fields, every quantitative claim of the accompanying paper:

  1. LFSR streams and the window lemma (state = sliding window on future output).
  2. Exact detection: a stream satisfies the order-L recurrence iff it is LFSR
     output; the seed is literally the first L symbols.
  3. Linear congruential generators are order-two LFSRs:
         x_{t+2} = (a+1) x_{t+1} - a x_t,  seed (x0, a*x0 + b).
  4. The 2L theorem: two order-L streams agreeing on 2L symbols agree forever.
  5. Sharpness: an explicit pair agreeing on 2L-1 symbols and diverging at 2L-1.
  6. Berlekamp-Massey seed recovery, with the bit-exact reproduction gate.
  7. Enumeration of the linear-complexity filtration: the counts
         q=2: 3, 11, 43, 171, 683      q=3: 7, 61, 547
     matching the conjectured closed form (q^{2L+1}+1)/(q+1); saturation of the
     count at n = 2L; the zero-seed bound q^{2L} - q^L + 1.
  8. Router capacity: coverage never exceeds the total seed count.
  9. Noise tolerance: the additive threshold 2L + 2e + 1 fails; the
     multiplicative threshold 2L(2e+1) works and is sharp at order one.

Runs in a few seconds with no dependencies beyond the standard library.
"""

from __future__ import annotations

from itertools import product
from typing import Dict, List, Optional, Sequence, Tuple

# ----------------------------------------------------------------------------
# Prime-field arithmetic
# ----------------------------------------------------------------------------


def fadd(x: int, y: int, q: int) -> int:
    """Addition in the prime field GF(q)."""
    return (x + y) % q


def fmul(x: int, y: int, q: int) -> int:
    """Multiplication in the prime field GF(q)."""
    return (x * y) % q


def finv(x: int, q: int) -> int:
    """Multiplicative inverse in GF(q); raises on 0."""
    if x % q == 0:
        raise ZeroDivisionError("no inverse of 0 in GF(q)")
    return pow(x, q - 2, q)


# ----------------------------------------------------------------------------
# 1. The linear feedback shift register
# ----------------------------------------------------------------------------


def lfsr_step(taps: Sequence[int], state: Sequence[int], q: int) -> Tuple[int, ...]:
    """One clock tick: shift left, refill the vacated cell with the feedback."""
    feedback = 0
    for j, cj in enumerate(taps):
        feedback = fadd(feedback, fmul(cj, state[j], q), q)
    return tuple(state[1:]) + (feedback,)


def lfsr_stream(taps: Sequence[int], seed: Sequence[int], n: int, q: int) -> List[int]:
    """The first n output symbols of the order-L register with the given taps/seed."""
    state = tuple(seed)
    out: List[int] = []
    for _ in range(n):
        out.append(state[0] if state else 0)
        state = lfsr_step(taps, state, q)
    return out


def lfsr_state_after(taps: Sequence[int], seed: Sequence[int], k: int, q: int) -> Tuple[int, ...]:
    """The register state after k clock ticks."""
    state = tuple(seed)
    for _ in range(k):
        state = lfsr_step(taps, state, q)
    return state


def satisfies_recurrence(taps: Sequence[int], word: Sequence[int], q: int) -> bool:
    """Does the word obey y_{t+L} = sum_j c_j y_{t+j} everywhere it can be tested?"""
    L = len(taps)
    for t in range(len(word) - L):
        rhs = 0
        for j, cj in enumerate(taps):
            rhs = fadd(rhs, fmul(cj, word[t + j], q), q)
        if word[t + L] != rhs:
            return False
    return True


# ----------------------------------------------------------------------------
# 2. Linear congruential generators
# ----------------------------------------------------------------------------


def lcg_stream(a: int, b: int, x0: int, n: int, q: int) -> List[int]:
    """The full-output LCG x -> a*x + b, started at x0."""
    out: List[int] = []
    x = x0 % q
    for _ in range(n):
        out.append(x)
        x = fadd(fmul(a, x, q), b, q)
    return out


def lcg_as_lfsr(a: int, b: int, x0: int, q: int) -> Tuple[Tuple[int, int], Tuple[int, int]]:
    """The equivalent order-two register: taps (-a, a+1) and seed (x0, a*x0 + b)."""
    taps = ((-a) % q, (a + 1) % q)
    seed = (x0 % q, fadd(fmul(a, x0, q), b, q))
    return taps, seed


# ----------------------------------------------------------------------------
# 3. Berlekamp-Massey seed recovery over a prime field
# ----------------------------------------------------------------------------


def berlekamp_massey(word: Sequence[int], q: int) -> List[int]:
    """
    Minimal-order tap vector reproducing `word`, via the Berlekamp-Massey
    recurrence in O(n^2) field operations.

    Returns taps c = (c_0, ..., c_{L-1}) with y_{t+L} = sum_j c_j y_{t+j};
    the empty list means the word is all zero.
    """
    n = len(word)
    # connection polynomial C(x) = 1 + c_1 x + ... ; we convert taps at the end
    C = [1] + [0] * n
    B = [1] + [0] * n
    L, m, b = 0, 1, 1
    for i in range(n):
        d = word[i] % q
        for j in range(1, L + 1):
            d = fadd(d, fmul(C[j], word[i - j], q), q)
        if d == 0:
            m += 1
        elif 2 * L <= i:
            T = C[:]
            coef = fmul(d, finv(b, q), q)
            for j in range(n + 1 - m):
                C[j + m] = (C[j + m] - fmul(coef, B[j], q)) % q
            L, B, b, m = i + 1 - L, T, d, 1
        else:
            coef = fmul(d, finv(b, q), q)
            for j in range(n + 1 - m):
                C[j + m] = (C[j + m] - fmul(coef, B[j], q)) % q
            m += 1
    # y_{t+L} = -sum_{k=1..L} C_k y_{t+L-k}  =>  c_j = -C_{L-j}
    return [(-C[L - j]) % q for j in range(L)]


def recover_and_certify(word: Sequence[int], q: int) -> Dict[str, object]:
    """
    Full pipeline: recover minimal taps, take the seed to be the observed prefix,
    regenerate, and apply the bit-exact reproduction gate.
    """
    taps = berlekamp_massey(word, q)
    L = len(taps)
    seed = list(word[:L])
    regenerated = lfsr_stream(taps, seed, len(word), q)
    return {
        "order": L,
        "taps": taps,
        "seed": seed,
        "exact": regenerated == list(word),
        "certified_forever": len(word) >= 2 * L,
    }


# ----------------------------------------------------------------------------
# 4. Enumeration of the linear-complexity filtration
# ----------------------------------------------------------------------------


def lfsr_words(q: int, L: int, n: int) -> set:
    """All length-n words produced by an order-L register over GF(q)."""
    words = set()
    for taps in product(range(q), repeat=L):
        for seed in product(range(q), repeat=L):
            words.add(tuple(lfsr_stream(taps, seed, n, q)))
    return words


def conjectured_count(q: int, L: int) -> int:
    """The conjectured closed form (q^{2L+1} + 1) / (q + 1)."""
    num = q ** (2 * L + 1) + 1
    assert num % (q + 1) == 0
    return num // (q + 1)


def zero_seed_bound(q: int, L: int) -> int:
    """The improved counting bound q^{2L} - q^L + 1."""
    return q ** (2 * L) - q**L + 1


# ----------------------------------------------------------------------------
# 5. Noise tolerance
# ----------------------------------------------------------------------------


def hamming(u: Sequence[int], v: Sequence[int]) -> int:
    """Number of positions at which two equal-length words differ."""
    return sum(1 for x, y in zip(u, v) if x != y)


def additive_threshold_counterexample(e: int) -> Dict[str, object]:
    """
    Two distinct order-one streams over GF(3) and a word of length 2*1 + 2e + 1
    within Hamming distance e of both: the additive threshold fails.
    """
    q, n = 3, 2 * 1 + 2 * e + 1
    y = [1] * n                          # constant stream, tap 1
    z = [pow(2, t, q) for t in range(n)]  # alternating stream, tap 2
    w = [2 if i == 1 else 1 for i in range(n)]
    return {
        "e": e,
        "n": n,
        "y": y,
        "z": z,
        "w": w,
        "dist_to_y": hamming(w, y),
        "dist_to_z": hamming(w, z),
        "streams_distinct": y != z,
    }


def sharpness_witness(e: int) -> Dict[str, object]:
    """
    At length 4e + 1 = 2*1*(2e+1) - 1, one symbol short of the corrected
    threshold, unique decoding still fails at order one over GF(3).
    """
    q, n = 3, 4 * e + 1
    y = [1] * n
    z = [pow(2, t, q) for t in range(n)]
    w = [1 if i % 2 == 0 else (1 if i < 2 * e else 2) for i in range(n)]
    return {
        "e": e,
        "n": n,
        "dist_to_y": hamming(w, y),
        "dist_to_z": hamming(w, z),
        "streams_distinct": y != z,
    }


def clean_block(error_positions: Sequence[int], L: int, e: int) -> Optional[int]:
    """
    The block pigeonhole: among the 2e+1 disjoint blocks [2Lm, 2L(m+1)) at least
    one avoids all <= 2e error positions. Returns its starting index.
    """
    errors = set(error_positions)
    for m in range(2 * e + 1):
        lo, hi = 2 * L * m, 2 * L * (m + 1)
        if not any(lo <= i < hi for i in errors):
            return lo
    return None


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------


def demo_window_lemma() -> None:
    print("=" * 74)
    print("1. WINDOW LEMMA: cell i of the state after k ticks = output at time i+k")
    print("=" * 74)
    q, taps, seed = 2, (1, 1, 0, 1), (1, 0, 1, 1)
    L, n = len(taps), 20
    stream = lfsr_stream(taps, seed, n, q)
    print(f"  GF({q}), taps {taps}, seed {seed}")
    print(f"  stream: {''.join(map(str, stream))}")
    ok = True
    for k in range(n - L):
        state = lfsr_state_after(taps, seed, k, q)
        for i in range(L):
            ok &= state[i] == stream[i + k]
    print(f"  window lemma holds at every (i, k) tested: {ok}")
    print(f"  the seed is the first L={L} symbols: {stream[:L] == list(seed)}")
    print(f"  the stream obeys its order-{L} recurrence: "
          f"{satisfies_recurrence(taps, stream, q)}\n")


def demo_lcg_is_order_two() -> None:
    print("=" * 74)
    print("2. LCG IS AN ORDER-TWO LFSR:  x_{t+2} = (a+1) x_{t+1} - a x_t")
    print("=" * 74)
    for q, a, b, x0 in [(7, 3, 5, 2), (11, 4, 9, 6), (13, 5, 0, 1)]:
        n = 14
        lcg = lcg_stream(a, b, x0, n, q)
        taps, seed = lcg_as_lfsr(a, b, x0, q)
        reg = lfsr_stream(taps, seed, n, q)
        print(f"  GF({q}) a={a} b={b} x0={x0}")
        print(f"    LCG stream       : {lcg}")
        print(f"    order-2 register : {reg}   taps={taps} seed={seed}")
        print(f"    identical: {lcg == reg}    obeys recurrence: "
              f"{satisfies_recurrence(taps, lcg, q)}")
    print()


def demo_two_L_theorem() -> None:
    print("=" * 74)
    print("3. THE 2L THEOREM AND ITS SHARPNESS")
    print("=" * 74)
    q, L, horizon = 3, 3, 40
    print(f"  Exhaustive check over GF({q}), L={L}: every pair of order-{L}")
    print(f"  streams agreeing on the first 2L={2*L} symbols agrees to t={horizon}.")
    by_window: Dict[Tuple[int, ...], List[Tuple[int, ...]]] = {}
    for taps in product(range(q), repeat=L):
        for seed in product(range(q), repeat=L):
            s = tuple(lfsr_stream(taps, seed, horizon, q))
            by_window.setdefault(s[: 2 * L], []).append(s)
    violations = sum(1 for group in by_window.values() if len(set(group)) > 1)
    pairs = sum(len(g) * (len(g) - 1) // 2 for g in by_window.values())
    print(f"    distinct 2L-windows: {len(by_window)},  colliding pairs tested: {pairs}")
    print(f"    windows with a divergent pair: {violations}  (theorem predicts 0)")

    print(f"\n  Sharpness at each order L (impulse seed, taps 0 vs (1,0,...,0)):")
    for L2 in range(1, 6):
        impulse = tuple([0] * (L2 - 1) + [1])
        zero_taps = tuple([0] * L2)
        delay_taps = tuple([1] + [0] * (L2 - 1))
        n = 2 * L2 + 2
        s1 = lfsr_stream(zero_taps, impulse, n, 2)
        s2 = lfsr_stream(delay_taps, impulse, n, 2)
        agree = all(s1[t] == s2[t] for t in range(2 * L2 - 1))
        diverge = s1[2 * L2 - 1] != s2[2 * L2 - 1]
        print(f"    L={L2}: {''.join(map(str,s1))} vs {''.join(map(str,s2))} "
              f"| agree on first {2*L2-1}: {agree}, differ at {2*L2-1}: {diverge}")
    print()


def demo_recovery() -> None:
    print("=" * 74)
    print("4. SEED RECOVERY WITH THE BIT-EXACT REPRODUCTION GATE")
    print("=" * 74)
    q = 2
    taps, seed = (1, 0, 0, 1, 1), (1, 1, 0, 1, 0)
    word = lfsr_stream(taps, seed, 64, q)
    res = recover_and_certify(word, q)
    print(f"  hidden generator : taps={taps} seed={seed} over GF({q})")
    print(f"  observed 64 bits : {''.join(map(str, word))}")
    print(f"  recovered order  : {res['order']}   taps={res['taps']} seed={res['seed']}")
    print(f"  bit-exact reproduction of the observed window : {res['exact']}")
    print(f"  window >= 2L, so certified for the whole file : {res['certified_forever']}")
    ext_true = lfsr_stream(taps, seed, 4096, q)
    ext_rec = lfsr_stream(res["taps"], res["seed"], 4096, q)  # type: ignore[arg-type]
    print(f"  extrapolation to 4096 bits matches            : {ext_true == ext_rec}")
    print(f"  compression: 4096 bits -> {2 * res['order']} bits of taps+seed")

    print("\n  Maximal-complexity obstruction: the impulse word 0...01")
    for n in range(2, 9):
        impulse = [0] * (n - 1) + [1]
        r = recover_and_certify(impulse, 2)
        print(f"    n={n}: minimal order returned = {r['order']} (= n: {r['order'] == n}),"
              f" exact: {r['exact']}")
    print("    so no routine can always return an order <= ceil(n/2).\n")


def demo_enumeration() -> None:
    print("=" * 74)
    print("5. ENUMERATION OF THE LINEAR-COMPLEXITY FILTRATION")
    print("=" * 74)
    print("   q  L     |W_L(2L)|   (q^{2L+1}+1)/(q+1)   q^{2L}-q^L+1   q^{2L}")
    for q, Lmax in [(2, 3), (3, 2)]:
        for L in range(1, Lmax + 1):
            n = max(2 * L, 2)
            count = len(lfsr_words(q, L, n))
            print(f"   {q}  {L}   {count:10d}   {conjectured_count(q, L):18d}"
                  f"   {zero_seed_bound(q, L):12d}   {q**(2*L):6d}")
    print("\n  Saturation at n = 2L (counts stop growing once n reaches 2L):")
    for q, L in [(2, 2), (2, 3), (3, 1)]:
        row = [len(lfsr_words(q, L, n)) for n in range(1, 2 * L + 4)]
        print(f"    q={q}, L={L}, n=1..{2*L+3}: {row}   (2L = {2*L})")
    print("\n  Order one is exactly q^2 - q + 1 = (q^3+1)/(q+1):")
    for q in [2, 3, 5, 7]:
        exact = len(lfsr_words(q, 1, 3))
        print(f"    q={q}: enumerated {exact}, formula {q*q - q + 1}, "
              f"closed form {conjectured_count(q, 1)}")
    print()


def demo_router_capacity() -> None:
    print("=" * 74)
    print("6. ROUTER CAPACITY: coverage <= total number of seeds")
    print("=" * 74)
    q, n = 2, 6
    families: List[Tuple[str, int, set]] = []
    for L in range(0, 4):
        families.append((f"LFSR order {L}", q ** (2 * L), lfsr_words(q, L, n)))
    lcg_set = {tuple(lcg_stream(a, b, x0, n, q))
               for a in range(q) for b in range(q) for x0 in range(q)}
    families.append(("LCG family", q**3, lcg_set))

    routed: set = set()
    budget = 0
    print(f"  alphabet GF({q}), file length n={n}, total files = {q**n}")
    for name, seeds, words in families:
        routed |= words
        budget += seeds
        print(f"    + {name:16s} seeds={seeds:4d}  covers={len(words):4d}"
              f"  | routed so far={len(routed):4d}  budget={budget:4d}"
              f"  ok={len(routed) <= budget}")
    print(f"  coverage {len(routed)} / {q**n} files "
          f"= {len(routed) / q**n:.4f}; capacity ceiling {budget}")
    print(f"  some file is routed nowhere: {len(routed) < q**n}")
    print(f"  LCG words all lie in the order-2 LFSR family: "
          f"{lcg_set <= lfsr_words(q, 2, n)}")
    print("  (Hierarchy collapse: the union over orders <= M equals the order-M family:"
          f" {lfsr_words(q,1,n) <= lfsr_words(q,2,n) <= lfsr_words(q,3,n)})\n")


def demo_noise_tolerance() -> None:
    print("=" * 74)
    print("7. NOISE TOLERANCE: 2L+2e+1 FAILS, 2L(2e+1) WORKS AND IS SHARP")
    print("=" * 74)
    print("  (a) The additive threshold 2L + 2e + 1 is not enough:")
    for e in range(1, 6):
        c = additive_threshold_counterexample(e)
        print(f"    e={e}: n={c['n']}  d(w,y)={c['dist_to_y']}<=e  "
              f"d(w,z)={c['dist_to_z']}<=e  y!=z: {c['streams_distinct']}")
    c1 = additive_threshold_counterexample(1)
    print(f"    smallest instance (e=1, n=5): w={c1['w']}, y={c1['y']}, z={c1['z']}")

    print("\n  (b) The corrected threshold 2L(2e+1) is sharp at order one:")
    for e in range(1, 6):
        s = sharpness_witness(e)
        print(f"    e={e}: n={s['n']} = 2*1*(2e+1)-1, d(w,y)={s['dist_to_y']}, "
              f"d(w,z)={s['dist_to_z']}  -> decoding still ambiguous")

    print("\n  (c) At length 2L(2e+1) a clean length-2L block always exists:")
    import random

    random.seed(20260818)
    L, trials = 3, 20000
    for e in [1, 2, 3]:
        n = 2 * L * (2 * e + 1)
        worst = None
        for _ in range(trials):
            errs = random.sample(range(n), 2 * e)
            j = clean_block(errs, L, e)
            if j is None:
                worst = errs
                break
        print(f"    L={L}, e={e}, n={n}: clean block found in all {trials} random "
              f"placements of 2e={2*e} errors: {worst is None}")
    print()


def main() -> None:
    demo_window_lemma()
    demo_lcg_is_order_two()
    demo_two_L_theorem()
    demo_recovery()
    demo_enumeration()
    demo_router_capacity()
    demo_noise_tolerance()
    print("=" * 74)
    print("All demonstrations completed.")
    print("=" * 74)


if __name__ == "__main__":
    main()
