import Mathlib
import Logic.ProofComplexity.Resolution
import Bridges.PigeonholeInjectionBridge

/-!
# Proof Complexity II: The Pigeonhole Principle as a CNF

This file builds the propositional pigeonhole formula `PHP n` — the CNF asserting
that `n + 1` pigeons can be placed into `n` holes with no two pigeons sharing a
hole — and proves it is **unsatisfiable** (`PHP_unsat`).

`PHP n` is *the* benchmark family of proof complexity.  Haken's celebrated theorem
states that every resolution refutation of `PHP n` has size exponential in `n`;
its unsatisfiability (proved here) is the precondition that makes the lower-bound
question meaningful, and combined with `refutation_sound` it shows that *any*
resolution refutation of `PHP n` is a correct certificate.

## Main definitions

* `ProofComplexity.PVar`         : the variable `(pigeon, hole)`.
* `ProofComplexity.pigeonClause` : "pigeon `p` sits in some hole".
* `ProofComplexity.holeClause`   : "pigeons `p1`, `p2` do not share hole `h`".
* `ProofComplexity.PHP`          : the full pigeonhole CNF.

## Main results

* `PHP_unsat`              : `PHP n` is unsatisfiable.
* `PHP_no_refutation_sat`  : a resolution refutation of `PHP n` certifies its
                            unsatisfiability (soundness specialised to `PHP`).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The combinatorial pigeonhole principle can be encoded
faithfully as a CNF whose unsatisfiability is provable directly from
`Fintype.card_le_of_injective`, by reading a satisfying assignment as an injection
from pigeons to holes.

Experiment (Experimenter): Variables are `Fin (n+1) × Fin n`.  Pigeon clauses are
positive disjunctions over holes; hole clauses are the binary "not both" clauses,
generated for all ordered distinct pigeon pairs so that membership extraction is
symmetric.  A satisfying assignment yields, via `choose`, a function `f : pigeon →
hole` that the hole clauses force to be injective.

Analysis (Analyst): The only subtlety was orienting the hole-clause pair: using
*ordered* distinct pairs `p1 ≠ p2` makes the required clause `holeClause (f p1) p1
p2` literally present in `PHP n`, avoiding a `wlog` on the pigeon order.  The
final contradiction reuses the attached catalog result
`Bridges.PigeonholeInjectionBridge.no_injection_of_card_lt`: an injection
`Fin (n+1) → Fin n` cannot exist since `n < n + 1`.

Critique (Critic): `PHP_unsat` is not vacuous — it is a genuine `¬ Satisfiable`
statement about a concrete, fully-spelled-out formula, and `unit_unsat` from the
Resolution file confirms the satisfiability predicate is not always false.  The
exponential resolution *lower* bound (Haken) is deliberately left as a future
direction; what is proved here is the exact hypothesis that bound is about.

Synthesis (PI): `PHP n` is unsatisfiable, so every resolution refutation of it is
sound, and the proof-complexity question "how *large* must such a refutation be?"
is well-posed.  The companion cutting-planes file shows that a *different* proof
system collapses this formula in linearly many counting steps.
-/

namespace ProofComplexity

open Finset

/-- The propositional variable `x_{p,h}` : "pigeon `p` is in hole `h`". -/
abbrev PVar (n : ℕ) := Fin (n + 1) × Fin n

/-- Pigeon clause: pigeon `p` sits in at least one hole. -/
def pigeonClause (n : ℕ) (p : Fin (n + 1)) : Clause (PVar n) :=
  (List.finRange n).map (fun h => ⟨(p, h), true⟩)

/-- Hole clause: pigeons `p1` and `p2` are not both in hole `h`. -/
def holeClause (n : ℕ) (h : Fin n) (p1 p2 : Fin (n + 1)) : Clause (PVar n) :=
  [⟨(p1, h), false⟩, ⟨(p2, h), false⟩]

/-- The pigeonhole CNF for `n + 1` pigeons and `n` holes. -/
def PHP (n : ℕ) : CNF (PVar n) :=
  (List.finRange (n + 1)).map (pigeonClause n) ++
  ((List.finRange n).flatMap (fun h =>
    ((List.finRange (n + 1)).flatMap (fun p1 =>
      ((List.finRange (n + 1)).filter (· ≠ p1)).map
        (fun p2 => holeClause n h p1 p2)))))

/-- **The pigeonhole principle is unsatisfiable.** No assignment can place
`n + 1` pigeons into `n` holes with no collisions. -/
theorem PHP_unsat (n : ℕ) : ¬ (PHP n).Satisfiable := by
  rintro ⟨a, ha⟩
  -- Every pigeon sits in some hole.
  have hpig : ∀ p : Fin (n + 1), ∃ h : Fin n, a (p, h) = true := by
    intro p
    have hmem : pigeonClause n p ∈ PHP n :=
      List.mem_append_left _ (List.mem_map_of_mem (List.mem_finRange p))
    obtain ⟨l, hl, hle⟩ := ha _ hmem
    simp only [pigeonClause, List.mem_map, List.mem_finRange, true_and] at hl
    obtain ⟨h, rfl⟩ := hl
    exact ⟨h, by simpa [Lit.eval] using hle⟩
  choose f hf using hpig
  -- The chosen hole map is injective.
  have hinj : Function.Injective f := by
    intro p1 p2 he
    by_contra hne
    have hmem : holeClause n (f p1) p1 p2 ∈ PHP n := by
      apply List.mem_append_right
      rw [List.mem_flatMap]
      refine ⟨f p1, List.mem_finRange _, ?_⟩
      rw [List.mem_flatMap]
      refine ⟨p1, List.mem_finRange _, ?_⟩
      apply List.mem_map_of_mem
      rw [List.mem_filter]
      exact ⟨List.mem_finRange _, by simpa using (Ne.symm hne)⟩
    obtain ⟨l, hl, hle⟩ := ha _ hmem
    simp only [holeClause, List.mem_cons, List.not_mem_nil, or_false] at hl
    rcases hl with rfl | rfl
    · simp [Lit.eval, hf p1] at hle
    · rw [he] at hle; simp [Lit.eval, hf p2] at hle
  -- An injection `Fin (n+1) → Fin n` is impossible.  We reuse the catalog
  -- pigeonhole bridge `PigeonholeInjectionBridge.no_injection_of_card_lt`.
  refine PigeonholeInjectionBridge.no_injection_of_card_lt ?_ f hinj
  simp

/-- Specialising soundness: any resolution refutation of `PHP n` is a valid
certificate of its unsatisfiability (the converse — that a *short* one exists —
is exactly what Haken's theorem rules out). -/
theorem PHP_no_refutation_sat (n : ℕ) (h : Refutation (PHP n)) :
    ¬ (PHP n).Satisfiable :=
  refutation_sound h

end ProofComplexity