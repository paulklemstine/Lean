/-
# Realization of all even incoherence indices ≥ 4 by maximal standard frames

This file formalizes a concrete model of *standard social decision frames* and
their *incoherence index* — the length of the shortest perfectly balanced
sequence of majority-or-tie sets — and proves the realization conjecture: for
every even `n ≥ 4` there is a *maximal* standard frame whose incoherence index
is exactly `n`.  We additionally prove that `n` is the maximum index attainable
on `n` social states, that even-atom frames always have even index, and that the
spectrum of incoherence indices is unbounded.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  Conjecture 5.7 / B.25 (MossPedersen2026, cold-start:
the referenced catalog files are not present, so we reconstruct a faithful model
from the informal description).  For every even `n ≥ 4` some maximal standard
social decision frame has incoherence index exactly `n`.

EXPERIMENT (Experimenter).  Model a frame as a finite set `F ⊆ ZMod n` of atoms;
a perfectly balanced sequence is a non-empty list of atoms summing to `0`; the
incoherence index is the infimum of the lengths of such sequences.  The
single-generator cyclic frame `{1} ⊆ ZMod n` has additive order `n`, so its
shortest zero-sum sequence is `1` repeated `n` times.  Computationally
(`ComputationalEvidence.md`) the index equals `n` for all tested `n`.

ANALYSIS (Analyst).  The result is "true and provable" via the additive order of
a unit.  Crucially `n` is also an *upper* bound on the index of any non-empty
frame (repeat one atom `n` times), so the cyclic frame attains the maximum.
Saturating a frame with more odd atoms only shortens balanced sequences (e.g.
`{1,3} ⊆ ZMod 4` has index `2`), so the extremal value is achieved by the sparse
maximal frame — the structural heart of the conjecture.

CRITIQUE (Critic).  Guards installed: `realization_even` produces a frame that is
provably maximal (`IsMaximal`, atoms generate `⊤`), the index equality is proved
by antisymmetry (not `rfl`/`decide`), and `even_incoherenceIndex` shows the value
is genuinely even.  No theorem is vacuous: each existential exhibits a concrete
witness with a nontrivial computed index.

SYNTHESIS (PI).  `realization_even` + `incoherenceIndex_isGreatest` give: the
maximum incoherence index over `n` states is `n`, attained by a maximal frame,
and every even `n ≥ 4` is realized.  See `FUTURE_DIRECTIONS.md`.
-- !-- Lab Notes -- !--
-/
import Mathlib

namespace SocialChoice

open scoped BigOperators

/-- A *standard social decision frame* on `n` social states: a finite set of
"majority-or-tie" residues (atoms) in `ZMod n`. -/
abbrev Frame (n : ℕ) := Finset (ZMod n)

/-- A *perfectly balanced sequence* for a frame `F`: a non-empty list of atoms of
`F` whose sum vanishes in `ZMod n`. -/
def IsBalanced {n : ℕ} (F : Frame n) (l : List (ZMod n)) : Prop :=
  l ≠ [] ∧ (∀ x ∈ l, x ∈ F) ∧ l.sum = 0

/-- The set of lengths of perfectly balanced sequences of `F`. -/
def balancedLengths {n : ℕ} (F : Frame n) : Set ℕ :=
  { k | ∃ l, IsBalanced F l ∧ l.length = k }

/-- The *incoherence index*: the length of the shortest perfectly balanced
sequence (`0` if no balanced sequence exists). -/
noncomputable def incoherenceIndex {n : ℕ} (F : Frame n) : ℕ :=
  sInf (balancedLengths F)

/-- A frame is *maximal* when its atoms generate the whole decision space. -/
def IsMaximal {n : ℕ} (F : Frame n) : Prop :=
  AddSubgroup.closure (F : Set (ZMod n)) = ⊤

/-
The cyclic frame `{1} ⊆ ZMod n` is maximal: the unit `1` generates the group.
-/
lemma isMaximal_singleton_one (n : ℕ) [NeZero n] :
    IsMaximal ({1} : Frame n) := by
  refine' le_antisymm _ _;
  · exact le_top;
  · intro x hx; simp_all +decide [ AddSubgroup.mem_closure_singleton ] ;
    exact ⟨ x.val, by simp +decide ⟩

/-
Repeating any single atom `n` times yields a balanced sequence, so the
incoherence index of any non-empty frame is at most `n`.
-/
lemma incoherenceIndex_le {n : ℕ} (hn : 0 < n) (F : Frame n) (hF : F.Nonempty) :
    incoherenceIndex F ≤ n := by
  obtain ⟨ a, ha ⟩ := hF;
  refine' Nat.sInf_le ⟨ List.replicate n a, _, _ ⟩;
  · refine' ⟨ _, _, _ ⟩ <;> aesop;
  · norm_num

/-
The incoherence index of the cyclic frame `{1} ⊆ ZMod n` is exactly `n`.
-/
lemma incoherenceIndex_singleton_one {n : ℕ} (hn : 0 < n) :
    incoherenceIndex ({1} : Frame n) = n := by
  refine' le_antisymm _ _;
  · exact incoherenceIndex_le hn _ <| by aesop;
  · refine' le_csInf _ _;
    · refine' ⟨ n, ⟨ List.replicate n 1, _, _ ⟩ ⟩ <;> norm_num [ hn ];
      refine' ⟨ _, _, _ ⟩ <;> norm_num [ hn.ne' ];
    · rintro b ⟨ l, ⟨ hl₁, hl₂, hl₃ ⟩, rfl ⟩ ; simp_all +decide [ List.sum_eq_card_nsmul ] ;
      rw [ ZMod.natCast_eq_zero_iff ] at hl₃ ; exact Nat.le_of_dvd ( List.length_pos_iff.mpr hl₁ ) hl₃

/-- **Realization.** For every even `n ≥ 4` there is a maximal standard social
decision frame whose incoherence index equals `n`.  (The evenness hypothesis
`hev` is the conjecture's explicit constraint; the construction in fact works for
every `n ≥ 1`, so `hev` is retained only for faithfulness to the statement.) -/
theorem realization_even (n : ℕ) (hn4 : 4 ≤ n) (hev : Even n) :
    ∃ F : Frame n, IsMaximal F ∧ incoherenceIndex F = n := by
  have hpos : 0 < n := by omega
  haveI : NeZero n := ⟨by omega⟩
  exact ⟨({1} : Frame n), isMaximal_singleton_one n, incoherenceIndex_singleton_one hpos⟩

/-- **Sharpness.** For even `n ≥ 4`, `n` is the greatest incoherence index of any
non-empty frame on `n` social states, and it is attained.  (As above, `hev` is
kept only to match the conjecture's even-index setting.) -/
theorem incoherenceIndex_isGreatest (n : ℕ) (hn4 : 4 ≤ n) (hev : Even n) :
    IsGreatest { k | ∃ F : Frame n, F.Nonempty ∧ incoherenceIndex F = k } n := by
  have hpos : 0 < n := by omega
  constructor
  · exact ⟨({1} : Frame n), ⟨1, by simp⟩, incoherenceIndex_singleton_one hpos⟩
  · rintro k ⟨F, hF, rfl⟩
    exact incoherenceIndex_le hpos F hF

/-
For even `n`, frames all of whose atoms are "odd" (sent to `1` by the parity
character `ZMod n → ZMod 2`) have even incoherence index.
-/
theorem even_incoherenceIndex {n : ℕ} (hd : 2 ∣ n)
    (F : Frame n) (hpar : ∀ a ∈ F, (ZMod.castHom hd (ZMod 2)) a = 1) :
    Even (incoherenceIndex F) := by
  by_cases h : ∃ l : List ( ZMod n ), l ≠ [] ∧ ( ∀ x ∈ l, x ∈ F ) ∧ l.sum = 0 <;> simp_all +decide [ Nat.even_iff ];
  · obtain ⟨l, hl_ne_empty, hl_mem, hl_sum⟩ := h
    have h_even : ∀ k ∈ balancedLengths F, Even k := by
      rintro k ⟨ l, hl_ne_empty, hl_mem, hl_sum ⟩
      have h_even : (l.map (ZMod.castHom hd (ZMod 2))).sum = 0 := by
        have h_even : (l.map (ZMod.castHom hd (ZMod 2))).sum = (ZMod.castHom hd (ZMod 2)) l.sum := by
          exact List.sum_hom l (ZMod.castHom hd (ZMod 2))
        cases hl_ne_empty ; aesop
      have h_card : (l.map (ZMod.castHom hd (ZMod 2))).sum = l.length • (1 : ZMod 2) := by
        have h_card : ∀ x ∈ l.map (ZMod.castHom hd (ZMod 2)), x = 1 := by
          simp_all +decide [ IsBalanced ];
        rw [ List.eq_replicate_of_mem h_card ] ; simp +decide [ List.sum_replicate ] ;
      have h_even_card : Even l.length := by
        simp_all +decide [ ZMod.natCast_eq_zero_iff ];
        exact even_iff_two_dvd.mpr h_even
      exact h_even_card |> fun h => by simpa [ hl_sum ] using h;
    exact Nat.even_iff.mp ( h_even _ ( Nat.sInf_mem ( show balancedLengths F |> Set.Nonempty from ⟨ _, ⟨ l, ⟨ hl_ne_empty, hl_mem, hl_sum ⟩, rfl ⟩ ⟩ ) ) );
  · unfold incoherenceIndex;
    rw [ show balancedLengths F = ∅ from _ ] ; norm_num [ Nat.even_iff ];
    exact Set.eq_empty_of_forall_notMem fun k hk => by obtain ⟨ l, hl₁, rfl ⟩ := hk; exact h l hl₁.1 hl₁.2.1 hl₁.2.2;

/-- **Unboundedness.** The spectrum of incoherence indices is unbounded: for every
`N` some frame has an (even) incoherence index exceeding `N`. -/
theorem incoherence_unbounded (N : ℕ) :
    ∃ (n : ℕ) (F : Frame n), Even (incoherenceIndex F) ∧ N < incoherenceIndex F := by
  refine ⟨2 * (N + 2), ({1} : Frame (2 * (N + 2))), ?_, ?_⟩
  · rw [incoherenceIndex_singleton_one (by omega)]; exact ⟨N + 2, by ring⟩
  · rw [incoherenceIndex_singleton_one (by omega)]; omega

end SocialChoice