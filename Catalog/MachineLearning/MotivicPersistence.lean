import Mathlib

/-!
# Motivic Persistence Spectrum for Point Counts

This file formalizes a prototype of **motivic persistence theory**: extracting
spectral (Frobenius eigenvalue) information from point-count data viewed through
a persistence-theoretic lens.

## Main definitions

* `powerSumSignal` — The power-sum sequence `r ↦ ∑ᵢ αᵢʳ` encoding arithmetic counting data
* `hankelMatrix` — The Hankel matrix `H_n(a) = (a_{i+j})_{0≤i,j<n}`
* `vandermondeMatrix` — The Vandermonde matrix `V(i,j) = αⱼⁱ`
* `hankelRankProfile` — The rank profile `n ↦ rank(H_n(a))`
* `arithmeticPersistenceProfile` — Persistence profile extracted from Hankel rank data
* `ellipticMiddleSignal` — The middle-cohomology signal `r ↦ αʳ + βʳ` for an elliptic curve

## Main results

* `powerSum_satisfies_charpoly_recurrence` — Power-sum sequences satisfy a linear recurrence
  whose coefficients come from the characteristic polynomial `∏(T - αᵢ)`.
* `hankelRank_le_spectral` — The rank of `H_n(powerSumSignal α)` is at most `m`.
* `hankelRank_eq_of_injective` — Under pairwise distinctness and `n ≥ m`, rank = `m`.
* `persistenceProfile_detects_spectral_order` — Different numbers of distinct eigenvalues
  yield different persistence profiles.
* `ellipticMiddleSignal_recurrence` — The elliptic middle signal satisfies a
  second-order recurrence from the Weil polynomial.
* `powerSums_determine_charpoly` — Sufficiently many matching power sums force
  equality of characteristic polynomials (spectral identifiability).

## Cross-domain significance

The mathematical content bridges:
- **Arithmetic geometry**: Weil zeta functions and Frobenius eigenvalues
- **Signal processing**: Prony's method for exponential sum recovery
- **Topological data analysis**: Persistence-style rank invariants
- **Linear algebra**: Vandermonde/Hankel matrix factorizations
-/

open Finset BigOperators Matrix Polynomial

/-! ## Core Definitions -/

/-- An arithmetic signal over a commutative ring: a sequence encoding
    point-count or spectral data. -/
structure ArithmeticSignal (R : Type*) [CommRing R] where
  /-- The underlying sequence -/
  seq : ℕ → R

/-- The power-sum signal for a family of scalars `α`: `r ↦ ∑ᵢ αᵢʳ`.
    This is the fundamental object connecting Frobenius eigenvalues to point counts. -/
def powerSumSignal {R : Type*} [CommRing R] {m : ℕ} (α : Fin m → R) : ℕ → R :=
  fun r => ∑ i, (α i) ^ r

/-- The Hankel matrix of a sequence `a` at stage `n`:
    `H_n(a)(i,j) = a(i+j)` for `0 ≤ i,j < n`. -/
def hankelMatrix {R : Type*} [CommRing R] (a : ℕ → R) (n : ℕ) :
    Matrix (Fin n) (Fin n) R :=
  fun i j => a (i.1 + j.1)

/-- The Vandermonde matrix: `V(i,j) = αⱼⁱ` -/
def vandermondeMatrix {R : Type*} [CommRing R] {m : ℕ}
    (α : Fin m → R) (n : ℕ) : Matrix (Fin n) (Fin m) R :=
  fun i j => (α j) ^ i.1

/-- The Hankel rank profile: `n ↦ rank(H_n(a))`.
    This is the core persistence invariant. -/
noncomputable def hankelRankProfile {R : Type*} [Field R] (a : ℕ → R) : ℕ → ℕ :=
  fun n => (hankelMatrix a n).rank

/-- The arithmetic persistence profile, defined as the Hankel rank profile.
    This is the bridge between arithmetic data and topological/persistence theory. -/
noncomputable def arithmeticPersistenceProfile {R : Type*} [Field R] (a : ℕ → R) : ℕ → ℕ :=
  hankelRankProfile a

/-- The elliptic middle signal: `r ↦ αʳ + βʳ`, encoding the middle cohomology
    contribution to point counts of an elliptic curve. -/
def ellipticMiddleSignal {R : Type*} [CommRing R] (α β : R) : ℕ → R :=
  fun r => α ^ r + β ^ r

/-! ## Theorem 1: Power Sums Satisfy Characteristic Polynomial Recurrence -/

/-- Each root of a polynomial annihilates the shifted power sum:
    if `P(x) = 0`, then `∑ₖ P.coeff(k) · x^(n+k) = 0`. -/
theorem root_power_shift_vanishes {R : Type*} [CommRing R]
    (p : R[X]) (x : R) (hx : p.eval x = 0) (n : ℕ) :
    ∑ k ∈ Finset.range (p.natDegree + 1), p.coeff k * x ^ (n + k) = 0 := by
  convert congr_arg (fun y => x ^ n * y) hx using 1
  · simp +decide [pow_add, mul_assoc, mul_comm, mul_left_comm,
      Finset.mul_sum _ _ _, Polynomial.eval_eq_sum_range]
  · ring

/-- **Theorem 1**: The power-sum sequence satisfies the linear recurrence
    given by the characteristic polynomial `∏ᵢ (T - αᵢ)`. -/
theorem powerSum_satisfies_charpoly_recurrence
    {R : Type*} [CommRing R] {m : ℕ} (α : Fin m → R) (n : ℕ) :
    ∑ k ∈ Finset.range ((∏ i : Fin m, (X - C (α i))).natDegree + 1),
      (∏ i : Fin m, (X - C (α i))).coeff k * powerSumSignal α (n + k) = 0 := by
  have h_comm :
    ∑ k ∈ Finset.range ((∏ i, (X - C (α i))).natDegree + 1),
      (∏ i, (X - C (α i))).coeff k * (∑ i, α i ^ (n + k)) =
    ∑ i, ∑ k ∈ Finset.range ((∏ i, (X - C (α i))).natDegree + 1),
      (∏ i, (X - C (α i))).coeff k * α i ^ (n + k) := by
    rw [Finset.sum_comm, Finset.sum_congr rfl]; intros; rw [Finset.mul_sum _ _ _]
  convert h_comm using 1
  exact Eq.symm (Finset.sum_eq_zero fun i _ =>
    root_power_shift_vanishes _ _ (by
      simp +decide [Polynomial.eval_prod,
        Finset.prod_eq_prod_diff_singleton_mul (Finset.mem_univ i)]) _)

/-! ## Hankel–Vandermonde Factorization -/

/-- The Hankel matrix factors as `H_n = V · Vᵀ` (Vandermonde factorization). -/
theorem hankel_eq_vandermonde_mul_transpose
    {R : Type*} [CommRing R] {m n : ℕ} (α : Fin m → R) :
    hankelMatrix (powerSumSignal α) n =
      vandermondeMatrix α n * (vandermondeMatrix α n)ᵀ := by
  ext i j
  simp +decide [Matrix.mul_apply, hankelMatrix, vandermondeMatrix, powerSumSignal]
  ring

/-! ## Theorem 2: Hankel Rank Bounds -/

/-- **Theorem 2a**: The Hankel rank is at most `m` (the spectral order). -/
theorem hankelRank_le_spectral
    {R : Type*} [Field R] {m n : ℕ} (α : Fin m → R) :
    hankelRankProfile (powerSumSignal α) n ≤ m := by
  have h : (hankelMatrix (powerSumSignal α) n).rank ≤ (vandermondeMatrix α n).rank := by
    rw [hankel_eq_vandermonde_mul_transpose]; exact Matrix.rank_mul_le_left _ _
  exact h.trans (le_trans (Matrix.rank_le_card_width _) (by simp +decide))

/-
**Theorem 2b**: Under distinctness and `n ≥ m`, the rank equals `m`.
-/
theorem hankelRank_eq_of_injective
    {R : Type*} [Field R] {m n : ℕ} (α : Fin m → R)
    (hα : Function.Injective α) (hn : m ≤ n) :
    hankelRankProfile (powerSumSignal α) n = m := by
  unfold hankelRankProfile;
  rw [ hankel_eq_vandermonde_mul_transpose ];
  -- The rank of a product of matrices is equal to the rank of the first matrix if the second matrix has full column rank.
  have h_rank_prod : Matrix.rank (vandermondeMatrix α n) = m := by
    rw [ Matrix.rank ];
    rw [ @LinearMap.finrank_range_of_inj ];
    · simp +decide;
    · intro x y hxy;
      -- Since the Vandermonde matrix is invertible when the α_i are distinct, we can conclude that x = y.
      have h_vandermonde_inv : Matrix.det (Matrix.of (fun i j : Fin m => α j ^ i.val)) ≠ 0 := by
        erw [ Matrix.det_transpose, Matrix.det_vandermonde ];
        exact Finset.prod_ne_zero_iff.mpr fun i hi => Finset.prod_ne_zero_iff.mpr fun j hj => sub_ne_zero_of_ne <| hα.ne <| by aesop;
      have h_vandermonde_inv : Matrix.mulVec (Matrix.of (fun i j : Fin m => α j ^ i.val)) x = Matrix.mulVec (Matrix.of (fun i j : Fin m => α j ^ i.val)) y := by
        convert congr_arg ( fun z : Fin n → R => fun i : Fin m => z ⟨ i, by linarith [ Fin.is_lt i ] ⟩ ) hxy using 1;
      apply_fun ( fun z => Matrix.mulVec ( Matrix.of ( fun i j : Fin m => α j ^ i.val ) )⁻¹ z ) at h_vandermonde_inv ; simp_all +decide [ isUnit_iff_ne_zero ];
  rw [ Matrix.rank, Matrix.mulVecLin_mul, LinearMap.range_comp ];
  rw [ show ( vandermondeMatrix α n )ᵀ.mulVecLin.range = ⊤ from _ ];
  · convert h_rank_prod using 1;
    rw [ Matrix.rank ];
    rw [ LinearMap.range_eq_map ];
  · refine' Submodule.eq_top_of_finrank_eq _;
    convert h_rank_prod using 1;
    · convert Matrix.rank_transpose _;
    · simp +decide

/-! ## Persistence Profile Properties -/

/-
The Hankel rank profile is monotone non-decreasing.
-/
theorem hankelRankProfile_mono {R : Type*} [Field R] (a : ℕ → R)
    {n₁ n₂ : ℕ} (h : n₁ ≤ n₂) :
    hankelRankProfile a n₁ ≤ hankelRankProfile a n₂ := by
  -- Let $P$ be the $n₁ \times n₂$ matrix with $P(i, j) = \delta_{i, j}$ (embedding first $n₁$ coordinates) and $Q = P^T$.
  set P : Matrix (Fin n₁) (Fin n₂) R := Matrix.of (fun i j => if i.val = j.val then 1 else 0)
  set Q : Matrix (Fin n₂) (Fin n₁) R := Matrix.of (fun i j => if i.val = j.val then 1 else 0);
  -- Then $P * H_{n₂} * Q = H_{n₁}$ because $(P * H * Q)(i, j) = H(i, j) = a(i + j)$ for $i, j < n₁$.
  have hPQ : P * hankelMatrix a n₂ * Q = hankelMatrix a n₁ := by
    ext i j; simp +decide [ Matrix.mul_apply, hankelMatrix ] ;
    rw [ Finset.sum_eq_single ⟨ j, by linarith [ Fin.is_lt j ] ⟩ ] <;> simp +decide [ Fin.ext_iff ];
    · rw [ Finset.sum_eq_single ⟨ i, by linarith [ Fin.is_lt i ] ⟩ ] <;> aesop;
    · aesop;
  -- By submultiplicativity of rank, we have $\text{rank}(P * H * Q) \leq \text{rank}(H)$.
  have h_rank_mul : Matrix.rank (P * hankelMatrix a n₂ * Q) ≤ Matrix.rank (hankelMatrix a n₂) := by
    exact le_trans ( Matrix.rank_mul_le_left _ _ ) ( Matrix.rank_mul_le_right _ _ );
  aesop

/-
**Persistence Separation Theorem**: Different numbers of distinct eigenvalues
    yield different persistence profiles. This is a genuine persistence-theoretic
    result: the rank profile detects the spectral order (model complexity).

    If `α` has `m` distinct eigenvalues and `β` has `m'` distinct eigenvalues
    with `m ≠ m'`, then their profiles differ.
-/
theorem persistenceProfile_detects_spectral_order
    {R : Type*} [Field R] {m m' : ℕ} (α : Fin m → R) (β : Fin m' → R)
    (hα : Function.Injective α) (hβ : Function.Injective β)
    (hmm : m ≠ m') :
    ∃ n, arithmeticPersistenceProfile (powerSumSignal α) n ≠
         arithmeticPersistenceProfile (powerSumSignal β) n := by
  cases lt_or_gt_of_ne hmm <;> [ refine' ⟨ m', _ ⟩ ; refine' ⟨ m, _ ⟩ ] <;> unfold arithmeticPersistenceProfile <;> simp_all +decide [ hankelRank_eq_of_injective ];
  · exact ne_of_lt ( lt_of_le_of_lt ( hankelRank_le_spectral α ) ( by linarith ) );
  · exact ne_of_gt ( lt_of_le_of_lt ( hankelRank_le_spectral β ) ( by linarith ) )

/-! ## Elliptic Curve Prototype -/

/-- **Theorem**: The elliptic middle signal `r ↦ αʳ + βʳ` satisfies the
    recurrence `a(n+2) - (α+β)·a(n+1) + αβ·a(n) = 0`. -/
theorem ellipticMiddleSignal_recurrence
    {R : Type*} [CommRing R] (α β : R) (n : ℕ) :
    ellipticMiddleSignal α β (n + 2)
      - (α + β) * ellipticMiddleSignal α β (n + 1)
      + (α * β) * ellipticMiddleSignal α β n = 0 := by
  unfold ellipticMiddleSignal; ring

/-! ## Theorem 3: Spectral Identifiability

This is the Newton/Prony identifiability theorem: sufficiently many matching
power sums force equality of characteristic polynomials.

The proof proceeds by contradiction using the Hankel rank characterization:
if two monic polynomials of degree `m` disagree, their difference gives a
recurrence of order `< m`, contradicting the Hankel rank being exactly `m`. -/

/-
The columns of the Hankel matrix beyond index `d` lie in the span
    of the first `d` columns when the sequence satisfies a recurrence
    of order `d`.
-/
theorem hankel_col_in_span_of_recurrence {R : Type*} [Field R]
    (a : ℕ → R) (d : ℕ) (c : Fin (d + 1) → R) (hc : c ⟨d, Nat.lt_succ_iff.mpr le_rfl⟩ ≠ 0)
    (hrec : ∀ n, ∑ k : Fin (d + 1), c k * a (n + k.1) = 0)
    (n : ℕ) (j : ℕ) :
    ∃ w : Fin d → R, ∀ i : Fin n, a (i.1 + j) = ∑ k : Fin d, w k * a (i.1 + k.1) := by
  induction' j using Nat.strong_induction_on with j ih generalizing n;
  by_cases hj : j < d;
  · use fun k => if k = ⟨j, hj⟩ then 1 else 0;
    aesop;
  · -- By the recurrence relation, we have $a(i + j) = -\sum_{k=0}^{d-1} \frac{c_k}{ �c�_d} a(i + j - d + k)$.
    have h_recurrence : ∀ i : Fin n, a (i + j) = -∑ k ∈ Finset.univ.filter (fun k => k.val < d), (c k / c ⟨d, by linarith⟩) * a (i + j - d + k.val) := by
      intro i
      have h_recurrence_step : ∑ k ∈ Finset.univ, c k * a (i + j - d + k.val) = 0 := by
        exact hrec _;
      simp_all +decide [ Fin.sum_univ_castSucc, div_mul_eq_mul_div, Finset.sum_div _ _ _ ];
      have := hrec ( i + j - d ) ; simp_all +decide [ ← Finset.sum_div _ _ _, ← eq_sub_iff_add_eq ] ;
      rw [ show ( Finset.filter ( fun x : Fin ( d + 1 ) => ( x : ℕ ) < d ) Finset.univ : Finset ( Fin ( d + 1 ) ) ) = Finset.univ.erase ( Fin.last d ) from ?_, Finset.sum_erase_eq_sub ( Finset.mem_univ _ ) ] ; simp_all +decide [ Finset.sum_range, Fin.sum_univ_castSucc ]; all_goals grind;
    -- By the induction hypothesis, each term $a(i + j - d + k)$ can be written as a linear combination of the first $d$ terms.
    have h_induction : ∀ k : Fin (d + 1), k.val < d → ∃ w : Fin d → R, ∀ i : Fin n, a (i + j - d + k.val) = ∑ l : Fin d, w l * a (i + l.val) := by
      intro k hk
      specialize ih (j - d + k.val) (by
      omega) n;
      simpa only [ add_assoc, Nat.add_sub_assoc ( le_of_not_gt hj ) ] using ih;
    choose! w hw using h_induction;
    use fun l => -∑ k ∈ Finset.univ.filter (fun k => k.val < d), (c k / c ⟨d, by linarith⟩) * w k l;
    simp +decide [ h_recurrence, hw, Finset.sum_mul _ _ _ ];
    intro i; rw [ Finset.sum_comm ] ; refine' Finset.sum_congr rfl fun k hk => _; rw [ hw k ( Finset.mem_filter.mp hk |>.2 ) i ] ; simp +decide [ mul_assoc, Finset.mul_sum _ _ _ ] ;

/-
A sequence satisfying a recurrence of order `d` has Hankel rank ≤ `d`.
-/
theorem recurrence_bounds_hankelRank {R : Type*} [Field R]
    (a : ℕ → R) (d : ℕ) (c : Fin (d + 1) → R) (hc : c ⟨d, Nat.lt_succ_iff.mpr le_rfl⟩ ≠ 0)
    (hrec : ∀ n, ∑ k : Fin (d + 1), c k * a (n + k.1) = 0)
    {n : ℕ} (hn : d ≤ n) :
    hankelRankProfile a n ≤ d := by
  obtain ⟨w, hw⟩ : ∃ w : Fin (d + 1) → R, w ⟨d, Nat.lt_succ_self d⟩ ≠ 0 ∧ ∀ n, ∑ k : Fin (d + 1), w k * a (n + k.1) = 0 ∧ ∀ j ≥ d, ∃ w' : Fin d → R, ∀ i : Fin n, a (i.1 + j) = ∑ k : Fin d, w' k * a (i.1 + k.1) := by
    have := @hankel_col_in_span_of_recurrence R; aesop;
  obtain ⟨hw₁, hw₂⟩ := hw;
  obtain ⟨hw₁, hw₂⟩ := hw₂ n;
  obtain ⟨B, C, hBC⟩ : ∃ B : Matrix (Fin n) (Fin d) R, ∃ C : Matrix (Fin d) (Fin n) R, hankelMatrix a n = B * C := by
    choose! w' hw' using hw₂;
    use Matrix.of (fun i j => a (i.1 + j.1)), Matrix.of (fun i j => if h : j.1 < d then if i = ⟨j.1, h⟩ then 1 else 0 else w' j.1 i);
    ext i j; simp +decide [ Matrix.mul_apply, hankelMatrix ] ;
    exact fun hj => by simpa only [ mul_comm ] using hw' j hj i;
  exact hBC.symm ▸ le_trans ( Matrix.rank_mul_le_left _ _ ) ( Matrix.rank_le_card_width _ ) |> le_trans <| by simp +decide ;

/-
If two monic polynomials P, Q of degree `m` both annihilate the same
    power-sum sequence (with Hankel rank `m`), then P = Q.

    This is the key step: the characteristic polynomial is the unique
    monic annihilator of minimal degree.
-/
theorem unique_monic_annihilator {R : Type*} [Field R] {m : ℕ}
    (a : ℕ → R)
    (P Q : R[X])
    (hPm : P.Monic) (hQm : Q.Monic)
    (hPd : P.natDegree = m) (hQd : Q.natDegree = m)
    (hPr : ∀ n, ∑ k ∈ Finset.range (m + 1), P.coeff k * a (n + k) = 0)
    (hQr : ∀ n, ∑ k ∈ Finset.range (m + 1), Q.coeff k * a (n + k) = 0)
    (hrank : hankelRankProfile a m = m) :
    P = Q := by
  by_contra h_neq
  have h_diff : P - Q ≠ 0 := by
    exact sub_ne_zero_of_ne h_neq;
  -- Let $d = \deg(P - Q)$. Since $P \neq Q$, we have $d < m$.
  set d := (P - Q).natDegree with hd
  have h_deg : d < m := by
    refine' lt_of_lt_of_le ( Polynomial.natDegree_lt_natDegree _ _ ) hPd.le;
    · exact h_diff;
    · convert Polynomial.degree_sub_lt _ _ _ using 1;
      · rw [ Polynomial.degree_eq_natDegree hPm.ne_zero, Polynomial.degree_eq_natDegree hQm.ne_zero, hPd, hQd ];
      · aesop;
      · rw [ hPm.leadingCoeff, hQm.leadingCoeff ];
  -- Since $P - Q$ is a polynomial of degree $d < m$, it satisfies the recurrence relation for $a$.
  have h_recurrence_diff : ∀ n, ∑ k ∈ Finset.range (d + 1), (P - Q).coeff k * a (n + k) = 0 := by
    intro n
    have h_recurrence_diff_step : ∑ k ∈ Finset.range (m + 1), (P - Q).coeff k * a (n + k) = 0 := by
      simp_all +decide [ sub_mul ];
    rw [ ← h_recurrence_diff_step, Finset.sum_subset ( Finset.range_mono ( Nat.succ_le_succ h_deg.le ) ) fun x hx₁ hx₂ => by rw [ Polynomial.coeff_eq_zero_of_natDegree_lt ] <;> aesop ];
  have h_rank_diff : hankelRankProfile a m ≤ d := by
    apply recurrence_bounds_hankelRank a d (fun k => (P - Q).coeff k);
    · exact mt Polynomial.leadingCoeff_eq_zero.1 h_diff;
    · simpa only [ Finset.sum_range, Fin.cast_val_eq_self ] using h_recurrence_diff;
    · lia;
  lia

/-
**Theorem 3**: Equal power sums imply equal characteristic polynomials.
-/
theorem powerSums_determine_charpoly
    {R : Type*} [Field R] [CharZero R] {m : ℕ}
    (α β : Fin m → R)
    (hα : Function.Injective α) (hβ : Function.Injective β)
    (hEq : ∀ r, r < 2 * m → powerSumSignal α r = powerSumSignal β r) :
    ∏ i : Fin m, (X - C (α i)) = ∏ i : Fin m, (X - C (β i)) := by
  -- Consider the polynomial $Q(x) = \prod_{i=1}^m (x - \beta_i)$.
  set Q : Polynomial R := ∏ i, (Polynomial.X - Polynomial.C (β i));
  -- Since $Q$ is a polynomial of degree $m$, and $Q(\alpha_i) = 0$ for all $i$, it follows that $Q$ is divisible by $\prod_{i=1}^m (x - \alpha_i)$.
  have hQ_div : ∏ i, (Polynomial.X - Polynomial.C (α i)) ∣ Q := by
    have hQ_div : ∀ i, Q.eval (α i) = 0 := by
      -- By the properties of the Hankel matrix and the � Vander�monde matrix, we know that $\sum_{i=0}^{m-1} \alpha_i^n Q(\alpha_i) = 0$ for all $n \geq 0$.
      have h_sum_zero : ∀ n < m, ∑ i, (α i) ^ n * Q.eval (α i) = 0 := by
        intro n hn
        have hQ_eval_zero_step : ∑ i, α i ^ n * Q.eval (α i) = ∑ k ∈ Finset.range (Q.natDegree + 1), Q.coeff k * powerSumSignal α (n + k) := by
          simp +decide [ Polynomial.eval_eq_sum_range, powerSumSignal, Finset.mul_sum _ _ _, mul_assoc, mul_comm, mul_left_comm ];
          exact Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by ring );
        rw [ hQ_eval_zero_step, Finset.sum_congr rfl fun k hk => by rw [ hEq _ <| by linarith [ Finset.mem_range.mp hk, show Q.natDegree ≤ m from by rw [ Polynomial.natDegree_prod _ _ fun i _ => Polynomial.X_sub_C_ne_zero _ ] ; simp +decide [ Polynomial.natDegree_sub_eq_left_of_natDegree_lt ] ] ] ];
        convert powerSum_satisfies_charpoly_recurrence β n using 1;
      -- By the properties of the Vandermonde matrix, if $\sum_{i=0}^{m-1} \alpha_i^n Q(\alpha_i) = 0$ for all $n \geq 0$, then $Q(\alpha_i) = 0$ for all $i$.
      have h_vandermonde : Matrix.det (Matrix.of (fun (i j : Fin m) => (α j) ^ (i : ℕ))) ≠ 0 := by
        erw [ Matrix.det_transpose, Matrix.det_vandermonde ];
        exact Finset.prod_ne_zero_iff.mpr fun i hi => Finset.prod_ne_zero_iff.mpr fun j hj => sub_ne_zero_of_ne <| hα.ne <| by aesop;
      -- By the properties of the Vandermonde matrix, if $\sum_{i=0}^{m-1} \alpha_i^n Q(\alpha_i) = 0$ for all $n \geq 0$, then $Q(\alpha_i) = 0$ for all $i$ because the Vandermonde matrix is invertible.
      have h_vandermonde_inv : ∀ (v : Fin m → R), Matrix.mulVec (Matrix.of (fun (i j : Fin m) => (α j) ^ (i : ℕ))) v = 0 → v = 0 := by
        exact fun v hv => Matrix.eq_zero_of_mulVec_eq_zero h_vandermonde hv;
      specialize h_vandermonde_inv ( fun i => Q.eval ( α i ) ) ; simp_all +decide [ funext_iff, Matrix.mulVec, dotProduct ] ;
    refine' Finset.prod_dvd_of_coprime _ _;
    · exact fun i _ j _ hij => Polynomial.pairwise_coprime_X_sub_C hα hij;
    · exact fun i _ => Polynomial.dvd_iff_isRoot.mpr ( hQ_div i );
  -- Since $Q$ is a polynomial of degree $m$, and $Q(\alpha_i) = 0$ for all $i$, it follows that $Q$ is equal to $\prod_{i=1}^m (x - \alpha_i)$.
  have hQ_eq : ∏ i, (Polynomial.X - Polynomial.C (α i)) = Q := by
    have h_deg : Polynomial.degree (∏ i, (Polynomial.X - Polynomial.C (α i))) = Polynomial.degree Q := by
      simp +decide only [degree_prod, degree_X_sub_C, Q]
    refine' Polynomial.eq_of_monic_of_associated _ _ ( associated_of_dvd_dvd hQ_div _ );
    · exact Polynomial.monic_prod_of_monic _ _ fun i _ => Polynomial.monic_X_sub_C _;
    · exact Polynomial.monic_prod_of_monic _ _ fun i _ => Polynomial.monic_X_sub_C _;
    · refine' ( Polynomial.eq_of_monic_of_associated _ _ _ ).dvd;
      · exact Polynomial.monic_prod_of_monic _ _ fun i _ => Polynomial.monic_X_sub_C _;
      · exact Polynomial.monic_prod_of_monic _ _ fun i _ => Polynomial.monic_X_sub_C _;
      · exact?;
  exact hQ_eq