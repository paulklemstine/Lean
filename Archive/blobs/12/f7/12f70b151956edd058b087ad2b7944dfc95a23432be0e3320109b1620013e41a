# Summary of changes for run e7d859bc-c599-44bd-b937-07ebfea5f65d
Added a single self-contained Lean 4 file, `Catalog/Speculative/PolyGrowthDensity.lean`, formalizing strict density between consecutive polynomial-growth systems under eventual domination. It compiles cleanly against the project's Mathlib (verified by a full `lake build` of the module) and is `sorry`-free; the main theorems depend only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`.

Contents (all in namespace `PolyGrowthDensity`):
- `structure PSystem` with the single field `size : ℕ → ℕ`.
- `SimLe` (`≼`): eventual domination, `∃ N, ∀ n ≥ N, S.size n ≤ T.size n`, with `SimLe.refl` and `SimLe.trans`, plus scoped `≼`/`≺` notation.
- `SimLt` (`≺`): strict comparison `S ≼ T ∧ ¬ T ≼ S`.
- `powSystem k` (`size n = n^k`) and the parity-glued witness `interPowSys k` (`n^(k+1)` on even `n`, `n^k` on odd `n`).
- Two elementary helper inequalities: `le_pow_succ` (`n^k ≤ n^(k+1)` for `k ≥ 1`) and `pow_lt_pow_succ` (`n^k < n^(k+1)` for `n ≥ 2`).
- The two domination directions (threshold `N = 0`): `powSystem_simLe_interPowSys` and `interPowSys_simLe_powSystem`.
- The two non-domination statements, proved by contradiction from an arbitrary threshold `N` using an explicit even witness `2 * max N 1` and odd witness `2 * max N 1 + 1`: `not_interPowSys_simLe_powSystem` and `not_powSystem_simLe_interPowSys`.
- The main theorem `powSystem_simLt_interPowSys_simLt_powSystem`: for `k ≥ 1`, `powSystem k ≺ interPowSys k ∧ interPowSys k ≺ powSystem (k+1)`; and the corollary `exists_intermediate`: `∃ U, powSystem k ≺ U ∧ U ≺ powSystem (k+1)`.

The file includes concise module documentation explaining the model and the parity-gluing idea. Note: the two non-domination statements were found not to require the `1 ≤ k` hypothesis; since the requested statements were phrased "for k ≥ 1", the hypothesis is kept and the docstrings note that it is unnecessary for those two directions (this is the source of two harmless `unused variable hk` linter warnings).