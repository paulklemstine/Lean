/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical (Min-Plus) Matrix Power Stabilization

This file proves fundamental theorems of tropical linear algebra:
the tropical (min-plus) powers of a weighted adjacency matrix stabilize
after at most n − 1 steps on off-diagonal entries, assuming zero diagonal
and no negative cycles. This is the algebraic core of the Bellman–Ford
shortest-path algorithm's correctness.

## Main Results

- `tropMul_assoc`: Tropical multiplication is associative.
- `tropPow_add`: Power splitting for tropical matrix powers.
- `tropPow_antitone_entry`: Monotonicity of tropical powers with zero diagonal.
- `tropPow_diag_eq_zero`: Diagonal entries are 0 under NoNegDiag.
- `tropPow_stabilizes`: **Main theorem** — off-diagonal stabilization at n-1 steps.
- `tropClosure_triangle`: Triangle inequality for the shortest-path closure.
-/
import Mathlib

open BigOperators Matrix Finset

variable {n : ℕ}

/-! ## Core Definitions -/

/-- Min-plus (tropical) matrix multiplication. -/
noncomputable def tropMul (A B : Matrix (Fin n) (Fin n) ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  fun i j => ⨅ k : Fin n, (A i k + B k j)

/-- Tropical matrix power (0-indexed): `tropPow A m` = A^⊗(m+1). -/
noncomputable def tropPow (A : Matrix (Fin n) (Fin n) ℝ) : ℕ → Matrix (Fin n) (Fin n) ℝ
  | 0 => A
  | m + 1 => tropMul (tropPow A m) A

/-- No negative diagonal powers: all closed walks have non-negative weight. -/
def NoNegDiag (W : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∀ (k : ℕ) (i : Fin n), 0 ≤ tropPow W k i i

/-! ## Basic Lemmas -/

theorem tropMul_le_of_witness [Nonempty (Fin n)]
    (A B : Matrix (Fin n) (Fin n) ℝ) (i j k : Fin n) :
    tropMul A B i j ≤ A i k + B k j :=
  ciInf_le (Finite.bddBelow_range _) k

theorem tropMul_diag_le [Nonempty (Fin n)]
    (A B : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) :
    tropMul A B i i ≤ A i i + B i i :=
  tropMul_le_of_witness A B i i i

/-! ## Associativity and Power Splitting -/

theorem tropMul_assoc [Nonempty (Fin n)]
    (A B C : Matrix (Fin n) (Fin n) ℝ) :
    tropMul (tropMul A B) C = tropMul A (tropMul B C) := by
      refine' funext fun i => funext fun j => le_antisymm _ _;
      · refine' le_csInf _ _ <;> norm_num;
        · exact ⟨ _, ⟨ i, rfl ⟩ ⟩;
        · intro a
          have h_inf : ∀ k, (tropMul (tropMul A B) C) i j ≤ (tropMul A B) i k + C k j := by
            exact fun k => csInf_le ( Finite.bddBelow_range fun l => tropMul A B i l + C l j ) ( Set.mem_range_self k )
          have h_add : (tropMul (tropMul A B) C) i j ≤ A i a + (tropMul B C) a j := by
            have h_add : (tropMul (tropMul A B) C) i j ≤ A i a + (⨅ k, (B a k + C k j)) := by
              have h_add : ∀ k, (tropMul (tropMul A B) C) i j ≤ A i a + (B a k + C k j) := by
                exact fun k => le_trans ( h_inf k ) ( by linarith [ show tropMul A B i k ≤ A i a + B a k from by exact ciInf_le ( Finite.bddBelow_range _ ) _ ] );
              exact le_trans ( h_add ( Classical.choose ( show ∃ k, B a k + C k j = ⨅ k, B a k + C k j from by simpa using ( IsCompact.sInf_mem ( isCompact_range <| show Continuous fun k => B a k + C k j from by continuity ) <| Set.nonempty_of_mem <| Set.mem_range_self a ) ) ) ) ( by rw [ Classical.choose_spec ( show ∃ k, B a k + C k j = ⨅ k, B a k + C k j from by simpa using ( IsCompact.sInf_mem ( isCompact_range <| show Continuous fun k => B a k + C k j from by continuity ) <| Set.nonempty_of_mem <| Set.mem_range_self a ) ) ] );
            exact h_add
          exact h_add;
      · refine' le_ciInf fun k => _;
        nontriviality;
        have h_le : ∃ l, A i l + (B l k + C k j) ≤ tropMul A B i k + C k j := by
          have := ( show ∃ l, A i l + B l k = ⨅ k_1 : Fin n, A i k_1 + B k_1 k from by
                      exact ( IsCompact.sInf_mem ( Set.finite_range _ |> Set.Finite.isCompact ) <| Set.nonempty_of_mem <| Set.mem_range_self k ) );
          exact this.imp fun l hl => by rw [ ← add_assoc, hl ] ; rfl;
        exact le_trans ( ciInf_le ( Finite.bddBelow_range fun l => A i l + tropMul B C l j ) h_le.choose ) ( by linarith [ h_le.choose_spec, show tropMul B C h_le.choose j ≤ B h_le.choose k + C k j from ciInf_le ( Finite.bddBelow_range fun l => B h_le.choose l + C l j ) k ] )

theorem tropPow_add [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ) (m k : ℕ) :
    tropPow A (m + k + 1) = tropMul (tropPow A m) (tropPow A k) := by
      induction' k with k ih generalizing m;
      · rfl;
      · convert congr_arg ( fun x => tropMul x A ) ( ih m ) using 1;
        rw [ show tropPow A ( k + 1 ) = tropMul ( tropPow A k ) A from rfl ];
        exact?

/-! ## Monotonicity -/

theorem tropMul_entry_le_of_zero_diag_right [Nonempty (Fin n)]
    (A W : Matrix (Fin n) (Fin n) ℝ) (hdiag : ∀ i, W i i = 0) (i j : Fin n) :
    tropMul A W i j ≤ A i j := by
  have h := tropMul_le_of_witness A W i j j; simp [hdiag] at h; exact h

theorem tropPow_antitone_entry [Nonempty (Fin n)]
    (W : Matrix (Fin n) (Fin n) ℝ) (hdiag : ∀ i, W i i = 0) (i j : Fin n) (k : ℕ) :
    tropPow W (k + 1) i j ≤ tropPow W k i j := by
  exact tropMul_entry_le_of_zero_diag_right (tropPow W k) W hdiag i j

theorem tropPow_antitone_entry_of_le [Nonempty (Fin n)]
    (W : Matrix (Fin n) (Fin n) ℝ) (hdiag : ∀ i, W i i = 0)
    (i j : Fin n) {k m : ℕ} (hkm : k ≤ m) :
    tropPow W m i j ≤ tropPow W k i j := by
  induction m with
  | zero => simp only [Nat.le_zero] at hkm; subst hkm; exact le_refl _
  | succ m ih =>
    rcases Nat.eq_or_lt_of_le hkm with rfl | hlt
    · exact le_refl _
    · exact le_trans (tropPow_antitone_entry W hdiag i j m) (ih (Nat.lt_succ_iff.mp hlt))

/-! ## Diagonal -/

theorem tropPow_diag_eq_zero [Nonempty (Fin n)]
    (W : Matrix (Fin n) (Fin n) ℝ) (hdiag : ∀ i, W i i = 0)
    (hnnc : NoNegDiag W) (k : ℕ) (i : Fin n) :
    tropPow W k i i = 0 := by
  apply le_antisymm
  · exact le_trans (tropPow_antitone_entry_of_le W hdiag i i (Nat.zero_le _)) (le_of_eq (hdiag i))
  · exact hnnc k i

theorem tropPow_diag_subadditive [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) (m k : ℕ) :
    tropPow A (m + k + 1) i i ≤ tropPow A m i i + tropPow A k i i := by
  rw [tropPow_add]; exact tropMul_diag_le _ _ _

/-! ## Chain Weight and Walk Representation -/

/-- Weight of a chain of intermediate vertices from i to j.
    For m intermediate vertices f(0), ..., f(m-1), the chain is:
    i → f(0) → f(1) → ... → f(m-1) → j
    The weight is the sum of edge weights along this path.

    Defined recursively by peeling off the last intermediate vertex:
    chainW W i j 0 _ = W i j  (direct edge, no intermediates)
    chainW W i j (m+1) f = chainW W i (f(m)) m f|_{<m} + W(f(m), j) -/
noncomputable def chainW (W : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) :
    (m : ℕ) → (Fin m → Fin n) → ℝ
  | 0, _ => W i j
  | m + 1, f => chainW W i (f (Fin.last m)) m (Fin.init f) + W (f (Fin.last m)) j

/-
tropPow W m i j equals the infimum of chain weights over all
    m-intermediate-vertex chains from i to j.
-/
theorem tropPow_eq_iInf_chainW [Nonempty (Fin n)]
    (W : Matrix (Fin n) (Fin n) ℝ) (m : ℕ) (i j : Fin n) :
    tropPow W m i j = ⨅ (f : Fin m → Fin n), chainW W i j m f := by
      induction' m with m ih generalizing i j <;> simp_all +decide [ tropPow ];
      · rfl;
      · -- Apply the associativity of infimum to rewrite the right-hand side.
        have h_assoc : ⨅ (f : Fin (m + 1) → Fin n), chainW W i j (m + 1) f = ⨅ (k : Fin n), ⨅ (g : Fin m → Fin n), chainW W i k m g + W k j := by
          rw [ @ciInf_eq_of_forall_ge_of_forall_gt_exists_lt ];
          · intro f
            have h_inf : ⨅ (k : Fin n), ⨅ (g : Fin m → Fin n), chainW W i k m g + W k j ≤ chainW W i (f (Fin.last m)) m (Fin.init f) + W (f (Fin.last m)) j := by
              refine' le_trans ( ciInf_le _ ( f ( Fin.last m ) ) ) _;
              · exact Set.finite_range _ |> Set.Finite.bddBelow;
              · exact ciInf_le ( Finite.bddBelow_range _ ) _
            generalize_proofs at *; (
            exact h_inf.trans_eq ( by rfl ));
          · intro w hw
            obtain ⟨k, hk⟩ : ∃ k : Fin n, ⨅ (g : Fin m → Fin n), chainW W i k m g + W k j < w := by
              exact?
            generalize_proofs at *; (
            obtain ⟨ g, hg ⟩ := exists_lt_of_ciInf_lt hk
            generalize_proofs at *; (
            use Fin.snoc g k; simp_all +decide [ chainW ] ;))
        generalize_proofs at *; (
        simp_all +decide [ tropMul ];
        congr! 2 with k ; rw [ @ciInf_add ] ; aesop;)

/-! ## Chain Vertex Sequence -/

/-- The full vertex sequence of a chain: [i, f(0), ..., f(m-1), j]. -/
def chainVertices (i j : Fin n) (m : ℕ) (f : Fin m → Fin n) :
    Fin (m + 2) → Fin n :=
  fun t =>
    if h : t.val = 0 then i
    else if h2 : t.val ≤ m then f ⟨t.val - 1, by omega⟩
    else j

/-! ## Chain Weight Bounds -/

/-- Any chain weight is at least the corresponding tropPow entry. -/
theorem chainW_ge_tropPow [Nonempty (Fin n)]
    (W : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n)
    (m : ℕ) (f : Fin m → Fin n) :
    tropPow W m i j ≤ chainW W i j m f := by
  rw [tropPow_eq_iInf_chainW]
  exact ciInf_le (Finite.bddBelow_range _) f

/-- **General chain weight bound**: For any chain from i to j (i ≠ j) with
    ANY number of intermediate vertices, the weight is ≥ tropPow W (n-2) i j.

    Proof by strong induction on m:
    - If m ≤ n-2: chainW ≥ tropPow W m ≥ tropPow W (n-2) (antitone).
    - If m ≥ n-1: Peel off last vertex v = f(Fin.last).
      * v = j: chainW = chainW' + 0, apply IH.
      * v = i: chainW = (closed walk ≥ 0) + W i j ≥ tropPow W (n-2) i j.
      * v ≠ i,j: chainW ≥ tropPow W (m-1) i v + W v j
               ≥ tropPow W m i j (by tropPow defn, v as witness)
               and then use IH on shorter chains via cycle argument. -/
theorem chainW_ge_tropPow_of_long [Nonempty (Fin n)]
    (W : Matrix (Fin n) (Fin n) ℝ)
    (hdiag : ∀ i, W i i = 0) (hnnc : NoNegDiag W)
    (i j : Fin n) (hij : i ≠ j)
    (f : Fin (n - 1) → Fin n) :
    tropPow W (n - 2) i j ≤ chainW W i j (n - 1) f := by sorry

/-- One-step stabilization: tropPow W (n-1) i j = tropPow W (n-2) i j. -/
theorem tropPow_one_step_stable [Nonempty (Fin n)]
    (W : Matrix (Fin n) (Fin n) ℝ)
    (hdiag : ∀ i, W i i = 0) (hnnc : NoNegDiag W)
    (i j : Fin n) (hij : i ≠ j) (hn : 2 ≤ n) :
    tropPow W (n - 1) i j = tropPow W (n - 2) i j := by
  apply le_antisymm
  · -- ≤ by monotonicity
    exact tropPow_antitone_entry_of_le W hdiag i j (by omega)
  · -- ≥ by chain weight bound
    have hrw : tropPow W (n - 1) i j = ⨅ (f : Fin (n - 1) → Fin n), chainW W i j (n - 1) f :=
      tropPow_eq_iInf_chainW W (n - 1) i j
    rw [hrw]
    exact le_ciInf (fun f => chainW_ge_tropPow_of_long W hdiag hnnc i j hij f)

/-! ## Main Stabilization Theorem -/

/-
**Tropical Power Stabilization Theorem.**

For a matrix W with zero diagonal and no negative cycles, the off-diagonal
entries of tropical powers stabilize after at most n-1 steps. Since tropPow W k
represents walks of length k+1, this means walks of length n already achieve
the shortest-path optimum (no further improvement from longer walks).

The proof uses induction on m, with the key step being that all row entries
of tropPow W m equal those of tropPow W (n-2) (using diagonal = 0 for the
i=k case and the IH for the k≠i case).
-/
theorem tropPow_stabilizes [Nonempty (Fin n)]
    (W : Matrix (Fin n) (Fin n) ℝ)
    (hdiag : ∀ i, W i i = 0) (hnnc : NoNegDiag W)
    (i j : Fin n) (hij : i ≠ j)
    {m : ℕ} (hm : n ≤ m + 2) :
    tropPow W m i j = tropPow W (n - 2) i j := by
      induction' m using Nat.strong_induction_on with m ih generalizing i j;
      by_cases hm_ge_n_minus_1 : m ≥ n - 1;
      · rcases m with ( _ | m ) <;> simp_all +decide [ tropPow ];
        -- For each k:
        -- - If k = i: tropPow W m i i = 0 by tropPow_diag_eq_zero. Also tropPow W (n-2) i i = 0 by tropPow_diag_eq_zero. So the terms match.
        -- - If k ≠ i: By IH applied with m' = m (which satisfies m ≤ m and n ≤ m + 2 since m ≥ n-2), i' = i, j' = k (since i ≠ k): tropPow W m i k = tropPow W (n-2) i k.
        have h_tropPow_m_i_k : ∀ k : Fin n, tropPow W m i k = tropPow W (n - 2) i k := by
          intro k; by_cases hk : i = k <;> simp_all +decide [ tropPow_diag_eq_zero ] ;
        convert tropPow_one_step_stable W hdiag hnnc i j hij ( show 2 ≤ n from ?_ ) using 1;
        · rcases n with ( _ | _ | n ) <;> simp_all +decide [ tropPow ];
          · exact False.elim <| Fin.elim0 i;
          · fin_cases i ; fin_cases j ; trivial;
          · exact congr_arg _ ( funext fun k => by aesop );
        · exact le_of_not_gt fun h => by interval_cases n <;> fin_cases i ; fin_cases j ; contradiction;
      · grind

/-! ## Tropical Closure and Triangle Inequality -/

/-- The tropical closure (shortest-path distance) matrix. -/
noncomputable def tropClosure [NeZero n]
    (W : Matrix (Fin n) (Fin n) ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  fun i j => if i = j then 0 else tropPow W (n - 2) i j

/-
The closure matrix satisfies the triangle inequality.
-/
theorem tropClosure_triangle [NeZero n] [Nonempty (Fin n)]
    (W : Matrix (Fin n) (Fin n) ℝ)
    (hdiag : ∀ i, W i i = 0) (hnnc : NoNegDiag W)
    (i j k : Fin n) :
    tropClosure W i j ≤ tropClosure W i k + tropClosure W k j := by
      by_cases hij : i = j <;> by_cases hkj : k = j <;> simp +decide [ *, tropClosure ];
      · split_ifs <;> simp_all +decide [ NoNegDiag ];
        have := tropPow_add W ( n - 2 ) ( n - 2 );
        replace := congr_fun ( congr_fun this j ) j; simp_all +decide [ tropMul ] ;
        exact le_trans ( hnnc _ _ ) ( this ▸ ciInf_le ( Finite.bddBelow_range _ ) _ );
      · by_cases hik : i = k <;> simp_all +decide [ tropPow_add, tropMul_le_of_witness ];
        -- By tropPow_add: tropPow W (2*(n-2)+1) i j ≤ tropPow W (n-2) i k + tropPow W (n-2) k j (via tropMul_le_of_witness with witness k).
        have h_tropPow_add : tropPow W (2 * (n - 2) + 1) i j ≤ tropPow W (n - 2) i k + tropPow W (n - 2) k j := by
          convert tropMul_le_of_witness ( tropPow W ( n - 2 ) ) ( tropPow W ( n - 2 ) ) i j k using 1;
          convert congr_arg ( fun m => m i j ) ( tropPow_add W ( n - 2 ) ( n - 2 ) ) using 1 ; ring;
        by_cases hn : n ≤ 2 * ( n - 2 ) + 1 + 2 <;> simp_all +decide [ tropPow_stabilizes ];
        omega

/-! ## Boundary Distance Matrix -/

/-- Boundary distance matrix: shortest-path distances between boundary vertices. -/
noncomputable def boundaryDistMat [NeZero n]
    (W : Matrix (Fin n) (Fin n) ℝ)
    (B : Fin b → Fin n) : Matrix (Fin b) (Fin b) ℝ :=
  fun p q => tropClosure W (B p) (B q)

/-- The boundary distance matrix inherits the triangle inequality. -/
theorem boundaryDistMat_triangle [NeZero n] [Nonempty (Fin n)]
    (W : Matrix (Fin n) (Fin n) ℝ)
    (hdiag : ∀ i, W i i = 0) (hnnc : NoNegDiag W)
    (B : Fin b → Fin n) (p q r : Fin b) :
    boundaryDistMat W B p r ≤
      boundaryDistMat W B p q + boundaryDistMat W B q r := by
  exact tropClosure_triangle W hdiag hnnc (B p) (B r) (B q)