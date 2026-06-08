/-
# Reverse Mathematics: Ramsey-Theoretic Principles — Core Definitions

This module formalizes the key combinatorial principles from the reverse
mathematics of Ramsey's theorem for pairs (RT²₂) and related principles.

## Main definitions

* `SymPairColoring` — A symmetric 2-coloring of unordered pairs of ℕ
* `IsHomogeneous` — Infinite monochromatic set predicate
* `RT2_2` — Ramsey's theorem for pairs with 2 colors
* `RT1_k` — Infinite pigeonhole principle for k colors
* `IsStable` — Stability: each row has a limiting color
* `SRT2_2` — Stable Ramsey's theorem for pairs
* `IsCohesive` — Cohesiveness predicate
* `COH` — The cohesiveness principle

## References

* Cholak–Jockusch–Slaman, "On the strength of Ramsey's theorem for pairs" (2001)
* Seetapun–Slaman, "On the strength of Ramsey's theorem" (1995)
-/
import Mathlib

open Set Filter

/-! ## Symmetric pair colorings -/

/-- A symmetric 2-coloring of pairs of natural numbers. -/
structure SymPairColoring where
  color : ℕ → ℕ → Bool
  symm : ∀ i j, color i j = color j i
  irrefl : ∀ i, color i i = false

namespace SymPairColoring

/-- The slice of a coloring fixing one coordinate. -/
def sliceAt (c : SymPairColoring) (v : ℕ) : ℕ → Bool :=
  fun j => c.color v j

end SymPairColoring

/-! ## Homogeneity -/

/-- An infinite set `S` is *homogeneous* for coloring `c` with color `b`
    if every pair of distinct elements from `S` receives color `b`. -/
def IsHomogeneous (S : Set ℕ) (c : SymPairColoring) (b : Bool) : Prop :=
  S.Infinite ∧ ∀ i ∈ S, ∀ j ∈ S, i ≠ j → c.color i j = b

/-! ## The Ramsey principles -/

/-- **RT²₂**: Every 2-coloring of pairs of naturals has an infinite homogeneous set. -/
def RT2_2 : Prop :=
  ∀ c : SymPairColoring, ∃ S : Set ℕ, ∃ b : Bool, IsHomogeneous S c b

/-- **RT¹ₖ**: Infinite pigeonhole for `k` colors. -/
def RT1_k (k : ℕ) : Prop :=
  ∀ f : ℕ → Fin k, ∃ b : Fin k, (f ⁻¹' {b}).Infinite

/-- **RT¹₂**: Infinite pigeonhole for 2 colors (special case of RT¹ₖ). -/
def RT1_2 : Prop := RT1_k 2

/-- **RT¹₂ (Bool version)**: Equivalent formulation using `Bool`. -/
def RT1_2_Bool : Prop :=
  ∀ f : ℕ → Bool, ∃ b : Bool, (f ⁻¹' {b}).Infinite

/-! ## Stable Ramsey -/

/-- A coloring is *stable* if for each `i`, the function `j ↦ c(i,j)` is
    eventually constant. -/
def IsStable (c : SymPairColoring) : Prop :=
  ∀ i : ℕ, ∃ b : Bool, ∀ᶠ j in atTop, c.color i j = b

/-- The limiting color of row `i` in a stable coloring. -/
noncomputable def stableLimit (c : SymPairColoring) (hstab : IsStable c) (i : ℕ) : Bool :=
  (hstab i).choose

theorem stableLimit_spec (c : SymPairColoring) (hstab : IsStable c) (i : ℕ) :
    ∀ᶠ j in atTop, c.color i j = stableLimit c hstab i :=
  (hstab i).choose_spec

/-- **SRT²₂**: Stable Ramsey's theorem — RT²₂ restricted to stable colorings. -/
def SRT2_2 : Prop :=
  ∀ c : SymPairColoring, IsStable c → ∃ S : Set ℕ, ∃ b : Bool, IsHomogeneous S c b

/-! ## Cohesiveness -/

/-- An infinite set `C` is *cohesive* for `R : ℕ → Set ℕ` if for every `i`,
    either `C ⊆* Rᵢ` or `C ⊆* Rᵢᶜ` (almost-inclusion). -/
def IsCohesive (C : Set ℕ) (R : ℕ → Set ℕ) : Prop :=
  C.Infinite ∧ ∀ i : ℕ, (C \ R i).Finite ∨ (C ∩ R i).Finite

/-- **COH**: For every sequence of sets there is an infinite cohesive set. -/
def COH : Prop :=
  ∀ R : ℕ → Set ℕ, ∃ C : Set ℕ, IsCohesive C R

/-! ## Ascending homogeneous sequences -/

/-- A strictly increasing sequence whose range is homogeneous. -/
def IsAscHomogeneous (a : ℕ → ℕ) (c : SymPairColoring) (b : Bool) : Prop :=
  StrictMono a ∧ ∀ i j, i ≠ j → c.color (a i) (a j) = b

/-
Ascending homogeneous sequences produce infinite homogeneous sets.
-/
theorem ascHomogeneous_to_homogeneous {a : ℕ → ℕ} {c : SymPairColoring} {b : Bool}
    (h : IsAscHomogeneous a c b) : IsHomogeneous (Set.range a) c b := by
  obtain ⟨h_mono, h_hom⟩ := h;
  exact ⟨ Set.infinite_range_of_injective h_mono.injective, by aesop ⟩

/-! ## The reduction coloring: encoding RT¹₂ into RT²₂ -/

/-- Given `f : ℕ → Bool`, construct a symmetric pair coloring `c` such that
    `c(i,j) = f(min i j)` for `i ≠ j`. An infinite homogeneous set for `c`
    yields an infinite monochromatic set for `f`. -/
def pairColoringOfUnary (f : ℕ → Bool) : SymPairColoring where
  color i j := if i = j then false else f (min i j)
  symm i j := by
    simp only [min_comm]
    by_cases h : i = j
    · subst h; rfl
    · have h2 : j ≠ i := Ne.symm h; simp [h, h2]
  irrefl i := by simp