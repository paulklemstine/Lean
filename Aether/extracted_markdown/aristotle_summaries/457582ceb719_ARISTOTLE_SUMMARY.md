# Summary of changes for run 1371ac8c-4f4c-4cdf-85f2-15c9964879b7
Created `Catalog/Logic/ProofComplexity/LadderDensity.lean`, a complete, self-contained Lean 4 file proving density of the `powSystem` exponential ladder in the proof-complexity degree order. No `sorry`s, no warnings; the headline results depend only on the standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

Note: the catalog did not actually contain a prior `powSystem`/`sysOfSize`/`simulates_sysOfSize_iff` framework (the prompt referenced one that was absent), so I built the needed size-system layer from scratch in the Cook–Reckhow style of the existing `Logic/ProofSystemCollapse.lean`, staying entirely in the proof-complexity domain.

What the file contains:
- `SizeSys`: a size system as a size-vs-input-length function `ℕ → ℕ`.
- `Dom` / `instance : Preorder SizeSys`: the polynomial-domination (Cook–Reckhow polynomial-simulation) preorder `S ≤ T ↔ ∃ c d, ∀ n, S n ≤ c·(T n + 1)^d`, with reflexivity and transitivity (monomial-bound composition). Its strict part `<` is the degree strict order.
- `powSystem k := fun n => 2 ^ (n ^ k)`: the canonical ladder.
- `interPowSys k`: the explicit parity-glued witness — faster rate `2^(n^(k+1))` on even inputs, slower rate `2^(n^k)` on odd inputs.
- Reusable growth-gap lemmas: `poly_dom` (eventually `a + b·n^j < n^m` when `j < m`) and the decisive `eventually_gap` (eventually `c·(2^(n^j)+1)^d < 2^(n^m)` when `j < m`).

Final theorems (matching the requested shape):
- `powSystem_le_interPowSys (k) (1 ≤ k)`
- `not_interPowSys_le_powSystem (k)` (even subsequence separation)
- `interPowSys_le_powSystem_succ (k)`
- `not_powSystem_succ_le_interPowSys (k)` (odd subsequence separation)
- `powSystem_lt_interPowSys (k) (1 ≤ k)`
- `interPowSys_lt_powSystem_succ (k)`
- `ladder_dense (k) (1 ≤ k) : ∃ S, powSystem k < S ∧ S < powSystem (k + 1)`

Two of the four directional facts and one strict inequality turned out not to need `1 ≤ k`, so I stated them in their stronger hypothesis-free form (noted in their docstrings); `1 ≤ k` is genuinely required for the lower-bound dominance and is kept on `ladder_dense` exactly as requested.

The new module builds successfully in isolation. (A pre-existing unrelated broken reference under `Algebra/SumThreeCubes/` prevents a full default-target build, but it is independent of this work.)