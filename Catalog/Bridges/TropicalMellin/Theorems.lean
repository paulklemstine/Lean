/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Bridges.TropicalMellin.Defs

/-!
# Tropical Pontryagin–Mellin Duality: Main Theorems

## Theorem 1: Character Separation
Characters separate elements modulo the radical congruence.

## Theorem 2: Evaluation Map Properties
The evaluation map is a well-defined semiring-like morphism.

## Theorem 3: Mellin Transform Convolution Theorem
The Mellin transform converts min-plus convolution to pointwise tropical addition.

## Theorem 4: Sparse Decoding Uniqueness
Under tropical nondegeneracy, sparse signals are uniquely recoverable.
-/

namespace TropicalMellin

noncomputable section
open scoped Classical

variable {S : Type*} [CommSemiring S]

/-! ## Theorem 1: Character Separation -/

/-- **Separation Theorem.** If `s` and `t` are inequivalent modulo the radical
congruence, then some tropical character distinguishes them. This is the
semiring analogue of the classical fact that characters separate points
modulo the radical. -/
theorem characters_separate_mod_radical (s t : S)
    (hne : ¬ (radicalSetoid S).r s t) :
    ∃ χ : TropChar S, χ s ≠ χ t := by
  by_contra h
  push_neg at h
  exact hne h

/-- The radical congruence is exactly the intersection of all character kernels. -/
theorem radicalSetoid_eq_iInf_ker (s t : S) :
    (radicalSetoid S).r s t ↔ ∀ χ : TropChar S, χ s = χ t :=
  Iff.rfl

/-! ## Key algebraic lemma: min distributes over addition in WithTop ℝ -/

/-
Addition distributes over min on the right in `WithTop ℝ`.
-/
theorem WithTop.min_add_right (a b c : TropVal) :
    min a b + c = min (a + c) (b + c) := by
      cases a <;> cases b <;> cases c <;> simp_all +decide [ min_def ];
      all_goals split_ifs <;> simp_all +decide [ WithTop.none_eq_top, WithTop.some_eq_coe ] ;

/-
Addition distributes over min on the left in `WithTop ℝ`.
-/
theorem WithTop.add_min_left (a b c : TropVal) :
    a + min b c = min (a + b) (a + c) := by
      convert @WithTop.min_add_right b c a using 1;
      · exact add_comm _ _;
      · rw [ add_comm a b, add_comm a c ]

/-
`Finset.inf'` distributes over addition on the right.
-/
theorem Finset.inf'_add_right {α : Type*} (A : Finset α) (hA : A.Nonempty)
    (f : α → TropVal) (c : TropVal) :
    A.inf' hA f + c = A.inf' hA (fun a => f a + c) := by
      induction' hA using Finset.Nonempty.cons_induction with x A hx hA ih;
      · simp +decide;
      · cases c <;> simp_all +decide [ WithTop.min_add_right ]

/-
`Finset.inf'` distributes over addition on the left.
-/
theorem Finset.inf'_add_left {α : Type*} (A : Finset α) (hA : A.Nonempty)
    (f : α → TropVal) (c : TropVal) :
    c + A.inf' hA f = A.inf' hA (fun a => c + f a) := by
      have := @WithTop.add_min_left;
      induction hA using Finset.Nonempty.cons_induction <;> aesop

/-
**Product inf factorization.** The infimum over a product of two sets factors
into a sum of infima. This is the key algebraic identity underlying the
Mellin convolution theorem.

  `inf_{(a,b) ∈ A × B} (u(a) + v(b)) = inf_{a ∈ A} u(a) + inf_{b ∈ B} v(b)`
-/
theorem Finset.inf'_product_add {α β : Type*}
    (A : Finset α) (B : Finset β) (hA : A.Nonempty) (hB : B.Nonempty)
    (u : α → TropVal) (v : β → TropVal) :
    (A ×ˢ B).inf' (hA.product hB) (fun p => u p.1 + v p.2) =
    A.inf' hA u + B.inf' hB v := by
      apply le_antisymm;
      · have := Finset.exists_mem_eq_inf' hA u; have := Finset.exists_mem_eq_inf' hB v; aesop;
      · simp +decide [ Finset.inf'_le_iff ];
        exact fun a b ha hb => add_le_add ( Finset.inf'_le _ ha ) ( Finset.inf'_le _ hb )

/-! ## Theorem 2: Evaluation map -/

/-- The evaluation map: sends `s : S` to the function `χ ↦ χ(s)`. -/
def evalMap (s : S) : TropChar S → TropVal := fun χ => χ s

/-- Evaluation respects addition: `ev(a+b)(χ) = min(ev(a)(χ), ev(b)(χ))`. -/
theorem evalMap_add (a b : S) (χ : TropChar S) :
    evalMap (a + b) χ = min (evalMap a χ) (evalMap b χ) := by
  simp [evalMap]

/-- Evaluation respects multiplication: `ev(a*b)(χ) = ev(a)(χ) + ev(b)(χ)`. -/
theorem evalMap_mul (a b : S) (χ : TropChar S) :
    evalMap (a * b) χ = evalMap a χ + evalMap b χ := by
  simp [evalMap]

/-- Evaluation of zero: `ev(0)(χ) = ⊤`. -/
theorem evalMap_zero (χ : TropChar S) : evalMap (0 : S) χ = ⊤ := by
  simp [evalMap]

/-- Evaluation of one: `ev(1)(χ) = 0`. -/
theorem evalMap_one (χ : TropChar S) : evalMap (1 : S) χ = 0 := by
  simp [evalMap]

/-- **Evaluation injectivity modulo radical.** If the radical is trivial,
the evaluation map is injective. -/
theorem evalMap_injective
    (hsemisimple : ∀ s t : S, (radicalSetoid S).r s t → s = t) :
    Function.Injective (evalMap (S := S)) := by
  intro s t h
  apply hsemisimple
  intro χ
  exact congr_fun h χ

/-! ## Theorem 3: Mellin Transform Convolution Theorem -/

/-
**Mellin transform on delta functions.** The Mellin transform of a delta
function `δ_s` (with value 0 at `s`) recovers the character value `χ(s)`.
-/
theorem mellin_delta [DecidableEq S] (s : S) (χ : TropChar S) :
    mellinTransform (fun t => if t = s then (0 : TropVal) else ⊤)
      {s} χ = χ s := by
        -- Apply the definition of mellinTransform to the delta function at s.
        simp [mellinTransform]

/-- Auxiliary: the Mellin transform is an infimum of `f(s) + χ(s)` over the support. -/
theorem mellinTransform_eq_inf' (f : S → TropVal) (A : Finset S) (hA : A.Nonempty)
    (χ : TropChar S) :
    mellinTransform f A χ = A.inf' hA (fun s => f s + χ s) := by
  simp [mellinTransform, hA]

/-
**Tropical Mellin Convolution Theorem.** For finitely-supported functions
`f` and `g` with supports `A` and `B`, the Mellin transform converts min-plus
convolution to pointwise tropical addition:

  `M(f ⋆ g)(χ) = M(f)(χ) + M(g)(χ)`

where `M(f ⋆ g)` is computed over the product support `A·B`.

This is the decisive bridge from abstract duality to computation: it shows that
tropical characters diagonalize min-plus convolution, exactly as classical
characters diagonalize ordinary convolution.
-/
theorem mellin_transform_convolution [DecidableEq S]
    (f g : S → TropVal)
    (A B : Finset S) (hA : A.Nonempty) (hB : B.Nonempty)
    (χ : TropChar S)
    (_hf : ∀ s, s ∉ A → f s = ⊤) (_hg : ∀ s, s ∉ B → g s = ⊤) :
    mellinTransform (tropConvVal f g A B) (tropConvSupp A B) χ =
    mellinTransform f A χ + mellinTransform g B χ := by
      nontriviality;
      unfold mellinTransform;
      split_ifs;
      · rw [ ← Finset.inf'_product_add ];
        refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le_iff, tropConvVal ];
        · intro a b ha hb;
          refine' ⟨ a * b, _, _ ⟩;
          · exact Finset.mem_image.mpr ⟨ ( a, b ), Finset.mem_product.mpr ⟨ ha, hb ⟩, rfl ⟩;
          · split_ifs <;> simp_all +decide [ ← add_assoc ];
            · rw [ add_assoc, add_assoc ];
              rw [ Finset.inf'_add_right ];
              simp +decide [ add_assoc, add_comm, add_left_comm ];
              exact ⟨ a, b, ⟨ ⟨ ha, hb ⟩, rfl ⟩, le_rfl ⟩;
            · exact False.elim ( ‹∀ a_1 b_1 : S, a_1 ∈ A → b_1 ∈ B → ¬a_1 * b_1 = a * b› a b ha hb rfl );
        · intro b hb;
          split_ifs with h;
          · obtain ⟨ p, hp ⟩ := Finset.exists_min_image _ ( fun p => f p.1 + g p.2 ) h;
            refine' ⟨ p.1, p.2, _, _ ⟩ <;> simp_all +decide [ Finset.inf'_le_iff ];
            rw [ ← add_add_add_comm, ← χ.map_mul ];
            exact add_le_add ( Finset.le_inf' _ _ fun q hq => hp.2 _ _ ( Finset.mem_filter.mp hq |>.1 |> Finset.mem_product.mp |>.1 ) ( Finset.mem_filter.mp hq |>.1 |> Finset.mem_product.mp |>.2 ) ( Finset.mem_filter.mp hq |>.2 ) ) ( by rw [ hp.1.2 ] );
          · exact ⟨ _, _, ⟨ hA.choose_spec, hB.choose_spec ⟩, le_top ⟩;
      · simp_all +decide [ tropConvSupp ]

/-! ## Key helper: convolution of delta functions -/

/-
**Delta convolution.** The min-plus convolution of delta functions
at `s` and `t` yields a delta function at `s * t`:
  `δ_s ⋆ δ_t = δ_{s*t}`
-/
theorem delta_conv_delta [DecidableEq S] (s t : S) :
    tropConvVal (fun u => if u = s then (0 : TropVal) else ⊤)
               (fun u => if u = t then (0 : TropVal) else ⊤)
               {s} {t} (s * t) = (0 : TropVal) := by
                 unfold tropConvVal;
                 simp +decide [ Finset.filter_singleton, Finset.inf'_singleton ]

/-
The convolution of deltas at any point other than `s * t` is `⊤`.
-/
theorem delta_conv_delta_off [DecidableEq S] (s t u : S) (h : u ≠ s * t) :
    tropConvVal (fun v => if v = s then (0 : TropVal) else ⊤)
               (fun v => if v = t then (0 : TropVal) else ⊤)
               {s} {t} u = ⊤ := by
                 unfold tropConvVal;
                 grind

/-! ## Theorem 4: Sparse Decoding Uniqueness -/

/-- **Sparse Decoding Uniqueness.** Under tropical nondegeneracy of the
character matrix, k-sparse inputs are uniquely determined by their
transform measurements. This is the identifiability theorem for
tropical compressed sensing. -/
theorem sparse_decode_unique {n m : ℕ} [NeZero n]
    (chars : Fin m → TropChar S)
    (gens : Fin n → S)
    (hnd : TropicallyNondegenerate chars gens k)
    {x y : Fin n → TropVal}
    (hx : (Finset.filter (fun j => x j ≠ ⊤) Finset.univ).card ≤ k)
    (hy : (Finset.filter (fun j => y j ≠ ⊤) Finset.univ).card ≤ k)
    (hEq : transformMeasurement chars gens x = transformMeasurement chars gens y) :
    x = y :=
  hnd x y hx hy hEq

/-! ## Corollaries combining duality with transform -/

/-
**Mellin delta identity.** Combining the delta Mellin result with
character separation: the Mellin transform of delta functions
completely encodes the character values, and hence (modulo radical)
the semiring element itself.
-/
theorem mellin_encodes_element [DecidableEq S]
    (hsemisimple : ∀ s t : S, (radicalSetoid S).r s t → s = t)
    (s t : S)
    (h : ∀ χ : TropChar S,
      mellinTransform (fun u => if u = s then (0 : TropVal) else ⊤) {s} χ =
      mellinTransform (fun u => if u = t then (0 : TropVal) else ⊤) {t} χ) :
    s = t := by
      contrapose! hsemisimple;
      refine' ⟨ s, t, _, hsemisimple ⟩;
      exact fun χ => by have := h χ; rw [ mellin_delta, mellin_delta ] at this; exact this;

end
end TropicalMellin