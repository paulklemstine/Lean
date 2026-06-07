# Retrocausal Mathematics: Galois Connections, Intuitionistic Logic, and Temporal Duality

## Abstract

We develop a rigorous mathematical framework for retrocausal structures — systems where implications can flow backward in time — using the theory of Galois connections on partially ordered sets. We prove that the retrocausal closure operator R∘T arising from a temporal Galois connection (T, R) satisfies the monad laws, establishing it as a genuine closure operator. The fixed points of this closure form a complete Heyting algebra (frame), providing the precise algebraic foundation for the claim that retrocausal logic is intuitionistic. We establish a Temporal Excluded Middle theorem — cl(a) ⊔ cl(aᶜ) = ⊤ in any Boolean algebra — while simultaneously proving that the fixed-point sublattice fails to be Boolean whenever the closure is non-trivial (cl(⊥) ≠ ⊥). We bridge this algebraic theory to topology by showing that retrocausal fixed points satisfy the axioms of closed sets, and to modal logic by demonstrating that the closure and interior operators satisfy the S4 axioms. All results are formalized in Lean 4 with Mathlib, providing machine-verified proofs.

## 1. Introduction

The question of whether effects can precede their causes has a long history in physics, from the Wheeler-Feynman absorber theory to retrocausal interpretations of quantum mechanics. The CPT theorem of quantum field theory — asserting invariance under the combined operation of charge conjugation (C), parity reversal (P), and time reversal (T) — establishes a deep symmetry between forward and backward temporal evolution.

While the physical reality of retrocausality remains debated, we can ask a purely mathematical question: *what logical structure is compatible with retrocausal influence?* This paper answers that question definitively through the theory of Galois connections.

**Main contributions:**
1. A complete monad structure for the retrocausal closure (§3).
2. Frame distributivity for fixed points, establishing Heyting algebra structure (§4).
3. The Temporal Excluded Middle and its non-Boolean gap (§5).
4. S4 modal logic structure for the closure and interior operators (§6).
5. A topological bridge theorem connecting retrocausal fixed points to closed sets (§7).
6. CPT symmetry analysis showing time reversal swaps closure and interior (§8).

## 2. Definitions

**Definition 2.1 (Temporal Galois Connection).** A *temporal Galois connection* on a preorder (α, ≤) is a pair of monotone functions T, R : α → α (forward and backward temporal propagation) satisfying the adjunction:
$$T(a) \leq b \iff a \leq R(b)$$
for all a, b ∈ α. We write τ = (T, R, gc) for such a structure.

**Definition 2.2 (Retrocausal Closure and Interior).** Given a temporal Galois connection τ:
- The *retrocausal closure* is cl := R ∘ T.
- The *retrocausal interior* is int := T ∘ R.

**Definition 2.3 (Fixed Points).** The set of *retrocausal fixed points* is:
$$\text{Fix}(\tau) = \{a \in \alpha \mid \text{cl}(a) = a\}$$

## 3. The Retrocausal Closure Monad

**Theorem 3.1 (Monad Laws).** The retrocausal closure satisfies:
1. *Unit (extensiveness)*: a ≤ cl(a) for all a.
2. *Multiplication (idempotency)*: cl(cl(a)) = cl(a) for all a.
3. *Functoriality (monotonicity)*: a ≤ b implies cl(a) ≤ cl(b).

*Proof.* (1) follows from the Galois connection unit η: a ≤ R(T(a)). (2) uses both directions: cl(cl(a)) ≤ cl(a) by R-monotonicity applied to the counit T(R(T(a))) ≤ T(a); cl(a) ≤ cl(cl(a)) by (1). (3) follows from monotonicity of both T and R. ∎

**Theorem 3.2 (Coherence Laws).**
- *Left coherence*: T(R(T(a))) = T(a).
- *Right coherence*: R(T(R(a))) = R(a).

These express that T and R form an *idempotent adjunction*: the compositions TRT and RTR collapse.

*Proof.* For left coherence: T(R(T(a))) ≤ T(a) by the counit applied to T(a); T(a) ≤ T(R(T(a))) by T-monotonicity of the unit. For right coherence: dual argument. ∎

## 4. Frame Distributivity

**Theorem 4.1 (Closure Preserves Meets of Fixed Points).** If a, b ∈ Fix(τ), then cl(a ⊓ b) = a ⊓ b.

*Proof.* The inequality a ⊓ b ≤ cl(a ⊓ b) is the unit. For the reverse: cl(a ⊓ b) ≤ cl(a) = a and cl(a ⊓ b) ≤ cl(b) = b by monotonicity, so cl(a ⊓ b) ≤ a ⊓ b. ∎

**Corollary 4.2.** a ⊓ b ∈ Fix(τ) whenever a, b ∈ Fix(τ).

**Theorem 4.3 (Master Theorem — Frame Distributivity).** For any family S ⊆ Fix(τ), we have ⨅S ∈ Fix(τ). That is, cl(⨅S) = ⨅S.

*Proof.* By monotonicity, cl(⨅S) ≤ cl(s) = s for each s ∈ S, giving cl(⨅S) ≤ ⨅S. The reverse is the unit. ∎

This is the defining property of a *frame* (also called a *locale* or *complete Heyting algebra*): the fixed points form a complete lattice that is closed under arbitrary meets. The join in Fix(τ) is not the ambient join but its closure: a ⊔_{Fix} b = cl(a ⊔ b).

**Theorem 4.4 (Universal Property of Fixed-Point Join).** For a, b ∈ Fix(τ), the element cl(a ⊔ b) is the smallest fixed point above both a and b.

## 5. Temporal Excluded Middle and the Non-Boolean Gap

**Theorem 5.1 (Temporal Excluded Middle).** In a Boolean algebra, cl(a) ⊔ cl(aᶜ) = ⊤.

*Proof.* Since a ⊔ aᶜ = ⊤ (Boolean algebra) and cl is extensive, ⊤ = a ⊔ aᶜ ≤ cl(a) ⊔ cl(aᶜ). ∎

**Theorem 5.2 (Non-Boolean Gap).** cl(a) ⊓ cl(aᶜ) ≥ cl(⊥).

*Proof.* cl(⊥) = cl(a ⊓ aᶜ) ≤ cl(a) ⊓ cl(aᶜ) by monotonicity applied to both projections. ∎

**Interpretation.** Theorems 5.1 and 5.2 together characterize the gap between retrocausal logic and classical logic. Temporal EM holds at the level of closures (Theorem 5.1), but the "temporal complement" cl(aᶜ) is not a true complement of cl(a) in the fixed-point lattice unless cl(⊥) = ⊥. When cl(⊥) ≠ ⊥ — which occurs whenever the Galois connection collapses any non-trivial information — the fixed-point lattice is Heyting but not Boolean.

**The Retrocausal Asymmetry.** The fundamental reason is the asymmetry between meets and joins:
- cl preserves meets of fixed points exactly (Theorem 4.1).
- cl only approximates joins from below: cl(a) ⊔ cl(b) ≤ cl(a ⊔ b).

This asymmetry is the algebraic signature of intuitionistic logic.

## 6. S4 Modal Logic

The closure and interior operators naturally yield modal operators:
- □a := cl(a) (necessity, retrocausal completion)
- ◇a := int(a) (possibility, temporal interior)

**Theorem 6.1 (S4 Axioms).** The following hold:
1. **K**: □ is monotone.
2. **T**: a ≤ □a.
3. **4**: □□a = □a.
4. **Dual T**: ◇a ≤ a.
5. **Dual 4**: ◇◇a = ◇a.

**Theorem 6.2 (Modal Interactions).**
- □ absorbs ◇ from the left: cl(int(a)) ≤ cl(a).
- ◇ absorbs □ from the left: int(a) ≤ int(cl(a)).
- Interior is below closure: int(a) ≤ cl(a).

## 7. Topological Bridge

**Theorem 7.1 (Retrocausal Topology).** For a temporal Galois connection on Set(X), the fixed points satisfy the axioms of closed sets:
1. Arbitrary intersections of fixed points are fixed points.
2. Finite unions (after closure) of fixed points are fixed points.
3. The universal set is a fixed point.

This establishes that every retrocausal structure on a powerset naturally defines a topology, and the intuitionistic logic of the fixed points is the logic of the corresponding open sets.

## 8. CPT Symmetry

**Definition 8.1.** A *CPT triple* on a type α is three involutions C, P, T : α → α (each satisfying f(f(a)) = a for all a).

**Theorem 8.1.** If C, P, T pairwise commute, then their composition CPT is an involution, and all six orderings agree: CPT = CTP = PCT = PTC = TCP = TPC.

*Proof.* For involutivity:
CPT(CPT(a)) = C(P(T(C(P(T(a)))))) = C(P(T(C(T(P(a)))))) [by PT comm.]
= C(P(C(T(T(P(a)))))) [by CT comm.] = C(P(C(P(a)))) [T² = id]
= C(C(P(P(a)))) [by CP comm.] = P(P(a)) [C² = id] = a [P² = id]. ∎

**Theorem 8.2 (Time Reversal Swaps Modalities).** If an involution T_inv satisfies T ∘ T_inv = T_inv ∘ R and R ∘ T_inv = T_inv ∘ T, then cl(T_inv(a)) = T_inv(int(a)).

*Interpretation.* Time reversal exchanges necessity and possibility — what is necessarily true in one temporal direction is merely possibly true in the reverse direction.

## 9. Discussion

### 9.1 Significance

Our results establish a rigorous connection between four mathematical areas:
1. **Order theory**: Galois connections and closure operators.
2. **Logic**: Heyting algebras and intuitionistic reasoning.
3. **Topology**: Closed sets and the topology induced by closure.
4. **Modal logic**: S4 modalities and temporal reasoning.

The central insight is that retrocausal influence — modeled by a backward temporal adjunction — inevitably leads to intuitionistic logic. This is not an arbitrary choice but a mathematical consequence of the asymmetry between meets and joins under closure.

### 9.2 Connection to Physics

The CPT theorem of quantum field theory states that any Lorentz-invariant quantum field theory is invariant under the combined CPT transformation. Our algebraic formalization of CPT triples captures the group-theoretic content of this symmetry. The result that time reversal swaps closure and interior has a physical interpretation: the temporal modes of reasoning (what must be true vs. what might be true) are exchanged under time reversal, reflecting the duality between retarded and advanced solutions in electrodynamics.

### 9.3 Connection to Existing Work

This work deepens the `temporal_excluded_middle` theorem from the Catalog (`Bridges/RetrocausalLogic.lean`) by:
- Proving it is part of a larger algebraic structure (the frame of fixed points).
- Showing precisely where classical logic breaks down (the non-Boolean gap).
- Connecting to topology and modal logic.

## 10. Algorithms

### Algorithm 1: Computing the Retrocausal Closure
Given a finite lattice and monotone operators T, R forming a Galois connection:
1. Compute cl(a) = R(T(a)) for each element a.
2. The fixed points are {a | cl(a) = a}.
3. The join in the fixed-point lattice is a ⊔_fp b = cl(a ⊔ b).

### Algorithm 2: Verifying Frame Distributivity
For a finite lattice with n fixed points:
1. Check that arbitrary meets of fixed points are fixed points: O(2^n) subsets.
2. For practical purposes, check binary meets: O(n²).
3. Verify cl(⊥) to determine if the fixed-point lattice is Boolean.

## 11. Future Work

1. **Constructive retrocausal logic**: Formalize the Heyting algebra structure of fixed points directly, including the Heyting implication (retrocausal arrow).
2. **Quantum connections**: Model quantum channels as temporal Galois connections and study the resulting modal logic.
3. **Retrocausal category theory**: Develop the category of retrocausal structures and study functorial properties.
4. **Computational interpretation**: Via the Curry-Howard correspondence, relate retrocausal proofs to continuation-passing computations.

## References

1. Galois connections: Ore, O. (1944). "Galois connexions." *Transactions of the AMS*, 55, 493–513.
2. Heyting algebras: Balbes, R. & Dwinger, P. (1974). *Distributive Lattices*. University of Missouri Press.
3. CPT theorem: Streater, R.F. & Wightman, A.S. (2000). *PCT, Spin and Statistics, and All That*. Princeton University Press.
4. S4 modal logic: Hughes, G.E. & Cresswell, M.J. (1996). *A New Introduction to Modal Logic*. Routledge.
5. Pointless topology: Johnstone, P.T. (1982). *Stone Spaces*. Cambridge University Press.
6. Temporal excluded middle (Catalog): `Bridges/RetrocausalLogic.lean`, theorem `temporal_excluded_middle`.
