
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

**Title**: Predicative-ordinal-analysis fragment
**Domain**: Applications
**Mathematical framing**: # Future Directions — The Ordinal Collapsing Bridge, Cycle 2

## Synthesis

This cycle extended the predicative-ordinal-analysis fragment
(`Catalog/Logic/StronglyCriticalOrdinals.lean`) with the *arithmetic* of strongly critical
ordinals and then forged a genuine **cross-domain bridge** to the finite-branching collapse
theory (`Catalog/MachineLearning/OrdinalCollapse/Basic.lean`).

The new file `Catalog/Logic/StronglyCriticalClosure.lean` proves, with zero `sorry` and only
the standard axioms `{propext, Classical.choice, Quot.sound}`:

* **Arithmetic closure (Cluster E).** A single Veblen fixed-point condition
  (`veblen o 0 = o`) upgrades to a full arithmetic package: every strongly critical ordinal
  is an ε-number (`StronglyCritical.omega0_opow_eq`), a limit ordinal
  (`StronglyCritical.isLimit`), additively principal (`StronglyCritical.add_lt`), and
  multiplicatively principal (`StronglyCritical.mul_lt`).
* **The Ordinal Collapsing Bridge (Cluster F).** The flagship
  `researchObject_omega_tower_lt_epsilon_zero` proves that for *every* finitely branching
  research object `A`, `ω ^ (researchDepth A) < ε₀`. The finite-branching collapse theorem
  `researchDepth_lt_omega` is fused with the predicative hierarchy: a finite epistemic
  process, even after a transfinite exponential lift, never reaches the proof-theoretic
  ordinal of Peano Arithmetic.
* **Ascending strength tower (Cluster G).** `exists_infinite_ascending_strength_tower`
  constructs the strictly increasing ω-tower `Γ_ 0 < Γ_ 1 < Γ_ 2 < ⋯`, the constructive
  complement to the previously proved `no_infinite_consistency_descent`.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `StronglyCritical.omega0_opow_eq` | `ω ^ o = o` | proved |
| `StronglyCritical.isLimit` | `Order.IsSuccLimit o` | proved |
| `StronglyCritical.add_lt` / `principal_add` | additively principal | proved |
| `StronglyCritical.mul_lt` / `principal_mul` | multiplicatively principal | proved |
| `omega0_opow_lt_epsilon_zero_of_lt` | `o < ε₀ → ω ^ o < ε₀` | proved |
| `researchObject_omega_tower_lt_epsilon_zero` | `ω ^ (researchDepth A) < ε₀` | proved |
| `exists_infinite_ascending_strength_tower` | strict ω-tower of `Γ_ n` | proved |

## Bold, Falsifiable Research Directions

### 1. Exponential closure of strongly critical ordinals

**Conjecture.** Every strongly critical ordinal `o` is closed under ordinal exponentiation:
`a < o → b < o → a ^ b < o`, i.e. `Principal (· ^ ·) o`.

**The key insight is** that an ε-number `o = ω ^ o` already absorbs the base of every
exponential tower, so the only obstruction to closure is the *length* of the tower, which is
itself bounded by `o`; the Cantor normal form of `a` below `o` should let one rewrite `a ^ b`
as a Veblen-fixed expression strictly below `o = veblen o 0`.

**Why now?** Mathlib already supplies `principal_opow_omega0`, the additive/multiplicative
principal characterizations (`principal_*_iff_*`), and the full `veblen_lt_veblen_iff`
trichotomy used in `StronglyCritical.veblen_lt`. The missing step is purely an induction on
Cantor normal form, which the present file's `add_lt`/`mul_lt` lemmas now make tractable.
Falsifiable: a single `a, b < Γ₀` with `a ^ b ≥ Γ₀` would refute it.

### 2. Cofinality `ω` for the entire gamma scale

**Conjecture.** For every `β`, `Ordinal.cof (Γ_ β) = ω`; in particular `cof Γ₀ = ω` and
`cof ε₀ = ω`.

**The key insight is** that `lt_gamma_zero` already exhibits `Γ₀` as the supremum of the
explicit ℕ-indexed sequence `(fun a ↦ veblen a 0)^[n] 0`, a countable cofinal chain; the same
`deriv`/`nfp` fixed-point machinery should yield an `ω`-fundamental sequence at every `Γ_ β`.

**Why now?** The fundamental sequences are already named in Mathlib
(`lt_gamma_zero`, `iterate_veblen_lt_gamma_zero`, `lt_epsilon_zero`), so the cofinality bound
`cof ≤ ω` is one `Ordinal.cof_le_of_...`-style lemma away, and `isLimit` (proved this cycle)
gives `ω ≤ cof`. Falsifiable: any strongly critical ordinal of uncountable cofinality refutes
it.

### 3. A research-object hierarchy theorem above `ε₀`

**Conjecture.** Enriching `ResearchObject` with a transfinite `limitNode : (ℕ → RO) → RO`
constructor (countable branching *without* a height bound) yields objects of depth exactly
`ε₀`, and the closure of such depths under `ω ^ ⬝` is exactly `[0, ε₀]` — so the bridge
`researchObject_omega_tower_lt_epsilon_zero` becomes sharp.

**The key insight is** that the catalog's `omegaTree_rank_eq_omega` already realizes depth `ω`
from unbounded branching; iterating the `ω ^ ⬝` lift along such trees climbs the `ε`-tower,
and the strongly-critical closure lemmas prove the climb cannot overshoot `ε₀` within
finitely many lifts.

**Why now?** `InfBranchTree`, its `rank`, and `omegaTree_rank_eq_omega` are already in the
catalog, and this cycle supplies the exact ceiling lemma `omega0_opow_lt_epsilon_zero_of_lt`.
Falsifiable: a height-unbounded, countably branching object of depth `> ε₀` (or `< ε₀` that is
not `ω`-cofinally approximable) refutes the sharpness claim.

### 4. Strength-tower order isomorphism

**Conjecture.** The map `n ↦ gammaSystem n` extends to a strict order embedding of the whole
ordinal line into `OrdAnalyzedSystem` under `StrongerThan`, and the image (the strongly
critical ordinals) is exactly the set of `StrongerThan`-fixed points of the "Veblen jump"
operator `S ↦ ⟨veblen S.pto 0⟩`.

**The key insight is** that `StrongerThan` is `InvImage (· < ·) pto` (already used in
`strength_wellFounded`), so order-theoretic structure of strengths is *literally* ordinal
order; the Veblen jump is then a normal function whose fixed points `mem_range_gamma`
characterizes as the strongly critical systems.

**Why now?** `isNormal_gamma`, `mem_range_gamma`, and the `OrdAnalyzedSystem`/`StrongerThan`
infrastructure are all in place; the embedding is `isNormal_gamma.strictMono` transported
across the `InvImage`. Falsifiable: a strongly critical ordinal not in `range Γ_`, or a
`Γ_`-value that is not a jump-fixed point, refutes it.

### 5. Predicative ceiling for the bootstrap dynamics

**Conjecture.** For the catalog's `bootstrapIter` and, more generally, any successor-law
operator `f` with `researchDepth (f B) = researchDepth B + 1`, the lifted orbit
`n ↦ ω ^ (researchDepth (f^[n] A))` is a strictly increasing ω-sequence whose supremum is a
strongly critical ordinal iff the base `A` is `ε`-critical — never `Γ₀`.

**The key insight is** that `depth_iter_eq_add_of_successor_law` makes the orbit affine
(`researchDepth A + n`), so the lifted orbit is `ω ^ (researchDepth A + n)`, whose supremum is
`ω ^ (researchDepth A + ω) = ω ^ (researchDepth A) · ε₀`-shaped — provably below `Γ₀` by the
multiplicative-closure lemma `StronglyCritical.mul_lt` proved this cycle.

**Why now?** The affine-growth theorem `depth_iter_eq_add_of_successor_law` and the new
arithmetic-closure cluster are exactly the two ingredients needed to compute and ceiling the
supremum. Falsifiable: a successor-law bootstrap whose lifted-orbit supremum reaches or
exceeds `Γ₀`.

Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Logic/StronglyCriticalClosure.lean
import Logic.StronglyCriticalOrdinals
import MachineLearning.OrdinalCollapse.Basic

/-!
# Arithmetic closure of strongly critical ordinals and the Ordinal Collapsing Bridge

This file extends the predicative-ordinal-analysis fragment of
`Catalog/Logic/StronglyCriticalOrdinals.lean` with the *arithmetic* of strongly critical
ordinals, and then forges a cross-domain bridge to the finite-branching collapse theory of
`Catalog/MachineLearning/OrdinalCollapse/Basic.lean`.

The pivot is `StronglyCritical.omega0_opow_eq`: the single unary Veblen fixed-point condition
`veblen o 0 = o` (the catalog's definition of `StronglyCritical`) forces `o` to be an
ε-number, `ω ^ o = o`.  Every further arithmetic property — being a limit ordinal, additive
and multiplicative principality — then follows from Mathlib's principal-ordinal API applied
to `ω ^ o`.

## Main results

### Cluster E — Arithmetic closure
* `StronglyCritical.omega0_opow_eq` — a strongly critical ordinal is an ε-number `ω ^ o = o`.
* `StronglyCritical.isLimit` — strongly critical ordinals are (successor) limit ordinals.
* `StronglyCritical.principal_add` / `StronglyCritical.add_lt` — additive principality.
* `StronglyCritical.principal_mul` / `StronglyCritical.mul_lt` — multiplicative principality.

### Cluster F — The Ordinal Collapsing Bridge
* `omega0_opow_lt_epsilon_zero_of_lt` — `ε₀` is closed under `ω ^ ⬝` below itself.
* `researchObject_omega_tower_lt_epsilon_zero` (flagship) — for *every* finitely branching
  `ResearchObject A`, `ω ^ (researchDepth A) < ε₀`.  A finite epistemic process, even after a
  transfinite exponential lift, never reaches the proof-theoretic ordinal of `PA`.

### Cluster G — Ascending strength tower
* `exists_infinite_ascending_strength_tower` — the strictly increasing ω-tower
  `Γ_ 0 < Γ_ 1 < ⋯` of strongly critical systems, the constructive complement to the
  catalog's `no_infinite_consistency_descent`.

## Lineage / catalog synthesis

The file builds directly on the catalog: `StronglyCritical` and `StronglyCritical.veblen_eq`
come from `Logic.StronglyCriticalOrdinals`; the bridge fuses
`ResearchObject.researchDepth_lt_omega` from `MachineLearning.OrdinalCollapse.Basic` with the
predicative hierarchy; the ascending tower is the order-dual of
`Predicative.no_infinite_consistency_descent` over the same `OrdAnalyzedSystem`/`StrongerThan`
infrastructure.
-/

/- -- !-- Lab Notebook -- !--
  Hypothesis (Cluster E): The unary Veblen fixed point `veblen o 0 = o` that *defines*
    `StronglyCritical` should be strong enough to recover the full arithmetic profile of a
    strongly critical ordinal — ε-number, limit, additively and multiplicatively principal —
    without any further hypotheses.
  Result: Confirmed. `StronglyCritical.veblen_eq` (catalog) at `a = 0` plus
    `veblen_zero_apply` collapses the definition to `ω ^ o = o`; everything else is a
    one-line transport of a Mathlib `principal_*`/`isSuccLimit_*` lemma across that equation.
  Insight: ε-numberhood is the *correct* normal form for `StronglyCritical`. The unary Veblen
    condition and the exponential fixed-point condition `ω ^ o = o` are interchangeable, which
    is what lets the entire `Ordinal.Principal` toolbox apply verbatim.

  Hypothesis (Cluster F): Finite branching (catalog `researchDepth_lt_omega`) is preserved
    under the exponential lift `ω ^ ⬝` relative to the ceiling `ε₀`.
  Result: Confirmed via `omega0_opow_lt_epsilon_zero_of_lt`, proved from the fundamental
    sequence `lt_epsilon_zero` for `ε₀`. Since `researchDepth A < ω < ε₀`, the lift stays
    below `ε₀`.
  Insight: The bridge is sharp at the *base* level — `ω < ε₀` is what makes the single lift
    safe; iterating the lift transfinitely is exactly Future Direction 3.
  Failure analysis: The first instinct was to bound `ω ^ (researchDepth A)` by an explicit
    iterate `(ω ^ ⬝)^[n] 0`; this is true but awkward. Routing through the abstract closure
    lemma `omega0_opow_lt_epsilon_zero_of_lt` (`o < ε₀ → ω ^ o < ε₀`) is cleaner and reusable.

  Hypothesis (Cluster G): The `gamma` scale gives a constructive strictly ascending tower of
    strongly critical systems, mirroring (dually) `no_infinite_consistency_descent`.
  Result: Confirmed. `gamma_lt_gamma` gives strict monotonicity of `n ↦ Γ_ n`, and
    `gamma_stronglyCritical` (catalog) gives strong criticality of every rung.
-/

namespace Predicative

open Ordinal

/-! ## Cluster E — Arithmetic closure of strongly critical ordinals -/

-- !-- `StronglyCritical.veblen_eq` at `a = 0` gives `veblen 0 o = o`; rewrite the left side
-- with `veblen_zero_apply : veblen 0 o = ω ^ o`. -- !--
/-- **ε-number.**  Every strongly critical ordinal is a fixed point of `ω ^ ⬝`. -/
theorem StronglyCritical.omega0_opow_eq {o : Ordinal} (h : StronglyCritical o) :
    ω ^ o = o := by
  have hv := h.veblen_eq h.1
  rw [veblen_zero_apply] at hv
  exact hv

-- !-- Rewrite `o` as `ω ^ o` (`omega0_opow_eq`) and apply `isSuccLimit_opow_left` with the
-- limit base `ω` and the nonzero exponent `o`. -- !--
/-- **Limit ordinal.**  Every strongly critical ordinal is a successor-limit ordinal. -/
theorem StronglyCritical.isLimit {o : Ordinal} (h : StronglyCritical o) :
    Order.IsSuccLimit o := by
  have he : ω ^ o = o := h.omega0_opow_eq
  rw [← he]
  exact isSuccLimit_opow_left isSuccLimit_omega0 (ne_of_gt h.1)

-- !-- Transport `principal_add_omega0_opow o : Principal (·+·) (ω ^ o)` across
-- `ω ^ o = o`. -- !--
/-- **Additive principality.**  Strongly critical ordinals are additively principal. -/
theorem StronglyCritical.principal_add {o : Ordinal} (h : StronglyCritical o) :
    Principal (· + ·) o := by
  have he : ω ^ o = o := h.omega0_opow_eq
  rw [← he]
  exact principal_add_omega0_opow o

-- !-- Specialize additive principality to the two summands. -- !--
/-- If `a, b < o` and `o` is strongly critical then `a + b < o`. -/
theorem StronglyCritical.add_lt {o a b : Ordinal} (h : StronglyCritical o)
    (ha : a < o) (hb : b < o) : a + b < o :=
  h.principal_add ha hb

-- !-- From `ω ^ o = o` we get `ω ^ ω ^ o = o`; transport `principal_mul_omega0_opow_opow o`
-- across this equation. -- !--
/-- **Multiplicative principality.**  Strongly critical ordinals are multiplicatively
principal. -/
theorem StronglyCritical.principal_mul {o : Ordinal} (h : StronglyCritical o) :
    Principal (· * ·) o := by
  have he : ω ^ o = o := h.omega0_opow_eq
  have he2 : ω ^ ω ^ o = o := by rw [he, he]
  rw [← he2]
  exact principal_mul_omega0_opow_opow o

-- !-- Specialize multiplicative principality to the two factors. -- !--
/-- If `a, b < o` and `o` is strongly critical then `a * b < o`. -/
theorem StronglyCritical.mul_lt {o a b : Ordinal} (h : StronglyCritical o)
    (ha : a < o) (hb : b < o) : a * b < o :=
  h.principal_mul ha hb

/-! ## Cluster F — The Ordinal Collapsing Bridge -/

-- !-- Use the fundamental sequence `lt_epsilon_zero` to get `o < (ω ^ ⬝)^[n] 0`; then
-- `ω ^ o < ω ^ ((ω ^ ⬝)^[n] 0) = (ω ^ ⬝)^[n+1] 0 < ε₀` via `opow_lt_opow_iff_right` and
-- `iterate_omega0_opow_lt_epsilon_zero`. -- !--
/-- **ε₀ is closed under `ω ^ ⬝` below itself.**  If `o < ε₀` then `ω ^ o < ε₀`. -/
theorem omega0_opow_lt_epsilon_zero_of_lt {o : Ordinal} (h : o < ε₀) : ω ^ o < ε₀ := by
  rw [lt_epsilon_zero] at h
  obtain ⟨n, hn⟩ := h
  calc ω ^ o < ω ^ ((fun a => ω ^ a)^[n] 0) :=
        (opow_lt_opow_iff_right one_lt_omega0).mpr hn
    _ = (fun a => ω ^ a)^[n + 1] 0 := by rw [Function.iterate_succ_apply']
    _ < ε₀ := iterate_omega0_opow_lt_epsilon_zero (n + 1)

-- !-- The catalog's `researchDepth_lt_omega` gives `researchDepth A < ω`, and
-- `ω < ε₀` (`omega0_lt_epsilon 0`); chain them and apply
-- `omega0_opow_lt_epsilon_zero_of_lt`. -- !--
/-- **Flagship — the Ordinal Collapsing Bridge.**  For *every* finitely branching research
object `A`, the transfinite exponential lift of its depth stays below the proof-theoretic
ordinal of Peano Arithmetic: `ω ^ (researchDepth A) < ε₀`
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — The Ordinal Collapsing Bridge, Cycle 2

## Synthesis

This cycle extended the predicative-ordinal-analysis fragment
(`Catalog/Logic/StronglyCriticalOrdinals.lean`) with the *arithmetic* of strongly critical
ordinals and then forged a genuine **cross-domain bridge** to the finite-branching collapse
theory (`Catalog/MachineLearning/OrdinalCollapse/Basic.lean`).

The new file `Catalog/Logic/StronglyCriticalClosure.lean` proves, with zero `sorry` and only
the standard axioms `{propext, Classical.choice, Quot.sound}`, three clusters of results.

* **Arithmetic closure (Cluster E).** The single unary Veblen fixed-point condition
  `veblen o 0 = o` that *defines* a strongly critical ordinal (catalog
  `Predicative.StronglyCritical`) upgrades to a full arithmetic package. The pivot lemma
  `StronglyCritical.omega0_opow_eq` shows every strongly critical ordinal is an ε-number
  (`ω ^ o = o`); from there `StronglyCritical.isLimit` (it is a limit ordinal),
  `StronglyCritical.principal_add` / `add_lt` (additively principal), and
  `StronglyCritical.principal_mul` / `mul_lt` (multiplicatively principal) follow by
  transporting Mathlib's `Ordinal.Principal` API across the ε-number equation.
* **The Ordinal Collapsing Bridge (Cluster F).** The flagship
  `researchObject_omega_tower_lt_epsilon_zero` proves that for *every* finitely branching
  research object `A`, `ω ^ (researchDepth A) < ε₀`. The finite-branching collapse theorem
  `ResearchObject.researchDepth_lt_omega` is fused with the predicative hierarchy through the
  reusable ceiling lemma `omega0_opow_lt_epsilon_zero_of_lt`: a finite epistemic process,
  even after a transfinite exponential lift, never reaches the proof-theoretic ordinal of
  Peano Arithmetic.
* **Ascending strength tower (Cluster G).** `exists_infinite_ascending_strength_tower`
  constructs the strictly increasing ω-tower `Γ_ 0 < Γ_ 1 < Γ_ 2 < ⋯` of strongly critical
  systems — the constructive complement to the previously proved
  `Predicative.no_infinite_consistency_descent`.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `StronglyCritical.omega0_opow_eq` | `ω ^ o = o` | proved |
| `StronglyCritical.isLimit` | `Order.IsSuccLimit o` | proved |
| `StronglyCritical.principal_add` / `add_lt` | additively principal | proved |
| `StronglyCritical.principal_mul` / `mul_lt` | multiplicatively principal | proved |
| `omega0_opow_lt_epsilon_zero_of_lt` | `o < ε₀ → ω ^ o < ε₀` | proved |
| `researchObject_omega_tower_lt_epsilon_zero` | `ω ^ (researchDepth A) < ε₀` | proved |
| `exists_infinite_ascending_strength_tower` | strict ω-tower of `Γ_ n` | proved |

## Bold, Falsifiable Research Directions

### 1. Exponential closure of strongly critical ordinals

**Conjecture.** Every strongly critical ordinal `o` is closed under ordinal exponentiation:
`a < o → b < o → a ^ b < o`, i.e. `Principal (· ^ ·) o`.

**The key insight is** that an ε-number `o = ω ^ o` (now available as
`StronglyCritical.omega0_o
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
