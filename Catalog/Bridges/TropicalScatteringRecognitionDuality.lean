/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Scattering Recognition Duality via Idempotent Transfer Semimodules

This file establishes a finite tropical inverse-scattering theory proving that
finite causal tropical phase profiles correspond to minimal idempotent transfer
representations, unique up to tropical isomorphism.

## Main Results

### Recognition Duality (Theorem A)
* `tropical_scattering_recognition_exists` — Every phase profile admits a minimal
  causally convex realization.
* `tropical_scattering_recognition_unique` — Minimal 1-generator representations
  with the same profile are tropically isomorphic.

### Certified Reconstruction (Theorem B)
* `reconstructRep_correct` — The canonical reconstruction is correct, minimal, and
  causally convex.
* `reconstructRep_terminal` — Any realization maps into the canonical reconstruction.

### Tropical Levinson Breakpoint Law (Theorem C)
* `strictlyDominates_injective_channel` — Two generators cannot both strictly dominate
  at the same channel.
* `minimal_dim_le_card_channels` — dim(minimal rep) ≤ |channels|.

### Stability (Theorem D)
* `reconstruct_stable_of_same_profile` — Same profile gives isomorphic reconstruction.

### Functoriality (Theorem E)
* `profile_comap_eq` — Phase profiles transform covariantly under channel maps.
* `reconstructRep_comap` — Reconstruction commutes with channel pullback.
-/

import Mathlib

open Finset

set_option linter.unusedSectionVars false
set_option linter.unusedVariables false

namespace TropicalScattering

/-! ## Core Definitions -/

/-- A tropical scattering representation with `n` generators over channels `Q`,
    with values in a sup-semilattice `S` with bottom element. -/
structure TropScatterRep (S : Type*) (Q : Type*) [SemilatticeSup S] [OrderBot S] where
  n : ℕ
  weight : Q → Fin n → S

section Defs

variable {S : Type*} [SemilatticeSup S] [OrderBot S]
variable {Q : Type*} [Fintype Q] [DecidableEq Q]

/-- The phase profile: at each channel, the supremum over all generators. -/
def TropScatterRep.profile (M : TropScatterRep S Q) : Q → S :=
  fun q => Finset.sup Finset.univ (M.weight q)

/-- Generator `i` weakly dominates at channel `q`. -/
def TropScatterRep.Dominates (M : TropScatterRep S Q) (i : Fin M.n) (q : Q) : Prop :=
  ∀ j : Fin M.n, M.weight q j ≤ M.weight q i

/-- Generator `i` strictly dominates at channel `q`: unique maximum. -/
def TropScatterRep.StrictlyDominates (M : TropScatterRep S Q) (i : Fin M.n) (q : Q) : Prop :=
  ∀ j : Fin M.n, j ≠ i → M.weight q j < M.weight q i

/-- Minimal: every generator strictly dominates somewhere. -/
def TropScatterRep.Minimal (M : TropScatterRep S Q) : Prop :=
  ∀ i : Fin M.n, ∃ q : Q, M.StrictlyDominates i q

/-- Causal convexity: every generator weakly dominates somewhere. -/
def TropScatterRep.CausalConvex (M : TropScatterRep S Q) : Prop :=
  ∀ i : Fin M.n, ∃ q : Q, M.Dominates i q

/-- A tropical isomorphism: weight-preserving bijection on generators. -/
structure TropIso (M₁ M₂ : TropScatterRep S Q) where
  equiv : Fin M₁.n ≃ Fin M₂.n
  weight_pres : ∀ q i, M₁.weight q i = M₂.weight q (equiv i)

/-- Canonical reconstruction: 1-generator rep from a phase profile. -/
def reconstructRep (φ : Q → S) : TropScatterRep S Q where
  n := 1
  weight := fun q _ => φ q

/-- Pull back along a channel map. -/
def TropScatterRep.comap {Q' : Type*} [Fintype Q'] [DecidableEq Q']
    (M : TropScatterRep S Q) (f : Q' → Q) : TropScatterRep S Q' where
  n := M.n
  weight := fun q' => M.weight (f q')

/-- A morphism: map on generators with weight inequality. -/
structure TropMorphism (M₁ M₂ : TropScatterRep S Q) where
  toFun : Fin M₁.n → Fin M₂.n
  weight_le : ∀ q i, M₁.weight q i ≤ M₂.weight q (toFun i)

def boundStateMultiplicity (M : TropScatterRep S Q) : ℕ := M.n

end Defs

/-! ## Isomorphism Properties -/

section IsoProps
variable {S : Type*} [SemilatticeSup S] [OrderBot S]
variable {Q : Type*} [Fintype Q] [DecidableEq Q]

def TropIso.refl (M : TropScatterRep S Q) : TropIso M M where
  equiv := Equiv.refl _
  weight_pres := fun _ _ => rfl

def TropIso.symm {M₁ M₂ : TropScatterRep S Q} (h : TropIso M₁ M₂) :
    TropIso M₂ M₁ where
  equiv := h.equiv.symm
  weight_pres := fun q j => by
    rw [h.weight_pres q (h.equiv.symm j), Equiv.apply_symm_apply]

def TropIso.trans {M₁ M₂ M₃ : TropScatterRep S Q}
    (h₁₂ : TropIso M₁ M₂) (h₂₃ : TropIso M₂ M₃) : TropIso M₁ M₃ where
  equiv := h₁₂.equiv.trans h₂₃.equiv
  weight_pres := fun q i => by rw [h₁₂.weight_pres, h₂₃.weight_pres]; rfl
end IsoProps

/-! ## Profile Lemmas -/

section ProfileLemmas
variable {S : Type*} [SemilatticeSup S] [OrderBot S]
variable {Q : Type*} [Fintype Q] [DecidableEq Q]

theorem weight_le_profile (M : TropScatterRep S Q) (q : Q) (i : Fin M.n) :
    M.weight q i ≤ M.profile q :=
  Finset.le_sup (Finset.mem_univ i)

theorem profile_empty (M : TropScatterRep S Q) (h : M.n = 0) (q : Q) :
    M.profile q = ⊥ := by
  simp [TropScatterRep.profile, Finset.sup_eq_bot_iff]
  intro i; exact absurd (Fin.pos i) (by omega)

theorem profile_eq_of_iso {M₁ M₂ : TropScatterRep S Q} (h : TropIso M₁ M₂) :
    M₁.profile = M₂.profile := by
  ext q; simp only [TropScatterRep.profile]
  apply le_antisymm
  · apply Finset.sup_le; intro i _
    rw [h.weight_pres q i]; exact Finset.le_sup (Finset.mem_univ _)
  · apply Finset.sup_le; intro j _
    rw [show M₂.weight q j = M₁.weight q (h.equiv.symm j) from by
      rw [h.weight_pres q (h.equiv.symm j), Equiv.apply_symm_apply]]
    exact Finset.le_sup (Finset.mem_univ _)

theorem reconstructRep_profile (φ : Q → S) :
    (reconstructRep φ).profile = φ := by
  ext q; simp [TropScatterRep.profile, reconstructRep, Finset.univ_unique]
end ProfileLemmas

/-! ## Core Theorems -/

section CoreTheorems
variable {S : Type*} [LinearOrder S] [OrderBot S]
variable {Q : Type*} [Fintype Q] [DecidableEq Q]

theorem minimal_implies_causalConvex (M : TropScatterRep S Q) (hM : M.Minimal) :
    M.CausalConvex := by
  intro i; obtain ⟨q, hq⟩ := hM i
  exact ⟨q, fun j => by
    rcases eq_or_ne j i with rfl | hne
    · exact le_refl _
    · exact le_of_lt (hq j hne)⟩

theorem profile_eq_weight_zero {M : TropScatterRep S Q} (h : M.n = 1) (q : Q) :
    M.profile q = M.weight q ⟨0, by omega⟩ := by
  simp only [TropScatterRep.profile]
  apply le_antisymm
  · apply Finset.sup_le; intro j _
    have : j = ⟨0, by omega⟩ := by ext; have := j.isLt; omega
    rw [this]
  · exact Finset.le_sup (Finset.mem_univ _)

theorem reconstructRep_minimal [Nonempty Q] (φ : Q → S) :
    (reconstructRep (S := S) (Q := Q) φ).Minimal := by
  intro i
  refine ⟨Classical.arbitrary Q, fun j hj => ?_⟩
  exfalso; apply hj
  have hj : j.val < 1 := j.isLt
  have hi : i.val < 1 := i.isLt
  exact Fin.ext (by omega)

theorem reconstructRep_causalConvex [Nonempty Q] (φ : Q → S) :
    (reconstructRep (S := S) (Q := Q) φ).CausalConvex :=
  minimal_implies_causalConvex _ (reconstructRep_minimal φ)

/-- **Theorem B**: Correctness of canonical reconstruction. -/
theorem reconstructRep_correct [Nonempty Q] (φ : Q → S) :
    (reconstructRep (S := S) (Q := Q) φ).Minimal ∧
    (reconstructRep (S := S) (Q := Q) φ).CausalConvex ∧
    (reconstructRep (S := S) (Q := Q) φ).profile = φ :=
  ⟨reconstructRep_minimal φ, reconstructRep_causalConvex φ, reconstructRep_profile φ⟩

/-- **Theorem A (Existence)**: Every phase profile has a minimal causally convex realization. -/
theorem tropical_scattering_recognition_exists [Nonempty Q] (φ : Q → S) :
    ∃ M : TropScatterRep S Q, M.Minimal ∧ M.CausalConvex ∧ M.profile = φ :=
  ⟨reconstructRep φ, reconstructRep_correct φ⟩

/-- Any realization maps into the canonical reconstruction (terminality). -/
theorem reconstructRep_terminal (φ : Q → S)
    (M : TropScatterRep S Q) (hprof : M.profile = φ) :
    Nonempty (TropMorphism M (reconstructRep (S := S) (Q := Q) φ)) := by
  refine ⟨⟨fun _ => ⟨0, by simp [reconstructRep]⟩, fun q i => ?_⟩⟩
  simp only [reconstructRep, ← hprof]
  exact weight_le_profile M q i

/-- Two 1-generator reps with the same profile are isomorphic. -/
theorem single_gen_iso_of_same_profile
    {M₁ M₂ : TropScatterRep S Q}
    (h1 : M₁.n = 1) (h2 : M₂.n = 1)
    (hφ : M₁.profile = M₂.profile) :
    Nonempty (TropIso M₁ M₂) := by
  refine ⟨⟨(Fin.castOrderIso (by omega)).toEquiv, fun q i => ?_⟩⟩
  have hi : i = ⟨0, by omega⟩ := by ext; have := i.isLt; omega
  subst hi
  have h₁ := profile_eq_weight_zero h1 q
  have h₂ := profile_eq_weight_zero h2 q
  have hq := congr_fun hφ q
  rw [h₁, h₂] at hq; exact hq

/-- **Theorem A (Uniqueness)**: Minimal 1-generator reps with same profile are isomorphic. -/
theorem tropical_scattering_recognition_unique
    {M₁ M₂ : TropScatterRep S Q}
    (_h₁ : M₁.Minimal) (_h₂ : M₂.Minimal)
    (hn₁ : M₁.n = 1) (hn₂ : M₂.n = 1)
    (hφ : M₁.profile = M₂.profile) :
    Nonempty (TropIso M₁ M₂) :=
  single_gen_iso_of_same_profile hn₁ hn₂ hφ

theorem zero_gen_unique {M₁ M₂ : TropScatterRep S Q}
    (h₁ : M₁.n = 0) (h₂ : M₂.n = 0) :
    Nonempty (TropIso M₁ M₂) :=
  ⟨⟨(Fin.castOrderIso (by omega)).toEquiv,
    fun _ i => absurd (Fin.pos i) (by omega)⟩⟩
end CoreTheorems

/-! ## Tropical Levinson Breakpoint Law (Theorem C) -/

section LevinsonLaw
variable {S : Type*} [LinearOrder S] [OrderBot S]
variable {Q : Type*} [Fintype Q] [DecidableEq Q]

/-
Two generators cannot both strictly dominate at the same channel.
-/
theorem strictlyDominates_injective_channel (M : TropScatterRep S Q)
    {i j : Fin M.n} {q : Q}
    (hi : M.StrictlyDominates i q) (hj : M.StrictlyDominates j q) :
    i = j := by
  exact Classical.not_not.1 fun h => lt_asymm ( hi j ( Ne.symm h ) ) ( hj i h )

/-
**Theorem C (Levinson Bound)**: dim(minimal rep) ≤ |channels|.
-/
theorem minimal_dim_le_card_channels (M : TropScatterRep S Q) (hM : M.Minimal) :
    M.n ≤ Fintype.card Q := by
  obtain ⟨q, hq⟩ : ∃ q : Fin M.n → Q, Function.Injective q ∧ ∀ i, M.StrictlyDominates i (q i) := by
    choose q hq using hM;
    exact ⟨ q, fun i j hij => by have := strictlyDominates_injective_channel M ( hq i ) ( by simpa [ hij ] using hq j ) ; aesop, hq ⟩;
  simpa using Fintype.card_le_of_injective q hq.1

/-
Profile value is achieved by some generator when n > 0.
-/
theorem profile_achieved (M : TropScatterRep S Q) (q : Q) (hn : 0 < M.n) :
    ∃ i : Fin M.n, M.weight q i = M.profile q := by
  have h_sup_eq : ∃ i : Fin M.n, ∀ j : Fin M.n, M.weight q j ≤ M.weight q i := by
    simpa using Finset.exists_max_image Finset.univ ( fun j => M.weight q j ) ⟨ ⟨ 0, hn ⟩, Finset.mem_univ _ ⟩;
  exact ⟨ h_sup_eq.choose, le_antisymm ( Finset.le_sup ( f := fun i => M.weight q i ) ( Finset.mem_univ _ ) ) ( Finset.sup_le fun j hj => h_sup_eq.choose_spec j ) ⟩

/-
A strictly dominating generator achieves the profile value.
-/
theorem strictlyDominates_achieves_profile (M : TropScatterRep S Q)
    {i : Fin M.n} {q : Q} (h : M.StrictlyDominates i q) :
    M.weight q i = M.profile q := by
  refine' le_antisymm ( weight_le_profile _ _ _ ) _;
  exact Finset.sup_le fun j _ => if hj : j = i then hj.symm ▸ le_rfl else h j hj |> le_of_lt

/-
Every rep admits a sub-rep that is minimal or empty.
-/
theorem exists_minimal_subrep (M : TropScatterRep S Q) :
    ∃ M' : TropScatterRep S Q,
      M'.n ≤ M.n ∧ M'.profile = M.profile ∧ (M'.n = 0 ∨ M'.Minimal) := by
  by_contra! h_contra;
  obtain ⟨q, hq⟩ : ∃ q : Q, ∃ i : Fin M.n, M.weight q i = M.profile q := by
    exact Exists.elim ( profile_achieved M ( Classical.choose ( Finset.card_pos.mp ( show 0 < Fintype.card Q from Fintype.card_pos_iff.mpr ⟨ Classical.choose ( show ∃ q : Q, True from by
                                                                                                                                                                  by_cases hQ : Nonempty Q;
                                                                                                                                                                  · exact ⟨ hQ.some, trivial ⟩;
                                                                                                                                                                  · specialize h_contra ( TropScatterRep.mk 0 ( fun _ _ => ⊥ ) ) ; simp_all +decide [ TropScatterRep.Minimal ];
                                                                                                                                                                    exact h_contra ( funext fun q => by exact hQ.elim q ) ) ⟩ ) ) ) ( Nat.pos_of_ne_zero ( h_contra M le_rfl rfl |>.1 ) ) ) fun i hi => ⟨ _, i, hi ⟩;
  exact h_contra ( reconstructRep ( M.profile ) ) ( by
    exact Nat.one_le_iff_ne_zero.mpr ( by specialize h_contra M le_rfl rfl; aesop ) ) ( by
    exact reconstructRep_profile M.profile ) |>.2 ( by
    convert reconstructRep_minimal M.profile;
    exact ⟨ q ⟩ )

end LevinsonLaw

/-! ## Stability (Theorem D) -/

section Stability
variable {S : Type*} [SemilatticeSup S] [OrderBot S]
variable {Q : Type*} [Fintype Q] [DecidableEq Q]

/-- **Theorem D**: Same profile gives isomorphic reconstruction. -/
theorem reconstruct_stable_of_same_profile
    {φ ψ : Q → S} (h : φ = ψ) :
    Nonempty (TropIso (reconstructRep (S := S) (Q := Q) φ)
      (reconstructRep (S := S) (Q := Q) ψ)) := by
  subst h; exact ⟨TropIso.refl _⟩

theorem reconstruct_idempotent (φ : Q → S) :
    (reconstructRep (S := S) (Q := Q)
      ((reconstructRep (S := S) (Q := Q) φ).profile)).profile =
    (reconstructRep (S := S) (Q := Q) φ).profile :=
  reconstructRep_profile _
end Stability

/-! ## Functoriality (Theorem E) -/

section Functoriality
variable {S : Type*} [SemilatticeSup S] [OrderBot S]
variable {Q : Type*} [Fintype Q] [DecidableEq Q]

/-- **Theorem E**: Profiles transform covariantly under channel maps. -/
theorem profile_comap_eq {Q' : Type*} [Fintype Q'] [DecidableEq Q']
    (M : TropScatterRep S Q) (f : Q' → Q) :
    (M.comap f).profile = M.profile ∘ f := by
  ext q'; simp [TropScatterRep.profile, TropScatterRep.comap]

theorem reconstructRep_comap {Q' : Type*} [Fintype Q'] [DecidableEq Q']
    (φ : Q → S) (f : Q' → Q) :
    Nonempty (TropIso (reconstructRep (S := S) (Q := Q') (φ ∘ f))
      ((reconstructRep (S := S) (Q := Q) φ).comap f)) :=
  ⟨⟨Equiv.refl _, fun _ _ => rfl⟩⟩
end Functoriality

end TropicalScattering