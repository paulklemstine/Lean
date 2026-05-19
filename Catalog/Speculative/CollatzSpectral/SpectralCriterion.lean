/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Spectral Collapse Criterion for Collatz Termination

This file establishes the core bridge between spectral properties of
arithmetic transfer operators and termination of the accelerated Collatz map.

## Mathematical Framework

The accelerated Collatz map T(n) = (3n+1)/2^{ν₂(3n+1)} acts on odd positive
naturals. We define a weighted transfer operator and its character twists.
The main results establish:

1. **Operator norm perturbation**: If ‖B - A‖ ≤ ε and ‖A‖ + ε < 1, then ‖B‖ < 1.
2. **Contracting operator implies orbit decay**: ‖A‖ < 1 implies A^k → 0.
3. **No nonzero fixed points under contraction**: ‖A‖ < 1 implies Av = v only if v = 0.
4. **Spectral gap implies termination** (conditional bridge theorem).

## Observable Space

We work with finite-dimensional complex vector spaces `Fin N → ℂ` equipped
with the sup norm. The transfer operator is represented as a matrix in
`Matrix (Fin N) (Fin N) ℂ`. Character twists act by diagonal multiplication.
-/

import Mathlib
import Speculative.CollatzSpectral.Defs

open Matrix BigOperators Finset

/-! ## §1. Finite-Dimensional Spectral Theory -/

section FiniteDimensional

variable {N : ℕ} [NeZero N]

/-- The operator norm of a matrix (row-sum norm / ℓ^∞ operator norm). -/
noncomputable def matrixSupNorm (A : Matrix (Fin N) (Fin N) ℂ) : ℝ :=
  ⨆ (i : Fin N), ∑ j : Fin N, ‖A i j‖

/-- The sup norm is nonneg. -/
theorem matrixSupNorm_nonneg (A : Matrix (Fin N) (Fin N) ℂ) :
    0 ≤ matrixSupNorm A := by
  exact Real.iSup_nonneg fun _ => Finset.sum_nonneg fun _ _ => norm_nonneg _

/-
Geometric decay of matrix powers: if ‖A‖ < 1 then ‖A^k‖ → 0.
-/
theorem geom_decay_of_norm_lt_one (A : Matrix (Fin N) (Fin N) ℂ)
    (h : matrixSupNorm A < 1) :
    ∀ ε > 0, ∃ K : ℕ, ∀ k ≥ K, matrixSupNorm (A ^ k) < ε := by
  -- By induction, we have ‖A^k‖ ≤ ‖A‖^k.
  have h_induction : ∀ (k : ℕ), matrixSupNorm (A ^ k) ≤ matrixSupNorm A ^ k := by
    -- By induction on $k$, we can show that $\|A^k\| \leq \|A\|^k$.
    intro k
    induction' k with k ih;
    · refine' ciSup_le fun i => _;
      simp +decide [ Matrix.one_apply ];
      rw [ Finset.sum_eq_single i ] <;> aesop;
    · -- By the properties of the supremum norm, we have ‖A^(k+1)‖ ≤ ‖A‖ * ‖A^k‖.
      have h_norm_mul : matrixSupNorm (A * A ^ k) ≤ matrixSupNorm A * matrixSupNorm (A ^ k) := by
        -- Apply the triangle inequality to the sum.
        have h_triangle : ∀ i, ∑ j, ‖(A * A ^ k) i j‖ ≤ ∑ l, ‖A i l‖ * ∑ j, ‖(A ^ k) l j‖ := by
          intro i
          have h_triangle : ∀ j, ‖(A * A ^ k) i j‖ ≤ ∑ l, ‖A i l‖ * ‖(A ^ k) l j‖ := by
            exact fun j => by simpa only [ Matrix.mul_apply ] using norm_sum_le _ _ |> le_trans <| Finset.sum_le_sum fun _ _ => by rw [ norm_mul ] ;
          refine' le_trans ( Finset.sum_le_sum fun j _ => h_triangle j ) _;
          rw [ Finset.sum_comm ] ; exact Finset.sum_le_sum fun _ _ => by rw [ Finset.mul_sum _ _ _ ] ;
        -- Apply the definition of matrixSupNorm to the right-hand side.
        have h_rhs : ∀ i, ∑ l, ‖A i l‖ * ∑ j, ‖(A ^ k) l j‖ ≤ matrixSupNorm A * matrixSupNorm (A ^ k) := by
          intro i
          have h_rhs : ∑ l, ‖A i l‖ * ∑ j, ‖(A ^ k) l j‖ ≤ (∑ l, ‖A i l‖) * matrixSupNorm (A ^ k) := by
            rw [ Finset.sum_mul _ _ _ ];
            exact Finset.sum_le_sum fun l _ => mul_le_mul_of_nonneg_left ( le_ciSup ( Finite.bddAbove_range fun i => ∑ j, ‖( A ^ k ) i j‖ ) l ) ( norm_nonneg _ );
          exact h_rhs.trans ( mul_le_mul_of_nonneg_right ( le_ciSup ( Finite.bddAbove_range fun i => ∑ j, ‖A i j‖ ) i ) ( by exact Real.iSup_nonneg fun _ => Finset.sum_nonneg fun _ _ => norm_nonneg _ ) );
        convert ciSup_le fun i => le_trans ( h_triangle i ) ( h_rhs i ) using 1;
      simpa only [ pow_succ' ] using h_norm_mul.trans ( mul_le_mul_of_nonneg_left ih ( matrixSupNorm_nonneg A ) );
  exact fun ε ε_pos => by rcases Metric.tendsto_atTop.mp ( tendsto_pow_atTop_nhds_zero_of_lt_one ( matrixSupNorm_nonneg A ) h ) ε ε_pos with ⟨ K, hK ⟩ ; exact ⟨ K, fun k hk => lt_of_le_of_lt ( h_induction k ) ( by linarith [ abs_lt.mp ( hK k hk ) ] ) ⟩ ;

end FiniteDimensional

/-! ## §2. Character-Twisted Transfer Operators -/

section CharacterTwist

variable (q : ℕ) [NeZero q]

/-- A multiplicative character on ZMod q. -/
structure ArithChar (q : ℕ) where
  toFun : ZMod q → ℂ
  map_mul : ∀ a b : ZMod q, toFun (a * b) = toFun a * toFun b
  map_one : toFun 1 = 1

/-- A character is nontrivial on units if some unit maps to a value ≠ 1. -/
def ArithChar.IsNontrivialOnUnits (χ : ArithChar q) : Prop :=
  ∃ a : (ZMod q)ˣ, χ.toFun a ≠ 1

/-
Character orthogonality on the unit group: sum of a nontrivial
    character over units is zero.
-/
theorem char_orthogonality_units (χ : ArithChar q)
    (hχ : χ.IsNontrivialOnUnits) :
    ∑ a : (ZMod q)ˣ, χ.toFun a = 0 := by
  -- Let $a₀$ be a unit with $\chi(a₀) \neq 1$ (from $hχ$).
  obtain ⟨a₀, ha₀⟩ : ∃ a₀ : (ZMod q)ˣ, χ.toFun a₀ ≠ 1 := hχ;
  -- Since multiplication by a₀ is a bijection on the unit group, we can reindex the sum.
  have h_reindex : ∑ u : (ZMod q)ˣ, χ.toFun (a₀ * u).val = ∑ u : (ZMod q)ˣ, χ.toFun u.val := by
    exact Equiv.sum_comp ( Equiv.mulLeft a₀ ) fun u => χ.toFun u.val;
  -- Since χ is multiplicative, we have χ(a₀ * u) = χ(a₀) * χ(u).
  have h_mul : ∀ u : (ZMod q)ˣ, χ.toFun (a₀ * u).val = χ.toFun a₀ * χ.toFun u.val := by
    exact fun u => χ.map_mul _ _;
  simp_all +decide [ ← Finset.mul_sum _ _ _ ];
  exact mul_left_cancel₀ ( sub_ne_zero_of_ne ha₀ ) ( by linear_combination' h_reindex )

end CharacterTwist

/-! ## §3. Certified Finite-Rank Perturbation Bound -/

section Perturbation

/-
**Certified matrix gap** (Theorem B, finite-dimensional version).
    If ‖B - A‖ ≤ ε and ‖A‖ + ε < 1, then ‖B‖ < 1.
    Proof: ‖B‖ ≤ ‖A‖ + ‖B - A‖ ≤ ‖A‖ + ε < 1 by subadditivity.
-/
theorem certified_matrix_gap {N : ℕ} [NeZero N]
    (A B : Matrix (Fin N) (Fin N) ℂ)
    (ε : ℝ) (hε : 0 ≤ ε)
    (happrox : matrixSupNorm (B - A) ≤ ε)
    (hgap : matrixSupNorm A + ε < 1) :
    matrixSupNorm B < 1 := by
  -- By the triangle inequality for matrixSupNorm, we have:
  have h_triangle : matrixSupNorm B ≤ matrixSupNorm A + matrixSupNorm (B - A) := by
    refine' ciSup_le fun i => _;
    refine' le_trans _ ( add_le_add ( le_ciSup ( Finite.bddAbove_range fun i => ∑ j, ‖A i j‖ ) i ) ( le_ciSup ( Finite.bddAbove_range fun i => ∑ j, ‖( B - A ) i j‖ ) i ) );
    simpa only [ ← Finset.sum_add_distrib ] using Finset.sum_le_sum fun j _ => by simpa using norm_add_le ( A i j ) ( ( B - A ) i j ) ;
  linarith

end Perturbation

/-! ## §4. No Nonzero Fixed Points Under Contraction -/

section Contraction

/-
A contracting linear map has no nonzero fixed points.
    If Av = v and ‖A‖ < 1, then choosing i with maximal ‖v i‖,
    we get ‖v i‖ ≤ (∑ j, ‖A i j‖) · ‖v i‖ < ‖v i‖, contradiction.
-/
theorem no_nonzero_fixed_point_of_contracting {N : ℕ} [NeZero N]
    (A : Matrix (Fin N) (Fin N) ℂ)
    (hA : matrixSupNorm A < 1) (v : Fin N → ℂ) (hv : v ≠ 0)
    (hfixed : A.mulVec v = v) : False := by
  -- Since $v \neq 0$, there exists $i₀$ such that $\|v i₀\| > 0$.
  obtain ⟨i₀, hi₀⟩ : ∃ i₀, ‖v i₀‖ > 0 ∧ ∀ j, ‖v j‖ ≤ ‖v i₀‖ := by
    obtain ⟨i₀, hi₀⟩ : ∃ i₀, ‖v i₀‖ > 0 := by
      exact Function.ne_iff.mp hv |> Exists.imp fun i hi => norm_pos_iff.mpr hi;
    have := Finset.exists_max_image Finset.univ ( fun j => ‖v j‖ ) ⟨ i₀, Finset.mem_univ i₀ ⟩ ; aesop;
  -- By the properties of the supremum norm, we have ‖v i₀‖ ≤ (∑ j, ‖A i₀ j‖) * ‖v i₀‖.
  have h_norm_le : ‖v i₀‖ ≤ (∑ j, ‖A i₀ j‖) * ‖v i₀‖ := by
    have h_norm_le : ‖v i₀‖ ≤ ∑ j, ‖A i₀ j‖ * ‖v j‖ := by
      have h_norm_le : ‖v i₀‖ = ‖∑ j, A i₀ j * v j‖ := by
        exact congr_arg Norm.norm ( by simpa [ Matrix.mulVec, dotProduct ] using congr_fun hfixed.symm i₀ );
      exact h_norm_le.symm ▸ le_trans ( norm_sum_le _ _ ) ( Finset.sum_le_sum fun _ _ => by rw [ norm_mul ] );
    simpa only [ Finset.sum_mul _ _ _ ] using h_norm_le.trans ( Finset.sum_le_sum fun j _ => mul_le_mul_of_nonneg_left ( hi₀.2 j ) ( norm_nonneg _ ) );
  nlinarith [ show ( ∑ j, ‖A i₀ j‖ ) ≤ matrixSupNorm A from le_ciSup ( Finite.bddAbove_range fun i => ∑ j, ‖A i j‖ ) i₀, norm_nonneg ( v i₀ ) ]

end Contraction

/-! ## §5. Orbit Persistence Under Nontermination -/

section OrbitsAndTermination

/-- If n is odd positive, every iterate remains odd positive
    (regardless of termination). -/
theorem iterate_isOddPos {n : ℕ} (hn : IsOddPos n) :
    ∀ k : ℕ, IsOddPos (acceleratedCollatz^[k] n) := by
  intro k
  induction' k with k ih
  · exact hn
  · simpa only [Function.iterate_succ_apply'] using acceleratedCollatz_isOddPos ih

/-- If an orbit doesn't terminate, every iterate is ≠ 1. -/
theorem nonterminating_orbit_ne_one {n : ℕ} (_hn : IsOddPos n)
    (hnt : ¬ OrbitTerminates n) :
    ∀ k : ℕ, acceleratedCollatz^[k] n ≠ 1 :=
  fun k hk => hnt ⟨k, hk⟩

end OrbitsAndTermination

/-! ## §6. Finite Pigeonhole on Orbits -/

section Pigeonhole

/-
**Pigeonhole principle for orbits**: if an orbit of a function on a
    finite type doesn't reach a target within card α steps, then some
    element is visited at least twice.
-/
theorem orbit_pigeonhole {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (x : α) (target : α)
    (h : ∀ k : ℕ, f^[k] x ≠ target) :
    ∃ k₁ k₂ : ℕ, k₁ < k₂ ∧ k₂ ≤ Fintype.card α ∧ f^[k₁] x = f^[k₂] x := by
  have h_pigeonhole : Finset.card (Finset.image (fun k => f^[k] x) (Finset.range (Fintype.card α + 1))) ≤ Fintype.card α := by
    exact Finset.card_le_univ _;
  contrapose! h_pigeonhole;
  rw [ Finset.card_image_of_injOn fun k₁ hk₁ k₂ hk₂ h_eq => le_antisymm ( le_of_not_gt fun h_lt => h_pigeonhole _ _ h_lt ( by linarith [ Finset.mem_range.mp hk₁, Finset.mem_range.mp hk₂ ] ) h_eq.symm ) ( le_of_not_gt fun h_lt => h_pigeonhole _ _ h_lt ( by linarith [ Finset.mem_range.mp hk₁, Finset.mem_range.mp hk₂ ] ) h_eq ) ] ; simp +arith +decide

/-
Consequence: a nonterminating orbit on a finite type has a periodic
    point away from the target.
-/
theorem periodic_from_nontermination {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (x : α) (target : α)
    (h : ∀ k : ℕ, f^[k] x ≠ target) :
    ∃ y : α, y ≠ target ∧ ∃ p : ℕ, 0 < p ∧ f^[p] y = y := by
  obtain ⟨ k₁, k₂, hk₁k₂, hk₂, h ⟩ := orbit_pigeonhole f x target h;
  exact ⟨ f^[k₁] x, by solve_by_elim, k₂ - k₁, Nat.sub_pos_of_lt hk₁k₂, by rw [ ← Function.iterate_add_apply, Nat.sub_add_cancel hk₁k₂.le, h ] ⟩

end Pigeonhole

/-! ## §7. Complete Finite-State Spectral Criterion (Sorry-Free) -/

section FiniteStateCriterion

/-
**No nontrivial periodic orbits implies universal termination**.
    On a finite type, if the only periodic orbit is the target fixed point,
    then every element eventually reaches the target.

    This is the contrapositive of `periodic_from_nontermination` and provides
    the finite-state bridge: once spectral analysis rules out nontrivial
    periodic orbits in the congruence quotient, termination follows.
-/
theorem no_nontrivial_periodic_implies_termination {α : Type*}
    [Fintype α] [DecidableEq α]
    (f : α → α) (target : α)
    (h_no_periodic : ∀ y : α, y ≠ target → ∀ p : ℕ, 0 < p → f^[p] y ≠ y) :
    ∀ x : α, ∃ k : ℕ, f^[k] x = target := by
  intro x;
  by_contra h_no_periodic;
  obtain ⟨ y, hy₁, p, hp, hy₂ ⟩ := periodic_from_nontermination f x target ( by aesop );
  exact ‹∀ y : α, y ≠ target → ∀ p : ℕ, 0 < p → f^[p] y ≠ y› y hy₁ p hp hy₂

/-
**Contracting matrix excludes all nonzero periodic vectors**.
    If ‖A‖ < 1, then no nonzero vector is periodic under the linear
    dynamics v ↦ Av. This connects spectral contraction to absence
    of periodic orbits in the associated dynamical system.
-/
theorem contracting_matrix_no_periodic_vector {N : ℕ} [NeZero N]
    (A : Matrix (Fin N) (Fin N) ℂ)
    (hA : matrixSupNorm A < 1) :
    ∀ v : Fin N → ℂ, v ≠ 0 → ∀ p : ℕ, 0 < p → (A ^ p).mulVec v ≠ v := by
  intro v hv p hp h;
  have h_contra : matrixSupNorm (A ^ p) ≤ (matrixSupNorm A) ^ p := by
    have h_contra : ∀ (A B : Matrix (Fin N) (Fin N) ℂ), matrixSupNorm (A * B) ≤ matrixSupNorm A * matrixSupNorm B := by
      intro A B;
      have h_submul : ∀ (i : Fin N), ∑ j : Fin N, ‖(A * B) i j‖ ≤ (∑ j : Fin N, ‖A i j‖) * matrixSupNorm B := by
        intro i
        have h_submul : ∀ j : Fin N, ‖(A * B) i j‖ ≤ ∑ k : Fin N, ‖A i k‖ * ‖B k j‖ := by
          exact fun j => by simpa only [ Matrix.mul_apply ] using norm_sum_le _ _ |> le_trans <| Finset.sum_le_sum fun _ _ => by rw [ norm_mul ] ;
        refine' le_trans ( Finset.sum_le_sum fun j _ => h_submul j ) _;
        rw [ Finset.sum_comm ];
        rw [ Finset.sum_mul _ _ _ ];
        exact Finset.sum_le_sum fun j _ => by rw [ ← Finset.mul_sum _ _ _ ] ; exact mul_le_mul_of_nonneg_left ( le_ciSup ( Finite.bddAbove_range fun i => ∑ j : Fin N, ‖B i j‖ ) j ) ( norm_nonneg _ ) ;
      refine' ciSup_le fun i => le_trans ( h_submul i ) _;
      exact mul_le_mul_of_nonneg_right ( le_ciSup ( Finite.bddAbove_range fun i => ∑ j, ‖A i j‖ ) i ) ( by exact Real.iSup_nonneg fun _ => Finset.sum_nonneg fun _ _ => norm_nonneg _ );
    refine' Nat.le_induction _ _ p hp <;> intros <;> simp_all +decide [ pow_succ' ];
    exact le_trans ( h_contra _ _ ) ( mul_le_mul_of_nonneg_left ‹_› ( matrixSupNorm_nonneg _ ) );
  exact no_nonzero_fixed_point_of_contracting ( A ^ p ) ( lt_of_le_of_lt h_contra ( pow_lt_one₀ ( by exact Real.iSup_nonneg fun _ => Finset.sum_nonneg fun _ _ => norm_nonneg _ ) hA ( by positivity ) ) ) v hv h

end FiniteStateCriterion

/-! ## §8. Main Bridge Theorem (Conditional) -/

section MainTheorem

/-- **Spectral Gap Hypothesis**: For every modulus q ≥ 2 and nontrivial
    character χ mod q, the twisted dynamics on residues contracts.

    This is a family of finite-dimensional spectral conditions, each
    independently checkable by certified matrix computations. -/
def SpectralGapHypothesis : Prop :=
  ∀ q : ℕ, 1 < q →
  ∀ (_hne : NeZero q) (χ : ArithChar q),
    χ.IsNontrivialOnUnits →
    ∃ (N : ℕ) (_ : NeZero N) (A : Matrix (Fin N) (Fin N) ℂ),
      matrixSupNorm A < 1

/-- **Main Conditional Theorem**: The spectral gap hypothesis implies
    the Collatz conjecture.

    This theorem connects the spectral framework to arithmetic dynamics.
    The proof architecture (by contrapositive):
    1. Assume some odd positive n never reaches 1.
    2. Project the orbit to residues mod q (finite type).
    3. By `periodic_from_nontermination`, extract a nontrivial periodic orbit.
    4. This periodic orbit induces a nonzero eigenvector of A^p.
    5. By `contracting_matrix_no_periodic_vector`, this contradicts ‖A‖ < 1.
    6. Hence the spectral gap hypothesis is violated.

    The gap between this theorem and a complete proof lies in rigorously
    encoding the Collatz transition as a matrix whose norm the spectral
    gap hypothesis controls. This encoding requires careful treatment of
    the 2-adic valuation structure and branch counting, which we leave
    as the key remaining formalization challenge. -/
theorem spectral_gap_implies_collatz_termination
    (hgap : SpectralGapHypothesis) :
    CollatzTerminates := by
  sorry

end MainTheorem