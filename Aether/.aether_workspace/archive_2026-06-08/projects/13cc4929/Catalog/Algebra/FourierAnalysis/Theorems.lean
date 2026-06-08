/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Fourier Analysis on Finite Abelian Groups — Main Theorems

This file proves the three pillars of Fourier analysis on finite abelian groups:

1. **Parseval/Plancherel identity**: The Fourier transform preserves inner products
   (up to scaling by `|G|`).
2. **Convolution theorem**: Fourier transform diagonalizes convolution.
3. **Uncertainty principle**: `|supp(f)| * |supp(f̂)| ≥ |G|` for nonzero `f`.

All theorems are proved in the representation-theoretic setting of
`FiniteCharacterBasis`, making them valid for any finite abelian group.

## References

* Terras, *Fourier Analysis on Finite Groups and Applications*
* Donoho–Stark, *Uncertainty principles and signal recovery*
-/

import Algebra.FourierAnalysis.Defs

open Finset Complex BigOperators

noncomputable section

namespace FiniteCharacterBasis

variable {G : Type*} [Fintype G] [CommGroup G] [DecidableEq G]
variable (B : FiniteCharacterBasis G)

/-! ## Parseval's identity -/

/-
**Parseval's identity for finite character bases.**
The inner product of the Fourier transforms equals `|G|` times the inner
product of the original functions:
  `∑_i f̂(i) * conj(ĥ(i)) = |G| * ∑_g f(g) * conj(h(g))`.

This is the representation-theoretic energy conservation law: expanding
functions in the character basis preserves the Hilbert-space inner product
up to the canonical normalization factor.
-/
theorem parseval_finiteCharacterBasis (f h : G → ℂ) :
    ∑ i : B.ι, B.fourierTransform f i * starRingEnd ℂ (B.fourierTransform h i)
      = (Fintype.card G : ℂ) * ∑ g : G, f g * starRingEnd ℂ (h g) := by
        unfold FiniteCharacterBasis.fourierTransform;
        simp +decide only [mul_comm, map_sum, star_mul, map_mul, map_neg, star_neg, starRingEnd_apply,
            map_smul, Finset.mul_sum, Finset.sum_mul];
        simp +decide only [star_star, mul_comm, mul_left_comm, mul_assoc];
        -- By Fubini's theorem, we can interchange the order of summation.
        have h_fubini : ∑ x : B.ι, ∑ x_1 : G, ∑ x_2 : G, f x_2 * (star (h x_1) * (B.χ x x_1 * star (B.χ x x_2))) = ∑ x_1 : G, ∑ x_2 : G, f x_2 * star (h x_1) * ∑ x : B.ι, B.χ x x_1 * star (B.χ x x_2) := by
          simp +decide only [Finset.mul_sum _ _ _, mul_assoc];
          exact Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_comm );
        simp_all +decide [ B.dual_orthogonal ];
        ac_rfl

/-
**Plancherel theorem (norm-square form).**
  `∑_i |f̂(i)|² = |G| * ∑_g |f(g)|²`.
-/
theorem plancherel_finiteCharacterBasis (f : G → ℂ) :
    ∑ i : B.ι, Complex.normSq (B.fourierTransform f i)
      = (Fintype.card G : ℝ) * ∑ g : G, Complex.normSq (f g) := by
        convert parseval_finiteCharacterBasis B f f using 1;
        norm_num [ ← Complex.ofReal_inj, Complex.normSq_eq_norm_sq, Complex.mul_conj ]

/-! ## Convolution theorem -/

/-
**Convolution theorem for finite abelian groups.**
The Fourier transform converts convolution to pointwise multiplication:
  `(f * h)^(i) = f̂(i) * ĥ(i)`
where `*` denotes group convolution.

This is the structural theorem that makes Fourier analysis an algorithmic
engine: any linear translation-invariant operation becomes a pointwise
multiplication in frequency space.
-/
theorem fourier_convolution (f h : G → ℂ) :
    B.fourierTransform (B.convolution f h)
      = fun i => B.fourierTransform f i * B.fourierTransform h i := by
        funext i;
        nontriviality;
        unfold FiniteCharacterBasis.convolution FiniteCharacterBasis.fourierTransform;
        simp +decide only [mul_comm, Finset.sum_mul _ _ _];
        rw [ Finset.sum_comm ];
        simp +decide only [mul_assoc, Finset.mul_sum _ _ _];
        refine' Finset.sum_congr rfl fun x _ => _;
        rw [ ← Equiv.sum_comp ( Equiv.mulRight x ) ] ; simp +decide [ mul_assoc, mul_comm, mul_left_comm, B.map_mul ]

/-! ## Finite uncertainty principle -/

/-
Auxiliary: the Fourier transform of a nonzero function is nonzero.
-/
lemma fourierTransform_ne_zero_of_ne_zero (f : G → ℂ) (hf : ∃ g : G, f g ≠ 0) :
    ∃ i : B.ι, B.fourierTransform f i ≠ 0 := by
      by_contra h;
      convert plancherel_finiteCharacterBasis B f using 1;
      simp_all +decide [ funext_iff, Complex.normSq_eq_norm_sq ];
      exact ne_of_gt ( lt_of_lt_of_le ( by exact sq_pos_of_pos ( norm_pos_iff.mpr hf.choose_spec ) ) ( Finset.single_le_sum ( fun x _ => sq_nonneg ( ‖f x‖ ) ) ( Finset.mem_univ _ ) ) )

/-
Auxiliary: support-spectral bound via Cauchy-Schwarz / L1-L∞ argument.
-/
lemma support_spectral_bound (f : G → ℂ) (hf : ∃ g : G, f g ≠ 0) :
    (Fintype.card G : ℝ) ≤
      (Fintype.card {g : G // f g ≠ 0} : ℝ) *
      (Fintype.card {i : B.ι // B.fourierTransform f i ≠ 0} : ℝ) := by
        -- Let $S = \{g \in G : f(g) \neq 0\}$ and $T = \{i \in B.ι : B.fourierTransform f i \neq 0\}$.
        set S := {g : G | f g ≠ 0}
        set T := {i : B.ι | B.fourierTransform f i ≠ 0};
        -- By the Cauchy-Schwarz inequality, we have $\left( \sum_{g \in S} |f(g)| \right)^2 \leq |S| \sum_{g \in S} |f(g)|^2$.
        have h_cauchy_schwarz : (∑ g ∈ Finset.univ.filter (fun g => f g ≠ 0), ‖f g‖) ^ 2 ≤ (Fintype.card { g // f g ≠ 0 }) * (∑ g ∈ Finset.univ.filter (fun g => f g ≠ 0), ‖f g‖ ^ 2) := by
          have h_cauchy_schwarz : ∀ (s : Finset G) (f : G → ℝ), (∑ g ∈ s, f g) ^ 2 ≤ (s.card : ℝ) * ∑ g ∈ s, f g ^ 2 := by
            intro s f; have := Finset.sum_le_sum fun x ( hx : x ∈ s ) => mul_self_nonneg ( f x - ( ∑ y ∈ s, f y ) / s.card ) ; by_cases hs : s = ∅ <;> simp_all +decide [ sub_sq, mul_div_cancel₀ ] ;
            simp_all +decide [ add_mul, sub_mul, mul_sub ];
            case _ => simp_all +decide only [← Finset.sum_mul, ← sq, ← Finset.mul_sum _ _ _] ; nlinarith [ mul_div_cancel₀ ( ( ∑ y ∈ s, f y ) : ℝ ) ( Nat.cast_ne_zero.mpr <| Finset.card_ne_zero_of_mem <| Classical.choose_spec <| Finset.nonempty_of_ne_empty hs ) ] ;
          convert h_cauchy_schwarz ( Finset.univ.filter fun g => f g ≠ 0 ) ( fun g => ‖f g‖ ) using 1 ; simp +decide [ Fintype.card_subtype ];
        -- Also, $\sum_{i \in T} |B.fourierTransform f i|^2 \leq |T| \left( \sum_{g \in S} |f(g)| \right)^2$.
        have h_fourier_sum : (∑ i ∈ Finset.univ.filter (fun i => B.fourierTransform f i ≠ 0), Complex.normSq (B.fourierTransform f i)) ≤ (Fintype.card { i // B.fourierTransform f i ≠ 0 }) * (∑ g ∈ Finset.univ.filter (fun g => f g ≠ 0), ‖f g‖) ^ 2 := by
          -- By the properties of the Fourier transform, we have $|B.fourierTransform f i| \leq \sum_{g \in S} |f(g)|$ for all $i \in T$.
          have h_fourier_bound : ∀ i ∈ Finset.univ.filter (fun i => B.fourierTransform f i ≠ 0), Complex.normSq (B.fourierTransform f i) ≤ (∑ g ∈ Finset.univ.filter (fun g => f g ≠ 0), ‖f g‖) ^ 2 := by
            intro i hi
            have h_fourier_bound : ‖B.fourierTransform f i‖ ≤ ∑ g ∈ Finset.univ.filter (fun g => f g ≠ 0), ‖f g‖ := by
              refine' le_trans ( norm_sum_le _ _ ) _;
              simp +decide [ Finset.sum_filter, B.χ_norm_one ];
              refine' Finset.sum_le_sum fun x _ => _ <;> simp_all +decide [ Complex.normSq_eq_norm_sq, B.χ_norm_one ] ;
              have := B.χ_norm_one i x; simp_all +decide [ Complex.normSq_eq_norm_sq ] ;
              cases this <;> split_ifs <;> simp_all +decide [ norm_eq_zero ];
            simpa only [ sq, Complex.normSq_eq_norm_sq ] using pow_le_pow_left₀ ( by positivity ) h_fourier_bound 2;
          refine' le_trans ( Finset.sum_le_sum h_fourier_bound ) _;
          simp +decide [ Fintype.card_subtype ];
        -- By Parseval's identity, we have $\sum_{i \in T} |B.fourierTransform f i|^2 = |G| \sum_{g \in S} |f(g)|^2$.
        have h_parseval : (∑ i ∈ Finset.univ.filter (fun i => B.fourierTransform f i ≠ 0), Complex.normSq (B.fourierTransform f i)) = (Fintype.card G : ℝ) * (∑ g ∈ Finset.univ.filter (fun g => f g ≠ 0), ‖f g‖ ^ 2) := by
          have := B.plancherel_finiteCharacterBasis f;
          simp_all +decide [ Complex.normSq_eq_norm_sq, Finset.sum_filter_of_ne ];
        nlinarith [ show 0 < ∑ g with f g ≠ 0, ‖f g‖ ^ 2 from Finset.sum_pos ( fun g hg => sq_pos_of_pos <| norm_pos_iff.mpr <| by aesop ) ⟨ hf.choose, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hf.choose_spec ⟩ ⟩ ]

/-
**Finite uncertainty principle.**
For any nonzero function `f` on a finite abelian group, the product of the
support size and the spectral support size is at least the group order:
  `|supp(f)| * |supp(f̂)| ≥ |G|`.

This is the finite-group avatar of the Heisenberg uncertainty principle:
a function cannot be simultaneously localized in physical space and
frequency space.
-/
theorem uncertainty_principle_finite_abelian
    (f : G → ℂ)
    (hf : ∃ g : G, f g ≠ 0) :
    (Fintype.card {g : G // f g ≠ 0}) *
      (Fintype.card {i : B.ι // B.fourierTransform f i ≠ 0})
        ≥ Fintype.card G := by
          convert support_spectral_bound B f hf using 1;
          norm_cast

/-! ## Cross-domain: unitarity (quantum interpretation) -/

/-- **Fourier transform preserves inner products (quantum unitarity).**
In quantum mechanics on a finite configuration space, functions `G → ℂ`
are wavefunctions. The Fourier transform is the change from position basis
to momentum basis, and Parseval's identity says it preserves probability
amplitudes (up to normalization). This is a direct restatement of Parseval. -/
theorem fourier_is_unitary_scaled (f h : G → ℂ) :
    ∑ i : B.ι, B.fourierTransform f i * starRingEnd ℂ (B.fourierTransform h i)
      = (Fintype.card G : ℂ) * ∑ g : G, f g * starRingEnd ℂ (h g) :=
  B.parseval_finiteCharacterBasis f h

/-! ## Additive energy identity -/

/-- Additive energy of a set `A` in a group `G`: the number of quadruples
`(a₁, a₂, a₃, a₄) ∈ A⁴` with `a₁ * a₂⁻¹ = a₃ * a₄⁻¹`. -/
def additiveEnergy (A : Finset G) : ℕ :=
  ((A ×ˢ A ×ˢ (A ×ˢ A)).filter
    fun p : G × G × (G × G) => p.1 * p.2.1⁻¹ = p.2.2.1 * p.2.2.2⁻¹).card

end FiniteCharacterBasis

end