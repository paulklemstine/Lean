"""Search for a frequency separating one multiplier spectrally from the others."""

from __future__ import annotations

import math
from fractions import Fraction
from typing import Dict, List, Optional, Sequence


def is_resonant_exact(a: int, w: Fraction) -> bool:
    """Exact rational test: is (2a-1) w an odd integer?"""
    t: Fraction = (2 * a - 1) * w
    return t.denominator == 1 and t.numerator % 2 != 0


def amplitude_modulus(a: int, w: float) -> float:
    """|A_a(w)| = |cos(pi (a - 1/2) w)|."""
    return abs(math.cos(math.pi * (a - 0.5) * w))


def find_discriminating_frequency(target: int,
                                  others: Sequence[int],
                                  max_m: int = 100) -> Optional[Fraction]:
    """
    Return the smallest positive w in the resonance set of `target` at which no
    multiplier in `others` resonates, i.e. a frequency where the target map
    exhibits full o(N) cancellation while every other map keeps linear size.

    Candidates are w = (2m+1)/(2*target-1), m = 0, 1, 2, ...; each candidate is
    tested exactly in rational arithmetic against the other multipliers.

    Complexity: O(max_m * |others|) exact rational operations.
    """
    d: int = 2 * target - 1
    for m in range(max_m):
        w = Fraction(2 * m + 1, d)
        if all(not is_resonant_exact(b, w) for b in others):
            return w
    return None


def discriminator_table(multipliers: Sequence[int]) -> Dict[int, Optional[Fraction]]:
    """For each multiplier, a frequency isolating it from all the others."""
    return {a: find_discriminating_frequency(a, [b for b in multipliers if b != a])
            for a in multipliers}


if __name__ == "__main__":
    table = discriminator_table([3, 5, 7])
    for a, w in table.items():
        if w is None:
            print(f"a={a}: no separating frequency found")
            continue
        rest: List[int] = [b for b in (3, 5, 7) if b != a]
        vals = ", ".join(f"|A_{b}| = {amplitude_modulus(b, float(w)):.4f}" for b in rest)
        print(f"a={a}: w = {w}  ->  |A_{a}| = 0 while {vals}")


"""Enumeration and testing of the resonance set R_a = {w : (2a-1) w odd integer}."""

from __future__ import annotations

import math
from fractions import Fraction
from typing import List


def resonance_spacing(a: int) -> Fraction:
    """Consecutive resonances of the a n + 1 map are 2/(2a-1) apart."""
    return Fraction(2, 2 * a - 1)


def enumerate_resonances(a: int, w_max: float) -> List[Fraction]:
    """
    All resonant frequencies of the a n + 1 map in the interval (0, w_max],
    returned exactly as fractions (2m+1)/(2a-1).

    Complexity: output-sensitive, Theta((2a-1) * w_max) steps.
    """
    d: int = 2 * a - 1
    out: List[Fraction] = []
    m: int = 0
    while True:
        w = Fraction(2 * m + 1, d)
        if float(w) > w_max:
            return out
        out.append(w)
        m += 1


def is_resonant(a: int, w: float, tol: float = 1e-12) -> bool:
    """O(1) test: is (2a-1) w within tol of an odd integer?"""
    t = (2 * a - 1) * w
    nearest_odd = 2.0 * round((t - 1.0) / 2.0) + 1.0
    return abs(t - nearest_odd) < tol


def amplitude_modulus(a: int, w: float) -> float:
    """|A_a(w)| = |cos(pi (a - 1/2) w)|."""
    return abs(math.cos(math.pi * (a - 0.5) * w))


if __name__ == "__main__":
    for a in (3, 5, 7):
        rs = enumerate_resonances(a, 2.0)
        print(f"a={a}: spacing {resonance_spacing(a)}, resonances in (0,2]: "
              + ", ".join(str(r) for r in rs))


"""Branch-accelerated evaluation of the cutoff transform F_a(w, N)."""

from __future__ import annotations

import cmath
import math
from typing import Tuple

TWO_PI: float = 2.0 * math.pi


def e(x: float) -> complex:
    """Additive character e(x) = exp(2 pi i x)."""
    return cmath.exp(1j * TWO_PI * x)


def limit_amp(a: int, w: float) -> complex:
    """Limiting normalized amplitude A_a(w) = (e(w/2) + e(a w)) / 2."""
    return (e(w / 2.0) + e(a * w)) / 2.0


def cutoff_transform(a: int, w: float, N: int) -> complex:
    """
    Evaluate F_a(w, N) = sum_{n=1}^{N} e(w * T_a(n) / n) using the exact
    even/odd split: the even branch contributes floor(N/2) copies of the
    constant phase e(w/2), so only the odd n require work.

    Complexity: N/2 character evaluations, O(1) memory.
    """
    total: complex = (N // 2) * e(w / 2.0)
    tail: complex = 0j
    for n in range(1, N + 1, 2):          # odd n only
        tail += e(w / n)
    return total + e(a * w) * tail


def transform_with_bound(a: int, w: float, N: int) -> Tuple[complex, complex, float, float]:
    """
    Return (F, A, observed_error, guaranteed_bound) where
    observed_error = |F/N - A| and
    guaranteed_bound = (1 + 2 pi |w| (1 + log N)) / N.
    """
    F = cutoff_transform(a, w, N)
    A = limit_amp(a, w)
    observed = abs(F / N - A)
    bound = (1.0 + TWO_PI * abs(w) * (1.0 + math.log(N))) / N
    return F, A, observed, bound


if __name__ == "__main__":
    for N in (10, 10**2, 10**3, 10**4, 10**5):
        F, A, obs, bnd = transform_with_bound(3, 0.37, N)
        print(f"N={N:>7}  |F/N - A| = {obs:.3e}   bound = {bnd:.3e}   ok={obs <= bnd}")


"""
Visualization: the phasor walk of the cutoff transform.

Plotting the partial sums F_a(w,N) in the complex plane shows the geometry
behind the limit law: off resonance the walk is a straight drift of slope
A_a(w) (linear growth), while at a resonance the two branch phases are
antipodal and the walk collapses to a bounded, logarithmically creeping curl.

Produces 'collatz_phasor_walk.png'.
"""

from __future__ import annotations

import cmath
import math
from typing import List, Tuple

import matplotlib.pyplot as plt

TWO_PI: float = 2.0 * math.pi


def e(x: float) -> complex:
    return cmath.exp(1j * TWO_PI * x)


def ratio(a: int, n: int) -> float:
    return 0.5 if n % 2 == 0 else a + 1.0 / n


def partial_sums(a: int, w: float, N: int) -> Tuple[List[float], List[float]]:
    xs: List[float] = []
    ys: List[float] = []
    total = 0j
    for n in range(1, N + 1):
        total += e(w * ratio(a, n))
        xs.append(total.real)
        ys.append(total.imag)
    return xs, ys


def main() -> None:
    N = 600
    cases = [
        (3, 0.37, "off resonance: linear drift"),
        (3, 0.2, "resonance $\\omega=1/5$: bounded curl"),
        (5, 0.2, "$5n+1$ at $\\omega=1/5$: no cancellation"),
        (3, 0.02, "near $\\omega=0$: the trivial-bound peak"),
    ]
    fig, axes = plt.subplots(2, 2, figsize=(11, 10))
    for ax, (a, w, title) in zip(axes.ravel(), cases):
        xs, ys = partial_sums(a, w, N)
        ax.plot(xs, ys, lw=1.0, color="#1f77b4")
        ax.scatter([xs[-1]], [ys[-1]], color="#d62728", zorder=3, s=18)
        ax.set_title(f"$a={a}$, $\\omega={w}$ — {title}", fontsize=10)
        ax.set_aspect("equal", adjustable="datalim")
        ax.grid(alpha=0.2)
        ax.set_xlabel("Re")
        ax.set_ylabel("Im")
    fig.suptitle(f"Phasor walks of the partial sums $F_a(\\omega,N)$, $N \\leq {N}$")
    fig.tight_layout()
    fig.savefig("collatz_phasor_walk.png", dpi=150)
    print("wrote collatz_phasor_walk.png")


if __name__ == "__main__":
    main()


"""
Visualization: the normalized spectrum |F_a(w,N)|/N against the closed-form
amplitude |cos(pi (a-1/2) w)|, for the multipliers a = 3, 5, 7, with the
resonance combs marked.

Produces 'collatz_spectrum.png'.
"""

from __future__ import annotations

import cmath
import math
from typing import List

import matplotlib.pyplot as plt

TWO_PI: float = 2.0 * math.pi


def e(x: float) -> complex:
    return cmath.exp(1j * TWO_PI * x)


def transform_norm(a: int, w: float, N: int) -> float:
    """|F_a(w,N)| / N, computed with the even/odd split."""
    tail = sum((e(w / n) for n in range(1, N + 1, 2)), 0j)
    return abs((N // 2) * e(w / 2.0) + e(a * w) * tail) / N


def amplitude(a: int, w: float) -> float:
    return abs(math.cos(math.pi * (a - 0.5) * w))


def resonances(a: int, w_max: float) -> List[float]:
    d = 2 * a - 1
    return [(2 * m + 1) / d for m in range(int((d * w_max) / 2) + 1)
            if (2 * m + 1) / d <= w_max]


def main() -> None:
    w_max = 2.0
    grid = [w_max * i / 800.0 for i in range(801)]
    N = 4000
    fig, axes = plt.subplots(3, 1, figsize=(10, 10), sharex=True)
    for ax, a, colour in zip(axes, (3, 5, 7), ("#1f77b4", "#d62728", "#2ca02c")):
        exact = [amplitude(a, w) for w in grid]
        empirical = [transform_norm(a, w, N) for w in grid]
        ax.plot(grid, exact, color=colour, lw=2.2,
                label=r"$|\cos(\pi(a-\frac12)\omega)|$")
        ax.plot(grid, empirical, color="k", lw=0.9, ls="--",
                label=rf"$|F_a(\omega,{N})|/{N}$")
        for r in resonances(a, w_max):
            ax.axvline(r, color=colour, alpha=0.25, lw=1.0)
        ax.set_ylabel(rf"$a = {a}$")
        ax.set_ylim(-0.03, 1.05)
        ax.legend(loc="upper right", fontsize=9)
        ax.grid(alpha=0.2)
    axes[0].set_title("Normalized spectrum of the $an+1$ maps: empirical sum vs. the "
                      "closed-form amplitude\n(vertical lines: resonance comb "
                      r"$\omega=(2m+1)/(2a-1)$)")
    axes[-1].set_xlabel(r"frequency $\omega$")
    fig.tight_layout()
    fig.savefig("collatz_spectrum.png", dpi=150)
    print("wrote collatz_spectrum.png")


if __name__ == "__main__":
    main()


"""Assemble PACKAGE.json from the individual deliverable files."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).parent


def read(p: str) -> str:
    return (ROOT / p).read_text(encoding="utf-8")


LEAN_FILES = [
    "Catalog/Novelty/CollatzSpectralNormalized.lean",
    "Catalog/Novelty/CollatzSpectralUniform.lean",
    "Catalog/Novelty/CollatzSpectralResonance.lean",
]

lean_proofs = "\n\n".join(
    f"-- ===== {f} =====\n{read(f)}" for f in LEAN_FILES
)

FUTURE_DIRECTIONS = """\
# Future Directions

Derived from the verified results on the normalized spectral transforms of the
`an + 1` maps: the limit law, the modulus formula, the resonance classification,
the `3n+1` vs `5n+1` vs `7n+1` discriminator and the `L²` mean; the explicit
`O((1+|ω| log N)/N)` error bound, uniform convergence on compact frequency sets,
and the density-zero blindness no-go; and the arithmetic of the resonance sets
with the pairwise separation of the three classical multipliers.

**What this cycle settled.** The one-step phase `T(n)/n` splits into a constant
even branch `1/2` and an odd branch `a + 1/n`; the odd perturbation `1/n` is
summable after Cesàro averaging, so `F_N(ω)/N → (e(ω/2)+e(aω))/2` with modulus
`|cos(π(a−½)ω)|`. Every question about "cancellation for the `an+1` map at a
fixed frequency" is therefore *completely answered* at the level of the one-step
sum, and the answer contains no dynamical information whatsoever: the transform
is invariant under modification of the map on any set of density zero. The
following conjectures push into the regimes where information can survive.

---

## Conjecture 1 (Second-order spectral law: the `log N` term is a genuine invariant)

For every `a ≥ 1` and every `ω ≠ 0`,
`F a ω N − N · limitAmp a ω − c(a,ω) · log N` converges as `N → ∞`, with
`c(a,ω) = π i ω e(aω)` (the coefficient produced by the odd-branch expansion
`e(ω/n) = 1 + 2πiω/n + O(ω²/n²)` summed against the odd harmonic series).
Equivalently, `(F a ω N − N·limitAmp a ω)/log N → c(a,ω)`.

**The key insight is** that the first-order term erases the multiplier's
arithmetic (it depends only on `e(aω)` through a modulus that is a single
cosine), while the *second*-order term is an honest half-harmonic sum whose
coefficient is linear in `ω` and carries the branch phase `e(aω)` undamped —
so the subleading spectrum sees strictly more than the leading one.

**Why now?** The deviation sum is already isolated and bounded by
`2π|ω|(1 + log N)`; the conjecture asserts that this bound is attained with an
explicit constant. What remains is a matching *lower* bound plus the standard
logarithmic asymptotics of the odd harmonic sum, both of which are within reach
of the existing machinery.

---

## Conjecture 2 (Iterated transforms are not blind)

Define the `m`-step transform `F^{(m)} a ω N = Σ_{n≤N} e(ω · T_a^m(n)/n)`.
Then for each fixed `m`, `F^{(m)} a ω N / N` converges to an explicit finite
combination `Σ_j 2^{−m} · (multiplicity) · e(ω · r_j)`, where `r_j` ranges over
the finitely many limiting `m`-step ratios `a^{k} / 2^{m−k}` (`k` = number of odd
steps), weighted by the density of residue classes mod `2^m` following that
parity pattern. Moreover, for `m ≥ 2` the resonance set of `F^{(m)}` is **not**
a coset of a lattice, and its zero set determines `a` uniquely.

**The key insight is** that one step gives two branches and hence a cosine,
whose zero set is an arithmetic progression encoding only the single integer
`2a − 1`. Two steps give up to four branches with unequal weights, and a sum of
four unit vectors with rational weights has a zero set that is a genuine
algebraic condition in `ω` rather than a lattice coset — so the iterated
spectrum can, in principle, see structure that the one-step spectrum has
flattened away.

---

## Further directions

- Replace the impossible global condition over all irrational frequencies by a
  condition excluding a fixed neighbourhood of the integer resonances.
  Continuity forces values near the zero-frequency peak to remain near the
  cutoff `N`.
- Study normalized transforms `F_N(ω) / N` on compact frequency sets bounded
  away from integers, and seek quantitative cancellation estimates uniform in
  `N`.
- Separate the even and odd summands. For the stated phase `T(n)/n`, the even
  branch contributes the constant phase `1/2`, while the odd branch has phase
  `a + 1/n`; this explicit decomposition should support sharper asymptotic
  estimates.
- Formulate averaged statements, such as `L²` bounds over a period or bounds
  outside an exceptional set of small measure. Such claims are compatible with
  isolated resonant peaks in a way that a pointwise bound over all irrationals
  is not — though the mean square of the amplitude over a full period is the
  universal constant `1/2`, so any useful averaged statistic must be weighted so
  as to detect the *location* of the resonance comb.
- Compare the corrected normalized or averaged statistics for the `3n+1`,
  `5n+1`, and `7n+1` maps. Any useful discriminator must depend on more than
  continuity near frequency zero.
- Investigate orbit-dependent transforms separately from the one-step cutoff
  sum. A rigorous implication between an orbit hitting-time estimate and a
  spectral estimate would require precise definitions and directional proofs; it
  should not be treated as an automatic equivalence.
"""
INTERACTIVE_LAYOUT = read("assets/interactive_layout.md")

package = {
    "title": "Normalized Spectral Transforms of the an+1 Maps: Limit Law, Resonance Arithmetic, and a No-Go Theorem",
    "domain": "Novelty",
    "description": (
        "A complete solution of the one-step exponential sum attached to the accelerated an+1 maps: "
        "the normalized transform converges to (e(w/2)+e(aw))/2, whose modulus is the single cosine "
        "|cos(pi(a-1/2)w)|, so cancellation occurs exactly on the arithmetic progression of resonant "
        "frequencies, and the statistic is provably blind to any modification of the map on a density-zero "
        "set of inputs."
    ),
    "authors": ["Aristotle"],
    "date": "2026-08-11",
    "key_results": [
        "Limit law for the normalized cutoff transform: (1/N) times the sum of e(w T_a(n)/n) over n <= N converges to (e(w/2) + e(aw))/2 for every multiplier a and every real frequency w",
        "Explicit multiplier-uniform error bound (1 + 2*pi*|w|*(1 + log N))/N, giving uniform convergence on every compact frequency set simultaneously for all multipliers",
        "Modulus formula: the limiting amplitude has absolute value |cos(pi (a - 1/2) w)|, so genuine o(N) cancellation occurs exactly when (2a-1)w is an odd integer, and off that set the sum has full linear size",
        "Zero-frequency peak: whenever |(2a-1)w| <= 2/3 the transform eventually exceeds N/4, refuting any pointwise decay statement valid for all irrational frequencies",
        "Arithmetic discriminator: the 3n+1, 5n+1 and 7n+1 maps are separated at the frequencies 1/5, 1/9 and 1/13, they resonate together only at odd integers, and the mean square of the amplitude over a period equals 1/2 for every multiplier, so averaging alone cannot discriminate",
        "No-go theorem: two maps whose phase ratios differ only on a set of density zero have the same normalized transform in the limit, so finite surgery such as inserting or destroying a cycle is spectrally invisible and no spectral estimate can imply an orbit hitting-time estimate",
    ],
    "keywords": [
        "Collatz map",
        "an+1 maps",
        "exponential sums",
        "equidistribution",
        "resonance set",
        "additive characters",
        "Cesaro averaging",
        "no-go theorem",
    ],
    "article": read("ARTICLE.md"),
    "research_paper": read("RESEARCH_PAPER.md"),
    "research_paper_tex": read("RESEARCH_PAPER.tex"),
    "demo": read("demo.py"),
    "demos": [
        {
            "name": "Complete Numerical Audit of the One-Step Collatz Spectrum",
            "description": (
                "A ten-part self-contained numerical study of the cutoff transform "
                "F_a(w,N) = sum_{n<=N} e(w T_a(n)/n). It verifies the exact branch splitting of the phase "
                "ratio (constant 1/2 on even inputs, a + 1/n on odd inputs); measures the convergence "
                "F_a(w,N)/N -> (e(w/2)+e(aw))/2 against the guaranteed error bound (1 + 2*pi*|w|(1+log N))/N; "
                "enumerates the resonance comb w = (2m+1)/(2a-1) and exhibits the bounded, logarithmically "
                "growing residual sum there; documents the zero-frequency peak where |F|/N stays near 1; "
                "reproduces the 3n+1 versus 5n+1 versus 7n+1 discriminator at w = 1/5, 1/9 and 1/13; confirms "
                "by fine grid search that two classical multipliers resonate together only at odd integers; "
                "computes the mean square of the amplitude over a full period and finds the universal value 1/2 "
                "for a = 1, 2, 3, 5, 7, 11, 101; demonstrates that replacing the phase ratio by junk at every "
                "power of two (a density-zero set) leaves the limit untouched; and probes the conjectural "
                "second-order log N law."
            ),
            "code": read("demo.py"),
        }
    ],
    "algorithms": [
        {
            "name": "Branch-Accelerated Evaluation of the Cutoff Transform with Certified Error",
            "description": (
                "Evaluates F_a(w,N) = sum_{n=1}^{N} e(w T_a(n)/n) and certifies its distance to the limiting "
                "amplitude. The naive method costs N character evaluations. The exact even/odd decomposition "
                "F_a(w,N) = floor(N/2) e(w/2) + e(aw) sum_{n<=N, n odd} e(w/n) removes the even branch entirely "
                "at O(1) cost, because every even input contributes the identical phase e(w/2); only the "
                "ceil(N/2) odd inputs require work. Complexity: N/2 transcendental evaluations, O(1) memory, "
                "and numerically stable because every partial term is a unit vector. The routine also returns "
                "the a priori bound (1 + 2*pi*|w|(1+log N))/N, which holds for every multiplier and every N >= 1, "
                "so the caller can check the measured deviation against a proven guarantee."
            ),
            "pseudocode": (
                "INPUT: multiplier a >= 1, frequency w in R, cutoff N >= 1\n"
                "OUTPUT: F = F_a(w,N), A = A_a(w), observed error, certified bound\n"
                "\n"
                "1.  even_part <- floor(N/2) * e(w/2)          # every even n has ratio exactly 1/2\n"
                "2.  tail <- 0\n"
                "3.  for n <- 1, 3, 5, ..., <= N do            # odd n only, ratio = a + 1/n\n"
                "4.      tail <- tail + e(w / n)\n"
                "5.  end for\n"
                "6.  F <- even_part + e(a*w) * tail            # factor e(a w) is common to the odd branch\n"
                "7.  A <- (e(w/2) + e(a*w)) / 2\n"
                "8.  observed <- |F / N - A|\n"
                "9.  bound <- (1 + 2*pi*|w|*(1 + log N)) / N   # proven for all a and all N >= 1\n"
                "10. assert observed <= bound\n"
                "11. return (F, A, observed, bound)"
            ),
            "code": read("assets/alg_transform.py"),
        },
        {
            "name": "Exact Enumeration and Testing of the Resonance Comb",
            "description": (
                "The set of frequencies at which the transform genuinely cancels is R_a = {w : (2a-1)w is an "
                "odd integer} = {(2m+1)/(2a-1) : m in Z}, an arithmetic progression of spacing 2/(2a-1). This "
                "routine enumerates R_a inside a window using exact rational arithmetic, so no floating-point "
                "drift can create or destroy a resonance, and provides an O(1) membership test for a numerical "
                "frequency by comparing (2a-1)w to the nearest odd integer. Enumeration is output-sensitive with "
                "cost Theta((2a-1) * w_max); membership testing is constant time. The companion amplitude routine "
                "returns the closed form |cos(pi (a - 1/2) w)|, letting one see how far from cancellation a "
                "non-resonant frequency is."
            ),
            "pseudocode": (
                "ENUMERATE(a, w_max):\n"
                "1.  d <- 2a - 1                                  # the only way a enters the spectrum\n"
                "2.  out <- empty list; m <- 0\n"
                "3.  loop\n"
                "4.      w <- Fraction(2m + 1, d)                 # exact rational\n"
                "5.      if w > w_max then return out\n"
                "6.      append w to out; m <- m + 1\n"
                "\n"
                "IS_RESONANT(a, w, tol):\n"
                "1.  t <- (2a - 1) * w\n"
                "2.  k <- 2 * round((t - 1)/2) + 1                # nearest odd integer to t\n"
                "3.  return |t - k| < tol\n"
                "\n"
                "AMPLITUDE(a, w):\n"
                "1.  return |cos(pi * (a - 1/2) * w)|             # zero exactly on the comb"
            ),
            "code": read("assets/alg_resonance.py"),
        },
        {
            "name": "Diophantine Search for a Spectrally Separating Frequency",
            "description": (
                "Given a family of multipliers, finds a frequency at which one distinguished map cancels "
                "completely while all the others retain full linear size. Because resonance is the exact "
                "rational condition that (2a-1)w be an odd integer, candidates need only be drawn from the "
                "target's own comb, w = (2m+1)/(2*target-1), and each candidate is tested against the rivals in "
                "exact rational arithmetic; no numerical tolerance is involved. For the classical multipliers "
                "the search succeeds immediately at m = 0, returning 1/5 for 3n+1, 1/9 for 5n+1 and 1/13 for "
                "7n+1, which is guaranteed by the fact that two classical multipliers resonate together only at "
                "odd integers. Complexity: O(max_m * |others|) exact rational operations."
            ),
            "pseudocode": (
                "FIND_DISCRIMINATOR(target, others, max_m):\n"
                "1.  d <- 2*target - 1\n"
                "2.  for m <- 0 to max_m - 1 do\n"
                "3.      w <- Fraction(2m + 1, d)                 # a resonance of the target map\n"
                "4.      separating <- true\n"
                "5.      for b in others do\n"
                "6.          t <- (2b - 1) * w                    # exact rational\n"
                "7.          if t is an integer and t is odd then separating <- false\n"
                "8.      end for\n"
                "9.      if separating then return w              # target cancels, rivals do not\n"
                "10. end for\n"
                "11. return NONE"
            ),
            "code": read("assets/alg_discriminator.py"),
        },
    ],
    "visualizations": [
        {
            "name": "Spectral Fingerprints of the 3n+1, 5n+1 and 7n+1 Maps",
            "description": (
                "For each of the three classical multipliers, overlays the measured normalized transform "
                "|F_a(w,N)|/N on the closed-form amplitude |cos(pi (a - 1/2) w)| across 0 <= w <= 2, with the "
                "resonance comb w = (2m+1)/(2a-1) marked by vertical lines. The three panels display combs of "
                "different spacings, 2/5, 2/9 and 2/13, which is exactly the arithmetic fingerprint that "
                "distinguishes the maps; the shared teeth at the odd integers are the trivial resonances "
                "common to every multiplier."
            ),
            "code": read("assets/viz_spectrum.py"),
        },
        {
            "name": "Phasor Walks: the Geometry of Cancellation",
            "description": (
                "Plots the partial sums of the transform as a walk in the complex plane for four regimes: off "
                "resonance, where the walk is a straight drift of slope equal to the limiting amplitude; at the "
                "resonance w = 1/5 of the 3n+1 map, where the two branch phases are antipodal and the walk "
                "collapses into a bounded curl that creeps only logarithmically; at the same frequency for the "
                "5n+1 map, where no cancellation occurs; and near frequency zero, where the walk is nearly a "
                "straight line of unit speed, pinned against the trivial bound."
            ),
            "code": read("assets/viz_phasor_walk.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Resonance Explorer: Watch a Famous Map Cancel Itself Out",
            "description": (
                "A single-page laboratory for the one-step Collatz spectrum. Drag the multiplier, the frequency "
                "and the cutoff and watch three linked views update live: the phasor walk of the partial sums, "
                "which turns from a straight linear drift into a tight bounded curl the moment the frequency "
                "hits a resonance; the amplitude spectrum, where the measured |F|/N is overlaid on the exact "
                "cosine |cos(pi (a - 1/2) w)| with the resonance comb (2m+1)/(2a-1) drawn in, together with a "
                "live readout of the certified error bound (1 + 2*pi*|w|(1+log N))/N; and a blindness laboratory "
                "in which the map can be sabotaged on the powers of two, on the perfect squares, or on a "
                "positive proportion of all inputs, showing that only the last of these moves the limit. "
                "One-click presets jump to the separating frequencies 1/5, 1/9 and 1/13 of the three classical "
                "maps, to the zero-frequency peak, and to a trivial shared resonance."
            ),
            "html": read("assets/widget_resonance_explorer.html"),
        }
    ],
    "interactive_layout": INTERACTIVE_LAYOUT,
    "lean_proofs": lean_proofs,
    "future_directions": FUTURE_DIRECTIONS,
    "modules": {
        "demo": read("demo.py"),
        "alg_transform": read("assets/alg_transform.py"),
        "alg_resonance": read("assets/alg_resonance.py"),
        "alg_discriminator": read("assets/alg_discriminator.py"),
        "viz_spectrum": read("assets/viz_spectrum.py"),
        "viz_phasor_walk": read("assets/viz_phasor_walk.py"),
    },
    "lean_files": LEAN_FILES,
}

(ROOT / "PACKAGE.json").write_text(
    json.dumps(package, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
)
print("wrote PACKAGE.json")


"""
Normalized spectral transforms of the (a n + 1) maps
====================================================

Self-contained numerical demonstration of the results described in the
accompanying article and research paper.

Setting
-------
For an integer multiplier a >= 1 define the accelerated one-step map

    T_a(n) = n / 2         if n is even,
    T_a(n) = a * n + 1     if n is odd,

and the phase ratio r_a(n) = T_a(n) / n.  The cutoff transform is

    F_a(w, N) = sum_{n=1}^{N} e(w * r_a(n)),    e(x) = exp(2*pi*i*x).

Results demonstrated numerically here:

  1. Branch splitting:  r_a(n) = 1/2 for even n, and r_a(n) = a + 1/n for odd n.
  2. Limit law:         F_a(w, N) / N -> A_a(w) = (e(w/2) + e(a*w)) / 2.
  3. Modulus formula:   |A_a(w)| = |cos(pi * (a - 1/2) * w)|.
  4. Resonance set:     A_a(w) = 0  <=>  (2a - 1) * w is an odd integer.
  5. Error bound:       |F_a(w,N)/N - A_a(w)| <= (1 + 2*pi*|w|*(1 + log N)) / N.
  6. Discriminator:     at w = 1/5 the 3n+1 map resonates, 5n+1 and 7n+1 do not.
  7. L2 mean:           the mean of |A_a(w)|^2 over a full period equals 1/2
                        for every a, so plain averaging cannot discriminate.
  8. Blindness:         altering the map on a density-zero set of inputs does
                        not change the limit of the normalized transform.

Run:  python demo.py
"""

from __future__ import annotations

import cmath
import math
from typing import Callable, List, Tuple

TWO_PI: float = 2.0 * math.pi


# ----------------------------------------------------------------------
# Core objects
# ----------------------------------------------------------------------
def e(x: float) -> complex:
    """The additive character e(x) = exp(2*pi*i*x)."""
    return cmath.exp(1j * TWO_PI * x)


def step(a: int, n: int) -> int:
    """One step of the accelerated a*n + 1 map."""
    return n // 2 if n % 2 == 0 else a * n + 1


def ratio(a: int, n: int) -> float:
    """The phase ratio T_a(n) / n."""
    return step(a, n) / n


def F(a: int, w: float, N: int) -> complex:
    """Cutoff transform F_a(w, N) = sum_{n=1}^{N} e(w * r_a(n))."""
    total = 0j
    for n in range(1, N + 1):
        total += e(w * ratio(a, n))
    return total


def limit_amp(a: int, w: float) -> complex:
    """The limiting normalized amplitude A_a(w) = (e(w/2) + e(a w)) / 2."""
    return (e(w / 2.0) + e(a * w)) / 2.0


def amp_modulus(a: int, w: float) -> float:
    """Closed form |A_a(w)| = |cos(pi (a - 1/2) w)|."""
    return abs(math.cos(math.pi * (a - 0.5) * w))


def is_resonant(a: int, w: float, tol: float = 1e-12) -> bool:
    """Test whether (2a - 1) w is an odd integer, i.e. whether A_a(w) = 0."""
    t = (2 * a - 1) * w
    return abs(t - 2.0 * round((t - 1.0) / 2.0) - 1.0) < tol


def error_bound(w: float, N: int) -> float:
    """Explicit upper bound for |F_a(w,N)/N - A_a(w)|, uniform in a."""
    return (1.0 + TWO_PI * abs(w) * (1.0 + math.log(N))) / N


def F_generic(r: Callable[[int], float], w: float, N: int) -> complex:
    """Cutoff transform of an arbitrary phase-ratio function r(n)."""
    return sum((e(w * r(n)) for n in range(1, N + 1)), 0j)


# ----------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------
def demo_branch_splitting(a: int = 3, upto: int = 10) -> None:
    print("=" * 72)
    print(f"1. Branch splitting of the phase ratio for the {a}n+1 map")
    print("=" * 72)
    print(f"{'n':>4} {'T_a(n)':>10} {'r_a(n)':>12} {'predicted':>12}")
    for n in range(1, upto + 1):
        pred = 0.5 if n % 2 == 0 else a + 1.0 / n
        print(f"{n:>4} {step(a, n):>10} {ratio(a, n):>12.6f} {pred:>12.6f}")
        assert abs(ratio(a, n) - pred) < 1e-12
    print("Even branch is the constant 1/2; odd branch is a + 1/n -> a.\n")


def demo_limit_law(a: int = 3, w: float = 0.37) -> None:
    print("=" * 72)
    print(f"2-3. Limit law and modulus formula (a = {a}, w = {w})")
    print("=" * 72)
    A = limit_amp(a, w)
    print(f"A_a(w) = {A.real:+.8f} {A.imag:+.8f}i   |A_a(w)| = {abs(A):.8f}")
    print(f"closed form |cos(pi (a - 1/2) w)| = {amp_modulus(a, w):.8f}")
    assert abs(abs(A) - amp_modulus(a, w)) < 1e-12
    print()
    print(f"{'N':>8} {'|F/N - A|':>14} {'bound':>14} {'|F|/N':>10}")
    for N in (10, 100, 1_000, 10_000, 100_000):
        v = F(a, w, N) / N
        err = abs(v - A)
        print(f"{N:>8} {err:>14.3e} {error_bound(w, N):>14.3e} {abs(v):>10.6f}")
        assert err <= error_bound(w, N) + 1e-12
    print("The observed error obeys the O((1 + |w| log N)/N) bound.\n")


def demo_resonances(a: int = 3, wmax: float = 3.0) -> None:
    print("=" * 72)
    print(f"4. Resonance set of the {a}n+1 map in 0 < w <= {wmax}")
    print("=" * 72)
    found: List[float] = []
    m = 0
    while True:
        w = (2 * m + 1) / (2 * a - 1)
        if w > wmax:
            break
        found.append(w)
        m += 1
    print("Resonant frequencies w = (2m+1)/(2a-1):")
    for w in found:
        assert is_resonant(a, w)
        assert amp_modulus(a, w) < 1e-12
        print(f"   w = {w:.6f}   |A_a(w)| = {amp_modulus(a, w):.2e}")
    print(f"Spacing is exactly 2/(2a-1) = {2/(2*a-1):.6f}.\n")


def demo_cancellation_at_resonance(a: int = 3) -> None:
    print("=" * 72)
    print(f"4b. Genuine o(N) cancellation at a resonance of the {a}n+1 map")
    print("=" * 72)
    w = 1.0 / (2 * a - 1)  # (2a-1) w = 1, an odd integer
    print(f"w = 1/(2a-1) = {w:.6f}, |A_a(w)| = {amp_modulus(a, w):.2e}")
    print(f"{'N':>8} {'|F|':>14} {'|F|/N':>12}")
    for N in (10, 100, 1_000, 10_000, 100_000):
        v = F(a, w, N)
        print(f"{N:>8} {abs(v):>14.6f} {abs(v)/N:>12.3e}")
    print("|F| stays bounded (O(log N) growth) while N grows: full cancellation.\n")


def demo_peak_near_zero(a: int = 3) -> None:
    print("=" * 72)
    print("5. The zero-frequency peak: no uniform pointwise decay is possible")
    print("=" * 72)
    N = 20_000
    print(f"{'w':>12} {'|A_a(w)|':>12} {'|F|/N':>12}")
    for w in (1e-4, 1e-3, 1e-2, 0.05, 0.1):
        print(f"{w:>12.5f} {amp_modulus(a, w):>12.6f} {abs(F(a, w, N))/N:>12.6f}")
    print("For every small w (irrational ones included) |F| >= N/4 eventually.\n")


def demo_discriminator(w: float = 0.2) -> None:
    print("=" * 72)
    print(f"6. Arithmetic discriminator at w = {w} (= 1/5)")
    print("=" * 72)
    N = 100_000
    print(f"{'a':>4} {'(2a-1)w':>10} {'resonant':>10} {'|A_a(w)|':>12} {'|F|/N':>12}")
    for a in (3, 5, 7):
        val = abs(F(a, w, N)) / N
        print(f"{a:>4} {(2*a-1)*w:>10.4f} {str(is_resonant(a, w)):>10} "
              f"{amp_modulus(a, w):>12.6f} {val:>12.6f}")
    print("Only 3n+1 has (2a-1)w = 1 odd: it alone shows full cancellation.")
    print()
    print("Separating frequencies for the three classical multipliers:")
    for a, w0 in ((3, 1 / 5), (5, 1 / 9), (7, 1 / 13)):
        others = [b for b in (3, 5, 7) if b != a]
        print(f"   w = 1/{round(1/w0)}: a = {a} resonates; "
              f"a = {others[0]}, {others[1]} give "
              f"|A| = {amp_modulus(others[0], w0):.4f}, "
              f"{amp_modulus(others[1], w0):.4f}")
    print()


def demo_common_resonances() -> None:
    print("=" * 72)
    print("6b. Two multipliers resonate together only at odd integers")
    print("=" * 72)
    grid = [k / 2000 for k in range(1, 12_001)]  # 0 < w <= 6
    both: List[float] = []
    for w in grid:
        if is_resonant(3, w, 1e-9) and is_resonant(5, w, 1e-9):
            both.append(w)
    print("Common resonances of 3n+1 and 5n+1 on a fine grid of (0, 6]:")
    print("   " + ", ".join(f"{w:.4f}" for w in both))
    print("These are exactly the odd integers 1, 3, 5 - the trivial resonances.\n")


def mean_square_amp(a: int, samples: int = 200_000) -> float:
    """Mean of |A_a(w)|^2 over the period 0 <= w <= 2 (midpoint rule)."""
    total = 0.0
    for k in range(samples):
        w = 2.0 * (k + 0.5) / samples
        total += amp_modulus(a, w) ** 2
    return total / samples


def demo_mean_square() -> None:
    print("=" * 72)
    print("7. The L2 mean of the amplitude is 1/2 for every multiplier")
    print("=" * 72)
    print(f"{'a':>4} {'mean |A_a|^2 over [0,2]':>26}")
    for a in (1, 2, 3, 5, 7, 11, 101):
        m = mean_square_amp(a)
        print(f"{a:>4} {m:>26.8f}")
        assert abs(m - 0.5) < 1e-4
    print("Averaging destroys the arithmetic; only the resonance locations differ.\n")


def demo_blindness(a: int = 3, w: float = 0.37) -> None:
    print("=" * 72)
    print("8. Blindness to density-zero modifications of the map")
    print("=" * 72)

    def perturbed(n: int) -> float:
        # Alter the phase ratio drastically on the powers of two: a set of
        # density zero (about log2(N) indices below N).
        if n & (n - 1) == 0:
            return 17.0 * math.sqrt(2.0)
        return ratio(a, n)

    A = limit_amp(a, w)
    print(f"{'N':>8} {'|F/N - A|':>14} {'|F_pert/N - A|':>18}")
    for N in (100, 1_000, 10_000, 100_000):
        v = F(a, w, N) / N
        vp = F_generic(perturbed, w, N) / N
        print(f"{N:>8} {abs(v - A):>14.3e} {abs(vp - A):>18.3e}")
    print("Both converge to the same amplitude: sparse dynamical surgery is")
    print("invisible to the one-step spectrum.\n")


def demo_second_order() -> None:
    print("=" * 72)
    print("9. Probing the conjectural second-order log term")
    print("=" * 72)
    a, w = 3, 0.37
    A = limit_amp(a, w)
    c = math.pi * 1j * w * e(a * w)
    print(f"predicted c(a,w) = pi i w e(a w) = {c.real:+.6f} {c.imag:+.6f}i")
    print(f"{'N':>8} {'(F - N A)/log N':>34}")
    for N in (10**3, 10**4, 10**5, 10**6):
        d = (F(a, w, N) - N * A) / math.log(N)
        print(f"{N:>8}   {d.real:+.6f} {d.imag:+.6f}i")
    print("The ratio drifts slowly towards the predicted coefficient.\n")


def main() -> None:
    demo_branch_splitting()
    demo_limit_law()
    demo_resonances()
    demo_cancellation_at_resonance()
    demo_peak_near_zero()
    demo_discriminator()
    demo_common_resonances()
    demo_mean_square()
    demo_blindness()
    demo_second_order()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
