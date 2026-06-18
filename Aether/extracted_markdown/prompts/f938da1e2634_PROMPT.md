
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

**Title**: Close Proofs: This cycle replaced the softmax score `exp⟨q,k⟩` with th
**Domain**: Applications
**Mathematical framing**: Cycle 166e1d18 (Q=0.627) proved 290 theorems in Cryptography but left 12 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Cycle 12ce834d (Q=0.527) proved 1655 theorems in Cryptography but left 18 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Cycle f3a4b926 (Q=
Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Bridges/TropicalHecke/Correspondence.lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Bridges.TropicalHecke.Defs

/-!
# Tropical Spectral Langlands Correspondence

This file establishes the core theorems of the tropical spectral Langlands
correspondence: the injection from simple summands of a finite tropical
semimodule into extremal closure eigenmeasures on its closure spectrum,
character recovery, and the classification theorem.

## Main results

### Stage 1: Closure from Residuation
* `closureSpectrum_of_residualAction` — every residuated action induces a
  closure spectrum object

### Stage 2: Eigenline-to-Eigenmeasure Map
* `summandToEigenmeasure` — each simple summand induces a closure eigenmeasure

### Stage 3: Spectral Correspondence
* `summandToEigenmeasure_injective` — distinct summands → distinct eigenmeasures
* `spectral_correspondence_injective` — the main injection theorem

### Stage 4: Character Recovery
* `tropicalCharacter_is_closed` — the tropical character is a closed element
* `tropicalCharacter_largest_closed` — it is the largest closed element

## Mathematical overview

For a residuated action of `H` on a finite lattice `M`:
1. Each `res_h ∘ act_h` is a closure operator (Galois connection theory)
2. Fixed points (closed elements) form a finite sublattice
3. Simple summands inject into closure eigenmeasures via indicator functionals
4. The tropical character (closure of ⊤) is the supremum of closed elements
-/

noncomputable section

open Set Function Finset

/-! ## Stage 1: Closure Spectrum Construction -/

/-- **Stage 1**: Every residuated action induces a closure spectrum object. -/
theorem closureSpectrum_of_residualAction
    (H M : Type*) [PartialOrder M] (ρ : ResidualAction H M) :
    Nonempty (ClosureSpectrum H M) :=
  ⟨ρ.toClosureSpectrum⟩

/-! ### Closure operator properties -/

/-- The closure of a fixed point is itself. -/
theorem closure_of_fixed {H M : Type*} [PartialOrder M]
    (ρ : ResidualAction H M) (h : H) (x : M) (hx : ρ.IsClosed h x) :
    (ρ.closureOp h) x = x := hx

/-- The closure operator is monotone. -/
theorem closureOp_mono {H M : Type*} [PartialOrder M]
    (ρ : ResidualAction H M) (h : H) : Monotone (ρ.closureOp h) :=
  (ρ.closureOp h).monotone

/-- The closure of any element is closed. -/
theorem closure_isClosed {H M : Type*} [PartialOrder M]
    (ρ : ResidualAction H M) (h : H) (x : M) :
    ρ.IsClosed h ((ρ.closureOp h) x) :=
  ρ.closure_idempotent h x

/-! ## Stage 2: Fixed Point Characterization -/

/-- The finset of closed elements for a given `h`. -/
def closedFinset {H M : Type*} [PartialOrder M] [DecidableEq M] [Fintype M]
    (ρ : ResidualAction H M) (h : H) : Finset M :=
  Finset.univ.filter (fun x => (ρ.closureOp h) x = x)

/-- Membership in the closed finset. -/
theorem mem_closedFinset {H M : Type*} [PartialOrder M] [DecidableEq M] [Fintype M]
    (ρ : ResidualAction H M) (h : H) (x : M) :
    x ∈ closedFinset ρ h ↔ ρ.IsClosed h x := by
  simp [closedFinset, ResidualAction.IsClosed]

/-- The spectral size equals the cardinality of the closed finset. -/
theorem spectralSize_eq_closedFinset_card {H M : Type*}
    [PartialOrder M] [DecidableEq M] [Fintype M]
    (ρ : ResidualAction H M) (h : H) :
    spectralSize ρ h = (closedFinset ρ h).card := by
  simp [spectralSize, closedFinset]

/-- A closure operator on a finite nonempty type has at least one fixed point. -/
theorem closedFinset_nonempty {H M : Type*}
    [PartialOrder M] [DecidableEq M] [Fintype M] [Nonempty M]
    (ρ : ResidualAction H M) (h : H) :
    (closedFinset ρ h).Nonempty := by
  obtain ⟨x⟩ : Nonempty M := inferInstance
  exact ⟨(ρ.closureOp h) x, by
    rw [mem_closedFinset]
    exact closure_isClosed ρ h x⟩

/-! ## The Tropical Character -/

/-- The tropical character at `h` is the closure of the top element. -/
theorem tropicalCharacter_is_closed {H M : Type*}
    [PartialOrder M] [OrderTop M] (ρ : ResidualAction H M) (h : H) :
    ρ.IsClosed h (tropicalCharacter ρ h) :=
  ρ.closure_idempotent h ⊤

/-- The tropical character is the largest closed element. -/
theorem tropicalCharacter_largest_closed {H M : Type*}
    [PartialOrder M] [OrderTop M] (ρ : ResidualAction H M) (h : H)
    (x : M) (_ : ρ.IsClosed h x) :
    x ≤ tropicalCharacter ρ h :=
  le_top.trans (ρ.le_closure h ⊤)

/-! ## Multiplicative Action -/

/-- A **multiplicative residuated action** extends `ResidualAction` with
    compatibility with a monoid structure on `H`. -/
structure MulResidualAction (H : Type*) [Monoid H] (M : Type*) [PartialOrder M]
    extends ResidualAction H M where
  act_mul : ∀ h₁ h₂ : H, ∀ x : M, act (h₁ * h₂) x = act h₁ (act h₂ x)
  act_one : ∀ x : M, act 1 x = x

namespace MulResidualAction

variable {H : Type*} [Monoid H] {M : Type*} [PartialOrder M]
    (ρ : MulResidualAction H M)

/-
The identity gives the identity closure operator.
-/
theorem closureOp_one (x : M) :
    (ρ.toResidualAction.closureOp 1) x = x := by
  -- By definition of closure operator, we have cl_1(x) = res_1(act_1(x)) = res_1(x) since act_1(x) = x.
  unfold ResidualAction.closureOp;
  have := ρ.gc 1;
  exact le_antisymm ( by simpa [ ρ.act_one ] using this ( ρ.res 1 x ) x ) ( by simpa [ ρ.act_one ] using this x x )

end MulResidualAction

/-! ## Stage 3: The Spectral Correspondence -/

/-- Given a simple summand (a non-bottom element closed under all `h`),
    construct an indicator function: `0` if `s ≤ x`, else `⊥`. -/
def summandIndicator {H M : Type*} [SemilatticeSup M] [OrderBot M]
    [DecidableRel ((· ≤ ·) : M → M → Prop)]
    (ρ : ResidualAction H M) (s : SimpleSummand ρ) : M → WithBot ℤ :=
  fun x => if s.val ≤ x then (0 : WithBot ℤ) else ⊥

/-
The summand indicator is monotone.
-/
theorem summandIndicator_mono {H M : Type*} [SemilatticeSup M] [OrderBot M]
    [DecidableRel ((· ≤ ·) : M → M → Prop)]
    (ρ : ResidualAction H M) (s : SimpleSummand ρ) :
    Monotone (summandIndicator ρ s) := by
  intro x y hxy;
  by_cases h : s.val ≤ x <;> simp_all +decide [ summandIndicator ];
  rw [ if_pos ( le_trans h hxy ) ]

/-
The summand indicator maps bot to bot.
-/
theorem summandIndicator_bot {H M : Type*} [SemilatticeSup M] [OrderBot M]
    [DecidableRel ((· ≤ ·) : M → M → Prop)]
    (ρ : ResidualAction H M) (s : SimpleSummand ρ) :
    summandIndicator ρ s ⊥ = ⊥ := by
  -- Since $s.val \neq \bot$, we have $¬(s.val ≤ ⊥)$, so the if statement returns $\bot$.
  have h_not_le_bot : ¬(s.val ≤ ⊥) := by
    exact fun h => s.ne_bot ( le_bot_iff.mp h );
  exact if_neg h_not_le_bot

/-
The summand indicator is closure-invariant: `μ(cl_h(x)) = μ(x)`.
-/
theorem summandIndicator_closure_invariant {H M : Type*}
    [SemilatticeSup M] [OrderBot M]
    [DecidableRel ((· ≤ ·) : M → M → Prop)]
    (ρ : ResidualAction H M) (s : SimpleSummand ρ)
    (h : H) (x : M) :
    summandIndicator ρ s ((ρ.closureOp h) x) = summandIndicator ρ s x := by
  by_cases h' : s.val ≤ x <;> simp +decide [ summandIndicator, h' ];
  · exact le_trans h' ( ρ.le_closure h x );
  · exact fun h'' => h' ( s.closure_prime h x h'' )

/-- **Main construction**: each simple summand gives a closure eigenmeasure. -/
def summandToEigenmeasure {H M : Type*} [SemilatticeSup M] [OrderBot M]
    [DecidableRel ((· ≤ ·) : M → M → Prop)]
    (ρ : ResidualAction H M) (s : SimpleSummand ρ) :
    ClosureEigenmeasure ρ where
  toFun := summandIndicator ρ s
  mono := summandIndicator_mono ρ s
  bot_map := summandIndicator_bot ρ s
  closure_invariant := summandIndicator_closure_invariant ρ s

/-
**Injectivity**: distinct simple summands give distinct eigenmeasures.
-/
theorem summandToEigenmeasure_injective {H M : Type*}
    [SemilatticeSup M] [OrderBot M]
    [DecidableRel ((· ≤ ·) : M → M → Prop)]
    (ρ : ResidualAction H M) :
    Function.Injective (summandToEigenmeasure ρ) := by
  intro s1 s2 h_eq
  have h_val : s1.val = s2.val := by
    have h_val : summandIndicator ρ s1 s2.val = 0 ∧ summandInd
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — The Fibonacci Apparition Lattice

## Synthesis

This cycle took a single orphaned catalog identity — `Nat.fib_gcd`
("Fib_gcd_identity"), already leveraged in
`Cryptography/FibonacciDivisibilityLattice.lean` to build the *rank of apparition*
`FibLattice.entry m` and the apparition law
`FibLattice.fib_dvd_iff_entry_dvd : m ∣ fib n ↔ entry m ∣ n` — and showed that this
one bridge lemma is enough to turn the rank of apparition into a genuine **lattice
homomorphism** of the divisibility order. The new file
`Cryptography/FibonacciApparitionLattice.lean` proves that `entry` is determined by the
set of indices it divides, is monotone for divisibility, and (the headline result)
*commutes with `lcm`*. The CRT corollary `entry_mul_coprime` then decomposes the
Fibonacci order of a composite modulus across its coprime factors — the structural
engine behind Lucas-sequence primality testing. Finally `entry_eq_iff_primitive`
welds this apparition theory directly onto the catalog's Carmichael primitive-divisor
program (`Shared/CarmichaelProof.lean`): a modulus `m` has `entry m = n` **iff** `m` is
a primitive divisor of `fib n`, recasting "primitive prime divisor of `fib n`" as
simply "prime with rank of apparition `n`".

## Results summary

All results live in `Cryptography/FibonacciApparitionLattice.lean`, namespace
`FibLattice`, sorry-free (axioms: `propext`, `Classical.choice`, `Quot.sound`):

- `eq_of_dvd_iff_dvd` — a natural number is determined by its set of multiples.
- `entry_unique` — the apparition law *characterizes* `entry`.
- `entry_eq_one_iff` — `entry m = 1 ↔ m = 1`.
- `entry_dvd_entry_of_dvd` — `entry` is monotone for divisibility.
- `entry_lcm` — **`entry (lcm m n) = lcm (entry m) (entry n)`** (the lattice homomorphism).
- `entry_mul_coprime` — CRT decomposition of the Fibonacci order over coprime factors.
- `entry_eq_iff_primitive` — `entry m = n ↔ m` is a primitive divisor of `fib n`.

## Research directions

### 1. The exact rank of apparition at a prime via the Legendre symbol
Conjecture: for an odd prime `p ≠ 5`, `entry p ∣ p - (5 / p)` where `(5 / p)` is the
Legendre symbol; equivalently `entry p ∣ p - 1` when `p ≡ ±1 (mod 5)` and
`entry p ∣ p + 1` when `p ≡ ±2 (mod 5)`. The key insight is that Binet's formula
becomes an identity in `𝔽_p` (or `𝔽_{p²}`), so the rank of apparition is exactly the
order of the golden-ratio unit in the relevant finite field, which divides the group
order `p ∓ 1`. Why now? We already have `entry` as a first-class object with a clean
characterization (`entry_eq_iff_primitive`) and a CRT decomposition
(`entry_mul_coprime`); reducing the prime case to a finite-field order computation would
let `entry_mul_coprime` lift the bound to *all* moduli, giving a fully verified Fibonacci
order oracle.

### 2. Sharp `lcm` law for prime powers and the full multiplicative formula
Conjecture: `entry (p ^ (k+1)) ∈ {entry (p^k), p · entry (p^k)}`, and combined with
`entry_lcm` this yields a closed multiplicati
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
