/-
# Consequences: Chebotarev's property and Tao's additive uncertainty principle

The catalog reduces Tao's additive uncertainty principle on `ZMod p`,

  `|supp f| + |supp f̂| ≥ p + 1`  for every `f ≠ 0`,

to `PrimeUncertainty.ChebotarevProperty p`, the nonsingularity of *all* minors of the DFT
matrix (`PrimeUncertainty.chebotarev_iff_sumUncertainty`), and settles the property only for
minors of size `≤ 3`.  Having proved Chebotarev's theorem in full
(`ParityGap.det_ez_ne_zero`), we can now discharge both statements unconditionally, for every
size and every prime.

Main results:

* `ParityGap.chebotarevProperty` — every minor of the DFT matrix of `ZMod p` is nonsingular;
* `ParityGap.sumUncertainty` — **Tao's additive uncertainty principle** for prime moduli;
* `ParityGap.card_supp_add_card_supp_dft` — its unfolded form;
* `ParityGap.exists_minimal_coxeterLength_witness` — Conjecture A with the Coxeter-length
  refinement, stated with the genuine inversion-counting length of
  `Catalog.Probability.ParityGap.CoxeterLength`.
-/

import Mathlib
import Probability.Chebotarev
import Probability.CoxeterLength

open Finset FourierFA FourierCyclic PrimeUncertainty

namespace ParityGap

variable {p : ℕ} [hp : Fact p.Prime]

/-- **Chebotarev's theorem.**  Every square submatrix of the DFT matrix of `ZMod p` indexed by
injective families of rows and columns is nonsingular — in every size, including the degenerate
sizes `0` and `1`. -/
theorem chebotarevProperty : ChebotarevProperty p := by
  intro n S T hS hT
  match n, S, T, hS, hT with
  | 0, S, T, _, _ => simp
  | 1, S, T, _, _ =>
    rw [Matrix.det_fin_one]
    exact ez_ne_zero _
  | (m + 2), S, T, hS, hT => exact det_ez_ne_zero S T (by omega) hS hT

/-- **Tao's additive uncertainty principle** for a prime modulus: a nonzero function on `ZMod p`
and its Fourier transform have supports of total size at least `p + 1`. -/
theorem sumUncertainty : SumUncertainty p := sumUncertainty_of_chebotarev chebotarevProperty

/-- The additive uncertainty principle, unfolded. -/
theorem card_supp_add_card_supp_dft (f : ZMod p → ℂ) (hf : f ≠ 0) :
    p + 1 ≤ (supp f).card + (supp (dftZMod f)).card := sumUncertainty f hf

/-- **Conjecture A with the Coxeter-length refinement.**  For injective `S, T` there is a
permutation `σ` whose exponent `∑_j S (σ j) T j` carries a nonzero parity-weighted count, and
which has minimal Coxeter length (number of inversions) among all permutations realising that
same exponent. -/
theorem exists_minimal_coxeterLength_witness {n : ℕ} (S T : Fin n → ZMod p)
    (hS : Function.Injective S) (hT : Function.Injective T) :
    ∃ σ : Equiv.Perm (Fin n), permCoeff S T (permExp S T σ) ≠ 0 ∧
      ∀ τ : Equiv.Perm (Fin n), permExp S T τ = permExp S T σ →
        coxeterLength σ ≤ coxeterLength τ :=
  exists_minimal_length_witness S T hS hT coxeterLength

/-- The Donoho–Stark multiplicative bound is subsumed: for a prime modulus the product of the
support sizes is at least `p`.  (It follows from the sharper additive bound, since `ab + 1 ≥
a + b` for positive integers.) -/
theorem card_supp_mul_card_supp_dft (f : ZMod p → ℂ) (hf : f ≠ 0) :
    p ≤ (supp f).card * (supp (dftZMod f)).card := by
  have h := card_supp_add_card_supp_dft f hf
  have ha : 1 ≤ (supp f).card := by
    rcases Function.ne_iff.1 hf with ⟨x, hx⟩
    exact Finset.card_pos.mpr ⟨x, mem_supp.2 (by simpa using hx)⟩
  have hb : 1 ≤ (supp (dftZMod f)).card := by
    have hdf : dftZMod f ≠ 0 := dft_ne_zero f hf
    rcases Function.ne_iff.1 hdf with ⟨x, hx⟩
    exact Finset.card_pos.mpr ⟨x, mem_supp.2 (by simpa using hx)⟩
  obtain ⟨a, hA⟩ : ∃ a, (supp f).card = a + 1 := ⟨(supp f).card - 1, by omega⟩
  obtain ⟨b, hB⟩ : ∃ b, (supp (dftZMod f)).card = b + 1 :=
    ⟨(supp (dftZMod f)).card - 1, by omega⟩
  rw [hA, hB] at h ⊢
  nlinarith [h]

end ParityGap