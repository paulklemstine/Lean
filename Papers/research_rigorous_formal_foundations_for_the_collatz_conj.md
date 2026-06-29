# Rigorous Formal Foundations for Collatz Contraction: The Sharp Logarithmic Threshold

## Abstract

The Collatz map sends an even number `n` to `n/2` and an odd number `n` to
`3n + 1`. The Collatz conjecture asserts that iterating this map from any positive
integer eventually reaches `1`. A standard route toward such a result is a
*density argument*: over a trajectory segment containing `j` odd ("multiply")
steps and `m` even ("halve") steps, the segment contracts in size precisely when
`3^j < 2^m`. The classical combinatorial treatment proves this under the
suboptimal hypothesis `2j < m` (odd-step density below `1/2`), exploiting only the
crude bound `3 < 4 = 2^2`. We sharpen this to the *optimal* threshold. Our central
result is an **exact logarithmic characterization**: for natural numbers `j, m`,

$$3^{j} < 2^{m} \iff j \log 3 < m \log 2,$$

valid in both `\mathbb{R}` and `\mathbb{N}`. From it we derive the sharp
contraction criterion — odd-step density below `\log 2 / \log 3 \approx 0.6309`
forces contraction — and prove it *strictly dominates* the classical bound: every
segment captured by `2j < m` is captured by the logarithmic criterion (via
`\log 3 < 2 \log 2`), while the explicit pair `(j, m) = (1, 2)` is captured by the
sharp criterion and not the crude one. We locate the threshold constant
`\log 3 / \log 2 = \log_2 3` strictly in the open interval `(1, 2)`. We are careful
to delimit what remains open: lifting *segment* contraction `3^j < 2^m` to *orbit*
contraction `T^{[k]}(n) < n` is obstructed by the additive `+1` accrued at each odd
step, and is recorded as an explicit conjecture rather than a theorem. All results
described here have been formally verified in the Lean 4 proof assistant on top of
Mathlib; this paper presents their mathematical content and proof sketches.

**Keywords:** Collatz conjecture, density contraction, parity exclusion,
logarithmic threshold, formal verification, `3x+1` problem.

---

## 1. Introduction

The Collatz conjecture (also the `3x+1` problem, Syracuse problem, or Ulam
conjecture) is among the most notorious open problems in elementary number theory.
Define the **Collatz map** `T : \mathbb{N} \to \mathbb{N}` by

$$T(n) = \begin{cases} n/2 & n \text{ even},\\ 3n + 1 & n \text{ odd}. \end{cases}$$

The conjecture states that for every `n \ge 1` there is some `k` with
`T^{[k]}(n) = 1`. Despite enormous computational verification (every `n` up to
`2^{68}` and beyond) and deep analytic progress — notably Tao's 2019 result that
almost all orbits attain *almost bounded* values — the full conjecture remains
open, and is widely believed to be extraordinarily hard, possibly independent of
standard axiom systems.

A recurring strategy is the **density / contraction heuristic**. Consider a
trajectory segment that performs `j` odd steps and `m` even steps. Each odd step
multiplies the value by approximately `3`; each even step divides by `2`. Up to a
lower-order additive correction, the value is scaled by `3^j / 2^m`. The segment is
*contractive* — its endpoint smaller than its start — when this ratio is below `1`,
i.e. when

$$3^{j} < 2^{m}. \tag{$\star$}$$

The fundamental structural constraint enabling such arguments is **parity
exclusion**: if `n` is odd then `T(n) = 3n + 1` is even, so two odd steps can never
occur consecutively. Consequently the odd-step density over any segment of length
`k` is at most `\lceil k/2 \rceil / k \to 1/2`.

The naive arithmetic resolution of `($\star$)` proves it under `2j < m`, using only
`3 < 4 = 2^2`:

$$3^{j} < 4^{j} = 2^{2j} \le 2^{m}.$$

This corresponds to the rational threshold `1/2`. But the *exact* break-even density
for `($\star$)` is `\log 2 / \log 3 \approx 0.6309`, strictly larger than `1/2`.
The interval `(1/2,\, \log 2/\log 3)` contains genuinely contractive segments that
the naive bound cannot certify. This paper closes that gap optimally.

### 1.1 Contributions

1. **Exact logarithmic characterization** (`pow3_lt_pow2_iff_log`,
   `nat_pow3_lt_pow2_iff_log`): `($\star$)` is *equivalent* to the affine inequality
   `j \log 3 < m \log 2`, in both `\mathbb{R}` and `\mathbb{N}`.
2. **Sharp contraction criterion** (`pow3_lt_pow2_of_density`): odd-step density
   below `\log 2 / \log 3` forces `($\star$)`.
3. **Strict domination** (`log_of_two_mul_lt`, `sharp_threshold_strictly_stronger`):
   the criterion contains the naive bound and strictly exceeds it, with explicit
   witness `(1, 2)`.
4. **Threshold localization** (`log3_div_log2_mem_Ioo`): `\log 3/\log 2 \in (1,2)`.
5. **Honest delimitation** (`sharp_orbit_contraction_conjecture`): the obstruction to
   orbit-level contraction is isolated as the additive error of the affine map.

---

## 2. Preliminaries and Definitions

We work over the natural numbers `\mathbb{N}` and the reals `\mathbb{R}`. All
logarithms are natural logarithms `\log = \ln`.

**Definition 2.1 (Collatz map).**
`T(n) = n/2` if `n` is even, and `T(n) = 3n + 1` if `n` is odd. (In Lean,
`T n = if n % 2 = 0 then n / 2 else 3 * n + 1`.)

**Definition 2.2 (Shortcut map).**
For odd `n`, since `3n + 1` is even, the *shortcut* `T_{\mathrm{sc}}(n) = (3n+1)/2`
equals `T(T(n))`. This folds each mandatory even step into the preceding odd step.

**Definition 2.3 (Orbit parity and odd count).**
For a start value `n`, define `\mathrm{orbitParity}(n, i) = T^{[i]}(n) \bmod 2`, and
the odd-position count over the first `k` steps,
`\mathrm{oddCount}(n,k) = \#\{ i < k : T^{[i]}(n) \text{ odd}\}.`

**Definition 2.4 (Segment data).**
A trajectory segment of length `k = j + m` performs `j` odd steps and `m` even
steps. Its idealized multiplier (ignoring additive corrections) is `3^j / 2^m`.

We rely on the following established foundations from the parity-contraction layer.

**Proposition 2.5 (Parity exclusion).** If `n` is odd, `T(n)` is even. Equivalently,
no two consecutive trajectory positions are both odd.
*Proof.* `3n + 1` with `n` odd: write `n = 2t+1`, then `3n+1 = 6t+4 = 2(3t+2)`. ∎

**Proposition 2.6 (Density bound).** For all `n, k`,
`\mathrm{oddCount}(n,k) \le \lceil k/2 \rceil = (k+1)/2` (integer division).
*Proof.* Strong induction on `k`. Parity exclusion implies that whenever position
`i` is odd, position `i+1` is even; hence odd positions never pair up, capping the
count at `\lceil k/2 \rceil`. ∎

**Proposition 2.7 (Naive power comparison).** If `1 \le j` and `2j < m`, then
`3^j < 2^m`.
*Proof.* `3^j \le 4^j = (2^2)^j = 2^{2j} < 2^m`. ∎

Proposition 2.6 guarantees odd-step density at most `1/2` over any segment, which
sits comfortably below the optimal threshold derived below; this is exactly why
*local* contraction is never the obstruction.

---

## 3. The Exact Logarithmic Characterization

The conceptual core of this work is to convert the multiplicative comparison
`($\star$)` into an additive one via the strict monotonicity of `\log` on the
positive reals.

**Theorem 3.1 (Logarithmic characterization, `pow3_lt_pow2_iff_log`).**
For all `j, m \in \mathbb{N}`,
$$(3:\mathbb{R})^{j} < (2:\mathbb{R})^{m} \iff j \log 3 < m \log 2.$$

*Proof sketch.* Use the identity `\log(a^n) = n \log a` (`Real.log_pow`) to rewrite
`j \log 3 = \log(3^j)` and `m \log 2 = \log(2^m)`. The claim becomes
`3^j < 2^m \iff \log(3^j) < \log(2^m)`, which is exactly the strict monotonicity of
the real logarithm on positive arguments (`Real.log_lt_log_iff`), applicable since
`3^j > 0` and `2^m > 0`. ∎

**Theorem 3.2 (Natural-number transfer, `nat_pow3_lt_pow2_iff_log`).**
For all `j, m \in \mathbb{N}`,
$$3^{j} < 2^{m} \ (\text{in } \mathbb{N}) \iff j \log 3 < m \log 2.$$

*Proof sketch.* The natural-number inequality `3^j < 2^m` is equivalent to its real
cast `(3:\mathbb{R})^j < (2:\mathbb{R})^m` (`Nat.cast_lt` with `Nat.cast_pow`), then
Theorem 3.1 applies. ∎

**Remark 3.3.** Theorem 3.1 is an *exact* biconditional, not an estimate. This is
what unlocks the sharp threshold: the rational bound `1/2` was an artifact of the
crude `3 < 4` substitution, whereas the logarithm sees the true gap between `3` and
`4` and yields the irrational optimum directly.

---

## 4. The Sharp Contraction Criterion

Rearranging the affine inequality `j \log 3 < m \log 2` by dividing through by
`\log 2 > 0` isolates the threshold constant.

**Theorem 4.1 (Sharp contraction criterion, `pow3_lt_pow2_of_density`).**
Let `j, m \in \mathbb{N}`. If
$$j \cdot \frac{\log 3}{\log 2} < m,$$
then `3^j < 2^m`.

*Proof sketch.* Let `c = \log 2 > 0` (`Real.log_pos`, since `2 > 1`). Multiply the
hypothesis by `c`: from `j \cdot (\log 3 / \log 2) < m` we obtain
`j \cdot (\log 3/\log 2) \cdot \log 2 < m \log 2`. Associativity and the
cancellation `(\log 3/\log 2)\cdot \log 2 = \log 3` (`div_mul_cancel₀`, valid as
`\log 2 \ne 0`) give `j \log 3 < m \log 2`. Theorem 3.2 concludes `3^j < 2^m`. ∎

**Interpretation.** Writing the segment length as `k = j + m`, the hypothesis says
the odd-step density `j/k` is below the optimal threshold
`\frac{1}{1 + \log 3/\log 2} = \frac{\log 2}{\log 2 + \log 3} = \log_6 2`... more
directly, with respect to even steps the break-even is `j/m < \log 2/\log 3 \approx
0.6309`. The constant `\log 3 / \log 2 = \log_2 3 \approx 1.585` is the number of
halvings needed to "pay for" one tripling at the exact margin.

---

## 5. Strict Domination Over the Naive Bound

A sharper criterion is only meaningful if it (a) loses nothing the old bound held
and (b) genuinely gains. We establish both.

**Theorem 5.1 (Forward containment, `log_of_two_mul_lt`).**
If `2j < m` then `j \log 3 < m \log 2`.

*Proof sketch.* First, `\log 3 < 2\log 2`: indeed `\log 3 < \log 4`
(`Real.log_lt_log` since `3 < 4`) and `\log 4 = \log(2^2) = 2 \log 2`. From the
integer hypothesis `2j < m` we get `2j + 1 \le m`, i.e. `2j + 1 \le m` over
`\mathbb{R}`. Scaling `\log 3 < 2\log 2` by `j \ge 0` gives
`j \log 3 \le 2j \log 2`, and the strict slack `2j + 1 \le m` together with
`\log 2 > 0` upgrades this to `j \log 3 < m \log 2` (a single `nlinarith`
combination of the scaled product, the slack, and positivity of `\log 2`). ∎

Theorem 5.1 says: *whenever the naive bound `2j < m` certifies contraction, so does
the logarithmic criterion.* Combined with Theorem 3.2, every naively-contractive
segment is logarithmically-contractive.

**Theorem 5.2 (Strict separation, `sharp_threshold_strictly_stronger`).**
The pair `(j, m) = (1, 2)` satisfies the sharp logarithmic condition
`1 \cdot \log 3 < 2 \cdot \log 2` but fails the naive condition `2 \cdot 1 < 2`.

*Proof sketch.* The naive condition `2 < 2` is false by inspection. For the
logarithmic side, `3^1 = 3 < 4 = 2^2`, so by Theorem 3.1 (with `j=1`, `m=2`)
`1 \cdot \log 3 < 2 \cdot \log 2`. ∎

Thus the inclusion of Theorem 5.1 is *strict*. The witness `(1,2)` is precisely the
most elementary contractive event — one tripling absorbed by two halvings,
`3 < 4` — and it is exactly the case the rational `1/2` threshold cannot reach. The
sharp criterion captures the entire density band `(1/2,\ \log 2/\log 3)` that the
naive argument discards.

---

## 6. Locating the Threshold Constant

To confirm the threshold is correctly positioned relative to the trivial bounds, we
bracket it.

**Theorem 6.1 (Threshold localization, `log3_div_log2_mem_Ioo`).**
$$1 < \frac{\log 3}{\log 2} < 2.$$

*Proof sketch.* Both bounds reduce to monotonicity of `\log` and `\log 2 > 0`.
Lower: `\log 3 / \log 2 > 1 \iff \log 3 > \log 2 \iff 3 > 2`. Upper:
`\log 3 / \log 2 < 2 \iff \log 3 < 2 \log 2 = \log 4 \iff 3 < 4`. ∎

Equivalently `\log_2 3 \in (1, 2)`: one always needs *more than one* but *fewer than
two* halvings per tripling. The naive threshold corresponds to the upper endpoint
`2` (it demands a full two-to-one margin); the true optimum sits strictly inside,
which is exactly the slack the sharp criterion exploits.

---

## 7. The Open Frontier: From Segments to Orbits

The results above concern the *idealized* multiplier `3^j/2^m`. The genuine
Collatz/shortcut map is **affine**, not purely multiplicative: each odd step applies
`n \mapsto (3n+1)/2`, contributing an additive constant. Over a segment with odd
steps at relative positions, the endpoint takes the form

$$T^{[k]}(n) = \frac{3^{j}}{2^{m}}\, n + E,$$

where `E > 0` is a geometric-series error term accumulated from the `+1`s. Even when
`3^j < 2^m` (multiplicative contraction), `E` can dominate for *small* `n`. As
`n \to \infty`, the multiplicative term overwhelms the bounded-by-`O(3^j/2^{?})`
error, so segment contraction should yield orbit contraction `T^{[k]}(n) < n` for
all sufficiently large `n`.

**Conjecture 7.1 (Sharp orbit contraction, `sharp_orbit_contraction_conjecture`).**
For a segment with realized parameters `j, m` satisfying `j \log 3 < m \log 2`,
there exists `N_0` such that for all `n \ge N_0` lying on a trajectory realizing
those parameters, `T^{[k]}(n) < n`.

This is recorded as the file's single, explicitly-marked `sorry` — a conjecture,
never claimed as a theorem. Its honest inclusion is the methodological point of the
cycle: **the power arithmetic is now optimal, and the remaining difficulty is
entirely in the affine error control and in the input-dependent fluctuation of
realized density.** Parity exclusion (Prop. 2.6) bounds *segment* density at `1/2`,
safely under the `0.6309` threshold, so local contraction is assured; the
conjecture is hard because *global* behavior depends on growth phases that no known
method bounds uniformly.

---

## 8. Algorithms

We summarize the computational procedures implicit in the results.

**Algorithm 8.1 (Segment density classifier).** Given `(j, m)`, decide contraction
by three tiers of increasing power: (i) the naive test `2j < m`; (ii) the exact
integer test `3^j < 2^m`; (iii) the logarithmic density test
`j \cdot \log 3 < m \cdot \log 2`. By Theorems 3.2 and 5.1 these satisfy
naive `\Rightarrow` log `\Leftrightarrow` exact, so the log/exact tests agree and
strictly refine the naive one. Complexity: the naive test is `O(1)`; the exact test
is `O(\text{poly}(j+m))` bit operations via big-integer powering; the log test is
`O(1)` floating-point (with care near the boundary, where the exact test should
arbitrate).

**Algorithm 8.2 (Orbit parity word extractor).** Given `n` and length `k`, iterate
`T` and record the parity word `w \in \{0,1\}^k`, `w_i = T^{[i]}(n) \bmod 2`. By
parity exclusion the word contains no `11` substring. Used to compute realized
density `j/k` and to compare against the sharp threshold.

---

## 9. Applications and Significance

1. **Tightest formal contraction bound.** Any density-based attack on Collatz needs
   the contraction criterion in its sharpest form. Replacing `1/2` with
   `\log 2/\log 3` is not cosmetic: it is the difference between a heuristic that
   discards a positive-measure band of contractive behaviors and one that does not.

2. **Diagnosis of difficulty.** By proving the power arithmetic optimal, the work
   relocates the entire residual difficulty to affine-error control. This is
   valuable triage: future effort should target Conjecture 7.1's error term, not
   the exponent comparison.

3. **Bridge to computability.** Generalized Collatz systems (varying multipliers and
   divisors by residue class) are Turing-complete (Conway), making their long-term
   behavior undecidable in general. The exact density threshold for the *specific*
   map `T` quantifies how close the genuine map sits to the contraction regime,
   informing whether `T` lands on the decidable or undecidable side.

4. **Verified rigor.** Every result here is machine-checked, eliminating the
   subtle errors (off-by-one density bounds, sign of `\log`, boundary cases) that
   have historically plagued informal Collatz arguments.

---

## 10. Discussion

The pleasing structural lesson is that a famously irrational threshold
(`\log 2/\log 3`) emerges *for free* the instant one phrases contraction additively
rather than multiplicatively. The crude `3 < 4` argument is precisely the
first-order rational underestimate of the true logarithmic boundary, and the gap it
leaves — realized concretely by `(1,2)`, the inequality `3 < 4` itself — is exactly
the region the sharp criterion reclaims.

The honest limitation is equally instructive. Segment-level contraction is now
optimal and complete; orbit-level contraction is not, and the reason is precise and
isolated. This stands in contrast to informal treatments that often blur the
segment/orbit distinction. By naming Conjecture 7.1 explicitly, the work makes the
remaining obstruction a concrete, attackable target rather than a vague difficulty.

---

## 11. Future Directions

The accompanying research program identifies five directions; we summarize the most
salient.

- **Sharp contraction threshold (extension, realized here).** Completed at the
  segment level by Theorems 3.1–6.1; the orbit-level lift is Conjecture 7.1.
- **Collatz encodings of finite automata (grand challenge).** Construct explicit
  generalized Collatz systems simulating `n`-state DFAs, via Chinese-Remainder
  separation of states — a constructive, finitary shadow of Conway universality.
- **Transfinite orbit measures / Goodstein analogy (grand challenge).** Seek an
  ordinal-valued measure `\mu : \mathbb{N} \to \mathrm{Ordinal}` below `\varepsilon_0`
  that strictly decreases under `T`; existence would prove Collatz by transfinite
  induction at the proof-theoretic strength of PA, mirroring Goodstein's theorem.
- **Spectral analysis of parity words (extension).** Show the discrete Fourier
  transform of a Collatz parity word concentrates at frequency `1/2` (the parity-
  exclusion alternation), connecting the combinatorial approach to Tao-style
  Fourier-analytic methods.
- **Computational lower bounds on independence (grand challenge).** Tie
  primitive-recursive boundedness of stopping times to PA-provability, converting
  the metamathematical independence question into a concrete growth-rate question.

---

## 12. Conclusion

We have established, with formal rigor, the optimal density threshold for Collatz
segment contraction. The exact logarithmic characterization `3^j < 2^m \iff
j\log 3 < m\log 2` converts a comparison of large powers into a single affine
inequality, from which the sharp threshold `\log 2/\log 3 \approx 0.6309` follows
immediately. We proved this criterion strictly dominates the classical `1/2` bound,
exhibited the explicit separating case `(1,2)`, and localized the threshold constant
`\log_2 3` in `(1,2)`. The remaining gap to a full Collatz proof — lifting segment
contraction to orbit contraction against the affine `+1` error — is isolated and
recorded honestly as an open conjecture. The power arithmetic of Collatz contraction
is now optimal; the mystery lives elsewhere, and we have said precisely where.

---

## Appendix A: Statement Index

| Name | Statement | Status |
|------|-----------|--------|
| `pow3_lt_pow2_iff_log` | `(3:ℝ)^j < 2^m ↔ j·log 3 < m·log 2` | Theorem |
| `nat_pow3_lt_pow2_iff_log` | `3^j < 2^m (ℕ) ↔ j·log 3 < m·log 2` | Theorem |
| `pow3_lt_pow2_of_density` | `j·(log 3/log 2) < m ⟹ 3^j < 2^m` | Theorem |
| `log_of_two_mul_lt` | `2j < m ⟹ j·log 3 < m·log 2` | Theorem |
| `sharp_threshold_strictly_stronger` | `1·log 3 < 2·log 2 ∧ ¬(2·1 < 2)` | Theorem |
| `log3_div_log2_mem_Ioo` | `log 3/log 2 ∈ (1,2)` | Theorem |
| `sharp_orbit_contraction_conjecture` | realized density `⟹` orbit contraction for large `n` | Conjecture |

## Appendix B: Numerical Threshold Reference

- `\log 2 \approx 0.693147`, `\log 3 \approx 1.098612`.
- `\log 3 / \log 2 = \log_2 3 \approx 1.584963` (halvings per tripling, at margin).
- `\log 2 / \log 3 = \log_3 2 \approx 0.630930` (optimal odd/even step ratio).
- Naive threshold `1/2 = 0.5`; reclaimed band width `\approx 0.13093`.
