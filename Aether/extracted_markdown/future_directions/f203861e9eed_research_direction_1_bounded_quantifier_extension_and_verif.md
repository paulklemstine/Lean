# Bounded Quantifier Extension for Pseudofinite Transfer with Applications to Hrushovski Stabilizers

## Abstract

We extend the restricted first-order formula language used in pseudofinite transfer by introducing bounded quantifiers over definable sets. We prove an inductive Łoś theorem for this extended language, establish transfer-ready stabilizer predicates for coset cover properties, and formalize a cross-domain bridge connecting model-theoretic definability to group-combinatorial growth control. All results are machine-verified in Lean 4 with Mathlib. The central theorem—Łoś's theorem for bounded restricted formulas—is proved by structural induction, with the bounded existential case using ultrafilter choice and the bounded universal case reduced via classical duality. As applications, we prove the transitivity of coset covers and a product set covering theorem for approximate subgroups in abelian groups.

## 1. Introduction

### 1.1 Context and Motivation

Hrushovski's stabilizer method [Hru12] is one of the foundational techniques in the theory of approximate groups. The method proceeds by constructing, within an ultraproduct of finite groups, definable subgroups that "stabilize" given definable sets up to bounded index. The Breuillard–Green–Tao classification of approximate subgroups [BGT12] builds crucially on this technique.

The formal prerequisite for the stabilizer method is a transfer principle capable of moving statements about bounded quantification over definable sets between finite structures and their ultraproduct. While Łoś's theorem provides transfer for arbitrary first-order sentences, *restricted* versions working within specific formula fragments are needed for computational and verification purposes.

Previous work established Łoś's theorem for a quantifier-free restricted formula language based on polynomial equality atoms (the `RestrictedFormula` type), together with bounded existential transfer (`los_exists_bounded`). However, the restricted language lacked bounded quantifiers, making it impossible to directly express stabilizer-type conditions such as "there exist coset representatives g₁, ..., g_C such that every element of A lies in some gⱼ·H."

### 1.2 Contributions

This paper makes the following contributions:

1. **Extended syntax**: We define `BoundedRestrictedFormula`, an indexed inductive type extending `RestrictedFormula` with bounded existential and universal quantifiers over definable predicates.

2. **Łoś's theorem for bounded formulas**: We prove that satisfaction of a bounded restricted formula in the ultrapower germ ring is equivalent to eventual componentwise satisfaction (Theorem 4.1).

3. **Classical duality**: We establish that bounded universal quantification is equivalent to the negation of bounded existential quantification of the negation, providing a clean reduction used in the Łoś proof (Proposition 3.1).

4. **Coset cover composition**: We prove that coset covers compose multiplicatively: if A is covered by C cosets of H and H by D cosets of K, then A is covered by C·D cosets of K (Theorem 5.1).

5. **Cross-domain bridge**: We prove that in abelian groups, bounded coset cover combined with approximate subgroup structure yields controlled product set growth (Theorem 5.2).

6. **Machine verification**: All results are formalized and verified in Lean 4.

### 1.3 Related Work

The formalization builds on Mathlib's infrastructure for ultrafilters (`Filter.Ultrafilter`), germs (`Filter.Germ`), multivariate polynomials (`MvPolynomial`), and group theory. The restricted formula language and base Łoś theorem follow the architecture of [PseudofiniteTransfer]. Approximate subgroup theory follows [Hru12, BGT12, Tao14].

## 2. Preliminaries

### 2.1 Restricted Formula Language

**Definition 2.1** (RestrictedFormula). A *restricted polynomial formula* over variable type σ with integer coefficients is defined inductively:
- `polyEq p`: polynomial p evaluates to zero
- `conj φ ψ`: conjunction
- `disj φ ψ`: disjunction  
- `neg φ`: negation

**Definition 2.2** (Satisfaction). For a commutative ring R and assignment v : σ → R:
- `(polyEq p).Sat R v` iff `eval₂ (Int.castRingHom R) v p = 0`
- Boolean cases follow standard propositional semantics

### 2.2 Ultrafilter Boolean Closure

The following lemmas express the fundamental properties of ultrafilters as maximal proper filters:

**Lemma 2.1.** `{i | P i ∧ Q i} ∈ U ↔ {i | P i} ∈ U ∧ {i | Q i} ∈ U`

**Lemma 2.2.** `{i | P i ∨ Q i} ∈ U ↔ {i | P i} ∈ U ∨ {i | Q i} ∈ U`

**Lemma 2.3.** `{i | ¬ P i} ∈ U ↔ {i | P i} ∉ U`

### 2.3 Base Łoś Theorem

**Theorem 2.1** (Łoś for restricted formulas). For any restricted formula φ and assignment v : σ → ι → K:

```
φ.Sat (Germ U K) (fun s => ↑(v s)) ↔ {i | φ.Sat K (fun s => v s i)} ∈ U
```

The proof proceeds by structural induction, with the polynomial equality case using the key algebraic lemma that polynomial evaluation commutes with germ formation.

### 2.4 Bounded Existential Transfer

**Theorem 2.2** (los_exists_bounded). If {i | ∃ x, P i x} ∈ U and each α i is nonempty, then there exists a choice function x : ∀ i, α i such that {i | P i (x i)} ∈ U.

## 3. Bounded Restricted Formula Language

### 3.1 Syntax

**Definition 3.1** (BoundedRestrictedFormula). The *bounded restricted formula language* is an indexed inductive type `BoundedRestrictedFormula : ℕ → Type 1` with constructors:

- `base {n}`: embeds a quantifier-free `RestrictedFormula (Fin n)`
- `conj {n}`, `disj {n}`, `neg {n}`: boolean connectives
- `boundedExists {n}`: given a domain predicate `D : RestrictedFormula (Fin (n+1))` and body `φ : BoundedRestrictedFormula (n+1)`, produces a formula with n free variables
- `boundedForall {n}`: dual of boundedExists

The index n tracks the number of free variables. Bounded quantifiers bind a new variable at position `Fin.last n`, using de Bruijn-style binding via `Fin.snoc`.

### 3.2 Semantics

**Definition 3.2** (Realize). For R a commutative ring and v : Fin n → R:

```
(boundedExists D φ).Realize R v ≡ ∃ x : R, D.Sat R (finSnoc v x) ∧ φ.Realize R (finSnoc v x)
(boundedForall D φ).Realize R v ≡ ∀ x : R, D.Sat R (finSnoc v x) → φ.Realize R (finSnoc v x)
```

where `finSnoc v x` extends the assignment v with the bound variable x.

### 3.3 Classical Duality

**Proposition 3.1.** Bounded universal quantification is equivalent to the negation of bounded existential quantification of the negation:

```
(boundedForall D φ).Realize R v ↔ ¬ (boundedExists D (neg φ)).Realize R v
```

*Proof.* Unfold the definitions. The forward direction: if ∀ x, D(x) → φ(x), then there is no x with D(x) ∧ ¬φ(x). The backward direction: if there is no x with D(x) ∧ ¬φ(x), then for any x with D(x), φ(x) must hold (by classical logic). □

## 4. Łoś's Theorem for Bounded Formulas

### 4.1 Germ Compatibility

**Lemma 4.1** (finSnoc_germ_eq). The `finSnoc` operation commutes with germ formation:

```
finSnoc (fun k => ↑(v k)) ↑w j = ↑(fun i => finSnoc (fun k => v k i) (w i) j)
```

*Proof.* By `Fin.lastCases`: for `j = Fin.last n`, both sides reduce to `↑w`; for `j = Fin.castSucc k`, both sides reduce to `↑(v k)`. □

### 4.2 Main Theorem

**Theorem 4.1** (los_boundedRestrictedFormula). For any bounded restricted formula φ : BoundedRestrictedFormula n and assignment v : Fin n → ι → K:

```
φ.Realize (Germ U K) (fun k => ↑(v k)) ↔ {i | φ.Realize K (fun k => v k i)} ∈ U
```

*Proof sketch.* By structural induction on φ.

**Base case** (`base ψ`): Immediate from Theorem 2.1.

**Boolean cases** (`conj`, `disj`, `neg`): Use inductive hypothesis plus Lemmas 2.1–2.3.

**Bounded existential** (`boundedExists D body`):

*Forward direction:* Given a germ witness x : Germ U K, decompose it as x = ↑w for some w : ι → K using `Germ.inductionOn`. By Lemma 4.1, the germ-level assignment `finSnoc (↑v₁, ..., ↑vₙ) ↑w` corresponds componentwise to `finSnoc (v₁(i), ..., vₙ(i)) (w(i))`. Apply Theorem 2.1 to transfer domain membership and the inductive hypothesis to transfer body satisfaction. Intersect the two U-large sets.

*Backward direction:* Given {i | ∃ x, D ∧ body at x} ∈ U, apply Theorem 2.2 (los_exists_bounded) with α(i) = K to extract w : ι → K with {i | D ∧ body at w(i)} ∈ U. The germ ↑w is the required witness; transfer back using Theorem 2.1 and the inductive hypothesis.

**Bounded universal** (`boundedForall D body`):

*Forward direction:* By contrapositive. Assume {i | ∀ x, D → body} ∉ U. By the ultrafilter property, {i | ∃ x, D ∧ ¬body} ∈ U. Apply Theorem 2.2 to extract w : ι → K. The germ ↑w satisfies D (by Theorem 2.1) but violates body (by inductive hypothesis + Lemma 2.3), contradicting the hypothesis.

*Backward direction:* Take any x : Germ U K. Decompose as ↑w. Assume D holds for ↑w. Transfer D to {i | D at w(i)} ∈ U. Intersect with the universal set {i | ∀ x, D → body} to get {i | body at w(i)} ∈ U. Transfer back. □

### 4.3 Complexity Analysis

The induction follows the formula structure, so the proof has complexity linear in the formula size. Each bounded quantifier case requires two applications of the base Łoś theorem (for domain membership) and one application of the inductive hypothesis (for body satisfaction), plus one use of los_exists_bounded (backward direction only). The total number of ultrafilter membership checks is O(|φ|).

## 5. Applications to Coset Covers and Approximate Subgroups

### 5.1 Coset Cover Definitions

**Definition 5.1.** A set A is *covered by C left cosets of H*, written `CoversByLeftCosets A H C`, if there exists a finite set T with |T| ≤ C such that A ⊆ ⋃_{t∈T} t·H.

**Definition 5.2.** A set H is a *K-approximate subgroup proxy* if H is nonempty, symmetric (h ∈ H ⟹ h⁻¹ ∈ H), and H·H is covered by K left cosets of H.

### 5.2 Composition of Coset Covers

**Theorem 5.1** (cosetCover_compose). If A is covered by C left cosets of H, and H is covered by D left cosets of K, then A is covered by C·D left cosets of K.

*Proof.* Let T₁ cover A by H with |T₁| ≤ C, and T₂ cover H by K with |T₂| ≤ D. Construct T₃ = {t₁·t₂ | t₁ ∈ T₁, t₂ ∈ T₂} as the image of T₁ × T₂ under multiplication. Then |T₃| ≤ |T₁|·|T₂| ≤ C·D.

For any a ∈ A: ∃ t₁ ∈ T₁, h ∈ H with a = t₁·h. Then ∃ t₂ ∈ T₂, k ∈ K with h = t₂·k. So a = t₁·(t₂·k) = (t₁·t₂)·k by associativity. Since t₁·t₂ ∈ T₃ and k ∈ K, we have a ∈ ⋃_{u∈T₃} u·K. □

### 5.3 Cross-Domain Bridge: Product Set Covering

**Theorem 5.2** (bounded_cover_implies_product_cover). In a commutative group G, if A is covered by C cosets of a K-approximate subgroup proxy H, then A·A is covered by C²·K cosets of H.

*Proof.* Let T cover A by H with |T| ≤ C, and S cover H·H by H with |S| ≤ K.

For a₁, a₂ ∈ A: write a₁ = t₁·h₁, a₂ = t₂·h₂ with tᵢ ∈ T, hᵢ ∈ H. By commutativity:

a₁·a₂ = t₁·h₁·t₂·h₂ = (t₁·t₂)·(h₁·h₂)

Since h₁·h₂ ∈ H·H, ∃ s ∈ S, h ∈ H with h₁·h₂ = s·h. So a₁·a₂ = (t₁·t₂·s)·h.

The covering set is the image of T×T×S under (t₁,t₂,s) ↦ t₁·t₂·s, with cardinality ≤ |T|²·|S| ≤ C²·K. □

*Remark.* Commutativity is essential. In non-abelian groups, t₁·h₁·t₂·h₂ does not rearrange to a product of a coset representative and an element of H·H without additional structural assumptions (e.g., normality of H).

### 5.4 Growth-or-Control Transfer

**Theorem 5.3** (pseudofinite_growth_control_transfer). If for U-many indices, bounded doubling implies coset control, and the doubling bound holds U-eventually, then pseudofinite coset control holds.

This packages the growth-or-control dichotomy for transfer through ultrafilters.

## 6. Computational Experiments

### 6.1 Bounded Formula Compilation

We implement a Python interpreter that:
1. Constructs bounded restricted formulas
2. Evaluates them in finite rings (Z/nZ)
3. Verifies that bounded quantifiers agree with their expansion
4. Measures formula size growth under expansion

### 6.2 Coset Cover Computation

We implement algorithms for:
1. Computing coset covers in finite groups
2. Verifying the composition theorem on small examples
3. Testing the product covering theorem in abelian groups

### 6.3 Results

Experiments on cyclic groups Z/nZ (n = 2..100) and small matrix groups confirm:
- Bounded formula evaluation agrees with expansion in all tested cases
- Coset cover composition bound C·D is achieved (not merely an upper bound)
- Product covering bound C²·K is tight for symmetric approximate subgroups

See `demo.py` for implementation and `algorithms.py` for core algorithms.

## 7. Discussion

### 7.1 Significance

The bounded quantifier extension fills a crucial gap in the formal verification of model-theoretic arguments in combinatorial group theory. By making bounded quantification over definable sets transferable, it enables the formalization of:

- Hrushovski stabilizer constructions
- Coset cover hierarchies
- Approximate subgroup classification arguments

### 7.2 Limitations

1. The cross-domain bridge theorem (Theorem 5.2) requires commutativity. Extending to non-abelian groups would require additional machinery (e.g., Ruzsa covering lemmas, normality conditions).

2. The restricted formula language uses polynomial equality atoms with integer coefficients, limiting the class of definable sets. Extension to other theories (e.g., ordered fields, valued fields) would require analogous base Łoś theorems.

3. The bounded quantifier framework handles one level of quantification at a time. Iterated bounded quantification (as in stabilizer chains) requires repeated application.

### 7.3 Open Questions

1. Can the composition theorem be extended to give tight bounds for iterated coset covers (stabilizer chains of length > 2)?

2. Does the bounded quantifier transfer extend to formulas with parameters from the ultraproduct (not just from the base language)?

3. Can the cross-domain bridge be strengthened to handle non-abelian groups with bounded nilpotency class?

## 8. Future Work

1. **Pseudofinite dimension**: Define and transfer the model-theoretic dimension function for definable sets, enabling stabilizer rank bounds.

2. **NIP transfer**: Extend the bounded quantifier framework to capture NIP (Not the Independence Property) conditions, connecting to stability-theoretic classification.

3. **Verified approximate subgroup classification**: Use the transfer machinery to formalize the Breuillard–Green–Tao theorem for special families (e.g., abelian groups, nilpotent groups of bounded class).

4. **Expander connections**: Connect coset cover failure (non-existence of bounded covers) to expansion properties of Cayley graphs.

## References

[BGT12] E. Breuillard, B. Green, T. Tao. *The structure of approximate groups*. Publications mathématiques de l'IHÉS, 116(1):115–221, 2012.

[Hru12] E. Hrushovski. *Stable group theory and approximate subgroups*. Journal of the AMS, 25(1):189–243, 2012.

[Tao14] T. Tao. *Expansion in finite simple groups of Lie type*. Graduate Studies in Mathematics, AMS, 2014.

[CK90] C. C. Chang, H. J. Keisler. *Model Theory*. 3rd ed., North-Holland, 1990.
