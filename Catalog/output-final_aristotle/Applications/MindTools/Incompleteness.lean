import Applications.MindTools.Basic

/-!
# Mind Tools — incompleteness and the existence of mind tools

This file contains the core "Gödel-flavoured" results of the development,
grounded in **Cantor's theorem** (`Function.cantor_surjective`).

The philosophical claim we formalize is:

> A mind tool is a formal system `F` whose provable theorems are strictly larger
> than what a cognitive agent can *directly apprehend*.  ZFC is a mind tool:
> there are statements it settles that the brain cannot see one-by-one.

We model "directly apprehensible / recursively enumerable" by `Enumerable`
(theorems listable by `ℕ → Statement`).  The decisive fact is that the space of
*all* statements (`Set ℕ`) is uncountable, so **no enumerable system is
complete**.  This is our abstract incompleteness theorem, and from it we derive:

* `complete_not_enumerable` — the complete system is not enumerable;
* `enumerable_incomplete` — every enumerable system misses some statement;
* `enumerable_ne_complete` — hence no enumerable system is complete;
* `enumerable_has_unprovable_truth` — every enumerable system (e.g. ZFC) has a
  "true but unprovable" statement (a Gödel sentence, abstractly);
* `exists_mindTool_of_enumerable` — every enumerable brain admits a strictly
  stronger enumerable mind tool: cognition can always be extended;
* `zfc_is_mind_tool` — the headline statement, phrased for an abstract
  enumerable brain and an enumerable system `ZFC` strictly extending it.

All proofs are complete and axiom-clean (they use only Cantor's theorem and
elementary set theory).
-/

namespace MindTools

open scoped Classical

/-- An enumerable system can be extended by one new statement and stays
enumerable: prepend the new statement to the enumeration. -/
theorem Enumerable.insert {F : FormalSystem} (h : Enumerable F) (s : Statement) :
    Enumerable ⟨insert s F.Thm⟩ := by
  obtain ⟨e, he⟩ := h
  refine ⟨fun n => n.casesOn s e, ?_⟩
  intro x hx
  simp only [Set.mem_insert_iff] at hx
  rcases hx with rfl | hx
  · exact ⟨0, rfl⟩
  · obtain ⟨k, hk⟩ := he hx
    exact ⟨k + 1, hk⟩

/-- **Abstract incompleteness (ceiling version).** The complete system — the one
that proves *every* statement — is not enumerable.  Directly by Cantor: an
enumeration of all of `Set ℕ` would be a surjection `ℕ → Set ℕ`. -/
theorem complete_not_enumerable : ¬ Enumerable Complete := by
  rintro ⟨e, he⟩
  have hsurj : Function.Surjective e := by
    intro s
    have : s ∈ Set.range e := he (Set.mem_univ s)
    exact this
  exact Function.cantor_surjective e hsurj

/-- **Abstract incompleteness.** Every enumerable formal system fails to prove
some statement.  This is the essential content of Gödel's first incompleteness
theorem, isolated to its Cantor-diagonal core: a recursively enumerable theory
cannot capture the uncountable space of truths. -/
theorem enumerable_incomplete (F : FormalSystem) (h : Enumerable F) :
    ∃ s : Statement, s ∉ F.Thm := by
  obtain ⟨e, he⟩ := h
  have hns : ¬ Function.Surjective e := Function.cantor_surjective e
  simp only [Function.Surjective, not_forall] at hns
  obtain ⟨s, hs⟩ := hns
  refine ⟨s, ?_⟩
  intro hmem
  obtain ⟨n, hn⟩ := he hmem
  exact hs ⟨n, hn⟩

/-- No enumerable system is the complete system. -/
theorem enumerable_ne_complete (F : FormalSystem) (h : Enumerable F) :
    F ≠ Complete := by
  intro hEq
  obtain ⟨s, hs⟩ := enumerable_incomplete F h
  apply hs
  rw [hEq]
  exact Set.mem_univ s

/-- **Gödel phenomenon.** Every enumerable system (in particular any concrete,
recursively-axiomatized theory such as ZFC) has a *true-but-unprovable*
statement: a statement lying in the complete (ceiling) system but not provable in
`F`.  This is the abstract Gödel sentence. -/
theorem enumerable_has_unprovable_truth (F : FormalSystem) (h : Enumerable F) :
    ∃ s : Statement, s ∈ Complete.Thm ∧ s ∉ F.Thm := by
  obtain ⟨s, hs⟩ := enumerable_incomplete F h
  exact ⟨s, Set.mem_univ s, hs⟩

/-- **Cognition can always be extended.** Every enumerable brain `B` admits a
strictly more powerful enumerable mind tool `F` (`B ≺ F`), obtained by adjoining
a statement the brain does not prove.  Hence there is no maximal enumerable
system: the hierarchy of mind tools has no top. -/
theorem exists_mindTool_of_enumerable (B : FormalSystem) (hB : Enumerable B) :
    ∃ F : FormalSystem, Enumerable F ∧ IsMindTool B F := by
  obtain ⟨s, hs⟩ := enumerable_incomplete B hB
  refine ⟨⟨insert s B.Thm⟩, hB.insert s, ?_⟩
  show B.Thm ⊂ insert s B.Thm
  exact Set.ssubset_insert hs

/-- **ZFC is a mind tool.**  For any enumerable brain `Brain` and any enumerable
formal system `ZFC` that proves everything the brain does *and more*
(`Brain ≺ ZFC`), `ZFC` is a mind tool relative to `Brain`, and moreover it
witnesses concretely a theorem the brain cannot directly apprehend.

The hypothesis `Brain ≺ ZFC` records the empirical fact that ZFC proves strictly
more than any single mind directly sees; `exists_mindTool_of_enumerable` shows
such a strict extension always exists, so the hypothesis is satisfiable.  This is
the formal rendering of "ZFC extends cognition". -/
theorem zfc_is_mind_tool (Brain ZFC : FormalSystem)
    (hZFC : Enumerable ZFC) (hExt : Brain ≺ ZFC) :
    IsMindTool Brain ZFC
      ∧ (∃ s : Statement, s ∈ ZFC.Thm ∧ s ∉ Brain.Thm)
      ∧ (∃ t : Statement, t ∈ Complete.Thm ∧ t ∉ ZFC.Thm) := by
  refine ⟨hExt, ?_, enumerable_has_unprovable_truth ZFC hZFC⟩
  -- a strict extension of theorem-sets provides a theorem of `ZFC` not in `Brain`
  obtain ⟨s, hsZ, hsB⟩ := Set.exists_of_ssubset hExt
  exact ⟨s, hsZ, hsB⟩

end MindTools