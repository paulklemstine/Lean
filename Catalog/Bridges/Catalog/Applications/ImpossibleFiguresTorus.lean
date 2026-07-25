import Mathlib

/-!
# Impossible Figures IV: Two–Dimensional Figures and the Torus

*The Topology of Impossible Objects: Escher Stairs and Klein Bottles.*

The Penrose triangle and the Escher staircase are *one–dimensional* impossible
figures: their inconsistency lives on a single loop.  Escher's **Waterfall**, by
contrast, is genuinely *two–dimensional* — a planar lattice of water channels whose
apparent heights cannot be globally reconciled.  This file builds the discrete
two–dimensional theory needed to classify such figures, on a doubly periodic grid
`ZMod m × ZMod n` (a discrete **torus**).

A two–dimensional figure is a pair of increment fields `(a, b)`: `a p` is the
apparent height change moving one step in the horizontal direction from cell `p`,
`b p` the change moving one step vertically.  Two obstructions to global
realizability appear:

* a **local** one, the *curvature* `curv a b` — the net height change around each
  unit square.  A nonzero curvature is a *local* inconsistency (the four corners
  of a single tile cannot be assigned consistent heights);
* two **global** ones, the *periods* `periodX`, `periodY` — the net height change
  around the two fundamental loops of the torus.

## Main results

* `curv_gradient`, `periodX_gradient`, `periodY_gradient` — a realizable figure is
  **flat** (zero curvature) and has **vanishing periods**.  Hence these are
  genuine obstructions.
* `total_curvature_zero` — **discrete Stokes / Gauss–Bonnet on a closed surface**:
  the curvatures of *any* figure sum to zero over the whole torus.  A closed
  surface has no boundary, so curvature can never have constant sign — the analogue
  of "the total turning around a closed curve is `2π`".
* `realizable_flat`, `realizable_periodX`, `realizable_periodY` — the three
  necessary conditions for realizability, packaged as impossibility criteria.
* `waterfall_impossible` — **Escher's Waterfall is impossible**: a figure whose
  water uniformly descends around a horizontal loop has period `≠ 0` and cannot be
  globally realized.
* `curved_tile_impossible` — a single locally twisted tile (nonzero curvature at
  one square) is already impossible, independently of the global periods.
-/

open Finset

namespace ImpossibleFigures.Torus

variable {m n : ℕ} [NeZero m] [NeZero n] {A : Type*} [AddCommGroup A]

/-- A field on the discrete torus `ZMod m × ZMod n`. -/
abbrev Grid (m n : ℕ) (A : Type*) := ZMod m × ZMod n → A

/-- Horizontal discrete derivative of a height field. -/
def dx (h : Grid m n A) : Grid m n A := fun p => h (p.1 + 1, p.2) - h p

/-- Vertical discrete derivative of a height field. -/
def dy (h : Grid m n A) : Grid m n A := fun p => h (p.1, p.2 + 1) - h p

/-- The **curvature** (discrete exterior derivative) of a two–dimensional figure
`(a, b)`: the net height change accumulated once around the unit square based at
`p`.  A figure is *flat* if its curvature vanishes identically. -/
def curv (a b : Grid m n A) : Grid m n A :=
  fun p => a p + b (p.1 + 1, p.2) - a (p.1, p.2 + 1) - b p

/-- A two–dimensional figure is **realizable** (globally consistent, developable)
if its increment fields are the discrete derivatives of a single height field. -/
def Realizable (a b : Grid m n A) : Prop := ∃ h : Grid m n A, dx h = a ∧ dy h = b

/-- The **horizontal period**: net height change around the horizontal loop. -/
def periodX (a : Grid m n A) : A := ∑ i : ZMod m, a (i, 0)

/-- The **vertical period**: net height change around the vertical loop. -/
def periodY (b : Grid m n A) : A := ∑ j : ZMod n, b (0, j)

omit [NeZero m] [NeZero n] in
/-- **Exact figures are flat.** The curvature of a figure that comes from a height
field vanishes identically: the four corners of every tile telescope. -/
theorem curv_gradient (h : Grid m n A) : curv (dx h) (dy h) = 0 := by
  funext p
  simp only [curv, dx, dy, Pi.zero_apply]
  abel

omit [NeZero n] in
/-- **Exact figures have zero horizontal period.** -/
theorem periodX_gradient (h : Grid m n A) : periodX (dx h) = 0 := by
  simp only [periodX, dx]
  rw [Finset.sum_sub_distrib, sub_eq_zero]
  exact Equiv.sum_comp (Equiv.addRight 1) (fun i => h (i, 0))

omit [NeZero m] in
/-- **Exact figures have zero vertical period.** -/
theorem periodY_gradient (h : Grid m n A) : periodY (dy h) = 0 := by
  simp only [periodY, dy]
  rw [Finset.sum_sub_distrib, sub_eq_zero]
  exact Equiv.sum_comp (Equiv.addRight 1) (fun j => h (0, j))

/-
**Discrete Stokes / Gauss–Bonnet on a closed surface.** The curvatures of an
*arbitrary* two–dimensional figure sum to zero over the entire torus: a closed
surface has no boundary.  Consequently the curvature can never be everywhere
positive (or everywhere negative) — the discrete analogue of the fact that total
geodesic curvature around a closed loop is a topological constant.
-/
theorem total_curvature_zero (a b : Grid m n A) :
    ∑ p : ZMod m × ZMod n, curv a b p = 0 := by
  simp +decide only [curv];
  simp +decide only [sum_sub_distrib, sum_add_distrib];
  rw [ show ∑ x : ZMod m × ZMod n, b ( x.1 + 1, x.2 ) = ∑ x : ZMod m × ZMod n, b x from ?_, show ∑ x : ZMod m × ZMod n, a ( x.1, x.2 + 1 ) = ∑ x : ZMod m × ZMod n, a x from ?_ ];
  · abel1;
  · exact Equiv.sum_comp ( Equiv.prodCongr ( Equiv.refl _ ) ( Equiv.addRight 1 ) ) _;
  · exact Equiv.sum_comp ( Equiv.prodCongr ( Equiv.addRight 1 ) ( Equiv.refl _ ) ) _

omit [NeZero m] [NeZero n] in
/-- **Necessity of flatness.** A realizable figure is flat. -/
theorem realizable_flat {a b : Grid m n A} (h : Realizable a b) : curv a b = 0 := by
  obtain ⟨f, hx, hy⟩ := h
  rw [← hx, ← hy]; exact curv_gradient f

omit [NeZero n] in
/-- **Necessity of vanishing horizontal period.** -/
theorem realizable_periodX {a b : Grid m n A} (h : Realizable a b) : periodX a = 0 := by
  obtain ⟨f, hx, _⟩ := h
  rw [← hx]; exact periodX_gradient f

omit [NeZero m] in
/-- **Necessity of vanishing vertical period.** -/
theorem realizable_periodY {a b : Grid m n A} (h : Realizable a b) : periodY b = 0 := by
  obtain ⟨f, _, hy⟩ := h
  rw [← hy]; exact periodY_gradient f

section Examples

/-- **Escher's Waterfall.** The water descends by a uniform unit around a
horizontal loop of three channels: `a ≡ 1` horizontally, `b ≡ 0` vertically. -/
def waterfall : Grid 3 3 ℝ × Grid 3 3 ℝ := (fun _ => 1, fun _ => 0)

/-- The horizontal period of the Waterfall is `3`. -/
lemma waterfall_periodX : periodX waterfall.1 = 3 := by
  simp [periodX, waterfall, ZMod.card]

/-- **Escher's Waterfall is impossible.** Its water uniformly descends around a
closed horizontal loop, giving a nonzero horizontal period, so no globally
consistent height field exists — it cannot be built as a real object. -/
theorem waterfall_impossible : ¬ Realizable waterfall.1 waterfall.2 := by
  intro h
  have := realizable_periodX h
  rw [waterfall_periodX] at this
  norm_num at this

/-- A single **twisted tile**: curvature `1` at the origin square, `0` elsewhere,
with no vertical increments.  Concretely the horizontal increments carry a unit on
the top edge `(0,1)` of the base tile. -/
def twistedTile : Grid 2 2 ℝ × Grid 2 2 ℝ :=
  (fun p => if p = (0, 1) then -1 else 0, fun _ => 0)

/-- The twisted tile has nonzero curvature at the origin. -/
lemma twistedTile_curv_origin : curv twistedTile.1 twistedTile.2 (0, 0) = 1 := by
  simp [curv, twistedTile]

/-- **A locally twisted tile is impossible.** Even one unit square whose four
corners cannot be consistently assigned heights (nonzero curvature) already
obstructs realizability — a purely *local* impossibility, unlike the Penrose
triangle whose impossibility is global. -/
theorem curved_tile_impossible : ¬ Realizable twistedTile.1 twistedTile.2 := by
  intro h
  have hflat := realizable_flat h
  have := congrFun hflat (0, 0)
  rw [twistedTile_curv_origin] at this
  norm_num at this

end Examples

/-
**One–dimensional primitive (Poincaré lemma on a cycle).** If a field on
`ZMod N` has vanishing total, its partial sums form a primitive: the coboundary of
the partial-sum function recovers the field.
-/
lemma partial_sum_coboundary {N : ℕ} [NeZero N] (t : ZMod N → A)
    (h0 : ∑ i : ZMod N, t i = 0) (k : ZMod N) :
    (∑ j ∈ Finset.range (k + 1).val, t (j : ZMod N))
      - (∑ j ∈ Finset.range k.val, t (j : ZMod N)) = t k := by
  have h_sum : ∀ k : Fin N, ∑ j ∈ Finset.range (k.val + 1), t j = ∑ j ∈ Finset.range k.val, t j + t k := by
    simp +decide [ Finset.sum_range_succ ];
  convert sub_eq_iff_eq_add'.mpr ( h_sum ⟨ k.val, k.val_lt ⟩ ) using 1;
  · cases N <;> simp_all +decide [ ZMod.val_add ];
    cases k using Fin.lastCases <;> simp_all +decide [ ZMod.val ];
    · simp_all +decide [ Finset.sum_range, ZMod, Fin.sum_univ_castSucc ];
    · rw [ Nat.mod_eq_of_lt ( Nat.succ_lt_succ ( Fin.is_lt _ ) ) ];
  · cases N <;> aesop

/-
**Telescoping without wrap.** Along the initial segment `0, …, k` (no
wrap-around) the coboundary of any field telescopes.
-/
lemma range_telescope {N : ℕ} [NeZero N] (f : ZMod N → A) (k : ZMod N) :
    (∑ j ∈ Finset.range k.val, (f ((j : ZMod N) + 1) - f (j : ZMod N)))
      = f k - f 0 := by
  convert Finset.sum_range_sub _ _ ; aesop;
  · cases N <;> aesop;
  · norm_num

/-
**Every column has vanishing vertical total.** Flatness forces the vertical
period to be the same in every column; since it vanishes in column `0` (the
hypothesis `periodY b = 0`), it vanishes everywhere.
-/
lemma col_period_zero {a b : Grid m n A}
    (hflat : curv a b = 0) (hy : periodY b = 0) (i : ZMod m) :
    ∑ j : ZMod n, b (i, j) = 0 := by
  -- By flatness, we have Q(i+1) - Q(i) = 0 for all i.
  have hQ_diff : ∀ i : ZMod m, (∑ j : ZMod n, b (i + 1, j)) - (∑ j : ZMod n, b (i, j)) = 0 := by
    intro i
    have hQ_diff_step : ∀ j : ZMod n, b (i + 1, j) - b (i, j) = a (i, j + 1) - a (i, j) := by
      intro j; have := congr_fun hflat ( i, j ) ; simp_all +decide [ curv ] ;
      exact eq_of_sub_eq_zero ( by rw [ ← this ] ; abel1 );
    rw [ ← Finset.sum_sub_distrib, Finset.sum_congr rfl fun j _ => hQ_diff_step j ];
    rw [ Finset.sum_sub_distrib, sub_eq_zero ];
    exact Equiv.sum_comp ( Equiv.addRight 1 ) fun x => a ( i, x );
  -- By induction on $i$, we can show that $Q(i) = Q(0)$ for all $i$.
  have hQ_ind : ∀ i : ℕ, (∑ j : ZMod n, b (i, j)) = (∑ j : ZMod n, b (0, j)) := by
    intro i; induction i <;> simp_all +decide [ sub_eq_zero ] ;
  convert hQ_ind ( i.val : ℕ );
  · cases m <;> aesop;
  · exact hy.symm

/-
**Sufficiency (discrete Poincaré lemma on the torus).** A figure that is flat
and has both periods vanishing is realizable: it can be integrated to a global
height field.  Together with the necessity results this classifies realizable
two–dimensional figures — the discrete `H¹(T²) ≅ A²` together with the flatness
(closedness) condition.
-/
theorem realizable_of_flat_periods {a b : Grid m n A}
    (hflat : curv a b = 0) (hx : periodX a = 0) (hy : periodY b = 0) :
    Realizable a b := by
  refine' ⟨ _, _, _ ⟩;
  exact fun p => ∑ i ∈ Finset.range p.1.val, a ( i, 0 ) + ∑ j ∈ Finset.range p.2.val, b ( p.1, j );
  · ext ⟨ i, j ⟩ ; simp +decide [ dx ] ;
    have h_telescope : ∑ x ∈ Finset.range j.val, (b (i + 1, x) - b (i, x)) = a (i, j) - a (i, 0) := by
      have h_telescope : ∀ x : ZMod n, b (i + 1, x) - b (i, x) = a (i, x + 1) - a (i, x) := by
        intro x; have := congr_fun hflat ( i, x ) ; simp_all +decide [ curv ] ;
        exact eq_of_sub_eq_zero ( by rw [ ← this ] ; abel1 );
      convert range_telescope ( fun x : ZMod n => a ( i, x ) ) j using 1;
      exact Finset.sum_congr rfl fun _ _ => h_telescope _;
    have := partial_sum_coboundary ( fun i : ZMod m => a ( i, 0 ) ) hx i; simp_all +decide [ add_sub_add_comm ] ;
  · ext ⟨i, j⟩; simp [dy];
    convert partial_sum_coboundary ( fun k => b ( i, k ) ) ( col_period_zero hflat hy i ) j using 1

/-- **Classification of two–dimensional figures.** A figure on the discrete torus
is realizable **iff** it is flat and both of its periods vanish.  This is the
two–dimensional analogue of the one–dimensional "realizable iff zero holonomy":
the local curvature and the two global periods are a complete set of obstructions,
computing `H¹(T²) ≅ A²`. -/
theorem realizable_iff (a b : Grid m n A) :
    Realizable a b ↔ curv a b = 0 ∧ periodX a = 0 ∧ periodY b = 0 :=
  ⟨fun h => ⟨realizable_flat h, realizable_periodX h, realizable_periodY h⟩,
    fun ⟨hf, hx, hy⟩ => realizable_of_flat_periods hf hx hy⟩

-- !-- Lab Notes -- !--
/-
**Hypothesis.** One–dimensional impossible figures are classified by a single
holonomy class. Two–dimensional figures (Escher's Waterfall) should require *two*
kinds of obstruction: a local curvature (per tile) and two global periods (one per
fundamental loop of the torus). The realizable figures should be exactly the flat,
period–free ones — the discrete `H¹(T²) ≅ A²`.

**Experiment.** We defined the discrete derivatives `dx, dy`, the curvature `curv`,
and the two periods. We proved every exact figure is flat with zero periods
(`curv_gradient`, `periodX_gradient`, `periodY_gradient`), giving three necessary
conditions. We proved a discrete Stokes theorem (`total_curvature_zero`): the
curvature of any figure sums to zero over the closed torus. We instantiated the
Waterfall (nonzero horizontal period) and a twisted tile (nonzero curvature) as
concrete impossible figures.

**Analysis.** The two obstruction types are genuinely different: the twisted tile
is impossible *locally* (one bad square), whereas the Waterfall is impossible only
*globally* (every tile is locally fine, but the loop period is nonzero). Discrete
Stokes explains why the curvature obstruction is subtle: it cannot be constant in
sign, so a globally "always ascending in circulation" tiling is impossible for
purely topological reasons.

**Critique.** Each necessity theorem uses real structure (telescoping sums,
reindexing by the shift equivalence, `abel`). The examples are verified by explicit
computation of periods/curvature, not by fiat, and each impossibility is derived
from a genuine nonzero invariant. The sufficiency direction (integrating a flat,
period–free figure) is the two–dimensional Poincaré lemma; it is the load–bearing
converse and is proved directly.

**Synthesis.** Two–dimensional impossible figures are classified by a local
curvature and two global periods; realizable figures are the flat, period–free
ones, and discrete Stokes constrains the curvature globally.
-/

end ImpossibleFigures.Torus