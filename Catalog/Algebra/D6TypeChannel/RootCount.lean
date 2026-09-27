/-
# Splitting types of `x⁶ - 2` modulo a prime

Number-theoretic side of the *DEGREE-6-NONABELIAN* experiment (paper 122).

The *type* of a prime `p ≥ 5` is `T(p) = #{x ∈ 𝔽_p : x⁶ = 2}`, the number of roots
of `x⁶ - 2` in `𝔽_p`.  The experiment observed only the three values `{0, 2, 6}`.
This file proves this unconditionally and explains the split along the conductor
`3`:

* `card_pow_eq_cyclic` — in a finite cyclic group of order `n`, the equation
  `x^k = a` has either `0` or exactly `gcd(n, k)` solutions;
* `card_pow_eq_field` — hence in a finite field `𝔽_q`, for `a ≠ 0`, `x^k = a`
  has `0` or `gcd(q-1, k)` solutions;
* `rootCount6_mod3_one` — **rotation half**: for `p ≡ 1 (mod 3)`, `T(p) ∈ {0, 6}`;
* `rootCount6_mod3_two` — **reflection half, pinned**: for `p ≡ 2 (mod 3)`,
  `p ≠ 2` (note `2 ≡ 2 (mod 3)` itself), `T(p) = 2` if `p ≡ ±1 (mod 8)` and `T(p) = 0` otherwise; the
  reflection half of the channel is a function of `p mod 24`;
* `rootCount6_mod24` — the complete congruence picture: `p mod 24` pins the type
  on six of the eight unit classes and leaves only the classes `1, 7 (mod 24)`
  ambiguous between `0` and `6` (the genuinely non-abelian residue: `2` a
  sixth power, not a congruence condition);
* `rootCount6_eq_card_roots` — `T(p)` is the number of distinct roots of the
  polynomial `X⁶ - 2 ∈ 𝔽_p[X]`.

Together with `Algebra.D6TypeChannel.Group` this matches the `D₆` fixed-point law
exactly: rotations have `0` or `6` fixed roots, reflections `0` or `2`.
-/
import Mathlib

namespace D6TypeChannel

open Finset Polynomial

/-! ## 1. Solutions of `x^k = a` in a cyclic group -/

/-- In a finite cyclic group of order `n`, `x^k = a` has `0` or `gcd(n, k)`
solutions. -/
theorem card_pow_eq_cyclic {G : Type*} [CommGroup G] [IsCyclic G] [Fintype G] [DecidableEq G]
    (k : ℕ) (a : G) :
    #{x : G | x ^ k = a} = 0 ∨ #{x : G | x ^ k = a} = Nat.gcd (Fintype.card G) k := by
  by_cases ha : a ∈ Set.range (powMonoidHom k : G →* G)
  · right
    have h := MonoidHom.card_fiber_eq_of_mem_range (powMonoidHom k : G →* G) (y := 1) ha ⟨1, by simp⟩
    simp only [powMonoidHom_apply] at h
    rw [h]
    have hk := IsCyclic.card_powMonoidHom_ker G k
    simp only [Nat.card_eq_fintype_card] at hk
    rw [← hk, ← Fintype.card_coe]
    exact Fintype.card_congr (Equiv.subtypeEquivRight (fun x => by simp [MonoidHom.mem_ker]))
  · left
    rw [card_eq_zero, filter_eq_empty_iff]
    intro x _ hx
    exact ha ⟨x, by simpa using hx⟩

/-- In a finite field with `q` elements, for `a ≠ 0` and `k ≥ 1`, the equation
`x^k = a` has `0` or `gcd(q-1, k)` solutions. -/
theorem card_pow_eq_field {K : Type*} [Field K] [Fintype K] [DecidableEq K]
    {k : ℕ} (hk : 0 < k) {a : K} (ha : a ≠ 0) :
    #{x : K | x ^ k = a} = 0 ∨ #{x : K | x ^ k = a} = Nat.gcd (Fintype.card K - 1) k := by
  have himg : ({x : K | x ^ k = a} : Finset K) =
      ({u : Kˣ | u ^ k = Units.mk0 a ha} : Finset Kˣ).map ⟨Units.val, Units.val_injective⟩ := by
    ext x
    simp only [mem_filter, mem_univ, true_and, mem_map, Function.Embedding.coeFn_mk]
    constructor
    · intro hx
      have hx0 : x ≠ 0 := by
        rintro rfl
        rw [zero_pow hk.ne'] at hx
        exact ha hx.symm
      exact ⟨Units.mk0 x hx0, by ext; simp [hx], rfl⟩
    · rintro ⟨u, hu, rfl⟩
      have := congrArg Units.val hu
      simpa using this
  rw [himg, card_map, ← Fintype.card_units]
  exact card_pow_eq_cyclic k _

/-! ## 2. The sextic `x⁶ - 2` -/

/-- The splitting type of `p` for `x⁶ - 2`: the number of roots in `𝔽_p`. -/
def rootCount6 (p : ℕ) [NeZero p] : ℕ := #{x : ZMod p | x ^ 6 = 2}

variable {p : ℕ} [hp : Fact p.Prime]

/-- `T(p)` is the number of distinct roots of the polynomial `X⁶ - 2` over `𝔽_p`. -/
theorem rootCount6_eq_card_roots :
    ((X ^ 6 - C 2 : (ZMod p)[X]).roots.toFinset).card = rootCount6 p := by
  unfold rootCount6
  congr 1
  ext x
  rw [Multiset.mem_toFinset, mem_roots (X_pow_sub_C_ne_zero (by norm_num) _)]
  simp [sub_eq_zero]

lemma two_ne_zero_of_ne_two (hp2 : p ≠ 2) : (2 : ZMod p) ≠ 0 := by
  intro h
  have : (p : ℕ) ∣ 2 := by
    have := (ZMod.natCast_eq_zero_iff 2 p).1 (by exact_mod_cast h)
    exact this
  rcases (Nat.dvd_prime Nat.prime_two).1 this with h1 | h2
  · exact hp.out.one_lt.ne' h1
  · exact hp2 h2

/-- The two possible values of `T(p)` for an odd prime: `0` or `gcd(p - 1, 6)`. -/
theorem rootCount6_dichotomy (hp2 : p ≠ 2) :
    rootCount6 p = 0 ∨ rootCount6 p = Nat.gcd (p - 1) 6 := by
  have h := card_pow_eq_field (K := ZMod p) (k := 6) (by norm_num) (two_ne_zero_of_ne_two hp2)
  rwa [ZMod.card] at h

/-- **Rotation half.** For `p ≡ 1 (mod 3)` the type is `0` or `6`. -/
theorem rootCount6_mod3_one (h3 : p % 3 = 1) : rootCount6 p = 0 ∨ rootCount6 p = 6 := by
  have hp2 : p ≠ 2 := by rintro rfl; norm_num at h3
  have hodd : p % 2 = 1 := by
    rcases hp.out.eq_two_or_odd with h | h
    · exact absurd h hp2
    · exact h
  have hg : Nat.gcd (p - 1) 6 = 6 := by
    apply Nat.gcd_eq_right
    have h1 := hp.out.one_lt
    omega
  rw [← hg]
  exact rootCount6_dichotomy hp2

/-- Sixth roots of `2` exist exactly when `2` is a square, provided that cubing is
a bijection (`p ≡ 2 (mod 3)`). -/
lemma exists_sixth_root_iff_isSquare (hp2 : p ≠ 2) (h3 : p % 3 = 2) :
    (∃ x : ZMod p, x ^ 6 = 2) ↔ IsSquare (2 : ZMod p) := by
  constructor
  · rintro ⟨x, hx⟩
    exact ⟨x ^ 3, by rw [← hx]; ring⟩
  · rintro ⟨y, hy⟩
    have hy0 : y ≠ 0 := by
      rintro rfl
      exact two_ne_zero_of_ne_two hp2 (by simpa using hy)
    have h1 := hp.out.one_lt
    obtain ⟨e, he⟩ : ∃ e, 3 * e = 2 * (p - 1) + 1 := ⟨(2 * p - 1) / 3, by omega⟩
    refine ⟨y ^ e, ?_⟩
    have hf : y ^ (p - 1) = 1 := ZMod.pow_card_sub_one_eq_one hy0
    calc (y ^ e) ^ 6 = (y ^ (3 * e)) ^ 2 := by ring
      _ = (y ^ (p - 1) * y ^ (p - 1) * y) ^ 2 := by rw [he]; ring
      _ = 2 := by rw [hf, hy]; ring

/-- **Reflection half, pinned by `p mod 24`.** For `p ≡ 2 (mod 3)` the type is `2`
if `p ≡ ±1 (mod 8)` and `0` otherwise. -/
theorem rootCount6_mod3_two (hp2 : p ≠ 2) (h3 : p % 3 = 2) :
    rootCount6 p = if p % 8 = 1 ∨ p % 8 = 7 then 2 else 0 := by
  have hodd : p % 2 = 1 := by
    rcases hp.out.eq_two_or_odd with h | h
    · exact absurd h hp2
    · exact h
  have hg : Nat.gcd (p - 1) 6 = 2 := by
    have h1 := hp.out.one_lt
    have hd : Nat.gcd (p - 1) 6 ∣ 6 := Nat.gcd_dvd_right _ _
    have h2 : 2 ∣ Nat.gcd (p - 1) 6 := Nat.dvd_gcd (by omega) (by norm_num)
    have h3' : ¬ 3 ∣ Nat.gcd (p - 1) 6 := fun h =>
      absurd (h.trans (Nat.gcd_dvd_left _ _)) (by omega)
    have hdiv : Nat.gcd (p - 1) 6 ∈ Nat.divisors 6 := Nat.mem_divisors.2 ⟨hd, by norm_num⟩
    have : Nat.divisors 6 = {1, 2, 3, 6} := by decide
    rw [this] at hdiv
    simp only [Finset.mem_insert, Finset.mem_singleton] at hdiv
    rcases hdiv with h | h | h | h <;> omega
  have hdich := rootCount6_dichotomy hp2
  rw [hg] at hdich
  have hsq := ZMod.exists_sq_eq_two_iff hp2
  have hne : rootCount6 p ≠ 0 ↔ ∃ x : ZMod p, x ^ 6 = 2 := by
    unfold rootCount6
    rw [Ne, card_eq_zero, filter_eq_empty_iff]
    simp
  split_ifs with h8
  · rcases hdich with h0 | h2
    · exact absurd h0 (hne.2 ((exists_sixth_root_iff_isSquare hp2 h3).2 (hsq.2 h8)))
    · exact h2
  · rcases hdich with h0 | h2
    · exact h0
    · exfalso
      exact h8 (hsq.1 ((exists_sixth_root_iff_isSquare hp2 h3).1 (hne.1 (by omega))))

/-- If `2` is not a square mod `p`, then `x⁶ - 2` has no root mod `p`. -/
theorem rootCount6_eq_zero_of_not_square (hsq : ¬ IsSquare (2 : ZMod p)) : rootCount6 p = 0 := by
  unfold rootCount6
  rw [card_eq_zero, filter_eq_empty_iff]
  intro x _ hx
  exact hsq ⟨x ^ 3, by rw [← hx]; ring⟩

/-- **The complete congruence picture at conductor `24`.**  For a prime `p ≥ 5`:
`p mod 24 ∈ {5, 11, 13, 19}` forces `T = 0`; `p mod 24 ∈ {17, 23}` forces `T = 2`;
`p mod 24 ∈ {1, 7}` leaves `T ∈ {0, 6}` (undetermined by any congruence). -/
theorem rootCount6_mod24 (h5 : 5 ≤ p) :
    ((p % 24 = 5 ∨ p % 24 = 11 ∨ p % 24 = 13 ∨ p % 24 = 19) → rootCount6 p = 0) ∧
    ((p % 24 = 17 ∨ p % 24 = 23) → rootCount6 p = 2) ∧
    ((p % 24 = 1 ∨ p % 24 = 7) → rootCount6 p = 0 ∨ rootCount6 p = 6) := by
  have hp2 : p ≠ 2 := by omega
  have hsq := ZMod.exists_sq_eq_two_iff hp2
  refine ⟨fun h => ?_, fun h => ?_, fun h => ?_⟩
  · apply rootCount6_eq_zero_of_not_square
    rw [hsq]
    omega
  · rw [rootCount6_mod3_two hp2 (by omega), if_pos (by omega)]
  · exact rootCount6_mod3_one (by omega)

/-- A kernel-checked sanity table (consistent with `rootCount6_mod24`):
`31` is the least prime `p ≥ 5` with `T = 6` (`2 ≡ 2^6` because `2^5 ≡ 1 mod 31`);
the primes `7, 13, 19` (`≡ 1 mod 3`) have `T = 0`; `23` and `47` (`≡ 23 mod 24`)
have `T = 2`; `5, 11` have `T = 0`. -/
theorem rootCount6_table :
    rootCount6 5 = 0 ∧ rootCount6 7 = 0 ∧ rootCount6 11 = 0 ∧ rootCount6 13 = 0 ∧
    rootCount6 19 = 0 ∧ rootCount6 23 = 2 ∧ rootCount6 31 = 6 ∧ rootCount6 47 = 2 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> decide

end D6TypeChannel