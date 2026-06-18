
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

**Title**: Close Proofs: **Thermodynamic Proof System** (TPS) framewo
**Domain**: Applications
**Mathematical framing**: Cycle 4b5245d6 (Q=0.427) proved 1469 theorems in MachineLearning but left 16 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: # Future Directions: Thermodynamic Proof Complexity

## Synthesis

This research cycle established the **Thermodynamic Proof System** (TPS) framework, connecting proof complexity to physical energy co
Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Geometry/QuasiSymmetricComposition.lean
/-
  Composition theory for set-local distortion of Hausdorff dimension
  ==================================================================

  This file *deepens* the set-local distortion theory developed in
  `Geometry.FractalDimension`, which built the set-local theory of how
  Lipschitz / antilipschitz / Hölder maps distort Hausdorff dimension on a fixed
  subset `s`.  That file proved single-map invariance and the two-sided Hölder
  (quasi-symmetric flavoured) distortion estimate.  The missing piece, and the
  natural next step in the fractal-topology programme, is the **closure of these
  classes under composition** and the resulting **multiplicative behaviour of the
  distortion exponents**.

  Why composition matters: quasi-symmetric maps, iterated function systems and
  their conjugacies are all built by *chaining* good maps on nested pieces.  A
  distortion theory that does not compose is not usable for fractals.  Here we
  show the set-local antilipschitz class is closed under composition and
  restriction, that global antilipschitz maps restrict to it, and — the main
  result — that the composite of two set-local bi-Hölder maps obeys the
  *product-exponent* two-sided distortion bound, with bi-Lipschitz invariance
  as the exponent-one corollary.

  To keep the file self-contained (so the proofs verify standalone), the few
  prerequisite definitions/lemmas from `Geometry.FractalDimension` are reproduced
  verbatim at the top, in the namespace `QuasiSymmetricDistortion`; the genuinely
  new contributions follow under the `### New: composition` headings.
-/
import Mathlib

open Set Function
open scoped ENNReal NNReal

namespace QuasiSymmetricDistortion

variable {X Y Z : Type*}

/-! ## Prerequisites (reproduced from `Geometry.FractalDimension`) -/

/-- If `g` is a left inverse of `f` on `s` that is Lipschitz on the image `f '' s`,
then the image cannot have smaller Hausdorff dimension than `s`. -/
theorem le_dimH_image_of_lipschitzOn_leftInverse
    [EMetricSpace X] [EMetricSpace Y]
    {f : X → Y} {g : Y → X} {s : Set X} {K : ℝ≥0}
    (hg : LipschitzOnWith K g (f '' s)) (hgf : ∀ x ∈ s, g (f x) = x) :
    dimH s ≤ dimH (f '' s) := by
  have hgimg : g '' (f '' s) = s := by
    apply Set.Subset.antisymm
    · rintro _ ⟨_, ⟨x, hx, rfl⟩, rfl⟩
      rw [hgf x hx]; exact hx
    · intro x hx
      exact ⟨f x, ⟨x, hx, rfl⟩, hgf x hx⟩
  calc dimH s = dimH (g '' (f '' s)) := by rw [hgimg]
    _ ≤ dimH (f '' s) := hg.dimH_image_le

/-- `AntilipschitzOnWith K f s` means that on the set `s`, the map `f` does not contract
distances by more than a factor `K`: `edist x y ≤ K * edist (f x) (f y)` for `x, y ∈ s`. -/
def AntilipschitzOnWith [EMetricSpace X] [EMetricSpace Y]
    (K : ℝ≥0) (f : X → Y) (s : Set X) : Prop :=
  ∀ ⦃x⦄, x ∈ s → ∀ ⦃y⦄, y ∈ s → edist x y ≤ K * edist (f x) (f y)

/-- A set-local antilipschitz map is injective on the set. -/
theorem AntilipschitzOnWith.injOn [EMetricSpace X] [EMetricSpace Y]
    {K : ℝ≥0} {f : X → Y} {s : Set X} (hf : AntilipschitzOnWith K f s) :
    InjOn f s := by
  intro x hx y hy hxy
  have h := hf hx hy
  rw [hxy, edist_self, mul_zero] at h
  simpa using h

/-- The canonical left inverse of a set-local antilipschitz map is Lipschitz on the image. -/
theorem AntilipschitzOnWith.lipschitzOnWith_invFunOn
    [EMetricSpace X] [EMetricSpace Y] [Nonempty X]
    {K : ℝ≥0} {f : X → Y} {s : Set X} (hf : AntilipschitzOnWith K f s) :
    LipschitzOnWith K (invFunOn f s) (f '' s) := by
  rintro _ ⟨x, hx, rfl⟩ _ ⟨y, hy, rfl⟩
  rw [hf.injOn.leftInvOn_invFunOn hx, hf.injOn.leftInvOn_invFunOn hy]
  exact hf hx hy

/-- **Set-local antilipschitz lower bound.** A map that is antilipschitz on `s` cannot send `s`
to an image of strictly smaller Hausdorff dimension: `dimH s ≤ dimH (f '' s)`. -/
theorem AntilipschitzOnWith.le_dimH_image
    [EMetricSpace X] [EMetricSpace Y] [Nonempty X]
    {K : ℝ≥0} {f : X → Y} {s : Set X} (hf : AntilipschitzOnWith K f s) :
    dimH s ≤ dimH (f '' s) :=
  le_dimH_image_of_lipschitzOn_leftInverse hf.lipschitzOnWith_invFunOn
    (fun _ hx => hf.injOn.leftInvOn_invFunOn hx)

/-- **Set-local bi-Lipschitz invariance, intrinsic form.** A map that is simultaneously
Lipschitz and antilipschitz on `s` preserves Hausdorff dimension. -/
theorem dimH_image_eq_of_lipschitzOn_antilipschitzOn
    [EMetricSpace X] [EMetricSpace Y] [Nonempty X]
    {Kf Kf' : ℝ≥0} {f : X → Y} {s : Set X}
    (hf : LipschitzOnWith Kf f s) (hf' : AntilipschitzOnWith Kf' f s) :
    dimH (f '' s) = dimH s :=
  le_antisymm hf.dimH_image_le hf'.le_dimH_image

/-- **Two-sided Hölder distortion of Hausdorff dimension.** -/
theorem dimH_image_bounds_of_holderOn_holderOn_inverse
    [EMetricSpace X] [EMetricSpace Y]
    {f : X → Y} {g : Y → X} {s : Set X} {Cf Cg rf rg : ℝ≥0}
    (hf : HolderOnWith Cf rf f s) (hrf : 0 < rf)
    (hg : HolderOnWith Cg rg g (f '' s)) (hrg : 0 < rg)
    (hgf : ∀ x ∈ s, g (f x) = x) :
    dimH (f '' s) ≤ dimH s / rf ∧ dimH s ≤ dimH (f '' s) / rg := by
  have hgimg : g '' (f '' s) = s := by
    apply Set.Subset.antisymm
    · rintro _ ⟨_, ⟨x, hx, rfl⟩, rfl⟩
      rw [hgf x hx]; exact hx
    · intro x hx
      exact ⟨f x, ⟨x, hx, rfl⟩, hgf x hx⟩
  refine ⟨hf.dimH_image_le hrf, ?_⟩
  calc dimH s = dimH (g '' (f '' s)) := by rw [hgimg]
    _ ≤ dimH (f '' s) / rg := hg.dimH_image_le hrg

/-! ## New: composition closure of the set-local antilipschitz class -/

-- !-- Lab Notebook: AntilipschitzOnWith.comp -- !--
-- !-- Hypothesis: Set-local antilipschitz maps should compose with multiplied constants, dual to LipschitzOnWith.comp -- !--
-- !-- Result: Proved by chaining the two antilipschitz inequalities through the image -- !--
-- !-- Insight: The image membership f x ∈ f '' s is automatic; g's bound must be evaluated at points of f '' s -- !--
-- !-- Failure analysis: ENNReal mul-assoc/mono is routine -- !--
-- !-- End Lab Notebook -- !--

-- !-- chain edist x y ≤ Kf·edist(f x)(f y) ≤ Kf·Kg·edist(g f x)(g f y) -- !--
/-- **Composition of set-local antilipschitz maps.** If `f` is antilipschitz on `s` with
constant `Kf` and `g` is antilipschitz on `f '' s` with constant `Kg`, then `g ∘ f` is
antilipschitz on `s` with constant `Kf * Kg`. This is the set-local dual of
`LipschitzOnWith.comp`. -/
theorem AntilipschitzOnWith.comp [EMetricSpace X] [EMetricSpace Y] [EMetricSpace Z]
    {Kg Kf : ℝ≥0} {g : Y → Z} {f : X → Y} {s : Set X}
    (hg : AntilipschitzOnWith Kg g (f '' s)) (hf : AntilipschitzOnWith Kf f s) :
    AntilipschitzOnWith (Kf * Kg) (g ∘ f) s := by
  intro x hx y hy
  calc edist x y ≤ Kf * edist (f x) (f y) := hf hx hy
    _ ≤ Kf * (Kg * edist (g (f x)) (g (f y))) := by
        gcongr; exact hg (Set.mem_image_of_mem f hx) (Set.mem_image_of_mem f hy)
    _ = (Kf * Kg : ℝ≥0) * edist ((g ∘ f) x) ((g ∘ f) y) := by
        simp only [Function.comp_apply]; push_cast; ring

-- !-- a subset inherits the pointwise bound -- !--
/-- **Restriction.** An antilipschitz map on `s` is antilipschitz on any subset `t ⊆ s`. -/
theorem AntilipschitzOnWith.mono [EMetricSpace X] [EMetricSpace Y]
    {K : ℝ≥0} {f : X → Y} {s t : Set X} (hf : AntilipschitzOnWith K f s) (hts : t ⊆ s) :
    AntilipschitzOnWith K f t := by
  exact fun x hx y hy => hf ( hts hx ) ( hts hy )

-- !-- the global pointwise antilipschitz bound holds in particular on s -- !--
/-- **Global ⇒ local.** A globally antilipschitz map is antilipschitz on every set. -/
theorem antilipschitzOnWith_of_antilipschitzWith [EMetricSpace X] [EMetricSpace Y]
    {K : ℝ≥0} {f : X → Y} (hf : AntilipschitzWith K f) (s : Set X) :
    AntilipschitzOnWith K f s := by
  exact fun x hx y hy => hf x y

/-! ## New: Hausdorff dimension invariance under composition of bi-Lipschitz maps -/

-- !-- Lab Notebook: dimH_image_comp_eq_of_lipschitzOn_antilipschitzOn -- !--
-- !-- Hypothesis: A composite of two set-local bi-Lipschitz maps preserves Hausdorff dimension, since the composite is itself bi-Lipschitz on s -- !--
-- !-- Result: Prove
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: The Thermodynamic Proof System (TPS)

## Synthesis

This cycle turned the slogan "a proof is the erasure of uncertainty" into formal
mathematics. Building directly on the catalog's sorry-free Shannon-entropy layer
(`Speculative.AutoResearch.ShannonEntropy`: `entropy`, `entropy_uniform`,
`entropy_le_log_card`), the new module
`MachineLearning.ThermodynamicProofSystem` models a proposition's possible answers
as a finite type `α` of *epistemic microstates*, a belief state as a probability
distribution `p : α → ℝ`, and a *proof* as a transition `p ⇝ q` that lowers Shannon
entropy. The energy such a transition must dissipate at temperature `T` is the
**Landauer cost** `landauerCost T p q = T·(H(p) − H(q))`.

Three classically separate worlds collapse onto one inequality, the
maximum-entropy theorem `H(p) ≤ log n`:

* **Information theory** reads it as "a distribution on `n` outcomes carries at most
  `log n` nats".
* **Thermodynamics** reads it as **Landauer's bound** `tps_landauer_bound`: proving
  any proposition over an `n`-world space costs at most `T·log n`, attained from the
  uniform prior (`tps_landauer_tight`) and counted in bits by `tps_landauer_bits`.
* **Proof complexity** reads it as a *capacity*: a decision over `n` worlds cannot
  extract more than `log₂ n` bits of certainty, the irreducible work of resolving it.

The dual principle — **Bennett's** observation that logically reversible computation
is free — appears as `reversible_entropy_invariant` / `reversible_free`: relabelling
microstates by *any* permutation leaves entropy, hence cost, exactly zero.
Reversible steps live precisely on the boundary `ΔH = 0`, separating "free"
bookkeeping from genuinely dissipative inference.

## Results Summary

`MachineLearning/ThermodynamicProofSystem.lean` — 8 theorems, `sorry = 0`,
standard axioms only:

1. `pointMass_isProbDist` — a determined (proven) state is a probability distribution.
2. `entropy_pointMass` — a proven proposition carries zero entropy (the proof endpoint).
3. `reversible_entropy_invariant` — Bennett, entropy form: bijections preserve entropy.
4. `reversible_free` — Bennett, energy form: a reversible step costs nothing.
5. `landauerCost_nonneg` — second-law flavour: uncertainty-reducing proofs never return energy.
6. `tps_landauer_bound` — Landauer capacity bound: cost ≤ `T·log n`.
7. `tps_landauer_tight` — the bound is sharp from the uniform prior: cost `= T·log n`.
8. `tps_landauer_bits` — the same cost is exactly `log₂ n` bits.

Infrastructure note: the project's root `lakefile.toml` was pointed at the actual
source root (`srcDir = "Catalog"`), so the catalog now elaborates and builds.

## Research Directions

### 1. Conditional entropy and the cost of partial proofs (data-processing law)

A real proof rarely jumps to a point mass; it *coarse-grains*, mapping the world type
`α` onto a smaller type `β` via some `f : α → β` (a lemma that "forgets" irrelevant
distinctions). Conjecture: for the pushforward 
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
