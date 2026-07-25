import Mathlib

/-!
# Oracle Counting Barrier — Extensions

This file extends `Computation/OracleCountingBarrier.lean` along two of the research
directions the foundational file opened:

* **Constructive diagonalization** (`oracle_diagonal_escape`): when the program space is
  the *index set itself* (`Fin N` descriptions for `N` statements), the escaping oracle
  is produced *explicitly* by a Cantor-style diagonal — no pigeonhole, no `by_contra`.
  Works for any alphabet with at least two verdicts.

* **Composition amplifies the gap — a finite Turing jump** (`oracle_comp_card`,
  `oracle_comp_jump`, `oracle_comp_budget_gap`): the space of oracle-to-oracle maps has
  cardinality `3 ^ (N · 3 ^ N)`, strictly larger than the evaluation space `3 ^ N` for
  every `N ≥ 1`, and it outruns every fixed program budget. Composing oracles is
  strictly costlier to describe than evaluating them — a fully constructive, finite
  analogue of the Turing jump, exhibited by a bare cardinal inequality.

* **Robustness to logical structure** (`consistent_oracles_escape`): the barrier
  survives *any* consistency constraint that still admits an independent `3`-valued
  block of size `k`. If the consistent oracles contain an injective copy of
  `Fin k → Fin 3` and the program space has fewer than `3 ^ k` elements, some
  *consistent* oracle escapes every compilation. Adding logical structure does not
  restore computability.

The module is self-contained (it re-states the one-line `Oracle` abbreviation and the
base count) so that it compiles independently; the mathematical lineage is the
foundational file `OracleCountingBarrier.lean`.
-/

namespace OracleBarrier

/-- A three-valued oracle on `N` statements (mirrors `Oracle` in the foundation file). -/
abbrev Oracle (N : ℕ) := Fin N → Fin 3

/-- There are exactly `3 ^ N` three-valued oracles on `N` statements
(`oracle_card` in the foundation file). -/
theorem oracle_card (N : ℕ) : Fintype.card (Oracle N) = 3 ^ N := by
  simp [Oracle]

/-- The growth lemma `budget_gap_exists` from the foundation file. -/
theorem budget_gap_exists (b k : ℕ) : ∃ N, b ^ k < 3 ^ N :=
  pow_unbounded_of_one_lt (b ^ k) (by norm_num)

-- !-- comment -- !--
-- Cantor diagonal: define `g i := (f i i + 1) mod a`. Then `g` differs from the `i`-th
-- description at coordinate `i`, so no description equals it. Case-split on whether
-- `f i i + 1 < a` (no wraparound) or `= a` (wraps to `0`) to evaluate the mod, since
-- `omega` cannot reason about a variable modulus.
-- !-- comment -- !--
/-- **Constructive diagonal escape.** For any alphabet with at least two verdicts, given
`N` descriptions `f : Fin N → (Fin N → Fin a)` of oracles on `N` statements, an escaping
oracle is built *explicitly* by diagonalization: it disagrees with the `i`-th
description at coordinate `i`. -/
theorem oracle_diagonal_escape {N a : ℕ} (ha : 2 ≤ a)
    (f : Fin N → (Fin N → Fin a)) :
    ∃ g : Fin N → Fin a, ∀ i, f i ≠ g := by
  refine ⟨fun i => ⟨((f i i : ℕ) + 1) % a, Nat.mod_lt _ (by omega)⟩, ?_⟩
  intro i hi
  have hval : (f i i : ℕ) = ((f i i : ℕ) + 1) % a := by
    have := congrFun hi i
    simpa [Fin.ext_iff] using this
  have hlt : (f i i : ℕ) < a := (f i i).isLt
  rcases lt_or_eq_of_le (Nat.succ_le_of_lt hlt) with h | h
  · have h' : (f i i : ℕ) + 1 < a := h
    rw [Nat.mod_eq_of_lt h'] at hval; omega
  · have h' : (f i i : ℕ) + 1 = a := h
    rw [h', Nat.mod_self] at hval; omega

-- !-- comment -- !--
-- Counting oracle-to-oracle maps: `card (Oracle N → Oracle N) = (3 ^ N) ^ (3 ^ N)`
-- by `Fintype.card_fun` and `oracle_card`, and `(3 ^ N) ^ (3 ^ N) = 3 ^ (N · 3 ^ N)`
-- by collapsing the power tower with `pow_mul`.
-- !-- comment -- !--
/-- The composition space of oracle-to-oracle maps has cardinality `3 ^ (N · 3 ^ N)`. -/
theorem oracle_comp_card (N : ℕ) :
    Fintype.card (Oracle N → Oracle N) = 3 ^ (N * 3 ^ N) := by
  rw [Fintype.card_fun, oracle_card, ← pow_mul]

-- !-- comment -- !--
-- Finite jump: evaluation space `3 ^ N` is strictly below composition space
-- `3 ^ (N · 3 ^ N)` because `N < N · 3 ^ N` for `N ≥ 1` (as `3 ^ N ≥ 2`); apply strict
-- monotonicity of `3 ^ ·`.
-- !-- comment -- !--
/-- **The finite Turing jump.** For `N ≥ 1`, the evaluation space is strictly smaller
than the composition space: composing oracles is strictly costlier to describe than
evaluating them. -/
theorem oracle_comp_jump {N : ℕ} (hN : 1 ≤ N) :
    Fintype.card (Oracle N) < Fintype.card (Oracle N → Oracle N) := by
  rw [oracle_card, oracle_comp_card]
  apply Nat.pow_lt_pow_right (by norm_num)
  have h3 : 2 ≤ 3 ^ N := by
    calc 2 ≤ 3 ^ 1 := by norm_num
    _ ≤ 3 ^ N := Nat.pow_le_pow_right (by norm_num) hN
  nlinarith [Nat.one_le_iff_ne_zero.mpr (show N ≠ 0 by omega)]

-- !-- comment -- !--
-- Composition outruns every fixed budget: pick `N` with `b ^ k < 3 ^ N` (growth lemma),
-- then `3 ^ N ≤ 3 ^ (N · 3 ^ N) = card`.
-- !-- comment -- !--
/-- The composition space outruns every fixed program budget `b ^ k`. -/
theorem oracle_comp_budget_gap (b k : ℕ) :
    ∃ N, b ^ k < Fintype.card (Oracle N → Oracle N) := by
  obtain ⟨N, hN⟩ := budget_gap_exists b k
  refine ⟨N, ?_⟩
  rw [oracle_comp_card]
  calc b ^ k < 3 ^ N := hN
  _ ≤ 3 ^ (N * 3 ^ N) :=
      Nat.pow_le_pow_right (by norm_num) (Nat.le_mul_of_pos_right N (by positivity))

-- !-- comment -- !--
-- Robustness via the generic barrier: the consistent oracles contain an injective image
-- of `Fin k → Fin 3`, hence at least `3 ^ k` of them; a program space of size `< 3 ^ k`
-- has range too small to cover that image, so some consistent oracle escapes
-- (pigeonhole on Finset cardinalities).
-- !-- comment -- !--
/-- **Robustness to consistency constraints.** Suppose the consistent oracles (those
satisfying a predicate `C`) contain an injective copy `emb` of an independent
`3`-valued block `Fin k → Fin 3`. Then any program space with fewer than `3 ^ k`
descriptions fails to cover them: some *consistent* oracle escapes every compilation.
Adding logical structure does not restore computability. -/
theorem consistent_oracles_escape {P : Type*} [Fintype P] {N k : ℕ}
    (C : Oracle N → Prop)
    (emb : (Fin k → Fin 3) → Oracle N) (hemb : Function.Injective emb)
    (hC : ∀ x, C (emb x))
    (f : P → Oracle N) (hcard : Fintype.card P < 3 ^ k) :
    ∃ g : Oracle N, C g ∧ ∀ p, f p ≠ g := by
  classical
  set A : Finset (Oracle N) := Finset.univ.image emb with hA
  set B : Finset (Oracle N) := Finset.univ.image f with hB
  have hcardA : A.card = 3 ^ k := by
    rw [hA, Finset.card_image_of_injective _ hemb, Finset.card_univ]
    simp
  have hcardB : B.card ≤ Fintype.card P := by
    rw [hB]; exact le_trans (Finset.card_image_le) (by simp [Finset.card_univ])
  have hnsub : ¬ A ⊆ B := by
    intro hsub
    have := Finset.card_le_card hsub
    omega
  obtain ⟨a, haA, haB⟩ := Finset.not_subset.mp hnsub
  rw [hA, Finset.mem_image] at haA
  obtain ⟨x, _, hx⟩ := haA
  refine ⟨a, hx ▸ hC x, ?_⟩
  intro p hp
  apply haB
  rw [hB, Finset.mem_image]
  exact ⟨p, Finset.mem_univ p, hp⟩

end OracleBarrier

/-!
## Lab Notebook

-- !-- Lab Notebook -- !--

**Hypothesis.** The nonconstructive coverage barrier should have a *constructive* core
when the program space is the index set, and the barrier should *amplify* under
composition and *survive* logical-consistency constraints.

**Result.** All three confirmed. (1) `oracle_diagonal_escape` produces the escaping
oracle by an explicit diagonal flip, valid for any alphabet `a ≥ 2`. (2) The composition
count is the exact power tower `3 ^ (N · 3 ^ N)` (`oracle_comp_card`); it strictly
dominates `3 ^ N` for `N ≥ 1` (`oracle_comp_jump`) and outruns any fixed budget
(`oracle_comp_budget_gap`) — a finite Turing jump with no appeal to the halting
problem. (3) `consistent_oracles_escape` shows a `3 ^ k` independent block inside the
consistent oracles already defeats any sub-`3 ^ k` program space.

**Insight.** The composition jump is *purely cardinal*: `card_fun` applied twice turns
the evaluation count `3 ^ N` into `3 ^ (N · 3 ^ N)`. The exponent `N · 3 ^ N` grows
faster than any fixed `b ^ k`, so the jump is automatic. The robustness theorem reveals
that the only thing a consistency relation can do to defeat the barrier is shrink the
independent block below logarithmic size — anything leaving a linear antichain keeps the
barrier biting.

**Failure analysis.** The diagonal proof exposed a sharp tooling limit: `omega` does not
reason about `(m + 1) % a` for a *variable* modulus `a`. The fix was to case-split on
`m + 1 < a` versus `m + 1 = a`, evaluating the modulus by `Nat.mod_eq_of_lt` /
`Nat.mod_self` before handing the residual linear arithmetic to `omega`. Naively trusting
`omega` with variable-modulus arithmetic is the single most common dead-end here.
-/