## Assignment: Algebra–Tropical–Cryptography  
## Tropical One-Way Rank–Factorization Duality via Min-Plus Matrix Semimodules and Certified Trapdoor Witness Reconstruction

**Mode: prove**

Build a new theorem package in:

`Bridges/TropicalCryptography/TropicalOneWayRankFactorizationDuality.lean`

The target is not “another tropical factorization lemma.” The target is a **structural equivalence between witness-certified tropical products and canonical hidden-factor classes**, with a converse realizability theorem and a certified inversion algorithm. If formalized cleanly, this opens a new mathematical cryptography interface: **trapdoor data = tropical witness geometry**.

---

## Core Vision

Let \(S\) be the min-plus semiring on a finite bounded value domain (or on `ℤ`, `ℚ`, or a finite interval thereof, depending on what is easiest to formalize first). For matrices
\[
A \in S^{m \times r}, \qquad B \in S^{r \times n},
\]
define the tropical product
\[
C = \operatorname{tropMul}(A,B), \qquad
C_{ij} = \min_{k : \mathrm{Fin}\ r} (A_{ik} + B_{kj}).
\]
For each output entry \((i,j)\), define the witness set
\[
W_{ij} := \operatorname{argmin}_{k} (A_{ik}+B_{kj}).
\]
A **certified witness profile** augments \(W_{ij}\) by a positive gap certificate \(\gamma_{ij}\) ensuring strict separation between active and inactive hidden indices.

The breakthrough theorem should show:

1. **Reconstruction/Classifying theorem**: under finite separation + minimality/nondegeneracy, the witness profile together with \(C\) determines a **canonical factorization class** of \((A,B)\), unique up to the tropical gauge action
   \[
   A_{\bullet k} \mapsto A_{\bullet k}+t_k,\qquad
   B_{k\bullet} \mapsto B_{k\bullet}-t_k,
   \]
   and permutation of hidden indices \(k\).

2. **Realizability theorem**: every admissible witness profile satisfying a finite consistency system arises from a separated tropical factorization.

3. **Certified inversion theorem**: reconstruction reduces to solving a finite system of tropical difference constraints, yielding a canonical representative. This makes precise a **one-wayness gap**: forward multiplication is easy, but inversion without witness data is exactly a constrained tropical rank/factorization problem.

This is mathematically new because the hidden object is not a shortest path, divisor class, or isogeny datum, but a **witness geometry for tropical bilinear maps**. That is a new cryptographic primitive schema.

---

## Precise Theorem Targets

You should define the cleanest formalizable version first over finite index types:
- `ι = Fin m`
- `κ = Fin r`
- `ȷ = Fin n`

and matrices valued in `ℤ` or `ℚ` if possible.

### 1. Witness profile determines factorization class

A mathematically precise target:

> **Theorem (Certified tropical witness reconstruction, class form).**  
> Let \(A,A' : \mathrm{Matrix}\ (\mathrm{Fin}\ m)\ (\mathrm{Fin}\ r)\ S\) and  
> \(B,B' : \mathrm{Matrix}\ (\mathrm{Fin}\ r)\ (\mathrm{Fin}\ n)\ S\).  
> Assume:
> 1. \(C = \operatorname{tropMul}(A,B) = \operatorname{tropMul}(A',B')\),
> 2. \((A,B)\) and \((A',B')\) satisfy a strict separation condition with positive gap,
> 3. they have the same certified witness profile \(\omega\),
> 4. each hidden index \(k\) is minimal/essential (appears in some witness set and satisfies a support nonredundancy condition).
>
> Then there exists a permutation \(\sigma : \mathrm{Equiv.Perm}(\mathrm{Fin}\ r)\) and a gauge vector \(t : \mathrm{Fin}\ r \to S\) such that
> \[
> A'_{i,\sigma(k)} = A_{ik} + t_k,\qquad
> B'_{\sigma(k),j} = B_{kj} - t_k
> \]
> for all \(i,j,k\).

This is the core duality statement.

### 2. Converse realizability theorem

> **Theorem (Witness profile realizability).**  
> Let \(C : \mathrm{Matrix}\ (\mathrm{Fin}\ m)\ (\mathrm{Fin}\ n)\ S\) and let \(\omega\) be a finite witness profile \((W_{ij},\gamma_{ij})\).  
> Suppose \(\omega\) satisfies:
> 1. nonemptiness of each \(W_{ij}\),
> 2. compatibility of overlapping witness equalities,
> 3. strict inequality constraints for non-witness indices with margin \(\gamma_{ij} > 0\),
> 4. essentiality/minimality of hidden indices.
>
> Then there exist \(A,B\) such that
> \[
> C = \operatorname{tropMul}(A,B),
> \]
> the certified witness profile of \((A,B)\) is exactly \(\omega\), and \((A,B)\) is unique up to gauge/permutation after canonical normalization.

This theorem should characterize admissibility as satisfiability of a finite tropical difference-constraint system.

### 3. Canonical representative / algorithmic theorem

> **Theorem (Canonical normalized reconstruction).**  
> Under the assumptions above, there exists a unique normalized representative \((A^\*,B^\*)\) in the gauge class, e.g. satisfying
> \[
> \min_i A^\*_{ik} = 0 \quad \text{for each } k
> \]
> or another workable normalization, and \((A^\*,B^\*)\) is computable from \((C,\omega)\) by solving finite difference constraints.

This is the theorem that converts structure into an algorithm.

---

## Suggested Lean 4 Type Signatures

These signatures are intentionally ambitious but should be adapted to whatever tropical API you build.

```lean
def tropMul
  {m r n : ℕ}
  (A : Matrix (Fin m) (Fin r) ℤ)
  (B : Matrix (Fin r) (Fin n) ℤ) :
  Matrix (Fin m) (Fin n) ℤ := ...

def WitnessSet
  {m r n : ℕ}
  (A : Matrix (Fin m) (Fin r) ℤ)
  (B : Matrix (Fin r) (Fin n) ℤ)
  (i : Fin m) (j : Fin n) : Finset (Fin r) := ...

structure WitnessProfile (m r n : ℕ) where
  support : Fin m → Fin n → Finset (Fin r)
  gap     : Fin m → Fin n → ℤ

def realizesProfile
  {m r n : ℕ}
  (C : Matrix (Fin m) (Fin n) ℤ)
  (ω : WitnessProfile m r n)
  (A : Matrix (Fin m) (Fin r) ℤ)
  (B : Matrix (Fin r) (Fin n) ℤ) : Prop := ...

def gaugeEquivalent
  {m r n : ℕ}
  (A A' : Matrix (Fin m) (Fin r) ℤ)
  (B B' : Matrix (Fin r) (Fin n) ℤ) : Prop :=
  ∃ (σ : Equiv.Perm (Fin r)) (t : Fin r → ℤ),
    (∀ i k, A' i (σ k) = A i k + t k) ∧
    (∀ k j, B' (σ k) j = B k j - t k)

def normalized
  {m r n : ℕ}
  (A : Matrix (Fin m) (Fin r) ℤ)
  (B : Matrix (Fin r) (Fin n) ℤ) : Prop :=
  ∀ k, ∃ i, A i k = 0

theorem witness_profile_classifies_factorization
  {m r n : ℕ}
  (C : Matrix (Fin m) (Fin n) ℤ)
  (ω : WitnessProfile m r n)
  (A A' : Matrix (Fin m) (Fin r) ℤ)
  (B B' : Matrix (Fin r) (Fin n) ℤ) :
  realizesProfile C ω A B →
  realizesProfile C ω A' B' →
  separated_profile ω →
  essential_hidden_indices ω →
  minimal_factorization A B →
  minimal_factorization A' B' →
  gaugeEquivalent A A' B B' := ...

theorem witness_profile_realizable_iff_constraints_feasible
  {m r n : ℕ}
  (C : Matrix (Fin m) (Fin n) ℤ)
  (ω : WitnessProfile m r n) :
  admissibleProfile C ω ↔
    ∃ A B, realizesProfile C ω A B := ...

theorem normalized_reconstruction_unique
  {m r n : ℕ}
  (C : Matrix (Fin m) (Fin n) ℤ)
  (ω : WitnessProfile m r n) :
  admissibleProfile C ω →
  ∃! (AB : Matrix (Fin m) (Fin r) ℤ × Matrix (Fin r) (Fin n) ℤ),
    realizesProfile C ω AB.1 AB.2 ∧ normalized AB.1 AB.2 := ...
```

If subtraction in `ℤ` becomes awkward relative to semiring purity, you can first formulate over `ℤ` as the additive model of min-plus, then later package the semiring interpretation separately.

---

## Definitions You Need to Make Exact

### Tropical product
Define it concretely as:
```lean
C i j = Finset.univ.inf' ?h (fun k => A i k + B k j)
```
or via `sInf` on a finite set, depending on what is easier in Mathlib.

### Witness set
```lean
k ∈ WitnessSet A B i j  ↔  A i k + B k j = tropMul A B i j
```

### Separation / certified gap
A strong usable version:
```lean
def separatedAt (A) (B) (i) (j) (W : Finset (Fin r)) (γ : ℤ) : Prop :=
  (0 < γ) ∧
  (∀ k ∈ W, A i k + B k j = tropMul A B i j) ∧
  (∀ k ∉ W, tropMul A B i j + γ ≤ A i k + B k j)
```
Then package pointwise over all `i j`.

### Essential hidden index / minimality
A hidden index should not be ghost structure. A workable condition:
```lean
def essential_hidden_indices (ω : WitnessProfile m r n) : Prop :=
  ∀ k, ∃ i j, k ∈ ω.support i j
```
You likely need a stronger “distinguishability” condition to force uniqueness up to permutation. For instance, require each hidden index to have a distinct witness-incidence pattern or enough support geometry to identify it modulo permutation.

### Gauge normalization
Canonical normalization is critical. The simplest:
- for each hidden index `k`, set `min_i A i k = 0`.

Then `B` is forced accordingly once `C` and witnesses are known.

---

## Proof Strategy Architecture

## Strategy A: Constraint-graph rigidity via difference constraints  
**Most promising.**

Translate witness equalities/inequalities into a finite system on unknowns \(a_{ik}, b_{kj}\):

- If \(k \in W_{ij}\), impose
  \[
  a_{ik} + b_{kj} = C_{ij}.
  \]
- If \(k \notin W_{ij}\), impose
  \[
  a_{ik} + b_{kj} \ge C_{ij} + \gamma_{ij}.
  \]

Then analyze the equality subsystem as a bipartite incidence graph between row-hidden variables \(a_{ik}\) and hidden-column variables \(b_{kj}\). Gauge transformations are exactly connected-component shifts. Under essentiality + connectivity/nondegeneracy, all freedom is gauge/permutation only.

Concrete steps:
1. Build the linearized equality graph of variables \((i,k)\) and \((k,j)\).
2. Prove any two realizations differ by hidden-index-wise additive shifts on connected components.
3. Use separation + essentiality + profile matching to show components are indexed exactly by hidden indices, forcing uniqueness up to gauge and permutation.

Why this is promising: it converts tropical algebra into a **rigidity theorem for finite difference-constraint systems**, which Lean handles better than high-level tropical geometry.

---

## Strategy B: Tropical rank-1 decomposition through support hypergraphs

Interpret each hidden index \(k\) as generating a tropical rank-1 sheet
\[
M^{(k)}_{ij} = A_{ik} + B_{kj},
\qquad
C = \min_k M^{(k)}.
\]
The witness profile records which sheets are active at each cell. Then prove that a separated active-sheet arrangement determines the sheets uniquely up to gauge/permutation.

Concrete steps:
1. Formalize the decomposition into hidden tropical rank-1 sheets.
2. Show witness support determines pairwise differences of sheet values on overlaps.
3. Reconstruct each sheet from overlap propagation and normalize.

Why this is powerful: it reframes the theorem as a **stratified tropical hyperplane arrangement reconstruction problem**. This may later generalize to higher-order tensors and tropical secant varieties.

---

## Strategy C: Galois/duality viewpoint via semimodule residuation

Try to interpret reconstruction as a residuated inverse problem in min-plus semimodules: witnesses encode exact attainment of an infimum, while admissibility becomes closure under residuation constraints.

Concrete steps:
1. Define a semimodule relation between candidate factors and certified products.
2. Show witness profiles define a closure operator or Galois connection.
3. Derive uniqueness of the closed minimal representative.

Why this matters: if successful, this is the conceptual leap that could connect tropical cryptography to **order-theoretic semantics, abstract interpretation, and program verification**. It may be harder in Lean initially, but it is a profound second-phase theorem.

---

## Recommended Build Order

1. **Finite tropical product + witness set basics**
   - `k ∈ WitnessSet A B i j ↔ A i k + B k j = tropMul A B i j`
   - witness set nonempty over finite index types

2. **Certified profile formalization**
   - define `realizesProfile`
   - define `admissibleProfile`
   - prove profile extraction from separated factorization

3. **Gauge invariance**
   - prove `tropMul` is invariant under gauge shifts
   - prove witness sets are invariant under gauge shifts
   - prove permutation-equivariance

4. **Constraint reconstruction**
   - encode profile constraints
   - reconstruct one normalized pair from a feasible system
   - prove uniqueness of normalized representative

5. **Classifying theorem**
   - any two realizations are gauge/permutation equivalent

6. **Converse realizability**
   - admissibility iff feasibility iff realizability

---

## Building Blocks to Seek in Mathlib / Catalog

Use finite matrix infrastructure aggressively:
- `Matrix`
- finite indexing via `Fin`
- `Finset`
- graph/connectivity tools if useful
- integer arithmetic / order lemmas
- if available, shortest-path or difference-constraints lemmas can be repurposed

If the live catalog contains:
- tropical matrix multiplication lemmas,
- min-plus algebra infrastructure,
- certified gap/separation lemmas,
- shortest-path witness extraction,
- uniqueness up to additive gauge in semimodule settings,

then explicitly build on them rather than reproving from scratch. In particular, any theorem of the form “strict margin certifies active minimizer stability” is exactly the right local ingredient for the separation profile.

---

## Cross-Domain Connections You Should Exploit

### 1. Cryptography
This theorem formalizes a new trapdoor paradigm:

- **public map**: \( (A,B) \mapsto C = A \otimes B \)
- **trapdoor**: witness profile \(\omega\)
- **inversion with trapdoor**: canonical reconstruction by finite constraints
- **inversion without trapdoor**: tropical rank/factorization search

This creates a mathematically clean candidate for **witness-augmented one-way functions** in tropical algebra.

### 2. Tropical geometry
Witness sets define a combinatorial cell decomposition of output entries by active hidden sheets. This is analogous to:
- tropical hyperplane arrangements,
- regular subdivisions,
- active monomial structure in tropical polynomials.

Your theorem says this combinatorics plus separation can determine the factorization class.

### 3. Optimization / operations research
The reconstruction constraints are a finite system of difference inequalities, connecting to:
- Bellman–Ford feasibility,
- shortest-path duality,
- assignment structure,
- min-cost potentials.

This is important because it makes the inverse problem algorithmically concrete.

### 4. Explainable AI / latent-variable identifiability
The hidden index \(k\) behaves like a latent cause; witness profiles record which latent factor explains each observed output. The theorem is a tropical analogue of:
- latent variable identifiability,
- dictionary learning with certificates,
- sparse coding with support recovery.

### 5. Complexity theory
The no-witness inversion problem is a constrained tropical factorization problem. This suggests a route to formal complexity separations:
- easy forward evaluation,
- easy inversion with certificate,
- plausibly hard inversion without certificate.

That is a rigorous mathematical prototype for **certificate-driven asymmetry**.

---

## Revolutionary Significance

If you prove this cleanly, you are not just adding a lemma to tropical algebra. You are defining a **new cryptographic semantics for tropical factorization**.

This opens:
- tropical trapdoor constructions based on witness geometry,
- certified factorization protocols,
- zero-knowledge-style witness revelation questions,
- identifiability theory for tropical latent structures,
- tensor generalizations \(C_{ij\ell} = \min_k(A_{ik}+B_{kj}+D_{k\ell})\),
- hardness reductions from tropical rank and matrix factorization.

The field-opening claim is this:

> **Witness geometry, not merely tropical value data, is the hidden invariant that controls invertibility of min-plus bilinear maps.**

That is a new principle.

---

## Concrete Intermediate Lemmas Worth Proving

1. `gaugeEquivalent` preserves tropical products.
2. `gaugeEquivalent` preserves witness profiles.
3. Separated witness profiles have unique support sets.
4. Equality constraints from active witnesses determine all pairwise differences within a hidden component.
5. Normalization kills all gauge freedom.
6. Any two normalized realizations of the same admissible separated profile are permutation-equal.
7. Admissibility reduces to consistency of a finite difference-constraint graph.

A particularly useful finite lemma:

> If for fixed hidden index \(k\), the equalities
> \[
> a_{ik} + b_{kj} = C_{ij}
> \]
> hold on a connected incidence subgraph spanning all relevant \(i,j\), then after normalization the values \(a_{ik}, b_{kj}\) are uniquely determined.

This is the engine of the whole theorem.

---

## Application Keywords

`tropical cryptography`, `min-plus matrix factorization`, `witness reconstruction`, `trapdoor inversion`, `tropical rank`, `difference constraints`, `latent factor identifiability`, `semimodule gauge symmetry`, `certified inversion`, `tropical one-way functions`, `active minimizer geometry`, `finite rigidity`, `hypergraph reconstruction`

---

## Deliverables

1. Formalize the core definitions in  
   `Bridges/TropicalCryptography/TropicalOneWayRankFactorizationDuality.lean`

2. Prove at least one major theorem at full strength:
   - either `witness_profile_classifies_factorization`
   - or `normalized_reconstruction_unique`
   - or `witness_profile_realizable_iff_constraints_feasible`

3. Minimize `sorry` by first proving the integer-valued finite version.

4. Include a structured file:

`FUTURE_DIRECTIONS.md`

with **3–5 concrete breakthrough-level next steps**, such as:
- tensor/higher-arity tropical witness duality,
- hardness reductions from tropical rank,
- zero-knowledge witness-profile protocols,
- probabilistic/noisy witness certification,
- tropical secant-variety identifiability from certified active sets.

Be bold: the right theorem here is a new identifiability principle for tropical cryptography.

### Catalog Reference Files
@Speculative/AutoResearch/TropicalOneWayFunctions.lean
```lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical One-Way Functions and Min-Plus Cryptographic Primitives

## Bridge: Tropical Algebra ↔ Post-Quantum Cryptography ↔ Certified ML Robustness

The min-plus semiring (ℝ, min, +) harbors a deep computational asymmetry:
tropical matrix powering is computable in O(n³ log k), yet recovering k from
M and M^⊗k (the tropical discrete logarithm) appears to require Ω(2^n) time.

## Main Results (30+ theorems, 0 sorry)

### Algebraic Foundations
* `tropMul_assoc` — min-plus multiplication is associative
* `minplus_left_distrib` — tropical distributivity
* `minplus_idem` — min(a,a) = a

### Metric Theory & Lipschitz Bounds
* `tropDist_triangle` — triangle inequality for sup-norm
* `min_lipschitz_bound` — |min(a,c) - min(b,c)| ≤ |a - b|
* `tropLinMap_nonexpansive` — tropical linear maps are 1-Lipschitz

### Certified ML Robustness
* `certified_robustness_from_margin` — margin + Lipschitz ⟹ stable classification
* `certified_robustness_multivariate` — extends to ℝⁿ classifiers

### Cryptographic Primitives
* `tropical_security_exponential_gap` — n³ < 2ⁿ for n ≥ 10
* `tropical_idempotent_quantum_obstruction` — no cyclic group in idempotent monoid
* `tropical_post_quantum_framework` — master security chain
-/

noncomputable section

open Finset BigOperators

set_option maxHeartbeats 1600000
set_option linter.unusedVariables false

namespace TropicalOWF

/-! ## Section 1: Min-Plus Matrix Multiplication

(A ⊗ B)ᵢⱼ = min_k (Aᵢₖ + Bₖⱼ)

Bridge: graph theory (shortest paths) → tropical algebra → cryptography -/

/-- **Min-plus matrix multiplication** over `ℝ`.
    Bridge: connects shortest-path algorithms to tropical algebraic structure. -/
def tropMul {n : ℕ} (hn : 0 < n) (A B : Matrix (Fin n) (Fin n) ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  fun i j => Finset.univ.inf' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩)
    (fun k => A i k + B k j)

theorem tropMul_entry_le {n : ℕ} (hn : 0 < n) (A B : Matrix (Fin n) (Fin n) ℝ)
    (i j k : Fin n) : tropMul hn A B i j ≤ A i k + B k j :=
  Finset.inf'_le _ (Finset.mem_univ k)

theorem tropMul_exists_witness {n : ℕ} (hn : 0 < n) (A B : Matrix (Fin n) (Fin n) ℝ)
    (i j : Fin n) : ∃ k, tropMul hn A B i j = A i k + B k j := by
  obtain ⟨k, _, hk⟩ := Finset.exists_mem_eq_inf' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩)
    (fun k => A i k + B k j)
  exact ⟨k, hk⟩

/-- **Transpose anti-homomorphism.** (A ⊗ B)ᵀ = Bᵀ ⊗ Aᵀ. -/
theorem tropMul_transpose {n : ℕ} (hn : 0 < n) (A B : Matrix (Fin n) (Fin n) ℝ) :
    Matrix.transpose (tropMul hn A B) =
    tropMul hn (Matrix.transpose B) (Matrix.transpose A) := by
  ext i j; simp only [tropMul, Matrix.transpose_apply]; congr 1; ext k; ring

/-- **Min-plus products preserve entry bounds.** -/
theorem tropMul_preserves_bound {n : ℕ} (hn : 0 < n)
    (A B : Matrix (Fin n) (Fin n) ℝ) (MA MB : ℝ)
    (hA : ∀ i j, A i j ≤ MA) (hB : ∀ i j, B i j ≤ MB) :
    ∀ i j, tropMul hn A B i j ≤ MA + MB := by
  intro i j
  calc tropMul hn A B i j ≤ A i ⟨0, hn⟩ + B ⟨0, hn⟩ j :=
      tropMul_entry_le hn A B i j ⟨0, hn⟩
    _ ≤ MA + MB := add_le_add (hA _ _) (hB _ _)

/-
**Min-plus multiplication is associative.**
    Bridge: semigroup theory → tropical geometry → cryptographic group actions
-/
theorem tropMul_assoc {n : ℕ} (hn : 0 < n) (A B C : Matrix (Fin n) (Fin n) ℝ) :
    tropMul hn (tropMul hn A B) C = tropMul hn A (tropMul hn B C) := by
  -- By definition of min-plus multiplication, we have:
  funext i j;
  refine' le_antisymm _ _;
  · -- By definition of min-plus multiplication, we have that for any $i, j$, $(A \otimes B)_{ij} = \min_{k} (A_{ik} + B_{kj})$.
    simp [tropMul];
    intro b;
    obtain ⟨ k, hk ⟩ := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty_iff.mpr ⟨ b ⟩ ) ( fun k => B b k + C k j ) ; use k; simp_all +decide [ Finset.inf'_le ] ;
    linarith [ Finset.inf'_le ( fun k_1 => A i k_1 + B k_1 k ) ( Finset.mem_univ b ) ];
  · obtain ⟨ k, hk ⟩ := tropMul_exists_witness hn ( tropMul hn A B ) C i j;
    obtain ⟨ m, hm ⟩ := tropMul_exists_witness hn A B i k;
    refine' le_trans ( tropMul_entry_le hn A ( tropMul hn B C ) i j m ) _;
    linarith [ tropMul_entry_le hn B C m j k ]

/-! ## Section 2: Tropical Matrix Powers -/

/-- **Tropical identity matrix**: 0 on diagonal, T off-diagonal. -/
def tropId {n : ℕ} (T : ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  fun i j => if i = j then 0 else T

/-- **Tropical matrix power**: M^⊗k.
    Bridge: connects exponentiation in tropical semiring to cryptographic OWF. -/
def tropMatPow {n : ℕ} (hn : 0 < n) (M : Matrix (Fin n) (Fin n) ℝ) (T : ℝ) :
    ℕ → Matrix (Fin n) (Fin n) ℝ
  | 0 => tropId T
  | k + 1 => tropMul hn (tropMatPow hn M T k) M

@[simp] theorem tropMatPow_zero {n : ℕ} (hn : 0 < n) (M : Matrix (Fin n) (Fin n) ℝ) (T : ℝ) :
    tropMatPow hn M T 0 = tropId T := rfl

@[simp] theorem tropMatPow_succ {n : ℕ} (hn : 0 < n) (M : Matrix (Fin n) (Fin n) ℝ) (T : ℝ)
    (k : ℕ) : tropMatPow hn M T (k + 1) = tropMul hn (tropMatPow hn M T k) M := rfl

theorem tropId_diagonal {n : ℕ} (T : ℝ) (i : Fin n) : tropId T i i = 0 := if_pos rfl

theorem tropId_off_diagonal {n : ℕ} (T : ℝ) (i j : Fin n) (hij : i ≠ j) :
    tropId T i j = T := if_neg hij

/-! ## Section 3: Tropical Distance (Sup-Norm) -/

/-- **Tropical distance** (sup-norm).
    Bridge: connects tropical geometry to lattice cryptography. -/
def tropDist {n : ℕ} (hn : 0 < n) (x y : Fin n → ℝ) : ℝ :=
  Finset.univ.sup' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) (fun i => |x i - y i|)

theorem tropDist_nonneg {n : ℕ} (hn : 0 < n) (x y : Fin n → ℝ) : 0 ≤ tropDist hn x y :=
  le_trans (abs_nonneg _) (Finset.le_sup' (fun i => |x i - y i|) (Finset.mem_univ ⟨0, hn⟩))

theorem tropDist_symm {n : ℕ} (hn : 0 < n) (x y : Fin n → ℝ) :
    tropDist hn x y = tropDist hn y x := by
  simp only [tropDist]; congr 1; ext i; rw [abs_sub_comm]

theorem tropDist_self {n : ℕ} (hn : 0 < n) (x : Fin n → ℝ) : tropDist hn x x = 0 := by
  unfold tropDist
  have : (fun i : Fin n => |x i - x i|) = fun _ => (0 : ℝ) := by ext; simp
  rw [this]
  exact Finset.sup'_const _ _

theorem tropDist_coord_le {n : ℕ} (hn : 0 < n) (x y : Fin n → ℝ) (i : Fin n) :
    |x i - y i| ≤ tropDist hn x y :=
-- ... (truncated, full file has 400 lines)
```

@Speculative/AutoResearch/Bridges/TropicalValuationFunctor.lean
```lean
/-
  # Tropical Valuation Functor:
  # The Bridge Between Multiplicative Algebra, p-Adic Analysis,
  # and Post-Quantum Lattice Security

  ## Domain Bridge: Tropical Geometry ↔ p-Adic Analysis ↔ Lattice Cryptography ↔ Neural Network Robustness

  The central discovery: The p-adic valuation is a *functor* from multiplicative
  algebra to tropical (min-plus) algebra that preserves exactly the structure needed for:
  - Post-quantum lattice security reductions (hardness amplification)
  - Lipschitz-certified neural network robustness (composition bounds)
  - Algorithmic complexity classification (tropical circuit complexity)

  The valuation map v_p : (ℤ_p \ {0}, ×) → (ℤ, +) sends:
  - multiplication ↦ addition
  - divisibility ↦ order
  - gcd ↦ min (tropical multiplication)

  ## Main Results (35+ theorems, zero sorry)

  ## Structures (8 novel types)

  - `TropicalSemiringCertificate` — certified min-plus algebraic structure
  - `ValuationDepthMeasure` — complexity measure via p-adic depth
  - `LipschitzCompositionChain` — chain of Lipschitz maps with certified bound
  - `SpectralAmplificationCertificate` — spectral gap amplification bounds
  - `CertifiedRobustnessWitness` — end-to-end adversarial robustness certificate
  - `TropicalSecurityParameter` — post-quantum security from tropical rank
  - `TropicalHashFunction` — hash function with tropical collision resistance
  - `TropicalDistanceMetric` — tropical metric structure
-/

import Mathlib

open Finset BigOperators

noncomputable section

namespace TropicalValuationFunctor

/-! ## §1. Tropical Arithmetic Infrastructure

The tropical semiring (ℝ ∪ {+∞}, ⊕, ⊗) where:
  a ⊕ b = min(a, b)     (tropical addition)
  a ⊗ b = a + b          (tropical multiplication) -/

set_option checkBinderAnnotations false in
/-- **TropicalSemiringCertificate**: A certificate that a linearly ordered
    additive type carries tropical semiring structure.
    Bridge: connects abstract algebra to quantitative crypto bounds.
    Impact: post_quantum_security, lattice_crypto. -/
structure TropicalSemiringCertificate (α : Type*) [LinearOrder α] [Add α] where
  /-- Tropical addition (min) is commutative -/
  tropAdd_comm : ∀ a b : α, min a b = min b a
  /-- Tropical addition (min) is associative -/
  tropAdd_assoc : ∀ a b c : α, min (min a b) c = min a (min b c)
  /-- Tropical multiplication (add) is commutative -/
  tropMul_comm : ∀ a b : α, a + b = b + a
  /-- Tropical multiplication distributes over tropical addition -/
  tropDistrib : ∀ a b c : α, a + min b c = min (a + b) (a + c)

/-- **ℤ is a tropical semiring**. -/
def int_tropical_certificate : TropicalSemiringCertificate ℤ where
  tropAdd_comm := min_comm
  tropAdd_assoc := min_assoc
  tropMul_comm := add_comm
  tropDistrib := fun a b c => (min_add_add_left a b c).symm

/-- **ℕ is a tropical semiring**. -/
def nat_tropical_certificate : TropicalSemiringCertificate ℕ where
  tropAdd_comm := min_comm
  tropAdd_assoc := min_assoc
  tropMul_comm := add_comm
  tropDistrib := fun a b c => (min_add_add_left a b c).symm

/-- **ℝ is a tropical semiring**. -/
def real_tropical_certificate : TropicalSemiringCertificate ℝ where
  tropAdd_comm := min_comm
  tropAdd_assoc := min_assoc
  tropMul_comm := add_comm
  tropDistrib := fun a b c => (min_add_add_left a b c).symm

/-- **Tropical commutativity is universal**: min is commutative in any linear order.
    Bridge: connects ordered algebra to tropical structure (Algebra ↔ Tropical). -/
theorem tropical_min_comm {α : Type*} [LinearOrder α] (a b : α) :
    min a b = min b a := min_comm a b

/-- **Tropical distributivity over ℤ**: a + min(b,c) = min(a+b, a+c). -/
theorem tropical_distrib_int (a b c : ℤ) :
    a + min b c = min (a + b) (a + c) := (min_add_add_left a b c).symm

/-- **Tropical distributivity over ℝ**: a + min(b,c) = min(a+b, a+c). -/
theorem tropical_distrib_real (a b c : ℝ) :
    a + min b c = min (a + b) (a + c) := (min_add_add_left a b c).symm

/-- **Tropical idempotency**: min(a, a) = a. Distinguishes tropical from classical. -/
theorem tropical_idempotent {α : Type*} [LinearOrder α] (a : α) :
    min a a = a := min_self a

/-- **Tropical absorption**: min(a, a + b) = a when b ≥ 0.
    Adding a non-negative "cost" never decreases the tropical sum. -/
theorem tropical_absorption (a b : ℤ) (hb : 0 ≤ b) :
    min a (a + b) = a := by simp [min_def]; omega

/-! ## §2. Valuation Depth Measure -/

/-- **ValuationDepthMeasure**: Complexity measure based on p-adic depth.
    Bridge: connects number theory to post-quantum security parameters.
    Impact: post_quantum_security, lattice_crypto. -/
structure ValuationDepthMeasure where
  /-- The prime base -/
  prime : ℕ
  /-- Primality certificate -/
  isPrime : Nat.Prime prime

/-- **Valuation additive on products**: v_p(ab) = v_p(a) + v_p(b).
    The *homomorphism property* making v_p a tropical functor.
    Bridge: connects multiplicative structure to tropical addition.
    Impact: tropical_hash_collision resistance bounds. -/
theorem valuation_additive_on_products (p a b : ℕ) (hp : Nat.Prime p)
    (ha : a ≠ 0) (hb : b ≠ 0) :
    padicValNat p (a * b) = padicValNat p a + padicValNat p b := by
  haveI : Fact (Nat.Prime p) := ⟨hp⟩
  exact padicValNat.mul ha hb

/-- **Valuation of prime powers**: v_p(p^k) = k.
    Bridge: connects exponentiation to tropical scaling. -/
theorem valuation_prime_power (p k : ℕ) (hp : Nat.Prime p) :
    padicValNat p (p ^ k) = k := by
  haveI : Fact (Nat.Prime p) := ⟨hp⟩
  exact padicValNat.prime_pow k

/-- **Valuation of prime itself**: v_p(p) = 1. -/
theorem valuation_prime_self (p : ℕ) (hp : Nat.Prime p) :
    padicValNat p p = 1 := by
  haveI : Fact (Nat.Prime p) := ⟨hp⟩
  exact padicValNat.self hp.one_lt

/-- **Valuation of 1**: v_p(1) = 0. The unit maps to tropical zero. -/
theorem valuation_one (p : ℕ) : padicValNat p 1 = 0 := by simp

/-- **Valuation bounds power divisibility**: p^(v_p(n)) | n.
    Bridge: connects valuation to divisibility lattice. -/
theorem valuation_power_dvd (p n : ℕ) (hp : Nat.Prime p) :
    p ^ padicValNat p n ∣ n :=
  haveI : Fact (Nat.Prime p) := ⟨hp⟩; pow_padicValNat_dvd

/-- **Iterated valuation**: v_p(p^a · p^b) = a + b.
    Bridge: tropical multiplication = ordinary addition of exponents. -/
theorem valuation_iterated (p a b : ℕ) (hp : Nat.Prime p) :
-- ... (truncated, full file has 531 lines)
```

@Bridges/AlgebraTropicalMachineLearning/TropicalBarronChoquetDuality.lean
```lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Barron–Choquet Duality via Idempotent Feature Semimodules

This file formalizes a **finite representation and reconstruction theorem** that connects
abstract tropical Choquet functionals to canonical sparse shallow tropical networks.

## Mathematical Context

In max-plus (tropical) algebra, "addition" is `max` and "multiplication" is `+`.
A **tropical network** with support `I ⊆ 𝓕` and weights `w : 𝓕 → ℝ` computes:

  `N(f) = max_{i ∈ I} (w(i) + eval(i)(f))`

where `eval : 𝓕 → (F → ℝ)` is a family of evaluation functionals (feature maps).

The **Tropical Barron–Choquet Duality** says:
1. Every sup-preserving, shift-equivariant functional admits such a representation.
2. Dominated hidden units can be pruned without changing the functional.
3. The irredundant (pruned) representation has minimum support cardinality.
4. Under a separation hypothesis, the irredundant support set is unique.

## Main Definitions

* `TropicalNetworkRep` — A tropical network representation (support, weights, evaluations)
* `TropicalNetworkRep.realize` — The function computed by a network
* `IsDominated` — A hidden unit is dominated if it never achieves the maximum
* `IsIrredundant` — A representation where no unit is dominated
* `SeparatingEvals` — Evaluation functionals that separate distinct indices

## Main Results

* `realize_erase_of_pointwise_dominated` — Removing a dominated unit preserves the functional
* `realize_sup_preserving` — Network realizations preserve tropical addition (max)
* `realize_shift_equivariant` — Network realizations are shift-equivariant
* `realize_monotone` — Network realizations are monotone
* `irredundant_support_card_eq` — Irredundant representations have equal support cardinality
* `certified_compression_of_dominated` — Dominated units can be certified-removed
* `network_weight_stability` — Weight perturbation stability bound
* `sparse_reconstruction` — Weights recovered from isolating test inputs

## Cross-Domain Connections

- **Tropical convex geometry**: extremal rays, tropical Carathéodory
- **Functional analysis**: Choquet-style representation, representer theorems
- **Machine learning**: sparse shallow networks, width minimization, certified compression
- **Idempotent analysis**: sup-preserving maps, max-plus linearity

## Application Keywords

`tropical neural networks`, `idempotent functional analysis`, `Choquet duality`,
`Barron space`, `sparse reconstruction`, `network compression`, `max-plus algebra`,
`extremal rays`, `certified recovery`, `interpretable ML`, `atomic decomposition`,
`minimal width realization`
-/

noncomputable section

open Finset

namespace TropicalBarronChoquet

variable {𝓕 F : Type*} [DecidableEq 𝓕]

/-! ## §1. Tropical Network Representations -/

/-- A **tropical network representation** consists of a finite support set,
    weight function, and evaluation functionals. It computes:
    `N(f) = max_{i ∈ support} (weight(i) + eval(i)(f))` -/
structure TropicalNetworkRep (𝓕 F : Type*) where
  /-- The finite support set of active hidden units -/
  support : Finset 𝓕
  /-- The weight assigned to each hidden unit -/
  weight : 𝓕 → ℝ
  /-- The evaluation functional for each hidden unit -/
  eval : 𝓕 → F → ℝ

variable {R R₁ R₂ : TropicalNetworkRep 𝓕 F}

/-- The function computed by a tropical network. When support is empty, returns 0. -/
def TropicalNetworkRep.realize (R : TropicalNetworkRep 𝓕 F) (f : F) : ℝ :=
  if h : R.support.Nonempty then
    R.support.sup' h (fun i => R.weight i + R.eval i f)
  else 0

omit [DecidableEq 𝓕] in
/-- Realize for nonempty support unfolds to sup'. -/
theorem TropicalNetworkRep.realize_nonempty (R : TropicalNetworkRep 𝓕 F)
    (h : R.support.Nonempty) (f : F) :
    R.realize f = R.support.sup' h (fun i => R.weight i + R.eval i f) := by
  simp [TropicalNetworkRep.realize, h]

/-- Two representations are **functionally equivalent** if they compute the
    same function on all inputs. -/
def FunctionallyEquiv (R₁ R₂ : TropicalNetworkRep 𝓕 F) : Prop :=
  ∀ f : F, R₁.realize f = R₂.realize f

/-! ## §2. Dominance and Irredundancy -/

/-- A hidden unit `i` is **dominated** in representation `R` if for all inputs,
    some other unit achieves at least as high a value. -/
def IsDominated (R : TropicalNetworkRep 𝓕 F) (i : 𝓕) : Prop :=
  i ∈ R.support ∧
    ∀ f : F, ∃ j ∈ R.support, j ≠ i ∧ R.weight i + R.eval i f ≤ R.weight j + R.eval j f

/-- A representation is **irredundant** if no active hidden unit is dominated. -/
def IsIrredundant (R : TropicalNetworkRep 𝓕 F) : Prop :=
  ∀ i ∈ R.support, ¬ IsDominated R i

/-- A unit is **essential** if it strictly achieves the max on some input. -/
def IsEssential (R : TropicalNetworkRep 𝓕 F) (i : 𝓕) : Prop :=
  i ∈ R.support ∧
    ∃ f : F, ∀ j ∈ R.support, j ≠ i → R.weight j + R.eval j f < R.weight i + R.eval i f

/-! ## §3. Separating Evaluations -/

/-- Evaluation functionals **separate** if distinct indices have distinct evaluation
    profiles. -/
def SeparatingEvals (eval : 𝓕 → F → ℝ) : Prop :=
  ∀ i j : 𝓕, i ≠ j → ∃ f : F, eval i f ≠ eval j f

/-! ## §4. Core Finset Sup Lemmas -/

/-- The sup over `S` equals the sup over `S.erase i` when `i`'s value is dominated. -/
theorem sup'_erase_of_dominated' (S : Finset 𝓕) (hS : S.Nonempty) (g : 𝓕 → ℝ)
    (i : 𝓕) (hi : i ∈ S) (hS' : (S.erase i).Nonempty)
    (hdom : ∃ j ∈ S, j ≠ i ∧ g i ≤ g j) :
    S.sup' hS g = (S.erase i).sup' hS' g := by
  apply le_antisymm
  · apply Finset.sup'_le
    intro b hb
    by_cases hbi : b = i
    · subst hbi
      obtain ⟨j, hj, hji, hle⟩ := hdom
      exact le_trans hle (Finset.le_sup' g (Finset.mem_erase.mpr ⟨hji, hj⟩))
    · exact Finset.le_sup' g (Finset.mem_erase.mpr ⟨hbi, hb⟩)
  · apply Finset.sup'_le
    intro b hb
    exact Finset.le_sup' g (Finset.mem_of_mem_erase hb)

omit [DecidableEq 𝓕] in
/-- sup' distributes over max (binary sup). -/
theorem sup'_max_distrib' (S : Finset 𝓕) (hS : S.Nonempty)
    (f g : 𝓕 → ℝ) :
    S.sup' hS (fun s => max (f s) (g s)) = max (S.sup' hS f) (S.sup' hS g) := by
-- ... (truncated, full file has 357 lines)
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
