/-
# Sharpness of the density-zero exceptional set

The main theorem of `SignAlternation.lean` shows that when the `ω = -1`
oscillation *uniformly* dominates the error from some point on, the sign-
alternation exceptional set is in fact **finite** (this is the situation for the
Folsom–Males–Rolen–Storzer function `v₁(q)`, whose coefficients are eventually
strictly alternating).

Here we show this cannot be strengthened for the *general* oscillatory model: the
"density zero" conclusion is sharp. When the amplitude itself degenerates on a
sparse (density-zero) set of indices — as happens when a *second* root of unity
contributes a competing oscillation that occasionally cancels the leading term —
the exceptional set can be genuinely **infinite** while still having density zero.

* `card_squares_le`                     — counting bound for perfect squares.
* `tendsto_sqrt_succ_div_nat`           — `(√N + 1)/N → 0`.
* `squares_densityZero`                 — **the set of perfect squares has density zero**.
* `alternation_exceptions_can_be_infinite` — **an explicit oscillatory model with an
  infinite, density-zero sign-alternation exceptional set**.
-/
import Mathlib
import Applications.QSeriesSignAlternation.SignAlternation

open Filter Topology

namespace QSignAlt

-- !-- Lab Notes -- !--
-- HYPOTHESIS (Hypothesizer): "The 'density zero' in the main theorem is sharp: one
--   cannot always upgrade it to 'finite'. If the amplitude vanishes exactly on the
--   perfect squares (a density-zero but infinite set), alternation fails on an
--   infinite set of density zero."
-- EXPERIMENT (Experimenter): take A n = 0 on squares, 1 elsewhere, a n = (-1)^n A n.
--   Then a n · a(n+1) = -1 when neither n nor n+1 is a square, and = 0 otherwise.
--   So exceptions = {n | n or n+1 is a perfect square}, which is infinite.
-- ANALYSIS (Analyst): counting squares in [0,N) is ≤ √N + 1, so their density is 0;
--   the neighbour shift only doubles the count, preserving density zero.
-- CRITIQUE (Critic): the construction is a legitimate instance of the oscillatory
--   model with A n ≥ 0 (the amplitude is allowed to degenerate); it demonstrates
--   the theorem's density-zero conclusion is best possible, contrasting with the
--   *finite* exceptional set enjoyed by v₁(q) under uniform dominance.
-- !-- end Lab Notes -- !--

/-! ## A general counting criterion for density zero -/

open Classical in
/-- If the counting function of `S` is bounded by a real function `b` whose ratio
`b N / N` tends to `0`, then `S` has density zero. -/
theorem densityZero_of_count_le (S : Set ℕ) (b : ℕ → ℝ)
    (hb : ∀ N, (((Finset.range N).filter (fun n => n ∈ S)).card : ℝ) ≤ b N)
    (hlim : Tendsto (fun N : ℕ => b N / (N : ℝ)) atTop (𝓝 0)) :
    densityZero S := by
  refine' squeeze_zero ( fun N => _ ) ( fun N => _ ) hlim;
  · positivity;
  · gcongr ; aesop

/-! ## Perfect squares have density zero -/

/-
There are at most `√N + 1` perfect squares below `N`.
-/
theorem card_squares_le (N : ℕ) :
    ((Finset.range N).filter (fun n => IsSquare n)).card ≤ Nat.sqrt N + 1 := by
  have h_prod_bound : Finset.filter (fun n => IsSquare n) (Finset.range N) ⊆ Finset.image (fun k => k * k) (Finset.range (Nat.sqrt N + 1)) := by
    intro n hn; obtain ⟨ k, rfl ⟩ := Finset.mem_filter.mp hn |>.2; exact Finset.mem_image.mpr ⟨ k, Finset.mem_range.mpr ( Nat.lt_succ_of_le ( Nat.le_sqrt.mpr ( by nlinarith [ Finset.mem_range.mp ( Finset.mem_filter.mp hn |>.1 ) ] ) ) ), by ring ⟩ ;
  exact le_trans ( Finset.card_le_card h_prod_bound ) ( Finset.card_image_le.trans ( by norm_num ) )

/-
`(√N + 1)/N → 0` as `N → ∞`.
-/
theorem tendsto_sqrt_succ_div_nat :
    Tendsto (fun N : ℕ => ((Nat.sqrt N : ℝ) + 1) / (N : ℝ)) atTop (𝓝 0) := by
  -- We can bound the expression by considering the inequality $\frac{\sqrt{N} + 1}{N} \leq \frac{2\sqrt{N}}{N} = \frac{2}{\sqrt{N}}$.
  have h_bound : ∀ N : ℕ, N ≥ 1 → (Nat.sqrt N + 1 : ℝ) / N ≤ 2 / Real.sqrt N := by
    intro N hN; rw [ div_le_div_iff₀ ] <;> try positivity;
    nlinarith only [ show ( N.sqrt : ℝ ) ≤ Real.sqrt N by exact Real.le_sqrt_of_sq_le <| mod_cast Nat.sqrt_le' N, Real.mul_self_sqrt <| Nat.cast_nonneg N, show ( N.sqrt : ℝ ) ≥ 1 by exact_mod_cast Nat.sqrt_pos.2 hN ];
  exact squeeze_zero_norm' ( Filter.eventually_atTop.mpr ⟨ 1, fun N hN => by rw [ Real.norm_of_nonneg ( by positivity ) ] ; exact h_bound N hN ⟩ ) ( tendsto_const_nhds.div_atTop <| by simpa only [ Real.sqrt_eq_rpow ] using tendsto_rpow_atTop ( by positivity ) |> Filter.Tendsto.comp <| tendsto_natCast_atTop_atTop )

/-
**The set of perfect squares has natural density zero.**
-/
theorem squares_densityZero : densityZero {n : ℕ | IsSquare n} := by
  convert densityZero_of_count_le { n | IsSquare n } ( fun N => ( Nat.sqrt N : ℝ ) + 1 ) ?_ ?_;
  · intro N;
    convert Nat.cast_le.mpr ( card_squares_le N ) using 1;
    all_goals try infer_instance;
    · congr!;
    · norm_num;
  · convert tendsto_sqrt_succ_div_nat using 1

/-! ## Closure properties of density zero -/

/-
Density zero is preserved under subsets.
-/
theorem densityZero_subset {S T : Set ℕ} (h : S ⊆ T) (hT : densityZero T) :
    densityZero S := by
  refine' squeeze_zero ( fun N => by positivity ) ( fun N => _ ) hT;
  gcongr

/-
Density zero is preserved under binary unions.
-/
theorem densityZero_union {S T : Set ℕ} (hS : densityZero S) (hT : densityZero T) :
    densityZero (S ∪ T) := by
  refine' squeeze_zero ( fun N => by positivity ) ( fun N => _ ) ( by simpa using hS.add hT );
  rw [ ← add_div ] ; gcongr;
  norm_cast; rw [ ← Finset.card_union_add_card_inter ] ; exact Nat.le_add_right _ _ |> le_trans ( Finset.card_mono <| by aesop_cat ) ;

/-
The predecessors of the perfect squares also form a density-zero set.
-/
theorem shifted_squares_densityZero : densityZero {n : ℕ | IsSquare (n + 1)} := by
  refine' densityZero_of_count_le _ _ _ _;
  exact fun N => ( Nat.sqrt N : ℝ ) + 2;
  · intro N;
    refine' mod_cast le_trans ( Finset.card_le_card _ ) _;
    exact Finset.image ( fun n => n ^ 2 - 1 ) ( Finset.Icc 1 ( Nat.sqrt N + 1 ) );
    · intro n hn; simp_all +decide [ IsSquare ];
      rcases hn.2 with ⟨ r, hr ⟩ ; exact ⟨ r, ⟨ by nlinarith, by nlinarith [ Nat.lt_succ_sqrt N ] ⟩, Nat.sub_eq_of_eq_add <| by linarith ⟩;
    · exact Finset.card_image_le.trans ( by norm_num );
  · -- We can bound $\frac{\sqrt{N} + 2}{N}$ above by $\frac{3\sqrt{N}}{N} = \frac{3}{\sqrt{N}}$.
    have h_bound : ∀ N : ℕ, N > 0 → ((Nat.sqrt N : ℝ) + 2) / N ≤ 3 / Real.sqrt N := by
      intro N hN; rw [ div_le_div_iff₀ ] <;> nlinarith [ show ( N : ℝ ) ≥ 1 by exact_mod_cast hN, Real.sqrt_nonneg N, Real.sq_sqrt <| Nat.cast_nonneg N, show ( Nat.sqrt N : ℝ ) ≤ Real.sqrt N by exact Real.le_sqrt_of_sq_le <| mod_cast Nat.sqrt_le' N ] ;
    exact squeeze_zero_norm' ( by filter_upwards [ Filter.eventually_gt_atTop 0 ] with N hN using by rw [ Real.norm_of_nonneg ( by positivity ) ] ; exact h_bound N hN ) ( tendsto_const_nhds.div_atTop <| by simpa only [ Real.sqrt_eq_rpow ] using tendsto_rpow_atTop ( by positivity ) |> Filter.Tendsto.comp <| tendsto_natCast_atTop_atTop )

/-! ## An oscillatory model with infinite, density-zero exceptions -/

/-- Amplitude that degenerates exactly on the perfect squares. -/
noncomputable def sqAmp (n : ℕ) : ℝ := if IsSquare n then 0 else 1

/-- The associated `ω = -1` oscillatory coefficient sequence. -/
noncomputable def sqCoeff (n : ℕ) : ℝ := (-1) ^ n * sqAmp n

/-
**Sharpness of the density-zero conclusion.** There is an explicit `ω = -1`
oscillatory coefficient sequence `sqCoeff` (with nonnegative amplitude `sqAmp`)
whose sign-alternation exceptional set is **infinite** yet still has natural
density zero.  Thus the main theorem's "density zero" cannot in general be
improved to "finite".
-/
theorem alternation_exceptions_can_be_infinite :
    (altExceptionSet sqCoeff).Infinite ∧ densityZero (altExceptionSet sqCoeff) := by
  constructor;
  · refine Set.infinite_of_forall_exists_gt ?_;
    intro a;
    refine' ⟨ ( a + 1 ) ^ 2, _, _ ⟩;
    · unfold altExceptionSet sqCoeff; norm_num [ sqAmp ] ;
      split_ifs <;> norm_num [ pow_succ' ];
      exact False.elim <| ‹¬IsSquare ( ( a + 1 ) ^ 2 ) › <| ⟨ a + 1, by ring ⟩;
    · grind;
  · -- The set of exceptions is exactly the set of perfect squares union the set of predecessors of perfect squares.
    have h_exceptions : altExceptionSet sqCoeff = {n : ℕ | IsSquare n} ∪ {n : ℕ | IsSquare (n + 1)} := by
      ext n
      simp [altExceptionSet, sqCoeff, sqAmp];
      split_ifs <;> simp_all +decide [ ← pow_add ];
    exact h_exceptions ▸ densityZero_union squares_densityZero shifted_squares_densityZero

end QSignAlt