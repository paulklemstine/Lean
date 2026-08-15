import Bridges.PosetTheory.GaloisConnectionFixedPoints
import Bridges.KnasterTarskiBridge
/-!
# Bridging the Galois-connection fixed points to Knaster–Tarski

This file is the *only* place where the order-theoretic Galois-connection
development (`Bridges.GaloisConnectionFixedPoints`) is connected to the
catalog's Knaster–Tarski theorem (`Bridges.KnasterTarskiBridge`).  Keeping the
two developments in separate files guarantees that
`Bridges.GaloisConnectionFixedPoints` is genuinely independent of
Knaster–Tarski (no circular dependency).

Recall from `Bridges.KnasterTarskiBridge` that for a monotone `f` on a complete
lattice, the least fixed point is `sInf (preFixed f)` (where
`preFixed f = {x | f x ≤ x}`) and the greatest fixed point is
`sSup (postFixed f)` (where `postFixed f = {x | x ≤ f x}`).

For a Galois connection `(l, u)` the closure operator `cl a = u (l a)` and the
kernel operator `ker b = l (u b)` have explicit extremal fixed points:

* the **least** fixed point of `cl` is `u (l ⊥)` (the closure of `⊥`);
* the **greatest** fixed point of `ker` is `l (u ⊤)` (the kernel of `⊤`).
-/

namespace GaloisConnectionFixedPoints

open KnasterTarskiBridge

universe u v

variable {α : Type u} {β : Type v} [CompleteLattice α] [CompleteLattice β]
variable {l : α → β} {u : β → α}

/-- The closure operator `u ∘ l` of a Galois connection is monotone, so the
Knaster–Tarski machinery applies to it. -/
theorem monotone_cl' (gc : GaloisConnection l u) : Monotone (fun a => u (l a)) :=
  cl_monotone gc

/-- The kernel operator `l ∘ u` of a Galois connection is monotone. -/
theorem monotone_ker' (gc : GaloisConnection l u) : Monotone (fun b => l (u b)) :=
  ker_monotone gc

/-- **Least fixed point of the closure operator.**  Via Knaster–Tarski the least
fixed point of `cl a = u (l a)` is `sInf (preFixed cl)`, and this equals the
closure of `⊥`, namely `u (l ⊥)`. -/
theorem lfp_closure_eq (gc : GaloisConnection l u) :
    sInf (preFixed (fun a => u (l a))) = u (l ⊥) := by
  apply le_antisymm
  · exact sInf_le (le_of_eq (u_l_u gc (l ⊥)))
  · apply le_sInf
    intro x hx
    exact (monotone_u gc (monotone_l gc bot_le)).trans hx

/-- The Knaster–Tarski least fixed point of `cl` is indeed a fixed point and
equals `u (l ⊥)`. -/
theorem closure_lfp_isFixed (gc : GaloisConnection l u) :
    u (l (u (l ⊥))) = u (l ⊥) := u_l_u gc (l ⊥)

/-- **Greatest fixed point of the kernel operator.**  Via the dual Knaster–Tarski
the greatest fixed point of `ker b = l (u b)` is `sSup (postFixed ker)`, and this
equals the kernel of `⊤`, namely `l (u ⊤)`. -/
theorem gfp_kernel_eq (gc : GaloisConnection l u) :
    sSup (postFixed (fun b => l (u b))) = l (u ⊤) := by
  apply le_antisymm
  · apply sSup_le
    intro x hx
    exact hx.trans (monotone_l gc (monotone_u gc le_top))
  · exact le_sSup (le_of_eq (l_u_l gc (u ⊤)).symm)

/-- The dual Knaster–Tarski greatest fixed point of `ker` is indeed a fixed point
and equals `l (u ⊤)`. -/
theorem kernel_gfp_isFixed (gc : GaloisConnection l u) :
    l (u (l (u ⊤))) = l (u ⊤) := l_u_l gc (u ⊤)

end GaloisConnectionFixedPoints