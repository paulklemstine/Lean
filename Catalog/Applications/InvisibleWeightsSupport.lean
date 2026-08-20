/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Mathlib
import Applications.InvisibleWeightVectors
import Applications.PowerSumInversion

/-!
# How wide must an invisible vector be?  The sharp support bound `K + 1`

The structure theorem of `Applications/InvisibleWeightVectors.lean` says every vector
invisible to the power-sum window `k < K` is a combination of shifted binomial vectors.
Each of those uses exactly `K + 1` nodes.  This file proves that no invisible vector can do
better:

* `card_nodeSupport_ge` — **a nonzero vector invisible to the window `k < K` is supported on
  at least `K + 1` nodes.**  The proof is a second, sparse, application of the Lagrange
  engine: if the support `S` had at most `K` nodes, the Lagrange basis polynomials *of `S`*
  have degree `< #S ≤ K`, so the window already sees them, and the vector must vanish.
* `card_nodeSupport_binWeight` — the shifted binomial vectors attain the bound exactly, so
  `K + 1` is sharp for every `K` and every admissible shift.
* `nearMiss_card_add_card_ge` — the multiset consequence: any near miss at window `K` uses
  at least `K + 1` elements in total.
* `l1_ge_of_invisible_int` — the integral `ℓ¹` consequence `∑_j |e j| ≥ K + 1`.

-- !-- Lab Notes -- !--

HYPOTHESIS (Hypothesizer).  Sparsity should be obstructed by the window: a vector living on
`m` nodes is determined by `m` moments (Vandermonde on those nodes), so `m ≤ K` invisible
forces `0`.  Hence `m ≥ K + 1`, and the shifted binomial vectors show this is attained.
Bolder companion conjecture: the `ℓ¹` bound should be `2^K`, not merely `K + 1`.  (This
companion conjecture has since been **refuted** — see `two_pow_l1_conjecture_false` in
`Applications/InvisibleWeightsL1.lean`, which produces invisible vectors of norm
`≤ 3 · 2^{K-1}` for every `K ≥ 3`, and `l1_ge_two_pow_of_window_le_two`, which shows the
conjecture is nevertheless true for `K ≤ 2`.)

EXPERIMENT (Experimenter).  `card_nodeSupport_ge` proved below via
`PowerSumInversion.nodeInv_delta`, the Lagrange inversion over an arbitrary finite node set
of a field, applied to the image of the support in `ℚ`.  The `2^K` strengthening resisted
all attempts and is *not* claimed here; what is proved is the sharp *support* bound and the
consequent `ℓ¹` bound `K + 1`.  A later cycle explained the resistance: the strengthening is
false from `K = 3` on.

ANALYSIS (Analyst).  Two different Lagrange arguments now bound the same object from two
sides: the dense one (nodes `0,…,N`) gives the dimension `N + 1 - K`, the sparse one (nodes
= the support) gives the width `≥ K + 1`.  The extremal vectors for the width bound are
exactly the basis vectors of the dimension count — the structure theory is internally
consistent and tight at both ends.

CRITIQUE (Critic).  The nonvacuity hypothesis is essential and explicit (`hne`): the zero
vector is invisible with empty support.  `card_nodeSupport_binWeight` needs `i + K ≤ N` so
that the whole vector fits inside the window of nodes; otherwise its support is truncated.
-/

open Finset

namespace InvisibleWeights

/-- The set of nodes in `{0,…,N}` where the weight vector is nonzero. -/
noncomputable def nodeSupport (N : ℕ) (e : ℕ → ℚ) : Finset ℕ :=
  (range (N + 1)).filter fun j => e j ≠ 0

lemma mem_nodeSupport {N : ℕ} {e : ℕ → ℚ} {j : ℕ} :
    j ∈ nodeSupport N e ↔ j ≤ N ∧ e j ≠ 0 := by
  simp [nodeSupport]

lemma nodeSupport_subset (N : ℕ) (e : ℕ → ℚ) : nodeSupport N e ⊆ range (N + 1) :=
  Finset.filter_subset _ _

/-- Moments only see the support. -/
lemma moment_eq_sum_nodeSupport (N : ℕ) (e : ℕ → ℚ) (k : ℕ) :
    moment N e k = ∑ j ∈ nodeSupport N e, e j * (j : ℚ) ^ k := by
  rw [moment]
  refine (Finset.sum_subset (nodeSupport_subset N e) ?_).symm
  intro j hj hj'
  have hz : e j = 0 := by
    by_contra hc
    exact hj' (mem_nodeSupport.mpr ⟨Nat.lt_succ_iff.mp (mem_range.mp hj), hc⟩)
  rw [hz, zero_mul]

/-- **Sharp width bound.**  A nonzero weight vector invisible to the window `k < K` occupies
at least `K + 1` nodes.  (Sparse Lagrange: a vector on `m ≤ K` nodes is already pinned down
by the moments `p_0, …, p_{m-1}`.) -/
theorem card_nodeSupport_ge {N K : ℕ} {e : ℕ → ℚ} (he : Invisible N K e)
    {j₀ : ℕ} (hj₀ : j₀ ≤ N) (hne : e j₀ ≠ 0) :
    K + 1 ≤ (nodeSupport N e).card := by
  classical
  by_contra hcon
  push_neg at hcon
  set S : Finset ℕ := nodeSupport N e with hS
  set T : Finset ℚ := S.image (fun n : ℕ => (n : ℚ)) with hT
  have hcardT : T.card = S.card :=
    Finset.card_image_of_injective _ (fun a b hab => Nat.cast_injective hab)
  have hmem : j₀ ∈ S := mem_nodeSupport.mpr ⟨hj₀, hne⟩
  have hmemT : ((j₀ : ℚ)) ∈ T := Finset.mem_image_of_mem _ hmem
  -- the moments below `#S` all vanish, because `#S ≤ K`
  have hmom : ∀ k < T.card, ∑ j ∈ S, e j * (j : ℚ) ^ k = 0 := by
    intro k hk
    rw [← moment_eq_sum_nodeSupport]
    exact he k (by omega)
  -- Lagrange inversion over the sparse node set `T`
  have hkey : e j₀ = 0 := by
    have hdelta : ∀ j ∈ S, ∑ k ∈ range T.card,
        PowerSumInversion.nodeInv T (j₀ : ℚ) k * (j : ℚ) ^ k = if j = j₀ then 1 else 0 := by
      intro j hj
      have := PowerSumInversion.nodeInv_delta (S := T) (v := (j₀ : ℚ)) (j := (j : ℚ)) hmemT
        (Finset.mem_image_of_mem _ hj)
      rw [this]
      by_cases hjj : j = j₀
      · rw [if_pos hjj, if_pos (by rw [hjj])]
      · rw [if_neg hjj, if_neg (fun hc => hjj (Nat.cast_injective hc))]
    have hstep : ∑ j ∈ S, e j * (if j = j₀ then 1 else 0) = e j₀ := by
      simp [Finset.sum_ite_eq', hmem]
    calc e j₀ = ∑ j ∈ S, e j * (if j = j₀ then 1 else 0) := hstep.symm
      _ = ∑ j ∈ S, ∑ k ∈ range T.card,
            (PowerSumInversion.nodeInv T (j₀ : ℚ) k * (j : ℚ) ^ k) * e j := by
          refine Finset.sum_congr rfl fun j hj => ?_
          rw [← hdelta j hj, Finset.mul_sum]
          exact Finset.sum_congr rfl fun k _ => by ring
      _ = ∑ k ∈ range T.card, ∑ j ∈ S,
            (PowerSumInversion.nodeInv T (j₀ : ℚ) k * (j : ℚ) ^ k) * e j := Finset.sum_comm
      _ = ∑ k ∈ range T.card, PowerSumInversion.nodeInv T (j₀ : ℚ) k
            * ∑ j ∈ S, e j * (j : ℚ) ^ k := by
          refine Finset.sum_congr rfl fun k _ => ?_
          rw [Finset.mul_sum]
          exact Finset.sum_congr rfl fun j _ => by ring
      _ = 0 := by
          refine Finset.sum_eq_zero fun k hk => ?_
          rw [hmom k (mem_range.mp hk), mul_zero]
  exact hne hkey

/-- The support of a shifted binomial vector is the full interval `[i, i+K]`. -/
theorem card_nodeSupport_binWeight {N K i : ℕ} (h : i + K ≤ N) :
    (nodeSupport N (binWeight (R := ℚ) K i)).card = K + 1 := by
  classical
  have hset : nodeSupport N (binWeight (R := ℚ) K i) = Finset.Icc i (i + K) := by
    ext j
    rw [mem_nodeSupport, Finset.mem_Icc]
    constructor
    · rintro ⟨-, hne⟩
      by_contra hc
      rcases Nat.lt_or_ge j i with hji | hji
      · exact hne (binWeight_of_lt hji)
      · exact hne (binWeight_of_gt (by omega))
    · rintro ⟨h1, h2⟩
      refine ⟨by omega, ?_⟩
      rw [binWeight, if_pos ⟨h1, h2⟩]
      have hchoose : (K.choose (j - i) : ℚ) ≠ 0 := by
        have : 0 < K.choose (j - i) := Nat.choose_pos (by omega)
        positivity
      exact mul_ne_zero (pow_ne_zero _ (by norm_num)) hchoose
  rw [hset, Nat.card_Icc]
  omega

/-- The bound `K + 1` is attained, hence sharp, for every window length. -/
theorem card_nodeSupport_bound_sharp (K : ℕ) :
    ∃ (N : ℕ) (e : ℕ → ℚ) (j₀ : ℕ), j₀ ≤ N ∧ e j₀ ≠ 0 ∧ Invisible N K e ∧
      (nodeSupport N e).card = K + 1 := by
  refine ⟨K, binWeight K 0, K, le_rfl, ?_, binWeight_invisible (by omega), ?_⟩
  · have : binWeight (R := ℚ) K 0 (0 + K) = 1 := binWeight_top K 0
    rw [zero_add] at this
    rw [this]
    norm_num
  · exact card_nodeSupport_binWeight (by omega)

/-! ## Integral consequences -/

/-- `ℓ¹` bound: a nonzero *integral* invisible vector has `∑_j |e j| ≥ K + 1`, since each of
its at least `K + 1` nonzero entries has absolute value at least `1`. -/
theorem l1_ge_of_invisible_int {N K : ℕ} {e : ℕ → ℤ} (he : Invisible N K e)
    {j₀ : ℕ} (hj₀ : j₀ ≤ N) (hne : e j₀ ≠ 0) :
    ((K : ℤ) + 1) ≤ ∑ j ∈ range (N + 1), |e j| := by
  classical
  set f : ℕ → ℚ := fun j => (e j : ℚ) with hf
  have hfinv : Invisible N K f := by
    intro k hk
    have := congrArg (fun z : ℤ => (z : ℚ)) (he k hk)
    simpa [moment, hf] using this
  have hfne : f j₀ ≠ 0 := by
    simp only [hf, ne_eq, Rat.intCast_eq_zero_iff]
    exact hne
  have hcard := card_nodeSupport_ge hfinv hj₀ hfne
  have hsub : nodeSupport N f ⊆ range (N + 1) := nodeSupport_subset N f
  have hone : ∀ j ∈ nodeSupport N f, (1 : ℤ) ≤ |e j| := by
    intro j hj
    have := (mem_nodeSupport.mp hj).2
    have hz : e j ≠ 0 := by
      intro hc
      exact this (by simp [hf, hc])
    exact Int.one_le_abs hz
  calc ((K : ℤ) + 1) ≤ ((nodeSupport N f).card : ℤ) := by exact_mod_cast hcard
    _ = ∑ j ∈ nodeSupport N f, (1 : ℤ) := by simp
    _ ≤ ∑ j ∈ nodeSupport N f, |e j| := Finset.sum_le_sum hone
    _ ≤ ∑ j ∈ range (N + 1), |e j| :=
        Finset.sum_le_sum_of_subset_of_nonneg hsub (fun j _ _ => abs_nonneg _)

lemma card_eq_sum_count {N : ℕ} {s : Multiset ℕ} (hs : ∀ x ∈ s, x ≤ N) :
    (Multiset.card s : ℤ) = ∑ j ∈ range (N + 1), (s.count j : ℤ) := by
  classical
  have hsub : s.toFinset ⊆ range (N + 1) := by
    intro j hj
    exact mem_range.mpr (by have := hs j (Multiset.mem_toFinset.mp hj); omega)
  have hcount : (Multiset.card s : ℤ) = ∑ j ∈ s.toFinset, (s.count j : ℤ) := by
    have := Multiset.toFinset_sum_count_eq s
    exact_mod_cast congrArg (fun n : ℕ => (n : ℤ)) this.symm
  rw [hcount]
  refine Finset.sum_subset (f := fun j => (s.count j : ℤ)) hsub ?_
  intro j _ hj
  have hz : s.count j = 0 := Multiset.count_eq_zero.mpr fun hc =>
    hj (Multiset.mem_toFinset.mpr hc)
  simp [hz]

/-- **Near misses are big.**  Two distinct multisets bounded by `N` with identical power
sums throughout the window `k < K` have at least `K + 1` elements in total.  (The catalog's
`two_pow_le_two_mul_card_of_near_miss` gives the stronger `2^N` at the sharp window `K = N`;
the present bound holds for *every* window and is sharp in the support count.) -/
theorem nearMiss_card_add_card_ge {N K : ℕ} {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x ≤ N) (ht : ∀ x ∈ t, x ≤ N)
    (h : ∀ k < K, PowerSumSharpness.powerSum s k = PowerSumSharpness.powerSum t k)
    {j₀ : ℕ} (hj₀ : j₀ ≤ N) (hne : s.count j₀ ≠ t.count j₀) :
    (K : ℤ) + 1 ≤ (Multiset.card s : ℤ) + (Multiset.card t : ℤ) := by
  classical
  set e : ℕ → ℤ := fun j => (s.count j : ℤ) - (t.count j : ℤ) with he
  have hinv : Invisible N K e := invisible_of_nearMiss hs ht h
  have hne' : e j₀ ≠ 0 := by
    simp only [he, sub_ne_zero]
    exact_mod_cast hne
  have hl1 := l1_ge_of_invisible_int hinv hj₀ hne'
  have hbound : ∑ j ∈ range (N + 1), |e j|
      ≤ ∑ j ∈ range (N + 1), ((s.count j : ℤ) + (t.count j : ℤ)) := by
    refine Finset.sum_le_sum fun j _ => ?_
    simp only [he]
    have h1 : (0 : ℤ) ≤ (s.count j : ℤ) := Int.natCast_nonneg _
    have h2 : (0 : ℤ) ≤ (t.count j : ℤ) := Int.natCast_nonneg _
    rcases abs_cases ((s.count j : ℤ) - (t.count j : ℤ)) with ⟨h3, -⟩ | ⟨h3, -⟩ <;> omega
  rw [Finset.sum_add_distrib, ← card_eq_sum_count hs, ← card_eq_sum_count ht] at hbound
  omega


/-! ## Parity refinement and the Prouhet–Tarry–Escott connection -/

/-- The `ℓ¹` norm of an invisible integral vector is even, because its zeroth moment (the
signed total) vanishes. -/
theorem l1_even_of_invisible_int {N K : ℕ} (hK : 1 ≤ K) {e : ℕ → ℤ} (he : Invisible N K e) :
    (2 : ℤ) ∣ ∑ j ∈ range (N + 1), |e j| := by
  have h0 : ∑ j ∈ range (N + 1), e j = 0 := by
    have := he 0 hK
    simpa [moment] using this
  have hsplit : ∑ j ∈ range (N + 1), |e j|
      = ∑ j ∈ range (N + 1), e j + 2 * ∑ j ∈ range (N + 1), max (-e j) 0 := by
    rw [Finset.mul_sum, ← Finset.sum_add_distrib]
    refine Finset.sum_congr rfl fun j _ => ?_
    rcases le_or_gt 0 (e j) with h | h
    · rw [abs_of_nonneg h, max_eq_right (by omega)]
      ring
    · rw [abs_of_neg h, max_eq_left (by omega)]
      ring
  rw [hsplit, h0, zero_add]
  exact ⟨_, rfl⟩

/-- **Parity-refined width bound.**  For an even window length `K ≥ 1` the `ℓ¹` bound
improves from `K + 1` to `K + 2`, since the norm is even. -/
theorem l1_ge_of_invisible_int_even {N K : ℕ} (hK : 1 ≤ K) (hKeven : Even K) {e : ℕ → ℤ}
    (he : Invisible N K e) {j₀ : ℕ} (hj₀ : j₀ ≤ N) (hne : e j₀ ≠ 0) :
    ((K : ℤ) + 2) ≤ ∑ j ∈ range (N + 1), |e j| := by
  obtain ⟨c, hc⟩ := l1_even_of_invisible_int hK he
  have h1 := l1_ge_of_invisible_int he hj₀ hne
  obtain ⟨m, hm⟩ := hKeven
  have hKm : (K : ℤ) = 2 * m := by exact_mod_cast (by omega : K = 2 * m)
  omega

/-- The zeroth power sum of a multiset is its cardinality. -/
lemma powerSum_zero_eq_card (u : Multiset ℕ) :
    PowerSumSharpness.powerSum u 0 = (Multiset.card u : ℤ) := by
  simp [PowerSumSharpness.powerSum, Multiset.map_const', Multiset.sum_replicate]

/-- A near miss has equal cardinalities on both sides (the `k = 0` moment). -/
theorem nearMiss_card_eq {K : ℕ} (hK : 1 ≤ K) {s t : Multiset ℕ}
    (h : ∀ k < K, PowerSumSharpness.powerSum s k = PowerSumSharpness.powerSum t k) :
    Multiset.card s = Multiset.card t := by
  have h0 := h 0 hK
  rw [powerSum_zero_eq_card, powerSum_zero_eq_card] at h0
  exact_mod_cast h0

/-- **Each side of a near miss is large.**  At window `K` both multisets have at least
`(K + 1)/2` elements.  This is the classical size bound for the Prouhet–Tarry–Escott
problem, whose ideal solutions correspond to the case `2 · card = 2K`; the conjecture that
`2K` is always attainable is open and recorded in `FUTURE_DIRECTIONS.md`. -/
theorem nearMiss_two_mul_card_ge {N K : ℕ} (hK : 1 ≤ K) {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x ≤ N) (ht : ∀ x ∈ t, x ≤ N)
    (h : ∀ k < K, PowerSumSharpness.powerSum s k = PowerSumSharpness.powerSum t k)
    {j₀ : ℕ} (hj₀ : j₀ ≤ N) (hne : s.count j₀ ≠ t.count j₀) :
    (K : ℤ) + 1 ≤ 2 * (Multiset.card s : ℤ) := by
  have hcard := nearMiss_card_eq hK h
  have := nearMiss_card_add_card_ge hs ht h hj₀ hne
  rw [hcard] at this ⊢
  omega

end InvisibleWeights