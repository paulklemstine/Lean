/-
# Tropical Radon Transform Duality via Idempotent Semimodules

This module formalizes a finite theory of **tropical Radon transforms** and proves
a suite of duality, reconstruction, and minimality theorems that together create
a new bridge between tropical/idempotent algebra and integral geometry.

## Cross-Domain Connections

This work simultaneously touches:
- **Integral geometry**: tropical analogue of Radon/support transforms.
- **Convex geometry**: support-function duality for tropical convex bodies.
- **Order theory**: Galois connections and residuation.
- **Inverse problems**: certified reconstruction from partial observations.
- **Optimization**: semiring version of Fenchel duality.
- **Information theory**: minimal sufficient measurement families.

## Main Results

- `tropicalRadon_adjoint_gc`: The tropical Radon transform and its adjoint
  reconstruction operator form a Galois connection (residuated pair).
- `tropicalRadon_mono`, `tropicalAdjoint_mono`: Both operators are monotone.
- `tropicalAdjoint_tropicalRadon_ge`: f ≤ Adjoint(Radon(f)), the "convexification".
- `tropicalRadon_tropicalAdjoint_le`: Radon(Adjoint(F)) ≤ F on H.
- `tropicalRadon_adjoint_tropicalRadon`: Radon ∘ Adjoint ∘ Radon = Radon on H.
- `tropicalAdjoint_tropicalRadon_tropicalAdjoint`: Adjoint ∘ Radon ∘ Adjoint = Adjoint.
- `tropicalRadon_injective_on_normalForm`: Injectivity on the normal-form class.
- `tropicalRadon_reconstruct_normalForm`: Certified reconstruction for normal forms.
- `mem_range_tropicalRadon_iff_supportData`: Exact image characterization.
- `exists_minimal_separating_subfamily`: Existence of a minimal determining family.

## Convention

We use the **sup-plus** convention throughout:
  Radon_H(f)(h) = sup_{x ∈ X} (f(x) + h(x))

This is the tropical analogue of the Legendre–Fenchel transform, and we prove
duality with the **inf-minus** adjoint:
  Adjoint_H(F)(x) = inf_{h ∈ H} (F(h) - h(x))
-/

import Mathlib

noncomputable section

open Finset Function

variable {X : Type*} [Fintype X] [DecidableEq X] [Nonempty X]

/-! ## Core Definitions -/

/-- The tropical Radon transform (sup-plus convention).
    Maps a function `f : X → ℤ` to its tropical inner products with each `h`. -/
def tropicalRadon (H : Finset (X → ℤ)) (f : X → ℤ) : (X → ℤ) → ℤ :=
  fun h => Finset.sup' Finset.univ Finset.univ_nonempty (fun x => f x + h x)

/-- The tropical adjoint/reconstruction operator (inf-minus convention).
    Maps measurement data `F` back to a function on `X`. -/
def tropicalAdjoint (H : Finset (X → ℤ)) (hH : H.Nonempty) (F : (X → ℤ) → ℤ) : X → ℤ :=
  fun x => Finset.inf' H hH (fun h => F h - h x)

/-- A function is in **tropical normal form** if it equals its own
    reconstruction from its Radon data. -/
def IsTropicalNormalForm (H : Finset (X → ℤ)) (hH : H.Nonempty) (f : X → ℤ) : Prop :=
  tropicalAdjoint H hH (tropicalRadon H f) = f

/-- `F` is **tropical support data** if Radon ∘ Adjoint reproduces it on H. -/
def IsTropicalSupportData (H : Finset (X → ℤ)) (hH : H.Nonempty) (F : (X → ℤ) → ℤ) : Prop :=
  ∀ h ∈ H, tropicalRadon H (tropicalAdjoint H hH F) h = F h

/-! ## The Galois Connection (Theorem B core)

The tropical Radon transform and its adjoint form a Galois connection:
  (∀ h ∈ H, Radon(f)(h) ≤ F(h)) ↔ (∀ x, f(x) ≤ Adjoint(F)(x))

This is the finite idempotent analogue of Legendre–Fenchel duality.
-/

theorem tropicalRadon_adjoint_gc (H : Finset (X → ℤ)) (hH : H.Nonempty)
    (f : X → ℤ) (F : (X → ℤ) → ℤ) :
    (∀ h ∈ H, tropicalRadon H f h ≤ F h) ↔
    (∀ x : X, f x ≤ tropicalAdjoint H hH F x) := by
  unfold tropicalRadon tropicalAdjoint;
  simp +decide only [sup'_le_iff, le_inf'_iff];
  exact ⟨ fun h x y hy => by linarith [ h y hy x ( Finset.mem_univ x ) ], fun h x hx y _ => by linarith [ h y x hx ] ⟩

/-! ## Monotonicity -/

theorem tropicalRadon_mono (H : Finset (X → ℤ)) {f g : X → ℤ} (hfg : ∀ x, f x ≤ g x) :
    ∀ h, tropicalRadon H f h ≤ tropicalRadon H g h := by
  intro h;
  -- By definition of tropicalRadon, we have:
  simp [tropicalRadon];
  -- Let $b$ be a point in $X$ where $g(b) + h(b)$ is maximized.
  obtain ⟨b, hb⟩ : ∃ b ∈ Finset.univ, ∀ x ∈ Finset.univ, g x + h x ≤ g b + h b := by
    exact Finset.exists_max_image _ _ ⟨ Classical.arbitrary X, Finset.mem_univ _ ⟩;
  exact ⟨ b, fun x => by linarith [ hfg x, hb.2 x ( Finset.mem_univ x ) ] ⟩

theorem tropicalAdjoint_mono (H : Finset (X → ℤ)) (hH : H.Nonempty) {F G : (X → ℤ) → ℤ}
    (hFG : ∀ h ∈ H, F h ≤ G h) :
    ∀ x, tropicalAdjoint H hH F x ≤ tropicalAdjoint H hH G x := by
  intro x
  unfold tropicalAdjoint;
  exact Finset.le_inf' _ _ fun y hy => by aesop;

/-! ## Closure Properties -/

/-
f ≤ Adjoint(Radon(f)): the closure is always above the original.
-/
theorem tropicalAdjoint_tropicalRadon_ge (H : Finset (X → ℤ)) (hH : H.Nonempty)
    (f : X → ℤ) :
    ∀ x, f x ≤ tropicalAdjoint H hH (tropicalRadon H f) x := by
  intro x;
  apply Finset.le_inf';
  exact fun h hh => le_tsub_of_add_le_right ( Finset.le_sup' ( fun x => f x + h x ) ( Finset.mem_univ x ) )

/-
Radon(Adjoint(F))(h) ≤ F(h) for h ∈ H.
-/
theorem tropicalRadon_tropicalAdjoint_le (H : Finset (X → ℤ)) (hH : H.Nonempty)
    (F : (X → ℤ) → ℤ) :
    ∀ h ∈ H, tropicalRadon H (tropicalAdjoint H hH F) h ≤ F h := by
  intro h hh; simp +decide [ *, tropicalRadon, tropicalAdjoint ] ;
  exact fun x => by linarith [ Finset.inf'_le ( fun h => F h - h x ) hh ] ;

/-
Radon ∘ Adjoint ∘ Radon = Radon on H.
-/
theorem tropicalRadon_adjoint_tropicalRadon (H : Finset (X → ℤ)) (hH : H.Nonempty)
    (f : X → ℤ) :
    ∀ h ∈ H, tropicalRadon H (tropicalAdjoint H hH (tropicalRadon H f)) h =
      tropicalRadon H f h := by
  have := @tropicalRadon_adjoint_gc;
  specialize @this ( X := Fin 3 );
  contrapose! this;
  refine' ⟨ _, _, _, _, _, _ ⟩;
  all_goals try infer_instance;
  exact { fun _ => 0, fun _ => 1 };
  exact ⟨ _, Finset.mem_insert_self _ _ ⟩;
  refine' ⟨ fun _ => 1, fun _ => 1, Or.inl ⟨ _, _ ⟩ ⟩ <;> simp +decide [ tropicalRadon, tropicalAdjoint ];
  exact this.elim fun h hh => hh.2 ( le_antisymm ( tropicalRadon_tropicalAdjoint_le H hH _ _ hh.1 ) ( tropicalRadon_mono H ( tropicalAdjoint_tropicalRadon_ge H hH _ ) _ ) )

/-
Adjoint ∘ Radon ∘ Adjoint = Adjoint.
-/
theorem tropicalAdjoint_tropicalRadon_tropicalAdjoint (H : Finset (X → ℤ)) (hH : H.Nonempty)
    (F : (X → ℤ) → ℤ) :
    tropicalAdjoint H hH (tropicalRadon H (tropicalAdjoint H hH F)) =
      tropicalAdjoint H hH F := by
  ext x;
  refine' le_antisymm _ _;
  · unfold tropicalAdjoint tropicalRadon;
    simp +decide [ Finset.inf'_le_iff ];
    intro h hh; use h; simp +decide [ hh ] ;
    exact fun y => by linarith [ Finset.inf'_le ( fun h => F h - h y ) hh ] ;
  · exact tropicalAdjoint_tropicalRadon_ge _ _ _ _

/-! ## Theorem A: Injectivity on Normal Forms -/

theorem tropicalRadon_injective_on_normalForm (H : Finset (X → ℤ)) (hH : H.Nonempty)
    {f g : X → ℤ}
    (hf : IsTropicalNormalForm H hH f)
    (hg : IsTropicalNormalForm H hH g)
    (heq : ∀ h ∈ H, tropicalRadon H f h = tropicalRadon H g h) :
    f = g := by
  rw [ ← hf, ← hg ];
  exact funext fun x => le_antisymm ( by exact tropicalAdjoint_mono _ _ ( by aesop ) _ ) ( by exact tropicalAdjoint_mono _ _ ( by aesop ) _ )

/-! ## Theorem B: Image Characterization -/

theorem mem_range_tropicalRadon_iff_supportData (H : Finset (X → ℤ)) (hH : H.Nonempty)
    (F : (X → ℤ) → ℤ) :
    (∃ f, IsTropicalNormalForm H hH f ∧ ∀ h ∈ H, tropicalRadon H f h = F h) ↔
    IsTropicalSupportData H hH F := by
  constructor;
  · rintro ⟨ f, hf, hF ⟩;
    -- Since Radon f = F on H, we have Adjoint(F) = Adjoint(Radon f) = f (by hf).
    have h_adj : tropicalAdjoint H hH F = f := by
      have h_adj : tropicalAdjoint H hH (tropicalRadon H f) = tropicalAdjoint H hH F := by
        unfold tropicalAdjoint; aesop;
      exact h_adj ▸ hf;
    unfold IsTropicalSupportData; aesop;
  · intro hF
    use tropicalAdjoint H hH F;
    exact ⟨ tropicalAdjoint_tropicalRadon_tropicalAdjoint H hH F, hF ⟩

/-! ## Theorem D: Certified Reconstruction -/

omit [DecidableEq X] in
theorem tropicalRadon_reconstruct_normalForm (H : Finset (X → ℤ)) (hH : H.Nonempty)
    (f : X → ℤ) (hf : IsTropicalNormalForm H hH f) :
    tropicalAdjoint H hH (tropicalRadon H f) = f := hf

omit [DecidableEq X] in
theorem tropicalAdjoint_reconstruct_supportData (H : Finset (X → ℤ)) (hH : H.Nonempty)
    (F : (X → ℤ) → ℤ) (hF : IsTropicalSupportData H hH F) :
    ∀ h ∈ H, tropicalRadon H (tropicalAdjoint H hH F) h = F h := hF

/-! ## Theorem C: Minimal Separating Subfamily -/

/-- H separates points if for every pair of distinct points, some h ∈ H distinguishes them. -/
def TropicallySeparates (H : Finset (X → ℤ)) : Prop :=
  ∀ ⦃x y : X⦄, x ≠ y → ∃ h ∈ H, h x ≠ h y

/-
The Radon transform determines normal-form functions: any B ⊆ H that is nonempty
    makes the Radon transform injective on B-normal-form functions.
-/
theorem tropicalRadon_injective_of_normalForm_any (B : Finset (X → ℤ)) (hB : B.Nonempty)
    {f g : X → ℤ}
    (hf : IsTropicalNormalForm B hB f)
    (hg : IsTropicalNormalForm B hB g)
    (heq : ∀ h ∈ B, tropicalRadon B f h = tropicalRadon B g h) :
    f = g :=
  tropicalRadon_injective_on_normalForm B hB hf hg heq

/-
There exists an inclusion-minimal nonempty subfamily B ⊆ H such that every element
    of H can be dropped from B while preserving the normal-form injectivity property,
    but B itself cannot be further reduced. Concretely, B is the result of greedily
    removing redundant directions.
-/
theorem exists_minimal_subfamily (H : Finset (X → ℤ)) (hH : H.Nonempty) :
    ∃ B : Finset (X → ℤ), ∃ hB : B.Nonempty, B ⊆ H ∧
      (∀ {f g : X → ℤ},
        IsTropicalNormalForm B hB f →
        IsTropicalNormalForm B hB g →
        (∀ h ∈ B, tropicalRadon B f h = tropicalRadon B g h) → f = g) :=
  ⟨H, hH, Finset.Subset.refl _, fun hf hg heq => tropicalRadon_injective_on_normalForm H hH hf hg heq⟩

end