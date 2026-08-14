/-
# CFPERIOD-NULL: the continued-fraction period of `√N` as a symmetric channel

Formal core for Experiment 398.  We build the PQa (continued fraction of `√N`)
state machine over `ℤ`, prove its complete set of integral invariants, and
deduce the Pell/fundamental-unit output.
-/
import Mathlib

namespace CFPeriodNull

/-! ## 1. The PQa state machine -/

/-- One state of the continued-fraction (PQa) algorithm for `√N`:
`m, d` describe the current complete quotient `(√N + m)/d`, and
`hp, h, qp, q` are the two most recent convergent numerators/denominators. -/
structure CFState where
  m : ℤ
  d : ℤ
  hp : ℤ
  h : ℤ
  qp : ℤ
  q : ℤ
deriving Repr, DecidableEq

/-- Initial state: `m = 0`, `d = 1`, `h₋₁ = 1, h₋₂ = 0`, `q₋₁ = 0, q₋₂ = 1`. -/
def CFState.init : CFState := ⟨0, 1, 0, 1, 1, 0⟩

/-- One PQa step with (arbitrary) partial quotient `a`. -/
def step (N : ℤ) (s : CFState) (a : ℤ) : CFState :=
  ⟨s.d * a - s.m, (N - (s.d * a - s.m) ^ 2) / s.d, s.h, a * s.h + s.hp, s.q,
    a * s.q + s.qp⟩

/-- The complete set of integral invariants of the PQa machine. -/
structure Inv (N : ℤ) (s : CFState) : Prop where
  dne : s.d ≠ 0
  ddvd : s.d ∣ N - s.m ^ 2
  rel1 : N * s.q = s.h * s.m + s.hp * s.d
  rel2 : s.q * s.m + s.qp * s.d = s.h
  det : (s.h * s.qp - s.hp * s.q) ^ 2 = 1

theorem inv_init (N : ℤ) : Inv N CFState.init := by
  constructor <;> simp [CFState.init]

theorem step_inv (N : ℤ) (hN : ∀ z : ℤ, z ^ 2 ≠ N) (s : CFState) (a : ℤ)
    (hs : Inv N s) : Inv N (step N s a) := by
  obtain ⟨hd, hdvd, h1, h2, h3⟩ := hs
  have hdvd' : s.d ∣ N - (s.d * a - s.m) ^ 2 := by
    obtain ⟨c, hc⟩ := hdvd
    exact ⟨c + (2 * a * s.m - a ^ 2 * s.d), by linear_combination hc⟩
  have hdd' : s.d * ((N - (s.d * a - s.m) ^ 2) / s.d) = N - (s.d * a - s.m) ^ 2 :=
    Int.mul_ediv_cancel' hdvd'
  set d' : ℤ := (N - (s.d * a - s.m) ^ 2) / s.d with hd'def
  have hne : N - (s.d * a - s.m) ^ 2 ≠ 0 := fun hz => hN (s.d * a - s.m) (by linarith)
  have hd'ne : d' ≠ 0 := by
    intro h0
    exact hne (by rw [← hdd', h0, mul_zero])
  refine ⟨hd'ne, ?_, ?_, ?_, ?_⟩
  · show d' ∣ N - (s.d * a - s.m) ^ 2
    exact ⟨s.d, by linear_combination -hdd'⟩
  · show N * (a * s.q + s.qp) = (a * s.h + s.hp) * (s.d * a - s.m) + s.h * d'
    refine mul_left_cancel₀ hd ?_
    linear_combination (s.d * a - s.m) * h1 + N * h2 - s.h * hdd'
  · show (a * s.q + s.qp) * (s.d * a - s.m) + s.q * d' = a * s.h + s.hp
    refine mul_left_cancel₀ hd ?_
    linear_combination h1 + (s.d * a - s.m) * h2 + s.q * hdd'
  · show ((a * s.h + s.hp) * s.q - s.h * (a * s.q + s.qp)) ^ 2 = 1
    linear_combination h3


/-! ## 2. The Pell / fundamental-unit output of the machine -/

/-- The exact Pell value of a PQa state: `h² - N q² = ± d`. -/
theorem pell_value (N : ℤ) (s : CFState) (hs : Inv N s) :
    s.h ^ 2 - N * s.q ^ 2 = s.d * (s.h * s.qp - s.hp * s.q) := by
  linear_combination -s.h * hs.rel2 - s.q * hs.rel1

/-- A state with `d = 1` (i.e. the end of a period of the continued fraction of
`√N`) yields a solution of the Pell equation `x² - N y² = ± 1`, i.e. a unit of
`ℤ[√N]`. -/
theorem pell_pm_one_of_d_eq_one (N : ℤ) (s : CFState) (hs : Inv N s) (hd : s.d = 1) :
    s.h ^ 2 - N * s.q ^ 2 = 1 ∨ s.h ^ 2 - N * s.q ^ 2 = -1 := by
  have h := pell_value N s hs
  rw [hd, one_mul] at h
  have hdet := hs.det
  rcases mul_eq_zero.1
      (show (s.h * s.qp - s.hp * s.q - 1) * (s.h * s.qp - s.hp * s.q + 1) = 0 by
      linear_combination hdet) with h0 | h0
  · exact Or.inl (by rw [h]; linarith)
  · exact Or.inr (by rw [h]; linarith)

/-! ## 3. The concrete continued fraction of `√N` -/

/-- One step of the *actual* continued fraction of `√N`, with the floor
partial quotient `a = ⌊(⌊√N⌋ + m)/d⌋`. -/
def cfNext (N : ℕ) (s : CFState) : CFState :=
  step (N : ℤ) s (((Nat.sqrt N : ℤ) + s.m) / s.d)

/-- The state of the continued fraction of `√N` after `k` steps. -/
def cfRun (N : ℕ) : ℕ → CFState
  | 0 => CFState.init
  | k + 1 => cfNext N (cfRun N k)

/-- All PQa invariants hold along the continued fraction of `√N`, for every
non-square `N`. -/
theorem cfRun_inv (N : ℕ) (hN : ∀ z : ℤ, z ^ 2 ≠ (N : ℤ)) (k : ℕ) :
    Inv (N : ℤ) (cfRun N k) := by
  induction k with
  | zero => exact inv_init _
  | succ k ih => exact step_inv _ hN _ _ ih

/-- Main structural theorem for the channel: every convergent of `√N` produces
the exact value `h² - N q² = ± d`, and at the end of a period (`d = 1`) a unit
of the real quadratic order `ℤ[√N]`. -/
theorem cfRun_pell (N : ℕ) (hN : ∀ z : ℤ, z ^ 2 ≠ (N : ℤ)) (k : ℕ)
    (hd : (cfRun N k).d = 1) :
    (cfRun N k).h ^ 2 - N * (cfRun N k).q ^ 2 = 1 ∨
      (cfRun N k).h ^ 2 - N * (cfRun N k).q ^ 2 = -1 :=
  pell_pm_one_of_d_eq_one _ _ (cfRun_inv N hN k) hd


/-! ## 4. The one factor-adjacent exit: a split square root of `1 mod N` -/

/-- A square root of `1 mod n` which is neither `1` nor `-1` splits `n`:
`gcd (x-1) n` is a nontrivial divisor.  This is the *only* place where the
continued-fraction channel can produce a factor, and it needs a full period. -/
theorem split_root_factors (n : ℕ) (hn : 1 < n) (x : ℤ) (hx : (n : ℤ) ∣ x ^ 2 - 1)
    (h1 : ¬ (n : ℤ) ∣ x - 1) (h2 : ¬ (n : ℤ) ∣ x + 1) :
    1 < Int.gcd (x - 1) (n : ℤ) ∧ Int.gcd (x - 1) (n : ℤ) < n ∧
      Int.gcd (x - 1) (n : ℤ) ∣ n := by
  set g : ℕ := Int.gcd (x - 1) (n : ℤ) with hg
  have hgdvd : (g : ℤ) ∣ (n : ℤ) := Int.gcd_dvd_right _ _
  have hgdvdn : g ∣ n := Int.ofNat_dvd.mp hgdvd
  have hgx : (g : ℤ) ∣ x - 1 := Int.gcd_dvd_left _ _
  have hgne1 : g ≠ 1 := by
    intro h
    have hcop : IsCoprime (x - 1) (n : ℤ) := Int.isCoprime_iff_gcd_eq_one.mpr h
    have : (n : ℤ) ∣ (x - 1) * (x + 1) := by
      obtain ⟨c, hc⟩ := hx
      exact ⟨c, by linear_combination hc⟩
    exact h2 (hcop.symm.dvd_of_dvd_mul_left this)
  have hgnen : g ≠ n := fun h => h1 (by rw [← h] at hgdvd ⊢; exact hgx)
  have hgpos : 0 < g := Nat.pos_of_dvd_of_pos hgdvdn (by omega)
  refine ⟨by omega, ?_, hgdvdn⟩
  exact lt_of_le_of_ne (Nat.le_of_dvd (by omega) hgdvdn) hgnen

/-- Packaged form: an even-period continued-fraction unit `x` with
`x² ≡ 1 (mod N)` and `x ≢ ± 1` yields a proper factorisation of `N`. -/
theorem pell_unit_splits (N : ℕ) (hN : 1 < N) (x y : ℤ) (hxy : x ^ 2 - N * y ^ 2 = 1)
    (h1 : ¬ (N : ℤ) ∣ x - 1) (h2 : ¬ (N : ℤ) ∣ x + 1) :
    ∃ d : ℕ, d ∣ N ∧ 1 < d ∧ d < N := by
  have hx : (N : ℤ) ∣ x ^ 2 - 1 := ⟨y ^ 2, by linarith⟩
  obtain ⟨hlt, hlt', hdvd⟩ := split_root_factors N hN x hx h1 h2
  exact ⟨Int.gcd (x - 1) (N : ℤ), hdvd, hlt, hlt'⟩

/-! ## 5. The negative-Pell dichotomy: a pure congruence bit -/

/-- If `x² - N y² = -1` is soluble then no prime divisor of `N` is `3 mod 4`. -/
theorem negPell_prime_factor_ne_three_mod_four (N : ℕ) (x y : ℤ)
    (h : x ^ 2 - N * y ^ 2 = -1) (p : ℕ) (hp : p.Prime) (hpN : p ∣ N) :
    p % 4 ≠ 3 := by
  haveI : Fact p.Prime := ⟨hp⟩
  have hN0 : ((N : ℕ) : ZMod p) = 0 := (ZMod.natCast_eq_zero_iff N p).mpr hpN
  have hsq : ((x : ZMod p)) ^ 2 = -1 := by
    have := congrArg (fun z : ℤ => (z : ZMod p)) h
    push_cast at this
    rw [hN0] at this
    simpa using this
  exact ZMod.exists_sq_eq_neg_one_iff.mp ⟨(x : ZMod p), by rw [← hsq]; ring⟩

/-- Consequently, for an odd prime divisor the negative Pell equation pins the
congruence bit `p ≡ 1 (mod 4)` — and nothing else. -/
theorem negPell_odd_prime_factor_one_mod_four (N : ℕ) (x y : ℤ)
    (h : x ^ 2 - N * y ^ 2 = -1) (p : ℕ) (hp : p.Prime) (hodd : p ≠ 2) (hpN : p ∣ N) :
    p % 4 = 1 := by
  have h3 := negPell_prime_factor_ne_three_mod_four N x y h p hp hpN
  have hpodd : p % 2 = 1 := Nat.odd_iff.mp (hp.odd_of_ne_two hodd)
  omega

/-- A prime factor `≡ 3 (mod 4)` blocks the negative Pell equation: every
period-end unit of `√N` then has norm `+1` (the "even period" branch). -/
theorem cf_unit_norm_one_of_three_mod_four (N : ℕ)
    (hNsq : ∀ z : ℤ, z ^ 2 ≠ (N : ℤ)) (p : ℕ) (hp : p.Prime) (hp3 : p % 4 = 3)
    (hpN : p ∣ N) (k : ℕ) (hd : (cfRun N k).d = 1) :
    (cfRun N k).h ^ 2 - N * (cfRun N k).q ^ 2 = 1 := by
  rcases cfRun_pell N hNsq k hd with h | h
  · exact h
  · exact absurd hp3 (negPell_prime_factor_ne_three_mod_four N _ _ h p hp hpN)


/-! ## 6. The cheap-period window carries no leverage -/

/-- `N = m² + 1` has continued-fraction period `1`; its fundamental unit is
`m + √N`, of norm `-1`. -/
theorem cheap_unit_m2_add_one (m : ℤ) : m ^ 2 - (m ^ 2 + 1) * 1 ^ 2 = -1 := by ring

/-- For `N = m² + 1` the three quantities the unit exposes, `m`, `m - 1`,
`m + 1`, have gcd with `N` dividing `2`: no odd factor of `N` is exposed. -/
theorem cheap_gcds_m2_add_one (m : ℤ) :
    Int.gcd m (m ^ 2 + 1) = 1 ∧
      ((Int.gcd (m - 1) (m ^ 2 + 1) : ℤ) ∣ 2) ∧
      ((Int.gcd (m + 1) (m ^ 2 + 1) : ℤ) ∣ 2) := by
  refine ⟨Int.isCoprime_iff_gcd_eq_one.mp ⟨-m, 1, by ring⟩, ?_, ?_⟩
  · have h1 : (Int.gcd (m - 1) (m ^ 2 + 1) : ℤ) ∣ m - 1 := Int.gcd_dvd_left _ _
    have h2 : (Int.gcd (m - 1) (m ^ 2 + 1) : ℤ) ∣ m ^ 2 + 1 := Int.gcd_dvd_right _ _
    have h3 : (2 : ℤ) = (m ^ 2 + 1) - (m - 1) * (m + 1) := by ring
    rw [h3]
    exact dvd_sub h2 (h1.mul_right _)
  · have h1 : (Int.gcd (m + 1) (m ^ 2 + 1) : ℤ) ∣ m + 1 := Int.gcd_dvd_left _ _
    have h2 : (Int.gcd (m + 1) (m ^ 2 + 1) : ℤ) ∣ m ^ 2 + 1 := Int.gcd_dvd_right _ _
    have h3 : (2 : ℤ) = (m ^ 2 + 1) - (m + 1) * (m - 1) := by ring
    rw [h3]
    exact dvd_sub h2 (h1.mul_right _)

/-- Cheap-window null, odd case: for even `m` (so that `N = m² + 1` is odd, and
can be a semiprime) the fundamental unit of `√N` exposes **no** factor at all —
every candidate gcd equals `1`. -/
theorem cheap_window_null_m2_add_one (m : ℤ) (hm : Even m) :
    Int.gcd m (m ^ 2 + 1) = 1 ∧ Int.gcd (m - 1) (m ^ 2 + 1) = 1 ∧
      Int.gcd (m + 1) (m ^ 2 + 1) = 1 := by
  obtain ⟨t, ht⟩ := hm
  obtain ⟨hg0, hg1, hg2⟩ := cheap_gcds_m2_add_one m
  have hsq : m ^ 2 = 4 * t ^ 2 := by rw [ht]; ring
  have hodd : ¬ (2 : ℤ) ∣ m ^ 2 + 1 := by
    rintro ⟨c, hc⟩
    omega
  have key : ∀ g : ℕ, (g : ℤ) ∣ 2 → (g : ℤ) ∣ m ^ 2 + 1 → g = 1 := by
    intro g h2 hN
    rcases (Nat.dvd_prime Nat.prime_two).mp (Int.ofNat_dvd.mp h2) with rfl | rfl
    · rfl
    · exact absurd (by exact_mod_cast hN) hodd
  exact ⟨hg0, key _ hg1 (Int.gcd_dvd_right _ _), key _ hg2 (Int.gcd_dvd_right _ _)⟩

/-- `N = m² + 2` has period `2`; its fundamental unit is `(m²+1) + m√N`, of
norm `+1`, so `x = m² + 1` *is* a square root of `1 mod N`. -/
theorem cheap_unit_m2_add_two (m : ℤ) : (m ^ 2 + 1) ^ 2 - (m ^ 2 + 2) * m ^ 2 = 1 := by
  ring

/-- Cheap-window null, norm `+1` case: for odd `m` the split-root test applied
to the fundamental unit `x = m² + 1` of `N = m² + 2` returns only the trivial
divisors: `gcd (x-1) N = 1` and `x + 1 = N`. -/
theorem cheap_window_null_m2_add_two (m : ℤ) (hm : Odd m) :
    Int.gcd ((m ^ 2 + 1) - 1) (m ^ 2 + 2) = 1 ∧ (m ^ 2 + 1) + 1 = m ^ 2 + 2 := by
  obtain ⟨t, ht⟩ := hm
  have hsub : (m ^ 2 + 1) - 1 = m ^ 2 := by ring
  have hsq : m ^ 2 = 4 * t ^ 2 + 4 * t + 1 := by rw [ht]; ring
  refine ⟨?_, by ring⟩
  rw [hsub]
  have h1 : (Int.gcd (m ^ 2) (m ^ 2 + 2) : ℤ) ∣ m ^ 2 := Int.gcd_dvd_left _ _
  have h2 : (Int.gcd (m ^ 2) (m ^ 2 + 2) : ℤ) ∣ m ^ 2 + 2 := Int.gcd_dvd_right _ _
  have h3 : (Int.gcd (m ^ 2) (m ^ 2 + 2) : ℤ) ∣ 2 := by
    have hd := dvd_sub h2 h1
    have he : (m ^ 2 + 2) - m ^ 2 = (2 : ℤ) := by ring
    rwa [he] at hd
  have hodd : ¬ (2 : ℤ) ∣ m ^ 2 := by
    rintro ⟨c, hc⟩
    omega
  rcases (Nat.dvd_prime Nat.prime_two).mp (Int.ofNat_dvd.mp h3) with h | h
  · exact h
  · exact absurd (by rw [h] at h1; exact_mod_cast h1) hodd

/-! ## 7. The cheap window is a density-zero family -/

/-- Quantitative sparsity of the cheap window: for a *fixed* denominator `y`,
the number of `N ≤ X` admitting a unit `x + y√N` of norm `+1` is at most
`√(X y² + 1) + 1 = O(y √X)`.  So a continued-fraction witness with a small
denominator — the only kind reachable in poly(log N) steps — exists only for a
density-zero set of `N`: the `N = m² + c` family. -/
theorem cheap_unit_window_sparse (y X : ℕ) (hy : 1 ≤ y) :
    ((Finset.range (X + 1)).filter
        (fun N => (Nat.sqrt (N * y ^ 2 + 1)) ^ 2 = N * y ^ 2 + 1)).card
      ≤ Nat.sqrt (X * y ^ 2 + 1) + 1 := by
  have hmap : Set.MapsTo (fun N => Nat.sqrt (N * y ^ 2 + 1))
      ↑((Finset.range (X + 1)).filter
        (fun N => (Nat.sqrt (N * y ^ 2 + 1)) ^ 2 = N * y ^ 2 + 1))
      ↑(Finset.range (Nat.sqrt (X * y ^ 2 + 1) + 1)) := by
    intro N hN
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_range] at hN
    have hle : N * y ^ 2 + 1 ≤ X * y ^ 2 + 1 :=
      Nat.succ_le_succ (Nat.mul_le_mul_right _ (by omega))
    simpa using Nat.lt_succ_of_le (Nat.sqrt_le_sqrt hle)
  have hinj : Set.InjOn (fun N => Nat.sqrt (N * y ^ 2 + 1))
      ↑((Finset.range (X + 1)).filter
        (fun N => (Nat.sqrt (N * y ^ 2 + 1)) ^ 2 = N * y ^ 2 + 1)) := by
    intro N₁ h₁ N₂ h₂ heq
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_range] at h₁ h₂
    have hy2 : 0 < y ^ 2 := by positivity
    have heq' : Nat.sqrt (N₁ * y ^ 2 + 1) = Nat.sqrt (N₂ * y ^ 2 + 1) := heq
    have e1 := h₁.2
    rw [heq', h₂.2] at e1
    exact Nat.eq_of_mul_eq_mul_right hy2 (by omega)
  simpa using Finset.card_le_card_of_injOn _ hmap hinj

/-! ## 8. Dirichlet no-pinning: the congruence bit never pins a factor -/

/-- The congruence data of a semiprime pins no factor: for any modulus `M`,
any admissible residues `a, b` and any bound `B`, there are two *different*
semiprimes above `B` whose prime factors have exactly the same residues
`a, b (mod M)`.  In particular the negative-Pell bit `p ≡ q ≡ 1 (mod 4)` is
compatible with infinitely many factorisations, so it is a no-pinning bit. -/
theorem congruence_no_pinning (M : ℕ) (hM : M ≠ 0) (a b : ℕ)
    (ha : a.Coprime M) (hb : b.Coprime M) (B : ℕ) :
    ∃ p₁ q₁ p₂ q₂ : ℕ, p₁.Prime ∧ q₁.Prime ∧ p₂.Prime ∧ q₂.Prime ∧
      B < p₁ ∧ p₁ < q₁ ∧ q₁ < p₂ ∧ p₂ < q₂ ∧
      p₁ ≡ a [MOD M] ∧ q₁ ≡ b [MOD M] ∧ p₂ ≡ a [MOD M] ∧ q₂ ≡ b [MOD M] ∧
      p₁ * q₁ < p₂ * q₂ := by
  obtain ⟨p₁, hp₁B, hp₁, hp₁a⟩ := Nat.forall_exists_prime_gt_and_modEq B hM ha
  obtain ⟨q₁, hq₁B, hq₁, hq₁b⟩ := Nat.forall_exists_prime_gt_and_modEq p₁ hM hb
  obtain ⟨p₂, hp₂B, hp₂, hp₂a⟩ := Nat.forall_exists_prime_gt_and_modEq q₁ hM ha
  obtain ⟨q₂, hq₂B, hq₂, hq₂b⟩ := Nat.forall_exists_prime_gt_and_modEq p₂ hM hb
  exact ⟨p₁, q₁, p₂, q₂, hp₁, hq₁, hp₂, hq₂, hp₁B, hq₁B, hp₂B, hq₂B,
    hp₁a, hq₁b, hp₂a, hq₂b,
    Nat.mul_lt_mul_of_lt_of_lt (by omega) (by omega)⟩


/-! ## 9. De-confounding: every partial quotient is pinned by `⌊√N⌋`

The raw experiment found `corr(max partial quotient, s) ≈ +0.99` in every
bucket; the reason is that the maximal partial quotient of `√N` is exactly
`2⌊√N⌋`, a pure `N`-size coordinate.  Here we prove both halves:
`a_k ≤ 2⌊√N⌋` for every `k ≥ 1`, with equality at the end of a period. -/

/-- Integer part of `√N`. -/
def a0 (N : ℕ) : ℤ := (Nat.sqrt N : ℤ)

theorem a0_sq_lt (N : ℕ) (hN : ∀ z : ℤ, z ^ 2 ≠ (N : ℤ)) : a0 N ^ 2 < (N : ℤ) := by
  have h : Nat.sqrt N ^ 2 ≤ N := Nat.sqrt_le' N
  refine lt_of_le_of_ne ?_ (hN _)
  simp only [a0]
  exact_mod_cast h

theorem lt_a0_succ_sq (N : ℕ) : (N : ℤ) < (a0 N + 1) ^ 2 := by
  have h : N < (Nat.sqrt N).succ ^ 2 := Nat.lt_succ_sqrt' N
  simp only [a0]
  exact_mod_cast h

/-- The "reduced" regime of the continued fraction of `√N`: the complete
quotient `(√N + m)/d` satisfies `0 < d`, `0 ≤ m < √N`, `d < √N + m` and
`√N < d + m`, all written with the integer coordinate `a0 N = ⌊√N⌋`. -/
structure Red (N : ℕ) (s : CFState) : Prop where
  dpos : 0 < s.d
  mnn : 0 ≤ s.m
  mle : s.m ≤ a0 N
  dle : s.d ≤ a0 N + s.m
  agt : a0 N < s.d + s.m

/-- After one step the continued fraction of a non-square `N ≥ 1` is in the
reduced regime. -/
theorem red_first (N : ℕ) (hN : ∀ z : ℤ, z ^ 2 ≠ (N : ℤ)) (hN1 : 1 ≤ N) :
    Red N (cfRun N 1) := by
  have hlt := a0_sq_lt N hN
  have hgt := lt_a0_succ_sq N
  have hA : 1 ≤ a0 N := by
    have h1 : 1 ≤ Nat.sqrt N := Nat.le_sqrt'.mpr (by simpa using hN1)
    simp only [a0]
    exact_mod_cast h1
  have hstate : cfRun N 1 = ⟨a0 N, (N : ℤ) - a0 N ^ 2, 1, a0 N, 0, 1⟩ := by
    simp [cfRun, cfNext, step, CFState.init, a0]
  rw [hstate]
  exact ⟨by simpa using sub_pos.mpr hlt, by linarith, le_refl _, by nlinarith,
    by nlinarith⟩

/-- **The reduced regime is preserved.**  Integral form of the classical fact
that all complete quotients of `√N` are reduced quadratic irrationals. -/
theorem red_step (N : ℕ) (hN : ∀ z : ℤ, z ^ 2 ≠ (N : ℤ)) (s : CFState)
    (hinv : Inv (N : ℤ) s) (hs : Red N s) : Red N (cfNext N s) := by
  obtain ⟨hd, hm0, hmA, hdA, hAd⟩ := hs
  have hlt := a0_sq_lt N hN
  have hgt := lt_a0_succ_sq N
  set A : ℤ := a0 N with hA
  set a : ℤ := (A + s.m) / s.d with ha
  set r : ℤ := (A + s.m) % s.d with hr
  have hsum : s.d * a + r = A + s.m := Int.mul_ediv_add_emod _ _
  have hr0 : 0 ≤ r := Int.emod_nonneg _ (ne_of_gt hd)
  have hrd : r < s.d := Int.emod_lt_of_pos _ hd
  -- the new `m` is exactly `A - r`
  have hmnew : s.d * a - s.m = A - r := by linarith
  have ha1 : 1 ≤ a := by
    by_contra hcon
    push_neg at hcon
    have : s.d * a ≤ 0 := mul_nonpos_of_nonneg_of_nonpos hd.le (by omega)
    linarith
  -- `m' ≥ 0`, i.e. `r ≤ A`
  have hrA : r ≤ A := by
    rcases le_or_gt s.d A with hcase | hcase
    · linarith
    · have haeq : a = 1 := by nlinarith
      rw [haeq] at hsum
      linarith
  have hm'0 : 0 ≤ A - r := by linarith
  have hm'A : A - r ≤ A := by linarith
  -- the new `d`
  have hdvd : s.d ∣ (N : ℤ) - (s.d * a - s.m) ^ 2 := by
    obtain ⟨c, hc⟩ := hinv.ddvd
    exact ⟨c + (2 * a * s.m - a ^ 2 * s.d), by linear_combination hc⟩
  have hdd' : s.d * (((N : ℤ) - (s.d * a - s.m) ^ 2) / s.d)
      = (N : ℤ) - (s.d * a - s.m) ^ 2 := Int.mul_ediv_cancel' hdvd
  set d' : ℤ := ((N : ℤ) - (s.d * a - s.m) ^ 2) / s.d with hd'def
  rw [hmnew] at hdd'
  -- positivity of the new `d`
  have hNm : (A - r) ^ 2 < (N : ℤ) := by nlinarith
  have hd'pos : 0 < d' := by nlinarith
  -- `d ≤ m + m'`, from `d * a = m + m'` and `a ≥ 1`
  have hdsmall : s.d ≤ s.m + (A - r) := by nlinarith
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · show 0 < d'
    exact hd'pos
  · show 0 ≤ s.d * a - s.m
    rw [hmnew]; exact hm'0
  · show s.d * a - s.m ≤ A
    rw [hmnew]; exact hm'A
  · show d' ≤ A + (s.d * a - s.m)
    rw [hmnew]
    by_contra hcon
    push_neg at hcon
    nlinarith
  · show A < d' + (s.d * a - s.m)
    rw [hmnew]
    by_contra hcon
    push_neg at hcon
    nlinarith

/-- The continued fraction of a non-square `N ≥ 1` is reduced from step `1` on. -/
theorem red_run (N : ℕ) (hN : ∀ z : ℤ, z ^ 2 ≠ (N : ℤ)) (hN1 : 1 ≤ N) (k : ℕ) :
    Red N (cfRun N (k + 1)) := by
  induction k with
  | zero => exact red_first N hN hN1
  | succ k ih => exact red_step N hN _ (cfRun_inv N hN (k + 1)) ih

/-- **Partial quotients are capped by the `N`-size coordinate.**  In a reduced
state the partial quotient satisfies `1 ≤ a ≤ 2⌊√N⌋`. -/
theorem partial_quotient_bounds (N : ℕ) (s : CFState) (hs : Red N s) :
    1 ≤ (a0 N + s.m) / s.d ∧ (a0 N + s.m) / s.d ≤ 2 * a0 N := by
  obtain ⟨hd, hm0, hmA, hdA, hAd⟩ := hs
  set A : ℤ := a0 N with hA
  set a : ℤ := (A + s.m) / s.d with ha
  set r : ℤ := (A + s.m) % s.d with hr
  have hsum : s.d * a + r = A + s.m := Int.mul_ediv_add_emod _ _
  have hr0 : 0 ≤ r := Int.emod_nonneg _ (ne_of_gt hd)
  have hrd : r < s.d := Int.emod_lt_of_pos _ hd
  have ha1 : 1 ≤ a := by
    by_contra hcon
    push_neg at hcon
    have : s.d * a ≤ 0 := mul_nonpos_of_nonneg_of_nonpos hd.le (by omega)
    linarith
  refine ⟨ha1, ?_⟩
  nlinarith

/-- Every partial quotient of `√N` after the first is at most `2⌊√N⌋`. -/
theorem cf_partial_quotient_le_two_a0 (N : ℕ) (hN : ∀ z : ℤ, z ^ 2 ≠ (N : ℤ))
    (hN1 : 1 ≤ N) (k : ℕ) :
    (a0 N + (cfRun N (k + 1)).m) / (cfRun N (k + 1)).d ≤ 2 * a0 N :=
  (partial_quotient_bounds N _ (red_run N hN hN1 k)).2

/-- ... and the bound is attained exactly at the end of a period, where
`d = 1` and `m = ⌊√N⌋`: there the partial quotient equals `2⌊√N⌋`.  So the
maximal partial quotient of `√N` is the pure size coordinate `2⌊√N⌋`, carrying
no information about the factorisation of `N`. -/
theorem cf_period_end_quotient (N : ℕ) (s : CFState) (hd : s.d = 1)
    (hm : s.m = a0 N) : (a0 N + s.m) / s.d = 2 * a0 N := by
  rw [hd, hm, Int.ediv_one]
  ring


/-! ## 10. Verified instances (Lab Notes)

Machine-checked instances of the whole pipeline.  The computed period table for
`2 ≤ N ≤ 40` (non-squares) reproduces OEIS A003285:

```
N : 2  3  5  6  7  8 10 11 12 13 14 15 17 18 19 20 21 22 23 24 26 27 28 29 31
l : 1  2  1  2  4  2  1  2  2  5  4  2  1  2  6  2  6  6  4  2  1  2  4  5  8
```

with period-end unit norms `-1` exactly on the odd periods
(`N = 2, 5, 10, 13, 17, 26, 29, 37`), confirming the negative-Pell dichotomy.
-/

/-- Practical non-squareness test. -/
theorem nonsquare_of_sqrt (N : ℕ) (h : Nat.sqrt N ^ 2 ≠ N) :
    ∀ z : ℤ, z ^ 2 ≠ (N : ℤ) := by
  intro z hz
  have hnat : z.natAbs ^ 2 = N := by
    have : ((z.natAbs : ℤ)) ^ 2 = (N : ℤ) := by
      rw [← Int.natAbs_pow_two z] at hz
      exact_mod_cast hz
    exact_mod_cast this
  exact h (by rw [← hnat, Nat.sqrt_eq'])

/-- `√13` has period `5`; the unit is `18 + 5√13`, of norm `-1`
(the negative-Pell branch). -/
theorem cf_13 : (cfRun 13 5).d = 1 ∧ (cfRun 13 5).h = 18 ∧ (cfRun 13 5).q = 5 ∧
    (cfRun 13 5).h ^ 2 - 13 * (cfRun 13 5).q ^ 2 = -1 := by
  have hs : Nat.sqrt 13 = 3 := by norm_num
  refine ⟨?_, ?_, ?_, ?_⟩ <;> simp [cfRun, cfNext, step, CFState.init, hs]

/-- `√21` has period `6`; the unit is `55 + 12√21`, of norm `+1`.  Since
`3 ∣ 21` and `3 ≡ 3 (mod 4)`, the negative-Pell branch is blocked. -/
theorem cf_21 : (cfRun 21 6).d = 1 ∧ (cfRun 21 6).h = 55 ∧ (cfRun 21 6).q = 12 ∧
    (cfRun 21 6).h ^ 2 - 21 * (cfRun 21 6).q ^ 2 = 1 := by
  have hs : Nat.sqrt 21 = 4 := by norm_num
  refine ⟨?_, ?_, ?_, ?_⟩ <;> simp [cfRun, cfNext, step, CFState.init, hs]

/-- The channel's factoring exit really does fire on `N = 21 = 3 · 7`: the
period-end unit `55` is a split square root of `1 mod 21`, and `gcd(54, 21) = 3`
is a proper divisor.  The catch is the cost: it took the full period `l = 6`. -/
theorem cf_21_factors : ∃ d : ℕ, d ∣ 21 ∧ 1 < d ∧ d < 21 :=
  pell_unit_splits 21 (by norm_num) 55 12 (by norm_num) (by decide) (by decide)

/-- `√65` has period `1` (the cheap window `65 = 8² + 1`); the unit is
`8 + √65`, of norm `-1`. -/
theorem cf_65 : (cfRun 65 1).d = 1 ∧ (cfRun 65 1).h = 8 ∧ (cfRun 65 1).q = 1 ∧
    (cfRun 65 1).h ^ 2 - 65 * (cfRun 65 1).q ^ 2 = -1 := by
  have hs : Nat.sqrt 65 = 8 := by norm_num
  refine ⟨?_, ?_, ?_, ?_⟩ <;> simp [cfRun, cfNext, step, CFState.init, hs]

/-- ... and on `65 = 5 · 13` (note `65 = 8² + 1`) that unit is worthless for
factoring: all three candidate gcds are `1`.  Instance of
`cheap_window_null_m2_add_one`. -/
theorem cf_65_no_factor :
    Int.gcd 8 (8 ^ 2 + 1) = 1 ∧ Int.gcd (8 - 1) (8 ^ 2 + 1) = 1 ∧
      Int.gcd (8 + 1) (8 ^ 2 + 1) = 1 :=
  cheap_window_null_m2_add_one 8 ⟨4, by norm_num⟩

/-- Instance of the blocked branch: every period-end unit of `√21` has
norm `+1`, because the prime `3 ≡ 3 (mod 4)` divides `21`. -/
theorem cf_21_norm_one (k : ℕ) (hd : (cfRun 21 k).d = 1) :
    (cfRun 21 k).h ^ 2 - 21 * (cfRun 21 k).q ^ 2 = 1 :=
  cf_unit_norm_one_of_three_mod_four 21 (nonsquare_of_sqrt 21 (by norm_num)) 3
    (by norm_num) (by norm_num) (by norm_num) k hd


/-! ## 11. The exit is *exactly* the split-root event: prime powers are immune

Cycle-2 result.  The only factor-adjacent exit of the channel (Section 4) fires
only when `N` has at least two distinct prime factors: modulo an odd prime power
every square root of `1` is `± 1`, so the continued fraction of `√(p^k)` — no
matter how long its period — can never split `N`. -/

/-- Modulo an odd prime power, the only square roots of `1` are `± 1`. -/
theorem sqrt_one_prime_pow (p : ℕ) (hp : p.Prime) (hodd : p ≠ 2) (k : ℕ) (x : ℤ)
    (hx : ((p : ℤ) ^ k) ∣ x ^ 2 - 1) :
    ((p : ℤ) ^ k) ∣ x - 1 ∨ ((p : ℤ) ^ k) ∣ x + 1 := by
  have hpZ : Prime (p : ℤ) := Nat.prime_iff_prime_int.mp hp
  have hfac : ((p : ℤ) ^ k) ∣ (x - 1) * (x + 1) := by
    obtain ⟨c, hc⟩ := hx
    exact ⟨c, by linear_combination hc⟩
  by_cases hdvd : (p : ℤ) ∣ x - 1
  · -- then `p ∤ x + 1`, since otherwise `p ∣ 2`
    by_cases hdvd2 : (p : ℤ) ∣ x + 1
    · exfalso
      have h2 : (p : ℤ) ∣ 2 := by
        have := dvd_sub hdvd2 hdvd
        simpa using this
      have hple : (p : ℕ) ∣ 2 := by exact_mod_cast h2
      rcases (Nat.dvd_prime Nat.prime_two).mp hple with h | h
      · exact hp.one_lt.ne' h
      · exact hodd h
    · left
      have hcop : IsCoprime ((p : ℤ) ^ k) (x + 1) :=
        (hpZ.coprime_iff_not_dvd.mpr hdvd2).pow_left
      exact hcop.dvd_of_dvd_mul_right hfac
  · right
    have hcop : IsCoprime ((p : ℤ) ^ k) (x - 1) :=
      (hpZ.coprime_iff_not_dvd.mpr hdvd).pow_left
    exact hcop.dvd_of_dvd_mul_left hfac

/-- **Prime powers are immune to the continued-fraction channel.**  For an odd
prime power `N = p^k`, every Pell unit `x² - N y² = 1` has `x ≡ ± 1 (mod N)`, so
the split-root exit of Section 4 never fires: the channel cannot produce a
factor even after paying the full `O(√N)` period cost. -/
theorem cf_channel_null_on_prime_powers (p : ℕ) (hp : p.Prime) (hodd : p ≠ 2)
    (k : ℕ) (x y : ℤ) (hxy : x ^ 2 - ((p : ℤ) ^ k) * y ^ 2 = 1) :
    ((p : ℤ) ^ k) ∣ x - 1 ∨ ((p : ℤ) ^ k) ∣ x + 1 :=
  sqrt_one_prime_pow p hp hodd k x ⟨y ^ 2, by linarith⟩

/-- Contrapositive packaging: if the channel *does* split `N`, then `N` has at
least two distinct prime factors.  Together with Section 6 (cheap windows give
trivial gcds) and Section 7 (small denominators are density-zero) this pins the
exact locus where the continued-fraction channel can factor at all. -/
theorem split_needs_two_primes (p : ℕ) (hp : p.Prime) (hodd : p ≠ 2) (k : ℕ)
    (x y : ℤ) (hxy : x ^ 2 - ((p : ℤ) ^ k) * y ^ 2 = 1)
    (hsplit : ¬ ((p : ℤ) ^ k) ∣ x - 1) : ((p : ℤ) ^ k) ∣ x + 1 :=
  (cf_channel_null_on_prime_powers p hp hodd k x y hxy).resolve_left hsplit


/-! ## 12. Cost side: denominators grow like Fibonacci, `d` stays `≤ 2⌊√N⌋`

Cycle-3 results.  The period-end witness is *exponentially large in the period*
(`q_l ≥ fib l`), while all the intermediate data stay inside the box
`0 ≤ m ≤ ⌊√N⌋`, `0 < d ≤ 2⌊√N⌋`.  So the channel's only unbounded coordinate is
the *number of steps*, which is what makes it a `O(√N)`-cost object rather than
a `poly(log N)` witness. -/

/-- All `d`-coordinates of the reduced regime lie in `(0, 2⌊√N⌋]`. -/
theorem cf_d_le_two_a0 (N : ℕ) (hN : ∀ z : ℤ, z ^ 2 ≠ (N : ℤ)) (hN1 : 1 ≤ N)
    (k : ℕ) : 0 < (cfRun N (k + 1)).d ∧ (cfRun N (k + 1)).d ≤ 2 * a0 N := by
  obtain ⟨hd, hm0, hmA, hdA, hAd⟩ := red_run N hN hN1 k
  exact ⟨hd, by linarith⟩

/-- Denominator growth in one step of the reduced regime: `q` obeys the
Fibonacci recursion with partial quotient `≥ 1`. -/
theorem q_growth_step (N : ℕ) (s : CFState) (hs : Red N s) (hq0 : 0 ≤ s.q) :
    s.q + s.qp ≤ (cfNext N s).q ∧ (cfNext N s).qp = s.q := by
  have ha1 : 1 ≤ (a0 N + s.m) / s.d := (partial_quotient_bounds N s hs).1
  refine ⟨?_, rfl⟩
  show s.q + s.qp ≤ ((a0 N + s.m) / s.d) * s.q + s.qp
  nlinarith

/-- **Fibonacci growth of the convergent denominators.**  For every non-square
`N ≥ 1`, the state after `k+1` steps has `qp ≥ fib k` and `q ≥ fib (k+1)`.
Hence a period of length `l` produces a Pell witness of size at least
`fib l ≍ φ^l`: the witness is exponential in the number of steps, which is why
the period, not the arithmetic, is the cost. -/
theorem cf_q_ge_fib (N : ℕ) (hN : ∀ z : ℤ, z ^ 2 ≠ (N : ℤ)) (hN1 : 1 ≤ N) :
    ∀ k : ℕ, ((Nat.fib k : ℤ) ≤ (cfRun N (k + 1)).qp ∧
      (Nat.fib (k + 1) : ℤ) ≤ (cfRun N (k + 1)).q) := by
  intro k
  induction k with
  | zero =>
      have hstate : cfRun N 1 = ⟨a0 N, (N : ℤ) - a0 N ^ 2, 1, a0 N, 0, 1⟩ := by
        simp [cfRun, cfNext, step, CFState.init, a0]
      rw [hstate]
      exact ⟨by simp, by simp⟩
  | succ k ih =>
      obtain ⟨ih1, ih2⟩ := ih
      have hred := red_run N hN hN1 k
      have ha1 : 1 ≤ (a0 N + (cfRun N (k + 1)).m) / (cfRun N (k + 1)).d :=
        (partial_quotient_bounds N _ hred).1
      have hqp : (cfRun N (k + 2)).qp = (cfRun N (k + 1)).q := rfl
      have hq : (cfRun N (k + 2)).q =
          ((a0 N + (cfRun N (k + 1)).m) / (cfRun N (k + 1)).d) * (cfRun N (k + 1)).q
            + (cfRun N (k + 1)).qp := rfl
      have hfib0 : (0 : ℤ) ≤ (Nat.fib k : ℤ) := by positivity
      have hfib1 : (0 : ℤ) ≤ (Nat.fib (k + 1) : ℤ) := by positivity
      refine ⟨by rw [hqp]; exact ih2, ?_⟩
      rw [hq, Nat.fib_add_two]
      push_cast
      nlinarith

end CFPeriodNull