import Mathlib
import Bridges.QRLottoDial
import Bridges.QRLottoDialIndependence

/-!
# Position side: the dial is the expected number of factor-base hits per sieve position

`Bridges.QRLottoDial` and `Bridges.QRLottoDialIndependence` randomise over the *target*
`N`.  A sieve, however, randomises over *positions* `x`: it asks how many factor-base
primes divide `x² − N`.  This file computes the first two moments of that counter exactly,
over the CRT product of position spaces `∏ ZMod (q i)`.

## Main results

* `QRLotto.sum_hitCount` — **the dial is the position-side mean**: averaged over the
  positions of a full period, the number of factor-base primes hitting a position is
  exactly `∑ #roots(p,N)/p`, i.e. the zero-fit dial `∑_{QR} 2/p`
  (`QRLotto.mean_hitCount_eq_theoryDial`).
* `QRLotto.sum_sq_hitCount` — **the position-side variance**: it is exactly
  `∑ (r_p/p)(1 − r_p/p)` with `r_p = #roots(p,N)`, i.e. `∑_{QR} (2/p)(1 − 2/p)`
  (`QRLotto.variance_hitCount_eq`).  The counter is a sum of independent Bernoulli
  indicators with the theory-forced parameters, so again nothing is fitted.
-/

open Finset

namespace QRLotto

/-! ## Positions modulo a single prime -/

/-- All residue classes mod `p`, as a `Finset (ZMod p)` built without a `Fintype`
instance obligation. -/
def allZ (p : ℕ) : Finset (ZMod p) := (Finset.range p).image (fun n : ℕ => (n : ZMod p))

/-- The classes of the sieve positions hit by `p`: the roots of `x² ≡ N (mod p)`. -/
def rootZ (p : ℕ) (N : ℤ) : Finset (ZMod p) :=
  (rootSet p N).image (fun n : ℕ => (n : ZMod p))

lemma card_allZ (p : ℕ) [NeZero p] : (allZ p).card = p := by
  rw [allZ, Finset.card_image_of_injOn (cast_injOn p _ (subset_refl _)), Finset.card_range]

lemma card_rootZ (p : ℕ) [NeZero p] (N : ℤ) : (rootZ p N).card = rootCount p N :=
  Finset.card_image_of_injOn (cast_injOn p _ (Finset.filter_subset _ _))

lemma rootZ_subset_allZ (p : ℕ) (N : ℤ) : rootZ p N ⊆ allZ p :=
  Finset.image_subset_image (Finset.filter_subset _ _)

/-- The centred position indicator at `p`. -/
noncomputable def posCoin (p : ℕ) (N : ℤ) (y : ZMod p) : ℝ :=
  (if y ∈ rootZ p N then (1 : ℝ) else 0) - (rootCount p N : ℝ) / p

lemma sum_indicator_allZ (p : ℕ) [NeZero p] (N : ℤ) :
    ∑ y ∈ allZ p, (if y ∈ rootZ p N then (1 : ℝ) else 0) = (rootCount p N : ℝ) := by
  classical
  rw [← Finset.sum_filter, Finset.filter_mem_eq_inter,
    Finset.inter_eq_right.2 (rootZ_subset_allZ p N), Finset.sum_const, nsmul_eq_mul,
    card_rootZ p N, mul_one]

/-- The centred position indicator has mean zero. -/
lemma sum_posCoin (p : ℕ) [NeZero p] (N : ℤ) : ∑ y ∈ allZ p, posCoin p N y = 0 := by
  have hp : (p : ℝ) ≠ 0 := Nat.cast_ne_zero.2 (NeZero.ne p)
  simp only [posCoin]
  rw [Finset.sum_sub_distrib, sum_indicator_allZ p N, Finset.sum_const, nsmul_eq_mul,
    card_allZ p]
  field_simp
  ring

/-- The exact second moment of the centred position indicator: a Bernoulli variance with
the theory-forced parameter `r/p`. -/
lemma sum_posCoin_sq (p : ℕ) [NeZero p] (N : ℤ) :
    ∑ y ∈ allZ p, (posCoin p N y) ^ 2
      = (p : ℝ) * (((rootCount p N : ℝ) / p) * (1 - (rootCount p N : ℝ) / p)) := by
  classical
  have hp : (p : ℝ) ≠ 0 := Nat.cast_ne_zero.2 (NeZero.ne p)
  set c : ℝ := (rootCount p N : ℝ) / p with hc
  have hsplit : ∑ y ∈ allZ p, (posCoin p N y) ^ 2
      = ∑ y ∈ allZ p \ rootZ p N, (posCoin p N y) ^ 2
        + ∑ y ∈ rootZ p N, (posCoin p N y) ^ 2 :=
    (Finset.sum_sdiff (rootZ_subset_allZ p N)).symm
  have hin : ∑ y ∈ rootZ p N, (posCoin p N y) ^ 2
      = (rootCount p N : ℝ) * (1 - c) ^ 2 := by
    rw [Finset.sum_congr rfl (fun y hy => by rw [posCoin, if_pos hy, ← hc]),
      Finset.sum_const, nsmul_eq_mul, card_rootZ p N]
  have hout : ∑ y ∈ allZ p \ rootZ p N, (posCoin p N y) ^ 2
      = ((p : ℝ) - (rootCount p N : ℝ)) * c ^ 2 := by
    have hle : rootCount p N ≤ p := by
      have hsub := Finset.card_le_card (rootZ_subset_allZ p N)
      rwa [card_rootZ p N, card_allZ p] at hsub
    have hcard : ((allZ p \ rootZ p N).card : ℝ) = (p : ℝ) - (rootCount p N : ℝ) := by
      have h := Finset.card_sdiff_add_card_eq_card (rootZ_subset_allZ p N)
      rw [card_allZ p, card_rootZ p N] at h
      have : (allZ p \ rootZ p N).card = p - rootCount p N := by omega
      rw [this]
      push_cast [hle]
      ring
    rw [Finset.sum_congr rfl (fun y hy => by
        rw [posCoin, if_neg (Finset.mem_sdiff.1 hy).2, ← hc, zero_sub, neg_sq]),
      Finset.sum_const, nsmul_eq_mul, hcard]
  rw [hsplit, hin, hout, hc]
  field_simp
  ring

/-! ## The position-side moments of the footprint counter -/

variable {k : ℕ}

/-- The number of factor-base primes hitting the sieve position `x`. -/
noncomputable def hitCount (q : Fin k → ℕ) (N : ℤ) (x : ∀ i, ZMod (q i)) : ℝ :=
  ∑ i, (if x i ∈ rootZ (q i) N then (1 : ℝ) else 0)

/-- The position space: one residue per factor-base prime, i.e. a full sieve period. -/
def positionSpace (q : Fin k → ℕ) : Finset (∀ i, ZMod (q i)) :=
  Fintype.piFinset (fun i => allZ (q i))

lemma card_positionSpace_erase (q : Fin k → ℕ) (i : Fin k) :
    (#(Fintype.piFinset (fun j => allZ (q j))) : ℝ)
      = (#(allZ (q i)) : ℝ) * ∏ j ∈ univ.erase i, (#(allZ (q j)) : ℝ) := by
  rw [Fintype.card_piFinset, Nat.cast_prod, ← Finset.mul_prod_erase univ _ (mem_univ i)]

/-- **The dial is the position-side mean.**  Over a full sieve period the average number
of factor-base primes hitting a position is exactly `∑ #roots(p,N)/p`. -/
theorem sum_hitCount (q : Fin k → ℕ) (hq : ∀ i, 0 < q i) (N : ℤ) :
    ∑ x ∈ positionSpace q, hitCount q N x
      = (#(positionSpace q) : ℝ) * ∑ i, (rootCount (q i) N : ℝ) / (q i : ℝ) := by
  classical
  simp only [positionSpace]
  rw [Finset.mul_sum]
  rw [show (∑ x ∈ Fintype.piFinset (fun j => allZ (q j)), hitCount q N x)
      = ∑ i : Fin k, ∑ x ∈ Fintype.piFinset (fun j => allZ (q j)),
          (if x i ∈ rootZ (q i) N then (1 : ℝ) else 0) from
    Finset.sum_comm]
  refine Finset.sum_congr rfl (fun i _ => ?_)
  haveI : NeZero (q i) := ⟨(hq i).ne'⟩
  have hqi : ((q i : ℝ)) ≠ 0 := Nat.cast_ne_zero.2 (hq i).ne'
  rw [sum_piFinset_single (fun j => allZ (q j)) i
    (fun y => if y ∈ rootZ (q i) N then (1 : ℝ) else 0), sum_indicator_allZ (q i) N,
    card_positionSpace_erase q i, card_allZ (q i)]
  field_simp

/-- **The position-side variance.**  The hit counter is a sum of independent Bernoulli
indicators with parameters `#roots(p,N)/p`, so its variance is
`∑ (r_p/p)(1 − r_p/p)` exactly. -/
theorem sum_sq_hitCount (q : Fin k → ℕ) (hq : ∀ i, 0 < q i) (N : ℤ) :
    ∑ x ∈ positionSpace q,
        (hitCount q N x - ∑ i, (rootCount (q i) N : ℝ) / (q i : ℝ)) ^ 2
      = (#(positionSpace q) : ℝ)
        * ∑ i, ((rootCount (q i) N : ℝ) / (q i : ℝ))
            * (1 - (rootCount (q i) N : ℝ) / (q i : ℝ)) := by
  classical
  simp only [positionSpace]
  have hcentre : ∀ x : ∀ i, ZMod (q i),
      hitCount q N x - ∑ i, (rootCount (q i) N : ℝ) / (q i : ℝ)
        = ∑ i, posCoin (q i) N (x i) := by
    intro x
    rw [hitCount, ← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl (fun i _ => rfl)
  have hsq : ∀ x : ∀ i, ZMod (q i),
      (hitCount q N x - ∑ i, (rootCount (q i) N : ℝ) / (q i : ℝ)) ^ 2
        = ∑ i : Fin k, ∑ j : Fin k, posCoin (q i) N (x i) * posCoin (q j) N (x j) := by
    intro x
    rw [hcentre x, sq, Finset.sum_mul_sum]
  rw [Finset.sum_congr rfl (fun x _ => hsq x), Finset.sum_comm]
  rw [show (∑ i : Fin k, ∑ x ∈ Fintype.piFinset (fun j => allZ (q j)), ∑ j : Fin k,
        posCoin (q i) N (x i) * posCoin (q j) N (x j))
      = ∑ i : Fin k, ∑ j : Fin k, ∑ x ∈ Fintype.piFinset (fun l => allZ (q l)),
        posCoin (q i) N (x i) * posCoin (q j) N (x j) from
    Finset.sum_congr rfl (fun i _ => Finset.sum_comm)]
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl (fun i _ => ?_)
  haveI : NeZero (q i) := ⟨(hq i).ne'⟩
  have hqi : ((q i : ℝ)) ≠ 0 := Nat.cast_ne_zero.2 (hq i).ne'
  rw [Finset.sum_eq_single i]
  · -- diagonal: the Bernoulli variance at the prime `q i`
    have hdiag : ∑ x ∈ Fintype.piFinset (fun l => allZ (q l)),
          posCoin (q i) N (x i) * posCoin (q i) N (x i)
        = ∑ x ∈ Fintype.piFinset (fun l => allZ (q l)),
            (fun y => (posCoin (q i) N y) ^ 2) (x i) :=
      Finset.sum_congr rfl (fun x _ => (pow_two _).symm)
    rw [hdiag, sum_piFinset_single (fun l => allZ (q l)) i
      (fun y => (posCoin (q i) N y) ^ 2), sum_posCoin_sq (q i) N,
      card_positionSpace_erase q i, card_allZ (q i)]
    ring
  · -- off-diagonal: distinct positions decouple and the coins are centred
    intro j _ hji
    haveI : NeZero (q j) := ⟨(hq j).ne'⟩
    rw [sum_piFinset_pair (fun l => allZ (q l)) i j (Ne.symm hji)
      (fun y => posCoin (q i) N y) (fun z => posCoin (q j) N z), sum_posCoin (q i) N]
    ring
  · intro h
    exact absurd (mem_univ i) h

/-- **The position-side mean is the zero-fit dial.**  For a factor base of distinct odd
primes coprime to `N`, the average number of primes hitting a sieve position is exactly
`T(N) = ∑_{QR} 2/p`. -/
theorem mean_hitCount_eq_theoryDial (q : Fin k → ℕ) (hq : ∀ i, (q i).Prime)
    (h2 : ∀ i, q i ≠ 2) (hinj : Function.Injective q) {N : ℤ}
    (hN : ∀ i, ¬ (q i : ℤ) ∣ N) :
    ∑ x ∈ positionSpace q, hitCount q N x
      = (#(positionSpace q) : ℝ) * theoryDial (univ.image q) N := by
  classical
  rw [sum_hitCount q (fun i => (hq i).pos) N]
  congr 1
  rw [theoryDial, Finset.sum_filter, Finset.sum_image (fun i _ j _ h => hinj h)]
  refine Finset.sum_congr rfl (fun i _ => ?_)
  haveI : Fact (q i).Prime := ⟨hq i⟩
  by_cases hb : qrBit (q i) N = true
  · have hsq : IsSquare ((N : ZMod (q i))) := (qrBit_iff (q i) (h2 i) N).1 hb
    rw [if_pos hb, rootCount_eq_two (q i) (h2 i) (hN i) hsq]
    norm_num
  · have hsq : ¬ IsSquare ((N : ZMod (q i))) := fun hc =>
      hb ((qrBit_iff (q i) (h2 i) N).2 hc)
    rw [if_neg hb, rootCount_eq_zero (q i) (h2 i) hsq]
    norm_num

/-- The position-side variance in dial form: `∑_{QR} (2/p)(1 − 2/p)`. -/
theorem variance_hitCount_eq (q : Fin k → ℕ) (hq : ∀ i, (q i).Prime) (h2 : ∀ i, q i ≠ 2)
    {N : ℤ} (hN : ∀ i, ¬ (q i : ℤ) ∣ N) :
    ∑ x ∈ positionSpace q,
        (hitCount q N x - ∑ i, (rootCount (q i) N : ℝ) / (q i : ℝ)) ^ 2
      = (#(positionSpace q) : ℝ)
        * ∑ i, (if qrBit (q i) N then (2 : ℝ) / (q i : ℝ) else 0)
            * (1 - (if qrBit (q i) N then (2 : ℝ) / (q i : ℝ) else 0)) := by
  rw [sum_sq_hitCount q (fun i => (hq i).pos) N]
  congr 1
  refine Finset.sum_congr rfl (fun i _ => ?_)
  haveI : Fact (q i).Prime := ⟨hq i⟩
  have hd : ((rootCount (q i) N : ℝ)) / (q i : ℝ)
      = if qrBit (q i) N then (2 : ℝ) / (q i : ℝ) else 0 := by
    have := hitDensity_eq_ite (q i) (h2 i) (hN i)
    rwa [hitDensity] at this
  rw [hd]

end QRLotto