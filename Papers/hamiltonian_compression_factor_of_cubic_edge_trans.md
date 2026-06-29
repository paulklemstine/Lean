# Theorem Trace — Hamiltonian Compression Factor of Cubic Edge-Transitive Graphs

This internal file maps every Lean name from the Phase A output to its
mathematical statement and records where it is discussed in `ARTICLE.md` and
`RESEARCH_PAPER.md`. No result outside this list is claimed anywhere in the
package.

## Definitions / structures (file: `Defs.lean`)

| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `diam` | `diam n = (n/2 : ZMod n)`, the diameter element. | "the half-turn step" | Def. 2.1 |
| `MLAdj` | `MLAdj n a b ↔ a-b = 1 ∨ a-b = -1 ∨ a-b = diam n`; the Möbius-ladder circulant adjacency with connection set `{±1, n/2}`. | "the wiring rule" | Def. 2.2 |
| `TwoSymHamCycle` | A structure bundling `order : ZMod n ≃ ZMod n`, `auto : ZMod n ≃ ZMod n`, with `consecutive`, `preserves`, `involutive`, `nontrivial`, `rotation`. It is the witness for `κ(Γ) ≥ 2`. | "what a 2-symmetric cycle is" | Def. 2.3 |

## Supporting arithmetic lemmas (file: `Defs.lean`)

| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `two_mul_diam` | `Even n → (2 : ZMod n) * diam n = 0`. | "two half-turns cancel" | Lemma 3.1 |
| `neg_diam` | `Even n → -diam n = diam n`. | "the half-turn is its own reverse" | Lemma 3.2 |
| `diam_ne_zero` | `4 ≤ n → diam n ≠ 0`. | "a real, nontrivial swap" | Lemma 3.3 |

## Main theorems (file: `MobiusLadder.lean`)

| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `mobiusLadder_twoSymmetric` | For even `n ≥ 4`, `Nonempty (TwoSymHamCycle n (MLAdj n))`. | Main theorem (plain language) | Theorem 4.1 |
| `mobiusLadder_cubic` | For even `n ≥ 4` and any `a`, `(univ.filter (MLAdj n a ·)).card = 3`. | "every junction has three roads" | Theorem 4.2 |

## Base-case instances (file: `Instances.lean`)

| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `MLAdj_four_eq_complete` | `MLAdj 4 a b ↔ a ≠ b` (i.e. `ML(4) = K₄`). | "the smallest example" | Prop. 5.1 |
| `MLAdj_six_eq_completeBipartite` | `MLAdj 6 a b ↔ a.val % 2 ≠ b.val % 2` (i.e. `ML(6) = K_{3,3}`). | "the utility graph" | Prop. 5.2 |
| `K4_kappa_ge_two` | `Nonempty (TwoSymHamCycle 4 (MLAdj 4))`. | base case κ(K₄) ≥ 2 | Cor. 5.3 |
| `K33_kappa_ge_two` | `Nonempty (TwoSymHamCycle 6 (MLAdj 6))`. | base case κ(K₃,₃) ≥ 2 | Cor. 5.4 |
| `K4_cubic` | `(univ.filter (MLAdj 4 a ·)).card = 3`. | K₄ is cubic | Cor. 5.5 |
| `K33_cubic` | `(univ.filter (MLAdj 6 a ·)).card = 3`. | K₃,₃ is cubic | Cor. 5.6 |
