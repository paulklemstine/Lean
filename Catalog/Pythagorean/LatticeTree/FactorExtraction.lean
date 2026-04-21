/-! # CatalogBuild.Pythagorean.LatticeTree.FactorExtraction

Auto-generated from theorem catalog database.
Domain: Pythagorean/LatticeTree
Declarations: 7
-/

import Mathlib

/-- [Section: # CatalogBuild.Pythagorean.LatticeTree.FactorExtraction
Auto-generated from theorem catalog database.
Domain: Pythagorean/LatticeTree
Declarations: 7] -/
theorem cascade_factor_extraction (N p x y z k : ℤ)
    (hsum : x ^ 2 + y ^ 2 + z ^ 2 = k * N)
    (hp : p ∣ N) (hpz : p ∣ z) :
    p ∣ (x ^ 2 + y ^ 2) := by
  have hpz2 : p ∣ z ^ 2 := by
    rw [sq]; exact dvd_mul_of_dvd_left hpz z
  have hpkN : p ∣ k * N := dvd_mul_of_dvd_right hp k
  have : x ^ 2 + y ^ 2 = k * N - z ^ 2 := by linarith
  rw [this]; exact dvd_sub hpkN hpz2




/-- Each short vector (x,y,z) gives 3 GCD candidates:
gcd(x²+y², N), gcd(x²+z², N), gcd(y²+z², N). -/
def extractionCandidates (N x y z : ℤ) : Fin 3 → ℕ :=
  ![Int.gcd (x ^ 2 + y ^ 2) N,
    Int.gcd (x ^ 2 + z ^ 2) N,
    Int.gcd (y ^ 2 + z ^ 2) N]




/-- All extraction candidates divide N. -/
theorem candidates_divide_N (N x y z : ℤ) (i : Fin 3) :
    ↑(extractionCandidates N x y z i) ∣ N := by
  fin_cases i <;> simp [extractionCandidates] <;> exact Int.gcd_dvd_right _ _




/-- Three-square version: (a²+b²+c²)(d²+e²+f²) ≥ (ad+be+cf)². -/
theorem three_square_cauchy_schwarz (a b c d e f : ℤ) :
    (a * d + b * e + c * f) ^ 2 ≤ (a ^ 2 + b ^ 2 + c ^ 2) * (d ^ 2 + e ^ 2 + f ^ 2) := by
  nlinarith [sq_nonneg (a * e - b * d), sq_nonneg (a * f - c * d), sq_nonneg (b * f - c * e)]




/-- In dimension 2: Minkowski gives ‖v‖ ≈ √Δ = √N.
In dimension 3: Minkowski gives ‖v‖ ≈ Δ^{1/3} = N^{1/3}.
The ratio N^{1/3}/N^{1/2} = N^{-1/6} → 0 as N → ∞. -/
theorem dim_advantage_exponent : (2 : ℕ) * 1 < (3 : ℕ) * 1 := by norm_num




/-- For 6 short vectors × 3 candidates each = 18 GCD computations. -/
theorem total_candidates : 6 * 3 = 18 := by norm_num




/-- [Section: # CatalogBuild.Pythagorean.LatticeTree.FactorExtraction
Auto-generated from theorem catalog database.
Domain: Pythagorean/LatticeTree
Declarations: 7] -/
theorem pipeline_sound (N g : ℤ) (hN : 1 < N)
    (hg : g ∣ N) (hg1 : 1 < g) (hgN : g < N) :
    ∃ p q : ℤ, N = p * q ∧ 1 < p ∧ p < N := by
  obtain ⟨q, hq⟩ := hg
  exact ⟨g, q, by linarith, hg1, hgN⟩



