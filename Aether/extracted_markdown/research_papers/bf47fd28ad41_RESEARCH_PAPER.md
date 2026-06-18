# Retrocausal Algebra: CPT Duality Between Intuitionistic and Paraconsistent Logic

## Abstract

We introduce *retrocausal algebras* — bi-Heyting algebras equipped with a time-reversal involution satisfying a CPT (Charge-Parity-Time) duality axiom. The CPT axiom states that time reversal maps Heyting implication to co-Heyting subtraction with swapped arguments: T(a ⇨ b) = T(b) \ T(a). We prove three main results:

1. **Temporal Excluded Middle**: In any retrocausal algebra, the co-Heyting excluded middle a ⊔ ￢a = ⊤ always holds, even when the Heyting excluded middle a ⊔ aᶜ = ⊤ fails.

2. **CPT Negation Duality**: Time reversal maps Heyting negation to co-Heyting negation: T(aᶜ) = ￢(T(a)). This establishes that time reversal exchanges the two canonical notions of negation.

3. **CPT-LEM Duality**: The law of excluded middle for an element is equivalent to the law of non-contradiction for its time-reversed image: a ⊔ aᶜ = ⊤ ↔ T(a) ⊓ ￢(T(a)) = ⊥. This reveals that every failure of classical logic (LEM) in forward time corresponds to a paraconsistency in reversed time.

All results are formalized and machine-verified in Lean 4 with Mathlib, building on the existing `BiheytingAlgebra` infrastructure.

## 1. Introduction

### 1.1 Motivation

The CPT theorem in quantum field theory establishes that the combined operation of charge conjugation (C), parity inversion (P), and time reversal (T) is a symmetry of any local, Lorentz-invariant quantum field theory. While the physical significance of CPT symmetry is well understood, its logical and algebraic content has received less attention.

Meanwhile, the study of bi-Heyting algebras — lattices that are simultaneously Heyting algebras (supporting intuitionistic implication) and co-Heyting algebras (supporting paraconsistent subtraction) — has revealed deep connections between intuitionistic and paraconsistent logic. In a bi-Heyting algebra, two canonical negations coexist: the Heyting complement aᶜ = a ⇨ ⊥ and the co-Heyting negation ￢a = ⊤ \ a.

This paper shows that these two strands — CPT symmetry and bi-Heyting duality — are connected by a natural algebraic structure that we call a *retrocausal algebra*.

### 1.2 Related Work

The connection between Heyting algebras and intuitionistic logic is classical (Birkhoff, 1933; Stone, 1938). Co-Heyting algebras and their paraconsistent interpretation were studied by Rauszer (1974) and Lawvere (1991). Bi-Heyting algebras appear naturally as the lattice of open sets of a topological space (where they are complete Heyting algebras) and in the theory of toposes.

The logical interpretation of time reversal in quantum mechanics connects to work on quantum logic (Birkhoff and von Neumann, 1936), temporal logic (Prior, 1967), and retrocausality in quantum foundations (Price, 1996; Wharton, 2018).

## 2. Definitions

### 2.1 Bi-Heyting Algebras

A **bi-Heyting algebra** is a bounded lattice (L, ⊔, ⊓, ⊥, ⊤) equipped with:
- A binary operation ⇨ (Heyting implication) satisfying c ≤ a ⇨ b ↔ a ⊓ c ≤ b
- A binary operation \\ (co-Heyting subtraction) satisfying a \\ b ≤ c ↔ a ≤ b ⊔ c

These induce two negations:
- **Heyting complement**: aᶜ = a ⇨ ⊥
- **Co-Heyting negation**: ￢a = ⊤ \\ a

### 2.2 Retrocausal Algebras

**Definition 2.1.** A **retrocausal algebra** is a bi-Heyting algebra (L, ⊔, ⊓, ⇨, \\, ⊥, ⊤) equipped with a map T : L → L satisfying:

1. **Involution**: T(T(a)) = a for all a
2. **Bounds**: T(⊤) = ⊥ and T(⊥) = ⊤
3. **De Morgan**: T(a ⊔ b) = T(a) ⊓ T(b) and T(a ⊓ b) = T(a) ⊔ T(b)
4. **CPT Axiom**: T(a ⇨ b) = T(b) \\ T(a) for all a, b

**Remark.** The CPT axiom is the defining characteristic. It states that time reversal converts forward implication into backward subtraction with swapped arguments. The name "CPT" is chosen by analogy with the CPT theorem in quantum field theory.

### 2.3 Retrocausal Kripke Frames

**Definition 2.2.** A **retrocausal Kripke frame** is a tuple (W, →, ←, rev) where:
- W is a set of worlds
- → (forward accessibility) is a preorder on W
- ← (backward accessibility) is a relation on W
- rev : W → W is an involution satisfying: u → v ↔ rev(v) ← rev(u)

The backward accessibility inherits reflexivity and transitivity from the forward accessibility via the time-reversal map (Theorems proved in the formalization).

## 3. Main Results

### 3.1 Basic Properties

**Theorem 3.1** (T is order-reversing). T is antitone: a ≤ b implies T(b) ≤ T(a).

*Proof.* If a ≤ b, then a ⊔ b = b, so T(b) = T(a ⊔ b) = T(a) ⊓ T(b) ≤ T(a). □

**Theorem 3.2** (T is a bijection). T is both injective and surjective.

*Proof.* Injectivity: if T(a) = T(b), apply T to get a = b. Surjectivity: for any b, a = T(b) satisfies T(a) = b. □

### 3.2 CPT Negation Duality

**Theorem 3.3** (CPT Negation Duality). T(aᶜ) = ￢(T(a)).

*Proof.* We have aᶜ = a ⇨ ⊥ (definition of Heyting complement). Applying the CPT axiom: T(a ⇨ ⊥) = T(⊥) \\ T(a) = ⊤ \\ T(a) = ￢(T(a)) (definition of co-Heyting negation). □

**Theorem 3.4** (Dual CPT). T(a \\ b) = T(b) ⇨ T(a).

*Proof.* Apply the CPT axiom with T(b) and T(a): T(T(b) ⇨ T(a)) = T(T(a)) \\ T(T(b)) = a \\ b. Apply T to both sides: T(b) ⇨ T(a) = T(a \\ b) (using involution). □

**Theorem 3.5** (Reverse CPT Negation). T(￢a) = (T(a))ᶜ.

*Proof.* By Theorem 3.4 applied to ⊤ \\ a: T(⊤ \\ a) = T(a) ⇨ T(⊤) = T(a) ⇨ ⊥ = (T(a))ᶜ. □

### 3.3 Temporal Excluded Middle

**Theorem 3.6** (Temporal Excluded Middle). For all a in a retrocausal algebra, a ⊔ ￢a = ⊤.

*Proof.* This is a standard property of co-Heyting algebras, following from the adjunction defining \\. □

**Remark.** The significance of this result is that temporal excluded middle holds *even when classical LEM fails*. In a non-Boolean retrocausal algebra, there exist elements a with a ⊔ aᶜ ≠ ⊤ (LEM fails) while a ⊔ ￢a = ⊤ (TEM holds) — see Theorem 3.8 below.

### 3.4 The CPT-LEM Duality Theorem

**Theorem 3.7** (CPT-LEM Duality). a ⊔ aᶜ = ⊤ if and only if T(a) ⊓ ￢(T(a)) = ⊥.

*Proof.*
(⇒) Assume a ⊔ aᶜ = ⊤. Apply T: T(a ⊔ aᶜ) = T(⊤) = ⊥. By De Morgan and CPT Negation Duality: T(a) ⊓ T(aᶜ) = T(a) ⊓ ￢(T(a)) = ⊥.

(⇐) Assume T(a) ⊓ ￢(T(a)) = ⊥. Apply T: T(T(a) ⊓ ￢(T(a))) = T(⊥) = ⊤. By De Morgan: T(T(a)) ⊔ T(￢(T(a))) = a ⊔ T(￢(T(a))) = ⊤. By Theorem 3.5: T(￢(T(a))) = (T(T(a)))ᶜ = aᶜ. Hence a ⊔ aᶜ = ⊤. □

**Interpretation.** This theorem establishes a precise duality between:
- **Classical logic** (LEM: P ∨ ¬P) in forward time
- **Consistency** (non-contradiction: ¬(P ∧ ¬P)) in reversed time

Every failure of excluded middle in forward time corresponds to a failure of non-contradiction in reversed time, and vice versa.

### 3.5 LEM Failure and Paraconsistency

**Theorem 3.8** (LEM Failure Implies Paraconsistency). If a ⊔ aᶜ ≠ ⊤ (LEM fails for a), then T(a) ⊓ ￢(T(a)) ≠ ⊥ (non-contradiction fails for T(a)).

*Proof.* Immediate from Theorem 3.7 by contraposition. □

**Corollary 3.9** (Retrocausal Logic is Intuitionistic). If a retrocausal algebra is non-Boolean (∃a : a ⊔ aᶜ ≠ ⊤), then LEM is not a tautology.

### 3.6 CPT Double Negation and Regularity

**Theorem 3.10** (CPT Double Negation). T(aᶜᶜ) = ￢￢(T(a)).

*Proof.* Apply Theorem 3.3 twice: T(aᶜᶜ) = ￢(T(aᶜ)) = ￢(￢(T(a))). □

**Theorem 3.11** (CPT Regularity). a = aᶜᶜ if and only if T(a) = ￢￢(T(a)).

*Proof.* Both directions follow from applying T and using Theorem 3.10 with the involution property. □

## 4. Concrete Models

### 4.1 The Three-Element Chain

The simplest non-Boolean retrocausal algebra is the three-element chain L₃ = {0, 1, 2} with the natural ordering. The bi-Heyting structure is given by:

| a | aᶜ | ￢a | a ⊔ aᶜ | a ⊔ ￢a |
|---|----|----|--------|--------|
| 0 | 2  | 2  | 2 = ⊤  | 2 = ⊤  |
| 1 | 0  | 2  | 1 ≠ ⊤  | 2 = ⊤  |
| 2 | 0  | 0  | 2 = ⊤  | 2 = ⊤  |

Time reversal: T(a) = 2 - a.

This model witnesses:
- LEM failure at a = 1: 1 ⊔ 0 = 1 ≠ 2 = ⊤
- TEM holds at a = 1: 1 ⊔ 2 = 2 = ⊤
- CPT negation duality: T(1ᶜ) = T(0) = 2 = ￢(T(1)) = ￢(1) = 2
- CPT-LEM duality: T(1) ⊓ ￢(T(1)) = 1 ⊓ 2 = 1 ≠ 0 = ⊥ (paraconsistency)

### 4.2 Chain Algebras of Arbitrary Size

For any n ≥ 2, the chain Lₙ = {0, 1, ..., n-1} with T(a) = (n-1) - a forms a retrocausal algebra. Key properties:

- **Boolean iff n = 2**: LEM holds for all elements only in the two-element chain.
- **LEM failures**: For n ≥ 3, exactly n - 2 elements (all except ⊥ and ⊤) fail LEM.
- **LEM failure ratio**: (n-2)/n → 1 as n → ∞. In the limit, "almost all" elements fail LEM.
- **CPT fixed points**: Only ⊥ and ⊤ are CPT fixed points (T(a) = aᶜ) for n ≥ 3.

## 5. Algorithms

### 5.1 Verification Algorithm

Given a finite bi-Heyting algebra with a candidate time-reversal T, the CPT axiom T(a ⇨ b) = T(b) \\ T(a) can be verified in O(n²) time by checking all pairs. The full axiom set (involution, De Morgan, CPT) requires O(n²) checks.

### 5.2 Spectrum Computation

The retrocausal spectrum — the set of LEM failure ratios across all finite chain algebras — can be computed in O(n) per algebra. For chain algebras, the LEM failure ratio is exactly (n-2)/n, converging to 1.

## 6. Conjecture

**Conjecture 6.1.** In any finite non-Boolean retrocausal algebra with |L| ≥ 4, there exists a non-trivial element a (a ≠ ⊥, a ≠ ⊤) that is not a CPT fixed point (T(a) ≠ aᶜ).

**Test**: Enumerate all retrocausal algebra structures on sets of size 4 and check. Note that this conjecture is restricted to non-Boolean algebras — in a Boolean algebra with T = complement, every element is trivially a CPT fixed point.

## 7. Discussion

### 7.1 Connections to Quantum Foundations

The CPT-LEM duality theorem provides an algebraic explanation for why time-reversal is connected to logical structure in physics. If the propositions of a physical theory form a retrocausal algebra, then the CPT axiom forces a correspondence between undecidability (LEM failure) and paraconsistency. This connects to:

- **Quantum complementarity**: Measurements that cannot be simultaneously sharp
- **Retrocausality in quantum mechanics**: The possibility that future measurements affect past states
- **The arrow of time**: The thermodynamic and cosmological arrows may have algebraic roots

### 7.2 Connections to the Catalog

This work builds on several existing catalog results:

- **Oracle excluded middle** (`Algebra/Oracle.lean`): The oracle-based excluded middle theorem demonstrates a similar phenomenon where decidability depends on computational context.
- **Excluded middle not tautology** (`Logic/ParaconsistentParadox.lean`): The paraconsistent logic framework already established that LEM can fail in non-classical logics; we extend this by showing the failure is *dual* to paraconsistency under time reversal.
- **Temporal compression** (`Bridges/UltrametricTemporalCompression.lean`): The ultrametric temporal compression provides a metric-space perspective on temporal structure that complements our algebraic approach.

## 8. Future Work

1. **Non-linear retrocausal algebras**: Extend the theory beyond chain algebras to arbitrary finite lattices and complete Heyting algebras.
2. **Categorical CPT duality**: Formulate the CPT axiom as a natural transformation between functors on the category of bi-Heyting algebras.
3. **Quantum retrocausal algebras**: Connect to the orthomodular lattices of quantum logic.
4. **Topological models**: Construct retrocausal algebras from the open sets of topological spaces with involution.
5. **Proof complexity**: Study the computational complexity of retrocausal reasoning.

## References

1. Birkhoff, G. (1933). On the combination of subalgebras. *Proc. Cambridge Phil. Soc.* 29, 441–464.
2. Birkhoff, G. and von Neumann, J. (1936). The logic of quantum mechanics. *Annals of Mathematics* 37(4), 823–843.
3. Lawvere, F.W. (1991). Intrinsic co-Heyting boundaries and the Leibniz rule in certain toposes. *Category Theory*, Springer, 279–281.
4. Prior, A.N. (1967). *Past, Present and Future*. Oxford University Press.
5. Price, H. (1996). *Time's Arrow and Archimedes' Point*. Oxford University Press.
6. Rauszer, C. (1974). Semi-Boolean algebras and their applications to intuitionistic logic with dual operations. *Fundamenta Mathematicae* 83, 219–249.
7. Wharton, K. (2018). A new class of retrocausal models. *Entropy* 20(6), 410.
