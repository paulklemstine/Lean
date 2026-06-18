# Future Directions: Tropical Choquet–Radon Trapdoor Duality

## Overview

The formalization of the tropical Choquet–Radon trapdoor duality opens several concrete research programs at the intersection of tropical geometry, cryptography, and certified computation. Below are five breakthrough-level next steps, each with specific theorem targets, proof strategies, and cross-domain connections.

---

## 1. Infinite/Compact Choquet Versions with Topological Hypotheses

### Goal
Extend the finite tropical Choquet system to compact Hausdorff spaces, replacing finite `Finset E` supports with closed subsets of a compact extremal boundary, and prove the analogous duality with topological separation axioms.

### Target Theorem
```
theorem compact_tropical_choquet_radon_duality
  {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]
  (Λ : UCTropicalFunctional X)
  (μ : CompactCapacity X)
  (hrep : TropicalRepresents Λ μ) :
  ∃! S : Set X, IsClosed S ∧
    IsMinimalSupport Λ S ∧
    ∀ T : Set X, IsClosed T → IsSupport Λ T → S ⊆ T
```

### Proof Strategy
- Build on `CompactTropicalChoquetRadon.lean` which already formalizes `UCTropicalFunctional` and `compactCapacity`.
- Use the Choquet–Bishop–de Leeuw theorem pattern: the minimal support is the intersection of all closed supports.
- Key challenge: showing that the intersection of closed supports is itself a support requires the upper-continuity axiom (`top_continuous'`).
- The Radon inversion theorem would use the Riesz representation theorem for maxitive measures.

### Cross-Domain Connection
Connects to **idempotent functional analysis** (Litvinov–Maslov) and **tropical integral geometry**. The compact version would enable applications to tropical moment problems and max-plus spectral theory.

---

## 2. Tropical Compressed Sensing: RIP-like Conditions for Exposed-Support Recoverability

### Goal
Formalize a tropical analogue of the Restricted Isometry Property (RIP) that characterizes when the Radon profile map enables exact support recovery, with quantitative bounds on the maximum recoverable support size.

### Target Theorem
```
theorem tropical_RIP_implies_recovery
  (TC : TropicalChoquetSystem S E M)
  (RP : TropicalRadonSystem E M P)
  (k : ℕ)
  (hRIP : TropicalRIP TC RP k δ)
  (x : M) (hx : (TC.suppC x).card ≤ k) :
  recoverSupport TC RP (RP.profile x) = TC.suppC x

def TropicalRIP (TC RP k δ) : Prop :=
  ∀ K L : Finset E, K.card ≤ k → L.card ≤ k → K ≠ L →
    ∃ x y : M, TC.suppC x = K ∧ TC.suppC y = L ∧
      tropicalDist (RP.profile x) (RP.profile y) ≥ δ
```

### Proof Strategy
- Define a tropical metric on the profile space P.
- Formulate RIP as: k-sparse supports are well-separated in profile space.
- Prove that RIP implies exact recovery by showing the recovery algorithm's elimination tests are correct for sparse inputs.
- Derive quantitative bounds: maximum k as a function of |E| and the profile dimension.

### Cross-Domain Connection
Bridges **compressed sensing** (Candès–Tao) to **tropical geometry**. The RIP condition becomes a geometric property of the tropical convex hull, connecting to matroid theory and tropical Grassmannians.

---

## 3. Cryptographic Protocol Semantics for Support-Hiding Keys

### Goal
Formalize a complete public-key cryptographic protocol based on the trapdoor duality, with security reductions to the hardness of tropical support recovery under non-exposedness.

### Target Theorems
```
-- Key generation: produces a system with certified exposed basis (private) and profile map (public)
theorem keygen_correct :
  ∃ (TC : TropicalChoquetSystem S E M)
    (RP : TropicalRadonSystem E M P)
    (tests : E → P → Bool),
    HasCertifiedExposedBasis TC RP tests ∧
    ¬ TriviallyInvertible RP

-- Encryption: hiding a support behind a profile
theorem encryption_hides_support :
  ∀ K : Finset E, ∃ x : M,
    TC.suppC x = K ∧
    ∀ (adversary : P → Finset E),
      ¬ HasCertifiedExposedBasis TC RP (adversaryToTests adversary) →
      ∃ K' ≠ K, adversary (RP.profile x) = K'

-- Decryption: recovering support with private key
theorem decryption_correct :
  HasCertifiedExposedBasis TC RP tests →
  ∀ x, RP.ExposedSeparated x →
    recoverSupport tests (RP.profile x) = TC.suppC x
```

### Proof Strategy
- Model the adversary as a function `P → Finset E` without access to the test battery.
- Security reduction: show that any efficient adversary implies a solution to the tropical support recovery problem, which is hard under non-exposedness (by Theorem 4).
- Use the collision theorem to show that without the trapdoor, the adversary faces an information-theoretic barrier.

### Cross-Domain Connection
Creates a new cryptographic primitive class: **geometric trapdoor functions** based on tropical convex structure rather than number-theoretic hardness. Potentially relevant to **post-quantum cryptography** since the underlying hardness is combinatorial/geometric rather than algebraic.

---

## 4. Matroidal Characterization of Exposed-Support Recoverability

### Goal
Characterize the class of tropical Choquet systems where every support is exposed (global exposedness holds) in terms of matroid-theoretic properties, specifically anti-exchange and basis exchange axioms.

### Target Theorem
```
theorem global_exposedness_iff_antimatroid
  (TC : TropicalChoquetSystem S E M)
  (RP : TropicalRadonSystem E M P) :
  GlobalExposedness TC RP ↔
    (AntiExchangeProperty TC ∧ SufficientRadonTests RP TC)

def AntiExchangeProperty (TC : TropicalChoquetSystem S E M) : Prop :=
  ∀ x : M, ∀ e₁ e₂ : E,
    e₁ ∈ TC.suppC x → e₂ ∈ TC.suppC x → e₁ ≠ e₂ →
    ∃ y : M, e₁ ∈ TC.suppC y ∧ e₂ ∉ TC.suppC y ∧
      TC.suppC y ⊆ TC.suppC x
```

### Proof Strategy
- Forward direction: GlobalExposedness + profile separation implies that each pair of extremals can be independently detected, which is the anti-exchange property.
- Backward direction: AntiExchangeProperty ensures that the support lattice has the structure of an antimatroid (a greedoid satisfying anti-exchange). Combined with sufficient Radon tests, this gives separation.
- Use the theory of convex geometries / antimatroids (Edelman–Jamison) to characterize the exposed class.

### Cross-Domain Connection
Connects **tropical convexity** to **combinatorial optimization** (matroid theory, greedoids) and **lattice theory**. The anti-exchange property appears in the theory of convex geometries and learning theory (concept classes).

---

## 5. Lower Bounds on Collision Multiplicity under Congruence Collapse

### Goal
Quantify how many distinct supports can collide (have identical Radon profiles) when exposedness fails, establishing lower bounds on collision multiplicity as a function of the "degree of non-exposedness."

### Target Theorem
```
theorem collision_multiplicity_lower_bound
  (TC : TropicalChoquetSystem S E M)
  (RP : TropicalRadonSystem E M P)
  (k : ℕ)
  (hfail : NonExposednessDegree TC RP ≥ k) :
  ∃ (xs : Fin k → M),
    (∀ i j, i ≠ j → TC.suppC (xs i) ≠ TC.suppC (xs j)) ∧
    (∀ i j, RP.profile (xs i) = RP.profile (xs j))

def NonExposednessDegree (TC RP) : ℕ :=
  Fintype.card E - rank (separationMatrix TC RP)
```

### Proof Strategy
- Define the separation matrix: rows indexed by generators, columns by Radon tests, entries indicating whether the test detects the generator.
- The rank deficiency of this matrix measures the degree of non-exposedness.
- Use linear algebra over GF(2) or ℤ to show that rank deficiency k implies at least 2^k collision classes.
- Each collision class contains supports that are indistinguishable by all Radon tests.

### Cross-Domain Connection
Connects to **coding theory** (the separation matrix is analogous to a parity check matrix), **information theory** (the collision multiplicity determines the entropy of the hidden support given the profile), and **computational complexity** (the rank deficiency determines the hardness of support recovery).

---

## Synthesis: The Tropical Convex Cryptography Program

These five directions together define a coherent research program:

1. **Foundation** (Direction 1): Compact topological theory providing the analytic backbone.
2. **Algorithms** (Direction 2): Quantitative recovery conditions connecting to compressed sensing.
3. **Applications** (Direction 3): Concrete cryptographic protocols with security proofs.
4. **Structure theory** (Direction 4): Matroidal characterization of when the trapdoor works.
5. **Hardness** (Direction 5): Quantitative collision bounds establishing genuine computational difficulty.

The overarching vision: tropical convex geometry provides a new mathematical framework for public-key cryptography, where the trapdoor is geometric (exposed extremal structure) rather than number-theoretic (factoring, discrete logarithm). This may yield post-quantum secure primitives with fundamentally different security assumptions.
