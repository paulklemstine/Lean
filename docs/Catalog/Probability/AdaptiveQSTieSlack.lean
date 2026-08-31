/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Tie-multiplicity slack of threshold deferral, and its arithmetic vanishing

`AdaptiveQSPrefixOptimality.lean` collapsed the deployment policy space: the minimum-work
quota-feasible schedule can always be taken *separated*, and a separated schedule sits
inside the dial threshold set `keepSet s r θ` at `θ = ` its own minimal rate.  That left
exactly one gap, recorded as the open direction "Tie-Multiplicity Slack of Threshold
Deferral": the threshold set retains *every* target whose rate equals `θ`, so it can be
strictly larger than the minimal schedule.

This file closes that gap.

* `tieClass` — the targets sitting exactly on the threshold.
* `keepSet_sdiff_eq_tieClass_sdiff` — the excess of the threshold set over a separated
  schedule is *exactly* the tie class outside it (an equality of sets, not a bound).
* `keepSet_card_eq_add_tie_slack` — hence the cardinality identity
  `|keepSet| = |T| + |tieClass \ T|`: the extra work done by the threshold policy is the
  tie multiplicity, nothing more.
* `keepSet_eq_of_injOn` — if the rate dial is injective on the targets there are no ties,
  and the threshold policy reproduces the minimal schedule *on the nose*.
* `periodRate_injOn_admissible` — the arithmetic input: on a factor base of admissible odd
  primes the exact rate `2/p` is injective, because `p ↦ 2/p` is.
* `factorBase_threshold_exactly_minimal` — the capstone: on such a factor base, whenever a
  relation quota is attainable there is a threshold whose retained set meets the quota, has
  the *minimum possible* cardinality among all quota-feasible schedules, and has throughput
  at least that of sieving the whole factor base.
* Lab note `labnote_tie_slack_is_one`: a three-target instance with a genuine tie, where the
  threshold policy does one unit of work more than the optimum — showing the slack term is
  not vacuous and that injectivity is doing real work.
-/
import Mathlib
import Probability.AdaptiveQSAllocation
import Probability.AdaptiveQSSkipFlip
import Probability.AdaptiveQSPrefixOptimality
import Probability.AdaptiveQSResidueRate

namespace Probability.AdaptiveQS

open Finset

variable {ι : Type*} [DecidableEq ι]

/-! ## The tie class of a threshold -/

/-- The targets whose rate is exactly the threshold: the only place where a threshold
policy can do more work than a minimal schedule. -/
noncomputable def tieClass (s : Finset ι) (r : ι → ℝ) (θ : ℝ) : Finset ι :=
  s.filter (fun i => r i = θ)

/-- **The excess of a threshold over a separated schedule is exactly its tie class.**
If `T` is separated in `s`, then the targets that the threshold at `θ = min_T r` retains
beyond `T` are precisely the targets outside `T` whose rate equals `θ`. -/
theorem keepSet_sdiff_eq_tieClass_sdiff {s T : Finset ι} {r : ι → ℝ}
    (hT : T.Nonempty) (hsep : Separated s T r) :
    keepSet s r (T.inf' hT r) \ T = tieClass s r (T.inf' hT r) \ T := by
  ext i
  simp only [Finset.mem_sdiff, keepSet, tieClass, Finset.mem_filter]
  constructor
  · rintro ⟨⟨his, hθi⟩, hiT⟩
    refine ⟨⟨his, le_antisymm ?_ hθi⟩, hiT⟩
    obtain ⟨t, htT, ht⟩ := Finset.exists_mem_eq_inf' hT r
    rw [ht]
    exact hsep t htT i his hiT
  · rintro ⟨⟨his, hri⟩, hiT⟩
    exact ⟨⟨his, le_of_eq hri.symm⟩, hiT⟩

/-- **The tie-multiplicity identity.**  The work done by the threshold policy exceeds the
minimal separated schedule by exactly the number of ties at the threshold. -/
theorem keepSet_card_eq_add_tie_slack {s T : Finset ι} {r : ι → ℝ} (hTs : T ⊆ s)
    (hT : T.Nonempty) (hsep : Separated s T r) :
    (keepSet s r (T.inf' hT r)).card
      = T.card + (tieClass s r (T.inf' hT r) \ T).card := by
  have hsub : T ⊆ keepSet s r (T.inf' hT r) := separated_subset_keepSet hTs hT
  have hcard := Finset.card_sdiff_add_card_eq_card hsub
  rw [keepSet_sdiff_eq_tieClass_sdiff hT hsep] at hcard
  omega

/-- **No ties, no slack.**  If the rate dial is injective on the targets, the threshold
policy retains exactly the minimal separated schedule. -/
theorem keepSet_eq_of_injOn {s T : Finset ι} {r : ι → ℝ} (hTs : T ⊆ s)
    (hT : T.Nonempty) (hsep : Separated s T r) (hinj : Set.InjOn r s) :
    keepSet s r (T.inf' hT r) = T := by
  have hsub : T ⊆ keepSet s r (T.inf' hT r) := separated_subset_keepSet hTs hT
  refine Finset.Subset.antisymm ?_ hsub
  intro i hi
  by_contra hiT
  have hmem : i ∈ keepSet s r (T.inf' hT r) \ T := Finset.mem_sdiff.mpr ⟨hi, hiT⟩
  rw [keepSet_sdiff_eq_tieClass_sdiff hT hsep] at hmem
  obtain ⟨hi', hiT'⟩ := Finset.mem_sdiff.mp hmem
  rw [tieClass, Finset.mem_filter] at hi'
  obtain ⟨t, htT, ht⟩ := Finset.exists_mem_eq_inf' hT r
  have : i = t := hinj hi'.1 (hTs htT) (by rw [hi'.2, ht])
  exact hiT (this ▸ htT)

/-! ## The arithmetic case: rates `2/p` are pairwise distinct -/

/-- A factor base is **admissible for `N`** when each of its members is an odd prime
that does not divide `N` and for which `N` is a quadratic residue — exactly the primes
with nonzero per-period rate. -/
def AdmissibleFB (N : ℤ) (FB : Finset ℕ) : Prop :=
  ∀ p ∈ FB, p.Prime ∧ p ≠ 2 ∧ ((N : ZMod p) ≠ 0) ∧ IsSquare ((N : ZMod p))

/-- **The exact rates of a factor base are pairwise distinct.**  Since an admissible odd
prime has rate exactly `2/p`, and `p ↦ 2/p` is injective on positive integers, no two
factor-base primes tie. -/
theorem periodRate_injOn_admissible {N : ℤ} {FB : Finset ℕ} (hFB : AdmissibleFB N FB) :
    Set.InjOn (periodRate N) FB := by
  intro p hp q hq hpq
  obtain ⟨hpprime, hp2, hpN, hpsq⟩ := hFB p hp
  obtain ⟨hqprime, hq2, hqN, hqsq⟩ := hFB q hq
  haveI : Fact p.Prime := ⟨hpprime⟩
  haveI : Fact q.Prime := ⟨hqprime⟩
  rw [periodRate_eq_two_div hp2 hpN hpsq, periodRate_eq_two_div hq2 hqN hqsq] at hpq
  have hppos : (0:ℝ) < p := by exact_mod_cast hpprime.pos
  have hqpos : (0:ℝ) < q := by exact_mod_cast hqprime.pos
  have : (p : ℝ) = q := by
    field_simp at hpq
    linarith
  exact_mod_cast this

/-- **Capstone: exact optimality of threshold deferral on a factor base.**  For an
admissible factor base and an attainable relation quota `Q`, there is a threshold `θ` on
the exact rate dial such that the retained primes

* still collect the quota,
* are *fewest possible*: no quota-feasible set of primes is smaller, and
* have throughput at least that of sieving the entire factor base.

There is no tie-breaking freedom left: the threshold policy is exactly optimal, not merely
optimal up to ties. -/
theorem factorBase_threshold_exactly_minimal {N : ℤ} {FB : Finset ℕ} {Q : ℝ}
    (hFB : AdmissibleFB N FB) (hQ : 0 < Q)
    (hfeas : ∃ K ⊆ FB, Q ≤ ∑ p ∈ K, periodRate N p) :
    ∃ θ : ℝ,
      Q ≤ ∑ p ∈ keepSet FB (periodRate N) θ, periodRate N p ∧
      (∀ K ⊆ FB, Q ≤ ∑ p ∈ K, periodRate N p →
        (keepSet FB (periodRate N) θ).card ≤ K.card) ∧
      throughput FB (periodRate N)
        ≤ throughput (keepSet FB (periodRate N) θ) (periodRate N) := by
  obtain ⟨T, hTs, hTQ, hTsep, hTmin⟩ := exists_separated_minimal_feasible hfeas
  have hT : T.Nonempty := by
    rcases Finset.eq_empty_or_nonempty T with rfl | h
    · simp only [Finset.sum_empty] at hTQ
      exact absurd hTQ (not_le.mpr hQ)
    · exact h
  have hkeep : keepSet FB (periodRate N) (T.inf' hT (periodRate N)) = T :=
    keepSet_eq_of_injOn hTs hT hTsep (periodRate_injOn_admissible hFB)
  refine ⟨T.inf' hT (periodRate N), ?_, ?_, ?_⟩
  · rw [hkeep]; exact hTQ
  · rw [hkeep]; exact hTmin
  · exact skip_throughput_ge (concordant_self FB (periodRate N))
      (T.inf' hT (periodRate N)) (hT.mono (separated_subset_keepSet hTs hT))

/-! ## Lab note — the slack is real when rates tie

Rates `(3, 3, 1)` on the three targets `{0, 1, 2}` and quota `Q = 3`.  The minimum-work
schedule is a single target, but the threshold at `θ = 3` must retain both targets of rate
`3`: the tie multiplicity is `1`, and the threshold policy does one unit of work more than
the optimum.  This is exactly the term that `keepSet_card_eq_add_tie_slack` isolates, and
that `periodRate_injOn_admissible` rules out arithmetically. -/

/-- The lab-note rate vector `(3, 3, 1)` — two targets tie at the top. -/
noncomputable def tieLabRate : ℕ → ℝ := fun i => if i = 0 then 3 else if i = 1 then 3 else 1

/-- The threshold at `θ = 3` retains both tied targets. -/
theorem tieLab_keepSet : keepSet ({0, 1, 2} : Finset ℕ) tieLabRate 3 = {0, 1} := by
  ext i
  simp only [keepSet, Finset.mem_filter, Finset.mem_insert, Finset.mem_singleton]
  constructor
  · rintro ⟨hi, hri⟩
    rcases hi with rfl | rfl | rfl
    · exact Or.inl rfl
    · exact Or.inr rfl
    · rw [tieLabRate] at hri
      norm_num at hri
  · rintro (rfl | rfl)
    · exact ⟨by norm_num, by norm_num [tieLabRate]⟩
    · exact ⟨by norm_num, by norm_num [tieLabRate]⟩

/-- **The slack costs exactly one extra target.**  A single target meets the quota `3`,
but the threshold policy at `θ = 3` works on two: the tie multiplicity is `1`. -/
theorem labnote_tie_slack_is_one :
    (3 : ℝ) ≤ ∑ i ∈ ({0} : Finset ℕ), tieLabRate i ∧
      (keepSet ({0, 1, 2} : Finset ℕ) tieLabRate 3).card
        = ({0} : Finset ℕ).card + 1 := by
  refine ⟨by norm_num [tieLabRate], ?_⟩
  rw [tieLab_keepSet]
  decide

end Probability.AdaptiveQS