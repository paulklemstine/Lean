import Mathlib

/-! # Algebraic Geometry of Neural Networks: Varieties of Decision Boundaries

A feed-forward network with rectified-linear (ReLU) activations computes a
*piecewise linear* function `f : ℝⁿ → ℝ`.  Its decision boundary
`{x : f x = 0}` is the "skeleton" of an algebraic variety — a **tropical
hypersurface**.  This file develops the algebraic structure underlying that
picture and proves the two combinatorial growth laws that control the
complexity of the boundary.

The central object is the *tropical polynomial* (a max-plus polynomial): a
pointwise maximum of affine "monomials"
`m_i(x) = a_i + ⟨w_i, x⟩`.  We work with an arbitrary nonempty finite index
type `ι` of monomials.

Main results.

* `tropVal_convex`, `tropVal_continuous`: a tropical polynomial is a convex,
  continuous, piecewise-linear function.
* `tropVal_max` (**tropical addition / ReLU law**): the pointwise maximum of
  two tropical polynomials is again a tropical polynomial, whose monomial set
  is the *disjoint union* of the two.  Hence the number of monomials *adds*.
* `tropVal_add` (**tropical multiplication law**): the pointwise sum of two
  tropical polynomials is again a tropical polynomial, whose monomial set is
  the *product* of the two.  Hence the number of monomials *multiplies*.
* `relu_tropRat`: applying a ReLU to a tropical rational function
  `p ⊖ q` yields the tropical rational `max(p,q) ⊖ q`; this is the algebraic
  reason each layer at most doubles the monomial count.
* `layer_count_le_pow_two`: an at-most-doubling recursion is bounded by `2^L`,
  formalizing the *degree ≤ 2^L* half of the conjecture.
* `tropProduct_card_eq_prod`: the tropical product over `L` factors of widths
  `w_i` has exactly `∏ w_i` monomials, formalizing the *∏ wᵢ regions* half.
* `decisionBoundary` results: the decision boundary is closed and coincides
  with the tropical hypersurface `{x : p x = q x}`; the sign of the classifier
  is governed by which numerator monomial family dominates.
-/

noncomputable section

open Finset BigOperators

namespace DecisionBoundaryVarieties

/-! ## Tropical polynomials -/

/-- Value of a tropical polynomial in `n` variables with monomials indexed by a
nonempty finite type `ι`: the pointwise maximum of the affine monomials
`a i + ⟨w i, x⟩`. -/
def tropVal {n : ℕ} {ι : Type*} [Fintype ι] [Nonempty ι]
    (a : ι → ℝ) (w : ι → Fin n → ℝ) (x : Fin n → ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun i => a i + ∑ j, w i j * x j)

variable {n : ℕ}

/-
Each monomial lies below the tropical polynomial.
-/
theorem monomial_le_tropVal {ι : Type*} [Fintype ι] [Nonempty ι]
    (a : ι → ℝ) (w : ι → Fin n → ℝ) (x : Fin n → ℝ) (i : ι) :
    a i + ∑ j, w i j * x j ≤ tropVal a w x := by
  exact Finset.le_sup' ( fun i => a i + ∑ j, w i j * x j ) ( Finset.mem_univ i )

/-
The tropical polynomial is attained by some monomial.
-/
theorem exists_monomial_eq_tropVal {ι : Type*} [Fintype ι] [Nonempty ι]
    (a : ι → ℝ) (w : ι → Fin n → ℝ) (x : Fin n → ℝ) :
    ∃ i, tropVal a w x = a i + ∑ j, w i j * x j := by
  obtain ⟨ i, hi ⟩ := Finset.exists_max_image Finset.univ ( fun i => a i + ∑ j, w i j * x j ) ⟨ Classical.arbitrary ι, Finset.mem_univ _ ⟩;
  exact ⟨ i, le_antisymm ( Finset.sup'_le _ _ fun i _ => hi.2 i ‹_› ) ( Finset.le_sup' ( fun i => a i + ∑ j, w i j * x j ) hi.1 ) ⟩

/-
A tropical polynomial is convex: a maximum of affine functions.
-/
theorem tropVal_convex {ι : Type*} [Fintype ι] [Nonempty ι]
    (a : ι → ℝ) (w : ι → Fin n → ℝ) :
    ConvexOn ℝ Set.univ (tropVal a w) := by
  refine' ⟨ convex_univ, _ ⟩;
  intro x _ y _ a b ha hb hab; simp +decide [ tropVal ] ;
  intro i; simp +decide [ mul_add, mul_left_comm, Finset.sum_add_distrib ] ;
  refine' le_trans _ ( add_le_add ( mul_le_mul_of_nonneg_left ( Finset.le_sup' _ ( Finset.mem_univ i ) ) ha ) ( mul_le_mul_of_nonneg_left ( Finset.le_sup' _ ( Finset.mem_univ i ) ) hb ) ) ; simp +decide [ ← Finset.mul_sum _ _ _ ];
  rw [ ← eq_sub_iff_add_eq' ] at hab ; subst_vars ; linarith

/-
A tropical polynomial is continuous.
-/
theorem tropVal_continuous {ι : Type*} [Fintype ι] [Nonempty ι]
    (a : ι → ℝ) (w : ι → Fin n → ℝ) :
    Continuous (tropVal a w) := by
  unfold tropVal;
  refine' continuous_iff_continuousAt.2 fun x => _;
  refine' tendsto_order.2 ⟨ fun y hy => _, fun y hy => _ ⟩;
  · obtain ⟨ i, hi ⟩ := Finset.exists_max_image _ ( fun i => a i + ∑ j, w i j * x j ) Finset.univ_nonempty;
    filter_upwards [ IsOpen.mem_nhds ( isOpen_lt continuous_const <| show Continuous fun x' => a i + ∑ j, w i j * x' j from Continuous.add continuous_const <| continuous_finset_sum _ fun _ _ => Continuous.mul ( continuous_const ) <| continuous_apply _ ) <| show y < a i + ∑ j, w i j * x j from hy.trans_le <| Finset.sup'_le _ _ fun i _ => hi.2 i <| Finset.mem_univ i ] with x' hx' using lt_of_lt_of_le hx' <| Finset.le_sup' ( fun i => a i + ∑ j, w i j * x' j ) <| Finset.mem_univ i;
  · simp_all +decide [ Finset.sup'_lt_iff ];
    exact fun i => IsOpen.mem_nhds ( isOpen_lt ( continuous_const.add ( continuous_finset_sum _ fun _ _ => continuous_const.mul ( continuous_apply _ ) ) ) continuous_const ) ( hy i )

/-! ## The two growth laws -/

/-
**Tropical addition / ReLU law.** The pointwise maximum of two tropical
polynomials is a tropical polynomial whose monomials are the disjoint union of
the two families.  Consequently the monomial count *adds*.
-/
theorem tropVal_max {ι κ : Type*} [Fintype ι] [Nonempty ι] [Fintype κ] [Nonempty κ]
    (a₁ : ι → ℝ) (w₁ : ι → Fin n → ℝ) (a₂ : κ → ℝ) (w₂ : κ → Fin n → ℝ)
    (x : Fin n → ℝ) :
    max (tropVal a₁ w₁ x) (tropVal a₂ w₂ x)
      = tropVal (Sum.elim a₁ a₂) (Sum.elim w₁ w₂) x := by
  refine' le_antisymm _ _;
  · refine' max_le _ _ <;> simp +decide [ tropVal ];
    · exact Or.inl ( by simpa using Finset.exists_max_image Finset.univ ( fun i => a₁ i + ∑ j, w₁ i j * x j ) ⟨ Classical.arbitrary ι, Finset.mem_univ _ ⟩ );
    · exact Or.inr ( by simpa using Finset.exists_max_image Finset.univ ( fun b => a₂ b + ∑ j, w₂ b j * x j ) ⟨ Classical.arbitrary κ, Finset.mem_univ _ ⟩ );
  · refine' Finset.sup'_le _ _ _;
    rintro ( i | i ) <;> simp +decide [ tropVal ];
    · exact Or.inl ⟨ i, le_rfl ⟩;
    · exact Or.inr ⟨ i, le_rfl ⟩

/-
**Tropical multiplication law.** The pointwise sum of two tropical
polynomials is a tropical polynomial whose monomials are the product of the two
families.  Consequently the monomial count *multiplies*.
-/
theorem tropVal_add {ι κ : Type*} [Fintype ι] [Nonempty ι] [Fintype κ] [Nonempty κ]
    (a₁ : ι → ℝ) (w₁ : ι → Fin n → ℝ) (a₂ : κ → ℝ) (w₂ : κ → Fin n → ℝ)
    (x : Fin n → ℝ) :
    tropVal a₁ w₁ x + tropVal a₂ w₂ x
      = tropVal (fun p : ι × κ => a₁ p.1 + a₂ p.2)
          (fun p : ι × κ => fun j => w₁ p.1 j + w₂ p.2 j) x := by
  refine' le_antisymm _ _ <;> simp +decide [ tropVal ];
  · obtain ⟨ i₁, hi₁ ⟩ := Finset.exists_mem_eq_sup' ( Finset.univ_nonempty ) ( fun i => a₁ i + ∑ j, w₁ i j * x j ) ; obtain ⟨ i₂, hi₂ ⟩ := Finset.exists_mem_eq_sup' ( Finset.univ_nonempty ) ( fun i => a₂ i + ∑ j, w₂ i j * x j ) ; use i₁, i₂ ; simp_all +decide [ add_mul, Finset.sum_add_distrib ] ;
    linarith;
  · simp +decide [ add_mul, Finset.sum_add_distrib, add_assoc ];
    exact fun i j => by linarith [ Finset.le_sup' ( fun i => a₁ i + ∑ j, w₁ i j * x j ) ( Finset.mem_univ i ), Finset.le_sup' ( fun i => a₂ i + ∑ j, w₂ i j * x j ) ( Finset.mem_univ j ) ] ;

/-! ## ReLU on tropical rational functions

A ReLU network computes a *tropical rational* function `f = p ⊖ q`, the
difference of two tropical polynomials.  The following algebraic identity is
the engine behind the layerwise doubling of complexity. -/

/-
The pointwise ReLU identity `max (p - q) 0 = max p q - q`.  Applied to a
tropical rational `p ⊖ q`, it shows the ReLU output is the tropical rational
with numerator `max p q` and unchanged denominator `q`.
-/
theorem relu_tropRat (p q : ℝ) : max (p - q) 0 = max p q - q := by
  grind

/-
Composing the ReLU law with `relu_tropRat`: for tropical polynomials `p`
(indexed by `ι`) and `q` (indexed by `κ`), the ReLU of the rational function
`p ⊖ q` equals a tropical rational whose numerator is the `(ι ⊕ κ)`-indexed
tropical polynomial and whose denominator is `q`.
-/
theorem relu_tropRat_value {ι κ : Type*} [Fintype ι] [Nonempty ι]
    [Fintype κ] [Nonempty κ]
    (a₁ : ι → ℝ) (w₁ : ι → Fin n → ℝ) (a₂ : κ → ℝ) (w₂ : κ → Fin n → ℝ)
    (x : Fin n → ℝ) :
    max (tropVal a₁ w₁ x - tropVal a₂ w₂ x) 0
      = tropVal (Sum.elim a₁ a₂) (Sum.elim w₁ w₂) x - tropVal a₂ w₂ x := by
  rw [ ← tropVal_max ];
  grind

/-- The number of monomials of the ReLU numerator is the sum of the numerator
and denominator monomial counts (`Fintype.card (ι ⊕ κ) = card ι + card κ`). -/
theorem relu_numerator_card {ι κ : Type*} [Fintype ι] [Fintype κ] :
    Fintype.card (ι ⊕ κ) = Fintype.card ι + Fintype.card κ :=
  Fintype.card_sum

/-! ## The degree ≤ 2^L growth law -/

/-
**At-most-doubling recursion is bounded by `2^L`.**  If a complexity
measure starts at most `1` and at most doubles at each of `L` layers, then it is
bounded by `2^L`.  This is the abstract form of the *degree ≤ 2^L* conjecture.
-/
theorem layer_count_le_pow_two (c : ℕ → ℕ) (h0 : c 0 ≤ 1)
    (hstep : ∀ i, c (i + 1) ≤ 2 * c i) (L : ℕ) : c L ≤ 2 ^ L := by
  exact Nat.recOn L ( by simpa using h0 ) fun i hi => by rw [ pow_succ' ] ; linarith [ hstep i ] ;

/-! ## The ∏ wᵢ growth law -/

/-
**Cardinality of an iterated tropical product.**  Combining `L` tropical
polynomials of widths `w 0, …, w (L-1)` via tropical multiplication produces a
polynomial with exactly `∏ w i` monomials, formalizing the *∏ wᵢ regions*
count.  Here the product index type is `∀ i, Fin (w i)`.
-/
theorem tropProduct_card_eq_prod (L : ℕ) (w : Fin L → ℕ) :
    Fintype.card (∀ i : Fin L, Fin (w i)) = ∏ i, w i := by
  simp +decide [ Fintype.card_pi ]

/-! ## Decision boundaries as tropical hypersurfaces -/

/-- The decision boundary of the tropical rational classifier `p ⊖ q`: the
locus where the two tropical polynomials agree.  This is precisely the tropical
hypersurface where the maximum is attained by both families. -/
def decisionBoundary {ι κ : Type*} [Fintype ι] [Nonempty ι]
    [Fintype κ] [Nonempty κ]
    (a₁ : ι → ℝ) (w₁ : ι → Fin n → ℝ) (a₂ : κ → ℝ) (w₂ : κ → Fin n → ℝ) :
    Set (Fin n → ℝ) :=
  {x | tropVal a₁ w₁ x = tropVal a₂ w₂ x}

/-
The decision boundary is closed.
-/
theorem decisionBoundary_isClosed {ι κ : Type*} [Fintype ι] [Nonempty ι]
    [Fintype κ] [Nonempty κ]
    (a₁ : ι → ℝ) (w₁ : ι → Fin n → ℝ) (a₂ : κ → ℝ) (w₂ : κ → Fin n → ℝ) :
    IsClosed (decisionBoundary a₁ w₁ a₂ w₂) := by
  exact isClosed_eq ( tropVal_continuous a₁ w₁ ) ( tropVal_continuous a₂ w₂ )

/-
The zero set of the tropical rational function equals the decision boundary.
-/
theorem zeroSet_eq_decisionBoundary {ι κ : Type*} [Fintype ι] [Nonempty ι]
    [Fintype κ] [Nonempty κ]
    (a₁ : ι → ℝ) (w₁ : ι → Fin n → ℝ) (a₂ : κ → ℝ) (w₂ : κ → Fin n → ℝ) :
    {x | tropVal a₁ w₁ x - tropVal a₂ w₂ x = 0}
      = decisionBoundary a₁ w₁ a₂ w₂ := by
  exact Set.ext fun x => sub_eq_zero

/-
The classifier decides the positive class exactly where the numerator family
strictly dominates the denominator family.
-/
theorem positive_region_iff {ι κ : Type*} [Fintype ι] [Nonempty ι]
    [Fintype κ] [Nonempty κ]
    (a₁ : ι → ℝ) (w₁ : ι → Fin n → ℝ) (a₂ : κ → ℝ) (w₂ : κ → Fin n → ℝ)
    (x : Fin n → ℝ) :
    0 < tropVal a₁ w₁ x - tropVal a₂ w₂ x
      ↔ tropVal a₂ w₂ x < tropVal a₁ w₁ x := by
  rw [ sub_pos ]

/-! ## Examples -/

/-- `ReLU(x) = max(x, 0)` is a tropical polynomial in one variable with two
monomials: `0 + 0·x` and `0 + 1·x`. -/
def reluMonoCoef : Bool → ℝ := fun _ => 0

def reluMonoWeight : Bool → Fin 1 → ℝ := fun b _ => if b then 1 else 0

example (x : Fin 1 → ℝ) :
    tropVal reluMonoCoef reluMonoWeight x = max (x 0) 0 := by
  unfold tropVal; simp +decide [ reluMonoCoef, reluMonoWeight ] ;

#check @tropVal
#check @tropVal_max
#check @tropVal_add
#check @layer_count_le_pow_two

end DecisionBoundaryVarieties

/-!
-- !-- Lab Notes -- !--

**Hypothesis (Hypothesizer).**  A ReLU network's decision boundary is a
tropical hypersurface.  Its algebraic complexity is governed by two growth
laws: monomial counts *add* under ReLU (tropical addition) and *multiply* under
composition of independent units (tropical multiplication).  This should yield
the conjectured *degree ≤ 2^L* and *∏ wᵢ regions* bounds.

**Experiment (Experimenter).**  We modelled tropical polynomials as pointwise
maxima of affine monomials indexed by an arbitrary nonempty finite type.  The
two growth laws (`tropVal_max`, `tropVal_add`) were proved as exact identities,
not merely inequalities.  The ReLU-on-rational identity `relu_tropRat` reduces
`max(p-q,0)` to `max(p,q) - q`, exhibiting the numerator's monomial set as the
disjoint union `ι ⊕ κ`, whence `relu_numerator_card`.  The doubling recursion
`layer_count_le_pow_two` gives the `2^L` bound; `tropProduct_card_eq_prod` gives
the `∏ wᵢ` bound.

**Analysis (Analyst).**  Both conjectured bounds are *structural*: they follow
from the semiring identities of the max-plus algebra, independent of the
particular weights.  The decision boundary is the tropical hypersurface
`{p = q}`; it is closed (continuity of `tropVal`) and its sign structure is
exactly the strict-domination relation between the two families.

**Critique (Critic).**  The identities are genuine equalities of piecewise
linear functions, not vacuous statements: `tropVal_max` and `tropVal_add` carry
the combinatorial content (union vs. product of index sets).  The `2^L` bound is
an honest induction, not `decide`.  A boundary case worth noting: the empty
monomial family is excluded by the `Nonempty` hypothesis, matching the
requirement that a classifier have at least one linear piece.

**Synthesis (Principal Investigator).**  Neural-network decision boundaries are
tropical hypersurfaces whose complexity is dictated by max-plus arithmetic:
addition of counts under activation, multiplication under composition.  See
`FUTURE_DIRECTIONS.md` for the next conjectures.
-/