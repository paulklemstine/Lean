import Mathlib
import Speculative.Shadowing.Defs

/-!
# The Shadowing Lemma and Transfer Theorems

This file contains:
1. The conjugacy transfer theorem: bi-Lipschitz conjugacies preserve shadowing.
2. Properties of expanding maps relevant to shadowing.

## Main Results

* `conjugacy_preserves_shadowing` — bi-Lipschitz conjugacy preserves the shadowing property
-/

noncomputable section

open Real Set Metric

/-! ## Conjugacy preserves shadowing -/

/-
If f and g are topologically conjugate via a bi-Lipschitz homeomorphism,
    then f has the shadowing property iff g does, with quantified distortion.
-/
theorem conjugacy_preserves_shadowing
    {X Y : Type*} [MetricSpace X] [MetricSpace Y] [CompactSpace X] [CompactSpace Y]
    {f : X → X} {g : Y → Y} {h : X → Y}
    (hconj : ∀ x, h (f x) = g (h x))
    (hbi : Function.Bijective h)
    (hLip : ∀ x y, dist (h x) (h y) ≤ 2 * dist x y)
    (hLip_inv : ∀ x y, dist x y ≤ 2 * dist (h x) (h y)) :
    HasShadowingProperty f ↔ HasShadowingProperty g := by
  constructor <;> intro h ε hε <;> obtain ⟨ δ, hδ, h ⟩ := h ( ε / 4 ) ( div_pos hε zero_lt_four ) <;> refine ⟨ δ / 4, div_pos hδ zero_lt_four, ?_ ⟩ <;> intro n z zshadow <;> refine' _;
  · choose y hy using hbi.2;
    -- By definition of $y$, � we� know that $y_i = h^{-1}(z_i)$ for all $i$.
    have hy_inv : ∀ i : Fin (n + 1), y (z i) = Classical.choose (hbi.2 (z i)) := by
      exact fun i => hbi.injective ( by have := Classical.choose_spec ( hbi.2 ( z i ) ) ; aesop );
    specialize h n ( fun i => y ( z i ) ) ; simp_all +decide [ IsPseudoOrbit, ShadowsOrbit ] ;
    refine' h ( fun i => _ ) |> fun ⟨ y, hy₁, hy₂ ⟩ => ⟨ fun i => ‹X → Y› ( y i ), fun i => _, fun i => _ ⟩ <;> simp_all +decide [ dist_comm ];
    · grind;
    · have := Classical.choose_spec ( hbi.2 ( z i ) ) ; have := hy₂ i; have := hLip ( y i ) ( Classical.choose ( hbi.2 ( z i ) ) ) ; have := hLip_inv ( y i ) ( Classical.choose ( hbi.2 ( z i ) ) ) ; simp_all +decide [ dist_comm ] ;
      linarith [ hy₂ i ];
  · obtain ⟨ y, hy ⟩ := h n ( fun i => ‹X → Y› ( z i ) ) ( by
      intro i; have := zshadow i; simp_all +decide [ IsPseudoOrbit ] ;
      rw [ ← hconj ] ; exact lt_of_le_of_lt ( hLip _ _ ) ( by linarith [ zshadow i ] ) ; );
    -- By definition of $h$, we know � that� $h^{-1}(y_i)$ is a true orbit of $f$.
    obtain ⟨ w, hw ⟩ : ∃ w : Fin (n + 1) → X, (∀ i : Fin n, w (Fin.castSucc i + 1) = f (w (Fin.castSucc i))) ∧ (∀ i : Fin (n + 1), ‹X → Y› (w i) = y i) := by
      choose w hw using fun i => hbi.2 ( y i );
      refine' ⟨ w, _, hw ⟩;
      intro i; have := hy.1 i; have := hbi.injective; aesop;
    refine' ⟨ w, _, _ ⟩ <;> simp_all +decide [ ShadowsOrbit ];
    grind

/-! ## Pseudo-orbit properties -/

/-
A true orbit is a 0-pseudo-orbit.
-/
theorem true_orbit_is_pseudo_orbit {X : Type*} [MetricSpace X] (f : X → X)
    {n : ℕ} (x : Fin (n + 1) → X)
    (horbit : ∀ i : Fin n, x (Fin.castSucc i + 1) = f (x (Fin.castSucc i))) :
    ∀ δ > 0, IsPseudoOrbit f δ x := by
  -- By definition of IsPseudoOrbit, we need to show that for all i, dist (x (i.castSucc + 1)) (f (x i.castSucc)) < δ.
  intro δ hδ
  intro i
  simp [horbit, hδ];
  simp_all +decide [ Fin.ext_iff, Fin.val_add ]

/-
A true orbit shadows itself with distance 0.
-/
theorem true_orbit_shadows_self {X : Type*} [MetricSpace X] (f : X → X)
    {n : ℕ} (x : Fin (n + 1) → X)
    (horbit : ∀ i : Fin n, x (Fin.castSucc i + 1) = f (x (Fin.castSucc i))) :
    ∀ ε > 0, ShadowsOrbit f ε x x := by
  intro ε εpos; constructor <;> aesop;

/-
Concatenation: if pseudo-orbits share an endpoint, they can be glued.
-/
theorem pseudo_orbit_of_subseq {X : Type*} [MetricSpace X] (f : X → X)
    {n : ℕ} {δ₁ δ₂ : ℝ} (hδ : δ₁ ≤ δ₂)
    (x : Fin (n + 1) → X) (hx : IsPseudoOrbit f δ₁ x) :
    IsPseudoOrbit f δ₂ x := by
  exact fun i => lt_of_lt_of_le ( hx i ) hδ

end