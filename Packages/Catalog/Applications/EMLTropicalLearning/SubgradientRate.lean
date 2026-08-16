import Applications.EMLTropicalLearning.TropicalPWL

/-!
# Convergence rates for subgradient descent on tropical (piecewise-linear) losses

In the tropical limit an EML network is piecewise linear, so its empirical `L¹` risk is
a **nonsmooth convex piecewise-linear** function of the parameter and training must be
analysed as subgradient descent, not gradient descent.

This file proves, from scratch:

* `descent_step` — the exact one-step energy inequality for a subgradient step;
* `sum_gap_le` — the telescoped bound
  `2η Σ_{k<n} (f xₖ - f z) + (xₙ - z)² ≤ (x₀ - z)² + n η² G²`;
* `exists_best_iterate` — the classical best-iterate bound
  `min_{k<n} f xₖ - f z ≤ ((x₀ - z)² + n η² G²) / (2 η n)`;
* `best_iterate_sqrt_rate` — with the optimal step `η = D /(G √n)` this is the
  `O(D G / √n)` rate.

These are then instantiated on the tropical `L¹` loss `∑ |x - yᵢ|` of an `N`-sample
training set: `tropL1_isSubgradientOracle`, `tropL1Sub_abs_le`, giving the explicit
rate `tropical_l1_sqrt_rate` with `G = N`.  Finally `tropL1Loss_isTropPoly` records
that the tropical training loss is *itself* a tropical polynomial in the parameter,
so the whole optimization problem stays inside the tropical category.
-/

noncomputable section

open Finset EMLTropicalPWL

namespace EMLTropicalSGD

/-- `g` is a subgradient oracle for `f` on `ℝ`: the affine minorant property. -/
def IsSubgradientOracle (f g : ℝ → ℝ) : Prop :=
  ∀ x y : ℝ, f x + g x * (y - x) ≤ f y

/-- Fixed-step subgradient descent iterates. -/
def gdIter (g : ℝ → ℝ) (η x₀ : ℝ) : ℕ → ℝ
  | 0 => x₀
  | n + 1 => gdIter g η x₀ n - η * g (gdIter g η x₀ n)

@[simp] theorem gdIter_zero (g : ℝ → ℝ) (η x₀ : ℝ) : gdIter g η x₀ 0 = x₀ := rfl

@[simp] theorem gdIter_succ (g : ℝ → ℝ) (η x₀ : ℝ) (n : ℕ) :
    gdIter g η x₀ (n + 1) = gdIter g η x₀ n - η * g (gdIter g η x₀ n) := rfl

/-- **One-step energy inequality.**  A subgradient step contracts the distance to any
comparison point up to the loss gap and a step-size term. -/
theorem descent_step {f g : ℝ → ℝ} (hg : IsSubgradientOracle f g) {G : ℝ}
    (hG : ∀ x, |g x| ≤ G) {η : ℝ} (hη : 0 ≤ η) (z x : ℝ) :
    (x - η * g x - z) ^ 2 ≤ (x - z) ^ 2 - 2 * η * (f x - f z) + η ^ 2 * G ^ 2 := by
  have hsub : f x - f z ≤ g x * (x - z) := by
    have := hg x z
    linarith
  have hgG : g x ^ 2 ≤ G ^ 2 := by
    have h1 : |g x| ≤ G := hG x
    have h2 : (0:ℝ) ≤ |g x| := abs_nonneg _
    nlinarith [sq_abs (g x)]
  have hη2 : (0:ℝ) ≤ η ^ 2 := sq_nonneg η
  nlinarith [mul_le_mul_of_nonneg_left hsub hη]

/-- **Telescoped bound.**  The running average loss gap is controlled by the initial
distance and the accumulated step budget. -/
theorem sum_gap_le {f g : ℝ → ℝ} (hg : IsSubgradientOracle f g) {G : ℝ}
    (hG : ∀ x, |g x| ≤ G) {η : ℝ} (hη : 0 ≤ η) (x₀ z : ℝ) (n : ℕ) :
    2 * η * (∑ k ∈ range n, (f (gdIter g η x₀ k) - f z)) + (gdIter g η x₀ n - z) ^ 2
      ≤ (x₀ - z) ^ 2 + (n : ℝ) * η ^ 2 * G ^ 2 := by
  induction n with
  | zero => simp
  | succ n ih =>
      have hstep := descent_step hg hG hη z (gdIter g η x₀ n)
      rw [Finset.sum_range_succ, gdIter_succ]
      push_cast
      nlinarith [hstep, ih]

/-- **Best-iterate bound** for fixed step size. -/
theorem exists_best_iterate {f g : ℝ → ℝ} (hg : IsSubgradientOracle f g) {G : ℝ}
    (hG : ∀ x, |g x| ≤ G) {η : ℝ} (hη : 0 < η) (x₀ z : ℝ) {n : ℕ} (hn : 0 < n) :
    ∃ k < n, f (gdIter g η x₀ k) - f z
      ≤ ((x₀ - z) ^ 2 + (n : ℝ) * η ^ 2 * G ^ 2) / (2 * η * n) := by
  by_contra hcon
  push_neg at hcon
  set B := ((x₀ - z) ^ 2 + (n : ℝ) * η ^ 2 * G ^ 2) / (2 * η * n) with hB
  have hne : (range n).Nonempty := by
    rw [Finset.nonempty_range_iff]
    omega
  have hsum : (n : ℝ) * B < ∑ k ∈ range n, (f (gdIter g η x₀ k) - f z) := by
    have : ∑ _k ∈ range n, B < ∑ k ∈ range n, (f (gdIter g η x₀ k) - f z) :=
      Finset.sum_lt_sum_of_nonempty hne fun k hk => hcon k (Finset.mem_range.mp hk)
    simpa [Finset.sum_const, Finset.card_range, nsmul_eq_mul] using this
  have hden : (0:ℝ) < 2 * η * n := by
    have : (0:ℝ) < (n : ℝ) := by exact_mod_cast hn
    positivity
  have hBmul : 2 * η * (n : ℝ) * B = (x₀ - z) ^ 2 + (n : ℝ) * η ^ 2 * G ^ 2 := by
    rw [hB]
    field_simp
  have htel := sum_gap_le hg hG hη.le x₀ z n
  nlinarith [sq_nonneg (gdIter g η x₀ n - z), hsum, htel]

/-- **Optimal-step `O(1/√n)` rate.**  With `η = D /(G √n)` where `D = |x₀ - z|`, some
iterate before time `n` has loss gap at most `D G / √n`. -/
theorem best_iterate_sqrt_rate {f g : ℝ → ℝ} (hg : IsSubgradientOracle f g) {G : ℝ}
    (hG : ∀ x, |g x| ≤ G) (hGpos : 0 < G) {x₀ z : ℝ} (hD : x₀ ≠ z) {n : ℕ} (hn : 0 < n) :
    ∃ k < n, f (gdIter g (|x₀ - z| / (G * Real.sqrt n)) x₀ k)
      ≤ f z + |x₀ - z| * G / Real.sqrt n := by
  set D := |x₀ - z| with hDdef
  have hDpos : 0 < D := abs_pos.mpr (sub_ne_zero.mpr hD)
  have hnR : (0:ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hsqrt : 0 < Real.sqrt n := Real.sqrt_pos.mpr hnR
  have hsq : Real.sqrt n ^ 2 = (n : ℝ) := Real.sq_sqrt hnR.le
  set η := D / (G * Real.sqrt n) with hη
  have hηpos : 0 < η := by
    rw [hη]
    positivity
  obtain ⟨k, hk, hbound⟩ := exists_best_iterate hg hG hηpos x₀ z hn
  refine ⟨k, hk, ?_⟩
  have hDsq : (x₀ - z) ^ 2 = D ^ 2 := by
    rw [hDdef, sq_abs]
  have hnum : (x₀ - z) ^ 2 + (n : ℝ) * η ^ 2 * G ^ 2 = 2 * D ^ 2 := by
    rw [hDsq, hη]
    field_simp
    nlinarith [hsq]
  have hdenom : 2 * η * (n : ℝ) = 2 * D * Real.sqrt n / G := by
    rw [hη]
    field_simp
    exact hsq.symm
  have hval : ((x₀ - z) ^ 2 + (n : ℝ) * η ^ 2 * G ^ 2) / (2 * η * n) = D * G / Real.sqrt n := by
    rw [hnum, hdenom]
    field_simp
  rw [hval] at hbound
  linarith

/-! ## The tropical `L¹` training loss of an `N`-sample data set -/

/-- Tropical (max-plus) `L¹` empirical loss on `N` reduced samples. -/
def tropL1Loss (y : ℕ → ℝ) (N : ℕ) (x : ℝ) : ℝ :=
  ∑ i ∈ range N, |x - y i|

/-- The canonical subgradient selection of the tropical `L¹` loss. -/
def tropL1Sub (y : ℕ → ℝ) (N : ℕ) (x : ℝ) : ℝ :=
  ∑ i ∈ range N, (if y i ≤ x then (1:ℝ) else -1)

theorem tropL1_isSubgradientOracle (y : ℕ → ℝ) (N : ℕ) :
    IsSubgradientOracle (tropL1Loss y N) (tropL1Sub y N) := by
  intro x u
  have hterm : ∀ i ∈ range N,
      |x - y i| + (if y i ≤ x then (1:ℝ) else -1) * (u - x) ≤ |u - y i| := by
    intro i _
    by_cases h : y i ≤ x
    · rw [if_pos h, abs_of_nonneg (by linarith : 0 ≤ x - y i)]
      have : u - y i ≤ |u - y i| := le_abs_self _
      linarith
    · push_neg at h
      rw [if_neg (not_le.mpr h), abs_of_nonpos (by linarith : x - y i ≤ 0)]
      have : -(u - y i) ≤ |u - y i| := neg_le_abs _
      linarith
  have hsum := Finset.sum_le_sum hterm
  rw [Finset.sum_add_distrib, ← Finset.sum_mul] at hsum
  exact hsum

theorem tropL1Sub_abs_le (y : ℕ → ℝ) (N : ℕ) (x : ℝ) : |tropL1Sub y N x| ≤ (N : ℝ) := by
  refine le_trans (Finset.abs_sum_le_sum_abs _ _) ?_
  have h : ∀ i ∈ range N, |if y i ≤ x then (1:ℝ) else -1| ≤ 1 := by
    intro i _
    by_cases h : y i ≤ x <;> simp [h]
  refine le_trans (Finset.sum_le_sum h) ?_
  simp

/-- The tropical loss is itself a tropical polynomial in the parameter: minimizing it is
optimization *inside* the tropical semiring. -/
theorem tropL1Loss_isTropPoly (y : ℕ → ℝ) (N : ℕ) : IsTropPoly (tropL1Loss y N) := by
  induction N with
  | zero =>
      have h : ∀ x : ℝ, tropL1Loss y 0 x = 0 := by intro x; simp [tropL1Loss]
      obtain ⟨b, l, hb⟩ := isTropPoly_const (0:ℝ)
      exact ⟨b, l, fun x => (h x).trans (hb x)⟩
  | succ N ih =>
      have habs : IsTropPoly fun x => |x - y N| := by
        have h1 : IsTropPoly fun x : ℝ => 1 * x + (-y N) := isTropPoly_affine 1 (-y N)
        have h2 : IsTropPoly fun x : ℝ => (-1) * x + y N := isTropPoly_affine (-1) (y N)
        refine (IsTropPoly.max h1 h2).congr fun x => ?_
        rcases le_total (y N) x with h | h
        · rw [abs_of_nonneg (by linarith : 0 ≤ x - y N),
            max_eq_left (by linarith : (-1) * x + y N ≤ 1 * x + (-y N))]
          ring
        · rw [abs_of_nonpos (by linarith : x - y N ≤ 0),
            max_eq_right (by linarith : 1 * x + (-y N) ≤ (-1) * x + y N)]
          ring
      refine (ih.add habs).congr fun x => ?_
      simp [tropL1Loss, Finset.sum_range_succ]

/-- Hence the tropical training loss is convex, which is what legitimises the
subgradient analysis above. -/
theorem tropL1Loss_convexOn (y : ℕ → ℝ) (N : ℕ) :
    ConvexOn ℝ Set.univ (tropL1Loss y N) := by
  obtain ⟨b, l, hb⟩ := tropL1Loss_isTropPoly y N
  have hfun : tropL1Loss y N = tpEval b l := funext hb
  rw [hfun]
  exact tpEval_convexOn b l

/-- **Explicit convergence rate for tropical `L¹` training.**  Subgradient descent with
step `η = |x₀ - z| /(N √n)` produces an iterate whose tropical loss exceeds that of any
comparison parameter `z` by at most `|x₀ - z| N / √n`. -/
theorem tropical_l1_sqrt_rate (y : ℕ → ℝ) {N : ℕ} (hN : 0 < N) {x₀ z : ℝ} (hD : x₀ ≠ z)
    {n : ℕ} (hn : 0 < n) :
    ∃ k < n, tropL1Loss y N
        (gdIter (tropL1Sub y N) (|x₀ - z| / ((N : ℝ) * Real.sqrt n)) x₀ k)
      ≤ tropL1Loss y N z + |x₀ - z| * N / Real.sqrt n := by
  have hNpos : (0:ℝ) < (N : ℝ) := by exact_mod_cast hN
  exact best_iterate_sqrt_rate (tropL1_isSubgradientOracle y N)
    (tropL1Sub_abs_le y N) hNpos hD hn

/-! ## Kernel-checked instances -/

example : tropL1Loss (fun i => (i : ℝ)) 3 1 = 2 := by
  norm_num [tropL1Loss, Finset.sum_range_succ]

example : tropL1Sub (fun i => (i : ℝ)) 3 1 = 1 := by
  norm_num [tropL1Sub, Finset.sum_range_succ]

-- With a fixed step the iterates oscillate around the median: `0 → 1 → 0`.
example : gdIter (tropL1Sub (fun i => (i : ℝ)) 3) 1 0 1 = 1 := by
  norm_num [gdIter, tropL1Sub, Finset.sum_range_succ]

example : gdIter (tropL1Sub (fun i => (i : ℝ)) 3) 1 0 2 = 0 := by
  norm_num [gdIter, tropL1Sub, Finset.sum_range_succ]

end EMLTropicalSGD