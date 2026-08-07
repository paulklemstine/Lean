/-
# A tropical Gelfand formula: growth rate of matrix powers

Classically the spectral radius of a matrix is the limit of `‖A^m‖^{1/m}`.  In the
max-plus world exponentiation becomes multiplication, and the statement becomes

  `‖A^{⊗ m}‖ / m → λ(A)`,

where `‖·‖` is the largest entry and `λ(A)` is the maximum cycle mean.  This file
proves the sharp two-sided form: the largest entry of `A^{⊗(m+1)}` differs from
`(m+1)·λ` by at most the *spread* `max v - min v` of a tropical eigenvector,
uniformly in `m`, hence the normalised growth rate converges to `λ`.

The bridge is that the eigenvector is preserved by the tropical action:
`A^{⊗(m+1)} ⊗ v = ((m+1)·λ) ⊗ v` (`IsTropEigen.tmulVec_tpow`).
-/
import Mathlib
import Algebra.TropicalLinearAlgebra.TropicalPerronFrobenius

namespace TropicalLA

open Filter Topology

variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-- The tropical action of a product is the composite action. -/
theorem tmulVec_tmul (A B : Matrix ι ι ℝ) (v : ι → ℝ) :
    tmulVec (tmul A B) v = tmulVec A (tmulVec B v) := by
  funext i
  apply le_antisymm
  · refine Finset.sup'_le _ _ fun j _ => ?_
    obtain ⟨k, hk⟩ := exists_tmul_eq A B i j
    have h1 : B k j + v j ≤ tmulVec B v k := le_tmulVec B v k j
    have h2 : A i k + tmulVec B v k ≤ tmulVec A (tmulVec B v) i := le_tmulVec A (tmulVec B v) i k
    rw [hk]
    linarith
  · refine Finset.sup'_le _ _ fun k _ => ?_
    obtain ⟨j, hj⟩ := exists_tmulVec_eq B v k
    have h1 : A i k + B k j ≤ tmul A B i j := le_tmul A B i j k
    have h2 : tmul A B i j + v j ≤ tmulVec (tmul A B) v i := le_tmulVec (tmul A B) v i j
    rw [hj]
    linarith

namespace IsTropEigen

variable {A : Matrix ι ι ℝ} {lam : ℝ} {v : ι → ℝ}

/-- Powers of the matrix scale the eigenvector: `A^{⊗(m+1)} ⊗ v = ((m+1)·lam) ⊗ v`. -/
theorem tmulVec_tpow (h : IsTropEigen A lam v) (m : ℕ) :
    tmulVec (tpow A m) v = fun i => (m + 1) * lam + v i := by
  induction m with
  | zero =>
      funext i
      simpa [tpow] using h i
  | succ m ih =>
      funext i
      have : tmulVec (tpow A (m + 1)) v = tmulVec (tpow A m) (tmulVec A v) := by
        rw [show tpow A (m + 1) = tmul (tpow A m) A from rfl, tmulVec_tmul]
      rw [this]
      have hAv : tmulVec A v = fun i => lam + v i := by
        funext i; exact h i
      rw [hAv]
      have hshift : tmulVec (tpow A m) (fun i => lam + v i) = fun i => lam + tmulVec (tpow A m) v i := by
        funext i
        apply le_antisymm
        · refine Finset.sup'_le _ _ fun j _ => ?_
          have := le_tmulVec (tpow A m) v i j
          simp only
          linarith
        · have hle : ∀ j, tpow A m i j + v j ≤
              Finset.univ.sup' Finset.univ_nonempty (fun j => tpow A m i j + (lam + v j)) - lam := by
            intro j
            have := Finset.le_sup' (fun j => tpow A m i j + (lam + v j)) (Finset.mem_univ j)
            simp only at this ⊢
            linarith
          have : tmulVec (tpow A m) v i ≤
              Finset.univ.sup' Finset.univ_nonempty (fun j => tpow A m i j + (lam + v j)) - lam :=
            Finset.sup'_le _ _ fun j _ => hle j
          simp only [tmulVec] at this ⊢
          linarith
      rw [hshift, ih]
      push_cast
      ring

end IsTropEigen

section Growth

variable (A : Matrix ι ι ℝ)

/-- The largest entry of `A^{⊗(m+1)}`: the tropical analogue of a matrix norm. -/
noncomputable def specNorm (m : ℕ) : ℝ :=
  Finset.univ.sup' (Finset.univ_nonempty (α := ι))
    (fun i => Finset.univ.sup' (Finset.univ_nonempty (α := ι)) (fun j => tpow A m i j))

variable {A}

theorem le_specNorm (m : ℕ) (i j : ι) : tpow A m i j ≤ specNorm A m := by
  rw [specNorm]
  exact le_trans (Finset.le_sup' (fun j => tpow A m i j) (Finset.mem_univ j))
    (Finset.le_sup' (fun i => Finset.univ.sup' (Finset.univ_nonempty (α := ι))
      (fun j => tpow A m i j)) (Finset.mem_univ i))

theorem exists_specNorm_eq (m : ℕ) : ∃ i j, specNorm A m = tpow A m i j := by
  obtain ⟨i, _, hi⟩ := Finset.exists_mem_eq_sup' (Finset.univ_nonempty (α := ι))
    (fun i => Finset.univ.sup' (Finset.univ_nonempty (α := ι)) (fun j => tpow A m i j))
  obtain ⟨j, _, hj⟩ := Finset.exists_mem_eq_sup' (Finset.univ_nonempty (α := ι))
    (fun j => tpow A m i j)
  exact ⟨i, j, by rw [specNorm, hi, hj]⟩

/-- **Uniform two-sided bound.**  With `v` an eigenvector of spread
`C = max v - min v`, every power satisfies `|‖A^{⊗(m+1)}‖ - (m+1)·lam| ≤ C`. -/
theorem abs_specNorm_sub_le {lam : ℝ} {v : ι → ℝ} (h : IsTropEigen A lam v) (m : ℕ) :
    |specNorm A m - (m + 1) * lam| ≤
      Finset.univ.sup' (Finset.univ_nonempty (α := ι)) v
        - Finset.univ.inf' (Finset.univ_nonempty (α := ι)) v := by
  set vmax := Finset.univ.sup' (Finset.univ_nonempty (α := ι)) v with hvmax
  set vmin := Finset.univ.inf' (Finset.univ_nonempty (α := ι)) v with hvmin
  have hvle : ∀ i, v i ≤ vmax := fun i => Finset.le_sup' v (Finset.mem_univ i)
  have hvge : ∀ i, vmin ≤ v i := fun i => Finset.inf'_le v (Finset.mem_univ i)
  have hpow := h.tmulVec_tpow m
  have hentry : ∀ i j, tpow A m i j + v j ≤ (m + 1) * lam + v i := by
    intro i j
    have h1 : tpow A m i j + v j ≤ tmulVec (tpow A m) v i := le_tmulVec (tpow A m) v i j
    rw [hpow] at h1
    exact h1
  have hupper : specNorm A m ≤ (m + 1) * lam + (vmax - vmin) := by
    obtain ⟨i, j, hij⟩ := exists_specNorm_eq (A := A) m
    have := hentry i j
    have h1 := hvle i
    have h2 := hvge j
    rw [hij]
    linarith
  have hlower : (m + 1) * lam - (vmax - vmin) ≤ specNorm A m := by
    obtain ⟨i⟩ := ‹Nonempty ι›
    obtain ⟨j, hj⟩ := exists_tmulVec_eq (tpow A m) v i
    have hval : tpow A m i j + v j = (m + 1) * lam + v i := by
      rw [← hj, hpow]
    have h1 := le_specNorm (A := A) m i j
    have h2 := hvle j
    have h3 := hvge i
    linarith
  rw [abs_le]
  constructor <;> linarith

/-- **Tropical Gelfand formula.**  The normalised largest entry of the tropical powers
of `A` converges to the maximum cycle mean of `A`. -/
theorem tendsto_specNorm_div (A : Matrix ι ι ℝ) :
    Tendsto (fun m : ℕ => specNorm A m / (m + 1)) atTop (𝓝 (maxCycleMean A)) := by
  obtain ⟨v, hv⟩ := exists_tropEigen A
  set lam := maxCycleMean A with hlam
  set C := Finset.univ.sup' (Finset.univ_nonempty (α := ι)) v
      - Finset.univ.inf' (Finset.univ_nonempty (α := ι)) v with hC
  have hbound : ∀ m : ℕ, |specNorm A m - (m + 1) * lam| ≤ C := fun m =>
    abs_specNorm_sub_le hv m
  have hCzero : Tendsto (fun m : ℕ => C / ((m : ℝ) + 1)) atTop (𝓝 0) := by
    have : Tendsto (fun m : ℕ => C * (1 / ((m : ℝ) + 1))) atTop (𝓝 (C * 0)) :=
      Tendsto.const_mul C tendsto_one_div_add_atTop_nhds_zero_nat
    simpa [mul_comm, mul_one_div] using this
  have hlow : Tendsto (fun m : ℕ => lam - C / ((m : ℝ) + 1)) atTop (𝓝 lam) := by
    simpa using (tendsto_const_nhds (x := lam) (f := atTop (α := ℕ))).sub hCzero
  have hhigh : Tendsto (fun m : ℕ => lam + C / ((m : ℝ) + 1)) atTop (𝓝 lam) := by
    simpa using (tendsto_const_nhds (x := lam) (f := atTop (α := ℕ))).add hCzero
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le hlow hhigh ?_ ?_
  · intro m
    have hm : (0 : ℝ) < (m : ℝ) + 1 := by positivity
    have hb := (abs_le.mp (hbound m)).1
    rw [le_div_iff₀ hm]
    have heq : (lam - C / ((m : ℝ) + 1)) * ((m : ℝ) + 1) = ((m : ℝ) + 1) * lam - C := by
      field_simp
    rw [heq]
    linarith
  · intro m
    have hm : (0 : ℝ) < (m : ℝ) + 1 := by positivity
    have hb := (abs_le.mp (hbound m)).2
    rw [div_le_iff₀ hm]
    have heq : (lam + C / ((m : ℝ) + 1)) * ((m : ℝ) + 1) = ((m : ℝ) + 1) * lam + C := by
      field_simp
    rw [heq]
    linarith

end Growth

end TropicalLA