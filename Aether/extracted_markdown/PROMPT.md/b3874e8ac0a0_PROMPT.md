
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

**Title**: Close Proofs: Close Proofs: Formalized framework connecting Collatz dynami
**Domain**: Logic
**Mathematical framing**: Cycle 085a52a3 (Q=0.423) proved 1635 theorems in Logic but left 5 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Cycle f2700283 (Q=0.426) proved 1066 theorems in Applications but left 1 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: # Future Directions
Research domain: Logic
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Bridges/HellyPrinciple.lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Harmonic Research
-/
import Mathlib

/-!
# A Categorical Helly Principle for Probe Families

This file establishes a **local-to-global finite generation principle** for
probe-separated presheaves on finite discrete categories. The central idea is
that a separating probe family P of size k creates a "measurement window" of
bounded size: to control the global representable dimension of a presheaf F,
it suffices to check fiber sizes on subsets of size at most k + 1.

This is a categorical analogue of **Helly's theorem** from convex geometry.

## Main Definitions

* `restrictedRepDim` — the representable dimension restricted to a subset S.
* `Presheaf.LocallyRepFinGenUpTo` — locally representably finitely generated.
* `probeCapacity` — product of fiber sizes at probe objects.
* `categoricalHellyNumber` — the Helly number |P| + 1.
* `MinimalNonSeparatedWitness` — obstruction witness.

## Main Results

* `fiber_le_probe_capacity` — fiber bound under separation. (**Theorem 1**)
* `repFinGen_of_local_on_helly_bound` — categorical Helly theorem. (**Theorem 2**)
* `separation_supset_presheaf` — separation preserved by enlargement. (**Theorem 3**)
* `obstruction_localized_to_helly_number` — obstruction localization. (**Theorem 4**)
-/

open Finset Fintype CategoryTheory

noncomputable section

universe u v

set_option linter.unusedSectionVars false
set_option linter.unusedVariables false

variable {Ob : Type u} [Fintype Ob] [DecidableEq Ob]

/-! ### Inherited Definitions (from ProbeComplexity.RepresentableDimension) -/

/-- A probe family for the discrete presheaf model. -/
abbrev ObProbeFamilyH (Ob : Type u) := Finset Ob

/-- The probe signature of an element `x ∈ F(Y)` records its image under
restriction maps `r Y Z` for each probe object `Z ∈ P`. -/
def probeSignatureH
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    (P : ObProbeFamilyH Ob)
    (r : ∀ Y Z, F Y → F Z)
    (Y : Ob) (x : F Y) : ∀ Z : ↥P, F (↑Z) :=
  fun ⟨Z, _⟩ => r Y Z x

/-- The probe signature map is injective at object Y. -/
def ProbeSignatureInjectiveH
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    (P : ObProbeFamilyH Ob)
    (r : ∀ Y Z, F Y → F Z)
    (Y : Ob) : Prop :=
  Function.Injective (probeSignatureH P r Y)

/-- A probe family separates a presheaf F if probe signatures are
injective at every object. -/
def PresheafProbeSeparatesH
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    (P : ObProbeFamilyH Ob) (r : ∀ Y Z, F Y → F Z) : Prop :=
  ∀ Y, ProbeSignatureInjectiveH P r Y

/-- Total objectwise cardinality of a presheaf. -/
def objectwiseTotalCardH
    (F : Ob → Type v) [∀ Y, Fintype (F Y)] : ℕ :=
  ∑ Y : Ob, Fintype.card (F Y)

/-! ### New Definitions -/

/-- The **restricted representable dimension** on a subset S: the sum of
fiber cardinalities over objects in S. -/
def restrictedRepDim (F : Ob → Type v) [∀ Y, Fintype (F Y)]
    (S : Finset Ob) : ℕ :=
  S.sum fun Y => Fintype.card (F Y)

/-- A presheaf is **locally representably finitely generated up to k** with
bound n if every restriction to at most k objects has total fiber size ≤ n. -/
def Presheaf.LocallyRepFinGenUpTo
    (F : Ob → Type v) [∀ Y, Fintype (F Y)] (k n : ℕ) : Prop :=
  ∀ S : Finset Ob, S.card ≤ k → restrictedRepDim F S ≤ n

/-- The **probe capacity** of F w.r.t. P: the product of fiber sizes at
probe objects. Under separation, this bounds each individual fiber. -/
def probeCapacity
    (F : Ob → Type v) [∀ Y, Fintype (F Y)]
    (P : ObProbeFamilyH Ob) : ℕ :=
  ∏ Z : ↥P, Fintype.card (F ↑Z)

/-- The **categorical Helly number** of a probe family P is |P| + 1. -/
def categoricalHellyNumber (P : ObProbeFamilyH Ob) : ℕ := P.card + 1

/-- A **minimal non-separated witness** at object Y: a pair of distinct
elements with identical probe signatures. -/
def MinimalNonSeparatedWitness
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    (P : ObProbeFamilyH Ob) (r : ∀ Y Z, F Y → F Z) (Y : Ob) : Prop :=
  ∃ (x y : F Y), x ≠ y ∧ probeSignatureH P r Y x = probeSignatureH P r Y y

/-! ### Helper Lemmas -/

/-- Restricted representable dimension on a singleton equals the fiber size. -/
theorem restrictedRepDim_singleton (F : Ob → Type v) [∀ Y, Fintype (F Y)]
    (Z : Ob) : restrictedRepDim F {Z} = Fintype.card (F Z) := by
  simp [restrictedRepDim]

/-- Restricted representable dimension is monotone under subset inclusion. -/
theorem restrictedRepDim_mono (F : Ob → Type v) [∀ Y, Fintype (F Y)]
    {S T : Finset Ob} (hST : S ⊆ T) :
    restrictedRepDim F S ≤ restrictedRepDim F T := by
  exact Finset.sum_le_sum_of_subset hST

/-- Restricted representable dimension on univ equals objectwise total card. -/
theorem restrictedRepDim_univ (F : Ob → Type v) [∀ Y, Fintype (F Y)] :
    restrictedRepDim F Finset.univ = objectwiseTotalCardH F := by
  simp [restrictedRepDim, objectwiseTotalCardH]

/-- Each probe-object fiber is bounded by the local bound n. -/
theorem probe_fiber_le_of_local_bound
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    (P : ObProbeFamilyH Ob) (n : ℕ)
    (hlocal : Presheaf.LocallyRepFinGenUpTo F (categoricalHellyNumber P) n)
    (Z : Ob) (hZ : Z ∈ P) :
    Fintype.card (F Z) ≤ n := by
  have h1 : ({Z} : Finset Ob).card ≤ categoricalHellyNumber P := by
    simp [categoricalHellyNumber]
  have h2 := hlocal {Z} h1
  rwa [restrictedRepDim_singleton] at h2

/-- Every fiber is bounded by the local bound n when k ≥ 1. -/
theorem every_fiber_le_of_local_bound
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    (k n : ℕ) (hk : 1 ≤ k)
    (hlocal : Presheaf.LocallyRepFinGenUpTo F k n)
    (Y : Ob) :
    Fintype.card (F Y) ≤ n := by
  have h1 : ({Y} : Finset Ob).card ≤ k := by simp; omega
  have h2 := hlocal {Y} h1
  rwa [restrictedRepDim_singleton] at h2

/-
The probe capacity is bounded by n^|P| when each probe fiber is ≤ n.
-/
theorem probe_capacity_le_pow
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    (P : ObProbeFamilyH Ob) (n : ℕ)
    (hbound : ∀ Z : Ob, Z ∈ P → Fintype.card (F Z) ≤ n) :
    probeCapacity F P ≤ n ^ P.card := by
  convert Finset.prod_le_prod' fun Z hZ => hbound Z <| Finset.mem_coe.mp hZ;
  · refine' Finset.prod_bij ( fun x hx => x ) _ _ _ _ <;> simp +decide;
  · rw [ Finset.prod_const, Finset.card_eq_sum_ones ]

/-! ### Theorem 1: Fiber Capacity Bound -/

/-
**Theorem 1 (Fiber Capacity Bound — the Helly Engine).**

Under probe separation, each fiber |F(Y)| is bounded by the product
of fiber sizes at probe objects: |F(Y)| ≤ ∏_{Z ∈ P} |F(Z)|.
-/
theorem fiber_le_probe_capacity
    {F : Ob → Type v} [∀ Y, Fintype (F Y)] [∀ Y, DecidableEq (F Y)]
    (P : ObProbeFamilyH Ob) (r : ∀ Y Z, F Y → F Z)
    [DecidableEq (∀ Z : ↥P, F ↑Z)]
    (hsep : PresheafProbeSeparatesH P r) (Y : Ob) :
    Fintype.card (F Y) ≤ probeCapacity F P := by
  convert Fintype.card_le_of_injective _ ( hsep Y ) using 1;
  rw [ Fintype.card_pi ];
  rfl

/-! ### Theorem 2: The Categorical Helly Theorem -/

/-- **Theorem 2 (The Categorical Helly Theorem).**

If P separates F and every subset of Ob of size ≤ |P| + 1 has restricted
representable dimension ≤ n, then the global representable dimension is
at most |Ob| · n^|P|.

**Proof architecture:**
1. Each probe-object fiber |F(Z)| ≤ n (from local bound on singletons).
2. Probe capacity ∏_{Z ∈ P} |F(Z)| ≤ n^|P| (product of bounded terms).
3. Each fiber |F(Y)| ≤ n^|P| (from Theorem 1 + step 2).
4. Sum: ∑_Y |F(Y)| ≤ |Ob| · n^|P|. -/
theorem repFinGen_of_local_on_helly_bound
    {F : Ob → Type v} [∀ Y, Fintype (F Y)] [∀ Y, DecidableEq (F Y)]
    (P : ObProbeFamilyH Ob) (r : ∀ Y Z, F Y → F Z)
    [DecidableEq (∀ Z : ↥P, F ↑Z)]
    (hsep : PresheafProbeSeparatesH P r)
    (n : ℕ)
    (hlocal : Presheaf.LocallyRepFinGenUpTo F (categoricalHellyNumber P) n) :
    objectwiseTotalCardH F ≤ Fintype.card Ob * n ^ P.card := by
  have hprobe_bound : ∀ Z : Ob, Z ∈ P → Fintype.card (F Z) ≤ n :=
    fun Z hZ => probe_fiber_le_of_local_bound P n hlocal 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions

## Synthesis

This cycle established a rigorous foundation for the modular-arithmetic structure of the Collatz dynamical system. We proved four main theorems: that powers of 2 deterministically descend to 1, that no positive fixed points or 2-cycles exist, and that the parity of the shortcut Collatz map is fully determined by residues modulo 4. The last result is particularly significant — it shows that the "randomness" of Collatz trajectories is entirely governed by the binary expansion of the input, with each additional bit determining the next branching decision.

The cycle revealed that omega (Lean's linear arithmetic decision procedure) is remarkably powerful for Collatz-style arguments involving modular arithmetic and natural number division. The no-fixed-point and no-2-cycle results, which require careful case analysis over parity, were discharged automatically. The pow2_reaches_one theorem required genuine induction and was the only result that needed structural reasoning beyond arithmetic.

A key structural insight: the Collatz map's cycle structure at short periods is trivially excluded by linear constraints over ℕ, but longer cycles (period ≥ 3) resist this approach because the system of equations becomes nonlinear. The boundary between "easily excludable" and "open" lies precisely at the transition from linear to polynomial constraints on cycle lengths.

## Results Summary

- `pow2_reaches_one`: proved — Powers of 2 reach 1 in exactly k Collatz steps, confirming 2-adic descent
- `collatz_no_positive_fixed_point`: proved — The Collatz map has no positive fixed point (C(n) ≠ n for n > 0)
- `collatz_no_positive_two_cycle`: proved — No positive 2-cycle exists (C(C(n)) ≠ n for n > 0)
- `shortcut_mod4_case1`: proved — For n ≡ 1 (mod 4), the shortcut map (3n+1)/2 is even
- `shortcut_mod4_case3`: proved — For n ≡ 3 (mod 4), the shortcut map (3n+1)/2 is odd
- `odd_mod4_cases`: proved — Every odd number is 1 or 3 mod 4 (completeness of branching)
- `C_pow2`: proved — Helper: C(2^k) = 2^(k-1) for k > 0

## Research Directions

### Direction 1: Exclude Positive 3-Cycles via Modular Constraints
**Hypothesis**: There is no n > 0 such that C(C(C(n))) = n, i.e., the Collatz map has no positive 3-cycle.
**Test**: Attempt to prove `∀ n : ℕ, 0 < n → C (C (C n)) ≠ n` by exhaustive case analysis on parities. The proof would require case-splitting on (n % 2, C(n) % 2, C(C(n)) % 2) — 8 cases, each yielding a system of linear constraints over ℕ.
**Why now**: This cycle showed that omega handles the 2-cycle case automatically. The 3-cycle case has 8 parity cases (vs. 4 for 2-cycles), but each individual case still reduces to linear arithmetic. The key insight is that period-k cycle exclusion stays tractable as long as 2^k cases each yield contradictions under omega.
**If true**: Would establish that the minimal period of any positive Collatz cycle is ≥ 4, significantly constraining the dynamics.
**If false**: Would identify a specific par
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
