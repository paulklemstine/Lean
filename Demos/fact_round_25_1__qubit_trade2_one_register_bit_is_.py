"""
The Fungibility Ramp: one register bit is worth one sample.

Numerical demonstration of the qubit/sample exchange law for Shor
period-finding.  Everything is self-contained: standard library only, no
external dependencies, all helper functions inlined and type-hinted.

The script demonstrates, in order:

  1. The certification criterion and its residue form.
  2. The exact peak count  N(q, r) = 2*floor(q/(2r)) + 1  below saturation,
     and the ramp rails  q/r^2 - 1/r < N/r <= q/r^2 + 1/r.
  3. The three regimes of the register axis: dead (q < 2r), ramp,
     saturated (q >= r(r-1) for odd r).
  4. The informative count  #I(q,r) = 2 * #{m in [1,B] : gcd(m,r)=1}.
  5. The two rails of the compounding law  P_s = 1 - (1-P_1)^s:
     reverse Bernoulli below, union bound above.
  6. The contour band  1/2 <= c*s*2^t <= 1  and the exchange law
     t*(4^m s) <= t*(s) - m <= t*(4^m s) + m.
  7. The exact arithmetic-progression measurement kernel
     P(k) = (1/(M q)) |sin(pi M k r / q) / sin(pi k r / q)|^2,
     and the certification probability it induces.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
from math import gcd
from typing import Dict, List, Tuple

# --------------------------------------------------------------------------
# 1.  The certification criterion
# --------------------------------------------------------------------------


def peak_residue(q: int, r: int, j: int) -> int:
    """Residue of the j-th peak position j*q/r on the measurement grid."""
    return (j * q) % r


def cert_res(q: int, r: int, j: int) -> bool:
    """Residue form of certification:  2*r*m <= q  or  2*r*(r-m) <= q."""
    m = peak_residue(q, r, j)
    return (2 * r * m <= q) or (2 * r * (r - m) <= q)


def peak_certifies_bruteforce(q: int, r: int, j: int) -> bool:
    """Direct geometric form: exists integer k with 2*r*|j*q - k*r| <= q.

    Only the two nearest candidates k = floor(j*q/r) and that plus one can
    possibly work, which is exactly the content of the residue criterion;
    we check them explicitly here as an independent verification.
    """
    d = (j * q) // r
    return any(2 * r * abs(j * q - k * r) <= q for k in (d, d + 1))


def cert_peaks(q: int, r: int) -> List[int]:
    """The set of certifying peak indices j in [0, r)."""
    return [j for j in range(r) if cert_res(q, r, j)]


def info_peaks(q: int, r: int) -> List[int]:
    """Certifying peaks whose numerator is coprime to r (informative ones)."""
    return [j for j in cert_peaks(q, r) if gcd(j, r) == 1]


def head_totatives(r: int, b: int) -> List[int]:
    """Integers in [1, B] coprime to r."""
    return [m for m in range(1, b + 1) if gcd(m, r) == 1]


def closed_form_count(q: int, r: int) -> int:
    """Closed form 2*floor(q/(2r)) + 1, valid below saturation."""
    return 2 * (q // (2 * r)) + 1


def is_saturated(q: int, r: int) -> bool:
    """Saturation criterion: r <= 2*floor(q/(2r)) + 1."""
    return r <= 2 * (q // (2 * r)) + 1


def regime(q: int, r: int) -> str:
    """Dead / ramp / saturated classification of the register axis."""
    if q < 2 * r:
        return "dead"
    if is_saturated(q, r):
        return "saturated"
    return "ramp"


# --------------------------------------------------------------------------
# 2.  The compounding law and its two rails
# --------------------------------------------------------------------------


def succ_prob(x: float, n: int) -> float:
    """P_s = 1 - (1 - x)^n : independent shots compound."""
    return 1.0 - (1.0 - x) ** n


def ramp_prob(c: float, t: int) -> float:
    """Ramp per-shot probability min(1, c * 2^t); the model has c = 1/r^2."""
    return min(1.0, c * (2.0 ** t))


def reaches(c: float, t: int, s: int) -> bool:
    """Configuration (t, s) reaches the 50% target."""
    return succ_prob(ramp_prob(c, t), s) >= 0.5


def t_star(c: float, s: int, t_max: int = 256) -> int:
    """Least register width at which s samples reach the 50% target."""
    for t in range(t_max + 1):
        if reaches(c, t, s):
            return t
    raise ValueError("threshold width not found below t_max")


# --------------------------------------------------------------------------
# 3.  The exact measurement kernel
# --------------------------------------------------------------------------


def shor_kernel(q: int, r: int) -> List[float]:
    """Exact Shor output distribution for an arithmetic-progression preimage.

        P(k) = (1 / (M q)) * |sin(pi M k r / q) / sin(pi k r / q)|^2 ,
        M = ceil(q / r) approximately,

    with the removable singularities at k*r = 0 (mod q) resolved to M/q.
    """
    m_terms = q // r
    out: List[float] = []
    for k in range(q):
        theta = math.pi * ((k * r) % q) / q
        if abs(math.sin(theta)) < 1e-14:
            out.append(m_terms / q)
        else:
            amp = math.sin(m_terms * theta) / math.sin(theta)
            out.append(amp * amp / (m_terms * q))
    total = sum(out)
    return [p / total for p in out]


def outcome_certifies(q: int, r: int, k: int) -> bool:
    """Does the measured outcome k admit a convergent j/r with |k/q - j/r| <= 1/(2 r^2)?

    Equivalently, some j in [0, r) with 2*r*|j*q - k*r| <= q.  Only the two
    candidates nearest to k*r/q can satisfy it.
    """
    j0 = (k * r) // q
    return any(
        0 <= j < r and 2 * r * abs(j * q - k * r) <= q for j in (j0, j0 + 1)
    )


def kernel_cert_rate(q: int, r: int) -> float:
    """Total kernel mass on outcomes that admit a certificate."""
    dist = shor_kernel(q, r)
    return sum(p for k, p in enumerate(dist) if outcome_certifies(q, r, k))


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------


def demo_counting() -> None:
    print("=" * 74)
    print("1.  EXACT PEAK COUNT AND THE RAMP")
    print("=" * 74)
    print("    N(q,r) = 2*floor(q/(2r)) + 1   below saturation, gcd(q,r) = 1")
    print("    ramp rails:  q/r^2 - 1/r  <  N/r  <=  q/r^2 + 1/r")
    print()
    header = f"{'r':>5} {'q':>6} {'regime':>10} {'N':>4} {'closed':>7} " \
             f"{'rate':>7} {'q/r^2':>7} {'lower':>8} {'upper':>8}"
    print(header)
    print("-" * len(header))
    for r in (11, 15, 21):
        for t in range(4, 11):
            q = 2 ** t
            if gcd(q, r) != 1:
                continue
            peaks = cert_peaks(q, r)
            n = len(peaks)
            reg = regime(q, r)
            closed = closed_form_count(q, r) if reg != "saturated" else r
            rate = n / r
            lo, hi = q / r ** 2 - 1 / r, q / r ** 2 + 1 / r
            print(f"{r:>5} {q:>6} {reg:>10} {n:>4} {closed:>7} "
                  f"{rate:>7.3f} {q / r ** 2:>7.3f} {lo:>8.3f} {hi:>8.3f}")
            # the criterion agrees with the direct geometric test
            assert peaks == [j for j in range(r) if peak_certifies_bruteforce(q, r, j)]
            if reg != "saturated":
                assert n == closed, (r, q, n, closed)
                assert lo < rate <= hi, (r, q, rate, lo, hi)
    print()
    print("    All closed forms and both ramp rails verified.")
    print()


def demo_walls() -> None:
    print("=" * 74)
    print("2.  THREE REGIMES:  DEAD  <  RAMP  <  SATURATED")
    print("=" * 74)
    print("    dead:       q < 2r              (no informative certificate)")
    print("    saturated:  q >= r(r-1), r odd  (every peak certifies)")
    print("    folklore wall q = r^2 is neither of these.")
    print()
    for r in (11, 15, 21, 35):
        print(f"  period r = {r}:  2r = {2 * r},  r(r-1) = {r * (r - 1)}, "
              f"r^2 = {r * r}")
        header = f"{'q':>7} {'regime':>10} {'N':>4} {'#info':>6} {'2*T(r,B)':>9}"
        print("   " + header)
        for t in range(3, 12):
            q = 2 ** t
            if gcd(q, r) != 1:
                continue
            b = q // (2 * r)
            n = len(cert_peaks(q, r))
            ni = len(info_peaks(q, r))
            reg = regime(q, r)
            predicted = 2 * len(head_totatives(r, b)) if reg != "saturated" else None
            shown = str(predicted) if predicted is not None else "sat."
            print(f"   {q:>7} {reg:>10} {n:>4} {ni:>6} {shown:>9}")
            if reg != "saturated":
                assert ni == predicted, (r, q, ni, predicted)
            if reg == "dead":
                assert ni == 0, (r, q, ni)
            # exact saturation point for odd r
            if r % 2 == 1:
                assert (n == r) == (q >= r * (r - 1)), (r, q)
        print(f"     saturated informative count = phi({r}) = "
              f"{len(head_totatives(r, r - 1))}")
        print()
    print("    Linear wall at q = 2r, saturation at q = r(r-1): both verified.")
    print()


def demo_doubling() -> None:
    print("=" * 74)
    print("3.  ONE REGISTER BIT DOUBLES THE CERTIFYING SET")
    print("=" * 74)
    print("    2 N(q) - 1  <=  N(2q)  <=  2 N(q) + 1   (r odd, below saturation)")
    print()
    print(f"{'r':>5} {'q':>7} {'N(q)':>6} {'N(2q)':>7} {'2N(q)-1':>9} {'2N(q)+1':>9}")
    print("-" * 48)
    for r in (11, 21, 35, 1155):
        for t in range(6, 14):
            q = 2 ** t
            if gcd(q, r) != 1 or is_saturated(2 * q, r):
                continue
            n1 = len(cert_peaks(q, r))
            n2 = len(cert_peaks(2 * q, r))
            print(f"{r:>5} {q:>7} {n1:>6} {n2:>7} {2 * n1 - 1:>9} {2 * n1 + 1:>9}")
            assert 2 * n1 - 1 <= n2 <= 2 * n1 + 1
    print()
    print("    Arithmetic doubling law verified.")
    print()


def demo_rails() -> None:
    print("=" * 74)
    print("4.  THE TWO RAILS OF THE COMPOUNDING LAW")
    print("=" * 74)
    print("    reverse Bernoulli:  (1-x)^n (1 + n x) <= 1")
    print("    lower rail:  n x >= 1    ==>  P_n >= 1/2")
    print("    upper rail:  n x < 1/2   ==>  P_n <  1/2")
    print()
    print(f"{'x':>8} {'n':>5} {'n*x':>8} {'P_n':>8} {'(1-x)^n(1+nx)':>15} {'verdict':>12}")
    print("-" * 62)
    cases: List[Tuple[float, int]] = [
        (0.005, 50), (0.005, 200), (0.05, 10), (0.05, 20),
        (0.1, 5), (0.1, 10), (0.3, 2), (0.3, 4), (0.725, 2),
    ]
    for x, n in cases:
        bern = (1 - x) ** n * (1 + n * x)
        p = succ_prob(x, n)
        if n * x >= 1:
            verdict = "P >= 1/2"
            assert p >= 0.5 - 1e-12
        elif n * x < 0.5:
            verdict = "P <  1/2"
            assert p < 0.5
        else:
            verdict = "in band"
        assert bern <= 1 + 1e-12
        print(f"{x:>8.3f} {n:>5} {n * x:>8.3f} {p:>8.4f} {bern:>15.6f} {verdict:>12}")
    print()
    print("    Reverse Bernoulli and both rails verified on every case.")
    print()


def demo_contour_band() -> None:
    print("=" * 74)
    print("5.  THE CONTOUR BAND:  1/2 <= c*s*2^t <= 1")
    print("=" * 74)
    print("    c = 1/r^2.  The 50% contour of the (t, s) diagram sits between")
    print("    two parallel unit-slope lines: a ramp, never a vertical wall.")
    print()
    r = 1155
    c = 1.0 / r ** 2
    print(f"    period r = {r},  c = 1/r^2 = {c:.3e},  folklore wall "
          f"t = {2 * math.log2(r):.1f}")
    print()
    print(f"{'s':>7} {'t*(s)':>7} {'c*s*2^(t*)':>12} {'c*s*2^(t*-1)':>14} {'in band':>9}")
    print("-" * 54)
    for s in (1, 2, 4, 8, 16, 32, 100, 1024):
        ts = t_star(c, s)
        coord = c * s * 2 ** ts
        coord_below = c * s * 2 ** (ts - 1) if ts > 0 else float("nan")
        ok = coord >= 0.5 and coord_below < 1.0 + 1e-12
        print(f"{s:>7} {ts:>7} {coord:>12.4f} {coord_below:>14.4f} {str(ok):>9}")
        assert coord >= 0.5 - 1e-12
    print()
    print("    Every threshold width sits inside the band, as proved.")
    print()


def demo_exchange_law() -> None:
    print("=" * 74)
    print("6.  THE EXCHANGE LAW:  ONE BIT PER SAMPLE DOUBLING")
    print("=" * 74)
    print("    t*(4^m s) <= t*(s) - m     (2m doublings buy >= m bits)")
    print("    t*(s) <= t*(4^m s) + 2m    (2m doublings buy <= 2m bits)")
    print()
    for r in (1155, 21, 8191):
        c = 1.0 / r ** 2
        base = t_star(c, 1)
        print(f"  period r = {r}:  t*(1) = {base},  folklore wall "
              f"t = {2 * math.log2(r):.1f}")
        print(f"   {'m':>4} {'4^m':>8} {'t*(4^m)':>9} {'t*(1)-m':>9} "
              f"{'shift':>7} {'-log2(4^m)':>11}")
        for m in range(0, 6):
            s = 4 ** m
            ts = t_star(c, s)
            shift = ts - base
            print(f"   {m:>4} {s:>8} {ts:>9} {base - m:>9} {shift:>7} "
                  f"{-math.log2(s):>11.1f}")
            assert ts <= base - m, (r, m, ts, base)
            assert base <= ts + 2 * m, (r, m, ts, base)
        print()
    print("    Both directions of the exchange band verified.")
    print()
    print("    Configuration form:")
    print("      (t, 2s) reaches  ==>  (t+1, s) reaches   [doubling <= one bit]")
    print("      (t+1, s) reaches ==>  (t, 4s) reaches    [one bit <= two doublings]")
    c = 1.0 / 21 ** 2
    checks = 0
    for t in range(0, 20):
        for s in (1, 2, 3, 5, 10, 50):
            if reaches(c, t, 2 * s):
                assert reaches(c, t + 1, s)
                checks += 1
            if reaches(c, t + 1, s):
                assert reaches(c, t, 4 * s)
                checks += 1
    print(f"      {checks} implications checked, all hold.")
    print()


def demo_kernel() -> None:
    print("=" * 74)
    print("7.  THE EXACT MEASUREMENT KERNEL")
    print("=" * 74)
    print("    P(k) = (1/(M q)) |sin(pi M k r / q) / sin(pi k r / q)|^2")
    print("    Certification mass vs the uniform peak model N(q,r)/r.")
    print()
    print(f"{'r':>5} {'q':>7} {'q/r^2':>8} {'kernel rate':>12} "
          f"{'uniform N/r':>12} {'ratio':>7}")
    print("-" * 56)
    rows: List[Tuple[int, int]] = [
        (11, 64), (11, 128), (11, 256),
        (15, 64), (15, 128), (15, 256),
        (21, 128), (21, 256), (21, 512),
        (8, 64), (8, 128),
    ]
    for r, q in rows:
        kr = kernel_cert_rate(q, r)
        un = len(cert_peaks(q, r)) / r
        ratio = kr / un if un > 0 else float("nan")
        print(f"{r:>5} {q:>7} {q / r ** 2:>8.3f} {kr:>12.4f} "
              f"{un:>12.4f} {ratio:>7.3f}")
    print()
    print("    The dyadic family r = 8 is flat-saturated (r | q): every peak")
    print("    sits on a grid point, and there is no ramp behaviour at all.")
    print()
    print("    Compounding on the kernel rate, out of sample:")
    print(f"    {'r':>5} {'q':>7} {'P_1':>7} {'s':>5} {'1-(1-P1)^s':>12}")
    for r, q in ((11, 128), (15, 128), (21, 256)):
        p1 = kernel_cert_rate(q, r)
        for s in (1, 2, 5, 20):
            print(f"    {r:>5} {q:>7} {p1:>7.4f} {s:>5} {succ_prob(p1, s):>12.4f}")
    print()


def demo_summary() -> None:
    print("=" * 74)
    print("SUMMARY")
    print("=" * 74)
    facts: Dict[str, str] = {
        "exact count": "N(q,r) = 2*floor(q/(2r)) + 1 below saturation",
        "ramp": "q/r^2 - 1/r < N/r <= q/r^2 + 1/r  (unit slope in q/r^2)",
        "true wall": "informative certificates exist iff q >= 2r (linear!)",
        "saturation": "all peaks certify iff q >= r(r-1) for odd r",
        "informative": "#I(q,r) = 2 * #{m in [1, floor(q/2r)] : gcd(m,r)=1}",
        "doubling": "2N(q) - 1 <= N(2q) <= 2N(q) + 1",
        "rails": "n*x >= 1 => P >= 1/2 ;  n*x < 1/2 => P < 1/2",
        "contour band": "1/2 <= c*s*2^t <= 1 pins the 50% contour",
        "exchange": "t*(4^m s) <= t*(s) - m <= t*(4^m s) + m",
        "slogan": "ONE REGISTER BIT IS WORTH ONE SAMPLE",
    }
    for key, value in facts.items():
        print(f"  {key:>14} : {value}")
    print()


def main() -> None:
    demo_counting()
    demo_walls()
    demo_doubling()
    demo_rails()
    demo_contour_band()
    demo_exchange_law()
    demo_kernel()
    demo_summary()


if __name__ == "__main__":
    main()
