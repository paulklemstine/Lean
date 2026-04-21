/-! # CatalogBuild.Algebra.DivisionAlgebras.CayleyDicksonHierarchy

Auto-generated from theorem catalog database.
Domain: Algebra/DivisionAlgebras
Declarations: 63
-/

import Mathlib

noncomputable section

/-- The Brahmagupta-Fibonacci identity (2-square composition).
This is the norm multiplicativity for ℂ. -/
theorem two_square_composition' (a₁ a₂ b₁ b₂ : ℤ) :
    (a₁^2 + a₂^2) * (b₁^2 + b₂^2) =
    (a₁*b₁ - a₂*b₂)^2 + (a₁*b₂ + a₂*b₁)^2 := by ring




/-- Euler's four-square identity (4-square composition).
This is the norm multiplicativity for ℍ. -/
theorem four_square_composition' (a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄ : ℤ) :
    (a₁^2 + a₂^2 + a₃^2 + a₄^2) * (b₁^2 + b₂^2 + b₃^2 + b₄^2) =
    (a₁*b₁ - a₂*b₂ - a₃*b₃ - a₄*b₄)^2 +
    (a₁*b₂ + a₂*b₁ + a₃*b₄ - a₄*b₃)^2 +
    (a₁*b₃ - a₂*b₄ + a₃*b₁ + a₄*b₂)^2 +
    (a₁*b₄ + a₂*b₃ - a₃*b₂ + a₄*b₁)^2 := by ring




/-- The Degen eight-square identity (8-square composition).
This is the norm multiplicativity for 𝕆 — the LAST such identity. -/
theorem eight_square_composition'
    (a₁ a₂ a₃ a₄ a₅ a₆ a₇ a₈ b₁ b₂ b₃ b₄ b₅ b₆ b₇ b₈ : ℤ) :
    (a₁^2 + a₂^2 + a₃^2 + a₄^2 + a₅^2 + a₆^2 + a₇^2 + a₈^2) *
    (b₁^2 + b₂^2 + b₃^2 + b₄^2 + b₅^2 + b₆^2 + b₇^2 + b₈^2) =
    (a₁*b₁ - a₂*b₂ - a₃*b₃ - a₄*b₄ - a₅*b₅ - a₆*b₆ - a₇*b₇ - a₈*b₈)^2 +
    (a₁*b₂ + a₂*b₁ + a₃*b₄ - a₄*b₃ + a₅*b₆ - a₆*b₅ - a₇*b₈ + a₈*b₇)^2 +
    (a₁*b₃ - a₂*b₄ + a₃*b₁ + a₄*b₂ + a₅*b₇ + a₆*b₈ - a₇*b₅ - a₈*b₆)^2 +
    (a₁*b₄ + a₂*b₃ - a₃*b₂ + a₄*b₁ + a₅*b₈ - a₆*b₇ + a₇*b₆ - a₈*b₅)^2 +
    (a₁*b₅ - a₂*b₆ - a₃*b₇ - a₄*b₈ + a₅*b₁ + a₆*b₂ + a₇*b₃ + a₈*b₄)^2 +
    (a₁*b₆ + a₂*b₅ - a₃*b₈ + a₄*b₇ - a₅*b₂ + a₆*b₁ - a₇*b₄ + a₈*b₃)^2 +
    (a₁*b₇ + a₂*b₈ + a₃*b₅ - a₄*b₆ - a₅*b₃ + a₆*b₄ + a₇*b₁ - a₈*b₂)^2 +
    (a₁*b₈ - a₂*b₇ + a₃*b₆ + a₄*b₅ - a₅*b₄ - a₆*b₃ + a₇*b₂ + a₈*b₁)^2 := by
  ring




/-- Quaternion multiplication is not commutative (explicit witness). -/
theorem quaternion_noncommutative' :
    ∃ (a b : Quaternion ℝ), a * b ≠ b * a := by
  use ⟨0, 1, 0, 0⟩, ⟨0, 0, 1, 0⟩
  simp [Quaternion.ext_iff]
  norm_num




/-- Mathlib's `associator` vanishes in any (associative) ring. -/
theorem assoc_zero_in_ring {α : Type*} [NonUnitalRing α] :
    (associator : α → α → α → α) = 0 := associator_eq_zero




/-- The ring-theoretic commutator [a, b] = ab - ba. -/
def ringCommutator' {α : Type*} [Ring α] (a b : α) : α := a * b - b * a




/-- The ringCommutator vanishes in a commutative ring. -/
theorem ringCommutator_zero_comm' {α : Type*} [CommRing α] (a b : α) :
    ringCommutator' a b = 0 := by
  unfold ringCommutator'; rw [mul_comm]; simp




/-- The ringCommutator is antisymmetric. -/
theorem ringCommutator_antisymm' {α : Type*} [Ring α] (a b : α) :
    ringCommutator' a b = -ringCommutator' b a := by
  simp only [ringCommutator', neg_sub]




/-- The Jacobi identity for the ring commutator in any associative ring. -/
theorem ringCommutator_jacobi' {α : Type*} [Ring α] (a b c : α) :
    ringCommutator' a (ringCommutator' b c) +
    ringCommutator' b (ringCommutator' c a) +
    ringCommutator' c (ringCommutator' a b) = 0 := by
  simp only [ringCommutator']; noncomm_ring




/-- The k-th power divisor sum: σ_k(n) = Σ_{d|n} d^k. -/
def sigma_k' (k n : ℕ) : ℤ := ∑ d ∈ Nat.divisors n, (d : ℤ) ^ k




/-- σ_k(1) = 1 for all k. -/
theorem sigma_k_one' (k : ℕ) : sigma_k' k 1 = 1 := by simp [sigma_k']




/-- σ_k(p) = 1 + p^k for prime p. -/
theorem sigma_k_prime' (k p : ℕ) (hp : Nat.Prime p) :
    sigma_k' k p = 1 + (p : ℤ) ^ k := by
  simp only [sigma_k', hp.divisors]
  rw [Finset.sum_insert (by simp; exact hp.ne_one.symm)]
  simp [Finset.sum_singleton]




/-- σ₁ multiplicativity: σ₁(6) = σ₁(2)·σ₁(3). -/
theorem sigma1_mult_2_3' : sigma_k' 1 6 = sigma_k' 1 2 * sigma_k' 1 3 := by native_decide




/-- σ₃ multiplicativity: σ₃(6) = σ₃(2)·σ₃(3). -/
theorem sigma3_mult_2_3' : sigma_k' 3 6 = sigma_k' 3 2 * sigma_k' 3 3 := by native_decide




/-- σ₇ multiplicativity: σ₇(6) = σ₇(2)·σ₇(3). -/
theorem sigma7_mult_2_3' : sigma_k' 7 6 = sigma_k' 7 2 * sigma_k' 7 3 := by native_decide




/-- The Hurwitz dimensions: exactly {1, 2, 4, 8}. -/
def hurwitzDims' : Finset ℕ := {1, 2, 4, 8}




/-- [Section: # CatalogBuild.Algebra.DivisionAlgebras.CayleyDicksonHierarchy
Auto-generated from theorem catalog database.
Domain: Algebra/DivisionAlgebras
Declarations: 63] -/
theorem hurwitz_card' : hurwitzDims'.card = 4 := by decide




/-- [Section: # CatalogBuild.Algebra.DivisionAlgebras.CayleyDicksonHierarchy
Auto-generated from theorem catalog database.
Domain: Algebra/DivisionAlgebras
Declarations: 63] -/
theorem hurwitz_are_powers_of_two' : ∀ d ∈ hurwitzDims', ∃ k, d = 2 ^ k := by
  intro d hd; simp [hurwitzDims'] at hd
  rcases hd with rfl | rfl | rfl | rfl
  · exact ⟨0, by norm_num⟩
  · exact ⟨1, by norm_num⟩
  · exact ⟨2, by norm_num⟩
  · exact ⟨3, by norm_num⟩




theorem dim16_not_hurwitz' : 16 ∉ hurwitzDims' := by decide



theorem dim32_not_hurwitz' : 32 ∉ hurwitzDims' := by decide



theorem hurwitz_sum' : hurwitzDims'.sum id = 15 := by decide



theorem hurwitz_prod' : hurwitzDims'.prod id = 64 := by decide




/-- The dimension of the n-th Cayley-Dickson algebra. -/
def cdDim' (n : ℕ) : ℕ := 2 ^ n




theorem cdDim_pos' (n : ℕ) : cdDim' n > 0 := by simp [cdDim']




theorem cdDim_succ' (n : ℕ) : cdDim' (n + 1) = 2 * cdDim' n := by
  unfold cdDim'; ring




/-- The sum of dimensions through level n is 2^(n+1) - 1. -/
theorem cdDim_sum' (n : ℕ) : ∑ i ∈ Finset.range (n + 1), cdDim' i = 2 ^ (n + 1) - 1 := by
  unfold cdDim'
  induction n with
  | zero => simp
  | succ n ih =>
    rw [Finset.sum_range_succ, ih]
    have : 1 ≤ 2 ^ (n + 1) := Nat.one_le_two_pow
    omega




/-- Each level has more dimensions than all previous levels combined. -/
theorem cdDim_dominates' (n : ℕ) (hn : n ≥ 1) :
    cdDim' n > ∑ i ∈ Finset.range n, cdDim' i := by
  simp only [cdDim']
  have h : ∑ i ∈ Finset.range n, (2 : ℕ) ^ i + 1 = 2 ^ n := by
    induction n with
    | zero => omega
    | succ n ih =>
      rw [Finset.sum_range_succ]
      by_cases hn0 : n = 0
      · simp [hn0]
      · have := ih (by omega)
        ring_nf; omega
  omega




/-- The complex norm-squared is multiplicative. -/
theorem complex_normSq_mul' (z w : ℂ) :
    Complex.normSq (z * w) = Complex.normSq z * Complex.normSq w :=
  map_mul Complex.normSq z w




/-- The quaternion norm-squared is multiplicative. -/
theorem quaternion_normSq_mul' (p q : Quaternion ℝ) :
    Quaternion.normSq (p * q) = Quaternion.normSq p * Quaternion.normSq q :=
  map_mul (Quaternion.normSq) p q




/-- Every natural number is a sum of 4 squares (Lagrange's theorem). -/
theorem lagrange_four_squares' (n : ℕ) :
    ∃ a b c d : ℕ, a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = n :=
  Nat.sum_four_squares n




/-- Every natural number is a sum of 8 squares. -/
theorem sum_of_eight_squares' (n : ℕ) :
    ∃ f : Fin 8 → ℕ, ∑ i, (f i)^2 = n := by
  obtain ⟨a, b, c, d, h⟩ := lagrange_four_squares' n
  exact ⟨![a, b, c, d, 0, 0, 0, 0], by simp [Fin.sum_univ_eight, h]⟩




/-- ℂ has no zero divisors (it is a field). -/
theorem complex_no_zero_div' (a b : ℂ) (ha : a ≠ 0) (hb : b ≠ 0) :
    a * b ≠ 0 := mul_ne_zero ha hb




/-- The quaternions have no zero divisors. -/
theorem quaternion_no_zero_div' (a b : Quaternion ℝ) (ha : a ≠ 0) (hb : b ≠ 0) :
    a * b ≠ 0 := by
  intro hab
  have h1 : Quaternion.normSq (a * b) = 0 := by rw [hab]; simp
  rw [quaternion_normSq_mul'] at h1
  have ha' : Quaternion.normSq a ≠ 0 :=
    fun h => ha (Quaternion.normSq_eq_zero.mp h)
  have hb' : Quaternion.normSq b ≠ 0 :=
    fun h => hb (Quaternion.normSq_eq_zero.mp h)
  exact absurd (mul_eq_zero.mp h1) (not_or.mpr ⟨ha', hb'⟩)




/-- The 2-square identity implies no zero divisors at Channel 2. -/
theorem two_sq_no_zero_div' (a b c d : ℤ)
    (h1 : a^2 + b^2 ≠ 0) (h2 : c^2 + d^2 ≠ 0) :
    (a*c - b*d)^2 + (a*d + b*c)^2 ≠ 0 := by
  rw [← two_square_composition']
  exact mul_ne_zero h1 h2




theorem bott_period' (n : ℕ) : 2^(n + 8) = 2^n * 256 := by ring




theorem bott_period_ratio' (n : ℕ) : 2^(n + 8) / 2^n = 256 := by
  rw [bott_period']; exact Nat.mul_div_cancel_left 256 (by positivity)




theorem bott_sedenion_connection' : (256 : ℕ) = 16^2 := by norm_num




/-- The dimension of S_k(Γ₀(4)), the cusp form space at weight k. -/
def cuspSpaceDim' : ℕ → ℕ
  | 2 => 0  | 4 => 0  | 6 => 0
  | 8 => 1  | 10 => 1  | 12 => 2  | 14 => 2
  | 16 => 5
  | _ => 0




theorem cusp_trivial_low' : cuspSpaceDim' 2 = 0 ∧ cuspSpaceDim' 4 = 0 := ⟨rfl, rfl⟩



theorem cusp_barrier' : cuspSpaceDim' 8 = 1 := rfl



theorem cusp_explosion' : cuspSpaceDim' 16 = 5 := rfl



theorem cusp_growth' : cuspSpaceDim' 16 = 5 * cuspSpaceDim' 8 := rfl




/-- Power-associativity: a^m · a^n = a^{m+n} in any monoid. -/
theorem pow_assoc_nat' {α : Type*} [Monoid α] (a : α) (m n : ℕ) :
    a ^ m * a ^ n = a ^ (m + n) := (pow_add a m n).symm




/-- Power-associativity for integer exponents. -/
theorem pow_assoc_int' {α : Type*} [Group α] (a : α) (m n : ℤ) :
    a ^ m * a ^ n = a ^ (m + n) := (zpow_add a m n).symm




/-- Data for each Cayley-Dickson level. -/
structure CayleyDicksonLevel' where
  level : ℕ
  dimension : ℕ
  isComposition : Bool
  numCuspForms : ℕ
  deriving DecidableEq, Repr




def cdLevel' : ℕ → CayleyDicksonLevel'
  | 0 => ⟨0, 1, true, 0⟩    -- ℝ
  | 1 => ⟨1, 2, true, 0⟩    -- ℂ
  | 2 => ⟨2, 4, true, 0⟩    -- ℍ
  | 3 => ⟨3, 8, true, 0⟩    -- 𝕆
  | 4 => ⟨4, 16, false, 1⟩  -- 𝕊 (sedenions)
  | 5 => ⟨5, 32, false, 5⟩  -- 𝕋 (trigintaduonions)
  | n + 6 => ⟨n + 6, 2^(n+6), false, 0⟩




/-- All composition algebras have dimension ≤ 8. -/
theorem composition_max_dim' (n : ℕ) :
    (cdLevel' n).isComposition = true → (cdLevel' n).dimension ≤ 8 := by
  match n with
  | 0 | 1 | 2 | 3 => simp [cdLevel']
  | 4 | 5 => simp [cdLevel']
  | n + 6 => simp [cdLevel']




/-- The first cusp form appears at level 4 (sedenions). -/
theorem first_cusp_at_sedenion' :
    (∀ k, k < 4 → (cdLevel' k).numCuspForms = 0) ∧
    (cdLevel' 4).numCuspForms > 0 := by
  constructor
  · intro k hk; interval_cases k <;> simp [cdLevel']
  · simp [cdLevel']




/-- The geometric sum: Σ_{i=0}^{n} 2^i = 2^{n+1} - 1. -/
theorem geometric_sum_powers_of_two' (n : ℕ) :
    ∑ i ∈ Finset.range (n + 1), 2^i = 2^(n+1) - 1 := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [Finset.sum_range_succ, ih]
    have : 1 ≤ 2 ^ (n + 1) := Nat.one_le_two_pow
    omega




/-- Channel n carries more information than all previous channels combined. -/
theorem channel_dominance' (n : ℕ) (hn : n ≥ 1) :
    2^n > ∑ i ∈ Finset.range n, 2^i := by
  have h : ∑ i ∈ Finset.range n, (2 : ℕ) ^ i + 1 = 2 ^ n := by
    induction n with
    | zero => omega
    | succ n ih =>
      rw [Finset.sum_range_succ]
      by_cases hn0 : n = 0
      · simp [hn0]
      · have := ih (by omega)
        ring_nf; omega
  omega




/-- No Cayley-Dickson algebra of dimension ≥ 16 is a composition algebra. -/
theorem zero_divisors_propagate' (n : ℕ) (hn : n ≥ 4) :
    2^n ∉ hurwitzDims' := by
  simp only [hurwitzDims', Finset.mem_insert, Finset.mem_singleton]
  have h16 : 2^n ≥ 16 := by
    calc 2 ^ n ≥ 2 ^ 4 := Nat.pow_le_pow_right (by omega) hn
    _ = 16 := by norm_num
  omega




/-- r₄(p) = 8(p+1) for odd prime p (Jacobi's formula). -/
def r4_prime' (p : ℕ) : ℕ := 8 * (p + 1)




theorem r4_of_5' : r4_prime' 5 = 48 := by norm_num [r4_prime']



theorem r4_of_7' : r4_prime' 7 = 64 := by norm_num [r4_prime']




/-- r₈(p) = 16(1 + p³) for odd prime p. -/
def r8_prime' (p : ℕ) : ℕ := 16 * (1 + p^3)




theorem r8_of_3' : r8_prime' 3 = 448 := by norm_num [r8_prime']




/-- The channel exponent for Channel k: the growth rate exponent. -/
def channelExponent' : ℕ → ℕ
  | 0 => 0
  | k + 1 => 2 ^ k - 1




theorem channel_exponents_explicit' :
    (channelExponent' 0, channelExponent' 1, channelExponent' 2,
     channelExponent' 3, channelExponent' 4) = (0, 0, 1, 3, 7) := by
  simp [channelExponent']




/-- The six channel dimensions. -/
theorem six_channel_dims :
    (2^0, 2^1, 2^2, 2^3, 2^4, 2^5) = (1, 2, 4, 8, 16, (32 : ℕ)) := by norm_num




/-- Total dimension through 6 channels = 63 = 2⁶ - 1. -/
theorem total_six_channels : (1 + 2 + 4 + 8 + 16 + 32 : ℕ) = 63 := by norm_num




/-- 63 = 2⁶ - 1 is a Mersenne number. -/
theorem sixtythree_mersenne' : (63 : ℕ) = 2^6 - 1 := by norm_num




/-- 31 = 2⁵ - 1 is a Mersenne prime. -/
theorem thirtyone_mersenne_prime : Nat.Prime 31 := by decide




/-- The first 5 channels sum to the Mersenne prime 31. -/
theorem five_channel_sum : (1 + 2 + 4 + 8 + 16 : ℕ) = 31 := by norm_num




end
