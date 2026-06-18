
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
    {
      "name": "descriptive_name",
      "description": "Detailed in-depth explanation of the algorithm, its mathematical foundation, computational complexity, and role in the pipeline.",
      "pseudocode": "Formal, structured step-by-step pseudocode detailing the logic.",
      "code": "# full Python source with type hints..."
    }
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

**Title**: Close Proofs: Close Proofs: The current formalization handles 0-dimensional persiste
**Domain**: Novelty
**Mathematical framing**: Cycle 007b54b3 (Q=0.518) proved 876 theorems in Applications but left 2 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Cycle 605ab808 (Q=0.424) proved 489 theorems in Physics but left 1 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: # Future Directions: The 
Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Bridges/FractalProofSearch/Defs.lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.

# Fractal Dimension of Proof Search — Definitions and Core Theory

## Overview

When a theorem prover searches for a proof, it explores a tree of possible
derivation steps. The "fractal dimension" of the set of successful proof paths
captures how hard the theorem is to prove. We formalize this via a
**branching search model** where at each node of a b-ary tree, exactly k
children lead to eventually-successful paths. The search dimension
D = log(k)/log(b) measures proof difficulty on a continuous scale from
0 (deterministic, unique proof) to 1 (trivial, every path works).

## Novel Concepts

- `SearchDimension`: fractal dimension of proof search = log(k)/log(b)
- `BranchingSearchModel`: parameterized proof search structure
- `ComposedSearch`: sequential composition of search problems
- `SearchEntropy` / `FullTreeEntropy`: information-theoretic measures

## Main Results

- Dimension lies in [0, 1] and equals 1 iff k = b (critical threshold)
- Dimension is monotone in survival count k
- Subcritical phase: k < b ⟹ exponential decay of success probability
- Entropy-dimension bridge: D = SearchEntropy / FullTreeEntropy
- Dimension determines information rate per search level
-/

import Mathlib

open Real Finset Nat

/-! ## Section 1: The Branching Search Model -/

/-- A **branching search model** captures the structure of proof search as a
complete b-ary tree where k out of b branches survive at each node.
- `b`: total branching factor (number of applicable tactics)
- `k`: surviving branches per node (leading to eventual proofs)
- `d`: search depth (proof length)
-/
structure BranchingSearchModel where
  b : ℕ
  k : ℕ
  d : ℕ
  hb : 2 ≤ b
  hk_pos : 1 ≤ k
  hkb : k ≤ b

namespace BranchingSearchModel

/-- Total leaf nodes: all possible proof attempts of length d. -/
def totalLeaves (M : BranchingSearchModel) : ℕ := M.b ^ M.d

/-- Successful leaf nodes: proof paths that work. -/
def successfulLeaves (M : BranchingSearchModel) : ℕ := M.k ^ M.d

end BranchingSearchModel

/-! ## Section 2: Search Dimension (Novel Definition)

The **search dimension** D = log(k)/log(b) is the box-counting dimension
of the set of successful paths in the boundary of the b-ary tree under
the natural ultrametric d(x,y) = b^{-n} where n is the common prefix length.

- D = 0: unique proof path (k = 1)
- D = 1: every path is a proof (k = b)
- 0 < D < 1: intermediate difficulty
-/

/-- The fractal dimension of proof search: log(k) / log(b).
Equals the Hausdorff dimension of successful paths in the tree boundary. -/
noncomputable def SearchDimension (b k : ℕ) : ℝ :=
  Real.log (k : ℝ) / Real.log (b : ℝ)

/-! ## Section 3: Fundamental Properties -/

/-- When every branch succeeds (k = b), dimension is 1. -/
theorem searchDim_full (b : ℕ) (hb : 2 ≤ b) :
    SearchDimension b b = 1 := by
  unfold SearchDimension
  exact div_self (ne_of_gt (Real.log_pos (by exact_mod_cast Nat.lt_of_lt_of_le one_lt_two hb)))

/-- When exactly one branch succeeds (k = 1), dimension is 0. -/
theorem searchDim_unique (b : ℕ) :
    SearchDimension b 1 = 0 := by
  simp [SearchDimension, Nat.cast_one, Real.log_one]

/-- Dimension is non-negative for valid parameters. -/
theorem searchDim_nonneg (b k : ℕ) (hb : 2 ≤ b) (hk : 1 ≤ k) (_hkb : k ≤ b) :
    0 ≤ SearchDimension b k := by
  apply div_nonneg
  · exact Real.log_nonneg (by exact_mod_cast hk)
  · exact le_of_lt (Real.log_pos (by exact_mod_cast Nat.lt_of_lt_of_le one_lt_two hb))

/-- Dimension is at most 1. -/
theorem searchDim_le_one (b k : ℕ) (hb : 2 ≤ b) (hk : 1 ≤ k) (hkb : k ≤ b) :
    SearchDimension b k ≤ 1 := by
  unfold SearchDimension
  rw [div_le_one (Real.log_pos (by exact_mod_cast Nat.lt_of_lt_of_le one_lt_two hb))]
  exact Real.log_le_log (by exact_mod_cast hk) (by exact_mod_cast hkb)

/-- **Subcritical dimension**: k < b implies dimension strictly less than 1. -/
theorem searchDim_lt_one (b k : ℕ) (hb : 2 ≤ b) (hk : 1 ≤ k) (hkb : k < b) :
    SearchDimension b k < 1 := by
  unfold SearchDimension
  rw [div_lt_one (Real.log_pos (by exact_mod_cast Nat.lt_of_lt_of_le one_lt_two hb))]
  exact Real.log_lt_log (by exact_mod_cast hk) (by exact_mod_cast hkb)

/-! ## Section 4: Monotonicity -/

/-- More surviving branches → higher dimension (easier search). -/
theorem searchDim_mono (b : ℕ) (hb : 2 ≤ b) {k₁ k₂ : ℕ}
    (hk₁ : 1 ≤ k₁) (h : k₁ ≤ k₂) (_hk₂b : k₂ ≤ b) :
    SearchDimension b k₁ ≤ SearchDimension b k₂ := by
  unfold SearchDimension
  apply div_le_div_of_nonneg_right
  · exact Real.log_le_log (by exact_mod_cast hk₁) (by exact_mod_cast h)
  · exact le_of_lt (Real.log_pos (by exact_mod_cast Nat.lt_of_lt_of_le one_lt_two hb))

/-! ## Section 5: Subcritical Exponential Decay -/

/-- When k < b, successful paths are strictly fewer than total paths. -/
theorem subcritical_decay (b k d : ℕ) (hkb : k < b) (hd : d ≠ 0) :
    k ^ d < b ^ d :=
  Nat.pow_lt_pow_left hkb hd

/-- The success ratio strictly worsens with each additional depth level:
    k^(d+1) · b^d < k^d · b^(d+1). -/
theorem decay_ratio_worsens (b k d : ℕ) (hk : 1 ≤ k) (hkb : k < b) :
    k ^ (d + 1) * b ^ d < k ^ d * b ^ (d + 1) := by
  simp only [pow_succ]
  have hkd : 0 < k ^ d := Nat.one_le_pow _ _ hk
  have hbd : 0 < b ^ d := Nat.one_le_pow _ _ (by omega)
  nlinarith [mul_lt_mul_of_pos_right hkb hbd]

/-! ## Section 6: Critical Threshold -/

/-- **Critical threshold**: D = 1 if and only if k = b. -/
theorem critical_threshold (b k : ℕ) (hb : 2 ≤ b) (hk : 1 ≤ k) (hkb : k ≤ b) :
    SearchDimension b k = 1 ↔ k = b := by
  constructor
  · intro h
    unfold SearchDimension at h
    have hlogb_pos : 0 < Real.log (b : ℝ) :=
      Real.log_pos (by exact_mod_cast Nat.lt_of_lt_of_le one_lt_two hb)
    rw [div_eq_one_iff_eq (ne_of_gt hlogb_pos)] at h
    have hk_pos : (0 : ℝ) < k := by positivity
    have hb_pos : (0 : ℝ) < b := by positivity
    exact_mod_cast Real.log_injOn_pos (Set.mem_Ioi.mpr hk_pos) (Set.mem_Ioi.mpr hb_pos) h
  · intro heq; subst heq; exact searchDim_full k hb

/-- **Subcritical iff**: D < 1 iff k < b. -/
theorem subcritical_iff (b k : ℕ) (hb : 2 ≤ b) (hk : 1 ≤ k) (hkb : k ≤ b) :
    SearchDimension b k < 1 ↔ k < b := by
  constructor
  · intro h
    by_contra hle
    push_neg at hle
    have : k = b := le_antisymm hkb hle
    rw [(critical_threshold b k hb hk hkb).mpr this] at h
    exact lt_irrefl 1 h
  · exact searchDim_lt_one b k hb hk

/-! ## Section 7: Entropy-Dimension Bridge -/

/-- Search entropy: log of successful path count at depth d. -/
noncomputable def SearchEntropy (k d : ℕ) : ℝ := Real.log ((k : ℝ) ^ d)

/-- Full tree entropy: log of total path count at depth d. -/
noncomputable def FullTreeEntropy (b d : ℕ) : ℝ := Real.log ((b : ℝ) ^ d)

/-- **Entropy-dimension bridge**: search dimension = SearchEntropy / FullTreeEntropy.
This is the key connection between information theory and fractal geometry. -/
theorem entropy_dimension_bridge (b k d : ℕ) (_hb : 2 ≤ b) (_hd : 1 ≤ d) :
    SearchEntropy k d / FullTreeEntropy b d = SearchDimension b k := by
  unfold SearchEntropy FullTreeEntropy SearchDimension
  rw [Real.log_pow, Real.log_pow]
  have hd_pos : (d : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (by omega)
  field_simp

/-- The information per depth level equals log(b) · (1 - D). -/
theorem dimension_info_rate (b k : ℕ) (hb : 2 ≤ b) (_hk : 1 ≤ k) (_hkb : k ≤ b) :
    Real.log (b : ℝ) - Real.log (k : ℝ) =
    Real.log (b : ℝ) * (1 - SearchDimension b k) := by
  unfold SearchDimension
  have hlogb : Real.log (b : ℝ) ≠ 0 :=
    ne_of_gt (Real.log_pos (by exact_mod_cast Nat.lt_of_lt_of_le one_lt_two hb))
  field_simp

/-- Information content decomposes multiplicatively over depth. -/
theorem info_content_decomposition (b k d : ℕ) :
    Real.log ((b : ℝ) ^ d) - Real.log ((k : ℝ) ^ d) =
    (d : ℝ) * (Real.log (b : ℝ) - Real.log (k : ℝ)) := by
  rw [Real.log_pow, Real.log_pow]; ring

/-! ## Section 9: Composition of Searches -/

/-- Sequential composition of two p
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Fibonacci Rank of Apparition

The file `Catalog/Speculative/FibApparitionExistence.lean` establishes, for every
modulus `m ≥ 1`, the **existence** of the Fibonacci rank of apparition `z(m)` (the least
positive `k` with `m ∣ F k`) and the full **biconditional** divisibility law
`m ∣ F n ↔ z(m) ∣ n`. The existence proof is purely structural: it iterates the
Fibonacci shift permutation `(a,b) ↦ (b, a+b)` on the finite set `ZMod m × ZMod m` and
uses pigeonhole + injectivity to force a return to `(0,1)`. This is the abstract engine
behind the Pisano period, none of which currently lives in Mathlib. The catalog's existing
`fibEntryPt_dvd_of_fib_dvd` (in `Speculative.AutoResearch.CarmichaelComposite`) is now a
strict corollary, freed from its primality assumption. The directions below build outward
from this foundation.

## 1. The Pisano period as the order of the shift permutation

Define the Pisano period `π(m)` as the least positive `t` with `(fibStep m)^[t] = id`,
i.e. the order of `fibStep m` in the permutation group of `ZMod m × ZMod m`. Conjecture:
`π(m)` exists for every `m ≥ 1`, equals `orderOf (fibStep m)`, and satisfies
`z(m) ∣ π(m)` together with the multiplicative bound `π(m) ∣ lcm` of the prime-power
Pisano periods of `m`.

The key insight is that `fibStep m` is a genuine group element (an `Equiv`), so its order
is a single algebraic invariant from which both the Pisano period and the rank of
apparition descend — `z(m)` is the first index where the *first coordinate* vanishes,
while `π(m)` is the first index where the *whole state* returns. Why now? The present file
already packages `fibStep` as an `Equiv.Perm`-style object and proves `fibStep_iterate`, so
`orderOf` and `Function.IsPeriodicPt` apply directly without any new infrastructure.

## 2. Multiplicativity of the rank of apparition

Conjecture: if `gcd(a, b) = 1` then `z(a * b) = lcm(z(a), z(b))`, and consequently `z` is
determined by its values on prime powers. Combined with Direction 1 this would give a
complete recursive formula for `z(m)`.

The key insight is that `m ∣ F n ↔ z(m) ∣ n` (already proved as
`fib_dvd_iff_apparitionRank_dvd`) turns a divisibility statement about `F n` into a lattice
statement about the divisors of `n`: for coprime `a, b`, `a*b ∣ F n ↔ (z(a) ∣ n ∧ z(b) ∣ n)
↔ lcm(z(a), z(b)) ∣ n`, and the least such `n` is exactly the lcm. Why now? The
biconditional that makes this CRT-style argument purely formal is exactly the capstone
theorem just proved, so the conjecture is reducible to elementary lattice manipulation plus
`Nat.Coprime` API.

## 3. The law of apparition for primes (z(p) ∣ p − (5/p))

Conjecture: for a prime `p ≠ 5`, the rank of apparition divides `p - (5 | p)`, where
`(5 | p)` is the Legendre symbol; concretely `z(p) ∣ p − 1` when `p ≡ ±1 (mod 5)` and
`z(p) ∣ p + 1` when `p ≡ ±2 (mod 5)`. This refines pure existence into a sharp size bound
`z(p) ≤ p + 1`.

The key insight is that working in `ZMod p` adjoined with a square roo
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
of objects (not placeholder strings). For each algorithm in the algorithms array, provide a name, a detailed explanation of its logic and complexity in 'description', formal step-by-step pseudocode in 'pseudocode', and clean type-hinted Python code in 'code'. Include future directions from Phase A in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
