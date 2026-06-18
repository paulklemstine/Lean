# Ultrametric Proof-Learning Representation Duality via Prime-Congruence Observer Semimodules and Certified Hierarchical Predictor Reconstruction

## Abstract

We establish a finite duality principle for proof dynamics: a proof-learning system with ultrametric contraction, idempotent compression, and observer separation admits a complete finite representation by its observer evaluation semimodule, and this semimodule algorithmically reconstructs a canonical sparse predictor tree with a machine-verified correctness certificate. Concretely, we prove three main theorems:

1. **Finite Observer Representation Duality (Theorem A/A'):** The observer evaluation map induces a constructive equivalence between compressed proof states and realizable observer profiles.
2. **Canonical Ultrametric Tree Reconstruction (Theorem B/B'):** The ultrametric cluster structure on compressed states yields a canonical rooted tree model, unique up to cluster equivalence.
3. **Certified Hierarchical Predictor Reconstruction (Theorem C/C'):** A computable predictor can be extracted from observer data, with a formal proof that it correctly recovers compressed proof-state profiles.

All results are fully machine-verified in Lean 4 with Mathlib, with zero `sorry` statements. The proofs depend only on standard axioms (propext, Classical.choice, Quot.sound). We formalize 12 novel definitions, 20+ theorems, and complete bridge lemmas connecting to prior work on ultrametric contraction dynamics and prime-congruence neural compression.

**Keywords:** ultrametric learning, proof-state compression, observer semimodules, idempotent algebra, tropical representation theory, hierarchical predictor reconstruction, dendrogram certification, certified latent structure extraction

---

## 1. Introduction

### 1.1 Motivation

Modern automated theorem proving systems navigate enormous proof-state spaces without rigorous geometric guidance. Proof search heuristics are typically engineered ad hoc — beam search, priority queues, learned value functions — without formal guarantees that the search representation faithfully captures proof structure.

Simultaneously, hierarchical clustering and sparse representation learning have emerged as central tools in machine learning, but typically lack correctness certificates: a learned dendrogram may or may not reflect true data structure.

This work addresses both problems by establishing a mathematically rigorous duality between:
1. **Dynamical proof systems** with ultrametric geometry and idempotent compression, and
2. **Finite semimodule representations** carrying observer evaluation data.

The duality is not merely existential — it is constructive, computable, and certified.

### 1.2 Relationship to Prior Work

Our work builds on three foundations:

**Ultrametric contraction dynamics** (catalog: `UltrametricProofLearning.lean`): Prior work established that contractive maps on ultrametric spaces enjoy exponential convergence, diagonal stability, and compression threshold existence. We extend this by showing that the compressed limit states admit a finite algebraic representation.

**Prime-congruence neural compression** (catalog: `PrimeCongruenceNeuralCompression.lean`): Prior work developed the theory of finite observer families (ring congruences) with diagonal avoidance properties, proving encoding respects congruence, cardinality bounds, and collision exclusion. We bridge to this framework via our observer separation → diagonal avoidance lemma.

**Certified Gibbs reconstruction** (catalog: `ClosureKramersWannierDuality.lean`): The theorem `certified_gibbs_reconstruction_from_boundary_partition` establishes that boundary partition data can certifiably reconstruct dual Gibbs weights. We follow the same architectural pattern — finite partition object, reconstruction map, correctness proof, certification theorem — with observer profiles as boundary data and compressed states as the reconstructed object.

### 1.3 Contributions

1. **Definitions** (§2): 12 novel Lean definitions including `evalProfile`, `ObserverSeparatesCompressed`, `compressedProfileEquiv`, `RootedTreeModel`, `CertifiedPredictor`, and `thresholdSublevel`.

2. **Theorem A/A'** (§3): Finite observer representation duality — the evaluation map is a constructive equivalence `Set.range C ≃ Set.range (evalProfile C obs)`.

3. **Theorem B/B'** (§4): Canonical ultrametric tree reconstruction and uniqueness up to cluster equivalence.

4. **Theorem C/C'** (§5): Certified hierarchical predictor reconstruction from observer profiles and finite traces.

5. **Tropical semimodule structure** (§6): Pointwise sup/inf on profiles with algebraic laws (commutativity, associativity, idempotence).

6. **Spectral filtration** (§7): Observer threshold sublevel sets form a monotone, compression-stable filtration.

7. **Bridge lemmas** (§8): Connecting observer separation to diagonal avoidance and the certified Gibbs reconstruction architecture.

---

## 2. Definitions and Notation

### 2.1 Basic Setup

Let `S` be a finite type (the proof-state space), `ι` a finite type (the observer index set), and `σ` a type with decidable equality (the observer score type).

**Definition 2.1 (Idempotent Compression).** A self-map `C : S → S` is *idempotent* if `C(C(x)) = C(x)` for all `x ∈ S`. The set of *compressed states* is `range(C) = {C(x) | x ∈ S}`. Elements of `range(C)` are exactly the fixed points of `C`.

**Definition 2.2 (Observer Evaluation Map).** Given `C : S → S` and `obs : ι → S → σ`, the *observer evaluation map* is:
```
evalProfile(C, obs)(x)(i) := obs(i)(C(x))
```
This compresses first, then observes. The range of `evalProfile` is the set of *realizable profiles*.

**Definition 2.3 (Observer Separation).** The observer family `obs` *separates compressed states* if for all `x, y ∈ S` with `C(x) = x` and `C(y) = y`:
```
(∀ i, obs(i)(x) = obs(i)(y)) → x = y
```

**Definition 2.4 (Compressed Ultrametric).** A function `d : S × S → ℝ` is a *compressed ultrametric* if it is nonneg, symmetric, separates compressed states (d(x,y) = 0 iff x = y for fixed points), and satisfies the strong triangle inequality `d(x,z) ≤ max(d(x,y), d(y,z))`.

**Definition 2.5 (Ultrametric Proof System).** A *finite ultrametric proof system* is a tuple `(S, d, C, obs)` where:
- `S` is finite with decidable equality
- `d` is a compressed ultrametric
- `C` is idempotent
- `d(C(x), C(y)) ≤ d(x,y)` (compression is nonexpansive)
- `obs` separates compressed states

### 2.2 Tropical Semimodule Structure

**Definition 2.6 (Profile Operations).**
- *Pointwise sup:* `(f ⊔ g)(i) := max(f(i), g(i))`
- *Pointwise order:* `f ≤ g ⟺ ∀ i, f(i) ≤ g(i)`

When `σ` is linearly ordered, these operations make `ι → σ` an idempotent semimodule (tropical module).

### 2.3 Cluster and Tree Structures

**Definition 2.7 (Ultrametric Ball Relation).** For radius `r ≥ 0`:
```
x ~_r y ⟺ d(x,y) ≤ r
```
By ultrametricity, `~_r` is an equivalence relation for every `r ≥ 0`.

**Definition 2.8 (Rooted Tree Model).** A *rooted tree model* for a proof system consists of:
- A set of leaves (= `range(C)`)
- A cluster relation `sameCluster(x, y, r)` for each radius `r`
- A root radius

**Definition 2.9 (Certified Predictor).** A *certified predictor* is a tuple `(predict, C, obs)` where `predict : (ι → σ) → S` satisfies:
```
∀ x, evalProfile(C, obs)(predict(evalProfile(C, obs)(x))) = evalProfile(C, obs)(x)
```

---

## 3. Theorem A/A': Finite Observer Representation Duality

### 3.1 Injectivity on Compressed States (Theorem A)

**Theorem 3.1.** If `obs` separates compressed states, then `evalProfile(C, obs)` is injective on fixed points of `C`.

*Proof sketch.* Let `x, y` be fixed points with `evalProfile(C, obs)(x) = evalProfile(C, obs)(y)`. Then for all `i`, `obs(i)(C(x)) = obs(i)(C(y))`, i.e., `obs(i)(x) = obs(i)(y)` since `C(x) = x, C(y) = y`. By observer separation, `x = y`. □

### 3.2 Factorization Through Compression

**Theorem 3.2.** For idempotent `C`: `evalProfile(C, obs)(x) = evalProfile(C, obs)(C(x))` for all `x`.

*Proof.* For each observer `i`: `obs(i)(C(x)) = obs(i)(C(C(x)))` by idempotence `C(C(x)) = C(x)`. □

### 3.3 The Duality Equivalence (Theorem A')

**Theorem 3.3.** The restricted evaluation map
```
evalProfileOnRange : range(C) → range(evalProfile(C, obs))
```
is a bijection.

*Proof.*
- **Injectivity:** Let `C(a), C(b) ∈ range(C)` with equal profiles. By idempotence, `C(a)` and `C(b)` are fixed points. Unfolding the profile equality and using idempotence twice, we get `obs(i)(C(a)) = obs(i)(C(b))` for all `i`. By separation, `C(a) = C(b)`.
- **Surjectivity:** Any `f ∈ range(evalProfile(C, obs))` equals `evalProfile(C, obs)(x)` for some `x`. Then `C(x) ∈ range(C)` and `evalProfile(C, obs)(C(x)) = evalProfile(C, obs)(x) = f` by the factorization theorem. □

**Corollary 3.4.** `|range(C)| = |range(evalProfile(C, obs))|`.

This is the finite representation duality: the algebraic object (observer profiles) completely classifies the geometric object (compressed proof states).

---

## 4. Theorem B/B': Canonical Ultrametric Tree Reconstruction

### 4.1 Cluster Equivalence Relations

**Theorem 4.1.** For an ultrametric `d` and any `r ≥ 0`, the ball relation `x ~_r y ⟺ d(x,y) ≤ r` is an equivalence relation.

*Proof.*
- *Reflexive:* `d(x,x) = 0 ≤ r`.
- *Symmetric:* `d(x,y) = d(y,x)`.
- *Transitive:* `d(x,z) ≤ max(d(x,y), d(y,z)) ≤ max(r, r) = r`. □

**Theorem 4.2 (Cluster Monotonicity).** If `r ≤ s` and `x ~_r y`, then `x ~_s y`.

### 4.2 The Canonical Tree (Theorem B)

**Theorem 4.3.** Every finite ultrametric proof system admits a canonical rooted tree model whose cluster relation exactly recovers the compressed ultrametric: `sameCluster(x, y, r) ⟺ d(C(x), C(y)) ≤ r`.

*Construction.* Define `canonicalTreeModel(C, d)` with leaves = `range(C)` and `sameCluster(x, y, r) := d(C(x), C(y)) ≤ r`. The equivalence with the ultrametric is tautological by construction. □

### 4.3 Uniqueness (Theorem B')

**Theorem 4.4.** Any two tree models `T₁, T₂` that faithfully represent the compressed ultrametric have equivalent cluster structures: `T₁.sameCluster(x,y,r) ⟺ T₂.sameCluster(x,y,r)` for all `x, y, r`.

*Proof.* If both `T₁` and `T₂` satisfy `sameCluster(x,y,r) ⟺ d(C(x),C(y)) ≤ r`, then they agree by transitivity of biconditionals. □

---

## 5. Theorem C/C': Certified Predictor Reconstruction

### 5.1 Certified Predictor (Theorem C)

**Theorem 5.1.** For a finite ultrametric proof system with nonempty state space, there exists a certified predictor `(predict, C, obs)` such that `predict` correctly recovers compressed profiles:
```
∀ x, evalProfile(C, obs)(predict(evalProfile(C, obs)(x))) = evalProfile(C, obs)(x)
```

*Proof.* Define:
```
predict(f) := if ∃ s, evalProfile(C, obs)(s) = f then C(choose(s)) else arbitrary
```
For any `x`, the profile `evalProfile(C, obs)(x)` is realizable (witnessed by `x`), so `predict` returns `C(s)` for some `s` with `evalProfile(C, obs)(s) = evalProfile(C, obs)(x)`. By factorization, `evalProfile(C, obs)(C(s)) = evalProfile(C, obs)(s) = evalProfile(C, obs)(x)`. □

### 5.2 Trace-Based Reconstruction (Theorem C')

**Theorem 5.2.** For any trace `t₁, ..., tₙ` of proof states, if `evalProfile(C, obs)(tᵢ) = evalProfile(C, obs)(tⱼ)`, then `C(tᵢ) = C(tⱼ)`.

*Proof.* The profile equality gives `obs(k)(C(tᵢ)) = obs(k)(C(tⱼ))` for all `k`. Since `C(tᵢ)` and `C(tⱼ)` are fixed points (by idempotence), observer separation yields `C(tᵢ) = C(tⱼ)`. □

---

## 6. Tropical Semimodule Structure

### 6.1 Algebraic Laws

**Theorem 6.1.** For linearly ordered `σ`, the pointwise sup operation on `ι → σ` is:
- Commutative: `f ⊔ g = g ⊔ f`
- Associative: `(f ⊔ g) ⊔ h = f ⊔ (g ⊔ h)`
- Idempotent: `f ⊔ f = f`

These three properties make `(ι → σ, ⊔)` a *band* (idempotent semigroup), which is the algebraic structure underlying tropical semirings.

### 6.2 Profile Order

**Theorem 6.2.** The pointwise order `f ≤ g ⟺ ∀ i, f(i) ≤ g(i)` is a partial order (reflexive, transitive, antisymmetric).

---

## 7. Spectral Filtration

### 7.1 Threshold Sublevel Sets

**Definition 7.1.** The *threshold sublevel set* at threshold `t : ι → σ` is:
```
F_t := {x ∈ S | ∀ i, obs(i)(C(x)) ≤ t(i)}
```

**Theorem 7.1 (Monotonicity).** If `t ≤ t'` (pointwise), then `F_t ⊆ F_{t'}`.

**Theorem 7.2 (Compression Stability).** If `x ∈ F_t`, then `C(x) ∈ F_t`.

These results show that the spectral filtration is compatible with compression, providing a multi-resolution view of the proof system.

---

## 8. Bridge Lemmas and Cross-Domain Connections

### 8.1 Observer Separation → Diagonal Avoidance

**Theorem 8.1.** Observer separation implies that for distinct compressed states `C(x) ≠ C(y)`, there exists a distinguishing observer: `∃ i, obs(i)(C(x)) ≠ obs(i)(C(y))`.

This directly bridges to the `DiagonalAvoidsOn` framework of prime-congruence neural compression: the observer family diagonally avoids the identity on compressed states.

### 8.2 Duality → Certified Reconstruction

**Theorem 8.2.** The duality equivalence `compressedProfileEquiv` provides a certified reconstruction inverse:
```
∃ reconstruct : range(evalProfile) → range(C),
  ∀ x ∈ range(C), reconstruct(equiv(x)) = x
```

This mirrors the architecture of `certified_gibbs_reconstruction_from_boundary_partition`:
- **Boundary data** = observer profiles
- **Partition** = ultrametric cluster partition
- **Reconstruction** = equivalence inverse
- **Certificate** = `Equiv.symm_apply_apply`

---

## 9. Algorithms

### 9.1 Profile Computation

```
Algorithm: ComputeProfile(x, C, obs, ι)
Input: state x, compression C, observers obs, index set ι
Output: observer profile f : ι → σ

1. y ← C(x)       // compress
2. for each i ∈ ι:
3.   f[i] ← obs[i](y)   // observe
4. return f

Time: O(|ι| · T_obs) where T_obs is observer evaluation time
Space: O(|ι|)
```

### 9.2 Certified Predictor Construction

```
Algorithm: BuildCertifiedPredictor(S, C, obs)
Input: finite state space S, compression C, observers obs
Output: certified predictor with lookup table

1. profiles ← {}     // map from profile to compressed state
2. for each x ∈ S:
3.   f ← ComputeProfile(x, C, obs, ι)
4.   if f ∉ profiles:
5.     profiles[f] ← C(x)
6. 
7. predict(f) := profiles[f] if f ∈ profiles, else arbitrary
8. return (predict, C, obs)

Time: O(|S| · |ι| · T_obs)
Space: O(|range(C)| · |ι|)
Certificate: by Theorem 5.1
```

### 9.3 Canonical Tree Construction

```
Algorithm: BuildCanonicalTree(S, C, d)
Input: finite state space S, compression C, distance d
Output: rooted tree model

1. compressed ← {C(x) | x ∈ S}
2. distances ← {d(a, b) | a, b ∈ compressed, a ≠ b}
3. Sort distances in decreasing order: r₁ > r₂ > ... > rₖ
4. tree ← single root node containing all of compressed
5. for j = 1 to k:
6.   For each leaf cluster L in tree:
7.     Partition L by: a ~_{rⱼ} b ⟺ d(a,b) ≤ rⱼ
8.     Replace L with children = partition classes
9. return tree

Time: O(|range(C)|² · T_dist + |range(C)|² log |range(C)|)
Space: O(|range(C)|²)
```

---

## 10. Computational Experiments

We implement the algorithms in Python and verify the theorems on concrete examples.

### 10.1 Example: 8-State Proof System

Consider `S = {0, 1, ..., 7}` with compression `C(x) = x mod 4` (mapping to 4 compressed states), ultrametric distance on compressed states:
```
d(0,1) = 1, d(0,2) = 2, d(0,3) = 2
d(1,2) = 2, d(1,3) = 2, d(2,3) = 1
```
and two observers `obs₀(x) = x mod 2`, `obs₁(x) = x div 2`.

The observer profiles are:
- State 0: profile (0, 0)
- State 1: profile (1, 0)
- State 2: profile (0, 1)
- State 3: profile (1, 1)

Observer separation holds (each pair has distinct profiles), and the canonical tree at distance thresholds 1 and 2 gives:
```
        root (r=2)
       /          \
   {0,1} (r=1)  {2,3} (r=1)
   /    \        /    \
  0      1      2      3
```

### 10.2 Verification

The Python demo (`demo.py`) verifies:
1. Profile computation matches the formal definition
2. Profile injection on compressed states
3. Canonical tree construction
4. Certified predictor correctness
5. Trace reconstruction consistency

---

## 11. Discussion

### 11.1 Significance

The main contribution is a clean, constructive duality between proof dynamics and observer algebra. The key insight is that idempotent compression + observer separation is *exactly* the right hypothesis to ensure faithful finite representation.

The theorem is not merely a Stone-type representation result transplanted to a new setting. The ultrametric geometry adds genuine content: it forces the representation to have hierarchical (tree) structure, and the uniqueness theorem guarantees that this structure is canonical.

### 11.2 Limitations

1. **Finiteness:** The current theorems require `S` to be finite. Extension to infinite compact/profinite systems is a natural next step.
2. **Observer construction:** We assume observers are given; we do not address how to find or learn separating observer families.
3. **Computational complexity:** The certified predictor uses a lookup table of size `|range(C)| · |ι|`, which may be large. Compression of the predictor itself is not addressed.

### 11.3 Connections to Other Fields

- **Tropical geometry:** Profile sup = tropical addition; the semimodule structure is a concrete instance of tropical linear algebra.
- **Stone duality:** Observer profiles = "characters" separating points; the duality parallels Stone's representation for Boolean algebras.
- **p-adic analysis:** Ultrametric ball equivalence relations = valuation-defined congruences in p-adic number theory.
- **Hierarchical clustering:** The canonical tree = single-linkage dendrogram; uniqueness = the well-known fact that ultrametrics and dendrograms are in bijection.
- **Neural networks:** Observers = feature detectors; profiles = latent representations; the duality certifies that the representation is faithful.

---

## 12. Future Work

See `FUTURE_DIRECTIONS.md` for detailed research directions. Key targets:
1. Profinite extension of the duality to infinite systems
2. Tropical Hahn–Banach separation for observer semimodules
3. Proof-search complexity bounds from tree depth/branching
4. PAC-learning guarantees for observer families
5. Categorical contravariant equivalence (FUPS^op ≃ FOPS)

---

## References

1. Stone, M.H. (1936). "The theory of representation for Boolean algebras." *Trans. AMS* 40(1), 37–111.
2. Hensel, K. (1897). "Über eine neue Begründung der Theorie der algebraischen Zahlen." *Jahresbericht der DMV* 6, 83–88.
3. Dress, A., Moulton, V., Terhalle, W. (1996). "T-theory: An overview." *European J. Combin.* 17(2-3), 161–175. [Ultrametric-dendrogram correspondence]
4. Viro, O. (2001). "Dequantization of real algebraic geometry on logarithmic paper." *Proc. 3rd European Congress of Mathematics*, 135–146. [Tropical geometry foundations]
5. Simon, I. (1988). "Recognizable sets with multiplicities in the tropical semiring." *MFCS*, LNCS 324, 107–120.
