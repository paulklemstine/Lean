/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Compositional Security: Invariant-Bearing Transition Systems

## Overview

This file develops a **compositional calculus of invariant-bearing systems**. The
central contribution is a universal finite product construction with a transfer
meta-theorem: any subadditive real-valued invariant on binary products automatically
extends to sharp bounds on finite products.

## Main Results

### Product Universal Property
* `finProdLift_proj` — β-law: lift ≫ proj = given map
* `finProdLift_unique` — η-law: uniqueness of mediating morphism
* `finProd_universal` — full universal property with ∃!
* `finProd_hom_ext` — morphisms into products determined by projections

### Invariant Transfer
* `subadditive_finProd_bound` — Φ(∏ Xᵢ) ≤ Σ Φ(Xᵢ) from binary subadditivity
* `additive_finProd_eq` — equality version for additive invariants

### Well-Founded Termination
* `finProd_step_wf` — finite product of WF reductions is WF

### Security Composition
* `security_finProd_min` — sec(∏ Xᵢ) ≥ min_i sec(Xᵢ)
-/

open Finset BigOperators Function

noncomputable section

/-! ## Part I: Core Definitions -/

/-- An invariant-bearing transition system. -/
structure InvSystem where
  State : Type
  step : State → State → Prop
  inv : State → ℝ
  inv_mono : ∀ s t, step s t → inv t ≤ inv s

/-- A morphism of invariant systems. -/
structure InvHom (X Y : InvSystem) where
  toFun : X.State → Y.State
  map_step : ∀ s t, X.step s t → Y.step (toFun s) (toFun t)

namespace InvHom

variable {W X Y Z : InvSystem}

@[ext]
theorem ext {f g : InvHom X Y} (h : ∀ s, f.toFun s = g.toFun s) : f = g := by
  cases f; cases g; simp only [mk.injEq]; funext s; exact h s

def id (X : InvSystem) : InvHom X X where
  toFun := _root_.id
  map_step := fun _ _ h => h

def comp (g : InvHom Y Z) (f : InvHom X Y) : InvHom X Z where
  toFun := g.toFun ∘ f.toFun
  map_step := fun _ _ h => g.map_step _ _ (f.map_step _ _ h)

@[simp]
theorem comp_toFun (g : InvHom Y Z) (f : InvHom X Y) (s : X.State) :
    (g.comp f).toFun s = g.toFun (f.toFun s) := rfl

@[simp]
theorem id_comp (f : InvHom X Y) : (InvHom.id Y).comp f = f := by ext; simp [id, comp]

@[simp]
theorem comp_id (f : InvHom X Y) : f.comp (InvHom.id X) = f := by ext; simp [id, comp]

theorem comp_assoc (h : InvHom Z W) (g : InvHom Y Z) (f : InvHom X Y) :
    (h.comp g).comp f = h.comp (g.comp f) := by ext _; simp [comp]

end InvHom

/-! ## Part II: Isomorphisms -/

/-- An isomorphism of invariant systems. -/
structure InvIso (X Y : InvSystem) where
  fwd : InvHom X Y
  bwd : InvHom Y X
  fwd_bwd : ∀ s, fwd.toFun (bwd.toFun s) = s
  bwd_fwd : ∀ s, bwd.toFun (fwd.toFun s) = s

/-! ## Part III: Binary Products -/

namespace InvSystem

def prod (X Y : InvSystem) : InvSystem where
  State := X.State × Y.State
  step := fun s t => X.step s.1 t.1 ∧ Y.step s.2 t.2
  inv := fun s => X.inv s.1 + Y.inv s.2
  inv_mono := fun _ _ ⟨h1, h2⟩ => add_le_add (X.inv_mono _ _ h1) (Y.inv_mono _ _ h2)

def prodFst (X Y : InvSystem) : InvHom (X.prod Y) X where
  toFun := Prod.fst
  map_step := fun _ _ ⟨h, _⟩ => h

def prodSnd (X Y : InvSystem) : InvHom (X.prod Y) Y where
  toFun := Prod.snd
  map_step := fun _ _ ⟨_, h⟩ => h

def prodLift {Z : InvSystem} (f : InvHom Z X) (g : InvHom Z Y) :
    InvHom Z (X.prod Y) where
  toFun := fun s => (f.toFun s, g.toFun s)
  map_step := fun s t h => ⟨f.map_step s t h, g.map_step s t h⟩

@[simp]
theorem prodLift_fst {Z : InvSystem} (f : InvHom Z X) (g : InvHom Z Y) :
    (prodFst X Y).comp (prodLift f g) = f := by
  ext s; simp [prodFst, prodLift, InvHom.comp]

@[simp]
theorem prodLift_snd {Z : InvSystem} (f : InvHom Z X) (g : InvHom Z Y) :
    (prodSnd X Y).comp (prodLift f g) = g := by
  ext s; simp [prodSnd, prodLift, InvHom.comp]

theorem prodLift_unique {Z : InvSystem} {f : InvHom Z X} {g : InvHom Z Y}
    (h : InvHom Z (X.prod Y))
    (hfst : (prodFst X Y).comp h = f) (hsnd : (prodSnd X Y).comp h = g) :
    h = prodLift f g := by
  ext s; apply Prod.ext
  · have := congr_arg (fun φ => InvHom.toFun φ s) hfst
    simpa [prodFst, prodLift, InvHom.comp] using this
  · have := congr_arg (fun φ => InvHom.toFun φ s) hsnd
    simpa [prodSnd, prodLift, InvHom.comp] using this

/-- The full universal property of binary products. -/
theorem prod_universal (X Y Z : InvSystem) (f : InvHom Z X) (g : InvHom Z Y) :
    ∃! h : InvHom Z (X.prod Y),
      (prodFst X Y).comp h = f ∧ (prodSnd X Y).comp h = g :=
  ⟨prodLift f g, ⟨prodLift_fst f g, prodLift_snd f g⟩,
   fun h ⟨hf, hg⟩ => prodLift_unique h hf hg⟩

/-! ## Part IV: Finite Products -/

def finProd {ι : Type} [Fintype ι] (X : ι → InvSystem) : InvSystem where
  State := ∀ i, (X i).State
  step := fun s t => ∀ i, (X i).step (s i) (t i)
  inv := fun s => ∑ i : ι, (X i).inv (s i)
  inv_mono := fun s t h => Finset.sum_le_sum fun i _ => (X i).inv_mono (s i) (t i) (h i)

def finProdProj {ι : Type} [Fintype ι] (X : ι → InvSystem) (i : ι) :
    InvHom (finProd X) (X i) where
  toFun := fun s => s i
  map_step := fun _ _ h => h i

def finProdLift {ι : Type} [Fintype ι] (X : ι → InvSystem)
    {Z : InvSystem} (f : ∀ i, InvHom Z (X i)) : InvHom Z (finProd X) where
  toFun := fun s i => (f i).toFun s
  map_step := fun s t h i => (f i).map_step s t h

@[simp]
theorem finProdLift_proj {ι : Type} [Fintype ι] (X : ι → InvSystem)
    {Z : InvSystem} (f : ∀ i, InvHom Z (X i)) (i : ι) :
    (finProdProj X i).comp (finProdLift X f) = f i := by
  ext s; simp [finProdProj, finProdLift, InvHom.comp]

theorem finProdLift_unique {ι : Type} [Fintype ι] (X : ι → InvSystem)
    {Z : InvSystem} (f : ∀ i, InvHom Z (X i))
    (g : InvHom Z (finProd X))
    (hg : ∀ i, (finProdProj X i).comp g = f i) :
    g = finProdLift X f := by
  ext s; funext i
  have := congr_arg (fun φ => InvHom.toFun φ s) (hg i)
  simpa [finProdProj, finProdLift, InvHom.comp] using this

theorem finProd_universal {ι : Type} [Fintype ι]
    (X : ι → InvSystem) (Z : InvSystem) (f : ∀ i, InvHom Z (X i)) :
    ∃! g : InvHom Z (finProd X), ∀ i, (finProdProj X i).comp g = f i :=
  ⟨finProdLift X f, finProdLift_proj X f, fun g hg => finProdLift_unique X f g hg⟩

theorem finProd_hom_ext {ι : Type} [Fintype ι]
    {X : ι → InvSystem} {Z : InvSystem}
    {g h : InvHom Z (finProd X)}
    (hproj : ∀ i, (finProdProj X i).comp g = (finProdProj X i).comp h) :
    g = h := by
  ext s; funext i
  have := congr_arg (fun φ => InvHom.toFun φ s) (hproj i)
  simpa [finProdProj, InvHom.comp] using this

/-! ## Part V: Structural Isomorphism for Induction -/

/-- Isomorphism: `finProd X` over `Fin (n+1)` ≅ `(X 0).prod (finProd (X ∘ Fin.succ))`. -/
def finProdSuccIso {n : ℕ} (X : Fin (n + 1) → InvSystem) :
    InvIso (finProd X) ((X 0).prod (finProd (X ∘ Fin.succ))) where
  fwd := {
    toFun := fun s => (s 0, fun i => s i.succ)
    map_step := fun _ _ h => ⟨h 0, fun i => h i.succ⟩
  }
  bwd := {
    toFun := fun p => Fin.cons p.1 p.2
    map_step := fun s t ⟨h0, hs⟩ i => by
      refine Fin.cases ?_ (fun j => ?_) i
      · simpa [Fin.cons] using h0
      · simpa [Fin.cons] using hs j
  }
  fwd_bwd := fun ⟨a, f⟩ => by simp [Fin.cons]
  bwd_fwd := fun s => by funext i; refine Fin.cases ?_ (fun j => ?_) i <;> simp [Fin.cons]

/-- Isomorphism: `finProd X` over `Fin 1` ≅ `X 0`. -/
def finProdSingleIso (X : Fin 1 → InvSystem) :
    InvIso (finProd X) (X 0) where
  fwd := {
    toFun := fun s => s 0
    map_step := fun _ _ h => h 0
  }
  bwd := {
    toFun := fun a i => (Fin.fin_one_eq_zero i) ▸ a
    map_step := fun s t h i => by
      have hi := Fin.fin_one_eq_zero i
      subst hi; exact h
  }
  fwd_bwd := fun _ => rfl
  bwd_fwd := fun s => by
    funext i
    have hi := Fin.fin_one_eq_zero i
    subst hi; rfl

/-! ## Part VI: Invariant Transfer Meta-Theorem -/

/-
**The Invariant Transfer Meta-Theorem (Subadditive version)**:

    For n ≥ 1, any iso-invariant subadditive functional on binary products
    satisfies finite-product subadditivity.
-/
theorem subadditive_finProd_bound
    (Φ : InvSystem → ℝ)
    (hprod : ∀ X Y, Φ (X.prod Y) ≤ Φ X + Φ Y)
    (hiso : ∀ X Y, InvIso X Y → Φ X = Φ Y)
    {n : ℕ} (hn : 1 ≤ n) (X : Fin n → InvSystem) :
    Φ (finProd X) ≤ ∑ i : Fin n, Φ (X i) := by
  induction' n with n ih;
  · contradiction;
  · by_cases hn : 1 ≤ n;
    · have := hiso ( finProd X ) ( ( X 0 ).prod ( finProd ( X ∘ Fin.succ ) ) ) ( finProdSuccIso X ) ; simp_all +decide [ Fin.sum_univ_succ ] ;
      grind +splitIndPred;
    · interval_cases n ; simp +decide;
      exact le_of_eq ( hiso _ _ ( finProdSingleIso _ ) )

/-
**Additive invariant equality**: If Φ is exactly additive on binary products
    and invariant under isomorphism, then it sums exactly on finite products.
-/
theorem additive_finProd_eq
    (Φ : InvSystem → ℝ)
    (hprod : ∀ X Y, Φ (X.prod Y) = Φ X + Φ Y)
    (hiso : ∀ X Y, InvIso X Y → Φ X = Φ Y)
    {n : ℕ} (hn : 1 ≤ n) (X : Fin n → InvSystem) :
    Φ (finProd X) = ∑ i : Fin n, Φ (X i) := by
  induction' n, hn using Nat.le_induction with n hn ih;
  · convert hiso _ _ ( finProdSingleIso X ) using 1;
    rw [ Fin.sum_univ_one ];
  · convert ih ( X ∘ Fin.succ ) |> fun h => hiso _ _ ( finProdSuccIso X ) using 1;
    rw [ Fin.sum_univ_succ, hprod, ih ];
    rfl

/-! ## Part VII: Well-Founded Termination -/

/-
If each component system has a well-founded step relation, then
    the synchronous product step relation is well-founded.
-/
theorem finProd_step_wf {ι : Type} [Fintype ι] [Nonempty ι]
    (X : ι → InvSystem)
    (hterm : ∀ i, WellFounded (X i).step) :
    WellFounded (finProd X).step := by
  -- Let's choose any $i \in \text{Finset.univ}$.
  obtain ⟨i₀, hi₀⟩ : ∃ i₀ : ι, True := by
    exact ⟨ Classical.arbitrary ι, trivial ⟩;
  rw [ WellFounded.wellFounded_iff_has_min ] at *;
  intro s hs;
  obtain ⟨ m, hm ⟩ := hterm i₀ |>.has_min ( Set.image ( fun x : ∀ i, ( X i ).State => x i₀ ) s ) ⟨ _, Set.mem_image_of_mem _ hs.choose_spec ⟩;
  rcases hm with ⟨ ⟨ x, hx, rfl ⟩, hm ⟩ ; exact ⟨ x, hx, fun y hy hxy => hm _ ( Set.mem_image_of_mem _ hy ) ( hxy i₀ ) ⟩ ;

/-! ## Part VIII: Security Composition -/

/-
**Finite security composition**: the finite product is bounded below
    by the minimum component security.
-/
theorem security_finProd_min
    (sec : InvSystem → ℝ)
    (hmono : ∀ X Y, sec (X.prod Y) ≥ min (sec X) (sec Y))
    (hiso : ∀ X Y, InvIso X Y → sec X = sec Y)
    {n : ℕ} [NeZero n] (X : Fin n → InvSystem) :
    sec (finProd X) ≥ Finset.univ.inf' (Finset.univ_nonempty (α := Fin n))
      (fun i => sec (X i)) := by
  -- Write n as m + 1 (since NeZero n gives n ≥ 1).
  obtain ⟨m, rfl⟩ : ∃ m, n = m + 1 := Nat.exists_eq_add_of_le' (NeZero.pos n);
  -- We now use the induction hypothesis on `m`.
  have h_ind : ∀ m : ℕ, ∀ X : Fin (m + 1) → InvSystem, sec (finProd X) ≥ (Finset.univ (α := Fin (m + 1))).inf' (by simp) (fun i => sec (X i)) := by
    intro m X;
    induction' m with m ih;
    · exact hiso _ _ ( finProdSingleIso X ) ▸ le_rfl;
    · -- By the induction hypothesis, we have sec (finProd (X ∘ Fin.succ)) ≥ inf' over Fin (m + 1) of sec (X ∘ Fin.succ).
      have h_ind_step : sec (finProd (X ∘ Fin.succ)) ≥ (Finset.univ (α := Fin (m + 1))).inf' (by simp) (fun i => sec (X i.succ)) := by
        exact ih _;
      -- By the properties of the infimum, we have inf' over Fin (m + 2) of sec (X) = min (sec (X 0)) (inf' over Fin (m + 1) of sec (X ∘ Fin.succ)).
      have h_inf : (Finset.univ (α := Fin (m + 2))).inf' (by simp) (fun i => sec (X i)) = min (sec (X 0)) ((Finset.univ (α := Fin (m + 1))).inf' (by simp) (fun i => sec (X i.succ))) := by
        refine' le_antisymm _ _ <;> simp +decide [ Fin.univ_succ ];
        · exact fun i hi => Or.inr <| Or.inr <| ⟨ i, hi, le_rfl ⟩;
        · exact fun i hi => Or.inr <| Or.inr <| ⟨ i, hi, le_rfl ⟩;
      -- By the properties of the infimum, we have sec (finProd X) = sec ((X 0).prod (finProd (X ∘ Fin.succ))).
      have h_finProd : sec (finProd X) = sec ((X 0).prod (finProd (X ∘ Fin.succ))) := by
        exact hiso _ _ ( finProdSuccIso X );
      grind;
  exact h_ind m X

/-! ## Part IX: Derived Corollaries -/

/-- **Pressure subadditivity**: corollary of the transfer theorem. -/
theorem pressure_finProd_bound
    (pressure : InvSystem → ℝ)
    (hprod : ∀ X Y, pressure (X.prod Y) ≤ pressure X + pressure Y)
    (hiso : ∀ X Y, InvIso X Y → pressure X = pressure Y)
    {n : ℕ} (hn : 1 ≤ n) (X : Fin n → InvSystem) :
    pressure (finProd X) ≤ ∑ i : Fin n, pressure (X i) :=
  subadditive_finProd_bound pressure hprod hiso hn X

/-- **Entropy-based additive security**: corollary of additive transfer. -/
theorem entropy_security_additive
    (Φ : InvSystem → ℝ)
    (hprod : ∀ X Y, Φ (X.prod Y) = Φ X + Φ Y)
    (hiso : ∀ X Y, InvIso X Y → Φ X = Φ Y)
    {n : ℕ} (hn : 1 ≤ n) (X : Fin n → InvSystem) :
    Φ (finProd X) = ∑ i : Fin n, Φ (X i) := additive_finProd_eq Φ hprod hiso hn X

end InvSystem

end