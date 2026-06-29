import Mathlib
import Logic.ProofComplexity.Resolution
import Logic.ProofComplexity.Pigeonhole
import Logic.ProofComplexity.CuttingPlanes

/-!
# Proof Complexity V: Bridging the Resolution and Cutting-Planes Encodings

The pigeonhole principle `PHP n` lives in two worlds at once:

* as a **CNF** (the `Resolution` encoding), where it is the canonical hard formula
  for resolution (Haken's exponential lower bound);
* as a system of **linear inequalities** (the `CuttingPlanes` encoding), where the
  double-counting argument `php_cp_counting` refutes it in `O(n)` steps.

This file builds the explicit bridge between the two.  Given any Boolean
assignment `a` that satisfies the pigeonhole CNF, the `0/1` integer vector
`fun pr => if a pr then 1 else 0` satisfies exactly the row lower bounds and
column upper bounds that the cutting-planes counting refutation consumes.  Feeding
those bounds into `php_cp_counting` re-derives `PHP_unsat` *through the
cutting-planes system* — a concrete instance of one proof system simulating the
content of another, and the constructive half of the resolution/cutting-planes
separation.

## Main results

* `php_pigeon_indicator_sum`  : a satisfied pigeon clause forces a row sum `≥ 1`.
* `php_hole_indicator_sum`    : satisfied hole clauses force a column sum `≤ 1`.
* `php_refuted_by_cutting_planes` : the CNF and the counting argument agree —
                                  a CNF model yields the cutting-planes contradiction.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): A satisfying Boolean assignment of the pigeonhole CNF
is *exactly* a `0/1` integer point obeying the pigeon row lower bounds and the hole
column upper bounds; therefore the cutting-planes counting refutation
(`php_cp_counting`) should re-prove `PHP_unsat` with the CNF semantics as its only
input. This realises "cutting planes simulates the contradiction" on a concrete
formula.

Experiment (Experimenter): Set `x pr = if a pr then 1 else 0`. The row bound comes
from the pigeon clause, which yields a hole `h₀` with `a (p, h₀) = true`; that term
is `1` and the rest are `≥ 0`, so `Finset.single_le_sum` gives `1 ≤ ∑`. The column
bound is the subtle one: rewrite the column sum as the cardinality of
`{p | a (p, h)}` via `Finset.sum_boole`, then bound that card by `1` using
`Finset.card_le_one` fed by the binary hole clauses (no two pigeons in one hole).

Analysis (Analyst): The membership bookkeeping in `PHP n` (append / flatMap /
filter layers) is reused verbatim from `PHP_unsat`; the genuinely new content is
the translation of clause satisfaction into the *arithmetic* inequalities of the
cutting-planes system. The final contradiction is `php_cp_counting` applied to the
two derived bounds.

Critique (Critic): This is not a vacuous restatement of `PHP_unsat`: it routes the
unsatisfiability proof through a *different* proof system (linear counting), making
the cross-system content explicit. The matching *lower* bound for resolution
(Haken) — which is what makes this a genuine *separation* — remains beyond reach
and is recorded in `FUTURE_DIRECTIONS.md`.

Synthesis (PI): The two encodings of the pigeonhole principle are reconciled: any
CNF model is a cutting-planes point, and the linear counting refutation closes it.
Resolution must pay exponentially for the same formula that cutting planes refutes
in linearly many counting steps.
-/

namespace ProofComplexity

open Finset

variable {n : ℕ} {a : PVar n → Bool}

/-
From a satisfied pigeon clause: the indicator row sum of pigeon `p` is `≥ 1`.
-/
theorem php_pigeon_indicator_sum (ha : (PHP n).sat a) (p : Fin (n + 1)) :
    1 ≤ ∑ h : Fin n, (if a (p, h) then (1 : ℤ) else 0) := by
  -- By definition of `Pigeonhole PHP`, we know that `pigeonClause n p` is in `PHP n`.
  have h_mem : pigeonClause n p ∈ PHP n := by
    exact List.mem_append_left _ ( List.mem_map_of_mem ( List.mem_finRange p ) );
  specialize ha ( pigeonClause n p ) h_mem;
  simp_all +decide [ Clause.sat, pigeonClause ];
  exact ⟨ ha.choose, by simpa [ Lit.eval ] using ha.choose_spec ⟩

/-
From the satisfied hole clauses: the indicator column sum of hole `h` is `≤ 1`.
-/
theorem php_hole_indicator_sum (ha : (PHP n).sat a) (h : Fin n) :
    (∑ p : Fin (n + 1), (if a (p, h) then (1 : ℤ) else 0)) ≤ 1 := by
  simp +zetaDelta at *;
  -- By contradiction, assume there are two pigeon-holes $(p_1, h)$ and $(p_2, h)$ such that $a(p_1, h) = true$ and $a(p_2, h) = true$.
  by_contra h_contra;
  obtain ⟨p1, p2, hp1, hp2, hne⟩ : ∃ p1 p2 : Fin (n + 1), p1 ≠ p2 ∧ a (p1, h) = true ∧ a (p2, h) = true := by
    obtain ⟨ p1, hp1, p2, hp2, hne ⟩ := Finset.one_lt_card.mp ( not_le.mp h_contra ) ; use p1, p2; aesop;
  have hmem : holeClause n h p1 p2 ∈ PHP n := by
    simp +decide [ PHP, holeClause ];
    exact Or.inr hp1.symm;
  obtain ⟨ l, hl, hle ⟩ := ha _ hmem; simp_all +decide [ holeClause ] ;
  cases hl <;> simp_all +decide [ Lit.eval ]

/-- **The cutting-planes counting argument refutes the pigeonhole CNF.**

Any Boolean assignment satisfying the resolution encoding `PHP n` yields, via its
`0/1` indicator, an integer point obeying the row lower bounds and column upper
bounds; the linear double-counting refutation `php_cp_counting` then closes it.
This re-derives `PHP_unsat` *inside the cutting-planes system*. -/
theorem php_refuted_by_cutting_planes (ha : (PHP n).sat a) : False :=
  php_cp_counting n (fun pr => if a pr then 1 else 0)
    (php_pigeon_indicator_sum ha) (php_hole_indicator_sum ha)

end ProofComplexity