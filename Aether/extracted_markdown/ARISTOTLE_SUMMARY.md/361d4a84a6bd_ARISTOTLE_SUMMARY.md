# Summary of changes for run 1f93e9e9-821c-4b92-9074-ddbb8a4d0003
Created `Catalog/Cryptography/AdditiveCAComplexityThreshold.lean`, a complete standalone Lean 4 file formalizing the exact row-complexity formula for the additive cellular automaton Rule 90. The file compiles cleanly (no `sorry`, no warnings) and every theorem depends only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`.

Definitions (in namespace `AdditiveCA`):
- `complexity t = #{k ∈ Finset.range (t+1) | Odd (Nat.choose t k)}` — the number of live cells in the Rule 90 row at time `t`.
- `popcount t = (Nat.digits 2 t).sum` — the number of `1`-bits in the binary expansion of `t`.

Main results:
- `complexity_eq_two_pow_popcount : complexity t = 2 ^ popcount t` — the exact closed form (the file's core contribution).
- `complexity_pow_two : complexity (2 ^ k) = 2` — every power of two gives a maximally sparse row (holds for all `k`, including `k = 0`).
- `complexity_mersenne : complexity (2 ^ k - 1) = 2 ^ k` — every Mersenne time gives a full row.
- `complexity_mersenne_full : complexity (2 ^ k - 1) = (2 ^ k - 1) + 1` — the arithmetic "full row" restatement (`complexity t = t + 1`).
- `sparse_rows_infinite` and `full_rows_infinite` — for every `N` there are times `t > N` with `complexity t = 2` and with `complexity t = t + 1`, two unbounded interleaved families that refute any naive monotone complexity-threshold formulation.

Proof strategy: a single-digit instance of Mathlib's Lucas theorem at prime 2 gives the parity recursion `odd_choose_iff : Odd (choose t k) ↔ k % 2 ≤ t % 2 ∧ Odd (choose (t/2) (k/2))`. From it, `complexity` satisfies the binary recursions `complexity (2t) = complexity t` and `complexity (2t+1) = 2·complexity t` (via Finset bijection/disjoint-image counting), matching the recursions of `2 ^ popcount`; strong induction then yields the closed form. The power-of-two and Mersenne corollaries follow from `popcount (2^k) = 1` and `popcount (2^k - 1) = k`.

A module docstring explains the Rule 90 interpretation, and every informal sentence in it is backed by a formal theorem in the file. The file lives in the project's `Cryptography` library (module `Cryptography.AdditiveCAComplexityThreshold`) and builds successfully on its own.