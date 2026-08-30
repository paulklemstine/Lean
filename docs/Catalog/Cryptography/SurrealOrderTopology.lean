import Mathlib

/-!
# The order topology on the surreal numbers, and Conway cuts

This module builds the infrastructure needed to study the *local character* of the
order topology on `Surreal`:

* `Surreal.cut` — the Conway cut `{ l | r }` of an arbitrary (possibly infinite,
  arbitrarily indexed) family of surreals `l` lying strictly below a family `r`,
  packaged as a genuine element of `Surreal` together with the two defining
  inequalities `l i < cut < r j`.
* `Surreal.instDenselyOrdered` — the surreals are densely ordered (an immediate
  application of `cut` with singleton index types).
* the order topology on `Surreal`, together with the fact that it turns `Surreal`
  into a topological additive group, so that translations are homeomorphisms.
* `Surreal.exists_pos_lt_seq` — **countable coinitiality failure**: for every
  sequence of positive surreals there is a positive surreal strictly below all of
  them.  This is the combinatorial engine behind the failure of first countability.

Everything is built on the Mathlib `SetTheory.PGame` / `Surreal` API; no axioms
beyond Mathlib's are introduced.
-/

open SetTheory PGame Filter Set Topology

namespace Surreal

/-! ## Conway cuts of arbitrary families -/

/-- The pre-game `{ l | r }` built from arbitrary families of surreal numbers, using
canonical numeric representatives of the surreals involved. -/
noncomputable def cutGame {L R : Type u} (l : L → Surreal.{u}) (r : R → Surreal.{u}) :
    PGame.{u} :=
  PGame.mk L R (fun i => ((l i).out : PGame.{u})) (fun j => ((r j).out : PGame.{u}))

@[simp]
theorem cutGame_moveLeft {L R : Type u} (l : L → Surreal.{u}) (r : R → Surreal.{u}) (i : L) :
    (cutGame l r).moveLeft i = ((l i).out : PGame.{u}) := rfl

@[simp]
theorem cutGame_moveRight {L R : Type u} (l : L → Surreal.{u}) (r : R → Surreal.{u}) (j : R) :
    (cutGame l r).moveRight j = ((r j).out : PGame.{u}) := rfl

/-- Any surreal is the class of its canonical numeric representative. -/
theorem mk_out (x : Surreal.{u}) : Surreal.mk (x.out : PGame.{u}) x.out.2 = x :=
  Quotient.out_eq x

/-- A Conway cut of families with `l i < r j` for all `i, j` is numeric. -/
theorem cutGame_numeric {L R : Type u} {l : L → Surreal.{u}} {r : R → Surreal.{u}}
    (h : ∀ i j, l i < r j) : (cutGame l r).Numeric := by
  refine Numeric.mk (fun i j => ?_) (fun i => (l i).out.2) (fun j => (r j).out.2)
  show ((l i).out : PGame.{u}) < ((r j).out : PGame.{u})
  have hij := h i j
  rw [← mk_out (l i), ← mk_out (r j)] at hij
  exact hij

/-- The surreal number `{ l | r }` determined by two families of surreals with every
member of `l` strictly below every member of `r`. -/
noncomputable def cut {L R : Type u} (l : L → Surreal.{u}) (r : R → Surreal.{u})
    (h : ∀ i j, l i < r j) : Surreal.{u} :=
  Surreal.mk (cutGame l r) (cutGame_numeric h)

theorem lt_cut {L R : Type u} {l : L → Surreal.{u}} {r : R → Surreal.{u}}
    (h : ∀ i j, l i < r j) (i : L) : l i < cut l r h := by
  have := Surreal.mk_moveLeft_lt_mk (cutGame_numeric h) i
  rwa [show Surreal.mk ((cutGame l r).moveLeft i) _ = l i from mk_out (l i)] at this

theorem cut_lt {L R : Type u} {l : L → Surreal.{u}} {r : R → Surreal.{u}}
    (h : ∀ i j, l i < r j) (j : R) : cut l r h < r j := by
  have := Surreal.mk_lt_mk_moveRight (cutGame_numeric h) j
  rwa [show Surreal.mk ((cutGame l r).moveRight j) _ = r j from mk_out (r j)] at this

/-! ## Density -/

/-- The surreals are densely ordered: `{x | y}` sits strictly between `x < y`. -/
instance instDenselyOrdered : DenselyOrdered Surreal.{u} := by
  constructor
  intro x y hxy
  refine ⟨cut (fun _ : PUnit.{u+1} => x) (fun _ : PUnit.{u+1} => y) (fun _ _ => hxy), ?_, ?_⟩
  · exact lt_cut (fun _ _ => hxy) PUnit.unit
  · exact cut_lt (fun _ _ => hxy) PUnit.unit

/-! ## Coinitiality failure at zero -/

/-- **No small family of positive surreals is coinitial in the positive surreals.**
For *any* index type `ι : Type u` and family `r : ι → Surreal.{u}` of positive surreals,
the Conway cut `{0 | r}` is a positive surreal strictly below every `r i`.  Note that the
index type may be of arbitrarily large cardinality inside `Type u`; only the fact that it
is a *set* rather than a proper class is used. -/
theorem exists_pos_lt_family {ι : Type u} (r : ι → Surreal.{u}) (hr : ∀ i, 0 < r i) :
    ∃ y : Surreal.{u}, 0 < y ∧ ∀ i, y < r i := by
  have h : ∀ (_ : PUnit.{u+1}) (j : ι), (fun _ : PUnit.{u+1} => (0 : Surreal.{u})) PUnit.unit
      < r j := fun _ j => hr j
  exact ⟨cut _ _ h, lt_cut h PUnit.unit, fun i => cut_lt h i⟩

/-- **No sequence of positive surreals is coinitial in the positive surreals.** -/
theorem exists_pos_lt_seq (r : ℕ → Surreal.{u}) (hr : ∀ n, 0 < r n) :
    ∃ y : Surreal.{u}, 0 < y ∧ ∀ n, y < r n := by
  obtain ⟨y, hy0, hy⟩ := exists_pos_lt_family (fun j : ULift.{u} ℕ => r j.down)
    (fun j => hr j.down)
  exact ⟨y, hy0, fun n => hy (ULift.up n)⟩

/-- Reformulation of `exists_pos_lt_seq`: the family of positive surreals has
uncountable coinitiality — no countable set of positive surreals is coinitial. -/
theorem not_coinitial_of_countable (S : Set Surreal.{u}) (hcount : S.Countable)
    (hpos : ∀ x ∈ S, 0 < x) :
    ∃ y : Surreal.{u}, 0 < y ∧ ∀ x ∈ S, y < x := by
  rcases eq_empty_or_nonempty S with rfl | hne
  · exact ⟨1, zero_lt_one, by simp⟩
  · obtain ⟨r, rfl⟩ := hcount.exists_eq_range hne
    obtain ⟨y, hy0, hy⟩ := exists_pos_lt_seq r (fun n => hpos _ (mem_range_self n))
    exact ⟨y, hy0, by rintro x ⟨n, rfl⟩; exact hy n⟩

/-! ## The order topology and continuity of addition -/

/-- The order topology on the surreal numbers. -/
noncomputable instance instTopologicalSpace : TopologicalSpace Surreal.{u} :=
  Preorder.topology _

instance instOrderTopology : OrderTopology Surreal.{u} := ⟨rfl⟩

instance instNoMaxOrder : NoMaxOrder Surreal.{u} :=
  ⟨fun a => ⟨a + 1, by simp⟩⟩

instance instNoMinOrder : NoMinOrder Surreal.{u} :=
  ⟨fun a => ⟨a - 1, by simp⟩⟩

/-- **Addition of surreals is jointly continuous** for the order topology.  This uses
density of the order: given `a + b < u` one splits the gap asymmetrically as
`(a + e) + (b + (u - a - b - e))` for some `0 < e < u - a - b`. -/
instance instContinuousAdd : ContinuousAdd Surreal.{u} := inferInstance

/-- The surreals form a topological additive group in the order topology; in particular
every translation is a homeomorphism. -/
instance instIsTopologicalAddGroup : IsTopologicalAddGroup Surreal.{u} := inferInstance

/-- Translation by `c`, as an order isomorphism of the surreals. -/
def addRightIso (c : Surreal.{u}) : Surreal.{u} ≃o Surreal.{u} := OrderIso.addRight c

@[simp] theorem addRightIso_apply (c x : Surreal.{u}) : addRightIso c x = x + c := rfl

/-- Translation by `c`, as a homeomorphism for the order topology. -/
noncomputable def addRightHomeomorph (c : Surreal.{u}) : Surreal.{u} ≃ₜ Surreal.{u} :=
  (addRightIso c).toHomeomorph

@[simp] theorem addRightHomeomorph_apply (c x : Surreal.{u}) :
    addRightHomeomorph c x = x + c := rfl

/-- Translation transports the neighbourhood filter of `x` to that of `x + c`. -/
theorem map_add_nhds (x c : Surreal.{u}) :
    Filter.map (· + c) (𝓝 x) = 𝓝 (x + c) := by
  simp

/-- Every neighbourhood filter is a translate of the neighbourhood filter of `0`. -/
theorem nhds_eq_map_nhds_zero (c : Surreal.{u}) :
    𝓝 c = Filter.map (· + c) (𝓝 (0 : Surreal.{u})) := by
  rw [map_add_nhds, zero_add]

end Surreal