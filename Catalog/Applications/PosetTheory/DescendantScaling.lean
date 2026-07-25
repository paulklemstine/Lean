import Mathlib

/-!
# The `n^{1/d}` scaling of descendant counts in random `d`-DAGs

For the random recursive DAG `G_n` with out-degree `d ≥ 2`, the number of descendants
`|D_n|` grows like `n^{1/d}`; this is precisely the normalisation appearing in the limit
law `|D_n| / n^{1/d} ⟶ Gamma(d, 1)` (Janson, 2023).

The mean growth is governed by a product of the form
`P_n(a) = ∏_{k=1}^n (1 + a/k)` with `a = 1/d`: each new vertex attaches to earlier
vertices, contributing a multiplicative factor `1 + a/k`.  This file proves, fully
formally, two facts about this product.

* `descProduct_gamma_closed_form` : the exact closed form
  `P_n(a) = Γ(n+1+a) / (Γ(1+a) · n!)`;
* `descProduct_div_rpow_tendsto` : the scaling limit
  `P_n(a) / n^a ⟶ 1 / Γ(1+a)` as `n → ∞`,

and specialises the latter to the `d`-DAG normalisation:

* `ddag_descProduct_scaling` : `P_n(1/d) / n^{1/d} ⟶ 1 / Γ(1 + 1/d)`.

In particular the correct scaling exponent is `1/d`, matching the statement of the limit
theorem, and the multiplicative constant is `1/Γ(1 + 1/d)`.
-/

open Real Filter Topology

namespace DDAG

/-- The mean-growth product `P_n(a) = ∏_{k=1}^n (1 + a/k)`. With `a = 1/d` its order of
growth is the descendant normalisation `n^{1/d}`. -/
noncomputable def descProduct (a : ℝ) (n : ℕ) : ℝ := ∏ k ∈ Finset.Icc 1 n, (1 + a / (k : ℝ))

@[simp] lemma descProduct_zero (a : ℝ) : descProduct a 0 = 1 := by
  simp [descProduct]

/--
The recursive step of the mean-growth product.
-/
lemma descProduct_succ (a : ℝ) (n : ℕ) :
    descProduct a (n + 1) = descProduct a n * (1 + a / (n + 1 : ℝ)) := by
  convert Finset.prod_Ioc_succ_top _ _ using 2 <;> norm_num

/--
**Exact closed form** for the mean-growth product in terms of the Gamma function:
`P_n(a) = Γ(n+1+a) / (Γ(1+a) · n!)`.
-/
theorem descProduct_gamma_closed_form {a : ℝ} (ha : 0 ≤ a) (n : ℕ) :
    descProduct a n = Real.Gamma (n + 1 + a) / (Real.Gamma (1 + a) * n.factorial) := by
  induction' n with n ih;
  · simp +zetaDelta at *;
    rw [ div_self <| ne_of_gt <| Real.Gamma_pos_of_pos <| by positivity ];
  · simp_all +decide [ Nat.factorial_succ, descProduct_succ ];
    rw [ show ( n : ℝ ) + 1 + 1 + a = ( n : ℝ ) + 1 + a + 1 by ring,
      Real.Gamma_add_one ( by positivity ), div_mul_eq_mul_div ]
    field_simp

/--
Relation between the mean-growth product and Mathlib's `Real.GammaSeq`:
`P_n(a) = n^a / (a · GammaSeq a n)` for `n ≥ 1`.
-/
lemma descProduct_eq_gammaSeq {a : ℝ} (ha : 0 < a) {n : ℕ} (hn : 1 ≤ n) :
    descProduct a n = (n : ℝ) ^ a / (a * Real.GammaSeq a n) := by
  have h_gamma_seq : Real.GammaSeq a n = (n : ℝ) ^ a * Nat.factorial n / (∏ j ∈ Finset.range (n + 1), (a + j)) := by
    rw [ Real.GammaSeq, Finset.prod_range_succ' ];
  -- By definition of `descProduct`, we have:
  have h_descProduct : descProduct a n = (∏ k ∈ Finset.Icc 1 n, (a + k)) / (Nat.factorial n) := by
    unfold descProduct;
    rw [ Finset.prod_congr rfl fun x hx => by rw [ one_add_div ( by norm_cast; linarith [ Finset.mem_Icc.mp hx ] ) ] ];
    norm_num [ add_comm, Finset.prod_div_distrib ];
    erw [ ← Nat.cast_prod, Finset.prod_Ico_id_eq_factorial ];
  have h_prod_range : ∏ j ∈ Finset.range (n + 1), (a + j) = a * ∏ k ∈ Finset.Icc 1 n, (a + k) := by
    erw [ Finset.prod_Ico_eq_prod_range ] ; norm_num [ add_comm, mul_comm, Finset.prod_range_succ' ];
  simp_all +decide [ div_eq_mul_inv, mul_assoc, mul_comm, mul_left_comm ];
  simp +decide [ ha.ne', ne_of_gt ( Real.rpow_pos_of_pos ( Nat.cast_pos.mpr hn ) _ ) ]

/--
**Scaling limit**: `P_n(a) / n^a ⟶ 1 / Γ(1+a)` as `n → ∞`.
-/
theorem descProduct_div_rpow_tendsto {a : ℝ} (ha : 0 < a) :
    Tendsto (fun n : ℕ => descProduct a n / (n : ℝ) ^ a) atTop
      (𝓝 (1 / Real.Gamma (1 + a))) := by
  -- For n ≥ 1, by descProduct_eq_gammaSeq ha (hn), descProduct a n = (n:ℝ)^a/(a * Real.GammaSeq a n), and (n:ℝ)^a ≠ 0 since n ≥ 1 (Real.rpow_pos_of_pos with 0 < (n:ℝ)). So descProduct a n / (n:ℝ)^a = 1/(a*Real.GammaSeq a n) (field_simp).
  have h_eventually : ∀ᶠ n in Filter.atTop, descProduct a n / n ^ a = 1 / (a * Real.GammaSeq a n) := by
    filter_upwards [ Filter.eventually_ge_atTop 1 ] with n hn using by
      have hn' : (n : ℝ) ^ a ≠ 0 := ne_of_gt (Real.rpow_pos_of_pos (Nat.cast_pos.mpr hn) a)
      rw [ descProduct_eq_gammaSeq ha ( mod_cast hn ) ]
      field_simp
  rw [ Filter.tendsto_congr' h_eventually ];
  convert tendsto_const_nhds.div ( tendsto_const_nhds.mul ( Real.GammaSeq_tendsto_Gamma a ) ) _ using 2;
  · rw [ add_comm, Real.Gamma_add_one ha.ne' ];
  · positivity

/--
**The `d`-DAG descendant scaling.** For out-degree `d ≥ 1`, the mean-growth product
with `a = 1/d` satisfies `P_n(1/d) / n^{1/d} ⟶ 1 / Γ(1 + 1/d)`.  The scaling exponent is
`1/d`, exactly the normalisation in the descendant limit law.
-/
theorem ddag_descProduct_scaling {d : ℝ} (hd : 1 ≤ d) :
    Tendsto (fun n : ℕ => descProduct (1 / d) n / (n : ℝ) ^ (1 / d)) atTop
      (𝓝 (1 / Real.Gamma (1 + 1 / d))) := by
  convert descProduct_div_rpow_tendsto _;
  positivity

end DDAG