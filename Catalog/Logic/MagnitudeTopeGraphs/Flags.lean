import Mathlib
import Novelty.PartialCube

/-!
# Face flags underlying magnitude homology of tope graphs

Koizumi's description of magnitude homology for a real hyperplane arrangement is indexed by
weakly nested flags of proper chamber faces.  A face contributes two statistics: the rank of
its localization and the number of hyperplanes containing it.  This file isolates the finite
combinatorial mechanism behind three parts of that description.

* the support of the multidegree of a nonempty nested flag is its terminal zero set;
* adjoining the center of a central arrangement shifts rank and length by the rank and size
  of the arrangement, respectively, giving the flag-level periodicity and reciprocity shift;
* nested zero sets trace geodesics in the ambient hypercube, and their Hamming lengths
  telescope to the size of the terminal zero set.

The last point links the face-flag model to the partial-cube geometry already developed for
hypercube subgraphs.  The results apply to any finite system of zero sets satisfying the
nesting axioms, independently of realizability by hyperplanes.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer), ranked by expected impact:
(1) face-flag generators extend from realizable arrangements to all oriented matroids;
(2) central reciprocity is induced by Alexander duality at chain level, not merely by equal
ranks; (3) the Stanley--Reisner model admits a multiplicative enhancement recovering a
magnitude-homology product; (4) Coxeter spherical flags determine a rational bivariate
series uniformly in finite and affine type; (5) terminal support alone controls localization;
(6) nested zero-set flags are monotone hypercube geodesics.  The first four are bold
cross-domain conjectures; the last two are finite, falsifiable structural tests.

Experiment (Experimenter): faces were represented by finite zero sets, and the multidegree
was defined by counting occurrences of each hyperplane.  Repetitions alter multiplicities
but never support.  Appending the full zero set shifts every coordinate by one and adds its
prescribed rank and length.  Successive nested sets were then measured with the Hamming
metric imported from the catalog's partial-cube model.

Analysis (Analyst): hypotheses (5) and (6) survive in full generality.  Terminal support is
the common combinatorial step behind localization and central periodicity.  Hamming lengths
telescope, so every newly introduced hyperplane is crossed exactly once.  Hypotheses (1)--(4)
remain plausible but require oriented-matroid face categories, chain complexes, ring
structures, and Coxeter growth machinery absent from this finite core; they are therefore
classified as true-or-hard rather than established.

Critique (Critic): nesting is essential.  For the non-nested sequence `{a}, {b}`, the support
is `{a,b}` rather than the terminal set `{b}`.  Nonemptiness is also essential to speak of a
terminal face.  The append/delete equivalence is deliberately combinatorial and does not by
itself assert a homology isomorphism.  Every principal theorem below uses structural
induction, an explicit equivalence, or cardinal arithmetic rather than finite enumeration.

Synthesis (Principal Investigator): the surviving results supply the flag-support lemma,
central degree shift, an explicit append/delete equivalence, and a partial-cube telescoping
law.  Together they isolate the combinatorial skeleton of localization and reciprocity.  The
next cycle should construct the chain-level localization and periodicity maps and compare
their bases with Stanley--Reisner monomials.
-/

namespace MagnitudeTope

open Finset
open scoped Classical symmDiff

variable {H : Type*} [Fintype H] [DecidableEq H]

/-- A weakly increasing list of hyperplane zero sets.  It is the zero-set form of a weakly
decreasing face flag. -/
def Nested (F : List (Finset H)) : Prop := F.Pairwise (· ⊆ ·)

/-- The multidegree records how often each hyperplane occurs in a flag. -/
def profile (F : List (Finset H)) (h : H) : ℕ := (F.filter (h ∈ ·)).length

/-- The support of the multidegree. -/
def profileSupport (F : List (Finset H)) : Finset H :=
  F.foldl (· ∪ ·) ∅

/-- The two scalar degrees attached to a flag with an abstract rank weight and length weight. -/
def rankDegree (rankWeight : Finset H → ℕ) (F : List (Finset H)) : ℕ :=
  (F.map rankWeight).sum

def lengthDegree (F : List (Finset H)) : ℕ := (F.map card).sum

omit [Fintype H] in
lemma mem_profileSupport_iff {F : List (Finset H)} {h : H} :
    h ∈ profileSupport F ↔ profile F h > 0 := by
  induction F using List.reverseRecOn <;> simp_all +decide [ profile, profileSupport ]

/-
**Terminal-support lemma.**  The support of the multidegree of a nonempty nested flag is
exactly the zero set of its terminal face.
-/
omit [Fintype H] in
theorem profileSupport_eq_getLast {F : List (Finset H)} (hne : F ≠ []) (hF : Nested F) :
    profileSupport F = F.getLast hne := by
  induction' F using List.reverseRecOn with F' hF' ih;
  · contradiction;
  · simp_all +decide [ Nested ];
    simp_all +decide [ List.pairwise_append, profileSupport ];
    induction' F' using List.reverseRecOn with F' hF' ih <;> simp_all +decide [ Finset.subset_iff ];
    grind

lemma profile_append_univ (F : List (Finset H)) (h : H) :
    profile (F ++ [Finset.univ]) h = profile F h + 1 := by
  unfold profile; aesop;

omit [Fintype H] [DecidableEq H] in
lemma rankDegree_append (rankWeight : Finset H → ℕ) (F : List (Finset H)) (Z : Finset H) :
    rankDegree rankWeight (F ++ [Z]) = rankDegree rankWeight F + rankWeight Z := by
  unfold rankDegree; simp +decide ;

omit [Fintype H] [DecidableEq H] in
lemma lengthDegree_append (F : List (Finset H)) (Z : Finset H) :
    lengthDegree (F ++ [Z]) = lengthDegree F + Z.card := by
  unfold lengthDegree; simp +decide ;

/-
Appending the central face preserves nesting and shifts the two flag degrees by the rank
and the number of hyperplanes.  This is the combinatorial periodicity step in the central
case.
-/
omit [DecidableEq H] in
theorem central_flag_periodicity (rankWeight : Finset H → ℕ) (F : List (Finset H))
    (hF : Nested F) :
    Nested (F ++ [Finset.univ]) ∧
      rankDegree rankWeight (F ++ [Finset.univ]) =
        rankDegree rankWeight F + rankWeight Finset.univ ∧
      lengthDegree (F ++ [Finset.univ]) = lengthDegree F + Fintype.card H := by
  constructor;
  · unfold Nested at *; simp_all +decide [ List.pairwise_append ] ;
  · unfold rankDegree lengthDegree; aesop;

/-
Flags ending at the central face are explicitly equivalent to arbitrary flags, by
adjoining or deleting the final full zero set.
-/
noncomputable def appendCenterEquiv :
    List (Finset H) ≃ {G : List (Finset H) // ∃ F, G = F ++ [Finset.univ]} := by
  let f : List (Finset H) → {G : List (Finset H) // ∃ F, G = F ++ [Finset.univ]} :=
    fun F => ⟨F ++ [Finset.univ], F, rfl⟩
  apply Equiv.ofBijective f
  constructor
  · intro F G h
    apply List.append_left_injective [Finset.univ]
    exact congrArg Subtype.val h
  · rintro ⟨G, F, rfl⟩
    exact ⟨F, rfl⟩

/-- Hamming distance on arbitrary finite zero sets.  On `Fin n` this is exactly the
catalog's `DaisyCube.hdist`. -/
def hamming (A B : Finset H) : ℕ := (A ∆ B).card

lemma hamming_eq_daisy {n : ℕ} (A B : Finset (Fin n)) :
    hamming A B = DaisyCube.hdist A B := by
  rfl

omit [Fintype H] in
lemma hamming_eq_card_sdiff {A B : Finset H} (hAB : A ⊆ B) :
    hamming A B = (B \ A).card := by
  convert congr_arg Finset.card ( show A ∆ B = B \ A from ?_ ) using 1;
  ext x; by_cases hx : x ∈ A <;> simp +decide [hx];
  · simp +decide [ Finset.mem_symmDiff, hx, hAB hx ];
  · simp +decide [hx, Finset.mem_symmDiff]

/-- Total Hamming length of the successive transitions beginning at `A`. -/
def transitionLength (A : Finset H) : List (Finset H) → ℕ
  | [] => 0
  | B :: F => hamming A B + transitionLength B F

/-
The Hamming increments along a nested flag telescope.  Thus the zero-set flag is a
monotone geodesic in the ambient hypercube, linking face combinatorics with partial-cube
geometry.
-/
omit [Fintype H] in
theorem nested_hamming_telescopes :
    ∀ (A : Finset H) (F : List (Finset H)), Nested (A :: F) →
      transitionLength A F + A.card = ((A :: F).getLast (by simp)).card := by
  intro A F hF
  generalize_proofs at *;
  induction' F with B F ih generalizing A <;> simp_all +decide [ transitionLength ];
  -- Since A ⊆ B, we have hamming A B = #B - #A.
  have h_hamming : hamming A B = #B - #A := by
    have h_hamming : A ⊆ B := by
      cases hF ; aesop;
    convert hamming_eq_card_sdiff h_hamming using 1;
    grind;
  linarith [ ih B ( by unfold Nested at *; aesop ), Nat.sub_add_cancel ( show #A ≤ #B from Finset.card_le_card ( by unfold Nested at *; aesop ) ) ]

end MagnitudeTope