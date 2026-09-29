module

public import Mathlib

/-!
# UNIVERSAL-S3-TEST (paper 111): root counts of `x^n - c` over finite fields

The round-32 S₃ test was run on the wrong polynomial: `x⁵ - 2` (Galois group `F₂₀`) instead
of `x³ - 2` (Galois group `S₃`).  This file proves exactly what a single-prime root-count
measurement can and cannot see.

* `rootSet_card_le` — `x^n = c` has at most `n` solutions in a field.
* `rootSet_card_dichotomy` — for `c ≠ 0` the solution count is `0` or `#μ_n` (a coset of the
  `n`-th roots of unity): the only possible root counts of `x⁵ - 2` are `0, 1, 5`-type values,
  those of `x³ - 2` are `0, 1, 3`-type values.
* `rootSet_card_eq_one_of_coprime` — if `gcd(n, q - 1) = 1` there is **exactly one** root:
  `x ↦ x^n` is a bijection of `𝔽_q`.
* `quintic_one_root`, `cubic_one_root` — the "inert" primes: `p ≢ 1 (mod 5)` resp.
  `p ≡ 2 (mod 3)` give exactly one root.
* `rootSet_one_card_of_dvd`, `rootSet_card_alphabet` — for a prime exponent `ℓ` and `c ≠ 0`
  the root count lies in the **alphabet `{0, 1, ℓ}`**: `{0,1,3}` for the intended cubic,
  `{0,1,5}` for the accidental quintic.  The alphabets share `0, 1` and differ only in the top
  letter.
* `sum_rootSet_card_sq` — the second moment over constants is `1 + (q - 1)·#μ_n`: *not*
  universal, in contrast with the Chebotarev second moment `2` of `AGL(1,q)`.
* `sum_rootSet_card` — **universal mean**: summed over all constants `c`, the root counts of
  `x^n - c` total exactly `q`, independent of `n`.
* `dial23_indistinguishable` — at the `S₃b@23` prime both polynomials have exactly one root:
  the wrong polynomial is invisible there.
* `dial31_separates` — at the `S₃a@31` prime `x³ - 2` has `3` roots and `x⁵ - 2` has none.
* `quintic_five_roots_151`, `cubic_never_five` — `p = 151` is a prime where `x⁵ - 2` has five
  roots, a count the cubic can never produce: a single-prime certificate of the wrong
  polynomial.

-- !-- Lab Notes -- !--
Experiment (`ComputationalEvidence.md`): over primes `7 ≤ p < 400`, root counts of `x⁵-2`
  lie in `{0,1,5}` (`14/58/3`) and of `x³-2` in `{0,1,3}` (`26/38/11`); the first primes with
  five roots of `x⁵-2` are `151, 241, 251`; roots mod `151`: `22, 25, 49, 90, 116`.
-/

@[expose] public section

namespace UniversalS3Test

open Finset

variable {F : Type*} [Field F] [Fintype F] [DecidableEq F]

/-- Solutions of `x^n = c` in `F`. -/
def rootSet (n : ℕ) (c : F) : Finset F := univ.filter (fun x => x ^ n = c)

omit [Fintype F] [DecidableEq F] in
lemma mem_rootSet_iff (n : ℕ) (c x : F) [Fintype F] [DecidableEq F] :
    x ∈ rootSet n c ↔ x ^ n = c := by simp [rootSet]

/-- At most `n` roots. -/
theorem rootSet_card_le {n : ℕ} (hn : 0 < n) (c : F) : (rootSet n c).card ≤ n := by
  classical
  have hsub : rootSet n c ⊆ (Polynomial.nthRoots n c).toFinset := by
    intro x hx
    rw [Multiset.mem_toFinset, Polynomial.mem_nthRoots hn]
    exact (mem_rootSet_iff n c x).mp hx
  calc (rootSet n c).card ≤ (Polynomial.nthRoots n c).toFinset.card := card_le_card hsub
    _ ≤ Multiset.card (Polynomial.nthRoots n c) := Multiset.toFinset_card_le _
    _ ≤ n := Polynomial.card_nthRoots n c

/-- **Coset dichotomy.** For `c ≠ 0` the solutions of `x^n = c` are empty or a translate of
the `n`-th roots of unity. -/
theorem rootSet_card_dichotomy {n : ℕ} (hn : n ≠ 0) {c : F} (hc : c ≠ 0) :
    (rootSet n c).card = 0 ∨ (rootSet n c).card = (rootSet n (1 : F)).card := by
  by_cases h : (rootSet n c).Nonempty
  · right
    obtain ⟨x0, hx0⟩ := h
    have hx0' : x0 ^ n = c := (mem_rootSet_iff n c x0).mp hx0
    have hne : x0 ≠ 0 := by
      rintro rfl
      rw [zero_pow hn] at hx0'; exact hc hx0'.symm
    symm
    refine card_nbij' (fun z => x0 * z) (fun y => y / x0) ?_ ?_ ?_ ?_
    · intro z hz
      have hz' : z ^ n = 1 := (mem_rootSet_iff n 1 z).mp hz
      simp only [coe_filter, rootSet, Set.mem_setOf_eq, mem_univ, true_and] at *
      rw [mul_pow, hz', hx0', mul_one]
    · intro y hy
      have hy' : y ^ n = c := (mem_rootSet_iff n c y).mp hy
      simp only [coe_filter, rootSet, Set.mem_setOf_eq, mem_univ, true_and] at *
      rw [div_pow, hy', hx0', div_self hc]
    · intro z _; simp only; field_simp
    · intro y _; simp only; field_simp
  · left
    exact card_eq_zero.mpr (not_nonempty_iff_eq_empty.mp h)

/-- `x ↦ x^n` is injective on `𝔽_q` when `n ≠ 0` and `gcd(n, q - 1) = 1`. -/
theorem pow_injective_of_coprime {n : ℕ} (hn : n ≠ 0)
    (hco : Nat.Coprime n (Fintype.card F - 1)) :
    Function.Injective (fun x : F => x ^ n) := by
  intro x y hxy
  simp only at hxy
  by_cases hy : y = 0
  · subst hy
    rw [zero_pow hn] at hxy
    exact pow_eq_zero_iff hn |>.mp hxy
  · have h1 : (x / y) ^ n = 1 := by rw [div_pow, hxy, div_self (pow_ne_zero _ hy)]
    have hx : x ≠ 0 := by
      rintro rfl; rw [zero_pow hn] at hxy; exact hy (pow_eq_zero_iff hn |>.mp hxy.symm)
    have h2 : (x / y) ^ (Fintype.card F - 1) = 1 :=
      FiniteField.pow_card_sub_one_eq_one _ (div_ne_zero hx hy)
    have h3 : (x / y) ^ (Nat.gcd n (Fintype.card F - 1)) = 1 := pow_gcd_eq_one.mpr ⟨h1, h2⟩
    rw [hco, pow_one, div_eq_one_iff_eq hy] at h3
    exact h3

/-- **Inert primes:** if `gcd(n, q - 1) = 1` then `x^n = c` has exactly one root. -/
theorem rootSet_card_eq_one_of_coprime {n : ℕ} (hn : n ≠ 0)
    (hco : Nat.Coprime n (Fintype.card F - 1)) (c : F) : (rootSet n c).card = 1 := by
  have hbij : Function.Bijective (fun x : F => x ^ n) :=
    Finite.injective_iff_bijective.mp (pow_injective_of_coprime hn hco)
  obtain ⟨x, hx, huniq⟩ := hbij.existsUnique c
  rw [card_eq_one]
  refine ⟨x, ?_⟩
  ext y
  simp only [mem_rootSet_iff, mem_singleton]
  exact ⟨fun hy => huniq y hy, fun hy => hy ▸ hx⟩

/-- **Universal mean.** Summed over all constants `c`, the root counts of `x^n - c` total `q`:
the average root count is `1` for *every* exponent `n`. -/
theorem sum_rootSet_card (n : ℕ) : ∑ c : F, (rootSet n c).card = Fintype.card F := by
  rw [← card_univ, card_eq_sum_card_fiberwise (f := fun x : F => x ^ n) (t := univ)
    (fun _ _ => mem_univ _)]
  rfl

/-- Among the nonzero constants alone, the total is `q - 1` (for `n ≠ 0`). -/
theorem sum_rootSet_card_units {n : ℕ} (hn : n ≠ 0) :
    ∑ c ∈ univ.erase (0 : F), (rootSet n c).card = Fintype.card F - 1 := by
  have h := sum_rootSet_card (F := F) n
  rw [← add_sum_erase _ _ (mem_univ (0 : F))] at h
  have h0 : (rootSet n (0 : F)).card = 1 := by
    rw [card_eq_one]; refine ⟨0, ?_⟩; ext y
    simp [mem_rootSet_iff, pow_eq_zero_iff hn]
  omega

/-! ## The two polynomials over prime fields -/

section Prime

variable {p : ℕ} [hp : Fact p.Prime]

lemma coprime_prime_of_not_dvd {ℓ : ℕ} (hℓ : ℓ.Prime) (h : ¬ ℓ ∣ p - 1) :
    Nat.Coprime ℓ (Fintype.card (ZMod p) - 1) := by
  rw [ZMod.card]; exact (Nat.Prime.coprime_iff_not_dvd hℓ).mpr h

/-- `x⁵ - 2` has exactly one root mod `p` whenever `p ≢ 1 (mod 5)`. -/
theorem quintic_one_root (h : ¬ 5 ∣ p - 1) : (rootSet 5 (2 : ZMod p)).card = 1 :=
  rootSet_card_eq_one_of_coprime (by norm_num) (coprime_prime_of_not_dvd (by norm_num) h) _

/-- `x³ - 2` has exactly one root mod `p` whenever `p ≡ 2 (mod 3)`. -/
theorem cubic_one_root (h : p % 3 = 2) : (rootSet 3 (2 : ZMod p)).card = 1 :=
  rootSet_card_eq_one_of_coprime (by norm_num)
    (coprime_prime_of_not_dvd (by norm_num) (by omega)) _

end Prime

/-- The cubic can never show five roots: its root count is at most `3`. -/
theorem cubic_never_five (c : F) : (rootSet 3 c).card ≠ 5 := by
  have := rootSet_card_le (by norm_num : 0 < 3) c; omega

instance fact_prime_23 : Fact (Nat.Prime 23) := ⟨by norm_num⟩
instance fact_prime_31 : Fact (Nat.Prime 31) := ⟨by norm_num⟩
instance fact_prime_151 : Fact (Nat.Prime 151) := ⟨by norm_num⟩

/-- **Dial `S₃b@23`:** both the intended and the accidental polynomial have exactly one root —
the wrong polynomial is invisible at this prime. -/
theorem dial23_indistinguishable :
    (rootSet 3 (2 : ZMod 23)).card = 1 ∧ (rootSet 5 (2 : ZMod 23)).card = 1 :=
  ⟨cubic_one_root (by norm_num), quintic_one_root (by norm_num)⟩

/-- `x⁵ = 2` has no solution mod `31`: a root would force `2⁶ = x³⁰ = 1`, but `2⁶ = 2`. -/
theorem quintic_no_root_31 : (rootSet 5 (2 : ZMod 31)).card = 0 := by
  rw [card_eq_zero, eq_empty_iff_forall_notMem]
  intro x hx
  have hx' : x ^ 5 = 2 := (mem_rootSet_iff 5 2 x).mp hx
  have hx0 : x ≠ 0 := by rintro rfl; revert hx'; decide
  have h30 : x ^ 30 = 1 := by
    have := ZMod.pow_card_sub_one_eq_one hx0; simpa using this
  have : (2 : ZMod 31) ^ 6 = 1 := by rw [← hx', ← pow_mul]; exact h30
  revert this; decide

/-- `x³ = 2` has the three solutions `4, 7, 20` mod `31`. -/
theorem cubic_three_roots_31 : (rootSet 3 (2 : ZMod 31)).card = 3 := by
  apply le_antisymm (rootSet_card_le (by norm_num) _)
  have hsub : ({4, 7, 20} : Finset (ZMod 31)) ⊆ rootSet 3 2 := by
    intro x hx
    rw [mem_rootSet_iff]
    simp only [mem_insert, mem_singleton] at hx
    rcases hx with rfl | rfl | rfl <;> decide
  exact (card_le_card hsub).trans' (by decide)

/-- **Dial `S₃a@31`:** the intended cubic splits completely (3 roots) while the accidental
quintic has no root — here a single measurement separates the two polynomials. -/
theorem dial31_separates :
    (rootSet 3 (2 : ZMod 31)).card = 3 ∧ (rootSet 5 (2 : ZMod 31)).card = 0 :=
  ⟨cubic_three_roots_31, quintic_no_root_31⟩

/-- **Wrong-polynomial certificate:** mod `151`, `x⁵ - 2` has five roots
(`22, 25, 49, 90, 116`), which no cubic can exhibit. -/
theorem quintic_five_roots_151 : (rootSet 5 (2 : ZMod 151)).card = 5 := by
  apply le_antisymm (rootSet_card_le (by norm_num) _)
  have hsub : ({22, 25, 49, 90, 116} : Finset (ZMod 151)) ⊆ rootSet 5 2 := by
    intro x hx
    rw [mem_rootSet_iff]
    simp only [mem_insert, mem_singleton] at hx
    rcases hx with rfl | rfl | rfl | rfl | rfl <;> decide
  exact (card_le_card hsub).trans' (by decide)

/-- Consequently, at `p = 151` the observed root count of `x⁵ - 2` is not a possible root count
of `x³ - 2` (nor of any `x³ - c`). -/
theorem wrong_polynomial_detected_151 (c : ZMod 151) :
    (rootSet 5 (2 : ZMod 151)).card ≠ (rootSet 3 c).card := by
  rw [quintic_five_roots_151]; exact (cubic_never_five c).symm

/-! ## Alphabet and second moment over constants -/

section Alphabet

/-- If a prime `ℓ` divides `q - 1`, there are exactly `ℓ` roots of unity of order dividing `ℓ`. -/
theorem rootSet_one_card_of_dvd {ℓ : ℕ} [hℓ : Fact ℓ.Prime] (hd : ℓ ∣ Fintype.card F - 1) :
    (rootSet ℓ (1 : F)).card = ℓ := by
  have hdu : ℓ ∣ Fintype.card Fˣ := by rw [Fintype.card_units]; exact hd
  obtain ⟨g, hg⟩ := exists_prime_orderOf_dvd_card ℓ hdu
  have hprim : IsPrimitiveRoot (g : F) ℓ := by
    rw [← hg]; exact IsPrimitiveRoot.coe_units_iff.mpr (IsPrimitiveRoot.orderOf g)
  have heq : rootSet ℓ (1 : F) = Polynomial.nthRootsFinset ℓ (1 : F) := by
    ext x; rw [mem_rootSet_iff, Polynomial.mem_nthRootsFinset hℓ.out.pos]
  rw [heq, hprim.card_nthRootsFinset]

/-- **The root-count alphabet of `x^ℓ - c` (`ℓ` prime, `c ≠ 0`) is `{0, 1, ℓ}`:**
`1` at inert primes (`ℓ ∤ q - 1`) and `0` or `ℓ` at split primes (`ℓ ∣ q - 1`). -/
theorem rootSet_card_alphabet {ℓ : ℕ} [hℓ : Fact ℓ.Prime] {c : F} (hc : c ≠ 0) :
    (rootSet ℓ c).card = 0 ∨ (rootSet ℓ c).card = 1 ∨ (rootSet ℓ c).card = ℓ := by
  by_cases hd : ℓ ∣ Fintype.card F - 1
  · rcases rootSet_card_dichotomy hℓ.out.ne_zero hc with h | h
    · exact Or.inl h
    · exact Or.inr (Or.inr (h.trans (rootSet_one_card_of_dvd hd)))
  · exact Or.inr (Or.inl (rootSet_card_eq_one_of_coprime hℓ.out.ne_zero
      ((Nat.Prime.coprime_iff_not_dvd hℓ.out).mpr hd) c))


/-- **Second moment over constants is *not* universal.** Summed over all `c`, the squared root
counts of `x^n - c` total `1 + (q - 1)·#μ_n`.  Contrast with the Chebotarev (prime-averaged)
second moment of `AGL(1,q)`, which is `2` for every `q` (`affine_moment_two`). -/
theorem sum_rootSet_card_sq {n : ℕ} (hn : n ≠ 0) :
    ∑ c : F, (rootSet n c).card ^ 2 = 1 + (Fintype.card F - 1) * (rootSet n (1 : F)).card := by
  have hfib : ∑ c : F, (rootSet n c).card ^ 2 = ∑ x : F, (rootSet n (x ^ n)).card := by
    rw [← sum_fiberwise (s := univ) (g := fun x : F => x ^ n)
      (f := fun x => (rootSet n (x ^ n)).card)]
    refine sum_congr rfl (fun c _ => ?_)
    rw [sq, sum_congr rfl (g := fun _ => (rootSet n c).card), sum_const, smul_eq_mul]
    · rfl
    · intro x hx; rw [(mem_filter.mp hx).2]
  rw [hfib, ← add_sum_erase _ _ (mem_univ (0 : F))]
  have h0 : (rootSet n ((0 : F) ^ n)).card = 1 := by
    rw [zero_pow hn, card_eq_one]; refine ⟨0, ?_⟩; ext y
    simp [mem_rootSet_iff, pow_eq_zero_iff hn]
  rw [h0, sum_congr rfl (g := fun _ => (rootSet n (1 : F)).card), sum_const, smul_eq_mul,
    card_erase_of_mem (mem_univ _), card_univ]
  intro x hx
  have hx0 : x ≠ 0 := (mem_erase.mp hx).1
  rcases rootSet_card_dichotomy hn (pow_ne_zero n hx0) with h | h
  · exfalso
    have : x ∈ rootSet n (x ^ n) := (mem_rootSet_iff _ _ _).mpr rfl
    rw [card_eq_zero] at h; rw [h] at this; simp at this
  · exact h

end Alphabet

end UniversalS3Test

end