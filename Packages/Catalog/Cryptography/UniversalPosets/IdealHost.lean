import Cryptography.UniversalPosets.MinSize

/-!
# The host of nonempty ideals: `U(n) ≤ 2^n - 1`

`Bounds.lean` uses the full Boolean lattice `Set (Fin n)` as a universal host,
of size `2^n`.  This file records the (small but strict) improvement obtained by
noticing that the labelling used there — `x ↦ {y | y ≤ x}`, the *principal
ideal* of `x` — never produces the empty label, because `x` always belongs to
its own ideal.  Deleting the empty set from the Boolean lattice therefore leaves
a universal host:

`minUniversalSize n ≤ 2 ^ n - 1`.

The host is the poset of **nonempty** subsets of an `n`-element set ordered by
inclusion; the embedding is again by principal ideals, and it is *induced*
because `x ≤ y ↔ ideal x ⊆ ideal y` in any partial order.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer).  Every label used by the Boolean-lattice embedding
contains the element it labels, so the empty label is never used; more
generally, the label of `x` determines `x` as its own maximum along any linear
extension, so the labels are exactly the nonempty subsets, and no further
subset can be deleted from this particular *scheme*.

Experiment (Experimenter).  The deletion of `∅` is formalised below.  Attempts
to delete a second subset fail for this scheme: for every nonempty `S ⊆ [n]`
and every `x ∈ S` there is a poset (make `S \ {x}` an antichain below `x`, all
other points isolated) whose ideal labelling uses exactly the label `S`; this is
`ideal_label_attained`.

Analysis (Analyst).  The improvement is by one point, not by an exponential
factor: the ideal scheme is intrinsically `2^n`-sized, and beating it requires
the fundamentally different, regularity-based labelling of the motivating paper.
What the file does establish is that the naive bound `2^n` is *never* attained,
so the sandwich `2^{n/4} ≤ U(n) < 2^n` is strict at the top for every `n ≥ 1`.

Critique (Critic).  Nothing is vacuous: the host is an explicit finite poset
whose cardinality is computed, the embedding is exhibited, and the accompanying
`ideal_label_attained` shows the bound is optimal *for this labelling scheme*
(it does not claim optimality of `U`).
-/

namespace UniversalPosets

open Function

variable {n : ℕ}

/-- The host of nonempty subsets of `Fin n`, ordered by inclusion. -/
def NeHost (n : ℕ) : Type := {S : Finset (Fin n) // S.Nonempty}

instance : Fintype (NeHost n) := inferInstanceAs (Fintype {S : Finset (Fin n) // S.Nonempty})

instance : PartialOrder (NeHost n) :=
  inferInstanceAs (PartialOrder {S : Finset (Fin n) // S.Nonempty})

@[simp] theorem NeHost.le_def (S T : NeHost n) : S ≤ T ↔ S.1 ⊆ T.1 := Iff.rfl

/-- The host of nonempty ideals has `2^n - 1` points. -/
theorem card_NeHost (n : ℕ) : Fintype.card (NeHost n) = 2 ^ n - 1 := by
  classical
  have h : Fintype.card (NeHost n)
      = (Finset.univ.filter (fun S : Finset (Fin n) => S.Nonempty)).card :=
    Fintype.card_subtype _
  have hfil : (Finset.univ.filter (fun S : Finset (Fin n) => S.Nonempty))
      = Finset.univ.erase (∅ : Finset (Fin n)) := by
    ext S
    simp [Finset.mem_erase, Finset.nonempty_iff_ne_empty]
  rw [h, hfil, Finset.card_erase_of_mem (Finset.mem_univ _)]
  simp

/-- **The nonempty ideals form a universal host.** -/
theorem neHost_isUniversalHost (n : ℕ) : IsUniversalHost (NeHost n) (Fin n) := by
  classical
  intro r hr
  haveI := hr
  refine ⟨fun x => ⟨Finset.univ.filter (fun y => r y x), ⟨x, by
    simp [refl_of r x]⟩⟩, fun x y => ?_⟩
  simp only [NeHost.le_def, Finset.subset_iff, Finset.mem_filter, Finset.mem_univ, true_and]
  constructor
  · intro h; exact h (refl_of r x)
  · intro h z hz; exact trans_of r hz h

/-- **Improved upper bound**: `U(n) ≤ 2^n - 1`. -/
theorem minUniversalSize_le_two_pow_sub_one (n : ℕ) : minUniversalSize n ≤ 2 ^ n - 1 :=
  Nat.sInf_le
    (isUniversalPosetOfSize_of_host (U := NeHost n) (card_NeHost n) (neHost_isUniversalHost n))

/-- The naive Boolean bound is never attained: `U(n) < 2^n` for every `n`. -/
theorem minUniversalSize_lt_two_pow (n : ℕ) : minUniversalSize n < 2 ^ n := by
  have h := minUniversalSize_le_two_pow_sub_one n
  have : 0 < 2 ^ n := Nat.two_pow_pos n
  omega
/--
Every nonempty subset really occurs as a principal-ideal label, so no further
point can be deleted from the ideal host *as a labelling scheme*: given `S ≠ ∅`
and `x ∈ S`, the order that puts `S \ {x}` as an antichain below `x` (and leaves
every other point isolated) is a partial order whose ideal of `x` is exactly `S`.
-/
theorem ideal_label_attained {n : ℕ} (S : Set (Fin n)) (x : Fin n) (hx : x ∈ S) :
    ∃ r : Fin n → Fin n → Prop, IsPartialOrder (Fin n) r ∧ {y | r y x} = S := by
  classical
  refine ⟨fun a b => a = b ∨ (a ∈ S ∧ b = x ∧ a ≠ x), ?_, ?_⟩
  · refine
      haveI : Std.Refl (fun a b : Fin n => a = b ∨ (a ∈ S ∧ b = x ∧ a ≠ x)) :=
        ⟨fun _ => Or.inl rfl⟩
      haveI : IsTrans (Fin n) (fun a b : Fin n => a = b ∨ (a ∈ S ∧ b = x ∧ a ≠ x)) := ?_
      haveI : IsPreorder (Fin n) (fun a b : Fin n => a = b ∨ (a ∈ S ∧ b = x ∧ a ≠ x)) := ⟨⟩
      haveI : Std.Antisymm (fun a b : Fin n => a = b ∨ (a ∈ S ∧ b = x ∧ a ≠ x)) := ?_
      ⟨⟩
    · refine ⟨?_⟩
      rintro a b c (rfl | ⟨ha, rfl, hax⟩) (h2 | ⟨hb, rfl, hbx⟩)
      · exact Or.inl h2
      · exact Or.inr ⟨hb, rfl, hbx⟩
      · exact Or.inr ⟨ha, h2 ▸ rfl, hax⟩
      · exact absurd rfl hbx
    · refine ⟨?_⟩
      rintro a b (rfl | ⟨ha, rfl, hax⟩) (h2 | ⟨hb, rfl, hbx⟩)
      · rfl
      · exact absurd rfl hbx
      · exact h2.symm
      · exact absurd rfl hax
  · ext y
    by_cases hy : y = x
    · subst hy; simp [hx]
    · simp [hy, Set.mem_setOf_eq]

end UniversalPosets