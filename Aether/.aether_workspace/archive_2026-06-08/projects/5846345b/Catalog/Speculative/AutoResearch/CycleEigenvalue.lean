/-
Copyright (c) 2026 Harmonic. All rights reserved.

# Tropical Eigenvalue as Minimum Cycle Mean

This file formalizes the tropical eigenvalue of a weighted directed graph (encoded as a
real-valued matrix) as the minimum cycle mean, and proves foundational invariance and
extremal properties.

## Main Definitions

* `IsClosedWalk` — predicate for a closed walk (first vertex = last vertex)
* `cycleCost` — total edge-weight cost of a walk
* `cycleMean` — mean edge-weight cost of a walk
* `tropicalEigenvalueSet` — the set of all cycle means of closed walks
* `tropicalEigenvalue` — the infimum of all cycle means (min-plus spectral radius)

## Main Results

* `cycleCost_add_const` — adding a constant to every edge shifts cost by `k * a`
* `cycleMean_add_const` — adding a constant to every edge shifts mean by `a`
* `cycleCost_mono` — pointwise matrix inequality implies cost inequality
* `cycleMean_mono` — pointwise matrix inequality implies mean inequality
* `tropicalEigenvalue_le_diag` — the tropical eigenvalue is ≤ any diagonal entry
* `tropicalEigenvalue_add_const` — shift invariance of the tropical eigenvalue
* `tropicalEigenvalue_mono` — monotonicity of the tropical eigenvalue
* `tropicalEigenvalue_const` — tropical eigenvalue of a constant matrix
* `exists_bounded_cycle_mean_le` — cycle reduction to bounded-length cycles
* `tropicalEigenvalue_attained` — the infimum is attained by a cycle of length ≤ n
-/

import Mathlib

open BigOperators Finset

noncomputable section

/-! ## Part 1: Core Definitions -/

/-- A closed walk on `Fin n`: the first vertex equals the last vertex. -/
def IsClosedWalk {n k : ℕ} (v : Fin (k + 1) → Fin n) : Prop :=
  v 0 = v ⟨k, Nat.lt_succ_self k⟩

/-- Cost of traversing a walk: sum of edge weights `W(v_i, v_{i+1})`. -/
def cycleCost {n k : ℕ} (W : Matrix (Fin n) (Fin n) ℝ)
    (v : Fin (k + 1) → Fin n) : ℝ :=
  ∑ i : Fin k, W (v i.castSucc) (v i.succ)

/-- Mean cost per edge of a walk. -/
def cycleMean {n k : ℕ} (W : Matrix (Fin n) (Fin n) ℝ)
    (_hk : 0 < k) (v : Fin (k + 1) → Fin n) : ℝ :=
  cycleCost W v / k

/-- The constant matrix with all entries equal to `a`. -/
def constMatrix (n : ℕ) (a : ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  fun _ _ => a

/-- The set of all cycle means achievable by closed walks on `Fin n`. -/
def tropicalEigenvalueSet {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) : Set ℝ :=
  {x | ∃ (k : ℕ) (hk : 0 < k) (v : Fin (k + 1) → Fin n),
    IsClosedWalk v ∧ x = cycleMean W hk v}

/-- **Tropical eigenvalue**: the infimum of all cycle means over closed walks. -/
def tropicalEigenvalue {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  sInf (tropicalEigenvalueSet W)

/-! ## Part 2: Basic Lemmas -/

theorem cycleCost_add_const {n k : ℕ} (W : Matrix (Fin n) (Fin n) ℝ)
    (v : Fin (k + 1) → Fin n) (a : ℝ) :
    cycleCost (W + constMatrix n a) v = cycleCost W v + k * a := by
  simp only [cycleCost, constMatrix, Matrix.add_apply, Pi.add_apply]
  rw [Finset.sum_add_distrib]
  simp [Finset.sum_const, Finset.card_fin, nsmul_eq_mul]

theorem cycleMean_add_const {n k : ℕ} (W : Matrix (Fin n) (Fin n) ℝ)
    (hk : 0 < k) (v : Fin (k + 1) → Fin n) (a : ℝ) :
    cycleMean (W + constMatrix n a) hk v = cycleMean W hk v + a := by
  unfold cycleMean
  rw [cycleCost_add_const, add_div, mul_div_cancel_left₀ _ (by positivity)]

theorem cycleCost_mono {n k : ℕ} {W W' : Matrix (Fin n) (Fin n) ℝ}
    (h : ∀ i j, W i j ≤ W' i j) (v : Fin (k + 1) → Fin n) :
    cycleCost W v ≤ cycleCost W' v :=
  Finset.sum_le_sum fun i _ => h _ _

theorem cycleMean_mono {n k : ℕ} (hk : 0 < k)
    {W W' : Matrix (Fin n) (Fin n) ℝ}
    (h : ∀ i j, W i j ≤ W' i j) (v : Fin (k + 1) → Fin n) :
    cycleMean W hk v ≤ cycleMean W' hk v :=
  div_le_div_of_nonneg_right (cycleCost_mono h v) (Nat.cast_nonneg _)

/-! ## Part 3: The Tropical Eigenvalue Set -/

theorem selfLoop_cycleMean {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) :
    cycleMean W one_pos (fun _ : Fin 2 => i) = W i i := by
  simp [cycleMean, cycleCost, Fin.sum_univ_one, Fin.castSucc, Fin.succ]

theorem selfLoop_mem_tropicalEigenvalueSet {n : ℕ}
    (W : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) :
    W i i ∈ tropicalEigenvalueSet W :=
  ⟨1, one_pos, fun _ => i, by simp [IsClosedWalk], by rw [selfLoop_cycleMean]⟩

theorem tropicalEigenvalueSet_nonempty {n : ℕ} (hn : 0 < n)
    (W : Matrix (Fin n) (Fin n) ℝ) :
    (tropicalEigenvalueSet W).Nonempty :=
  ⟨W ⟨0, hn⟩ ⟨0, hn⟩, selfLoop_mem_tropicalEigenvalueSet W ⟨0, hn⟩⟩

theorem tropicalEigenvalueSet_bddBelow {n : ℕ}
    (W : Matrix (Fin n) (Fin n) ℝ) :
    BddBelow (tropicalEigenvalueSet W) := by
  rcases n with ( _ | n );
  · exact ⟨ 0, by rintro x ⟨ k, hk, v, hv, rfl ⟩ ; exact False.elim <| Fin.elim0 <| v ⟨ 0, by linarith ⟩ ⟩;
  · -- Let m be the minimum entry of W.
    set m := sInf (Set.range (fun p : Fin (n + 1) × Fin (n + 1) => W p.1 p.2));
    refine' ⟨ m, fun x hx => _ ⟩;
    obtain ⟨ k, hk, v, hv, rfl ⟩ := hx;
    have h_sum_ge_k_m : ∑ i : Fin k, W (v i.castSucc) (v i.succ) ≥ k * m := by
      exact le_trans ( by norm_num ) ( Finset.sum_le_sum fun i _ => show W ( v i.castSucc ) ( v i.succ ) ≥ m from csInf_le ( Set.finite_range _ |> Set.Finite.bddBelow ) ⟨ ( v i.castSucc, v i.succ ), rfl ⟩ );
    exact le_div_iff₀' ( by positivity ) |>.2 h_sum_ge_k_m

/-! ## Part 4: Core Properties -/

theorem tropicalEigenvalue_le_diag {n : ℕ}
    (W : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) :
    tropicalEigenvalue W ≤ W i i :=
  csInf_le (tropicalEigenvalueSet_bddBelow W)
    (selfLoop_mem_tropicalEigenvalueSet W i)

theorem tropicalEigenvalue_le_cycleMean {n k : ℕ}
    (W : Matrix (Fin n) (Fin n) ℝ) (hk : 0 < k)
    (v : Fin (k + 1) → Fin n) (hv : IsClosedWalk v) :
    tropicalEigenvalue W ≤ cycleMean W hk v :=
  csInf_le (tropicalEigenvalueSet_bddBelow W) ⟨k, hk, v, hv, rfl⟩

theorem tropicalEigenvalue_add_const {n : ℕ} (hn : 0 < n)
    (W : Matrix (Fin n) (Fin n) ℝ) (a : ℝ) :
    tropicalEigenvalue (W + constMatrix n a) = tropicalEigenvalue W + a := by
  -- By definition of tropical eigenvalue, we know that for any $x$ in the tropical eigenvalue set of $W$, $x + a$ is in the tropical eigenvalue set of $W + \text{constMatrix} n a$.
  have h_add_const : ∀ x ∈ tropicalEigenvalueSet W, x + a ∈ tropicalEigenvalueSet (W + constMatrix n a) := by
    rintro x ⟨ k, hk, v, hv, rfl ⟩;
    exact ⟨ k, hk, v, hv, by rw [ ← cycleMean_add_const ] ⟩;
  refine' le_antisymm _ _;
  · -- By definition of tropical eigenvalue, we know that for any $\epsilon > 0$, there exists $x \in \text{tropicalEigenvalueSet } W$ such that $x \leq \text{tropicalEigenvalue } W + \epsilon$.
    have h_eps : ∀ ε > 0, ∃ x ∈ tropicalEigenvalueSet W, x ≤ tropicalEigenvalue W + ε := by
      exact fun ε ε_pos => by rcases exists_lt_of_csInf_lt ( tropicalEigenvalueSet_nonempty hn W ) ( show InfSet.sInf ( tropicalEigenvalueSet W ) < InfSet.sInf ( tropicalEigenvalueSet W ) + ε from lt_add_of_pos_right _ ε_pos ) with ⟨ x, hx₁, hx₂ ⟩ ; exact ⟨ x, hx₁, le_of_lt hx₂ ⟩ ;
    exact le_of_forall_pos_le_add fun ε ε_pos => by obtain ⟨ x, hx₁, hx₂ ⟩ := h_eps ε ε_pos; linarith [ show tropicalEigenvalue ( W + constMatrix n a ) ≤ x + a from csInf_le ( by exact? ) ( h_add_const x hx₁ ) ] ;
  · refine' le_csInf _ _;
    · exact ⟨ _, h_add_const _ ( selfLoop_mem_tropicalEigenvalueSet W ⟨ 0, hn ⟩ ) ⟩;
    · intro b hb;
      -- By definition of $tropicalEigenvalueSet$, there exists some $x \in tropicalEigenvalueSet W$ such that $x + a = b$.
      obtain ⟨x, hx⟩ : ∃ x ∈ tropicalEigenvalueSet W, x + a = b := by
        obtain ⟨ k, hk, v, hv, rfl ⟩ := hb;
        exact ⟨ cycleMean W hk v, ⟨ k, hk, v, hv, rfl ⟩, by rw [ cycleMean_add_const ] ⟩;
      linarith [ show tropicalEigenvalue W ≤ x from csInf_le ( tropicalEigenvalueSet_bddBelow W ) hx.1 ]

theorem tropicalEigenvalue_mono {n : ℕ} (hn : 0 < n)
    {W W' : Matrix (Fin n) (Fin n) ℝ}
    (h : ∀ i j, W i j ≤ W' i j) :
    tropicalEigenvalue W ≤ tropicalEigenvalue W' := by
  refine' le_csInf _ _;
  · exact?;
  · rintro _ ⟨ k, hk, v, hv, rfl ⟩;
    exact le_trans ( tropicalEigenvalue_le_cycleMean W hk v hv ) ( cycleMean_mono hk h v )

theorem tropicalEigenvalue_const {n : ℕ} (hn : 0 < n) (c : ℝ) :
    tropicalEigenvalue (constMatrix n c) = c := by
  refine' le_antisymm ( csInf_le _ _ ) ( le_csInf _ _ );
  · exact?;
  · exact selfLoop_mem_tropicalEigenvalueSet _ ⟨ 0, hn ⟩;
  · exact?;
  · rintro _ ⟨ k, hk, v, hv, rfl ⟩;
    unfold cycleMean cycleCost; norm_num [ constMatrix ];
    rw [ mul_div_cancel_left₀ _ ( by positivity ) ]

theorem tropicalEigenvalue_le_entry_avg {n : ℕ}
    (W : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) :
    tropicalEigenvalue W ≤ (W i j + W j i) / 2 := by
  convert tropicalEigenvalue_le_cycleMean W two_pos _ _ using 1;
  rotate_left;
  exact fun k => if k = 0 then i else if k = 1 then j else i;
  · exact?;
  · unfold cycleMean; norm_num [ Fin.sum_univ_succ ] ; ring;
    unfold cycleCost; simp +decide [ Fin.sum_univ_succ ] ;

/-! ## Part 5: Walk Surgery Helpers -/

/-
Weighted average: min(a/p, b/q) ≤ (a+b)/(p+q) for positive p, q.
-/
theorem weighted_avg_min_le {a b : ℝ} {p q : ℕ} (hp : 0 < p) (hq : 0 < q) :
    min (a / p) (b / q) ≤ (a + b) / (↑p + ↑q) := by
  cases min_cases ( a / p : ℝ ) ( b / q : ℝ ) <;> rw [ le_div_iff₀ ( by positivity ) ] at * <;> nlinarith [ show ( p : ℝ ) > 0 by positivity, show ( q : ℝ ) > 0 by positivity, mul_div_cancel₀ a ( by positivity : ( p : ℝ ) ≠ 0 ), mul_div_cancel₀ b ( by positivity : ( q : ℝ ) ≠ 0 ) ]

/-- Extract the inner sub-cycle from index i to j in a walk. -/
def subwalkInner {n k : ℕ} (v : Fin (k + 1) → Fin n)
    (i j : ℕ) (hij : i ≤ j) (hjk : j ≤ k) :
    Fin (j - i + 1) → Fin n :=
  fun t => v ⟨i + t.val, by omega⟩

theorem subwalkInner_closed {n k : ℕ} (v : Fin (k + 1) → Fin n)
    (i j : ℕ) (hij : i ≤ j) (hjk : j ≤ k)
    (heq : v ⟨i, by omega⟩ = v ⟨j, by omega⟩) :
    IsClosedWalk (subwalkInner v i j hij hjk) := by
  convert heq using 1;
  constructor <;> intro h <;> simp_all +decide [ IsClosedWalk, subwalkInner ]

/-- Extract the outer walk: v[0..i] ++ v[j..k]. -/
def subwalkOuter {n k : ℕ} (v : Fin (k + 1) → Fin n)
    (i j : ℕ) (hij : i < j) (hjk : j ≤ k) :
    Fin (k - (j - i) + 1) → Fin n :=
  fun t => if t.val ≤ i then v ⟨t.val, by omega⟩
           else v ⟨t.val + (j - i), by omega⟩

theorem subwalkOuter_closed {n k : ℕ} (v : Fin (k + 1) → Fin n)
    (hclosed : IsClosedWalk v)
    (i j : ℕ) (hij : i < j) (hjk : j ≤ k)
    (heq : v ⟨i, by omega⟩ = v ⟨j, by omega⟩) :
    IsClosedWalk (subwalkOuter v i j hij hjk) := by
  unfold IsClosedWalk at *;
  unfold subwalkOuter;
  grind

theorem cycleCost_decompose {n k : ℕ} (W : Matrix (Fin n) (Fin n) ℝ)
    (v : Fin (k + 1) → Fin n) (i j : ℕ) (hij : i < j) (hjk : j ≤ k)
    (heq : v ⟨i, by omega⟩ = v ⟨j, by omega⟩) :
    cycleCost W v = cycleCost W (subwalkInner v i j (le_of_lt hij) hjk)
                  + cycleCost W (subwalkOuter v i j hij hjk) := by
  unfold cycleCost subwalkInner subwalkOuter;
  simp +decide [ Finset.sum_fin_eq_sum_range, Finset.sum_range_add _ _ ( j - i ), Finset.sum_range_add _ _ ( k - j + 1 ), Nat.sub_add_comm hij.le ];
  have h_split : Finset.range k = Finset.image (fun x => i + x) (Finset.range (j - i)) ∪ Finset.image (fun x => if x < i then x else x + (j - i)) (Finset.range (k - (j - i))) := by
    ext x;
    simp +zetaDelta at *;
    constructor;
    · intro hx;
      by_cases h : x < i;
      · exact Or.inr ⟨ x, by omega, by aesop ⟩;
      · by_cases h' : x < j;
        · exact Or.inl ⟨ x - i, by omega, by omega ⟩;
        · exact Or.inr ⟨ x - ( j - i ), by omega, by split_ifs <;> omega ⟩;
    · grind;
  rw [ h_split, Finset.sum_union ];
  · rw [ Finset.sum_image, Finset.sum_image ] <;> norm_num [ Finset.sum_range, Nat.lt_succ_iff ];
    · grind +revert;
    · intro x hx y hy; simp +decide [ Set.InjOn ] at *; split_ifs <;> omega;
  · norm_num [ Finset.disjoint_left ];
    intro a ha x hx; split_ifs <;> omega;

/-! ## Part 6: Cycle Reduction and Attainment -/

/-
**Cycle reduction**: every closed walk has a sub-walk of length ≤ n
    with cycle mean no greater.
-/
theorem exists_bounded_cycle_mean_le {n k : ℕ}
    (W : Matrix (Fin n) (Fin n) ℝ)
    (hk : 0 < k) (v : Fin (k + 1) → Fin n)
    (hclosed : IsClosedWalk v) :
    ∃ (m : ℕ) (hm : 0 < m) (_ : m ≤ n) (u : Fin (m + 1) → Fin n),
        IsClosedWalk u ∧ cycleMean W hm u ≤ cycleMean W hk v := by
  revert v hclosed;
  -- By strong induction on $k$ using `Nat.strongRecOn`.
  induction' k using Nat.strong_induction_on with k ih;
  intro v hclosed
  by_cases hk_le_n : k ≤ n;
  · exact ⟨ k, hk, hk_le_n, v, hclosed, le_rfl ⟩;
  · -- By pigeonhole, there exist indices $a$ and $b$ such that $a < b$ and $v a = v b$.
    obtain ⟨a, b, hab, hv_eq⟩ : ∃ a b : Fin k, a < b ∧ v ⟨a.val, by
      linarith [ Fin.is_lt a ]⟩ = v ⟨b.val, by
      linarith [ Fin.is_lt b ]⟩ := by
      by_contra! h;
      exact absurd ( Fintype.card_le_of_injective ( fun a : Fin k => v ⟨ a, by linarith [ Fin.is_lt a ] ⟩ ) fun a b hab => le_antisymm ( not_lt.mp fun ha => h _ _ ha hab.symm ) ( not_lt.mp fun hb => h _ _ hb hab ) ) ( by simpa using by linarith )
    generalize_proofs at *;
    -- By cycleCost_decompose, we have cycleCost W v = cycleCost W (subwalkInner v a.val b.val (le_of_lt hab) (by sorry)) + cycleCost W (subwalkOuter v a.val b.val hab (by sorry)).
    have h_cycleCost_decompose : cycleCost W v = cycleCost W (subwalkInner v a.val b.val (le_of_lt hab) (by
    exact Nat.le_of_lt ( Fin.is_lt b ))) + cycleCost W (subwalkOuter v a.val b.val hab (by
    exact Nat.le_of_lt ( Fin.is_lt b ))) := by
      grind +suggestions
    generalize_proofs at *;
    -- By weighted_avg_min_le, we have min(cycleMean W (b.val - a.val) (subwalkInner v a.val b.val (le_of_lt hab) (by sorry)), cycleMean W (k - (b.val - a.val)) (subwalkOuter v a.val b.val hab (by sorry))) ≤ cycleMean W hk v.
    have h_weighted_avg_min_le : min (cycleMean W (by
    exact Nat.sub_pos_of_lt hab) (subwalkInner v a.val b.val (le_of_lt hab) (by
    linarith))) (cycleMean W (by
    exact Nat.sub_pos_of_lt ( by omega )) (subwalkOuter v a.val b.val hab (by
    linarith))) ≤ cycleMean W hk v := by
      all_goals generalize_proofs at *;
      unfold cycleMean at *;
      rw [ h_cycleCost_decompose, add_div ];
      convert weighted_avg_min_le ‹0 < ( b : ℕ ) - a› ‹0 < k - ( b - a ) › using 1 ; norm_num [ Nat.cast_sub ( show ( b : ℕ ) ≥ a from by assumption ), Nat.cast_sub ( show ( k : ℕ ) ≥ ( b - a ) from by omega ) ] ; ring
    generalize_proofs at *;
    cases min_cases ( cycleMean W ‹_› ( subwalkInner v ( a : ℕ ) ( b : ℕ ) ( by omega ) ( by omega ) ) ) ( cycleMean W ‹_› ( subwalkOuter v ( a : ℕ ) ( b : ℕ ) hab ( by omega ) ) ) <;> simp_all +decide only;
    · exact ih _ ( by omega ) _ _ ( subwalkInner_closed _ _ _ ( by omega ) ( by omega ) hv_eq ) |> fun ⟨ m, hm₁, hm₂, u, hu₁, hu₂ ⟩ => ⟨ m, hm₁, hm₂, u, hu₁, hu₂.trans h_weighted_avg_min_le ⟩;
    · exact ih _ ( by omega ) _ _ ( subwalkOuter_closed _ hclosed _ _ hab ( by omega ) hv_eq ) |> fun ⟨ m, hm₁, hm₂, u, hu₁, hu₂ ⟩ => ⟨ m, hm₁, hm₂, u, hu₁, hu₂.trans h_weighted_avg_min_le ⟩

/-
**Attainment**: for `n > 0`, the tropical eigenvalue is attained by a
    closed walk of length between 1 and `n`.
-/
theorem tropicalEigenvalue_attained {n : ℕ} (hn : 0 < n)
    (W : Matrix (Fin n) (Fin n) ℝ) :
    ∃ (k : ℕ) (hk : 0 < k) (_ : k ≤ n) (v : Fin (k + 1) → Fin n),
        IsClosedWalk v ∧ tropicalEigenvalue W = cycleMean W hk v := by
  -- By `exists_bounded_cycle_mean_le`, there exists a cycle with length to n having cycle mean ≤ the cycle mean of some closed walk.
  have h_exists_bounded_cycle_mean_le : ∃ k : ℕ, ∃ hk : 0 < k, ∃ u : Fin (k + 1) → Fin n, IsClosedWalk u ∧ k ≤ n ∧ cycleMean W hk u ≤ tropicalEigenvalue W := by
    have h_exists_bounded_cycle_mean_le : ∀ ε > 0, ∃ k : ℕ, ∃ hk : 0 < k, ∃ u : Fin (k + 1) → Fin n, IsClosedWalk u ∧ k ≤ n ∧ cycleMean W hk u < tropicalEigenvalue W + ε := by
      intro ε hε
      obtain ⟨x, hx⟩ : ∃ x ∈ tropicalEigenvalueSet W, x < tropicalEigenvalue W + ε := by
        exact exists_lt_of_csInf_lt ( tropicalEigenvalueSet_nonempty hn W ) ( lt_add_of_pos_right _ hε );
      rcases hx.1 with ⟨ k, hk, v, hv, rfl ⟩ ; rcases exists_bounded_cycle_mean_le W hk v hv with ⟨ m, hm₁, hm₂, u, hu₁, hu₂ ⟩ ; exact ⟨ m, hm₁, u, hu₁, hm₂, hu₂.trans_lt hx.2 ⟩ ;
    contrapose! h_exists_bounded_cycle_mean_le;
    -- Let's choose any $\epsilon > 0$.
    obtain ⟨ε, hε⟩ : ∃ ε > 0, ∀ k : ℕ, ∀ hk : 0 < k, ∀ u : Fin (k + 1) → Fin n, IsClosedWalk u → k ≤ n → ε ≤ cycleMean W hk u - tropicalEigenvalue W := by
      have h_finite : Set.Finite {x : ℝ | ∃ k : ℕ, ∃ hk : 0 < k, ∃ u : Fin (k + 1) → Fin n, IsClosedWalk u ∧ k ≤ n ∧ x = cycleMean W hk u - tropicalEigenvalue W} := by
        have h_finite : Set.Finite {x : ℝ | ∃ k : ℕ, ∃ hk : 0 < k, ∃ u : Fin (k + 1) → Fin n, k ≤ n ∧ x = cycleMean W hk u - tropicalEigenvalue W} := by
          refine Set.Finite.subset ( Set.toFinite ( Finset.biUnion ( Finset.Icc 1 n ) fun k => Finset.image ( fun u : Fin ( k + 1 ) → Fin n => cycleCost W u / ( k : ℝ ) - tropicalEigenvalue W ) ( Finset.univ ) ) ) ?_;
          exact fun x hx => by rcases hx with ⟨ k, hk, u, hk', rfl ⟩ ; exact Finset.mem_coe.mpr ( Finset.mem_biUnion.mpr ⟨ k, Finset.mem_Icc.mpr ⟨ hk, hk' ⟩, Finset.mem_image.mpr ⟨ u, Finset.mem_univ _, rfl ⟩ ⟩ ) ;
        exact h_finite.subset fun x hx => by obtain ⟨ k, hk, u, hu, hk', rfl ⟩ := hx; exact ⟨ k, hk, u, hk', rfl ⟩ ;
      obtain ⟨ε, hε⟩ : ∃ ε ∈ {x : ℝ | ∃ k : ℕ, ∃ hk : 0 < k, ∃ u : Fin (k + 1) → Fin n, IsClosedWalk u ∧ k ≤ n ∧ x = cycleMean W hk u - tropicalEigenvalue W}, ∀ x ∈ {x : ℝ | ∃ k : ℕ, ∃ hk : 0 < k, ∃ u : Fin (k + 1) → Fin n, IsClosedWalk u ∧ k ≤ n ∧ x = cycleMean W hk u - tropicalEigenvalue W}, ε ≤ x := by
        apply_rules [ Set.exists_min_image ];
        exact ⟨ _, ⟨ 1, by norm_num, fun _ => ⟨ 0, hn ⟩, by unfold IsClosedWalk; norm_num, by linarith, rfl ⟩ ⟩;
      exact ⟨ ε, by obtain ⟨ k, hk, u, hu, hk', rfl ⟩ := hε.1; linarith [ h_exists_bounded_cycle_mean_le k hk u hu hk' ], fun k hk u hu hk' => hε.2 _ ⟨ k, hk, u, hu, hk', rfl ⟩ ⟩;
    exact ⟨ ε, hε.1, fun k hk u hu hk' => by linarith [ hε.2 k hk u hu hk' ] ⟩;
  obtain ⟨ k, hk, u, hu, hk', h ⟩ := h_exists_bounded_cycle_mean_le;
  exact ⟨ k, hk, hk', u, hu, le_antisymm ( tropicalEigenvalue_le_cycleMean W hk u hu ) h ⟩

end