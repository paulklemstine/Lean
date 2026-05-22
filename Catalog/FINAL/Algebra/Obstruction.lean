/-
  # Necessary Divisibility Obstruction for Hadamard Matrices

  Proves that if a Hadamard matrix of order n exists with n > 2, then 4 ∣ n.
  This is the fundamental arithmetic obstruction that turns the Hadamard conjecture
  into a sharp existence problem: which multiples of 4 admit Hadamard matrices?

  ## Proof Strategy
  We use the classical normalization-and-parity argument:
  1. Take any three rows r₁, r₂, r₃ of H.
  2. Since each entry is ±1, we can partition columns by the sign pattern of (r₁, r₂, r₃).
  3. Orthogonality between pairs of rows gives linear constraints on the partition sizes.
  4. These constraints force n to be divisible by 4.
-/
import Algebra.Hadamard.Defs

open Matrix Finset BigOperators

/-! ## The main obstruction theorem -/

/-- If n > 2 and a Hadamard matrix of order n exists, then 4 ∣ n. -/
theorem four_dvd_of_hadamardOrder {n : ℕ}
    (hn : HadamardOrder n) (hgt : 2 < n) : 4 ∣ n := by
  obtain ⟨H, hH⟩ := hn
  -- Extract three distinct rows
  set r₁ := H (⟨0, by omega⟩ : Fin n)
  set r₂ := H (⟨1, by omega⟩ : Fin n)
  set r₃ := H (⟨2, by omega⟩ : Fin n)
  -- Key facts: entries are ±1, orthogonality, self-dot-products
  have hpm₁ : ∀ k, r₁ k = 1 ∨ r₁ k = -1 := fun k => hH.1 ⟨0, by omega⟩ k
  have hpm₂ : ∀ k, r₂ k = 1 ∨ r₂ k = -1 := fun k => hH.1 ⟨1, by omega⟩ k
  have hpm₃ : ∀ k, r₃ k = 1 ∨ r₃ k = -1 := fun k => hH.1 ⟨2, by omega⟩ k
  have h12 : ∑ k, r₁ k * r₂ k = 0 := hH.row_orthogonal _ _ (by simp)
  have h13 : ∑ k, r₁ k * r₃ k = 0 := hH.row_orthogonal _ _ (by simp)
  have h23 : ∑ k, r₂ k * r₃ k = 0 := hH.row_orthogonal _ _ (by simp)
  have h11 : ∑ k, r₁ k * r₁ k = (n : ℤ) := hH.row_dot_self _
  -- For each column k, define indicator variables for sign agreements
  -- a(k) = (1 + r₁(k)*r₂(k))/2 ∈ {0,1}: whether r₁ and r₂ agree at k
  -- b(k) = (1 + r₁(k)*r₃(k))/2 ∈ {0,1}: whether r₁ and r₃ agree at k
  -- Key sums from orthogonality:
  -- ∑ r₁*r₂ = 0 and ∑ r₁² = n  ⟹  ∑ (1+r₁r₂)/2 = n/2
  -- ∑ r₁*r₃ = 0  ⟹  ∑ (1+r₁r₃)/2 = n/2
  -- ∑ r₂*r₃ = 0 and r_i² = 1  ⟹  ∑ r₁²r₂r₃ = ∑ r₂r₃ = 0
  -- Now ∑ (1+r₁r₂)(1+r₁r₃) = n + ∑r₁r₂ + ∑r₁r₃ + ∑r₁²r₂r₃ = n + 0 + 0 + 0 = n
  -- So the number of columns where r₁,r₂ agree AND r₁,r₃ agree is n/4
  -- This means n/4 is an integer, i.e., 4 ∣ n.
  -- Compute ∑ (1 + r₁r₂)(1 + r₁r₃) = n
  have key : ∑ k, (1 + r₁ k * r₂ k) * (1 + r₁ k * r₃ k) = (n : ℤ) := by
    have expand : ∀ k, (1 + r₁ k * r₂ k) * (1 + r₁ k * r₃ k) =
        1 + r₁ k * r₂ k + r₁ k * r₃ k + r₁ k * r₁ k * (r₂ k * r₃ k) := by
      intro k
      rcases hpm₁ k with h | h <;> rw [h] <;> ring
    simp_rw [expand]
    simp only [Finset.sum_add_distrib]
    -- ∑ 1 = n, ∑ r₁r₂ = 0, ∑ r₁r₃ = 0
    -- ∑ r₁²r₂r₃ = ∑ r₂r₃ = 0 (since r₁² = 1)
    have h_r1sq_r2r3 : ∑ k, r₁ k * r₁ k * (r₂ k * r₃ k) = 0 := by
      have : ∀ k, r₁ k * r₁ k * (r₂ k * r₃ k) = r₂ k * r₃ k := by
        intro k; rcases hpm₁ k with h | h <;> rw [h] <;> ring
      simp_rw [this]; exact h23
    rw [h12, h13, h_r1sq_r2r3]
    simp
  -- Each term (1 + r₁r₂)(1 + r₁r₃) is either 0 or 4
  have each_term : ∀ k, (1 + r₁ k * r₂ k) * (1 + r₁ k * r₃ k) = 0 ∨
      (1 + r₁ k * r₂ k) * (1 + r₁ k * r₃ k) = 4 := by
    intro k
    rcases hpm₁ k with h₁ | h₁ <;> rcases hpm₂ k with h₂ | h₂ <;>
      rcases hpm₃ k with h₃ | h₃ <;> simp [h₁, h₂, h₃]
  -- Since each term is 0 or 4 and they sum to n, we get 4 ∣ n
  have h_dvd : (4 : ℤ) ∣ (n : ℤ) := by
    rw [← key]
    apply Finset.dvd_sum
    intro k _
    cases each_term k with
    | inl h => simp [h]
    | inr h => simp [h]
  exact Int.ofNat_dvd.mp h_dvd