import Tropical.EML.TropicalReluWidth

/-!
# Tropical boxes: even samples in `d` parameters

`Tropical.EML.TropicalMedianDescent` shows that for an even scalar sample the
tropical `L¹` minimizer set is a segment, and
`Tropical.EML.TropicalDescentRobustness` handles `d` separable coordinates with odd
samples (a single point).  This file combines the two: for a separable
`d`-parameter tropical affine model with **even** samples in each coordinate the
minimizer set is exactly a *box* — the product of the `d` central segments — and
simultaneous clipped descent reaches the metric projection of the initialization
onto that box, in the maximum of the `d` coordinatewise times.

Main results.

* `sep_minimizes_iff_coordinatewise` : a general separability principle — a
  separable objective is minimized exactly when every coordinate is.
* `box_minimizes_iff_mem_box` : the minimizer set of the separable even-sample
  tropical `L¹` loss is exactly `∏ᵢ [xᵢ(kᵢ), xᵢ(kᵢ+1)]`.
* `boxStep_terminates` : simultaneous clipped descent freezes at the projection of
  the initialization onto the box after finitely many steps.
* `box_descent_reaches_minimizer` : and that projection is an empirical-risk
  minimizer, so training halts at an exact optimum in finite time.
-/

noncomputable section

open EMLTropicalGradientFlow EMLTropicalGD TropicalMedianDescent

namespace TropicalBoxDescent

/-! ## A separability principle -/

/-- A separable objective is minimized exactly when each coordinate is minimized. -/
theorem sep_minimizes_iff_coordinatewise {d : ℕ} (F : Fin d → ℝ → ℝ) (θ : Fin d → ℝ) :
    (∀ y : Fin d → ℝ, ∑ i, F i (θ i) ≤ ∑ i, F i (y i)) ↔ ∀ i (t : ℝ), F i (θ i) ≤ F i t := by
  constructor
  · intro h i t
    have hy := h (Function.update θ i t)
    have hsplit : ∀ z : Fin d → ℝ,
        ∑ j, F j (z j) = F i (z i) + ∑ j ∈ Finset.univ.erase i, F j (z j) := by
      intro z
      rw [Finset.add_sum_erase _ (fun j => F j (z j)) (Finset.mem_univ i)]
    rw [hsplit θ, hsplit (Function.update θ i t)] at hy
    have hupd : ∀ j ∈ Finset.univ.erase i,
        F j (Function.update θ i t j) = F j (θ j) := by
      intro j hj
      rw [Function.update_of_ne (Finset.ne_of_mem_erase hj) t θ]
    rw [Finset.sum_congr rfl hupd, Function.update_self] at hy
    linarith
  · intro h y
    exact Finset.sum_le_sum fun i _ => h i (y i)

/-! ## The even-sample box -/

/-- Separable `d`-parameter tropical `L¹` loss with an even sample in each coordinate. -/
def boxLoss {d : ℕ} (kk : Fin d → ℕ) (xs : Fin d → ℕ → ℝ) (θ : Fin d → ℝ) : ℝ :=
  ∑ i, l1Loss (2 * kk i + 2) (xs i) (θ i)

/-- Lower corner of the tropical minimizer box. -/
def boxLo {d : ℕ} (kk : Fin d → ℕ) (xs : Fin d → ℕ → ℝ) : Fin d → ℝ := fun i => xs i (kk i)

/-- Upper corner of the tropical minimizer box. -/
def boxHi {d : ℕ} (kk : Fin d → ℕ) (xs : Fin d → ℕ → ℝ) : Fin d → ℝ :=
  fun i => xs i (kk i + 1)

/-- **The minimizer set of a separable even-sample tropical loss is exactly a box.** -/
theorem box_minimizes_iff_mem_box {d : ℕ} {kk : Fin d → ℕ} {xs : Fin d → ℕ → ℝ}
    (hxs : ∀ i, SortedSample (2 * kk i + 2) (xs i)) (θ : Fin d → ℝ) :
    (∀ y : Fin d → ℝ, boxLoss kk xs θ ≤ boxLoss kk xs y) ↔
      ∀ i, θ i ∈ Set.Icc (boxLo kk xs i) (boxHi kk xs i) := by
  unfold boxLoss
  rw [sep_minimizes_iff_coordinatewise (fun i t => l1Loss (2 * kk i + 2) (xs i) t) θ]
  constructor
  · intro h i
    exact (even_minimizes_iff_mem_Icc (hxs i) (θ i)).mp (fun y => h i y)
  · intro h i t
    exact (even_minimizes_iff_mem_Icc (hxs i) (θ i)).mpr (h i) t

/-! ## Simultaneous clipped descent onto the box -/

/-- Coordinatewise clipped descent toward a box. -/
def boxStep {d : ℕ} (lo hi : Fin d → ℝ) (η : ℝ) (θ : Fin d → ℝ) : Fin d → ℝ :=
  fun i => intervalStep (lo i) (hi i) η (θ i)

theorem boxStep_iterate_apply {d : ℕ} {lo hi : Fin d → ℝ} {η : ℝ} (θ : Fin d → ℝ) (n : ℕ)
    (i : Fin d) :
    (boxStep lo hi η)^[n] θ i = (intervalStep (lo i) (hi i) η)^[n] (θ i) := by
  induction n generalizing θ with
  | zero => simp
  | succ n ih => rw [Function.iterate_succ_apply, Function.iterate_succ_apply, ih]; rfl

/-- **Descent onto a tropical box terminates** at the coordinatewise projection. -/
theorem boxStep_terminates {d : ℕ} {lo hi : Fin d → ℝ} {η : ℝ} (hη : 0 < η)
    (hlohi : ∀ i, lo i ≤ hi i) (θ : Fin d → ℝ) :
    ∀ n ≥ Finset.univ.sup fun i => ⌈|θ i - projIcc (lo i) (hi i) (θ i)| / η⌉₊,
      (boxStep lo hi η)^[n] θ = fun i => projIcc (lo i) (hi i) (θ i) := by
  intro n hn
  funext i
  rw [boxStep_iterate_apply, intervalStep_iterate hη.le (hlohi i)]
  refine tropicalFlow_eq_median ?_
  have hle : (⌈|θ i - projIcc (lo i) (hi i) (θ i)| / η⌉₊ : ℕ)
      ≤ Finset.univ.sup fun j => ⌈|θ j - projIcc (lo j) (hi j) (θ j)| / η⌉₊ :=
    Finset.le_sup (f := fun j => ⌈|θ j - projIcc (lo j) (hi j) (θ j)| / η⌉₊)
      (Finset.mem_univ i)
  have hc := Nat.le_ceil (|θ i - projIcc (lo i) (hi i) (θ i)| / η)
  have hcast : ((⌈|θ i - projIcc (lo i) (hi i) (θ i)| / η⌉₊ : ℕ) : ℝ) ≤ (n : ℝ) := by
    exact_mod_cast le_trans hle hn
  have hdiv : |θ i - projIcc (lo i) (hi i) (θ i)| / η ≤ (n : ℝ) := le_trans hc hcast
  rwa [div_le_iff₀ hη] at hdiv

/-- **Even-sample vector training theorem.**  For a separable `d`-parameter model with
even samples, simultaneous clipped descent halts after at most the maximum of the `d`
coordinatewise times, at an exact empirical-risk minimizer of the tropical loss. -/
theorem box_descent_reaches_minimizer {d : ℕ} {kk : Fin d → ℕ} {xs : Fin d → ℕ → ℝ}
    (hxs : ∀ i, SortedSample (2 * kk i + 2) (xs i)) {η : ℝ} (hη : 0 < η) (θ : Fin d → ℝ) :
    ∃ N : ℕ, ∀ n ≥ N,
      ((boxStep (boxLo kk xs) (boxHi kk xs) η)^[n] θ
        = fun i => projIcc (boxLo kk xs i) (boxHi kk xs i) (θ i)) ∧
      ∀ y : Fin d → ℝ,
        boxLoss kk xs ((boxStep (boxLo kk xs) (boxHi kk xs) η)^[n] θ) ≤ boxLoss kk xs y := by
  have hlohi : ∀ i, boxLo kk xs i ≤ boxHi kk xs i := fun i =>
    hxs i (kk i) (kk i + 1) (by omega) (by omega)
  refine ⟨Finset.univ.sup fun i =>
    ⌈|θ i - projIcc (boxLo kk xs i) (boxHi kk xs i) (θ i)| / η⌉₊, fun n hn => ?_⟩
  have hreach := boxStep_terminates hη hlohi θ n hn
  refine ⟨hreach, ?_⟩
  rw [hreach]
  exact (box_minimizes_iff_mem_box hxs _).mpr fun i => projIcc_mem (hlohi i)

/-! ## Kernel-checked instance

Two coordinates with the four-point samples `(-3,-1,2,5)` and `(0,1,1,4)`: the
minimizer box is `[-1,2] × [1,1]`, i.e. a segment times a point. -/

/-- A two-coordinate even sample. -/
def sample2d : Fin 2 → ℕ → ℝ := fun i =>
  if i = 0 then (fun j => if j = 0 then -3 else if j = 1 then -1 else if j = 2 then 2 else 5)
  else (fun j => if j = 0 then 0 else if j = 1 then 1 else if j = 2 then 1 else 4)

theorem sample2d_sorted : ∀ i, SortedSample (2 * 1 + 2) (sample2d i) := by
  intro i j j' hjj hj'
  have hj : j < 4 := lt_of_le_of_lt hjj hj'
  fin_cases i <;> interval_cases j <;> interval_cases j' <;>
    simp_all [sample2d] <;> try norm_num

example : boxLo (fun _ => 1) sample2d = ![-1, 1] := by
  funext i
  fin_cases i <;> norm_num [boxLo, sample2d]

example : boxHi (fun _ => 1) sample2d = ![2, 1] := by
  funext i
  fin_cases i <;> norm_num [boxHi, sample2d]

end TropicalBoxDescent