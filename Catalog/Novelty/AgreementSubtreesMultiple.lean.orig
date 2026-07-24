import Applications.Core

/-!
# Multiple agreement subtrees: gluing, counting, and threshold transfer

The split-system representation turns restriction of a labelled phylogenetic tree into
intersection of every displayed split with the retained leaf set.  This chapter develops
three consequences used in the study of agreement subtrees for many trees:

* common agreement can be glued across two families sharing a tree;
* every restricted system is supported on the powerset of the retained leaves, giving a
  double-exponential bound on its number of displayed splits;
* any uniform bound forcing a larger common subtree transfers to the quartet problem,
  independently of the analytic form of the bound (in particular, to fourfold iterated
  exponential bounds).

The results apply to arbitrary finite split systems; binary compatibility assumptions are
not needed for these restriction-algebra steps.

-- !-- Lab Notes -- !--
## Hypothesis (Hypothesizer)
The selected target category is **cross-domain bridge**: finite-set restriction algebra,
overlap connectivity, and information counting are combined with phylogenetic agreement.
The conjectures below are ranked by expected impact.

1. **Named-problem subtask, bold:** four rounds of compatible-signature refinement suffice
   to recover the fourfold exponential upper bound for the multiple-tree MAST problem.
2. **Named-problem subtask, bold:** probabilistic packings of quartet signatures give the
   optimal exponential rate in the lower bound for the common-quartet threshold `h(k)`.
3. **Named-problem subtask, bold:** for fixed small `k`, all extremal families defining
   `h(k)` fall into finitely many explicit relabelling orbits.
4. **Connectivity bridge:** common-restriction witnesses should glue along every connected
   overlap pattern; the chain case is the first falsifiable instance.
5. **Information bridge:** a restriction to `a` leaves should contain at most `2^a` distinct
   split sides, while binary compatibility should permit a sharper topology count.
6. **Ramsey bridge:** every bound for a common subtree of size at least four should
   automatically be a bound for a common quartet.

## Experiment (Experimenter)
The restriction operation was tested symbolically under nested leaf deletion and under
unions of split systems.  The gluing statement survives exactly when the two tree families
share an index: the shared restriction identifies their two witnesses.  Counting split
sides reduces to the powerset identity `|𝒫(A)| = 2^|A|`.

## Analysis (Analyst)
The surviving statements separate into a categorical layer (restriction composition and
witness gluing), an information-theoretic layer (powerset bounds), and an extremal layer
(threshold transfer).  The compatibility and binary-degree conditions enter only beyond
this interface, when one seeks the paper's quantitative fourfold exponential estimate.

## Critique (Critic)
The overlap hypothesis in the gluing theorem is essential: two disjoint singleton families
may choose different restrictions.  The powerset estimate counts split sides rather than
whole tree topologies, so it is deliberately not advertised as the paper's final bound.
The threshold theorem assumes, rather than proves, a quantitative common-subtree bound;
it rigorously isolates the implication from that bound to the quartet bound.

## Synthesis (Principal Investigator)
Restriction functoriality, overlap gluing, finite information bounds, and quartet transfer
form a reusable interface between phylogenetic agreement and finite Ramsey counting.  This
interface identifies precisely where future work must add compatibility-sensitive counting.
-/

open Finset

namespace AgreementSubtrees

variable {α ι : Type*} [DecidableEq α] [DecidableEq ι]

/-
Restriction distributes over union of split systems.
-/
theorem restrict_union (T U : SplitSystem α) (A : Finset α) :
    restrict (T ∪ U) A = restrict T A ∪ restrict U A := by
  unfold restrict; aesop;

/-
Every split side surviving restriction is a subset of the retained leaf set.
-/
theorem mem_restrict_subset {T : SplitSystem α} {A s : Finset α}
    (hs : s ∈ restrict T A) : s ⊆ A := by
  unfold restrict at hs; aesop;

/-
A restriction to `A` has at most `2 ^ |A|` distinct split sides.  This is the
finite-information bridge underlying subsequent pigeonhole arguments.
-/
theorem card_restrict_le_two_pow (T : SplitSystem α) (A : Finset α) :
    (restrict T A).card ≤ 2 ^ A.card := by
  convert Finset.card_le_card ( show restrict T A ⊆ Finset.powerset A from ?_ ) using 1;
  · rw [ Finset.card_powerset ];
  · exact fun x hx => Finset.mem_powerset.mpr ( mem_restrict_subset hx )

/-
Common-agreement witnesses glue across two families that share at least one tree.
-/
theorem commonAgreement_union_of_inter_nonempty {F G : Finset ι}
    {T : ι → SplitSystem α} {A : Finset α}
    (hFG : (F ∩ G).Nonempty) (hF : CommonAgreement F T A)
    (hG : CommonAgreement G T A) : CommonAgreement (F ∪ G) T A := by
  obtain ⟨ c, hc ⟩ := hFG;
  obtain ⟨ R, hR ⟩ := hF
  obtain ⟨ S, hS ⟩ := hG
  have h_eq : R = S := by
    rw [ ← hR c ( Finset.mem_of_mem_inter_left hc ), ← hS c ( Finset.mem_of_mem_inter_right hc ) ];
  exact ⟨ R, fun i hi => by cases Finset.mem_union.mp hi <;> aesop ⟩

/-
Pairwise agreement across two internally coherent families is forced by one shared
member; this is the relational form of witness gluing.
-/
theorem agreeOn_cross_of_common_overlap {F G : Finset ι}
    {T : ι → SplitSystem α} {A : Finset α}
    (hFG : (F ∩ G).Nonempty) (hF : CommonAgreement F T A)
    (hG : CommonAgreement G T A) :
    ∀ i ∈ F, ∀ j ∈ G, AgreeOn (T i) (T j) A := by
  obtain ⟨ R, hR ⟩ := commonAgreement_union_of_inter_nonempty hFG hF hG;
  exact fun i hi j hj => by rw [ AgreeOn, hR i ( Finset.mem_union_left _ hi ), hR j ( Finset.mem_union_right _ hj ) ] ;

/-- Union of all tree-index families in a finite chain. -/
def familyUnion : List (Finset ι) → Finset ι
  | [] => ∅
  | F :: families => F ∪ familyUnion families

/-- Consecutive families in a chain overlap. -/
def OverlapChain : List (Finset ι) → Prop
  | [] => True
  | [_] => True
  | F :: G :: families => (F ∩ G).Nonempty ∧ OverlapChain (G :: families)

/-- Every family in a list has a common restriction on `A`. -/
def EachCommon (T : ι → SplitSystem α) (A : Finset α) : List (Finset ι) → Prop
  | [] => True
  | F :: families => CommonAgreement F T A ∧ EachCommon T A families

/-
The head family is contained in the union of a nonempty family chain.
-/
theorem head_subset_familyUnion (F : Finset ι) (families : List (Finset ι)) :
    F ⊆ familyUnion (F :: families) := by
  exact Finset.subset_union_left

/-
Local agreement propagates through an arbitrary finite chain of overlapping tree
families.  The proof inductively glues witnesses and is a finite connectedness principle
for agreement data.
-/
theorem commonAgreement_familyUnion_of_chain {T : ι → SplitSystem α} {A : Finset α}
    (families : List (Finset ι)) (hoverlap : OverlapChain families)
    (hcommon : EachCommon T A families) :
    CommonAgreement (familyUnion families) T A := by
  induction' families with F families ih generalizing A;
  · exact ⟨ ∅, by simp +decide [ familyUnion ] ⟩;
  · rcases families with ( _ | ⟨ G, families ⟩ );
    · convert hcommon.1 using 1;
      exact Finset.union_empty _;
    · apply commonAgreement_union_of_inter_nonempty;
      · obtain ⟨ x, hx ⟩ := hoverlap.1;
        exact ⟨ x, Finset.mem_inter.mpr ⟨ Finset.mem_of_mem_inter_left hx, head_subset_familyUnion G families ( Finset.mem_of_mem_inter_right hx ) ⟩ ⟩;
      · exact hcommon.1;
      · exact ih ( by cases hoverlap; tauto ) ( by cases hcommon; tauto )

/-- Fourfold self-composition, used to state four-times iterated bounds without fixing the
particular exponential function supplied by a quantitative argument. -/
def iterateFour (f : ℕ → ℕ) (x : ℕ) : ℕ := f (f (f (f x)))

/-
Abstract fourfold-bound transfer.  If a fourfold iterated bound forces an `n`-leaf
common agreement subtree and `n ≥ 4`, the same ambient bound forces a common quartet.
-/
theorem fourfold_bound_implies_quartet (B : ℕ → ℕ → ℕ) (f : ℕ → ℕ)
    {k n : ℕ} (hn : 4 ≤ n)
    (h : IsAgreementThreshold (iterateFour f (B k n)) k n) :
    IsAgreementThreshold (iterateFour f (B k n)) k 4 := by
  exact agreementThreshold_implies_quartetThreshold hn h

/-
A uniform many-tree MAST bound transfers pointwise to a uniform quartet bound.
-/
theorem uniform_MAST_bound_implies_uniform_quartet
    (B : ℕ → ℕ → ℕ) (hB : ∀ k n, 4 ≤ n → IsAgreementThreshold (B k n) k n) :
    ∀ k n, 4 ≤ n → IsAgreementThreshold (B k n) k 4 := by
  exact fun k n hn => by have := hB k n hn; exact AgreementSubtrees.agreementThreshold_implies_quartetThreshold hn this;

end AgreementSubtrees