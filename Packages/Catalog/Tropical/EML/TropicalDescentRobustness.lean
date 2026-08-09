import Tropical.EML.TropicalMedianDescent

/-!
# Robustness and expressivity of clipped tropical subgradient descent

This file continues `Tropical.EML.TropicalMedianDescent` (which itself extends the
catalog files `Applications.EML.TropicalGradientFlow` and
`Applications.EML.TropicalGDConvergence`) in three directions.

* **Perturbed tropical limit.**  If every clipped update is corrupted by an error
  of size at most `ε ≤ η`, the parameter distance after `n` steps is at most
  `max ε (|x₀ - m| - n (η - ε))`  (`perturbed_distance_bound`).  Outside the closed
  `ε`-ball the pure bound `|x₀ - m| - n (η - ε)` therefore still holds
  (`perturbed_distance_before_ball`), and the trajectory enters the `ε`-ball after
  finitely many steps and never leaves it (`perturbed_enters_ball`).
  The `max ε` is unavoidable: `perturbed_ball_bound_sharp` exhibits a perturbed
  trajectory sitting permanently at distance exactly `ε`, so the naive bound
  `max 0 (|x₀ - m| - n (η - ε))` is *false*.

* **Vector tropical monomials.**  For a separable `d`-parameter tropical affine
  model with per-coordinate odd samples, simultaneous clipped descent terminates
  after exactly the maximum of the `d` coordinatewise termination times
  (`sep_descent_max_termination`), and the point it reaches is the unique
  empirical-risk minimizer (`sep_minimizes_iff`).

* **ReLU lower bound.**  The clipped update `x ↦ tropicalFlow m t x` with `t > 0`
  is neither convex nor concave, hence *no* single ReLU unit `x ↦ a·relu(bx+c)+e`
  can represent it (`no_single_relu`), while two shifted ReLU units do
  (`relu_width_two_exact_and_minimal`, using the catalog's
  `tropicalFlow_eq_two_relu`).  This is an exact width-two lower bound.
-/

noncomputable section

open Filter Set Topology
open EMLTropicalGradientFlow EMLTropicalGD TropicalMedianDescent

namespace TropicalDescentRobustness

/-! ## Perturbed clipped descent -/

/-- One perturbed step contracts the distance by `η` up to the perturbation `ε`. -/
theorem perturbed_step_bound {m η ε : ℝ} {u : ℕ → ℝ}
    (hstep : ∀ n, |u (n + 1) - tropicalFlow m η (u n)| ≤ ε) (n : ℕ) :
    |u (n + 1) - m| ≤ ε + max 0 (|u n - m| - η) := by
  have h1 : |u (n + 1) - m|
      ≤ |u (n + 1) - tropicalFlow m η (u n)| + |tropicalFlow m η (u n) - m| :=
    abs_sub_le _ _ _
  rw [tropicalFlow_distance] at h1
  linarith [hstep n]

/-- **Perturbed tropical limit.**  With per-step error at most `ε ≤ η`, the distance
to the minimizer after `n` steps is at most `max ε (|x₀ - m| - n (η - ε))`. -/
theorem perturbed_distance_bound {m η ε : ℝ} {u : ℕ → ℝ} (hηε : ε ≤ η)
    (hstep : ∀ n, |u (n + 1) - tropicalFlow m η (u n)| ≤ ε) (n : ℕ) :
    |u n - m| ≤ max ε (|u 0 - m| - (n : ℝ) * (η - ε)) := by
  induction n with
  | zero => simp
  | succ n ih =>
      have hk := perturbed_step_bound hstep n
      have hcast : ((n + 1 : ℕ) : ℝ) = (n : ℝ) + 1 := by push_cast; ring
      rw [hcast]
      rcases max_cases 0 (|u n - m| - η) with ⟨h1, h1'⟩ | ⟨h1, h1'⟩ <;> rw [h1] at hk <;>
        rcases max_cases ε (|u 0 - m| - (n : ℝ) * (η - ε)) with ⟨h2, h2'⟩ | ⟨h2, h2'⟩ <;>
          rw [h2] at ih <;>
        [ (refine le_trans ?_ (le_max_left _ _)); (refine le_trans ?_ (le_max_left _ _));
          (refine le_trans ?_ (le_max_left _ _)); (refine le_trans ?_ (le_max_right _ _))] <;>
        nlinarith

/-- Outside the closed `ε`-ball the unperturbed-style linear bound still holds. -/
theorem perturbed_distance_before_ball {m η ε : ℝ} {u : ℕ → ℝ} (hηε : ε ≤ η)
    (hstep : ∀ n, |u (n + 1) - tropicalFlow m η (u n)| ≤ ε) {n : ℕ}
    (hout : ε < |u n - m|) :
    |u n - m| ≤ |u 0 - m| - (n : ℝ) * (η - ε) := by
  have h := perturbed_distance_bound hηε hstep n
  rcases max_cases ε (|u 0 - m| - (n : ℝ) * (η - ε)) with ⟨h1, _⟩ | ⟨h1, _⟩ <;> rw [h1] at h
  · linarith
  · exact h

/-- The perturbed trajectory enters the closed `ε`-ball around the minimizer in
finitely many steps, and stays there. -/
theorem perturbed_enters_ball {m η ε : ℝ} {u : ℕ → ℝ} (hε : 0 ≤ ε) (hηε : ε < η)
    (hstep : ∀ n, |u (n + 1) - tropicalFlow m η (u n)| ≤ ε) :
    ∃ N : ℕ, ∀ n ≥ N, |u n - m| ≤ ε := by
  obtain ⟨N, hN⟩ := exists_nat_gt (|u 0 - m| / (η - ε))
  refine ⟨N, fun n hn => ?_⟩
  have hpos : 0 < η - ε := by linarith
  have hNlt : |u 0 - m| < (N : ℝ) * (η - ε) := by
    rw [← div_lt_iff₀ hpos]; exact_mod_cast hN
  have hcast : (N : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hmono : (N : ℝ) * (η - ε) ≤ (n : ℝ) * (η - ε) :=
    mul_le_mul_of_nonneg_right hcast hpos.le
  have h := perturbed_distance_bound hηε.le hstep n
  rcases max_cases ε (|u 0 - m| - (n : ℝ) * (η - ε)) with ⟨h1, _⟩ | ⟨h1, _⟩ <;> rw [h1] at h
  · exact h
  · linarith

/-- **The `max ε` in `perturbed_distance_bound` cannot be replaced by `max 0`.**
Sitting permanently at distance `ε` on the right of the minimizer is a legitimate
perturbed trajectory, so the distance does not go to `0`. -/
theorem perturbed_ball_bound_sharp {m η ε : ℝ} (hε : 0 < ε) (hηε : ε ≤ η) :
    ∃ u : ℕ → ℝ, (∀ n, |u (n + 1) - tropicalFlow m η (u n)| ≤ ε) ∧
      (∀ n, |u n - m| = ε) := by
  refine ⟨fun _ => m + ε, fun n => ?_, fun n => ?_⟩
  · have hflow : tropicalFlow m η (m + ε) = m := by
      unfold tropicalFlow
      rw [if_neg (by linarith), max_eq_left (by linarith)]
    rw [hflow]
    simpa using le_of_eq (abs_of_nonneg hε.le)
  · simpa using abs_of_nonneg hε.le

/-! ## Separable vector tropical monomials -/

/-- Simultaneous clipped descent on `d` independent tropical coordinates. -/
def vecStep {d : ℕ} (m : Fin d → ℝ) (η : ℝ) (x : Fin d → ℝ) : Fin d → ℝ :=
  fun i => tropicalFlow (m i) η (x i)

/-- Separable `d`-parameter tropical `L¹` loss with odd samples in each coordinate. -/
def sepLoss {d : ℕ} (kk : Fin d → ℕ) (xs : Fin d → ℕ → ℝ) (θ : Fin d → ℝ) : ℝ :=
  ∑ i, l1Loss (2 * kk i + 1) (xs i) (θ i)

/-- The coordinatewise median of a separable sample. -/
def sepMedian {d : ℕ} (kk : Fin d → ℕ) (xs : Fin d → ℕ → ℝ) : Fin d → ℝ :=
  fun i => xs i (kk i)

theorem vecStep_iterate_apply {d : ℕ} {m : Fin d → ℝ} {η : ℝ} (x : Fin d → ℝ) (n : ℕ)
    (i : Fin d) : (vecStep m η)^[n] x i = (tropicalFlow (m i) η)^[n] (x i) := by
  induction n generalizing x with
  | zero => simp
  | succ n ih => rw [Function.iterate_succ_apply, Function.iterate_succ_apply, ih]; rfl

/-- Vector termination is the conjunction of the scalar termination conditions. -/
theorem vecStep_terminates_iff {d : ℕ} {m x : Fin d → ℝ} {η : ℝ} (hη : 0 < η) (n : ℕ) :
    (vecStep m η)^[n] x = m ↔ ∀ i, |x i - m i| ≤ (n : ℝ) * η := by
  constructor
  · intro h i
    have hi := congrFun h i
    rw [vecStep_iterate_apply] at hi
    exact (odd_descent_iterate_eq_iff hη n).mp hi
  · intro h
    funext i
    rw [vecStep_iterate_apply]
    exact (odd_descent_iterate_eq_iff hη n).mpr (h i)

/-- **Vector termination time.**  Simultaneous clipped descent terminates exactly at
the maximum of the `d` coordinatewise termination times. -/
theorem vecStep_max_termination {d : ℕ} {m x : Fin d → ℝ} {η : ℝ} (hη : 0 < η) :
    (vecStep m η)^[Finset.univ.sup fun i => ⌈|x i - m i| / η⌉₊] x = m ∧
    ∀ n < Finset.univ.sup fun i => ⌈|x i - m i| / η⌉₊, (vecStep m η)^[n] x ≠ m := by
  constructor
  · rw [vecStep_terminates_iff hη]
    intro i
    have hle : (⌈|x i - m i| / η⌉₊ : ℕ) ≤ Finset.univ.sup fun j => ⌈|x j - m j| / η⌉₊ :=
      Finset.le_sup (f := fun j => ⌈|x j - m j| / η⌉₊) (Finset.mem_univ i)
    have hc := Nat.le_ceil (|x i - m i| / η)
    have hcast :
        ((⌈|x i - m i| / η⌉₊ : ℕ) : ℝ)
          ≤ ((Finset.univ.sup fun j => ⌈|x j - m j| / η⌉₊ : ℕ) : ℝ) := by
      exact_mod_cast hle
    have hdiv : |x i - m i| / η
        ≤ ((Finset.univ.sup fun j => ⌈|x j - m j| / η⌉₊ : ℕ) : ℝ) := le_trans hc hcast
    rwa [div_le_iff₀ hη] at hdiv
  · intro n hn heq
    obtain ⟨i, -, hi⟩ := Finset.lt_sup_iff.mp hn
    have hcoord := congrFun heq i
    rw [vecStep_iterate_apply] at hcoord
    exact odd_descent_before_ceiling hη hi hcoord

/-- Separable linear growth: the vector loss grows at least like the `ℓ¹` distance
to the coordinatewise median. -/
theorem sep_loss_growth {d : ℕ} {kk : Fin d → ℕ} {xs : Fin d → ℕ → ℝ}
    (hxs : ∀ i, SortedSample (2 * kk i + 1) (xs i)) (θ : Fin d → ℝ) :
    sepLoss kk xs (sepMedian kk xs) + ∑ i, |θ i - sepMedian kk xs i| ≤ sepLoss kk xs θ := by
  unfold sepLoss sepMedian
  rw [← Finset.sum_add_distrib]
  exact Finset.sum_le_sum fun i _ => odd_l1Loss_growth (hxs i) (θ i)

/-- The coordinatewise median is the unique minimizer of a separable tropical loss. -/
theorem sep_minimizes_iff {d : ℕ} {kk : Fin d → ℕ} {xs : Fin d → ℕ → ℝ}
    (hxs : ∀ i, SortedSample (2 * kk i + 1) (xs i)) (θ : Fin d → ℝ) :
    (∀ y : Fin d → ℝ, sepLoss kk xs θ ≤ sepLoss kk xs y) ↔ θ = sepMedian kk xs := by
  constructor
  · intro h
    have h1 := h (sepMedian kk xs)
    have h2 := sep_loss_growth hxs θ
    have h3 : ∑ i, |θ i - sepMedian kk xs i| ≤ 0 := by linarith
    have h4 : ∀ i ∈ Finset.univ, |θ i - sepMedian kk xs i| = 0 :=
      (Finset.sum_eq_zero_iff_of_nonneg fun i _ => abs_nonneg _).mp
        (le_antisymm h3 (Finset.sum_nonneg fun i _ => abs_nonneg _))
    funext i
    have h5 := abs_eq_zero.mp (h4 i (Finset.mem_univ i))
    linarith
  · rintro rfl y
    have h := sep_loss_growth hxs y
    have hnn : 0 ≤ ∑ i, |y i - sepMedian kk xs i| := Finset.sum_nonneg fun i _ => abs_nonneg _
    linarith

/-- **Separable training theorem.**  Simultaneous clipped descent on a separable
`d`-parameter tropical affine model stops exactly at the maximum of the `d`
coordinatewise termination times, and the parameter it reaches is the unique
empirical-risk minimizer of the separable tropical `L¹` loss. -/
theorem sep_descent_max_termination {d : ℕ} {kk : Fin d → ℕ} {xs : Fin d → ℕ → ℝ}
    (hxs : ∀ i, SortedSample (2 * kk i + 1) (xs i)) {η : ℝ} (hη : 0 < η) (x : Fin d → ℝ) :
    (vecStep (sepMedian kk xs) η)^[Finset.univ.sup
        fun i => ⌈|x i - sepMedian kk xs i| / η⌉₊] x = sepMedian kk xs ∧
    (∀ n < Finset.univ.sup fun i => ⌈|x i - sepMedian kk xs i| / η⌉₊,
      (vecStep (sepMedian kk xs) η)^[n] x ≠ sepMedian kk xs) ∧
    (∀ y : Fin d → ℝ, sepLoss kk xs (sepMedian kk xs) ≤ sepLoss kk xs y) := by
  obtain ⟨h1, h2⟩ := vecStep_max_termination (m := sepMedian kk xs) (x := x) hη
  exact ⟨h1, h2, (sep_minimizes_iff hxs _).mpr rfl⟩

/-! ## Exact ReLU width for the clipped tropical update -/

/-- `relu` is midpoint convex. -/
theorem relu_midpoint (u v : ℝ) : relu ((u + v) / 2) ≤ (relu u + relu v) / 2 := by
  unfold relu
  refine max_le ?_ ?_
  · have h1 := le_max_left u 0
    have h2 := le_max_left v 0
    linarith
  · have h1 := le_max_right u 0
    have h2 := le_max_right v 0
    linarith

/-- **ReLU lower bound.**  For `t > 0` no single ReLU unit `x ↦ a·relu(b x + c) + e`
represents the two-sided clipped tropical update: such a unit is convex or concave,
while the clipped update is neither (it is flat between two opposite kinks). -/
theorem no_single_relu {m t : ℝ} (ht : 0 < t) (a b c e : ℝ) :
    ∃ x : ℝ, a * relu (b * x + c) + e ≠ tropicalFlow m t x := by
  by_contra hcon
  push_neg at hcon
  have f1 : tropicalFlow m t (m - 2 * t) = m - t := by
    unfold tropicalFlow
    rw [if_pos (by linarith), min_eq_right (by linarith)]
    ring
  have f2 : tropicalFlow m t (m - t) = m := by
    unfold tropicalFlow
    rw [if_pos (by linarith), min_eq_left (by linarith)]
  have f3 : tropicalFlow m t m = m := by
    unfold tropicalFlow
    rw [if_neg (by linarith), max_eq_left (by linarith)]
  have f4 : tropicalFlow m t (m + t) = m := by
    unfold tropicalFlow
    rw [if_neg (by linarith), max_eq_left (by linarith)]
  have f5 : tropicalFlow m t (m + 2 * t) = m + t := by
    unfold tropicalFlow
    rw [if_neg (by linarith), max_eq_right (by linarith)]
    ring
  rcases le_total 0 a with ha | ha
  · -- a convex unit cannot rise from `m - t` to `m` and then stay flat
    have hmid :
        relu (b * (m - t) + c) ≤ (relu (b * (m - 2 * t) + c) + relu (b * m + c)) / 2 := by
      have h := relu_midpoint (b * (m - 2 * t) + c) (b * m + c)
      have heq : (b * (m - 2 * t) + c + (b * m + c)) / 2 = b * (m - t) + c := by ring
      rwa [heq] at h
    have h1 := hcon (m - 2 * t)
    have h2 := hcon (m - t)
    have h3 := hcon m
    rw [f1] at h1; rw [f2] at h2; rw [f3] at h3
    nlinarith
  · -- a concave unit cannot stay flat and then rise from `m` to `m + t`
    have hmid :
        relu (b * (m + t) + c) ≤ (relu (b * m + c) + relu (b * (m + 2 * t) + c)) / 2 := by
      have h := relu_midpoint (b * m + c) (b * (m + 2 * t) + c)
      have heq : (b * m + c + (b * (m + 2 * t) + c)) / 2 = b * (m + t) + c := by ring
      rwa [heq] at h
    have h3 := hcon m
    have h4 := hcon (m + t)
    have h5 := hcon (m + 2 * t)
    rw [f3] at h3; rw [f4] at h4; rw [f5] at h5
    nlinarith

/-- **Exact ReLU width two.**  Two shifted ReLU units realize the clipped tropical
update exactly, and one never does. -/
theorem relu_width_two_exact_and_minimal {m t : ℝ} (ht : 0 < t) :
    (∀ x : ℝ, tropicalFlow m t x = m + relu (x - m - t) - relu (m - x - t)) ∧
    (∀ a b c e : ℝ, ∃ x : ℝ, a * relu (b * x + c) + e ≠ tropicalFlow m t x) :=
  ⟨fun _ => tropicalFlow_eq_two_relu ht.le, fun a b c e => no_single_relu ht a b c e⟩

/-! ## Kernel-checked instances -/

example : vecStep ![1, -2] 1 ![4, -4] = ![3, -3] := by
  funext i
  fin_cases i <;> norm_num [vecStep, tropicalFlow]

example : (vecStep ![1, -2] 1)^[3] ![4, -4] = ![1, -2] := by
  funext i
  fin_cases i <;>
    simp [vecStep, Function.iterate_succ_apply] <;> norm_num [tropicalFlow]

/-- Two ReLU units reproduce a concrete clipped update. -/
example : (1 : ℝ) + relu (4 - 1 - 1) - relu (1 - 4 - 1) = 3 := by
  norm_num [relu]

end TropicalDescentRobustness