/-
# A Fourier-analytic sumset theorem on finite abelian groups

Building on `Catalog.Shared.FourierFiniteAbelian`, this file uses the convolution theorem,
Fourier inversion, Parseval's identity and Cauchy–Schwarz to count representations
`c = a + b` with `a ∈ A`, `b ∈ B` in a finite abelian group `G`.

Main results:

* `FourierAdd.conv_indF` : the convolution of two indicators counts representations.
* `FourierAdd.card_mul_rep_eq` : the Fourier counting formula
  `|G| * r_{A,B}(c) = ∑_ψ ψ(c) · 1̂_A(ψ) · 1̂_B(ψ)`.
* `FourierAdd.norm_error_lt` : the nonprincipal characters contribute strictly less than
  `|A| * |B|` when `(|G| - |A|)(|G| - |B|) < |A||B|`.
* `FourierAdd.exists_add_eq` : consequently `A + B = G`.  The hypothesis turns out to be
  *equivalent* to the pigeonhole bound `|A| + |B| > |G|` (see `cardCondition_iff`), so the
  Fourier/Cauchy–Schwarz route reproduces exactly the pigeonhole threshold — Cauchy–Schwarz is
  tight here.
* `FourierAdd.exists_add_eq_of_card_add_card_gt` : the classical pigeonhole corollary.
* `FourierAdd.cardCondition_iff` : the Cauchy–Schwarz hypothesis is *exactly equivalent* to
  `|A| + |B| > |G|`; so the Fourier route recovers, and does not beat, the pigeonhole threshold.
* `FourierAdd.energy_identity` : the exact Plancherel/additive-energy identity
  `|G| * ∑_c r(c)² = (|A||B|)² + ∑_{ψ ≠ 0} |1̂_A(ψ)|² |1̂_B(ψ)|²`.
* `FourierAdd.card_support_rep_ge` : the resulting quantitative covering bound
  `|{c : r(c) > 0}| ≥ |G| (|A||B|)² / ((|A||B|)² + E)`.
-/

import Mathlib
import Shared.FourierFiniteAbelian

open Finset ComplexConjugate FourierFA

namespace FourierAdd

variable {G : Type*} [AddCommGroup G] [Fintype G] [DecidableEq G]

/-- The (complex-valued) indicator function of a finset. -/
noncomputable def indF (A : Finset G) : G → ℂ := fun x => if x ∈ A then 1 else 0

/-- The number of representations `c = a + b` with `a ∈ A` and `b ∈ B`. -/
def rep (A B : Finset G) (c : G) : ℕ := (A.filter (fun y => c - y ∈ B)).card

/-- The convolution of two indicators is the representation-counting function. -/
theorem conv_indF (A B : Finset G) (c : G) :
    conv (indF A) (indF B) c = (rep A B c : ℂ) := by
  have h : ∀ y : G, indF A y * indF B (c - y)
      = if y ∈ A.filter (fun y => c - y ∈ B) then (1 : ℂ) else 0 := by
    intro y
    simp only [indF, Finset.mem_filter]
    by_cases h1 : y ∈ A <;> by_cases h2 : c - y ∈ B <;> simp [h1, h2]
  rw [conv]
  simp_rw [h]
  rw [Finset.sum_ite_mem, Finset.univ_inter, Finset.sum_const, nsmul_eq_mul, mul_one, rep]

/-- The Fourier coefficient of an indicator at the trivial character is the cardinality. -/
@[simp] theorem dft_indF_zero (A : Finset G) : dft (indF A) 0 = (A.card : ℂ) := by
  rw [dft]
  have h : ∀ x : G, conj ((0 : AddChar G ℂ) x) * indF A x
      = if x ∈ A then (1 : ℂ) else 0 := by
    intro x
    simp [indF]
  simp_rw [h]
  rw [Finset.sum_ite_mem, Finset.univ_inter, Finset.sum_const, nsmul_eq_mul, mul_one]

/-- Parseval's identity for an indicator function. -/
theorem parseval_indF (A : Finset G) :
    ∑ ψ : AddChar G ℂ, ‖dft (indF A) ψ‖ ^ 2 = (Fintype.card G : ℝ) * (A.card : ℝ) := by
  rw [parseval_norm]
  congr 1
  have h : ∀ x : G, ‖indF A x‖ ^ 2 = if x ∈ A then (1 : ℝ) else 0 := by
    intro x
    by_cases hx : x ∈ A <;> simp [indF, hx]
  simp_rw [h]
  rw [Finset.sum_ite_mem, Finset.univ_inter, Finset.sum_const, nsmul_eq_mul, mul_one]

/-- The sum of `‖1̂_A‖²` over the *nonprincipal* characters. -/
theorem sum_erase_norm_sq (A : Finset G) :
    ∑ ψ ∈ (Finset.univ : Finset (AddChar G ℂ)).erase 0, ‖dft (indF A) ψ‖ ^ 2
      = (Fintype.card G : ℝ) * (A.card : ℝ) - (A.card : ℝ) ^ 2 := by
  have h := parseval_indF A
  rw [← Finset.add_sum_erase _ _ (Finset.mem_univ (0 : AddChar G ℂ))] at h
  rw [dft_indF_zero] at h
  have h0 : ‖(A.card : ℂ)‖ ^ 2 = (A.card : ℝ) ^ 2 := by
    rw [Complex.norm_natCast]
  rw [h0] at h
  linarith

/-- **Fourier counting formula**: `|G| * r_{A,B}(c) = ∑_ψ ψ(c) 1̂_A(ψ) 1̂_B(ψ)`. -/
theorem card_mul_rep_eq (A B : Finset G) (c : G) :
    (Fintype.card G : ℂ) * (rep A B c : ℂ)
      = ∑ ψ : AddChar G ℂ, ψ c * (dft (indF A) ψ * dft (indF B) ψ) := by
  have hcard : (Fintype.card G : ℂ) ≠ 0 := by
    exact_mod_cast (Fintype.card_ne_zero (α := G))
  have hinv : conv (indF A) (indF B) c
      = (Fintype.card G : ℂ)⁻¹ * ∑ ψ : AddChar G ℂ, ψ c * dft (conv (indF A) (indF B)) ψ := by
    conv_lhs => rw [← dft_inversion (conv (indF A) (indF B))]
    rfl
  rw [conv_indF] at hinv
  have hconv : ∀ ψ : AddChar G ℂ, dft (conv (indF A) (indF B)) ψ
      = dft (indF A) ψ * dft (indF B) ψ := fun ψ => dft_conv _ _ ψ
  simp_rw [hconv] at hinv
  rw [hinv, ← mul_assoc, mul_inv_cancel₀ hcard, one_mul]

/-- Splitting off the principal character in the counting formula. -/
theorem card_mul_rep_eq_add (A B : Finset G) (c : G) :
    (Fintype.card G : ℂ) * (rep A B c : ℂ)
      = (A.card : ℂ) * (B.card : ℂ)
        + ∑ ψ ∈ (Finset.univ : Finset (AddChar G ℂ)).erase 0,
            ψ c * (dft (indF A) ψ * dft (indF B) ψ) := by
  rw [card_mul_rep_eq A B c,
    ← Finset.add_sum_erase _ _ (Finset.mem_univ (0 : AddChar G ℂ))]
  congr 1
  simp

/-- Cauchy–Schwarz bound for the nonprincipal contribution. -/
theorem norm_error_le (A B : Finset G) (c : G) :
    ‖∑ ψ ∈ (Finset.univ : Finset (AddChar G ℂ)).erase 0,
        ψ c * (dft (indF A) ψ * dft (indF B) ψ)‖ ^ 2
      ≤ ((Fintype.card G : ℝ) * A.card - (A.card : ℝ) ^ 2)
        * ((Fintype.card G : ℝ) * B.card - (B.card : ℝ) ^ 2) := by
  set s := (Finset.univ : Finset (AddChar G ℂ)).erase 0 with hs
  have h1 : ‖∑ ψ ∈ s, ψ c * (dft (indF A) ψ * dft (indF B) ψ)‖
      ≤ ∑ ψ ∈ s, ‖dft (indF A) ψ‖ * ‖dft (indF B) ψ‖ := by
    refine (norm_sum_le _ _).trans (le_of_eq ?_)
    refine Finset.sum_congr rfl fun ψ _ => ?_
    rw [norm_mul, norm_mul, AddChar.norm_apply, one_mul]
  have h2 : (∑ ψ ∈ s, ‖dft (indF A) ψ‖ * ‖dft (indF B) ψ‖) ^ 2
      ≤ (∑ ψ ∈ s, ‖dft (indF A) ψ‖ ^ 2) * ∑ ψ ∈ s, ‖dft (indF B) ψ‖ ^ 2 :=
    Finset.sum_mul_sq_le_sq_mul_sq s _ _
  have h3 : ‖∑ ψ ∈ s, ψ c * (dft (indF A) ψ * dft (indF B) ψ)‖ ^ 2
      ≤ (∑ ψ ∈ s, ‖dft (indF A) ψ‖ * ‖dft (indF B) ψ‖) ^ 2 := by
    have hnn : (0 : ℝ) ≤ ∑ ψ ∈ s, ‖dft (indF A) ψ‖ * ‖dft (indF B) ψ‖ :=
      Finset.sum_nonneg fun ψ _ => by positivity
    nlinarith [norm_nonneg (∑ ψ ∈ s, ψ c * (dft (indF A) ψ * dft (indF B) ψ)), h1, hnn]
  rw [sum_erase_norm_sq A, sum_erase_norm_sq B] at h2
  linarith

/-- Under the Cauchy–Schwarz condition, the nonprincipal contribution is strictly smaller than
the main term `|A| * |B|`. -/
theorem norm_error_lt (A B : Finset G) (c : G)
    (h : ((Fintype.card G : ℝ) - A.card) * ((Fintype.card G : ℝ) - B.card)
      < (A.card : ℝ) * (B.card : ℝ)) :
    ‖∑ ψ ∈ (Finset.univ : Finset (AddChar G ℂ)).erase 0,
        ψ c * (dft (indF A) ψ * dft (indF B) ψ)‖ < (A.card : ℝ) * (B.card : ℝ) := by
  have hAle : (A.card : ℝ) ≤ (Fintype.card G : ℝ) := by
    exact_mod_cast Finset.card_le_univ A
  have hBle : (B.card : ℝ) ≤ (Fintype.card G : ℝ) := by
    exact_mod_cast Finset.card_le_univ B
  have hA0 : (0 : ℝ) ≤ (A.card : ℝ) := Nat.cast_nonneg _
  have hB0 : (0 : ℝ) ≤ (B.card : ℝ) := Nat.cast_nonneg _
  -- both sets must be nonempty
  have hApos : (0 : ℝ) < (A.card : ℝ) := by
    rcases lt_or_eq_of_le hA0 with h' | h'
    · exact h'
    · exfalso
      rw [← h'] at h
      nlinarith [sub_nonneg.2 hBle]
  have hBpos : (0 : ℝ) < (B.card : ℝ) := by
    rcases lt_or_eq_of_le hB0 with h' | h'
    · exact h'
    · exfalso
      rw [← h'] at h
      nlinarith [sub_nonneg.2 hAle]
  have hcs := norm_error_le A B c
  have hprod : ((Fintype.card G : ℝ) * A.card - (A.card : ℝ) ^ 2)
      * ((Fintype.card G : ℝ) * B.card - (B.card : ℝ) ^ 2)
      < ((A.card : ℝ) * (B.card : ℝ)) ^ 2 := by
    have e1 : (Fintype.card G : ℝ) * A.card - (A.card : ℝ) ^ 2
        = (A.card : ℝ) * ((Fintype.card G : ℝ) - A.card) := by ring
    have e2 : (Fintype.card G : ℝ) * B.card - (B.card : ℝ) ^ 2
        = (B.card : ℝ) * ((Fintype.card G : ℝ) - B.card) := by ring
    rw [e1, e2]
    have hpos : (0 : ℝ) < (A.card : ℝ) * (B.card : ℝ) := mul_pos hApos hBpos
    nlinarith [mul_pos hApos hBpos]
  have hlt : ‖∑ ψ ∈ (Finset.univ : Finset (AddChar G ℂ)).erase 0,
      ψ c * (dft (indF A) ψ * dft (indF B) ψ)‖ ^ 2 < ((A.card : ℝ) * (B.card : ℝ)) ^ 2 :=
    lt_of_le_of_lt hcs hprod
  nlinarith [norm_nonneg (∑ ψ ∈ (Finset.univ : Finset (AddChar G ℂ)).erase 0,
      ψ c * (dft (indF A) ψ * dft (indF B) ψ)), mul_pos hApos hBpos]

/-- **Fourier-analytic sumset theorem**: if `(|G| - |A|)(|G| - |B|) < |A| |B|`, then every element
of `G` is a sum of an element of `A` and an element of `B`. -/
theorem exists_add_eq (A B : Finset G)
    (h : ((Fintype.card G : ℝ) - A.card) * ((Fintype.card G : ℝ) - B.card)
      < (A.card : ℝ) * (B.card : ℝ)) (c : G) :
    ∃ a ∈ A, ∃ b ∈ B, a + b = c := by
  have hkey := card_mul_rep_eq_add A B c
  set S := ∑ ψ ∈ (Finset.univ : Finset (AddChar G ℂ)).erase 0,
      ψ c * (dft (indF A) ψ * dft (indF B) ψ) with hS
  have hSreal : S = (((Fintype.card G : ℝ) * (rep A B c : ℝ)
      - (A.card : ℝ) * (B.card : ℝ) : ℝ) : ℂ) := by
    push_cast
    linear_combination -hkey
  have hnorm : ‖S‖ = |(Fintype.card G : ℝ) * (rep A B c : ℝ) - (A.card : ℝ) * (B.card : ℝ)| := by
    rw [hSreal, Complex.norm_real, Real.norm_eq_abs]
  have hlt := norm_error_lt A B c h
  rw [hnorm] at hlt
  have habs := abs_lt.1 hlt
  have hrep : (0 : ℝ) < (Fintype.card G : ℝ) * (rep A B c : ℝ) := by linarith [habs.1]
  have hreppos : 0 < rep A B c := by
    rcases Nat.eq_zero_or_pos (rep A B c) with h0 | h0
    · rw [h0] at hrep
      simp at hrep
    · exact h0
  -- extract a representation
  obtain ⟨a, ha⟩ := Finset.card_pos.1 hreppos
  rw [Finset.mem_filter] at ha
  exact ⟨a, ha.1, c - a, ha.2, by abel⟩

/-- Pigeonhole corollary: `|A| + |B| > |G|` implies `A + B = G`. -/
theorem exists_add_eq_of_card_add_card_gt (A B : Finset G)
    (h : Fintype.card G < A.card + B.card) (c : G) :
    ∃ a ∈ A, ∃ b ∈ B, a + b = c := by
  refine exists_add_eq A B ?_ c
  have h' : (Fintype.card G : ℝ) < (A.card : ℝ) + (B.card : ℝ) := by exact_mod_cast h
  have hAle : (A.card : ℝ) ≤ (Fintype.card G : ℝ) := by
    exact_mod_cast Finset.card_le_univ A
  have hBle : (B.card : ℝ) ≤ (Fintype.card G : ℝ) := by
    exact_mod_cast Finset.card_le_univ B
  nlinarith

/-- The hypothesis of `exists_add_eq` is *equivalent* to the pigeonhole hypothesis
`|G| < |A| + |B|`: Cauchy–Schwarz is exactly tight at this threshold. -/
theorem cardCondition_iff (N a b : ℝ) (hN : 0 < N) :
    (N - a) * (N - b) < a * b ↔ N < a + b := by
  constructor
  · intro h
    nlinarith
  · intro h
    nlinarith

/-- **Additive energy identity** (Plancherel for the representation function):
`|G| * ∑_c r(c)² = (|A| |B|)² + ∑_{ψ ≠ 0} |1̂_A(ψ)|² |1̂_B(ψ)|²`. -/
theorem energy_identity (A B : Finset G) :
    (Fintype.card G : ℝ) * ∑ c : G, ((rep A B c : ℝ)) ^ 2
      = ((A.card : ℝ) * (B.card : ℝ)) ^ 2
        + ∑ ψ ∈ (Finset.univ : Finset (AddChar G ℂ)).erase 0,
            ‖dft (indF A) ψ‖ ^ 2 * ‖dft (indF B) ψ‖ ^ 2 := by
  have hpar := parseval_norm (conv (indF A) (indF B))
  have hR : ∀ c : G, ‖conv (indF A) (indF B) c‖ ^ 2 = ((rep A B c : ℝ)) ^ 2 := by
    intro c
    rw [conv_indF, Complex.norm_natCast]
  have hL : ∀ ψ : AddChar G ℂ, ‖dft (conv (indF A) (indF B)) ψ‖ ^ 2
      = ‖dft (indF A) ψ‖ ^ 2 * ‖dft (indF B) ψ‖ ^ 2 := by
    intro ψ
    rw [dft_conv, norm_mul, mul_pow]
  simp_rw [hR, hL] at hpar
  rw [← Finset.add_sum_erase _ _ (Finset.mem_univ (0 : AddChar G ℂ))] at hpar
  rw [dft_indF_zero, dft_indF_zero, Complex.norm_natCast, Complex.norm_natCast] at hpar
  rw [← hpar]
  ring

/-- The total number of representations is `|A| * |B|`. -/
theorem sum_rep (A B : Finset G) : ∑ c : G, rep A B c = A.card * B.card := by
  have h1 : ∀ c : G, rep A B c = ∑ y ∈ A, if c - y ∈ B then 1 else 0 := by
    intro c
    rw [rep, Finset.card_filter]
  simp_rw [h1]
  rw [Finset.sum_comm]
  have h2 : ∀ y : G, ∑ c : G, (if c - y ∈ B then 1 else 0) = B.card := by
    intro y
    rw [← Equiv.sum_comp (Equiv.addRight y) (fun c => if c - y ∈ B then 1 else 0)]
    have h3 : ∀ c : G, (if (Equiv.addRight y) c - y ∈ B then 1 else 0)
        = if c ∈ B then 1 else 0 := by
      intro c
      have : (Equiv.addRight y) c - y = c := by
        show c + y - y = c
        abel
      rw [this]
    simp_rw [h3]
    rw [Finset.sum_ite_mem, Finset.univ_inter, Finset.sum_const, smul_eq_mul, mul_one]
  simp_rw [h2]
  rw [Finset.sum_const, smul_eq_mul]

/-- **Quantitative covering bound**: the number of elements of `G` that are represented as
`a + b` is at least `|G| (|A||B|)² / ((|A||B|)² + E)`, where `E` is the nonprincipal Fourier
energy appearing in `energy_identity`. -/
theorem card_support_rep_ge (A B : Finset G) (hA : A.Nonempty) (hB : B.Nonempty) :
    (Fintype.card G : ℝ) * ((A.card : ℝ) * (B.card : ℝ)) ^ 2
        / (((A.card : ℝ) * (B.card : ℝ)) ^ 2
          + ∑ ψ ∈ (Finset.univ : Finset (AddChar G ℂ)).erase 0,
              ‖dft (indF A) ψ‖ ^ 2 * ‖dft (indF B) ψ‖ ^ 2)
      ≤ ((Finset.univ : Finset G).filter (fun c => 0 < rep A B c)).card := by
  set T := (Finset.univ : Finset G).filter (fun c => 0 < rep A B c) with hT
  set E := ∑ ψ ∈ (Finset.univ : Finset (AddChar G ℂ)).erase 0,
      ‖dft (indF A) ψ‖ ^ 2 * ‖dft (indF B) ψ‖ ^ 2 with hE
  have hEnn : 0 ≤ E := Finset.sum_nonneg fun ψ _ => by positivity
  have hcardpos : (0 : ℝ) < (Fintype.card G : ℝ) := by
    exact_mod_cast Fintype.card_pos (α := G)
  have hApos : (0 : ℝ) < (A.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hA
  have hBpos : (0 : ℝ) < (B.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hB
  -- the representation function is supported on `T`
  have hsupp1 : ∑ c ∈ T, (rep A B c : ℝ) = (A.card : ℝ) * (B.card : ℝ) := by
    have h0 : ∑ c ∈ T, (rep A B c : ℝ) = ∑ c : G, (rep A B c : ℝ) := by
      refine Finset.sum_subset (Finset.subset_univ _) ?_
      intro c _ hc
      have : rep A B c = 0 := by
        by_contra h
        exact hc (Finset.mem_filter.2 ⟨Finset.mem_univ c, Nat.pos_of_ne_zero h⟩)
      rw [this]
      norm_num
    rw [h0]
    have := sum_rep A B
    exact_mod_cast congrArg (fun m : ℕ => (m : ℝ)) this
  have hsupp2 : ∑ c ∈ T, ((rep A B c : ℝ)) ^ 2 = ∑ c : G, ((rep A B c : ℝ)) ^ 2 := by
    refine Finset.sum_subset (Finset.subset_univ _) ?_
    intro c _ hc
    have : rep A B c = 0 := by
      by_contra h
      exact hc (Finset.mem_filter.2 ⟨Finset.mem_univ c, Nat.pos_of_ne_zero h⟩)
    rw [this]
    norm_num
  -- Cauchy–Schwarz on `T`
  have hcs : ((A.card : ℝ) * (B.card : ℝ)) ^ 2
      ≤ (T.card : ℝ) * ∑ c : G, ((rep A B c : ℝ)) ^ 2 := by
    have h := Finset.sum_mul_sq_le_sq_mul_sq T (fun _ => (1 : ℝ)) (fun c => (rep A B c : ℝ))
    simp only [one_mul, one_pow, Finset.sum_const, nsmul_eq_mul, mul_one] at h
    rw [hsupp1, hsupp2] at h
    exact h
  -- combine with the energy identity
  have henergy := energy_identity A B
  rw [← hE] at henergy
  have hsum : ∑ c : G, ((rep A B c : ℝ)) ^ 2
      = (((A.card : ℝ) * (B.card : ℝ)) ^ 2 + E) / (Fintype.card G : ℝ) := by
    field_simp at henergy ⊢
    linarith [henergy]
  rw [hsum] at hcs
  have hden : (0 : ℝ) < ((A.card : ℝ) * (B.card : ℝ)) ^ 2 + E := by positivity
  rw [div_le_iff₀ hden]
  have hstep : ((A.card : ℝ) * (B.card : ℝ)) ^ 2 * (Fintype.card G : ℝ)
      ≤ (T.card : ℝ) * (((A.card : ℝ) * (B.card : ℝ)) ^ 2 + E) := by
    have := mul_le_mul_of_nonneg_left hcs (le_of_lt hcardpos)
    calc ((A.card : ℝ) * (B.card : ℝ)) ^ 2 * (Fintype.card G : ℝ)
        = (Fintype.card G : ℝ) * ((A.card : ℝ) * (B.card : ℝ)) ^ 2 := by ring
      _ ≤ (Fintype.card G : ℝ) * ((T.card : ℝ)
            * ((((A.card : ℝ) * (B.card : ℝ)) ^ 2 + E) / (Fintype.card G : ℝ))) := this
      _ = (T.card : ℝ) * (((A.card : ℝ) * (B.card : ℝ)) ^ 2 + E) := by
          field_simp
  linarith [hstep]

end FourierAdd