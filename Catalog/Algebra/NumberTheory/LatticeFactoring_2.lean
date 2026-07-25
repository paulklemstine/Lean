import Mathlib

/-! # CatalogBuild.Speculative.LatticeFactoring_2

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 9
-/

/-- [Section: # CatalogBuild.Speculative.LatticeFactoring_2
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 9] -/
def normSq' (x y : ℤ) : ℤ := x ^ 2 + y ^ 2

/-- [Section: # CatalogBuild.Speculative.LatticeFactoring_2
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 9] -/
theorem normSq_nonneg' (x y : ℤ) : 0 ≤ normSq' x y := by
  unfold normSq'; positivity

theorem normSq_zero_iff' (x y : ℤ) : normSq' x y = 0 ↔ x = 0 ∧ y = 0 := by
  unfold normSq'
  constructor
  · intro h; exact ⟨by nlinarith, by nlinarith⟩
  · rintro ⟨rfl, rfl⟩; ring

theorem factoring_lattice_exists' (N : ℕ) (hN : 1 < N) :
    ∃ a b c d : ℤ, a * d - b * c = N ∧ normSq' c d ≤ 2 * N := by
  refine ⟨N, 0, 0, 1, ?_, ?_⟩
  · simp
  · simp [normSq']; omega

def IsSmooth' (B n : ℕ) : Prop :=
  ∀ p, Nat.Prime p → p ∣ n → p ≤ B

theorem one_is_smooth' (B : ℕ) : IsSmooth' B 1 := by
  intro p hp hd
  have := hp.one_lt
  have := Nat.le_of_dvd one_pos hd
  omega

theorem smooth_mul' (B a b : ℕ) (ha : IsSmooth' B a) (hb : IsSmooth' B b) :
    IsSmooth' B (a * b) := by
  intro p hp hd
  rcases hp.dvd_mul.mp hd with h | h
  · exact ha p hp h
  · exact hb p hp h

theorem smooth_exists (N B : ℕ) (hB : 1 < B) (hBN : B ≤ N) :
    ∃ n, 1 < n ∧ n ≤ N ∧ IsSmooth' B n := by
  obtain ⟨p, hp, hpB⟩ := Nat.exists_prime_and_dvd (show B ≠ 1 by omega)
  refine ⟨p, hp.one_lt, ?_, ?_⟩
  · exact le_trans (le_of_dvd (by omega) hpB) hBN
  · intro q hq hqp
    rcases hp.eq_one_or_self_of_dvd q hqp with h | h
    · exact absurd h hq.ne_one
    · rw [h]; exact le_of_dvd (by omega) hpB

theorem coppersmith_deg1 (a b p : ℤ) (hp : 0 < p)
    (hmod : p ∣ (a + b))
    (hsmall : |a + b| < p) :
    a + b = 0 := by
  rcases hmod with ⟨k, hk⟩
  rw [hk] at hsmall ⊢
  rw [abs_mul, abs_of_pos hp] at hsmall
  have : |k| = 0 := by
    by_contra h
    have hk1 : 1 ≤ |k| := Int.one_le_abs (mt abs_eq_zero.mpr h)
    linarith [mul_le_mul_of_nonneg_left hk1 (le_of_lt hp)]
  simp [abs_eq_zero.mp this]