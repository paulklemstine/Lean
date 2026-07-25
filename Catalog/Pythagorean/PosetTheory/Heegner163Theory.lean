import Mathlib

/-!
# Deep Theory of 163: Heegner Numbers, Euler's Polynomial, and Lattice Geometry

This module develops the formal theory connecting the number 163 — the largest
Heegner number — to Euler's prime-generating polynomial, discriminant lattices,
and coding theory.

## Main Results

* `eulerPoly_strictMono` — Euler's polynomial is strictly monotone increasing
* `eulerPoly_factor_divides_41` — Key divisibility lemma via factored form
* `discriminantLattice_pos_def` — Positive definiteness by completing the square
* `DiscriminantLattice` — Novel structure: lattices from class number 1 discriminants
* `heegnerLattice163_fourDet` — The Gram matrix 4-determinant equals 163
* `eulerPoly_no_root_zmod` — Non-residue characterization via ZMod
* `eulerPoly_not_div_prime` — Lifting from finite fields to ℕ
* `fortyone_euler_lucky` — 41 is an Euler lucky prime
-/

open Finset Nat Int

namespace Heegner163

/-! ## Part I: Euler's Polynomial -/

/-- Euler's prime-generating polynomial: f(n) = n² + n + 41 -/
def eulerPoly (n : ℕ) : ℕ := n ^ 2 + n + 41

/-- Euler's polynomial over the integers -/
def eulerPolyZ (n : ℤ) : ℤ := n ^ 2 + n + 41

/-- The Heegner quadratic form: Q(x,y) = x² + xy + 41y² -/
def heegnerForm (x y : ℤ) : ℤ := x ^ 2 + x * y + 41 * y ^ 2

/-- Euler's polynomial is strictly monotone increasing. -/
theorem eulerPoly_strictMono : StrictMono eulerPoly := by
  intro a b hab; unfold eulerPoly; nlinarith

/-- Euler's polynomial is always at least 41. -/
theorem eulerPoly_ge_41 (n : ℕ) : 41 ≤ eulerPoly n := by
  unfold eulerPoly; omega

/-- f(n) = n(n+1) + 41. -/
theorem eulerPoly_factored (n : ℕ) : eulerPoly n = n * (n + 1) + 41 := by
  unfold eulerPoly; ring

/-- If d divides both f(n) and (n+1), then d divides 41.
    Uses the factored form and multi-step dvd reasoning. -/
theorem eulerPoly_factor_divides_41 (n d : ℕ) (hd : d ∣ eulerPoly n)
    (hn : d ∣ (n + 1)) : d ∣ 41 := by
  rw [eulerPoly_factored] at hd
  have h1 : d ∣ n * (n + 1) := dvd_mul_of_dvd_right hn n
  exact (Nat.dvd_add_right h1).mp hd

/-- If d divides both f(n) and n, then d divides 41. -/
theorem eulerPoly_factor_divides_41' (n d : ℕ) (hd : d ∣ eulerPoly n)
    (hn : d ∣ n) : d ∣ 41 := by
  have h1 : d ∣ n ^ 2 := dvd_pow hn (by norm_num : 2 ≠ 0)
  have h2 : d ∣ n ^ 2 + n := Dvd.dvd.add h1 hn
  unfold eulerPoly at hd
  exact (Nat.dvd_add_right h2).mp hd

/-- Euler's polynomial is never divisible by 2. Proof by parity:
    n(n+1) is always even, so n²+n+41 = n(n+1)+41 is always odd. -/
theorem eulerPoly_not_div_2 (n : ℕ) : ¬ 2 ∣ eulerPoly n := by
  unfold eulerPoly
  have h_even : Even (n * (n + 1)) := n.even_mul_succ_self
  rw [show n ^ 2 + n + 41 = n * (n + 1) + 41 from by ring]
  obtain ⟨m, hm⟩ := h_even
  intro ⟨k, hk⟩
  omega

/-- For n < 40, Euler's polynomial is bounded by 41². -/
theorem eulerPoly_lt_sq41 (n : ℕ) (hn : n < 40) : eulerPoly n < 41 * 41 := by
  unfold eulerPoly; nlinarith

theorem eulerPoly_at_0 : eulerPoly 0 = 41 := by unfold eulerPoly; ring
theorem eulerPoly_at_1 : eulerPoly 1 = 43 := by unfold eulerPoly; ring
theorem eulerPoly_at_39 : eulerPoly 39 = 1601 := by unfold eulerPoly; ring

theorem prime_1601 : Nat.Prime 1601 := by norm_num

/-! ## Part II: The Discriminant Lattice — Novel Structure -/

/-- A **DiscriminantLattice** encodes a rank-2 lattice from a binary
    quadratic form ax² + bxy + cy² with negative discriminant b²-4ac < 0.

    This bridges:
    - **Number theory**: class number 1 ⟺ unique reduced form
    - **Coding theory**: unique densest lattice packing for given discriminant
    - **Geometry**: positive definite quadratic form ⟺ ellipsoid -/
structure DiscriminantLattice where
  a : ℕ
  b : ℤ
  c : ℕ
  neg_disc : b ^ 2 < 4 * (a : ℤ) * c
  a_pos : 0 < a

def DiscriminantLattice.disc (L : DiscriminantLattice) : ℤ :=
  L.b ^ 2 - 4 * (L.a : ℤ) * L.c

def DiscriminantLattice.fourDet (L : DiscriminantLattice) : ℤ :=
  4 * (L.a : ℤ) * L.c - L.b ^ 2

def DiscriminantLattice.form (L : DiscriminantLattice) (x y : ℤ) : ℤ :=
  (L.a : ℤ) * x ^ 2 + L.b * x * y + (L.c : ℤ) * y ^ 2

noncomputable def heegnerLattice163 : DiscriminantLattice where
  a := 1; b := 1; c := 41
  neg_disc := by norm_num
  a_pos := by norm_num

theorem heegnerLattice163_disc : heegnerLattice163.disc = -163 := by
  unfold DiscriminantLattice.disc heegnerLattice163; norm_num

theorem heegnerLattice163_fourDet : heegnerLattice163.fourDet = 163 := by
  unfold DiscriminantLattice.fourDet heegnerLattice163; norm_num

theorem heegnerLattice163_form_eq (x y : ℤ) :
    heegnerLattice163.form x y = heegnerForm x y := by
  unfold DiscriminantLattice.form heegnerLattice163 heegnerForm; ring

/-! ## Part III: Positive Definiteness (Deep Theorem) -/

/-
Every discriminant lattice has a positive definite quadratic form.
    Proof by completing the square and case split on y.
-/
theorem discriminantLattice_pos_def (L : DiscriminantLattice) (x y : ℤ)
    (hxy : (x, y) ≠ (0, 0)) : 0 < L.form x y := by
  by_cases hy : y = 0;
  · simp_all +decide [ DiscriminantLattice.form ];
    exact mul_pos ( Nat.cast_pos.mpr L.a_pos ) ( sq_pos_of_ne_zero hxy );
  · unfold DiscriminantLattice.form; nlinarith [ sq_nonneg ( L.a * x * 2 + L.b * y ), L.neg_disc, L.a_pos, mul_self_pos.mpr hy ] ;

/-- 4·Q(x,y) = (2x + y)² + 163·y² -/
theorem heegnerForm_complete_square (x y : ℤ) :
    4 * heegnerForm x y = (2 * x + y) ^ 2 + 163 * y ^ 2 := by
  unfold heegnerForm; ring

/-- The Heegner form is positive definite. -/
theorem heegnerForm_pos_def (x y : ℤ) (hxy : (x, y) ≠ (0, 0)) :
    0 < heegnerForm x y := by
  rw [← heegnerLattice163_form_eq]
  exact discriminantLattice_pos_def heegnerLattice163 x y hxy

/-! ## Part IV: ZMod Non-Residue Theorem -/

/-- x² + x + 41 has no roots in ℤ/pℤ for any prime p ≤ 40. -/
theorem eulerPoly_no_root_zmod (p : ℕ) (hp : Nat.Prime p) (hle : p ≤ 40) :
    ∀ n : ZMod p, n ^ 2 + n + 41 ≠ 0 := by
  have hmem : p ∈ Finset.filter Nat.Prime (Finset.range 41) :=
    Finset.mem_filter.mpr ⟨Finset.mem_range.mpr (by omega), hp⟩
  fin_cases hmem <;> decide

/-
Lifting: if x²+x+41 has no root mod p, then p ∤ eulerPoly(n) for any n.
-/
theorem eulerPoly_not_div_prime (p : ℕ) (hp : Nat.Prime p) (hle : p ≤ 40)
    (n : ℕ) : ¬ p ∣ eulerPoly n := by
  convert eulerPoly_no_root_zmod p hp hle n using 1;
  erw [ ← ZMod.natCast_eq_zero_iff ] ; simp +decide [ eulerPoly ] ;

/-! ## Part V: Quadratic Form Specializations -/

/-- Q(n,1) = eulerPolyZ(n). Bridges quadratic forms and prime generation. -/
theorem heegnerForm_specializes (n : ℤ) :
    heegnerForm n 1 = eulerPolyZ n := by
  simp [heegnerForm, eulerPolyZ]

theorem heegnerForm_at_10 : heegnerForm 1 0 = 1 := by unfold heegnerForm; norm_num
theorem heegnerForm_at_01 : heegnerForm 0 1 = 41 := by unfold heegnerForm; norm_num
theorem heegnerForm_at_11 : heegnerForm 1 1 = 43 := by unfold heegnerForm; norm_num
theorem heegnerForm_at_neg11 : heegnerForm (-1) 1 = 41 := by unfold heegnerForm; norm_num

/-! ## Part VI: Heegner Number Properties -/

def heegnerSet : Finset ℕ := {1, 2, 3, 7, 11, 19, 43, 67, 163}

theorem heegner_163_prime : Nat.Prime 163 := by norm_num

/-- Every Heegner number > 3 is prime. Uses fin_cases on finite membership. -/
theorem heegner_gt3_prime (d : ℕ) (hd : d ∈ heegnerSet) (h3 : 3 < d) :
    Nat.Prime d := by
  fin_cases hd <;> first | omega | norm_num

/-- 163 is the largest Heegner number. -/
theorem heegner_163_largest (d : ℕ) (hd : d ∈ heegnerSet) : d ≤ 163 := by
  fin_cases hd <;> omega

theorem euler_poly_discriminant : (1 : ℤ) - 4 * 41 = -163 := by ring

/-! ## Part VII: Heegner-to-Euler Connection -/

theorem heegner_163_to_euler : (163 + 1 : ℤ) / 4 = 41 := by norm_num
theorem heegner_67_to_euler : (67 + 1 : ℤ) / 4 = 17 := by norm_num
theorem heegner_43_to_euler : (43 + 1 : ℤ) / 4 = 11 := by norm_num

/-! ## Part VIII: Ramanujan Constant -/

/-- 640320³ + 744 = 262537412640768744 (nearest integer to e^(π√163)). -/
theorem ramanujan_constant_algebraic :
    (640320 : ℤ) ^ 3 + 744 = 262537412640768744 := by norm_num

theorem factor_640320 : 640320 = 2^6 * 3 * 5 * 23 * 29 := by norm_num

/-! ## Part IX: Euler Lucky Primes -/

/-- An Euler lucky prime: p prime and n²+n+p prime for 0 ≤ n ≤ p-2. -/
structure IsEulerLuckyPrime (p : ℕ) : Prop where
  prime : Nat.Prime p
  generates_primes : ∀ n : ℕ, n + 2 ≤ p → Nat.Prime (n ^ 2 + n + p)

theorem two_euler_lucky : IsEulerLuckyPrime 2 :=
  ⟨by norm_num, fun n hn => by
    have h0 : n = 0 := by omega
    subst h0; norm_num⟩

theorem three_euler_lucky : IsEulerLuckyPrime 3 :=
  ⟨by norm_num, fun n hn => by
    have h1 : n ≤ 1 := by omega
    interval_cases n <;> norm_num⟩

theorem five_euler_lucky : IsEulerLuckyPrime 5 :=
  ⟨by norm_num, fun n hn => by
    have h3 : n ≤ 3 := by omega
    interval_cases n <;> norm_num⟩

theorem eleven_euler_lucky : IsEulerLuckyPrime 11 :=
  ⟨by norm_num, fun n hn => by
    have h9 : n ≤ 9 := by omega
    interval_cases n <;> norm_num⟩

/-- 17 is an Euler lucky prime (from Heegner number 67). -/
theorem seventeen_euler_lucky : IsEulerLuckyPrime 17 :=
  ⟨by norm_num, fun n hn => by
    have h15 : n ≤ 15 := by omega
    interval_cases n <;> norm_num⟩

/-- 41 is an Euler lucky prime: the deepest instance, from d = 163. -/
theorem fortyone_euler_lucky : IsEulerLuckyPrime 41 :=
  ⟨by norm_num, fun n hn => by
    have h39 : n ≤ 39 := by omega
    interval_cases n <;> norm_num⟩

/-! ## Part X: Non-Euler-Lucky Primes -/

/-- 7 is NOT an Euler lucky prime: 4²+4+7 = 27 = 3³ is composite. -/
theorem seven_not_euler_lucky : ¬ IsEulerLuckyPrime 7 := by
  intro ⟨_, hgen⟩
  have h := hgen 4 (by norm_num)
  revert h; decide

/-- 13 is NOT an Euler lucky prime: 10²+10+13 = 123 = 3·41. -/
theorem thirteen_not_euler_lucky : ¬ IsEulerLuckyPrime 13 := by
  intro ⟨_, hgen⟩
  have h := hgen 10 (by norm_num)
  revert h; decide

/-! ## Part XI: Falsifiable Conjecture

**Conjecture (Cross-Heegner Coprimality)**: For the Euler polynomials from
d₁ = 43 (p₁ = 11) and d₂ = 163 (p₂ = 41), the values
f₁(n) = n²+n+11 and f₂(m) = m²+m+41 are coprime for all
n ∈ {0,...,9}, m ∈ {0,...,39}.

**Test**: Compute gcd(n²+n+11, m²+m+41) for all n,m in range.
The difference f₂(m) - f₁(m) = 30, and neither polynomial is ever
divisible by 2, 3, or 5, so common factors for equal arguments are impossible. -/

theorem euler_poly_diff_30 (n : ℕ) :
    (n ^ 2 + n + 41) - (n ^ 2 + n + 11) = 30 := by omega

end Heegner163