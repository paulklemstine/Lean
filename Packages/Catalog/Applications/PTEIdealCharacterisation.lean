/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Mathlib
import Applications.PTEMassSubmultiplicative

/-!
# When is the Newton bound attained?  `minMass K = 2K ↔ an ideal pair of size `K` exists`

`PTESize.l1_ge_two_mul_window` gives `minMass K ≥ 2K` and `PTEIdealWitnesses` realises `2K`
for `K ≤ 10` and `K = 12` by exhibiting *ideal Prouhet–Tarry–Escott pairs*.  This file closes
the loop: equality in the Newton bound holds **exactly** when such a pair exists.

* `IdealPair K` — two disjoint multisets of `K` naturals, distinct, with identical power sums
  throughout the window `k < K`.
* `minMass_eq_two_mul_iff` — **`minMass K = 2K ↔ IdealPair K`**, for every `K`.
* `minMass_eleven_eq_22_iff` — the boundary case in exact form: `minMass 11 = 22` iff an
  ideal pair of size `11` exists.  Together with `minMass_eleven_eq_or` this turns a century
  old open problem into a two-valued question about a catalog invariant.
* `idealPair_iff_minMass` and `not_idealPair_of_minMass_ne` — the contrapositive readings,
  usable as a *nonexistence certificate*: computing `minMass 11 = 24` would prove that no
  ideal Prouhet–Tarry–Escott pair of size `11` exists.

-- !-- Lab Notes -- !--

HYPOTHESIS (Hypothesizer).  Attaining the Newton bound should be equivalent to a purely
combinatorial configuration, with no room for multiplicities or cancellation: mass `2K` must
split as `K + K` and, by the rigidity theorem, the two sides must be disjoint.

EXPERIMENT (Experimenter).  Proved in both directions.  The forward direction uses the
rigidity theorem `nearMiss_disjoint_of_card_eq_window`; the backward direction needs the mass
computation for a disjoint pair, `mass_of_disjoint_nearMiss`, which is where disjointness is
used quantitatively (`|a - b| = a + b` when one of `a, b` vanishes).

ANALYSIS (Analyst).  The equivalence explains why the catalog's `K ≤ 10` witnesses stop:
they stop exactly where the ideal PTE problem stops.  There is no formal obstruction visible
in the invisible-vector picture, which supports the view that the difficulty at `K = 11` is
arithmetic, not structural.

CRITIQUE (Critic).  Both directions are quantified over *multisets*, not sets, so the
statement does not secretly assume distinctness of nodes; distinctness of the two *sides* is
a conclusion (`IdealPair` carries disjointness), not an assumption.  No hypothesis on `K` is
needed: at `K = 0` both sides are false, since `minMass 0 = 1 ≠ 0` (`minMass_zero`) and an
ideal pair of size `0` would need two distinct empty multisets.
-/

open Finset

namespace PTEIdeal

open PowerSumSharpness InvisibleWeights PTESize PTEWitness PTEBase PTERigid

/-- `IdealPair K` : an *ideal Prouhet–Tarry–Escott configuration of size `K`* — two disjoint
multisets of `K` naturals, distinct, with equal power sums `p_0, …, p_{K-1}`. -/
def IdealPair (K : ℕ) : Prop :=
  ∃ s t : Multiset ℕ, Multiset.card s = K ∧ Multiset.card t = K ∧ (∀ a ∈ s, a ∉ t) ∧
    s ≠ t ∧ ∀ k < K, powerSum s k = powerSum t k

/-! ## Mass bookkeeping -/

lemma sum_count_eq_card {N : ℕ} {s : Multiset ℕ} (hs : ∀ x ∈ s, x ≤ N) :
    ∑ j ∈ range (N + 1), (s.count j : ℤ) = (Multiset.card s : ℤ) := by
  have h := powerSum_ofCounts N (fun j => s.count j) 0
  rw [← eq_ofCounts hs, powerSum_index_zero] at h
  simpa using h.symm

/-- For a *disjoint* pair of multisets the mass of the multiplicity difference is the total
number of elements. -/
lemma mass_of_disjoint_nearMiss {N : ℕ} {s t : Multiset ℕ} (hs : ∀ x ∈ s, x ≤ N)
    (ht : ∀ x ∈ t, x ≤ N) (hdisj : ∀ a ∈ s, a ∉ t) :
    ∑ j ∈ range (N + 1), |(s.count j : ℤ) - (t.count j : ℤ)|
      = (Multiset.card s : ℤ) + (Multiset.card t : ℤ) := by
  classical
  have habs : ∀ j, |(s.count j : ℤ) - (t.count j : ℤ)| = (s.count j : ℤ) + (t.count j : ℤ) := by
    intro j
    by_cases hj : 0 < s.count j
    · have hmem : j ∈ s := Multiset.count_pos.mp hj
      have h0 : t.count j = 0 := Multiset.count_eq_zero.mpr (hdisj j hmem)
      rw [h0]
      simp only [Nat.cast_zero, sub_zero, add_zero]
      exact abs_of_nonneg (by positivity)
    · have h0 : s.count j = 0 := by omega
      rw [h0]
      simp only [Nat.cast_zero, zero_sub, zero_add, abs_neg]
      exact abs_of_nonneg (by positivity)
  simp only [habs]
  rw [Finset.sum_add_distrib, sum_count_eq_card hs, sum_count_eq_card ht]

/-- The mass of an invisible vector equals the total size of the two multisets it defines. -/
lemma mass_eq_card_add_card (N : ℕ) (e : ℕ → ℤ) :
    ∑ j ∈ range (N + 1), |e j|
      = (Multiset.card (posMultiset N e) : ℤ) + (Multiset.card (negMultiset N e) : ℤ) := by
  rw [posMultiset, negMultiset, card_ofCounts, card_ofCounts, ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun j _ => ?_
  simp only [InvisibleWeights.posPart, InvisibleWeights.negPart, Int.abs_eq_natAbs]
  omega

/-- The empty window costs one unit of mass: a single node carrying `±1`. -/
theorem minMass_zero : minMass 0 = 1 := by
  have hach : MassAchievable 0 1 := by
    refine ⟨0, fun j => if j = 0 then 1 else 0, fun k hk => absurd hk (by omega), ⟨0, le_rfl, ?_⟩, ?_⟩
    · norm_num
    · norm_num
  have hle : minMass 0 ≤ 1 := minMass_le hach
  rcases Nat.eq_zero_or_pos (minMass 0) with h | h
  · exfalso
    obtain ⟨N, e, -, ⟨j₀, hj₀, hne⟩, hmass⟩ := minMass_mem 0
    rw [h] at hmass
    have hzero : ∀ j ∈ range (N + 1), |e j| = 0 := by
      refine (Finset.sum_eq_zero_iff_of_nonneg fun j _ => abs_nonneg _).mp ?_
      simpa using hmass
    exact hne (abs_eq_zero.mp (hzero j₀ (mem_range.mpr (by omega))))
  · omega

/-! ## The characterisation -/

theorem idealPair_of_minMass_eq {K : ℕ} (h : minMass K = 2 * K) : IdealPair K := by
  obtain ⟨N, e, hinv, ⟨j₀, hj₀, hne⟩, hmass⟩ := minMass_mem K
  obtain ⟨-, -, hdist, hpow⟩ := nearMiss_of_invisible hinv hj₀ hne
  have hsum : (Multiset.card (posMultiset N e) : ℤ) + (Multiset.card (negMultiset N e) : ℤ)
      = ((2 * K : ℕ) : ℤ) := by
    rw [← mass_eq_card_add_card, hmass, h]
  have hsum' : Multiset.card (posMultiset N e) + Multiset.card (negMultiset N e) = 2 * K := by
    exact_mod_cast hsum
  obtain ⟨hcs, hct, hdisj⟩ := minimal_mass_sides_disjoint hpow hdist hsum'
  exact ⟨posMultiset N e, negMultiset N e, hcs, hct, hdisj, hdist, hpow⟩

theorem minMass_eq_of_idealPair {K : ℕ} (h : IdealPair K) : minMass K = 2 * K := by
  obtain ⟨s, t, hcs, hct, hdisj, hne, hpow⟩ := h
  classical
  -- choose a common bound for the nodes
  obtain ⟨N, hN⟩ : ∃ N : ℕ, (∀ x ∈ s, x ≤ N) ∧ (∀ x ∈ t, x ≤ N) := by
    refine ⟨((s + t).toFinset.sup id), ⟨fun x hx => ?_, fun x hx => ?_⟩⟩
    · exact Finset.le_sup (f := id) (Multiset.mem_toFinset.mpr (Multiset.mem_add.mpr (Or.inl hx)))
    · exact Finset.le_sup (f := id) (Multiset.mem_toFinset.mpr (Multiset.mem_add.mpr (Or.inr hx)))
  obtain ⟨hs, ht⟩ := hN
  set e : ℕ → ℤ := fun j => (s.count j : ℤ) - (t.count j : ℤ) with he
  have hinv : Invisible N K e := invisible_of_nearMiss hs ht hpow
  have hnz : ∃ j ≤ N, e j ≠ 0 := by
    by_contra hcon
    push_neg at hcon
    refine hne (Multiset.ext.mpr fun j => ?_)
    by_cases hj : j ≤ N
    · have := hcon j hj
      rw [he] at this
      simp only [sub_eq_zero] at this
      exact_mod_cast this
    · rw [Multiset.count_eq_zero.mpr fun hmem => hj (hs j hmem),
        Multiset.count_eq_zero.mpr fun hmem => hj (ht j hmem)]
  have hmass : ∑ j ∈ range (N + 1), |e j| = ((2 * K : ℕ) : ℤ) := by
    rw [he, mass_of_disjoint_nearMiss hs ht hdisj, hcs, hct]
    push_cast
    ring
  have hle : minMass K ≤ 2 * K := minMass_le ⟨N, e, hinv, hnz, hmass⟩
  exact le_antisymm hle (two_mul_le_minMass K)

/-- **The characterisation.**  The Newton bound `minMass K ≥ 2K` is attained exactly when an
ideal Prouhet–Tarry–Escott configuration of size `K` exists. -/
theorem minMass_eq_two_mul_iff (K : ℕ) : minMass K = 2 * K ↔ IdealPair K :=
  ⟨idealPair_of_minMass_eq, minMass_eq_of_idealPair⟩

/-- Ideal configurations exist for every size `K ≤ 10` and for `K = 12`. -/
theorem idealPair_of_le_ten {K : ℕ} (hK : 1 ≤ K) (hK' : K ≤ 10 ∨ K = 12) : IdealPair K :=
  (minMass_eq_two_mul_iff K).mp (minMass_eq_two_mul hK hK')

/-- **The open boundary, exactly.**  `minMass 11 = 22` if and only if an ideal
Prouhet–Tarry–Escott configuration of size `11` exists. -/
theorem minMass_eleven_eq_22_iff : minMass 11 = 22 ↔ IdealPair 11 := by
  have h := minMass_eq_two_mul_iff 11
  simpa using h

/-- A *nonexistence certificate*: if the minimal mass at window `11` is not `22` — and by
`minMass_eleven_eq_or` the only alternative is `24` — then no ideal configuration of size
`11` exists. -/
theorem not_idealPair_of_minMass_ne (h : minMass 11 = 24) : ¬ IdealPair 11 := by
  intro hid
  have := minMass_eq_of_idealPair hid
  omega

/-- The dichotomy in its sharpest form: either an ideal size-`11` configuration exists and
the minimal mass is `22`, or none exists and the minimal mass is `24`. -/
theorem minMass_eleven_dichotomy :
    (IdealPair 11 ∧ minMass 11 = 22) ∨ (¬ IdealPair 11 ∧ minMass 11 = 24) := by
  rcases minMass_eleven_eq_or with h | h
  · exact Or.inl ⟨minMass_eleven_eq_22_iff.mp h, h⟩
  · exact Or.inr ⟨not_idealPair_of_minMass_ne h, h⟩

/-- **Improved lower bound in the absence of an ideal configuration.**  For `K ≥ 1`, if no
ideal Prouhet–Tarry–Escott pair of size `K` exists then the minimal mass jumps to at least
`2K + 2`, because it is even and cannot equal `2K`. -/
theorem minMass_ge_two_mul_add_two {K : ℕ} (hK : 1 ≤ K) (h : ¬ IdealPair K) :
    2 * K + 2 ≤ minMass K := by
  have h1 : 2 * K ≤ minMass K := two_mul_le_minMass K
  have h2 : minMass K ≠ 2 * K := fun hc => h ((minMass_eq_two_mul_iff K).mp hc)
  have h3 : 2 ∣ minMass K := minMass_even hK
  omega

end PTEIdeal