/-
# Consequences of the rigidity theorem for the Donoho–Stark uncertainty principle

Building on `Catalog.Novelty.FourierUncertaintyRigidity`, which proves that the extremals of
`|supp f| · |supp f̂| ≥ |G|` are exactly the modulated coset indicators, this file extracts the
structural and arithmetic consequences of that classification.

Main results:

* `FourierFA.dft_coset_modulation` : the *explicit* Fourier transform of a modulated coset
  indicator, `c · χ · 1_{a+H}`.
* `FourierFA.supp_dft_coset_modulation` : consequently its spectrum is exactly the coset
  `χ + H^⊥` of the annihilator — the extremal picture is *self-dual*.
* `FourierFA.IsExtremal.norm_eq_l1norm` : on an extremal, `|f|` is constant with value
  `‖f‖₁ / |supp f|`.
* `FourierFA.IsExtremal.sub_add_mem_supp` : the support of an extremal is closed under
  `x - y + z` (i.e. it is a coset), a statement free of any auxiliary subgroup.
* `FourierFA.IsExtremal.dft_isExtremal` : **self-duality of extremality** — the Fourier transform of an
  extremal function is an extremal function on the Pontryagin dual (proved through
  `AddChar.doubleDualEmb`).
* `FourierFA.extremal_classification_of_prime` : for `|G|` prime the only extremals are the
  scaled Dirac deltas and the scaled characters — an arithmetic dichotomy with no intermediate
  regime.
* `FourierFA.IsExtremal.mem_phaseSubgroup_iff`, `FourierFA.IsExtremal.phaseSubgroup_eq` : the
  phase subgroup used in the rigidity proof is intrinsic — it is the group of periods of
  `supp f`, independent of the spectral character chosen.
* `FourierFA.exists_isExtremal_supp_eq` : conversely every coset occurs as an extremal support,
  so the divisibility obstruction is sharp.
* `FourierFA.IsExtremal.exists_modulation_of_supp_eq`,
  `FourierFA.subgroup_unique_of_isCosetModulation` : the extremals with a fixed support form one
  orbit of the scaling–modulation group, and the subgroup in the classification is unique.
* `FourierFA.uncertainty_gap_of_not_cosetModulation` : a quantitative gap — if `|supp f|` divides
  `|G|` and `f` is not extremal, the uncertainty product exceeds `|G|` by at least `|supp f|`.
* `FourierFA.indicator_isExtremal_iff_coset` : the purely combinatorial form — a set is extremal
  for the uncertainty principle iff it is a coset.
-/

import Mathlib
import Catalog.Shared.FourierFiniteAbelian
import Catalog.Shared.FourierSubgroupDuality
import Catalog.Shared.FourierExtremals
import Catalog.Novelty.FourierUncertaintyRigidity

open Finset Fintype ComplexConjugate

namespace FourierFA

variable {G : Type*} [AddCommGroup G] [Fintype G] [DecidableEq G] {f : G → ℂ}

/-! ## The Fourier transform of an extremal, explicitly -/

/-- **Explicit Fourier transform of a modulated coset indicator.**  Combining the behaviour of
the DFT under translation and modulation with the transform of a subgroup indicator. -/
theorem dft_coset_modulation (H : AddSubgroup G) [DecidablePred (· ∈ H)] (c : ℂ)
    (χ : AddChar G ℂ) (a : G) (ψ : AddChar G ℂ) :
    dft (fun x => c * (χ x * indic H (x - a))) ψ
      = c * conj ((ψ - χ) a) * (if ψ - χ ∈ annih H then ((subFinset H).card : ℂ) else 0) := by
  have hfun : (fun x => c * (χ x * indic H (x - a))) = c • modul χ (transl a (indic H)) := rfl
  rw [hfun, dft_smul, Pi.smul_apply, smul_eq_mul, dft_modul, dft_transl, dft_indic, mul_assoc]

/-- The spectrum of a (nonzero) modulated coset indicator is exactly the coset `χ + H^⊥`. -/
theorem supp_dft_coset_modulation (H : AddSubgroup G) [DecidablePred (· ∈ H)] {c : ℂ}
    (hc : c ≠ 0) (χ : AddChar G ℂ) (a : G) :
    supp (dft (fun x => c * (χ x * indic H (x - a))))
      = Finset.univ.filter (fun ψ : AddChar G ℂ => ψ - χ ∈ annih H) := by
  ext ψ
  have hne : conj ((ψ - χ) a) ≠ 0 := by
    intro h
    have hn := AddChar.norm_apply (ψ - χ) a
    rw [← RCLike.norm_conj, h] at hn
    simp at hn
  have hcardpos : ((subFinset H).card : ℂ) ≠ 0 := by
    have := card_subFinset_pos (H := H)
    exact_mod_cast this.ne'
  rw [mem_supp, dft_coset_modulation]
  by_cases hmem : ψ - χ ∈ annih H
  · rw [if_pos hmem]
    exact iff_of_true (mul_ne_zero (mul_ne_zero hc hne) hcardpos)
      (Finset.mem_filter.2 ⟨Finset.mem_univ _, hmem⟩)
  · rw [if_neg hmem, mul_zero]
    exact iff_of_false (by simp) (fun h => hmem (Finset.mem_filter.1 h).2)

/-! ## Sharp value distribution -/

/-- On an extremal function `|f|` is constant on its support, with the sharp value
`‖f‖₁ / |supp f|`. -/
theorem IsExtremal.norm_eq_l1norm (hext : IsExtremal f) {x : G} (hx : x ∈ supp f) :
    ‖f x‖ * ((supp f).card : ℝ) = l1norm f := by
  classical
  obtain ⟨ψ₀, hψ₀⟩ := supp_nonempty (dft_ne_zero hext.ne_zero)
  have hApos : (0 : ℝ) < ((supp (dft f)).card : ℝ) := by
    have : 0 < (supp (dft f)).card := Finset.card_pos.2 ⟨ψ₀, hψ₀⟩
    exact_mod_cast this
  have hmain := hext.card_mul_norm_eq hx
  have hcard : ((supp f).card : ℝ) * ((supp (dft f)).card : ℝ) = (Fintype.card G : ℝ) := by
    exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) hext
  have h : (‖f x‖ * ((supp f).card : ℝ)) * ((supp (dft f)).card : ℝ)
      = l1norm f * ((supp (dft f)).card : ℝ) := by
    calc (‖f x‖ * ((supp f).card : ℝ)) * ((supp (dft f)).card : ℝ)
        = ‖f x‖ * (((supp f).card : ℝ) * ((supp (dft f)).card : ℝ)) := by ring
      _ = ‖f x‖ * (Fintype.card G : ℝ) := by rw [hcard]
      _ = l1norm f * ((supp (dft f)).card : ℝ) := hmain
  exact mul_right_cancel₀ hApos.ne' h

/-! ## Cosetness of the support, stated without auxiliary data -/

/-- **The support of an extremal is a coset**, phrased intrinsically: it is closed under the
ternary operation `x - y + z`. -/
theorem IsExtremal.sub_add_mem_supp (hext : IsExtremal f) {x y z : G}
    (hx : x ∈ supp f) (hy : y ∈ supp f) (hz : z ∈ supp f) : x - y + z ∈ supp f := by
  classical
  obtain ⟨ψ₀, hψ₀⟩ := supp_nonempty (dft_ne_zero hext.ne_zero)
  refine (hext.mem_supp_iff_sub_mem hψ₀ hz _).2 ?_
  have hxy : x - y ∈ phaseSubgroup f ψ₀ := hext.sub_mem_phaseSubgroup hψ₀ hx hy
  simpa using hxy

/-! ## Self-duality of extremality -/

/-- The double transform detects the support of `f` through Pontryagin's embedding. -/
theorem supp_dft_dft (f : G → ℂ) :
    supp (dft (dft f)) = (supp f).image (fun x : G => AddChar.doubleDualEmb (-x)) := by
  classical
  have hcard : (Fintype.card G : ℂ) ≠ 0 := by
    exact_mod_cast (Fintype.card_ne_zero (α := G))
  ext Ψ
  simp only [mem_supp, Finset.mem_image]
  constructor
  · intro hΨ
    obtain ⟨x, rfl⟩ := AddChar.doubleDualEmb_bijective.surjective Ψ
    rw [dft_dft] at hΨ
    refine ⟨-x, fun h => hΨ (by rw [h, mul_zero]), by simp⟩
  · rintro ⟨y, hy, rfl⟩
    rw [dft_dft, neg_neg]
    exact mul_ne_zero hcard hy

/-- **Extremality is self-dual**: if `f` attains equality in the uncertainty principle on `G`,
then `f̂` attains equality on the dual group `Ĝ`. -/
theorem IsExtremal.dft_isExtremal (hext : IsExtremal f) : IsExtremal (dft f) := by
  classical
  have hinj : Function.Injective
      (fun x : G => (AddChar.doubleDualEmb (-x) : AddChar (AddChar G ℂ) ℂ)) := by
    intro u v huv
    have := AddChar.doubleDualEmb_injective huv
    simpa using this
  have hcard2 : (supp (dft (dft f))).card = (supp f).card := by
    rw [supp_dft_dft, Finset.card_image_of_injective _ hinj]
  rw [IsExtremal, hcard2, AddChar.card_eq]
  exact (Nat.mul_comm _ _).trans hext

/-! ## The arithmetic dichotomy in prime order -/

/-- **Prime order dichotomy.**  If `|G|` is prime, an extremal function is either a scaled Dirac
delta or a scaled character: there is no intermediate extremal.  (The support has cardinality
dividing the prime `|G|`.) -/
theorem extremal_classification_of_prime (hp : Nat.Prime (Fintype.card G))
    (hext : IsExtremal f) :
    (∃ (a : G) (c : ℂ), c ≠ 0 ∧ ∀ x, f x = if x = a then c else 0) ∨
      (∃ (c : ℂ) (χ : AddChar G ℂ), c ≠ 0 ∧ ∀ x, f x = c * χ x) := by
  classical
  rcases (Nat.Prime.eq_one_or_self_of_dvd hp _ hext.card_supp_dvd) with h1 | hall
  · -- a single point in the support: a scaled Dirac delta
    obtain ⟨a, ha⟩ := Finset.card_eq_one.1 h1
    have hfa : f a ≠ 0 := by
      have : a ∈ supp f := by rw [ha]; exact Finset.mem_singleton_self a
      exact mem_supp.1 this
    refine Or.inl ⟨a, f a, hfa, fun x => ?_⟩
    by_cases hx : x = a
    · simp [hx]
    · have hxs : x ∉ supp f := by rw [ha]; simpa using hx
      have : f x = 0 := by
        by_contra h
        exact hxs (mem_supp.2 h)
      simp [hx, this]
  · -- full support: a scaled character
    have hsupp : supp f = Finset.univ := Finset.eq_univ_of_card _ hall
    obtain ⟨H, c, χ, a, hc, h₁, h₂⟩ := hext.isCosetModulation
    refine Or.inr ⟨c, χ, hc, fun x => ?_⟩
    by_cases hx : x - a ∈ H
    · exact h₁ x hx
    · exfalso
      have hfx : f x ≠ 0 := by
        have : x ∈ supp f := by rw [hsupp]; exact Finset.mem_univ x
        exact mem_supp.1 this
      exact hfx (h₂ x hx)

/-! ## Canonicity of the phase subgroup -/

/-- **The phase subgroup is intrinsic**: for an extremal `f` it is exactly the group of periods
of `supp f`, and in particular does not depend on the choice of the spectral character `ψ₀`. -/
theorem IsExtremal.mem_phaseSubgroup_iff (hext : IsExtremal f) {ψ₀ : AddChar G ℂ}
    (hψ₀ : ψ₀ ∈ supp (dft f)) (z : G) :
    z ∈ phaseSubgroup f ψ₀ ↔ ∀ x ∈ supp f, x + z ∈ supp f := by
  classical
  obtain ⟨a, ha⟩ := supp_nonempty hext.ne_zero
  constructor
  · intro hz x hx
    refine (hext.mem_supp_iff_sub_mem hψ₀ ha _).2 ?_
    have hxa : x - a ∈ phaseSubgroup f ψ₀ := (hext.mem_supp_iff_sub_mem hψ₀ ha x).1 hx
    have : x + z - a = (x - a) + z := by abel
    rw [this]
    exact AddSubgroup.add_mem _ hxa hz
  · intro hz
    have haz : a + z ∈ supp f := hz a ha
    have : a + z - a = z := by abel
    have hmem := hext.sub_mem_phaseSubgroup hψ₀ haz ha
    rwa [this] at hmem

/-- Consequently the phase subgroup is independent of the chosen spectral character. -/
theorem IsExtremal.phaseSubgroup_eq (hext : IsExtremal f) {ψ₀ ψ₁ : AddChar G ℂ}
    (hψ₀ : ψ₀ ∈ supp (dft f)) (hψ₁ : ψ₁ ∈ supp (dft f)) :
    phaseSubgroup f ψ₀ = phaseSubgroup f ψ₁ := by
  ext z
  rw [hext.mem_phaseSubgroup_iff hψ₀, hext.mem_phaseSubgroup_iff hψ₁]

/-! ## Sharpness of the divisibility obstruction -/

/-- Every coset of every subgroup is the support of some extremal function: the arithmetic
obstruction `|supp f| ∣ |G|` of `IsExtremal.card_supp_dvd` is sharp, and the classification is
onto. -/
theorem exists_isExtremal_supp_eq (H : AddSubgroup G) [DecidablePred (· ∈ H)] (a : G) :
    ∃ g : G → ℂ, IsExtremal g ∧ supp g = (subFinset H).image (fun z => z + a) := by
  classical
  refine ⟨transl a (indic H), (isExtremal_indic H).transl a, ?_⟩
  ext x
  simp only [Finset.mem_image, mem_subFinset, mem_supp, transl, indic]
  constructor
  · intro hx
    refine ⟨x - a, ?_, by abel⟩
    by_contra hmem
    simp [hmem] at hx
  · rintro ⟨z, hz, rfl⟩
    simpa using hz

/-! ## Extremals with a fixed support form a single orbit -/

/-- **Orbit description of the extremals.**  Two extremal functions with the same support differ
by a nonzero scalar and a modulation.  Together with `exists_isExtremal_supp_eq` and
`IsExtremal.card_supp_dvd` this describes the whole extremal set: it is the disjoint union, over
the cosets of the subgroups of `G`, of one orbit of the scaling–modulation group. -/
theorem IsExtremal.exists_modulation_of_supp_eq {g : G → ℂ} (hf : IsExtremal f)
    (hg : IsExtremal g) (hsupp : supp f = supp g) :
    ∃ (c : ℂ) (χ : AddChar G ℂ), c ≠ 0 ∧ ∀ x, f x = c * χ x * g x := by
  classical
  obtain ⟨H₁, c₁, χ₁, a₁, hc₁, hf₁, hf₂⟩ := hf.isCosetModulation
  obtain ⟨H₂, c₂, χ₂, a₂, hc₂, hg₁, hg₂⟩ := hg.isCosetModulation
  have hfval : ∀ x ∈ supp f, f x = c₁ * χ₁ x := by
    intro x hx
    by_cases hmem : x - a₁ ∈ H₁
    · exact hf₁ x hmem
    · exact absurd (hf₂ x hmem) (mem_supp.1 hx)
  have hgval : ∀ x ∈ supp g, g x = c₂ * χ₂ x := by
    intro x hx
    by_cases hmem : x - a₂ ∈ H₂
    · exact hg₁ x hmem
    · exact absurd (hg₂ x hmem) (mem_supp.1 hx)
  have hχ₂ne : ∀ x : G, χ₂ x ≠ 0 := by
    intro x h
    have hn := AddChar.norm_apply χ₂ x
    rw [h] at hn
    simp at hn
  refine ⟨c₁ / c₂, χ₁ - χ₂, div_ne_zero hc₁ hc₂, fun x => ?_⟩
  by_cases hx : x ∈ supp f
  · have hxg : x ∈ supp g := by rwa [hsupp] at hx
    have hne := hχ₂ne x
    rw [hfval x hx, hgval x hxg, AddChar.sub_apply' χ₁ χ₂ x]
    field_simp
  · have hfx : f x = 0 := by
      by_contra h
      exact hx (mem_supp.2 h)
    have hgx : g x = 0 := by
      by_contra h
      exact hx (by rw [hsupp]; exact mem_supp.2 h)
    rw [hfx, hgx, mul_zero]

/-! ## A quantitative gap above the extremal locus -/

/-- **Uncertainty gap.**  If `|supp f|` divides `|G|` but `f` fails to be a modulated coset
indicator, the uncertainty product jumps by at least `|supp f|`:
`|supp f| · |supp f̂| ≥ |G| + |supp f|`.  There is no "almost extremal" regime among functions
whose support size divides `|G|`. -/
theorem uncertainty_gap_of_not_cosetModulation (hf : f ≠ 0)
    (hdvd : (supp f).card ∣ Fintype.card G) (hnot : ¬ IsCosetModulation f) :
    Fintype.card G + (supp f).card ≤ (supp f).card * (supp (dft f)).card := by
  classical
  obtain ⟨q, hq⟩ := hdvd
  have hSpos : 0 < (supp f).card := Finset.card_pos.2 (supp_nonempty hf)
  have hge : Fintype.card G ≤ (supp f).card * (supp (dft f)).card := uncertainty f hf
  have hne : (supp f).card * (supp (dft f)).card ≠ Fintype.card G := by
    intro h
    exact hnot (IsExtremal.isCosetModulation h)
  have hgt : Fintype.card G < (supp f).card * (supp (dft f)).card := lt_of_le_of_ne hge (Ne.symm hne)
  have hqlt : q < (supp (dft f)).card := by
    by_contra hcon
    push_neg at hcon
    have : (supp f).card * (supp (dft f)).card ≤ (supp f).card * q :=
      Nat.mul_le_mul_left _ hcon
    omega
  have hstep : q + 1 ≤ (supp (dft f)).card := hqlt
  calc Fintype.card G + (supp f).card
      = (supp f).card * q + (supp f).card * 1 := by rw [hq]; ring
    _ = (supp f).card * (q + 1) := by ring
    _ ≤ (supp f).card * (supp (dft f)).card := Nat.mul_le_mul_left _ hstep

/-- The same gap, phrased through extremality. -/
theorem uncertainty_gap_of_not_isExtremal (hf : f ≠ 0)
    (hdvd : (supp f).card ∣ Fintype.card G) (hnot : ¬ IsExtremal f) :
    Fintype.card G + (supp f).card ≤ (supp f).card * (supp (dft f)).card :=
  uncertainty_gap_of_not_cosetModulation hf hdvd
    (fun h => hnot (IsCosetModulation.isExtremal h))

/-! ## Uniqueness of the data in the classification -/

omit [DecidableEq G] in
/-- The support of a modulated coset indicator is the coset itself. -/
theorem supp_eq_of_isCosetModulation {H : AddSubgroup G} {c : ℂ} {χ : AddChar G ℂ} {a : G}
    (hc : c ≠ 0) (h₁ : ∀ x, x - a ∈ H → f x = c * χ x) (h₂ : ∀ x, x - a ∉ H → f x = 0)
    (x : G) : x ∈ supp f ↔ x - a ∈ H := by
  have hχne : χ x ≠ 0 := by
    intro h
    have hn := AddChar.norm_apply χ x
    rw [h] at hn
    simp at hn
  constructor
  · intro hx
    by_contra hmem
    exact (mem_supp.1 hx) (h₂ x hmem)
  · intro hmem
    exact mem_supp.2 (by rw [h₁ x hmem]; exact mul_ne_zero hc hχne)

omit [DecidableEq G] in
/-- **The subgroup in the classification is unique.**  If `f` is written in two ways as a
modulated coset indicator, the two subgroups coincide (they are both the group of periods of
`supp f`). -/
theorem subgroup_unique_of_isCosetModulation {H₁ H₂ : AddSubgroup G} {c₁ c₂ : ℂ}
    {χ₁ χ₂ : AddChar G ℂ} {a₁ a₂ : G} (hc₁ : c₁ ≠ 0) (hc₂ : c₂ ≠ 0)
    (h₁₁ : ∀ x, x - a₁ ∈ H₁ → f x = c₁ * χ₁ x) (h₁₂ : ∀ x, x - a₁ ∉ H₁ → f x = 0)
    (h₂₁ : ∀ x, x - a₂ ∈ H₂ → f x = c₂ * χ₂ x) (h₂₂ : ∀ x, x - a₂ ∉ H₂ → f x = 0) :
    H₁ = H₂ := by
  have key : ∀ x, x - a₁ ∈ H₁ ↔ x - a₂ ∈ H₂ := fun x =>
    (supp_eq_of_isCosetModulation hc₁ h₁₁ h₁₂ x).symm.trans
      (supp_eq_of_isCosetModulation hc₂ h₂₁ h₂₂ x)
  have ha₁ : a₁ - a₂ ∈ H₂ := by
    refine (key a₁).1 ?_
    simp
  ext z
  have hz := key (z + a₁)
  have e₁ : z + a₁ - a₁ = z := by abel
  have e₂ : z + a₁ - a₂ = z + (a₁ - a₂) := by abel
  rw [e₁, e₂] at hz
  constructor
  · intro hzH
    have := hz.1 hzH
    simpa using H₂.sub_mem this ha₁
  · intro hzH
    exact hz.2 (H₂.add_mem hzH ha₁)

/-! ## A purely combinatorial corollary: extremal sets are cosets -/

/-- **Sets with minimal Fourier support are exactly cosets.**  For a nonempty `S ⊆ G`, the
indicator `1_S` attains equality in the uncertainty principle iff `S` is a coset of a subgroup.
This is the classification specialised to `0/1`-valued functions, and is a statement purely
about subsets of `G` and the size of the Fourier support of `1_S`. -/
theorem indicator_isExtremal_iff_coset (S : Finset G) (hS : S.Nonempty) :
    IsExtremal (fun x => if x ∈ S then (1 : ℂ) else 0) ↔
      ∃ (H : AddSubgroup G) (a : G), ∀ x, x ∈ S ↔ x - a ∈ H := by
  classical
  set f : G → ℂ := fun x => if x ∈ S then (1 : ℂ) else 0 with hf
  have hsupp : supp f = S := by
    ext x
    by_cases hx : x ∈ S <;> simp [mem_supp, hf, hx]
  constructor
  · intro hext
    obtain ⟨a, ha⟩ := hS
    obtain ⟨ψ₀, hψ₀⟩ := supp_nonempty (dft_ne_zero hext.ne_zero)
    refine ⟨phaseSubgroup f ψ₀, a, fun x => ?_⟩
    have hmem : a ∈ supp f := by rw [hsupp]; exact ha
    have := hext.mem_supp_iff_sub_mem hψ₀ hmem x
    rwa [hsupp] at this
  · rintro ⟨H, a, hH⟩
    letI : DecidablePred (· ∈ H) := Classical.decPred _
    refine IsCosetModulation.isExtremal ⟨H, 1, 1, a, one_ne_zero, ?_, ?_⟩
    · intro x hx
      have : x ∈ S := (hH x).2 hx
      simp [hf, this]
    · intro x hx
      have : x ∉ S := fun h => hx ((hH x).1 h)
      simp [hf, this]

end FourierFA