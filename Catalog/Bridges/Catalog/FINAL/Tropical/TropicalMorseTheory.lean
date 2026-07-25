/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Morse Theory for Piecewise-Linear Optimization Landscapes

This file formalizes **corner critical points** in tropical geometry: singularities of
piecewise-linear (max-plus) functions where optimization trajectories encounter
combinatorial obstructions to descent. This is a tropical analogue of classical
Morse theory, adapted to the nonsmooth geometry of max-of-affines functions.

## Mathematical Overview

A tropical loss function takes the form `f(x) = max_i (ℓ_i(x) + c_i)` — the
pointwise maximum of finitely many affine functions. The **corner locus** is the
set of points where at least two affine pieces simultaneously achieve the maximum.
At such points, the function is non-differentiable, and the combinatorial structure
of which pieces are "active" changes. These corner crossings are the tropical
analogue of phase transitions.

A **corner critical point** is a point on the corner locus where active pieces
produce conflicting directional derivatives: for every direction, the active
gradients do not all agree in sign. This means no local descent is possible
without changing the active set — a genuine variational obstruction.

## Main Definitions

* `AffinePiece` — An affine function on ℝⁿ, with a linear map and bias
* `evalPiece` — Evaluation of an affine piece at a point
* `tropicalMax` — Max-plus tropical function: max of finitely many affine pieces
* `activeIndices` — Indices of pieces achieving the maximum at a point
* `cornerLocus` — Points where ≥ 2 pieces are simultaneously active
* `cornerCritical` — Corner locus + pairwise sign obstruction on all directions
* `wallEq` — The wall (codimension-1 face) where two specific pieces are equal

## Main Results

* `evalPiece_continuous` — Evaluation is continuous
* `tropicalMax_continuous` — The tropical max function is continuous
* `exists_cornerLocus_on_transition_path` — A transition path between regions
  where distinct pieces are uniquely active must cross the corner locus (IVT)
* `cornerCritical_of_opposing_gradients` — Two-piece walls with opposing gradients
  are corner critical
* `tropicalMorseIndex_eq_one_two_piece` — The tropical Morse index of a
  two-piece wall with full opposition equals 1
* `graph_localMax_exists` — Every finite nonempty graph has a local maximum

## References

* Mikhalkin, "Tropical geometry and its applications" (2006)
* Itenberg, Mikhalkin, Shustin, "Tropical algebraic geometry" (2009)
* Zhang, Naitzat, Lim, "Tropical geometry of deep neural networks" (2018)
-/

noncomputable section

open Finset BigOperators Set Classical

/-! ## Core Definitions -/

/-- An **affine piece** on `ℝⁿ`: a linear functional plus a bias constant.
This represents one branch of a piecewise-affine tropical function. -/
structure AffinePiece (n : ℕ) where
  lin : (Fin n → ℝ) →ₗ[ℝ] ℝ
  bias : ℝ

/-- Evaluate an affine piece at a point `x ∈ ℝⁿ`. -/
def evalPiece {n : ℕ} (p : AffinePiece n) (x : Fin n → ℝ) : ℝ :=
  p.lin x + p.bias

/-- The **tropical max function**: pointwise maximum of a finite indexed family
of affine pieces. This is the fundamental building block of piecewise-linear
functions arising in tropical geometry and ReLU neural networks. -/
def tropicalMax {n m : ℕ} [NeZero m] (P : Fin m → AffinePiece n)
    (x : Fin n → ℝ) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty (fun i => evalPiece (P i) x)

/-- The **active indices** at a point `x`: indices of affine pieces that achieve
the maximum value. When multiple indices are active, `x` lies on the corner locus. -/
def activeIndices {n m : ℕ} [NeZero m] (P : Fin m → AffinePiece n)
    (x : Fin n → ℝ) : Finset (Fin m) :=
  Finset.univ.filter (fun i => evalPiece (P i) x = tropicalMax P x)

/-- The **corner locus**: the set of points where at least two affine pieces
simultaneously achieve the maximum. This is the tropical analogue of the
singular set of the function — the non-differentiable locus. -/
def cornerLocus {n m : ℕ} [NeZero m] (P : Fin m → AffinePiece n) :
    Set (Fin n → ℝ) :=
  {x | 2 ≤ (activeIndices P x).card}

/-- A point `x` is **corner critical** if it lies on the corner locus and for
every direction `v`, the active pieces produce conflicting directional
derivatives: either all vanish, or some pair has non-positive product.
This is the tropical analogue of a critical point in classical Morse theory. -/
def cornerCritical {n m : ℕ} [NeZero m] (P : Fin m → AffinePiece n)
    (x : Fin n → ℝ) : Prop :=
  x ∈ cornerLocus P ∧
  ∀ v : Fin n → ℝ,
    (∀ i ∈ activeIndices P x, (P i).lin v = 0) ∨
    ∃ i ∈ activeIndices P x, ∃ j ∈ activeIndices P x,
      (P i).lin v * (P j).lin v ≤ 0

/-- The **wall** where two specific affine pieces have equal value.
This is the codimension-1 tropical hyperplane separating their dominance regions. -/
def wallEq {n : ℕ} (p q : AffinePiece n) : Set (Fin n → ℝ) :=
  {x | evalPiece p x = evalPiece q x}

/-! ## Continuity Lemmas -/

/-- Evaluation of an affine piece is continuous as a function of `x`. -/
theorem evalPiece_continuous {n : ℕ} (p : AffinePiece n) :
    Continuous (evalPiece p) :=
  (LinearMap.continuous_of_finiteDimensional p.lin).add continuous_const

/-
The tropical max function is continuous. As the pointwise maximum of
finitely many continuous affine functions, it inherits continuity.
-/
theorem tropicalMax_continuous {n m : ℕ} [NeZero m]
    (P : Fin m → AffinePiece n) :
    Continuous (tropicalMax P) := by
      -- The tropical max function is the pointwise maximum of finitely many continuous functions; hence, it is continuous as well.
      have h_continuous : ∀ x : Fin n → ℝ, tropicalMax P x = sSup (Set.range (fun i : Fin m => evalPiece (P i) x)) := by
        intro x
        unfold tropicalMax;
        rw [ @csSup_eq_of_forall_le_of_forall_lt_exists_gt ] <;> norm_num;
        · exact ⟨ _, ⟨ ⟨ 0, NeZero.pos m ⟩, rfl ⟩ ⟩;
        · exact fun a => ⟨ a, le_rfl ⟩;
      simp_all +decide [ continuous_iff_continuousAt ];
      intro x
      have h_cont_at : ContinuousAt (fun x => sSup (Set.range (fun i : Fin m => evalPiece (P i) x))) x := by
        refine' tendsto_order.2 ⟨ _, _ ⟩;
        · intro a' ha';
          -- Since $a' < \sup_{i} \text{evalPiece}(P_i, x)$, there exists some $i$ such that $a' < \text{evalPiece}(P_i, x)$.
          obtain ⟨i, hi⟩ : ∃ i : Fin m, a' < evalPiece (P i) x := by
            contrapose! ha';
            exact csSup_le ( Set.nonempty_of_mem ( Set.mem_range_self ⟨ 0, NeZero.pos m ⟩ ) ) ( Set.forall_mem_range.mpr ha' );
          -- Since $a' < \text{evalPiece}(P_i, x)$, and $\text{evalPiece}(P_i, \cdot)$ is continuous, there exists a neighborhood around $x$ where $a' < \text{evalPiece}(P_i, y)$ for all $y$ in this neighborhood.
          have h_neighborhood : ∀ᶠ y in nhds x, a' < evalPiece (P i) y := by
            exact IsOpen.mem_nhds ( isOpen_lt continuous_const ( evalPiece_continuous _ ) ) hi;
          filter_upwards [ h_neighborhood ] with y hy using lt_of_lt_of_le hy ( le_csSup ( Set.finite_range _ |> Set.Finite.bddAbove ) ( Set.mem_range_self _ ) );
        · intro a ha;
          -- Since $a > \sup_{i} \text{evalPiece}(P_i, x)$, there exists some $\epsilon > 0$ such that for all $i$, $\text{evalPiece}(P_i, x) < a - \epsilon$.
          obtain ⟨ε, hε_pos, hε⟩ : ∃ ε > 0, ∀ i, evalPiece (P i) x < a - ε := by
            exact ⟨ ( a - SupSet.sSup ( Set.range fun i => evalPiece ( P i ) x ) ) / 2, half_pos ( sub_pos.mpr ha ), fun i => by linarith [ le_csSup ( Set.finite_range ( fun i => evalPiece ( P i ) x ) |> Set.Finite.bddAbove ) ( Set.mem_range_self i ) ] ⟩;
          -- Since $evalPiece (P i)$ is continuous, there exists a neighborhood $U$ of $x$ such that for all $y \in U$, $evalPiece (P i) y < a - \epsilon$.
          have h_neighborhood : ∀ i, ∃ U : Set (Fin n → ℝ), IsOpen U ∧ x ∈ U ∧ ∀ y ∈ U, evalPiece (P i) y < a - ε := by
            exact fun i => ⟨ { y | evalPiece ( P i ) y < a - ε }, isOpen_lt ( evalPiece_continuous ( P i ) ) continuous_const, hε i, fun y hy => hy ⟩;
          choose U hU₁ hU₂ hU₃ using h_neighborhood;
          filter_upwards [ IsOpen.mem_nhds ( show IsOpen ( ⋂ i, U i ) from isOpen_iInter_of_finite fun i => hU₁ i ) ( Set.mem_iInter.mpr fun i => hU₂ i ) ] with y hy using lt_of_le_of_lt ( csSup_le ( Set.nonempty_of_mem <| Set.mem_range_self <| ⟨ 0, NeZero.pos m ⟩ ) <| Set.forall_mem_range.mpr fun i => le_of_lt <| hU₃ i y <| Set.mem_iInter.mp hy i ) <| by linarith;
      exact h_cont_at.congr (Filter.eventuallyEq_of_mem (Metric.ball_mem_nhds x zero_lt_one) fun y hy => by rw [h_continuous])

/-! ## Active Index Properties -/

/-
The active indices set is always nonempty: at least one piece achieves the max.
-/
theorem activeIndices_nonempty {n m : ℕ} [NeZero m]
    (P : Fin m → AffinePiece n) (x : Fin n → ℝ) :
    (activeIndices P x).Nonempty := by
      -- By definition of `tropicalMax`, there exists some index `i` such that `evalPiece (P i) x = tropicalMax P x`.
      obtain ⟨i, hi⟩ : ∃ i : Fin m, evalPiece (P i) x = tropicalMax P x := by
        convert Finset.max'_mem _ _;
        rotate_left;
        exact ℝ;
        exact inferInstance;
        exact Finset.image ( fun i => evalPiece ( P i ) x ) Finset.univ;
        exact ⟨ _, Finset.mem_image_of_mem _ ( Finset.mem_univ ⟨ 0, NeZero.pos m ⟩ ) ⟩;
        simp +decide [ Finset.max', tropicalMax ];
      exact ⟨ i, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hi ⟩ ⟩

/-- Every affine piece evaluates to at most the tropical max. -/
theorem evalPiece_le_tropicalMax {n m : ℕ} [NeZero m]
    (P : Fin m → AffinePiece n) (x : Fin n → ℝ) (i : Fin m) :
    evalPiece (P i) x ≤ tropicalMax P x := by
  exact Finset.le_sup' (fun i => evalPiece (P i) x) (Finset.mem_univ i)

/-- An active index achieves the tropical max value. -/
theorem active_eq_tropicalMax {n m : ℕ} [NeZero m]
    (P : Fin m → AffinePiece n) (x : Fin n → ℝ) (i : Fin m)
    (hi : i ∈ activeIndices P x) :
    evalPiece (P i) x = tropicalMax P x :=
  (Finset.mem_filter.mp hi).2

/-- Membership criterion for active indices. -/
theorem mem_activeIndices_iff {n m : ℕ} [NeZero m]
    (P : Fin m → AffinePiece n) (x : Fin n → ℝ) (i : Fin m) :
    i ∈ activeIndices P x ↔ evalPiece (P i) x = tropicalMax P x := by
  simp [activeIndices]

/-! ## Main Theorem A: Corner Locus on Transition Paths

The central result: if a continuous path connects a region where piece `i` is
uniquely active to a region where piece `j ≠ i` is uniquely active, the path
must cross the corner locus. This is a tropical IVT theorem.

**Proof strategy**: The difference `evalPiece (P i) (γ t) - evalPiece (P j) (γ t)`
is continuous and changes sign between `t₀` and `t₁`. By the intermediate value
theorem, it has a zero `t*`. At `t*`, both pieces `i` and `j` evaluate equally.
For the general case (more than 2 pieces), we use a topological argument:
if the corner locus is never hit, the active index function is locally constant
on the connected set `[t₀, t₁]`, hence constant, contradicting `i ≠ j`. -/

/-
**Two-piece wall crossing lemma (IVT)**: If piece `p` strictly dominates piece `q`
at time `t₀` and vice versa at time `t₁`, and `γ` is continuous, then the path
crosses the wall where `p` and `q` equalize.
-/
theorem exists_wall_crossing_two_piece {n : ℕ}
    (p q : AffinePiece n) (γ : ℝ → Fin n → ℝ) (t₀ t₁ : ℝ)
    (ht : t₀ ≤ t₁)
    (hγ : Continuous γ)
    (hp_start : evalPiece q (γ t₀) < evalPiece p (γ t₀))
    (hq_end : evalPiece p (γ t₁) < evalPiece q (γ t₁)) :
    ∃ t ∈ Set.Icc t₀ t₁, evalPiece p (γ t) = evalPiece q (γ t) := by
      -- By continuity, there exists a time $t \in [t_0, t_1]$ where $g(t) = 0$.
      have hg_zero : ∃ t ∈ Set.Icc t₀ t₁, (evalPiece p (γ t)) - (evalPiece q (γ t)) = 0 := by
        apply_rules [ intermediate_value_Icc' ];
        · exact ContinuousOn.sub ( evalPiece_continuous p |> Continuous.comp_continuousOn <| hγ.continuousOn ) ( evalPiece_continuous q |> Continuous.comp_continuousOn <| hγ.continuousOn );
        · constructor <;> linarith;
      simpa only [ sub_eq_zero ] using hg_zero

/-
**General corner locus theorem (flagship)**: If piece `i` is uniquely active
at `γ(t₀)` and a different piece `j` is uniquely active at `γ(t₁)`, any
continuous path `γ` must cross the corner locus. This is the tropical analogue
of the mountain pass theorem's topological forcing.

**Proof**: If no corner point exists on the path, then the active index function
is well-defined (always a singleton) and locally constant (by continuity of all
gap functions and openness of strict inequality). Since `[t₀, t₁]` is connected,
a locally constant function must be constant. But the active index at `t₀` is `i`
and at `t₁` is `j`, contradicting `i ≠ j`.
-/
theorem exists_cornerLocus_on_transition_path
    {n m : ℕ} [NeZero m] (P : Fin m → AffinePiece n)
    (γ : ℝ → Fin n → ℝ) (i j : Fin m) (hij : i ≠ j)
    (t₀ t₁ : ℝ) (ht : t₀ ≤ t₁)
    (hγ : Continuous γ)
    (hi_start : ∀ k : Fin m, k ≠ i →
      evalPiece (P k) (γ t₀) < evalPiece (P i) (γ t₀))
    (hj_end : ∀ k : Fin m, k ≠ j →
      evalPiece (P k) (γ t₁) < evalPiece (P j) (γ t₁)) :
    ∃ t ∈ Set.Icc t₀ t₁, γ t ∈ cornerLocus P := by
      -- Assume for contradiction that there is no point on the path in the corner locus.
      by_contra h_no_corner
      have h_unique : ∀ t ∈ Set.Icc t₀ t₁, (activeIndices P (γ t)).card = 1 := by
        simp_all +decide [ cornerLocus ];
        exact fun t ht₁ ht₂ => le_antisymm ( Nat.le_of_lt_succ ( h_no_corner t ht₁ ht₂ ) ) ( Finset.card_pos.mpr ( activeIndices_nonempty P ( γ t ) ) );
      have h_const : ∀ t ∈ Set.Icc t₀ t₁, (activeIndices P (γ t)).min' (by
      grind +suggestions) = (activeIndices P (γ t₀)).min' (by
      grind +suggestions) := by
        all_goals generalize_proofs at *;
        intro t ht
        have h_const : ∀ t ∈ Set.Icc t₀ t₁, ∃ k : Fin m, (activeIndices P (γ t)) = {k} := by
          exact fun t ht => Finset.card_eq_one.mp ( h_unique t ht )
        generalize_proofs at *;
        choose! k hk using h_const
        generalize_proofs at *;
        have h_const : ContinuousOn (fun t => k t) (Set.Icc t₀ t₁) := by
          have h_const : ∀ t ∈ Set.Icc t₀ t₁, ∀ k' : Fin m, k' ≠ k t → evalPiece (P k') (γ t) < evalPiece (P (k t)) (γ t) := by
            intro t ht k' hk'
            have h_active : k' ∉ activeIndices P (γ t) := by
              grind
            generalize_proofs at *;
            simp_all +decide [ activeIndices ];
            have := hk t ht.1 ht.2; simp_all +decide [ Finset.ext_iff ] ;
            exact lt_of_le_of_ne ( by linarith [ hk t ht.1 ht.2 ( k t ) |>.2 rfl, evalPiece_le_tropicalMax P ( γ t ) k' ] ) fun h => hk' <| by have := hk t ht.1 ht.2 k' |>.1 ( by linarith [ hk t ht.1 ht.2 ( k t ) |>.2 rfl, evalPiece_le_tropicalMax P ( γ t ) k' ] ) ; aesop;
          generalize_proofs at *;
          have h_const : ∀ t ∈ Set.Icc t₀ t₁, ∀ᶠ t' in nhdsWithin t (Set.Icc t₀ t₁), k t' = k t := by
            intro t ht
            have h_const : ∀ k' : Fin m, k' ≠ k t → ∀ᶠ t' in nhdsWithin t (Set.Icc t₀ t₁), evalPiece (P k') (γ t') < evalPiece (P (k t)) (γ t') := by
              intro k' hk'
              have h_cont : ContinuousOn (fun t' => evalPiece (P k') (γ t') - evalPiece (P (k t)) (γ t')) (Set.Icc t₀ t₁) := by
                exact ContinuousOn.sub ( ContinuousOn.comp ( show ContinuousOn ( fun x => evalPiece ( P k' ) x ) ( Set.univ : Set ( Fin n → ℝ ) ) from Continuous.continuousOn <| by exact evalPiece_continuous _ ) ( show ContinuousOn γ ( Set.Icc t₀ t₁ ) from hγ.continuousOn ) fun x hx => Set.mem_univ _ ) ( ContinuousOn.comp ( show ContinuousOn ( fun x => evalPiece ( P ( k t ) ) x ) ( Set.univ : Set ( Fin n → ℝ ) ) from Continuous.continuousOn <| by exact evalPiece_continuous _ ) ( show ContinuousOn γ ( Set.Icc t₀ t₁ ) from hγ.continuousOn ) fun x hx => Set.mem_univ _ )
              generalize_proofs at *;
              have := h_cont.continuousWithinAt ht;
              filter_upwards [ this.eventually ( gt_mem_nhds <| show evalPiece ( P k' ) ( γ t ) - evalPiece ( P ( k t ) ) ( γ t ) < 0 from sub_neg_of_lt <| h_const t ht k' hk' ) ] with t' ht' using by linarith;
            generalize_proofs at *;
            have h_const : ∀ᶠ t' in nhdsWithin t (Set.Icc t₀ t₁), ∀ k' : Fin m, k' ≠ k t → evalPiece (P k') (γ t') < evalPiece (P (k t)) (γ t') := by
              exact Filter.eventually_all.mpr fun k' => by by_cases hk' : k' = k t <;> aesop;
            generalize_proofs at *;
            filter_upwards [ h_const, self_mem_nhdsWithin ] with t' ht' ht'' ; specialize hk t' ht'' ; simp_all +decide [ Finset.eq_singleton_iff_unique_mem ] ;
            grind
          generalize_proofs at *;
          intro t ht;
          exact tendsto_nhds_of_eventually_eq ( h_const t ht )
        generalize_proofs at *;
        have h_const : IsConnected (Set.image k (Set.Icc t₀ t₁)) := by
          exact ⟨ Set.Nonempty.image _ ⟨ t₀, Set.left_mem_Icc.mpr ‹_› ⟩, isPreconnected_Icc.image _ h_const ⟩
        generalize_proofs at *;
        have := h_const.isPreconnected.subsingleton ( Set.mem_image_of_mem k <| Set.left_mem_Icc.mpr ‹_› ) ( Set.mem_image_of_mem k ht ) ; aesop;
      generalize_proofs at *;
      -- By definition of $activeIndices$, we know that $i$ is the unique active index at $t₀$ and $j$ is the unique active index at $t₁$.
      have h_unique_i : activeIndices P (γ t₀) = {i} := by
        refine' Finset.eq_singleton_iff_unique_mem.mpr ⟨ _, fun k hk => _ ⟩ <;> simp_all +decide [ activeIndices ];
        · refine' le_antisymm _ _;
          · exact Finset.le_sup' ( fun i => evalPiece ( P i ) ( γ t₀ ) ) ( Finset.mem_univ i );
          · exact Finset.sup'_le _ _ fun k hk => if hk' : k = i then hk'.symm ▸ le_rfl else le_of_lt ( hi_start k hk' );
        · exact Classical.not_not.1 fun h => hk.not_lt <| lt_of_lt_of_le ( hi_start k h ) <| Finset.le_sup' ( fun x => evalPiece ( P x ) ( γ t₀ ) ) <| Finset.mem_univ i
      have h_unique_j : activeIndices P (γ t₁) = {j} := by
        have h_unique_j : j ∈ activeIndices P (γ t₁) := by
          simp_all +decide [ activeIndices ];
          exact le_antisymm ( evalPiece_le_tropicalMax _ _ _ ) ( Finset.sup'_le _ _ fun k hk => le_of_not_gt fun hk' => by linarith [ hj_end k ( by aesop ) ] );
        grind +locals;
      specialize h_const t₁ ⟨ by linarith, by linarith ⟩ ; aesop;

/-! ## Main Theorem B: Codimension-1 Corner Critical Points

For the two-piece case, we characterize when a wall point is corner critical
and define the tropical Morse index. -/

/-
**Two-piece corner critical**: If `x` lies on the wall between pieces 0 and 1,
and for every direction `v`, the directional derivatives have non-positive product
(opposing signs or zero), then `x` is corner critical for the two-piece system.

This is the codimension-1 tropical analogue of a saddle point: descent in one
branch forces ascent in the other.
-/
theorem cornerCritical_of_opposing_gradients
    {n : ℕ} (P : Fin 2 → AffinePiece n) (x : Fin n → ℝ)
    (hwall : evalPiece (P 0) x = evalPiece (P 1) x)
    (hopp : ∀ v : Fin n → ℝ, (P 0).lin v * (P 1).lin v ≤ 0) :
    cornerCritical P x := by
      refine' ⟨ _, fun v => Or.inr _ ⟩;
      · refine' Finset.one_lt_card.2 ⟨ 0, _, 1, _, _ ⟩ <;> simp_all +decide [ activeIndices ];
        · unfold tropicalMax; simp +decide [ Fin.univ_succ ] ;
          linarith;
        · unfold tropicalMax;
          simp +decide [ Fin.univ_succ, hwall ];
      · refine' ⟨ 0, _, 1, _, _ ⟩ <;> simp_all +decide [ activeIndices ];
        · unfold tropicalMax;
          simp +decide [ Fin.univ_succ, hwall ];
        · unfold tropicalMax;
          simp +decide [ Fin.univ_succ, hwall ]

/-- The number of **sign-opposing pairs** among a set of indices for direction `v`.
This is a local combinatorial invariant measuring the "conflict complexity" at
a corner point. -/
def signOpposingPairs {n m : ℕ} [NeZero m]
    (P : Fin m → AffinePiece n) (A : Finset (Fin m)) (v : Fin n → ℝ) : ℕ :=
  ((A ×ˢ A).filter (fun ij => (P ij.1).lin v * (P ij.2).lin v < 0)).card

/-- The **tropical Morse index** for a two-piece corner point, as a Prop:
whether the pieces fully oppose on the wall. -/
def twoPieceFullyOpposes {n : ℕ}
    (P : Fin 2 → AffinePiece n) : Prop :=
  ∀ v : Fin n → ℝ, (P 0).lin v * (P 1).lin v ≤ 0

/-- The **tropical Morse index** as a natural number:
1 if the pieces fully oppose, 0 otherwise. -/
def tropicalMorseIndex_twoPiece {n : ℕ}
    (P : Fin 2 → AffinePiece n) : ℕ :=
  if twoPieceFullyOpposes P then 1 else 0

/-
In the two-piece case with full opposition, the tropical Morse index is 1.
-/
theorem tropicalMorseIndex_eq_one_two_piece {n : ℕ}
    (P : Fin 2 → AffinePiece n)
    (hopp : twoPieceFullyOpposes P) :
    tropicalMorseIndex_twoPiece P = 1 := by
      exact if_pos hopp

/-
The tropical Morse index vanishes when pieces agree on some direction.
-/
theorem tropicalMorseIndex_eq_zero_of_agreement {n : ℕ}
    (P : Fin 2 → AffinePiece n)
    (hagree : ∃ v : Fin n → ℝ, 0 < (P 0).lin v * (P 1).lin v) :
    tropicalMorseIndex_twoPiece P = 0 := by
      unfold tropicalMorseIndex_twoPiece;
      unfold twoPieceFullyOpposes; aesop;

/-! ## Main Theorem C: Graph-Theoretic Tropical Morse Inequality

A discrete version of tropical Morse theory on wall graphs: every finite
graph with a height function has at least one local maximum. This is the
prototype for tropical Morse counting inequalities. -/

/-- A vertex is a **local maximum** in a graph if its function value
is ≥ that of all its neighbors. -/
def isLocalMax' {V : Type*} (adj : V → V → Prop) (φ : V → ℝ) (v : V) : Prop :=
  ∀ u, adj v u → φ u ≤ φ v

/-- A vertex is a **local minimum** in a graph. -/
def isLocalMin' {V : Type*} (adj : V → V → Prop) (φ : V → ℝ) (v : V) : Prop :=
  ∀ u, adj v u → φ v ≤ φ u

/-
**Existence of local maxima**: Every finite nonempty type with a function
has a global maximum, which is in particular a local maximum for any graph
structure. This is the discrete analogue of the tropical Morse lower bound
`#critical ≥ 1`.
-/
theorem graph_localMax_exists {V : Type*} [Fintype V] [Nonempty V]
    (adj : V → V → Prop) (φ : V → ℝ) :
    ∃ v : V, isLocalMax' adj φ v := by
      exact ⟨ Classical.choose ( Finset.exists_max_image Finset.univ ( fun v => φ v ) ( Finset.univ_nonempty ) ), fun u hu => Classical.choose_spec ( Finset.exists_max_image Finset.univ ( fun v => φ v ) ( Finset.univ_nonempty ) ) |>.2 u ( Finset.mem_univ u ) ⟩

/-
**Existence of local minima**: Dual to local maxima existence.
-/
theorem graph_localMin_exists {V : Type*} [Fintype V] [Nonempty V]
    (adj : V → V → Prop) (φ : V → ℝ) :
    ∃ v : V, isLocalMin' adj φ v := by
      exact ⟨ Classical.choose ( Finset.exists_min_image Finset.univ ( fun v => φ v ) ( Finset.univ_nonempty ) ), fun u hu => Classical.choose_spec ( Finset.exists_min_image Finset.univ ( fun v => φ v ) ( Finset.univ_nonempty ) ) |>.2 u ( Finset.mem_univ u ) ⟩

/-- Count of local maxima in a decidable graph. -/
def localMaxCount {V : Type*} [Fintype V] [DecidableEq V]
    (adj : V → V → Prop) [DecidableRel adj] (φ : V → ℝ) : ℕ :=
  (Finset.univ.filter (fun v => ∀ u, adj v u → φ u ≤ φ v)).card

/-
The local maximum count is always at least 1 for nonempty types.
-/
theorem localMaxCount_pos {V : Type*} [Fintype V] [Nonempty V] [DecidableEq V]
    (adj : V → V → Prop) [DecidableRel adj] (φ : V → ℝ) :
    0 < localMaxCount adj φ := by
      -- By graph_localMax_exists, there exists v with isLocalMax' adj φ v.
      obtain ⟨v, hv⟩ : ∃ v : V, isLocalMax' adj φ v := graph_localMax_exists adj φ;
      exact Finset.card_pos.mpr ⟨ v, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hv ⟩ ⟩

/-! ## Worked Example: Two Affine Pieces on ℝ²

We construct a concrete example with `f₁(x) = x₀ - x₁` and `f₂(x) = -x₀ + x₁`.
These have perfectly opposing gradients, so the wall `{x₀ = x₁}` consists
entirely of corner critical points with tropical Morse index 1. -/

/-- Example: the linear functional `x ↦ x₀ - x₁` on ℝ². -/
def exLin1 : (Fin 2 → ℝ) →ₗ[ℝ] ℝ where
  toFun x := x 0 - x 1
  map_add' x y := by simp [Pi.add_apply]; ring
  map_smul' r x := by simp [Pi.smul_apply, smul_eq_mul]; ring

/-- Example: the linear functional `x ↦ -x₀ + x₁` on ℝ² (opposite of exLin1). -/
def exLin2 : (Fin 2 → ℝ) →ₗ[ℝ] ℝ where
  toFun x := -x 0 + x 1
  map_add' x y := by simp [Pi.add_apply]; ring
  map_smul' r x := by simp [Pi.smul_apply, smul_eq_mul]; ring

/-- Example piece 1: `f₁(x) = x₀ - x₁` -/
def exPiece1 : AffinePiece 2 := ⟨exLin1, 0⟩
/-- Example piece 2: `f₂(x) = -x₀ + x₁` -/
def exPiece2 : AffinePiece 2 := ⟨exLin2, 0⟩

/-
The example pieces have opposing gradients: `exLin1 = -exLin2`.
-/
theorem exLin_neg : ∀ v : Fin 2 → ℝ, exLin1 v = -exLin2 v := by
  exact fun v => show v 0 - v 1 = - ( -v 0 + v 1 ) by ring;

/-
The example pieces have opposing gradients: for all `v`, the product is ≤ 0.
-/
theorem example_opposing : ∀ v : Fin 2 → ℝ, exLin1 v * exLin2 v ≤ 0 := by
  exact fun v => by rw [ show exLin1 v = -exLin2 v by exact exLin_neg v ] ; nlinarith [ sq_nonneg ( exLin2 v ) ] ;

/-
The origin lies on the wall between the two example pieces.
-/
theorem example_on_wall : evalPiece exPiece1 0 = evalPiece exPiece2 0 := by
  -- By definition of `evalPiece`, we have:
  simp [evalPiece, exPiece1, exPiece2]

end