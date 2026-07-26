/-
# Non-computable consciousness: the brain's behaviour space is "beyond Turing"

The Penrose side of the Orch OR programme rests on a philosophical claim: human
understanding is **non-computable** — it cannot be captured by any Turing
machine.  This file gives a rigorous, self-contained core of that idea using
Cantor diagonalization together with Mathlib's genuine model of Turing
computability, `Nat.Partrec.Code`.

We model:
* a **behaviour** as a total function `ℕ → Bool` (the yes/no response of an agent
  on each possible input), and
* a **Turing machine / algorithm** by Mathlib's `Nat.Partrec.Code` (partial
  recursive codes), which is a *countable* type — there are only countably many
  algorithms.

Main results:

* `no_surj_nat_behaviors` — Cantor's diagonal: no enumeration `ℕ → (ℕ → Bool)`
  is surjective.  Any listing of behaviours misses one.
* `behaviors_uncountable` — the space of behaviours is uncountable.
* `codes_not_surjective` — no assignment of a behaviour to each Turing code hits
  every behaviour: the countably many algorithms cannot realize all behaviours.
* `exists_noncomputable_behavior` — **there exists a boolean behaviour
  `f : ℕ → Bool` that is not `Computable`.**  This is the precise sense in which
  the space of possible input/output behaviours provably exceeds what any Turing
  machine can compute: consciousness *could* in principle inhabit this
  non-computable remainder.

None of this proves the brain is non-computable — it establishes the logical
room for the Penrose claim: non-computable behaviours demonstrably exist.
-/
import Mathlib

open Function Classical

namespace NonComputableConsciousness

/-- **Cantor's diagonal argument.**  No enumeration of boolean behaviours
`f : ℕ → (ℕ → Bool)` is surjective: given any listing, the diagonal behaviour
`n ↦ ¬ f n n` is absent. -/
theorem no_surj_nat_behaviors : ¬ ∃ f : ℕ → (ℕ → Bool), Surjective f := by
  rintro ⟨f, hf⟩
  obtain ⟨i, hi⟩ := hf (fun n => !(f n n))
  have := congrFun hi i
  simp at this

/-- The space of behaviours `ℕ → Bool` is uncountable. -/
theorem behaviors_uncountable : ¬ Countable (ℕ → Bool) := by
  intro h
  obtain ⟨g, hg⟩ := exists_surjective_nat (ℕ → Bool)
  exact no_surj_nat_behaviors ⟨g, hg⟩

/-- **Countably many algorithms cannot realize every behaviour.**  For any way of
assigning a boolean behaviour to each Turing-machine code, some behaviour is
never produced. -/
theorem codes_not_surjective (enc : Nat.Partrec.Code → (ℕ → Bool)) :
    ¬ Surjective enc := by
  intro h
  obtain ⟨g, hg⟩ := exists_surjective_nat Nat.Partrec.Code
  exact no_surj_nat_behaviors ⟨enc ∘ g, h.comp hg⟩

/-- **There is a non-computable behaviour.**  Some total function `f : ℕ → Bool`
is not `Computable`: no Turing machine computes it.  The proof shows that if every
behaviour were computable, the (countable) partial-recursive codes would inject
onto the (uncountable) space of behaviours — impossible. -/
theorem exists_noncomputable_behavior : ∃ f : ℕ → Bool, ¬ Computable f := by
  by_contra hcon
  push_neg at hcon
  -- Assign to each behaviour a code computing it (possible since all are computable).
  set assign : (ℕ → Bool) → Nat.Partrec.Code :=
    fun f => Classical.choose (Nat.Partrec.Code.exists_code.mp (hcon f)) with hdef
  have hspec : ∀ f, (assign f).eval = _ :=
    fun f => Classical.choose_spec (Nat.Partrec.Code.exists_code.mp (hcon f))
  -- This assignment is injective: equal codes ⇒ equal evaluations ⇒ equal behaviours.
  have hinj : Function.Injective assign := by
    intro f g hfg
    funext n
    have heval : (assign f).eval = (assign g).eval := by rw [hfg]
    rw [hspec f, hspec g] at heval
    have hn := congrFun heval n
    simp at hn
    exact hn
  -- An injection into a countable type makes behaviours countable — contradiction.
  exact behaviors_uncountable (Function.Injective.countable hinj)

end NonComputableConsciousness