import Mathlib

/-!
# Tropical Matrix Iteration: Monotonicity and Dominance Certificates

This file develops the foundational theory of **tropical (max-plus) matrix operators**
acting on vectors in `ℝⁿ`. The central object is the tropical matrix map

  `T(x)ᵢ = max_j (Aᵢⱼ + xⱼ)`

which arises naturally in:
- dynamic programming (Bellman operators),
- shortest/longest path computations,
- tropical linear algebra and spectral theory,
- neural network verification (max-affine maps),
- static analysis via abstract interpretation.

## Main Results

* `tropicalMatMap_monotone`: One-step monotonicity — if `x ≤ y` pointwise,
  then `T(x) ≤ T(y)` pointwise.
* `tropicalMatMap_iterate_monotone`: Iterated monotonicity — monotonicity
  is preserved under arbitrary iteration.
* `tropicalMatMap_postfixed_iterate`: Post-fixed point certificate —
  if `x ≤ T(x)`, then `x ≤ Tⁿ(x)` for all `n`.
* `tropicalMatMap_prefixed_iterate`: Pre-fixed point certificate —
  if `T(x) ≤ x`, then `Tⁿ(x) ≤ x` for all `n`.
* `tropicalMatMap_nonexpansive_coord`: Nonexpansiveness in the sup-norm —
  `|T(x)ᵢ - T(y)ᵢ| ≤ max_j |xⱼ - yⱼ|`.
* `tropicalMatMap_add_const`: Additive homogeneity —
  `T(x + c) = T(x) + c`.
* `tropicalMatMap_comp`: Composition corresponds to tropical matrix multiplication.
* `tropicalMatMap_iterate_lower_bound`: Lower bound on iterates from minimum entry.

## References

* Baccelli, Cohen, Olsder, Quadrat, *Synchronization and Linearity*, 1992
* Butkovič, *Max-linear Systems: Theory and Algorithms*, 2010
-/

noncomputable section

open Finset Matrix

/-! ## Definition of the Tropical Matrix Map -/

/-- The **tropical (max-plus) matrix map** sends a vector `x : Fin n → ℝ` to the vector
whose `i`-th component is `max_j (A i j + x j)`. This is the Bellman operator
associated with the weight matrix `A`. Requires `n ≥ 1` (i.e., `Nonempty (Fin n)`). -/
def tropicalMatMap {n : ℕ} [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) : Fin n → ℝ :=
  fun i => Finset.univ.sup' Finset.univ_nonempty (fun j => A i j + x j)

/-! ## One-Step Monotonicity -/

/-
**One-step monotonicity of the tropical matrix map.**
If `x ≤ y` pointwise, then `T(x) ≤ T(y)` pointwise. Each summand
`A i j + x j ≤ A i j + y j`, so the maximum over `j` is monotone.
-/
theorem tropicalMatMap_monotone {n : ℕ} [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ)
    {x y : Fin n → ℝ}
    (hxy : ∀ i, x i ≤ y i) :
    ∀ i, tropicalMatMap A x i ≤ tropicalMatMap A y i := by
  -- Each term A i j + x j ≤ A i j + y j by add_le_add_left and hxy. Then use Finset.sup'_le_sup' to conclude the sup' over j is monotone.
  intros i
  apply Finset.sup'_le;
  -- Since the supremum is an upper bound for each element in the set, we have A i b + x b ≤ A i b + y b ≤ the supremum of A i j + y j over all j.
  intros b hb
  have h_le : A i b + x b ≤ A i b + y b := by
    grind +locals;
  exact le_trans h_le ( Finset.le_sup' ( fun j => A i j + y j ) hb )

/-! ## Iterated Monotonicity -/

/-
**Iterated monotonicity of the tropical matrix map.**
If `x ≤ y` pointwise, then `Tᵏ(x) ≤ Tᵏ(y)` pointwise for all `k : ℕ`.
-/
theorem tropicalMatMap_iterate_monotone {n : ℕ} [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ)
    {x y : Fin n → ℝ}
    (hxy : ∀ i, x i ≤ y i) :
    ∀ k : ℕ, ∀ i,
      (Nat.iterate (tropicalMatMap A) k x) i ≤
      (Nat.iterate (tropicalMatMap A) k y) i := by
  intro k;
  induction' k with k ih;
  · exact hxy;
  · simpa only [ Function.iterate_succ_apply' ] using fun i => tropicalMatMap_monotone A ih i

/-! ## Post-Fixed Point Certificate -/

/-
**Post-fixed point certificate for tropical iteration.**
If `x ≤ T(x)`, then `x ≤ Tᵏ(x)` for all `k`. A single dominance check
certifies that `x` remains a lower bound through arbitrarily many iterations.
-/
theorem tropicalMatMap_postfixed_iterate {n : ℕ} [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ)
    {x : Fin n → ℝ}
    (hx : ∀ i, x i ≤ tropicalMatMap A x i) :
    ∀ k : ℕ, ∀ i,
      x i ≤ (Nat.iterate (tropicalMatMap A) k x) i := by
  intro k;
  induction k <;> simp_all +decide [ Function.iterate_succ_apply' ];
  exact fun i => le_trans ( hx i ) ( tropicalMatMap_monotone A ‹_› i )

/-! ## Pre-Fixed Point Certificate -/

/-
**Pre-fixed point certificate for tropical iteration.**
If `T(x) ≤ x`, then `Tᵏ(x) ≤ x` for all `k`.
-/
theorem tropicalMatMap_prefixed_iterate {n : ℕ} [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ)
    {x : Fin n → ℝ}
    (hx : ∀ i, tropicalMatMap A x i ≤ x i) :
    ∀ k : ℕ, ∀ i,
      (Nat.iterate (tropicalMatMap A) k x) i ≤ x i := by
  have h_inductive_step : ∀ y : Fin n → ℝ, (∀ i, y i ≤ x i) → (∀ i, tropicalMatMap A y i ≤ x i) := by
    exact fun y hy i => le_trans ( tropicalMatMap_monotone A hy i ) ( hx i );
  exact fun k => Nat.recOn k ( fun i => le_rfl ) fun k ih => by simpa only [ Function.iterate_succ', Function.comp_apply ] using h_inductive_step _ ih;

/-! ## Nonexpansiveness -/

/-
**Sup-norm nonexpansiveness of the tropical matrix map.**
`|T(x)ᵢ - T(y)ᵢ| ≤ max_j |xⱼ - yⱼ|` for all `i`.
-/
theorem tropicalMatMap_nonexpansive_coord {n : ℕ} [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (x y : Fin n → ℝ) (i : Fin n) :
    |tropicalMatMap A x i - tropicalMatMap A y i| ≤
    Finset.univ.sup' Finset.univ_nonempty (fun j => |x j - y j|) := by
  unfold tropicalMatMap;
  refine' abs_sub_le_iff.mpr _;
  constructor <;> rw [ sub_le_iff_le_add' ];
  · simp +zetaDelta at *;
    exact fun j => by linarith [ Finset.le_sup' ( fun j => A i j + y j ) ( Finset.mem_univ j ), Finset.le_sup' ( fun j => |x j - y j| ) ( Finset.mem_univ j ), abs_le.mp ( Finset.le_sup' ( fun j => |x j - y j| ) ( Finset.mem_univ j ) ) ] ;
  · norm_num +zetaDelta at *;
    exact fun j => by linarith [ Finset.le_sup' ( fun j => A i j + x j ) ( Finset.mem_univ j ), Finset.le_sup' ( fun j => |x j - y j| ) ( Finset.mem_univ j ), abs_le.mp ( show |x j - y j| ≤ univ.sup' Finset.univ_nonempty fun j => |x j - y j| from Finset.le_sup' ( fun j => |x j - y j| ) ( Finset.mem_univ j ) ) ] ;

/-! ## Additive Homogeneity -/

/-
**Additive homogeneity of the tropical matrix map.**
`T(x + c·1) = T(x) + c` — the tropical map commutes with uniform scalar shifts.
-/
theorem tropicalMatMap_add_const {n : ℕ} [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (x : Fin n → ℝ) (c : ℝ) :
    tropicalMatMap A (fun j => x j + c) =
    fun i => tropicalMatMap A x i + c := by
  unfold tropicalMatMap;
  ext i; simp +decide [ ← add_assoc, Finset.sup'_add ] ;

/-! ## Tropical Matrix Multiplication and Composition -/

/-- Tropical (max-plus) matrix multiplication: `(A ⊗ B)ᵢₖ = max_j (Aᵢⱼ + Bⱼₖ)`. -/
def tropicalMatMul {n : ℕ} [Nonempty (Fin n)]
    (A B : Matrix (Fin n) (Fin n) ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  fun i k => Finset.univ.sup' Finset.univ_nonempty (fun j => A i j + B j k)

/-
Composition of tropical matrix maps equals the tropical matrix map of the
tropical product: `T_A ∘ T_B = T_{A⊗B}`.
-/
theorem tropicalMatMap_comp {n : ℕ} [Nonempty (Fin n)]
    (A B : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) :
    tropicalMatMap A (tropicalMatMap B x) = tropicalMatMap (tropicalMatMul A B) x := by
  funext i;
  refine' le_antisymm ( Finset.sup'_le _ _ _ ) _;
  · unfold tropicalMatMap tropicalMatMul;
    intro j hj; simp +decide [ add_assoc, add_comm, add_left_comm, Finset.le_sup' ] ;
    obtain ⟨ k, hk ⟩ := Finset.exists_mem_eq_sup' ( Finset.univ_nonempty ) ( fun j_1 => B j j_1 + x j_1 );
    obtain ⟨ l, hl ⟩ := Finset.exists_mem_eq_sup' ( Finset.univ_nonempty ) ( fun j_1 => A i j_1 + B j_1 k ) ; use k; simp_all +decide [ add_comm, add_left_comm, add_assoc ] ;
    linarith [ Finset.le_sup' ( fun j_1 => A i j_1 + B j_1 k ) ( Finset.mem_univ j ) ];
  · simp [tropicalMatMap, tropicalMatMul];
    -- Let's choose any $b$ such that $A i b + \sup_{j} (B b j + x j)$ is maximized.
    obtain ⟨b, hb⟩ : ∃ b, ∀ j, A i b + (Finset.univ.sup' Finset.univ_nonempty (fun k => B b k + x k)) ≥ A i j + (Finset.univ.sup' Finset.univ_nonempty (fun k => B j k + x k)) := by
      simpa using Finset.exists_max_image Finset.univ ( fun j => A i j + Finset.univ.sup' Finset.univ_nonempty ( fun k => B j k + x k ) ) ⟨ i, Finset.mem_univ i ⟩;
    use b;
    grind +suggestions

/-! ## Iterate Growth Bound -/

/-
**Lower bound on tropical iterates from minimum matrix entry.**
If all entries of `A` are at least `m`, then each coordinate after `k` iterations
is at least `xmin + k * m`, where `xmin` is a lower bound on initial values.
-/
theorem tropicalMatMap_iterate_lower_bound {n : ℕ} [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (x : Fin n → ℝ)
    (m : ℝ)
    (hm : ∀ i j, m ≤ A i j)
    (xmin : ℝ)
    (hxmin : ∀ i, xmin ≤ x i) :
    ∀ k : ℕ, ∀ i,
      xmin + k * m ≤ (Nat.iterate (tropicalMatMap A) k x) i := by
  intro k i; induction' k with k hk generalizing i <;> simp_all +decide [ Function.iterate_succ_apply', tropicalMatMap ] ;
  exact ⟨ Classical.arbitrary _, by linarith [ hk ( Classical.arbitrary _ ), hm i ( Classical.arbitrary _ ) ] ⟩

/-! ## Monotone Iteration Squeeze -/

/-- **Squeeze theorem for tropical iterates.**
If `x ≤ T(x)` and `T(y) ≤ y` and `x ≤ y`, then the iterates starting from `x`
are sandwiched: `x ≤ Tᵏ(x) ≤ Tᵏ(y) ≤ y` for all `k`. -/
theorem tropicalMatMap_iterate_squeeze {n : ℕ} [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ)
    {x y : Fin n → ℝ}
    (hx : ∀ i, x i ≤ tropicalMatMap A x i)
    (hy : ∀ i, tropicalMatMap A y i ≤ y i)
    (hxy : ∀ i, x i ≤ y i) :
    ∀ k : ℕ, ∀ i,
      x i ≤ (Nat.iterate (tropicalMatMap A) k x) i ∧
      (Nat.iterate (tropicalMatMap A) k x) i ≤ (Nat.iterate (tropicalMatMap A) k y) i ∧
      (Nat.iterate (tropicalMatMap A) k y) i ≤ y i := by
  intro k i
  exact ⟨tropicalMatMap_postfixed_iterate A hx k i,
         tropicalMatMap_iterate_monotone A hxy k i,
         tropicalMatMap_prefixed_iterate A hy k i⟩

end