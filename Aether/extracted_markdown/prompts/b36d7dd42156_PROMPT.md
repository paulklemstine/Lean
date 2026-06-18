
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   Reference the specific theorems proved in Phase A using @file references.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work,
   references to catalog results. Use @file references for theorems.
3. **demo.py** — Numerical examples demonstrating the key results.
   Self-contained Python, type hints, all functions inlined.
4. **PACKAGE.json** — Single JSON bundling all of the above, with this schema:

```json
{
  "title": "Human-Readable Package Title",
  "domain": "Algebra|Applications|Bridges|Computation|Cryptography|EML|Geometry|Logic|MachineLearning|Novelty|Physics|Pythagorean|Shared|Tropical",
  "description": "1-2 sentence description of the package",
  "authors": ["Author Name"],
  "date": "YYYY-MM-DD",
  "key_results": ["Key result 1", "Key result 2"],
  "keywords": ["keyword1", "keyword2"],
  "article": "ARTICLE.md",
  "research_paper": "RESEARCH_PAPER.md",
  "demo": "demo.py",
  "demos": [
    {"name": "descriptive_name", "description": "What this demo shows", "code": "# full Python source..."}
  ],
  "algorithms": [
    {"name": "descriptive_name", "pseudocode": "Brief description", "code": "# full Python source..."}
  ],
  "visualizations": [
    {"name": "descriptive_name", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Interactive Widget Title", "description": "What users can explore", "html": "<!DOCTYPE html><html>...</html>"}
  ],
  "lean_proofs": "LEAN_FILE_CONTENT_OR_PLACEHOLDER",
  "future_directions": "FUTURE_DIRECTIONS_CONTENT",
  "modules": {"demo": "# full demo.py source..."},
  "lean_files": ["Catalog/Domain/Package/File.lean"]
}
```

**CRITICAL**: The `demos`, `algorithms`, `visualizations`, and
`interactive_demos` fields MUST be arrays of objects with the
exact structure shown above. Do NOT use placeholder strings like
"MISSING" — either include real content or omit the field entirely.

### DO NOT OUTPUT:
- NO new `.lean` files
- NO new theorem proofs
- NO changes to the existing Lean 4 source
- NO `FUTURE_DIRECTIONS.md` as a separate file (Phase A already produced
  future directions — they are provided below for inclusion in PACKAGE.json)

The math is already proved. Treat the Lean files below as the
ground truth — your prose should explain and contextualize them.
Use the @file references above to point readers to specific theorems.


## Concept

**Title**: **Causal Integration Algebra** — a rigorous lattice-t
**Domain**: Shared
**Mathematical framing**: # Future Directions: Causal Integration Algebra

## Synthesis

This cycle established the **Causal Integration Algebra** — a rigorous lattice-theoretic formalization of Integrated Information Theory that identifies Φ with the minimum cut of a weighted causal graph. We proved 18 theorems covering nonnegativity, decomposition characterization, composition/exclusion, scaling, monotonicity, and a novel symmetrization invariance result. The framework connects IIT to classical graph theory and opens several deep avenues.

The most promising cross-domain connection is between **integration theory and spectral graph theory**. The Fiedler value (algebraic connectivity) provides a lower bound on the minimum cut, and our scaling and monotonicity theorems suggest that the entire spectral structure of the graph Laplacian encodes integration properties. This connects consciousness science to one of the richest areas of combinatorial mathematics.

The highest breakthrough potential lies in **Direction 1**: formalizing the relationship between Φ and algebraic connectivity. If this connection can be made precise, it would import the entire machinery of spectral graph theory into consciousness science — eigenvalue bounds, Cheeger inequalities, expander graphs, and random matrix theory would all become tools for understanding integration.

---

### Direction 1: Spectral Integration — Φ and the Fiedler Value

**Conjecture**: For any symmetric causal system C on n vertices, the Fiedler value λ₂(L) of the graph Laplacian satisfies: λ₂(L) ≤ Φ(C) ≤ n · λ₂(L) / 4, where L is the Laplacian matrix of the symmetrized causal graph with edge weights w(i,j) + w(j,i).

**Test**: Compute both Φ (by brute-force minimum cut) and λ₂(L) (by eigenvalue computation) for all connected weighted graphs on 4-6 vertices with integer weights 1-3. Check whether the conjectured inequality holds.

**Impact**: If true, this establishes a computable lower bound on Φ via eigenvalue computation (O(n²) vs O(2ⁿ) for brute-force Φ), and imports Cheeger-type inequalities into consciousness theory. If false, the failure case would reveal systems where spectral methods fundamentally mischaracterize integration.

**Catalog References**: `Novelty/IntegratedInformation/Core.lean` (CausalSystem, phi, symmetrize_phi), `Novelty/IntegratedInformation/Spectrum.lean` (phi_eq_min_cut, phi_mono_of_weight_le)

**Proof Strategy**: 
1. Define the graph Laplacian L of a CausalSystem in Lean
2. Prove the Courant-Fischer characterization of λ₂
3. Show that Φ = min_A cross(A) ≥ λ₂ via the Rayleigh quotient bound
4. Prove the upper bound using the Cheeger inequality

**Domain Bridges**: Spectral Graph Theory ↔ Integrated Information Theory ↔ Algebraic Connectivity

**Lineage**: Builds on phi_eq_min_cut, symmetrize_phi, crossInfo_le_totalWeight from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Dynamic Integration — Phase Transitions in Evolving Causal Systems

**Conjecture**: For a one-parameter family of causal systems C(t) where w(i,j;t) = (1-t)·w_disconnected + t·w_connected (linear interpolation between a disconnected and fully connected system), there exists a critical threshold t* ∈ (0,1) such that Φ(C(t)) = 0 for t < t* and Φ(C(t)) > 0 for t > t*. Moreover, t* = 1/n for the uniform complete graph target.

**Test**: Compute Φ(C(t)) for n = 4,5,6 with the disconnected system being two equal halves and the connected system being the complete graph with unit weights. Plot Φ vs t and verify the phase transition.

**Impact**: If true, this identifies a sharp phase transition in integration, analogous to percolation thresholds in random graphs. This would connect IIT to critical phenomena and phase transitions — one of the deepest frameworks in statistical physics. If false, integration may emerge gradually rather than sharply, which would itself be informative.

**Catalog References**: `Novelty/IntegratedInformation/Core.lean` (phi, IsDisconnected, phi_zero_of_disconnected), `Novelty/IntegratedInformation/Spectrum.lean` (phi_mono_of_weight_le, phi_scale)

**Proof Strategy**:
1. Define CausalSystem.interpolate as a linear combination
2. Show Φ is continuous in the interpolation parameter (follows from min of continuous functions)
3. Show Φ = 0 at t = 0 (disconnected) and Φ > 0 at t = 1 (strongly positive)
4. Prove existence of t* by intermediate value theorem
5. For the specific uniform case, compute t* exactly

**Domain Bridges**: Statistical Physics (Phase Transitions) ↔ Integrated Information ↔ Percolation Theory

**Lineage**: Builds on phi_zero_of_disconnected, phi_pos_of_strongly_positive, phi_mono_of_weight_le from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Categorical Integration — Causal Systems as Enriched Categories

**Conjecture**: The category of causal systems (with morphisms being weight-reducing maps) admits a monoidal structure under direct sum, and Φ extends to a lax monoidal functor to (ℝ≥0, min, +). Specifically, Φ(C₁ ⊕ C₂) = min(Φ(C₁), Φ(C₂), cross(C₁,C₂)) where cross(C₁,C₂) is the minimum cross-flow between the two components.

**Test**: Verify the functor properties for all pairs of causal systems on 2-3 vertices. Check that the monoidal structure axioms (associativity, unit) hold.

**Impact**: If true, this provides a categorical foundation for IIT, enabling composition of conscious systems via universal constructions (limits, colimits). This would connect IIT to topos theory and provide a principled answer to the "combination problem" in philosophy of mind.

**Catalog References**: `Novelty/IntegratedInformation/Core.lean` (directSum, phi_directSum_eq_zero), `Bridges/ArrowDepthComplexity.lean` (category-theoretic methods)

**Proof Strategy**:
1. Define the category CausalSys with objects = CausalSystem n and morphisms = weight-reducing maps
2. Verify well-definedness of composition
3. Define the direct sum monoidal product
4. Show Φ is functorial (monotonicity implies functoriality)
5. Verify the lax monoidal property

**Domain Bridges**: Category Theory (Enriched Categories) ↔ IIT ↔ Monoidal Functors

**Lineage**: Builds on directSum, phi_directSum_eq_zero, phi_mono_of_weight_le from this cycle.

**Ambition**: extension

---

### Direction 4: Integration Spectrum and Chromatic Number

**Conjecture**: For a causal system C, define the "zero graph" G₀ as the graph with edges where w(i,j) = 0. Then the integration dimension (largest k where Φ_k > 0) equals the chromatic number χ(G₀ᶜ) of the complement of G₀ minus 1. In particular, for a strongly positive system, dim(C) = n - 1.

**Test**: Enumerate all graphs on 4-5 vertices, assign random positive weights to edges and zero to non-edges. Compute integration dimension by brute-force k-partition enumeration. Compare with chromatic number of complement.

**Impact**: If true, this provides a graph-coloring characterization of integration depth, connecting IIT to one of the central problems in combinatorics. If false, the failure cases would reveal interesting structures where integration dimension diverges from chromatic expectations.

**Catalog References**: `Novelty/IntegratedInformation/Core.lean` (KPartition, interPartFlow, interPartFlow_nonneg), `Novelty/IntegratedInformation/Spectrum.lean` (phi_pos_of_strongly_positive)

**Proof Strategy**:
1. Formalize integration dimension as a definition
2. Show that Φ_k > 0 iff every k-partition has positive inter-part flow
3. Relate this to the existence of edges between every pair of parts
4. Connect to graph coloring: a proper coloring of G₀ᶜ corresponds to a zero-flow partition

**Domain Bridges**: Graph Coloring ↔ Integration Spectrum ↔ Complexity Theory (chromatic number is NP-hard)

**Lineage**: Builds on KPartition, interPartFlow_nonneg from this cycle; connects to `critical_density_bounds` in Novelty/SegmentAlgebra.lean.

**Ambition**: extension

---

### Direction 5: Information-Geometric Integration — Φ on Statistical Manifolds

**Conjecture**: When causal weights represent Fisher information between stochastic processes at each node, Φ becomes a Riemannian distance on the statistical manifold of joint distributions. Specifically, Φ(C) ≥ d_FI(p_joint, p_product) where d_FI is the Fisher-Rao distance between the joint distribution and the product of marginals.

**Test**: For binary causal systems (each node has state 0 or 1) with n = 3-4, compute Φ (minimum cut) and d_FI (Fisher-Rao distance between joint and product distributions) numerically. Check whether the inequality holds.

**Impact**: If true, this embeds IIT in information geometry — one of the most elegant frameworks in mathematical statistics. Φ would acquire a geometric interpretation as a "distance from independence" on a curved statistical manifold. This would also provide natural connections to machine learning (natural gradient descent) and quantum information (quantum Fisher information).

**Catalog References**: `Novelty/IntegratedInformation/Spectrum.lean` (phi_le_totalWeight, phi_scale), `Bridges/PadicQuantumInformation.lean` (information-theoretic methods)

**Proof Strategy**:
1. Define Fisher information matrix for a causal system
2. Define the Fisher-Rao metric on the simplex of joint distributions
3. Show that the minimum cut provides an upper bound on the geodesic distance
4. Prove the lower bound using the data processing inequality

**Domain Bridges**: Information Geometry ↔ IIT ↔ Statistical Manifolds ↔ Quantum Information

**Lineage**: Builds on phi_le_totalWeight, crossInfo_le_totalWeight from this cycle; connects to `ultrametric_entropy_composition_bound` in Bridges/PadicQuantumInformation.lean.

**Ambition**: grand_challenge

Research domain: Shared
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Bridges/IRVStability.lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# GL3 Tropical Satake Certified Robustness for IRV Classifiers

This file formalizes a robustness theory for deterministic, tie-free
instant-runoff / sequential-elimination classifiers built from multiclass
tropical score maps.

## Main results

* `roundLoser_eq_of_strict_min` — uniqueness of the minimizer on a finite set
* `gap_preserved_under_perturbation` — the one-round perturbation lemma
* `eliminationOrderOn_stable` — elimination-order stability under bounded perturbation
* `irvWinnerOn_stable` — winner stability under bounded perturbation
* `irvWinner_certified_robust` — the full tropical/Lipschitz robustness corollary

## Proof architecture

The core theorem proceeds by induction on the cardinality of the active
candidate set. At each round, the gap certificate ensures the current loser
has score at least γ below every other active candidate. A uniform
perturbation of size ≤ ε shifts each score by at most ε, so the gap shrinks
by at most 2ε. When 2ε < γ, the same candidate remains the unique loser,
and the induction carries through the remaining rounds.
-/

import Mathlib

namespace IRV

open Finset

/-! ## Part 1: Core Definitions -/

/-- Pairwise distinct scores on a candidate set. -/
def PairwiseDistinctOn {m : ℕ} (S : Finset (Fin m)) (v : Fin m → ℝ) : Prop :=
  ∀ ⦃i⦄, i ∈ S → ∀ ⦃j⦄, j ∈ S → i ≠ j → v i ≠ v j

/-- Gap certificate: `i` is in `S` and every other element of `S` has
    score at least `γ` above `v i`. -/
def HasGapAtLeast {m : ℕ} (S : Finset (Fin m)) (v : Fin m → ℝ)
    (i : Fin m) (γ : ℝ) : Prop :=
  i ∈ S ∧ ∀ j ∈ S, j ≠ i → v i + γ ≤ v j

/-- The round loser: the element of `S` minimizing `v`, chosen via `Classical.choose`
    from the existence of a minimizer on a nonempty finite set. -/
noncomputable def roundLoser {m : ℕ} (S : Finset (Fin m)) (hS : S.Nonempty)
    (v : Fin m → ℝ) : Fin m :=
  (S.exists_min_image v hS).choose

/-! ## Part 2: Properties of `roundLoser` -/

lemma roundLoser_mem {m : ℕ} (S : Finset (Fin m)) (hS : S.Nonempty)
    (v : Fin m → ℝ) : roundLoser S hS v ∈ S :=
  (S.exists_min_image v hS).choose_spec.1

lemma roundLoser_le {m : ℕ} (S : Finset (Fin m)) (hS : S.Nonempty)
    (v : Fin m → ℝ) : ∀ j ∈ S, v (roundLoser S hS v) ≤ v j :=
  (S.exists_min_image v hS).choose_spec.2

/-
If `i ∈ S` is strictly below every other element of `S` under `v`,
    then `roundLoser S hS v = i`.
-/
lemma roundLoser_eq_of_strict_min {m : ℕ} {S : Finset (Fin m)} {hS : S.Nonempty}
    {v : Fin m → ℝ} {i : Fin m}
    (hi : i ∈ S) (hmin : ∀ j ∈ S, j ≠ i → v i < v j) :
    roundLoser S hS v = i := by
  -- Since `roundLoser S hS v` is in `S` and `v i < v j` for all `j ∈ S \ {i}`, it must be that `roundLoser S hS v = i`.
  have h_unique_min : ∀ j ∈ S, v j < v (roundLoser S hS v) → False := by
    exact fun j hj => not_lt_of_ge ( roundLoser_le S hS v j hj );
  exact Classical.not_not.1 fun h => h_unique_min i hi <| hmin _ ( roundLoser_mem _ hS _ ) h

/-! ## Part 3: Recursive Elimination -/

private lemma erase_nonempty_of_card_gt_one {m : ℕ} {S : Finset (Fin m)}
    {a : Fin m} (ha : a ∈ S) (hcard : ¬ S.card ≤ 1) :
    (S.erase a).Nonempty := by
  -- Since S has more than one element, removing one element a from S leaves a set with at least one element.
  have h_card_erase : (S.erase a).card ≥ 1 := by
    grind +locals;
  -- Since the cardinality of S.erase a is at least 1, the set must be nonempty.
  apply Finset.card_pos.mp h_card_erase

private lemma erase_card_lt {m : ℕ} {S : Finset (Fin m)}
    {a : Fin m} (ha : a ∈ S) :
    (S.erase a).card < S.card := by
  grind +locals

/-- Recursive elimination order on active set `S`: produces the list
    `[first_eliminated, second_eliminated, ..., winner]`. -/
noncomputable def eliminationOrderOn {m : ℕ}
    (S : Finset (Fin m)) (hS : S.Nonempty) (v : Fin m → ℝ) : List (Fin m) :=
  if hcard : S.card ≤ 1 then
    [S.min' hS]
  else
    let i := roundLoser S hS v
    have hi : i ∈ S := roundLoser_mem S hS v
    have hS' : (S.erase i).Nonempty := erase_nonempty_of_card_gt_one hi hcard
    have : (S.erase i).card < S.card := erase_card_lt hi
    i :: eliminationOrderOn (S.erase i) hS' v
termination_by S.card

/-- The IRV winner on active set `S`: the last candidate surviving
    sequential elimination by minimum score. -/
noncomputable def irvWinnerOn {m : ℕ}
    (S : Finset (Fin m)) (hS : S.Nonempty) (v : Fin m → ℝ) : Fin m :=
  if hcard : S.card ≤ 1 then
    S.min' hS
  else
    let i := roundLoser S hS v
    have hi : i ∈ S := roundLoser_mem S hS v
    have hS' : (S.erase i).Nonempty := erase_nonempty_of_card_gt_one hi hcard
    have : (S.erase i).card < S.card := erase_card_lt hi
    irvWinnerOn (S.erase i) hS' v
termination_by S.card

/-- The IRV winner on all candidates. -/
noncomputable def irvWinner {m : ℕ} [NeZero m] (v : Fin m → ℝ) : Fin m :=
  irvWinnerOn Finset.univ Finset.univ_nonempty v

/-- Recursive gap certificate: at every round of the elimination of `v` on `S`,
    the current loser has gap at least `γ` to every other active candidate. -/
noncomputable def EliminationGapCertified {m : ℕ}
    (S : Finset (Fin m)) (hS : S.Nonempty) (v : Fin m → ℝ) (γ : ℝ) : Prop :=
  if hcard : S.card ≤ 1 then
    True
  else
    let i := roundLoser S hS v
    have hi : i ∈ S := roundLoser_mem S hS v
    have hS' : (S.erase i).Nonempty := erase_nonempty_of_card_gt_one hi hcard
    have : (S.erase i).card < S.card := erase_card_lt hi
    HasGapAtLeast S v i γ ∧ EliminationGapCertified (S.erase i) hS' v γ
termination_by S.card

/-! ## Part 4: One-Round Perturbation Lemma -/

/-
The algebraic heart: if `i` has gap `γ` in `S` under `v`, and `v'` is
    within `ε` of `v` coordinatewise, then `i` still has gap `γ - 2*ε`
    in `S` under `v'`.
-/
lemma gap_preserved_under_perturbation {m : ℕ}
    {S : Finset (Fin m)} {v v' : Fin m → ℝ}
    {i : Fin m} {γ ε : ℝ}
    (hgap : HasGapAtLeast S v i γ)
    (hclose : ∀ k, |v' k - v k| ≤ ε) :
    ∀ j ∈ S, j ≠ i → v' i + (γ - 2 * ε) ≤ v' j := by
  exact fun j hj hij => by linarith [ abs_le.mp ( hclose i ), abs_le.mp ( hclose j ), hgap.2 j hj hij ] ;

/-
From a preserved positive gap, the same candidate is the strict minimizer.
-/
lemma strict_min_of_gap {m : ℕ}
    {S : Finset (Fin m)} {v : Fin m → ℝ}
    {i : Fin m} {δ : ℝ}
    (_hi : i ∈ S) (hδ : 0 < δ)
    (hsep : ∀ j ∈ S, j ≠ i → v i + δ ≤ v j) :
    ∀ j ∈ S, j ≠ i → v i < v j := by
  exact fun j hj hij => lt_of_lt_of_le ( lt_add_of_pos_right _ hδ ) ( hsep j hj hij )

/-! ## Part 5: Main Stability Theorem -/

/-
**Elimination-order stability theorem.** If the elimination of `v` on `S`
    is gap-certified with parameter `γ`, and `v'` is within `ε` of `v`
    coordinatewise with `2ε < γ`, then the elimination order of `v'` on `S`
    equals that of `v`.
-/
theorem eliminationOrderOn_stable {m : ℕ}
    {v v' : Fin m → ℝ}
    (S : Finset (Fin m)) (hS : S.Nonempty)
    {ε γ : ℝ}
    (hcert : EliminationGapCertified S hS v γ)
    (hε : 0 ≤ ε)
    (hgap : 2 * ε < γ)
    (hclose : ∀ i, |v' i - v i| ≤ ε) :
    eliminationOrderOn S hS v' = eliminationOrderOn S hS v := by
  nontriviality;
  -- Apply the induction hypothesis to the smaller set S.erase i.
  have ih : ∀ (S : Finset (Fin m)) (hS : S.Nonempty), S.card < Finset.card S + 1 → EliminationGapCertified S hS v γ → 2 * ε < γ → (∀ i, |v' i - v i| ≤ ε) → eliminationOrderOn S hS v' = eliminationOrderOn S hS v := by
    intros S hS hcard hcert hgap hclose;
    induction' n : Finset.card S using Nat.strong_induction_on with n ih generalizing S hS;
    unfold eliminationOrderOn;
    grind +locals;
  exact ih S hS ( Nat.lt_succ_self _ ) hcert hgap hclose

/-! ## Part 6: Winner Stability -/

/-
**Winner stability theorem.** Under the same hypotheses as
    `eliminationOrderOn_stable`, the IRV winner is preserved.
-/
theorem irvWinnerOn_stable {m : ℕ}
    {v v' : Fin m → ℝ}
    (S : Finset (Fin m))
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Causal Integration Algebra

## What We Built

We formalized the **Causal Integration Algebra** in two Lean 4 files (`Shared/CausalIntegration/Core.lean` and `Shared/CausalIntegration/Composition.lean`), establishing a rigorous lattice-theoretic foundation connecting Integrated Information Theory (IIT) to minimum cuts of weighted directed graphs. The framework defines:

- `CausalSystem n`: weighted directed graphs on `Fin n` with nonneg edge weights
- `crossInfo C S`: total weight crossing a bipartition (cut value)
- `phi C hn`: integrated information Φ as the minimum cut over nontrivial bipartitions

We proved **11 theorems** with zero sorries:
1. `crossInfo_nonneg` — cut values are nonneg
2. `phi_nonneg` — Φ ≥ 0
3. `phi_le_crossInfo` — Φ ≤ any specific cut
4. `phi_zero_of_disconnected` — disconnected ⟹ Φ = 0
5. `crossInfo_scale` / `phi_scale` — Φ scales linearly with weights
6. `crossInfo_mono` / `phi_mono_of_weight_le` — monotonicity under pointwise weight increase
7. `crossInfo_le_totalWeight` / `phi_le_totalWeight` — upper bound by total weight
8. `symmetrize_crossInfo` — symmetrization decomposes into two directed cuts
9. `crossInfo_pos_of_stronglyPositive` / `phi_pos_of_stronglyPositive` — strongly positive systems have Φ > 0

---

## Direction 1: Spectral Lower Bound via Cheeger Inequality

The Fiedler value λ₂ (second-smallest eigenvalue of the graph Laplacian) provides a spectral lower bound on the minimum cut. For a symmetric causal system, the Cheeger inequality gives λ₂/2 ≤ h(G) where h(G) is the Cheeger constant (normalized minimum cut). The key insight is that our `phi` is closely related to the unnormalized Cheeger constant, so formalizing the graph Laplacian and its spectral gap would yield a computable lower bound on Φ — avoiding exponential brute-force enumeration. Why now? We have `phi_mono_of_weight_le` and `symmetrize_crossInfo` as the foundation; the missing piece is the Rayleigh quotient characterization of λ₂, which requires formalizing inner products on `Fin n → ℝ` and the Laplacian as a linear map.

## Direction 2: Converse of Disconnectedness — Characterizing Φ = 0

We proved `phi_zero_of_disconnected`: if a zero-weight cut exists, Φ = 0. The converse — Φ = 0 implies disconnectedness — is more subtle and amounts to showing that the minimum of a finite set of nonneg reals is zero iff some element is zero. The key insight is that this follows from `Finset.inf'` equaling zero in a linearly ordered type with no infinitesimals, which is elementary but requires careful handling of the `inf'` API. Why now? The proof is a direct corollary of our existing `phi_nonneg` and `phi_le_crossInfo`, combined with the fact that ℝ has no positive infinitesimals — the minimum of finitely many nonneg reals is zero iff at least one is zero.

## Direction 3: Subadditivity and the Exclusion Postulate

IIT's exclusion postulate states that Φ picks out a unique "grain" of causal structure. Formally, if C has a k-partition P 
```

## Your task

Produce the deliverables listed above. Reference the specific theorems and
results in the Lean code by their @file path and statement. The Lean file is
the source of truth — your prose must accurately explain it.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). Include future directions from Phase A
in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
