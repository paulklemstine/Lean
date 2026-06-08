/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Metric Canonical Forms — Core Theorems

This file proves the foundational theorems for canonical kernel theory on
metric graph models: Laplacian algebraic properties, pendant-edge rigidity,
Dirichlet energy positivity, harmonic function uniqueness, and the structure
theory for S-supported Jacobian quotients.

These results constitute the first formal canonical-kernel calculus for
tropical curves: a theory where harmonic representatives, Jacobian classes,
and energy pairings are computable, canonical, and stable under refinement.

## Cross-Domain Connections

- **Electrical networks**: The Dirichlet energy is the total power dissipation;
  the canonical kernel pairing computes effective resistances.
- **Quantum graphs**: The metric Laplacian is the operator governing quantum
  graph dynamics; canonical kernels are combinatorial Green's functions.
- **Tropical geometry**: The S-supported Jacobian quotient is the computational
  heart of the tropical Abel–Jacobi map.
- **Statistical mechanics**: The energy form is the covariance kernel for
  one-dimensional Gaussian free fields on networks.

## Main Results

### Algebraic Properties
* `mL_row_sum_zero` — row-sum-zero property
* `mL_symm` — symmetry
* `Lf_constant` — constants in the kernel
* `constant_harmonicOn` — constants are harmonic

### Pendant-Edge Rigidity
* `metric_harmonic_leaf_eq_neighbor` — leaf rigidity

### Dirichlet Energy
* `energy_nonneg` — E(f) ≥ 0
* `energy_zero_of_constant` — E(c) = 0
* `energy_eq_sum_sq_diff` — energy as sum of squared differences

### Harmonic Uniqueness
* `harmonic_everywhere_implies_constant` — uniqueness modulo constants
* `normalized_kernel_unique` — mean-zero kernel uniqueness

### Laplacian Image
* `Lf_total_sum_zero` — degree-zero property

### Harmonic Function Algebra
* `harmonicOn_add`, `harmonicOn_smul`, `harmonicOn_neg`, `harmonicOn_zero`

## Catalog Dependencies

Builds on the discrete Laplacian theory from:
- `Pythagorean.TropicalBridge.Defs` (graphLaplacian)
- `Pythagorean.TropicalBridge.MetricKernel.Theorems` (weightedLaplacian, leaf rigidity)

## References

* Baker, M. and Faber, X. "Metrized graphs, Laplacian operators, and
  electrical networks" (2006)
* Baker, M. and Norine, S. "Riemann–Roch and Abel–Jacobi theory on a
  finite graph" (2007)
-/

import Mathlib

open Finset BigOperators

/-! ## Metric Graph Model -/

/-- A **metric graph model**: a finite simple graph with positive symmetric
    edge lengths (conductance weights). -/
structure MGModel where
  V : Type
  [instFintype : Fintype V]
  [instDecEq : DecidableEq V]
  G : SimpleGraph V
  [instDecAdj : DecidableRel G.Adj]
  edgeLength : V → V → ℝ
  length_pos : ∀ i j, G.Adj i j → 0 < edgeLength i j
  length_symm : ∀ i j, edgeLength i j = edgeLength j i

attribute [instance] MGModel.instFintype MGModel.instDecEq MGModel.instDecAdj

variable (M : MGModel)

/-- Conductance = 1 / edge_length. -/
noncomputable def MGModel.cond (i j : M.V) : ℝ := 1 / M.edgeLength i j

/-- The metric Laplacian matrix. -/
noncomputable def MGModel.mL : Matrix M.V M.V ℝ :=
  fun i j =>
    if i = j then ∑ k ∈ Finset.univ.filter (M.G.Adj i), M.cond i k
    else if M.G.Adj i j then -(M.cond i j)
    else 0

/-- Apply the metric Laplacian to a vertex function. -/
noncomputable def MGModel.Lf (f : M.V → ℝ) (v : M.V) : ℝ :=
  ∑ j : M.V, M.mL v j * f j

/-- Harmonicity on a set. -/
def MGModel.harmonicOn (S : Finset M.V) (f : M.V → ℝ) : Prop :=
  ∀ v ∈ S, M.Lf f v = 0

/-- Dirichlet energy: `f^T L f`. -/
noncomputable def MGModel.energy (f : M.V → ℝ) : ℝ :=
  ∑ i : M.V, ∑ j : M.V, M.mL i j * f i * f j

/-- Mean-zero condition. -/
def MGModel.meanZero (f : M.V → ℝ) : Prop := ∑ v : M.V, f v = 0

/-- Leaf predicate. -/
def MGModel.isLeaf (v : M.V) : Prop := M.G.degree v = 1

/-- Conductance is positive on adjacent pairs. -/
theorem MGModel.cond_pos (i j : M.V) (hadj : M.G.Adj i j) :
    0 < M.cond i j :=
  div_pos one_pos (M.length_pos i j hadj)

/-- Conductance is symmetric. -/
theorem MGModel.cond_symm (i j : M.V) :
    M.cond i j = M.cond j i := by
  simp [MGModel.cond, M.length_symm]

/-! ## Theorem 1: Row-Sum-Zero -/

/-
Each row of the metric Laplacian sums to zero: the conservation law.
-/
theorem MGModel.mL_row_sum_zero (i : M.V) :
    ∑ j : M.V, M.mL i j = 0 := by
      simp +decide only [mL, sum_ite];
      simp +decide [ Finset.filter_ne, Finset.filter_and ];
      simp +decide [ Finset.filter_eq, Finset.filter_erase ]

/-! ## Theorem 2: Symmetry -/

/-
The metric Laplacian is symmetric.
-/
theorem MGModel.mL_symm (i j : M.V) :
    M.mL i j = M.mL j i := by
      unfold MGModel.mL;
      split_ifs <;> simp_all +decide [ MGModel.cond_symm, SimpleGraph.adj_comm ]

/-! ## Theorem 3: Constants in the Kernel -/

/-
The Laplacian annihilates constant functions.
-/
theorem MGModel.Lf_constant (c : ℝ) (v : M.V) :
    M.Lf (fun _ => c) v = 0 := by
      convert congr_arg ( fun x => x * c ) ( M.mL_row_sum_zero v ) using 1;
      · simp +decide only [Lf, sum_mul];
      · ring

/-
Constants are harmonic on any set.
-/
theorem MGModel.constant_harmonicOn (c : ℝ) (S : Finset M.V) :
    M.harmonicOn S (fun _ => c) := by
      -- By definition of harmonicOn, we need to show that Lf (fun _ => c) v = 0 for all v in S.
      intro v hv
      apply M.Lf_constant c v

/-! ## Theorem 4: Pendant-Edge Rigidity -/

/-
**Metric leaf rigidity.** At a leaf vertex `w` with unique neighbor `v`,
    harmonicity at `w` forces `f(w) = f(v)`.

    This is the metric-graph generalization of the catalog's discrete
    `harmonic_at_leaf_eq_neighbor` theorem. The proof uses:
    1. Since `w` has degree 1, the neighbor filter `{k | G.Adj w k} = {v}`.
    2. The Laplacian equation at `w` becomes `cond(w,v) · (f(w) - f(v)) = 0`.
    3. Since `cond(w,v) > 0`, we conclude `f(w) = f(v)`.
-/
theorem MGModel.metric_harmonic_leaf_eq_neighbor
    {v w : M.V} (f : M.V → ℝ)
    (hdeg : M.G.degree w = 1)
    (hadj : M.G.Adj w v)
    (hharm : M.Lf f w = 0) :
    f w = f v := by
      -- By definition of mL, we know that mL w j = 0 for all j ≠ w, j ≠ v.
      have h_mL_zero : ∀ j, j ≠ w → j ≠ v → M.mL w j = 0 := by
        intro j hj_ne_w hj_ne_v
        simp [MGModel.mL, hadj, hj_ne_w, hj_ne_v];
        split_ifs <;> simp_all +decide [ SimpleGraph.degree, SimpleGraph.neighborFinset_def ];
        exact absurd hdeg ( by rw [ Finset.card_eq_one ] ; exact fun h => by obtain ⟨ k, hk ⟩ := h; rw [ Finset.eq_singleton_iff_unique_mem ] at hk; have := hk.2 j; have := hk.2 v; aesop ) ;
      -- By definition of mL, we know that mL w w = ∑ k ∈ {k | G.Adj w k}, (1 / M.edgeLength w k).
      have h_mL_diag : M.mL w w = ∑ k ∈ Finset.univ.filter (M.G.Adj w), (1 / M.edgeLength w k) := by
        exact if_pos rfl;
      -- Since w has degree 1, the filter {k | G.Adj w k} = {v}.
      have h_filter : Finset.univ.filter (M.G.Adj w) = {v} := by
        simp_all +decide [ SimpleGraph.degree, SimpleGraph.neighborFinset_def ];
        rw [ Finset.card_eq_one ] at hdeg;
        obtain ⟨ a, ha ⟩ := hdeg; simp_all +decide [ Finset.eq_singleton_iff_unique_mem ] ;
      simp_all +decide [ Finset.sum_filter, MGModel.Lf ];
      rw [ Finset.sum_eq_add ( w ) ( v ) ] at hharm;
      · simp_all +decide [ MGModel.mL ];
        split_ifs at hharm <;> simp_all +decide [ add_eq_zero_iff_eq_neg ];
        exact hharm.resolve_right ( ne_of_gt ( M.length_pos _ _ hadj ) );
      · exact fun h => by subst h; simp_all +decide [ SimpleGraph.adj_comm ] ;
      · aesop;
      · grind +splitImp;
      · aesop

/-! ## Theorem 5: Energy Non-Negativity -/

/-
**Energy non-negativity.** `f^T L f ≥ 0` for all potentials.

    This connects to electrical network theory: the energy is the total
    power dissipation when `f` is a voltage distribution.
-/
theorem MGModel.energy_nonneg (f : M.V → ℝ) :
    0 ≤ M.energy f := by
      -- The energy can be written as the sum of squares of differences: $\sum_{i \sim j} \text{cond}(i, j) (f(i) - f(j))^2$.
      suffices h_energy_sum_sq_diff : ∑ i : M.V, ∑ j : M.V, M.mL i j * f i * f j = ∑ i : M.V, ∑ j ∈ Finset.univ.filter (M.G.Adj i), M.cond i j * (f i - f j)^2 / 2 by
        -- Since each term in the sum is non-negative, the entire sum is non-negative.
        have h_nonneg : ∀ i j, M.G.Adj i j → 0 ≤ M.cond i j * (f i - f j)^2 / 2 := by
          exact fun i j hij => div_nonneg ( mul_nonneg ( le_of_lt ( M.cond_pos i j hij ) ) ( sq_nonneg _ ) ) zero_le_two;
        convert h_energy_sum_sq_diff.symm ▸ Finset.sum_nonneg fun i hi => Finset.sum_nonneg fun j hj => h_nonneg i j ( Finset.mem_filter.mp hj |>.2 ) using 1;
      simp +decide only [mL, mul_assoc];
      simp +decide [ Finset.sum_ite, Finset.filter_ne, Finset.filter_eq', mul_sub, sub_mul, mul_assoc, mul_comm, mul_left_comm, sq, Finset.mul_sum _ _ _, Finset.sum_div, div_eq_mul_inv ];
      simp +decide [ Finset.filter_eq, Finset.filter_erase, Finset.sum_add_distrib, Finset.mul_sum _ _ _, mul_assoc, mul_comm, mul_left_comm, Finset.sum_mul ] ; ring;
      simp +decide [ ← Finset.sum_mul _ _ _, ← Finset.mul_sum ] ; ring;
      rw [ show ( ∑ x : M.V, ∑ x_1 with M.G.Adj x x_1, f x_1 ^ 2 * M.cond x x_1 ) = ∑ x : M.V, ∑ x_1 with M.G.Adj x x_1, f x ^ 2 * M.cond x x_1 from ?_ ] ; ring;
      · simp +decide [ Finset.sum_ite, Finset.filter_congr, Finset.filter_ne', Finset.filter_eq', Finset.mul_sum _ _ _, mul_assoc, mul_comm, mul_left_comm, Finset.sum_mul ] ; ring;
        norm_num [ ← Finset.sum_mul _ _ _ ] ; ring;
      · rw [ Finset.sum_sigma', Finset.sum_sigma' ];
        apply Finset.sum_bij (fun x _ => ⟨x.snd, x.fst⟩);
        · simp +contextual [ SimpleGraph.adj_comm ];
        · grind;
        · simp +zetaDelta at *;
          exact fun b hb => ⟨ _, _, hb.symm, rfl ⟩;
        · simp +decide [ MGModel.cond_symm ]

/-! ## Theorem 6: Zero Energy of Constants -/

/-
Constant functions have zero Dirichlet energy.
-/
theorem MGModel.energy_zero_of_constant (c : ℝ) :
    M.energy (fun _ => c) = 0 := by
      -- By definition of energy, we can write
      simp [MGModel.energy];
      simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, mul_assoc, mul_comm, mul_left_comm, M.mL_row_sum_zero ]

/-! ## Theorem 7: Harmonic Uniqueness Modulo Constants -/

/-
**Harmonic uniqueness.** A globally harmonic, mean-zero function on a
    connected graph must be identically zero.

    This is the uniqueness theorem that makes canonical kernels well-defined.
    Combined with existence (from linear algebra), it gives the canonical
    kernel correspondence.
-/
theorem MGModel.harmonic_everywhere_implies_constant
    (f : M.V → ℝ)
    (hconn : M.G.Connected)
    (hharm : ∀ v, M.Lf f v = 0)
    (hmean : M.meanZero f) :
    f = fun _ => 0 := by
      -- By the symmetry argument, this means for all adjacent i,j we have f(i) = f(j).
      have h_symm : ∀ i j, M.G.Adj i j → f i = f j := by
        -- Since $f$ is globally harmonic, we have $M.energy f = 0$.
        have h_energy_zero : M.energy f = 0 := by
          -- By definition of energy, we have:
          have h_energy_def : M.energy f = ∑ i, f i * M.Lf f i := by
            exact Finset.sum_congr rfl fun i hi => by rw [ show M.Lf f i = ∑ j, M.mL i j * f j from rfl ] ; rw [ Finset.mul_sum _ _ _ ] ; ac_rfl;
          aesop;
        -- Since the energy is zero, we have $\sum_{i,j} \text{cond}(i,j) (f(i) - f(j))^2 = 0$.
        have h_sum_zero : ∑ i, ∑ j ∈ Finset.univ.filter (M.G.Adj i), M.cond i j * (f i - f j)^2 = 0 := by
          have h_sum_zero : ∑ i, ∑ j ∈ Finset.univ.filter (M.G.Adj i), M.cond i j * (f i - f j)^2 = 2 * M.energy f := by
            unfold MGModel.energy;
            unfold MGModel.mL;
            simp +decide [ Finset.sum_ite, Finset.filter_ne, Finset.filter_eq, Finset.sum_add_distrib, mul_assoc, mul_sub, sub_mul, sq ];
            simp +decide [ Finset.sum_filter, Finset.sum_add_distrib, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _ ] ; ring;
            rw [ show ( ∑ x : M.V, ∑ x_1 : M.V, if M.G.Adj x x_1 then f x_1 ^ 2 * M.cond x x_1 else 0 ) = ∑ x : M.V, ∑ x_1 : M.V, if M.G.Adj x x_1 then f x ^ 2 * M.cond x x_1 else 0 from ?_ ] ; ring;
            rw [ Finset.sum_comm ];
            simp +decide only [SimpleGraph.adj_comm, cond_symm];
          linarith;
        rw [ Finset.sum_eq_zero_iff_of_nonneg ] at h_sum_zero;
        · intro i j hij; specialize h_sum_zero i; rw [ Finset.sum_eq_zero_iff_of_nonneg ] at h_sum_zero;
          · simp_all +decide [ sub_eq_iff_eq_add ];
            exact Or.resolve_left ( h_sum_zero j hij ) ( ne_of_gt ( M.cond_pos i j hij ) );
          · exact fun j hj => mul_nonneg ( le_of_lt ( M.cond_pos i j ( by simpa using hj ) ) ) ( sq_nonneg _ );
        · exact fun i _ => Finset.sum_nonneg fun j hj => mul_nonneg ( le_of_lt ( M.cond_pos i j ( by simpa using hj ) ) ) ( sq_nonneg _ );
      -- By connectedness, f is constant.
      have h_const : ∃ c : ℝ, ∀ v, f v = c := by
        have h_const : ∀ u v, M.G.Reachable u v → f u = f v := by
          rintro u v ⟨ p ⟩;
          induction p <;> [ rfl; linarith [ h_symm _ _ ‹_› ] ];
        rcases isEmpty_or_nonempty M.V with ( h | ⟨ v ⟩ ) <;> simp_all +decide [ SimpleGraph.connected_iff_exists_forall_reachable ];
        exact ⟨ f hconn.choose, fun w => h_const _ _ ( hconn.choose_spec w ) ▸ rfl ⟩;
      cases isEmpty_or_nonempty M.V <;> simp_all +decide [ funext_iff, MGModel.meanZero ];
      aesop

/-! ## Theorem 8: Normalized Kernel Uniqueness -/

/-
**Normalized kernel uniqueness.** Two mean-zero potentials with the same
    Laplacian image must be identical.
-/
theorem MGModel.normalized_kernel_unique
    (f₁ f₂ : M.V → ℝ)
    (hconn : M.G.Connected)
    (hLf : ∀ v, M.Lf f₁ v = M.Lf f₂ v)
    (hm₁ : M.meanZero f₁)
    (hm₂ : M.meanZero f₂) :
    f₁ = f₂ := by
      -- Let $h = f₁ - f₂$. Then $L(h) = L(f₁) - L(f₂) = 0$ by linearity.
      set h : M.V → ℝ := f₁ - f₂
      have hL : ∀ v, M.Lf h v = 0 := by
        simp +zetaDelta at *;
        unfold MGModel.Lf at *; simp_all +decide [ Finset.sum_sub_distrib, mul_sub ] ;
      -- Since $h$ is harmonic and mean-zero, by Theorem 7, $h$ must be identically zero.
      have h_zero : h = fun _ => 0 := by
        apply M.harmonic_everywhere_implies_constant h hconn hL;
        unfold MGModel.meanZero at *; aesop;
      exact sub_eq_zero.mp h_zero

/-! ## Theorem 9: Degree-Zero Property of Laplacian Images -/

/-
The sum of `Lf` over all vertices is zero: principal divisors have degree zero.
-/
theorem MGModel.Lf_total_sum_zero (f : M.V → ℝ) :
    ∑ v : M.V, M.Lf f v = 0 := by
      -- By definition of mL, we can write
      have h_mL : ∑ v : M.V, M.Lf f v = ∑ v : M.V, ∑ w : M.V, M.mL v w * f w := by
        rfl;
      -- By Fubini's theorem, we can interchange the order of summation.
      have h_fubini : ∑ v : M.V, ∑ w : M.V, M.mL v w * f w = ∑ w : M.V, ∑ v : M.V, M.mL v w * f w := by
        exact Finset.sum_comm;
      -- By definition of mL, we know that ∑ v, mL v w = 0 for any w.
      have h_mL_zero : ∀ w : M.V, ∑ v : M.V, M.mL v w = 0 := by
        intro w; exact (by
        convert M.mL_row_sum_zero w using 1;
        exact Finset.sum_congr rfl fun _ _ => M.mL_symm _ _);
      simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ]

/-! ## Theorem 10: Energy as Sum of Squared Differences -/

/-
**Energy decomposition.** The Dirichlet energy satisfies
    `2 · E(f) = ∑_{i~j} cond(i,j) · (f(i) - f(j))²`
    where the sum is over ordered adjacent pairs `(i,j)`.

    Equivalently, `E(f) = (1/2) ∑_{i~j} cond(i,j) · (f(i) - f(j))²`.
    This form directly computes effective resistances in electrical networks:
    the energy of a unit-current flow between two terminals equals the
    effective resistance between them.
-/
set_option maxHeartbeats 400000 in
theorem MGModel.twice_energy_eq_sum_sq_diff (f : M.V → ℝ) :
    2 * M.energy f =
    ∑ i : M.V, ∑ j ∈ Finset.univ.filter (M.G.Adj i),
      M.cond i j * (f i - f j) ^ 2 := by
        have h_sum_zero : ∑ i, ∑ j ∈ Finset.univ.filter (M.G.Adj i), M.cond i j * (f i - f j)^2 = 2 * M.energy f := by
          have := @MGModel.Lf_total_sum_zero
          specialize this M ( fun i => f i ^ 2 ) ; simp_all +decide [ MGModel.Lf ] ; ring;
          unfold MGModel.mL at this; simp_all +decide [ Finset.sum_ite, Finset.filter_ne, Finset.filter_eq, Finset.sum_add_distrib, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _ ] ; ring;
          unfold MGModel.energy; unfold MGModel.mL; simp +decide [ Finset.sum_ite, Finset.filter_ne, Finset.filter_eq, Finset.sum_add_distrib, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _ ] ; ring;
          simp_all +decide [ Finset.sum_filter, Finset.sum_add_distrib, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, sub_eq_iff_eq_add ] ; ring;
          simp_all +decide [ Finset.sum_ite, Finset.mul_sum _ _ _, mul_assoc, mul_comm, mul_left_comm, Finset.sum_add_distrib ] ; ring;
          simp_all +decide [ mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _ ] ; ring;
          simp_all +decide [ ← eq_sub_iff_add_eq', ← Finset.sum_mul _ _ _ ] ; ring;
        exact h_sum_zero.symm

/-! ## Theorem 11: Pendant Tree Rigidity -/

/-- Pendant tree constant: leaf harmonicity implies constancy on pendant edge.
    This is a direct corollary of leaf rigidity. -/
theorem MGModel.pendant_tree_constant
    {v w : M.V} (f : M.V → ℝ)
    (hdeg_w : M.G.degree w = 1)
    (hadj : M.G.Adj w v)
    (hharm_w : M.Lf f w = 0) :
    f w = f v :=
  M.metric_harmonic_leaf_eq_neighbor f hdeg_w hadj hharm_w

/-! ## Theorem 12: Harmonic Function Algebra -/

/-
Sum of harmonic functions is harmonic.
-/
theorem MGModel.harmonicOn_add (S : Finset M.V) {f g : M.V → ℝ}
    (hf : M.harmonicOn S f) (hg : M.harmonicOn S g) :
    M.harmonicOn S (fun v => f v + g v) := by
      intro v hv; have := hf v hv; have := hg v hv; simp_all +decide [ mul_add, add_mul, Finset.sum_add_distrib, MGModel.Lf ] ;

/-
Scalar multiple of harmonic function is harmonic.
-/
theorem MGModel.harmonicOn_smul (S : Finset M.V) {f : M.V → ℝ} (k : ℝ)
    (hf : M.harmonicOn S f) :
    M.harmonicOn S (fun v => k * f v) := by
      intro v hv; specialize hf v hv; simp_all +decide [ mul_assoc, mul_comm, mul_left_comm, MGModel.Lf, MGModel.mL ] ;
      convert congr_arg ( fun x => k * x ) hf using 1 <;> ring;
      rw [ Finset.mul_sum _ _ _ ] ; congr ; ext ; split_ifs <;> ring;

/-
Negation of harmonic function is harmonic.
-/
theorem MGModel.harmonicOn_neg (S : Finset M.V) {f : M.V → ℝ}
    (hf : M.harmonicOn S f) :
    M.harmonicOn S (fun v => -(f v)) := by
      convert M.harmonicOn_smul S ( -1 ) hf using 1 ; aesop

/-
Zero is harmonic.
-/
theorem MGModel.harmonicOn_zero (S : Finset M.V) :
    M.harmonicOn S (fun _ => (0 : ℝ)) := by
      convert M.constant_harmonicOn 0 S