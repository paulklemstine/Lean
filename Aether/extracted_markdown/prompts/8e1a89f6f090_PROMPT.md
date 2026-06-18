## Assignment: Algebra–EML–MachineLearning Closure Barron Duality via Idempotent Dependency Semimodules and Certified Sparse Concept Reconstruction

**Mode:** prove

Prove a genuinely new finite duality theorem that turns closure geometry into an interpretable sparse learning theory. The breakthrough is to show that finite closure systems admit a Barron/atomic-norm style representation theory in which monotone functionals on closed sets are exactly sparse sup-combinations of closure-atoms, with a reconstruction theorem sending the representation back to a weighted closure geometry. This is not a tropical variant. The novelty is that the atomic objects are determined by **closure irreducibility and dependency cuts**, and the norm is an **idempotent dependency variation** intrinsic to the closure lattice.

The target is to create a new bridge:

- **Algebra / lattice theory**: finite closure systems, join-irreducibles, canonical join representations, closure irreducibles
- **EML / idempotent mathematics**: semimodules over join-plus or max-plus style semirings, atomic variation norms
- **Machine learning**: sparse concept networks, exact support recovery, interpretable hidden units, certified reconstruction

This should feel like the closure-theoretic analogue of atomic Barron spaces, but with the geometry coming from finite closure lattices rather than Euclidean harmonics or tropical linear forms.

---

## Precise theorem target

Let `C` be a finite closure system on a finite ground type `X`, with lattice of closed sets `ClosedSet C`. Let `JI(C)` denote the join-irreducible closed sets. Define closure-atoms as monotone indicator-like functionals detecting principal dependency cuts; the most formalizable version is to take atoms indexed by join-irreducibles:
- for `j : JoinIrred C`, define `atom j : ClosedSet C → ℝ≥0∞` by
  `atom j K = if j ≤ K then 1 else 0`.

Then define the closure-variation of a monotone functional `f : ClosedSet C → ℝ≥0∞` as the infimum/minimum total weight of a sup-combination
\[
f(K)=\sup_{j\in JI(C)} w_j \otimes atom_j(K),
\]
or, in the order-theoretic version more likely to formalize cleanly,
\[
f(K)=\sup \{ w_j \mid j \in JI(C),\ j \le K\}.
\]

The canonical theorem should be stated with enough precision that Aristotle can formalize it in stages.

### Primary representation theorem
For a finite closure system whose closed sets form a finite distributive lattice, every monotone functional is represented by join-irreducible atoms, with canonical weights given by Möbius-free order extraction:
\[
w_j = f(j) \quad \text{or} \quad w_j = f(j)\setminus \sup_{i<j}w_i
\]
depending on the exact atom definition.

A strong formal target:

```lean
theorem finite_closure_barron_representation
  {X : Type _} [Fintype X] [DecidableEq X]
  (C : FiniteClosureSystem X)
  (hdist : IsDistributive (ClosedSet C))
  (f : ClosedSet C → ℝ≥0∞)
  (hmono : Monotone f) :
  ∃ (A : Finset (JoinIrred C)) (w : JoinIrred C → ℝ≥0∞),
    (∀ j, j ∉ A → w j = 0) ∧
    (∀ K : ClosedSet C,
      f K = iSup (fun j : JoinIrred C => if (j : ClosedSet C) ≤ K then w j else 0)) ∧
    A.card ≤ Fintype.card (JoinIrred C)
```

This theorem says every monotone closure-functional has a finite atomic decomposition over closure-extreme generators.

### Canonical support / minimality theorem
You should then prove that there is a **canonical minimal support** under an anti-chain separation or strict irredundancy hypothesis.

```lean
theorem finite_closure_barron_canonical_support
  {X : Type _} [Fintype X] [DecidableEq X]
  (C : FiniteClosureSystem X)
  (hdist : IsDistributive (ClosedSet C))
  (f : ClosedSet C → ℝ≥0∞)
  (hmono : Monotone f)
  (hsep : AntichainSeparation C f) :
  ∃! (A : Finset (JoinIrred C)) (w : JoinIrred C → ℝ≥0∞),
    SparseRep C f A w ∧ MinimalSupport C f A w
```

The point is not merely existence, but uniqueness of the interpretable hidden units.

### Reconstruction theorem
From a sparse concept network built from closure-atoms, reconstruct the weighted closure geometry up to dependency isomorphism.

```lean
theorem closure_network_reconstruction
  {X : Type _} [Fintype X] [DecidableEq X]
  (C : FiniteClosureSystem X)
  (hdist : IsDistributive (ClosedSet C))
  (N : SparseConceptNetwork C)
  (hreal : RealizesClosureAtoms C N) :
  ∃ C' : WeightedClosureSystem X,
    DependencyIso C.toWeighted C' ∧
    NetworkInducedFunctional N = WeightedClosureFunctional C'
```

This is the ML-facing half: sparse hidden units are not arbitrary parameters; they encode a closure geometry.

### Duality theorem
Bundle the above into a finite equivalence between weighted closure systems and sparse concept networks.

```lean
theorem finite_closure_barron_duality
  {X : Type _} [Fintype X] [DecidableEq X]
  (C : FiniteClosureSystem X)
  (hdist : IsDistributive (ClosedSet C)) :
  ∃ Φ : WeightedClosureFunctional C ≃ SparseConceptNetwork C,
    (∀ f, CertifiedSparse (Φ f)) ∧
    (∀ N, ReconstructsUniquely C (Φ.symm N))
```

If full equivalence is too ambitious for one cycle, first prove a pair of inverse-up-to-isomorphism maps.

---

## Why this is a breakthrough

This would create the first rigorous **atomic representation theory for closure functionals** analogous to Barron spaces, but in a finite idempotent/lattice setting. It says:

1. **Interpretability is geometric**: hidden units correspond to join-irreducible dependency generators.
2. **Sparsity is intrinsic**: support size is controlled by the closure lattice, not by arbitrary architecture choices.
3. **Reconstruction is exact**: the learned sparse model determines an underlying dependency geometry.
4. **Certification becomes combinatorial**: exact recovery can be verified on a finite generating family of closed sets.

This opens a field where closure systems become a native language for interpretable concept learning, dependency extraction, symbolic ML, and idempotent representation theory.

---

## Recommended formal architecture in Lean

Define things in the most order-theoretic way possible. Avoid premature semiring abstraction if it slows proof flow.

### Stage 1: finite closure lattice interface
Create or reuse:
- `FiniteClosureSystem X`
- `ClosedSet C`
- lattice structure on `ClosedSet C`
- `JoinIrred C := {K : ClosedSet C // JoinIrreducible K}`

If `ClosedSet C` is hard to make distributive globally, parameterize by a finite distributive lattice `L` first, and only later instantiate `L := ClosedSet C`.

### Stage 2: atomic representation
Define:

```lean
def closureAtom (j : JoinIrred C) : ClosedSet C → ℝ≥0∞ :=
  fun K => if (j : ClosedSet C) ≤ K then 1 else 0
```

or better for sup-decomposition:

```lean
def closureAtomEval (w : JoinIrred C → ℝ≥0∞) (K : ClosedSet C) : ℝ≥0∞ :=
  iSup (fun j : JoinIrred C => if (j : ClosedSet C) ≤ K then w j else 0)
```

Define sparse representation:

```lean
def SparseRep
  (C : FiniteClosureSystem X)
  (f : ClosedSet C → ℝ≥0∞)
  (A : Finset (JoinIrred C))
  (w : JoinIrred C → ℝ≥0∞) : Prop :=
  (∀ j, j ∉ A → w j = 0) ∧
  ∀ K, f K = iSup (fun j : JoinIrred C => if (j : ClosedSet C) ≤ K then w j else 0)
```

### Stage 3: variation norm
Since the space is finite, define variation as a minimum over finitely supported weights rather than an infimum over all decompositions.

```lean
def ClosureVariation
  (C : FiniteClosureSystem X)
  (f : ClosedSet C → ℝ≥0∞) : ℝ≥0∞ :=
  sInf {t | ∃ A w, SparseRep C f A w ∧ t = ∑ j in A, w j}
```

Later prove the infimum is attained by finiteness.

### Stage 4: certified reconstruction
Define a generating family of probes, ideally the join-irreducibles themselves or principal closed sets, and prove values on this family determine the full function.

```lean
def CertifyingFamily (C : FiniteClosureSystem X) := Finset (ClosedSet C)

def CertifiedReconstruction
  (C : FiniteClosureSystem X)
  (f : ClosedSet C → ℝ≥0∞) : Prop :=
  ∃ G : CertifyingFamily C,
    ∀ g, (∀ K ∈ G, g K = f K) → g = f
```

Then show `G = univ` over join-irreducibles suffices in the distributive case.

---

## Proof strategy options

### Strategy A: Birkhoff representation of finite distributive lattices
**Most promising.**

If `ClosedSet C` is finite distributive, Birkhoff says every closed set is the join of the join-irreducibles below it. Then monotonicity implies:
\[
f(K)
\]
is determined by the values of `f` on the join-irreducibles below `K`, and you can engineer the canonical weights from these values.

Concrete steps:
1. Prove every `K : ClosedSet C` equals the finite join of `j ≤ K` with `j` join-irreducible.
2. Define canonical weights on join-irreducibles by order extraction.
3. Show the induced sup-functional equals `f` on all closed sets by induction over the finite lattice order.
4. Prove support bound and minimality from irredundancy of canonical join representations.

Why this is strongest: it converts the whole theorem into finite lattice combinatorics, where Lean is happiest.

### Strategy B: Möbius inversion on the poset of closed sets
Potentially deeper, but heavier.

Interpret `f` as a monotone capacity on the finite poset `ClosedSet C`. Define atomic coefficients via Möbius inversion, then show monotonicity plus idempotent positivity forces support onto join-irreducibles/extreme cuts.

Concrete steps:
1. Equip `ClosedSet C` with incidence algebra data.
2. Define coefficients by Möbius inversion of `f`.
3. Prove positivity/extremality criteria collapse support to closure-atoms.
4. Deduce uniqueness from invertibility of incidence transform.

Why use it: this would connect directly to capacities, Choquet-style ideas, and explain the Barron analogy at a deeper level. But it may be more than one cycle.

### Strategy C: Greedy sparse extraction by maximal violated irreducible
Algorithmic and ML-friendly.

Construct the representation iteratively:
1. Start with zero approximation.
2. Choose a maximal join-irreducible where current approximation underestimates `f`.
3. Add the minimal correcting weight.
4. Prove termination by finite descent and certify exactness.
5. Under anti-chain separation, prove the greedy support is unique/minimal.

Why use it: this yields the certified reconstruction pipeline directly and is ideal for later extraction into algorithms. It may be the best route for the reconstruction theorem after Strategy A establishes existence.

**Recommendation:** Use Strategy A for the representation theorem, then Strategy C for certified reconstruction and support minimality.

---

## Cross-domain connections you should exploit explicitly

### 1. Finite distributive lattices ↔ interpretable neural architectures
Join-irreducibles play the role of **hidden neurons**.
Closed sets play the role of **concept states**.
Sup-combination over atoms is a **monotone max-aggregation network**.

This is a mathematically clean concept-network semantics: hidden units are not heuristic features but irreducible dependency generators.

### 2. Idempotent semimodules ↔ atomic norms / Barron spaces
The decomposition over closure-atoms is the idempotent analogue of:
- Barron atomic expansions,
- dictionary learning,
- sparse coding.

But here the dictionary is canonical and geometry-induced. This is the real novelty.

### 3. Closure theory ↔ formal concept analysis / knowledge extraction
Closure systems encode implicational theories and concept lattices. Your theorem would imply that sparse predictors over concept lattices are equivalent to weighted dependency structures. This suggests exact recovery of symbolic rules from trained sparse networks.

### 4. Matroid and antimatroid shadows
If this works first for distributive closure lattices, the next frontier is:
- convex geometries / antimatroids,
- matroid flats,
- greedoids.

That would turn combinatorial geometries into learnable sparse concept spaces.

### 5. EML physics analogy
Weighted dependency propagation on closure systems resembles energy propagation through constrained state spaces. The variation norm behaves like a finite idempotent action functional. This is a promising bridge to EML-inspired statistical mechanics over knowledge states.

---

## Concrete theorem refinements worth proving if possible

### Exact recovery from generator evaluations
Show that `f` is determined by its values on join-irreducibles.

```lean
theorem monotone_functional_determined_by_join_irreducibles
  {X : Type _} [Fintype X] [DecidableEq X]
  (C : FiniteClosureSystem X)
  (hdist : IsDistributive (ClosedSet C))
  {f g : ClosedSet C → ℝ≥0∞}
  (hf : Monotone f) (hg : Monotone g)
  (hJI : ∀ j : JoinIrred C, f j = g j) :
  f = g
```

If this exact statement is false under your chosen atom semantics, weaken to equality for the induced atomic reconstructions.

### Support bound by join-irreducibles
```lean
theorem sparse_support_bound
  {X : Type _} [Fintype X] [DecidableEq X]
  (C : FiniteClosureSystem X)
  (f : ClosedSet C → ℝ≥0∞) :
  ∀ {A w}, SparseRep C f A w →
    A.card ≤ Fintype.card (JoinIrred C)
```

### Canonical decomposition from finite variation
```lean
theorem finite_variation_implies_sparse_atomic
  {X : Type _} [Fintype X] [DecidableEq X]
  (C : FiniteClosureSystem X)
  (hdist : IsDistributive (ClosedSet C))
  (f : ClosedSet C → ℝ≥0∞)
  (hmono : Monotone f)
  (hvar : ClosureVariation C f < ∞) :
  ∃ A w, SparseRep C f A w ∧
    (∑ j in A, w j) = ClosureVariation C f
```

This is the closest to the Barron-language framing.

---

## Important caution: sharpen the statement so it is true

As written, “every monotone closure-functional” may be too broad for exact sup-atomic representation depending on atom definition. You likely need one of:

1. `ClosedSet C` finite distributive and atoms defined by join-irreducibles with the induced representation class;
2. `f` preserves finite joins into sup:
   \[
   f(K \vee L)=\max(f(K),f(L)),
   \]
   i.e. `SupHom`-type monotone functionals;
3. or define the variation/decomposition class so that representability is built into `FiniteClosureVariation`.

The most robust theorem is:

- characterize **join-sup-homomorphic** monotone functionals exactly as sup-combinations of join-irreducible atoms;
- then prove every finite-variation functional belongs to this class by definition or additional hypotheses.

A cleaner Lean theorem may therefore be:

```lean
theorem closure_sup_hom_barron_duality
  {X : Type _} [Fintype X] [DecidableEq X]
  (C : FiniteClosureSystem X)
  (hdist : IsDistributive (ClosedSet C))
  (f : ClosedSet C → ℝ≥0∞)
  (hmono : Monotone f)
  (hsup : ∀ K L, f (K ⊔ L) = max (f K) (f L)) :
  ∃! w : JoinIrred C → ℝ≥0∞,
    ∀ K : ClosedSet C,
      f K = iSup (fun j : JoinIrred C => if (j : ClosedSet C) ≤ K then w j else 0)
```

This statement is elegant, likely true, and powerful.

---

## Build on catalog-style ingredients

Use any existing catalog lemmas about:
- finite lattice induction,
- closure operators and Galois insertions,
- join-irreducibles in finite distributive lattices,
- finitely supported `iSup` / `Finset.sup`,
- monotone maps on finite orders,
- exact reconstruction from generators.

If there are prior closure-matroid or EML-physics files, mine them for:
- closure irreducible definitions,
- dependency extraction patterns,
- finite support constructions,
- “certified” theorem styles that package existence + algorithmic witness.

The key is not to re-prove basic finite-lattice machinery if Mathlib already has it.

---

## Deliverables

1. A Lean file proving the strongest correct version of the representation theorem.
2. A second theorem proving canonical/minimal support under an anti-chain separation hypothesis.
3. A reconstruction theorem from sparse concept networks to weighted closure systems up to dependency isomorphism.
4. Minimal `sorry` footprint; if a theorem is too strong, weaken cleanly but preserve the duality vision.
5. A `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, such as:
   - extension from distributive closure lattices to semidistributive or antimatroid closures,
   - closure-Möbius inversion and Choquet-type capacities,
   - sample complexity / exact recovery guarantees for sparse concept reconstruction,
   - categorical duality between closure semimodules and interpretable monotone networks,
   - statistical mechanics or information-theoretic invariants of weighted closure geometries.

---

## Application keywords

closure systems, finite distributive lattices, join-irreducibles, Barron duality, atomic decomposition, idempotent semimodules, sparse concept networks, interpretable machine learning, exact recovery, formal concept analysis, dependency geometry, certified reconstruction, monotone networks, algebraic machine learning, EML, symbolic learning, closure-based representation theory

### Catalog Reference Files
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

@AutoResearch/CompactTropicalChoquetRadon.lean
```lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Compact Tropical Choquet–Radon Representation

This file formalizes a Choquet–Radon representation theorem for upper-continuous
max-plus linear functionals on continuous real-valued functions over a compact
Hausdorff space.

## Main definitions

* `UCTropicalFunctional` — A structure encoding an upper-continuous, max-plus linear
  functional on `C(X, ℝ)` with values in `EReal`.
* `compactCapacity` — The compact-set capacity extracted from a functional.
* `infOnCompact` — The infimum of a continuous function on a compact set.
* `tropSupport` — The support of a tropical functional (smallest closed carrier).
* `supportedOn` — Predicate for a functional being supported on a set.
* `pushforwardFunctional` — Pushforward of a tropical functional along a continuous map.

## Main results

* `compactCapacity_empty` — Capacity of the empty compact set is ⊥.
* `compactCapacity_mono` — Capacity is monotone (larger sets, larger capacity).
* `compactCapacity_union` — Capacity is maxitive: `μ(K ∪ L) = max(μ(K), μ(L))`.
* `infOnCompact_le_eval` — The infimum on a compact set is bounded by point evaluation.
* `tropical_choquet_radon_le` — One direction of the representation:
    `⊔_K (μ(K) + inf_K f) ≤ Λ(f)`.
* `isClosed_tropSupport` — The tropical support is closed.
* `tropSupport_supported` — The functional is supported on its tropical support.
* `tropSupport_minimal` — The tropical support is the smallest closed carrier.
* `compactCapacity_pushforward_le` — Capacity is functorial under pushforward.

## Mathematical overview

In max-plus (tropical) algebra, addition is `max` and multiplication is `+`.
A max-plus linear functional Λ on continuous functions satisfies:
- `Λ(f ⊔ g) = Λ(f) ⊔ Λ(g)` (preserves tropical addition = max)
- `Λ(f + c) = Λ(f) + c` (equivariant under tropical scalar action = real translation)

The Choquet–Radon representation expresses such a functional as a "max-plus integral":
  `Λ(f) = ⊔_K (μ(K) + inf_K f)`
where `μ` is a maxitive capacity on compact sets.
-/

noncomputable section

open TopologicalSpace Set EReal

/-! ### The functional structure -/

/-- An upper-continuous tropical (max-plus linear) functional on `C(X, ℝ)`,
taking values in `EReal` (extended reals with ±∞).

The axioms encode:
- `monotone'`: monotonicity with respect to pointwise order
- `sup_preserving'`: max-plus additivity `Λ(f ⊔ g) = max(Λ(f), Λ(g))`
- `shift_equivariant'`: tropical scalar action `Λ(f + c) = Λ(f) + c`
- `normalized'`: normalization `Λ(0) = 0`

The upper-continuity axiom (`top_continuous'`) states that Λ commutes with
directed suprema of continuous functions, provided the supremum is itself continuous.
-/
structure UCTropicalFunctional (X : Type*) [TopologicalSpace X]
    [CompactSpace X] [T2Space X] where
  /-- The underlying function from continuous maps to extended reals. -/
  toFun : C(X, ℝ) → EReal
  /-- The functional is monotone. -/
  monotone' : Monotone toFun
  /-- The functional preserves binary suprema (max-plus additivity). -/
  sup_preserving' : ∀ f g : C(X, ℝ), toFun (f ⊔ g) = toFun f ⊔ toFun g
  /-- The functional is equivariant under translation by real constants. -/
  shift_equivariant' : ∀ (c : ℝ) (f : C(X, ℝ)),
    toFun (f + ContinuousMap.const X c) = toFun f + (c : EReal)
  /-- Upper continuity: Λ commutes with monotone suprema of continuous functions,
      provided the supremum is itself continuous. -/
  top_continuous' : ∀ {ι : Type*} [Nonempty ι] [Preorder ι] (s : ι → C(X, ℝ))
    (f : C(X, ℝ)),
    (∀ x, f x = ⨆ i, (s i x : EReal)) →
    Monotone s →
    toFun f = ⨆ i, toFun (s i)
  /-- Normalization: the zero function maps to zero. -/
  normalized' : toFun 0 = 0

variable {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]

namespace UCTropicalFunctional

instance : CoeFun (UCTropicalFunctional X) (fun _ => C(X, ℝ) → EReal) :=
  ⟨toFun⟩

@[simp]
theorem coe_toFun (Λ : UCTropicalFunctional X) (f : C(X, ℝ)) :
    Λ f = Λ.toFun f := rfl

theorem monotone (Λ : UCTropicalFunctional X) : Monotone Λ.toFun :=
  Λ.monotone'

theorem sup_preserving (Λ : UCTropicalFunctional X) (f g : C(X, ℝ)) :
    Λ (f ⊔ g) = Λ f ⊔ Λ g :=
  Λ.sup_preserving' f g

theorem shift_equivariant (Λ : UCTropicalFunctional X) (c : ℝ) (f : C(X, ℝ)) :
    Λ (f + ContinuousMap.const X c) = Λ f + (c : EReal) :=
  Λ.shift_equivariant' c f

theorem normalized (Λ : UCTropicalFunctional X) :
    Λ 0 = 0 := Λ.normalized'

/-- The functional maps constant functions to the constant. -/
theorem map_const (Λ : UCTropicalFunctional X) (c : ℝ) :
    Λ (ContinuousMap.const X c) = (c : EReal) := by
  have h := Λ.shift_equivariant c 0
  simp [Λ.normalized] at h
  exact h

/-- As constants decrease to -∞, the functional value goes to ⊥. -/
theorem map_const_neg_iInf (Λ : UCTropicalFunctional X) :
    ⨅ (n : ℕ), Λ (ContinuousMap.const X (-(n : ℝ))) = ⊥ := by
  simp [map_const]
  rw [iInf_eq_bot]
  intro b hb
  induction b with
    | bot => exact absurd rfl (ne_of_gt hb)
    | top => exact ⟨0, by simp⟩
    | coe r =>
      obtain ⟨n, hn⟩ := exists_nat_gt (-r)
      exact ⟨n, EReal.coe_lt_coe_iff.mpr (by linarith)⟩

end UCTropicalFunctional

/-! ### Compact-set capacity -/

/-- The compact-set capacity extracted from a tropical functional.
    `compactCapacity Λ K` is the infimum of `Λ(f)` over all continuous functions `f`
    that are nonneg (≥ 0) on `K`. -/
def compactCapacity (Λ : UCTropicalFunctional X) (K : Compacts X) : EReal :=
  sInf {a : EReal | ∃ f : C(X, ℝ), (∀ x ∈ (K : Set X), (0 : ℝ) ≤ f x) ∧ a = Λ.toFun f}

/-- The infimum of a continuous function over a compact set.
    When `K` is empty, this is `⊤` by convention (infimum of empty set). -/
def infOnCompact (f : C(X, ℝ)) (K : Compacts X) : EReal :=
  ⨅ x ∈ (K : Set X), (f x : EReal)

/-! ### Basic capacity properties -/

/-- Helper: the defining set for compactCapacity is nonempty. -/
-- ... (truncated, full file has 459 lines)
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
    "algorithms": [ { "name": "...", "pseudocode": "...", "code": "executable Python implementation" } ],
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
Research mode: prove
