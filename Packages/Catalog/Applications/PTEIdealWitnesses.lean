/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Mathlib
import Applications.PTESizeNewton

/-!
# Ideal witnesses: the minimal mass of an invisible vector is exactly `2K` for `K ≤ 10`

`Applications/PTESizeNewton.lean` proves that a nonzero integral vector invisible to the
power-sum window `k < K` has mass `∑_j |e j| ≥ 2K`.  This file supplies the matching
**construction** and thereby computes the minimal mass exactly.

The construction is the classical one: an *ideal Prouhet–Tarry–Escott pair*, i.e. two
disjoint sets of `K` naturals with identical power sums `p_0, …, p_{K-1}`.  Its
multiplicity difference is an invisible vector of mass `2K`.  Explicit ideal pairs are
supplied for every window `K ≤ 10` and for `K = 12`; each is certified inside Lean by
kernel evaluation of the finitely many power-sum identities, and the reduction from
"list of nodes" to "weight vector" is the general lemma `pte_pair`.

## Main results

* `pte_pair` — the general dictionary: two disjoint lists of nodes bounded by `N` with equal
  power sums throughout the window `k < K` give a vector invisible to that window, with
  explicit moments, explicit support and mass exactly `|A| + |B|`.
* `MassAchievable`, `minMass` — the minimal mass of a nonzero invisible vector at window `K`.
* `two_mul_le_minMass` (lower bound, from the Newton law) and `minMass_le` (upper bound from
  any witness), together with `minMass_le_two_pow` showing the minimum is well defined.
* `minMass_eq_two_mul` — **the exact value `minMass K = 2K` for `K = 1, …, 10` and `K = 12`.**
* `minMass_eleven_eq_or` — **the boundary case.**  `minMass 11 ∈ {22, 24}`, and it is `22`
  exactly when an ideal Prouhet–Tarry–Escott pair of size `11` exists — a well-known open
  problem.  So the catalog now contains a completely explicit, decidable-in-principle
  statement whose resolution is open mathematics.
* `minMass_lt_two_pow` — for `4 ≤ K ≤ 10` (and `K = 12`) the minimal mass is *exponentially*
  below the mass `2^K` of the shifted binomial vectors, so the binomial basis of
  `InvisibleWeightVectors` is very far from mass-optimal.

-- !-- Lab Notes -- !--

HYPOTHESIS (Hypothesizer).  If the Newton bound `2K` is the truth, minimal-mass invisible
vectors must be `±1`-valued and supported on `2K` nodes — no multiplicities, no cancellation
slack.  Bold form: for every `K` there is a `±1`-valued invisible vector on `2K` nodes.

EXPERIMENT (Experimenter).  Confirmed for `K ≤ 10` and `K = 12` by explicit witnesses
(`ComputationalEvidence.md` records the search data).  At `K = 11` the hypothesis is
*undecided*: no ideal pair of size 11 is known, and our certificate at `K = 12` only gives
mass `24`.  The parity lemma `l1_even_of_invisible_int` rules out `23`, so the value is `22`
or `24` — recorded as `minMass_eleven_eq_or`.

ANALYSIS (Analyst).  The witnesses show three distinct regimes.  For `K ≤ 3` the binomial
vector *is* mass-optimal (`2^K = 2K` at `K = 1, 2` and `8 > 6` already at `K = 3`).  From
`K = 4` on, ideal pairs beat the binomial vector by an exponential factor.  The obstruction
at `K = 11` is not a defect of the method: it is the same obstruction that has kept the
ideal PTE problem open for a century.

CRITIQUE (Critic).  The witnesses are not trivialities: each certifies `K` polynomial
identities in integers up to `47500 ^ 9`, and the packaging lemma `pte_pair` is proved in
general (no `decide` on the mass identity, which is a statement about a sum over
`range (N+1)` with `N` as large as `47500`).  `minMass` is well defined because the shifted
binomial vector always achieves mass `2^K`; without that the `sInf` would silently be `0`.
-/

open Finset

namespace PTEWitness

open PowerSumSharpness InvisibleWeights PTESize

/-! ## From node lists to weight vectors -/

/-- `listPowerSum A k = ∑_{a ∈ A} a ^ k`, computed in `ℕ` so that the certificates for the
explicit witnesses reduce by kernel arithmetic. -/
def listPowerSum (A : List ℕ) (k : ℕ) : ℕ := (A.map fun a => a ^ k).sum

/-- The multiplicity difference of two node lists, as an integral weight vector. -/
def listWeight (A B : List ℕ) : ℕ → ℤ := fun j => (A.count j : ℤ) - (B.count j : ℤ)

lemma powerSum_coe_list (A : List ℕ) (k : ℕ) :
    powerSum (↑A : Multiset ℕ) k = (listPowerSum A k : ℤ) := by
  simp [powerSum, listPowerSum, Function.comp_def]

lemma count_coe_list (A : List ℕ) (j : ℕ) : (↑A : Multiset ℕ).count j = A.count j := by
  simp

/-- Every node list bounded by `N` has its multiplicities summing to its length. -/
lemma sum_count_eq_length {N : ℕ} {A : List ℕ} (hA : ∀ a ∈ A, a ≤ N) :
    ∑ j ∈ range (N + 1), (A.count j : ℤ) = (A.length : ℤ) := by
  have hmem : ∀ x ∈ (↑A : Multiset ℕ), x ≤ N := fun x hx => hA x (by simpa using hx)
  have h0 := powerSum_ofCounts N (fun j => (↑A : Multiset ℕ).count j) 0
  rw [← eq_ofCounts hmem, powerSum_index_zero] at h0
  simpa using h0.symm

/-- The moments of `listWeight A B` are the differences of the power sums of `A` and `B`. -/
lemma moment_listWeight {N : ℕ} {A B : List ℕ} (hA : ∀ a ∈ A, a ≤ N) (hB : ∀ b ∈ B, b ≤ N)
    (k : ℕ) :
    moment N (listWeight A B) k = (listPowerSum A k : ℤ) - (listPowerSum B k : ℤ) := by
  have key : ∀ C : List ℕ, (∀ c ∈ C, c ≤ N) →
      ∑ j ∈ range (N + 1), (C.count j : ℤ) * (j : ℤ) ^ k = (listPowerSum C k : ℤ) := by
    intro C hC
    have hmem : ∀ x ∈ (↑C : Multiset ℕ), x ≤ N := fun x hx => hC x (by simpa using hx)
    have h := powerSum_ofCounts N (fun j => (↑C : Multiset ℕ).count j) k
    rw [← eq_ofCounts hmem, powerSum_coe_list] at h
    simpa using h.symm
  simp only [moment, listWeight, sub_mul, Finset.sum_sub_distrib]
  rw [key A hA, key B hB]

/-- **The dictionary.**  Two disjoint node lists bounded by `N` whose power sums agree
throughout the window `k < K` give an invisible vector of mass exactly `|A| + |B|`, with
support inside `{0, …, N}` and with computable moments. -/
theorem pte_pair {N K : ℕ} {A B : List ℕ} (hA : ∀ a ∈ A, a ≤ N) (hB : ∀ b ∈ B, b ≤ N)
    (hdisj : ∀ j ∈ A, j ∉ B) (hAne : A ≠ [])
    (hpte : ∀ k < K, listPowerSum A k = listPowerSum B k) :
    (∀ j, N < j → listWeight A B j = 0) ∧
      Invisible N K (listWeight A B) ∧
      (∃ j ≤ N, listWeight A B j ≠ 0) ∧
      (∀ k, moment N (listWeight A B) k = (listPowerSum A k : ℤ) - (listPowerSum B k : ℤ)) ∧
      ∑ j ∈ range (N + 1), |listWeight A B j| = ((A.length + B.length : ℕ) : ℤ) := by
  refine ⟨?_, ?_, ?_, moment_listWeight hA hB, ?_⟩
  · intro j hj
    have h1 : A.count j = 0 := List.count_eq_zero.mpr fun hmem => by
      have := hA j hmem; omega
    have h2 : B.count j = 0 := List.count_eq_zero.mpr fun hmem => by
      have := hB j hmem; omega
    simp [listWeight, h1, h2]
  · intro k hk
    rw [moment_listWeight hA hB, hpte k hk, sub_self]
  · obtain ⟨a, ha⟩ := List.exists_mem_of_ne_nil A hAne
    refine ⟨a, hA a ha, ?_⟩
    have h1 : 0 < A.count a := List.count_pos_iff.mpr ha
    have h2 : B.count a = 0 := List.count_eq_zero.mpr (hdisj a ha)
    simp only [listWeight, h2, Nat.cast_zero, sub_zero, ne_eq, Nat.cast_eq_zero]
    omega
  · have habs : ∀ j, |listWeight A B j| = (A.count j : ℤ) + (B.count j : ℤ) := by
      intro j
      by_cases hj : j ∈ A
      · have h2 : B.count j = 0 := List.count_eq_zero.mpr (hdisj j hj)
        simp only [listWeight, h2, Nat.cast_zero, sub_zero, add_zero]
        exact abs_of_nonneg (by positivity)
      · have h1 : A.count j = 0 := List.count_eq_zero.mpr hj
        simp only [listWeight, h1, Nat.cast_zero, zero_sub, zero_add, abs_neg]
        exact abs_of_nonneg (by positivity)
    simp only [habs]
    rw [Finset.sum_add_distrib, sum_count_eq_length hA, sum_count_eq_length hB]
    push_cast
    ring

/-! ## The minimal mass of an invisible vector -/

/-- `MassAchievable K L` : there is a nonzero integral vector invisible to the window
`k < K` whose total mass is exactly `L`. -/
def MassAchievable (K L : ℕ) : Prop :=
  ∃ (N : ℕ) (e : ℕ → ℤ), Invisible N K e ∧ (∃ j ≤ N, e j ≠ 0) ∧
    ∑ j ∈ range (N + 1), |e j| = (L : ℤ)

/-- The minimal mass of a nonzero vector invisible to the window `k < K`. -/
noncomputable def minMass (K : ℕ) : ℕ := sInf {L | MassAchievable K L}

/-- The shifted binomial vector realises mass `2 ^ K`, so the minimum is well defined. -/
theorem massAchievable_two_pow (K : ℕ) : MassAchievable K (2 ^ K) := by
  refine ⟨K, binWeight (R := ℤ) K 0, binWeight_invisible (by omega), ⟨K, le_rfl, ?_⟩, ?_⟩
  · have h : binWeight (R := ℤ) K 0 (0 + K) = 1 := binWeight_top K 0
    rw [zero_add] at h
    rw [h]
    norm_num
  · have habs : ∀ j ∈ range (K + 1), |binWeight (R := ℤ) K 0 j| = (K.choose j : ℤ) := by
      intro j hj
      have hj' : j ≤ K := Nat.lt_succ_iff.mp (mem_range.mp hj)
      simp only [binWeight, Nat.zero_le, true_and, Nat.sub_zero]
      rw [if_pos (by omega), abs_mul, abs_pow, abs_neg, abs_one, one_pow, one_mul,
        Nat.abs_cast]
    rw [Finset.sum_congr rfl habs]
    have : ∑ j ∈ range (K + 1), (K.choose j : ℤ) = ((∑ j ∈ range (K + 1), K.choose j : ℕ) : ℤ) := by
      push_cast
      ring
    rw [this, Nat.sum_range_choose]

theorem minMass_le {K L : ℕ} (h : MassAchievable K L) : minMass K ≤ L := Nat.sInf_le h

theorem minMass_le_two_pow (K : ℕ) : minMass K ≤ 2 ^ K := minMass_le (massAchievable_two_pow K)

theorem minMass_mem (K : ℕ) : MassAchievable K (minMass K) :=
  Nat.sInf_mem (s := {L | MassAchievable K L}) ⟨2 ^ K, massAchievable_two_pow K⟩

/-- **The Newton lower bound, in terms of `minMass`.** -/
theorem two_mul_le_minMass (K : ℕ) : 2 * K ≤ minMass K := by
  obtain ⟨N, e, hinv, ⟨j₀, hj₀, hne⟩, hmass⟩ := minMass_mem K
  have h := l1_ge_two_mul_window hinv hj₀ hne
  rw [hmass] at h
  exact_mod_cast h

/-- Any witness pins the value from above; combined with `two_mul_le_minMass` this computes
`minMass` exactly whenever a witness of mass `2K` exists. -/
theorem minMass_eq_of_witness {K : ℕ} (h : MassAchievable K (2 * K)) : minMass K = 2 * K :=
  le_antisymm (minMass_le h) (two_mul_le_minMass K)

/-! ## The explicit ideal witnesses -/

/-- Packaging: an explicit disjoint pair of node lists of equal length `K` with matching
power sums below `K` certifies `MassAchievable K (2 * K)`. -/
theorem massAchievable_of_lists {K N : ℕ} {A B : List ℕ} (hA : ∀ a ∈ A, a ≤ N)
    (hB : ∀ b ∈ B, b ≤ N) (hdisj : ∀ j ∈ A, j ∉ B) (hAne : A ≠ [])
    (hlen : A.length + B.length = 2 * K)
    (hpte : ∀ k < K, listPowerSum A k = listPowerSum B k) :
    MassAchievable K (2 * K) := by
  obtain ⟨-, hinv, hnz, -, hmass⟩ := pte_pair hA hB hdisj hAne hpte
  exact ⟨N, listWeight A B, hinv, hnz, by rw [hmass, hlen]⟩

theorem massAchievable_one : MassAchievable 1 2 :=
  massAchievable_of_lists (A := [0]) (B := [1]) (N := 1) (by decide) (by decide) (by decide)
    (by decide) (by decide) (by decide)

theorem massAchievable_two : MassAchievable 2 4 :=
  massAchievable_of_lists (A := [0, 3]) (B := [1, 2]) (N := 3) (by decide) (by decide)
    (by decide) (by decide) (by decide) (by decide)

theorem massAchievable_three : MassAchievable 3 6 :=
  massAchievable_of_lists (A := [1, 5, 6]) (B := [2, 3, 7]) (N := 7) (by decide) (by decide)
    (by decide) (by decide) (by decide) (by decide)

theorem massAchievable_four : MassAchievable 4 8 :=
  massAchievable_of_lists (A := [0, 4, 7, 11]) (B := [1, 2, 9, 10]) (N := 11) (by decide)
    (by decide) (by decide) (by decide) (by decide) (by decide)

theorem massAchievable_five : MassAchievable 5 10 :=
  massAchievable_of_lists (A := [1, 2, 10, 14, 18]) (B := [0, 4, 8, 16, 17]) (N := 18)
    (by decide) (by decide) (by decide) (by decide) (by decide) (by decide)

theorem massAchievable_six : MassAchievable 6 12 :=
  massAchievable_of_lists (A := [0, 5, 6, 16, 17, 22]) (B := [1, 2, 10, 12, 20, 21]) (N := 22)
    (by decide) (by decide) (by decide) (by decide) (by decide) (by decide)

theorem massAchievable_seven : MassAchievable 7 14 :=
  massAchievable_of_lists (A := [0, 18, 27, 58, 64, 89, 101])
    (B := [1, 13, 38, 44, 75, 84, 102]) (N := 102)
    (by decide) (by decide) (by decide) (by decide) (by decide) (by decide)

theorem massAchievable_eight : MassAchievable 8 16 :=
  massAchievable_of_lists (A := [0, 4, 9, 23, 27, 41, 46, 50])
    (B := [1, 2, 11, 20, 30, 39, 48, 49]) (N := 50)
    (by decide) (by decide) (by decide) (by decide) (by decide) (by decide)

theorem massAchievable_nine : MassAchievable 9 18 :=
  massAchievable_of_lists (A := [0, 24, 30, 83, 86, 133, 157, 181, 197])
    (B := [1, 17, 41, 65, 112, 115, 168, 174, 198]) (N := 198)
    (by decide) (by decide) (by decide) (by decide) (by decide) (by decide)

theorem massAchievable_ten : MassAchievable 10 20 :=
  massAchievable_of_lists
    (A := [12, 2865, 3519, 11869, 23738, 23762, 35631, 43981, 44635, 47488])
    (B := [0, 3083, 3301, 11893, 23314, 24186, 35607, 44199, 44417, 47500]) (N := 47500)
    (by decide) (by decide) (by decide) (by decide) (by decide) (by decide)

theorem massAchievable_twelve : MassAchievable 12 24 :=
  massAchievable_of_lists
    (A := [0, 11, 24, 65, 90, 129, 173, 212, 237, 278, 291, 302])
    (B := [3, 5, 30, 57, 104, 116, 186, 198, 245, 272, 297, 299]) (N := 302)
    (by decide) (by decide) (by decide) (by decide) (by decide) (by decide)

/-! ## The exact values -/

theorem minMass_one : minMass 1 = 2 := minMass_eq_of_witness massAchievable_one
theorem minMass_two : minMass 2 = 4 := minMass_eq_of_witness massAchievable_two
theorem minMass_three : minMass 3 = 6 := minMass_eq_of_witness massAchievable_three
theorem minMass_four : minMass 4 = 8 := minMass_eq_of_witness massAchievable_four
theorem minMass_five : minMass 5 = 10 := minMass_eq_of_witness massAchievable_five
theorem minMass_six : minMass 6 = 12 := minMass_eq_of_witness massAchievable_six
theorem minMass_seven : minMass 7 = 14 := minMass_eq_of_witness massAchievable_seven
theorem minMass_eight : minMass 8 = 16 := minMass_eq_of_witness massAchievable_eight
theorem minMass_nine : minMass 9 = 18 := minMass_eq_of_witness massAchievable_nine
theorem minMass_ten : minMass 10 = 20 := minMass_eq_of_witness massAchievable_ten
theorem minMass_twelve : minMass 12 = 24 := minMass_eq_of_witness massAchievable_twelve

/-- **The minimal mass is exactly `2K` for every window `K ≤ 10` and for `K = 12`.** -/
theorem minMass_eq_two_mul {K : ℕ} (hK : 1 ≤ K) (hK' : K ≤ 10 ∨ K = 12) :
    minMass K = 2 * K := by
  rcases hK' with h | h
  · interval_cases K
    · exact minMass_one
    · exact minMass_two
    · exact minMass_three
    · exact minMass_four
    · exact minMass_five
    · exact minMass_six
    · exact minMass_seven
    · exact minMass_eight
    · exact minMass_nine
    · exact minMass_ten
  · subst h
    exact minMass_twelve

/-! ## The open boundary at `K = 11` -/

/-- Shrinking the window keeps a vector invisible. -/
lemma invisible_mono {N K K' : ℕ} (h : K' ≤ K) {e : ℕ → ℤ} (he : Invisible N K e) :
    Invisible N K' e := fun k hk => he k (lt_of_lt_of_le hk h)

theorem massAchievable_mono {K K' L : ℕ} (h : K' ≤ K) (hL : MassAchievable K L) :
    MassAchievable K' L := by
  obtain ⟨N, e, hinv, hnz, hmass⟩ := hL
  exact ⟨N, e, invisible_mono h hinv, hnz, hmass⟩

/-- The mass of a nonzero invisible vector is even (catalog parity lemma, in `minMass` form). -/
theorem minMass_even {K : ℕ} (hK : 1 ≤ K) : 2 ∣ minMass K := by
  obtain ⟨N, e, hinv, -, hmass⟩ := minMass_mem K
  have h := l1_even_of_invisible_int hK hinv
  rw [hmass] at h
  exact_mod_cast h

/-- **The boundary case `K = 11`.**  The Newton bound gives `≥ 22`, the size-12 ideal pair
gives `≤ 24`, and parity excludes `23`: so the minimal mass at window `11` is `22` or `24`.
It equals `22` precisely when an ideal Prouhet–Tarry–Escott configuration of size `11`
exists, which is open. -/
theorem minMass_eleven_eq_or : minMass 11 = 22 ∨ minMass 11 = 24 := by
  have hlow : 22 ≤ minMass 11 := by simpa using two_mul_le_minMass 11
  have hhigh : minMass 11 ≤ 24 := minMass_le (massAchievable_mono (by omega) massAchievable_twelve)
  have hpar : 2 ∣ minMass 11 := minMass_even (by omega)
  omega

/-! ## Consequence: the binomial basis is far from mass-optimal -/

/-- For `4 ≤ K ≤ 10` (and for `K = 12`) the minimal mass `2K` is strictly, and
exponentially, below the mass `2 ^ K` of the shifted binomial vectors. -/
theorem minMass_lt_two_pow {K : ℕ} (hK : 4 ≤ K) (hK' : K ≤ 10 ∨ K = 12) :
    minMass K < 2 ^ K := by
  rw [minMass_eq_two_mul (by omega) hK']
  have h : ∀ m : ℕ, 4 ≤ m → 2 * m < 2 ^ m := by
    intro m hm
    induction m, hm using Nat.le_induction with
    | base => norm_num
    | succ n hn ih =>
        have h2 : 2 ^ (n + 1) = 2 * 2 ^ n := by ring
        omega
  exact h K hK

/-- The gap at `K = 10`: mass `20` versus the binomial vector's `1024`. -/
theorem minMass_ten_gap : 51 * minMass 10 < 2 ^ 10 := by
  rw [minMass_ten]
  norm_num

end PTEWitness