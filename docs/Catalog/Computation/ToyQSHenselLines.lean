import Mathlib
import Shared.QSRelationPoolRandom

/-!
# Hensel-lifted prime-power sieve lines for `x² - N`

Context (experiment 470, ledger item "Hensel-lifted prime-power lines restored
~20% of relations").  A toy quadratic sieve that only marks the two lines
`x ≡ ±r (mod p)` undercounts every value `x² - N` divisible by `p²`, `p³`, ….
The fix is to also sieve with the lines modulo `p^k`.  This file proves the exact
structure of those lines for an odd prime `p ∤ N`:

* `hensel_lift_step` / `hensel_lift` — every root modulo `p` lifts to a root
  modulo every `p^k` (Hensel's lemma, done by hand over `ℤ`);
* `prime_pow_dichotomy` — two roots modulo `p^k` agree up to sign modulo `p^k`;
* `rootCountPow_eq_two` — **exactly two lines modulo every `p^k`**, extending the
  `p`-level statement `QSRelationPool.root_count_of_isSquare` to all prime powers;
* `rootCountPow_eq_zero` — and none at all when `N` is a non-residue modulo `p`:
  the quadratic-character obstruction persists at every level.
-/

namespace ToyQSHensel

open QSRelationPool

/-- An odd prime does not divide `2 * x` unless it divides `x`. -/
lemma not_dvd_two_mul {p : ℕ} (hp : p.Prime) (hp2 : p ≠ 2) {x : ℤ}
    (hx : ¬ (p : ℤ) ∣ x) : ¬ (p : ℤ) ∣ 2 * x := by
  have hpz : Prime (p : ℤ) := Nat.prime_iff_prime_int.1 hp
  intro h
  rcases hpz.dvd_or_dvd h with h2 | h2
  · have : p ∣ 2 := by exact_mod_cast h2
    exact hp2 ((Nat.prime_dvd_prime_iff_eq hp Nat.prime_two).1 this)
  · exact hx h2

/-- A root of `x² ≡ N (mod p)` with `p ∤ N` is a unit modulo `p`. -/
lemma not_dvd_of_root {p : ℕ} {N x : ℤ} {k : ℕ} (hk : 1 ≤ k)
    (hx : (p : ℤ) ^ k ∣ x ^ 2 - N) (hpN : ¬ (p : ℤ) ∣ N) : ¬ (p : ℤ) ∣ x := by
  intro h
  apply hpN
  have h1 : (p : ℤ) ∣ x ^ 2 - N := (dvd_pow_self (p : ℤ) (by omega)).trans hx
  have h2 : (p : ℤ) ∣ x ^ 2 := h.trans (dvd_pow_self x (by norm_num))
  have := dvd_sub h2 h1
  simpa using this

/-- **One Hensel step.**  A root modulo `p^k` (`k ≥ 1`) that is a unit modulo `p`
lifts to a root modulo `p^(k+1)` in the same class modulo `p^k`. -/
theorem hensel_lift_step {p : ℕ} (hp : p.Prime) (hp2 : p ≠ 2) {N x : ℤ} {k : ℕ}
    (hk : 1 ≤ k) (hx : (p : ℤ) ^ k ∣ x ^ 2 - N) (hpx : ¬ (p : ℤ) ∣ x) :
    ∃ y : ℤ, (p : ℤ) ^ (k + 1) ∣ y ^ 2 - N ∧ (p : ℤ) ^ k ∣ y - x := by
  have hpz : Prime (p : ℤ) := Nat.prime_iff_prime_int.1 hp
  obtain ⟨t, ht⟩ := hx
  have hcop : IsCoprime (p : ℤ) (2 * x) :=
    (Prime.coprime_iff_not_dvd hpz).2 (not_dvd_two_mul hp hp2 hpx)
  obtain ⟨b, a, hab⟩ := hcop
  refine ⟨x + (p : ℤ) ^ k * (-t * a), ?_, ⟨-t * a, by ring⟩⟩
  have hpow : (p : ℤ) ^ (2 * k) = (p : ℤ) ^ (k + 1) * (p : ℤ) ^ (k - 1) := by
    rw [← pow_add]; congr 1; omega
  refine ⟨t * b + (p : ℤ) ^ (k - 1) * (t * a) ^ 2, ?_⟩
  have e1 : (x + (p : ℤ) ^ k * (-t * a)) ^ 2 - N
      = (x ^ 2 - N) - 2 * x * a * t * (p : ℤ) ^ k + (p : ℤ) ^ (2 * k) * (t * a) ^ 2 := by
    rw [pow_mul]; ring
  rw [e1, ht, hpow]
  have hab' : 2 * x * a = 1 - b * p := by linear_combination hab
  rw [hab', pow_succ]
  ring

/-- **Hensel's lemma for the sieve lines.**  If `p` is an odd prime with `p ∤ N`
and `p ∣ x₀² - N`, then for every `k ≥ 1` there is a root modulo `p^k` lying over
`x₀`. -/
theorem hensel_lift {p : ℕ} (hp : p.Prime) (hp2 : p ≠ 2) {N x₀ : ℤ}
    (h1 : (p : ℤ) ∣ x₀ ^ 2 - N) (hpN : ¬ (p : ℤ) ∣ N) :
    ∀ k, 1 ≤ k → ∃ y : ℤ, (p : ℤ) ^ k ∣ y ^ 2 - N ∧ (p : ℤ) ∣ y - x₀ := by
  intro k hk
  induction k, hk using Nat.le_induction with
  | base => exact ⟨x₀, by simpa using h1, by simp⟩
  | succ k hk ih =>
    obtain ⟨y, hy, hyx⟩ := ih
    obtain ⟨z, hz, hzy⟩ := hensel_lift_step hp hp2 hk hy (not_dvd_of_root hk hy hpN)
    refine ⟨z, hz, ?_⟩
    have : (p : ℤ) ∣ z - y := (dvd_pow_self (p : ℤ) (by omega)).trans hzy
    have := dvd_add this hyx
    simpa using this

/-- **At most two lines.**  Two roots of `x² ≡ N (mod p^k)` with `p` odd and
`p ∤ N` agree modulo `p^k` up to sign. -/
theorem prime_pow_dichotomy {p : ℕ} (hp : p.Prime) (hp2 : p ≠ 2) {N x y : ℤ} {k : ℕ}
    (hpN : ¬ (p : ℤ) ∣ N) (hx : (p : ℤ) ^ k ∣ x ^ 2 - N) (hy : (p : ℤ) ^ k ∣ y ^ 2 - N) :
    (p : ℤ) ^ k ∣ x - y ∨ (p : ℤ) ^ k ∣ x + y := by
  rcases Nat.eq_zero_or_pos k with rfl | hk
  · simp
  have hpz : Prime (p : ℤ) := Nat.prime_iff_prime_int.1 hp
  have hprod : (p : ℤ) ^ k ∣ (x - y) * (x + y) := by
    have := dvd_sub hx hy
    have e : x ^ 2 - N - (y ^ 2 - N) = (x - y) * (x + y) := by ring
    rwa [e] at this
  by_cases hd : (p : ℤ) ∣ x - y
  · -- then `p ∤ x + y`, otherwise `p ∣ 2x`
    have hnd : ¬ (p : ℤ) ∣ x + y := by
      intro hs
      have h2x : (p : ℤ) ∣ 2 * x := by
        have := dvd_add hd hs
        have e : x - y + (x + y) = 2 * x := by ring
        rwa [e] at this
      exact not_dvd_two_mul hp hp2 (not_dvd_of_root hk hx hpN) h2x
    have hc : IsCoprime ((p : ℤ) ^ k) (x + y) :=
      ((Prime.coprime_iff_not_dvd hpz).2 hnd).pow_left
    left
    exact hc.dvd_of_dvd_mul_right hprod
  · have hc : IsCoprime ((p : ℤ) ^ k) (x - y) :=
      ((Prime.coprime_iff_not_dvd hpz).2 hd).pow_left
    right
    exact hc.dvd_of_dvd_mul_left hprod

/-- Number of sieve lines modulo `p^k`: the number of residues `x` modulo `p^k`
with `p^k ∣ x² - N`. -/
noncomputable def rootCountPow (p k : ℕ) (N : ℤ) : ℕ :=
  {x : ZMod (p ^ k) | x ^ 2 = (N : ZMod (p ^ k))}.ncard

/-- Root condition in `ZMod (p^k)` versus divisibility in `ℤ`. -/
lemma zmod_sq_eq_iff {p k : ℕ} (N x : ℤ) :
    ((x : ZMod (p ^ k))) ^ 2 = (N : ZMod (p ^ k)) ↔ (p : ℤ) ^ k ∣ x ^ 2 - N := by
  have := ZMod.intCast_zmod_eq_zero_iff_dvd (x ^ 2 - N) (p ^ k)
  push_cast at this
  rw [← this, sub_eq_zero]

/-- **Exactly two lines modulo every prime power.**  For an odd prime `p`, `p ∤ N`
and `N` a quadratic residue modulo `p`, the congruence `x² ≡ N (mod p^k)` has
exactly two solutions for every `k ≥ 1`.  This is what a sieve must mark at the
prime-power level; omitting these lines loses every relation with a repeated
factor. -/
theorem rootCountPow_eq_two {p : ℕ} (hp : p.Prime) (hp2 : p ≠ 2) {N : ℤ}
    (hpN : ¬ (p : ℤ) ∣ N) (hsq : IsSquare (N : ZMod p)) {k : ℕ} (hk : 1 ≤ k) :
    rootCountPow p k N = 2 := by
  haveI : NeZero (p ^ k) := ⟨pow_ne_zero _ hp.ne_zero⟩
  -- a root modulo `p`
  haveI : NeZero p := ⟨hp.ne_zero⟩
  obtain ⟨x₀, hx₀⟩ := (exists_dvd_qsValue_iff_isSquare (p := p) N).2 hsq
  obtain ⟨y, hy, -⟩ := hensel_lift hp hp2 (N := N) (x₀ := x₀) (by simpa [qsValue] using hx₀)
    hpN k hk
  have hpy : ¬ (p : ℤ) ∣ y := not_dvd_of_root hk hy hpN
  have hne : ((y : ZMod (p ^ k))) ≠ -((y : ZMod (p ^ k))) := by
    intro h
    have h2 : (((2 * y : ℤ)) : ZMod (p ^ k)) = 0 := by
      push_cast; linear_combination h
    rw [ZMod.intCast_zmod_eq_zero_iff_dvd] at h2
    push_cast at h2
    exact not_dvd_two_mul hp hp2 hpy ((dvd_pow_self (p : ℤ) (by omega)).trans h2)
  unfold rootCountPow
  rw [Set.ncard_eq_two]
  refine ⟨(y : ZMod (p ^ k)), -(y : ZMod (p ^ k)), hne, ?_⟩
  ext z
  simp only [Set.mem_setOf_eq, Set.mem_insert_iff, Set.mem_singleton_iff]
  constructor
  · intro hz
    have hz' : (p : ℤ) ^ k ∣ (z.cast : ℤ) ^ 2 - N := by
      rw [← zmod_sq_eq_iff]; simpa [ZMod.intCast_cast, ZMod.cast_id] using hz
    rcases prime_pow_dichotomy hp hp2 hpN hz' hy with h | h
    · left
      have := (ZMod.intCast_zmod_eq_zero_iff_dvd _ (p ^ k)).2 (by push_cast; exact h)
      push_cast at this
      simpa [ZMod.intCast_cast, ZMod.cast_id, sub_eq_zero] using this
    · right
      have := (ZMod.intCast_zmod_eq_zero_iff_dvd _ (p ^ k)).2 (by push_cast; exact h)
      push_cast at this
      have h' : z + (y : ZMod (p ^ k)) = 0 := by
        simpa [ZMod.intCast_cast, ZMod.cast_id] using this
      linear_combination h'
  · rintro (h | h)
    · rw [h, zmod_sq_eq_iff]; exact hy
    · rw [h, neg_sq, zmod_sq_eq_iff]; exact hy

/-- **No lines at any level for a non-residue.**  If `N` is not a square modulo
`p`, then `x² ≡ N (mod p^k)` has no solution for any `k ≥ 1`. -/
theorem rootCountPow_eq_zero {p : ℕ} {N : ℤ}
    (hsq : ¬ IsSquare (N : ZMod p)) {k : ℕ} (hk : 1 ≤ k) :
    rootCountPow p k N = 0 := by
  unfold rootCountPow
  convert Set.ncard_empty (ZMod (p ^ k))
  rw [Set.eq_empty_iff_forall_notMem]
  intro z hz
  apply hsq
  have hz' : (p : ℤ) ^ k ∣ (z.cast : ℤ) ^ 2 - N := by
    rw [← zmod_sq_eq_iff]; simpa [ZMod.intCast_cast, ZMod.cast_id] using hz
  exact isSquare_of_dvd_qsValue (x := z.cast)
    ((dvd_pow_self (p : ℤ) (by omega)).trans hz')

/-! ## The prime `2`: a bounded sieve height unless `N ≡ 1 (mod 8)`

The toy sieve treats `p = 2` separately.  For odd `N` the `2`-adic lines are not
governed by Hensel's lemma: an odd square is `≡ 1 (mod 8)`, so the height of the
`2`-power lines is capped by the residue of `N` modulo `8`. -/

/-- If `N` is odd and `4 ∣ x² - N` for some `x`, then `N ≡ 1 (mod 4)`.  For
`N ≡ 3 (mod 4)` no sieve value is divisible by `4`. -/
theorem four_dvd_obstruction {N x : ℤ} (hN : N % 2 = 1) (h : 4 ∣ x ^ 2 - N) :
    N % 4 = 1 := by
  obtain ⟨c, hc⟩ := h
  have hx := Int.emod_add_mul_ediv x 4
  have h0 := Int.emod_nonneg x (by norm_num : (4 : ℤ) ≠ 0)
  have h4 := Int.emod_lt_of_pos x (by norm_num : (0 : ℤ) < 4)
  set r := x % 4
  set q := x / 4
  have e : x ^ 2 = r ^ 2 + 4 * (2 * r * q + 4 * q ^ 2) := by rw [← hx]; ring
  interval_cases r <;> omega

/-- If `N` is odd and `8 ∣ x² - N` for some `x`, then `N ≡ 1 (mod 8)`.  For
`N ≡ 3, 5, 7 (mod 8)` the `2`-power sieve lines stop at height `≤ 2`. -/
theorem eight_dvd_obstruction {N x : ℤ} (hN : N % 2 = 1) (h : 8 ∣ x ^ 2 - N) :
    N % 8 = 1 := by
  obtain ⟨c, hc⟩ := h
  have hx := Int.emod_add_mul_ediv x 8
  have h0 := Int.emod_nonneg x (by norm_num : (8 : ℤ) ≠ 0)
  have h8 := Int.emod_lt_of_pos x (by norm_num : (0 : ℤ) < 8)
  set r := x % 8
  set q := x / 8
  have e : x ^ 2 = r ^ 2 + 8 * (2 * r * q + 8 * q ^ 2) := by rw [← hx]; ring
  interval_cases r <;> omega

/-- Lab note: the toy modulus `N = 103764863 ≡ 7 (mod 8)`, so no sieve value is
divisible by `4` — consistent with every relation in the toy run having `2`-adic
valuation `≤ 1` (`2 ∥ 10749² - N`, `2 ∥ 18185² - N`). -/
theorem toy_N_two_adic (x : ℤ) : ¬ (4 : ℤ) ∣ x ^ 2 - 103764863 := by
  intro h
  have := four_dvd_obstruction (by norm_num) h
  norm_num at this

end ToyQSHensel