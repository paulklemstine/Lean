
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

**Title**: (in `Catalog/Bridges/CategoricalTropicalRipsInterleaving.
**Domain**: Geometry
**Mathematical framing**: # Future Directions — Categorical Tropicalization of Rips Filtrations and Interleaving Stability

This cycle established (in `Catalog/Bridges/CategoricalTropicalRipsInterleaving.lean`,
0 sorries, axioms `propext / Classical.choice / Quot.sound` only) the order-theoretic
core of persistence stability:

- a Rips filtration `ripsOf` of an **arbitrary symmetric distance** `d : α → α → ℝ`
  (generalizing the instance-bound `ripsGraph` of
  `Applications/PoincareData/MetricFiltration.lean`, related by `ripsMetric_eq_ripsOf`);
- the `δ`-**interleaving** relation `Interleaved`, with `interleaved_refl`,
  `interleaved_symm`, `interleaved_mono`, and the **tropical composition law**
  `interleaved_comp` (shifts add: `δ₁ ⊙ δ₂ = δ₁ + δ₂`);
- the **stability theorem** `rips_stability` (`|d − d'| ≤ δ ⇒ δ`-interleaved) and its
  metric form `rips_stability_dist`;
- the **interleaving (pseudo)distance** `interleavingDist` satisfying the tropical
  valuation / pseudometric axioms `interleavingDist_self`, `interleavingDist_comm`,
  `interleavingDist_triangle`.

The conjectures below are concrete, falsifiable next steps. Each is phrased so that a
follow-up cycle can either produce a Lean theorem or a Lean counterexample.

---

## Conjecture 1 — Sharpness of stability (the converse Lipschitz bound)

**Statement.** For finite `α` with two symmetric distances `d, d'`, the interleaving
distance of their Rips filtrations *equals* a tropical "best matching" of edge-birth
scales:
```
interleavingDist (ripsOf d) (ripsOf d') = sInf { δ ≥ 0 | ∀ x y, |d x y − d' x y| ≤ δ on the relevant edge set }.
```
In particular stability is **tight**: there exist `d, d'` with
`interleavingDist (ripsOf d) (ripsOf d') = ‖d − d'‖_∞`. 

**Test.** Prove `interleavingDist (ripsOf d) (ripsOf d') ≥ f(d,d')` for an explicit
lower bound `f`, complementing the upper bound `rips_stability_dist`; or exhibit a
3-point counterexample where the inequality is strict. *Falsifiable:* a single finite
example with strict gap refutes tightness.

## Conjecture 2 — `interleavingDist` is a genuine extended pseudometric on filtrations

**Statement.** Replacing `ℝ` by `ℝ≥0∞` and dropping the nonemptiness hypotheses,
`interleavingDistExt : (ℝ → SimpleGraph α) → (ℝ → SimpleGraph α) → ℝ≥0∞` is a true
`PseudoEMetricSpace` structure on the type of **monotone** filtrations, with
`interleavingDistExt F G = 0 ↔ F = G` on left-continuous filtrations.

**Test.** Build the `ℝ≥0∞`-valued version, prove `edist`-style triangle/symmetry
unconditionally (the `sInf ∅ = ⊤` convention removes the `Nonempty` hypotheses that are
load-bearing in the current `ℝ` version), and register a `PseudoEMetricSpace` instance.
*Falsifiable:* exhibiting two distinct left-continuous monotone filtrations at distance
`0` refutes the separation half.

## Conjecture 3 — Functoriality: 1-Lipschitz maps contract interleaving distance

**Statement.** A `1`-Lipschitz map `φ : (α, d) → (α', d')` (i.e. `d' (φx)(φy) ≤ d x y`)
induces graph homomorphisms `ripsOf d ε → ripsOf d' ε` for all `ε`, and the induced map
on filtrations is **`1`-Lipschitz for `interleavingDist`**. Hence `interleavingDist`
is a functor `(FiniteMetricSpaces, Lipschitz) ⥤ (Filtrations, interleaving)` landing in
the tropical-enriched category of §2.

**Test.** Define the induced filtration map, prove the homomorphism existence, and prove
the contraction `interleavingDist (push φ F) (push φ G) ≤ interleavingDist F G`.
*Falsifiable:* a Lipschitz map increasing some interleaving distance.

## Conjecture 4 — Tropical idempotency: an ultrametric refinement via single-linkage

**Statement.** The **`π₀`/connected-components** functor applied to `ripsOf d` recovers
the single-linkage (sub-)dendrogram, and the associated "merge-scale" distance
`d_SL x y := inf { ε | x, y connected in ripsOf d ε }` is an **ultrametric**, with
```
interleavingDist (ripsOf d) (ripsOf d') ≤ ‖d_SL − d'_SL‖_∞ ≤ ‖d − d'‖_∞,
```
so single-linkage is a tropical-idempotent contraction of the metric. This directly
links this bridge to `Bridges/CategoricalTropicalUltrametric.lean`: `d_SL` is the
ultrametric *reconstructed* from the tropical valuation data of the filtration.

**Test.** Define `d_SL` via `SimpleGraph.Reachable` on `ripsOf d ε`, prove the strong
triangle inequality `d_SL x z ≤ max (d_SL x y) (d_SL y z)`, and prove the chained bound.
*Falsifiable:* a 4-point example violating the ultrametric inequality for `d_SL`.

## Conjecture 5 — Stability of the connectivity (Poincaré) threshold

**Statement.** Define the connectivity threshold `θ(d) := inf { ε | ripsOf d ε is
connected }` (the `MetricFiltration`-level "Poincaré threshold" of the catalog). Then
`θ` is **`1`-Lipschitz** in the `sup`-distance:
```
|θ(d) − θ(d')| ≤ ‖d − d'‖_∞,
```
as a corollary of `rips_stability` plus monotone-connectivity transfer along
interleavings (`δ`-interleaved filtrations have connectivity thresholds within `δ`).

**Test.** Prove "connected at scale `ε` ⇒ connected at scale `ε + δ` for a
`δ`-interleaved filtration" (using `interleaved.fg` and `SimpleGraph.Connected.mono`),
then derive the Lipschitz bound on `θ`. *Falsifiable:* a finite perturbation moving the
connectivity threshold by more than `‖d − d'‖_∞`.

Research domain: Geometry
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Bridges/CategoricalTropicalRipsInterleaving.lean
/-
  # Categorical Tropical Rips Interleaving
  ## Persistence modules, interleaving distance, the min-plus (tropical) triangle law,
  ## and Vietoris–Rips stability.

  Bridge: connects **categorical persistence theory** (functors out of `(ℝ, ≤)` and their
  interleavings) ↔ **tropical / min-plus algebra** (composition of interleavings is tropical
  multiplication, the optimal interleaving is tropical addition) ↔ **geometry / TDA**
  (Vietoris–Rips filtrations of a dissimilarity and their stability under perturbation of the
  metric).

  **Core principle.** A persistence module is a monotone functor `M : ℝ → α` into a preorder.
  Two modules are `ε`-interleaved when each is dominated by an `ε`-shift of the other. The
  resulting interleaving distance is a genuine `ℝ≥0∞`-valued pseudometric whose triangle
  inequality is *exactly* a statement in the tropical semiring `Tropical ℝ≥0∞`: the
  composition of an `ε`- and a `δ`-interleaving is an `(ε+δ)`-interleaving, and `ε + δ` is
  tropical multiplication. The Vietoris–Rips construction turns a dissimilarity on a fixed
  point set into such a module, and sup-close dissimilarities give interleaved modules
  (algebraic / geometric stability).

  -- !-- Lab Notes -- !--
  -- HYPOTHESIS H1: In a *preorder*-valued model, interleavings carry no extra naturality
  --   data (every square commutes by proof irrelevance), so `Interleaved` reduces to a pair
  --   of shifted pointwise inequalities. This should make all categorical lemmas (reflexivity,
  --   symmetry, monotone weakening, composition) elementary while remaining faithful.
  -- HYPOTHESIS H2: Composition of interleavings is additive in the shift; lifting to
  --   `Tropical ℝ≥0∞` turns the triangle inequality into tropical submultiplicativity.
  -- HYPOTHESIS H3: For Vietoris–Rips, modeling the scale-`t` complex by its edge set
  --   `{(x,y) | d x y ≤ t} ⊆ X × X` inside the complete lattice `Set (X × X)` keeps the
  --   stability proof to one-line metric estimates.
-/

import Mathlib

open scoped ENNReal
open Tropical

noncomputable section

namespace CategoricalTropicalRipsInterleaving

universe u

/-! ## §1. Persistence modules as monotone functors `ℝ → α`. -/

/-- A persistence module valued in a preorder `α`: a monotone map from the parameter line. -/
structure PersMod (α : Type u) [Preorder α] where
  obj : ℝ → α
  mono : Monotone obj

variable {α : Type u} [Preorder α]

/-- `ε`-interleaving of two persistence modules. In a preorder the naturality squares of the
    two interleaving transformations commute automatically, so an interleaving is exactly a
    pair of `ε`-shifted dominations. -/
def Interleaved (ε : ℝ) (M N : PersMod α) : Prop :=
  (∀ t, M.obj t ≤ N.obj (t + ε)) ∧ (∀ t, N.obj t ≤ M.obj (t + ε))

/-
Every module is `0`-interleaved with itself.
-/
theorem interleaved_refl (M : PersMod α) : Interleaved 0 M M := by
  exact ⟨ fun t => by simp, fun t => by simp ⟩

/-
Interleaving is symmetric.
-/
theorem Interleaved.symm {ε : ℝ} {M N : PersMod α} (h : Interleaved ε M N) :
    Interleaved ε N M := by
      exact ⟨ h.2, h.1 ⟩

/-
An `ε`-interleaving is also a `δ`-interleaving for any larger nonnegative shift `δ`.
-/
theorem Interleaved.weaken {ε δ : ℝ} {M N : PersMod α}
    (h : Interleaved ε M N) (hεδ : ε ≤ δ) : Interleaved δ M N := by
      obtain ⟨h1, h2⟩ := h;
      exact ⟨ fun t => le_trans ( h1 t ) ( N.mono ( by linarith ) ), fun t => le_trans ( h2 t ) ( M.mono ( by linarith ) ) ⟩

/-- **Composition law (the tropical multiplication of interleavings).**
    An `ε`-interleaving followed by a `δ`-interleaving yields an `(ε+δ)`-interleaving. -/
theorem Interleaved.trans {ε δ : ℝ} {M N L : PersMod α}
    (h₁ : Interleaved ε M N) (h₂ : Interleaved δ N L) : Interleaved (ε + δ) M L := by
  refine ⟨fun t => ?_, fun t => ?_⟩
  · calc M.obj t ≤ N.obj (t + ε) := h₁.1 t
      _ ≤ L.obj (t + ε + δ) := h₂.1 (t + ε)
      _ = L.obj (t + (ε + δ)) := by rw [add_assoc]
  · calc L.obj t ≤ N.obj (t + δ) := h₂.2 t
      _ ≤ M.obj (t + δ + ε) := h₁.2 (t + δ)
      _ = M.obj (t + (ε + δ)) := by rw [show t + δ + ε = t + (ε + δ) by ring]

/-! ## §2. The interleaving distance in `ℝ≥0∞`. -/

/-- The set of (nonnegative, real) shifts at which `M` and `N` are interleaved, embedded into
    `ℝ≥0∞`. -/
def interleavingSet (M N : PersMod α) : Set ℝ≥0∞ :=
  {x | ∃ ε : ℝ, 0 ≤ ε ∧ Interleaved ε M N ∧ x = ENNReal.ofReal ε}

/-- The interleaving distance: the infimum of all interleaving shifts. Empty infimum is `⊤`
    (no finite interleaving exists). -/
def interleavingDist (M N : PersMod α) : ℝ≥0∞ := sInf (interleavingSet M N)

/-
The distance from a module to itself is `0`.
-/
theorem interleavingDist_self (M : PersMod α) : interleavingDist M M = 0 := by
  refine' le_antisymm ( csInf_le _ _ ) ( zero_le _ );
  · exact ⟨ 0, fun x hx => by rcases hx with ⟨ ε, hε, hε', rfl ⟩ ; exact zero_le _ ⟩;
  · exact ⟨ 0, le_rfl, interleaved_refl M, by simp +decide ⟩

/-
The interleaving distance is symmetric.
-/
theorem interleavingDist_comm (M N : PersMod α) :
    interleavingDist M N = interleavingDist N M := by
      refine' le_antisymm _ _ <;> simp +decide [ interleavingDist ];
      · intro b hb; obtain ⟨ ε, hε, hI, rfl ⟩ := hb; exact csInf_le' ⟨ ε, hε, hI.symm, rfl ⟩ ;
      · intro b hb; obtain ⟨ ε, hε, hMN, rfl ⟩ := hb; exact csInf_le ⟨ 0, by rintro x ⟨ δ, hδ, hNM, rfl ⟩ ; positivity ⟩ ⟨ ε, hε, hMN.symm, rfl ⟩ ;

/-
If `M, N` are `ε`-interleaved with `ε ≥ 0`, the distance is at most `ENNReal.ofReal ε`.
-/
theorem interleavingDist_le_ofReal {ε : ℝ} {M N : PersMod α} (hε : 0 ≤ ε)
    (h : Interleaved ε M N) : interleavingDist M N ≤ ENNReal.ofReal ε := by
      exact csInf_le ⟨ 0, fun x hx => by aesop ⟩ ⟨ ε, hε, h, rfl ⟩

/-
**Triangle inequality.** This is the tropical/min-plus law for the interleaving distance:
    composing interleavings adds shifts, and the infimum distributes.
-/
theorem interleavingDist_triangle (M N L : PersMod α) :
    interleavingDist M L ≤ interleavingDist M N + interleavingDist N L := by
      have h_dist : ∀ x ∈ interleavingSet M N, ∀ y ∈ interleavingSet N L, interleavingDist M L ≤ x + y := by
        -- By definition of interleaving distance, if $x \in \text{interleavingSet } M N$ and $y \in \text{interleavingSet } N L$, then there exist $\varepsilon, \delta \geq 0$ such that $M \leq N[\varepsilon]$ and $N \leq L[\delta]$.
        intro x hx y hy
        obtain ⟨ε, hε_nonneg, hε⟩ := hx
        obtain ⟨δ, hδ_nonneg, hδ⟩ := hy;
        convert interleavingDist_le_ofReal ( add_nonneg hε_nonneg hδ_nonneg ) ( hε.1.trans hδ.1 ) using 1 ; rw [ hε.2, hδ.2, ENNReal.ofReal_add hε_nonneg hδ_nonneg ];
      unfold interleavingDist at *;
      rw [ ENNReal.sInf_add ];
      refine' le_iInf₂ fun x hx => _;
      rw [ ENNReal.add_sInf ];
      exact le_iInf₂ fun y hy => h_dist x hx y hy

/-! ## §3. The tropical reformulation.

The triangle inequality, transported to the tropical semiring `Tropical ℝ≥0∞` (where
multiplication is ordinary addition), is exactly *submultiplicativity* of `trop ∘
interleavingDist`. This is the precise sense in which interleaving distances live in the
min-plus world. -/

/-
The interleaving distance is tropically submultiplicative:
    `trop d(M,L) ≤ trop d(M,N) * trop d(N,L)` in `Tropical ℝ≥0∞`, which unfolds to the
    ordinary triangle inequality.
-/
theorem interleaving_tropical_submul (M N L : PersMod α) :
    trop (interleavingDist M L) ≤ trop (interleavingDist M N) * trop (interleavingDist N L) := by
  convert interleavingDist_triangle M N L using 1

/-! ## §4. Vietoris–Rips persistence modules and stability. -/

variable {X : Type u}

/-- The Vietoris–Rips persistence module of a dissimilarity `d : X → X → ℝ`: at scale `t` the
    object is the edge set `{(x,y) | d x y ≤ t}` inside the complete lattice `Set (X × X)`,
    ordered by inclusion. Monotone in `t`. -/
def RipsMod (d : X → X → ℝ) : PersMod (Set (X × X)) where
  obj t := {p | d p.1 p.2 ≤ t}
  mono 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Categorical Tropical Rips Interleaving

This cycle established, in `Catalog/Bridges/CategoricalTropicalRipsInterleaving.lean`, a
self-contained, fully-verified bridge between **categorical persistence theory**,
**tropical / min-plus algebra**, and **geometry / topological data analysis**:

- Persistence modules as monotone functors `ℝ → α` (`PersMod`).
- `ε`-interleavings, with reflexivity, symmetry, monotone weakening, and the **composition
  law** `Interleaved.trans` (`ε`-interleaving ∘ `δ`-interleaving = `(ε+δ)`-interleaving).
- The `ℝ≥0∞`-valued **interleaving distance** `interleavingDist`, proven to be a pseudometric
  (`interleavingDist_self`, `interleavingDist_comm`, `interleavingDist_triangle`).
- The **tropical reformulation** `interleaving_tropical_submul`: the triangle inequality is
  *exactly* submultiplicativity of `trop ∘ interleavingDist` in `Tropical ℝ≥0∞`.
- **Vietoris–Rips stability** (`rips_stability`, `rips_interleavingDist_le`): sup-close
  dissimilarities yield interleaved Rips modules.

The following conjectures are precise, falsifiable targets for the next cycles.

## Conjecture 1 (Isometry / converse stability)
For Rips modules of pseudometrics `d, d'` on a fixed point set, the interleaving distance is
*equal* to (not just bounded by) the sup perturbation:
`interleavingDist (RipsMod d) (RipsMod d') = ENNReal.ofReal (⨆ x y, |d x y - d' x y|)`
whenever the sup is finite. **Test:** prove the `≥` direction by extracting, from any
`ε`-interleaving of edge-set modules, the pointwise bound `|d x y - d' x y| ≤ ε` (evaluate the
interleaving at `t = d x y`). This would upgrade §4 to a genuine isometry theorem.

## Conjecture 2 (Tropical semiring action on the distance lattice)
The map `(M, N) ↦ trop (interleavingDist M N)` is a lax functor into `Tropical ℝ≥0∞`: not only
submultiplicative under composition (proved), but the *self-distance is the tropical unit*
(`trop 0 = 1` in `Tropical ℝ≥0∞`) and constant shifts act by tropical multiplication, i.e.
`interleavingDist (shift c M) (shift c N) = interleavingDist M N` and the shift functor `M ↦
shift c M` satisfies `interleavingDist M (shift c M) ≤ ENNReal.ofReal c`. **Test:** define
`shift c M := ⟨fun t => M.obj (t + c), …⟩` and prove these three identities.

## Conjecture 3 (Stability is 1-Lipschitz / sub-additive in the tropical metric)
Composition of perturbations is tropically multiplicative end-to-end: for dissimilarities
`d, d', d''`,
`trop (interleavingDist (RipsMod d) (RipsMod d''))
   ≤ trop (idist (RipsMod d) (RipsMod d')) * trop (idist (RipsMod d') (RipsMod d''))`,
and moreover this is *tight* when the perturbations are aligned (same sign everywhere).
**Test:** the inequality is immediate from Conjecture-free results already proved; the tightness
clause is the falsifiable content and should be attacked with a 2-point metric space.

## Conjecture 4 (Lattice-valued generalization: persistence in any complete lattice is a
tropical module)
For any complete 
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
