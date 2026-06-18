# Summary of changes for run 5fca431f-7fa7-4675-8bc3-115af41f8fd0
## Phase A deliverables — complete and verified

I extended the project's proof-theoretic ordinal framework (`Catalog/Pythagorean/ProofTheoreticOrdinals.lean` and `ProofTheoreticOrdinalsLattice.lean`, which define `OrdinalTheory`, `pto`, and `ofOrdinal`) by connecting its previously abstract `Ordinal` framework to the concrete proof-theoretic landmarks **ε₀** and **Γ₀**, via Mathlib's Veblen/epsilon API.

### New Lean file: `Catalog/Pythagorean/ProofTheoreticOrdinalsEpsilon.lean`
The file compiles cleanly (verified through the Lean LSP) with **0 `sorry`, 0 `axiom`, and no disallowed automation** on any result. It introduces the unifying notion of **exponential closure** (`ExpClosed`: the set of provably-well-ordered ordinals is closed under `α ↦ ω^α`) and proves, among 17 theorems, four headline results:

1. **`expClosed_ofOrdinal_iff_isFixed`** — for a *limit* theory `ofOrdinal α`, exponential closure is *exactly* the ε-number equation `ω^α = α` (proved from normality: `opow_le_of_isSuccLimit`, `right_le_opow`, strict monotonicity).
2. **`epsilon0_is_least_expClosed_pto`** (the **ε₀ barrier**) — `ε₀` is the *least* proof-theoretic ordinal of an exponentially-closed limit theory; combined with `pto_ofOrdinal_epsilon0` (its PTO is exactly `ε₀`).
3. **Boundary triple** (`expClosed_succ_epsilon0`, `not_isLimitTheory_succ_epsilon0`, `not_isFixed_succ_epsilon0`) — shows the limit hypothesis in result 1 is essential: `ofOrdinal (ε₀+1)` is exponentially closed yet is not a limit theory and `ω^(ε₀+1) ≠ ε₀+1`.
4. **Cross-domain bridge** `pto_lt_pto_epsilon0_gamma0` — strict inclusion of the ε₀-theory into the Feferman–Schütte Γ₀-theory strictly raises the PTO, locating the ε₀ barrier strictly below the predicative barrier Γ₀ (en route, `omega0_opow_gamma0` proves Γ₀ is itself an ε-number).

Each theorem carries a one-to-two-sentence proof sketch in `-- !-- … -- !--` comment blocks, plus `example` sanity checks at the end. Note: these catalog files are reference modules outside the lake build path (as the existing lattice file documents), so the minimal core (`OrdinalTheory`, `pto`, `ofOrdinal`, `pto_monotone`, `pto_ofOrdinal_limit`) is reproduced in Section 0 and the file is self-contained on `import Mathlib`.

### `Catalog/Pythagorean/FUTURE_DIRECTIONS.md`
A freeform narrative with 5 testable, falsifiable conjectures extending the work (the Veblen/Γ₀ barrier analogue, a normal-function abstraction `ClosedUnder f` subsuming both barriers, a complete-sublattice structure for exponentially-closed theories, an exact `depthDist` computation between barriers, and a finite-tower reflection characterization of ε₀). Each includes a "The key insight is…" sentence and a "Why now?" justification citing the specific Mathlib lemmas that make it immediately approachable.