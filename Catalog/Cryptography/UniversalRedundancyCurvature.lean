/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Price of Universality IX: the curvature of a model pool

Research thread *Compression Beyond the Pigeonhole Bound*, Phase A.

`Cryptography.UniversalRedundancyLibrary` shows that the price of universality
`C(A) = shtarkov P A` of a *library* `A` of models is a monotone submodular set
function with `C(∅) = 0`, and deduces the classical `(1 − 1/e)` guarantee for
greedy library design.

This file introduces the **curvature of a candidate pool** `Ω`,

`κ(Ω) = 1 − minⱼ∈Ω (C(Ω) − C(Ω∖{j})) / C({j})`,

the Conforti–Cornuéjols total curvature of the price functional restricted to
the pool, and studies how it controls greedy library design.

## Main results

* `Library.curvature` — the curvature of a pool (a total function: the `min` is
  taken as a `fold` with default value `1`, and `C({j}) = 0` contributes the
  pessimistic ratio `0`);
* `Library.curvature_nonneg`, `Library.curvature_le_one` — `κ ∈ [0,1]`;
* `Library.curvature_marginal_ge` — the defining inequality in usable form:
  every insertion into a sub-library of the pool is worth at least
  `(1 − κ)·C({j})`;
* `Library.shtarkov_union_ge_curvature` — curvature superadditivity
  `C(A ∪ B) ≥ C(B) + (1 − κ)(C(A) − C(A ∩ B))`;
* `Library.PoolGreedyRun` — greedy library design *inside a pool*, with the
  basic structure theory of the greedy gains (`greedyGain_antitone`,
  `greedyGain_le_singleton`, `shtarkov_le_of_greedyGain_nonpos`);
* `Library.gap_le_curvature_gain` — the **curvature-sharpened greedy step**:
  after `k` steps the optimality gap is at most `(n − (1 − κ)k)` greedy gains,
  instead of the `n` gains of the curvature-free analysis;
* `Library.greedy_curvature_gap_le` — the resulting product bound
  `gap_k ≤ (∏_{i<k} (1 − 1/(n − (1−κ)i)))·C(B)`;
* `Library.greedy_zero_curvature_optimal` — **zero curvature ⇒ greedy is
  exactly optimal**, the `κ → 0` endpoint of the conjectured `(1−e^{−κ})/κ`
  guarantee;
* `Library.greedy_one_sub_inv_exp_le_pool` — the `κ = 1` endpoint: the
  classical `(1 − 1/e)` guarantee is recovered for every pool;
* `Library.greedy_one_sub_exp_neg_curvature` — the factor `1 − e^{−κ}`, the
  numerator of the conjectured `(1 − e^{−κ})/κ`, is achieved (the `1/κ`
  amplification remains open);
* `Library.greedy_low_curvature_gap` — a quantitative low-curvature guarantee:
  the gap is at most `κ(n−1)/(1 + κ(n−1))·(1 − 1/n)^{n−1}·C(B)`;
* `Library.poolGreedyRun_poolGreedySeq` — pool-restricted greedy runs exist, so
  none of the guarantees is vacuous;
* `Library.shtarkov_modular_of_curvature_zero` — zero curvature is exactly
  modularity of the price functional on the pool.

The companion file `Cryptography.UniversalRedundancyCurvatureTV` relates the
curvature to the total-variation spread of the pool and refutes the conjecture
`κ ≤ δ·|Ω|`.

## Application keywords

universal compression, Shtarkov sum, submodularity, total curvature,
Conforti–Cornuéjols, greedy approximation, model libraries, total variation
-/

import Cryptography.UniversalRedundancyLibrary

open Finset Real

namespace UniversalRedundancy

namespace Library

variable {X : Type*} {ι : Type*} (P : ι → X → ℝ)

/-! ## Singletons and subadditivity -/

section Singletons

variable [Fintype X] [DecidableEq ι]

omit [Fintype X] in
@[simp] lemma envelope_singleton (j : ι) (x : X) :
    envelope P {j} x = max (P j x) 0 := by
  have : ({j} : Finset ι) = insert j (∅ : Finset ι) := rfl
  rw [this, envelope_insert, envelope_empty]

lemma shtarkov_singleton (j : ι) : shtarkov P {j} = ∑ x, max (P j x) 0 := by
  simp [shtarkov]

/-- Inserting a model into any library is worth at most its solo price. -/
lemma shtarkov_insert_sub_le_singleton (j : ι) (A : Finset ι) :
    shtarkov P (insert j A) - shtarkov P A ≤ shtarkov P {j} := by
  have h := shtarkov_diminishing P (A := (∅ : Finset ι)) (B := A) (Finset.empty_subset A) j
  have hins : insert j (∅ : Finset ι) = {j} := rfl
  rw [hins, shtarkov_empty] at h
  linarith

/-- **Subadditivity across a splitting.**  The price of `A` is at most the price
of `A ∩ B` plus the solo prices of the models of `A` outside `B`. -/
lemma shtarkov_le_inter_add_sum (A B : Finset ι) :
    shtarkov P A ≤ shtarkov P (A ∩ B) + ∑ a ∈ A \ B, shtarkov P {a} := by
  have hcov := shtarkov_union_sub_le_sum P (A ∩ B) (A \ B)
  have hEq : (A ∩ B) ∪ (A \ B) = A := by
    rw [Finset.union_comm]
    exact Finset.sdiff_union_inter A B
  rw [hEq] at hcov
  have hterm : ∑ a ∈ A \ B, (shtarkov P (insert a (A ∩ B)) - shtarkov P (A ∩ B))
      ≤ ∑ a ∈ A \ B, shtarkov P {a} :=
    Finset.sum_le_sum fun a _ => shtarkov_insert_sub_le_singleton P a (A ∩ B)
  linarith

end Singletons

/-! ## The curvature of a pool -/

section Curvature

variable [Fintype X] [DecidableEq ι]

/-- The marginal ratio of the model `j` in the pool `Ω`: the value that `j`
still adds on top of *all* the other models of the pool, relative to its solo
value.  (If `C({j}) = 0` the ratio is `0`, the pessimistic convention.) -/
noncomputable def marginalRatio (Ω : Finset ι) (j : ι) : ℝ :=
  (shtarkov P Ω - shtarkov P (Ω.erase j)) / shtarkov P {j}

/-- The **curvature** of a pool of models,
`κ = 1 − minⱼ∈Ω (C(Ω) − C(Ω∖{j}))/C({j})`.  The minimum is a `fold` with
default value `1`, so the empty pool has curvature `0`. -/
noncomputable def curvature (Ω : Finset ι) : ℝ :=
  1 - Ω.fold min 1 (marginalRatio P Ω)

lemma marginalRatio_nonneg (Ω : Finset ι) (j : ι) : 0 ≤ marginalRatio P Ω j := by
  refine div_nonneg ?_ (shtarkov_nonneg P _)
  have := shtarkov_mono P (Finset.erase_subset j Ω)
  linarith

lemma marginalRatio_le_one {Ω : Finset ι} {j : ι} (hj : j ∈ Ω) :
    marginalRatio P Ω j ≤ 1 := by
  have hnum : shtarkov P Ω - shtarkov P (Ω.erase j) ≤ shtarkov P {j} := by
    have h := shtarkov_insert_sub_le_singleton P j (Ω.erase j)
    rwa [Finset.insert_erase hj] at h
  rcases eq_or_lt_of_le (shtarkov_nonneg P ({j} : Finset ι)) with h0 | h0
  · unfold marginalRatio
    rw [← h0, div_zero]
    norm_num
  · exact (div_le_one h0).2 hnum

lemma one_sub_curvature (Ω : Finset ι) :
    1 - curvature P Ω = Ω.fold min 1 (marginalRatio P Ω) := by
  unfold curvature; ring

/-- The curvature is nonnegative. -/
theorem curvature_nonneg (Ω : Finset ι) : 0 ≤ curvature P Ω := by
  have : Ω.fold min 1 (marginalRatio P Ω) ≤ 1 :=
    (Finset.fold_min_le _).2 (Or.inl le_rfl)
  unfold curvature; linarith

/-- The curvature is at most `1`. -/
theorem curvature_le_one (Ω : Finset ι) : curvature P Ω ≤ 1 := by
  have : 0 ≤ Ω.fold min 1 (marginalRatio P Ω) :=
    (Finset.le_fold_min _).2 ⟨zero_le_one, fun j _ => marginalRatio_nonneg P Ω j⟩
  unfold curvature; linarith

lemma one_sub_curvature_le_marginalRatio {Ω : Finset ι} {j : ι} (hj : j ∈ Ω) :
    1 - curvature P Ω ≤ marginalRatio P Ω j := by
  rw [one_sub_curvature]
  exact (Finset.fold_min_le _).2 (Or.inr ⟨j, hj, le_rfl⟩)

/-- The marginal ratio of a model can only shrink when the pool grows. -/
lemma marginalRatio_antitone {Ω Ω' : Finset ι} (hsub : Ω ⊆ Ω') {j : ι} (hj : j ∈ Ω) :
    marginalRatio P Ω' j ≤ marginalRatio P Ω j := by
  have hjΩ' : j ∈ Ω' := hsub hj
  have hnum : shtarkov P Ω' - shtarkov P (Ω'.erase j)
      ≤ shtarkov P Ω - shtarkov P (Ω.erase j) := by
    have hsube : Ω.erase j ⊆ Ω'.erase j := Finset.erase_subset_erase j hsub
    have hdim := shtarkov_diminishing P hsube j
    rwa [Finset.insert_erase hj, Finset.insert_erase hjΩ'] at hdim
  rcases eq_or_lt_of_le (shtarkov_nonneg P ({j} : Finset ι)) with h0 | h0
  · unfold marginalRatio
    rw [← h0, div_zero, div_zero]
  · unfold marginalRatio
    exact div_le_div_of_nonneg_right hnum (le_of_lt h0)

/-- **Curvature is monotone in the pool.**  Enlarging the candidate pool can
only increase its curvature, hence only weaken the greedy guarantee. -/
theorem curvature_mono {Ω Ω' : Finset ι} (hsub : Ω ⊆ Ω') :
    curvature P Ω ≤ curvature P Ω' := by
  have hfold : Ω'.fold min 1 (marginalRatio P Ω') ≤ Ω.fold min 1 (marginalRatio P Ω) := by
    refine (Finset.le_fold_min _).2 ⟨(Finset.fold_min_le _).2 (Or.inl le_rfl), fun j hj => ?_⟩
    exact le_trans ((Finset.fold_min_le _).2 (Or.inr ⟨j, hsub hj, le_rfl⟩))
      (marginalRatio_antitone P hsub hj)
  unfold curvature
  linarith

/-- **The curvature inequality.**  Adjoining a pool member `j` to *any*
sub-library `S` of the pool is worth at least `(1 − κ)` times its solo value.
This is the workhorse form of the definition of curvature. -/
theorem curvature_marginal_ge {Ω : Finset ι} {j : ι} (hj : j ∈ Ω) {S : Finset ι}
    (hS : S ⊆ Ω) (hjS : j ∉ S) :
    (1 - curvature P Ω) * shtarkov P {j} ≤ shtarkov P (insert j S) - shtarkov P S := by
  have hSe : S ⊆ Ω.erase j := Finset.subset_erase.2 ⟨hS, hjS⟩
  have hdim := shtarkov_diminishing P hSe j
  rw [Finset.insert_erase hj] at hdim
  rcases eq_or_lt_of_le (shtarkov_nonneg P ({j} : Finset ι)) with h0 | h0
  · rw [← h0, mul_zero]
    have := shtarkov_mono P (Finset.subset_insert j S)
    linarith
  · have hr : 1 - curvature P Ω ≤ marginalRatio P Ω j :=
      one_sub_curvature_le_marginalRatio P hj
    have hmul : (1 - curvature P Ω) * shtarkov P {j}
        ≤ marginalRatio P Ω j * shtarkov P {j} :=
      mul_le_mul_of_nonneg_right hr (le_of_lt h0)
    have hcancel : marginalRatio P Ω j * shtarkov P {j}
        = shtarkov P Ω - shtarkov P (Ω.erase j) := by
      unfold marginalRatio
      field_simp
    rw [hcancel] at hmul
    linarith

/-- Adjoining a whole (disjoint) family of pool members to a library is worth at
least `(1 − κ)` times the sum of their solo values. -/
lemma shtarkov_union_ge_curvature_aux {Ω : Finset ι} {B : Finset ι} (hB : B ⊆ Ω) :
    ∀ T : Finset ι, T ⊆ Ω → Disjoint T B →
      shtarkov P B + (1 - curvature P Ω) * ∑ a ∈ T, shtarkov P {a}
        ≤ shtarkov P (T ∪ B) := by
  intro T
  induction T using Finset.induction_on with
  | empty => intro _ _; simp
  | insert j T hj ih =>
      intro hsub hdisj
      have hjΩ : j ∈ Ω := hsub (Finset.mem_insert_self j T)
      have hTΩ : T ⊆ Ω := fun a ha => hsub (Finset.mem_insert_of_mem ha)
      have hdisj' : Disjoint T B :=
        Finset.disjoint_of_subset_left (Finset.subset_insert j T) hdisj
      have hjB : j ∉ B := by
        intro hjB
        exact (Finset.disjoint_left.1 hdisj (Finset.mem_insert_self j T)) hjB
      have hjTB : j ∉ T ∪ B := by
        simp only [Finset.mem_union]
        tauto
      have hTBΩ : T ∪ B ⊆ Ω := Finset.union_subset hTΩ hB
      have hstep := curvature_marginal_ge P hjΩ hTBΩ hjTB
      have hins : insert j T ∪ B = insert j (T ∪ B) := by
        ext y; simp [Finset.mem_union, Finset.mem_insert]
      have hIH := ih hTΩ hdisj'
      rw [hins, Finset.sum_insert hj, mul_add]
      linarith

/-- **Curvature superadditivity.**  For sub-libraries of the pool,
`C(A ∪ B) ≥ C(B) + (1 − κ)·(C(A) − C(A ∩ B))`.  At `κ = 0` this is exact
modularity; at `κ = 1` it degenerates to monotonicity. -/
theorem shtarkov_union_ge_curvature {Ω : Finset ι} {A B : Finset ι}
    (hA : A ⊆ Ω) (hB : B ⊆ Ω) :
    shtarkov P B + (1 - curvature P Ω) * (shtarkov P A - shtarkov P (A ∩ B))
      ≤ shtarkov P (A ∪ B) := by
  have hTsub : A \ B ⊆ Ω := fun a ha => hA (Finset.mem_sdiff.1 ha).1
  have hdisj : Disjoint (A \ B) B := Finset.sdiff_disjoint
  have haux := shtarkov_union_ge_curvature_aux P hB (A \ B) hTsub hdisj
  have hunion : (A \ B) ∪ B = A ∪ B := by
    ext y; simp [Finset.mem_union]
  rw [hunion] at haux
  have hsub := shtarkov_le_inter_add_sum P A B
  have hκ : 0 ≤ 1 - curvature P Ω := by
    have := curvature_le_one P Ω; linarith
  nlinarith

/-- **Zero curvature means exact modularity on the pool.**  Together with
submodularity, curvature superadditivity pins the price functional down to a
modular one on all sub-libraries of a curvature-zero pool. -/
theorem shtarkov_modular_of_curvature_zero {Ω : Finset ι} (hcurv : curvature P Ω = 0)
    {A B : Finset ι} (hA : A ⊆ Ω) (hB : B ⊆ Ω) :
    shtarkov P (A ∪ B) + shtarkov P (A ∩ B) = shtarkov P A + shtarkov P B := by
  have hsub := shtarkov_submodular P A B
  have hsuper := shtarkov_union_ge_curvature P hA hB
  rw [hcurv] at hsuper
  linarith

end Curvature

/-! ## The curvature product -/

section CurvatureProduct

/-- The decay factor of the curvature-sharpened greedy analysis: after `k`
greedy steps against a target library of size `n`, the optimality gap has been
multiplied by `curvatureProd n κ k`. -/
noncomputable def curvatureProd (n : ℕ) (kappa : ℝ) (k : ℕ) : ℝ :=
  ∏ i ∈ Finset.range k, (1 - 1 / ((n : ℝ) - (1 - kappa) * i))

@[simp] lemma curvatureProd_zero (n : ℕ) (kappa : ℝ) : curvatureProd n kappa 0 = 1 := by
  simp [curvatureProd]

lemma curvatureProd_succ (n : ℕ) (kappa : ℝ) (k : ℕ) :
    curvatureProd n kappa (k + 1)
      = curvatureProd n kappa k * (1 - 1 / ((n : ℝ) - (1 - kappa) * k)) :=
  Finset.prod_range_succ _ _

lemma one_le_curvatureDenom {n : ℕ} {kappa : ℝ} (h0 : 0 ≤ kappa)
    {i : ℕ} (hi : i + 1 ≤ n) : (1 : ℝ) ≤ (n : ℝ) - (1 - kappa) * i := by
  have hin : (i : ℝ) + 1 ≤ (n : ℝ) := by exact_mod_cast hi
  have hi0 : (0 : ℝ) ≤ (i : ℝ) := Nat.cast_nonneg i
  nlinarith

lemma curvatureDenom_le {n : ℕ} {kappa : ℝ} (h1 : kappa ≤ 1) (i : ℕ) :
    (n : ℝ) - (1 - kappa) * i ≤ (n : ℝ) := by
  have hi0 : (0 : ℝ) ≤ (i : ℝ) := Nat.cast_nonneg i
  nlinarith

lemma curvatureFactor_nonneg {n : ℕ} {kappa : ℝ} (h0 : 0 ≤ kappa)
    {i : ℕ} (hi : i + 1 ≤ n) : 0 ≤ 1 - 1 / ((n : ℝ) - (1 - kappa) * i) := by
  have hden := one_le_curvatureDenom h0 hi
  have hpos : (0 : ℝ) < (n : ℝ) - (1 - kappa) * i := by linarith
  have : 1 / ((n : ℝ) - (1 - kappa) * i) ≤ 1 := by
    rw [div_le_one hpos]; exact hden
  linarith

lemma curvatureFactor_le {n : ℕ} {kappa : ℝ} (h0 : 0 ≤ kappa) (h1 : kappa ≤ 1)
    {i : ℕ} (hi : i + 1 ≤ n) :
    1 - 1 / ((n : ℝ) - (1 - kappa) * i) ≤ 1 - 1 / (n : ℝ) := by
  have hden := one_le_curvatureDenom h0 hi
  have hpos : (0 : ℝ) < (n : ℝ) - (1 - kappa) * i := by linarith
  have hle := curvatureDenom_le (n := n) (kappa := kappa) h1 i
  have : 1 / (n : ℝ) ≤ 1 / ((n : ℝ) - (1 - kappa) * i) :=
    one_div_le_one_div_of_le hpos hle
  linarith

lemma curvatureProd_nonneg {n : ℕ} {kappa : ℝ} (h0 : 0 ≤ kappa)
    {k : ℕ} (hk : k ≤ n) : 0 ≤ curvatureProd n kappa k :=
  Finset.prod_nonneg fun _i hi =>
    curvatureFactor_nonneg h0 (le_trans (Finset.mem_range.1 hi) hk)

/-- The curvature product never exceeds the curvature-free decay `(1 − 1/n)^k`,
so the classical greedy guarantee is always recovered. -/
lemma curvatureProd_le_pow {n : ℕ} {kappa : ℝ} (h0 : 0 ≤ kappa) (h1 : kappa ≤ 1)
    {k : ℕ} (hk : k ≤ n) : curvatureProd n kappa k ≤ (1 - 1 / (n : ℝ)) ^ k := by
  have h : curvatureProd n kappa k ≤ ∏ _i ∈ Finset.range k, (1 - 1 / (n : ℝ)) := by
    refine Finset.prod_le_prod (fun _i hi => ?_) (fun _i hi => ?_)
    · exact curvatureFactor_nonneg h0 (le_trans (Finset.mem_range.1 hi) hk)
    · exact curvatureFactor_le h0 h1 (le_trans (Finset.mem_range.1 hi) hk)
  simpa using h

/-- **The zero-curvature endpoint.**  At `κ = 0` the last factor of the product
vanishes: the curvature analysis predicts a *zero* optimality gap. -/
lemma curvatureProd_self_eq_zero {n : ℕ} (hn : 1 ≤ n) : curvatureProd n 0 n = 0 := by
  refine Finset.prod_eq_zero (i := n - 1) (Finset.mem_range.2 (by omega)) ?_
  have hcast : ((n - 1 : ℕ) : ℝ) = (n : ℝ) - 1 := by
    have h1 : (1 : ℕ) ≤ n := hn
    push_cast [Nat.cast_sub h1]
    ring
  rw [hcast]
  have hrw : (n : ℝ) - (1 - 0) * ((n : ℝ) - 1) = 1 := by ring
  rw [hrw]
  norm_num

end CurvatureProduct

/-! ## Greedy library design inside a pool -/

section Greedy

variable [Fintype X] [DecidableEq ι]

/-- A greedy run *inside a candidate pool* `Ω`: it starts from the empty
library and each step adjoins a pool member of maximal marginal value. -/
structure PoolGreedyRun (Ω : Finset ι) (A : ℕ → Finset ι) : Prop where
  init : A 0 = ∅
  step : ∀ k, ∃ j ∈ Ω, A (k + 1) = insert j (A k)
  optimal : ∀ k, ∀ j ∈ Ω, shtarkov P (insert j (A k)) ≤ shtarkov P (A (k + 1))

/-- The value gained by the `k`-th greedy step. -/
noncomputable def greedyGain (A : ℕ → Finset ι) (k : ℕ) : ℝ :=
  shtarkov P (A (k + 1)) - shtarkov P (A k)

namespace PoolGreedyRun

variable {P} {Ω : Finset ι} {A : ℕ → Finset ι}

lemma subset_succ (h : PoolGreedyRun P Ω A) (k : ℕ) : A k ⊆ A (k + 1) := by
  obtain ⟨j, -, hj⟩ := h.step k
  rw [hj]
  exact Finset.subset_insert _ _

lemma subset_pool (h : PoolGreedyRun P Ω A) : ∀ k, A k ⊆ Ω := by
  intro k
  induction k with
  | zero => rw [h.init]; exact Finset.empty_subset _
  | succ k ih =>
      obtain ⟨j, hjΩ, hj⟩ := h.step k
      rw [hj]
      exact Finset.insert_subset hjΩ ih

lemma greedyGain_nonneg (h : PoolGreedyRun P Ω A) (k : ℕ) : 0 ≤ greedyGain P A k := by
  have := shtarkov_mono P (h.subset_succ k)
  unfold greedyGain
  linarith

/-- **The greedy gains are nonincreasing** — the algorithmic face of
submodularity. -/
lemma greedyGain_antitone (h : PoolGreedyRun P Ω A) (k : ℕ) :
    greedyGain P A (k + 1) ≤ greedyGain P A k := by
  obtain ⟨j, hjΩ, hj⟩ := h.step (k + 1)
  have hdim := shtarkov_diminishing P (h.subset_succ k) j
  have hopt := h.optimal k j hjΩ
  unfold greedyGain
  rw [hj]
  linarith

/-- Every model already in the greedy library has solo price at least the
current greedy gain. -/
lemma greedyGain_le_singleton (h : PoolGreedyRun P Ω A) :
    ∀ k, ∀ a ∈ A k, greedyGain P A k ≤ shtarkov P {a} := by
  intro k
  induction k with
  | zero => intro a ha; rw [h.init] at ha; exact absurd ha (Finset.notMem_empty a)
  | succ k ih =>
      intro a ha
      obtain ⟨j, -, hj⟩ := h.step k
      have hanti := h.greedyGain_antitone k
      rw [hj] at ha
      rcases Finset.mem_insert.1 ha with rfl | ha'
      · have hsolo : greedyGain P A k ≤ shtarkov P {a} := by
          have hsing := shtarkov_insert_sub_le_singleton P a (A k)
          unfold greedyGain
          rw [hj]
          linarith
        linarith
      · exact le_trans hanti (ih a ha')

/-- **A stalled greedy step certifies optimality.**  If the greedy gain is not
positive, the current library already beats every sub-library of the pool. -/
lemma shtarkov_le_of_greedyGain_nonpos (h : PoolGreedyRun P Ω A) {B : Finset ι}
    (hB : B ⊆ Ω) {k : ℕ} (hg : greedyGain P A k ≤ 0) :
    shtarkov P B ≤ shtarkov P (A k) := by
  have hcov := shtarkov_union_sub_le_sum P (A k) B
  have hterms : ∑ j ∈ B, (shtarkov P (insert j (A k)) - shtarkov P (A k)) ≤ 0 := by
    refine Finset.sum_nonpos fun j hj => ?_
    have := h.optimal k j (hB hj)
    unfold greedyGain at hg
    linarith
  have hmono : shtarkov P B ≤ shtarkov P (A k ∪ B) :=
    shtarkov_mono P Finset.subset_union_right
  linarith

lemma card_succ_of_greedyGain_pos (h : PoolGreedyRun P Ω A) {k : ℕ}
    (hg : 0 < greedyGain P A k) : (A (k + 1)).card = (A k).card + 1 := by
  obtain ⟨j, -, hj⟩ := h.step k
  have hjnot : j ∉ A k := by
    intro hmem
    have hEq : A (k + 1) = A k := by rw [hj, Finset.insert_eq_self.2 hmem]
    unfold greedyGain at hg
    rw [hEq] at hg
    linarith
  rw [hj, Finset.card_insert_of_notMem hjnot]

/-- **The curvature-sharpened greedy step.**  After `k` steps the optimality gap
against a target library `B` of size `n` is at most `n − (1 − κ)k` greedy gains.
The curvature-free analysis only gives the bound with `n` gains; every unit of
`1 − κ` shortens the remaining horizon by one step per model already chosen. -/
theorem gap_le_curvature_gain (h : PoolGreedyRun P Ω A) {B : Finset ι} (hB : B ⊆ Ω)
    {k : ℕ} (hcard : (A k).card = k) :
    shtarkov P B - shtarkov P (A k)
      ≤ ((B.card : ℝ) - (1 - curvature P Ω) * k) * greedyGain P A k := by
  have hAk : A k ⊆ Ω := h.subset_pool k
  have hg0 : 0 ≤ greedyGain P A k := h.greedyGain_nonneg k
  have hk0 : 0 ≤ curvature P Ω := curvature_nonneg P Ω
  have hk1 : curvature P Ω ≤ 1 := curvature_le_one P Ω
  have h1 : shtarkov P (A k ∪ B) - shtarkov P (A k)
      ≤ ∑ j ∈ B \ A k, (shtarkov P (insert j (A k)) - shtarkov P (A k)) := by
    have hu := shtarkov_union_sub_le_sum P (A k) (B \ A k)
    rwa [Finset.union_sdiff_self_eq_union] at hu
  have h2 : ∑ j ∈ B \ A k, (shtarkov P (insert j (A k)) - shtarkov P (A k))
      ≤ ((B \ A k).card : ℝ) * greedyGain P A k := by
    have hterm : ∀ j ∈ B \ A k,
        shtarkov P (insert j (A k)) - shtarkov P (A k) ≤ greedyGain P A k := by
      intro j hj
      have := h.optimal k j (hB (Finset.mem_sdiff.1 hj).1)
      unfold greedyGain
      linarith
    calc ∑ j ∈ B \ A k, (shtarkov P (insert j (A k)) - shtarkov P (A k))
        ≤ ∑ _j ∈ B \ A k, greedyGain P A k := Finset.sum_le_sum hterm
      _ = ((B \ A k).card : ℝ) * greedyGain P A k := by
          rw [Finset.sum_const, nsmul_eq_mul]
  have h3 := shtarkov_union_ge_curvature_aux P hB (A k \ B)
      (fun a ha => hAk (Finset.mem_sdiff.1 ha).1) Finset.sdiff_disjoint
  have hunion : (A k \ B) ∪ B = A k ∪ B := by
    ext y; simp [Finset.mem_union]
  rw [hunion] at h3
  have h4 : ((A k \ B).card : ℝ) * greedyGain P A k ≤ ∑ a ∈ A k \ B, shtarkov P {a} := by
    calc ((A k \ B).card : ℝ) * greedyGain P A k
        = ∑ _a ∈ A k \ B, greedyGain P A k := by rw [Finset.sum_const, nsmul_eq_mul]
      _ ≤ ∑ a ∈ A k \ B, shtarkov P {a} :=
          Finset.sum_le_sum fun a ha =>
            h.greedyGain_le_singleton k a (Finset.mem_sdiff.1 ha).1
  have h5 : (1 - curvature P Ω) * (((A k \ B).card : ℝ) * greedyGain P A k)
      ≤ (1 - curvature P Ω) * ∑ a ∈ A k \ B, shtarkov P {a} :=
    mul_le_mul_of_nonneg_left h4 (by linarith)
  have hc1 : ((B \ A k).card : ℝ) + ((A k ∩ B).card : ℝ) = (B.card : ℝ) := by
    have hcard' := Finset.card_sdiff_add_card_inter B (A k)
    have hcomm : (B ∩ A k).card = (A k ∩ B).card := by rw [Finset.inter_comm]
    rw [hcomm] at hcard'
    exact_mod_cast congrArg (fun m : ℕ => (m : ℝ)) hcard'
  have hc2 : ((A k \ B).card : ℝ) + ((A k ∩ B).card : ℝ) = (k : ℝ) := by
    have hcard' := Finset.card_sdiff_add_card_inter (A k) B
    rw [hcard] at hcard'
    exact_mod_cast congrArg (fun m : ℕ => (m : ℝ)) hcard'
  have hcnn : (0 : ℝ) ≤ ((A k ∩ B).card : ℝ) := Nat.cast_nonneg _
  have hs : ((B \ A k).card : ℝ) = (B.card : ℝ) - ((A k ∩ B).card : ℝ) := by linarith
  have ht : ((A k \ B).card : ℝ) = (k : ℝ) - ((A k ∩ B).card : ℝ) := by linarith
  rw [hs] at h2
  rw [ht] at h5
  have hchain : shtarkov P B - shtarkov P (A k)
      ≤ ((B.card : ℝ) - ((A k ∩ B).card : ℝ)) * greedyGain P A k
        - (1 - curvature P Ω)
          * (((k : ℝ) - ((A k ∩ B).card : ℝ)) * greedyGain P A k) := by linarith
  have hring : ((B.card : ℝ) - ((A k ∩ B).card : ℝ)) * greedyGain P A k
      - (1 - curvature P Ω)
        * (((k : ℝ) - ((A k ∩ B).card : ℝ)) * greedyGain P A k)
      = ((B.card : ℝ) - (1 - curvature P Ω) * k) * greedyGain P A k
        - curvature P Ω * (((A k ∩ B).card : ℝ) * greedyGain P A k) := by ring
  have hnn : 0 ≤ curvature P Ω * (((A k ∩ B).card : ℝ) * greedyGain P A k) :=
    mul_nonneg hk0 (mul_nonneg hcnn hg0)
  linarith

/-- **The curvature-sharpened greedy invariant.** -/
lemma greedy_invariant (h : PoolGreedyRun P Ω A) {B : Finset ι} (hB : B ⊆ Ω) :
    ∀ k, k ≤ B.card →
      (shtarkov P B ≤ shtarkov P (A k)) ∨
        ((A k).card = k ∧ shtarkov P B - shtarkov P (A k)
          ≤ curvatureProd B.card (curvature P Ω) k * shtarkov P B) := by
  intro k
  induction k with
  | zero =>
      intro _
      right
      refine ⟨by rw [h.init]; simp, ?_⟩
      rw [h.init, shtarkov_empty, curvatureProd_zero]
      linarith
  | succ k ih =>
      intro hk
      have hk' : k ≤ B.card := Nat.le_of_succ_le hk
      rcases ih hk' with hopt | ⟨hcard, hgap⟩
      · exact Or.inl (le_trans hopt (shtarkov_mono P (h.subset_succ k)))
      · by_cases hdone : shtarkov P B ≤ shtarkov P (A (k + 1))
        · exact Or.inl hdone
        · push_neg at hdone
          right
          have hgpos : 0 < greedyGain P A k := by
            by_contra hcon
            push_neg at hcon
            have hle := h.shtarkov_le_of_greedyGain_nonpos hB hcon
            have := shtarkov_mono P (h.subset_succ k)
            linarith
          refine ⟨by rw [h.card_succ_of_greedyGain_pos hgpos, hcard], ?_⟩
          have hk0 : 0 ≤ curvature P Ω := curvature_nonneg P Ω
          have hk1 : curvature P Ω ≤ 1 := curvature_le_one P Ω
          have hD : (1 : ℝ) ≤ (B.card : ℝ) - (1 - curvature P Ω) * k :=
            one_le_curvatureDenom hk0 hk
          have hDpos : (0 : ℝ) < (B.card : ℝ) - (1 - curvature P Ω) * k := by linarith
          have hfac : 0 ≤ 1 - 1 / ((B.card : ℝ) - (1 - curvature P Ω) * k) :=
            curvatureFactor_nonneg hk0 hk
          have hstep := gap_le_curvature_gain h hB hcard
          have hgdiv : (shtarkov P B - shtarkov P (A k))
              / ((B.card : ℝ) - (1 - curvature P Ω) * k) ≤ greedyGain P A k :=
            (div_le_iff₀ hDpos).2 (by linarith [hstep])
          have hsplit : shtarkov P B - shtarkov P (A (k + 1))
              = (shtarkov P B - shtarkov P (A k)) - greedyGain P A k := by
            unfold greedyGain; ring
          have hmul : (shtarkov P B - shtarkov P (A k))
              * (1 - 1 / ((B.card : ℝ) - (1 - curvature P Ω) * k))
              ≤ (curvatureProd B.card (curvature P Ω) k * shtarkov P B)
              * (1 - 1 / ((B.card : ℝ) - (1 - curvature P Ω) * k)) :=
            mul_le_mul_of_nonneg_right hgap hfac
          have hexpand : (shtarkov P B - shtarkov P (A k))
              * (1 - 1 / ((B.card : ℝ) - (1 - curvature P Ω) * k))
              = (shtarkov P B - shtarkov P (A k))
                - (shtarkov P B - shtarkov P (A k))
                  / ((B.card : ℝ) - (1 - curvature P Ω) * k) := by
            field_simp
          rw [curvatureProd_succ, hsplit]
          nlinarith [hmul, hgdiv, hexpand]

/-- **Curvature-sharpened greedy guarantee.**  After `k ≤ n` greedy steps the
optimality gap against any target library `B ⊆ Ω` of size `n` has been
multiplied by the curvature product. -/
theorem greedy_curvature_gap_le (h : PoolGreedyRun P Ω A) {B : Finset ι} (hB : B ⊆ Ω)
    {k : ℕ} (hk : k ≤ B.card) :
    shtarkov P B - shtarkov P (A k)
      ≤ curvatureProd B.card (curvature P Ω) k * shtarkov P B := by
  rcases h.greedy_invariant hB k hk with hopt | ⟨-, hgap⟩
  · have hQ : 0 ≤ curvatureProd B.card (curvature P Ω) k :=
      curvatureProd_nonneg (curvature_nonneg P Ω) hk
    have hBnn : 0 ≤ shtarkov P B := shtarkov_nonneg P B
    have := mul_nonneg hQ hBnn
    linarith
  · exact hgap

/-- **Zero curvature ⇒ greedy library design is exactly optimal.**  This is the
`κ → 0` endpoint of the conjectured `(1 − e^{−κ})/κ` guarantee, where the factor
tends to `1`. -/
theorem greedy_zero_curvature_optimal (h : PoolGreedyRun P Ω A) {B : Finset ι}
    (hB : B ⊆ Ω) (hne : B.Nonempty) (hcurv : curvature P Ω = 0) :
    shtarkov P B ≤ shtarkov P (A B.card) := by
  have hcard : 1 ≤ B.card := Finset.card_pos.2 hne
  have hgap := greedy_curvature_gap_le h hB (le_refl B.card)
  rw [hcurv, curvatureProd_self_eq_zero hcard] at hgap
  linarith

/-- **The classical guarantee is recovered for every pool.**  Whatever the
curvature, the greedy library of size `n = |B|` is within `1 − 1/e` of `B`. -/
theorem greedy_one_sub_inv_exp_le_pool (h : PoolGreedyRun P Ω A) {B : Finset ι}
    (hB : B ⊆ Ω) (hne : B.Nonempty) :
    (1 - Real.exp (-1)) * shtarkov P B ≤ shtarkov P (A B.card) := by
  have hcard : 1 ≤ B.card := Finset.card_pos.2 hne
  have hgap := greedy_curvature_gap_le h hB (le_refl B.card)
  have hprod := curvatureProd_le_pow (curvature_nonneg P Ω) (curvature_le_one P Ω)
    (le_refl B.card)
  have hpow := one_sub_inv_pow_le_exp_neg_one (n := B.card) hcard
  have hBnn : 0 ≤ shtarkov P B := shtarkov_nonneg P B
  have hmul := mul_le_mul_of_nonneg_right (le_trans hprod hpow) hBnn
  linarith

/-- **The numerator of the conjectured factor is achieved.**  Greedy library
design inside a pool of curvature `κ` recovers at least a `1 − e^{−κ}` fraction
of the price of any target library of the same size.  This is the conjectured
factor `(1 − e^{−κ})/κ` *without* the amplification by `1/κ`: since `κ ≤ 1`, the
factor `1 − e^{−κ}` is dominated by the classical `1 − 1/e`, so the whole content
of the Conforti–Cornuéjols conjecture sits in the `1/κ` amplification, which is
not proved here (`greedy_curvature_gap_le` is the strongest guarantee obtained;
see its documentation). -/
theorem greedy_one_sub_exp_neg_curvature (h : PoolGreedyRun P Ω A) {B : Finset ι}
    (hB : B ⊆ Ω) (hne : B.Nonempty) :
    (1 - Real.exp (-(curvature P Ω))) * shtarkov P B ≤ shtarkov P (A B.card) := by
  have hclassical := greedy_one_sub_inv_exp_le_pool h hB hne
  have hexp : Real.exp (-1) ≤ Real.exp (-(curvature P Ω)) :=
    Real.exp_le_exp.2 (by linarith [curvature_le_one P Ω])
  have hBnn : 0 ≤ shtarkov P B := shtarkov_nonneg P B
  nlinarith [hclassical, hexp, hBnn]

/-- **Low curvature ⇒ nearly optimal greedy libraries.**  A quantitative form of
the `κ → 0` endpoint: for a pool of curvature `κ` and a target library of size
`m + 1`, the residual optimality gap is at most `κ·m` times the optimum. -/
theorem greedy_low_curvature_gap (h : PoolGreedyRun P Ω A) {B : Finset ι}
    (hB : B ⊆ Ω) {m : ℕ} (hm : B.card = m + 1) :
    shtarkov P B - shtarkov P (A B.card)
      ≤ (curvature P Ω * m) * shtarkov P B := by
  have hk0 : 0 ≤ curvature P Ω := curvature_nonneg P Ω
  have hk1 : curvature P Ω ≤ 1 := curvature_le_one P Ω
  have hBnn : 0 ≤ shtarkov P B := shtarkov_nonneg P B
  have hgap := greedy_curvature_gap_le h hB (le_refl B.card)
  have hsucc : curvatureProd B.card (curvature P Ω) (m + 1)
      = curvatureProd B.card (curvature P Ω) m
        * (1 - 1 / ((B.card : ℝ) - (1 - curvature P Ω) * m)) :=
    curvatureProd_succ _ _ _
  have hmle : m ≤ B.card := by omega
  have hQnn : 0 ≤ curvatureProd B.card (curvature P Ω) m :=
    curvatureProd_nonneg hk0 hmle
  have hcardR : (1 : ℝ) ≤ (B.card : ℝ) := by
    have : 1 ≤ B.card := by omega
    exact_mod_cast this
  have hQle : curvatureProd B.card (curvature P Ω) m ≤ 1 := by
    have hpow := curvatureProd_le_pow hk0 hk1 hmle
    have hbase : (1 : ℝ) - 1 / (B.card : ℝ) ≤ 1 := by
      have : (0 : ℝ) ≤ 1 / (B.card : ℝ) := by positivity
      linarith
    have hbase0 : (0 : ℝ) ≤ 1 - 1 / (B.card : ℝ) := by
      have hpos : (0 : ℝ) < (B.card : ℝ) := by linarith
      have : 1 / (B.card : ℝ) ≤ 1 := by rw [div_le_one hpos]; exact hcardR
      linarith
    calc curvatureProd B.card (curvature P Ω) m ≤ (1 - 1 / (B.card : ℝ)) ^ m := hpow
      _ ≤ 1 := pow_le_one₀ hbase0 hbase
  have hden : (B.card : ℝ) - (1 - curvature P Ω) * m = 1 + curvature P Ω * m := by
    rw [hm]
    push_cast
    ring
  have hmnn : (0 : ℝ) ≤ (m : ℝ) := Nat.cast_nonneg m
  have hlast : 1 - 1 / ((B.card : ℝ) - (1 - curvature P Ω) * m)
      ≤ curvature P Ω * m := by
    rw [hden]
    have hpos : (0 : ℝ) < 1 + curvature P Ω * m := by nlinarith
    have hkey : 1 - curvature P Ω * m ≤ 1 / (1 + curvature P Ω * m) := by
      rw [le_div_iff₀ hpos]
      nlinarith [sq_nonneg (curvature P Ω * (m : ℝ))]
    linarith
  have hlast0 : 0 ≤ 1 - 1 / ((B.card : ℝ) - (1 - curvature P Ω) * m) := by
    have hml : m + 1 ≤ B.card := by omega
    exact curvatureFactor_nonneg hk0 hml
  have hfinal : curvatureProd B.card (curvature P Ω) B.card ≤ curvature P Ω * m := by
    calc curvatureProd B.card (curvature P Ω) B.card
        = curvatureProd B.card (curvature P Ω) (m + 1) := by rw [hm]
      _ = curvatureProd B.card (curvature P Ω) m
            * (1 - 1 / ((B.card : ℝ) - (1 - curvature P Ω) * m)) := hsucc
      _ ≤ 1 * (1 - 1 / ((B.card : ℝ) - (1 - curvature P Ω) * m)) :=
          mul_le_mul_of_nonneg_right hQle hlast0
      _ ≤ curvature P Ω * m := by rw [one_mul]; exact hlast
  have hmul := mul_le_mul_of_nonneg_right hfinal hBnn
  linarith

end PoolGreedyRun

/-! ### Pool-restricted greedy runs exist -/

/-- A pool member of maximal marginal value on top of the library `A`. -/
noncomputable def poolGreedyChoice {Ω : Finset ι} (hΩ : Ω.Nonempty) (A : Finset ι) : ι :=
  (Finset.exists_max_image Ω (fun j => shtarkov P (insert j A)) hΩ).choose

lemma poolGreedyChoice_mem {Ω : Finset ι} (hΩ : Ω.Nonempty) (A : Finset ι) :
    poolGreedyChoice P hΩ A ∈ Ω :=
  (Finset.exists_max_image Ω (fun j => shtarkov P (insert j A)) hΩ).choose_spec.1

lemma le_poolGreedyChoice {Ω : Finset ι} (hΩ : Ω.Nonempty) (A : Finset ι) {j : ι}
    (hj : j ∈ Ω) :
    shtarkov P (insert j A) ≤ shtarkov P (insert (poolGreedyChoice P hΩ A) A) :=
  (Finset.exists_max_image Ω (fun j => shtarkov P (insert j A)) hΩ).choose_spec.2 j hj

/-- The canonical greedy library sequence built inside the pool `Ω`. -/
noncomputable def poolGreedySeq {Ω : Finset ι} (hΩ : Ω.Nonempty) : ℕ → Finset ι
  | 0 => ∅
  | k + 1 => insert (poolGreedyChoice P hΩ (poolGreedySeq hΩ k)) (poolGreedySeq hΩ k)

/-- The canonical pool greedy sequence is a greedy run, so none of the
guarantees above is vacuous. -/
theorem poolGreedyRun_poolGreedySeq {Ω : Finset ι} (hΩ : Ω.Nonempty) :
    PoolGreedyRun P Ω (poolGreedySeq P hΩ) where
  init := rfl
  step k := ⟨poolGreedyChoice P hΩ (poolGreedySeq P hΩ k),
    poolGreedyChoice_mem P hΩ _, rfl⟩
  optimal _ _ hj := le_poolGreedyChoice P hΩ _ hj

/-- **The canonical greedy library of a zero-curvature pool is optimal.** -/
theorem poolGreedySeq_zero_curvature_optimal {Ω : Finset ι} (hΩ : Ω.Nonempty)
    {B : Finset ι} (hB : B ⊆ Ω) (hne : B.Nonempty) (hcurv : curvature P Ω = 0) :
    shtarkov P B ≤ shtarkov P (poolGreedySeq P hΩ B.card) :=
  (poolGreedyRun_poolGreedySeq P hΩ).greedy_zero_curvature_optimal hB hne hcurv

/-- **The canonical greedy library obeys the curvature-sharpened bound.** -/
theorem poolGreedySeq_curvature_gap_le {Ω : Finset ι} (hΩ : Ω.Nonempty)
    {B : Finset ι} (hB : B ⊆ Ω) {k : ℕ} (hk : k ≤ B.card) :
    shtarkov P B - shtarkov P (poolGreedySeq P hΩ k)
      ≤ curvatureProd B.card (curvature P Ω) k * shtarkov P B :=
  (poolGreedyRun_poolGreedySeq P hΩ).greedy_curvature_gap_le hB hk

end Greedy

end Library

end UniversalRedundancy