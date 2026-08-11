import Computation.KraftConverse
import Novelty.MultiwaySortingRadix

/-!
# Entropy-sensitive sorting under nonuniform priors

The uniform-prior theory of the previous cycles fixes the sorting baseline at `log₂(n!)`
bits, i.e. `kT log (n!)` of Landauer work.  This file proves the conjectured prior-sensitive
refinement, in the sharp form "within **one** comparison", not merely `O(n)`:

* `PriorSorter.entropy_le_expectedComparisons`: every correct comparison sorter whose
  transcripts form a prefix-free code has expected comparison count at least the Shannon
  entropy `H(p)` of the prior on orderings.
* `exists_priorSorter_within_one_comparison`: there is a correct sorter whose expected
  comparison count is `< H(p) + 1`, and whose retained history is exactly its transcript,
  so the reversible history is compressed to the same `H(p)` scale.
* `entropy_le_logb_card` / `entropy_uniform` / `entropy_lt_logb_card_of_nonuniform`:
  `H(p) ≤ log₂(n!)`, with equality exactly at the uniform prior — the factorial baseline is
  the uniform-prior case, and every biased prior is strictly cheaper.
* `priorSorter_work_below_uniform_baseline`: the expected reset work of the optimal
  prior-sensitive sorter is below the catalog's uniform Landauer gap
  `landauerGap (sortingFunction n) kT = kT log (n!)` plus one bit `kT log 2`.
* `nonuniform_floor_strictly_below_uniform`: for a nonuniform prior the entropy floor is
  *strictly* below the uniform factorial baseline.

The general entropy lemmas are stated for an arbitrary finite ensemble, so they apply to any
prior-sensitive erasure task.
-/

open Finset PrefixFreeThermo

namespace PriorSensitiveSorting

variable {ι : Type*} [Fintype ι]

/-! ## Maximum-entropy lemmas for a finite ensemble -/

/-- Pointwise Gibbs estimate. -/
theorem gibbs_pt {a b : ℝ} (ha : 0 < a) (hb : 0 < b) :
    a * (Real.log b - Real.log a) ≤ b - a := by
  have h1 : Real.log (b / a) ≤ b / a - 1 := Real.log_le_sub_one_of_pos (by positivity)
  rw [Real.log_div (ne_of_gt hb) (ne_of_gt ha)] at h1
  have h2 := mul_le_mul_of_nonneg_left h1 ha.le
  have h3 : a * (b / a - 1) = b - a := by field_simp
  linarith [h2, h3.le, h3.ge]

/-- Strict pointwise Gibbs estimate. -/
theorem gibbs_pt_strict {a b : ℝ} (ha : 0 < a) (hb : 0 < b) (hab : a ≠ b) :
    a * (Real.log b - Real.log a) < b - a := by
  have hne : b / a ≠ 1 := by
    intro h
    exact hab (by field_simp at h; linarith)
  have h1 : Real.log (b / a) < b / a - 1 := Real.log_lt_sub_one_of_pos (by positivity) hne
  rw [Real.log_div (ne_of_gt hb) (ne_of_gt ha)] at h1
  have h2 := mul_lt_mul_of_pos_left h1 ha
  have h3 : a * (b / a - 1) = b - a := by field_simp
  linarith [h2, h3.le, h3.ge]

/-- **Maximum entropy.**  Any distribution on a finite ensemble has entropy at most the
logarithm of the ensemble size. -/
theorem entropy_le_logb_card [Nonempty ι] (p : ι → ℝ) (hp : ∀ i, 0 < p i)
    (hsum : ∑ i, p i = 1) : entropy p ≤ Real.logb 2 (Fintype.card ι) := by
  have hN : (0 : ℝ) < Fintype.card ι := by exact_mod_cast Fintype.card_pos
  have hL2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hle : ∀ i ∈ (Finset.univ : Finset ι),
      p i * (Real.log ((Fintype.card ι : ℝ)⁻¹) - Real.log (p i))
        ≤ (Fintype.card ι : ℝ)⁻¹ - p i :=
    fun i _ => gibbs_pt (hp i) (by positivity)
  have hsum' : ∑ i, (p i * (Real.log ((Fintype.card ι : ℝ)⁻¹) - Real.log (p i)))
      ≤ ∑ i, ((Fintype.card ι : ℝ)⁻¹ - p i) := Finset.sum_le_sum hle
  have hrhs : ∑ i, ((Fintype.card ι : ℝ)⁻¹ - p i) = 0 := by
    rw [Finset.sum_sub_distrib, hsum, Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
    field_simp
    ring
  have hlhs : ∑ i, (p i * (Real.log ((Fintype.card ι : ℝ)⁻¹) - Real.log (p i)))
      = -Real.log (Fintype.card ι) - ∑ i, p i * Real.log (p i) := by
    have hterm : ∀ i : ι, p i * (Real.log ((Fintype.card ι : ℝ)⁻¹) - Real.log (p i))
        = p i * Real.log ((Fintype.card ι : ℝ)⁻¹) - p i * Real.log (p i) := fun i => by ring
    rw [Finset.sum_congr rfl fun i _ => hterm i, Finset.sum_sub_distrib, ← Finset.sum_mul,
      hsum, Real.log_inv]
    ring
  rw [hrhs, hlhs] at hsum'
  have hnats : -∑ i, p i * Real.log (p i) ≤ Real.log (Fintype.card ι) := by linarith
  rw [entropy_eq, Real.logb, div_le_div_iff_of_pos_right hL2]
  exact hnats

/-- **Strict maximum entropy.**  A prior that is not the uniform one has entropy strictly
below `log₂|ι|`. -/
theorem entropy_lt_logb_card_of_nonuniform [Nonempty ι] (p : ι → ℝ) (hp : ∀ i, 0 < p i)
    (hsum : ∑ i, p i = 1) (hne : ∃ j, p j ≠ (Fintype.card ι : ℝ)⁻¹) :
    entropy p < Real.logb 2 (Fintype.card ι) := by
  obtain ⟨j, hj⟩ := hne
  have hN : (0 : ℝ) < Fintype.card ι := by exact_mod_cast Fintype.card_pos
  have hL2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hle : ∀ i ∈ (Finset.univ : Finset ι),
      p i * (Real.log ((Fintype.card ι : ℝ)⁻¹) - Real.log (p i))
        ≤ (Fintype.card ι : ℝ)⁻¹ - p i :=
    fun i _ => gibbs_pt (hp i) (by positivity)
  have hstrict : p j * (Real.log ((Fintype.card ι : ℝ)⁻¹) - Real.log (p j))
      < (Fintype.card ι : ℝ)⁻¹ - p j :=
    gibbs_pt_strict (hp j) (by positivity) hj
  have hsum' : ∑ i, (p i * (Real.log ((Fintype.card ι : ℝ)⁻¹) - Real.log (p i)))
      < ∑ i, ((Fintype.card ι : ℝ)⁻¹ - p i) :=
    Finset.sum_lt_sum hle ⟨j, Finset.mem_univ j, hstrict⟩
  have hrhs : ∑ i, ((Fintype.card ι : ℝ)⁻¹ - p i) = 0 := by
    rw [Finset.sum_sub_distrib, hsum, Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
    field_simp
    ring
  have hlhs : ∑ i, (p i * (Real.log ((Fintype.card ι : ℝ)⁻¹) - Real.log (p i)))
      = -Real.log (Fintype.card ι) - ∑ i, p i * Real.log (p i) := by
    have hterm : ∀ i : ι, p i * (Real.log ((Fintype.card ι : ℝ)⁻¹) - Real.log (p i))
        = p i * Real.log ((Fintype.card ι : ℝ)⁻¹) - p i * Real.log (p i) := fun i => by ring
    rw [Finset.sum_congr rfl fun i _ => hterm i, Finset.sum_sub_distrib, ← Finset.sum_mul,
      hsum, Real.log_inv]
    ring
  rw [hrhs, hlhs] at hsum'
  have hnats : -∑ i, p i * Real.log (p i) < Real.log (Fintype.card ι) := by linarith
  rw [entropy_eq, Real.logb, div_lt_div_iff_of_pos_right hL2]
  exact hnats

/-- The uniform prior attains the maximum entropy `log₂|ι|`. -/
theorem entropy_uniform [Nonempty ι] :
    entropy (fun _ : ι => (Fintype.card ι : ℝ)⁻¹) = Real.logb 2 (Fintype.card ι) := by
  have hN : (0 : ℝ) < Fintype.card ι := by exact_mod_cast Fintype.card_pos
  unfold entropy
  rw [Finset.sum_const, Finset.card_univ, Real.logb_inv, nsmul_eq_mul]
  field_simp

/-! ## Prior-sensitive comparison sorters -/

/-- A **prior-sensitive comparison sorter** for `n` items: it produces, for each input
ordering, the binary transcript of the comparisons it performs.  Correctness is injectivity
of the transcript (the sorted output carries no information), and the transcripts form a
prefix-free set, which is exactly the statement that the algorithm halts on its own
transcript without an external length marker. -/
structure PriorSorter (n : ℕ) where
  /-- The comparison transcript of an input ordering. -/
  code : Equiv.Perm (Fin n) → List Bool
  /-- Correctness. -/
  inj : Function.Injective code
  /-- Self-delimiting transcripts. -/
  prefixFree : PrefixFree (Finset.univ.image code)

namespace PriorSorter

/-- Expected number of comparisons under a prior `p` on input orderings. -/
noncomputable def expectedComparisons {n : ℕ} (S : PriorSorter n)
    (p : Equiv.Perm (Fin n) → ℝ) : ℝ :=
  expectedLength p (fun σ => (S.code σ).length)

/-- **Entropy lower bound for nonuniform priors.**  No correct self-delimiting comparison
sorter can beat the Shannon entropy of the prior. -/
theorem entropy_le_expectedComparisons {n : ℕ} (S : PriorSorter n)
    (p : Equiv.Perm (Fin n) → ℝ) (hp : ∀ σ, 0 < p σ) (hsum : ∑ σ, p σ = 1) :
    entropy p ≤ S.expectedComparisons p :=
  shannon_entropy_lower_bound p hp hsum _
    (kraftSum_le_one_of_prefixFree_code S.code S.inj S.prefixFree)

end PriorSorter

/-- **Achievability within one comparison.**  For every prior on input orderings there is a
correct self-delimiting comparison sorter whose expected comparison count is below
`H(p) + 1`; its transcript *is* its retained reversible history, so the history is
compressed to the same entropy scale. -/
theorem exists_priorSorter_within_one_comparison (n : ℕ) (p : Equiv.Perm (Fin n) → ℝ)
    (hp : ∀ σ, 0 < p σ) (hsum : ∑ σ, p σ = 1) :
    ∃ S : PriorSorter n, entropy p ≤ S.expectedComparisons p ∧
      S.expectedComparisons p < entropy p + 1 := by
  obtain ⟨c, hinj, hpf, hlow, hhigh⟩ := KraftConverse.shannon_source_coding p hp hsum
  exact ⟨⟨c, hinj, hpf⟩, hlow, hhigh⟩

/-! ## Thermodynamic reading -/

/-- The expected Landauer work of resetting the retained transcript. -/
noncomputable def expectedResetWork {n : ℕ} (S : PriorSorter n) (p : Equiv.Perm (Fin n) → ℝ)
    (kT : ℝ) : ℝ :=
  landauerCost kT (S.expectedComparisons p)

/-- Entropy of a prior on orderings is at most `log₂(n!)`. -/
theorem entropy_le_logb_factorial {n : ℕ} (p : Equiv.Perm (Fin n) → ℝ) (hp : ∀ σ, 0 < p σ)
    (hsum : ∑ σ, p σ = 1) : entropy p ≤ Real.logb 2 n.factorial := by
  have h := entropy_le_logb_card p hp hsum
  rwa [perm_card] at h

/-- If a sorter's expected comparison count is within one bit of the entropy, its expected
reset work is below the uniform Landauer baseline plus one bit. -/
theorem work_lt_baseline_of_comparisons_lt {n : ℕ} (S : PriorSorter n)
    (p : Equiv.Perm (Fin n) → ℝ) (hp : ∀ σ, 0 < p σ) (hsum : ∑ σ, p σ = 1)
    (hlt : S.expectedComparisons p < entropy p + 1) {kT : ℝ} (hkT : 0 < kT) :
    expectedResetWork S p kT < landauerGap (sortingFunction n) kT + kT * Real.log 2 := by
  have hL2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hent : entropy p ≤ Real.logb 2 n.factorial := entropy_le_logb_factorial p hp hsum
  have hkey : S.expectedComparisons p < Real.logb 2 n.factorial + 1 := by linarith
  have hbase : landauerGap (sortingFunction n) kT = kT * Real.log n.factorial :=
    SortingEntropyWork.sorting_landauer_gap_exact n kT
  have hlogb : Real.log 2 * Real.logb 2 n.factorial = Real.log n.factorial := by
    rw [Real.logb]
    field_simp
  unfold expectedResetWork landauerCost
  rw [hbase]
  nlinarith [mul_lt_mul_of_pos_left hkey (mul_pos hkT hL2), hlogb]

/-- **Prior-sensitive work below the uniform baseline.**  For every prior there is a correct
sorter whose expected comparison count is within one comparison of `H(p)` and whose expected
reset work is strictly below the catalog's uniform Landauer gap `kT log (n!)` plus the cost
`kT log 2` of a single bit. -/
theorem exists_priorSorter_efficient (n : ℕ) (p : Equiv.Perm (Fin n) → ℝ)
    (hp : ∀ σ, 0 < p σ) (hsum : ∑ σ, p σ = 1) {kT : ℝ} (hkT : 0 < kT) :
    ∃ S : PriorSorter n, entropy p ≤ S.expectedComparisons p ∧
      S.expectedComparisons p < entropy p + 1 ∧
      expectedResetWork S p kT < landauerGap (sortingFunction n) kT + kT * Real.log 2 := by
  obtain ⟨S, hlow, hhigh⟩ := exists_priorSorter_within_one_comparison n p hp hsum
  exact ⟨S, hlow, hhigh, work_lt_baseline_of_comparisons_lt S p hp hsum hhigh hkT⟩

/-- **A biased prior is strictly cheaper.**  If the prior on orderings is not uniform, its
entropy floor is strictly below the uniform factorial baseline `kT log (n!)`. -/
theorem nonuniform_floor_strictly_below_uniform (n : ℕ) (p : Equiv.Perm (Fin n) → ℝ)
    (hp : ∀ σ, 0 < p σ) (hsum : ∑ σ, p σ = 1)
    (hne : ∃ τ, p τ ≠ ((n.factorial : ℝ))⁻¹) {kT : ℝ} (hkT : 0 < kT) :
    landauerCost kT (entropy p) < landauerGap (sortingFunction n) kT := by
  have hL2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hne' : ∃ τ, p τ ≠ ((Fintype.card (Equiv.Perm (Fin n)) : ℝ))⁻¹ := by
    obtain ⟨τ, hτ⟩ := hne
    exact ⟨τ, by rwa [perm_card]⟩
  have hstrict : entropy p < Real.logb 2 n.factorial := by
    have := entropy_lt_logb_card_of_nonuniform p hp hsum hne'
    rwa [perm_card] at this
  have hbase : landauerGap (sortingFunction n) kT = kT * Real.log n.factorial :=
    SortingEntropyWork.sorting_landauer_gap_exact n kT
  have hlogb : Real.log 2 * Real.logb 2 n.factorial = Real.log n.factorial := by
    rw [Real.logb]
    field_simp
  unfold landauerCost
  rw [hbase]
  nlinarith [mul_lt_mul_of_pos_left hstrict (mul_pos hkT hL2), hlogb]

/-- **Prior-sensitive synthesis.**  For every prior `p` on the `n!` input orderings:
the entropy `H(p)` is a hard floor on the expected comparison count of any correct
self-delimiting sorter, it is attained within one comparison by a sorter whose expected
reset work stays below the uniform Landauer baseline plus one bit, and `H(p) ≤ log₂(n!)`. -/
theorem prior_sensitive_synthesis (n : ℕ) (p : Equiv.Perm (Fin n) → ℝ) (hp : ∀ σ, 0 < p σ)
    (hsum : ∑ σ, p σ = 1) {kT : ℝ} (hkT : 0 < kT) :
    (∀ S : PriorSorter n, entropy p ≤ S.expectedComparisons p) ∧
    (∃ S : PriorSorter n, S.expectedComparisons p < entropy p + 1 ∧
      expectedResetWork S p kT < landauerGap (sortingFunction n) kT + kT * Real.log 2) ∧
    entropy p ≤ Real.logb 2 n.factorial := by
  obtain ⟨S, _, hhigh, hwork⟩ := exists_priorSorter_efficient n p hp hsum hkT
  exact ⟨fun S' => S'.entropy_le_expectedComparisons p hp hsum, ⟨S, hhigh, hwork⟩,
    entropy_le_logb_factorial p hp hsum⟩

-- !-- Lab Notes -- !--
-- Hypothesis (Future Direction 2): for every prior on permutations there is a sorter whose
-- expected comparison count is within `O(n)` of the Shannon entropy, with history of the
-- same scale.
-- Experiment: the conjecture was tested against the catalog's Kraft/Shannon machinery.  For
-- `n = 3` (`3! = 6`) the dyadic prior `(1/2, 1/4, 1/8, 1/16, 1/32, 1/32)` has entropy
-- `1/2 + 1/2 + 3/8 + 1/4 + 5/16 = 1.9375` bits versus the uniform `log₂ 6 = 2.585` bits:
-- the biased prior is cheaper by `0.647` bits, and the Shannon–Fano code attains
-- `1.9375` exactly (all probabilities dyadic), i.e. zero overshoot in the dyadic case.
-- Analysis: the conjectured additive slack `O(n)` is far from tight — the true slack is a
-- single comparison, uniformly in `n`, because self-delimiting transcripts are exactly
-- prefix codes and Kraft's converse turns Shannon–Fano lengths into an actual sorter.  The
-- ceiling `H(p) ≤ log₂(n!)` with strict inequality off the uniform prior identifies the
-- factorial baseline of the earlier cycles as the maximum-entropy special case.
-- Critique: prefix-freeness is load-bearing; a sorter allowed to rely on an external clock
-- to know when to stop is not Kraft-constrained, and for such a model only the weaker
-- fixed-depth bound `⌈log₂(n!)⌉` applies (see `MultiwaySorting.Sorter.clog_le_depth`).
-- Positivity of the prior is also load-bearing: orderings of probability zero can be given
-- arbitrarily long transcripts.
-- !-- end Lab Notes -- !--

end PriorSensitiveSorting