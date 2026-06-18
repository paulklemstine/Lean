
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
State theorems inline in your article and paper — they must be
self-contained and publishable without external references.


## Concept

**Title**: ML Universal Approximation: Width vs Depth Trade-offs
**Domain**: Applications
**Mathematical framing**: Prove that depth-L ReLU networks of width (n+4) can approximate any continuous function on [-1,1]^n to epsilon accuracy. Show that the required width grows as O(epsilon^{-1/n}) for shallow networks but only O(log(1/epsilon)) for deep networks. Formalize the depth separation theorem: there exist functions representable by depth-L+1 networks of polynomial size that require exponential size in depth L.
Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/MachineLearning/ReLUDepthWidth/Basic.lean
import Mathlib

/-!
# ReLU Networks: Width vs Depth Trade-offs and Depth Separation

This file develops a self-contained, fully formal account of the
**depth-separation phenomenon** for ReLU networks, phrased through the
classical *tent map* (a width-2 one-hidden-layer ReLU block) and its
iterated compositions.

## The construction

The tent map `tent x = 1 - |2x - 1|` is a single ReLU layer of width 2
(Lemma `tent_relu_repr`). Composing it `k` times yields a function
`tent^[k]` computed by a **depth-`k`, constant-width** ReLU network of
total size `O(k)`. Although its output stays bounded in `[0,1]`, the
`k`-fold tent develops an exponentially steep oscillation: it rises from
`0` to `1` over an interval of width `2^{-k}` (Lemmas `tent_iterate_zero`,
`tent_iterate_peak`). Equivalently its Lipschitz constant is `2^k`
(Theorem `tent_iterate_lipschitz`).

## The separation

Theorem `relu_depth_separation` shows that **any** function `g` whose
Lipschitz constant `K` satisfies `K · 2^{-k} + 2ε < 1` cannot approximate
`tent^[k]` to accuracy `ε` on `[0,1]`. A bounded-weight shallow ReLU
network is exactly such a Lipschitz function, so it must have Lipschitz
constant — and hence (weight × width) budget — growing like `2^k` to even
match a depth-`k` network. This is the depth-separation theorem in its
analytic, ReLU-native form: equal output range, exponential oscillation.

## Catalog synthesis

This complements `MachineLearning.DepthSeparation.Separation`
(`not_uniformApprox_of_small_lipschitz`), which proves a Lipschitz
obstruction for the iterated *exponential* tower (whose *range* explodes).
Here the range stays in `[0,1]` and the obstruction comes from the
*oscillation* packed into a tiny interval — the genuinely neural
(piecewise-linear) mechanism behind Telgarsky-style depth separation.

## Main results

* `tent_relu_repr` — the tent map is a width-2 ReLU layer
* `tent_lipschitz` — the tent map is `2`-Lipschitz
* `tent_iterate_lipschitz` — `tent^[k]` is `2^k`-Lipschitz (deep net)
* `tent_iterate_zero`, `tent_iterate_peak` — the exponentially steep ramp
* `relu_depth_separation` — Lipschitz functions cannot approximate `tent^[k]`
-/

noncomputable section

open Set

namespace ReLUDepthWidth

/-- The ReLU activation `relu x = max x 0`. -/
def relu (x : ℝ) : ℝ := max x 0

/-- The tent map `tent x = 1 - |2x - 1|`, the canonical depth-1 ReLU block.
On `[0,1]` it is the symmetric triangle peaking at `x = 1/2`. -/
def tent (x : ℝ) : ℝ := 1 - |2 * x - 1|

/-- The tent map is realized by a single ReLU layer of width two. -/
-- !-- |y| = relu y + relu (-y), so the tent map is a width-2 one-hidden-layer ReLU network. -- !--
theorem tent_relu_repr (x : ℝ) :
    tent x = 1 - relu (2 * x - 1) - relu (1 - 2 * x) := by
  unfold tent relu; grind

/-- The tent map is `2`-Lipschitz (a single ReLU block of slope ±2). -/
-- !-- tent = 1 - |2x-1|; abs is 1-Lipschitz, so tent is 2-Lipschitz via abs_sub_abs_le_abs_sub. -- !--
theorem tent_lipschitz : LipschitzWith 2 tent := by
  refine' LipschitzWith.of_dist_le_mul _
  norm_num [Real.dist_eq, tent]
  exact fun x y => abs_le.mpr
    ⟨by cases abs_cases (2 * x - 1) <;> cases abs_cases (2 * y - 1) <;>
        cases abs_cases (x - y) <;> linarith,
     by cases abs_cases (2 * x - 1) <;> cases abs_cases (2 * y - 1) <;>
        cases abs_cases (x - y) <;> linarith⟩

/-- The tent map sends `[0,1]` into `[0,1]`. -/
-- !-- For x ∈ [0,1], -1 ≤ 2x-1 ≤ 1, so |2x-1| ≤ 1 and 0 ≤ 1 - |2x-1| ≤ 1. -- !--
theorem tent_mapsTo : MapsTo tent (Icc (0:ℝ) 1) (Icc (0:ℝ) 1) := by
  exact fun x hx => ⟨sub_nonneg.2 <| by
      cases abs_cases (2 * x - 1) <;> linarith [hx.1, hx.2],
    sub_le_self _ <| abs_nonneg _⟩

/-- On the ascending branch `x ≤ 1/2`, the tent map is exactly `2x`. -/
-- !-- For x ≤ 1/2, 2x-1 ≤ 0 so |2x-1| = 1-2x and tent x = 2x. -- !--
theorem tent_eq_two_mul {x : ℝ} (hx : x ≤ 1 / 2) : tent x = 2 * x := by
  unfold tent; rw [abs_of_nonpos] <;> linarith

/-- A depth-`k` tent network is `2^k`-Lipschitz: the Lipschitz constant grows
exponentially with depth at constant width. -/
-- !-- LipschitzWith.iterate: composing a 2-Lipschitz map k times gives 2^k-Lipschitz. -- !--
theorem tent_iterate_lipschitz (k : ℕ) : LipschitzWith (2 ^ k) (tent^[k]) := by
  convert LipschitzWith.iterate tent_lipschitz k using 1

/-- The `k`-fold tent fixes the left endpoint: `tent^[k] 0 = 0`. -/
-- !-- tent 0 = 0, and the orbit of the fixed point 0 stays at 0; induction on k. -- !--
theorem tent_iterate_zero (k : ℕ) : tent^[k] (0 : ℝ) = 0 := by
  induction k <;> simp_all +decide [Function.iterate_succ_apply']
  unfold tent; norm_num

/-- The first peak of the `k`-fold tent occurs at `x = (1/2)^k`, where the
value is `1`. Combined with `tent_iterate_zero`, the function climbs from
`0` to `1` over an interval of width `2^{-k}`. -/
-- !-- tent ((1/2)^(k+1)) = (1/2)^k since (1/2)^(k+1) ≤ 1/2; then induct using tent_eq_two_mul. -- !--
theorem tent_iterate_peak (k : ℕ) : tent^[k] ((1 / 2 : ℝ) ^ k) = 1 := by
  induction' k with k ih <;> simp_all +decide [Function.iterate_succ_apply']
  have h_tent_half : tent ((1 / 2 : ℝ) ^ (k + 1)) = (1 / 2 : ℝ) ^ k := by
    rw [tent_eq_two_mul]
    · ring
    · exact mul_le_of_le_one_left (by norm_num) (pow_le_one₀ (by norm_num) (by norm_num))
  rw [← Function.iterate_succ_apply' tent k]; aesop

/-- **ReLU depth-separation theorem.** If `g` is `K`-Lipschitz with
`K · 2^{-k} + 2ε < 1`, then `g` cannot approximate `tent^[k]` within `ε`
uniformly on `[0,1]`. Hence approximating a depth-`k` constant-width tent
network with a Lipschitz (e.g. bounded-weight shallow) network forces the
Lipschitz constant to grow like `2^k`. -/
-- !-- f rises 0→1 over width 2^{-k}; a K-Lipschitz g within ε at both endpoints forces
--     1 ≤ 2ε + K·2^{-k}, contradicting the hypothesis. -- !--
theorem relu_depth_separation (k : ℕ) (g : ℝ → ℝ) (K ε : ℝ)
    (hg : ∀ x y, |g x - g y| ≤ K * |x - y|)
    (hKε : K * (1 / 2 : ℝ) ^ k + 2 * ε < 1) :
    ¬ (∀ x ∈ Icc (0 : ℝ) 1, |tent^[k] x - g x| ≤ ε) := by
  contrapose! hKε
  have h₁ := hKε 0 ⟨by norm_num, by norm_num⟩
  have h₂ := hKε ((1 / 2) ^ k) ⟨by positivity, pow_le_one₀ (by norm_num) (by norm_num)⟩
  norm_num [abs_le, tent_iterate_zero, tent_iterate_peak] at *
  have := hg 0 ((1 / 2) ^ k)
  norm_num [abs_of_nonneg, pow_nonneg] at *
  linarith

/-- The separation threshold is sharp: `tent^[k]` approximates itself with
`ε = 0`, and there `K = 2^k` gives `K · 2^{-k} + 0 = 1`, exactly failing the
strict inequality of `relu_depth_separation`. This shows the hypothesis
`K · 2^{-k} + 2ε < 1` cannot be relaxed to `≤`. -/
-- !-- (2^k)·(1/2)^k = (2·1/2)^k = 1, so the budget exactly hits the threshold. -- !--
theorem relu_depth_separation_sharp (k : ℕ) :
    (2 ^ k : ℝ) * (1 / 2 : ℝ) ^ k + 2 * 0 = 1 := by
  norm_num [← mul_pow]

end ReLUDepthWidth

/-- Illustration: at depth `k = 3`, the constant function `1/2` (which is
`0`-Lipschitz, `K = 0`, the extreme "shallow" case) fails to
approximate the depth-3 tent network better than the threshold, since
`1 · (1/2)^3 + 2·0 = 1/8 < 1`. -/
example : ¬ (∀ x ∈ Icc (0 : ℝ) 1,
    |ReLUDepthWidth.tent^[3] x - (fun _ => (1/2 : ℝ)) x| ≤ (3/8 : ℝ)) := by
  apply ReLUDepthWidth.relu_depth_separation 3 (fun _ => (1/2 : ℝ)) 0 (3/8)
  · intro x y; simp
  · norm_num

end



-- NEW_FILE: Catalog/Pythagorean/TropicalEntanglement/Defs.lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Tropical Entanglement Certificates — Core Definitions

This file introduces the core definitions for **tropical entanglement certificates**,
a new framework connecting tropical geometry and quantum information theory.

The central idea is that multipartite quantum entanglement leaves a detectable
"tropical footprint" in the support and coefficient geometry of the state's
magnitude polynomial. Product states exhibit rectangular support structure that
forces a combinatorial witness
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: ReLU Width–Depth Trade-offs

The file `Basic.lean` establishes a fully formal, axiom-clean depth-separation
result for ReLU networks built from the tent map `tent x = 1 - |2x - 1|`. The
depth-`k` constant-width network `tent^[k]` rises from `0` to `1` over an
interval of width `2^{-k}` (`tent_iterate_zero`, `tent_iterate_peak`), is
`2^k`-Lipschitz (`tent_iterate_lipschitz`), yet stays bounded in `[0,1]`. Any
`K`-Lipschitz approximant with `K·2^{-k} + 2ε < 1` provably fails
(`relu_depth_separation`). The following directions extend this frontier; each
is testable and falsifiable.

## 1. From a single steep ramp to a counting (oscillation) lower bound

The current obstruction uses one ramp of width `2^{-k}`. The sharper
Telgarsky-style statement counts oscillations: `tent^[k]` crosses the level
`1/2` exactly `2^k` times, while a one-hidden-layer ReLU network of width `w`
is piecewise-linear with at most `w+1` pieces and hence crosses any level at
most `w+1` times. This yields an *exact width lower bound* `w ≥ 2^k - 1`,
independent of the weight magnitudes — a strictly stronger separation than the
Lipschitz version.
**The key insight is** that the crossing number of a continuous piecewise-linear
function is bounded by its number of affine pieces, so an exponential crossing
count forces exponential width regardless of how large the weights are allowed
to be. **Why now?** The tent and its iterate are already formalized with their
ascending-branch identity `tent_eq_two_mul`; the missing ingredient is a Lean
lemma "a function with `p` affine pieces has at most `p` solutions to `f = c`",
which is a finite combinatorial fact about `tent_iterate_peak`-style alternation
and is within reach of the existing induction machinery.

## 2. Matching shallow upper bound: quantitative 1-D universal approximation

Pair the lower bound with a constructive upper bound: every `K`-Lipschitz
`f : [0,1] → ℝ` is approximated within `ε` by the piecewise-linear interpolant
on `N = ⌈K/ε⌉` equal nodes, which is exactly a width-`N` one-hidden-layer ReLU
network. This pins the shallow cost at `Θ(K/ε)` and, with direction 1, closes
the `width ≈ ε^{-1}` (shallow) vs `depth ≈ log(1/ε)` (deep) gap quantitatively.
**The key insight is** that Lipschitz control bounds the interpolation error by
`K · (mesh size)`, so a uniform mesh of `K/ε` nodes suffices and each interior
node is one ReLU neuron. **Why now?** `relu_depth_separation` already isolates
the Lipschitz constant as the governing quantity; the dual upper bound reuses
the same `LipschitzWith` API plus Mathlib's `Real`-interval interpolation
lemmas, making the two-sided `Θ` characterization formalizable today.

## 3. Higher-dimensional separation on `[-1,1]^n`

Lift the construction to `[-1,1]^n` via tensorized tents
`F(x) = tent^[k](x₁) · ⋯ · tent^[k](xₙ)` or a max-pooling variant, and show the
shallow Lipschitz/width cost scales as `ε^{-n}` while a depth-`O(n·log(1/ε))`
network keeps polynomial size — the ge
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
of objects (not placeholder strings). Include future directions from Phase A
in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
