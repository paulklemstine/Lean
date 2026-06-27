/-
# Saturation contrast: maximality alone does not pin the incoherence index

The realization result (`IncoherenceIndex.lean`) attains a *large* incoherence
index `n` using the *sparse* maximal frame `{1} ⊆ ZMod n`.  This file proves the
complementary structural fact that motivates that choice: the *saturated* maximal
frame `{1,3} ⊆ ZMod 4` (all odd residues) is also maximal, yet its incoherence
index collapses to `2`.  Hence maximality alone does not determine the index, and
the extremal value is genuinely a property of the sparse generator.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  Among maximal frames on `n` states, adding more odd
atoms strictly shortens the shortest balanced sequence; the maximum index is the
exclusive privilege of single-generator frames.

EXPERIMENT (Experimenter).  Test the smallest interesting case `n = 4`.  The
sparse frame `{1}` has index `4` (proved upstream); the saturated odd frame
`{1,3}` admits the balanced sequence `[1,3]` (sum `= 4 ≡ 0`), so its index drops
to `2`.

ANALYSIS (Analyst).  Both frames are maximal (each contains the unit `1`, which
generates `ZMod 4`), so the gap `4` vs `2` is caused purely by atom density, not
by reachability.  This isolates "sparsity of generators" as the operative lever.

CRITIQUE (Critic).  The index `2` is proved by antisymmetry: `[1,3]` realizes the
upper bound, and a length-`1` balanced sequence is impossible because no single
odd residue of `ZMod 4` is `0`.  No `decide`-only shortcut on the index itself.

SYNTHESIS (PI).  Combined with `realization_even`, this shows the realizable
spectrum is sensitive to atom density; future work (see `FUTURE_DIRECTIONS.md`)
should classify the index as a function of the atom set, not merely of maximality.
-- !-- Lab Notes -- !--
-/
import Applications.SocialChoice.IncoherenceIndex

namespace SocialChoice

/-- The saturated odd frame `{1,3} ⊆ ZMod 4` is maximal: it contains the unit `1`,
which generates the whole group. -/
lemma isMaximal_oneThree : IsMaximal ({1, 3} : Frame 4) := by
  have h1 := isMaximal_singleton_one 4
  unfold IsMaximal at h1 ⊢
  refine top_le_iff.mp (h1.ge.trans (AddSubgroup.closure_mono ?_))
  intro x hx
  rw [Finset.coe_singleton, Set.mem_singleton_iff] at hx
  subst hx
  simp

/-- The saturated maximal frame `{1,3} ⊆ ZMod 4` has incoherence index `2`,
strictly below the index `4` of the sparse maximal frame `{1}`.  Thus maximality
does not determine the incoherence index. -/
theorem incoherenceIndex_oneThree : incoherenceIndex ({1, 3} : Frame 4) = 2 := by
  have hbal : IsBalanced ({1, 3} : Frame 4) [1, 3] := by
    refine ⟨by simp, ?_, by decide⟩
    intro x hx
    fin_cases hx <;> decide
  apply le_antisymm
  · exact Nat.sInf_le ⟨[1, 3], hbal, rfl⟩
  · -- every balanced sequence has length ≥ 2
    have key : ∀ k ∈ balancedLengths ({1, 3} : Frame 4), 2 ≤ k := by
      rintro k ⟨l, ⟨hne, hmem, hsum⟩, rfl⟩
      rcases l with _ | ⟨a, l⟩
      · exact absurd rfl hne
      · rcases l with _ | ⟨b, l⟩
        · exfalso
          have ha : a ∈ ({1, 3} : Frame 4) := hmem a (by simp)
          simp only [List.sum_cons, List.sum_nil, add_zero] at hsum
          rw [Finset.mem_insert, Finset.mem_singleton] at ha
          rcases ha with rfl | rfl <;> exact absurd hsum (by decide)
        · simp
    exact key _ (Nat.sInf_mem ⟨2, [1, 3], hbal, rfl⟩)

end SocialChoice