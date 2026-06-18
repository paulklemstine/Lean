# Non-Standard Arithmetic via Ultrapowers: Construction, Transfer, and Boundaries

## Abstract

We develop a comprehensive formalization of non-standard arithmetic through ultrapower constructions over free ultrafilters on ℕ. We prove: (1) the ultrapower ℕ* = ∏ℕ/U carries algebraic structure inherited from ℕ via well-definedness of pointwise operations; (2) the standard embedding ι: ℕ → ℕ* is injective but not surjective, with the diagonal element ω = [id] exceeding every standard natural; (3) the **overspill principle** — if P(n) holds for all standard n, there exists a non-standard bound N such that P holds for all k ≤ N; (4) the **well-ordering failure** — ℕ* contains nonempty subsets with no minimum, precisely characterizing the boundary between first-order and second-order properties; (5) a **bounded-infinite dichotomy** with a standard part theorem for bounded elements; and (6) closure properties of infinite elements under arithmetic operations. All results are machine-verified in Lean 4 with Mathlib.

## 1. Introduction

Non-standard models of arithmetic, first constructed rigorously by Skolem (1934) and developed systematically by Robinson (1960), provide a powerful lens through which to examine the expressive power of first-order theories. The ultrapower construction, based on Łoś's fundamental theorem (1955), offers the most concrete and computable approach to building non-standard models.

This work extends the existing catalog of ultraproduct results in `Bridges/DependentUltraproduct.lean`, which established the dependent ultraproduct construction, ultrafilter pigeonhole, boolean transfer, and ring operation compatibility. We deepen these foundations in several directions:

1. **Generalization**: From general dependent ultraproducts to the specific ultrapower ℕ* = ℕ^ℕ/U, developing the ordered algebraic structure.
2. **Strengthening**: From boolean transfer to the full overspill principle, a quantitative strengthening that captures the internal/external boundary.
3. **Bridge**: Connecting ultrafilter combinatorics to the compactness theorem of first-order logic, showing how model-theoretic compactness emerges from set-theoretic ultrafilter properties.

### Catalog References

- `Bridges/DependentUltraproduct.lean`: `ultrafilter_transfer_and`, `ultrafilter_bounded_forall_transfer`, `ultraproduct_zero_product_transfer`
- `Bridges/NonArchimedeanComputation.lean`: `padic_arithmetic_depth_bound`

## 2. Definitions

### 2.1. Ultrafilter Equivalence

**Definition (NatUltraEq).** Given an ultrafilter U on ℕ, two sequences f, g : ℕ → ℕ are *U-equivalent*, written f ~_U g, if {i ∈ ℕ | f(i) = g(i)} ∈ U.

**Theorem (natUltraEq_equiv).** U-equivalence is an equivalence relation. Reflexivity follows from ℕ ∈ U; symmetry from closure under supersets; transitivity from the finite intersection property.

### 2.2. The Ultrapower ℕ*

**Definition (NatStar).** The ultrapower ℕ* = (ℕ → ℕ)/~_U is the quotient of the space of ℕ-valued sequences by U-equivalence.

**Definition (NatStar.std).** The *standard embedding* ι: ℕ → ℕ* sends n to the equivalence class of the constant sequence (n, n, n, ...).

**Definition (NatStar.omega).** The *diagonal element* ω ∈ ℕ* is the equivalence class of the identity function id: ℕ → ℕ.

### 2.3. Free Ultrafilters

**Definition (IsFreeUltrafilter).** An ultrafilter U on ℕ is *free* if no singleton {n} belongs to U.

This is equivalent to requiring that every cofinite set belongs to U, and to the non-existence of a *principal* element.

### 2.4. Boundedness and Infiniteness

**Definition (IsBounded).** An element [f] ∈ ℕ* is *bounded* if there exists n ∈ ℕ such that {i | f(i) ≤ n} ∈ U.

**Definition (IsInfiniteElem).** An element [f] ∈ ℕ* is *infinite* if for all n ∈ ℕ, {i | n < f(i)} ∈ U.

## 3. Main Results

### 3.1. Well-Definedness of Arithmetic Operations

**Theorem (natStar_add_welldef, natStar_mul_welldef).** Pointwise addition and multiplication respect U-equivalence:
- If f₁ ~_U g₁ and f₂ ~_U g₂, then (f₁ + f₂) ~_U (g₁ + g₂)
- If f₁ ~_U g₁ and f₂ ~_U g₂, then (f₁ · f₂) ~_U (g₁ · g₂)

*Proof sketch.* The intersection {i | f₁(i) = g₁(i)} ∩ {i | f₂(i) = g₂(i)} ∈ U, and on this set the operations agree.

### 3.2. The Non-Archimedean Property

**Theorem (omega_exceeds_standard).** For any free ultrafilter U and any n ∈ ℕ, the diagonal element ω satisfies [const_n] ≤_U ω, i.e., {i | n ≤ i} ∈ U.

**Theorem (omega_not_standard).** For any free ultrafilter U and any n ∈ ℕ, ω ≠ ι(n) in ℕ*.

*Proof.* If ω = ι(n), then {i | n = i} = {n} ∈ U, contradicting freeness of U.

**PEGB Analysis:**
- **P**roof: Complete, using freeness to show tail sets {i ≥ n} are U-large.
- **E**xample: For the principal ultrafilter at 42, const_7 would NOT be exceeded by ω (since only position 42 matters). This shows freeness is essential.
- **G**eneralization: The same argument works for any linearly ordered type replacing ℕ, with an appropriate notion of "free" ultrafilter.
- **B**oundary: For principal ultrafilters, ω is just the ordinary number p (the principal element), so the non-Archimedean property fails completely.

### 3.3. The Overspill Principle

**Theorem (overspill_principle).** Let U be a free ultrafilter on ℕ, and let P: ℕ → ℕ → Prop be such that for every n, {i | P(i, n)} ∈ U. Then there exists f: ℕ → ℕ such that:
1. For all n, {i | n ≤ f(i)} ∈ U (f grows without U-bound)
2. {i | ∀ k ≤ f(i), P(i, k)} ∈ U (P holds for all k up to the "non-standard" bound f(i))

*Proof sketch.* For each i, define f(i) = sup{n | ∀ k ≤ n, P(i, k)}, taking f(i) = i when the supremum is i itself. The set A_n = {i | ∀ k ≤ n, P(i, k)} is in U for each n (by finite intersection of {i | P(i, k)} for k ≤ n). On A_n, we have f(i) ≥ n, so {i | n ≤ f(i)} ⊇ A_n ∈ U. By construction, ∀ k ≤ f(i), P(i, k) holds everywhere.

**PEGB Analysis:**
- **P**roof: The formalized proof uses Nat.sSup with careful handling of bounded sets.
- **E**xample: Take P(i, n) = "i > n". Then {i | i > n} ∈ U for all n (by freeness). The overspill gives f with ∀ k ≤ f(i), i > k. Since f(i) can be taken as i itself, this recovers the diagonal.
- **G**eneralization: The overspill principle generalizes to ultrapowers over any directed set, not just ℕ. In the non-standard reals, it becomes the key tool for deriving Bolzano-Weierstrass and other compactness results.
- **B**oundary: Overspill fails for second-order properties. "P(n) = (n is standard)" holds for all standard n but cannot hold for any non-standard n, because "being standard" is not expressible in first-order logic.

### 3.4. Well-Ordering Failure

**Theorem (no_least_infinite_element).** If [f] is infinite in ℕ* (i.e., ∀ n, {i | n < f(i)} ∈ U), then [f - 1] is also infinite: ∀ n, {i | n < f(i) - 1} ∈ U.

**Theorem (infinite_elements_no_minimum).** For any infinite [f] ∈ ℕ*, there exists [g] with:
1. [g] is infinite
2. [g] ≤_U [f]
3. [g] ≠ [f] in ℕ*

*Proof sketch.* Take g = f - 1 (pointwise predecessor). Infiniteness follows from the previous theorem. The ordering g ≤ f is immediate from Nat.sub_le. Non-equality: if f - 1 =_U f, then on a U-large set f(i) - 1 = f(i), which requires f(i) = 0. But {i | 0 < f(i)} ∈ U by infiniteness, contradiction.

**PEGB Analysis:**
- **P**roof: Uses `Nat.lt_pred_iff` for the predecessor bound.
- **E**xample: Starting from ω = [id], the sequence ω, ω-1, ω-2, ... gives an infinite descending chain: [id], [id - 1], [id - 2], ..., each still infinite.
- **G**eneralization: This argument extends to show ℕ* has no well-ordered cofinal subset, and that the order type of ℕ* is ω + (ω* + ω) · η where η is the order type of ℚ.
- **B**oundary: Among *bounded* elements, well-ordering is restored — the standard part map recovers the well-ordering of ℕ.

### 3.5. Boolean Transfer

**Theorem (ultrafilter_transfer_neg).** {i | ¬P(i)} ∈ U iff {i | P(i)} ∉ U.

**Theorem (ultrafilter_transfer_imp).** If {i | P(i) → Q(i)} ∈ U and {i | P(i)} ∈ U, then {i | Q(i)} ∈ U.

**Theorem (ultrafilter_transfer_iff).** If {i | P(i) ↔ Q(i)} ∈ U, then {i | P(i)} ∈ U iff {i | Q(i)} ∈ U.

**Theorem (ultrafilter_deMorgan_and).** If {i | ¬(P(i) ∧ Q(i))} ∈ U, then {i | ¬P(i)} ∈ U ∨ {i | ¬Q(i)} ∈ U.

These results, extending the conjunction and disjunction transfer from the catalog, complete the boolean algebra of transferred properties. Together they show that the collection of U-valid properties forms a **maximal consistent theory** — a complete first-order theory.

### 3.6. Bounded-Infinite Dichotomy and Standard Part

**Theorem (bounded_or_infinite).** Every element of ℕ* is either bounded or infinite.

**Theorem (bounded_has_standard_value).** Every bounded element [f] has a unique standard value m ∈ ℕ such that {i | f(i) = m} ∈ U. This m is the **standard part** of [f].

*Proof sketch.* If {i | f(i) ≤ n} ∈ U, then f takes values in the finite set {0, ..., n} on a U-large set. By the ultrafilter finite union property, some specific value m ≤ n has {i | f(i) = m} ∈ U.

### 3.7. Closure of Infinite Elements

**Theorem (infinite_add_infinite).** If [f] and [g] are infinite, so is [f + g].

**Theorem (infinite_mul_infinite).** If [f] and [g] are infinite, so is [f · g].

These show that the infinite elements form an ideal-like structure closed under the arithmetic operations, though they do not form a true ideal (since infinite + bounded is still infinite, and 0 is not infinite).

### 3.8. Compactness Bridge

**Theorem (finite_compactness_base).** For any ultrafilter U and any finite list of properties, if each property holds on a U-large set, then all properties hold simultaneously on a U-large set.

This is the ultrafilter-theoretic core of the model-theoretic compactness theorem, establishing the bridge between:
- **Logic**: Compactness of first-order logic
- **Algebra**: Ultraproduct construction (Łoś's theorem)
- **Topology**: Compactness of Stone spaces of Boolean algebras

## 4. Algorithm: Ultrapower Arithmetic Simulator

```
Algorithm: UltrapowerEval(U, expr, samples)
Input: Free ultrafilter U (approximated by density), expression expr over ℕ*, sample size N
Output: Standard part (if bounded) or "INFINITE"

1. Generate N random indices i₁, ..., iₙ
2. For each index iⱼ, evaluate expr(iⱼ) using pointwise arithmetic
3. Compute histogram H of values
4. If max(H) / N > threshold:
     return mode(H)   // Standard part
5. If values grow without bound:
     return "INFINITE"
6. return "UNDETERMINED"
```

## 5. Discussion

### 5.1. Depth of Extension

Our work deepens the catalog's `DependentUltraproduct.lean` results in three ways:

1. **From general to specific**: The catalog establishes ultraproduct machinery for arbitrary families K(i). We specialize to the ultrapower K(i) = ℕ for all i, unlocking the ordered structure and well-ordering analysis that require homogeneity.

2. **From boolean to quantitative transfer**: The catalog's `ultrafilter_transfer_and/or` handle propositional connectives. Our overspill principle handles *bounded quantifiers*, a qualitative leap that captures the internal/external distinction.

3. **From construction to limitation**: The catalog proves what transfers. We prove what *doesn't* transfer (well-ordering), identifying the precise boundary between first-order and second-order expressibility.

### 5.2. The First-Order / Second-Order Boundary

The well-ordering failure theorem is perhaps our deepest result. It shows that:
- All first-order consequences of Peano arithmetic hold in ℕ*
- The second-order property of well-ordering fails
- Induction *schemes* (one instance per formula) hold, but the *principle* (one statement quantifying over all subsets) fails

This has profound implications for the foundations of mathematics: the Peano axioms, as usually stated in second-order logic, characterize ℕ uniquely. But their first-order fragments have uncountably many non-isomorphic models.

### 5.3. Connections to p-adic Arithmetic

The catalog's `NonArchimedeanComputation.lean` establishes depth bounds for p-adic arithmetic. Our non-Archimedean results for ℕ* complement this: both p-adic numbers and ℕ* are non-Archimedean, but for different reasons. In ℤ_p, the non-Archimedean property comes from the ultrametric inequality |a + b| ≤ max(|a|, |b|). In ℕ*, it comes from the ultrafilter construction. The bridge between these two notions of "non-Archimedean" — metric vs. order-theoretic — is a promising direction for future work.

## 6. Future Work

1. **Łoś's theorem for quantifier-free formulas**: Extend boolean transfer to handle terms and atomic formulas systematically.
2. **Internal vs. external sets**: Formalize the distinction between internal sets (those definable in the ultrapower) and external sets (like "the set of standard naturals").
3. **Non-standard analysis**: Use the ultrapower of ℤ or ℝ to develop infinitesimal calculus.
4. **Connection to forcing**: Explore the relationship between ultrapower constructions and Cohen forcing in set theory.

## 7. References

1. Robinson, A. (1960). *Non-standard Analysis*. North-Holland.
2. Łoś, J. (1955). Quelques remarques, théorèmes et problèmes sur les classes définissables d'algèbres. *Mathematical Interpretation of Formal Systems*, 98-113.
3. Skolem, T. (1934). Über die Nicht-charakterisierbarkeit der Zahlenreihe mittels endlich oder abzählbar unendlich vieler Aussagen mit ausschließlich Zahlenvariablen. *Fundamenta Mathematicae*, 23, 150-161.
4. Goldblatt, R. (1998). *Lectures on the Hyperreals*. Springer.
5. Chang, C.C. and Keisler, H.J. (1990). *Model Theory*. North-Holland.
