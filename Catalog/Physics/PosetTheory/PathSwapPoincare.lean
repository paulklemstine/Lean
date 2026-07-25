/-
# A telescoping Poincaré inequality for the path swap chain

The path is the one-dimensional prototype for local swap reconfiguration.  This
file supplies the converse to the slowly varying position witness: every
nonconstant observable pays enough adjacent-edge energy to force a cubic lower
bound.  Together with the imported cubic upper bound, this closes the exponent.

**Target category: cross-domain bridge.** The result connects the combinatorics
of unique paths and finite sums with the Poincaré variational principle from
probability and statistical physics.

The central estimate is deliberately insensitive to monotonicity.  A difference
between any two sites telescopes along the unique path between them;
Cauchy–Schwarz bounds its square by the path length times the sum of squared
increments.  Summing over all ordered pairs costs at most another factor `n²`.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).** Unique-path geometry should control every
  observable, not merely the linear position witness, and therefore upgrade the
  witnessed cubic upper bound to a two-sided spectral estimate.
* **Experiment (Experimenter).** Differences were expanded into consecutive
  increments and bounded by finite Cauchy–Schwarz. Summation over ordered pairs
  gives a deliberately robust `n³` comparison between variation and energy.
* **Analysis (Analyst).** The cubic exponent has two complementary origins:
  linear energy versus quartic variation gives the upper bound, while path
  length times the number of ordered endpoint pairs gives the lower bound.
* **Critique (Critic).** The estimate is not asserted at the empty or singleton
  path, where no nonconstant observable exists. The lower constant is not sharp;
  replacing the global `n` path-length bound by exact edge congestion is a
  separate optimization problem. No monotonicity assumption on the observable
  is hidden in the argument.
* **Synthesis (Principal Investigator).** The imported Rayleigh witness and the
  new all-observable Poincaré estimate place the path gap between `2 n⁻³` and
  `12 n⁻³`, establishing cubic order by two genuinely different mechanisms.
-/
import Applications.NeuralCoding.ChordSwapUniversality

open scoped BigOperators
open Finset

namespace PathSwapPoincare

open ChordSwapUniv

/-- The unoriented adjacent-increment energy of an observable on a path. -/
def edgeEnergy (n : ℕ) (f : Fin n → ℝ) : ℝ :=
  ∑ k : Fin (n - 1), (f ⟨k.val + 1, by omega⟩ - f ⟨k.val, by omega⟩) ^ 2

/-
A difference between two path sites is controlled by the total adjacent
increment energy, with the path length bounded by `n`.
-/
lemma pair_sq_le_edgeEnergy {n : ℕ} (f : Fin n → ℝ) (i j : Fin n) :
    (f i - f j) ^ 2 ≤ (n : ℝ) * edgeEnergy n f := by
  rcases n with ( _ | _ | n ) <;> norm_num at *;
  · exact Fin.elim0 i;
  · fin_cases i ; fin_cases j ; norm_num [ edgeEnergy ];
  · -- By the properties of the edge energy and the Cauchy-Schwarz inequality, we have:
    have h_cauchy_schwarz : ∀ i j : Fin (n + 2), i ≤ j → (f j - f i) ^ 2 ≤ (j - i) * ∑ k ∈ Finset.Ico i j, (f (k + 1) - f k) ^ 2 := by
      intros i j hij
      have h_telescope : f j - f i = ∑ k ∈ Finset.Ico i j, (f (k + 1) - f k) := by
        induction' j using Fin.inductionOn with j ih;
        · aesop;
        · cases hij.eq_or_lt <;> simp_all +decide;
          rw [ show ( Ico i ( Fin.succ j ) ) = Finset.Ico i ( Fin.castSucc j ) ∪ { ( Fin.castSucc j ) } from ?_, Finset.sum_union ] <;> norm_num;
          · linarith [ ih ( Nat.le_of_lt_succ ‹_› ) ];
          · ext x; simp [Finset.mem_Ico, Finset.mem_insert];
            exact ⟨ fun h => or_iff_not_imp_left.mpr fun h' => ⟨ h.1, lt_of_le_of_ne ( Nat.le_of_lt_succ h.2 ) ( by simpa [ Fin.ext_iff ] using h' ) ⟩, fun h => h.elim ( fun h => ⟨ h.symm ▸ Nat.le_of_lt_succ ‹_›, h.symm ▸ Nat.lt_succ_self _ ⟩ ) fun h => ⟨ h.1, h.2.trans_le ( Nat.le_succ _ ) ⟩ ⟩;
      have h_cauchy_schwarz : ∀ (s : Finset (Fin (n + 2))), (∑ k ∈ s, (f (k + 1) - f k)) ^ 2 ≤ (s.card : ℝ) * ∑ k ∈ s, (f (k + 1) - f k) ^ 2 := by
        exact fun s => sq_sum_le_card_mul_sum_sq;
      convert h_cauchy_schwarz ( Finset.Ico i j ) using 1 ; aesop;
      simp +decide [ hij ];
    cases le_total i j <;> simp_all +decide [ edgeEnergy ];
    · refine' le_trans ( by rw [ sq ] ; nlinarith ) ( le_trans ( h_cauchy_schwarz i j ‹_› ) _ );
      gcongr;
      · linarith [ show ( i : ℝ ) ≤ j from mod_cast ‹_›, show ( j : ℝ ) ≤ n + 1 from mod_cast Fin.is_le j ];
      · refine' le_trans ( Finset.sum_le_sum_of_subset_of_nonneg _ _ ) _;
        exact Finset.univ.filter fun x => x.val < n + 1;
        · exact fun x hx => by simpa using Finset.mem_Ico.mp hx |>.2 |> Nat.lt_of_lt_of_le <| Nat.le_of_lt_succ <| Fin.is_lt j;
        · exact fun _ _ _ => sq_nonneg _;
        · refine' le_of_eq _;
          refine' Finset.sum_bij ( fun x hx => ⟨ x, by linarith [ Fin.is_lt x, Finset.mem_filter.mp hx ] ⟩ ) _ _ _ _ <;> simp +decide [ Fin.ext_iff ];
          · exact fun b => ⟨ ⟨ b, by linarith [ Fin.is_lt b ] ⟩, by linarith [ Fin.is_lt b ], rfl ⟩;
          · exact fun a ha => by congr; exact Fin.ext <| by simp +decide [ Fin.val_add, Nat.mod_eq_of_lt ( show ( a : ℕ ) + 1 < n + 2 from by linarith ) ] ;
    · refine' le_trans ( h_cauchy_schwarz _ _ ‹_› ) _;
      refine' mul_le_mul _ _ _ _;
      · linarith [ show ( i : ℝ ) ≤ n + 1 by norm_cast; exact Fin.is_le i, show ( j : ℝ ) ≥ 0 by norm_cast; exact Nat.zero_le j ];
      · refine' le_trans ( Finset.sum_le_sum_of_subset_of_nonneg _ _ ) _;
        exact Finset.univ.filter fun x => x.val < n + 1;
        · grind;
        · exact fun _ _ _ => sq_nonneg _;
        · refine' le_of_eq _;
          refine' Finset.sum_bij ( fun x hx => ⟨ x, by linarith [ Fin.is_lt x, Finset.mem_filter.mp hx ] ⟩ ) _ _ _ _ <;> simp +decide [ Fin.ext_iff ];
          · exact fun b => ⟨ ⟨ b, by linarith [ Fin.is_lt b ] ⟩, by linarith [ Fin.is_lt b ], rfl ⟩;
          · exact fun a ha => by congr; simp +decide [ Fin.add_def, Nat.mod_eq_of_lt ( by linarith : ( a : ℕ ) + 1 < n + 2 ) ] ;
      · exact Finset.sum_nonneg fun _ _ => sq_nonneg _;
      · positivity

/-
Summing the pointwise telescoping estimate over all ordered endpoint pairs
costs at most `n²`, yielding the path Poincaré inequality with cubic constant.
-/
theorem variation_le_cube_edgeEnergy {n : ℕ} (f : Fin n → ℝ) :
    vr f ≤ (n : ℝ) ^ 3 * edgeEnergy n f := by
  -- By the properties of the edge energy and the Cauchy-Schwarz inequality, we have $(f(i) - f(j))^2 \leq n \cdot \text{edgeEnergy}(n, f)$ for all $i, j$.
  have h_cauchy_schwarz : ∀ i j : Fin n, (f i - f j) ^ 2 ≤ n * edgeEnergy n f := by
    exact pair_sq_le_edgeEnergy f;
  convert Finset.sum_le_sum fun i _ => Finset.sum_le_sum fun j _ => h_cauchy_schwarz i j using 1 ; norm_num ; ring

/-
The oriented Dirichlet energy of the unit path is twice the unoriented
adjacent-increment energy.
-/
theorem path_dir_eq_two_edgeEnergy {n : ℕ} (f : Fin n → ℝ) :
    dir (wpathQ 1 n) f = 2 * edgeEnergy n f := by
  unfold dir edgeEnergy;
  rcases n with ( _ | n ) <;> simp_all +decide [ wpathQ ];
  induction' n with n ih;
  · simp +decide [ Fin.eq_zero ];
  · simp_all +decide [ Fin.sum_univ_succ, Finset.sum_add_distrib ];
    convert congr_arg ( · + ( f 0 - f 1 ) ^ 2 + ( f 1 - f 0 ) ^ 2 ) ( ih ( fun i => f i.succ ) ) using 1 <;> ring!

/-
Every nonconstant observable on a path of length at least two has Rayleigh
quotient at least `2/n³`.
-/
theorem path_RQ_cubic_lower {n : ℕ} (hn : 2 ≤ n) (f : Fin n → ℝ)
    (hnc : ∃ x y, f x ≠ f y) :
    2 / (n : ℝ) ^ 3 ≤ RQ (wpathQ 1 n) f := by
  rw [ RQ, div_le_div_iff₀ ];
  · rw [ path_dir_eq_two_edgeEnergy ];
    linarith [ variation_le_cube_edgeEnergy f ];
  · positivity;
  · exact vr_pos_of_nonconstant hnc

/-
The combinatorial path gap is bounded below by `2/n³`.
-/
theorem path_gap_cubic_lower {n : ℕ} (hn : 2 ≤ n) :
    2 / (n : ℝ) ^ 3 ≤ gap (wpathQ 1 n) := by
  refine' le_csInf _ _;
  · exact ⟨ _, ⟨ idf n, wpath_nonconstant hn, rfl ⟩ ⟩;
  · rintro _ ⟨ f, ⟨ x, y, hxy ⟩, rfl ⟩ ; exact path_RQ_cubic_lower hn f ⟨ x, y, hxy ⟩ ;

/-
**Two-sided cubic spectral estimate.** The unit path swap chain has gap
between `2 n⁻³` and `12 n⁻³`.
-/
theorem path_gap_two_sided {n : ℕ} (hn : 2 ≤ n) :
    2 / (n : ℝ) ^ 3 ≤ gap (wpathQ 1 n) ∧
      gap (wpathQ 1 n) ≤ 12 / (n : ℝ) ^ 3 := by
  refine' ⟨ path_gap_cubic_lower hn, _ ⟩;
  convert wpath_gap_cubic_upper zero_le_one hn using 1;
  ring

end PathSwapPoincare