import Applications.EMLTropicalLearning.SubgradientRate
import Applications.EMLTropicalLearning.TropicalLimit

/-!
# Tropical empirical risk minimization: sharpness, rates, and the ReLU comparison

This file completes the learning-theoretic picture for EML networks in the tropical
limit.  The trainable model is the max-plus monomial `tropModel θ z = z + θ` (a
tropical rational function), trained with the tropical `L¹` risk on `2m+1` samples.

Main results:

* `tropL1_sharp_growth` — a **sharpness (error-bound) inequality**:
  `L(θ) ≥ L(θ*) + |θ - θ*|` where `θ*` is the median residual.  The tropical loss has
  a genuine `V`-shape with growth constant `1`; this is the piecewise-linear analogue
  of strong convexity and is what converts loss rates into parameter rates.
* `median_minimizes_tropL1` and `tropL1_minimizer_unique` — the median parameter is the
  unique empirical risk minimizer.
* `tropical_parameter_rate` — subgradient descent reaches parameter error
  `≤ |θ₀ - θ*| · N / √n` before step `n`.
* `risk_landscape_equivalence` — **comparison with ReLU networks**: a function is
  tropical rational *iff* some ReLU expression has the same empirical `L¹` risk on
  *every* data set.  Hence tropical EML training and ReLU training see literally the
  same landscape, and all rates transfer verbatim.
* `tropical_training_main` — the synthesis: unique median minimizer, an explicit
  `O(1/√n)` rate in both risk and parameter, and the statement that every trained model
  and the limit model is a tropical rational function computed exactly by a ReLU
  network.
-/

noncomputable section

open Finset EMLTropicalPWL EMLTropicalSGD

namespace EMLTropicalERM

/-! ## Sharpness of the tropical `L¹` loss -/

/-- Betweenness gives the triangle-type inequality driving the median argument. -/
theorem between_abs_le {u v w x : ℝ} (h : (u ≤ v ∧ v ≤ w) ∨ (w ≤ v ∧ v ≤ u)) :
    |v - u| + |v - w| ≤ |x - u| + |x - w| := by
  have h1 : x - u ≤ |x - u| := le_abs_self _
  have h2 : -(x - u) ≤ |x - u| := neg_le_abs _
  have h3 : x - w ≤ |x - w| := le_abs_self _
  have h4 : -(x - w) ≤ |x - w| := neg_le_abs _
  rcases h with ⟨huv, hvw⟩ | ⟨hwv, hvu⟩
  · rw [abs_of_nonneg (by linarith : (0:ℝ) ≤ v - u), abs_of_nonpos (by linarith : v - w ≤ 0)]
    linarith
  · rw [abs_of_nonpos (by linarith : v - u ≤ 0), abs_of_nonneg (by linarith : (0:ℝ) ≤ v - w)]
    linarith

/-- Doubling a tropical `L¹` loss by the reflection `i ↦ 2m - i` of the sample index. -/
theorem two_mul_tropL1 (y : ℕ → ℝ) (m : ℕ) (x : ℝ) :
    2 * tropL1Loss y (2 * m + 1) x
      = ∑ i ∈ range (2 * m + 1), (|x - y i| + |x - y (2 * m - i)|) := by
  have hrefl : ∑ i ∈ range (2 * m + 1), |x - y (2 * m - i)|
      = ∑ i ∈ range (2 * m + 1), |x - y i| := by
    have h := Finset.sum_range_reflect (fun i => |x - y i|) (2 * m + 1)
    simpa using h
  rw [Finset.sum_add_distrib, hrefl, tropL1Loss]
  ring

/-- **Sharpness / error bound.**  For an ordered sample of odd size the tropical `L¹`
loss grows at least linearly away from the median parameter, with constant `1`. -/
theorem tropL1_sharp_growth {y : ℕ → ℝ} {m : ℕ}
    (hy : ∀ i j : ℕ, i ≤ j → j ≤ 2 * m → y i ≤ y j) (x : ℝ) :
    tropL1Loss y (2 * m + 1) (y m) + |x - y m| ≤ tropL1Loss y (2 * m + 1) x := by
  set N := 2 * m + 1 with hN
  set g : ℕ → ℝ := fun i =>
    (|x - y i| + |x - y (2 * m - i)|) - (|y m - y i| + |y m - y (2 * m - i)|) with hg
  have hbetween : ∀ i ∈ range N,
      (y i ≤ y m ∧ y m ≤ y (2 * m - i)) ∨ (y (2 * m - i) ≤ y m ∧ y m ≤ y i) := by
    intro i hi
    have hiN : i ≤ 2 * m := by
      have := Finset.mem_range.mp hi
      omega
    rcases le_total i m with h | h
    · refine Or.inl ⟨hy i m h (by omega), hy m (2 * m - i) (by omega) (by omega)⟩
    · exact Or.inr ⟨hy (2 * m - i) m (by omega) (by omega), hy m i h hiN⟩
  have hgnonneg : ∀ i ∈ range N, 0 ≤ g i := by
    intro i hi
    have := between_abs_le (u := y i) (v := y m) (w := y (2 * m - i)) (x := x) (hbetween i hi)
    simp only [hg]
    linarith
  have hgm : g m = 2 * |x - y m| := by
    have h2m : 2 * m - m = m := by omega
    simp [hg, h2m]
    ring
  have hmem : m ∈ range N := by
    rw [Finset.mem_range, hN]
    omega
  have hsum : g m ≤ ∑ i ∈ range N, g i := Finset.single_le_sum hgnonneg hmem
  have hsplit : ∑ i ∈ range N, g i
      = 2 * tropL1Loss y N x - 2 * tropL1Loss y N (y m) := by
    simp only [hg, Finset.sum_sub_distrib]
    rw [← two_mul_tropL1 y m x, ← two_mul_tropL1 y m (y m)]
  rw [hgm, hsplit] at hsum
  linarith

/-- The median of an ordered odd sample minimizes the tropical `L¹` loss. -/
theorem median_minimizes_tropL1 {y : ℕ → ℝ} {m : ℕ}
    (hy : ∀ i j : ℕ, i ≤ j → j ≤ 2 * m → y i ≤ y j) (x : ℝ) :
    tropL1Loss y (2 * m + 1) (y m) ≤ tropL1Loss y (2 * m + 1) x := by
  have h := tropL1_sharp_growth hy x
  have := abs_nonneg (x - y m)
  linarith

/-- The minimizer of the tropical `L¹` loss is unique: it is the median parameter. -/
theorem tropL1_minimizer_unique {y : ℕ → ℝ} {m : ℕ}
    (hy : ∀ i j : ℕ, i ≤ j → j ≤ 2 * m → y i ≤ y j) {x : ℝ}
    (hx : ∀ u : ℝ, tropL1Loss y (2 * m + 1) x ≤ tropL1Loss y (2 * m + 1) u) :
    x = y m := by
  have h1 := tropL1_sharp_growth hy x
  have h2 := hx (y m)
  have : |x - y m| ≤ 0 := by linarith
  have := abs_nonneg (x - y m)
  have hzero : |x - y m| = 0 := le_antisymm ‹|x - y m| ≤ 0› ‹0 ≤ |x - y m|›
  have := abs_eq_zero.mp hzero
  linarith

/-- **Parameter convergence rate.**  Sharpness upgrades the `O(1/√n)` risk rate into the
same rate for the distance to the unique optimal parameter. -/
theorem tropical_parameter_rate {y : ℕ → ℝ} {m : ℕ}
    (hy : ∀ i j : ℕ, i ≤ j → j ≤ 2 * m → y i ≤ y j)
    {x₀ : ℝ} (hx₀ : x₀ ≠ y m) {n : ℕ} (hn : 0 < n) :
    ∃ k < n,
      |gdIter (tropL1Sub y (2 * m + 1)) (|x₀ - y m| / ((2 * m + 1 : ℕ) * Real.sqrt n)) x₀ k
        - y m| ≤ |x₀ - y m| * (2 * m + 1 : ℕ) / Real.sqrt n := by
  obtain ⟨k, hk, hbound⟩ :=
    tropical_l1_sqrt_rate y (N := 2 * m + 1) (by omega) hx₀ hn
  refine ⟨k, hk, ?_⟩
  have hsharp := tropL1_sharp_growth hy
    (gdIter (tropL1Sub y (2 * m + 1)) (|x₀ - y m| / ((2 * m + 1 : ℕ) * Real.sqrt n)) x₀ k)
  linarith

/-! ## The tropical model class and the ReLU comparison -/

/-- The trainable tropical model: the max-plus monomial `z ↦ z ⊙ θ = z + θ`. -/
def tropModel (θ z : ℝ) : ℝ := z + θ

theorem tropModel_isTropRat (θ : ℝ) : IsTropRat (tropModel θ) :=
  (isTropRat_affine 1 θ).congr fun z => by simp [tropModel]

/-- Empirical `L¹` risk of a model `f` on the data `(X i, Y i)`, `i < N`. -/
def empRisk (f : ℝ → ℝ) (N : ℕ) (X Y : ℕ → ℝ) : ℝ :=
  ∑ i ∈ range N, |f (X i) - Y i|

/-- Training the tropical monomial is exactly tropical `L¹` minimization over the
reduced residuals `Y i - X i`. -/
theorem empRisk_tropModel (θ : ℝ) (N : ℕ) (X Y : ℕ → ℝ) :
    empRisk (tropModel θ) N X Y = tropL1Loss (fun i => Y i - X i) N θ := by
  simp only [empRisk, tropL1Loss, tropModel]
  refine Finset.sum_congr rfl fun i _ => ?_
  congr 1
  ring

/-- **Risk-landscape equivalence with ReLU networks.**  A one-variable function is
tropical rational precisely when some ReLU expression has the *same* empirical `L¹`
risk on *every* finite data set.  Consequently the tropical hypothesis class and the
ReLU hypothesis class have identical loss landscapes, minimizers and rates. -/
theorem risk_landscape_equivalence (f : ℝ → ℝ) :
    IsTropRat f ↔ ∃ e : ReluExpr, ∀ (N : ℕ) (X Y : ℕ → ℝ),
      empRisk f N X Y = empRisk e.eval N X Y := by
  constructor
  · intro hf
    obtain ⟨e, he⟩ := hf.exists_reluExpr
    exact ⟨e, fun N X Y => by simp only [empRisk, he]⟩
  · rintro ⟨e, he⟩
    have hpoint : ∀ x : ℝ, e.eval x = f x := by
      intro x
      have h := he 1 (fun _ => x) (fun _ => f x)
      simp only [empRisk, Finset.sum_range_one, sub_self, abs_zero] at h
      have : |e.eval x - f x| = 0 := h.symm
      have := abs_eq_zero.mp this
      linarith
    exact e.eval_isTropRat.congr fun x => (hpoint x).symm

/-- Each trained tropical model is exactly computed by a ReLU network of two units. -/
theorem tropModel_reluExpr (θ : ℝ) :
    ∃ e : ReluExpr, ∀ z, e.eval z = tropModel θ z :=
  (tropModel_isTropRat θ).exists_reluExpr

/-! ## Main synthesis theorem -/

/-- **Main theorem: tropical EML training.**  For an odd number `2m+1` of samples whose
residuals `Y i - X i` are ordered:

1. the max-plus monomial with the *median residual* parameter is the unique empirical
   risk minimizer, and the risk is sharp (grows at rate `1`) around it;
2. subgradient descent with step `|θ₀ - θ*| /(N √n)` produces, before step `n`, a
   parameter with both risk gap and parameter error at most `|θ₀ - θ*| N / √n`;
3. every model produced along the way — and the limit model — is a tropical rational
   function, exactly computable by a ReLU network. -/
theorem tropical_training_main {m : ℕ} {X Y : ℕ → ℝ}
    (hmono : ∀ i j : ℕ, i ≤ j → j ≤ 2 * m → Y i - X i ≤ Y j - X j)
    {θ₀ : ℝ} (hθ₀ : θ₀ ≠ Y m - X m) {n : ℕ} (hn : 0 < n) :
    let y : ℕ → ℝ := fun i => Y i - X i
    let N : ℕ := 2 * m + 1
    let θstar : ℝ := Y m - X m
    let D : ℝ := |θ₀ - θstar|
    let η : ℝ := D / ((N : ℝ) * Real.sqrt n)
    (∀ θ : ℝ, empRisk (tropModel θstar) N X Y ≤ empRisk (tropModel θ) N X Y) ∧
    (∀ θ : ℝ, (∀ θ' : ℝ, empRisk (tropModel θ) N X Y ≤ empRisk (tropModel θ') N X Y) →
      θ = θstar) ∧
    (∃ k < n,
      empRisk (tropModel (gdIter (tropL1Sub y N) η θ₀ k)) N X Y
          ≤ empRisk (tropModel θstar) N X Y + D * N / Real.sqrt n ∧
      |gdIter (tropL1Sub y N) η θ₀ k - θstar| ≤ D * N / Real.sqrt n) ∧
    (∀ θ : ℝ, IsTropRat (tropModel θ) ∧ ∃ e : ReluExpr, ∀ z, e.eval z = tropModel θ z) := by
  intro y N θstar D η
  have hy : ∀ i j : ℕ, i ≤ j → j ≤ 2 * m → y i ≤ y j := hmono
  have hstar : θstar = y m := rfl
  refine ⟨?_, ?_, ?_, fun θ => ⟨tropModel_isTropRat θ, tropModel_reluExpr θ⟩⟩
  · intro θ
    rw [empRisk_tropModel, empRisk_tropModel]
    exact median_minimizes_tropL1 hy θ
  · intro θ hθ
    refine tropL1_minimizer_unique hy fun u => ?_
    have := hθ u
    rwa [empRisk_tropModel, empRisk_tropModel] at this
  · obtain ⟨k, hk, hrisk⟩ := tropical_l1_sqrt_rate y (N := N) (by omega) hθ₀ hn
    refine ⟨k, hk, ?_, ?_⟩
    · rw [empRisk_tropModel, empRisk_tropModel]
      exact hrisk
    · have hsharp := tropL1_sharp_growth hy (gdIter (tropL1Sub y N) η θ₀ k)
      linarith

/-! ## Kernel-checked instances -/

example : tropL1Loss (fun i => (i : ℝ)) 3 1 ≤ tropL1Loss (fun i => (i : ℝ)) 3 0 := by
  norm_num [tropL1Loss, Finset.sum_range_succ]

example : empRisk (tropModel 1) 2 (fun i => (i : ℝ)) (fun i => (i : ℝ) + 1) = 0 := by
  norm_num [empRisk, tropModel, Finset.sum_range_succ]

end EMLTropicalERM