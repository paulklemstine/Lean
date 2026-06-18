# Non-Standard Arithmetic via Ultrafilters: Transfer Principles, Saturation Degree, and the Primality Dichotomy

## Abstract

We develop a rigorous framework for non-standard arithmetic by constructing the ultrapower of ℕ modulo a free ultrafilter U on ℕ. Working directly with sequences and ultrafilter membership (rather than quotient types), we establish: (1) the non-Archimedean property — the diagonal element ω = [id] exceeds all standard naturals; (2) the Standard Part Theorem — bounded elements have unique standard representatives; (3) a comprehensive Transfer Principle for atomic arithmetic relations; (4) the Primality Dichotomy — both prime-selecting and composite-selecting ultrafilters exist; and (5) a novel concept, the **saturation degree**, which quantifies how far a predicate extends into the non-standard realm. All results are formalized in Lean 4 with complete machine-verified proofs.

**Keywords**: non-standard arithmetic, ultrafilters, ultrapower construction, transfer principle, overspill, saturation degree, Ramsey theory

## 1. Introduction

Non-standard analysis, introduced by Robinson [1966], provides a rigorous framework for reasoning with infinitesimal and infinite quantities. While the analytic aspects have been extensively studied, the *arithmetic* aspects — what happens when you extend the natural numbers beyond infinity — deserve renewed attention.

The ultrapower construction *ℕ = ℕ^ℕ / U produces a non-Archimedean extension of ℕ in which "infinitely large" natural numbers coexist with the standard ones. The Transfer Principle guarantees that first-order truths about ℕ remain true in *ℕ, while the Overspill Principle provides a mechanism for converting "for all finite n" statements into "for some infinite N" statements.

Our contribution is threefold:

1. **Complete formalization**: All results are proved in Lean 4 with no sorry's and only standard axioms (propext, Classical.choice, Quot.sound).

2. **Novel structure — Saturation Degree**: We introduce the saturation degree of a predicate, a quantitative measure of "transfer strength" that interpolates between predicates that fail immediately (sdeg = 0) and those that transfer completely (sdeg = ∞). We prove monotonicity and conjunction bounds.

3. **Primality Dichotomy**: We prove that both prime-selecting and composite-selecting ultrafilters exist on ℕ, showing that the "primality" of the diagonal element ω is genuinely underdetermined by the construction.

### 1.1. Related Work

The ultrapower construction is classical (Łoś [1955], Robinson [1966]). Formalizations of non-standard analysis in proof assistants include work in Isabelle/HOL (Fleuriot [2000]), Coq (Berger et al.), and Lean (partial, in Mathlib). Our work differs in focusing on the *arithmetic* (rather than analytic) aspects and introducing the saturation degree as a new tool.

The connection to Ramsey theory through ultrafilter color selection is related to the Hindman-Galvin-Glazer theorem (Hindman [1974]), formalized in Mathlib as `Ultrafilter.mul` and `Ultrafilter.eventually_mul`.

## 2. Definitions

### 2.1. U-Equivalence

**Definition 2.1** (U-Equivalence). Let U be an ultrafilter on ℕ. Two sequences f, g : ℕ → ℕ are *U-equivalent*, written f ~_U g, if {i : ℕ | f(i) = g(i)} ∈ U.

**Proposition 2.2**. U-equivalence is an equivalence relation.

*Proof*. Reflexivity: {i | f(i) = f(i)} = ℕ ∈ U. Symmetry and transitivity follow from ultrafilter closure under supersets and finite intersections. □

### 2.2. Free Ultrafilters

**Definition 2.3** (Free Ultrafilter). An ultrafilter U on ℕ is *free* if no singleton {n} is in U.

**Proposition 2.4**. A free ultrafilter contains all cofinite sets.

*Proof*. By induction on the cardinality of the finite complement. For finite S, decompose S = S' ∪ {a}; since {a} ∉ U, we have {a}ᶜ ∈ U; since S'ᶜ ∈ U by IH, their intersection (S' ∪ {a})ᶜ = S'ᶜ ∩ {a}ᶜ ∈ U. □

### 2.3. The Non-Standard Ordering

**Definition 2.5** (U-Order). Define f ≤_U g iff {i | f(i) ≤ g(i)} ∈ U, and f <_U g iff {i | f(i) < g(i)} ∈ U.

**Proposition 2.6** (Totality). For any f, g : ℕ → ℕ, either f ≤_U g or g ≤_U f.

*Proof*. By the ultrafilter property: either {i | f(i) ≤ g(i)} ∈ U or its complement {i | g(i) < f(i)} ⊆ {i | g(i) ≤ f(i)} is in U. □

### 2.4. Saturation Degree

**Definition 2.7** (Saturation Degree). For P : ℕ → Prop and ultrafilter U on ℕ:

sdeg_U(P) = sup{n ∈ ℕ∞ | ∃ k : ℕ, n = k ∧ {i | P(i) ∧ k ≤ i} ∈ U}

The saturation degree is ⊤ (infinite) if P holds on {i | i ≥ n} for all standard n, and finite otherwise.

## 3. Main Results

### 3.1. Non-Archimedean Property

**Theorem 3.1** (Non-Archimedean). Let U be a free ultrafilter on ℕ. Then:
(a) For every n ∈ ℕ, id is not U-equivalent to the constant function n.
(b) For every n ∈ ℕ, {i | n < i} ∈ U.

*Proof*. (a) {i | id(i) = n} = {n}, which is not in a free ultrafilter. (b) {i | i ≤ n} is finite, so its complement is in U. □

**Corollary 3.2**. The identity function, viewed as a "non-standard natural number" ω = [id], is strictly greater than every standard natural in the U-ordering.

### 3.2. Standard Part Theorem

**Theorem 3.3** (Standard Part — Existence). If {i | f(i) ≤ n} ∈ U, then there exists m ≤ n with {i | f(i) = m} ∈ U.

*Proof*. By induction on n. The base case is immediate. For the inductive step, either {i | f(i) = n+1} ∈ U (done) or {i | f(i) ≠ n+1} ∈ U (by ultrafilter dichotomy). In the latter case, {i | f(i) ≤ n+1} ∩ {i | f(i) ≠ n+1} = {i | f(i) ≤ n} ∈ U, and the inductive hypothesis applies. □

**Theorem 3.4** (Standard Part — Uniqueness). If {i | f(i) = m₁} ∈ U and {i | f(i) = m₂} ∈ U, then m₁ = m₂.

*Proof*. If m₁ ≠ m₂, then {i | f(i) = m₁} ∩ {i | f(i) = m₂} = ∅ ∈ U, contradicting the ultrafilter property. □

### 3.3. Transfer Principle

**Theorem 3.5** (Arithmetic Transfer). For all f, g : ℕ → ℕ:
- (fun i => f i + g i) ~_U (fun i => g i + f i) [commutativity of addition]
- (fun i => f i * g i) ~_U (fun i => g i * f i) [commutativity of multiplication]
- (fun i => f i * (g i + h i)) ~_U (fun i => f i * g i + f i * h i) [distributivity]
- gcd(f, g) ~_U gcd(g, f) [commutativity of GCD]
- Coprime(f, g) transfers iff Coprime(g, f) transfers [coprimality symmetry]

*Proof*. Each follows from the pointwise truth of the corresponding identity (which holds for all i ∈ ℕ), making the agreement set equal to ℕ ∈ U. □

**Theorem 3.6** (Bounded ∀ Transfer). If for each k < n, {i | P(i, k)} ∈ U, then {i | ∀ k < n, P(i, k)} ∈ U.

*Proof*. By induction on n, using ultrafilter closure under finite intersections. □

**Theorem 3.7** (Bounded ∃ Transfer). If {i | ∃ k < n, P(i, k)} ∈ U and n > 0, then ∃ k < n with {i | P(i, k)} ∈ U.

*Proof*. By contraposition: if no k < n has {i | P(i, k)} ∈ U, then each {i | ¬P(i, k)} ∈ U, so {i | ∀ k < n, ¬P(i, k)} ∈ U, contradicting the hypothesis. □

### 3.4. Overspill Principle

**Theorem 3.8** (Overspill). If ∀ n ∈ ℕ, {i | P(i) ∧ n ≤ i} ∈ U, then {i | P(i)} ∈ U.

*Proof*. Take n = 0: {i | P(i) ∧ 0 ≤ i} = {i | P(i)} ∈ U. □

**Remark**. The overspill principle is deceptively simple in this formulation. Its power lies in the *interpretation*: if P holds for all "standard-sized" elements (those below any fixed n), then it holds for the non-standard element ω = [id]. This converts "for all finite n" into "for some infinite N."

### 3.5. Primality Dichotomy

**Theorem 3.9** (Primality Dichotomy). Both of the following hold:
(a) ∃ U : Ultrafilter ℕ, {i | Prime(i)} ∈ U (ω is prime in some ultrapower)
(b) ∃ U : Ultrafilter ℕ, {i | ¬Prime(i)} ∈ U (ω is composite in some ultrapower)

*Proof*. (a) The primes are infinite; any infinite set generates a proper filter (via the principal filter), which extends to an ultrafilter by Zorn's lemma. (b) The composites are infinite (containing all multiples of 2 above 2); the same argument applies. □

**Discussion**. This theorem reveals that the "primality" of ω is not an intrinsic property of non-standard arithmetic but depends on the choice of ultrafilter. This is analogous to the independence of the Continuum Hypothesis from ZFC — the axioms do not determine the answer.

### 3.6. Saturation Degree Properties

**Theorem 3.10** (Saturation Monotonicity). If P(i) → Q(i) for all i, then sdeg_U(P) ≤ sdeg_U(Q).

*Proof*. Every k in the defining set for P is also in the defining set for Q (by ultrafilter closure under supersets), so the supremum of the former is at most that of the latter. □

**Theorem 3.11** (Conjunction Bound). min(sdeg_U(P), sdeg_U(Q)) ≤ sdeg_U(P ∧ Q).

*Proof*. If both {i | P(i) ∧ k ≤ i} ∈ U and {i | Q(i) ∧ k ≤ i} ∈ U, then their intersection (which equals {i | P(i) ∧ Q(i) ∧ k ≤ i}) is in U. So the defining set for P ∧ Q contains the intersection of the defining sets for P and Q. □

### 3.7. Color Selection

**Theorem 3.12** (k-Color Selection). For any k > 0 and c : ℕ → Fin k, there exists color ∈ Fin k with {n | c(n) = color} ∈ U.

*Proof*. The sets {n | c(n) = j} for j ∈ Fin k cover ℕ. Their union is ℕ ∈ U. By the finite union property of ultrafilters, at least one component is in U. □

### 3.8. Integral Domain Transfer

**Theorem 3.13** (Zero-Product Property). If {i | f(i) ≠ 0} ∈ U and {i | g(i) ≠ 0} ∈ U, then {i | f(i) · g(i) ≠ 0} ∈ U.

*Proof*. {i | f(i) · g(i) ≠ 0} ⊇ {i | f(i) ≠ 0} ∩ {i | g(i) ≠ 0} ∈ U. □

## 4. Algorithms

### 4.1. Standard Part Algorithm
Given a bounded sequence f with f(i) ≤ n, compute the standard part by counting occurrences of each value in a tail window and selecting the majority value. Complexity: O(N · n).

### 4.2. Saturation Degree Estimation
Estimate sdeg(P) by sliding a window [n, n+W] and computing the density of P. The first n where density drops below 0.5 approximates the saturation degree. Complexity: O(N · W).

### 4.3. Color Selection
Simulate ultrafilter selection by computing the tail density of each color class and selecting the majority. Complexity: O(N · k).

## 5. Applications and Cross-Connections

### 5.1. Connection to Ramsey Theory
The Color Selection Theorem (3.12) connects to van der Waerden's theorem: the selected color class contains arbitrarily long arithmetic progressions. In the ultrapower, this gives a non-standard AP of non-standard length.

### 5.2. Connection to p-adic Arithmetic
The non-Archimedean property of *ℕ parallels the non-Archimedean property of p-adic numbers. Both arise from "completing" the rationals/naturals with respect to a non-standard valuation. The saturation degree can be viewed as an analogue of the p-adic valuation.

### 5.3. Connection to Catalog Results
Our bounded ∀ and ∃ transfer theorems generalize `ultrafilter_bounded_forall_transfer` from the existing catalog (Catalog/Bridges/DependentUltraproduct.lean). The Color Selection Theorem provides a concrete instance of the ultrafilter pigeonhole principle.

## 6. Falsifiable Conjecture

**Conjecture 6.1** (Ultrafilter AP Conjecture). For every free ultrafilter U on ℕ and every 2-coloring c : ℕ → Fin 2, the U-selected color class contains arbitrarily long arithmetic progressions.

**Test**: For c(n) = n mod 2, both color classes are equidistributed and contain APs of all lengths. For c(n) = ⌊log₂ n⌋ mod 2, verify computationally that APs of length ≤ 100 exist in both classes for n ≤ 10⁶.

**Status**: TRUE by van der Waerden's theorem (both color classes of any 2-coloring contain arbitrarily long APs).

## 7. Future Work

1. **Formal CommSemiring instance**: Complete the quotient type construction to give *ℕ a formal `CommSemiring` instance in Lean.
2. **Łoś's theorem**: Formalize the full first-order transfer principle.
3. **Iterated ultrapowers**: Study *(ℕ) = *(ℕ^ℕ / U) and higher-order non-standard models.
4. **Connection to model theory**: Relate the saturation degree to model-theoretic notions of saturation.
5. **Computational non-standard methods**: Use the overspill principle to automate proofs about finite combinatorics.

## References

1. Robinson, A. (1966). *Non-Standard Analysis*. North-Holland.
2. Łoś, J. (1955). "Quelques remarques, théorèmes et problèmes sur les classes définissables d'algèbres." *Mathematical Interpretation of Formal Systems*.
3. Hindman, N. (1974). "Finite sums from sequences within cells of a partition of ℕ." *J. Combinatorial Theory Ser. A*, 17, 1–11.
4. Goldblatt, R. (1998). *Lectures on the Hyperreals*. Springer.
5. Fleuriot, J. (2000). "On the mechanization of real analysis in Isabelle/HOL." *TPHOLs 2000*.
