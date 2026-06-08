/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

set_option linter.unusedSectionVars false
set_option linter.unusedSimpArgs false

/-!
# Closure of K=1 Valuated Exchange under Differentiation

This file establishes a differentiation-closure principle for the sharp constant K=1
valuated exchange condition on homogeneous weight functions with nonnegative values.
The central result is that differentiation of degree-2 homogeneous nonnegative weight
functions preserves the K=1 valuated exchange inequality, identifying a new
"minimal positivity" class sitting between raw discrete convexity and the full
Lorentzian package.

## Mathematical Context

The K=1 valuated exchange condition is a coefficient-level inequality inspired by
the tropical/M-convex exchange axiom from discrete convex analysis (Murota, 2003)
and the Lorentzian polynomial theory of Brändén–Huh (2020). We prove that this
condition is preserved under partial differentiation for degree-2 homogeneous
weight functions, establishing the first case of a conjectured general
derivative-stability principle.

## Main Definitions

* `totalDeg` — Total degree of an exponent vector
* `HomogeneousWt` — Homogeneity condition for weight functions
* `exchVec` — Exchange move on exponent vectors
* `ValExchOne` — K=1 valuated exchange condition
* `pdWeight` — Partial derivative weight transform
* `contrShadow` — Contraction shadow on support sets
* `MConvexSupp` — M-convex support condition
* `DerivStableValExchOne` — Derivative-stable K=1 exchange

## Main Results

* `valuatedExchangeOne_of_degree_one` — Degree-1 nonneg ⟹ K=1 exchange
* `valuatedExchangeOne_deriv_degree_two` — Degree-2 derivative closure
* `pdWeight_nonneg` — Derivative preserves nonnegativity
* `pdWeight_homogeneous` — Derivative drops degree by 1
* `support_pdWeight_subset_contrShadow` — Derivative support ⊆ contraction shadow
* `valuatedExchangeOne_smul` — Positive scaling preserves exchange

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Murota, "Discrete Convex Analysis", SIAM, 2003
-/

open Finset BigOperators Function

noncomputable section

namespace ValuatedMConvexDiff

variable {σ : Type*} [Fintype σ] [DecidableEq σ]

/-! ## Core Definitions -/

/-- Total degree of an exponent vector: the sum of all coordinates. -/
def totalDeg (m : σ → ℕ) : ℕ := ∑ i : σ, m i

/-- A weight function `w : (σ → ℕ) → ℝ` is **homogeneous of degree d** if every
    exponent vector in its support has total degree exactly `d`. -/
def HomogeneousWt (d : ℕ) (w : (σ → ℕ) → ℝ) : Prop :=
  ∀ m : σ → ℕ, w m ≠ 0 → totalDeg m = d

/-- **Exchange move** on exponent vectors: given `m : σ → ℕ` and coordinates `i, j`,
    decrease `m i` by 1 and increase `m j` by 1. When `i ≠ j`, this corresponds to
    the matroid basis exchange operation at the exponent level. -/
def exchVec (m : σ → ℕ) (i j : σ) : σ → ℕ :=
  fun k => if k = i then m i - 1 else if k = j then m j + 1 else m k

/-- **K=1 Valuated Exchange condition**: for any two support vectors `α, β` and any
    coordinate `i` with `α i > β i`, there exists a coordinate `j ≠ i` with
    `β j > α j` such that the exchange preserves the product inequality:
    `w(exchVec α i j) · w(exchVec β j i) ≥ w(α) · w(β)`.

    This is the sharp (K=1) version of the tropical exchange inequality. -/
def ValExchOne (w : (σ → ℕ) → ℝ) : Prop :=
  ∀ α β : σ → ℕ, w α > 0 → w β > 0 →
    ∀ i : σ, α i > β i →
      ∃ j : σ, j ≠ i ∧ β j > α j ∧
        w (exchVec α i j) * w (exchVec β j i) ≥ w α * w β

/-- **Partial derivative weight transform**: the coefficient of the partial derivative
    `∂/∂xᵢ` of a polynomial with weight function `w`. The formula
    `(∂ᵢw)(m) = (m(i)+1) · w(m + eᵢ)` encodes the product rule for monomials. -/
def pdWeight (i : σ) (w : (σ → ℕ) → ℝ) : (σ → ℕ) → ℝ :=
  fun m => (↑(m i + 1) : ℝ) * w (Function.update m i (m i + 1))

/-- **Contraction shadow** of a support set `S` at coordinate `i`: the set of
    exponent vectors obtained by subtracting `eᵢ` from vectors in `S` that have
    `m(i) ≥ 1`. Equivalently, `{m | m + eᵢ ∈ S}`. This is the exponent-level
    analogue of matroid contraction. -/
def contrShadow (i : σ) (S : Set (σ → ℕ)) : Set (σ → ℕ) :=
  {m | Function.update m i (m i + 1) ∈ S}

/-- **M-convex support**: the symmetric exchange property on support, asserting that
    for any two support vectors and any coordinate where the first exceeds the second,
    there exists a complementary coordinate for a valid exchange move. -/
def MConvexSupp (w : (σ → ℕ) → ℝ) : Prop :=
  ∀ α β : σ → ℕ, w α ≠ 0 → w β ≠ 0 →
    ∀ i : σ, α i > β i →
      ∃ j : σ, j ≠ i ∧ β j > α j ∧
        w (exchVec α i j) ≠ 0 ∧ w (exchVec β j i) ≠ 0

/-- **Derivative-stable K=1 valuated exchange**: both the weight function and all
    its first partial derivatives satisfy the K=1 exchange inequality. This is the
    key new positivity class whose closure under differentiation we establish. -/
def DerivStableValExchOne (w : (σ → ℕ) → ℝ) : Prop :=
  ValExchOne w ∧ ∀ i : σ, ValExchOne (pdWeight i w)

/-! ## Exchange Vector Simplification Lemmas -/

@[simp]
theorem exchVec_at_i (m : σ → ℕ) (i j : σ) :
    exchVec m i j i = m i - 1 := by
  simp [exchVec]

@[simp]
theorem exchVec_at_j (m : σ → ℕ) (i j : σ) (hij : j ≠ i) :
    exchVec m i j j = m j + 1 := by
  simp [exchVec, hij]

@[simp]
theorem exchVec_at_other (m : σ → ℕ) (i j k : σ) (hki : k ≠ i) (hkj : k ≠ j) :
    exchVec m i j k = m k := by
  simp [exchVec, hki, hkj]

/-! ## Key Helper Lemma: Unit Vector Characterization -/

/-
If a function `f : σ → ℕ` sums to 1 over a finite type, then exactly one
    coordinate is 1 and all others are 0. This is the fundamental structure
    lemma for degree-1 exponent vectors.
-/
theorem exists_eq_one_of_sum_eq_one (f : σ → ℕ) (hf : ∑ i : σ, f i = 1) :
    ∃ a : σ, f a = 1 ∧ ∀ k : σ, k ≠ a → f k = 0 := by
  -- Since ∑ f = 1 > 0, there exists a with f a > 0 (by Finset.exists_ne_zero or similar).
  obtain ⟨a, ha⟩ : ∃ a, f a > 0 := by
    contrapose! hf; aesop;
  exact ⟨ a, by linarith [ Finset.single_le_sum ( fun i _ => Nat.zero_le ( f i ) ) ( Finset.mem_univ a ) ], fun k hk => Nat.eq_zero_of_not_pos fun hk' => by have := hf ▸ Finset.sum_eq_add_sum_diff_singleton ( Finset.mem_univ a ) f; linarith [ Finset.single_le_sum ( fun i _ => Nat.zero_le ( f i ) ) ( Finset.mem_sdiff.mpr ⟨ Finset.mem_univ k, by aesop ⟩ : k ∈ Finset.univ \ { a } ) ] ⟩

/-
Exchange of unit vectors: if `α` is 1 at `i` and 0 elsewhere, and `β` is 1
    at `j` and 0 elsewhere (with `i ≠ j`), then exchanging `α` at `(i, j)`
    produces `β` and vice versa.
-/
theorem unit_exchVec_swap (i j : σ) (hij : i ≠ j)
    (α : σ → ℕ) (hαi : α i = 1) (hαk : ∀ k, k ≠ i → α k = 0)
    (β : σ → ℕ) (hβj : β j = 1) (hβk : ∀ k, k ≠ j → β k = 0) :
    exchVec α i j = β ∧ exchVec β j i = α := by
  constructor <;> ext k <;> by_cases hi : k = i <;> by_cases hj : k = j <;> simp_all +decide [ exchVec ]

/-! ## Theorem 1: Derivative Preserves Nonnegativity -/

/-
Partial differentiation of a nonnegative weight function produces a nonnegative
    weight function. The derivative coefficient `(m(i)+1) · w(m + eᵢ)` is a product
    of a positive natural number and a nonnegative weight.
-/
theorem pdWeight_nonneg (w : (σ → ℕ) → ℝ) (hw : ∀ m, 0 ≤ w m) (i : σ) :
    ∀ m, 0 ≤ pdWeight i w m := by
  exact fun m => mul_nonneg ( Nat.cast_nonneg _ ) ( hw _ )

/-! ## Theorem 2: Derivative Drops Degree by 1 -/

/-
Partial differentiation of a degree-`d` homogeneous weight function produces
    a degree-`(d-1)` homogeneous weight function. This follows from the shift
    `m + eᵢ` having total degree `totalDeg m + 1`.
-/
theorem pdWeight_homogeneous (w : (σ → ℕ) → ℝ) (d : ℕ) (hd : 1 ≤ d)
    (hw : HomogeneousWt d w) (i : σ) :
    HomogeneousWt (d - 1) (pdWeight i w) := by
  intro m hm;
  -- By definition of $pdWeight$, we know that $w(update m i (m i + 1)) \neq 0$.
  have h_w_update : w (Function.update m i (m i + 1)) ≠ 0 := by
    exact fun h => hm <| by unfold pdWeight; aesop;
  have := hw _ h_w_update;
  simp_all +decide [ totalDeg, Finset.sum_update_of_mem ];
  exact eq_tsub_of_add_eq ( by rw [ ← this, Finset.sum_eq_add_sum_diff_singleton ( Finset.mem_univ i ) ] ; ring )

/-! ## Theorem 3: Degree-1 K=1 Valuated Exchange (Deep) -/

/-
**Degree-1 exchange theorem**: Every nonnegative homogeneous weight function
    of degree 1 satisfies K=1 valuated exchange. This is the anchor case for
    the derivative closure principle.

    **Proof sketch**: In degree 1, every support vector is a unit vector `eₐ`
    (1 at coordinate `a`, 0 elsewhere). For any `α = eᵢ, β = eⱼ` with `i ≠ j`
    and `α i > β i`, the exchange at `(i, j)` simply swaps them:
    `exchVec(eᵢ, i, j) = eⱼ` and `exchVec(eⱼ, j, i) = eᵢ`. Therefore
    `w(exchVec α i j) · w(exchVec β j i) = w(β) · w(α) = w(α) · w(β)`,
    giving exact equality in the exchange inequality.
-/
theorem valuatedExchangeOne_of_degree_one (w : (σ → ℕ) → ℝ)
    (hw_nonneg : ∀ m, 0 ≤ w m)
    (hw_hom : HomogeneousWt 1 w) :
    ValExchOne w := by
  intro α β hα hβ i hii;
  -- By hw_hom, totalDeg α = 1 and totalDeg β = 1.
  have h_deg_alpha : ∑ k, α k = 1 := by
    exact hw_hom α ( ne_of_gt hα )
  have h_deg_beta : ∑ k, β k = 1 := by
    exact hw_hom β ( ne_of_gt hβ ) ▸ rfl
  generalize_proofs at *; simp_all +decide [ Finset.sum_eq_zero_iff_of_nonneg ] ;
  -- By exists_eq_one_of_sum_eq_one, there exists a unique index a such that α a = 1 and α k = 0 for all k ≠ a.
  obtain ⟨a, ha⟩ : ∃ a : σ, α a = 1 ∧ ∀ k : σ, k ≠ a → α k = 0 := exists_eq_one_of_sum_eq_one α h_deg_alpha
  obtain ⟨b, hb⟩ : ∃ b : σ, β b = 1 ∧ ∀ k : σ, k ≠ b → β k = 0 := exists_eq_one_of_sum_eq_one β h_deg_beta
  generalize_proofs at *; simp_all +decide [ Finset.sum_eq_zero_iff_of_nonneg ] ;
  by_cases hi : i = a <;> by_cases hj : i = b <;> simp_all +decide [ Finset.sum_eq_zero_iff_of_nonneg ] ;
  use b; simp_all +decide [ Finset.sum_eq_zero_iff_of_nonneg ] ;
  have h_exch : exchVec α a b = β ∧ exchVec β b a = α := by
    exact unit_exchVec_swap a b hj α ha.1 ha.2 β hb.1 hb.2 |> fun h => ⟨ h.1, h.2 ⟩
  generalize_proofs at *; simp_all +decide [ Finset.sum_eq_zero_iff_of_nonneg ] ;
  exact ⟨ Ne.symm hj, ha.2 b ( Ne.symm hj ), by linarith ⟩

/-! ## Theorem 4: Degree-2 Derivative Closure (Main Result) -/

/-
**Degree-2 derivative closure theorem**: For any nonnegative homogeneous
    weight function of degree 2 satisfying K=1 valuated exchange, every partial
    derivative also satisfies K=1 valuated exchange.

    **Proof**: The partial derivative `∂ᵢw` is nonnegative (by `pdWeight_nonneg`)
    and homogeneous of degree 1 (by `pdWeight_homogeneous`). By the degree-1
    exchange theorem (`valuatedExchangeOne_of_degree_one`), it satisfies K=1
    valuated exchange.

    This is the first nontrivial case of the conjectured general derivative
    closure principle, showing that the mechanism is not accidental but
    geometric: differentiation of degree-2 polynomials produces linear
    polynomials whose exchange structure is automatic.
-/
theorem valuatedExchangeOne_deriv_degree_two (w : (σ → ℕ) → ℝ)
    (hw_nonneg : ∀ m, 0 ≤ w m)
    (hw_hom : HomogeneousWt 2 w)
    (_hw_mconvex : MConvexSupp w)
    (_hw_vx : ValExchOne w) :
    ∀ i : σ, ValExchOne (pdWeight i w) := by
  intro i
  apply valuatedExchangeOne_of_degree_one
  · exact pdWeight_nonneg w hw_nonneg i
  · exact (pdWeight_homogeneous w 2 (by omega) hw_hom i)

/-! ## Theorem 5: Derivative Support ⊆ Contraction Shadow -/

/-
The support of the derivative weight function is contained in the contraction
    shadow of the original support. Equivalently, if `(∂ᵢw)(m) ≠ 0`, then
    `w(m + eᵢ) ≠ 0`, so `m + eᵢ` is in the original support.
-/
theorem support_pdWeight_subset_contrShadow (w : (σ → ℕ) → ℝ) (i : σ) :
    {m | pdWeight i w m ≠ 0} ⊆ contrShadow i {m | w m ≠ 0} := by
  simp +decide [ pdWeight, contrShadow ]

/-! ## Theorem 6: Positive Scaling Preserves K=1 Exchange -/

/-
Scaling a weight function by a positive constant preserves the K=1 exchange
    condition. Both sides of the inequality scale by `c²`, preserving the
    direction of the inequality.
-/
theorem valuatedExchangeOne_smul (w : (σ → ℕ) → ℝ) (c : ℝ) (hc : 0 < c)
    (hw : ValExchOne w) :
    ValExchOne (fun m => c * w m) := by
  intro α β hα hβ i hi;
  rcases hw α β ( by nlinarith ) ( by nlinarith ) i hi with ⟨ j, hj₁, hj₂, hj₃ ⟩ ; exact ⟨ j, hj₁, hj₂, by nlinarith [ mul_pos hc hc ] ⟩

/-! ## Degree-0 Base Case -/

/-
Degree-0 weight functions vacuously satisfy K=1 exchange: if `totalDeg α = 0`
    and `totalDeg β = 0`, then `α = β = 0`, so `α i = β i` for all `i`,
    and the condition `α i > β i` can never hold.
-/
theorem valuatedExchangeOne_of_degree_zero (w : (σ → ℕ) → ℝ)
    (hw_nonneg : ∀ m, 0 ≤ w m)
    (hw_hom : HomogeneousWt 0 w) :
    ValExchOne w := by
  intro α β hα hβ i hi;
  have := hw_hom α hα.ne'; have := hw_hom β hβ.ne'; simp_all +decide [ totalDeg ]

/-! ## Cross-Domain: DerivStable Class Properties -/

/-- **Degree-2 derivative stability**: Any nonneg degree-2 weight function with
    M-convex support and K=1 exchange belongs to the derivative-stable class. -/
theorem derivStable_of_degree_two (w : (σ → ℕ) → ℝ)
    (hw_nonneg : ∀ m, 0 ≤ w m)
    (hw_hom : HomogeneousWt 2 w)
    (hw_mconvex : MConvexSupp w)
    (hw_vx : ValExchOne w) :
    DerivStableValExchOne w :=
  ⟨hw_vx, valuatedExchangeOne_deriv_degree_two w hw_nonneg hw_hom hw_mconvex hw_vx⟩

/-! ## General Conjecture Statement -/

/-
**Conjecture (Derivative closure of K=1 exchange)**:
    For all degrees `d`, if `w` is a nonneg homogeneous degree-`d` weight function
    with M-convex support and K=1 valuated exchange, then all first partial
    derivatives also satisfy K=1 valuated exchange.

    The degree-2 case is proved above (`valuatedExchangeOne_deriv_degree_two`).
    The general case is stated here as a target for future work.
-/
theorem valuatedExchangeOne_deriv_closed_general (w : (σ → ℕ) → ℝ) (d : ℕ)
    (hw_nonneg : ∀ m, 0 ≤ w m)
    (hw_hom : HomogeneousWt d w)
    (hw_mconvex : MConvexSupp w)
    (hw_vx : ValExchOne w) :
    ∀ i : σ, ValExchOne (pdWeight i w) := by
  intro i m m' hm hm' k hk;
  -- Since $pdWeight i w m > 0$ and $pdWeight i w m' > 0$, we have $w (Function.update m i (m i + 1)) > 0$ and $w (Function.update m' i (m' i + 1)) > 0$.
  have h_w_pos : w (Function.update m i (m i + 1)) > 0 ∧ w (Function.update m' i (m' i + 1)) > 0 := by
    exact ⟨ by exact lt_of_not_ge fun h => hm.not_ge <| mul_nonpos_of_nonneg_of_nonpos ( Nat.cast_nonneg _ ) h, by exact lt_of_not_ge fun h => hm'.not_ge <| mul_nonpos_of_nonneg_of_nonpos ( Nat.cast_nonneg _ ) h ⟩;
  -- By the exchange property of $w$, there exists $j \neq k$ such that $w (Function.update (exchVec m k j) i (exchVec m k j i + 1)) * w (Function.update (exchVec m' j k) i (exchVec m' j k i + 1)) \geq w (Function.update m i (m i + 1)) * w (Function.update m' i (m' i + 1))$.
  obtain ⟨j, hj₁, hj₂, hj₃⟩ : ∃ j, j ≠ k ∧ m' j > m j ∧ w (Function.update (exchVec m k j) i (exchVec m k j i + 1)) * w (Function.update (exchVec m' j k) i (exchVec m' j k i + 1)) ≥ w (Function.update m i (m i + 1)) * w (Function.update m' i (m' i + 1)) := by
    have := hw_vx ( Function.update m i ( m i + 1 ) ) ( Function.update m' i ( m' i + 1 ) ) h_w_pos.1 h_w_pos.2 k ?_ <;> simp_all +decide [ exchVec ];
    · obtain ⟨ j, hj₁, hj₂, hj₃ ⟩ := this; use j; by_cases hi : i = j <;> simp_all +decide [ update_apply ] ;
      · convert hj₃ using 2 <;> congr <;> ext x <;> by_cases hx : x = j <;> simp +decide [ *, exchVec ];
        · grind;
        · grind +extAll;
        · grind +qlia;
        · split_ifs <;> simp_all +decide [ update_apply ];
      · split_ifs at hj₂ <;> simp_all +decide [ exchVec ];
        convert hj₃ using 2 <;> congr <;> ext x <;> by_cases hx : x = i <;> by_cases hx' : x = j <;> by_cases hx'' : x = k <;> simp +decide [ *, exchVec ];
        all_goals simp_all +decide [ exchVec, update_apply ];
        rw [ Nat.sub_add_cancel ( Nat.one_le_iff_ne_zero.mpr ( by aesop_cat ) ) ];
    · by_cases hi : k = i <;> simp_all +decide [ update_apply ];
  refine' ⟨ j, hj₁, hj₂, _ ⟩;
  unfold pdWeight;
  simp_all +decide [ mul_assoc, mul_comm, mul_left_comm, exchVec ];
  split_ifs <;> simp_all +decide [ Nat.cast_sub ( show 1 ≤ m k from by linarith ), Nat.cast_sub ( show 1 ≤ m' j from by linarith ) ];
  · refine' le_trans _ ( mul_le_mul_of_nonneg_left ( mul_le_mul_of_nonneg_left hj₃ ( by positivity ) ) ( by positivity ) );
    nlinarith [ show ( m k : ℝ ) ≥ m' k + 1 by norm_cast, show ( m' k : ℝ ) ≥ 0 by positivity, show ( w ( update m k ( m k + 1 ) ) * w ( update m' k ( m' k + 1 ) ) ) ≥ 0 by exact mul_nonneg ( hw_nonneg _ ) ( hw_nonneg _ ), mul_le_mul_of_nonneg_right ( show ( m k : ℝ ) ≥ m' k + 1 by norm_cast ) ( show ( w ( update m k ( m k + 1 ) ) * w ( update m' k ( m' k + 1 ) ) ) ≥ 0 by exact mul_nonneg ( hw_nonneg _ ) ( hw_nonneg _ ) ) ];
  · refine' le_trans _ ( mul_le_mul_of_nonneg_left ( mul_le_mul_of_nonneg_left hj₃ ( Nat.cast_nonneg _ ) ) ( by positivity ) );
    nlinarith [ show ( m j : ℝ ) + 1 ≤ m' j by norm_cast, show ( m' j : ℝ ) ≥ 1 by norm_cast; linarith, show ( w ( update m j ( m j + 1 ) ) * w ( update m' j ( m' j + 1 ) ) ) ≥ 0 by exact mul_nonneg ( hw_nonneg _ ) ( hw_nonneg _ ), mul_le_mul_of_nonneg_right ( show ( m j : ℝ ) + 1 ≤ m' j by norm_cast ) ( show ( w ( update m j ( m j + 1 ) ) * w ( update m' j ( m' j + 1 ) ) ) ≥ 0 by exact mul_nonneg ( hw_nonneg _ ) ( hw_nonneg _ ) ) ];
  · exact mul_le_mul_of_nonneg_left ( mul_le_mul_of_nonneg_left hj₃ ( by positivity ) ) ( by positivity )

end ValuatedMConvexDiff