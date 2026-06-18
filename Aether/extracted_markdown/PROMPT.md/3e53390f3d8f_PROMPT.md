
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

**Title**: Close Proofs: The catalog's `Bridges/CategoricalTropicalUltrametric.lean` built an *
**Domain**: Applications
**Mathematical framing**: Cycle 415b1517 (Q=0.507) proved 224 theorems in Novelty but left 5 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: # Future Directions — Arithmetic Heights as Tropical Valuations Inducing Ultrametric Lipschitz Bounds

## Synthesis

The catalog's `Bridges/CategoricalTropicalUltrametric.lean` built an *abstract* fun
Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Bridges/FibonacciApparitionDuality.lean
import Mathlib
import Bridges.TropicalUltrametricBridge

/-!
# The Fibonacci Law of Apparition as an Arithmetic–Height / Tropical Duality

This file proves the **law of apparition** for the Fibonacci sequence in full
generality (for every modulus `m ≥ 1`, not only primes), and then *bridges* it to
the catalog's tropical/ultrametric arithmetic-height machinery in
`Bridges/TropicalUltrametricBridge.lean`.

The **rank of apparition** of `m`,
`fibRank m = least k > 0 with m ∣ fib k`, is shown to exist for every `m ≥ 1`
(`fib_apparition_exists`).  The headline representation theorem

  `fib_dvd_iff_rank_dvd : m ∣ fib n ↔ fibRank m ∣ n`

is a genuine *duality*: divisibility of Fibonacci **values** is translated, without
loss, into divisibility of the **indices**.  This is the index-side dual of the
strong-divisibility identity `Nat.fib_gcd : fib (gcd m n) = gcd (fib m) (fib n)`.

As corollaries the divisibility predicate becomes a **lattice (min-plus)
homomorphism** (`fib_dvd_gcd_iff`: `gcd` of indices ↦ conjunction), and — closing
the loop with the catalog — the `p`-adic **arithmetic height**
`TropUltra.padicHeightNorm` of `fib n` drops below `1` *exactly* on the rank
sublattice (`fibHeight_lt_one_iff`, with the Mathlib-native restatement
`padicNorm_fib_lt_one_iff`).  This realises the theme "arithmetic heights as
tropical valuations" concretely on the Fibonacci sequence.

## Synthesis with the catalog
* Builds on `Nat.fib_gcd` and `Nat.fib_dvd` (the priority `Fib_gcd_identity`).
* Builds on `TropUltra.padicHeightNorm` / `TropUltra.NonArchNorm` from
  `Bridges/TropicalUltrametricBridge.lean`: the abstract ultrametric arithmetic
  height is fed the concrete Fibonacci inputs, so that `fibRank` becomes the exact
  combinatorial controller of the non-archimedean size of Fibonacci numbers.
-/

-- !-- Lab Notebook -- !--
-- Hypothesis:  The strong-divisibility identity `fib (gcd m n) = gcd (fib m) (fib n)`
--   should "linearise" Fibonacci divisibility: there ought to be a single index
--   `fibRank m` (the rank of apparition) such that `m ∣ fib n ↔ fibRank m ∣ n`,
--   turning a question about values into a question about indices (a duality), and
--   turning the index `gcd` (a tropical `min`) into logical conjunction.
-- Result:  Confirmed in full generality for every `m ≥ 1`.
--   `fib_apparition_exists` (rank exists, via pure periodicity of the state pair
--   `(fib n, fib (n+1))` over `ZMod m`), `fib_dvd_iff_rank_dvd` (the duality),
--   `fib_dvd_gcd_iff` (the min-plus homomorphism) and the height capstones
--   `padicNorm_fib_lt_one_iff` / `fibHeight_lt_one_iff` are all proven `sorry`-free.
-- Insight:  Existence of the rank is *purely* the statement that the transition
--   `T(a,b) = (b, a+b)` is a bijection of the finite set `ZMod m × ZMod m`; a finite
--   bijection has every orbit purely periodic, so the orbit of the start state
--   `(0,1)` returns to `(0,1)`, i.e. some positive `fib d ≡ 0`.  No analysis, no
--   Binet — only injectivity of an affine shift (here packaged as the cancellation
--   `add_right_cancel` inside `fibState_descent`).  The whole theory of apparition
--   is then `Nat.fib_gcd` + minimality of `sInf`.
-- Failure analysis:  Defining `fibRank` via `Nat.find` forces carrying the existence
--   proof as a definitional argument, which pollutes every downstream statement; the
--   `noncomputable sInf {k | 0 < k ∧ m ∣ fib k}` packaging keeps the definition
--   hypothesis-free and recovers membership/minimality from `Nat.sInf_mem` /
--   `Nat.sInf_le`.  Also: the `m = 0` case genuinely has no rank (`0 ∣ fib k ↔ k = 0`),
--   so every theorem is correctly guarded by `0 < m`; the prime capstone gets `0 < p`
--   for free from `Nat.Prime.pos`.
-- !-- Lab Notebook -- !--

open Nat

namespace FibApparition

/-! ## §1. Existence of the rank of apparition via pure periodicity -/

/-- The Fibonacci "state pair" `(fib n, fib (n+1))` taken modulo `m`. -/
def fibState (m : ℕ) (n : ℕ) : ZMod m × ZMod m :=
  ((Nat.fib n : ZMod m), (Nat.fib (n + 1) : ZMod m))

-- !-- Unfold `fib (n+2) = fib n + fib (n+1)` and push the casts. -- !--
lemma fibState_succ (m n : ℕ) :
    fibState m (n + 1) = ((fibState m n).2, (fibState m n).1 + (fibState m n).2) := by
  simp only [fibState, Nat.fib_add_two]; push_cast; ring_nf

-- !-- `fib 0 = 0`, `fib 1 = 1`. -- !--
lemma fibState_zero (m : ℕ) : fibState m 0 = (0, 1) := by
  simp [fibState]

-- !-- The shift `T(a,b)=(b,a+b)` is injective, so equality of states at `i` and `i+d`
--     descends (by induction on `i`, using `add_right_cancel`) to equality at `0` and `d`. -- !--
lemma fibState_descent (m : ℕ) :
    ∀ (d i : ℕ), fibState m i = fibState m (i + d) → fibState m 0 = fibState m d := by
  intro d i
  induction i with
  | zero => intro h; simpa using h
  | succ i ih =>
    intro h
    apply ih
    have h' : fibState m (i + 1) = fibState m (i + d + 1) := by
      have : i + 1 + d = i + d + 1 := by omega
      rwa [this] at h
    rw [fibState_succ, fibState_succ] at h'
    have h2 := Prod.ext_iff.mp h'
    have hsnd : (fibState m i).2 = (fibState m (i + d)).2 := h2.1
    have hsum : (fibState m i).1 + (fibState m i).2
        = (fibState m (i + d)).1 + (fibState m (i + d)).2 := h2.2
    have hfst : (fibState m i).1 = (fibState m (i + d)).1 := by
      have := hsum; rw [hsnd] at this; exact add_right_cancel this
    exact Prod.ext hfst hsnd

/-- **The rank of apparition exists.** Every modulus `m ≥ 1` divides some positive
Fibonacci number.  Proof: the finite-state pure periodicity above forces the orbit
of `(0,1)` to return to `(0,1)`. -/
-- !-- Pigeonhole on `fibState m : ℕ → ZMod m × ZMod m` (finite codomain) gives a
--     repeat `i ≠ j`; the descent lemma sends it to `(0,1) = fibState m d` with
--     `d > 0`, whose first coordinate `fib d ≡ 0 [m]` gives `m ∣ fib d`. -- !--
lemma fib_apparition_exists (m : ℕ) (hm : 0 < m) : ∃ k, 0 < k ∧ m ∣ Nat.fib k := by
  haveI : NeZero m := ⟨hm.ne'⟩
  obtain ⟨i, j, hij, hfe⟩ := Finite.exists_ne_map_eq_of_infinite (fibState m)
  wlog hlt : i < j generalizing i j
  · exact this j i (Ne.symm hij) hfe.symm (by omega)
  · set d := j - i with hd
    have hjd : j = i + d := by omega
    have hdpos : 0 < d := by omega
    rw [hjd] at hfe
    have hdesc := fibState_descent m d i hfe
    rw [fibState_zero] at hdesc
    have hfirst : (0 : ZMod m) = (Nat.fib d : ZMod m) := by
      have := congrArg Prod.fst hdesc
      simpa [fibState] using this
    refine ⟨d, hdpos, ?_⟩
    rw [← ZMod.natCast_eq_zero_iff]
    exact hfirst.symm

/-! ## §2. The rank of apparition and the representation (duality) theorem -/

/-- The **rank of apparition** of `m`: the least positive index `k` with `m ∣ fib k`. -/
noncomputable def fibRank (m : ℕ) : ℕ := sInf {k | 0 < k ∧ m ∣ Nat.fib k}

-- !-- `Nat.sInf_mem` applied to the nonempty witness set from `fib_apparition_exists`. -- !--
lemma fibRank_spec (m : ℕ) (hm : 0 < m) : 0 < fibRank m ∧ m ∣ Nat.fib (fibRank m) :=
  Nat.sInf_mem (fib_apparition_exists m hm)

lemma fibRank_pos (m : ℕ) (hm : 0 < m) : 0 < fibRank m := (fibRank_spec m hm).1

lemma fibRank_dvd_fib (m : ℕ) (hm : 0 < m) : m ∣ Nat.fib (fibRank m) := (fibRank_spec m hm).2

-- !-- Minimality of `sInf` (`Nat.sInf_le`). -- !--
lemma fibRank_le (m : ℕ) {k : ℕ} (hk : 0 < k) (hd : m ∣ Nat.fib k) : fibRank m ≤ k :=
  Nat.sInf_le ⟨hk, hd⟩

/-- **Headline theorem: the Fibonacci law of apparition.**
`m` divides the `n`-th Fibonacci value iff the rank of apparition of `m` divides the
index `n`.  Divisibility of *values* is dual to divisibility of *indices*. -/
-- !-- (⇐) `fibRank m ∣ n ⇒ fib (fibRank m) ∣ fib n` (`Nat.fib_dvd`) and `m ∣ fib (fibRank m)`.
--     (⇒) `m ∣ fib n` and `m ∣ fib (fibRank m)` give `m ∣ fib (gcd (fibRank m) n)`
--     (`Nat.fib_gcd`); minimality forces `gcd (fibRank m) n = fibRank m`, i.e. `fibRank m ∣ n`. -- !--
theorem fib_dvd_iff_rank_dvd (m : ℕ) (hm : 0 < m) (n : ℕ) :
    m ∣ Nat.fib n ↔ fibRank m ∣ n := by
  construc
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — The Fibonacci Law of Apparition as an Arithmetic-Height / Tropical Duality

## Synthesis

This cycle closed a concrete gap between two halves of the catalog that had only
been linked *abstractly*: the tropical/ultrametric arithmetic-height machinery of
`Bridges/TropicalUltrametricBridge.lean` (the `NonArchNorm` structure and the
`padicHeightNorm`/`padicTropicalValuation` realisation of `p`-adic height as a
tropical valuation), and the strong-divisibility identity `Nat.fib_gcd` that powers
the catalog's Carmichael/Fibonacci work.

The bridge is the **rank of apparition**. In `Bridges/FibonacciApparitionDuality.lean`
we prove, for every modulus `m ≥ 1`, that there is a least positive index
`fibRank m` with `m ∣ fib (fibRank m)` (`fib_apparition_exists`), and the headline
*representation/duality theorem*

```
fib_dvd_iff_rank_dvd :  m ∣ fib n  ↔  fibRank m ∣ n .
```

Divisibility of Fibonacci **values** is translated, with no loss, into divisibility
of **indices** — the index-side dual of `fib (gcd m n) = gcd (fib m) (fib n)`. Two
consequences make the duality quantitative: the divisibility predicate is a
**min-plus (lattice) homomorphism** (`fib_dvd_gcd_iff`, sending the index `gcd` — a
tropical `min` — to logical conjunction), and the catalog's `p`-adic arithmetic
height of `fib n` drops below `1` *exactly* on the rank sublattice
(`fibHeight_lt_one_iff` / `padicNorm_fib_lt_one_iff`). In one sentence: the
non-archimedean size of a Fibonacci number is governed precisely by the
combinatorial object `fibRank p`.

The pleasant surprise is how little is needed. Existence of the rank reduces to the
single fact that the affine shift `T(a,b) = (b, a+b)` is a *bijection* of the finite
set `ZMod m × ZMod m`; a finite bijection has purely periodic orbits, so the orbit
of `(0,1)` returns to `(0,1)`. No Binet formula, no analysis — only injectivity,
packaged as `add_right_cancel`.

## Results summary

All statements below are proven `sorry`-free, depending only on
`propext`, `Classical.choice`, `Quot.sound`.

* `FibApparition.fib_apparition_exists` — every `m ≥ 1` divides some positive `fib k`
  (pure periodicity of the Fibonacci state pair mod `m`).
* `FibApparition.fib_dvd_iff_rank_dvd` — **the law of apparition** (value/index duality).
* `FibApparition.fib_dvd_gcd_iff` — divisibility is a `gcd → ∧` (min-plus) homomorphism.
* `FibApparition.padicNorm_fib_lt_one_iff` — Mathlib-native height capstone.
* `FibApparition.fibHeight_lt_one_iff` — catalog capstone: `TropUltra.padicHeightNorm`
  of `fib n` is `< 1` iff `fibRank p ∣ n`.

## Research directions

### 1. Primitivity is rank equality — and it re-frames the open Carmichael tail.

The catalog's `Shared/CarmichaelProof.lean` still leaves the *infinite tail*
(composite `n > 10000`) of the Fibonacci primitive-divisor theorem open. The
apparition theorem turns the very definition of "primitive divisor" into a clean
statement about the rank: a prime `p` is a primitive prime divisor of `fib n
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
