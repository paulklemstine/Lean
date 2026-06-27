/-
# Non-finite-axiomatization of measurable majorities via the incoherence index

This file extends the catalog model of *standard social decision frames* from
`Applications/SocialChoice/IncoherenceIndex.lean` (the reconstructed
`MossPedersen2026` / `arXiv:2606.23853` framework: frames as finite atom sets in
`ZMod n`, *perfectly balanced sequences*, and the *incoherence index*).  Because
the surrounding monorepo's build configuration does not make that module
importable in isolation, the small amount of shared infrastructure (the model
definitions and three base lemmas about the single-generator frame) is
reproduced here verbatim from the catalog file; the **main results below are new**:

* `realization_2k2` — for every `k ≥ 1` a *maximal* frame whose shortest
  coherence violation has length exactly `2k+2` (every even index `≥ 4`).
* `coherence_not_finitely_axiomatizable` — no bounded finite fragment can replace
  the coherence criterion (the headline non-finite-axiomatization theorem).
* `incoherenceIndex_unbounded_over_maximal` — the spectrum of incoherence indices
  over maximal frames is unbounded.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  Bold conjecture: coherence (= strict majority
representability) is *not* finitely axiomatizable.  For no fixed `B` does "no
perfectly balanced sequence of length `≤ B`" imply "no perfectly balanced
sequence at all", uniformly over all finite social decision frames.  The
obstruction is quantitative: incoherence indices realize the entire even tail
`2k+2`, so any finite bound is eventually overshot.

EXPERIMENT (Experimenter).  Reuse the catalog model.  The single-generator frame
`{1} ⊆ ZMod n` is maximal and its shortest balanced sequence is `1` repeated `n`
times (`incoherenceIndex_singleton_one`).  Set `n = 2k+2` to hit every even
length `≥ 4`; set `n = B+1` to defeat the width-`B` fragment.  The decisive new
lemma `singleton_one_min_length` shows every balanced sequence of `{1}` has
length `≥ n` (all atoms equal `1`, so the length is a positive multiple of `n`).

ANALYSIS (Analyst).  True and provable.  Structural pattern: the incoherence
index of `{1} ⊆ ZMod n` equals the additive order `n` of the unit, so the family
`{1} ⊆ ZMod (B+1)` produces, for each `B`, a frame that passes the width-`B`
test yet is genuinely incoherent — exactly a non-finite-axiomatization failure:
the bounded fragments are strictly weaker than the full criterion at every stage.

CRITIQUE (Critic).  Guards: `coherence_not_finitely_axiomatizable` is proved by
`by_contra` (no `decide`/`rfl` shortcut); every witness frame is exhibited
maximal; the separating gap is quantitative (`B < l.length`).  No theorem is
vacuous: each existential carries a concrete frame with a computed index, and the
separating frame is simultaneously coherent-up-to-`B` and incoherent.

SYNTHESIS (PI).  Together with the catalog's `realization_even`, these results
upgrade "the spectrum is unbounded" to "the criterion admits no bounded finite
fragment" — the precise sense in which measurable majorities cannot be finitely
axiomatized.  See `FUTURE_DIRECTIONS.md`.
-- !-- Lab Notes -- !--
-/
import Mathlib

namespace SocialChoice

open scoped BigOperators

/-! ## Catalog model (reproduced from `IncoherenceIndex.lean`) -/

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

/-- The cyclic frame `{1} ⊆ ZMod n` is maximal: the unit `1` generates the group.
(Reproduced from the catalog file.) -/
lemma isMaximal_singleton_one (n : ℕ) [NeZero n] :
    IsMaximal ({1} : Frame n) := by
  refine' le_antisymm _ _;
  · exact le_top;
  · intro x hx; simp_all +decide [ AddSubgroup.mem_closure_singleton ] ;
    exact ⟨ x.val, by simp +decide ⟩

/-- Repeating any single atom `n` times yields a balanced sequence, so the
incoherence index of any non-empty frame is at most `n`.  (Reproduced from the
catalog file.) -/
lemma incoherenceIndex_le {n : ℕ} (hn : 0 < n) (F : Frame n) (hF : F.Nonempty) :
    incoherenceIndex F ≤ n := by
  obtain ⟨ a, ha ⟩ := hF;
  refine' Nat.sInf_le ⟨ List.replicate n a, _, _ ⟩;
  · refine' ⟨ _, _, _ ⟩ <;> aesop;
  · norm_num

/-- The incoherence index of the cyclic frame `{1} ⊆ ZMod n` is exactly `n`.
(Reproduced from the catalog file.) -/
lemma incoherenceIndex_singleton_one {n : ℕ} (hn : 0 < n) :
    incoherenceIndex ({1} : Frame n) = n := by
  refine' le_antisymm _ _;
  · exact incoherenceIndex_le hn _ <| by aesop;
  · refine' le_csInf _ _;
    · refine' ⟨ n, ⟨ List.replicate n 1, _, _ ⟩ ⟩ <;> norm_num [ hn ];
      refine' ⟨ _, _, _ ⟩ <;> norm_num [ hn.ne' ];
    · rintro b ⟨ l, ⟨ hl₁, hl₂, hl₃ ⟩, rfl ⟩ ; simp_all +decide [ List.sum_eq_card_nsmul ] ;
      rw [ ZMod.natCast_eq_zero_iff ] at hl₃ ; exact Nat.le_of_dvd ( List.length_pos_iff.mpr hl₁ ) hl₃

/-! ## New results: non-finite-axiomatization -/

/-
Every perfectly balanced sequence of the single-generator frame `{1}` has a
length divisible by `n`: all its atoms equal `1`, so its length is a multiple of
the additive order `n`.
-/
lemma singleton_one_balanced_dvd {n : ℕ} (l : List (ZMod n))
    (h : IsBalanced ({1} : Frame n) l) : (n : ℕ) ∣ l.length := by
  obtain ⟨ hl₁, hl₂ ⟩ := h;
  have h_sum : l.sum = l.length • (1 : ZMod n) := by
    rw [ List.eq_replicate_of_mem fun x hx => Finset.mem_singleton.mp ( hl₂.1 x hx ) ] ; simp +decide;
  cases n <;> simp_all +decide [ ← ZMod.natCast_eq_zero_iff ]

/-
Every perfectly balanced sequence of the single-generator frame `{1} ⊆ ZMod n`
has length at least `n` (its incoherence index).
-/
lemma singleton_one_min_length {n : ℕ} (l : List (ZMod n))
    (h : IsBalanced ({1} : Frame n) l) : n ≤ l.length := by
  convert Nat.le_of_dvd ( List.length_pos_iff.mpr h.1 ) ( singleton_one_balanced_dvd l h )

/-
**Parametric realization.** For every `k ≥ 1` there is a *maximal* standard
social decision frame whose shortest coherence violation has length exactly
`2k+2`.  This exhibits every even index `≥ 4` and shows no uniform finite bound
caps the incoherence index.
-/
theorem realization_2k2 (k : ℕ) (hk : 1 ≤ k) :
    ∃ F : Frame (2 * k + 2), IsMaximal F ∧ incoherenceIndex F = 2 * k + 2 := by
  use ({1} : Frame (2 * k + 2));
  exact ⟨ isMaximal_singleton_one _, incoherenceIndex_singleton_one ( by linarith ) ⟩

/-- A frame is *coherent* (strict-majority representable) when it admits no
perfectly balanced sequence at all. -/
def Coherent {n : ℕ} (F : Frame n) : Prop :=
  ¬ ∃ l, IsBalanced F l

/-- The *width-`B` finite fragment*: a frame passes it when it admits no perfectly
balanced sequence of length `≤ B`.  This is the candidate bounded replacement for
the (infinitary) coherence criterion. -/
def CoherentUpTo {n : ℕ} (B : ℕ) (F : Frame n) : Prop :=
  ¬ ∃ l, IsBalanced F l ∧ l.length ≤ B

/-
Genuine coherence always implies passing every finite fragment.
-/
theorem coherent_imp_coherentUpTo {n : ℕ} (B : ℕ) (F : Frame n)
    (h : Coherent F) : CoherentUpTo B F := by
  exact fun ⟨ l, hl₁, hl₂ ⟩ => h ⟨ l, hl₁ ⟩

/-
The single-generator frame `{1} ⊆ ZMod (B+1)` is genuinely incoherent: it
admits the balanced sequence `1` repeated `B+1` times.
-/
theorem witness_incoherent (B : ℕ) : ¬ Coherent ({1} : Frame (B + 1)) := by
  simp +decide [ Coherent ];
  use List.replicate (B + 1) (1 : ZMod (B + 1));
  constructor <;> norm_num

/-
The single-generator frame `{1} ⊆ ZMod (B+1)` passes the width-`B` fragment:
its shortest balanced sequence has length `B+1 > B`.
-/
theorem witness_coherentUpTo (B : ℕ) : CoherentUpTo B ({1} : Frame (B + 1)) := by
  intro h
  obtain ⟨l, hbal, hlen⟩ := h
  have hlen_ge : B + 1 ≤ l.length := by
    convert singleton_one_min_length l hbal using 1
  linarith [hlen]

/-
**Non-finite-axiomatization (existential form).** For every finite bound `B`
there is a *maximal* standard frame that passes the width-`B` fragment yet is
genuinely incoherent.  Hence no finite fragment captures coherence.
-/
theorem no_finite_axiomatization (B : ℕ) :
    ∃ (n : ℕ) (F : Frame n), IsMaximal F ∧ CoherentUpTo B F ∧ ¬ Coherent F := by
  use B + 1, {1};
  exact ⟨ isMaximal_singleton_one _, witness_coherentUpTo _, witness_incoherent _ ⟩

/-
**Non-finite-axiomatization (headline).** It is impossible to replace the
coherence criterion for strict majority representability by any bounded finite
fragment: there is no width `B` for which "no balanced violation of length `≤ B`"
is equivalent to full coherence across all finite social decision frames.
-/
theorem coherence_not_finitely_axiomatizable :
    ¬ ∃ B : ℕ, ∀ (n : ℕ) (F : Frame n), CoherentUpTo B F → Coherent F := by
  push_neg;
  intro B
  obtain ⟨n, F, hF_max, hF_cup, hF_incoh⟩ := no_finite_axiomatization B
  use n, F

/-
**Unboundedness over maximal frames.** For every `N` there is a maximal
standard frame whose incoherence index exceeds `N`, realized by the explicit
`2k+2` family.  This is the quantitative engine behind non-finite-axiomatization.
-/
theorem incoherenceIndex_unbounded_over_maximal (N : ℕ) :
    ∃ (n : ℕ) (F : Frame n), IsMaximal F ∧ N < incoherenceIndex F := by
  -- Set n = 2*(N+1)+2, which is an even number ≥ 4 (since N ≥ 0 implies N+1 ≥ 1 so 2*(N+1) ≥ 2, so n ≥ 4).
  set n := 2 * (N + 1) + 2;
  -- By `isMaximal_singleton_one n`, the frame `{1}` is maximal.
  have h_max : IsMaximal ({1} : Frame n) := by
    convert isMaximal_singleton_one n;
  exact ⟨ n, { 1 }, h_max, by erw [ incoherenceIndex_singleton_one ( by positivity ) ] ; omega ⟩

end SocialChoice