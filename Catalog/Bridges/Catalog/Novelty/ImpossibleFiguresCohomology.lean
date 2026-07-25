import Mathlib

/-!
# The Cohomology of Impossible Figures

*The Topology of Impossible Objects: Escher Stairs and Klein Bottles.*

This file formalizes the mathematics underlying **impossible figures** such as the
Penrose triangle and the Escher staircase.  The classical insight (R. Penrose,
*On the cohomology of impossible figures*, 1992) is that the "impossibility" of
such a picture is not a *local* defect: every small patch of the drawing is
perfectly consistent.  The impossibility is a *global*, cohomological
obstruction — a nonzero holonomy class in `H¹` of the cyclic cover formed by the
overlapping patches of the figure.

We model a figure as a cyclic arrangement of `n` overlapping patches indexed by
`ZMod n`.  On the overlap from patch `i` to patch `i+1` a local rule prescribes an
increment `t i` living in an abelian group `A`:

* `A = ℝ`   — a **depth / height** increment.  This models the Penrose triangle
  (three beams, each apparently receding) and the Escher staircase (each flight
  apparently ascending).
* `A = ZMod 2` — an **orientation** flip.  Total holonomy `1 ∈ ZMod 2` is a
  one-sided gluing: the Möbius band / Klein bottle phenomenon.

The central theorem `realizable_iff` says the figure can be globally realised
(there is an honest height/orientation field inducing the local increments)
**iff** its holonomy vanishes.  Everything else — the impossibility of the
Penrose triangle, the impossibility of a strictly ascending closed staircase, the
non-orientability of a one-sided band, and the fact that impossibility is a
complete `ℝ`-valued invariant — is a corollary.

## Main results

* `holonomy_of_realizable` / `realizable_of_holonomy` / `realizable_iff` —
  realizability is equivalent to vanishing holonomy.
* `holonomy_add_coboundary` — the holonomy class is well defined on `H¹`
  (invariant under changing the local height gauge by a coboundary).
* `penrose_triangle_impossible` — the Penrose triangle is not realizable.
* `escher_staircase_impossible` — a closed, everywhere-ascending staircase is
  impossible.
* `klein_bottle_nonorientable` — a loop with an odd number of orientation flips
  admits no global orientation.
* `holonomy_surjective` / `impossibility_is_complete_invariant` — the
  impossibility class ranges over all of `ℝ` and detects realizability exactly.
* `impossible_uniform` together with `realizable_nonuniform` — a contrarian pair
  showing impossibility is *global*, not local: uniform local data can be
  impossible while wildly non-uniform data can be perfectly realizable.
-/

open Finset

namespace ImpossibleFigures

variable {n : ℕ} [NeZero n] {A : Type*} [AddCommGroup A]

/-- Local increment data on a cyclic arrangement of `n` overlapping patches:
`t i` is the increment imposed on the overlap from patch `i` to patch `i+1`. -/
abbrev Step (n : ℕ) (A : Type*) := ZMod n → A

/-- The **holonomy** of a figure: the total increment accumulated once around the
cycle.  This is the Penrose cohomology class in `H¹ ≅ A`. -/
def holonomy (t : Step n A) : A := ∑ i, t i

/-- A figure is **realizable** if its local increments come from a genuine global
height/orientation field `h`, i.e. `t` is the coboundary of `h`. -/
def Realizable (t : Step n A) : Prop := ∃ h : ZMod n → A, ∀ i, h (i + 1) - h i = t i

/-
The holonomy of any coboundary vanishes: going once around a cycle returns to
the start. This is the discrete "fundamental theorem of calculus" on `ZMod n`.
-/
lemma holonomy_coboundary (h : ZMod n → A) :
    holonomy (fun i => h (i + 1) - h i) = 0 := by
  unfold holonomy; simp +decide [ sub_eq_zero ] ;
  exact Equiv.sum_comp ( Equiv.addRight 1 ) h

/-
**Forward direction.** A realizable figure has vanishing holonomy.
-/
lemma holonomy_of_realizable {t : Step n A} (ht : Realizable t) : holonomy t = 0 := by
  convert holonomy_coboundary ht.choose using 1;
  exact Finset.sum_congr rfl fun i _ => ht.choose_spec i ▸ rfl

/-
**Reverse direction.** A figure with vanishing holonomy is realizable; an
explicit height field is given by the partial sums of the increments.
-/
lemma realizable_of_holonomy {t : Step n A} (ht : holonomy t = 0) : Realizable t := by
  -- Define the height field $h$ by $h(i) = \sum_{j=0}^{i-1} t(j)$.
  use fun i => ∑ j ∈ Finset.range i.val, t (j : ZMod n);
  intro i
  by_cases h : i.val + 1 < n;
  · simp +decide [ show ( i + 1 : ZMod n ).val = i.val + 1 from by
                    rw [ ZMod.val_add ];
                    rcases n with ( _ | _ | n ) <;> simp_all +decide [ ZMod.val ], Finset.sum_range_succ ];
  · have h_sum : ∑ j ∈ Finset.range n, t (j : ZMod n) = 0 := by
      convert ht using 1;
      refine' Finset.sum_bij ( fun j _ => j ) _ _ _ _ <;> simp +decide;
      · exact fun a₁ ha₁ a₂ ha₂ h => Nat.mod_eq_of_lt ha₁ ▸ Nat.mod_eq_of_lt ha₂ ▸ by simpa [ ZMod.natCast_eq_natCast_iff' ] using h;
      · exact fun b => ⟨ b.val, ZMod.val_lt b, ZMod.natCast_zmod_val b ⟩;
    cases eq_or_lt_of_le ( Nat.succ_le_of_lt ( ZMod.val_lt i ) ) <;> simp_all +decide;
    simp_all +decide [ show i + 1 = 0 from by
                        rw [ ← ZMod.natCast_zmod_val i, show i.val = n - 1 from eq_tsub_of_add_eq ‹_› ] ; cases n <;> aesop ];
    rw [ neg_eq_iff_add_eq_zero, ← h_sum, ← Finset.sum_range_add_sum_Ico _ ( show i.val ≤ n from by linarith ) ];
    simp +decide [ ← ‹i.val + 1 = n› ]

/-- **Main theorem.** A figure is realizable iff its holonomy class vanishes. -/
theorem realizable_iff (t : Step n A) : Realizable t ↔ holonomy t = 0 :=
  ⟨holonomy_of_realizable, realizable_of_holonomy⟩

/-
The holonomy class is well defined on `H¹`: changing the local height gauge by
a coboundary `c(i+1) - c(i)` does not change the holonomy.
-/
lemma holonomy_add_coboundary (t : Step n A) (c : ZMod n → A) :
    holonomy (fun i => t i + (c (i + 1) - c i)) = holonomy t := by
  unfold holonomy; simp +decide [ Finset.sum_add_distrib ] ;
  erw [ sub_eq_zero, Equiv.sum_comp ( Equiv.addRight 1 ) ]

/-
Holonomy is additive.
-/
lemma holonomy_add (t s : Step n A) : holonomy (t + s) = holonomy t + holonomy s := by
  exact Finset.sum_add_distrib

section Real

/-
The holonomy class of a real figure is surjective onto `ℝ`: every real number
occurs as the impossibility class of some figure. Thus `H¹ ≅ ℝ`.
-/
lemma holonomy_surjective (r : ℝ) : ∃ t : Step n ℝ, holonomy t = r := by
  unfold holonomy;
  exact ⟨ fun i => if i = 0 then r else 0, by simp +decide ⟩

/-- **Impossibility is a complete invariant.** Two figures are simultaneously
realizable or simultaneously impossible according to whether their holonomy
classes agree with `0`; more precisely the holonomy class alone decides
realizability. -/
theorem impossibility_is_complete_invariant (t : Step n ℝ) :
    ¬ Realizable t ↔ holonomy t ≠ 0 :=
  not_congr (realizable_iff t)

/-
**The Penrose triangle is impossible.** Three beams, each apparently receding
by the same unit amount, accumulate a nonzero holonomy `3 ≠ 0`, so no global depth
assignment exists.
-/
theorem penrose_triangle_impossible : ¬ Realizable (n := 3) (fun _ => (1 : ℝ)) := by
  rintro ⟨ h, h' ⟩;
  linarith! [ h' 0, h' 1, h' 2 ]

/-
**The Escher staircase is impossible.** A closed flight of stairs in which
every step ascends (each increment is strictly positive) cannot close up: its
holonomy is a strictly positive sum, hence nonzero.
-/
theorem escher_staircase_impossible (t : Step n ℝ) (hpos : ∀ i, 0 < t i) :
    ¬ Realizable t := by
  exact fun h => ne_of_gt ( Finset.sum_pos ( fun i _ => hpos i ) ( Finset.univ_nonempty ) ) ( holonomy_of_realizable h )

/-- **Contrarian result 1.** Impossibility is *global*, not local: the Penrose
triangle has perfectly *uniform* local data (every overlap prescribes the same
increment) yet is impossible. -/
theorem impossible_uniform :
    (∀ i j : ZMod 3, (fun _ => (1 : ℝ)) i = (fun _ => (1 : ℝ)) j) ∧
      ¬ Realizable (n := 3) (fun _ => (1 : ℝ)) :=
  ⟨fun _ _ => rfl, penrose_triangle_impossible⟩

/-- The three distinct increments `1, 2, -3` on a triangle. -/
def nonuniform : Step 3 ℝ := fun i => if i = 0 then 1 else if i = 1 then 2 else -3

/-
**Contrarian result 2.** Impossibility is *global*, not local: this figure has
three *pairwise distinct* local increments (maximally non-uniform data) yet is
perfectly realizable, because its holonomy `1 + 2 + (-3) = 0` vanishes.  Together
with `impossible_uniform` this refutes any attempt to read impossibility off the
local data alone.
-/
theorem realizable_nonuniform :
    Realizable nonuniform ∧ nonuniform 0 ≠ nonuniform 1 ∧
      nonuniform 1 ≠ nonuniform 2 ∧ nonuniform 0 ≠ nonuniform 2 := by
  refine' ⟨ _, _ ⟩;
  · -- Apply the lemma that states if the holonomy is zero, then the figure is realizable.
    apply realizable_of_holonomy;
    unfold holonomy nonuniform ;
    erw [ Finset.sum_ite ] ; norm_cast;
  · grind +locals

end Real

section Orientation

/-
A one-sided (Möbius / Klein) gluing: the orientation increments are valued in
`ZMod 2`, and total holonomy `1` means an odd number of orientation-reversing
overlaps.

**Non-orientability (Möbius band / Klein bottle).** A closed band whose
orientation flips an odd number of times around the loop (total holonomy `1` in
`ZMod 2`) admits no global orientation field.
-/
theorem klein_bottle_nonorientable (s : Step n (ZMod 2)) (hodd : holonomy s = 1) :
    ¬ Realizable s := by
  exact fun h => by have := realizable_iff s; aesop;

/-
The simplest one-sided band: a single patch glued to itself with a flip. It is
non-orientable.
-/
theorem mobius_band_nonorientable : ¬ Realizable (n := 1) (fun _ => (1 : ZMod 2)) := by
  refine klein_bottle_nonorientable _ ?_
  simp [holonomy]

end Orientation

end ImpossibleFigures