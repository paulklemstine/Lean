/-
# Which Resource Does the Branching? Switchless Worlds and Clockless Worlds

`Combinatorics.CWorldFiltration` shows that every finite rooted directed poset is a
bounded morphic image of `CWorld (Fin 1) (Fin (card P))` — a *clockless* world.  This
file isolates the role of each of the two resources.

## Main results

* `representable_switchless_iff` — **with no switches you get exactly the chains.**
  A finite nonempty preorder is a bounded morphic image of some `CWorld (Fin n) (Fin 0)`
  iff it is a linear order.  So the clock alone can never create branching: every bit of
  incomparability in the image comes from the switches.
* `clock_redundant` — **the clock is redundant.**  A finite nonempty preorder is
  representable iff it is already a bounded morphic image of a *one-tick*
  clock-and-switch world `CWorld (Fin 1) (Fin m)`.  Combined with the previous item this
  says the two coordinates of `CWorld` are far from symmetric: switches subsume clocks,
  clocks cannot subsume switches.
* `BddMorphism.ofOrderIso` — order isomorphisms are bounded morphisms (the transport
  tool used above).
-/

import Combinatorics.CWorldFiltration

namespace CWorldFiltration

open Function

/-- Every order isomorphism is a bounded morphism. -/
def BddMorphism.ofOrderIso {X Y : Type*} [Preorder X] [Preorder Y] (e : X ≃o Y) :
    BddMorphism X Y where
  toFun := e
  forth _ _ h := e.monotone h
  back x q h := ⟨e.symm q, by simpa using e.symm.monotone h, by simp⟩

theorem BddMorphism.ofOrderIso_surjective {X Y : Type*} [Preorder X] [Preorder Y] (e : X ≃o Y) :
    Surjective (BddMorphism.ofOrderIso e).toFun := e.surjective

/-- A switchless clock-and-switch world is a linear order: the only coordinate is the
clock. -/
theorem switchless_total {n : ℕ} (w v : CWorld (Fin n) (Fin 0)) : w ≤ v ∨ v ≤ w := by
  rcases le_total w.clock v.clock with h | h
  · exact Or.inl ⟨h, fun b => b.elim0⟩
  · exact Or.inr ⟨h, fun b => b.elim0⟩

/-- **Switchless worlds represent exactly the finite chains.**  Without switches the
image of a clock-and-switch world is a linear order, and every finite nonempty linear
order arises this way. -/
theorem representable_switchless_iff (P : Type) [Preorder P] [Fintype P] [Nonempty P] :
    (∃ n : ℕ, ∃ f : BddMorphism (CWorld (Fin n) (Fin 0)) P, Surjective f.toFun) ↔
      ((∀ p q : P, p ≤ q ∨ q ≤ p) ∧ ∀ p q : P, p ≤ q → q ≤ p → p = q) := by
  constructor
  · rintro ⟨n, f, hf⟩
    refine ⟨?_, fun p q hpq hqp => f.antisymm_image hf hpq hqp⟩
    intro p q
    obtain ⟨w, rfl⟩ := hf p
    obtain ⟨v, rfl⟩ := hf q
    rcases switchless_total w v with h | h
    · exact Or.inl (f.forth h)
    · exact Or.inr (f.forth h)
  · rintro ⟨htot, hanti⟩
    letI : PartialOrder P := { ‹Preorder P› with le_antisymm := hanti }
    letI : LinearOrder P :=
      { ‹PartialOrder P› with
        le_total := htot
        toDecidableLE := Classical.decRel _ }
    let e : Fin (Fintype.card P) ≃o P := monoEquivOfFin P rfl
    refine ⟨Fintype.card P,
      (BddMorphism.ofOrderIso e).comp (forgetSwitches (Fin (Fintype.card P)) (Fin 0)), ?_⟩
    exact (BddMorphism.ofOrderIso_surjective e).comp
      (forgetSwitches_surjective (Fin (Fintype.card P)) (Fin 0))

/-- **The clock is redundant.**  Anything representable at all is representable with a
single clock tick: the switches alone carry all the structure. -/
theorem clock_redundant (P : Type) [Preorder P] [Fintype P] [Nonempty P] :
    Representable P ↔
      ∃ m : ℕ, ∃ f : BddMorphism (CWorld (Fin 1) (Fin m)) P, Surjective f.toFun := by
  constructor
  · intro h
    obtain ⟨hroot, hdir, hanti⟩ := (representable_iff P).mp h
    letI : PartialOrder P := { ‹Preorder P› with le_antisymm := hanti }
    obtain ⟨f, hf⟩ := representable_of_rooted_directed P hroot hdir
    exact ⟨Fintype.card P, f, hf⟩
  · rintro ⟨m, f, hf⟩
    exact ⟨1, m, f, hf⟩

/-- A chain of `ℓ + 1` points is representable without switches, and (by
`Combinatorics.CWorldFiltrationSharpness`) needs `ℓ` switches once the clock is
collapsed: the two resources trade off against each other. -/
theorem chain_switchless (ℓ : ℕ) :
    ∃ f : BddMorphism (CWorld (Fin (ℓ + 1)) (Fin 0)) (Fin (ℓ + 1)), Surjective f.toFun :=
  ⟨forgetSwitches (Fin (ℓ + 1)) (Fin 0), forgetSwitches_surjective _ _⟩

end CWorldFiltration