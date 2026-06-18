
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
    {"name": "Descriptive and Professional Title of the Python Demo", "description": "A comprehensive, high-quality description of what this Python demo calculates and shows mathematically.", "code": "# full Python source..."}
  ],
  "algorithms": [
    {
      "name": "Formal Mathematical Title of the Algorithm",
      "description": "Detailed in-depth explanation of the algorithm, its mathematical foundation, computational complexity, and role in the pipeline.",
      "pseudocode": "Formal, structured step-by-step pseudocode detailing the logic.",
      "code": "# full Python source with type hints..."
    }
  ],
  "visualizations": [
    {"name": "Descriptive Visualization Title", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Beautiful Math-Rich Interactive Widget Title", "description": "Detailed description of the interactive widget and what users can explore.", "html": "<!DOCTYPE html><html>...</html>"}
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

**Title**: This cycle fused two strands of the catalog that had been developed
**Domain**: Novelty
**Mathematical framing**: # Future Directions: Conserved Quantities along Reduction Paths

## Synthesis

This cycle fused two strands of the catalog that had been developed
independently: the **conserved-quantity view of cryptographic reductions**
(`Catalog/Cryptography/AdvantageMetric.lean`, where *advantage* behaves like a
pseudo-metric coordinate and the hybrid argument is sub-additivity) and the
**Fibonacci / Carmichael primitive-divisor** work
(`Catalog/Shared/CarmichaelProof.lean`, `Catalog/Novelty/FibApparitionExistence.lean`).

The unifying observation is that *both* theories are about a **length/valuation
functional on a discrete path** and the morphisms that conserve it. A sequence
of cryptographic games is a discrete path in a pseudometric space; the advantage
is its length; a reduction is a Lipschitz morphism of path spaces; and the
"advantage-loss factor" is nothing but a Lipschitz constant. Dually, in number
theory the Fibonacci map is a *gcd-conserving morphism of the divisor lattice*
(`gcd (fib m) (fib n) = fib (gcd m n)`), and this conserved quantity is the
homotopy-invariant heart of the primitive-divisor (Carmichael) argument.

New file: `Catalog/Cryptography/ConservedPathReductions.lean`.

## Results Summary

All six theorems are proved with `sorry = 0` and depend only on the standard
axioms (`propext`, `Classical.choice`, `Quot.sound`).

- `gameDist_path_le` — endpoint distance ≤ path length: the metric-space
  generalization of `AdvantageMetric.hybrid_argument`, now valid in *any*
  pseudometric space rather than over a real coordinate.
- `pathLength_concat` — the path-length functional is additive under
  concatenation at any intermediate game `k ≤ n`: the structural form of the
  triangle conservation law `AdvantageMetric.advantage_triangle`.
- `lipschitz_reduction_contracts_path` — a `K`-Lipschitz reduction multiplies
  the path length by at most `K`. This single inequality subsumes both the
  multiplicative law `AdvantageMetric.reduction_composition` and the additive
  hybrid bound.
- `reduction_end_to_end_bound` — chaining the previous two into the headline
  quantitative reduction estimate `dist (φ(f 0)) (φ(f n)) ≤ K · pathLength f n`.
- `fib_gcd_conservation` — the gcd-conserved quantity on Fibonacci, read as a
  conservation law (catalog synthesis with the Carmichael work).
- `fib_primitivity_bridge` — a clean, self-contained restatement and proof of
  the conserved-quantity heart of `CarmichaelProof.bridge_lemma`: local
  non-divisibility on *proper divisors* collapses to global non-divisibility on
  *all smaller indices*, purely via gcd conservation.

## Research Directions

### 1. Metric path spaces with a genuine fundamental-groupoid structure for games

Replace the index set `ℕ` by an arbitrary directed graph of games and define the
length functional over walks, then quotient by the relation "same endpoints,
equal length" to obtain a fundamental-groupoid-like object whose morphisms are
exactly the admissible hybrid rewrites. **The key insight is** that the hybrid
argument is path-length sub-additivity, so the *only* homotopy-invariant of a
game walk that survives is its endpoint distance — every legitimate hybrid proof
is a homotopy of walks with non-increasing length. **Why now?** With
`pathLength_concat` and `gameDist_path_le` already proved, the concatenation and
endpoint-bound axioms of a length-graded groupoid are in hand; only the quotient
construction remains, and it is falsifiable by exhibiting two equal-endpoint
walks whose minimal lengths differ in a way the groupoid laws forbid.

### 2. Sharpness of the Lipschitz reduction bound

Conjecture: `lipschitz_reduction_contracts_path` is tight — for every `K` and
`n` there is a pseudometric pair and a `K`-Lipschitz `φ` and a path `f` with
`pathLength (φ ∘ f) n = K · pathLength f n`. **The key insight is** that
equality forces `φ` to be a *dilation* on every consecutive pair `(f i, f(i+1))`,
so tightness is equivalent to the existence of a geodesic path on which `φ`
achieves its Lipschitz constant at every step. **Why now?** The inequality is
formalized; the matching lower bound is a finite construction (take `α = β = ℝ`,
`φ x = K x`, `f i = i`) that can be checked mechanically, turning a qualitative
"the constant is best possible" remark into a theorem.

### 3. A multiplicative Lipschitz constant for the Fibonacci valuation

The `p`-adic valuation of `fib n` along the divisor lattice should obey a
Lipschitz-type law analogous to `lipschitz_reduction_contracts_path`, with the
gcd playing the role of the metric meet. Conjecture: `v_p(fib n)` is a monotone,
sub-additive functional on the divisor lattice whose "steps" are controlled by
the rank of apparition. **The key insight is** that `fib_gcd_conservation` makes
the Fibonacci map a lattice morphism, so divisibility distances contract exactly
as metric distances do under a Lipschitz reduction. **Why now?**
`fib_primitivity_bridge` already exposes the conserved quantity; quantifying *how
much* valuation is gained per divisor step would upgrade the primitive-divisor
existence statement to a primitive-divisor *counting* statement.

### 4. Closing the Carmichael infinite tail via the conserved quantity

`Catalog/Shared/CarmichaelProof.lean` discharges every composite `n ≤ 10000` by
`native_decide` but leaves the tail `n > 10000` as a `sorry`. Conjecture: the
tail is provable by combining `fib_primitivity_bridge` (this file) with a
Zsygmondy/Carmichael lower bound `fib n > ∏_{d | n, d < n} (fib d)^{...}`, so the
primitive part `primPart n` is forced to exceed `1` for all large `n`. **The key
insight is** that the bridge lemma already reduces primitivity to a *single*
inequality about the size of the primitive part, eliminating the per-`n` search.
**Why now?** The bridge is formalized axiom-clean and independent of the finite
verification, so the tail reduces to an analytic growth estimate on Fibonacci
products rather than an infinite case analysis.

### 5. An ∞-categorical localization inverting "negligible" reductions

Define the class of reductions with Lipschitz constant `K = 1` (advantage
preserving) and localize the category of game path spaces at the morphisms whose
constant is "negligible" in the security parameter. Conjecture: the localization
identifies exactly the games that are computationally indistinguishable, so
"indistinguishability" *is* isomorphism in the localized ∞-category. **The key
insight is** that `reduction_end_to_end_bound` makes the advantage a functorial
length that the localization must send to zero, so negligibility becomes a
formal weak-equivalence condition. **Why now?** With the Lipschitz-morphism
layer proved, the weak equivalences form a well-defined class (closed under
composition by `reduction_composition`), which is the precondition for a calculus
of fractions and hence a falsifiable model-categorical presentation.

Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Cryptography/ConservedPathReductions.lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Conserved Quantities along Reduction Paths

This file fuses two strands of the catalog that were developed independently:

* the **conserved-quantity view of cryptographic reductions**
  (`Catalog/Cryptography/AdvantageMetric.lean`, where *advantage* behaves like a
  pseudo-metric coordinate and the hybrid argument is sub-additivity), and
* the **Fibonacci / Carmichael primitive-divisor** work
  (`Catalog/Shared/CarmichaelProof.lean`,
  `Catalog/Novelty/FibApparitionExistence.lean`).

The unifying observation is that *both* theories are about a **length / valuation
functional on a discrete path** and the morphisms that conserve it.

A sequence of cryptographic games is a discrete path in a pseudometric space; the
advantage is its **length**; a reduction is a **Lipschitz morphism** of path
spaces; and the "advantage-loss factor" is nothing but a **Lipschitz constant**.
Dually, in number theory the Fibonacci map is a *gcd-conserving morphism of the
divisor lattice* (`gcd (fib m) (fib n) = fib (gcd m n)`), and this conserved
quantity is the homotopy-invariant heart of the primitive-divisor (Carmichael)
argument.

## Main results

* `gameDist_path_le` — endpoint distance ≤ path length: the metric-space
  generalization of `AdvantageMetric.hybrid_argument`, valid in *any* pseudometric
  space rather than over a single real coordinate.
* `pathLength_concat` — the path-length functional is additive under concatenation
  at any intermediate game `k ≤ n`: the structural form of the triangle
  conservation law `AdvantageMetric.advantage_triangle`.
* `lipschitz_reduction_contracts_path` — a `K`-Lipschitz reduction multiplies the
  path length by at most `K`. This single inequality subsumes both the
  multiplicative law `AdvantageMetric.reduction_composition` and the additive
  hybrid bound `AdvantageMetric.prg_stretch_amplification`.
* `reduction_end_to_end_bound` — chaining the previous two into the headline
  quantitative reduction estimate `dist (φ(f 0)) (φ(f n)) ≤ K · pathLength f n`.
* `fib_gcd_conservation` — the gcd-conserved quantity on Fibonacci, read as a
  conservation law (catalog synthesis with the Carmichael work).
* `fib_primitivity_bridge` — a clean, self-contained restatement and proof of the
  conserved-quantity heart of `CarmichaelProof.bridge_lemma`: local
  non-divisibility on *proper divisors* collapses to global non-divisibility on
  *all smaller indices*, purely via gcd conservation.

-- !-- Lab Notebook -- !--
Hypothesis: The cryptographic hybrid/composition calculus and the Fibonacci
  primitive-divisor argument are two instances of one structure: a non-negative
  *length functional* on a discrete path, together with morphisms that contract
  it. On the crypto side the functional is path length in a pseudometric space;
  on the number-theory side it is the gcd-valuation of the Fibonacci map. If
  true, the hybrid argument, reduction composition, and the Carmichael bridge
  should all become one-line consequences of (a) telescoping/triangle, (b)
  Lipschitz monotonicity, and (c) gcd conservation `Nat.fib_gcd`.
Result: Confirmed. `gameDist_path_le` is exactly `dist_le_range_sum_dist`;
  `pathLength_concat` is `Finset.sum_range_add_sum_Ico`;
  `lipschitz_reduction_contracts_path` is `Finset.sum_le_sum` + `Finset.mul_sum`;
  `reduction_end_to_end_bound` chains the two; `fib_gcd_conservation` is
  `Nat.fib_gcd`; and `fib_primitivity_bridge` collapses to a single application
  of gcd conservation, mirroring `CarmichaelProof.bridge_lemma`.
Insight: "Advantage", "path length", and "gcd-valuation" are the same conserved
  coordinate viewed in three categories (ℝ, a pseudometric space, the divisor
  lattice). Sub-additivity along a path and contraction under a morphism are the
  only two laws needed; the entire quantitative theory is their interplay.
Failure analysis: The Lipschitz contraction does *not* need `0 ≤ K`: the
  termwise bounds `dist (φ x) (φ y) ≤ K * dist x y` are summed directly, so
  `Finset.sum_le_sum` + `Finset.mul_sum` closes it for any real `K` (a pleasant
  surprise — the nonnegativity of a Lipschitz constant is automatic from a
  single step and never used). The bridge lemma genuinely needs `0 < n` so that
  `gcd n k` is a *positive proper* divisor of `n`, otherwise the conserved
  quantity lands outside the range where local non-divisibility is assumed.
-- !-- Lab Notebook -- !--
-/

namespace Cryptography.ConservedPathReductions

open Finset

/-! ## The length functional on a discrete path -/

/-- The **path length** of a discrete walk `f : ℕ → α` through the first `n`
steps of a pseudometric space: the sum of consecutive distances. In the
cryptographic reading `f` is a sequence of games and `pathLength f n` is the
end-to-end *advantage* accumulated across `n` hybrids. -/
def pathLength {α : Type*} [PseudoMetricSpace α] (f : ℕ → α) (n : ℕ) : ℝ :=
  ∑ i ∈ Finset.range n, dist (f i) (f (i + 1))

@[simp] theorem pathLength_zero {α : Type*} [PseudoMetricSpace α] (f : ℕ → α) :
    pathLength f 0 = 0 := by simp [pathLength]

theorem pathLength_succ {α : Type*} [PseudoMetricSpace α] (f : ℕ → α) (n : ℕ) :
    pathLength f (n + 1) = pathLength f n + dist (f n) (f (n + 1)) := by
  simp [pathLength, Finset.sum_range_succ]

theorem pathLength_nonneg {α : Type*} [PseudoMetricSpace α] (f : ℕ → α) (n : ℕ) :
    0 ≤ pathLength f n :=
  Finset.sum_nonneg fun _ _ => dist_nonneg

/-! ## The conservation laws of reduction paths -/

-- !-- The end-to-end distance is bounded by the accumulated path length: this is
-- the iterated triangle inequality (telescoping), i.e. `dist_le_range_sum_dist`.
-- It is the pseudometric generalization of `AdvantageMetric.hybrid_argument`. -- !--
/-- **Endpoint bound (hybrid argument).** The distance between the endpoints of a
walk is at most its path length. Generalizes `AdvantageMetric.hybrid_argument`
from the real advantage coordinate to an arbitrary pseudometric space. -/
theorem gameDist_path_le {α : Type*} [PseudoMetricSpace α] (f : ℕ → α) (n : ℕ) :
    dist (f 0) (f n) ≤ pathLength f n :=
  dist_le_range_sum_dist f n

-- !-- Splitting the range `[0,n) = [0,k) ∪ [k,n)` via `sum_range_add_sum_Ico`
-- gives additivity of the length functional under concatenation. -- !--
/-- **Concatenation additivity.** The path-length functional is additive when a
walk is split at any intermediate game `k ≤ n`. This is the structural form of the
triangle conservation law `AdvantageMetric.advantage_triangle`. -/
theorem pathLength_concat {α : Type*} [PseudoMetricSpace α] (f : ℕ → α)
    (k n : ℕ) (hk : k ≤ n) :
    pathLength f n =
      pathLength f k + ∑ i ∈ Finset.Ico k n, dist (f i) (f (i + 1)) := by
  unfold pathLength
  rw [Finset.sum_range_add_sum_Ico _ hk]

-- !-- Each consecutive distance contracts by `K` under a `K`-Lipschitz map, so
-- summing and pulling `K` out with `Finset.mul_sum` contracts the whole length.
-- This subsumes `AdvantageMetric.reduction_composition`. -- !--
/-- **Lipschitz reduction contracts path length.** A `K`-Lipschitz reduction `φ`
multiplies the path length by at most `K`. This single inequality subsumes both
the multiplicative law `AdvantageMetric.reduction_composition` and the additive
hybrid bound `AdvantageMetric.prg_stretch_amplification`. -/
theorem lipschitz_reduction_contracts_path
    {α β : Type*} [PseudoMetricSpace α] [PseudoMetricSpace β]
    (φ : α → β) (K : ℝ)
    (hφ : ∀ x y, dist (φ x) (φ y) ≤ K * dist x y)
    (f : ℕ → α) (n : ℕ) :
    pathLength (φ ∘ f) n ≤ K * pathLength f n := by
  unfold pathLength
  rw [Finset.mul_sum]
  exact Finset.sum_le_sum fun i _ => hφ (f i) (f (i + 1))

-- !-- Chain the endpoint bound (for the reduced walk `φ ∘ f`) with the Lipschitz
-- contraction: `dist (φ(f 0)) (φ(f n)) ≤ pathLength (φ∘f) n ≤ K · pathLength f n`. -- !--
/-- **End-to-
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Conserved Quantities along Reduction Paths

## Synthesis

This cycle fused two strands of the catalog that had been developed
independently: the **conserved-quantity view of cryptographic reductions**
(`Catalog/Cryptography/AdvantageMetric.lean`, where *advantage* behaves like a
pseudo-metric coordinate and the hybrid argument is sub-additivity) and the
**Fibonacci / Carmichael primitive-divisor** work
(`Catalog/Shared/CarmichaelProof.lean`,
`Catalog/Novelty/FibApparitionExistence.lean`).

The unifying observation is that *both* theories are about a **length / valuation
functional on a discrete path** and the morphisms that conserve it. A sequence of
cryptographic games is a discrete path in a pseudometric space; the advantage is
its length; a reduction is a Lipschitz morphism of path spaces; and the
"advantage-loss factor" is nothing but a Lipschitz constant. Dually, in number
theory the Fibonacci map is a *gcd-conserving morphism of the divisor lattice*
(`gcd (fib m) (fib n) = fib (gcd m n)`), and this conserved quantity is the
homotopy-invariant heart of the primitive-divisor (Carmichael) argument.

New file: `Catalog/Cryptography/ConservedPathReductions.lean`.

## Results Summary

All results are proved with `sorry = 0` and depend only on the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`); the two number-theoretic results
do not even use `Classical.choice`.

- `pathLength` — the length functional on a discrete walk in a pseudometric
  space, with the structural lemmas `pathLength_zero`, `pathLength_succ`, and
  `pathLength_nonneg`.
- `gameDist_path_le` — endpoint distance ≤ path length: the metric-space
  generalization of `AdvantageMetric.hybrid_argument`, now valid in *any*
  pseudometric space rather than over a single real coordinate.
- `pathLength_concat` — the path-length functional is additive under
  concatenation at any intermediate game `k ≤ n`: the structural form of the
  triangle conservation law `AdvantageMetric.advantage_triangle`.
- `lipschitz_reduction_contracts_path` — a `K`-Lipschitz reduction multiplies
  the path length by at most `K`. This single inequality subsumes both the
  multiplicative law `AdvantageMetric.reduction_composition` and the additive
  hybrid bound `AdvantageMetric.prg_stretch_amplification`. (A pleasant
  discovery: the proof never uses `0 ≤ K`, so the hypothesis was dropped and the
  statement is strictly more general than expected.)
- `reduction_end_to_end_bound` — chaining the previous two into the headline
  quantitative reduction estimate `dist (φ(f 0)) (φ(f n)) ≤ K · pathLength f n`.
- `fib_gcd_conservation` — the gcd-conserved quantity on Fibonacci, read as a
  conservation law (catalog synthesis with the Carmichael work).
- `fib_primitivity_bridge` — a clean, self-contained restatement and proof of
  the conserved-quantity heart of `CarmichaelProof.bridge_lemma`: local
  non-divisibility on *proper divisors* collapses to global non-divisibility on
  *all smal
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
of objects (not placeholder strings). For each algorithm in the algorithms array, provide a clear, professional mathematical title in 'name' (do not use generic placeholders; this will be displayed as the header on the interactive site), a detailed explanation of its logic and complexity in 'description', formal step-by-step pseudocode in 'pseudocode', and clean type-hinted Python code in 'code'. For each Python demo in the demos array, provide a highly descriptive title in 'name', a comprehensive functional description in 'description', and the implementation code in 'code'. For each interactive HTML demo in interactive_demos, provide a beautiful title in 'title' and a detailed description in 'description'. Include future directions from Phase A in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
