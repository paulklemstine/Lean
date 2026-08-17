/-
# Gaussian binomial coefficients and the `q`-binomial theorem

This file supplies the *combinatorial* half of the statement "`U_q(g)` is a `q`-deformation of
`U(g)`", complementing the analytic half proved in `Physics.QuantumSL2ClassicalLimit`.

## Contents

* **Gaussian binomials.**  `QuantumBinomial.qBinom q n j` is defined by the `q`-Pascal recursion
  `[n+1 ; j+1] = q^{n-j} [n ; j] + [n ; j+1]`.  We prove the vanishing/normalisation lemmas,
  the closed form `qBinom q n 1 = ∑_{i<n} qⁱ`, and the *second* `q`-Pascal recursion
  `[n+1 ; j+1] = [n ; j] + q^{j+1} [n ; j+1]` (`qBinom_pascal'`), which is a genuine theorem for
  this definition, plus the reflection symmetry `[n ; j] = [n ; n-j]` (`qBinom_symm`).

* **The `q`-binomial theorem.**  `add_pow_of_qCommute`: if `y x = q (x y)` in a `k`-algebra then
  `(x+y)ⁿ = ∑_j [n ; j]_q x^j y^{n-j}`.  This is the deformation of the classical binomial
  theorem, which is recovered at `q = 1` (`qBinom_one_eq_choose`, `add_pow_of_commute_of_qBinom`).

* **Degeneration.**  `qBinom_continuous` and `qBinom_tendsto_choose` show that each Gaussian
  binomial is a polynomial in `q` converging to the ordinary binomial coefficient as `q → 1`,
  so the whole deformed expansion degenerates to the classical one.

* **Bridge to `U_q(sl₂)`.**  `qInt_eq_qBinom` identifies the balanced quantum integer `[m]_q` of
  `Physics.QuantumSL2ClassicalLimit` with `q^{1-m}·[m ; 1]_{q²}`, and `IsUqSl2.add_pow_E_K`
  applies the `q`-binomial theorem to the generators `E, K` of `U_q(sl₂)`, whose relation
  `K E = q² E K` is exactly a `q²`-commutation.
-/

import Mathlib
import Physics.QuantumSL2ClassicalLimit

open Filter Topology

namespace QuantumBinomial

/-! ## 1. Gaussian binomial coefficients -/

section Defs

variable {k : Type*} [CommRing k]

/-- The **Gaussian (`q`-)binomial coefficient** `[n ; j]_q`, defined by the `q`-Pascal
recursion `[n+1 ; j+1] = q^{n-j} [n ; j] + [n ; j+1]`. -/
def qBinom (q : k) : ℕ → ℕ → k
  | _, 0 => 1
  | 0, _ + 1 => 0
  | n + 1, j + 1 => q ^ (n - j) * qBinom q n j + qBinom q n (j + 1)

@[simp] theorem qBinom_zero_right (q : k) (n : ℕ) : qBinom q n 0 = 1 := by
  cases n <;> rfl

@[simp] theorem qBinom_zero_succ (q : k) (j : ℕ) : qBinom q 0 (j + 1) = 0 := rfl

theorem qBinom_succ_succ (q : k) (n j : ℕ) :
    qBinom q (n + 1) (j + 1) = q ^ (n - j) * qBinom q n j + qBinom q n (j + 1) := rfl

/-- Gaussian binomials vanish above the diagonal. -/
theorem qBinom_eq_zero_of_lt (q : k) : ∀ {n j : ℕ}, n < j → qBinom q n j = 0 := by
  intro n
  induction n with
  | zero =>
      intro j hj
      obtain ⟨j, rfl⟩ := Nat.exists_eq_succ_of_ne_zero (by omega : j ≠ 0)
      simp
  | succ n ih =>
      intro j hj
      obtain ⟨j, rfl⟩ := Nat.exists_eq_succ_of_ne_zero (by omega : j ≠ 0)
      rw [qBinom_succ_succ, ih (by omega), ih (by omega)]
      ring

@[simp] theorem qBinom_self (q : k) (n : ℕ) : qBinom q n n = 1 := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [qBinom_succ_succ, ih, qBinom_eq_zero_of_lt q (by omega : n < n + 1)]
      simp

/-- `[n ; 1]_q = 1 + q + ⋯ + q^{n-1}`, the *unbalanced* quantum integer. -/
theorem qBinom_one (q : k) (n : ℕ) : qBinom q n 1 = ∑ i ∈ Finset.range n, q ^ i := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [show (1 : ℕ) = 0 + 1 from rfl, qBinom_succ_succ, ih, Finset.sum_range_succ]
      simp [add_comm]

/-- **The second `q`-Pascal recursion.**  With the definition above (which builds in
`[n+1 ; j+1] = q^{n-j}[n ; j] + [n ; j+1]`), the dual recursion is a theorem. -/
theorem qBinom_pascal' (q : k) : ∀ (n j : ℕ),
    qBinom q (n + 1) (j + 1) = qBinom q n j + q ^ (j + 1) * qBinom q n (j + 1) := by
  intro n
  induction n with
  | zero =>
      intro j
      match j with
      | 0 => simp
      | (j + 1) =>
          rw [qBinom_succ_succ]
          simp
  | succ n ih =>
      intro j
      match j with
      | 0 =>
          have h1 : ∑ i ∈ Finset.range (n + 2), q ^ i
              = q * (∑ i ∈ Finset.range (n + 1), q ^ i) + 1 := by
            rw [Finset.sum_range_succ' (fun i => q ^ i) (n + 1), Finset.mul_sum]
            simp [pow_succ, mul_comm]
          have h2 : ∑ i ∈ Finset.range (n + 2), q ^ i
              = (∑ i ∈ Finset.range (n + 1), q ^ i) + q ^ (n + 1) :=
            Finset.sum_range_succ _ _
          rw [qBinom_succ_succ]
          simp only [qBinom_one, qBinom_zero_right, Nat.sub_zero, mul_one, pow_one, zero_add]
          linear_combination h1 - h2
      | (j + 1) =>
          rcases lt_or_ge j n with hlt | hge
          · have D1 : qBinom q (n + 1) (j + 1)
                = q ^ (n - j) * qBinom q n j + qBinom q n (j + 1) := rfl
            have D2 : qBinom q (n + 1) (j + 2)
                = q ^ (n - (j + 1)) * qBinom q n (j + 1) + qBinom q n (j + 2) := rfl
            have R1 : q ^ (n - j) * qBinom q n j + qBinom q n (j + 1)
                = qBinom q n j + q ^ (j + 1) * qBinom q n (j + 1) := by rw [← D1, ih j]
            have R2 : q ^ (n - (j + 1)) * qBinom q n (j + 1) + qBinom q n (j + 2)
                = qBinom q n (j + 1) + q ^ (j + 2) * qBinom q n (j + 2) := by rw [← D2, ih (j + 1)]
            have e1 : n + 1 - (j + 1) = n - (j + 1) + 1 := by omega
            have e2 : n - j = n - (j + 1) + 1 := by omega
            rw [e2] at R1
            rw [qBinom_succ_succ q (n + 1) (j + 1), D1, D2, e1, e2]
            linear_combination (q ^ (n - (j + 1)) * q) * R1 + R2
          · have hz1 : qBinom q n (j + 1) = 0 := qBinom_eq_zero_of_lt q (by omega)
            have hz2 : qBinom q n (j + 2) = 0 := qBinom_eq_zero_of_lt q (by omega)
            have hz3 : qBinom q (n + 1) (j + 2) = 0 := by
              rw [qBinom_succ_succ, hz1, hz2]; ring
            rcases Nat.eq_or_lt_of_le hge with heq | hlt'
            · subst heq
              simp [hz3]
            · have hz4 : qBinom q (n + 1) (j + 1) = 0 := by
                rw [qBinom_succ_succ, hz1, qBinom_eq_zero_of_lt q (by omega : n < j)]; ring
              rw [qBinom_succ_succ q (n + 1) (j + 1), hz3, hz4]
              ring

/-- **Reflection symmetry** of the Gaussian binomials. -/
theorem qBinom_symm (q : k) : ∀ (n j : ℕ), j ≤ n → qBinom q n j = qBinom q n (n - j) := by
  intro n
  induction n with
  | zero => intro j hj; interval_cases j; simp
  | succ n ih =>
      intro j hj
      match j with
      | 0 => simp
      | (j + 1) =>
          have hj' : j ≤ n := by omega
          have e0 : n + 1 - (j + 1) = n - j := by omega
          rw [qBinom_succ_succ, e0]
          rcases Nat.eq_or_lt_of_le hj' with heq | hlt
          · subst heq
            rw [qBinom_eq_zero_of_lt q (by omega : j < j + 1)]
            simp
          · have e1 : n - j = (n - j - 1) + 1 := by omega
            have e2 : n - (n - j - 1) = j + 1 := by omega
            have e5 : n - j - 1 = n - (j + 1) := by omega
            have e6 : n - j - 1 + 1 = n - j := by omega
            have hR : qBinom q (n + 1) (n - j)
                = q ^ (j + 1) * qBinom q n (j + 1) + qBinom q n j := by
              rw [e1, qBinom_succ_succ, e2, e6, e5, ← ih (j + 1) (by omega), ← ih j (by omega)]
            have hp := qBinom_pascal' q n j
            rw [show qBinom q (n + 1) (j + 1)
                = q ^ (n - j) * qBinom q n j + qBinom q n (j + 1) from rfl] at hp
            rw [hR]
            linear_combination hp

end Defs

/-! ## 2. The `q`-binomial theorem -/

section Binomial

variable {k : Type*} [CommRing k] {R : Type*} [Ring R] [Algebra k R]

/-- If `y x = q (x y)` then `yᵐ x = qᵐ (x yᵐ)`. -/
theorem qpow_comm {q : k} {x y : R} (h : y * x = q • (x * y)) :
    ∀ m : ℕ, y ^ m * x = (q ^ m) • (x * y ^ m) := by
  intro m
  induction m with
  | zero => simp
  | succ m ih =>
      have hcalc : y ^ (m + 1) * x = q • (q ^ m • (x * y ^ m * y)) := by
        rw [pow_succ, mul_assoc, h, mul_smul_comm, ← mul_assoc, ih, smul_mul_assoc]
      rw [hcalc, smul_smul, ← pow_succ' q m, mul_assoc, ← pow_succ]

/-- **The `q`-binomial theorem.**  If `y x = q·(x y)` in a `k`-algebra, then
`(x + y)ⁿ = ∑_{j ≤ n} [n ; j]_q · x^j y^{n-j}`. -/
theorem add_pow_of_qCommute {q : k} {x y : R} (h : y * x = q • (x * y)) (n : ℕ) :
    (x + y) ^ n = ∑ j ∈ Finset.range (n + 1), qBinom q n j • (x ^ j * y ^ (n - j)) := by
  induction n with
  | zero => simp
  | succ n ih =>
      have hstep : ∀ i : ℕ, (qBinom q n i • (x ^ i * y ^ (n - i))) * x
          = (q ^ (n - i) * qBinom q n i) • (x ^ (i + 1) * y ^ (n - i)) := by
        intro i
        rw [smul_mul_assoc, mul_assoc, qpow_comm h (n - i), mul_smul_comm, smul_smul,
          ← mul_assoc, pow_succ, mul_comm (qBinom q n i) (q ^ (n - i))]
      have hS2 : ∑ j ∈ Finset.range (n + 1), qBinom q n j • (x ^ j * y ^ (n - j + 1))
          = (∑ i ∈ Finset.range (n + 1), qBinom q n (i + 1) • (x ^ (i + 1) * y ^ (n - i)))
            + qBinom q n 0 • (x ^ 0 * y ^ (n + 1)) := by
        rw [Finset.sum_range_succ' (fun j => qBinom q n j • (x ^ j * y ^ (n - j + 1))) n,
          Finset.sum_range_succ (fun i => qBinom q n (i + 1) • (x ^ (i + 1) * y ^ (n - i)))]
        rw [qBinom_eq_zero_of_lt q (by omega : n < n + 1)]
        simp only [zero_smul, add_zero]
        congr 1
        refine Finset.sum_congr rfl fun i hi => ?_
        rw [Finset.mem_range] at hi
        rw [show n - (i + 1) + 1 = n - i from by omega]
      rw [pow_succ, ih, Finset.sum_mul]
      simp only [mul_add]
      rw [Finset.sum_add_distrib]
      rw [Finset.sum_congr rfl (fun i _ => hstep i)]
      have hmy : ∀ i : ℕ, (qBinom q n i • (x ^ i * y ^ (n - i))) * y
          = qBinom q n i • (x ^ i * y ^ (n - i + 1)) := by
        intro i
        rw [smul_mul_assoc, mul_assoc, ← pow_succ]
      rw [Finset.sum_congr rfl (fun i _ => hmy i), hS2]
      rw [Finset.sum_range_succ' (fun j => qBinom q (n + 1) j • (x ^ j * y ^ (n + 1 - j))) (n + 1)]
      rw [← add_assoc, ← Finset.sum_add_distrib]
      congr 1
      · refine Finset.sum_congr rfl fun i _ => ?_
        rw [show n + 1 - (i + 1) = n - i from by omega, ← add_smul, ← qBinom_succ_succ]
      · simp

/-- At `q = 1` the Gaussian binomials are the ordinary binomial coefficients. -/
theorem qBinom_one_eq_choose (n j : ℕ) : qBinom (1 : k) n j = (n.choose j : k) := by
  induction n generalizing j with
  | zero => cases j <;> simp
  | succ n ih =>
      cases j with
      | zero => simp
      | succ j => rw [qBinom_succ_succ, ih, ih, Nat.choose_succ_succ]; push_cast; ring

/-- **The classical binomial theorem is the `q = 1` case.**  For commuting `x, y` the
`q`-binomial expansion collapses to the ordinary one. -/
theorem add_pow_of_commute_of_qBinom {x y : R} (h : y * x = x * y) (n : ℕ) :
    (x + y) ^ n = ∑ j ∈ Finset.range (n + 1), (n.choose j : k) • (x ^ j * y ^ (n - j)) := by
  have h1 : y * x = (1 : k) • (x * y) := by rw [one_smul, h]
  rw [add_pow_of_qCommute h1 n]
  exact Finset.sum_congr rfl fun j _ => by rw [qBinom_one_eq_choose]

end Binomial

/-! ## 3. Degeneration `q → 1` -/

section Limit

/-- Each Gaussian binomial is a (polynomial, hence) continuous function of `q`. -/
theorem qBinom_continuous (n j : ℕ) : Continuous fun q : ℝ => qBinom q n j := by
  induction n generalizing j with
  | zero => cases j <;> simp [qBinom] <;> exact continuous_const
  | succ n ih =>
      cases j with
      | zero => simpa using continuous_const
      | succ j =>
          simp only [qBinom_succ_succ]
          exact ((continuous_pow _).mul (ih j)).add (ih (j + 1))

/-- **The Gaussian binomial degenerates to the ordinary binomial coefficient as `q → 1`.** -/
theorem qBinom_tendsto_choose (n j : ℕ) :
    Tendsto (fun q : ℝ => qBinom q n j) (𝓝 1) (𝓝 (n.choose j : ℝ)) := by
  have := (qBinom_continuous n j).continuousAt (x := (1 : ℝ))
  rwa [ContinuousAt, qBinom_one_eq_choose] at this

end Limit

/-! ## 4. Bridge to `U_q(sl₂)` -/

section Bridge

open QuantumSL2

variable {k : Type*} [Field k]

/-- The **balanced** quantum integer of `Physics.QuantumSL2ClassicalLimit` is a normalised
Gaussian binomial at parameter `q²`: `[m]_q = q^{1-m} · [m ; 1]_{q²}`. -/
theorem qInt_eq_qBinom (q : k) (hq : q ≠ 0) (hq2 : q ^ 2 - 1 ≠ 0) (m : ℕ) :
    qInt q (m : ℤ) = q ^ (1 - (m : ℤ)) * qBinom (q ^ 2) m 1 := by
  rw [qBinom_one, qInt_nat_eq q hq hq2 m]

variable {A : Type*} [Ring A] [Algebra k A]

/-- **The `q`-binomial theorem inside `U_q(sl₂)`.**  The defining relation `K E = q² E K`
is a `q²`-commutation, so powers of `E + K` expand with Gaussian binomials at `q²`. -/
theorem IsUqSl2.add_pow_E_K {q : k} {E F Kk Ki : A} (h : IsUqSl2 q E F Kk Ki) (n : ℕ) :
    (E + Kk) ^ n
      = ∑ j ∈ Finset.range (n + 1), qBinom (q ^ 2) n j • (E ^ j * Kk ^ (n - j)) :=
  add_pow_of_qCommute h.K_E n

end Bridge

end QuantumBinomial