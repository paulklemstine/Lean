# A Formally Verified Tropical Riesz Representation Theorem

## Abstract

We present the first machine-verified proof of the tropical (max-plus) Riesz representation theorem: every idempotent max-plus linear functional on continuous functions over a finite space is uniquely represented as a Shilkret integral against a weight function. The formalization is carried out in Lean 4 with the Mathlib library, establishing the discrete case as a stepping stone toward the full compact Hausdorff theory. We define tropical functionals, prove the tropical basis decomposition, establish the representation formula, and prove uniqueness of the representing weight. The theorem gives an algorithmic normal form for max-plus linear functionals and opens the door to formally verified tropical duality theory.

**Keywords**: tropical algebra, max-plus semiring, Riesz representation, Shilkret integral, formal verification, Lean 4

## 1. Introduction

The Riesz representation theorem is one of the cornerstones of functional analysis: every positive linear functional on the space of continuous functions on a compact Hausdorff space is integration against a unique regular Borel measure. This theorem connects algebra (linear functionals) to geometry (measures), and is foundational for probability theory, spectral theory, and harmonic analysis.

In this paper, we establish the *tropical* analogue of this theorem. The max-plus semiring (ℝ ∪ {-∞}, max, +) — where "addition" is max and "multiplication" is ordinary addition — arises naturally in optimization, control theory, and tropical geometry. A *tropical functional* is a map Λ from continuous functions to ℝ ∪ {-∞} that preserves max (tropical addition) and commutes with additive translation (tropical scalar multiplication). The tropical Riesz theorem states:

> **Theorem (Discrete Tropical Riesz Representation).** Let X be a finite set. Every tropical functional Λ on functions X → ℝ ∪ {-∞} is uniquely represented by a weight function w : X → ℝ ∪ {-∞} such that
>
> Λ(f) = max_{x ∈ X} (w(x) + f(x))
>
> for all f. The weight is uniquely determined by w(x) = Λ(δ_x), where δ_x is the tropical basis function at x.

This representation as a supremum of shifted values is precisely the **Shilkret integral** — the max-plus analogue of the Lebesgue integral. The weight function w plays the role of a maxitive measure (also called a possibility measure or Maslov measure in different communities).

### 1.1 Contributions

1. **Formal definitions** of tropical continuous functions, tropical functionals, and their algebraic axioms in Lean 4.
2. **Tropical basis decomposition**: any function on a finite set is a finite tropical supremum of shifted Dirac profiles.
3. **Representation formula**: Λ(f) = max_x (w(x) + f(x)) for all f, proved by combining the basis decomposition with finite sup preservation.
4. **Uniqueness**: the weight w is uniquely determined by w(x) = Λ(δ_x), proved by evaluating the representation on basis functions.
5. **Infrastructure for the compact case**: definitions of tropical capacity, tropical integral, upper-continuous functionals, and evaluation functionals, with partial results.

### 1.2 Related Work

The classical Riesz-Markov-Kakutani representation theorem has been formalized in Lean/Mathlib. Our work is, to our knowledge, the first formalization of any tropical analogue.

In the mathematical literature, tropical Riesz-type results appear implicitly in the work of Maslov on idempotent analysis, Litvinov and Maslov on idempotent functional analysis, and Kolokoltsov and Maslov on idempotent probability. The Shilkret integral was introduced by Shilkret (1971) as the "maxitive integral." The connection between max-plus linear functionals and maxitive measures was developed by Akian, Gaubert, and Kolokoltsov in the context of idempotent measure theory.

Our contribution is to give the first complete formal verification of these results, making the proofs machine-checkable and establishing a foundation for further formalization.

## 2. Mathematical Framework

### 2.1 The Max-Plus Semiring

The **max-plus semiring** is the set ℝ_max = ℝ ∪ {-∞} equipped with:
- **Tropical addition**: a ⊕ b = max(a, b)
- **Tropical multiplication**: a ⊙ b = a + b
- **Additive identity**: 𝟎 = -∞
- **Multiplicative identity**: 𝟏 = 0

This is a commutative idempotent semiring (a ⊕ a = a for all a).

In Lean 4, we represent this as `WithBot ℝ`, where `⊥` corresponds to -∞. The lattice structure provides `⊔` (= max = tropical addition) and the additive structure provides `+` (= tropical multiplication).

### 2.2 Tropical Continuous Functions

For a topological space X, we define:

```
TropCont X = C(X, WithBot ℝ)
```

the space of continuous functions from X to WithBot ℝ with the order topology. On a finite discrete space, every function is continuous, so TropCont X ≅ (WithBot ℝ)^X.

### 2.3 Tropical Functionals

A **tropical functional** on TropCont X is a map Λ : TropCont X → WithBot ℝ satisfying:

1. **Sup-preservation** (tropical additivity): Λ(f ⊔ g) = Λ(f) ⊔ Λ(g)
2. **Constant normalization**: Λ(const c) = c for all c ∈ WithBot ℝ
3. **Translation equivariance** (tropical homogeneity): Λ(c + f) = c + Λ(f)
4. **Monotonicity**: f ≤ g pointwise ⟹ Λ(f) ≤ Λ(g)

These axioms are the tropical counterparts of positivity and linearity in the classical setting.

**Remark.** The normalization axiom Λ(const c) = c follows from translation equivariance and Λ(const 0) = 0, since const c = c + const 0. We include it explicitly for convenience.

### 2.4 Tropical Basis Functions

For each point x₀ ∈ X, the **tropical basis function** (or tropical Dirac delta) is:

```
δ_{x₀}(y) = 0    if y = x₀
δ_{x₀}(y) = -∞   if y ≠ x₀
```

This is the tropical analogue of the indicator function 1_{x₀}.

## 3. The Discrete Tropical Riesz Theorem

### 3.1 Tropical Basis Decomposition

**Lemma.** For any function f : X → WithBot ℝ on a finite set X:

f(y) = max_{x ∈ X} (f(x) + δ_x(y))

*Proof.* The term for x = y contributes f(y) + 0 = f(y). Every other term contributes f(x) + (-∞) = -∞ ≤ f(y). Hence the maximum equals f(y). □

This lemma says that every function is a tropical linear combination of basis functions. It is the tropical analogue of writing a function as a linear combination of indicator functions.

### 3.2 The Representation Formula

**Theorem.** For any tropical functional Λ on a finite nonempty space X, with w(x) = Λ(δ_x):

Λ(f) = max_{x ∈ X} (w(x) + f(x))

*Proof.* By the basis decomposition, f = max_x (f(x) + δ_x). By translation equivariance, Λ(f(x) + δ_x) = f(x) + w(x). By finite sup preservation (proved by induction from the binary case):

Λ(f) = max_x Λ(f(x) + δ_x) = max_x (w(x) + f(x)) □

### 3.3 Uniqueness

**Theorem.** The weight function w is unique.

*Proof.* If w₁, w₂ both represent Λ, evaluate on δ_y:

max_x (w_i(x) + δ_y(x)) = w_i(y)

So w₁(y) = Λ(δ_y) = w₂(y) for all y. □

### 3.4 Lean Formalization

The full theorem in Lean 4:

```lean
theorem tropical_riesz_finite [Nonempty X]
    (Λ : TropicalFunctional X) :
    ∃! w : X → WithBot ℝ,
      ∀ f : TropCont X,
        Λ.toFun f = Finset.univ.sup (fun x => w x + f x)
```

All proofs compile without `sorry` and depend only on the standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

## 4. Toward the Compact Case

### 4.1 Evaluation Functionals

For any point x₀ ∈ X, evaluation at x₀ defines a tropical functional Λ_{x₀}(f) = f(x₀). Its weight function is the tropical Dirac delta δ_{x₀}. This is formally verified.

### 4.2 Tropical Capacity

For a compact Hausdorff space X, we define the tropical capacity:

μ_K(Λ) = inf { Λ(f) | f ≥ 0 on K }

We prove monotonicity and the empty-set value μ_∅ = -∞.

### 4.3 Extensionality Conjecture

We state (but leave unproven) the extensionality principle: if two upper-continuous tropical functionals agree on a dense subsemialgebra, they are equal. This is the key step for the compact Hausdorff generalization.

## 5. Applications

### 5.1 Algorithmic Parameter Recovery

The theorem provides an efficient algorithm: given any max-plus linear oracle, recover its internal weights by querying n basis functions. This has applications in:

- **Inverse optimization**: recovering costs from observed optimal decisions
- **System identification**: identifying parameters of max-plus linear systems
- **Machine learning**: extracting features from tropical neural networks

### 5.2 Dynamic Programming

In the min-plus dual setting, the theorem says every Bellman-type value function is decomposable into individual state costs. This gives a canonical representation for value functions in dynamic programming and optimal control.

### 5.3 Tropical Probability

The weight function is a Maslov measure. The normalization max_x w(x) = 0 is the tropical analogue of Σ μ(x) = 1. The Riesz theorem establishes the bijection between tropical expectations and tropical probability measures.

## 6. Discussion: Making the Invisible Visible

### A Parable for the General Reader

Suppose you encounter a mysterious device with a single dial. You can feed it any "landscape" — a function that assigns a height to each location — and the dial reports a single number. You discover two curious properties:

1. If you feed it two landscapes and it reports 7 and 3, then feeding it the landscape that takes the higher of the two at each point always gives 7 (the higher report).

2. If you uniformly raise every point of a landscape by 5 meters, the dial reading goes up by exactly 5.

What can you conclude about the device's inner workings?

The tropical Riesz theorem gives the answer: the device must contain a fixed set of "sensors," one at each location, each with a characteristic sensitivity. The dial reading is always "the best sensor reading" — the maximum over all sensors of (sensor sensitivity + landscape height at sensor location). Moreover, these sensitivities are uniquely determined.

This is a theorem about the hidden structure of systems that "take the best option." It says that any such system — no matter how complex its implementation — is secretly computing a weighted maximum. There is no other possibility.

### Why Formalization Matters

The classical Riesz representation theorem is typically proved using Urysohn's lemma, partition of unity arguments, and regularity properties of Borel measures. These are sophisticated tools, and errors in their application are easy to make. By formalizing the tropical analogue in Lean 4, we achieve:

1. **Certainty**: The proof is checked by a computer. There are no gaps, no "clearly" steps that hide difficulty, no appeal to the reader's intuition.
2. **Precision**: The exact hypotheses are explicit. We know precisely what algebraic axioms are needed (and which are redundant).
3. **Foundation**: Future work on tropical Choquet theory, tropical spectral theory, and tropical probability can build on these verified foundations.

## 7. Conclusion

The discrete tropical Riesz representation theorem — every max-plus linear functional is a Shilkret integral against a unique weight — is now formally verified. The proof is approximately 200 lines of Lean 4, building on Mathlib's lattice and order theory. The theorem gives an algorithmic normal form for tropical functionals and opens the door to formally verified tropical duality theory on compact spaces.

## References

1. F. Riesz, "Sur les opérations fonctionnelles linéaires," *C. R. Acad. Sci. Paris*, 1909.
2. V. P. Maslov, *Méthodes opératorielles*, Mir, Moscow, 1987.
3. G. L. Litvinov, V. P. Maslov, "Idempotent mathematics and mathematical physics," *Contemporary Mathematics*, vol. 377, AMS, 2005.
4. V. N. Kolokoltsov, V. P. Maslov, *Idempotent Analysis and Its Applications*, Kluwer, 1997.
5. N. Shilkret, "Maxitive measure and integration," *Indag. Math.*, vol. 33, pp. 109–116, 1971.
6. M. Akian, S. Gaubert, V. Kolokoltsov, "Set coverings and invertibility of functional Galois connections," in *Idempotent Mathematics and Mathematical Physics*, AMS, 2005.
7. The Mathlib Community, *Mathlib: a unified library of mathematics formalized in Lean*, 2024.
