import Bridges.ArrowCurvature.Defs

/-!
# Arrow-Curvature: Extensions and the Unrestricted-Domain Obstruction

This file extends `Bridges.ArrowCurvature.Defs`. The headline result there,
`arrow_curvature_conjecture`, is *vacuously* true because the unrestricted-domain
hypothesis `∀ P, 0 < CondorcetCurvature P` is unsatisfiable: a unanimous
(constant) profile always has zero Condorcet curvature
(`unanimous_curvature_zero`).

Here we make that observation a first-class theorem and develop the constructive
"flat" side of the bridge:

* `exists_unanimous_profile` — a unanimous profile always exists.
* `unrestricted_domain_impossible` — no profile family has positive curvature
  on *all* profiles; the unrestricted-domain hypothesis is never satisfiable.
* `condorcetCurvature_eq_cycleCount` — the Condorcet curvature of a profile
  equals the directed-3-cycle count of its majority tournament, identifying the
  two curvature notions across Parts I and V.
* `dictatorSWF` and its properties — the dictatorship social welfare function is
  Pareto, IIA, and dictatorial, so the Arrow hypotheses are jointly *consistent*
  (the impossibility is genuine, not an empty class).
-/

open Finset Function

namespace ArrowCurvature

/-! ## Part I: A unanimous profile always exists -/

-- !-- The constant profile assigning the identity ranking to every voter is
-- unanimous by definition (all voters share one ranking). -- !--
/-- For any number of alternatives `n` and voters `k`, there is a unanimous
    preference profile. -/
theorem exists_unanimous_profile (n k : ℕ) :
    ∃ P : PreferenceProfile n k, P.IsUnanimous := by
  refine ⟨fun _ => ⟨Equiv.refl (Fin n)⟩, ?_⟩
  intro i j a b h
  exact h

/-! ## Part II: The unrestricted-domain hypothesis is unsatisfiable -/

-- !-- Instantiate the constant profile, whose curvature is `0` by
-- `unanimous_curvature_zero`; this contradicts positivity on all profiles. -- !--
/-- **Unrestricted-domain obstruction.** There is no profile space on which the
    Condorcet curvature is positive for *every* profile: the constant profile is
    always flat. This is exactly why `arrow_curvature_conjecture` is vacuous. -/
theorem unrestricted_domain_impossible (n k : ℕ) :
    ¬ ∀ P : PreferenceProfile n k, 0 < CondorcetCurvature P := by
  intro h
  obtain ⟨P, hP⟩ := exists_unanimous_profile n k
  have h0 := unanimous_curvature_zero P hP
  have h1 := h P
  omega

/-! ## Part III: Condorcet curvature is the majority tournament's cycle count -/

-- !-- Both quantities are the cardinality of the same filtered finset of triples:
-- `majorityBeats a b` unfolds to `supportCount a b > supportCount b a`, the very
-- predicate defining `CondorcetCurvature`. -- !--
/-- The Condorcet curvature of a profile equals the number of directed 3-cycles
    of its majority tournament, unifying the Part-I tournament curvature
    (`cycleCount`) with the Part-V profile curvature (`CondorcetCurvature`). -/
theorem condorcetCurvature_eq_cycleCount {n k : ℕ} (P : PreferenceProfile n k)
    (hk : Odd k) (hn : 1 < n) :
    CondorcetCurvature P = (P.majorityTournament hk hn).cycleCount := by
  rfl

/-! ## Part IV: The dictatorship SWF — Arrow's hypotheses are consistent -/

/-- The dictatorship social welfare function: society copies voter `d`'s ranking. -/
def dictatorSWF {n k : ℕ} (d : Fin k) : SocialWelfareFunction n k :=
  fun P => P d

-- !-- `dictatorSWF d P = P d`, so society's preference on `a,b` is exactly voter
-- `d`'s preference; the three properties are immediate. -- !--
/-- The dictatorship SWF makes `d` a dictator. -/
theorem dictatorSWF_isDictator {n k : ℕ} (d : Fin k) :
    (dictatorSWF (n := n) d).IsDictator d := by
  intro P a b h
  exact h

/-- The dictatorship SWF is Pareto efficient. -/
theorem dictatorSWF_isPareto {n k : ℕ} (d : Fin k) :
    (dictatorSWF (n := n) d).IsPareto := by
  intro P a b h
  exact h d

/-- The dictatorship SWF satisfies Independence of Irrelevant Alternatives. -/
theorem dictatorSWF_isIIA {n k : ℕ} (d : Fin k) :
    (dictatorSWF (n := n) d).IsIIA := by
  intro P Q a b h
  exact h d

/-- **Consistency of Arrow's axioms.** For `k ≥ 1` voters there exists a social
    welfare function that is simultaneously Pareto, IIA, and dictatorial, so the
    impossibility theorem governs a nonempty class of aggregators rather than a
    vacuous one. -/
theorem arrow_axioms_consistent {n k : ℕ} (hk : 1 ≤ k) :
    ∃ F : SocialWelfareFunction n k,
      F.IsPareto ∧ F.IsIIA ∧ F.IsDictatorial := by
  refine ⟨dictatorSWF ⟨0, hk⟩, dictatorSWF_isPareto _, dictatorSWF_isIIA _,
    ⟨⟨0, hk⟩, dictatorSWF_isDictator _⟩⟩

end ArrowCurvature