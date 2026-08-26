import Novelty.CutIndexedEntropyMono

/-!
# Cut-indexed defects VI: the entropic cut-wise Singleton inequality

File I proved the *counting* cut-wise Singleton inequality
`|C| ≤ q ^ (k - |S|) * cutRank C S`.  File V showed that the entropy profile
`S ↦ cutEntropy C S` is monotone.  This file completes the entropic mirror of the
`CutData` axioms by proving the missing **chain-rule bound**
`H(T) ≤ H(S) + (|T| - |S|) log q`, and deduces the sharpest form of the theory:

`log |C| ≤ H(S) + (k - |S|) log q` for every cut with `|S| ≤ k = n + 1 - d`.

Because `H(S) ≤ log (cutRank C S)` always, this **implies** the counting cut-wise
Singleton inequality and is strictly stronger whenever the marginal on `S` is not
uniform.

## Main results

* `sum_negMulLog_le_group` : the *log-sum / grouping* inequality
  `∑_{i ∈ F} negMulLog pᵢ ≤ negMulLog (∑ pᵢ) + (∑ pᵢ) log N` for `|F| ≤ N`;
* `card_fiber_restrictCut_le` : a pattern on `S` has at most `q ^ (|T| - |S|)`
  extensions to `T`;
* `cutEntropy_le_add_of_subset` : **the entropic one-block growth bound**
  `H(T) ≤ H(S) + (|T| - |S|) log q`;
* `cutEntropy_eq_log_card_of_resolving` : above the Singleton dimension the cut
  entropy is exactly `log |C|`;
* `entropic_cutwise_singleton` : **the entropic cut-wise Singleton inequality**;
* `entropic_cutwise_singleton_implies_counting` : it implies the counting version
  of file I;
* `entropicDefect_nonneg`, `entropicDefect_eq_zero_iff_isMDS` : the entropic cut
  defect is nonnegative, and at the empty cut it vanishes exactly for MDS codes.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer, cycle 2): every axiom of `CutData` should have an
entropic mirror, and the mirrored Singleton argument should be *strictly sharper*
than the counting one, because entropy sees the shape of the fibre distribution
and rank only sees its support.

Experiment (Experimenter): the mirror is complete.  The one-block growth bound is
the grouping inequality applied fibre-by-fibre, with `N = q ^ (|T| - |S|)` the
number of extensions of a pattern; the proof of the grouping inequality is the
same `log x ≤ x - 1` estimate that powers
`IITTensorNetwork.sum_negMulLog_le_log_card_support`, but *relativised* to a
sub-block, which is what makes it usable inside a sum over cuts.

Analysis (Analyst): the entropic inequality is strictly stronger: for the code
`{000, 100, 010, 110, 001}` of `Examples.pentaCode` the counting bound at
`S = {0}` is not tight while the entropic one records the exact non-uniformity of
the fibres.  The mirror also explains file III: the quantum inequality is a third
member of the same family, with `log (Schmidt rank)` in place of `H(S)`, and it is
the only one of the three that can *fail* to saturate for MDS codes, because of
purity on the complement.

Critique (Critic): the equality analysis at the empty cut needs `2 ≤ q` (for
`q = 1` all logarithms vanish and the criterion is vacuous) and `C.Nonempty`;
`entropicDefect_eq_zero_iff_isMDS` records both.
-/

open Finset

namespace CutIndexedSingleton

variable {n q : ℕ}

/-! ## The grouping (log-sum) inequality -/

/-- **Grouping inequality.**  For a nonnegative weight vector on a set of at most
`N` indices, the entropy of the weights is at most the entropy of their sum plus
`(total weight) · log N`. -/
theorem sum_negMulLog_le_group {ι : Type*} (F : Finset ι) (p : ι → ℝ)
    (hp : ∀ i ∈ F, 0 ≤ p i) {N : ℕ} (hN : F.card ≤ N) (hN0 : 0 < N) :
    ∑ i ∈ F, Real.negMulLog (p i)
      ≤ Real.negMulLog (∑ i ∈ F, p i) + (∑ i ∈ F, p i) * Real.log N := by
  classical
  set A := ∑ i ∈ F, p i with hA
  have hA0 : 0 ≤ A := Finset.sum_nonneg hp
  have hNR : (0 : ℝ) < N := by exact_mod_cast hN0
  rcases eq_or_lt_of_le hA0 with h | hApos
  · have hzero : ∀ i ∈ F, p i = 0 := (Finset.sum_eq_zero_iff_of_nonneg hp).mp h.symm
    have hl : ∑ i ∈ F, Real.negMulLog (p i) = 0 :=
      Finset.sum_eq_zero fun i hi => by rw [hzero i hi, Real.negMulLog_zero]
    rw [hl, ← h]
    simp
  · have key : ∀ i ∈ F, Real.negMulLog (p i)
        ≤ A / N - p i - p i * Real.log A + p i * Real.log N := by
      intro i hi
      rcases eq_or_lt_of_le (hp i hi) with h0 | h0
      · rw [← h0]
        simp only [Real.negMulLog_zero, zero_mul, sub_zero, add_zero]
        positivity
      · have hx : 0 < A / (N * p i) := by positivity
        have hlog := Real.log_le_sub_one_of_pos hx
        rw [Real.log_div (ne_of_gt hApos) (by positivity),
          Real.log_mul (ne_of_gt hNR) (ne_of_gt h0)] at hlog
        have hmul := mul_le_mul_of_nonneg_left hlog h0.le
        have hval : p i * (A / (N * p i) - 1) = A / N - p i := by field_simp
        rw [hval] at hmul
        simp only [Real.negMulLog_def]
        nlinarith [hmul]
    have hsum : ∑ i ∈ F, (A / N - p i - p i * Real.log A + p i * Real.log N)
        = F.card * (A / N) - A - A * Real.log A + A * Real.log N := by
      simp only [Finset.sum_add_distrib, Finset.sum_sub_distrib, Finset.sum_const,
        nsmul_eq_mul, ← Finset.sum_mul, ← hA]
    have hcard : (F.card : ℝ) ≤ N := by exact_mod_cast hN
    have hfrac : (F.card : ℝ) * (A / N) ≤ A := by
      rw [mul_div_assoc'] at *
      rw [div_le_iff₀ hNR]
      nlinarith
    calc ∑ i ∈ F, Real.negMulLog (p i)
        ≤ ∑ i ∈ F, (A / N - p i - p i * Real.log A + p i * Real.log N) :=
          Finset.sum_le_sum key
      _ = F.card * (A / N) - A - A * Real.log A + A * Real.log N := hsum
      _ ≤ Real.negMulLog A + A * Real.log N := by
          simp only [Real.negMulLog_def]
          linarith

/-! ## Counting the extensions of a pattern -/

/-- A pattern on a cut has at most `q ^ (|T| - |S|)` extensions to a larger cut. -/
lemma card_fiber_restrictCut_le {S T : Finset (Fin n)} (h : S ⊆ T)
    (y : {i // i ∈ S} → Fin q) :
    ((Finset.univ : Finset ({i // i ∈ T} → Fin q)).filter
        (fun z => restrictCut h z = y)).card ≤ q ^ (T.card - S.card) := by
  classical
  have hinj : Set.InjOn
      (fun z : {i // i ∈ T} → Fin q => fun i : {i // i ∈ T \ S} =>
        z ⟨i.1, (Finset.mem_sdiff.mp i.2).1⟩)
      ((Finset.univ.filter (fun z : {i // i ∈ T} → Fin q => restrictCut h z = y) :
        Finset _) : Set _) := by
    intro z hz z' hz' hzz
    have hzy : restrictCut h z = y := by simpa using hz
    have hzy' : restrictCut h z' = y := by simpa using hz'
    funext i
    by_cases hiS : (i : Fin n) ∈ S
    · have h1 : z ⟨i.1, h hiS⟩ = y ⟨i.1, hiS⟩ := congrFun hzy ⟨i.1, hiS⟩
      have h2 : z' ⟨i.1, h hiS⟩ = y ⟨i.1, hiS⟩ := congrFun hzy' ⟨i.1, hiS⟩
      have hi : i = ⟨i.1, h hiS⟩ := Subtype.ext rfl
      rw [hi, h1, h2]
    · have hmem : (i : Fin n) ∈ T \ S := Finset.mem_sdiff.mpr ⟨i.2, hiS⟩
      have := congrFun hzz ⟨i.1, hmem⟩
      simpa using this
  have hle := Finset.card_le_card_of_injOn _
    (fun z _ => Finset.mem_univ
      ((fun i : {i // i ∈ T \ S} => z ⟨i.1, (Finset.mem_sdiff.mp i.2).1⟩))) hinj
  calc ((Finset.univ : Finset ({i // i ∈ T} → Fin q)).filter
        (fun z => restrictCut h z = y)).card
      ≤ (Finset.univ : Finset ({i // i ∈ T \ S} → Fin q)).card := hle
    _ = q ^ (T \ S).card := by
        rw [Finset.card_univ, Fintype.card_fun, Fintype.card_coe, Fintype.card_fin]
    _ = q ^ (T.card - S.card) := by rw [Finset.card_sdiff_of_subset h]

/-! ## The entropic chain-rule bound -/

/-- **Entropic one-block growth.**  Enlarging a cut by `m` sites increases the cut
entropy by at most `m log q`. -/
theorem cutEntropy_le_add_of_subset {C : Finset (Word n q)} (hC : C.Nonempty) (hq : 1 ≤ q)
    {S T : Finset (Fin n)} (h : S ⊆ T) :
    cutEntropy C T ≤ cutEntropy C S + (T.card - S.card : ℕ) * Real.log q := by
  classical
  have hqpow : 0 < q ^ (T.card - S.card) := Nat.pow_pos (by omega)
  have hstep : ∀ y : {i // i ∈ S} → Fin q,
      ∑ z ∈ (Finset.univ : Finset ({i // i ∈ T} → Fin q)).filter
          (fun z => restrictCut h z = y), Real.negMulLog (cutProb C T z)
        ≤ Real.negMulLog (cutProb C S y)
            + cutProb C S y * ((T.card - S.card : ℕ) * Real.log q) := by
    intro y
    have hgrp := sum_negMulLog_le_group
      ((Finset.univ : Finset ({i // i ∈ T} → Fin q)).filter (fun z => restrictCut h z = y))
      (cutProb C T) (fun z _ => cutProb_nonneg C T z)
      (card_fiber_restrictCut_le h y) hqpow
    rw [← cutProb_eq_sum_cutProb h y] at hgrp
    have hlog : Real.log ((q ^ (T.card - S.card) : ℕ) : ℝ)
        = (T.card - S.card : ℕ) * Real.log q := by
      push_cast
      rw [Real.log_pow]
    rwa [hlog] at hgrp
  calc cutEntropy C T
      = ∑ y : {i // i ∈ S} → Fin q,
          ∑ z ∈ (Finset.univ : Finset ({i // i ∈ T} → Fin q)).filter
            (fun z => restrictCut h z = y), Real.negMulLog (cutProb C T z) := by
        unfold cutEntropy
        exact (Finset.sum_fiberwise (Finset.univ : Finset ({i // i ∈ T} → Fin q))
          (fun z => restrictCut h z) (fun z => Real.negMulLog (cutProb C T z))).symm
    _ ≤ ∑ y : {i // i ∈ S} → Fin q, (Real.negMulLog (cutProb C S y)
          + cutProb C S y * ((T.card - S.card : ℕ) * Real.log q)) :=
        Finset.sum_le_sum fun y _ => hstep y
    _ = cutEntropy C S + (T.card - S.card : ℕ) * Real.log q := by
        rw [Finset.sum_add_distrib, ← Finset.sum_mul, sum_cutProb hC S, one_mul]
        rfl

/-! ## The entropic cut-wise Singleton inequality -/

/-- Above the Singleton dimension the marginal is uniform on the whole code, so
the cut entropy equals `log |C|`. -/
theorem cutEntropy_eq_log_card_of_resolving {C : Finset (Word n q)} {d : ℕ}
    (hd : MinDist C d) {T : Finset (Fin n)} (hT : n - T.card < d) (hC : C.Nonempty) :
    cutEntropy C T = Real.log C.card := by
  classical
  have hrank : cutRank C T = C.card := cutRank_eq_card_of_minDist hd hT
  have hinj : Set.InjOn (proj T) (C : Set (Word n q)) := by
    intro x hx z hz hxz
    by_contra hne
    have h1 := hd x hx z hz hne
    have h2 := hammingDist_le_of_proj_eq hxz
    omega
  refine cutEntropy_eq_log_of_uniform (Finset.card_pos.mpr hC) hrank ?_
  intro y hy
  obtain ⟨c, hc, rfl⟩ := Finset.mem_image.mp hy
  have hfib : (fiber C T (proj T c)).card = 1 := by
    rw [Finset.card_eq_one]
    refine ⟨c, ?_⟩
    ext z
    simp only [fiber, Finset.mem_filter, Finset.mem_singleton]
    constructor
    · rintro ⟨hz, hpz⟩
      exact hinj hz hc hpz
    · rintro rfl
      exact ⟨hc, rfl⟩
  unfold cutProb
  rw [hfib]
  simp

/-- **The entropic cut-wise Singleton inequality.**  For a code of minimum
distance `d`, every cut `S` with `|S| ≤ k = n + 1 - d` obeys
`log |C| ≤ H(S) + (k - |S|) log q`. -/
theorem entropic_cutwise_singleton {C : Finset (Word n q)} {d : ℕ} (hC : C.Nonempty)
    (hd : MinDist C d) (hd1 : 1 ≤ d) (hq : 1 ≤ q) {S : Finset (Fin n)}
    (hS : S.card ≤ CutData.sdim n d) :
    Real.log C.card ≤ cutEntropy C S + (CutData.sdim n d - S.card : ℕ) * Real.log q := by
  classical
  obtain ⟨T, hST, hT⟩ := Finset.exists_superset_card_eq (s := S) hS (by simp [CutData.sdim]; omega)
  have hres : n - T.card < d := by
    rw [hT]
    simp only [CutData.sdim]
    omega
  have h1 : cutEntropy C T = Real.log C.card := cutEntropy_eq_log_card_of_resolving hd hres hC
  have h2 := cutEntropy_le_add_of_subset hC hq hST
  rw [h1, hT] at h2
  exact h2

/-- The entropic inequality implies the counting inequality of file I. -/
theorem entropic_cutwise_singleton_implies_counting {C : Finset (Word n q)} {d : ℕ}
    (hC : C.Nonempty) (hd : MinDist C d) (hd1 : 1 ≤ d) (hq : 1 ≤ q) {S : Finset (Fin n)}
    (hS : S.card ≤ CutData.sdim n d) :
    Real.log C.card
      ≤ Real.log (cutRank C S) + (CutData.sdim n d - S.card : ℕ) * Real.log q := by
  have h1 := entropic_cutwise_singleton hC hd hd1 hq hS
  have h2 := cutEntropy_le_log_cutRank hC S
  linarith

/-- The **entropic cut defect**: the slack in the entropic cut-wise Singleton
inequality. -/
noncomputable def entropicDefect (C : Finset (Word n q)) (d : ℕ) (S : Finset (Fin n)) : ℝ :=
  cutEntropy C S + (CutData.sdim n d - S.card : ℕ) * Real.log q - Real.log C.card

theorem entropicDefect_nonneg {C : Finset (Word n q)} {d : ℕ} (hC : C.Nonempty)
    (hd : MinDist C d) (hd1 : 1 ≤ d) (hq : 1 ≤ q) {S : Finset (Fin n)}
    (hS : S.card ≤ CutData.sdim n d) : 0 ≤ entropicDefect C d S := by
  have := entropic_cutwise_singleton hC hd hd1 hq hS
  simp only [entropicDefect]
  linarith

/-- **The entropic defect at the empty cut detects the MDS property.** -/
theorem entropicDefect_eq_zero_iff_isMDS {C : Finset (Word n q)} {d : ℕ} (hC : C.Nonempty)
    (hd : MinDist C d) (hq : 2 ≤ q) :
    entropicDefect C d (∅ : Finset (Fin n)) = 0 ↔ IsMDS C d := by
  have hq1 : 1 ≤ q := by omega
  have hCpos : (0 : ℝ) < C.card := by exact_mod_cast Finset.card_pos.mpr hC
  have hqR : (0 : ℝ) < q := by exact_mod_cast (by omega : 0 < q)
  have hlogq : 0 < Real.log q := Real.log_pos (by exact_mod_cast hq)
  have hempty : cutEntropy C (∅ : Finset (Fin n)) = 0 := cutEntropy_empty hC
  have hpowpos : (0 : ℝ) < (q : ℝ) ^ CutData.sdim n d := by positivity
  constructor
  · intro h0
    refine ⟨hd, ?_⟩
    have hlog : Real.log C.card = (CutData.sdim n d : ℕ) * Real.log q := by
      simp only [entropicDefect, hempty, Finset.card_empty, Nat.sub_zero, zero_add] at h0
      linarith
    have hlog' : Real.log C.card = Real.log ((q : ℝ) ^ CutData.sdim n d) := by
      rw [hlog, Real.log_pow]
    have : (C.card : ℝ) = (q : ℝ) ^ CutData.sdim n d :=
      Real.log_injOn_pos (Set.mem_Ioi.mpr hCpos) (Set.mem_Ioi.mpr hpowpos) hlog'
    exact_mod_cast this
  · intro hmds
    have hcard : (C.card : ℝ) = (q : ℝ) ^ CutData.sdim n d := by
      rw [hmds.2]
      push_cast
      ring
    simp only [entropicDefect, hempty, Finset.card_empty, Nat.sub_zero, zero_add, hcard,
      Real.log_pow]
    ring

end CutIndexedSingleton