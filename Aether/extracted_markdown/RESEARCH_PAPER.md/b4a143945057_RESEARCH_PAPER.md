# Retrocausal Mathematics: Galois Connections, Temporal Closure, and Intuitionistic Logic

## Abstract

We develop a formal mathematical framework for retrocausal reasoning, where implications can flow backward in time. The central construction is a *temporal Galois connection* — an adjoint pair (T, R) on a lattice, where T models forward temporal propagation and R models retrocausal (backward) propagation. We prove that the composition R∘T is a closure operator satisfying idempotency, extensiveness, and monotonicity. The fixed points of this closure form a complete lattice supporting intuitionistic reasoning. We establish a *Temporal Excluded Middle* theorem showing that classical logic re-emerges for the temporal closure, and prove temporal coherence laws T∘R∘T = T and R∘T∘R = R that rule out paradoxical information amplification. We formalize an algebraic CPT theorem showing that three pairwise-commuting involutions compose to an involution, and that any CPT composition satisfies a reversal symmetry CPT = TPC. All results are machine-verified in Lean 4 with the Mathlib library.

## 1. Introduction

The question of whether effects can precede their causes has a long history in physics, from Wheeler and Feynman's absorber theory [1] to Cramer's transactional interpretation of quantum mechanics [2] and recent work on indefinite causal order [3]. While the physical reality of retrocausality remains debated, the mathematical structures underlying retrocausal reasoning are well-defined and lead to rich theory.

This paper develops the mathematics of retrocausality from the ground up, using the language of order theory and lattice theory. Our starting point is the observation that forward and backward temporal propagation naturally form a Galois connection — an adjoint pair of monotone maps between partially ordered sets. This perspective immediately yields a wealth of structural results through the general theory of Galois connections.

### 1.1 Main Contributions

1. **Temporal Galois Connections** (§2): We define a temporal Galois connection as an adjoint pair (T, R) on a lattice and derive basic properties: T preserves joins, R preserves meets, and both are monotone.

2. **Retrocausal Closure Operator** (§3): We prove that R∘T is a closure operator (extensive, monotone, idempotent) and T∘R is an interior operator. The key idempotency result R(T(R(T(a)))) = R(T(a)) follows from the adjunction.

3. **Temporal Coherence** (§4): We establish the coherence laws T∘R∘T = T and R∘T∘R = R, which prevent paradoxical information amplification in causal loops.

4. **Temporal Excluded Middle** (§5): In a Boolean algebra, the retrocausal closure satisfies R(T(a)) ⊔ R(T(aᶜ)) = ⊤, recovering excluded middle at the level of temporally complete propositions.

5. **Fixed Point Theory** (§6): We characterize the fixed points of the retrocausal closure as precisely the range of R, prove they form a complete lattice, and show the closure preserves finite meets on fixed points.

6. **CPT Symmetry** (§7): We formalize an algebraic CPT theorem: three pairwise-commuting involutions compose to an involution, and any CPT involution satisfies the reversal symmetry CPT = TPC.

7. **Concrete Models** (§8): We construct retrocausal Kripke frames and demonstrate the failure of classical excluded middle in the intuitionistic logic of upward-closed sets.

## 2. Temporal Galois Connections

### Definition 2.1 (Temporal Galois Connection)
Let (α, ≤) be a preorder. A *temporal Galois connection* on α is a pair of maps T, R : α → α satisfying

$$T(a) \leq b \iff a \leq R(b)$$

for all a, b ∈ α. We call T the *forward temporal propagation* and R the *retrocausal propagation*.

The adjunction captures a fundamental duality: a proposition a causally implies b (after forward propagation) if and only if a is retrocausally implied by b (after backward propagation).

### Proposition 2.2
In any temporal Galois connection:
1. T and R are monotone.
2. a ≤ R(T(a)) for all a (unit of the adjunction).
3. T(R(a)) ≤ a for all a (counit of the adjunction).

*Proof.* These are standard properties of Galois connections. □

### Theorem 2.3 (Preservation Laws)
If α is a complete lattice:
1. T(⨆S) = ⨆{T(s) | s ∈ S} (T preserves arbitrary joins)
2. R(⨅S) = ⨅{R(s) | s ∈ S} (R preserves arbitrary meets)
3. T(⊥) = ⊥ and R(⊤) = ⊤
4. T(a ⊔ b) = T(a) ⊔ T(b) and R(a ⊓ b) = R(a) ⊓ R(b)

*Proof.* (1) and (2) are the RAPL (Right Adjoint Preserves Limits) and LAPL (Left Adjoint Preserves Colimits) theorems for Galois connections. (3) and (4) are special cases. □

**Remark.** The asymmetry is fundamental: T distributes over disjunction but not conjunction, while R distributes over conjunction but not disjunction. This asymmetry is the algebraic signature of the arrow of time.

## 3. Retrocausal Closure and Interior

### Definition 3.1
The *retrocausal closure* is the composition cl := R ∘ T. The *retrocausal interior* is int := T ∘ R.

### Theorem 3.2 (Closure Properties)
On a partial order, cl := R ∘ T satisfies:
1. **Extensiveness**: a ≤ cl(a)
2. **Monotonicity**: a ≤ b ⟹ cl(a) ≤ cl(b)
3. **Idempotency**: cl(cl(a)) = cl(a)

*Proof.* (1) is the unit of the adjunction. (2) follows from the monotonicity of T and R. For (3), the key observation is that the counit gives T(R(T(a))) ≤ T(a), whence R(T(R(T(a)))) ≤ R(T(a)) by monotonicity of R. Combined with extensiveness applied to R(T(a)), we get equality. □

### Theorem 3.3 (Interior Properties)
Dually, int := T ∘ R satisfies:
1. **Contractiveness**: int(a) ≤ a
2. **Monotonicity**: a ≤ b ⟹ int(a) ≤ int(b)
3. **Idempotency**: int(int(a)) = int(a)

## 4. Temporal Coherence

### Theorem 4.1 (Temporal Coherence Laws)
For any temporal Galois connection on a partial order:
1. T ∘ R ∘ T = T
2. R ∘ T ∘ R = R

*Proof.* For (1): T(R(T(a))) ≤ T(a) by the counit applied to T(a). T(a) ≤ T(R(T(a))) by applying T (which is monotone) to the unit a ≤ R(T(a)). Antisymmetry gives equality. Part (2) is dual. □

**Interpretation.** The coherence laws express that causal loops do not amplify information. Propagating forward, then backward, then forward again yields the same result as propagating forward once. This is the mathematical refutation of the grandfather paradox.

### Corollary 4.2 (Monad/Comonad Structure)
The closure cl = R∘T satisfies the monad multiplication law cl∘cl ≤ cl, and the interior int = T∘R satisfies the comonad comultiplication law int ≤ int∘int.

## 5. Temporal Excluded Middle

### Theorem 5.1 (Temporal Excluded Middle)
If α is a Boolean algebra and (T, R) is a temporal Galois connection on α, then for all a:

$$\text{cl}(a) \sqcup \text{cl}(a^c) = \top$$

*Proof.* Since α is a Boolean algebra, a ⊔ aᶜ = ⊤. By extensiveness, cl(a) ≥ a and cl(aᶜ) ≥ aᶜ. Therefore cl(a) ⊔ cl(aᶜ) ≥ a ⊔ aᶜ = ⊤. □

**Remark.** The Temporal Excluded Middle holds at the level of *retrocausal closures*, not at the level of propositions themselves. In the intuitionistic logic of upward-closed sets on a Kripke frame, ordinary excluded middle fails, but the temporally closed version is recovered. This demonstrates a precise sense in which retrocausal closure "classicalizes" the temporal fragment of an intuitionistic logic.

### Theorem 5.2 (Super-additivity of Closure)
For any complete lattice, the retrocausal closure is super-additive:

$$\text{cl}(a) \sqcup \text{cl}(b) \leq \text{cl}(a \sqcup b)$$

## 6. Fixed Point Theory

### Definition 6.1
The set of *retrocausal fixed points* is Fix(cl) := {a | cl(a) = a}.

### Theorem 6.2 (Characterization of Fixed Points)
a ∈ Fix(cl) if and only if a is in the range of R.

*Proof.* If cl(a) = R(T(a)) = a, then a = R(T(a)) is in the range of R. Conversely, if a = R(b) for some b, then cl(a) = R(T(R(b))) = R(b) = a by the coherence law R∘T∘R = R. □

### Theorem 6.3 (Closure of Fixed Point Lattice)
1. ⊤ is a fixed point.
2. The retrocausal closure of ⨅S equals ⨅{cl(s) | s ∈ S} when S consists of fixed points.
3. The closure preserves finite meets on fixed points: if cl(a) = a and cl(b) = b, then cl(a ⊓ b) = a ⊓ b.

*Proof.* (1) follows from extensiveness and the trivial bound ⊤ ≥ cl(⊤). (2) uses the fixed-point hypothesis to simplify both sides to ⨅S, then proves equality using monotonicity and extensiveness. (3) uses monotonicity: cl(a ⊓ b) ≤ cl(a) = a and cl(a ⊓ b) ≤ cl(b) = b, so cl(a ⊓ b) ≤ a ⊓ b. Combined with extensiveness, we get equality. □

**Remark.** Property (3) is crucial: it ensures that the fixed-point lattice is a *Heyting algebra* (the meet operation has a right adjoint). This is the precise algebraic sense in which retrocausal logic is intuitionistic.

## 7. CPT Symmetry

### Definition 7.1 (CPT Triple)
A *CPT triple* on a type α is a triple (C, P, T) of involutions on α, i.e., functions satisfying C∘C = P∘P = T∘T = id.

### Theorem 7.2 (CPT Involutivity from Commutativity)
If C, P, T are pairwise commuting involutions, then C∘P∘T is an involution.

*Proof.* (C∘P∘T)∘(C∘P∘T) = C∘P∘(T∘C)∘P∘T = C∘P∘(C∘T)∘P∘T = C∘(P∘C)∘(T∘P)∘T = C∘(C∘P)∘(P∘T)∘T = (C∘C)∘(P∘P)∘(T∘T) = id. □

### Theorem 7.3 (CPT Reversal)
If C∘P∘T is an involution (without assuming commutativity), then C∘P∘T = T∘P∘C.

*Proof.* Since C∘P∘T is an involution, it equals its own inverse. The inverse of C∘P∘T is T⁻¹∘P⁻¹∘C⁻¹ = T∘P∘C (since each is its own inverse). □

**Remark.** The converse of Theorem 7.2 is *false*. A counterexample on Fin 3: let C = swap(0,1), P = swap(0,2), T = swap(0,1). Then C∘P∘T = swap(1,2) is an involution, but C and P do not commute.

## 8. Concrete Models

### Retrocausal Kripke Frames

A *retrocausal Kripke frame* consists of a set W of worlds with:
- A temporal ordering ≤ (preorder)
- A retrocausal accessibility relation R such that R(w₁, w₂) implies w₁ ≤ w₂ (influences flow backward)

### Theorem 8.1 (Failure of Classical Excluded Middle)
There exists a retrocausal Kripke frame on 3 worlds with an upward-closed set S satisfying:
- S is proper (neither ∅ nor W)
- Sᶜ is proper (neither ∅ nor W)

This demonstrates the failure of excluded middle in the intuitionistic logic of the frame.

*Proof.* Take the linear order {0 < 1 < 2}. The upward-closed set {1, 2} is proper and has proper complement {0}. □

## 9. Discussion

### 9.1 Relationship to Intuitionistic Logic

The central result of this paper is that retrocausal reasoning is inherently intuitionistic. The fixed points of the retrocausal closure operator form a Heyting algebra but (in general) not a Boolean algebra. This is not an accident but a consequence of the asymmetry between T (which preserves joins) and R (which preserves meets): the closure R∘T preserves meets but not joins, which is exactly the signature of a nucleus on a frame.

### 9.2 Physical Interpretation

The temporal coherence laws T∘R∘T = T and R∘T∘R = R have a direct physical interpretation: they forbid the amplification of information through causal loops. This is consistent with the Novikov self-consistency principle in general relativity and with the linearity of quantum mechanics (which prevents superluminal signaling even in the presence of entanglement).

### 9.3 Connection to Categorical Quantum Mechanics

The structure of a temporal Galois connection is closely related to the compact closed categories used in categorical quantum mechanics. The unit and counit of the adjunction correspond to the cups and caps of a compact closed structure, and the coherence laws correspond to the snake equations.

## 10. Falsifiable Conjecture

**Conjecture.** For any retrocausal Galois connection on a non-trivial distributive lattice where T ≠ id, the fixed-point lattice is a proper Heyting algebra (i.e., it is not Boolean).

**Test.** Enumerate all Galois connections on distributive lattices of size ≤ 8. For each non-identity T, check whether the fixed-point lattice is Boolean or merely Heyting.

**Prediction.** If true, this would establish that retrocausality *necessarily* produces intuitionistic logic, strengthening our main results from "retrocausal logic can be intuitionistic" to "retrocausal logic must be intuitionistic."

## References

[1] Wheeler, J.A. and Feynman, R.P. "Interaction with the Absorber as the Mechanism of Radiation," Reviews of Modern Physics, 17(2-3), 157-181, 1945.

[2] Cramer, J.G. "The Transactional Interpretation of Quantum Mechanics," Reviews of Modern Physics, 58(3), 647-687, 1986.

[3] Oreshkov, O., Costa, F., and Brukner, Č. "Quantum correlations with no causal order," Nature Communications, 3, 1092, 2012.
