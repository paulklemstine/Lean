"""
Amortized model-delta compression: numerical demonstrations
===========================================================

A shared decompressor can be *steered* toward a domain by transmitting a patch (a
"model delta") of D bits.  Once steered, each message costs r bits of arithmetic-coded
residual instead of r + 1.  The question is when the patch pays for itself, and this
script demonstrates -- by brute force, by dynamic programming, and by min-plus matrix
powering -- the exact answers proved in the accompanying paper:

    1.  Coherent stream of n messages:      optimum = n*r + min(D, n)   (exactly)
    2.  Break-even:                          adaptive beats generic  <=>  n > D
    3.  Asymptotics:                         optimum / n  ->  r
    4.  Maximally incoherent (alternating):  optimum = n*r + ceil(n/2), independent of D
    5.  Block-alternating, block length L:   optimum = B*L*r
                                                       + floor(B/2)*min(2D, L)
                                                       + (B mod 2)*min(D, L)
        and the amortized rate  ->  r + min(2D, L) / (2L)   ("coherence-length law")
    6.  Tropical bridge: the optimum is an entry of a min-plus matrix power.
    7.  Pigeonhole floor: exactly 2^(t+1) - 1 bitstrings of length <= t, hence some
        source always needs more than t bits; and a domain patch alphabet of size K
        forces a patch longer than log2(K) - 1 bits.
    8.  Losslessness: an explicit shared codec round-trips an entire stream exactly.

Everything is self-contained: standard library only, all helpers inlined.

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import product
from math import ceil, floor
from typing import Callable, Dict, List, Sequence, Tuple

INF: int = 10**18

# --------------------------------------------------------------------------------------
# 1.  The model: decoder states, residual costs, model-delta costs
# --------------------------------------------------------------------------------------

# A decoder state is an int in range(k).  A residual cost is a tuple c with c[m] = bits to
# code one message when the decoder sits in state m.  A model-delta cost is a matrix
# delta with delta[i][j] = bits to move the shared decoder from state i to state j.

ResidualCost = Tuple[int, ...]
DeltaCost = List[List[int]]


def schedule_cost(
    delta: DeltaCost, start: int, stream: Sequence[ResidualCost], schedule: Sequence[int]
) -> int:
    """Total transmitted bits of an explicit schedule of decoder states."""
    total: int = 0
    prev: int = start
    for cost, state in zip(stream, schedule):
        total += delta[prev][state] + cost[state]
        prev = state
    return total


def opt_cost_bruteforce(
    delta: DeltaCost, start: int, stream: Sequence[ResidualCost]
) -> int:
    """Protocol optimum by exhaustive search over all |M|^n schedules (small n only)."""
    k: int = len(delta)
    best: int = INF
    for schedule in product(range(k), repeat=len(stream)):
        best = min(best, schedule_cost(delta, start, stream, schedule))
    return best if stream else 0


def opt_cost_dp(delta: DeltaCost, start: int, stream: Sequence[ResidualCost]) -> int:
    """Protocol optimum by the min-plus dynamic program.  O(n * k^2) time, O(k) space."""
    k: int = len(delta)
    value: List[int] = [0] * k          # value[m] = optimum of the remaining suffix from m
    for cost in reversed(list(stream)):
        nxt: List[int] = [INF] * k
        for prev in range(k):
            nxt[prev] = min(
                delta[prev][m] + cost[m] + value[m] for m in range(k)
            )
        value = nxt
    return value[start]


def opt_schedule_dp(
    delta: DeltaCost, start: int, stream: Sequence[ResidualCost]
) -> Tuple[int, List[int]]:
    """Optimum together with an optimal schedule, by storing argmin pointers."""
    k: int = len(delta)
    stream = list(stream)
    n: int = len(stream)
    value: List[List[int]] = [[0] * k for _ in range(n + 1)]
    arg: List[List[int]] = [[0] * k for _ in range(n + 1)]
    for i in range(n - 1, -1, -1):
        cost = stream[i]
        for prev in range(k):
            best_val, best_m = INF, 0
            for m in range(k):
                candidate = delta[prev][m] + cost[m] + value[i + 1][m]
                if candidate < best_val:
                    best_val, best_m = candidate, m
            value[i][prev], arg[i][prev] = best_val, best_m
    schedule: List[int] = []
    state: int = start
    for i in range(n):
        state = arg[i][state]
        schedule.append(state)
    return value[0][start], schedule


# --------------------------------------------------------------------------------------
# 2.  The two-state model: generic (state 0) vs specialized (state 1)
# --------------------------------------------------------------------------------------


def bool_cost(r: int) -> ResidualCost:
    """State 0 = generic pretrained model (r + 1 bits/message); state 1 = adapted (r)."""
    return (r + 1, r)


def bool_delta(d: int) -> DeltaCost:
    """Entering the specialized state from the generic one costs D bits; else free."""
    return [[0, d], [0, 0]]


def coherent_stream(r: int, n: int) -> List[ResidualCost]:
    """n statistically identical messages, all from one domain."""
    return [bool_cost(r)] * n


def sharp_law(r: int, d: int, n: int) -> int:
    """Closed form proved in the paper: n*r + min(D, n)."""
    return n * r + min(d, n)


# --------------------------------------------------------------------------------------
# 3.  The two-domain model: alternating and block-alternating streams
# --------------------------------------------------------------------------------------


def dom_cost(r: int, d: int) -> ResidualCost:
    """A message of domain d costs r bits in state d and r + 1 bits in the other state."""
    return tuple(r if m == d else r + 1 for m in (0, 1))


def swap_delta(d: int) -> DeltaCost:
    """Swapping the specialized decoder state costs D bits either way; staying is free."""
    return [[0, d], [d, 0]]


def alternating_stream(r: int, first_domain: int, n: int) -> List[ResidualCost]:
    """Domain flips at every single message: maximal incoherence."""
    return [dom_cost(r, (first_domain + i) % 2) for i in range(n)]


def block_stream(r: int, first_domain: int, blocks: int, length: int) -> List[ResidualCost]:
    """B blocks of L consecutive messages, the domain alternating from block to block."""
    out: List[ResidualCost] = []
    for b in range(blocks):
        out.extend([dom_cost(r, (first_domain + b) % 2)] * length)
    return out


def block_excess(d: int, length: int, blocks: int) -> int:
    """Closed form: floor(B/2)*min(2D, L) + (B mod 2)*min(D, L)."""
    return (blocks // 2) * min(2 * d, length) + (blocks % 2) * min(d, length)


def block_law(r: int, d: int, length: int, blocks: int) -> int:
    """Exact optimum of a block-alternating stream, starting in the wrong state."""
    return blocks * length * r + block_excess(d, length, blocks)


def coherence_rate(d: int, length: int) -> float:
    """Limiting amortized excess over the rate floor: min(2D, L) / (2L) bits/message."""
    return min(2 * d, length) / (2 * length)


# --------------------------------------------------------------------------------------
# 4.  The tropical (min-plus) bridge
# --------------------------------------------------------------------------------------


def tropical_matmul(a: List[List[int]], b: List[List[int]]) -> List[List[int]]:
    """Min-plus matrix product: (AB)_ij = min_k (A_ik + B_kj)."""
    n, m, p = len(a), len(b), len(b[0])
    return [
        [min(a[i][k] + b[k][j] for k in range(m)) for j in range(p)] for i in range(n)
    ]


def tropical_identity(n: int) -> List[List[int]]:
    """Min-plus identity: 0 on the diagonal (multiplicative unit), INF off it."""
    return [[0 if i == j else INF for j in range(n)] for i in range(n)]


def tropical_power(a: List[List[int]], n: int) -> List[List[int]]:
    """n-th min-plus power by exponentiation by squaring: O(k^3 log n)."""
    result = tropical_identity(len(a))
    base = [row[:] for row in a]
    while n > 0:
        if n & 1:
            result = tropical_matmul(result, base)
        base = tropical_matmul(base, base)
        n >>= 1
    return result


def cost_matrix(delta: DeltaCost, cost: ResidualCost) -> List[List[int]]:
    """A_ij = delta(i, j) + c(j): move the decoder to state j, then code one message."""
    k = len(delta)
    return [[delta[i][j] + cost[j] for j in range(k)] for i in range(k)]


def tropical_optimum(delta: DeltaCost, cost: ResidualCost, start: int, n: int) -> int:
    """(A^{ox n} ox 1)_start: the coherent-stream optimum read off a tropical power."""
    power = tropical_power(cost_matrix(delta, cost), n)
    return min(power[start])  # tropical product with the all-ones (all-zero) vector


# --------------------------------------------------------------------------------------
# 5.  Counting: the pigeonhole floor and the cost of a patch alphabet
# --------------------------------------------------------------------------------------


def count_short_bitstrings(t: int) -> int:
    """Brute-force count of bitstrings of length at most t; equals 2^(t+1) - 1."""
    return sum(2**length for length in range(t + 1))


def pigeonhole_threshold(num_sources: int) -> int:
    """Largest t with 2^(t+1) <= num_sources: some source needs more than t bits."""
    t = -1
    while 2 ** (t + 2) <= num_sources:
        t += 1
    return t


def stream_counting_floor(n: int, s: int) -> int:
    """Every lossless scheme spends >= n*s bits on some stream of n symbols from 2^s."""
    return n * s


# --------------------------------------------------------------------------------------
# 6.  Losslessness: an explicit shared codec
# --------------------------------------------------------------------------------------


def build_shared_codec(
    domain: Sequence[str], s: int
) -> Tuple[Callable[[str], int], Callable[[int], str]]:
    """A codec at rate s bits/message, exactly lossless on `domain` when |domain| <= 2^s."""
    if len(domain) > 2**s:
        raise ValueError("domain does not fit in 2^s codewords")
    table: Dict[str, int] = {x: i for i, x in enumerate(domain)}
    inverse: Dict[int, str] = {i: x for x, i in table.items()}
    fallback: str = domain[0]

    def encode(x: str) -> int:
        return table.get(x, 0)

    def decode(i: int) -> str:
        return inverse.get(i, fallback)

    return encode, decode


def roundtrip_stream(
    encode: Callable[[str], int], decode: Callable[[int], str], xs: Sequence[str]
) -> List[str]:
    """Encode then decode a whole stream, message by message."""
    return [decode(encode(x)) for x in xs]


# --------------------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------------------


def demo_bellman_optimality() -> None:
    print("=" * 78)
    print("1.  BELLMAN OPTIMALITY:  dynamic program == minimum over all schedules")
    print("=" * 78)
    r, d = 3, 4
    delta = bool_delta(d)
    for n in range(0, 9):
        stream = coherent_stream(r, n)
        brute = opt_cost_bruteforce(delta, 0, stream)
        dp = opt_cost_dp(delta, 0, stream)
        assert brute == dp, (n, brute, dp)
    print(f"  r = {r}, D = {d}:  exhaustive search over 2^n schedules agrees with the")
    print("  min-plus dynamic program for every n = 0..8.   [verified]")
    value, schedule = opt_schedule_dp(delta, 0, coherent_stream(r, 8))
    print(f"  Optimal schedule for n = 8:  {schedule}   (cost {value} bits)")
    print("  Reading: state 0 = generic, state 1 = specialized.  The encoder pays the")
    print("  patch on the first message and never switches again.\n")


def demo_sharp_law() -> None:
    print("=" * 78)
    print("2.  SHARP AMORTIZATION LAW:  optimum = n*r + min(D, n),  break-even at n = D")
    print("=" * 78)
    r, d = 5, 6
    delta, cost = bool_delta(d), bool_cost(r)
    print(f"  r = {r} bits/message specialized, {r + 1} generic;  patch D = {d} bits\n")
    print("     n   optimum   n*r+min(D,n)   generic n*(r+1)   adaptive wins?")
    print("   " + "-" * 66)
    for n in range(0, 13):
        dp = opt_cost_dp(delta, 0, coherent_stream(r, n))
        closed = sharp_law(r, d, n)
        generic = n * (r + 1)
        assert dp == closed
        assert (dp < generic) == (d < n)
        mark = "yes" if dp < generic else "no "
        print(f"   {n:3d}   {dp:7d}   {closed:12d}   {generic:15d}   {mark}")
    print()
    print(f"  Break-even is EXACTLY at n = D = {d}: the patch pays for itself on message")
    print(f"  {d + 1} and not one message sooner.  For n <= D the optimum equals the")
    print("  delta-free generic cost exactly -- the patch is strictly wasted.\n")


def demo_asymptotics() -> None:
    print("=" * 78)
    print("3.  THE MODEL DELTA IS ASYMPTOTICALLY FREE:  optimum / n  ->  r")
    print("=" * 78)
    r, d = 5, 1000
    print(f"  r = {r},  a deliberately enormous patch D = {d} bits\n")
    print("          n     optimum/n     excess over r")
    print("   " + "-" * 42)
    for n in (10, 100, 1_000, 10_000, 100_000, 1_000_000):
        value = sharp_law(r, d, n)      # closed form, validated against the DP above
        rate = value / n
        print(f"   {n:10d}   {rate:11.6f}   {rate - r:13.6f}")
    print()
    print("  The excess is min(D, n)/n = D/n once n > D: it vanishes, however large the")
    print("  patch.  Concavity check  V(n) + V(n+2) <= 2 V(n+1)  (economies of scale):")
    ok = all(
        sharp_law(r, d, n) + sharp_law(r, d, n + 2) <= 2 * sharp_law(r, d, n + 1)
        for n in range(0, 2000)
    )
    print(f"  holds for n = 0..1999:  {ok}\n")


def demo_incoherence() -> None:
    print("=" * 78)
    print("4.  MAXIMAL INCOHERENCE:  stream length does NOT amortize the delta")
    print("=" * 78)
    r = 4
    print(f"  Two domains, r = {r}; the domain flips at EVERY message.\n")
    print("      D    n   optimum   n*r+ceil(n/2)   rate     (floor n*r)")
    print("   " + "-" * 60)
    for d in (1, 3, 50):
        for n in (4, 8, 16, 64):
            stream = alternating_stream(r, 1, n)     # decoder starts in the wrong state
            dp = opt_cost_dp(swap_delta(d), 0, stream)
            closed = n * r + ceil(n / 2)
            assert dp == closed, (d, n, dp, closed)
            print(f"   {d:4d} {n:4d}   {dp:7d}   {closed:13d}   {dp / n:6.3f}   {n * r:11d}")
    print()
    print("  The optimum does not depend on D at all: switching is never worth it, and")
    print("  the protocol loses half a bit per message forever.  Amortized rate ->")
    print(f"  r + 1/2 = {r + 0.5}.  A trillion messages would not help.\n")


def demo_coherence_length_law() -> None:
    print("=" * 78)
    print("5.  THE COHERENCE-LENGTH LAW:  excess rate = min(2D, L) / (2L)")
    print("=" * 78)
    r, d = 4, 8
    print(f"  Two domains, r = {r}, patch D = {d} bits; B blocks of L messages,")
    print("  the domain alternating from block to block.\n")
    print("      L    B   DP optimum   closed form   excess/msg   limit min(2D,L)/(2L)")
    print("   " + "-" * 74)
    for length in (1, 4, 8, 16, 64):
        for blocks in (2, 5, 10):
            stream = block_stream(r, 1, blocks, length)   # start in the wrong state
            dp = opt_cost_dp(swap_delta(d), 0, stream)
            closed = block_law(r, d, length, blocks)
            assert dp == closed, (length, blocks, dp, closed)
            msgs = blocks * length
            excess = (dp - msgs * r) / msgs
            print(
                f"   {length:4d} {blocks:4d}   {dp:10d}   {closed:11d}   "
                f"{excess:10.4f}   {coherence_rate(d, length):19.4f}"
            )
    print()
    print(f"  Threshold at L = 2D = {2 * d}:")
    print(f"    L < {2 * d}:  excess = 1/2 bit/message, INDEPENDENT of D -- never patch.")
    print(f"    L >= {2 * d}: excess = D/L -> 0 -- the patch amortizes against the block.")
    print("  What amortizes the model delta is the COHERENCE LENGTH, not the stream")
    print("  length.  Sorting a stream by domain is therefore worth, per message:")
    for l1, l2 in ((1, 64), (4, 128), (8, 1024)):
        gain = coherence_rate(d, l1) - coherence_rate(d, l2)
        print(f"    sorting L = {l1:4d} -> {l2:5d}:  {gain:.4f} bits/message saved")
    print()


def demo_tropical_bridge() -> None:
    print("=" * 78)
    print("6.  THE TROPICAL BRIDGE:  the optimum is a min-plus matrix power")
    print("=" * 78)
    r, d = 3, 7
    delta, cost = bool_delta(d), bool_cost(r)
    matrix = cost_matrix(delta, cost)
    print(f"  r = {r}, D = {d}.  Cost matrix A_ij = delta(i,j) + c(j) (rows: from-state):")
    for i, row in enumerate(matrix):
        print(f"      state {i}:  {row}")
    print()
    print("      n   (A^n ox 1)_generic   dynamic program   n*r+min(D,n)")
    print("   " + "-" * 62)
    for n in (0, 1, 3, 7, 8, 15, 40):
        trop = tropical_optimum(delta, cost, 0, n)
        dp = opt_cost_dp(delta, 0, coherent_stream(r, n))
        closed = sharp_law(r, d, n)
        assert trop == dp == closed, (n, trop, dp, closed)
        print(f"   {n:4d}   {trop:18d}   {dp:15d}   {closed:12d}")
    print()
    print("  Ordinary matrix powers count paths; min-plus powers find the shortest one.")
    print("  Exponentiation by squaring computes the optimum for a stream of length")
    print("  n = 10^18 in O(log n) steps:")
    huge = 10**18
    print(f"      n = 10^18:  optimum = {tropical_optimum(delta, cost, 0, huge)} bits")
    print(f"      closed form:          {sharp_law(r, d, huge)} bits")
    print("  The kink of the piecewise-linear function n -> n*r + min(D, n) at n = D is")
    print("  literally a tropical corner.\n")


def demo_counting_floor() -> None:
    print("=" * 78)
    print("7.  THE PIGEONHOLE FLOOR AND THE PRICE OF A PATCH ALPHABET")
    print("=" * 78)
    print("      t   #bitstrings of length <= t   2^(t+1) - 1")
    print("   " + "-" * 52)
    for t in range(0, 9):
        counted = count_short_bitstrings(t)
        assert counted == 2 ** (t + 1) - 1
        print(f"   {t:4d}   {counted:26d}   {2 ** (t + 1) - 1:11d}")
    print()
    n, s = 1000, 8
    print(f"  Streaming floor: {n} messages over a {2**s}-symbol alphabet require at")
    print(f"  least n*s = {stream_counting_floor(n, s)} bits on some stream -- delta,")
    print("  residuals, framing and all -- for ANY lossless scheme.")
    protocol = 4096 + n * s
    print(f"  The amortized protocol with a {4096}-bit patch spends {protocol} bits:")
    print(f"  a gap of exactly {protocol - stream_counting_floor(n, s)} bits, independent of n.")
    print()
    print("  Patch alphabet (a decompressor steerable to K domains):")
    print("       K    forced patch length > t bits    break-even delayed to n > t")
    print("   " + "-" * 66)
    for k in (2, 16, 256, 65_536, 10**6):
        t = pigeonhole_threshold(k)
        print(f"   {k:7d}   {t:29d}   {t:26d}")
    print()
    print("  Some domain's patch always exceeds about log2(K) - 1 bits, and for THAT")
    print("  domain the adaptive protocol is worth exactly nothing until the stream")
    print("  is longer than that many messages: a logarithmic warm-up delay.\n")


def demo_losslessness() -> None:
    print("=" * 78)
    print("8.  THE LOSSLESSNESS GATE:  exact reconstruction of an entire stream")
    print("=" * 78)
    domain = ["the", "quick", "brown", "fox", "jumps", "over", "lazy", "dog"]
    s = 3
    encode, decode = build_shared_codec(domain, s)
    stream = ["the", "quick", "brown", "fox", "jumps", "over", "the", "lazy", "dog"]
    decoded = roundtrip_stream(encode, decode, stream)
    assert decoded == stream
    print(f"  Domain of {len(domain)} messages fits in 2^{s} = {2**s} codewords.")
    print(f"  Input stream : {stream}")
    print(f"  Codewords    : {[encode(x) for x in stream]}")
    print(f"  Decoded      : {decoded}")
    print(f"  Exact match  : {decoded == stream}")
    n = len(stream)
    d = 40
    print()
    print(f"  Bit accounting for n = {n} messages with a D = {d}-bit patch:")
    print(f"    counting floor        n*s          = {n * s} bits")
    print(f"    amortized protocol    D + n*s      = {d + n * s} bits")
    print(f"    generic protocol      n*(s+1)      = {n * (s + 1)} bits")
    print(f"    adaptive wins?        D < n        = {d < n}")
    print("  Here the stream is far shorter than the patch, so the optimal protocol")
    print("  declines to send the patch at all -- exactly as the sharp law predicts.\n")


def main() -> None:
    print()
    print("#" * 78)
    print("#  AMORTIZED MODEL-DELTA COMPRESSION -- the model is free, the delta is not")
    print("#" * 78)
    print()
    demo_bellman_optimality()
    demo_sharp_law()
    demo_asymptotics()
    demo_incoherence()
    demo_coherence_length_law()
    demo_tropical_bridge()
    demo_counting_floor()
    demo_losslessness()
    print("=" * 78)
    print("All closed forms verified against brute-force search and dynamic programming.")
    print("=" * 78)
    print()


if __name__ == "__main__":
    main()
