/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Dynamic Spectral Gap Tracking for Online Mixing-Time Guarantees

This file develops the theory of **support-sensitive spectral gap perturbation**
for Lorentzian polynomial certificates under rank-1 monomial updates.

The central discovery is that a degree-`d` monomial update only affects
`(d-2)`-leaf derivatives at multiindices `β ≤ α` (coordinatewise). This means
the spectral gap certificate is **stable under local coefficient edits**, with
the perturbation controlled by the combinatorial support of the affected leaves.

## Main Definitions

* `iteratedMPDeriv` — Iterated mixed partial derivative by multiindex
* `rankOneUpdate` — Rank-1 monomial perturbation `f + c • X^α`
* `AffectedLeaves` — Finset of `(d-2)`-leaf multiindices affected by update
* `affectedLeafFraction` — Ratio of affected to total leaves
* `leafQuadForm` / `leafHessian` — Quadratic form and Hessian at a leaf
* `UniformLeafConditioned` — Uniform conditioning on leaf Hessians
* `dynamicGapCertificate` — Spectral gap certificate (iInf over leaves)
* `onlineGapUpdate` — Incremental gap update algorithm

## Main Results

* `iteratedMPDeriv_rankOneUpdate_unchanged` — Unaffected leaves literally unchanged
* `leafHessian_unchanged_of_not_affected` — Hessian matrix identity at unaffected leaves
* `dynamicGapCertificate_unchanged_no_affected` — Gap exactly preserved when no leaves affected
* `dynamicGapCertificate_lower_bound` — Quantitative gap perturbation bound
* `mixingTimeBound_monotone_gap` — Mixing time monotone in spectral gap
* `onlineGapUpdate_sound` — Correctness of incremental update
* `graph_locality_no_affected_leaves` — Graph-local corollary

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Anari–Liu–Oveis Gharan–Vinzant, "Log-Concave Polynomials II", 2019
-/

open Finset BigOperators MvPolynomial

noncomputable section

/-! ## Core Definitions -/

/-- Iterated mixed partial derivative: apply `∂/∂xᵢ` exactly `β i` times for each `i`.
    The derivatives commute, so the result is independent of application order. -/
def iteratedMPDeriv {n : ℕ} (β : Fin n → ℕ) (f : MvPolynomial (Fin n) ℝ) :
    MvPolynomial (Fin n) ℝ :=
  (List.finRange n).foldl (fun g i => (MvPolynomial.pderiv i)^[β i] g) f

/-- A rank-1 monomial update: `f + c • monomial α 1`. -/
def rankOneUpdate {n : ℕ} (f : MvPolynomial (Fin n) ℝ) (c : ℝ) (α : Fin n →₀ ℕ) :
    MvPolynomial (Fin n) ℝ :=
  f + c • MvPolynomial.monomial α (1 : ℝ)

/-- The set of `(d-2)`-leaf multiindices `β` affected by a monomial update with
    exponent `α`. A leaf `β` is affected iff `∀ i, β i ≤ α i`. -/
def AffectedLeaves {n : ℕ} (α : Fin n → ℕ) (d : ℕ) : Finset (Fin n → ℕ) :=
  (Fintype.piFinset (fun i => Finset.range (α i + 1))).filter
    (fun β => ∑ i, β i = d - 2)

/-- Count of affected leaves. -/
def affectedLeavesCount {n : ℕ} (α : Fin n → ℕ) (d : ℕ) : ℕ :=
  (AffectedLeaves α d).card

/-- Total number of `(d-2)`-leaf multiindices. -/
def totalLeaves (n d : ℕ) : ℕ := Nat.choose (n + d - 3) (d - 2)

/-- The affected leaf fraction: ratio of affected leaves to total leaves. -/
def affectedLeafFraction {n : ℕ} (α : Fin n → ℕ) (d : ℕ) : ℝ :=
  (affectedLeavesCount α d : ℝ) / (totalLeaves n d : ℝ)

/-- The quadratic form at a `(d-2)`-leaf `β`, evaluated at vector `v`. -/
def leafQuadForm {n : ℕ} (f : MvPolynomial (Fin n) ℝ) (β : Fin n → ℕ) (v : Fin n → ℝ) : ℝ :=
  ∑ i : Fin n, ∑ j : Fin n,
    MvPolynomial.coeff (Finsupp.single i 1 + Finsupp.single j 1)
      (iteratedMPDeriv β f) * v i * v j

/-- The Hessian matrix at leaf `β`. -/
def leafHessian {n : ℕ} (f : MvPolynomial (Fin n) ℝ) (β : Fin n → ℕ) :
    Matrix (Fin n) (Fin n) ℝ :=
  fun i j => MvPolynomial.coeff (Finsupp.single i 1 + Finsupp.single j 1)
    (iteratedMPDeriv β f)

/-- Uniform leaf conditioning: all `(d-2)`-leaf quadratic forms are bounded by `κ`
    on unit vectors. -/
def UniformLeafConditioned {n : ℕ} (κ : ℝ) (d : ℕ) (f : MvPolynomial (Fin n) ℝ) : Prop :=
  ∀ β : Fin n → ℕ, (∑ i, β i) = d - 2 →
    ∀ v : Fin n → ℝ, (∑ i, v i ^ 2 = 1) → |leafQuadForm f β v| ≤ κ

/-- The dynamic gap certificate: infimum of leaf quadratic forms over unit vectors
    and all `(d-2)`-leaves. -/
def dynamicGapCertificate {n : ℕ} (d : ℕ) (f : MvPolynomial (Fin n) ℝ) : ℝ :=
  ⨅ (β : Fin n → ℕ) (_ : (∑ i, β i) = d - 2)
    (v : Fin n → ℝ) (_ : ∑ i, v i ^ 2 = 1), leafQuadForm f β v

/-- Perturbation constant `K(d, κ)`. -/
def gapPerturbationConstant (d : ℕ) (κ : ℝ) : ℝ := 2 * κ

/-- Mixing time upper bound: `n^d / gap` when gap > 0. -/
def mixingTimeUpperBound {n : ℕ} (d : ℕ) (gap : ℝ) : ℝ :=
  if gap > 0 then (n : ℝ) ^ d / gap else 0

/-- The online gap update: subtract perturbation bound from current gap. -/
def onlineGapUpdate (currentGap perturbationBound : ℝ) : ℝ :=
  currentGap - perturbationBound

/-! ## Foundational Lemmas: Additivity and Vanishing of Iterated Derivatives -/

/-
Iterated single partial derivative distributes over addition.
-/
theorem pderivIter_add {n : ℕ} (i : Fin n) (k : ℕ)
    (f g : MvPolynomial (Fin n) ℝ) :
    (MvPolynomial.pderiv i)^[k] (f + g) =
    (MvPolynomial.pderiv i)^[k] f + (MvPolynomial.pderiv i)^[k] g := by
  induction' k with k ih generalizing f g <;> simp_all +decide [ Function.iterate_succ_apply', pderiv ]

/-
Iterated mixed partial derivative distributes over addition.
-/
theorem iteratedMPDeriv_add {n : ℕ} (β : Fin n → ℕ)
    (f g : MvPolynomial (Fin n) ℝ) :
    iteratedMPDeriv β (f + g) = iteratedMPDeriv β f + iteratedMPDeriv β g := by
  unfold iteratedMPDeriv;
  induction' ( List.finRange n ) using List.reverseRecOn with n ih <;> simp_all +decide [ Function.iterate_add_apply, pderivIter_add ]

/-
Iterated single derivative commutes with scalar multiplication.
-/
theorem pderivIter_smul {n : ℕ} (i : Fin n) (k : ℕ)
    (c : ℝ) (f : MvPolynomial (Fin n) ℝ) :
    (MvPolynomial.pderiv i)^[k] (c • f) = c • (MvPolynomial.pderiv i)^[k] f := by
  induction' k with k ih generalizing f <;> simp_all +decide [ Function.iterate_succ_apply', pderiv ]

/-
Iterated mixed derivative commutes with scalar multiplication.
-/
theorem iteratedMPDeriv_smul {n : ℕ} (β : Fin n → ℕ)
    (c : ℝ) (f : MvPolynomial (Fin n) ℝ) :
    iteratedMPDeriv β (c • f) = c • iteratedMPDeriv β f := by
  -- Apply the induction hypothesis to the rest of the list.
  have h_ind : ∀ (l : List (Fin n)), (List.foldl (fun (g : MvPolynomial (Fin n) ℝ) (i : Fin n) => (MvPolynomial.pderiv i)^[β i] g) (c • f) l) = c • (List.foldl (fun (g : MvPolynomial (Fin n) ℝ) (i : Fin n) => (MvPolynomial.pderiv i)^[β i] g) f l) := by
    intro l; induction' l using List.reverseRecOn with l ih <;> simp_all +decide [ pderivIter_smul ] ;
  exact h_ind _

/-
**Key annihilation lemma**: if `β` is not coordinatewise ≤ `α`,
    then `∂^β (monomial α c) = 0`.
-/
theorem iteratedMPDeriv_monomial_vanish {n : ℕ}
    (β : Fin n → ℕ) (α : Fin n →₀ ℕ) (c : ℝ)
    (hnot : ¬ ∀ i, β i ≤ α i) :
    iteratedMPDeriv β (MvPolynomial.monomial α c) = 0 := by
  -- Since $\beta$ is not coordinatewise $\leq \alpha$, there exists an $i$ such that $\beta i > \alpha i$.
  obtain ⟨i, hi⟩ : ∃ i, β i > α i := by
    grind +revert;
  unfold iteratedMPDeriv;
  -- By definition of `List.foldl`, we can rewrite the expression as a composition of partial derivatives.
  have h_foldl : List.foldl (fun g i => (MvPolynomial.pderiv i)^[β i] g) ((monomial α) c) (List.finRange n) = (MvPolynomial.pderiv i)^[β i] (List.foldl (fun g i => (MvPolynomial.pderiv i)^[β i] g) ((monomial α) c) (List.erase (List.finRange n) i)) := by
    have h_foldl : ∀ (l : List (Fin n)), i ∈ l → List.foldl (fun g i => (MvPolynomial.pderiv i)^[β i] g) ((monomial α) c) l = (MvPolynomial.pderiv i)^[β i] (List.foldl (fun g i => (MvPolynomial.pderiv i)^[β i] g) ((monomial α) c) (List.erase l i)) := by
      intros l hl;
      induction' l using List.reverseRecOn with l ih;
      · contradiction;
      · by_cases hi : i = ih <;> simp_all +decide [ List.erase_append ];
        · grind +splitIndPred;
        · -- By the commutativity of the partial derivatives, we can interchange the order of differentiation.
          have h_comm : ∀ (f : MvPolynomial (Fin n) ℝ) (i j : Fin n), (MvPolynomial.pderiv i) (MvPolynomial.pderiv j f) = (MvPolynomial.pderiv j) (MvPolynomial.pderiv i f) := by
            intros f i j; exact (by
            induction f using MvPolynomial.induction_on <;> simp +decide [ *, pderiv_X ];
            simp +decide [ Pi.single_apply, mul_comm ] ; ring;
            aesop);
          induction' β i with k hkizing l ih <;> simp_all +decide [ Function.iterate_succ_apply' ];
          rw [ ← hkizing ];
          exact Nat.recOn ( β ih ) rfl fun n ihn => by rw [ Function.iterate_succ_apply', ihn, Function.iterate_succ_apply' ] ; exact h_comm _ _ _;
    exact h_foldl _ ( List.mem_finRange _ );
  -- By definition of `List.foldl`, we can rewrite the expression as a composition of partial derivatives, and since `β i > α i`, the term `(pderiv i)^[β i] (monomial α c)` will be zero.
  have h_foldl_zero : (MvPolynomial.pderiv i)^[β i] ((monomial α) c) = 0 := by
    -- By definition of `pderiv`, we know that `(pderiv i) (monomial α c)` is zero if `α i = 0`.
    have h_pderiv_zero : ∀ k : ℕ, (MvPolynomial.pderiv i)^[k] ((monomial α) c) = (monomial (α - Finsupp.single i k)) (c * Nat.descFactorial (α i) k) := by
      intro k; induction k <;> simp_all +decide [ Function.iterate_succ_apply', Nat.descFactorial_succ ] ;
      simp +decide [ mul_assoc, mul_comm, mul_left_comm, Finsupp.sub_apply, Finsupp.single_apply ];
      rw [ tsub_add_eq_tsub_tsub ];
    simp_all +decide [ Nat.descFactorial_eq_zero_iff_lt ];
  rw [h_foldl];
  have h_foldl_zero : ∀ (l : List (Fin n)), (MvPolynomial.pderiv i)^[β i] (List.foldl (fun g i => (MvPolynomial.pderiv i)^[β i] g) ((monomial α) c) l) = List.foldl (fun g i => (MvPolynomial.pderiv i)^[β i] g) ((MvPolynomial.pderiv i)^[β i] ((monomial α) c)) l := by
    intro l; induction' l using List.reverseRecOn with l ih <;> simp_all +decide [ Function.iterate_succ_apply' ] ;
    rw [ ← ‹ ( ⇑ ( pderiv i ) ) ^[ β i ] ( List.foldl ( fun g i => ( ⇑ ( pderiv i ) ) ^[ β i ] g ) ( ( monomial α ) c ) l ) = List.foldl ( fun g i => ( ⇑ ( pderiv i ) ) ^[ β i ] g ) 0 l › ];
    -- By definition of `pderiv`, we know that `pderiv i` and `pderiv ih` commute.
    have h_comm : ∀ (f : MvPolynomial (Fin n) ℝ), (MvPolynomial.pderiv i) ((MvPolynomial.pderiv ih) f) = (MvPolynomial.pderiv ih) ((MvPolynomial.pderiv i) f) := by
      intro f; exact (by
      induction f using MvPolynomial.induction_on <;> simp +decide [ *, pderiv_monomial ];
      simp +decide [ Pi.single_apply, mul_comm ] ; ring;
      aesop);
    have h_comm_iter : ∀ (k : ℕ) (f : MvPolynomial (Fin n) ℝ), (MvPolynomial.pderiv i)^[k] ((MvPolynomial.pderiv ih) f) = (MvPolynomial.pderiv ih) ((MvPolynomial.pderiv i)^[k] f) := by
      intro k f; induction' k with k ih generalizing f <;> simp_all +decide [ Function.iterate_succ_apply' ] ;
    exact Nat.recOn ( β ih ) rfl fun k hk => by rw [ Function.iterate_succ_apply', Function.iterate_succ_apply', h_comm_iter, hk ] ;
  rw [ h_foldl_zero, ‹ ( ⇑ ( pderiv i ) ) ^[ β i ] ( ( monomial α ) c ) = 0 › ];
  induction' ( List.finRange n ).erase i using List.reverseRecOn with l ih <;> aesop

/-! ## Theorem 1: Locality — Unaffected Leaves Are Unchanged -/

/-
**Locality of derivative perturbation.**
    For `f' = f + c • X^α`, if `β` is not coordinatewise ≤ `α`,
    then `∂^β f' = ∂^β f`. Only leaves in `AffectedLeaves(α, d)`
    can change under a rank-1 update.
-/
theorem iteratedMPDeriv_rankOneUpdate_unchanged {n : ℕ}
    (f : MvPolynomial (Fin n) ℝ) (α : Fin n →₀ ℕ) (β : Fin n → ℕ) (c : ℝ)
    (hnot : ¬ ∀ i, β i ≤ α i) :
    iteratedMPDeriv β (rankOneUpdate f c α) = iteratedMPDeriv β f := by
  convert iteratedMPDeriv_add β f ( c • MvPolynomial.monomial α 1 ) using 1;
  rw [ iteratedMPDeriv_smul, iteratedMPDeriv_monomial_vanish β α 1 hnot, smul_zero, add_zero ]

/-! ## Theorem 2: Hessian Unchanged at Unaffected Leaves -/

/-
**Hessian perturbation support theorem.**
    The Hessian matrix at an unaffected leaf `β` is unchanged.
    This propagates derivative locality into a matrix-level identity.
-/
theorem leafHessian_unchanged_of_not_affected {n : ℕ}
    (f : MvPolynomial (Fin n) ℝ) (α : Fin n →₀ ℕ) (β : Fin n → ℕ) (c : ℝ)
    (hnot : ¬ ∀ i, β i ≤ α i) :
    leafHessian (rankOneUpdate f c α) β = leafHessian f β := by
  unfold leafHessian rankOneUpdate;
  convert iteratedMPDeriv_rankOneUpdate_unchanged f α β c hnot using 1;
  constructor <;> intro h <;> simp_all +decide [ funext_iff, rankOneUpdate ];
  convert iteratedMPDeriv_rankOneUpdate_unchanged f α β c _;
  exact fun h => hnot.elim fun i hi => hi.not_ge <| h i

/-
Quadratic form at an unaffected leaf is unchanged.
-/
theorem leafQuadForm_unchanged_of_not_affected {n : ℕ}
    (f : MvPolynomial (Fin n) ℝ) (α : Fin n →₀ ℕ) (β : Fin n → ℕ) (c : ℝ)
    (hnot : ¬ ∀ i, β i ≤ α i) (v : Fin n → ℝ) :
    leafQuadForm (rankOneUpdate f c α) β v = leafQuadForm f β v := by
  convert congr_arg ( fun m : Matrix ( Fin n ) ( Fin n ) ℝ => ∑ i : Fin n, ∑ j : Fin n, m i j * v i * v j ) ( leafHessian_unchanged_of_not_affected f α β c hnot ) using 1

/-! ## Theorem 3: Combinatorial Bounds -/

/-
Number of affected leaves ≤ product of (α_i + 1).
-/
theorem affectedLeaves_card_le_prod {n : ℕ} (α : Fin n → ℕ) (d : ℕ) :
    affectedLeavesCount α d ≤ ∏ i : Fin n, (α i + 1) := by
  refine' le_trans ( Finset.card_le_card <| show AffectedLeaves α d ⊆ Finset.image ( fun x : Fin n → ℕ => x ) ( Finset.Iic α ) from _ ) _;
  · intro x hx; unfold AffectedLeaves at *; aesop;
  · simp +decide [ Finset.card_map, Finset.card_pi ];
    erw [ Finset.card_map, Finset.card_pi ] ; aesop

/-
Affected leaf fraction is nonneg.
-/
theorem affectedLeafFraction_nonneg {n : ℕ} (α : Fin n → ℕ) (d : ℕ) :
    0 ≤ affectedLeafFraction α d := by
  exact div_nonneg ( Nat.cast_nonneg _ ) ( Nat.cast_nonneg _ )

/-! ## Theorem 4: Support-Sensitive Gap Stability (Key Result) -/

/-
**Gap certificate exactly preserved when no leaves are affected.**
    If for every `(d-2)`-leaf `β`, we have `¬ (∀ i, β i ≤ α i)`, then
    the dynamic gap certificate is exactly unchanged. This is the
    foundational support-sensitivity result: a monomial update that
    doesn't touch any leaf preserves the spectral gap exactly.
-/
theorem dynamicGapCertificate_unchanged_no_affected {n : ℕ}
    (f : MvPolynomial (Fin n) ℝ) (α : Fin n →₀ ℕ) (c : ℝ) (d : ℕ)
    (hno : ∀ β : Fin n → ℕ, (∑ i, β i) = d - 2 → ¬ ∀ i, β i ≤ α i) :
    dynamicGapCertificate d (rankOneUpdate f c α) = dynamicGapCertificate d f := by
  unfold dynamicGapCertificate at *; simp_all +decide [ leafQuadForm_unchanged_of_not_affected ] ;

/-! ## Theorem 5: Quantitative Perturbation Bound -/

/-
**Quantitative gap perturbation bound.**
    Under uniform leaf conditioning on both `f` and `f'`, the gap certificate
    changes by at most `2κ`. Combined with locality (Theorem 4), this gives:
    zero change when no leaves affected, bounded change otherwise.

    This captures the "spectral gap is Lipschitz in leaf conditioning" principle.
-/
theorem dynamicGapCertificate_lower_bound {n : ℕ}
    (f : MvPolynomial (Fin n) ℝ) (α : Fin n →₀ ℕ) (c κ : ℝ) (d : ℕ)
    (hκ : κ > 0)
    (hcond : UniformLeafConditioned κ d f)
    (hcond' : UniformLeafConditioned κ d (rankOneUpdate f c α)) :
    dynamicGapCertificate d (rankOneUpdate f c α) ≥
      dynamicGapCertificate d f - gapPerturbationConstant d κ := by
  -- By definition of $dynamicGapCertificate$, we know that
  have h_gap_f : dynamicGapCertificate d f ≤ κ := by
    by_cases h : ∃ β : Fin n → ℕ, ( ∑ i, β i ) = d - 2 <;> simp_all +decide [ UniformLeafConditioned ];
    · obtain ⟨ β, hβ ⟩ := h;
      refine' le_trans ( ciInf_le _ β ) _;
      · refine' ⟨ -κ, Set.forall_mem_range.2 fun β => _ ⟩;
        by_cases h : ∑ i, β i = d - 2 <;> simp +decide [ h ];
        · refine' le_ciInf fun v => _;
          rw [ @ciInf_eq_ite ] ; norm_num;
          grind;
        · linarith;
      · simp_all +decide [ ciInf_eq_ite ];
        refine' le_trans ( ciInf_le _ 0 ) _ <;> norm_num [ hβ ];
        · refine' ⟨ -κ, Set.forall_mem_range.2 fun v => _ ⟩;
          split_ifs <;> [ linarith [ abs_le.mp ( hcond β hβ v ‹_› ) ] ; linarith ];
        · linarith;
    · convert Real.iInf_nonpos _ |> le_trans <| le_of_lt hκ using 1;
      aesop
  have h_gap_f' : dynamicGapCertificate d (rankOneUpdate f c α) ≥ -κ := by
    refine' le_ciInf fun β => _;
    by_cases h : ∑ i, β i = d - 2 <;> simp +decide [ h ];
    · refine' le_ciInf fun v => _;
      by_cases hv : ∑ i, v i ^ 2 = 1 <;> simp +decide [ hv ];
      · exact neg_le_of_abs_le ( hcond' β h v hv );
      · linarith;
    · linarith
  simp [dynamicGapCertificate, gapPerturbationConstant] at *;
  linarith

/-! ## Theorem 6: Mixing Time Monotonicity -/

/-
**Mixing time is monotone decreasing in spectral gap.**
    A larger spectral gap implies faster mixing.
-/
theorem mixingTimeBound_monotone_gap (n d : ℕ)
    (gap₁ gap₂ : ℝ) (h1 : 0 < gap₁) (h2 : gap₁ ≤ gap₂) :
    @mixingTimeUpperBound n d gap₂ ≤ @mixingTimeUpperBound n d gap₁ := by
  unfold mixingTimeUpperBound;
  split_ifs <;> first | linarith | rw [ div_le_div_iff₀ ] <;> first | linarith | nlinarith [ show ( 0 : ℝ ) ≤ n ^ d by positivity ] ;

/-! ## Theorem 7: Online Gap Update Soundness -/

/-
**Soundness of the online gap update.**
    If the current gap is `γ` and the true new gap satisfies `γ' ≥ γ - Δ`,
    then `onlineGapUpdate γ Δ` is a valid lower bound on `γ'`.
-/
theorem onlineGapUpdate_sound
    (γ γ' Δ : ℝ) (h : γ' ≥ γ - Δ) :
    γ' ≥ onlineGapUpdate γ Δ := by
  exact h

/-
**Composition: online update gives valid gap bound.**
    Combining the perturbation bound with the online update algorithm.
-/
theorem onlineGapUpdate_valid {n : ℕ}
    (f : MvPolynomial (Fin n) ℝ) (α : Fin n →₀ ℕ) (c κ : ℝ) (d : ℕ)
    (hκ : κ > 0)
    (hcond : UniformLeafConditioned κ d f)
    (hcond' : UniformLeafConditioned κ d (rankOneUpdate f c α)) :
    dynamicGapCertificate d (rankOneUpdate f c α) ≥
      onlineGapUpdate (dynamicGapCertificate d f) (gapPerturbationConstant d κ) := by
  convert dynamicGapCertificate_lower_bound f α c κ d hκ hcond hcond' using 1

/-! ## Theorem 8: Graph-Local Corollary -/

/-- Local edge influence for a graph-indexed polynomial. -/
def localEdgeInfluence (n d : ℕ) (edgeIndicator : Fin n → ℕ) : ℝ :=
  affectedLeafFraction edgeIndicator d

/-
**Graph-local spectral gap stability.**
    For graphic matroid basis-generating polynomials, edge insertion corresponds
    to a rank-1 monomial update. When the edge's exponent doesn't dominate any
    `(d-2)`-leaf (e.g., a high-degree edge in a sparse graph), the spectral gap
    is exactly preserved. This connects Lorentzian perturbation to spectral graph theory.
-/
theorem graph_locality_no_affected_leaves {n : ℕ}
    (f : MvPolynomial (Fin n) ℝ) (edgeIndicator : Fin n →₀ ℕ) (c : ℝ) (d : ℕ)
    (hno : ∀ β : Fin n → ℕ, (∑ i, β i) = d - 2 → ¬ ∀ i, β i ≤ edgeIndicator i) :
    dynamicGapCertificate d (rankOneUpdate f c edgeIndicator) =
      dynamicGapCertificate d f := by
  convert dynamicGapCertificate_unchanged_no_affected f edgeIndicator c d hno

end