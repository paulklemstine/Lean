# Computational Evidence — Finite model property with an explicit bound (Temporal Gödel–Löb logic)

All numbers below were produced by `#eval` inside Lean against the definitions in
`Catalog/Logic/PosetTheory/TemporalGLSyntax.lean` (they are computations on the actual
`subformulas` / `subformulaCount` / `TForm.size` definitions used in the theorems, not
hand calculations). Countermodel sizes marked "verified" are backed by sorry-free Lean
theorems, not by scratch computation.

## 1. Small-case calculations: the bound on concrete formulas

Notation: `p = atom 0`, `q = atom 1`, `◻` = provability box, `◼` = temporal "always".

| # | Formula `A` | `subformulaCount A` | `A.size` | `2 ^ n` | `2 ^ (2n)` |
|---|-------------|--------------------:|---------:|--------:|-----------:|
| 1 | `◻⊥ ⟹ ⊥` (consistency) | 3 | 4 | 8 | 64 |
| 2 | `◻(◻p ⟹ p) ⟹ ◻p` (Löb) | 5 | 8 | 32 | 1024 |
| 3 | `◻p ⟹ ◼◻p` (interaction) | 4 | 6 | 16 | 256 |
| 4 | `◼p ⟹ ◻p` (independence) | 4 | 5 | 16 | 256 |
| 5 | `◻p ⟹ ◻◻p` (axiom 4) | 4 | 6 | 16 | 256 |
| 6 | `◻(p ⟹ q) ⟹ (◻p ⟹ ◻q)` (K) | 8 | 10 | 256 | 65536 |

Observation used in the formalisation: `subformulaCount A ≤ A.size` in every row. This
is not an accident of the sample — it is proved in general as
`TemporalGLDeep.subformulaCount_le_size`, so the finite-model bound stated with
`subformulaCount` also holds for the "number of nodes" reading of the phrase.

## 2. Counterexample hunt against the universal claim

The conjecture is universal over non-derivable formulas, so the honest test is to look
for a formula that is non-derivable yet needs *more* than `2 ^ (2 * subformulaCount A)`
worlds. The search terminated in the strongest possible way: the canonical-model
construction shows that `2 ^ subformulaCount A` worlds always suffice, i.e. the square
root of the conjectured bound. No counterexample can exist. This is
`TemporalGLDeep.finite_model_property_sharp`.

Formulas 2, 3, 5, 6 in the table are *derivable* (they are axioms or, for row 5,
`derivable_four`), so the conjecture says nothing about them. Rows 1 and 4 are
non-derivable, verified in Lean by exhibiting explicit countermodels
(`not_derivable_own_consistency`, `not_derivable_glob_imp_box`).

## 3. How loose is the bound? (verified minimal countermodels)

| Formula | permitted `2 ^ (2n)` | permitted `2 ^ n` | actual verified countermodel |
|---------|---------------------:|------------------:|-----------------------------:|
| `◻⊥ ⟹ ⊥` | 64 | 8 | **1 world** (`consistency_countermodel_one_world`) |
| `◼p ⟹ ◻p` | 256 | 16 | **2 worlds** (`glob_box_countermodel_two_worlds`) |

Both entries are Lean theorems with `Nat.card` of the world type computed exactly, so
the gap between the conjectured bound and reality is machine-checked, not estimated.
This gap is the empirical seed for the first two conjectures in `FUTURE_DIRECTIONS.md`.

## 4. Structural data extracted during the experiments

* The filtration measure. Every `filtR`-step strictly increases the number of realised
  boxed subformulas (`filtR_measure_lt`). Hence any `R`-chain in a filtered or canonical
  model has length at most `#{◻B ∈ subformulas A}`, which for rows 1–6 above is
  1, 2, 2, 1, 2, 3 respectively. The *depth* of the countermodels is therefore tiny
  compared with the exponential bound on their *width*.
* The temporal relation contributes no depth at all: `filtT` is a preorder, so the
  temporal dimension only ever adds a reflexive-transitive clustering on top of the
  strictly increasing `◻`-chains.

## 5. OEIS

No new integer sequence arises: the quantities appearing are `2 ^ n` and `2 ^ (2n)`
(A000079 and its even-index subsequence A000302), which are the trivial powers-of-two
sequences and carry no additional information here. No OEIS lookup was needed.
