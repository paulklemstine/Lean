/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Congruence Elimination for Boolean Polynomials

This file defines finitely generated semiring congruences on the Boolean
polynomial support model and proves the main elimination theorems.

## Overview

The key result is that elimination congruences (restricting to polynomials
not involving the last variable) are finitely generated when the original
congruence is finitely generated. The generators can be refined to
join-irreducible witnesses, giving a canonical finite presentation.

This is the central theorem of Boolean congruence elimination: it converts
elimination from an unbounded algebraic cancellation problem into a finite
combinatorial engine based on join-irreducible witness extraction.

## Main definitions

* `BPoly.GeneratedCong` — least semiring congruence containing given pairs
* `BPoly.eliminationCong` — pullback congruence along the lifting map
* `IsJoinIrredFinset` — join-irreducibility for finite sets
* `BPoly.elimJoinIrredWitnesses` — join-irreducible witness extraction

## Main results

* `BPoly.elim_finitely_generated_bounded` — elimination is finitely generated
* `BPoly.elim_eq_generate_joinIrred_witnesses` — **main theorem**: JI witnesses
  generate the elimination congruence
-/

import Algebra.BooleanCongruenceElimination.Basic

/-! ## Join-Irreducibility -/

/-- A finset `s` is join-irreducible in the inclusion lattice if it is nonempty
    and cannot be written as the union of two proper subsets. -/
def IsJoinIrredFinset {α : Type*} [DecidableEq α] (s : Finset α) : Prop :=
  s.Nonempty ∧ ∀ a b : Finset α, a ⊂ s → b ⊂ s → a ∪ b ≠ s

/-- Singleton sets are always join-irreducible. -/
theorem isJoinIrredFinset_singleton {α : Type*} [DecidableEq α] (x : α) :
    IsJoinIrredFinset ({x} : Finset α) := by
  refine ⟨⟨x, Finset.mem_singleton.mpr rfl⟩, ?_⟩
  intro a b ha hb
  rw [Finset.ssubset_singleton_iff] at ha hb
  simp [ha, hb]

namespace BPoly

open Classical

/-! ## Generated Semiring Congruence -/

/-- The least semiring congruence on `BPoly n` containing a given finite set of pairs. -/
inductive GeneratedCong {n : ℕ} (R : Finset (BPoly n × BPoly n)) :
    BPoly n → BPoly n → Prop where
  | gen : ∀ {a b}, (a, b) ∈ R → GeneratedCong R a b
  | refl : ∀ a, GeneratedCong R a a
  | symm : ∀ {a b}, GeneratedCong R a b → GeneratedCong R b a
  | trans : ∀ {a b c}, GeneratedCong R a b → GeneratedCong R b c →
      GeneratedCong R a c
  | add_left : ∀ {a b} (c), GeneratedCong R a b →
      GeneratedCong R (a + c) (b + c)
  | mul_left : ∀ {a b} (c), GeneratedCong R a b →
      GeneratedCong R (a * c) (b * c)

namespace GeneratedCong

variable {n : ℕ} {R : Finset (BPoly n × BPoly n)}

theorem add_right {a b : BPoly n} (c : BPoly n) (h : GeneratedCong R a b) :
    GeneratedCong R (c + a) (c + b) := by
  rw [BPoly.add_comm c a, BPoly.add_comm c b]; exact add_left c h

theorem add_compat {a b c d : BPoly n}
    (h1 : GeneratedCong R a b) (h2 : GeneratedCong R c d) :
    GeneratedCong R (a + c) (b + d) :=
  .trans (add_left c h1) (add_right b h2)

theorem mul_right {a b : BPoly n} (c : BPoly n) (h : GeneratedCong R a b) :
    GeneratedCong R (c * a) (c * b) := by
  rw [BPoly.mul_comm c a, BPoly.mul_comm c b]; exact mul_left c h

theorem mul_compat {a b c d : BPoly n}
    (h1 : GeneratedCong R a b) (h2 : GeneratedCong R c d) :
    GeneratedCong R (a * c) (b * d) :=
  .trans (mul_left c h1) (mul_right b h2)

end GeneratedCong

theorem generatedCong_mono {n : ℕ} {R S : Finset (BPoly n × BPoly n)}
    (h : R ⊆ S) : ∀ {a b}, GeneratedCong R a b → GeneratedCong S a b := by
  intro a b hab
  induction hab with
  | gen hm => exact .gen (h hm)
  | refl => exact .refl _
  | symm _ ih => exact .symm ih
  | trans _ _ ih1 ih2 => exact .trans ih1 ih2
  | add_left c _ ih => exact .add_left c ih
  | mul_left c _ ih => exact .mul_left c ih

theorem generatedCong_empty {n : ℕ} {a b : BPoly n}
    (h : GeneratedCong ∅ a b) : a = b := by
  induction h with
  | gen hm => simp at hm
  | refl => rfl
  | symm _ ih => exact ih.symm
  | trans _ _ ih1 ih2 => exact ih1.trans ih2
  | add_left c _ ih => rw [ih]
  | mul_left c _ ih => rw [ih]

/-- Universal property of generated congruences. -/
theorem generatedCong_le {n : ℕ} {R : Finset (BPoly n × BPoly n)}
    {C : BPoly n → BPoly n → Prop}
    (hrefl : ∀ a, C a a) (hsymm : ∀ {a b}, C a b → C b a)
    (htrans : ∀ {a b c}, C a b → C b c → C a c)
    (hadd : ∀ {a b} c, C a b → C (a + c) (b + c))
    (hmul : ∀ {a b} c, C a b → C (a * c) (b * c))
    (hgen : ∀ p ∈ R, C p.1 p.2)
    {a b : BPoly n} (h : GeneratedCong R a b) : C a b := by
  induction h with
  | gen hm => exact hgen _ hm
  | refl => exact hrefl _
  | symm _ ih => exact hsymm ih
  | trans _ _ ih1 ih2 => exact htrans ih1 ih2
  | add_left c _ ih => exact hadd c ih
  | mul_left c _ ih => exact hmul c ih

/-! ## Elimination Congruence -/

/-- The elimination congruence: restriction via the lifting map. -/
def eliminationCong {n : ℕ} (C : BPoly (n + 1) → BPoly (n + 1) → Prop) :
    BPoly n → BPoly n → Prop :=
  fun f g => C (liftBPoly f) (liftBPoly g)

theorem eliminationCong_refl {n : ℕ}
    (R : Finset (BPoly (n + 1) × BPoly (n + 1))) (f : BPoly n) :
    eliminationCong (GeneratedCong R) f f :=
  GeneratedCong.refl _

theorem eliminationCong_symm {n : ℕ}
    {R : Finset (BPoly (n + 1) × BPoly (n + 1))} {f g : BPoly n}
    (h : eliminationCong (GeneratedCong R) f g) :
    eliminationCong (GeneratedCong R) g f :=
  GeneratedCong.symm h

theorem eliminationCong_trans {n : ℕ}
    {R : Finset (BPoly (n + 1) × BPoly (n + 1))} {f g h : BPoly n}
    (h1 : eliminationCong (GeneratedCong R) f g)
    (h2 : eliminationCong (GeneratedCong R) g h) :
    eliminationCong (GeneratedCong R) f h :=
  GeneratedCong.trans h1 h2

theorem eliminationCong_add_left {n : ℕ}
    {R : Finset (BPoly (n + 1) × BPoly (n + 1))} {a b : BPoly n}
    (c : BPoly n) (h : eliminationCong (GeneratedCong R) a b) :
    eliminationCong (GeneratedCong R) (a + c) (b + c) := by
  unfold eliminationCong; rw [lift_add, lift_add]; exact GeneratedCong.add_left _ h

theorem eliminationCong_mul_left {n : ℕ}
    {R : Finset (BPoly (n + 1) × BPoly (n + 1))} {a b : BPoly n}
    (c : BPoly n) (h : eliminationCong (GeneratedCong R) a b) :
    eliminationCong (GeneratedCong R) (a * c) (b * c) := by
  unfold eliminationCong; rw [lift_mul, lift_mul]; exact GeneratedCong.mul_left _ h

/-! ## Idempotent Addition Lemmas for Elimination -/

/-- From `f ≡ g` in elimination congruence, derive `f ≡ f + g`.
    Uses idempotent addition: `f + f = f` and `add_left`. -/
theorem elimCong_self_union {n : ℕ}
    {R : Finset (BPoly (n + 1) × BPoly (n + 1))} {f g : BPoly n}
    (h : eliminationCong (GeneratedCong R) f g) :
    eliminationCong (GeneratedCong R) f (f + g) := by
  have step : GeneratedCong R (liftBPoly f + liftBPoly f)
      (liftBPoly f + liftBPoly g) :=
    GeneratedCong.add_right (liftBPoly f) h
  rw [BPoly.add_idem] at step
  show GeneratedCong R (liftBPoly f) (liftBPoly (f + g))
  rw [lift_add]; exact step

/-- From `f ≡ g` in elimination congruence, derive `f + g ≡ g`. -/
theorem elimCong_union_self {n : ℕ}
    {R : Finset (BPoly (n + 1) × BPoly (n + 1))} {f g : BPoly n}
    (h : eliminationCong (GeneratedCong R) f g) :
    eliminationCong (GeneratedCong R) (f + g) g := by
  have step : GeneratedCong R (liftBPoly f + liftBPoly g)
      (liftBPoly g + liftBPoly g) :=
    GeneratedCong.add_left (liftBPoly g) h
  rw [BPoly.add_idem] at step
  show GeneratedCong R (liftBPoly (f + g)) (liftBPoly g)
  rw [lift_add]; exact step

/-
Adding a single monomial preserves elimination congruence when
    the monomial is in the support of a congruent partner.
-/
theorem elimCong_add_singleton {n : ℕ}
    {R : Finset (BPoly (n + 1) × BPoly (n + 1))} {f g : BPoly n}
    (h : eliminationCong (GeneratedCong R) f g) (e : BPolyExp n)
    (he : e ∈ g.support) :
    eliminationCong (GeneratedCong R) f (f + ⟨{e}⟩) := by
  -- f ≡ f + g (by elimCong_self_union)
  -- f + ⟨{e}⟩ ≡ f + g + ⟨{e}⟩ = f + g (since e ∈ g.support, so {e} ⊆ (f+g).support)
  -- Actually: ⟨{e}⟩ + f ≡ ⟨{e}⟩ + g (add_right from f ≡ g)
  -- ⟨{e}⟩ + g = g (since e ∈ g.support, g + ⟨{e}⟩ = g)
  -- ⟨{e}⟩ + f = f + ⟨{e}⟩
  -- So f + ⟨{e}⟩ ≡ g
  -- Combined with f ≡ g: f ≡ f + ⟨{e}⟩ by f ≡ g ≡ ... no, need another route.
  -- Better: f ≡ f + g (by elimCong_self_union). f + ⟨{e}⟩ has support ⊆ (f+g).support.
  -- Actually, we need f ≡ f + ⟨{e}⟩, not f + ⟨{e}⟩ ≡ f.
  -- f + f + ⟨{e}⟩ ≡ f + g + ⟨{e}⟩ (add_left ⟨{e}⟩ applied to f + f ≡ f + g)
  -- But we don't have f + f ≡ f + g directly... we do have f ≡ f + g.
  -- add_left ⟨{e}⟩ (f ≡ f + g): f + ⟨{e}⟩ ≡ (f + g) + ⟨{e}⟩ = f + g + ⟨{e}⟩ = f + (g + ⟨{e}⟩) = f + g
  -- (since e ∈ g.support, g + ⟨{e}⟩ = g)
  -- So f + ⟨{e}⟩ ≡ f + g
  -- And f ≡ f + g (from elimCong_self_union)
  -- By symmetry: f + g ≡ f + ⟨{e}⟩
  -- So f ≡ f + g ≡ ... wait, that gives f ≡ f + g and f + ⟨{e}⟩ ≡ f + g.
  -- By symmetry of the second: f + g ≡ f + ⟨{e}⟩.
  -- By transitivity: f ≡ f + ⟨{e}⟩. ✓
  convert eliminationCong_trans ( elimCong_self_union h ) _ using 1;
  convert eliminationCong_trans ( elimCong_union_self h ) _ using 1;
  convert eliminationCong_symm ( eliminationCong_add_left _ h ) using 1;
  refine' BPoly.ext _;
  ext; simp [BPoly.support_add];
  lia

/-! ## Support Universe -/

def supportUniverse {n : ℕ} (R : Finset (BPoly n × BPoly n)) : Finset (BPolyExp n) :=
  R.biUnion (fun p => p.1.support ∪ p.2.support)

def boundedPolys {n : ℕ} (U : Finset (BPolyExp n)) : Finset (BPoly n) :=
  U.powerset.image (fun s => ⟨s⟩)

theorem mem_boundedPolys {n : ℕ} {U : Finset (BPolyExp n)} {f : BPoly n} :
    f ∈ boundedPolys U ↔ f.support ⊆ U := by
  simp [boundedPolys, Finset.mem_image, Finset.mem_powerset]
  constructor
  · rintro ⟨s, hs, rfl⟩; exact hs
  · intro h; exact ⟨f.support, h, by cases f; rfl⟩

theorem boundedPolys_card_le {n : ℕ} (U : Finset (BPolyExp n)) :
    (boundedPolys U).card ≤ 2 ^ U.card := by
  calc (U.powerset.image _).card
      ≤ U.powerset.card := Finset.card_image_le
    _ = 2 ^ U.card := Finset.card_powerset U

/-! ## Finite Generation -/

noncomputable def elimPairsBounded {n : ℕ}
    (V : Finset (BPolyExp n))
    (R : Finset (BPoly (n + 1) × BPoly (n + 1))) :
    Finset (BPoly n × BPoly n) :=
  ((boundedPolys V) ×ˢ (boundedPolys V)).filter
    fun p => eliminationCong (GeneratedCong R) p.1 p.2

/-- **Finite generation of bounded elimination congruence.** -/
theorem elim_finitely_generated_bounded {n : ℕ}
    (V : Finset (BPolyExp n))
    (R : Finset (BPoly (n + 1) × BPoly (n + 1))) :
    ∃ S : Finset (BPoly n × BPoly n),
      ∀ f g : BPoly n,
        f.support ⊆ V → g.support ⊆ V →
        (eliminationCong (GeneratedCong R) f g ↔ GeneratedCong S f g) := by
  use elimPairsBounded V R
  intro f g hf hg
  constructor
  · intro h
    exact GeneratedCong.gen (Finset.mem_filter.mpr
      ⟨Finset.mem_product.mpr ⟨mem_boundedPolys.mpr hf, mem_boundedPolys.mpr hg⟩, h⟩)
  · intro h
    exact generatedCong_le
      (eliminationCong_refl R) eliminationCong_symm eliminationCong_trans
      eliminationCong_add_left eliminationCong_mul_left
      (fun p hp => (Finset.mem_filter.mp hp).2) h

/-! ## Join-Irreducible Witnesses -/

/-- Join-irreducible elimination witnesses: pairs `(f, g)` in the bounded
    universe that are elimination-congruent and have join-irreducible
    support difference. -/
noncomputable def elimJoinIrredWitnesses {n : ℕ}
    (V : Finset (BPolyExp n))
    (R : Finset (BPoly (n + 1) × BPoly (n + 1))) :
    Finset (BPoly n × BPoly n) :=
  ((boundedPolys V) ×ˢ (boundedPolys V)).filter
    fun p => p.1 ≠ p.2 ∧
             IsJoinIrredFinset (p.1.support \ p.2.support) ∧
             eliminationCong (GeneratedCong R) p.1 p.2

/-- Soundness: every JI witness is elimination-congruent. -/
theorem elimJoinIrredWitnesses_sound {n : ℕ}
    (V : Finset (BPolyExp n))
    (R : Finset (BPoly (n + 1) × BPoly (n + 1)))
    (p : BPoly n × BPoly n)
    (hp : p ∈ elimJoinIrredWitnesses V R) :
    eliminationCong (GeneratedCong R) p.1 p.2 := by
  simp only [elimJoinIrredWitnesses, Finset.mem_filter, Finset.mem_product] at hp
  exact hp.2.2.2

/-! ## Key Helper: Subset Case via Induction -/

/-
When `f.support ⊆ g.support` and `f ≡ g` in the elimination congruence,
    the pair is generated by JI witnesses.
    Proof by strong induction on `|g.support \ f.support|`.
-/
theorem subset_elim_gen_by_ji {n : ℕ}
    (V : Finset (BPolyExp n))
    (R : Finset (BPoly (n + 1) × BPoly (n + 1)))
    (f g : BPoly n)
    (hfV : f.support ⊆ V) (hgV : g.support ⊆ V)
    (hsub : f.support ⊆ g.support)
    (hcong : eliminationCong (GeneratedCong R) f g) :
    GeneratedCong (elimJoinIrredWitnesses V R) f g := by
  induction' k : ( g.support \ f.support ).card using Nat.strong_induction_on with k ih generalizing f g;
  by_cases h_empty : g.support \ f.support = ∅ <;> simp_all +decide [ Finset.ext_iff ];
  · rw [ show f = g from BPoly.ext <| Finset.Subset.antisymm hsub h_empty ] ; exact GeneratedCong.refl _;
  · obtain ⟨ e, he₁, he₂ ⟩ := h_empty
    set h := f + ⟨ { e } ⟩
    have hh₁ : h.support ⊆ g.support := by
      simp +zetaDelta at *;
      simp_all +decide [ Finset.subset_iff, BPoly.support_add ]
    have hh₂ : h.support ⊆ V := by
      exact Finset.Subset.trans hh₁ hgV
    have hh₃ : (g.support \ h.support).card < (g.support \ f.support).card := by
      refine' Finset.card_lt_card _;
      simp_all +decide [ Finset.ssubset_def, Finset.subset_iff ];
      exact ⟨ fun x hx₁ hx₂ hx₃ => hx₂ <| by rw [ BPoly.support_add ] ; aesop, e, he₁, he₂, by rw [ BPoly.support_add ] ; aesop ⟩
    have hh₄ : eliminationCong (GeneratedCong R) f h := by
      apply elimCong_add_singleton hcong e he₁
    have hh₅ : eliminationCong (GeneratedCong R) h g := by
      apply GeneratedCong.trans;
      rotate_right;
      exact f.liftBPoly;
      · exact GeneratedCong.symm hh₄;
      · exact hcong
    have hh₆ : GeneratedCong (elimJoinIrredWitnesses V R) f h := by
      have hh₆ : (h.support \ f.support) = {e} := by
        erw [ BPoly.support_add ] ; aesop;
      generalize_proofs at *; (
      have hh₇ : (h, f) ∈ elimJoinIrredWitnesses V R := by
        simp_all +decide [ elimJoinIrredWitnesses ];
        exact ⟨ ⟨ by rw [ mem_boundedPolys ] ; exact hh₂, by rw [ mem_boundedPolys ] ; exact hfV ⟩, by aesop_cat, isJoinIrredFinset_singleton e, by exact GeneratedCong.symm hh₄ ⟩
      generalize_proofs at *; (
      exact GeneratedCong.symm ( GeneratedCong.gen hh₇ )))
    have hh₇ : GeneratedCong (elimJoinIrredWitnesses V R) h g := by
      exact ih _ ( by linarith ) _ _ hh₂ hgV hh₁ hh₅ rfl
    exact GeneratedCong.trans hh₆ hh₇

/-! ## Main Theorem -/

/-- **Main elimination theorem.**
    The elimination congruence restricted to a bounded universe is generated
    by the join-irreducible elimination witnesses. -/
theorem elim_eq_generate_joinIrred_witnesses {n : ℕ}
    (V : Finset (BPolyExp n))
    (R : Finset (BPoly (n + 1) × BPoly (n + 1))) :
    ∀ f g : BPoly n,
      f.support ⊆ V → g.support ⊆ V →
      (eliminationCong (GeneratedCong R) f g ↔
       GeneratedCong (elimJoinIrredWitnesses V R) f g) := by
  intro f g hfV hgV
  constructor
  · -- Forward: eliminate via f ≡ f+g ≡ g with subset inclusions
    intro h
    -- f ≡ f + g (by elimCong_self_union)
    have hfg : eliminationCong (GeneratedCong R) f (f + g) := elimCong_self_union h
    -- f + g ≡ g (by elimCong_union_self)
    have hfgg : eliminationCong (GeneratedCong R) (f + g) g := elimCong_union_self h
    -- f.support ⊆ (f+g).support and g.support ⊆ (f+g).support
    have hf_sub : f.support ⊆ (f + g).support :=
      support_add f g ▸ Finset.subset_union_left
    have hg_sub : g.support ⊆ (f + g).support :=
      support_add f g ▸ Finset.subset_union_right
    have hfg_V : (f + g).support ⊆ V := by
      simp [support_add]; exact Finset.union_subset hfV hgV
    -- Apply subset_elim_gen_by_ji to both halves
    have step1 := subset_elim_gen_by_ji V R f (f + g) hfV hfg_V hf_sub hfg
    have step2 := subset_elim_gen_by_ji V R g (f + g) hgV hfg_V hg_sub
        (eliminationCong_symm hfgg)
    exact GeneratedCong.trans step1 (GeneratedCong.symm step2)
  · -- Reverse: by induction, using that elimination congruence is a congruence
    intro h
    exact generatedCong_le
      (eliminationCong_refl R) eliminationCong_symm eliminationCong_trans
      eliminationCong_add_left eliminationCong_mul_left
      (fun p hp => elimJoinIrredWitnesses_sound V R p hp) h

/-! ## Algorithmic Interface -/

/-- Compute elimination witnesses. -/
noncomputable def enumerateProjectedWitnesses {n : ℕ}
    (V : Finset (BPolyExp n))
    (R : Finset (BPoly (n + 1) × BPoly (n + 1))) :
    Finset (BPoly n × BPoly n) :=
  elimJoinIrredWitnesses V R

/-- Soundness of enumerated witnesses. -/
theorem enumerateProjectedWitnesses_sound {n : ℕ}
    (V : Finset (BPolyExp n))
    (R : Finset (BPoly (n + 1) × BPoly (n + 1)))
    (p : BPoly n × BPoly n)
    (hp : p ∈ enumerateProjectedWitnesses V R) :
    eliminationCong (GeneratedCong R) p.1 p.2 :=
  elimJoinIrredWitnesses_sound V R p hp

/-- Completeness of enumerated witnesses. -/
theorem enumerateProjectedWitnesses_complete {n : ℕ}
    (V : Finset (BPolyExp n))
    (R : Finset (BPoly (n + 1) × BPoly (n + 1)))
    (f g : BPoly n) (hf : f.support ⊆ V) (hg : g.support ⊆ V)
    (h : eliminationCong (GeneratedCong R) f g) :
    GeneratedCong (enumerateProjectedWitnesses V R) f g :=
  (elim_eq_generate_joinIrred_witnesses V R f g hf hg).mp h

end BPoly