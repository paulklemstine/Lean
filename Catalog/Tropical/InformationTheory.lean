/-
# Tropical Information Theory

This file formalizes a tropical analogue of mutual information and proves
the tropical data processing inequality: deterministic post-processing
cannot increase tropical mutual information.

## Definitions

- `postprocess K g`: the pushed channel `(K ▷ g) x z = sup {K x y | g y = z}`
- `tropicalOneSidedSep K x₁ x₂`: one-sided separation `sup_y (K x₁ y - K x₂ y)`
- `tropicalDist K x₁ x₂`: tropical distinguishability, sum of both one-sided separations
- `tropicalMutualInformation K`: the maximum pairwise distinguishability

## Main results

- `oneSidedSep_postprocess_le`: one-sided separation contracts under surjective post-processing
- `tropicalDist_postprocess_le`: pairwise distinguishability contracts under post-processing
- `tropicalMutualInformation_mono`: TMI is monotone in pairwise bounds
- `tropical_mutual_information_data_processing`: the data processing inequality

## Mathematical significance

This establishes the first formally verified monotone information principle in
tropical (max-plus) algebra, founding a rigorous bridge between tropical algebra,
entropy-like functionals, and data-processing phenomena.
-/

import Mathlib

open Finset

noncomputable section

/-! ## Core Definitions -/

/-- Post-processing a channel `K : X → Y → ℝ` by a deterministic map `g : Y → Z`.
    For each input `x` and output `z`, the pushed channel takes the supremum of `K x y`
    over all `y` in the fiber `g⁻¹(z)`. When the fiber is empty, defaults to `0`. -/
def postprocess {X Y Z : Type} [Fintype Y] [DecidableEq Z]
    (K : X → Y → ℝ) (g : Y → Z) : X → Z → ℝ :=
  fun x z =>
    let fiber := Finset.univ.filter (fun y => g y = z)
    if h : fiber.Nonempty then fiber.sup' h (K x) else 0

/-- One-sided tropical separation: `sup_y (K x₁ y - K x₂ y)`.
    Measures how much channel `K` can distinguish `x₁` from `x₂` in one direction. -/
def tropicalOneSidedSep {X Y : Type} [Fintype Y] [Nonempty Y]
    (K : X → Y → ℝ) (x₁ x₂ : X) : ℝ :=
  Finset.univ.sup' univ_nonempty (fun y => K x₁ y - K x₂ y)

/-- Tropical distinguishability between inputs `x₁` and `x₂` through channel `K`.
    Defined as the sum of both one-sided separations:
    `δ_K(x₁,x₂) = sup_y(K x₁ y - K x₂ y) + sup_y(K x₂ y - K x₁ y)` -/
def tropicalDist {X Y : Type} [Fintype Y] [Nonempty Y]
    (K : X → Y → ℝ) (x₁ x₂ : X) : ℝ :=
  tropicalOneSidedSep K x₁ x₂ + tropicalOneSidedSep K x₂ x₁

/-- Tropical mutual information of a channel `K : X → Y → ℝ`.
    Defined as the maximum pairwise tropical distinguishability:
    `TMI(K) = sup_{x₁,x₂} δ_K(x₁,x₂)` -/
def tropicalMutualInformation {X Y : Type} [Fintype X] [Nonempty X] [Fintype Y] [Nonempty Y]
    (K : X → Y → ℝ) : ℝ :=
  Finset.univ.sup' univ_nonempty (fun x₁ =>
    Finset.univ.sup' univ_nonempty (fun x₂ =>
      tropicalDist K x₁ x₂))

/-! ## Auxiliary lemmas -/

/-- The supremum of `f` minus the supremum of `g` over a nonempty finite set
    is at most the supremum of `f - g`. -/
theorem sup'_sub_sup'_le {Y : Type} {s : Finset Y} (hs : s.Nonempty)
    (f h : Y → ℝ) :
    s.sup' hs f - s.sup' hs h ≤ s.sup' hs (fun y => f y - h y) := by
  obtain ⟨a, ha⟩ : ∃ a ∈ s, f a = s.sup' hs f := by
    have := Finset.exists_mem_eq_sup' hs f; aesop;
  exact ha.2 ▸ by simpa using Finset.le_sup' ( fun y => f y - h y ) ha.1 |> le_trans ( sub_le_sub_left ( Finset.le_sup' h ha.1 ) _ ) ;

/-
A sup' over a filtered subset is at most the sup' over the full set.
-/
theorem sup'_filter_le_sup' {Y : Type} [Fintype Y] [Nonempty Y]
    {p : Y → Prop} [DecidablePred p]
    (hs : (Finset.univ.filter p).Nonempty) (f : Y → ℝ) :
    (Finset.univ.filter p).sup' hs f ≤ Finset.univ.sup' univ_nonempty f := by
  exact Finset.sup'_le _ _ fun x hx => Finset.le_sup' _ <| Finset.mem_univ _

/-
When g is surjective, every fiber is nonempty.
-/
theorem fiber_nonempty_of_surjective {Y Z : Type} [Fintype Y] [DecidableEq Z]
    (g : Y → Z) (hg : Function.Surjective g) (z : Z) :
    (Finset.univ.filter (fun y => g y = z)).Nonempty := by
  exact Exists.elim ( hg z ) fun x hx => ⟨ x, by simpa [ hx ] ⟩

/-
Postprocess value equals fiber sup when the fiber is nonempty.
-/
theorem postprocess_eq_sup' {X Y Z : Type} [Fintype Y] [DecidableEq Z]
    (K : X → Y → ℝ) (g : Y → Z) (x : X) (z : Z)
    (hz : (Finset.univ.filter (fun y => g y = z)).Nonempty) :
    postprocess K g x z = (Finset.univ.filter (fun y => g y = z)).sup' hz (K x) := by
  -- By definition of postprocess, we have:
  simp [postprocess, hz]

/-! ## One-sided separation contracts under surjective post-processing -/

/-
One-sided separation contracts under surjective deterministic post-processing.
-/
theorem oneSidedSep_postprocess_le
    {X Y Z : Type} [Fintype Y] [Nonempty Y] [Fintype Z] [Nonempty Z]
    [DecidableEq Z]
    (K : X → Y → ℝ) (g : Y → Z) (hg : Function.Surjective g) (x₁ x₂ : X) :
    tropicalOneSidedSep (postprocess K g) x₁ x₂ ≤ tropicalOneSidedSep K x₁ x₂ := by
  unfold tropicalOneSidedSep;
  simp +decide only [postprocess_eq_sup' _ _ _ _ (fiber_nonempty_of_surjective _ hg _)];
  refine' Finset.sup'_le _ _ _;
  intro z hz; exact le_trans ( sup'_sub_sup'_le _ _ _ ) ( sup'_filter_le_sup' _ _ ) ;

/-! ## Tropical distinguishability contracts under post-processing -/

/-
Pairwise tropical distinguishability contracts under surjective post-processing.
-/
theorem tropicalDist_postprocess_le
    {X Y Z : Type} [Fintype Y] [Nonempty Y] [Fintype Z] [Nonempty Z]
    [DecidableEq Z]
    (K : X → Y → ℝ) (g : Y → Z) (hg : Function.Surjective g) (x₁ x₂ : X) :
    tropicalDist (postprocess K g) x₁ x₂ ≤ tropicalDist K x₁ x₂ := by
  convert add_le_add ( oneSidedSep_postprocess_le K g hg x₁ x₂ ) ( oneSidedSep_postprocess_le K g hg x₂ x₁ ) using 1

/-! ## Monotonicity of TMI -/

/-
Tropical mutual information is monotone: if every pairwise distinguishability
    through `K₂` is bounded by the corresponding one through `K₁`, then
    `TMI(K₂) ≤ TMI(K₁)`.
-/
theorem tropicalMutualInformation_mono
    {X Y₁ Y₂ : Type} [Fintype X] [Nonempty X] [Fintype Y₁] [Nonempty Y₁]
    [Fintype Y₂] [Nonempty Y₂]
    (K₁ : X → Y₁ → ℝ) (K₂ : X → Y₂ → ℝ)
    (h : ∀ x₁ x₂, tropicalDist K₂ x₁ x₂ ≤ tropicalDist K₁ x₁ x₂) :
    tropicalMutualInformation K₂ ≤ tropicalMutualInformation K₁ := by
  apply Finset.sup'_le;
  exact fun x₁ _ => Finset.sup'_le _ _ fun x₂ _ => le_trans ( h x₁ x₂ ) ( Finset.le_sup' ( fun x₁ => Finset.sup' Finset.univ Finset.univ_nonempty fun x₂ => tropicalDist K₁ x₁ x₂ ) ( Finset.mem_univ x₁ ) |> le_trans ( Finset.le_sup' ( fun x₂ => tropicalDist K₁ x₁ x₂ ) ( Finset.mem_univ x₂ ) ) )

/-! ## The Main Theorem: Tropical Data Processing Inequality -/

/-
**Tropical Data Processing Inequality.**
    Deterministic surjective post-processing cannot increase tropical mutual information.
    This is the foundational monotonicity theorem of tropical information theory.

    The surjectivity condition ensures every output category `z : Z` is reachable,
    which is the natural setting for coarse-graining in information theory.
-/
theorem tropical_mutual_information_data_processing
    {X Y Z : Type} [Fintype X] [Nonempty X] [Fintype Y] [Nonempty Y]
    [Fintype Z] [Nonempty Z] [DecidableEq Z]
    (K : X → Y → ℝ) (g : Y → Z) (hg : Function.Surjective g) :
    tropicalMutualInformation (postprocess K g) ≤ tropicalMutualInformation K := by
  -- Apply the monotonicity of the tropical mutual information.
  apply tropicalMutualInformation_mono K (postprocess K g) (fun x₁ x₂ => tropicalDist_postprocess_le K g hg x₁ x₂)

/-! ## Additional Results -/

/-- Tropical distinguishability is symmetric. -/
theorem tropicalDist_symm {X Y : Type} [Fintype Y] [Nonempty Y]
    (K : X → Y → ℝ) (x₁ x₂ : X) :
    tropicalDist K x₁ x₂ = tropicalDist K x₂ x₁ := by
  exact add_comm _ _

/-- Tropical distinguishability is nonneg: `δ_K(x₁,x₂) ≥ 0`. -/
theorem tropicalDist_nonneg {X Y : Type} [Fintype Y] [Nonempty Y]
    (K : X → Y → ℝ) (x₁ x₂ : X) :
    0 ≤ tropicalDist K x₁ x₂ := by
  obtain ⟨ y, hy ⟩ := Finset.exists_max_image Finset.univ ( fun y => K x₁ y - K x₂ y ) ⟨ Classical.arbitrary Y, Finset.mem_univ _ ⟩;
  refine' le_trans _ ( add_le_add ( Finset.le_sup' ( fun y => K x₁ y - K x₂ y ) hy.1 ) ( Finset.le_sup' ( fun y => K x₂ y - K x₁ y ) ( Finset.mem_univ y ) ) ) ; aesop

/-- Tropical self-distinguishability is zero: `δ_K(x,x) = 0`. -/
theorem tropicalDist_self {X Y : Type} [Fintype Y] [Nonempty Y]
    (K : X → Y → ℝ) (x : X) :
    tropicalDist K x x = 0 := by
  unfold tropicalDist tropicalOneSidedSep;
  norm_num

/-
TMI is nonneg.
-/
theorem tropicalMutualInformation_nonneg {X Y : Type} [Fintype X] [Nonempty X]
    [Fintype Y] [Nonempty Y] (K : X → Y → ℝ) :
    0 ≤ tropicalMutualInformation K := by
  exact le_trans ( by norm_num [ tropicalDist_self ] ) ( Finset.le_sup' ( fun x => Finset.sup' Finset.univ ( Finset.univ_nonempty ) fun y => tropicalDist K x y ) ( Finset.mem_univ ( Classical.arbitrary X ) ) |> le_trans ( Finset.le_sup' ( fun y => tropicalDist K ( Classical.arbitrary X ) y ) ( Finset.mem_univ ( Classical.arbitrary X ) ) ) )

/-! ## Bijective relabeling invariance -/

/-
TMI is invariant under bijective relabeling of outputs.
-/
theorem tropicalMutualInformation_equiv
    {X Y Z : Type} [Fintype X] [Nonempty X] [Fintype Y] [Nonempty Y]
    [Fintype Z] [Nonempty Z] [DecidableEq Z]
    (K : X → Y → ℝ) (e : Y ≃ Z) :
    tropicalMutualInformation (postprocess K e) = tropicalMutualInformation K := by
  -- Since $e$ is a bijection, the postprocess of $K$ with $e$ is just $K$ with $e^{-1}$ applied to the output.
  have h_postprocess : ∀ x z, postprocess K e x z = K x (e.symm z) := by
    -- Since e is a bijection, the fiber {y | e y = z} is a singleton set containing e.symm z.
    have h_fiber : ∀ z, (Finset.univ.filter (fun y => e y = z)).Nonempty ∧ (Finset.univ.filter (fun y => e y = z)) = {e.symm z} := by
      simp +decide [ Finset.ext_iff, Set.ext_iff ];
      exact fun z => ⟨ ⟨ e.symm z, by simp +decide ⟩, fun y => ⟨ fun hy => by simpa using congr_arg e.symm hy, fun hy => by simp +decide [ hy ] ⟩ ⟩;
    unfold postprocess; aesop;
  unfold tropicalMutualInformation;
  unfold tropicalDist;
  unfold tropicalOneSidedSep; simp +decide [ h_postprocess ] ;
  congr! 3;
  · refine' le_antisymm _ _ <;> simp +decide [ Finset.sup'_le_iff ];
    · rename_i x hx y hy;
      -- Let $b$ be the element in $Y$ that maximizes $K x b - K y b$.
      obtain ⟨b, hb⟩ : ∃ b : Y, ∀ y' : Y, K x y' - K y y' ≤ K x b - K y b := by
        simpa using Finset.exists_max_image Finset.univ ( fun y' => K x y' - K y y' ) ⟨ Classical.arbitrary Y, Finset.mem_univ _ ⟩;
      exact ⟨ b, fun z => by linarith [ hb ( e.symm z ) ] ⟩;
    · rename_i x hx y hy;
      obtain ⟨ b, hb ⟩ := Finset.exists_max_image Finset.univ ( fun z => K x z - K y z ) ⟨ Classical.arbitrary Y, Finset.mem_univ _ ⟩ ; use e b; intro z; have := hb.2 z ( Finset.mem_univ z ) ; aesop;
  · refine' le_antisymm _ _ <;> simp +decide [ Finset.sup'_le_iff ];
    · rename_i x hx y hy;
      -- Let $b$ be the element in $Y$ that maximizes $K y b - K x b$.
      obtain ⟨b, hb⟩ : ∃ b : Y, ∀ y' : Y, K y y' - K x y' ≤ K y b - K x b := by
        simpa using Finset.exists_max_image Finset.univ ( fun y' => K y y' - K x y' ) ⟨ Classical.arbitrary Y, Finset.mem_univ _ ⟩;
      exact ⟨ b, fun z => by linarith [ hb ( e.symm z ) ] ⟩;
    · rename_i x₁ hx₁ x₂ hx₂;
      -- Let $b$ be the element in $Z$ such that $e.symm b$ maximizes $K x₂ b_1 - K x₁ b_1$.
      obtain ⟨b, hb⟩ : ∃ b : Z, ∀ y : Z, K x₂ (e.symm y) - K x₁ (e.symm y) ≤ K x₂ (e.symm b) - K x₁ (e.symm b) := by
        simpa using Finset.exists_max_image Finset.univ ( fun y => K x₂ ( e.symm y ) - K x₁ ( e.symm y ) ) ⟨ Classical.arbitrary Z, Finset.mem_univ _ ⟩;
      exact ⟨ b, fun y => by simpa using hb ( e y ) ⟩

/-! ## Tensor product channel and subadditivity -/

/-- Product channel: tropical tensor product defined by addition of weights. -/
def tensorChannel {X₁ Y₁ X₂ Y₂ : Type}
    (K₁ : X₁ → Y₁ → ℝ) (K₂ : X₂ → Y₂ → ℝ) : (X₁ × X₂) → (Y₁ × Y₂) → ℝ :=
  fun ⟨x₁, x₂⟩ ⟨y₁, y₂⟩ => K₁ x₁ y₁ + K₂ x₂ y₂

/-
One-sided separation of a tensor channel decomposes additively.
-/
theorem oneSidedSep_tensor {X₁ Y₁ X₂ Y₂ : Type}
    [Fintype Y₁] [Nonempty Y₁] [Fintype Y₂] [Nonempty Y₂]
    (K₁ : X₁ → Y₁ → ℝ) (K₂ : X₂ → Y₂ → ℝ)
    (a₁ b₁ : X₁) (a₂ b₂ : X₂) :
    tropicalOneSidedSep (tensorChannel K₁ K₂) (a₁, a₂) (b₁, b₂) =
      tropicalOneSidedSep K₁ a₁ b₁ + tropicalOneSidedSep K₂ a₂ b₂ := by
  unfold tropicalOneSidedSep;
  refine' le_antisymm _ _ <;> simp +decide [ tensorChannel ] ;
  · intro y₁ y₂; linarith [ Finset.le_sup' ( fun y => K₁ a₁ y - K₁ b₁ y ) ( Finset.mem_univ y₁ ), Finset.le_sup' ( fun y => K₂ a₂ y - K₂ b₂ y ) ( Finset.mem_univ y₂ ) ] ;
  · obtain ⟨ y₁, hy₁ ⟩ := Finset.exists_mem_eq_sup' ( Finset.univ_nonempty ) ( fun y => K₁ a₁ y - K₁ b₁ y ) ; obtain ⟨ y₂, hy₂ ⟩ := Finset.exists_mem_eq_sup' ( Finset.univ_nonempty ) ( fun y => K₂ a₂ y - K₂ b₂ y ) ; use y₁, y₂ ; linarith;

/-
Tropical distinguishability of tensor channels is additive.
-/
theorem tropicalDist_tensor {X₁ Y₁ X₂ Y₂ : Type}
    [Fintype Y₁] [Nonempty Y₁] [Fintype Y₂] [Nonempty Y₂]
    (K₁ : X₁ → Y₁ → ℝ) (K₂ : X₂ → Y₂ → ℝ)
    (a₁ b₁ : X₁) (a₂ b₂ : X₂) :
    tropicalDist (tensorChannel K₁ K₂) (a₁, a₂) (b₁, b₂) =
      tropicalDist K₁ a₁ b₁ + tropicalDist K₂ a₂ b₂ := by
  unfold tropicalDist;
  simp +decide [ oneSidedSep_tensor, add_comm, add_left_comm, add_assoc ]

/-
**Tensor subadditivity of TMI.**
    The tropical mutual information of a product channel is at most the sum
    of the individual TMIs.
-/
theorem tropical_mutual_information_tensor_le
    {X₁ Y₁ X₂ Y₂ : Type}
    [Fintype X₁] [Nonempty X₁] [Fintype Y₁] [Nonempty Y₁]
    [Fintype X₂] [Nonempty X₂] [Fintype Y₂] [Nonempty Y₂]
    (K₁ : X₁ → Y₁ → ℝ) (K₂ : X₂ → Y₂ → ℝ) :
    tropicalMutualInformation (tensorChannel K₁ K₂) ≤
      tropicalMutualInformation K₁ + tropicalMutualInformation K₂ := by
  unfold tropicalMutualInformation;
  simp +decide [ Finset.sup'_le_iff ];
  intro a b c d; rw [ tropicalDist_tensor ] ; gcongr <;> aesop;

end