import Combinatorics.BellDefectBlockPatterns

/-!
# The Bell defect, graded by blocks: propagation bounds and the moment–spectrum equivalence

This file closes the two open conjectures of the previous cycle of this research thread
(Conjecture E′ and Conjecture F of `FUTURE_DIRECTIONS.md`), building on

* `Catalog/Bridges/MoonshineBellTransitivityBridge.lean`  (Bell floor, `k`-transitivity),
* `Catalog/Speculative/AutoResearch/MoonshineFibreSpectrumBridge.lean`  (`bell_defect_eq`),
* `Catalog/Speculative/AutoResearch/FibreSpectrumRank.lean`  (rank collapse `m_P = t_{rank P}`,
  Stirling expansion, monotonicity `t_r ≤ t_s`),
* `Catalog/Combinatorics/BellDefectBlockPatterns.lean`  (Stirling boundary values and tails).

## Results

**Bell defect.**  `bellDefect k G X := Σ_g |X^g|^k − B_k·|G|`, the excess of the `k`-th moment of
the fixed-point (trace) family over its Bell floor.

* `bellDefect_eq_spectrum` : `D_k = |G| · Σ_{r≤k} S(k,r)·(t_r − 1)`.
* `moment_eq_bell_add_bellDefect` : `Σ_g |X^g|^k = B_k·|G| + D_k` (so the truncated subtraction in
  the definition is harmless).
* `bellDefect_eq_zero_iff` : `D_k = 0 ↔ k`-transitive.

**Conjecture F (quantitative propagation), proved.**

* `bellDefect_propagation` : for `1 ≤ j ≤ k ≤ |X|`,
  `(Σ_{r=j}^{k} S(k,r)) · D_j ≤ B_j · D_k`.
  The constant is *explicit and combinatorial*: the Stirling tail over the coarser levels.
* `bellDefect_two_propagation` : the case `j = 2`, `(B_k − 1)·D_2 ≤ 2·D_k`, i.e. the constant
  asked for in Conjecture F is `c_k = (B_k − 1)/2`.
* `bellDefect_pos_of_bellDefect_two_pos` : hence `D_2 > 0 ⇒ D_k > 0`; failure of `2`-transitivity
  propagates quantitatively to every longer tuple length.

**Conjecture E′, resolved in two halves.**

* `patternMultiplicity_rank_eq_one_iff` (the *confirmed* half): for `1 ≤ j ≤ k ≤ |X|`, all fibres
  over patterns with exactly `j` blocks are singletons **iff** the action is `j`-transitive.  So
  the block grading of the `k`-tuple data resolves the whole transitivity hierarchy below `k`,
  which no single moment can do.
* `moments_eq_iff_injOrbits_eq` (the *refuted* half): for two actions of groups of equal order,
  the moments `Σ_g |X^g|^j` for `j ≤ k` agree **iff** the spectra `t_r`, `r ≤ k`, agree.  The
  fibre spectrum is therefore *not* a strictly finer invariant than the family of moments: it is
  the Stirling transform of it, and the transform is invertible (the Stirling matrix is
  unitriangular).  Only a *single* moment is strictly coarser.

There are no `sorry`s, no `native_decide`, and no new axioms.
-/

open Finset MulAction Function

namespace BellDefectGraded

open MoonshineBell MoonshineFibre FibreSpectrum

/-! ## Part 1: the block-graded transitivity criterion (Conjecture E′, confirmed half) -/

section Graded

variable {j k : ℕ} (G : Type*) [Group G] (X : Type*) [MulAction G X] [Finite X]

/-- **Block-graded fibrewise criterion.**  Inside the level-`k` data, the patterns with exactly
`j` blocks see exactly `j`-transitivity: every fibre over a `j`-block pattern is a singleton iff
the action is `j`-transitive.  For `j = k` this is the top-fibre criterion, and taking all `j` at
once recovers `patternMultiplicity_eq_one_iff`. -/
theorem patternMultiplicity_rank_eq_one_iff (hj : 1 ≤ j) (hjk : j ≤ k) (hk : k ≤ Nat.card X) :
    (∀ P : Pattern k, rank P = j → patternMultiplicity k G X P = 1) ↔ KTransitive j G X := by
  have hjX : j ≤ Nat.card X := le_trans hjk hk
  constructor
  · intro hall
    have h := hall (blockPattern k j) (rank_blockPattern hj hjk)
    rw [patternMultiplicity_eq_injOrbits_rank, rank_blockPattern hj hjk] at h
    exact (injOrbits_eq_one_iff G X hjX).1 h
  · intro htr P hP
    rw [patternMultiplicity_eq_injOrbits_rank, hP]
    exact (injOrbits_eq_one_iff G X hjX).2 htr

/-- The graded criteria are nested: if the level-`j` fibres are all singletons then so are the
level-`i` fibres for every `1 ≤ i ≤ j`.  (Transitivity degrades downwards.) -/
theorem patternMultiplicity_rank_eq_one_mono {i : ℕ} (hi : 1 ≤ i) (hij : i ≤ j) (hjk : j ≤ k)
    (hk : k ≤ Nat.card X)
    (h : ∀ P : Pattern k, rank P = j → patternMultiplicity k G X P = 1) :
    ∀ P : Pattern k, rank P = i → patternMultiplicity k G X P = 1 := by
  intro P hP
  have hjX : j ≤ Nat.card X := le_trans hjk hk
  have hiX : i ≤ Nat.card X := le_trans hij hjX
  have htop : injOrbits G X j = 1 := by
    have := h (blockPattern k j) (rank_blockPattern (le_trans hi hij) hjk)
    rwa [patternMultiplicity_eq_injOrbits_rank, rank_blockPattern (le_trans hi hij) hjk] at this
  have hlow : 1 ≤ injOrbits G X i :=
    one_le_patternMultiplicity i G X hiX (idPattern i)
  have hmono : injOrbits G X i ≤ injOrbits G X j := injOrbits_monotone G X hij hjX
  rw [patternMultiplicity_eq_injOrbits_rank, hP]
  omega

end Graded

/-! ## Part 2: the Bell defect and its spectral formula -/

section Defect

variable (k : ℕ) (G : Type*) [Group G] [Fintype G] (X : Type*) [MulAction G X] [Finite X]

/-- The **Bell defect** `D_k = Σ_g |X^g|^k − B_k·|G|`: the excess of the `k`-th moment of the
fixed-point family over the universal Bell floor. -/
noncomputable def bellDefect : ℕ :=
  (∑ g : G, Nat.card (fixedBy X g) ^ k) - bell k * Nat.card G

/-- **Spectral formula for the defect.**  `D_k = |G|·Σ_{r≤k} S(k,r)·(t_r − 1)`: each block number
contributes its own excess, weighted by the number of patterns with that many blocks. -/
theorem bellDefect_eq_spectrum (hk : k ≤ Nat.card X) :
    bellDefect k G X
      = (∑ r ∈ Finset.range (k + 1), stirling k r * (injOrbits G X r - 1)) * Nat.card G := by
  rw [bellDefect, bell_defect_stirling k G X hk, add_mul, Nat.add_sub_cancel_left]

/-- The defect really is a defect: the moment splits as Bell floor plus defect, with no truncated
subtraction. -/
theorem moment_eq_bell_add_bellDefect (hk : k ≤ Nat.card X) :
    ∑ g : G, Nat.card (fixedBy X g) ^ k = bell k * Nat.card G + bellDefect k G X := by
  rw [bellDefect_eq_spectrum k G X hk, bell_defect_stirling k G X hk, add_mul]

/-- The defect vanishes exactly for `k`-transitive actions. -/
theorem bellDefect_eq_zero_iff (hk : k ≤ Nat.card X) :
    bellDefect k G X = 0 ↔ KTransitive k G X := by
  have hGpos : 0 < Nat.card G := Nat.card_pos
  rw [bellDefect, bell_defect_eq k G X hk, add_mul, Nat.add_sub_cancel_left,
    ← sum_patternMultiplicity_sub_one_eq_zero_iff k G X hk]
  constructor
  · intro h
    rcases Nat.mul_eq_zero.1 h with h | h
    · exact h
    · omega
  · intro h; rw [h, zero_mul]

/-- Upper bound for the defect in terms of the top spectral value at level `j`: since the spectrum
is monotone, every term of the Stirling expansion is at most `t_j − 1`. -/
theorem bellDefect_le_bell_mul (j : ℕ) (hj : j ≤ Nat.card X) :
    bellDefect j G X ≤ bell j * (injOrbits G X j - 1) * Nat.card G := by
  rw [bellDefect_eq_spectrum j G X hj]
  refine Nat.mul_le_mul_right _ ?_
  calc ∑ r ∈ Finset.range (j + 1), stirling j r * (injOrbits G X r - 1)
      ≤ ∑ r ∈ Finset.range (j + 1), stirling j r * (injOrbits G X j - 1) := by
        refine Finset.sum_le_sum fun r hr => ?_
        have hrj : r ≤ j := Nat.lt_succ_iff.1 (Finset.mem_range.1 hr)
        exact Nat.mul_le_mul_left _
          (Nat.sub_le_sub_right (injOrbits_monotone G X hrj hj) 1)
    _ = bell j * (injOrbits G X j - 1) := by
        rw [← Finset.sum_mul, ← bell_eq_sum_stirling]

/-- Lower bound for the defect at level `k` in terms of the level-`j` spectral value, `j ≤ k`:
only the ranks `≥ j` are used, and each of them has `t_r − 1 ≥ t_j − 1`. -/
theorem sum_stirling_mul_le_bellDefect {j : ℕ} (hk : k ≤ Nat.card X) :
    (∑ r ∈ Finset.Icc j k, stirling k r) * (injOrbits G X j - 1) * Nat.card G
      ≤ bellDefect k G X := by
  rw [bellDefect_eq_spectrum k G X hk]
  refine Nat.mul_le_mul_right _ ?_
  have hsub : Finset.Icc j k ⊆ Finset.range (k + 1) := by
    intro r hr
    rw [Finset.mem_Icc] at hr
    exact Finset.mem_range.2 (Nat.lt_succ_of_le hr.2)
  calc (∑ r ∈ Finset.Icc j k, stirling k r) * (injOrbits G X j - 1)
      = ∑ r ∈ Finset.Icc j k, stirling k r * (injOrbits G X j - 1) := by rw [Finset.sum_mul]
    _ ≤ ∑ r ∈ Finset.Icc j k, stirling k r * (injOrbits G X r - 1) := by
        refine Finset.sum_le_sum fun r hr => ?_
        rw [Finset.mem_Icc] at hr
        exact Nat.mul_le_mul_left _ (Nat.sub_le_sub_right
          (injOrbits_monotone G X hr.1 (le_trans hr.2 hk)) 1)
    _ ≤ ∑ r ∈ Finset.range (k + 1), stirling k r * (injOrbits G X r - 1) :=
        Finset.sum_le_sum_of_subset hsub

/-- **Conjecture F, proved.**  The Bell defect propagates from any level `j` to any longer level
`k` with an explicit combinatorial constant: the Stirling tail `Σ_{r=j}^{k} S(k,r)` over the Bell
number `B_j`.  Nothing about the action is assumed beyond `k ≤ |X|`. -/
theorem bellDefect_propagation {j : ℕ} (hjk : j ≤ k) (hk : k ≤ Nat.card X) :
    (∑ r ∈ Finset.Icc j k, stirling k r) * bellDefect j G X ≤ bell j * bellDefect k G X := by
  have hj : j ≤ Nat.card X := le_trans hjk hk
  calc (∑ r ∈ Finset.Icc j k, stirling k r) * bellDefect j G X
      ≤ (∑ r ∈ Finset.Icc j k, stirling k r) * (bell j * (injOrbits G X j - 1) * Nat.card G) :=
        Nat.mul_le_mul_left _ (bellDefect_le_bell_mul (G := G) (X := X) j hj)
    _ = bell j * ((∑ r ∈ Finset.Icc j k, stirling k r) * (injOrbits G X j - 1) * Nat.card G) := by
        ring
    _ ≤ bell j * bellDefect k G X :=
        Nat.mul_le_mul_left _ (sum_stirling_mul_le_bellDefect k G X hk)

/-- **The constant of Conjecture F, explicitly.**  `(B_k − 1)·D_2 ≤ 2·D_k`, i.e.
`D_k ≥ c_k·D_2` with `c_k = (B_k − 1)/2`, a constant depending only on `k`. -/
theorem bellDefect_two_propagation (hk2 : 2 ≤ k) (hk : k ≤ Nat.card X) :
    (bell k - 1) * bellDefect 2 G X ≤ 2 * bellDefect k G X := by
  have h := bellDefect_propagation k G X (j := 2) hk2 hk
  rwa [sum_stirling_Icc_two (by omega : 1 ≤ k), bell_two] at h

/-- Failure of `2`-transitivity is inherited, quantitatively, by every longer tuple length. -/
theorem bellDefect_pos_of_bellDefect_two_pos (hk2 : 2 ≤ k) (hk : k ≤ Nat.card X)
    (h2 : 0 < bellDefect 2 G X) : 0 < bellDefect k G X := by
  have hb : 0 < bell k - 1 := by have := two_le_bell hk2; omega
  have h := bellDefect_two_propagation k G X hk2 hk
  have hle : bellDefect 2 G X ≤ (bell k - 1) * bellDefect 2 G X :=
    Nat.le_mul_of_pos_left _ hb
  have h3 : 0 < 2 * bellDefect k G X := lt_of_lt_of_le (lt_of_lt_of_le h2 hle) h
  omega

/-- The contrapositive packaging: if the action is `k`-transitive for some `k ≥ 2` then it is
`2`-transitive — recovered here from the quantitative bound rather than from the fibre picture. -/
theorem kTransitive_two_of_kTransitive (hk2 : 2 ≤ k) (hk : k ≤ Nat.card X)
    (h : KTransitive k G X) : KTransitive 2 G X := by
  by_contra hcon
  have h2 : bellDefect 2 G X ≠ 0 := fun hz =>
    hcon ((bellDefect_eq_zero_iff 2 G X (le_trans hk2 hk)).1 hz)
  have hpos := bellDefect_pos_of_bellDefect_two_pos k G X hk2 hk (Nat.pos_of_ne_zero h2)
  have hzero := (bellDefect_eq_zero_iff k G X hk).2 h
  omega

omit [Fintype G] in
/-- The spectrum starts at `t_0 = 1`: there is exactly one orbit of empty tuples. -/
theorem injOrbits_zero_eq_one : injOrbits G X 0 = 1 :=
  (injOrbits_eq_one_iff G X (Nat.zero_le _)).2
    (fun _ _ _ _ => ⟨1, funext fun i => absurd i.isLt (by omega)⟩)

end Defect

/-! ## Part 3: moments versus the fibre spectrum (Conjecture E′, refuted half) -/

section MomentSpectrum

variable {k : ℕ}
variable (G : Type*) [Group G] [Fintype G] (X : Type*) [MulAction G X] [Finite X]
variable (H : Type*) [Group H] [Fintype H] (Y : Type*) [MulAction H Y] [Finite Y]

/-- **The moments determine the spectrum.**  If two actions of groups of the same order have the
same moments `Σ_g |X^g|^j` for all `j ≤ k`, then their fibre spectra agree up to level `k`.  The
proof is Stirling inversion: the Stirling matrix is unitriangular (`stirling_self`), so the
transform can be undone by strong induction. -/
theorem injOrbits_eq_of_moments_eq (hcard : Nat.card G = Nat.card H)
    (hmom : ∀ j ≤ k, ∑ g : G, Nat.card (fixedBy X g) ^ j
      = ∑ h : H, Nat.card (fixedBy Y h) ^ j) :
    ∀ r ≤ k, injOrbits G X r = injOrbits H Y r := by
  intro r
  induction r using Nat.strong_induction_on with
  | _ r ih =>
    intro hrk
    have hGpos : 0 < Nat.card G := Nat.card_pos
    have hmr := hmom r hrk
    rw [sum_fixedPoints_pow_eq_sum_stirling r G X, sum_fixedPoints_pow_eq_sum_stirling r H Y,
      ← hcard] at hmr
    have hsum : ∑ s ∈ Finset.range (r + 1), stirling r s * injOrbits G X s
        = ∑ s ∈ Finset.range (r + 1), stirling r s * injOrbits H Y s :=
      Nat.eq_of_mul_eq_mul_right hGpos hmr
    rw [Finset.sum_range_succ, Finset.sum_range_succ, stirling_self r, one_mul, one_mul] at hsum
    have hlow : ∑ s ∈ Finset.range r, stirling r s * injOrbits G X s
        = ∑ s ∈ Finset.range r, stirling r s * injOrbits H Y s := by
      refine Finset.sum_congr rfl fun s hs => ?_
      have hsr : s < r := Finset.mem_range.1 hs
      rw [ih s hsr (le_trans (le_of_lt hsr) hrk)]
    omega

/-- **The spectrum determines the moments.**  This is the Stirling expansion, read forwards. -/
theorem moments_eq_of_injOrbits_eq (hcard : Nat.card G = Nat.card H)
    (hsp : ∀ r ≤ k, injOrbits G X r = injOrbits H Y r) :
    ∀ j ≤ k, ∑ g : G, Nat.card (fixedBy X g) ^ j = ∑ h : H, Nat.card (fixedBy Y h) ^ j := by
  intro j hjk
  rw [sum_fixedPoints_pow_eq_sum_stirling j G X, sum_fixedPoints_pow_eq_sum_stirling j H Y, hcard]
  congr 1
  refine Finset.sum_congr rfl fun s hs => ?_
  have hsj : s ≤ j := Nat.lt_succ_iff.1 (Finset.mem_range.1 hs)
  rw [hsp s (le_trans hsj hjk)]

/-- **Moment–spectrum equivalence (Conjecture E′, refuted half).**  For groups of equal order the
truncated moment sequence and the truncated fibre spectrum are *the same invariant*: each
determines the other.  Hence the vector `(m_P)_P` of pattern multiplicities cannot separate two
actions that all the moments `j ≤ k` fail to separate; only a single moment is strictly coarser
(the Stirling row sum forgets the grading). -/
theorem moments_eq_iff_injOrbits_eq (hcard : Nat.card G = Nat.card H) :
    (∀ j ≤ k, ∑ g : G, Nat.card (fixedBy X g) ^ j = ∑ h : H, Nat.card (fixedBy Y h) ^ j)
      ↔ (∀ r ≤ k, injOrbits G X r = injOrbits H Y r) :=
  ⟨injOrbits_eq_of_moments_eq G X H Y hcard, moments_eq_of_injOrbits_eq G X H Y hcard⟩

/-- The same statement in terms of the fibre spectrum itself: the level-`k` multiplicities
`m_P = t_{rank P}` agree for the two actions iff all moments up to `k` agree. -/
theorem patternMultiplicity_eq_iff_moments_eq (hcard : Nat.card G = Nat.card H) :
    (∀ P : Pattern k, patternMultiplicity k G X P = patternMultiplicity k H Y P)
      ↔ (∀ j ≤ k, ∑ g : G, Nat.card (fixedBy X g) ^ j
          = ∑ h : H, Nat.card (fixedBy Y h) ^ j) := by
  rw [moments_eq_iff_injOrbits_eq G X H Y hcard]
  constructor
  · intro hP r hrk
    rcases Nat.eq_zero_or_pos r with hr0 | hrpos
    · subst hr0
      rw [injOrbits_zero_eq_one G X, injOrbits_zero_eq_one H Y]
    · have hrank : rank (blockPattern k r) = r := rank_blockPattern hrpos hrk
      have h := hP (blockPattern k r)
      rwa [patternMultiplicity_eq_injOrbits_rank, patternMultiplicity_eq_injOrbits_rank,
        hrank] at h
  · intro hsp P
    rw [patternMultiplicity_eq_injOrbits_rank, patternMultiplicity_eq_injOrbits_rank,
      hsp (rank P) (rank_le P)]

end MomentSpectrum

end BellDefectGraded