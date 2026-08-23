import Novelty.CutIndexedSingleton
import Novelty.IITTensorNetworkEntropy

/-!
# Cut-indexed defects II: the entropy profile of a cut

`CutIndexedSingleton.lean` proved the cut-wise Singleton inequality
`|C| ≤ q ^ (k - |S|) * cutRank C S` for the *counting* bond dimension of a code.
This file replaces counting by **Shannon entropy** and asks when the resulting
entropic inequality is an equality.

## The cut entropy

Put the uniform distribution on the codebook `C` and push it forward to the cut
`S`: the pattern `y : S → Fin q` receives probability
`cutProb C S y = |fibre over y| / |C|`.  Its Shannon entropy `cutEntropy C S` is
the entropy of the marginal seen by the sites in `S` — the classical shadow of
the entanglement entropy across the cut.

## Main results

* `sum_cutProb`, `support_cutProb` : `cutProb` is a probability vector whose
  support is exactly the set of realised patterns, of size `cutRank C S`;
* `cutEntropy_le_log_cutRank` : the entropy of a cut is at most the log of its
  bond dimension (reusing `IITTensorNetwork.sum_negMulLog_le_log_card_support`);
* `cutEntropy_le_min` : **entropic cut-wise Singleton.**  For a code of minimum
  distance `d`, `H(S) ≤ min (|S|, k) * log q` — the entropy profile is trapped
  under the "Ryu–Takayanagi"-shaped plateau curve;
* `entropyDefect_nonneg` : the *entropic cut defect* `|S| log q - H(S)` is
  nonnegative;
* `cutEntropy_of_isMDS` : **the plateau is attained.**  For an MDS code,
  `H(S) = min (|S|, k) * log q` at *every* cut: the profile rises with unit slope
  `log q` up to `|S| = k` and is exactly flat afterwards;
* `isMDS_iff_cutEntropy_eq` : **equality with entropy is equivalent to MDS.**
  Given minimum distance `d` and any single cut `S` of size `k`, the code is MDS
  if and only if the entropy of that one cut equals `k log q`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the combinatorial defect `q ^ (k-|S|) rank S - |C|`
should have an entropic avatar whose vanishing is *equivalent* to the MDS
property, and the entropy profile of an MDS code should be the piecewise-linear
`min(|S|, k) log q` — a discrete Ryu–Takayanagi curve with a sharp corner at the
Singleton dimension.

Experiment (Experimenter): both halves were proved.  The upward slope comes from
`fiber_card_of_isMDS` (balanced fibres force a *uniform* marginal on `q ^ |S|`
patterns); the plateau comes from `cutRank_eq_card_of_minDist` (above `k` the
projection is injective, so the marginal is uniform on all of `C`).  Both cases
are instances of one lemma, `cutEntropy_eq_log_of_uniform`.

Analysis (Analyst): the "needs a different definition" verdict of cycle 1 applies
to the converse direction: `H(S) = |S| log q` for a *single* cut of size `k` is
already enough for MDS, because Shannon entropy of the marginal never exceeds
`log |C|`.  So the whole Singleton defect is detectable at one cut — no averaging
over cuts is needed.  This is what makes `isMDS_iff_cutEntropy_eq` an `iff`.

Critique (Critic): the equivalence needs `2 ≤ q` (for `q = 1` all logs vanish and
the criterion is vacuous) and `C.Nonempty` (the empty code has no marginal); both
hypotheses are recorded explicitly and are necessary.
-/

open Finset

namespace CutIndexedSingleton

variable {n q : ℕ}

/-- The marginal probability that the uniform distribution on the codebook `C`
puts on the pattern `y` of the cut `S`. -/
noncomputable def cutProb (C : Finset (Word n q)) (S : Finset (Fin n))
    (y : {i // i ∈ S} → Fin q) : ℝ :=
  ((fiber C S y).card : ℝ) / C.card

/-- The **Shannon entropy of the cut** `S`: the entropy of the marginal that the
uniform distribution on `C` induces on the sites of `S`. -/
noncomputable def cutEntropy (C : Finset (Word n q)) (S : Finset (Fin n)) : ℝ :=
  ∑ y : {i // i ∈ S} → Fin q, Real.negMulLog (cutProb C S y)

lemma cutProb_nonneg (C : Finset (Word n q)) (S : Finset (Fin n))
    (y : {i // i ∈ S} → Fin q) : 0 ≤ cutProb C S y := by
  unfold cutProb
  positivity

lemma sum_cutProb {C : Finset (Word n q)} (hC : C.Nonempty) (S : Finset (Fin n)) :
    ∑ y : {i // i ∈ S} → Fin q, cutProb C S y = 1 := by
  have hpos : (0 : ℝ) < C.card := by
    exact_mod_cast Finset.card_pos.mpr hC
  unfold cutProb
  rw [← Finset.sum_div]
  rw [show ∑ y : {i // i ∈ S} → Fin q, ((fiber C S y).card : ℝ) = ((C.card : ℕ) : ℝ) by
    exact_mod_cast congrArg (fun m : ℕ => (m : ℝ)) (sum_fiber_card C S)]
  field_simp

lemma cutProb_ne_zero_iff {C : Finset (Word n q)} (hC : C.Nonempty) (S : Finset (Fin n))
    (y : {i // i ∈ S} → Fin q) : cutProb C S y ≠ 0 ↔ y ∈ C.image (proj S) := by
  classical
  have hpos : (0 : ℝ) < C.card := by exact_mod_cast Finset.card_pos.mpr hC
  unfold cutProb
  rw [div_ne_zero_iff]
  constructor
  · rintro ⟨h1, -⟩
    have : (fiber C S y).Nonempty := by
      rw [← Finset.card_pos]
      exact Nat.pos_of_ne_zero (by exact_mod_cast h1)
    obtain ⟨c, hc⟩ := this
    exact Finset.mem_image.mpr ⟨c, (Finset.mem_filter.mp hc).1, (Finset.mem_filter.mp hc).2⟩
  · intro hy
    obtain ⟨c, hc, rfl⟩ := Finset.mem_image.mp hy
    refine ⟨?_, ne_of_gt hpos⟩
    have : (fiber C S (proj S c)).Nonempty :=
      ⟨c, Finset.mem_filter.mpr ⟨hc, rfl⟩⟩
    have hpos' := Finset.card_pos.mpr this
    exact_mod_cast hpos'.ne'

/-- The support of the cut marginal is exactly the set of realised patterns. -/
lemma support_cutProb {C : Finset (Word n q)} (hC : C.Nonempty) (S : Finset (Fin n)) :
    IITTensorNetwork.support (cutProb C S) = C.image (proj S) := by
  ext y
  rw [IITTensorNetwork.mem_support]
  exact cutProb_ne_zero_iff hC S y

/-- **Entropy is bounded by the log of the bond dimension of the cut.** -/
theorem cutEntropy_le_log_cutRank {C : Finset (Word n q)} (hC : C.Nonempty)
    (S : Finset (Fin n)) : cutEntropy C S ≤ Real.log (cutRank C S) := by
  have h := IITTensorNetwork.sum_negMulLog_le_log_card_support
    (p := cutProb C S) (fun y => cutProb_nonneg C S y) (sum_cutProb hC S)
  rwa [support_cutProb hC S] at h

lemma cutEntropy_nonneg {C : Finset (Word n q)} (hC : C.Nonempty) (S : Finset (Fin n)) :
    0 ≤ cutEntropy C S :=
  IITTensorNetwork.sum_negMulLog_nonneg (fun y => cutProb_nonneg C S y) (sum_cutProb hC S)

/-- **The entropic cut defect**: the gap between the maximal entropy `|S| log q`
that the sites of the cut could carry and the entropy they do carry. -/
noncomputable def entropyDefect (C : Finset (Word n q)) (S : Finset (Fin n)) : ℝ :=
  S.card * Real.log q - cutEntropy C S

lemma cutEntropy_le_card_mul_log {C : Finset (Word n q)} (hC : C.Nonempty)
    (S : Finset (Fin n)) : cutEntropy C S ≤ S.card * Real.log q := by
  classical
  rcases Nat.eq_zero_or_pos q with hq | hq
  · subst hq
    -- with an empty alphabet a nonempty codebook forces `n = 0`
    obtain ⟨c, -⟩ := id hC
    have hn : n = 0 := by
      by_contra hn
      exact (c ⟨0, Nat.pos_of_ne_zero hn⟩).elim0
    subst hn
    have hS : S = ∅ := by
      ext i
      exact i.elim0
    subst hS
    simp only [Finset.card_empty, Nat.cast_zero, zero_mul]
    refine (cutEntropy_le_log_cutRank hC (∅ : Finset (Fin 0))).trans ?_
    refine Real.log_nonpos (by positivity) ?_
    exact_mod_cast cutRank_empty_le C
  · have h1 := cutEntropy_le_log_cutRank hC S
    have h2 : (cutRank C S : ℝ) ≤ (q : ℝ) ^ S.card := by
      exact_mod_cast (codeCutData C).rank_le_pow S
    have hpos : (0 : ℝ) < cutRank C S := by
      have : 0 < cutRank C S := by
        rw [cutRank, Finset.card_pos]
        exact hC.image _
      exact_mod_cast this
    have := Real.log_le_log hpos h2
    rw [Real.log_pow] at this
    linarith

/-- The entropic cut defect is nonnegative. -/
theorem entropyDefect_nonneg {C : Finset (Word n q)} (hC : C.Nonempty) (S : Finset (Fin n)) :
    0 ≤ entropyDefect C S := by
  have := cutEntropy_le_card_mul_log hC S
  simp only [entropyDefect]
  linarith

/-- **Entropic cut-wise Singleton bound.**  For a code of minimum distance `d`,
the entropy of a cut never exceeds `min (|S|, k) * log q`. -/
theorem cutEntropy_le_min {C : Finset (Word n q)} {d : ℕ} (hC : C.Nonempty)
    (hd : MinDist C d) (hd1 : 1 ≤ d) (hq : 1 ≤ q) (S : Finset (Fin n)) :
    cutEntropy C S ≤ (min S.card (CutData.sdim n d) : ℕ) * Real.log q := by
  have hlogq : 0 ≤ Real.log q := Real.log_nonneg (by exact_mod_cast hq)
  rcases le_total S.card (CutData.sdim n d) with h | h
  · rw [Nat.min_eq_left h]
    exact cutEntropy_le_card_mul_log hC S
  · rw [Nat.min_eq_right h]
    have h1 := cutEntropy_le_log_cutRank hC S
    have h2 : (cutRank C S : ℝ) ≤ (C.card : ℝ) := by
      exact_mod_cast Finset.card_image_le
    have h3 : (C.card : ℝ) ≤ ((q : ℝ)) ^ (CutData.sdim n d) := by
      exact_mod_cast singleton_bound_of_minDist hd hd1
    have hpos : (0 : ℝ) < cutRank C S := by
      have : 0 < cutRank C S := by
        rw [cutRank, Finset.card_pos]
        exact hC.image _
      exact_mod_cast this
    have := Real.log_le_log hpos (h2.trans h3)
    rw [Real.log_pow] at this
    linarith

/-! ### Flat marginals -/

/-- If the marginal on a cut is uniform on its `m` realised patterns, the cut
entropy is `log m`. -/
lemma cutEntropy_eq_log_of_uniform {C : Finset (Word n q)} {S : Finset (Fin n)} {m : ℕ}
    (hm : 0 < m) (hcard : cutRank C S = m)
    (huni : ∀ y ∈ C.image (proj S), cutProb C S y = ((m : ℝ))⁻¹) :
    cutEntropy C S = Real.log m := by
  classical
  have hmR : (0 : ℝ) < m := by exact_mod_cast hm
  have hzero : ∀ y ∈ (Finset.univ : Finset ({i // i ∈ S} → Fin q)) \ C.image (proj S),
      Real.negMulLog (cutProb C S y) = 0 := by
    intro y hy
    have hy' : y ∉ C.image (proj S) := (Finset.mem_sdiff.mp hy).2
    have : cutProb C S y = 0 := by
      unfold cutProb
      have : (fiber C S y).card = 0 := by
        rw [Finset.card_eq_zero]
        by_contra hne
        obtain ⟨c, hc⟩ := Finset.nonempty_iff_ne_empty.mpr hne
        exact hy' (Finset.mem_image.mpr
          ⟨c, (Finset.mem_filter.mp hc).1, (Finset.mem_filter.mp hc).2⟩)
      rw [this]
      simp
    rw [this, Real.negMulLog_zero]
  have hsplit : cutEntropy C S = ∑ y ∈ C.image (proj S), Real.negMulLog (cutProb C S y) := by
    unfold cutEntropy
    rw [← Finset.sum_subset (Finset.subset_univ (C.image (proj S)))]
    intro y hy hy'
    exact hzero y (Finset.mem_sdiff.mpr ⟨hy, hy'⟩)
  have huni' : ∀ y ∈ C.image (proj S),
      Real.negMulLog (cutProb C S y) = Real.negMulLog ((m : ℝ))⁻¹ := by
    intro y hy
    rw [huni y hy]
  have hcard' : (C.image (proj S)).card = m := hcard
  rw [hsplit, Finset.sum_congr rfl huni', Finset.sum_const, hcard', nsmul_eq_mul]
  simp only [Real.negMulLog_def, Real.log_inv]
  field_simp

/-- **The entropy plateau of an MDS code.**  At every cut, the entropy of an MDS
code equals `min (|S|, k) * log q`: it grows with the maximal slope `log q` up to
the Singleton dimension and is exactly constant beyond it. -/
theorem cutEntropy_of_isMDS {C : Finset (Word n q)} {d : ℕ} (hmds : IsMDS C d)
    (hd1 : 1 ≤ d) (hdn : d ≤ n + 1) (hq : 0 < q) (S : Finset (Fin n)) :
    cutEntropy C S = (min S.card (CutData.sdim n d) : ℕ) * Real.log q := by
  classical
  set k := CutData.sdim n d with hk
  have hCcard : C.card = q ^ k := hmds.2
  have hCne : C.Nonempty := by
    rw [← Finset.card_pos, hCcard]
    exact Nat.pow_pos hq
  rcases le_total S.card k with h | h
  · -- below the plateau: uniform on `q ^ |S|` patterns
    rw [Nat.min_eq_left h]
    have hrank : cutRank C S = q ^ S.card := cutRank_eq_pow_of_isMDS hmds hd1 hq h
    have huni : ∀ y ∈ C.image (proj S), cutProb C S y = (((q ^ S.card : ℕ) : ℝ))⁻¹ := by
      intro y _
      have hfib : (fiber C S y).card = q ^ (k - S.card) := fiber_card_of_isMDS hmds hd1 h y
      unfold cutProb
      rw [hfib, hCcard]
      have hsplit : (q : ℝ) ^ k = (q : ℝ) ^ (k - S.card) * (q : ℝ) ^ S.card := by
        rw [← pow_add]
        congr 1
        omega
      have hqR : (0 : ℝ) < q := by exact_mod_cast hq
      push_cast
      rw [hsplit]
      rw [div_eq_iff (by positivity)]
      field_simp
    rw [cutEntropy_eq_log_of_uniform (Nat.pow_pos hq) hrank huni]
    push_cast
    rw [Real.log_pow]
  · -- above the plateau: uniform on all of `C`
    rw [Nat.min_eq_right h]
    have hres : cutRank C S = C.card := by
      refine cutRank_eq_card_of_minDist hmds.1 ?_
      have : k ≤ S.card := h
      simp only [hk, CutData.sdim] at this ⊢
      omega
    have huni : ∀ y ∈ C.image (proj S), cutProb C S y = ((C.card : ℝ))⁻¹ := by
      intro y hy
      have hfib : (fiber C S y).card = 1 := by
        have hinj : Set.InjOn (proj S) (C : Set (Word n q)) := by
          intro x hx z hz hxz
          by_contra hne
          have h1 := hmds.1 x hx z hz hne
          have h2 := hammingDist_le_of_proj_eq hxz
          have : k ≤ S.card := h
          simp only [hk, CutData.sdim] at this
          omega
        obtain ⟨c, hc, rfl⟩ := Finset.mem_image.mp hy
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
    have hCpos : 0 < C.card := Finset.card_pos.mpr hCne
    rw [cutEntropy_eq_log_of_uniform hCpos hres huni, hCcard]
    push_cast
    rw [Real.log_pow]

/-- **Equality with entropy characterises MDS codes.**  For a code of minimum
distance `d` and any single cut of size exactly `k = n + 1 - d`, the entropic cut
defect vanishes if and only if the code meets the Singleton bound. -/
theorem isMDS_iff_cutEntropy_eq {C : Finset (Word n q)} {d : ℕ} (hC : C.Nonempty)
    (hd : MinDist C d) (hd1 : 1 ≤ d) (hdn : d ≤ n + 1) (hq : 2 ≤ q)
    {S : Finset (Fin n)} (hS : S.card = CutData.sdim n d) :
    IsMDS C d ↔ cutEntropy C S = (CutData.sdim n d : ℕ) * Real.log q := by
  classical
  set k := CutData.sdim n d with hk
  have hq0 : 0 < q := by omega
  have hlogq : 0 < Real.log q := Real.log_pos (by exact_mod_cast hq)
  constructor
  · intro hmds
    have := cutEntropy_of_isMDS hmds hd1 hdn hq0 S
    rwa [hS, Nat.min_self] at this
  · intro hent
    refine ⟨hd, ?_⟩
    have hle : C.card ≤ q ^ k := singleton_bound_of_minDist hd hd1
    have h1 : cutEntropy C S ≤ Real.log C.card := by
      have h2 := cutEntropy_le_log_cutRank hC S
      have h3 : (cutRank C S : ℝ) ≤ (C.card : ℝ) := by exact_mod_cast Finset.card_image_le
      have hpos : (0 : ℝ) < cutRank C S := by
        have : 0 < cutRank C S := by
          rw [cutRank, Finset.card_pos]
          exact hC.image _
        exact_mod_cast this
      exact h2.trans (Real.log_le_log hpos h3)
    rw [hent] at h1
    have hCpos : (0 : ℝ) < C.card := by exact_mod_cast Finset.card_pos.mpr hC
    have hqk : (0 : ℝ) < (q : ℝ) ^ k := by positivity
    have hlog : Real.log ((q : ℝ) ^ k) ≤ Real.log C.card := by
      rw [Real.log_pow]
      exact_mod_cast h1
    have hge : ((q : ℝ)) ^ k ≤ (C.card : ℝ) := (Real.log_le_log_iff hqk hCpos).mp hlog
    have hge' : q ^ k ≤ C.card := by exact_mod_cast hge
    exact le_antisymm hle hge'

end CutIndexedSingleton