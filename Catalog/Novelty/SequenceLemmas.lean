import Mathlib

/-!
# Monotone-sequence dichotomy for degree normalization

This file isolates the purely order-theoretic core of the degree-normalization
conjecture for linked tree-cut decompositions.  Along the root-to-end ray of the
decomposition the adhesion sizes form an integer sequence `a : ℕ → ℕ`.  When the
decomposition is *linked* and *componental* this sequence is **monotone**, and the
degree-normalization clause is precisely the dichotomy:

* a bounded monotone (or any antitone) `ℕ`-sequence is **eventually constant**,
  equal to its infimum — this is the "finite edge-degree stabilizes exactly" case;
* an unbounded monotone `ℕ`-sequence **diverges to `+∞`** — this is the
  "infinite edge-degree" case.

These are proved here with no graph theory, then transported to tree-cut
decompositions in `Core.lean`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the whole degree-normalization clause is, after
stripping graph language, the statement that a monotone integer sequence either
stabilizes exactly or diverges.  Experiment (Experimenter): formalize both halves
over `ℕ`.  Analysis (Analyst): the antitone half needs well-foundedness of `<` on
`ℕ` (the infimum is attained); the unbounded-monotone half is `tendsto … atTop`.
Critique (Critic): the dichotomy is FALSE without monotonicity (`1,2,1,2,…`),
so monotonicity is load-bearing and must be supplied by the decomposition's
linked+componental structure — this is exactly the boundary we record.
-- !-- end Lab Notes -- !--
-/

namespace DegreeNormalizedTreeCut

/-
An antitone `ℕ`-sequence of naturals is eventually equal to its infimum.
-/
theorem antitone_nat_eventually_eq_iInf (f : ℕ → ℕ) (hf : Antitone f) :
    ∃ N, ∀ n ≥ N, f n = ⨅ k, f k := by
      obtain ⟨N, hN⟩ : ∃ N, f N = ⨅ k, f k := by
        exact ( Nat.sInf_mem <| Set.range_nonempty f );
      exact ⟨ N, fun n hn => le_antisymm ( hN ▸ hf hn ) ( ciInf_le ( show BddBelow ( Set.range f ) from ⟨ 0, Set.forall_mem_range.mpr fun n => Nat.zero_le _ ⟩ ) _ ) ⟩

/-
A bounded monotone `ℕ`-sequence of naturals is eventually constant.
-/
theorem monotone_nat_eventually_const_of_bddAbove (f : ℕ → ℕ) (hf : Monotone f)
    (hb : BddAbove (Set.range f)) : ∃ N, ∀ n ≥ N, f n = f N := by
      -- Since the range of `f` is a bounded set of naturals, it must have a maximum element.
      obtain ⟨M, hM⟩ : ∃ M, M ∈ Set.range f ∧ ∀ y ∈ Set.range f, y ≤ M := by
        exact ⟨ Finset.max' ( Set.Finite.toFinset ( Set.finite_iff_bddAbove.mpr hb ) ) ⟨ _, Set.Finite.mem_toFinset _ |>.mpr <| Set.mem_range_self 0 ⟩, Set.Finite.mem_toFinset _ |>.1 <| Finset.max'_mem _ _, fun y hy => Finset.le_max' _ _ <| Set.Finite.mem_toFinset _ |>.2 hy ⟩;
      obtain ⟨ N, rfl ⟩ := hM.1; exact ⟨ N, fun n hn => le_antisymm ( hM.2 _ <| Set.mem_range_self _ ) ( hf hn ) ⟩ ;

/-
An unbounded monotone `ℕ`-sequence of naturals diverges: for every threshold
`k`, all sufficiently late terms are `≥ k`.
-/
theorem monotone_nat_unbounded_eventually_ge (f : ℕ → ℕ) (hf : Monotone f)
    (hb : ¬ BddAbove (Set.range f)) : ∀ k : ℕ, ∃ N, ∀ n ≥ N, k ≤ f n := by
      exact fun k => by rcases not_bddAbove_iff.mp hb k with ⟨ n, ⟨ m, rfl ⟩, hm ⟩ ; exact ⟨ m, fun n' hn' => hm.le.trans ( hf hn' ) ⟩

/-
**Monotone dichotomy.**  An eventually-monotone (here: monotone-or-antitone)
integer sequence either is eventually constant or diverges to `+∞`.
-/
theorem eventually_const_or_diverges (f : ℕ → ℕ) (hmono : Monotone f ∨ Antitone f) :
    (∃ c N, ∀ n ≥ N, f n = c) ∨ (∀ k : ℕ, ∃ N, ∀ n ≥ N, k ≤ f n) := by
      cases' hmono with hmono hmono;
      · by_cases hb : BddAbove ( Set.range f );
        · exact Or.inl <| by obtain ⟨ N, hN ⟩ := monotone_nat_eventually_const_of_bddAbove f hmono hb; exact ⟨ f N, N, hN ⟩ ;
        · exact Or.inr fun k => by rcases monotone_nat_unbounded_eventually_ge f hmono hb k with ⟨ N, hN ⟩ ; exact ⟨ N, fun n hn => hN n hn ⟩ ;
      · exact Or.inl <| by rcases antitone_nat_eventually_eq_iInf f hmono with ⟨ N, hN ⟩ ; exact ⟨ _, N, hN ⟩ ;

end DegreeNormalizedTreeCut