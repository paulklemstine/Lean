## Assignment: Algebra–Logic–MachineLearning Non-Archimedean Löwenheim–Sample Duality via Ultrametric Proof Types and Operadic Compression Cores

**Mode:** `formalize` + `prove`

You are not being asked for a local lemma. You are being asked to carve out a new formal interface between three worlds that almost never meet cleanly in proof assistants: non-Archimedean geometry, model-theoretic approximation, and sample compression in learning theory. The point is not merely to define another metric structure; it is to show that *ultrametric proof contraction* forces a finite combinatorial core, and that this core is exactly the object a learning theorist would call a compression certificate. If this works, it opens a genuine theory of **non-Archimedean learnability of proof systems**.

The breakthrough claim should be that in an observer-stable ultrametric proof space, total boundedness is not just a topological compactness shadow: it is equivalent to the existence of finite operadic compression certificates, and therefore to a controlled form of uniform learnability. This is a non-Archimedean Löwenheim–Sample duality: finite approximate elementary submodels become finite compressed hypothesis cores.

---

## Formalization Target

Bridge the speculative infrastructure from:

- `Speculative/AutoResearch/Bridges/UltrametricProofLearning.lean`
- `Speculative/AutoResearch/Bridges/UltrametricDeepLearning.lean`

with operadic ML infrastructure from:

- `MachineLearning/OperadicDeepLearning/Foundations.lean`

and define a clean Lean interface around:

- `UltrametricProofType`
- `ProofContraction`
- `CompressionCore`
- `OperadicDecoder`
- `ProofObserver`
- `ObserverStable`
- `RealizationFunctor`

You should aim to produce a new file along the lines of:

- `Speculative/AutoResearch/Bridges/LowenheimSampleDuality.lean`

and, if useful, supporting files for definitions and finite-cover lemmas.

---

## Core Mathematical Objects

Let `(P, d)` be a pseudo/extended metric proof space with ultrametric inequality

\[
d(x,z) \le \max(d(x,y), d(y,z)).
\]

Let `C : P → P` be a contraction with factor `q < 1`, in the sense

\[
d(Cx, Cy) \le q \, d(x,y).
\]

For `ε > 0`, define the **ε-core rank** of `(P,C)` to be the least `n : ℕ` such that there exists a finite set `S ⊆ P` with `|S| = n` and every `p : P` lies within `ε` of some iterate `C^[k](s)` for some `s ∈ S`, `k : ℕ`.

On the ML side, for a hypothesis class `H` with an operadic decoder `decode : Code → H`, define the **ε-compression rank** to be the least codebook size that ε-approximates all hypotheses under the target metric/evaluation pseudometric.

The bridge theorem should show that, for proof systems equipped with a suitable observer family and realization functor into an operadic hypothesis class, these two notions coincide up to explicit distortion.

---

## Precise Theorem Statements

### Theorem 1: Finite Core from Total Boundedness + Contraction

This is the first formal foothold and should likely be proved first.

**Mathematical statement.**  
Let `(P,d)` be an ultrametric pseudoemetric space, let `C : P → P` be `q`-contractive with `0 ≤ q < 1`. If `P` is totally bounded, then for every `ε > 0` there exists a finite compression core `S : Finset P` and a depth bound `N : ℕ` such that every `p : P` is within `ε` of some iterate `C^[n](s)` with `s ∈ S` and `n ≤ N`. In particular, `coreRank ε < ∞`.

A robust Lean-facing formulation is:

```lean
theorem finite_core_of_totally_bounded
  {P : Type*} [PseudoEMetricSpace P]
  (hUltra : ∀ x y z : P, edist x z ≤ max (edist x y) (edist y z))
  (C : P → P)
  (q : ℝ≥0∞)
  (hq : q < 1)
  (hC : ∀ x y : P, edist (C x) (C y) ≤ q * edist x y)
  (hTot : TotallyBounded (Set.univ : Set P)) :
  ∀ ⦃ε : ℝ≥0∞⦄, ε ≠ 0 → ∃ (S : Finset P) (N : ℕ),
    ∀ p : P, ∃ s ∈ S, ∃ n ≤ N, edist p ((C^[n]) s) ≤ ε
```

If iteration-depth boundedness is too ambitious initially, first prove the weaker but still important statement:

```lean
theorem finite_core_of_totally_bounded_weak
  {P : Type*} [PseudoEMetricSpace P]
  (hUltra : ∀ x y z : P, edist x z ≤ max (edist x y) (edist y z))
  (C : P → P)
  (q : ℝ≥0∞)
  (hq : q < 1)
  (hC : ∀ x y : P, edist (C x) (C y) ≤ q * edist x y)
  (hTot : TotallyBounded (Set.univ : Set P)) :
  ∀ ⦃ε : ℝ≥0∞⦄, ε ≠ 0 → ∃ S : Finset P,
    ∀ p : P, ∃ s ∈ S, ∃ n : ℕ, edist p ((C^[n]) s) ≤ ε
```

This theorem already captures the compactness-to-compression direction.

---

### Theorem 2: Ultrametric Core Duality

This is the conceptual centerpiece.

**Mathematical statement.**  
For a class of observer-stable ultrametric proof systems `(P,d,C,Obs)` equipped with a realization functor `R` into compressed operadic hypothesis classes, there are explicit constants `A ≥ 1`, `B ≥ 0` such that for all `ε > 0`,

\[
\mathrm{compressionRank}_{A\varepsilon+B}(R(P,C))
\;\le\;
\mathrm{coreRank}_\varepsilon(P,C)
\;\le\;
\mathrm{compressionRank}_{A\varepsilon+B}(R(P,C)).
\]

At minimum, formalize one direction exactly and the converse under stronger hypotheses (e.g. decoder surjectivity / observer faithfulness / distortion control).

A Lean signature template:

```lean
theorem ultrametric_core_duality
  {P H Code : Type*}
  [PseudoEMetricSpace P]
  [PseudoEMetricSpace H]
  (C : P → P)
  (R : P → H)
  (decode : Code → H)
  (encodeSet : Finset P → Finset Code)
  (ε δ : ℝ≥0∞)
  (hε : ε ≠ 0)
  (hδ : δ ≠ 0)
  (hFaithful :
    ∀ p₁ p₂ : P, edist (R p₁) (R p₂) ≤ δ → edist p₁ p₂ ≤ ε)
  (hRealize :
    ∀ S : Finset P, ∀ p : P,
      (∃ s ∈ S, ∃ n : ℕ, edist p ((C^[n]) s) ≤ ε) →
      ∃ c ∈ encodeSet S, edist (R p) (decode c) ≤ δ) :
  compressionRank decode δ ≤ coreRank C ε ∧
  coreRank C ε ≤ compressionRank decode δ
```

You may need to define `coreRank` and `compressionRank` as `sInf` over sets of naturals or as `Nat` values with default `0` when unrealized. If cardinal minimization is awkward in a first pass, define a *certificate predicate* and prove equivalence at the level of existence:

```lean
def HasCoreCertificate (C : P → P) (ε : ℝ≥0∞) (n : ℕ) : Prop := ...
def HasCompressionCertificate (decode : Code → H) (ε : ℝ≥0∞) (n : ℕ) : Prop := ...

theorem ultrametric_core_duality_cert
  ...
  : HasCoreCertificate C ε n ↔ HasCompressionCertificate decode δ n
```

This certificate-level equivalence is likely the right first theorem in Lean.

---

### Theorem 3: Approximate Finite-Submodel / ε-Elementary Compression Core

This is the model-theoretic jewel and should be stated boldly even if the full proof requires a staged development.

**Mathematical statement.**  
Let `Obs` be a finite family of bounded proof observers `φ : P → α_φ`, each uniformly continuous with respect to the ultrametric. If `(P,d,C)` is totally bounded and observer-stable, then for every `ε > 0` there exists a finite core `S ⊆ P` such that for every `p ∈ P` there exists `s ∈ S` and `n : ℕ` with:

1. `d(p, C^[n](s)) ≤ ε`,
2. each observer value is preserved up to `ε`,
3. the realized hypothesis class induced by `S` is uniformly learnable with sample complexity controlled by `|S|`.

A Lean signature could be staged as:

```lean
theorem finite_elementary_compression_core
  {P α : Type*}
  [PseudoEMetricSpace P]
  [PseudoEMetricSpace α]
  (C : P → P)
  (Obs : Finset (P → α))
  (ε : ℝ≥0∞)
  (hε : ε ≠ 0)
  (hTot : TotallyBounded (Set.univ : Set P))
  (hStable :
    ∀ φ ∈ Obs, ∀ x y : P, edist x y ≤ ε → edist (φ x) (φ y) ≤ ε) :
  ∃ S : Finset P,
    ∀ p : P, ∃ s ∈ S, ∃ n : ℕ,
      edist p ((C^[n]) s) ≤ ε ∧
      ∀ φ ∈ Obs, edist (φ p) (φ ((C^[n]) s)) ≤ ε
```

This is your approximate Löwenheim principle in compressed form.

---

### Theorem 4: Compression Core Generalization Bound

Even a simple finite-class bound would be a major bridge result if linked to core size.

**Mathematical statement.**  
If a realized hypothesis class admits an ε-compression certificate of size `k`, then it is uniformly learnable with sample complexity `O((log k + log(1/δ))/η²)` under bounded loss. Do not overreach for the sharpest statistical theorem; a finite-hypothesis Hoeffding/union bound formalization is already enough to certify the bridge.

Lean-facing theorem skeleton:

```lean
theorem compression_core_generalization_bound
  {H X Y : Type*}
  (decode : Fin k → H)
  (loss : H → X → Y → ℝ)
  (η δ : ℝ)
  (hη : 0 < η)
  (hδ : 0 < δ)
  (hδ' : δ < 1)
  (hbounded : ∀ h x y, 0 ≤ loss h x y ∧ loss h x y ≤ 1) :
  ∃ m : ℕ, 0 < m ∧
    ∀ (sample : Fin m → X × Y),
      True
```

This may need adaptation depending on the probability infrastructure available. If the probabilistic statement is too heavy, prove a deterministic combinatorial surrogate first: finite compression certificate implies finite covering number, and finite covering number implies learnability once a probability layer is added later.

---

## Recommended Lean Definitions

You should define the bridge structures so that theorems are certificate-based and composable.

```lean
structure UltrametricProofType where
  P : Type*
  instPseudoEMetricSpace : PseudoEMetricSpace P
  ultrametric :
    ∀ x y z : P, edist x z ≤ max (edist x y) (edist y z)

attribute [instance] UltrametricProofType.instPseudoEMetricSpace

structure ProofContraction (U : UltrametricProofType) where
  map : U.P → U.P
  q : ℝ≥0∞
  q_lt_one : q < 1
  contractive : ∀ x y : U.P, edist (map x) (map y) ≤ q * edist x y

structure CompressionCore (P : Type*) where
  seeds : Finset P
  depth : ℕ

def CoreCovers
  {P : Type*} [PseudoEMetricSpace P]
  (C : P → P) (ε : ℝ≥0∞) (K : CompressionCore P) : Prop :=
  ∀ p : P, ∃ s ∈ K.seeds, ∃ n ≤ K.depth, edist p ((C^[n]) s) ≤ ε

def HasCoreCertificate
  {P : Type*} [PseudoEMetricSpace P]
  (C : P → P) (ε : ℝ≥0∞) (k : ℕ) : Prop :=
  ∃ K : CompressionCore P, K.seeds.card ≤ k ∧ CoreCovers C ε K
```

For the realization side:

```lean
structure OperadicDecoder (Code H : Type*) [PseudoEMetricSpace H] where
  decode : Code → H

def HasCompressionCertificate
  {Code H : Type*} [PseudoEMetricSpace H]
  (decode : Code → H) (ε : ℝ≥0∞) (k : ℕ) : Prop :=
  ∃ T : Finset Code, T.card ≤ k ∧ ∀ h : H, ∃ c ∈ T, edist h (decode c) ≤ ε
```

And the realization bridge:

```lean
structure RealizationFunctor
  (P H : Type*) [PseudoEMetricSpace P] [PseudoEMetricSpace H] where
  toFun : P → H
  lipschitz : ∃ K : ℝ≥0∞, ∀ p q : P, edist (toFun p) (toFun q) ≤ K * edist p q
```

If there is existing category-theoretic infrastructure for functors, use it later; for the first theorem, a structured map is enough.

---

## Proof Strategy Architecture

### Strategy A: Total boundedness → finite ε-net → contraction closure
**Most promising first route.**

1. Use total boundedness of `P` to obtain a finite `ε`-net `S`.
2. Show that contraction iterates of points in `S` remain sufficient to cover the orbit geometry induced by `C`.
3. In the ultrametric setting, exploit the stronger geometry of balls:
   - balls are either nested or disjoint in many standard formulations,
   - centers are highly non-unique,
   - contraction preserves ball structure more rigidly than in Archimedean metrics.
4. Package the resulting finite witness as a `CompressionCore`.

Why this is promising: total boundedness lemmas already exist in Mathlib for pseudo/emetric spaces, and iteration of contractions is straightforward to formalize. The ultrametric inequality should simplify radius bookkeeping because maxima replace additive triangle chains.

### Strategy B: Observer pseudometric first, ambient metric second
A more model-theoretic route.

1. Define an observer pseudometric
   \[
   d_{\mathrm{obs}}(p,q)=\sup_{\phi \in Obs} d_\alpha(\phi(p),\phi(q))
   \]
   for finite observer families, or a finite-max surrogate in Lean.
2. Prove total boundedness / finite-net existence in `d_obs`.
3. Show observer-stable contraction transfers `d_obs`-cores to ambient ultrametric cores.
4. Use this to obtain the ε-elementary finite compression core theorem.

Why this matters: it aligns the proof system with approximate elementary equivalence and avoids overcommitting to the raw ambient metric. It is also conceptually the right analogue of finite-submodel extraction.

### Strategy C: Certificate equivalence before rank equality
Best route for the main duality theorem.

1. Avoid minimization over cardinals at first.
2. Define `HasCoreCertificate` and `HasCompressionCertificate`.
3. Prove:
   - a core certificate pushes forward to a compression certificate via realization;
   - a faithful decoder pulls back a compression certificate to a core certificate.
4. Only after this, define ranks as minimal `k` and derive inequalities/equalities.

Why this is promising: Lean handles existence-of-witness equivalences much more smoothly than infima over finite-cardinality predicates. This strategy also isolates the mathematics from implementation noise.

---

## Key Supporting Lemmas to Target

You should aim to prove, in roughly this order:

```lean
lemma iterate_contraction
  {P : Type*} [PseudoEMetricSpace P]
  (C : P → P) (q : ℝ≥0∞)
  (hC : ∀ x y, edist (C x) (C y) ≤ q * edist x y) :
  ∀ n x y, edist ((C^[n]) x) ((C^[n]) y) ≤ q^n * edist x y
```

```lean
lemma ultrametric_ball_center_swap
  {P : Type*} [PseudoEMetricSpace P]
  (hUltra : ∀ x y z : P, edist x z ≤ max (edist x y) (edist y z))
  {x y : P} {r : ℝ≥0∞}
  (hxy : edist x y ≤ r) :
  Metric.closedBall x r = Metric.closedBall y r
```

Adapt to `EMetric.closedBall` if needed. This lemma is extremely important: in ultrametric spaces, points within a ball can often serve as alternate centers. This is one of the exact geometric facts that should make the compression proof elegant and distinct from standard metric entropy arguments.

```lean
lemma finite_net_gives_core
  {P : Type*} [PseudoEMetricSpace P]
  (C : P → P) (ε : ℝ≥0∞) :
  ...
```

```lean
lemma core_certificate_pushforward
  ...
  : HasCoreCertificate C ε k → HasCompressionCertificate decode δ k
```

```lean
lemma compression_certificate_pullback
  ...
  : HasCompressionCertificate decode δ k → HasCoreCertificate C ε k
```

---

## Cross-Domain Connections You Should Make Explicit

### 1. Model Theory
This is an **approximate Löwenheim–Skolem theorem for proof observers**.  
Finite compression cores play the role of finite approximate elementary substructures. The observer family substitutes for formulas, and ultrametric closeness substitutes for elementary equivalence up to precision. This suggests a future theory of *continuous non-Archimedean proof structures*.

### 2. Learning Theory
This is a new species of **sample compression theorem**.  
The compressed object is not a subset of examples but a finite set of proof seeds plus contraction depth. The hypothesis class is generated operadically from proof geometry. Core size controlling learnability is exactly the kind of theorem that could seed a whole “proof compression learning” program.

### 3. Non-Archimedean Geometry
Ultrametric spaces are not just metric spaces with a stronger triangle inequality. Their ball combinatorics are tree-like and often admit canonical cluster decompositions. This means the compression core should have a hidden dendrogram interpretation. There is a plausible future bridge to Berkovich-style semantics and p-adic neural representations.

### 4. Operads and Deep Learning
The operadic decoder is not decoration. It should encode compositional reconstruction: small proof cores generate large hypothesis classes by composition. This is philosophically close to syntax-semantics adjunctions and practically close to modular neural architectures. If formalized, this could become a categorical compression theorem for compositional learning systems.

### 5. Proof Theory / Semantics
A contraction on proof states resembles normalization, cut-reduction, proof simplification, or denoising of derivations. The theorem says that if such dynamics is ultrametrically contracting, then the proof universe has a finite compressed skeleton. That is a striking semantic statement with algorithmic consequences.

---

## Why This Would Be a Breakthrough

Because it would certify, inside Lean, a theorem of the following form:

> **Compactness in a non-Archimedean proof semantics is equivalent to compressibility in a compositional learning semantics.**

That is not a routine extension of PAC-Bayes, nor a repackaging of compactness, nor another metric entropy estimate. It is a bridge theorem between proof geometry and learnability. If you can make this precise and machine-checked, you create a new field fragment: **formal non-Archimedean statistical proof theory**.

This could enable:

- certified extraction of finite proof summaries,
- approximate model companions for bounded observer logics,
- new learnability criteria for symbolic/neural hybrid systems,
- operadic compression algorithms with proof-theoretic guarantees,
- p-adic / ultrametric semantics for reasoning agents.

---

## Concrete Lean Work Plan

1. **Define the certificate predicates first.**
   - Avoid minimization/rank definitions until certificate theorems are stable.
2. **Prove finite-core existence from total boundedness.**
   - This is the first nontrivial theorem with genuine geometric content.
3. **Formalize realization pushforward.**
   - Core certificate ⇒ compression certificate.
4. **Add observer stability.**
   - Derive approximate elementary preservation theorem.
5. **Only then define `coreRank` and `compressionRank`.**
   - Use `Nat.find` or least witness patterns if existence is already proved.
6. **If probability is too heavy, stop the learning theorem at finite covering numbers.**
   - State a clean corollary that sample complexity follows from standard finite-class bounds, even if the full probabilistic theorem is postponed.

---

## Suggested Theorem Names

- `iterate_contraction`
- `finite_core_of_totally_bounded`
- `finite_core_of_totally_bounded_weak`
- `core_certificate_pushforward`
- `compression_certificate_pullback`
- `ultrametric_core_duality_cert`
- `ultrametric_core_duality`
- `finite_elementary_compression_core`
- `compression_core_generalization_bound`

---

## If Existing Sorries Are Nearby

You mentioned possible relevance to `ultrametric_trian...`. If there is a sorry proving or using the strong triangle inequality in the bridge files, discharge it immediately and factor it into a reusable lemma about ultrametric balls and contraction iterates. The entire project will depend on that geometry being easy to invoke.

---

## Deliverables

1. Lean 4 definitions for ultrametric proof types, contractions, compression cores, observers, and operadic decoders.
2. A proved theorem `finite_core_of_totally_bounded` or its weak certificate variant.
3. A proved certificate-level duality theorem `ultrametric_core_duality_cert`.
4. If possible, an approximate finite-submodel theorem `finite_elementary_compression_core`.
5. A structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, not vague ideas.

---

## Required FUTURE_DIRECTIONS.md

You must produce `FUTURE_DIRECTIONS.md` with 3–5 specific next theorems or systems to build. Good examples include:

1. **Non-Archimedean VC theory:** define a shattering notion for ultrametric observer families and prove compression-implies-finite-ultrametric-VC-dimension.
2. **Adjoint semantics:** construct an adjunction between proof contraction systems and operadic decoder systems, with the duality theorem as the unit/counit witness.
3. **Tree-coded cores:** prove that every ultrametric compression core admits a canonical rooted-tree representation, yielding logarithmic-depth decoders.
4. **Probabilistic upgrade:** formalize finite-class generalization bounds over realized operadic hypothesis classes using Mathlib probability.
5. **Approximate elementary categories:** define a category of observer-stable ultrametric proof systems and prove that finite compression cores give compact projective approximants.

---

## Application Keywords

non-Archimedean learning, ultrametric proof theory, approximate Löwenheim–Skolem, sample compression, operadic deep learning, proof normalization geometry, observer semantics, finite covering certificates, model-theoretic approximation, certified proof summarization, compositional hypothesis classes, p-adic semantics, formalized statistical logic

### Catalog Reference Files
@Speculative/AutoResearch/Bridges/UltrametricProofLearning.lean
```lean
/-
# Ultrametric Proof Dynamics: p-Adic Neural Compression and Diagonal Stability

This file formalizes the theory of **ultrametric proof dynamics** for neural compression,
centered on a diagonal-stability principle for iterated proof updates in an ultrametric
state space. It bridges:

- **Ultrametric geometry / p-adic valuation thinking**
- **Machine learning / certified robustness / Lipschitz compression**
- **Cryptographic semantics / collision resistance via prefix-separation**
- **Operadic neural composition / proof architecture minimization**

## Main Results (25+ theorems, 0 sorry)

- **Geometric iterate decay**: d(F^[n+1] x, F^[n] x) ≤ q^n · d(F x, x)
- **Diagonal stability**: adjacent-step distances are monotonically decreasing
- **Orbit tail bound**: d(F^[m] x, F^[n] x) ≤ q^m · d(F x, x) for m ≤ n
- **Compression threshold existence**: ∀ ε > 0, ∃ N, d(F^[N] x, F^[N+1] x) ≤ ε
- **Ultrametric isosceles shell**: the classical "all triangles are isosceles" theorem
- **Tropical hash collision exclusion**: distinct points stay distinct under iterates
- **Neural compression monotonicity**: F is distance-non-increasing
- **Proof compression functoriality**: intertwining maps preserve orbits exactly

## Structures (11 novel types)

- `UltrametricDistPred` — ultrametric distance predicate
- `ProofStateContraction` — contractive map on an ultrametric space
- `DiagStableProofSystem` — system with monotone decreasing step distances
- `ProofCompressionOperator` — named compression operator
- `NeuralCompressionWitness` — compression preserving separation scores

## Bridges

- **Ultrametric geometry ↔ ML**: contraction decay → certified robustness bounds
- **p-adic analysis ↔ Cryptography**: prefix separation → collision resistance
- **Operadic composition ↔ Neural architecture**: functorial compression → layer stacking
- **Dynamical systems ↔ Optimization**: diagonal stability → convergence guarantees
-/

import Mathlib

open Function

noncomputable section

/-! ## §1. Foundations: Ultrametric Distance and Core Predicates -/

/-- `UltrametricDistPred d` asserts that `d` is an ultrametric distance function:
    nonnegative, identity of indiscernibles, symmetric, and satisfying the strong
    triangle inequality d(x,z) ≤ max(d(x,y), d(y,z)).

    Bridge: connects non-Archimedean valuation theory to hierarchical clustering
    and post_quantum_security via prefix-tree separation. -/
def UltrametricDistPred {α : Type*} (d : α → α → ℝ) : Prop :=
  (∀ x y, 0 ≤ d x y) ∧
  (∀ x y, d x y = 0 ↔ x = y) ∧
  (∀ x y, d x y = d y x) ∧
  (∀ x y z, d x z ≤ max (d x y) (d y z))

/-- `ProofCompressionOperator` wraps a self-map with a named complexity measure.
    Bridge: connects proof-state compression to neural_network architecture
    minimization and entropy capacity bounds. -/
structure ProofCompressionOperator (α : Type*) where
  toFun : α → α
  nameComplexity : ℕ

/-- `ProofStateContraction` bundles an ultrametric space with a contractive
    self-map F and contraction ratio q ∈ [0,1).

    Bridge: connects p-adic style valuation decay to machine-learning compression
    certificates and lipschitz_certified_robustness via hierarchical prefix separation. -/
structure ProofStateContraction (α : Type*) where
  d : α → α → ℝ
  isUltra : UltrametricDistPred d
  F : α → α
  q : ℝ
  hq_nonneg : 0 ≤ q
  hq_lt_one : q < 1
  contractive : ∀ x y, d (F x) (F y) ≤ q * d x y

/-- `DiagStableProofSystem` encodes that once two iterates are close enough,
    future iterates remain controlled — the adjacent-step distance is
    monotonically decreasing.

    Bridge: connects diagonal_stability of proof dynamics to quantum-style
    hierarchical state compression and certified convergence guarantees. -/
structure DiagStableProofSystem (α : Type*) where
  d : α → α → ℝ
  isUltra : UltrametricDistPred d
  F : α → α
  diagonalStable :
    ∀ x n, d (F^[n+2] x) (F^[n+1] x) ≤ d (F^[n+1] x) (F^[n] x)

/-- The proof separation score between two proof states under distance `d`.
    Bridge: connects ultrametric geometry to post_quantum_security via
    tropical_hash_collision resistance interpretation. -/
def proofSeparationScore {α : Type*} (d : α → α → ℝ) (x y : α) : ℝ := d x y

/-- The compression radius: distance from a state to its compressed image.
    Bridge: connects proof architecture minimization to neural_network
    layer-wise compression and entropy capacity bounds. -/
def compressionRadius {α : Type*} (d : α → α → ℝ) (F : α → α) (x : α) : ℝ :=
  d x (F x)

/-- A certified robust orbit: all adjacent iterates are within radius R.
    Bridge: connects dynamical systems theory to lipschitz_certified_robustness
    and adversarial ML defense via bounded orbit diameter. -/
def IsCertifiedRobustOrbit {α : Type*} (d : α → α → ℝ) (F : α → α)
    (x : α) (R : ℝ) : Prop :=
  ∀ n : ℕ, d (F^[n] x) (F^[n+1] x) ≤ R

/-- Exponential compression profile: adjacent-step distances decay as C·q^n.
    Bridge: connects contraction theory to certified neural_network compression
    with explicit O(q^n) convergence rate bounds. -/
def HasExponentialCompressionProfile {α : Type*}
    (d : α → α → ℝ) (F : α → α) (x : α) (q C : ℝ) : Prop :=
  ∀ n : ℕ, d (F^[n] x) (F^[n+1] x) ≤ C * q ^ n

/-- Prefix collision resistance: points closer than τ must be equal.
    Bridge: connects ultrametric geometry to post_quantum_security and
    tropical_hash_collision exclusion via minimum distance thresholds. -/
def PrefixCollisionResistant {α : Type*} (d : α → α → ℝ) (τ : ℝ) : Prop :=
  ∀ ⦃x y : α⦄, d x y < τ → x = y

/-- `NeuralCompressionWitness` asserts that a compression operator is
    distance-non-increasing: it never increases the separation between states.

    Bridge: connects operadic neural composition to lipschitz_certified_robustness
    and proof architecture minimization. -/
structure NeuralCompressionWitness (α : Type*) (d : α → α → ℝ) where
  compressor : α → α
  preserves_orbit_separation :
    ∀ x y, proofSeparationScore d (compressor x) (compressor y) ≤
           proofSeparationScore d x y

/-- Whether the iterate reaches a compression threshold ε by step N.
    Bridge: connects contraction dynamics to algorithmic stopping rules
    for certified neural proof compression. -/
def reachesCompressionThreshold {α : Type*}
    (d : α → α → ℝ) (F : α → α) (x : α) (ε : ℝ) (N : ℕ) : Prop :=
  d (F^[N] x) (F^[N+1] x) ≤ ε

/-- `UltrametricOrbitConvergence` asserts convergence of geometric-step-bounded
    orbits. This is a completeness axiom that strengthens finite-step bounds
    to actual convergence.

    Bridge: connects ultrametric completeness to quantum/thermodynamic basin
    convergence and post_quantum_security fixed-point semantics. -/
class UltrametricOrbitConvergence (α : Type*) (d : α → α → ℝ) : Prop where
  converges_of_geometric_step_bound :
-- ... (truncated, full file has 624 lines)
```

@Speculative/AutoResearch/Bridges/UltrametricDeepLearning.lean
```lean
/-
# Ultrametric Deep Learning: p-Adic Optimization, Valuation Bounds, and Pruning Theory

This file formalizes the foundations of *ultrametric deep learning*: the study of
neural network optimization over non-Archimedean fields. The ultrametric strong
triangle inequality ‖x + y‖ ≤ max ‖x‖ ‖y‖ fundamentally reshapes loss landscape
geometry, yielding provable structural advantages over Archimedean optimization.

## Main Results (27 theorems, 0 sorry)

- **Ultrametric Isosceles Principle**: Unequal-norm elements sum to max norm
- **Sum Dominance**: ‖∑ vᵢ‖ ≤ max ‖vᵢ‖ (no cancellation)
- **MulVec Bound**: ‖(Av)ᵢ‖ ≤ ‖A‖_∞ · ‖v‖_∞ (no factor of n)
- **Entrywise Norm Submultiplicativity**: ‖BA‖_∞ ≤ ‖B‖_∞ · ‖A‖_∞
- **Lipschitz Composition**: Constants multiply under composition
- **Pruning Advantage**: Total error = max(individual errors), not sum
- **Valuation Monotone Pruning**: Higher valuation ⟹ smaller error
- **Critical Point Uniformity**: At critical points, components have equal norm
- **Generalization Bound Decay**: O(1/√n) with sample size
- **Valuation-Norm Correspondence**: ‖w‖ = p^{-v_p(w)}

## Structures (7 novel types)

- `IsUltrametricNormedField` — typeclass for non-Archimedean normed fields
- `UltrametricLayer` — neural network layer with certified norm bound
- `ValuationComplexityMeasure` — product-of-norms generalization complexity
- `PadicActivation` — activation function with certified Lipschitz constant
- `UltrametricNetworkCertificate` — end-to-end Lipschitz certification
- `UltrametricGeneralizationBound` — sample-size-dependent generalization bound
- `UltrametricPruningCertificate` — certified pruning with ultrametric advantage

## Bridges

- **Algebra ↔ ML**: p-adic valuations → neural network complexity measures
- **Number Theory ↔ Cryptography**: Valuation structure → certified pruning
- **Optimization ↔ Analysis**: Non-cancellation → saddle-free landscapes
-/

import Mathlib

open Finset Matrix

noncomputable section

/-! ## §1. Ultrametric Normed Field Infrastructure -/

/-- **IsUltrametricNormedField**: A normed field satisfying the ultrametric
    (strong) triangle inequality ‖x + y‖ ≤ max ‖x‖ ‖y‖.
    Bridge: connects non-Archimedean algebra to saddle-free ML optimization. -/
class IsUltrametricNormedField (K : Type*) extends NormedField K where
  ultrametric' : ∀ x y : K, ‖x + y‖ ≤ max ‖x‖ ‖y‖

/-- ℚ_p is an ultrametric normed field. -/
instance Padic.instIsUltrametricNormedField (p : ℕ) [hp : Fact (Nat.Prime p)] :
    IsUltrametricNormedField ℚ_[p] where
  ultrametric' := fun x y => IsUltrametricDist.norm_add_le_max x y

/-! ## §2. Fundamental Ultrametric Norm Theorems -/

variable (p : ℕ) [hp : Fact (Nat.Prime p)]

/-- **Ultrametric Triangle Inequality**: The fundamental non-Archimedean inequality.
    Impact: certified_robustness — perturbation bounds tighter than Archimedean. -/
theorem ultrametric_triangle_inequality (x y : ℚ_[p]) :
    ‖x + y‖ ≤ max ‖x‖ ‖y‖ :=
  IsUltrametricDist.norm_add_le_max x y

/-- **Ultrametric Isosceles Principle**: Unequal-norm elements sum to max norm.
    *Impossible* in ℝ where cancellation reduces ‖x + y‖ (e.g., x = 1, y = -1 + ε).
    Engine behind saddle elimination: gradient components cannot partially cancel.
    Bridge: connects ultrametric geometry (Algebra) to gradient dominance (ML). -/
theorem ultrametric_isosceles_principle (x y : ℚ_[p]) (hne : ‖x‖ ≠ ‖y‖) :
    ‖x + y‖ = max ‖x‖ ‖y‖ :=
  Padic.add_eq_max_of_ne hne

/-- **Ultrametric Subtraction Bound**: ‖x - y‖ ≤ max ‖x‖ ‖y‖.
    Bridge: connects p-adic geometry to adversarial ML defense. -/
theorem ultrametric_sub_bound (x y : ℚ_[p]) :
    ‖x - y‖ ≤ max ‖x‖ ‖y‖ := by
  calc ‖x - y‖ = ‖x + (-y)‖ := by rw [sub_eq_add_neg]
    _ ≤ max ‖x‖ ‖-y‖ := IsUltrametricDist.norm_add_le_max x (-y)
    _ = max ‖x‖ ‖y‖ := by rw [norm_neg]

/-- **Norm Multiplicativity**: ‖xy‖ = ‖x‖·‖y‖ in ℚ_p.
    Impact: certified_robustness — exact Lipschitz constants. -/
theorem padic_norm_multiplicative (x y : ℚ_[p]) :
    ‖x * y‖ = ‖x‖ * ‖y‖ :=
  norm_mul x y

/-- **Ultrametric Sum Dominance**: ‖∑ vᵢ‖ ≤ C when all ‖vᵢ‖ ≤ C.
    No partial cancellation possible — prevents gradient saddle creation.
    Bridge: connects ultrametric analysis to gradient non-cancellation (ML). -/
theorem ultrametric_sum_dominance
    {n : ℕ} (v : Fin n → ℚ_[p]) (C : ℝ) (hn : 0 < n)
    (hC : ∀ i, ‖v i‖ ≤ C) :
    ‖∑ i : Fin n, v i‖ ≤ C :=
  IsUltrametricDist.norm_sum_le_of_forall_le_of_nonempty
    ⟨⟨0, hn⟩, mem_univ _⟩ (fun i _ => hC i)

/-- **Critical Point Gradient Uniformity**: If g₁ + g₂ = 0, then ‖g₁‖ = ‖g₂‖.
    At a critical point where ∇L = 0, all gradient components must have the
    same p-adic norm — no "mixed curvature" as in Archimedean saddles.
    Bridge: connects ultrametric analysis to saddle-free optimization (ML).
    Impact: certified_robustness, adversarial_defense. -/
theorem ultrametric_critical_gradient_uniformity
    (g₁ g₂ : ℚ_[p]) (hsum : g₁ + g₂ = 0) :
    ‖g₁‖ = ‖g₂‖ := by
  rw [eq_neg_of_add_eq_zero_left hsum, norm_neg]

/-- **N-ary Critical Point Bound**: If ∑ vᵢ = 0 and all components except i₀
    have norm ≤ C, then ‖v i₀‖ ≤ C. Ultrametric inequality propagates bounds.
    Bridge: connects ultrametric analysis to high-dimensional optimization (ML). -/
theorem ultrametric_sum_zero_dominant_bound
    {n : ℕ} (v : Fin n → ℚ_[p])
    (hsum : ∑ i : Fin n, v i = 0)
    (i₀ : Fin n) (C : ℝ) (hC0 : 0 ≤ C) (hC : ∀ i, i ≠ i₀ → ‖v i‖ ≤ C) :
    ‖v i₀‖ ≤ C := by
  have h1 := add_sum_erase univ v (mem_univ i₀)
  rw [hsum] at h1
  rw [eq_neg_of_add_eq_zero_left h1, norm_neg]
  by_cases hempty : (univ.erase i₀ : Finset (Fin n)).Nonempty
  · exact IsUltrametricDist.norm_sum_le_of_forall_le_of_nonempty hempty
      (fun j hj => hC j (ne_of_mem_erase hj))
  · rw [not_nonempty_iff_eq_empty.mp hempty, sum_empty, norm_zero]; exact hC0

/-- **Valuation-Norm Correspondence**: ‖x‖ = p^{-v_p(x)} for x ≠ 0.
    Norms take values in {p^k : k ∈ ℤ} ∪ {0} — a discrete spectrum.
    Impact: post_quantum_security — connects to lattice problems. -/
theorem valuation_norm_correspondence (x : ℚ_[p]) (hx : x ≠ 0) :
    ‖x‖ = (p : ℝ) ^ (-x.valuation) :=
  Padic.norm_eq_zpow_neg_valuation hx

/-- **Norm Absorption**: If ‖x‖ < ‖y‖ then ‖x + y‖ = ‖y‖. The larger-norm
    element "absorbs" the smaller one.
    Bridge: connects ultrametric absorption to gradient analysis (ML). -/
theorem ultrametric_norm_absorption (x y : ℚ_[p]) (hlt : ‖x‖ < ‖y‖) :
    ‖x + y‖ = ‖y‖ := by
  rw [Padic.add_eq_max_of_ne (ne_of_lt hlt), max_eq_right (le_of_lt hlt)]

/-- **Norm Absorption (symmetric)**: If ‖y‖ < ‖x‖ then ‖x + y‖ = ‖x‖. -/
theorem ultrametric_norm_absorption_symm (x y : ℚ_[p]) (hlt : ‖y‖ < ‖x‖) :
    ‖x + y‖ = ‖x‖ := by
  rw [Padic.add_eq_max_of_ne (ne_of_gt hlt), max_eq_left (le_of_lt hlt)]

/-- **Ball Stability**: p-adic balls are additive subgroups. If ‖x‖ ≤ r and
    ‖y‖ ≤ r, then ‖x + y‖ ≤ r.
    Bridge: connects p-adic topology to constraint optimization (ML). -/
theorem ultrametric_ball_stability
    (x y : ℚ_[p]) (r : ℝ) (hx : ‖x‖ ≤ r) (hy : ‖y‖ ≤ r) :
    ‖x + y‖ ≤ r :=
-- ... (truncated, full file has 534 lines)
```

@MachineLearning/OperadicDeepLearning/Foundations.lean
```lean
import Mathlib

/-! # Operadic Deep Learning: Foundations

This file formalizes the algebraic foundations of operadic deep learning theory.
We define symmetric operads, neural layers, and their compositional structure,
then prove foundational theorems connecting neural network composition to operadic
algebraic structure.

## Main Results

### Structures and Definitions (7 novel)
* `NeuralOperad` — typeclass capturing operadic structure of neural modules
* `NeuralLayer` — parameterized affine-activation maps with Lipschitz certification
* `OperadicExpression` — tree-structured operadic expressions (free operad elements)
* `DepthSeparationWitness` — certified depth separation between architectures
* `ApproximationCertificate` — operadic approximation with error and Lipschitz bounds
* `OperadicRankBound` — combined rank + Lipschitz robustness certificate
* `operadicLipschitz` — compositional Lipschitz constant computation

### Theorems (35+ proved, zero sorry)
* Neural operad identity, associativity, and Σ₂-equivariance axioms
* Depth separation via generator count and depth-width product
* Lipschitz-certified compositional robustness bounds (L^k for depth k)
* Universal approximation certificates with operadic rate bounds
* Tropical operadic bridge: linear regions and piecewise-linear analysis
* Robustness-expressivity tradeoff theorem
* Parallel vs sequential architecture comparison

## Bridge: connects algebraic topology (operads) → ML (neural networks) →
   analysis (Lipschitz continuity) → cryptography (certified robustness) →
   tropical geometry (piecewise-linear maps) → complexity theory (circuit depth)
-/

noncomputable section

open NNReal

/-! ## I. Core Algebraic Structures -/

/-- `NeuralOperad`: A typeclass capturing the operadic structure of parameterized
    computation modules. Each arity `n` has an associated type of n-input operations,
    with composition satisfying identity and associativity.

    Bridge: connects category theory (operadic composition) to ML (layer stacking). -/
class NeuralOperad (Op : ℕ → Type*) where
  /-- The identity operation -/
  id_op : Op 1
  /-- Operadic composition -/
  compose : {m : ℕ} → Op m → (Fin m → Op 1) → Op m
  /-- Left identity law -/
  compose_id_left : ∀ {m : ℕ} (f : Op m), compose f (fun _ => id_op) = f
  /-- Right identity law -/
  compose_id_right : ∀ (f : Op 1), compose id_op (fun _ => f) = f

/-- `NeuralLayer`: A parameterized affine map ℝⁿ → ℝᵐ composed with activation,
    equipped with a Lipschitz bound for certified robustness.

    Bridge: connects ML (neural layers) to analysis (Lipschitz continuity)
    to cryptography (adversarial robustness certification). -/
structure NeuralLayer (n m : ℕ) where
  /-- Weight matrix entries -/
  weights : Fin m → Fin n → ℝ
  /-- Bias vector -/
  bias : Fin m → ℝ
  /-- Lipschitz constant of the activation function -/
  activationLipschitz : NNReal
  /-- The Lipschitz constant is positive -/
  lipschitz_pos : (0 : NNReal) < activationLipschitz

/-- `OperadicExpression`: A tree-structured expression in the free operad,
    representing a composed neural architecture.

    Bridge: connects algebraic topology (free operads) to ML (architecture design)
    to computational complexity (circuit depth). -/
inductive OperadicExpression where
  | generator : OperadicExpression
  | identity : OperadicExpression
  | compose : OperadicExpression → OperadicExpression → OperadicExpression
  | parallel : OperadicExpression → OperadicExpression → OperadicExpression
  deriving Repr, BEq

namespace OperadicExpression

/-- The depth of an operadic expression: length of the longest sequential chain.
    Parallel composition takes max (branches run concurrently). -/
def depth : OperadicExpression → ℕ
  | generator => 1
  | identity => 0
  | compose e₁ e₂ => e₁.depth + e₂.depth
  | parallel e₁ e₂ => max e₁.depth e₂.depth

/-- The generator count: total number of generator nodes.
    This is the algebraic analog of parameter block count. -/
def generatorCount : OperadicExpression → ℕ
  | generator => 1
  | identity => 0
  | compose e₁ e₂ => e₁.generatorCount + e₂.generatorCount
  | parallel e₁ e₂ => e₁.generatorCount + e₂.generatorCount

/-- Width = generator count (defined separately for conceptual clarity). -/
def width : OperadicExpression → ℕ
  | generator => 1
  | identity => 0
  | compose e₁ e₂ => e₁.width + e₂.width
  | parallel e₁ e₂ => e₁.width + e₂.width

/-- The depth-width product: key combined invariant for approximation rate. -/
def depthWidthProduct (e : OperadicExpression) : ℕ :=
  e.depth * e.generatorCount

end OperadicExpression

/-! ## II. Certified Structures -/

/-- `OperadicRankBound`: Combined rank + Lipschitz robustness certificate.

    Bridge: connects ML model complexity to adversarial robustness
    to post-quantum security (Lipschitz hash functions). -/
structure OperadicRankBound where
  rankBound : ℕ
  lipschitzBound : NNReal
  lipschitz_pos : (0 : NNReal) < lipschitzBound

/-- `DepthSeparationWitness`: Certificate that two architectures at
    different depths have provably different expressivity. -/
structure DepthSeparationWitness (k₁ k₂ : ℕ) where
  shallow : OperadicExpression
  deep : OperadicExpression
  shallow_depth : shallow.depth = k₁
  deep_depth : deep.depth = k₂
  rank_gap : deep.generatorCount > shallow.generatorCount

/-- `ApproximationCertificate`: Operadic approximation with error and Lipschitz bounds. -/
structure ApproximationCertificate where
  expression : OperadicExpression
  errorBound : ℝ
  error_pos : 0 < errorBound
  lipschitzConst : NNReal

/-! ## III. k-Deep Expressions -/

/-- Composing k generators sequentially: the canonical depth-k architecture. -/
def kDeepExpression : ℕ → OperadicExpression
  | 0 => .identity
  | k + 1 => .compose .generator (kDeepExpression k)

/-- A wide parallel arrangement of n generators (depth 1, width n). -/
def wideParallel : ℕ → OperadicExpression
  | 0 => .identity
-- ... (truncated, full file has 631 lines)
```

            ---

            You are Aristotle. Pursue this research direction deeply and originally.
            Discover what matters. Prove what you can. Define what needs defining.
            Build on the catalog theorems referenced above.

            Use concrete types (Nat, Real, Finset, Matrix). Avoid trivial tautologies.
            If a direct proof fails, try the contrapositive, a constructive witness,
            or structural induction. Connect to at least one other domain for impact.

            Required: Lean 4 proofs, FUTURE_DIRECTIONS.md
            Optional: ARTICLE.md, RESEARCH_PAPER.md, demo.py, diagram.svg

            FUTURE_DIRECTIONS.md is critical — it drives the next research cycle.
            Structure it with specific theorem statements, proof strategies, and
            cross-domain connections.


### WHAT WE NEED FROM YOU

You are a world-class mathematician, software engineer, and science writer.
Use your judgment on the best way to organize and present your work.
We need ALL of the following deliverables:

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 1 — Formally verified mathematics (Lean 4)
────────────────────────────────────────────────────────────────────────────
- Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
- Organize the code however makes sense — one file or several,
  whatever serves the mathematics best
- Use doc comments to explain the significance of key results

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 2 — Standalone Popular-Science ARTICLE  →  ARTICLE.md
────────────────────────────────────────────────────────────────────────────
Write a **superb, standalone magazine-quality article** about this research.

CRITICAL RULES FOR THE ARTICLE:
• Do NOT mention "Scientific American", "Sci Am", or "Lean" anywhere.
• Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
• This is a POPULAR SCIENCE article for a curious, intelligent audience.
  Write it as if it will be published in a premier science magazine.
• The reader should come away saying "Wow, I had no idea math could do THAT."

ARTICLE QUALITY STANDARDS:
• **Superb writing**: Vivid, engaging prose. Strong opening hook. Narrative arc.
  Use concrete analogies and metaphors that make abstract ideas tangible.
• **Depth without jargon**: Explain the IDEAS, not the formalism.
  A reader with a college education should understand and enjoy every paragraph.
• **Story structure**: Open with a provocative question or surprising fact.
  Build tension. Reveal the breakthrough. Show why it matters.
• **Real-world connections**: Connect to technology, nature, everyday life.
  Why should a non-mathematician care about this?
• **Historical context**: Place the discovery in the sweep of intellectual history.
  Who tried this before? What barriers stood in the way?
• **Length**: 1500–3000 words. Substantial but not padded.
• **Standalone**: The article must make complete sense on its own.
  No references to "the proof above" or "our formal verification."

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 3 — Comprehensive RESEARCH PAPER  →  RESEARCH_PAPER.md
────────────────────────────────────────────────────────────────────────────
Write a **thorough, in-depth research paper** that a mathematician or
graduate student would find valuable. This is NOT a summary — it is a
complete, publishable-quality paper.

RESEARCH PAPER REQUIREMENTS:
• **Abstract**: Concise summary of contributions and significance.
• **Introduction**: Motivation, context, relationship to prior work.
• **Definitions & Notation**: Precise mathematical setup.
• **Main Results**: Full theorem statements with detailed proof sketches.
  Include the key ideas, not just "by induction."
• **Algorithms**: If the work produces algorithms, include complete
  pseudocode with complexity analysis (time, space, convergence).
• **Applications**: Concrete applications with worked examples.
  Show HOW to use the results in practice.
• **Computational Experiments**: Reference the Python demos.
  Include tables, charts, or numerical results.
• **Discussion**: Implications, limitations, open questions.
• **Future Work**: Specific, actionable next steps.
• **References**: Cite relevant prior work properly.
• **Length**: 3000–8000 words. Comprehensive and substantive.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — JSON Data Package  →  PACKAGE.json
────────────────────────────────────────────────────────────────────────────
Create a **single JSON file** that bundles ALL artifacts for the web templating system.
Requirements:

• **Structure**: Output a strictly valid JSON object matching this schema:
  {
    "title": "Title of the Research",
    "domain": "Mathematical Domain",
    "article": "Markdown content...",
    "research_paper": "Markdown content...",
    "future_directions": "Markdown content...",
    "demos": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files like 'algorithms'" } ],
    "algorithms": [ { "name": "...", "pseudocode": "..." } ],
    "visualizations": [ { "name": "...", "data": "base64 encoded URI or inline SVG string" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Embedded images**: ALL images (charts, diagrams, visualizations) MUST be
  embedded directly in the JSON. If you generate matplotlib/plotly figures, convert them to base64
  data URIs (e.g., `data:image/png;base64,...`). For SVG diagrams, put the raw `<svg>...</svg>`
  string into the `data` field. NEVER reference external image files.
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Bridges
Research mode: formalize
