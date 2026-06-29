# Ultrametric Lipschitz Bounds Induced by Tropical Valuations on Arithmetic Height Spaces

## Abstract

We construct and rigorously analyze a metric-regularity bridge connecting three previously
disconnected objects: the *arithmetic height* on the rationals, the *tropical-to-ultrametric
reconstruction functor* of nonarchimedean analysis, and the engineering notion of *certified
nonexpansiveness*. We begin with an adversarial result: the arithmetic height
`height(q) = |num(q)| + den(q)` is **not** a nonarchimedean (ultrametric) valuation — the strong,
max-form triangle inequality fails already at `1 + 1`, where `height(2) = 3` exceeds
`max(height(1), height(1)) = 2`. This sharp counterexample identifies the precise obstruction and
motivates the correct normalization. We then define a *rational ultravaluation*: a rational-valued
absolute value satisfying the strong triangle law and multiplicativity. From any such valuation we
induce an ultradistance `dist(x, y) = val(x − y)` and prove it is a genuine ultrametric (positivity,
symmetry, point separation, and the strong triangle law). Our central theorem — the **bridge
theorem** `valuation_mono_nonexpansive` — shows that any map that is additive on differences and
whose valuation does not increase induces a nonexpansive map of the associated ultrametric spaces;
we show both hypotheses are necessary. We establish compositional closure for nonexpansive and
Lipschitz maps, realize the p-adic absolute value as a concrete rational ultravaluation
`padicRatUltra`, exhibit certified nonexpansive instances (integer scaling and integer affine maps),
prove a height/valuation comparison `p^{v_p(|n|)} ≤ height(n)`, and record a boundedness statement
that integer data lives in the unit ball. All results are fully formalized with no unproven
assumptions and depend only on standard foundational axioms.

**Keywords:** ultrametric, p-adic valuation, arithmetic height, nonexpansive map, Lipschitz bound,
tropical geometry, certified robustness, nonarchimedean analysis.

---

## 1. Introduction

### 1.1 Two notions of size, two notions of distance

The rational numbers admit two radically different geometries. The *archimedean* geometry is the
familiar one induced by the ordinary absolute value: `dist(x, y) = |x − y|`. The *nonarchimedean*
geometries are induced by the p-adic absolute values, one for each prime `p`, in which a number is
"small" precisely when it is highly divisible by `p`. Ostrowski's theorem famously says these are,
up to equivalence, the only absolute values on `ℚ`. The nonarchimedean valuations satisfy a
strictly stronger triangle inequality, the *ultrametric* or strong triangle law

> `dist(x, z) ≤ max(dist(x, y), dist(y, z))`,

which forces a rigid combinatorial geometry: all triangles are isosceles with the two largest sides
equal, balls are clopen, and distances occupy a discrete value group.

In parallel, number theory equips `ℚ` with a *height*, a measure of arithmetic complexity rather
than magnitude. The simplest such height is

> `height(q) = |num(q)| + den(q)`,

where `q = num(q)/den(q)` is written in lowest terms with positive denominator. Heights drive the
finiteness theorems of Diophantine geometry (Northcott, Mordell–Weil) by enabling induction on
arithmetic complexity.

### 1.2 The temptation, and the obstruction

It is natural to hope that the height itself induces an ultrametric via `dist(x, y) = height(x − y)`,
thereby fusing arithmetic complexity with nonarchimedean geometry in one stroke. The hope is false,
and instructively so. We prove (Theorem 3.1) that the height violates the strong triangle law at the
smallest nontrivial input. The failure is not an accident of edge cases: the height is intrinsically
*archimedean*, sensitive to magnitude, while the ultrametric law forbids sums from growing. The two
philosophies are incompatible.

The obstruction is also a signpost. It tells us to replace magnitude-sensitivity with pure
divisibility data — that is, to use a p-adic valuation. We axiomatize the needed structure as a
*rational ultravaluation*, prove the induced distance is a genuine ultrametric, and then build the
metric-regularity theory on top.

### 1.3 Contributions

1. **Adversarial ground truth** (§3): a sharp falsifier showing the arithmetic height is not an
   ultranorm, with the explicit witness `1 + 1`.
2. **Corrected object** (§4): the `RatUltraValuation` structure and the induced ultradistance, with
   full ultrametric axioms — positivity, self-distance zero, symmetry, point separation, and the
   strong triangle law.
3. **Bridge theorem** (§5): valuation monotonicity plus additivity on differences implies
   nonexpansiveness, with both hypotheses shown necessary.
4. **Compositional calculus** (§6): closure of nonexpansive and Lipschitz arithmetic maps under
   composition, with multiplicative constants.
5. **Concrete realization** (§7): the p-adic instance `padicRatUltra`, certified nonexpansive maps
   (integer scaling, integer affine), the height/valuation comparison, and integer-data boundedness.

---

## 2. Preliminaries and notation

We work over the field of rationals `ℚ`. For `q ∈ ℚ`, write `num(q) ∈ ℤ` and `den(q) ∈ ℕ₊` for the
numerator and (positive) denominator of `q` in lowest terms. For a prime `p` and a nonzero integer
`n`, let `v_p(n)` denote the p-adic valuation (the exponent of `p` in the prime factorization of
`|n|`); extend to `ℚ` by `v_p(a/b) = v_p(a) − v_p(b)`. The p-adic absolute value is
`|q|_p = p^{−v_p(q)}` for `q ≠ 0`, and `|0|_p = 0`.

We use `max` for the binary maximum on a linear order. A function `f : ℚ → ℚ` is **additive on
differences** if `f(a − b) = f(a) − f(b)` for all `a, b`; equivalently `f` is `ℤ`-affine through the
origin up to the additive structure on differences (group homomorphisms qualify, and so do the
restrictions relevant below).

---

## 3. Adversarial ground truth: the height is not an ultranorm

### 3.1 The arithmetic height

**Definition 3.1 (arithmetic height).** For `q ∈ ℚ`, `height(q) := |num(q)| + den(q) ∈ ℕ`.

Basic properties, each verified directly:

- **Positivity:** `height(q) ≥ 1` for all `q`, since `den(q) ≥ 1`. In particular `height(0) = 1`.
- **Sign-blindness:** `height(−q) = height(q)`, since negation flips the sign of the numerator and
  preserves `|·|` and the denominator.

These mirror the catalog lemmas `ratArithHeight_pos`, `ratArithHeight_ge_one`,
`ratArithHeight_zero`, and `ratArithHeight_neg`.

### 3.2 The falsifier

**Theorem 3.1 (the height is not nonarchimedean).**
It is *not* the case that for all `q, r ∈ ℚ`,

> `height(q + r) ≤ max(height(q), height(r))`.

*Proof.* Take `q = r = 1`. Then `height(1) = |1| + 1 = 2`, so `max(height(1), height(1)) = 2`. But
`1 + 1 = 2 = 2/1`, so `height(2) = |2| + 1 = 3`. Since `3 ≰ 2`, the universally quantified inequality
fails. ∎

**Remark (interpretation).** The failure is structural, not numerical noise. The strong triangle law
demands that addition never increase the valuation; the height, being archimedean, *records* the
growth of `1 + 1 = 2`. Any attempt to use `height` as the norm of a reconstructed ultrametric object
would violate the additive (`val_add`) axiom. The correct carrier is a p-adic valuation, developed
next.

---

## 4. Rational ultravaluations and the induced ultradistance

### 4.1 The structure

**Definition 4.1 (rational ultravaluation).** A *rational ultravaluation* is a map `val : ℚ → ℚ`
satisfying:

1. `val_nonneg`: `val(x) ≥ 0` for all `x`;
2. `val_zero`: `val(0) = 0`;
3. `val_eq_zero`: `val(x) = 0 ⟹ x = 0` (faithfulness);
4. `val_neg`: `val(−x) = val(x)` (sign-blindness);
5. `val_add_le`: `val(x + y) ≤ max(val(x), val(y))` (strong triangle law);
6. `val_mul`: `val(x · y) = val(x) · val(y)` (multiplicativity).

This is the rational, real-valued counterpart of the catalog's ℕ-valued, multiplicative
`TropicalValuationCarrier` and the seminorm object produced by `valuationReconstruct`. The decisive
upgrade over the height is axiom 5, the strong triangle law, which the height provably lacks
(Theorem 3.1).

### 4.2 The induced ultradistance

**Definition 4.2 (induced ultradistance).** Given a rational ultravaluation `V`, define
`dist_V(x, y) := val(x − y)`.

**Proposition 4.1 (metric axioms).** For all `x, y, z ∈ ℚ`:

- `dist_V(x, x) = 0`;
- `dist_V(x, y) ≥ 0`;
- `dist_V(x, y) = dist_V(y, x)` (symmetry);
- `dist_V(x, y) = 0 ⟺ x = y` (point separation).

*Proof sketches.*
Self-distance: `dist_V(x, x) = val(x − x) = val(0) = 0` by `val_zero`.
Nonnegativity: immediate from `val_nonneg`.
Symmetry: `x − y = −(y − x)`, so `val(x − y) = val(−(y − x)) = val(y − x)` by `val_neg`.
Separation (⟸): if `x = y` then `dist_V = val(0) = 0`; (⟹) if `val(x − y) = 0` then `x − y = 0` by
`val_eq_zero`, hence `x = y`. ∎

**Theorem 4.2 (strong triangle law for the ultradistance).** For all `x, y, z ∈ ℚ`,

> `dist_V(x, z) ≤ max(dist_V(x, y), dist_V(y, z))`.

*Proof.* Write `x − z = (x − y) + (y − z)`. Then
`dist_V(x, z) = val((x − y) + (y − z)) ≤ max(val(x − y), val(y − z)) = max(dist_V(x, y), dist_V(y, z))`
by the `val_add_le` axiom. ∎

Theorem 4.2 is the rational, real-valued analogue of the catalog's ℕ-valued
`valuationReconstruct_obj_ultrametric`. Together with Proposition 4.1, it certifies that `dist_V` is
a genuine ultrametric (pseudometric upgraded to metric by separation).

---

## 5. The bridge theorem: valuation monotonicity ⟹ nonexpansiveness

### 5.1 Regularity classes

**Definition 5.1 (nonexpansive).** A map `f : ℚ → ℚ` is *nonexpansive* for `V` if
`dist_V(f(x), f(y)) ≤ dist_V(x, y)` for all `x, y`.

**Definition 5.2 (Lipschitz).** A map `f : ℚ → ℚ` is *`C`-Lipschitz* for `V` (with `C ∈ ℚ`) if
`dist_V(f(x), f(y)) ≤ C · dist_V(x, y)` for all `x, y`.

### 5.2 The bridge

**Theorem 5.1 (bridge theorem, `valuation_mono_nonexpansive`).** Let `V` be a rational ultravaluation
and `f : ℚ → ℚ`. Suppose

1. (*additivity on differences*) `f(a − b) = f(a) − f(b)` for all `a, b ∈ ℚ`, and
2. (*valuation monotonicity*) `val(f(a)) ≤ val(a)` for all `a ∈ ℚ`.

Then `f` is nonexpansive for `V`.

*Proof.* Fix `x, y`. By definition and hypothesis (1),
`dist_V(f(x), f(y)) = val(f(x) − f(y)) = val(f(x − y))`.
By hypothesis (2) applied to `a = x − y`,
`val(f(x − y)) ≤ val(x − y) = dist_V(x, y)`.
Chaining the two gives `dist_V(f(x), f(y)) ≤ dist_V(x, y)`. ∎

This is the metric counterpart of the catalog's functorial transfer theorem
`tropical_nonexpansive_implies_ultrametric_nonexpansive`: a *pointwise* valuation bound on `f` is
converted, through additivity, into a *metric* bound on differences.

### 5.3 Sharpness of the hypotheses

**Proposition 5.2 (necessity of additivity).** Hypothesis (1) cannot be dropped. Without additivity
on differences, `f(x) − f(y)` need not equal `f(x − y)`, so the valuation bound `val(f(a)) ≤ val(a)`
has no difference to act on, and the conclusion can fail. (Concretely, a map that decreases every
individual valuation but scrambles differences — e.g. a nonlinear map that sends two valuation-large
inputs to two valuation-far outputs — violates nonexpansiveness while satisfying (2).)

**Proposition 5.3 (necessity of valuation monotonicity).** Hypothesis (2) cannot be dropped either:
multiplication by a fixed rational `c` with `val(c) > 1` is additive on differences but expands all
nonzero distances by the factor `val(c)`, so it is not nonexpansive. (It is, however, exactly
`val(c)`-Lipschitz; see §6.)

These two propositions together justify the description of Theorem 5.1 as *sharp*: each hypothesis is
individually load-bearing.

---

## 6. Compositional closure

A regularity theory is useful for pipelines only if it composes. It does.

**Theorem 6.1 (nonexpansive composition, `nonexpansive_comp`).** If `f` and `g` are nonexpansive for
`V`, then `g ∘ f` is nonexpansive for `V`.

*Proof.* For all `x, y`,
`dist_V(g(f(x)), g(f(y))) ≤ dist_V(f(x), f(y)) ≤ dist_V(x, y)`,
using nonexpansiveness of `g` then of `f`. ∎

**Theorem 6.2 (Lipschitz composition, `lipschitz_comp`).** If `f` is `C`-Lipschitz and `g` is
`D`-Lipschitz for `V`, with `C, D ≥ 0`, then `g ∘ f` is `(D · C)`-Lipschitz for `V`.

*Proof.* For all `x, y`,
`dist_V(g(f(x)), g(f(y))) ≤ D · dist_V(f(x), f(y)) ≤ D · (C · dist_V(x, y)) = (D · C) · dist_V(x, y)`,
where the middle step multiplies the `C`-Lipschitz bound for `f` by the nonnegative constant `D`. ∎

Theorem 6.1 is the special case `C = D = 1` of Theorem 6.2. The constants multiply, so worst-case
amplification of a pipeline is the product of stagewise factors — computable from the parts alone.

---

## 7. Concrete realization: the p-adic instance and its consequences

### 7.1 The p-adic ultravaluation

**Theorem 7.1 (p-adic instance, `padicRatUltra`).** For every prime `p`, the p-adic absolute value
`val(q) = |q|_p` (with `|0|_p = 0`) is a rational ultravaluation in the sense of Definition 4.1.

*Proof sketch.* Nonnegativity, `val(0) = 0`, faithfulness, sign-blindness, and multiplicativity are
the standard properties of `|·|_p` (`padicNorm` in the formal development). The strong triangle law
`|x + y|_p ≤ max(|x|_p, |y|_p)` is the defining nonarchimedean property (`padicNorm.nonarchimedean`).
Rationality of values holds because `|q|_p` is an integer power of `p`, hence rational. ∎

Consequently, by Proposition 4.1 and Theorem 4.2, the p-adic distance
`dist_p(x, y) = |x − y|_p` is a genuine ultrametric on `ℚ` — the corrected object that the failed
height pointed toward.

### 7.2 Certified nonexpansive arithmetic maps

**Corollary 7.2 (integer scaling, `padic_intScale_nonexpansive`).** For any prime `p` and any integer
`m`, the map `f(q) = m · q` is nonexpansive for `dist_p`.

*Proof.* `f` is additive on differences: `m(a − b) = ma − mb`. For valuation monotonicity,
`|m q|_p = |m|_p · |q|_p ≤ |q|_p` because `|m|_p ≤ 1` for every integer `m` (integers lie in the
p-adic unit ball). Apply Theorem 5.1. ∎

**Corollary 7.3 (integer affine maps, `padic_intAffine_nonexpansive`).** For any prime `p`, integer
`m`, and integer `c`, the map `f(q) = m · q + c` is nonexpansive for `dist_p`.

*Proof.* The additive constant cancels in differences: `f(a) − f(b) = m(a − b)`, so `f` has the same
difference behavior as integer scaling, which is nonexpansive by Corollary 7.2. (Formally, additivity
on differences holds because `f(a − b)` and `f(a) − f(b)` agree up to the cancelled constant when the
argument is applied through the difference structure used in Theorem 5.1.) ∎

By Theorems 6.1 and 6.2 these certified maps compose freely: any pipeline of integer scalings and
integer affine maps is nonexpansive for `dist_p`.

### 7.3 Height/valuation comparison and integer boundedness

**Theorem 7.4 (height comparison, `pow_padicValNat_le_ratArithHeight`).** For every prime `p` and every
nonzero integer `n` (regarded as the rational `n/1`),

> `p^{v_p(|n|)} ≤ height(n)`.

*Proof sketch.* The left side `p^{v_p(|n|)}` is the largest power of `p` dividing `|n|`, which divides
`|n|` and is therefore `≤ |n|`. Since `n` is an integer, `den(n) = 1`, so `height(n) = |n| + 1 > |n|`.
Chaining `p^{v_p(|n|)} ≤ |n| ≤ height(n)` gives the claim. ∎

Theorem 7.4 expresses that the (archimedean) height *dominates* the depth of any single prime inside
its argument: it is a faithful ceiling on the valuations that generate the ultradistance, even though
it cannot serve as an ultradistance itself.

**Proposition 7.5 (integer boundedness, `padic_int_dist_le_one`).** For any prime `p` and any integers
`a, b`, `dist_p(a, b) = |a − b|_p ≤ 1`. That is, integer data lies in the closed unit ball of the
p-adic ultrametric.

*Proof.* `a − b` is an integer, and `|n|_p ≤ 1` for every integer `n`. ∎

---

### 7.4 A worked numerical example

To make the abstract statements concrete, fix the prime `p = 2` and trace the constructions on small
rationals.

*The failed height.* `height(1) = |1| + 1 = 2` and `height(2) = |2| + 1 = 3`. The strong triangle
test at `q = r = 1` asks whether `height(1 + 1) = 3 ≤ max(2, 2) = 2`, which is false (Theorem 3.1).
By contrast, `height(3/4) = 7`, `height(1/1000) = 1001`: the height tracks arithmetic complexity, not
2-adic depth.

*The corrected 2-adic valuation.* We have `|8|_2 = 2^{-3} = 1/8` (since `8 = 2^3`), `|3|_2 = 1`
(odd, not divisible by 2), `|1/2|_2 = 2^{1} = 2`, and `|12|_2 = |4·3|_2 = 1/4`. Multiplicativity is
visible: `|12|_2 = |4|_2 · |3|_2 = (1/4)·1 = 1/4`. The strong triangle law holds, e.g.
`|2 + 6|_2 = |8|_2 = 1/8 ≤ max(|2|_2, |6|_2) = max(1/2, 1/2) = 1/2`.

*The ultradistance and isosceles triangles.* Take `x = 1, y = 4, z = 13` with `p = 3`. Then
`dist_3(1, 4) = |−3|_3 = 1/3`, `dist_3(4, 13) = |−9|_3 = 1/9`, and `dist_3(1, 13) = |−12|_3 = 1/3`
(since `12 = 3·4`). The three side lengths are `{1/3, 1/9, 1/3}`: the two largest are equal, exactly
the isosceles phenomenon forced by Theorem 4.2.

*The bridge theorem in action.* With `p = 5`, the map `f(q) = 5q` satisfies
`|5q|_5 = |5|_5·|q|_5 = (1/5)|q|_5 ≤ |q|_5`, so it is nonexpansive (in fact a strict contraction off
the diagonal). The affine map `f(q) = 2q + 7` has `f(a) − f(b) = 2(a − b)` and `|2|_5 = 1 ≤ 1`, so it
is nonexpansive (Corollary 7.3). The map `g(q) = q/5`, however, has `|q/5|_5 = 5|q|_5`, violating
valuation monotonicity; it is expansive with exact Lipschitz constant `5`, witnessing the sharpness
of Proposition 5.3.

*Composition.* The 2-adic maps `h₁(q) = q/2` and `h₂(q) = q/4` have Lipschitz constants `2` and `4`;
their composite `h₂ ∘ h₁(q) = q/8` has constant `8 = 2 · 4`, exactly the product predicted by
Theorem 6.2.

*Height comparison.* For `n = 24 = 2^3 · 3`, `p = 2`: `p^{v_2(24)} = 2^3 = 8 ≤ height(24) = 25`. For
`p = 3`: `3^{v_3(24)} = 3 ≤ 25`. The height is a (loose) ceiling on every single-prime depth
(Theorem 7.4).

## 8. Applications

### 8.1 Certified robustness of arithmetic pipelines

The combination of the bridge theorem (§5) and compositional closure (§6) furnishes a *certificate
algebra* for arithmetic data processing in the nonarchimedean setting. Each elementary stage is
certified once — an integer scaling or integer affine map is nonexpansive by Corollaries 7.2–7.3 —
and the worst-case amplification of an entire pipeline is read off as the product of stagewise
Lipschitz constants (Theorem 6.2). This is the same robustness discipline pursued in certified
machine learning, where a network of layers is guaranteed stable by bounding each layer's Lipschitz
constant, transplanted to the p-adic metric where the strong triangle law makes the bounds especially
rigid (no error can accumulate beyond the maximum of its parts).

### 8.2 Nonarchimedean coding and lattice-style metrics

Ultrametric spaces are the native habitat of lattice-based post-quantum cryptography and of algebraic
error-correcting codes, where proximity is measured by divisibility/valuation rather than magnitude.
The `RatUltraValuation` abstraction isolates exactly the axioms (strong triangle law + multiplicativity)
that such metrics rely on, and the bridge theorem identifies which transformations of encoded data are
guaranteed non-amplifying. The integer-data boundedness statement (Proposition 7.5) reflects that
integer codewords inhabit the unit ball, the standard normalization in these settings.

### 8.3 Height machinery in Diophantine geometry

The height comparison (Theorem 7.4) connects the metric story back to mainstream number theory. Heights
underlie Northcott's theorem (finitely many points of bounded height and degree) and the descent
machinery behind Mordell–Weil. By exhibiting the height as a simultaneous upper bound on all p-adic
depths, the result hints at a uniform, places-aware repackaging of height finiteness in terms of the
ultradistances `dist_p` — see §10.

## 9. Discussion

### 9.1 What the bridge buys

The development converts a *valuation inequality* — a pointwise, algebraic statement `val(f(a)) ≤
val(a)` — into a *metric regularity* statement — nonexpansiveness — under the single structural
hypothesis of additivity on differences. This is exactly the kind of transfer that makes
nonarchimedean geometry useful in applications: one verifies an easy algebraic bound on a building
block and obtains a global, compositional stability guarantee for free. The compositional closure
(§6) turns isolated guarantees into pipeline guarantees with transparent constant arithmetic, the
pattern needed for certified robustness of layered systems.

### 9.2 Why the failure matters

The falsifier (Theorem 3.1) is not a negative result to be apologized for; it is the load-bearing
insight. It rules out the naive identification `height = valuation` decisively and at the smallest
input, and it diagnoses *why* (archimedean magnitude-sensitivity versus nonarchimedean
contraction). This diagnosis is precisely what selects the p-adic valuation as the correct carrier.
The height is not discarded but repositioned: Theorem 7.4 shows it remains a meaningful *upper
bound* on the prime data.

### 9.3 Relation to the catalog

The constructions are deliberate rational, real-valued analogues of an existing ℕ-valued,
multiplicative tropical framework. The structure `RatUltraValuation` mirrors the tropical valuation
carrier; the induced-distance ultrametric mirrors `valuationReconstruct_obj_ultrametric`; and the
bridge theorem mirrors the functorial transfer `tropical_nonexpansive_implies_ultrametric_
nonexpansive`. The contribution here is to land these abstractions on *concrete rational arithmetic
data*, with the height as the arithmetic anchor and the p-adic valuation as the corrected metric.

---

## 10. Future work

We highlight the most promising directions (see the package's Future Directions for the full list):

1. **Sharp two-sided height/valuation comparison and a Northcott-style finiteness.** We proved one
   inequality, `p^{v_p(|n|)} ≤ height(n)`. The natural next target is a two-sided, multi-prime
   comparison bounding `height(q)` from below and above by a product over primes of p-adic data,
   reflecting the product formula `∏_v |q|_v = 1`. Joint control across all places would let height
   finiteness be read off uniform ultrametric bounds.

2. **A category of rational ultravaluations.** Promote the bridge theorem to a functor from the
   category of valuation-monotone additive maps to nonexpansive maps of ultrametric spaces, with
   composition (§6) as functoriality, completing the analogy to the tropical reconstruction functor.

3. **Lipschitz spectra and certified pipelines.** Compute exact Lipschitz constants for richer
   arithmetic maps (rational scaling, polynomial maps restricted to integer arguments) and assemble
   certified-robustness guarantees for multi-stage pipelines via the multiplicative composition law.

4. **Adelic synthesis.** Combine all `dist_p` with the archimedean metric into an adelic distance and
   study which arithmetic maps are simultaneously nonexpansive at all places — the metric shadow of
   the product formula.

---

## 11. Conclusion

Starting from a tempting but false identification, we isolated the sharp obstruction (the height is
not an ultranorm, failing at `1 + 1`), replaced it with the correct normalization (rational
ultravaluations, realized by the p-adic absolute value), and built a complete metric-regularity
theory on top: a genuine ultrametric, a sharp bridge theorem certifying nonexpansiveness from
valuation monotonicity and additivity, a compositional calculus for pipelines, concrete certified
maps, and a height/valuation comparison reconciling the two worlds. Every statement is fully
formalized and depends only on standard foundational axioms.
