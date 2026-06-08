/-
# Ramsey Theory: Core Definitions

This module establishes a reusable formal framework for 2-color graph Ramsey theory
and combinatorial line (Hales–Jewett) theory.

## Main definitions

* `TwoColoring n` — a 2-coloring of edges of the complete graph on `Fin n`
* `IsRedClique`, `IsBlueClique` — monochromatic clique predicates
* `RamseyProp n s t` — the Ramsey property: every 2-coloring of Kₙ has a red Kₛ or blue Kₜ
* `CombinatorialLine n k` — a combinatorial line in [k]^n
* `HJProp k r n` — the Hales–Jewett property
-/
import Mathlib

open Finset

/-! ## Two-colorings of complete graphs -/

/-- A 2-coloring of the edges of the complete graph on `Fin n`.
    We represent this as a symmetric, irreflexive function to `Bool`,
    where `true` = red and `false` = blue. -/
structure TwoColoring (n : ℕ) where
  color : Fin n → Fin n → Bool
  symm : ∀ i j, color i j = color j i
  irrefl : ∀ i, color i i = false

namespace TwoColoring

/-- The set of red neighbors of vertex `v`. -/
def redNeighbors (C : TwoColoring n) (v : Fin n) : Finset (Fin n) :=
  Finset.univ.filter (fun w => C.color v w = true)

/-- The set of blue neighbors of vertex `v`. -/
def blueNeighbors (C : TwoColoring n) (v : Fin n) : Finset (Fin n) :=
  Finset.univ.filter (fun w => C.color v w = false ∧ w ≠ v)

end TwoColoring

/-- A set `S` of vertices forms a red clique in coloring `C` if every pair of
    distinct vertices in `S` is colored red. -/
def IsRedClique (C : TwoColoring n) (S : Finset (Fin n)) : Prop :=
  ∀ i ∈ S, ∀ j ∈ S, i ≠ j → C.color i j = true

/-- A set `S` of vertices forms a blue clique in coloring `C` if every pair of
    distinct vertices in `S` is colored blue. -/
def IsBlueClique (C : TwoColoring n) (S : Finset (Fin n)) : Prop :=
  ∀ i ∈ S, ∀ j ∈ S, i ≠ j → C.color i j = false

/-- The Ramsey property: every 2-coloring of the complete graph on `n` vertices
    contains either a red clique of size `s` or a blue clique of size `t`. -/
def RamseyProp (n s t : ℕ) : Prop :=
  ∀ C : TwoColoring n,
    (∃ S : Finset (Fin n), S.card = s ∧ IsRedClique C S) ∨
    (∃ S : Finset (Fin n), S.card = t ∧ IsBlueClique C S)

/-! ## Base cases for the Ramsey property -/

/-- `RamseyProp n 0 t` holds vacuously (an empty red clique always exists). -/
theorem RamseyProp_zero_left (n t : ℕ) : RamseyProp n 0 t := by
  intro C
  left
  exact ⟨∅, by simp, fun i hi => absurd hi (by simp)⟩

/-- `RamseyProp n s 0` holds vacuously. -/
theorem RamseyProp_zero_right (n s : ℕ) : RamseyProp n s 0 := by
  intro C
  right
  exact ⟨∅, by simp, fun i hi => absurd hi (by simp)⟩

/-- `RamseyProp n 1 t` holds for `n ≥ 1`. -/
theorem RamseyProp_one_left (n : ℕ) (hn : 1 ≤ n) (t : ℕ) : RamseyProp n 1 t := by
  intro C
  left
  have hpos : 0 < n := by omega
  obtain ⟨v⟩ := Fin.pos_iff_nonempty.mp hpos
  refine ⟨{v}, by simp, fun i hi j hj hij => ?_⟩
  simp at hi hj
  exact absurd (hi.symm ▸ hj) hij.symm

/-- `RamseyProp n s 1` holds for `n ≥ 1`. -/
theorem RamseyProp_one_right (n : ℕ) (hn : 1 ≤ n) (s : ℕ) : RamseyProp n s 1 := by
  intro C
  right
  have hpos : 0 < n := by omega
  obtain ⟨v⟩ := Fin.pos_iff_nonempty.mp hpos
  refine ⟨{v}, by simp, fun i hi j hj hij => ?_⟩
  simp at hi hj
  exact absurd (hi.symm ▸ hj) hij.symm

/-
`RamseyProp` is monotone in `n`.
-/
theorem RamseyProp.mono {n m s t : ℕ} (h : RamseyProp n s t) (hnm : n ≤ m) :
    RamseyProp m s t := by
      intro C
      by_contra h_contra
      refine absurd (h (TwoColoring.mk (fun i j => C.color (Fin.castLE hnm i) (Fin.castLE hnm j)) (fun i j => C.symm (Fin.castLE hnm i) (Fin.castLE hnm j)) (fun i => C.irrefl (Fin.castLE hnm i))) ) ?_;
      simp_all +decide [ IsRedClique, IsBlueClique ];
      refine' ⟨ fun x hx => _, fun x hx => _ ⟩ <;> have := h_contra.1 ( Finset.image ( fun x : Fin n => Fin.castLE hnm x ) x ) <;> have := h_contra.2 ( Finset.image ( fun x : Fin n => Fin.castLE hnm x ) x ) <;> simp_all +decide [ Finset.card_image_of_injective, Function.Injective ] ;

/-! ## Combinatorial Lines (Hales–Jewett) -/

/-- A combinatorial line in `[k]^n`. Given `n` coordinates and alphabet size `k`,
    a combinatorial line is determined by:
    - `active`: which coordinates are "wild" (vary together)
    - `base`: the fixed values at non-active coordinates
    The line consists of points obtained by setting all active coordinates
    to each value in `Fin k` while keeping inactive coordinates at base values. -/
structure CombinatorialLine (n k : ℕ) where
  /-- Which coordinates are active (wild). -/
  active : Fin n → Bool
  /-- At least one coordinate must be active. -/
  nontrivial : ∃ i, active i = true
  /-- The base word: values at inactive coordinates. -/
  base : Fin n → Fin k

namespace CombinatorialLine

/-- The point on the line corresponding to letter `a`. -/
def point (L : CombinatorialLine n k) (a : Fin k) : Fin n → Fin k :=
  fun i => if L.active i then a else L.base i

/-- Two points on the same line at different letters are distinct. -/
theorem point_injective (L : CombinatorialLine n k)
    {a b : Fin k} (hab : a ≠ b) : L.point a ≠ L.point b := by
  obtain ⟨i, hi⟩ := L.nontrivial
  intro h
  have := congr_fun h i
  simp [point, hi] at this
  exact hab this

end CombinatorialLine

/-- The Hales–Jewett property: every `r`-coloring of `[k]^n` contains
    a monochromatic combinatorial line. -/
def HJProp (k r n : ℕ) : Prop :=
  ∀ c : (Fin n → Fin k) → Fin r,
    ∃ L : CombinatorialLine n k,
      ∀ a b : Fin k, c (L.point a) = c (L.point b)