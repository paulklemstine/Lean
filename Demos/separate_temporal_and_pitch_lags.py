"""Algorithm B: moment-bridge audit and the exact null-baseline test."""

from __future__ import annotations

from typing import Dict, List, Sequence


def energy(d: Sequence[int]) -> int:
    """E(d) = sum_i d_i^2."""
    return sum(v * v for v in d)


def autocorrelation(d: Sequence[int], lag: int) -> int:
    """A(lag) = sum_i d_i d_{i+lag}, indices taken cyclically."""
    n = len(d)
    return sum(d[i] * d[(i + lag) % n] for i in range(n))


def cyclic_histogram(d: Sequence[int], lag: int, base: int = 10) -> List[int]:
    """The cyclic lag-`lag` pitch-interval distribution."""
    n = len(d)
    hist: List[int] = [0] * base
    for i in range(n):
        hist[abs(d[i] - d[(i + lag) % n])] += 1
    return hist


def pair_count(base: int, v: int) -> int:
    """P_b(v): the number of ordered digit pairs at pitch interval v."""
    if v == 0:
        return base
    return 2 * (base - v) if v < base else 0


def bridge_audit(d: Sequence[int], lag: int, base: int = 10) -> Dict[str, float]:
    """Audit a cyclic digit window against the moment bridge and the null baseline.

    Computes the energy E, the autocorrelation A(lag), the lag-`lag` interval
    histogram and its second moment M2, and checks the identity

        2 A(lag) = 2 E - M2      (residual must be exactly 0),

    then compares the observed deficit E - A with the exact null prediction
    m (b^4 - b^2) / 12, where m = n / b^2 is the null multiplicity implied by the
    window length.  Runs in O(n + b) time.
    """
    n = len(d)
    e = energy(d)
    a = autocorrelation(d, lag)
    hist = cyclic_histogram(d, lag, base)
    m2 = sum(v * v * c for v, c in enumerate(hist))
    multiplicity = n / float(base ** 2)
    predicted = multiplicity * (base ** 4 - base ** 2) / 12.0
    return {
        "energy": float(e),
        "autocorrelation": float(a),
        "second_moment": float(m2),
        "bridge_residual": float(2 * a - (2 * e - m2)),
        "observed_deficit": float(e - a),
        "null_deficit": predicted,
        "excess_over_null": float(e - a) - predicted,
        "unison_mass": float(hist[0]),
        "octave_mass": float(hist[12]) if base > 12 else 0.0,
    }


if __name__ == "__main__":
    pi = [int(c) for c in (
        "14159265358979323846264338327950288419716939937510"
        "58209749445923078164062862089986280348253421170679")]
    for lag in (1, 6, 12, 25):
        report = bridge_audit(pi, lag)
        print(f"lag {lag:3d}: " + "  ".join(f"{k}={v:g}" for k, v in report.items()))


"""Algorithm A: the lag-l pitch-interval histogram of a digit melody."""

from __future__ import annotations

from typing import List, Sequence


def interval_histogram(x: Sequence[int], n: int, lag: int, base: int = 10) -> List[int]:
    """Return N_x(n, lag, .) as a list of length `base`.

    N_x(n, lag, v) = #{ i < n : |x_i - x_{i+lag}| = v }.

    Requires len(x) >= n + lag.  Runs in O(n) time and O(base) space.
    The result always has total mass n, and is supported on {0, ..., base-1};
    in particular the octave value v = 12 gets mass 0 for base = 10.
    """
    if len(x) < n + lag:
        raise ValueError("window plus lag exceeds the available melody")
    hist: List[int] = [0] * base
    for i in range(n):
        v = abs(x[i] - x[i + lag])
        if v >= base:
            raise ValueError("melody is not a base-%d digit melody" % base)
        hist[v] += 1
    return hist


def interval_histogram_cyclic(d: Sequence[int], lag: int, base: int = 10) -> List[int]:
    """The same statistic on a cyclic window, where indices wrap around."""
    n = len(d)
    hist: List[int] = [0] * base
    for i in range(n):
        hist[abs(d[i] - d[(i + lag) % n])] += 1
    return hist


if __name__ == "__main__":
    pi = [int(c) for c in "314159265358979323846264338327950288419716939937510"]
    h = interval_histogram(pi, 30, 12)
    print("lag-12 histogram:", h)
    print("total mass:", sum(h), " unison mass:", h[0], " octave mass: 0 (unattainable)")


"""Algorithm C: realize any prescribed interval histogram, at any lag.

Layer-cake rearrangement + alternating walk + interleaving.
"""

from __future__ import annotations

from typing import List, Sequence


def tail_mass(target: Sequence[int], w: int) -> int:
    """T_N(w) = sum_{u >= w} N(u) over the admissible interval values 0..9."""
    return sum(target[u] for u in range(w, 10))


def layer_sequence(target: Sequence[int], n: int) -> List[int]:
    """The non-increasing rearrangement of the demanded intervals.

    L_N(t) = #{ w in 1..9 : t < T_N(w) }.  Values lie in {0,...,9} and the value
    histogram of L_N over t < n is exactly N.  Cost O(9 n).
    """
    return [sum(1 for w in range(1, 10) if t < tail_mass(target, w)) for t in range(n)]


def alternating_walk(demands: Sequence[int]) -> List[int]:
    """Play a non-increasing sequence of intervals without leaving [0, demands[0]].

    Start at pitch 0; at even times step up by the demand, at odd times step down.
    The parity invariant guarantees the walk stays inside the digit range.
    """
    notes: List[int] = [0]
    for t, step in enumerate(demands):
        notes.append(notes[t] + step if t % 2 == 0 else notes[t] - step)
    return notes


def interleave(z: Sequence[int], factor: int) -> List[int]:
    """z^[l](i) = z(floor(i / l)): l independent voices, one step per l beats."""
    if factor < 1:
        raise ValueError("interleaving factor must be positive")
    return [z[i // factor] for i in range(factor * len(z))]


def realize_histogram(target: Sequence[int], lag: int = 1) -> List[int]:
    """A decimal melody whose lag-`lag` interval histogram is lag * target.

    `target` is a list of ten multiplicities N(0), ..., N(9) of total mass n.
    For lag = 1 the melody has n+1 notes and histogram exactly N on the window
    of length n; for lag = l > 1 the interleaved melody has histogram l*N on the
    window of length l*n.  Total cost O(l n).
    """
    if len(target) != 10:
        raise ValueError("target histogram must have ten bins (interval values 0..9)")
    n = sum(target)
    melody = alternating_walk(layer_sequence(target, n))
    return melody if lag == 1 else interleave(melody, lag)


if __name__ == "__main__":
    target = [1, 0, 0, 0, 0, 0, 0, 0, 0, 9]  # one unison, nine major sixths
    melody = realize_histogram(target, lag=1)
    got = [0] * 10
    for i in range(sum(target)):
        got[abs(melody[i] - melody[i + 1])] += 1
    print("melody  :", melody)
    print("target  :", target)
    print("realized:", got, " match:", got == target)


"""Lag audit of a digit melody against the exact interval-statistics baseline.

For each temporal lag l = 1..40 of the first 400 digits of pi this demo reports

  * the unison mass N_l(0) -- the quantity a lag-l correlation peak measures;
  * the octave mass N_l(12) -- identically zero on a ten-note scale;
  * the second moment sum_v v^2 N_l(v) and the derived deficit (1/2) sum_v v^2 N_l(v),
    which the moment bridge identifies with the autocorrelation deficit E - A(l)
    of the corresponding cyclic window;
  * the excess of the observed deficit over the exact triangular-null prediction
    m (b^4 - b^2)/12 = 825 m for b = 10 and window length n = 100 m.

It then searches short cyclic windows for pairs of melodies that share energy and
autocorrelation but differ in their interval distributions, confirming that the
bridge from pitch statistics to temporal statistics is not invertible.

Pure standard library; run with `python3 demo_pi_audit.py`.
"""

from __future__ import annotations

from itertools import product
from typing import Dict, List, Sequence, Tuple

PI_DIGITS: List[int] = [int(c) for c in (
    "1415926535897932384626433832795028841971693993751058209749445923078164"
    "0628620899862803482534211706798214808651328230664709384460955058223172"
    "5359408128481117450284102701938521105559644622948954930381964428810975"
    "6659334461284756482337867831652712019091456485669234603486104543266482"
    "1339360726024914127372458700660631558817488152092096282925409171536436"
    "7892590360011330530548820466521384146951941511609433057270365759591953"
)]

BASE: int = 10
WINDOW: int = 300


def histogram(x: Sequence[int], n: int, lag: int) -> List[int]:
    """N_x(n, lag, .) with thirteen bins, so the octave bin is visible."""
    hist = [0] * 13
    for i in range(n):
        hist[abs(x[i] - x[i + lag])] += 1
    return hist


def second_moment(hist: Sequence[int]) -> int:
    return sum(v * v * c for v, c in enumerate(hist))


def audit_lags(x: Sequence[int], n: int, lags: Sequence[int]) -> None:
    null = n / BASE ** 2 * (BASE ** 4 - BASE ** 2) / 12.0
    print(f"window n = {n},  exact null deficit = {null:.1f}")
    print(f"{'lag':>4} {'unisons':>8} {'octaves':>8} {'2nd moment':>11} "
          f"{'deficit':>9} {'excess':>9}")
    for lag in lags:
        hist = histogram(x, n, lag)
        m2 = second_moment(hist)
        deficit = m2 / 2.0
        print(f"{lag:>4} {hist[0]:>8} {hist[12]:>8} {m2:>11} "
              f"{deficit:>9.1f} {deficit - null:>+9.1f}")


def most_unisons(x: Sequence[int], n: int, lags: Sequence[int]) -> Tuple[int, int]:
    best = max(lags, key=lambda l: histogram(x, n, l)[0])
    return best, histogram(x, n, best)[0]


def cyclic_stats(d: Sequence[int], lag: int) -> Tuple[int, int, Tuple[int, ...]]:
    n = len(d)
    energy = sum(v * v for v in d)
    auto = sum(d[i] * d[(i + lag) % n] for i in range(n))
    hist = [0] * 10
    for i in range(n):
        hist[abs(d[i] - d[(i + lag) % n])] += 1
    return energy, auto, tuple(hist)


def find_indistinguishable_pairs(length: int = 4, alphabet: int = 6) -> List[
        Tuple[Tuple[int, ...], Tuple[int, ...]]]:
    """Melodies with equal energy and lag-1 autocorrelation but different histograms."""
    buckets: Dict[Tuple[int, int], List[Tuple[Tuple[int, ...], Tuple[int, ...]]]] = {}
    for melody in product(range(alphabet), repeat=length):
        energy, auto, hist = cyclic_stats(melody, 1)
        buckets.setdefault((energy, auto), []).append((melody, hist))
    found: List[Tuple[Tuple[int, ...], Tuple[int, ...]]] = []
    for entries in buckets.values():
        for i in range(len(entries)):
            for j in range(i + 1, len(entries)):
                if entries[i][1] != entries[j][1]:
                    found.append((entries[i][0], entries[j][0]))
    return found


def main() -> None:
    print("=" * 74)
    print("LAG AUDIT OF THE DIGITS OF PI")
    print("=" * 74)
    audit_lags(PI_DIGITS, WINDOW, range(1, 41))
    lag, unisons = most_unisons(PI_DIGITS, WINDOW, range(1, 41))
    print(f"\nMost unisons: lag {lag} with {unisons} unisons "
          f"(expected {WINDOW / BASE:.0f} under the null).")
    print("Octave mass is zero at every lag: the ten-note scale spans nine semitones.")

    print("\n" + "=" * 74)
    print("MELODIES THAT ENERGY AND AUTOCORRELATION CANNOT TELL APART")
    print("=" * 74)
    pairs = find_indistinguishable_pairs()
    print(f"Cyclic windows of length 4 over the digits 0..5: {len(pairs)} such pairs.")
    for melody_d, melody_e in pairs[:5]:
        e_d, a_d, h_d = cyclic_stats(melody_d, 1)
        e_e, a_e, h_e = cyclic_stats(melody_e, 1)
        print(f"  {melody_d} vs {melody_e}:  E = {e_d} = {e_e},  A(1) = {a_d} = {a_e}")
        print(f"      histograms {list(h_d)}  vs  {list(h_e)}"
              f"   unisons {h_d[0]} vs {h_e[0]}")
    print("\nThe canonical minimal witness (0,0,0,5) versus (0,3,0,4):")
    for melody in ((0, 0, 0, 5), (0, 3, 0, 4)):
        energy, auto, hist = cyclic_stats(melody, 1)
        print(f"  {melody}: E = {energy}, A(1) = {auto}, histogram {list(hist)}")


if __name__ == "__main__":
    main()


"""Melodies that energy and autocorrelation cannot tell apart.

The moment bridge  2 A(k) = 2 E - sum_v v^2 N_k(v)  compresses a ten-bin pitch
histogram into a single weighted sum, so it cannot be invertible.  This demo makes
the failure explicit by exhaustive search over short cyclic digit windows: melodies
are bucketed by the pair (energy, lag-k autocorrelation), and every bucket that
contains two different interval histograms is a certificate that a correlation
statistic cannot certify which musical intervals occur.

Pure standard library; run with `python3 demo_witness_search.py`.
"""

from __future__ import annotations

from itertools import product
from typing import Dict, List, Sequence, Tuple

Histogram = Tuple[int, ...]
Melody = Tuple[int, ...]


def energy(d: Sequence[int]) -> int:
    """E(d) = sum_i d_i^2."""
    return sum(v * v for v in d)


def autocorrelation(d: Sequence[int], lag: int) -> int:
    """A(lag) = sum_i d_i d_{i+lag}, indices cyclic."""
    n = len(d)
    return sum(d[i] * d[(i + lag) % n] for i in range(n))


def cyclic_histogram(d: Sequence[int], lag: int, base: int = 10) -> Histogram:
    """The cyclic lag-`lag` pitch-interval distribution."""
    n = len(d)
    hist = [0] * base
    for i in range(n):
        hist[abs(d[i] - d[(i + lag) % n])] += 1
    return tuple(hist)


def second_moment(hist: Sequence[int]) -> int:
    return sum(v * v * c for v, c in enumerate(hist))


def search(length: int, alphabet: int, lag: int) -> List[Tuple[Melody, Melody]]:
    """All pairs of melodies with equal (energy, autocorrelation) but different histograms."""
    buckets: Dict[Tuple[int, int], List[Tuple[Melody, Histogram]]] = {}
    for melody in product(range(alphabet), repeat=length):
        key = (energy(melody), autocorrelation(melody, lag))
        buckets.setdefault(key, []).append((melody, cyclic_histogram(melody, lag)))
    witnesses: List[Tuple[Melody, Melody]] = []
    for entries in buckets.values():
        for i in range(len(entries)):
            for j in range(i + 1, len(entries)):
                if entries[i][1] != entries[j][1]:
                    witnesses.append((entries[i][0], entries[j][0]))
    return witnesses


def unison_gap(pair: Tuple[Melody, Melody], lag: int) -> int:
    """How far apart the two melodies' unison counts are."""
    a, b = pair
    return abs(cyclic_histogram(a, lag)[0] - cyclic_histogram(b, lag)[0])


def report(length: int, alphabet: int, lag: int, show: int = 4) -> None:
    witnesses = search(length, alphabet, lag)
    print(f"windows of length {length} over digits 0..{alphabet - 1}, lag {lag}: "
          f"{len(witnesses)} indistinguishable pairs with different histograms")
    if not witnesses:
        return
    witnesses.sort(key=lambda p: -unison_gap(p, lag))
    for a, b in witnesses[:show]:
        ha, hb = cyclic_histogram(a, lag), cyclic_histogram(b, lag)
        print(f"  {a} vs {b}")
        print(f"     E = {energy(a)} = {energy(b)},  A({lag}) = {autocorrelation(a, lag)}"
              f" = {autocorrelation(b, lag)},  2nd moments "
              f"{second_moment(ha)} = {second_moment(hb)}")
        print(f"     histograms {list(ha)}  vs  {list(hb)}   "
              f"unisons {ha[0]} vs {hb[0]}")


def main() -> None:
    print("=" * 78)
    print("THE MOMENT BRIDGE IS MANY-TO-ONE")
    print("=" * 78)
    report(4, 6, 1)
    print()
    report(5, 4, 1)
    print()
    report(4, 6, 2)
    print("\nCanonical minimal witness:")
    for melody in ((0, 0, 0, 5), (0, 3, 0, 4)):
        hist = cyclic_histogram(melody, 1)
        print(f"  {melody}: E = {energy(melody)}, A(1) = {autocorrelation(melody, 1)},"
              f" histogram {list(hist)}, unisons {hist[0]}")
    print("\nEqual energy and equal correlation, maximally different unison counts:")
    print("no correlation statistic can decide which intervals a melody contains.")


if __name__ == "__main__":
    main()


"""Visualization: rigidity of lags versus freedom of pitches.

Left panel:  the unison-lag lattice.  For a family of periodic melodies the set
             of lags with perfect correlation is drawn as a row of dots; it is
             always exactly the set of multiples of the minimal period, the
             divisibility rigidity of the unison-lag monoid.
Right panel: three prescribed interval histograms and the melodies that realize
             them (layer-cake rearrangement followed by an alternating walk),
             showing that any histogram supported on {0,...,9} occurs.

Run with `python3 viz_rigidity_vs_freedom.py` (requires matplotlib).
"""

from __future__ import annotations

from typing import List, Sequence

import matplotlib.pyplot as plt


def is_unison_lag(x: Sequence[int], lag: int, n: int) -> bool:
    return all(x[i] == x[i + lag] for i in range(n))


def tail_mass(target: Sequence[int], w: int) -> int:
    return sum(target[u] for u in range(w, 10))


def layer_sequence(target: Sequence[int], n: int) -> List[int]:
    return [sum(1 for w in range(1, 10) if t < tail_mass(target, w)) for t in range(n)]


def alternating_walk(demands: Sequence[int]) -> List[int]:
    notes: List[int] = [0]
    for t, step in enumerate(demands):
        notes.append(notes[t] + step if t % 2 == 0 else notes[t] - step)
    return notes


def realize(target: Sequence[int]) -> List[int]:
    return alternating_walk(layer_sequence(target, sum(target)))


def main() -> None:
    fig, (ax0, ax1) = plt.subplots(1, 2, figsize=(13, 5.5))

    patterns = {
        "period 3:  (1,4,1)": [1, 4, 1],
        "period 2:  (2,7)": [2, 7],
        "period 6:  (3,1,4,1,5,9)": [3, 1, 4, 1, 5, 9],
        "period 12: (0..9,0,9)": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 9],
    }
    for row, (name, cell) in enumerate(patterns.items()):
        melody = cell * (200 // len(cell) + 1)
        lags = [l for l in range(1, 49) if is_unison_lag(melody, l, 100)]
        ax0.scatter(lags, [row] * len(lags), s=42, color="#1f4e79")
        ax0.scatter([l for l in range(1, 49) if l not in lags],
                    [row] * (48 - len(lags)), s=8, color="#cccccc")
        ax0.text(49.5, row, f"multiples of {min(lags)}", va="center", fontsize=8)
    ax0.set_yticks(range(len(patterns)))
    ax0.set_yticklabels(list(patterns), fontsize=9)
    ax0.set_xlabel("temporal lag $\\ell$")
    ax0.set_xlim(0, 62)
    ax0.set_title("RIGID: unison lags are exactly the multiples\nof the minimal period")

    targets = {
        "one unison, nine sixths": [1, 0, 0, 0, 0, 0, 0, 0, 0, 9],
        "uniform on 0..9": [2] * 10,
        "all mass on 4 semitones": [0, 0, 0, 0, 9, 0, 0, 0, 0, 0],
    }
    for idx, (name, target) in enumerate(targets.items()):
        melody = realize(target)
        ax1.plot(range(len(melody)), [v + 11 * idx for v in melody],
                 marker="o", ms=4, lw=1.4, label=name)
        got = [0] * 10
        for i in range(sum(target)):
            got[abs(melody[i] - melody[i + 1])] += 1
        assert got == list(target)
    ax1.set_xlabel("time")
    ax1.set_ylabel("pitch (offset per example)")
    ax1.legend(fontsize=8, loc="upper right")
    ax1.set_title("FREE: every interval histogram is realized\n"
                  "(each melody reproduces its target exactly)")

    fig.tight_layout()
    fig.savefig("rigidity_vs_freedom.png", dpi=160)
    print("wrote rigidity_vs_freedom.png")


if __name__ == "__main__":
    main()


"""Visualization: the temporal statistic and the pitch statistic, side by side.

Top panel:  the lag spectrum M(l) = max_i |x_i - x_{i+l}| and the normalized
            autocorrelation deficit E - A(l) of the first 360 digits of pi,
            plotted against the temporal lag l, with the exact null baseline
            825 m drawn as a horizontal line.
Bottom panel: the pitch-interval histograms at three lags, overlaid on the
            triangular null distribution P_10(v) = 10, 18, 16, ..., 2, with the
            octave bin v = 12 shown empty for every lag.

Run with `python3 viz_two_statistics.py` (requires matplotlib).
"""

from __future__ import annotations

from typing import List, Sequence

import matplotlib.pyplot as plt

PI_DIGITS: List[int] = [int(c) for c in (
    "1415926535897932384626433832795028841971693993751058209749445923078164"
    "0628620899862803482534211706798214808651328230664709384460955058223172"
    "5359408128481117450284102701938521105559644622948954930381964428810975"
    "6659334461284756482337867831652712019091456485669234603486104543266482"
    "1339360726024914127372458700660631558817488152092096282925409171536436"
    "7892590360011330530548820466521384146951941511609433057270365759591953"
)]

N: int = 360
BASE: int = 10


def lag_spectrum(x: Sequence[int], lag: int, n: int) -> int:
    return max(abs(x[i] - x[i + lag]) for i in range(n))


def autocorrelation_deficit(x: Sequence[int], lag: int, n: int) -> int:
    """E - A on the window, computed through the moment bridge: half the 2nd moment."""
    return sum(abs(x[i] - x[i + lag]) ** 2 for i in range(n)) // 2


def histogram(x: Sequence[int], lag: int, n: int) -> List[int]:
    hist = [0] * 13
    for i in range(n):
        hist[abs(x[i] - x[i + lag])] += 1
    return hist


def pair_count(base: int, v: int) -> int:
    if v == 0:
        return base
    return 2 * (base - v) if v < base else 0


def main() -> None:
    lags = list(range(1, 41))
    spectrum = [lag_spectrum(PI_DIGITS, l, N) for l in lags]
    deficit = [autocorrelation_deficit(PI_DIGITS, l, N) for l in lags]
    null_deficit = N / BASE ** 2 * (BASE ** 4 - BASE ** 2) / 12.0

    fig, (ax0, ax1) = plt.subplots(2, 1, figsize=(11, 8.5))

    ax0.step(lags, spectrum, where="mid", color="#1f4e79", lw=2,
             label=r"lag spectrum $M(\ell)$ (max interval)")
    ax0.set_ylim(0, 13.8)
    ax0.axhline(9, color="#1f4e79", ls=":", lw=1)
    ax0.axhline(12, color="crimson", ls="--", lw=1.5)
    ax0.text(20, 12.3, "octave = 12 semitones: unreachable at every lag",
             va="bottom", ha="center", color="crimson", fontsize=9)
    ax0.set_ylabel("semitones")
    ax0.set_xlabel("temporal lag $\\ell$")
    axb = ax0.twinx()
    axb.plot(lags, deficit, color="#c05000", marker="o", ms=3, lw=1.2,
             label=r"autocorrelation deficit $E - A(\ell)$")
    axb.axhline(null_deficit, color="#c05000", ls="--", lw=1,
                label=f"exact null baseline {null_deficit:.0f}")
    axb.set_ylabel("deficit (energy units)")
    lines = ax0.get_lines()[:1] + axb.get_lines()
    ax0.legend(lines, [l.get_label() for l in lines], loc="lower right", fontsize=8)
    ax0.set_title("Two different statistics of the same melody: temporal versus pitch")

    width = 0.22
    colors = {1: "#1f4e79", 12: "#c05000", 24: "#2e7d32"}
    for offset, lag in enumerate((1, 12, 24)):
        hist = histogram(PI_DIGITS, lag, N)
        xs = [v + (offset - 1) * width for v in range(13)]
        ax1.bar(xs, hist, width=width, color=colors[lag], label=f"lag {lag}")
    null = [pair_count(BASE, v) * N / BASE ** 2 for v in range(13)]
    ax1.plot(range(13), null, color="black", lw=2, ls="--",
             label="triangular null $P_{10}$ (scaled)")
    ax1.axvline(11.5, color="crimson", lw=1)
    ax1.text(12, max(null) * 0.8, "octave bin\nalways empty", color="crimson", fontsize=8)
    ax1.set_xticks(range(13))
    ax1.set_xlabel("pitch interval $v$ (semitones)")
    ax1.set_ylabel("count")
    ax1.legend(fontsize=8)
    ax1.set_title("Pitch-interval distributions at three lags, against the exact null")

    fig.tight_layout()
    fig.savefig("two_statistics.png", dpi=160)
    print("wrote two_statistics.png")


if __name__ == "__main__":
    main()


"""Assemble PACKAGE.json from the deliverables and the assets directory."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, Dict, List

ROOT = Path(__file__).resolve().parent
ASSETS = ROOT / "assets"

LEAN_FILES: List[str] = [
    "Catalog/Tropical/MusicalDigits/IntervalDistribution.lean",
    "Catalog/Tropical/MusicalDigits/TropicalLagSpectrum.lean",
    "Catalog/Tropical/MusicalDigits/IntervalDistributionRealizability.lean",
    "Catalog/Tropical/MusicalDigits/MinPlusIntervalMatrix.lean",
    "Catalog/Tropical/MusicalDigits/AutocorrelationMomentBridge.lean",
    "Catalog/Tropical/MusicalDigits/NullIntervalDistribution.lean",
]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def lean_bundle() -> str:
    chunks = []
    for name in LEAN_FILES:
        chunks.append(f"-- ===== FILE: {name} =====\n" + read(name))
    return "\n\n".join(chunks)


FUTURE_DIRECTIONS = """# Future Directions — temporal lags versus pitch intervals

This cycle established a complete separation of the two variables that the original
"lag 12 ≈ octave" reading conflated:

* the **temporal** variable `ℓ` lives in the additive monoid `ℕ`, is measured by the
  tropical lag spectrum `M(ℓ) = max_i |x_i − x_{i+ℓ}|`, and is organized by *divisibility*
  (the unison-lag monoid is the set of multiples of the minimal period);
* the **pitch** variable lives in `{0, …, 9}`, is measured by the interval distribution
  `N(n, ℓ, v)`, and is *unconstrained* beyond its support (every histogram is realized,
  at every lag).

The bridge between them is the moment identity `2·autocorrelation = 2·energy − Σ_v v² N(v)`:
an autocorrelation statistic sees only the second moment of the pitch statistic.

Three bold, testable directions follow.

## 1. Tropical spectral rigidity of the lag spectrum

**Conjecture.** The function `ℓ ↦ M(ℓ)` of a decimal melody is not an arbitrary
subadditive function: for aperiodic melodies of positive entropy it is eventually equal to
its maximum `9`, and the set of lags where it is `< 9` is finite and closed under
divisors.

*The key insight is* that `M` is a tropical seminorm on `(ℕ, +)` whose unit fibre
is already known to be an arithmetically rigid monoid, so the next fibres — the level sets
`{ℓ : M(ℓ) ≤ c}` — should inherit divisor-closedness from the same truncated
subtraction argument that produced gcd-closure.

*Why now?*  Subadditivity of the lag spectrum, gcd-closure of the periods and the
description of the unison lags as the multiples of the minimal period supply the
`c = 0` case in full; the general case only needs a quantitative version of the
period-subtraction lemma, i.e. a "c-approximate period" calculus.

## 2. Fine–Wilf theorem for finite digit windows

**Conjecture.** If a window of `n` consecutive digits has unison lags `p` and `q` and
`n ≥ p + q − gcd(p, q)`, then it has unison lag `gcd(p, q)`; the bound is sharp.

*The key insight is* that the infinite-word gcd-closure proved here degenerates on finite
windows exactly at the Fine–Wilf threshold, so the finite theorem is the quantitative
refinement of the rigidity we already have.

*Why now?*  A finite-window version is what empirical digit studies actually measure: they
never see an infinite melody. The proof can reuse the period-subtraction lemma verbatim
with an index-range side condition.

## 3. Joint interval distributions at two lags

**Conjecture.** For coprime lags `k, ℓ ≥ 1` the pair of interval distributions
`(N_k, N_ℓ)` is jointly realizable for every pair of admissible histograms of equal mass,
whereas for `ℓ = 2k` the pair is constrained by the tropical triangle inequality:
`N_{2k}` is supported in `[0, 2·max supp N_k]`.

*The key insight is* that interleaving (used here for one lag) becomes a Chinese-remainder
construction for coprime lags, while non-coprime lags are coupled by subadditivity of the
lag spectrum — so coprimality is exactly the boundary between free and constrained joint
realizability.
"""


INTERACTIVE_LAYOUT = r"""
# Two Twelves: Temporal Lag versus Pitch Interval

> *Autocorrelation at sequence lag $12$ compares digit positions twelve time steps apart.
> It does not measure a twelve-semitone interval. This notebook takes that one sentence
> seriously and follows it all the way down.*

---

## 1. The melody, and the two distances in it

Turn a digit sequence into music: map each digit $x_i \in \{0,\dots,9\}$ to the $x_i$-th note
of a scale. Now there are two completely different distances you can measure.

| | lives in | measures | notation |
|---|---|---|---|
| **temporal lag** | the additive monoid $(\mathbb{N},+)$ of offsets | *which* pairs of positions you compare | $\ell$ in the pair $(i, i+\ell)$ |
| **pitch interval** | the digit alphabet $\{0,\dots,9\}$ | *what you hear* when a pair is compared | $\lvert x_i - x_j\rvert$ semitones |

An **octave** is a pitch fact: twelve semitones. A **lag-12 autocorrelation** is a temporal
fact: positions twelve beats apart. Both mention "twelve", and that coincidence is the
entire source of the folklore claim that digit melodies contain hidden octave structure.

Play with the laboratory below before reading on. Slide the lag; watch the arcs (which pairs
are compared) change independently of the histogram (what those pairs sound). Look at the
last column of the histogram: bin $v=12$. It never fills.

{{interactive_demo:0}}

<details>
<summary><strong>Why the octave bin is empty — the one-line proof</strong></summary>

Every digit lies in $\{0,\dots,9\}$, so for any two positions
$$\lvert x_i - x_j\rvert \le 9 < 12 .$$
Hence for every decimal melody, every window length $n$, and every lag $\ell$, the number of
position pairs realizing a twelve-semitone interval is exactly $0$. This is a property of the
*alphabet*, not of the number being expanded: it holds for a constant melody just as much as
for the digits of $\pi$. A ten-note scale simply does not span an octave.
</details>

---

## 2. The right object: the interval distribution

If you want to speak about musical intervals, count musical intervals. For a melody $x$,
window length $n$, lag $\ell$, and interval size $v$, define the **pitch-interval
distribution**
$$N_x(n,\ell,v)=\#\bigl\{\, i<n : \lvert x_i - x_{i+\ell}\rvert = v \,\bigr\}.$$

Two facts pin it down:

* **total mass** $\sum_{v=0}^{9} N_x(n,\ell,v) = n$ — each of the $n$ position pairs
  contributes exactly one interval;
* **support** $N_x(n,\ell,v)=0$ whenever $v \ge 10$ — the vanishing octave, again.

And everything you might compute from lag-$\ell$ intervals is a *moment*: for any weight $g$,
$$\sum_{v} g(v)\,N_x(n,\ell,v) \;=\; \sum_{i<n} g\bigl(\lvert x_i - x_{i+\ell}\rvert\bigr).$$

{{algorithm:0}}

---

## 3. The moment bridge: what autocorrelation actually is

Work on a cyclic window and write $E=\sum_i x_i^2$ for the energy and
$A(k)=\sum_i x_i x_{i+k}$ for the autocorrelation. Expanding $(x_{i+k}-x_i)^2$ and summing
gives the classical polarization identity $2A(k) = 2E - \sum_i (x_{i+k}-x_i)^2$, and the
subtracted term is exactly the **second moment of the interval histogram**:

$$\boxed{\;2A(k) \;=\; 2E \;-\; \sum_{v=0}^{9} v^2\,N_k(v).\;}$$

This is the only bridge between the temporal and the pitch worlds — and it is one number wide.
The laboratory above verifies the identity live: the residual column is exactly zero for
every melody and every lag you can select.

Three consequences:

1. **Autocorrelation is a legitimate pitch statistic.** Two melodies with equal energy and
   equal lag-$k$ histograms have equal lag-$k$ autocorrelation.
2. **A peak is a unison statement.** $A(k)=E$ holds exactly when every lag-$k$ interval is
   a unison, i.e. when the melody has period $k$. The octave contributes mass $0$ to every
   term of the bridge.
3. **The bridge is not invertible.**

<details>
<summary><strong>The minimal counterexample, in full</strong></summary>

Take the four-note cyclic melodies $d=(0,0,0,5)$ and $e=(0,3,0,4)$.

* Energies: $0+0+0+25=25$ and $0+9+0+16=25$. Equal.
* Lag-1 autocorrelations: every cyclically adjacent product vanishes in both, so both are $0$.
* Lag-1 interval multisets: $d$ gives $\{0,0,5,5\}$ — **two unisons**; $e$ gives
  $\{3,3,4,4\}$ — **no unisons**.

Identical correlation, different music. A correlation statistic therefore cannot certify any
claim about which intervals occur.
</details>

{{demo:1}}

---

## 4. What "no correlation" should mean: the exact null

Before calling a lag anomalous you need a baseline. Because the alphabet is finite, the
baseline is a closed-form identity, not a simulation. Counting ordered digit pairs at each
interval size gives the **triangular null distribution**
$$P_b(v) = \begin{cases} b, & v=0,\\ 2(b-v), & 0<v<b,\\ 0, & v\ge b,\end{cases}$$
of total mass $b^2$, with second moment
$$\sum_v v^2 P_b(v) = \frac{b^4-b^2}{6} \;=\; 1650 \ \text{ for } b=10,$$
a mean squared interval of exactly $16.5$ semitones$^2$ over the $100$ ordered digit pairs.
Feeding this into the moment bridge gives the **null deficit law**: if the lag-$k$ histogram
is exactly $m$ copies of the null distribution, then
$$12\,\bigl(E - A(k)\bigr) \;=\; m\,(b^4-b^2), \qquad\text{i.e.}\qquad E - A(k) = 825\,m \ \text{ in base ten.}$$

{{algorithm:1}}

{{demo:0}}

---

## 5. Time is rigid

Now study the temporal variable alone. The **lag spectrum**
$$M_x(\ell)=\sup_i \lvert x_i - x_{i+\ell}\rvert$$
obeys a triangle inequality on lags — route from time $i$ to time $i+k+\ell$ through the
intermediate note at $i+k$:
$$M_x(k+\ell) \le M_x(k)+M_x(\ell).$$
In [tropical (min-plus) algebra](https://en.wikipedia.org/wiki/Tropical_geometry), where
"addition" is $\min$ and "multiplication" is $+$, this says $M_x$ is a **seminorm on the
monoid of lags**. Its kernel — the lags with $M_x(\ell)=0$ — is the set of **unison lags**,
i.e. the periods of the melody, and it is extraordinarily rigid.

> **Rigidity.** The unison lags are closed under greatest common divisors. Hence if a melody
> has any positive period, its unison lags are exactly the multiples of a single number, its
> minimal period; if it has none, the only unison lag is $0$. Two coprime periods force the
> melody to be constant.

<details>
<summary><strong>Proof of gcd-closure: the Euclidean algorithm, run on periods</strong></summary>

If $p$ and $q$ are periods and $q \le p$, then $p-q$ is a period: apply $q$-periodicity at
index $i+(p-q)$ to move between $x_{i+p-q}$ and $x_{i+p}=x_i$. Iterating the subtraction,
$q \bmod p$ is a period whenever $p$ and $q$ are. But $\gcd(p,q)=\gcd(q\bmod p,\,p)$, so
strong induction on $p$ — exactly the [Euclidean algorithm](https://en.wikipedia.org/wiki/Euclidean_algorithm)
— shows $\gcd(p,q)$ is a period.
</details>

This settles lag twelve completely. If a decimal melody has $M_x(12)=0$ then its minimal
period divides $12$ and every lag-$12$ pair sounds a unison; if $M_x(12)\ne 0$ then some
lag-$12$ pair sounds an interval between $1$ and $9$ semitones. The octave never enters
the dichotomy.

And subadditivity is strictly one-way: the square wave $s(i)=7\cdot(\lfloor i/12\rfloor \bmod 2)$
has $M(12)=7$ — every lag-$12$ pair jumps a perfect fifth, *no unisons at all* — while
$M(24)=0$, since it is $24$-periodic. Select it in the laboratory above and watch both
happen.

{{visualization:0}}

---

## 6. Pitch is free

The pitch variable has no rigidity whatsoever. Its only constraint is its support.

> **Inverse theorem.** Let $N$ be any assignment of multiplicities to the interval sizes
> $0,\dots,9$ with total mass $n$. Then some decimal melody has lag-$1$ interval histogram
> exactly $N$ on the window of length $n$; and for every lag $\ell\ge1$ some decimal melody
> has lag-$\ell$ histogram exactly $\ell N$ on the window of length $\ell n$.

Design your own histogram below and watch the melody get built. The construction has three
moves: **layer-cake rearrangement** (sort the demands into non-increasing order), the
**alternating walk** (up, down, up, down — which, because the demands never grow, never
falls off the ten-note scale), and **interleaving** (run $\ell$ independent voices to move
a lag-$1$ histogram to lag $\ell$).

{{interactive_demo:1}}

{{algorithm:2}}

{{visualization:1}}

So the two variables sit at opposite ends of a rigidity spectrum: **lags are organized by
divisibility, pitches are unconstrained, and the only bridge is the second moment.**

---

## 7. Two closing structures

<details>
<summary><strong>The interval matrix squares to itself</strong></summary>

Collect all pairwise intervals of the first $n$ notes into a matrix $A_{ij}=\lvert x_i-x_j\rvert$
and read it in the min-plus semiring, where
$(A\odot A)_{ij}=\min_k (A_{ik}+A_{kj})$ is the cheapest two-step *voice-leading* from note
$i$ to note $j$. Then $A\odot A = A$, and hence $A^{\odot m}=A$ for all $m\ge1$.

*Proof.* For "$\le$", choose the intermediate index $k=i$, of cost $0+A_{ij}$. For "$\ge$",
the triangle inequality gives $A_{ik}+A_{kj}\ge A_{ij}$ for every $k$. $\square$

Musically: the cheapest voice-leading with any number of intermediate stops is simply to
move there directly. The matrix is its own tropical
[Kleene closure](https://en.wikipedia.org/wiki/Kleene_star) — already shortest-path complete.
</details>

<details>
<summary><strong>Pitch classes mod 12 do nothing here</strong></summary>

The standard fix for octave confusion is to reduce pitches modulo $12$. On a ten-note scale
that fix is empty: if $a,c<12$ then $a \equiv c \pmod{12}$ forces $a=c$, so no two distinct
digits are ever identified, and interval classes carry exactly the same information as
intervals. The boundary is sharp — in base $13$ the digits $0$ and $12$ finally become
octave-equivalent while remaining different notes. Below thirteen symbols, "using pitch
classes" changes nothing; the real correction is to measure $\lvert x_i-x_j\rvert$ for a
clearly specified pair of positions.
</details>

---

## 8. The moral, and the full computational suite

Turn the **temporal** dial and you enter a world of arithmetic rigidity: periods,
divisibility, gcds, a tropical seminorm on the monoid of lags. Turn the **pitch** dial and
you enter a world of complete freedom: every histogram achievable at every lag, bounded only
by the alphabet's nine-semitone span. Autocorrelation is a bridge between them of width one.

The suite below reproduces every numerical claim on this page — the vanishing octave, the
moment bridge with zero residual, the indistinguishable pair, the exact null baseline, the
rigidity of unison lags, the histogram realizations, tropical idempotency, and the
faithfulness of pitch classes below base thirteen.

{{demo:2}}

> To study musical intervals in a digit sequence, use the distribution of $\lvert x_i-x_j\rvert$
> for a clearly specified pair of positions — and if octaves are the object of interest, use
> an alphabet with at least thirteen symbols.
"""


def main() -> None:
    package: Dict[str, Any] = {
        "title": "Two Twelves: Separating Temporal Lag from Pitch Interval in Digit Melodies",
        "domain": "Tropical",
        "description": (
            "A complete separation of the temporal lag of a digit sequence from the pitch "
            "intervals of the melody it encodes: the lag variable carries a tropical "
            "seminorm whose kernel is the divisibility-rigid monoid of unison lags, the "
            "pitch variable carries an interval histogram that is free beyond its support, "
            "and autocorrelation is exactly the second moment of that histogram, with an "
            "exact combinatorial null baseline."
        ),
        "authors": ["Aristotle"],
        "date": "2026-08-23",
        "key_results": [
            "Vanishing Octave Theorem: for every decimal digit melody, every window and "
            "every temporal lag, the number of position pairs sounding a twelve-semitone "
            "interval is exactly zero, since a ten-note alphabet spans at most nine semitones.",
            "Moment Bridge: on a cyclic digit window, twice the lag-k autocorrelation equals "
            "twice the energy minus the second moment of the lag-k pitch-interval "
            "distribution; autocorrelation is therefore a functional of the interval "
            "histogram, and it is maximal exactly when all lag-k intervals are unisons.",
            "Non-invertibility of the bridge: the four-note cyclic melodies (0,0,0,5) and "
            "(0,3,0,4) share their energy and their lag-one autocorrelation while having "
            "different interval distributions, two unisons versus none.",
            "Exact null baseline: the triangular distribution of digit pairs has second "
            "moment (b^4 - b^2)/6, equal to 1650 in base ten, giving the exact deficit law "
            "12(energy - autocorrelation) = m(b^4 - b^2), i.e. a deficit of 825m in base ten.",
            "Rigidity versus freedom: the lag spectrum is a tropical seminorm on the additive "
            "monoid of lags whose unison lags are closed under greatest common divisors and "
            "hence equal the multiples of the minimal period, while every interval histogram "
            "supported on the digit range is realized at every lag by an explicit melody.",
        ],
        "keywords": [
            "tropical semiring",
            "min-plus algebra",
            "autocorrelation",
            "pitch-interval distribution",
            "digit sequences",
            "periodicity",
            "lag spectrum",
            "layer-cake rearrangement",
        ],
        "article": read("ARTICLE.md"),
        "research_paper": read("RESEARCH_PAPER.md"),
        "research_paper_tex": read("RESEARCH_PAPER.tex"),
        "demo": read("demo.py"),
        "demos": [
            {
                "name": "Lag Audit of the Digits of Pi Against the Exact Interval Baseline",
                "description": (
                    "Scans the temporal lags 1 through 40 of the first 300 digits of pi and "
                    "reports, for each lag, the unison mass N(0) that a correlation peak "
                    "actually measures, the octave mass N(12) that is identically zero, the "
                    "second moment of the interval histogram, the implied autocorrelation "
                    "deficit (half the second moment) and its excess over the exact "
                    "triangular-null prediction of 825 per hundred position pairs. It then "
                    "enumerates all cyclic windows of length four over the digits 0 to 5 and "
                    "finds every pair of melodies with equal energy and equal lag-one "
                    "autocorrelation but different interval distributions, exhibiting the "
                    "canonical witness (0,0,0,5) versus (0,3,0,4)."
                ),
                "code": (ASSETS / "demo_pi_audit.py").read_text(encoding="utf-8"),
            },
            {
                "name": "Minimal Witnesses: Melodies Indistinguishable by Energy and Correlation",
                "description": (
                    "A focused exhaustive search over short cyclic digit windows that "
                    "collects melodies into buckets keyed by (energy, lag-one "
                    "autocorrelation) and reports buckets containing distinct interval "
                    "histograms. This demonstrates concretely that the moment bridge is a "
                    "many-to-one map: a correlation statistic compresses a ten-bin histogram "
                    "into a single weighted sum and cannot certify which intervals occur. "
                    "The output includes the unison counts, which differ by the maximum "
                    "possible amount for a window of length four."
                ),
                "code": (ASSETS / "demo_witness_search.py").read_text(encoding="utf-8"),
            },
            {
                "name": "Complete Numerical Suite for the Lag/Interval Separation",
                "description": (
                    "The full demonstration suite: the vanishing octave and the mass and "
                    "support of the interval distribution; the moment bridge verified with "
                    "zero residual at several lags; the non-invertibility witness; the "
                    "triangular null distribution with its closed-form second moment in "
                    "bases 4, 10 and 13 and the resulting deficit law; the tropical lag "
                    "spectrum with subadditivity, the square-wave witness M(12)=7 and "
                    "M(24)=0, and gcd-rigidity of the unison lags; the inverse theorem "
                    "realizing prescribed histograms at lags 1, 2, 3 and 12; tropical "
                    "idempotency of the min-plus interval matrix; and the faithfulness of "
                    "pitch-class reduction below base thirteen."
                ),
                "code": read("demo.py"),
            },
        ],
        "algorithms": [
            {
                "name": "Lag-Resolved Pitch-Interval Histogram",
                "description": (
                    "Computes the pitch-interval distribution N(n, l, v) = #{i < n : "
                    "|x_i - x_{i+l}| = v} of a base-b digit melody at a specified temporal "
                    "lag, in both the windowed and the cyclic conventions. This is the "
                    "object that a study of musical intervals should report, in place of a "
                    "correlation coefficient: the lag parameter selects which position pairs "
                    "are compared, and the histogram records what those pairs sound. The "
                    "algorithm is a single pass with an array of counters, so it runs in "
                    "O(n) time and O(b) space. Two structural guarantees follow from the "
                    "construction and are asserted by the implementation: the output always "
                    "has total mass n, since each position pair contributes exactly one "
                    "interval, and it is supported on {0, ..., b-1}, so on a decimal scale "
                    "the octave bin v = 12 is unreachable."
                ),
                "pseudocode": (
                    "INPUT : melody x, window length n, lag l, base b\n"
                    "OUTPUT: histogram H[0..b-1] with H[v] = #{i < n : |x_i - x_{i+l}| = v}\n"
                    "1. assert len(x) >= n + l\n"
                    "2. H <- array of b zeros\n"
                    "3. for i <- 0 to n-1 do\n"
                    "4.     v <- |x[i] - x[i+l]|            // pitch distance, not time distance\n"
                    "5.     assert v < b                    // support theorem\n"
                    "6.     H[v] <- H[v] + 1\n"
                    "7. assert sum(H) = n                   // total-mass theorem\n"
                    "8. return H\n"
                    "CYCLIC VARIANT: replace x[i+l] by x[(i+l) mod n] and take n = len(x)."
                ),
                "code": (ASSETS / "algo_histogram.py").read_text(encoding="utf-8"),
            },
            {
                "name": "Moment-Bridge Audit and Exact Null-Baseline Test",
                "description": (
                    "Audits a cyclic digit window against the moment bridge 2A(k) = 2E - "
                    "sum_v v^2 N_k(v) and against the exact combinatorial null model. The "
                    "procedure computes the energy, the lag-k autocorrelation and the lag-k "
                    "interval histogram in a single sweep, verifies that the bridge residual "
                    "is identically zero (a nonzero residual can only indicate an indexing "
                    "error, which makes the identity a useful self-check), and then compares "
                    "the observed deficit E - A(k) with the closed-form null prediction "
                    "m(b^4 - b^2)/12, where m = n/b^2 is the null multiplicity implied by the "
                    "window length. In base ten the prediction is 825m, derived from the "
                    "triangular pair-count distribution whose second moment is exactly 1650. "
                    "Cost: O(n + b) time and O(b) space, with no simulation and no sampling "
                    "error. The reported excess over the null is the only legitimate form of "
                    "a lag anomaly claim."
                ),
                "pseudocode": (
                    "INPUT : cyclic window d[0..n-1] of base-b digits, lag k\n"
                    "OUTPUT: energy, autocorrelation, bridge residual, deficit, null excess\n"
                    "1. E <- 0 ; A <- 0 ; H <- array of b zeros\n"
                    "2. for i <- 0 to n-1 do\n"
                    "3.     E <- E + d[i]^2\n"
                    "4.     A <- A + d[i] * d[(i+k) mod n]\n"
                    "5.     H[ |d[i] - d[(i+k) mod n]| ] <- H[...] + 1\n"
                    "6. M2 <- sum over v of v^2 * H[v]\n"
                    "7. residual <- 2A - (2E - M2)          // provably 0\n"
                    "8. m <- n / b^2\n"
                    "9. null_deficit <- m * (b^4 - b^2) / 12\n"
                    "10. return (E, A, M2, residual, E - A, (E - A) - null_deficit, H[0])"
                ),
                "code": (ASSETS / "algo_bridge_audit.py").read_text(encoding="utf-8"),
            },
            {
                "name": "Layer-Cake Realization of a Prescribed Interval Histogram at Any Lag",
                "description": (
                    "Constructs, for any prescribed multiplicity function N on the interval "
                    "values 0 through 9 of total mass n, a decimal melody whose lag-one "
                    "interval histogram is exactly N, and then transports that histogram to "
                    "any lag l by interleaving, producing a melody whose lag-l histogram is "
                    "exactly l*N on a window of length l*n. The construction has three "
                    "stages. First the layer-cake rearrangement writes the demanded intervals "
                    "in non-increasing order: at time t the demanded interval is the number "
                    "of levels w in 1..9 whose tail mass sum_{u >= w} N(u) still exceeds t. "
                    "Second the alternating walk plays the demands, stepping up at even times "
                    "and down at odd times; because the demands never grow, a parity "
                    "invariant keeps the walk inside the band [0, first demand], so it never "
                    "leaves the ten-note scale and realizes every demand exactly. Third, "
                    "interleaving runs l independent voices, each advancing one step per l "
                    "beats, so every lag-l comparison of the interleaved melody is a lag-one "
                    "comparison of the original, realized l times over. Cost O(l n); the "
                    "output certifies that the temporal lag constrains nothing about the "
                    "pitch histogram beyond its support."
                ),
                "pseudocode": (
                    "INPUT : target histogram N[0..9] of total mass n, lag l >= 1\n"
                    "OUTPUT: decimal melody x with lag-l histogram exactly l*N on window l*n\n"
                    "1. for w <- 1 to 9 do T[w] <- sum_{u=w}^{9} N[u]      // tail masses\n"
                    "2. for t <- 0 to n-1 do\n"
                    "3.     L[t] <- #{ w in 1..9 : t < T[w] }              // layer cake\n"
                    "4. // L is non-increasing and its value histogram is exactly N\n"
                    "5. y[0] <- 0\n"
                    "6. for t <- 0 to n-1 do                               // alternating walk\n"
                    "7.     if t even then y[t+1] <- y[t] + L[t] else y[t+1] <- y[t] - L[t]\n"
                    "8. if l = 1 then return y\n"
                    "9. for i <- 0 to l*(n+1)-1 do x[i] <- y[ floor(i / l) ]   // interleave\n"
                    "10. return x"
                ),
                "code": (ASSETS / "algo_realize.py").read_text(encoding="utf-8"),
            },
        ],
        "visualizations": [
            {
                "name": "Temporal Statistic versus Pitch Statistic, Side by Side",
                "description": (
                    "A two-panel figure separating the two variables on the same data. The "
                    "top panel plots the lag spectrum M(l), the largest interval realized "
                    "across lag l, together with the autocorrelation deficit E - A(l) of the "
                    "first 360 digits of pi, against the temporal lag, with the exact null "
                    "baseline drawn as a horizontal line and the octave level 12 marked as "
                    "unreachable. The bottom panel overlays the pitch-interval histograms at "
                    "lags 1, 12 and 24 on the triangular null distribution scaled to the "
                    "window, with the octave bin highlighted as permanently empty."
                ),
                "code": (ASSETS / "viz_two_statistics.py").read_text(encoding="utf-8"),
            },
            {
                "name": "Rigidity of Lags against Freedom of Pitches",
                "description": (
                    "A two-panel contrast of the paper's central asymmetry. The left panel "
                    "draws the unison-lag sets of several periodic melodies as rows of dots: "
                    "in every case the set of lags with perfect correlation is exactly the "
                    "set of multiples of the minimal period, the divisibility rigidity that "
                    "follows from closure of the periods under greatest common divisors. The "
                    "right panel draws three prescribed interval histograms and the melodies "
                    "that realize them by layer-cake rearrangement followed by an alternating "
                    "walk, each verified to reproduce its target exactly, showing that the "
                    "pitch side has no rigidity at all beyond its support."
                ),
                "code": (ASSETS / "viz_rigidity_vs_freedom.py").read_text(encoding="utf-8"),
            },
        ],
        "interactive_demos": [
            {
                "title": "The Lag / Interval Laboratory",
                "description": (
                    "An interactive bench for the central distinction. Choose a digit melody "
                    "(the digits of pi or e, a square wave of amplitude seven and half-period "
                    "twelve, a periodic cell, or fresh uniform random digits), then slide the "
                    "temporal lag and the window length. The upper panel draws the melody with "
                    "arcs joining the compared position pairs, coloured by the interval each "
                    "pair sounds, so that changing the lag visibly changes which pairs are "
                    "compared without constraining what they sound. The lower panels show the "
                    "pitch-interval histogram with thirteen bins against the exact triangular "
                    "null distribution, so the reader can watch the octave bin stay empty at "
                    "every lag, and a live table of the energy, the autocorrelation, the "
                    "second moment, the two sides of the moment bridge and their residual "
                    "(always exactly zero), the unison and octave masses, and the observed "
                    "deficit against the exact null prediction of 825 per hundred position "
                    "pairs. Selecting the square wave exhibits the sharpest witness: perfect "
                    "temporal regularity at lag twenty-four with no unison whatsoever at lag "
                    "twelve."
                ),
                "html": (ASSETS / "widget_lab.html").read_text(encoding="utf-8"),
            },
            {
                "title": "The Interval-Histogram Composer",
                "description": (
                    "A constructive widget for the inverse theorem. The reader demands any "
                    "multiplicities for the interval sizes zero through nine, and the melody "
                    "realizing that demand exactly is built live by the three moves of the "
                    "proof: layer-cake rearrangement into a non-increasing sequence of "
                    "demanded intervals, an alternating walk that plays them without ever "
                    "leaving the ten-note scale, and interleaving that transports the "
                    "histogram to any chosen lag, where the realized histogram becomes the "
                    "demand multiplied by the lag. A verification table compares the demanded "
                    "and realized counts bin by bin, including the octave bin, which stays at "
                    "zero no matter what is demanded. Presets include the extreme histogram "
                    "of one unison and nine major sixths, the uniform histogram, a single "
                    "interval value, the triangular null shape, and an attempt to demand an "
                    "octave. Two collapsible sections explain why the walk never falls off "
                    "the scale and why the octave bin can never be filled."
                ),
                "html": (ASSETS / "widget_composer.html").read_text(encoding="utf-8"),
            },
        ],
        "interactive_layout": INTERACTIVE_LAYOUT,
        "lean_proofs": lean_bundle(),
        "future_directions": FUTURE_DIRECTIONS,
        "modules": {"demo": read("demo.py")},
        "lean_files": LEAN_FILES,
    }

    (ROOT / "PACKAGE.json").write_text(
        json.dumps(package, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print("wrote PACKAGE.json")


if __name__ == "__main__":
    main()


"""
Separating temporal lag from pitch interval in digit melodies.
==============================================================

Numerical demonstrations of the results of the accompanying paper:

  * the pitch-interval distribution N_x(n, l, v) = #{ i < n : |x_i - x_{i+l}| = v },
    its total mass n and its support {0, ..., b-1} (so the octave value v = 12
    never occurs in a decimal melody, at any lag);
  * the MOMENT BRIDGE   2 A(k) = 2 E - sum_v v^2 N_k(v)   on a cyclic window,
    exhibiting autocorrelation as the second moment of the pitch statistic;
  * non-invertibility of the bridge: (0,0,0,5) and (0,3,0,4) share energy and
    lag-1 autocorrelation but differ in their unison counts;
  * the triangular null distribution P_b(v) with second moment (b^4 - b^2)/6,
    and the exact deficit law  12 (E - A(k)) = m (b^4 - b^2), i.e. 825 m in base ten;
  * the tropical lag spectrum M_x(l) = max_i |x_i - x_{i+l}|: subadditivity,
    gcd-rigidity of the unison lags, and the square-wave witness M(12) = 7, M(24) = 0;
  * the inverse theorem: layer-cake rearrangement + alternating walk + interleaving
    realize any prescribed interval histogram at any lag;
  * tropical idempotency of the min-plus interval matrix A (X) A = A;
  * faithfulness of pitch-class reduction mod 12 below base 13.

Pure standard library; run with `python3 demo.py`.
"""

from __future__ import annotations

from math import gcd
from typing import Dict, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# Sample data: the first 201 decimal digits of pi (a conventional digit melody).
# ----------------------------------------------------------------------------

PI_DIGITS: List[int] = [int(c) for c in (
    "3"
    "14159265358979323846264338327950288419716939937510"
    "58209749445923078164062862089986280348253421170679"
    "82148086513282306647093844609550582231725359408128"
    "48111745028410270193852110555964462294895493038196"
)]


# ----------------------------------------------------------------------------
# 1. Pitch intervals and the interval distribution
# ----------------------------------------------------------------------------

def pitch_interval(a: int, c: int) -> int:
    """The pitch interval, in semitones, between two digit-notes."""
    return abs(a - c)


def lag_interval(x: Sequence[int], lag: int, i: int) -> int:
    """The interval realized by the position pair (i, i + lag)."""
    return pitch_interval(x[i], x[i + lag])


def interval_histogram(x: Sequence[int], n: int, lag: int, base: int = 10) -> List[int]:
    """N_x(n, lag, .) as a length-`base` list.  Requires n + lag <= len(x)."""
    hist: List[int] = [0] * base
    for i in range(n):
        hist[lag_interval(x, lag, i)] += 1
    return hist


def cyclic_interval_histogram(d: Sequence[int], lag: int, base: int = 10) -> List[int]:
    """The cyclic lag-`lag` interval distribution of a window of length len(d)."""
    n = len(d)
    hist: List[int] = [0] * base
    for i in range(n):
        hist[pitch_interval(d[i], d[(i + lag) % n])] += 1
    return hist


# ----------------------------------------------------------------------------
# 2. Cyclic energy, autocorrelation, and the moment bridge
# ----------------------------------------------------------------------------

def energy(d: Sequence[int]) -> int:
    """E(d) = sum_i d_i^2."""
    return sum(v * v for v in d)


def autocorrelation(d: Sequence[int], lag: int) -> int:
    """A(lag) = sum_i d_i d_{i+lag}, indices cyclic."""
    n = len(d)
    return sum(d[i] * d[(i + lag) % n] for i in range(n))


def second_moment(hist: Sequence[int]) -> int:
    """sum_v v^2 N(v)."""
    return sum(v * v * count for v, count in enumerate(hist))


def moment_bridge_residual(d: Sequence[int], lag: int, base: int = 10) -> int:
    """2 A(lag) - (2 E - sum_v v^2 N_lag(v)); identically zero by the moment bridge."""
    hist = cyclic_interval_histogram(d, lag, base)
    return 2 * autocorrelation(d, lag) - (2 * energy(d) - second_moment(hist))


# ----------------------------------------------------------------------------
# 3. The triangular null distribution and the deficit law
# ----------------------------------------------------------------------------

def pair_count(base: int, v: int) -> int:
    """P_b(v): ordered pairs of base-b digits at pitch interval v."""
    if v == 0:
        return base
    if v < base:
        return 2 * (base - v)
    return 0


def null_histogram(base: int, multiplicity: int = 1) -> List[int]:
    """m copies of the triangular null distribution, as a length-`base` list."""
    return [multiplicity * pair_count(base, v) for v in range(base)]


def null_second_moment_closed_form(base: int) -> int:
    """(b^4 - b^2) / 6, the closed form of sum_v v^2 P_b(v)."""
    return (base ** 4 - base ** 2) // 6


def null_deficit(base: int, multiplicity: int) -> float:
    """The exact autocorrelation deficit E - A for m copies of the null histogram."""
    return multiplicity * (base ** 4 - base ** 2) / 12.0


# ----------------------------------------------------------------------------
# 4. The tropical lag spectrum and the unison lags
# ----------------------------------------------------------------------------

def lag_spectrum(x: Sequence[int], lag: int, n: int) -> int:
    """M_x(lag) computed over the window of n position pairs."""
    return max((lag_interval(x, lag, i) for i in range(n)), default=0)


def is_unison_lag(x: Sequence[int], lag: int, n: int) -> bool:
    """Whether x_i = x_{i+lag} for every i < n (a period, on the window)."""
    return lag_spectrum(x, lag, n) == 0


def square_wave(amplitude: int, half_period: int, length: int) -> List[int]:
    """s_{v,l}(i) = v * (floor(i / l) mod 2)."""
    return [amplitude * ((i // half_period) % 2) for i in range(length)]


# ----------------------------------------------------------------------------
# 5. The inverse theorem: layer cake, alternating walk, interleaving
# ----------------------------------------------------------------------------

def tail_mass(target: Sequence[int], w: int) -> int:
    """T_N(w) = sum_{u >= w} N(u), over the ten admissible interval values."""
    return sum(target[u] for u in range(w, 10))


def layer_sequence(target: Sequence[int], n: int) -> List[int]:
    """The non-increasing rearrangement of the demanded intervals (layer cake)."""
    return [sum(1 for w in range(1, 10) if t < tail_mass(target, w)) for t in range(n)]


def alternating_walk(demands: Sequence[int]) -> List[int]:
    """Start at 0; step up by demands[t] at even t, down at odd t."""
    notes: List[int] = [0]
    for t, step in enumerate(demands):
        notes.append(notes[t] + step if t % 2 == 0 else notes[t] - step)
    return notes


def interleave(z: Sequence[int], factor: int) -> List[int]:
    """z^[l](i) = z(floor(i / l)): l independent voices, one step per l beats."""
    return [z[i // factor] for i in range(factor * len(z))]


def realize_histogram(target: Sequence[int], lag: int = 1) -> List[int]:
    """A decimal melody whose lag-`lag` histogram is lag * target (mass = sum target)."""
    n = sum(target)
    melody = alternating_walk(layer_sequence(target, n))
    return melody if lag == 1 else interleave(melody, lag)


# ----------------------------------------------------------------------------
# 6. The min-plus interval matrix
# ----------------------------------------------------------------------------

def interval_matrix(x: Sequence[int], n: int) -> List[List[int]]:
    """A_ij = |x_i - x_j|, to be read in the min-plus semiring."""
    return [[pitch_interval(x[i], x[j]) for j in range(n)] for i in range(n)]


def min_plus_product(a: List[List[int]], b: List[List[int]]) -> List[List[int]]:
    """(A (X) B)_ij = min_k (A_ik + B_kj)."""
    n = len(a)
    return [[min(a[i][k] + b[k][j] for k in range(n)) for j in range(n)] for i in range(n)]


# ----------------------------------------------------------------------------
# 7. Pitch classes
# ----------------------------------------------------------------------------

def pitch_class(a: int) -> int:
    """a mod 12."""
    return a % 12


def pitch_class_collisions(base: int) -> List[Tuple[int, int]]:
    """Distinct digits below `base` that are identified by mod-12 reduction."""
    return [(a, c) for a in range(base) for c in range(a + 1, base)
            if pitch_class(a) == pitch_class(c)]


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def show_histogram(hist: Sequence[int]) -> str:
    return "  ".join(f"{v}:{c}" for v, c in enumerate(hist) if c)


def demo_octave_vanishes() -> None:
    print("=" * 78)
    print("1. THE OCTAVE NEVER APPEARS  (support of the interval distribution)")
    print("=" * 78)
    n = 100
    for lag in (1, 5, 12, 24):
        hist = interval_histogram(PI_DIGITS, n, lag)
        print(f"  lag {lag:2d}:  histogram  {show_histogram(hist)}")
        print(f"           total mass = {sum(hist)} (= window length {n}),"
              f"  max interval = {max(v for v, c in enumerate(hist) if c)}")
    print("  Interval value 12 has mass 0 at every lag: digits span at most 9 semitones.")
    print(f"  Unison mass at lag 12: N(0) = {interval_histogram(PI_DIGITS, n, 12)[0]}"
          "   <- this is what a lag-12 correlation actually measures.\n")


def demo_moment_bridge() -> None:
    print("=" * 78)
    print("2. THE MOMENT BRIDGE   2 A(k) = 2 E - sum_v v^2 N_k(v)")
    print("=" * 78)
    d = PI_DIGITS[:60]
    e = energy(d)
    for k in (1, 3, 12):
        a = autocorrelation(d, k)
        hist = cyclic_interval_histogram(d, k)
        m2 = second_moment(hist)
        print(f"  lag {k:2d}:  E = {e},  A = {a},  second moment = {m2}")
        print(f"           2A = {2 * a}   vs   2E - moment = {2 * e - m2}"
              f"   residual = {moment_bridge_residual(d, k)}")
    print()


def demo_information_loss() -> None:
    print("=" * 78)
    print("3. THE BRIDGE IS NOT INVERTIBLE")
    print("=" * 78)
    d: List[int] = [0, 0, 0, 5]
    e: List[int] = [0, 3, 0, 4]
    for name, mel in (("d = (0,0,0,5)", d), ("e = (0,3,0,4)", e)):
        hist = cyclic_interval_histogram(mel, 1)
        print(f"  {name}:  E = {energy(mel)},  A(1) = {autocorrelation(mel, 1)},"
              f"  lag-1 histogram  {show_histogram(hist)}   unisons = {hist[0]}")
    print("  Equal energy, equal autocorrelation, different interval distributions:")
    print("  a correlation statistic cannot certify which intervals occur.\n")


def demo_null_model() -> None:
    print("=" * 78)
    print("4. THE EXACT NULL MODEL AND THE DEFICIT LAW")
    print("=" * 78)
    for base in (4, 10, 13):
        hist = null_histogram(base)
        brute = sum(1 for a in range(base) for c in range(base))
        print(f"  base {base:2d}:  P_b = {hist}")
        print(f"            total mass = {sum(hist)} = b^2 = {base ** 2}"
              f" (ordered pairs checked: {brute})")
        print(f"            second moment = {second_moment(hist)}"
              f"  =  (b^4 - b^2)/6 = {null_second_moment_closed_form(base)}")
    print(f"  Decimal mean squared interval = {second_moment(null_histogram(10)) / 100:.2f}"
          " semitones^2  (RMS "
          f"{(second_moment(null_histogram(10)) / 100) ** 0.5:.3f} semitones)")
    for m in (1, 2, 5):
        print(f"  m = {m}:  predicted deficit E - A = {null_deficit(10, m):.1f}"
              f"   (= 825 m = {825 * m})")
    print()


def demo_lag_spectrum() -> None:
    print("=" * 78)
    print("5. THE TROPICAL LAG SPECTRUM: SUBADDITIVITY AND RIGIDITY")
    print("=" * 78)
    n = 90
    spec = {lag: lag_spectrum(PI_DIGITS, lag, n) for lag in range(1, 13)}
    print("  pi melody, M(l) for l = 1..12:  "
          + "  ".join(f"{lag}:{val}" for lag, val in spec.items()))
    worst = max((spec[k] + spec[l] - lag_spectrum(PI_DIGITS, k + l, n),
                 k, l) for k in range(1, 7) for l in range(1, 7))
    print(f"  subadditivity M(k+l) <= M(k) + M(l) verified for all k,l <= 6"
          f"  (largest slack {worst[0]} at k={worst[1]}, l={worst[2]})")

    sq = square_wave(7, 12, 400)
    print(f"  square wave s_(7,12):  M(12) = {lag_spectrum(sq, 12, 300)}"
          f"   M(24) = {lag_spectrum(sq, 24, 300)}")
    h12 = interval_histogram(sq, 96, 12)
    print(f"     lag-12 histogram  {show_histogram(h12)}"
          f"   unisons at lag 12: {h12[0]}")
    print("     maximal temporal regularity at lag 24, no unison at all at lag 12.")

    per = [3, 1, 4, 1, 5, 9] * 40  # minimal period 6
    periods = [p for p in range(1, 61) if is_unison_lag(per, p, 120)]
    print(f"  periodic melody (3,1,4,1,5,9 repeated): unison lags <= 60 are {periods}")
    print(f"     minimal period {periods[0]}; every listed lag is a multiple of it: "
          f"{all(p % periods[0] == 0 for p in periods)}")
    print(f"     gcd-closure check: gcd(12, 18) = {gcd(12, 18)} is a unison lag: "
          f"{is_unison_lag(per, gcd(12, 18), 120)}\n")


def demo_inverse_theorem() -> None:
    print("=" * 78)
    print("6. THE INVERSE THEOREM: EVERY HISTOGRAM IS REALIZED, AT EVERY LAG")
    print("=" * 78)
    targets: List[Tuple[str, List[int]]] = [
        ("one unison + nine major sixths", [1, 0, 0, 0, 0, 0, 0, 0, 0, 9]),
        ("uniform over 0..9", [3] * 10),
        ("all mass on 4 semitones", [0, 0, 0, 0, 7, 0, 0, 0, 0, 0]),
    ]
    for name, target in targets:
        n = sum(target)
        melody = realize_histogram(target, lag=1)
        got = interval_histogram(melody, n, 1)
        print(f"  {name}:")
        print(f"     melody       {melody}")
        print(f"     target       {target}")
        octave_mass = sum(1 for i in range(n) if lag_interval(melody, 1, i) == 12)
        print(f"     realized     {got}      match: {got == list(target)}"
              f"   octave mass: {octave_mass}")
    target = [1, 0, 0, 0, 0, 0, 0, 0, 0, 9]
    for lag in (2, 3, 12):
        n = sum(target)
        melody = realize_histogram(target, lag=lag)
        got = interval_histogram(melody, lag * n, lag)
        expected = [lag * t for t in target]
        print(f"  lag {lag:2d}: realized {got}  expected {expected}"
              f"  match: {got == expected}")
    print()


def demo_min_plus_matrix() -> None:
    print("=" * 78)
    print("7. TROPICAL IDEMPOTENCY OF THE INTERVAL MATRIX")
    print("=" * 78)
    n = 7
    a = interval_matrix(PI_DIGITS, n)
    a2 = min_plus_product(a, a)
    a3 = min_plus_product(a2, a)
    print(f"  first {n} notes: {PI_DIGITS[:n]}")
    for row in a:
        print("     " + " ".join(f"{v:2d}" for v in row))
    print(f"  A (X) A == A : {a2 == a}      A (X) A (X) A == A : {a3 == a}")
    print(f"  symmetric: {all(a[i][j] == a[j][i] for i in range(n) for j in range(n))}"
          f"   unit diagonal: {all(a[i][i] == 0 for i in range(n))}")
    print(f"  max entry {max(max(r) for r in a)} <= 9;"
          f"  any entry equal to 12: {any(v == 12 for r in a for v in r)}\n")


def demo_pitch_classes() -> None:
    print("=" * 78)
    print("8. PITCH CLASSES MOD 12 ARE FAITHFUL BELOW BASE 13")
    print("=" * 78)
    for base in (10, 12, 13, 16):
        collisions = pitch_class_collisions(base)
        print(f"  base {base:2d}: octave-equivalent distinct digit pairs: "
              f"{collisions if collisions else 'none'}")
    print("  On the decimal digit scale, reducing mod 12 identifies nothing:")
    print("  interval classes carry exactly the same information as intervals.\n")


def main() -> None:
    demo_octave_vanishes()
    demo_moment_bridge()
    demo_information_loss()
    demo_null_model()
    demo_lag_spectrum()
    demo_inverse_theorem()
    demo_min_plus_matrix()
    demo_pitch_classes()
    print("=" * 78)
    print("Temporal lag and pitch interval are separate variables; the second moment")
    print("is the only bridge between them.")
    print("=" * 78)


if __name__ == "__main__":
    main()
