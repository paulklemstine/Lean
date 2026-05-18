/-
# Tropical Perron–Frobenius Theorem

This file formalizes the tropical (max-plus) spectral theorem for finite real matrices:
the normalized tropical matrix powers converge entrywise to a common limit,
which is the maximum cycle mean.

## Main Results

* `tropMul` — tropical (max-plus) matrix multiplication
* `tropPow` — iterated tropical matrix power
* `maxCycleMean` — the maximum average weight of a short closed walk
* `tropMul_assoc` — associativity of tropical multiplication
* `tropPow_add` — `tropPow W (m + k + 1) = tropMul (tropPow W m) (tropPow W k)`
* `tropPow_diag_superadd` — superadditivity of diagonal entries
* `tropical_perron_frobenius` — asymptotic convergence of normalized tropical powers

## Conventions

Since we work over `ℝ` (not `ℝ ∪ {-∞}`), every matrix entry is finite, so the
underlying directed graph is the complete graph on `Fin (n+1)` vertices. This makes
strong connectivity automatic and avoids the need for an irreducibility hypothesis.

`tropPow W m` is the `(m+1)`-fold tropical power, so `tropPow W m i j` represents
the maximum weight among all walks of `(m + 1)` edges from `i` to `j`.
-/

import Mathlib

noncomputable section

open Finset Matrix Filter Topology

variable {n : ℕ}

/-! ## Tropical Matrix Multiplication -/

/-- Tropical (max-plus) matrix multiplication: `(A ⊗ B)ᵢⱼ = maxₖ (Aᵢₖ + Bₖⱼ)`. -/
def tropMul (A B : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) :
    Matrix (Fin (n+1)) (Fin (n+1)) ℝ :=
  fun i j => Finset.univ.sup' Finset.univ_nonempty (fun k => A i k + B k j)

/-- Each summand is at most the tropical product entry. -/
theorem le_tropMul (A B : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (i j k : Fin (n+1)) :
    A i k + B k j ≤ tropMul A B i j := by
  unfold tropMul
  exact Finset.le_sup' (fun k => A i k + B k j) (Finset.mem_univ k)

/-- The tropical product is bounded by a uniform bound on summands. -/
theorem tropMul_le (A B : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (i j : Fin (n+1)) (x : ℝ) (hx : ∀ k, A i k + B k j ≤ x) :
    tropMul A B i j ≤ x := by
  unfold tropMul
  exact Finset.sup'_le Finset.univ_nonempty _ (fun k _ => hx k)

/-
Associativity of tropical matrix multiplication.
-/
theorem tropMul_assoc (A B C : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) :
    tropMul (tropMul A B) C = tropMul A (tropMul B C) := by
  ext i j;
  refine' le_antisymm _ _;
  · nontriviality;
    unfold tropMul;
    grind +suggestions;
  · -- For each $k$, we have $\sup_l (A i l + \sup_k' (B l k' + C k' j)) \leq \sup_k' (\sup_l (A i l + B l k') + C k' j)$.
    have h_le : ∀ k, A i k + Finset.univ.sup' Finset.univ_nonempty (fun k' => B k k' + C k' j) ≤ Finset.univ.sup' Finset.univ_nonempty (fun k' => Finset.univ.sup' Finset.univ_nonempty (fun l => A i l + B l k') + C k' j) := by
      grind +suggestions;
    exact Finset.sup'_le _ _ fun k _ => h_le k

/-! ## Tropical Matrix Power -/

/-- Tropical matrix power: `tropPow W m` is the `(m+1)`-fold tropical power. -/
def tropPow (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) :
    ℕ → Matrix (Fin (n+1)) (Fin (n+1)) ℝ
  | 0 => W
  | (m+1) => tropMul (tropPow W m) W

@[simp]
theorem tropPow_zero (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) :
    tropPow W 0 = W := rfl

@[simp]
theorem tropPow_succ (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) (m : ℕ) :
    tropPow W (m + 1) = tropMul (tropPow W m) W := rfl

/-
Tropical powers decompose under addition of indices.
-/
theorem tropPow_add (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) (m k : ℕ) :
    tropPow W (m + k + 1) = tropMul (tropPow W m) (tropPow W k) := by
  induction' k with k ih generalizing m;
  · rfl;
  · grind +suggestions

/-- Any intermediate vertex gives a lower bound. -/
theorem tropPow_add_le (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) (m k : ℕ)
    (i j l : Fin (n+1)) :
    tropPow W m i l + tropPow W k l j ≤ tropPow W (m + k + 1) i j := by
  rw [tropPow_add]; exact le_tropMul _ _ i j l

/-- Superadditivity of diagonal entries. -/
theorem tropPow_diag_superadd (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (m k : ℕ) (i : Fin (n+1)) :
    tropPow W m i i + tropPow W k i i ≤ tropPow W (m + k + 1) i i :=
  tropPow_add_le W m k i i i

/-! ## Maximum Cycle Mean -/

/-- The maximum cycle mean of `W`. -/
def maxCycleMean (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) : ℝ :=
  (Finset.univ.product Finset.univ).sup'
    ⟨(0, 0), Finset.mem_product.mpr ⟨Finset.mem_univ _, Finset.mem_univ _⟩⟩
    (fun p : Fin (n+1) × Fin (n+1) =>
      tropPow W p.2.val p.1 p.1 / ((p.2.val : ℝ) + 1))

/-- The maximum cycle mean bounds any short closed walk average. -/
theorem maxCycleMean_ge_diag_avg (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (i : Fin (n+1)) (m : Fin (n+1)) :
    tropPow W m.val i i / ((m.val : ℝ) + 1) ≤ maxCycleMean W := by
  exact Finset.le_sup' (fun x : Fin (n+1) × Fin (n+1) =>
    tropPow W (x.2 : ℕ) x.1 x.1 / ((x.2 : ℝ) + 1))
    (Finset.mk_mem_product (Finset.mem_univ i) (Finset.mem_univ m))

/-! ## Bounds -/

/-- The maximum absolute value of any entry. -/
def maxEntry (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) : ℝ :=
  (Finset.univ.product Finset.univ).sup'
    ⟨(0, 0), Finset.mem_product.mpr ⟨Finset.mem_univ _, Finset.mem_univ _⟩⟩
    (fun p : Fin (n+1) × Fin (n+1) => |W p.1 p.2|)

theorem abs_entry_le_maxEntry (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (i j : Fin (n+1)) : |W i j| ≤ maxEntry W := by
  exact Finset.le_sup' (fun p : Fin (n+1) × Fin (n+1) => |W p.1 p.2|)
    (Finset.mk_mem_product (Finset.mem_univ i) (Finset.mem_univ j))

theorem entry_le_maxEntry (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (i j : Fin (n+1)) : W i j ≤ maxEntry W :=
  le_trans (le_abs_self _) (abs_entry_le_maxEntry W i j)


theorem neg_maxEntry_le_entry (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (i j : Fin (n+1)) : -maxEntry W ≤ W i j := by
  linarith [abs_entry_le_maxEntry W i j, neg_abs_le (W i j)]

theorem maxEntry_nonneg (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) :
    0 ≤ maxEntry W :=
  le_trans (abs_nonneg _) (abs_entry_le_maxEntry W 0 0)

/-
Tropical power entries grow at most linearly.
-/
theorem tropPow_le_linear (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (m : ℕ) (i j : Fin (n+1)) :
    tropPow W m i j ≤ ((m : ℝ) + 1) * maxEntry W := by
  induction' m with m ih generalizing i j <;> simp_all +decide [ tropPow ];
  · exact entry_le_maxEntry W i j
  · exact tropMul_le _ _ _ _ _ fun k => by linarith [ih i k, entry_le_maxEntry W k j]

/-
Tropical power entries decrease at most linearly.
-/
theorem neg_linear_le_tropPow (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (m : ℕ) (i j : Fin (n+1)) :
    -(((m : ℝ) + 1) * maxEntry W) ≤ tropPow W m i j := by
  induction' m with m ih generalizing i j <;> norm_num at *;
  · exact neg_maxEntry_le_entry W i j
  · exact le_trans (by linarith [ih i j, neg_maxEntry_le_entry W j j]) (le_tropMul _ _ _ _ _)

/-! ## Subadditive Convergence for Diagonal Entries -/

/-- The negated diagonal sequence, shifted to start at 0. -/
def negDiagSeq (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) (i : Fin (n+1)) : ℕ → ℝ
  | 0 => 0
  | (m+1) => -tropPow W m i i

/-
The negated diagonal sequence is subadditive.
-/
theorem negDiagSeq_subadditive (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (i : Fin (n+1)) : Subadditive (negDiagSeq W i) := by
  intro m n; induction' m with m ih generalizing n <;> induction' n with n ih <;> simp +decide [ *, Nat.succ_add ] ;
  · exact le_rfl;
  · grind +revert;
  · exact le_rfl;
  · simp_all +decide [ ← add_assoc, negDiagSeq ];
    convert tropPow_diag_superadd W m n i using 1 ; ring!;

/-
The ratio `negDiagSeq / n` is bounded below.
-/
theorem negDiagSeq_bddBelow (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) (i : Fin (n+1)) :
    BddBelow (Set.range fun m => negDiagSeq W i m / (m : ℝ)) := by
  refine' ⟨ -maxEntry W, Set.forall_mem_range.2 fun m => _ ⟩;
  rcases m with ( _ | m ) <;> norm_num [ negDiagSeq ];
  · exact maxEntry_nonneg W
  · rw [le_div_iff₀] <;> nlinarith [neg_linear_le_tropPow W m i i, tropPow_le_linear W m i i]

/-- The diagonal tropical power growth rate. -/
def tropGrowthRate (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) (i : Fin (n+1)) : ℝ :=
  -(negDiagSeq_subadditive W i).lim

/-
Diagonal convergence: `tropPow W m i i / (m+1) → tropGrowthRate W i`.
-/
theorem tropPow_diag_div_tendsto (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (i : Fin (n+1)) :
    Tendsto (fun m => tropPow W m i i / ((m : ℝ) + 1))
      atTop (𝓝 (tropGrowthRate W i)) := by
  convert Tendsto.neg ( Subadditive.tendsto_lim ( negDiagSeq_subadditive W i ) ( negDiagSeq_bddBelow W i ) |> Filter.Tendsto.comp <| Filter.tendsto_add_atTop_nat 1 ) using 2;
  simp +decide [ negDiagSeq ];
  ring

/-! ## Common Growth Rate -/

/-
The growth rate is the same for all vertices.
-/
theorem tropGrowthRate_eq (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (i j : Fin (n+1)) : tropGrowthRate W i = tropGrowthRate W j := by
  have h_lim : Filter.Tendsto (fun m => tropPow W (m + 2) i i / (m + 3)) Filter.atTop (nhds (tropGrowthRate W i)) := by
    convert tropPow_diag_div_tendsto W i |> Filter.Tendsto.comp <| Filter.tendsto_add_atTop_nat 2 using 2 ; norm_num ; ring;
  have h_lim_j : Filter.Tendsto (fun m => tropPow W m j j / (m + 1)) Filter.atTop (nhds (tropGrowthRate W j)) := by
    convert tropPow_diag_div_tendsto W j using 1
  have h_lim_j' : Filter.Tendsto (fun m => (tropPow W m j j + W i j + W j i) / (m + 3)) Filter.atTop (nhds (tropGrowthRate W j)) := by
    have h_lim_j' : Filter.Tendsto (fun m => (tropPow W m j j / (m + 1)) * ((m + 1) / (m + 3)) + (W i j + W j i) / (m + 3)) Filter.atTop (nhds (tropGrowthRate W j)) := by
      convert Filter.Tendsto.add ( h_lim_j.mul ( show Filter.Tendsto ( fun m : ℕ => ( m + 1 : ℝ ) / ( m + 3 ) ) Filter.atTop ( nhds 1 ) from ?_ ) ) ( tendsto_const_nhds.div_atTop <| show Filter.Tendsto ( fun m : ℕ => ( m + 3 : ℝ ) ) Filter.atTop Filter.atTop from Filter.tendsto_atTop_add_const_right _ _ tendsto_natCast_atTop_atTop ) using 2 <;> norm_num;
      exact ( Metric.tendsto_atTop.mpr fun ε hε => ⟨ Nat.ceil ( ε⁻¹ * 3 ), fun m hm => abs_lt.mpr ⟨ by nlinarith [ Nat.ceil_le.mp hm, inv_mul_cancel₀ ( ne_of_gt hε ), div_mul_cancel₀ ( ( m : ℝ ) + 1 ) ( by linarith : ( m : ℝ ) + 3 ≠ 0 ) ], by nlinarith [ Nat.ceil_le.mp hm, inv_mul_cancel₀ ( ne_of_gt hε ), div_mul_cancel₀ ( ( m : ℝ ) + 1 ) ( by linarith : ( m : ℝ ) + 3 ≠ 0 ) ] ⟩ ⟩ );
    exact h_lim_j'.congr fun m => by rw [ div_mul_div_cancel₀ ( by positivity ) ] ; ring;
  have h_lim_ge : tropGrowthRate W i ≥ tropGrowthRate W j := by
    have h_lim_ge : ∀ m : ℕ, tropPow W (m + 2) i i ≥ tropPow W m j j + W i j + W j i := by
      intros m
      have h_tropPow_add_le : tropPow W (m + 2) i i ≥ tropPow W (m + 1) i j + tropPow W 0 j i := by
        convert tropPow_add_le W ( m + 1 ) 0 i i j using 1
      have h_tropPow_add_le' : tropPow W (m + 1) i j ≥ tropPow W m j j + tropPow W 0 i j := by
        have h_tropPow_add_le' : tropPow W (m + 1) i j ≥ tropPow W 0 i j + tropPow W m j j := by
          have := tropPow_add_le W 0 m i j j
          aesop;
        linarith
      have h_tropPow_add_le'' : tropPow W 0 i j = W i j := by
        rfl
      have h_tropPow_add_le''' : tropPow W 0 j i = W j i := by
        rfl
      linarith [h_tropPow_add_le, h_tropPow_add_le', h_tropPow_add_le'', h_tropPow_add_le'''];
    exact le_of_tendsto_of_tendsto' h_lim_j' h_lim fun m => by rw [ div_le_div_iff_of_pos_right ( by positivity ) ] ; linarith [ h_lim_ge m ] ;
  have h_lim_le : tropGrowthRate W j ≥ tropGrowthRate W i := by
    have h_lim_ge' : Filter.Tendsto (fun m => tropPow W (m + 2) j j / (m + 3)) Filter.atTop (nhds (tropGrowthRate W j)) := by
      convert h_lim_j.comp ( Filter.tendsto_add_atTop_nat 2 ) using 2 ; norm_num ; ring
    have h_lim_j'' : Filter.Tendsto (fun m => (tropPow W m i i + W j i + W i j) / (m + 3)) Filter.atTop (nhds (tropGrowthRate W i)) := by
      have h_lim_j'' : Filter.Tendsto (fun m => tropPow W m i i / (m + 3)) Filter.atTop (nhds (tropGrowthRate W i)) := by
        have h_lim_j'' : Filter.Tendsto (fun m => tropPow W m i i / (m + 1)) Filter.atTop (nhds (tropGrowthRate W i)) := by
          convert tropPow_diag_div_tendsto W i using 1;
        have h_lim_j'' : Filter.Tendsto (fun m => (tropPow W m i i / (m + 1)) * ((m + 1) / (m + 3))) Filter.atTop (nhds (tropGrowthRate W i)) := by
          convert h_lim_j''.mul ( show Filter.Tendsto ( fun m : ℕ => ( m + 1 : ℝ ) / ( m + 3 ) ) Filter.atTop ( nhds 1 ) from ?_ ) using 2 <;> norm_num [ add_assoc ];
          exact ( Metric.tendsto_atTop.mpr fun ε hε => ⟨ Nat.ceil ( ε⁻¹ * 3 ), fun m hm => abs_lt.mpr ⟨ by nlinarith [ Nat.ceil_le.mp hm, inv_mul_cancel₀ ( ne_of_gt hε ), div_mul_cancel₀ ( ( m : ℝ ) + 1 ) ( by linarith : ( m : ℝ ) + 3 ≠ 0 ) ], by nlinarith [ Nat.ceil_le.mp hm, inv_mul_cancel₀ ( ne_of_gt hε ), div_mul_cancel₀ ( ( m : ℝ ) + 1 ) ( by linarith : ( m : ℝ ) + 3 ≠ 0 ) ] ⟩ ⟩ );
        exact h_lim_j''.congr fun m => by rw [ div_mul_div_cancel₀ ] ; positivity;
      convert h_lim_j''.add ( show Filter.Tendsto ( fun m : ℕ => ( W j i + W i j ) / ( m + 3 : ℝ ) ) Filter.atTop ( nhds 0 ) from tendsto_const_nhds.div_atTop <| Filter.tendsto_atTop_add_const_right _ _ tendsto_natCast_atTop_atTop ) using 2 <;> ring
    have h_lim_ge'' : tropGrowthRate W j ≥ tropGrowthRate W i := by
      refine' le_of_tendsto_of_tendsto' h_lim_j'' h_lim_ge' fun m => _;
      have := tropPow_add_le W 0 m j i i; have := tropPow_add_le W ( m + 1 ) 0 j j i; norm_num at * ; rw [ div_le_div_iff_of_pos_right ] <;> linarith;
    exact h_lim_ge''
  exact le_antisymm h_lim_le h_lim_ge

/-- The common tropical growth rate. -/
def tropRate (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) : ℝ :=
  tropGrowthRate W 0

theorem tropGrowthRate_eq_tropRate (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (i : Fin (n+1)) : tropGrowthRate W i = tropRate W :=
  tropGrowthRate_eq W i 0

/-! ## Off-Diagonal Convergence -/

/-
Lower bound: off-diagonal ≥ diagonal shifted by two edge weights.
-/
theorem tropPow_offdiag_lower (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (m : ℕ) (i j : Fin (n+1)) :
    W i j + tropPow W m j j ≤ tropPow W (m + 1) i j := by
  -- Apply the tropPow_add_le lemma with k = m to get the inequality.
  have := tropPow_add_le W 0 m i j j;
  aesop

/-
Upper bound: off-diagonal ≤ next diagonal minus one edge.
-/
theorem tropPow_offdiag_upper (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (m : ℕ) (i j : Fin (n+1)) :
    tropPow W m i j ≤ tropPow W (m + 1) j j - W j i := by
  convert sub_le_sub_right ( tropPow_add_le W 0 m j j i ) ( W j i ) using 1 ; norm_num;
  norm_num [ add_assoc ]

/-
Off-diagonal convergence.
-/
theorem tropPow_offdiag_div_tendsto (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ)
    (i j : Fin (n+1)) :
    Tendsto (fun m => tropPow W m i j / ((m : ℝ) + 1))
      atTop (𝓝 (tropRate W)) := by
  -- We'll use the fact that if the denominator grows faster than the numerator, then the limit of the quotient is zero.
  suffices h_lim : Filter.Tendsto (fun m : ℕ => (tropPow W (m + 1) i j) / (m + 2)) Filter.atTop (nhds (tropRate W)) by
    rw [ ← Filter.tendsto_add_atTop_iff_nat 1 ] ; norm_cast at *;
  -- Apply the lower bound inequality to get the lower bound for the limit.
  have h_lower_bound : ∀ m : ℕ, (W i j + tropPow W m j j) / (m + 2 : ℝ) ≤ (tropPow W (m + 1) i j) / (m + 2 : ℝ) := by
    exact fun m => by gcongr; linarith [ tropPow_offdiag_lower W m i j ] ;
  -- Apply the upper bound inequality to get the upper bound for the limit.
  have h_upper_bound : ∀ m : ℕ, (tropPow W (m + 1) i j) / (m + 2 : ℝ) ≤ (tropPow W (m + 2) j j - W j i) / (m + 2 : ℝ) := by
    intros m
    have h_upper_bound : tropPow W (m + 1) i j ≤ tropPow W (m + 2) j j - W j i := by
      apply tropPow_offdiag_upper;
    gcongr;
  -- Apply the squeeze theorem to conclude the proof.
  have h_squeeze : Filter.Tendsto (fun m : ℕ => (W i j + tropPow W m j j) / (m + 2 : ℝ)) Filter.atTop (nhds (tropRate W)) ∧ Filter.Tendsto (fun m : ℕ => (tropPow W (m + 2) j j - W j i) / (m + 2 : ℝ)) Filter.atTop (nhds (tropRate W)) := by
    constructor;
    · have h_limit_lower : Filter.Tendsto (fun m : ℕ => (tropPow W m j j) / (m + 1 : ℝ)) Filter.atTop (nhds (tropRate W)) := by
        convert tropPow_diag_div_tendsto W j using 1;
        exact congr_arg _ ( tropGrowthRate_eq_tropRate W j ▸ rfl );
      have h_limit_lower : Filter.Tendsto (fun m : ℕ => (tropPow W m j j) / (m + 2 : ℝ)) Filter.atTop (nhds (tropRate W)) := by
        have h_limit_lower : Filter.Tendsto (fun m : ℕ => ((m + 1 : ℝ) / (m + 2 : ℝ)) * ((tropPow W m j j) / (m + 1 : ℝ))) Filter.atTop (nhds (tropRate W)) := by
          have h_limit_lower : Filter.Tendsto (fun m : ℕ => ((m + 1 : ℝ) / (m + 2 : ℝ))) Filter.atTop (nhds 1) := by
            exact ( Metric.tendsto_atTop.mpr fun ε hε => ⟨ Nat.ceil ( ε⁻¹ * 2 ), fun m hm => abs_lt.mpr ⟨ by nlinarith [ Nat.ceil_le.mp hm, inv_mul_cancel₀ ( ne_of_gt hε ), div_mul_cancel₀ ( ( m : ℝ ) + 1 ) ( by linarith : ( m : ℝ ) + 2 ≠ 0 ) ], by nlinarith [ Nat.ceil_le.mp hm, inv_mul_cancel₀ ( ne_of_gt hε ), div_mul_cancel₀ ( ( m : ℝ ) + 1 ) ( by linarith : ( m : ℝ ) + 2 ≠ 0 ) ] ⟩ ⟩ );
          simpa using h_limit_lower.mul ‹Tendsto ( fun m : ℕ => tropPow W m j j / ( m + 1 : ℝ ) ) atTop ( 𝓝 ( tropRate W ) ) ›;
        exact h_limit_lower.congr fun m => by rw [ div_mul_div_comm, div_eq_div_iff ] <;> ring <;> positivity;
      simpa [ add_div ] using Filter.Tendsto.add ( tendsto_const_nhds.mul ( tendsto_inv_atTop_zero.comp ( show Filter.Tendsto ( fun m : ℕ => ( m : ℝ ) + 2 ) Filter.atTop ( Filter.atTop ) from Filter.tendsto_atTop_add_const_right _ _ tendsto_natCast_atTop_atTop ) ) ) h_limit_lower;
    · have h_squeeze : Filter.Tendsto (fun m : ℕ => (tropPow W (m + 2) j j) / (m + 2 : ℝ)) Filter.atTop (nhds (tropRate W)) := by
        have h_squeeze : Filter.Tendsto (fun m : ℕ => (tropPow W m j j) / (m + 1 : ℝ)) Filter.atTop (nhds (tropRate W)) := by
          convert tropPow_diag_div_tendsto W j using 1;
          exact congr_arg _ ( tropGrowthRate_eq_tropRate W j ▸ rfl );
        have h_squeeze : Filter.Tendsto (fun m : ℕ => (tropPow W (m + 2) j j) / (m + 3 : ℝ)) Filter.atTop (nhds (tropRate W)) := by
          convert h_squeeze.comp ( Filter.tendsto_add_atTop_nat 2 ) using 2 ; norm_num ; ring;
        convert h_squeeze.mul ( show Filter.Tendsto ( fun m : ℕ => ( m + 3 : ℝ ) / ( m + 2 ) ) Filter.atTop ( 𝓝 1 ) from ?_ ) using 2 <;> norm_num;
        · rw [ div_mul_div_cancel₀ ( by positivity ) ];
        · rw [ Metric.tendsto_nhds ] ; norm_num;
          exact fun ε hε => ⟨ Nat.ceil ( ε⁻¹ * 3 ), fun m hm => abs_lt.mpr ⟨ by nlinarith [ Nat.ceil_le.mp hm, inv_mul_cancel₀ hε.ne', div_mul_cancel₀ ( ( m : ℝ ) + 3 ) ( by linarith : ( m : ℝ ) + 2 ≠ 0 ) ], by nlinarith [ Nat.ceil_le.mp hm, inv_mul_cancel₀ hε.ne', div_mul_cancel₀ ( ( m : ℝ ) + 3 ) ( by linarith : ( m : ℝ ) + 2 ≠ 0 ) ] ⟩ ⟩;
      simpa [ sub_div ] using h_squeeze.sub ( tendsto_const_nhds.mul tendsto_inv_atTop_nhds_zero_nat |> Filter.Tendsto.comp <| Filter.tendsto_add_atTop_nat 2 );
  exact tendsto_of_tendsto_of_tendsto_of_le_of_le h_squeeze.1 h_squeeze.2 ( fun m => h_lower_bound m ) ( fun m => h_upper_bound m )

/-! ## Main Theorem -/

/-
**Tropical Perron–Frobenius (Asymptotic Form).**
    The normalized tropical power `tropPow W m i j / (m + 1)` converges to
    `tropRate W` as `m → ∞`, uniformly in `i` and `j`.
-/
theorem tropical_perron_frobenius
    (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) :
    ∀ ε > 0, ∃ N : ℕ, ∀ m ≥ N, ∀ i j : Fin (n+1),
      |tropPow W m i j / ((m : ℝ) + 1) - tropRate W| < ε := by
  intro ε hε;
  -- By the definition of limit, for each (i, j), there exists N_{i,j} such that for all m ≥ N_{i,j}, |tropPow W m i j / (m + 1) - tropRate W| < ε.
  have hN : ∀ i j : Fin (n + 1), ∃ N : ℕ, ∀ m ≥ N, |tropPow W m i j / (m + 1 : ℝ) - tropRate W| < ε := by
    exact fun i j => Metric.tendsto_atTop.mp ( tropPow_offdiag_div_tendsto W i j ) ε hε;
  choose! N hN using hN;
  exact ⟨ Finset.univ.sup fun i => Finset.univ.sup fun j => N i j, fun m hm i j => hN i j m <| le_trans ( Finset.le_sup ( f := fun j => N i j ) <| Finset.mem_univ j ) <| le_trans ( Finset.le_sup ( f := fun i => Finset.univ.sup fun j => N i j ) <| Finset.mem_univ i ) hm ⟩

/-
The tropical rate is at least the maximum cycle mean.
-/
theorem maxCycleMean_le_tropRate (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ) :
    maxCycleMean W ≤ tropRate W := by
  -- By definition of `tropRate`, we know that for any `i` and `j`, `tropPow W m i j / ((m : ℝ) + 1)` converges to `tropRate W`.
  have h_diag_conv : ∀ i : Fin (n + 1), Filter.Tendsto (fun m => tropPow W m i i / ((m : ℝ) + 1)) Filter.atTop (nhds (tropRate W)) := by
    intro i;
    convert tropPow_diag_div_tendsto W i using 1;
    rw [ tropGrowthRate_eq_tropRate ];
  -- Since the diagonal entries converge to `tropRate W`, the maximum of these entries also converges to `tropRate W`.
  have h_max_diag_conv : ∀ i : Fin (n + 1), ∀ m : Fin (n + 1), tropPow W m.val i i / ((m.val : ℝ) + 1) ≤ tropRate W := by
    intro i m;
    -- By definition of `tropRate`, we know that for any `i` and `m`, `tropPow W (m + k) i i / ((m + k + 1 : ℝ))` is bounded below by `tropPow W m i i / ((m + 1 : ℝ))`.
    have h_diag_bound : ∀ k : ℕ, tropPow W (m.val + k * (m.val + 1)) i i / ((m.val + k * (m.val + 1) + 1 : ℝ)) ≥ tropPow W m.val i i / ((m.val + 1 : ℝ)) := by
      intro k
      have h_diag_bound_step : ∀ k : ℕ, tropPow W (m.val + (k + 1) * (m.val + 1)) i i ≥ tropPow W (m.val + k * (m.val + 1)) i i + tropPow W m.val i i := by
        intro k
        have h_diag_bound_step : tropPow W (m.val + (k + 1) * (m.val + 1)) i i ≥ tropPow W (m.val + k * (m.val + 1)) i i + tropPow W m.val i i := by
          have h_diag_bound_step : tropPow W (m.val + k * (m.val + 1) + m.val + 1) i i ≥ tropPow W (m.val + k * (m.val + 1)) i i + tropPow W m.val i i := by
            convert tropPow_diag_superadd W ( m.val + k * ( m.val + 1 ) ) m.val i using 1
          convert h_diag_bound_step using 2 ; ring;
        exact h_diag_bound_step;
      rw [ ge_iff_le, div_le_div_iff₀ ] <;> try positivity;
      induction' k with k ih <;> norm_num at *;
      nlinarith [ h_diag_bound_step k, show ( m : ℝ ) ≥ 0 by positivity ];
    exact le_of_tendsto_of_tendsto tendsto_const_nhds ( h_diag_conv i |> Filter.Tendsto.comp <| Filter.tendsto_atTop_mono ( fun k => by nlinarith ) tendsto_natCast_atTop_atTop ) ( Filter.Eventually.of_forall fun k => mod_cast h_diag_bound k );
  exact Finset.sup'_le _ _ fun x hx => h_max_diag_conv _ _

end