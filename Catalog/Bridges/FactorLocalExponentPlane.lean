import Mathlib
import Shared.ECMStage1OrderCompletion

/-!
# The factor-local exponent plane: three exact laws and their arm-invariance

Experiment 486-full fitted a cost law `T ≈ c · p^α` (with `p = min` prime factor of the
semiprime `N = p·q`) separately for trial division, Pollard rho and Fermat, on several
"arms" (different laws for the second prime `q`).  The measured exponents were
`α_td = 1.0009 [1.000, 1.002]`, `α_rho = 0.4994 [0.485, 0.510]`,
`α_fermat = 0.9932`, with `td`/`rho` first-order arm-invariant and Fermat strongly
non-invariant.

This file proves the three exact laws that those three numbers are measuring, and the
invariance dichotomy, unconditionally.

## Trial division: `α = 1` on the nose

`tdCost N = Nat.minFac N` is the last (and largest) trial divisor examined.  For a
semiprime it is *exactly* the smaller prime (`td_cost_semiprime`), so
`log_p (cost) = 1` exactly (`td_exponent_exact`) — no fitted constant, no error term.
It is also *exactly* arm-invariant (`td_arm_invariant`): the cost does not depend on
`q` at all.

## Pollard rho: `α = 1/2`, two-sided

With the standard model "the iteration visits uniform independent residues in a set of
size `m ≈ p`", the probability of no collision in `t` draws is exactly
`m^{\underline t} / m^t` (`noCollisionRatio`).  We prove the two matching bounds
`1 - t(t-1)/(2m) ≤ ratio ≤ exp(-t(t-1)/(2m))`
(`one_sub_le_noCollisionRatio`, `noCollisionRatio_le_exp`), whose consequence
(`birthday_threshold_two_sided`) pins the constant-probability threshold to the window
`√m ≤ T(m) ≤ 1 + √(2 log 2)·√m`.  Both bounds have the *same* exponent `1/2`; that is
what "birthday bound to three decimals" means.

## Fermat: the exact `p/2` law

`fermat_first_hit` and `fermat_no_earlier_hit` prove that Fermat's method applied to a
semiprime `N = p·q` (odd primes, `p < q`) halts at *exactly* `x = (p+q)/2` and at no
smaller `x` — the only alternative representation `N = 1 · N` occurs later.  The
resulting real gap `fermatGap p q = (p+q)/2 - √(pq) = (√q - √p)²/2`
(`fermat_gap_eq`) is `Θ(p)` on a bounded-ratio arm (`fermat_gap_lower`,
`fermat_gap_upper`), i.e. `α = 1`; and it is *strictly increasing in `q`*
(`fermat_arm_not_invariant`), so Fermat's exponent fit must move when the arm moves.

`exponent_plane` collects the three laws into a single statement about one semiprime.
-/

namespace FactorPlane

open Finset

/-! ## Trial division -/

/-- The largest trial divisor a textbook trial-division run examines before reporting a
factor of `N`: the smallest nontrivial divisor of `N`. -/
def tdCost (N : ℕ) : ℕ := Nat.minFac N

/-- For a semiprime the trial-division cost is *exactly* the smaller prime. -/
theorem td_cost_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≤ q) :
    tdCost (p * q) = p := by
  show Nat.minFac (p * q) = p
  have hdvd : p ∣ p * q := Dvd.intro q rfl
  have hle : Nat.minFac (p * q) ≤ p := Nat.minFac_le_of_dvd hp.two_le hdvd
  have hne : p * q ≠ 1 := by
    have := hp.one_lt
    nlinarith [hq.one_lt]
  have hmp : (Nat.minFac (p * q)).Prime := Nat.minFac_prime hne
  have hmd : Nat.minFac (p * q) ∣ p * q := Nat.minFac_dvd _
  have : Nat.minFac (p * q) = p ∨ Nat.minFac (p * q) = q := by
    rcases (Nat.Prime.dvd_mul hmp).mp hmd with h | h
    · exact Or.inl ((Nat.prime_dvd_prime_iff_eq hmp hp).mp h)
    · exact Or.inr ((Nat.prime_dvd_prime_iff_eq hmp hq).mp h)
  rcases this with h | h
  · exact h
  · omega

/-- **Exact arm invariance of trial division.**  The cost depends on the small prime
only; the law of the second prime is invisible to it. -/
theorem td_arm_invariant {p q q' : ℕ} (hp : p.Prime) (hq : q.Prime) (hq' : q'.Prime)
    (h : p ≤ q) (h' : p ≤ q') : tdCost (p * q) = tdCost (p * q') := by
  rw [td_cost_semiprime hp hq h, td_cost_semiprime hp hq' h']

/-- **`α = 1` exactly**: the fitted exponent of trial division is not approximately one,
it is one, with constant one. -/
theorem td_exponent_exact {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≤ q) :
    Real.logb p (tdCost (p * q)) = 1 := by
  rw [td_cost_semiprime hp hq hpq]
  have h1 : (1 : ℝ) < p := by exact_mod_cast hp.one_lt
  exact Real.logb_self_eq_one h1

/-! ## Pollard rho: the birthday exponent `1/2` -/

/-- Probability that `t` uniform independent draws from a set of size `m` are pairwise
distinct: the falling factorial over `m^t`. -/
noncomputable def noCollisionRatio (m t : ℕ) : ℝ := (m.descFactorial t : ℝ) / (m : ℝ) ^ t

theorem sum_range_cast (t : ℕ) : ∑ i ∈ range t, (i : ℝ) = (t : ℝ) * ((t : ℝ) - 1) / 2 := by
  induction t with
  | zero => simp
  | succ n ih =>
      rw [Finset.sum_range_succ, ih]
      push_cast
      ring

theorem noCollisionRatio_eq_prod {m t : ℕ} (hm : 0 < m) (ht : t ≤ m) :
    noCollisionRatio m t = ∏ i ∈ range t, (1 - (i : ℝ) / m) := by
  have hm0 : (m : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hm.ne'
  rw [noCollisionRatio, Nat.descFactorial_eq_prod_range, Nat.cast_prod]
  rw [show ((m : ℝ)) ^ t = ∏ _i ∈ range t, (m : ℝ) by simp]
  rw [← Finset.prod_div_distrib]
  refine Finset.prod_congr rfl ?_
  intro i hi
  have hi' : i ≤ m := le_trans (le_of_lt (Finset.mem_range.mp hi)) ht
  rw [Nat.cast_sub hi']
  field_simp

/-- **Weierstrass product inequality** (proved here by induction): a product of factors
`1 - xᵢ` with `xᵢ ∈ [0,1]` is at least `1 - ∑ xᵢ`. -/
theorem one_sub_sum_le_prod (t : ℕ) (x : ℕ → ℝ) (h0 : ∀ i ∈ range t, 0 ≤ x i)
    (h1 : ∀ i ∈ range t, x i ≤ 1) :
    1 - ∑ i ∈ range t, x i ≤ ∏ i ∈ range t, (1 - x i) := by
  induction t with
  | zero => simp
  | succ n ih =>
      have h0' : ∀ i ∈ range n, 0 ≤ x i := fun i hi =>
        h0 i (Finset.mem_range.mpr (lt_trans (Finset.mem_range.mp hi) (Nat.lt_succ_self n)))
      have h1' : ∀ i ∈ range n, x i ≤ 1 := fun i hi =>
        h1 i (Finset.mem_range.mpr (lt_trans (Finset.mem_range.mp hi) (Nat.lt_succ_self n)))
      have hmem : n ∈ range (n + 1) := Finset.self_mem_range_succ n
      have hxn0 : 0 ≤ x n := h0 n hmem
      have hxn1 : x n ≤ 1 := h1 n hmem
      have hS : 0 ≤ ∑ i ∈ range n, x i := Finset.sum_nonneg h0'
      have hstep := ih h0' h1'
      rw [Finset.prod_range_succ, Finset.sum_range_succ]
      have hmul : (1 - ∑ i ∈ range n, x i) * (1 - x n)
          ≤ (∏ i ∈ range n, (1 - x i)) * (1 - x n) :=
        mul_le_mul_of_nonneg_right hstep (by linarith)
      nlinarith [hstep, hS, hxn0, hxn1]

/-- **Birthday upper bound.**  The no-collision probability decays at least as fast as
`exp(-t(t-1)/2m)`. -/
theorem noCollisionRatio_le_exp {m t : ℕ} (hm : 0 < m) (ht : t ≤ m) :
    noCollisionRatio m t ≤ Real.exp (-((t : ℝ) * ((t : ℝ) - 1)) / (2 * m)) := by
  have hm0 : (0 : ℝ) < m := by exact_mod_cast hm
  rw [noCollisionRatio_eq_prod hm ht]
  have hbound : ∏ i ∈ range t, (1 - (i : ℝ) / m) ≤ ∏ i ∈ range t, Real.exp (-((i : ℝ) / m)) := by
    refine Finset.prod_le_prod ?_ ?_
    · intro i hi
      have hi' : (i : ℝ) ≤ m := by
        have := le_trans (le_of_lt (Finset.mem_range.mp hi)) ht
        exact_mod_cast this
      have : (i : ℝ) / m ≤ 1 := (div_le_one hm0).mpr hi'
      linarith
    · intro i hi
      have := Real.add_one_le_exp (-((i : ℝ) / m))
      linarith
  refine le_trans hbound ?_
  have hsum : (∑ i ∈ range t, -((i : ℝ) / m)) = -((t : ℝ) * ((t : ℝ) - 1)) / (2 * m) := by
    have hstep : (∑ i ∈ range t, -((i : ℝ) / m)) = -(∑ i ∈ range t, (i : ℝ)) / m := by
      simp [Finset.sum_div, neg_div]
    rw [hstep, sum_range_cast]
    field_simp
  rw [← Real.exp_sum, hsum]

/-- **Birthday lower bound.**  The no-collision probability is at least
`1 - t(t-1)/2m`: below `t ≈ √m` the collision probability is genuinely small, so the
exponent `1/2` is not an artefact of the upper bound. -/
theorem one_sub_le_noCollisionRatio {m t : ℕ} (hm : 0 < m) (ht : t ≤ m) :
    1 - (t : ℝ) * ((t : ℝ) - 1) / (2 * m) ≤ noCollisionRatio m t := by
  have hm0 : (0 : ℝ) < m := by exact_mod_cast hm
  rw [noCollisionRatio_eq_prod hm ht]
  have key := one_sub_sum_le_prod t (fun i => (i : ℝ) / m) ?_ ?_
  · refine le_trans ?_ key
    have hsum : (∑ i ∈ range t, (i : ℝ) / m) = (t : ℝ) * ((t : ℝ) - 1) / (2 * m) := by
      rw [← Finset.sum_div, sum_range_cast]
      field_simp
    rw [hsum]
  · intro i _
    positivity
  · intro i hi
    have hi' : (i : ℝ) ≤ m := by
      have := le_trans (le_of_lt (Finset.mem_range.mp hi)) ht
      exact_mod_cast this
    exact (div_le_one hm0).mpr hi'

/-- **The birthday threshold is two-sided at exponent `1/2`.**  Below `t(t-1) ≤ m` the
collision probability is at most `1/2`; above `t ≥ 1 + √(2 log 2)·√m` it is at least
`1/2`.  The constant-probability threshold therefore sits in `[√m, 1 + 1.178·√m]`:
`α = 1/2` with a pinned constant, matching the measured `0.4994 [0.485, 0.510]`. -/
theorem birthday_threshold_two_sided {m t : ℕ} (hm : 0 < m) (ht : t ≤ m) :
    ((t : ℝ) * ((t : ℝ) - 1) ≤ m → 1 - noCollisionRatio m t ≤ 1 / 2) ∧
    (1 + Real.sqrt (2 * m * Real.log 2) ≤ t → 1 / 2 ≤ 1 - noCollisionRatio m t) := by
  have hm0 : (0 : ℝ) < m := by exact_mod_cast hm
  constructor
  · intro h
    have hlow := one_sub_le_noCollisionRatio hm ht
    have : (t : ℝ) * ((t : ℝ) - 1) / (2 * m) ≤ 1 / 2 := by
      rw [div_le_iff₀ (by positivity : (0 : ℝ) < 2 * m)]
      linarith
    linarith
  · intro h
    have hup := noCollisionRatio_le_exp hm ht
    have hlog : (0 : ℝ) ≤ 2 * m * Real.log 2 := by
      have : (0 : ℝ) ≤ Real.log 2 := Real.log_nonneg (by norm_num)
      positivity
    have hs : Real.sqrt (2 * m * Real.log 2) ^ 2 = 2 * m * Real.log 2 :=
      Real.sq_sqrt hlog
    have hs0 : 0 ≤ Real.sqrt (2 * m * Real.log 2) := Real.sqrt_nonneg _
    have ht1 : Real.sqrt (2 * m * Real.log 2) ≤ (t : ℝ) - 1 := by linarith
    have hsq : 2 * m * Real.log 2 ≤ ((t : ℝ) - 1) ^ 2 := by
      calc 2 * m * Real.log 2 = Real.sqrt (2 * m * Real.log 2) ^ 2 := hs.symm
        _ ≤ ((t : ℝ) - 1) ^ 2 := by nlinarith
    have htge : (1 : ℝ) ≤ (t : ℝ) := by linarith
    have hprod : ((t : ℝ) - 1) ^ 2 ≤ (t : ℝ) * ((t : ℝ) - 1) := by nlinarith
    have hkey : Real.log 2 ≤ (t : ℝ) * ((t : ℝ) - 1) / (2 * m) := by
      rw [le_div_iff₀ (by positivity)]
      nlinarith
    have hexp : Real.exp (-((t : ℝ) * ((t : ℝ) - 1)) / (2 * m)) ≤ 1 / 2 := by
      have : Real.exp (-((t : ℝ) * ((t : ℝ) - 1)) / (2 * m)) ≤ Real.exp (-Real.log 2) := by
        apply Real.exp_le_exp.mpr
        rw [neg_div]
        linarith
      calc Real.exp (-((t : ℝ) * ((t : ℝ) - 1)) / (2 * m)) ≤ Real.exp (-Real.log 2) := this
        _ = 1 / 2 := by
            rw [Real.exp_neg, Real.exp_log (by norm_num)]
            norm_num
    linarith

/-! ## Fermat: the exact halting point -/

/-- **Fermat's method hits at `x = (p+q)/2`.**  With `x = (p+q)/2` and `y = (q-p)/2`,
`x² - N` is the perfect square `y²`. -/
theorem fermat_first_hit {p q x y : ℕ} (hpq : p ≤ q) (hx : 2 * x = p + q)
    (hy : 2 * y = q - p) : x * x = p * q + y * y := by
  have h : x = y + p := by omega
  subst h
  nlinarith [hx, hy]

/-- **And never before.**  For `N = p·q` a product of two primes with `p < q`, no
`x < (p+q)/2` makes `x² - N` a perfect square: the only other factorisation `N = 1·N`
produces the strictly later `x = (N+1)/2`.  Fermat's step count on a semiprime is
therefore *exactly* `(p+q)/2 - ⌈√N⌉`. -/
theorem fermat_no_earlier_hit {p q x x₀ y : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≤ q)
    (hx₀ : 2 * x₀ = p + q) (hlt : x < x₀) : x * x ≠ p * q + y * y := by
  intro hxy
  have hyx : y < x := by nlinarith [hp.pos, hq.pos]
  have hfac : (x - y) * (x + y) = p * q := by
    have h1 : x - y + y = x := by omega
    nlinarith [hxy, h1]
  set d := x - y with hd
  have hdle : d ≤ x + y := by omega
  have hdvd : d ∣ p * q := ⟨x + y, hfac.symm⟩
  have hcase : d = 1 ∨ d = p ∨ d = q ∨ d = p * q := by
    by_cases hpd : p ∣ d
    · obtain ⟨k, hk⟩ := hpd
      have hkq : k ∣ q := by
        have : p * k * (x + y) = p * q := by rw [← hk]; exact hfac
        have hp0 : 0 < p := hp.pos
        have : k * (x + y) = q := by
          have := this
          nlinarith [this, hp0]
        exact ⟨x + y, this.symm⟩
      rcases (Nat.dvd_prime hq).mp hkq with rfl | rfl
      · exact Or.inr (Or.inl (by omega))
      · exact Or.inr (Or.inr (Or.inr (by omega)))
    · have hcop : Nat.Coprime d p := ((Nat.Prime.coprime_iff_not_dvd hp).mpr hpd).symm
      have hdq : d ∣ q := Nat.Coprime.dvd_of_dvd_mul_left hcop hdvd
      rcases (Nat.dvd_prime hq).mp hdq with h1 | h1
      · exact Or.inl h1
      · exact Or.inr (Or.inr (Or.inl h1))
  have hsum : d + (x + y) = 2 * x := by omega
  rcases hcase with h | h | h | h
  · -- d = 1, so x + y = p*q and 2x = 1 + p*q ≥ p + q
    have hxy' : x + y = p * q := by
      rw [h] at hfac; omega
    have : 2 * x = 1 + p * q := by omega
    nlinarith [hp.two_le, hq.two_le]
  · -- d = p, so x + y = q and 2x = p + q, contradicting x < x₀
    have hxy' : x + y = q := by
      have hp0 : 0 < p := hp.pos
      rw [h] at hfac
      nlinarith [hfac, hp0]
    omega
  · -- d = q forces q ≤ x + y = p, impossible unless p = q, handled by the size bound
    have hxy' : x + y = p := by
      have hq0 : 0 < q := hq.pos
      rw [h] at hfac
      nlinarith [hfac, hq0]
    have : q ≤ p := by omega
    have hpq' : p = q := by omega
    subst hpq'
    omega
  · -- d = p*q forces x + y = 1
    have hxy' : x + y = 1 := by
      rw [h] at hfac
      have hpos : 0 < p * q := Nat.mul_pos hp.pos hq.pos
      nlinarith [hfac, hpos]
    have h2 : p * q ≤ 1 := by omega
    nlinarith [hp.two_le, hq.two_le]

/-- **Fermat's method on a semiprime: the exact halting point.**  For odd primes
`p ≤ q` the halting abscissa is `x₀ = (p+q)/2` and nothing happens before it — the
`p/2` law in exact form (`IsLeast` over the set of successful abscissae). -/
theorem fermat_halts_exactly {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hop : Odd p)
    (hoq : Odd q) (hpq : p ≤ q) :
    ∃ x₀ y₀ : ℕ, 2 * x₀ = p + q ∧ x₀ * x₀ = p * q + y₀ * y₀ ∧
      ∀ x < x₀, ∀ y, x * x ≠ p * q + y * y := by
  obtain ⟨a, ha⟩ := hop
  obtain ⟨b, hb⟩ := hoq
  refine ⟨a + b + 1, b - a, by omega, ?_, ?_⟩
  · exact fermat_first_hit hpq (by omega) (by omega)
  · intro x hx y
    exact fermat_no_earlier_hit hp hq hpq (x₀ := a + b + 1) (by omega) hx

/-- The bounded-ratio arm of `exponent_plane` is non-empty: `N = 3 · 7` satisfies every
hypothesis, so the plane statement is not vacuous. -/
theorem exponent_plane_arm_nonempty :
    Nat.Prime 3 ∧ Nat.Prime 7 ∧ 2 * 3 ≤ 7 ∧ 7 ≤ 4 * 3 := by
  refine ⟨by norm_num, by norm_num, by norm_num, by norm_num⟩

/-! ## The Fermat gap and its arm dependence -/

/-- The real Fermat gap: how far past `√N` the method must walk. -/
noncomputable def fermatGap (p q : ℕ) : ℝ := ((p : ℝ) + q) / 2 - Real.sqrt ((p : ℝ) * q)

/-- The closed form `(√q - √p)²/2`. -/
theorem fermat_gap_eq (p q : ℕ) :
    fermatGap p q = (Real.sqrt q - Real.sqrt p) ^ 2 / 2 := by
  have hp : Real.sqrt p ^ 2 = (p : ℝ) := Real.sq_sqrt (Nat.cast_nonneg p)
  have hq : Real.sqrt q ^ 2 = (q : ℝ) := Real.sq_sqrt (Nat.cast_nonneg q)
  have hmul : Real.sqrt ((p : ℝ) * q) = Real.sqrt p * Real.sqrt q :=
    Real.sqrt_mul (Nat.cast_nonneg p) _
  rw [fermatGap, hmul]
  nlinarith [hp, hq]

/-- **`α = 1`, lower half.**  On any arm with `q ≥ 2p`, the Fermat gap is at least
`p/12`: linear in the small prime. -/
theorem fermat_gap_lower {p q : ℕ} (hp : 0 < p) (h : 2 * p ≤ q) :
    (p : ℝ) / 12 ≤ fermatGap p q := by
  have hp0 : (0 : ℝ) < p := by exact_mod_cast hp
  have hq0 : (0 : ℝ) ≤ q := Nat.cast_nonneg q
  have hle : 2 * (p : ℝ) ≤ q := by exact_mod_cast h
  have hs : Real.sqrt ((p : ℝ) * q) ^ 2 = (p : ℝ) * q :=
    Real.sq_sqrt (by positivity)
  have hs0 : 0 ≤ Real.sqrt ((p : ℝ) * q) := Real.sqrt_nonneg _
  rw [fermatGap]
  nlinarith [hs, hs0, hp0, hle]

/-- **`α = 1`, upper half.**  On a bounded-ratio arm `q ≤ 4p` the gap is at most
`5p/2`.  Together with `fermat_gap_lower` this is `Θ(p)`: exponent exactly `1`. -/
theorem fermat_gap_upper {p q : ℕ} (h : q ≤ 4 * p) : fermatGap p q ≤ 5 * (p : ℝ) / 2 := by
  have hle : (q : ℝ) ≤ 4 * p := by exact_mod_cast h
  have hs0 : 0 ≤ Real.sqrt ((p : ℝ) * q) := Real.sqrt_nonneg _
  rw [fermatGap]
  linarith

/-- **Fermat is strongly arm-dependent.**  For a fixed small prime `p`, the gap is
strictly increasing in the second prime: any change of the `q`-law moves the cost, so no
single `(α, c)` can be arm-invariant for Fermat.  Contrast `td_arm_invariant`. -/
theorem fermat_arm_not_invariant {p q q' : ℕ} (hp : 0 < p) (hpq : p ≤ q) (hlt : q < q') :
    fermatGap p q < fermatGap p q' := by
  have hp0 : (0 : ℝ) < p := by exact_mod_cast hp
  have hqq : (q : ℝ) < q' := by exact_mod_cast hlt
  have hpq' : (p : ℝ) ≤ q := by exact_mod_cast hpq
  have h1 : Real.sqrt p ≤ Real.sqrt q := Real.sqrt_le_sqrt hpq'
  have h2 : Real.sqrt q < Real.sqrt q' := by
    exact Real.sqrt_lt_sqrt (Nat.cast_nonneg q) hqq
  have hnn : 0 ≤ Real.sqrt q - Real.sqrt p := by linarith
  rw [fermat_gap_eq, fermat_gap_eq]
  have : (Real.sqrt q - Real.sqrt p) ^ 2 < (Real.sqrt q' - Real.sqrt p) ^ 2 := by
    nlinarith
  linarith

/-! ## The plane -/

/-- **The measured plane, proved.**  For a semiprime `N = p·q` on a bounded-ratio arm
(`2p ≤ q ≤ 4p`, both prime):

* trial division costs *exactly* `p` — exponent `1`, constant `1`;
* Fermat's gap is between `p/12` and `5p/2` — exponent `1`, constant pinned;
* the rho/birthday collision threshold is two-sided at `√p` — exponent `1/2`.

These are the three exact laws behind the fitted `1.0009 / 0.9932 / 0.4994`. -/
theorem exponent_plane {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (h2 : 2 * p ≤ q) (h4 : q ≤ 4 * p) :
    tdCost (p * q) = p ∧
    ((p : ℝ) / 12 ≤ fermatGap p q ∧ fermatGap p q ≤ 5 * (p : ℝ) / 2) ∧
    (∀ t : ℕ, t ≤ p → (t : ℝ) * ((t : ℝ) - 1) ≤ p → 1 - noCollisionRatio p t ≤ 1 / 2) ∧
    (∀ t : ℕ, t ≤ p → 1 + Real.sqrt (2 * p * Real.log 2) ≤ t →
      1 / 2 ≤ 1 - noCollisionRatio p t) := by
  have hple : p ≤ q := by have := hp.two_le; omega
  refine ⟨td_cost_semiprime hp hq hple,
    ⟨fermat_gap_lower hp.pos h2, fermat_gap_upper h4⟩, ?_, ?_⟩
  · intro t ht hsmall
    exact (birthday_threshold_two_sided hp.pos ht).1 hsmall
  · intro t ht hbig
    exact (birthday_threshold_two_sided hp.pos ht).2 hbig

/-- **The invariance dichotomy.**  On the same two arms `q` and `q'`, trial division
returns literally the same cost while Fermat's cost strictly changes. -/
theorem arm_invariance_dichotomy {p q q' : ℕ} (hp : p.Prime) (hq : q.Prime) (hq' : q'.Prime)
    (h : p ≤ q) (hlt : q < q') :
    tdCost (p * q) = tdCost (p * q') ∧ fermatGap p q < fermatGap p q' :=
  ⟨td_arm_invariant hp hq hq' h (le_of_lt (lt_of_le_of_lt h hlt)),
   fermat_arm_not_invariant hp.pos h hlt⟩

end FactorPlane