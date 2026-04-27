import Mathlib

/-! # CatalogBuild.Pythagorean.InverseTree.ChainFactoring

Auto-generated from theorem catalog database.
Domain: Pythagorean/InverseTree
Declarations: 33
-/

/-- All three inverse maps share the same hypotenuse formula. -/
theorem inv_hyp_formula (a b c : ℤ) :
    (invB1 a b c).2.2 = -2*a - 2*b + 3*c ∧
    (invB2 a b c).2.2 = -2*a - 2*b + 3*c ∧
    (invB3 a b c).2.2 = -2*a - 2*b + 3*c := by
  simp [invB1, invB2, invB3]

/-- The parent hypotenuse is strictly less than the child's. -/
theorem parent_hyp_decrease (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    -2*a - 2*b + 3*c < c := by
  nlinarith [sq_nonneg (a + b - c)]

/-- The hypotenuse decreases by exactly 2(a + b - c). -/
theorem hyp_decrease_amount (a b c : ℤ) :
    c - (-2*a - 2*b + 3*c) = 2*(a + b) - 2*c := by ring

/-- B₁⁻¹ and B₂⁻¹ cannot both have positive second components. -/
theorem branch_exclusive_12 (a b c : ℤ)
    (h1 : 0 < (-2*a - b + 2*c))
    (h2 : 0 < (2*a + b - 2*c)) : False := by linarith

/-- B₁⁻¹/B₂⁻¹ and B₃⁻¹ cannot both have positive first components. -/
theorem branch_exclusive_123 (a b c : ℤ)
    (h1 : 0 < (a + 2*b - 2*c))
    (h2 : 0 < (-a - 2*b + 2*c)) : False := by linarith

/-- The computable parent function: selects the correct inverse Berggren matrix. -/
def parentTriple (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  let (a, b, c) := t
  let (a1, b1, _c1) := invB1 a b c
  if 0 < a1 && 0 < b1 then invB1 a b c
  else
    let (a2, b2, _c2) := invB2 a b c
    if 0 < a2 && 0 < b2 then invB2 a b c
    else invB3 a b c

/-- The chain function: f(d) = parent^d(t). -/
def chainF (t : ℤ × ℤ × ℤ) : ℕ → ℤ × ℤ × ℤ
  | 0 => t
  | d + 1 => parentTriple (chainF t d)

/-- f(0) = t. -/
theorem chain_zero (t : ℤ × ℤ × ℤ) : chainF t 0 = t := rfl

/-- f(d+1) = parent(f(d)). -/
theorem chain_succ (t : ℤ × ℤ × ℤ) (d : ℕ) :
    chainF t (d + 1) = parentTriple (chainF t d) := rfl

/-- The hypotenuse of a triple. -/
def tripleHyp (t : ℤ × ℤ × ℤ) : ℤ := t.2.2

/-- The parent triple preserves the Pythagorean property (for any branch). -/
theorem parent_preserves_pyth_any_branch (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    let t := parentTriple (a, b, c)
    t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 := by
  simp only [parentTriple]
  split
  · exact invB1_preserves_pyth a b c h
  · split
    · exact invB2_preserves_pyth a b c h
    · exact invB3_preserves_pyth a b c h

/-- The trivial PPT for an odd N: (N, (N²-1)/2, (N²+1)/2). -/
def trivialPPT (N : ℤ) : ℤ × ℤ × ℤ :=
  (N, (N ^ 2 - 1) / 2, (N ^ 2 + 1) / 2)

/-- [Section: # CatalogBuild.Pythagorean.InverseTree.ChainFactoring
Auto-generated from theorem catalog database.
Domain: Pythagorean/InverseTree
Declarations: 33] -/
theorem trivial_ppt_is_pyth (N : ℤ) (hodd : N % 2 = 1) (hN : 1 < N) :
    let t := trivialPPT N
    t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 := by
  simp only [trivialPPT]
  nlinarith [ Int.ediv_mul_cancel ( show 2 ∣ N ^ 2 + 1 from Int.dvd_of_emod_eq_zero ( by norm_num [ sq, Int.add_emod, Int.mul_emod, hodd ] ) ), Int.ediv_mul_cancel ( show 2 ∣ N ^ 2 - 1 from Int.dvd_of_emod_eq_zero ( by norm_num [ sq, Int.sub_emod, Int.mul_emod, hodd ] ) ) ]

/-- [Section: # CatalogBuild.Pythagorean.InverseTree.ChainFactoring
Auto-generated from theorem catalog database.
Domain: Pythagorean/InverseTree
Declarations: 33] -/
theorem trivial_ppt_diff (N : ℤ) (hodd : N % 2 = 1) :
    let t := trivialPPT N
    t.2.2 - t.2.1 = 1 ∧ t.2.2 + t.2.1 = N ^ 2 := by
  simp only [trivialPPT]
  constructor <;> linarith [ Int.ediv_mul_cancel ( show 2 ∣ N ^ 2 + 1 from Int.dvd_of_emod_eq_zero ( by norm_num [ sq, Int.add_emod, Int.mul_emod, hodd ] ) ), Int.ediv_mul_cancel ( show 2 ∣ N ^ 2 - 1 from Int.dvd_of_emod_eq_zero ( by norm_num [ sq, Int.sub_emod, Int.mul_emod, hodd ] ) ) ]

theorem divisor_pair_gives_triple_Z (N d e : ℤ)
    (hprod : d * e = N ^ 2) (hparity : (d + e) % 2 = 0) (hd_pos : 0 < d) (he_pos : 0 < e)
    (hlt : d < e) :
    N ^ 2 + ((e - d) / 2) ^ 2 = ((e + d) / 2) ^ 2 := by
  cases abs_cases N <;> nlinarith [ Int.ediv_mul_cancel ( show 2 ∣ e - d from Int.dvd_of_emod_eq_zero ( by omega ) ), Int.ediv_mul_cancel ( show 2 ∣ e + d from Int.dvd_of_emod_eq_zero ( by omega ) ) ]

theorem composite_nontrivial_factorization (p q : ℤ) (hp : 1 < p) (hq : 1 < q)
    (hodd_p : p % 2 = 1) (hodd_q : q % 2 = 1) :
    let N := p * q
    ∃ d e : ℤ, d * e = N ^ 2 ∧ 1 < d ∧ d < N ^ 2 ∧ (d + e) % 2 = 0 := by
  exact ⟨ p ^ 2, q ^ 2, by ring, one_lt_pow₀ hp two_ne_zero, by nlinarith [ pow_pos ( zero_lt_one.trans hp ) 2, pow_pos ( zero_lt_one.trans hq ) 2 ], by norm_num [ *, sq, Int.add_emod, Int.mul_emod ] ⟩

/-- For an odd prime p ≥ 5, the Berggren tree depth of the trivial PPT
is at most (p - 3) / 2. -/
theorem depth_bound_prime (p : ℕ) (hodd : p % 2 = 1) (hp5 : 5 ≤ p) :
    (p + 1) / 2 ≥ 2 ∧ (p + 1) / 2 - 2 = (p - 3) / 2 := by omega

/-- All three inverse Berggren matrices preserve the Lorentz form a² + b² - c². -/
theorem invB1_lorentz_form (a b c : ℤ) :
    let t := invB1 a b c
    t.1 ^ 2 + t.2.1 ^ 2 - t.2.2 ^ 2 = a ^ 2 + b ^ 2 - c ^ 2 := by
  simp only [invB1]; ring

theorem invB2_lorentz_form (a b c : ℤ) :
    let t := invB2 a b c
    t.1 ^ 2 + t.2.1 ^ 2 - t.2.2 ^ 2 = a ^ 2 + b ^ 2 - c ^ 2 := by
  simp only [invB2]; ring

theorem invB3_lorentz_form (a b c : ℤ) :
    let t := invB3 a b c
    t.1 ^ 2 + t.2.1 ^ 2 - t.2.2 ^ 2 = a ^ 2 + b ^ 2 - c ^ 2 := by
  simp only [invB3]; ring

/-- All three forward Berggren matrices preserve the Lorentz form. -/
theorem fwdB1_lorentz_form (a b c : ℤ) :
    let t := fwdB1 a b c
    t.1 ^ 2 + t.2.1 ^ 2 - t.2.2 ^ 2 = a ^ 2 + b ^ 2 - c ^ 2 := by
  simp only [fwdB1]; ring

theorem fwdB2_lorentz_form (a b c : ℤ) :
    let t := fwdB2 a b c
    t.1 ^ 2 + t.2.1 ^ 2 - t.2.2 ^ 2 = a ^ 2 + b ^ 2 - c ^ 2 := by
  simp only [fwdB2]; ring

theorem fwdB3_lorentz_form (a b c : ℤ) :
    let t := fwdB3 a b c
    t.1 ^ 2 + t.2.1 ^ 2 - t.2.2 ^ 2 = a ^ 2 + b ^ 2 - c ^ 2 := by
  simp only [fwdB3]; ring

/-- GCD of the chain components with N at each depth.
This computes gcd(a_d, N) for the chain from triple t. -/
def chainGcdA (t : ℤ × ℤ × ℤ) (N : ℤ) (d : ℕ) : ℤ :=
  Int.gcd (chainF t d).1 N

def chainGcdB (t : ℤ × ℤ × ℤ) (N : ℤ) (d : ℕ) : ℤ :=
  Int.gcd (chainF t d).2.1 N

/-- The GCD always divides N. -/
theorem chainGcdA_dvd_N (t : ℤ × ℤ × ℤ) (N : ℤ) (d : ℕ) :
    (chainGcdA t N d : ℤ) ∣ N := by
  simp [chainGcdA]
  exact_mod_cast Int.gcd_dvd_right (chainF t d).1 N

theorem chainGcdB_dvd_N (t : ℤ × ℤ × ℤ) (N : ℤ) (d : ℕ) :
    (chainGcdB t N d : ℤ) ∣ N := by
  simp [chainGcdB]
  exact_mod_cast Int.gcd_dvd_right (chainF t d).2.1 N

/-- If gcd(a_d, N) is nontrivial, it gives a valid factor of N. -/
theorem nontrivial_gcd_gives_factor (t : ℤ × ℤ × ℤ) (N : ℤ) (d : ℕ)
    (hgcd : 1 < chainGcdA t N d) (hgcd2 : chainGcdA t N d < N) :
    (chainGcdA t N d : ℤ) ∣ N ∧ 1 < chainGcdA t N d ∧ chainGcdA t N d < N :=
  ⟨chainGcdA_dvd_N t N d, hgcd, hgcd2⟩

/-- Verify: factoring N = 15 = 3 × 5 via the chain. -/
theorem factor_15 : ∃ d : ℕ, d ≤ 10 ∧
    let t := trivialPPT 15
    let g := Int.gcd (chainF t d).2.1 15
    1 < g ∧ g < 15 := by
  use 1
  native_decide

/-- Verify: factoring N = 21 = 3 × 7 via the chain. -/
theorem factor_21 : ∃ d : ℕ, d ≤ 10 ∧
    let t := trivialPPT 21
    let g := Int.gcd (chainF t d).2.1 21
    1 < g ∧ g < 21 := by
  use 1
  native_decide

/-- Verify: factoring N = 77 = 7 × 11 via the chain. -/
theorem factor_77 : ∃ d : ℕ, d ≤ 10 ∧
    let t := trivialPPT 77
    let g := Int.gcd (chainF t d).2.1 77
    1 < g ∧ g < 77 := by
  use 3
  native_decide

/-- Verify: factoring N = 143 = 11 × 13 via the chain. -/
theorem factor_143 : ∃ d : ℕ, d ≤ 10 ∧
    let t := trivialPPT 143
    let g := Int.gcd (chainF t d).2.1 143
    1 < g ∧ g < 143 := by
  use 5
  native_decide

/-- Verify: factoring N = 221 = 13 × 17 via the chain. -/
theorem factor_221 : ∃ d : ℕ, d ≤ 10 ∧
    let t := trivialPPT 221
    let g := Int.gcd (chainF t d).2.1 221
    1 < g ∧ g < 221 := by
  use 6
  native_decide

