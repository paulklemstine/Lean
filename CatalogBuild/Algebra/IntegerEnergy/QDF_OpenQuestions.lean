/-! # CatalogBuild.Algebra.IntegerEnergy.QDF_OpenQuestions

Auto-generated from theorem catalog database.
Domain: Algebra/IntegerEnergy
Declarations: 26
-/

import Mathlib

/-- For each d, the trivial quadruple (d, 0, 0, d) exists. -/
theorem quadruple_exists_trivial (d : ℤ) :
    ∃ a b c : ℤ, a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2 := by
  exact ⟨d, 0, 0, by ring⟩


/-- [Section: # CatalogBuild.Pythagorean.QDF.QDF_OpenQuestions
Auto-generated from theorem catalog database.
Domain: Pythagorean/QDF
Declarations: 26] -/
theorem trivial_gcd_coprime (N c d : ℤ)
    (h1 : Int.gcd (d - c) N = 1) (h2 : Int.gcd (d + c) N = 1) :
    Int.gcd ((d - c) * (d + c)) N = 1 := by
  simp_all +decide [ Int.gcd_eq_natAbs, Int.natAbs_mul ];
  exact Nat.Coprime.mul_left h1 h2


/-- [Section: # CatalogBuild.Pythagorean.QDF.QDF_OpenQuestions
Auto-generated from theorem catalog database.
Domain: Pythagorean/QDF
Declarations: 26] -/
theorem trivial_gcd_implies_coprime_sum (a b c d N : ℤ)
    (h_quad : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (h1 : Int.gcd (d - c) N = 1) (h2 : Int.gcd (d + c) N = 1) :
    Int.gcd (a ^ 2 + b ^ 2) N = 1 := by
  simp_all +decide [ Int.gcd_eq_natAbs, Int.natAbs_mul ];
  rw [ show a ^ 2 + b ^ 2 = ( d - c ) * ( d + c ) by linarith ] ; simp_all +decide [ Int.natAbs_mul, Nat.coprime_mul_iff_left, Nat.coprime_mul_iff_right ] ;
  exact ⟨ h1, h2 ⟩


/-- Two quadruples sharing hypotenuse relate their component sums. -/
theorem shared_component_factor (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d ^ 2) :
    (a₁ ^ 2 + b₁ ^ 2) = (a₂ ^ 2 + b₂ ^ 2) + (c₂ ^ 2 - c₁ ^ 2) := by
  linarith


/-- Parametric deformation: changing m by 1 changes 'a' by 2m+1. -/
theorem param_deformation_bound (m n p q : ℤ) :
    let a := m ^ 2 + n ^ 2 - p ^ 2 - q ^ 2
    let a' := (m + 1) ^ 2 + n ^ 2 - p ^ 2 - q ^ 2
    a' - a = 2 * m + 1 := by
  simp only; ring


/-- For any positive p and d > p, there exists c with p | (d - c). -/
theorem grover_good_pair_exists (p : ℤ) (hp_pos : p > 0)
    (d : ℤ) (hd : d > p) :
    ∃ c : ℤ, 0 < c ∧ c < d ∧ p ∣ (d - c) := by
  exact ⟨d - p, by omega, by omega, ⟨1, by ring⟩⟩


/-- k-Tuple Composition: triples compose to quadruples. -/
theorem ktuple_composition_3_to_4 (a b c k d : ℤ)
    (h1 : a ^ 2 + b ^ 2 = c ^ 2)
    (h2 : c ^ 2 + k ^ 2 = d ^ 2) :
    a ^ 2 + b ^ 2 + k ^ 2 = d ^ 2 := by linarith


/-- k-Tuple Composition: quadruples compose to quintuples. -/
theorem ktuple_composition_4_to_5 (a b c k e d : ℤ)
    (h1 : a ^ 2 + b ^ 2 + c ^ 2 = k ^ 2)
    (h2 : k ^ 2 + e ^ 2 = d ^ 2) :
    a ^ 2 + b ^ 2 + c ^ 2 + e ^ 2 = d ^ 2 := by linarith


/-- 5-tuple factor identity: (e-d)(e+d) = a²+b²+c². -/
theorem quintuple_factor_identity (a b c d e : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = e ^ 2) :
    (e - d) * (e + d) = a ^ 2 + b ^ 2 + c ^ 2 := by nlinarith


/-- 5-tuple GCD cascade: 4 independent difference-of-square factorizations. -/
theorem quintuple_gcd_cascade (a b c d e : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = e ^ 2) :
    (e - d) * (e + d) = a ^ 2 + b ^ 2 + c ^ 2 ∧
    (e - c) * (e + c) = a ^ 2 + b ^ 2 + d ^ 2 ∧
    (e - b) * (e + b) = a ^ 2 + c ^ 2 + d ^ 2 ∧
    (e - a) * (e + a) = b ^ 2 + c ^ 2 + d ^ 2 := by
  exact ⟨by nlinarith, by nlinarith, by nlinarith, by nlinarith⟩


/-- k-Tuple Factor Richness: 3 independent factor extractions from a quintuple. -/
theorem quintuple_four_factorizations (a b c d e : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = e ^ 2) :
    (↑(Int.gcd (e - d) a) : ℤ) * ↑(Int.gcd (e + d) a) ∣ a ^ 2 ∧
    (↑(Int.gcd (e - c) a) : ℤ) * ↑(Int.gcd (e + c) a) ∣ a ^ 2 ∧
    (↑(Int.gcd (e - b) a) : ℤ) * ↑(Int.gcd (e + b) a) ∣ a ^ 2 := by
  constructor
  · calc (↑(Int.gcd (e - d) a) : ℤ) * ↑(Int.gcd (e + d) a)
        ∣ a * a := mul_dvd_mul (Int.gcd_dvd_right _ _) (Int.gcd_dvd_right _ _)
      _ = a ^ 2 := by ring
  constructor
  · calc (↑(Int.gcd (e - c) a) : ℤ) * ↑(Int.gcd (e + c) a)
        ∣ a * a := mul_dvd_mul (Int.gcd_dvd_right _ _) (Int.gcd_dvd_right _ _)
      _ = a ^ 2 := by ring
  · calc (↑(Int.gcd (e - b) a) : ℤ) * ↑(Int.gcd (e + b) a)
      ∣ a * a := mul_dvd_mul (Int.gcd_dvd_right _ _) (Int.gcd_dvd_right _ _)
    _ = a ^ 2 := by ring


/-- General factor identity for dimension k=3. -/
theorem general_factor_identity_k3 (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (c - b) * (c + b) = a ^ 2 := by nlinarith


/-- General factor identity for dimension k=4. -/
theorem general_factor_identity_k4 (a b c d : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (d - c) * (d + c) = a ^ 2 + b ^ 2 := by nlinarith


/-- General factor identity for dimension k=5. -/
theorem general_factor_identity_k5 (a b c d e : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = e ^ 2) :
    (e - d) * (e + d) = a ^ 2 + b ^ 2 + c ^ 2 := by nlinarith


/-- General factor identity for dimension k=6. -/
theorem general_factor_identity_k6 (a b c d e f : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 + e ^ 2 = f ^ 2) :
    (f - e) * (f + e) = a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 := by nlinarith


/-- Berggren M₁ preserves the Pythagorean property. -/
theorem berggrenM1_oq_preserves (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    let a' := a - 2 * b + 2 * c
    let b' := 2 * a - b + 2 * c
    let c' := 2 * a - 2 * b + 3 * c
    a' ^ 2 + b' ^ 2 = c' ^ 2 := by
  simp only; nlinarith


/-- Berggren M₁ determinant is +1 (preserves orientation). -/
theorem berggren_M1_det_one :
    let M : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]
    M.det = 1 := by decide


/-- Bridge creates adjacency: lifting through 4D connects distant triples. -/
theorem bridge_creates_adjacency (a b c k d e : ℤ)
    (h_pyth : a ^ 2 + b ^ 2 = c ^ 2)
    (h_quad : a ^ 2 + b ^ 2 + k ^ 2 = d ^ 2)
    (h_proj : a ^ 2 + k ^ 2 = e ^ 2) :
    e ^ 2 + b ^ 2 = d ^ 2 := by linarith


/-- Bridge hypotenuse: the 4D hypotenuse d² > original c² when k ≠ 0. -/
theorem bridge_hypotenuse_gt (a b c k d : ℤ)
    (h_pyth : a ^ 2 + b ^ 2 = c ^ 2)
    (h_quad : a ^ 2 + b ^ 2 + k ^ 2 = d ^ 2)
    (hk : k ≠ 0) :
    d ^ 2 > c ^ 2 := by
  have : k ^ 2 > 0 := by positivity
  linarith


/-- Bridge can decrease hypotenuse via different projection axis. -/
theorem bridge_can_decrease (a b c d : ℤ)
    (h_quad : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (e : ℤ) (h_e : a ^ 2 + b ^ 2 = e ^ 2) :
    e ^ 2 ≤ d ^ 2 := by nlinarith [sq_nonneg c]


/-- [Section: # CatalogBuild.Pythagorean.QDF.QDF_OpenQuestions
Auto-generated from theorem catalog database.
Domain: Pythagorean/QDF
Declarations: 26] -/
theorem even_hyp_parity (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (hd : 2 ∣ d) (ha : ¬2 ∣ a) (hb : ¬2 ∣ b) :
    2 ∣ c := by
  replace h := congr_arg ( · % 4 ) h; rcases hd with ⟨ k, rfl ⟩ ; rcases Int.even_or_odd' a with ⟨ m, rfl | rfl ⟩ <;> rcases Int.even_or_odd' b with ⟨ n, rfl | rfl ⟩ <;> rcases Int.even_or_odd' c with ⟨ o, rfl | rfl ⟩ <;> ring_nf at * <;> norm_num at *;


/-- Quaternion norm preservation: the parametric map produces valid quadruples. -/
theorem quaternion_norm_preserved (m n p q : ℤ) :
    let a := m ^ 2 + n ^ 2 - p ^ 2 - q ^ 2
    let b := 2 * (m * q + n * p)
    let c := 2 * (n * q - m * p)
    let d := m ^ 2 + n ^ 2 + p ^ 2 + q ^ 2
    a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2 := by
  simp only; ring


theorem division_decreasing (d g : ℤ) (hg : g > 1) (hd_pos : d > 0) (hgd : g ∣ d) :
    d / g < d := by
  nlinarith [ Int.ediv_mul_cancel hgd ]


/-- Two quadruples with shared hypotenuse: cross-difference identity. -/
theorem cross_quad_factor (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d ^ 2) :
    (c₁ - c₂) * (c₁ + c₂) = (a₂ ^ 2 - a₁ ^ 2) + (b₂ ^ 2 - b₁ ^ 2) := by
  nlinarith


/-- GCD of cross-differences with N always divides N. -/
theorem cross_gcd_divides (c₁ c₂ N : ℤ) :
    (↑(Int.gcd (c₁ ^ 2 - c₂ ^ 2) N) : ℤ) ∣ N := by
  exact Int.gcd_dvd_right _ _


/-- Cross-difference factors multiplicatively. -/
theorem cross_diff_factors (c₁ c₂ : ℤ) :
    c₁ ^ 2 - c₂ ^ 2 = (c₁ - c₂) * (c₁ + c₂) := by ring


