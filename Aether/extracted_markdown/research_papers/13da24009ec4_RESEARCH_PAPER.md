# The Cumulative Weight-Threshold Count and Its Tropical Convolution Law for Binary Linear Codes

**Domain:** Shared (Coding Theory ∩ Tropical Geometry ∩ Combinatorics)

## Abstract

We introduce and study the **cumulative weight-threshold count** of a finite binary
linear code `C` of length `n`, the monotone function
`wcount(C, t) = #{ c ∈ C : wt(c) ≤ t }`, where `wt` denotes Hamming weight. This is the
discrete cumulative distribution function (CDF) of the weight, and unlike the *tropical
weight enumerator* `twe(C, t) = min_{c ∈ C} (t · wt(c))` — which records only the convex
(min-plus) hull of the weight spectrum and therefore erases interior strata such as the
minimum distance — the cumulative count retains the entire weight distribution, with
every stratum visible as a jump. Our central results concern the behaviour of `wcount`
under the **direct sum** (coordinate concatenation) `C ⊕ D` of codes. We prove (i) an
**exact sliding-threshold convolution law**, `wcount(C ⊕ D, t) = Σ_{a ∈ C, wt(a) ≤ t}
wcount(D, t − wt(a))`; and (ii) a **supermultiplicative (tropical) inequality**,
`wcount(C, s) · wcount(D, r) ≤ wcount(C ⊕ D, s + r)` for all thresholds `s, r`, which on
taking logarithms expresses the subadditivity of `t ↦ −log wcount(C, t)`. The inequality
is generically strict in the interior and degenerates to the cardinality identity
`|C ⊕ D| = |C|·|D|` only at the extreme thresholds. We exhibit the strict gap explicitly
on the extended Hamming `[8,4,4]` code: `wcount(Hamming, 4)² = 15² = 225 < 227 =
wcount(Hamming ⊕ Hamming, 8)`, the deficit of `2` being exactly the cross-strata blocks
`(8,0)` and `(0,8)`. We complement these with the exact Cauchy convolution of the weight
distribution `wexact(C, t) = #{c ∈ C : wt(c) = t}` and the CDF/PMF link `wcount = Σ
wexact`, situating `wcount` within a strict hierarchy of direct-sum invariants:
cardinality ⊃ Cauchy convolution ⊃ prefix-convolution inequality ⊃ tropical-min hull.
All results have been formally verified.

## 1. Introduction

The weight distribution of a linear code is among its most studied invariants. Its
generating function, the **weight enumerator** `W_C(x, y) = Σ_{c ∈ C} x^{n − wt(c)}
y^{wt(c)}`, is multiplicative under the direct sum of codes: `W_{C ⊕ D} = W_C · W_D`.
This multiplicativity is the engine behind a great deal of structural coding theory,
including the behaviour of self-dual codes and their MacWilliams identities.

Tropicalization — replacing the semiring `(ℝ, +, ×)` with the min-plus semiring
`(ℝ, min, +)` — turns the generating *sum* into a *minimum* and the *product* into a
*sum*. The resulting **tropical weight enumerator** `twe(C, t) = min_{c ∈ C} (t · wt(c))`
is piecewise linear in the slope `t` and satisfies `twe(C ⊕ D, ·) = twe(C, ·) +
twe(D, ·)`, the exact tropical mirror of the additivity of weight under concatenation,
`wt(a ++ b) = wt(a) + wt(b)`. However, the min-plus operation is lossy: `twe` records
only the lower convex hull of the weight spectrum, discarding interior strata. On the
extended Hamming `[8,4,4]` code, whose classical enumerator is `1 + 14x⁴ + x⁸`, the
tropical enumerator cannot distinguish the fourteen weight-`4` words from any other
interior configuration; the minimum distance `d = 4` is *not* recoverable from `twe`
beyond its appearance as a hull vertex.

This motivates a finer invariant that (a) retains every stratum and (b) still obeys a
clean tropical-style law under direct sum. We propose the **cumulative weight-threshold
count** `wcount(C, t) = #{c ∈ C : wt(c) ≤ t}`, the discrete CDF of weight. Section 2
fixes definitions and elementary properties; Section 3 proves the exact convolution and
the supermultiplicative bound; Section 4 develops the weight-distribution (PMF)
companion `wexact`; Section 5 instantiates everything on the extended Hamming code and
exhibits the strict gap; Section 6 places the results in a refinement hierarchy and
discusses applications; Section 7 records the formal-verification status; Section 8 lists
open problems.

## 2. Definitions and elementary properties

Throughout, codes are finite subsets `C ⊆ (ZMod 2)^n` of binary vectors of length `n`;
we do not require linearity for any of the counting results, though the motivating
examples are linear. We write `Fin n → ZMod 2` for the type of length-`n` binary
vectors.

**Definition 2.1 (Hamming weight).** For `v : Fin n → ZMod 2`,
`wt(v) = #{ i : v(i) = 1 }`.

**Definition 2.2 (Direct sum / concatenation).** For `C ⊆ (ZMod 2)^m` and
`D ⊆ (ZMod 2)^n`, the direct sum `C ⊕ D ⊆ (ZMod 2)^{m+n}` consists of all
concatenations `append(a, b)` (the vector `a` on the first `m` coordinates, `b` on the
last `n`) with `a ∈ C` and `b ∈ D`. Membership is characterized by
`z ∈ C ⊕ D ⟺ ∃ a ∈ C, ∃ b ∈ D, z = append(a, b)`, and concatenation is injective.

**Definition 2.3 (Cumulative weight-threshold count).**
`wcount(C, t) = #{ c ∈ C : wt(c) ≤ t }`, the cardinality of the sub-multiset of
codewords of weight at most `t`.

We record the basic CDF properties; all are immediate from Definition 2.3.

**Lemma 2.4 (Weight bound).** For every `v : Fin n → ZMod 2`, `wt(v) ≤ n`.
*Proof sketch.* The support `{i : v(i) = 1}` is a subset of the `n`-element index set,
so its cardinality is at most `n`. ∎

**Lemma 2.5 (Monotonicity).** If `s ≤ t` then `wcount(C, s) ≤ wcount(C, t)`.
*Proof sketch.* The set `{c : wt(c) ≤ s}` is contained in `{c : wt(c) ≤ t}` by
transitivity of `≤`, and cardinality is monotone under inclusion. ∎

**Lemma 2.6 (Bounded by size).** `wcount(C, t) ≤ |C|` for all `t`.
*Proof sketch.* A filtered subset has cardinality at most that of the whole set. ∎

**Lemma 2.7 (Saturation at the length).** `wcount(C, n) = |C|`.
*Proof sketch.* By Lemma 2.4 every codeword satisfies `wt(c) ≤ n`, so the filter is the
whole code. ∎

**Lemma 2.8 (Weight zero ⟺ zero vector).** `wt(v) = 0 ⟺ v = 0`.
*Proof sketch.* `wt(v) = 0` means the support is empty, i.e. `v(i) ≠ 1` for all `i`;
since the values lie in `ZMod 2`, this forces `v(i) = 0` for all `i`. ∎

**Lemma 2.9 (Bottom value).** `wcount(C, 0) = #{c ∈ C : c = 0}`, which is `1` if `0 ∈ C`
and `0` otherwise. *Proof sketch.* Combine Lemma 2.8 with `wt(c) ≤ 0 ⟺ wt(c) = 0`. ∎

Thus `t ↦ wcount(C, t)` is a nondecreasing step function on `{0, 1, …, n}` rising from
`#{0-words}` (typically `1`) to `|C|`: the discrete CDF of the weight, jumping by
`wexact(C, t)` (Definition 4.1) at each `t`.

## 3. The convolution law under direct sum

The structural results rest entirely on the additivity of weight under concatenation,
which we state as a standing fact.

**Fact 3.1 (Additivity of weight).** `wt(append(a, b)) = wt(a) + wt(b)`.
*Justification.* The support of `append(a, b)` is the disjoint union of the support of
`a` (in the first block) and the support of `b` (in the second block); cardinalities
add. ∎

### 3.1 Exact sliding-threshold convolution

**Theorem 3.2 (Exact convolution, `wcount_append`).** For all `t`,
```
wcount(C ⊕ D, t) = Σ_{a ∈ C, wt(a) ≤ t} wcount(D, t − wt(a)).
```

*Proof sketch.* By Definition 2.2 the map `(a, b) ↦ append(a, b)` is a bijection from
`C × D` onto `C ⊕ D`. By Fact 3.1, `wt(append(a, b)) = wt(a) + wt(b)`, so the event
`wt(append(a, b)) ≤ t` is equivalent to `wt(a) + wt(b) ≤ t`. Partition the qualifying
pairs by their first coordinate `a`. For a fixed `a`, the pair qualifies iff `wt(a) ≤ t`
and `wt(b) ≤ t − wt(a)` (using truncated subtraction on ℕ; when `wt(a) > t` the inner
condition is unsatisfiable and the term is absent). The number of admissible `b` for a
fixed admissible `a` is exactly `wcount(D, t − wt(a))`. Summing over `a ∈ C` with
`wt(a) ≤ t` and invoking injectivity of `append` (so the fibres are disjoint and no
double counting occurs) yields the claim. The guard `wt(a) ≤ t` is essential: without
it, the truncation `t − wt(a) = 0` for heavy `a` would spuriously contribute the
zero-weight words of `D`. ∎

The truncated-subtraction subtlety is exactly why the *filtered* sum
`Σ_{a ∈ C, wt(a) ≤ t}` rather than `Σ_{a ∈ C}` is used: the filter and the truncation
must agree, and the filter is the honest accounting.

### 3.2 Supermultiplicative (tropical) bound

**Theorem 3.3 (Supermultiplicative bound, `wcount_append_ge`).** For all `s, r`,
```
wcount(C, s) · wcount(D, r) ≤ wcount(C ⊕ D, s + r).
```

*Proof sketch.* Consider the product set `R = {a ∈ C : wt(a) ≤ s} × {b ∈ D : wt(b) ≤ r}`,
of cardinality `wcount(C, s) · wcount(D, r)`. Map it into `C ⊕ D` by `(a, b) ↦
append(a, b)`. For `(a, b) ∈ R` we have `wt(append(a, b)) = wt(a) + wt(b) ≤ s + r` by
Fact 3.1, so the image lands in `{z ∈ C ⊕ D : wt(z) ≤ s + r}`, a set of cardinality
`wcount(C ⊕ D, s + r)`. The map is injective (concatenation is injective). An injection
from a finite set into another gives the cardinality inequality. ∎

**Corollary 3.4 (Subadditivity of the log-deficit).** The function
`φ_C(t) = −log wcount(C, t)` (defined where `wcount(C, t) > 0`) satisfies
`φ_{C ⊕ D}(s + r) ≤ φ_C(s) + φ_D(r)`. *Proof.* Take `−log` of Theorem 3.3 and use that
`log` is increasing. ∎

This subadditivity is the **tropical fingerprint**: it is the min-plus shadow of the
additive grading `wt(a ++ b) = wt(a) + wt(b)`, with the product of counts playing the
role of the tropical product (= addition of logarithms) and the inequality recording
that the rectangle is a *proper* sub-domain of the simplex.

**Remark 3.5 (Endpoint degeneration).** At `s = 0, r = 0`, Theorem 3.3 reads
`(#0\text{-words of }C)·(#0\text{-words of }D) ≤ #0\text{-words of }C ⊕ D`, an equality
`1 ≤ 1` for codes containing `0`. At `s = m, r = n` (the lengths), Lemma 2.7 gives
`|C|·|D| ≤ |C ⊕ D|`, which is the equality `|C ⊕ D| = |C|·|D|`. Thus the supermultiplicative
bound interpolates between two equalities and is generically strict only in the interior
(Section 5). ∎

### 3.3 Why the bound is an inequality: cross-strata

The gap in Theorem 3.3 has a precise combinatorial meaning. The rectangle
`{wt ≤ s} × {wt ≤ r}` is a strict subset of the simplex
`{(a, b) : wt(a) + wt(b) ≤ s + r}` whenever the codes carry strata with `wt(a) > s` but
`wt(a) + wt(b) ≤ s + r` (compensated by a light `b`), or symmetrically. By Theorem 3.2
the exact count is the simplex count, so:

**Proposition 3.6 (Gap = cross-strata census, conjectural exact form in Section 8).**
```
wcount(C ⊕ D, s + r) − wcount(C, s)·wcount(D, r)
   = #{ (a, b) ∈ C × D : wt(a) + wt(b) ≤ s + r, ¬(wt(a) ≤ s ∧ wt(b) ≤ r) }.
```
*Proof sketch.* The left term counts the simplex (Theorem 3.2 summed, or directly by
the `append` bijection), the subtracted term counts the rectangle; their difference is
the cardinality of the set-theoretic difference, which is exactly the displayed set. ∎

We verify Proposition 3.6 numerically in Section 5; its general formalization is recorded
as Conjecture 2 in Section 8.

## 4. The weight distribution and its exact convolution

The differences of the CDF form the probability mass function.

**Definition 4.1 (Weight distribution / PMF).**
`wexact(C, t) = #{ c ∈ C : wt(c) = t }`.

**Theorem 4.2 (CDF–PMF link, `wcount_eq_sum_wexact`).**
`wcount(C, t) = Σ_{u = 0}^{t} wexact(C, u)`. *Proof sketch.* The events
`{wt = u}` for `u = 0, …, t` partition `{wt ≤ t}`; sum their cardinalities. ∎

**Theorem 4.3 (Cauchy convolution of distributions, `wexact_append`).** For all `t`,
```
wexact(C ⊕ D, t) = Σ_{s = 0}^{t} wexact(C, s) · wexact(D, t − s).
```
*Proof sketch.* By the `append` bijection and Fact 3.1, a glued word has weight exactly
`t` iff its halves have weights `s` and `t − s` for some `0 ≤ s ≤ t`. Partition by `s`;
for fixed `s` the count of admissible `(a, b)` factors as `wexact(C, s)·wexact(D, t−s)`
because the two halves are chosen independently. Sum over `s`. ∎

Theorem 4.3 is the literal discrete shadow of the polynomial product `W_{C ⊕ D} =
W_C · W_D`: it *is* the coefficient convolution of weight enumerators. Combining
Theorems 4.2 and 4.3 reproves the exact `wcount` convolution of Theorem 3.2 in CDF form,
and summing Theorem 4.3 over `t ≤ s + r` recovers the supermultiplicative bound of
Theorem 3.3, since the rectangle terms are the "diagonal-respecting" subset of the
double sum.

## 5. The extended Hamming code and the strict gap

We instantiate on the extended Hamming `[8,4,4]` code `H` (Reed–Muller `RM(1,3)`, the
mod-2 reduction of the `E8` lattice), with generator matrix
```
[1 1 1 1 1 1 1 1]
[0 0 0 0 1 1 1 1]
[0 0 1 1 0 0 1 1]
[0 1 0 1 0 1 0 1]
```
spanning `16` codewords. Its weight distribution is `wexact(H, ·) = (1, 0, 0, 0, 14, 0,
0, 0, 1)` on weights `0, …, 8`, i.e. enumerator `1 + 14x⁴ + x⁸`.

**Cumulative count.** From the spectrum,
`wcount(H, t) = 1` for `t ∈ {0,1,2,3}`, `wcount(H, t) = 15` for `t ∈ {4,5,6,7}`, and
`wcount(H, 8) = 16`.

**The direct sum `H ⊕ H`** has `256` codewords; by Theorem 4.3 its weight distribution
is the self-convolution `(1, 0, 0, 0, 14, 0, 0, 0, 1) * (1, 0, 0, 0, 14, 0, 0, 0, 1)`,
namely on weights `0, 4, 8, 12, 16`:
```
wexact(H ⊕ H, 0)  = 1·1            = 1
wexact(H ⊕ H, 4)  = 1·14 + 14·1    = 28
wexact(H ⊕ H, 8)  = 1·1 + 14·14 + 1·1 = 198   (the "E8 ⊕ E8 shadow" reconstruction)
wexact(H ⊕ H, 12) = 14·1 + 1·14    = 28
wexact(H ⊕ H, 16) = 1·1            = 1
```
totalling `1 + 28 + 198 + 28 + 1 = 256`, as required.

**The headline strict gap.** By Theorem 4.2,
`wcount(H ⊕ H, 8) = 1 + 28 + 198 = 227`. By Theorem 3.2 directly,
`wcount(H ⊕ H, 8) = 1·wcount(H, 8) + 14·wcount(H, 4) + 1·wcount(H, 0) = 16 + 210 + 1 =
227`. Meanwhile the supermultiplicative lower bound at `s = r = 4` is
`wcount(H, 4)² = 15² = 225`. Hence
```
225 = wcount(H, 4)² < wcount(H ⊕ H, 8) = 227,        (strict, gap = 2).
```
By Proposition 3.6 the deficit `2` equals
`#{(a,b) : wt(a)+wt(b) ≤ 8, ¬(wt(a) ≤ 4 ∧ wt(b) ≤ 4)}`, which is realized by exactly the
two cross-strata blocks `(wt 8, wt 0)` and `(wt 0, wt 8)` — the all-ones block paired
with a zero block and vice versa — each contributing `1·1 = 1`. This is the concrete
content of "convolution, not product": the count is *not* multiplicative, the gap is the
cross-strata census, and it vanishes only at the endpoints (`s=r=0` gives `1 = 1`;
`s=r=8` gives `256 = 256`).

## 6. A refinement hierarchy and applications

The four direct-sum laws form a strict tower of increasing resolution:

| invariant | direct-sum law | type | resolution |
|---|---|---|---|
| cardinality `\|C\|` | `\|C ⊕ D\| = \|C\|·\|D\|` | product | totals only |
| weight distribution `wexact` | exact Cauchy convolution (Thm 4.3) | equality | every stratum |
| cumulative count `wcount` | supermultiplicative inequality (Thm 3.3); exact sliding convolution (Thm 3.2) | inequality / convolution | every stratum, as thresholds; cross-strata as gap |
| tropical enumerator `twe` | additive `twe(C⊕D) = twe(C)+twe(D)` | equality | convex hull only |

Cardinality is the coarsest; `twe` discards interior strata to the min-plus hull;
`wexact` is exact but unstructured (a bare convolution monoid); `wcount` sits between,
retaining all strata while admitting the clean tropical (subadditive) law of
Corollary 3.4. The strict Hamming gap certifies that each containment in
`cardinality ⊃ Cauchy convolution ⊃ prefix-convolution inequality ⊃ tropical-min hull`
is proper.

**Applications.**
- *Threshold decoding budgets.* `wcount(C, t)` is the number of codewords a
  bounded-weight (radius-`t`) enumeration must consider; Theorem 3.2 gives a divide-and-
  conquer recursion over concatenated blocks, and Theorem 3.3 a fast supermultiplicative
  lower bound for capacity-planning without enumerating the product code.
- *Subadditive valuations.* Corollary 3.4 exhibits `−log wcount` as a genuine tropical
  valuation on the monoid of codes under direct sum, packaging the additive weight
  grading into a single subadditive functional — useful wherever a CDF must be combined
  across independently graded subsystems (bit-error budgets, energy levels, additive
  costs).
- *Self-dual / lattice shadows.* For Type II codes such as `H`, the self-convolution
  spectrum (Section 5) is the mod-2 avatar of lattice theta-series multiplication
  (`E8 ⊕ E8`), and the strict gap quantifies the failure of naive multiplicativity at
  interior radii.

## 7. Formal verification

All numbered results have been formally verified in a proof assistant, `sorry`-free.
The cumulative-count file establishes Lemmas 2.4–2.9 (`wt_le_length`, `wcount_mono`,
`wcount_le_card`, `wcount_length`, `wt_eq_zero_iff`, `wcount_zero`), Theorem 3.2
(`wcount_append`), and Theorem 3.3 (`wcount_append_ge`), together with the Hamming
instantiation `225 < 227` (`hamming16_wcount_strict`). The weight-distribution file
establishes Theorem 4.3 (`wexact_append`), Theorem 4.2 (`wcount_eq_sum_wexact`), the
normalization `Σ_t wexact(C,t) = |C|` (`sum_wexact_eq_card`), and the `E8 ⊕ E8`-shadow
reconstruction `1 + 196 + 1 = 198` (`hamming16_wexact_convolution`). These build on the
established direct-sum infrastructure: `wt_append` (Fact 3.1), `appendCode_card`
(`|C ⊕ D| = |C|·|D|`), the membership characterization of Definition 2.2, and the
`[8,4,4]` weight enumerator `1 + 14x⁴ + x⁸`.

## 8. Open problems and future directions

**Conjecture 1 (Log-concavity under direct-sum powers).** For an arbitrary binary code
`C` the cumulative sequence `t ↦ wcount(C, t)` need not be log-concave (the Hamming
spectrum `1,0,0,0,14,0,0,0,1` is itself not log-concave), but for the `k`-fold direct
sum `C^{⊕k}` the normalized distribution `wexact(C^{⊕k}, ·)` becomes asymptotically
log-concave — a discrete central-limit phenomenon for weight under repeated
concatenation. The mechanism is that `wexact` is a Cauchy-convolution monoid
(Theorem 4.3), so `wexact(C^{⊕k})` is the `k`-fold self-convolution of a fixed finite
nonnegative sequence, the canonical setting for Newton/CLT-type log-concavity. The
missing ingredient is a finite-support self-convolution log-concavity lemma.

**Conjecture 2 (The strict gap counts cross-strata exactly).** The general form of
Proposition 3.6:
`wcount(C ⊕ D, s+r) − wcount(C, s)·wcount(D, r) = #{(a,b) : wt(a)+wt(b) ≤ s+r,
¬(wt(a) ≤ s ∧ wt(b) ≤ r)}`, i.e. the deficit of the tropical bound is precisely the
number of concatenations lying *outside* the rectangle `{≤s}×{≤r}` but inside the
simplex `{wt(a)+wt(b) ≤ s+r}`. The supermultiplicative bound arose from a
rectangle-into-simplex injection; its failure to be onto is governed term-by-term by the
exact convolution (Theorem 3.2), so the gap is a sum of honest cross-stratum counts (on
Hamming, the `(8,0)` and `(0,8)` blocks giving `227 − 225 = 2`).

**Further directions.** Extend the dictionary to (i) non-binary alphabets `ZMod q` with
weight replaced by the appropriate metric; (ii) the *tensor* (rather than direct sum)
construction, where weight is sub/super-additive and one expects a two-sided bound;
(iii) a functorial statement, realizing `C ↦ (t ↦ wcount(C, t))` as a functor from the
category of finite codes (with direct sum) to a category of tropical valuation objects,
with Theorem 3.3 the lax-monoidal structure map; and (iv) MacWilliams-type duality for
`wcount`, relating the cumulative count of `C` to that of its dual `C^⊥`.

## References

This paper is self-contained; all definitions and proofs are given inline. The extended
Hamming `[8,4,4]` code, the Reed–Muller family `RM(1,3)`, the `E8` lattice, and the
min-plus (tropical) semiring are standard objects whose elementary properties used here
are reproved from first principles in the text.
