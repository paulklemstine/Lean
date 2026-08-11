import Geometry.CSSDistance

/-!
# The Steane code `[[7,1,3]]` as a test of the CSS dictionary and of CSS distance

The two preceding files of this cycle set up

* the dictionary "commuting parity checks ⟷ chain complex ⟷ stabilizer group"
  (`Catalog/Geometry/CSSDictionary.lean`), and
* the operational CSS distance with the theorem
  `d = min(systole, cosystole)` (`Catalog/Geometry/CSSDistance.lean`).

A framework of this kind is only as good as the codes it can certify, so here we
run it on the standard nontrivial example: the **Steane code**, obtained from the
`[7,4,3]` Hamming code by the CSS construction with `H_X = H_Z = H`, where the
columns of `H` are the nonzero binary triples.  We prove, with no numerical
input taken on faith:

* `steaneH_orthogonal` : `H Hᵀ = 0` — the Hamming code contains its dual, which
  is exactly the CSS commutation condition;
* `steaneH_rank` : `rank H = 3`, via surjectivity of `v ↦ H *ᵥ v`;
* `steane_numLogical_eq_one` : `k = 1` — one logical qubit, from the catalog
  dimension formula `k + rank H_X + rank H_Z = N`;
* `steane_dX_eq_three`, `steane_cssDistance_eq_three` : `d = 3`, both sectors,
  via the `min(systole, cosystole)` theorem;
* `steane_singleton` : the parameters satisfy the quantum Singleton bound
  `k + 2(d−1) ≤ N` with `N = 7` — and do *not* saturate it.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  If the abstract machinery is correct, feeding it the
Hamming parity-check matrix must return exactly `[[7,1,3]]`, with no extra
hypotheses beyond `H Hᵀ = 0`.

EXPERIMENT (Experimenter).  The finite verifications (`H Hᵀ = 0`; the minimum
weight `3` of a nontrivial undetectable error, over all `2⁷ = 128` candidates
and all `2³ = 8` stabilizer combinations) are kernel-checked by `decide`; the
structural steps (rank, `k`, `d = min(dX, dZ)`) are genuine proofs using the
catalog theorems, not evaluation.

ANALYSIS (Analyst).  Contrast with `Catalog/Geometry/HypercubeDistanceOne.lean`:
the hypercube graph code has a huge `k` but `d = 1`, while the Steane code has
`k = 1` and `d = 3`.  Both are computed by the *same* definitions, which is the
point of target 3: the distance is a property of the pair `(H_X, H_Z)`, never of
the primal sector alone.

CRITIQUE (Critic).  `decide` is used only for genuinely finite statements about
a fixed `3 × 7` matrix; every parameter of the code (`N`, `k`, `d`) is then
derived through the general theorems, so this section cannot be dismissed as a
brute-force computation of a definition.
-/

namespace HQECC
namespace SteaneCode

open Matrix Module CSSDictionary CSSDistance

/-- The parity-check matrix of the `[7,4,3]` Hamming code: column `j` is the
binary expansion of `j + 1`. -/
def steaneH : Matrix (Fin 3) (Fin 7) (ZMod 2) :=
  !![1,0,1,0,1,0,1; 0,1,1,0,0,1,1; 0,0,0,1,1,1,1]

/-- **The Hamming code contains its dual**: `H Hᵀ = 0`, i.e. the CSS
commutation condition holds for `H_X = H_Z = H`. -/
theorem steaneH_orthogonal : steaneH * steaneHᵀ = 0 := by decide

/-- Membership in the row space, in a decidable form. -/
lemma mem_rowSpace_iff (a : Fin 7 → ZMod 2) :
    a ∈ rowSpace steaneH ↔ ∃ y : Fin 3 → ZMod 2, steaneHᵀ *ᵥ y = a := Iff.rfl

/-- The three parity checks are independent: `v ↦ H *ᵥ v` is onto `𝔽₂³`
(columns `0, 1, 3` form an identity block). -/
lemma steaneH_surj : Function.Surjective steaneH.mulVecLin := by
  intro y
  refine ⟨fun j => if j = 0 then y 0 else if j = 1 then y 1 else if j = 3 then y 2 else 0, ?_⟩
  revert y
  decide

/-- `rank H = 3`. -/
theorem steaneH_rank : steaneH.rank = 3 := by
  have h : LinearMap.range steaneH.mulVecLin = ⊤ := LinearMap.range_eq_top.2 steaneH_surj
  unfold Matrix.rank
  rw [h]
  simp [Module.finrank_fintype_fun_eq_card]

/-- The Steane code as a chain complex `𝔽₂³ --Hᵀ--> 𝔽₂⁷ --H--> 𝔽₂³`. -/
noncomputable def steaneComplex : CSSComplex (ZMod 2) (Fin 3 → ZMod 2) (Fin 7 → ZMod 2)
    (Fin 3 → ZMod 2) :=
  cssComplex steaneH steaneH steaneH_orthogonal

/-- **`k = 1`.**  The Steane code encodes exactly one logical qubit:
`k = N − rank H_X − rank H_Z = 7 − 3 − 3`. -/
theorem steane_numLogical_eq_one : steaneComplex.numLogical = 1 := by
  have h := cssComplex_numLogical_add steaneH steaneH steaneH_orthogonal
  rw [steaneH_rank, Fintype.card_fin] at h
  show (cssComplex steaneH steaneH steaneH_orthogonal).numLogical = 1
  omega

/-! ## Distance -/

set_option maxRecDepth 100000 in
/-- Every nontrivial undetectable error of a single type has weight at least
`3` (a finite check over all `128` candidates). -/
lemma steane_min_weight : ∀ a : Fin 7 → ZMod 2, steaneH *ᵥ a = 0 →
    (¬ ∃ y : Fin 3 → ZMod 2, steaneHᵀ *ᵥ y = a) → 3 ≤ wt a := by decide

/-- A weight-three logical operator: `X₁X₂X₃` is a codeword of the Hamming code
that is not a sum of parity checks. -/
lemma steane_logical_witness :
    (3 : ℕ) ∈ {w | ∃ a, XLogical steaneH steaneH a ∧ wt a = w} := by
  refine ⟨![1,1,1,0,0,0,0], ⟨by decide, ?_⟩, by decide⟩
  rw [mem_rowSpace_iff]
  decide

/-- **The primal distance is `3`.** -/
theorem steane_dX_eq_three : dX steaneH steaneH = 3 := by
  refine le_antisymm (Nat.sInf_le steane_logical_witness) ?_
  obtain ⟨a, ha, hwa⟩ := Nat.sInf_mem (⟨3, steane_logical_witness⟩ :
    Set.Nonempty {w | ∃ a, XLogical steaneH steaneH a ∧ wt a = w})
  have hlow : 3 ≤ wt a := steane_min_weight a ha.1 (fun h => ha.2 ((mem_rowSpace_iff a).2 h))
  rw [hwa] at hlow
  exact hlow

/-- The dual distance coincides with the primal one, the code being
self-dual as a CSS pair (`H_X = H_Z`). -/
theorem steane_dZ_eq_three : dZ steaneH steaneH = 3 := steane_dX_eq_three

/-- **The Steane code has CSS distance `3`**, by the `min(systole, cosystole)`
theorem. -/
theorem steane_cssDistance_eq_three : cssDistance steaneH steaneH = 3 := by
  have hX : {w | ∃ a, XLogical steaneH steaneH a ∧ wt a = w}.Nonempty :=
    ⟨3, steane_logical_witness⟩
  have hZ : {w | ∃ b, ZLogical steaneH steaneH b ∧ wt b = w}.Nonempty :=
    ⟨3, steane_logical_witness⟩
  rw [cssDistance_eq_min steaneH steaneH hX hZ, steane_dX_eq_three, steane_dZ_eq_three]
  simp

/-- **Quantum Singleton bound with the correct block length.**  For the Steane
code `N = 7`, `k = 1`, `d = 3`: `k + 2(d − 1) = 5 ≤ 7`, and the inequality is
strict, so the code is not quantum-MDS. -/
theorem steane_singleton :
    steaneComplex.numLogical + 2 * (cssDistance steaneH steaneH - 1) < Fintype.card (Fin 7) := by
  rw [steane_numLogical_eq_one, steane_cssDistance_eq_three]
  simp

end SteaneCode
end HQECC