import Bridges.FourierFunctorUncertainty

/-!
# Donoho–Stark uncertainty for arbitrary finite abelian groups

`Catalog/Bridges/FourierFunctorUncertainty.lean` proved the Donoho–Stark uncertainty principle on
`ZMod N`, where the characters are explicit roots of unity. This file shows the argument is
structural rather than cyclic: it needs only that characters have modulus one and that the
character-sum inversion formula holds. We therefore obtain the uncertainty principle for an
arbitrary finite abelian group `G`, with the Fourier transform taking values on the Pontryagin
dual `AddChar G ℂ`.

## Main results

* `FiniteAbelianUncertainty.gdft_inversion` : the character-sum inversion formula
  `∑_ψ ψ b · 𝓖f(ψ) = |G| · f b`.
* `FiniteAbelianUncertainty.donoho_stark_finite_abelian` : for every nonzero `f : G → ℂ`,
  `|G| ≤ |supp f| * |supp 𝓖f|`, the support on the right being taken in the dual group.
* `FiniteAbelianUncertainty.donoho_stark_sharp_delta` : the bound is attained by delta functions,
  so it is sharp for every finite abelian group.
-/

open Finset AddChar

namespace FiniteAbelianUncertainty

variable {G : Type*} [AddCommGroup G] [Fintype G] [DecidableEq G]

/-- The Fourier transform of a function on a finite abelian group, valued on the dual group. -/
noncomputable def gdft (f : G → ℂ) (psi : AddChar G ℂ) : ℂ := ∑ a, psi (-a) * f a

open scoped Classical in
/-- Support of a function on the group. -/
noncomputable def gsupport (f : G → ℂ) : Finset G := Finset.univ.filter fun a => f a ≠ 0

open scoped Classical in
/-- Support of a function on the dual group. -/
noncomputable def dsupport (F : AddChar G ℂ → ℂ) : Finset (AddChar G ℂ) :=
  Finset.univ.filter fun psi => F psi ≠ 0

open scoped Classical in
omit [AddCommGroup G] [DecidableEq G] in
@[simp]
theorem mem_gsupport {f : G → ℂ} {a : G} : a ∈ gsupport f ↔ f a ≠ 0 := by simp [gsupport]

open scoped Classical in
omit [DecidableEq G] in
@[simp]
theorem mem_dsupport {F : AddChar G ℂ → ℂ} {psi : AddChar G ℂ} :
    psi ∈ dsupport F ↔ F psi ≠ 0 := by simp [dsupport]

/-- A weighted sum with unimodular weights, supported on a finite set, is bounded by the size of
that set times the sup bound. This is the only analytic input of the uncertainty principle. -/
theorem norm_weighted_sum_le {I : Type*} [Fintype I] (w g : I → ℂ) (K : ℝ)
    (hw : ∀ i, ‖w i‖ ≤ 1) (hK : ∀ i, ‖g i‖ ≤ K) (S : Finset I) (hS : ∀ i, i ∉ S → g i = 0) :
    ‖∑ i, w i * g i‖ ≤ S.card * K := by
  classical
  have hsum : ∑ i, w i * g i = ∑ i ∈ S, w i * g i := by
    refine (Finset.sum_subset (Finset.subset_univ _) ?_).symm
    intro x _ hx
    simp [hS x hx]
  rw [hsum]
  calc ‖∑ i ∈ S, w i * g i‖
      ≤ ∑ i ∈ S, ‖w i * g i‖ := norm_sum_le _ _
    _ ≤ ∑ _i ∈ S, K := by
        refine Finset.sum_le_sum fun i _ => ?_
        rw [norm_mul]
        exact le_trans (mul_le_mul (hw i) (hK i) (norm_nonneg _) zero_le_one)
          (le_of_eq (one_mul K))
    _ = S.card * K := by rw [Finset.sum_const, nsmul_eq_mul]

/-- **Character-sum inversion formula** on a finite abelian group. -/
theorem gdft_inversion (f : G → ℂ) (b : G) :
    ∑ psi : AddChar G ℂ, psi b * gdft f psi = (Fintype.card G : ℂ) * f b := by
  classical
  simp only [gdft, Finset.mul_sum]
  rw [Finset.sum_comm]
  have key : ∀ a : G, ∑ psi : AddChar G ℂ, psi b * (psi (-a) * f a)
      = (if b - a = 0 then (Fintype.card G : ℂ) else 0) * f a := by
    intro a
    rw [← AddChar.sum_apply_eq_ite (b - a), Finset.sum_mul]
    refine Finset.sum_congr rfl fun psi _ => ?_
    rw [← mul_assoc, ← AddChar.map_add_eq_mul]
    congr 2
    abel
  rw [Finset.sum_congr rfl fun a _ => key a, Finset.sum_eq_single b]
  · simp
  · intro c _ hc
    have : b - c ≠ 0 := sub_ne_zero.2 (Ne.symm hc)
    simp [this]
  · intro h
    exact absurd (Finset.mem_univ b) h

omit [DecidableEq G] in
/-- Every Fourier coefficient is bounded by the support size times the sup norm. -/
theorem norm_gdft_le (f : G → ℂ) (M : ℝ) (hM : ∀ a, ‖f a‖ ≤ M) (psi : AddChar G ℂ) :
    ‖gdft f psi‖ ≤ (gsupport f).card * M := by
  classical
  refine norm_weighted_sum_le (fun a => psi (-a)) f M (fun a => le_of_eq
    (AddChar.norm_apply _ _)) hM (gsupport f) ?_
  intro a ha
  by_contra h
  exact ha (mem_gsupport.2 h)

/-- **The Donoho–Stark uncertainty principle for an arbitrary finite abelian group.** A nonzero
function and its Fourier transform on the Pontryagin dual cannot both be concentrated:
`|G| ≤ |supp f| * |supp 𝓖f|`. -/
theorem donoho_stark_finite_abelian (f : G → ℂ) (hf : f ≠ 0) :
    Fintype.card G ≤ (gsupport f).card * (dsupport (gdft f)).card := by
  classical
  obtain ⟨a₀⟩ : Nonempty G := ⟨0⟩
  obtain ⟨b, -, hb⟩ :=
    Finset.exists_max_image (Finset.univ : Finset G) (fun a => ‖f a‖) ⟨a₀, mem_univ _⟩
  set M : ℝ := ‖f b‖ with hMdef
  have hM : ∀ a, ‖f a‖ ≤ M := fun a => hb a (mem_univ a)
  have hMpos : 0 < M := by
    rcases lt_or_eq_of_le (norm_nonneg (f b)) with h | h
    · exact h
    · exfalso
      apply hf
      funext a
      have : ‖f a‖ ≤ 0 := by rw [hMdef, ← h] at hM; exact hM a
      simpa using le_antisymm this (norm_nonneg _)
  have h1 : ∀ psi : AddChar G ℂ, ‖gdft f psi‖ ≤ (gsupport f).card * M := norm_gdft_le f M hM
  have h2 : ‖∑ psi : AddChar G ℂ, psi b * gdft f psi‖
      ≤ (dsupport (gdft f)).card * ((gsupport f).card * M) := by
    refine norm_weighted_sum_le (fun psi => psi b) (gdft f) _
      (fun psi => le_of_eq (AddChar.norm_apply _ _)) h1 (dsupport (gdft f)) ?_
    intro psi hpsi
    by_contra h
    exact hpsi (mem_dsupport.2 h)
  rw [gdft_inversion f b, norm_mul] at h2
  have h3 : (Fintype.card G : ℝ) * M
      ≤ (dsupport (gdft f)).card * ((gsupport f).card * M) := by
    simpa using h2
  have h4 : (Fintype.card G : ℝ) * M
      ≤ ((gsupport f).card * (dsupport (gdft f)).card : ℝ) * M := by nlinarith [h3]
  exact_mod_cast le_of_mul_le_mul_right h4 hMpos

/-! ## Sharpness -/

open scoped Classical in
/-- The delta function at `a`. -/
noncomputable def gdelta (a : G) : G → ℂ := fun x => if x = a then 1 else 0

theorem gdft_gdelta (a : G) (psi : AddChar G ℂ) : gdft (gdelta a) psi = psi (-a) := by
  classical
  rw [gdft, Finset.sum_eq_single a]
  · simp [gdelta]
  · intro c _ hc
    simp [gdelta, hc]
  · intro h
    exact absurd (Finset.mem_univ a) h

omit [AddCommGroup G] in
theorem gsupport_gdelta (a : G) : gsupport (gdelta a) = {a} := by
  classical
  ext x
  simp only [mem_gsupport, Finset.mem_singleton, gdelta]
  constructor
  · intro h
    by_contra hx
    simp [hx] at h
  · rintro rfl
    simp

theorem dsupport_gdft_gdelta (a : G) : dsupport (gdft (gdelta a)) = Finset.univ := by
  classical
  ext psi
  simp only [mem_dsupport, Finset.mem_univ, iff_true, gdft_gdelta]
  intro h
  have h1 : ‖psi (-a)‖ = 1 := AddChar.norm_apply _ _
  rw [h] at h1
  simp at h1

/-- **Sharpness for every finite abelian group.** A delta function attains the bound: its support
has one element and its transform is nonvanishing on the whole dual group, whose cardinality is
`|G|`. -/
theorem donoho_stark_sharp_delta (a : G) :
    (gsupport (gdelta a)).card * (dsupport (gdft (gdelta a))).card = Fintype.card G := by
  classical
  rw [gsupport_gdelta, dsupport_gdft_gdelta, Finset.card_singleton, one_mul, Finset.card_univ]
  exact AddChar.card_eq

end FiniteAbelianUncertainty