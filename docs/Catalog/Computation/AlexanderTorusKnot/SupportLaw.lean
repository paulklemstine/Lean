/-
# Cycle 12: the support law — `#supp Δ_{a,b} = 2·β(a,b) + 1`

This closes Conjecture 1 of the eleven-cycle thread. Cycle 9 proved
`coeff_n Δ_{a,b} = [n ∈ ⟨a,b⟩] − [n−1 ∈ ⟨a,b⟩]`, which turns the support of the Alexander
polynomial into a *boundary count* of the numerical semigroup:

* `upJumps`   : indices `n ≥ 1` entering the semigroup (`n ∈ S`, `n−1 ∉ S`), where the
  coefficient is `+1`;
* `downJumps` : indices leaving it (`n ∉ S`, `n−1 ∈ S`), where the coefficient is `−1`;
* `card_upJumps_eq_card_downJumps` : the two counts agree, by the telescoping identity
  `∑_{n ≥ 1} coeff_n Δ = Δ(1) − coeff_0 Δ = 0`;
* `torusAlexander_support` : `supp Δ_{a,b} = {0} ∪ upJumps ∪ downJumps`;
* `torusAlexander_support_card` : `#supp Δ_{a,b} = 2·#downJumps + 1`.

Since the down-jumps are exactly the starting points of the maximal runs of gaps, the number
of nonzero coefficients of `Δ_{a,b}` is `2β + 1` with `β` the number of gap runs. For the
catalog pencil this gives `β(2,N) = (N−1)/2` (`card_downJumps_two`), i.e. the `N` nonzero
coefficients of `A_N` are accounted for by the `(N−1)/2` isolated odd gaps of `⟨2,N⟩`: the
support is exponentially large in `log N` because the semigroup alternates at every step.
-/
import Computation.AlexanderTorusKnot.JonesComparison

namespace Computation.AlexanderTorusKnot

open Polynomial Finset

variable {a b : ℕ}

/-- Indices at which the semigroup `⟨a,b⟩` is entered; the coefficient of `Δ_{a,b}` there
is `+1`. -/
def upJumps (a b : ℕ) : Finset ℕ :=
  (Finset.Icc 1 ((a - 1) * (b - 1))).filter (fun n => IsRep a b n ∧ ¬ IsRep a b (n - 1))

/-- Indices at which the semigroup `⟨a,b⟩` is left — equivalently, the starting points of the
maximal runs of gaps. The coefficient of `Δ_{a,b}` there is `−1`. -/
def downJumps (a b : ℕ) : Finset ℕ :=
  (Finset.Icc 1 ((a - 1) * (b - 1))).filter (fun n => ¬ IsRep a b n ∧ IsRep a b (n - 1))

lemma coeff_of_mem_upJumps (hab : Nat.Coprime a b) (ha : 1 < a) (hb : 1 < b) {n : ℕ}
    (hn : n ∈ upJumps a b) : (torusAlexander a b).coeff n = 1 := by
  simp only [upJumps, Finset.mem_filter, Finset.mem_Icc] at hn
  obtain ⟨⟨h1, -⟩, h2, h3⟩ := hn
  rw [torusAlexander_coeff_semigroup hab ha hb n, if_pos h2,
    if_neg (fun hc => h3 hc.2)]
  norm_num

lemma coeff_of_mem_downJumps (hab : Nat.Coprime a b) (ha : 1 < a) (hb : 1 < b) {n : ℕ}
    (hn : n ∈ downJumps a b) : (torusAlexander a b).coeff n = -1 := by
  simp only [downJumps, Finset.mem_filter, Finset.mem_Icc] at hn
  obtain ⟨⟨h1, -⟩, h2, h3⟩ := hn
  rw [torusAlexander_coeff_semigroup hab ha hb n, if_neg h2, if_pos ⟨h1, h3⟩]
  norm_num

lemma coeff_eq_zero_of_not_jump (hab : Nat.Coprime a b) (ha : 1 < a) (hb : 1 < b) {n : ℕ}
    (hn : 1 ≤ n) (h1 : n ∉ upJumps a b) (h2 : n ∉ downJumps a b)
    (hle : n ≤ (a - 1) * (b - 1)) : (torusAlexander a b).coeff n = 0 := by
  simp only [upJumps, Finset.mem_filter, Finset.mem_Icc, not_and, not_not] at h1
  simp only [downJumps, Finset.mem_filter, Finset.mem_Icc, not_and] at h2
  have h1' := h1 ⟨hn, hle⟩
  have h2' := h2 ⟨hn, hle⟩
  rw [torusAlexander_coeff_semigroup hab ha hb n]
  by_cases hrep : IsRep a b n
  · rw [if_pos hrep, if_pos ⟨hn, h1' hrep⟩]
    norm_num
  · rw [if_neg hrep, if_neg (fun hc : 1 ≤ n ∧ IsRep a b (n - 1) => h2' hrep hc.2)]
    norm_num

/-- The total mass of the positive-index coefficients vanishes: `Δ(1) = 1 = coeff_0 Δ`. -/
lemma sum_coeff_pos (hab : Nat.Coprime a b) (ha : 1 < a) (hb : 1 < b) :
    ∑ n ∈ Finset.Icc 1 ((a - 1) * (b - 1)), (torusAlexander a b).coeff n = 0 := by
  have hdeg : (torusAlexander a b).natDegree = (a - 1) * (b - 1) :=
    torusAlexander_natDegree hab (by omega) (by omega)
  have heval : (torusAlexander a b).eval 1
      = ∑ n ∈ Finset.range ((a - 1) * (b - 1) + 1), (torusAlexander a b).coeff n := by
    rw [Polynomial.eval_eq_sum_range, hdeg]
    simp
  have hone : (torusAlexander a b).eval 1 = 1 := torusAlexander_eval_one hab
  have hzero : (torusAlexander a b).coeff 0 = 1 := by
    rw [torusAlexander_coeff_semigroup hab ha hb 0, if_pos (isRep_zero a b)]
    norm_num
  have hset : Finset.range ((a - 1) * (b - 1) + 1)
      = insert 0 (Finset.Icc 1 ((a - 1) * (b - 1))) := by
    ext n
    simp only [Finset.mem_range, Finset.mem_insert, Finset.mem_Icc]
    omega
  have hsplit : ∑ n ∈ Finset.range ((a - 1) * (b - 1) + 1), (torusAlexander a b).coeff n
      = (torusAlexander a b).coeff 0
        + ∑ n ∈ Finset.Icc 1 ((a - 1) * (b - 1)), (torusAlexander a b).coeff n := by
    rw [hset, Finset.sum_insert (by simp)]
  rw [heval, hsplit, hzero] at hone
  omega

/-- **The two jump sets are equinumerous.** -/
theorem card_upJumps_eq_card_downJumps (hab : Nat.Coprime a b) (ha : 1 < a) (hb : 1 < b) :
    (upJumps a b).card = (downJumps a b).card := by
  classical
  have hsum := sum_coeff_pos hab ha hb
  set s := Finset.Icc 1 ((a - 1) * (b - 1)) with hs
  have hup : ∑ n ∈ s.filter (fun n => n ∈ upJumps a b), (torusAlexander a b).coeff n
      = (upJumps a b).card := by
    have hfilter : s.filter (fun n => n ∈ upJumps a b) = upJumps a b := by
      ext n
      simp only [Finset.mem_filter, and_iff_right_iff_imp]
      intro hn
      simp only [upJumps, Finset.mem_filter] at hn
      exact hn.1
    rw [hfilter, Finset.sum_congr rfl (fun n hn => coeff_of_mem_upJumps hab ha hb hn)]
    simp
  have hdown : ∑ n ∈ (s.filter (fun n => n ∉ upJumps a b)).filter
        (fun n => n ∈ downJumps a b), (torusAlexander a b).coeff n
      = -((downJumps a b).card : ℤ) := by
    have hfilter : (s.filter (fun n => n ∉ upJumps a b)).filter
        (fun n => n ∈ downJumps a b) = downJumps a b := by
      ext n
      simp only [Finset.mem_filter, and_iff_right_iff_imp]
      intro hn
      have hmem : n ∈ s := by
        simp only [downJumps, Finset.mem_filter] at hn
        exact hn.1
      refine ⟨hmem, fun hup => ?_⟩
      simp only [upJumps, Finset.mem_filter] at hup
      simp only [downJumps, Finset.mem_filter] at hn
      exact hn.2.1 hup.2.1
    rw [hfilter, Finset.sum_congr rfl (fun n hn => coeff_of_mem_downJumps hab ha hb hn)]
    simp
  have hrest : ∑ n ∈ (s.filter (fun n => n ∉ upJumps a b)).filter
        (fun n => n ∉ downJumps a b), (torusAlexander a b).coeff n = 0 := by
    refine Finset.sum_eq_zero fun n hn => ?_
    simp only [Finset.mem_filter, hs, Finset.mem_Icc] at hn
    exact coeff_eq_zero_of_not_jump hab ha hb hn.1.1.1 hn.1.2 hn.2 hn.1.1.2
  have hsplit1 := Finset.sum_filter_add_sum_filter_not s (fun n => n ∈ upJumps a b)
    (fun n => (torusAlexander a b).coeff n)
  have hsplit2 := Finset.sum_filter_add_sum_filter_not (s.filter (fun n => n ∉ upJumps a b))
    (fun n => n ∈ downJumps a b) (fun n => (torusAlexander a b).coeff n)
  have hnotup : ∑ n ∈ s.filter (fun n => n ∉ upJumps a b), (torusAlexander a b).coeff n
      = -((downJumps a b).card : ℤ) := by
    rw [← hsplit2, hdown, hrest]
    ring
  rw [hup, hnotup, hsum] at hsplit1
  omega

lemma upJumps_disjoint_downJumps : Disjoint (upJumps a b) (downJumps a b) := by
  refine Finset.disjoint_left.2 fun n hn hn' => ?_
  simp only [upJumps, Finset.mem_filter] at hn
  simp only [downJumps, Finset.mem_filter] at hn'
  exact hn'.2.1 hn.2.1

/-- **The support of `Δ_{a,b}`** consists of `0` together with the jump indices of the
numerical semigroup `⟨a,b⟩`. -/
theorem torusAlexander_support (hab : Nat.Coprime a b) (ha : 1 < a) (hb : 1 < b) :
    (torusAlexander a b).support = insert 0 (upJumps a b ∪ downJumps a b) := by
  classical
  have hdeg : (torusAlexander a b).natDegree = (a - 1) * (b - 1) :=
    torusAlexander_natDegree hab (by omega) (by omega)
  ext n
  simp only [Polynomial.mem_support_iff, Finset.mem_insert, Finset.mem_union]
  constructor
  · intro hne
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · exact Or.inl rfl
    refine Or.inr ?_
    have hle : n ≤ (a - 1) * (b - 1) := by
      have := Polynomial.le_natDegree_of_ne_zero hne
      omega
    by_cases hup : n ∈ upJumps a b
    · exact Or.inl hup
    by_cases hdown : n ∈ downJumps a b
    · exact Or.inr hdown
    exact absurd (coeff_eq_zero_of_not_jump hab ha hb hn hup hdown hle) hne
  · rintro (rfl | hmem)
    · rw [torusAlexander_coeff_semigroup hab ha hb 0, if_pos (isRep_zero a b)]
      norm_num
    · rcases hmem with hup | hdown
      · rw [coeff_of_mem_upJumps hab ha hb hup]; norm_num
      · rw [coeff_of_mem_downJumps hab ha hb hdown]; norm_num

/-- **The support law.** The number of nonzero coefficients of `Δ_{a,b}` is
`2·#downJumps + 1`, i.e. twice the number of maximal gap runs of `⟨a,b⟩` plus one. -/
theorem torusAlexander_support_card (hab : Nat.Coprime a b) (ha : 1 < a) (hb : 1 < b) :
    (torusAlexander a b).support.card = 2 * (downJumps a b).card + 1 := by
  classical
  have hzero : (0 : ℕ) ∉ upJumps a b ∪ downJumps a b := by
    intro h
    rcases Finset.mem_union.1 h with h | h <;>
      simp only [upJumps, downJumps, Finset.mem_filter, Finset.mem_Icc] at h <;> omega
  rw [torusAlexander_support hab ha hb, Finset.card_insert_of_notMem hzero,
    Finset.card_union_of_disjoint upJumps_disjoint_downJumps,
    card_upJumps_eq_card_downJumps hab ha hb]
  omega

/-- Specialisation to the catalog pencil: `⟨2,N⟩` has exactly `(N−1)/2` gap runs, matching
the `N` nonzero coefficients of `A_N`. -/
theorem card_downJumps_two {N : ℕ} (hN : Odd N) (h1 : 1 < N) :
    2 * (downJumps 2 N).card + 1 = N := by
  have hcop : Nat.Coprime 2 N := by simpa using hN
  have hsupp := torusAlexander_support_card hcop (by omega) h1
  rw [torusAlexander_two_eq_alexander hN h1,
    Bridges.AlexanderTorus.alexander_support_card N] at hsupp
  omega

end Computation.AlexanderTorusKnot