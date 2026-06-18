# Summary of changes for run 0420cd26-743a-476d-9041-bca2b4b19772
Created `Catalog/Bridges/BerggrenMatrix.lean`, a self-contained file (importing only `Mathlib`) formalizing a submultiplicative row-sum norm for the Berggren matrices and the resulting depth/hypotenuse bounds. All proofs are complete with no `sorry`, and every theorem depends only on the standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

Definitions provided:
- `Berggren.A`, `Berggren.B`, `Berggren.C : Matrix (Fin 3) (Fin 3) ℤ` with their standard entries.
- `rowNorm M = max_i ∑_j |M i j|` (via `Int.natAbs`, valued in ℕ) and an auxiliary `vecNorm v = max_j |v j|`.
- `Generator` (inductive A/B/C), `genMatrix`, and `wordMatrix w = (w.map genMatrix).prod`.
- `root = (3,4,5)` and `hypotenuse v = v 2`.

Theorems proved:
1. `rowNorm_mul_le` — submultiplicativity `rowNorm (M*N) ≤ rowNorm M * rowNorm N` (plus the helper `matVec_natAbs_le : |(M *ᵥ v) i| ≤ rowNorm M * vecNorm v`).
2. `generator_norms` — explicit finite computation (`decide`).
3. `rowNorm_wordMatrix_le` — `rowNorm (wordMatrix w) ≤ 7 ^ w.length` (induction using 1 and 2).
4. `hyp_of_word_le` — `hypotenuse (wordMatrix w *ᵥ root) ≤ 7 ^ w.length * 5`.
5. `depth_bound` — `Nat.log2 |hypotenuse (wordMatrix w *ᵥ root)| ≤ 3 * w.length + 3`.

Two numerical claims in the brief were incorrect and have been corrected (and documented in the module docstring), with the corrected statements proved in full:
- The brief's `rowNorm ≤ 2` is wrong: each generator actually has row-sum norm 7 (the bottom row (2,2,3) alone sums to 7). All bounds therefore use base 7 rather than 2.
- The brief's `depth_bound` direction (`w.length ≤ log₂(hyp) + C`) is false: the generator A is parabolic (its only eigenvalue is 1), so iterating A grows the hypotenuse only linearly in the depth (e.g. depth 100 gives hypotenuse 20605). What the submultiplicative row-norm machinery genuinely yields, by rearranging the hypotenuse upper bound, is the reverse inequality on bit-length, `Nat.log2 |hyp| ≤ 3·w.length + 3` (equivalently `w.length ≥ (log₂|hyp| − 3)/3`), which is what is proved.

The file compiles cleanly (`lake env lean Catalog/Bridges/BerggrenMatrix.lean`).