
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

**Title**: Close Proofs: This cycle delivered `Catalog/Applications/StrongDivPrimitiveCriterion
**Domain**: Applications
**Mathematical framing**: Cycle 3856eb7f (Q=0.529) proved 28 theorems in Applications but left 1 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: # Future Directions — A Unified Primitive-Divisor Engine, Sixth Cycle

## Synthesis

This cycle delivered `Catalog/Applications/StrongDivPrimitiveCriterion.lean`, a **self-contained,
`sorry`-free** fi
Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Applications/StrongDivPrimitiveCriterion.lean
import Mathlib
import Catalog.Applications.StrongDivisibilitySequences

/-! # The strong primitive-divisor criterion: the rank of apparition

Domain: Number Theory / Applications.

This file **extends** `Catalog/Applications/StrongDivisibilitySequences.lean` (the abstract
strong-divisibility-sequence theory `StrongDivSeq.IsStrongDivSeq`, with its primitivity and
simultaneous-apparition results) by introducing the **rank of apparition**

  `rank u p := sInf {k | 0 < k ∧ p ∣ u k}`,

the least positive index at which `p` appears in the sequence `u`.  Where the parent file's
results (`StrongDivSeq.dvd_iff_index_dvd_of_primitive`, `StrongDivSeq.simultaneous_apparition`)
require the caller to *supply* a primitive index, here we **manufacture** that index canonically
from `p` alone and turn the whole theory into a self-contained *criterion* phrased purely in
terms of `rank`.  This unifies the Fibonacci entry-point theory
(`Catalog/Applications/FibonacciEntryPoints.lean`) and the Mersenne/`aⁿ−1` family under one
definition.

Main results (for an arbitrary strong divisibility sequence `u`):

* `rank_primitive`        — `p` is a primitive divisor of `u (rank u p)` whenever it appears at
  all; i.e. the rank is always a primitive index.  (Cf. `StrongDivSeq.IsPrimitive`.)
* `dvd_iff_rank_dvd`      — the **strong primitive-divisor criterion**: `p ∣ u m ↔ rank u p ∣ m`.
  Builds on `StrongDivSeq.dvd_iff_index_dvd_of_primitive`.
* `isPrimitive_iff_eq_rank` — `IsPrimitive u p n ↔ n = rank u p` (for `0 < n`): the rank is the
  unique primitive index, sharpening `StrongDivSeq.isPrimitive_unique`.
* `joint_dvd_iff_lcm_rank_dvd` — the **join law in ranks**: `(p ∣ u n ∧ q ∣ u n) ↔
  lcm (rank u p) (rank u q) ∣ n`, a rank-only form of `StrongDivSeq.simultaneous_apparition`.
* `fib_dvd_iff_rank_dvd` / `mersenne_dvd_iff_rank_dvd` — the criterion specialized to the
  Fibonacci and `aⁿ−1` sequences, recovering the law of apparition from one definition.
-/

namespace StrongDivSeq

open scoped Classical

/-- The **rank of apparition** of `p` in the sequence `u`: the least *positive* index `k`
with `p ∣ u k` (and `0` if `p` never appears at a positive index). -/
noncomputable def rank (u : ℕ → ℕ) (p : ℕ) : ℕ :=
  sInf {k | 0 < k ∧ p ∣ u k}

/-- `p` *appears* in `u` if it divides some `u k` at a positive index `k`. -/
def Appears (u : ℕ → ℕ) (p : ℕ) : Prop := ∃ k, 0 < k ∧ p ∣ u k

/-! ## §1. Basic properties of the rank -/

/-
!-- Lab Notebook: rank_pos / rank_mem -- !--
!-- Hypothesis: When `p` appears, its rank is a positive index at which `p` divides `u`. -- !--
!-- Result: `Nat.sInf_mem` on the nonempty appearance set gives membership; the set's
!-- defining predicate carries both `0 < rank` and `p ∣ u rank`. -- !--
!-- Insight: The rank is the canonical witness of appearance. -- !--
!-- End Lab Notebook -- !--

!-- `Nat.sInf_mem` applied to the nonempty appearance set. -- !--
-/
theorem rank_mem {u : ℕ → ℕ} {p : ℕ} (h : Appears u p) :
    0 < rank u p ∧ p ∣ u (rank u p) := by
      exact Nat.sInf_mem h

theorem rank_pos {u : ℕ → ℕ} {p : ℕ} (h : Appears u p) : 0 < rank u p :=
  (rank_mem h).1

theorem rank_dvd {u : ℕ → ℕ} {p : ℕ} (h : Appears u p) : p ∣ u (rank u p) :=
  (rank_mem h).2

/-
!-- Lab Notebook: rank_le -- !--
!-- Hypothesis: The rank is `≤` every positive index at which `p` divides `u`. -- !--
!-- Result: `Nat.sInf_le` on membership of `k` in the appearance set. -- !--
!-- Insight: Minimality of the rank, the engine behind primitivity. -- !--
!-- End Lab Notebook -- !--

!-- `Nat.sInf_le` with the witness `⟨hk, hdvd⟩`. -- !--
-/
theorem rank_le {u : ℕ → ℕ} {p k : ℕ} (hk : 0 < k) (hdvd : p ∣ u k) :
    rank u p ≤ k := by
      exact Nat.sInf_le ⟨ hk, hdvd ⟩

/-! ## §2. The rank is the unique primitive index -/

/-
!-- Lab Notebook: rank_primitive -- !--
!-- Hypothesis: `p` is a primitive divisor of `u (rank u p)`. -- !--
!-- Result: `rank_dvd` gives divisibility at the rank; `rank_le` (contrapositive) forbids
!-- divisibility at any smaller positive index, which is exactly minimality. -- !--
!-- Insight: The rank canonically produces the primitive index that the parent file's
!-- `dvd_iff_index_dvd_of_primitive` had to take as input. -- !--
!-- End Lab Notebook -- !--

!-- Combine `rank_dvd` with the contrapositive of `rank_le`. -- !--
-/
theorem rank_primitive {u : ℕ → ℕ} {p : ℕ} (h : Appears u p) :
    IsPrimitive u p (rank u p) := by
      exact ⟨ rank_dvd h, fun k hk₁ hk₂ hk₃ => not_lt_of_ge ( rank_le hk₁ hk₃ ) hk₂ ⟩

/-
!-- Lab Notebook: isPrimitive_iff_eq_rank -- !--
!-- Hypothesis: For `0 < n`, `p` is primitive at `n` iff `n` equals its rank. -- !--
!-- Result: (←) `rank_primitive`. (→) primitivity makes `p` appear, so `rank_primitive`
!-- holds, and `isPrimitive_unique` forces `n = rank u p`. -- !--
!-- Insight: Sharpens `isPrimitive_unique`: the single primitive index is computable as `rank`. -- !--
!-- End Lab Notebook -- !--

!-- (→) via `isPrimitive_unique` with `rank_primitive`; (←) is `rank_primitive` after `n = rank`. -- !--
-/
theorem isPrimitive_iff_eq_rank {u : ℕ → ℕ} {p n : ℕ} (hn : 0 < n) :
    IsPrimitive u p n ↔ n = rank u p := by
      constructor <;> intro h;
      · apply isPrimitive_unique hn (rank_pos (by
        exact ⟨ n, hn, h.1 ⟩)) h (rank_primitive (by
        exact ⟨ n, hn, h.1 ⟩));
      · rw [ h ];
        apply rank_primitive;
        contrapose! hn; simp_all +singlePass [ rank ] ;
        exact Set.eq_empty_of_forall_notMem fun k hk => hn ⟨ k, hk ⟩

/-! ## §3. The strong primitive-divisor criterion -/

/-
!-- Lab Notebook: dvd_iff_rank_dvd -- !--
!-- Hypothesis: In a strong divisibility sequence, `p ∣ u m ↔ rank u p ∣ m`. -- !--
!-- Result: `rank_primitive` provides the primitive index `rank u p`; apply
!-- `dvd_iff_index_dvd_of_primitive` from the parent file. -- !--
!-- Insight: The central apparition criterion, now phrased with no external index — the
!-- divisibility set of `p` is exactly the multiples of its rank. -- !--
!-- Failure analysis: requires `p` to appear; otherwise `rank = 0` and the equivalence fails. -- !--
!-- End Lab Notebook -- !--

!-- `dvd_iff_index_dvd_of_primitive hu (rank_pos h) (rank_primitive h) m`. -- !--
-/
theorem dvd_iff_rank_dvd {u : ℕ → ℕ} (hu : IsStrongDivSeq u) {p : ℕ}
    (h : Appears u p) (m : ℕ) : p ∣ u m ↔ rank u p ∣ m := by
      exact StrongDivSeq.dvd_iff_index_dvd_of_primitive hu (rank_pos h) (rank_primitive h) m

/-! ## §4. The join law in ranks -/

/-
!-- Lab Notebook: joint_dvd_iff_lcm_rank_dvd -- !--
!-- Hypothesis: Two appearing divisors both divide `u n` exactly at multiples of the lcm
!-- of their ranks. -- !--
!-- Result: Rewrite each conjunct via `dvd_iff_rank_dvd`, then `Nat.lcm_dvd_iff`. -- !--
!-- Insight: A rank-only form of `simultaneous_apparition`: the joint apparition set is the
!-- apparition class of `lcm (rank u p) (rank u q)`. -- !--
!-- End Lab Notebook -- !--

!-- Two applications of `dvd_iff_rank_dvd` and `Nat.lcm_dvd_iff`. -- !--
-/
theorem joint_dvd_iff_lcm_rank_dvd {u : ℕ → ℕ} (hu : IsStrongDivSeq u) {p q : ℕ}
    (hp : Appears u p) (hq : Appears u q) (n : ℕ) :
    (p ∣ u n ∧ q ∣ u n) ↔ Nat.lcm (rank u p) (rank u q) ∣ n := by
      rw [ dvd_iff_rank_dvd hu hp n, dvd_iff_rank_dvd hu hq n, Nat.lcm_dvd_iff ]

/-! ## §5. Concrete specializations -/

-- !-- Lab Notebook: fib_dvd_iff_rank_dvd -- !--
-- !-- Hypothesis: For Fibonacci, `p ∣ F_m ↔ rank Nat.fib p ∣ m`. -- !--
-- !-- Result: `dvd_iff_rank_dvd` with `fib_isStrongDivSeq`. -- !--
-- !-- Insight: Recovers the Fibonacci law of apparition from the abstract rank. -- !--
-- !-- End Lab Notebook -- !--
theorem fib_dvd_iff_rank_dvd {p : ℕ} (h : Appears Nat.fib p) (m : ℕ) :
    p ∣ Nat.fib m ↔ rank Nat.fib p ∣ m :=
  dvd_iff_rank_dvd fib_isStrongDivSeq h m

-- !-- Lab Notebook: mersenne_dvd_iff_rank_dvd -- !--
-- !-- Hypothesis: For `u n = aⁿ − 1`, `p ∣ aᵐ − 1 ↔ rank ∣ m`. -- !--
-- !-- Result: `dvd_iff_rank_dvd` with `mersenne_isStrongDivSeq`. --
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — The Rank-of-Apparition Engine, Seventh Cycle

## Synthesis

This cycle delivered `Catalog/Applications/StrongDivPrimitiveCriterion.lean`, a self-contained,
`sorry`-free upper floor on top of the abstract strong-divisibility theory in
`Catalog/Applications/StrongDivisibilitySequences.lean`. Where the parent file required the
caller to *supply* a primitive index before any apparition law could be invoked
(`StrongDivSeq.dvd_iff_index_dvd_of_primitive`, `StrongDivSeq.simultaneous_apparition`), this
cycle *manufactures* that index canonically from the divisor alone:

    rank u p := sInf {k | 0 < k ∧ p ∣ u k}.

The headline results are:

* `StrongDivSeq.rank_primitive` — the rank is always a primitive index, so the existence of a
  primitive index is never a side hypothesis again.
* `StrongDivSeq.dvd_iff_rank_dvd` — **the strong primitive-divisor criterion**:
  `p ∣ u m ↔ rank u p ∣ m`. The divisibility set of any divisor is *exactly* the multiples of
  its rank, for every strong divisibility sequence at once.
* `StrongDivSeq.isPrimitive_iff_eq_rank` — sharpens `StrongDivSeq.isPrimitive_unique`: the unique
  primitive index is *computable* as the rank.
* `StrongDivSeq.joint_dvd_iff_lcm_rank_dvd` — a rank-only join law:
  `(p ∣ u n ∧ q ∣ u n) ↔ lcm (rank u p) (rank u q) ∣ n`.
* `fib_dvd_iff_rank_dvd`, `mersenne_dvd_iff_rank_dvd` — the same criterion specialized to the
  Fibonacci sequence and the `aⁿ − 1` family, recovering both classical laws of apparition
  (Fibonacci entry points; multiplicative order) from one definition and one proof.

## Results Summary

Six new `sorry`-free theorems plus two corollary specializations, all depending only on the
standard axioms `propext`, `Classical.choice`, `Quot.sound`. The work strictly *extends* the
catalog (it imports and reuses `IsStrongDivSeq`, `IsPrimitive`, `dvd_iff_index_dvd_of_primitive`,
`isPrimitive_unique`, `fib_isStrongDivSeq`, `mersenne_isStrongDivSeq`) rather than reproving
anything, and it unifies the Fibonacci-specific apparition results with the Mersenne family.

## Research Directions

### Direction 1 — Multiplicativity of the rank over coprime divisors

Conjecture: for a strong divisibility sequence `u` and coprime appearing divisors `p`, `q`
(`Nat.Coprime p q`), the product `p * q` appears and `rank u (p*q) = lcm (rank u p) (rank u q)`.
This is the natural strengthening of `joint_dvd_iff_lcm_rank_dvd`: the join law says the *common*
apparition set is governed by the lcm of ranks; the conjecture says the rank of the *product*
divisor equals that lcm exactly. Falsifiable: a single counterexample with `p*q ∣ u n` for some
`n` not a multiple of `lcm (rank u p) (rank u q)` kills it. The key insight is that `p*q ∣ u n`
is equivalent to `p ∣ u n ∧ q ∣ u n` precisely when `p, q` are coprime, so the join law should
collapse into a rank identity. Why now? `joint_dvd_iff_lcm_rank_dvd` is already proven and
coprimality of divisors is exactly the hypothesis that turns `∧` of divisib
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
