import Mathlib
import Probability.SpikeInclusionGeometry
import Probability.SpikePositionMagnitudeDegeneracy

/-!
# The exact quantile identity: positional prefixes *are* magnitude sublevel sets

`Catalog/Probability/SpikePositionMagnitudeDegeneracy.lean` shows that, at a
fixed modulus, position and residue determine each other.  This file closes the
counting half of that statement (future direction 1 of
`FUTURE_DIRECTIONS.md`) in its exact, non-asymptotic form: the *empirical
quantile function of the residue on the window is an explicit closed-form
expression in the position variable*, namely

`#{ j ∈ W N : residue N j ≤ x } = min (3 * isqrt N) (isqrt (N + x)) - isqrt N`
(`Spike.Quantile.card_sublevel`),

so every magnitude sublevel set is literally a positional prefix
(`Spike.Quantile.sublevel_eq_prefix`) and conversely
(`Spike.Quantile.prefix_eq_sublevel`).

Applied to the geometry of the round-85 window this gives the sharp form of the
inclusion artifact.  For the exactly divisible moduli `N = (5m)^2` we obtain

* `Spike.Quantile.window_card` : the window has exactly `10 * m` positions;
* `Spike.Quantile.firstDecile_card` : the first decile has exactly `m` of them —
  it really is a tenth (`Spike.Quantile.firstDecile_is_a_tenth`);
* `Spike.Quantile.firstDecile_eq_residue_sublevel` : on that window the
  first-decile predicate is *equivalent* to the magnitude predicate
  `v ≤ 11 * m ^ 2` — the decile cut is a magnitude cut, with no positional
  content whatsoever;
* `Spike.Quantile.card_residue_le_eq_firstDecile_card` : consequently the
  first-decile count and the tiny-`v` count are the same number.

Together with `Spike.size_residue_lt_96` this upgrades "100% of first-decile
hits have `bitlen v < 96`" from a bound to an identity of counting statistics:
a first-decile analysis and a `v`-threshold analysis are the *same* analysis.
-/

namespace Spike.Quantile

open Spike

variable {N : ℕ}

instance decidableInWindow (N j : ℕ) : Decidable (inWindow N j) := by
  unfold inWindow; infer_instance

instance decidableInFirstDecile (N j : ℕ) : Decidable (inFirstDecile N j) := by
  unfold inFirstDecile; infer_instance

/-- The stored window as a finite set of positions. -/
def window (N : ℕ) : Finset ℕ := Finset.Icc (Nat.sqrt N + 1) (3 * Nat.sqrt N)

/-- Above `isqrt N` the modulus never exceeds the square of the position. -/
theorem le_sq_of_window {j : ℕ} (hj : Nat.sqrt N + 1 ≤ j) : N ≤ j ^ 2 := by
  have h1 : N < (Nat.sqrt N + 1) ^ 2 := by simpa [pow_two] using Nat.lt_succ_sqrt N
  exact le_of_lt (lt_of_lt_of_le h1 (Nat.pow_le_pow_left hj 2))

/-- **Pointwise inversion of the sublevel condition.**  For a window position,
`residue N j ≤ x` holds exactly when `j ≤ isqrt (N + x)`. -/
theorem residue_le_iff {j x : ℕ} (hj : Nat.sqrt N + 1 ≤ j) :
    residue N j ≤ x ↔ j ≤ Nat.sqrt (N + x) := by
  have h := le_sq_of_window hj
  rw [Nat.le_sqrt']
  simp only [residue]
  omega

/-- **A magnitude sublevel set is a positional prefix.** -/
theorem sublevel_eq_prefix (x : ℕ) :
    (window N).filter (fun j => residue N j ≤ x)
      = Finset.Icc (Nat.sqrt N + 1) (min (3 * Nat.sqrt N) (Nat.sqrt (N + x))) := by
  ext j
  simp only [window, Finset.mem_filter, Finset.mem_Icc, le_min_iff]
  constructor
  · rintro ⟨⟨hlo, hhi⟩, hres⟩
    exact ⟨hlo, hhi, (residue_le_iff hlo).mp hres⟩
  · rintro ⟨hlo, hhi, hsq⟩
    exact ⟨⟨hlo, hhi⟩, (residue_le_iff hlo).mpr hsq⟩

/-- **The exact empirical quantile function of the residue on the window.**  No
asymptotics: the count of hits below any magnitude threshold is a closed-form
function of the position variable alone. -/
theorem card_sublevel (x : ℕ) :
    ((window N).filter (fun j => residue N j ≤ x)).card
      = min (3 * Nat.sqrt N) (Nat.sqrt (N + x)) - Nat.sqrt N := by
  have hmono : Nat.sqrt N ≤ Nat.sqrt (N + x) := Nat.sqrt_le_sqrt (Nat.le_add_right _ _)
  have h3 : Nat.sqrt N ≤ 3 * Nat.sqrt N := by omega
  rw [sublevel_eq_prefix x, Nat.card_Icc]
  omega

/-- **Conversely, a positional prefix is a magnitude sublevel set**: cutting the
window at position `c` is the same as cutting the residues at `residue N c`. -/
theorem prefix_eq_sublevel {c : ℕ} (hc : Nat.sqrt N + 1 ≤ c) :
    (window N).filter (fun j => j ≤ c)
      = (window N).filter (fun j => residue N j ≤ residue N c) := by
  ext j
  simp only [window, Finset.mem_filter, Finset.mem_Icc]
  constructor
  · rintro ⟨⟨hlo, hhi⟩, hjc⟩
    refine ⟨⟨hlo, hhi⟩, ?_⟩
    rcases eq_or_lt_of_le hjc with heq | hlt
    · simp [heq]
    · exact le_of_lt (Spike.Degeneracy.residue_strictMonoOn hlo hlt)
  · rintro ⟨⟨hlo, hhi⟩, hres⟩
    refine ⟨⟨hlo, hhi⟩, ?_⟩
    by_contra hcon
    push_neg at hcon
    exact absurd hres (not_le.mpr (Spike.Degeneracy.residue_strictMonoOn hc hcon))

/-! ### The round-85 window: the decile cut *is* a magnitude cut -/

section Divisible

variable (m : ℕ)

/-- On the exactly divisible modulus `N = (5m)^2` the square root is `5m`. -/
theorem sqrt_sq_five (m : ℕ) : Nat.sqrt ((5 * m) ^ 2) = 5 * m := Nat.sqrt_eq' (5 * m)

/-- The window of `N = (5m)^2` has exactly `10 * m` positions. -/
theorem window_card (m : ℕ) : (window ((5 * m) ^ 2)).card = 10 * m := by
  rw [window, Nat.card_Icc, sqrt_sq_five]
  omega

/-- The residue at position `5m + t` of the modulus `(5m)^2` is `10mt + t^2`. -/
theorem residue_shift (m t : ℕ) :
    residue ((5 * m) ^ 2) (5 * m + t) = 10 * m * t + t ^ 2 := by
  have h : (5 * m + t) ^ 2 = (5 * m) ^ 2 + (10 * m * t + t ^ 2) := by ring
  simp only [residue, h]
  omega

/-- **The decile cut is a magnitude cut.**  On the window of `N = (5m)^2` the
first-decile predicate is *equivalent* to the residue threshold `v ≤ 11 m^2`.
There is no positional information in the cut beyond the magnitude cut. -/
theorem firstDecile_eq_residue_sublevel (m : ℕ) {j : ℕ}
    (hj : j ∈ window ((5 * m) ^ 2)) :
    inFirstDecile ((5 * m) ^ 2) j ↔ residue ((5 * m) ^ 2) j ≤ 11 * m ^ 2 := by
  simp only [window, Finset.mem_Icc, sqrt_sq_five] at hj
  obtain ⟨hlo, hhi⟩ := hj
  obtain ⟨t, rfl⟩ : ∃ t, j = 5 * m + t := ⟨j - 5 * m, by omega⟩
  have hres := residue_shift m t
  constructor
  · rintro ⟨-, hdec⟩
    have ht : t ≤ m := by
      simp only [sqrt_sq_five] at hdec
      omega
    have : 10 * m * t + t ^ 2 ≤ 10 * m * m + m ^ 2 := by
      have h1 : 10 * m * t ≤ 10 * m * m := Nat.mul_le_mul_left _ ht
      have h2 : t ^ 2 ≤ m ^ 2 := Nat.pow_le_pow_left ht 2
      omega
    rw [hres]
    nlinarith
  · intro hle
    rw [hres] at hle
    have ht : t ≤ m := by
      by_contra hcon
      push_neg at hcon
      have h1 : 10 * m * (m + 1) ≤ 10 * m * t := Nat.mul_le_mul_left _ hcon
      nlinarith
    refine ⟨⟨by simpa [sqrt_sq_five] using hlo, by simpa [sqrt_sq_five] using hhi⟩, ?_⟩
    simp only [sqrt_sq_five]
    omega

/-- The first decile of that window has exactly `m` positions. -/
theorem firstDecile_card (m : ℕ) :
    ((window ((5 * m) ^ 2)).filter (fun j => inFirstDecile ((5 * m) ^ 2) j)).card = m := by
  classical
  have hset : (window ((5 * m) ^ 2)).filter (fun j => inFirstDecile ((5 * m) ^ 2) j)
      = Finset.Icc (5 * m + 1) (6 * m) := by
    ext j
    simp only [window, Finset.mem_filter, Finset.mem_Icc, inFirstDecile, inWindow,
      sqrt_sq_five]
    constructor
    · rintro ⟨⟨hlo, -⟩, -, hdec⟩
      exact ⟨hlo, by omega⟩
    · rintro ⟨hlo, hhi⟩
      exact ⟨⟨hlo, by omega⟩, ⟨hlo, by omega⟩, by omega⟩
  rw [hset, Nat.card_Icc]
  omega

/-- The name is literal: the first decile is exactly a tenth of the window. -/
theorem firstDecile_is_a_tenth (m : ℕ) :
    10 * ((window ((5 * m) ^ 2)).filter (fun j => inFirstDecile ((5 * m) ^ 2) j)).card
      = (window ((5 * m) ^ 2)).card := by
  rw [firstDecile_card, window_card]

/-- **The two analyses coincide.**  The number of first-decile positions equals
the number of positions with residue at most `11 m^2`: a positional decile
statistic and a magnitude threshold statistic are the same statistic. -/
theorem card_residue_le_eq_firstDecile_card (m : ℕ) :
    ((window ((5 * m) ^ 2)).filter (fun j => residue ((5 * m) ^ 2) j ≤ 11 * m ^ 2)).card
      = ((window ((5 * m) ^ 2)).filter (fun j => inFirstDecile ((5 * m) ^ 2) j)).card := by
  classical
  refine congrArg Finset.card (Finset.filter_congr ?_)
  intro j hj
  simpa [eq_iff_iff] using (firstDecile_eq_residue_sublevel m hj).symm

end Divisible

end Spike.Quantile