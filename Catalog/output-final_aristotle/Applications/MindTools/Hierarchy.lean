import Applications.MindTools.Basic
import Mathlib.Order.OrderIsoNat

/-!
# Mind Tools — the hierarchy is *not* a well-order (a contrarian result)

Rucker's conjecture (paraphrased): *the hierarchy of mind tools is well-ordered
by proof-theoretic ordinal.*  A well-order requires two things: the order must be
**total** (any two systems comparable) and **well-founded** (no infinite
descending chain).

We formalize the natural "cognitive power" order on formal systems — extension of
theorem-sets — and **disprove** the well-ordering conjecture *for this order* on
two independent counts:

* `power_not_total` — there exist two formal systems, neither of which extends the
  other; the mind-tool relation is a genuine *partial* order, not a linear one.
* `exists_infinite_descending_chain` / `power_order_not_wellFounded` — there is an
  infinite strictly *decreasing* chain of formal systems, so the power order is
  not well-founded.

Both obstructions are essential.  The literal reading of the conjecture (mind
tools linearly and well-ordered by their theorem-power) is therefore **false**.

This does *not* refute the refined conjecture that a suitable *sub*-collection of
systems (e.g. the canonical theories of ordinal analysis) is well-ordered by
proof-theoretic ordinal — that lives on a different, coarser order and is left as
a genuine open direction (see `FUTURE_DIRECTIONS.md`).
-/

namespace MindTools

open scoped Classical

/-- The cognitive-power relation `≺` is a strict order (irreflexive and
transitive); this lets us embed `ℕ` decreasingly into it via `RelEmbedding.natGT`. -/
instance : IsStrictOrder FormalSystem LtPow where
  irrefl := ltPow_irrefl
  trans := fun _ _ _ => ltPow_trans

/-! ### The power order is not total -/

/-- **Incomparable mind tools exist.**  The system proving only the statement `∅`
and the system proving only the statement `univ` are incomparable: neither
extends the other.  Hence cognitive power is a partial, not a linear, order. -/
theorem power_not_total :
    ∃ F G : FormalSystem, ¬ F ≼ G ∧ ¬ G ≼ F := by
  refine ⟨⟨{(∅ : Set ℕ)}⟩, ⟨{(Set.univ : Set ℕ)}⟩, ?_, ?_⟩
  · intro h
    exact Set.empty_ne_univ (h rfl)
  · intro h
    exact Set.empty_ne_univ (h rfl).symm

/-! ### The power order is not well-founded -/

/-- The `n`-th system in our descending chain proves exactly the singleton
statements `{m}` for `m ≥ n`. -/
def tailSystem (n : ℕ) : FormalSystem :=
  ⟨(fun m => ({m} : Set ℕ)) '' {m | n ≤ m}⟩

/-- The singleton-encoding of naturals into statements is injective. -/
theorem singleton_stmt_injective :
    Function.Injective (fun m : ℕ => ({m} : Set ℕ)) := by
  intro a b h
  simpa using h

/-- The chain `tailSystem` is strictly decreasing: `tailSystem (n+1) ≺ tailSystem n`. -/
theorem tailSystem_strictAnti (n : ℕ) : tailSystem (n + 1) ≺ tailSystem n := by
  have hsub : (tailSystem (n + 1)).Thm ⊆ (tailSystem n).Thm :=
    Set.image_mono (fun _ hx => Nat.le_of_succ_le hx)
  show (tailSystem (n + 1)).Thm ⊂ (tailSystem n).Thm
  rw [Set.ssubset_iff_of_subset hsub]
  refine ⟨({n} : Set ℕ), ⟨n, le_refl n, rfl⟩, ?_⟩
  rintro ⟨m, hm, hmn⟩
  simp only [Set.mem_setOf_eq] at hm
  have : m = n := singleton_stmt_injective hmn
  omega

/-- There is an infinite strictly descending chain of formal systems under the
cognitive-power order. -/
theorem exists_infinite_descending_chain :
    ∃ f : ℕ → FormalSystem, ∀ n, f (n + 1) ≺ f n :=
  ⟨tailSystem, tailSystem_strictAnti⟩

/-- **The cognitive-power order is not well-founded.**  Consequently the
hierarchy of mind tools is *not* a well-order under theorem-set extension: the
literal well-ordering conjecture is false. -/
theorem power_order_not_wellFounded : ¬ WellFounded (LtPow) :=
  (RelEmbedding.natGT tailSystem tailSystem_strictAnti).not_wellFounded

end MindTools