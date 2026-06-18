
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

**Title**: Quantum Error Correction Threshold: The Eastin-Knill Theorem
**Domain**: Physics
**Mathematical framing**: Prove the Eastin-Knill theorem: no quantum code can transversally implement a universal gate set. Formalize the threshold theorem for fault-tolerant quantum computing and prove that the threshold is approximately 1% for the surface code with depolarizing noise.
Research domain: Physics
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Physics/EastinKnillThreshold.lean
import Mathlib

/-!
# The Eastin–Knill Theorem and the Fault-Tolerance Threshold

This file formalizes two pillars of fault-tolerant quantum computation as clean,
self-contained mathematical statements.

## Part I — The fault-tolerance threshold theorem (sharp trichotomy)

Under code concatenation a distance-`3` fault-tolerant gadget transforms a physical
error rate `p` into a level-`1` error rate `c·p²` (quadratic error suppression),
where `c` is the number of malignant fault pairs.  Iterating `L` levels gives the
recursion `p_{n+1} = c·p_n²`.  Writing the *rescaled* rate `q_n = c·p_n`, the
recursion linearizes to `q_{n+1} = q_n²`, hence `q_n = q_0^{2^n}` — a doubly
exponential law.  This yields the **threshold** `p_th = 1/c`:

* below threshold (`c·p < 1`): the logical error rate collapses to `0`;
* at threshold (`c·p = 1`): it is frozen at the fixed point `1/c`;
* above threshold (`c·p > 1`): it blows up to `+∞`.

The constant `c ≈ 100` for the surface code with depolarizing noise gives the
celebrated `p_th ≈ 1%` figure (`threshold_one_percent`).

## Part II — The Eastin–Knill theorem (abstract group-theoretic core)

The transversal logical gates of any quantum code form a *finite* group `T`.
Universality requires generating a dense (in particular infinite) subgroup of the
logical unitary group.  A finite group cannot exhaust an infinite ambient group,
so transversal gates are never universal: `eastin_knill_not_universal`.

## Main results

* `errorRate_rescaled` — `c · p_n = (c·p)^{2^n}` (the doubly-exponential law)
* `errorRate_closed_form` — `p_n = (1/c)·(c·p)^{2^n}`
* `errorRate_subthreshold_tendsto_zero` — below threshold the error rate → 0
* `errorRate_at_threshold_const` — at threshold the error rate is constant `1/c`
* `errorRate_superthreshold_tendsto_top` — above threshold the error rate → ∞
* `threshold_one_percent` — `c = 100 ⇒ p_th = 0.01`
* `eastin_knill_not_universal` — finite transversal gate group ≠ whole unitary group
-/

open Filter Topology

namespace Physics.EastinKnillThreshold

/-! ## Part I: The fault-tolerance threshold -/

/-- Level-`n` logical error rate under code concatenation, defined by the
quadratic error-suppression recursion `p_{n+1} = c · p_n²` with physical rate
`p_0 = p`.  Here `c` is the number of malignant fault locations per gadget. -/
noncomputable def errorRate (c p : ℝ) : ℕ → ℝ
  | 0 => p
  | n + 1 => c * (errorRate c p n) ^ 2

/-- The fault-tolerance threshold `p_th = 1/c`. -/
noncomputable def threshold (c : ℝ) : ℝ := 1 / c

@[simp] lemma errorRate_zero (c p : ℝ) : errorRate c p 0 = p := rfl

@[simp] lemma errorRate_succ (c p : ℝ) (n : ℕ) :
    errorRate c p (n + 1) = c * (errorRate c p n) ^ 2 := rfl

/-
!-- The rescaled rate q_n = c·p_n satisfies q_{n+1} = q_n², so q_n = q_0^{2^n};
prove by induction using pow_mul / sq. -- !--

**Doubly-exponential law.** The rescaled error rate `q_n = c·p_n` obeys
`q_n = q_0^{2^n}`: `c · p_n = (c · p)^{2^n}`.
-/
theorem errorRate_rescaled (c p : ℝ) (n : ℕ) :
    c * errorRate c p n = (c * p) ^ (2 ^ n) := by
  induction n <;> simp_all +decide [ pow_succ, pow_mul ];
  grobner

/-
!-- Divide the rescaled law by c (c ≠ 0). -- !--

**Closed form.** `p_n = (1/c) · (c·p)^{2^n}` for `c ≠ 0`.
-/
theorem errorRate_closed_form (c p : ℝ) (hc : c ≠ 0) (n : ℕ) :
    errorRate c p n = (1 / c) * (c * p) ^ (2 ^ n) := by
  rw [ ← errorRate_rescaled ] ; ring_nf ; aesop;

/-
!-- Below threshold q := c·p ∈ [0,1); q^{2^n} → 0 since 2^n → ∞; scale by 1/c. -- !--

**Sub-threshold collapse.** If `0 ≤ p`, `0 < c` and `c·p < 1` (i.e.
`p < p_th = 1/c`), then the logical error rate converges to `0`.
-/
theorem errorRate_subthreshold_tendsto_zero (c p : ℝ) (hc : 0 < c) (hp : 0 ≤ p)
    (hlt : c * p < 1) :
    Tendsto (errorRate c p) atTop (𝓝 0) := by
  convert Tendsto.const_mul ( 1 / c ) ( tendsto_pow_atTop_nhds_zero_of_lt_one ( by positivity ) hlt |> Filter.Tendsto.comp <| tendsto_pow_atTop_atTop_of_one_lt one_lt_two ) using 2 ; norm_num [ errorRate_closed_form _ _ hc.ne', mul_div_cancel_left₀ ];
  ring

/-
!-- At threshold q = 1, q^{2^n} = 1, so p_n = 1/c for all n; via closed form. -- !--

**Critical fixed point.** At threshold (`c·p = 1`) the error rate is frozen
at `1/c` for every level.
-/
theorem errorRate_at_threshold_const (c p : ℝ) (hc : c ≠ 0) (heq : c * p = 1)
    (n : ℕ) : errorRate c p n = 1 / c := by
  convert errorRate_closed_form c p hc n using 1 ; norm_num [ heq ]

/-
!-- Above threshold q := c·p > 1; q^{2^n} → ∞ and 1/c > 0, so p_n → ∞. -- !--

**Super-threshold blow-up.** If `0 < c` and `c·p > 1` (i.e. `p > p_th`), the
logical error rate diverges to `+∞`.
-/
theorem errorRate_superthreshold_tendsto_top (c p : ℝ) (hc : 0 < c)
    (hgt : 1 < c * p) :
    Tendsto (errorRate c p) atTop atTop := by
  -- By the closed form, we have $p_n = (1/c) * (c * p)^{2^n}$.
  have h_closed_form : ∀ n, errorRate c p n = (1 / c) * (c * p) ^ (2 ^ n) := by
    exact fun n => errorRate_closed_form c p hc.ne' n;
  rw [ show errorRate c p = _ from funext h_closed_form ] ; exact Filter.Tendsto.const_mul_atTop ( by positivity ) ( tendsto_pow_atTop_atTop_of_one_lt hgt |> Filter.Tendsto.comp <| tendsto_pow_atTop_atTop_of_one_lt one_lt_two ) ;

/-
!-- threshold 100 = 1/100 = 0.01 by norm_num. -- !--

**The ~1% surface-code threshold.** With the surface-code malignant-pair
count `c = 100`, the fault-tolerance threshold is exactly `1%`.
-/
theorem threshold_one_percent : threshold 100 = 0.01 := by
  unfold threshold; norm_num;

/-! ## Part II: The Eastin–Knill theorem -/

/-
!-- If T were all of G then G would be finite (image of a finite set), contradicting
Infinite G; hence T ≠ univ. -- !--

**Eastin–Knill (abstract core).** In an infinite logical-unitary group `G`, a
*finite* group `T` of transversal gates can never be the whole group.  Since a
universal gate set must generate all of `G`, transversal gates are not universal.
-/
theorem eastin_knill_not_universal {G : Type*} [Group G] [Infinite G]
    (T : Subgroup G) (hT : (T : Set G).Finite) : (T : Set G) ≠ Set.univ := by
  exact fun h => hT.not_infinite <| h ▸ Set.infinite_univ

/-
**Corollary.** No finite transversal gate group contains a universal generating
set: if `T` is finite then its carrier is a proper subset of an infinite `G`.
-/
theorem eastin_knill_proper {G : Type*} [Group G] [Infinite G]
    (T : Subgroup G) (hT : (T : Set G).Finite) : (T : Set G) ⊂ Set.univ := by
  exact ⟨ Set.subset_univ _, fun h => by exact hT.not_infinite <| Set.infinite_univ.mono h ⟩

end Physics.EastinKnillThreshold


-- DIFF: Catalog/Tropical/Langlands/SatakeIsomorphism.lean
--- a/Tropical/Langlands/SatakeIsomorphism.lean
+++ b/Tropical/Langlands/SatakeIsomorphism.lean
@@ -1,260 +1,159 @@
+/-
+Copyright (c) 2024. All rights reserved.
+Released under Apache 2.0 license as described in the file LICENSE.
+
+# Tropical Satake Isomorphism — Definitions
+
+This file provides the core definitions for the tropical Satake isomorphism.
+-/
 import Mathlib
-
-/-!
-# Tropical Satake Isomorphism for GL₂
-
-We formalize the tropical analog of the Satake isomorphism for GL₂, establishing
-that the tropical Hecke algebra is isomorphic (as a tropical algebra) to the ring
-of Weyl-invariant tropical Laurent polynomials.
-
-## Main Results
-
-* `satakeImage_weyl_invariant` — The Satake image of any Hecke operator is S₂-symmetric
-* `satakeImage_eq_nsmul_max` — The Satake image of Tₙ equals n · max(x₁, x₂)
-* `satakeImage_one_eq_tropE1` — T₁ maps to the first tropical elementary symmetric function
-* `satakeTransform_bijective` — The tropical Satake transform is a bijection
-* `satakeTransform_mul_compat` — The Satake transform preserves tropical convolution
-
-## Mathematical Context
-
-In the classical Langlands program, the Satake isomorphism identifies the spherical
-Hecke algebra H(GL₂(ℚₚ), GL₂(ℤₚ)) with ℂ[X₁±¹, X₂±¹]^{S₂}. The tropical analog
-replaces the base ring with the max-plus semiring (ℝ ∪ {-∞}, max, +) and reveals
-
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Eastin–Knill and the Fault-Tolerance Threshold

The file `Catalog/Physics/EastinKnillThreshold.lean` formalizes two cornerstones
of fault-tolerant quantum computing as clean mathematical objects: the
doubly-exponential concatenation recursion `q_{n+1} = q_n²` (with its sharp
threshold trichotomy at `c·p = 1`, i.e. `p_th = 1/c ≈ 1%` for `c ≈ 100`), and an
abstract group-theoretic core of the Eastin–Knill no-go theorem
(`eastin_knill_not_universal`: a finite transversal-gate group cannot exhaust an
infinite logical unitary group). It synthesizes naturally with the catalog's QEC
ecosystem — `StabilizerBounds.lean` (Hamming/Singleton parameter bounds),
`GaugeCodeDistance.lean` (distance from spectral gaps), and `ToricCode.lean`
(CSS codes). Below are five testable extensions.

## 1. Higher-distance codes give super-quadratic suppression

For a distance-`d` code each fault-tolerant gadget needs `t+1 = ⌊(d-1)/2⌋+1`
faults to fail, so the recursion generalizes to `p_{n+1} = c · p_n^{t+1}`, and the
rescaled rate obeys `q_n = q_0^{(t+1)^n}` — the exponent base is the code's
error-correcting radius plus one, directly linking `CodeParams.t` from
`StabilizerBounds.lean` to the convergence speed. The conjecture: below threshold,
`errorRateD c p (t+1) n ≤ (1/c) · (c·p)^{(t+1)^n}`, with the threshold value
`p_th = c^{-1/t}` strictly increasing in `d`.

**The key insight is** that distance enters the threshold *exponent*, not just the
prefactor, so even modest increases in `d` widen the basin of convergence
multiplicatively. **Why now?** The present `errorRate_rescaled` proof is a clean
induction over `q_n = q_0^{2^n}`; replacing `pow_mul` with the general
`(t+1)^n` exponent is a direct, low-risk generalization that immediately couples
to the already-formalized `CodeParams.t`.

## 2. Quantitative resource overhead: the polylog(1/ε) law

Inverting the doubly-exponential law gives the number of concatenation levels
needed to reach target logical error `ε`: `L(ε) = ⌈log₂ log_q(1/ε)⌉`, and hence a
physical-qubit overhead that is *polylogarithmic* in `1/ε`. Formalize
`levels_for_target c p ε` and prove `errorRate c p (levels_for_target c p ε) ≤ ε`
whenever `c·p < 1`, then bound the overhead `N(ε) ≤ poly(log(1/ε))`.

**The key insight is** that the inverse of a tower of exponentials is a tower of
logarithms, converting the convergence theorem into an explicit, certified
resource estimate. **Why now?** We already have `errorRate_closed_form` in closed
form, so the inversion is pure real-analysis bookkeeping (monotonicity of `log`)
with no new quantum input required.

## 3. Eastin–Knill made quantitative: continuity-bound approximate gates

The exact no-go (`eastin_knill_not_universal`) admits a quantitative refinement:
transversal gates can approximate a target unitary `U` only to accuracy bounded
below by the code distance, `‖U_transversal − U‖ ≥ f(d)`. Formalize a metric/normed
group `G`, a finite subgroup `T`, and prove a positive covering radiu
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
