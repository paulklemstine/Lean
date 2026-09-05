import Mathlib
import Shared.ECMStage1OrderCompletion

/-!
# The ECM self-destruction wall and its validity edge

`Shared.ECMStage1OrderCompletion` established that a stage-1 ECM run at smoothness
bound `B` kills a point of order `n` **exactly** when `n` is `B`-powersmooth
(`ECMStage1.dvd_stage1Scalar_iff`).  That equivalence is a statement about one prime
of the modulus.  Experiment 486-full measured the *joint* object: a stage-1 run on
`N = p·q` is only useful when the two local events — "the order dies mod `p`" and
"the order dies mod `q`" — *disagree*.  The measurement refused to produce a single
cost exponent `α` for ECM on the toy range, and the reason turned out to be
structural rather than statistical.  This file proves that reason.

## The wall

Every group order occurring for an elliptic curve over `𝔽_p` lies in the Hasse window
`|n - (p+1)| ≤ 2√p`.  If the smoothness bound `B` is pushed past the top of that
window, then **every** conceivable order `n` satisfies `n ≤ B`, hence is trivially
`B`-powersmooth, hence divides the stage-1 scalar `k(B) = lcm(1,…,B)`.  Once this
happens at *both* primes, every curve degenerates simultaneously: the stage-1 gcd is
the whole modulus `N`, no curve ever splits, and the uncapped expected number of
curves is infinite.

* `powersmooth_of_le`, `dvd_stage1Scalar_of_le` — size forces powersmoothness.
* `wall_degenerate`, `wall_never_splits`, `wall_success_count_zero` — the wall.
* `one_sided_crossing_splits` — crossing the wall at only **one** prime is the exact
  opposite of fatal: the run then splits *deterministically*.  Degeneration is a
  genuinely joint phenomenon, which is why the honest validity condition involves
  `min (p, q)`.
* `hasseWindow_gt_of_two_mul_le` — **the validity edge**.  If `2·B ≤ p` (and `p ≥ 19`)
  then every order in the Hasse window at `p` strictly exceeds `B`, so the size
  mechanism above is completely inactive: below `B ≈ min(p,q)/2` a degeneration can
  only come from genuine powersmoothness, never from the wall.
* `allDegenerate_mono`, `not_allDegenerate_of_prime_in_window`,
  `wall_101_sandwich` — the wall is a monotone threshold in `B`, it cannot switch on
  before the largest prime of the window, and for `p = 101` it is pinned to
  `113 ≤ B*(101) ≤ 124`.
* `lpf_omega_blind_to_firing` — **H2b refuted, in family form**.  For every bound
  `B ≥ 2` there are two orders with the *same* largest prime factor and the *same*
  number of distinct prime factors, one of which fires and the other of which does
  not.  No `lpf`/`ω` proxy can be a function determining stage-1 firing; only
  powersmoothness is.
-/

namespace ECMWall

open Finset ECMStage1

/-! ## An integer Hasse window -/

/-- Lower end of an integer enclosure of the Hasse interval `[p+1-2√p, p+1+2√p]`. -/
def hasseLower (p : ℕ) : ℕ := p + 1 - 2 * (Nat.sqrt p + 1)

/-- Upper end of an integer enclosure of the Hasse interval. -/
def hasseUpper (p : ℕ) : ℕ := p + 1 + 2 * (Nat.sqrt p + 1)

/-- The integer Hasse window: a finite superset of the set of possible group orders
`#E(𝔽_p)`. -/
def hasseWindow (p : ℕ) : Finset ℕ := Finset.Icc (hasseLower p) (hasseUpper p)

theorem real_sqrt_lt_natSqrt_succ (p : ℕ) : Real.sqrt p < (Nat.sqrt p : ℝ) + 1 := by
  have hpos : (0 : ℝ) < (Nat.sqrt p : ℝ) + 1 := by positivity
  have h : (p : ℝ) < ((Nat.sqrt p : ℝ) + 1) ^ 2 := by
    have hn : p < (Nat.sqrt p + 1) ^ 2 := Nat.lt_succ_sqrt' p
    have : (p : ℝ) < ((Nat.sqrt p + 1 : ℕ) : ℝ) ^ 2 := by exact_mod_cast hn
    push_cast at this
    linarith
  exact (Real.sqrt_lt' hpos).mpr h

/-- **The integer window really does contain the Hasse interval.**  Any `n` with
`|n - (p+1)| ≤ 2√p` — in particular any group order of an elliptic curve over `𝔽_p` —
lies in `hasseWindow p`. -/
theorem mem_hasseWindow_of_abs_le {p n : ℕ}
    (h : |(n : ℝ) - ((p : ℝ) + 1)| ≤ 2 * Real.sqrt p) : n ∈ hasseWindow p := by
  have hs := real_sqrt_lt_natSqrt_succ p
  have h1 : (n : ℝ) - ((p : ℝ) + 1) ≤ 2 * Real.sqrt p := (abs_le.mp h).2
  have h2 : -(2 * Real.sqrt p) ≤ (n : ℝ) - ((p : ℝ) + 1) := (abs_le.mp h).1
  have hup : n ≤ hasseUpper p := by
    have : (n : ℝ) < (p : ℝ) + 1 + 2 * ((Nat.sqrt p : ℝ) + 1) := by linarith
    have : n < p + 1 + 2 * (Nat.sqrt p + 1) := by exact_mod_cast this
    exact le_of_lt this
  have hlo : hasseLower p ≤ n := by
    by_cases hc : p + 1 ≤ 2 * (Nat.sqrt p + 1)
    · simp [hasseLower, Nat.sub_eq_zero_of_le hc]
    · push_neg at hc
      have hR : (p : ℝ) + 1 - 2 * ((Nat.sqrt p : ℝ) + 1) < (n : ℝ) := by linarith
      have hle : p + 1 - 2 * (Nat.sqrt p + 1) ≤ n := by
        have hcast : ((p + 1 - 2 * (Nat.sqrt p + 1) : ℕ) : ℝ)
            = (p : ℝ) + 1 - 2 * ((Nat.sqrt p : ℝ) + 1) := by
          have : 2 * (Nat.sqrt p + 1) ≤ p + 1 := le_of_lt hc
          push_cast [Nat.cast_sub this]
          ring
        have : ((p + 1 - 2 * (Nat.sqrt p + 1) : ℕ) : ℝ) < (n : ℝ) := by rw [hcast]; exact hR
        exact le_of_lt (by exact_mod_cast this)
      simpa [hasseLower] using hle
  simp only [hasseWindow, Finset.mem_Icc]
  exact ⟨hlo, hup⟩

/-! ## Size forces powersmoothness -/

/-- Anything not exceeding the bound is powersmooth for that bound: the prime powers
exactly dividing `n` divide `n`, hence are at most `n ≤ B`. -/
theorem powersmooth_of_le {n B : ℕ} (hn : n ≠ 0) (h : n ≤ B) : Powersmooth B n := by
  intro q hq
  have hdvd : q ^ n.factorization q ∣ n := Nat.ordProj_dvd n q
  exact le_trans (Nat.le_of_dvd (Nat.pos_of_ne_zero hn) hdvd) h

/-- **Self-destruction, local form.**  Once `B` reaches the order, the stage-1 scalar
`k(B)` kills that order — with no smoothness luck involved at all. -/
theorem dvd_stage1Scalar_of_le {n B : ℕ} (hn : n ≠ 0) (h : n ≤ B) :
    n ∣ stage1Scalar B := by
  have hB : B ≠ 0 := by
    rintro rfl
    exact hn (Nat.le_zero.mp h)
  exact (dvd_stage1Scalar_iff hn hB).mpr (powersmooth_of_le hn h)

/-! ## The two-prime stage-1 outcome -/

/-- A stage-1 run splits `N = p·q` iff the point's order dies at exactly one of the two
primes: if it dies at neither, the gcd is `1`; if it dies at both, the gcd is `N`. -/
def Splits (mp mq k : ℕ) : Prop := Xor' (mp ∣ k) (mq ∣ k)

/-- The degenerate outcome: the order dies at both primes simultaneously and the
stage-1 gcd is the whole modulus. -/
def Degenerate (mp mq k : ℕ) : Prop := mp ∣ k ∧ mq ∣ k

theorem not_splits_of_degenerate {mp mq k : ℕ} (h : Degenerate mp mq k) :
    ¬ Splits mp mq k := by
  rintro (⟨-, h2⟩ | ⟨-, h2⟩)
  · exact h2 h.2
  · exact h2 h.1

/-- **The ECM self-destruction wall.**  If the smoothness bound has been pushed past
the top of the Hasse window at *both* primes, then every curve — whatever its group
orders — degenerates: both local orders divide `lcm(1,…,B)` at once. -/
theorem wall_degenerate {p q B mp mq : ℕ} (hp : hasseUpper p ≤ B) (hq : hasseUpper q ≤ B)
    (hmp : mp ∈ hasseWindow p) (hmq : mq ∈ hasseWindow q) (h1 : mp ≠ 0) (h2 : mq ≠ 0) :
    Degenerate mp mq (stage1Scalar B) := by
  simp only [hasseWindow, Finset.mem_Icc] at hmp hmq
  exact ⟨dvd_stage1Scalar_of_le h1 (hmp.2.trans hp), dvd_stage1Scalar_of_le h2 (hmq.2.trans hq)⟩

/-- Behind the wall, **no curve ever splits** — the success event is empty, so the
uncapped expected number of curves to a split is infinite. -/
theorem wall_never_splits {p q B mp mq : ℕ} (hp : hasseUpper p ≤ B) (hq : hasseUpper q ≤ B)
    (hmp : mp ∈ hasseWindow p) (hmq : mq ∈ hasseWindow q) (h1 : mp ≠ 0) (h2 : mq ≠ 0) :
    ¬ Splits mp mq (stage1Scalar B) :=
  not_splits_of_degenerate (wall_degenerate hp hq hmp hmq h1 h2)

open Classical in
/-- Behind the wall, running any finite batch of curves produces zero successes: the
"try more curves" amplification of ECM is exactly worthless there. -/
theorem wall_success_count_zero {p q B : ℕ} (hp : hasseUpper p ≤ B) (hq : hasseUpper q ≤ B)
    (curves : Finset (ℕ × ℕ))
    (hc : ∀ c ∈ curves, c.1 ∈ hasseWindow p ∧ c.2 ∈ hasseWindow q ∧ c.1 ≠ 0 ∧ c.2 ≠ 0) :
    (curves.filter (fun c : ℕ × ℕ => Splits c.1 c.2 (stage1Scalar B))).card = 0 := by
  rw [Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  intro c hcm
  obtain ⟨h1, h2, h3, h4⟩ := hc c hcm
  exact wall_never_splits hp hq h1 h2 h3 h4

/-- Behind the wall, an infinite stream of curves still never splits: `E[T] = ∞`
in the strongest pointwise sense. -/
theorem wall_stream_never_splits {p q B : ℕ} (hp : hasseUpper p ≤ B) (hq : hasseUpper q ≤ B)
    (curves : ℕ → ℕ × ℕ)
    (hc : ∀ i, (curves i).1 ∈ hasseWindow p ∧ (curves i).2 ∈ hasseWindow q ∧
      (curves i).1 ≠ 0 ∧ (curves i).2 ≠ 0) :
    ∀ i, ¬ Splits (curves i).1 (curves i).2 (stage1Scalar B) := by
  intro i
  obtain ⟨h1, h2, h3, h4⟩ := hc i
  exact wall_never_splits hp hq h1 h2 h3 h4

/-- **Degeneration is joint, not local.**  Crossing the wall at one prime only is the
best possible situation for ECM: the run splits deterministically, for every curve
whose order at the other prime survives.  This is why the honest validity condition
is stated with `min (p, q)` and why the wall is invisible to any single-prime model. -/
theorem one_sided_crossing_splits {p B mp mq : ℕ} (hp : hasseUpper p ≤ B)
    (hmp : mp ∈ hasseWindow p) (h1 : mp ≠ 0) (hsurv : ¬ mq ∣ stage1Scalar B) :
    Splits mp mq (stage1Scalar B) := by
  simp only [hasseWindow, Finset.mem_Icc] at hmp
  exact Or.inl ⟨dvd_stage1Scalar_of_le h1 (hmp.2.trans hp), hsurv⟩

/-! ## The validity edge: `B ≲ min(p,q)/2` -/

/-- Arithmetic core of the validity edge: for `p ≥ 19`, `p` exceeds `4√p + 2`. -/
theorem four_sqrt_add_two_lt (p : ℕ) (hp : 19 ≤ p) : 2 + 4 * Nat.sqrt p < p := by
  have h1 : Nat.sqrt p ^ 2 ≤ p := Nat.sqrt_le' p
  have h2 : p < (Nat.sqrt p + 1) ^ 2 := Nat.lt_succ_sqrt' p
  rw [pow_two] at h1
  rw [pow_two] at h2
  by_cases hs : Nat.sqrt p ≤ 6
  · interval_cases h : (Nat.sqrt p) <;> omega
  · push_neg at hs
    nlinarith

/-- **The validity edge.**  If the smoothness bound satisfies `2·B ≤ p` (and `p ≥ 19`),
then every order in the Hasse window at `p` is *strictly larger* than `B`.  The
size mechanism that produces the wall is therefore completely inactive below
`B ≈ p/2`: any degeneration there is genuine powersmoothness, and the measured
`(α, c)(B₁)` family is meaningful exactly in that regime. -/
theorem hasseWindow_gt_of_two_mul_le {p B : ℕ} (hp : 19 ≤ p) (hB : 2 * B ≤ p)
    {n : ℕ} (hn : n ∈ hasseWindow p) : B < n := by
  have hkey := four_sqrt_add_two_lt p hp
  simp only [hasseWindow, Finset.mem_Icc, hasseLower] at hn
  omega

/-- Below the validity edge at both primes, no order is forced to die; the wall
argument gives nothing, at either prime. -/
theorem no_forced_degeneration_below_edge {p q B mp mq : ℕ} (hp : 19 ≤ p) (hq : 19 ≤ q)
    (hB : 2 * B ≤ min p q) (hmp : mp ∈ hasseWindow p) (hmq : mq ∈ hasseWindow q) :
    B < mp ∧ B < mq :=
  ⟨hasseWindow_gt_of_two_mul_le hp (le_trans hB (min_le_left _ _)) hmp,
   hasseWindow_gt_of_two_mul_le hq (le_trans hB (min_le_right _ _)) hmq⟩

/-! ## The wall as a monotone threshold in `B` -/

/-- "Every order in the window at `p` dies at bound `B`". -/
def AllDegenerate (p B : ℕ) : Prop := ∀ n ∈ hasseWindow p, n ≠ 0 → n ∣ stage1Scalar B

theorem allDegenerate_of_hasseUpper_le {p B : ℕ} (h : hasseUpper p ≤ B) :
    AllDegenerate p B := by
  intro n hn hn0
  simp only [hasseWindow, Finset.mem_Icc] at hn
  exact dvd_stage1Scalar_of_le hn0 (hn.2.trans h)

/-- The wall, once crossed, stays crossed: `AllDegenerate p ·` is upward closed. -/
theorem allDegenerate_mono {p B B' : ℕ} (hBB : B ≤ B') (h : AllDegenerate p B) :
    AllDegenerate p B' := by
  intro n hn hn0
  have hB0 : B ≠ 0 := by
    rintro rfl
    have hmem : hasseUpper p ∈ hasseWindow p := by
      simp only [hasseWindow, Finset.mem_Icc, hasseLower, hasseUpper]
      omega
    have h1 : hasseUpper p ∣ stage1Scalar 0 := h _ hmem (by simp [hasseUpper])
    have h2 : stage1Scalar 0 = 1 := by
      simp [stage1Scalar, stage1, Nat.log_zero_right]
    rw [h2] at h1
    have hle := Nat.le_of_dvd one_pos h1
    simp only [hasseUpper] at hle
    omega
  have hB'0 : B' ≠ 0 := by omega
  have hsm : Powersmooth B n := (dvd_stage1Scalar_iff hn0 hB0).mp (h n hn hn0)
  exact (dvd_stage1Scalar_iff hn0 hB'0).mpr fun r hr => le_trans (hsm r hr) hBB

/-- **The wall cannot switch on early.**  If the window contains a prime larger than
`B`, some order survives: the threshold is at least the largest prime of the window. -/
theorem not_allDegenerate_of_prime_in_window {p B r : ℕ} (hr : r.Prime)
    (hmem : r ∈ hasseWindow p) (hB : B < r) : ¬ AllDegenerate p B := by
  intro h
  have hr0 : r ≠ 0 := hr.pos.ne'
  have hdvd := h r hmem hr0
  rcases Nat.eq_zero_or_pos B with rfl | hBpos
  · have h2 : stage1Scalar 0 = 1 := by simp [stage1Scalar, stage1, Nat.log_zero_right]
    rw [h2] at hdvd
    exact hr.one_lt.ne' (Nat.dvd_one.mp hdvd)
  · have hsm : Powersmooth B r := (dvd_stage1Scalar_iff hr0 hBpos.ne').mp hdvd
    have hmemp : r ∈ r.primeFactors := by
      simp [hr]
    have hle := hsm r hmemp
    rw [Nat.Prime.factorization_self hr, pow_one] at hle
    omega

/-- **The wall for `p = 101`, pinned between two explicit bounds.**  The window is
`[80, 124]`; the prime `113` lies in it, so nothing degenerates below `B = 113`,
while `B = 124` already degenerates everything.  The threshold `B*(101)` therefore
satisfies `113 ≤ B*(101) ≤ 124 ≈ 101 + 2√101`. -/
theorem wall_101_sandwich :
    (∀ B < 113, ¬ AllDegenerate 101 B) ∧ AllDegenerate 101 124 := by
  constructor
  · intro B hB
    refine not_allDegenerate_of_prime_in_window (r := 113) (by norm_num) ?_ hB
    simp [hasseWindow, hasseLower, hasseUpper, show Nat.sqrt 101 = 10 by norm_num]
  · exact allDegenerate_of_hasseUpper_le
      (by simp [hasseUpper, show Nat.sqrt 101 = 10 by norm_num])

/-! ## H2b refuted: `lpf` and `ω` are blind to firing -/

/-- **No `lpf`/`ω` proxy can predict stage-1 firing.**  For every bound `B ≥ 1` the two
orders `2^{⌊log₂ B⌋}` and `2^{⌊log₂ B⌋+1}` have the same largest prime factor `2` and
the same number `1` of distinct prime factors, yet the first fires at bound `B` and the
second does not.  Any statistic that is a function of `(lpf, ω)` is therefore constant
on a pair with different firing behaviour: powersmoothness, not `lpf` or `ω`, is the
driver. -/
theorem lpf_omega_blind_to_firing (B : ℕ) (hB : 2 ≤ B) :
    ∃ m m' : ℕ, 0 < m ∧ 0 < m' ∧ lpf m = lpf m' ∧
      m.primeFactors.card = m'.primeFactors.card ∧
      m ∣ stage1Scalar B ∧ ¬ m' ∣ stage1Scalar B := by
  set a := Nat.log 2 B with ha
  have ha1 : 1 ≤ a := by
    have : Nat.log 2 2 ≤ Nat.log 2 B := Nat.log_mono_right hB
    simpa [ha] using this
  have hpf : (2 ^ a : ℕ).primeFactors = {2} :=
    Nat.primeFactors_prime_pow (by omega) Nat.prime_two
  have hpf' : (2 ^ (a + 1) : ℕ).primeFactors = {2} :=
    Nat.primeFactors_prime_pow (by omega) Nat.prime_two
  refine ⟨2 ^ a, 2 ^ (a + 1), by positivity, by positivity, ?_, ?_, ?_, ?_⟩
  · simp [lpf, hpf, hpf']
  · simp [hpf, hpf']
  · exact dvd_stage1Scalar_of_le (by positivity) (Nat.pow_log_le_self 2 (by omega))
  · intro hdvd
    have hB0 : B ≠ 0 := by omega
    have hsm : Powersmooth B (2 ^ (a + 1)) :=
      (dvd_stage1Scalar_iff (by positivity) hB0).mp hdvd
    have hmem : 2 ∈ (2 ^ (a + 1) : ℕ).primeFactors := by simp [hpf']
    have hfac : (2 ^ (a + 1) : ℕ).factorization 2 = a + 1 := by
      simp [Nat.Prime.factorization_pow Nat.prime_two]
    have := hsm 2 hmem
    rw [hfac] at this
    have hlt : B < 2 ^ (a + 1) := Nat.lt_pow_succ_log_self (by norm_num) B
    omega

end ECMWall