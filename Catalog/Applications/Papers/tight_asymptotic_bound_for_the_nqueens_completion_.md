# Theorem Trace (internal anti-hallucination ledger)

Every claim in ARTICLE.md / RESEARCH_PAPER.md must map to one of the following
names from the Phase A Lean output. No other named results are asserted.

## Definitions
- `antiDiag (a) := a.1.val + a.2.val : ℤ` — anti-diagonal index (row + col), non-wrapping.
- `mainDiag (a) := a.1.val - a.2.val : ℤ` — main-diagonal index (row − col), non-wrapping.
- `Attacks a b := a.1 = b.1 ∨ a.2 = b.2 ∨ antiDiag a = antiDiag b ∨ mainDiag a = mainDiag b`.
- `NonAttacking Q := ∀ a ∈ Q, ∀ b ∈ Q, a ≠ b → ¬ Attacks a b`.
- `IsFullSolution Q := NonAttacking Q ∧ Q.card = n`.
- `Completable Q := ∃ F, IsFullSolution F ∧ Q ⊆ F`.
- `diagGraph b := univ.image (fun x => (x, 2*x + b))` (the slope-2 toroidal line).

## Lemmas / Theorems (with statements)
- `NonAttacking.col_unique` : in a non-attacking set, (r,c),(r,c') ∈ Q ⇒ c = c'.
- `NonAttacking.row_unique` : in a non-attacking set, (r,c),(r',c) ∈ Q ⇒ r = r'.
- `mem_diagGraph` : p ∈ diagGraph b ↔ p.2 = 2*p.1 + b.
- `isUnit_two` : Nat.Coprime n 6 → IsUnit (2 : ZMod n).
- `isUnit_three` : Nat.Coprime n 6 → IsUnit (3 : ZMod n).
- `diagGraph_card` : (diagGraph b).card = n.
- `diagGraph_isFullSolution` : Nat.Coprime n 6 → IsFullSolution (diagGraph b).
- `exists_full_solution` : Nat.Coprime n 6 → ∃ Q, IsFullSolution Q.
- `single_queen_completable` : Nat.Coprime n 6 → ∀ r c, Completable {(r,c)}.
- `infinitely_many_coprime_six` : {n | Nat.Coprime n 6}.Infinite.

## Documented-but-relaxation result (stated in the file's module docstring)
- `completion_relaxation` : if `5 * #Q ≤ n` and Q non-attacking, Q extends to a
  permutation placement with no row/column/diagonal conflict between a NEW queen and
  an OLD queen (bipartite Hall relaxation; does NOT preclude new-new diagonal clashes).
  Constant 1/5 = 0.2. Described in module documentation; presented honestly as a
  relaxation, not as the full completion theorem.

## NOT proved (must be flagged as conjecture/open in prose)
- `limsup qc(n)/n = 0.216` (the headline conjecture; constant 27/125).
- Glock–Munhá Correia–Sudakov full linear completion theorem.
- The full reachability / threshold lemmas referenced only in Future Directions
  (`nonAttacking_extend`, `exists_nonAttacking_third`, etc.) are NOT in the supplied
  file body and are mentioned only as future directions.
