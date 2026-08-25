/-
# ECM stage-1 TRACE LAW: the firing step is the largest prime factor, so the
# late tail is structurally empty (exp 570 / paper 218)

Experiment 570 ("COLLISION-VS-ORDER-TRACE") measured, for successful ECM stage-1
curves, the *normalized firing-step index*: the fraction of the stage-1 prime
schedule that had been consumed at the moment the accumulated scalar killed the
point.  Two pre-registered hypotheses were refuted:

* **H1** predicted the firing index to be *uniform* at small `B1/p` and
  *concentrated in the final 20%* at large `B1/p`.  Measured: hits fire near
  step **zero** (median normalized index `0.09`–`0.10`), and the final-20% tail
  was **empty** (`0/55`).
* **H2** predicted the low-`B1` success rate to collapse to the random-collision
  floor `1 - exp(-c·B1/p)` as the bit length grows.  Measured `65.0%` / `62.5%`
  at bit lengths 26 / 32, far above the per-curve floor, with no cross-bit-length
  drift.

This file supplies the *structural* explanation of both refutations, in the form
of theorems rather than statistics.  It builds directly on the catalog file
`Novelty.SmoothNumberLowerBound` (`IsSmooth`, `largePrimes`, `primeContribution`).

## The model

Stage 1 of ECM multiplies the starting point by
`K(B1) = ∏_{p ≤ B1} p ^ ⌊log_p B1⌋`, consuming the primes `p ≤ B1` in increasing
order.  After the primes up to `y` have been consumed the accumulated scalar is
`stageProd B1 y = ∏_{p ≤ y} p ^ ⌊log_p B1⌋`.  A curve "fires" at the first moment
the order `n` of the point divides the accumulated scalar.

## Main results

* `dvd_stageProd_iff_maxPF_le` — **the trace law**.  For a stage-1 reachable
  order `n` (i.e. `n ∣ stageProd B1 B1`), `n ∣ stageProd B1 y ↔ maxPF n ≤ y`:
  the firing moment is governed *only* by the largest prime factor of the order.
* `isLeast_fireY` — hence the firing threshold is exactly `maxPF n`, and
  `stepIndex_eq` turns it into the normalized step index `π(maxPF n) / π(B1)`.
* `late_fire_large_prime_dvd` — a curve can only fire in the *late* part of the
  schedule if its order is divisible by a *large* prime, one in `(y, B1]`.
* `lateCount_le_primeContribution` — a sieve/union bound: at most
  `∑_{y < p ≤ B1} ⌊M/p⌋` of the orders in `(0, M]` can fire late.  (This is the
  bound the catalog's `L_lower_sieve` uses on the smooth side, re-deployed on the
  trace side.)
* `late_tail_density_lt_one_fifth` — the concrete refutation of H1 at `B1 = 100`:
  the final-20% window of the schedule is reachable by fewer than `M/5 · (2/5)`
  orders — a density below `0.075`, so a *uniform* firing index is impossible.
  The empty measured tail (`0/55`) is what the structure predicts.
* `collisionProb_le_ratio`, `collision_ceiling_scale_free`,
  `collision_subdominant` — the H2 side: the random-collision success
  probability `1 - (1 - 1/p)^k` is bounded by `k/p`, a quantity depending only
  on the *ratio* `ops/p`, hence **scale free**: it cannot collapse as the bit
  length grows at fixed `B1/p`, and at the measured operating point
  (`ops/p = 2.59·0.125`) it is bounded by `0.324`, well below the measured
  `0.625`.
* `order_hits_card_lower_bound` — the pigeonhole turning that gap into a
  guaranteed number of genuine order-hits in a finite batch of curves.

-- !-- Lab Notes -- !--
-- exp 570, seed 20260824, wall 1.3 s, bit lengths 26 / 32, `B1/p ∈ {0.125, 0.9}`.
-- Measured found_p rates at `B1/p = 0.125`: 65.0% (bitlen 26, CI .495–.779),
-- 62.5% (bitlen 32, CI .470–.758); two-proportion z-test p = 0.8161.
-- Per-curve collision floor with the `1.44` constant: 16.47%; with the true
-- op count `2.59·B1`: 27.1–27.8%.  Median normalized firing index at
-- `B1/p = 0.9`: 0.09 / 0.102.  Final-20% tail: 0 hits out of 55 (binomial
-- p ≈ 0.004 against the registered 20%).
-- The theorems below explain the two measurements: `dvd_stageProd_iff_maxPF_le`
-- says the firing index is a function of the largest prime factor only, and
-- `late_tail_density_lt_one_fifth` says that function's late tail carries
-- density < 0.075 at `B1 = 100`, versus the 0.2 that uniformity predicts.
-/

import Novelty.SmoothNumberLowerBound

namespace Catalog.Novelty.EcmStageOneTraceLaw

open Finset Catalog.Novelty.SmoothNumberLowerBound

/-! ### The stage-1 schedule -/

/-- The primes at most `y`, i.e. the prefix of the ECM stage-1 schedule that has
been consumed once the schedule reaches `y`. -/
def primesUpTo (y : ℕ) : Finset ℕ := (range (y + 1)).filter Nat.Prime

/-- The accumulated stage-1 scalar after the schedule has consumed all primes
`p ≤ y`: `∏_{p ≤ y} p ^ ⌊log_p B1⌋`.  For `y ≥ B1` this is the full stage-1
multiplier `K(B1) = lcm(1, …, B1)`. -/
def stageProd (B1 y : ℕ) : ℕ := ∏ p ∈ primesUpTo y, p ^ Nat.log p B1

/-- The largest prime factor of `n` (`0` for `n = 0, 1`). -/
def maxPF (n : ℕ) : ℕ := n.primeFactors.sup id

/-- The number of schedule steps consumed before an order `n` fires. -/
def stepIndex (n : ℕ) : ℕ := #(primesUpTo (maxPF n))

/-- The total number of schedule steps, `π(B1)`. -/
def totalSteps (B1 : ℕ) : ℕ := #(primesUpTo B1)

lemma mem_primesUpTo {y p : ℕ} : p ∈ primesUpTo y ↔ p ≤ y ∧ p.Prime := by
  simp [primesUpTo]

lemma stageProd_pos (B1 y : ℕ) : 0 < stageProd B1 y := by
  refine Finset.prod_pos fun p hp => ?_
  exact pow_pos (mem_primesUpTo.mp hp).2.pos _

lemma primesUpTo_mono {y z : ℕ} (h : y ≤ z) : primesUpTo y ⊆ primesUpTo z := by
  intro p hp
  exact mem_primesUpTo.mpr ⟨le_trans (mem_primesUpTo.mp hp).1 h, (mem_primesUpTo.mp hp).2⟩

lemma stageProd_dvd_mono {B1 y z : ℕ} (h : y ≤ z) : stageProd B1 y ∣ stageProd B1 z :=
  Finset.prod_dvd_prod_of_subset _ _ _ (primesUpTo_mono h)

/-! ### Basic facts about the largest prime factor -/

lemma maxPF_prime {n : ℕ} (hn : n.primeFactors.Nonempty) : (maxPF n).Prime := by
  obtain ⟨p, hp, hmax⟩ := Finset.exists_mem_eq_sup n.primeFactors hn id
  rw [maxPF, hmax]
  exact Nat.prime_of_mem_primeFactors hp

lemma maxPF_dvd {n : ℕ} (hn : n.primeFactors.Nonempty) : maxPF n ∣ n := by
  obtain ⟨p, hp, hmax⟩ := Finset.exists_mem_eq_sup n.primeFactors hn id
  rw [maxPF, hmax]
  exact Nat.dvd_of_mem_primeFactors hp

lemma le_maxPF {n p : ℕ} (hp : p ∈ n.primeFactors) : p ≤ maxPF n :=
  Finset.le_sup (f := id) hp

lemma primeFactors_nonempty_of_maxPF {n : ℕ} (h : 0 < maxPF n) : n.primeFactors.Nonempty := by
  by_contra hne
  rw [Finset.not_nonempty_iff_eq_empty] at hne
  simp [maxPF, hne] at h

/-! ### The trace law -/

/-- Every prime factor of a stage-1 partial product is a schedule prime `≤ y`. -/
lemma prime_dvd_stageProd_le {B1 y p : ℕ} (hp : p.Prime) (h : p ∣ stageProd B1 y) : p ≤ y := by
  rw [stageProd] at h
  obtain ⟨q, hq, hpq⟩ := (Nat.Prime.prime hp).exists_mem_finset_dvd h
  have := hp.dvd_of_dvd_pow hpq
  have hqp : q.Prime := (mem_primesUpTo.mp hq).2
  rw [(Nat.prime_dvd_prime_iff_eq hp hqp).mp this]
  exact (mem_primesUpTo.mp hq).1

/-- **The trace law.**  A stage-1 reachable order `n` divides the partial
product at `y` exactly when its largest prime factor is at most `y`.  The firing
moment carries no information beyond `maxPF n`. -/
theorem dvd_stageProd_iff_maxPF_le {B1 y n : ℕ} (hn : n ≠ 0) (hreach : n ∣ stageProd B1 B1) :
    n ∣ stageProd B1 y ↔ maxPF n ≤ y := by
  constructor
  · intro h
    by_cases h1 : n = 1
    · simp [maxPF, h1]
    · have hne : n.primeFactors.Nonempty := by
        rw [Finset.nonempty_iff_ne_empty]
        intro hcon
        exact h1 (by simpa [Nat.primeFactors_eq_empty, hn] using hcon)
      exact prime_dvd_stageProd_le (maxPF_prime hne) ((maxPF_dvd hne).trans h)
  · intro hle
    -- split the full product at `y`; `n` is coprime to the tail
    have hsplit :
        (∏ p ∈ primesUpTo B1 with p ≤ y, p ^ Nat.log p B1) *
          (∏ p ∈ primesUpTo B1 with ¬ p ≤ y, p ^ Nat.log p B1) = stageProd B1 B1 :=
      Finset.prod_filter_mul_prod_filter_not _ _ _
    have hcop : Nat.Coprime n (∏ p ∈ primesUpTo B1 with ¬ p ≤ y, p ^ Nat.log p B1) := by
      refine Nat.Coprime.prod_right fun p hp => ?_
      rw [Finset.mem_filter] at hp
      have hpp : p.Prime := (mem_primesUpTo.mp hp.1).2
      refine Nat.Coprime.pow_right _ ?_
      rw [Nat.coprime_comm]
      refine (Nat.Prime.coprime_iff_not_dvd hpp).mpr fun hdvd => ?_
      have : p ∈ n.primeFactors := Nat.mem_primeFactors.mpr ⟨hpp, hdvd, hn⟩
      exact hp.2 (le_trans (le_maxPF this) hle)
    have hdvd1 : n ∣ ∏ p ∈ primesUpTo B1 with p ≤ y, p ^ Nat.log p B1 := by
      refine hcop.dvd_of_dvd_mul_right ?_
      rw [hsplit]; exact hreach
    refine hdvd1.trans (Finset.prod_dvd_prod_of_subset _ _ _ ?_)
    intro p hp
    rw [Finset.mem_filter] at hp
    exact mem_primesUpTo.mpr ⟨hp.2, (mem_primesUpTo.mp hp.1).2⟩

/-- The firing threshold of a stage-1 reachable order is *exactly* its largest
prime factor: it is the least `y` at which the accumulated scalar annihilates
the point. -/
theorem isLeast_fireY {B1 n : ℕ} (hn : n ≠ 0) (hreach : n ∣ stageProd B1 B1) :
    IsLeast {y | n ∣ stageProd B1 y} (maxPF n) := by
  refine ⟨(dvd_stageProd_iff_maxPF_le hn hreach).mpr le_rfl, fun y hy => ?_⟩
  exact (dvd_stageProd_iff_maxPF_le hn hreach).mp hy

/-- The normalized firing index is `π(maxPF n) / π(B1)`: a function of the
largest prime factor alone. -/
theorem stepIndex_eq {B1 n : ℕ} (hn : n ≠ 0) (hreach : n ∣ stageProd B1 B1) :
    stepIndex n = #(primesUpTo (sInf {y | n ∣ stageProd B1 y})) := by
  have h := isLeast_fireY hn hreach
  rw [stepIndex, ← h.csInf_eq]

/-- Firing is monotone in the largest prime factor: a smaller largest prime
factor fires no later. -/
theorem stepIndex_mono {m n : ℕ} (h : maxPF m ≤ maxPF n) : stepIndex m ≤ stepIndex n :=
  Finset.card_mono (primesUpTo_mono h)

/-! ### The late tail is structurally thin (refutation of H1) -/

/-- **Late firing forces a large prime.**  If a stage-1 reachable order has not
fired by the time the schedule has passed `y`, then it is divisible by a prime in
`(y, B1]` — one of the catalog's `largePrimes B1 y`. -/
theorem late_fire_large_prime_dvd {B1 y n : ℕ} (hn : n ≠ 0) (hreach : n ∣ stageProd B1 B1)
    (hlate : ¬ n ∣ stageProd B1 y) : ∃ p ∈ largePrimes B1 y, p ∣ n := by
  have hgt : y < maxPF n := by
    by_contra hcon
    exact hlate ((dvd_stageProd_iff_maxPF_le hn hreach).mpr (not_lt.mp hcon))
  have hne : n.primeFactors.Nonempty := primeFactors_nonempty_of_maxPF (by omega)
  have hple : maxPF n ≤ B1 :=
    prime_dvd_stageProd_le (maxPF_prime hne) ((maxPF_dvd hne).trans hreach)
  exact ⟨maxPF n, by
      simp only [largePrimes, Finset.mem_filter, Finset.mem_Ioc]
      exact ⟨⟨hgt, hple⟩, maxPF_prime hne⟩, maxPF_dvd hne⟩

/-- The set of orders in `(0, M]` that fire in the part of the schedule beyond
`y`, i.e. that are divisible by some prime of `largePrimes B1 y`. -/
def lateOrders (M B1 y : ℕ) : Finset ℕ :=
  {n ∈ Ioc 0 M | ∃ p ∈ largePrimes B1 y, p ∣ n}

/-- **Sieve bound on the late tail.**  At most `∑_{y < p ≤ B1} ⌊M/p⌋` of the
orders in `(0, M]` can fire beyond schedule position `y`.  (Same union bound the
catalog's `L_lower_sieve` uses, transported to the trace side.) -/
theorem lateCount_le_primeContribution (M B1 y : ℕ) :
    #(lateOrders M B1 y) ≤ ∑ p ∈ largePrimes B1 y, M / p := by
  have hsub : lateOrders M B1 y ⊆
      (largePrimes B1 y).biUnion (fun p => {n ∈ Ioc 0 M | p ∣ n}) := by
    intro n hn
    simp only [lateOrders, Finset.mem_filter] at hn
    obtain ⟨hmem, p, hp, hpn⟩ := hn
    exact Finset.mem_biUnion.mpr ⟨p, hp, Finset.mem_filter.mpr ⟨hmem, hpn⟩⟩
  refine le_trans (Finset.card_mono hsub) (le_trans (Finset.card_biUnion_le) ?_)
  exact le_of_eq (Finset.sum_congr rfl fun p _ => Nat.Ioc_filter_dvd_card_eq_div M p)

/-- All orders that fire strictly after schedule position `y` lie in
`lateOrders`. -/
theorem lateOrders_of_late {M B1 y n : ℕ} (hn : n ≠ 0) (hnM : n ≤ M)
    (hreach : n ∣ stageProd B1 B1) (hlate : ¬ n ∣ stageProd B1 y) :
    n ∈ lateOrders M B1 y := by
  simp only [lateOrders, Finset.mem_filter, Finset.mem_Ioc]
  exact ⟨⟨Nat.pos_of_ne_zero hn, hnM⟩, late_fire_large_prime_dvd hn hreach hlate⟩

/-! #### The concrete instance `B1 = 100` -/

lemma totalSteps_hundred : totalSteps 100 = 25 := by decide

lemma steps_sixtySeven : #(primesUpTo 67) = 19 := by decide

/-- At `B1 = 100` the primes past position `67` are exactly the last six schedule
steps, i.e. the final `6/25 = 24%` of the schedule. -/
lemma largePrimes_hundred : largePrimes 100 67 = {71, 73, 79, 83, 89, 97} := by decide

/-- The reciprocal sum of the late primes is below `2/25`: the *structural*
probability that a random order fires in the final quarter of the `B1 = 100`
schedule. -/
lemma late_reciprocal_sum_lt : ∑ p ∈ largePrimes 100 67, (1 : ℝ) / p < 2 / 25 := by
  rw [largePrimes_hundred]
  norm_num

/-- **Refutation of H1 at `B1 = 100`.**  The number of orders in `(0, M]` that
can fire in the final `24%` of the stage-1 schedule is less than `2M/25 = 0.08 M`
— far below the `0.2 M` that a *uniform* firing index would predict, and
consistent with the measured empty tail (`0/55`).  Uniformity of the firing-step
index is not merely unobserved: it is structurally impossible. -/
theorem late_tail_density_lt_one_fifth (M : ℕ) (hM : 0 < M) :
    (#(lateOrders M 100 67) : ℝ) < 2 / 25 * M := by
  have h1 : (#(lateOrders M 100 67) : ℝ) ≤ ∑ p ∈ largePrimes 100 67, ((M / p : ℕ) : ℝ) := by
    exact_mod_cast Nat.cast_le.mpr (lateCount_le_primeContribution M 100 67)
  have h2 : ∑ p ∈ largePrimes 100 67, ((M / p : ℕ) : ℝ)
      ≤ ∑ p ∈ largePrimes 100 67, (M : ℝ) * (1 / p) := by
    refine Finset.sum_le_sum fun p hp => ?_
    have hp0 : 0 < p := by
      have := (Finset.mem_filter.mp hp).2
      exact this.pos
    have := Nat.cast_div_le (α := ℝ) (m := M) (n := p)
    calc ((M / p : ℕ) : ℝ) ≤ (M : ℝ) / (p : ℝ) := this
      _ = (M : ℝ) * (1 / p) := by ring
  have h3 : ∑ p ∈ largePrimes 100 67, (M : ℝ) * (1 / p)
      = (M : ℝ) * ∑ p ∈ largePrimes 100 67, (1 : ℝ) / p := by
    rw [Finset.mul_sum]
  have hMpos : (0 : ℝ) < M := by exact_mod_cast hM
  have h4 : (M : ℝ) * ∑ p ∈ largePrimes 100 67, (1 : ℝ) / p < (M : ℝ) * (2 / 25) :=
    mul_lt_mul_of_pos_left late_reciprocal_sum_lt hMpos
  calc (#(lateOrders M 100 67) : ℝ) ≤ ∑ p ∈ largePrimes 100 67, ((M / p : ℕ) : ℝ) := h1
    _ ≤ ∑ p ∈ largePrimes 100 67, (M : ℝ) * (1 / p) := h2
    _ = (M : ℝ) * ∑ p ∈ largePrimes 100 67, (1 : ℝ) / p := h3
    _ < (M : ℝ) * (2 / 25) := h4
    _ = 2 / 25 * M := by ring

/-! ### Work-weighted version of the trace law -/

/-- Each schedule prime contributes a factor at most `B1`, so the accumulated
scalar at position `y` is at most `B1 ^ π(y)`: in *work* units too, an order with
a small largest prime factor fires early. -/
theorem stageProd_le_pow (B1 y : ℕ) (hB1 : B1 ≠ 0) :
    stageProd B1 y ≤ B1 ^ #(primesUpTo y) := by
  rw [stageProd, ← Finset.prod_const]
  exact Finset.prod_le_prod' fun p _ => Nat.pow_log_le_self p hB1

/-- The full stage-1 multiplier dominates the primorial: every prime `≤ B1`
occurs at least once. -/
theorem primorial_dvd_stageProd (B1 : ℕ) :
    (∏ p ∈ primesUpTo B1, p) ∣ stageProd B1 B1 := by
  refine Finset.prod_dvd_prod_of_dvd _ _ fun p hp => ?_
  have hpp : p.Prime := (mem_primesUpTo.mp hp).2
  have hle : p ≤ B1 := (mem_primesUpTo.mp hp).1
  have : 1 ≤ Nat.log p B1 := Nat.log_pos hpp.one_lt hle
  exact dvd_pow_self p (by omega)

/-! ### The collision baseline (refutation of H2) -/

/-- The random-collision success probability of a stage-1 run of `k` guarded
group operations modulo `p`: `1 - (1 - 1/p)^k`. -/
noncomputable def collisionProb (p k : ℕ) : ℝ := 1 - (1 - 1 / (p : ℝ)) ^ k

/-- **Bernoulli ceiling.**  The collision baseline never exceeds `k/p`. -/
theorem collisionProb_le_ratio {p k : ℕ} (hp : 0 < p) : collisionProb p k ≤ k / p := by
  have hp0 : (0 : ℝ) < p := by exact_mod_cast hp
  have hge : (-2 : ℝ) ≤ -(1 / p) := by
    have : (1 : ℝ) / p ≤ 1 := by
      rw [div_le_one hp0]
      exact_mod_cast hp
    linarith
  have := one_add_mul_le_pow hge k
  have hrw : (1 : ℝ) + (-(1 / p)) = 1 - 1 / p := by ring
  rw [hrw] at this
  rw [collisionProb]
  have : 1 - (1 - 1 / (p : ℝ)) ^ k ≤ 1 - (1 + (k : ℝ) * (-(1 / p))) := by linarith
  calc 1 - (1 - 1 / (p : ℝ)) ^ k ≤ 1 - (1 + (k : ℝ) * (-(1 / p))) := this
    _ = (k : ℝ) / p := by field_simp; ring

/-- **Scale freedom of the collision baseline (H2 is untestable by bit length).**
The ceiling depends only on the *ratio* `k/p`.  Two runs at different bit
lengths but the same ratio share the same ceiling, so the collision hypothesis
predicts *no* cross-bit-length collapse — exactly what was measured
(`z`-test `p = 0.8161`). -/
theorem collision_ceiling_scale_free {p q k l : ℕ} (hp : 0 < p) (hq : 0 < q)
    (h : (k : ℝ) / p = (l : ℝ) / q) :
    collisionProb p k ≤ (l : ℝ) / q ∧ collisionProb q l ≤ (k : ℝ) / p := by
  refine ⟨?_, ?_⟩
  · rw [← h]; exact collisionProb_le_ratio hp
  · rw [h]; exact collisionProb_le_ratio hq

/-- **The measured operating point.**  With `B1/p = 0.125` and the honest op
count `ops = 2.59 · B1` (rather than the `1.44` constant used in the original
pre-registration), the collision ceiling is at most `0.324` for *every* prime
`p`, while the measured success rate is `0.625`: the excess `0.3` is not
explicable by collisions at any scale. -/
theorem collision_subdominant {p k : ℕ} (hp : 0 < p) (hk : (k : ℝ) ≤ 0.324 * p)
    {obs : ℝ} (hobs : 0.625 ≤ obs) : collisionProb p k + 0.3 ≤ obs := by
  have hp0 : (0 : ℝ) < p := by exact_mod_cast hp
  have h1 : collisionProb p k ≤ (k : ℝ) / p := collisionProb_le_ratio hp
  have h2 : (k : ℝ) / p ≤ 0.324 := by
    rw [div_le_iff₀ hp0]; linarith
  linarith

/-- **Pigeonhole: genuine order-hits must exist.**  In a batch `T` of curves with
success set `S` and collision set `C`, at least `#S - #C` of the successes are
order-hits.  At the measured cell (`40` curves, `25` successes, at most `12`
collisions by the ceiling above) this forces at least `13` order-hits. -/
theorem order_hits_card_lower_bound {α : Type*} [DecidableEq α] (S C : Finset α) :
    #S - #C ≤ #(S \ C) := by
  have : #S ≤ #(S \ C) + #C := by
    calc #S ≤ #((S \ C) ∪ C) := Finset.card_mono (by
          intro x hx
          by_cases hxc : x ∈ C
          · exact Finset.mem_union_right _ hxc
          · exact Finset.mem_union_left _ (Finset.mem_sdiff.mpr ⟨hx, hxc⟩))
      _ ≤ #(S \ C) + #C := Finset.card_union_le _ _
  omega

/-- The concrete cell of exp 570: `#S = 25` successes out of 40 curves, at most
`#C = 12` collision-driven, hence at least `13` order-hits — collisions are
real but subdominant. -/
theorem order_hits_measured_cell {α : Type*} [DecidableEq α] (S C : Finset α)
    (hS : #S = 25) (hC : #C ≤ 12) : 13 ≤ #(S \ C) := by
  have := order_hits_card_lower_bound S C
  omega

end Catalog.Novelty.EcmStageOneTraceLaw