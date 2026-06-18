
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

**Title**: Proof Phase Transitions: Sharp Thresholds in Random Formal Theories
**Domain**: Physics
**Mathematical framing**: Conjecture: For natural families of randomly generated first-order axiom systems with bounded symbol complexity and a fixed theorem schema φ_n, there exists a nontrivial critical clause-density parameter c* such that the probability that φ_n has a proof of length polynomial in n exhibits a sharp threshold at c* as n → ∞. Test: Define an ensemble of random formal theories (for example, random Horn, equational, or bounded-quantifier axiom sets), fix theorem families φ_n, and empirically/theoretically measure whether short-provability transitions from asymptotically unlikely to asymptotically likely within a vanishing-width window around some c*. The conjecture is refuted if no sharp threshold appears across robust ensembles or if the transition width remains extensive. Impact: Establishes a statistical-mechanics theory of provability, giving predictive tools for theorem-prover difficulty, phase diagrams for automated reasoning, and new links between proof complexity, random structures, and computational hardness.
Research domain: Physics
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
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
    for intercept b ∈ {cap i} and slope m ∈ {dist i}. -/
theorem bottleneck_piecewise_affine [LinearOrder R] [Add R] [Mul R]
    (Obs : Finset ι) (cap dist : ι → R) (hne : Obs.Nonempty) :
    ∀ β, ∃ m ∈ Obs.image dist, ∃ b ∈ Obs.image cap,
      bottleneckVal Obs cap dist hne β = b + β * m := by
  intro β
  obtain ⟨i, hi, h_eq⟩ := bottleneck_realized_by_observer Obs cap dist hne β
  exact ⟨dist i, mem_image.mpr ⟨i, hi, rfl⟩, cap i, mem_image.mpr ⟨i, hi, rfl⟩, h_eq⟩

/-- **Extreme Observer Minimizer**: At every β, some observer achieves the
    minimum among all observers.

    Connects to `OperadicDeepLearning/Foundations.lean`: extreme observer factors
    correspond to Pareto-optimal architecture factorizations. -/
theorem exists_extreme_observer_minimizer [LinearOrder R] [Add R] [Mul R]
    (Obs : Finset ι) (cap dist : ι → R) (hne : Obs.Nonempty) (β : R) :
    ∃ i ∈ Obs, ∀ j ∈ Obs, objective cap dist β i ≤ objective cap dist β j :=
  exists_min_image Obs (objective cap dist β) hne

/-! ## Section C: Scalarization Monotonicity -/

/-- Arithmetic helper: a + β * b ≤ c + β * d when a ≤ c, b ≤ d, and β ≥ 0. -/
private lemma add_mul_le_add_mul [LinearOrder R] [Semiring R] [IsOrderedRing R]
    {a b c d β : R} (hab : a ≤ c) (hcd : b ≤ d) (hβ : 0 ≤ β) :
    a + β * b ≤ c + β * d :=
  add_le_add hab (mul_le_mul_of_nonneg_left hcd hβ)

/-- **Scalarization Monotonicity**: Domination implies objective ordering for β ≥ 0.
    This is the key lemma driving the main duality theorem. -/
theorem objective_mono_of_dominates [LinearOrder R] [Semiring R] [IsOrderedRing R]
    (cap dist : ι → R) (i j : ι) (β : R)
    (hcap : cap i ≤ cap j) (hdist : dist i ≤ dist j) (hβ : 0 ≤ β) :
    objective cap dist β i ≤ objective cap dist β j :=
  add_mul_le_add_mul hcap hdist hβ

/-! ## Section D: Main Duality Theorem -/

/-- **Main Tropical Bottleneck Duality Theorem**: Under observer sufficiency,
    the infimum over all admissible latents equals the minimum over observers.

    `min_{i ∈ Obs}(cap_i + β * dist_i) = inf_{z ∈ Adm}(Cap(z) + β * Dist(z))`

    This is the tropical information bottleneck duality: closure capacities (primal)
    and operadic spectra (dual) yield the same bottleneck value through min-plus
    Legendre conjugacy.

    The proof follows Strategy A:
    1. Observer sufficiency provides domination for every admissible latent.
    2. Monotone scalarization (`add_mul_le_add_mul`) upgrades domination to objective bounds.
    3. Realizability embeds the observer spectrum into the admissible image.
    4. `le_antisymm` combines both directions via `le_csInf` and `csInf_le`. -/
theorem bottleneck_eq_min_over_observers [ConditionallyCompleteLinearOrder R]
    [Semiring R] [IsOrderedRing R]
    (Obs : Finset ι) (cap_obs dist_obs : ι → R) (hne : Obs.Nonempty)
    (Z : Type*) (Adm : Set Z) (Cap Dist : Z → R)
    (hAdm : Adm.Nonempty)
    (hObs_adm : ∀ i ∈ Obs, ∃ z ∈ Adm, Cap z = cap_obs i ∧ Dist z = dist_obs i)
    (hSuff : ∀ z ∈ Adm, ∃ i ∈ Obs, cap_obs i ≤ Cap z ∧ dist_obs i ≤ Dist z)
    (β : R) (hβ : 0 ≤ β) :
    Obs.inf' hne (fun i => cap_obs i + β * dist_obs i) =
      sInf ((fun z => Cap z + β * Dist z) '' Adm) := by
  apply le_antisymm
  · -- Direction 1: inf' ≤ sInf (observer minimum bounds every admissible)
    apply le_csInf (hAdm.image _)
    rintro _ ⟨z, hz, rfl⟩
    obtain ⟨i, hi, hci, hdi⟩ := hSuff z hz
    exact le_trans (inf'_le _ hi) (add_mul_le_add_mul hci hdi hβ)
  · -- Direction 2: sInf ≤ inf' (each observer value appears in the image)
    apply Finset.le_inf'
    intro i hi
    obtain ⟨z, hzAdm, hzCap, hzDist⟩ := hObs_adm i hi
    have hmem : Cap z + β * Dist z ∈ (fun z => Cap z + β * Dist z) '' Adm :=
      ⟨z, hzAdm, rfl⟩
    have hbdd : BddBelow ((fun z => Cap z + β * Dist z) '' Adm) := by
      use Obs.inf' hne (fun i => cap
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Proof Phase Transitions

## 1. Probabilistic Sharp Threshold for Random Implicational Theories

The natural next step is to formalize the actual probabilistic phase transition. Consider the random implicational theory on `Fin n` where each directed edge is included independently with probability `p`. Our monotonicity theorem (theory_extension_monotone) establishes that derivability is a monotone increasing property in the edge set. By Friedgut's sharp threshold theorem for monotone graph properties, the probability that a fixed pair `(0, n-1)` is derivable must transition from near 0 to near 1 within a window of width `o(1)` around some critical probability `p*(n)`.

The key insight is that our `Derivable` predicate is exactly a monotone Boolean function on the Boolean hypercube `{0,1}^{n²}` (indexed by potential edges), and Friedgut's theorem applies to any such function with a coarse threshold.

Why now? We have the monotonicity infrastructure (Theorem 2) and the boundary characterizations (Theorems 1 and 3) already formalized. The remaining piece is formalizing Friedgut's theorem itself, which requires Fourier analysis on the Boolean cube — a significant but tractable formalization target that would have broad applications beyond this project.

## 2. Proof Length Phase Transitions and Resolution Complexity

A deeper conjecture concerns not just derivability but *short* derivability: is there a sharp threshold for the existence of derivations of length ≤ L(n)? Our chain_derivable theorem shows that the chain theory (with n edges) gives a derivation of length exactly n. The conjecture is that in a random theory with edge probability p, the minimum derivation length exhibits a phase transition: below p*, minimum proofs are exponentially long (or nonexistent); above p*, polynomial-length proofs exist with high probability.

The key insight is that this connects our framework to proof complexity theory. The implicational derivation system is equivalent to monotone resolution, and resolution complexity lower bounds are known for random k-CNF. Formalizing this connection would bridge combinatorial proof complexity with the random graph threshold machinery.

Why now? The chain_axiom_critical theorem already demonstrates that minimal-density theories have tight proof structure. Extending this to random theories requires formalizing the relationship between graph diameter and derivation length, which builds directly on our chain theory infrastructure.

## 3. Multi-Conclusion Theories and Hypergraph Phase Transitions

Our framework models single-conclusion implications (a → b). A natural generalization is multi-premise implications: (a₁ ∧ a₂ ∧ ... ∧ aₖ) → b, which correspond to directed hypergraphs. The derivability closure becomes k-uniform hypergraph reachability, and the phase transition behavior should depend on k in a way analogous to the k-SAT threshold phenomenon.

The key insight is that for k ≥ 2, the phase transition should
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
