/-! # CatalogBuild.Computation.Factoring.InsideOutResearch

Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 17
-/

import Mathlib

/-- [Section: # CatalogBuild.Computation.Factoring.InsideOutResearch
Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 17] -/
theorem euclid_thin_triple (a : ℤ) (hodd : a % 2 = 1) :
    a ^ 2 + ((a ^ 2 - 1) / 2) ^ 2 = ((a ^ 2 + 1) / 2) ^ 2 := by
  nlinarith [ Int.ediv_mul_cancel ( show 2 ∣ a^2 - 1 from Int.dvd_of_emod_eq_zero ( by norm_num [ sq, Int.mul_emod, Int.sub_emod, hodd ] ) ), Int.ediv_mul_cancel ( show 2 ∣ a^2 + 1 from Int.dvd_of_emod_eq_zero ( by norm_num [ sq, Int.mul_emod, Int.add_emod, hodd ] ) ) ]



theorem factor_condition (N k p : ℤ) (hp : p ∣ N) :
    p ∣ ((N - 2*k)^2 - 1) ↔ p ∣ (4*k^2 - 1) := by
  obtain ⟨d, rfl⟩ := hp
  exact ⟨ fun ⟨ x, hx ⟩ => ⟨ x - p * d ^ 2 + 4 * d * k, by linarith ⟩, fun ⟨ x, hx ⟩ => ⟨ x + p * d ^ 2 - 4 * d * k, by linarith ⟩ ⟩ ;



/-- Factoring 4k² - 1 = (2k-1)(2k+1) -/
theorem four_k_sq_minus_one (k : ℤ) : 4 * k ^ 2 - 1 = (2 * k - 1) * (2 * k + 1) := by ring



/-- At k = (p-1)/2, we have 2k = p-1, so 2k+1 = p, hence p | (4k²-1) -/
theorem factor_at_half_p (p : ℕ) (hp : 2 ≤ p) (hodd : p % 2 = 1) :
    (p : ℤ) ∣ (4 * ((p - 1 : ℕ) / 2 : ℤ) ^ 2 - 1) := by
  rw [four_k_sq_minus_one]
  have hp_val : (p - 1 : ℕ) / 2 * 2 = p - 1 := by omega
  have h2k : 2 * ((p - 1 : ℕ) / 2 : ℤ) + 1 = (p : ℤ) := by
    push_cast
    omega
  rw [show 2 * ((p - 1 : ℕ) / 2 : ℤ) + 1 = (p : ℤ) from h2k]
  exact dvd_mul_left (p : ℤ) _



theorem no_factor_before_half (p : ℕ) (hp : Nat.Prime p) (hodd : p ≠ 2)
    (k : ℕ) (hk_pos : 0 < k) (hk_lt : k < (p - 1) / 2) :
    ¬((p : ℤ) ∣ (4 * (k : ℤ) ^ 2 - 1)) := by
  by_contra h_div
  have h_div_cases : (p : ℤ) ∣ (2 * k - 1) ∨ (p : ℤ) ∣ (2 * k + 1) := by
    exact Int.Prime.dvd_mul' hp ( by convert h_div using 1; ring );
  obtain h | h := h_div_cases <;> obtain ⟨ m, hm ⟩ := h <;> nlinarith [ show m = 1 by nlinarith [ Nat.div_mul_le_self ( p - 1 ) 2, Nat.sub_add_cancel hp.pos ], Nat.div_mul_le_self ( p - 1 ) 2, Nat.sub_add_cancel hp.pos ] ;



/-- The Berggren inverse B₁⁻¹ preserves the Pythagorean property -/
theorem invB1_preserves_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (a + 2*b - 2*c)^2 + (-2*a - b + 2*c)^2 = (-2*a - 2*b + 3*c)^2 := by
  nlinarith [h]



/-- The Berggren inverse B₂⁻¹ preserves the Pythagorean property -/
theorem invB2_preserves_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (a + 2*b - 2*c)^2 + (2*a + b - 2*c)^2 = (-2*a - 2*b + 3*c)^2 := by
  nlinarith [h]



/-- The Berggren inverse B₃⁻¹ preserves the Pythagorean property -/
theorem invB3_preserves_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (-a - 2*b + 2*c)^2 + (2*a + b - 2*c)^2 = (-2*a - 2*b + 3*c)^2 := by
  nlinarith [h]



theorem lorentz_invariant_B1 (a b c : ℤ) :
    (a + 2*b - 2*c)^2 + (-2*a - b + 2*c)^2 - (-2*a - 2*b + 3*c)^2 =
    a^2 + b^2 - c^2 := by ring



theorem lorentz_invariant_B2 (a b c : ℤ) :
    (a + 2*b - 2*c)^2 + (2*a + b - 2*c)^2 - (-2*a - 2*b + 3*c)^2 =
    a^2 + b^2 - c^2 := by ring



theorem lorentz_invariant_B3 (a b c : ℤ) :
    (-a - 2*b + 2*c)^2 + (2*a + b - 2*c)^2 - (-2*a - 2*b + 3*c)^2 =
    a^2 + b^2 - c^2 := by ring



/-- The hypotenuse strictly decreases at each step -/
theorem hyp_strictly_decreases (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpyth : a^2 + b^2 = c^2) :
    -2*a - 2*b + 3*c < c := by
  nlinarith [sq_nonneg (a + b - c)]



/-- If gcd(b_k, N) is nontrivial, it reveals a factor -/
theorem gcd_factor_detection (bk N : ℕ) (h1 : 1 < Nat.gcd bk N) (h2 : Nat.gcd bk N < N) :
    (Nat.gcd bk N) ∣ N ∧ 1 < Nat.gcd bk N := by
  exact ⟨Nat.gcd_dvd_right bk N, h1⟩



theorem semiprime_divisor (N p q : ℕ) (hN : N = p * q)
    (hp : Nat.Prime p) (hq : Nat.Prime q)
    (d : ℕ) (hd : d ∣ N) (h1 : 1 < d) (h2 : d < N) :
    d = p ∨ d = q := by
  simp_all +decide [ Nat.dvd_mul ];
  rcases hd with ⟨ k₁, hk₁, x, hx, rfl ⟩ ; rw [ Nat.dvd_prime hp, Nat.dvd_prime hq ] at *; aesop;



/-- The odd leg of the Euclid triple with m=(N+1)/2, n=(N-1)/2 is N -/
theorem euclid_odd_leg_is_N (N : ℤ) (hodd : N % 2 = 1) :
    ((N + 1) / 2) ^ 2 - ((N - 1) / 2) ^ 2 = N := by
  have hN : N = 2 * ((N - 1) / 2) + 1 := by omega
  have hm : (N + 1) / 2 = (N - 1) / 2 + 1 := by omega
  rw [hm]; ring_nf; omega



/-- The simplified closed-form inside-out factoring algorithm -/
def insideOutFactorV2 (N : ℕ) (maxSteps : ℕ) : Option (ℕ × ℕ) := Id.run do
  if N % 2 == 0 || N < 9 then return none
  for k in [:maxSteps] do
    let ak := N - 2 * k
    if ak ≤ 1 then break
    let bk := (ak * ak - 1) / 2
    let g := Nat.gcd bk N
    if 1 < g && g < N then return some (g, N / g)
  return none



/-- The multi-polynomial sieve version -/
def multiPolySieve (N : ℕ) (maxSteps : ℕ) : Option (ℕ × ℕ) := Id.run do
  if N % 2 == 0 || N < 4 then return none
  for k in [:maxSteps] do
    if k == 0 then continue
    let vals := #[k*k - 1, 2*k*k - 1, k*k + k - 1, 2*k*k + 1,
                   3*k*k - 1, k*k + k + 1, 3*k*k + 1]
    for v in vals do
      if v > 0 then
        let g := Nat.gcd v N
        if 1 < g && g < N then return some (g, N / g)
    if k*k > 1 then
      let g := Nat.gcd (k*k - 2) N
      if 1 < g && g < N then return some (g, N / g)
  return none

-- Verification
#eval insideOutFactorV2 77 100      -- some (7, 11)
#eval insideOutFactorV2 143 100     -- some (11, 13)
#eval insideOutFactorV2 10403 200   -- some (101, 103)
#eval multiPolySieve 77 100         -- finds factor earlier
#eval multiPolySieve 143 100
#eval multiPolySieve 10403 200

