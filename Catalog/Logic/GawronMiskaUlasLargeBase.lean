import Logic.GawronMiskaUlasBase

/-!
# Unboundedness in the large-base regime `b ≥ m`

`GawronMiskaUlasBase.lean` settles the exponent `m = 2` for **every** base `b ≥ 2`.
Here we settle, dually, **every** exponent `m` once the base is large enough,
`b ≥ m`: at the base-`b` repunits `R_k` we get the clean closed form

`T_{b,m}(R_k) = (−m)^k`,

so `|T_{b,m}(R_k)| = m^k → ∞` whenever `m ≥ 2`.  Together the two files cover the
Gawron–Miska–Ulas conjecture on the union `{m = 2} ∪ {b ≥ m}` of the parameter range.

The mechanism refines the `m = 2` computation.  At `n = R_{k+1} = b·R_k + 1` the
Mahler factor `(1 − x)^m = Σ_j (−1)^j \binom{m}{j} x^j` contributes the coefficient at
`R_{k+1} − j`, which is divisible by `b` exactly when `j ≡ 1 (mod b)`.  For `0 ≤ j ≤ m`
and `b ≥ m` the **only** such `j` is `j = 1`, leaving `(−1)^1 \binom{m}{1} = −m`.

-- !-- Lab Notes — Cycle 3 (large-base regime) -- !--
-- !-- Hypothesis (Hypothesizer): the m=2 repunit doubling was an instance of a
--     general "single surviving binomial term" phenomenon. If b ≥ m, only j = 1 of
--     (1-x)^m aligns with the repunit residue, predicting T_{b,m}(R_k) = (-m)^k. -- !--
-- !-- Experiment (Experimenter): computed T_{b,m}(R_k); for b ≥ m it is exactly
--     (-m)^k (e.g. m=3,b∈{3,5}: 1,-3,9,-27,…; m=4,b=5: 1,-4,16,-64,…). For b < m
--     carries from j = 1 + b ≤ m spoil the identity (m=4,b=3 deviates), confirming
--     the b ≥ m threshold is sharp for this argument. -- !--
-- !-- Analysis (Analyst): need ((1-X)^m).coeff j = (-1)^j C(m,j) and an antidiagonal
--     collapse keyed on "j ≡ 1 mod b within [0,m] ⟺ j = 1" using b ≥ m. The b < m
--     residual is "true but harder" — it is the genuinely open part of the conjecture
--     (small base, large exponent), where m=2 (the other file) is the only easy column. -- !--
-- !-- Critique (Critic): the headline T_large_unbounded is a real ∀B∃n claim, proved
--     by induction through the functional equation; m ≥ 2 is load-bearing (m=1 is
--     bounded, see GawronMiskaUlasOne.lean). -- !--
-/

namespace GawronMiskaUlas

open Polynomial Finset

/-
Binomial coefficients of `(1 - X)^m`: `((1-X)^m).coeff j = (-1)^j · C(m,j)`.
-/
lemma coeff_one_sub_X_pow (m j : ℕ) :
    ((1 - X) ^ m : ℤ[X]).coeff j = (-1) ^ j * (m.choose j) := by
  rw [ sub_eq_add_neg, add_comm, add_pow ];
  by_cases hj : j ≤ m <;> simp_all +decide;
  · rw [ Finset.sum_eq_single j ] <;> simp_all +decide [ Polynomial.coeff_eq_zero_of_natDegree_lt ];
    · ring_nf;
      by_cases h : Even j <;> aesop;
    · intro k hk hk'; ring_nf;
      by_cases h : Even k <;> aesop;
  · rw [ Finset.sum_eq_zero ] <;> norm_num [ Nat.choose_eq_zero_of_lt hj ];
    exact fun x hx => Or.inl <| Polynomial.coeff_eq_zero_of_natDegree_lt <| by erw [ Polynomial.natDegree_pow, Polynomial.natDegree_neg, Polynomial.natDegree_X ] ; linarith;

/-
Repunit recurrence in the large-base regime: for `2 ≤ b` and `m ≤ b`,
`T_{b,m}(R_{k+1}) = -m · T_{b,m}(R_k)`.
-/
lemma T_repunit_step_large (b m k : ℕ) (hb : 2 ≤ b) (hmb : m ≤ b) :
    T b m (R b (k + 1)) = -(m : ℤ) * T b m (R b k) := by
  -- collapses with Finset.sum_eq_single (1, b*Rk):
  have h_sum : ∑ p ∈ Finset.antidiagonal (b * R b k + 1), ((1 - X) ^ m : ℤ[X]).coeff p.1 * ((expand ℤ b) (Tpoly b m (b * R b k))).coeff p.2 = ((1 - X) ^ m : ℤ[X]).coeff 1 * ((expand ℤ b) (Tpoly b m (b * R b k))).coeff (b * R b k) := by
    rw [ Finset.sum_eq_single ( 1, b * R b k ) ];
    · intro p hp hp';
      by_cases h : p.1 ≤ m <;> by_cases h' : b ∣ p.2 <;> simp_all +decide [ coeff_one_sub_X_pow ];
      · contrapose! hp';
        exact Prod.ext ( by obtain ⟨ q, hq ⟩ := h'; nlinarith [ show q = R b k by nlinarith ] ) ( by obtain ⟨ q, hq ⟩ := h'; nlinarith [ show q = R b k by nlinarith ] );
      · rw [ Polynomial.coeff_expand ] ; aesop;
        linarith;
      · exact Or.inl <| Nat.choose_eq_zero_of_lt h;
      · exact Or.inl <| Nat.choose_eq_zero_of_lt h;
    · simp +decide [ Finset.mem_antidiagonal ];
      exact fun h => False.elim <| h <| add_comm _ _;
  convert h_sum using 1;
  · rw [ show T b m ( R b ( k + 1 ) ) = ( Tpoly b m ( b * R b k + 1 ) |> Polynomial.coeff ) ( b * R b k + 1 ) from ?_, factor_succ ];
    · rw [ Polynomial.coeff_mul ];
    · exact GawronMiskaUlas.coeff_eq_of_le b m _ _ hb ( by linarith );
  · rw [ Polynomial.coeff_expand ];
    · rw [ coeff_one_sub_X_pow ] ; norm_num [ Nat.choose_one_right, Nat.mul_div_cancel_left _ ( by linarith : 0 < b ) ];
      exact Or.inl ( Eq.symm ( coeff_eq_of_le b m ( R b k ) ( b * R b k ) hb ( by nlinarith ) ) );
    · linarith

/-
Base value `T_{b,m}(0) = 1`.
-/
lemma T_zero (b m : ℕ) : T b m 0 = 1 := by
  unfold T;
  unfold Tpoly; norm_num;
  norm_num [ Polynomial.coeff_zero_eq_eval_zero ]

/-
**Closed form in the large-base regime**: `T_{b,m}(R_k) = (−m)^k` for `m ≤ b`.
-/
lemma T_repunit_large (b m k : ℕ) (hb : 2 ≤ b) (hmb : m ≤ b) :
    T b m (R b k) = (-(m : ℤ)) ^ k := by
  induction' k with k ih;
  · convert T_zero b m using 1;
    norm_num;
  · rw [ T_repunit_step_large b m k hb hmb, ih, pow_succ' ]

/-- Absolute value at a repunit: `|T_{b,m}(R_k)| = m^k` for `m ≤ b`. -/
lemma abs_T_repunit_large (b m k : ℕ) (hb : 2 ≤ b) (hmb : m ≤ b) :
    |T b m (R b k)| = (m : ℤ) ^ k := by
  rw [T_repunit_large b m k hb hmb, abs_pow, abs_neg, Nat.abs_cast]

/-
**Unboundedness for every exponent `m ≥ 2` in the large-base regime `b ≥ m`.**
-/
theorem T_large_unbounded (b m : ℕ) (hm : 2 ≤ m) (hmb : m ≤ b) (B : ℤ) :
    ∃ n, B < |T b m n| := by
  -- Choose k with B < (m:ℤ)^k, which exists because m ≥ 2 > 1 so (m:ℤ)^k is unbounded.
  obtain ⟨k, hk⟩ : ∃ k, B < (m : ℤ) ^ k := by
    exact pow_unbounded_of_one_lt _ <| mod_cast hm;
  exact ⟨ R b k, by rw [ abs_T_repunit_large b m k ( by linarith ) ( by linarith ) ] ; exact hk ⟩

end GawronMiskaUlas