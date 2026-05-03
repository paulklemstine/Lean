/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# GL₃ Tropical Satake Surjectivity — Definitions

This file provides the foundational definitions for the GL₃ tropical Satake
surjectivity theorem: dominant coweights, support data, tropical Hecke functions,
the Satake support extraction map, and the admissibility predicate.
-/
import Mathlib

namespace GL3TropicalSatake

/-! ## Sorting into Dominant Chamber -/

/-- Sort three integers into weakly decreasing order: (max, mid, min). -/
def sort₃ (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (max a (max b c),
   a + b + c - max a (max b c) - min a (min b c),
   min a (min b c))

theorem sort₃_fst_ge_snd (a b c : ℤ) : (sort₃ a b c).1 ≥ (sort₃ a b c).2.1 := by
  simp only [sort₃]; omega

theorem sort₃_snd_ge_thd (a b c : ℤ) : (sort₃ a b c).2.1 ≥ (sort₃ a b c).2.2 := by
  simp only [sort₃]; omega

theorem sort₃_of_dominant {a b c : ℤ} (h1 : a ≥ b) (h2 : b ≥ c) :
    sort₃ a b c = (a, b, c) := by
  simp only [sort₃, Prod.mk.injEq]; constructor <;> [skip; constructor] <;> omega

theorem sort₃_sum (a b c : ℤ) :
    (sort₃ a b c).1 + (sort₃ a b c).2.1 + (sort₃ a b c).2.2 = a + b + c := by
  simp only [sort₃]; omega

theorem sort₃_swap12 (a b c : ℤ) : sort₃ b a c = sort₃ a b c := by
  simp only [sort₃, Prod.mk.injEq]; constructor <;> [skip; constructor] <;> omega

theorem sort₃_cycle (a b c : ℤ) : sort₃ b c a = sort₃ a b c := by
  simp only [sort₃, Prod.mk.injEq]; constructor <;> [skip; constructor] <;> omega

theorem sort₃_idempotent (a b c : ℤ) :
    let s := sort₃ a b c
    sort₃ s.1 s.2.1 s.2.2 = s := by
  have h1 := sort₃_fst_ge_snd a b c
  have h2 := sort₃_snd_ge_thd a b c
  exact sort₃_of_dominant h1 h2

/-! ## Dominant Coweights -/

/-- A dominant coweight for GL₃ is a weakly decreasing triple of integers. -/
def GL3Dom := { μ : ℤ × ℤ × ℤ // μ.1 ≥ μ.2.1 ∧ μ.2.1 ≥ μ.2.2 }

instance : DecidableEq GL3Dom := Subtype.instDecidableEq

/-- Construct the dominant representative of any triple. -/
def toGL3Dom (a b c : ℤ) : GL3Dom :=
  ⟨sort₃ a b c, sort₃_fst_ge_snd a b c, sort₃_snd_ge_thd a b c⟩

/-- The zero dominant coweight. -/
def GL3Dom.zero : GL3Dom := ⟨(0, 0, 0), le_refl _, le_refl _⟩

instance : Zero GL3Dom := ⟨GL3Dom.zero⟩

@[simp] theorem GL3Dom.zero_val : (0 : GL3Dom).1 = (0, 0, 0) := rfl

/-- Componentwise addition of dominant coweights is dominant. -/
def GL3Dom.add (μ ν : GL3Dom) : GL3Dom :=
  ⟨(μ.1.1 + ν.1.1, μ.1.2.1 + ν.1.2.1, μ.1.2.2 + ν.1.2.2),
   by constructor <;> [linarith [μ.2.1, ν.2.1]; linarith [μ.2.2, ν.2.2]]⟩

instance : Add GL3Dom := ⟨GL3Dom.add⟩

@[simp] theorem GL3Dom.add_val (μ ν : GL3Dom) :
    (μ + ν).1 = (μ.1.1 + ν.1.1, μ.1.2.1 + ν.1.2.1, μ.1.2.2 + ν.1.2.2) := rfl

/-- toGL3Dom of a dominant triple returns the original triple. -/
theorem toGL3Dom_of_dominant {a b c : ℤ} (h1 : a ≥ b) (h2 : b ≥ c) :
    toGL3Dom a b c = ⟨(a, b, c), h1, h2⟩ := by
  simp only [toGL3Dom]
  exact Subtype.ext (sort₃_of_dominant h1 h2)

/-- toGL3Dom is invariant under transposition (12). -/
theorem toGL3Dom_swap12 (a b c : ℤ) : toGL3Dom b a c = toGL3Dom a b c := by
  exact Subtype.ext (sort₃_swap12 a b c)

/-- toGL3Dom is invariant under the 3-cycle. -/
theorem toGL3Dom_cycle (a b c : ℤ) : toGL3Dom b c a = toGL3Dom a b c := by
  exact Subtype.ext (sort₃_cycle a b c)

/-! ## Support Datum -/

/-- A support datum is a function from dominant coweights to ℤ. -/
def SupportDatum := GL3Dom → ℤ

instance : CoeFun SupportDatum (fun _ => GL3Dom → ℤ) := ⟨id⟩



/-- Finite support means vanishing outside some finite set. -/
def FiniteSupport (h : SupportDatum) : Prop :=
  ∃ s : Finset GL3Dom, ∀ μ, μ ∉ s → h μ = 0

/-! ## S₃-Invariant Functions (Tropical Hecke Functions) -/

/-- A function f : ℤ³ → ℤ is S₃-invariant if it is invariant under
    transposition (12) and the 3-cycle (123). -/
def IsS3Invariant (f : ℤ → ℤ → ℤ → ℤ) : Prop :=
  (∀ a b c, f a b c = f b a c) ∧ (∀ a b c, f a b c = f b c a)

/-- A tropical Hecke function for GL₃ is an S₃-invariant function ℤ³ → ℤ. -/
def TropicalHeckeGL3 := { f : ℤ → ℤ → ℤ → ℤ // IsS3Invariant f }

instance : CoeFun TropicalHeckeGL3 (fun _ => ℤ → ℤ → ℤ → ℤ) := ⟨Subtype.val⟩

/-- Extensionality for tropical Hecke functions. -/
@[ext] theorem TropicalHeckeGL3.ext {f g : TropicalHeckeGL3}
    (h : ∀ a b c, f.1 a b c = g.1 a b c) : f = g :=
  Subtype.ext (funext fun a => funext fun b => funext fun c => h a b c)

/-! ## Satake Support Map -/

/-- Extract the support datum: restrict a Hecke function to the dominant chamber. -/
def satakeSupport (f : TropicalHeckeGL3) : SupportDatum :=
  fun μ => f.1 μ.1.1 μ.1.2.1 μ.1.2.2

/-! ## Satake Extension -/

/-- Extend a support datum to an S₃-invariant function on ℤ³ via sorting. -/
def satakeExtend (h : SupportDatum) : ℤ → ℤ → ℤ → ℤ :=
  fun a b c => h (toGL3Dom a b c)

theorem satakeExtend_invariant (h : SupportDatum) : IsS3Invariant (satakeExtend h) := by
  constructor
  · intro a b c; simp only [satakeExtend, toGL3Dom_swap12]
  · intro a b c; simp only [satakeExtend, toGL3Dom_cycle]

/-- Lift a support datum to a tropical Hecke function. -/
def satakeExtendHecke (h : SupportDatum) : TropicalHeckeGL3 :=
  ⟨satakeExtend h, satakeExtend_invariant h⟩

/-! ## S₃-invariant functions are determined by their dominant values -/

/-
Any triple has the same S₃-invariant value as its sorted version.
-/
theorem s3_inv_eq_at_sort (f : ℤ → ℤ → ℤ → ℤ) (hf : IsS3Invariant f) (a b c : ℤ) :
    f a b c = f (sort₃ a b c).1 (sort₃ a b c).2.1 (sort₃ a b c).2.2 := by
  unfold sort₃; have := hf.1; have := hf.2; simp_all +decide [max_def, min_def] ;
  grind

end GL3TropicalSatake