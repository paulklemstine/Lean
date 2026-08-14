/-
# ECM-PARITY, core: the parity of the point count of `y² = x³ + A x + B`

For an odd prime `p` and `A B : ZMod p` put

  `curveCard A B = 1 + #{(x,y) ∈ (ZMod p)² : y² = x³ + A x + B}`

(the `1` is the point at infinity of the projective Weierstrass model).

The main result of this file is the **parity dichotomy**

  `2 ∣ curveCard A B  ↔  the cubic x³ + A x + B has a root in ZMod p`

valid whenever the cubic is separable (`Δ = -4A³ - 27B² ≠ 0`).  Equivalently:
`#E` is odd exactly when Frobenius is a `3`-cycle on the roots of the cubic
(the cubic is irreducible over `𝔽_p`; see `ECMParityFrobenius.lean`).

The proof is elementary and self-contained:

* fibrewise counting: over each `x` the fibre `{y : y² = f x}` has odd
  cardinality iff `f x = 0`, hence `#affine ≡ #roots (mod 2)`;
* a separable cubic has `0`, `1` or `3` roots (never `2`), so `#roots` is odd
  iff `#roots ≠ 0`.

§0 collects the purely algebraic facts about a depressed cubic over an arbitrary
field (Vieta, the third root, the discriminant as a square of the root
difference product).  These are reused over the cubic extension `𝔽_{p³}` in
`ECMParityFrobenius.lean`.
-/
import Mathlib

namespace ECMParity

open Finset

/-! ## 0. Depressed cubics over an arbitrary field -/

/-- The depressed cubic `x³ + A x + B`. -/
def cubic {R : Type*} [CommRing R] (A B x : R) : R := x ^ 3 + A * x + B

/-- The discriminant `-4A³ - 27B²` of `x³ + A x + B`. -/
def disc {R : Type*} [CommRing R] (A B : R) : R := -4 * A ^ 3 - 27 * B ^ 2

section GeneralField

variable {F : Type*} [Field F] {A B a b x : F}

/-- Vieta for a depressed cubic with two known distinct roots: `A = -(a²+ab+b²)`. -/
theorem vieta_A (hab : a ≠ b) (ha : cubic A B a = 0) (hb : cubic A B b = 0) :
    A = -(a ^ 2 + a * b + b ^ 2) := by
  have hsub : (a - b) * (a ^ 2 + a * b + b ^ 2 + A) = 0 := by
    unfold cubic at ha hb; linear_combination ha - hb
  rcases mul_eq_zero.1 hsub with h | h
  · exact absurd (sub_eq_zero.1 h) hab
  · linear_combination h

/-- Vieta for a depressed cubic with two known distinct roots: `B = ab(a+b)`. -/
theorem vieta_B (hab : a ≠ b) (ha : cubic A B a = 0) (hb : cubic A B b = 0) :
    B = a * b * (a + b) := by
  have hA := vieta_A hab ha hb
  unfold cubic at ha; rw [hA] at ha; linear_combination ha

/-- The third root of a depressed cubic with two known distinct roots is `-(a+b)`
(the roots sum to zero). -/
theorem cubic_neg_add (hab : a ≠ b) (ha : cubic A B a = 0) (hb : cubic A B b = 0) :
    cubic A B (-(a + b)) = 0 := by
  rw [cubic, vieta_A hab ha hb, vieta_B hab ha hb]; ring

/-- With two distinct roots known, *every* root is one of `a`, `b`, `-(a+b)`. -/
theorem root_cases (hab : a ≠ b) (ha : cubic A B a = 0) (hb : cubic A B b = 0)
    (hx : cubic A B x = 0) : x = a ∨ x = b ∨ x = -(a + b) := by
  have hfac : (x - a) * (x - b) * (x - (-(a + b))) = 0 := by
    unfold cubic at hx
    rw [vieta_A hab ha hb, vieta_B hab ha hb] at hx
    linear_combination hx
  rcases mul_eq_zero.1 hfac with h | h
  · rcases mul_eq_zero.1 h with h' | h'
    · exact Or.inl (sub_eq_zero.1 h')
    · exact Or.inr (Or.inl (sub_eq_zero.1 h'))
  · exact Or.inr (Or.inr (sub_eq_zero.1 h))

/-- The discriminant is the square of the product of root differences. -/
theorem disc_eq_sq (hab : a ≠ b) (ha : cubic A B a = 0) (hb : cubic A B b = 0) :
    disc A B = ((a - b) * (b - -(a + b)) * (-(a + b) - a)) ^ 2 := by
  rw [disc, vieta_A hab ha hb, vieta_B hab ha hb]; ring

/-- For a separable cubic the third root differs from the first. -/
theorem third_root_ne_left (hab : a ≠ b) (ha : cubic A B a = 0) (hb : cubic A B b = 0)
    (hd : disc A B ≠ 0) : -(a + b) ≠ a := by
  intro h
  apply hd
  have hb2 : b = -2 * a := by linear_combination -h
  rw [disc, vieta_A hab ha hb, vieta_B hab ha hb, hb2]; ring

/-- For a separable cubic the third root differs from the second. -/
theorem third_root_ne_right (hab : a ≠ b) (ha : cubic A B a = 0) (hb : cubic A B b = 0)
    (hd : disc A B ≠ 0) : -(a + b) ≠ b := by
  intro h
  apply hd
  have ha2 : a = -2 * b := by linear_combination -h
  rw [disc, vieta_A hab ha hb, vieta_B hab ha hb, ha2]; ring

end GeneralField

/-! ## 1. Fibrewise counting over `𝔽_p` -/

variable {p : ℕ} [Fact p.Prime]

/-- The set of roots of the cubic in `ZMod p`. -/
def rootSet (A B : ZMod p) : Finset (ZMod p) :=
  univ.filter (fun x => cubic A B x = 0)

/-- The affine points of `y² = x³ + A x + B`. -/
def affinePoints (A B : ZMod p) : Finset (ZMod p × ZMod p) :=
  univ.filter (fun P => P.2 ^ 2 = cubic A B P.1)

/-- The number of projective points: affine points plus the point at infinity. -/
def curveCard (A B : ZMod p) : ℕ := 1 + (affinePoints A B).card

theorem two_ne_zero_of_odd (hp : p ≠ 2) : (2 : ZMod p) ≠ 0 := by
  intro h
  have h2 : ((2 : ℕ) : ZMod p) = 0 := by exact_mod_cast h
  rw [ZMod.natCast_eq_zero_iff] at h2
  have hp' : p.Prime := Fact.out
  exact hp ((Nat.prime_dvd_prime_iff_eq hp' Nat.prime_two).1 h2)

/-- For `p` odd, the fibre `{y : y² = c}` has odd cardinality iff `c = 0`. -/
theorem card_sqrt_fiber_mod_two (hp : p ≠ 2) (c : ZMod p) :
    (((univ.filter (fun y : ZMod p => y ^ 2 = c)).card : ZMod 2)) =
      if c = 0 then 1 else 0 := by
  have hp2 : (2 : ZMod p) ≠ 0 := two_ne_zero_of_odd hp
  by_cases hc : c = 0
  · subst hc
    have hset : (univ.filter (fun y : ZMod p => y ^ 2 = 0)) = {0} := by
      ext y; simp [pow_eq_zero_iff]
    rw [hset]
    simp
  · simp only [hc, if_false]
    by_cases hs : ∃ y₀ : ZMod p, y₀ ^ 2 = c
    · obtain ⟨y₀, hy₀⟩ := hs
      have hy0 : y₀ ≠ 0 := by
        rintro rfl; exact hc (by simpa using hy₀.symm)
      have hne : y₀ ≠ -y₀ := by
        intro h
        apply hy0
        have h2 : (2 : ZMod p) * y₀ = 0 := by linear_combination h
        rcases mul_eq_zero.1 h2 with h' | h'
        · exact absurd h' hp2
        · exact h'
      have hset : (univ.filter (fun y : ZMod p => y ^ 2 = c)) = {y₀, -y₀} := by
        ext y
        simp only [mem_filter, mem_univ, true_and, mem_insert, mem_singleton]
        constructor
        · intro hy
          have hfac : (y - y₀) * (y + y₀) = 0 := by linear_combination hy - hy₀
          rcases mul_eq_zero.1 hfac with h | h
          · exact Or.inl (sub_eq_zero.1 h)
          · exact Or.inr (eq_neg_of_add_eq_zero_left h)
        · rintro (rfl | rfl)
          · exact hy₀
          · rw [neg_pow]; simpa using hy₀
      rw [hset, Finset.card_insert_of_notMem (by simpa using hne), Finset.card_singleton]
      decide
    · push_neg at hs
      have hset : (univ.filter (fun y : ZMod p => y ^ 2 = c)) = ∅ := by
        ext y; simp [hs y]
      simp [hset]

/-- The affine point count is congruent, mod `2`, to the number of roots of the cubic. -/
theorem affine_card_mod_two (hp : p ≠ 2) (A B : ZMod p) :
    (((affinePoints A B).card : ZMod 2)) = ((rootSet A B).card : ZMod 2) := by
  have h1 : (affinePoints A B).card
      = ∑ x : ZMod p, (univ.filter (fun y : ZMod p => y ^ 2 = cubic A B x)).card := by
    rw [affinePoints, card_filter]
    rw [Fintype.sum_prod_type]
    refine Finset.sum_congr rfl (fun x _ => ?_)
    rw [card_filter]
  have h2 : ((rootSet A B).card : ZMod 2)
      = ∑ x : ZMod p, (if cubic A B x = 0 then (1 : ZMod 2) else 0) := by
    rw [rootSet, card_filter]
    push_cast
    exact Finset.sum_congr rfl (fun x _ => by split <;> simp)
  rw [h1, h2]
  push_cast
  exact Finset.sum_congr rfl (fun x _ => card_sqrt_fiber_mod_two hp _)

/-- The projective point count is even iff the number of roots of the cubic is odd. -/
theorem curveCard_even_iff_odd_rootSet (hp : p ≠ 2) (A B : ZMod p) :
    2 ∣ curveCard A B ↔ Odd (rootSet A B).card := by
  have h := affine_card_mod_two hp A B
  have key : (((affinePoints A B).card) % 2) = ((rootSet A B).card % 2) := by
    have := (ZMod.natCast_eq_natCast_iff' _ _ 2).1 h
    simpa using this
  unfold curveCard
  rw [Nat.odd_iff]
  omega

/-! ## 2. A separable cubic has `0`, `1` or `3` roots -/

/-- If a depressed cubic has two distinct roots `a ≠ b`, its root set is exactly
`{a, b, -(a+b)}`. -/
theorem rootSet_eq_of_two_roots {A B a b : ZMod p} (hab : a ≠ b)
    (ha : cubic A B a = 0) (hb : cubic A B b = 0) :
    rootSet A B = {a, b, -(a + b)} := by
  ext x
  simp only [rootSet, mem_filter, mem_univ, true_and, mem_insert, mem_singleton]
  constructor
  · exact fun hx => root_cases hab ha hb hx
  · rintro (rfl | rfl | rfl)
    · exact ha
    · exact hb
    · exact cubic_neg_add hab ha hb

/-- With a nonzero discriminant, two distinct roots force a third one:
the root set has exactly three elements. -/
theorem rootSet_card_eq_three {A B a b : ZMod p} (hab : a ≠ b)
    (ha : cubic A B a = 0) (hb : cubic A B b = 0) (hd : disc A B ≠ 0) :
    (rootSet A B).card = 3 := by
  have hca : -(a + b) ≠ a := third_root_ne_left hab ha hb hd
  have hcb : -(a + b) ≠ b := third_root_ne_right hab ha hb hd
  rw [rootSet_eq_of_two_roots hab ha hb]
  rw [Finset.card_insert_of_notMem (by
      simp only [Finset.mem_insert, Finset.mem_singleton]
      push_neg
      exact ⟨hab, fun h => hca (by linear_combination -h)⟩),
    Finset.card_insert_of_notMem (by
      simp only [Finset.mem_singleton]
      exact fun h => hcb (by linear_combination -h)), Finset.card_singleton]

/-- A separable depressed cubic over `𝔽_p` has `0`, `1` or `3` roots. -/
theorem rootSet_card_cases (A B : ZMod p) (hd : disc A B ≠ 0) :
    (rootSet A B).card = 0 ∨ (rootSet A B).card = 1 ∨ (rootSet A B).card = 3 := by
  rcases Nat.lt_or_ge (rootSet A B).card 2 with h | h
  · interval_cases hc : (rootSet A B).card
    · exact Or.inl rfl
    · exact Or.inr (Or.inl rfl)
  · obtain ⟨a, ha, b, hb, hab⟩ := Finset.one_lt_card.1 h
    simp only [rootSet, mem_filter] at ha hb
    exact Or.inr (Or.inr (rootSet_card_eq_three hab ha.2 hb.2 hd))

/-! ## 3. The parity dichotomy -/

/-- **Parity dichotomy.**  For a separable cubic, the projective point count of
`y² = x³ + A x + B` over `𝔽_p` (`p` odd) is even iff the cubic has a root. -/
theorem two_dvd_curveCard_iff (hp : p ≠ 2) (A B : ZMod p) (hd : disc A B ≠ 0) :
    2 ∣ curveCard A B ↔ ∃ x : ZMod p, cubic A B x = 0 := by
  rw [curveCard_even_iff_odd_rootSet hp]
  constructor
  · intro hodd
    have hne : (rootSet A B).Nonempty := by
      rw [← Finset.card_pos]
      rcases hodd with ⟨k, hk⟩; omega
    obtain ⟨x, hx⟩ := hne
    exact ⟨x, by simpa [rootSet] using hx⟩
  · intro ⟨x, hx⟩
    have hne : (rootSet A B).card ≠ 0 := by
      intro h
      have hx' : x ∈ rootSet A B := by simp [rootSet, hx]
      rw [Finset.card_eq_zero] at h
      rw [h] at hx'
      simp at hx'
    rcases rootSet_card_cases A B hd with h | h | h
    · exact absurd h hne
    · rw [h]; exact ⟨0, rfl⟩
    · rw [h]; exact ⟨1, rfl⟩

/-- The odd face: `#E` is odd exactly when the cubic has no root, i.e. exactly when
Frobenius acts as a `3`-cycle on the roots. -/
theorem curveCard_odd_iff_no_root (hp : p ≠ 2) (A B : ZMod p) (hd : disc A B ≠ 0) :
    ¬ (2 ∣ curveCard A B) ↔ ∀ x : ZMod p, cubic A B x ≠ 0 := by
  rw [two_dvd_curveCard_iff hp A B hd]
  push_neg
  rfl

end ECMParity