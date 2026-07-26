/-
# The fragment hierarchy never collapses: stratifying coherence by the index

A companion to `NonFiniteAxiomatization.lean`.  Where that file shows *some*
finite fragment fails, this file pinpoints *why*: the width-`B` fragment passes a
frame exactly when the frame's incoherence index exceeds `B`
(`coherentUpTo_iff_lt_incoherenceIndex`).  Consequently the fragments form a
*strictly* refining chain — for every `B` there is a maximal frame separating
width `B` from width `B+1` (`fragment_strictly_refines`) — so the hierarchy of
finite approximations never stabilizes.

The shared model (frames in `ZMod n`, balanced sequences, incoherence index) and
the three base lemmas about the single-generator frame are reproduced from the
catalog file `IncoherenceIndex.lean`; the monorepo build configuration prevents
importing it in isolation, so the infrastructure is inlined and the **new
results below are the stratification theorems**.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  Conjecture: the bounded fragments `CoherentUpTo B`
are governed *exactly* by the incoherence index — `CoherentUpTo B F ↔
B < incoherenceIndex F` for any incoherent frame — so increasing the width by one
strictly increases the discriminating power, and no finite width is terminal.

EXPERIMENT (Experimenter).  Identify `∃ l, IsBalanced F l ∧ l.length ≤ B` with
`∃ k ∈ balancedLengths F, k ≤ B`, and use that `incoherenceIndex = sInf
(balancedLengths F)` is attained (`Nat.sInf_mem`) when the set is non-empty.  The
single-generator frame `{1} ⊆ ZMod (B+1)` has index `B+1`, hence passes width `B`
but fails width `B+1` (the sequence `1` repeated `B+1` times), giving the strict
separator.

ANALYSIS (Analyst).  True and provable.  The index is the *exact* threshold: a
frame survives the width-`B` test iff its shortest violation is longer than `B`.
The strict-refinement corollary is then immediate from realizing index `B+1`.

CRITIQUE (Critic).  The iff is proved by antisymmetric `Nat.sInf` reasoning (not
`decide`); the non-emptiness hypothesis `hne` is essential and explicit (a fully
coherent frame has index `0` yet passes every fragment, so the iff genuinely
needs an actual violation to exist).  `fragment_strictly_refines` exhibits a
concrete maximal witness, so nothing is vacuous.

SYNTHESIS (PI).  Combined with `coherence_not_finitely_axiomatizable`, the index
is revealed as the complete invariant controlling the finite fragments: the
fragments refine strictly and forever, which is the structural reason measurable
majorities admit no bounded finite axiomatization.  See `FUTURE_DIRECTIONS.md`.
-- !-- Lab Notes -- !--
-/
import Mathlib

namespace SocialChoice

open scoped BigOperators

/-! ## Catalog model (reproduced from `IncoherenceIndex.lean`) -/

/-- A *standard social decision frame* on `n` social states. -/
abbrev Frame (n : ℕ) := Finset (ZMod n)

/-- A *perfectly balanced sequence* for a frame `F`. -/
def IsBalanced {n : ℕ} (F : Frame n) (l : List (ZMod n)) : Prop :=
  l ≠ [] ∧ (∀ x ∈ l, x ∈ F) ∧ l.sum = 0

/-- The set of lengths of perfectly balanced sequences of `F`. -/
def balancedLengths {n : ℕ} (F : Frame n) : Set ℕ :=
  { k | ∃ l, IsBalanced F l ∧ l.length = k }

/-- The *incoherence index*: the length of the shortest perfectly balanced
sequence. -/
noncomputable def incoherenceIndex {n : ℕ} (F : Frame n) : ℕ :=
  sInf (balancedLengths F)

/-- A frame is *maximal* when its atoms generate the whole decision space. -/
def IsMaximal {n : ℕ} (F : Frame n) : Prop :=
  AddSubgroup.closure (F : Set (ZMod n)) = ⊤

/-- The *width-`B` finite fragment*: a frame passes it when it admits no perfectly
balanced sequence of length `≤ B`. -/
def CoherentUpTo {n : ℕ} (B : ℕ) (F : Frame n) : Prop :=
  ¬ ∃ l, IsBalanced F l ∧ l.length ≤ B

/-- The cyclic frame `{1} ⊆ ZMod n` is maximal (reproduced from the catalog). -/
lemma isMaximal_singleton_one (n : ℕ) [NeZero n] :
    IsMaximal ({1} : Frame n) := by
  refine' le_antisymm _ _;
  · exact le_top;
  · intro x hx; simp_all +decide [ AddSubgroup.mem_closure_singleton ] ;
    exact ⟨ x.val, by simp +decide ⟩

/-- Every balanced sequence of `{1}` has length divisible by `n` (reproduced). -/
lemma singleton_one_balanced_dvd {n : ℕ} (l : List (ZMod n))
    (h : IsBalanced ({1} : Frame n) l) : (n : ℕ) ∣ l.length := by
  obtain ⟨ hl₁, hl₂ ⟩ := h;
  have h_sum : l.sum = l.length • (1 : ZMod n) := by
    rw [ List.eq_replicate_of_mem fun x hx => Finset.mem_singleton.mp ( hl₂.1 x hx ) ] ; simp +decide;
  cases n <;> simp_all +decide [ ← ZMod.natCast_eq_zero_iff ]

/-- Every balanced sequence of `{1} ⊆ ZMod n` has length at least `n`
(reproduced). -/
lemma singleton_one_min_length {n : ℕ} (l : List (ZMod n))
    (h : IsBalanced ({1} : Frame n) l) : n ≤ l.length := by
  convert Nat.le_of_dvd ( List.length_pos_iff.mpr h.1 ) ( singleton_one_balanced_dvd l h )

/-! ## New results: the index is the exact fragment threshold -/

/-
**Exact threshold.** For a frame that admits at least one perfectly balanced
sequence (an *incoherent* frame), the width-`B` fragment is passed precisely when
the incoherence index strictly exceeds `B`.  Thus the index is the exact length
at which the bounded fragments begin to detect the incoherence.
-/
theorem coherentUpTo_iff_lt_incoherenceIndex {n : ℕ} (B : ℕ) (F : Frame n)
    (hne : (balancedLengths F).Nonempty) :
    CoherentUpTo B F ↔ B < incoherenceIndex F := by
  unfold CoherentUpTo;
  constructor <;> intro h;
  · exact lt_of_not_ge fun h' => h <| by rcases Nat.sInf_mem hne with ⟨ l, hl₁, hl₂ ⟩ ; exact ⟨ l, hl₁, hl₂ ▸ h' ⟩ ;
  · contrapose! h;
    exact le_trans ( Nat.sInf_le ⟨ _, h.choose_spec.1, rfl ⟩ ) h.choose_spec.2

/-
**Strict refinement.** For every `B` there is a *maximal* standard frame that
passes the width-`B` fragment but fails the width-`(B+1)` fragment.  Hence each
successive fragment is strictly stronger and the hierarchy never collapses.
-/
theorem fragment_strictly_refines (B : ℕ) :
    ∃ (n : ℕ) (F : Frame n), IsMaximal F ∧ CoherentUpTo B F ∧ ¬ CoherentUpTo (B + 1) F := by
  refine' ⟨ B + 1, { 1 }, _, _, _ ⟩ <;> simp +decide [ IsMaximal, CoherentUpTo ];
  · convert isMaximal_singleton_one ( B + 1 );
    unfold IsMaximal; aesop;
  · intro l hl; have := singleton_one_min_length l hl; aesop;
  · refine' ⟨ List.replicate ( B + 1 ) 1, _, _ ⟩ <;> simp +decide [ IsBalanced ]

end SocialChoice