import Mathlib

/-!
# Anti-Mathematics VI: Hereditary finiteness and the cumulative rank

**Mission.** *Anti-Mathematics: What if all axioms were negated?*  Negating the
Axiom of **Infinity** yields the hereditarily finite universe `HF = V_ω`.  This file
makes the "hereditarily finite" and "cumulative" structure of the Ackermann model
(`a ∈ₐ b :⟺ Nat.testBit b a`) precise.

## Results

* `transGen_lt` — every ∈-ancestor of a set has a strictly smaller code.
* `hereditarily_finite` — the **∈-transitive closure** of any set is finite: every
  set is hereditarily finite, the defining property of `HF`.
* `members_finite` — in particular every set has finitely many members.
* `rank` — the set-theoretic **rank**, defined by ∈-recursion.
* `rank_lt_of_mem` — `rank` strictly decreases along membership, so it is a genuine
  rank function witnessing the cumulative hierarchy.
* `rank_le` — every set has rank at most its own code; combined with `rank_zero`
  this shows the cumulative hierarchy of the model is exhausted at the finite
  stages, i.e. the model is contained in `V_ω`.
-/

namespace AntiMath.Hereditary

/-- **Ackermann membership**: `a ∈ₐ b` iff the `a`-th binary digit of `b` is `1`. -/
def Mem (a b : ℕ) : Prop := b.testBit a

@[inherit_doc] scoped infix:50 " ∈ₐ " => Mem

/-- Membership strictly decreases the Ackermann code: `a ∈ₐ b → a < b`. -/
theorem mem_lt {a b : ℕ} (h : a ∈ₐ b) : a < b :=
  lt_of_lt_of_le (Nat.lt_two_pow_self) (Nat.ge_two_pow_of_testBit h)

/-- Every ∈-ancestor (member, member-of-member, …) of `a` has a smaller code. -/
theorem transGen_lt {x a : ℕ} (h : Relation.TransGen Mem x a) : x < a := by
  induction h with
  | single hb => exact mem_lt hb
  | tail _ hb ih => exact lt_trans ih (mem_lt hb)

/-- **Hereditary finiteness.**  The ∈-transitive closure of any set is finite: the
class of all ∈-ancestors of `a` is a finite set.  This is exactly the assertion
that every set of the model is *hereditarily finite*, the defining property of the
universe `HF = V_ω` obtained by negating Infinity. -/
theorem hereditarily_finite (a : ℕ) :
    {x | Relation.TransGen Mem x a}.Finite :=
  Set.Finite.subset (Set.finite_Iio a) (fun _ hx => transGen_lt hx)

/-- Every set has finitely many members. -/
theorem members_finite (a : ℕ) : {x | x ∈ₐ a}.Finite :=
  Set.Finite.subset (Set.finite_Iio a) (fun _ hx => mem_lt hx)

/-- **Set-theoretic rank**, defined by ∈-recursion: `rank a` is the least strict
upper bound of the ranks of the members of `a`.  Recursion is legitimate because
membership strictly decreases the code. -/
def rank (a : ℕ) : ℕ :=
  ((Finset.range a).filter (fun x => a.testBit x)).attach.sup (fun x => rank x.1 + 1)
termination_by a
decreasing_by
  obtain ⟨x, hx⟩ := x
  simp only [Finset.mem_filter, Finset.mem_range] at hx
  exact hx.1

/-- Defining equation of `rank`. -/
theorem rank_eq (a : ℕ) :
    rank a =
      ((Finset.range a).filter (fun x => a.testBit x)).attach.sup (fun x => rank x.1 + 1) := by
  rw [rank]

/-- The empty set has rank `0`. -/
theorem rank_zero : rank 0 = 0 := by rw [rank_eq]; simp

/-- **`rank` is a genuine rank function**: it strictly decreases along membership. -/
theorem rank_lt_of_mem {x a : ℕ} (h : x ∈ₐ a) : rank x < rank a := by
  rw [rank_eq a]
  apply Nat.lt_of_lt_of_le (Nat.lt_succ_self (rank x))
  have hmem : x ∈ (Finset.range a).filter (fun y => a.testBit y) := by
    simp only [Finset.mem_filter, Finset.mem_range]; exact ⟨mem_lt h, h⟩
  exact Finset.le_sup (f := fun y => rank y.1 + 1) (Finset.mem_attach _ ⟨x, hmem⟩)

/-- Every set has rank at most its own code; the cumulative hierarchy of the model
never leaves the finite stages, i.e. the model is contained in `V_ω`. -/
theorem rank_le (a : ℕ) : rank a ≤ a := by
  induction a using Nat.strong_induction_on with
  | _ a ih =>
    rw [rank_eq]
    apply Finset.sup_le
    rintro ⟨x, hx⟩ _
    simp only [Finset.mem_filter, Finset.mem_range] at hx
    have := ih x hx.1
    dsimp only
    omega

end AntiMath.Hereditary