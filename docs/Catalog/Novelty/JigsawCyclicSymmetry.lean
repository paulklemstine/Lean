import Mathlib
import Novelty.JigsawComplementFreeAction

/-!
# From tab--blank to `d`-ary tab types: cyclic symmetry forces divisibility by `d`

The tab--blank complement is the `d = 2` case of a general phenomenon.  Suppose a
framed puzzle is milled with `d` distinct interlock *depths* rather than the two
shapes tab and blank, so that a variable piece exposes an element of `ZMod d` and
a clause piece's input is milled for a required depth.  Deepening every mill by
one step is then an order-`d` symmetry of the whole construction.

This file proves that the parity theorem of cycle one is the shadow of a
divisibility theorem: for `n ≥ 1` variables, the combined assembly space of the
`d` shifted puzzles has cardinality divisible by `d`, and is in fact exactly `d`
times the number of shift orbits.  The tab--blank case `d = 2` returns the
earlier parity statement.

## Contents

* `dAssembles_shift`: the depth shift is an exact transport of complete assembly
  spaces, generalising `JigsawFreeComplement.assembles_compPuzzle_compAssign`.
* `depthGauge` and `stable_card_eq_mul_gauge`: a shift-stable set of assemblies
  is exactly `d` copies of its gauge (the assemblies whose variable `0` piece is
  milled to depth `0`), via an explicit bijection with `gauge × ZMod d`.
* `combined_card_dvd`: `d` divides the combined assembly count.
* `combined_card_even_two`: specialising to `d = 2` reproduces the tab--blank
  parity theorem in the `d`-ary language.
* `zeroVar_combined_card_one`: sharpness — for `n = 0` the combined space is a
  single fixed configuration for every `d`.
-/

open Function

namespace JigsawCyclicSymmetry

variable {n d : ℕ} [NeZero d]

/-! ## Part 1 — `d`-ary framed puzzles -/

/-- A literal input of a `d`-ary clause piece: a variable index together with the
interlock depth its input edge is milled for. -/
abbrev DLit (n d : ℕ) := Fin n × ZMod d

/-- A `d`-ary clause piece. -/
abbrev DClause (n d : ℕ) := List (DLit n d)

/-- A `d`-ary framed puzzle on `n` variables. -/
abbrev DPuzzle (n d : ℕ) := List (DClause n d)

/-- A choice of variable pieces assembles the puzzle when every clause piece has
an input whose milled depth matches the depth exposed by its variable. -/
def DAssembles (P : DPuzzle n d) (a : Fin n → ZMod d) : Prop :=
  ∀ c ∈ P, ∃ l ∈ c, a l.1 = l.2

instance (P : DPuzzle n d) (a : Fin n → ZMod d) : Decidable (DAssembles P a) := by
  unfold DAssembles
  infer_instance

/-- The complete assembly space of a `d`-ary framed puzzle. -/
def dAssemblySet (P : DPuzzle n d) : Finset (Fin n → ZMod d) :=
  Finset.univ.filter (DAssembles P)

@[simp] theorem mem_dAssemblySet {P : DPuzzle n d} {a : Fin n → ZMod d} :
    a ∈ dAssemblySet P ↔ DAssembles P a := by
  simp [dAssemblySet]

/-! ## Part 2 — The depth shift -/

/-- Deepen every mill of a clause piece by `t`. -/
def shiftClause (t : ZMod d) (c : DClause n d) : DClause n d :=
  c.map fun l => (l.1, l.2 + t)

/-- Deepen every mill of a puzzle by `t`. -/
def shiftPuzzle (t : ZMod d) (P : DPuzzle n d) : DPuzzle n d :=
  P.map (shiftClause t)

/-- Deepen every variable piece by `t`. -/
def shiftAssign (t : ZMod d) (a : Fin n → ZMod d) : Fin n → ZMod d := fun i => a i + t

omit [NeZero d] in
@[simp] theorem shiftAssign_zero (a : Fin n → ZMod d) : shiftAssign 0 a = a := by
  funext i; simp [shiftAssign]

omit [NeZero d] in
@[simp] theorem shiftAssign_add (s t : ZMod d) (a : Fin n → ZMod d) :
    shiftAssign s (shiftAssign t a) = shiftAssign (t + s) a := by
  funext i; simp [shiftAssign, add_assoc]

omit [NeZero d] in
@[simp] theorem shiftPuzzle_add (s t : ZMod d) (P : DPuzzle n d) :
    shiftPuzzle s (shiftPuzzle t P) = shiftPuzzle (t + s) P := by
  simp only [shiftPuzzle, List.map_map]
  refine List.map_congr_left ?_
  intro c _
  simp only [Function.comp_apply, shiftClause, List.map_map]
  refine List.map_congr_left ?_
  intro l _
  simp [add_assoc]

omit [NeZero d] in
/-- **Exact transport under the depth shift.**  Shifting the puzzle and the
assembly by the same amount preserves assembly, and conversely. -/
theorem dAssembles_shift (t : ZMod d) (P : DPuzzle n d) (a : Fin n → ZMod d) :
    DAssembles (shiftPuzzle t P) (shiftAssign t a) ↔ DAssembles P a := by
  constructor
  · intro h c hc
    obtain ⟨l, hl, hfit⟩ := h (shiftClause t c) (List.mem_map_of_mem hc)
    simp only [shiftClause, List.mem_map] at hl
    obtain ⟨l', hl', rfl⟩ := hl
    exact ⟨l', hl', by simpa [shiftAssign] using hfit⟩
  · intro h c hc
    simp only [shiftPuzzle, List.mem_map] at hc
    obtain ⟨c', hc', rfl⟩ := hc
    obtain ⟨l, hl, hfit⟩ := h c' hc'
    exact ⟨(l.1, l.2 + t), List.mem_map_of_mem hl, by simp [shiftAssign, hfit]⟩

/-! ## Part 3 — Shift-stable sets are `d` copies of their gauge -/

/-- The depth gauge: assemblies whose variable `0` piece is milled to depth `0`.
It meets each shift orbit exactly once. -/
def depthGauge (hn : 0 < n) (s : Finset (Fin n → ZMod d)) : Finset (Fin n → ZMod d) :=
  s.filter fun a => a ⟨0, hn⟩ = 0

/-- **Orbit decomposition for the cyclic symmetry.**  A shift-stable set of
assemblies is the image of `gauge × ZMod d` under the shift action, so its
cardinality is exactly `d` times the number of shift orbits. -/
theorem stable_card_eq_mul_gauge (hn : 0 < n) (s : Finset (Fin n → ZMod d))
    (hs : ∀ (t : ZMod d), ∀ a ∈ s, shiftAssign t a ∈ s) :
    s.card = (depthGauge hn s).card * d := by
  classical
  have hbij : s = (depthGauge hn s ×ˢ (Finset.univ : Finset (ZMod d))).image
      fun p => shiftAssign p.2 p.1 := by
    ext a
    simp only [Finset.mem_image, Finset.mem_product, Finset.mem_univ, and_true,
      depthGauge, Finset.mem_filter]
    constructor
    · intro ha
      refine ⟨(shiftAssign (-a ⟨0, hn⟩) a, a ⟨0, hn⟩), ⟨⟨hs _ a ha, ?_⟩, ?_⟩⟩
      · simp [shiftAssign]
      · simp
    · rintro ⟨⟨g, t⟩, ⟨⟨hg, -⟩, rfl⟩⟩
      exact hs t g hg
  have hinj : Set.InjOn (fun p : (Fin n → ZMod d) × ZMod d => shiftAssign p.2 p.1)
      (↑(depthGauge hn s ×ˢ (Finset.univ : Finset (ZMod d))) : Set ((Fin n → ZMod d) × ZMod d)) := by
    rintro ⟨g, t⟩ hg ⟨g', t'⟩ hg' heq
    simp only [Finset.mem_coe, Finset.mem_product, depthGauge,
      Finset.mem_filter] at hg hg'
    have h0 : g ⟨0, hn⟩ = 0 := hg.1.2
    have h0' : g' ⟨0, hn⟩ = 0 := hg'.1.2
    have ht : t = t' := by
      have := congrFun heq ⟨0, hn⟩
      simpa [shiftAssign, h0, h0'] using this
    subst ht
    have : g = g' := by
      funext i
      have := congrFun heq i
      simpa [shiftAssign] using this
    simp [this]
  conv_lhs => rw [hbij]
  rw [Finset.card_image_of_injOn hinj, Finset.card_product, Finset.card_univ, ZMod.card]

/-! ## Part 4 — The combined assembly space of all `d` shifts -/

/-- The combined (untagged) assembly space of a `d`-ary puzzle: the assemblies of
all `d` of its depth shifts, viewed inside one cube. -/
def dCombined (P : DPuzzle n d) : Finset (Fin n → ZMod d) :=
  Finset.univ.biUnion fun t : ZMod d => dAssemblySet (shiftPuzzle t P)

theorem shift_mem_dCombined (P : DPuzzle n d) (t : ZMod d) {a : Fin n → ZMod d}
    (ha : a ∈ dCombined P) : shiftAssign t a ∈ dCombined P := by
  simp only [dCombined, Finset.mem_biUnion, Finset.mem_univ, true_and,
    mem_dAssemblySet] at ha ⊢
  obtain ⟨s, hs⟩ := ha
  exact ⟨s + t, by
    rw [← shiftPuzzle_add]
    exact (dAssembles_shift t (shiftPuzzle s P) a).2 hs⟩

/-- **Cyclic orbit theorem.**  For `n ≥ 1` the combined assembly space of the `d`
depth shifts is exactly `d` times its gauge. -/
theorem dCombined_card_eq (hn : 0 < n) (P : DPuzzle n d) :
    (dCombined P).card = (depthGauge hn (dCombined P)).card * d :=
  stable_card_eq_mul_gauge hn _ (fun t _ ha => shift_mem_dCombined P t ha)

/-- **Divisibility theorem.**  `d` divides the combined assembly count of a
`d`-ary framed puzzle on at least one variable.  This is the general form of the
tab--blank parity conjecture: the order of the mill symmetry, not self-duality,
is what constrains the solution count. -/
theorem combined_card_dvd (hn : 0 < n) (P : DPuzzle n d) : d ∣ (dCombined P).card :=
  ⟨(depthGauge hn (dCombined P)).card, by rw [dCombined_card_eq hn P]; ring⟩

/-- Specialisation to two interlock depths: the tab--blank parity theorem,
recovered inside the `d`-ary theory. -/
theorem combined_card_even_two (hn : 0 < n) (P : DPuzzle n 2) :
    Even (dCombined P).card := by
  obtain ⟨k, hk⟩ := combined_card_dvd hn P
  exact ⟨k, by omega⟩

/-! ## Part 5 — Sharpness at `n = 0` -/

/-- On zero variables the cube is a single point and every depth shift fixes it:
the empty puzzle has a one-element combined space for every `d`, so the
divisibility conclusion fails exactly as in the tab--blank case. -/
theorem zeroVar_combined_card_one : (dCombined ([] : DPuzzle 0 d)).card = 1 := by
  have hall : ∀ t : ZMod d, dAssemblySet (shiftPuzzle t ([] : DPuzzle 0 d)) = Finset.univ := by
    intro t
    ext a
    simp only [mem_dAssemblySet, Finset.mem_univ, iff_true]
    intro c hc
    simp [shiftPuzzle] at hc
  obtain ⟨t, -⟩ := (Finset.univ_nonempty : (Finset.univ : Finset (ZMod d)).Nonempty)
  have : dCombined ([] : DPuzzle 0 d) = Finset.univ := by
    refine Finset.Subset.antisymm (Finset.subset_univ _) ?_
    intro a _
    simp only [dCombined, Finset.mem_biUnion, Finset.mem_univ, true_and]
    exact ⟨t, by rw [hall t]; exact Finset.mem_univ a⟩
  rw [this]
  simp

/-! ## Part 6 — Numerical experiments -/

/-- A ternary puzzle on two variables: one clause piece milled for depth `1` at
variable `0`, one milled for depth `2` at variable `1`. -/
def Q : DPuzzle 2 3 := [[(0, 1)], [(1, 2)]]

#eval (dAssemblySet Q).card
#eval (dAssemblySet (shiftPuzzle 1 Q)).card
#eval (dCombined Q).card
#eval (depthGauge (n := 2) (d := 3) (by norm_num) (dCombined Q)).card

/-- The ternary example has one assembly per shift and a combined space of size
three: a single free shift orbit, as `dCombined_card_eq` predicts. -/
theorem Q_counts :
    (dAssemblySet Q).card = 1 ∧ (dCombined Q).card = 3 ∧
      (depthGauge (n := 2) (d := 3) (by norm_num) (dCombined Q)).card = 1 := by
  refine ⟨by decide, by decide, by decide⟩

/-!
-- !-- Lab Notes -- !--

**Hypothesis.**  Cycle four asked whether the tab--blank involution is special.
(M1) Does the parity theorem generalise to `d` interlock depths as divisibility
by `d`?  (M2) Is the gauge construction still a section of the orbit map when the
acting group is cyclic of order `d` rather than of order two?  (M3) Does the
`n = 0` degeneracy persist?  (M4) Does the `d = 2` instance reproduce the
tab--blank parity theorem?

**Experiment.**  The Boolean cube was replaced by `Fin n → ZMod d` and the
complement by the depth shift `a ↦ a + t`.  A ternary example `Q` on two
variables was evaluated: each of the three shifted puzzles has exactly one
assembly, the combined space has three elements, and the depth gauge has one —
a single free shift orbit.  All three numbers are closed by enumeration in
`Q_counts`.

**Analysis.**  M1 and M2 survive in the strong form
`stable_card_eq_mul_gauge`: *any* shift-stable set of assemblies is in explicit
bijection with `gauge × ZMod d`, so its cardinality is `d · (#orbits)`; the
bijection is `(g, t) ↦ g + t`, inverted by reading off the depth of variable `0`.
Divisibility (`combined_card_dvd`) is an immediate corollary, and M4 holds
(`combined_card_even_two`).  M3 survives: at `n = 0` the cube is a point fixed by
every shift (`zeroVar_combined_card_one`), so `0 < n` remains the exact boundary
for all `d`, confirming that the obstruction is dimensional rather than
self-duality.

**Critique.**  The `d`-ary model is stated for `ZMod d` with `NeZero d`; for
`d = 1` the statement is true but vacuous (everything is divisible by one), and
`d = 2` recovers the tab--blank case, though through the additive rather than the
Boolean encoding, so it is a parallel proof rather than a literal
generalisation of the Boolean file — the two are connected by the ring
isomorphism `Bool ≃ ZMod 2`, which is not formalised here.  The gauge again
depends on the choice of variable `0`.  Divisibility is by the order of the
*shift group*, not by the number of clause pieces or variables; no finer
arithmetic constraint is claimed.

**Synthesis.**  Complementation constrains solution counts because it is a free
action of a cyclic group on the assembly cube, and the constraint is exactly the
order of that group.  Tab--blank parity is the `d = 2` slice of a divisibility
law valid for every interlock alphabet with a transitive cyclic mill symmetry.
-/

end JigsawCyclicSymmetry