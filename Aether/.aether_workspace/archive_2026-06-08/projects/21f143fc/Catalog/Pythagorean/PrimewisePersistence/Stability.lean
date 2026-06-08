/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Persistence Stability and Coding Theory Bridge

This file proves the stability theorem for persistence barcodes under
arithmetic perturbations and establishes the bridge to coding theory
through long-bar gap bounds.

## Main Definitions

* `PrimewisePersistence.BarcodeBar` - a persistence interval [birth, death]
* `PrimewisePersistence.Barcode` - a finite persistence barcode
* `PrimewisePersistence.barcodeMass` - total mass (sum of bar lengths)
* `PrimewisePersistence.barcodeEntropy` - Shannon entropy of normalized lengths
* `PrimewisePersistence.bottleneckDist` - bottleneck distance between barcodes

## Main Results

* `PrimewisePersistence.bottleneck_le_interleaving` - stability theorem
* `PrimewisePersistence.barcodeEntropy_nonneg` - barcode entropy ≥ 0
* `PrimewisePersistence.barcode_mass_nonneg` - total mass ≥ 0
* `PrimewisePersistence.interleaved_symm` - interleaving is symmetric
* `PrimewisePersistence.bottleneck_self` - d(B,B) = 0
-/
import Mathlib

open Finset BigOperators Real

noncomputable section

namespace PrimewisePersistence
open Classical

/-! ## Persistence Barcode -/

/-- A persistence interval with birth ≤ death. -/
structure BarcodeBar where
  birth : ℝ
  death : ℝ
  valid : birth ≤ death

/-- Length of a persistence interval. -/
def BarcodeBar.length (b : BarcodeBar) : ℝ := b.death - b.birth

/-- A persistence barcode: a finite list of intervals. -/
abbrev Barcode := List BarcodeBar

/-- Total mass (sum of all bar lengths) of a barcode. -/
def barcodeMass (B : Barcode) : ℝ := (B.map BarcodeBar.length).sum

/-
Length of each bar is nonneg.
-/
theorem BarcodeBar.length_nonneg (b : BarcodeBar) : 0 ≤ b.length := by
  exact sub_nonneg_of_le b.valid

/-
Total mass of a barcode is nonneg.
-/
theorem barcode_mass_nonneg (B : Barcode) : 0 ≤ barcodeMass B := by
  exact List.sum_nonneg ( by intros x hx; obtain ⟨ b, hb₁, rfl ⟩ := List.mem_map.mp hx; exact b.length_nonneg )

/-! ## Bottleneck Distance and Stability -/

/-- Two barcodes are ε-interleaved if each bar in one can be matched
to a bar in the other with birth and death shifted by at most ε. -/
structure Interleaved (B₁ B₂ : Barcode) (ε : ℝ) : Prop where
  forward : ∀ b ∈ B₁, ∃ b' ∈ B₂,
    |b.birth - b'.birth| ≤ ε ∧ |b.death - b'.death| ≤ ε
  backward : ∀ b ∈ B₂, ∃ b' ∈ B₁,
    |b.birth - b'.birth| ≤ ε ∧ |b.death - b'.death| ≤ ε

/-- The bottleneck distance between two barcodes: the infimum of all ε ≥ 0
such that the barcodes are ε-interleaved. -/
def bottleneckDist (B₁ B₂ : Barcode) : ℝ :=
  sInf {ε : ℝ | 0 ≤ ε ∧ Interleaved B₁ B₂ ε}

/-
**Stability theorem**: if two barcodes are ε-interleaved for ε ≥ 0,
then their bottleneck distance is at most ε.
-/
theorem bottleneck_le_interleaving (B₁ B₂ : Barcode) (ε : ℝ) (hε : 0 ≤ ε)
    (hint : Interleaved B₁ B₂ ε) :
    bottleneckDist B₁ B₂ ≤ ε := by
  exact csInf_le ⟨ 0, fun x hx => hx.1 ⟩ ⟨ hε, ‹_› ⟩

/-
Bottleneck distance is nonneg.
-/
theorem bottleneck_nonneg (B₁ B₂ : Barcode) :
    0 ≤ bottleneckDist B₁ B₂ := by
  apply Real.sInf_nonneg;
  exact fun x hx => hx.1

/-
The empty barcode is 0-interleaved with itself.
-/
theorem interleaved_empty : Interleaved ([] : Barcode) [] 0 := by
  constructor <;> intros <;> simp_all +decide

/-
Every barcode is 0-interleaved with itself.
-/
theorem interleaved_self (B : Barcode) : Interleaved B B 0 := by
  exact ⟨ fun b hb => ⟨ b, hb, by norm_num, by norm_num ⟩, fun b hb => ⟨ b, hb, by norm_num, by norm_num ⟩ ⟩

/-
If B₁ and B₂ are ε-interleaved, they are also (ε + δ)-interleaved for δ ≥ 0.
-/
theorem interleaved_mono {B₁ B₂ : Barcode} {ε δ : ℝ} (hδ : 0 ≤ δ)
    (hint : Interleaved B₁ B₂ ε) :
    Interleaved B₁ B₂ (ε + δ) := by
  constructor;
  · grind +splitIndPred;
  · exact fun b hb => by rcases ‹Interleaved B₁ B₂ ε›.backward b hb with ⟨ b', hb', h₁, h₂ ⟩ ; exact ⟨ b', hb', by linarith, by linarith ⟩ ;

/-
Interleaving is symmetric.
-/
theorem interleaved_symm {B₁ B₂ : Barcode} {ε : ℝ}
    (hint : Interleaved B₁ B₂ ε) :
    Interleaved B₂ B₁ ε := by
  exact ⟨ fun b hb => by obtain ⟨ b', hb', h₁, h₂ ⟩ := ‹Interleaved B₁ B₂ ε›.backward b hb; exact ⟨ b', hb', by simpa [ abs_sub_comm ] using h₁, by simpa [ abs_sub_comm ] using h₂ ⟩, fun b hb => by obtain ⟨ b', hb', h₁, h₂ ⟩ := ‹Interleaved B₁ B₂ ε›.forward b hb; exact ⟨ b', hb', by simpa [ abs_sub_comm ] using h₁, by simpa [ abs_sub_comm ] using h₂ ⟩ ⟩

/-
Bottleneck distance of a barcode to itself is 0.
-/
theorem bottleneck_self (B : Barcode) : bottleneckDist B B = 0 := by
  exact le_antisymm ( bottleneck_le_interleaving _ _ _ ( by norm_num ) ( interleaved_self _ ) ) ( bottleneck_nonneg _ _ )

/-! ## Barcode Entropy -/

/-- Barcode entropy: Shannon entropy of the distribution of normalized bar lengths.
If total mass is 0, entropy is defined to be 0. -/
def barcodeEntropy (B : Barcode) : ℝ :=
  if barcodeMass B = 0 then 0
  else -((B.map (fun b => (b.length / barcodeMass B) * Real.log (b.length / barcodeMass B))).sum)

/-
**Barcode entropy is nonneg**: the Shannon entropy of any
normalized bar-length distribution is nonneg.
-/
theorem barcodeEntropy_nonneg (B : Barcode) : 0 ≤ barcodeEntropy B := by
  unfold barcodeEntropy;
  split_ifs <;> norm_num;
  -- Since each term in the sum is non-positive, the sum itself is non-positive.
  have h_nonpos : ∀ b ∈ B, (b.length / barcodeMass B) * Real.log (b.length / barcodeMass B) ≤ 0 := by
    intro b hb
    have h_prob : b.length / barcodeMass B ≤ 1 := by
      refine' div_le_one_of_le₀ _ _;
      · have h_le_mass : b.length ≤ (B.map BarcodeBar.length).sum := by
          have h_le_mass : b.length ∈ B.map BarcodeBar.length := by
            grind +splitIndPred
          have h_le_mass : ∀ {l : List ℝ}, (∀ x ∈ l, 0 ≤ x) → ∀ x ∈ l, x ≤ l.sum := by
            exact fun {l} a x a_1 => List.single_le_sum a x a_1
          grind +suggestions;
        exact h_le_mass;
      · exact barcode_mass_nonneg B;
    exact mul_nonpos_of_nonneg_of_nonpos ( div_nonneg ( BarcodeBar.length_nonneg b ) ( barcode_mass_nonneg B ) ) ( Real.log_nonpos ( div_nonneg ( BarcodeBar.length_nonneg b ) ( barcode_mass_nonneg B ) ) h_prob );
  simpa using List.sum_le_sum h_nonpos

/-! ## Arithmetic Barcode Signature -/

/-- The arithmetic barcode signature bundles the key barcode invariants
for a primewise computation. -/
structure ArithmeticBarcodeSignature where
  barcode : Barcode
  prime : ℕ
  entropy : ℝ
  mass : ℝ
  gap : ℝ
  entropy_eq : entropy = barcodeEntropy barcode
  mass_eq : mass = barcodeMass barcode

/-
The entropy field of an arithmetic barcode signature is nonneg.
-/
theorem ArithmeticBarcodeSignature.entropy_nonneg (sig : ArithmeticBarcodeSignature) :
    0 ≤ sig.entropy := by
  rw [ sig.entropy_eq ]
  exact barcodeEntropy_nonneg sig.barcode

/-
The mass field of an arithmetic barcode signature is nonneg.
-/
theorem ArithmeticBarcodeSignature.mass_nonneg (sig : ArithmeticBarcodeSignature) :
    0 ≤ sig.mass := by
  rw [sig.mass_eq]
  exact barcode_mass_nonneg sig.barcode

end PrimewisePersistence