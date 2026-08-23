"""Constant-free cross-channel consistency audit for co-measured cost channels."""

from __future__ import annotations

import math
from typing import Dict, Optional


def doubling_constant(t: float) -> float:
    """K(t) = (1 + 2^t)^2 / (4 * 2^t): the sharp reverse power-mean constant
    on a dyadic window along the doubling ray s = 2t."""
    if t <= 0.0:
        raise ValueError("t must be positive")
    two_t = 2.0 ** t
    return (1.0 + two_t) ** 2 / (4.0 * two_t)


def generic_allowance(s: float, t: float, dk: float) -> float:
    """Power-mean allowance s*t/dk for |t*slope_s - s*slope_t|."""
    return s * t / dk


def sharp_allowance(s: float, t: float, dk: float) -> Optional[float]:
    """Sharp allowance for |t*slope_s - s*slope_t| on the doubling ray s = 2t,
    where the law reads |slope_{2t} - 2*slope_t| <= log2 K(t)/dk; rescaling by t
    puts it in the same normalisation as `generic_allowance`.  The classical
    Cauchy-Schwarz / Kantorovich member is (s, t) = (1, 1/2).  Returns None off
    the ray, where no sharp constant is currently known."""
    if not math.isclose(s, 2.0 * t, rel_tol=1e-12, abs_tol=1e-12):
        return None
    return t * math.log2(doubling_constant(t)) / dk


def audit(slope_a: float, slope_b: float, s: float, t: float, dk: float) -> Dict[str, object]:
    """Audit a pair of across-level slopes measured on ONE population.

    Channel A has pointwise cost a*p^s, channel B has pointwise cost c*p^t,
    with 0 < t <= s.  Both implementation constants a and c cancel from the
    audit; it consumes no calibration information whatsoever.
    """
    if not (0.0 < t <= s):
        raise ValueError("require 0 < t <= s")
    if dk <= 0.0:
        raise ValueError("lever arm must be positive")
    disc = abs(t * slope_a - s * slope_b)
    gen = generic_allowance(s, t, dk)
    sharp = sharp_allowance(s, t, dk)
    binding = gen if sharp is None else sharp
    return {
        "discrepancy": disc,
        "generic_allowance": gen,
        "sharp_allowance": sharp,
        "binding_allowance": binding,
        "violation_factor": disc / binding if binding > 0 else float("inf"),
        "verdict": "IMPOSSIBLE" if disc > binding else "CONSISTENT",
    }


if __name__ == "__main__":
    # The reported round-41 pair, trial division (s = 1) against Pollard rho
    # (t = 1/2), on one population, lever arm dk = 8.
    result = audit(slope_a=0.84, slope_b=0.52, s=1.0, t=0.5, dk=8.0)
    for key, val in result.items():
        print(f"{key:>22}: {val}")


"""Two-point exponent estimation with a certified identifiability band."""

from __future__ import annotations

import math
from typing import Dict, Tuple


def log_slope(e1: float, e2: float, k1: int, k2: int) -> float:
    """Two-point log-log slope (log2 E(k2) - log2 E(k1)) / (k2 - k1)."""
    if e1 <= 0.0 or e2 <= 0.0:
        raise ValueError("mean costs must be strictly positive")
    if k1 == k2:
        raise ValueError("levels must differ")
    return (math.log2(e2) - math.log2(e1)) / float(k2 - k1)


def certified_band(alpha: float, log_spread: float, dk: float) -> Tuple[float, float]:
    """Interval [alpha - sigma/dk, alpha + sigma/dk] guaranteed to contain the
    two-point slope of any curve obeying a power band of logarithmic spread
    `log_spread` around exponent `alpha`."""
    if log_spread < 0.0:
        raise ValueError("logarithmic spread must be nonnegative")
    if dk <= 0.0:
        raise ValueError("lever arm must be positive")
    tol = log_spread / dk
    return (alpha - tol, alpha + tol)


def estimate_exponent(
    e_lo: float,
    e_hi: float,
    k_lo: int,
    k_hi: int,
    alpha_model: float,
    log_spread: float,
) -> Dict[str, object]:
    """Full inference step for one channel.

    Returns the measured slope, the certified band for the asserted model, the
    verdict ('REFUTED' / 'NON-REFUTING'), the two-point resolution 2*sigma/dk,
    and -- when the model is refuted -- the multiplicative constant drift that
    any rescue of the model would have to exhibit.
    """
    dk = float(k_hi - k_lo)
    slope = log_slope(e_lo, e_hi, k_lo, k_hi)
    lo, hi = certified_band(alpha_model, log_spread, dk)
    deficit = abs(slope - alpha_model)
    refuted = not (lo <= slope <= hi)
    return {
        "slope": slope,
        "band": (lo, hi),
        "lever_arm": dk,
        "resolution": 2.0 * log_spread / dk,
        "deficit": deficit,
        "verdict": "REFUTED" if refuted else "NON-REFUTING",
        "required_spread_for_rescue": 2.0 ** (deficit * dk),
    }


if __name__ == "__main__":
    # Trial division: pointwise cost a*p on a dyadic window has logarithmic
    # spread exactly s = 1, so the certified band at dk = 8 is 1 +/- 1/8.
    fake_lo, fake_hi = 1.0, 2.0 ** (0.84 * 8)  # a curve with measured slope 0.84
    out = estimate_exponent(fake_lo, fake_hi, 16, 24, alpha_model=1.0, log_spread=1.0)
    for key, val in out.items():
        print(f"{key:>28}: {val}")


"""Shape-drift decomposition: split a measured exponent into a true exponent
plus the logarithmic drift of the normalized population moment."""

from __future__ import annotations

import math
from typing import Dict, Sequence


def mean(xs: Sequence[float]) -> float:
    if not xs:
        raise ValueError("empty sample")
    return math.fsum(xs) / float(len(xs))


def shape_moment(pop: Sequence[float], k: int, s: float) -> float:
    """M_s(k) = mean((p / 2^k)^s), the normalized s-th moment of a level-k
    population.  Scale-invariant samplers have M_s independent of k."""
    scale = 2.0 ** k
    return mean([(p / scale) ** s for p in pop])


def decompose(
    pop_lo: Sequence[float],
    pop_hi: Sequence[float],
    k_lo: int,
    k_hi: int,
    s: float,
) -> Dict[str, float]:
    """Exact decomposition  slope = s + log2(M_s(k_hi)/M_s(k_lo)) / dk.

    The returned 'reconstructed_slope' equals the directly measured slope
    identically, so any mismatch is a pipeline bug rather than approximation
    error -- which makes this both a diagnosis and an audit.
    """
    dk = float(k_hi - k_lo)
    m_lo = shape_moment(pop_lo, k_lo, s)
    m_hi = shape_moment(pop_hi, k_hi, s)
    e_lo = mean([p ** s for p in pop_lo])
    e_hi = mean([p ** s for p in pop_hi])
    measured = (math.log2(e_hi) - math.log2(e_lo)) / dk
    drift = math.log2(m_hi / m_lo) / dk
    return {
        "shape_moment_lo": m_lo,
        "shape_moment_hi": m_hi,
        "shape_ratio": m_lo / m_hi,
        "drift_term": drift,
        "measured_slope": measured,
        "reconstructed_slope": s + drift,
        "residual": abs(measured - (s + drift)),
    }


def forced_shape_ratio(measured_slope: float, s: float, dk: float) -> Dict[str, object]:
    """Invert the identity: a measured deficit d = s - slope pins the drift
    exactly, M_s(k_lo)/M_s(k_hi) = 2^(d*dk).  A dyadic sampler has all its
    normalized means in [1/2, 1], so its ratio can never exceed 2."""
    deficit = s - measured_slope
    ratio = 2.0 ** (deficit * dk)
    return {
        "deficit": deficit,
        "forced_shape_ratio": ratio,
        "dyadic_maximum": 2.0,
        "dyadic_compatible": ratio <= 2.0,
    }


if __name__ == "__main__":
    # The drifting sampler u_k = 2^(-0.16 k) realizes the reported slope exactly.
    k1, k2 = 16, 24
    lo = [2.0 ** (0.84 * k1)] * 500
    hi = [2.0 ** (0.84 * k2)] * 500
    for key, val in decompose(lo, hi, k1, k2, s=1.0).items():
        print(f"{key:>22}: {val}")
    print()
    for key, val in forced_shape_ratio(0.84, s=1.0, dk=8.0).items():
        print(f"{key:>22}: {val}")


#!/usr/bin/env python3
"""Assemble PACKAGE.json from the individual deliverables in the project."""

from __future__ import annotations

import json
import os
from typing import Dict, List

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS = os.path.join(ROOT, "assets")

LEAN_FILES: List[str] = [
    "Catalog/Probability/FactorLocalETScaling.lean",
    "Catalog/Probability/FactorLocalETCrossChannel.lean",
    "Catalog/Probability/FactorLocalETPowerMean.lean",
    "Catalog/Probability/FactorLocalETKantorovich.lean",
    "Catalog/Probability/FactorLocalETDoubling.lean",
    "Catalog/Probability/FactorLocalETTruncation.lean",
    "Catalog/Probability/FactorLocalETShapeDrift.lean",
]


def read(rel: str) -> str:
    with open(os.path.join(ROOT, rel), "r", encoding="utf-8") as fh:
        return fh.read()


def asset(name: str) -> str:
    with open(os.path.join(ASSETS, name), "r", encoding="utf-8") as fh:
        return fh.read()


def lean_bundle() -> str:
    chunks: List[str] = []
    for path in LEAN_FILES:
        chunks.append("/- " + "=" * 74 + "\n   FILE: " + path + "\n   " + "=" * 74 + " -/\n")
        chunks.append(read(path).rstrip() + "\n")
    return "\n".join(chunks)


FUTURE_DIRECTIONS = """# FUTURE DIRECTIONS — FACTOR-LOCAL-ET

## What survived this cycle

1. **Slope identifiability.**  Multiplicative model error enters a two-point
   exponent measurement divided by the lever arm: `|slope − α| ≤ log₂(c₂/c₁)/Δk`.
   Everything else in the development is a consequence of this one inequality,
   used in both directions.

2. **Pollard ρ is the birthday law.**  The certified band at `Δk = 8` is
   `1/2 ± 1/16`, and an explicit admissible curve inside the dyadic birthday
   window has slope exactly `0.52`.  The measurement is non-refuting, and its
   exponent is anchored in a *proved* threshold: the minimal storage for a
   guaranteed 2-sum collision mod `p` is exactly `⌊√p⌋ + 1`.

3. **Fermat is a gap meter, not an algorithmic exponent.**  The exponent
   transfer law `α_Fermat = 2β_gap − 1` was proved and then confirmed
   numerically (`0.985` vs `2(0.999) − 1`).  Inverting the reported `0.50`
   predicts `β_gap = 0.75`.

4. **The trial-division `0.84` is a refutation, not a measurement.**  A
   pointwise `a·p` cost on any dyadic population forces `slope > 0.875`; matching
   `0.84` at all requires a constant drift of at least `2^{5/4} > 2.36`.

5. **Cross-channel rigidity.**  Running two channels on the *same* draw is
   itself a constraint: Cauchy–Schwarz plus the dyadic window give
   `|slope_trial − 2·slope_ρ| ≤ 1/Δk` with both implementation constants
   cancelling.  The reported pair `(0.84, 0.52)` violates it, and an explicit
   witness shows the hypotheses are satisfiable, so the violation is real
   content.

6. **Power-mean rigidity at general exponent pairs.**  The Cauchy–Schwarz
   coupling was only the `(s, t) = (1, 1/2)` instance.  Power-mean monotonicity
   plus the dyadic window give `|t·slope_A − s·slope_B| ≤ s·t/Δk` for pointwise
   costs `a·p^s`, `c·p^t` on one population, with both implementation constants
   cancelling; the `(1, 1/2)` case recovers the earlier law.  Note that the
   constant conjectured previously, `(s+t)/(2Δk)`, was **wrong**: the correct one
   is `s·t/Δk`.

7. **The identifiability band is attained, and its converse holds.**  An
   endpoint-saturating curve inside a window of spread `2^σ` has measured slope
   exactly `α + σ/Δk`, so the identifiability inequality cannot be improved; and
   two exponents differing by `2σ/Δk` admit two admissible populations with
   *identical* two-point slopes.  This is the design bound behind the
   "within-`k` fits confounded" caveat (`Δk < 1` gives no resolution at all).

8. **Sharp constants.**  Kantorovich replaces the crude window reversal, giving
   `log₂((4+3√2)/8) < 0.044` in place of `1`; along the doubling ray `s = 2t` the
   sharp family is `K(t) = (1+2^t)²/(4·2^t)`, with `log₂K(t) < 2t²` and
   `log₂K(t) ~ t²·ln2/4` as `t → 0`.  **Open:** the sharp constant off the
   doubling ray, i.e. for general `0 < t < s` with `s ≠ 2t`.

9. **Cost truncation is ruled out.**  The natural rescue `min(p, B·2^k)` cannot
   manufacture a deficit past `1/8` for any truncation level `B`, and for
   `B ≤ 1/2` the deficit is exactly zero.  The compression must come from the
   `p`-distribution, not the cost accounting.

10. **Direct measurement of the shape drift.**  The shape-drift identity turns
    the reported `0.84` into the exact prediction `M₁(16)/M₁(24) = 2^{1.28}`.
    Measuring the normalised moments of the actual draws would settle, in one
    computation, whether the anomaly lives in the sampler or in the fitting
    procedure.

11. **Extending the formalism to subexponential channels.**  ECM and the number
    field sieve have costs of the form `exp(c (log p)^γ (log log p)^{1-γ})`.  A
    band formalism in the variable `log log` rather than `log` would be needed,
    and the analogue of the lever-arm division is not yet known.  ECM remains
    deferred.
"""


INTERACTIVE_LAYOUT = r"""
# Three Clocks, One Race
### A guided tour of what it means to *measure* a scaling exponent

---

## 0. The question in one paragraph

You are handed a number $N = pq$, the product of two primes of roughly equal size, and asked to find $p$.
Trial division walks the primes upward and costs about $p$ steps. Pollard's rho wanders pseudorandomly
through the residues mod $p$ and, by the birthday paradox, costs about $\sqrt{p}$. Fermat's method searches
for $N = x^2 - y^2$ from $x = \lceil\sqrt N\rceil$ upward. Everyone "knows" the exponents. This page is about
what happens when you actually measure them — on **one** population of balanced semiprimes, at bit sizes
$k \in \{16, 20, 24\}$, running all three algorithms on the *same* draws.

The measurement returned:

| channel | measured slope |
|---|---|
| trial division | $0.84$ |
| Pollard rho | $0.52$ |
| Fermat | $0.50$ |

Two of those look like triumphs. One is sixteen percent short of where it should be. By the end of this
page you will know, precisely, which of those readings are confirmations, which are thermometers pointed
at the wrong thing, and which is an outright refutation — and you will be able to say *exactly* what the
refutation implies about the sampler.

---

## 1. Why an exponent is measurable at all

Define the **two-point log-log slope** of a mean cost $E(k)$ across two levels:

$$\mathrm{slope}(k_1,k_2) \;=\; \frac{\log_2 E(k_2) - \log_2 E(k_1)}{k_2 - k_1}, \qquad \Delta k = k_2 - k_1 .$$

If $E(k) = C\cdot 2^{\alpha k}$ exactly, this returns $\alpha$ — for *any* two levels, and *whatever* the
constant $C$ is. The constant cancels in the difference of logarithms. That single fact is the licence for
every exponent measurement ever made: you never have to calibrate your implementation.

<details>
<summary><b>Click to reveal the (two-line) proof</b></summary>

$\log_2 E(k) = \log_2 C + \alpha k$, so the numerator is $(\log_2 C + \alpha k_2) - (\log_2 C + \alpha k_1)
= \alpha(k_2-k_1)$, and dividing by $k_2 - k_1$ leaves $\alpha$. $\blacksquare$

Notice how brittle the argument looks: it needs the power law to hold *exactly*. Everything interesting
below is about repairing it when it holds only approximately.
</details>

---

## 2. The central object: a power band

Real costs are not pure powers. The honest hypothesis asserts the exponent and declines to assert the
constant. Say $E$ obeys a **power band** with exponent $\alpha$ and constants $0 < c_1 \le c_2$ when

$$c_1\cdot 2^{\alpha k}\;\le\;E(k)\;\le\;c_2\cdot 2^{\alpha k}\qquad\text{for every }k .$$

On a logarithmic plot that is a straight *corridor* of height $\sigma = \log_2(c_2/c_1)$ around the line
$\alpha k$. And a chord across a corridor of height $\sigma$ over a horizontal run $\Delta k$ can tilt away
from $\alpha$ by at most $\sigma/\Delta k$. That is the whole theory:

> **Identifiability Theorem.** $\;\bigl|\mathrm{slope}(k_1,k_2) - \alpha\bigr| \le \dfrac{\log_2(c_2/c_1)}{\Delta k}$.

**Multiplicative model error enters an exponent measurement divided by the lever arm.** Play with it —
drag the two endpoints around inside the corridor and watch the slope respond.

{{interactive_demo:0}}

<details>
<summary><b>Two things the widget is showing you that are theorems</b></summary>

**The band is attained.** Sliding one endpoint to the bottom of the corridor and the other to the top gives
a slope of exactly $\alpha + \sigma/\Delta k$. So the inequality cannot be improved — it is not a slack
estimate, it is the exact extremal value.

**The band has a converse.** Two exponents differing by exactly $2\sigma/\Delta k$ admit two admissible
curves — one saturating upward, one saturating downward — whose two-point slopes are *identical*. No
two-level estimator can separate them, whatever fitting procedure you use. So $2\sigma/\Delta k$ is not a
nuisance; it is the **resolution of the instrument**, and it is exactly computable. This is also why fits
performed *within* a single bit size (effectively $\Delta k \lesssim 1$) carry essentially no information
about the exponent.

**And the inequality runs backwards.** If a measured slope misses $\alpha$ by at least $d$, then no power
band with spread below $2^{d\Delta k}$ can hold. An anomalous slope is a *quantified statement about the
constants*. Read this way, the theorem is a refutation engine.
</details>

Here is the same picture drawn statically, alongside the decay of the tolerance $\sigma/\Delta k$ with the
lever arm. Notice where the two reported factoring slopes fall relative to their own curves.

{{visualization:0}}

And here is the corresponding inference step as a piece of code — the estimator with its certified band,
its verdict, and, when the verdict is *refuted*, the constant drift any rescue would need to exhibit.

{{algorithm:0}}

---

## 3. The window pins the constants — and the first refutation

So far $c_1, c_2$ were free. In this experiment they are not, because "the factor has exactly $k$ bits"
means $2^{k-1} \le p < 2^{k}$: a **dyadic window**. If every instance costs exactly $a\cdot p^{s}$, then the
mean cost is trapped between $a\,2^{s(k-1)}$ and $a\,2^{sk}$ — a corridor of height exactly $s$, with the
unknown constant $a$ appearing in both endpoints and cancelling.

> **Pointwise Slope Band.** For a pointwise cost $a\cdot p^{s}$ on a dyadic population,
> $\;|\mathrm{slope} - s| \le s/\Delta k$, with **no hypothesis on $a$ whatsoever**.

Put in the numbers for trial division: $s = 1$, $\Delta k = 8$. The slope must be at least $0.875$.

The measurement said $0.84$.

**That is a refutation with no free parameters left to blame.** Not a noisy confirmation of linearity — a
falsification of it.

---

## 4. Two clocks on one stopwatch

Now for the structurally distinctive point. All three algorithms ran on the *same* draws. So the
trial-division cost and the rho cost are two different functions of the *same* random variable $p$, and
their expectations are yoked together. Cauchy–Schwarz gives $(\mathbb{E}\sqrt p)^2 \le \mathbb{E}[p]$, and
confinement to a dyadic window gives the reverse $\mathbb{E}[p] \le 2(\mathbb{E}\sqrt p)^2$. Take logarithms,
difference across the lever arm, and *both* implementation constants vanish:

> **Cross-Channel Rigidity Law.** $\;\bigl|\mathrm{slope}_{\mathrm{trial}} - 2\,\mathrm{slope}_{\rho}\bigr| \le 1/\Delta k$.

This says nothing about what either slope *is*. It says the two cannot be chosen independently. At
$\Delta k = 8$ it allows a discrepancy of $0.125$. The reported pair demands $2(0.52) - 0.84 = 0.20$.

**The reported pair is impossible.** Explore the admissible region yourself:

{{interactive_demo:1}}

<details>
<summary><b>The constant was far too generous — enter Kantorovich</b></summary>

The reverse bound $\mathbb{E}[p] \le 2(\mathbb{E}\sqrt p)^2$ throws away all interior structure of the
window. The sharp tool is the **Kantorovich inequality**: for a sample $y$ confined to $[a,b]$,

$$4ab\,\mathbb{E}[y^2] \;\le\; (a+b)^2 (\mathbb{E}y)^2 ,$$

which follows from the pointwise fact $(y-a)(b-y)\ge 0$ plus one completion of a square. Substituting
$y = \sqrt p$ on a dyadic window (where $b/a = \sqrt 2$) replaces the factor $2$ by

$$\frac{4+3\sqrt2}{8}\approx 1.0303, \qquad \log_2\frac{4+3\sqrt2}{8} \approx 0.04311 < 0.044 .$$

At $\Delta k = 8$ the *entire* admissible discrepancy is below $0.0055$. The reported pair demands $0.20$:
it misses by a factor of more than **thirty-six**.

This is not a trick special to the pair $(1, \tfrac12)$. Substituting $y = p^{t}$ shows the whole
*doubling ray* $s = 2t$ carries a sharp constant $K(t) = (1+2^{t})^2/(4\cdot 2^{t})$, with
$K(1/2) = (4+3\sqrt2)/8$ and $\log_2 K(t) < 2t^2$ always. And away from the ray, for arbitrary
$0 < t \le s$, power-mean monotonicity (Jensen for $x\mapsto x^{s/t}$) still yields a constant-free law

$$\bigl|\,t\cdot\mathrm{slope}_{s} - s\cdot\mathrm{slope}_{t}\,\bigr| \;\le\; \frac{s\,t}{\Delta k}.$$

A note on how research actually goes: the constant conjectured for this general law was $(s+t)/(2\Delta k)$,
and it was simply **wrong**. The correct one is $s\,t/\Delta k$.
</details>

The gap between the crude and the sharp constant, across the whole doubling ray, together with the
admissible region in the plane of co-measured slopes:

{{visualization:1}}

The audit itself is four lines of arithmetic and consumes no calibration information at all:

{{algorithm:1}}

---

## 5. Where did the missing exponent go?

We have a hard fact and an obligation. Two hypotheses present themselves.

<details>
<summary><b>Hypothesis one: the cost accounting is wrong (spoiler — no)</b></summary>

Real implementations abandon trial division after a bound proportional to the modulus, paying
$\min(p, B\cdot 2^{k})$. Does truncation manufacture the deficit?

No, and the reason is clean. On a dyadic population the truncated cost still obeys a corridor with exponent
$1$ and constants $a\min(\tfrac12, B)$ and $a\min(1, B)$ — a spread of at most $2$, **uniformly in $B$**.
Truncation removes mass; it cannot tilt the window by more than the window's own width. So the slope is
still $\ge 0.875$ and the achievable deficit is strictly below $1/8$, never the required $0.16$.

The extreme case is the sharpest form of the obstruction: if $B \le \tfrac12$ the bound binds on every single
draw, the cost becomes the pure power $aB\cdot 2^{k}$, and the measured slope is **exactly $1$** — deficit
zero, not $0.16$. Truncating harder makes the anomaly *smaller*, not larger.
</details>

**Hypothesis two: the population is wrong.** Write $p_k(i) = 2^{k}\,u_k(i)$ and let
$M_s(k) = \mathbb{E}[u_k^{s}]$ be the **shape moment** — the shape of the distribution inside the window,
with scale stripped out. Then $E(k) = \bigl(a M_s(k)\bigr)\cdot 2^{sk}$ exactly, and taking logarithms gives
not a bound but an **identity**:

$$\boxed{\;\mathrm{slope}(k_1,k_2) \;=\; s \;+\; \frac{\log_2\bigl(M_s(k_2)/M_s(k_1)\bigr)}{\Delta k}\;}$$

This is the cleanest statement on the page. A measured exponent *is* the true exponent plus the logarithmic
drift of the shape, divided by the lever arm. Turn the dials and watch the consequences:

{{interactive_demo:2}}

Three things fall out immediately.

- **Compression is equivalent to shape decrease.** $\mathrm{slope} < s$ *if and only if* $M_s$ strictly
  decreases across the lever arm. A scale-invariant sampler returns $s$ exactly, with zero tolerance.
- **Inversion pins the drift.** A deficit $d$ forces $M_s(k_1)/M_s(k_2) = 2^{d\Delta k}$ exactly. At $s=1$,
  $\Delta k = 8$, the reported $0.84$ forces $M_1(16)/M_1(24) = 2^{1.28} \approx 2.428$.
- **A dyadic sampler cannot drift that far.** Its normalised means live in $[\tfrac12, 1]$, so the ratio is
  at most $2 < 2^{1.28}$. **The measurement refutes the dyadic window itself.**

And the mechanism is nonetheless *sufficient*: the explicit drifting sampler $u_k \equiv 2^{-0.16k}$
reproduces slope $0.84$ exactly, with exactly the predicted ratio. So shape drift is both necessary and
realizable — which converts a narrative ("balanced draws compress the exponent") into a falsifiable number
somebody can go and compute this afternoon.

{{algorithm:2}}

---

## 6. Fermat is a thermometer, not a clock

That leaves the third channel, whose $0.50$ looks suspiciously like a birthday exponent and is nothing of
the kind. Fermat's method starts at $\lceil\sqrt N\rceil$ and halts at $(p+q)/2$, so its step count is the
**offset** $(p+q)/2 - \sqrt{pq}$, which a one-line identity shows equals $(\sqrt q - \sqrt p)^2/2$.

> **Gap-Locality Law.** For $0 < p \le q$: $\;\dfrac{(q-p)^2}{8q} \le \dfrac{p+q}{2} - \sqrt{pq} \le \dfrac{(q-p)^2}{8p}$.

<details>
<summary><b>Click for the proof — it is three substitutions</b></summary>

Write $s = \sqrt p$, $u = \sqrt q$. Then $q - p = (u-s)(u+s)$ and the offset is $(u-s)^2/2$. Since
$0 < s \le u$ we have $4s^2 \le (u+s)^2 \le 4u^2$, so

$$\frac{(q-p)^2}{8q} = \frac{(u-s)^2(u+s)^2}{8u^2}\;\le\;\frac{(u-s)^2 \cdot 4u^2}{8u^2} = \frac{(u-s)^2}{2}
\;\le\;\frac{(u-s)^2(u+s)^2}{8s^2} = \frac{(q-p)^2}{8p}. \qquad\blacksquare$$
</details>

So Fermat's cost is $\Theta(\mathrm{gap}^2/p)$ — a purely *local* function of the prime gap. Its exponent is
not a property of the algorithm; it is a readout of the gap distribution you fed it. Hence the **exponent
transfer law**: if the mean gap scales like $p^{\beta}$, then

$$\alpha_{\mathrm{Fermat}} = 2\beta_{\mathrm{gap}} - 1 .$$

Inverting the reported $0.50$ gives $\beta_{\mathrm{gap}} = 0.75$. A population whose gaps grew
proportionally to $p$ would have $\beta = 1$ and would have shown a Fermat slope of $1$. So the Fermat
channel is a **gap-exponent meter**, and it reports that the balanced sampler produces gaps growing like
$p^{3/4}$ — which is the *same* non-scale-invariance that Section 5 detected through completely different
mathematics.

{{visualization:2}}

---

## 7. And the birthday exponent is a theorem

Meanwhile the rho slope $0.52$ sits comfortably inside its certified band $1/2 \pm 1/16$, and — better — it
is *attained* by an explicit admissible curve obeying the dyadic birthday window at every level. So the
measurement is **non-refuting**, and we can say exactly why: the window slack is spent almost entirely on
the two endpoints.

<details>
<summary><b>Anchoring the exponent 1/2 in a proved threshold rather than a heuristic</b></summary>

Ask the guaranteed-collision question: how many stored residues force a repeated two-element sum modulo
$p$? The answer is exact. One needs $m$ elements with $p < m^2$, and

$$p < m^2 \iff \lfloor\sqrt p\rfloor + 1 \le m ,$$

so the minimal storage is precisely $\lfloor\sqrt p\rfloor + 1$, and at that threshold a collision provably
exists. Since $\sqrt p \le \lfloor\sqrt p\rfloor + 1 \le 2\sqrt p$ for $p \ge 1$, the threshold is a
$\tfrac12$-power law of spread at most $2$, and the Identifiability Theorem identifies its exponent. The
birthday $1/2$ is not folklore here — it is the exponent of a proved threshold. Further background:
[the birthday problem](https://en.wikipedia.org/wiki/Birthday_problem),
[Pollard's rho algorithm](https://en.wikipedia.org/wiki/Pollard%27s_rho_algorithm).
</details>

---

## 8. Run it yourself

Everything above, end to end, as one self-contained numerical script: exact recovery of a pure power law,
the identifiability band with its sharpness and converse, the pointwise band, cross-channel rigidity with
both constants, the power-mean family, gap locality on genuine random semiprimes, the birthday threshold
checked exhaustively, the truncation no-go, and the shape-drift identity verified to machine precision.

{{demo:0}}

---

## 9. What to take away

An exponent measurement across levels is a legitimate inference, and its entire error budget is one number:
multiplicative model ignorance divided by the lever arm. Once you write that number down, the three
reported slopes stop being a table of approximate confirmations and become three distinct objects:

- **Pollard rho, $0.52$** — a genuine replication of an exponent that is itself a theorem about a collision
  threshold.
- **Fermat, $0.50$** — not about Fermat at all; through an exact gap-locality law, a thermometer reading the
  gap exponent of the population, and it reads $3/4$.
- **Trial division, $0.84$** — a refutation. Robust to every free constant, immune to the obvious rescue via
  cost truncation, inconsistent with the rho slope measured on the very same draws by a factor exceeding
  thirty-six, and resolvable by an exact identity into a single directly measurable claim: the sampler's
  normalised factor distribution drifts by a factor $2^{1.28}$ across eight bits.

The broader lesson is a design principle. **Co-measurement is rigidity.** Running several cost channels on
one population yields constraints in which every implementation constant cancels, and those constraints are
strong enough to declare a reported pair of exponents impossible. It costs nothing, and it buys a great
deal.

A number that refuses to be $1$ is more informative than a number that agrees. You just have to build the
inequality that lets it speak.

Further reading:
[power mean inequality](https://en.wikipedia.org/wiki/Generalized_mean),
[Kantorovich inequality](https://en.wikipedia.org/wiki/Kantorovich_inequality),
[Fermat's factorization method](https://en.wikipedia.org/wiki/Fermat%27s_factorization_method),
[prime gaps](https://en.wikipedia.org/wiki/Prime_gap).
"""


def main() -> None:
    package: Dict[str, object] = {
        "title": "Three Clocks, One Race: A Certified Calculus for Across-Level Scaling Exponents",
        "domain": "Probability",
        "description": (
            "A rigorous inferential calculus for two-point log-log scaling exponents, built on the "
            "identifiability inequality |slope - alpha| <= log2(c2/c1)/lever arm and applied to three "
            "factoring cost channels co-measured on one population of balanced semiprimes. It certifies "
            "the Pollard-rho birthday exponent, reinterprets the Fermat channel as an exact gap-exponent "
            "meter, and refutes the reported trial-division slope 0.84 in four independent ways, "
            "resolving it by an exact identity into a directly measurable drift of the sampler's "
            "normalized factor distribution."
        ),
        "authors": ["Aristotle"],
        "date": "2026-08-23",
        "key_results": [
            "Identifiability inequality for two-point scaling exponents: a mean cost trapped between "
            "c1*2^(alpha k) and c2*2^(alpha k) has two-point log-log slope within log2(c2/c1)/(lever arm) "
            "of alpha; the bound is attained, and two exponents separated by twice that tolerance are "
            "indistinguishable to any two-level estimator.",
            "Pointwise slope band on a dyadic window: a per-instance cost a*p^s pins the measured slope to "
            "s +/- s/(lever arm) with no hypothesis on the implementation constant, so the reported "
            "trial-division slope 0.84 refutes a pointwise linear cost, which would force a slope of at "
            "least 0.875.",
            "Constant-free cross-channel rigidity law: for costs a*p^s and c*p^t measured on one dyadic "
            "population, |t*slope_s - s*slope_t| <= s*t/(lever arm); on the doubling ray s = 2t the sharp "
            "constant is log2 K(t) with K(t) = (1+2^t)^2/(4*2^t), giving log2((4+3*sqrt(2))/8) < 0.044 at "
            "(s,t) = (1,1/2), under which the reported pair (0.84, 0.52) is impossible by a factor "
            "exceeding 36.",
            "Exact gap-locality law for Fermat's method, (q-p)^2/(8q) <= (p+q)/2 - sqrt(pq) <= (q-p)^2/(8p), "
            "and the resulting exponent transfer law alpha_Fermat = 2*beta_gap - 1, whose inversion turns "
            "the reported Fermat slope 0.50 into the gap-exponent prediction 3/4.",
            "Shape-drift identity: slope = s + log2(M_s(k2)/M_s(k1))/(lever arm) for the normalized moment "
            "M_s(k), making exponent compression equivalent to a decrease of that moment, forcing the ratio "
            "M_1(16)/M_1(24) = 2^1.28 from the reported 0.84, and refuting the dyadic window (whose ratio "
            "can never exceed 2); cost truncation min(p, B*2^k) is proved unable to produce a deficit past "
            "1/8 for any truncation level.",
        ],
        "keywords": [
            "scaling exponent",
            "power band",
            "identifiability",
            "Kantorovich inequality",
            "power mean",
            "birthday bound",
            "Pollard rho",
            "integer factorization",
        ],
        "article": read("ARTICLE.md"),
        "research_paper": read("RESEARCH_PAPER.md"),
        "research_paper_tex": read("RESEARCH_PAPER.tex"),
        "demo": read("demo.py"),
        "demos": [
            {
                "name": "End-to-End Numerical Audit of Three Co-Measured Factoring Cost Channels",
                "description": (
                    "A single self-contained script that exercises every result in the development on "
                    "simulated and genuine data. It verifies that the two-point log-log slope recovers a "
                    "pure power law exactly regardless of the multiplicative constant; exhibits the "
                    "identifiability band together with the endpoint-saturating curve that attains it and "
                    "the pair of exponents that a two-level estimator cannot separate; measures the "
                    "pointwise slope band s +/- s/(lever arm) on simulated dyadic populations of 1500 "
                    "draws per level; computes the cross-channel discrepancy for trial division against "
                    "Pollard rho with deliberately absurd implementation constants, confirming that both "
                    "cancel and that the sharp Kantorovich allowance is respected while the reported pair "
                    "(0.84, 0.52) violates it by a factor above 37; tabulates the sharp doubling-ray "
                    "constants against the generic power-mean constants; checks the two-sided Fermat "
                    "gap-locality envelope on 200 genuine random balanced semiprimes with a Miller-Rabin "
                    "prime generator and confirms the exponent transfer law on synthetic gap populations; "
                    "verifies the birthday storage threshold exhaustively; sweeps the truncation level to "
                    "show the deficit never reaches 1/8; and finally verifies the shape-drift identity to "
                    "machine precision on both a scale-invariant and a drifting sampler, extracting the "
                    "forced shape ratio 2^1.28."
                ),
                "code": read("demo.py"),
            }
        ],
        "algorithms": [
            {
                "name": "Two-Point Exponent Estimation with a Certified Identifiability Band",
                "description": (
                    "The basic inference step for a single cost channel. Given the mean costs at two "
                    "levels, an asserted exponent, and the logarithmic spread the model permits, it "
                    "returns the measured log-log slope, the certified interval alpha +/- sigma/(lever "
                    "arm) guaranteed to contain the slope of any curve obeying that power band, the "
                    "verdict, the two-point resolution 2*sigma/(lever arm) below which exponents are "
                    "provably indistinguishable, and -- when the model is refuted -- the multiplicative "
                    "constant drift 2^(deficit * lever arm) that any rescue of the model would have to "
                    "exhibit. The mathematical content is the identifiability inequality, used forwards "
                    "as a guarantee and backwards as a refutation engine; the band is exactly attained by "
                    "an endpoint-saturating curve, so no sharper verdict is possible from two levels. "
                    "Complexity is O(1) arithmetic operations once the two means are available; the "
                    "expensive part of the pipeline is producing the means, which is O(n) per level."
                ),
                "pseudocode": (
                    "INPUT   E_lo, E_hi > 0        mean costs at levels k_lo < k_hi\n"
                    "        alpha                 exponent asserted by the model\n"
                    "        sigma >= 0            logarithmic spread log2(c2/c1) the model permits\n"
                    "OUTPUT  slope, band, verdict, resolution, required_spread\n"
                    "\n"
                    "1.  dk        <- k_hi - k_lo                      // the lever arm; require dk > 0\n"
                    "2.  slope     <- (log2(E_hi) - log2(E_lo)) / dk   // two-point log-log slope\n"
                    "3.  tol       <- sigma / dk                       // identifiability tolerance\n"
                    "4.  band      <- [alpha - tol, alpha + tol]       // certified, and attained\n"
                    "5.  deficit   <- |slope - alpha|\n"
                    "6.  IF deficit > tol THEN\n"
                    "7.        verdict <- 'REFUTED'\n"
                    "8.        required_spread <- 2^(deficit * dk)     // contrapositive: any power band\n"
                    "9.                                                // matching this slope needs at\n"
                    "10.                                               // least this constant drift\n"
                    "11. ELSE\n"
                    "12.       verdict <- 'NON-REFUTING'\n"
                    "13.       required_spread <- 1\n"
                    "14. resolution <- 2 * sigma / dk                  // exponents closer than this are\n"
                    "15.                                               // provably indistinguishable\n"
                    "16. RETURN (slope, band, verdict, resolution, required_spread)"
                ),
                "code": asset("alg_identifiability.py"),
            },
            {
                "name": "Constant-Free Cross-Channel Consistency Audit via Power-Mean Rigidity",
                "description": (
                    "An audit that constrains a *pair* of exponent measurements taken on one population "
                    "without knowing either channel's implementation constant. If channel A has pointwise "
                    "cost a*p^s and channel B has pointwise cost c*p^t with 0 < t <= s, then power-mean "
                    "monotonicity (Jensen's inequality for x -> x^(s/t)) bounds one mean by a power of "
                    "the other, the dyadic window bounds it in the reverse direction, and differencing "
                    "the logarithms across the lever arm annihilates both constants, leaving "
                    "|t*slope_A - s*slope_B| <= s*t/(lever arm). On the doubling ray s = 2t the "
                    "substitution y = p^t turns the reverse inequality into the exact Kantorovich "
                    "configuration and yields the sharp constant log2 K(t) with K(t) = (1+2^t)^2/(4*2^t); "
                    "at (s, t) = (1, 1/2) this is log2((4+3*sqrt(2))/8) ~ 0.0431, roughly twenty-three "
                    "times smaller than the crude value 1. Off the ray no sharp constant is currently "
                    "known and the audit falls back on the generic bound. Complexity is O(1); the audit "
                    "consumes no calibration data whatsoever."
                ),
                "pseudocode": (
                    "INPUT   slope_A, slope_B      slopes co-measured on ONE population\n"
                    "        s >= t > 0            pointwise cost exponents of channels A and B\n"
                    "        dk > 0                lever arm\n"
                    "OUTPUT  discrepancy, allowances, violation factor, verdict\n"
                    "\n"
                    "1.  ASSERT 0 < t <= s  and  dk > 0\n"
                    "2.  discrepancy <- |t * slope_A - s * slope_B|\n"
                    "3.  generic     <- s * t / dk                     // power-mean rigidity\n"
                    "4.  IF s = 2t THEN                                // the doubling ray\n"
                    "5.        K     <- (1 + 2^t)^2 / (4 * 2^t)        // sharp Kantorovich constant\n"
                    "6.        sharp <- t * log2(K) / dk               // same normalisation as generic\n"
                    "7.  ELSE\n"
                    "8.        sharp <- NONE                           // no sharp constant known\n"
                    "9.  binding <- (sharp if sharp != NONE else generic)\n"
                    "10. IF discrepancy > binding THEN\n"
                    "11.       verdict <- 'IMPOSSIBLE'                 // no population can do this\n"
                    "12. ELSE\n"
                    "13.       verdict <- 'CONSISTENT'\n"
                    "14. RETURN (discrepancy, generic, sharp, binding,\n"
                    "            discrepancy / binding, verdict)"
                ),
                "code": asset("alg_cross_channel.py"),
            },
            {
                "name": "Shape-Drift Decomposition of a Measured Scaling Exponent",
                "description": (
                    "A diagnosis that localises an exponent anomaly exactly. Writing each level in "
                    "normalised form p_k(i) = 2^k * u_k(i) and defining the shape moment "
                    "M_s(k) = mean(u_k^s), the expected pointwise power cost factorises as "
                    "E(k) = (a * M_s(k)) * 2^(sk), so taking logarithms and differencing yields the "
                    "identity slope = s + log2(M_s(k2)/M_s(k1))/(lever arm). Because this is an identity "
                    "rather than a bound, the routine is simultaneously a decomposition and a pipeline "
                    "audit: the reconstructed slope must equal the directly measured slope to machine "
                    "precision, and any residual is a bug. Its consequences are immediate -- compression "
                    "holds if and only if the normalised moment decreases, so a scale-invariant sampler "
                    "returns the exponent with zero tolerance; and inverting a measured deficit d pins the "
                    "drift exactly at 2^(d * lever arm), a number that can be checked directly against the "
                    "raw draws. Since a dyadic sampler keeps every normalised mean in [1/2, 1], a forced "
                    "ratio above 2 refutes the window itself. Complexity is O(n) per level."
                ),
                "pseudocode": (
                    "INPUT   pop_lo, pop_hi        raw level populations at k_lo < k_hi\n"
                    "        s                     modelled pointwise cost exponent\n"
                    "OUTPUT  shape moments, drift term, measured and reconstructed slopes\n"
                    "\n"
                    "1.  dk    <- k_hi - k_lo\n"
                    "2.  M_lo  <- mean over i of ( pop_lo[i] / 2^k_lo )^s     // shape moment at k_lo\n"
                    "3.  M_hi  <- mean over i of ( pop_hi[i] / 2^k_hi )^s     // shape moment at k_hi\n"
                    "4.  E_lo  <- mean over i of pop_lo[i]^s\n"
                    "5.  E_hi  <- mean over i of pop_hi[i]^s\n"
                    "6.  measured      <- (log2(E_hi) - log2(E_lo)) / dk\n"
                    "7.  drift         <- log2(M_hi / M_lo) / dk\n"
                    "8.  reconstructed <- s + drift                            // an IDENTITY, not a bound\n"
                    "9.  ASSERT |measured - reconstructed| ~ 0                 // else the pipeline is buggy\n"
                    "10. // inversion, when only the slope is available:\n"
                    "11. deficit <- s - measured\n"
                    "12. forced_ratio <- 2^(deficit * dk)                      // = M_lo / M_hi, exactly\n"
                    "13. IF forced_ratio > 2 THEN\n"
                    "14.       REPORT 'dyadic window refuted'                  // means live in [1/2, 1]\n"
                    "15. RETURN (M_lo, M_hi, drift, measured, reconstructed, forced_ratio)"
                ),
                "code": asset("alg_shape_drift.py"),
            },
        ],
        "visualizations": [
            {
                "name": "The Identifiability Corridor and the Decay of Slope Tolerance",
                "description": (
                    "A two-panel figure. The left panel plots the logarithm of the mean cost against bit "
                    "size, with the power band drawn as a shaded corridor of height sigma around the line "
                    "alpha*k, and the two extreme admissible chords across the lever arm superimposed: "
                    "their slopes are exactly alpha +/- sigma/(lever arm), which is the entire error "
                    "budget of a two-point exponent measurement. The reported trial-division chord of "
                    "slope 0.84 is drawn as well, visibly exiting the corridor. The right panel plots the "
                    "tolerance sigma/(lever arm) as a function of the lever arm for the trial-division "
                    "and Pollard-rho models, and marks each reported deviation against its own curve at "
                    "the experimental lever arm of 8: the rho point falls below its curve and is "
                    "admissible, while the trial-division point falls above and is refuted."
                ),
                "code": asset("viz_corridor.py"),
            },
            {
                "name": "The Admissible Region of Co-Measured Slopes and the Sharp Doubling-Ray Constant",
                "description": (
                    "A two-panel figure about cross-channel rigidity. The left panel works in the plane "
                    "whose coordinates are the two slopes measured on one population, and draws both "
                    "admissible strips around the exact ridge slope_trial = 2*slope_rho: the wide "
                    "Cauchy-Schwarz strip of half-width 1/(lever arm), and the far narrower Kantorovich "
                    "strip of half-width log2((4+3*sqrt(2))/8)/(lever arm). The saturating witness (1/2, 1) "
                    "sits on the ridge, while the reported pair (0.52, 0.84) lies far outside both, "
                    "annotated with its violation factor of 37. The right panel compares, on a logarithmic "
                    "axis, the sharp doubling-ray constant log2 K(t) with K(t) = (1+2^t)^2/(4*2^t) against "
                    "the generic power-mean constant 2t^2 and against the small-t asymptote t^2*ln(2)/4, "
                    "displaying the roughly 11.5-fold gap that persists across the whole ray."
                ),
                "code": asset("viz_admissible_region.py"),
            },
            {
                "name": "Fermat Gap Locality and the Exponent Transfer Law",
                "description": (
                    "A two-panel figure showing that Fermat's method measures the population rather than "
                    "the algorithm. The left panel plots, for several hundred random balanced-ish "
                    "semiprime pairs, the exact Fermat offset against the two-sided envelope "
                    "(q-p)^2/(8q) <= offset <= (q-p)^2/(8p) on log-log axes; every point lies inside the "
                    "envelope, which is the gap-locality law, and the envelope collapses onto the offset "
                    "as the pair becomes balanced. The right panel draws the exponent transfer law "
                    "alpha_Fermat = 2*beta_gap - 1 as a straight line, marks the reported Fermat slope "
                    "0.50 and its inversion to a gap exponent of 0.75, and contrasts this with the "
                    "beta = 1 that a naively scale-invariant balanced sampler would exhibit, which would "
                    "have produced a Fermat slope of 1."
                ),
                "code": asset("viz_fermat_gap.py"),
            },
        ],
        "interactive_demos": [
            {
                "title": "The Lever-Arm Laboratory: How Much Can a Drifting Constant Lie to You?",
                "description": (
                    "An interactive rendering of the identifiability theorem. Sliders control the "
                    "modelled exponent, the logarithmic spread of the power band, the two measurement "
                    "levels, and where inside the corridor each endpoint sits; the canvas draws the "
                    "corridor, the two extreme admissible chords, the reported trial-division chord of "
                    "slope 0.84, and the chord you have built, colour-coded by verdict. The readout gives "
                    "the measured slope, the certified band, the tolerance sigma/(lever arm), and the "
                    "two-point resolution 2*sigma/(lever arm). Sliding one endpoint to the bottom of the "
                    "corridor and the other to the top attains the band exactly, demonstrating that the "
                    "inequality cannot be improved; shortening the lever arm shows the tolerance blowing "
                    "up like 1/(lever arm), which is precisely why fits within a single bit size carry no "
                    "information about the exponent."
                ),
                "html": asset("widget_lever_arm.html"),
            },
            {
                "title": "The Cross-Channel Consistency Auditor: Where Both Constants Cancel",
                "description": (
                    "An explorer for the rigidity law that links two cost channels co-measured on one "
                    "population. Sliders set the two pointwise cost exponents s and t, the two measured "
                    "slopes, and the lever arm; the canvas draws the plane of co-measured slopes with the "
                    "exact rigidity ridge t*slope_A = s*slope_B, the wide generic power-mean strip of "
                    "half-width s*t/(lever arm), and -- whenever the exponents lie on the doubling ray "
                    "s = 2t -- the dramatically narrower sharp Kantorovich strip. Presets place the "
                    "saturating witness (1, 1/2) on the ridge and the reported pair (0.84, 0.52) far "
                    "outside it, with the readout reporting the violation factor of 37. The point of the "
                    "widget is that no calibration information is ever entered: both implementation "
                    "constants have cancelled from the constraint."
                ),
                "html": asset("widget_cross_channel.html"),
            },
            {
                "title": "The Shape-Drift Meter: Turning an Anomaly into a Measurable Prediction",
                "description": (
                    "An interactive inversion of the shape-drift identity slope = s + "
                    "log2(M_s(k2)/M_s(k1))/(lever arm). Sliders set the modelled exponent, the measured "
                    "slope, and the lever arm; the meter returns the deficit, the shape ratio the "
                    "measurement forces exactly, and whether that ratio is achievable by a sampler "
                    "confined to a dyadic window, whose normalised means are trapped in [1/2, 1]. The "
                    "canvas draws the forced drift of the normalised moment across the lever arm against "
                    "that admissible band. Setting the modelled exponent to 1 and the measured slope to "
                    "the reported 0.84 at a lever arm of 8 produces the forced ratio 2^1.28 = 2.428, "
                    "outside the band -- which is how the anomaly becomes a falsifiable statement about "
                    "the draws rather than a narrative about finite-size effects."
                ),
                "html": asset("widget_shape_drift.html"),
            },
        ],
        "interactive_layout": INTERACTIVE_LAYOUT,
        "lean_proofs": lean_bundle(),
        "future_directions": FUTURE_DIRECTIONS,
        "modules": {"demo": read("demo.py")},
        "lean_files": LEAN_FILES,
    }

    out = os.path.join(ROOT, "PACKAGE.json")
    with open(out, "w", encoding="utf-8") as fh:
        json.dump(package, fh, indent=2, ensure_ascii=False)
    print(f"wrote {out}  ({os.path.getsize(out)} bytes)")


if __name__ == "__main__":
    main()


"""Visualization: the admissible region in the plane of co-measured slopes.

Two channels run on ONE population are not two independent measurements.  With
pointwise costs a*p and c*sqrt(p) the pair (slope_trial, slope_rho) is forced
into the strip |slope_trial - 2*slope_rho| <= 1/dk, and, once the crude window
reversal is replaced by the Kantorovich inequality, into the far narrower strip
|slope_trial - 2*slope_rho| <= log2((4+3*sqrt(2))/8)/dk.

Left panel  -- the two strips in the (slope_rho, slope_trial) plane, together
with the saturating witness (1/2, 1) and the reported pair (0.52, 0.84), which
lies outside both.

Right panel -- the sharp doubling-ray constant log2 K(t), K(t)=(1+2^t)^2/(4*2^t),
against the generic power-mean constant 2t^2, showing the roughly 11.5-fold gap
and the common quadratic decay as t -> 0.

Run:  python3 viz_admissible_region.py     (writes admissible_region.png)
"""

from __future__ import annotations

import math
from typing import List

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402


DK: float = 8.0
KANT: float = (4.0 + 3.0 * math.sqrt(2.0)) / 8.0


def doubling_constant(t: float) -> float:
    two_t = 2.0 ** t
    return (1.0 + two_t) ** 2 / (4.0 * two_t)


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13.5, 5.4))

    # ---------------- left: admissible strips ----------------
    xs: List[float] = [0.30 + 0.005 * i for i in range(81)]
    crude = 1.0 / DK
    sharp = math.log2(KANT) / DK

    ax1.fill_between(xs, [2 * x - crude for x in xs], [2 * x + crude for x in xs],
                     color="#aed6f1", alpha=0.55,
                     label=rf"Cauchy--Schwarz strip, half-width $1/\Delta k={crude:.4f}$")
    ax1.fill_between(xs, [2 * x - sharp for x in xs], [2 * x + sharp for x in xs],
                     color="#1f618d", alpha=0.75,
                     label=rf"Kantorovich strip, half-width ${sharp:.5f}$")
    ax1.plot(xs, [2 * x for x in xs], color="#154360", lw=1.3, ls="--",
             label=r"exact rigidity $\mathrm{slope}_{\rm trial}=2\,\mathrm{slope}_\rho$")

    ax1.scatter([0.5], [1.0], s=110, marker="*", color="#1e8449", zorder=6,
                label="saturating witness $(1/2,\\,1)$")
    ax1.scatter([0.52], [0.84], s=90, marker="X", color="#c0392b", zorder=6,
                label="reported pair $(0.52,\\,0.84)$")
    ax1.annotate("discrepancy 0.20\n= 37x the sharp allowance",
                 xy=(0.52, 0.84), xytext=(0.545, 0.70), fontsize=9, color="#c0392b",
                 arrowprops=dict(arrowstyle="->", color="#c0392b"))

    ax1.set_xlim(0.42, 0.62)
    ax1.set_ylim(0.60, 1.30)
    ax1.set_xlabel(r"$\mathrm{slope}_\rho$   (channel cost $c\,\sqrt{p}$)")
    ax1.set_ylabel(r"$\mathrm{slope}_{\rm trial}$   (channel cost $a\,p$)")
    ax1.set_title(r"Admissible pairs on one population, $\Delta k=8$")
    ax1.legend(fontsize=8.3, loc="upper left")
    ax1.grid(alpha=0.25)

    # ---------------- right: sharp vs generic constant ----------------
    ts = [0.02 + 0.01 * i for i in range(120)]
    ax2.plot(ts, [2 * t * t for t in ts], color="#c0392b", lw=2.0,
             label=r"generic power-mean constant $2t^2$")
    ax2.plot(ts, [math.log2(doubling_constant(t)) for t in ts], color="#1f618d", lw=2.0,
             label=r"sharp doubling-ray constant $\log_2 K(t)$")
    ax2.plot(ts, [math.log(2.0) / 4.0 * t * t for t in ts], color="#7d3c98", lw=1.2, ls=":",
             label=r"small-$t$ asymptote $\;t^2\ln 2/4$")
    ax2.scatter([0.5], [math.log2(KANT)], s=80, color="#1f618d", zorder=6)
    ax2.annotate(rf"$t=1/2$: $\log_2\frac{{4+3\sqrt{{2}}}}{{8}}={math.log2(KANT):.5f}$",
                 xy=(0.5, math.log2(KANT)), xytext=(0.30, 0.30), fontsize=9,
                 arrowprops=dict(arrowstyle="->", color="#1f618d"))

    ax2.set_yscale("log")
    ax2.set_xlabel(r"$t$   (channel exponents $s=2t$ and $t$)")
    ax2.set_ylabel("allowed discrepancy per unit lever arm")
    ax2.set_title(r"Sharp vs generic constant along the doubling ray $s=2t$")
    ax2.legend(fontsize=8.5, loc="lower right")
    ax2.grid(alpha=0.25, which="both")

    fig.suptitle("Co-measurement is rigidity: both implementation constants cancel",
                 fontsize=13)
    fig.tight_layout(rect=(0, 0, 1, 0.95))
    fig.savefig("admissible_region.png", dpi=160)
    print("wrote admissible_region.png")
    print(f"crude half-width  1/dk               = {crude:.6f}")
    print(f"sharp half-width  log2 K(1/2)/dk     = {sharp:.6f}")
    print(f"reported discrepancy |0.84 - 2*0.52| = {abs(0.84 - 1.04):.6f}"
          f"  -> factor {abs(0.84-1.04)/sharp:.2f} over the sharp bound")


if __name__ == "__main__":
    main()


"""Visualization: the identifiability corridor and the decay of slope tolerance.

Left panel  -- log2 of the mean cost against bit size k, with the power-band
corridor of logarithmic spread sigma drawn as a shaded strip around the line
alpha*k.  The two extreme admissible chords across the lever arm are drawn:
their slopes are exactly alpha +/- sigma/dk, so the strip's height divided by
the run is the entire error budget of a two-point exponent measurement.

Right panel -- the tolerance sigma/dk as a function of the lever arm, with the
reported factoring slopes marked against the exponents they are meant to test.
The trial-division point falls outside its corridor at dk = 8; the Pollard-rho
point falls inside its own.

Run:  python3 viz_corridor.py     (writes corridor.png)
"""

from __future__ import annotations

import math
from typing import List, Tuple

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402


ALPHA: float = 1.0        # modelled exponent for trial division
SIGMA: float = 1.0        # logarithmic spread forced by a dyadic window at s = 1
K_LO, K_HI = 16, 24
MEASURED_TRIAL, MEASURED_RHO, MEASURED_FERMAT = 0.84, 0.52, 0.50


def corridor(ks: List[int], alpha: float, sigma: float) -> Tuple[List[float], List[float]]:
    """Lower and upper edges of log2 E(k) for a band of logarithmic spread sigma."""
    lower = [alpha * k - sigma for k in ks]
    upper = [alpha * k for k in ks]
    return lower, upper


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13.5, 5.4))

    # ---------------- left: the corridor ----------------
    ks = list(range(12, 29))
    lo, hi = corridor(ks, ALPHA, SIGMA)
    ax1.fill_between(ks, lo, hi, color="#8fb8de", alpha=0.45,
                     label=f"power band, spread $2^{{{SIGMA:g}}}$")
    ax1.plot(ks, [ALPHA * k for k in ks], color="#22456b", lw=1.2, ls="--",
             label=r"$\alpha k$  ($\alpha=1$)")

    # extreme admissible chords across the lever arm
    steep = [(K_LO, ALPHA * K_LO - SIGMA), (K_HI, ALPHA * K_HI)]
    flat = [(K_LO, ALPHA * K_LO), (K_HI, ALPHA * K_HI - SIGMA)]
    for pts, col, lab in (
        (steep, "#c0392b", rf"steepest chord: slope $\alpha+\sigma/\Delta k={ALPHA+SIGMA/8:.3f}$"),
        (flat, "#1e8449", rf"flattest chord: slope $\alpha-\sigma/\Delta k={ALPHA-SIGMA/8:.3f}$"),
    ):
        ax1.plot([p[0] for p in pts], [p[1] for p in pts], color=col, lw=2.2, label=lab)
        ax1.scatter([p[0] for p in pts], [p[1] for p in pts], color=col, zorder=5, s=28)

    # the reported trial-division slope, anchored at the corridor top at k = 16
    y0 = ALPHA * K_LO
    ax1.plot([K_LO, K_HI], [y0, y0 + MEASURED_TRIAL * 8], color="#7d3c98", lw=2.4, ls=":",
             label=f"reported trial slope {MEASURED_TRIAL} (exits the corridor)")

    ax1.axvspan(K_LO, K_HI, color="#f4f6f7", zorder=0)
    ax1.set_xlabel("bit size $k$ of the smaller prime factor")
    ax1.set_ylabel(r"$\log_2 \mathbb{E}[T](k)$")
    ax1.set_title("The identifiability corridor at lever arm $\\Delta k = 8$")
    ax1.legend(fontsize=8.5, loc="upper left")
    ax1.grid(alpha=0.25)

    # ---------------- right: tolerance decay ----------------
    dks = [d / 10.0 for d in range(5, 241)]
    for sigma, col, lab in ((1.0, "#c0392b", r"trial division, $\sigma=1$"),
                            (0.5, "#2471a3", r"Pollard $\rho$, $\sigma=1/2$")):
        ax2.plot(dks, [sigma / d for d in dks], color=col, lw=2.0, label=lab)

    ax2.axvline(8, color="#555555", ls="--", lw=1.1)
    ax2.annotate(r"experimental lever arm $\Delta k = 8$", xy=(8, 0.30),
                 xytext=(10.2, 0.42), fontsize=9,
                 arrowprops=dict(arrowstyle="->", color="#555555"))

    ax2.scatter([8], [abs(MEASURED_TRIAL - 1.0)], color="#c0392b", s=70, zorder=6,
                marker="X", label=f"|{MEASURED_TRIAL}$-1$| $=0.16$ : ABOVE its curve (refuted)")
    ax2.scatter([8], [abs(MEASURED_RHO - 0.5)], color="#2471a3", s=70, zorder=6,
                marker="o", label=f"|{MEASURED_RHO}$-1/2$| $=0.02$ : below its curve (admissible)")

    ax2.set_xlim(0.5, 24)
    ax2.set_ylim(0, 0.9)
    ax2.set_xlabel(r"lever arm $\Delta k$")
    ax2.set_ylabel(r"slope tolerance $\sigma/\Delta k$")
    ax2.set_title("Multiplicative model error, divided by the lever arm")
    ax2.legend(fontsize=8.5, loc="upper right")
    ax2.grid(alpha=0.25)

    fig.suptitle("Two-point exponent measurement: what a drifting constant can and cannot do",
                 fontsize=13)
    fig.tight_layout(rect=(0, 0, 1, 0.95))
    fig.savefig("corridor.png", dpi=160)
    print("wrote corridor.png")
    print(f"tolerance at dk=8, sigma=1 : {1.0/8:.4f}  (trial deficit "
          f"{abs(MEASURED_TRIAL-1.0):.4f} -> refuted)")
    print(f"tolerance at dk=8, sigma=.5: {0.5/8:.4f}  (rho deficit "
          f"{abs(MEASURED_RHO-0.5):.4f} -> admissible)")
    print(f"Fermat slope {MEASURED_FERMAT} inverts to gap exponent "
          f"{(MEASURED_FERMAT+1)/2:.3f}")


if __name__ == "__main__":
    main()


"""Visualization: Fermat's method is a gap meter, not an algorithmic clock.

Left panel  -- for random balanced semiprime pairs (p, q) the exact Fermat
offset (p+q)/2 - sqrt(pq) is plotted against the two-sided envelope
(q-p)^2/(8q) <= offset <= (q-p)^2/(8p).  Every point lies inside the envelope,
which is the content of the gap-locality law; the envelope collapses onto the
offset as the pair becomes balanced.

Right panel -- the exponent transfer law alpha_Fermat = 2*beta_gap - 1.  For a
population whose mean gap scales like 2^(beta k), the measured Fermat slope is
plotted against beta; the reported slope 0.50 is inverted to beta = 0.75, well
below the beta = 1 of a naively scale-invariant balanced sampler.

Run:  python3 viz_fermat_gap.py     (writes fermat_gap.png)
"""

from __future__ import annotations

import math
import random
from typing import List, Tuple

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402


SEED: int = 20260920
MEASURED_FERMAT: float = 0.50


def sample_pairs(n: int, rng: random.Random) -> List[Tuple[float, float]]:
    """Balanced-ish pairs with p in a dyadic window and a gap of tunable size."""
    out: List[Tuple[float, float]] = []
    for _ in range(n):
        k = rng.choice([16, 20, 24])
        p = rng.uniform(2.0 ** (k - 1), 2.0 ** k)
        beta = rng.uniform(0.5, 1.0)
        gap = (p ** beta) * rng.uniform(0.2, 2.0)
        out.append((p, p + gap))
    return out


def main() -> None:
    rng = random.Random(SEED)
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13.5, 5.4))

    pairs = sample_pairs(600, rng)
    offsets = [(p + q) / 2.0 - math.sqrt(p * q) for p, q in pairs]
    lower = [(q - p) ** 2 / (8.0 * q) for p, q in pairs]
    upper = [(q - p) ** 2 / (8.0 * p) for p, q in pairs]

    ax1.scatter(offsets, lower, s=7, alpha=0.5, color="#1e8449",
                label=r"lower bound $(q-p)^2/(8q)$")
    ax1.scatter(offsets, upper, s=7, alpha=0.5, color="#c0392b",
                label=r"upper bound $(q-p)^2/(8p)$")
    lim = [min(offsets) * 0.5, max(upper) * 2.0]
    ax1.plot(lim, lim, color="#154360", lw=1.4, ls="--", label="identity line")
    ax1.set_xscale("log")
    ax1.set_yscale("log")
    ax1.set_xlabel(r"exact Fermat offset  $\frac{p+q}{2}-\sqrt{pq}$")
    ax1.set_ylabel("envelope value")
    ax1.set_title("Gap locality: the offset is squeezed by $\\Theta(\\mathrm{gap}^2/p)$")
    ax1.legend(fontsize=9)
    ax1.grid(alpha=0.25, which="both")

    violations = sum(1 for o, l, u in zip(offsets, lower, upper) if not (l <= o <= u + 1e-9))
    ax1.annotate(f"{len(pairs)} draws, {violations} violations",
                 xy=(0.04, 0.92), xycoords="axes fraction", fontsize=9.5)

    betas = [0.4 + 0.005 * i for i in range(121)]
    ax2.plot(betas, [2 * b - 1 for b in betas], color="#1f618d", lw=2.2,
             label=r"$\alpha_{\rm Fermat} = 2\beta_{\rm gap} - 1$")
    ax2.axhline(MEASURED_FERMAT, color="#c0392b", ls="--", lw=1.3,
                label=f"reported Fermat slope {MEASURED_FERMAT}")
    ax2.axvline(0.75, color="#c0392b", ls=":", lw=1.3)
    ax2.scatter([0.75], [MEASURED_FERMAT], s=95, marker="X", color="#c0392b", zorder=6)
    ax2.annotate(r"inverts to $\beta_{\rm gap}=0.75$", xy=(0.75, 0.5), xytext=(0.79, 0.20),
                 fontsize=10, color="#c0392b",
                 arrowprops=dict(arrowstyle="->", color="#c0392b"))
    ax2.scatter([1.0], [1.0], s=80, marker="o", color="#1e8449", zorder=6)
    ax2.annotate(r"naive balanced sampler: $\beta=1 \Rightarrow$ slope $1$",
                 xy=(1.0, 1.0), xytext=(0.62, 1.02), fontsize=9, color="#1e8449")
    ax2.set_xlabel(r"gap exponent $\beta_{\rm gap}$  (mean gap $\sim p^{\beta}$)")
    ax2.set_ylabel(r"measured Fermat slope")
    ax2.set_title("The Fermat channel is a gap-exponent meter")
    ax2.legend(fontsize=9, loc="upper left")
    ax2.grid(alpha=0.25)

    fig.suptitle("Fermat's method measures the population, not the algorithm", fontsize=13)
    fig.tight_layout(rect=(0, 0, 1, 0.95))
    fig.savefig("fermat_gap.png", dpi=160)
    print("wrote fermat_gap.png")
    print(f"gap-locality violations among {len(pairs)} draws: {violations}")
    print(f"inversion of slope {MEASURED_FERMAT}: beta_gap = {(MEASURED_FERMAT + 1) / 2:.4f}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
demo.py -- Numerical demonstrations for the certified calculus of
across-level scaling exponents.

Self-contained: standard library only (math, random, statistics).

The demonstrations cover, in order:

  1. Exact recovery of a pure power law by the two-point log-log slope.
  2. The identifiability inequality  |slope - alpha| <= log2(c2/c1)/dk,
     together with its sharpness (the band is attained) and its converse
     (two exponents separated by 2*sigma/dk are indistinguishable).
  3. The pointwise slope band  s +/- s/dk  on a dyadic population, and the
     resulting refutation of a pointwise linear trial-division cost by the
     reported slope 0.84.
  4. Cross-channel rigidity  |slope_trial - 2*slope_rho| <= 1/dk, its
     Kantorovich sharpening to log2((4+3*sqrt(2))/8)/dk, the sharp
     doubling-ray family K(t) = (1+2^t)^2 / (4*2^t), and the impossibility
     of the reported pair (0.84, 0.52).
  5. General power-mean rigidity  |t*slope_s - s*slope_t| <= s*t/dk.
  6. Fermat gap locality  (q-p)^2/(8q) <= (p+q)/2 - sqrt(pq) <= (q-p)^2/(8p)
     and the exponent transfer law  alpha_Fermat = 2*beta_gap - 1.
  7. The birthday storage threshold  p < m^2  <=>  isqrt(p) + 1 <= m.
  8. The truncation no-go: min(p, B*2^k) never yields a deficit past 1/8.
  9. The shape-drift identity  slope = s + log2(M_s(k2)/M_s(k1))/dk, and the
     exact prediction M_1(16)/M_1(24) = 2^1.28 forced by the reported 0.84.
"""

from __future__ import annotations

import math
import random
from typing import Callable, Dict, List, Sequence, Tuple

SEED: int = 20260920
LO_LEVEL: int = 16
HI_LEVEL: int = 24
LEVER_ARM: float = float(HI_LEVEL - LO_LEVEL)

MEASURED_TRIAL: float = 0.84
MEASURED_RHO: float = 0.52
MEASURED_FERMAT: float = 0.50


# ----------------------------------------------------------------------
# Core definitions
# ----------------------------------------------------------------------

def log_slope(e1: float, e2: float, k1: int, k2: int) -> float:
    """Two-point log-log slope: (log2 E(k2) - log2 E(k1)) / (k2 - k1)."""
    if e1 <= 0.0 or e2 <= 0.0:
        raise ValueError("mean costs must be positive")
    return (math.log2(e2) - math.log2(e1)) / float(k2 - k1)


def mean(xs: Sequence[float]) -> float:
    """Unweighted empirical mean of a finite sample."""
    if not xs:
        raise ValueError("empty sample")
    return math.fsum(xs) / float(len(xs))


def identifiability_band(alpha: float, c1: float, c2: float, dk: float) -> Tuple[float, float]:
    """Certified interval for a two-point slope of a power band PB(alpha; c1, c2)."""
    if not (0.0 < c1 <= c2):
        raise ValueError("require 0 < c1 <= c2")
    tol = math.log2(c2 / c1) / dk
    return (alpha - tol, alpha + tol)


def kantorovich_constant() -> float:
    """(4 + 3*sqrt(2)) / 8, the sharp dyadic reverse-Cauchy-Schwarz constant."""
    return (4.0 + 3.0 * math.sqrt(2.0)) / 8.0


def doubling_constant(t: float) -> float:
    """K(t) = (1 + 2^t)^2 / (4 * 2^t), the sharp constant along s = 2t."""
    two_t = 2.0 ** t
    return (1.0 + two_t) ** 2 / (4.0 * two_t)


# ----------------------------------------------------------------------
# Populations
# ----------------------------------------------------------------------

def dyadic_population(k: int, n: int, rng: random.Random) -> List[float]:
    """n draws uniform on the dyadic window [2^(k-1), 2^k]."""
    lo, hi = 2.0 ** (k - 1), 2.0 ** k
    return [rng.uniform(lo, hi) for _ in range(n)]


def drifting_population(k: int, n: int, deficit: float) -> List[float]:
    """Scale-drifting sampler u_k == 2^(-deficit*k), i.e. p_k(i) = 2^((1-deficit)k)."""
    return [2.0 ** ((1.0 - deficit) * k)] * n


def shape_moment(pop: Sequence[float], k: int, s: float) -> float:
    """M_s(k) = mean((p / 2^k)^s), the normalized s-th moment ('the shape')."""
    scale = 2.0 ** k
    return mean([(p / scale) ** s for p in pop])


# ----------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------

def demo_1_pure_power() -> None:
    print("=" * 74)
    print("1. A pure power law E(k) = C * 2^(alpha k) is read off exactly")
    print("=" * 74)
    for C, alpha in [(1.0, 1.0), (137.0, 0.5), (1e-9, 0.84)]:
        e1 = C * 2.0 ** (alpha * LO_LEVEL)
        e2 = C * 2.0 ** (alpha * HI_LEVEL)
        s = log_slope(e1, e2, LO_LEVEL, HI_LEVEL)
        print(f"   C = {C:>10.3e}   alpha = {alpha:.2f}   measured slope = {s:.12f}")
    print("   -> the constant C cancels identically.\n")


def demo_2_identifiability() -> None:
    print("=" * 74)
    print("2. Identifiability, its sharpness, and its converse")
    print("=" * 74)
    alpha, sigma, C = 1.0, 1.0, 1.0
    c1, c2 = C * 2.0 ** (-sigma), C
    lo, hi = identifiability_band(alpha, c1, c2, LEVER_ARM)
    print(f"   band PB(alpha={alpha}; c1={c1:.4f}, c2={c2:.4f}), lever arm {LEVER_ARM:.0f}")
    print(f"   certified slope interval: [{lo:.6f}, {hi:.6f}]  (half-width {sigma/LEVER_ARM:.6f})")

    # sharpness: saturate the lower endpoint at k1 and the upper endpoint at k2
    e1 = c1 * 2.0 ** (alpha * LO_LEVEL)
    e2 = c2 * 2.0 ** (alpha * HI_LEVEL)
    s_att = log_slope(e1, e2, LO_LEVEL, HI_LEVEL)
    print(f"   endpoint-saturating curve attains slope = {s_att:.6f} = alpha + sigma/dk"
          f" ({alpha + sigma/LEVER_ARM:.6f})")

    # converse: two exponents separated by 2*sigma/dk give identical slopes
    a1 = 1.0
    a2 = a1 + 2.0 * sigma / LEVER_ARM
    up1 = log_slope(c1 * 2.0 ** (a1 * LO_LEVEL), c2 * 2.0 ** (a1 * HI_LEVEL), LO_LEVEL, HI_LEVEL)
    dn2 = log_slope(c2 * 2.0 ** (a2 * LO_LEVEL), c1 * 2.0 ** (a2 * HI_LEVEL), LO_LEVEL, HI_LEVEL)
    print(f"   exponent {a1:.4f} saturating upward -> slope {up1:.6f}")
    print(f"   exponent {a2:.4f} saturating downward -> slope {dn2:.6f}")
    print(f"   identical: {math.isclose(up1, dn2, rel_tol=1e-12)}  "
          f"=> two-point resolution is exactly 2*sigma/dk = {2*sigma/LEVER_ARM:.4f}\n")


def demo_3_pointwise_band(rng: random.Random) -> None:
    print("=" * 74)
    print("3. Pointwise slope band on a dyadic population, and the 0.84 refutation")
    print("=" * 74)
    n = 1500
    for s in (1.0, 0.5, 0.25):
        pops = {k: dyadic_population(k, n, rng) for k in (LO_LEVEL, HI_LEVEL)}
        means = {k: mean([p ** s for p in pops[k]]) for k in pops}
        sl = log_slope(means[LO_LEVEL], means[HI_LEVEL], LO_LEVEL, HI_LEVEL)
        tol = s / LEVER_ARM
        ok = abs(sl - s) <= tol + 1e-12
        print(f"   s = {s:.2f}: measured {sl:.6f}, certified band [{s-tol:.6f}, {s+tol:.6f}]"
              f"  inside: {ok}")
    floor = 1.0 - 1.0 / LEVER_ARM
    print(f"\n   s = 1 forces slope >= {floor:.4f}; reported trial slope = {MEASURED_TRIAL}")
    print(f"   -> pointwise linear model REFUTED (deficit {floor - MEASURED_TRIAL:.4f} "
          f"below the floor).")
    d = 1.0 - MEASURED_TRIAL
    print(f"   any linear power band matching 0.84 needs spread >= 2^({d*LEVER_ARM:.2f}) "
          f"= {2.0 ** (d * LEVER_ARM):.4f}\n")


def demo_4_cross_channel(rng: random.Random) -> None:
    print("=" * 74)
    print("4. Cross-channel rigidity: Cauchy-Schwarz, Kantorovich, doubling ray")
    print("=" * 74)
    n = 1500
    a, c = 7.3e-6, 41.0  # arbitrary implementation constants; they must cancel
    pops = {k: dyadic_population(k, n, rng) for k in (LO_LEVEL, HI_LEVEL)}
    e_tri = {k: a * mean(pops[k]) for k in pops}
    e_rho = {k: c * mean([math.sqrt(p) for p in pops[k]]) for k in pops}
    s_tri = log_slope(e_tri[LO_LEVEL], e_tri[HI_LEVEL], LO_LEVEL, HI_LEVEL)
    s_rho = log_slope(e_rho[LO_LEVEL], e_rho[HI_LEVEL], LO_LEVEL, HI_LEVEL)
    disc = abs(s_tri - 2.0 * s_rho)
    kant = math.log2(kantorovich_constant()) / LEVER_ARM
    print(f"   simulated dyadic population, n = {n} per level, a = {a}, c = {c}")
    print(f"   slope_trial = {s_tri:.6f},  slope_rho = {s_rho:.6f}")
    print(f"   discrepancy |slope_trial - 2 slope_rho| = {disc:.8f}")
    print(f"   crude allowance  1/dk                    = {1.0/LEVER_ARM:.8f}")
    print(f"   sharp allowance  log2((4+3sqrt2)/8)/dk   = {kant:.8f}")
    print(f"   both respected: {disc <= kant + 1e-12}")

    disc_meas = abs(MEASURED_TRIAL - 2.0 * MEASURED_RHO)
    print(f"\n   reported pair (0.84, 0.52): discrepancy = {disc_meas:.4f}")
    print(f"   crude bound violated by factor {disc_meas / (1.0/LEVER_ARM):.2f}")
    print(f"   sharp bound violated by factor {disc_meas / kant:.2f}")
    print("   -> the reported pair is IMPOSSIBLE for any such population.")

    print("\n   witness saturating the law (one-point population at the window floor):")
    w_tri = {k: 0.5 * 2.0 ** k for k in (LO_LEVEL, HI_LEVEL)}
    w_rho = {k: 2.0 ** (-0.5) * 2.0 ** (0.5 * k) for k in (LO_LEVEL, HI_LEVEL)}
    print(f"     slope_trial = {log_slope(w_tri[LO_LEVEL], w_tri[HI_LEVEL], LO_LEVEL, HI_LEVEL):.6f}"
          f"   slope_rho = {log_slope(w_rho[LO_LEVEL], w_rho[HI_LEVEL], LO_LEVEL, HI_LEVEL):.6f}")

    print("\n   the sharp doubling-ray family K(t) = (1+2^t)^2/(4*2^t):")
    print(f"     {'t':>6} {'log2 K(t)':>14} {'generic 2t^2':>14} {'ratio':>10}")
    for t in (1.0, 0.75, 0.5, 0.25, 0.125, 0.0625):
        lk = math.log2(doubling_constant(t))
        gen = 2.0 * t * t
        print(f"     {t:>6.4f} {lk:>14.8f} {gen:>14.8f} {gen/lk:>10.3f}")
    print(f"   K(1/2) = {doubling_constant(0.5):.10f}  vs  (4+3sqrt2)/8 = "
          f"{kantorovich_constant():.10f}\n")


def demo_5_power_mean(rng: random.Random) -> None:
    print("=" * 74)
    print("5. General power-mean rigidity  |t*slope_s - s*slope_t| <= s*t/dk")
    print("=" * 74)
    n = 1200
    pops = {k: dyadic_population(k, n, rng) for k in (LO_LEVEL, HI_LEVEL)}
    print(f"     {'s':>6} {'t':>6} {'discrepancy':>14} {'allowance s t/dk':>18} {'ok':>5}")
    for s, t in [(1.0, 0.5), (2.0, 1.0), (1.0, 0.25), (0.75, 0.3), (3.0, 0.5)]:
        ms = {k: mean([p ** s for p in pops[k]]) for k in pops}
        mt = {k: mean([p ** t for p in pops[k]]) for k in pops}
        ss = log_slope(ms[LO_LEVEL], ms[HI_LEVEL], LO_LEVEL, HI_LEVEL)
        st = log_slope(mt[LO_LEVEL], mt[HI_LEVEL], LO_LEVEL, HI_LEVEL)
        disc = abs(t * ss - s * st)
        allow = s * t / LEVER_ARM
        print(f"     {s:>6.2f} {t:>6.2f} {disc:>14.8f} {allow:>18.8f} {str(disc <= allow):>5}")
    print()


def demo_6_fermat(rng: random.Random) -> None:
    print("=" * 74)
    print("6. Fermat: exact gap locality and the exponent transfer law")
    print("=" * 74)

    def is_prime(m: int) -> bool:
        if m < 2:
            return False
        for q in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
            if m % q == 0:
                return m == q
        d, r = m - 1, 0
        while d % 2 == 0:
            d //= 2
            r += 1
        for base in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
            x = pow(base, d, m)
            if x in (1, m - 1):
                continue
            for _ in range(r - 1):
                x = x * x % m
                if x == m - 1:
                    break
            else:
                return False
        return True

    def random_prime(bits: int, r: random.Random) -> int:
        while True:
            cand = r.getrandbits(bits) | (1 << (bits - 1)) | 1
            if is_prime(cand):
                return cand

    print("   verifying  (q-p)^2/(8q) <= (p+q)/2 - sqrt(pq) <= (q-p)^2/(8p):")
    worst_lo, worst_hi = 1e18, 1e18
    for _ in range(200):
        k = rng.choice([16, 20, 24])
        p = random_prime(k, rng)
        q = random_prime(k, rng)
        if p > q:
            p, q = q, p
        offset = (p + q) / 2.0 - math.sqrt(float(p) * float(q))
        lo = (q - p) ** 2 / (8.0 * q)
        hi = (q - p) ** 2 / (8.0 * p)
        worst_lo = min(worst_lo, offset - lo)
        worst_hi = min(worst_hi, hi - offset)
        # identity check
        assert abs(offset - (math.sqrt(q) - math.sqrt(p)) ** 2 / 2.0) < 1e-6 * max(1.0, offset)
    print(f"     200 random balanced-semiprime draws: min slack (lower) = {worst_lo:.6e}, "
          f"min slack (upper) = {worst_hi:.6e}")
    print("     both nonnegative -> the two-sided gap-locality law holds on every draw.")

    print("\n   exponent transfer  alpha_Fermat = 2*beta_gap - 1  (synthetic populations):")
    print(f"     {'beta_gap':>10} {'measured Fermat slope':>24} {'2 beta - 1':>12}")
    for beta in (1.0, 0.999, 0.9, 0.75, 0.6):
        f_lo = (2.0 ** (beta * LO_LEVEL)) ** 2 / (8.0 * 2.0 ** LO_LEVEL)
        f_hi = (2.0 ** (beta * HI_LEVEL)) ** 2 / (8.0 * 2.0 ** HI_LEVEL)
        sl = log_slope(f_lo, f_hi, LO_LEVEL, HI_LEVEL)
        print(f"     {beta:>10.4f} {sl:>24.6f} {2*beta-1:>12.6f}")
    print(f"\n   inverting the reported Fermat slope {MEASURED_FERMAT}: "
          f"beta_gap = (sigma+1)/2 = {(MEASURED_FERMAT + 1)/2:.4f}")
    print("   (a population with gaps proportional to p would have beta = 1 and slope 1)\n")


def demo_7_birthday() -> None:
    print("=" * 74)
    print("7. The birthday storage threshold  p < m^2  <=>  isqrt(p) + 1 <= m")
    print("=" * 74)
    bad = 0
    for p in range(0, 3000):
        thr = math.isqrt(p) + 1
        for m in range(0, 80):
            if (p < m * m) != (thr <= m):
                bad += 1
    print(f"   exhaustive check over p < 3000, m < 80: mismatches = {bad}")
    print(f"     {'p':>12} {'isqrt(p)+1':>12} {'sqrt(p)':>12} {'2 sqrt(p)':>12}")
    for p in (2 ** 16, 2 ** 20, 2 ** 24, 10 ** 9 + 7):
        print(f"     {p:>12} {math.isqrt(p)+1:>12} {math.sqrt(p):>12.3f} {2*math.sqrt(p):>12.3f}")
    print("   sandwich sqrt(p) <= isqrt(p)+1 <= 2 sqrt(p) holds: a 1/2-power law of spread <= 2,")
    print(f"   hence a certified rho slope band of 1/2 +/- {math.log2(math.sqrt(2))/LEVER_ARM:.4f} "
          f"at lever arm {LEVER_ARM:.0f}.")
    lo, hi = 0.5 - 1.0 / 16.0, 0.5 + 1.0 / 16.0
    print(f"   reported rho slope {MEASURED_RHO} in [{lo:.4f}, {hi:.4f}]: "
          f"{lo <= MEASURED_RHO <= hi}  -> NON-REFUTING")
    # explicit admissible curve realizing 0.52 exactly
    e16 = 2.0 ** ((LO_LEVEL - 1) / 2.0)
    e24 = 2.0 ** 11.66
    print(f"   explicit admissible curve: E(16) = 2^7.5, E(24) = 2^11.66 in [2^11.5, 2^12], "
          f"slope = {log_slope(e16, e24, LO_LEVEL, HI_LEVEL):.4f}\n")


def demo_8_truncation(rng: random.Random) -> None:
    print("=" * 74)
    print("8. Truncation no-go: min(p, B*2^k) cannot manufacture the deficit")
    print("=" * 74)
    n = 1500
    pops = {k: dyadic_population(k, n, rng) for k in (LO_LEVEL, HI_LEVEL)}
    print(f"     {'B':>10} {'slope':>12} {'deficit 1-slope':>18} {'< 1/8':>7}")
    for B in (10.0, 2.0, 1.0, 0.75, 0.6, 0.5, 0.25, 0.05):
        e = {k: mean([min(p, B * 2.0 ** k) for p in pops[k]]) for k in pops}
        sl = log_slope(e[LO_LEVEL], e[HI_LEVEL], LO_LEVEL, HI_LEVEL)
        print(f"     {B:>10.4f} {sl:>12.6f} {1.0-sl:>18.8f} {str(1.0-sl < 0.125):>7}")
    print("   uniformly in B the spread stays <= 2, so slope >= 0.875 and the deficit < 1/8.")
    print(f"   explaining {MEASURED_TRIAL} would need a deficit of "
          f"{1.0-MEASURED_TRIAL:.2f} -> truncation REFUTED as an explanation.\n")


def demo_9_shape_drift(rng: random.Random) -> None:
    print("=" * 74)
    print("9. The shape-drift identity and the falsifiable prediction")
    print("=" * 74)
    n = 1500
    s = 1.0

    def check(name: str, pops: Dict[int, List[float]]) -> None:
        e = {k: mean([p ** s for p in pops[k]]) for k in pops}
        sl = log_slope(e[LO_LEVEL], e[HI_LEVEL], LO_LEVEL, HI_LEVEL)
        m_lo = shape_moment(pops[LO_LEVEL], LO_LEVEL, s)
        m_hi = shape_moment(pops[HI_LEVEL], HI_LEVEL, s)
        drift = math.log2(m_hi / m_lo) / LEVER_ARM
        print(f"   {name}")
        print(f"     M_1(16) = {m_lo:.8f}, M_1(24) = {m_hi:.8f}, ratio = {m_lo/m_hi:.6f}")
        print(f"     measured slope = {sl:.10f}")
        print(f"     s + drift      = {s + drift:.10f}   (identity holds: "
              f"{math.isclose(sl, s + drift, rel_tol=1e-12, abs_tol=1e-12)})")
        print(f"     compression (slope < s): {sl < s}   shape decrease (M(24)<M(16)): "
              f"{m_hi < m_lo}\n")

    check("scale-invariant dyadic sampler (uniform on [2^(k-1), 2^k]):",
          {k: dyadic_population(k, n, rng) for k in (LO_LEVEL, HI_LEVEL)})
    check("drifting sampler u_k = 2^(-0.16 k):",
          {k: drifting_population(k, n, 0.16) for k in (LO_LEVEL, HI_LEVEL)})

    d = 1.0 - MEASURED_TRIAL
    forced = 2.0 ** (d * LEVER_ARM)
    print(f"   INVERSION: the reported slope {MEASURED_TRIAL} forces, exactly,")
    print(f"     M_1(16) / M_1(24) = 2^({d*LEVER_ARM:.2f}) = {forced:.6f}")
    print(f"   but a genuinely dyadic sampler has M_1(k) in [1/2, 1], so the ratio is <= 2.")
    print(f"     {forced:.4f} > 2  ->  the measurement also refutes the dyadic window itself.")
    print("   The prediction is directly checkable: compute the mean normalized")
    print("   small factor at k = 16 and k = 24 and take the ratio.\n")


def main() -> None:
    rng = random.Random(SEED)
    print()
    print("#" * 74)
    print("#  Across-level scaling exponents on one population of balanced semiprimes")
    print(f"#  levels k = {LO_LEVEL} -> {HI_LEVEL}, lever arm dk = {LEVER_ARM:.0f}, seed {SEED}")
    print(f"#  reported slopes: trial {MEASURED_TRIAL}, rho {MEASURED_RHO}, "
          f"Fermat {MEASURED_FERMAT}")
    print("#" * 74)
    print()
    demo_1_pure_power()
    demo_2_identifiability()
    demo_3_pointwise_band(rng)
    demo_4_cross_channel(rng)
    demo_5_power_mean(rng)
    demo_6_fermat(rng)
    demo_7_birthday()
    demo_8_truncation(rng)
    demo_9_shape_drift(rng)
    print("=" * 74)
    print("SUMMARY")
    print("=" * 74)
    print("  rho    0.52 : NON-REFUTING (inside 1/2 +/- 1/16, attained by an admissible curve)")
    print("  Fermat 0.50 : a gap-exponent meter; inverts to beta_gap = 0.75")
    print("  trial  0.84 : REFUTED as a pointwise linear cost, not rescued by truncation,")
    print("                inconsistent with the rho slope on the same draws by a factor > 36,")
    print("                and equivalent to a normalized-moment drift of 2^1.28 ~ 2.428")
    print("                which a dyadic sampler cannot produce.")
    print()


if __name__ == "__main__":
    main()
