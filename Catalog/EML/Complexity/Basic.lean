import EML.Complexity.Defs

/-!
# EML Circuit Depth Separation — Basic Theorems

## Main Results

1. **`EMLExpr.expRank_le_emlDepth`**: The exponential rank is bounded by EML depth.
2. **`fullExprIterExp_eval`**: The canonical FullExpr correctly evaluates to `iterExp n`.
3. **`fullExprIterExp_depth`**: The canonical FullExpr has depth exactly `n`.
4. **`iterExp_strictMono`**: Iterated exponentials are strictly monotone.
5. **`iterExp_pos`**: Iterated exponentials are positive on positive inputs.
6. **`emlExprIterExp_eval`**: The canonical EMLExpr correctly evaluates to `iterExp n`.
7. **`emlExprIterExp_emlDepth`**: The canonical EMLExpr has emlDepth exactly `n`.
-/

noncomputable section

open Real

/-! ## Theorem 1: Structural bound — expRank ≤ emlDepth -/

/-
The exponential nesting rank of any EML expression is bounded by its EML depth.
    This is the structural half of the depth separation: it shows that each `eml` layer
    can increase the exponential nesting by at most one.
-/
theorem EMLExpr.expRank_le_emlDepth (e : EMLExpr) : e.expRank ≤ e.emlDepth := by
  induction e <;> simp +decide [ *, EMLExpr.expRank, EMLExpr.emlDepth ];
  · grind;
  · grind;
  · grind

/-! ## Theorem 2: Upper bound in full language -/

/-
The canonical `FullExpr` for `iterExp n` evaluates correctly.
-/
theorem fullExprIterExp_eval (n : ℕ) (x : ℝ) :
    (fullExprIterExp n).eval x = iterExp n x := by
  induction' n with n ih generalizing x;
  · rfl;
  · exact congr_arg Real.exp ( ih x )

/-
The canonical `FullExpr` for `iterExp n` has depth exactly `n`.
-/
theorem fullExprIterExp_depth (n : ℕ) :
    (fullExprIterExp n).depth = n := by
  induction' n with n ih;
  · rfl;
  · exact show 1 + ( fullExprIterExp n |> FullExpr.depth ) = n + 1 from by rw [ ih, add_comm ] ;

/-
The canonical `FullExpr` for `iterExp n` has size exactly `n + 1`.
-/
theorem fullExprIterExp_size (n : ℕ) :
    (fullExprIterExp n).size = n + 1 := by
  induction n <;> simp_all +arith +decide [ fullExprIterExp ];
  rename_i n ih; rw [ show ( fullExprIterExp n ).exp.size = 1 + ( fullExprIterExp n ).size from rfl ] ; simp +arith +decide [ ih ] ;

/-
`iterExp n` is efficiently representable in `FullExpr`: depth `n`, size `n + 1`.
-/
theorem exists_fullExpr_iterExp (n : ℕ) :
    ∃ e : FullExpr,
      FullRepresentsOnPos e (iterExp n) ∧ e.depth = n ∧ e.size = n + 1 := by
  exact ⟨ fullExprIterExp n, fun x hx => by simp [ fullExprIterExp_eval ], fullExprIterExp_depth n, fullExprIterExp_size n ⟩

/-! ## Theorem 3: Iterated exponential properties -/

/-
Iterated exponentials are strictly monotone for every `n`.
-/
theorem iterExp_strictMono (n : ℕ) : StrictMono (iterExp n) := by
  induction' n with n ih;
  · exact strictMono_id;
  · exact Real.exp_strictMono.comp ih

/-
Iterated exponentials are positive on positive inputs.
-/
theorem iterExp_pos (n : ℕ) {x : ℝ} (hx : 0 < x) : 0 < iterExp n x := by
  exact Nat.recOn n hx fun n ih => Real.exp_pos _

/-
For n ≥ 1, iterExp n x is positive for all x.
-/
theorem iterExp_pos_of_pos_level {n : ℕ} (hn : 0 < n) (x : ℝ) :
    0 < iterExp n x := by
  induction hn <;> simp +decide [ * ];
  · exact Real.exp_pos _;
  · exact Real.exp_pos _

/-
iterExp is monotone in its first argument for positive inputs.
-/
theorem iterExp_mono_level {n m : ℕ} (hnm : n ≤ m) {x : ℝ} (_hx : 0 < x) :
    iterExp n x ≤ iterExp m x := by
  -- We'll use induction on $m - n$.
  induction' hnm with m ih;
  · rfl;
  · exact le_trans ‹_› ( by exact Real.add_one_le_exp _ |> le_trans ( by linarith [ show 0 ≤ iterExp m x from Nat.recOn m ( by exact le_of_lt _hx ) fun n ihn => by { rw [ show iterExp ( n + 1 ) x = Real.exp ( iterExp n x ) from rfl ] ; positivity } ] ) )

/-
For positive x, iterExp (n+1) x > iterExp n x.
-/
theorem iterExp_lt_succ {n : ℕ} {x : ℝ} (_hx : 0 < x) :
    iterExp n x < iterExp (n + 1) x := by
  exact Real.add_one_le_exp _ |> lt_of_lt_of_le ( lt_add_one _ )

/-! ## Canonical EML construction -/

/-
The canonical `EMLExpr` for `iterExp n` evaluates correctly.
-/
theorem emlExprIterExp_eval (n : ℕ) (x : ℝ) :
    (emlExprIterExp n).eval x = iterExp n x := by
  induction' n with n ihizing x;
  · rfl;
  · exact show ( 1 : ℝ ) * Real.exp ( ( emlExprIterExp n ).eval x ) = Real.exp ( iterExp n x ) from by rw [ ihizing, one_mul ] ;

/-
The canonical `EMLExpr` for `iterExp n` has `emlDepth` exactly `n`.
-/
theorem emlExprIterExp_emlDepth (n : ℕ) :
    (emlExprIterExp n).emlDepth = n := by
  induction' n with n ih;
  · rfl;
  · exact show 1 + Max.max 0 ( emlExprIterExp n |> EMLExpr.emlDepth ) = n + 1 from by simp +arith +decide [ ih ] ;

/-
The canonical `EMLExpr` for `iterExp n` has `expRank` exactly `n`.
-/
theorem emlExprIterExp_expRank (n : ℕ) :
    (emlExprIterExp n).expRank = n := by
  induction' n with n ih;
  · rfl;
  · exact Nat.succ_inj.mpr ih

/-! ## EMLExpr depth structural properties -/

/-
EML depth is bounded by tree depth.
-/
theorem EMLExpr.emlDepth_le_depth (e : EMLExpr) : e.emlDepth ≤ e.depth := by
  induction' e using EMLExpr.recOn with e ih;
  all_goals simp +arith +decide [ *, EMLExpr.depth, EMLExpr.emlDepth ];
  · exact ⟨ Nat.le_succ_of_le ( le_max_of_le_left ‹_› ), Nat.le_succ_of_le ( le_max_of_le_right ‹_› ) ⟩;
  · exact ⟨ le_add_of_le_of_nonneg ( le_trans ‹_› ( le_max_left _ _ ) ) zero_le_one, le_add_of_le_of_nonneg ( le_trans ‹_› ( le_max_right _ _ ) ) zero_le_one ⟩;
  · grind;
  · grind;
  · grind

end