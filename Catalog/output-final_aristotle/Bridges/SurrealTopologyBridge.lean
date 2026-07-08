/-
# Surreal Topology Bridge

A cross-domain bridge connecting **combinatorial game theory / set theory**
(Conway's surreal numbers `Surreal`) with **point-set topology**.

Conway's surreal numbers form the largest ordered field, containing the reals,
all ordinals, and all infinitesimals.  In `Mathlib` `Surreal` is realized as a
genuine `Type` (numeric pre-games modulo the game equivalence), carrying a
`LinearOrder` and a strict ordered commutative ring structure.

We equip `Surreal` with its **order topology** and prove the following bridge
theorems:

* `Surreal.instDenselyOrdered` — surreals are *densely ordered*: between any two
  surreals `a < b` there is a third surreal.  The witness is the numeric
  pre-game `{a | b}` (the "simplest number" strictly between `a` and `b`), a
  purely combinatorial-game construction.
* `Surreal.instNoMaxOrder` / `Surreal.instNoMinOrder` — surreals are unbounded
  above and below (`a < a + 1`, `a - 1 < a`).
* `Surreal.t2Space` — the order topology is Hausdorff.
* `Surreal.perfectSpace` — **the bridge**: because the order is dense, the order
  topology on `Surreal` has *no isolated points*; i.e. `Surreal` is a perfect
  space (`𝓝[≠] x` is never trivial).  This is a topological statement deduced
  from a game-theoretic/order-theoretic fact.
* `Surreal.not_compactSpace` — the order topology is not compact (there is no
  greatest surreal).

These make precise, in the fragment of the theory that lives inside a single
Lean universe, the informal claim that the ordered field of surreal numbers
carries a natural topology that is dense-in-itself (perfect) and non-compact.

The file is self-contained (`import Mathlib`).
-/

import Mathlib

open SetTheory PGame
open scoped Topology

namespace Surreal

/-- **Density of the surreals (order-theory / combinatorial-game bridge).**
Between any two surreal numbers `a < b` lies a third surreal.  The witness is
the numeric pre-game `{a | b}` with a single Left option `a` and a single Right
option `b`; it is numeric precisely because `a < b`, and by the basic
`moveLeft_lt` / `lt_moveRight` inequalities it sits strictly between `a` and `b`. -/
noncomputable instance instDenselyOrdered : DenselyOrdered Surreal := by
  constructor
  rintro a b hab
  induction a using Quotient.inductionOn with | _ x =>
  induction b using Quotient.inductionOn with | _ y =>
  obtain ⟨X, ox⟩ := x
  obtain ⟨Y, oy⟩ := y
  have hXY : X < Y := hab
  -- the "simplest number between": the numeric pre-game `{X | Y}`.
  set g : PGame := PGame.mk PUnit PUnit (fun _ => X) (fun _ => Y) with hg
  have hgnum : g.Numeric := Numeric.mk (fun _ _ => hXY) (fun _ => ox) (fun _ => oy)
  refine ⟨Surreal.mk g hgnum, ?_, ?_⟩
  · simpa [g] using Surreal.mk_moveLeft_lt_mk hgnum PUnit.unit
  · simpa [g] using Surreal.mk_lt_mk_moveRight hgnum PUnit.unit

/-- The surreals have no greatest element: `a < a + 1`. -/
instance instNoMaxOrder : NoMaxOrder Surreal := ⟨fun a => ⟨a + 1, lt_add_one a⟩⟩

/-- The surreals have no least element: `a - 1 < a`. -/
instance instNoMinOrder : NoMinOrder Surreal := ⟨fun a => ⟨a - 1, sub_one_lt a⟩⟩

/-- The order topology on the surreal numbers. -/
noncomputable instance instTopologicalSpace : TopologicalSpace Surreal :=
  Preorder.topology Surreal

/-- The chosen topology is by definition the order topology. -/
instance instOrderTopology : OrderTopology Surreal := ⟨rfl⟩

/-- The order topology on the surreals is Hausdorff. -/
instance t2Space : T2Space Surreal := inferInstance

/-- **Main bridge theorem.**  The order topology on the surreal numbers is a
*perfect space*: it has no isolated points.  Equivalently, for every surreal `x`
the punctured neighbourhood filter `𝓝[≠] x` is nontrivial.  This is a purely
topological conclusion drawn from the order-density of `Surreal`
(`instDenselyOrdered`), itself a combinatorial-game fact. -/
instance perfectSpace : PerfectSpace Surreal := by
  rw [perfectSpace_iff_forall_not_isolated]
  intro x
  infer_instance

/-- Restatement of the bridge: no surreal number is isolated in the order
topology. -/
theorem not_isolated (x : Surreal) : (𝓝[≠] x).NeBot := inferInstance

/-- The order topology on the surreals is **not compact**: were it compact there
would be a greatest surreal number, contradicting `instNoMaxOrder`. -/
theorem not_compactSpace : ¬ CompactSpace Surreal := by
  intro h
  obtain ⟨m, -, hm⟩ :=
    (isCompact_univ (X := Surreal)).exists_isGreatest ⟨0, Set.mem_univ 0⟩
  obtain ⟨y, hy⟩ := exists_gt m
  exact absurd (hm (Set.mem_univ y)) (not_le.2 hy)

end Surreal