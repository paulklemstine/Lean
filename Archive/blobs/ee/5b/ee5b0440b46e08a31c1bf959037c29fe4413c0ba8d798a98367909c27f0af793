
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

**Title**: Self-Avoiding Walk: Connective Constant
**Domain**: Computation
**Mathematical framing**: Prove that the connective constant for the self-avoiding walk on Z² equals (2+√2)/2 or determine its exact value. Formalize the Hara-Slade result and Nienhuis's conjecture.
Research domain: Computation
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Computation/SelfAvoidingWalk/ConnectiveConstant.lean
/-
Copyright (c) 2025. All rights reserved.

# Existence of the Self-Avoiding-Walk Connective Constant (Hammersley–Morton)

## Overview

This file EXTENDS `Computation.SelfAvoidingWalk.Basic`, which proved that the
self-avoiding-walk (SAW) count `c_n = sawCount n` on ℤ² is submultiplicative
(`SAW.sawCount_submultiplicative`) and that `log c_n` is therefore subadditive
(`SAW.logSawCount_subadditive`).

The Basic file *defines* the connective constant `μ = SAW.connectiveConstant`
but never proves that `c_n^{1/n}` actually converges to it. That convergence —
the Hammersley–Morton theorem, an application of Fekete's subadditive lemma —
is the mathematical heart of the connective constant's *existence*, and is what
we supply here, together with rigorous bounds `2 ≤ μ`.

## Main Results

* `SAW.sawCount_log_div_tendsto` : `(log c_n)/n → SAW.logSawCount_subadditive.lim`
   (Fekete's lemma applied to SAWs — the existence statement).
* `SAW.connectiveConstant_eq_exp_lim` : `μ = exp (Fekete limit)`, identifying the
   Basic-file definition with the Fekete limit.
* `SAW.sawCount_rpow_tendsto` : `c_n^{1/n} → μ` (Hammersley–Morton: the connective
   constant exists as the limit of root-counts).
* `SAW.connectiveConstant_le_rpow` : `μ ≤ c_n^{1/n}` for every `n ≥ 1` — the
   rigorous principle that *every* finite count yields an upper bound for `μ`.
* `SAW.one_le_connectiveConstant` : `1 ≤ μ`.
* `SAW.two_le_connectiveConstant` : `2 ≤ μ`, from the `2^n` north-east walks.
* `SAW.connectiveConstant_le_three` : `μ ≤ 3` — stated as a `conjecture` (sorry),
   the standard non-reversal upper bound.

## Note on the problem framing

The research brief proposed `μ = (2+√2)/2 ≈ 1.707`. This is incorrect for both
relevant lattices. The Nienhuis (1982) / Duminil-Copin–Smirnov (2012) constant is
the *hexagonal* connective constant `μ_hex = √(2+√2) ≈ 1.848` (formalized
algebraically in the Basic file as `SAW.nienhuis_mu`). The ℤ² connective constant
treated here has *no known closed form*; rigorously `2 ≤ μ_{ℤ²} ≤ 3` and
numerically `μ_{ℤ²} ≈ 2.638`. We therefore prove existence + bounds rather than a
(false) closed form.
-/

import Mathlib
import Computation.SelfAvoidingWalk.Basic

open Function Filter Topology

namespace SAW

-- !-- Lab Notebook: sawCount_log_div_tendsto -- !--
-- !-- Hypothesis: submultiplicativity of c_n (catalog) should yield convergence of (log c_n)/n via Fekete. -- !--
-- !-- Result: Direct application of Mathlib's `Subadditive.tendsto_lim` to `logSawCount_subadditive`. -- !--
-- !-- Insight: The only nontrivial hypothesis is BddBelow, which holds because c_n ≥ 1 makes every term ≥ 0. -- !--
-- !-- Failure analysis: none; the catalog had already done the hard combinatorial step (submultiplicativity). -- !--
-- !-- End Lab Notebook -- !--

/-- `log c_n ≥ 0` since `c_n ≥ 1`. -/
theorem zero_le_logSawCount (n : ℕ) : 0 ≤ Real.log (sawCount n) :=
  Real.log_nonneg (by exact_mod_cast one_le_sawCount n)

/-- The Fekete quotients `(log c_n)/n` are bounded below (by `0`). -/
theorem logSawCount_bddBelow :
    BddBelow (Set.range fun n => Real.log (sawCount n) / (n : ℝ)) := by
  refine ⟨0, ?_⟩
  rintro x ⟨n, rfl⟩
  exact div_nonneg (zero_le_logSawCount n) (Nat.cast_nonneg n)

/-- **Fekete's lemma for SAWs.** `(log c_n)/n` converges to the subadditive limit.
    This is the existence statement underlying the connective constant. -/
theorem sawCount_log_div_tendsto :
    Tendsto (fun n => Real.log (sawCount n) / (n : ℝ)) atTop
      (𝓝 logSawCount_subadditive.lim) :=
  logSawCount_subadditive.tendsto_lim logSawCount_bddBelow

/-- The Fekete limit is nonnegative (each quotient is `≥ 0`). -/
theorem zero_le_lim : 0 ≤ logSawCount_subadditive.lim :=
  ge_of_tendsto sawCount_log_div_tendsto
    (Eventually.of_forall fun n =>
      div_nonneg (zero_le_logSawCount n) (Nat.cast_nonneg n))

-- !-- Lab Notebook: connectiveConstant_eq_exp_lim -- !--
-- !-- Hypothesis: the catalog's `connectiveConstant = exp(⨅_{k>0} (log c_k)/k)` equals `exp(Fekete lim)`. -- !--
-- !-- Result: Proved by identifying the indexed infimum over {k>0} with `sInf` over the image of `Ici 1`. -- !--
-- !-- Insight: `iInf = sInf ∘ range`, and the range over the subtype {k>0} is exactly the image of {k | 0<k} = Ici 1. -- !--
-- !-- Failure analysis: the subtype-coercion bookkeeping is the only subtlety. -- !--
-- !-- End Lab Notebook -- !--

/-- The Basic-file connective constant equals `exp` of the Fekete limit. -/
theorem connectiveConstant_eq_exp_lim :
    connectiveConstant = Real.exp logSawCount_subadditive.lim := by
  unfold connectiveConstant
  congr 1
  rw [Subadditive.lim]
  rw [iInf]
  congr 1
  ext x
  constructor
  · rintro ⟨k, rfl⟩
    exact ⟨(k : ℕ), k.2, rfl⟩
  · rintro ⟨k, hk, rfl⟩
    exact ⟨⟨k, hk⟩, rfl⟩

-- !-- Lab Notebook: sawCount_rpow_tendsto -- !--
-- !-- Hypothesis: c_n^{1/n} → μ (Hammersley–Morton existence of the connective constant). -- !--
-- !-- Result: Exponentiate the Fekete convergence: c_n^{1/n} = exp((log c_n)/n) → exp(lim) = μ. -- !--
-- !-- Insight: `Real.rpow_def_of_pos` turns the root into `exp((1/n)·log c_n)`; continuity of `exp` finishes. -- !--
-- !-- Failure analysis: must restrict to n ≥ 1 (eventual equality) since rpow at 1/0 degenerates. -- !--
-- !-- End Lab Notebook -- !--

/-- **Hammersley–Morton theorem for ℤ².** The connective constant exists as the
    limit of the `n`-th root of the SAW counts: `c_n^{1/n} → μ`. -/
theorem sawCount_rpow_tendsto :
    Tendsto (fun n => (sawCount n : ℝ) ^ (1 / (n : ℝ))) atTop
      (𝓝 connectiveConstant) := by
  rw [connectiveConstant_eq_exp_lim]
  have hcont : Tendsto (fun n => Real.exp (Real.log (sawCount n) / (n : ℝ))) atTop
      (𝓝 (Real.exp logSawCount_subadditive.lim)) :=
    (Real.continuous_exp.tendsto _).comp sawCount_log_div_tendsto
  refine hcont.congr' ?_
  filter_upwards [eventually_gt_atTop 0] with n hn
  rw [Real.rpow_def_of_pos (by exact_mod_cast sawCount_pos n)]
  congr 1
  field_simp

-- !-- Lab Notebook: connectiveConstant_le_rpow -- !--
-- !-- Hypothesis: since μ is the INFIMUM of the c_n^{1/n}, every finite count upper-bounds μ. -- !--
-- !-- Result: From `lim ≤ (log c_n)/n` (Fekete inf property), exponentiate to μ ≤ c_n^{1/n}. -- !--
-- !-- Insight: This is the rigorous justification for computer-assisted upper bounds on μ. -- !--
-- !-- Failure analysis: none. -- !--
-- !-- End Lab Notebook -- !--

/-- **The connective constant is bounded above by every root-count.** For all
    `n ≥ 1`, `μ ≤ c_n^{1/n}`. Hence any single finite computation of `c_n` yields a
    rigorous upper bound on `μ`. -/
theorem connectiveConstant_le_rpow {n : ℕ} (hn : 0 < n) :
    connectiveConstant ≤ (sawCount n : ℝ) ^ (1 / (n : ℝ)) := by
  rw [connectiveConstant_eq_exp_lim, Real.rpow_def_of_pos (by exact_mod_cast sawCount_pos n)]
  apply Real.exp_le_exp.2
  have h := logSawCount_subadditive.lim_le_div logSawCount_bddBelow (n := n) hn.ne'
  calc logSawCount_subadditive.lim ≤ Real.log (sawCount n) / (n : ℝ) := h
    _ = Real.log (sawCount n) * (1 / (n : ℝ)) := by ring

/-- `1 ≤ μ`. -/
theorem one_le_connectiveConstant : 1 ≤ connectiveConstant := by
  rw [connectiveConstant_eq_exp_lim, ← Real.exp_zero]
  exact Real.exp_le_exp.2 zero_le_lim

/-! ### North-east walks give the lower bound `μ ≥ 2` -/

-- !-- Lab Notebook: twoPow_le_sawCount / two_le_connectiveConstant -- !--
-- !-- Hypothesis: the 2^n "north-east" walks (each step +x or +y) are self-avoiding, so c_n ≥ 2^n, giving μ ≥ 2. -- !--
-- !-- Result: Inject (Fin n → Bool) into LatticeWalk n via partial-sum coordinates; recover the bits to show injectivity. -- !--
-- !-- Insight: along a NE walk the sum x+y strictly increases, forcing self-avoidance for free. -- !--
-- !-- Failure analysis: TBD — the coordinate/injectivity bookkeeping is the delicate part. -- !--
-- !-- End Lab Notebook -- !--

/-- Coordinates of the north-east walk determined by a bit string `s`: the
    x-coordinate counts the `true`
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Self-Avoiding Walks and the Connective Constant

## Synthesis

This cycle closed the central *existence* gap left open by the catalog file
`Computation.SelfAvoidingWalk.Basic`. That file had done the genuinely hard
combinatorial work — it proved the SAW count `c_n = sawCount n` on ℤ² is
submultiplicative (`SAW.sawCount_submultiplicative`) and hence that `log c_n` is
subadditive (`SAW.logSawCount_subadditive`) — and it *defined* the connective
constant `μ = SAW.connectiveConstant`, but it never proved that `c_n^{1/n}`
actually converges to that definition. We supplied exactly that: the
Hammersley–Morton theorem `SAW.sawCount_rpow_tendsto`, obtained by feeding the
catalog's subadditivity into Mathlib's Fekete lemma (`Subadditive.tendsto_lim`)
and exponentiating. We also identified the catalog's indexed-infimum definition
with the Fekete limit (`SAW.connectiveConstant_eq_exp_lim`), turning the
definition into a *theorem-bearing* object. The structural insight is that once
submultiplicativity is in hand, the connective constant is not just *defined* but
*characterized* as `μ = inf_n c_n^{1/n} = lim_n c_n^{1/n}`, and — crucially for
computation — every finite count gives a rigorous one-sided bound
(`SAW.connectiveConstant_le_rpow` : `μ ≤ c_n^{1/n}`).

On the bounds side, we proved the clean two-sided trap is half-open: `2 ≤ μ`
(`SAW.two_le_connectiveConstant`) via an explicit injection of the `2^n`
north-east (monotone) walks into self-avoiding walks (`SAW.twoPow_le_sawCount`).
The combinatorial heart was that along a north-east walk the quantity `x+y`
strictly increases, so self-avoidance is automatic; the bits of the step string
are recovered from the per-step x-increments, giving injectivity. The matching
upper bound `μ ≤ 3` resisted a quick proof and is recorded as a conjecture
(`SAW.connectiveConstant_le_three`): it needs an injection of walks into
*non-reversing* step sequences (`c_n ≤ 4·3^{n-1}`), which is delicate because
"no immediate backtrack" is a local constraint that must be tracked along the
whole walk rather than read off a monotone coordinate.

The Critic's main finding: the proposed closed form `μ = (2+√2)/2 ≈ 1.707` in the
research brief is *false* for ℤ². It conflates two different objects. The
Nienhuis (1982) / Duminil-Copin–Smirnov (2012) constant `√(2+√2) ≈ 1.848` is the
*hexagonal*-lattice connective constant (formalized algebraically in the catalog
as `SAW.nienhuis_mu`), while the ℤ² constant treated here has no known closed
form and satisfies `2 ≤ μ_{ℤ²} ≤ 3` with numerical value `≈ 2.638`. We therefore
proved existence + rigorous bounds rather than a spurious exact value, and the
documentation now records this correction.

## Results Summary

- `SAW.zero_le_logSawCount`: proved — `log c_n ≥ 0`, the bounded-below input to Fekete.
- `SAW.logSawCount_bddBelow`: proved — the Fekete quotients `(log c_n)/n` are bounded below by 0.
- `SAW.sawCount_log_div_tendsto`: proved — Fekete's lemma for SAWs: `(log c_n)/
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
