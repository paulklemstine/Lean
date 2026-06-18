# Future Directions: Axiomatic Transcendence Theory in Theorem Provers

This document identifies 5 specific, testable scientific hypotheses emerging from our formal framework for Schanuel's conjecture. Each hypothesis is falsifiable and comes with a concrete validation plan.

---

## Hypothesis 1: Full Lindemann–Weierstrass from Schanuel via Algebraic Independence

**Conjecture:** The full Lindemann–Weierstrass theorem — that for Q-linearly independent algebraic numbers α₁, …, αₙ, the exponentials exp(α₁), …, exp(αₙ) are *algebraically independent* over Q — can be derived from Schanuel's conjecture using only the existing Mathlib API for `AlgebraicIndependent`, `Algebra.trdeg`, and `Algebra.adjoin`, in under 500 lines of additional code beyond our current framework.

**Test:** Attempt to formalize the stronger statement:
```
theorem schanuel_implies_lw_strong (SC : SchanuelConjecture) {n : ℕ} (a : Fin n → ℂ)
    (ha_alg : ∀ i, IsAlgebraic ℚ (a i)) (ha_lin : LinearIndependent ℚ a) :
    AlgebraicIndependent ℚ (fun i => Complex.exp (a i))
```
The key technical challenge is connecting the transcendence degree lower bound from Schanuel to the algebraic independence of the exponentials. The argument requires showing that if the z_i are algebraic, the transcendence degree of Q(z₁,...,zₙ,exp(z₁),...,exp(zₙ)) equals the transcendence degree of Q(exp(z₁),...,exp(zₙ)), which needs `trdeg` additivity for algebraic extensions.

**Impact:** This would give the first machine-checked proof that Schanuel implies the strongest classical form of Lindemann–Weierstrass, enabling certified transcendence and algebraic independence results in computer algebra systems.

---

## Hypothesis 2: Schanuel Implies Algebraic Independence of e and π

**Conjecture:** Using the family z₁ = 1, z₂ = iπ in Schanuel's conjecture, one can formally derive that e and π are algebraically independent over Q, in under 300 lines. The key steps are:
1. Show {1, iπ} is Q-linearly independent (requires π is irrational, which is in Mathlib).
2. Apply Schanuel to get trdeg(Q(1, iπ, e, e^(iπ))) ≥ 2.
3. Use e^(iπ) = -1 ∈ Q to simplify: trdeg(Q(iπ, e)) ≥ 2.
4. Conclude e and π (hence iπ) are algebraically independent.

**Test:** Formalize this chain of reasoning. The primary blocker is likely step 3: showing that removing algebraic elements from the generating set doesn't reduce the transcendence degree. Check whether `Algebra.trdeg` has the needed monotonicity/additivity properties in Mathlib.

**Impact:** The algebraic independence of e and π is one of the most famous open problems in number theory. A formal proof that it follows from Schanuel would be a landmark result in formalized mathematics.

---

## Hypothesis 3: Abstract Exponential Field Typeclass Generalization

**Conjecture:** The entire Schanuel framework (definitions, conditional consequences, shadow theorems) can be refactored to work over an abstract exponential field typeclass:
```
class ExponentialField (F : Type*) extends Field F where
  exp : F → F
  exp_add : ∀ a b, exp (a + b) = exp a * exp b
  exp_zero : exp 0 = 1
```
with no change to the linear-algebra layer, and at most 5 complex-specific lemmas needed for the instantiation to ℂ.

**Test:** Define the typeclass, restate `SchanuelProp` and all consequences generically, and count the number of lemmas that require `Complex`-specific arguments. Success criterion: the generic framework compiles and the ℂ instantiation requires ≤ 5 additional lemmas.

**Impact:** This would enable the framework to apply to p-adic exponentials, formal power series exponentials, and model-theoretic exponential fields (connecting to Zilber's pseudo-exponentiation and Ax–Schanuel).

---

## Hypothesis 4: Transcendence Degree Additivity for Algebraic Extensions

**Conjecture:** The following lemma, which is crucial for upgrading the weak Lindemann–Weierstrass to the strong form, can be proved using current Mathlib infrastructure:

"If K ⊆ L ⊆ M are field extensions with L/K algebraic, then trdeg(M/K) = trdeg(M/L)."

More precisely:
```
theorem trdeg_eq_of_algebraic_intermediate (K L M : Type*) [Field K] [Field L] [Field M]
    [Algebra K L] [Algebra L M] [Algebra K M] [IsScalarTower K L M]
    [Algebra.IsAlgebraic K L] :
    Algebra.trdeg K M = Algebra.trdeg L M
```

**Test:** Attempt to prove this directly from Mathlib's `transcendenceBasis` and `AlgebraicIndependent` API. The expected approach: a transcendence basis of M/L is also algebraically independent over K (since L/K is algebraic), and conversely any K-algebraically independent set in M is L-algebraically independent.

**Impact:** This is the key missing infrastructure lemma. Its proof would immediately unlock the full Lindemann–Weierstrass consequence and many other transcendence-degree arguments.

---

## Hypothesis 5: Counterexample-Driven Discovery of ≥ 3 False Formulations

**Conjecture:** At least 3 natural but mathematically false formal statements of Schanuel-type results can be constructed and formally refuted in Lean:

1. **"exp of algebraic is transcendental" (without nonzero condition):** False because exp(0) = 1. Our framework already contains this counterexample (`exp_zero_algebraic`).

2. **"Schanuel over ℤ instead of ℚ":** Replacing Q-linear independence with Z-linear independence changes the statement (Z-linear independence is strictly weaker since Q is the fraction field of Z, making the hypothesis easier to satisfy but the conclusion unchanged — actually Z-linear independence and Q-linear independence coincide for torsion-free modules, so this may not give a counterexample. Test whether the formalization reveals a subtlety.)

3. **"Schanuel without linear independence":** The statement "trdeg(Q(z₁,...,zₙ,exp(z₁),...,exp(zₙ))) ≥ n for any n distinct complex numbers" is false: take z₁ = 0, z₂ = log(2), ..., and all are algebraic after exponentiation while having small transcendence degree.

4. **"exp of distinct algebraic implies linear independence of exponentials over Q":** False because exp(0) = 1, exp(1) = e, and 1·exp(0) + 0·exp(1) = 1, which is a Q-linear relation if we're not careful about the formulation.

**Test:** Formalize each false statement and either (a) produce a Lean proof of its negation, or (b) exhibit a concrete counterexample via `#eval` or explicit construction.

**Impact:** This systematic counterexample analysis refines the formal statement of Schanuel to its canonical form and builds intuition for correct formalization of transcendence conjectures.

---

## Summary Table

| # | Hypothesis | Difficulty | Estimated LOC | Key Blocker |
|---|-----------|-----------|---------------|-------------|
| 1 | Full LW from Schanuel | Hard | ~500 | trdeg additivity for algebraic extensions |
| 2 | e, π algebraically independent | Medium | ~300 | π irrationality + trdeg of quotient |
| 3 | Abstract exponential field | Medium | ~400 | Typeclass design + instantiation |
| 4 | trdeg additivity | Hard | ~200 | Deep Mathlib algebraic independence API |
| 5 | ≥ 3 counterexamples | Easy | ~150 | Finding the right false statements |

---

## Long-Term Vision

These hypotheses, if validated, would establish the first comprehensive formal infrastructure for transcendence theory in a theorem prover. The framework would enable:

- **Certified transcendence proofs** in computer algebra systems
- **Formal comparison** of axiom systems (Schanuel, Ax–Schanuel, exponential algebraic closure)
- **Machine-checked derivations** of conditional transcendence results
- **Automated discovery** of new consequences via proof search
- **Cross-domain formalization** connecting transcendence theory to model theory, differential algebra, and arithmetic geometry
