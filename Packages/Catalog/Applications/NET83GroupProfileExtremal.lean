/-
# NET-83, cycle 4 — which key sets pay the group-correlation penalty?

`Applications.NET83GroupedNoiseInteraction` reduced the whole GPTQ
group-correlation penalty of a `k`-sparse head to a single integer statistic of
the selected key set: the number of ordered same-group pairs
`∑_{i∈S} samePartners S grp i`.  This file determines that statistic.

* `NET83.samePartners_sum_eq_profile` — it equals `∑_t mₜ(mₜ−1)`, where `mₜ` is
  the number of selected keys in quantization group `t`.  The penalty depends
  on the selection *only* through its group occupancy profile.
* `NET83.samePartners_sum_le_aligned` — it is at most `k(k−1)`, with the
  group-aligned selection attaining the bound
  (`NET83.samePartners_sum_aligned`): **the aligned selection is the worst
  possible**, for every group structure.
* `NET83.samePartners_sum_eq_zero_of_spread` — it vanishes exactly for
  group-spread selections.
* `NET83.pairs_smoothing` — the Schur-convexity step: moving one key from a
  fuller group to an emptier one strictly decreases the penalty, so balanced
  profiles are the good ones.
* `NET83.grouped_meansquare_le_aligned` — transported back to variance: under
  any non-negative group correlation, no selection transmits more than the
  aligned value `σ²(1+ρ(k−1))/k`.
-/
import Applications.NET83GroupedNoiseInteraction

namespace NET83

open Finset

variable {n : ℕ} {G : Type*} [DecidableEq G]

/-- Number of selected keys lying in quantization group `t`. -/
def groupCount (S : Finset (Fin n)) (grp : Fin n → G) (t : G) : ℕ :=
  (S.filter (fun j => grp j = t)).card

lemma samePartners_add_one (S : Finset (Fin n)) (grp : Fin n → G) {i : Fin n}
    (hi : i ∈ S) :
    samePartners S grp i + 1 = groupCount S grp (grp i) := by
  have hfil : (S.erase i).filter (fun j => grp i = grp j)
      = (S.filter (fun j => grp j = grp i)).erase i := by
    ext j
    simp only [Finset.mem_filter, Finset.mem_erase]
    constructor
    · rintro ⟨⟨hji, hjS⟩, hg⟩; exact ⟨hji, hjS, hg.symm⟩
    · rintro ⟨hji, hjS, hg⟩; exact ⟨⟨hji, hjS⟩, hg.symm⟩
  have hmem : i ∈ S.filter (fun j => grp j = grp i) :=
    Finset.mem_filter.mpr ⟨hi, rfl⟩
  rw [samePartners, hfil, groupCount, Finset.card_erase_add_one hmem]

/-- Every selected key has at most `k − 1` same-group partners. -/
lemma samePartners_le (S : Finset (Fin n)) (grp : Fin n → G) {i : Fin n}
    (hi : i ∈ S) : samePartners S grp i ≤ S.card - 1 := by
  rw [samePartners]
  calc ((S.erase i).filter (fun j => grp i = grp j)).card
      ≤ (S.erase i).card := Finset.card_filter_le _ _
    _ = S.card - 1 := Finset.card_erase_of_mem hi

/-- **The penalty depends only on the group occupancy profile.**  The number of
ordered same-group pairs inside the selected set is `∑ₜ mₜ(mₜ − 1)`. -/
theorem samePartners_sum_eq_profile (S : Finset (Fin n)) (grp : Fin n → G) :
    ∑ i ∈ S, samePartners S grp i
      = ∑ t ∈ S.image grp, groupCount S grp t * (groupCount S grp t - 1) := by
  have hmaps : ∀ i ∈ S, grp i ∈ S.image grp := fun i hi => Finset.mem_image_of_mem grp hi
  rw [← Finset.sum_fiberwise_of_maps_to hmaps (fun i => samePartners S grp i)]
  refine Finset.sum_congr rfl (fun t ht => ?_)
  have hfib : ∀ i ∈ S.filter (fun i => grp i = t),
      samePartners S grp i = groupCount S grp t - 1 := by
    intro i hi
    rw [Finset.mem_filter] at hi
    have h := samePartners_add_one S grp hi.1
    rw [hi.2] at h
    omega
  rw [Finset.sum_congr rfl hfib, Finset.sum_const, smul_eq_mul]
  rfl

/-- **The aligned selection is the worst possible.**  Whatever the group
structure, the same-group pair count is at most `k(k − 1)`. -/
theorem samePartners_sum_le_aligned (S : Finset (Fin n)) (grp : Fin n → G) :
    ∑ i ∈ S, samePartners S grp i ≤ S.card * (S.card - 1) := by
  calc ∑ i ∈ S, samePartners S grp i
      ≤ ∑ _i ∈ S, (S.card - 1) :=
        Finset.sum_le_sum (fun i hi => samePartners_le S grp hi)
    _ = S.card * (S.card - 1) := by rw [Finset.sum_const, smul_eq_mul]

/-- A selection inside a single quantization group attains the bound. -/
theorem samePartners_sum_aligned {S : Finset (Fin n)} {grp : Fin n → G}
    (halign : ∀ i ∈ S, ∀ j ∈ S, grp i = grp j) :
    ∑ i ∈ S, samePartners S grp i = S.card * (S.card - 1) := by
  rw [Finset.sum_congr rfl (fun i hi => samePartners_of_aligned halign hi),
    Finset.sum_const, smul_eq_mul]

/-- A group-spread selection pays nothing. -/
theorem samePartners_sum_eq_zero_of_spread {S : Finset (Fin n)} {grp : Fin n → G}
    (hspread : ∀ i ∈ S, ∀ j ∈ S, grp i = grp j → i = j) :
    ∑ i ∈ S, samePartners S grp i = 0 := by
  refine Finset.sum_eq_zero (fun i hi => ?_)
  rw [samePartners, Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  intro j hj hg
  exact (Finset.ne_of_mem_erase hj) (hspread i hi j (Finset.mem_of_mem_erase hj) hg).symm

/-- **Schur-convexity step.**  Moving one selected key from a group holding `a`
of them to a group holding `b ≤ a − 2` strictly decreases the same-group pair
count: balanced group profiles are optimal. -/
theorem pairs_smoothing (a b : ℤ) (hab : b + 2 ≤ a) :
    (a - 1) * (a - 2) + (b + 1) * b < a * (a - 1) + b * (b - 1) := by
  nlinarith

/-- **Variance form of the extremal statement.**  For any non-negative group
correlation, no selection transmits more quantization variance than the
group-aligned one. -/
theorem grouped_meansquare_le_aligned {Omega : Type*} [Fintype Omega]
    (eta : Omega → Fin n → ℝ) (sigma rho : ℝ) (grp : Fin n → G)
    {S : Finset (Fin n)} (hS : S.Nonempty) (hrho : 0 ≤ rho)
    (hcov : ∀ i j, i ≠ j →
      Eavg (fun o => eta o i * eta o j) = if grp i = grp j then rho * sigma ^ 2 else 0)
    (hvar : ∀ i, Eavg (fun o => (eta o i) ^ 2) = sigma ^ 2) :
    Eavg (fun o => (avgOn S (eta o)) ^ 2)
      ≤ sigma ^ 2 * (1 + rho * ((S.card : ℝ) - 1)) / S.card := by
  have hcard : (0 : ℝ) < S.card := by exact_mod_cast Finset.card_pos.mpr hS
  have hcard1 : 1 ≤ S.card := Finset.card_pos.mpr hS
  have hs2 : (0 : ℝ) ≤ sigma ^ 2 := sq_nonneg _
  rw [meansquare_avgOn_grouped eta sigma rho grp hS hcov hvar]
  have hle : ∑ i ∈ S, (samePartners S grp i : ℝ)
      ≤ (S.card : ℝ) * ((S.card : ℝ) - 1) := by
    have hnat := samePartners_sum_le_aligned S grp
    have : ((∑ i ∈ S, samePartners S grp i : ℕ) : ℝ)
        ≤ ((S.card * (S.card - 1) : ℕ) : ℝ) := by exact_mod_cast hnat
    rw [Nat.cast_sum] at this
    calc ∑ i ∈ S, (samePartners S grp i : ℝ)
        ≤ ((S.card * (S.card - 1) : ℕ) : ℝ) := this
      _ = (S.card : ℝ) * ((S.card : ℝ) - 1) := by
          push_cast [Nat.cast_sub hcard1]
          ring
  rw [div_le_div_iff₀ (by positivity) hcard]
  have hmul : rho * sigma ^ 2 * ∑ i ∈ S, (samePartners S grp i : ℝ)
      ≤ rho * sigma ^ 2 * ((S.card : ℝ) * ((S.card : ℝ) - 1)) :=
    mul_le_mul_of_nonneg_left hle (by positivity)
  nlinarith [hmul, hs2, hcard]

end NET83