/-
# The pure cubic `x³ - 2`: the sign character has conductor 3 (paper 112)

The `S₃`-field `ℚ(∛2, ζ₃)` (discriminant of `x³ - 2` is `-108 = -3 · 6²`) has its
sign character at conductor `3`.  We prove this *unconditionally at every prime*:

* `cube_injective_of_mod_three_eq_two` : for `p ≡ 2 (mod 3)`, cubing is a
  bijection of `𝔽_p`, so every `x³ = a` has exactly one root.
* `card_cube_roots_of_mod_three_eq_one` : for `p ≡ 1 (mod 3)` and `a ≠ 0`, the
  equation `x³ = a` has `0` or `3` roots.
* `card_cube_two_eq_one_iff` : for primes `p > 3`,
  `#{x ∈ 𝔽_p : x³ = 2} = 1  ↔  p ≡ 2 (mod 3)`: the splitting type of `x³ - 2`
  determines `p mod 3` and conversely determines the sign bit.
* `isSquare_neg_three_iff` : `-3` is a square mod `p > 3` iff `p ≡ 1 (mod 3)`,
  obtained *from the cubic* via the discriminant sign law.
* `channel_pure_cubic` : on any finite set of primes `> 3`, the splitting-type
  channel satisfies `I(p mod 3 ; T) = H(p mod 3)`; on a balanced sample
  (`{5, 7, 11, 13}`) it is exactly one bit.
* `trinomial_sign_not_mod_three` : the **correction** — for `x³ + x + 1`
  (discriminant `-31`) the sign bit is *not* a function of `p mod 3`:
  `p = 5` and `p = 11` are both `≡ 2 (mod 3)` but have `0` resp. `1` roots.
  The law is universal at the level of the group `S₃`, not at the level of the
  conductor.
-/
import Novelty.S3SignChannelUniversal
import Novelty.CubicDiscriminantSignLaw

namespace PureCubicSignConductor

open Finset CyclicTypeChannel

/-! ## 1. `p ≡ 2 (mod 3)`: cubing is a bijection -/

section Two

variable {p : ℕ} [hp : Fact p.Prime]

/-- `x ^ (2p - 1) = x` in `𝔽_p`. -/
lemma pow_two_mul_sub_one (x : ZMod p) : x ^ (2 * p - 1) = x := by
  have hp1 := hp.out.one_lt
  rcases eq_or_ne x 0 with rfl | hx
  · exact zero_pow (by omega)
  · have : 2 * p - 1 = p + (p - 1) := by omega
    rw [this, pow_add, ZMod.pow_card, ZMod.pow_card_sub_one_eq_one hx, mul_one]

theorem cube_injective_of_mod_three_eq_two (h3 : p % 3 = 2) :
    Function.Injective (fun x : ZMod p => x ^ 3) := by
  intro x y hxy
  simp only at hxy
  have hk : 3 * ((2 * p - 1) / 3) = 2 * p - 1 := by omega
  rw [← pow_two_mul_sub_one x, ← pow_two_mul_sub_one y, ← hk, pow_mul, pow_mul, hxy]

theorem cube_bijective_of_mod_three_eq_two (h3 : p % 3 = 2) :
    Function.Bijective (fun x : ZMod p => x ^ 3) :=
  (Finite.injective_iff_bijective).1 (cube_injective_of_mod_three_eq_two h3)

/-- For `p ≡ 2 (mod 3)` every cube equation `x³ = a` has exactly one root. -/
theorem card_cube_roots_of_mod_three_eq_two (h3 : p % 3 = 2) (a : ZMod p) :
    #{x : ZMod p | x ^ 3 = a} = 1 := by
  obtain ⟨x0, hx0⟩ := (cube_bijective_of_mod_three_eq_two h3).2 a
  rw [card_eq_one]
  refine ⟨x0, ?_⟩
  ext y
  simp only [mem_filter, mem_univ, true_and, mem_singleton]
  constructor
  · intro hy
    exact cube_injective_of_mod_three_eq_two h3 (hy.trans hx0.symm)
  · rintro rfl; exact hx0

end Two

/-! ## 2. `p ≡ 1 (mod 3)`: `0` or `3` roots -/

section One

variable {p : ℕ} [hp : Fact p.Prime]

/-- A primitive cube root of unity in `𝔽_p` when `p ≡ 1 (mod 3)`. -/
lemma exists_primitive_cube_root (h3 : p % 3 = 1) :
    ∃ w : ZMod p, w ^ 3 = 1 ∧ w ≠ 1 := by
  haveI : Fact (Nat.Prime 3) := ⟨Nat.prime_three⟩
  have hdvd : 3 ∣ Fintype.card (ZMod p)ˣ := by
    rw [ZMod.card_units_eq_totient, Nat.totient_prime hp.out]
    omega
  obtain ⟨u, hu⟩ := exists_prime_orderOf_dvd_card 3 hdvd
  refine ⟨(u : ZMod p), ?_, ?_⟩
  · rw [← Units.val_pow_eq_pow_val, ← hu, pow_orderOf_eq_one, Units.val_one]
  · intro h1
    have : u = 1 := Units.ext h1
    rw [this, orderOf_one] at hu
    norm_num at hu

lemma cube_root_sum (w : ZMod p) (hw3 : w ^ 3 = 1) (hw1 : w ≠ 1) : w ^ 2 + w + 1 = 0 := by
  have : (w - 1) * (w ^ 2 + w + 1) = 0 := by linear_combination hw3
  exact (mul_eq_zero.1 this).resolve_left (sub_ne_zero.2 hw1)

/-- For `p ≡ 1 (mod 3)` and `a ≠ 0`, `x³ = a` has either no root or exactly three. -/
theorem card_cube_roots_of_mod_three_eq_one (h3 : p % 3 = 1) {a : ZMod p} (ha : a ≠ 0) :
    #{x : ZMod p | x ^ 3 = a} = 0 ∨ #{x : ZMod p | x ^ 3 = a} = 3 := by
  by_cases hex : ∃ x0 : ZMod p, x0 ^ 3 = a
  · right
    obtain ⟨x0, hx0⟩ := hex
    obtain ⟨w, hw3, hw1⟩ := exists_primitive_cube_root h3
    have hs := cube_root_sum w hw3 hw1
    have hx0ne : x0 ≠ 0 := by rintro rfl; apply ha; rw [← hx0]; ring
    have hw0 : w ≠ 0 := by rintro rfl; norm_num at hw3
    have hw2 : w ^ 2 ≠ 1 := by
      intro h; apply hw1
      have : w * w ^ 2 = w := by rw [h, mul_one]
      rw [← pow_succ', hw3] at this; exact this.symm
    have hww : w ≠ w ^ 2 := by
      intro h; apply hw1
      have : w * (w - 1) = 0 := by linear_combination -h
      exact sub_eq_zero.1 ((mul_eq_zero.1 this).resolve_left hw0)
    rw [card_eq_three]
    refine ⟨x0, x0 * w, x0 * w ^ 2, ?_, ?_, ?_, ?_⟩
    · intro h; apply hw1
      exact (mul_left_cancel₀ hx0ne (h.symm.trans (mul_one x0).symm))
    · intro h; apply hw2
      exact (mul_left_cancel₀ hx0ne (h.symm.trans (mul_one x0).symm))
    · intro h; exact hww (mul_left_cancel₀ hx0ne h)
    · ext y
      simp only [mem_filter, mem_univ, true_and, mem_insert, mem_singleton]
      constructor
      · intro hy
        set t := y / x0
        have hyt : y = x0 * t := by simp [t, mul_div_cancel₀ _ hx0ne]
        have ht3 : t ^ 3 = 1 := by
          have : x0 ^ 3 * t ^ 3 = x0 ^ 3 * 1 := by rw [mul_one, ← mul_pow, ← hyt, hy, hx0]
          exact mul_left_cancel₀ (pow_ne_zero 3 hx0ne) this
        have hfac : (t - 1) * (t - w) * (t - w ^ 2) = 0 := by
          linear_combination ht3 - t ^ 2 * hs + t * hs + t * hw3 - hw3
        rcases mul_eq_zero.1 hfac with h12 | h3'
        · rcases mul_eq_zero.1 h12 with h1 | h2
          · left; rw [hyt, sub_eq_zero.1 h1, mul_one]
          · right; left; rw [hyt, sub_eq_zero.1 h2]
        · right; right; rw [hyt, sub_eq_zero.1 h3']
      · rintro (rfl | rfl | rfl)
        · exact hx0
        · rw [mul_pow, hw3, mul_one, hx0]
        · rw [mul_pow, ← pow_mul, show 2 * 3 = 3 * 2 from rfl, pow_mul, hw3, one_pow,
            mul_one, hx0]
  · left
    rw [card_eq_zero, filter_eq_empty_iff]
    intro x _ hx
    exact hex ⟨x, hx⟩

end One

/-! ## 3. The splitting type of `x³ - 2` determines the sign bit, and vice versa -/

section Law

variable {p : ℕ} [hp : Fact p.Prime]

lemma natCast_ne_zero_of_lt {n : ℕ} (hn : 0 < n) (hnp : n < p) : (n : ZMod p) ≠ 0 := by
  rw [Ne, ZMod.natCast_eq_zero_iff]
  intro h
  exact absurd (Nat.le_of_dvd hn h) (by omega)

lemma mod_three_of_gt (hp3 : 3 < p) : p % 3 = 1 ∨ p % 3 = 2 := by
  have : p % 3 ≠ 0 := by
    intro h
    have h3 : 3 ∣ p := Nat.dvd_of_mod_eq_zero h
    rcases (Nat.Prime.eq_one_or_self_of_dvd hp.out 3 h3) with h | h <;> omega
  omega

/-- **The splitting type of `x³ - 2` detects `p mod 3`.**  For primes `p > 3`,
`x³ - 2` has exactly one root mod `p` (type `1 + 2`, odd Frobenius) iff `p ≡ 2 (mod 3)`. -/
theorem card_cube_two_eq_one_iff (hp3 : 3 < p) :
    #{x : ZMod p | x ^ 3 = 2} = 1 ↔ p % 3 = 2 := by
  constructor
  · intro h
    rcases mod_three_of_gt hp3 with h1 | h2
    · have h20 : (2 : ZMod p) ≠ 0 := by
        exact_mod_cast natCast_ne_zero_of_lt (n := 2) (by norm_num) (by omega)
      rcases card_cube_roots_of_mod_three_eq_one h1 h20 with h0 | h0 <;> omega
    · exact h2
  · intro h
    exact card_cube_roots_of_mod_three_eq_two h 2

/-- **Quadratic character of `-3` from the pure cubic.**  For primes `p > 3`, `-3` is a
square mod `p` iff `p ≡ 1 (mod 3)`.  The forward direction is derived from the
discriminant sign law applied to `x³ - 2` (discriminant `-108 = -3 · 6²`). -/
theorem isSquare_neg_three_iff (hp3 : 3 < p) : IsSquare (-3 : ZMod p) ↔ p % 3 = 1 := by
  have h2 : (2 : ZMod p) ≠ 0 := by
    exact_mod_cast natCast_ne_zero_of_lt (n := 2) (by norm_num) (by omega)
  have h3 : (3 : ZMod p) ≠ 0 := by
    exact_mod_cast natCast_ne_zero_of_lt (n := 3) (by norm_num) hp3
  constructor
  · rintro ⟨t, ht⟩
    rcases mod_three_of_gt hp3 with h1 | h32
    · exact h1
    exfalso
    obtain ⟨r, hr⟩ := (cube_bijective_of_mod_three_eq_two h32).2 2
    simp only at hr
    have hcr : CubicDiscriminantSignLaw.cubic 0 (-2) r = 0 := by
      simp [CubicDiscriminantSignLaw.cubic, hr]
    have hdisc : CubicDiscriminantSignLaw.disc (0 : ZMod p) (-2) = -3 * 6 ^ 2 := by
      simp [CubicDiscriminantSignLaw.disc]; ring
    have hΔ : CubicDiscriminantSignLaw.disc (0 : ZMod p) (-2) ≠ 0 := by
      rw [hdisc]
      have h6 : (6 : ZMod p) ≠ 0 := by
        have : (6 : ZMod p) = 2 * 3 := by norm_num
        rw [this]; exact mul_ne_zero h2 h3
      exact mul_ne_zero (neg_ne_zero.2 h3) (pow_ne_zero 2 h6)
    have hsq : IsSquare (CubicDiscriminantSignLaw.disc (0 : ZMod p) (-2)) :=
      ⟨6 * t, by rw [hdisc, ht]; ring⟩
    obtain ⟨s, hsr, hs⟩ :=
      (CubicDiscriminantSignLaw.isSquare_disc_iff h2 0 (-2) r hcr hΔ).1 hsq
    apply hsr
    apply cube_injective_of_mod_three_eq_two h32
    simp only [CubicDiscriminantSignLaw.cubic] at hs
    simp only [hr]
    linear_combination hs
  · intro h1
    obtain ⟨w, hw3, hw1⟩ := exists_primitive_cube_root h1
    exact ⟨2 * w + 1, by linear_combination (-4) * cube_root_sum w hw3 hw1⟩

end Law

/-! ## 4. The channel `I(p mod 3 ; T) ` over sets of primes -/

/-- The splitting-type statistic of `x³ - 2` at `p`: the number of roots mod `p`. -/
noncomputable def cubeType (p : ℕ) : ℕ := Nat.card {x : ZMod p // x ^ 3 = 2}

lemma cubeType_eq (p : ℕ) [Fact p.Prime] : cubeType p = #{x : ZMod p | x ^ 3 = 2} := by
  rw [cubeType, Nat.card_eq_fintype_card, Fintype.card_subtype]

lemma cubeType_eq_one_iff {p : ℕ} (hp : p.Prime) (hp3 : 3 < p) :
    cubeType p = 1 ↔ p % 3 = 2 := by
  haveI := Fact.mk hp
  rw [cubeType_eq]
  exact card_cube_two_eq_one_iff hp3

/-- On primes `> 3`, `p mod 3` is a function of the splitting type of `x³ - 2`. -/
lemma mod_three_eq_of_cubeType_eq {p q : ℕ} (hp : p.Prime) (hp3 : 3 < p) (hq : q.Prime)
    (hq3 : 3 < q) (h : cubeType p = cubeType q) : p % 3 = q % 3 := by
  have ep := cubeType_eq_one_iff hp hp3
  have eq := cubeType_eq_one_iff hq hq3
  haveI := Fact.mk hp; haveI := Fact.mk hq
  rcases mod_three_of_gt (p := p) hp3 with h1 | h1 <;>
    rcases mod_three_of_gt (p := q) hq3 with h2 | h2
  · omega
  · have := eq.2 h2; have := ep.1 (h.trans this); omega
  · have := ep.2 h1; have := eq.1 (h.symm.trans this); omega
  · omega

/-- **The pure-cubic channel.**  On any finite set of primes `> 3`, the splitting
type of `x³ - 2` reveals `p mod 3` completely: `I(p mod 3 ; T) = H(p mod 3)`. -/
theorem channel_pure_cubic (S : Finset ℕ) (hS : ∀ p ∈ S, p.Prime ∧ 3 < p) :
    mutInfo S (· % 3) cubeType = uEnt S (· % 3) :=
  S3SignChannelUniversal.mutInfo_eq_uEnt_of_factor S _ _ fun x hx y hy h =>
    mod_three_eq_of_cubeType_eq (hS x hx).1 (hS x hx).2 (hS y hy).1 (hS y hy).2 h

/-- On the balanced sample `{5, 7, 11, 13}` the channel is exactly one bit. -/
theorem channel_pure_cubic_one_bit :
    mutInfo ({5, 7, 11, 13} : Finset ℕ) (· % 3) cubeType = 1 := by
  rw [channel_pure_cubic _ (by
    intro p hp; simp only [mem_insert, mem_singleton] at hp
    rcases hp with rfl | rfl | rfl | rfl <;> norm_num)]
  rw [S3SignChannelUniversal.uEnt_const_fiber _ _ 2 (by decide) (by decide)]
  rw [show (#({5, 7, 11, 13} : Finset ℕ) : ℝ) = 4 by rfl, lb_4]
  norm_num

/-- **Semiprime pair channel.**  For pairs of primes `> 3`, the pair of splitting
types `(T p, T q)` determines the residue `p q mod 3` of the semiprime. -/
theorem pair_channel_pure_cubic (S : Finset (ℕ × ℕ))
    (hS : ∀ x ∈ S, x.1.Prime ∧ 3 < x.1 ∧ x.2.Prime ∧ 3 < x.2) :
    mutInfo S (fun x => x.1 * x.2 % 3) (fun x => (cubeType x.1, cubeType x.2))
      = uEnt S (fun x => x.1 * x.2 % 3) := by
  refine S3SignChannelUniversal.mutInfo_eq_uEnt_of_factor S _ _ fun x hx y hy h => ?_
  simp only [Prod.mk.injEq] at h
  obtain ⟨a1, a2, a3, a4⟩ := hS x hx
  obtain ⟨b1, b2, b3, b4⟩ := hS y hy
  rw [Nat.mul_mod, mod_three_eq_of_cubeType_eq a1 a2 b1 b2 h.1,
    mod_three_eq_of_cubeType_eq a3 a4 b3 b4 h.2, ← Nat.mul_mod]

/-- The semiprime pair channel on `{5, 7}²` is exactly one bit. -/
theorem pair_channel_pure_cubic_one_bit :
    mutInfo ({5, 7} ×ˢ {5, 7} : Finset (ℕ × ℕ)) (fun x => x.1 * x.2 % 3)
      (fun x => (cubeType x.1, cubeType x.2)) = 1 := by
  rw [pair_channel_pure_cubic _ (by
    rintro ⟨a, b⟩ hx; simp only [mem_product, mem_insert, mem_singleton] at hx
    rcases hx with ⟨rfl | rfl, rfl | rfl⟩ <;> norm_num)]
  rw [S3SignChannelUniversal.uEnt_const_fiber _ _ 2 (by decide) (by decide)]
  rw [show (#({5, 7} ×ˢ {5, 7} : Finset (ℕ × ℕ)) : ℝ) = 4 by rfl, lb_4]
  norm_num

/-! ## 5. The correction: the conductor is NOT universal -/

/-- The splitting-type statistic of `x³ + x + 1` (discriminant `-31`). -/
noncomputable def trinomialType (p : ℕ) : ℕ := Nat.card {x : ZMod p // x ^ 3 + x + 1 = 0}

/-- For `x³ + x + 1`, the sign bit is governed by the quadratic character of the
discriminant `-31`: at a prime `p ∉ {2, 31}` where it has a root, the root is unique
(odd Frobenius) iff `-31` is a non-square mod `p`. -/
theorem trinomial_unique_root_iff {p : ℕ} [Fact p.Prime] (hp2 : p ≠ 2)
    (hp31 : (31 : ZMod p) ≠ 0) (r : ZMod p) (hr : r ^ 3 + r + 1 = 0) :
    (∀ s : ZMod p, s ^ 3 + s + 1 = 0 → s = r) ↔ ¬ IsSquare (-31 : ZMod p) := by
  have h2 : (2 : ZMod p) ≠ 0 := by
    intro h
    have : ((2 : ℕ) : ZMod p) = 0 := by exact_mod_cast h
    rw [ZMod.natCast_eq_zero_iff] at this
    exact hp2 ((Nat.prime_dvd_prime_iff_eq (Fact.out) Nat.prime_two).1 this)
  have hdisc : CubicDiscriminantSignLaw.disc (1 : ZMod p) 1 = -31 := by
    simp [CubicDiscriminantSignLaw.disc]; ring
  have hcr : CubicDiscriminantSignLaw.cubic 1 1 r = 0 := by
    simp [CubicDiscriminantSignLaw.cubic, hr]
  have key := CubicDiscriminantSignLaw.isSquare_disc_iff h2 1 1 r hcr
    (by rw [hdisc]; exact neg_ne_zero.2 hp31)
  rw [hdisc] at key
  rw [key]
  simp only [CubicDiscriminantSignLaw.cubic, one_mul, not_exists, not_and]
  constructor
  · intro h s hsr hs; exact hsr (h s hs)
  · intro h s hs; by_contra hsr; exact h s hsr hs

/-- **The conductor is not universal.**  `5 ≡ 11 ≡ 2 (mod 3)`, yet `x³ + x + 1` has
no root mod `5` (a 3-cycle, even) and exactly one root mod `11` (a transposition,
odd).  So for `x³ + x + 1` the sign bit is not a function of `p mod 3`, in contrast
with `x³ - 2`: the shape of the channel is universal, the conductor is not. -/
theorem trinomial_sign_not_mod_three :
    5 % 3 = 11 % 3 ∧ trinomialType 5 = 0 ∧ trinomialType 11 = 1 ∧
      cubeType 5 = 1 ∧ cubeType 11 = 1 := by
  refine ⟨rfl, ?_, ?_, ?_, ?_⟩
  · rw [trinomialType, Nat.card_eq_fintype_card]; decide
  · rw [trinomialType, Nat.card_eq_fintype_card]; decide
  · exact (cubeType_eq_one_iff (by norm_num) (by norm_num)).2 rfl
  · exact (cubeType_eq_one_iff (by norm_num) (by norm_num)).2 rfl

/-- Consequently `-31` is a non-square mod `11`, read off from the splitting type. -/
theorem neg_31_not_square_mod_11 : ¬ IsSquare (-31 : ZMod 11) := by
  have h31 : (31 : ZMod 11) ≠ 0 := by decide
  have hr : (2 : ZMod 11) ^ 3 + 2 + 1 = 0 := by decide
  have huniq : ∀ s : ZMod 11, s ^ 3 + s + 1 = 0 → s = 2 := by decide
  haveI : Fact (Nat.Prime 11) := ⟨by norm_num⟩
  exact (trinomial_unique_root_iff (p := 11) (by norm_num) h31 2 hr).1 huniq

end PureCubicSignConductor