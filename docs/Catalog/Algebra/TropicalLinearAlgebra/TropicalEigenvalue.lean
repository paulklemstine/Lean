/-
# Tropical eigenvalues and the max-plus Perron–Frobenius theorem

An eigenpair of a max-plus matrix `A` (finite real entries) is a pair `(lam, v)`
with `A ⊗ v = lam ⊗ v`, i.e.

  `max_j (A i j + v j) = lam + v i`  for every `i`.

Main results of this file:

* `IsTropEigen.cycle_le` : every closed walk (cycle) of `A` has weight at most
  `length · lam` — an eigenvalue dominates all cycle means;
* `IsTropEigen.exists_critical_cycle` : some *simple* cycle attains the mean `lam`
  exactly (the critical cycle), obtained from the argmax function of the eigenvector
  by a minimal-period pigeonhole argument;
* `IsTropEigen.isGreatest_cycleMean` : **tropical Perron–Frobenius (spectral part)** —
  `lam` is the *maximum cycle mean* of `A`, and hence
* `tropEigenvalue_unique` : a max-plus matrix has at most one eigenvalue.
-/
import Mathlib
import Algebra.TropicalLinearAlgebra.TropicalDeterminant

namespace TropicalLA

variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-- `lam` is a **tropical eigenvalue** of `A` with eigenvector `v` (all entries finite)
if `A ⊗ v = lam ⊗ v`. -/
def IsTropEigen (A : Matrix ι ι ℝ) (lam : ℝ) (v : ι → ℝ) : Prop :=
  ∀ i, tmulVec A v i = lam + v i

namespace IsTropEigen

variable {A : Matrix ι ι ℝ} {lam : ℝ} {v : ι → ℝ}

/-- The eigenvector inequality `A i j + v j ≤ lam + v i`. -/
theorem le_of (h : IsTropEigen A lam v) (i j : ι) : A i j + v j ≤ lam + v i := by
  rw [← h i]; exact le_tmulVec A v i j

/-- For each row the maximum is attained: `∃ j, A i j + v j = lam + v i`. -/
theorem exists_tight (h : IsTropEigen A lam v) (i : ι) : ∃ j, A i j + v j = lam + v i := by
  obtain ⟨j, hj⟩ := exists_tmulVec_eq A v i
  exact ⟨j, by rw [← hj, h i]⟩

/-- **Every cycle mean is at most the eigenvalue.**  For a closed walk
`c 0 → c 1 → ⋯ → c m = c 0` the total weight is at most `m · lam`; the eigenvector
values telescope away. -/
theorem cycle_le (h : IsTropEigen A lam v) {m : ℕ} {c : ℕ → ι} (hc : c m = c 0) :
    pathWeight A c m ≤ m * lam := by
  have step : ∀ t ∈ Finset.range m,
      A (c t) (c (t + 1)) ≤ lam + ((fun t => v (c t)) t - (fun t => v (c t)) (t + 1)) := by
    intro t _
    have := h.le_of (c t) (c (t + 1))
    simp only
    linarith
  have hsum := Finset.sum_le_sum step
  rw [Finset.sum_add_distrib, Finset.sum_range_sub' (fun t => v (c t)) m] at hsum
  simp only [Finset.sum_const, Finset.card_range, nsmul_eq_mul] at hsum
  rw [pathWeight]
  simp only [hc] at hsum
  linarith

/-- The mean weight of any cycle is at most the eigenvalue. -/
theorem cycleMean_le (h : IsTropEigen A lam v) {m : ℕ} (hm : 1 ≤ m) {c : ℕ → ι}
    (hc : c m = c 0) : pathWeight A c m / m ≤ lam := by
  have hm' : (0 : ℝ) < m := by exact_mod_cast hm
  rw [div_le_iff₀ hm']
  have := h.cycle_le hc
  linarith [this]

section CriticalCycle

/-- A choice of tight successor for each index, together with a point of **minimal**
period for that choice function.  This is the combinatorial heart of tropical
Perron–Frobenius: following the argmax of the eigenvector must eventually cycle. -/
theorem exists_minimal_periodic_point (h : IsTropEigen A lam v) :
    ∃ (f : ι → ι) (y : ι) (p : ℕ), 0 < p ∧ f^[p] y = y ∧
      (∀ q, 0 < q → q < p → f^[q] y ≠ y) ∧ (∀ i, A i (f i) + v (f i) = lam + v i) := by
  classical
  choose f hf using h.exists_tight
  obtain ⟨i₀⟩ := ‹Nonempty ι›
  obtain ⟨a, b, hab, hfab⟩ := Finite.exists_ne_map_eq_of_infinite (fun n : ℕ => f^[n] i₀)
  -- normalise so that `a < b`
  rcases lt_or_gt_of_ne hab with hlt | hlt
  · exact aux f hf i₀ a b hlt hfab
  · exact aux f hf i₀ b a hlt hfab.symm
where
  aux (f : ι → ι) (hf : ∀ i, A i (f i) + v (f i) = lam + v i) (i₀ : ι) (a b : ℕ) (hlt : a < b)
      (hfab : f^[a] i₀ = f^[b] i₀) :
      ∃ (f : ι → ι) (y : ι) (p : ℕ), 0 < p ∧ f^[p] y = y ∧
        (∀ q, 0 < q → q < p → f^[q] y ≠ y) ∧ (∀ i, A i (f i) + v (f i) = lam + v i) := by
    classical
    set y₀ := f^[a] i₀ with hy₀
    have hper : f^[b - a] y₀ = y₀ := by
      rw [hy₀, ← Function.iterate_add_apply f (b - a) a i₀]
      have : b - a + a = b := by omega
      rw [this, ← hfab]
    have hex : ∃ q, 0 < q ∧ f^[q] y₀ = y₀ := ⟨b - a, by omega, hper⟩
    classical
    let p := Nat.find hex
    have hp := Nat.find_spec hex
    refine ⟨f, y₀, p, hp.1, hp.2, ?_, hf⟩
    intro q hq hqp hcontra
    have hmem : 0 < q ∧ f^[q] y₀ = y₀ := ⟨hq, hcontra⟩
    have hle : p ≤ q := Nat.find_le hmem
    omega

omit [Fintype ι] [Nonempty ι] in
/-- Points on the minimal-period orbit are pairwise distinct. -/
theorem iterate_injOn_of_minimal_period {f : ι → ι} {y : ι} {p : ℕ}
    (hp : f^[p] y = y) (hmin : ∀ q, 0 < q → q < p → f^[q] y ≠ y) :
    Set.InjOn (fun t => f^[t] y) (Finset.range p : Finset ℕ) := by
  intro s hs t ht hst
  simp only [Finset.coe_range, Set.mem_Iio] at hs ht
  by_contra hne
  rcases lt_or_gt_of_ne hne with hlt | hlt
  · have : f^[p - t + s] y = y := by
      rw [Function.iterate_add_apply]
      simp only at hst
      rw [hst, ← Function.iterate_add_apply]
      have : p - t + t = p := by omega
      rw [this, hp]
    exact hmin (p - t + s) (by omega) (by omega) this
  · have : f^[p - s + t] y = y := by
      rw [Function.iterate_add_apply]
      simp only at hst
      rw [← hst, ← Function.iterate_add_apply]
      have : p - s + s = p := by omega
      rw [this, hp]
    exact hmin (p - s + t) (by omega) (by omega) this

/-- **Existence of a critical cycle.**  If `lam` is an eigenvalue, some closed walk
has mean weight exactly `lam`; moreover it can be taken *simple*: its `p` vertices
`y, f y, …, f^{p-1} y` are pairwise distinct. -/
theorem exists_critical_cycle (h : IsTropEigen A lam v) :
    ∃ (f : ι → ι) (y : ι) (p : ℕ), 0 < p ∧ f^[p] y = y ∧
      Set.InjOn (fun t => f^[t] y) (Finset.range p : Finset ℕ) ∧
      (∀ i, A i (f i) + v (f i) = lam + v i) ∧
      pathWeight A (fun t => f^[t] y) p = p * lam := by
  obtain ⟨f, y, p, hp0, hp, hmin, hf⟩ := h.exists_minimal_periodic_point
  refine ⟨f, y, p, hp0, hp, iterate_injOn_of_minimal_period hp hmin, hf, ?_⟩
  have hterm : ∀ t : ℕ, A (f^[t] y) (f^[t + 1] y) =
      lam + ((fun t => v (f^[t] y)) t - (fun t => v (f^[t] y)) (t + 1)) := by
    intro t
    have h1 := hf (f^[t] y)
    have h2 : f^[t + 1] y = f (f^[t] y) := by
      rw [Function.iterate_succ_apply']
    rw [h2]
    simp only
    rw [h2]
    linarith
  rw [pathWeight]
  rw [Finset.sum_congr rfl (fun t _ => hterm t), Finset.sum_add_distrib,
    Finset.sum_range_sub' (fun t => v (f^[t] y)) p]
  simp only [Finset.sum_const, Finset.card_range, nsmul_eq_mul, Function.iterate_zero_apply, hp]
  ring

end CriticalCycle

/-- **Tropical Perron–Frobenius, spectral part.**  An eigenvalue of a max-plus matrix
is exactly the *maximum cycle mean*: it dominates every cycle mean and is attained by
some cycle. -/
theorem isGreatest_cycleMean (h : IsTropEigen A lam v) :
    IsGreatest {μ : ℝ | ∃ (m : ℕ) (c : ℕ → ι), 0 < m ∧ c m = c 0 ∧ μ = pathWeight A c m / m}
      lam := by
  constructor
  · obtain ⟨f, y, p, hp0, hp, _, _, hw⟩ := h.exists_critical_cycle
    refine ⟨p, fun t => f^[t] y, hp0, by simpa using hp, ?_⟩
    rw [hw]
    have : (p : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (by omega)
    field_simp
  · rintro μ ⟨m, c, hm, hc, rfl⟩
    exact h.cycleMean_le hm hc

end IsTropEigen

/-- **Uniqueness of the tropical eigenvalue.**  Any two eigenvalues of the same
max-plus matrix coincide — both equal the maximum cycle mean. -/
theorem tropEigenvalue_unique {A : Matrix ι ι ℝ} {lam₁ lam₂ : ℝ} {v₁ v₂ : ι → ℝ}
    (h₁ : IsTropEigen A lam₁ v₁) (h₂ : IsTropEigen A lam₂ v₂) : lam₁ = lam₂ := by
  have key : ∀ {a b : ℝ} {w₁ w₂ : ι → ℝ}, IsTropEigen A a w₁ → IsTropEigen A b w₂ → a ≤ b := by
    intro a b w₁ w₂ ha hb
    obtain ⟨f, y, p, hp0, hp, _, _, hw⟩ := ha.exists_critical_cycle
    have hle := hb.cycle_le (c := fun t => f^[t] y) (m := p) (by simpa using hp)
    rw [hw] at hle
    have hp' : (0 : ℝ) < p := by exact_mod_cast hp0
    nlinarith
  exact le_antisymm (key h₁ h₂) (key h₂ h₁)

end TropicalLA