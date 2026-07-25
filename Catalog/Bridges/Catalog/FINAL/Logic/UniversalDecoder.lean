import Mathlib

/-! # CatalogBuild.Logic.UniversalDecoder

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 16
-/

noncomputable section

/-- [Section: # CatalogBuild.Logic.UniversalDecoder
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 16] -/
theorem rational_density_quantitative (a b : ℝ) (hab : a < b) :
    ∃ (p : ℤ) (q : ℕ), 0 < q ∧ (q : ℝ) ≤ 1 / (b - a) + 1 ∧
    a < (p : ℝ) / q ∧ (p : ℝ) / q < b := by
      by_contra h_no_rational;
      -- Let's choose any rational number $q$ such that $0 < q \leq \lceil 1 / (b - a) \rceil + 1$.
      obtain ⟨q, hq⟩ : ∃ q : ℕ, 0 < q ∧ (q : ℝ) ≤ 1 / (b - a) + 1 ∧ ∃ p : ℤ, a * q < p ∧ p < b * q := by
        refine' ⟨ ⌊ ( b - a ) ⁻¹⌋₊ + 1, _, _, _ ⟩ <;> norm_num;
        · exact Nat.floor_le ( inv_nonneg.2 ( sub_nonneg.2 hab.le ) );
        · refine' ⟨ ⌊a * ( ⌊ ( b - a ) ⁻¹⌋₊ + 1 ) ⌋ + 1, _, _ ⟩ <;> push_cast <;> nlinarith [ Nat.lt_floor_add_one ( ( b - a ) ⁻¹ ), mul_inv_cancel₀ ( by linarith : ( b - a ) ≠ 0 ), Int.floor_le ( a * ( ⌊ ( b - a ) ⁻¹⌋₊ + 1 ) ), Int.lt_floor_add_one ( a * ( ⌊ ( b - a ) ⁻¹⌋₊ + 1 ) ) ];
      exact h_no_rational ⟨ hq.2.2.choose, q, hq.1, hq.2.1, by rw [ lt_div_iff₀ ( Nat.cast_pos.mpr hq.1 ) ] ; linarith [ hq.2.2.choose_spec ], by rw [ div_lt_iff₀ ( Nat.cast_pos.mpr hq.1 ) ] ; linarith [ hq.2.2.choose_spec ] ⟩

/-- A simple continued fraction represented as a finite list of partial quotients -/
def SimpleCF := List ℕ

/-- Evaluate a simple continued fraction to a rational number -/
def evalCF : SimpleCF → ℚ
  | [] => 0
  | [a] => a
  | (a :: rest) => a + 1 / (evalCF rest)

/-- [Section: # CatalogBuild.Logic.UniversalDecoder
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 16] -/
theorem rat_has_cf (q : ℚ) (hq : 0 < q) :
    ∃ cf : SimpleCF, cf ≠ [] ∧ evalCF cf = q := by
      -- By definition of $evalCF$, we know that if $q = \frac{p}{r}$ with $p$ and $r$ being coprime integers, then $evalCF cf = q$ for some $cf$.
      have h_exists_cf : ∀ {p r : ℕ}, 0 < p → 0 < r → Nat.gcd p r = 1 → ∃ cf : SimpleCF, cf ≠ [] ∧ evalCF cf = p / r := by
        intros p r hp hr h_coprime
        induction' r using Nat.strong_induction_on with r ih generalizing p;
        by_cases h_cases : p % r = 0;
        · obtain ⟨ k, hk ⟩ := Nat.dvd_of_mod_eq_zero h_cases; use [ k ] ; aesop;
        · -- If $p$ is not divisible by $r$, then we can write $p = qr + s$ where $0 < s < r$.
          obtain ⟨q, s, hs⟩ : ∃ q s : ℕ, 0 < s ∧ s < r ∧ p = q * r + s := by
            exact ⟨ p / r, p % r, Nat.pos_of_ne_zero h_cases, Nat.mod_lt _ hr, by rw [ Nat.div_add_mod' ] ⟩;
          -- By the induction hypothesis, there exists a continued fraction $cf'$ such that $evalCF cf' = r / s$.
          obtain ⟨cf', hcf'_ne_empty, hcf'_eval⟩ : ∃ cf' : SimpleCF, cf' ≠ [] ∧ evalCF cf' = r / s := by
            simp_all +decide [ Nat.gcd_comm ];
          use q :: cf';
          -- By definition of $evalCF$, we have $evalCF (q :: cf') = q + 1 / evalCF cf'$.
          have h_eval : evalCF (q :: cf') = q + 1 / evalCF cf' := by
            cases cf' <;> tauto;
          simp_all +decide [ ne_of_gt, add_div ];
      convert h_exists_cf ( show 0 < q.num.natAbs by exact Int.natAbs_pos.mpr ( ne_of_gt ( Rat.num_pos.mpr hq ) ) ) ( show 0 < q.den by exact q.pos ) ( q.reduced ) using 1 ; simp +decide [ abs_of_pos, hq, Rat.num_div_den ]

/-- An element of SL(2,ℤ) represented by its four entries -/
structure SL2Z where
  a : ℤ
  b : ℤ
  c : ℤ
  d : ℤ
  det_one : a * d - b * c = 1

/-- The identity element -/
def SL2Z.one : SL2Z := ⟨1, 0, 0, 1, by ring⟩

/-- The S generator: z ↦ -1/z -/
def SL2Z.S : SL2Z := ⟨0, -1, 1, 0, by ring⟩

/-- The T generator: z ↦ z + 1 -/
def SL2Z.T : SL2Z := ⟨1, 1, 0, 1, by ring⟩

/-- Matrix multiplication in SL(2,ℤ) -/
def SL2Z.mul (A B : SL2Z) : SL2Z where
  a := A.a * B.a + A.b * B.c
  b := A.a * B.b + A.b * B.d
  c := A.c * B.a + A.d * B.c
  d := A.c * B.b + A.d * B.d
  det_one := by nlinarith [A.det_one, B.det_one]

theorem SL2Z_S_sq : let S2 := SL2Z.mul SL2Z.S SL2Z.S
    S2.a = -1 ∧ S2.b = 0 ∧ S2.c = 0 ∧ S2.d = -1 := by
      exact ⟨ rfl, rfl, rfl, rfl ⟩

theorem SL2Z_ST_order :
    let ST := SL2Z.mul SL2Z.S SL2Z.T
    let ST3 := SL2Z.mul (SL2Z.mul ST ST) ST
    ST3.a = -1 ∧ ST3.b = 0 ∧ ST3.c = 0 ∧ ST3.d = -1 := by
      decide +kernel

/-- The Möbius function -/
noncomputable def moebius (n : ℕ) : ℤ :=
  if n = 0 then 0
  else if ¬ Squarefree n then 0
  else if Even (Nat.card (n.primeFactors)) then 1
  else -1

theorem moebius_sum_eq_indicator (n : ℕ) (hn : 0 < n) :
    (∑ d ∈ Nat.divisors n, ArithmeticFunction.moebius (d : ℕ)) =
    if n = 1 then 1 else 0 := by
      -- Apply the Möbius inversion formula.
      have h_moebius_sum : ∑ d ∈ Nat.divisors n, ArithmeticFunction.moebius d = (ArithmeticFunction.moebius * ArithmeticFunction.zeta) (n : ℕ) := by
        exact?;
      aesop

theorem euler_product_finite_sq (S : Finset ℕ) (hS : ∀ p ∈ S, Nat.Prime p) :
    ∀ p ∈ S, (1 : ℚ) - 1 / (p : ℚ)^2 ≠ 0 := by
      exact fun p hp => sub_ne_zero_of_ne <| ne_of_gt <| by rw [ div_lt_iff₀ ] <;> norm_cast <;> nlinarith [ Nat.Prime.one_lt <| hS p hp ] ;

/-- The signed area of a triangle with vertices (x₁,y₁), (x₂,y₂), (x₃,y₃) -/
def triangleArea (x₁ y₁ x₂ y₂ x₃ y₃ : ℚ) : ℚ :=
  (x₁ * (y₂ - y₃) + x₂ * (y₃ - y₁) + x₃ * (y₁ - y₂)) / 2

theorem stereo_triangle_area (t₁ t₂ : ℚ) :
    let x₁ := (1 - t₁^2) / (1 + t₁^2)
    let y₁ := 2 * t₁ / (1 + t₁^2)
    let x₂ := (1 - t₂^2) / (1 + t₂^2)
    let y₂ := 2 * t₂ / (1 + t₂^2)
    triangleArea 0 0 x₁ y₁ x₂ y₂ =
    (t₂ - t₁) * (1 + t₁ * t₂) / ((1 + t₁^2) * (1 + t₂^2)) := by
      unfold triangleArea; ring;
      -- Combine like terms and simplify the expression.
      field_simp
      ring

end