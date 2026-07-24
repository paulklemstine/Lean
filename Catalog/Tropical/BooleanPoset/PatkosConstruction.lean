import Mathlib
import Catalog.Tropical.BooleanPoset.B3Free

/-!
# The finite-dimensional construction behind large `B₃`-free families

Patkós's construction selects four adjacent ranks according to the dimension of the
linear span of their labels.  This file isolates its deterministic core.  The main
result proves that the selected family contains no three-dimensional Boolean interval:
if all eight sets between `A` and `A ∪ {x,y,z}` were selected, the three singleton
extensions would leave the span unchanged, while the top extension would be required
to change it.

The argument is stated over an arbitrary field and finite-dimensional vector space;
its content is independent of the probabilistic choice of labels used to estimate the
size of the family.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the four-layer linear-rank construction excludes every full
three-dimensional interval for a reason that belongs simultaneously to extremal-poset
theory and matroid closure.  The ranked targets were: (1) the deterministic interval
obstruction; (2) reduction of every weak `D₆` in four adjacent ranks to such an interval;
(3) a finite Gaussian-rank count; (4) positivity of the asymptotic gain; (5) a stability
theorem for near-extremal families; and (6) an entropy interpretation of the gain.
Targets (1), (2), (4), and (5) address the forbidden-subposet problem, while (1), (3),
and (6) bridge it with linear algebra, finite geometry, and information theory.

Experiment (Experimenter): label the ground set by vectors and inspect the eight sets
in a Boolean interval of rank three.  Membership of the bottom set fixes its span rank.
Membership of each singleton extension bounds its rank above by the same value.
Monotonicity forces equality of spans, so adjoining all three elements also leaves the
span unchanged.  Membership of the top set requires the opposite conclusion.

Analysis (Analyst): no probability is needed for exclusion.  Randomness enters only in
showing that some labeling makes the selected family large.  The obstruction is the
closure axiom: elements individually in the closure of `A` remain in that closure when
adjoined together.

Critique (Critic): interval avoidance alone is weaker than the paper's full weak-`D₆`
avoidance statement unless one also proves the four-rank reduction.  Accordingly the
main theorem here is named and documented as an interval theorem, not overstated as the
full asymptotic result.  It uses genuine span monotonicity and finite-dimensional rank
comparison; no finite brute-force decision closes the argument.

Synthesis (Principal Investigator): the interval theorem captures the algebraic engine
of the construction and cleanly separates it from the outstanding enumerative and
four-rank poset-reduction components.
-/

open Finset
open scoped Classical

namespace BooleanPoset.Patkos

variable {𝕜 V α : Type*} [Field 𝕜] [AddCommGroup V] [Module 𝕜 V]

/-- The span of the labels indexed by a finite set. -/
def labelSpan (label : α → V) (A : Finset α) : Submodule 𝕜 V :=
  Submodule.span 𝕜 (label '' (A : Set α))

/-- The linear rank of a finite set of labels. -/
noncomputable def labelRank [FiniteDimensional 𝕜 V]
    (label : α → V) (A : Finset α) : ℕ :=
  Module.finrank 𝕜 (labelSpan (𝕜 := 𝕜) label A)

/-
The span is monotone under inclusion of index sets.
-/
lemma labelSpan_mono (label : α → V) {A B : Finset α} (hAB : A ⊆ B) :
    labelSpan (𝕜 := 𝕜) label A ≤ labelSpan (𝕜 := 𝕜) label B := by
  exact Submodule.span_mono ( Set.image_mono hAB )

/-
Equal finite-dimensional ranks turn an inclusion of label spans into equality.
-/
lemma labelSpan_eq_of_subset_of_rank_eq [FiniteDimensional 𝕜 V]
    (label : α → V) {A B : Finset α} (hAB : A ⊆ B)
    (hrank : labelRank (𝕜 := 𝕜) label A = labelRank (𝕜 := 𝕜) label B) :
    labelSpan (𝕜 := 𝕜) label A = labelSpan (𝕜 := 𝕜) label B := by
  refine' Submodule.eq_of_le_of_finrank_le ( labelSpan_mono label hAB ) _;
  exact hrank.ge

variable [DecidableEq α]

/-
If adjoining each of three points separately leaves a span unchanged, adjoining
all three simultaneously also leaves it unchanged.
-/
lemma labelSpan_insert_three
    (label : α → V) (A : Finset α) (x y z : α)
    (hx : labelSpan (𝕜 := 𝕜) label (insert x A) = labelSpan (𝕜 := 𝕜) label A)
    (hy : labelSpan (𝕜 := 𝕜) label (insert y A) = labelSpan (𝕜 := 𝕜) label A)
    (hz : labelSpan (𝕜 := 𝕜) label (insert z A) = labelSpan (𝕜 := 𝕜) label A) :
    labelSpan (𝕜 := 𝕜) label (insert z (insert y (insert x A))) =
      labelSpan (𝕜 := 𝕜) label A := by
  refine' le_antisymm _ _ <;> simp_all +decide [ labelSpan, Submodule.span_le ];
  · simp_all +decide [ Set.insert_subset_iff ];
    simp_all +decide [ Set.image_insert_eq, Submodule.span_insert ];
    exact fun x hx => Submodule.subset_span <| Set.mem_image_of_mem _ hx;
  · exact fun a ha => Submodule.subset_span ⟨ a, by aesop ⟩

/-- The four-layer family used in the deterministic part of the construction.
At rank `k-2` it keeps exactly rank-`k-2` sets; at rank `k-1` it keeps sets of
rank at most `k-2`; it keeps the whole rank `k`; and at rank `k+1` it keeps sets
whose rank differs from `k-2`. -/
noncomputable def fourLayerFamily [FiniteDimensional 𝕜 V]
    (label : α → V) (k : ℕ) : Finset α → Prop :=
  fun A =>
    (A.card = k - 2 ∧ labelRank (𝕜 := 𝕜) label A = k - 2) ∨
    (A.card = k - 1 ∧ labelRank (𝕜 := 𝕜) label A ≤ k - 2) ∨
    A.card = k ∨
    (A.card = k + 1 ∧ labelRank (𝕜 := 𝕜) label A ≠ k - 2)

/-
**Deterministic Patkós obstruction.**  No full Boolean interval generated by three
fresh points is contained in the four-layer family.
-/
theorem fourLayerFamily_no_threeCube [FiniteDimensional 𝕜 V]
    (label : α → V) (k : ℕ) (hk : 2 ≤ k)
    (A : Finset α) (x y z : α)
    (hxA : x ∉ A) (hyA : y ∉ A) (hzA : z ∉ A)
    (hxy : x ≠ y) (hxz : x ≠ z) (hyz : y ≠ z) :
    ¬ (fourLayerFamily (𝕜 := 𝕜) label k A ∧
       fourLayerFamily (𝕜 := 𝕜) label k (insert x A) ∧
       fourLayerFamily (𝕜 := 𝕜) label k (insert y A) ∧
       fourLayerFamily (𝕜 := 𝕜) label k (insert z A) ∧
       fourLayerFamily (𝕜 := 𝕜) label k (insert y (insert x A)) ∧
       fourLayerFamily (𝕜 := 𝕜) label k (insert z (insert x A)) ∧
       fourLayerFamily (𝕜 := 𝕜) label k (insert z (insert y A)) ∧
       fourLayerFamily (𝕜 := 𝕜) label k (insert z (insert y (insert x A)))) := by
  by_contra h_contra
  obtain ⟨hA, hx, hy, hz, hxy, hxz, hyz, hxyz⟩ := h_contra
  have hA_card : A.card = k - 2 := by
    rcases k with ( _ | _ | k ) <;> simp_all +decide [ fourLayerFamily ];
    grind +qlia
  have hA_rank : labelRank (𝕜 := 𝕜) label A = k - 2 := by
    unfold fourLayerFamily at hA;
    grind +qlia
  have hx_rank : labelRank (𝕜 := 𝕜) label (insert x A) ≤ k - 2 := by
    rcases hx with ( ⟨ h₁, h₂ ⟩ | ⟨ h₁, h₂ ⟩ | h₁ | ⟨ h₁, h₂ ⟩ ) <;> simp_all +decide [ Finset.card_insert_of_notMem ]; all_goals omega
  have hy_rank : labelRank (𝕜 := 𝕜) label (insert y A) ≤ k - 2 := by
    rcases hy with ( ⟨ h₁, h₂ ⟩ | ⟨ h₁, h₂ ⟩ | h₁ | ⟨ h₁, h₂ ⟩ ) <;> simp_all +decide [ Finset.card_insert_of_notMem ]; all_goals omega
  have hz_rank : labelRank (𝕜 := 𝕜) label (insert z A) ≤ k - 2 := by
    grind +locals;
  have hx_rank_eq : labelRank (𝕜 := 𝕜) label (insert x A) = k - 2 := by
    refine' le_antisymm hx_rank _;
    exact hA_rank ▸ Submodule.finrank_mono ( labelSpan_mono _ ( Finset.subset_insert _ _ ) )
  have hy_rank_eq : labelRank (𝕜 := 𝕜) label (insert y A) = k - 2 := by
    refine' le_antisymm hy_rank _;
    exact hA_rank ▸ Submodule.finrank_mono ( labelSpan_mono _ ( Finset.subset_insert _ _ ) )
  have hz_rank_eq : labelRank (𝕜 := 𝕜) label (insert z A) = k - 2 := by
    refine' le_antisymm hz_rank _;
    exact hA_rank ▸ Submodule.finrank_mono ( labelSpan_mono _ ( Finset.subset_insert _ _ ) );
  have hxyz_rank_eq : labelRank (𝕜 := 𝕜) label (insert z (insert y (insert x A))) = k - 2 := by
    convert congr_arg ( fun s : Submodule 𝕜 V => Module.finrank 𝕜 s ) ( labelSpan_insert_three label A x y z _ _ _ ) using 1;
    · exact hA_rank.symm;
    · grind +suggestions;
    · grind +suggestions;
    · grind +suggestions;
  have := hxyz; unfold fourLayerFamily at this; simp_all +decide ;
  grind +qlia

/-
The numerator of the asymptotic improvement term is positive for every
prime-power candidate `q ≥ 2`.  Since the remaining factors are positive, this
is the elementary inequality behind the strict improvement over three layers.
-/
theorem gainNumerator_pos (q : ℕ) (hq : 2 ≤ q) :
    q ^ 6 < q ^ 4 * (q - 1) * (q ^ 2 - 1) * (q ^ 3 - 1) := by
  zify;
  rcases q with ( _ | _ | _ | _ | _ | _ | q ) <;> norm_num at *;
  grind

end BooleanPoset.Patkos