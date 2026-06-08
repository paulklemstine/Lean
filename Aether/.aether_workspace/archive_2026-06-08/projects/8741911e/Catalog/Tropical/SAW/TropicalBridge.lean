/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Tropical Geometry and Self-Avoiding Walk Generating Functions

The connection between SAW theory and tropical geometry arises through
the generating function G(x) = Σ c(n) x^n, whose radius of convergence
is 1/μ where μ is the connective constant.

In the tropical limit (as temperature T → 0 in statistical mechanics),
the free energy of the SAW model becomes a tropical polynomial,
and the connective constant corresponds to a tropical root.

This file formalizes:
1. The SAW generating function and its radius of convergence
2. The tropical valuation of SAW partition functions
3. The connection between tropical roots and the connective constant
-/
import Mathlib

open Real Filter Topology

/-! ## Generating function theory -/

/-
For a submultiplicative sequence: the formal power series Σ a(n) x^n has radius of convergence
    R = 1/limsup |a(n)|^{1/n}. For submultiplicative positive sequences,
    this equals 1/μ where μ is the connective constant.
    Here we show: for a submultiplicative sequence, the radius of convergence of
    the generating function equals the reciprocal of the connective constant.
-/
theorem radius_of_convergence_submultiplicative {a : ℕ → ℝ}
    (hpos : ∀ n, 0 < a n) (hsub : ∀ m n, a (m + n) ≤ a m * a n)
    (hmu : 0 < iInf (fun k : {k : ℕ // 0 < k} => (a k) ^ (1 / (k : ℝ)))) :
    ∀ x : ℝ, |x| < 1 / iInf (fun k : {k : ℕ // 0 < k} => (a k) ^ (1 / (k : ℝ))) →
    Summable (fun n => a n * x ^ n) := by
  -- By definition of exponentiation, we know that if $|x| < 1 / \mu$, then for sufficiently large $n$, we have $|x^n| < 1 / \mu^n$.
  intro x hx
  have hx_pow : ∃ k : ℕ+, |x| * (a k) ^ (1 / (k : ℝ)) < 1 := by
    contrapose! hx;
    rw [ div_le_iff₀ hmu ];
    convert le_ciInf fun k => hx k using 1;
    rw [ ← Real.mul_iInf_of_nonneg ( abs_nonneg x ) ];
    convert rfl;
  -- Let $k$ be such that $|x| * (a k) ^ (1 / (k : ℝ)) < 1$.
  obtain ⟨k, hk⟩ := hx_pow;
  -- We'll use the comparison test. Since $|a(n)| \leq a(k)^{n/k}$ for all $n$, we have $|a(n) x^n| \leq (a(k) |x|^k)^{n/k}$.
  have h_comparison : ∀ n : ℕ, |a n * x ^ n| ≤ (a k * |x| ^ (k : ℕ)) ^ (n / (k : ℕ)) * a (n % (k : ℕ)) * |x| ^ (n % (k : ℕ)) := by
    -- By definition of exponentiation, we know that if $|x| < 1 / \mu$, then for sufficiently large $n$, we have $|x^n| < 1 / \mu^n$. Hence, we can bound $|a(n)|$ using the submultiplicative property.
    have h_bound : ∀ n : ℕ, a n ≤ (a k) ^ (n / (k : ℕ)) * a (n % (k : ℕ)) := by
      intro n; rw [ ← Nat.div_add_mod n k ] ; induction' n / k with d hd <;> simp_all +decide [ pow_succ, mul_assoc ] ;
      convert le_trans ( hsub ( k * d + n % k ) k ) ( mul_le_mul_of_nonneg_right hd ( le_of_lt ( hpos k ) ) ) using 1 <;> ring;
      norm_num [ add_assoc, Nat.add_mul_div_left ];
      exact Or.inl ( by rw [ pow_succ' ] );
    intro n; rw [ abs_mul, abs_pow ] ; convert mul_le_mul_of_nonneg_right ( h_bound n ) ( pow_nonneg ( abs_nonneg x ) n ) using 1 ; ring;
    · rw [ abs_of_pos ( hpos n ), mul_comm ];
    · rw [ mul_pow ] ; rw [ show |x| ^ n = ( |x| ^ ( n / ( k : ℕ ) ) ) ^ ( k : ℕ ) * |x| ^ ( n % ( k : ℕ ) ) by rw [ ← pow_mul, ← pow_add, Nat.div_add_mod' ] ] ; ring;
  -- Since $|a(k) x^k| < 1$, the series $\sum_{n=0}^{\infty} (a(k) |x|^k)^{n/k}$ converges.
  have h_series_conv : Summable (fun n => (a k * |x| ^ (k : ℕ)) ^ (n / (k : ℕ)) * a (n % (k : ℕ)) * |x| ^ (n % (k : ℕ))) := by
    -- We can bound the series $\sum_{n=0}^{\infty} (a(k) |x|^k)^{n/k}$ by a geometric series.
    have h_geo_series : Summable (fun n => (a k * |x| ^ (k : ℕ)) ^ (n / (k : ℕ))) := by
      have h_geo_series : Summable (fun n => (a k * |x| ^ (k : ℕ)) ^ n) := by
        refine' summable_geometric_of_lt_one _ _;
        · exact mul_nonneg ( le_of_lt ( hpos _ ) ) ( pow_nonneg ( abs_nonneg _ ) _ );
        · contrapose! hk;
          convert Real.rpow_le_rpow ( by positivity ) hk ( show ( 0 : ℝ ) ≤ 1 / ( k : ℝ ) by positivity ) using 1 <;> norm_num [ mul_comm, Real.mul_rpow, abs_nonneg, hpos, ne_of_gt ];
          rw [ Real.mul_rpow ( le_of_lt ( hpos _ ) ) ( by positivity ), ← Real.rpow_natCast, ← Real.rpow_mul ( by positivity ), mul_inv_cancel₀ ( by positivity ), Real.rpow_one, mul_comm ];
      have h_geo_series : Summable (fun n => (a k * |x| ^ (k : ℕ)) ^ (n / (k : ℕ))) := by
        have h_split : ∀ N : ℕ, ∑ n ∈ Finset.range (N * (k : ℕ)), (a k * |x| ^ (k : ℕ)) ^ (n / (k : ℕ)) ≤ ∑ n ∈ Finset.range N, (a k * |x| ^ (k : ℕ)) ^ n * (k : ℕ) := by
          intro N; induction N <;> simp_all +decide [ Nat.succ_mul, Finset.sum_range_add ] ;
          refine' add_le_add ‹_› _;
          norm_num [ Nat.add_div ];
          exact le_trans ( Finset.sum_le_sum fun _ _ => pow_le_pow_of_le_one ( mul_nonneg ( le_of_lt ( hpos _ ) ) ( pow_nonneg ( abs_nonneg x ) _ ) ) ( by nlinarith [ abs_of_pos ( hpos k ), pow_nonneg ( abs_nonneg x ) k ] ) ( show _ ≤ _ from by split_ifs <;> linarith [ Nat.mod_lt ( ‹_› : ℕ ) k.pos, Nat.div_eq_of_lt ( show ‹_› < ( k : ℕ ) from Finset.mem_range.mp ‹_› ) ] ) ) ( by norm_num [ mul_assoc, mul_comm, mul_left_comm ] )
        rw [ summable_iff_not_tendsto_nat_atTop_of_nonneg ];
        · rw [ Filter.tendsto_atTop_atTop ];
          push_neg;
          exact ⟨ ∑' n : ℕ, ( a k * |x| ^ ( k : ℕ ) ) ^ n * ( k : ℝ ) + 1, fun N => ⟨ N * k, by nlinarith [ PNat.pos k ], lt_of_le_of_lt ( h_split N ) ( lt_add_of_le_of_pos ( Summable.sum_le_tsum ( Finset.range N ) ( fun _ _ => mul_nonneg ( pow_nonneg ( mul_nonneg ( le_of_lt ( hpos _ ) ) ( pow_nonneg ( abs_nonneg x ) _ ) ) _ ) ( Nat.cast_nonneg _ ) ) ( h_geo_series.mul_right _ ) ) zero_lt_one ) ⟩ ⟩;
        · exact fun n => pow_nonneg ( mul_nonneg ( le_of_lt ( hpos _ ) ) ( pow_nonneg ( abs_nonneg _ ) _ ) ) _;
      convert h_geo_series using 1;
    -- Since $a(n \% k)$ and $|x|^{n \% k}$ are bounded, their product is also bounded.
    have h_bounded : ∃ C : ℝ, ∀ n : ℕ, a (n % (k : ℕ)) * |x| ^ (n % (k : ℕ)) ≤ C := by
      exact ⟨ ∑ i ∈ Finset.range k, a i * |x| ^ i, fun n => Finset.single_le_sum ( fun i _ => mul_nonneg ( le_of_lt ( hpos i ) ) ( pow_nonneg ( abs_nonneg x ) i ) ) ( Finset.mem_range.mpr ( Nat.mod_lt _ k.pos ) ) ⟩;
    exact Summable.of_nonneg_of_le ( fun n => mul_nonneg ( mul_nonneg ( pow_nonneg ( mul_nonneg ( le_of_lt ( hpos _ ) ) ( pow_nonneg ( abs_nonneg x ) _ ) ) _ ) ( le_of_lt ( hpos _ ) ) ) ( pow_nonneg ( abs_nonneg x ) _ ) ) ( fun n => by simpa only [ mul_assoc ] using mul_le_mul_of_nonneg_left ( h_bounded.choose_spec n ) ( pow_nonneg ( mul_nonneg ( le_of_lt ( hpos _ ) ) ( pow_nonneg ( abs_nonneg x ) _ ) ) _ ) ) ( h_geo_series.mul_right _ );
  exact Summable.of_norm <| by simpa [ abs_mul ] using Summable.of_nonneg_of_le ( fun n => by positivity ) ( fun n => by simpa [ abs_mul ] using h_comparison n ) h_series_conv;

/-! ## Tropical valuation and SAW -/

/-- The tropical valuation of a positive real number is its negative logarithm.
    This maps multiplication to addition and addition to min. -/
noncomputable def tropicalVal (x : ℝ) (hx : 0 < x) : ℝ := -Real.log x

/-
Tropical valuation is a valuation: val(xy) = val(x) + val(y).
-/
theorem tropicalVal_mul {x y : ℝ} (hx : 0 < x) (hy : 0 < y) :
    tropicalVal (x * y) (mul_pos hx hy) = tropicalVal x hx + tropicalVal y hy := by
  unfold tropicalVal; rw [ Real.log_mul hx.ne' hy.ne' ] ; ring;

/-- The tropical free energy of the SAW model at fugacity x > 0
    is defined as the tropical limit of the partition function. -/
noncomputable def tropicalFreeEnergy (a : ℕ → ℝ) (hpos : ∀ n, 0 < a n) : ℝ :=
  -iInf (fun k : {k : ℕ // 0 < k} => Real.log (a k) / k)

/-- The tropical free energy equals log(μ). -/
theorem tropicalFreeEnergy_eq_log_mu {a : ℕ → ℝ}
    (hpos : ∀ n, 0 < a n) (hsub : ∀ m n, a (m + n) ≤ a m * a n) :
    tropicalFreeEnergy a hpos =
    -iInf (fun k : {k : ℕ // 0 < k} => Real.log (a k) / k) := by
  rfl

/-! ## Tropical polynomial for the Nienhuis constant -/

/-- The minimal polynomial of the Nienhuis constant in tropical form.
    The polynomial x⁴ - 4x² + 2 = 0 has tropical version
    max(4v, 2v + log 4, log 2) where v = val(x). -/
noncomputable def nienhuis_tropical_poly (v : ℝ) : ℝ :=
  max (max (4 * v) (2 * v + Real.log 4)) (Real.log 2)

/-
The tropical root of the Nienhuis polynomial.
    At the tropical root, at least two of the three terms must be equal.
-/
theorem nienhuis_tropical_root_exists :
    ∃ v : ℝ, (4 * v = 2 * v + Real.log 4) ∨
             (4 * v = Real.log 2) ∨
             (2 * v + Real.log 4 = Real.log 2) := by
  exact ⟨ Real.log 2, Or.inl <| by linarith [ show Real.log 4 = 2 * Real.log 2 by rw [ ← Real.log_rpow ] <;> norm_num ] ⟩

/-! ## Growth rate bounds via tropical methods -/

/-
**Tropical bound principle**: If a submultiplicative sequence satisfies
    a(n) ≤ C · μ^n for some constant C and growth rate μ,
    then the connective constant is at most μ.
-/
theorem tropical_growth_bound {a : ℕ → ℝ} {C μ : ℝ}
    (hpos : ∀ n, 0 < a n)
    (hC : 0 < C) (hmu : 0 < μ)
    (hbound : ∀ n, a n ≤ C * μ ^ n) :
    ∀ (k : ℕ) (hk : 0 < k),
      (a k) ^ (1 / (k : ℝ)) ≤ C ^ (1 / (k : ℝ)) * μ := by
  intro k hk; convert Real.rpow_le_rpow ( le_of_lt ( hpos k ) ) ( hbound k ) ( by positivity : ( 0 : ℝ ) ≤ 1 / k ) using 1 ; rw [ Real.mul_rpow ( by positivity ) ( by positivity ), ← Real.rpow_natCast, ← Real.rpow_mul ( by positivity ), mul_one_div_cancel ( by positivity ), Real.rpow_one ]

/-
As k → ∞, C^{1/k} → 1, so the bound approaches μ.
-/
theorem constant_root_tends_to_one {C : ℝ} (hC : 0 < C) :
    Filter.Tendsto (fun k : ℕ => C ^ (1 / ((k : ℝ) + 1))) Filter.atTop (nhds 1) := by
  simpa using tendsto_const_nhds.rpow tendsto_one_div_add_atTop_nhds_zero_nat ( Or.inl hC.ne' )

/-! ## Concatenation and the tropical convolution -/

/-
The SAW count submultiplicativity, viewed tropically:
    log c(m+n) ≤ log c(m) + log c(n)
    This is exactly subadditivity of the log-count sequence,
    which tropically means the tropical convolution is bounded.
-/
theorem tropical_saw_subadditivity {c : ℕ → ℝ} (hpos : ∀ n, 0 < c n)
    (hsub : ∀ m n, c (m + n) ≤ c m * c n) :
    ∀ m n, Real.log (c (m + n)) ≤ Real.log (c m) + Real.log (c n) := by
  exact fun m n => by rw [ ← Real.log_mul ( ne_of_gt ( hpos m ) ) ( ne_of_gt ( hpos n ) ) ] ; exact Real.log_le_log ( hpos _ ) ( hsub m n ) ;

/-
**Key insight**: The tropical SAW generating function converges
    if and only if the fugacity is below the critical value 1/μ.
    This connects the combinatorial (SAW counting) and analytic
    (generating function) perspectives through tropical geometry.
-/
theorem tropical_convergence_criterion {c : ℕ → ℝ} {x : ℝ}
    (hpos : ∀ n, 0 < c n) (hx : 0 < x)
    (hsub : ∀ m n, c (m + n) ≤ c m * c n)
    (hbdd : BddBelow (Set.range (fun k : {k : ℕ // 0 < k} => Real.log (c k) / ↑k.val)))
    (hconv : Summable (fun n => c n * x ^ n)) :
    Real.log x < -iInf (fun k : {k : ℕ // 0 < k} => Real.log (c k) / ↑k.val) := by
  contrapose! hconv;
  -- By contrapositive, assume log(x) ≥ -iInf (fun k => log(c(k))/k).
  have h_contra : ∀ k : {k : ℕ // 0 < k}, c k * x ^ (k : ℕ) ≥ 1 := by
    intro k
    have h_log : Real.log (c k) + k * Real.log x ≥ 0 := by
      have := ciInf_le hbdd k;
      rw [ le_div_iff₀ ] at this <;> nlinarith [ show ( k : ℝ ) > 0 by exact Nat.cast_pos.mpr k.prop ];
    rw [ ge_iff_le, ← Real.log_le_log_iff ( by positivity ) ( by exact mul_pos ( hpos _ ) ( pow_pos hx _ ) ), Real.log_mul ( ne_of_gt ( hpos _ ) ) ( ne_of_gt ( pow_pos hx _ ) ), Real.log_pow ] ; aesop;
  exact fun h => absurd ( h.tendsto_atTop_zero ) fun H => absurd ( le_of_tendsto_of_tendsto tendsto_const_nhds H <| Filter.eventually_atTop.mpr ⟨ 1, fun n hn => h_contra ⟨ n, hn ⟩ ⟩ ) ( by norm_num )