import MachineLearning.QRResidual.MeanDial

/-!
# The exact information capacity of the dial: `|base|` bits, not fewer

`Blindness` proved two halves of a capacity statement: the dial takes **at most**
`2^{|base|}` values (`qrWeight_information_bound`), and **every** subset sum `Σ_{p∈T} 2/p`
is attained (`qrWeight_full_range`).  What was missing is that distinct QR patterns give
*distinct* dial values — without it the dial could collapse many patterns onto one number.

This file supplies the missing injectivity by an elementary primorial argument: after
multiplying by the primorial `D = ∏_{p ≤ B} p`, the subset sum becomes the natural number
`Σ_{p∈T} 2·(D/p)`, whose divisibility by a factor-base prime `p` detects exactly whether
`p ∈ T`.  Consequently the dial's range has **exactly** `2^{|base|}` elements: it carries
exactly `|base|` bits about `N` — no more (the bound) and no fewer (this file).

Main results.

* `subsetSum_mul_primorial` — the subset sum, scaled by the primorial, is a natural number.
* `dvd_subsetSumNat_iff` — a factor-base prime divides that number iff it is *not* in `T`.
* `subsetSum_injective` — distinct subsets of the factor base give distinct subset sums.
* `qrWeight_range_ncard` — **exact capacity**: the dial's range has `2^{|base|}` values.
* `qrWeight_injective_on_patterns` — two moduli share a dial value iff they share their
  whole QR pattern: the dial loses no information about the pattern.
-/

namespace QRResidual

open Finset

/-- The primorial-scaled subset sum, as a natural number. -/
def subsetSumNat (B : ℕ) (T : Finset ℕ) : ℕ := ∑ p ∈ T, 2 * (basePrimorial B / p)

/-- `D / p` is the product of the factor base with `p` removed. -/
theorem primorial_div {B p : ℕ} (hp : p ∈ oddFactorBase B) :
    basePrimorial B / p = ∏ q ∈ (oddFactorBase B).erase p, q := by
  have hprime : p.Prime := (mem_oddFactorBase.1 hp).2.1
  have h := basePrimorial_eq_mul hp
  exact Nat.div_eq_of_eq_mul_left hprime.pos h

/-- Scaling the subset sum by the primorial turns it into the natural number
`Σ_{p ∈ T} 2·(D/p)`. -/
theorem subsetSum_mul_primorial {B : ℕ} {T : Finset ℕ} (hT : T ⊆ oddFactorBase B) :
    (∑ p ∈ T, (2 : ℚ) / p) * (basePrimorial B : ℚ) = (subsetSumNat B T : ℚ) := by
  classical
  rw [Finset.sum_mul, subsetSumNat]
  push_cast
  refine Finset.sum_congr rfl ?_
  intro p hp
  have hpB := hT hp
  have hprime : p.Prime := (mem_oddFactorBase.1 hpB).2.1
  have hppos : (0 : ℚ) < p := by exact_mod_cast hprime.pos
  have hdvd : p ∣ basePrimorial B := by
    rw [basePrimorial]
    exact Finset.dvd_prod_of_mem _ hpB
  have hcast : ((basePrimorial B / p : ℕ) : ℚ) = (basePrimorial B : ℚ) / (p : ℚ) :=
    Nat.cast_div hdvd (ne_of_gt hppos)
  rw [hcast]
  field_simp

/-- A factor-base prime `p` never divides `2·(D/p)`. -/
theorem not_dvd_two_mul_primorial_div {B p : ℕ} (hp : p ∈ oddFactorBase B) :
    ¬ p ∣ 2 * (basePrimorial B / p) := by
  classical
  obtain ⟨-, hprime, hp2⟩ := mem_oddFactorBase.1 hp
  intro h
  rcases (Nat.Prime.dvd_mul hprime).1 h with h2 | hq
  · have hle : p ≤ 2 := Nat.le_of_dvd (by norm_num) h2
    have hge : 2 ≤ p := hprime.two_le
    exact hp2 (by omega)
  · rw [primorial_div hp] at hq
    obtain ⟨q, hqmem, hqdvd⟩ := (Nat.Prime.prime hprime).exists_mem_finset_dvd hq
    have hqprime : q.Prime := (mem_oddFactorBase.1 (Finset.mem_of_mem_erase hqmem)).2.1
    have : p = q := ((Nat.prime_dvd_prime_iff_eq hprime hqprime).1 hqdvd)
    exact (Finset.ne_of_mem_erase hqmem) this.symm

/-- `p` divides the scaled subset sum exactly when `p ∉ T`: the arithmetic of the primorial
reads the QR pattern back off the dial value. -/
theorem dvd_subsetSumNat_iff {B p : ℕ} {T : Finset ℕ} (hT : T ⊆ oddFactorBase B)
    (hp : p ∈ oddFactorBase B) :
    p ∣ subsetSumNat B T ↔ p ∉ T := by
  classical
  have hother : ∀ q ∈ T, q ≠ p → p ∣ 2 * (basePrimorial B / q) := by
    intro q hq hqp
    have hqB := hT hq
    refine Dvd.dvd.mul_left ?_ 2
    rw [primorial_div hqB]
    exact Finset.dvd_prod_of_mem _ (Finset.mem_erase.2 ⟨Ne.symm hqp, hp⟩)
  constructor
  · intro hdvd hpT
    -- split off the `p`-term
    have hsplit : subsetSumNat B T
        = 2 * (basePrimorial B / p) + ∑ q ∈ T.erase p, 2 * (basePrimorial B / q) := by
      rw [subsetSumNat, ← Finset.add_sum_erase _ _ hpT]
    have hrest : p ∣ ∑ q ∈ T.erase p, 2 * (basePrimorial B / q) := by
      refine Finset.dvd_sum ?_
      intro q hq
      exact hother q (Finset.mem_of_mem_erase hq) (Finset.ne_of_mem_erase hq)
    rw [hsplit] at hdvd
    exact not_dvd_two_mul_primorial_div hp ((Nat.dvd_add_iff_left hrest).2 hdvd)
  · intro hpT
    refine Finset.dvd_sum ?_
    intro q hq
    exact hother q hq (fun h => hpT (h ▸ hq))

/-- **Distinct QR patterns give distinct dial values.** -/
theorem subsetSum_injective {B : ℕ} {T S : Finset ℕ} (hT : T ⊆ oddFactorBase B)
    (hS : S ⊆ oddFactorBase B)
    (h : ∑ p ∈ T, (2 : ℚ) / p = ∑ p ∈ S, (2 : ℚ) / p) : T = S := by
  classical
  have hDpos : 0 < basePrimorial B := basePrimorial_pos B
  have hDQ : (basePrimorial B : ℚ) ≠ 0 := by
    have : (0 : ℚ) < basePrimorial B := by exact_mod_cast hDpos
    exact ne_of_gt this
  have hnat : (subsetSumNat B T : ℚ) = (subsetSumNat B S : ℚ) := by
    rw [← subsetSum_mul_primorial hT, ← subsetSum_mul_primorial hS, h]
  have heq : subsetSumNat B T = subsetSumNat B S := by exact_mod_cast hnat
  ext p
  by_cases hpB : p ∈ oddFactorBase B
  · have h1 := dvd_subsetSumNat_iff hT hpB
    have h2 := dvd_subsetSumNat_iff hS hpB
    rw [heq] at h1
    constructor
    · intro hpT
      by_contra hpS
      exact (h1.1 (h2.2 hpS)) hpT
    · intro hpS
      by_contra hpT
      exact (h2.1 (h1.2 hpT)) hpS
  · constructor
    · intro hpT; exact absurd (hT hpT) hpB
    · intro hpS; exact absurd (hS hpS) hpB

/-! ## Exact capacity of the dial -/

/-- **Exact information capacity.**  The dial takes exactly `2^{|base|}` distinct values:
the upper bound of `qrWeight_information_bound` is attained, so the feature carries exactly
`|base|` bits about `N` — one bit per factor-base prime. -/
theorem qrWeight_range_ncard (B : ℕ) :
    (Set.range (fun N : ℤ => qrWeight N B)).ncard = 2 ^ (oddFactorBase B).card := by
  classical
  set img : Finset ℚ :=
    (oddFactorBase B).powerset.image (fun T : Finset ℕ => ∑ p ∈ T, (2 : ℚ) / (p : ℚ)) with himg
  have hset : Set.range (fun N : ℤ => qrWeight N B) = (img : Set ℚ) := by
    ext v
    constructor
    · rintro ⟨N, rfl⟩
      have hmem : ((oddFactorBase B).filter (fun p => IsQR N p)) ∈ (oddFactorBase B).powerset :=
        Finset.mem_powerset.2 (Finset.filter_subset _ _)
      exact Finset.mem_coe.2 (Finset.mem_image.2 ⟨_, hmem, rfl⟩)
    · intro hv
      obtain ⟨T, hT, rfl⟩ := Finset.mem_image.1 (Finset.mem_coe.1 hv)
      obtain ⟨N, hN⟩ := qrWeight_full_range B T (Finset.mem_powerset.1 hT)
      exact ⟨N, hN⟩
  have hinj : Set.InjOn (fun T : Finset ℕ => ∑ p ∈ T, (2 : ℚ) / (p : ℚ))
      ((oddFactorBase B).powerset : Set (Finset ℕ)) := by
    intro T hT S hS h
    exact subsetSum_injective (Finset.mem_powerset.1 (Finset.mem_coe.1 hT))
      (Finset.mem_powerset.1 (Finset.mem_coe.1 hS)) h
  rw [hset, Set.ncard_coe_finset, himg, Finset.card_image_of_injOn hinj,
    Finset.card_powerset]

/-- **The dial determines the pattern.**  Two moduli receive the same dial value exactly
when they have the same set of QR primes in the factor base: nothing about the pattern is
lost by summing the weights. -/
theorem qrWeight_injective_on_patterns (B : ℕ) (N₁ N₂ : ℤ) :
    qrWeight N₁ B = qrWeight N₂ B ↔
      (oddFactorBase B).filter (fun p => IsQR N₁ p)
        = (oddFactorBase B).filter (fun p => IsQR N₂ p) := by
  classical
  constructor
  · intro h
    exact subsetSum_injective (Finset.filter_subset _ _) (Finset.filter_subset _ _) h
  · intro h
    rw [qrWeight, qrWeight, h]

section LabNotes

/-! For `B = 20` the factor base is `{3, 5, 7, 11, 13, 17, 19}` and the dial therefore takes
exactly `2^7 = 128` distinct values.  The two sample moduli below have different QR
patterns, hence different dial values, in accordance with
`qrWeight_injective_on_patterns`. -/

example : (oddFactorBase 20).card = 7 := by decide

example : (2 : ℕ) ^ (oddFactorBase 20).card = 128 := by decide

example : qrWeight 1649 20 ≠ qrWeight 1 20 := by
  intro hcon
  have hpat := (qrWeight_injective_on_patterns 20 1649 1).1 hcon
  have h1 : (oddFactorBase 20).filter (fun p => IsQR (1649 : ℤ) p) = {5, 7, 17} := by decide
  have h2 : (oddFactorBase 20).filter (fun p => IsQR (1 : ℤ) p) = {3, 5, 7, 11, 13, 17, 19} := by
    decide
  rw [h1, h2] at hpat
  exact absurd hpat (by decide)

end LabNotes

end QRResidual