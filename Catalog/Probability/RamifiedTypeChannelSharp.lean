import Mathlib
import Probability.RamifiedTypeChannelNegligible

/-!
# Sharpness of the ramified-negligibility rate (FACT round-36 #1, paper 128)

`ramified_contribution_negligible` bounds the effect of `r` ramified primes in a sample of
`N` primes by `(r / N) (3 log₂ N + 2 / log 2)`.  Here we show that the `log₂ N` factor cannot
be removed: there is a configuration (all unramified primes share one splitting type, every
ramified prime has its own type) in which the change is at least `(r / N) log₂ N`.
-/

namespace Catalog.Probability.RamifiedTypeChannel

open Finset CyclicTypeChannel Catalog.Probability.D5TypeChannelCore

/-- The extremal type read-out: unramified primes (indices `< u`) have the common type `0`,
the ramified ones (indices `≥ u`) have pairwise distinct non-zero types. -/
def extremalType (u : ℕ) (x : ℕ) : ℕ := if x < u then 0 else x + 1

lemma lam_extremal_unram (u : ℕ) :
    lam (range u) (extremalType u) = u * Real.logb 2 u := by
  have hf : ∀ a ∈ range u, {x ∈ range u | extremalType u x = extremalType u a} = range u := by
    intro a ha
    refine Finset.filter_true_of_mem fun x hx => ?_
    simp only [mem_range] at ha hx
    simp [extremalType, ha, hx]
  rw [lam, Finset.sum_congr rfl fun a ha => by rw [hf a ha], sum_const, card_range, nsmul_eq_mul]

lemma lam_extremal_all (u n : ℕ) :
    lam (range u ∪ Ico u n) (extremalType u) = u * Real.logb 2 u := by
  have hdisj : Disjoint (range u) (Ico u n) := by
    rw [range_eq_Ico]; exact Ico_disjoint_Ico_consecutive 0 u n
  have hU : ∀ a ∈ range u,
      {x ∈ range u ∪ Ico u n | extremalType u x = extremalType u a} = range u := by
    intro a ha
    simp only [mem_range] at ha
    ext x
    simp only [mem_filter, mem_union, mem_range, mem_Ico, extremalType, ha, if_true]
    constructor
    · rintro ⟨hx, hx0⟩
      by_contra hxu
      rw [if_neg hxu] at hx0
      omega
    · intro hx; exact ⟨Or.inl hx, by simp [hx]⟩
  have hR : ∀ a ∈ Ico u n,
      {x ∈ range u ∪ Ico u n | extremalType u x = extremalType u a} = {a} := by
    intro a ha
    simp only [mem_Ico] at ha
    have hau : ¬ a < u := by omega
    ext x
    simp only [mem_filter, mem_union, mem_range, mem_Ico, extremalType, hau, if_false,
      mem_singleton]
    constructor
    · rintro ⟨_, hx⟩
      by_cases hxu : x < u
      · rw [if_pos hxu] at hx; omega
      · rw [if_neg hxu] at hx; omega
    · rintro rfl; exact ⟨Or.inr ⟨by omega, ha.2⟩, by simp [hau]⟩
  have e1 : ∑ a ∈ range u, Real.logb 2
      (#{x ∈ range u ∪ Ico u n | extremalType u x = extremalType u a} : ℝ)
      = ∑ _a ∈ range u, Real.logb 2 (u : ℝ) :=
    Finset.sum_congr rfl fun a ha => by rw [hU a ha, card_range]
  have e2 : ∑ a ∈ Ico u n, Real.logb 2
      (#{x ∈ range u ∪ Ico u n | extremalType u x = extremalType u a} : ℝ)
      = ∑ _a ∈ Ico u n, (0 : ℝ) :=
    Finset.sum_congr rfl fun a ha => by rw [hR a ha]; simp
  rw [lam, sum_union hdisj, e1, e2]
  simp

/-- **Sharpness.**  For every `r ≤ n` there is a sample of `n` primes, `r` of them ramified,
and a type read-out such that including the ramified primes raises the channel
`I(T ; T)` by at least `(r / n) log₂ n` bits.  Hence the `log N / N` rate of
`ramified_contribution_negligible` is optimal up to the constant factor. -/
theorem ramified_contribution_sharp (r n : ℕ) (hrn : r ≤ n) :
    ∃ U R : Finset ℕ, Disjoint U R ∧ R.card = r ∧ (U ∪ R).card = n ∧
      (r : ℝ) / n * Real.logb 2 n ≤
        mutInfo (U ∪ R) (extremalType (n - r)) (extremalType (n - r))
          - mutInfo U (extremalType (n - r)) (extremalType (n - r)) := by
  set u := n - r with hu
  have hun : u ≤ n := Nat.sub_le n r
  have hdisj : Disjoint (range u) (Ico u n) := by
    rw [range_eq_Ico]; exact Ico_disjoint_Ico_consecutive 0 u n
  have hcardR : (Ico u n).card = r := by rw [Nat.card_Ico]; omega
  have hcard : (range u ∪ Ico u n).card = n := by
    rw [card_union_of_disjoint hdisj, card_range, hcardR]; omega
  refine ⟨range u, Ico u n, hdisj, hcardR, hcard, ?_⟩
  -- the channel `I(T ; T)` is the entropy of `T`
  have hself : ∀ s : Finset ℕ, mutInfo s (extremalType u) (extremalType u)
      = uEnt s (extremalType u) := fun s =>
    mutInfo_of_function s _ _ id (fun _ _ => rfl)
  rw [hself, hself, uEnt_eq_lam, uEnt_eq_lam, lam_extremal_unram, lam_extremal_all u n,
    hcard, card_range]
  have hUn : Real.logb 2 (u : ℝ) ≤ Real.logb 2 (n : ℝ) := logb_natCast_mono hun
  have hUeq : Real.logb 2 (u : ℝ) - u * Real.logb 2 u / u = 0 := by
    rcases Nat.eq_zero_or_pos u with h | h
    · simp [h]
    · have : (u : ℝ) ≠ 0 := by exact_mod_cast h.ne'
      field_simp; ring
  rw [hUeq, sub_zero]
  rcases Nat.eq_zero_or_pos n with hn | hn
  · simp [hn]
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  have hcast : (u : ℝ) = n - r := by rw [hu]; push_cast [hrn]; ring
  have hu0 : (0 : ℝ) ≤ u := Nat.cast_nonneg u
  rw [div_mul_eq_mul_div, div_le_iff₀ hnR, sub_mul, div_mul_cancel₀ _ hnR.ne']
  have := mul_le_mul_of_nonneg_left hUn hu0
  rw [hcast] at this ⊢
  nlinarith

/-! ## Bridge to the Chebotarev fibre product -/

section Galois

variable {A G δ β : Type*} [Fintype G] [DecidableEq G] [DecidableEq A] [DecidableEq δ]
  [DecidableEq β]

/-- **The measured channel with ramified primes included is the Galois channel up to the
ramified bound.**  Model the unramified primes by the balanced Chebotarev fibre product of
`(p mod m, Frob_p)` and add any set `R` of at most `r` extra (ramified) sample points.  Then
the residue-to-type information of the contaminated sample differs from the pure
Galois-group channel `I(σ ; T)` (computed on `G` with the uniform law) by at most
`ramifiedBound r N`. -/
theorem ramified_galois_channel (U : Finset A) (χ : A → δ) (σ : G → δ) (T : G → β) (K : ℕ)
    (hKpos : 0 < K) (hbal : ∀ g : G, #{a ∈ U | χ a = σ g} = K) (R : Finset (A × G))
    (hR : Disjoint (fibreProd U χ σ) R) {r : ℕ} (hr : R.card ≤ r) :
    |mutInfo (fibreProd U χ σ ∪ R) (T ∘ Prod.snd) Prod.fst - mutInfo univ T σ|
      ≤ ramifiedBound r (fibreProd U χ σ ∪ R).card := by
  rw [← fibreProd_mutInfo U χ σ T K hKpos hbal]
  exact ramified_contribution_le_bound hR _ _ hr

end Galois

end Catalog.Probability.RamifiedTypeChannel