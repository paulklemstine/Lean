/-
# Tropical Morse Theory via Active-Set Transitions

This file formalizes a **non-smooth Morse theory for tropical sublevel filtrations**.
The central objects are:

* **Active-set complexes** at varying thresholds, forming a filtration
* **Pair-critical values** where two affine forms exchange dominance
* **Birth events** recording when new cells first appear in the filtration
* **Equality hyperplanes** providing a cross-domain bridge to arrangement theory

## Main results

* `activeSetComplexSub_mono` — the simplicial active-set complex grows monotonically
* `activeSetComplexSub_downward_closed` — the complex is closed under taking subsets
* `birth_witness_tropMax_eq` — at a strict birth, the witness achieves tropMax = c exactly
* `strictBirth_pair_imp_pairCritical` — births of ≥2-cells force pair-critical events
* `pairwiseGeneric_activeSet_card_le_two` — genericity bounds active set size
* `criticalValue_imp_exists_strictBirth` — critical values produce strict births (pigeonhole)
* `pairCritical_lies_on_eqHyperplane` — cross-domain bridge to hyperplane arrangements
* `face_in_complex_of_superface` — subfaces appear whenever superfaces do

## References

This theory connects tropical geometry (max-plus algebra) with discrete Morse theory
via the observation that topology changes in sublevel filtrations correspond to
pairwise dominance exchanges of affine forms, analogous to critical points in
smooth Morse theory but in a combinatorial, non-differentiable setting.
-/

import Mathlib
import Tropical.ArithmeticUniversality.Defs

open TropicalLoss

namespace TropicalMorse

variable {n : ℕ}

/-! ## Simplicial Active-Set Complex

The catalog defines `ActiveSetComplexSublevel` using equality: the exact active sets
realized at sublevel points. We define the **simplicial** version, closed under subsets,
which forms a genuine abstract simplicial complex. -/

/-- The simplicial active-set complex at threshold `c`: all subsets of
realized active sets at sublevel points. This is downward-closed by construction. -/
def ActiveSetComplexSub (F : TropicalAffineFamily n) (c : ℚ) : Set (Finset F.ι) :=
  {s | ∃ x : Fin n → ℚ, tropMax F x ≤ c ∧ s ⊆ ActiveSet F x}

/-! ## Key Definitions for Tropical Morse Theory -/

/-- A threshold `c` is **pair-critical** if two distinct affine forms
simultaneously achieve value `c` at some point where all forms are ≤ c.
This is the tropical analogue of a critical point in smooth Morse theory. -/
def IsPairCritical (F : TropicalAffineFamily n) (c : ℚ) : Prop :=
  ∃ x : Fin n → ℚ, ∃ i j : F.ι,
    i ≠ j ∧
    affineEval F i x = c ∧
    affineEval F j x = c ∧
    ∀ l : F.ι, affineEval F l x ≤ c

/-- A threshold `c` is a **critical value** if the active-set complex strictly
grows at `c`: for every ε > 0, some face is present at `c` but absent at `c - ε`. -/
def IsCriticalValue (F : TropicalAffineFamily n) (c : ℚ) : Prop :=
  ∀ ε : ℚ, ε > 0 → ∃ s, s ∈ ActiveSetComplexSub F c ∧ s ∉ ActiveSetComplexSub F (c - ε)

/-- A face `s` is **strictly born at threshold `c`** if `s` first appears in
the active-set complex exactly at `c`: it is present at `c` but absent
at every strictly lower threshold. -/
def StrictBirthsAt (F : TropicalAffineFamily n) (c : ℚ) (s : Finset F.ι) : Prop :=
  s ∈ ActiveSetComplexSub F c ∧ ∀ ε : ℚ, ε > 0 → s ∉ ActiveSetComplexSub F (c - ε)

/-- A face `s` is **(weakly) born at threshold `c`** if `s` is present at `c`
and absent at some strictly lower threshold. -/
def BirthsAt (F : TropicalAffineFamily n) (c : ℚ) (s : Finset F.ι) : Prop :=
  s ∈ ActiveSetComplexSub F c ∧ ∃ ε : ℚ, ε > 0 ∧ s ∉ ActiveSetComplexSub F (c - ε)

/-- A family is **pairwise generic** if no three distinct indices are
simultaneously active (i.e., no triple ties occur). -/
def PairwiseGeneric (F : TropicalAffineFamily n) : Prop :=
  ∀ x : Fin n → ℚ, ∀ i j l : F.ι,
    i ≠ j → j ≠ l → i ≠ l →
    ¬(affineEval F i x = affineEval F j x ∧ affineEval F j x = affineEval F l x)

/-- The **equality hyperplane** for a pair of indices: the locus where
two affine forms agree. This connects to classical hyperplane arrangement theory. -/
def EqHyperplane (F : TropicalAffineFamily n) (i j : F.ι) : Set (Fin n → ℚ) :=
  {x | affineEval F i x = affineEval F j x}

/-- A maximal face in the complex at threshold `c`. -/
def IsMaximalFaceAt (F : TropicalAffineFamily n) (c : ℚ) (s : Finset F.ι) : Prop :=
  s ∈ ActiveSetComplexSub F c ∧
  ∀ t, s ⊆ t → t ∈ ActiveSetComplexSub F c → t = s

/-- The first-birth preorder: `s` appears no later than `t`. -/
def FirstBirthLe (F : TropicalAffineFamily n) (s t : Finset F.ι) : Prop :=
  ∀ c : ℚ, t ∈ ActiveSetComplexSub F c → s ∈ ActiveSetComplexSub F c

/-! ## Structural Theorems -/

/-- **Monotonicity**: The simplicial active-set complex grows with the threshold.
Uses `sublevel_mono` from the catalog. -/
theorem activeSetComplexSub_mono (F : TropicalAffineFamily n) {c d : ℚ} (hcd : c ≤ d) :
    ActiveSetComplexSub F c ⊆ ActiveSetComplexSub F d := by
  intro s ⟨x, hx_sub, hx_act⟩
  exact ⟨x, le_trans hx_sub hcd, hx_act⟩

/-- **Downward closure**: The simplicial complex is closed under taking subfaces.
This is the key property making it an abstract simplicial complex. -/
theorem activeSetComplexSub_downward_closed (F : TropicalAffineFamily n) (c : ℚ)
    {s t : Finset F.ι} (hst : s ⊆ t) (ht : t ∈ ActiveSetComplexSub F c) :
    s ∈ ActiveSetComplexSub F c := by
  obtain ⟨x, hx_sub, hx_act⟩ := ht
  exact ⟨x, hx_sub, Finset.Subset.trans hst hx_act⟩

/-- **Subface persistence**: If a superface is in the complex, every subface is too.
Equivalently, subfaces appear no later than superfaces in the filtration. -/
theorem face_in_complex_of_superface (F : TropicalAffineFamily n) {c : ℚ}
    {s t : Finset F.ι} (hst : s ⊆ t) (ht : t ∈ ActiveSetComplexSub F c) :
    s ∈ ActiveSetComplexSub F c :=
  activeSetComplexSub_downward_closed F c hst ht

/-- **Birth monotonicity (filtration form)**: In the first-birth preorder,
subfaces always appear no later than superfaces. This is the tropical
analogue of "a face cannot be born before its boundary." -/
theorem firstBirthLe_of_subset (F : TropicalAffineFamily n)
    {s t : Finset F.ι} (hst : s ⊆ t) :
    FirstBirthLe F s t := by
  intro c ht_mem
  exact face_in_complex_of_superface F hst ht_mem

/-- **Face birth monotonicity**: If `t` is strictly born at `c` and `s ⊆ t`,
then `s` is in the complex at `c` (born at or before `c`). -/
theorem face_in_complex_at_birth (F : TropicalAffineFamily n)
    {s t : Finset F.ι} {c : ℚ} (hst : s ⊆ t) (ht : StrictBirthsAt F c t) :
    s ∈ ActiveSetComplexSub F c :=
  face_in_complex_of_superface F hst ht.1

/-- Active set membership characterization in terms of evaluation. -/
theorem activeSet_mem_iff_eval_eq (F : TropicalAffineFamily n)
    (x : Fin n → ℚ) (i : F.ι) :
    i ∈ ActiveSet F x ↔ affineEval F i x = tropMax F x :=
  mem_activeSet_iff F x i

/-- Every evaluation is bounded by the tropical max. -/
theorem eval_le_tropMax (F : TropicalAffineFamily n) (x : Fin n → ℚ) (i : F.ι) :
    affineEval F i x ≤ tropMax F x :=
  affineEval_le_tropMax F x i

/-- The sublevel membership is characterized by all evaluations being ≤ c. -/
theorem mem_sublevel_iff (F : TropicalAffineFamily n) (c : ℚ) (x : Fin n → ℚ) :
    x ∈ SublevelSet F c ↔ ∀ i : F.ι, affineEval F i x ≤ c :=
  mem_sublevel_iff_forall_le F c x

/-! ## Deep Theorem 1: Birth Witness Achieves Exact Threshold

At a strict birth, any witness point must achieve `tropMax = c` exactly.
This is the key lemma enabling the passage from births to pair-critical events.
The proof uses `by_contra` and the monotonicity of the complex. -/

/-
**Birth witness exactness**: If a face is strictly born at `c`, then
there exists a witness point achieving `tropMax = c` exactly. The proof proceeds
by contradiction: if `tropMax(x) < c` at the witness, the face would already
appear at a lower threshold, contradicting strict birth.
-/
theorem birth_witness_tropMax_eq (F : TropicalAffineFamily n)
    {c : ℚ} {s : Finset F.ι}
    (hbirth : StrictBirthsAt F c s) :
    ∃ x : Fin n → ℚ, tropMax F x = c ∧ s ⊆ ActiveSet F x := by
  -- From `StrictBirthsAt`, we know there exists a witness `x` such that `tropMax F x ≤ c` and `s ⊆ ActiveSet F x`.
  obtain ⟨x, hx⟩ := hbirth.left;
  by_cases h : tropMax F x = c <;> simp_all +decide [ StrictBirthsAt ];
  · use x;
  · exact False.elim <| hbirth.2 ( c - tropMax F x ) ( sub_pos.mpr <| lt_of_le_of_ne hx.1 h ) ⟨ x, by norm_num, hx.2 ⟩

/-! ## Deep Theorem 2: Births of Large Faces Imply Pair-Critical Events

This is the tropical analogue of "critical points have index ≥ 1": when a face
with ≥ 2 vertices is born, two affine forms must exchange dominance simultaneously.
The proof uses `rcases` to extract witnesses and structural reasoning about active sets. -/

/-
**Pair-critical extraction**: The strict birth of a face with at least two
elements forces a pair-critical event. Two active forms must simultaneously
achieve value `c`, creating the tropical analogue of a saddle point.
-/
theorem strictBirth_pair_imp_pairCritical (F : TropicalAffineFamily n)
    {c : ℚ} {s : Finset F.ι}
    (hbirth : StrictBirthsAt F c s)
    (hcard : 2 ≤ s.card) :
    IsPairCritical F c := by
  -- By birth_witness_tropMax_eq, there exists x such that tropMax F x = c and s ⊆ ActiveSet F x.
  obtain ⟨x, hx_tropMax, hx_active⟩ := birth_witness_tropMax_eq F hbirth
  generalize_proofs at *; (
  obtain ⟨ i, hi, j, hj, hij ⟩ := Finset.one_lt_card.mp hcard; use x; use i, j; simp_all +decide [ Finset.subset_iff ] ;
  exact ⟨ hx_tropMax ▸ activeSet_mem_iff_eval_eq F x i |>.1 ( hx_active hi ), hx_tropMax ▸ activeSet_mem_iff_eval_eq F x j |>.1 ( hx_active hj ), fun l => hx_tropMax ▸ eval_le_tropMax F x l ⟩)

/-! ## Deep Theorem 3: Genericity Bounds Active Set Size

Under the pairwise-generic condition (no triple ties), the active set at any
point has at most 2 elements. This is the key structural constraint that makes
tropical Morse theory tractable: topology changes are atomic. -/

/-
**Active set size bound**: Under genericity, at most two affine forms
can simultaneously achieve the maximum at any point. The proof proceeds by
contradiction: three active forms would create a triple tie.
-/
theorem pairwiseGeneric_activeSet_card_le_two (F : TropicalAffineFamily n)
    (hgen : PairwiseGeneric F) (x : Fin n → ℚ) :
    (ActiveSet F x).card ≤ 2 := by
  by_contra hgen;
  obtain ⟨i, j, k, hij, hjk, hik, h_eval⟩ : ∃ i j k : F.ι, i ≠ j ∧ j ≠ k ∧ i ≠ k ∧ affineEval F i x = tropMax F x ∧ affineEval F j x = tropMax F x ∧ affineEval F k x = tropMax F x := by
    obtain ⟨ s, hs ⟩ := Finset.two_lt_card.mp ( not_le.mp hgen );
    rcases hs with ⟨ hs₁, t, ht₁, u, hu₁, hst, hsu, htu ⟩ ; use s, t, u; simp_all +decide [ activeSet_mem_iff_eval_eq ] ;
  exact ‹PairwiseGeneric F› x i j k hij hjk hik ⟨ by linarith, by linarith ⟩

/-- Under genericity, the active set complex at any threshold consists of
faces of size ≤ 2 (vertices and edges of a graph). -/
theorem pairwiseGeneric_complex_face_card_le_two (F : TropicalAffineFamily n)
    (hgen : PairwiseGeneric F) (c : ℚ)
    {s : Finset F.ι} (hs : s ∈ ActiveSetComplexSub F c) :
    s.card ≤ 2 := by
  obtain ⟨x, _, hx_sub⟩ := hs
  exact le_trans (Finset.card_le_card hx_sub) (pairwiseGeneric_activeSet_card_le_two F hgen x)

/-! ## Deep Theorem 4: Critical Values Produce Strict Births (Pigeonhole)

This is the deepest structural theorem: every critical value witnesses a
strict birth event. The proof uses a finiteness/pigeonhole argument over
the (finite) powerset of indices. -/

/-
**Pigeonhole theorem**: Every critical value witnesses at least one
strict birth. The proof exploits finiteness of the face set: if the complex
grows for every ε > 0, some specific face must be responsible for
arbitrarily small perturbations, hence is strictly born at `c`.
-/
theorem criticalValue_imp_exists_strictBirth (F : TropicalAffineFamily n)
    {c : ℚ} (hcrit : IsCriticalValue F c) :
    ∃ s : Finset F.ι, StrictBirthsAt F c s := by
  by_contra! hict_births;
  -- By assumption, every face in complex(c) is persistent below c.
  have h_persistent_below : ∀ s : Finset F.ι, s ∈ ActiveSetComplexSub F c → ∃ ε > 0, s ∈ ActiveSetComplexSub F (c - ε) := by
    exact fun s hs => by_contradiction fun h => hict_births s ⟨ hs, fun ε hε => fun h' => h ⟨ ε, hε, h' ⟩ ⟩;
  -- Since there are only finitely many faces, there exists a minimum ε such that for all faces s in complex(c), s is in complex(c - ε).
  obtain ⟨ε, hε⟩ : ∃ ε > 0, ∀ s ∈ ActiveSetComplexSub F c, s ∈ ActiveSetComplexSub F (c - ε) := by
    choose! ε hε₁ hε₂ using h_persistent_below;
    -- Since there are only finitely many faces, we can take the minimum of all ε_s.
    obtain ⟨ε_min, hε_min⟩ : ∃ ε_min > 0, ∀ s ∈ ActiveSetComplexSub F c, ε_min ≤ ε s := by
      have h_finite : Set.Finite (ActiveSetComplexSub F c) := by
        exact Set.toFinite _;
      by_cases h_empty : ActiveSetComplexSub F c = ∅;
      · exact ⟨ 1, zero_lt_one, by simp +decide [ h_empty ] ⟩;
      · have := Finset.exists_min_image ( h_finite.toFinset ) ( fun s => ε s ) ⟨ Classical.choose ( Set.nonempty_iff_ne_empty.mpr h_empty ), h_finite.mem_toFinset.mpr ( Classical.choose_spec ( Set.nonempty_iff_ne_empty.mpr h_empty ) ) ⟩ ; aesop;
    exact ⟨ ε_min, hε_min.1, fun s hs => activeSetComplexSub_mono F ( by linarith [ hε_min.2 s hs ] ) ( hε₂ s hs ) ⟩;
  exact absurd ( hcrit ε hε.1 ) ( by tauto )

/-! ## Cross-Domain Bridge: Hyperplane Arrangement Theory

Pair-critical events correspond to points on classical equality hyperplanes.
This theorem establishes the formal connection between tropical Morse theory
and classical hyperplane arrangement geometry. -/

/-- **Cross-domain bridge theorem**: Every pair-critical event is witnessed by
a point lying on an equality hyperplane of the associated arrangement.
This connects tropical critical values to classical arrangement geometry:
the critical spectrum is controlled by the intersection pattern of
equality hyperplanes `{x | f_i(x) = f_j(x)}`. -/
theorem pairCritical_lies_on_eqHyperplane (F : TropicalAffineFamily n)
    {c : ℚ} (hc : IsPairCritical F c) :
    ∃ i j : F.ι, ∃ x : Fin n → ℚ,
      i ≠ j ∧
      x ∈ EqHyperplane F i j ∧
      affineEval F i x = c ∧
      ∀ l : F.ι, affineEval F l x ≤ c := by
  obtain ⟨x, i, j, hij, hi_eq, hj_eq, hall⟩ := hc
  exact ⟨i, j, x, hij, show affineEval F i x = affineEval F j x from hi_eq.trans hj_eq.symm,
    hi_eq, hall⟩

/-- **Hyperplane containment**: If `i` and `j` are both active at a point `x`,
then `x` lies on the equality hyperplane for `(i, j)`. -/
theorem active_pair_on_eqHyperplane (F : TropicalAffineFamily n)
    {x : Fin n → ℚ} {i j : F.ι}
    (hi : i ∈ ActiveSet F x) (hj : j ∈ ActiveSet F x) :
    x ∈ EqHyperplane F i j := by
  rw [activeSet_mem_iff_eval_eq] at hi hj
  show affineEval F i x = affineEval F j x
  exact hi.trans hj.symm

/-! ## Critical Value Counting -/

/-- The pair-event set collects all thresholds `c` at which a specific pair
`(i, j)` of affine forms can simultaneously achieve value `c` while all
other forms remain ≤ `c`. -/
def PairEventSet (F : TropicalAffineFamily n) (i j : F.ι) : Set ℚ :=
  {c | ∃ x : Fin n → ℚ, affineEval F i x = c ∧ affineEval F j x = c ∧
    ∀ l : F.ι, affineEval F l x ≤ c}

/-- **Soundness of pair enumeration**: Every pair-critical value belongs to
some pair-event set. -/
theorem pairCritical_in_pairEventSet (F : TropicalAffineFamily n)
    {c : ℚ} (hc : IsPairCritical F c) :
    ∃ i j : F.ι, i ≠ j ∧ c ∈ PairEventSet F i j := by
  obtain ⟨x, i, j, hij, hi, hj, hall⟩ := hc
  exact ⟨i, j, hij, x, hi, hj, hall⟩

/-- The full pair spectrum: union of all pair-event sets. -/
def PairSpectrum (F : TropicalAffineFamily n) : Set ℚ :=
  ⋃ (i : F.ι) (j : F.ι), PairEventSet F i j

/-- **Completeness**: Every pair-critical value lies in the pair spectrum. -/
theorem pairCritical_subset_spectrum (F : TropicalAffineFamily n)
    {c : ℚ} (hc : IsPairCritical F c) :
    c ∈ PairSpectrum F := by
  obtain ⟨i, j, _, hc_mem⟩ := pairCritical_in_pairEventSet F hc
  exact Set.mem_iUnion₂.mpr ⟨i, j, hc_mem⟩

/-! ## Strict Birth and Weak Birth Relationship -/

/-- Strict birth implies weak birth. -/
theorem strictBirthsAt_imp_birthsAt (F : TropicalAffineFamily n)
    {c : ℚ} {s : Finset F.ι}
    (h : StrictBirthsAt F c s) : BirthsAt F c s :=
  ⟨h.1, 1, one_pos, h.2 1 one_pos⟩

/-- **Weak birth pair-critical**: The weak birth of a face with ≥ 2 elements
also forces pair-critical events, but the critical value may be at or below `c`. -/
theorem birthsAt_pair_imp_pairCritical_le (F : TropicalAffineFamily n)
    {c : ℚ} {s : Finset F.ι}
    (hbirth : BirthsAt F c s) (hcard : 2 ≤ s.card) :
    ∃ d : ℚ, d ≤ c ∧ IsPairCritical F d := by
  obtain ⟨⟨x, hx_le, hx_sub⟩, _ε, _hε, _⟩ := hbirth
  obtain ⟨i, hi, j, hj, hij⟩ := Finset.one_lt_card.mp (by omega : 1 < s.card)
  have hi_active : i ∈ ActiveSet F x := Finset.mem_of_subset hx_sub hi
  have hj_active : j ∈ ActiveSet F x := Finset.mem_of_subset hx_sub hj
  rw [activeSet_mem_iff_eval_eq] at hi_active hj_active
  exact ⟨tropMax F x, hx_le, x, i, j, hij, hi_active, hj_active,
    fun l => eval_le_tropMax F x l⟩

/-! ## Combinatorial Morse Theory: Birth-Order Structure

The birth-order on faces forms a preorder compatible with the face relation.
This is the foundation of the discrete Morse-theoretic structure. -/

/-- The first-birth preorder is reflexive. -/
theorem firstBirthLe_refl (F : TropicalAffineFamily n) (s : Finset F.ι) :
    FirstBirthLe F s s := fun _ h => h

/-- The first-birth preorder is transitive. -/
theorem firstBirthLe_trans (F : TropicalAffineFamily n)
    {r s t : Finset F.ι}
    (hrs : FirstBirthLe F r s) (hst : FirstBirthLe F s t) :
    FirstBirthLe F r t := fun c hc => hrs c (hst c hc)

/-- Birth monotonicity: if `s ⊆ t`, then `s` is born no later than `t`. -/
theorem firstBirthLe_of_sub (F : TropicalAffineFamily n)
    {s t : Finset F.ι} (h : s ⊆ t) :
    FirstBirthLe F s t :=
  firstBirthLe_of_subset F h

/-! ## Morse-Theoretic Consequences under Genericity -/

/-- Under genericity, every strict birth of a non-singleton face is pair-critical. -/
theorem generic_birth_is_pairCritical (F : TropicalAffineFamily n)
    (_hgen : PairwiseGeneric F)
    {c : ℚ} {s : Finset F.ι}
    (hbirth : StrictBirthsAt F c s)
    (hcard : 2 ≤ s.card) :
    IsPairCritical F c :=
  strictBirth_pair_imp_pairCritical F hbirth hcard

/-- Under genericity, born faces have size ≤ 2. -/
theorem generic_birth_card_le_two (F : TropicalAffineFamily n)
    (hgen : PairwiseGeneric F) {c : ℚ} {s : Finset F.ι}
    (hs : s ∈ ActiveSetComplexSub F c) :
    s.card ≤ 2 :=
  pairwiseGeneric_complex_face_card_le_two F hgen c hs

/-- **Strict birth construction**: If `x` achieves tropMax = c and
the active set contains face `s`, and `s` doesn't appear below, then `s` is strictly born. -/
theorem strictBirth_of_exact_witness (F : TropicalAffineFamily n)
    {c : ℚ} {s : Finset F.ι} {x : Fin n → ℚ}
    (htrop : tropMax F x = c)
    (hact : s ⊆ ActiveSet F x)
    (hno_below : ∀ ε : ℚ, ε > 0 → s ∉ ActiveSetComplexSub F (c - ε)) :
    StrictBirthsAt F c s :=
  ⟨⟨x, le_of_eq htrop, hact⟩, hno_below⟩

/-! ## Complex membership at the boundary -/

/-- If the sublevel at `c` is nonempty, the empty set is in the complex. -/
theorem empty_mem_activeSetComplexSub (F : TropicalAffineFamily n) (c : ℚ)
    (hne : (SublevelSet F c).Nonempty) :
    (∅ : Finset F.ι) ∈ ActiveSetComplexSub F c := by
  obtain ⟨x, hx⟩ := hne
  exact ⟨x, hx, Finset.empty_subset _⟩

/-- The active set itself is always in the complex at the corresponding threshold. -/
theorem activeSet_mem_complex (F : TropicalAffineFamily n) (x : Fin n → ℚ) :
    ActiveSet F x ∈ ActiveSetComplexSub F (tropMax F x) :=
  ⟨x, le_refl _, Finset.Subset.refl _⟩

/-- Singleton of an active index is in the complex. -/
theorem singleton_active_mem_complex (F : TropicalAffineFamily n) (x : Fin n → ℚ)
    (i : F.ι) (hi : i ∈ ActiveSet F x) (hc : tropMax F x ≤ c) :
    ({i} : Finset F.ι) ∈ ActiveSetComplexSub F c := by
  exact ⟨x, hc, Finset.singleton_subset_iff.mpr hi⟩

/-! ## Verified Algorithm: Pair-Critical Value Enumeration -/

/-- **Completeness of pair spectrum**: Every pair-critical value lies in the spectrum. -/
theorem pairCritical_in_spectrum (F : TropicalAffineFamily n)
    {c : ℚ} (hc : IsPairCritical F c) :
    c ∈ PairSpectrum F :=
  pairCritical_subset_spectrum F hc

/-! ## Cells born in each dimension -/

/-- Cells of dimension `m` (faces with `m + 1` elements) that have a strict birth. -/
def CellsBornInDim (F : TropicalAffineFamily n) (m : ℕ) : Set (Finset F.ι) :=
  {s | (∃ c : ℚ, StrictBirthsAt F c s) ∧ s.card = m + 1}

/-- Under genericity, all born cells have dimension ≤ 1. -/
theorem generic_cells_dim_le_one (F : TropicalAffineFamily n)
    (hgen : PairwiseGeneric F) (m : ℕ) (hm : 2 ≤ m) :
    CellsBornInDim F m = ∅ := by
  ext s
  simp only [CellsBornInDim, Set.mem_setOf_eq, Set.mem_empty_iff_false, iff_false, not_and]
  intro ⟨c, hc⟩ hcard
  have := pairwiseGeneric_complex_face_card_le_two F hgen c hc.1
  omega

end TropicalMorse