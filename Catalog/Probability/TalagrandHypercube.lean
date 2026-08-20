import Probability.TalagrandConcentration

/-!
# A concrete instance: the uniform hypercube

This file records two things that guard the general theory against vacuity.

* `Talagrand.dTsq_singleton` — the convex distance to a single point really is
  the Euclidean length of the Hamming vector, so `dTsq` is not identically `0`;
  in particular `dTsq {y} x = n` when `x` and `y` differ in every coordinate.
* `Talagrand.hypercube_ones_concentration` — Talagrand's inequality applied to
  the uniform measure on the discrete cube `Fin n → Bool` and to the normalised
  number-of-ones functional `x ↦ (#{i : x i}) / √n`, which is `1`-Lipschitz for
  the Hamming metric weighted by `w i = 1 / √n` (a weight vector of Euclidean
  norm exactly one).  The conclusion is the classical statement
  `P(f ≤ m) * P(f ≥ m + t) ≤ exp (-t²/4)`.
* `Talagrand.biased_cube_concentration` — the same conclusion for independent
  coins with arbitrary, coordinate-dependent biases `θ i ∈ [0, 1]`, an instance of
  the non-identically-distributed form of the inequality.
-/

namespace Talagrand

open Finset Real

variable {α : Type*} [DecidableEq α] {n : ℕ}

/-- The convex distance to a singleton is the squared Hamming distance. -/
theorem dTsq_singleton (y x : Fin n → α) :
    dTsq {y} x = ∑ i, hamm (x i) (y i) ^ 2 := by
  classical
  have hupper : dTsq {y} x ≤ ∑ i, hamm (x i) (y i) ^ 2 := by
    have hrep : IsRepW ({y} : Finset (Fin n → α)) x (fun i => hamm (x i) (y i)) := by
      refine ⟨fun z => if z = y then 1 else 0, fun z => by dsimp only; split <;> norm_num, by simp, ?_⟩
      intro i; simp
    simpa [sqn] using dTsq_le_of_isRepW hrep
  refine le_antisymm hupper ?_
  refine le_csInf ⟨sqn (fun i => hamm (x i) (y i)), ⟨fun i => hamm (x i) (y i), ?_, rfl⟩⟩ ?_
  · exact (IsRepW.isRep ⟨fun z => if z = y then 1 else 0,
      fun z => by dsimp only; split <;> norm_num, by simp, fun i => by simp⟩)
  · rintro s ⟨v, hv, rfl⟩
    obtain ⟨w, hw0, hw1, hveq⟩ := hv.isRepW
    have hwy : w y = 1 := by simpa using hw1
    have hv' : ∀ i, v i = hamm (x i) (y i) := by
      intro i
      rw [hveq i]
      simp [hwy]
    have : sqn v = ∑ i, hamm (x i) (y i) ^ 2 := by
      simp only [sqn]
      exact Finset.sum_congr rfl fun i _ => by rw [hv' i]
    exact this.ge

/-- If `x` and `y` differ in every coordinate, the convex distance to `{y}` is `n`. -/
theorem dTsq_singleton_eq_card {y x : Fin n → α} (h : ∀ i, x i ≠ y i) :
    dTsq {y} x = n := by
  rw [dTsq_singleton]
  have : ∀ i : Fin n, hamm (x i) (y i) ^ 2 = 1 := by
    intro i; simp [hamm, h i]
  simp [this]

/-- A concrete non-degeneracy check: in the three-dimensional cube the convex
distance from the all-`true` point to `{all false}` equals `3`. -/
example : dTsq ({fun _ => false} : Finset (Fin 3 → Bool)) (fun _ => true) = 3 := by
  have h := dTsq_singleton_eq_card (y := fun _ : Fin 3 => false) (x := fun _ => true)
    (fun i => by simp)
  simpa using h

/-! ### The uniform measure on the discrete cube -/

/-- The uniform weight on the coordinates of the discrete cube. -/
noncomputable def unif (n : ℕ) : Fin n → Bool → ℝ := fun _ _ => 1 / 2

lemma unif_nonneg (n : ℕ) : ∀ (i : Fin n) (b : Bool), 0 ≤ unif n i b := by
  intro i b; norm_num [unif]

lemma unif_sum (n : ℕ) : ∀ i : Fin n, ∑ b : Bool, unif n i b = 1 := by
  intro i; simp [unif]

/-- Independent coins with *arbitrary*, coordinate-dependent biases `θ i`. -/
def biased {n : ℕ} (θ : Fin n → ℝ) : Fin n → Bool → ℝ :=
  fun i b => if b then θ i else 1 - θ i

lemma biased_nonneg {n : ℕ} {θ : Fin n → ℝ} (h0 : ∀ i, 0 ≤ θ i) (h1 : ∀ i, θ i ≤ 1) :
    ∀ (i : Fin n) (b : Bool), 0 ≤ biased θ i b := by
  intro i b
  cases b
  · show (0:ℝ) ≤ 1 - θ i
    linarith [h1 i]
  · exact h0 i

lemma biased_sum {n : ℕ} (θ : Fin n → ℝ) : ∀ i : Fin n, ∑ b : Bool, biased θ i b = 1 := by
  intro i; simp [biased]

/-- The normalised number-of-ones functional on the discrete cube. -/
noncomputable def ones (n : ℕ) (x : Fin n → Bool) : ℝ :=
  ∑ i, (1 / Real.sqrt n) * (if x i then 1 else 0)

/-- The uniform Hamming weight vector: `w i = 1 / √n`. -/
noncomputable def cubeWeight (n : ℕ) : Fin n → ℝ := fun _ => 1 / Real.sqrt n

lemma cubeWeight_nonneg (n : ℕ) : ∀ i, 0 ≤ cubeWeight n i := by
  intro i
  simp only [cubeWeight]
  positivity

lemma cubeWeight_sq (hn : 1 ≤ n) : ∑ i, (cubeWeight n i) ^ 2 = 1 := by
  have hn0 : (0:ℝ) < n := by exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hn
  have hsq : Real.sqrt n ^ 2 = (n : ℝ) := Real.sq_sqrt hn0.le
  have hne : Real.sqrt (n : ℝ) ≠ 0 := by positivity
  simp only [cubeWeight, div_pow, one_pow, Finset.sum_const, Finset.card_univ,
    Fintype.card_fin, nsmul_eq_mul, hsq]
  field_simp

/-- The number-of-ones functional is `1`-Lipschitz for the `cubeWeight`-weighted
Hamming metric. -/
lemma ones_lipschitz (n : ℕ) (x y : Fin n → Bool) :
    ones n x ≤ ones n y + ∑ i, cubeWeight n i * hamm (x i) (y i) := by
  have hstep : ∀ i : Fin n,
      (1 / Real.sqrt n) * (if x i then 1 else 0)
        ≤ (1 / Real.sqrt n) * (if y i then 1 else 0)
          + cubeWeight n i * hamm (x i) (y i) := by
    intro i
    have hw : (0:ℝ) ≤ 1 / Real.sqrt n := by positivity
    by_cases hxy : x i = y i
    · rw [hxy]
      have : (0:ℝ) ≤ cubeWeight n i * hamm (y i) (y i) := by simp [hamm]
      linarith
    · have hh : hamm (x i) (y i) = 1 := by simp [hamm, hxy]
      have hx : ((if x i then (1:ℝ) else 0)) ≤ (if y i then (1:ℝ) else 0) + 1 := by
        by_cases h : x i = true <;> by_cases h' : y i = true <;> simp [h, h']
      simp only [cubeWeight, hh, mul_one]
      nlinarith [hw]
  have := Finset.sum_le_sum (fun i (_ : i ∈ Finset.univ) => hstep i)
  simpa [ones, Finset.sum_add_distrib] using this

/-- **Talagrand concentration on the uniform discrete cube** for the normalised
number-of-ones functional. -/
theorem hypercube_ones_concentration (hn : 1 ≤ n)
    (A S : Finset (Fin n → Bool)) (hA : A.Nonempty) {m t : ℝ} (ht : 0 ≤ t)
    (hAle : ∀ y ∈ A, ones n y ≤ m) (hSge : ∀ x ∈ S, m + t ≤ ones n x) :
    mass (unif n) A * mass (unif n) S ≤ Real.exp (-(t ^ 2 / 4)) :=
  lipschitz_concentration (unif_nonneg n) (unif_sum n) (cubeWeight_nonneg n)
    (le_of_eq (cubeWeight_sq hn)) (ones_lipschitz n) A S hA ht hAle hSge

/-- **Talagrand concentration for independent coins with arbitrary biases.**  The
coordinates are independent but not identically distributed: coordinate `i` is a
coin with its own bias `θ i ∈ [0, 1]`.  The bound is uniform in the biases. -/
theorem biased_cube_concentration (hn : 1 ≤ n) {θ : Fin n → ℝ}
    (h0 : ∀ i, 0 ≤ θ i) (h1 : ∀ i, θ i ≤ 1)
    (A S : Finset (Fin n → Bool)) (hA : A.Nonempty) {m t : ℝ} (ht : 0 ≤ t)
    (hAle : ∀ y ∈ A, ones n y ≤ m) (hSge : ∀ x ∈ S, m + t ≤ ones n x) :
    mass (biased θ) A * mass (biased θ) S ≤ Real.exp (-(t ^ 2 / 4)) :=
  lipschitz_concentration (biased_nonneg h0 h1) (biased_sum θ) (cubeWeight_nonneg n)
    (le_of_eq (cubeWeight_sq hn)) (ones_lipschitz n) A S hA ht hAle hSge

end Talagrand