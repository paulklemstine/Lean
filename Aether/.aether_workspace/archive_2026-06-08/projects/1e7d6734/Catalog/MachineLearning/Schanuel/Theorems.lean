import Speculative.Schanuel.Defs

/-!
# Schanuel Conjecture: Main Theorems

This file proves three substantial theorems within the axiomatic Schanuel framework:

1. **`schanuel_implies_lindemann_weierstrass`**: Under the Schanuel axiom, `ℚ`-linearly
   independent algebraic numbers have algebraically independent exponentials.
2. **`algebraic_logs_force_q_dependence`**: Under the Schanuel axiom, if both `z i` and
   `exp(z i)` are algebraic for all `i`, then `z` must be `ℚ`-linearly dependent.
3. **`schanuelCritical_has_exp_witness`**: A Schanuel-critical tuple necessarily carries an
   explicit `ExpAlgDependenceWitness`.

We also prove cross-domain results connecting the witness structure to algebraic independence.
-/

noncomputable section

open Complex MvPolynomial

/-!
## Theorem 1: Schanuel implies Lindemann–Weierstrass
-/

/-- **Lindemann–Weierstrass from Schanuel**: Under the Schanuel axiom, if `z : Fin n → ℂ`
is `ℚ`-linearly independent and each `z i` is algebraic over `ℚ`, then the exponentials
`fun i => exp(z i)` are algebraically independent over `ℚ`. -/
theorem schanuel_implies_lindemann_weierstrass
    [hS : SchanuelAxiom]
    {n : ℕ}
    (z : Fin n → ℂ)
    (hlin : LinearIndependent ℚ z)
    (halg : ∀ i, IsAlgebraic ℚ (z i)) :
    AlgebraicIndependent ℚ (fun i => Complex.exp (z i)) :=
  hS.exp_algIndep_of_lin_indep_algebraic z hlin halg

/-
Under Schanuel, a nonzero algebraic number has transcendental exponential.
This recovers the Hermite–Lindemann theorem.
-/
theorem schanuel_implies_exp_transcendental
    [hS : SchanuelAxiom]
    (α : ℂ)
    (hα_ne : α ≠ 0)
    (hα_alg : IsAlgebraic ℚ α) :
    Transcendental ℚ (Complex.exp α) := by
  have := hS.exp_algIndep_of_lin_indep_algebraic (fun _ : Fin 1 => α) ?_ ?_ <;> simp_all +decide

/-- Under Schanuel, if there is an algebraic dependence among exponentials of
linearly independent algebraic numbers, we obtain a contradiction. -/
theorem schanuel_contradiction_from_exp_relation
    [hS : SchanuelAxiom]
    {n : ℕ}
    (z : Fin n → ℂ)
    (hlin : LinearIndependent ℚ z)
    (halg : ∀ i, IsAlgebraic ℚ (z i))
    (p : MvPolynomial (Fin n) ℚ)
    (hp_ne : p ≠ 0)
    (hp_van : MvPolynomial.aeval (fun i => Complex.exp (z i)) p = 0) :
    False := by
  have hindep := schanuel_implies_lindemann_weierstrass z hlin halg
  exact hp_ne (hindep (show _ = _ from by rw [hp_van, map_zero]))

/-!
## Theorem 2: Algebraic logarithms force rational dependence
-/

/-- **Algebraic logs force `ℚ`-dependence**: Under the Schanuel axiom, if `z : Fin n → ℂ`
has all coordinates algebraic and all exponentials algebraic, then the tuple is
`ℚ`-linearly dependent.

**Proof**: By contradiction. If `z` is linearly independent, then by Schanuel the exponentials
are algebraically independent. In particular each `exp(z i)` is transcendental
(via `AlgebraicIndependent.transcendental`), contradicting the assumption that each
`exp(z i)` is algebraic. The `Fin n` index type must be nonempty for this to be nontrivial;
when `n = 0` the statement is vacuously true since `Fin 0` is empty and the empty family is
linearly dependent (it is not linearly independent, as `linearIndependent_empty_type` shows). -/
theorem algebraic_logs_force_q_dependence
    [hS : SchanuelAxiom]
    {n : ℕ}
    (z : Fin n → ℂ)
    (hn : 0 < n)
    (hz_alg : ∀ i, IsAlgebraic ℚ (z i))
    (hexp_alg : ∀ i, IsAlgebraic ℚ (Complex.exp (z i))) :
    ¬ LinearIndependent ℚ z := by
  intro hlin
  have hindep := schanuel_implies_lindemann_weierstrass z hlin hz_alg
  have htrans := hindep.transcendental
  exact (htrans ⟨0, hn⟩) (hexp_alg ⟨0, hn⟩)

/-!
## Theorem 3: Schanuel-critical tuples carry witnesses
-/

/-- A Schanuel-critical tuple has a nonzero polynomial vanishing on its exponentials. -/
theorem schanuelCritical_has_exp_witness
    {n : ℕ} {z : Fin n → ℂ}
    (hcrit : IsSchanuelCritical z) :
    ∃ (p : MvPolynomial (Fin n) ℚ), p ≠ 0 ∧
      MvPolynomial.aeval (fun i => Complex.exp (z i)) p = 0 :=
  exp_dep_witness hcrit.exp_dep

/-- Under Schanuel, there are no Schanuel-critical tuples of any size. -/
theorem schanuel_no_critical_any_size
    [hS : SchanuelAxiom] :
    ∀ (n : ℕ) (z : Fin n → ℂ), ¬ IsSchanuelCritical z :=
  fun _ z => no_critical_of_schanuel z

/-!
## Cross-Domain: Witness certification
-/

/-- Any nonzero polynomial relation among `exp(z i)` certifies that the exponentials
are not algebraically independent. -/
theorem exp_witness_certifies_dependence
    {n : ℕ} {z : Fin n → ℂ}
    (p : MvPolynomial (Fin n) ℚ)
    (hp : p ≠ 0)
    (hv : MvPolynomial.aeval (fun i => Complex.exp (z i)) p = 0) :
    ¬ AlgebraicIndependent ℚ (fun i => Complex.exp (z i)) := by
  intro h
  exact hp (h (show _ = _ from by rw [hv, map_zero]))

/-- Contrapositive: algebraic independence means no nonzero polynomial vanishes. -/
theorem algIndep_implies_no_witness
    {n : ℕ} {z : Fin n → ℂ}
    (h : AlgebraicIndependent ℚ (fun i => Complex.exp (z i)))
    (p : MvPolynomial (Fin n) ℚ)
    (hp : p ≠ 0) :
    MvPolynomial.aeval (fun i => Complex.exp (z i)) p ≠ 0 := by
  intro hv
  exact hp (h (show _ = _ from by rw [hv, map_zero]))

/-- Under Schanuel, algebraic base points with linear independence yield a complete
absence of exponential polynomial relations. -/
theorem schanuel_no_exp_witness
    [hS : SchanuelAxiom]
    {n : ℕ}
    (z : Fin n → ℂ)
    (hlin : LinearIndependent ℚ z)
    (halg : ∀ i, IsAlgebraic ℚ (z i))
    (p : MvPolynomial (Fin n) ℚ)
    (hp : p ≠ 0) :
    MvPolynomial.aeval (fun i => Complex.exp (z i)) p ≠ 0 :=
  algIndep_implies_no_witness (schanuel_implies_lindemann_weierstrass z hlin halg) p hp

/-!
## Structural result: critical tuples cannot have size 0
-/

/-
A Schanuel-critical tuple cannot have size 0.
-/
theorem not_schanuelCritical_zero (z : Fin 0 → ℂ) :
    ¬ IsSchanuelCritical z := by
  rintro ⟨ lin_indep, all_algebraic, exp_dep, proper_subtuples_indep ⟩;
  refine' exp_dep _;
  convert algebraicIndependent_empty_type;
  · infer_instance;
  · infer_instance

end