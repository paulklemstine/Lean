import Shared.FermatDivisorLocality

/-!
# Steering and repairing the locality of Fermat's method

Two consequences of the divisor-locality theorem of
`Shared.FermatDivisorLocality`.

## 1. The locality is *steerable* (multipliers)

Fermat's scan only sees the divisor of `N` nearest `√N`.  Multiplying `N` by a
small odd `k` changes which divisor that is: the pair `(k·p, q)` of `k·N` can be
far better balanced than `(p, q)` was.  `fermat_multiplier_bound` bounds the
stopping point of the scan on `k·N` by `(k·p + q)/2`, and
`multiplier_303_9999` is a fully computed instance: Fermat needs `34`
iterations on `N = 303 = 3·101`, but **zero** iterations on `33·N = 9999`,
whose factorisation `99 · 101` is maximally balanced; one gcd then returns the
factor `3` of `N`.

## 2. The degenerate square defect is a *boundary* bug, and it is repairable

`fermatSteps_prime_sq` showed that plain Fermat has no stopping point on a
square, because the target `a = √N` lies one step below the start `⌊√N⌋ + 1`.
Starting the scan at `⌊√N⌋` instead repairs exactly this: `fermatSteps'` halts
immediately on every square (`fermatSteps'_sq`) and costs precisely one extra
iteration on every odd non-square (`fermatSteps'_eq_succ`).  The defect was a
one-off boundary error, not a structural feature of the method.
-/

namespace FermatGapLocality

/-! ### A square-root computation helper -/

lemma sqrt_eq_of_bounds {k N : ℕ} (h1 : k * k ≤ N) (h2 : N < (k + 1) * (k + 1)) :
    Nat.sqrt N = k := by
  have hle : k ≤ Nat.sqrt N := Nat.le_sqrt.mpr h1
  have hlt : Nat.sqrt N < k + 1 := by
    by_contra hcon
    push_neg at hcon
    have hmul : (k + 1) * (k + 1) ≤ Nat.sqrt N * Nat.sqrt N := Nat.mul_le_mul hcon hcon
    have := Nat.sqrt_le N
    omega
  omega

/-! ### Any factorisation is an upper bound for the stopping point -/

/-- The scan cannot run past the half-sum of *any* ordered factorisation of an
odd non-square `N`. -/
theorem fermat_stop_le_of_factorization {N d e : ℕ} (hodd : Odd N) (hns : ∀ m, m * m ≠ N)
    (hde : d * e = N) (hle : d ≤ e) :
    2 * (fermatStart N + fermatSteps N) ≤ d + e := by
  have hfac : Odd d ∧ Odd e := Nat.odd_mul.mp (hde ▸ hodd)
  obtain ⟨j, hj⟩ := hfac.1
  obtain ⟨l, hl⟩ := hfac.2
  obtain ⟨a, ha⟩ : ∃ a, d + e = 2 * a := ⟨j + l + 1, by omega⟩
  have hmem : a ∈ fermatSums N := ⟨d, e, hde, hle, ha⟩
  have hInf : sInf (fermatSums N) ≤ a := Nat.sInf_le hmem
  have := fermat_cost_eq_sInf_sums hodd hns
  omega

/-! ### Steering the locality with a multiplier -/

/-- **Multiplier bound (Lehman-style).**  Running Fermat on `k·N` instead of `N`
replaces the visible factor pair `(p, q)` by `(k·p, q)`; whenever `k·p ≤ q`, the
scan on `k·N` stops at or before `(k·p + q)/2`.  Choosing `k ≈ q/p` therefore
makes the gap — and with it the cost — as small as one likes, even though the
factors of `N` themselves are wildly unbalanced. -/
theorem fermat_multiplier_bound {k p q : ℕ} (hodd : Odd (k * (p * q)))
    (hns : ∀ m, m * m ≠ k * (p * q)) (hle : k * p ≤ q) :
    2 * (fermatStart (k * (p * q)) + fermatSteps (k * (p * q))) ≤ k * p + q :=
  fermat_stop_le_of_factorization hodd hns (by ring) hle

/-- Fermat's method on `N = 303 = 3 · 101` needs `34` iterations. -/
theorem fermatSteps_303 : fermatSteps 303 = 34 := by
  have hs : Nat.sqrt 303 = 17 := sqrt_eq_of_bounds (by norm_num) (by norm_num)
  have h : fermatSteps (3 * 101) = (3 + 101) / 2 - (Nat.sqrt (3 * 101) + 1) :=
    fermatSteps_eq (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  norm_num [hs] at h
  exact h

/-- On the multiplied number `33 · 303 = 9999 = 99 · 101` the very first trial
value succeeds: zero iterations. -/
theorem fermatSteps_9999 : fermatSteps 9999 = 0 := by
  have hodd : Odd 9999 := ⟨4999, by norm_num⟩
  have hns : ∀ m, m * m ≠ 9999 := by
    intro m hm
    rcases le_or_gt m 99 with h | h
    · nlinarith
    · nlinarith
  have hmax : ∀ d' e', d' * e' = 9999 → d' ≤ e' → d' ≤ 99 := by
    intro d e h hle
    nlinarith
  have hcost : 2 * (fermatStart 9999 + fermatSteps 9999) = 99 + 101 :=
    fermat_cost_largest_divisor hodd hns (by norm_num) (by norm_num) hmax
  have hs : Nat.sqrt 9999 = 99 := sqrt_eq_of_bounds (by norm_num) (by norm_num)
  simp only [fermatStart, hs] at hcost
  omega

/-- **Steering instance.**  The multiplier `33` converts a `34`-iteration Fermat
run on `303` into a `0`-iteration run on `9999`, and the balanced factor `99`
found there returns the factor `3` of `303` by one gcd. -/
theorem multiplier_303_9999 :
    fermatSteps 303 = 34 ∧ fermatSteps (33 * 303) = 0 ∧ Nat.gcd 99 303 = 3 := by
  refine ⟨fermatSteps_303, ?_, by norm_num⟩
  have : (33 : ℕ) * 303 = 9999 := by norm_num
  rw [this]
  exact fermatSteps_9999

/-! ### Repairing the degenerate square case -/

/-- The repaired scan starts one step lower, at `⌊√N⌋`. -/
def fermatStart' (N : ℕ) : ℕ := Nat.sqrt N

/-- Iteration counts at which the repaired scan succeeds. -/
def fermatHits' (N : ℕ) : Set ℕ :=
  {k | ∃ b, (fermatStart' N + k) * (fermatStart' N + k) = N + b * b}

/-- Number of iterations of the repaired scan. -/
noncomputable def fermatSteps' (N : ℕ) : ℕ := sInf (fermatHits' N)

/-- **The defect is repaired.**  The repaired scan halts immediately on every
square, where plain Fermat has no stopping point at all. -/
theorem fermatSteps'_sq (n : ℕ) : fermatSteps' (n * n) = 0 := by
  have hmem : (0 : ℕ) ∈ fermatHits' (n * n) := by
    refine ⟨0, ?_⟩
    simp [fermatStart', Nat.sqrt_eq]
  exact Nat.le_antisymm (Nat.sInf_le hmem) (Nat.zero_le _)

/-- On a non-square the repaired scan cannot succeed at its first trial value. -/
lemma zero_not_mem_hits' {N : ℕ} (hns : ∀ m, m * m ≠ N) : (0 : ℕ) ∉ fermatHits' N := by
  rintro ⟨b, hb⟩
  have h1 : Nat.sqrt N * Nat.sqrt N ≤ N := Nat.sqrt_le N
  have h2 : Nat.sqrt N * Nat.sqrt N = N := by
    simp only [fermatStart', Nat.add_zero] at hb
    nlinarith [Nat.zero_le (b * b)]
  exact hns _ h2

/-- **Cost of the repair.**  On an odd non-square the repaired scan is exactly
one iteration slower than plain Fermat — the price of covering the square
boundary case is a single wasted trial. -/
theorem fermatSteps'_eq_succ {N : ℕ} (hodd : Odd N) (hns : ∀ m, m * m ≠ N) :
    fermatSteps' N = fermatSteps N + 1 := by
  -- the two hit sets differ by a shift of one
  have hshift : ∀ k : ℕ, (k + 1) ∈ fermatHits' N ↔ k ∈ fermatHits N := by
    intro k
    constructor
    · rintro ⟨b, hb⟩
      refine ⟨b, ?_⟩
      simp only [fermatStart', fermatStart] at hb ⊢
      have hrw : Nat.sqrt N + 1 + k = Nat.sqrt N + (k + 1) := by omega
      rw [hrw]; exact hb
    · rintro ⟨b, hb⟩
      refine ⟨b, ?_⟩
      simp only [fermatStart', fermatStart] at hb ⊢
      have hrw : Nat.sqrt N + (k + 1) = Nat.sqrt N + 1 + k := by omega
      rw [hrw]; exact hb
  -- plain Fermat does have a stopping point on an odd number
  have hne : (fermatHits N).Nonempty := by
    obtain ⟨j, hj⟩ := hodd
    have hmem : ((N + 1) / 2) ∈ fermatSums N := ⟨1, N, by ring, by omega, by omega⟩
    have hstart : fermatStart N ≤ (N + 1) / 2 := start_le_of_mem_sums hns hmem
    exact ⟨_, sums_mem_hits hmem hstart⟩
  have hmemS : fermatSteps N ∈ fermatHits N := Nat.sInf_mem hne
  have hmemS' : fermatSteps N + 1 ∈ fermatHits' N := (hshift _).mpr hmemS
  have hne' : (fermatHits' N).Nonempty := ⟨_, hmemS'⟩
  have hle : fermatSteps' N ≤ fermatSteps N + 1 := Nat.sInf_le hmemS'
  have hmem' : fermatSteps' N ∈ fermatHits' N := Nat.sInf_mem hne'
  have hpos : fermatSteps' N ≠ 0 := by
    intro h0
    exact zero_not_mem_hits' hns (h0 ▸ hmem')
  obtain ⟨m, hm⟩ : ∃ m, fermatSteps' N = m + 1 := ⟨fermatSteps' N - 1, by omega⟩
  have hmS : m ∈ fermatHits N := (hshift m).mp (hm ▸ hmem')
  have hge : fermatSteps N ≤ m := Nat.sInf_le hmS
  omega

end FermatGapLocality