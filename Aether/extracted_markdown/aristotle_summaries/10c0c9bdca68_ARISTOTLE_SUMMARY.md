# Summary of changes for run c0228aea-1cd5-44b1-8209-17c6a5d5eaf9
## Asymmetric Duration Games (ADGs) — Lean 4 Formalization

### Deliverables

**Lean file**: `Catalog/Shared/AsymDurationGames.lean` — 150 lines, zero `sorry`, zero warnings, compiles cleanly.

**FUTURE_DIRECTIONS.md** — 5 research directions with conjectures, tests, and justifications.

### Theorems Proved (all verified, 0 sorry)

1. **ω-Survival on Infinite Types** (`omega_survival_infinite`): On any infinite type α with decidable equality, for any n rounds and any adversary schedule of finite banned sets, Mortal has an injective evasion sequence. Proved by induction on n, extending partial solutions using the infinite complement of (used positions ∪ current banned set).

2. **Ascending Strategy Correctness** (`ascending_strict_mono`, `ascending_avoids`, `ascending_lower_bound`): The ascending strategy on ℕ — defined by `ascendingStrat banned 0 = sup(banned 0) + 1` and `ascendingStrat banned (n+1) = max(prev, sup(banned(n+1))) + 1` — is strictly monotone (hence injective), avoids all bans, and satisfies `ascendingStrat banned n ≥ n + 1`.

3. **Diagonal Lemma** (`diagonal_lemma`): No finite family of k deterministic sequences can evade every adversary. For any k strategies, there exists an adversary catching each one — constructed by having the adversary at round t ban the prediction of strategy (t mod k), catching strategy i at round i.

4. **Finite Type Tight Bound** (`finite_type_tight_bound`): On `Fin (n+1)`, the adversary can force evasion failure in `n+1` rounds by banning {0} every round. Any injective function `Fin (n+1) → Fin (n+1)` is a bijection, hence surjective, so some position must equal 0 — contradicting the avoidance condition.

### Key Definitions

- `EvasionProblem α n` — adversary's schedule: at each of n rounds, a finite banned set from α
- `EvasionSolution prob` — Mortal's response: an injective sequence avoiding all bans  
- `ascendingStrat` — the canonical ascending strategy on ℕ

### Axioms Used

All theorems depend only on standard axioms: `propext`, `Classical.choice`, `Quot.sound`.