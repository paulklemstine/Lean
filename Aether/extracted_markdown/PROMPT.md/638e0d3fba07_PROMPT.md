
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

**Title**: Close Proofs: This cycle laid the missing foundation for the "proof phase transition
**Domain**: Applications
**Mathematical framing**: Cycle bdd5cb68 (Q=0.765) proved 727 theorems in Novelty but left 2 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: # Future Directions: Proof Phase Transitions in Random Implicational Theories

## Synthesis

This cycle laid the missing foundation for the "proof phase transition" program. The
concept brief referenc
Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Speculative/AutoResearch/EntryPointMultiplicativity.lean
import Mathlib

/-!
# Multiplicativity of the rank of apparition in strong divisibility sequences

Domain: Number Theory (Applications / cross-domain).

This file **extends** the catalog's strong-divisibility-sequence program — namely
`Catalog/Applications/StrongDivisibilitySequences.lean` (`StrongDivSeq.IsStrongDivSeq`,
the meet law `dvd_gcd_index_iff`, the rigidity result `isPrimitive_unique`) and
`Catalog/Novelty/FibonacciEntryPointInvariant.lean` (`StrongDivSeq.entry`,
`entry_dvd`, `primitive_divisor_inj`).  Those files established the *gcd-side* of the
entry-point ("rank of apparition") lattice morphism and proved a fixed modulus is a
primitive divisor of at most one index.

The two facts that were **only available for the Fibonacci sequence** in the catalog
(via the — currently missing — `FibonacciApparition` module: the law of apparition
`fib_dvd_iff_fibEntry_dvd` and the coprime multiplicativity `fibEntry_mul_coprime`) are
here proved **abstractly**, for an arbitrary strong divisibility sequence, depending on
nothing but the renormalization identity `gcd (u m) (u n) = u (gcd m n)` and the boundary
value `u 0 = 0`.  This is a genuine generalization and a self-contained replacement for the
broken Fibonacci-specific chain.

## Main results

* `RankOfApparition.dvd_iff_entry_dvd` — **the abstract law of apparition**: for a modulus
  `m` that appears, `m ∣ u k ↔ entry u m ∣ k` for *every* `k` (the bridge that turns a
  divisibility question about terms into an arithmetic question about indices).
* `RankOfApparition.entry_eq_of_dvd_iff` — **rigidity**: the entry point is the unique
  positive number whose multiples are exactly the indices of appearance.
* `RankOfApparition.entry_dvd_entry_of_dvd` — **lattice morphism (order side)**: `d ∣ m`
  implies `entry u d ∣ entry u m`; the entry map is monotone for divisibility on moduli.
* `RankOfApparition.entry_mul_coprime` — **the join law / multiplicativity**: for coprime
  moduli `a, b` that appear, `entry u (a*b) = lcm (entry u a) (entry u b)`.  This is the
  dual of the catalog's `gcd ↦ gcd` half and reduces all entry-point computation to the
  prime-power case.

## Concrete instantiations (cross-domain)

* `RankOfApparition.mersenne_entry_mul_coprime` — for the Mersenne/repunit family
  `u n = a^n - 1` (a strong divisibility sequence by `Nat.pow_sub_one_gcd_pow_sub_one`),
  the rank of apparition is multiplicative on coprime moduli.  Since here `entry` is the
  multiplicative order, this *is* the classical fact `ord_{a*b} = lcm (ord_a) (ord_b)`.
* `RankOfApparition.fib_entry_mul_coprime` — the Fibonacci specialization (via
  `Nat.fib_gcd`), recovering the catalog's `fibEntry_mul_coprime` from the abstract theorem.
-/

namespace RankOfApparition

open Classical

/-- A **strong divisibility sequence**: `gcd (u m) (u n) = u (gcd m n)` (the
"renormalization" / self-similarity identity).  Both `Nat.fib` and `n ↦ aⁿ − 1` satisfy it.
This is the `Hgcd`-shaped restatement of `StrongDivSeq.IsStrongDivSeq`. -/
def IsSDS (u : ℕ → ℕ) : Prop := ∀ m n, Nat.gcd (u m) (u n) = u (Nat.gcd m n)

/-- The **entry point** (rank of apparition) of `m` in `u`: the least `k > 0` with
`m ∣ u k`, or `0` if no such index exists. -/
noncomputable def entry (u : ℕ → ℕ) (m : ℕ) : ℕ :=
  if h : ∃ k, 0 < k ∧ m ∣ u k then Nat.find h else 0

/-- `m` **appears** in `u`: it divides some positive term. -/
def Appears (u : ℕ → ℕ) (m : ℕ) : Prop := ∃ k, 0 < k ∧ m ∣ u k

variable {u : ℕ → ℕ}

/-! ## §1. Basic facts about the entry point (mirrors the catalog) -/

-- !-- `gcd(u d, u n) = u (gcd d n) = u d`, so `u d ∣ u n` by `gcd_eq_left_iff_dvd`. -- !--
/-- Divisibility of indices transports to divisibility of terms: `d ∣ n → u d ∣ u n`. -/
lemma dvd_of_dvd (Hgcd : IsSDS u) {d n : ℕ} (hd : d ∣ n) : u d ∣ u n := by
  have h1 : Nat.gcd (u d) (u n) = u d := by rw [Hgcd, Nat.gcd_eq_left hd]
  exact Nat.gcd_eq_left_iff_dvd.mp h1

/-- If `m` appears then its entry point is positive and witnesses divisibility. -/
lemma entry_spec {m : ℕ} (h : Appears u m) : 0 < entry u m ∧ m ∣ u (entry u m) := by
  have he : entry u m = Nat.find h := dif_pos h
  rw [he]; exact Nat.find_spec h

lemma entry_pos {m : ℕ} (h : Appears u m) : 0 < entry u m := (entry_spec h).1

lemma entry_dvd_self {m : ℕ} (h : Appears u m) : m ∣ u (entry u m) := (entry_spec h).2

-- !-- Pull `m ∣ u n` and `m ∣ u e` into `m ∣ u (gcd n e)`; minimality of `e = Nat.find` forces `gcd n e = e ∣ n`. -- !--
/-- **Rank of apparition divides the index.** If `m ∣ u n` with `n > 0`, then
`entry u m ∣ n`.  Uses only the strong-divisibility identity. -/
lemma entry_dvd (Hgcd : IsSDS u) {m n : ℕ} (hn : 0 < n) (hmn : m ∣ u n) :
    entry u m ∣ n := by
  have hex : Appears u m := ⟨n, hn, hmn⟩
  have he : entry u m = Nat.find hex := dif_pos hex
  have hspec := Nat.find_spec hex
  set e := Nat.find hex with he_def
  have he_pos : 0 < e := hspec.1
  have hme : m ∣ u e := hspec.2
  have hmg : m ∣ u (Nat.gcd n e) := by
    rw [← Hgcd]; exact Nat.dvd_gcd hmn hme
  have hg_pos : 0 < Nat.gcd n e := Nat.gcd_pos_of_pos_right _ he_pos
  have hg_le : e ≤ Nat.gcd n e := by
    by_contra h
    push_neg at h
    exact Nat.find_min hex h ⟨hg_pos, hmg⟩
  have hgcd_eq : Nat.gcd n e = e :=
    Nat.le_antisymm (Nat.le_of_dvd he_pos (Nat.gcd_dvd_right _ _)) hg_le
  rw [he, ← hgcd_eq]
  exact Nat.gcd_dvd_left _ _

/-! ## §2. The abstract law of apparition -/

/-
!-- Forward: `k = 0` uses `u 0 = 0`; `k > 0` is `entry_dvd`. Backward: `entry ∣ k → u(entry) ∣ u k` (`dvd_of_dvd`) and `m ∣ u(entry)`. -- !--

**The abstract law of apparition.** For a modulus `m` that appears in a strong
divisibility sequence `u` with `u 0 = 0`, divisibility of the `k`-th term is governed
entirely by the index: `m ∣ u k ↔ entry u m ∣ k`.
-/
theorem dvd_iff_entry_dvd (Hgcd : IsSDS u) (h0 : u 0 = 0) {m : ℕ}
    (hm : Appears u m) (k : ℕ) : m ∣ u k ↔ entry u m ∣ k := by
  constructor;
  · by_cases hk : 0 < k <;> simp_all +decide [ entry_dvd ];
  · intro hk;
    exact dvd_trans ( entry_spec hm |>.2 ) ( dvd_of_dvd Hgcd hk )

/-
!-- Antisymmetry of `∣`: `entry u m ∣ d` since `m ∣ u d` (from `h d`) and `entry_dvd`; and `d ∣ entry u m` from `h (entry u m)` applied to `entry_dvd_self`. -- !--

**Rigidity of the entry point.** If the indices of appearance of `m` are exactly the
multiples of a positive `d`, then `entry u m = d`.  The entry point is the unique positive
generator of the appearance set.
-/
theorem entry_eq_of_dvd_iff (Hgcd : IsSDS u) {m d : ℕ}
    (hm : Appears u m) (hd : 0 < d) (h : ∀ k, m ∣ u k ↔ d ∣ k) : entry u m = d := by
  apply Nat.dvd_antisymm;
  · apply entry_dvd Hgcd hd;
    exact h d |>.2 dvd_rfl;
  · exact h _ |>.1 ( entry_dvd_self hm )

/-! ## §3. The entry point is a divisibility-lattice morphism on moduli -/

/-
!-- `d ∣ m ∣ u (entry u m)` with `entry u m > 0`, so `entry_dvd` gives `entry u d ∣ entry u m`. -- !--

**Order side of the lattice morphism.** If `d ∣ m` and `m` appears, then
`entry u d ∣ entry u m`: refining the modulus refines (divides) the index of first
appearance.
-/
theorem entry_dvd_entry_of_dvd (Hgcd : IsSDS u) {d m : ℕ}
    (hm : Appears u m) (hdm : d ∣ m) : entry u d ∣ entry u m := by
  convert entry_dvd Hgcd ( entry_pos hm ) _;
  exact dvd_trans hdm ( entry_dvd_self hm )

/-! ## §4. Multiplicativity on coprime moduli (the join law) -/

/-- Coprime split of a product divisor. -/
lemma coprime_mul_dvd_iff {a b k : ℕ} (hab : Nat.Coprime a b) :
    a * b ∣ k ↔ a ∣ k ∧ b ∣ k := by
  constructor
  · intro h
    exact ⟨dvd_trans (dvd_mul_right a b) h, dvd_trans (dvd_mul_left b a) h⟩
  · rintro ⟨ha, hb⟩
    exact hab.mul_dvd_of_dvd_of_dvd ha hb

/-
!-- For all `k`: `a*b ∣ u k ↔ a∣u k ∧ b∣u k` (coprime) ↔ `entry a∣k ∧ entry b∣k` (law) ↔ `lcm∣k`; then `entry_eq_of_dvd_iff`. -- !--

**Multiplicativity / join law.** For coprime moduli `a, b` that appear in a strong
divisibility sequence `u` with `u 0 = 0`,
`entry u (a * b) = lcm (entry u a) (entr
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — The Entry-Point (Rank-of-Apparition) Lattice Morphism

## Synthesis

This cycle isolated, and proved in full abstraction, the two facts that the catalog's
"proof phase transition / Fibonacci primitive divisor" program had only ever stated for the
Fibonacci sequence (and through the now-missing `Speculative.AutoResearch.FibonacciApparition`
module): the **law of apparition** and the **coprime multiplicativity of the rank of
apparition**. The new file `Catalog/Speculative/AutoResearch/EntryPointMultiplicativity.lean`
shows both follow from nothing but the renormalization identity
`gcd (u m) (u n) = u (gcd m n)` together with the boundary value `u 0 = 0`. Concretely it
proves, for an arbitrary strong divisibility sequence `u`:

* `dvd_iff_entry_dvd` — `m ∣ u k ↔ entry u m ∣ k` (the bridge from terms to indices);
* `entry_eq_of_dvd_iff` — the entry point is the unique positive generator of the appearance
  set (uses only the gcd identity, **not** `u 0 = 0`);
* `entry_dvd_entry_of_dvd` — `d ∣ m → entry u d ∣ entry u m` (order side of the morphism);
* `entry_mul_coprime` — `entry u (a·b) = lcm (entry u a) (entry u b)` on coprime moduli.

These were harvested into two cross-domain instances at zero further cost:
`mersenne_entry_mul_coprime` for `u n = aⁿ − 1` (where `entry` is the multiplicative order,
so this is the classical `ord_{a·b} = lcm(ord_a, ord_b)`) and `fib_entry_mul_coprime` for
Fibonacci, recovering the catalog's `fibEntry_mul_coprime`. Together with the catalog's
`StrongDivSeq.dvd_gcd_index_iff` (`gcd ↦ gcd`) this exhibits `entry u` as a genuine
divisibility-lattice morphism, and pins down `u 0 = 0` as load-bearing only for the `k = 0`
edge case of the law of apparition.

## Results Summary

| Theorem | Statement | Hypotheses actually used |
|---|---|---|
| `dvd_iff_entry_dvd` | `m ∣ u k ↔ entry u m ∣ k` | `IsSDS`, `Appears` (`u 0 = 0` only for `k=0`) |
| `entry_eq_of_dvd_iff` | entry = unique positive generator | `IsSDS` only |
| `entry_dvd_entry_of_dvd` | `d ∣ m → entry u d ∣ entry u m` | `IsSDS` only |
| `entry_mul_coprime` | `entry u (a·b) = lcm (entry u a) (entry u b)` | `IsSDS`, `u 0 = 0`, coprimality, `Appears` |
| `mersenne_entry_mul_coprime` | order is multiplicative on coprime moduli | `Appears` of both factors |
| `fib_entry_mul_coprime` | Fibonacci rank multiplicative on coprime moduli | `Appears` of both factors |

All six are `sorry`-free and depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Falsifiable Research Directions

### 1. Fibonacci totality: discharge the `Appears` hypotheses via Pisano periodicity
**Conjecture.** Every positive `m` divides some positive Fibonacci number, with the first
index `entry Nat.fib m ≤ m²` (more sharply, `≤ 6m`, the Pisano-period bound). Formalizing
this removes the `Appears` hypotheses from `fib_entry_mul_coprime`, turning it into the
unconditional `∀ a b > 0, Coprime a b → entry fib (a·b) = lcm (entry fib a) (entry fib b)`.
**The key insight is** that th
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
