# Future Directions: Tropical Isogeny Rigidity and Post-Quantum Cryptography

## Overview

The tropical isogeny rigidity theorem establishes that compressed min-plus spectral data (coordinate valuation characters on a discrete Jacobian) uniquely determines a harmonic correspondence up to principal equivalence. This opens several concrete research directions at the intersection of tropical geometry, idempotent algebra, graph theory, and cryptography.

---

## Direction 1: Tropical Jacobian Hash Functions with Certified Collision Bounds

### Goal
Construct explicit hash functions `H : {0,1}^n → J(Γ)` mapping binary strings to tropical Jacobian elements, with collision resistance certified via the congruence kernel triviality theorem.

### Concrete Theorem Target
```
theorem tropical_hash_collision_bound (Γ : TropicalCurveData) (n : ℕ) :
  ∀ H : Fin (2^n) → Jacobian Γ,
    InjOnJacobian H →
    collision_probability H ≤ Γ.genus^2 / 2^n
```

### Strategy
- Use the min-plus matrix-vector product as the hash core: `H(x) = tropMV(A, x)` for a random tropical matrix `A`.
- Collision resistance reduces to showing that `tropMV(A, x) = tropMV(A, y)` implies `x = y` under appropriate conditions.
- The tropical matrix rigidity theorem (`tropMat_determined_by_action`) provides the key technical ingredient: distinct matrices produce distinct actions.
- Formalize the birthday-bound analysis in the tropical setting.

### Impact
This would provide the first hash function family with collision resistance certified by formal proof in a tropical algebraic framework, offering a novel approach to post-quantum hash design.

---

## Direction 2: Tropical Hecke Correspondences as Public-Key Actions

### Goal
Define tropical Hecke operators on metric graph Jacobians and use their composition structure as a public-key cryptographic primitive.

### Concrete Theorem Target
```
theorem hecke_composition_rigidity (Γ : TropicalCurveData) (p q : ℕ)
    (hp : Nat.Prime p) (hq : Nat.Prime q) :
    HeckeCorrespondence Γ p ∘ HeckeCorrespondence Γ q =
    HeckeCorrespondence Γ q ∘ HeckeCorrespondence Γ p
```

### Strategy
- Define the tropical Hecke correspondence `T_p` on a metric graph as the harmonic correspondence induced by the graph's `p`-fold edge subdivision.
- Show that Hecke operators commute in the tropical setting (analogous to classical Hecke algebra commutativity).
- Use the rigidity theorem to show that the composition `T_p ∘ T_q` is uniquely determined by its spectral data, enabling a Diffie-Hellman-like key exchange: Alice publishes `T_p(J)`, Bob publishes `T_q(J)`, shared secret is `T_p ∘ T_q(J)`.

### Impact
This would create a new class of post-quantum key exchange protocols based on tropical Hecke operators rather than classical isogenies, potentially resistant to quantum attacks on elliptic curve isogeny problems.

---

## Direction 3: Tropical Prym Varieties and Hidden-Subsemimodule Trapdoors

### Goal
Formalize tropical Prym varieties (kernels of norm maps on double covers of metric graphs) and use their hidden subsemimodule structure as cryptographic trapdoors.

### Concrete Theorem Target
```
theorem prym_subsemimodule_recovery (Γ₁ Γ₂ : TropicalCurveData)
    (π : CoveringMap Γ₁ Γ₂) (hdouble : IsDegreeTwo π) :
    ∃! P : Subsemimodule (Jacobian Γ₁),
      P = kernel (normMap π) ∧
      Fintype.card P = Γ₁.genus - Γ₂.genus
```

### Strategy
- Define the norm map `Nm : J(Γ₁) → J(Γ₂)` for a double cover `π : Γ₁ → Γ₂`.
- The Prym variety `P = ker(Nm)` is a subsemimodule of `J(Γ₁)`.
- The trapdoor is the covering map `π`; the public key is the Prym variety `P` viewed as a quotient.
- Recovery of `π` from `P` uses the rigidity theorem applied to the restricted action on `P`.

### Impact
Tropical Prym varieties are a natural analogue of abelian subvarieties used in classical isogeny cryptography. This direction would extend the rigidity theorem to a richer class of tropical geometric objects.

---

## Direction 4: Certified Security Reductions from Congruence-Kernel Hardness

### Goal
Formalize a security reduction showing that breaking the tropical isogeny cryptosystem is at least as hard as computing the congruence kernel of a random tropical matrix.

### Concrete Theorem Target
```
theorem security_reduction (Γ : TropicalCurveData) (n : ℕ) :
    ∀ A : Oracle (TropicalIsogenyProblem Γ),
      SuccessProbability A ≥ ε →
      ∃ B : Oracle (CongruenceKernelProblem Γ),
        SuccessProbability B ≥ ε / poly(Γ.genus)
```

### Strategy
- Define the **Tropical Isogeny Problem (TIP)**: given `tropMV(A, ·)` as a black box, recover the matrix `A`.
- Define the **Congruence Kernel Problem (CKP)**: given two tropical matrix-vector oracles, determine if they have the same matrix.
- Show TIP reduces to CKP via the rigidity theorem: if you can solve CKP, you can solve TIP by testing candidates.
- Formalize the reduction in a game-based security framework.
- Analyze the complexity: the test-vector approach requires `g²` queries, matching the lower bound from `reconstruction_dimension`.

### Impact
This would provide the first formally certified security reduction for a tropical cryptographic primitive, establishing a concrete hardness foundation for post-quantum tropical cryptography.

---

## Direction 5: Functorial Tropical Langlands Reconstruction Beyond Graphs

### Goal
Extend the rigidity theorem from metric graphs to higher-dimensional tropical varieties, establishing a functorial correspondence between tropical automorphic forms and spectral data.

### Concrete Theorem Target
```
theorem tropical_langlands_reconstruction (X : TropicalVariety) (d : ℕ)
    (hd : d ≤ dim X) :
    ∀ Φ Ψ : TropicalCorrespondence X,
      SameSpectralData (TropicalCohomology X d) Φ Ψ →
      PrincipalEquiv Φ Ψ
```

### Strategy
- Generalize the discrete Jacobian `ℤ^g` to tropical cohomology groups `H^d(X, ℤ)` of tropical varieties.
- Define tropical correspondences on higher-dimensional varieties as piecewise-linear maps.
- The separation framework already works for any type with a separating family of characters; the key is constructing such families for tropical cohomology.
- Use the theory of tropical intersection products to define the period pairing and nondegeneracy condition.

### Impact
This would establish the tropical analogue of the Langlands correspondence: spectral data (tropical automorphic forms) determines geometric data (correspondences) up to equivalence. The formal verification framework ensures that each step of the generalization is mathematically rigorous.

---

## Cross-Cutting Technical Infrastructure

### Needed Mathlib Contributions
1. **Tropical semiring formalization**: Extend Mathlib's `Tropical` type with min-plus matrix operations and spectral theory.
2. **Metric graph library**: Formalize metric graphs, harmonic morphisms, and chip-firing in Lean 4.
3. **Idempotent semimodule theory**: Develop the theory of semimodules over idempotent semirings, including free semimodules and quotients.
4. **Game-based cryptographic security**: Formalize oracle-based security reductions for tropical primitives.

### Computational Experiments
- Implement tropical matrix-vector products and test-vector reconstruction for random matrices up to dimension 100.
- Benchmark collision search complexity as a function of genus.
- Compare tropical key exchange performance against classical isogeny-based systems (SIKE, CSIDH).

---

## Timeline and Priority

| Direction | Priority | Estimated Effort | Dependencies |
|-----------|----------|-----------------|--------------|
| 1. Hash Functions | High | 2-4 weeks | Current work |
| 2. Hecke Operators | High | 4-8 weeks | Metric graph library |
| 3. Prym Varieties | Medium | 6-12 weeks | Covering space theory |
| 4. Security Reductions | High | 4-8 weeks | Game-based framework |
| 5. Tropical Langlands | Exploratory | 12+ weeks | Tropical cohomology |
