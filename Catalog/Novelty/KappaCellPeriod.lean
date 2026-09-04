/-
# The small-prime cell measure over one period: exact counts and independence

## Research context (FACT round-95 #4, exp 606 KAPPA-SUFFICIENCY-SCALE)

Experiment 606 measures, for integers `v` drawn from a window, the *cell* of `v`
relative to a fixed base `B` of small primes — the set `S = {p ∈ B : p ∣ v}` — and
the *composition order* `κ(v) = |S|`, and regresses a log smoothness rate on `κ`.
The reported empirical law is

  `log-rate ≈ dial − 0.35·κ + (cell-identity terms)`,

with the identity terms switching on only in the rare-smoothness regime.

Any statement of the form "κ summarises everything rate-relevant" presupposes a
model for how cells are distributed in the population.  This file supplies the
*exact* arithmetic distribution, with no heuristic: over one full period
`M = ∏_{p ∈ B} p` the cell statistic is distributed **exactly** as a product of
independent Bernoulli variables, `p ∣ v` having probability `1/p`.

## Main results

* `card_cellFiber` — for every `S ⊆ B` the number of `v ∈ [0, M)` whose cell is
  exactly `S` equals `∏_{p ∈ B \ S} (p − 1)`.  (Proof: divide out the forced part
  `d = ∏_{p∈S} p` and recognise the remaining count as Euler's totient of
  `∏_{p ∈ B\S} p`.)
* `cellFiber_density` — hence the density of the cell `S` is exactly
  `∏_{p∈S} (1/p) · ∏_{p ∈ B\S} (1 − 1/p)`: the divisibility events are *exactly*
  independent over a period, not merely asymptotically.
* `sum_card_cellFiber` — the fibres partition the period (`∑_S |fibre S| = M`),
  so the above really is a probability distribution.
* `sum_kappa_period` / `expected_kappa` — the mean composition order over a period
  is exactly `∑_{p ∈ B} 1/p` (the Mertens sum truncated at the base).
* `card_cellFiber_pos` — every cell is populated, so the regression of a rate on
  `κ` has support at every value `0 ≤ κ ≤ |B|`.

These are the inputs consumed by `Novelty.KappaSufficiencyScale`, where the
sufficiency question ("does κ carry all the information of the cell?") is settled.

-- !-- Lab Notes -- !--
-- HYPOTHESIS.  Over one period of the small-prime base the cell statistic should
--   be an exact product measure with marginals `1/p`.
-- EXPERIMENT (`#eval`, B = {2,3,5}, M = 30): fibre sizes
--   ∅ ↦ 8, {2} ↦ 8, {3} ↦ 4, {5} ↦ 2, {2,3} ↦ 4, {2,5} ↦ 2, {3,5} ↦ 1, {2,3,5} ↦ 1;
--   total 30 ✓, and 8 = 1·2·4, 8 = 2·4, 4 = 1·4 … matching `∏_{p ∉ S}(p−1)` in every case
--   (checked exhaustively for B = {2,3,5,7} as well).
--   Total κ over the period = 31 = 15 + 10 + 6, i.e. mean 31/30 = 1/2 + 1/3 + 1/5 ✓.
-- OUTCOME.  Both identities proved unconditionally for an arbitrary finite base of
--   distinct primes.
-- FAILURE ANALYSIS.  A first attempt routed through `ZMod.prodEquivPi` (CRT) and
--   stalled on identifying the component maps with `ZMod.castHom`.  Dividing out the
--   forced factor `d` and invoking `Nat.totient` instead removes CRT entirely.
-/
import Mathlib

open Finset

namespace Catalog.Novelty.KappaCellPeriod

variable {B S : Finset ℕ}

/-- The period of a base `B` of small primes: `∏_{p ∈ B} p`. -/
def period (B : Finset ℕ) : ℕ := ∏ p ∈ B, p

/-- The **cell** of `v` relative to the base `B`: the set of base primes dividing `v`. -/
def cell (B : Finset ℕ) (v : ℕ) : Finset ℕ := B.filter (· ∣ v)

/-- The **composition order** of `v`: how many base primes divide `v`. -/
def kappa (B : Finset ℕ) (v : ℕ) : ℕ := (cell B v).card

/-- The fibre of the cell map over `S`, inside one period. -/
def cellFiber (B S : Finset ℕ) : Finset ℕ :=
  (range (period B)).filter (fun v => cell B v = S)

@[simp] lemma mem_cell {B : Finset ℕ} {v p : ℕ} : p ∈ cell B v ↔ p ∈ B ∧ p ∣ v := by
  simp [cell]

lemma cell_subset (B : Finset ℕ) (v : ℕ) : cell B v ⊆ B := filter_subset _ _

/-- Membership description of the cell fibre. -/
lemma cell_eq_iff (hS : S ⊆ B) (v : ℕ) :
    cell B v = S ↔ ∀ p ∈ B, (p ∣ v ↔ p ∈ S) := by
  constructor
  · intro h p hp
    constructor
    · intro hd; rw [← h]; exact mem_cell.2 ⟨hp, hd⟩
    · intro hpS; have := hS hpS; rw [← h] at hpS; exact (mem_cell.1 hpS).2
  · intro h
    ext p
    simp only [mem_cell]
    constructor
    · rintro ⟨hp, hd⟩; exact (h p hp).1 hd
    · intro hpS; exact ⟨hS hpS, (h p (hS hpS)).2 hpS⟩

/-- Euler's totient of a squarefree product of distinct primes. -/
lemma totient_prod_primes {T : Finset ℕ} (hT : ∀ p ∈ T, Nat.Prime p) :
    Nat.totient (∏ p ∈ T, p) = ∏ p ∈ T, (p - 1) := by
  classical
  induction T using Finset.induction with
  | empty => simp
  | insert a T ha ih =>
      have hprimes : ∀ p ∈ T, Nat.Prime p := fun p hp => hT p (mem_insert_of_mem hp)
      have hpa : Nat.Prime a := hT a (mem_insert_self a T)
      have hcop : Nat.Coprime a (∏ p ∈ T, p) := by
        refine Nat.Coprime.prod_right ?_
        intro i hi
        have hpi : Nat.Prime i := hprimes i hi
        have : a ≠ i := by rintro rfl; exact ha hi
        exact (Nat.coprime_primes hpa hpi).2 this
      rw [Finset.prod_insert ha, Finset.prod_insert ha, Nat.totient_mul hcop,
        Nat.totient_prime hpa, ih hprimes]

/-- **Exact cell counts over a period.**  For a base `B` of distinct primes and any
sub-cell `S ⊆ B`, the number of residues `v ∈ [0, ∏_{p∈B} p)` whose small-prime cell is
exactly `S` equals `∏_{p ∈ B \ S} (p − 1)`. -/
theorem card_cellFiber (hB : ∀ p ∈ B, Nat.Prime p) (hS : S ⊆ B) :
    (cellFiber B S).card = ∏ p ∈ B \ S, (p - 1) := by
  classical
  set d : ℕ := ∏ p ∈ S, p with hd
  set M : ℕ := ∏ p ∈ B \ S, p with hM
  have hperiod : period B = M * d := (Finset.prod_sdiff hS).symm
  have hdpos : 0 < d := Finset.prod_pos (fun p hp => (hB p (hS hp)).pos)
  have hMpos : 0 < M := Finset.prod_pos (fun p hp => (hB p (mem_sdiff.1 hp).1).pos)
  -- the source: residues mod `M` coprime to `M`
  have hsrc : ((range M).filter (Nat.Coprime M)).card = ∏ p ∈ B \ S, (p - 1) := by
    have := totient_prod_primes (T := B \ S) (fun p hp => hB p (mem_sdiff.1 hp).1)
    rw [← hM] at this
    simpa [Nat.totient] using this
  rw [← hsrc]
  -- the bijection `u ↦ d * u`
  refine (Finset.card_nbij (i := fun u => d * u) ?_ ?_ ?_).symm
  · -- maps into the fibre
    intro u hu
    simp only [coe_filter, Set.mem_setOf_eq, mem_range] at hu
    obtain ⟨hu1, hu2⟩ := hu
    simp only [cellFiber, coe_filter, Set.mem_setOf_eq, mem_range]
    constructor
    · rw [hperiod, mul_comm M d]
      exact (Nat.mul_lt_mul_left hdpos).2 hu1
    · rw [cell_eq_iff hS]
      intro p hp
      by_cases hpS : p ∈ S
      · simp only [hpS, iff_true]
        exact Dvd.dvd.mul_right (Finset.dvd_prod_of_mem _ hpS) u
      · simp only [hpS, iff_false]
        have hpBS : p ∈ B \ S := mem_sdiff.2 ⟨hp, hpS⟩
        have hpp : Nat.Prime p := hB p hp
        have hpd : ¬ p ∣ d := by
          intro hdvd
          obtain ⟨q, hq, hpq⟩ := (Nat.Prime.prime hpp).exists_mem_finset_dvd hdvd
          have : p = q := ((Nat.prime_dvd_prime_iff_eq hpp (hB q (hS hq))).1 hpq)
          exact hpS (this ▸ hq)
        have hpu : ¬ p ∣ u := by
          intro hdvd
          have hcop : Nat.Coprime p u := Nat.Coprime.coprime_dvd_left
            (Finset.dvd_prod_of_mem _ hpBS) hu2
          exact (hpp.coprime_iff_not_dvd.1 hcop) hdvd
        intro hcon
        rcases (Nat.Prime.dvd_mul hpp).1 hcon with h | h
        · exact hpd h
        · exact hpu h
  · -- injective
    intro u _ v _ h
    exact Nat.eq_of_mul_eq_mul_left hdpos h
  · -- surjective
    intro v hv
    simp only [cellFiber, coe_filter, Set.mem_setOf_eq, mem_range] at hv
    obtain ⟨hv1, hv2⟩ := hv
    rw [cell_eq_iff hS] at hv2
    -- `d ∣ v` since every prime of `S` divides `v`
    have hdv : d ∣ v := by
      refine Finset.prod_primes_dvd v ?_ ?_
      · intro p hp; exact (hB p (hS hp)).prime
      · intro p hp; exact (hv2 p (hS hp)).2 hp
    obtain ⟨u, rfl⟩ := hdv
    refine ⟨u, ?_, rfl⟩
    simp only [coe_filter, Set.mem_setOf_eq, mem_range]
    constructor
    · have : d * u < d * M := by rw [mul_comm d M, ← hperiod]; exact hv1
      exact Nat.lt_of_mul_lt_mul_left this
    · -- coprimality: no prime of `B \ S` divides `u`
      refine Nat.Coprime.prod_left ?_
      intro p hp
      obtain ⟨hpB, hpS⟩ := mem_sdiff.1 hp
      have hpp : Nat.Prime p := hB p hpB
      refine hpp.coprime_iff_not_dvd.2 ?_
      intro hdvd
      exact hpS ((hv2 p hpB).1 (Dvd.dvd.mul_left hdvd d))

/-- Every cell is realised inside a single period. -/
theorem card_cellFiber_pos (hB : ∀ p ∈ B, Nat.Prime p) (hS : S ⊆ B) :
    0 < (cellFiber B S).card := by
  rw [card_cellFiber hB hS]
  refine Finset.prod_pos (fun p hp => ?_)
  have := (hB p (mem_sdiff.1 hp).1).two_le
  omega

/-- **The cell fibres partition the period.**  Summing the exact counts over all cells
recovers `∏_{p ∈ B} p`. -/
theorem sum_card_cellFiber (hB : ∀ p ∈ B, Nat.Prime p) :
    ∑ S ∈ B.powerset, (cellFiber B S).card = period B := by
  classical
  have h : ∀ S ∈ B.powerset, (cellFiber B S).card = (∏ p ∈ S, 1) * ∏ p ∈ B \ S, (p - 1) := by
    intro S hS
    rw [card_cellFiber hB (mem_powerset.1 hS)]
    simp
  rw [Finset.sum_congr rfl h, ← Finset.prod_add]
  refine Finset.prod_congr rfl (fun p hp => ?_)
  have := (hB p hp).two_le
  omega

/-- **Exact independence of the small-prime divisibility events.**  The density of the
cell `S` in one period is the product measure `∏_{p∈S} (1/p) · ∏_{p ∉ S} (1 − 1/p)`. -/
theorem cellFiber_density (hB : ∀ p ∈ B, Nat.Prime p) (hS : S ⊆ B) :
    ((cellFiber B S).card : ℝ) / (period B : ℝ)
      = (∏ p ∈ S, (1 : ℝ) / p) * ∏ p ∈ B \ S, (1 - (1 : ℝ) / p) := by
  classical
  have hppos : ∀ p ∈ B, (0 : ℝ) < p := by
    intro p hp; exact_mod_cast (hB p hp).pos
  have hperiod : period B = (∏ p ∈ B \ S, p) * ∏ p ∈ S, p := by
    rw [period]; exact (Finset.prod_sdiff hS).symm
  have hP : ((period B : ℝ)) = (∏ p ∈ B \ S, (p : ℝ)) * ∏ p ∈ S, (p : ℝ) := by
    rw [hperiod]; push_cast; ring
  have hne1 : (∏ p ∈ B \ S, (p : ℝ)) ≠ 0 :=
    ne_of_gt (Finset.prod_pos (fun p hp => hppos p (mem_sdiff.1 hp).1))
  have hne2 : (∏ p ∈ S, (p : ℝ)) ≠ 0 :=
    ne_of_gt (Finset.prod_pos (fun p hp => hppos p (hS hp)))
  have hcast : ((∏ p ∈ B \ S, (p - 1) : ℕ) : ℝ) = ∏ p ∈ B \ S, ((p : ℝ) - 1) := by
    push_cast
    refine Finset.prod_congr rfl (fun p hp => ?_)
    have := (hB p (mem_sdiff.1 hp).1).two_le
    have : (1 : ℕ) ≤ p := by omega
    push_cast [this]
    ring
  rw [card_cellFiber hB hS, hcast, hP]
  rw [Finset.prod_div_distrib, Finset.prod_const_one]
  have hsub : ∀ p ∈ B \ S, (1 : ℝ) - 1 / p = ((p : ℝ) - 1) / p := by
    intro p hp
    have := hppos p (mem_sdiff.1 hp).1
    field_simp
  rw [Finset.prod_congr rfl hsub, Finset.prod_div_distrib]
  field_simp

/-- The total composition order over a period: `∑_{v < M} κ(v) = ∑_{p ∈ B} M / p`. -/
theorem sum_kappa_period (hB : ∀ p ∈ B, Nat.Prime p) :
    ∑ v ∈ range (period B), kappa B v = ∑ p ∈ B, period B / p := by
  classical
  have hstep : ∀ v, kappa B v = ∑ p ∈ B, if p ∣ v then 1 else 0 := by
    intro v
    simp only [kappa, cell, Finset.card_filter]
  calc ∑ v ∈ range (period B), kappa B v
      = ∑ v ∈ range (period B), ∑ p ∈ B, (if p ∣ v then 1 else 0) := by
        exact Finset.sum_congr rfl (fun v _ => hstep v)
    _ = ∑ p ∈ B, ∑ v ∈ range (period B), (if p ∣ v then 1 else 0) := Finset.sum_comm
    _ = ∑ p ∈ B, period B / p := by
        refine Finset.sum_congr rfl (fun p hp => ?_)
        rw [← Finset.card_filter]
        have hppos : 0 < p := (hB p hp).pos
        have hdvdM : p ∣ period B := Finset.dvd_prod_of_mem _ hp
        have hMeq : period B = p * (period B / p) := (Nat.mul_div_cancel' hdvdM).symm
        have hiff : ∀ k : ℕ, p * k < period B ↔ k < period B / p := by
          intro k
          constructor
          · intro h
            have h' : p * k < p * (period B / p) := by rw [← hMeq]; exact h
            exact (Nat.mul_lt_mul_left hppos).1 h'
          · intro h
            have h' : p * k < p * (period B / p) := (Nat.mul_lt_mul_left hppos).2 h
            rw [← hMeq] at h'; exact h'
        have himg : (range (period B)).filter (fun v => p ∣ v) =
            (range (period B / p)).image (fun k => p * k) := by
          ext v
          simp only [mem_filter, mem_range, mem_image]
          constructor
          · rintro ⟨hv, k, rfl⟩
            exact ⟨k, (hiff k).1 hv, rfl⟩
          · rintro ⟨k, hk, rfl⟩
            exact ⟨(hiff k).2 hk, Dvd.intro k rfl⟩
        rw [himg, Finset.card_image_of_injective _ (fun a b h =>
          Nat.eq_of_mul_eq_mul_left hppos h), Finset.card_range]

/-- **The mean composition order over one period is the truncated Mertens sum.**
`(1/M) ∑_{v < M} κ(v) = ∑_{p ∈ B} 1/p`. -/
theorem expected_kappa (hB : ∀ p ∈ B, Nat.Prime p) :
    (∑ v ∈ range (period B), (kappa B v : ℝ)) / (period B : ℝ) = ∑ p ∈ B, (1 : ℝ) / p := by
  classical
  have hMpos : 0 < period B := Finset.prod_pos (fun p hp => (hB p hp).pos)
  have hMne : ((period B : ℝ)) ≠ 0 := Nat.cast_ne_zero.2 hMpos.ne'
  have hsum : (∑ v ∈ range (period B), (kappa B v : ℝ)) = ((∑ p ∈ B, period B / p : ℕ) : ℝ) := by
    rw [← sum_kappa_period hB]; push_cast; rfl
  rw [hsum, Nat.cast_sum]
  rw [Finset.sum_div]
  refine Finset.sum_congr rfl (fun p hp => ?_)
  have hdvd : p ∣ period B := Finset.dvd_prod_of_mem _ hp
  have hppos : (0 : ℝ) < p := by exact_mod_cast (hB p hp).pos
  have : ((period B / p : ℕ) : ℝ) = (period B : ℝ) / p := by
    rw [Nat.cast_div hdvd (ne_of_gt hppos)]
  rw [this]
  field_simp

end Catalog.Novelty.KappaCellPeriod