import Mathlib

/-!
# Paper 137 — the positional filter: sqrt-descending trial division

Experiment 467 measured that visiting the trial divisors of a semiprime `N = p q` in
**descending** order from `⌊√N⌋` (Fermat's order, applied to divisibility tests) buys a
large expected speedup over the ascending scan, concentrated at near-squares.  This file
proves the exact finite combinatorics behind the measurement.

## The model

A candidate pool is a finite set `P` of trial divisors; the standard pool is
`pool N = [2, ⌊√N⌋]`.  A *visitation order* is a key `κ : ℕ → ℕ`; candidates are tested in
increasing key order.  The number of divisibility tests spent is the number of candidates
whose key does not exceed the key of any hit:

  `scanCostOn P κ N = #{d ∈ P | ∀ e ∈ P, e ∣ N → κ d ≤ κ e}`.

(If there is no hit, the whole pool is paid for.)  The ascending scan is `κ = id`, the
sqrt-descending scan is `κ d = N - d`.  Accounting is in divisibility tests (information),
not wall-clock.

## Main results

* `pool_dvd_iff` — for primes `p ≤ q`, the only hit in the pool of `N = p q` is `p`.
* `ascCost_semiprime` — the ascending scan pays exactly `p - 1` tests.
* `descCost_semiprime` — the sqrt-descending scan pays exactly `⌊√N⌋ + 1 - p` tests.
* `asc_add_desc` — **complementarity**: the two costs always add up to `⌊√N⌋`.
* `desc_le_asc_succ_of_lt_four`, `asc_add_two_le_desc_of_four_le` — **the balance wall at
  `4`**: the descending scan wins (up to a one-test tie) exactly when `q < 4 p`.
* `two_mul_desc_le_gap` — near-squares are cheap: `2 (desc - 1) ≤ q - p`.
* `desc_add_fermat` — **Fermat–trial complementarity**: with `a = (p + q)/2`, the
  descending trial scan (walking `⌊√N⌋ ↓ p`) and Fermat's method (walking `⌊√N⌋ ↑ a`) split
  the interval `[p, a]` between them: `desc + (a - ⌊√N⌋) = (q - p)/2 + 1`.
* `truncAsc_semiprime`, `truncDesc_semiprime` — **mechanism (b) is orthogonal to
  mechanism (a)**: truncating the pool at a learned lower bound `L ≤ p` saves exactly
  `L - 2` ascending tests and *no* descending test.
-/

namespace PositionalFilter

open Finset

/-- The trial-division candidate pool `[2, ⌊√N⌋]`. -/
def pool (N : ℕ) : Finset ℕ := Icc 2 (Nat.sqrt N)

/-- Number of divisibility tests spent on the pool `P` by the visitation order with key
`κ`: every candidate visited no later than the first hit. -/
def scanCostOn (P : Finset ℕ) (κ : ℕ → ℕ) (N : ℕ) : ℕ :=
  (P.filter (fun d => ∀ e ∈ P, e ∣ N → κ d ≤ κ e)).card

/-- Cost on the standard pool. -/
def scanCost (κ : ℕ → ℕ) (N : ℕ) : ℕ := scanCostOn (pool N) κ N

/-- The descending key: larger candidates first. -/
def descKey (N : ℕ) : ℕ → ℕ := fun d => N - d

/-- Ascending scan cost. -/
def ascCost (N : ℕ) : ℕ := scanCost id N

/-- Sqrt-descending scan cost (Fermat's order). -/
def descCost (N : ℕ) : ℕ := scanCost (descKey N) N

/-- For primes `p ≤ q`, the only divisor of `p q` in the pool is `p`. -/
theorem pool_dvd_iff {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≤ q) {d : ℕ}
    (hd : d ∈ pool (p * q)) : d ∣ p * q ↔ d = p := by
  rw [pool, mem_Icc, Nat.le_sqrt] at hd
  obtain ⟨h2, hle⟩ := hd
  have hp2 := hp.two_le; have hq2 := hq.two_le
  constructor
  · intro h
    obtain ⟨d1, d2, h1, h2', rfl⟩ := Nat.dvd_mul.mp h
    rcases (Nat.dvd_prime hp).mp h1 with e1 | e1 <;>
      rcases (Nat.dvd_prime hq).mp h2' with e2 | e2 <;> subst e1 e2
    · omega
    · have : d2 * d2 ≤ p * d2 := by simpa using hle
      have : d2 ≤ p := Nat.le_of_mul_le_mul_right this hq.pos
      simp; omega
    · simp
    · nlinarith
  · rintro rfl; exact dvd_mul_right _ _

/-- `p ≤ ⌊√(p q)⌋` when `p ≤ q`. -/
theorem le_sqrt_mul {p q : ℕ} (hpq : p ≤ q) : p ≤ Nat.sqrt (p * q) :=
  Nat.le_sqrt.mpr (Nat.mul_le_mul_left p hpq)

/-- `p` lies in the pool of `p q`. -/
theorem mem_pool {p q : ℕ} (hp : p.Prime) (hpq : p ≤ q) : p ∈ pool (p * q) := by
  rw [pool, mem_Icc]
  exact ⟨hp.two_le, le_sqrt_mul hpq⟩

/-- Generic cost formula on any sub-pool containing `p`, when `p` is the unique hit. -/
theorem scanCostOn_of_unique {P : Finset ℕ} {κ : ℕ → ℕ} {p q : ℕ} (hp : p.Prime)
    (hq : q.Prime) (hpq : p ≤ q) (hP : P ⊆ pool (p * q)) (hpP : p ∈ P) :
    scanCostOn P κ (p * q) = (P.filter (fun d => κ d ≤ κ p)).card := by
  unfold scanCostOn
  congr 1
  apply Finset.filter_congr
  intro d _
  constructor
  · intro h; exact h p hpP (dvd_mul_right _ _)
  · intro h e he hdiv
    rw [(pool_dvd_iff hp hq hpq (hP he)).mp hdiv]; exact h

/-- **Ascending cost.** The plain scan pays `p - 1` divisibility tests. -/
theorem ascCost_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≤ q) :
    ascCost (p * q) = p - 1 := by
  unfold ascCost scanCost
  rw [scanCostOn_of_unique hp hq hpq subset_rfl (mem_pool hp hpq)]
  have hs := le_sqrt_mul hpq
  have h2 := hp.two_le
  have : (pool (p * q)).filter (fun d => id d ≤ id p) = Icc 2 p := by
    ext d; simp only [pool, mem_filter, mem_Icc, id]; omega
  rw [this, Nat.card_Icc]; omega

/-- **Sqrt-descending cost.** Fermat's order pays `⌊√N⌋ + 1 - p` divisibility tests. -/
theorem descCost_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≤ q) :
    descCost (p * q) = Nat.sqrt (p * q) + 1 - p := by
  unfold descCost scanCost
  rw [scanCostOn_of_unique hp hq hpq subset_rfl (mem_pool hp hpq)]
  have hs := le_sqrt_mul hpq
  have hsN := Nat.sqrt_le_self (p * q)
  have h2 := hp.two_le
  have : (pool (p * q)).filter (fun d => descKey (p * q) d ≤ descKey (p * q) p) =
      Icc p (Nat.sqrt (p * q)) := by
    ext d; simp only [pool, descKey, mem_filter, mem_Icc]; omega
  rw [this, Nat.card_Icc]

/-- **Complementarity.** Ascending and descending costs always sum to `⌊√N⌋`. -/
theorem asc_add_desc {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≤ q) :
    ascCost (p * q) + descCost (p * q) = Nat.sqrt (p * q) := by
  rw [ascCost_semiprime hp hq hpq, descCost_semiprime hp hq hpq]
  have hs := le_sqrt_mul hpq
  have h2 := hp.two_le
  omega

/-- **Balance wall, inside.** If `q < 4 p` the descending scan is at least as good as the
ascending one, up to a single-test tie. -/
theorem desc_le_asc_succ_of_lt_four {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≤ q)
    (h4 : q < 4 * p) : descCost (p * q) ≤ ascCost (p * q) + 1 := by
  rw [ascCost_semiprime hp hq hpq, descCost_semiprime hp hq hpq]
  have hlt : Nat.sqrt (p * q) < 2 * p := by
    rw [Nat.sqrt_lt']
    have := hp.pos
    nlinarith
  have h2 := hp.two_le
  omega

/-- **Balance wall, outside.** If `q ≥ 4 p` the ascending scan strictly wins, by at least
two tests. -/
theorem asc_add_two_le_desc_of_four_le {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpq : p ≤ q) (h4 : 4 * p ≤ q) : ascCost (p * q) + 2 ≤ descCost (p * q) := by
  rw [ascCost_semiprime hp hq hpq, descCost_semiprime hp hq hpq]
  have hle : 2 * p ≤ Nat.sqrt (p * q) := by
    rw [Nat.le_sqrt]
    nlinarith
  have h2 := hp.two_le
  omega

/-- AM–GM in the floor form: `2 ⌊√(p q)⌋ ≤ p + q`. -/
theorem two_mul_sqrt_le_add (p q : ℕ) : 2 * Nat.sqrt (p * q) ≤ p + q := by
  have hs := Nat.sqrt_le' (p * q)
  by_contra h
  push_neg at h
  nlinarith [sq_nonneg ((p : ℤ) - q)]

/-- **Near-squares are cheap.** The descending cost is at most half the factor gap, plus
one: `2 (desc - 1) ≤ q - p`. -/
theorem two_mul_desc_le_gap {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≤ q) :
    2 * (descCost (p * q) - 1) ≤ q - p := by
  rw [descCost_semiprime hp hq hpq]
  have := two_mul_sqrt_le_add p q
  omega

/-- A twin-type semiprime (`q ≤ p + 3`) is found by the descending scan in at most two
tests, whatever its size. -/
theorem desc_le_two_of_gap {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≤ q)
    (hgap : q ≤ p + 3) : descCost (p * q) ≤ 2 := by
  have := two_mul_desc_le_gap hp hq hpq
  omega

/-- **Fermat–trial complementarity.** For odd primes `p ≤ q` write `a = (p + q)/2` (the
Fermat target, `N = a² - ((q-p)/2)²`).  The descending trial scan walks `⌊√N⌋ ↓ p`, Fermat's
method walks `⌊√N⌋ ↑ a`; together they cover `[p, a]` exactly once:
`desc + (a - ⌊√N⌋) = (q - p)/2 + 1`. -/
theorem desc_add_fermat {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≤ q) :
    descCost (p * q) + ((p + q) / 2 - Nat.sqrt (p * q)) = (q - p) / 2 + 1 := by
  rw [descCost_semiprime hp hq hpq]
  have h1 := two_mul_sqrt_le_add p q
  have h2 := le_sqrt_mul hpq
  omega

/-! ## Mechanism (b): learned range truncation -/

/-- The truncated pool `[L, ⌊√N⌋]` revealed by a learned feasibility bound `p ≥ L`. -/
def truncPool (L N : ℕ) : Finset ℕ := Icc (max 2 L) (Nat.sqrt N)

theorem truncPool_subset (L N : ℕ) : truncPool L N ⊆ pool N := by
  intro d; simp only [truncPool, pool, mem_Icc]; omega

/-- Truncated ascending scan: `p + 1 - L` tests (for `2 ≤ L ≤ p`). -/
theorem truncAsc_semiprime {p q L : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≤ q)
    (hL2 : 2 ≤ L) (hLp : L ≤ p) :
    scanCostOn (truncPool L (p * q)) id (p * q) = p + 1 - L := by
  have hs := le_sqrt_mul hpq
  have hmem : p ∈ truncPool L (p * q) := by
    simp only [truncPool, mem_Icc]; omega
  rw [scanCostOn_of_unique hp hq hpq (truncPool_subset _ _) hmem]
  have : (truncPool L (p * q)).filter (fun d => id d ≤ id p) = Icc L p := by
    ext d; simp only [truncPool, mem_filter, mem_Icc, id]; omega
  rw [this, Nat.card_Icc]

/-- Truncation buys the descending scan nothing: its cost is unchanged. -/
theorem truncDesc_semiprime {p q L : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≤ q)
    (hLp : L ≤ p) :
    scanCostOn (truncPool L (p * q)) (descKey (p * q)) (p * q) = descCost (p * q) := by
  have hs := le_sqrt_mul hpq
  have hsN := Nat.sqrt_le_self (p * q)
  have h2 := hp.two_le
  have hmem : p ∈ truncPool L (p * q) := by
    simp only [truncPool, mem_Icc]; omega
  rw [scanCostOn_of_unique hp hq hpq (truncPool_subset _ _) hmem, descCost_semiprime hp hq hpq]
  have : (truncPool L (p * q)).filter
      (fun d => descKey (p * q) d ≤ descKey (p * q) p) = Icc p (Nat.sqrt (p * q)) := by
    ext d; simp only [truncPool, descKey, mem_filter, mem_Icc]; omega
  rw [this, Nat.card_Icc]

/-- **Orthogonality of the two mechanisms.** Truncation at `L` saves exactly `L - 2`
ascending tests and zero descending tests. -/
theorem truncation_saving {p q L : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≤ q)
    (hL2 : 2 ≤ L) (hLp : L ≤ p) :
    scanCostOn (truncPool L (p * q)) id (p * q) + (L - 2) = ascCost (p * q) ∧
    scanCostOn (truncPool L (p * q)) (descKey (p * q)) (p * q) = descCost (p * q) := by
  refine ⟨?_, truncDesc_semiprime hp hq hpq hLp⟩
  rw [truncAsc_semiprime hp hq hpq hL2 hLp, ascCost_semiprime hp hq hpq]
  omega

/-- A concrete instance: `N = 101 · 103`; ascending pays `100`, descending pays `1`. -/
theorem example_twin : ascCost (101 * 103) = 100 ∧ descCost (101 * 103) = 1 := by
  refine ⟨?_, ?_⟩
  · rw [ascCost_semiprime (by norm_num) (by norm_num) (by norm_num)]
  · rw [descCost_semiprime (by norm_num) (by norm_num) (by norm_num)]
    have : Nat.sqrt (101 * 103) = 101 := by
      rw [eq_comm, Nat.eq_sqrt]; norm_num
    rw [this]

end PositionalFilter