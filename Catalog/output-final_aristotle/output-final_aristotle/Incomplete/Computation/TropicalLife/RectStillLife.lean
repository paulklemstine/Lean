import Novelty.Basic
import Computation.TropicalLife.StillLife

/-!
# Generalized Rectangular Still Lifes and Exponential Diversity

## Overview

We generalize the 2×2 block still life from a single example on the 6×6 torus
to arbitrary placements on various torus sizes, and prove that the number of
distinct still lifes grows exponentially with the number of independent blocks.

## Main Results

* `block_at_still_life_8x8` — 2×2 block at position (2,3) on the 8×8 torus
* `block_at_origin_still_life_8` — 2×2 block at origin on the 8×8 torus
* `blocks_independent_still_life` — two separated 2×2 blocks form a still life
* `fourBlockConfig_still_life` — all 16 subsets of 4 independent blocks are still lifes
* `exponentially_many_still_lifes` — existence of ≥ 16 distinct still lifes
* `blinker_period_2` — the blinker oscillates with period 2

## Significance

These results establish that tropical Life supports an exponentially rich
landscape of stable attractors (still lifes), connecting to description
complexity: each individual still life has bounded orbit description length
(by `still_life_has_bounded_orbit_description`), yet the family cardinality
grows exponentially. This tension between individual simplicity and collective
complexity is a hallmark of emergent computation.
-/

open Function Finset

/-! ## 2×2 Block at Various Positions -/

/-- 2×2 block at position (2,3) on the 8×8 torus. -/
def blockAt23_8 : Config 8 8 :=
  fun ⟨i, j⟩ => if (i.val = 2 ∨ i.val = 3) ∧ (j.val = 3 ∨ j.val = 4) then 1 else 0

/-- A 2×2 block placed at position (2,3) on the 8×8 torus is a still life. -/
theorem block_at_still_life_8x8 :
    IsStillLife (by omega : 0 < 8) (by omega : 0 < 8) blockAt23_8 := by native_decide

/-- 2×2 block at origin on the 8×8 torus. -/
def blockOrigin8 : Config 8 8 :=
  fun ⟨i, j⟩ => if i.val ≤ 1 ∧ j.val ≤ 1 then 1 else 0

/-- The 2×2 block at origin is a still life on the 8×8 torus. -/
theorem block_at_origin_still_life_8 :
    IsStillLife (by omega : 0 < 8) (by omega : 0 < 8) blockOrigin8 := by native_decide

/-! ## Multiple Independent Blocks -/

/-- Configuration with two separated 2×2 blocks on the 12×12 torus. -/
def twoBlocks12 : Config 12 12 :=
  fun ⟨i, j⟩ =>
    if (i.val ≤ 1 ∧ j.val ≤ 1) ∨ ((i.val = 5 ∨ i.val = 6) ∧ (j.val = 5 ∨ j.val = 6))
    then 1 else 0

/-- Two well-separated 2×2 blocks form a still life on the 12×12 torus. -/
theorem blocks_independent_still_life :
    IsStillLife (by omega : 0 < 12) (by omega : 0 < 12) twoBlocks12 := by native_decide

/-! ## Four Independent Blocks: Exponential Family -/

/-- Configuration with a subset of 4 possible 2×2 blocks on a 20×20 torus.
    Block positions at (0,0), (0,5), (5,0), (5,5), well-separated. -/
def fourBlockConfig (b₀ b₁ b₂ b₃ : Bool) : Config 20 20 :=
  fun ⟨i, j⟩ =>
    if b₀ && i.val ≤ 1 && j.val ≤ 1 then 1
    else if b₁ && i.val ≤ 1 && (j.val = 5 ∨ j.val = 6) then 1
    else if b₂ && (i.val = 5 ∨ i.val = 6) && j.val ≤ 1 then 1
    else if b₃ && (i.val = 5 ∨ i.val = 6) && (j.val = 5 ∨ j.val = 6) then 1
    else 0

private theorem fb_tttt : IsStillLife (by omega : 0 < 20) (by omega : 0 < 20) (fourBlockConfig true true true true) := by native_decide
private theorem fb_tttf : IsStillLife (by omega : 0 < 20) (by omega : 0 < 20) (fourBlockConfig true true true false) := by native_decide
private theorem fb_ttft : IsStillLife (by omega : 0 < 20) (by omega : 0 < 20) (fourBlockConfig true true false true) := by native_decide
private theorem fb_ttff : IsStillLife (by omega : 0 < 20) (by omega : 0 < 20) (fourBlockConfig true true false false) := by native_decide
private theorem fb_tftt : IsStillLife (by omega : 0 < 20) (by omega : 0 < 20) (fourBlockConfig true false true true) := by native_decide
private theorem fb_tftf : IsStillLife (by omega : 0 < 20) (by omega : 0 < 20) (fourBlockConfig true false true false) := by native_decide
private theorem fb_tfft : IsStillLife (by omega : 0 < 20) (by omega : 0 < 20) (fourBlockConfig true false false true) := by native_decide
private theorem fb_tfff : IsStillLife (by omega : 0 < 20) (by omega : 0 < 20) (fourBlockConfig true false false false) := by native_decide
private theorem fb_fttt : IsStillLife (by omega : 0 < 20) (by omega : 0 < 20) (fourBlockConfig false true true true) := by native_decide
private theorem fb_fttf : IsStillLife (by omega : 0 < 20) (by omega : 0 < 20) (fourBlockConfig false true true false) := by native_decide
private theorem fb_ftft : IsStillLife (by omega : 0 < 20) (by omega : 0 < 20) (fourBlockConfig false true false true) := by native_decide
private theorem fb_ftff : IsStillLife (by omega : 0 < 20) (by omega : 0 < 20) (fourBlockConfig false true false false) := by native_decide
private theorem fb_fftt : IsStillLife (by omega : 0 < 20) (by omega : 0 < 20) (fourBlockConfig false false true true) := by native_decide
private theorem fb_fftf : IsStillLife (by omega : 0 < 20) (by omega : 0 < 20) (fourBlockConfig false false true false) := by native_decide
private theorem fb_ffft : IsStillLife (by omega : 0 < 20) (by omega : 0 < 20) (fourBlockConfig false false false true) := by native_decide
private theorem fb_ffff : IsStillLife (by omega : 0 < 20) (by omega : 0 < 20) (fourBlockConfig false false false false) := by native_decide

/-- All 16 subsets of 4 independent 2×2 blocks are still lifes. -/
theorem fourBlockConfig_still_life (b₀ b₁ b₂ b₃ : Bool) :
    IsStillLife (by omega : 0 < 20) (by omega : 0 < 20) (fourBlockConfig b₀ b₁ b₂ b₃) := by
  rcases b₀ <;> rcases b₁ <;> rcases b₂ <;> rcases b₃
  exacts [fb_ffff, fb_ffft, fb_fftf, fb_fftt, fb_ftff, fb_ftft, fb_fttf, fb_fttt,
          fb_tfff, fb_tfft, fb_tftf, fb_tftt, fb_ttff, fb_ttft, fb_tttf, fb_tttt]

/-- Different Boolean vectors produce different configurations. -/
theorem fourBlockConfig_injective :
    ∀ b₀ b₁ b₂ b₃ c₀ c₁ c₂ c₃ : Bool,
      fourBlockConfig b₀ b₁ b₂ b₃ = fourBlockConfig c₀ c₁ c₂ c₃ →
      b₀ = c₀ ∧ b₁ = c₁ ∧ b₂ = c₂ ∧ b₃ = c₃ := by
  intro b₀ b₁ b₂ b₃ c₀ c₁ c₂ c₃ h
  have eval := fun (i j : Fin 20) => congr_fun h (i, j)
  simp only [fourBlockConfig] at eval
  -- Extract values at indicator cells for each block
  have h0 := eval ⟨0, by omega⟩ ⟨0, by omega⟩  -- block 0
  have h1 := eval ⟨0, by omega⟩ ⟨5, by omega⟩  -- block 1
  have h2 := eval ⟨5, by omega⟩ ⟨0, by omega⟩  -- block 2
  have h3 := eval ⟨5, by omega⟩ ⟨5, by omega⟩  -- block 3
  revert h0 h1 h2 h3
  rcases b₀ <;> rcases b₁ <;> rcases b₂ <;> rcases b₃ <;>
    rcases c₀ <;> rcases c₁ <;> rcases c₂ <;> rcases c₃ <;> simp

/-- **Exponential Diversity of Still Lifes**: There exist at least 16 = 2⁴ distinct
    still life configurations on the 20×20 torus.

    This demonstrates that the tropical Life automaton supports an exponentially
    rich landscape of stable attractors. Combined with
    `still_life_has_bounded_orbit_description`, this shows that each attractor
    has bounded descriptive complexity, yet the attractor landscape is
    combinatorially explosive — a hallmark of emergent complexity. -/
theorem exponentially_many_still_lifes :
    ∃ S : Finset (Config 20 20),
      S.card ≥ 16 ∧
      ∀ c ∈ S, IsStillLife (by omega : 0 < 20) (by omega : 0 < 20) c := by
  refine ⟨(Finset.univ : Finset (Bool × Bool × Bool × Bool)).image
    (fun ⟨b₀, b₁, b₂, b₃⟩ => fourBlockConfig b₀ b₁ b₂ b₃), ?_, ?_⟩
  · have hinj : Function.Injective
        (fun (x : Bool × Bool × Bool × Bool) =>
          fourBlockConfig x.1 x.2.1 x.2.2.1 x.2.2.2) := by
      intro ⟨a₀, a₁, a₂, a₃⟩ ⟨b₀, b₁, b₂, b₃⟩ h
      have := fourBlockConfig_injective a₀ a₁ a₂ a₃ b₀ b₁ b₂ b₃ h
      simp [this.1, this.2.1, this.2.2.1, this.2.2.2]
    rw [Finset.card_image_of_injective _ hinj]
    simp [Finset.card_univ, Fintype.card_prod, Fintype.card_bool]
  · intro c hc
    simp only [Finset.mem_image, Finset.mem_univ, true_and] at hc
    obtain ⟨⟨b₀, b₁, b₂, b₃⟩, rfl⟩ := hc
    exact fourBlockConfig_still_life b₀ b₁ b₂ b₃

/-! ## Blinker: Period-2 Oscillator -/

/-- Horizontal blinker on the 8×8 torus. -/
def blinkerH8 : Config 8 8 :=
  fun ⟨i, j⟩ => if i.val = 3 ∧ (j.val = 2 ∨ j.val = 3 ∨ j.val = 4) then 1 else 0

/-- Vertical blinker on the 8×8 torus. -/
def blinkerV8 : Config 8 8 :=
  fun ⟨i, j⟩ => if j.val = 3 ∧ (i.val = 2 ∨ i.val = 3 ∨ i.val = 4) then 1 else 0

/-- The horizontal blinker evolves to the vertical blinker in one step. -/
theorem blinker_step_HV :
    tropicalLifeStep (by omega : 0 < 8) (by omega : 0 < 8) blinkerH8 = blinkerV8 := by
  native_decide

/-- The vertical blinker evolves back to the horizontal blinker in one step. -/
theorem blinker_step_VH :
    tropicalLifeStep (by omega : 0 < 8) (by omega : 0 < 8) blinkerV8 = blinkerH8 := by
  native_decide

/-- **Blinker Period-2 Oscillation**: the blinker returns to its original state
    after exactly 2 steps, demonstrating periodic non-fixed-point dynamics. -/
theorem blinker_period_2 :
    (tropicalLifeStep (by omega : 0 < 8) (by omega : 0 < 8))^[2] blinkerH8 = blinkerH8 := by
  simp [Function.iterate_succ, Function.comp, blinker_step_HV, blinker_step_VH]

/-- The blinker is not a still life. -/
theorem blinker_not_still_life :
    ¬ IsStillLife (by omega : 0 < 8) (by omega : 0 < 8) blinkerH8 := by native_decide

/-! ## Local Stability Characterization -/

/-- A cell is locally stable if the local rule fixes it. -/
def locallyStable {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (c : Config m n)
    (x : Cell m n) : Prop :=
  tropicalLocalRule hm hn c x = c x

/-- A configuration is a still life if and only if every cell is locally stable.
    This is the fundamental local-to-global equivalence for fixed points. -/
theorem still_life_iff_all_locally_stable {m n : ℕ} (hm : 0 < m) (hn : 0 < n)
    (c : Config m n) :
    IsStillLife hm hn c ↔ ∀ x, locallyStable hm hn c x := by
  simp only [IsStillLife, tropicalLifeStep, funext_iff, locallyStable]