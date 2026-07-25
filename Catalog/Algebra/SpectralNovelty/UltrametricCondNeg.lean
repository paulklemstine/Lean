import Mathlib
import Algebra.SpectralNovelty.CutMetric

/-!
# Ultrametric Distance Matrices are Conditionally Negative Semidefinite

This file proves the central bridge theorem of the spectral theory of novelty:
**every finite ultrametric distance function is conditionally negative semidefinite**.

## Proof Strategy

We prove this by Nat induction on the number of distinct values in the range of d.
At each step, we "peel off" the maximum distance level:
- d(i,j) = min(d(i,j), M') + (M - M') · 1_{d(i,j) = M}
- The first part is an ultrametric with fewer distinct values (by IH, cond neg def)
- The second part is a separation indicator (always cond neg def for zero-sum vectors)

## Tags

ultrametric geometry, spectral theory, conditionally negative definite kernels,
dendrogram spectra, hierarchical clustering, compression duality
-/

open Finset BigOperators

/-! ### Separation Indicator Lemma

For any function f : Fin n → β, the "separation metric" d(i,j) = if f(i)=f(j) then 0 else 1
is conditionally negative semidefinite. This captures the fact that partition-based
distances always produce nonpositive quadratic energy on zero-sum vectors. -/

/-
The quadratic form of a separation indicator for a partition (given by a function f)
is nonpositive on zero-sum vectors. Specifically:
  ∑ᵢⱼ xᵢ xⱼ · 1_{f(i) ≠ f(j)} = (∑ xᵢ)² - ∑_a (∑_{f(i)=a} xᵢ)²
For zero-sum x, this equals -∑_a (∑_{f(i)=a} xᵢ)² ≤ 0.
-/
theorem separation_indicator_condNeg {n : ℕ} {β : Type*} [DecidableEq β]
    (f : Fin n → β) (x : Fin n → ℝ) (hx : ∑ i, x i = 0) :
    ∑ i : Fin n, ∑ j : Fin n, x i * x j *
      (if f i = f j then (0 : ℝ) else 1) ≤ 0 := by
  -- Let's rewrite the expression $\sum_{i,j} x_i x_j (1_{f(i) \neq f(j)})$ using the partitioning function.
  have h_partition : ∑ i, ∑ j, x i * x j * (if f i = f j then 0 else 1) = (∑ i, x i)^2 - ∑ a ∈ Finset.image f Finset.univ, (∑ i ∈ Finset.filter (fun i => f i = a) Finset.univ, x i)^2 := by
    have h_partition : ∑ i, ∑ j, x i * x j * (if f i = f j then 1 else 0) = ∑ a ∈ Finset.image f Finset.univ, (∑ i ∈ Finset.filter (fun i => f i = a) Finset.univ, x i)^2 := by
      simp +decide only [mul_ite, mul_one, mul_zero, sum_ite];
      simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, sq, mul_comm, Finset.sum_add_distrib ];
      rw [ Finset.sum_image' ] ; simp +decide [ eq_comm ];
      exact fun i => by rw [ Finset.sum_mul _ _ _ ] ; exact Finset.sum_congr rfl fun j hj => by aesop;
    simp_all +decide [ Finset.sum_ite, Finset.filter_not ];
    simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, hx ];
  exact h_partition ▸ by rw [ hx ] ; exact sub_nonpos_of_le ( by exact le_trans ( by norm_num ) ( Finset.sum_nonneg fun _ _ => sq_nonneg _ ) ) ;

/-! ### Min preserves ultrametric -/

/-
Capping an ultrametric at a threshold preserves the ultrametric property.
This uses the lattice identity min(max(a,b), c) ≤ max(min(a,c), min(b,c)).
-/
theorem min_ultrametric {n : ℕ} (d : Fin n → Fin n → ℝ) (c : ℝ) (hc : 0 ≤ c)
    (h_nonneg : ∀ i j, 0 ≤ d i j)
    (h_refl : ∀ i, d i i = 0)
    (h_symm : ∀ i j, d i j = d j i)
    (h_ultra : ∀ i j k, d i k ≤ max (d i j) (d j k)) :
    (∀ i j, 0 ≤ min (d i j) c) ∧
    (∀ i, min (d i i) c = 0) ∧
    (∀ i j, min (d i j) c = min (d j i) c) ∧
    (∀ i j k, min (d i k) c ≤ max (min (d i j) c) (min (d j k) c)) := by
  grind

/-! ### Main Theorem -/

/-
Auxiliary lemma: conditional negative definiteness for ultrametrics whose range
has at most k distinct values. Proved by induction on k.
-/
theorem ultrametric_condNeg_aux (k : ℕ) :
    ∀ {n : ℕ} (d : Fin n → Fin n → ℝ),
    (Finset.univ.image (fun p : Fin n × Fin n => d p.1 p.2)).card ≤ k →
    (∀ i j, 0 ≤ d i j) →
    (∀ i, d i i = 0) →
    (∀ i j, d i j = d j i) →
    (∀ i j k, d i k ≤ max (d i j) (d j k)) →
    ∀ x : Fin n → ℝ,
      (∑ i, x i) = 0 →
      ∑ i : Fin n, ∑ j : Fin n, x i * x j * d i j ≤ 0 := by
  intro n d hd h₀ h₁ h₂ h₃ x hx
  induction' k with k ih generalizing n d x;
  · cases n <;> simp_all +decide [ Finset.ext_iff ];
  · by_cases h_card : (Finset.image (fun p => d p.1 p.2) (Finset.univ : Finset (Fin n × Fin n))).card ≤ 1;
    · have h_const : ∀ i j, d i j = 0 := by
        rw [ Finset.card_le_one_iff ] at h_card;
        exact fun i j => h_card ( Finset.mem_image_of_mem _ ( Finset.mem_univ ( i, j ) ) ) ( Finset.mem_image_of_mem _ ( Finset.mem_univ ( i, i ) ) ) ▸ h₁ i ▸ rfl;
      norm_num [ h_const ];
    · -- Let $M$ be the maximum value in the range of $d$.
      obtain ⟨M, hM⟩ : ∃ M, M ∈ Finset.image (fun p => d p.1 p.2) (Finset.univ : Finset (Fin n × Fin n)) ∧ ∀ y ∈ Finset.image (fun p => d p.1 p.2) (Finset.univ : Finset (Fin n × Fin n)), y ≤ M := by
        exact ⟨ Finset.max' _ <| Finset.card_pos.mp <| pos_of_gt <| lt_of_not_ge h_card, Finset.max'_mem _ _, fun y hy => Finset.le_max' _ _ hy ⟩;
      -- Define $d'(i,j) = \min(d(i,j), M')$ where $M'$ is the second largest value in the range of $d$.
      obtain ⟨M', hM'⟩ : ∃ M', M' < M ∧ M' ∈ Finset.image (fun p => d p.1 p.2) (Finset.univ : Finset (Fin n × Fin n)) ∧ ∀ y ∈ Finset.image (fun p => d p.1 p.2) (Finset.univ : Finset (Fin n × Fin n)), y < M → y ≤ M' := by
        obtain ⟨M', hM'⟩ : ∃ M', M' ∈ Finset.image (fun p => d p.1 p.2) (Finset.univ : Finset (Fin n × Fin n)) ∧ M' < M := by
          exact Exists.elim ( Finset.exists_mem_ne ( lt_of_not_ge h_card ) M ) fun x hx => ⟨ x, hx.1, lt_of_le_of_ne ( hM.2 x hx.1 ) hx.2 ⟩;
        have h_max_lt_M : ∃ M', M' ∈ Finset.image (fun p => d p.1 p.2) (Finset.univ : Finset (Fin n × Fin n)) ∧ M' < M ∧ ∀ y ∈ Finset.image (fun p => d p.1 p.2) (Finset.univ : Finset (Fin n × Fin n)), y < M → y ≤ M' := by
          have h_finite : Finset.Nonempty (Finset.filter (fun y => y < M) (Finset.image (fun p => d p.1 p.2) (Finset.univ : Finset (Fin n × Fin n)))) := by
            exact ⟨ M', Finset.mem_filter.mpr ⟨ hM'.1, hM'.2 ⟩ ⟩
          exact ⟨ Finset.max' _ h_finite, Finset.mem_filter.mp ( Finset.max'_mem _ h_finite ) |>.1, Finset.mem_filter.mp ( Finset.max'_mem _ h_finite ) |>.2, fun y hy hy' => Finset.le_max' _ _ ( Finset.mem_filter.mpr ⟨ hy, hy' ⟩ ) ⟩;
        exact ⟨ h_max_lt_M.choose, h_max_lt_M.choose_spec.2.1, h_max_lt_M.choose_spec.1, h_max_lt_M.choose_spec.2.2 ⟩;
      -- Define $d'(i,j) = \min(d(i,j), M')$.
      set d' : Fin n → Fin n → ℝ := fun i j => min (d i j) M';
      -- By the induction hypothesis, $d'$ is conditionally negative semidefinite.
      have h_ind : ∑ i, ∑ j, x i * x j * d' i j ≤ 0 := by
        apply ih d';
        any_goals assumption;
        · have h_image_d' : Finset.image (fun p => d' p.1 p.2) (Finset.univ : Finset (Fin n × Fin n)) ⊆ Finset.image (fun p => d p.1 p.2) (Finset.univ : Finset (Fin n × Fin n)) \ {M} := by
            grind;
          exact le_trans ( Finset.card_le_card h_image_d' ) ( by rw [ Finset.card_sdiff ] ; norm_num [ hM.1 ] ; omega );
        · exact fun i j => le_min ( h₀ i j ) ( by obtain ⟨ p, hp, rfl ⟩ := Finset.mem_image.mp hM'.2.1; exact h₀ _ _ );
        · grind;
        · grind +revert;
        · grind +locals;
      -- The second part is a separation indicator, which is conditionally negative semidefinite.
      have h_sep : ∑ i, ∑ j, x i * x j * (if d i j = M then 1 else 0) ≤ 0 := by
        -- By the properties of the separation indicator, we have:
        have h_sep_indicator : ∑ i, ∑ j, x i * x j * (if d i j = M then 1 else 0) = -∑ i, ∑ j, x i * x j * (if d i j < M then 1 else 0) := by
          have h_sep_indicator : ∑ i, ∑ j, x i * x j * (if d i j = M then 1 else 0) + ∑ i, ∑ j, x i * x j * (if d i j < M then 1 else 0) = ∑ i, ∑ j, x i * x j := by
            rw [ ← Finset.sum_add_distrib ];
            refine' Finset.sum_congr rfl fun i hi => _;
            rw [ ← Finset.sum_add_distrib ] ; refine' Finset.sum_congr rfl fun j hj => _ ; split_ifs <;> ring;
            · linarith;
            · exact False.elim <| ‹¬d i j < M› <| lt_of_le_of_ne ( hM.2 _ <| Finset.mem_image_of_mem _ <| Finset.mem_univ ( i, j ) ) ‹_›;
          exact eq_neg_of_add_eq_zero_left ( h_sep_indicator.trans ( by simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, hx ] ) );
        -- By the properties of the separation indicator, we have that $\sum_{i,j} x_i x_j \cdot \mathbf{1}_{d(i,j) < M} \geq 0$.
        have h_sep_indicator_nonneg : ∑ i, ∑ j, x i * x j * (if d i j < M then 1 else 0) ≥ 0 := by
          -- By the properties of the separation indicator, we have that $\sum_{i,j} x_i x_j \cdot \mathbf{1}_{d(i,j) < M} = \sum_{a} (\sum_{i \in A_a} x_i)^2$ where $A_a$ are the equivalence classes under $d(i,j) < M$.
          have h_sep_indicator_eq : ∑ i, ∑ j, x i * x j * (if d i j < M then 1 else 0) = ∑ a ∈ Finset.image (fun i => Finset.filter (fun j => d i j < M) Finset.univ) Finset.univ, (∑ i ∈ a, x i) ^ 2 := by
            have h_sep_indicator_eq : ∀ i j, d i j < M ↔ Finset.filter (fun k => d i k < M) Finset.univ = Finset.filter (fun k => d j k < M) Finset.univ := by
              intro i j; constructor <;> intro hij <;> simp +decide [ Finset.ext_iff, Set.ext_iff ] at hij ⊢;
              · grind;
              · grind;
            rw [ Finset.sum_image' ];
            simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, sq, h₁ ];
            intro i; rw [ Finset.sum_mul ] ; rw [ Finset.sum_congr rfl ] ; simp +decide [ Finset.sum_ite, h₁ ] ;
            any_goals intros; rw [ Finset.mul_sum _ _ _ ];
            congr! 1;
            · grind +qlia;
            · grind;
          exact h_sep_indicator_eq.symm ▸ Finset.sum_nonneg fun _ _ => sq_nonneg _;
        linarith;
      nontriviality;
      convert add_nonpos h_ind ( mul_nonpos_of_nonneg_of_nonpos ( sub_nonneg.mpr hM'.1.le ) h_sep ) using 1;
      nontriviality;
      simp +decide only [Finset.mul_sum _ _ _];
      rw [ ← Finset.sum_add_distrib ];
      refine' Finset.sum_congr rfl fun i hi => _;
      rw [ ← Finset.sum_add_distrib ] ; refine' Finset.sum_congr rfl fun j hj => _ ; by_cases h : d i j = M <;> simp +decide [ h ];
      · rw [ show d' i j = M' by exact min_eq_right ( by linarith [ hM.2 _ ( Finset.mem_image_of_mem _ ( Finset.mk_mem_product hi hj ) ) ] ) ] ; ring;
      · exact Or.inl <| Eq.symm <| min_eq_left <| hM'.2.2 _ ( Finset.mem_image_of_mem _ <| Finset.mem_univ ( i, j ) ) <| lt_of_le_of_ne ( hM.2 _ <| Finset.mem_image_of_mem _ <| Finset.mem_univ ( i, j ) ) h

/-- **Theorem A: Negative Type of Finite Ultrametrics (Main Bridge Theorem)**.

For every finite ultrametric space (Fin n, d), the quadratic form of d is
nonpositive on the codimension-1 subspace of zero-sum vectors:

  ∀ x with ∑ᵢ xᵢ = 0, ∑ᵢⱼ xᵢ xⱼ d(i,j) ≤ 0.

This is the precise mathematical bridge connecting hierarchical novelty
(ultrametric structure) to spectral rigidity (negative type). -/
theorem ultrametric_distance_matrix_condNeg
    {n : ℕ} (_hn : 0 < n)
    (d : Fin n → Fin n → ℝ)
    (h_nonneg : ∀ i j, 0 ≤ d i j)
    (h_refl : ∀ i, d i i = 0)
    (h_symm : ∀ i j, d i j = d j i)
    (h_ultra : ∀ i j k, d i k ≤ max (d i j) (d j k)) :
    ∀ x : Fin n → ℝ,
      (∑ i, x i) = 0 →
      ∑ i : Fin n, ∑ j : Fin n, x i * x j * d i j ≤ 0 :=
  ultrametric_condNeg_aux _ d le_rfl h_nonneg h_refl h_symm h_ultra