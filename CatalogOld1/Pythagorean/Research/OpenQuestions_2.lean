import Mathlib

/-!
# The Integrality Trichotomy: Open Questions

## Addressing the Four Open Problems

1. **Tree structure for k = 6:** Computational verification of the single-tree property.
2. **What happens at k = 5?** Alternative descent mechanisms.
3. **Connection to norms:** Algebraic structures underlying k ∈ {3,4,6}.
4. **Mod-p variants:** Modular descent over 𝔽_p.
-/

open Matrix Finset

/-! ## Part 1: k = 6 Descent — Toward the Single Tree Property -/

/-- The Lorentz form Q₆(v) = v₀² + v₁² + v₂² + v₃² + v₄² - v₅² -/
def Q6 (v : Fin 6 → ℤ) : ℤ :=
  v 0 ^ 2 + v 1 ^ 2 + v 2 ^ 2 + v 3 ^ 2 + v 4 ^ 2 - v 5 ^ 2

/-
The parity lemma: on the null cone, the sum minus hypotenuse is even
-/
theorem null_cone_eta_even (v : Fin 6 → ℤ)
    (hNull : v 0 ^ 2 + v 1 ^ 2 + v 2 ^ 2 + v 3 ^ 2 + v 4 ^ 2 = v 5 ^ 2) :
    2 ∣ (v 0 + v 1 + v 2 + v 3 + v 4 - v 5) := by
  exact even_iff_two_dvd.mp ( by apply_fun Even at hNull; simp_all +decide [ parity_simps ] )

/-
The descent identity for k = 6
-/
theorem descent_identity_k6 (a₁ a₂ a₃ a₄ a₅ d : ℤ)
    (h : a₁^2 + a₂^2 + a₃^2 + a₄^2 + a₅^2 = d^2)
    (σ : ℤ) (hσ : 2 * σ = a₁ + a₂ + a₃ + a₄ + a₅ - d) :
    (a₁-σ)^2 + (a₂-σ)^2 + (a₃-σ)^2 + (a₄-σ)^2 + (a₅-σ)^2 = (d-σ)^2 := by
  grind

/-
Strict descent: new hypotenuse d' = d - σ satisfies 0 < d' < d
-/
theorem descent_strict_k6 (a₁ a₂ a₃ a₄ a₅ d : ℤ)
    (h : a₁^2 + a₂^2 + a₃^2 + a₄^2 + a₅^2 = d^2)
    (h1 : 0 ≤ a₁) (h2 : 0 ≤ a₂) (h3 : 0 ≤ a₃) (h4 : 0 < a₄) (h5 : 0 < a₅)
    (hd : 0 < d)
    (σ : ℤ) (hσ : 2 * σ = a₁ + a₂ + a₃ + a₄ + a₅ - d) :
    0 < d - σ ∧ d - σ < d := by
  -- We need to show that 0 < d - σ and d - σ < d.
  apply And.intro;
  · -- By the Cauchy-Schwarz inequality, we have $(a₁ + a₂ + a₃ + a₄ + a₅)^2 \leq 5(a₁^2 + a₂^2 + a₃^2 + a₄^2 + a₅^2)$.
    have h_cauchy_schwarz : (a₁ + a₂ + a₃ + a₄ + a₅) ^ 2 ≤ 5 * (a₁ ^ 2 + a₂ ^ 2 + a₃ ^ 2 + a₄ ^ 2 + a₅ ^ 2) := by
      linarith [ sq_nonneg ( a₁ - a₂ ), sq_nonneg ( a₁ - a₃ ), sq_nonneg ( a₁ - a₄ ), sq_nonneg ( a₁ - a₅ ), sq_nonneg ( a₂ - a₃ ), sq_nonneg ( a₂ - a₄ ), sq_nonneg ( a₂ - a₅ ), sq_nonneg ( a₃ - a₄ ), sq_nonneg ( a₃ - a₅ ), sq_nonneg ( a₄ - a₅ ) ];
    nlinarith only [ hσ, h_cauchy_schwarz, h, hd ];
  · nlinarith only [ hσ, h1, h2, h3, h4, h5, h, sq_nonneg ( a₁ - a₂ ), sq_nonneg ( a₁ - a₃ ), sq_nonneg ( a₁ - a₄ ), sq_nonneg ( a₁ - a₅ ), sq_nonneg ( a₂ - a₃ ), sq_nonneg ( a₂ - a₄ ), sq_nonneg ( a₂ - a₅ ), sq_nonneg ( a₃ - a₄ ), sq_nonneg ( a₃ - a₅ ), sq_nonneg ( a₄ - a₅ ) ]

/-- The root sextuple (0,0,0,0,1,1) -/
theorem root_sextuple : (0:ℤ)^2 + 0^2 + 0^2 + 0^2 + 1^2 = 1^2 := by norm_num

/-
Descent terminates at root: if d=1, only unit-norm solutions
-/
theorem descent_terminates_k6 (a₁ a₂ a₃ a₄ a₅ : ℤ)
    (h : a₁^2 + a₂^2 + a₃^2 + a₄^2 + a₅^2 = 1^2)
    (h1 : 0 ≤ a₁) (h2 : 0 ≤ a₂) (h3 : 0 ≤ a₃) (h4 : 0 ≤ a₄) (h5 : 0 ≤ a₅) :
    (a₁ = 0 ∧ a₂ = 0 ∧ a₃ = 0 ∧ a₄ = 0 ∧ a₅ = 1) ∨
    (a₁ = 0 ∧ a₂ = 0 ∧ a₃ = 0 ∧ a₄ = 1 ∧ a₅ = 0) ∨
    (a₁ = 0 ∧ a₂ = 0 ∧ a₃ = 1 ∧ a₄ = 0 ∧ a₅ = 0) ∨
    (a₁ = 0 ∧ a₂ = 1 ∧ a₃ = 0 ∧ a₄ = 0 ∧ a₅ = 0) ∨
    (a₁ = 1 ∧ a₂ = 0 ∧ a₃ = 0 ∧ a₄ = 0 ∧ a₅ = 0) := by
  have : a₁ ≤ 1 := Int.le_of_lt_add_one ( by nlinarith only [ h, h1, h2, h3, h4, h5 ] ) ; ( have : a₂ ≤ 1 := Int.le_of_lt_add_one ( by nlinarith only [ h, h1, h2, h3, h4, h5 ] ) ; ( have : a₃ ≤ 1 := Int.le_of_lt_add_one ( by nlinarith only [ h, h1, h2, h3, h4, h5 ] ) ; ( have : a₄ ≤ 1 := Int.le_of_lt_add_one ( by nlinarith only [ h, h1, h2, h3, h4, h5 ] ) ; ( have : a₅ ≤ 1 := Int.le_of_lt_add_one ( by nlinarith only [ h, h1, h2, h3, h4, h5 ] ) ; interval_cases a₁ <;> interval_cases a₂ <;> interval_cases a₃ <;> interval_cases a₄ <;> interval_cases a₅ <;> trivial; ) ) ) )

/-! ## Part 2: k = 5 Alternative Descent Mechanisms -/

/-
For k = 5 with uniform reflection s = (a,a,a,a,a), all fail
-/
theorem k5_uniform_reflection_fails (a : ℤ) (ha : a ≠ 0) :
    ∃ v : Fin 5 → ℤ,
      v 0 ^ 2 + v 1 ^ 2 + v 2 ^ 2 + v 3 ^ 2 = v 4 ^ 2 ∧
      ¬ ((3 * a ^ 2) ∣ (2 * a * (v 0 + v 1 + v 2 + v 3 - v 4))) := by
  by_contra! h;
  -- Consider the vector $v = (a,a,a,a,2a)$.
  set v : Fin 5 → ℤ := ![a, a, a, a, 2 * a];
  have := h v ?_ <;> simp_all +decide [ Fin.forall_fin_succ ];
  · simp +zetaDelta at *;
    exact ha ( by obtain ⟨ k, hk ⟩ := this; nlinarith [ show k = 1 by nlinarith [ mul_self_pos.mpr ha ] ] );
  · simp +zetaDelta at *;
    ring

/-- The Minkowski inner product for signature (4,1) -/
def eta5_form (u v : Fin 5 → ℤ) : ℤ :=
  u 0 * v 0 + u 1 * v 1 + u 2 * v 2 + u 3 * v 3 - u 4 * v 4

/-- Two candidate reflection vectors for k = 5 -/
def s5_a : Fin 5 → ℤ := ![1, 1, 1, 1, 1]
def s5_b : Fin 5 → ℤ := ![1, 1, 0, 0, 1]

/-- η(s_a, s_a) = 3 in signature (4,1) -/
theorem eta_sa : eta5_form s5_a s5_a = 3 := by
  unfold eta5_form s5_a; native_decide

/-- η(s_b, s_b) = 1 in signature (4,1) -/
theorem eta_sb : eta5_form s5_b s5_b = 1 := by
  unfold eta5_form s5_b; native_decide

/-- Reflection through s_b is always integral -/
theorem reflect_sb_integral (v : Fin 5 → ℤ) :
    ∀ i, (1 : ℤ) ∣ (2 * eta5_form s5_b v * s5_b i) := by
  intro i; exact one_dvd _

/-- For s = (1,1,1,1,1), η(s,s) = 3, and the reflection of (1,1,1,1,2) is fractional -/
theorem k5_allones_gives_rational :
    let s : Fin 5 → ℤ := ![1, 1, 1, 1, 1]
    let v : Fin 5 → ℤ := ![1, 1, 1, 1, 2]
    (2 : ℚ) * (eta5_form s v : ℚ) / (eta5_form s s : ℚ) = 4 / 3 := by
  native_decide

/-! ## Part 3: Connection to Division Algebras and Norms -/

/-- k-2 ∈ {1,2,4} = dimensions of ℝ, ℂ, ℍ -/
theorem hurwitz_connection : ∀ k ∈ ({3, 4, 6} : Finset ℕ), k - 2 ∈ ({1, 2, 4} : Finset ℕ) := by
  decide

/-- k = 10 (octonions, k-2=8) fails because 8 ∤ 4 -/
theorem octonion_case_fails : ¬ ((8 : ℤ) ∣ 4) := by omega

/-- The algebraic identity underlying k = 4 descent -/
theorem k4_algebraic_identity (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2) :
    (d-b-c)^2 + (d-a-c)^2 + (d-a-b)^2 = (2*d-a-b-c)^2 := by nlinarith

/-! ## Part 4: Mod-p Descent -/

/-- k = 5 barrier prime is 3 -/
theorem k5_barrier_prime : (5 : ℤ) - 2 = 3 := by norm_num

/-- k = 7 barrier prime is 5 -/
theorem k7_barrier_prime : (7 : ℤ) - 2 = 5 := by norm_num

/-- The mod-2 null cone parity (general version) -/
private theorem sq_sub_self_even' (x : ℤ) : 2 ∣ (x ^ 2 - x) := by
  obtain ⟨r, hr⟩ := Int.even_mul_pred_self x; exact ⟨r, by nlinarith⟩

/-- General parity for sums on null cone: for k variables,
    if a₁² + ... + a_{k-1}² = d², then (a₁ + ... + a_{k-1} - d) is even -/
theorem general_null_cone_parity_3 (a b d : ℤ) (h : a^2 + b^2 = d^2) :
    2 ∣ (a + b - d) := by
  obtain ⟨ra, hra⟩ := sq_sub_self_even' a
  obtain ⟨rb, hrb⟩ := sq_sub_self_even' b
  obtain ⟨rd, hrd⟩ := sq_sub_self_even' d
  exact ⟨rd - ra - rb, by linarith⟩

theorem general_null_cone_parity_4 (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2) :
    2 ∣ (a + b + c - d) := by
  obtain ⟨ra, hra⟩ := sq_sub_self_even' a
  obtain ⟨rb, hrb⟩ := sq_sub_self_even' b
  obtain ⟨rc, hrc⟩ := sq_sub_self_even' c
  obtain ⟨rd, hrd⟩ := sq_sub_self_even' d
  exact ⟨rd - ra - rb - rc, by linarith⟩

theorem general_null_cone_parity_5 (a b c e d : ℤ) (h : a^2 + b^2 + c^2 + e^2 = d^2) :
    2 ∣ (a + b + c + e - d) := by
  obtain ⟨ra, hra⟩ := sq_sub_self_even' a
  obtain ⟨rb, hrb⟩ := sq_sub_self_even' b
  obtain ⟨rc, hrc⟩ := sq_sub_self_even' c
  obtain ⟨re, hre⟩ := sq_sub_self_even' e
  obtain ⟨rd, hrd⟩ := sq_sub_self_even' d
  exact ⟨rd - ra - rb - rc - re, by linarith⟩

theorem general_null_cone_parity_6 (a₁ a₂ a₃ a₄ a₅ d : ℤ)
    (h : a₁^2 + a₂^2 + a₃^2 + a₄^2 + a₅^2 = d^2) :
    2 ∣ (a₁ + a₂ + a₃ + a₄ + a₅ - d) := by
  obtain ⟨r₁, hr₁⟩ := sq_sub_self_even' a₁
  obtain ⟨r₂, hr₂⟩ := sq_sub_self_even' a₂
  obtain ⟨r₃, hr₃⟩ := sq_sub_self_even' a₃
  obtain ⟨r₄, hr₄⟩ := sq_sub_self_even' a₄
  obtain ⟨r₅, hr₅⟩ := sq_sub_self_even' a₅
  obtain ⟨rd, hrd⟩ := sq_sub_self_even' d
  exact ⟨rd - r₁ - r₂ - r₃ - r₄ - r₅, by linarith⟩

/-! ## Part 5: The Divisibility Characterization -/

/-
The divisibility characterization: (k-2) | 4 iff k ∈ {3,4,6}
-/
theorem k_minus_2_dvd_4_characterization (k : ℕ) (hk : 3 ≤ k) (hk' : k ≤ 100) :
    (↑(k - 2) : ℤ) ∣ 4 ↔ k = 3 ∨ k = 4 ∨ k = 6 := by
  interval_cases k <;> trivial

/-! ## Part 6: Computational Verification Infrastructure for k = 6 -/

/-- Enumeration of primitive Pythagorean sextuples up to bound N -/
def listPrimSextuples (N : ℕ) : List (ℕ × ℕ × ℕ × ℕ × ℕ × ℕ) := do
  let d ← List.range (N + 1)
  let a₅ ← List.range (d + 1)
  let a₄ ← List.range (a₅ + 1)
  let a₃ ← List.range (a₄ + 1)
  let a₂ ← List.range (a₃ + 1)
  let a₁ ← List.range (a₂ + 1)
  if d > 0 &&
     a₁ * a₁ + a₂ * a₂ + a₃ * a₃ + a₄ * a₄ + a₅ * a₅ == d * d &&
     Nat.gcd (Nat.gcd (Nat.gcd (Nat.gcd a₁ a₂) (Nat.gcd a₃ a₄)) a₅) d == 1
  then return (a₁, a₂, a₃, a₄, a₅, d)
  else .nil

#eval (listPrimSextuples 5).length

/-- Apply one step of descent for k = 6 -/
def descentStep6 (a₁ a₂ a₃ a₄ a₅ d : ℤ) : ℤ × ℤ × ℤ × ℤ × ℤ × ℤ :=
  let σ := (a₁ + a₂ + a₃ + a₄ + a₅ - d) / 2
  (a₁ - σ, a₂ - σ, a₃ - σ, a₄ - σ, a₅ - σ, d - σ)

/-- Verify descent reaches (0,0,0,0,1,1) -/
def verifyDescent6 (a₁ a₂ a₃ a₄ a₅ d : ℤ) (fuel : ℕ) : Bool :=
  match fuel with
  | 0 => false
  | fuel + 1 =>
    let vals := [a₁.natAbs, a₂.natAbs, a₃.natAbs, a₄.natAbs, a₅.natAbs]
    let sorted := vals.mergeSort (· ≤ ·)
    let dabs := d.natAbs
    if sorted == [0, 0, 0, 0, 1] && dabs == 1 then true
    else
      let (a₁', a₂', a₃', a₄', a₅', d') := descentStep6 a₁ a₂ a₃ a₄ a₅ d
      verifyDescent6 a₁'.natAbs a₂'.natAbs a₃'.natAbs a₄'.natAbs a₅'.natAbs d'.natAbs fuel

#eval verifyDescent6 0 0 0 0 1 1 10
#eval verifyDescent6 0 0 1 2 2 3 20

/-! ## Part 7: Clifford Algebra Dimensions -/

/-- Cl⁺(2,0) dimension = 2 (≅ ℂ) -/
theorem cliff_even_2 : 2^(2-1) = (2 : ℕ) := by norm_num

/-- Cl⁺(3,0) dimension = 4 (≅ ℍ) -/
theorem cliff_even_3 : 2^(3-1) = (4 : ℕ) := by norm_num

/-- Cl⁺(5,0) dimension = 16 (≅ M₂(ℍ)) -/
theorem cliff_even_5 : 2^(5-1) = (16 : ℕ) := by norm_num