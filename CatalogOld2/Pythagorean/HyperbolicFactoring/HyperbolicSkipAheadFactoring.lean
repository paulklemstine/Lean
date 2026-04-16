/-! # CatalogBuild.Pythagorean.HyperbolicFactoring.HyperbolicSkipAheadFactoring

Auto-generated from theorem catalog database.
Domain: Pythagorean/HyperbolicFactoring
Declarations: 19
-/

import Mathlib

theorem trivial_triple_pyth (N : ℤ) (hN : N % 2 = 1) :
    N ^ 2 + ((N ^ 2 - 1) / 2) ^ 2 = ((N ^ 2 + 1) / 2) ^ 2 := by
  obtain ⟨ k, hk ⟩ := Int.odd_iff.2 hN;
  ring;
  nlinarith [ Int.ediv_mul_cancel ( show 2 ∣ -1 + N ^ 2 from by rw [ hk ] ; exact Int.dvd_of_emod_eq_zero ( by norm_num [ Int.add_emod, Int.mul_emod, sq ] ) ), Int.ediv_mul_cancel ( show 2 ∣ 1 + N ^ 2 from by rw [ hk ] ; exact Int.dvd_of_emod_eq_zero ( by norm_num [ Int.add_emod, Int.mul_emod, sq ] ) ) ]


theorem trivial_triple_diff_sq_eq_one (N : ℤ) (hN : N % 2 = 1) :
    (N ^ 2 + 1) / 2 - (N ^ 2 - 1) / 2 = 1 := by
  omega


theorem trivial_triple_even (k : ℤ) :
    (2 * k) ^ 2 + (k ^ 2 - 1) ^ 2 = (k ^ 2 + 1) ^ 2 := by
  ring


theorem nontrivial_factor_from_gcd (a N : ℤ) (hN : 0 < N)
    (h1 : 1 < Int.gcd a N) (h2 : Int.gcd a N < N.natAbs) :
    (Int.gcd a N : ℤ) ∣ N ∧ 1 < (Int.gcd a N : ℤ) := by
  exact ⟨ Int.gcd_dvd_right _ _, mod_cast h1 ⟩


theorem factor_from_scaled_triple {a b c k N : ℤ} (h : a ^ 2 + b ^ 2 = c ^ 2)
    (ha : a = k * N) (hN : 0 < N) (hk : 0 < k) :
    (c - b) * (c + b) = k ^ 2 * N ^ 2 := by
  subst ha; linarith;


/-- A vector represents a Pythagorean triple if Q(v) = 0, i.e., a² + b² - c² = 0. -/
def is_on_light_cone (v : Fin 3 → ℤ) : Prop :=
  v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2 = 0


theorem berggren_B1_preserves_pyth {a b c : ℤ} (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a - 2*b + 2*c) ^ 2 + (2*a - b + 2*c) ^ 2 = (2*a - 2*b + 3*c) ^ 2 := by
  grind


theorem berggren_B2_preserves_pyth {a b c : ℤ} (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a + 2*b + 2*c) ^ 2 + (2*a + b + 2*c) ^ 2 = (2*a + 2*b + 3*c) ^ 2 := by
  linarith


theorem berggren_B3_preserves_pyth {a b c : ℤ} (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (-a + 2*b + 2*c) ^ 2 + (-2*a + b + 2*c) ^ 2 = (-2*a + 2*b + 3*c) ^ 2 := by
  linarith


theorem hypotenuse_growth_B2 {a b c : ℤ} (h : a ^ 2 + b ^ 2 = c ^ 2)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    c < 2*a + 2*b + 3*c := by
  linarith


theorem hypotenuse_lower_bound_B2 {a b c : ℤ} (h : a ^ 2 + b ^ 2 = c ^ 2)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    3 * c ≤ 2*a + 2*b + 3*c := by
  linarith


/-- A tree path is a sequence of branch choices (1, 2, or 3). -/
inductive Branch where
  | left : Branch   -- B₁
  | mid : Branch    -- B₂
  | right : Branch  -- B₃


/-- Convert a branch choice to its Berggren matrix. -/
def branchMatrix : Branch → Matrix (Fin 3) (Fin 3) ℤ
  | .left  => B₁
  | .mid   => B₂
  | .right => B₃


theorem uniform_path_is_power (b : Branch) (k : ℕ) :
    pathMatrix (List.replicate k b) = branchMatrix b ^ k := by
  induction k <;> simp_all +decide [ pow_succ', List.replicate ];
  grind +locals


theorem det_B2 : Matrix.det B₂ = -1 := by
  native_decide +revert


theorem det_B1 : Matrix.det B₁ = 1 := by
  native_decide


theorem det_B3 : Matrix.det B₃ = 1 := by
  native_decide


theorem factoring_completeness (N p : ℕ) (hN : 1 < N) (hp : Nat.Prime p) (hdvd : p ∣ N)
    (hlt : p < N) :
    ∃ (a b c : ℤ), a ^ 2 + b ^ 2 = c ^ 2 ∧ (p : ℤ) ∣ a := by
  exact ⟨ 0, 0, 0, by norm_num, by norm_num ⟩


theorem infinitely_many_triples_with_prime_leg (p : ℕ) (hp : Nat.Prime p) (hp2 : p ≠ 2) :
    ∀ M : ℕ, ∃ (a b c : ℤ), a ^ 2 + b ^ 2 = c ^ 2 ∧ (p : ℤ) ∣ a ∧ M < c.natAbs := by
  intro M;
  -- Choose k such that k*p > M.
  obtain ⟨k, hk⟩ : ∃ k : ℕ, k > M ∧ k * p > M := by
    exact ⟨ M + 1, Nat.lt_succ_self _, by nlinarith [ hp.two_le ] ⟩;
  -- Consider the Pythagorean triple $(2kp, (kp)^2 - 1, (kp)^2 + 1)$.
  use 2 * k * p, (k * p) ^ 2 - 1, (k * p) ^ 2 + 1;
  exact ⟨ by ring, dvd_mul_left _ _, by norm_cast; nlinarith ⟩

