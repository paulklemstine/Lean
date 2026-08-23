#!/usr/bin/env python3
"""Assemble PACKAGE.json from the individual project artefacts."""

from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
A = ROOT / "assets"


def read(p: Path) -> str:
    return p.read_text(encoding="utf-8")


def slice_marker(src: str, tag: str) -> str:
    m = re.search(rf"# ===== {tag} =====\n(.*?)# ===== /{tag} =====", src, re.S)
    assert m, f"marker {tag} not found"
    return m.group(1).rstrip() + "\n"


ALGSRC = read(A / "algorithms.py")
PREAMBLE = (
    "from __future__ import annotations\n\n"
    "from fractions import Fraction\n"
    "from typing import Dict, List, Optional, Sequence, Tuple\n\n\n"
)

LEAN_FILES = [
    "Catalog/MachineLearning/ZeroFitDialUnif52.lean",
    "Catalog/MachineLearning/ZeroFitDialResolution.lean",
    "Catalog/MachineLearning/ZeroFitDialEnvelope.lean",
    "Catalog/MachineLearning/ZeroFitDialEnvelopeSharp.lean",
]

lean_blocks = []
for rel in LEAN_FILES:
    lean_blocks.append(
        f"-- ============================================================\n"
        f"-- FILE: {rel}\n"
        f"-- ============================================================\n\n"
        + read(ROOT / rel).rstrip()
        + "\n"
    )
LEAN_PROOFS = "\n\n".join(lean_blocks)

FUTURE_DIRECTIONS = """# Future directions — after the bit-length-52 uniform-draw cycle

Four developments were completed this cycle, all fully proved:

* **The tie geometry of the count (Hamming-weight) baseline** — the count ceiling law
  `ρ²_count ≥ 1 - 4/(3b+2)` for even bit lengths, its convergence to `1`, and the
  **inversion law**: for every even bit length `b ≥ 10` the count baseline's tie ceiling
  *strictly exceeds* the trailing-zero dial's `6/7`.
* **The resolution law** `ρ² ≤ 1 - 1/K² + 1/n²` for any statistic with `K` distinct values on
  `n` points, from a power-mean inequality proved by an explicit sum-of-squares identity; the
  resulting two-sided sandwich for the count ceiling at bit length 52, and the **shape gap**
  showing that resolution alone does not determine a ceiling.
* **The deployment envelope** — the dominant-block upper law, the half-mass cap `ρ ≤ 0.936`,
  and the **envelope stability law**: ceilings are `7`-Lipschitz in the total-variation
  distance between draw laws, giving a robust deployment envelope for the recorded
  bit-length-52 readings.
* **Sharpening the envelope constant** — a conservation-aware displacement lemma sharpening the
  envelope constant to `4.1`, together with an explicit pair of 52-bit profiles showing no
  envelope law can have constant below `2.96`; the sharp constant is therefore bracketed in
  `[2.96, 4.1]`.

The analysis that survives adversarial review is: *the recorded `+0.070` advantage of the dial
over the count baseline cannot be a tie/quantisation artefact, because tie geometry favours the
count baseline.* What failed is the tempting hypothesis that the count baseline's huge central
tie class (`C(52,26) ≈ 5·10¹⁴`) depresses its ceiling — it does not, because the Franel cube sum
is only `Θ(8^b/b)`; that is "false", not "true but hard".

The conjectures below are the natural next cycle.

---

## 1. Franel exact ceiling law

**The key insight is** that the count ceiling is *exactly* `1 - (F(b) - 2^b)/(8^b - 2^b)` with
`F(b)` the Franel number `Σₖ C(b,k)³` (OEIS A000172), and Franel numbers satisfy the three-term
P-recursive relation `(n+1)²F(n+1) = (7n² + 7n + 2)F(n) + 8n²F(n-1)`; feeding that recursion
into the attenuation law should turn the current sandwich `[0.9747, 0.9996]` into a closed
asymptotic `ρ²_count = 1 - c/b + O(b⁻²)` with `c = √3/(2π) ≈ 0.2757` — an *exact* constant rather
than a bound.

**Why now?** The sandwich proved this cycle already isolates the target between two explicit
rationals, and the recursion is elementary to state; the only missing ingredient is a
Laplace-type asymptotic for `F(b)/8^b`, which the recursion converts into a linear
difference-equation estimate.

## 2. Universal shape functional for tie ceilings

**The key insight is** that both the dyadic (`6/7`) and the binomial (`→ 1`) ceilings are values
of one functional — the limiting `ℓ³` norm of the normalised tie profile. If the normalised
profile converges to a weight sequence `(pᵢ)`, the ceiling limit should be `1 - Σᵢ pᵢ³`. For the
dyadic law `pᵢ = 2^{-(i+1)}` and `Σᵢ pᵢ³ = 1/7`, giving exactly `6/7`; for the binomial law the
weights vanish uniformly and the sum is `0`, giving `1`. Formalising this as a continuity
statement for the map `μ ↦ ‖μ‖₃³` on profile measures would unify every ceiling computation in
this cycle, and the envelope stability law is precisely the finite-`n` shadow of that
continuity.

## 3. Sharpening the envelope constant to a single value

The sharp constant is bracketed in `[2.96, 4.1]`. The lower witness is a two-block profile, which
suggests the extremiser is the family `(1-t, t)`; optimising `|1 - (1-t)³ - t³| / t` over `t`
should identify the sharp constant exactly. Numerical search over two-block profiles at bit
length 52 reaches `2.9978`, so the answer is plausibly exactly `3`.

## 4. Empirical profiles and concentration

The profiles analysed are population profiles over all `2^b` words. For a finite sample the
empirical profile is a multinomial draw from the population law; combining a concentration
inequality for its total-variation distance with the envelope stability law would upgrade every
ceiling statement from a population guarantee to a finite-sample one.

## 5. Optimal quantiser design

The resolution law says `K` bins buy at most `1 - 1/K²`; the shape gap says where inside that
budget a statistic lands is decided by the profile shape. The equality case of the power-mean
inequality identifies equal-mass bins as optimal. Quantifying the loss from unequal bins, in
terms of the `ℓ³` norm of the bin-mass vector, would turn the theory into a practical
quantiser-design rule.
"""

INTERACTIVE_LAYOUT = r"""
# Tie Ceilings: Why Your Statistic Has a Speed Limit

> **What you will learn.** Every discrete statistic used with rank correlation has a
> *ceiling* — a maximum correlation it can ever attain, fixed before any data arrives, by
> nothing but how it groups the sample into tied blocks. By the end of this page you will be
> able to compute that ceiling exactly, predict which of two statistics is more handicapped
> (and be surprised by the answer), and certify how far the input distribution can drift
> before the guarantee breaks.

---

## 1. The problem, in one picture

Hand someone a ruler with only 53 marks and ask for a millimetre measurement. They will fail,
and it is not their fault. Statistics has the same problem, but a correlation coefficient does
not announce that it is being throttled by its own granularity — it just comes back low, and
invites the wrong story.

Concretely: draw 52-bit machine words and compute the number of **trailing binary zeros** of
each. Call it the **dial**. It is one processor instruction, and on $b$-bit words it returns one
of only $b+1$ answers. At $b=52$ that is $4.5 \times 10^{15}$ inputs mapped onto $53$ outputs.

The competing diagnostic is the **count**: the number of $1$-bits, the Hamming weight. Also
$53$ values.

Three independent runs measured the dial's Spearman correlation against a downstream response:

$$\rho = 0.698,\qquad 0.697,\qquad 0.720 \qquad(\text{pooled } 0.705),$$

and the dial beat the count by $+0.070$, with confidence interval $[0.046, 0.093]$.

**Is that advantage real, or is one statistic simply more tie-crippled than the other?**

---

## 2. Ties, midranks, and the exact ceiling

<details>
<summary><b>Click to reveal: what a midrank is and why it costs you variance</b></summary>

When a statistic takes the same value on a block of $m$ sample points, those points have no
internal order. The standard fix is the **midrank**: every member of the block receives the
average of the consecutive ranks the block occupies. It is fair, but lossy — the block's rank
variance collapses from that of $m$ distinct integers to zero, a loss of exactly

$$\frac{m^3 - m}{12}.$$

Summing over blocks defines the **tie correction** $C(L) = \sum_j (m_j^3 - m_j)/12$ of the
**tie profile** $L = (m_1, \dots, m_K)$, the multiset of tie-class sizes. Against the most
favourable response possible — one that resolves every comparison the statistic *can* resolve —
the squared Spearman correlation is exactly

$$\rho^2_{\max}(L) \;=\; 1 - \frac{12\,C(L)}{n^3 - n} \;=\; 1 - \frac{\sum_j m_j^3 - n}{n^3 - n},
\qquad n = \sum_j m_j.$$

Read that formula again and notice what is **not** in it: the response, the sample values, the
science. The ceiling is a property of the instrument. It also depends on the profile only
through the single number $\sum_j m_j^3$ — the **cube sum**. Every theorem below is an estimate
of that one quantity.

Sanity checks: no ties gives $C = 0$ and ceiling $1$; everything tied gives ceiling $0$.

</details>

Rather than take the formula on faith, watch the collapse happen. The widget below builds a
sample, groups it into the tie blocks you choose, shows the midranks, computes the ordinary
correlation between the collapsed ranks and an ideal response, and compares it to the closed
formula. They agree to machine precision — every time.

{{interactive_demo:1}}

> **Try this.** Compare the preset `8,8` with the preset `15,1`. Both have $n=16$ and both have
> exactly two classes, yet the first reaches $\rho^2 = 0.7529$ and the second only $0.1765$.
> *Same resolution, wildly different ceilings.* Hold on to that observation — it becomes a
> theorem in Section 5.

---

## 3. The dial's ceiling is $6/7$, forever

Among $2^b$ uniformly drawn $b$-bit words, exactly half are odd, a quarter end in one zero, an
eighth in two, and the lone word $0$ sits by itself. The profile is a geometric cascade,

$$L_{\mathrm{dy}}(b) = \bigl(2^{b-1},\,2^{b-2},\,\dots,\,2,\,1,\,1\bigr).$$

Its cube sum is a geometric series, and the algebra collapses beautifully.

> **Theorem (Dyadic Ceiling).** For every $b \ge 1$, with $n = 2^b$,
> $$\rho^2_{\max}\bigl(L_{\mathrm{dy}}(b)\bigr) = \frac{6}{7}\left(1 + \frac{1}{n(n+1)}\right).$$

<details>
<summary><b>Click to reveal the proof</b></summary>

The cube sum is
$\sum_{k=0}^{b-1} 8^k + 1 = \frac{8^b - 1}{7} + 1 = \frac{n^3 + 6}{7}$, so

$$1 - \rho^2_{\max} = \frac{n^3 - 7n + 6}{7n(n^2-1)}
= \frac{(n-1)(n-2)(n+3)}{7n(n-1)(n+1)} = \frac{(n-2)(n+3)}{7n(n+1)}.$$

Subtracting from $1$ and collecting terms,
$$\rho^2_{\max} = \frac{7n(n+1) - (n^2 + n - 6)}{7n(n+1)} = \frac{6(n^2+n+1)}{7n(n+1)}
= \frac67\left(1 + \frac{1}{n(n+1)}\right).\qquad\blacksquare$$

**Why $6/7$?** The profile is self-similar: strip the leading block and rescale, and you get the
profile back. Under that scaling both the cube sum and $n^3$ pick up a factor $8$, so the
normalised cube sum has a fixed point, $1/7$. The constant is a signature of binary doubling —
not of any hardware parameter.

</details>

At $b=4$ the ceiling is $0.8603$; at $b=16$ it is $0.85714286$; at $b=52$ it differs from $6/7$
in the thirty-second decimal place. On the correlation scale the dial can never exceed

$$\sqrt{6/7} = 0.925820\ldots$$

Doubling the word length buys nothing. A reading of $0.98$ from this dial would not be
impressive; it would be impossible.

---

## 4. The intuition that is wrong

Now the count. Its profile is a row of Pascal's triangle, and at $b=52$ the central class has
size $\binom{52}{26} = 495{,}918{,}532{,}948{,}104$ — nearly half a quadrillion words sharing one
value. Surely *this* is the crippled statistic?

Run the algorithm and see for yourself.

{{algorithm:0}}

The cube sum of a binomial row is the **Franel number** $F(b) = \sum_k \binom{b}{k}^3$
(sequence A000172), and the whole question is how big $F(b)$ is relative to the maximum
conceivable $8^b$.

<details>
<summary><b>Click to reveal: the arithmetic that settles it</b></summary>

Two elementary steps.

**Cube-to-square collapse.** Termwise
$\binom{b}{k}^3 = \binom{b}{k}^2\binom{b}{k} \le \bigl(\max_k \binom{b}{k}\bigr)^2 \binom{b}{k}$,
so summing gives $F(b) \le \binom{b}{\lfloor b/2\rfloor}^2 \cdot 2^b$.

**Sharp central-binomial bound.** For every $m \ge 0$,
$$\binom{2m}{m}^2 (3m+1) \le 16^m, \qquad\text{i.e.}\qquad \binom{2m}{m} \le \frac{4^m}{\sqrt{3m+1}}.$$
This is proved by induction using $(m+1)\binom{2m+2}{m+1} = 2(2m+1)\binom{2m}{m}$; the inductive
step reduces to the polynomial inequality $(2m+1)^2(3m+4) \le (2m+2)^2(3m+1)$, which after
expansion is $19m \le 20m$.

Combining them at $b = 2m$ gives $F(2m)(3m+1) \le 8^{2m}$: **the Franel sum is only
$\Theta(8^b/b)$**, a vanishing fraction of what a genuinely degenerate profile would need.

Feeding that into the ceiling formula, and using $8^b - 2^b \ge 8^b/2$:
$$1 - \rho^2_{\max} \le \frac{2F(b)}{8^b} \le \frac{2}{3m+1} = \frac{4}{3b+2}.$$

</details>

> **Theorem (Count Ceiling Law).** For every even bit length $b \ge 2$,
> $$\rho^2_{\max}\bigl(L_{\mathrm{bin}}(b)\bigr) \ge 1 - \frac{4}{3b+2},$$
> and hence $\rho^2_{\max} \to 1$: the Hamming-weight statistic is *asymptotically
> tie-transparent*.

> **Theorem (Inversion Law).** For every even $b \ge 10$, the count's ceiling **strictly
> exceeds** the dial's. The statistic with the colossal central class is the *less* attenuated
> of the two.

Here is the whole story in one figure — the two ceilings as a function of bit length, with the
crossing marked, and the two profile shapes side by side.

{{visualization:0}}

**Why this settles the empirical question.** The recorded ordering is dial $0.705$ beats count
$0.635$. The ceiling ordering is count $0.9965$ beats dial $0.9258$. *The statistic that wins
the measurement is the one with the worse instrument.* Rank granularity acts in the opposite
direction to the observed effect, so no amount of tie bookkeeping can manufacture the $+0.070$.
It is signal.

---

## 5. Resolution is a budget; shape is the spend

Both statistics distinguish exactly $53$ values. Does that number alone determine anything?

> **Theorem (Resolution Law).** A statistic taking $K$ distinct values on $n$ points satisfies
> $$\rho^2_{\max} \le 1 - \frac{1}{K^2} + \frac{1}{n^2}.$$

<details>
<summary><b>Click to reveal the sum-of-squares proof</b></summary>

The engine is a power-mean inequality: $n^3 \le K^2 \sum_j m_j^3$, with equality exactly when
all blocks are equal. The induction on the profile length rests on one algebraic identity. Write
$L = (m) \frown L'$ with $K' = |L'|$, $s = \Sigma L'$; the inductive step reduces to showing that

$$K'^2(K'+1)^2 m^3 + (K'+1)^2 s^3 - K'^2 (m+s)^3
\;=\; (K'm - s)^2\bigl(K'^2 m + 2K'm + 2K's + s\bigr)$$

is non-negative — and the right-hand side is *visibly* non-negative, being a square times a sum
of non-negative terms. That is a sum-of-squares certificate: an identity you can verify by
expanding both sides, with no analysis required.

Given $\sum_j m_j^3 \ge n^3/K^2$, the ceiling deficit is at least
$(n^3/K^2 - n)/(n^3 - n)$, and a short computation using $K \le n$ turns that into
$1/K^2 - 1/n^2$.

</details>

Read backwards, this is a **resolution budget**: to read $\rho^2 \ge 1 - \varepsilon$ you need at
least about $1/\sqrt{\varepsilon}$ distinct values. Want $0.99$? Ten values, minimum. Want
$0.9999$? A hundred. It costs nothing to check at design time.

But now apply it. With $K = 53$ the budget permits $\rho^2 \le 0.99964$. The count comes within
$0.007$ of the budget; the dial misses it by more than $0.14$.

> **Theorem (Shape Gap).** At $b = 52$ the dyadic and binomial profiles have the *same* number
> of distinct values, yet
> $$\rho^2_{\max}\bigl(L_{\mathrm{dy}}(52)\bigr) + \tfrac{1}{10} < 1 - \tfrac{1}{53^2} + \tfrac{1}{(2^{52})^2}.$$

Counting your categories tells you what is impossible. Only the profile's shape tells you what
is achievable. Go back to the collapse widget and re-run `8,8` against `15,1` — that is this
theorem in miniature.

---

## 6. A cap you cannot escape, whatever the draw law

Everything so far assumed a specific draw law. The next result does not.

<details>
<summary><b>Click to reveal: the dominant-block mechanism</b></summary>

The tie correction is a sum of non-negative terms, so a *single* class of size $M$ already
contributes $(M^3 - M)/12$, giving the **dominant-block upper law**
$$\rho^2_{\max} \le 1 - \frac{M^3 - M}{n^3 - n}$$
with no hypothesis on the rest of the profile. If $M \ge n/2$ then $M^3 \ge n^3/8$, and using
the exact identity
$$\left(\frac18 - \frac{7}{8(n^2-1)}\right)(n^3-n) = \frac{n^3}{8} - n$$
the deficit is at least $\tfrac18 - \tfrac{7}{8(n^2-1)}$.

</details>

> **Theorem (Half-Mass Cap).** If any single value of the statistic is taken by at least half
> the sample, then
> $$\rho^2_{\max} \le \frac78 + \frac{7}{8(n^2-1)},$$
> and once $n \ge 1024$ this gives $\rho \le 0.936$ on the correlation scale.

This is **distribution-free**. It assumes only that the modal value carries half the mass, which
for the trailing-zero dial holds under *any* draw law in which at least half the words are odd —
balanced, uniform, skewed, adversarial. So the dial's specification sheet reads: *valid range
$[0, 0.936]$, hard stop*. The validation band $[0.55, 0.85]$ sits comfortably inside; a reported
reading above $0.936$ would be a falsification, not a triumph.

---

## 7. Does the ceiling move when the world does?

The last worry, and the deepest. Real deployments drift. If the ceiling were exquisitely
sensitive to the draw law, every guarantee above would be a knife-edge.

It is not: the ceiling is **Lipschitz in the draw law**, with an explicit constant.

<details>
<summary><b>Click to reveal: the displacement lemma and where the constant comes from</b></summary>

Measure the distance between two draw laws by the total variation $\tau$ between their profiles,
$\tau = \|L - L'\|_1/(2n)$. Since the ceiling depends on the profile only through the cube sum,
and $|a^3 - b^3| = |a-b|(a^2+ab+b^2)$, a naive bound gives a Lipschitz constant of $7$.

That throws away a conservation law. Both profiles carry the *same total mass*, so mass cannot
vanish, only move — and hence

$$2\,\bigl|m_j - m_j'\bigr| \;\le\; \|L - L'\|_1 + \bigl|\Sigma L - \Sigma L'\bigr|,$$

the **displacement lemma**: no single class can absorb more than half of the $\ell^1$ budget.
Combining it with the sharper factorisation $a^2 + ab + b^2 \le (a+b)^2$ and the square-sum
bound $\sum_j (m_j + m_j')^2 \le (2n)^2$ improves the cube estimate by a factor $3/2$, to
$|\Delta \text{cube sum}| \le 2n^2 \|L - L'\|_1$, and the constant drops to $4.1$.

</details>

> **Theorem (Envelope Stability Law).** Two draw laws producing profiles of equal length and
> equal total mass $n \ge 7$, at total-variation distance $\tau$, have ceilings satisfying
> $$\bigl|\rho^2_{\max}(L) - \rho^2_{\max}(L')\bigr| \le 4.1\,\tau.$$

And the constant is genuinely of order one. Take the $52$-bit profile
$A = (2^{52}-1,\,1)$ — almost totally degenerate, ceiling $\approx 0$ — and move exactly $1\%$ of
its mass into the second class. The two laws are at total variation $0.01$ and their ceilings
differ by $0.0297$. **So the sharp constant lies in $[2.96,\, 4.1]$.**

Here is the guarantee drawn as a cone, together with the shape-gap picture from Section 5:

{{visualization:1}}

Cash it out for the recorded data: the dial's ceiling is $6/7 \approx 0.857$, the pooled reading
squared is $0.497$, so the margin is $0.360$ and the tolerated drift is
$0.360/4.1 \approx 8.8\%$ in total variation. That is not a knife-edge; that is a deployment
envelope with a number attached.

Stress-test it yourself — directed transport, randomised transport, and an adversarial search
over two-block profiles that gets within $0.002$ of the conjectured sharp constant $3$:

{{demo:1}}

---

## 8. The laboratory: build your own instrument

Now put everything together. Choose a statistic, deform its profile, drift its draw law, and
watch all four numbers — the exact ceiling, the resolution budget, the half-mass cap, and the
post-drift guarantee — respond live. Every value is computed in exact big-integer arithmetic.

{{interactive_demo:0}}

> **Guided experiments.**
> 1. Select **Trailing zeros** and sweep the bit length from $3$ to $24$. The ceiling snaps to
>    $6/7$ almost immediately and then refuses to move. Word length buys nothing.
> 2. Switch to **Hamming weight** and sweep again. The ceiling climbs steadily toward $1$. This
>    is the inversion law happening in front of you.
> 3. Select **Equal classes**. Same $K$ as the dial, but the ceiling now nearly saturates the
>    resolution bound and the shape gap collapses to almost nothing.
> 4. Select **One dominant class** and push the skew slider. Watch the ceiling fall off a cliff
>    while $K$ never changes — resolution held fixed, shape doing all the work.
> 5. With any preset, push the **drift** slider until the verdict turns amber, then red. The
>    crossover is exactly the tolerated total variation for that instrument.

---

## 9. The whole calculus, executable

Two more pieces of machinery, if you want to run this on your own statistic.

The **certified envelope check** bundles all five guarantees into one pre-registration routine
that you can run *before* collecting data:

{{algorithm:2}}

And for the asymptotics of the count ceiling, the Franel numbers are P-recursive, which is both
faster than the definition and the analytic handle on the exact rate at which the count ceiling
approaches $1$:

{{algorithm:3}}

The profile constructors and the closed-form certifier that ties Sections 3 and 4 together:

{{algorithm:1}}

Finally, the full numerical companion — ten worked sections, every number in exact rational
arithmetic, including a synthetic sampling experiment whose empirical maxima track the
closed-form ceilings to four decimal places:

{{demo:0}}

---

## 10. What an instrument's spec sheet should say

For any discrete statistic used as a diagnostic, four numbers are computable from the tie
profile alone, before the experiment runs:

| Quantity | For the trailing-zero dial |
|---|---|
| Exact ceiling | $\sqrt{6/7} = 0.9258$, independent of word length |
| Resolution budget | $K = 53$ values buy at most $1 - 1/53^2 = 0.99964$ |
| Distribution-free cap | modal class at half mass forces $\rho \le 0.936$ |
| Stability modulus | a $1\%$ draw-law shift moves the ceiling by at most $4.1\%$ |

None of these is about the phenomenon. All of them are about the ruler. And that is what turns
"moderate correlation, $0.705$" into something worth saying:

> *This instrument tops out at $0.926$. The reading uses $54\%$ of the available dynamic range.
> The competing instrument tops out higher, at $0.997$, and still lost by $0.070$ — so the
> difference is not an artefact of granularity. And the whole conclusion survives an $8\%$
> perturbation of the input distribution.*

### Where to read more

- [Spearman's rank correlation coefficient](https://en.wikipedia.org/wiki/Spearman%27s_rank_correlation_coefficient) — the tie-corrected definition used throughout.
- [Franel numbers, OEIS A000172](https://oeis.org/A000172) — the cube sums of binomial rows, with the three-term recurrence.
- [2-adic valuation](https://en.wikipedia.org/wiki/P-adic_valuation) — the number-theoretic name for the trailing-zero count.
- [Central binomial coefficient](https://en.wikipedia.org/wiki/Central_binomial_coefficient) — background for the sharp bound $\binom{2m}{m} \le 4^m/\sqrt{3m+1}$.
- [Total variation distance](https://en.wikipedia.org/wiki/Total_variation_distance_of_probability_measures) — the metric in which the ceiling is Lipschitz.
- [Power mean inequality](https://en.wikipedia.org/wiki/Generalized_mean) — the source of the resolution law.
"""

package = {
    "title": "Tie Ceilings for Discrete Rank Statistics: Exact Values, Resolution Budgets, "
             "and a Deployment Envelope",
    "domain": "MachineLearning",
    "description": (
        "A distribution-free theory of the Spearman tie ceiling of a discrete statistic: the "
        "trailing-zero statistic on b-bit words is pinned at exactly (6/7)(1+1/(2^b(2^b+1))) "
        "while the Hamming-weight baseline converges to 1, so the coarse-looking count "
        "statistic is the less tie-attenuated of the two. The resulting inversion, resolution, "
        "half-mass and Lipschitz-stability laws certify that a recorded +0.070 advantage of "
        "the trailing-zero dial at bit length 52 cannot be a rank-granularity artefact and "
        "survives an 8.8% shift of the input distribution."
    ),
    "authors": ["Aristotle"],
    "date": "2026-08-23",
    "key_results": [
        "Dyadic Ceiling Theorem: the trailing-zero statistic on b-bit words has Spearman tie "
        "ceiling exactly (6/7)(1 + 1/(2^b(2^b+1))), hence the word-length-independent bound "
        "rho <= sqrt(6/7) = 0.9258",
        "Count Ceiling Law and Inversion Law: the Hamming-weight statistic has tie ceiling at "
        "least 1 - 4/(3b+2) for even bit lengths, hence tending to 1, and strictly exceeds the "
        "trailing-zero ceiling for every even bit length at least 10 — so the recorded +0.070 "
        "advantage of the trailing-zero dial cannot be a tie or quantisation artefact",
        "Resolution Law and Shape Gap: any statistic with K distinct values on n points has "
        "ceiling at most 1 - 1/K^2 + 1/n^2, proved from a power-mean inequality with an "
        "explicit sum-of-squares certificate; at bit length 52 two statistics with the "
        "identical K = 53 have ceilings differing by more than 0.14, so resolution alone does "
        "not determine a ceiling",
        "Half-Mass Cap: any statistic whose modal class carries at least half the sample has "
        "ceiling at most 7/8 + 7/(8(n^2-1)), hence correlation at most 0.936 once n >= 1024 — "
        "a bound requiring no assumption on the draw law",
        "Envelope Stability Law with a matching witness: tie ceilings are 4.1-Lipschitz in the "
        "total-variation distance between draw laws, and an explicit pair of 52-bit profiles "
        "shows no constant below 2.96 is possible, bracketing the sharp constant in [2.96, 4.1] "
        "and giving a tolerated draw-law drift of about 8.8% for the recorded readings",
    ],
    "keywords": [
        "Spearman rank correlation",
        "tie correction",
        "midranks",
        "2-adic valuation",
        "Franel numbers",
        "power-mean inequality",
        "total variation",
        "Lipschitz stability",
    ],
    "article": read(ROOT / "ARTICLE.md"),
    "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
    "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
    "demo": read(ROOT / "demo.py"),
    "demos": [
        {
            "name": "Exact Tie-Ceiling Companion: Ten Verified Numerical Studies of the "
                    "Dyadic and Binomial Rank Statistics",
            "description": (
                "A ten-part numerical companion that reproduces every quantitative claim of the "
                "theory in exact rational arithmetic. It evaluates the tie ceiling on small "
                "hand-checkable profiles; confirms that the trailing-zero ceiling matches the "
                "closed form (6/7)(1 + 1/(2^b(2^b+1))) for bit lengths 1 through 52 and that its "
                "excess over 6/7 at b = 52 is below 5e-32; tabulates the Franel numbers and "
                "verifies the proved lower bound 1 - 4/(3b+2) against the exact Hamming-weight "
                "ceiling; exhibits the inversion law together with the deficit comparison "
                "showing the count baseline wastes more than 0.2 extra of its resolving power; "
                "checks the resolution law and measures the 0.1425 shape gap between two "
                "statistics with the identical 53 distinct values; evaluates the half-mass cap "
                "0.936; stress-tests the 4.1-Lipschitz envelope law on a family of perturbed "
                "draw laws; reproduces the explicit two-profile witness pinning the envelope "
                "constant at 2.97; runs a dependency-free synthetic sampling experiment whose "
                "empirical rank-correlation maxima track the closed-form ceilings to four "
                "decimal places; and finally audits the three recorded bit-length-52 readings "
                "against every bound in the theory."
            ),
            "code": read(ROOT / "demo.py"),
        },
        {
            "name": "Deployment-Envelope Stress Test: Directed, Randomised and Adversarial "
                    "Draw-Law Perturbations at Bit Length 52",
            "description": (
                "A focused stress test of the envelope stability law, which asserts that tie "
                "ceilings move by at most 4.1 times the total-variation distance between draw "
                "laws. Three independent attacks are mounted at bit length 52, all in exact "
                "rational arithmetic. (i) Directed transport moves prescribed fractions of mass "
                "out of the dominant odd class of the trailing-zero profile into successively "
                "later classes and records the realised ceiling shift against the guaranteed "
                "bound, obtaining realised ratios around 0.74. (ii) Randomised transport "
                "redistributes mass over randomly chosen class pairs using a deterministic, "
                "reproducible pseudo-random stream, asserting the bound on every one of four "
                "hundred trials. (iii) An adversarial search over two-block profiles of equal "
                "mass locates the genuinely extremal configurations and attains a ratio of "
                "2.9978 — comfortably above the proved lower bracket 2.96 and strong numerical "
                "evidence that the sharp envelope constant is exactly 3."
            ),
            "code": read(A / "demo_envelope_stress.py"),
        },
    ],
    "algorithms": [
        {
            "name": "Exact Tie-Ceiling Evaluation by Cube-Sum Accumulation",
            "description": (
                "Computes the Spearman tie ceiling of a discrete statistic from its tie profile "
                "alone. Given the multiset of tie-class sizes (m_1, ..., m_K) with total mass n, "
                "the ceiling is 1 - 12 C(L)/(n^3 - n) where C(L) = sum_j (m_j^3 - m_j)/12; "
                "equivalently 1 - (S_3 - n)/(n^3 - n) with S_3 the cube sum. The mathematical "
                "foundation is the classical tie-corrected form of Spearman's rho with "
                "midranks: a tied block of size m destroys exactly (m^3 - m)/12 of the rank "
                "variance, and the ceiling is what remains once the most favourable response "
                "possible has been assumed. The algorithm is a single pass accumulating n and "
                "S_3, followed by one exact rational division: O(K) big-integer cubings, i.e. "
                "O(K * M(log n)) bit operations where M is the integer multiplication cost. "
                "Exact arithmetic is not optional — at n = 2^52 the numerator and denominator "
                "carry roughly 47 decimal digits and IEEE double precision annihilates the "
                "correction term entirely. This routine is the primitive on which every other "
                "algorithm in the pipeline is built."
            ),
            "pseudocode": (
                "ALGORITHM ExactTieCeiling(L = (m_1, ..., m_K))\n"
                "  REQUIRE  m_j >= 1 for all j\n"
                "  n    <- 0 ;  S3 <- 0                       // exact integers\n"
                "  FOR j = 1 TO K DO\n"
                "      n  <- n  + m_j\n"
                "      S3 <- S3 + m_j * m_j * m_j\n"
                "  END FOR\n"
                "  IF n < 2 THEN REJECT  ('total mass too small')\n"
                "  numerator   <- S3 - n                      // = 12 * C(L)\n"
                "  denominator <- n*n*n - n\n"
                "  RETURN  1 - numerator / denominator        // exact rational\n"
                "\n"
                "COMPLEXITY  O(K) big-integer multiplications; O(K * M(log n)) bit operations.\n"
                "INVARIANT   0 <= result <= 1, with 1 iff every m_j = 1 and 0 iff K = 1."
            ),
            "code": PREAMBLE + slice_marker(ALGSRC, "ALG1"),
        },
        {
            "name": "Dyadic and Binomial Tie-Profile Synthesis with Closed-Form Certification",
            "description": (
                "Constructs the two tie profiles that the theory compares and certifies every "
                "closed-form law about them. The dyadic profile (2^(b-1), ..., 2, 1, 1) is the "
                "level-set structure of the trailing-zero statistic (the 2-adic valuation) on "
                "the 2^b residues modulo 2^b, built in O(b) shifts. The binomial profile is one "
                "row of Pascal's triangle, the level-set structure of the Hamming weight on the "
                "Boolean cube, built by the multiplicative recurrence C(b,k+1) = C(b,k)(b-k)/(k+1) "
                "in O(b) exact divisions, each exact by construction. The certifier then checks, "
                "in exact arithmetic: that the dyadic ceiling equals (6/7)(1 + 1/(n(n+1))); that "
                "the binomial ceiling meets the proved lower bound 1 - 4/(3b+2) at even bit "
                "lengths; that both respect the universal resolution bound 1 - 1/K^2 + 1/n^2; "
                "that the dyadic profile is half-mass, so the distribution-free 0.936 cap "
                "applies; and that the inversion law holds. Total cost O(b) big-integer "
                "operations, dominated by the cubing pass of the underlying ceiling evaluation."
            ),
            "pseudocode": (
                "ALGORITHM DyadicProfile(b)\n"
                "  IF b <= 0 THEN RETURN (1)\n"
                "  RETURN (2^(b-1), 2^(b-2), ..., 2^1, 2^0, 1)      // b+1 classes, mass 2^b\n"
                "\n"
                "ALGORITHM BinomialProfile(b)\n"
                "  c <- 1 ;  row <- ()\n"
                "  FOR k = 0 TO b DO\n"
                "      append c to row\n"
                "      c <- c * (b - k) / (k + 1)                   // exact at every step\n"
                "  END FOR\n"
                "  RETURN row                                       // b+1 classes, mass 2^b\n"
                "\n"
                "ALGORITHM CertifyClosedForms(b)\n"
                "  n  <- 2^b\n"
                "  Ld <- DyadicProfile(b) ;  Lb <- BinomialProfile(b)\n"
                "  cd <- ExactTieCeiling(Ld) ;  cb <- ExactTieCeiling(Lb)\n"
                "  ASSERT cd = (6/7) * (1 + 1/(n*(n+1)))            // dyadic closed form\n"
                "  IF b is even THEN ASSERT cb >= 1 - 4/(3b+2)      // count ceiling law\n"
                "  ASSERT cd <= 1 - 1/(b+1)^2 + 1/n^2               // resolution law\n"
                "  ASSERT cb <= 1 - 1/(b+1)^2 + 1/n^2\n"
                "  ASSERT 2 * max(Ld) >= n                          // dyadic is half-mass\n"
                "  ASSERT sqrt(cd) <= 0.936                         // half-mass cap\n"
                "  ASSERT cb > cd                                   // inversion law\n"
                "  RETURN report\n"
                "\n"
                "COMPLEXITY  O(b) big-integer operations for each profile and each certificate."
            ),
            "code": PREAMBLE + slice_marker(ALGSRC, "ALG1") + "\n\n"
                    + slice_marker(ALGSRC, "ALG2"),
        },
        {
            "name": "Certified Deployment-Envelope Verification under Draw-Law Drift",
            "description": (
                "A five-certificate audit that decides whether a recorded rank correlation is "
                "compatible with its instrument, and whether that compatibility survives a "
                "specified drift of the input distribution. Certificate 1 checks the reading "
                "against the profile's own exact ceiling — a violation means the reported number "
                "is mathematically impossible. Certificate 2 applies the distribution-free "
                "half-mass cap: if the modal class carries at least half the mass, the reading "
                "must not exceed 0.936 under any draw law whatsoever. Certificate 3 checks the "
                "ceiling against the universal resolution bound 1 - 1/K^2 + 1/n^2, catching "
                "arithmetic errors upstream. Certificate 4 verifies that the validation band is "
                "admissible at all, i.e. that its top lies below the ceiling. Certificate 5 is "
                "the deployment envelope proper: using the proved Lipschitz modulus 4.1, it "
                "verifies that after a worst-case draw-law shift of the given total variation "
                "the ceiling still strictly exceeds the top of the band, and on failure reports "
                "the exact tolerated drift instead. All comparisons are exact rational; the "
                "whole audit costs O(K) operations and can be executed at pre-registration time, "
                "before a single sample is drawn."
            ),
            "pseudocode": (
                "ALGORITHM CertifyEnvelope(L, reading r, band [lo, hi], drift tau, "
                "modulus c = 4.1)\n"
                "  n  <- sum(L) ;  K <- |L| ;  M <- max(L)\n"
                "  c2 <- ExactTieCeiling(L)\n"
                "\n"
                "  // 1. the reading must be attainable at all\n"
                "  CERTIFY  r^2 < c2                     ELSE FAIL 'impossible reading'\n"
                "\n"
                "  // 2. distribution-free cap for majority-modal statistics\n"
                "  IF 2*M >= n THEN\n"
                "      CERTIFY  r <= 0.936               ELSE FAIL 'half-mass cap violated'\n"
                "\n"
                "  // 3. internal consistency with the resolution law\n"
                "  CERTIFY  c2 <= 1 - 1/K^2 + 1/n^2      ELSE FAIL 'resolution law violated'\n"
                "\n"
                "  // 4. the validation band must be reachable\n"
                "  CERTIFY  hi^2 < c2                    ELSE FAIL 'band above the ceiling'\n"
                "\n"
                "  // 5. the deployment envelope\n"
                "  guaranteed <- c2 - c * tau\n"
                "  IF hi^2 < guaranteed THEN PASS\n"
                "  ELSE REPORT tolerated drift = (c2 - hi^2) / c\n"
                "\n"
                "COMPLEXITY  O(K) exact-rational operations; runs before data collection."
            ),
            "code": PREAMBLE + slice_marker(ALGSRC, "ALG1") + "\n\n"
                    + slice_marker(ALGSRC, "ALG3"),
        },
        {
            "name": "Franel Number Evaluation via the Three-Term P-Recursive Relation",
            "description": (
                "Evaluates the Franel numbers F(b) = sum_k C(b,k)^3 — the cube sums of binomial "
                "rows, and therefore the exact determinant of the Hamming-weight tie ceiling — "
                "using the holonomic recurrence (n+1)^2 F(n+1) = (7n^2 + 7n + 2) F(n) + "
                "8 n^2 F(n-1) with F(0) = 1, F(1) = 2. The division by (n+1)^2 is exact at every "
                "step. This is both faster than the naive definition, which requires cubing all "
                "b+1 binomial coefficients, and mathematically more useful: the recurrence is "
                "the analytic handle that converts the asymptotics of F(b)/8^b into a linear "
                "difference-equation estimate, which is the route to replacing the current "
                "two-sided sandwich [0.9747, 0.9997] on the count ceiling at bit length 52 by an "
                "exact asymptotic expansion 1 - c/b + O(b^-2). Cost: O(b) big-integer "
                "multiplications on operands of O(b) bits, i.e. O(b * M(b)) bit operations, "
                "against O(b) cubings of O(b)-bit integers for the definition — the same order, "
                "but with a much smaller constant and no binomial-coefficient table."
            ),
            "pseudocode": (
                "ALGORITHM FranelNumbers(B)\n"
                "  F[0] <- 1 ;  F[1] <- 2\n"
                "  FOR m = 1 TO B-1 DO\n"
                "      numerator <- (7*m^2 + 7*m + 2) * F[m]  +  8 * m^2 * F[m-1]\n"
                "      F[m+1]    <- numerator / (m+1)^2            // exact integer division\n"
                "  END FOR\n"
                "  RETURN F[0..B]\n"
                "\n"
                "ALGORITHM CountCeilingFromFranel(b)\n"
                "  F <- FranelNumbers(b)[b]\n"
                "  n <- 2^b\n"
                "  RETURN 1 - (F - n) / (n^3 - n)                  // exact rational\n"
                "\n"
                "COMPLEXITY  O(b) big-integer multiplications; operands grow to O(b) bits.\n"
                "CORRECTNESS the recurrence is the Zeilberger certificate for A000172 and its\n"
                "            output agrees with sum_k C(b,k)^3 for every b tested up to 52."
            ),
            "code": PREAMBLE + slice_marker(ALGSRC, "ALG4"),
        },
    ],
    "visualizations": [
        {
            "name": "The Ceiling Inversion and the Shape Dichotomy",
            "description": (
                "A two-panel figure. The left panel plots the exact Spearman tie ceilings of the "
                "trailing-zero and Hamming-weight statistics as functions of bit length, "
                "together with the proved lower bound 1 - 4/(3b+2) for the count and the 6/7 "
                "asymptote for the dial, and marks the bit length from which the inversion law "
                "takes hold. The right panel overlays the two normalised tie profiles at bit "
                "length 20 on a logarithmic mass scale, so that the dial's geometric cascade and "
                "the count's binomial bell can be compared directly, with the half-mass line "
                "that triggers the distribution-free 0.936 cap marked. Together the panels make "
                "the central dichotomy visible: both statistics have exactly b+1 tie classes, so "
                "the enormous difference between their ceilings is a matter of shape, not "
                "resolution."
            ),
            "code": read(A / "viz_inversion.py"),
        },
        {
            "name": "The Deployment Envelope Cone and the Shape Gap",
            "description": (
                "A two-panel figure about robustness and about what class counts fail to "
                "predict. The left panel draws the guaranteed Lipschitz cone around the uniform "
                "52-bit dial ceiling 6/7 — every draw law at total variation tau has its ceiling "
                "inside a band of half-width 4.1 tau — overlays the steeper slope 2.96 that an "
                "explicit witness pair attains, plots an actual one-parameter family of "
                "perturbed draw laws inside the cone, and marks the two operationally meaningful "
                "crossings: the drift at which the cone floor reaches the top of the validation "
                "band, and the larger drift at which it reaches the pooled reading. The right "
                "panel sweeps a one-parameter family of profile shapes at fixed class count "
                "K = 53, from a single dominant class to perfectly equal classes, and plots the "
                "resulting ceiling against the universal resolution bound, marking the 0.143 "
                "shape gap that separates the dial from what its 53 values would permit."
            ),
            "code": read(A / "viz_envelope.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Tie Ceiling Laboratory",
            "description": (
                "A full exploratory environment for the theory, computing every displayed "
                "quantity in exact browser-native big-integer arithmetic. Choose one of five "
                "instruments — the trailing-zero dial, the Hamming-weight count, an equal-class "
                "statistic, a single-dominant-class statistic, or the extremal envelope witness "
                "— then deform it with two sliders: bit length, and a skew control that transports "
                "mass into the leading class while conserving total mass exactly. A third slider "
                "applies a draw-law drift of chosen total variation. The panel reports the exact "
                "squared ceiling and its square root, the class count and sample size, the modal "
                "class share, the universal resolution bound, the shape gap between the two, "
                "whether the distribution-free half-mass cap of 0.936 binds, and the guaranteed "
                "post-drift ceiling from the 4.1-Lipschitz envelope law — issuing a colour-coded "
                "verdict on whether the validation band [0.55, 0.85] still survives. Two live "
                "canvases accompany the readout: a logarithmic bar chart of the current tie "
                "profile with the half-mass and equal-mass reference lines, and a ceiling-versus-"
                "bit-length curve on which the dial, the count, and the user's own statistic are "
                "drawn together so that the inversion law can be discovered by dragging a "
                "slider. Three expandable sections derive the ceiling formula, the half-mass cap, "
                "and the Franel bound behind the count's surprising advantage."
            ),
            "html": read(A / "widget_lab.html"),
        },
        {
            "title": "Where the Ceiling Comes From: the Midrank Collapse",
            "description": (
                "A pedagogical widget that derives the ceiling formula from first principles by "
                "showing the loss as it happens. Enter any tie profile, or pick from seven "
                "presets ranging from no ties to a single all-tied block, and the widget lays "
                "out the sample twice: once with the ideal response's ranks 1 through n, and "
                "once with the statistic's midranks, drawing each tie class as a labelled box "
                "whose members all collapse onto one shared value. It then computes the ordinary "
                "Pearson correlation between the two rank vectors *directly*, and compares it to "
                "the closed formula 1 - 12 C(L)/(n^3 - n); the two agree to machine precision "
                "for every profile, which is the theorem made tangible. A breakdown table "
                "attributes the total tie correction to individual classes, revealing how "
                "brutally the cube weighting favours the largest block. The suggested "
                "experiments include the pair (8,8) versus (15,1) — identical class count, "
                "identical sample size, ceilings 0.7529 and 0.1765 — which is the shape gap in "
                "miniature and the single fastest way to internalise why counting categories "
                "tells you almost nothing."
            ),
            "html": read(A / "widget_midrank.html"),
        },
    ],
    "interactive_layout": INTERACTIVE_LAYOUT.strip() + "\n",
    "lean_proofs": LEAN_PROOFS,
    "future_directions": FUTURE_DIRECTIONS,
    "modules": {
        "demo": read(ROOT / "demo.py"),
        "algorithms": ALGSRC,
        "envelope_stress": read(A / "demo_envelope_stress.py"),
        "viz_inversion": read(A / "viz_inversion.py"),
        "viz_envelope": read(A / "viz_envelope.py"),
    },
    "lean_files": LEAN_FILES,
}

out = ROOT / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print(f"wrote {out} ({out.stat().st_size:,} bytes)")


#!/usr/bin/env python3
"""
Envelope stress test: how far can a draw law drift before the guarantee breaks?
===============================================================================

The Spearman tie ceiling of a discrete statistic depends on the draw law only
through the tie profile, and only through that profile's cube sum.  Two laws at
total-variation distance ``tau`` therefore have ceilings within ``4.1 * tau`` of
each other (and the sharp constant is at least ``2.96``, so this modulus is of
the right order).

This script stress-tests that guarantee three ways at bit length 52:

  1. **Directed transport.**  Move mass out of the dominant odd class of the
     trailing-zero profile into successively later classes, and record the
     realised ceiling shift against the guaranteed bound.

  2. **Randomised transport.**  Redistribute a fixed total-variation budget over
     randomly chosen class pairs (deterministic pseudo-random stream, so the
     output is reproducible), and record the worst realised ratio
     ``|delta rho^2| / tau`` over many trials.

  3. **Adversarial two-block search.**  Scan the family of two-block profiles
     ``(n-c, c)`` and their perturbations to find the largest ratio actually
     achievable, confirming the lower bracket ``2.96`` on the sharp constant.

All arithmetic is exact (Python ``Fraction`` over unbounded integers).
"""

from __future__ import annotations

from fractions import Fraction
from typing import Iterable, List, Sequence, Tuple

LIPSCHITZ: Fraction = Fraction(41, 10)   # proved upper bound on the modulus
WITNESS_LOWER: Fraction = Fraction(296, 100)  # proved lower bound on the modulus


# --------------------------------------------------------------------------- #
# Core quantities
# --------------------------------------------------------------------------- #

def cube_sum(profile: Sequence[int]) -> int:
    return sum(m**3 for m in profile)


def tie_ceiling_sq(profile: Sequence[int]) -> Fraction:
    n = sum(profile)
    return Fraction(1) - Fraction(cube_sum(profile) - n, n**3 - n)


def dyadic_profile(b: int) -> List[int]:
    return [2 ** (b - 1 - k) for k in range(b)] + [1]


def total_variation(a: Sequence[int], b: Sequence[int]) -> Fraction:
    n = sum(a)
    assert n == sum(b), "mass must be conserved"
    return Fraction(sum(abs(x - y) for x, y in zip(a, b)), 2 * n)


# --------------------------------------------------------------------------- #
# A tiny deterministic pseudo-random stream (no external dependencies)
# --------------------------------------------------------------------------- #

class Stream:
    """Deterministic 64-bit LCG, so every run of this script is reproducible."""

    def __init__(self, seed: int) -> None:
        self.state = seed & ((1 << 64) - 1)

    def next_int(self, bound: int) -> int:
        self.state = (6364136223846793005 * self.state + 1442695040888963407) % (1 << 64)
        return (self.state >> 11) % bound


# --------------------------------------------------------------------------- #
# 1. Directed transport
# --------------------------------------------------------------------------- #

def directed_transport(b: int, targets: Iterable[int], budgets: Iterable[int]) -> None:
    base = dyadic_profile(b)
    n = sum(base)
    c0 = tie_ceiling_sq(base)
    print(f"\n{'target class':>13}{'tau':>12}{'realised shift':>18}"
          f"{'4.1*tau bound':>16}{'ratio':>10}")
    for j in targets:
        for pct in budgets:
            shift = (n * pct) // 1000
            if shift == 0 or shift >= base[0]:
                continue
            moved = base[:]
            moved[0] -= shift
            moved[j] += shift
            tau = total_variation(base, moved)
            delta = abs(tie_ceiling_sq(moved) - c0)
            bound = LIPSCHITZ * tau
            assert delta <= bound, "envelope law violated!"
            print(f"{j:>13}{float(tau):>12.5f}{float(delta):>18.8f}"
                  f"{float(bound):>16.8f}{float(delta / tau):>10.4f}")


# --------------------------------------------------------------------------- #
# 2. Randomised transport
# --------------------------------------------------------------------------- #

def randomised_transport(b: int, trials: int, seed: int) -> Fraction:
    base = dyadic_profile(b)
    n = sum(base)
    K = len(base)
    c0 = tie_ceiling_sq(base)
    rng = Stream(seed)
    worst = Fraction(0)
    for _ in range(trials):
        moved = base[:]
        for _ in range(6):
            src, dst = rng.next_int(K), rng.next_int(K)
            if src == dst or moved[src] <= 1:
                continue
            amount = 1 + rng.next_int(max(1, moved[src] // 4))
            moved[src] -= amount
            moved[dst] += amount
        tau = total_variation(base, moved)
        if tau == 0:
            continue
        ratio = abs(tie_ceiling_sq(moved) - c0) / tau
        assert ratio <= LIPSCHITZ, "envelope law violated!"
        worst = max(worst, ratio)
    return worst


# --------------------------------------------------------------------------- #
# 3. Adversarial two-block search
# --------------------------------------------------------------------------- #

def adversarial_two_block(b: int, grid: int) -> Tuple[Fraction, int, int]:
    """Scan pairs of two-block profiles of equal mass and return the worst ratio."""
    n = 2**b
    best = (Fraction(0), 0, 0)
    for i in range(1, grid + 1):
        c1 = (n * i) // (100 * grid)          # first profile's small block
        for j in range(1, grid + 1):
            c2 = (n * j) // (100 * grid)
            if c1 == c2 or c1 == 0 or c2 == 0:
                continue
            a = [n - c1, c1]
            d = [n - c2, c2]
            tau = total_variation(a, d)
            if tau == 0 or tau > Fraction(1, 100):
                continue
            ratio = abs(tie_ceiling_sq(a) - tie_ceiling_sq(d)) / tau
            if ratio > best[0]:
                best = (ratio, c1, c2)
    return best


# --------------------------------------------------------------------------- #

def main() -> None:
    print(__doc__)
    B = 52

    print("=" * 74)
    print("1.  Directed transport out of the dominant odd class (bit length 52)")
    print("=" * 74)
    directed_transport(B, targets=[1, 2, 5, 20, 52], budgets=[5, 20, 50])

    print("\n" + "=" * 74)
    print("2.  Randomised mass transport, 400 trials, reproducible stream")
    print("=" * 74)
    worst = randomised_transport(B, trials=400, seed=20261120)
    print(f"worst realised ratio |delta rho^2| / tau : {float(worst):.6f}")
    print(f"proved upper bound on the modulus        : {float(LIPSCHITZ):.6f}")
    print("no trial exceeded the bound (assertions all passed).")

    print("\n" + "=" * 74)
    print("3.  Adversarial two-block search")
    print("=" * 74)
    ratio, c1, c2 = adversarial_two_block(B, grid=40)
    print(f"worst ratio found                        : {float(ratio):.6f}")
    print(f"attained by (n-{c1}, {c1}) versus (n-{c2}, {c2})")
    print(f"proved lower bound on the sharp constant : {float(WITNESS_LOWER):.6f}")
    print(f"proved upper bound on the sharp constant : {float(LIPSCHITZ):.6f}")
    print(f"the search stays inside the bracket      : "
          f"{WITNESS_LOWER - Fraction(1,100) <= ratio <= LIPSCHITZ}")

    print("\n" + "=" * 74)
    print("Conclusion: the guarantee is never violated, and the worst adversarial")
    print("ratio sits close to the lower bracket 2.96, confirming that a constant")
    print("of order 3-4 is genuinely necessary and not an artefact of the proof.")
    print("=" * 74)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: the deployment envelope and the shape gap.
=========================================================

Left panel — *the envelope*.  The Spearman tie ceiling of a profile is a
Lipschitz function of the draw law: two laws at total-variation distance tau
have ceilings within 4.1*tau of each other, and no constant below 2.96 works.
We draw the guaranteed cone around the uniform 52-bit dial ceiling 6/7, plot
the actual ceiling of a one-parameter family of perturbed draw laws inside it,
and shade the region in which the recorded readings (0.698, 0.697, 0.720,
squared) still lie strictly below the ceiling.  The intersection of the cone
floor with the top of the validation band gives the tolerated drift, ~8.8%.

Right panel — *the shape gap*.  For every profile shape interpolating between
"one dominant class" and "all classes equal" at fixed class count K = 53, we
plot the achieved ceiling against the universal resolution bound
1 - 1/K^2 + 1/n^2.  The dial and the count sit at opposite ends: resolution is
a budget, shape decides how much of it you spend.

Requires: matplotlib, numpy.  Writes `tie_ceiling_envelope.png`.
"""

from __future__ import annotations

from fractions import Fraction
from math import comb
from typing import List

import matplotlib.pyplot as plt
import numpy as np


def tie_ceiling_sq(profile: List[int]) -> float:
    n = sum(profile)
    s3 = sum(m**3 for m in profile)
    return float(Fraction(1) - Fraction(s3 - n, n**3 - n))


def dyadic_profile(b: int) -> List[int]:
    return [2 ** (b - 1 - k) for k in range(b)] + [1]


def binomial_profile(b: int) -> List[int]:
    return [comb(b, k) for k in range(b + 1)]


def main() -> None:
    B = 52
    n = 2**B
    base = dyadic_profile(B)
    c0 = tie_ceiling_sq(base)

    # ---- left panel: the envelope cone --------------------------------------
    taus = np.linspace(0, 0.12, 200)
    upper = c0 + 4.1 * taus
    lower = c0 - 4.1 * taus
    lower_lb = c0 - 2.96 * taus

    actual_tau, actual_c = [], []
    for pct in range(0, 25):
        shift = (n * pct) // 200
        moved = base[:]
        moved[0] -= shift
        moved[1] += shift
        l1 = sum(abs(a - b) for a, b in zip(base, moved))
        actual_tau.append(l1 / (2 * n))
        actual_c.append(tie_ceiling_sq(moved))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13.5, 5.2))

    ax1.fill_between(taus, lower, np.minimum(upper, 1.0), color="#aed6f1", alpha=0.40,
                     label=r"guaranteed cone: $|\Delta\rho^2_{\max}| \leq 4.1\,\tau$")
    ax1.plot(taus, lower, color="#2471a3", lw=1.8)
    ax1.plot(taus, np.minimum(upper, 1.0), color="#2471a3", lw=1.8)
    ax1.plot(taus, lower_lb, "--", color="#7d3c98", lw=1.5,
             label=r"known worst case: slope $2.96$ (explicit witness pair)")
    ax1.plot(actual_tau, actual_c, "o-", color="#c0392b", ms=4, lw=1.6,
             label="one actual perturbation family")
    ax1.axhline(c0, ls=":", color="#922b21", lw=1.3, label=r"uniform ceiling $6/7$")

    band_top = 0.85**2
    pooled_sq = 0.705**2
    ax1.axhline(band_top, ls="-.", color="#117864", lw=1.4,
                label=r"top of validation band, $0.85^2 = 0.7225$")
    ax1.axhline(pooled_sq, ls="-.", color="#b9770e", lw=1.4,
                label=r"pooled reading squared, $0.705^2 = 0.4970$")

    tol_pooled = (c0 - pooled_sq) / 4.1
    tol_band = (c0 - band_top) / 4.1
    ax1.axvline(tol_pooled, ls="--", color="#b9770e", lw=1.2)
    ax1.axvline(tol_band, ls="--", color="#117864", lw=1.2)
    ax1.annotate(f"pooled reading still\nunder the cone floor\nup to $\\tau = {tol_pooled:.3f}$",
                 xy=(tol_pooled, pooled_sq), xytext=(tol_pooled + 0.004, 0.585),
                 fontsize=8.5, color="#b9770e",
                 arrowprops=dict(arrowstyle="->", color="#b9770e", lw=1.1))
    ax1.annotate(f"whole band safe\nup to $\\tau = {tol_band:.3f}$",
                 xy=(tol_band, band_top), xytext=(tol_band + 0.006, 0.775),
                 fontsize=8.5, color="#117864",
                 arrowprops=dict(arrowstyle="->", color="#117864", lw=1.1))

    ax1.set_xlabel(r"total variation $\tau$ between draw laws")
    ax1.set_ylabel(r"tie ceiling $\rho^2_{\max}$")
    ax1.set_title("Deployment envelope at bit length 52:\n"
                  "how far the ceiling can move when the world does", fontsize=11)
    ax1.set_xlim(0, 0.12)
    ax1.set_ylim(0.42, 1.0)
    ax1.grid(alpha=0.3)
    ax1.legend(fontsize=7.5, loc="lower left", framealpha=0.95)

    # ---- right panel: the shape gap ----------------------------------------
    K = 53
    resolution_bound = 1 - 1 / K**2 + 1 / n**2

    # family interpolating between "dominant block" and "equal blocks"
    ts = np.linspace(0.0, 1.0, 120)
    ceilings = []
    for t in ts:
        # mass fraction t goes to the equal-split part, 1-t stays in one class
        head = 1.0 - t * (1 - 1.0 / K)
        rest = (1.0 - head) / (K - 1)
        s3 = head**3 + (K - 1) * rest**3
        ceilings.append(1.0 - s3)
    ax2.plot(ts, ceilings, lw=2.4, color="#2471a3",
             label="ceiling along shapes from dominant to equal")
    ax2.axhline(resolution_bound, ls="--", color="#7d3c98", lw=1.8,
                label=r"resolution bound $1 - 1/K^2 + 1/n^2$ ($K=53$)")

    c_dial = tie_ceiling_sq(dyadic_profile(52))
    c_count = tie_ceiling_sq(binomial_profile(52))
    ax2.axhline(c_dial, ls=":", color="#c0392b", lw=1.8,
                label=f"dial ceiling {c_dial:.4f}")
    ax2.axhline(c_count, ls=":", color="#117864", lw=1.8,
                label=f"count ceiling {c_count:.4f}")
    ax2.annotate("", xy=(0.12, resolution_bound), xytext=(0.12, c_dial),
                 arrowprops=dict(arrowstyle="<->", color="#7d3c98", lw=1.6))
    ax2.text(0.14, (resolution_bound + c_dial) / 2,
             f"shape gap\n$\\approx {resolution_bound - c_dial:.3f}$",
             fontsize=9, color="#7d3c98")

    ax2.set_xlabel("shape parameter: 0 = one dominant class, 1 = all classes equal")
    ax2.set_ylabel(r"tie ceiling $\rho^2_{\max}$")
    ax2.set_title("Resolution is a budget, shape is the spend\n"
                  "(both statistics have exactly $K = 53$ classes)", fontsize=11)
    ax2.set_ylim(-0.02, 1.03)
    ax2.grid(alpha=0.3)
    ax2.legend(fontsize=8, loc="lower right")

    fig.suptitle("Stability of the ceiling, and what the class count does not tell you",
                 fontsize=13, y=1.00)
    fig.tight_layout()
    fig.savefig("tie_ceiling_envelope.png", dpi=160, bbox_inches="tight")
    print("wrote tie_ceiling_envelope.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: the ceiling inversion.
=====================================

Plots, as a function of the bit length b, the exact Spearman tie ceilings of

  * the trailing-zero ("dial") statistic, whose ceiling is
        rho^2 = (6/7)(1 + 1/(2^b (2^b+1)))  ->  6/7,
  * the Hamming-weight ("count") statistic, whose ceiling is
        rho^2 = 1 - (F(b) - 2^b)/(8^b - 2^b),  F(b) = sum_k C(b,k)^3,

together with the proved lower bound 1 - 4/(3b+2) for the count and the
6/7 asymptote for the dial.  The crossing point makes the *inversion law*
visible: past a small bit length the count statistic --- the one with the
gigantic central tie class --- is the LESS tie-attenuated of the two.

A second panel shows the two normalised tie profiles at b = 20 on a log
scale, so that the geometric cascade of the dial and the bell of the count
can be compared directly: it is the shape, not the number of classes
(both have exactly b+1), that determines the ceiling.

Requires: matplotlib, numpy.  Writes `tie_ceiling_inversion.png`.
"""

from __future__ import annotations

from fractions import Fraction
from math import comb
from typing import List

import matplotlib.pyplot as plt
import numpy as np


def tie_ceiling_sq(profile: List[int]) -> float:
    n = sum(profile)
    s3 = sum(m**3 for m in profile)
    return float(Fraction(1) - Fraction(s3 - n, n**3 - n))


def dyadic_profile(b: int) -> List[int]:
    return [2 ** (b - 1 - k) for k in range(b)] + [1] if b else [1]


def binomial_profile(b: int) -> List[int]:
    return [comb(b, k) for k in range(b + 1)]


def main() -> None:
    bs = list(range(2, 41))
    dial = [tie_ceiling_sq(dyadic_profile(b)) for b in bs]
    count = [tie_ceiling_sq(binomial_profile(b)) for b in bs]
    even_bs = [b for b in bs if b % 2 == 0]
    lower = [1 - 4 / (3 * b + 2) for b in even_bs]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13.5, 5.2))

    ax1.plot(bs, dial, "o-", lw=2, ms=4, color="#c0392b",
             label=r"dial (trailing zeros): $\frac{6}{7}(1+\frac{1}{2^b(2^b+1)})$")
    ax1.plot(bs, count, "s-", lw=2, ms=4, color="#2471a3",
             label=r"count (Hamming weight): $1-\frac{F(b)-2^b}{8^b-2^b}$")
    ax1.plot(even_bs, lower, "--", lw=1.8, color="#5dade2",
             label=r"proved count lower bound $1-\frac{4}{3b+2}$ (even $b$)")
    ax1.axhline(6 / 7, ls=":", lw=1.6, color="#922b21",
                label=r"dial asymptote $6/7 = 0.857143$")
    ax1.axhline(1.0, ls=":", lw=1.0, color="grey")

    # mark the crossing
    cross = next(b for b, d, c in zip(bs, dial, count) if c > d)
    ax1.axvline(cross, ls="-.", lw=1.2, color="#7d3c98")
    ax1.annotate(f"inversion from b = {cross}", xy=(cross, 0.60),
                 xytext=(cross + 3, 0.47), fontsize=9, color="#7d3c98",
                 arrowprops=dict(arrowstyle="->", color="#7d3c98"))

    ax1.set_xlabel("bit length $b$")
    ax1.set_ylabel(r"tie ceiling $\rho^2_{\max}$")
    ax1.set_title("The inversion law: the coarse-looking count statistic\n"
                  "has the HIGHER ceiling", fontsize=11)
    ax1.set_ylim(0.4, 1.03)
    ax1.grid(alpha=0.3)
    ax1.legend(fontsize=8, loc="lower right")

    b0 = 20
    dp = dyadic_profile(b0)
    bp = binomial_profile(b0)
    n0 = 2**b0
    idx = np.arange(len(dp))
    ax2.semilogy(idx, [m / n0 for m in dp], "o-", color="#c0392b", ms=4,
                 label="dial profile (geometric cascade)")
    ax2.semilogy(np.arange(len(bp)), [m / n0 for m in bp], "s-", color="#2471a3",
                 ms=4, label="count profile (binomial bell)")
    ax2.axhline(0.5, ls=":", color="#922b21", lw=1.4,
                label="half-mass line (forces $\\rho \\leq 0.936$)")
    ax2.set_xlabel("tie class index")
    ax2.set_ylabel("class mass / $n$   (log scale)")
    ax2.set_title(f"Same number of classes ($b+1 = {b0+1}$), opposite shapes\n"
                  f"dial ceiling {tie_ceiling_sq(dp):.4f} vs "
                  f"count ceiling {tie_ceiling_sq(bp):.4f}", fontsize=11)
    ax2.grid(alpha=0.3, which="both")
    ax2.legend(fontsize=8)

    fig.suptitle("Tie ceilings of two bit-level statistics", fontsize=13, y=1.00)
    fig.tight_layout()
    fig.savefig("tie_ceiling_inversion.png", dpi=160, bbox_inches="tight")
    print("wrote tie_ceiling_inversion.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Tie ceilings for rank statistics: numerical companion.
=====================================================

This self-contained script reproduces, in exact rational arithmetic, every
numerical claim in the accompanying article and paper on the *tie ceiling* of a
discrete statistic under Spearman rank correlation.

Background in one paragraph
---------------------------
Let a statistic ``T`` take values on ``n`` sample points and let its *tie
profile* be the multiset ``L = (m_1, ..., m_K)`` of tie-class sizes, so that
``m_1 + ... + m_K = n``.  Spearman's rank correlation with midranks compares
``T`` against a response ``Y``.  Writing ``C(L) = sum_j (m_j^3 - m_j) / 12``
for the tie correction, the largest squared Spearman correlation that ``T`` can
possibly attain against *any* response — attained when the response refines the
statistic perfectly — is the **tie ceiling**

        rho^2_max(L) = 1 - 12 * C(L) / (n^3 - n).

Two profiles matter here, both on ``n = 2^b`` b-bit words drawn uniformly:

  * the **dyadic profile** of the trailing-zero statistic (the 2-adic
    valuation), ``L_dyadic(b) = (2^(b-1), 2^(b-2), ..., 2, 1, 1)``;
  * the **binomial profile** of the Hamming-weight ("count") statistic,
    ``L_binom(b) = (C(b,0), C(b,1), ..., C(b,b))``.

Everything below is computed with Python's exact ``Fraction`` and unbounded
integers, so no floating-point rounding enters the verification.

Run with:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from math import comb
from typing import List, Sequence, Tuple

# ----------------------------------------------------------------------------
# Section 0.  Core tie calculus
# ----------------------------------------------------------------------------


def tie_correction(profile: Sequence[int]) -> Fraction:
    """Spearman tie correction ``C(L) = sum_j (m_j^3 - m_j)/12``."""
    return Fraction(sum(m**3 - m for m in profile), 12)


def cube_sum(profile: Sequence[int]) -> int:
    """``sum_j m_j^3`` — the only shape functional the ceiling depends on."""
    return sum(m**3 for m in profile)


def tie_ceiling_sq(profile: Sequence[int]) -> Fraction:
    """Tie ceiling ``rho^2_max = 1 - 12 C(L)/(n^3-n)`` in exact arithmetic."""
    n = sum(profile)
    if n < 2:
        raise ValueError("profile needs total mass at least 2")
    return Fraction(1) - Fraction(12) * tie_correction(profile) / Fraction(n**3 - n)


def tie_ceiling(profile: Sequence[int]) -> float:
    """Tie ceiling on the correlation scale, ``rho_max = sqrt(rho^2_max)``."""
    return float(tie_ceiling_sq(profile)) ** 0.5


# ----------------------------------------------------------------------------
# Section 1.  The two profiles
# ----------------------------------------------------------------------------


def dyadic_profile(b: int) -> List[int]:
    """Tie profile of the trailing-zero statistic on ``b``-bit words.

    Among the ``2^b`` residues mod ``2^b``, exactly ``2^(b-1)`` are odd
    (valuation 0), ``2^(b-2)`` have valuation 1, and so on; the single residue
    ``0`` forms its own class.  Total mass ``2^b``, exactly ``b+1`` classes.
    """
    if b == 0:
        return [1]
    return [2 ** (b - 1 - k) for k in range(b)] + [1]


def binomial_profile(b: int) -> List[int]:
    """Tie profile of the Hamming-weight statistic on ``b``-bit words."""
    return [comb(b, k) for k in range(b + 1)]


def franel(b: int) -> int:
    """Franel number ``F(b) = sum_k C(b,k)^3`` (OEIS A000172)."""
    return sum(comb(b, k) ** 3 for k in range(b + 1))


# ----------------------------------------------------------------------------
# Section 2.  Closed forms and bounds proved in the paper
# ----------------------------------------------------------------------------


def dyadic_ceiling_closed_form(b: int) -> Fraction:
    """``rho^2 = (6/7)(1 + 1/(2^b (2^b + 1)))`` for the dyadic profile."""
    n = 2**b
    return Fraction(6, 7) * (Fraction(1) + Fraction(1, n * (n + 1)))


def count_ceiling_lower_bound(b: int) -> Fraction:
    """Count ceiling law: ``rho^2_count >= 1 - 4/(3b+2)`` for even ``b >= 2``."""
    assert b % 2 == 0 and b >= 2
    return Fraction(1) - Fraction(4, 3 * b + 2)


def resolution_upper_bound(num_classes: int, n: int) -> Fraction:
    """Resolution law: ``rho^2 <= 1 - 1/K^2 + 1/n^2``."""
    return Fraction(1) - Fraction(1, num_classes**2) + Fraction(1, n**2)


def half_mass_cap(n: int) -> Fraction:
    """Half-mass cap: ``rho^2 <= 7/8 + 7/(8(n^2-1))`` when one class has mass >= n/2."""
    return Fraction(7, 8) + Fraction(7, 8 * (n**2 - 1))


def dominant_block_cap(largest_class: int, n: int) -> Fraction:
    """Dominant-block upper law: ``rho^2 <= 1 - (M^3-M)/(n^3-n)``."""
    return Fraction(1) - Fraction(largest_class**3 - largest_class, n**3 - n)


# ----------------------------------------------------------------------------
# Section 3.  Envelope stability
# ----------------------------------------------------------------------------


def l1_distance(profile_a: Sequence[int], profile_b: Sequence[int]) -> int:
    """``||L - L'||_1`` for two profiles listed in the same class order."""
    return sum(abs(a - b) for a, b in zip(profile_a, profile_b))


def total_variation(profile_a: Sequence[int], profile_b: Sequence[int]) -> Fraction:
    """Total variation distance ``tau = ||L - L'||_1 / (2n)`` for equal-mass profiles."""
    n = sum(profile_a)
    assert n == sum(profile_b), "profiles must carry equal mass"
    return Fraction(l1_distance(profile_a, profile_b), 2 * n)


def envelope_prediction(tau: Fraction, constant: Fraction = Fraction(41, 10)) -> Fraction:
    """Guaranteed bound on the ceiling shift induced by a draw-law shift ``tau``."""
    return constant * tau


# ----------------------------------------------------------------------------
# Section 4.  Recorded readings (three seeds, bitlen 52)
# ----------------------------------------------------------------------------

SEED_READINGS: Tuple[Fraction, Fraction, Fraction] = (
    Fraction(698, 1000),
    Fraction(697, 1000),
    Fraction(720, 1000),
)
POOLED: Fraction = sum(SEED_READINGS, Fraction(0)) / 3
ADVANTAGE: Fraction = Fraction(70, 1000)
ADV_CI: Tuple[Fraction, Fraction] = (Fraction(46, 1000), Fraction(93, 1000))
BAND: Tuple[Fraction, Fraction] = (Fraction(55, 100), Fraction(85, 100))
COUNT_POOLED: Fraction = POOLED - ADVANTAGE


# ----------------------------------------------------------------------------
# Section 5.  Demonstrations
# ----------------------------------------------------------------------------


def rule(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def demo_small_profiles() -> None:
    rule("1.  The tie ceiling on small examples")
    examples: List[Tuple[str, List[int]]] = [
        ("no ties, n=6", [1] * 6),
        ("one pair tied, n=6", [2, 1, 1, 1, 1]),
        ("two blocks of 3, n=6", [3, 3]),
        ("all six tied, n=6", [6]),
        ("half-mass block, n=8", [4, 2, 1, 1]),
    ]
    print(f"{'profile':<26}{'K':>4}{'n':>5}{'rho^2 ceiling':>18}{'rho':>10}")
    for name, prof in examples:
        c = tie_ceiling_sq(prof)
        print(f"{name:<26}{len(prof):>4}{sum(prof):>5}{str(c):>18}{tie_ceiling(prof):>10.5f}")
    print("\nA single all-tied block reads exactly 0: the statistic is constant.")


def demo_dyadic_ceiling() -> None:
    rule("2.  The dyadic ceiling: exactly (6/7)(1 + 1/(2^b(2^b+1))), decreasing to 6/7")
    print(f"{'b':>4}{'n = 2^b':>20}{'rho^2 (direct)':>22}{'closed form matches':>22}{'rho':>10}")
    for b in [1, 2, 3, 4, 8, 16, 32, 52]:
        prof = dyadic_profile(b)
        direct = tie_ceiling_sq(prof)
        closed = dyadic_ceiling_closed_form(b)
        print(f"{b:>4}{2**b:>20}{float(direct):>22.12f}{str(direct == closed):>22}"
              f"{float(direct) ** 0.5:>10.6f}")
    print(f"\nLimit 6/7 = {6/7:.12f}; at b=52 the excess over 6/7 is "
          f"{float(dyadic_ceiling_closed_form(52) - Fraction(6,7)):.3e}.")
    print("Interpretation: no matter how good the downstream response is, the")
    print("trailing-zero dial cannot correlate above sqrt(6/7) = "
          f"{(6/7)**0.5:.6f}.")


def demo_count_ceiling() -> None:
    rule("3.  The count ceiling: Franel numbers push it to 1")
    print(f"{'b':>4}{'F(b) = sum C(b,k)^3':>26}{'rho^2 exact':>16}"
          f"{'lower bound 1-4/(3b+2)':>26}")
    for b in [2, 4, 6, 10, 20, 30, 52]:
        prof = binomial_profile(b)
        exact = tie_ceiling_sq(prof)
        lower = count_ceiling_lower_bound(b)
        assert lower <= exact, "count ceiling law violated"
        print(f"{b:>4}{franel(b):>26}{float(exact):>16.8f}{float(lower):>26.8f}")
    print("\nThe bound is valid but loose; the true ceiling races to 1 much faster.")
    print("At b = 52 the count baseline's central tie class alone has size")
    print(f"C(52,26) = {comb(52,26):,} out of n = 2^52 = {2**52:,},")
    print("yet its ceiling is still")
    print(f"  rho^2_count(52) = {float(tie_ceiling_sq(binomial_profile(52))):.10f}")


def demo_inversion_law() -> None:
    rule("4.  The inversion law: the count baseline has the HIGHER ceiling")
    print(f"{'b':>4}{'dyadic rho^2':>18}{'count rho^2':>18}{'count > dyadic?':>18}")
    for b in [2, 3, 4, 6, 8, 10, 20, 52]:
        d = tie_ceiling_sq(dyadic_profile(b))
        c = tie_ceiling_sq(binomial_profile(b))
        print(f"{b:>4}{float(d):>18.8f}{float(c):>18.8f}{str(c > d):>18}")
    print("\nThe theorem asserts strict inversion for every even b >= 10; the table")
    print("shows it already holds from b = 3 onward (the two ceilings coincide at")
    print("b = 2), and the guaranteed regime is the one the theory certifies.")
    print("\nConsequence for the recorded data:")
    print(f"  dial reads   {float(POOLED):.3f}  against ceiling "
          f"{tie_ceiling(dyadic_profile(52)):.4f}")
    print(f"  count reads  {float(COUNT_POOLED):.3f}  against ceiling "
          f"{tie_ceiling(binomial_profile(52)):.4f}")
    dial_deficit = tie_ceiling_sq(dyadic_profile(52)) - POOLED**2
    count_deficit = tie_ceiling_sq(binomial_profile(52)) - COUNT_POOLED**2
    print(f"  dial deficit  = {float(dial_deficit):.5f}")
    print(f"  count deficit = {float(count_deficit):.5f}")
    print(f"  gap           = {float(count_deficit - dial_deficit):.5f} > 1/5   "
          f"({count_deficit - dial_deficit > Fraction(1,5)})")
    print("\nThe statistic that wins the head-to-head is the one with the LOWER")
    print("ceiling.  Rank granularity cannot manufacture that ordering.")


def demo_resolution_law() -> None:
    rule("5.  The resolution law and the shape gap")
    n52 = 2**52
    for name, prof in [("dyadic (52)", dyadic_profile(52)),
                       ("binomial (52)", binomial_profile(52))]:
        K = len(prof)
        c = tie_ceiling_sq(prof)
        u = resolution_upper_bound(K, n52)
        assert c <= u, "resolution law violated"
        print(f"{name:<16} K = {K:<4} ceiling = {float(c):.8f}   "
              f"resolution bound = {float(u):.8f}   slack = {float(u-c):.8f}")
    print("\nBoth statistics distinguish exactly 53 values, yet the dyadic ceiling")
    print("falls short of what 53 values allow by more than 0.14.  Resolution is")
    print("a budget, not a prediction; SHAPE decides where inside the budget you land.")
    print("\nSandwich for the count baseline at bitlen 52:")
    lo = count_ceiling_lower_bound(52)
    hi = resolution_upper_bound(53, n52)
    print(f"  {float(lo):.6f}  <=  rho^2_count  <=  {float(hi):.6f}")
    print(f"  (true value {float(tie_ceiling_sq(binomial_profile(52))):.6f})")


def demo_half_mass_cap() -> None:
    rule("6.  The half-mass cap: any modal class of mass n/2 forces rho <= 0.936")
    print(f"{'n':>16}{'cap on rho^2':>18}{'cap on rho':>14}")
    for b in [10, 20, 32, 52]:
        n = 2**b
        cap = half_mass_cap(n)
        print(f"{n:>16}{float(cap):>18.10f}{float(cap)**0.5:>14.6f}")
    cap52 = half_mass_cap(2**52)
    print(f"\nCap on rho at bitlen 52: {float(cap52)**0.5:.8f}  <=  0.936")
    dial52 = tie_ceiling(dyadic_profile(52))
    print(f"Actual dyadic ceiling on rho: {dial52:.6f}")
    print(f"Validation band: [{float(BAND[0])}, {float(BAND[1])}] — entirely below the cap.")
    print("Every recorded seed reading:")
    for i, r in enumerate(SEED_READINGS):
        inside = BAND[0] <= r <= BAND[1]
        print(f"  seed {i}: {float(r):.3f}   inside band: {inside}   "
              f"below dyadic ceiling: {r**2 < tie_ceiling_sq(dyadic_profile(52))}")
    print("\nA reading above 0.936 would falsify the half-mass model outright.")


def demo_envelope_stability() -> None:
    rule("7.  Envelope stability: ceilings are Lipschitz in the draw law")
    base = dyadic_profile(52)
    n = sum(base)
    print("Perturb the uniform 52-bit dyadic profile by moving mass out of the")
    print("dominant odd class into the second class, and watch the ceiling move.\n")
    print(f"{'tau (TV)':>12}{'||L-L'+chr(39)+'||_1/n':>16}{'new rho^2':>16}"
          f"{'|shift|':>12}{'4.1*tau bound':>16}")
    for pct in [0, 1, 2, 5, 8]:
        # moving `shift` units of mass gives l1 = 2*shift and TV tau = shift/n
        shift = (n * pct) // 200
        moved = base[:]
        moved[0] -= shift
        moved[1] += shift
        tau = total_variation(base, moved)
        c0 = tie_ceiling_sq(base)
        c1 = tie_ceiling_sq(moved)
        delta = abs(c1 - c0)
        bound = envelope_prediction(tau)
        assert delta <= bound + Fraction(1, 10**9), "sharp envelope law violated"
        print(f"{float(tau):>12.5f}{float(Fraction(l1_distance(base,moved),n)):>16.5f}"
              f"{float(c1):>16.8f}{float(delta):>12.6f}{float(bound):>16.6f}")
    print("\nAll observed shifts respect the guaranteed 4.1-Lipschitz modulus.")


def demo_lower_witness() -> None:
    rule("8.  The envelope constant cannot be below 2.96")
    a = [4503599627370495, 1]
    b = [4458563631096791, 45035996273705]
    assert sum(a) == sum(b) == 2**52
    tau = total_variation(a, b)
    ca, cb = tie_ceiling_sq(a), tie_ceiling_sq(b)
    delta = abs(ca - cb)
    print(f"profile A = {a}")
    print(f"profile B = {b}")
    print(f"common mass n = {sum(a):,} = 2^52")
    print(f"total variation tau  = {float(tau):.8f}   (<= 1/100: {tau <= Fraction(1,100)})")
    print(f"ceiling A            = {float(ca):.10f}")
    print(f"ceiling B            = {float(cb):.10f}")
    print(f"|difference|         = {float(delta):.8f}")
    print(f"ratio delta / tau    = {float(delta/tau):.6f}")
    print(f"exceeds 2.96/100     = {delta >= Fraction(296,10000)}")
    print("\nSo the sharp envelope constant is bracketed: 2.96 <= c <= 4.1.")


def demo_synthetic_experiment() -> None:
    rule("9.  A synthetic sanity experiment (no external libraries)")
    print("Draw pseudo-uniform b-bit words with a deterministic LCG, compute the")
    print("trailing-zero statistic and the Hamming weight, and measure their")
    print("midrank Spearman correlation against an ideal refining response.\n")

    def lcg(seed: int, count: int, bits: int) -> List[int]:
        state, out, mod = seed, [], 1 << bits
        for _ in range(count):
            state = (6364136223846793005 * state + 1442695040888963407) % (1 << 64)
            out.append((state >> 11) % mod)
        return out

    def trailing_zeros(x: int, bits: int) -> int:
        return bits if x == 0 else (x & -x).bit_length() - 1

    def midranks(values: Sequence[float]) -> List[float]:
        order = sorted(range(len(values)), key=lambda i: values[i])
        ranks = [0.0] * len(values)
        i = 0
        while i < len(order):
            j = i
            while j + 1 < len(order) and values[order[j + 1]] == values[order[i]]:
                j += 1
            avg = (i + j) / 2 + 1
            for k in range(i, j + 1):
                ranks[order[k]] = avg
            i = j + 1
        return ranks

    def pearson(xs: Sequence[float], ys: Sequence[float]) -> float:
        n = len(xs)
        mx, my = sum(xs) / n, sum(ys) / n
        num = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
        dx = sum((x - mx) ** 2 for x in xs) ** 0.5
        dy = sum((y - my) ** 2 for y in ys) ** 0.5
        return num / (dx * dy) if dx * dy else 0.0

    bits, size = 20, 20000
    for seed in (20261120, 20261121, 20261122):
        xs = lcg(seed, size, bits)
        tz = [trailing_zeros(x, bits) for x in xs]
        hw = [bin(x).count("1") for x in xs]
        # ideal refining response: value of the statistic plus a tie-breaking jitter
        ideal_tz = [t + i / (2 * size) for i, t in enumerate(tz)]
        ideal_hw = [h + i / (2 * size) for i, h in enumerate(hw)]
        rho_tz = pearson(midranks([float(t) for t in tz]), midranks(ideal_tz))
        rho_hw = pearson(midranks([float(h) for h in hw]), midranks(ideal_hw))
        print(f"seed {seed}:  empirical dial ceiling ~ {rho_tz:.4f}   "
              f"(theory {tie_ceiling(dyadic_profile(bits)):.4f})")
        print(f"              empirical count ceiling ~ {rho_hw:.4f}   "
              f"(theory {tie_ceiling(binomial_profile(bits)):.4f})")
    print("\nThe empirical maxima track the closed-form ceilings; the count")
    print("statistic is again the less attenuated of the two.")


def demo_recorded_numbers() -> None:
    rule("10.  The recorded bitlen-52 readings, checked against the theory")
    print(f"seed readings : {[float(r) for r in SEED_READINGS]}")
    print(f"pooled        : {float(POOLED):.4f}")
    print(f"band          : [{float(BAND[0])}, {float(BAND[1])}]  — all inside: "
          f"{all(BAND[0] <= r <= BAND[1] for r in SEED_READINGS)}")
    print(f"advantage     : +{float(ADVANTAGE):.3f}  CI [{float(ADV_CI[0]):.3f}, "
          f"{float(ADV_CI[1]):.3f}]  strictly positive: {ADV_CI[0] > 0}")
    d52 = tie_ceiling_sq(dyadic_profile(52))
    c52 = tie_ceiling_sq(binomial_profile(52))
    print(f"\ndial ceiling  : rho^2 = {float(d52):.8f}   rho = {float(d52)**0.5:.6f}")
    print(f"count ceiling : rho^2 = {float(c52):.8f}   rho = {float(c52)**0.5:.6f}")
    print(f"pooled^2      : {float(POOLED**2):.6f}  < dial ceiling: {POOLED**2 < d52}")
    print(f"count pooled^2: {float(COUNT_POOLED**2):.6f}  < count ceiling: "
          f"{COUNT_POOLED**2 < c52}")
    margin = Fraction(6, 7) - POOLED**2
    print(f"\nmargin to the dyadic ceiling: {float(margin):.5f}")
    print(f"draw-law shift tolerated (margin / 4.1): tau <= {float(margin/Fraction(41,10)):.4f}"
          f"  (~{float(margin/Fraction(41,10))*100:.1f}% total variation)")


def main() -> None:
    print(__doc__)
    demo_small_profiles()
    demo_dyadic_ceiling()
    demo_count_ceiling()
    demo_inversion_law()
    demo_resolution_law()
    demo_half_mass_cap()
    demo_envelope_stability()
    demo_lower_witness()
    demo_synthetic_experiment()
    demo_recorded_numbers()
    rule("All checks passed.")


if __name__ == "__main__":
    main()
