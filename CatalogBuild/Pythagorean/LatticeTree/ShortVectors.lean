/-! # CatalogBuild.Pythagorean.LatticeTree.ShortVectors

Auto-generated from theorem catalog database.
Domain: Pythagorean/LatticeTree
Declarations: 9
-/

import Mathlib

/-- If (m-n)(m+n) = N with m-n > 1 and m+n < N, we have a non-trivial factorization (over ℤ). -/
theorem short_vector_nontrivial_factor_int (m n N : ℤ)
    (hmn : (m - n) * (m + n) = N) (hd : m - n > 1) (he : m + n < N) (he' : m + n > 1) :
    ∃ d e : ℤ, d * e = N ∧ 1 < d ∧ d < N ∧ 1 < e ∧ e < N :=
  ⟨m - n, m + n, hmn, hd, by nlinarith, he', he⟩


/-- The short vector gives explicit divisibility (over ℤ). -/
theorem short_vector_gives_dvd_int (m n N : ℤ)
    (hmn : m ^ 2 - n ^ 2 = N) :
    (m - n) ∣ N ∧ (m + n) ∣ N := by
  have : (m - n) * (m + n) = N := by linarith
  exact ⟨⟨m + n, this.symm⟩, ⟨m - n, by linarith [mul_comm (m - n) (m + n)]⟩⟩


/-- The "short" (m,n) pair for N = pq satisfies the identity (over ℤ). -/
theorem short_pair_identity (p q : ℤ) (hodd_p : p % 2 = 1) (hodd_q : q % 2 = 1) :
    ((p + q) / 2) ^ 2 - ((q - p) / 2) ^ 2 = p * q := by
  have h1 : (2 : ℤ) ∣ (p + q) := by omega
  have h2 : (2 : ℤ) ∣ (q - p) := by omega
  have h1' := Int.ediv_mul_cancel h1
  have h2' := Int.ediv_mul_cancel h2
  have key : ((p + q) / 2 + (q - p) / 2) * ((p + q) / 2 - (q - p) / 2) =
    ((p + q) / 2) ^ 2 - ((q - p) / 2) ^ 2 := by ring
  rw [← key]
  have sum_eq : (p + q) / 2 + (q - p) / 2 = q := by linarith
  have diff_eq : (p + q) / 2 - (q - p) / 2 = p := by linarith
  rw [sum_eq, diff_eq, mul_comm]


/-- Gauss reduction step preserves the lattice determinant. -/
theorem gaussStep_det (a b c d k : ℤ) :
    (a - k * c) * d - (b - k * d) * c = a * d - b * c := by ring


/-- The key invariant: m² - n² transforms predictably under CF steps. -/
theorem cf_step_transform (m n q : ℤ) :
    let r := m - q * n
    (q * n + r) ^ 2 - n ^ 2 = m ^ 2 - n ^ 2 := by
  simp only; ring


/-- The quadruple lattice: N² | (x² + y² + z²). -/
def quadLattice (N : ℤ) (x y z : ℤ) : Prop :=
  (N ^ 2 : ℤ) ∣ (x ^ 2 + y ^ 2 + z ^ 2)


/-- In 3D, the quadruple tree gives 4 children per node vs 3. -/
theorem combined_approach_potential (d : ℕ) (hd : d = 3) :
    4 ^ d > 3 ^ d := by subst hd; norm_num


/-- Balanced semiprimes: p ≤ p². -/
theorem effective_complexity_balanced (p : ℕ) (_hp : 2 ≤ p) :
    p ≤ p * p := Nat.le_mul_of_pos_right p (by omega)


/-- Unbalanced semiprimes: p < p*q when q > 1. -/
theorem effective_complexity_unbalanced (p q : ℕ) (_hp : 2 ≤ p) (hq : p < q) :
    p < p * q := by nlinarith


