import Mathlib

/-!
# The Library of Babel: combinatorial and probabilistic structure

This file formalizes the exact combinatorial and probabilistic structure of Borges'
*Library of Babel*.

A **volume** of length `L` over an alphabet of `b` symbols is a function
`Fin L → Fin b`.  The **library** is the (finite) collection of *all* such volumes.
We equip the library with the uniform probability measure (encoded directly as the
counting ratio `ProbabilityTheory.prob`).

Main results:

* `card_library` : the library contains exactly `b ^ L` volumes.
* `prob_singleton` : every individual volume has probability `b ^ (-L)`.
* `expected_substring_count` : the expected number of occurrences of a fixed
  pattern of length `k` in a uniformly random volume is `(L - k + 1) * b ^ (-k)`.
  (For this statement to be meaningful the probability space must be nonempty, i.e.
  `0 < b`; when `b = 0` the library is empty and the expectation is undefined.)
* `prob_contains_substring_bound` : the probability that a random volume contains a
  fixed pattern is at most `(L - k + 1) * b ^ (-k)` (a union bound).

All edge cases (`b = 0`, `b = 1`, `L = 0`, `k = 0`) are handled.
-/

open Finset

namespace LibraryOfBabel

/-- A volume of length `L` over an alphabet with `b` symbols. -/
abbrev Volume (b L : ℕ) := Fin L → Fin b

/-- The library of all volumes of length `L` over `b` symbols. -/
def Library (b L : ℕ) : Finset (Volume b L) := Finset.univ

/-- The Library of Babel contains exactly `b ^ L` volumes. -/
theorem card_library (b L : ℕ) : (Library b L).card = b ^ L := by
  simp [Library, Volume]

open scoped Classical in
/-- The uniform probability of an event `A` inside the finite sample space `s`:
the fraction of points of `s` lying in `A`.  For `s = Library b L` this is the
uniform probability measure on the library. -/
noncomputable def _root_.ProbabilityTheory.prob {α : Type*} [Fintype α]
    (s : Finset α) (A : Set α) : ℝ :=
  ((s.filter (fun x => x ∈ A)).card : ℝ) / (s.card : ℝ)

/-- Read the symbol at position `n` of a volume, returning `none` if out of range. -/
def readAt {b L : ℕ} (v : Volume b L) (n : ℕ) : Option (Fin b) :=
  if h : n < L then some (v ⟨n, h⟩) else none

/-- The pattern `pattern` occurs in volume `v` starting at position `i`. -/
def OccursAt {b L k : ℕ} (pattern : Fin k → Fin b) (v : Volume b L) (i : ℕ) : Prop :=
  ∀ j : Fin k, readAt v (i + j) = some (pattern j)

instance {b L k : ℕ} (pattern : Fin k → Fin b) (v : Volume b L) (i : ℕ) :
    Decidable (OccursAt pattern v i) := by unfold OccursAt; infer_instance

/-- The number of starting positions at which `pattern` occurs in `v`. -/
def occurrenceCount {b L k : ℕ} (pattern : Fin k → Fin b) (v : Volume b L) : ℕ :=
  ((Finset.range (L - k + 1)).filter (fun i => OccursAt pattern v i)).card

/-- The pattern `pattern` appears somewhere in the volume `v`. -/
def Contains {b L k : ℕ} (pattern : Fin k → Fin b) (v : Volume b L) : Prop :=
  ∃ i : ℕ, OccursAt pattern v i

/-- The expected number of occurrences of `pattern` in a uniformly random volume. -/
noncomputable def expectedOccurrences {b k : ℕ} (pattern : Fin k → Fin b) (L : ℕ) : ℝ :=
  (∑ v : Volume b L, (occurrenceCount pattern v : ℝ)) / ((Library b L).card : ℝ)

/-! ### Counting lemmas -/

/-- The number of functions `α → β` that agree with a fixed function `g` on every
point satisfying a predicate `p` equals `(card β) ^ (number of points with ¬ p)`. -/
theorem card_filter_agree {α β : Type*} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]
    (p : α → Prop) [DecidablePred p] (g : α → β) :
    (Finset.univ.filter (fun v : α → β => ∀ a, p a → v a = g a)).card
      = (Fintype.card β) ^ (Finset.univ.filter (fun a => ¬ p a)).card := by
  have heq : (Finset.univ.filter (fun v : α → β => ∀ a, p a → v a = g a))
      = Fintype.piFinset (fun a => if p a then {g a} else Finset.univ) := by
    ext v
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Fintype.mem_piFinset]
    constructor
    · intro h a
      by_cases hp : p a
      · simp [hp, h a hp]
      · simp [hp]
    · intro h a hp
      have := h a; simp [hp] at this; exact this
  rw [heq, Fintype.card_piFinset, Finset.card_filter, ← Finset.prod_pow_eq_pow_sum]
  apply Finset.prod_congr rfl
  intro i _
  by_cases hp : p i <;> simp [hp]

/-- The number of volumes of length `L` agreeing with a fixed pattern along an
injective family of `k` positions equals `b ^ (L - k)`. -/
theorem card_agree_inj {b L k : ℕ} (φ : Fin k → Fin L) (hφ : Function.Injective φ)
    (pattern : Fin k → Fin b) :
    (Finset.univ.filter (fun v : Volume b L => ∀ j, v (φ j) = pattern j)).card = b ^ (L - k) := by
  by_cases hb : b = 0;
  · cases k <;> simp_all +decide;
    cases pattern 0 ; aesop;
  · convert card_filter_agree ( fun i => i ∈ Set.range φ ) ( fun i => if h : ∃ j, φ j = i then pattern h.choose else ⟨ 0, Nat.pos_of_ne_zero hb ⟩ ) using 1;
    · congr with v ; simp +decide [ hφ.eq_iff ];
    · rw [ Finset.filter_not, Finset.card_sdiff ] ; norm_num [ Finset.card_univ, Finset.card_range, hφ ];
      rw [ show ( filter ( Membership.mem ( Set.range φ ) ) Finset.univ : Finset ( Fin L ) ) = Finset.image φ Finset.univ by ext; aesop, Finset.card_image_of_injective _ hφ, Finset.card_fin ]

/-- The number of volumes in which `pattern` occurs at a fixed valid position `i`
(`i + k ≤ L`) is `b ^ (L - k)`. -/
theorem card_occursAt {b L k : ℕ} (pattern : Fin k → Fin b) (i : ℕ) (hi : i + k ≤ L) :
    (Finset.univ.filter (fun v : Volume b L => OccursAt pattern v i)).card = b ^ (L - k) := by
  convert card_agree_inj ( fun j => ⟨ i + j, by linarith [ Fin.is_lt j ] ⟩ ) ?_ pattern;
  · unfold OccursAt;
    simp +decide [ readAt ];
    exact ⟨ fun h j => h j |>.2, fun h j => ⟨ by linarith [ Fin.is_lt j ], h j ⟩ ⟩;
  · exact fun a b h => by simpa [ Fin.ext_iff ] using h;

/-! ### Main theorems -/

/-- Every single volume has uniform probability `b ^ (-L)`. -/
theorem prob_singleton (b L : ℕ) (v : Volume b L) :
    ProbabilityTheory.prob (Library b L) ({v} : Set (Volume b L)) = (b : ℝ) ^ (-(L : ℤ)) := by
  unfold ProbabilityTheory.prob;
  simp +decide [ Library, Finset.card_univ ];
  rw [ Finset.card_filter ] ; aesop

/-- The expected number of occurrences of a fixed pattern of length `k` in a
uniformly random volume of length `L` (with `k ≤ L`) is `(L - k + 1) * b ^ (-k)`.
Requires `0 < b` so that the library is nonempty. -/
theorem expected_substring_count {b k : ℕ} (L : ℕ) (hk : k ≤ L) (hb : 0 < b)
    (pattern : Fin k → Fin b) :
    expectedOccurrences pattern L
      = ((L - k + 1 : ℕ) : ℝ) * (b : ℝ) ^ (-(k : ℤ)) := by
  -- First, note that the numerator of the expected value is the sum over all volumes of the number of times the pattern appears in each volume.
  have h_num : (∑ v : Volume b L, (occurrenceCount pattern v : ℝ)) = (L - k + 1) * (b : ℝ) ^ (L - k) := by
    -- By definition of occurrenceCount, we can rewrite the sum as the sum over all positions i in the range (L-k+1) of the number of volumes in which the pattern occurs at position i.
    have h_sum : (∑ v : Volume b L, (occurrenceCount pattern v : ℝ)) = ∑ i ∈ Finset.range (L - k + 1), (Finset.univ.filter (fun v : Volume b L => OccursAt pattern v i)).card := by
      simp +decide [ occurrenceCount ];
      simp +decide only [card_filter];
      exact mod_cast Finset.sum_comm;
    rw [ h_sum, Finset.sum_congr rfl fun i hi => card_occursAt pattern i <| by linarith [ Finset.mem_range.mp hi, Nat.sub_add_cancel hk ] ] ; aesop;
  simp_all +decide [ expectedOccurrences, card_library ];
  field_simp;
  rw [ mul_assoc, ← pow_add, Nat.sub_add_cancel hk ]

/-- Union bound: the probability that a random volume contains a fixed pattern of
length `k` (with `k ≤ L`) is at most `(L - k + 1) * b ^ (-k)`. -/
theorem prob_contains_substring_bound {b k : ℕ} (L : ℕ) (hk : k ≤ L)
    (pattern : Fin k → Fin b) :
    ProbabilityTheory.prob (Library b L) {v : Volume b L | Contains pattern v}
      ≤ ((L - k + 1 : ℕ) : ℝ) * (b : ℝ) ^ (-(k : ℤ)) := by
  by_cases hb : 0 < b;
  · convert div_le_div_of_nonneg_right ( show ( Finset.univ.filter ( fun v : Volume b L => Contains pattern v ) |> Finset.card : ℝ ) ≤ ( L - k + 1 ) * b ^ ( L - k ) from ?_ ) ( by positivity : ( 0 : ℝ ) ≤ ( b ^ L : ℝ ) ) using 1;
    unfold ProbabilityTheory.prob Library; norm_num [ card_library ] ;
    convert rfl;
    · rw [ eq_div_iff (by positivity), zpow_neg, zpow_natCast,
        show (b : ℝ) ^ L = b ^ (L - k) * b ^ k by rw [← pow_add, Nat.sub_add_cancel hk] ]
      have hbk : (b : ℝ) ^ k ≠ 0 := by positivity
      rw [Nat.cast_add, Nat.cast_sub hk]
      field_simp
      ring
    · norm_cast;
      refine' le_trans ( Finset.card_le_card _ ) _;
      exact Finset.biUnion ( Finset.range ( L - k + 1 ) ) fun i => Finset.filter ( fun v => OccursAt pattern v i ) Finset.univ;
      · intro v hv; simp_all +decide [ Contains ] ;
        obtain ⟨ i, hi ⟩ := hv;
        by_cases hk0 : k = 0;
        · subst hk0; use 0; simp_all +decide [ OccursAt ] ;
        · have := hi ⟨ k - 1, Nat.sub_lt ( Nat.pos_of_ne_zero hk0 ) zero_lt_one ⟩ ; simp_all +decide [ readAt ] ;
          grind;
      · refine' le_trans ( Finset.card_biUnion_le ) _;
        exact le_trans ( Finset.sum_le_sum fun _ _ => show _ ≤ _ from card_occursAt pattern _ ( by linarith [ Finset.mem_range.mp ‹_›, Nat.sub_add_cancel hk ] ) |> le_of_eq ) ( by norm_num );
  · rcases k with ( _ | k ) <;> simp_all +decide;
    · refine' le_trans ( div_le_one_of_le₀ _ _ ) _ <;> norm_num;
      grind;
    · cases pattern ⟨ 0, Nat.succ_pos _ ⟩ ; aesop

end LibraryOfBabel