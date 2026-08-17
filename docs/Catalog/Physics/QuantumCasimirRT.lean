/-
# Second cycle: the Casimir spectrum and Reshetikhin–Turaev naturality

This file deepens the two halves of the bridge developed in
`Catalog/Physics/QuantumSL2ClassicalLimit.lean` and `Catalog/Physics/QuantumSL2Braiding.lean`.

## 1. The spectrum of the quantum Casimir

`QuantumCasimir.casimir_apply` shows that on the `(n+1)`-dimensional module the quantum Casimir
`F E + (qK + q⁻¹K⁻¹)/(q - q⁻¹)²` acts by the **scalar**

`CasimirScalar q n = (q^{n+1} + q^{-(n+1)})/(q - q⁻¹)²`

*independently of the weight* — a quantitative form of Schur's lemma for `U_q(sl₂)`.

`QuantumCasimir.casimir_tendsto` then proves that the (necessarily) shifted Casimir
`CasimirScalar q n - (q + q⁻¹)/(q - q⁻¹)²` — a ratio of two expressions that both blow up as
`q → 1` — converges to the classical `sl₂` Casimir eigenvalue `n(n+2)/4` of the spin-`n/2`
representation.  The mechanism is the factorisation

`CasimirScalar q n - (q+q⁻¹)/(q-q⁻¹)² = q^{1-n} (∑_{i<n} qⁱ)(∑_{i<n+2} qⁱ)/(q+1)²`

(`casimir_shift_eq`), which is manifestly regular at `q = 1`.

## 2. Reshetikhin–Turaev naturality of the braiding

`QuantumCasimir.eMat` is the Temperley–Lieb generator on `V ⊗ V` (`V = k²`), the projector onto
the `q`-deformed singlet.  We prove `eMat_sq` (`e² = δ e`) and, for `q = A⁻²`, that `e` commutes
with the whole coproduct action (`eMat_comm_deltaE`, `eMat_comm_deltaF`, `eMat_comm_deltaK`).
Consequently the Kauffman braiding `Ř = A·1 + A⁻¹·e` is a **morphism of `U_q(sl₂)`-modules**
(`braiding_intertwines`).  This naturality is precisely what makes the Reshetikhin–Turaev
functor — and hence the Jones polynomial computed in `Catalog/Physics/JonesPolynomialTL.lean` —
well defined.
-/

import Mathlib
import Physics.QuantumSL2Braiding

open Filter Topology

namespace QuantumCasimir

open QuantumSL2 QuantumBraiding

/-! ## 1. The Casimir acts by a scalar -/

section Spectrum

variable {k : Type*} [Field k]

/-- The scalar by which the quantum Casimir acts on the `(n+1)`-dimensional module. -/
noncomputable def CasimirScalar (q : k) (n : ℕ) : k :=
  (q ^ ((n : ℤ) + 1) + q ^ (-((n : ℤ) + 1))) / (q - q⁻¹) ^ 2

/-- A form of the shifted Casimir eigenvalue which is regular at `q = 1`. -/
noncomputable def casimirReg (q : k) (n : ℕ) : k :=
  q ^ (1 - (n : ℤ)) * (∑ i ∈ Finset.range n, q ^ i) * (∑ i ∈ Finset.range (n + 2), q ^ i)
    / (q + 1) ^ 2

/-- **The quantum Casimir acts on the `(n+1)`-dimensional module by a scalar** (Schur). -/
theorem casimir_apply (q : k) (hq : q ≠ 0) (n : ℕ) (c : ℕ → k) (j : ℕ) :
    Fop q n (Eop q c) j
        + ((q - q⁻¹) ^ 2)⁻¹ * (q * Kop q n c j + q⁻¹ * Kiop q n c j)
      = CasimirScalar q n * c j := by
  have key : (q ^ ((n : ℤ) - j + 1) - q ^ (-((n : ℤ) - j + 1))) * (q ^ (j : ℤ) - q ^ (-(j : ℤ)))
      + (q * q ^ ((n : ℤ) - 2 * j) + q⁻¹ * q ^ (-((n : ℤ) - 2 * j)))
      = q ^ ((n : ℤ) + 1) + q ^ (-((n : ℤ) + 1)) := by
    have hjn : q ^ (j : ℤ) ≠ 0 := zpow_ne_zero _ hq
    have hnn : q ^ (n : ℤ) ≠ 0 := zpow_ne_zero _ hq
    rw [show ((n : ℤ) - 2 * j) = (n : ℤ) - j - j by ring]
    simp only [zpow_sub₀ hq, zpow_add₀ hq, zpow_neg, zpow_one, mul_inv, div_eq_mul_inv, inv_inv]
    field_simp
    ring
  have hscalar : qInt q ((n : ℤ) - j + 1) * qInt q j
      + ((q - q⁻¹) ^ 2)⁻¹ * (q * q ^ ((n : ℤ) - 2 * j) + q⁻¹ * q ^ (-((n : ℤ) - 2 * j)))
      = CasimirScalar q n := by
    rw [qInt, qInt, div_mul_div_comm, ← sq, inv_mul_eq_div, ← add_div, CasimirScalar, key]
  rw [FE_apply, Kop, Kiop]
  calc qInt q ((n : ℤ) - j + 1) * qInt q j * c j
        + ((q - q⁻¹) ^ 2)⁻¹ * (q * (q ^ ((n : ℤ) - 2 * j) * c j)
          + q⁻¹ * (q ^ (-((n : ℤ) - 2 * j)) * c j))
      = (qInt q ((n : ℤ) - j + 1) * qInt q j
        + ((q - q⁻¹) ^ 2)⁻¹ * (q * q ^ ((n : ℤ) - 2 * j)
          + q⁻¹ * q ^ (-((n : ℤ) - 2 * j)))) * c j := by ring
    _ = CasimirScalar q n * c j := by rw [hscalar]

/-- The shifted Casimir eigenvalue in a form manifestly regular at `q = 1`. -/
theorem casimir_shift_eq (q : k) (hq : q ≠ 0) (h1 : q - 1 ≠ 0) (h2 : q + 1 ≠ 0) (n : ℕ) :
    CasimirScalar q n - (q + q⁻¹) / (q - q⁻¹) ^ 2 = casimirReg q n := by
  have h4 : q ^ 2 - 1 ≠ 0 := by
    intro h
    have hf : (q - 1) * (q + 1) = 0 := by linear_combination h
    rcases mul_eq_zero.mp hf with h' | h'
    · exact h1 h'
    · exact h2 h'
  have hd : q - q⁻¹ = (q ^ 2 - 1) / q := by field_simp
  have hgn : (∑ i ∈ Finset.range n, q ^ i) = (q ^ n - 1) / (q - 1) := by
    rw [eq_div_iff h1]; exact geom_sum_mul q n
  have hgn2 : (∑ i ∈ Finset.range (n + 2), q ^ i) = (q ^ (n + 2) - 1) / (q - 1) := by
    rw [eq_div_iff h1]; exact geom_sum_mul q (n + 2)
  have e1 : q ^ ((n : ℤ) + 1) = q * q ^ n := by rw [zpow_add₀ hq, zpow_one, zpow_natCast]; ring
  have e2 : q ^ (-((n : ℤ) + 1)) = (q * q ^ n)⁻¹ := by rw [zpow_neg, e1]
  have e3 : q ^ (1 - (n : ℤ)) = q / q ^ n := by
    rw [zpow_sub₀ hq, zpow_one, zpow_natCast, div_eq_mul_inv]
  have hxn : q ^ n ≠ 0 := pow_ne_zero _ hq
  rw [CasimirScalar, casimirReg, hgn, hgn2, e1, e2, e3, pow_add, hd, div_pow]
  field_simp
  ring

end Spectrum

/-- **The quantum Casimir eigenvalue degenerates to the classical one.**  As `q → 1` the shifted
Casimir eigenvalue of the `(n+1)`-dimensional module converges to `n(n+2)/4`, the value of the
classical `sl₂` Casimir on the spin-`n/2` representation. -/
theorem casimir_tendsto (n : ℕ) :
    Tendsto (fun q : ℝ => CasimirScalar q n - (q + q⁻¹) / (q - q⁻¹) ^ 2) (𝓝[≠] 1)
      (𝓝 ((n : ℝ) * (n + 2) / 4)) := by
  have hcont : ContinuousAt (fun q : ℝ => casimirReg q n) 1 := by
    apply ContinuousAt.div
    · exact ContinuousAt.mul (ContinuousAt.mul
        (continuousAt_zpow₀ _ _ (Or.inl one_ne_zero)) (by fun_prop)) (by fun_prop)
    · fun_prop
    · norm_num
  have hval : casimirReg (1 : ℝ) n = (n : ℝ) * (n + 2) / 4 := by
    simp [casimirReg]
    ring
  have h := hcont.continuousWithinAt (s := {(1 : ℝ)}ᶜ)
  rw [ContinuousWithinAt, hval] at h
  refine h.congr' ?_
  have hIoo : ∀ᶠ q in 𝓝[≠] (1 : ℝ), q ∈ Set.Ioo (0 : ℝ) 2 :=
    eventually_nhdsWithin_of_eventually_nhds (Ioo_mem_nhds (by norm_num) (by norm_num))
  filter_upwards [hIoo, self_mem_nhdsWithin] with q hq hne
  exact (casimir_shift_eq q (ne_of_gt hq.1) (sub_ne_zero.mpr hne) (by nlinarith [hq.1]) n).symm

/-! ## 2. Naturality: the braiding is a map of `U_q(sl₂)`-modules -/

section Naturality

open Matrix

variable {k : Type*} [Field k]

/-- The Temperley–Lieb generator on `V ⊗ V`: the projector onto the `q`-deformed singlet. -/
noncomputable def eMat (A : k) : Matrix (Fin 2 × Fin 2) (Fin 2 × Fin 2) k :=
  Matrix.of fun p r => cup A p.1 p.2 * (-cup A r.1 r.2)

set_option maxHeartbeats 1000000 in
theorem eMat_sq (A : k) (hA : A ≠ 0) : eMat A * eMat A = loopValue A • eMat A := by
  ext p r
  fin_cases p <;> fin_cases r <;>
    simp [Matrix.mul_apply, Fintype.sum_prod_type, Fin.sum_univ_two, eMat, cup, loopValue] <;>
    field_simp <;> ring

set_option maxHeartbeats 1000000 in
theorem eMat_comm_deltaE (A : k) (hA : A ≠ 0) :
    eMat A * deltaE (A ^ 2)⁻¹ = deltaE (A ^ 2)⁻¹ * eMat A := by
  ext p r
  fin_cases p <;> fin_cases r <;>
    simp [Matrix.mul_apply, Fintype.sum_prod_type, Fin.sum_univ_two, eMat, deltaE, Emat, Kmat,
      cup, Matrix.kroneckerMap] <;>
    field_simp <;> ring

set_option maxHeartbeats 1000000 in
theorem eMat_comm_deltaF (A : k) (hA : A ≠ 0) :
    eMat A * deltaF (A ^ 2)⁻¹ = deltaF (A ^ 2)⁻¹ * eMat A := by
  ext p r
  fin_cases p <;> fin_cases r <;>
    simp [Matrix.mul_apply, Fintype.sum_prod_type, Fin.sum_univ_two, eMat, deltaF, Fmat, Kimat,
      cup, Matrix.kroneckerMap] <;>
    field_simp <;> ring

set_option maxHeartbeats 1000000 in
theorem eMat_comm_deltaK (A : k) (hA : A ≠ 0) :
    eMat A * deltaK (A ^ 2)⁻¹ = deltaK (A ^ 2)⁻¹ * eMat A := by
  ext p r
  fin_cases p <;> fin_cases r <;>
    simp [Matrix.mul_apply, Fintype.sum_prod_type, Fin.sum_univ_two, eMat, deltaK, Kmat,
      cup, Matrix.kroneckerMap] <;>
    field_simp

/-- **Naturality of the Reshetikhin–Turaev braiding.**  For `q = A⁻²` the Kauffman braiding
`Ř = A·1 + A⁻¹·e` commutes with the action of `U_q(sl₂)` on `V ⊗ V`, i.e. it is a morphism of
`U_q(sl₂)`-modules.  This is what makes the Reshetikhin–Turaev functor well defined. -/
theorem braiding_intertwines (A : k) (hA : A ≠ 0) :
    kauffman A (eMat A) * deltaE (A ^ 2)⁻¹ = deltaE (A ^ 2)⁻¹ * kauffman A (eMat A) ∧
      kauffman A (eMat A) * deltaF (A ^ 2)⁻¹ = deltaF (A ^ 2)⁻¹ * kauffman A (eMat A) ∧
        kauffman A (eMat A) * deltaK (A ^ 2)⁻¹ = deltaK (A ^ 2)⁻¹ * kauffman A (eMat A) := by
  refine ⟨?_, ?_, ?_⟩ <;>
    simp only [kauffman, add_mul, mul_add, smul_mul_assoc, mul_smul_comm, one_mul, mul_one,
      eMat_comm_deltaE A hA, eMat_comm_deltaF A hA, eMat_comm_deltaK A hA]

end Naturality

end QuantumCasimir