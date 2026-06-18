# Future Directions: Tropical Algebraic Cryptographic Hardness

## Overview

This document outlines concrete next steps opened by the formalization of the
**tropical minor–congruence collision bridge** in `Bridges/AlgebraSpeculativeCryptography/TropicalOneWayMinors.lean`. The bridge theorem establishes that profile separation (via principal tropical minors, kernel data, and semiring congruence classes) implies collision-freeness for finitely generated tropical semigroup actions, with constructive witness extraction when collisions do occur.

---

## Direction 1: Categorical Valuation-Functor Formulation

### Goal
Reformulate the collision bridge as a natural transformation between functors:
- A **word functor** from the free monoid category to the matrix semigroup category.
- A **profile functor** from the matrix semigroup to a category of valuation-congruence certificates.

### Concrete Theorem Target
```lean
theorem profile_functor_faithful_implies_collision_free
    {Gen S : Type*} [CommSemiring S] {n : ℕ}
    (M : Gen → Matrix (Fin n) (Fin n) S)
    (v₀ : Fin n → S) (R : ℕ)
    (F : List Gen → ValCongProfile n S)
    (h_functorial : ∀ w₁ w₂, F (w₁ ++ w₂) = compositeProfile (F w₁) (F w₂))
    (h_faithful : ∀ w₁ w₂, w₁.length ≤ R → w₂.length ≤ R → F w₁ = F w₂ → w₁ = w₂) :
    collisionFreeOnBall M v₀ R
```

### Strategy
1. Define `compositeProfile` capturing how profiles compose under matrix multiplication.
2. Prove that functoriality of the profile map preserves the monoidal structure.
3. Show that faithfulness of the profile functor (injectivity on morphisms) directly yields collision-freeness.

### Impact
This connects tropical cryptography to **categorical semantics**, opening doors to abstract nonsense tools (Yoneda, adjunctions, Kan extensions) for analyzing collision resistance.

---

## Direction 2: Automata-Theoretic Reinterpretation via Tropical Nerode Classes

### Goal
Interpret the collision bridge through the lens of tropical automata theory, connecting to the existing `TropicalNerodeRel` infrastructure.

### Concrete Theorem Target
```lean
theorem nerode_separation_implies_collision_free
    {α σ W : Type*} [Semiring W] [Fintype σ]
    (A : TropicalOneWayAutomaton α σ W)
    (p q : σ) (R : ℕ)
    (h_sep : ∀ w, w.length ≤ R → rightCost A w p ≠ rightCost A w q) :
    ∀ w₁ w₂, w₁.length ≤ R → w₂.length ≤ R →
      rightCost A w₁ p = rightCost A w₁ q → rightCost A w₂ p = rightCost A w₂ q →
      w₁ = w₂ → True
```

### Strategy
1. View words as actions in a tropical transition system.
2. Map the `TropicalNerodeRel` equivalence classes to profile classes.
3. Show that Nerode-inequivalent states yield profile-separated words.
4. Transfer `tropical_separation_witness_sound` to the collision bridge.

### Impact
Creates a new bridge from **tropical automata complexity** to cryptography, potentially yielding state-complexity lower bounds for collision-finding algorithms.

---

## Direction 3: Concrete Tropical Hash Family with Certified Collision Resistance

### Goal
Construct a specific tropical hash function family and prove collision resistance using the bridge theorem.

### Concrete Theorem Target
```lean
def tropicalHash (p : ℕ) (n : ℕ) (M : Fin p → Matrix (Fin n) (Fin n) (ZMod q))
    (v₀ : Fin n → ZMod q) : List (Fin p) → Fin n → ZMod q :=
  tropicalAct M v₀

theorem tropicalHash_collision_resistant
    (hp : Nat.Prime p) (n : ℕ) (M : Fin p → Matrix (Fin n) (Fin n) (ZMod q))
    (v₀ : Fin n → ZMod q) (R : ℕ)
    (h_gen_distinct : ∀ i j : Fin p, i ≠ j → M i *ᵥ v₀ ≠ M j *ᵥ v₀)
    (h_separation : SeparationCertificate M v₀ R) :
    collisionFreeOnBall M v₀ R
```

### Strategy
1. Choose generators from `GL(n, ZMod q)` with good spectral properties.
2. Define a concrete `SeparationCertificate` type carrying diagonal distinctness proofs.
3. Prove that spectral separation of generators implies profile separation.
4. Apply the bridge theorem.

### Impact
Produces the first **formally verified tropical collision-resistant hash family**, a concrete cryptographic primitive with machine-checked security guarantees.

---

## Direction 4: Extension to Asymptotic Growth and Security Parameters

### Goal
Move from bounded balls (radius R) to asymptotic security statements parameterized by a security parameter λ.

### Concrete Theorem Target
```lean
theorem asymptotic_collision_resistance
    (family : ℕ → Σ (Gen : Type) (S : Type) (n : ℕ),
      (Gen → Matrix (Fin n) (Fin n) S) × (Fin n → S))
    (R : ℕ → ℕ)
    (h_grows : ∀ λ, R λ ≥ λ)
    (h_sep : ∀ λ, ProfileSeparated (family λ) (R λ)) :
    ∀ λ, collisionFreeOnBall (family λ).snd.snd.snd.fst
                              (family λ).snd.snd.snd.snd (R λ)
```

### Strategy
1. Define parameterized families of tropical matrix generators.
2. Formalize the growth rate of the separation radius as a function of security parameter.
3. Prove that polynomial-time collision search is bounded by the ball radius.
4. Connect to computational complexity assumptions.

### Impact
Bridges from **finite combinatorial** statements to **asymptotic complexity theory**, the standard setting for cryptographic security.

---

## Direction 5: Tropical Second-Preimage Resistance via Congruence Rigidity

### Goal
Define and prove **second-preimage resistance**: given a word w and its output, it is hard to find w' ≠ w with the same output.

### Concrete Theorem Target
```lean
theorem second_preimage_resistance
    {Gen S : Type*} [Semiring S] {n : ℕ}
    (M : Gen → Matrix (Fin n) (Fin n) S)
    (v₀ : Fin n → S) (R : ℕ)
    (profile : List Gen → ValCongProfile n S)
    (Witness : ℕ → List Gen → List Gen → Prop)
    (hcollision : ∀ ⦃w₁ w₂⦄, w₁.length ≤ R → w₂.length ≤ R →
      tropicalAct M v₀ w₁ = tropicalAct M v₀ w₂ → ∃ k ≤ R, Witness k w₁ w₂)
    (hseparated : ∀ ⦃w₁ w₂⦄, w₁.length ≤ R → w₂.length ≤ R →
      profile w₁ = profile w₂ → ¬∃ k ≤ R, Witness k w₁ w₂)
    {w : List Gen} (hw : w.length ≤ R) :
    ∀ ⦃w'⦄, w'.length ≤ R → profile w = profile w' →
      tropicalAct M v₀ w ≠ tropicalAct M v₀ w'
```

### Strategy
1. This is a direct specialization of the main bridge theorem.
2. The key new ingredient is showing that **congruence rigidity** (the semiring congruence class component of the profile) prevents second preimages even when minors agree.
3. Formalize tropical matrix rigidity theorems connecting minor agreement to matrix equality.

### Impact
Completes the analogy with classical hash function security: collision resistance, second-preimage resistance, and preimage resistance form the standard security hierarchy.

---

## Cross-Cutting Themes

### Tropical Proof-Carrying Security
All directions converge on the vision of **proof-carrying security certificates**: a tropical hash function comes equipped with a formally verified proof of its collision resistance, checkable by any proof assistant.

### Idempotent Algebra as a Complexity Barrier
The idempotent property (min(a,a) = a) fundamentally distinguishes tropical algebra from classical algebra and may serve as an intrinsic source of computational hardness, analogous to how lattice structure underlies post-quantum cryptographic assumptions.

### Connections to Existing Formalized Infrastructure
- `TropicalNerode.lean`: Nerode equivalence for tropical automata
- `TropicalOWF/`: One-way function foundations
- `TropicalValuationFunctor.lean`: Valuation functoriality
- `AutoResearch/Basic.lean`: Semiring congruence theory
