
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

**Title**: Close Proofs: The order-theoretic core of the Cook–Reckhow program in this catalog h
**Domain**: Novelty
**Mathematical framing**: Cycle e955f9f8 (Q=0.722) proved 219 theorems in Novelty but left 7 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: # Future Directions: The Full Order Type of the p-Degrees

## Synthesis

The order-theoretic core of the Cook–Reckhow program in this catalog has, over successive
cycles, been assembled from the simul
Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Algebra/MarkovBases/TwoWay.lean
import Mathlib

/-!
# Algebraic Statistics: The Markov Basis of the Two-Way Independence Model

This file formalises the **two-way independence model** on `m × n` contingency tables and
proves the *Fundamental Theorem of Markov Bases* for it (Diaconis–Sturmfels): the set of
**basic `2 × 2` swap moves** connects every fiber of the model.

An `m × n` contingency table is `u : Fin m → Fin n → ℤ`.  The independence model fixes the
two families of one-dimensional margins (all row sums and all column sums).  A *fiber* is the
set of non-negative integer tables with prescribed row and column sums (a transportation
polytope's lattice points).

The classical Markov basis of this model is the collection of **basic moves**
`B(i,i',j,j') = e_{i,j'} + e_{i',j} - e_{i,j} - e_{i',j'}` for `i ≠ i'`, `j ≠ j'`: the
`2 × 2` minor swaps.  This file proves these moves connect every fiber, using the textbook
distance-reduction argument.

## Main results

* `basicMove_preserves_margins` — every basic move lies in the kernel of the margin map
  (it is a legal model move): adding it changes no row sum and no column sum.
* `exists_good_indices` — for any two distinct equal-margin tables there is a `2 × 2`
  configuration `(i,i',j,j')` aligned with the sign pattern of `u - v` (a three-step
  pigeonhole on the all-cells sum, a row sum, then a column sum).
* `dist_decrease` — the corresponding basic move strictly decreases the `ℓ¹` distance to `v`.
* `twoWay_fiber_connected` — **Fundamental Theorem of Markov Bases (independence model).**
  Any two non-negative tables with equal row and column sums are joined by a walk of basic
  `2 × 2` moves that stays non-negative at every step: the basic moves connect every fiber.

## Catalog synthesis

This is the foundational companion to `Algebra.MarkovBases.NoThreeWay` (which handles the
rank-one `2 × 2 × 2` no-three-way model).  Where that model has a *single* generator, the
independence model needs the full family of `2 × 2` swaps, so the connectivity proof is a
genuine *distance-reduction* (potential-function) argument rather than a one-line walk: a
reusable bridge between integer lattice walks (combinatorial step relations via
`Relation.ReflTransGen`) and the `ℓ¹` metric on fibers.  The three-stage pigeonhole in
`exists_good_indices` (all-cells sum → row sum → column sum) is the structural heart of the
Fundamental Theorem of Markov Bases.
-/

namespace MarkovBases.TwoWay

variable {m n : ℕ}

/-- An `m × n` integer contingency table. -/
abbrev Table (m n : ℕ) := Fin m → Fin n → ℤ

/-- The `i`-th row margin (sum over columns). -/
def rowSum (u : Table m n) (i : Fin m) : ℤ := ∑ j, u i j
/-- The `j`-th column margin (sum over rows). -/
def colSum (u : Table m n) (j : Fin n) : ℤ := ∑ i, u i j

/-- Two tables lie in the same fiber of the independence model iff all row sums and all
column sums agree. -/
def SameMargins (u v : Table m n) : Prop :=
  (∀ i, rowSum u i = rowSum v i) ∧ (∀ j, colSum u j = colSum v j)

/-- The basic `2 × 2` swap move `B(i,i',j,j') = e_{i,j'} + e_{i',j} - e_{i,j} - e_{i',j'}`. -/
def basicMove (i i' : Fin m) (j j' : Fin n) : Table m n :=
  fun a b =>
    (if a = i ∧ b = j' then 1 else 0)
  + (if a = i' ∧ b = j then 1 else 0)
  - (if a = i ∧ b = j then 1 else 0)
  - (if a = i' ∧ b = j' then 1 else 0)

/-- Non-negativity of a table (membership in a fiber requires non-negative counts). -/
def Nonneg (u : Table m n) : Prop := ∀ i j, 0 ≤ u i j

/-- A single legal Markov step: add a basic `2 × 2` move (with distinct rows and columns),
staying non-negative at both ends.  The reverse move is obtained by swapping `i, i'`. -/
def Step (u v : Table m n) : Prop :=
  Nonneg u ∧ Nonneg v ∧
    ∃ (i i' : Fin m) (j j' : Fin n), i ≠ i' ∧ j ≠ j' ∧ v = u + basicMove i i' j j'

/-- `Connected u v`: a walk of legal basic `2 × 2` moves from `u` to `v`. -/
def Connected (u v : Table m n) : Prop := Relation.ReflTransGen Step u v

/-- The `ℓ¹` distance between two tables (number of unit cell-discrepancies). -/
def D (u v : Table m n) : ℕ := ∑ p : Fin m × Fin n, (u p.1 p.2 - v p.1 p.2).natAbs

-- !-- Lab Notebook: basicMove_preserves_margins -- !--
-- !-- Hypothesis: every basic 2×2 move has all row and column margins zero, so it is legal -- !--
-- !-- Result: PROVED. Adding any basic move leaves every rowSum and colSum unchanged. -- !--
-- !-- Insight: each row of B sums to +1-1=0 (cols j,j'), each column to +1-1=0 (rows i,i') -- !--
-- !-- Failure analysis: keeping B in the explicit four-`if` form lets `simp +decide` plus a
--     case split on whether the running index equals i/i' (resp. j/j') discharge each line
--     sum after `Finset.sum_add_distrib` splits the perturbation off the base table. -- !--
-- !-- End Lab Notebook -- !--

-- !-- basicMove_preserves_margins: each row of B sums to 0 (uses j≠j') and each column sums to
-- 0 (uses i≠i'), so adding B changes no margin: B is in the kernel of the margin map. -- !--
/-- Adding a basic move (with distinct rows and columns) preserves all row and column
margins: every basic move lies in the kernel of the margin map. -/
theorem basicMove_preserves_margins (u : Table m n) (i i' : Fin m) (j j' : Fin n)
    (hi : i ≠ i') (hj : j ≠ j') : SameMargins u (u + basicMove i i' j j') := by
  constructor <;> intro k <;> simp_all +decide [ rowSum, colSum, Finset.sum_add_distrib ];
  · unfold basicMove; by_cases hk : k = i <;> by_cases hk' : k = i' <;> simp_all +decide ;
  · unfold basicMove; simp +decide [ *, Finset.sum_add_distrib ] ;
    by_cases hi : k = j <;> by_cases hj : k = j' <;> simp_all +decide [ Finset.filter_eq' ]

-- !-- D_eq_zero_iff: the ℓ¹ distance is a sum of natAbs cells, zero iff every cell agrees. -- !--
/-- `D u v = 0` exactly when the tables coincide. -/
theorem D_eq_zero_iff (u v : Table m n) : D u v = 0 ↔ u = v := by
  simp +decide [ funext_iff, D ];
  grind

-- !-- Lab Notebook: exists_good_indices -- !--
-- !-- Hypothesis: u≠v with equal margins ⇒ a 2×2 frame aligned to the sign pattern of u-v -- !--
-- !-- Result: PROVED. Returns i≠i', j≠j' with v i j<u i j, u i j'<v i j', v i' j'<u i' j'. -- !--
-- !-- Insight: total sum of (u-v) is 0 (equal margins) so some cell has u>v; its row sums to 0
--     so some cell in that row has u<v; that column sums to 0 so some cell has u>v -- !--
-- !-- Failure analysis: distinctness of the two rows/columns is *not* a separate hypothesis —
--     it falls out of the opposite signs (a positive and a negative cell cannot coincide),
--     proved by `rintro rfl; linarith`. -- !--
-- !-- End Lab Notebook -- !--

-- !-- exists_good_indices: three-stage pigeonhole — the all-cells sum of u-v is 0 giving a cell
-- with u>v, its row sum is 0 giving a cell with u<v, that column sum is 0 giving u>v again;
-- distinctness of the two rows/columns is forced by the opposite signs. -- !--
/-- **Sign-pattern pigeonhole.** If `u ≠ v` have the same margins, there is a `2 × 2`
configuration `(i,i',j,j')` with `i ≠ i'`, `j ≠ j'` and the sign pattern
`v i j < u i j`, `u i j' < v i j'`, `v i' j' < u i' j'`. -/
theorem exists_good_indices (u v : Table m n) (hm : SameMargins u v) (hne : u ≠ v) :
    ∃ (i i' : Fin m) (j j' : Fin n), i ≠ i' ∧ j ≠ j' ∧
      v i j < u i j ∧ u i j' < v i j' ∧ v i' j' < u i' j' := by
  -- By the pigeonhole principle, there exists a cell $(i,j)$ with $d_{ij} > 0$.
  obtain ⟨i, j, h_pos⟩ : ∃ i j, u i j > v i j := by
    contrapose! hne;
    ext i j; exact le_antisymm ( hne i j ) ( by have := hm.1 i; have := hm.2 j; exact (by
    exact le_of_not_gt fun h => absurd this ( ne_of_lt <| Finset.sum_lt_sum ( fun a _ => by aesop ) ⟨ i, Finset.mem_univ _, h ⟩ )) ) ;
  -- By the pigeonhole principle, there exists a cell $(i,j')$ with $d_{ij'} < 0$.
  obtain ⟨j', h_neg⟩ : ∃ j', u i j' < v i j' := by
    contrapose! hm;
    exact fun h => by have := h.1 i; exact absurd this ( ne_of_gt <| Finset.sum_lt_sum ( fun a _ => by linarith [ hm a ] ) ⟨ j, Finset.mem_univ _, h_pos ⟩ ) ;
  -- By the pigeonho
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: The Full Order Type of the p-Degrees

## Synthesis

The order-theoretic core of the Cook–Reckhow program in this catalog has, over successive
cycles, been assembled from the simulation preorder `Simulates` on abstract proof systems
(`Catalog/Logic/ProofComplexity/SimulationPreorder.lean`) and its quotient, the **poset of
p-degrees** `Antisymmetrization (ProofSystem ℕ) (· ≤ ·)`. Earlier cycles proved the
qualitative skeleton: a `Preorder`/`Setoid` structure, the master reduction
`simulates_sysOfSize_iff` (simulation between size-indexed systems is *exactly* polynomial
domination of their size functions), infinite **height** (`powSystem_strictMono`), infinite
**width** (`spikeSys_isAntichain`), a **bottom** (`zeroSys_isBot`), **no top** (`no_top`),
binary **meets** (`isGLB_sumSystem`), and local **density** at two places
(`exists_strictly_between_lin_fib`, `exists_strictly_between_powSystem`).

This cycle (`Catalog/Logic/ProofComplexity/OrderEmbedding.lean`) sharpened that skeleton
from *qualitative facts* to *concrete embedded suborders*:

- **`powSystem_orderEmbedding`** upgrades "infinite height" to a genuine order embedding
  `ℕ ↪o (p-degrees)`: the p-degrees literally contain `(ℕ, ≤)`.
- **`spikeSys_bounded_antichain`** shows the infinite spike antichain is *order-bounded* —
  trapped strictly between `zeroSys` and the single degree `powSystem 2`. Infinite width is
  therefore present *arbitrarily low* in the order, not banished to infinity.
- **`powSystem_two_bounds_lin_fib_chain`** places the Fibonacci density 3-chain
  `linSystem < interSys < fibSystem` under the *same* ceiling `powSystem 2`. Height and
  width thus coexist inside one finite-height interval `(⊥, powSystem 2]`.
- **`pdegrees_order_type_summary`** bundles the embedded `ℕ`-chain, an incomparable pair,
  the absence of a top, and the bottom into one statement.

The unifying lesson — the "homotopy-invariant" content, in the spirit of working with the
poset up to p-equivalence (the natural notion of *equivalence* in this localization) — is
that the right invariant is the **growth rate of the size function up to polynomial
re-parameterization**, and every structural feature (chains, antichains, gaps, bounds)
reduces, via `simulates_sysOfSize_iff`, to elementary arithmetic of growth rates. The four
directions below push this from "the p-degrees contain ℕ and a bounded antichain" toward a
full identification of the order type.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `powSystem_orderEmbedding` | `ℕ ↪o` p-degrees | proved, `sorry = 0` |
| `spikeSys_bounded_antichain` | bounded infinite antichain in `(⊥, powSystem 2]` | proved, `sorry = 0` |
| `powSystem_two_bounds_lin_fib_chain` | density 3-chain also `≤ powSystem 2` | proved, `sorry = 0` |
| `pdegrees_order_type_summary` | embedded ℕ-chain + incomparable pair + no top + bottom | proved, `sorry = 0` |

All depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research Direct
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
