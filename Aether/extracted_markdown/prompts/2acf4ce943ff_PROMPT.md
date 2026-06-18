
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   **Must be fully self-contained and publishable without any external
   references.** State every theorem, result, and definition inline —
   do NOT use @file references or point to other files. A reader with
   only this article must understand every result without looking elsewhere.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work.
   **Must be fully self-contained and publishable quality without any
   external references.** State every theorem, lemma, and definition
   inline with its full mathematical statement and proof sketch. Do NOT
   use @file references or reference other files. A reader with only this
   paper must be able to follow every result from start to finish.
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
    {
      "name": "descriptive_name",
      "description": "Detailed in-depth explanation of the algorithm, its mathematical foundation, computational complexity, and role in the pipeline.",
      "pseudocode": "Formal, structured step-by-step pseudocode detailing the logic.",
      "code": "# full Python source with type hints..."
    }
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
State theorems inline in your article and paper — they must be
self-contained and publishable without external references.


## Concept

**Title**: We formalized the **Causal Integration Algebra** in two Lean 4 files (`Shared/Ca
**Domain**: Physics
**Mathematical framing**: # Future Directions: Causal Integration Algebra

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

IIT's exclusion postulate states that Φ picks out a unique "grain" of causal structure. Formally, if C has a k-partition P = {P₁, ..., Pₖ}, then Φ(C) ≤ Σᵢ Φ(C|Pᵢ) + cross-terms. The key insight is that restricting a causal system to a subset S induces a sub-system, and the global minimum cut either aligns with the partition (giving a cross-term) or cuts through some part (giving a term bounded by that part's Φ). Why now? Our `crossInfo_mono` and monotonicity infrastructure provide the inequalities needed to relate restricted and global cuts; the missing formalization is the notion of restriction `C.restrict S` and its interaction with `crossInfo`.

## Direction 4: Compositional Φ for Direct Sums

For two causal systems C₁ on n₁ nodes and C₂ on n₂ nodes, the direct sum C₁ ⊕ C₂ on n₁ + n₂ nodes (with zero cross-weights) should satisfy Φ(C₁ ⊕ C₂) = 0, since the natural bipartition has zero cross-info. More interestingly, for a "weakly coupled" direct sum with small cross-weights ε, one expects Φ(C₁ ⊕ε C₂) = O(ε). The key insight is that `phi_mono_of_weight_le` already gives Φ(C₁ ⊕ε C₂) ≤ Φ(C₁ ⊕0 C₂) + O(ε·n²), but the tight bound requires analyzing which cut achieves the minimum — if ε is small enough, the minimum cut is the natural partition. Why now? The `scale` and `mono` theorems provide the analytical tools; formalizing `directSum` on `Fin (n₁ + n₂)` using `Fin.addCases` would make this immediately accessible.

## Direction 5: Information-Theoretic Interpretation via Mutual Information

When edge weights represent conditional mutual information I(Xᵢ; Xⱼ | X_rest), the cross-info of a bipartition S measures the total information flow between S and Sᶜ. Under this interpretation, Φ becomes the minimum information bottleneck. The key insight is that mutual information satisfies submodularity, which would strengthen our monotonicity results to give a submodular Φ function on the lattice of partitions — connecting to the extensive theory of submodular optimization. Why now? Our `crossInfo` is defined abstractly enough that any interpretation of weights applies; the missing piece is formalizing the submodularity inequality crossInfo(S ∪ T) + crossInfo(S ∩ T) ≤ crossInfo(S) + crossInfo(T) and showing it holds when weights satisfy the triangle inequality.

Research domain: Physics
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Bridges/DynamicProgramming.lean
/-
  # Tropical Dynamic Programming for Voice Leading

  Theorem 3: Tropical Bellman recursion for optimal voice leading.
  Local costs combine tropically via dynamic programming, turning
  counterpoint search into a certified tropical shortest-path problem.
-/
import Mathlib
import Bridges.TropicalCounterpoint.Defs

open Finset BigOperators

/-! ## Finite DP formulation over bounded pitch alphabet -/

/-- State cost for a single note at position 0: just the vertical penalty. -/
noncomputable def dpCostBase (cantus0 : ℤ) (x : ℤ) : ℝ :=
  forbiddenVerticalPenalty (x - cantus0)

/-- Transition cost between consecutive notes, incorporating vertical, melodic, and parallel penalties. -/
noncomputable def dpTransition (cantusCurr cantusNext : ℤ) (curr next : ℤ) : ℝ :=
  forbiddenVerticalPenalty (next - cantusNext) +
  melodicLeapPenalty curr next +
  (if perfectConsonance (curr - cantusCurr) ∧ perfectConsonance (next - cantusNext) then 1 else 0)

/-- The DP value function: minimum total cost achievable ending at pitch `x` at step `k`.
    Uses a finite pitch set `Y` for the minimization. -/
noncomputable def dpValue (cantus : ℕ → ℤ) (Y : Finset ℤ) : ℕ → ℤ → ℝ
  | 0, x => dpCostBase (cantus 0) x
  | k + 1, x => if hY : Y.Nonempty then
      Y.inf' hY (fun y => dpTransition (cantus k) (cantus (k + 1)) y x + dpValue cantus Y k y)
    else 0

/-! ## Tropical Bellman equation -/

/-
**Theorem 3 (Tropical Bellman Recursion)**: The DP value at step `k+1`
    satisfies the tropical (min-plus) Bellman equation:
    `dpValue (k+1) x = min_y (dpTransition y x + dpValue k y)`.

    This is the computational heart of tropical counterpoint: it turns
    voice-leading search into a certified shortest-path problem over
    a layered directed acyclic graph.
-/
theorem tropical_bellman (cantus : ℕ → ℤ) (Y : Finset ℤ) (hY : Y.Nonempty)
    (k : ℕ) (x : ℤ) :
    dpValue cantus Y (k + 1) x =
      Y.inf' hY (fun y => dpTransition (cantus k) (cantus (k + 1)) y x +
                           dpValue cantus Y k y) := by
  grind +locals

/-! ## Tropical distributivity: adding a constant distributes over min -/

/-
Addition distributes over minimum (tropical distributivity).
    This is the algebraic law `a + min(b,c) = min(a+b, a+c)` that
    underpins the Bellman recursion.
-/
theorem tropical_plus_distributes_over_min_real (a b c : ℝ) :
    a + min b c = min (a + b) (a + c) := by
  grind

/-
Monotonicity: adding candidates cannot increase the tropical optimum.
-/
theorem tropical_monotone_insert (Y : Finset ℤ) (y₀ : ℤ) (f : ℤ → ℝ)
    (hY : Y.Nonempty) :
    (insert y₀ Y).inf' (Finset.insert_nonempty y₀ Y) f ≤ Y.inf' hY f := by
  norm_num [ Finset.inf'_le ];
  exact fun x hx => Or.inr ⟨ x, hx, le_rfl ⟩

/-! ## Path cost equals DP value -/

/-- The cost of a specific path through the pitch space. -/
noncomputable def pathCost (cantus : ℕ → ℤ) : (n : ℕ) → (Fin (n + 1) → ℤ) → ℝ
  | 0, p => dpCostBase (cantus 0) (p 0)
  | n + 1, p =>
    pathCost cantus n (fun i => p ⟨i.val, Nat.lt_succ_of_lt i.isLt⟩) +
    dpTransition (cantus n) (cantus (n + 1)) (p ⟨n, Nat.lt_succ_of_lt (Nat.lt.base n)⟩) (p ⟨n + 1, Nat.lt.base (n + 1)⟩)

/-
The DP value lower-bounds any path cost ending at the given pitch.
-/
theorem dpValue_le_pathCost (cantus : ℕ → ℤ) (Y : Finset ℤ)
    (n : ℕ) (p : Fin (n + 1) → ℤ)
    (_hY : Y.Nonempty)
    (hp : ∀ i : Fin (n + 1), p i ∈ Y) :
    dpValue cantus Y n (p ⟨n, Nat.lt.base n⟩) ≤ pathCost cantus n p := by
  induction' n with n ih;
  · exact le_rfl;
  · convert le_trans _ ( add_le_add_left ( ih _ _ ) _ ) using 1;
    · rw [ tropical_bellman ];
      convert Finset.inf'_le _ ( hp ⟨ n, Nat.lt_succ_of_lt ( Nat.lt_succ_self _ ) ⟩ ) using 1 ; ring;
    · exact fun i => hp _


-- NEW_FILE: Catalog/Bridges/EMLMachineLearning/TropicalInformationBottleneckDuality.lean
/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Information Bottleneck Duality via Closure Capacities and Neural Operad Rate Regions

This file establishes a rigorous min-plus information bottleneck theorem that unifies:

1. **Closure-theoretic semantics** of representation (closure capacity as primal resource),
2. **Operadic compositional complexity** of neural architectures (finite observer spectra),
3. **Rate–distortion duality** in tropical algebra (Legendre/Fenchel conjugacy).

## Main Results

* `bottleneck_realized_by_observer` — The bottleneck value is realized by some observer.
* `bottleneck_piecewise_affine` — The bottleneck is piecewise affine.
* `slopes_subset_distortion_spectrum` — Slopes lie in the finite distortion spectrum.
* `bottleneck_eq_min_over_observers` — Main duality: observer minimum = admissible infimum.
* `admissible_pair_in_rate_region` — Certified rate region characterization.
* `objective_mono_of_dominates` — Monotone scalarization under domination.
* `certifiedRateRegion_upward_closed` — Rate region is upward closed.
* `exists_extreme_observer_minimizer` — Extreme observer realizes optimum.
* `finite_breakpoints` — Finite breakpoint set.

## Bridge Connections

* Connects to `LawvereRateDistortionDuality.lean`: observer sufficiency generalizes
  the weak duality principle `prime_capacity_le_rate_distortion` to a finite attainment
  result via the monotone scalarization mechanism.
* Connects to `OperadicDeepLearning/Foundations.lean`: the finite observer spectrum
  arises from canonical factorizations of the neural operad generators, and extreme
  observer factors correspond to Pareto-optimal architectures.

## References

* Shannon, C.E. — Coding theorems for a discrete source with a fidelity criterion (1959)
* Litvinov, G.L. — Maslov dequantization, idempotent and tropical mathematics (2007)
* Lawvere, F.W. — Metric spaces, generalized logic, and closed categories (1973)
-/

import Mathlib

open Finset

noncomputable section

namespace TropicalBottleneck

variable {ι R : Type*}

/-! ## Section A: Core Definitions -/

/-- The tropical bottleneck objective for a single observer at parameter β:
    the "affine tropical functional" `cap(i) + β * dist(i)`. -/
def objective [Add R] [Mul R] (cap dist : ι → R) (β : R) (i : ι) : R :=
  cap i + β * dist i

/-- The bottleneck value function: minimum of objectives over the observer set.
    This is the tropical analogue of the rate-distortion function. -/
def bottleneckVal [LinearOrder R] [Add R] [Mul R] (Obs : Finset ι) (cap dist : ι → R)
    (hne : Obs.Nonempty) (β : R) : R :=
  Obs.inf' hne (fun i => objective cap dist β i)

/-- The **certified rate region**: upward closure of the operadic spectrum. -/
def certifiedRateRegion [Preorder R] (Obs : Finset ι) (cap dist : ι → R) :
    Set (R × R) :=
  { p | ∃ i ∈ Obs, cap i ≤ p.1 ∧ dist i ≤ p.2 }

/-! ## Section B: Bottleneck Realization — Core Theorems -/

/-- **Bottleneck Realization**: At every β, the bottleneck value is realized by
    some observer. This is the fundamental finite-envelope theorem.

    Bridge: Connects to `LawvereRateDistortionDuality.prime_capacity_le_rate_distortion`
    by upgrading capacity-distortion inequality to finite attainment. -/
theorem bottleneck_realized_by_observer [LinearOrder R] [Add R] [Mul R]
    (Obs : Finset ι) (cap dist : ι → R) (hne : Obs.Nonempty) (β : R) :
    ∃ i ∈ Obs, bottleneckVal Obs cap dist hne β = objective cap dist β i :=
  exists_mem_eq_inf' hne fun i => objective cap dist β i

/-- **Slope Containment**: At every β, the bottleneck equals cap i + β * dist i
    for some observer i. The slopes of the envelope are observer distortions. -/
theorem slopes_subset_distortion_spectrum [LinearOrder R] [Add R] [Mul R]
    (Obs : Finset ι) (cap dist : ι → R) (hne : Obs.Nonempty) (β : R) :
    ∃ i ∈ Obs, bottleneckVal Obs cap dist hne β = cap i + β * dist i :=
  bottleneck_realized_by_observer Obs cap dist hne β

/-- **Piecewise Affine Structure**: At every β, the bottleneck equals b + β * m
    for intercept b ∈ {cap i} a
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Causal Integration Algebra — Composition Layer

## What We Built in This Cycle

This cycle extends the catalog's `Shared.CausalIntegration.Core` (the lattice-theoretic
formalization of Integrated Information Theory as min-cuts of weighted digraphs) with a new
file, `Shared.CausalIntegration.Composition`, proving four new headline results (zero sorries,
only the standard `propext / Classical.choice / Quot.sound` axioms):

- **`phi_eq_zero_iff`** — the *exact* characterization `Φ(C) = 0 ↔ C.IsDisconnected`. This is
  the genuine converse of the catalog's one-directional `phi_zero_of_disconnected`, closing
  the boundary of the integrated regime. The proof hinges on the minimum over the lattice of
  nontrivial bipartitions being *attained* (`Finset.exists_mem_eq_inf'`).
- **`symmetrize_crossInfo`** — the undirected weight `w i j + w j i` has cut value
  `crossInfo S + crossInfo Sᶜ`, decomposing an undirected cut into the two opposite directed
  cuts via a summation swap.
- **`directSum` + `phi_directSum_eq_zero`** — the block-diagonal direct sum of two nonempty
  systems is always disconnected, so `Φ = 0`. This is the algebraic incarnation of IIT's
  exclusion postulate: causally independent subsystems carry no joint integration.
- Supporting lemmas `directSum_weight_cross_eq_zero`, `crossInfo_natural_cut_eq_zero`,
  `directSum_isDisconnected`, plus two worked `example` instances (a two-node direct sum, and
  the strict positivity `¬IsDisconnected → 0 < Φ` that drops out of `phi_eq_zero_iff`).

These build directly on catalog results `phi_nonneg`, `phi_le_crossInfo`,
`phi_zero_of_disconnected`, `nontrivialBipartitions_nonempty`, and the `crossInfo` / `phi`
API. They are also the graph-theoretic mirror of the tensor-network IIT in
`Computation.IIT.TensorNetworkSchmidt`, where the role of "disconnected ⟹ Φ = 0" is played by
"product state ⟹ Φ = 0".

---

## Direction 1: Weakly Coupled Direct Sums and a Quantitative Φ = O(ε)

We proved `phi_directSum_eq_zero` for the *strict* block-diagonal sum. The natural next step is
the weakly coupled sum `C₁ ⊕ε C₂`, where the cross-blocks carry weights bounded by `ε`. One
expects `Φ(C₁ ⊕ε C₂) ≤ ε · n₁ · n₂`, and — more sharply — that for small enough `ε` the natural
block bipartition *is* the minimizer, giving `Φ(C₁ ⊕ε C₂) = (cross-info of the block cut) = O(ε)`.
The key insight is that `phi_le_crossInfo` already pins Φ below the block cut, whose value is a
sum of at most `n₁ · n₂` terms each `≤ ε`; combined with `crossInfo_le_totalWeight` from Core this
gives the upper bound immediately, and the matching lower bound only requires showing every other
cut exceeds it once `ε` is below the spectral gap of the diagonal blocks. Why now? The `scale`,
`mono`, and the brand-new `directSum_weight_cross_eq_zero` lemmas already isolate exactly the
cross-block contribution, so the perturbation `ε · 𝟙_{cross}` is additive and `crossInfo_mono`
controls its effect cut-by-cut without any new machinery.

## Di
```

## Your task

Produce the deliverables listed above. The Lean file is the source of truth —
your prose must accurately explain it. Both ARTICLE.md and RESEARCH_PAPER.md
MUST be self-contained and publishable without referencing any external files.
State every theorem, definition, and result inline so a reader can follow the
entire argument from the document alone.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). For each algorithm in the algorithms array, provide a name, a detailed explanation of its logic and complexity in 'description', formal step-by-step pseudocode in 'pseudocode', and clean type-hinted Python code in 'code'. Include future directions from Phase A in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
