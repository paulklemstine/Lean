import Mathlib
import Probability.SpikeInclusionGeometry

/-!
# Position and magnitude are the same statistic at fixed modulus

This is the load-bearing *mechanical degeneracy* of the round-85 analysis, in
exact form.  Inside one modulus `N` the stored residue `v = j^2 - N` is a
strictly increasing function of the window position `j`, and it is invertible:
`j = isqrt (N + v)`.  Hence, at fixed `N`:

* the positional order and the magnitude order coincide
  (`Spike.Degeneracy.residue_strictMonoOn`, `Spike.Degeneracy.residue_lt_iff`);
* the position is a *function of* the residue and vice versa
  (`Spike.Degeneracy.position_of_residue`);
* therefore **any** positional weight is realisable as a magnitude weight and
  conversely (`Spike.Degeneracy.positional_weight_is_magnitude_weight`,
  `Spike.Degeneracy.magnitude_weight_is_positional_weight`): the two model
  families are observationally indistinguishable within a modulus — no
  single-`N` experiment can separate a "positional kernel" from a size effect;
* the counting version `Spike.Degeneracy.count_below_eq_position` shows the two
  empirical quantile functions are literally equal.

The degeneracy is broken only by *pooling across moduli*
(`Spike.Degeneracy.exists_cross_modulus_separation`): two hits with the same
residue can occupy different positions in different windows.  That is precisely
the pooling step which, by the inclusion geometry, also imports the band
composition confound analysed in
`Catalog/Probability/SpikeBandComposition.lean`.  So the design's only source of
identification is also its only source of confounding — the sharp form of the
"no positional kernel component survives" verdict.
-/

namespace Spike.Degeneracy

open Spike

/-- Inside the window, larger position means strictly larger residue. -/
theorem residue_strictMonoOn {N j j' : ℕ} (hj : Nat.sqrt N + 1 ≤ j) (hlt : j < j') :
    residue N j < residue N j' := by
  have hNj : N < j ^ 2 := by
    have h1 : N < (Nat.sqrt N + 1) ^ 2 := by simpa [pow_two] using Nat.lt_succ_sqrt N
    exact lt_of_lt_of_le h1 (Nat.pow_le_pow_left hj 2)
  have hjj : j ^ 2 < j' ^ 2 := Nat.pow_lt_pow_left hlt (by norm_num)
  simp only [residue]
  omega

/-- Equivalently, the residue order *is* the positional order on the window. -/
theorem residue_lt_iff {N j j' : ℕ} (hj : Nat.sqrt N + 1 ≤ j) (hj' : Nat.sqrt N + 1 ≤ j') :
    residue N j < residue N j' ↔ j < j' := by
  constructor
  · intro h
    by_contra hcon
    push_neg at hcon
    rcases eq_or_lt_of_le hcon with heq | hlt
    · simp [heq] at h
    · exact absurd h (not_lt.mpr (le_of_lt (residue_strictMonoOn hj' hlt)))
  · exact residue_strictMonoOn hj

/-- **Exact inversion.**  The position is recovered from the residue by
`j = isqrt (N + v)`. -/
theorem position_of_residue {N j : ℕ} (hj : Nat.sqrt N + 1 ≤ j) :
    Nat.sqrt (N + residue N j) = j := by
  have hNj : N ≤ j ^ 2 := by
    have h1 : N < (Nat.sqrt N + 1) ^ 2 := by simpa [pow_two] using Nat.lt_succ_sqrt N
    exact le_of_lt (lt_of_lt_of_le h1 (Nat.pow_le_pow_left hj 2))
  have : N + residue N j = j ^ 2 := by
    simp only [residue]; omega
  rw [this, Nat.sqrt_eq']

/-- **Every positional weight is a magnitude weight.**  Given any weight `w`
attached to window positions, the magnitude weight `m v = w (isqrt (N + v))`
reproduces it exactly.  A positional kernel is therefore not identifiable
against magnitude kernels at fixed `N`. -/
theorem positional_weight_is_magnitude_weight (N : ℕ) (w : ℕ → ℝ) :
    ∃ m : ℕ → ℝ, ∀ j, Nat.sqrt N + 1 ≤ j → w j = m (residue N j) := by
  refine ⟨fun v => w (Nat.sqrt (N + v)), fun j hj => ?_⟩
  show w j = w (Nat.sqrt (N + residue N j))
  rw [position_of_residue hj]

/-- Conversely every magnitude weight is a positional weight: the degeneracy is
symmetric. -/
theorem magnitude_weight_is_positional_weight (N : ℕ) (m : ℕ → ℝ) :
    ∃ w : ℕ → ℝ, ∀ j, Nat.sqrt N + 1 ≤ j → w j = m (residue N j) :=
  ⟨fun j => m (residue N j), fun _ _ => rfl⟩

/-- The residue map is injective on the window, so the two empirical orderings
carry the same information. -/
theorem residue_injOn {N j j' : ℕ} (hj : Nat.sqrt N + 1 ≤ j) (hj' : Nat.sqrt N + 1 ≤ j')
    (h : residue N j = residue N j') : j = j' := by
  by_contra hne
  rcases lt_or_gt_of_ne hne with hlt | hgt
  · exact absurd h (ne_of_lt (residue_strictMonoOn hj hlt))
  · exact absurd h.symm (ne_of_lt (residue_strictMonoOn hj' hgt))

/-- **The quantile functions coincide.**  Among window positions
`isqrt N + 1, …, j`, the number whose residue does not exceed `residue N j`
is exactly the positional rank `j - isqrt N`.  Position-quantile and
magnitude-quantile are the same statistic. -/
theorem count_below_eq_position {N j : ℕ} (hj : Nat.sqrt N + 1 ≤ j) :
    ((Finset.Icc (Nat.sqrt N + 1) j).filter
      (fun j' => residue N j' ≤ residue N j)).card = j - Nat.sqrt N := by
  have hfilter : (Finset.Icc (Nat.sqrt N + 1) j).filter
      (fun j' => residue N j' ≤ residue N j) = Finset.Icc (Nat.sqrt N + 1) j := by
    refine Finset.filter_true_of_mem ?_
    intro j' hj'
    rcases Finset.mem_Icc.mp hj' with ⟨hlo, hhi⟩
    rcases eq_or_lt_of_le hhi with heq | hlt
    · simp [heq]
    · exact le_of_lt (residue_strictMonoOn hlo hlt)
  rw [hfilter, Nat.card_Icc]
  omega

/-- **Pooling breaks the degeneracy — and only pooling.**  Two different moduli
can carry the same residue at different positions: the residue `v = 12` occurs
at the first window position of `N = 37` and at the second window position of
`N = 24`.
Cross-`N` pooling is thus the sole source of identification, and, by the
inclusion bound, the sole source of the band-composition confound. -/
theorem exists_cross_modulus_separation :
    ∃ N₁ j₁ N₂ j₂ : ℕ,
      Nat.sqrt N₁ + 1 ≤ j₁ ∧ Nat.sqrt N₂ + 1 ≤ j₂ ∧
      residue N₁ j₁ = residue N₂ j₂ ∧
      j₁ - Nat.sqrt N₁ ≠ j₂ - Nat.sqrt N₂ := by
  refine ⟨37, 7, 24, 6, by norm_num, by norm_num, ?_, ?_⟩
  · norm_num [residue]
  · norm_num

end Spike.Degeneracy