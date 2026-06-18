# Retrocausal Heyting Algebras: Nuclei, Temporal Adjunctions, and the Intuitionistic Character of Time-Reversed Logic

## Abstract

We formalize the mathematical theory of retrocausal logical structures, where implications can flow backward in time. Starting from a Galois connection (T, R) modeling forward and backward temporal propagation, we show that the composition R∘T forms a nucleus on the underlying lattice when T preserves finite meets. The fixed points of this nucleus carry a Heyting algebra structure via the retrocausal implication j(a ⇨ b), and we prove the fundamental adjunction: c ⊓ a ≤ b if and only if c ≤ j(a ⇨ b) for fixed points a, b, c. We construct a concrete 3-element Heyting algebra demonstrating that the law of excluded middle fails on fixed points, while proving that a temporal form of excluded middle — R(T(a)) ⊔ R(T(aᶜ)) = ⊤ — holds whenever the base algebra is Boolean. The temporal operators □ = R∘T and ◇ = T∘R are shown to satisfy S4 modal axioms and temporal coherence laws. We formalize an algebraic CPT symmetry structure and prove that the CPT composition is involutive under pairwise commutativity. All results are machine-verified in Lean 4 with the Mathlib library.

## 1. Introduction

The relationship between temporal structure and logical character has been a recurring theme across mathematics, physics, and philosophy. In locale theory, nuclei (closure operators preserving finite meets) provide the mechanism for passing from a frame to a quotient frame, and the resulting fixed-point lattice is always a Heyting algebra — potentially lacking the law of excluded middle present in the original Boolean algebra. In physics, the CPT theorem establishes that any Lorentz-invariant quantum field theory is invariant under the combined action of charge conjugation, parity reversal, and time reversal.

This paper connects these two traditions by interpreting the nucleus construction in temporal terms. A Galois connection (T, R) models forward temporal propagation T and backward (retrocausal) propagation R, with the adjunction T(a) ≤ b ⟺ a ≤ R(b) capturing their duality. The composition R∘T acts as a temporal closure operator, and we show it is a nucleus when T preserves meets — a condition satisfied by frame homomorphisms.

### 1.1 Main Contributions

1. **Retrocausal Implication** (§3): We define j(a ⇨ b) as the retrocausal Heyting implication and prove the fundamental adjunction theorem showing fixed points form a Heyting algebra.

2. **LEM Failure** (§5): We construct a concrete 3-element Heyting algebra (modeling the fixed-point lattice of a retrocausal nucleus) where the law of excluded middle fails: mid ⊔ midᶜ ≠ ⊤.

3. **Temporal Excluded Middle** (§6): We prove that R(T(a)) ⊔ R(T(aᶜ)) = ⊤ in any Boolean algebra equipped with a Galois connection, showing that temporal closure restores classical behavior.

4. **Modal S4 Structure** (§4): The operators □ = R∘T and ◇ = T∘R satisfy S4 axioms (idempotence) and temporal coherence laws (T∘R∘T = T, R∘T∘R = R).

5. **CPT Algebra** (§7): We formalize CPT triples as three involutions and prove: (a) commutativity implies involutivity of CPT; (b) involutivity of CPT implies CPT = TPC.

## 2. Preliminaries

### 2.1 Galois Connections

A **Galois connection** between preordered sets (α, ≤) consists of monotone functions T, R : α → α satisfying T(a) ≤ b ⟺ a ≤ R(b) for all a, b. Standard consequences:
- a ≤ R(T(a)) (extensiveness of R∘T)
- T(R(b)) ≤ b (contractiveness of T∘R)  
- T∘R∘T = T, R∘T∘R = R (coherence)
- R∘T is idempotent, T∘R is idempotent

### 2.2 Nuclei

A **nucleus** on a semilattice (α, ⊓) is a function j : α → α satisfying:
- j(a ⊓ b) = j(a) ⊓ j(b) (meet preservation)
- j(j(a)) = j(a) (idempotence, follows from j(j(a)) ≤ j(a))
- a ≤ j(a) (extensiveness)

The fixed points Fix(j) = {a | j(a) = a} form a sublattice of α. When α is a Heyting algebra, Fix(j) inherits a Heyting algebra structure with implication a ⇨_j b := j(a ⇨ b).

### 2.3 Heyting Algebras

A **Heyting algebra** is a bounded lattice with an operation ⇨ satisfying: c ⊓ a ≤ b ⟺ c ≤ a ⇨ b. The complement is ¬a := a ⇨ ⊥. Unlike Boolean algebras, Heyting algebras need not satisfy a ⊔ ¬a = ⊤.

## 3. The Retrocausal Implication

**Definition 3.1.** Given a nucleus ν on a Heyting algebra α, the *retrocausal implication* is:
$$a \Rightarrow_\nu b := \nu(a \Rightarrow b)$$

**Theorem 3.2** (Nucleus Heyting Adjunction). *For fixed points a, b, c of ν:*
$$c \wedge a \leq b \iff c \leq a \Rightarrow_\nu b$$

*Proof sketch.* 
(⇒): If c ⊓ a ≤ b, then c ≤ a ⇨ b by the Heyting adjunction in the base algebra. Since c is a fixed point, c = ν(c) ≤ ν(a ⇨ b) by monotonicity of ν.

(⇐): If c ≤ ν(a ⇨ b), then c ⊓ a = ν(c) ⊓ ν(a) = ν(c ⊓ a) ≤ ν((a ⇨ b) ⊓ a) ≤ ν(b) = b, using meet preservation and the modus ponens inequality (a ⇨ b) ⊓ a ≤ b. □

This theorem is the key result establishing that retrocausal logic is intuitionistic: the fixed-point lattice carries a Heyting algebra structure, but need not be Boolean.

## 4. Temporal Modalities

**Definition 4.1.** For a Galois connection (T, R):
- The *box* modality: □a := R(T(a)) (temporal necessity)
- The *diamond* modality: ◇a := T(R(a)) (temporal possibility)

**Theorem 4.2** (S4 Axioms). *For any Galois connection on a partial order:*
1. □□a = □a (S4 for necessity)
2. ◇◇a = ◇a (S4 for possibility)
3. a ≤ □a (T axiom for necessity)
4. ◇a ≤ a (dual T axiom for possibility)

*Proof.* For (1): □□a = R(T(R(T(a)))) and by right coherence R∘T∘R = R, this equals R(T(a)) = □a. For (2): similarly by left coherence T∘R∘T = T. Properties (3) and (4) are the unit and counit of the adjunction. □

**Theorem 4.3** (K Axiom). *□(a ⊓ b) ≤ □a ⊓ □b.*

*Proof.* By monotonicity: a ⊓ b ≤ a implies R(T(a ⊓ b)) ≤ R(T(a)), and similarly for b. □

**Theorem 4.4** (Temporal Coherence Laws).
1. T(R(T(a))) = T(a) (left coherence)
2. R(T(R(a))) = R(a) (right coherence)

These laws express that forward and backward propagation are *coherent*: a round trip through the opposite direction doesn't change the outcome.

## 5. LEM Failure on Fixed Points

**Construction 5.1.** The three-element chain {⊥ < mid < ⊤} carries a Heyting algebra structure with:
- a ⇨ b = ⊤ if a ≤ b, and a ⇨ b = b otherwise
- ¬a = ⊤ if a = ⊥, and ¬a = ⊥ otherwise

**Theorem 5.2** (LEM Failure). *In the three-element chain, mid ⊔ midᶜ ≠ ⊤.*

*Proof.* midᶜ = mid ⇨ ⊥ = ⊥ (since mid > ⊥). Then mid ⊔ ⊥ = mid ≠ ⊤. □

**Theorem 5.3** (Double Negation Failure). *¬¬mid ≠ mid.*

*Proof.* ¬mid = ⊥, so ¬¬mid = ¬⊥ = ⊤ ≠ mid. □

The three-element chain arises naturally as the fixed-point lattice of a nucleus on a Boolean algebra. For instance, on the power set lattice P({0,1}), the nucleus j(S) = S ∪ {0,1} if 0 ∈ S, j(S) = S otherwise, has fixed points {∅, {1}, {0,1}}, which form exactly the three-element chain.

## 6. Temporal Excluded Middle

**Theorem 6.1** (Temporal Excluded Middle). *In any Boolean algebra with a Galois connection (T, R):*
$$R(T(a)) \lor R(T(a^c)) = \top$$

*Proof.* By extensiveness, a ≤ R(T(a)) and aᶜ ≤ R(T(aᶜ)). Therefore:
$$R(T(a)) \lor R(T(a^c)) \geq a \lor a^c = \top$$
Since x ≤ ⊤ for all x, we conclude R(T(a)) ⊔ R(T(aᶜ)) = ⊤. □

This theorem reveals the fundamental asymmetry of retrocausal logic: while the propositional level (fixed points) may fail LEM, the temporal level (closure applied to complementary pairs) always satisfies it. The closure operator "classicalizes" the temporal fragment.

## 7. CPT Symmetry

**Definition 7.1.** A *CPT triple* on a type α consists of three involutions C, P, T : α → α.

**Theorem 7.2.** *If C, P, T pairwise commute, then C∘P∘T is an involution.*

*Proof.* (C∘P∘T)² = C(P(T(C(P(T(x)))))) = C(P(C(T(P(T(x)))))) [by CT comm] = C(C(P(T(P(T(x)))))) [by CP comm] = P(T(P(T(x)))) [by C²=id] = P(P(T(T(x)))) [by PT comm] = T(T(x)) [by P²=id] = x [by T²=id]. □

**Theorem 7.3** (CPT Reversal). *If C∘P∘T is an involution, then C∘P∘T = T∘P∘C.*

*Proof.* Set f = C∘P∘T. Since f is involutive, f = f⁻¹. The inverse of C∘P∘T is T⁻¹∘P⁻¹∘C⁻¹ = T∘P∘C (each being its own inverse). Hence C∘P∘T = T∘P∘C. 

More concretely: apply involutivity to T(P(C(a))). Then f(f(T(P(C(a))))) = T(P(C(a))). But f(T(P(C(a)))) = C(P(T(T(P(C(a)))))) = C(P(P(C(a)))) = C(C(a)) = a. So f(a) = T(P(C(a))), i.e., C(P(T(a))) = T(P(C(a))). □

## 8. From Galois Connections to Nuclei

**Theorem 8.1.** *If (T, R) is a Galois connection on a semilattice and T preserves binary meets, then R∘T is a nucleus.*

*Proof.* Extensiveness and idempotence follow from the Galois connection. For meet preservation: R(T(a ⊓ b)) = R(T(a) ⊓ T(b)) [by T preserving meets] = R(T(a)) ⊓ R(T(b)) [by R preserving meets as a right adjoint]. □

This theorem provides the bridge from temporal Galois connections to the Heyting algebra structure of fixed points, completing the logical picture: a meet-preserving temporal propagation operator naturally produces an intuitionistic quotient.

## 9. The Retrocausal Frame Construction

We also define retrocausal Kripke frames — structures with both a temporal partial order and a retrocausal accessibility relation constrained to flow backward in time. The upward-closed sets in such a frame form a Heyting algebra, providing a semantic model for retrocausal intuitionistic logic.

**Definition 9.1.** A *retrocausal frame* (W, ≤, R) consists of:
- A set of worlds W
- A temporal preorder ≤ on W
- A retrocausal accessibility relation R on W
- The constraint: if R(w₁, w₂) then w₁ ≤ w₂ (access flows backward in time)

The upward-closed subsets of W form a Heyting algebra under set-theoretic operations, providing a concrete model for the abstract theory developed above.

## 10. Falsifiable Conjecture

**Conjecture 10.1** (Nucleus Spectrum Bound). *For any nucleus ν on the power set lattice P(Fin(n)), the number of fixed points satisfies |Fix(ν)| ≤ 2^(n-1) + 1.*

**Rationale.** The meet-preservation condition j(a ⊓ b) = j(a) ⊓ j(b) forces structural constraints on which subsets can be identified. In particular, j(a) ⊓ j(aᶜ) = j(⊥) = ⊥ (since j is extensive and preserves meets with ⊥), which constrains complementary pairs.

**Test.** Enumerate all nuclei on P(Fin(3)) (the 256-element Boolean algebra) and count fixed points. If any nucleus has more than 5 fixed points, the conjecture is false.

## 11. Discussion

### 11.1 Physical Interpretation

The mathematical results formalize a precise sense in which retrocausal physical theories require intuitionistic reasoning. Any system where information propagates both forward and backward in time, with these propagations forming a Galois connection, generates a nucleus whose fixed points — the "temporally stable" propositions — form a Heyting algebra. Classical reasoning (LEM) holds at the temporal level but fails at the propositional level.

### 11.2 Connection to Quantum Mechanics

The transactional interpretation of quantum mechanics models quantum events as "handshakes" between forward-traveling offer waves and backward-traveling confirmation waves. This has the structure of a Galois connection, and our results predict that the logic of stable quantum propositions should be intuitionistic — a prediction consistent with the quantum logic tradition initiated by Birkhoff and von Neumann.

### 11.3 The S4 Modal Structure

The automatic emergence of S4 modal axioms from the Galois connection structure connects retrocausal logic to the extensive mathematical literature on modal logic and topology. The S4 axioms characterize the logic of topological interior and closure operators, and our results show this connection is not accidental but forced by the temporal adjunction.

## 12. Future Work

1. Extend the CPT algebraic theory to include the full structure of the Lorentz group.
2. Investigate whether the nucleus spectrum bound conjecture holds, and if so, characterize the extremal nuclei.
3. Connect the retrocausal frame construction to concrete quantum mechanical systems.
4. Develop the categorical perspective: retrocausal structures as enriched categories.

## References

1. Birkhoff, G. and von Neumann, J. "The Logic of Quantum Mechanics." *Annals of Mathematics*, 1936.
2. Cramer, J.G. "The Transactional Interpretation of Quantum Mechanics." *Reviews of Modern Physics*, 1986.
3. Johnstone, P.T. *Stone Spaces.* Cambridge University Press, 1982.
4. Mac Lane, S. and Moerdijk, I. *Sheaves in Geometry and Logic.* Springer, 1994.
5. Price, H. *Time's Arrow and Archimedes' Point.* Oxford University Press, 1996.
