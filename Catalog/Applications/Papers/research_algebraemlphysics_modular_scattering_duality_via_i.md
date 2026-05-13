# Modular Scattering Duality via Idempotent Closure-Scattering Systems: Certified Minimal Resonance Reconstruction

## Abstract

We introduce **closure-scattering systems** — structures consisting of a closure operator, a transfer map, and boundary observation functionals on a finite state space — and establish a complete duality and minimal realization theory for them. The **resonance congruence**, defined as observational indistinguishability under iterated transfer and boundary evaluation, is shown to be the coarsest equivalence compatible with the system's dynamics. Quotienting by this congruence yields the **minimal realization**: a unique (up to isomorphism) separated system reproducing all boundary response data. The dual object, the **spectral boundary semimodule** — a shift-closed set of response profiles — provides a complete invariant for separated systems. These results are stated and machine-verified in the Lean 4 proof assistant with the Mathlib library.

**Keywords:** closure operator, scattering theory, minimal realization, resonance congruence, idempotent semiring, tropical algebra, Myhill-Nerode theorem, spectral duality, boundary inverse problem

---

## 1. Introduction

### 1.1 Motivation

The reconstruction of internal system structure from boundary measurements is a fundamental problem across mathematics, physics, and engineering. Classical instances include:

- **Minimal realization** in linear systems theory (Kalman 1963): reconstructing a state-space model from input-output (Hankel) data.
- **Myhill-Nerode minimization** in automata theory: constructing the unique minimal DFA recognizing a given regular language.
- **Inverse scattering** in mathematical physics: recovering a potential from S-matrix or scattering data.
- **Boundary inverse problems** in PDE theory: determining internal coefficients from boundary measurements (Calderón problem).

Each of these frameworks relies on specific algebraic structure (linearity, finite alphabets, Hilbert spaces). We propose a unifying framework based on **closure operators** and **idempotent algebra** that:

1. Subsumes Myhill-Nerode minimization as a special case.
2. Admits a Hankel-style realization interpretation over idempotent semirings.
3. Connects naturally to scattering-theoretic notions of resonance and channel observation.
4. Is fully machine-verified, providing certified correctness guarantees.

### 1.2 Main Contributions

1. **Definition of closure-scattering systems** (Definition 2.1): a clean axiomatization combining closure operators, transfer dynamics, and boundary observations.

2. **Resonance congruence theory** (Theorems 3.1–3.3): the resonance equivalence is an equivalence relation that is preserved by transfer, and is the coarsest such equivalence compatible with boundary observations.

3. **Spectral boundary construction** (Definition 4.1, Theorem 4.2): every closure-scattering system has a canonical dual representation as a shift-closed set of response profiles.

4. **Main duality theorem** (Theorem 5.1): separated systems with identical spectral boundaries are isomorphic.

5. **Minimal realization** (Theorem 6.1): every system has a unique minimal separated quotient, constructible from its response profiles.

6. **Certified reconstruction** (Theorem 6.2): any separated system with the same boundary data is isomorphic to the minimal realization.

### 1.3 Related Work

**Automata minimization.** The Myhill-Nerode theorem (Myhill 1957, Nerode 1958) establishes that regular languages have unique minimal DFAs. Our resonance congruence generalizes the Nerode equivalence to systems with closure structure and general observation functionals.

**Linear realization theory.** Kalman's minimal realization (1963) and Ho-Kalman's algorithm reconstruct state-space models from Hankel matrices. Our spectral boundary semimodule is the idempotent analogue of the Hankel matrix.

**Tropical and max-plus algebra.** The theory of linear systems over the max-plus semiring (Baccelli et al. 1992, Gaubert 1992) provides realization results for discrete-event systems. Our framework extends this by incorporating closure operators, which model reachability and generation beyond linear span.

**Closure operators and lattice theory.** Closure operators are classical objects in lattice theory (Birkhoff 1940) and universal algebra. Their connection to scattering theory appears to be new.

---

## 2. Definitions

### Definition 2.1 (Closure-Scattering System)

A **closure-scattering system** over types R, X, C is a tuple S = (cl, T, β) where:

- **cl : P(X) → P(X)** is a closure operator: extensive (A ⊆ cl(A)), monotone (A ⊆ B ⟹ cl(A) ⊆ cl(B)), and idempotent (cl(cl(A)) = cl(A)).
- **T : X → X** is the transfer map (one-step evolution).
- **β : X × C → R** is the boundary observation function.

### Definition 2.2 (Response Profile)

The **response profile** of a state x ∈ X is the function:

ρ_S(x) : ℕ × C → R,  ρ_S(x)(n, c) = β(T^n(x), c)

This records the complete observable history of x under iterated transfer.

### Definition 2.3 (Resonance Equivalence)

States x, y ∈ X are **resonance-equivalent**, written x ~_ρ y, if ρ_S(x) = ρ_S(y). That is, they produce identical response profiles.

### Definition 2.4 (Separated System)

A closure-scattering system is **separated** (or **reduced**) if the response profile map ρ_S is injective: distinct states have distinct profiles.

### Definition 2.5 (Closure Defect)

The **closure defect** of a set A ⊆ X is:

δ(A) = T(cl(A)) \ cl(T(A))

This measures the failure of transfer to commute with closure. When δ(A) = ∅ for all A, transfer is **closure-compatible**.

### Definition 2.6 (Spectral Boundary Semimodule)

A **spectral boundary semimodule** over (R, C) is a pair M = (P, σ) where:

- P ⊆ (ℕ → C → R) is a set of response profiles.
- σ : P → P is the shift map σ(f)(n, c) = f(n+1, c), and P is closed under σ.

### Definition 2.7 (CSS Morphism and Isomorphism)

A **morphism** φ : S₁ → S₂ between CSS's is a function φ : X₁ → X₂ such that:
- φ ∘ T₁ = T₂ ∘ φ (transfer commutation)
- β₁(x, c) = β₂(φ(x), c) (boundary preservation)

An **isomorphism** is a bijective morphism.

---

## 3. Resonance Congruence Theory

### Theorem 3.1 (Equivalence)

Resonance equivalence ~_ρ is an equivalence relation on X.

*Proof.* Immediate from the definition as equality of response profiles: reflexivity, symmetry, and transitivity of equality. □

### Theorem 3.2 (Transfer Preservation)

If x ~_ρ y, then T(x) ~_ρ T(y).

*Proof.* The response profile of T(x) is the tail-shift of the response profile of x:

ρ_S(T(x))(n, c) = β(T^n(T(x)), c) = β(T^{n+1}(x), c) = ρ_S(x)(n+1, c)

Similarly for T(y). Since ρ_S(x) = ρ_S(y), we get ρ_S(T(x)) = ρ_S(T(y)). □

### Theorem 3.3 (Coarsest Congruence — Minimality)

Resonance equivalence is the **coarsest** equivalence relation ≡ on X satisfying:
1. x ≡ y ⟹ β(x, c) = β(y, c) for all c (boundary compatibility)
2. x ≡ y ⟹ T(x) ≡ T(y) (transfer compatibility)

That is, if ≡ satisfies (1) and (2), then x ≡ y ⟹ x ~_ρ y.

*Proof.* Suppose ≡ satisfies (1) and (2) and x ≡ y. By induction on n using (2), we have T^n(x) ≡ T^n(y) for all n. By (1), β(T^n(x), c) = β(T^n(y), c) for all n, c. Thus ρ_S(x) = ρ_S(y), i.e., x ~_ρ y. □

### Theorem 3.4 (Closure Compatibility Implies Empty Defect)

If the system is closure-compatible (T(cl(A)) ⊆ cl(T(A)) for all A), then δ(A) = ∅ for all A.

*Proof.* Direct from the definition: δ(A) = T(cl(A)) \ cl(T(A)) ⊆ ∅ when T(cl(A)) ⊆ cl(T(A)). □

---

## 4. Spectral Boundary Construction

### Theorem 4.1 (Shift Closure of Response Profiles)

If f ∈ range(ρ_S), then the shifted profile σ(f) defined by σ(f)(n, c) = f(n+1, c) is also in range(ρ_S).

*Proof.* If f = ρ_S(x) for some x, then σ(f) = ρ_S(T(x)) by Theorem 3.2's proof, and T(x) ∈ X, so σ(f) ∈ range(ρ_S). □

### Definition 4.2 (Canonical Spectral Boundary)

The **spectral boundary** of S is the semimodule:

Spec(S) = (range(ρ_S), σ)

where σ is the shift map. By Theorem 4.1, this is well-defined.

### Theorem 4.3 (Morphism Preservation)

A CSS morphism φ : S₁ → S₂ satisfies ρ_{S₂}(φ(x)) = ρ_{S₁}(x) for all x.

*Proof.* By induction: φ commutes with iterated transfer (φ(T₁^n(x)) = T₂^n(φ(x))), so:
ρ_{S₂}(φ(x))(n, c) = β₂(T₂^n(φ(x)), c) = β₂(φ(T₁^n(x)), c) = β₁(T₁^n(x), c) = ρ_{S₁}(x)(n, c). □

### Corollary 4.4 (Surjective Morphisms Induce Spectral Inclusion)

If φ : S₁ → S₂ is surjective, then Spec(S₂).profiles ⊆ Spec(S₁).profiles.

---

## 5. Main Duality Theorem

### Theorem 5.1 (Isomorphism of Separated Systems with Equal Spectral Boundaries)

Let S₁ = (cl₁, T₁, β₁) over X₁ and S₂ = (cl₂, T₂, β₂) over X₂ be separated CSS's over the same (R, C). If range(ρ_{S₁}) = range(ρ_{S₂}), then S₁ ≅ S₂.

*Proof sketch.*

**Step 1: Construct the correspondence.** For each x₁ ∈ X₁, ρ_{S₁}(x₁) ∈ range(ρ_{S₁}) = range(ρ_{S₂}), so there exists x₂ ∈ X₂ with ρ_{S₂}(x₂) = ρ_{S₁}(x₁). Since S₂ is separated, x₂ is unique. Define f(x₁) = x₂.

**Step 2: f is injective.** If f(x₁) = f(x₁'), then ρ_{S₂}(f(x₁)) = ρ_{S₂}(f(x₁')), so ρ_{S₁}(x₁) = ρ_{S₁}(x₁'), so x₁ = x₁' by separation of S₁.

**Step 3: f is surjective.** For any y ∈ X₂, ρ_{S₂}(y) ∈ range(ρ_{S₂}) = range(ρ_{S₁}), so there exists x with ρ_{S₁}(x) = ρ_{S₂}(y), giving f(x) = y by uniqueness in S₂.

**Step 4: f preserves boundary.** β₁(x, c) = ρ_{S₁}(x)(0, c) = ρ_{S₂}(f(x))(0, c) = β₂(f(x), c).

**Step 5: f commutes with transfer.** ρ_{S₂}(f(T₁(x))) = ρ_{S₁}(T₁(x)) = σ(ρ_{S₁}(x)) = σ(ρ_{S₂}(f(x))) = ρ_{S₂}(T₂(f(x))). By separation of S₂, f(T₁(x)) = T₂(f(x)). □

---

## 6. Minimal Realization

### Construction 6.1 (Minimal Realization)

Given a CSS S = (cl, T, β) over X, define the **minimal realization** S_min over X_min = range(ρ_S) ⊆ (ℕ → C → R):

- cl_min = id (identity closure)
- T_min(f) = σ(f) = (n ↦ c ↦ f(n+1, c))
- β_min(f, c) = f(0, c)

This is well-defined because range(ρ_S) is shift-closed (Theorem 4.1).

### Theorem 6.2

The minimal realization satisfies:

1. **Separation:** S_min is separated, with ρ_{S_min} = id on range(ρ_S).
2. **Same spectral boundary:** range(ρ_{S_min}) = range(ρ_S).
3. **Universality:** Any separated CSS with the same spectral boundary is isomorphic to S_min.

*Proof.*

(1) We show ρ_{S_min}(f) = f for all f ∈ range(ρ_S). By induction, T_min^n(f) = σ^n(f), where σ^n(f)(m, c) = f(m+n, c). Thus:
ρ_{S_min}(f)(n, c) = β_min(T_min^n(f), c) = σ^n(f)(0, c) = f(n, c).
So ρ_{S_min} = id, which is injective.

(2) range(ρ_{S_min}) = range(id) = range(ρ_S).

(3) By Theorem 5.1 applied to S' and S_min. □

### Theorem 6.3 (Finite Closure-Scattering Duality)

For any CSS S with Fintype X, there exists a spectral boundary semimodule M such that:
- M.profiles = range(ρ_S)
- S_min is separated
- range(ρ_{S_min}) = M.profiles
- The resonance congruence is the coarsest observation-and-transfer-compatible equivalence on X

---

## 7. Algorithms

### Algorithm 7.1: Minimal Realization from Response Data

```
Input: CSS S = (cl, T, β) with finite state space X, channel set C
Output: Minimal realization S_min

1. For each x ∈ X, compute ρ_S(x) to depth D (D ≥ |X| suffices)
2. Group states by response profile → resonance classes
3. Representatives: one state per class
4. S_min states = set of distinct profiles
5. S_min.T(profile) = shift(profile)
6. S_min.β(profile, c) = profile(0, c)
7. Return S_min
```

**Complexity:** O(|X| · D · |C|) time, O(|X| · D · |C|) space, where D is the observation depth.

### Algorithm 7.2: Isomorphism Detection

```
Input: Separated CSS's S₁, S₂ with same channel set C
Output: Isomorphism f : X₁ → X₂ or "not isomorphic"

1. Compute profile sets P₁, P₂
2. If P₁ ≠ P₂, return "not isomorphic"
3. For each x₁ ∈ X₁, find x₂ ∈ X₂ with ρ_{S₂}(x₂) = ρ_{S₁}(x₁)
4. Return the mapping x₁ ↦ x₂
```

**Complexity:** O((|X₁| + |X₂|) · D · |C|) time.

---

## 8. Applications

### 8.1 Automata Minimization

When the closure operator is the identity and the boundary observation encodes acceptance, the resonance congruence specializes to the Nerode equivalence. The minimal realization construction gives the unique minimal DFA. Our framework thus provides a certified generalization of classical automata minimization.

### 8.2 Tropical System Identification

Over the max-plus semiring (ℝ ∪ {-∞}, max, +), closure-scattering systems model discrete-event systems. The minimal realization identifies the essential timing modes of a manufacturing pipeline or network protocol. The closure defect detects scheduling anomalies where "processing then aggregating" differs from "aggregating then processing."

### 8.3 Network Flow Analysis

In network analysis, states are nodes, transfer is packet forwarding, and boundary observations are edge measurements. Resonance equivalence identifies nodes with identical forwarding behavior. The closure operator models reachability or influence propagation. The minimal realization compresses the network to its essential behavioral classes.

---

## 9. Machine Verification

All definitions and theorems in this paper are stated and proved in Lean 4 with the Mathlib library. The formalization comprises approximately 470 lines of code in the file `Bridges/AlgebraEMLPhysics/ModularScatteringDuality.lean`. Key verified results include:

| Theorem | Lean Name | Lines |
|---------|-----------|-------|
| Resonance is equivalence | `resonanceEquiv_is_equivalence` | 2 |
| Transfer preserves equivalence | `transfer_preserves_resonanceEquiv` | 5 |
| Coarsest congruence | `resonanceEquiv_coarsest` | 5 |
| Morphism preserves profiles | `morphism_preserves_responseProfile` | 8 |
| Main duality theorem | `separated_systems_isomorphic_of_same_profiles` | 25 |
| Minimal realization separated | `minimalRealization_separated` | 3 |
| Certified reconstruction | `minimal_resonance_realization_unique` | 6 |
| Finite duality | `finite_closure_scattering_duality` | 5 |

The proofs use only standard axioms (propext, Classical.choice, Quot.sound).

---

## 10. Discussion

### 10.1 Relationship to Existing Dualities

The closure-scattering duality fits into the broader landscape of algebraic dualities:

| Duality | Objects | Dual Objects | Key Map |
|---------|---------|--------------|---------|
| Stone | Boolean algebras | Stone spaces | Ultrafilters |
| Pontryagin | Compact abelian groups | Discrete groups | Characters |
| Gel'fand | Commutative C*-algebras | Compact Hausdorff spaces | Evaluation |
| **Closure-Scattering** | **Separated CSS's** | **Spectral boundary semimodules** | **Response profiles** |

### 10.2 The Resonance-Defect Interpretation

The closure defect δ(A) = T(cl(A)) \ cl(T(A)) provides a finite, algebraic analogue of physical resonance. In scattering theory, resonances correspond to poles of the S-matrix — states that persist near the boundary and interfere with outgoing waves. In our framework, resonant states are those generated by closure-then-transfer that cannot be reached by transfer-then-closure. This algebraic characterization makes resonance a computationally tractable concept.

### 10.3 Limitations

The current framework assumes a single deterministic transfer map. Extensions to nondeterministic or probabilistic transfer, and to infinite state spaces with topological structure, are natural next steps. The closure operator is also treated abstractly; connecting it to specific physical closure operations (e.g., thermodynamic equilibrium) requires domain-specific modeling.

---

## 11. Future Work

1. **Tropical Hankel reconstruction:** Develop explicit algorithms for computing the "tropical rank" of the response matrix and provide complexity bounds.

2. **Weighted automata interpretation:** Establish a formal correspondence between closure-scattering systems and weighted automata over idempotent semirings.

3. **Categorical S-matrix functoriality:** Extend the duality to a full categorical equivalence and study composition/gluing operations.

4. **Infinite systems:** Generalize to infinite state spaces with topological closure operators, connecting to functional-analytic scattering theory.

5. **Computational applications:** Implement efficient algorithms for minimal realization in network analysis and discrete-event simulation.

---

## References

1. Baccelli, F., Cohen, G., Olsder, G.J., Quadrat, J.-P. (1992). *Synchronization and Linearity*. Wiley.
2. Birkhoff, G. (1940). *Lattice Theory*. AMS Colloquium Publications.
3. Gaubert, S. (1992). Théorie des systèmes linéaires dans les dioïdes. Thèse, École des Mines de Paris.
4. Kalman, R.E. (1963). Mathematical description of linear dynamical systems. *SIAM J. Control*, 1(2), 152–192.
5. Myhill, J. (1957). Finite automata and the representation of events. WADD Tech. Report 57-624.
6. Nerode, A. (1958). Linear automaton transformations. *Proc. AMS*, 9(4), 541–544.
7. Ho, B.L., Kalman, R.E. (1966). Effective construction of linear state-variable models from input/output functions. *Regelungstechnik*, 14, 545–548.
