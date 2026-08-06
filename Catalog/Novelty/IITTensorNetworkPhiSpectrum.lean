import Novelty.IITTensorNetworkSchmidtSpectrum

/-! # The spectrum of `Φ` at bond dimension two

For two-qubit chain states the integrated information satisfies
`0 ≤ Φ ≤ 2 log 2` (`phi_two_qubits_le_two_log_two`), the upper bound coming from
the Schmidt rank cap.  Here we prove the converse: **every** value of the
interval `[0, 2 log 2]` is attained, already by the one-parameter family
`c|00⟩ + s|11⟩` of `IITTensorNetworkSchmidtSpectrum.lean`.  Thus the set of
values of `Φ` on two-qubit states is exactly `[0, 2 log 2]`, which is the
`n = d = χ = 2` case of the "spectrum of `Φ` is a full interval" question.

Main results:

* `phi_two_qubits_le_two_log_two` — the cap `Φ ≤ 2 log 2` for any two-qubit state;
* `exists_qubitPair_phi_eq` — every `t ∈ [0, 2 log 2]` is the `Φ` of some state
  `c|00⟩ + s|11⟩`;
* `phi_range_qubitPair` — the range of `Φ` on the family is exactly `[0, 2 log 2]`.
-/

open Set

namespace IITTensorNetwork

section PhiSpectrum

/-- The Schmidt rank of a cut of a two-qubit state is at most `2`. -/
lemma schmidtRank_chainCutMatrix_two_qubits {psi : (Fin 2 → Fin 2) → ℂ} :
    schmidtRank (chainCutMatrix psi 1 (by omega)) ≤ 2 := by
  have h := Matrix.rank_le_card_width (chainCutMatrix psi 1 (by omega))
  simpa [schmidtRank] using h

/-- **The cap.** Any two-qubit chain state has `Φ ≤ 2 log 2`. -/
theorem phi_two_qubits_le_two_log_two {psi : (Fin 2 → Fin 2) → ℂ}
    (hpsi : ∑ s, ‖psi s‖ ^ 2 = 1) :
    Phi hpsi (le_refl 2) ≤ 2 * Real.log 2 := by
  rw [phi_two_sites hpsi]
  refine le_trans (mutualInformation_le_two_log_schmidtRank
    (normalized_chainCutMatrix hpsi 1 (by omega))) ?_
  have hrk : (schmidtRank (chainCutMatrix psi 1 (by omega)) : ℝ) ≤ 2 := by
    exact_mod_cast schmidtRank_chainCutMatrix_two_qubits (psi := psi)
  have hpos : (0 : ℝ) < schmidtRank (chainCutMatrix psi 1 (by omega)) := by
    have := schmidtRank_pos (normalized_chainCutMatrix hpsi 1 (by omega))
    exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one this
  have := Real.log_le_log hpos hrk
  linarith

/-- `Φ` of the two-qubit family, in terms of the binary entropy of `c²`. -/
theorem phi_qubitPair_binEntropy {c s : ℝ} (h : c ^ 2 + s ^ 2 = 1) :
    Phi (qubitPairState_normalized h) (le_refl 2) = 2 * Real.binEntropy (c ^ 2) := by
  rw [phi_qubitPair h, Real.binEntropy_eq_negMulLog_add_negMulLog_one_sub]
  have hs : s ^ 2 = 1 - c ^ 2 := by linarith
  rw [hs]

/-- **Every value in `[0, 2 log 2]` is attained.**  Given `t` between `0` and
`2 log 2` there is a two-qubit state `c|00⟩ + s|11⟩` with `Φ = t`. -/
theorem exists_qubitPair_phi_eq {t : ℝ} (ht : t ∈ Icc (0 : ℝ) (2 * Real.log 2)) :
    ∃ (c s : ℝ) (h : c ^ 2 + s ^ 2 = 1),
      Phi (qubitPairState_normalized h) (le_refl 2) = t := by
  have hcont : ContinuousOn (fun p : ℝ => 2 * Real.binEntropy p) (Icc 0 2⁻¹) :=
    (continuous_const.mul Real.binEntropy_continuous).continuousOn
  have hsub := intermediate_value_Icc (by norm_num : (0:ℝ) ≤ 2⁻¹) hcont
  have hmem : t ∈ Icc ((fun p : ℝ => 2 * Real.binEntropy p) 0)
      ((fun p : ℝ => 2 * Real.binEntropy p) 2⁻¹) := by
    simpa using ht
  obtain ⟨p, hp, hpt⟩ := hsub hmem
  obtain ⟨hp0, hp1⟩ := hp
  have hp1' : p ≤ 1 := by linarith
  have hnorm : Real.sqrt p ^ 2 + Real.sqrt (1 - p) ^ 2 = 1 := by
    rw [Real.sq_sqrt hp0, Real.sq_sqrt (by linarith : (0:ℝ) ≤ 1 - p)]
    ring
  refine ⟨Real.sqrt p, Real.sqrt (1 - p), hnorm, ?_⟩
  rw [phi_qubitPair_binEntropy hnorm, Real.sq_sqrt hp0]
  simpa using hpt

/-- **The spectrum of `Φ` on the two-qubit family is exactly `[0, 2 log 2]`.** -/
theorem phi_range_qubitPair :
    {t : ℝ | ∃ (c s : ℝ) (h : c ^ 2 + s ^ 2 = 1),
        Phi (qubitPairState_normalized h) (le_refl 2) = t} = Icc 0 (2 * Real.log 2) := by
  ext t
  constructor
  · rintro ⟨c, s, h, rfl⟩
    exact ⟨phi_nonneg (qubitPairState_normalized h) (le_refl 2),
      phi_two_qubits_le_two_log_two (qubitPairState_normalized h)⟩
  · intro ht
    exact exists_qubitPair_phi_eq ht

end PhiSpectrum

end IITTensorNetwork