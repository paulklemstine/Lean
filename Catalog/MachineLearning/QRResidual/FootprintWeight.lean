import Mathlib
import Shared.QSRelationPoolRandom

/-!
# The QR footprint weight is *exactly* the mean sieve footprint

Context (experiment 477, paper 145; continuing paper 130 / `Shared.QSRelationPoolRandom`).

In the quadratic sieve one factors the values `v(x) = x² − N` over a factor base of
primes `p ≤ B`.  A per-`N` "yield dial" was fitted empirically, and the residual of the
naive dial was captured by the *theoretically motivated* feature

  `Σ 2/p` over the primes `p ≤ B` for which `N` is a quadratic residue mod `p`,

whose motivation is the slogan "each admissible prime `p` divides about `2/p` of the
values `x² − N`, because there are two roots".  This file turns the slogan into exact
theorems.

Main results.

* `hitCount_eq_rootCount` — the *integer window* hit count over `x ∈ [0, p)` equals the
  number of square roots of `N` in `ZMod p` (transport of the count to `ZMod p`).
* `hitCount_eq_two_of_isQR`, `hitCount_eq_zero_of_not_isQR`, `hitCount_le_two` — the
  `2 / 0` dichotomy, imported from `QSRelationPool`.
* `count_periodic`, `window_hit_count` — exact periodic counting over a long window.
* `mean_footprint_eq_sum` — **the exact identity behind the feature**: the mean, over a
  full period `M = ∏_{p∈S} p` of sieve locations, of the number of factor-base primes
  dividing `x² − N`, is exactly `Σ_{p∈S} hitCount(N,p)/p`.
* `mean_footprint_eq_qrWeight` — for `N` coprime to the factor base this mean is exactly
  the QR-weighted feature `Σ_{QR p} 2/p`.  The feature is not an approximation: it is the
  mean footprint on the nose.
-/

namespace QRResidual

open Finset

/-! ## The sieve hit count of a prime over one window -/

/-- The number of sieve locations `x` in one period `[0, p)` at which `p` divides the
quadratic-sieve value `x² − N`.  This is what a sieve implementation actually counts. -/
def hitCount (N : ℤ) (p : ℕ) : ℕ :=
  ((range p).filter (fun x : ℕ => (p : ℤ) ∣ ((x : ℤ) ^ 2 - N))).card

/-- The odd part of the quadratic-sieve factor base: the odd primes `p ≤ B`. -/
def oddFactorBase (B : ℕ) : Finset ℕ := (range (B + 1)).filter (fun p => p.Prime ∧ p ≠ 2)

/-- `N` is a quadratic residue modulo `p`, stated in the decidable "window" form used by
the sieve: some `x` in one period gives `p ∣ x² − N`. -/
def IsQR (N : ℤ) (p : ℕ) : Prop := ∃ x ∈ range p, (p : ℤ) ∣ ((x : ℤ) ^ 2 - N)

instance (N : ℤ) (p : ℕ) : Decidable (IsQR N p) := by unfold IsQR; infer_instance

/-- The raw footprint weight: the total local hit density of the odd factor base. -/
def footprintWeight (N : ℤ) (B : ℕ) : ℚ :=
  ∑ p ∈ oddFactorBase B, (hitCount N p : ℚ) / p

/-- **The feature of experiment 477**: `Σ 2/p` over the QR primes of the factor base. -/
def qrWeight (N : ℤ) (B : ℕ) : ℚ :=
  ∑ p ∈ (oddFactorBase B).filter (fun p => IsQR N p), (2 : ℚ) / p

theorem mem_oddFactorBase {B p : ℕ} : p ∈ oddFactorBase B ↔ p ≤ B ∧ p.Prime ∧ p ≠ 2 := by
  simp [oddFactorBase]

/-! ## Transport of the window count to `ZMod p` -/

/-- The window hit count is the number of square roots of `N` in `ZMod p`. -/
theorem hitCount_eq_card_sqrts (p : ℕ) [NeZero p] (N : ℤ) :
    hitCount N p = (Finset.univ.filter (fun x : ZMod p => x ^ 2 = (N : ZMod p))).card := by
  apply Finset.card_bij' (fun x _ => ((x : ℕ) : ZMod p)) (fun a _ => a.val)
  · intro a ha
    simp only [mem_filter, mem_range] at ha ⊢
    refine ⟨Finset.mem_univ _, ?_⟩
    have h2 : (((a : ℤ) ^ 2 - N : ℤ) : ZMod p) = 0 :=
      (ZMod.intCast_zmod_eq_zero_iff_dvd _ _).2 ha.2
    push_cast at h2
    linear_combination h2
  · intro a ha
    simp only [mem_filter, mem_range] at ha ⊢
    refine ⟨ZMod.val_lt a, ?_⟩
    rw [← ZMod.intCast_zmod_eq_zero_iff_dvd]
    push_cast
    simp only [ZMod.natCast_val, ZMod.cast_id]
    rw [ha.2]; ring
  · intro a ha
    simp only [mem_filter, mem_range] at ha
    exact ZMod.val_natCast_of_lt ha.1
  · intro a _
    simp [ZMod.natCast_val]

/-- The window hit count agrees with the catalog's `QSRelationPool.rootCount`. -/
theorem hitCount_eq_rootCount (p : ℕ) [Fact p.Prime] (N : ℤ) :
    hitCount N p = QSRelationPool.rootCount p (N : ZMod p) := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  rw [hitCount_eq_card_sqrts, QSRelationPool.rootCount, Set.toFinset_setOf]

/-- The decidable window form of "quadratic residue" agrees with `IsSquare` in `ZMod p`. -/
theorem isQR_iff_isSquare {p : ℕ} [NeZero p] (N : ℤ) :
    IsQR N p ↔ IsSquare ((N : ZMod p)) := by
  constructor
  · rintro ⟨x, _, hx⟩
    refine ⟨(x : ZMod p), ?_⟩
    have h2 : (((x : ℤ) ^ 2 - N : ℤ) : ZMod p) = 0 :=
      (ZMod.intCast_zmod_eq_zero_iff_dvd _ _).2 hx
    push_cast at h2
    linear_combination -h2
  · rintro ⟨r, hr⟩
    refine ⟨r.val, mem_range.2 (ZMod.val_lt r), ?_⟩
    rw [← ZMod.intCast_zmod_eq_zero_iff_dvd]
    push_cast
    simp only [ZMod.natCast_val, ZMod.cast_id]
    rw [hr]; ring

/-! ## The `2 / 0` dichotomy for the hit count -/

variable {p : ℕ} {N : ℤ}

/-- **Admissible primes hit twice.**  For an odd prime `p ∤ N` for which `N` is a QR,
exactly two of the `p` locations of a period are hit. -/
theorem hitCount_eq_two_of_isQR (hp : p.Prime) (hp2 : p ≠ 2) (hpN : ¬ (p : ℤ) ∣ N)
    (hqr : IsQR N p) : hitCount N p = 2 := by
  haveI : Fact p.Prime := ⟨hp⟩
  haveI : NeZero p := ⟨hp.ne_zero⟩
  have hne : ((N : ZMod p)) ≠ 0 := fun h => hpN ((ZMod.intCast_zmod_eq_zero_iff_dvd _ _).1 h)
  rw [hitCount_eq_rootCount]
  exact QSRelationPool.root_count_of_isSquare hp2 hne ((isQR_iff_isSquare N).1 hqr)

/-- **Inadmissible primes never hit.** -/
theorem hitCount_eq_zero_of_not_isQR (hp : p.Prime) (hp2 : p ≠ 2) (hqr : ¬ IsQR N p) :
    hitCount N p = 0 := by
  haveI : Fact p.Prime := ⟨hp⟩
  haveI : NeZero p := ⟨hp.ne_zero⟩
  rw [hitCount_eq_rootCount]
  exact QSRelationPool.root_count_of_not_isSquare hp2 (fun h => hqr ((isQR_iff_isSquare N).2 h))

/-- The ramified case `p ∣ N`: exactly one hit per period. -/
theorem hitCount_eq_one_of_dvd (hp : p.Prime) (hpN : (p : ℤ) ∣ N) : hitCount N p = 1 := by
  haveI : Fact p.Prime := ⟨hp⟩
  have h0 : ((N : ZMod p)) = 0 := (ZMod.intCast_zmod_eq_zero_iff_dvd _ _).2 hpN
  rw [hitCount_eq_rootCount, h0]
  exact QSRelationPool.root_count_zero

/-- The hit count of an odd prime is at most `2`: a quadratic has at most two roots. -/
theorem hitCount_le_two (hp : p.Prime) (hp2 : p ≠ 2) : hitCount N p ≤ 2 := by
  by_cases hpN : (p : ℤ) ∣ N
  · rw [hitCount_eq_one_of_dvd hp hpN]; norm_num
  · by_cases hqr : IsQR N p
    · rw [hitCount_eq_two_of_isQR hp hp2 hpN hqr]
    · rw [hitCount_eq_zero_of_not_isQR hp hp2 hqr]; norm_num

/-! ## Exact periodic counting over a long window -/

/-- A `p`-periodic predicate shifted by any multiple of `p`. -/
theorem shift_periodic (P : ℕ → Prop) (p : ℕ) (hper : ∀ x, P (x + p) ↔ P x) (k x : ℕ) :
    P (k * p + x) ↔ P x := by
  induction k with
  | zero => simp
  | succ m ihm =>
    have h : (m + 1) * p + x = (m * p + x) + p := by ring
    rw [h, hper, ihm]

/-- **Exact periodic counting.**  A `p`-periodic predicate is satisfied exactly
`k · (count over one period)` times in a window of length `k · p`. -/
theorem count_periodic (P : ℕ → Prop) [DecidablePred P] (p : ℕ) (hper : ∀ x, P (x + p) ↔ P x)
    (k : ℕ) : ((range (k * p)).filter P).card = k * ((range p).filter P).card := by
  induction k with
  | zero => simp
  | succ k ih =>
    have hk : (k + 1) * p = k * p + p := by ring
    rw [hk, Finset.range_add, Finset.filter_union, Finset.card_union_of_disjoint, ih,
      Finset.filter_map, Finset.card_map]
    · have hc : ((range p).filter (fun x => P (k * p + x))).card = ((range p).filter P).card := by
        congr 1
        refine Finset.filter_congr ?_
        intro x _
        simpa using shift_periodic P p hper k x
      rw [show ((range p).filter (P ∘ (addLeftEmbedding (k * p))))
            = ((range p).filter (fun x => P (k * p + x))) from rfl, hc]
      ring
    · refine Finset.disjoint_left.2 ?_
      intro a ha hb
      simp only [mem_filter, mem_range] at ha
      simp only [mem_filter, Finset.mem_map] at hb
      obtain ⟨⟨x, hx, hxa⟩, _⟩ := hb
      simp only [addLeftEmbedding, Function.Embedding.coeFn_mk] at hxa
      omega

/-- Divisibility of the sieve value by `p` is a `p`-periodic condition on the location. -/
theorem dvd_qsValue_periodic (N : ℤ) (p x : ℕ) :
    ((p : ℤ) ∣ (((x + p : ℕ) : ℤ) ^ 2 - N)) ↔ ((p : ℤ) ∣ ((x : ℤ) ^ 2 - N)) := by
  constructor <;> intro h
  · have hrw : ((x : ℤ) ^ 2 - N)
        = (((x + p : ℕ) : ℤ) ^ 2 - N) - (p : ℤ) * ((p : ℤ) + 2 * x) := by
      push_cast; ring
    rw [hrw]
    exact dvd_sub h ⟨(p : ℤ) + 2 * x, rfl⟩
  · have hrw : (((x + p : ℕ) : ℤ) ^ 2 - N)
        = ((x : ℤ) ^ 2 - N) + (p : ℤ) * ((p : ℤ) + 2 * x) := by
      push_cast; ring
    rw [hrw]
    exact dvd_add h ⟨(p : ℤ) + 2 * x, rfl⟩

/-- **Long-window hit count.**  Over a window of `k · p` consecutive locations, exactly
`k · hitCount N p` of them are divisible by `p`. -/
theorem window_hit_count (N : ℤ) (p k : ℕ) :
    ((range (k * p)).filter (fun x : ℕ => (p : ℤ) ∣ ((x : ℤ) ^ 2 - N))).card
      = k * hitCount N p :=
  count_periodic _ p (fun x => dvd_qsValue_periodic N p x) k

/-! ## The footprint weight is the mean footprint -/

/-- **Exact mean-footprint identity.**  Let `S` be a finite set of positive moduli with
product `M`.  Then the total, over a full period of `M` sieve locations, of the number of
elements of `S` dividing `x² − N`, is exactly `M · Σ_{p ∈ S} hitCount(N,p)/p`.  This is
the theoretical motivation of the footprint feature, as an identity rather than a
heuristic. -/
theorem mean_footprint_eq_sum (N : ℤ) (S : Finset ℕ) (hS : ∀ p ∈ S, 0 < p) :
    (∑ x ∈ range (∏ p ∈ S, p),
        ((S.filter (fun p : ℕ => (p : ℤ) ∣ ((x : ℤ) ^ 2 - N))).card : ℚ))
      = ((∏ p ∈ S, p : ℕ) : ℚ) * ∑ p ∈ S, (hitCount N p : ℚ) / p := by
  classical
  set M := ∏ p ∈ S, p with hM
  have hswap :
      (∑ x ∈ range M, ((S.filter (fun p : ℕ => (p : ℤ) ∣ ((x : ℤ) ^ 2 - N))).card : ℚ))
        = ∑ p ∈ S, (((range M).filter (fun x : ℕ => (p : ℤ) ∣ ((x : ℤ) ^ 2 - N))).card : ℚ) := by
    simp only [Finset.card_filter, Nat.cast_sum]
    rw [Finset.sum_comm]
  rw [hswap, Finset.mul_sum]
  refine Finset.sum_congr rfl ?_
  intro p hp
  have hp0 : 0 < p := hS p hp
  have hpne : (p : ℚ) ≠ 0 := Nat.cast_ne_zero.2 hp0.ne'
  have hMp : M = (∏ q ∈ S.erase p, q) * p := by
    rw [hM, ← Finset.mul_prod_erase S _ hp]; ring
  have hcount := window_hit_count N p (∏ q ∈ S.erase p, q)
  rw [← hMp] at hcount
  rw [hcount, hMp]
  push_cast
  field_simp

/-- **The feature is exactly the mean footprint.**  If `N` is coprime to every prime of
the odd factor base, the average number of factor-base primes dividing `x² − N`, over a
full period of sieve locations, equals the QR-weighted feature `Σ_{QR p} 2/p`. -/
theorem mean_footprint_eq_qrWeight (N : ℤ) (B : ℕ)
    (hN : ∀ p ∈ oddFactorBase B, ¬ (p : ℤ) ∣ N) :
    (∑ x ∈ range (∏ p ∈ oddFactorBase B, p),
        (((oddFactorBase B).filter (fun p : ℕ => (p : ℤ) ∣ ((x : ℤ) ^ 2 - N))).card : ℚ))
      = ((∏ p ∈ oddFactorBase B, p : ℕ) : ℚ) * qrWeight N B := by
  classical
  have hpos : ∀ p ∈ oddFactorBase B, 0 < p := by
    intro p hp
    exact (mem_oddFactorBase.1 hp).2.1.pos
  rw [mean_footprint_eq_sum N _ hpos]
  congr 1
  rw [qrWeight, ← Finset.sum_filter_add_sum_filter_not (oddFactorBase B) (fun p => IsQR N p)]
  have hzero : ∑ p ∈ (oddFactorBase B).filter (fun p => ¬ IsQR N p),
      (hitCount N p : ℚ) / p = 0 := by
    refine Finset.sum_eq_zero ?_
    intro p hp
    simp only [Finset.mem_filter] at hp
    obtain ⟨hpB, hqr⟩ := hp
    obtain ⟨-, hprime, hp2⟩ := mem_oddFactorBase.1 hpB
    rw [hitCount_eq_zero_of_not_isQR hprime hp2 hqr]
    simp
  rw [hzero, add_zero]
  refine Finset.sum_congr rfl ?_
  intro p hp
  simp only [Finset.mem_filter] at hp
  obtain ⟨hpB, hqr⟩ := hp
  obtain ⟨-, hprime, hp2⟩ := mem_oddFactorBase.1 hpB
  rw [hitCount_eq_two_of_isQR hprime hp2 (hN p hpB) hqr]
  norm_num

/-! ## Elementary structure of the dial -/

theorem qrWeight_nonneg (N : ℤ) (B : ℕ) : 0 ≤ qrWeight N B := by
  refine Finset.sum_nonneg ?_
  intro p _
  positivity

/-- The dial is bounded above by its "all-QR" value. -/
theorem qrWeight_le_full (N : ℤ) (B : ℕ) :
    qrWeight N B ≤ ∑ p ∈ oddFactorBase B, (2 : ℚ) / p := by
  refine Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _) ?_
  intro p _ _
  positivity

/-- The footprint weight of `N` equals the QR-weighted feature when `N` is coprime to the
factor base: the "raw" dial and the theoretically motivated dial coincide. -/
theorem footprintWeight_eq_qrWeight (N : ℤ) (B : ℕ)
    (hN : ∀ p ∈ oddFactorBase B, ¬ (p : ℤ) ∣ N) :
    footprintWeight N B = qrWeight N B := by
  classical
  rw [footprintWeight, qrWeight,
    ← Finset.sum_filter_add_sum_filter_not (oddFactorBase B) (fun p => IsQR N p)]
  have hzero : ∑ p ∈ (oddFactorBase B).filter (fun p => ¬ IsQR N p),
      (hitCount N p : ℚ) / p = 0 := by
    refine Finset.sum_eq_zero ?_
    intro p hp
    simp only [Finset.mem_filter] at hp
    obtain ⟨hpB, hqr⟩ := hp
    obtain ⟨-, hprime, hp2⟩ := mem_oddFactorBase.1 hpB
    rw [hitCount_eq_zero_of_not_isQR hprime hp2 hqr]
    simp
  rw [hzero, add_zero]
  refine Finset.sum_congr rfl ?_
  intro p hp
  simp only [Finset.mem_filter] at hp
  obtain ⟨hpB, hqr⟩ := hp
  obtain ⟨-, hprime, hp2⟩ := mem_oddFactorBase.1 hpB
  rw [hitCount_eq_two_of_isQR hprime hp2 (hN p hpB) hqr]
  norm_num

end QRResidual