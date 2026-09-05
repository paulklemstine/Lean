import Mathlib
import Physics.EcmStage2Wall

/-!
# The wall, exactly located: `lcm(1..B)`, the sharp firing threshold, and the true cost

`Catalog.Physics.EcmStage2Wall` showed that at `B ≥ p + 1 + 2√p` every Hasse-window
order divides the stage-1 scalar, that the resulting outcome under separated
accounting is `found_p` (never `dead`), and that the firing count is monotone in `B`
so no destruction wall can exist.

This file locates the phenomenon exactly and prices it.

* `stage1Scalar_eq_lcmUpTo`: the stage-1 scalar **is** `lcm(1, …, B)`.  This
  identifies the object in paper 159's sentence ("every Hasse-window order divides
  `lcm(1..B1)`") with the object the theory is about; the two ledgers describe the
  same scalar.
* `maxPrimePow`, `fires_iff_maxPrimePow_le`, `firingThreshold_isLeast`: firing at
  order `n` is a **sharp threshold** in `B`, located at the largest prime power
  exactly dividing `n`.  As a function of `B` the success indicator is a single
  step from `0` to `1`; `success_never_drops` records that it can never step down,
  which is the precise sense in which a "destruction wall" is not a possible shape.
* `prime_order_fires_iff`: for a curve of prime order `n` the threshold is `n`
  itself, so covering the whole Hasse window really does require `B ≳ p`.  The
  wall region is not a failure region, it is a *certainty* region.
* `two_pow_primeCount_le_stage1Scalar`, `primeCount_le_log_stage1Scalar`: what the
  certainty costs.  The stage-1 scalar has at least `π(B)` binary digits, so the
  ladder at `B ≈ p` performs at least `π(p)` doublings: the honest reading of the
  recorded "wall" is exponential cost, not method death.
* `gcd_le_pow_omega`, `dead_rate_le`: a quantitative ceiling on the simultaneous
  degeneracy ("dead") rate — `gcd(m, k(B)) ≤ B^{ω(m)}`, so the dead rate is at most
  `B^{ω(m)}/m`.
-/

namespace ECMWall

open ECMStage1 Finset

/-! ## The stage-1 scalar is `lcm(1..B)` -/

/-- `lcm(1, 2, …, B)`. -/
def lcmUpTo (B : ℕ) : ℕ := (Finset.Icc 1 B).lcm id

theorem lcmUpTo_ne_zero (B : ℕ) : lcmUpTo B ≠ 0 := by
  rw [lcmUpTo, Ne, Finset.lcm_eq_zero_iff]
  rintro ⟨x, hx, hx0⟩
  simp only [id] at hx0
  simp [hx0] at hx

/-- Every positive integer up to `B` divides the stage-1 scalar. -/
theorem lcmUpTo_dvd_stage1Scalar (B : ℕ) : lcmUpTo B ∣ stage1Scalar B := by
  refine Finset.lcm_dvd ?_
  intro n hn
  simp only [Finset.mem_Icc] at hn
  have h0 : n ≠ 0 := by omega
  have h1 : n ≤ B := hn.2
  simpa using fires_of_le h0 h1

theorem stage1Scalar_dvd_lcmUpTo (B : ℕ) : stage1Scalar B ∣ lcmUpTo B := by
  rcases Nat.eq_zero_or_pos B with rfl | hB
  · rw [stage1Scalar_zero]; exact one_dvd _
  rw [← Nat.factorization_le_iff_dvd (stage1Scalar_ne_zero B) (lcmUpTo_ne_zero B)]
  intro r
  by_cases hr : r.Prime
  · rw [stage1Scalar, stage1_factorization B B hr]
    by_cases hrB : r ≤ B
    · rw [if_pos hrB]
      have hpow : r ^ Nat.log r B ∈ Finset.Icc 1 B := by
        refine Finset.mem_Icc.mpr ⟨Nat.one_le_iff_ne_zero.mpr (pow_ne_zero _ hr.pos.ne'), ?_⟩
        exact Nat.pow_log_le_self r hB.ne'
      have hdvd : r ^ Nat.log r B ∣ lcmUpTo B :=
        Finset.dvd_lcm (f := id) hpow
      exact (Nat.Prime.pow_dvd_iff_le_factorization hr (lcmUpTo_ne_zero B)).mp hdvd
    · simp [hrB]
  · simp [Nat.factorization_eq_zero_of_not_prime _ hr]

/-- **The stage-1 scalar is exactly `lcm(1..B)`.**  Paper 159's `lcm(1..B1)` and the
prime-power schedule `∏_{q ≤ B} q^{⌊log_q B⌋}` are the same number. -/
theorem stage1Scalar_eq_lcmUpTo (B : ℕ) : stage1Scalar B = lcmUpTo B :=
  Nat.dvd_antisymm (stage1Scalar_dvd_lcmUpTo B) (lcmUpTo_dvd_stage1Scalar B)

/-! ## The sharp firing threshold -/

/-- The largest prime power exactly dividing `n` (`0` for `n = 1`). -/
def maxPrimePow (n : ℕ) : ℕ := n.primeFactors.sup (fun q => q ^ n.factorization q)

theorem powersmooth_iff_maxPrimePow_le {B n : ℕ} :
    Powersmooth B n ↔ maxPrimePow n ≤ B := by
  rw [maxPrimePow, Finset.sup_le_iff]
  rfl

theorem maxPrimePow_eq_zero_iff {n : ℕ} (hn : n ≠ 0) : maxPrimePow n = 0 ↔ n = 1 := by
  constructor
  · intro h
    have hempty : n.primeFactors = ∅ := by
      by_contra hne
      obtain ⟨q, hq⟩ := Finset.nonempty_iff_ne_empty.mpr hne
      have hle : q ^ n.factorization q ≤ maxPrimePow n :=
        Finset.le_sup (f := fun q => q ^ n.factorization q) hq
      have hpos : 0 < q ^ n.factorization q :=
        Nat.pow_pos (Nat.prime_of_mem_primeFactors hq).pos
      omega
    rcases Nat.primeFactors_eq_empty.mp hempty with h0 | h1
    · exact absurd h0 hn
    · exact h1
  · rintro rfl
    simp [maxPrimePow]

/-- **The exact firing criterion, in threshold form.**  An order `n` is killed by
the stage-1 scalar at bound `B` iff `B` has reached the largest prime power exactly
dividing `n`.  (No positivity assumption on `B` is needed.) -/
theorem fires_iff_maxPrimePow_le {n B : ℕ} (hn : n ≠ 0) :
    n ∣ stage1Scalar B ↔ maxPrimePow n ≤ B := by
  rcases Nat.eq_zero_or_pos B with rfl | hB
  · rw [stage1Scalar_zero, Nat.dvd_one, Nat.le_zero, maxPrimePow_eq_zero_iff hn]
  · rw [dvd_stage1Scalar_iff hn hB.ne', powersmooth_iff_maxPrimePow_le]

/-- **The firing threshold is `maxPrimePow n`**: it is the least smoothness bound at
which stage 1 succeeds on an order `n`, and success persists above it. -/
theorem firingThreshold_isLeast {n : ℕ} (hn : n ≠ 0) :
    IsLeast {B | n ∣ stage1Scalar B} (maxPrimePow n) :=
  ⟨(fires_iff_maxPrimePow_le hn).mpr le_rfl, fun _ hB => (fires_iff_maxPrimePow_le hn).mp hB⟩

/-- **A destruction wall is not a possible shape.**  The success indicator of a fixed
order is a single upward step in the bound: once stage 1 succeeds it never fails
again, so success cannot collapse above any threshold. -/
theorem success_never_drops {n B B' : ℕ} (hn : n ≠ 0) (hBB : B ≤ B')
    (h : n ∣ stage1Scalar B) : n ∣ stage1Scalar B' :=
  (fires_iff_maxPrimePow_le hn).mpr
    (le_trans ((fires_iff_maxPrimePow_le hn).mp h) hBB)

/-- For a curve of prime order the threshold is the order itself. -/
theorem prime_order_fires_iff {n B : ℕ} (hp : n.Prime) :
    n ∣ stage1Scalar B ↔ n ≤ B := by
  rw [fires_iff_maxPrimePow_le hp.pos.ne']
  have h : maxPrimePow n = n := by
    rw [maxPrimePow, hp.primeFactors]
    simp [hp.factorization_self]
  rw [h]

/-- Covering the whole Hasse window really does need `B ≳ p`: a prime order in the
window fires only once the bound reaches it. -/
theorem prime_order_requires_bound {n B : ℕ} (hp : n.Prime) (h : n ∣ stage1Scalar B) :
    n ≤ B := (prime_order_fires_iff hp).mp h

/-! ## What the certainty costs -/

/-- Each prime in the schedule contributes a factor at least `2`. -/
theorem two_pow_primeCount_le_stage1Scalar {B : ℕ} (hB : 1 ≤ B) :
    2 ^ primeCount B ≤ stage1Scalar B := by
  rw [stage1Scalar, stage1, primeCount]
  refine Finset.pow_card_le_prod _ _ _ ?_
  intro q hq
  simp only [Finset.mem_filter, Finset.mem_range, Nat.lt_succ_iff] at hq
  obtain ⟨hqB, hqp⟩ := hq
  have hlog : 1 ≤ Nat.log q B := (Nat.le_log_iff_pow_le hqp.one_lt (by omega)).mpr (by simpa)
  calc (2 : ℕ) = 2 ^ 1 := by norm_num
    _ ≤ q ^ 1 := Nat.pow_le_pow_left hqp.two_le 1
    _ ≤ q ^ Nat.log q B := Nat.pow_le_pow_right hqp.pos hlog

/-- **The wall region is an exponential-cost region.**  The stage-1 scalar carries at
least `π(B)` binary digits, so the stage-1 ladder at bound `B` performs at least
`π(B)` doublings.  At the recorded wall `B ≈ p` this is `≈ p / ln p` group
operations: the phenomenon is cost, not destruction. -/
theorem primeCount_le_log_stage1Scalar {B : ℕ} (hB : 1 ≤ B) :
    primeCount B ≤ Nat.log 2 (stage1Scalar B) :=
  (Nat.le_log_iff_pow_le one_lt_two (stage1Scalar_ne_zero B)).mpr
    (two_pow_primeCount_le_stage1Scalar hB)

/-! ## A ceiling on the simultaneous-degeneracy rate -/

/-- **`gcd(m, k(B)) ≤ B^{ω(m)}`.**  The firing count is a product of at most `ω(m)`
prime powers, each at most `B`. -/
theorem gcd_le_pow_omega {m B : ℕ} (hm : m ≠ 0) (hB : 1 ≤ B) :
    Nat.gcd m (stage1Scalar B) ≤ B ^ m.primeFactors.card := by
  set g := Nat.gcd m (stage1Scalar B) with hg
  have hgz : g ≠ 0 := Nat.gcd_ne_zero_left hm
  have hsm : Powersmooth B g :=
    (dvd_stage1Scalar_iff hgz (by omega)).mp (Nat.gcd_dvd_right _ _)
  have hsub : g.primeFactors ⊆ m.primeFactors :=
    Nat.primeFactors_mono (Nat.gcd_dvd_left _ _) hm
  have hprod : ∏ q ∈ g.primeFactors, q ^ g.factorization q = g := by
    have := Nat.factorization_prod_pow_eq_self hgz
    simpa [Finsupp.prod, Nat.support_factorization] using this
  calc g = ∏ q ∈ g.primeFactors, q ^ g.factorization q := hprod.symm
    _ ≤ B ^ g.primeFactors.card := Finset.prod_le_pow_card _ _ _ (fun q hq => hsm q hq)
    _ ≤ B ^ m.primeFactors.card := Nat.pow_le_pow_right hB (Finset.card_le_card hsub)

/-- The simultaneous-degeneracy ("dead") rate at the large prime is at most
`B^{ω(m)}/m`. -/
theorem dead_rate_le {m B : ℕ} (hm : 0 < m) (hB : 1 ≤ B) :
    ((firingSet m (stage1Scalar B)).card : ℝ) / m ≤ (B : ℝ) ^ m.primeFactors.card / m := by
  rw [card_firingSet _ _ hm]
  have h : (Nat.gcd m (stage1Scalar B) : ℝ) ≤ (B : ℝ) ^ m.primeFactors.card := by
    exact_mod_cast gcd_le_pow_omega hm.ne' hB
  have hm' : (0 : ℝ) < m := by exact_mod_cast hm
  gcongr

/-! ## Where the real wall is: `max(p,q)`, not `min(p,q)` -/

/-- **Death needs *both* windows.**  Simultaneous degeneracy — the `dead` outcome,
where the guarded inversion returns `gcd = N` — occurs precisely when the bound
covers the Hasse windows of *both* prime factors.  Its threshold is therefore
`max(p,q)`, not `min(p,q)`. -/
theorem dead_of_both_windows_covered {Gp Gq : Type*} [Group Gp] [Group Gq]
    [Finite Gp] [Finite Gq] {p q B : ℕ} (hBp : hasseCeil p ≤ B) (hBq : hasseCeil q ≤ B)
    (hp : (Nat.card Gp : ℝ) ≤ (p : ℝ) + 1 + 2 * Real.sqrt p)
    (hq : (Nat.card Gq : ℝ) ≤ (q : ℝ) + 1 + 2 * Real.sqrt q) (gp : Gp) (gq : Gq) :
    outcomeOf (gp ^ stage1Scalar B = 1) (gq ^ stage1Scalar B = 1) = Outcome.dead := by
  refine outcomeOf_eq_dead_iff.mpr ⟨every_point_fires_at_wall hBp hp gp,
    every_point_fires_at_wall hBq hq gq⟩

/-- **The corrected wall sentence.**  Between the two windows — bound past the top of
`p`'s window but below the largest prime power of the mod-`q` order — the outcome is
`found_p`; only once the bound also covers `q`'s window does the run go `dead`.  The
recorded threshold `min(p,q)` is the *success* threshold; the *destruction* threshold
is `max(p,q)`. -/
theorem wall_dichotomy {Gp Gq : Type*} [Group Gp] [Group Gq] [Finite Gp] [Finite Gq]
    {p q B B' r : ℕ} (hBne : B ≠ 0) (hBp : hasseCeil p ≤ B)
    (hp : (Nat.card Gp : ℝ) ≤ (p : ℝ) + 1 + 2 * Real.sqrt p)
    (hq : (Nat.card Gq : ℝ) ≤ (q : ℝ) + 1 + 2 * Real.sqrt q)
    (gp : Gp) (gq : Gq) (hr : r ∈ (orderOf gq).primeFactors) (hrB : B < r)
    (hB'p : hasseCeil p ≤ B') (hB'q : hasseCeil q ≤ B') :
    outcomeOf (gp ^ stage1Scalar B = 1) (gq ^ stage1Scalar B = 1) = Outcome.foundP ∧
      outcomeOf (gp ^ stage1Scalar B' = 1) (gq ^ stage1Scalar B' = 1) = Outcome.dead :=
  ⟨wall_yields_foundP hBp hBne hp gp gq hr hrB,
    dead_of_both_windows_covered hB'p hB'q hp hq gp gq⟩

/-! ## Numeric witnesses for the threshold -/

theorem stage1Scalar_four : stage1Scalar 4 = 12 := by decide

theorem stage1Scalar_three : stage1Scalar 3 = 6 := by decide

theorem maxPrimePow_twelve : maxPrimePow 12 = 4 := by
  have hle : maxPrimePow 12 ≤ 4 := by
    refine (fires_iff_maxPrimePow_le (by norm_num)).mp ?_
    rw [stage1Scalar_four]
  have hgt : ¬ maxPrimePow 12 ≤ 3 := by
    intro hcon
    have := (fires_iff_maxPrimePow_le (n := 12) (by norm_num)).mpr hcon
    rw [stage1Scalar_three] at this
    omega
  omega

/-- Order `12` (a Hasse-window order for `𝔽₁₃`) fires from bound `4` onwards — far
below the alleged validity edge `p/2 = 6.5`, and it never stops firing. -/
theorem twelve_fires_iff (B : ℕ) : (12 : ℕ) ∣ stage1Scalar B ↔ 4 ≤ B := by
  rw [fires_iff_maxPrimePow_le (by norm_num), maxPrimePow_twelve]

/-- A prime order in the Hasse window of `p = 13`: `13 ∣ k(B)` iff `B ≥ 13`.  The
last Hasse-window orders to be covered are the prime ones, at `B ≈ p`. -/
theorem thirteen_fires_iff (B : ℕ) : (13 : ℕ) ∣ stage1Scalar B ↔ 13 ≤ B :=
  prime_order_fires_iff (by norm_num)

end ECMWall