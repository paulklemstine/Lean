# The Non-Archimedean Valuation as a Tropical Semiring Morphism, Up to Its Defect

## Abstract

A non-Archimedean additive valuation `v : K → Γ ∪ {∞}` on a field is, simultaneously, two things: the multiplicative backbone of a homomorphism into the tropical semiring, and an *almost*-additive map whose only failures are sharply localized. We make both halves precise. Tropicalizing `v` through the canonical map `trop` yields `tropVal v : K → Tropical Γ`, `x ↦ trop(v x)`. We prove that `tropVal v` is an exact homomorphism for the multiplicative structure — bundled as a monoid homomorphism `tropValMonoidHom : K →* Tropical Γ` — and is sub-additive, `tropVal(x) + tropVal(y) ≤ tropVal(x+y)`, the tropical shadow of the ultrametric inequality. The additive defect is then completely controlled: additivity holds with *equality* whenever `v x ≠ v y` (`addValuation_add_eq_min_of_ne`), and conversely every failure of additivity forces `v x = v y` (`addValuation_defect_imp_tie`). Hence the defect locus is exactly the diagonal **tie set** `{v x = v y}`. We connect this to tropical geometry by showing that, for a two-monomial weight family, the corner-locus predicate "the minimum is attained at least twice" is equivalent to the tie condition `a = b` (`attainedTwice_fin2_iff`), so every additive defect of `v` lands on the binary corner locus (`addValuation_defect_imp_corner`). The result unifies the additive (defect) and combinatorial (corner) descriptions of tropicalization under one slogan: *morphism defect = corner locus*. All results are fully formalized and machine-checked, depending only on the standard foundational axioms (propositional extensionality, choice, quotient soundness). We also explain the obstruction to upgrading `tropVal` to a ring homomorphism, which is genuine and maximal.

## 1. Introduction

Tropical geometry replaces classical algebraic varieties with piecewise-linear polyhedral complexes, trading the field operations `(+, ·)` for the *min-plus* operations `(min, +)`. The bridge between the two worlds is a valuation. Given a non-Archimedean valued field `(K, v)`, the **tropicalization** of a subvariety is the closure of the image of its points under the coordinatewise valuation map. The Fundamental Theorem of Tropical Geometry (Kapranov; Speyer–Sturmfels) states that this image equals the corner locus of the tropicalized defining polynomials.

The "easy direction" of that theorem — tropicalization is *contained in* the corner locus — is a consequence of one elementary phenomenon: in an ultrametric, a sum of terms with a unique minimal valuation inherits that minimal valuation exactly, so a cancellation (`∑ Tᵢ = 0`) is impossible unless the minimum is achieved at least twice. This phenomenon is purely about *ties*: the ultrametric inequality `v(x+y) ≥ min(v x, v y)` is an equality away from `{v x = v y}` and can be strict only on it.

This paper isolates and formalizes the *algebraic* content of that phenomenon, independent of any variety. We package the valuation itself as a structured map into the tropical semiring and prove that:

1. It is an exact monoid homomorphism (multiplicativity has no defect).
2. It is sub-additive, with the inequality tightening to equality off the tie set.
3. The locus of additive defect is *exactly* the tie set.
4. The tie set, for two monomials, *is* a corner locus.

The conjunction is the identity "morphism defect = corner locus", settling Direction 5 of the future-directions program attached to the bridge files `TropicalValuationLimitBridge.lean` and `TropicalBezoutFactorization.lean`.

### 1.1 Contributions

- A bundled monoid homomorphism `tropValMonoidHom : K →* Tropical Γ` realizing the multiplicative half of a valuation as a tropical-semiring morphism.
- A complete characterization of the additive defect of tropicalization as the diagonal tie set (Theorems 4.1, 4.2 below).
- The identification of the binary corner locus with the tie set (Theorem 6.1), yielding the unifying statement that all additive defects are corner points (Theorem 6.2).
- A precise account of why `tropVal` cannot be a ring homomorphism, with the maximal counterexample `x + (−x) = 0`.

## 2. Preliminaries

### 2.1 Additive valuations

Throughout, `K` is a field and `Γ` is a linearly ordered additive commutative monoid with a top element `∞` (`LinearOrderedAddCommMonoidWithTop`), which serves as the value group completed by the value of `0`.

**Definition 2.1 (Additive valuation).** An *additive valuation* `v : K → Γ` is a map satisfying:

- `v 0 = ∞` and `v 1 = 0`;
- `v(x · y) = v x + v y` (multiplicativity, exact);
- `v(x + y) ≥ min(v x, v y)` (the ultrametric / non-Archimedean inequality).

We write `v : AddValuation K Γ` for the bundled object. The key consequence we use repeatedly is that the ultrametric inequality is *forced to be an equality off the diagonal*:

**Lemma 2.2 (Strict domination ⇒ equality).** If `v x < v y` then `v(x + y) = v x`. More generally `v(x + y) = min(v x, v y)` whenever `v x ≠ v y`.

This is `AddValuation.map_add_eq_of_lt_left` in the underlying library, applied after trichotomy.

### 2.2 The tropical semiring

**Definition 2.3 (Tropical semiring).** For a linearly ordered additive monoid `Γ`, the tropical semiring `Tropical Γ` has carrier (a copy of) `Γ`, with the bijection `trop : Γ → Tropical Γ` and inverse `untrop`. Its operations are:

- addition `a + b := trop(min(untrop a, untrop b))` — i.e. tropical `+` is `min`;
- multiplication `a · b := trop(untrop a + untrop b)` — i.e. tropical `·` is `+`;
- multiplicative identity `1 = trop 0`;
- additive identity `0 = trop ∞`.

These satisfy the semiring axioms; in particular `trop` is monotone and an order embedding, so `a ≤ b` in `Tropical Γ` iff `untrop a ≤ untrop b`.

### 2.3 The corner-locus predicate

**Definition 2.4 (Attained at least twice / corner locus).** For a weight function `w : ι → α` on a linearly ordered type `α`, define
```
AttainedAtLeastTwice w  :⇔  ∃ i j, i ≠ j ∧ (∀ k, w i ≤ w k) ∧ (∀ k, w j ≤ w k).
```
That is, the global minimum of `w` is achieved by two distinct indices. Geometrically, when `w` is the family of monomial values of a tropical polynomial at a point, `AttainedAtLeastTwice w` says the point lies on the *corner locus* (tropical hypersurface): the defining minimum is non-smooth there.

## 3. The single additive defect is controlled by the tie set

We first record the two facts that pin the additive behaviour of `v` to its diagonal.

**Theorem 3.1 (Additivity off the tie set, `addValuation_add_eq_min_of_ne`).** Let `v : AddValuation K Γ` and `x, y : K` with `v x ≠ v y`. Then
```
v(x + y) = min(v x, v y).
```

*Proof sketch.* Apply trichotomy to `v x` versus `v y`. The case `v x = v y` is excluded by hypothesis. If `v x < v y`, then `x` strictly dominates and `AddValuation.map_add_eq_of_lt_left` gives `v(x+y) = v x = min(v x, v y)`; the symmetric case `v y < v x` is identical. ∎

**Theorem 3.2 (Defect locus ⊆ tie set, `addValuation_defect_imp_tie`).** Let `v : AddValuation K Γ` and `x, y : K` with `v(x + y) ≠ min(v x, v y)`. Then `v x = v y`.

*Proof sketch.* Contrapositive of Theorem 3.1: if `v x ≠ v y`, Theorem 3.1 yields `v(x+y) = min(v x, v y)`, contradicting the assumed defect. Hence `v x = v y`. ∎

Theorems 3.1–3.2 together state that the *defect locus* `{(x,y) : v(x+y) ≠ min(v x, v y)}` is contained in the *tie set* `{(x,y) : v x = v y}`. The containment can be strict — ties do not *force* cancellation — but every cancellation is a tie.

## 4. Tropicalization as a monoid morphism plus a defect

**Definition 4.1 (Tropicalization map, `tropVal`).** For `v : AddValuation K Γ`, define
```
tropVal v : K → Tropical Γ,    tropVal v x := trop (v x).
```

**Theorem 4.2 (Unit, `tropVal_one`).** `tropVal v 1 = 1`.

*Proof sketch.* `v 1 = 0` (valuation axiom), and the tropical unit is `trop 0`; hence `trop (v 1) = trop 0 = 1`. ∎

**Theorem 4.3 (Exact multiplicativity, `tropVal_mul`).** For all `x, y : K`,
```
tropVal v (x · y) = tropVal v x · tropVal v y    (tropical product).
```

*Proof sketch.* Unfold: `tropVal v (x·y) = trop(v(x·y)) = trop(v x + v y)`. Tropical multiplication is defined so that `trop(a + b) = trop a · trop b`, giving `trop(v x) · trop(v y) = tropVal v x · tropVal v y`. The multiplicativity axiom of `v` is the only ingredient; there is no defect. ∎

**Definition 4.4 (Bundled morphism, `tropValMonoidHom`).** The data of Theorems 4.2–4.3 assemble into a monoid homomorphism
```
tropValMonoidHom v : K →* Tropical Γ,    toFun = tropVal v,
    map_one' = tropVal_one,    map_mul' = tropVal_mul.
```
This is the "honest half" of the bridge: the multiplicative structure of `K` maps onto the multiplicative (min-plus additive) structure of the tropical semiring with no loss.

**Theorem 4.5 (Sub-additivity, `tropVal_add_le`).** For all `x, y : K`,
```
tropVal v x + tropVal v y ≤ tropVal v (x + y)    (tropical sum on the left).
```

*Proof sketch.* Tropical addition is `min`, so the left side is `trop(min(v x, v y))`. The claim is `trop(min(v x, v y)) ≤ trop(v(x+y))`, i.e. by monotonicity of `trop`, `min(v x, v y) ≤ v(x+y)` — exactly the ultrametric inequality `AddValuation.map_add`. ∎

**Theorem 4.6 (Additivity off the tie set, tropical form, `tropVal_add_eq_of_ne`).** If `v x ≠ v y` then
```
tropVal v x + tropVal v y = tropVal v (x + y).
```

*Proof sketch.* By Theorem 3.1, `v(x+y) = min(v x, v y)`, so `trop(v(x+y)) = trop(min(v x, v y)) = tropVal v x + tropVal v y`. The sub-additive inequality of Theorem 4.5 becomes an equality precisely where Theorem 3.1 applies. ∎

Thus `tropVal v` is a monoid homomorphism that is additionally additive everywhere except, possibly, on the tie set `{v x = v y}` — and on that set it can fail.

## 5. The obstruction to a ring homomorphism

It is natural to ask whether `tropVal v` extends to a semiring/ring homomorphism, i.e. whether additivity is exact everywhere. It is not, and the failure is maximal.

**Proposition 5.1 (No additive homomorphism).** For any `x ≠ 0`, taking `y = −x` gives `x + y = 0`, so
```
tropVal v (x + y) = trop (v 0) = trop ∞ = 0_{Tropical}  (the tropical additive identity),
```
whereas the predicted value is
```
tropVal v x + tropVal v y = trop(min(v x, v(−x))) = trop(v x),
```
a finite (non-`0_{Tropical}`) element. The two differ. Since `v(−x) = v x`, this defect occurs *on the tie set*, consistent with Theorem 3.2, and it is the largest possible defect (an infinite gap in `Γ`).

*Discussion.* Proposition 5.1 explains the asymmetry in the packaging: the correct structure is a **monoid homomorphism plus a sub-additivity inequality**, not a ring homomorphism. The additive imperfection is intrinsic and is exactly what makes valuations *measure cancellation* rather than merely transport addition. ∎

## 6. Morphism defect = corner locus

We now connect the algebraic defect to the combinatorial corner locus of Definition 2.4.

**Theorem 6.1 (Two-monomial corner locus = tie set, `attainedTwice_fin2_iff`).** Let `a b : α` and consider the two-element weight family `w : Fin 2 → α`, `w = ![a, b]`. Then
```
AttainedAtLeastTwice w  ⇔  a = b.
```

*Proof sketch.* (⇐) If `a = b`, the two distinct indices `0, 1` both achieve `min(a, b) = a = b`, witnessing the predicate. (⇒) The only pair of distinct indices in `Fin 2` is `{0, 1}`. If both achieve the global minimum, then `w 0 ≤ w 1` and `w 1 ≤ w 0`, i.e. `a ≤ b` and `b ≤ a`, hence `a = b`. ∎

**Theorem 6.2 (Defects are corners, `addValuation_defect_imp_corner`).** Let `v : AddValuation K Γ` and `x, y : K` with `v(x + y) ≠ min(v x, v y)`. Then the two-monomial weight family `![v x, v y]` lies on the corner locus:
```
AttainedAtLeastTwice (![v x, v y]).
```

*Proof sketch.* By Theorem 3.2 the defect forces `v x = v y`; by Theorem 6.1 (with `a = v x`, `b = v y`) this is exactly the corner-locus condition for `![v x, v y]`. ∎

Theorem 6.2 is the headline identification. Every additive defect of the valuation — every point where tropicalization fails to be additive — is, verbatim, a corner of the associated two-monomial tropical polynomial. The algebraic failure locus and the geometric crease locus coincide.

### 6.1 Relation to the Fundamental Theorem (easy direction)

The companion result `kapranov_easy_direction` states: if a point lies on a classical hypersurface `∑ᵢ Tᵢ = 0` with not all `Tᵢ` vanishing, then the tropicalized weights `i ↦ v(Tᵢ)` attain their minimum at least twice. Its proof is the *winner-takes-all* lemma: if the minimum were unique, the sum would inherit that finite valuation, contradicting `v(0) = ∞`. Theorem 6.2 is the two-term, defect-centric refinement: where Kapranov needs an entire vanishing sum to produce a corner, the present result shows that even a *single binary cancellation* — `v(x+y)` exceeding `min(v x, v y)` — already produces one. Both are powered by the same fact (Lemma 2.2): away from ties, one valuation strictly wins and pins the sum.

## 7. Algorithms

The theory is constructive enough to be checked numerically. We summarize the core procedures (full implementations appear in the accompanying `demo.py`).

**Algorithm 7.1 (p-adic valuation).** Given a prime `p` and a nonzero rational `x = a/b`, return `v_p(a) − v_p(b)`, where `v_p(n)` counts factors of `p` in the integer `n`. Define `v_p(0) = ∞`. Complexity: `O(log_p |x|)` divisions.

**Algorithm 7.2 (Defect detector).** Given `v`, `x`, `y`, compute `lhs = v(x+y)` and `rhs = min(v x, v y)`. Report a *defect* when `lhs ≠ rhs`, and assert (by Theorem 3.2) that any reported defect satisfies `v x = v y`. Complexity: three valuation evaluations.

**Algorithm 7.3 (Corner-locus checker for two monomials).** Given weights `a, b`, return `a == b` (Theorem 6.1). Cross-check against the brute-force search over the two index pairs of `Fin 2` for the corner predicate.

## 7bis. Worked examples over the 3-adic rationals

To make the theorems concrete we instantiate `K = ℚ`, `Γ = ℤ ∪ {∞}`, and `v = v_3`, the 3-adic valuation. Recall `v_3(n)` counts factors of `3`, so `v_3(3) = 1`, `v_3(9) = 2`, `v_3(5) = 0`, `v_3(0) = ∞`.

**Example A (multiplicativity, exact).** Take `x = 9`, `y = 3`. Then `v(x·y) = v_3(27) = 3`, while `v(x) + v(y) = 2 + 1 = 3`. The tropical product `tropVal x ⊙ tropVal y = trop(3)` equals `tropVal(x·y)`. As guaranteed by Theorem 4.3, there is no defect; this holds for every choice of `x, y`.

**Example B (additivity off the tie set).** Take `x = 3` (`v = 1`) and `y = 9` (`v = 2`), so `v x ≠ v y`. Then `x + y = 12 = 4·3`, giving `v(x+y) = 1 = min(1, 2)`. The sub-additivity inequality of Theorem 4.5 is an equality here, exactly as Theorem 3.1 (resp. its tropical form 4.6) predicts: away from ties, the lower-order term dominates and the sum inherits its valuation.

**Example C (a defect on the tie set).** Take `x = 3`, `y = 6`, both with `v = 1` (a tie). Then `x + y = 9`, so `v(x+y) = 2 > 1 = min(v x, v y)`. This is a genuine additive defect: the leading 3-parts (`3·1` and `3·2`) summed to `3·3`, raising the order. By Theorem 3.2 the defect *forces* the tie `v x = v y`, which it does. By Theorem 6.2 the weight family `![1, 1]` lies on the corner locus — and indeed both indices of `![1,1]` achieve the minimum `1`.

**Example D (the maximal defect / no ring homomorphism).** Take `x = 3`, `y = −3`. Both have `v = 1` (a tie), but `x + y = 0`, so `v(x+y) = ∞`. The defect is now infinite, the largest possible: this is Proposition 5.1 in action and the precise reason `tropVal` cannot be promoted to an additive (ring) homomorphism. Consistent with Theorem 3.2, the defect sits on the tie set.

**Example E (a tie without a defect).** Take `x = 3`, `y = −6`, both `v = 1` (a tie). Then `x + y = −3`, `v(x+y) = 1 = min(1, 1)`: no defect, even though we are on the tie set. This shows the containment of Theorem 3.2 (defect ⊆ tie) is *strict*: ties are necessary but not sufficient for a defect. The corner-locus membership of `![1,1]` still holds (it depends only on the tie), illustrating that the corner locus is the *closure* of the defect phenomenon, capturing where cancellation is *possible*.

These five examples exhaust the qualitative cases and are reproduced, with assertions, in the accompanying `demo.py`.

## 8. Applications

- **Tropicalization of varieties.** The monoid homomorphism `tropValMonoidHom` transports every multiplicative identity in `K` into a tropical identity. Combined with the companion `eval_mul` and `tropRoot_mul_iff` (the tropical hypersurface of a product is the union of hypersurfaces), this gives the multiplicative scaffolding for tropical Bézout-type degree counts: factorizations become Minkowski sums of Newton polytopes.
- **Cancellation diagnostics.** Theorems 3.1–3.2 give an exact criterion for when summation in a valued field loses precision (a valuation jump): precisely on ties. This is the algebraic analogue of catastrophic cancellation in floating point, with an exact predictor.
- **Scale-invariant limits.** Because corner membership depends only on which weights tie, rescaling `v ↦ t·v` (`t > 0`) preserves the corner locus. The "valuation → ∞" limit of the amoeba is therefore the fixed shape already shared by the whole family, not an analytic limit of moving sets.

## 9. Discussion

The conceptual payoff is the reframing of a valuation as a *defective homomorphism whose defect is the geometry*. The multiplicative half is exact and bundled; the additive half is an inequality whose failures are confined to, and characterize, the tie set; and the tie set is, for two monomials, literally a tropical corner. This dissolves the apparent gap between the algebraic and combinatorial descriptions of tropicalization: they are two readings of the same defect.

A methodological remark: the proofs are uniformly *one-step* reductions to a single underlying fact (Lemma 2.2 / `AddValuation.map_add_eq_of_lt_left`). Tropicalizing through `trop` turns each valuation axiom into a tropical-semiring (in)equality verbatim. The economy of the proofs is itself evidence that the packaging is the natural one.

## 10. Future Directions

(See the dedicated future-directions material in the package metadata.) The principal open targets are Kapranov's *hard* direction (surjectivity onto the corner locus via a Newton-polygon/Hensel lifting, starting from the univariate seed) and the *balancing condition* as a conservation law (the tie set that proves corner membership should carry the balanced-fan data for free). The morphism picture suggests three further programs: bundling the defect as an explicit `defect : K × K → Γ` cocycle; characterizing when the defect-locus containment of Theorem 3.2 is an equality; and extending `tropValMonoidHom` to a structured "morphism with controlled defect" abstraction reusable across valued-field constructions.

## 11. Conclusion

A non-Archimedean valuation is an exact tropical monoid homomorphism whose only additive imperfection lives precisely on the diagonal tie set, which is precisely the binary corner locus. Multiplication translates flawlessly; addition translates as a controlled inequality; and the controlled failures are the seeds of tropical geometry. *Morphism defect = corner locus.*

## Appendix A. Formalization summary

All statements are machine-checked. The principal declarations are:

- `addValuation_add_eq_min_of_ne` — Theorem 3.1.
- `addValuation_defect_imp_tie` — Theorem 3.2.
- `tropVal`, `tropVal_one`, `tropVal_mul` — Definition 4.1, Theorems 4.2–4.3.
- `tropValMonoidHom : K →* Tropical Γ` — Definition 4.4.
- `tropVal_add_le`, `tropVal_add_eq_of_ne` — Theorems 4.5–4.6.
- `attainedTwice_fin2_iff` — Theorem 6.1.
- `addValuation_defect_imp_corner` — Theorem 6.2.

The development depends only on the standard foundational axioms: propositional extensionality, the axiom of choice, and quotient soundness.
