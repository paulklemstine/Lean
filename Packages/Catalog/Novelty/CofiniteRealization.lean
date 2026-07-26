/-
# Cofinite realization of every even incoherence index by maximal standard frames

This file refines the catalog result `IncoherenceIndex.realization_even`
(`Catalog/Applications/SocialChoice/IncoherenceIndex.lean`), which realizes the
incoherence index `n` on `n` social states by the *single-generator* cyclic
frame.  Here we realize a *prescribed even* incoherence index `2*k+2` on a *large*
electorate of `2*n` voters, by a genuinely two-generator maximal standard frame.

The construction is the two-atom frame `{1, -(2*k+1)} ⊆ ZMod (2*n)`.  Its only
short perfectly balanced sequence is `(2*k+1)` copies of `1` together with one
copy of `-(2*k+1)`, of length `2*k+2`; no shorter balanced sequence exists once
the electorate is large enough, namely once `(2*k+1)^2 < 2*n`.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  v19d conjecture: for every `k ≥ 1` and every
`n ≥ 2*k+1`, some maximal standard frame on `2*n` voters has incoherence index
exactly `2*k+2` (filling the sparse sizes of the geometric construction).

EXPERIMENT (Experimenter).  Model frames in `ZMod (2*n)` exactly as the catalog
file.  Computational search (`ComputationalEvidence.md`) over the two-atom family
`{1, 2*n-(2*k+1)}` shows index `= 2*k+2` for *every* even electorate with
`(2*k+1)^2 < 2*n`, but the *literal* threshold `n ≥ 2*k+1` is FALSE at the
boundary (see `BoundaryObstruction.lean`).  The honest, provable statement is the
**cofinite** one: realization holds for all sufficiently large electorates.

ANALYSIS (Analyst).  Counting atoms: a balanced list with `q` copies of
`b = -(2*k+1)` and `length-q` copies of `1` has sum `length - q*(2*k+2)` in
`ZMod (2*n)`.  Vanishing forces `2*n ∣ (length - q*(2*k+2))` over `ℤ`.  The
quantity `q*(2*k+2) - length` lies in `[1, (2*k+1)^2)` whenever `0 < length ≤
2*k+1` and `q ≤ length`, so it cannot be a nonzero multiple of `2*n > (2*k+1)^2` —
hence `length ≥ 2*k+2`.  The witness `(2*k+1)•1 + 1•b` attains `2*k+2`.

CRITIQUE (Critic).  Maximality is genuine (`1` is a unit, atoms generate `⊤`);
the index equality is by antisymmetry (`le_antisymm`), the lower bound uses the
arithmetic obstruction above (`omega`/`nlinarith`), not `decide`.  The evenness of
the index `2*k+2` is automatic from the value; the threshold `(2*k+1)^2 < 2*n` is
explicit and shown necessary in the companion file.

SYNTHESIS (PI).  `incoherenceIndex_coFrame` and its packaged form
`cofinite_realization` give the corrected, fully-proved cofinite realization
theorem.  See `FUTURE_DIRECTIONS.md`.
-- !-- Lab Notes -- !--
-/
import Mathlib

namespace SocialChoice.Cofinite

open scoped BigOperators

/-- A *standard social decision frame* on `N` voters (reproduced from the catalog
model `IncoherenceIndex.lean`). -/
abbrev Frame (N : ℕ) := Finset (ZMod N)

/-- A *perfectly balanced sequence* for a frame `F`. -/
def IsBalanced {N : ℕ} (F : Frame N) (l : List (ZMod N)) : Prop :=
  l ≠ [] ∧ (∀ x ∈ l, x ∈ F) ∧ l.sum = 0

/-- The set of lengths of perfectly balanced sequences of `F`. -/
def balancedLengths {N : ℕ} (F : Frame N) : Set ℕ :=
  { k | ∃ l, IsBalanced F l ∧ l.length = k }

/-- The *incoherence index*: the length of the shortest perfectly balanced
sequence (`0` if none exists). -/
noncomputable def incoherenceIndex {N : ℕ} (F : Frame N) : ℕ :=
  sInf (balancedLengths F)

/-- A frame is *maximal* when its atoms generate the whole decision space. -/
def IsMaximal {N : ℕ} (F : Frame N) : Prop :=
  AddSubgroup.closure (F : Set (ZMod N)) = ⊤

/-- The two-atom standard frame realizing index `2*k+2` on `N` voters. -/
def coFrame (N k : ℕ) : Frame N := {1, -(2 * k + 1 : ZMod N)}

/-! ### Maximality -/

/-
The two-atom frame is maximal: the unit `1` already generates `ZMod N`.
-/
lemma isMaximal_coFrame (N k : ℕ) [NeZero N] : IsMaximal (coFrame N k) := by
  refine' le_antisymm ( le_top ) _;
  intro s hs
  simp at hs;
  convert AddSubgroup.zsmul_mem _ ( AddSubgroup.subset_closure <| show 1 ∈ ( coFrame N k : Set ( ZMod N ) ) from ?_ ) s.val using 1 ; aesop;
  simp +decide [ coFrame ]

/-! ### Atom-counting identity -/

/-
Counting identity.  Any list whose entries are atoms of `coFrame N k` (i.e.
each is `1` or `b = -(2*k+1)`) has sum `length - q*(2*k+2)` in `ZMod N`, where `q`
is the number of `b`-entries; in particular `q ≤ length`.
-/
lemma coFrame_sum_count {N k : ℕ} (l : List (ZMod N))
    (hl : ∀ x ∈ l, x = 1 ∨ x = -(2 * k + 1 : ZMod N)) :
    ∃ q, q ≤ l.length ∧
      l.sum = (l.length : ZMod N) - (q : ZMod N) * (2 * k + 2) := by
  induction' l with x l ih;
  · exact ⟨ 0, by norm_num ⟩;
  · rcases ih fun y hy => hl y <| List.mem_cons_of_mem _ hy with ⟨ q, hq₁, hq₂ ⟩ ; rcases hl x <| List.mem_cons_self with rfl | rfl <;> simp_all +decide;
    · exact ⟨ q, by linarith, by ring ⟩;
    · exact ⟨ q + 1, by linarith, by push_cast; ring ⟩

/-! ### Lower bound: no short balanced sequence -/

/-
Lower bound.  When `(2*k+1)^2 < N`, every perfectly balanced sequence of
`coFrame N k` has length at least `2*k+2`.
-/
lemma coFrame_balanced_length_ge {N k : ℕ} (hN : (2 * k + 1) ^ 2 < N)
    (l : List (ZMod N)) (hl : IsBalanced (coFrame N k) l) :
    2 * k + 2 ≤ l.length := by
  obtain ⟨q, hq⟩ : ∃ q : ℕ, q ≤ l.length ∧ l.sum = (l.length : ZMod N) - (q : ZMod N) * (2 * k + 2) := by
    convert coFrame_sum_count l _;
    intro x hx; have := hl.2.1 x hx; unfold coFrame at this; aesop;
  have h_div : (N : ℤ) ∣ ((l.length : ℤ) - (q : ℤ)*(2*k+2)) := by
    convert ( by simpa [ ← ZMod.intCast_zmod_eq_zero_iff_dvd, hq.2 ] using hl.2.2 ) using 1;
    erw [ ← ZMod.intCast_zmod_eq_zero_iff_dvd ] ; aesop;
  obtain ⟨ m, hm ⟩ := h_div;
  by_cases hm_zero : m = 0;
  · by_cases hq_zero : q = 0 <;> simp_all +decide [ sub_eq_iff_eq_add ];
    · cases hl.1 rfl;
    · nlinarith [ Nat.pos_of_ne_zero hq_zero ];
  · rcases lt_trichotomy m 0 with hm_neg | rfl | hm_pos <;> norm_num at *;
    · nlinarith [ show q ≤ l.length from hq.1, show ( 2 * k + 1 ) ^ 2 < N from hN ];
    · nlinarith [ show q * ( 2 * k + 2 ) ≥ 0 by positivity ]

/-! ### Upper bound: an explicit balanced sequence of length `2*k+2` -/

/-- The explicit balanced sequence: `2*k+1` copies of `1` followed by one copy of
`b = -(2*k+1)`. -/
def coWitness (N k : ℕ) : List (ZMod N) :=
  List.replicate (2 * k + 1) (1 : ZMod N) ++ [-(2 * k + 1 : ZMod N)]

lemma coWitness_isBalanced (N k : ℕ) :
    IsBalanced (coFrame N k) (coWitness N k) := by
  constructor <;> simp_all +decide [ coFrame, coWitness ];
  ring

lemma coWitness_length (N k : ℕ) : (coWitness N k).length = 2 * k + 2 := by
  simp +arith +decide [ coWitness ]

/-! ### Main theorem -/

/-- **Cofinite realization.**  For every `k ≥ 1` and every electorate `N` with
`(2*k+1)^2 < N`, the maximal standard frame `coFrame N k` has incoherence index
exactly `2*k+2`.  Thus every even index `2*k+2` is realized by a maximal frame on
all sufficiently large electorates. -/
theorem incoherenceIndex_coFrame {N k : ℕ} [NeZero N] (hN : (2 * k + 1) ^ 2 < N) :
    incoherenceIndex (coFrame N k) = 2 * k + 2 := by
  have hmem : (2 * k + 2) ∈ balancedLengths (coFrame N k) :=
    ⟨coWitness N k, coWitness_isBalanced N k, coWitness_length N k⟩
  refine le_antisymm (Nat.sInf_le hmem) ?_
  refine le_csInf ⟨_, hmem⟩ ?_
  rintro b ⟨l, hl, rfl⟩
  exact coFrame_balanced_length_ge hN l hl

/-- **Cofinite realization, packaged on `2*n` voters.**  For every `k ≥ 1` and
every half-size `n` with `2*k^2 + 2*k + 1 ≤ n`, there is a maximal standard frame
on exactly `2*n` voters whose incoherence index is exactly `2*k+2`. -/
theorem cofinite_realization (k n : ℕ) (hk : 1 ≤ k) (hn : 2 * k ^ 2 + 2 * k + 1 ≤ n) :
    ∃ F : Frame (2 * n), IsMaximal F ∧ incoherenceIndex F = 2 * k + 2 := by
  have hNpos : 0 < 2 * n := by omega
  haveI : NeZero (2 * n) := ⟨by omega⟩
  have hN : (2 * k + 1) ^ 2 < 2 * n := by nlinarith [hn]
  exact ⟨coFrame (2 * n) k, isMaximal_coFrame (2 * n) k, incoherenceIndex_coFrame hN⟩

end SocialChoice.Cofinite