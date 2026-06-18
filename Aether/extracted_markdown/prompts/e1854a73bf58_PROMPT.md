
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
3. **RESEARCH_PAPER.tex** (NEW) — A clean, compilable LaTeX version of
   the paper that mirrors the content of RESEARCH_PAPER.md. Use standard
   amsmath/amsart or article class, define all theorems inline, and make
   it suitable for direct PDF compilation with `pdflatex`. This is the
   publishable artifact.
4. **demo.py** — Numerical examples demonstrating the key results.
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
  "research_paper_tex": "RESEARCH_PAPER.tex",
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

**Title**: The Borsuk-Ulam Theorem Implies Arrow's Impossibility: Social Choice Is Topology
**Domain**: Computation
**Mathematical framing**: Arrow's impossibility theorem states that no ranked voting system can be fair (Pareto efficient, non-dictatorial, and independent of irrelevant alternatives). The Borsuk-Ulam theorem states that every continuous function f: S^n -> R^n maps some pair of antipodal points to the same value: f(x) = f(-x). Conjecture: Arrow's theorem is a corollary of Borsuk-Ulam. Specifically, define the 'preference sphere' S^{n-1} as the set of all preference profiles over n alternatives, where antipodal points represent opposite preferences (x prefers A > B > C, -x prefers C > B > A). Define f: S^{n-1} -> R^{n-1} by f(x) = (social_preference(x)_1, ..., social_preference(x)_{n-1}). By Borsuk-Ulam, there exists x such that f(x) = f(-x), meaning the social preference for profile x equals the social preference for profile -x. This contradicts Pareto efficiency (if all voters prefer A to B, the social preference should prefer A to B). Therefore, no continuous voting function satisfies all of Arrow's axioms. Conjecture: this proof generalizes: any social choice function on n alternatives is either discontinuous or dictatorial. Test: formalize the Borsuk-Ulam proof of Arrow's theorem in Lean 4. Impact: social choice theory is topology. Arrow's impossibility is a topological theorem about spheres.
Research domain: Computation
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Computation/BorsukUlamArrow.lean
/-
# The Borsuk–Ulam Route to Arrow-Style Impossibility: Social Choice as Topology

This file investigates the conjecture that *social choice is topology*: that an
Arrow-style impossibility for **continuous** social welfare functions is a
corollary of the (one–dimensional) Borsuk–Ulam theorem.

We model the "preference circle" `S¹` by `2π`-periodic continuous real functions
`f : ℝ → ℝ`, with the **antipodal map** sending a profile `θ` to its opposite
profile `θ + π` (every voter's ranking reversed). A continuous *social welfare
function* (SWF) assigns to each profile the social margin of `A` over `B`.

We prove:

* `borsuk_ulam_one_dim` — the 1-D Borsuk–Ulam theorem: every continuous circle
  function has an antipodal coincidence `f θ = f (θ + π)`. This is proved
  honestly from the Intermediate Value Theorem (imported from the Bridges
  catalog domain).
* `no_continuous_decisive_swf` — the Arrow-style impossibility: there is **no**
  continuous SWF that both *respects preference reversal* (`swf (θ+π) = -swf θ`)
  and is *decisive* (`swf θ ≠ 0` everywhere). Society is forced into a tie.
* `borsuk_ulam_arrow_bridge` — the cross-domain bridge theorem combining the
  **Computation/Impossibility** equivariant framework (the antipodal `ZMod 2`
  action is fixed-point free, `zmod_add_free`) with the **Bridges/IVT** result,
  exhibiting the forced social tie as the topological shadow of an algebraically
  free involution.

-- !-- Lab Notes -- !--

HYPOTHESIS (Hypothesizer):
  H1. Arrow's full impossibility is *literally* Borsuk–Ulam.  [too strong]
  H2. A continuous, reversal-respecting, decisive SWF on the preference circle
      cannot exist; the obstruction is exactly a 1-D Borsuk–Ulam coincidence.
  H3. The obstruction is structural: it is the algebraic shadow of the free
      ZMod 2 antipodal action (no fixed profile equals its own reversal).
  H4. Borsuk–Ulam in dimension 1 is provable directly from the IVT.

EXPERIMENT (Experimenter):
  - Mathlib has NO Borsuk–Ulam theorem (searched: borsuk/antipodal/LS-category).
    So we BUILD the 1-D case from the IVT bridge (`zero_crossing`).
  - We model S¹ → ℝ by 2π-periodic continuous f. The odd auxiliary function
    g(θ) = f θ - f (θ+π) satisfies g(π) = -g(0) by periodicity, so IVT gives a
    zero: an antipodal coincidence. Verified, 0 sorries.
  - Reversal axiom + coincidence forces swf θ = -swf θ, hence a tie. Verified.

ANALYSIS (Analyst):
  - H1 is FALSE as stated (discrete Arrow ≠ Borsuk–Ulam; the real topological
    statement needs continuity, à la Chichilnisky). We keep the honest H2/H3/H4.
  - "true but hard": general n-dim Borsuk–Ulam (absent from Mathlib).
  - "needs a different definition": Arrow with finite profiles is combinatorial,
    not topological — so we state the *continuous* impossibility, which IS
    topological and which the Borsuk–Ulam method genuinely proves.

CRITIQUE (Critic):
  - Not vacuous: a *constant nonzero* swf is continuous and decisive but FAILS
    reversal; an *honest* reversal-respecting swf (e.g. swf = sin) is continuous
    but NOT decisive (it has zeros). The theorem says you cannot have both — and
    `sin` witnesses that the hypotheses are individually satisfiable.
  - Main proofs use IVT + by_contra/rcases, not simp/decide. Bridge theorem uses
    a result from a *different* catalog domain (`zmod_add_free`).

SYNTHESIS (PI): The continuous Arrow impossibility is a 1-D Borsuk–Ulam corollary;
  Borsuk–Ulam is IVT; the structural cause is a free involution. Social choice,
  in its continuous form, really is topology.

BRIDGE FILES USED:
  * Bridges/IntermediateValueBridge.lean  (domain: Bridges)  — `zero_crossing`
  * Computation/Impossibility/Core.lean   (domain: Computation) — `zmod_add_free`
  NEW CONNECTION: the IVT-built Borsuk–Ulam coincidence (analysis) is identified
  with the fixed-point-freeness of the ZMod 2 antipodal action (algebra),
  yielding a single theorem in which an analytic obstruction and an algebraic
  obstruction are two faces of the same impossibility.
-/

import Mathlib
import Bridges.IntermediateValueBridge
import Computation.Impossibility.Core

open Real Set

namespace BorsukUlamArrow

/-- A *circle function* models a continuous map `S¹ → ℝ`: a continuous,
`2π`-periodic real function. Antipodal profiles are `θ` and `θ + π`. -/
structure IsCircleFn (f : ℝ → ℝ) : Prop where
  cont : Continuous f
  per  : Function.Periodic f (2 * π)

/-- **One-dimensional Borsuk–Ulam theorem.** Every continuous circle function
takes equal values on some antipodal pair `θ, θ + π`. Proved from the
Intermediate Value Theorem (Bridges domain). -/
theorem borsuk_ulam_one_dim {f : ℝ → ℝ} (hf : IsCircleFn f) :
    ∃ θ : ℝ, f θ = f (θ + π) := by
  set g : ℝ → ℝ := fun θ => f θ - f (θ + π) with hg
  have hgcont : Continuous g :=
    hf.cont.sub (hf.cont.comp (continuous_id.add continuous_const))
  have hper2 : f (π + π) = f 0 := by
    have := hf.per 0
    have e : (0 : ℝ) + 2 * π = π + π := by ring
    rw [e] at this; simpa using this
  have hg0 : g 0 = f 0 - f π := by simp [hg]
  have hgpi : g π = f π - f 0 := by simp [hg, hper2]
  have hopp : g π = - g 0 := by rw [hg0, hgpi]; ring
  have hpinn : (0 : ℝ) ≤ π := le_of_lt pi_pos
  rcases le_or_gt (g 0) 0 with h | h
  · -- `g 0 ≤ 0` and `g π = -(g 0) ≥ 0`, so IVT gives a zero of `g`.
    have hb : 0 ≤ g π := by rw [hopp]; linarith
    obtain ⟨x, _, hx⟩ :=
      IntermediateValueBridge.zero_crossing hpinn hgcont.continuousOn h hb
    refine ⟨x, ?_⟩
    have hxz : g x = 0 := hx
    simp only [hg] at hxz; linarith [hxz]
  · -- `g 0 > 0`, apply the zero-crossing to `-g`.
    have hng : Continuous (fun θ => - g θ) := hgcont.neg
    have ha : (fun θ => - g θ) 0 ≤ 0 := by simp; linarith
    have hb : 0 ≤ (fun θ => - g θ) π := by simp [hopp]; linarith
    obtain ⟨x, _, hx⟩ :=
      IntermediateValueBridge.zero_crossing hpinn hng.continuousOn ha hb
    refine ⟨x, ?_⟩
    have hxz : g x = 0 := by simpa using hx
    simp only [hg] at hxz; linarith [hxz]

/-- **Continuous Arrow-style impossibility.** There is no continuous social
welfare function that simultaneously respects preference reversal
(`swf (θ+π) = -swf θ`) and is decisive (`swf θ ≠ 0` everywhere): the antipodal
Borsuk–Ulam coincidence forces a social tie. -/
theorem no_continuous_decisive_swf :
    ¬ ∃ swf : ℝ → ℝ, IsCircleFn swf ∧
      (∀ θ, swf (θ + π) = - swf θ) ∧ (∀ θ, swf θ ≠ 0) := by
  rintro ⟨swf, hc, hrev, hdec⟩
  obtain ⟨θ, hθ⟩ := borsuk_ulam_one_dim hc
  rw [hrev θ] at hθ
  exact hdec θ (by linarith)

/-- The reversal and decisiveness hypotheses are *individually* satisfiable, so
the impossibility is non-vacuous. `sin` is a continuous reversal-respecting
circle function (witnessing the reversal axiom is consistent). -/
theorem reversal_axiom_satisfiable :
    ∃ swf : ℝ → ℝ, IsCircleFn swf ∧ (∀ θ, swf (θ + π) = - swf θ) := by
  refine ⟨Real.sin, ⟨Real.continuous_sin, Real.sin_periodic⟩, ?_⟩
  intro θ; exact Real.sin_add_pi θ

/-- **Cross-domain bridge: Borsuk–Ulam ⇄ free involution.**
For any continuous reversal-respecting SWF, *both* of the following hold:
* (Computation/Impossibility) the antipodal generator `1 : ZMod 2` acts freely —
  no profile-class equals its own reversal (`zmod_add_free`);
* (Bridges/IVT) the SWF is forced to produce a social tie `∃ θ, swf θ = 0`.
The forced analytic tie is the topological shadow of the algebraically free
involution: social choice is topology. -/
theorem borsuk_ulam_arrow_bridge (swf : ℝ → ℝ) (h : IsCircleFn swf)
    (hrev : ∀ θ, swf (θ + π) = - swf θ) :
    (∀ g : ZMod 2, g ≠ 0 → ∀ x : ZMod 2, g + x ≠ x) ∧ (∃ θ, swf θ = 0) := by
  refine ⟨zmod_add_free (le_refl 2), ?_⟩
  obtain ⟨θ, hθ⟩ := borsuk_ulam_one_dim h
  rw [hrev θ] at hθ
  exact ⟨θ, by linarith⟩

end BorsukUlamArrow



-- NEW_FILE: Catalog/Computation/BorsukUlamArrowDichotomy.lean
/-
# Continuity Is Essential: The Topological Arrow Dichotomy

Companion to `Computation.BorsukUlamArrow`. Where that fi
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Borsuk–Ulam ⇄ Arrow (Social Choice Is Topology)

Derived from the cycle in `Computation/BorsukUlamArrow.lean` and
`Computation/BorsukUlamArrowDichotomy.lean`. Each conjecture is falsifiable in
Lean 4.

## What this cycle established (basis for the conjectures below)

- 1-D Borsuk–Ulam (`borsuk_ulam_one_dim`) is provable directly from the
  Intermediate Value Theorem (Bridges domain).
- No continuous, `2π`-periodic, reversal-respecting, decisive social welfare
  function exists (`no_continuous_decisive_swf`).
- Dropping continuity restores possibility: the square wave
  `socialWave θ = (-1)^⌊θ/π⌋` is decisive and reversal-respecting
  (`decisive_reversal_swf_exists`), and is therefore *provably discontinuous*
  via the impossibility theorem (`socialWave_not_continuous`).
- The obstruction is the algebraically free `ZMod 2` antipodal involution
  (`borsuk_ulam_arrow_bridge`, reusing `Impossibility/Core.zmod_add_free`).

---

## Conjecture 1 — Higher-dimensional simultaneous ties (full Borsuk–Ulam)

For a continuous `F : S^{n} → ℝ^{n}` with `F(-x) = -F(x)` (antipodal/odd), there
is a single `x` with `F(x) = 0` — all `n` coordinates tie *simultaneously*. The
1-D file only ties coordinates independently.

The key insight is... coordinatewise IVT is too weak; simultaneous vanishing is
exactly the content of full Borsuk–Ulam, so the social-choice corollary "all
pairwise margins tie at one profile" is genuinely `n`-dimensional topology.

Why now? Mathlib has no Borsuk–Ulam theorem at all; building even the `S^2 → ℝ^2`
case (e.g. via degree theory or `ℤ/2`-equivariant cohomology of spheres) would be
the first formalization and would upgrade `no_continuous_decisive_swf` to genuine
multi-alternative Arrow.

## Conjecture 2 — Continuity is the *unique* obstructed axiom

Among {continuity, periodicity, reversal, decisiveness}, exactly one cannot be
dropped-and-restored: removing continuity restores a model (proved), and we
conjecture removing *any other single axiom* also restores a model, while keeping
all four is contradictory.

The key insight is... the impossibility is a single topological cut, so each of
the other three axioms should be individually inessential — a "minimal
unsatisfiable core" of size dictated solely by topology.

Why now? We already have the discontinuous witness; constructing the three
remaining witnesses (non-periodic, non-reversing, indecisive) is elementary and
would formally certify that `Continuous` is load-bearing and the others are not.

## Conjecture 3 — The tie set is a nonempty closed antipode-stable subset

For continuous reversal-respecting `swf`, the tie set `{θ | swf θ = 0}` is
nonempty (proved), closed, and invariant under `θ ↦ θ + π`; moreover its image in
the circle has cardinality ≥ 2.

The key insight is... antipode-stability (`tie_set_antipodal`) plus continuity
forces the zero set to be a `ℤ/2`-invariant closed set, so a *single* tie is
impossible — ties always come in antipodal pairs.

Why no
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
