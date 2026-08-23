import Novelty.CutIndexedTensorNetwork

/-!
# Cut-indexed defects IV: a fully worked example and a sharpness experiment

The abstract theory of files I–III is instantiated here on the smallest
non-degenerate MDS code, the **even-weight code** `E = {000, 011, 101, 110}` on
`n = 3` bits (`q = 2`, minimum distance `d = 2`, Singleton dimension
`k = n + 1 - d = 2`).  Everything about the code itself is checked by `decide`;
everything about its cut data is then *derived from the general theorems*, not
recomputed.

## Contents

* `isMDS_evenWeight`                     : `E` is MDS (checked by `decide`);
* `cutRank_evenWeight_single`            : bond dimension `2` across a one-site cut;
* `cutEntropy_evenWeight`                : the full entropy profile
  `H(S) = min (|S|, 2) log 2`, an instance of `cutEntropy_of_isMDS`;
* `entropyDefect_evenWeight_full_eq`     : the entropic cut defect at the *full*
  cut is exactly `log 2 > 0` — the defect is a genuinely nonzero invariant, so the
  theory is not vacuous;
* `entanglementEntropy_evenWeight_single`: the quantum cut entropy at a one-site
  cut is exactly `log 2`, saturating the quantum cut-wise Singleton bound;
* `entanglement_lt_cutEntropy_evenWeight`: **sharpness of the guard.**  At the
  two-site cut (`|S| = 2 = k`, but `|S| > d - 1 = 1`) the *quantum* cut entropy is
  strictly smaller than the *classical* cut entropy.  This is the promised
  counterexample showing that the hypothesis `|S| < d` of
  `entanglementEntropy_codeState_of_isMDS` cannot be dropped, and that the
  classical and quantum cut-indexed defects are genuinely different invariants.

-- !-- Lab Notes -- !--
Experiment (Experimenter): `E = {c : (Fin 3 → Fin 2) | c₀ + c₁ + c₂ = 0}`.  `decide`
verifies `|E| = 4 = 2 ^ k` and `MinDist E 2`.  The derived cut profile is
`cutRank(∅, single, pair, full) = (1, 2, 4, 4)` and
`H(S)/log 2 = (0, 1, 2, 2)`, while the quantum profile is
`E(S)/log 2 = (0, 1, ≤ 1, 0)` — the classical profile is monotone and the quantum
profile is a *tent*, forced down by purity on the complement.

Analysis (Analyst): the tent versus staircase discrepancy is the structural reason
why the two saturation regimes of file III differ; it is the discrete shadow of the
fact that a pure state cannot carry more entanglement than either side can hold.
-/

open Finset

namespace CutIndexedSingleton

namespace Examples

open IITTensorNetwork

/-- The even-weight code on three bits: the `[3, 2, 2]_2` MDS code. -/
def evenWeight : Finset (Word 3 2) :=
  Finset.univ.filter (fun c => c 0 + c 1 + c 2 = 0)

lemma card_evenWeight : evenWeight.card = 4 := by decide

lemma nonempty_evenWeight : evenWeight.Nonempty := by decide

lemma minDist_evenWeight : MinDist evenWeight 2 := by
  show ∀ x ∈ evenWeight, ∀ y ∈ evenWeight, x ≠ y → 2 ≤ hammingDist x y
  decide

/-- The even-weight code meets the Singleton bound: it is MDS. -/
theorem isMDS_evenWeight : IsMDS evenWeight 2 := ⟨minDist_evenWeight, by decide⟩

/-- Across a single site the classical bond dimension is `2`. -/
theorem cutRank_evenWeight_single : cutRank evenWeight {(0 : Fin 3)} = 2 := by
  have h := cutRank_eq_pow_of_isMDS isMDS_evenWeight (by norm_num) (by norm_num)
    (S := {(0 : Fin 3)}) (by decide)
  simpa using h

/-- Across two sites the classical bond dimension is `4`: two sites already
determine the codeword. -/
theorem cutRank_evenWeight_pair : cutRank evenWeight {(0 : Fin 3), 1} = 4 := by
  have h := cutRank_eq_pow_of_isMDS isMDS_evenWeight (by norm_num) (by norm_num)
    (S := {(0 : Fin 3), 1}) (by decide)
  have hcard : ({(0 : Fin 3), 1} : Finset (Fin 3)).card = 2 := by decide
  rw [hcard] at h
  simpa using h

/-- **The entropy profile of the even-weight code**: `H(S) = min (|S|, 2) log 2`. -/
theorem cutEntropy_evenWeight (S : Finset (Fin 3)) :
    cutEntropy evenWeight S = (min S.card 2 : ℕ) * Real.log 2 := by
  have h := cutEntropy_of_isMDS isMDS_evenWeight (by norm_num) (by norm_num) (by norm_num) S
  simpa [CutData.sdim] using h

/-- At the full cut the entropic defect is exactly `log 2`: the third site carries
no new information, and the cut-indexed defect detects it. -/
theorem entropyDefect_evenWeight_full_eq :
    entropyDefect evenWeight (Finset.univ : Finset (Fin 3)) = Real.log 2 := by
  have hcard : (Finset.univ : Finset (Fin 3)).card = 3 := by decide
  rw [entropyDefect, cutEntropy_evenWeight, hcard]
  norm_num
  ring

/-- The defect at the full cut is strictly positive. -/
theorem entropyDefect_evenWeight_full_pos :
    0 < entropyDefect evenWeight (Finset.univ : Finset (Fin 3)) := by
  rw [entropyDefect_evenWeight_full_eq]
  exact Real.log_pos (by norm_num)

/-- **The one-site cut of the code state is maximally entangled**: its
entanglement entropy is exactly `log 2`. -/
theorem entanglementEntropy_evenWeight_single :
    entanglementEntropy (codeState evenWeight {(0 : Fin 3)}) = Real.log 2 := by
  have h := entanglementEntropy_codeState_of_isMDS isMDS_evenWeight (by norm_num) (by norm_num)
    (S := {(0 : Fin 3)}) (by decide) (by decide)
  simpa using h

/-- **Sharpness of the guard `|S| < d`.**  At the two-site cut the quantum cut
entropy is strictly below the classical one, so the quantum cut-wise Singleton
inequality is *not* saturated there even though the code is MDS. -/
theorem entanglement_lt_cutEntropy_evenWeight :
    entanglementEntropy (codeState evenWeight {(0 : Fin 3), 1})
      < cutEntropy evenWeight {(0 : Fin 3), 1} := by
  have hlog : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have hcard : ({(0 : Fin 3), 1} : Finset (Fin 3)).card = 2 := by decide
  have hclass : cutEntropy evenWeight {(0 : Fin 3), 1} = 2 * Real.log 2 := by
    rw [cutEntropy_evenWeight, hcard]
    norm_num
  have hnorm := normalized_codeState nonempty_evenWeight ({(0 : Fin 3), 1} : Finset (Fin 3))
  have h1 := entanglementEntropy_le_log_schmidtRank hnorm
  have h2 := schmidtRank_codeState_le_pow_compl evenWeight ({(0 : Fin 3), 1} : Finset (Fin 3))
  have hcompl : (({(0 : Fin 3), 1} : Finset (Fin 3))ᶜ).card = 1 := by decide
  rw [hcompl, pow_one] at h2
  have hrk : 1 ≤ schmidtRank (codeState evenWeight {(0 : Fin 3), 1}) := schmidtRank_pos hnorm
  have hpos : (0 : ℝ) < schmidtRank (codeState evenWeight {(0 : Fin 3), 1}) := by
    exact_mod_cast hrk
  have hle : Real.log (schmidtRank (codeState evenWeight {(0 : Fin 3), 1})) ≤ Real.log 2 := by
    refine Real.log_le_log hpos ?_
    exact_mod_cast h2
  rw [hclass]
  linarith

/-! ### A negative result: the cut rank is not submodular -/

/-- The five-word code `{000, 100, 010, 110, 001}` on three bits. -/
def pentaCode : Finset (Word 3 2) :=
  Finset.univ.filter (fun c => c 2 = 0 ∨ (c 0 = 0 ∧ c 1 = 0))

lemma card_pentaCode : pentaCode.card = 5 := by decide

/-- **The cut rank is not submodular.**  For the five-word code and the cuts
`S = {0, 2}`, `T = {1, 2}` one has `r(S) r(T) = 9 < 10 = r(S ∪ T) r(S ∩ T)`, so
`log ∘ cutRank` violates the submodularity that Shannon entropy always satisfies.
Cut rank is therefore a strictly coarser invariant than cut entropy, and no
submodular (entropy-like) axiom may be added to `CutData` without losing the code
instance. -/
theorem cutRank_not_submodular :
    cutRank pentaCode {(0 : Fin 3), 2} * cutRank pentaCode {(1 : Fin 3), 2}
      < cutRank pentaCode ({(0 : Fin 3), 2} ∪ {(1 : Fin 3), 2})
          * cutRank pentaCode ({(0 : Fin 3), 2} ∩ {(1 : Fin 3), 2}) := by
  decide

end Examples

end CutIndexedSingleton