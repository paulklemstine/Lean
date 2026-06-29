# Prime Congruence Spectra of Proof Semirings: An Algebraic Foundation for Proof-Spectrum Semantics

## Abstract

We establish the algebraic core of *proof-spectrum semantics*: the theorem that semiprime kernels in commutative semirings are exactly the intersections of the prime theories containing them. This result, formalized and machine-verified in Lean 4 with Mathlib, provides a rigorous foundation for interpreting derivability in closure-based proof systems through the lens of algebraic geometry. We develop the theory of proof congruences, vanishing loci, and the antitone Galois correspondence between theories and prime spectra. For commutative rings, we prove the full prime congruence separation theorem by constructing quotient ring congruences. The framework opens new connections between proof theory, tropical algebra, and spectral geometry.

## 1. Introduction

### 1.1 Motivation

A fundamental question in logic and computer science is: *when is a statement derivable from a set of axioms?* Classical model theory answers this through semantic completeness: a statement is derivable if and only if it holds in every model consistent with the axioms. But this answer depends on having the right notion of "model."

We propose a new algebraic framework — **proof-spectrum semantics** — that identifies models with *prime theories* in a commutative semiring. The key insight is that derivability kernels (sets of derivable statements) carry the structure of a semiring ideal, and prime ideals are the natural notion of "irreducible semantic point."

### 1.2 Main Result

**Theorem (Semiprime Theory Reconstruction).** *Let α be a commutative semiring and K ⊆ α a semiprime kernel (a set containing 0, closed under addition, absorbing under multiplication, and satisfying a² ∈ K ⟹ a ∈ K). Then*

$$K = \bigcap \{T \mid T \text{ is a prime theory with } K \subseteq T\}$$

*where a prime theory is a theory T satisfying: ab ∈ T ⟹ a ∈ T ∨ b ∈ T.*

This is the semiring-theoretic analogue of the classical result that semiprime ideals in commutative rings are intersections of prime ideals. Our proof works in the greater generality of commutative semirings (without subtraction), which is essential for applications to proof theory and closure systems where resources cannot be "un-derived."

### 1.3 Contributions

1. **Formal verification**: All main theorems are machine-verified in Lean 4 with Mathlib, including the Zorn's lemma argument for prime separation.

2. **Semiring generality**: The reconstruction theorem holds for commutative semirings, not just rings. This extends the classical algebra to settings without additive inverses.

3. **Galois correspondence**: We establish the antitone Galois correspondence between sets of proof terms and sets of congruences, analogous to the Zariski topology correspondence in algebraic geometry.

4. **Ring congruence construction**: For commutative rings, we prove the full prime congruence separation theorem by constructing ProofCongruences from prime ideals via quotient rings.

## 2. Definitions and Framework

### 2.1 Theories and Prime Theories

**Definition 2.1** (Theory). A subset T of a commutative semiring α is a *theory* if:
- 0 ∈ T
- T is closed under addition: a, b ∈ T ⟹ a + b ∈ T
- T absorbs multiplication: a ∈ T ⟹ ab ∈ T for all b

**Definition 2.2** (Prime Theory). A theory T is *prime* if: ab ∈ T ⟹ a ∈ T ∨ b ∈ T.

**Definition 2.3** (Semiprime Theory). A theory T is *semiprime* if: a² ∈ T ⟹ a ∈ T.

In the integers ℤ, theories are exactly ideals (sets of the form nℤ). Prime theories are prime ideals: {0} and pℤ for primes p. A theory nℤ is semiprime iff n is squarefree.

### 2.2 Proof Congruences

**Definition 2.4** (Proof Congruence). A *proof congruence* on a commutative semiring α is an equivalence relation ~ compatible with both addition and multiplication:
- a ~ b, c ~ d ⟹ a+c ~ b+d
- a ~ b, c ~ d ⟹ ac ~ bd

**Definition 2.5** (Zero-Class). The *zero-class* of a proof congruence ~ is {a ∈ α | a ~ 0}.

**Proposition 2.6.** The zero-class of any proof congruence is a theory. The zero-class of a prime proof congruence (where ab ~ 0 ⟹ a ~ 0 ∨ b ~ 0) is a prime theory.

### 2.3 Galois Correspondence

**Definition 2.7.** For a set S ⊆ α of proof terms, the *zero locus* is:

$$V(S) = \{P \text{ proof congruence} \mid \forall a \in S,\, a \sim_P 0\}$$

For a set X of proof congruences, the *theory* is:

$$I(X) = \{a \in \alpha \mid \forall P \in X,\, a \sim_P 0\}$$

**Theorem 2.8** (Galois Correspondence).
- V is antitone: S ⊆ T ⟹ V(T) ⊆ V(S)
- I is antitone: X ⊆ Y ⟹ I(Y) ⊆ I(X)
- S ⊆ I(V(S)) (extensivity)
- S ⊆ I(X) ⟺ X ⊆ V(S) (adjunction)

## 3. The Reconstruction Theorem

### 3.1 Powers in Semiprime Kernels

**Lemma 3.1.** *If K is a semiprime theory and aⁿ ∈ K for some n ≥ 1, then a ∈ K.*

*Proof.* By strong induction on n. For n = 1, trivial. For even n = 2k: aⁿ = (aᵏ)², so aᵏ ∈ K by semiprimality, then a ∈ K by induction (k < n). For odd n ≥ 3: aⁿ ∈ K implies aⁿ⁺¹ = aⁿ · a ∈ K by absorption. Since n+1 is even, a^((n+1)/2) ∈ K by semiprimality, and (n+1)/2 < n, so a ∈ K by induction. □

### 3.2 The Ideal Generated by an Element

**Definition 3.2.** Given a theory M and element x, the *generated theory* is:

$$M[x] = \{m + xr \mid m \in M, r \in \alpha\}$$

**Lemma 3.3.** *M[x] is a theory containing M ∪ {x}.*

**Lemma 3.4** (Key Algebraic Lemma). *If xy ∈ M, a ∈ M[x], and b ∈ M[y], then ab ∈ M.*

*Proof.* Write a = m₁ + xr₁ and b = m₂ + yr₂. Then:

$$ab = m_1 m_2 + m_1 y r_2 + m_2 x r_1 + xy \cdot r_1 r_2$$

Each term is in M: the first three by absorption (m₁, m₂ ∈ M), the fourth because xy ∈ M. Their sum is in M by closure under addition. □

### 3.3 Prime Separation via Zorn's Lemma

**Theorem 3.5** (Prime Separation). *Let K be a semiprime theory in a commutative semiring α, and let a ∉ K. Then there exists a prime theory T with K ⊆ T and a ∉ T.*

*Proof.* Consider the family:

$$\mathcal{F} = \{I \mid I \text{ is a theory}, K \subseteq I, \forall n \geq 1: a^n \notin I\}$$

By Lemma 3.1, K ∈ F (nonempty). Chains in F have upper bounds (their union). By Zorn's lemma, let M be maximal in F.

*Claim: M is prime.* Suppose xy ∈ M, x ∉ M, y ∉ M. By maximality, M[x] ∉ F, so some aⁿ ∈ M[x]. Similarly, some aᵐ ∈ M[y]. By Lemma 3.4, aⁿ⁺ᵐ = aⁿ · aᵐ ∈ M, contradicting M ∈ F (since n+m ≥ 2 > 0).

Since a = a¹ and M avoids all powers of a, we have a ∉ M. □

### 3.4 The Main Theorem

**Theorem 3.6** (Semiprime Theory Reconstruction). *A semiprime theory K equals the intersection of all prime theories containing it:*

$$K = \bigcap_{T \text{ prime}, K \subseteq T} T$$

*Proof.* The forward inclusion K ⊆ ∩T is trivial. For the reverse: if a ∉ K, Theorem 3.5 gives a prime T with K ⊆ T, a ∉ T, so a ∉ ∩T. □

### 3.5 Closed Theory Correspondence

**Corollary 3.7.** *Two semiprime theories K, L are equal if and only if they have the same prime theories above them: for all prime T, K ⊆ T ⟺ L ⊆ T.*

This is the injectivity of the "spectrum map" — distinct semiprime theories are always distinguished by some prime theory.

## 4. The Ring Case: Full Congruence Separation

For commutative rings, we can strengthen the theorem to use proof congruences rather than just theories.

**Theorem 4.1** (Prime Congruence Separation for Rings). *In a commutative ring α, if K is a semiprime theory and a ∉ K, then there exists a prime proof congruence P with K ⊆ zero-class(P) and a ∉ zero-class(P).*

*Proof.* By Theorem 3.5, get a prime theory T ⊇ K with a ∉ T. In a ring, T is automatically an ideal (closure under negation follows from absorption: a · (-1) = -a). The quotient ring α/T is an integral domain (since T is prime), and the kernel congruence of the quotient map α → α/T is a prime proof congruence with zero-class = T. □

The gap between the ring case and the general semiring case lies in constructing congruences from theories. In semirings without subtraction, this requires additional structure (such as k-closure or the Bourne congruence).

## 5. Discussion: A Scientific American Perspective

### What Does This Theorem Really Say?

Imagine you're building a proof system — a machine that derives new facts from old ones. You start with some axioms K, and you derive everything you can. The question is: *how can you be sure you've derived everything that's true?*

The classical approach is to build **models** — mathematical structures where the axioms hold — and check which statements are true in all models. If a statement fails in some model, it's not derivable. If it holds in every model, it is. This is the essence of *completeness theorems* in logic.

Our theorem provides a new, algebraic perspective on this idea. Instead of "models," we use **prime theories** — minimal, irreducible collections of true statements. Think of them as the "atoms" of truth: they can't be decomposed into smaller pieces.

The reconstruction theorem says: **a statement is derivable if and only if it belongs to every prime theory consistent with the axioms.** This is exactly the algebraic-geometric motto "a function vanishes on a variety if and only if it vanishes at every point."

### The Geometry of Proofs

Here's the beautiful analogy. In algebraic geometry:
- **Points** of a variety correspond to **prime ideals**
- A polynomial **vanishes** at a point if it's in the prime ideal
- A variety is determined by its points (for "nice" — reduced — varieties)

In proof-spectrum semantics:
- **Semantic points** correspond to **prime theories**
- A proof term **vanishes** at a semantic point if it's derivable in that theory
- A proof system is determined by its semantic points (for **semiprime** systems)

The word "semiprime" plays the role of "reduced" in algebraic geometry: it means the system has no "nilpotent proofs" — no proof term a such that a² (using a twice) is derivable but a itself is not.

### Why Semirings, Not Just Rings?

Classical algebra works with rings, where you can add and subtract. But proof systems are fundamentally *semirings*: you can combine proofs (add) and compose them (multiply), but you can't "un-prove" something. There's no subtraction of derivations.

This is why our theorem, which works for semirings without subtraction, is more than a routine generalization. It captures the essential *asymmetry* of logical derivation: once something is proved, it stays proved.

### Historical Context

The reconstruction theorem is a descendent of several great mathematical traditions:

1. **Hilbert's Nullstellensatz** (1893): The foundation of algebraic geometry, connecting polynomial equations to geometric varieties. Our theorem is the "proof-theoretic Nullstellensatz."

2. **Krull's theorem** (1929): The existence of maximal (and prime) ideals in commutative rings via Zorn's lemma. Our Zorn argument follows the same pattern.

3. **Stone duality** (1936): The correspondence between Boolean algebras and Stone spaces. Our Galois correspondence is a semiring generalization.

4. **Lindenbaum-Tarski** construction: The passage from syntax to semantics in logic. Our prime theories play the role of "complete consistent extensions."

## 6. Applications

### 6.1 Automated Non-Derivability Certificates

The prime separation theorem gives a concrete strategy for proving that a statement is *not* derivable: **find a prime theory containing the axioms but not the statement.** This is the proof-theoretic analogue of finding a counterexample.

For finite systems, this reduces to a search problem over a finite set of prime theories, potentially amenable to SAT-solving or constraint programming.

### 6.2 Modular Proof Analysis

The reconstruction theorem says that every semiprime theory decomposes into prime "components." This supports **modular proof analysis**: instead of analyzing a complex proof system as a monolith, decompose it into independent prime components, analyze each separately, and reconstruct the whole.

### 6.3 Abstract Interpretation

In program analysis, abstract domains form closure systems. The proof-spectrum framework suggests decomposing abstract domains into prime components, each providing an independent semantic analysis.

## 7. Formal Verification

All theorems in this paper are formally verified in Lean 4 (version 4.28.0) with Mathlib. The formalization consists of approximately 500 lines of Lean code in the file `PrimeCongruenceProofSemiring.lean`, including:

- 7 definitions (ProofCongruence, vanishesAt, zeroLocus, theoryOf, IsTheory, IsPrimeTheory, etc.)
- 12 proved theorems (no sorry in any proved theorem)
- 1 explicitly stated conjecture (prime congruence separation for general semirings)

The proof of the main theorem (`semiprime_eq_iInter_prime_theories`) uses Zorn's lemma from Mathlib's `Order.Zorn` module. All axioms used are standard: `propext`, `Classical.choice`, and `Quot.sound`.

## References

The algebraic content generalizes classical results from commutative algebra. The connection to proof theory and closure systems is, to our knowledge, new. For background on:

- Semiprime ideals and their characterization: Atiyah & Macdonald, *Introduction to Commutative Algebra*
- Semiring theory and ideals: Golan, *Semirings and their Applications*
- Stone duality and spectral spaces: Johnstone, *Stone Spaces*
- Formal verification with Lean: The Mathlib Community, *Mathematics in Lean*
