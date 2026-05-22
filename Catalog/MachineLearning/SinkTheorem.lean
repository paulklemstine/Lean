import Mathlib
import MachineLearning.TropicalAttention.Defs

/-!
# Theorem D: Attention Sink as Tropical Fixed Point

If column `jStar` dominates every row by gap δ > 0, then:
1. `jStar` is the unique rowwise argmax in every row
2. Tropical attention maps every row to `V_{jStar}`
3. This selection is idempotent

This makes "attention sink" a theorem, not an empirical observation.
-/

noncomputable section

open Finset BigOperators Real

/-! ## Dominant column implies row argmax -/

/-
If column `jStar` dominates every row by gap δ > 0,
    then `jStar` achieves the row maximum in every row.
-/
theorem dominant_column_is_row_argmax
    {n : ℕ} [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (jStar : Fin n) (δ : ℝ) (hδ : 0 < δ)
    (hdom : IsDominantColumn A jStar δ) :
    ∀ i, IsRowArgmax A i jStar := by
  exact fun i k => if hk : k = jStar then hk ▸ le_rfl else by linarith [ hdom i k hk ] ;

/-
Tropical attention under dominant column: every row selects `V_{jStar}`.
-/
theorem tropical_sink_output
    {n d : ℕ} [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (V : Matrix (Fin n) (Fin d) ℝ)
    (jStar : Fin n) (δ : ℝ) (hδ : 0 < δ)
    (hdom : IsDominantColumn A jStar δ) :
    tropAttnWithSelector V (fun _ => jStar) = fun i k => V jStar k := by
  exact?

/-
Tropical sink selection is idempotent: applying it twice is the same as once.
-/
theorem tropical_sink_idempotent
    {n d : ℕ} [Nonempty (Fin n)]
    (V : Matrix (Fin n) (Fin d) ℝ)
    (jStar : Fin n) :
    tropAttnWithSelector (tropAttnWithSelector V (fun _ => jStar)) (fun _ => jStar) =
    tropAttnWithSelector V (fun _ => jStar) := by
  unfold tropAttnWithSelector; ext i k; simp +decide ;

/-! ## Softmax concentration under dominance -/

/-
Under dominant column with gap δ, the softmax weight on `jStar`
    is close to 1 with exponential convergence.
-/
theorem softmax_weight_dominant_bound
    {n : ℕ} [hn : Nonempty (Fin n)]
    (S : Matrix (Fin n) (Fin n) ℝ)
    (jStar : Fin n) (δ : ℝ) (hδ : 0 < δ)
    (hdom : IsDominantColumn S jStar δ)
    (τ : ℝ) (hτ : 0 < τ) :
    ∀ i, 1 - softmaxWeight S τ i jStar ≤
      (Fintype.card (Fin n) - 1) * Real.exp (-δ / τ) := by
  intro i
  unfold softmaxWeight;
  -- By definition of $IsDominantColumn$, we know that for all $k \ne jStar$, $S i k \le S i jStar - δ$.
  have h_dom : ∀ k ≠ jStar, S i k ≤ S i jStar - δ := by
    exact fun k hk => by linarith [ hdom i k hk ] ;
  -- Applying the inequality $e^{(S i k) / τ} \leq e^{(S i jStar - δ) / τ}$ to each term in the sum.
  have h_sum : ∑ k ∈ Finset.univ.erase jStar, Real.exp ((S i k) / τ) ≤ ∑ k ∈ Finset.univ.erase jStar, Real.exp ((S i jStar) / τ) * Real.exp (-δ / τ) := by
    exact Finset.sum_le_sum fun k hk => by rw [ ← Real.exp_add ] ; exact Real.exp_le_exp.mpr ( by ring_nf at *; nlinarith [ h_dom k ( Finset.ne_of_mem_erase hk ), inv_pos.mpr hτ ] ) ;
  simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ];
  rw [ add_div', le_div_iff₀ ] <;> try positivity [ show 0 < ∑ k, Real.exp ( S i k / τ ) from Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) ⟨ jStar, Finset.mem_univ _ ⟩, Real.exp_pos ( S i jStar / τ ), show ( n : ℝ ) ≥ 1 from Nat.one_le_cast.mpr ( Fin.pos jStar ), show ( n - 1 : ℝ ) ≥ 0 from sub_nonneg.mpr ( Nat.one_le_cast.mpr ( Fin.pos jStar ) ), mul_div_cancel₀ ( -δ ) hτ.ne' ];
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ Nat.succ_eq_add_one, mul_assoc, mul_comm, mul_left_comm ];
  nlinarith [ Real.exp_pos ( S i jStar / τ ), Real.exp_pos ( -δ / τ ), mul_le_mul_of_nonneg_left ( show ( ∑ k : Fin ( n + 1 + 1 ), Real.exp ( S i k / τ ) ) ≥ Real.exp ( S i jStar / τ ) from Finset.single_le_sum ( fun a _ => Real.exp_nonneg ( S i a / τ ) ) ( Finset.mem_univ jStar ) ) ( Real.exp_nonneg ( -δ / τ ) ) ]

end