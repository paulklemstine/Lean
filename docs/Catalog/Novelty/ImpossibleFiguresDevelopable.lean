import Mathlib

/-!
# Impossible Figures II: The Multiplicative Model and Developable Surfaces

*The Topology of Impossible Objects: Escher Stairs and Klein Bottles.*

This companion file develops the **multiplicative** formulation of impossible
figures — the one Penrose used in his original 1992 note.  Instead of additive
depth increments we record, on each overlap of a cyclic figure, a *scaling
ambiguity* `t i` living in a commutative group `G` (Penrose used the positive
reals `ℝ_{>0}` under multiplication, modelling the freedom to rescale the
apparent depth of each visual patch).

A figure can be assembled into an honest, globally consistent object — in
particular built as a genuine **developable (flat) surface** in space — exactly
when the local scalings can be trivialised by a global gauge `h`, i.e. when the
figure is `MRealizable`.  The main theorem `developable_iff_trivial_monodromy`
says this happens **iff** the *total monodromy* `∏ i, t i` is the identity.  Thus
the impossibility of a figure is a single group element, the monodromy, and it is
a complete invariant.

## Main results

* `mrealizable_iff` / `developable_iff_trivial_monodromy` — a figure is
  realizable (developable) iff its monodromy is trivial.
* `monodromyHom` — monodromy packaged as a group homomorphism from the group of
  figures to `G`, with `monodromy_surjective` showing it is onto.
* `realizable_iff_mem_ker` — the realizable/developable figures are exactly the
  kernel of the monodromy homomorphism.
* `penrose_scaling_triangle_not_developable` — a triangle whose every beam is
  scaled by the same nontrivial factor is not developable.
* `developable_with_nontrivial_scalings` — **contrarian disproof**: the naive
  conjecture "if every overlap genuinely rescales (each `t i ≠ 1`) then the
  figure is impossible" is FALSE; here every scaling is nontrivial yet the figure
  is developable because the scalings cancel around the loop.
-/

open Finset

namespace ImpossibleFigures.Developable

variable {n : ℕ} [NeZero n] {G : Type*} [CommGroup G]

/-- Multiplicative local data: `t i ∈ G` is the scaling ambiguity across the
overlap from patch `i` to patch `i+1` of a cyclic figure. -/
abbrev MScale (n : ℕ) (G : Type*) := ZMod n → G

/-- The **total monodromy** of a figure: the product of all scaling ambiguities
accumulated once around the cycle. This is the multiplicative Penrose class. -/
def monodromy (t : MScale n G) : G := ∏ i, t i

/-- A figure is **realizable** (equivalently, buildable as a developable surface)
if the local scalings are the coboundary of a global gauge `h`. -/
def MRealizable (t : MScale n G) : Prop :=
  ∃ h : ZMod n → G, ∀ i, h (i + 1) * (h i)⁻¹ = t i

/-
Monodromy of a coboundary is trivial: the gauge factors cancel telescopically
around the cycle.
-/
lemma monodromy_coboundary (h : ZMod n → G) :
    monodromy (fun i => h (i + 1) * (h i)⁻¹) = 1 := by
  -- Apply the fact that `i ↦ i + 1` is a bijection of `ZMod n` to simplify the product.
  have h_bij : ∏ i : ZMod n, h (i + 1) = ∏ i : ZMod n, h i := by
    exact Equiv.prod_comp ( Equiv.addRight 1 ) h;
  simp +decide [ monodromy, Finset.prod_mul_distrib, h_bij ]

/-
**Forward direction.** A realizable figure has trivial monodromy.
-/
lemma monodromy_of_mrealizable {t : MScale n G} (ht : MRealizable t) :
    monodromy t = 1 := by
  obtain ⟨ h, hh ⟩ := ht;
  convert monodromy_coboundary h;
  rw [ hh ]

/-
**Reverse direction.** A figure with trivial monodromy is realizable; the
gauge is given by the partial products of the scalings.
-/
lemma mrealizable_of_monodromy {t : MScale n G} (ht : monodromy t = 1) :
    MRealizable t := by
  refine' ⟨ fun i => ∏ j ∈ Finset.range i.val, t j, fun i => _ ⟩;
  by_cases hi : i.val + 1 < n;
  · simp +decide;
    rw [ show ( i + 1 : ZMod n ).val = i.val + 1 from ?_, Finset.prod_range_succ ];
    · simp +decide [ mul_comm ];
    · rcases n with ( _ | _ | n ) <;> simp_all +decide [ ZMod.val_add ];
      simp +decide [ ZMod.val ];
      exact_mod_cast hi;
  · -- Since $i$ is the top element, we have $i + 1 = 0$ (since ↑(i.val)+1 = ↑n = 0), so $h(i+1) = h 0 = ∏ over range 0 = 1$.
    have h_top : i.val = n - 1 := by
      exact eq_tsub_of_add_eq ( by linarith [ i.val_lt ] )
    have h_top_succ : (i + 1).val = 0 := by
      rcases n with ( _ | _ | n ) <;> simp_all +decide [ ZMod.val_add ];
      · exact NeZero.ne 0 rfl;
      · simp +decide [ ZMod.val ]
    have h_top_prod : ∏ j ∈ Finset.range i.val, t j = (t i)⁻¹ := by
      have h_top_prod : ∏ j ∈ Finset.range n, t j = 1 := by
        convert ht using 1;
        refine' Finset.prod_bij ( fun j _ => j ) _ _ _ _ <;> simp +decide;
        · exact fun a₁ ha₁ a₂ ha₂ h => Nat.mod_eq_of_lt ha₁ ▸ Nat.mod_eq_of_lt ha₂ ▸ by simpa [ ZMod.natCast_eq_natCast_iff' ] using h;
        · exact fun b => ⟨ b.val, b.val_lt, by simp +decide ⟩;
      rcases n <;> simp_all +decide [ Finset.prod_range_succ ];
      rw [ eq_inv_of_mul_eq_one_left h_top_prod ];
      rw [ ← ZMod.natCast_zmod_val i, h_top ]
    simp_all +decide

/-- **Main theorem.** A figure is realizable iff its total monodromy is trivial. -/
theorem mrealizable_iff (t : MScale n G) : MRealizable t ↔ monodromy t = 1 :=
  ⟨monodromy_of_mrealizable, mrealizable_of_monodromy⟩

/-- **Classification of developable impossible figures.** A cyclic figure of
scaling data can be realised as a genuine developable (flat) surface exactly when
its total monodromy is trivial. (Same statement as `mrealizable_iff`, phrased in
the geometric language of the classification problem.) -/
theorem developable_iff_trivial_monodromy (t : MScale n G) :
    MRealizable t ↔ monodromy t = 1 := mrealizable_iff t

/-
Monodromy is multiplicative in the figure.
-/
lemma monodromy_mul (t s : MScale n G) :
    monodromy (t * s) = monodromy t * monodromy s := by
  exact Finset.prod_mul_distrib

/-
Monodromy of the trivial figure is trivial.
-/
lemma monodromy_one : monodromy (1 : MScale n G) = 1 := by
  exact Finset.prod_const_one

/-- Monodromy packaged as a group homomorphism from the group of figures (under
pointwise multiplication) to `G`. -/
def monodromyHom : MScale n G →* G where
  toFun := monodromy
  map_one' := monodromy_one
  map_mul' := monodromy_mul

/-- The realizable (developable) figures are exactly the kernel of the monodromy
homomorphism. Hence `H¹ ≅ G` and the monodromy is a complete invariant of
impossibility. -/
theorem realizable_iff_mem_ker (t : MScale n G) :
    MRealizable t ↔ t ∈ (monodromyHom (n := n) (G := G)).ker := by
  rw [MonoidHom.mem_ker]
  exact mrealizable_iff t

/-
The monodromy homomorphism is surjective: every group element occurs as the
impossibility class of some figure.
-/
lemma monodromy_surjective (g : G) : ∃ t : MScale n G, monodromy t = g := by
  refine' ⟨ fun i => if i = 0 then g else 1, _ ⟩ ; simp +decide [ monodromy ]

section Examples

/-- A triangle (three overlaps) each of which scales apparent depth by the same
factor `g`. -/
def scalingTriangle (g : G) : MScale 3 G := fun _ => g

/-
**The Penrose scaling triangle is not developable.** If every beam rescales by
the same nontrivial factor `g` (so `g^3 ≠ 1`), the figure has nontrivial monodromy
`g^3` and cannot be built as a flat surface.
-/
theorem penrose_scaling_triangle_not_developable (g : G) (hg : g ^ 3 ≠ 1) :
    ¬ MRealizable (scalingTriangle g) := by
  contrapose! hg with h;
  convert monodromy_of_mrealizable h;
  simp +decide [ monodromy, scalingTriangle ]

/-- A two-overlap figure that scales by `g` and then by `g⁻¹`. -/
def cancellingPair (g : G) : MScale 2 G := fun i => if i = 0 then g else g⁻¹

/-
**Contrarian disproof.** The plausible conjecture *"if every overlap genuinely
rescales the figure (each local factor `≠ 1`) then the figure is impossible"* is
FALSE.  Here, for any nontrivial `g`, both scalings are nontrivial (`g ≠ 1` and
`g⁻¹ ≠ 1`), yet the figure is perfectly developable because the two scalings
cancel around the loop (monodromy `g · g⁻¹ = 1`).  Impossibility is global.
-/
theorem developable_with_nontrivial_scalings (g : G) (hg : g ≠ 1) :
    MRealizable (cancellingPair g) ∧
      cancellingPair g 0 ≠ 1 ∧ cancellingPair g 1 ≠ 1 := by
  refine' ⟨ _, _, _ ⟩;
  · refine' mrealizable_of_monodromy _;
    convert Finset.prod_range_succ ( fun i => if i = 0 then g else g⁻¹ ) 1 using 1 ; simp +decide;
  · unfold cancellingPair; aesop;
  · unfold cancellingPair; aesop;

end Examples

end ImpossibleFigures.Developable