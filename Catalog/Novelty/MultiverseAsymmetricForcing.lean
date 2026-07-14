/-
# Asymmetric Forcing — Separating `S4.2` from `S5`

This file **deepens** `MultiverseModalForcing.lean`.  There the concrete forcing
frame was built from single-atom *flips*, which are their own inverse; the
resulting accessibility relation is an equivalence relation, so it validates the
full `S5`.  Real forcing, however, is *asymmetric*: one can pass to a generic
extension but cannot in general force *back* to the ground model.  The modal
logic of forcing is therefore exactly `S4.2`, **not** `S5`.

Here we realise that asymmetry.  Worlds are truth assignments and the
accessibility relation is the pointwise *domination* order

  `dom w v  :=  ∀ a, w a = true → v a = true`

("`v` decides at least as many atoms positively as `w`"): an extension may turn
atoms on but never off.  This relation is

* **reflexive** and **transitive** (`dom_refl`, `dom_trans`) — so it validates
  `T` and `4`;
* **confluent** (`dom_confluent`), the common upper bound being the pointwise
  `or` (join) — so it validates the characteristic forcing axiom `.2`
  (`asym_dot2`);
* but **not symmetric / not Euclidean**, and crucially it **refutes axiom `5`**
  (`asym_refutes_five`): from the bottom world `◇P` can hold while `□◇P` fails.

Thus the asymmetric forcing frame validates `S4.2` yet falsifies `S5`, giving a
clean semantic separation of the two logics — the phenomenon that makes the
modal logic of forcing genuinely `S4.2`.

Everything is proved over `Mathlib` and the file is self-contained.
-/
import Mathlib

namespace MultiverseAsymmetricForcing

open Relation

/-! ## Abstract Kripke layer (self-contained) -/

section Kripke

variable {W : Type*}

/-- Necessity: `Box R P w` holds when `P` holds in every `R`-successor of `w`. -/
def Box (R : W → W → Prop) (P : W → Prop) (w : W) : Prop := ∀ v, R w v → P v

/-- Possibility: `Dia R P w` holds when `P` holds in some `R`-successor of `w`. -/
def Dia (R : W → W → Prop) (P : W → Prop) (w : W) : Prop := ∃ v, R w v ∧ P v

variable {R : W → W → Prop} {P Q : W → Prop} {w : W}

/-- Monotonicity of `□`. -/
theorem box_mono (h : ∀ v, P v → Q v) (hp : Box R P w) : Box R Q w :=
  fun v hv => h v (hp v hv)

/-- **Axiom K**: `□(p → q) → □p → □q`. -/
theorem box_K (hpq : Box R (fun v => P v → Q v) w) (hp : Box R P w) : Box R Q w :=
  fun v hv => hpq v hv (hp v hv)

/-- **Axiom T** (reflexive frames): `□p → p`. -/
theorem box_T (hr : Reflexive R) (hp : Box R P w) : P w := hp w (hr w)

/-- **Axiom 4** (transitive frames): `□p → □□p`. -/
theorem box_four (ht : Transitive R) (hp : Box R P w) : Box R (Box R P) w :=
  fun _v hwv u hvu => hp u (ht hwv hvu)

/-- A relation is **confluent** (directed) when any two successors of a point have
    a common successor. -/
def Confluent (R : W → W → Prop) : Prop :=
  ∀ x y z, R x y → R x z → ∃ u, R y u ∧ R z u

/-- A relation is **Euclidean** when successors of a point are related. -/
def EuclideanRel (R : W → W → Prop) : Prop :=
  ∀ x y z, R x y → R x z → R y z

/-- **Axiom .2** (confluent frames): `◇□p → □◇p`, the characteristic axiom of the
    logic of forcing (`S4.2`). -/
theorem box_dot2 (hc : Confluent R) (hp : Dia R (Box R P) w) : Box R (Dia R P) w := by
  obtain ⟨v, hwv, hbox⟩ := hp
  intro u hwu
  obtain ⟨t, hvt, hut⟩ := hc w v u hwv hwu
  exact ⟨t, hut, hbox t hvt⟩

/-- **Axiom 5** (Euclidean frames): `◇p → □◇p`. -/
theorem box_five (he : EuclideanRel R) (hp : Dia R P w) : Box R (Dia R P) w := by
  obtain ⟨v, hwv, hpv⟩ := hp
  intro u hwu
  exact ⟨v, he w u v hwu hwv, hpv⟩

/-- Confluence is the *semantic* content of `.2`: a relation validates the schema
    `◇□p → □◇p` (at every world, for every predicate) **iff** it is confluent.
    The forward direction takes `P` to be membership in a chosen successor. -/
theorem confluent_of_dot2
    (h : ∀ (P : W → Prop) (w : W), Dia R (Box R P) w → Box R (Dia R P) w) :
    Confluent R := by
  intro x y z hxy hxz
  have hdia : Dia R (Box R (fun t => R y t)) x := ⟨y, hxy, fun _t ht => ht⟩
  obtain ⟨u, hzu, huy⟩ := h (fun t => R y t) x hdia z hxz
  exact ⟨u, huy, hzu⟩

end Kripke

/-! ## The asymmetric (domination) forcing frame -/

section Asymmetric

variable {α : Type*}

/-- A `World` is a truth assignment to atomic set-theoretic assertions. -/
abbrev World (α : Type*) := α → Bool

/-- **Asymmetric accessibility**: `dom w v` means `v` decides at least as many
    atoms positively as `w`.  An extension may switch atoms on, never off. -/
def dom (w v : World α) : Prop := ∀ a, w a = true → v a = true

theorem dom_refl : Reflexive (dom (α := α)) := fun _w _a h => h

theorem dom_trans : Transitive (dom (α := α)) :=
  fun _x _y _z h1 h2 a h => h2 a (h1 a h)

/-- The domination order is **confluent**: the pointwise `or` (join) of two
    extensions dominates both. -/
theorem dom_confluent : Confluent (dom (α := α)) := by
  intro x y z _hxy _hxz
  refine ⟨fun a => y a || z a, ?_, ?_⟩
  · intro a h; simp [h]
  · intro a h; simp [h]

/-! ### The asymmetric frame validates `S4.2` -/

/-- Asymmetric forcing validates **T** (`□p → p`). -/
theorem asym_T {P : World α → Prop} {w : World α} (hp : Box dom P w) : P w :=
  box_T dom_refl hp

/-- Asymmetric forcing validates **4** (`□p → □□p`). -/
theorem asym_four {P : World α → Prop} {w : World α} (hp : Box dom P w) :
    Box dom (Box dom P) w :=
  box_four dom_trans hp

/-- Asymmetric forcing validates **.2** (`◇□p → □◇p`): the characteristic axiom. -/
theorem asym_dot2 {P : World α → Prop} {w : World α}
    (hp : Dia dom (Box dom P) w) : Box dom (Dia dom P) w :=
  box_dot2 dom_confluent hp

end Asymmetric

/-! ## Separation: asymmetric forcing refutes `5`

We witness the failure of `S5` in the two-atom model `World Bool`.  From the
bottom world `bot` (all atoms false) the predicate "`= m`" (the world in which
exactly the atom `true` holds) is *possible*, yet not *necessarily possible*:
the world `top` (all atoms true) is accessible from `bot` but cannot reach `m`,
since reaching `m` would require switching the atom `false` back off. -/

section Separation

/-- The bottom world: every atom false. -/
def bot : World Bool := fun _ => false

/-- The world in which exactly the atom `true` holds. -/
def m : World Bool := fun a => a

/-- The world in which every atom is true. -/
def top : World Bool := fun _ => true

/-- `bot` dominates nothing nontrivially, so it dominates `m`. -/
theorem dom_bot_m : dom bot m := fun a h => by simp [bot] at h

/-- `bot` dominates `top`. -/
theorem dom_bot_top : dom bot top := fun a h => by simp [bot] at h

/-- `top` does **not** dominate `m`: the atom `false` is on in `top` but off in
    `m`, and domination cannot switch it off. -/
theorem not_dom_top_m : ¬ dom top m := by
  intro h
  have := h false (by simp [top])
  simp [m] at this

/-- The domination frame is **not Euclidean**: `dom bot top` and `dom bot m` hold,
    but `dom top m` fails. -/
theorem dom_not_euclidean : ¬ EuclideanRel (dom (α := Bool)) := by
  intro he
  exact not_dom_top_m (he bot top m dom_bot_top dom_bot_m)

/-- **Separation theorem.**  Asymmetric forcing *refutes* axiom `5`: there is a
    predicate `P` and a world `w` with `◇P` true but `□◇P` false.  Combined with
    `asym_T`, `asym_four`, `asym_dot2`, this shows the frame validates `S4.2`
    while falsifying `S5`. -/
theorem asym_refutes_five :
    ∃ (P : World Bool → Prop) (w : World Bool),
      Dia dom P w ∧ ¬ Box dom (Dia dom P) w := by
  refine ⟨fun t => t = m, bot, ⟨m, dom_bot_m, rfl⟩, ?_⟩
  intro hb
  obtain ⟨t, hut, ht⟩ := hb top dom_bot_top
  subst ht
  exact not_dom_top_m hut

/-- The predicate witnessing the failure of `5` is genuinely *possible* from the
    bottom world (sanity companion to `asym_refutes_five`). -/
theorem asym_dia_witness : Dia dom (fun t => t = m) bot := ⟨m, dom_bot_m, rfl⟩

end Separation

end MultiverseAsymmetricForcing