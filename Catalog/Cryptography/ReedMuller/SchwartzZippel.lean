/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Cryptography.ReedMuller.Defs

/-!
# Schwartz–Zippel Lemma for Reed–Muller Codes

This file derives the zero-count form of the Schwartz–Zippel lemma from Mathlib's
existing `MvPolynomial.schwartz_zippel_totalDegree`, specialized to evaluation over
the full finite field `𝔽_q^n`.

The key result is that a nonzero polynomial of total degree `d` over `𝔽_q` has at most
`d · q^(n-1)` zeros in `𝔽_q^n`.
-/

noncomputable section

open MvPolynomial Finset Fintype

variable {𝔽 : Type*} [Field 𝔽] [Fintype 𝔽] [DecidableEq 𝔽]

/-- The piFinset over univ equals univ for function types. -/
theorem piFinset_univ_eq_univ {n : ℕ} :
    (Fintype.piFinset (fun _ : Fin n => (Finset.univ : Finset 𝔽))) = Finset.univ := by
  ext x; simp [Fintype.mem_piFinset]

/-- The Schwartz–Zippel bound as an NNRat inequality, specialized to full `𝔽^n`. -/
theorem schwartz_zippel_nnrat {n : ℕ}
    (f : MvPolynomial (Fin n) 𝔽) (hf : f ≠ 0) :
    ((Finset.univ.filter (fun x : Fin n → 𝔽 => MvPolynomial.eval x f = 0)).card : ℚ≥0) /
      ((Finset.univ : Finset 𝔽).card ^ n : ℚ≥0) ≤
    f.totalDegree / (Finset.univ : Finset 𝔽).card := by
  have h := MvPolynomial.schwartz_zippel_totalDegree hf (Finset.univ : Finset 𝔽)
  rwa [piFinset_univ_eq_univ] at h

/-
**Schwartz–Zippel Lemma (zero-count form)**: A nonzero multivariate polynomial
of total degree at most `d` over a finite field `𝔽_q` has at most `d · q^(n-1)` zeros
in `𝔽_q^n`.

Derived from Mathlib's `MvPolynomial.schwartz_zippel_totalDegree`.
-/
theorem schwartz_zippel_bound
    (n : ℕ) (hn : 1 ≤ n) (d : ℕ)
    (f : MvPolynomial (Fin n) 𝔽) (hf : f ≠ 0) (hd : f.totalDegree ≤ d) :
    zeroCount f ≤ d * (Fintype.card 𝔽) ^ (n - 1) := by
  have h_schwartz_zippel_nat : ∀ (f : MvPolynomial (Fin n) 𝔽), f ≠ 0 → (Finset.univ.filter (fun x : Fin n → 𝔽 => MvPolynomial.eval x f = 0)).card ≤ f.totalDegree * Fintype.card 𝔽 ^ (n - 1) := by
    intro f hf
    have := @ schwartz_zippel_nnrat;
    specialize this f hf;
    rw [ div_le_div_iff₀ ] at this <;> norm_cast at * <;> simp_all +decide [ Finset.card_univ ];
    · cases n <;> simp_all +decide [ pow_succ', mul_assoc ] ; nlinarith [ show 0 < Fintype.card 𝔽 from Fintype.card_pos ];
    · exact pow_pos ( Fintype.card_pos ) _;
    · exact Fintype.card_pos;
  exact le_trans ( h_schwartz_zippel_nat f hf ) ( Nat.mul_le_mul_right _ hd )

end