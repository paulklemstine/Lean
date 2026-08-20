import Probability.TalagrandProduct

/-!
# Consequences: concentration of 1-Lipschitz functionals

From the exponential moment bound `Talagrand.Eexp_mul_mass_le_one` we deduce, by
Markov's inequality, the concentration statements Talagrand's inequality is used
for in practice.

## Main results

* `Talagrand.mass_mul_mass_le_exp` — if every point of `S` is at squared convex
  distance at least `t` from `A`, then `mass A * mass S ≤ exp (-(t/4))`.
* `Talagrand.mass_mul_mass_le_exp_hamming` — the same with the weighted Hamming
  distance: if `∑ w i ^ 2 ≤ 1` and every point of `S` is at weighted Hamming
  distance at least `t` from `A`, then `mass A * mass S ≤ exp (-(t ^ 2 / 4))`.
* `Talagrand.lipschitz_concentration` — the concentration inequality for a
  functional `f` that is 1-Lipschitz for the `w`-weighted Hamming metric:
  `mass {f ≤ m} * mass {f ≥ m + t} ≤ exp (-(t ^ 2 / 4))`.
* `Talagrand.lipschitz_concentration_half` — the usual reading of the previous
  bound when `{f ≤ m}` has mass at least `1/2`.
-/

namespace Talagrand

open Finset Real

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- **Markov's inequality for the convex distance.**  If every point of `S` is at
squared convex distance at least `t` from `A`, the two sets cannot both be large. -/
theorem mass_mul_mass_le_exp {n : ℕ} {p : Fin n → α → ℝ} (hp0 : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, ∑ a, p i a = 1) (A S : Finset (Fin n → α)) {t : ℝ} (hS : ∀ x ∈ S, t ≤ dTsq A x) :
    mass p A * mass p S ≤ Real.exp (-(t / 4)) := by
  have hmassS : mass p S ≤ Real.exp (-(t / 4)) * Eexp p A := by
    have hterm : ∀ x ∈ S, wt p x ≤ Real.exp (-(t / 4)) * (wt p x * Real.exp (dTsq A x / 4)) := by
      intro x hx
      have h1 : t / 4 ≤ dTsq A x / 4 := by linarith [hS x hx]
      have h2 : (1:ℝ) ≤ Real.exp (-(t / 4)) * Real.exp (dTsq A x / 4) := by
        rw [← Real.exp_add]
        have : (0:ℝ) ≤ -(t / 4) + dTsq A x / 4 := by linarith
        simpa using Real.one_le_exp this
      have hw := wt_nonneg hp0 (p := p) x
      nlinarith
    calc mass p S = ∑ x ∈ S, wt p x := rfl
      _ ≤ ∑ x ∈ S, Real.exp (-(t / 4)) * (wt p x * Real.exp (dTsq A x / 4)) :=
          Finset.sum_le_sum hterm
      _ ≤ ∑ x : Fin n → α, Real.exp (-(t / 4)) * (wt p x * Real.exp (dTsq A x / 4)) := by
          refine Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ S) fun x _ _ => ?_
          exact mul_nonneg (Real.exp_pos _).le
            (mul_nonneg (wt_nonneg hp0 x) (Real.exp_pos _).le)
      _ = Real.exp (-(t / 4)) * Eexp p A := by rw [Eexp, Finset.mul_sum]
  have hA0 : 0 ≤ mass p A := mass_nonneg hp0 A
  have hmain := Eexp_mul_mass_le_one p hp0 hp1 A
  calc mass p A * mass p S ≤ mass p A * (Real.exp (-(t / 4)) * Eexp p A) := by
        exact mul_le_mul_of_nonneg_left hmassS hA0
    _ = Real.exp (-(t / 4)) * (Eexp p A * mass p A) := by ring
    _ ≤ Real.exp (-(t / 4)) * 1 := by
        exact mul_le_mul_of_nonneg_left hmain (Real.exp_pos _).le
    _ = Real.exp (-(t / 4)) := by ring

omit [Fintype α] in
/-- A lower bound for the weighted Hamming distance from a uniform lower bound on
the distances to the individual points of `A`. -/
lemma le_dHamming {n : ℕ} {w : Fin n → ℝ} {A : Finset (Fin n → α)} {x : Fin n → α}
    (hA : A.Nonempty) {t : ℝ} (h : ∀ y ∈ A, t ≤ ∑ i, w i * hamm (x i) (y i)) :
    t ≤ dHamming w A x := by
  obtain ⟨y0, hy0⟩ := hA
  refine le_csInf ⟨∑ i, w i * hamm (x i) (y0 i), y0, hy0, rfl⟩ ?_
  rintro s ⟨y, hy, rfl⟩
  exact h y hy

/-- **Talagrand's concentration inequality for the weighted Hamming metric.** -/
theorem mass_mul_mass_le_exp_hamming {n : ℕ} {p : Fin n → α → ℝ} (hp0 : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, ∑ a, p i a = 1) {w : Fin n → ℝ} (hw : ∀ i, 0 ≤ w i) (hw2 : ∑ i, (w i) ^ 2 ≤ 1)
    (A S : Finset (Fin n → α)) (hA : A.Nonempty) {t : ℝ} (ht : 0 ≤ t)
    (hS : ∀ x ∈ S, t ≤ dHamming w A x) :
    mass p A * mass p S ≤ Real.exp (-(t ^ 2 / 4)) := by
  refine mass_mul_mass_le_exp hp0 hp1 A S (fun x hx => ?_)
  have h1 : t ≤ dHamming w A x := hS x hx
  have h2 : (dHamming w A x) ^ 2 ≤ dTsq A x := dHamming_sq_le_dTsq hw hw2 hA x
  nlinarith

/-- **Concentration of 1-Lipschitz functionals.**  If `f` is 1-Lipschitz for the
`w`-weighted Hamming metric (with `∑ w i ^ 2 ≤ 1`), then the level set `{f ≤ m}`
and the far level set `{f ≥ m + t}` cannot both be large. -/
theorem lipschitz_concentration {n : ℕ} {p : Fin n → α → ℝ} (hp0 : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, ∑ a, p i a = 1) {w : Fin n → ℝ} (hw : ∀ i, 0 ≤ w i) (hw2 : ∑ i, (w i) ^ 2 ≤ 1)
    {f : (Fin n → α) → ℝ}
    (hLip : ∀ x y, f x ≤ f y + ∑ i, w i * hamm (x i) (y i))
    (A S : Finset (Fin n → α)) (hA : A.Nonempty) {m t : ℝ} (ht : 0 ≤ t)
    (hAle : ∀ y ∈ A, f y ≤ m) (hSge : ∀ x ∈ S, m + t ≤ f x) :
    mass p A * mass p S ≤ Real.exp (-(t ^ 2 / 4)) := by
  refine mass_mul_mass_le_exp_hamming hp0 hp1 hw hw2 A S hA ht (fun x hx => ?_)
  refine le_dHamming hA (fun y hy => ?_)
  have h1 := hLip x y
  have h2 := hAle y hy
  have h3 := hSge x hx
  linarith

/-- The classical reading of `lipschitz_concentration`: if the sublevel set
`{f ≤ m}` carries at least half of the mass (`m` is a *median-like* value), then
the upper tail decays like `2 * exp (-t ^ 2 / 4)`. -/
theorem lipschitz_concentration_half {n : ℕ} {p : Fin n → α → ℝ} (hp0 : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, ∑ a, p i a = 1) {w : Fin n → ℝ} (hw : ∀ i, 0 ≤ w i) (hw2 : ∑ i, (w i) ^ 2 ≤ 1)
    {f : (Fin n → α) → ℝ}
    (hLip : ∀ x y, f x ≤ f y + ∑ i, w i * hamm (x i) (y i))
    (A S : Finset (Fin n → α)) (hA : A.Nonempty) {m t : ℝ} (ht : 0 ≤ t)
    (hAmass : 1 / 2 ≤ mass p A)
    (hAle : ∀ y ∈ A, f y ≤ m) (hSge : ∀ x ∈ S, m + t ≤ f x) :
    mass p S ≤ 2 * Real.exp (-(t ^ 2 / 4)) := by
  have hmain := lipschitz_concentration hp0 hp1 hw hw2 hLip A S hA ht hAle hSge
  have hS0 : 0 ≤ mass p S := mass_nonneg hp0 S
  nlinarith

end Talagrand