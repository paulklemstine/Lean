import Mathlib

/-!
# The per-`N` sieve-yield dial: exact root counts behind `QR(≤100)`

The round-39 experiment (exp 476) adopts the empirical predictor

  `rate(N) ≈ −0.0035 + 0.01156 · QR(≤100)`,

where `QR(≤100)` counts the odd primes `p ≤ 100` that pass the Euler test
`N^((p-1)/2) ≡ 1 (mod p)`, i.e. the primes that enter the quadratic-sieve
factor base of `N`.  This file proves the exact arithmetic that makes such a
feature meaningful, and the exact boundary of the adopted linear form.

Main results.

* `qsRoots_eq_one_add_legendre` — the number of sieve hits of `Q(x) = x² − N`
  in one period mod an odd prime `p` is exactly `1 + (N/p)`.
* `eulerPass_iff_legendre` — the computable Euler test used by the experiment is
  exactly the Legendre-symbol condition `(N/p) = 1`.
* `qsRoots_split` — per prime, `#roots = 2·[Euler pass] + [p ∣ N]`.
* `total_roots_affine` — **shape theorem**: summed over any set of odd primes,
  the total root mass is *exactly affine* in the QR feature,
  `Σ roots = 2·QR(N) + #{p ∣ N}`, slope `2`, with no other dependence on `N`.
* `sieve_hits_interval` — over an interval of `L` periods, the sieve hits are
  exactly `L · #roots` (periodicity), and `weighted_sieve_hits` gives the
  `1/p`-weighted total over a common period.
* `eulerPass_count`, `population_feature_sum` — **level theorem**: in every
  complete residue system mod `p`, exactly `(p−1)/2` values of `N` pass the Euler
  test; so the population mean of the feature is fixed by the population alone.
* `dial_pos_iff`, `dial_le_max`, `dial_negative_witness` — the adopted rational
  form `−7/2000 + (289/25000)·q` is positive iff `q ≥ 1`, is at most
  `13697/50000` on all `N`, and the semiprime `N = 163520117 = 2027 · 80671`
  has `QR(≤100) = 0`, so the adopted dial predicts a *negative* rate there:
  the linear dial needs clipping at the bottom of its range.
-/

namespace PerNPredictor

open Finset

/-! ## Periodic counting -/

/-- Counting a `p`-periodic predicate on `L` full periods gives `L` times the
count on one period. -/
theorem card_filter_range_mul_of_periodic (P : ℕ → Prop) [DecidablePred P] {p : ℕ}
    (hper : ∀ x, P (x + p) ↔ P x) (L : ℕ) :
    ((range (L * p)).filter P).card = L * ((range p).filter P).card := by
  have hshift : ∀ k x, P (x + k * p) ↔ P x := by
    intro k; induction k with
    | zero => simp
    | succ k ih => intro x; rw [Nat.succ_mul, ← add_assoc, hper, ih]
  induction L with
  | zero => simp
  | succ L ih =>
    rw [Finset.card_filter, Nat.succ_mul, Finset.sum_range_add, ← Finset.card_filter, ih,
      Nat.succ_mul, Finset.card_filter]
    congr 1
    apply Finset.sum_congr rfl
    intro x _
    have := hshift L x
    rw [add_comm] at this
    simp only [this]

/-! ## Sieve roots of `x² − N` -/

/-- Sieve hits of the QS polynomial `Q(x) = x² − N` in one period `0 ≤ x < p`. -/
def qsRoots (p N : ℕ) : ℕ :=
  ((range p).filter fun r : ℕ => (p : ℤ) ∣ (r : ℤ) ^ 2 - N).card

/-- The sieve-hit count is the number of square roots of `N` in `ZMod p`. -/
theorem qsRoots_eq_card_sqrts (p N : ℕ) [NeZero p] :
    qsRoots p N = (univ.filter fun x : ZMod p => x ^ 2 = (N : ZMod p)).card := by
  unfold qsRoots
  apply Finset.card_nbij (fun r : ℕ => ((r : ℕ) : ZMod p))
  · intro r hr
    simp only [coe_filter, mem_range, Set.mem_setOf_eq, mem_univ, true_and] at hr ⊢
    have := (ZMod.intCast_zmod_eq_zero_iff_dvd ((r:ℤ)^2 - N) p).mpr hr.2
    push_cast at this
    exact sub_eq_zero.mp this
  · intro a ha b hb hab
    simp only [coe_filter, mem_range, Set.mem_setOf_eq] at ha hb
    have := (ZMod.natCast_eq_natCast_iff' a b p).mp hab
    rwa [Nat.mod_eq_of_lt ha.1, Nat.mod_eq_of_lt hb.1] at this
  · intro x hx
    simp only [coe_filter, mem_univ, true_and, Set.mem_setOf_eq] at hx
    refine ⟨x.val, ?_, ZMod.natCast_zmod_val x⟩
    simp only [coe_filter, mem_range, Set.mem_setOf_eq]
    refine ⟨ZMod.val_lt x, ?_⟩
    rw [← ZMod.intCast_zmod_eq_zero_iff_dvd]
    push_cast
    rw [ZMod.natCast_zmod_val, hx, sub_self]

/-- **Root count = `1 + (N/p)`** for an odd prime `p`. -/
theorem qsRoots_eq_one_add_legendre (p N : ℕ) [Fact p.Prime] (hp2 : p ≠ 2) :
    (qsRoots p N : ℤ) = 1 + legendreSym p N := by
  rw [qsRoots_eq_card_sqrts]
  have h := quadraticChar_card_sqrts (F := ZMod p) (by rwa [ZMod.ringChar_zmod_n]) (N : ZMod p)
  rw [legendreSym]
  simp only [Set.toFinset_setOf] at h
  push_cast
  rw [h, add_comm]

/-! ## The Euler test used by the experiment -/

/-- The computable Euler test: `p ∤ N` and `N^(p/2) ≡ 1 (mod p)`
(for odd `p`, `p/2 = (p-1)/2`). -/
abbrev eulerPass (p N : ℕ) : Prop := ¬ p ∣ N ∧ N ^ (p / 2) % p = 1

/-- The Euler test is exactly the Legendre condition `(N/p) = 1`. -/
theorem eulerPass_iff_legendre (p N : ℕ) [hp : Fact p.Prime] (hp2 : p ≠ 2) :
    eulerPass p N ↔ legendreSym p N = 1 := by
  have h1p : 1 < p := hp.out.one_lt
  haveI : Fact (2 < p) := ⟨by have := hp.out.two_le; omega⟩
  have hne : (-1 : ZMod p) ≠ 1 := ZMod.neg_one_ne_one (n := p)
  have hpow := legendreSym.eq_pow p (N : ℤ)
  push_cast at hpow
  constructor
  · rintro ⟨hnd, hmod⟩
    have hN0 : ((N : ℤ) : ZMod p) ≠ 0 := by
      push_cast; rwa [Ne, ZMod.natCast_eq_zero_iff]
    have h1 : (N : ZMod p) ^ (p / 2) = 1 := by
      have : ((N ^ (p / 2) : ℕ) : ZMod p) = ((1 : ℕ) : ZMod p) := by
        rw [ZMod.natCast_eq_natCast_iff', hmod, Nat.mod_eq_of_lt h1p]
      push_cast at this; exact this
    rcases legendreSym.eq_one_or_neg_one p hN0 with h | h
    · exact h
    · rw [h, h1] at hpow; push_cast at hpow; exact absurd hpow hne
  · intro h
    have hN0 : ((N : ℤ) : ZMod p) ≠ 0 := by
      intro h0; rw [← legendreSym.eq_zero_iff] at h0; rw [h0] at h; exact zero_ne_one h
    refine ⟨?_, ?_⟩
    · push_cast at hN0; rwa [Ne, ZMod.natCast_eq_zero_iff] at hN0
    · rw [h] at hpow
      have : ((N ^ (p / 2) : ℕ) : ZMod p) = ((1 : ℕ) : ZMod p) := by
        push_cast; exact_mod_cast hpow.symm
      rw [ZMod.natCast_eq_natCast_iff', Nat.mod_eq_of_lt h1p] at this
      exact this

/-- Per prime: `#roots = 2·[Euler pass] + [p ∣ N]`. -/
theorem qsRoots_split (p N : ℕ) [hp : Fact p.Prime] (hp2 : p ≠ 2) :
    qsRoots p N = (if eulerPass p N then 2 else 0) + (if p ∣ N then 1 else 0) := by
  have h := qsRoots_eq_one_add_legendre p N hp2
  have hz : legendreSym p N = 0 ↔ p ∣ N := by
    rw [legendreSym.eq_zero_iff]; push_cast; exact ZMod.natCast_eq_zero_iff N p
  have he := eulerPass_iff_legendre p N hp2
  by_cases hd : p ∣ N
  · have h0 := hz.mpr hd
    have hnp : ¬ eulerPass p N := fun hh => hh.1 hd
    rw [if_neg hnp, if_pos hd]
    rw [h0] at h; omega
  · have hne0 : ((N : ℤ) : ZMod p) ≠ 0 := by
      push_cast; rwa [Ne, ZMod.natCast_eq_zero_iff]
    rcases legendreSym.eq_one_or_neg_one p hne0 with h1 | h1
    · rw [if_pos (he.mpr h1), if_neg hd]; rw [h1] at h; omega
    · have : ¬ eulerPass p N := by rw [he, h1]; decide
      rw [if_neg this, if_neg hd]; rw [h1] at h; omega

/-! ## The QR feature and the shape theorem -/

/-- The QR feature on a prime set `S`: the number of primes passing the Euler test. -/
def qrFeature (S : Finset ℕ) (N : ℕ) : ℕ := (S.filter fun p => eulerPass p N).card

/-- **Shape theorem.** The total root mass over any set of odd primes is exactly
affine in the QR feature: `Σ roots = 2·QR(N) + #{p ∈ S : p ∣ N}`. -/
theorem total_roots_affine (S : Finset ℕ) (hS : ∀ p ∈ S, p.Prime ∧ p ≠ 2) (N : ℕ) :
    ∑ p ∈ S, qsRoots p N = 2 * qrFeature S N + (S.filter (· ∣ N)).card := by
  rw [qrFeature, card_filter, card_filter, mul_sum, ← sum_add_distrib]
  apply sum_congr rfl
  intro p hp
  haveI : Fact p.Prime := ⟨(hS p hp).1⟩
  rw [qsRoots_split p N (hS p hp).2]
  split_ifs <;> simp

/-- For `N` coprime to every prime of `S` the root mass is exactly `2·QR(N)`. -/
theorem total_roots_coprime (S : Finset ℕ) (hS : ∀ p ∈ S, p.Prime ∧ p ≠ 2) (N : ℕ)
    (hN : ∀ p ∈ S, ¬ p ∣ N) :
    ∑ p ∈ S, qsRoots p N = 2 * qrFeature S N := by
  rw [total_roots_affine S hS N, filter_false_of_mem hN, card_empty, add_zero]

/-! ## Sieve hits on intervals -/

/-- Divisibility of `x² − N` by `p` is `p`-periodic in `x`. -/
theorem qsHit_periodic (p N x : ℕ) :
    ((p : ℤ) ∣ ((x + p : ℕ) : ℤ) ^ 2 - N) ↔ ((p : ℤ) ∣ (x : ℤ) ^ 2 - N) := by
  have : (((x + p : ℕ) : ℤ) ^ 2 - N) = ((x : ℤ) ^ 2 - N) + p * (2 * x + p) := by
    push_cast; ring
  rw [this]
  exact (Int.dvd_add_left (dvd_mul_right _ _))

/-- Over `L` full periods the sieve hits are exactly `L · #roots`. -/
theorem sieve_hits_interval (p N L : ℕ) :
    ((range (L * p)).filter fun x : ℕ => (p : ℤ) ∣ (x : ℤ) ^ 2 - N).card = L * qsRoots p N :=
  card_filter_range_mul_of_periodic _ (fun x => qsHit_periodic p N x) L

/-- **Weighted sieve yield.** Over a common period `M` of the odd primes in `S`,
the total sieve hits are `Σ_p (M/p)·(2·[Euler pass] + [p ∣ N])`. -/
theorem weighted_sieve_hits (S : Finset ℕ) (hS : ∀ p ∈ S, p.Prime ∧ p ≠ 2) (M N : ℕ)
    (hM : ∀ p ∈ S, p ∣ M) :
    ∑ p ∈ S, ((range M).filter fun x : ℕ => (p : ℤ) ∣ (x : ℤ) ^ 2 - N).card
      = ∑ p ∈ S, (M / p) * ((if eulerPass p N then 2 else 0) + (if p ∣ N then 1 else 0)) := by
  apply sum_congr rfl
  intro p hp
  haveI : Fact p.Prime := ⟨(hS p hp).1⟩
  have hMp : M = (M / p) * p := (Nat.div_mul_cancel (hM p hp)).symm
  conv_lhs => rw [hMp]
  rw [sieve_hits_interval, qsRoots_split p N (hS p hp).2]

/-! ## The level theorem: the population fixes the mean feature -/

/-- Each `r` hits exactly one class `a mod p`, so the root counts over a complete
residue system sum to `p`. -/
theorem sum_qsRoots_range (p : ℕ) (hp : 0 < p) : ∑ a ∈ range p, qsRoots p a = p := by
  unfold qsRoots
  simp_rw [card_filter]
  rw [sum_comm]
  conv_rhs => rw [← card_range p, card_eq_sum_ones]
  apply sum_congr rfl
  intro r _
  rw [← card_filter, card_eq_one]
  refine ⟨r ^ 2 % p, ?_⟩
  ext a
  simp only [mem_filter, mem_range, mem_singleton]
  constructor
  · rintro ⟨ha, hd⟩
    have h1 : ((a : ℤ)) % p = ((r : ℤ) ^ 2) % p := (Int.modEq_iff_dvd).mpr hd
    have : (a : ℤ) % p = a := Int.emod_eq_of_lt (by positivity) (by exact_mod_cast ha)
    rw [this] at h1
    exact_mod_cast h1
  · rintro rfl
    refine ⟨Nat.mod_lt _ hp, ?_⟩
    have : ((r ^ 2 % p : ℕ) : ℤ) = (r : ℤ) ^ 2 % p := by push_cast; rfl
    rw [this]
    exact Int.dvd_self_sub_emod

/-- **Exactly half of the units pass.** In a complete residue system mod an odd
prime `p`, exactly `(p-1)/2` values of `N` pass the Euler test.  (Derived from
the root-count identities, not from Euler's criterion counting.) -/
theorem eulerPass_count (p : ℕ) [hp : Fact p.Prime] (hp2 : p ≠ 2) :
    ((range p).filter fun N => eulerPass p N).card = p / 2 := by
  have h1 := sum_qsRoots_range p hp.out.pos
  have h2 : ∑ a ∈ range p, qsRoots p a
      = 2 * ((range p).filter fun N => eulerPass p N).card + ((range p).filter (p ∣ ·)).card := by
    rw [card_filter, card_filter, mul_sum, ← sum_add_distrib]
    apply sum_congr rfl
    intro a _
    rw [qsRoots_split p a hp2]
    split_ifs <;> simp
  have h3 : ((range p).filter (p ∣ ·)) = {0} := by
    ext a; simp only [mem_filter, mem_range, mem_singleton]
    constructor
    · rintro ⟨ha, hd⟩; exact Nat.eq_zero_of_dvd_of_lt hd ha
    · rintro rfl; exact ⟨hp.out.pos, dvd_zero p⟩
  rw [h3, card_singleton] at h2
  have hodd : p % 2 = 1 := by
    rcases hp.out.eq_two_or_odd with h | h
    · exact absurd h hp2
    · exact h
  omega

/-- The Euler test is `p`-periodic in `N`. -/
theorem eulerPass_periodic (p x : ℕ) : eulerPass p (x + p) ↔ eulerPass p x := by
  unfold eulerPass
  rw [Nat.dvd_add_self_right, Nat.pow_mod, Nat.add_mod_right, ← Nat.pow_mod]

/-- **Population level theorem.** Over any range `N < M` with `M` a common
multiple of the odd primes of `S`, the total QR feature is
`Σ_p (M/p)·((p-1)/2)`: the population mean of the feature is determined by the
population (here, uniform on a common period) and not by any individual `N`. -/
theorem population_feature_sum (S : Finset ℕ) (hS : ∀ p ∈ S, p.Prime ∧ p ≠ 2) (M : ℕ)
    (hM : ∀ p ∈ S, p ∣ M) :
    ∑ N ∈ range M, qrFeature S N = ∑ p ∈ S, (M / p) * (p / 2) := by
  unfold qrFeature
  simp_rw [card_filter]
  rw [sum_comm]
  apply sum_congr rfl
  intro p hp
  haveI : Fact p.Prime := ⟨(hS p hp).1⟩
  rw [← card_filter]
  have hMp : M = (M / p) * p := (Nat.div_mul_cancel (hM p hp)).symm
  conv_lhs => rw [hMp]
  rw [card_filter_range_mul_of_periodic _ (fun x => eulerPass_periodic p x),
    eulerPass_count p (hS p hp).2]

/-! ## The adopted dial and its boundary -/

/-- The odd primes `≤ 100`: the Euler tests behind `QR(≤100)`. -/
def oddPrimesLe100 : Finset ℕ := (range 101).filter fun p => p.Prime ∧ p ≠ 2

theorem oddPrimesLe100_spec : ∀ p ∈ oddPrimesLe100, p.Prime ∧ p ≠ 2 := by
  intro p hp
  exact (mem_filter.mp hp).2

theorem oddPrimesLe100_card : oddPrimesLe100.card = 24 := by decide

/-- The adopted dial `rate(q) = −0.0035 + 0.01156·q`, in exact rationals. -/
def dial (q : ℕ) : ℚ := -7 / 2000 + 289 / 25000 * q

/-- The dial predicts a positive rate iff at least one Euler test passes. -/
theorem dial_pos_iff (q : ℕ) : 0 < dial q ↔ 1 ≤ q := by
  unfold dial
  constructor
  · intro h
    by_contra hq
    push_neg at hq
    have : q = 0 := by omega
    subst this
    norm_num at h
  · intro hq
    have : (1 : ℚ) ≤ q := by exact_mod_cast hq
    linarith

/-- The dial is bounded on all `N`: at most `13697/50000 ≈ 0.27394`. -/
theorem dial_le_max (N : ℕ) : dial (qrFeature oddPrimesLe100 N) ≤ 13697 / 50000 := by
  have h : qrFeature oddPrimesLe100 N ≤ 24 := by
    rw [← oddPrimesLe100_card]; exact card_filter_le _ _
  have h' : ((qrFeature oddPrimesLe100 N : ℕ) : ℚ) ≤ 24 := by exact_mod_cast h
  unfold dial
  linarith

/-- The total root mass on the 24 odd primes `≤ 100` is affine in the dial input. -/
theorem roots_le100_affine (N : ℕ) :
    ∑ p ∈ oddPrimesLe100, qsRoots p N
      = 2 * qrFeature oddPrimesLe100 N + (oddPrimesLe100.filter (· ∣ N)).card :=
  total_roots_affine _ oddPrimesLe100_spec N

/-- **Boundary witness.** The semiprime `163520117 = 2027 · 80671` is a quadratic
non-residue modulo *every* odd prime `≤ 100` (feature `0`, root mass `0`), so the
adopted dial predicts a strictly negative rate for it. -/
theorem dial_negative_witness :
    163520117 = 2027 * 80671 ∧ Nat.Prime 2027 ∧ Nat.Prime 80671 ∧
    qrFeature oddPrimesLe100 163520117 = 0 ∧
    ∑ p ∈ oddPrimesLe100, qsRoots p 163520117 = 0 ∧
    dial (qrFeature oddPrimesLe100 163520117) < 0 := by
  have hq : qrFeature oddPrimesLe100 163520117 = 0 := by decide
  have hdiv : (oddPrimesLe100.filter (· ∣ 163520117)).card = 0 := by decide
  refine ⟨by norm_num, by norm_num, by norm_num, hq, ?_, ?_⟩
  · rw [roots_le100_affine, hq, hdiv]
  · rw [hq]; unfold dial; norm_num

end PerNPredictor