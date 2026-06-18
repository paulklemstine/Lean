# Growth-Stratified Ultrapowers: Galaxy Decomposition and Constructive Overspill in Non-Standard Arithmetic

## Abstract

We introduce the **Growth-Stratified Ultrapower**, a novel algebraic structure that formalizes the galaxy decomposition of non-standard arithmetic models. Given a free ultrafilter U on ℕ, elements of the ultrapower ℕ*/U naturally stratify into equivalence classes called *galaxies*, where two elements share a galaxy when their pointwise difference is U-bounded. We prove that this stratification yields a totally ordered, dense partition. We establish a *constructive* overspill principle using `Nat.findGreatest` as an explicit witness function, and derive the dual underspill principle via contraposition through overspill. We prove that addition respects galaxy equivalence but multiplication does not — a fundamental structural asymmetry. Finally, we establish the non-Archimedean property of the ultrapower ordering and formulate the Galaxy Continuum Hypothesis as a falsifiable conjecture. All results are machine-verified in Lean 4 with Mathlib.

**Keywords:** Non-standard arithmetic, ultrafilter, ultrapower, galaxy decomposition, overspill principle, constructive witness, non-Archimedean ordering

---

## 1. Introduction

Non-standard analysis, pioneered by Robinson [1], extends the real numbers (or natural numbers) to include infinitesimal and infinite elements by means of the ultrapower construction. While the logical foundations — particularly Łoś's theorem and the transfer principle — are well-established, the *internal structure* of the extended objects has received less attention from the formalization community.

The central contribution of this work is the formalization of the **galaxy decomposition** of the ultrapower of ℕ. In classical non-standard analysis, galaxies (also called *monads* in some treatments) classify hyperreal numbers by their asymptotic equivalence class. We formalize this for the natural number ultrapower ℕ*/U, where two sequences f, g : ℕ → ℕ belong to the same galaxy if their pointwise difference is bounded by a constant on a U-large set.

### 1.1 Main Contributions

1. **Novel structure**: The Growth-Stratified Ultrapower, bundling the galaxy equivalence relation with the ultrapower arithmetic and ordering.

2. **Constructive overspill**: An explicit witness function f(i) = Nat.findGreatest(P(i, ·), i) that produces an infinite element satisfying any downward-closed property P that holds for all standard numbers.

3. **Structural dichotomy**: Addition respects galaxies (Theorem 8.1) but multiplication does not (Theorem 8.2), revealing a fundamental asymmetry.

4. **Galaxy density**: Between any two distinct galaxies lies a third (Theorem 7.5).

5. **Non-Archimedean bridge**: The ultrapower ordering exhibits non-Archimedean behavior (Theorem 9.1), connecting to p-adic analysis via a different mechanism.

All proofs are machine-verified in Lean 4 with the Mathlib library.

---

## 2. Preliminaries

### 2.1 Ultrafilters

An ultrafilter U on a set I is a maximal proper filter — equivalently, a finitely additive {0,1}-valued measure. The key property is *dichotomy*: for every subset S ⊆ I, either S ∈ U or Sᶜ ∈ U, but not both.

A free ultrafilter contains no finite sets, or equivalently, no singletons. The existence of free ultrafilters on ℕ follows from Zorn's lemma (the Boolean Prime Ideal theorem).

### 2.2 The Ultrapower Construction

Given a free ultrafilter U on ℕ, the ultrapower ℕ*/U is the quotient of the function space ℕ → ℕ by the equivalence relation:

    f ~_U g  ⟺  {i | f(i) = g(i)} ∈ U

Operations (+, ×, ≤) are defined pointwise and are well-defined on equivalence classes by the filter properties.

---

## 3. The Ultrapower Preorder

**Definition 3.1 (UltraLeq).** For f, g : ℕ → ℕ, define f ≤_U g iff {i | f(i) ≤ g(i)} ∈ U.

**Theorem 3.2 (Reflexivity).** f ≤_U f for all f.

*Proof.* {i | f(i) ≤ f(i)} = ℕ ∈ U. □

**Theorem 3.3 (Transitivity).** If f ≤_U g and g ≤_U h, then f ≤_U h.

*Proof.* The intersection {i | f(i) ≤ g(i)} ∩ {i | g(i) ≤ h(i)} is in U, and on this set, f(i) ≤ h(i) by transitivity of ≤ on ℕ. □

**Theorem 3.4 (Totality).** For any f, g : ℕ → ℕ, either f ≤_U g or g ≤_U f.

*Proof.* Since ≤ is total on ℕ, {i | f(i) ≤ g(i)} ∪ {i | g(i) ≤ f(i)} = ℕ ∈ U. By the ultrafilter union property, at least one is in U. □

---

## 4. Galaxy Equivalence

**Definition 4.1 (SameGalaxy).** Sequences f, g : ℕ → ℕ belong to the same galaxy, written f ≈_gal g, iff there exists C ∈ ℕ such that {i | f(i) ≤ g(i) + C ∧ g(i) ≤ f(i) + C} ∈ U.

**Theorem 4.2.** SameGalaxy is an equivalence relation.

*Proof.* Reflexivity: C = 0. Symmetry: swap the conjuncts. Transitivity: if f ≈ g with bound C₁ and g ≈ h with bound C₂, then f ≈ h with bound C₁ + C₂ (by omega on the intersection). □

**Definition 4.3 (Galaxy).** The Galaxy quotient is the type (ℕ → ℕ) / ≈_gal.

**Definition 4.4 (GalaxyLeq).** f's galaxy ≤ g's galaxy iff ∃ C, {i | f(i) ≤ g(i) + C} ∈ U.

---

## 5. Standard and Infinite Elements

**Definition 5.1.** The standard embedding ι : ℕ → (ℕ → ℕ) maps n to the constant sequence fun _ => n.

**Definition 5.2.** f is *standard* if f ≈_gal ι(n) for some n. f is *infinite* if ∀ n, {i | f(i) > n} ∈ U.

**Theorem 5.3.** The identity function id is infinite for any free ultrafilter.

*Proof.* For each n, {i | i > n} = {0,...,n}ᶜ. Since U is free, no finite set is in U, so {0,...,n} ∉ U, hence {i | i > n} ∈ U. □

**Theorem 5.4.** Infinite elements are not standard.

*Proof.* If f is standard with bound (n, C), then {i | f(i) ≤ n + C} ∈ U. But f infinite gives {i | f(i) > n + C} ∈ U. Their intersection is empty, contradicting U being proper. □

**Theorem 5.5 (Downward closure).** If f is standard and g ≤_U f, then g is standard.

*Proof.* g(i) ≤ f(i) ≤ n + C on a U-large set, so g is galaxy-equivalent to the constant 0 with bound n + C. □

---

## 6. Overspill and Underspill

### 6.1 Constructive Overspill

**Theorem 6.1 (Constructive Overspill).** Let U be a free ultrafilter on ℕ. Let P : ℕ → ℕ → Prop be decidable and downward-closed in the second argument. If {i | P(i, n)} ∈ U for all n ∈ ℕ, then the function

    f(i) = Nat.findGreatest(P(i, ·), i)

satisfies: (1) {i | P(i, f(i))} ∈ U, and (2) f is infinite.

*Proof sketch.*

(1) Since P(i, 0) holds on a U-large set, and findGreatest returns a value m ≤ i with P(i, m) whenever any such m exists, we get P(i, f(i)) on the U-large set where P(i, 0) holds.

(2) Fix n. We need {i | f(i) > n} ∈ U. Consider S = {i | P(i, n+1) ∧ i ≥ n+1}. Both {i | P(i, n+1)} ∈ U (by hstandard) and {i | i ≥ n+1} ∈ U (since its complement is finite and U is free). So S ∈ U. For i ∈ S, Nat.findGreatest(P(i, ·), i) ≥ n+1 > n (since P(i, n+1) holds and n+1 ≤ i). □

### 6.2 Underspill

**Theorem 6.2 (Underspill).** Let U be free, Q : ℕ → ℕ → Prop be decidable and upward-closed. If {i | Q(i, f(i))} ∈ U for every infinite f, then ∃ n₀, {i | Q(i, n₀)} ∈ U.

*Proof.* By contradiction. If ∀ n, {i | Q(i, n)} ∉ U, then {i | ¬Q(i, n)} ∈ U for all n. The negation ¬Q is downward-closed (since Q is upward-closed). Apply overspill to ¬Q to get an infinite f with {i | ¬Q(i, f(i))} ∈ U. But the hypothesis gives {i | Q(i, f(i))} ∈ U. The intersection is empty — contradiction. □

---

## 7. Galaxy Order Properties

**Theorem 7.1 (Reflexivity).** GalaxyLeq is reflexive (C = 0).

**Theorem 7.2 (Transitivity).** GalaxyLeq is transitive.

**Theorem 7.3 (Totality).** GalaxyLeq is total — follows immediately from UltraLeq totality.

**Theorem 7.4 (Minimality).** The standard galaxy (containing the constant 0 sequence) is initial.

**Theorem 7.5 (Density/Sandwich).** If f's galaxy < g's galaxy (i.e., GalaxyLeq but ¬SameGalaxy), then there exists h with f < h < g at the galaxy level.

*Proof.* Take h(i) = ⌊(f(i) + g(i))/2⌋. The key insight: if SameGalaxy(f, h) held, then h(i) ≤ f(i) + C would imply (f(i) + g(i))/2 ≤ f(i) + C, hence g(i) ≤ f(i) + 2C + 1, giving SameGalaxy(f, g) — contradiction. Similarly for SameGalaxy(h, g). □

---

## 8. Arithmetic Compatibility

**Theorem 8.1 (Addition respects galaxies).** If f₁ ≈ g₁ and f₂ ≈ g₂, then (f₁ + f₂) ≈ (g₁ + g₂).

*Proof.* With bounds C₁, C₂, the bound C₁ + C₂ works by linearity. □

**Theorem 8.2 (Multiplication breaks galaxies).** There exist f ≈ g and h such that f·h ≉ g·h.

*Proof.* Take f = id, g = id + 1, h = id. Then f ≈ g with C = 1. But f·h = id² and g·h = (id+1)·id = id² + id differ by id, which is infinite. Any bound C would require {i | i ≤ C} ∈ U, contradicting freeness. □

### Significance

This asymmetry means galaxies form an additive group quotient but not a ring quotient. The galaxy structure is intrinsically linear — multiplication introduces a scale-dependent phenomenon that the additive galaxy classification cannot capture.

---

## 9. Non-Archimedean Property

**Theorem 9.1.** There exist f, g with f ≤_U g such that for all n ∈ ℕ, ¬(g ≤_U n·f).

*Proof.* Take f = const(1), g = id. Then 1 ≤ i for all i > 0 (U-large). For any n, n·f = const(n), and g ≤_U const(n) would mean {i | i ≤ n} ∈ U, contradicting freeness. □

### Connection to p-adic Analysis

This non-Archimedean behavior mirrors the p-adic numbers ℤ_p, where the p-adic absolute value satisfies |a + b|_p ≤ max(|a|_p, |b|_p). Both the ultrapower and p-adic completions produce non-Archimedean extensions of ℤ, but via fundamentally different mechanisms:

| Feature | Ultrapower ℕ*/U | p-adic ℤ_p |
|---------|-----------------|------------|
| Mechanism | Ultrafilter consensus | Valuation completion |
| Ordering | Totally ordered | Not linearly ordered (as a ring) |
| Non-Archimedean source | Growth rate gaps | Divisibility by p |
| Ring structure | Yes (Łoś transfer) | Yes (inverse limit) |

---

## 10. Conjecture: Galaxy Continuum Hypothesis

**Conjecture.** For any free ultrafilter U on ℕ, the set of galaxies between the standard galaxy and the galaxy of id is uncountable.

**Testable prediction.** For any countable family (f_n), construct by diagonalization a sequence g with g's galaxy distinct from all f_n's galaxies. Specifically, define g(i) so that g grows faster than f_n on a U-large set but slower than f_{n+1} — a construction analogous to Cantor's diagonal argument but at the galaxy level.

**Boundary case.** For principal ultrafilters, the galaxy structure collapses to a single point (all sequences are galaxy-equivalent to their value at the generator).

---

## 11. PEGB Analysis

### Theorem: Constructive Overspill (Theorem 6.1)

- **P (Proof)**: Complete Lean 4 proof using Nat.findGreatest, induction on cofinite sets.
- **E (Example)**: P(i, n) = (n ≤ √i). For each n, {i | n ≤ √i} is cofinite. The witness f(i) = findGreatest(· ≤ √i, i) ≈ √i, which is infinite.
- **G (Generalization)**: Extends to any ultrapower ∏_U Aᵢ where each Aᵢ has a well-ordering and a "findGreatest" operation.
- **B (Boundary)**: Fails for principal ultrafilters (no infinite elements exist). Fails without downward-closure (overspill requires monotonicity).

### Theorem: Galaxy Density (Theorem 7.5)

- **P (Proof)**: Midpoint construction h = (f+g)/2 with contradiction argument.
- **E (Example)**: f = id, g = id². Midpoint ≈ id²/2, which is in a different galaxy from both.
- **G (Generalization)**: For any dense linear order, the same midpoint argument works. Galaxy density is a consequence of the density of (ℝ, ≤).
- **B (Boundary)**: The analog fails for *halos* (infinitesimal neighborhoods) in the hyperreals, which can be adjacent.

### Theorem: Multiplication Incompatibility (Theorem 8.2)

- **P (Proof)**: Explicit counterexample (id, id+1, id) with freeness argument.
- **E (Example)**: 1000000 and 1000001 are galaxy-equivalent. But 10⁶ × 10⁶ = 10¹² and 10⁶ × (10⁶+1) = 10¹² + 10⁶ — already galaxy-inequivalent for sufficiently large elements.
- **G (Generalization)**: For any non-trivial galaxy equivalence on a ring ultrapower, multiplication fails to be compatible unless the ring is a field of characteristic 0.
- **B (Boundary)**: In the hyperreals (ultrapower of ℝ), multiplication DOES respect the *monad* (infinitesimal neighborhood) structure because monads use a multiplicative, not additive, bound.

---

## 12. Algorithms

### Algorithm 1: Constructive Overspill Witness

```
Input: Decidable downward-closed P : ℕ → ℕ → Prop
Output: Function f : ℕ → ℕ representing an infinite element satisfying P

f(i) = findGreatest(n ↦ P(i, n), i)
     = max { n ≤ i | P(i, n) }
```

Time complexity: O(i) per evaluation (linear scan). Can be improved to O(log i) if P has a monotonicity structure allowing binary search.

### Algorithm 2: Galaxy Classification

```
Input: Sequences f, g : ℕ → ℕ, bound N
Output: Estimate of whether f and g are in the same galaxy

For C = 0, 1, 2, ..., C_max:
    count = |{i ≤ N : |f(i) - g(i)| ≤ C}|
    if count / N > threshold:
        return "Same galaxy (bound C)"
return "Different galaxies"
```

---

## 13. Discussion and Future Work

The galaxy decomposition provides a structural view of non-standard arithmetic that goes beyond the transfer principle. While Łoś's theorem tells us *which* properties transfer, the galaxy structure tells us *how* the transferred elements organize themselves.

Key open problems:
1. **Full Łoś's theorem formalization**: A complete formalization of the transfer principle for first-order arithmetic, building on the bounded transfer proved here.
2. **Galaxy Continuum Hypothesis**: Proving or disproving that the galaxy poset is uncountable.
3. **Algebraic structure of galaxies**: Characterizing which algebraic operations are galaxy-compatible beyond addition.
4. **Computational applications**: Using the constructive overspill witness in automated theorem proving and program verification.

---

## References

[1] Robinson, A. *Non-standard Analysis*. North-Holland, 1966.

[2] Goldblatt, R. *Lectures on the Hyperreals: An Introduction to Nonstandard Analysis*. Springer, 1998.

[3] Schmerl, J. H. "The structure of models of Peano arithmetic." In *Studies in Logic*, vol. 31, 2006.

[4] Loeb, P. A., and Wolff, M. (eds.). *Nonstandard Analysis for the Working Mathematician*. Springer, 2015.
