/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Support Theory for Tropical Functionals

This file develops the support theory for upper-continuous tropical (max-plus) functionals,
establishing a closed-set invariant that interacts functorially with pullback and
reconstructs normalized functionals from local peak data.

## Main results

- `isClosed_supportOf`: the support of a tropical functional is closed
- `mem_compl_supportOf_iff`: complement characterization of support
- `supportOf_eq_peakAt_nonbot`: support = {x | Λ(peakAt x) ≠ ⊥} (discrete)
- `kernel_eq_botOn_compl_support_discrete`: kernel/support duality (discrete)
- `eq_of_agree_on_singleton_peaks`: uniqueness from peak values (discrete)
- `support_pushforward_le`: support functoriality under pushforward

## Mathematical significance

The support `supportOf Λ` is the tropical/idempotent analogue of the essential support
of a measure. Its closedness upgrades it from an ad hoc nontriviality locus into a
genuine geometric object. The reconstruction theorem shows that a normalized functional
on a finite discrete space is uniquely determined by its peak values.
-/

import Bridges.TropicalFunctional.Basic

noncomputable section

open scoped Classical

variable {X : Type*} [TopologicalSpace X]

/-! ## Support of a tropical functional -/

/-- The support of an upper-continuous tropical functional `Λ`: the set of points `x`
such that every neighborhood of `x` contains a function that `Λ` does not annihilate. -/
def supportOf (Λ : UCTropicalFunctional X) : Set X :=
  {x | ∀ U : Set X, IsOpen U → x ∈ U →
      ∃ f : TropCont X, f.support ⊆ U ∧ Λ f ≠ ⊥}

/-- Membership in the support. -/
theorem mem_supportOf_iff (Λ : UCTropicalFunctional X) (x : X) :
    x ∈ supportOf Λ ↔
      ∀ U : Set X, IsOpen U → x ∈ U →
        ∃ f : TropCont X, f.support ⊆ U ∧ Λ f ≠ ⊥ :=
  Iff.rfl

/-
Complement characterization of support: `x ∉ supportOf Λ` iff there exists an
open neighborhood of `x` on which `Λ` annihilates every supported function.
-/
theorem mem_compl_supportOf_iff (Λ : UCTropicalFunctional X) (x : X) :
    x ∈ (supportOf Λ)ᶜ ↔
      ∃ U : Set X, IsOpen U ∧ x ∈ U ∧
        ∀ f : TropCont X, f.support ⊆ U → Λ f = ⊥ := by
  simp +decide [ supportOf, Set.mem_setOf_eq ]

/-
**Closedness of the support.**
The support of a tropical functional is a closed set.

**Proof**: The complement is open. For any `x ∉ supportOf Λ`, there exists an open
neighborhood `U` on which every supported function is annihilated.
Every `y ∈ U` also has `U` as a witness, so `y ∉ supportOf Λ`.
-/
theorem isClosed_supportOf (Λ : UCTropicalFunctional X) :
    IsClosed (supportOf Λ) := by
  refine' isClosed_iff_nhds.2 fun x hx => _;
  intro U hU hxU;
  obtain ⟨ y, hy ⟩ := hx U ( hU.mem_nhds hxU );
  exact hy.2 U hU hy.1

/-! ## Peak functions for discrete spaces -/

variable {Y : Type*} [TopologicalSpace Y]

/-- The tropical peak (basis) function at a point `x₀` in a discrete space:
`peakAt x₀ y = 0` if `y = x₀`, `⊥` otherwise. -/
def peakAt [DiscreteTopology X] [DecidableEq X] (x₀ : X) : TropCont X :=
  ⟨fun y => if y = x₀ then 0 else ⊥, continuous_of_discreteTopology⟩

@[simp]
theorem peakAt_apply_self [DiscreteTopology X] [DecidableEq X] (x : X) :
    peakAt x x = (0 : WithBot ℝ) := by
  simp [peakAt]

@[simp]
theorem peakAt_apply_ne [DiscreteTopology X] [DecidableEq X] {x y : X} (h : y ≠ x) :
    peakAt x y = (⊥ : WithBot ℝ) := by
  simp [peakAt, h]

/-
The support of `peakAt x` is exactly `{x}`.
-/
theorem support_peakAt [DiscreteTopology X] [DecidableEq X] (x : X) :
    (peakAt x).support = {x} := by
  ext y;
  by_cases hy : y = x <;> simp +decide [ hy, peakAt_apply_self, peakAt_apply_ne ]

/-- A function `f` is a "peak at `x` inside `U`" if its support is in `U`
and `f(x) ≠ ⊥`. -/
def IsPeakAt (x : X) (U : Set X) (f : TropCont X) : Prop :=
  f.support ⊆ U ∧ f x ≠ ⊥

/-! ## Bot-on predicate -/

/-- The "bot-on" predicate: `Λ` annihilates all functions supported in `S`. -/
def botOn (Λ : UCTropicalFunctional X) (S : Set X) : Prop :=
  ∀ f : TropCont X, f.support ⊆ S → Λ f = ⊥

/-! ## Shifted basis and finite representation (discrete spaces) -/

/-- Shifted tropical basis at `x₀` with value `c`:
`shiftedBasis c x₀ y = c` if `y = x₀`, `⊥` otherwise. -/
def shiftedBasis [DiscreteTopology X] [DecidableEq X]
    (c : WithBot ℝ) (x₀ : X) : TropCont X :=
  ⟨fun y => if y = x₀ then c else ⊥, continuous_of_discreteTopology⟩

@[simp]
theorem shiftedBasis_apply_self [DiscreteTopology X] [DecidableEq X]
    (c : WithBot ℝ) (x : X) :
    shiftedBasis c x x = c := by simp [shiftedBasis]

@[simp]
theorem shiftedBasis_apply_ne [DiscreteTopology X] [DecidableEq X]
    (c : WithBot ℝ) {x y : X} (h : y ≠ x) :
    shiftedBasis c x y = ⊥ := by simp [shiftedBasis, h]

/-- The shifted basis equals `c + peakAt x₀` pointwise. -/
theorem shiftedBasis_eq_add [DiscreteTopology X] [DecidableEq X]
    (c : WithBot ℝ) (x₀ : X) (y : X) :
    shiftedBasis c x₀ y = c + peakAt x₀ y := by
  simp only [shiftedBasis, peakAt, ContinuousMap.coe_mk]
  split_ifs with h
  · simp
  · simp

/-- The functional value on a shifted basis function. -/
theorem map_shiftedBasis [DiscreteTopology X] [DecidableEq X]
    (Λ : TropicalFunctional X) (c : WithBot ℝ) (x₀ : X) :
    Λ.toFun (shiftedBasis c x₀) = c + Λ.toFun (peakAt x₀) :=
  Λ.map_addConst' c (peakAt x₀) (shiftedBasis c x₀) (shiftedBasis_eq_add c x₀)

/-- The delta weight: the tropical mass at a point. -/
def deltaWeight [DiscreteTopology X] [DecidableEq X]
    (Λ : TropicalFunctional X) (x : X) : WithBot ℝ :=
  Λ.toFun (peakAt x)

/-- An arbitrary function on a discrete space, lifted to `TropCont`. -/
def mkTropCont [DiscreteTopology X] (f : X → WithBot ℝ) : TropCont X :=
  ⟨f, continuous_of_discreteTopology⟩

/-- Pointwise sup of a finite family of tropical continuous functions. -/
def finsetTropSup [DiscreteTopology X] (s : Finset ι) (f : ι → TropCont X) : TropCont X :=
  ⟨fun x => s.sup (fun i => f i x), continuous_of_discreteTopology⟩

@[simp]
theorem finsetTropSup_apply [DiscreteTopology X] (s : Finset ι) (f : ι → TropCont X) (x : X) :
    finsetTropSup s f x = s.sup (fun i => f i x) := rfl

/-
Tropical basis decomposition: any function on a finite discrete space is the
supremum of its shifted basis components.
-/
theorem tropical_basis_decomp [DiscreteTopology X] [DecidableEq X] [Fintype X]
    (f : TropCont X) (y : X) :
    f y = Finset.univ.sup (fun x => shiftedBasis (f x) x y) := by
  refine' le_antisymm _ _ <;> simp +decide [ shiftedBasis ];
  · exact Finset.le_sup ( f := fun x => if y = x then f x else ⊥ ) ( Finset.mem_univ y ) |> le_trans ( by simp +decide );
  · aesop

/-
A tropical functional preserves finite nonempty suprema.
-/
theorem TropicalFunctional.map_finsetSup [DiscreteTopology X]
    (Λ : TropicalFunctional X) (s : Finset ι)
    (hs : s.Nonempty) (f : ι → TropCont X) :
    Λ.toFun (finsetTropSup s f) = s.sup (fun i => Λ.toFun (f i)) := by
  induction hs using Finset.Nonempty.cons_induction;
  · unfold finsetTropSup; aesop;
  · simp_all +decide [ Finset.sup_cons, Finset.inf_cons ];
    rename_i k s hk hs ih;
    have h_sup : finsetTropSup (insert k s) f = TropCont.tsup (f k) (finsetTropSup s f) := by
      ext x; simp [finsetTropSup, TropCont.tsup];
    rw [ h_sup, Λ.map_sup', ih ]

/-
**Representation formula**: on a finite discrete space, the functional value equals
the sup of shifted basis values.
-/
theorem finite_representation_formula [DiscreteTopology X] [DecidableEq X]
    [Fintype X] [Nonempty X]
    (Λ : TropicalFunctional X) (f : TropCont X) :
    Λ.toFun f = Finset.univ.sup (fun x => deltaWeight Λ x + f x) := by
  have h_tropical_basis_decomp : f = finsetTropSup Finset.univ (fun x => shiftedBasis (f x) x) := by
    ext x;
    exact tropical_basis_decomp f x;
  conv_lhs => rw [ h_tropical_basis_decomp ];
  rw [ TropicalFunctional.map_finsetSup ];
  · exact Finset.sup_congr rfl fun x _ => by rw [ map_shiftedBasis, add_comm ] ; rfl;
  · exact ⟨ Classical.arbitrary X, Finset.mem_univ _ ⟩

/-! ## Support characterization via peaks in discrete spaces -/

/-
In a discrete space, `x ∈ supportOf Λ` iff `Λ(peakAt x) ≠ ⊥`.
-/
theorem mem_supportOf_iff_peakAt
    [DiscreteTopology X] [Fintype X] [DecidableEq X]
    (Λ : UCTropicalFunctional X) (x : X) :
    x ∈ supportOf Λ ↔ Λ.toFun (peakAt x) ≠ ⊥ := by
  constructor;
  · intro hx;
    have := hx { x } ; simp_all +decide [ support_peakAt ] ;
    obtain ⟨ f, hf₁, hf₂ ⟩ := this;
    have h_eq : f = shiftedBasis (f x) x := by
      ext y; by_cases hy : y = x <;> simp_all +decide [ shiftedBasis ] ;
      exact Classical.not_not.1 fun h => hy <| hf₁ y h;
    rw [ h_eq ] at hf₂;
    rw [ map_shiftedBasis ] at hf₂;
    exact fun h => hf₂ <| by simp +decide [ h ] ;
  · intro h;
    intro U hU hxU; use peakAt x; simp_all +decide [ support_peakAt ] ;

/-- The support equals the set of points where the peak function is not killed. -/
theorem supportOf_eq_peakAt_nonbot
    [DiscreteTopology X] [Fintype X] [DecidableEq X]
    (Λ : UCTropicalFunctional X) :
    supportOf Λ = {x | Λ.toFun (peakAt x) ≠ ⊥} := by
  ext x; exact mem_supportOf_iff_peakAt Λ x

/-! ## Kernel/support duality in discrete spaces -/

/-
Functions supported outside the support are killed (discrete).
-/
theorem kernel_eq_botOn_compl_support_discrete
    [DiscreteTopology X] [Fintype X] [DecidableEq X] [Nonempty X]
    (Λ : UCTropicalFunctional X) :
    ∀ f : TropCont X, f.support ⊆ (supportOf Λ)ᶜ → Λ f = ⊥ := by
  intro f hf;
  rw [ finite_representation_formula ];
  simp +zetaDelta at *;
  intro x; by_cases hx : x ∈ supportOf Λ <;> simp_all +decide [ supportOf_eq_peakAt_nonbot ] ;
  · exact Or.inr ( Classical.not_not.1 fun h => hf h hx );
  · exact Or.inl hx

/-- Setwise version: subsets of the complement of the support lie in the kernel. -/
theorem kernel_eq_botOn_support_discrete
    [DiscreteTopology X] [Fintype X] [DecidableEq X] [Nonempty X]
    (Λ : UCTropicalFunctional X) (S : Set X) :
    S ⊆ (supportOf Λ)ᶜ →
    ∀ f : TropCont X, f.support ⊆ S → Λ f = ⊥ := by
  intro hS f hf
  exact kernel_eq_botOn_compl_support_discrete Λ f (hf.trans hS)

/-! ## Pushforward of tropical functionals -/

/-- Pushforward of an upper-continuous tropical functional along a continuous map.
Given `φ : X → Y` continuous and `Λ : UCTropicalFunctional X`,
`(pushforward φ hφ Λ)(g) = Λ(g ∘ φ)` for `g : TropCont Y`. -/
def UCTropicalFunctional.pushforward
    (φ : X → Y) (hφ : Continuous φ)
    (Λ : UCTropicalFunctional X) : UCTropicalFunctional Y where
  toFun g := Λ.toFun (g.comp ⟨φ, hφ⟩)
  map_sup' f g := by
    show Λ.toFun ((TropCont.tsup f g).comp ⟨φ, hφ⟩) =
         Λ.toFun (f.comp ⟨φ, hφ⟩) ⊔ Λ.toFun (g.comp ⟨φ, hφ⟩)
    have h : (TropCont.tsup f g).comp ⟨φ, hφ⟩ =
           TropCont.tsup (f.comp ⟨φ, hφ⟩) (g.comp ⟨φ, hφ⟩) := by
      ext x; simp [TropCont.tsup]
    rw [h]; exact Λ.map_sup' _ _
  map_const' c := by
    show Λ.toFun ((ContinuousMap.const Y c).comp ⟨φ, hφ⟩) = c
    have h : (ContinuousMap.const Y c).comp ⟨φ, hφ⟩ = ContinuousMap.const X c := by ext; simp
    rw [h]; exact Λ.map_const' c
  map_addConst' c f g hfg := by
    apply Λ.map_addConst'; intro x; exact hfg (φ x)
  monotone' h := Λ.monotone' (fun x => h (φ x))
  upper_continuous' hmono hconv := by
    apply Λ.upper_continuous'
    · intro m n hmn x; exact hmono hmn (φ x)
    · intro x; exact hconv (φ x)

/-! ## Support functoriality -/

/-
**Functoriality of support under pushforward (discrete case).**
On finite discrete spaces, the support of the pushforward functional is contained
in the image of the support. This uses the kernel duality theorem.
-/
theorem support_pushforward_le_discrete
    [DiscreteTopology X] [Fintype X] [DecidableEq X] [Nonempty X]
    {Z : Type*} [TopologicalSpace Z] [DiscreteTopology Z] [Fintype Z] [DecidableEq Z]
    (φ : X → Z) (hφ : Continuous φ)
    (Λ : UCTropicalFunctional X) :
    supportOf (UCTropicalFunctional.pushforward φ hφ Λ) ⊆ φ '' supportOf Λ := by
  intro z hz
  simp_all +decide [ mem_supportOf_iff_peakAt ];
  contrapose! hz; simp_all +decide [ UCTropicalFunctional.pushforward ] ;
  rw [ finite_representation_formula ];
  simp_all +decide [ deltaWeight, peakAt ];
  exact fun x => Classical.or_iff_not_imp_left.2 fun hx => hz x hx

/-- Contrapositive of the discrete pushforward support inclusion. -/
theorem not_mem_support_pushforward_of_not_in_image_discrete
    [DiscreteTopology X] [Fintype X] [DecidableEq X] [Nonempty X]
    {Z : Type*} [TopologicalSpace Z] [DiscreteTopology Z] [Fintype Z] [DecidableEq Z]
    (φ : X → Z) (hφ : Continuous φ)
    (Λ : UCTropicalFunctional X) {y : Z}
    (hy : y ∉ φ '' supportOf Λ) :
    y ∉ supportOf (UCTropicalFunctional.pushforward φ hφ Λ) :=
  fun h => hy (support_pushforward_le_discrete φ hφ Λ h)

/-! ## Normalized functionals and uniqueness -/

/-- A tropical functional is normalized if `Λ(0) = 0`. -/
def Normalized (Λ : UCTropicalFunctional X) : Prop :=
  Λ.toFun (0 : TropCont X) = 0

/-
**Uniqueness from peak values.**
On a finite discrete space, two tropical functionals that agree on all
singleton peak functions must be equal.
-/
theorem eq_of_agree_on_singleton_peaks
    [DiscreteTopology X] [Fintype X] [DecidableEq X] [Nonempty X]
    {Λ Γ : UCTropicalFunctional X}
    (_hconst : Λ.toFun (0 : TropCont X) = Γ.toFun (0 : TropCont X))
    (hatom : ∀ x : X, Λ.toFun (peakAt x) = Γ.toFun (peakAt x)) :
    Λ = Γ := by
  refine' UCTropicalFunctional.ext fun f => _;
  convert finite_representation_formula Λ.toTropicalFunctional f using 1;
  convert finite_representation_formula Γ.toTropicalFunctional f using 2;
  exact funext fun x => congr_arg₂ _ ( hatom x ) rfl

/-
Two normalized functionals with same support and agreeing on peaks are equal.
-/
theorem support_eq_and_agree_on_peaks_imp_eq
    [DiscreteTopology X] [Fintype X] [DecidableEq X] [Nonempty X]
    {Λ Γ : UCTropicalFunctional X}
    (hΛ : Normalized Λ) (hΓ : Normalized Γ)
    (hsupp : supportOf Λ = supportOf Γ)
    (hpeak :
      ∀ x : X, x ∈ supportOf Λ →
        ∀ f : TropCont X, IsPeakAt x Set.univ f →
          Λ.toFun f = Γ.toFun f) :
    Λ = Γ := by
  apply eq_of_agree_on_singleton_peaks;
  · exact hΛ.trans hΓ.symm;
  · intro x
    by_cases hx : x ∈ supportOf Λ;
    · exact hpeak x hx _ ⟨ fun y hy => by simp_all +decide [ TropCont.support ], by simp +decide ⟩;
    · have h_peak_zero : ∀ x : X, x ∉ supportOf Λ → Λ.toFun (peakAt x) = ⊥ := by
        intro x hx;
        exact Classical.not_not.1 fun h => hx <| mem_supportOf_iff_peakAt Λ x |>.2 h;
      have h_peak_zero : ∀ x : X, x ∉ supportOf Γ → Γ.toFun (peakAt x) = ⊥ := by
        exact fun x hx => by simpa using mem_supportOf_iff_peakAt Γ x |>.not.mp hx;
      grind

end