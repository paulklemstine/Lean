# Future Directions: Evaluation-Kernel Calculus for Finite-Field Mathematics

This document outlines concrete next steps building on the formalized evaluation-kernel framework. Each direction includes a precise theorem statement, proof strategy, and cross-domain significance.

---

## 1. Reed–Muller Code Minimum Distance from Evaluation Injectivity

### Theorem Statement

```
theorem reed_muller_minimum_distance
    (q : ℕ) [Fact (Nat.Prime q)]
    (n d : ℕ) (hd : d < q)
    (f : MvPolynomial (Fin n) (ZMod q))
    (hf : f ≠ 0)
    (hdeg : ∀ m ∈ f.support, ∀ i, m i < q)
    (htotdeg : f.totalDegree ≤ d) :
    (q ^ n - d * q ^ (n - 1)) ≤
      (Finset.univ.filter (fun x : Fin n → ZMod q => MvPolynomial.eval x f ≠ 0)).card
```

### Proof Strategy

This is the converse face of the vanishing polynomial theorem. If a nonzero polynomial of total degree ≤ d over 𝔽_q can vanish on at most d · q^(n−1) points (by the Schwartz–Zippel lemma), then the number of nonzero evaluations is at least q^n − d · q^(n−1). This gives the minimum distance of the Reed–Muller code RM(q, n, d).

**Key steps:**
1. Formalize the Schwartz–Zippel lemma for finite fields (bound zeros of multivariate polynomials).
2. Use the complement counting argument: nonzero evaluations = total evaluations − zero evaluations.
3. The evaluation-kernel framework already provides the polynomial witness; this direction bounds how *many* zeros a nonzero polynomial can have.

### Cross-Domain Significance

Reed–Muller codes are foundational in coding theory, used in deep space communications, locally decodable codes, and probabilistically checkable proofs. Formalizing their distance bound would connect the polynomial method directly to verified coding theory.

---

## 2. Schwartz–Zippel Lemma via Evaluation Framework

### Theorem Statement

```
theorem schwartz_zippel
    (K : Type*) [Field K] [DecidableEq K]
    (n : ℕ) (S : Finset K)
    (f : MvPolynomial (Fin n) K)
    (hf : f ≠ 0)
    (d : ℕ) (hdeg : f.totalDegree ≤ d) :
    (S.pi (fun _ => S)).filter (fun x => MvPolynomial.eval (fun i => x i (Finset.mem_univ i)) f = 0)).card
      ≤ d * S.card ^ (n - 1)
```

*(Exact formalization may vary in how the product domain S^n is represented.)*

### Proof Strategy

Induction on the number of variables n.
- **Base case (n = 1):** A univariate polynomial of degree ≤ d has at most d roots. This follows from the fundamental theorem of algebra over fields, already available in Mathlib.
- **Inductive step:** Write f = Σᵢ gᵢ(x₁,...,x_{n-1}) · xₙⁱ. Fix x₁,...,x_{n-1} generically; the resulting univariate polynomial in xₙ has degree ≤ d. Apply the inductive hypothesis to handle the leading coefficient's zero set.

The evaluation linear map provides the structural framework: the zero set of f is exactly the preimage of 0 under the evaluation map.

### Cross-Domain Significance

Schwartz–Zippel is the workhorse of randomized polynomial identity testing (PIT), used in:
- Verifying matrix multiplication (Freivalds' algorithm)
- Polynomial identity testing in algebraic complexity
- Zero-knowledge proofs and interactive proof systems
- Randomized algorithms in computational geometry

---

## 3. Box-Degree Interpolation with Exact Dimension d^n

### Theorem Statement

```
theorem box_degree_interpolation_exact
    (K : Type*) [Field K]
    (n d : ℕ)
    (E : Finset (Fin n → K))
    (hE : E.card = d ^ n)
    (hVandermonde : -- E is in "general position" w.r.t. box-degree monomials) :
    ∀ f : E → K,
    ∃! p : MvPolynomial (Fin n) K,
      (∀ m ∈ p.support, ∀ i, m i < d) ∧
      ∀ x ∈ E, MvPolynomial.eval x p = f ⟨x, ‹x ∈ E›⟩
```

### Proof Strategy

When |E| = dim(box-degree space) = d^n and the evaluation matrix is invertible (the "general position" condition), the evaluation map is a bijection. This gives unique interpolation.

1. The box-degree evaluation map is a linear map between spaces of equal finite dimension d^n.
2. Injectivity is equivalent to: no nonzero box-degree polynomial vanishes on all of E.
3. By the vanishing theorem, if |E| = d^n, the kernel is zero only when the evaluation matrix has full rank.
4. Formalize the Vandermonde-like non-degeneracy condition for multivariate grids.

### Cross-Domain Significance

Interpolation is the dual of the vanishing theorem. Together they form a complete picture:
- **Vanishing:** too few points → nonzero annihilator exists.
- **Interpolation:** enough points in general position → unique representation.

Applications include multivariate secret sharing (Shamir-type schemes over grids), polynomial commitment schemes in cryptography, and multivariate numerical analysis.

---

## 4. Circuit Lower Bound Bridge via Polynomial Witnesses

### Theorem Statement

```
theorem circuit_degree_vs_vanishing_witness
    (K : Type*) [Field K] [Fintype K]
    (n : ℕ)
    (C : AlgCircuit K n)  -- algebraic circuit
    (E : Finset (Fin n → K))
    (d : ℕ)
    (hC_deg : C.degree_bound ≤ d)
    (hC_vanishes : ∀ x ∈ E, C.eval x = 0)
    (hE_large : d ^ n ≤ E.card) :
    C.eval = fun _ => 0  -- C computes the zero function
```

### Proof Strategy

Combine the circuit degree bound (`bounded_circuit_degree_bound` from the catalog) with the vanishing polynomial theorem:

1. If circuit C has degree bound ≤ d, then the polynomial it computes has total degree ≤ d.
2. If C vanishes on E with |E| ≥ d^n, and the polynomial has box-degree bounded by d in each variable (reduce modulo x^q = x over finite fields), then the polynomial must be zero.
3. This uses the contrapositive of our vanishing theorem: if |E| ≥ d^n, then no nonzero box-degree-d polynomial can vanish on all of E (when K = 𝔽_q with q > d).

This creates a formal bridge between algebraic circuit complexity and the polynomial method.

### Cross-Domain Significance

This direction connects to fundamental questions in algebraic complexity:
- Lower bounds on circuit size from evaluation constraints
- The VP vs. VNP question (Valiant's algebraic analog of P vs. NP)
- Polynomial identity testing and derandomization
- Rigidity lower bounds for matrix computation

---

## 5. Finite-Geometry Incidence Obstruction via Polynomial Vanishing

### Theorem Statement

```
theorem kakeya_finite_field_lower_bound
    (q : ℕ) [hq : Fact (Nat.Prime q)]
    (n : ℕ)
    (E : Finset (Fin n → ZMod q))
    (hE_kakeya : ∀ v : Fin n → ZMod q, v ≠ 0 →
      ∃ a : Fin n → ZMod q, ∀ t : ZMod q, (fun i => a i + t * v i) ∈ E) :
    (q : ℚ) ^ n / (Fintype.card (Fin n))! ≤ E.card
```

### Proof Strategy

This is the Dvir (2009) finite-field Kakeya theorem, proved using the polynomial method:

1. **Assume for contradiction** that |E| < C(n,q) (the dimension of the degree-< n(q−1)/n polynomial space, or a simpler bound).
2. By our vanishing theorem, there exists a nonzero polynomial f of controlled degree vanishing on all of E.
3. The Kakeya property means E contains a line in every direction. A polynomial vanishing on a line of q points must have degree ≥ q in that direction (over 𝔽_q).
4. But the degree bound from step 2 contradicts the degree requirement from step 3, giving the lower bound on |E|.

The key innovation is that step 2 is now *already formalized* — the vanishing polynomial theorem provides the witness directly.

### Cross-Domain Significance

The finite-field Kakeya conjecture (now theorem) was a landmark application of the polynomial method. Formalizing it would:
- Validate the polynomial method framework as a genuine research tool
- Connect to the Euclidean Kakeya conjecture (a major open problem in harmonic analysis)
- Demonstrate that formalized mathematics can handle modern research-level arguments
- Open paths to formalizing other polynomial method results (cap set bounds, Joints theorem)

---

## Implementation Priority

| Priority | Direction | Difficulty | Impact |
|----------|-----------|------------|--------|
| 1 | Schwartz–Zippel lemma | Medium | Very High — unlocks PIT, Reed–Muller, and more |
| 2 | Reed–Muller distance | Medium | High — direct coding theory application |
| 3 | Circuit lower bound bridge | Medium | High — connects to existing catalog |
| 4 | Box-degree interpolation | Medium-Hard | Medium — completes the interpolation/vanishing duality |
| 5 | Kakeya lower bound | Hard | Very High — research-level formalization milestone |

---

## Team Directive

Each direction above is specified with enough precision for a research team to:
1. **State the formal theorem** in Lean 4 with concrete types and hypotheses.
2. **Decompose into helper lemmas** following the proof strategy.
3. **Build on the existing evaluation-kernel framework** without re-deriving the linear algebra.
4. **Cross-reference** with the existing catalog (circuit complexity, Freivalds, commutative algebra).

The evaluation-kernel calculus is designed as a *reusable engine*. Every future direction instantiates the same pattern: define a polynomial space, construct the evaluation map, count dimensions, extract witnesses. This modularity is the key architectural insight that makes the framework a genuine research accelerator.
