import Mathlib

/-!
# Eventual Periodicity of GCD Degrees over Finite Fields

## Main results

* `pow_eventually_periodic`: In any finite monoid, the power sequence of any element
  is eventually periodic.

* `gcd_Xpow_sub_one_eventually_periodic`: For any nonzero polynomial `Q` over `ZMod p`
  (where `p` is prime), the gcd of `Q` and `X^n - 1` is eventually periodic in `n`.

* `natDegree_gcd_Xpow_sub_one_eventually_periodic`: The `natDegree` of the above gcd
  is eventually periodic.

## Proof strategy

The key insight is that `X^n mod Q` lives in the finite quotient ring
`(ZMod p)[X]/(Q)`. By the pigeonhole principle, the sequence `X^n mod Q` must
eventually repeat, giving periodicity. Since `EuclideanDomain.gcd Q a` depends
only on `a mod Q` (by the Euclidean algorithm recursion), the gcd
inherits this periodicity.

## Application to cellular automata

For an additive cellular automaton over `GF(p)` with local polynomial `P`,
the number of fixed points of the `m`-th iterate on cyclic configurations
of length `n` equals `p^(dim ker(P^m - 1 acting on (ZMod p)^n))`.
This dimension equals `natDegree(gcd(X^n - 1, Q_m))` for an appropriate
annihilator polynomial `Q_m`. Our theorem therefore implies that the
logarithmic fixed-point count is eventually periodic in `n`.
-/

open Polynomial

noncomputable section

/-! ## Part 1: Eventual periodicity in finite monoids -/

/-- In a finite type, any sequence of `Nat.card M + 1` powers must have a collision
(pigeonhole principle). -/
theorem exists_lt_pow_eq_pow_of_finite {M : Type*} [Monoid M] [Finite M]
    (m : M) : ∃ i j : ℕ, i < j ∧ j ≤ Nat.card M ∧ m ^ i = m ^ j := by
  have h_pigeonhole : ∃ i j : Fin (Nat.card M + 1), i ≠ j ∧ m ^ (i : ℕ) = m ^ (j : ℕ) := by
    by_contra! h
    have h_inj : Function.Injective (fun i : Fin (Nat.card M + 1) => m ^ (i : ℕ)) := by
      exact fun i j hij => Classical.not_not.1 fun hij' => h i j hij' hij
    have h_card : Nat.card (Fin (Nat.card M + 1)) ≤ Nat.card M := by
      apply_rules [Nat.card_le_card_of_injective]
    simp +decide at h_card
  obtain ⟨i, j, hij, h⟩ := h_pigeonhole
  exact hij.lt_or_gt.elim
    (fun h' => ⟨i, j, h', Nat.le_of_lt_succ j.2, h⟩)
    fun h' => ⟨j, i, h', Nat.le_of_lt_succ i.2, h.symm⟩

/-
**Finite Monoid Power Periodicity**: In a finite monoid, the power sequence of
any element is eventually periodic. There exist `N` and `T > 0` such that
`m^(n+T) = m^n` for all `n ≥ N`.

This is a fundamental fact connecting finite algebra to dynamical systems:
iteration of any element in a finite monoid must eventually enter a cycle.
-/
theorem pow_eventually_periodic {M : Type*} [Monoid M] [Finite M]
    (m : M) : ∃ N T : ℕ, 0 < T ∧ ∀ n, N ≤ n → m ^ (n + T) = m ^ n := by
  -- By the pigeonhole principle, there exist integers $i < j$ such that $m^i = m^j$.
  obtain ⟨i, j, hij, h_eq⟩ : ∃ i j : ℕ, i < j ∧ m ^ i = m ^ j := by
    by_contra! h;
    exact not_injective_infinite_finite _ fun i j hij => le_antisymm ( le_of_not_gt fun hi => h _ _ hi hij.symm ) ( le_of_not_gt fun hj => h _ _ hj hij );
  refine' ⟨ i, j - i, tsub_pos_of_lt hij, fun n hn => _ ⟩;
  induction hn <;> simp_all +decide [ ← pow_add, add_assoc, Nat.succ_add, le_of_lt ];
  simp_all +decide [ ← add_assoc, pow_add ]

/-! ## Part 2: GCD depends only on residue -/

variable (p : ℕ) [hp : Fact p.Prime]

/-
The Euclidean algorithm gives `gcd Q a = gcd Q b` when `a % Q = b % Q`,
because the first recursive step reduces `gcd Q a = gcd (a % Q) Q` by `gcd_val`.
-/
theorem EuclideanDomain.gcd_eq_of_mod_eq'
    {R : Type*} [EuclideanDomain R] [DecidableEq R]
    (Q a b : R) (hab : a % Q = b % Q) :
    EuclideanDomain.gcd Q a = EuclideanDomain.gcd Q b := by
  grind +suggestions

/-! ## Part 3: Polynomial mod periodicity -/

/-
The mod operation for polynomials over a finite field produces eventually
periodic sequences when applied to powers of `X` modulo a fixed nonzero polynomial.
-/
theorem polynomial_mod_pow_eventually_periodic
    (Q : Polynomial (ZMod p)) (hQ : Q ≠ 0) :
    ∃ N T : ℕ, 0 < T ∧ ∀ n, N ≤ n →
      (X ^ (n + T) : Polynomial (ZMod p)) % Q = X ^ n % Q := by
  -- Apply the periodicity result to the sequence X^n % Q.
  have h_periodic : ∃ i j : ℕ, i < j ∧ Polynomial.X ^ i % Q = Polynomial.X ^ j % Q := by
    -- The set of possible values {r : (ZMod p)[X] | r.natDegree < Q.natDegree} is finite.
    have h_finite_set : Set.Finite {r : (ZMod p)[X] | r.natDegree < Q.natDegree} := by
      refine' Set.Finite.subset ( Set.toFinite ( Set.range fun f : Fin Q.natDegree → ZMod p => ∑ i : Fin Q.natDegree, f i • Polynomial.X ^ ( i : ℕ ) ) ) _;
      intro r hr; use fun i => r.coeff i; ext i; simp_all +decide [ Polynomial.coeff_sum, Polynomial.smul_eq_C_mul ] ;
      by_cases hi : i < r.natDegree <;> simp_all +decide [ Finset.sum_ite, Polynomial.coeff_eq_zero_of_natDegree_lt ];
      · rw [ Finset.sum_eq_single ⟨ i, by linarith ⟩ ] <;> aesop;
      · cases eq_or_lt_of_le hi <;> simp_all +decide [ Polynomial.coeff_eq_zero_of_natDegree_lt ];
        · rw [ Finset.sum_eq_single ⟨ i, by linarith ⟩ ] <;> aesop;
        · exact Finset.sum_eq_zero fun x hx => Polynomial.coeff_eq_zero_of_natDegree_lt <| by linarith [ Fin.is_lt x, Finset.mem_filter.mp hx ] ;
    -- By the pigeonhole principle, since there are only finitely many possible remainders when dividing by $Q$, the sequence of remainders must eventually repeat.
    have h_pigeonhole : Set.Finite (Set.range (fun n : ℕ => (Polynomial.X ^ n : Polynomial (ZMod p)) % Q)) := by
      refine Set.Finite.subset ( h_finite_set.union ( Set.finite_singleton 0 ) ) ?_;
      rintro _ ⟨ n, rfl ⟩ ; by_cases h : X ^ n % Q = 0 <;> simp +decide [ h ];
      exact Polynomial.natDegree_lt_natDegree h ( EuclideanDomain.mod_lt ( X ^ n ) hQ );
    contrapose! h_pigeonhole;
    exact Set.infinite_range_of_injective fun i j hij => le_antisymm ( le_of_not_gt fun hi => h_pigeonhole _ _ hi hij.symm ) ( le_of_not_gt fun hj => h_pigeonhole _ _ hj hij );
  obtain ⟨ i, j, hij, h ⟩ := h_periodic; use i, j - i; refine' ⟨ tsub_pos_of_lt hij, fun n hn => _ ⟩ ; induction hn <;> simp_all +decide [ Nat.succ_add, pow_add ] ;
  · rw [ ← pow_add, add_tsub_cancel_of_le hij.le ];
  · simp_all +decide [ mul_assoc, Polynomial.mod_def ];
    simp_all +decide [ ← mul_assoc, Polynomial.modByMonic_eq_of_dvd_sub ];
    rw [ Polynomial.modByMonic_eq_of_dvd_sub ];
    · exact Polynomial.monic_mul_leadingCoeff_inv hQ;
    · have := Polynomial.modByMonic_eq_sub_mul_div ( X ^ ‹_› * X ^ ( j - i ) ) ( show Polynomial.Monic ( Q * Polynomial.C Q.leadingCoeff⁻¹ ) from ?_ ) ; ( have := Polynomial.modByMonic_eq_sub_mul_div ( X ^ ‹_› ) ( show Polynomial.Monic ( Q * Polynomial.C Q.leadingCoeff⁻¹ ) from ?_ ) ; simp_all +decide [ mul_assoc, mul_comm, mul_left_comm ] ; );
      · rename_i k hk₁ hk₂;
        exact ⟨ C Q.leadingCoeff⁻¹ * ( X ^ ‹_› * X ^ ( j - i ) /ₘ ( Q * C Q.leadingCoeff⁻¹ ) ) * X - C Q.leadingCoeff⁻¹ * ( X ^ ‹_› /ₘ ( Q * C Q.leadingCoeff⁻¹ ) ) * X, by linear_combination' hk₁ * X ⟩;
      · exact Polynomial.monic_mul_leadingCoeff_inv hQ;
      · rw [ Polynomial.Monic, Polynomial.leadingCoeff_mul, Polynomial.leadingCoeff_C ] ; aesop

/-! ## Part 4: Main theorems -/

/-- **Main Theorem (Direction B)**: For any nonzero polynomial `Q` over `ZMod p`,
the gcd of `Q` and `X^n - 1` is eventually periodic in `n`.

This is a key step toward proving that fixed-point counts of additive cellular
automata on cyclic configurations are eventually periodic.

The proof combines three ingredients:
1. Powers `X^n mod Q` are eventually periodic in `n` (finite monoid pigeonhole).
2. `(X^n - 1) mod Q` inherits this periodicity.
3. `gcd(Q, X^n - 1)` depends only on `(X^n - 1) mod Q` (Euclidean algorithm). -/
theorem gcd_Xpow_sub_one_eventually_periodic
    (Q : Polynomial (ZMod p)) (hQ : Q ≠ 0) :
    ∃ N T : ℕ, 0 < T ∧ ∀ n, N ≤ n →
      EuclideanDomain.gcd Q (X ^ (n + T) - 1 : Polynomial (ZMod p)) =
      EuclideanDomain.gcd Q (X ^ n - 1) := by
  obtain ⟨N, T, hT, hper⟩ := polynomial_mod_pow_eventually_periodic p Q hQ
  exact ⟨N, T, hT, fun n hn => by
    apply EuclideanDomain.gcd_eq_of_mod_eq'
    have := hper n hn
    simp only [sub_eq_add_neg]
    rw [Polynomial.add_mod, this, ← Polynomial.add_mod]⟩

/-- Corollary: the `natDegree` of `gcd(Q, X^n - 1)` is eventually periodic. -/
theorem natDegree_gcd_Xpow_sub_one_eventually_periodic
    (Q : Polynomial (ZMod p)) (hQ : Q ≠ 0) :
    ∃ N T : ℕ, 0 < T ∧ ∀ n, N ≤ n →
      (EuclideanDomain.gcd Q (X ^ (n + T) - 1 : Polynomial (ZMod p))).natDegree =
      (EuclideanDomain.gcd Q (X ^ n - 1)).natDegree := by
  obtain ⟨N, T, hT, hper⟩ := gcd_Xpow_sub_one_eventually_periodic p Q hQ
  exact ⟨N, T, hT, fun n hn => by rw [hper n hn]⟩

end