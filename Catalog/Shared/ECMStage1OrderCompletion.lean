import Mathlib

/-!
# ECM stage 1: order completion, its exact firing criterion, and its firing cutoff

Context (experiments 570 / 595, papers 215 → 218 → 244).  The recorded question is
*mechanistic*: when a stage-1 elliptic-curve-method (ECM) run succeeds at a small
smoothness bound `B1`, is that success a **collision accident** (a chance gcd, whose
rate the folklore model puts at `1 - exp(-1.44·B1/p)`), or is it **order completion**
— the group order genuinely dividing the stage-1 scalar — *firing early inside the
prime schedule*?

That dichotomy is a statement about the scalar

```
k(B, C)  =  ∏ { q ^ ⌊log_q B⌋ : q prime, q ≤ C }
```

which stage 1 accumulates prime by prime, and about the set of group elements it
kills.  This file isolates the part of the picture that is an unconditional theorem,
in the form used by the experiments:

* **Firing criterion** (`dvd_stage1_iff`, `orderCompletes_iff`).  A point of order
  `n` is killed by the full stage-1 scalar `k(B) = k(B,B)` **iff** `n` is
  `B`-powersmooth.  No probability enters: the event is exactly a divisibility.
* **Order completion is impossible above the bound** (`not_orderCompletes_of_large_primePow`,
  `no_orderCompletion_of_large_prime_factor`).  If the order has a prime power
  divisor exceeding `B`, stage 1 provably never fires on it.  This is the formal
  content of the `found_q` cross-check: for the *large* factor `q` of the modulus,
  with `B1 ≪ q`, order completion cannot be responsible for a hit, so hits there
  measure the collision floor alone.
* **Firing cutoff = largest prime factor** (`firingCutoff_isLeast`,
  `dvd_stage1_prefix_iff`).  For an order that does fire, the *position in the
  schedule* at which it fires is not random: it is exactly the largest prime factor
  of the order.  This turns "early fire" into an arithmetic statement — a run fires
  inside the first `π(L)` of its `π(B)` prime steps precisely when the order has no
  prime factor above `L`.

The distributional consequences (exact firing rates, the gcd staircase, its
non-uniformity, multi-curve amplification, and the collision-floor comparison) are
in `Catalog.Shared.ECMStage1FiringRate`, which builds on this file.
-/

namespace ECMStage1

open Finset

/-! ## The stage-1 scalar and its factorization -/

/-- The stage-1 scalar truncated at prime cutoff `C`:
`k(B, C) = ∏ { q ^ ⌊log_q B⌋ : q prime, q ≤ C }`.  Stage 1 of ECM multiplies the
starting point by these prime powers one prime at a time, in increasing order, so
`stage1 B C` is exactly the scalar accumulated after all primes `≤ C`. -/
def stage1 (B C : ℕ) : ℕ := ∏ q ∈ (Finset.range (C + 1)).filter Nat.Prime, q ^ Nat.log q B

/-- The full stage-1 scalar at smoothness bound `B`. -/
def stage1Scalar (B : ℕ) : ℕ := stage1 B B

/-- `n` is `B`-powersmooth: every prime power exactly dividing `n` is at most `B`. -/
def Powersmooth (B n : ℕ) : Prop := ∀ q ∈ n.primeFactors, q ^ n.factorization q ≤ B

/-- Factorization of a product of prime powers over a finset of primes. -/
theorem factorization_prod_primePow {S : Finset ℕ} (hS : ∀ q ∈ S, q.Prime) (e : ℕ → ℕ)
    (r : ℕ) :
    (∏ q ∈ S, q ^ e q).factorization r = if r ∈ S then e r else 0 := by
  rw [Nat.factorization_prod (fun q hq => pow_ne_zero _ (hS q hq).pos.ne')]
  rw [Finset.sum_apply']
  have h : ∀ q ∈ S, (q ^ e q).factorization r = if q = r then e q else 0 := by
    intro q hq
    rw [Nat.Prime.factorization_pow (hS q hq)]
    simp [Finsupp.single_apply]
  rw [Finset.sum_congr rfl h, Finset.sum_ite_eq' S r]

theorem stage1_ne_zero (B C : ℕ) : stage1 B C ≠ 0 := by
  refine Finset.prod_ne_zero_iff.mpr ?_
  intro q hq
  simp only [Finset.mem_filter] at hq
  exact pow_ne_zero _ hq.2.pos.ne'

theorem stage1Scalar_ne_zero (B : ℕ) : stage1Scalar B ≠ 0 := stage1_ne_zero B B

/-- The exponent of a prime `r` in the stage-1 scalar is `⌊log_r B⌋` as soon as `r`
has entered the schedule, and `0` before that. -/
theorem stage1_factorization (B C : ℕ) {r : ℕ} (hr : r.Prime) :
    (stage1 B C).factorization r = if r ≤ C then Nat.log r B else 0 := by
  rw [stage1, factorization_prod_primePow (fun q hq => (Finset.mem_filter.mp hq).2) _ r]
  simp [hr]

/-! ## The firing criterion -/

/-- **Exact firing criterion for a truncated schedule.**  An order `n` is killed by
the scalar accumulated up to prime cutoff `C` iff each prime power exactly dividing
`n` is at most `B` *and* its prime has already entered the schedule. -/
theorem dvd_stage1_iff {n B C : ℕ} (hn : n ≠ 0) (hB : B ≠ 0) :
    n ∣ stage1 B C ↔ ∀ q ∈ n.primeFactors, q ≤ C ∧ q ^ n.factorization q ≤ B := by
  rw [← Nat.factorization_le_iff_dvd hn (stage1_ne_zero B C), Finsupp.le_def]
  constructor
  · intro h q hq
    have hqp : q.Prime := Nat.prime_of_mem_primeFactors hq
    have hle := h q
    rw [stage1_factorization B C hqp] at hle
    by_cases hqC : q ≤ C
    · rw [if_pos hqC] at hle
      exact ⟨hqC, (Nat.le_log_iff_pow_le hqp.one_lt hB).mp hle⟩
    · rw [if_neg hqC] at hle
      have hpos : 0 < n.factorization q :=
        Nat.Prime.factorization_pos_of_dvd hqp hn (Nat.dvd_of_mem_primeFactors hq)
      omega
  · intro h r
    by_cases hrp : r.Prime
    · by_cases hrn : r ∈ n.primeFactors
      · obtain ⟨h1, h2⟩ := h r hrn
        rw [stage1_factorization B C hrp, if_pos h1]
        exact (Nat.le_log_iff_pow_le hrp.one_lt hB).mpr h2
      · have hz : n.factorization r = 0 := by
          simp only [Nat.mem_primeFactors, not_and, not_not] at hrn
          exact Nat.factorization_eq_zero_of_not_dvd (fun hd => hn (hrn hrp hd))
        simp [hz]
    · simp [Nat.factorization_eq_zero_of_not_prime n hrp]

/-- **Order completion is exactly powersmoothness.**  The full stage-1 scalar kills
an order `n` iff `n` is `B`-powersmooth; the ECM success event at stage 1 carries no
probabilistic content beyond this divisibility. -/
theorem dvd_stage1Scalar_iff {n B : ℕ} (hn : n ≠ 0) (hB : B ≠ 0) :
    n ∣ stage1Scalar B ↔ Powersmooth B n := by
  rw [stage1Scalar, dvd_stage1_iff hn hB]
  refine ⟨fun h q hq => (h q hq).2, fun h q hq => ⟨?_, h q hq⟩⟩
  have hqp : q.Prime := Nat.prime_of_mem_primeFactors hq
  have hpos : 0 < n.factorization q :=
    Nat.Prime.factorization_pos_of_dvd hqp hn (Nat.dvd_of_mem_primeFactors hq)
  calc q = q ^ 1 := (pow_one q).symm
    _ ≤ q ^ n.factorization q := Nat.pow_le_pow_right hqp.pos hpos
    _ ≤ B := h q hq

/-- The exponent of a prime in the firing count `gcd(m, k(B,C))`. -/
theorem gcd_stage1_factorization {m B C : ℕ} (hm : m ≠ 0) {r : ℕ} (hr : r.Prime) :
    (Nat.gcd m (stage1 B C)).factorization r =
      min (m.factorization r) (if r ≤ C then Nat.log r B else 0) := by
  rw [Nat.factorization_gcd hm (stage1_ne_zero B C)]
  simp only [Finsupp.inf_apply]
  rw [stage1_factorization B C hr]

/-! ## The group-theoretic form -/

variable {G : Type*} [Group G]

/-- **Order completion in a group.**  A point is killed by the full stage-1 scalar
iff its order is `B`-powersmooth. -/
theorem orderCompletes_iff {g : G} (hg : 0 < orderOf g) {B : ℕ} (hB : B ≠ 0) :
    g ^ stage1Scalar B = 1 ↔ Powersmooth B (orderOf g) := by
  rw [← orderOf_dvd_iff_pow_eq_one, dvd_stage1Scalar_iff hg.ne' hB]

/-- **No order completion above the bound.**  If some prime power exactly dividing
the order exceeds `B`, stage 1 provably never fires on that point — whatever the
schedule.  (Used as the `found_q` cross-check: for the large factor of the modulus
order completion is impossible, so hits there isolate the collision floor.) -/
theorem not_orderCompletes_of_large_primePow {g : G} (hg : 0 < orderOf g) {B q : ℕ}
    (hB : B ≠ 0) (hq : q ∈ (orderOf g).primeFactors)
    (hlarge : B < q ^ (orderOf g).factorization q) :
    g ^ stage1Scalar B ≠ 1 := by
  rw [Ne, orderCompletes_iff hg hB]
  exact fun h => absurd (h q hq) (by omega)

/-- Same statement in the form used in the experiment logs: a prime factor larger
than the smoothness bound blocks order completion outright. -/
theorem no_orderCompletion_of_large_prime_factor {g : G} (hg : 0 < orderOf g) {B q : ℕ}
    (hB : B ≠ 0) (hq : q ∈ (orderOf g).primeFactors) (hlarge : B < q) :
    g ^ stage1Scalar B ≠ 1 := by
  refine not_orderCompletes_of_large_primePow hg hB hq (lt_of_lt_of_le hlarge ?_)
  have hqp : q.Prime := Nat.prime_of_mem_primeFactors hq
  have hpos : 0 < (orderOf g).factorization q :=
    Nat.Prime.factorization_pos_of_dvd hqp hg.ne'
      (Nat.dvd_of_mem_primeFactors hq)
  calc q = q ^ 1 := (pow_one q).symm
    _ ≤ q ^ (orderOf g).factorization q := Nat.pow_le_pow_right hqp.pos hpos

/-! ## Where in the schedule it fires -/

/-- The largest prime factor of `n` (`0` for `n = 0, 1`). -/
def lpf (n : ℕ) : ℕ := n.primeFactors.sup id

theorem lpf_le_iff {n C : ℕ} : lpf n ≤ C ↔ ∀ q ∈ n.primeFactors, q ≤ C := by
  simp [lpf, Finset.sup_le_iff]

/-- **The firing position is the largest prime factor.**  For a point whose order is
`B`-powersmooth (so stage 1 does fire), the truncated schedule up to cutoff `C`
already fires iff `C` has reached the largest prime factor of the order. -/
theorem dvd_stage1_prefix_iff {n B C : ℕ} (hn : n ≠ 0) (hB : B ≠ 0)
    (hsm : Powersmooth B n) : n ∣ stage1 B C ↔ lpf n ≤ C := by
  rw [dvd_stage1_iff hn hB, lpf_le_iff]
  exact ⟨fun h q hq => (h q hq).1, fun h q hq => ⟨h q hq, hsm q hq⟩⟩

/-- **The firing cutoff is exactly `lpf n`**: it is the least prime cutoff at which
the accumulating stage-1 scalar kills the order. -/
theorem firingCutoff_isLeast {n B : ℕ} (hn : n ≠ 0) (hB : B ≠ 0) (hsm : Powersmooth B n) :
    IsLeast {C | n ∣ stage1 B C} (lpf n) := by
  refine ⟨(dvd_stage1_prefix_iff hn hB hsm).mpr le_rfl, ?_⟩
  intro C hC
  exact (dvd_stage1_prefix_iff hn hB hsm).mp hC

/-- The number of prime steps of the schedule, `π(C)`. -/
def primeCount (C : ℕ) : ℕ := ((Finset.range (C + 1)).filter Nat.Prime).card

theorem primeCount_mono : Monotone primeCount := by
  intro a b hab
  refine Finset.card_le_card ?_
  intro x hx
  simp only [Finset.mem_filter, Finset.mem_range, Nat.lt_succ_iff] at hx ⊢
  exact ⟨hx.1.trans hab, hx.2⟩

/-- **Early fire, arithmetized.**  If the order is `B`-powersmooth and has no prime
factor above `L`, the run fires after at most `π(L)` of its `π(B)` prime steps; the
normalized firing position is at most `π(L) / π(B)`. -/
theorem earlyFire_of_lpf_le {n B L : ℕ} (hn : n ≠ 0) (hB : B ≠ 0) (hsm : Powersmooth B n)
    (hL : lpf n ≤ L) :
    n ∣ stage1 B L ∧ primeCount (lpf n) ≤ primeCount L :=
  ⟨(dvd_stage1_prefix_iff hn hB hsm).mpr hL, primeCount_mono hL⟩

/-- Conversely a *late* fire forces a large prime factor: firing only after cutoff
`L` means the order has a prime factor exceeding `L`. -/
theorem large_prime_factor_of_late_fire {n B L : ℕ} (hn : n ≠ 0) (hB : B ≠ 0)
    (hsm : Powersmooth B n) (hlate : ¬ n ∣ stage1 B L) : ∃ q ∈ n.primeFactors, L < q := by
  by_contra h
  push_neg at h
  exact hlate ((dvd_stage1_iff hn hB).mpr fun q hq => ⟨h q hq, hsm q hq⟩)

/-! ## Monotonicity of the schedule -/

/-- The accumulating scalar only gains divisors as the cutoff advances. -/
theorem stage1_dvd_stage1 {B C C' : ℕ} (h : C ≤ C') : stage1 B C ∣ stage1 B C' := by
  refine Finset.prod_dvd_prod_of_subset _ _ _ ?_
  intro x hx
  simp only [Finset.mem_filter, Finset.mem_range, Nat.lt_succ_iff] at hx ⊢
  exact ⟨hx.1.trans h, hx.2⟩

end ECMStage1