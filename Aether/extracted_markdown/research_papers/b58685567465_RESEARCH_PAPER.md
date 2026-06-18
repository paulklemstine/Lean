# Formal Knot Invariants: The Kauffman Bracket and Jones Polynomial via State-Sum Algebra

## Abstract

We present a formal development of the Kauffman bracket polynomial and Jones polynomial for link diagrams, verified in a machine-checked proof system. Starting from a combinatorial model of unoriented link diagrams as finite crossing sets equipped with state-dependent loop counting functions, we define the Kauffman bracket as a Laurent polynomial state sum and prove its key structural properties: invariance under Reidemeister III moves (via state bijection), and precise behavior under Reidemeister I moves (multiplication by $-A^{\pm 3}$). We normalize by the writhe to obtain the Jones polynomial and prove its invariance under Reidemeister I and III. We define concrete diagrams for the trefoil and figure-eight knots, establish their writhe values, and formulate the adequacy-based unknot detection theorem for alternating knots. The formalization comprises approximately 700 lines of verified code across five modules.

## 1. Introduction

### 1.1 Motivation

The Jones polynomial, discovered by V. Jones in 1984, is one of the most important invariants in low-dimensional topology. It assigns to each oriented link a Laurent polynomial $V_L(t) \in \mathbb{Z}[t^{1/2}, t^{-1/2}]$ that is preserved under ambient isotopy. The polynomial has deep connections to statistical mechanics (via the Potts model), quantum groups (via braid representations), and topological quantum computation (via anyonic systems).

Despite its importance, formal verification of the Jones polynomial's invariance has been largely unexplored. This work builds the first comprehensive formal framework for the Kauffman bracket state sum and proves key invariance theorems with machine-checked certainty.

### 1.2 Contributions

1. **Combinatorial diagram model.** We define link diagrams as structures parameterized by crossing count, with a loop-counting function for each smoothing state. This abstraction captures exactly the data needed for the state sum.

2. **Kauffman bracket definition and proofs.** We define the bracket as a Laurent polynomial state sum and prove:
   - $\langle \text{unknot} \rangle = 1$
   - Reidemeister III invariance (from state bijection)
   - Reidemeister I behavior: $\langle D_+ \rangle = -A^3 \langle D \rangle$ and $\langle D_- \rangle = -A^{-3} \langle D \rangle$

3. **Jones polynomial and invariance.** We define the Jones polynomial via writhe normalization and prove invariance under Reidemeister I and III.

4. **Concrete examples.** We define the trefoil and figure-eight knots with explicit loop counts and verify their writhe values.

5. **Detection theorem.** We formulate the adequacy-based detection theorem for alternating knots: adequate diagrams with $n > 0$ crossings have non-trivial Jones polynomial.

### 1.3 Related Work

Prior formalizations of knot theory in proof assistants include partial developments in Coq and Isabelle focusing on combinatorial braid groups. Our work is distinguished by its focus on the state-sum bracket polynomial and its algebraic properties, rather than purely topological definitions.

## 2. Definitions and Notation

### 2.1 Smoothing Types

A **smoothing** at a crossing is one of two choices: $A$ (positive resolution) or $B$ (negative resolution). Formally:

```
inductive Smoothing : Type
  | A : Smoothing
  | B : Smoothing
```

### 2.2 Link Diagrams

An **unoriented link diagram** with $n$ crossings is a structure:

```
structure LinkDiagram (n : ℕ) where
  loops : (Fin n → Smoothing) → ℕ
  loops_pos : ∀ s, 0 < loops s
```

A **state** $s : \text{Fin } n \to \text{Smoothing}$ assigns a smoothing to each crossing. The function `loops s` returns the number of resulting simple closed curves after resolving all crossings according to $s$.

### 2.3 State Counts

For a state $s$:
- $\#A(s) = |\{i : s(i) = A\}|$
- $\#B(s) = |\{i : s(i) = B\}|$
- $\#A(s) + \#B(s) = n$

### 2.4 Oriented Diagrams and Writhe

An **oriented link diagram** augments a link diagram with crossing signs:

```
structure OrientedLinkDiagram (n : ℕ) extends LinkDiagram n where
  sign : Fin n → CrossingSign
```

The **writhe** is $w(D) = \sum_i \text{sign}(i)$.

### 2.5 Laurent Polynomials

We use Mathlib's `LaurentPolynomial ℤ = AddMonoidAlgebra ℤ ℤ`, with monomial $T(k)$ representing $A^k$. The loop value is $\delta = -T(2) - T(-2) = -A^2 - A^{-2}$.

## 3. The Kauffman Bracket

### 3.1 Definition

The **Kauffman bracket** of a diagram $D$ with $n$ crossings is:

$$\langle D \rangle = \sum_{s \in \{A,B\}^n} A^{\#A(s) - \#B(s)} \cdot \delta^{\ell(s) - 1}$$

where $\ell(s) = \text{loops}(s)$ is the number of loops in state $s$.

### 3.2 Bracket of the Unknot

**Theorem 3.1.** $\langle \text{unknot} \rangle = 1$.

*Proof.* The unknot has $n = 0$ crossings. The sum has a single term (the unique state on $\text{Fin } 0$) with $\#A = \#B = 0$ and $\ell = 1$, giving $A^0 \cdot \delta^0 = 1$. □

### 3.3 Reidemeister III Invariance

**Theorem 3.2.** If $D_1$ and $D_2$ are related by a Reidemeister III move (i.e., there exists a bijection $f$ on states preserving $\#A$ and loop counts), then $\langle D_1 \rangle = \langle D_2 \rangle$.

*Proof.* Since $f$ is a bijection with $\#A(s) = \#A(f(s))$ and $\ell_1(s) = \ell_2(f(s))$, also $\#B(s) = \#B(f(s))$ (since $\#A + \#B = n$). Each term transforms bijectively: $\text{stateContribution}_{D_1}(s) = \text{stateContribution}_{D_2}(f(s))$. The result follows from `Finset.sum_bij`. □

### 3.4 Reidemeister I Behavior

**Theorem 3.3** (Positive RI). If $D_1$ has $n+1$ crossings with a positive kink at the last crossing (A-smoothing adds a loop, B-smoothing preserves loops), then:

$$\langle D_1 \rangle = -A^3 \cdot \langle D_2 \rangle$$

*Proof sketch.* Partition the states of $D_1$ by the last crossing's smoothing:
$$\langle D_1 \rangle = \sum_s \left[\text{contrib}(s \cdot A) + \text{contrib}(s \cdot B)\right]$$

For each base state $s$ of $D_2$:
- Extending with $A$: $\#A$ increases by 1, loops increase by 1
- Extending with $B$: $\#B$ increases by 1, loops unchanged

The per-state contribution becomes:
$$A \cdot \delta \cdot [\text{base}] + A^{-1} \cdot [\text{base}] = (A\delta + A^{-1}) \cdot [\text{base}]$$

The key algebraic identity: $A\delta + A^{-1} = A(-A^2 - A^{-2}) + A^{-1} = -A^3$. □

**Theorem 3.4** (Negative RI). Under a negative kink: $\langle D_1 \rangle = -A^{-3} \cdot \langle D_2 \rangle$.

*Proof.* Analogous, using the identity $A + A^{-1}\delta = -A^{-3}$. □

## 4. The Jones Polynomial

### 4.1 Definition

The **Jones polynomial** of an oriented diagram $D$ is:

$$V_D(A) = (-A)^{-3w(D)} \cdot \langle D \rangle$$

We implement the sign factor as:
$$(-A)^{-3w} = (-1)^w \cdot T(-3w)$$

(using $(-1)^{-3w} = (-1)^w$ since $(-1)^3 = -1$).

### 4.2 Invariance Under Reidemeister I

**Theorem 4.1.** $V_{D_1} = V_{D_2}$ when $D_1$ has a positive kink over $D_2$.

*Proof.* We have $w(D_1) = w(D_2) + 1$ and $\langle D_1 \rangle = -A^3 \langle D_2 \rangle$. Then:
$$V_{D_1} = (-1)^{w_2+1} T(-3w_2 - 3) \cdot (-T(3)) \cdot \langle D_2 \rangle$$
$$= (-1)^{w_2+1} \cdot (-1) \cdot T(-3w_2) \cdot \langle D_2 \rangle = (-1)^{w_2} \cdot T(-3w_2) \cdot \langle D_2 \rangle = V_{D_2}$$

The parity analysis: if $w_2$ is even, then $(-1)^{w_2+1} \cdot (-1) = (-1)^0 = 1$; if odd, $(-1)^{w_2+1} \cdot (-1) = (-1)^1 = -1$. Both match $(-1)^{w_2}$. □

### 4.3 Invariance Under Reidemeister III

**Theorem 4.2.** Jones is invariant under oriented RIII (which preserves writhe and the unoriented bracket).

*Proof.* Immediate from bracket RIII invariance and writhe preservation. □

## 5. Concrete Examples

### 5.1 Left Trefoil

The left trefoil has 3 negative crossings (writhe $= -3$). Loop counts from the PD code:

| State | #A | #B | Loops |
|-------|----|----|-------|
| AAA   | 3  | 0  | 3     |
| AAB   | 2  | 1  | 2     |
| ABA   | 2  | 1  | 2     |
| ABB   | 1  | 2  | 1     |
| BAA   | 2  | 1  | 2     |
| BAB   | 1  | 2  | 1     |
| BBA   | 1  | 2  | 1     |
| BBB   | 0  | 3  | 2     |

### 5.2 Figure-Eight Knot

The figure-eight has 4 crossings with alternating signs (+,-,+,-), giving writhe $= 0$. The loop counts exhibit the symmetry characteristic of this amphichiral knot.

## 6. Adequacy and Detection

### 6.1 Adequacy

A diagram is **A-adequate** if the all-A state achieves the maximum "state degree" $\#A(s) - \#B(s) + 2(\ell(s) - 1)$ uniquely among all states. **B-adequacy** is the analogous condition for the minimum.

All reduced alternating diagrams are adequate (Kauffman–Murasugi–Thistlethwaite).

### 6.2 Detection Theorem

**Theorem 6.1** (stated). For adequate diagrams with $n > 0$ crossings, $V_D \neq 1$.

*Proof sketch.* The all-A state contributes the leading coefficient of $\langle D \rangle$ at degree $\#A_{\max} + 2(\ell_A - 1) = n + 2\ell_A - 2$. By A-adequacy, this coefficient is $(-1)^{\ell_A - 1} \neq 0$. By B-adequacy, the trailing coefficient at degree $-n - 2\ell_B + 2$ is also nonzero. Since $n > 0$, these degrees differ (their difference is $2n + 2\ell_A + 2\ell_B - 4 > 0$). The bracket has support at $\geq 2$ degrees, so after multiplying by the monomial writhe factor, $V_D$ still has $\geq 2$ nonzero terms and cannot equal $1$.

**Corollary 6.2.** If $D$ is adequate and $V_D = 1$, then $n = 0$ (the diagram represents the unknot).

## 7. Discussion

### 7.1 What Was Proved

The formalization establishes:
- The Kauffman bracket as a well-defined state sum on combinatorial diagrams
- Invariance under Reidemeister III (via state bijection argument)
- Precise RI behavior ($-A^{\pm 3}$ factors) via algebraic identity
- Jones polynomial invariance under RI and RIII
- Writhe computation for specific knots

### 7.2 Limitations

- **Reidemeister II invariance** requires a richer diagram model with explicit arc connections, beyond our abstract loop-counting model. The proof involves topology-dependent loop merging/splitting that cannot be captured by loop counts alone.
- **Bracket computation** for specific knots (equating the bracket to an explicit polynomial) requires either decidable evaluation (blocked by noncomputable definitions) or extensive coefficient manipulation.
- **The detection theorem** requires a Laurent polynomial coefficient API not yet available in the formalization.

### 7.3 Architecture

The code is organized as:
- `Defs.lean`: Types (Smoothing, LinkDiagram, OrientedLinkDiagram, Reidemeister moves, adequacy)
- `KauffmanBracket.lean`: Bracket definition, unknot computation, RI/RIII proofs
- `Jones.lean`: Jones polynomial, writhe lemmas, RI/RIII invariance
- `Examples.lean`: Trefoil, figure-eight, writhe computations
- `Alternating.lean`: Adequacy, detection theorem statement

## 8. Future Work

See `FUTURE_DIRECTIONS.md` for detailed next steps. Key priorities:
1. Planar arc model for RII invariance
2. Laurent polynomial coefficient API for the detection theorem proof
3. Braid group representations and Temperley–Lieb algebra
4. Khovanov homology categorification
5. Certified knot recognition algorithms

## References

1. V.F.R. Jones. A polynomial invariant for knots via von Neumann algebras. *Bull. AMS*, 12:103–111, 1985.
2. L.H. Kauffman. State models and the Jones polynomial. *Topology*, 26(3):395–407, 1987.
3. K. Murasugi. Jones polynomials and classical conjectures in knot theory. *Topology*, 26(2):187–194, 1987.
4. M.B. Thistlethwaite. A spanning tree expansion of the Jones polynomial. *Topology*, 26(3):297–309, 1987.
5. C. Adams. *The Knot Book*. American Mathematical Society, 2004.
