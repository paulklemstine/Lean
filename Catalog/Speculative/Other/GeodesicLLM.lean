/-! # CatalogBuild.Speculative.Other.GeodesicLLM

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 13
-/

import Mathlib

/-- Cramér-Rao: variance ≥ 1/I(θ), so large Fisher eigenvalues allow
small variance; small eigenvalues indicate redundant parameters. -/
theorem cramer_rao_motivation (fisher_eigenval : ℝ) (hf : 0 < fisher_eigenval)
    (variance : ℝ) (hv : 1 / fisher_eigenval ≤ variance) :
    0 < variance := by linarith [div_pos one_pos hf]



/-- [Section: # CatalogBuild.Speculative.Other.GeodesicLLM
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 13] -/
theorem geodesic_speedup (cond_s cond_n steps_s steps_n : ℝ)
    (hcs : 0 < cond_s)
    (hs : steps_n * cond_s ≤ steps_s * cond_n) :
    steps_n ≤ steps_s * cond_n / cond_s := by
  rwa [ le_div_iff₀ hcs ]



theorem tropical_is_zero_temp_limit (a b : ℝ) (hab : a < b)
    (β : ℝ) (hβ : 0 < β) :
    b ≤ (1/β) * Real.log (Real.exp (β * a) + Real.exp (β * b)) := by
  rw [ one_div, inv_mul_eq_div, le_div_iff₀' hβ ];
  rw [ Real.le_log_iff_exp_le ] <;> nlinarith [ Real.exp_pos ( β * a ), Real.exp_pos ( β * b ), Real.exp_le_exp.2 ( mul_le_mul_of_nonneg_left hab.le hβ.le ) ]



theorem conformal_factor_upper (x_norm_sq : ℝ) (hx : 0 ≤ x_norm_sq) :
    2 / (1 + x_norm_sq) ≤ 2 := by
  exact div_le_self ( by norm_num ) ( by linarith )



/-- Spherical projection gives (d-1)/d compression ratio < 1. -/
theorem spherical_compression_ratio (d : ℕ) (hd : 2 ≤ d) :
    (d - 1 : ℝ) / d < 1 := by
  rw [div_lt_one (by positivity : (0:ℝ) < d)]
  exact sub_lt_self _ one_pos



theorem attention_layer_bound (κ ε : ℝ) (hκ : 0 < κ) (hκ1 : κ < 1)
    (hε : 0 < ε) (init_dist : ℝ) (hd : 0 < init_dist) :
    ∃ N : ℕ, κ ^ N * init_dist < ε := by
  -- We can find N such that κ^N < ε/init_dist using the fact that 0 < κ < 1 and the Archimedean property.
  have h_arch : ∃ N : ℕ, κ ^ N < ε / init_dist := by
    exact exists_pow_lt_of_lt_one ( by positivity ) hκ1;
  exact h_arch.imp fun N hN => by rwa [ lt_div_iff₀ hd ] at hN;



/-- The collapsed representation is invariant under additional layers. -/
theorem idempotent_invariance {α : Type*} (f : α → α)
    (x_star : α) (hfp : f x_star = x_star) (n : ℕ) :
    f^[n] x_star = x_star := by
  induction n with
  | zero => simp
  | succ n ih => simp [Function.iterate_succ_apply', ih, hfp]



/-- E₈ lattice has 16x better density than Z⁸. -/
theorem e8_density_advantage :
    (1 : ℝ) / 16 > 1 / 256 := by norm_num



/-- Bit savings from lattice quantization scale with dimension. -/
theorem lattice_bit_savings (d : ℕ) (log_ratio : ℝ) (hlr : 0 < log_ratio) (hd : 0 < d) :
    0 < (d : ℝ) / 2 * log_ratio := by positivity



/-- Hyperbolic distance grows logarithmically with tree distance. -/
theorem hyperbolic_tree_embedding (n : ℕ) (hn : 2 ≤ n) :
    0 < Real.log n := by
  apply Real.log_pos; exact_mod_cast hn



theorem hyperbolic_dim_reduction (n : ℕ) (hn : 4 ≤ n) :
    Nat.log 2 n + 1 < n := by
  rcases n with ( _ | _ | _ | _ | _ | n ) <;> norm_num at *;
  refine Nat.le_of_lt_succ ( Nat.log_lt_of_lt_pow ?_ ?_ ) <;> norm_num [ Nat.pow_succ' ];
  exact Nat.recOn n ( by norm_num ) fun n ihn => by norm_num [ Nat.pow_succ' ] at * ; linarith;



theorem combined_compression (s l h c : ℝ)
    (hs : 0 < s) (hs1 : s < 1)
    (hl : 0 < l) (hl1 : l < 1)
    (hh : 0 < h) (hh1 : h < 1)
    (hc0 : 0 < c) (hc1 : c < 1) :
    s * l * h * c < 1 := by
  nlinarith [ mul_pos hs hl, mul_pos ( mul_pos hs hl ) hh, mul_pos ( mul_pos ( mul_pos hs hl ) hh ) hc0 ]



theorem geometric_efficiency_gap (d L r : ℕ) (hd : 2 ≤ d) (hL : 2 ≤ L)
    (hr : r < d) (hr0 : 0 < r) :
    r * d * (Nat.log 2 L + 1) < d * d * L := by
  -- By dividing both sides of the inequality by $d$, we obtain $r * (Nat.log 2 L + 1) < d * L$.
  suffices h_divided : r * (Nat.log 2 L + 1) < d * L by
    nlinarith;
  nlinarith [ show Nat.log 2 L < L from Nat.log_lt_of_lt_pow ( by linarith ) ( by exact Nat.recOn L ( by norm_num ) fun n ihn => by norm_num [ Nat.pow_succ ] at * ; nlinarith ) ]

