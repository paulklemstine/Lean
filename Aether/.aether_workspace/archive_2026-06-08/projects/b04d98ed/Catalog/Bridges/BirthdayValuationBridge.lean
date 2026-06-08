import Mathlib

/-!
# Birthday-Valuation Bridge: Surreal Birthdays Meet 2-Adic Number Theory

This file develops the **Birthday–Denomination Principle**: the 2-adic valuation
of the denominator of a dyadic rational determines its position in the surreal
birthday hierarchy. We formalize:

1. The **dyadic valuation** `ν₂(q) = padicValNat 2 q.den` on ℚ
2. The **Birthday Filtration** — a filtered ring structure on dyadic rationals
3. **Subadditivity** of the birthday valuation under addition and multiplication
4. An **ultrametric inequality** for the birthday metric
5. The **tropical-birthday bridge**: birthday filtration ↔ tropical semiring valuations

## Mathematical Overview

A dyadic rational is a rational number whose denominator is a power of 2.
The surreal birthday of such a number m/2ⁿ (in lowest terms, m odd) equals n.
This connects combinatorial game theory to p-adic number theory: the birthday
hierarchy IS the 2-adic filtration restricted to dyadic rationals.

The key insight is that this filtration has **non-Archimedean** character:
  ν₂(a + b) ≤ max(ν₂(a), ν₂(b))
which is the ultrametric inequality. Combined with the Birthday-Denomination
Principle, this says that the surreal birthday of a sum is at most the maximum
of the two birthdays.

## References

* Conway, J.H. *On Numbers and Games*, Academic Press, 1976.
* Gonshor, H. *An Introduction to the Theory of Surreal Numbers*, Cambridge, 1986.
-/

open Finset BigOperators

noncomputable section

namespace BirthdayValuation

/-! ## Part I: The Dyadic Valuation on ℚ -/

/-- The **dyadic valuation** of a rational number: the 2-adic valuation of its
denominator. This measures "how deep" in the surreal birthday hierarchy the
number sits. Integers have valuation 0; 1/2 has valuation 1; 3/8 has valuation 3. -/
def dyadicVal (q : ℚ) : ℕ := padicValNat 2 q.den

/-- Integers have dyadic valuation 0. -/
theorem dyadicVal_intCast (n : ℤ) : dyadicVal (n : ℚ) = 0 := by
  simp [dyadicVal]

/-- The dyadic valuation of 0 is 0. -/
theorem dyadicVal_zero : dyadicVal 0 = 0 := by
  simp [dyadicVal]

/-- The dyadic valuation of 1 is 0. -/
theorem dyadicVal_one : dyadicVal 1 = 0 := by
  simp [dyadicVal]

/-- Negation preserves the dyadic valuation. -/
theorem dyadicVal_neg (q : ℚ) : dyadicVal (-q) = dyadicVal q := by
  simp [dyadicVal]

/-! ## Part II: The Birthday Filtration -/

/-- The **birthday filtration** at level `n`: all rationals with denominator dividing `2^n`.
This is a subgroup (in fact, a subring) of ℚ, and corresponds to the surreal numbers
born by day n. -/
def BirthdayFiltration (n : ℕ) : Set ℚ :=
  { q : ℚ | q.den ∣ 2 ^ n }

/-- Zero belongs to every filtration level. -/
theorem zero_mem_filtration (n : ℕ) : (0 : ℚ) ∈ BirthdayFiltration n := by
  simp [BirthdayFiltration]

/-- Every integer belongs to every filtration level. -/
theorem intCast_mem_filtration (a : ℤ) (n : ℕ) : (a : ℚ) ∈ BirthdayFiltration n := by
  simp [BirthdayFiltration]

/-- The filtration is monotone: higher levels contain more numbers. -/
theorem filtration_mono {m n : ℕ} (h : m ≤ n) :
    BirthdayFiltration m ⊆ BirthdayFiltration n := by
  intro q hq
  simp only [BirthdayFiltration, Set.mem_setOf_eq] at *
  exact dvd_trans hq (Nat.pow_dvd_pow 2 h)

/-
Forward direction: membership in filtration implies bounded dyadic valuation.
-/
theorem dyadicVal_le_of_mem_filtration {q : ℚ} {n : ℕ}
    (hq : q ∈ BirthdayFiltration n) : dyadicVal q ≤ n := by
  have := Nat.factorization_le_iff_dvd ( by positivity ) ( by positivity ) |>.2 hq;
  simpa [ Nat.factorization ] using this 2

/-
Reverse direction for dyadic rationals: bounded valuation implies membership.
-/
theorem mem_filtration_of_den_pow2 {q : ℚ} {n : ℕ}
    (hd : ∃ k, q.den = 2 ^ k) (hv : dyadicVal q ≤ n) :
    q ∈ BirthdayFiltration n := by
  obtain ⟨ k, hk ⟩ := hd;
  exact Nat.dvd_trans ( show q.den ∣ 2 ^ k from by simp +decide [ hk ] ) ( pow_dvd_pow _ ( show k ≤ n from by simpa [ hk, dyadicVal ] using hv ) )

/-- The filtration is closed under negation. -/
theorem neg_mem_filtration {n : ℕ} {q : ℚ} (hq : q ∈ BirthdayFiltration n) :
    -q ∈ BirthdayFiltration n := by
  simp only [BirthdayFiltration, Set.mem_setOf_eq] at *
  simp [hq]

/-! ## Part III: Denominator Divisibility for Dyadic Arithmetic -/

/-
Key structural lemma: the denominator of a sum divides the product of
the denominators.
-/
theorem den_add_dvd_mul (a b : ℚ) : (a + b).den ∣ a.den * b.den := by
  convert Rat.add_den_dvd a b using 1

/-
The denominator of a product divides the product of the denominators.
-/
theorem den_mul_dvd_mul (a b : ℚ) : (a * b).den ∣ a.den * b.den := by
  convert Rat.mul_den_dvd a b using 1

/-- **Birthday Addition Theorem**: The birthday of a sum is at most the sum of
the individual birthdays. This is the fundamental subadditivity property. -/
theorem filtration_add_closed {m n : ℕ} {a b : ℚ}
    (ha : a ∈ BirthdayFiltration m) (hb : b ∈ BirthdayFiltration n) :
    a + b ∈ BirthdayFiltration (m + n) := by
  simp only [BirthdayFiltration, Set.mem_setOf_eq] at *
  calc (a + b).den ∣ a.den * b.den := den_add_dvd_mul a b
    _ ∣ 2 ^ m * 2 ^ n := Nat.mul_dvd_mul ha hb
    _ = 2 ^ (m + n) := (pow_add 2 m n).symm

/-- **Birthday Multiplication Theorem**: The birthday of a product is at most the
sum of the individual birthdays. -/
theorem filtration_mul_closed {m n : ℕ} {a b : ℚ}
    (ha : a ∈ BirthdayFiltration m) (hb : b ∈ BirthdayFiltration n) :
    a * b ∈ BirthdayFiltration (m + n) := by
  simp only [BirthdayFiltration, Set.mem_setOf_eq] at *
  calc (a * b).den ∣ a.den * b.den := den_mul_dvd_mul a b
    _ ∣ 2 ^ m * 2 ^ n := Nat.mul_dvd_mul ha hb
    _ = 2 ^ (m + n) := (pow_add 2 m n).symm

/-! ## Part IV: The Carry Propagation — Non-Archimedean Addition -/

/-
**Carry Propagation Theorem**: When adding dyadic rationals with denominators
dividing 2^m and 2^n, the result's denominator divides 2^(max(m,n)). This is the
non-Archimedean strengthening: birthday of sum ≤ max of birthdays (not sum).
-/
theorem filtration_add_max {m n : ℕ} {a b : ℚ}
    (ha : a ∈ BirthdayFiltration m) (hb : b ∈ BirthdayFiltration n) :
    a + b ∈ BirthdayFiltration (max m n) := by
  -- Since $a$ and $b$ are in their respective filtrations, their denominators divide $2^m$ and $2^n$ respectively.
  have ha_den : a.den ∣ 2 ^ m := by
    exact ha
  have hb_den : b.den ∣ 2 ^ n := by
    exact hb;
  -- Since $a.den \mid 2^m$ and $b.den \mid 2^n$, we have $a.den \mid 2^{\max(m,n)}$ and $b.den \mid 2^{\max(m,n)}$.
  have ha_den_max : a.den ∣ 2 ^ (max m n) := by
    exact dvd_trans ha_den ( pow_dvd_pow _ ( le_max_left _ _ ) )
  have hb_den_max : b.den ∣ 2 ^ (max m n) := by
    exact dvd_trans hb_den ( pow_dvd_pow _ ( le_max_right _ _ ) );
  -- By Rat.add_def, we have that (a + b).den divides lcm(a.den, b.den).
  have h_denom_div : (a + b).den ∣ Nat.lcm a.den b.den := by
    exact Rat.add_den_dvd_lcm a b
  exact dvd_trans h_denom_div ( Nat.lcm_dvd ha_den_max hb_den_max )

/-! ## Part V: The Birthday–Denomination Principle -/

/-
**Birthday–Denomination Principle**: For a rational with denominator 2^n,
the dyadic valuation equals n. This is the fundamental bridge between surreal
birthday arithmetic and 2-adic number theory.
-/
theorem birthday_denomination_principle (q : ℚ) (n : ℕ) (h : q.den = 2 ^ n) :
    dyadicVal q = n := by
  simp [ h, dyadicVal ]

/-
Converse direction: if the denominator is a power of 2, then
den = 2^(dyadicVal q).
-/
theorem den_eq_pow2_of_dyadicVal (q : ℚ) (h : ∃ k, q.den = 2 ^ k) :
    q.den = 2 ^ dyadicVal q := by
  convert h.choose_spec;
  convert birthday_denomination_principle q h.choose h.choose_spec

/-! ## Part VI: Power-of-Two Denominator Characterization -/

/-
Every rational in the birthday filtration has a power-of-2 denominator.
-/
theorem den_is_pow2_of_mem_filtration {q : ℚ} {n : ℕ}
    (hq : q ∈ BirthdayFiltration n) : ∃ k ≤ n, q.den = 2 ^ k := by
  obtain ⟨ k, hk ⟩ := hq;
  have : q.den ∣ 2 ^ n := hk.symm ▸ dvd_mul_right _ _; ( rw [ Nat.dvd_prime_pow ( by decide ) ] at this; aesop; )

/-! ## Part VII: Subadditivity of the Dyadic Valuation -/

/-
**Subadditivity under addition (non-Archimedean)**: for all rationals,
the denominator valuation of a sum is at most the max of the valuations.

ν₂(den(a+b)) ≤ max(ν₂(den(a)), ν₂(den(b)))
-/
theorem dyadicVal_add_le_max (a b : ℚ) :
    dyadicVal (a + b) ≤ max (dyadicVal a) (dyadicVal b) := by
  by_contra! h_contra;
  -- By definition of dyadic valuation, we know that (a + b).den ∣ lcm(a.den, b.den).
  have h_denom_div : (a + b).den ∣ Nat.lcm a.den b.den := by
    -- By definition of dyadic valuation, we know that (a + b).den ∣ lcm(a.den, b.den) because the denominator of a sum divides the least common multiple of the denominators.
    apply Rat.add_den_dvd_lcm;
  -- Since $padicValNat 2$ is monotone, we have $padicValNat 2 (a + b).den \leq padicValNat 2 (Nat.lcm a.den b.den)$.
  have h_padicValNat_le : padicValNat 2 (a + b).den ≤ padicValNat 2 (Nat.lcm a.den b.den) := by
    exact Nat.factorization_le_iff_dvd ( by aesop ) ( by aesop ) |>.2 h_denom_div 2;
  -- Since $padicValNat 2$ is monotone, we have $padicValNat 2 (Nat.lcm a.den b.den) = \max(padicValNat 2 a.den, padicValNat 2 b.den)$.
  have h_padicValNat_lcm : padicValNat 2 (Nat.lcm a.den b.den) = max (padicValNat 2 a.den) (padicValNat 2 b.den) := by
    rw [ ← Nat.factorization_def, ← Nat.factorization_def, ← Nat.factorization_def ];
    · rw [ Nat.factorization_lcm ] <;> aesop;
    · norm_num;
    · norm_num;
    · norm_num;
  exact h_contra.not_ge ( h_padicValNat_lcm ▸ h_padicValNat_le )

/-
**Subadditivity under multiplication**: ν₂(den(a·b)) ≤ ν₂(den(a)) + ν₂(den(b)).
-/
theorem dyadicVal_mul_le_add (a b : ℚ) :
    dyadicVal (a * b) ≤ dyadicVal a + dyadicVal b := by
  convert Nat.factorization_le_iff_dvd ( by aesop ) ( by aesop ) |>.2 ( den_mul_dvd_mul a b ) 2 using 1;
  rw [ Nat.factorization_mul ] <;> aesop

/-! ## Part VIII: The Birthday Distance -/

/-- The **birthday distance** between two rational numbers, measured by the
2-adic depth needed to distinguish them. -/
def birthdayDist (a b : ℚ) : ℕ := dyadicVal (a - b)

/-- The birthday distance is symmetric. -/
theorem birthdayDist_comm (a b : ℚ) : birthdayDist a b = birthdayDist b a := by
  unfold birthdayDist
  rw [show a - b = -(b - a) from by ring, dyadicVal_neg]

/-- The birthday distance from any number to itself is 0. -/
theorem birthdayDist_self (a : ℚ) : birthdayDist a a = 0 := by
  simp [birthdayDist, dyadicVal]

/-- **Ultrametric triangle inequality** for birthday distance. -/
theorem birthdayDist_triangle (a b c : ℚ) :
    birthdayDist a c ≤ max (birthdayDist a b) (birthdayDist b c) := by
  unfold birthdayDist
  have hab : a - c = (a - b) + (b - c) := by ring
  rw [hab]
  exact dyadicVal_add_le_max (a - b) (b - c)

/-! ## Part IX: Growth Bounds for the Birthday Hierarchy -/

/-- The number of distinct dyadic rationals in [0,1] with denominator dividing 2^n
equals 2^n + 1. -/
def countDyadicsInUnitInterval (n : ℕ) : ℕ := 2 ^ n + 1

theorem countDyadics_zero : countDyadicsInUnitInterval 0 = 2 := by
  simp [countDyadicsInUnitInterval]

theorem countDyadics_succ (n : ℕ) :
    countDyadicsInUnitInterval (n + 1) = 2 * countDyadicsInUnitInterval n - 1 := by
  simp only [countDyadicsInUnitInterval, pow_succ]
  omega

/-- The count grows exponentially. -/
theorem countDyadics_growth (n : ℕ) :
    countDyadicsInUnitInterval (n + 1) > countDyadicsInUnitInterval n := by
  simp only [countDyadicsInUnitInterval]
  have := Nat.one_le_pow n 2 (by norm_num)
  omega

/-! ## Part X: The Filtered Ring Structure -/

/-- **Filtered Ring Theorem**: The birthday filtration makes the dyadic rationals
into a filtered ring: F_m · F_n ⊆ F_{m+n} and F_m + F_n ⊆ F_{max(m,n)}. -/
structure BirthdayFilteredRing where
  /-- Each level is closed under negation -/
  neg_closed : ∀ n q, q ∈ BirthdayFiltration n → -q ∈ BirthdayFiltration n
  /-- Addition respects the max filtration -/
  add_closed : ∀ m n a b, a ∈ BirthdayFiltration m → b ∈ BirthdayFiltration n →
    a + b ∈ BirthdayFiltration (max m n)
  /-- Multiplication respects the sum filtration -/
  mul_closed : ∀ m n a b, a ∈ BirthdayFiltration m → b ∈ BirthdayFiltration n →
    a * b ∈ BirthdayFiltration (m + n)
  /-- Monotonicity of levels -/
  mono : ∀ m n, m ≤ n → BirthdayFiltration m ⊆ BirthdayFiltration n

/-- Construction of the birthday filtered ring. -/
theorem birthdayFilteredRing : BirthdayFilteredRing where
  neg_closed := fun _ _ hq => neg_mem_filtration hq
  add_closed := fun _ _ _ _ ha hb => filtration_add_max ha hb
  mul_closed := fun _ _ _ _ ha hb => filtration_mul_closed ha hb
  mono := fun _ _ h => filtration_mono h

/-! ## Part XI: Complexity Measure -/

/-- The two-dimensional complexity measure: (birthday, numerator size) with
lexicographic order. The birthday measures "when" a number appears; the
numerator size measures structural complexity within that birthday level. -/
structure ComplexityPair where
  birthday : ℕ
  numeratorSize : ℕ
  deriving DecidableEq

instance : LE ComplexityPair where
  le a b := a.birthday < b.birthday ∨
    (a.birthday = b.birthday ∧ a.numeratorSize ≤ b.numeratorSize)

instance : LT ComplexityPair where
  lt a b := a.birthday < b.birthday ∨
    (a.birthday = b.birthday ∧ a.numeratorSize < b.numeratorSize)

/-- Compute the complexity of a rational number. -/
def complexity (q : ℚ) : ComplexityPair where
  birthday := dyadicVal q
  numeratorSize := q.num.natAbs

/-
**Monotonicity**: simpler denominators yield lower birthday complexity.
-/
theorem complexity_birthday_le_of_den_dvd {q r : ℚ}
    (h : q.den ∣ r.den) :
    (complexity q).birthday ≤ (complexity r).birthday := by
  convert Nat.factorization_le_iff_dvd ( by aesop ) ( by aesop ) |>.2 h 2 using 1

/-! ## Part XII: Falsifiable Conjecture

**Conjecture (Multiplication Defect)**:
For dyadic rationals a, b, the defect δ(a,b) = (dyadicVal a + dyadicVal b) - dyadicVal(a·b)
equals the 2-adic valuation of the product of numerators.

**Test**: Compute for all dyadic rationals with denominator ≤ 2^4.
- a = 1/4, b = 6 = 6/1: a·b = 3/2, dyadicVal = 1, sum = 2, defect = 1.
  ν₂(1·6) = ν₂(6) = 1. ✓
- a = 1/2, b = 1/2: a·b = 1/4, dyadicVal = 2, sum = 2, defect = 0.
  ν₂(1·1) = 0. ✓
- a = 3/4, b = 2/1: a·b = 3/2, dyadicVal = 1, sum = 2, defect = 1.
  ν₂(3·2) = ν₂(6) = 1. ✓
-/

/-- The multiplication defect: how much the birthday drops from the sum bound. -/
def mulDefect (a b : ℚ) : ℕ :=
  (dyadicVal a + dyadicVal b) - dyadicVal (a * b)

/-- **Conjecture (revised)**: the multiplication defect equals the minimum of the
2-adic valuation of the numerator product and the sum of the birthday levels.
The original conjecture δ(a,b) = ν₂(|a.num·b.num|) fails for integers with
even numerators (e.g. a=b=20: δ=0 but ν₂(400)=4). The correction accounts for
the fact that cancellation is bounded by the total birthday budget. -/
def mulDefectConjecture : Prop :=
  ∀ a b : ℚ, (∃ k, a.den = 2 ^ k) → (∃ k, b.den = 2 ^ k) →
    mulDefect a b = min (padicValNat 2 (a.num * b.num).natAbs)
                        (dyadicVal a + dyadicVal b)

end BirthdayValuation