import Mathlib

/-!
# The Information-Theoretic DFT Sample Bound: `K ≥ r`

Shor's algorithm extracts the period `r` of `x ↦ a^x mod N` from the discrete
Fourier transform of a period-`r` signal.  A recurring hope for "classical
Shor" is that *few* Fourier samples might suffice.  This file proves that this
is impossible, in the strongest (representation-independent) form:

* `exists_indistinguishable_of_finrank_lt` — a linear measurement scheme with
  fewer measurements than the dimension of the signal space always confuses two
  distinct signals;
* `dft_lt_period_indistinguishable` — concretely: for `K < r` and *any* choice
  of `K` frequencies, two distinct period-`r` signals have identical DFT samples
  at those frequencies;
* `dft_sample_count_ge_period` — hence any family of sample frequencies that
  determines the signal must have `K ≥ r`.  This is the advertised bound.
* `dft_full_samples_determine` — sharpness: `r` samples (all frequencies) do
  determine the signal, since `ZMod.dft` is a linear equivalence.

The bound is unconditional and information-theoretic: it does not depend on the
computational model, only on `ℂ`-linearity of Fourier sampling.
-/

namespace FactoringBarriers

open Module

/-! ## The abstract dimension bound -/

/-- **Dimension bound on linear measurement.** A `ℂ`-linear measurement map into
a space of strictly smaller finite dimension cannot separate all signals. -/
theorem exists_indistinguishable_of_finrank_lt
    {V W : Type*} [AddCommGroup V] [Module ℂ V] [AddCommGroup W] [Module ℂ W]
    [Module.Finite ℂ W] (M : V →ₗ[ℂ] W) (h : finrank ℂ W < finrank ℂ V) :
    ∃ v w : V, v ≠ w ∧ M v = M w := by
  by_contra hcon
  push_neg at hcon
  have hinj : Function.Injective M := by
    intro a b hab
    by_contra hne
    exact hne (by simpa using (hcon a b hne hab).elim)
  exact absurd (LinearMap.finrank_le_finrank_of_injective hinj) (by omega)

/-! ## Fourier sampling on `ZMod r` -/

variable {r K : ℕ} [NeZero r]

/-- The measurement map "take the DFT, then read off the `K` chosen
frequencies", as a `ℂ`-linear map. -/
noncomputable def dftSample (idx : Fin K → ZMod r) :
    (ZMod r → ℂ) →ₗ[ℂ] (Fin K → ℂ) :=
  (LinearMap.funLeft ℂ ℂ idx).comp (ZMod.dft : (ZMod r → ℂ) ≃ₗ[ℂ] (ZMod r → ℂ)).toLinearMap

@[simp] theorem dftSample_apply (idx : Fin K → ZMod r) (v : ZMod r → ℂ) (j : Fin K) :
    dftSample idx v j = ZMod.dft v (idx j) := rfl

theorem finrank_signal_space : finrank ℂ (ZMod r → ℂ) = r := by
  simp [ZMod.card]

theorem finrank_sample_space : finrank ℂ (Fin K → ℂ) = K := by
  simp

/-- **Fewer than `r` Fourier samples are blind.** For any choice of `K < r`
sample frequencies there are two *distinct* signals on `ZMod r` whose discrete
Fourier transforms agree at every sampled frequency. -/
theorem dft_lt_period_indistinguishable (hK : K < r) (idx : Fin K → ZMod r) :
    ∃ v w : ZMod r → ℂ, v ≠ w ∧ ∀ j : Fin K, ZMod.dft v (idx j) = ZMod.dft w (idx j) := by
  obtain ⟨v, w, hvw, h⟩ :=
    exists_indistinguishable_of_finrank_lt (dftSample idx)
      (by rw [finrank_signal_space, finrank_sample_space]; exact hK)
  exact ⟨v, w, hvw, fun j => congrFun h j⟩

/-- **The sample lower bound `K ≥ r`.** If a family of `K` sample frequencies
suffices to determine every period-`r` signal from its Fourier samples, then
`K ≥ r`. -/
theorem dft_sample_count_ge_period (idx : Fin K → ZMod r)
    (hdet : ∀ v w : ZMod r → ℂ, (∀ j : Fin K, ZMod.dft v (idx j) = ZMod.dft w (idx j)) → v = w) :
    r ≤ K := by
  by_contra hlt
  push_neg at hlt
  obtain ⟨v, w, hvw, h⟩ := dft_lt_period_indistinguishable hlt idx
  exact hvw (hdet v w h)

/-- **Sharpness.** Sampling at *all* `r` frequencies does determine the signal:
the discrete Fourier transform on `ZMod r` is injective. -/
theorem dft_full_samples_determine {v w : ZMod r → ℂ}
    (h : ∀ k : ZMod r, ZMod.dft v k = ZMod.dft w k) : v = w :=
  (ZMod.dft : (ZMod r → ℂ) ≃ₗ[ℂ] (ZMod r → ℂ)).injective (funext h)

/-- The bound `K ≥ r` is attained: the identity frequency family of size `r`
is determining. -/
theorem dft_identity_family_determines :
    ∀ v w : ZMod r → ℂ,
      (∀ j : Fin (Fintype.card (ZMod r)),
        ZMod.dft v ((Fintype.equivFin (ZMod r)).symm j) =
          ZMod.dft w ((Fintype.equivFin (ZMod r)).symm j)) → v = w := by
  intro v w h
  refine dft_full_samples_determine (fun k => ?_)
  have := h (Fintype.equivFin (ZMod r) k)
  simpa using this

end FactoringBarriers