/-! # CatalogBuild.Speculative.SmoothNumberTheory

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 13
-/

import Mathlib

/-- [Section: # CatalogBuild.Speculative.SmoothNumberTheory
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 13] -/
def BSmooth (B n : ℕ) : Prop :=
  ∀ p, Nat.Prime p → p ∣ n → p ≤ B


/-- [Section: # CatalogBuild.Speculative.SmoothNumberTheory
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 13] -/
theorem smooth_one (B : ℕ) : BSmooth B 1 := by
  intro p hp hd
  have := hp.one_lt
  have := Nat.le_of_dvd one_pos hd
  linarith


/-- [Section: # CatalogBuild.Speculative.SmoothNumberTheory
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 13] -/
theorem smooth_prime (p : ℕ) (hp : Nat.Prime p) : BSmooth p p := by
  intro q hq hd
  rcases hp.eq_one_or_self_of_dvd q hd with h | h
  · exact absurd h hq.ne_one
  · exact le_of_eq h


theorem smooth_prime_pow (p k : ℕ) (hp : Nat.Prime p) : BSmooth p (p ^ k) := by
  intro q hq hd
  have := hq.dvd_of_dvd_pow hd
  rcases hp.eq_one_or_self_of_dvd q this with h | h
  · exact absurd h hq.ne_one
  · exact le_of_eq h


theorem smooth_mul_closed (B a b : ℕ) (ha : BSmooth B a) (hb : BSmooth B b) :
    BSmooth B (a * b) := by
  intro p hp hd
  rcases hp.dvd_mul.mp hd with h | h
  · exact ha p hp h
  · exact hb p hp h


theorem smooth_dvd_closed (B n d : ℕ) (hn : BSmooth B n) (hd : d ∣ n) :
    BSmooth B d := by
  intro p hp hpd
  exact hn p hp (dvd_trans hpd hd)


theorem smooth_pow_closed (B n k : ℕ) (hn : BSmooth B n) :
    BSmooth B (n ^ k) := by
  intro p hp hd
  exact hn p hp (hp.dvd_of_dvd_pow hd)


theorem smooth_gcd_closed (B a b : ℕ) (ha : BSmooth B a) :
    BSmooth B (Nat.gcd a b) := by
  exact smooth_dvd_closed B a _ ha (Nat.gcd_dvd_left a b)


theorem not_smooth_prime_gt (B p : ℕ) (hp : Nat.Prime p) (hBp : B < p) :
    ¬ BSmooth B p := by
  intro h
  have := h p hp dvd_rfl
  omega


theorem smooth_mono (B₁ B₂ n : ℕ) (hle : B₁ ≤ B₂) (h : BSmooth B₁ n) :
    BSmooth B₂ n := by
  intro p hp hd
  exact le_trans (h p hp hd) hle


theorem two_smooth_8 : BSmooth 2 8 := by
  intro p hp hd; have := hp.dvd_of_dvd_pow (show p ∣ 2^3 by norm_num; exact hd)
  rcases (Nat.Prime.eq_one_or_self_of_dvd (by norm_num : Nat.Prime 2) p this) with h | h
  · exact absurd h hp.ne_one
  · omega


theorem three_smooth_12 : BSmooth 3 12 := by
  intro p hp hd
  have h12 : 12 = 2^2 * 3 := by norm_num
  rw [h12] at hd
  rcases hp.dvd_mul.mp hd with h | h
  · have := hp.dvd_of_dvd_pow h
    rcases (by norm_num : Nat.Prime 2).eq_one_or_self_of_dvd p this with h | h
    · exact absurd h hp.ne_one
    · omega
  · rcases (by norm_num : Nat.Prime 3).eq_one_or_self_of_dvd p h with h | h
    · exact absurd h hp.ne_one
    · omega


theorem smooth_exists_in_range (N B : ℕ) (hB : 1 < B) (hBN : B ≤ N) :
    ∃ n, 1 < n ∧ n ≤ N ∧ BSmooth B n := by
  obtain ⟨p, hp, hpB⟩ := Nat.exists_prime_and_dvd (show B ≠ 1 by omega)
  refine ⟨p, hp.one_lt, le_trans (Nat.le_of_dvd (by omega) hpB) hBN, ?_⟩
  exact smooth_mono p B p (Nat.le_of_dvd (by omega) hpB) (smooth_prime p hp)


