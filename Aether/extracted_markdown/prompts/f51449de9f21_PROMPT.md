
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

**Title**: Close Proofs: This cycle hardened the foundation the previous cycle was *resting on 
**Domain**: Applications
**Mathematical framing**: Cycle c2f078e3 (Q=0.409) proved 9 theorems in Applications but left 2 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: # Future Directions — Closing the Equivalence Calculus and the Universality of Interchange

## Synthesis

This cycle hardened the foundation the previous cycle was *resting on but had not
actually com
Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Applications/FibonacciDivisibilityCalculus.lean
/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The Fibonacci Divisibility Calculus

This file develops the *divisibility calculus* of the Fibonacci sequence: the
precise dictionary translating the additive/gcd structure of the **indices** into
the multiplicative/divisibility structure of the **values** `F(n)`.

The cornerstone is Mathlib's `Nat.fib_gcd`, which states that `F` is a *strong
divisibility sequence*:

    F(gcd m n) = gcd (F m) (F n).

From this single identity we extract the full calculus:

* `fib_gcd_identity`        — the strong-divisibility law, restated.
* `fib_coprime_of_coprime`  — coprime indices give coprime values.
* `fib_dvd_iff`             — the divisibility *characterization*
                              `F m ∣ F n ↔ m ∣ n` (for `m ≥ 3`), the converse to
                              `Nat.fib_dvd`.
* `prime_dvd_fib_gcd`       — the "rank of apparition" descent lemma underlying
                              Carmichael's primitive-divisor theorem.

## Catalog synthesis

This file is the *foundation* the Carmichael primitive-divisor development rests
on.  `prime_dvd_fib_gcd` is exactly the descent step used (under the names
`fib_prime_dvd_gcd'` / `fib_dvd_gcd_of_dvd`) in
`Catalog/Speculative/CarmichaelPrimitiveDivisor.lean` and
`Catalog/Speculative/AutoResearch/CarmichaelComposite.lean`; here it is proved
once, cleanly, as a consequence of `fib_gcd_identity`.  The sharp
characterization `fib_dvd_iff` is the missing converse to `Nat.fib_dvd` and is
the index-level analogue of the entry-point (rank of apparition) theory used
throughout the `FibonacciEntryPoints` catalog files.
-/

import Mathlib

namespace FibonacciDivisibilityCalculus

open Nat

-- !-- Lab Notebook --!--
-- Hypothesis: Fibonacci is a *strong divisibility sequence*, so the entire
--   divisibility lattice of {F(n)} should be a faithful image of the divisibility
--   lattice of ℕ, with the *only* defect coming from the degenerate equality
--   F(1) = F(2) = 1.  We test whether `F m ∣ F n ↔ m ∣ n` holds once we step past
--   that defect (m ≥ 3).
-- Result: Confirmed and proved sorry-free.  The four theorems below give the
--   complete dictionary.  The forward direction of `fib_dvd_iff` is where the
--   strong-divisibility identity does the real work: `F m ∣ F n` forces
--   `gcd(F m, F n) = F m`, hence `F (gcd m n) = F m`, and strict monotonicity of
--   `F` on `[2, ∞)` upgrades this to `gcd m n = m`, i.e. `m ∣ n`.
-- Insight: The hypothesis `m ≥ 3` is exactly sharp: at `m = 1, 2` we have
--   `F m = 1`, which divides every `F n`, so the right-hand side `m ∣ n` would be
--   false in general (e.g. `m = 2`, `n` odd).  The defect of the calculus is a
--   single value, and `m ≥ 3` is the minimal hypothesis erasing it.
-- Failure analysis: A first attempt routed the converse through Pisano
--   periods / entry points directly; this is unnecessary — routing everything
--   through `Nat.fib_gcd` plus `Nat.fib_strictMonoOn` is shorter and avoids any
--   appeal to modular periodicity.
-- !-- Lab Notebook --!--

-- !-- The strong-divisibility law `F(gcd m n) = gcd(F m, F n)`: this is Mathlib's
--     `Nat.fib_gcd`, restated as the foundation of the whole calculus. --!--
theorem fib_gcd_identity (m n : ℕ) :
    Nat.fib (Nat.gcd m n) = Nat.gcd (Nat.fib m) (Nat.fib n) := by
  convert Nat.fib_gcd m n using 1

-- !-- Coprime indices yield coprime Fibonacci values: specialise
--     `fib_gcd_identity` at `gcd m n = 1` and use `F 1 = 1`. --!--
theorem fib_coprime_of_coprime (m n : ℕ) (h : Nat.Coprime m n) :
    Nat.Coprime (Nat.fib m) (Nat.fib n) :=
  (fib_gcd_identity m n).symm.trans (by simp [h])

-- !-- The divisibility characterization (converse to `Nat.fib_dvd`). `(←)` is
--     `Nat.fib_dvd`; `(→)` uses `fib_gcd_identity` to get `F (gcd m n) = F m`,
--     then injectivity of `Nat.fib_strictMonoOn` on `[2,∞)` gives `gcd m n = m`,
--     i.e. `m ∣ n`. --!--
theorem fib_dvd_iff (m n : ℕ) (hm : 3 ≤ m) :
    Nat.fib m ∣ Nat.fib n ↔ m ∣ n := by
  constructor
  · intro h_div
    have h_gcd : Nat.fib (Nat.gcd m n) = Nat.fib m := by
      rw [fib_gcd_identity, Nat.gcd_eq_left h_div]
    have h_gcd_ge_2 : 2 ≤ Nat.gcd m n := by
      contrapose! h_gcd
      interval_cases _ : Nat.gcd m n <;> simp_all +decide
      linarith [Nat.le_fib_add_one m]
    have h_gcd_eq_m : Nat.gcd m n = m :=
      Nat.fib_strictMonoOn.injOn h_gcd_ge_2 (show 2 ≤ m by linarith) h_gcd
    exact h_gcd_eq_m ▸ Nat.gcd_dvd_right _ _
  · exact Nat.fib_dvd m n

-- !-- The rank-of-apparition descent step: a common Fibonacci divisor of two
--     indices already divides the Fibonacci of their gcd.  Rewrite by
--     `fib_gcd_identity` and apply `Nat.dvd_gcd`. --!--
theorem prime_dvd_fib_gcd (p m n : ℕ) (hm : p ∣ Nat.fib m) (hn : p ∣ Nat.fib n) :
    p ∣ Nat.fib (Nat.gcd m n) := by
  rw [fib_gcd_identity]
  exact Nat.dvd_gcd hm hn

end FibonacciDivisibilityCalculus



-- NEW_FILE: Catalog/MachineLearning/SmallCases.lean
/-
# Frankl's Conjecture: Small Universe and Small Family Cases

This file proves Frankl's conjecture for:
- Families over universes of size ≤ 3
- Families with few members

The standard formulation requires the family to contain at least one
nonempty set (otherwise {∅} is a trivial counterexample).
-/
import Mathlib
import Speculative.Frankl.Defs

open Finset

/-! ## Helper: Frankl for families where every set contains a fixed element -/

/-
If every set in a nonempty family contains element x, then x is abundant.
-/
theorem frankl_of_all_contain {α : Type*} [DecidableEq α]
    (F : Finset (Finset α)) (x : α)
    (hne : F.Nonempty)
    (h : ∀ s ∈ F, x ∈ s) :
    FranklProperty F := by
  exact ⟨ x, by rw [ abundance_eq_sum ] ; rw [ Finset.sum_congr rfl fun s hs => if_pos ( h s hs ) ] ; simp +decide [ hne ] ⟩

/-! ## Frankl's conjecture for Fin n, n ≤ 3

Note: We include the hypothesis that the family contains a nonempty member,
since {∅} is a trivial counterexample to the unguarded statement. -/

/-
Frankl's conjecture for families over Fin 1 containing a nonempty member.
-/
theorem frankl_fin_one
    (F : Finset (Finset (Fin 1)))
    (hUC : UnionClosed F)
    (hne : F.Nonempty)
    (hnonempty : ∃ s ∈ F, s.Nonempty) :
    FranklProperty F := by
  fin_cases F <;> simp_all +decide;
  · exact ⟨ 0, by simp +decide [ abundance ] ⟩;
  · exists 0

/-
Frankl's conjecture for families over Fin 2 containing a nonempty member.
-/
theorem frankl_fin_two
    (F : Finset (Finset (Fin 2)))
    (hUC : UnionClosed F)
    (hne : F.Nonempty)
    (hnonempty : ∃ s ∈ F, s.Nonempty) :
    FranklProperty F := by
  -- By examining all possible nonempty union-closed families over Fin 2, we can verify that each one satisfies the Frankl property.
  have h_cases : ∀ (F : Finset (Finset (Fin 2))), F.Nonempty → (∃ s ∈ F, s.Nonempty) → (∀ A ∈ F, ∀ B ∈ F, A ∪ B ∈ F) → ∃ x : Fin 2, 2 * (F.filter (x ∈ ·)).card ≥ F.card := by
    native_decide +revert;
  convert h_cases F hne hnonempty hUC

/-
Frankl's conjecture for families over Fin 3 containing a nonempty member.
-/
theorem frankl_fin_three
    (F : Finset (Finset (Fin 3)))
    (hUC : UnionClosed F)
    (hne : F.Nonempty)
    (hnonempty : ∃ s ∈ F, s.Nonempty) :
    FranklProperty F := by
  -- By examining all possible families over Fin 3, we can verify that each one satisfies Frankl's property.
  have h_all_families : ∀ F : Finset (Finset (Fin 3)), F.Nonempty → (∃ s ∈ F, s.Nonempty) → (∀ s ∈ F, ∀ t ∈ F, s ∪ t ∈ F) → ∃ v : Fin 3, 2 * (Finset.filter (fun s => v ∈ s) F).card ≥ F.card := by
    native_decide;
  exact h_all_families F hne hnonempty fun s hs t ht => hUC hs ht

/-! ## Transport to arbitrary small universes -/

/-
Frankl's conjecture for any universe of cardinality ≤ 3.
-/
theorem frankl_universe_card_le_three
    {α : Type*} [Fintype α] [DecidableEq α]
    (hα : Fintype.card α ≤ 3)
    (F : Finset (Finset α))
    (hUC : UnionClosed F)
    (hne : F.Nonempty)
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Closing the Fibonacci Divisibility Calculus and the Road to Carmichael

## Synthesis

This cycle hardened the foundation that the Carmichael primitive-divisor
development was *resting on but had not actually isolated*. The previous
Carmichael files (`Catalog/Speculative/CarmichaelPrimitiveDivisor.lean`,
`Catalog/Speculative/AutoResearch/CarmichaelComposite.lean`,
`Catalog/Shared/CarmichaelProof.lean`) repeatedly re-derive the same descent
step — "if `p ∣ F(m)` and `p ∣ F(n)` then `p ∣ F(gcd m n)`" — inline, from
`Nat.fib_gcd`, each time. We extracted this once and cleanly, and went further:
we proved the **sharp divisibility characterization** `F m ∣ F n ↔ m ∣ n`
(`m ≥ 3`), the exact converse to Mathlib's `Nat.fib_dvd`, which to our knowledge
is *not* in Mathlib. The new file
`Catalog/Applications/FibonacciDivisibilityCalculus.lean` is therefore both a
de-duplication and a genuine strengthening.

The strategic picture: the Fibonacci sequence is a *strong divisibility
sequence* (SDS). Every SDS over `ℕ` carries a "calculus" turning index gcd into
value gcd. The interesting frontier is how far this calculus determines, and is
determined by, the **rank-of-apparition** (entry-point) function, and whether
the *primitive-divisor* phenomenon (Carmichael) is a formal consequence of SDS
axioms plus a single growth inequality.

## Results Summary

Proven sorry-free this cycle (axioms: `propext`, `Classical.choice`,
`Quot.sound`):

1. `fib_gcd_identity` — `F(gcd m n) = gcd(F m, F n)` (the SDS law, restated).
2. `fib_coprime_of_coprime` — coprime indices ⇒ coprime Fibonacci values.
3. `fib_dvd_iff` — `F m ∣ F n ↔ m ∣ n` for `m ≥ 3` (the missing converse to
   `Nat.fib_dvd`; hypothesis `m ≥ 3` shown to be exactly sharp).
4. `prime_dvd_fib_gcd` — the rank-of-apparition descent step, isolated once.

## Research Directions

### 1. The entry-point function is a divisor-respecting "logarithm" of the SDS.

Define `α(p)` = the rank of apparition of a prime `p` (least `k > 0` with
`p ∣ F(k)`). Conjecture: for every prime `p ≠ 5`, `p ∣ F(n) ↔ α(p) ∣ n`, and
moreover `α` is the *unique* function `ℕ → ℕ` with `α(p) ∣ n ↔ p ∣ F(n)` for all
`n`. This makes `α` a literal logarithm: it linearizes the multiplicative
divisor lattice of `{F(n)}` into the additive divisibility lattice of `ℕ`.
**The key insight is** that `fib_dvd_iff` already gives the index-level skeleton
(`F m ∣ F n ↔ m ∣ n`), so the prime-level statement is its "atomization" — one
only needs that `α(p)` is well defined and minimal, which `prime_dvd_fib_gcd`
supplies via descent to the gcd. **Why now?** Both load-bearing lemmas were just
proved in this cycle; the remaining step is a clean minimization argument with no
appeal to Pisano periods, which is exactly the kind of self-contained target the
prover handles well. *Falsifiable:* the prime `5` (with `α(5) = 5` and `25 ∣
F(25)` but the lifting-the-exponent behaviour) is the stress test — if the clean
`↔` fails anywhere, it fails at `p =
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
