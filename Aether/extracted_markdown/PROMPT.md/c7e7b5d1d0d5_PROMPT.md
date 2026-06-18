
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

**Title**: The file `WillmoreEnergy.lean` establishes the elementary half of the Willmore
**Domain**: Geometry
**Mathematical framing**: # Future Directions: Willmore Energy Lower Bounds by Genus

The file `WillmoreEnergy.lean` establishes the elementary half of the Willmore
story in a clean measure-theoretic abstraction: the pointwise square identity
`H² - K = ((κ₁-κ₂)/2)²`, its integral consequence `∫ K ≤ W`, the Gauss–Bonnet
bound `2π·χ ≤ W`, the sharp `4π` bound for genus `0`, the universal `4π` bound
from a Gauss-map degree input, and a precise statement of *why* the elementary
argument degenerates for higher genus. Below are five concrete, falsifiable
directions that build directly on these results and connect to the catalog files
`DiscreteGaussBonnet.lean` (`total_curvature_eq_genus`,
`eulerChar_eq_two_sub_two_mul_genus`) and `GenusFormula.lean`.

## 1. A quantitative umbilic-defect lower bound

The identity `willmoreDensity_sub_gaussCurv` says `W - ∫K = ∫((κ₁-κ₂)/2)²`, the
total *umbilic defect*. Conjecture: for any closed surface,
`W ≥ 2π·χ + c · diam(spec(II))²` for an explicit constant, where the second term
measures how far the surface is from being totally umbilic in an averaged sense.
**The key insight is** that the slack in `gauss_le_willmore` is *itself* a
geometrically meaningful energy (the traceless second fundamental form), so the
inequality can be upgraded to an identity-with-remainder rather than a bare
bound. **Why now?** The remainder is already available in Lean as
`∫ x, ((k1 x - k2 x)/2)^2 ∂μ`; one only needs `integral_eq_integral_add` style
splitting, which is fully supported in current Mathlib measure theory.

## 2. Rigidity: characterizing equality `W = ∫K`

`willmoreDensity_eq_gaussCurv_iff` proves the pointwise rigidity `H² = K ↔ κ₁=κ₂`.
The integral upgrade — `W = ∫K` (with both integrable and the defect `≥ 0`) forces
`κ₁ = κ₂` μ-almost everywhere (total umbilicity) — should follow from
`MeasureTheory.integral_eq_zero_iff_of_nonneg`. **The key insight is** that the
nonnegative defect integrand vanishes in integral iff it vanishes a.e., turning a
pointwise iff into an a.e. rigidity theorem with no new geometry. **Why now?** The
nonnegativity lemma `willmoreDensity_nonneg` plus the square identity are already
proved, so the only missing ingredient is a single standard Mathlib lemma about
a.e.-vanishing of nonnegative integrands.

## 3. Genus-monotonicity of the elementary obstruction

`gaussBonnet_bound_vacuous_high_genus` shows `4π(1-g) ≤ 0` for `g ≥ 1`.
Strengthen this to a *monotone family*: the elementary lower bound
`b(g) = 4π(1-g)` is strictly decreasing in `g`, and the gap between `b(g)` and the
true sharp bound `β(g)` (e.g. `β(1) = 2π²`) is strictly increasing. **The key
insight is** that the elementary Gauss–Bonnet method loses exactly `2π` of
detectable energy per unit genus, which can be stated and proved as a clean real
inequality `b(g+1) = b(g) - 4π`. **Why now?** This is a finite real-arithmetic
statement reachable by `linarith`/`nlinarith` on top of the existing genus
machinery in `DiscreteGaussBonnet.lean`, requiring no analysis at all.

## 4. The Li–Yau multiplicity bound via the set-integral method

`willmore_ge_fourPi_of_setGauss` already isolates the degree mechanism: a region
contributing `≥ 4π` of positive Gauss curvature forces `W ≥ 4π`. Generalize to
the Li–Yau inequality: a surface with a point of multiplicity `k` satisfies
`W ≥ 4πk`. **The key insight is** that `k` disjoint sheets each contribute an
independent `4π` of Gauss-map degree, so the single-set bound becomes a finite
sum over `k` disjoint measurable regions via additivity of the set integral.
**Why now?** `setIntegral_le_integral` and finite additivity of restricted
integrals are present in Mathlib, so the `k = 1` proof here extends to general
`k` by induction with no new analytic input.

## 5. The Marques–Neves bound `2π² ≤ W` for tori (the open target)

`willmore_torus_conjecture` records the genus-1 sharp bound as a `sorry`. A
tractable intermediate target is the *conformal/min-max width* reformulation:
define an abstract "width" functional on the abstract surface model and prove
that (i) the Willmore energy dominates the width and (ii) the width of any
genus-1 configuration is `≥ 2π²`. **The key insight is** that the full
Almgren–Pitts machinery can be *axiomatized* at the level of a width functional
satisfying a small list of monotonicity/normalization properties, reducing the
deep theorem to a finite combinatorial-analytic core that Lean can verify.
**Why now?** The abstract measure-space surface model in this file is exactly the
right setting to host such a width functional without committing to a smooth
manifold structure, so the reformulation can be prototyped immediately on top of
`willmoreEnergy`.

Research domain: Geometry
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Geometry/WillmoreEnergy.lean
/-
# Willmore Energy: The Elementary Lower Bounds by Genus

This file develops the *elementary* half of the Willmore story in a clean,
measure-theoretic abstraction.  Rather than committing to a smooth immersed
surface, we model the geometric data of a closed surface as a finite measure
space `(X, μ)` together with two principal-curvature functions `k₁, k₂ : X → ℝ`.
All the algebraic and integral inequalities that underlie the classical
Willmore theory are then provable with no manifold machinery whatsoever.

## The core objects

* `meanCurv   = (k₁ + k₂)/2`            (the mean curvature `H`)
* `willmoreDensity = H² = ((k₁+k₂)/2)²` (the pointwise Willmore integrand)
* `gaussCurv  = k₁·k₂`                  (the Gaussian curvature `K`)
* `umbilicDefect = ((k₁-k₂)/2)²`        (the *traceless* second fundamental form)
* `willmoreEnergy = ∫ H² dμ`            (the Willmore energy `W`)

## Main results

* `willmoreDensity_sub_gaussCurv` — the pointwise identity `H² - K = ((k₁-k₂)/2)²`.
* `willmoreDensity_eq_gaussCurv_iff` — pointwise rigidity `H² = K ↔ k₁ = k₂`.
* `willmoreEnergy_sub_gauss_eq_defect` — the integral identity `W - ∫K = ∫((k₁-k₂)/2)²`.
* `gauss_le_willmore` — the integral inequality `∫K ≤ W`.
* `willmore_eq_gauss_iff_umbilic_ae` — integral rigidity: `W = ∫K ↔ k₁ = k₂` a.e.
* `gaussBonnet_bound` — `2π·χ ≤ W` from a Gauss–Bonnet input `∫K = 2π·χ`.
* `willmore_ge_fourPi_genus_zero` — the sharp `4π` bound for genus `0`.
* `willmore_ge_fourPi_of_setGauss` — the universal `4π` bound from a Gauss-map
  degree region.
* `willmore_ge_fourPi_mul_of_disjoint_sheets` — a Li–Yau-style multiplicity bound:
  `n` disjoint `4π`-sheets force `W ≥ 4π·n`.
* `gaussBonnet_bound_vacuous_high_genus` — the elementary bound `4π(1-g) ≤ 0`
  degenerates for `g ≥ 1`.
* `elementary_bound_step` / `elementary_bound_antitone` — the elementary
  obstruction loses exactly `2π` per unit genus.

This file connects to the catalog file `DiscreteGaussBonnet.lean`
(`total_curvature_eq_genus`, `eulerChar_eq_two_sub_two_mul_genus`,
`sphere_euler_char`): the Euler characteristic / genus inputs to the
Gauss–Bonnet theorems below are exactly the discrete totals proved there.

## References

* Willmore, T.J. "Note on embedded surfaces."
* Li, P. and Yau, S.-T. "A new conformal invariant and its applications…"
* Marques, F.C. and Neves, A. "Min-max theory and the Willmore conjecture."
-/

-- !-- Lab Notebook -- !--
-- Hypothesis: The classical chain of Willmore inequalities (H²≥K pointwise,
--   hence ∫K ≤ W, hence 2πχ ≤ W via Gauss–Bonnet, hence the 4π genus-0 bound)
--   is *entirely algebraic + measure-theoretic*; no smooth manifold structure
--   is needed if the principal curvatures are taken as raw measurable functions.
-- Result: Confirmed. Every elementary inequality reduces to the single square
--   identity H² - K = ((k₁-k₂)/2)² plus nonnegativity of integrals of squares.
-- Insight: The "slack" in ∫K ≤ W is *literally* an L² norm of the traceless
--   second fundamental form, so the bound upgrades to an identity-with-remainder
--   and to an a.e.-umbilic rigidity statement for free.
-- Failure analysis: The elementary method cannot see genus ≥ 1 sharp bounds:
--   for g ≥ 1 the Gauss–Bonnet floor 4π(1-g) ≤ 0 is vacuous, which we make
--   precise. The genuine genus-1 floor 2π² needs min-max input absent here.

import Mathlib

open MeasureTheory Real

namespace WillmoreEnergy

variable {X : Type*} (k1 k2 : X → ℝ)

/-! ## Part 1: Pointwise objects and the square identity -/

/-- Mean curvature `H = (k₁ + k₂)/2`. -/
noncomputable def meanCurv (x : X) : ℝ := (k1 x + k2 x) / 2

/-- Willmore density `H² = ((k₁+k₂)/2)²`, the pointwise Willmore integrand. -/
noncomputable def willmoreDensity (x : X) : ℝ := ((k1 x + k2 x) / 2) ^ 2

/-- Gaussian curvature `K = k₁·k₂`. -/
def gaussCurv (x : X) : ℝ := k1 x * k2 x

/-- Umbilic defect `((k₁-k₂)/2)²`, the squared length of the traceless second
fundamental form. -/
noncomputable def umbilicDefect (x : X) : ℝ := ((k1 x - k2 x) / 2) ^ 2

-- !-- The square identity H² - K = ((k₁-k₂)/2)² is a single `ring` fact: it is the polarization (a+b)² - 4ab = (a-b)² rescaled by 1/4. -- !--
/-- **The pointwise square identity** `H² - K = ((k₁-k₂)/2)²`. -/
theorem willmoreDensity_sub_gaussCurv (x : X) :
    willmoreDensity k1 k2 x - gaussCurv k1 k2 x = umbilicDefect k1 k2 x := by
  unfold willmoreDensity gaussCurv umbilicDefect; ring

/-- The umbilic defect is nonnegative (it is a square). -/
theorem umbilicDefect_nonneg (x : X) : 0 ≤ umbilicDefect k1 k2 x :=
  sq_nonneg _

-- !-- The difference H² - K equals the nonnegative defect, so K ≤ H² pointwise. -- !--
/-- The Willmore density dominates the Gaussian curvature pointwise: `K ≤ H²`. -/
theorem gaussCurv_le_willmoreDensity (x : X) :
    gaussCurv k1 k2 x ≤ willmoreDensity k1 k2 x := by
  unfold gaussCurv willmoreDensity
  linarith [sq_nonneg (k1 x - k2 x)]

/-- The Willmore density is nonnegative (it is a square). -/
theorem willmoreDensity_nonneg (x : X) : 0 ≤ willmoreDensity k1 k2 x :=
  sq_nonneg _

-- !-- Pointwise rigidity: the square defect ((k₁-k₂)/2)² vanishes iff k₁=k₂, so H²=K exactly at umbilic points. -- !--
/-- **Pointwise rigidity**: `H² = K` exactly at umbilic points `k₁ = k₂`. -/
theorem willmoreDensity_eq_gaussCurv_iff (x : X) :
    willmoreDensity k1 k2 x = gaussCurv k1 k2 x ↔ k1 x = k2 x := by
  constructor <;> intro h <;> unfold willmoreDensity gaussCurv at * <;> nlinarith

/-! ## Part 2: The Willmore energy and the integral inequalities -/

variable [MeasurableSpace X] {μ : Measure X}

/-- The Willmore energy `W = ∫ H² dμ`. -/
noncomputable def willmoreEnergy (μ : Measure X) (k1 k2 : X → ℝ) : ℝ :=
  ∫ x, willmoreDensity k1 k2 x ∂μ

/-- The total Gaussian curvature `∫ K dμ`. -/
noncomputable def totalGauss (μ : Measure X) (k1 k2 : X → ℝ) : ℝ :=
  ∫ x, gaussCurv k1 k2 x ∂μ

/-- The total umbilic defect `∫ ((k₁-k₂)/2)² dμ`. -/
noncomputable def totalDefect (μ : Measure X) (k1 k2 : X → ℝ) : ℝ :=
  ∫ x, umbilicDefect k1 k2 x ∂μ

-- !-- Integrate the pointwise identity term by term via `integral_sub`; the defect integrability follows from that of density and curvature. -- !--
/-- **The integral identity** `W - ∫K = ∫ ((k₁-k₂)/2)²` (the total umbilic
defect is exactly the Willmore slack). -/
theorem willmoreEnergy_sub_gauss_eq_defect
    (hW : Integrable (willmoreDensity k1 k2) μ)
    (hK : Integrable (gaussCurv k1 k2) μ) :
    willmoreEnergy μ k1 k2 - totalGauss μ k1 k2 = totalDefect μ k1 k2 := by
  unfold totalDefect totalGauss willmoreEnergy
  rw [← MeasureTheory.integral_sub hW hK]
  congr; ext; unfold umbilicDefect gaussCurv willmoreDensity; ring

/-- The total umbilic defect is nonnegative. -/
theorem totalDefect_nonneg : 0 ≤ totalDefect μ k1 k2 :=
  MeasureTheory.integral_nonneg fun _ => sq_nonneg _

-- !-- The slack W - ∫K equals the nonnegative defect integral, hence ∫K ≤ W. -- !--
/-- **The integral inequality** `∫K ≤ W`. -/
theorem gauss_le_willmore
    (hW : Integrable (willmoreDensity k1 k2) μ)
    (hK : Integrable (gaussCurv k1 k2) μ) :
    totalGauss μ k1 k2 ≤ willmoreEnergy μ k1 k2 := by
  have h := willmoreEnergy_sub_gauss_eq_defect k1 k2 hW hK
  have hd := totalDefect_nonneg (μ := μ) k1 k2
  linarith

-- !-- The nonnegative defect integrand integrates to 0 iff it is a.e. 0 (`integral_eq_zero_iff_of_nonneg_ae`), i.e. k₁ = k₂ a.e. -- !--
/-- **Integral rigidity**: equality `W = ∫K` forces total umbilicity `k₁ = k₂`
almost everywhere. -/
theorem willmore_eq_gauss_iff_umbilic_ae
    (hW : Integrable (willmoreDensity k1 k2) μ)
    (hK : Integrable (gaussCurv k1 k2) μ) :
    willmoreEnergy μ k1 k2 = totalGauss μ k1 k2 ↔ k1 =ᵐ[μ] k2 := by
  constructor <;> intro h
  · have h_pointwise : ∀ x, willmoreDensity k1 k2 x - gaussCurv k1 k2 x
        = umbilicDefect k1 k2 x := willmoreDensity_sub_gaussCurv k1 k2
    have h_zero_ae : ∫ x, umbilicDefect k1 k2 x ∂μ = 0 → umbilicDefect k1 k2 =ᵐ[μ] 0 := by
      intro h_zero_ae
      have h_in
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Willmore Energy Lower Bounds by Genus

## Synthesis

`WillmoreEnergy.lean` realizes the *entire elementary half* of the Willmore
story inside a deliberately minimal abstraction: a measure space `(X, μ)`
carrying two principal-curvature functions `k₁, k₂ : X → ℝ`. No smooth
manifold, no immersion, no second fundamental form as a tensor — just raw
measurable functions. The surprising payoff is that the classical chain of
inequalities collapses onto a single algebraic seed, the square identity

```
H² - K = ((k₁ - k₂)/2)²        (willmoreDensity_sub_gaussCurv)
```

Everything else is an integral of this one fact. The pointwise nonnegativity of
the right-hand side gives `K ≤ H²`; integrating gives `∫K ≤ W`
(`gauss_le_willmore`); the Gauss–Bonnet substitution `∫K = 2π·χ` gives
`2π·χ ≤ W` (`gaussBonnet_bound`); and `χ = 2` gives the sharp genus-0 floor
`4π ≤ W` (`willmore_ge_fourPi_genus_zero`). The same square identity, read as an
*equality with remainder*, upgrades the bound to the rigidity statement
`W = ∫K ↔ k₁ = k₂` a.e. (`willmore_eq_gauss_iff_umbilic_ae`). A set-integral
refinement isolates the Gauss-map degree mechanism and yields both the universal
`4π` bound (`willmore_ge_fourPi_of_setGauss`) and a Li–Yau multiplicity bound
`W ≥ 4π·n` from `n` disjoint sheets
(`willmore_ge_fourPi_mul_of_disjoint_sheets`).

This file plugs directly into the catalog's discrete-topology layer:
`DiscreteGaussBonnet.lean` already proves `total_curvature_eq_genus`
(`∑ K(v) = 2π(2 - 2g)`), `eulerChar_eq_two_sub_two_mul_genus` (`χ = 2 - 2g`) and
`sphere_euler_char` (`χ = 2`). Those totals are exactly the Gauss–Bonnet inputs
`hGB : totalGauss = 2π·χ` consumed here, so the two files compose into one
curvature→topology→energy pipeline.

## Results Summary

| Theorem | Statement |
|---|---|
| `willmoreDensity_sub_gaussCurv` | `H² - K = ((k₁-k₂)/2)²` (pointwise) |
| `willmoreDensity_eq_gaussCurv_iff` | `H² = K ↔ k₁ = k₂` (pointwise rigidity) |
| `willmoreEnergy_sub_gauss_eq_defect` | `W - ∫K = ∫((k₁-k₂)/2)²` |
| `gauss_le_willmore` | `∫K ≤ W` |
| `willmore_eq_gauss_iff_umbilic_ae` | `W = ∫K ↔ k₁ = k₂` a.e. (integral rigidity) |
| `gaussBonnet_bound` | `2π·χ ≤ W` |
| `willmore_ge_fourPi_genus_zero` | `4π ≤ W` for genus 0 |
| `willmore_ge_fourPi_of_setGauss` | one `4π`-region forces `W ≥ 4π` |
| `willmore_ge_fourPi_mul_of_disjoint_sheets` | `n` sheets force `W ≥ 4π·n` (Li–Yau) |
| `gaussBonnet_bound_vacuous_high_genus` | `4π(1-g) ≤ 0` for `g ≥ 1` |
| `elementary_bound_step` / `elementary_bound_antitone` | `b(g+1) = b(g) - 4π`, strictly decreasing |

All main results are `sorry`-free and depend only on the standard axioms
`propext, Classical.choice, Quot.sound`.

---

## Direction 1 — A quantitative umbilic-defect lower bound

`willmoreEnergy_sub_gauss_eq_defect` already exhibits the slack in `∫K ≤ W` as
the *total umbilic defect* `∫((k₁-k₂)/2)²`. Conjecture: this can be lower-bounded
by a coarse, observable quantity, e.g. `W ≥ 2π·χ + c · (esssup|k₁-k₂|)
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
