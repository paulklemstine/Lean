import Mathlib
import Logic.GraphTheory.Defs

/-!
# Single-Peaked Preferences are Flat: Black's Theorem as Vanishing Curvature

This file extends `Bridges.ArrowCurvature.Defs`, where the *Condorcet curvature*
of a preference profile (the number of directed majority 3-cycles) was introduced
as a discrete analogue of Riemannian curvature on the space of preference profiles.

The headline result advertised but **left unproven** in `Defs` was Black's theorem
(`single_peaked_majority_transitive`). We close that gap here, and recast Black's
1948 theorem in geometric language:

> **Single-peaked preference domains are flat.**
> If every voter's ranking is single-peaked on a common axis, the Condorcet
> curvature vanishes, hence the majority tournament is transitive.

## Strategy (Sen's value restriction → Black's theorem)

The proof goes through Amartya Sen's *value restriction* condition, which we
isolate as the key structural lemma:

* `single_peaked_never_worst` — On any triple `a < b < c` (in axis order), a
  single-peaked voter never ranks the **middle** alternative `b` last; i.e. the
  voter prefers `b` to `a` or prefers `b` to `c`.

The engine that converts value restriction into transitivity is a *transfer of
decisiveness* across the middle alternative:

* `cross_beats` — If the middle `m` is never-worst for every voter, and a flank
  alternative `L` beats `m` by majority, then `L` also beats the opposite flank
  `R` by majority. (The `L > m` voters are forced, by value restriction and
  transitivity, to also rank `L > R`.)

These combine to forbid majority cycles, giving flatness:

* `single_peaked_no_majority_cycle` — no Condorcet cycle.
* `single_peaked_curvature_zero` — `CondorcetCurvature P = 0` (geometric form).
* `single_peaked_majority_transitive` — **Black's theorem** (classical form).

## Catalog synthesis

We build directly on `Bridges.ArrowCurvature.Defs`:
`CondorcetCurvature`, `PreferenceProfile.majorityBeats`,
`PreferenceProfile.supportCount`, `support_partition`,
`StrictRanking.IsSinglePeakedAt`, `curvature_zero_iff_no_majority_cycle`, and
`zero_curvature_majority_transitive`. Where `unanimous_curvature_zero` (in `Defs`)
showed the *single point* is flat, we show the entire *single-peaked submanifold*
is flat — the geometric explanation, anticipated in the project's FUTURE
DIRECTIONS, for why single-peakedness escapes Arrow's impossibility.

-- !-- Lab Notebook -- !--
Hypothesis: The "single-peaked ⟹ transitive majority" result (Black 1948),
  advertised in `ArrowCurvature/Defs.lean` but unproven, should follow from a
  purely local value-restriction property combined with a counting/transfer
  argument, with no parity (odd-`k`) hypothesis needed for *acyclicity*.
Result: Confirmed. `single_peaked_no_majority_cycle` and
  `single_peaked_curvature_zero` need no oddness assumption; oddness only enters
  `single_peaked_majority_transitive` because the underlying
  `majorityTournament` of `Defs` is only defined for odd `k` (to break ties).
Insight: The whole proof factors through ONE inequality lemma `cross_beats`:
  decisiveness of a flank over the never-worst middle transfers to decisiveness
  over the far flank. This is the discrete shadow of "geodesics on a flat
  submanifold carry no holonomy". Value restriction = flatness; the transfer
  lemma = parallel transport with trivial holonomy.
Failure analysis: A first instinct was to do a 4-class (n1..n4) census of the
  six linear orders on a triple. That is correct but heavy in Lean. The subset
  inclusion `{i : L ≻ m} ⊆ {i : L ≻ R}` (valid precisely because `m` is
  never-worst) replaces the entire census with one `Finset.card_le_card`.
-- !-- end Lab Notebook -- !--
-/

open Finset Function

namespace SinglePeakedFlatness

/-! ## Part I: Value restriction — the middle is never worst -/

/-
!-- For a voter single-peaked at `p`, on a triple `a < b < c` either the peak
is at/right of `b` (use the right-monotone clause to get `b ≻ c`) or strictly
left of `b` (use the left-monotone clause to get `b ≻ a`). Either way `b` is
not last. -- !--

**Sen value restriction from single-peakedness.** A single-peaked voter never
    ranks the axis-middle alternative `b` of a triple `a < b < c` last: it prefers
    `b` to `a` or prefers `b` to `c`.
-/
theorem single_peaked_never_worst {n : ℕ} (r : StrictRanking n) (p : Fin n)
    (hsp : r.IsSinglePeakedAt p) (a b c : Fin n)
    (hab : (a : ℕ) < (b : ℕ)) (hbc : (b : ℕ) < (c : ℕ)) :
    r.prefers b a ∨ r.prefers b c := by
  by_cases hp : ( b : ℕ ) ≤ p.val <;> simp_all +decide [ StrictRanking.IsSinglePeakedAt ];
  exact Or.inr ( hsp.2.2 _ _ hp.le hbc )

/-! ## Part II: The transfer-of-decisiveness lemma -/

/-
!-- The voters with `L ≻ m` are a subFinset of those with `L ≻ R`: each such
voter has, by value restriction, `m ≻ L` or `m ≻ R`; `m ≻ L` is impossible
(asymmetry), so `m ≻ R`, hence `L ≻ m ≻ R ⟹ L ≻ R`. Counting:
`supportCount L R ≥ supportCount L m > k/2`, so `L` beats `R`. -- !--

**Transfer of decisiveness across a never-worst middle.** If `m` is never
    ranked worst (every voter prefers `m` to `L` or to `R`) and the flank `L`
    beats `m` by strict majority, then `L` beats the far flank `R` by strict
    majority.
-/
theorem cross_beats {n k : ℕ} (P : PreferenceProfile n k) (m L R : Fin n)
    (hLm : L ≠ m) (hLR : L ≠ R)
    (hvr : ∀ i, (P i).prefers m L ∨ (P i).prefers m R)
    (hbeat : P.majorityBeats L m) :
    P.majorityBeats L R := by
  unfold PreferenceProfile.majorityBeats at *;
  have h_support_count : (Finset.univ.filter (fun i => (P i).prefers L m)).card ≤ (Finset.univ.filter (fun i => (P i).prefers L R)).card := by
    refine Finset.card_le_card ?_;
    intro i hi; specialize hvr i; simp_all +decide [ StrictRanking.prefers ] ;
    exact lt_trans hi ( hvr.resolve_left ( lt_asymm hi ) );
  linarith! [ P.support_partition L m hLm, P.support_partition L R hLR ]

/-! ## Part III: No majority cycles on the sorted triple -/

/-
!-- With `a < b < c` the middle is `b`; value restriction gives `b` never-worst
for all voters. Each cyclic orientation contains an edge `flank ≻ b`; apply
`cross_beats` to get `flank` beating the opposite flank, contradicting the
closing edge of the cycle by majority asymmetry. -- !--

For an axis-sorted triple `a < b < c`, neither cyclic orientation of the
    majority relation can occur on a single-peaked profile.
-/
theorem median_no_cycle {n k : ℕ} (P : PreferenceProfile n k)
    (hsp : P.IsSinglePeaked) (a b c : Fin n)
    (hab : (a : ℕ) < (b : ℕ)) (hbc : (b : ℕ) < (c : ℕ)) :
    ¬ (P.majorityBeats a b ∧ P.majorityBeats b c ∧ P.majorityBeats c a) ∧
    ¬ (P.majorityBeats a c ∧ P.majorityBeats c b ∧ P.majorityBeats b a) := by
  constructor <;> intro h <;> rcases h with ⟨ h₁, h₂, h₃ ⟩;
  · -- By `cross_beats`, `a` beats `c` by majority, contradicting `h₃`.
    have h_cross : P.majorityBeats a c := by
      apply cross_beats;
      exact ne_of_lt hab;
      · exact ne_of_lt ( lt_trans hab hbc );
      · exact fun i => single_peaked_never_worst _ _ ( hsp i |> Classical.choose_spec ) _ _ _ hab hbc;
      · assumption;
    unfold PreferenceProfile.majorityBeats at *; linarith;
  · -- By `cross_beats`, since `c` beats `b`, `c` must also beat `a`.
    have h_c_beats_a : P.majorityBeats c a := by
      apply cross_beats P b c a (by
      exact ne_of_gt hbc) (by
      exact ne_of_gt ( lt_trans hab hbc )) (by
      intro i
      obtain ⟨p, hp⟩ := hsp i
      have := single_peaked_never_worst (P i) p hp a b c hab hbc
      aesop) h₂;
    unfold PreferenceProfile.majorityBeats at *; linarith;

/-! ## Part IV: Black's theorem, geometric and classical forms -/

/-
!-- A Condorcet cycle forces three distinct alternatives; sorting them by axis
position lands in one of the two orientations ruled out by `median_no_cycle`. -- !--

**No Condorcet cycle on a single-peaked profile.**
-/
theorem single_peaked_no_majority_cycle {n k : ℕ} (P : PreferenceProfile n k)
    (hsp : P.IsSinglePeaked) :
    ¬ ∃ a b c : Fin n,
      P.majorityBeats a b ∧ P.majorityBeats b c ∧ P.majorityBeats c a := by
  by_contra h_contra
  obtain ⟨a, b, c, h_cycle⟩ := h_contra;
  have h_distinct : a ≠ b ∧ b ≠ c ∧ c ≠ a := by
    unfold PreferenceProfile.majorityBeats at h_cycle; aesop;
  grind +suggestions

-- !-- Immediate from `curvature_zero_iff_no_majority_cycle` (in `Defs`) applied to
-- `single_peaked_no_majority_cycle`. -- !--
/-- **Black's theorem, geometric form: single-peaked domains are flat.** The
    Condorcet curvature of any single-peaked profile vanishes. This is the
    submanifold strengthening of `unanimous_curvature_zero` from `Defs`. -/
theorem single_peaked_curvature_zero {n k : ℕ} (P : PreferenceProfile n k)
    (hsp : P.IsSinglePeaked) :
    CondorcetCurvature P = 0 :=
  (curvature_zero_iff_no_majority_cycle P).mpr (single_peaked_no_majority_cycle P hsp)

-- !-- Compose `single_peaked_curvature_zero` with `zero_curvature_majority_transitive`
-- from `Defs`. -- !--
/-- **Black's theorem, classical form.** On a single-peaked domain with an odd
    number of voters and at least two alternatives, the majority tournament is
    transitive — a genuine, non-dictatorial social ordering exists. -/
theorem single_peaked_majority_transitive {n k : ℕ} (P : PreferenceProfile n k)
    (hsp : P.IsSinglePeaked) (hk : Odd k) (hn : 1 < n) :
    (P.majorityTournament hk hn).IsTransitive :=
  zero_curvature_majority_transitive P hk hn (single_peaked_curvature_zero P hsp)

end SinglePeakedFlatness