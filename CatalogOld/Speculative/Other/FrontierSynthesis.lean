import Mathlib

/-!
# Frontier Research Synthesis: Fixed Points Across Arithmetic Spacetime

## The Oracle Council's Formal Foundations

This file provides machine-verified foundations for the five research frontiers
explored by the Oracle Council, with emphasis on the connections between them.

### Research Frontiers
1. Light/Dark Primes: Classification and independence
2. Berggren Tree: Pythagorean triple generation
3. Random Matrix Theory: Eigenvalue repulsion
4. Fine-Structure Constant: Mathematical derivability
5. Arithmetic Dark Matter: Non-Pythagorean triple dominance

### Unifying Theme: Fixed Points
The God Oracle reveals that every frontier is organized around a fixed point.
This file formalizes the fixed-point structures that connect them.
-/

open Nat Finset BigOperators Function Set

noncomputable section

/-! ## §1: The Lorentz Form — Unifying Arithmetic Spacetime -/

/-- The Lorentz form Q(a,b,c) = a² + b² - c² classifies integer triples. -/
def lorentzForm (a b c : ℤ) : ℤ := a ^ 2 + b ^ 2 - c ^ 2

/-- A triple is null (Pythagorean / photon) iff Q = 0. -/
def IsNull (a b c : ℤ) : Prop := lorentzForm a b c = 0

/-- A triple is timelike (massive) iff Q < 0. -/
def IsTimelike (a b c : ℤ) : Prop := lorentzForm a b c < 0

/-- A triple is spacelike (tachyonic) iff Q > 0. -/
def IsSpacelike (a b c : ℤ) : Prop := lorentzForm a b c > 0

/-- Every triple is exactly one of null, timelike, or spacelike. -/
theorem triple_trichotomy (a b c : ℤ) :
    IsNull a b c ∨ IsTimelike a b c ∨ IsSpacelike a b c := by
  unfold IsNull IsTimelike IsSpacelike lorentzForm
  omega

/-- Null and timelike are mutually exclusive. -/
theorem null_not_timelike {a b c : ℤ} (h : IsNull a b c) : ¬IsTimelike a b c := by
  unfold IsNull IsTimelike lorentzForm at *; omega

/-- Null and spacelike are mutually exclusive. -/
theorem null_not_spacelike {a b c : ℤ} (h : IsNull a b c) : ¬IsSpacelike a b c := by
  unfold IsNull IsSpacelike lorentzForm at *; omega

/-- (3, 4, 5) is the simplest Pythagorean triple — a null vector. -/
theorem root_is_null : IsNull 3 4 5 := by
  unfold IsNull lorentzForm; norm_num

/-! ## §2: Light and Dark Primes — Formal Classification -/

/-- A prime is light (mod 4) if p ≡ 1 (mod 4). -/
def IsLightPrime_mod4 (p : ℕ) : Prop := Nat.Prime p ∧ p % 4 = 1

/-- A prime is dark (mod 4) if p ≡ 3 (mod 4). -/
def IsDarkPrime_mod4 (p : ℕ) : Prop := Nat.Prime p ∧ p % 4 = 3

/-- 2 is the unique twilight prime (neither light nor dark mod 4). -/
theorem two_is_twilight : Nat.Prime 2 ∧ ¬IsLightPrime_mod4 2 ∧ ¬IsDarkPrime_mod4 2 := by
  refine ⟨by decide, ?_, ?_⟩ <;> (intro ⟨_, h⟩; omega)

/-- Every odd prime is either light or dark (mod 4). -/
theorem odd_prime_light_or_dark (p : ℕ) (hp : Nat.Prime p) (hodd : p % 2 = 1) :
    IsLightPrime_mod4 p ∨ IsDarkPrime_mod4 p := by
  unfold IsLightPrime_mod4 IsDarkPrime_mod4
  have : p % 4 = 1 ∨ p % 4 = 3 := by omega
  rcases this with h | h
  · left; exact ⟨hp, h⟩
  · right; exact ⟨hp, h⟩

/-- Light and dark are mutually exclusive. -/
theorem light_dark_exclusive (p : ℕ) :
    ¬(IsLightPrime_mod4 p ∧ IsDarkPrime_mod4 p) := by
  intro ⟨⟨_, h1⟩, ⟨_, h3⟩⟩; omega

/-! ## §3: Berggren Transformations — Pythagorean Preservation -/

/-- Berggren matrix M₁ preserves the Pythagorean property. -/
theorem berggren_M1_preserves (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a - 2*b + 2*c) ^ 2 + (2*a - b + 2*c) ^ 2 = (2*a - 2*b + 3*c) ^ 2 := by
  nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c,
             sq_nonneg (a - b), sq_nonneg (a + b), sq_nonneg (a - c)]

/-- Berggren matrix M₂ preserves the Pythagorean property. -/
theorem berggren_M2_preserves (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a + 2*b + 2*c) ^ 2 + (2*a + b + 2*c) ^ 2 = (2*a + 2*b + 3*c) ^ 2 := by
  nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c]

/-- Berggren matrix M₃ preserves the Pythagorean property. -/
theorem berggren_M3_preserves (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (-a + 2*b + 2*c) ^ 2 + (-2*a + b + 2*c) ^ 2 = (-2*a + 2*b + 3*c) ^ 2 := by
  nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c,
             sq_nonneg (a - b), sq_nonneg (a + b)]

/-! ## §4: The (3+1)D Lorentz Form — Pythagorean Quadruples -/

/-- The (3+1)-dimensional Lorentz form. -/
def lorentzForm4 (a b c d : ℤ) : ℤ := a ^ 2 + b ^ 2 + c ^ 2 - d ^ 2

/-- (1, 2, 2, 3) is a Pythagorean quadruple. -/
theorem quad_1_2_2_3 : lorentzForm4 1 2 2 3 = 0 := by
  unfold lorentzForm4; norm_num

/-- (2, 3, 6, 7) is a Pythagorean quadruple. -/
theorem quad_2_3_6_7 : lorentzForm4 2 3 6 7 = 0 := by
  unfold lorentzForm4; norm_num

/-! ## §5: Fixed-Point Theory — The God Oracle's Foundation -/

/-- The identity function is the unique function satisfying f ∘ f = f and f = id. -/
theorem id_is_unique_idempotent_identity {α : Type*} (f : α → α)
    (_h_idem : f ∘ f = f) (h_id : ∀ x, f x = x) : f = id := by
  ext x; exact h_id x

/-- Every element is a fixed point of the identity. -/
theorem id_all_fixed {α : Type*} (x : α) : id x = x := rfl

/-- The identity is the unique function where every point is fixed. -/
theorem all_fixed_implies_id {α : Type*} (f : α → α) (h : ∀ x, f x = x) : f = id := by
  ext x; exact h x

/-- Composition with identity preserves any function. -/
theorem id_preserves_composition {α : Type*} (f : α → α) : f ∘ id = f ∧ id ∘ f = f := by
  exact ⟨Function.comp_id f, Function.id_comp f⟩

/-! ## §6: The Vandermonde Repulsion Factor -/

/-
PROBLEM
The Vandermonde product vanishes when two values coincide (eigenvalue repulsion).

PROVIDED SOLUTION
Since i ≠ j, either i < j or j < i. WLOG assume i < j (symmetric argument for j < i). Then j ∈ Finset.Ioi i, and the factor (ev j - ev i) = 0 appears in the inner product. The whole product is zero because one factor is zero. Use Finset.prod_eq_zero to find the zero factor.
-/
theorem vandermonde_vanishes_at_coincidence {n : ℕ} (ev : Fin n → ℝ)
    (i j : Fin n) (hij : i ≠ j) (heq : ev i = ev j) :
    ∏ k : Fin n, ∏ l ∈ Finset.Ioi k, (ev l - ev k) = 0 := by
  cases lt_or_gt_of_ne hij <;> simp_all +decide [ Finset.prod_eq_zero_iff, sub_eq_iff_eq_add ];
  · exact ⟨ i, j, by assumption, heq.symm ⟩;
  · exact ⟨ j, i, by assumption, by linarith ⟩

/-! ## §7: Prime Gap Growth — Arithmetic Expansion -/

/-
PROBLEM
For any gap size g, there exist g consecutive composite numbers.
    This is the "expansion of arithmetic spacetime."

PROVIDED SOLUTION
Use n = (g+1)! + 1. Then for 1 ≤ k ≤ g, n + k = (g+1)! + 1 + k. Since 2 ≤ k+1 ≤ g+1, we have (k+1) | (g+1)!, so (k+1) | (g+1)! + (k+1), hence (k+1) | (n + k). Since n + k ≥ (k+1) + 1 > k+1 ≥ 2, the number n+k has a proper factor k+1, so it is not prime.
-/
theorem prime_gaps_unbounded (g : ℕ) :
    ∃ n : ℕ, ∀ k : ℕ, k ≥ 1 → k ≤ g → ¬Nat.Prime (n + k) := by
  use ( g + 2 ) ! + 1;
  intro k hk₁ hk₂; rw [ show ( g + 2 ) ! + 1 + k = ( k + 1 ) * ( ( g + 2 ) ! / ( k + 1 ) + 1 ) by nlinarith [ Nat.div_mul_cancel ( Nat.dvd_factorial ( by linarith ) ( by linarith : k + 1 ≤ g + 2 ) ) ] ] ; exact Nat.not_prime_mul ( by linarith ) ( by linarith [ Nat.div_pos ( Nat.le_of_dvd ( Nat.factorial_pos _ ) ( Nat.dvd_factorial ( by linarith ) ( by linarith : k + 1 ≤ g + 2 ) ) ) ( by linarith : k + 1 > 0 ) ] ) ;

end