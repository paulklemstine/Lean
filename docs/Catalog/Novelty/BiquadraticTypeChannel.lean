/-
# THE-BIQUADRATIC-IS-FULLY-PINNED: the type channel of `x⁴ - 10x² + 1`

`x⁴ - 10x² + 1` is the minimal polynomial of `√2 + √3`; its splitting field is the
biquadratic field `ℚ(√2, √3)` with Galois group `V₄ = C₂ × C₂` and conductor `24`.

We prove the arithmetic behind the reported "two types, full pinning" experiment,
in a form that holds for the *general* biquadratic quartic
`B_{a,b}(x) = x⁴ - 2(a+b)x² + (a-b)²` (the minimal polynomial of `√a + √b`), over an
*arbitrary* field of characteristic `≠ 2`:

* `bq_eq_sub_sq_a`, `bq_eq_sub_sq_b`, `bq_eq_sub_sq_ab` — the three "difference of
  squares" shapes of `B_{a,b}`, one for each quadratic subfield.
* `bq_root_iff` — `B_{a,b}` has a root iff **both** `a` and `b` are squares.
* `bq_roots_eq` — if `α² = a`, `β² = b`, the root set is exactly `{±α ± β}`,
  and (`bq_roots_card`) these are four distinct elements.
* `bq_reducible_of_square` — `B_{a,b}` is a product of two monic quadratics as soon
  as one of `a`, `b`, `ab` is a square.

Specialised to `ℤ/p` with `a = 2`, `b = 3`:

* `biqType_eq` — for every prime `p ≥ 5`, the number of roots of `x⁴ - 10x² + 1`
  mod `p` is `4` if `p ≡ ±1 (mod 24)` and `0` otherwise: **only two types**.
* `biq_reducible_mod_every_prime` — `x⁴ - 10x² + 1` factors into two monic
  quadratics modulo *every* prime, so the root-free type is the type `(2,2)`;
  `biq_no_int_factorisation` shows there is no such factorisation over `ℤ`, and
  `biqPolyQ_irreducible` that the quartic is irreducible over `ℚ`
  (`biq_local_global`: globally irreducible, locally reducible everywhere).
* `conductor_exactly_24` — no proper divisor `d` of `24` pins the type.
* `biq_full_pinning` — on every finite set of primes `≥ 5`,
  `I(p mod 24 ; T) = H(T)` **exactly**.
-/
import Novelty.S3SignChannelUniversal

namespace BiquadraticTypeChannel

open Finset CyclicTypeChannel

/-! ## 1. The general biquadratic quartic over a field -/

section Field

variable {F : Type*} [Field F]

/-- The biquadratic quartic `B_{a,b}(x) = x⁴ - 2(a+b)x² + (a-b)²`,
the minimal polynomial of `√a + √b`. -/
def bq (a b x : F) : F := x ^ 4 - 2 * (a + b) * x ^ 2 + (a - b) ^ 2

/-- `B_{a,b}(x) = (x² + (a - b))² - 4a·x²` (the `ℚ(√a)`-shape). -/
theorem bq_eq_sub_sq_a (a b x : F) : bq a b x = (x ^ 2 + (a - b)) ^ 2 - 4 * a * x ^ 2 := by
  unfold bq; ring

/-- `B_{a,b}(x) = (x² - (a - b))² - 4b·x²` (the `ℚ(√b)`-shape). -/
theorem bq_eq_sub_sq_b (a b x : F) : bq a b x = (x ^ 2 - (a - b)) ^ 2 - 4 * b * x ^ 2 := by
  unfold bq; ring

/-- `B_{a,b}(x) = (x² - (a + b))² - 4ab` (the `ℚ(√ab)`-shape). -/
theorem bq_eq_sub_sq_ab (a b x : F) : bq a b x = (x ^ 2 - (a + b)) ^ 2 - 4 * (a * b) := by
  unfold bq; ring

variable {a b : F}

/-- A root of `B_{a,b}` forces `a` to be a square (when `2 ≠ 0`, `a ≠ b`). -/
theorem isSquare_a_of_root (h2 : (2 : F) ≠ 0) (hab : a ≠ b) {x : F} (hx : bq a b x = 0) :
    IsSquare a := by
  have hx0 : x ≠ 0 := by
    rintro rfl
    apply hab
    have : (a - b) ^ 2 = 0 := by simpa [bq] using hx
    exact sub_eq_zero.1 (pow_eq_zero_iff (n := 2) (by norm_num) |>.1 this)
  refine ⟨(x ^ 2 + (a - b)) / (2 * x), ?_⟩
  rw [bq_eq_sub_sq_a] at hx
  field_simp
  linear_combination -hx

/-- A root of `B_{a,b}` forces `b` to be a square (when `2 ≠ 0`, `a ≠ b`). -/
theorem isSquare_b_of_root (h2 : (2 : F) ≠ 0) (hab : a ≠ b) {x : F} (hx : bq a b x = 0) :
    IsSquare b := by
  have hx0 : x ≠ 0 := by
    rintro rfl
    apply hab
    have : (a - b) ^ 2 = 0 := by simpa [bq] using hx
    exact sub_eq_zero.1 (pow_eq_zero_iff (n := 2) (by norm_num) |>.1 this)
  refine ⟨(x ^ 2 - (a - b)) / (2 * x), ?_⟩
  rw [bq_eq_sub_sq_b] at hx
  field_simp
  linear_combination -hx

/-- `±α ± β` are roots of `B_{a,b}` whenever `α² = a`, `β² = b`. -/
theorem bq_root_of_sq {α β : F} (ha : α ^ 2 = a) (hb : β ^ 2 = b) (s t : F)
    (hs : s ^ 2 = 1) (ht : t ^ 2 = 1) : bq a b (s * α + t * β) = 0 := by
  rw [bq_eq_sub_sq_ab, show (s * α + t * β) ^ 2 - (a + b) = 2 * s * t * α * β by
    rw [← ha, ← hb]; linear_combination α ^ 2 * hs + β ^ 2 * ht, ← ha, ← hb]
  linear_combination 4 * α ^ 2 * β ^ 2 * (s ^ 2 * ht + hs)

/-- **Root criterion.**  Over a field of characteristic `≠ 2`, with `a ≠ b`,
`B_{a,b}` has a root iff both `a` and `b` are squares. -/
theorem bq_root_iff (h2 : (2 : F) ≠ 0) (hab : a ≠ b) :
    (∃ x, bq a b x = 0) ↔ IsSquare a ∧ IsSquare b := by
  constructor
  · rintro ⟨x, hx⟩
    exact ⟨isSquare_a_of_root h2 hab hx, isSquare_b_of_root h2 hab hx⟩
  · rintro ⟨⟨α, hα⟩, ⟨β, hβ⟩⟩
    refine ⟨1 * α + 1 * β, bq_root_of_sq (by rw [hα]; ring) (by rw [hβ]; ring) 1 1
      (by ring) (by ring)⟩

/-- **The root set is exactly `{±α ± β}`.** -/
theorem bq_roots_eq {α β : F} (ha : α ^ 2 = a) (hb : β ^ 2 = b) (x : F) :
    bq a b x = 0 ↔ x = α + β ∨ x = α - β ∨ x = -α + β ∨ x = -α - β := by
  constructor
  · intro hx
    rw [bq_eq_sub_sq_ab, ← ha, ← hb] at hx
    have h1 : (x ^ 2 - (α + β) ^ 2) * (x ^ 2 - (α - β) ^ 2) = 0 := by
      linear_combination hx
    rcases mul_eq_zero.1 h1 with h | h
    · have h' : (x - (α + β)) * (x + (α + β)) = 0 := by linear_combination h
      rcases mul_eq_zero.1 h' with h | h
      · exact Or.inl (sub_eq_zero.1 h)
      · exact Or.inr (Or.inr (Or.inr (by linear_combination h)))
    · have h' : (x - (α - β)) * (x + (α - β)) = 0 := by linear_combination h
      rcases mul_eq_zero.1 h' with h | h
      · exact Or.inr (Or.inl (sub_eq_zero.1 h))
      · exact Or.inr (Or.inr (Or.inl (by linear_combination h)))
  · rintro (rfl | rfl | rfl | rfl)
    · simpa using bq_root_of_sq ha hb 1 1 (by ring) (by ring)
    · simpa [sub_eq_add_neg] using bq_root_of_sq ha hb 1 (-1) (by ring) (by ring)
    · simpa using bq_root_of_sq ha hb (-1) 1 (by ring) (by ring)
    · simpa [sub_eq_add_neg] using bq_root_of_sq ha hb (-1) (-1) (by ring) (by ring)

/-- **The four roots are distinct.** -/
theorem bq_roots_card [DecidableEq F] (h2 : (2 : F) ≠ 0) {α β : F} (hα : α ≠ 0) (hβ : β ≠ 0)
    (hab : α ^ 2 ≠ β ^ 2) :
    ({α + β, α - β, -α + β, -α - β} : Finset F).card = 4 := by
  have hab1 : α ≠ β := fun h => hab (by rw [h])
  have hab2 : α ≠ -β := fun h => hab (by rw [h]; ring)
  have k1 : α + β ≠ α - β := fun h => hβ (by
    have : 2 * β = 0 := by linear_combination h
    exact (mul_eq_zero.1 this).resolve_left h2)
  have k2 : α + β ≠ -α + β := fun h => hα (by
    have : 2 * α = 0 := by linear_combination h
    exact (mul_eq_zero.1 this).resolve_left h2)
  have k3 : α + β ≠ -α - β := fun h => hab2 (by
    have : 2 * (α + β) = 0 := by linear_combination h
    linear_combination (mul_eq_zero.1 this).resolve_left h2)
  have k4 : α - β ≠ -α + β := fun h => hab1 (by
    have : 2 * (α - β) = 0 := by linear_combination h
    linear_combination (mul_eq_zero.1 this).resolve_left h2)
  have k5 : α - β ≠ -α - β := fun h => hα (by
    have : 2 * α = 0 := by linear_combination h
    exact (mul_eq_zero.1 this).resolve_left h2)
  have k6 : -α + β ≠ -α - β := fun h => hβ (by
    have : 2 * β = 0 := by linear_combination h
    exact (mul_eq_zero.1 this).resolve_left h2)
  rw [card_insert_of_notMem (by simp [k1, k2, k3]), card_insert_of_notMem (by simp [k4, k5]),
    card_insert_of_notMem (by simp [k6]), card_singleton]

/-- **Reducibility from any quadratic subfield.**  If one of `a`, `b`, `ab` is a
square, `B_{a,b}` is a product of two monic quadratics. -/
theorem bq_reducible_of_square (h : IsSquare a ∨ IsSquare b ∨ IsSquare (a * b)) :
    ∃ u v w z : F, ∀ x, bq a b x = (x ^ 2 + u * x + v) * (x ^ 2 + w * x + z) := by
  rcases h with ⟨α, hα⟩ | ⟨β, hβ⟩ | ⟨γ, hγ⟩
  · exact ⟨-2 * α, a - b, 2 * α, a - b, fun x => by rw [bq_eq_sub_sq_a, hα]; ring⟩
  · exact ⟨-2 * β, -(a - b), 2 * β, -(a - b), fun x => by rw [bq_eq_sub_sq_b, hβ]; ring⟩
  · exact ⟨0, -(a + b) - 2 * γ, 0, -(a + b) + 2 * γ, fun x => by rw [bq_eq_sub_sq_ab, hγ]; ring⟩

/-- **Two-types universality for every biquadratic quartic.**  Over a finite field of
characteristic `≠ 2`, with `a, b ≠ 0` and `a ≠ b`, the quartic `B_{a,b}` has exactly
`4` roots if `a` and `b` are both squares and `0` roots otherwise: the splitting type
of `ℚ(√a, √b)` only ever takes the two values "split" and `(2,2)`. -/
theorem bq_card_roots [Fintype F] [DecidableEq F] (h2 : (2 : F) ≠ 0) (ha0 : a ≠ 0) (hb0 : b ≠ 0)
    (hab : a ≠ b) :
    Fintype.card {x : F // bq a b x = 0} = if IsSquare a ∧ IsSquare b then 4 else 0 := by
  split_ifs with h
  · obtain ⟨⟨α, hα⟩, ⟨β, hβ⟩⟩ := h
    have hα2 : α ^ 2 = a := by rw [hα]; ring
    have hβ2 : β ^ 2 = b := by rw [hβ]; ring
    have hα0 : α ≠ 0 := by rintro rfl; exact ha0 (by simpa using hα2.symm)
    have hβ0 : β ≠ 0 := by rintro rfl; exact hb0 (by simpa using hβ2.symm)
    have e : ∀ x : F, bq a b x = 0 ↔ x ∈ ({α + β, α - β, -α + β, -α - β} : Finset F) := by
      intro x; rw [bq_roots_eq hα2 hβ2]; simp
    rw [Fintype.card_congr (Equiv.subtypeEquivRight e), Fintype.card_coe,
      bq_roots_card h2 hα0 hβ0 (by rw [hα2, hβ2]; exact hab)]
  · rw [Fintype.card_eq_zero_iff]
    exact ⟨fun ⟨x, hx⟩ => h ((bq_root_iff h2 hab).1 ⟨x, hx⟩)⟩

end Field

/-! ## 2. The quartic `x⁴ - 10x² + 1` modulo a prime -/

/-- `B_{2,3}` is `x⁴ - 10x² + 1`. -/
theorem bq_two_three {R : Type*} [Field R] (x : R) : bq 2 3 x = x ^ 4 - 10 * x ^ 2 + 1 := by
  unfold bq; ring

/-- `2` is not a square mod `3`. -/
lemma not_isSquare_two_zmod3 : ¬ IsSquare (2 : ZMod 3) := by decide

section ZModP

variable {p : ℕ} [hp : Fact p.Prime]

lemma two_ne_zero_mod (hp2 : p ≠ 2) : (2 : ZMod p) ≠ 0 := by
  haveI : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩
  exact_mod_cast ZMod.prime_ne_zero p 2 hp2

lemma three_ne_zero_mod (hp3 : p ≠ 3) : (3 : ZMod p) ≠ 0 := by
  haveI : Fact (Nat.Prime 3) := ⟨Nat.prime_three⟩
  exact_mod_cast ZMod.prime_ne_zero p 3 hp3

lemma two_ne_three_mod : (2 : ZMod p) ≠ 3 := by
  intro h
  have : (1 : ZMod p) = 0 := by linear_combination -h
  exact one_ne_zero this

/-- **`3` is a square mod `p` iff `p ≡ ±1 (mod 12)`** (quadratic reciprocity). -/
theorem isSquare_three_iff (hp2 : p ≠ 2) (hp3 : p ≠ 3) :
    IsSquare (3 : ZMod p) ↔ p % 12 = 1 ∨ p % 12 = 11 := by
  haveI : Fact (Nat.Prime 3) := ⟨Nat.prime_three⟩
  have hodd : p % 2 = 1 := Nat.odd_iff.1 (hp.out.odd_of_ne_two hp2)
  have h3 : p % 3 ≠ 0 := fun h =>
    hp3 ((Nat.prime_dvd_prime_iff_eq Nat.prime_three hp.out).1 (Nat.dvd_of_mod_eq_zero h)).symm
  have hc : ((p : ℕ) : ZMod 3) = ((p % 3 : ℕ) : ZMod 3) := (ZMod.natCast_mod p 3).symm
  have hm3 : p % 3 = 1 ∨ p % 3 = 2 := by omega
  have hm4 : p % 4 = 1 ∨ p % 4 = 3 := by omega
  rcases hm4 with h4 | h4
  · have key := ZMod.exists_sq_eq_prime_iff_of_mod_four_eq_one (p := p) (q := 3) h4 (by norm_num)
    push_cast at key
    rw [key, hc]
    rcases hm3 with h | h <;> rw [h]
    · rw [Nat.cast_one]; exact iff_of_true ⟨1, by ring⟩ (by omega)
    · simp only [Nat.cast_ofNat]
      constructor
      · intro hs; exact absurd hs not_isSquare_two_zmod3
      · intro; omega
  · have key := ZMod.exists_sq_eq_prime_iff_of_mod_four_eq_three (p := p) (q := 3) h4 (by norm_num)
      hp3
    push_cast at key
    rw [key, hc]
    rcases hm3 with h | h <;> rw [h]
    · rw [Nat.cast_one]; exact iff_of_false (fun hn => hn ⟨1, by ring⟩) (by omega)
    · simp only [Nat.cast_ofNat]
      constructor
      · intro; omega
      · intro; exact not_isSquare_two_zmod3

/-- **Root criterion at conductor 24.**  For a prime `p ≥ 5`, `x⁴ - 10x² + 1`
has a root mod `p` iff `p ≡ ±1 (mod 24)`. -/
theorem biq_root_iff (hp2 : p ≠ 2) (hp3 : p ≠ 3) :
    (∃ x : ZMod p, x ^ 4 - 10 * x ^ 2 + 1 = 0) ↔ p % 24 = 1 ∨ p % 24 = 23 := by
  have e : (∃ x : ZMod p, x ^ 4 - 10 * x ^ 2 + 1 = 0) ↔ ∃ x : ZMod p, bq 2 3 x = 0 := by
    simp only [bq_two_three]
  rw [e, bq_root_iff (two_ne_zero_mod hp2) two_ne_three_mod, ZMod.exists_sq_eq_two_iff hp2,
    isSquare_three_iff hp2 hp3]
  omega

/-- **Reducible modulo every prime.**  `x⁴ - 10x² + 1` is a product of two monic
quadratics over `ℤ/p` for *every* prime `p` (one of `2`, `3`, `6` is always a square). -/
theorem biq_reducible_mod_every_prime :
    ∃ u v w z : ZMod p, ∀ x, x ^ 4 - 10 * x ^ 2 + 1 = (x ^ 2 + u * x + v) * (x ^ 2 + w * x + z) := by
  have hsq : IsSquare (2 : ZMod p) ∨ IsSquare (3 : ZMod p) ∨ IsSquare ((2 : ZMod p) * 3) := by
    by_cases hp2 : p = 2
    · subst hp2; left; exact ⟨0, by rw [mul_zero]; rfl⟩
    by_cases hp3 : p = 3
    · subst hp3; right; left; exact ⟨0, by rw [mul_zero]; rfl⟩
    by_cases h2 : IsSquare (2 : ZMod p)
    · exact Or.inl h2
    by_cases h3 : IsSquare (3 : ZMod p)
    · exact Or.inr (Or.inl h3)
    right; right
    have l2 : legendreSym p 2 = -1 := legendreSym.eq_neg_one_iff p |>.2 (by exact_mod_cast h2)
    have l3 : legendreSym p 3 = -1 := legendreSym.eq_neg_one_iff p |>.2 (by exact_mod_cast h3)
    have l6 : legendreSym p (2 * 3) = 1 := by rw [legendreSym.mul, l2, l3]; norm_num
    have h6 : ((2 * 3 : ℤ) : ZMod p) ≠ 0 := by
      rw [show ((2 * 3 : ℤ) : ZMod p) = 2 * 3 by push_cast; ring]
      exact mul_ne_zero (two_ne_zero_mod hp2) (three_ne_zero_mod hp3)
    have := (legendreSym.eq_one_iff p h6).1 l6
    exact_mod_cast this
  obtain ⟨u, v, w, z, h⟩ := bq_reducible_of_square hsq
  exact ⟨u, v, w, z, fun x => by rw [← bq_two_three, h]⟩

end ZModP

/-- **No factorisation over `ℤ`.**  In contrast with `biq_reducible_mod_every_prime`,
`x⁴ - 10x² + 1` is *not* a product of two monic integer quadratics. -/
theorem biq_no_int_factorisation :
    ¬ ∃ u v w z : ℤ, ∀ x : ℤ, x ^ 4 - 10 * x ^ 2 + 1 = (x ^ 2 + u * x + v) * (x ^ 2 + w * x + z) := by
  rintro ⟨u, v, w, z, h⟩
  have h0 := h 0
  have h1 := h 1
  have h1' := h (-1)
  have h2 := h 2
  have h2' := h (-2)
  norm_num at h0 h1 h1' h2 h2'
  rcases Int.eq_one_or_neg_one_of_mul_eq_one' h0.symm with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
  · have hw : w = -u := by nlinarith
    subst hw
    have hu : u ^ 2 = 12 := by nlinarith
    have hb : u ≤ 3 ∧ -3 ≤ u := by constructor <;> nlinarith
    obtain ⟨hb1, hb2⟩ := hb
    interval_cases u <;> omega
  · have hw : w = -u := by nlinarith
    subst hw
    have hu : u ^ 2 = 8 := by nlinarith
    have hb : u ≤ 2 ∧ -2 ≤ u := by constructor <;> nlinarith
    obtain ⟨hb1, hb2⟩ := hb
    interval_cases u <;> omega

/-! ## 3. Only two types -/

/-- The splitting type of `x⁴ - 10x² + 1` at `p`, read out as its number of roots
mod `p`. -/
noncomputable def biqType (p : ℕ) : ℕ := Nat.card {x : ZMod p // x ^ 4 - 10 * x ^ 2 + 1 = 0}

/-- The type predicted from the residue class: `4` on the classes `±1 (mod 24)`,
`0` elsewhere. -/
def classType (r : ℕ) : ℕ := if r = 1 ∨ r = 23 then 4 else 0

/-- **Only two types, read off from `p mod 24`.**  For every prime `p ≥ 5`,
`x⁴ - 10x² + 1` has exactly `4` roots mod `p` if `p ≡ ±1 (mod 24)` (complete
splitting, type `(1,1,1,1)`) and no root otherwise (type `(2,2)`, by
`biq_reducible_mod_every_prime`). -/
theorem biqType_eq {p : ℕ} (hp : p.Prime) (hp2 : p ≠ 2) (hp3 : p ≠ 3) :
    biqType p = classType (p % 24) := by
  haveI := Fact.mk hp
  unfold classType
  split_ifs with h
  · obtain ⟨⟨α, hα⟩, ⟨β, hβ⟩⟩ := (bq_root_iff (two_ne_zero_mod hp2) two_ne_three_mod).1
      ((biq_root_iff hp2 hp3).2 h |>.imp fun x hx => by rwa [bq_two_three])
    have hα2 : α ^ 2 = 2 := by rw [hα]; ring
    have hβ2 : β ^ 2 = 3 := by rw [hβ]; ring
    have hα0 : α ≠ 0 := by rintro rfl; exact two_ne_zero_mod hp2 (by simpa using hα2.symm)
    have hβ0 : β ≠ 0 := by rintro rfl; exact three_ne_zero_mod hp3 (by simpa using hβ2.symm)
    classical
    have e : ∀ x : ZMod p, x ^ 4 - 10 * x ^ 2 + 1 = 0 ↔
        x ∈ ({α + β, α - β, -α + β, -α - β} : Finset (ZMod p)) := by
      intro x
      rw [← bq_two_three, bq_roots_eq hα2 hβ2]
      simp
    rw [biqType, Nat.card_congr (Equiv.subtypeEquivRight e), Nat.card_eq_fintype_card,
      Fintype.card_coe, bq_roots_card (two_ne_zero_mod hp2) hα0 hβ0
        (by rw [hα2, hβ2]; exact two_ne_three_mod)]
  · rw [biqType, Nat.card_eq_zero]
    left
    exact ⟨fun ⟨x, hx⟩ => h ((biq_root_iff hp2 hp3).1 ⟨x, hx⟩)⟩

/-- **Two types.**  The root count is always `4` or `0`: no prime `p ≥ 5` gives one or
two roots (types `(1,3)`, `(1,1,2)`) or an irreducible quartic (type `(4)`). -/
theorem biqType_two_values {p : ℕ} (hp : p.Prime) (hp2 : p ≠ 2) (hp3 : p ≠ 3) :
    biqType p = 4 ∨ biqType p = 0 := by
  rw [biqType_eq hp hp2 hp3, classType]
  split_ifs <;> simp

/-- **THE-BIQUADRATIC-IS-FULLY-PINNED.**  On every finite set of primes `≥ 5`, the
residue `p mod 24` carries *all* the information of the splitting type:
`I(T ; p mod 24) = H(T)`. -/
theorem biq_full_pinning (S : Finset ℕ) (hS : ∀ p ∈ S, p.Prime ∧ p ≠ 2 ∧ p ≠ 3) :
    mutInfo S biqType (· % 24) = uEnt S biqType := by
  refine S3SignChannelUniversal.mutInfo_eq_uEnt_of_factor S _ _ fun x hx y hy h => ?_
  obtain ⟨hx1, hx2, hx3⟩ := hS x hx
  obtain ⟨hy1, hy2, hy3⟩ := hS y hy
  rw [biqType_eq hx1 hx2 hx3, biqType_eq hy1 hy2 hy3]
  exact congrArg classType h

/-- **The conductor is exactly 24.**  For every proper divisor `d` of `24` the
residue `p mod d` does *not* determine the type: there are primes `p, q ≥ 5`
with `p ≡ q (mod d)` but different types (witnesses `7, 23` and `13, 73`). -/
theorem conductor_exactly_24 (d : ℕ) (hd : d ∣ 24) (hd24 : d ≠ 24) :
    ∃ p q : ℕ, p.Prime ∧ q.Prime ∧ 5 ≤ p ∧ 5 ≤ q ∧ p % d = q % d ∧ biqType p ≠ biqType q := by
  have hdiv : d ∣ 8 ∨ d ∣ 12 := by
    have : d ∈ Nat.divisors 24 := Nat.mem_divisors.2 ⟨hd, by norm_num⟩
    have hl : Nat.divisors 24 = {1, 2, 3, 4, 6, 8, 12, 24} := by decide
    rw [hl] at this
    simp only [mem_insert, mem_singleton] at this
    rcases this with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> first
      | exact absurd rfl hd24 | (left; decide) | (right; decide)
  rcases hdiv with h8 | h12
  · refine ⟨7, 23, by norm_num, by norm_num, by norm_num, by norm_num, ?_, ?_⟩
    · exact (Nat.ModEq.of_dvd h8 (show 7 ≡ 23 [MOD 8] by decide))
    · rw [biqType_eq (by norm_num) (by norm_num) (by norm_num),
        biqType_eq (by norm_num) (by norm_num) (by norm_num)]
      decide
  · refine ⟨13, 73, by norm_num, by norm_num, by norm_num, by norm_num, ?_, ?_⟩
    · exact (Nat.ModEq.of_dvd h12 (show 13 ≡ 73 [MOD 12] by decide))
    · rw [biqType_eq (by norm_num) (by norm_num) (by norm_num),
        biqType_eq (by norm_num) (by norm_num) (by norm_num)]
      decide

/-! ## 4. Globally irreducible, locally reducible everywhere -/

section Global

open Polynomial

/-- The integer polynomial `x⁴ - 10x² + 1`. -/
noncomputable def biqPolyZ : ℤ[X] := X ^ 4 - C 10 * X ^ 2 + 1

lemma biqPolyZ_eval (x : ℤ) : biqPolyZ.eval x = x ^ 4 - 10 * x ^ 2 + 1 := by
  simp [biqPolyZ]

lemma biqPolyZ_natDegree : biqPolyZ.natDegree = 4 := by
  unfold biqPolyZ; compute_degree!

lemma biqPolyZ_monic : biqPolyZ.Monic := by
  unfold biqPolyZ; monicity!

/-- A monic polynomial of degree `2` evaluates as `x² + c₁x + c₀`. -/
lemma eval_monic_deg_two {q : ℤ[X]} (hq : q.Monic) (hd : q.natDegree = 2) (x : ℤ) :
    q.eval x = x ^ 2 + q.coeff 1 * x + q.coeff 0 := by
  conv_lhs => rw [hq.as_sum, hd]
  simp only [Finset.sum_range_succ, Finset.sum_range_zero, eval_add, eval_pow, eval_X, eval_mul,
    eval_C, pow_zero, pow_one, zero_add, mul_one]
  ring

/-- **`x⁴ - 10x² + 1` is irreducible over `ℤ`.** -/
theorem biqPolyZ_irreducible : Irreducible biqPolyZ := by
  have h1 : biqPolyZ ≠ 1 := fun h => by
    have := congrArg natDegree h
    rw [biqPolyZ_natDegree] at this
    simp at this
  rw [biqPolyZ_monic.irreducible_iff_lt_natDegree_lt h1, biqPolyZ_natDegree]
  rintro q hq hdeg ⟨f, hf⟩
  have hfm : f.Monic := hq.of_mul_monic_left (hf ▸ biqPolyZ_monic)
  have hdf : f.natDegree = 4 - q.natDegree := by
    have := congrArg natDegree hf
    rw [hq.natDegree_mul hfm, biqPolyZ_natDegree] at this
    omega
  simp only [Finset.mem_Ioc, show (4 : ℕ) / 2 = 2 from rfl] at hdeg
  have hev : ∀ x : ℤ, x ^ 4 - 10 * x ^ 2 + 1 = q.eval x * f.eval x := fun x => by
    rw [← biqPolyZ_eval, hf, eval_mul]
  rcases (show q.natDegree = 1 ∨ q.natDegree = 2 by omega) with hd | hd
  · -- a linear factor gives an integer root `-c`, impossible
    have hq' : q.eval (-q.coeff 0) = 0 := by
      rw [hq.as_sum, hd]; simp
    have h0 := hev (-q.coeff 0)
    rw [hq', zero_mul] at h0
    have hc : q.coeff 0 * (10 * q.coeff 0 - q.coeff 0 ^ 3) = 1 := by linear_combination -h0
    rcases Int.eq_one_or_neg_one_of_mul_eq_one' hc with ⟨h, h'⟩ | ⟨h, h'⟩ <;>
      rw [h] at h' <;> norm_num at h'
  · exact biq_no_int_factorisation ⟨q.coeff 1, q.coeff 0, f.coeff 1, f.coeff 0, fun x => by
      rw [hev, eval_monic_deg_two hq hd, eval_monic_deg_two hfm (by omega)]⟩

/-- **`x⁴ - 10x² + 1` is irreducible over `ℚ`** (Gauss's lemma), although by
`biq_reducible_mod_every_prime` it is reducible modulo every prime. -/
theorem biqPolyQ_irreducible : Irreducible (biqPolyZ.map (Int.castRingHom ℚ)) :=
  (IsPrimitive.Int.irreducible_iff_irreducible_map_cast biqPolyZ_monic.isPrimitive).1
    biqPolyZ_irreducible

/-- **Local–global contrast.**  Irreducible over `ℚ`, yet a product of two monic
quadratics modulo every prime `p` — the Galois group `V₄` has no element of order `4`. -/
theorem biq_local_global :
    Irreducible (biqPolyZ.map (Int.castRingHom ℚ)) ∧
      ∀ p : ℕ, p.Prime → ∃ u v w z : ZMod p,
        ∀ x, x ^ 4 - 10 * x ^ 2 + 1 = (x ^ 2 + u * x + v) * (x ^ 2 + w * x + z) :=
  ⟨biqPolyQ_irreducible, fun p hp => by haveI := Fact.mk hp; exact biq_reducible_mod_every_prime⟩

end Global

end BiquadraticTypeChannel