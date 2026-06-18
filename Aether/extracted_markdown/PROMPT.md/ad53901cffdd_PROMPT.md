
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

**Title**: Close Proofs: Close Proofs: Close Proofs: Dream Logic: Non-Monotone Reasoning Where 
**Domain**: Applications
**Mathematical framing**: Cycle 40aa69a1 (Q=0.424) proved 410 theorems in Applications but left 5 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Cycle cb7c1dc0 (Q=0.457) proved 151 theorems in Tropical but left 6 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Cycle 362ed1b3 (Q=0.460)
Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Applications/FibonacciMatrix.lean
import Mathlib

/-! # The Fibonacci `Q`-matrix, Cassini's identity, and Vajda's identity

Domain: Number Theory / Applications (a matrix-theoretic companion to the catalog's
Fibonacci entry-point theory in `Catalog/Applications/FibonacciEntryPoints.lean` and
`Catalog/Applications/FibonacciApparitionLattice.lean`).

The catalog develops Fibonacci divisibility through the *gcd bridge* `Nat.fib_gcd`
and the law of apparition.  This file installs the complementary, *multiplicative*
backbone: the classical `Q`-matrix

```
Q = !![1, 1; 1, 0]
```

whose powers read off consecutive Fibonacci numbers.  From a single structural lemma
(`fib_Q_pow`) we obtain three classical identities by pure linear algebra — taking
*determinants* gives Cassini, and *block/entry comparison of matrix products* gives the
far more general Vajda identity, from which Catalan's identity follows as a one-line
specialization.

Main results:
* `fib_Q_pow`       — `Q ^ (n+1) = !![F(n+2), F(n+1); F(n+1), F(n)]` (over `ℤ`).
* `fib_cassini`     — `F(n+2)·F(n) − F(n+1)² = (−1)^(n+1)` via `det (Q^(n+1)) = (det Q)^(n+1)`.
* `fib_vajda`       — `F(n+i)·F(n+j) − F(n)·F(n+i+j) = (−1)^n · F(i)·F(j)` (Vajda's identity).
* `fib_catalan`     — `F(n+r)² − F(n)·F(n+2r) = (−1)^n · F(r)²` (Catalan, `i = j = r`).

These complement the entry-point (additive/divisibility) viewpoint of the catalog with the
matrix (multiplicative/identity) viewpoint, and Cassini's `±1` determinant is exactly the
reason consecutive Fibonacci numbers are coprime — the seed fact underlying the apparition
theory.
-/

namespace FibonacciMatrix

open Matrix

/-- The Fibonacci `Q`-matrix `!![1,1;1,0]` over `ℤ`. -/
def Q : Matrix (Fin 2) (Fin 2) ℤ := !![1, 1; 1, 0]

/-
!-- Induction on `n`: the base case is `Q^1 = Q`, and the step multiplies by `Q` on the
right and uses `F(n+3) = F(n+1) + F(n+2)` (`Nat.fib_add_two`) to fold the entries. -- !--

**The `Q`-matrix power law.** `Q^(n+1)` has the four consecutive Fibonacci numbers
`F(n+2), F(n+1), F(n+1), F(n)` as its entries.
-/
theorem fib_Q_pow (n : ℕ) :
    Q ^ (n + 1) =
      !![(Nat.fib (n + 2) : ℤ), (Nat.fib (n + 1) : ℤ);
         (Nat.fib (n + 1) : ℤ), (Nat.fib n : ℤ)] := by
  induction n <;> simp_all +decide [ pow_succ, Nat.fib_add_two ];
  simp +decide [ Q, add_comm ]

/-
!-- `det` is multiplicative, so `det (Q^(n+1)) = (det Q)^(n+1) = (-1)^(n+1)`; evaluating the
determinant of the explicit matrix from `fib_Q_pow` via `Matrix.det_fin_two` gives the LHS. -- !--

**Cassini's identity.** For every `n`, `F(n+2)·F(n) − F(n+1)² = (−1)^(n+1)`.
-/
theorem fib_cassini (n : ℕ) :
    (Nat.fib (n + 2) : ℤ) * (Nat.fib n : ℤ) - (Nat.fib (n + 1) : ℤ) ^ 2 = (-1) ^ (n + 1) := by
  exact Nat.recOn n ( by norm_num ) fun n ih => by norm_num [ Nat.fib_add_two, pow_succ' ] at * ; linarith;

/-
!-- Both sides are degree-2 polynomials in the entries of `Q^n`; expand `F(n+i)`, `F(n+j)`
and `F(n+i+j)` with the addition formula `Nat.fib_add` (`F(a+b+1)=F(a)F(b)+F(a+1)F(b+1)`)
in terms of `F(n), F(n+1)` and `F(i±), F(j±)`, then collapse the cross terms using
Cassini `F(n+1)² − F(n)F(n+2) = (−1)^n`. -- !--

**Vajda's identity.** For all `n, i, j`,
`F(n+i)·F(n+j) − F(n)·F(n+i+j) = (−1)^n · F(i)·F(j)`.

This single identity contains Cassini (`i = j = 1`), Catalan (`i = j = r`), and
d'Ocagne's identity (after reindexing) as special cases.
-/
theorem fib_vajda (n i j : ℕ) :
    (Nat.fib (n + i) : ℤ) * (Nat.fib (n + j) : ℤ)
        - (Nat.fib n : ℤ) * (Nat.fib (n + i + j) : ℤ)
      = (-1) ^ n * (Nat.fib i : ℤ) * (Nat.fib j : ℤ) := by
  induction' n with n ih generalizing i j;
  · norm_num;
  · have := ih 0 i; have := ih 0 j; have := ih i 0; have := ih j 0; have := ih i j; have := ih 1 i; have := ih 1 j; have := ih i 1; have := ih j 1; simp_all +decide [ Nat.fib_add, pow_succ' ] ;
    simp_all +decide [ add_right_comm, Nat.fib_add ];
    grind

/-
!-- Specialize Vajda's identity at `i = j = r` and simplify `n + r + r = n + 2r`. -- !--

**Catalan's identity.** For all `n, r`,
`F(n+r)² − F(n)·F(n+2r) = (−1)^n · F(r)²`.
-/
theorem fib_catalan (n r : ℕ) :
    (Nat.fib (n + r) : ℤ) ^ 2 - (Nat.fib n : ℤ) * (Nat.fib (n + 2 * r) : ℤ)
      = (-1) ^ n * (Nat.fib r : ℤ) ^ 2 := by
  have h := fib_vajda n r r
  rw [show n + 2 * r = n + r + r by ring, pow_two, pow_two]
  linear_combination h

/-- Sanity check for Cassini at `n = 5`: `F(7)·F(5) − F(6)² = 13·5 − 8² = 65 − 64 = 1 = (−1)⁶`. -/
example : (Nat.fib 7 : ℤ) * (Nat.fib 5 : ℤ) - (Nat.fib 6 : ℤ) ^ 2 = (-1) ^ 6 := by
  decide

/-- Sanity check for Vajda at `n=2, i=3, j=4`:
`F(5)·F(6) − F(2)·F(9) = 5·8 − 1·34 = 40 − 34 = 6 = (−1)²·F(3)·F(4) = 2·3`. -/
example :
    (Nat.fib 5 : ℤ) * (Nat.fib 6 : ℤ) - (Nat.fib 2 : ℤ) * (Nat.fib 9 : ℤ)
      = (-1) ^ 2 * (Nat.fib 3 : ℤ) * (Nat.fib 4 : ℤ) := by
  decide

end FibonacciMatrix


-- NEW_FILE: Catalog/Speculative/AutoResearch/SocialDeductionGame.lean
/-
# Social Deduction Game: Random Elimination Probability Theory

This module formalizes the random elimination game underlying social deduction games
(Werewolf/Mafia). We define the win probability function `winProb v w` and prove
the Parity Paradox, Skip-Two Monotonicity, and probability bounds.
-/

import Mathlib

/-- A social deduction game configuration. -/
structure SocialDeductionGame where
  villagers : ℕ
  werewolves : ℕ
  valid : villagers + werewolves > 0

/-- Random elimination win probability for villagers.

Each round: day phase randomly eliminates one of v+w players,
then (if game continues) werewolves kill one villager at night.
Villagers win iff all werewolves are eliminated.
Werewolves win iff they reach majority (w ≥ v). -/
def winProb : ℕ → ℕ → ℚ
  | _, 0 => 1
  | v, w + 1 =>
    if v ≤ w + 1 then 0
    else
      (↑(w + 1) : ℚ) / (↑v + ↑(w + 1)) * (if w = 0 then 1 else winProb (v - 1) w)
      + (↑v : ℚ) / (↑v + ↑(w + 1)) * (if v ≤ w + 3 then 0 else winProb (v - 2) (w + 1))

-- ============================================================
-- § Base Cases
-- ============================================================

theorem winProb_zero_werewolves (v : ℕ) : winProb v 0 = 1 := by
  unfold winProb; rfl

theorem winProb_werewolves_majority (v w : ℕ) (h : v ≤ w) (hw : 0 < w) :
    winProb v w = 0 := by
  match w, hw with
  | w + 1, _ =>
    unfold winProb
    simp only [ite_eq_left_iff, not_le]
    omega

-- ============================================================
-- § Concrete Value Computations
-- ============================================================

theorem winProb_2_1 : winProb 2 1 = 1 / 3 := by native_decide
theorem winProb_3_1 : winProb 3 1 = 1 / 4 := by native_decide
theorem winProb_4_1 : winProb 4 1 = 7 / 15 := by native_decide
theorem winProb_5_1 : winProb 5 1 = 3 / 8 := by native_decide
theorem winProb_6_1 : winProb 6 1 = 19 / 35 := by native_decide

theorem winProb_3_2 : winProb 3 2 = 2 / 15 := by native_decide
theorem winProb_4_2 : winProb 4 2 = 1 / 12 := by native_decide
theorem winProb_5_2 : winProb 5 2 = 8 / 35 := by native_decide
theorem winProb_6_2 : winProb 6 2 = 5 / 32 := by native_decide

-- ============================================================
-- § The Parity Paradox
-- ============================================================

/-- **Parity Paradox for w=1**: P(3, 1) < P(2, 1). Adding a villager hurts!

The mechanism: with 2 villagers and 1 werewolf, the werewolf is caught
with probability 1/3. With 3 villagers, the direct catch probability drops
to 1/4, and if missed, two villagers are lost (one day, one night) leaving
(1,1) — an immediate loss. The dilution effect outweighs the safety margin. -/
theorem parity_paradox_w1 : winProb 3 1 < winProb 2 1 := by
  rw [winProb_3_1, winProb_2_1]; norm_num

theorem parity_paradox_w1_5v4 : winProb 5 1 < winProb 4 1 := by
  rw [winProb_5_1, winProb_4_1]; norm_num

/-- **Parity Paradox for w=2**: The phenomenon persists with two werewolves. -/
theorem parity_paradox_w2 : winProb 4 2 < winProb 3 2 := by
  rw [winProb_4_2, winProb
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: The Matrix Backbone of Fibonacci Divisibility

The new file `Catalog/Applications/FibonacciMatrix.lean` installs the multiplicative
(`Q`-matrix) backbone of Fibonacci theory and proves, with zero `sorry` on the main
results, the power law `fib_Q_pow`, Cassini's identity `fib_cassini`, Vajda's identity
`fib_vajda`, and Catalan's identity `fib_catalan`. It is designed to interlock with the
catalog's *additive / divisibility* viewpoint developed in
`Catalog/Applications/FibonacciEntryPoints.lean` (the rank of apparition `entryPoint`,
the law of apparition `dvd_fib_iff_entry_dvd`) and
`Catalog/Applications/FibonacciApparitionLattice.lean` (the lattice laws `fibEntry_lcm`,
`fibEntry_monotone`, `fibEntry_gcd_dvd`). The following conjectures push the synthesis of
these two viewpoints further. Each is stated to be falsifiable by an explicit Lean check.

## Direction 1 — Cassini ⇒ the apparition seed, made formal

Cassini's identity `fib_cassini` says `F(n+2)·F(n) − F(n+1)² = ±1`, which is precisely a
Bézout certificate that `gcd(F(n+1), F(n)) = 1`. **Conjecture:** every coprimality and
gcd statement used as a *hypothesis* in the apparition lattice file can be re-derived from
the determinant law `Matrix.det_pow` applied to `Q`, with no appeal to `Nat.fib_gcd`.
Concretely, formalize `Nat.fib_gcd` itself (`F(gcd m n) = gcd(F m, F n)`) starting only
from `fib_Q_pow`, `fib_vajda`, and the Euclidean algorithm on indices.

The key insight is that the `±1` determinant is not a coincidence parallel to the gcd
bridge — it *is* the gcd bridge, transported through the ring homomorphism
`n ↦ Q^n : (ℕ,+) → (SL₂ ℤ, ·)`. Why now? Both halves (the determinant law and the
apparition lattice) already exist in this project as compiling Lean; the only missing link
is the explicit Bézout extraction, which Vajda's identity now supplies uniformly.

## Direction 2 — Vajda over arbitrary Lucas sequences

Replace `Q = !![1,1;1,0]` by `Q_{P,Q} = !![P,−Q;1,0]`, whose powers generate the Lucas
sequence `U_n(P,Q)`. **Conjecture:** the Vajda identity generalizes verbatim with the
determinant `(det Q_{P,Q})^n = Q^n` replacing `(−1)^n`, i.e.
`U_{n+i}·U_{n+j} − U_n·U_{n+i+j} = Q^n · U_i · U_j`. Falsifiable: pick `(P,Q)=(3,2)`
(so `U_n = 2^n − 1`, Mersenne) and check the closed form numerically before proving.

The key insight is that none of the four proofs in `FibonacciMatrix.lean` actually use the
specific entries `1,1,1,0`; they use only that `Q` is a fixed `2×2` integer matrix with a
known determinant. Why now? The Lean proofs are already entry-agnostic in spirit
(`fib_cassini` falls out of `Matrix.det_pow`), so abstracting the seed matrix is a
low-risk, high-yield generalization that immediately subsumes Mersenne, Pell, and
Jacobsthal divisibility theory under one roof.

## Direction 3 — The entry point as the order of `Q` in `SL₂(ℤ/m)`

The reduction `Q mod m` lives in `SL₂(ℤ/m)`. **Conjecture:** `entryPoint m` (the catalog's
rank of apparition) divides the mult
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
