
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

**Title**: Close Proofs: This cycle formalized the order-theoretic engine of the persistent-hom
**Domain**: Novelty
**Mathematical framing**: Cycle 132f9096 (Q=0.501) proved 364 theorems in Applications but left 8 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: # Future Directions: Persistent Homology Stability

This cycle formalized the order-theoretic engine of the persistent-homology stability
theorem in `Catalog/Computation/PersistentHomologyStability.le
Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Applications/UnifiedRankOfApparition.lean
import Mathlib

/-! # The rank-of-apparition engine for arbitrary strong divisibility sequences

Domain: Number Theory / Applications (Conceptual Unification).

The catalog contains two parallel developments of the *rank of apparition* idea:

* `Catalog/Applications/RankOfApparition.lean` builds the rank function `fibRank`, the spine
  `fibRank_dvd_iff : m ∣ F n ↔ fibRank m ∣ n`, the order-morphism law `fibRank_dvd_of_dvd`,
  the rigidity `fibRank_fib : fibRank (F k) = k`, and the Fibonacci divisibility biconditional
  `fib_dvd_fib_iff : F a ∣ F b ↔ a ∣ b` — but *only* for the Fibonacci sequence.
* `Catalog/Applications/StrongDivisibilitySequences.lean` introduces the abstract notion
  `IsStrongDivSeq u : u (gcd m n) = gcd (u m) (u n)` together with the primitivity theory
  (`isPrimitive_unique`, `dvd_iff_index_dvd_of_primitive`, `simultaneous_apparition`, …) and
  the two concrete instances `fib_isStrongDivSeq` and `mersenne_isStrongDivSeq` (`n ↦ aⁿ − 1`),
  but it never builds a *rank function* and never proves the value biconditional `u a ∣ u b ↔ a ∣ b`.

This file **unifies the two**: it lifts the entire rank machinery of `RankOfApparition` from
`Nat.fib` to an arbitrary strong divisibility sequence, proving the generic spine
`rank_dvd_iff`, the order morphism `rank_dvd_of_dvd`, the rigidity `rank_self`, and the value
biconditional `value_dvd_iff` from the single hypothesis `IsStrongDivSeq u`.  Two classical
theorems then drop out as *instances of one engine*:

* `fib_dvd_fib_iff`     — `F a ∣ F b ↔ a ∣ b` for `a ≥ 3` (recovering `RankOfApparition`);
* `mersenne_dvd_iff`    — `(aᵐ − 1) ∣ (aⁿ − 1) ↔ m ∣ n` for `a ≥ 2`, `m ≥ 1` (**new**: the
  classical Mersenne divisibility law, which the catalog stated the SDS instance for but never
  derived the index biconditional of).

This is a Grothendieck-style unification: the gcd-meet law `IsStrongDivSeq` *is* the abstract
"Pisano/order" mechanism, and Fibonacci vs. `aⁿ−1` are two specializations of one truth.
-/

namespace UnifiedRank

open scoped Classical

/-- A **strong divisibility sequence**: `u (gcd m n) = gcd (u m) (u n)` for all `m, n`.
(Same notion as `StrongDivSeq.IsStrongDivSeq`; restated here so the file is self-contained
against the catalog's fragmented import graph.) -/
def IsStrongDivSeq (u : ℕ → ℕ) : Prop :=
  ∀ m n, u (Nat.gcd m n) = Nat.gcd (u m) (u n)

/-! ## §1. The weak divisibility law -/

-- !-- Lab Notebook: IsStrongDivSeq.dvd_of_dvd -- !--
-- !-- Hypothesis: a strong divisibility sequence is a divisibility sequence: `m ∣ n → u m ∣ u n`. -- !--
-- !-- Result: `m ∣ n` gives `gcd m n = m`, so `u m = u (gcd m n) = gcd (u m) (u n) ∣ u n`. -- !--
-- !-- Insight: the weak law is a free corollary of the strong (meet) law. -- !--
-- !-- Failure analysis: none. -- !--
-- !-- End Lab Notebook -- !--
theorem IsStrongDivSeq.dvd_of_dvd {u : ℕ → ℕ} (hu : IsStrongDivSeq u) {m n : ℕ}
    (h : m ∣ n) : u m ∣ u n := by
  have hg : Nat.gcd m n = m := Nat.gcd_eq_left h
  have hmn := hu m n
  rw [hg] at hmn
  rw [hmn]
  exact Nat.gcd_dvd_right _ _

/-! ## §2. The rank function -/

/-- `m` *has a rank of apparition* for `u` if it divides some positive-index value `u k`. -/
def HasRank (u : ℕ → ℕ) (m : ℕ) : Prop := ∃ k, 0 < k ∧ m ∣ u k

/-- The rank of apparition of `m` in `u`: the least positive `k` with `m ∣ u k`
(or `0` if none exists). -/
noncomputable def rank (u : ℕ → ℕ) (m : ℕ) : ℕ :=
  if h : ∃ k, 0 < k ∧ m ∣ u k then Nat.find h else 0

theorem rank_pos {u : ℕ → ℕ} {m : ℕ} (hm : HasRank u m) : 0 < rank u m := by
  unfold rank; split_ifs with h
  · exact (Nat.find_spec h).1
  · exact absurd hm h

theorem dvd_rank {u : ℕ → ℕ} {m : ℕ} (hm : HasRank u m) : m ∣ u (rank u m) := by
  unfold rank; split_ifs with h
  · exact (Nat.find_spec h).2
  · exact absurd hm h

theorem rank_min {u : ℕ → ℕ} {m k : ℕ} (hk : 0 < k) (hlt : k < rank u m) :
    ¬ m ∣ u k := by
  unfold rank at hlt; split_ifs at hlt with h
  · exact fun hd => Nat.find_min h hlt ⟨hk, hd⟩
  · simp at hlt

/-! ## §3. The spine: `m ∣ u n ↔ rank u m ∣ n` -/

-- !-- Lab Notebook: rank_dvd_iff -- !--
-- !-- Hypothesis: for any modulus with a rank, `m ∣ u n ↔ rank u m ∣ n` (generic spine). -- !--
-- !-- Result: (←) `rank ∣ n → u(rank) ∣ u n` (weak law) plus `m ∣ u(rank)`. (→) push `m` into
-- the meet law `u (gcd (rank) n) = gcd (u rank) (u n)`; minimality of the rank forces
-- `gcd (rank) n = rank`, i.e. `rank ∣ n`. -- !--
-- !-- Insight: this generalizes `RankOfApparition.fibRank_dvd_iff` from `Nat.fib_gcd` to the
-- bare `IsStrongDivSeq` hypothesis — the load-bearing fact of all apparition threads. -- !--
-- !-- Failure analysis: needs `HasRank u m` for positivity of the rank. -- !--
-- !-- End Lab Notebook -- !--
theorem rank_dvd_iff {u : ℕ → ℕ} (hu : IsStrongDivSeq u) {m : ℕ} (hm : HasRank u m) (n : ℕ) :
    m ∣ u n ↔ rank u m ∣ n := by
  have hz : 0 < rank u m := rank_pos hm
  have hmz : m ∣ u (rank u m) := dvd_rank hm
  constructor <;> intro hn
  · contrapose! hn
    have hgcd_lt : Nat.gcd (rank u m) n < rank u m :=
      lt_of_le_of_ne (Nat.le_of_dvd hz (Nat.gcd_dvd_left _ _))
        (fun h => hn (h ▸ Nat.gcd_dvd_right _ _))
    refine fun hcontra => rank_min (Nat.gcd_pos_of_pos_left _ hz) hgcd_lt ?_
    have := Nat.dvd_gcd hmz hcontra
    rw [hu]
    exact this
  · obtain ⟨k, rfl⟩ := hn
    exact dvd_trans hmz (hu.dvd_of_dvd ⟨k, rfl⟩)

/-! ## §4. The order-morphism law (with existence) -/

-- !-- Lab Notebook: rank_dvd_of_dvd -- !--
-- !-- Hypothesis: `rank` is an order morphism of divisibility posets: `b ∣ a → rank b ∣ rank a`. -- !--
-- !-- Result: from the spine: `b ∣ a ∣ u (rank a)`, so `b ∣ u (rank a)`, and the spine for `b`
-- gives `rank b ∣ rank a`. -- !--
-- !-- Insight: monotonicity packaged with existence of the divisor's rank. -- !--
-- !-- Failure analysis: needs a totality witness `hex` so that `a, b` have ranks. -- !--
-- !-- End Lab Notebook -- !--
theorem rank_dvd_of_dvd {u : ℕ → ℕ} (hu : IsStrongDivSeq u)
    (hex : ∀ m, 0 < m → HasRank u m) {a b : ℕ} (ha : 0 < a) (hab : b ∣ a) :
    rank u b ∣ rank u a := by
  have hb : 0 < b := Nat.pos_of_dvd_of_pos hab ha
  have hrb : HasRank u b := hex b hb
  have hra : HasRank u a := hex a ha
  have hbdvd : b ∣ u (rank u a) := dvd_trans hab (dvd_rank hra)
  exact (rank_dvd_iff hu hrb (rank u a)).1 hbdvd

/-! ## §5. Rigidity: the rank pins the values exactly -/

-- !-- Lab Notebook: rank_self -- !--
-- !-- Hypothesis: if `u` is positive and strictly grows up to index `k`, then `rank u (u k) = k`. -- !--
-- !-- Result: `Nat.find_eq_iff`: `u k ∣ u k` trivially, and for `0 < j < k` we have
-- `0 < u j < u k`, so `u k ∤ u j` (`Nat.not_dvd_of_pos_of_lt`). -- !--
-- !-- Insight: the abstract version of `RankOfApparition.fibRank_fib`; growth replaces the
-- Fibonacci-specific monotonicity. -- !--
-- !-- Failure analysis: needs strict growth strictly below `k`; equal values (e.g. `F 1 = F 2`)
-- break it, which is exactly why Fibonacci needed `k ≥ 3`. -- !--
-- !-- End Lab Notebook -- !--
theorem rank_self {u : ℕ → ℕ} {k : ℕ} (hk : 0 < k)
    (hpos : ∀ j, 0 < j → 0 < u j)
    (hgrow : ∀ j, 0 < j → j < k → u j < u k) :
    rank u (u k) = k := by
  have hhas : ∃ j, 0 < j ∧ u k ∣ u j := ⟨k, hk, dvd_rfl⟩
  unfold rank
  rw [dif_pos hhas, Nat.find_eq_iff]
  refine ⟨⟨hk, dvd_rfl⟩, ?_⟩
  intro j hj hcontra
  obtain ⟨hj0, hdvd⟩ := hcontra
  exact Nat.not_dvd_of_pos_of_lt (hpos j hj0) (hgrow j hj0 hj) hdvd

/-! ## §6. The value biconditional -/

-- !-- Lab Notebook: value_dvd_iff -- !--
-- !-- Hypothesis: under positivity + growth at `a`, `u a ∣ u b ↔ a ∣ b`. -- !--
-- !-- Result: `rank u (u a) = a` (rank_self), then spine `u a ∣ u b ↔ rank u (u a) ∣ b ↔ a ∣ b`. -- !--
-- !-- Insight: the spine converts a statement about values into one about indices, upgrading
-- the weak law `dvd_of_dvd` to a biconditional in one stroke. -- !--
-- !-- Failure analysis: growth strictly below `a` is required (sharp). -- !--
-- !-- End Lab Notebook -- 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — The Rank-of-Apparition Engine

## Synthesis

This cycle unified two parallel catalog threads — the Fibonacci-only rank machinery of
`Catalog/Applications/RankOfApparition.lean` and the abstract `IsStrongDivSeq` framework of
`Catalog/Applications/StrongDivisibilitySequences.lean` — into a single generic engine in
`Catalog/Applications/UnifiedRankOfApparition.lean`. From the bare meet law
`u (gcd m n) = gcd (u m) (u n)` we derived, for an *arbitrary* strong divisibility sequence,
the spine `rank_dvd_iff : m ∣ u n ↔ rank u m ∣ n`, the order-morphism law `rank_dvd_of_dvd`,
the rigidity `rank_self : rank u (u k) = k`, and the value biconditional
`value_dvd_iff : u a ∣ u b ↔ a ∣ b`. Two classical theorems then fell out as instances of one
truth: the Fibonacci law `fib_dvd_fib_iff` (`F a ∣ F b ↔ a ∣ b`, `a ≥ 3`) and — newly derived —
the Mersenne law `mersenne_dvd_iff` (`aᵐ − 1 ∣ aⁿ − 1 ↔ m ∣ n`, `a ≥ 2`, `m ≥ 1`).

## Results Summary

- `rank_dvd_iff` — generic spine, no primitivity hypothesis (generalizes `fibRank_dvd_iff`).
- `rank_dvd_of_dvd` — `rank` is a morphism of divisibility posets.
- `rank_self` / `value_dvd_iff` — rigidity and the index biconditional from positivity + growth.
- `fib_dvd_fib_iff`, `mersenne_dvd_iff` — two classical divisibility laws as one engine's instances.
- All four headline theorems verified with axioms `[propext, Classical.choice, Quot.sound]`, `sorry = 0`.

## Research Directions

### 1. A generic primitive-divisor existence theorem (Zsygmondy through one engine)
Conjecture: for any strong divisibility sequence `u` that is *eventually super-linearly growing*
(`∀ d ≥ 1, ∃ N, ∀ n ≥ N, u n > u d · (number of proper divisors of n)`), every `u n` with `n`
large has a primitive divisor, i.e. `IsPrimitive p n` for some prime `p`. Falsifiable: a single
SDS with unbounded growth but a primitive-divisor gap at some large `n` would refute it.
**The key insight is** that `value_dvd_iff` already pins every non-primitive contribution to
`u d` for proper divisors `d ∣ n`, so a counting bound `u n > ∏_{d∣n, d<n} u d` mechanically
forces a leftover primitive factor — primitivity becomes a growth inequality, not a new idea.
**Why now?** The engine supplies the exact divisibility bookkeeping (the spine + rigidity) that
Zsygmondy-style arguments hand-wave; only the arithmetic growth estimate remains to be formalized.

### 2. Closing the Carmichael composite tail via the engine
Conjecture: the `sorry` in `Catalog/Shared/CarmichaelProof.lean` (composite `n > 10000`) is
discharged by instantiating Direction 1 to `Nat.fib`, since `F n` grows like `φⁿ` while the
product of `F d` over proper divisors `d ∣ n` grows like `φ^{n/2 + o(n)}`. Falsifiable: exhibit a
composite `n` where `primPart n = 1` despite `n > 10000` (none should exist).
**The key insight is** that the catalog's `primPart` is literally the leftover after stripping all
`F d` for proper divisors `d`, so a clean lower bound `primPart n ≥ φ^{n/2}/poly > 1` is ex
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
