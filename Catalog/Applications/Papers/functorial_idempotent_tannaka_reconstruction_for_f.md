# Newton's Method in Algebra: Idempotent Lifting via Polynomial Iteration

**A Formally Verified Development in Lean 4**

---

## Abstract

We present a formally verified development of the **idempotent lifting theorem** in commutative rings, proved using an algebraic analogue of Newton's method. The polynomial $f(t) = 3t^2 - 2t^3$ acts as a correction map that squares the idempotent defect: if $e^2 - e$ is "small" (nilpotent), then $f(e)$ is a better approximation to a true idempotent. The key identity $f(e)^2 - f(e) = (e^2 - e)^2 \cdot (4e^2 - 4e - 3)$ drives quadratic convergence, producing a true idempotent after finitely many iterations.

All results are machine-verified in Lean 4 using the Mathlib library. We also develop the theory of geometric series inverses for nilpotent elements and prove the stability of units under nilpotent perturbation.

---

## 1. Introduction

### 1.1 The Idempotent Lifting Problem

An element $e$ of a ring $R$ is **idempotent** if $e^2 = e$. The prototypical idempotents are $0$ and $1$, but richer rings contain more: in $\mathbb{Z}/12\mathbb{Z}$, both $4$ and $9$ are idempotent, since $4^2 = 16 \equiv 4$ and $9^2 = 81 \equiv 9 \pmod{12}$.

Idempotents determine **ring decompositions**. If $e$ is an idempotent in a commutative ring $R$, then $R \cong Re \times R(1-e)$, splitting $R$ into a direct product of smaller rings. This is the algebraic backbone of the Chinese Remainder Theorem.

The **idempotent lifting problem** asks: given a ring $R$, an ideal $I$, and an idempotent $\bar{e}$ in the quotient ring $R/I$, can we find an idempotent $e \in R$ that maps to $\bar{e}$? In general, the answer is no — but when $I$ is **nilpotent** (meaning $I^n = 0$ for some $n$), lifting is always possible.

### 1.2 Newton's Method: From Analysis to Algebra

The classical Newton's method solves $g(x) = 0$ by iterating $x \mapsto x - g(x)/g'(x)$. For the equation $g(t) = t^2 - t$ (whose solutions are the idempotents $0$ and $1$), Newton's iteration gives:

$$t \mapsto t - \frac{t^2 - t}{2t - 1} = \frac{t(2t-1) - (t^2 - t)}{2t-1} = \frac{t^2}{2t-1}$$

But this requires dividing by $2t-1$, which may not be invertible in a general ring. The key insight is that we can avoid division entirely by using the **Hermite interpolation polynomial** $f(t) = 3t^2 - 2t^3$, which satisfies:

- $f(0) = 0, \quad f(1) = 1$ (it fixes the target idempotents)
- $f'(0) = 0, \quad f'(1) = 0$ (double roots ensure quadratic convergence)

This polynomial works in **any** commutative ring — no division required.

### 1.3 The Smoothstep Connection

The polynomial $f(t) = 3t^2 - 2t^3$ is better known in computer graphics as the **smoothstep function**. It provides smooth interpolation between 0 and 1 with zero derivatives at the endpoints. This coincidence is not accidental: both applications require a function that maps $\{0, 1\}$ to itself with "flat" behavior near the fixed points. In graphics, this gives smooth transitions; in algebra, it gives quadratic convergence.

---

## 2. Main Results

### 2.1 The Fundamental Squaring Identity

**Theorem 1** (Formally verified as `newtonMap_defect_sq`). *For any element $e$ in a commutative ring $R$,*

$$f(e)^2 - f(e) = (e^2 - e)^2 \cdot (4e^2 - 4e - 3)$$

*where $f(e) = 3e^2 - 2e^3$.*

This identity is purely algebraic and holds in every commutative ring. It is verified by the `ring` tactic in Lean, which decides equalities in commutative rings.

The identity tells us that the "defect" $\delta(e) := e^2 - e$ satisfies $\delta(f(e)) = \delta(e)^2 \cdot g(e)$, so one application of $f$ replaces the defect with its square (times a cofactor). This is the algebraic manifestation of quadratic convergence.

### 2.2 Base Case: Lifting Modulo Square-Zero Ideals

**Theorem 2** (Formally verified as `newtonMap_isIdempotentElem`). *If $(e^2 - e)^2 = 0$ in a commutative ring $R$, then $f(e) = 3e^2 - 2e^3$ is idempotent.*

*Proof.* By Theorem 1, $f(e)^2 - f(e) = (e^2 - e)^2 \cdot (4e^2 - 4e - 3) = 0 \cdot (4e^2 - 4e - 3) = 0$. $\square$

### 2.3 The General Lifting Theorem

**Definition.** The **iterated Newton map** is defined recursively:
- $f^{(0)}(e) = e$
- $f^{(k+1)}(e) = f(f^{(k)}(e))$

**Theorem 3** (Formally verified as `iterNewtonMap_isIdempotentElem`). *If $(e^2 - e)^{2^k} = 0$ in a commutative ring $R$, then $f^{(k)}(e)$ is idempotent.*

*Proof.* By induction on $k$. The base case $k = 0$ says: if $e^2 - e = 0$, then $e$ is idempotent, which is immediate.

For the inductive step, suppose the result holds for $k$. Given $(e^2 - e)^{2^{k+1}} = 0$, we use the Key Inductive Lemma (`defect_pow_of_newtonMap`): since $(e^2 - e)^{2^{k+1}} = ((e^2 - e)^2)^{2^k} = 0$ and $f(e)^2 - f(e) = (e^2 - e)^2 \cdot g(e)$, we get $(f(e)^2 - f(e))^{2^k} = 0$. By the inductive hypothesis applied to $f(e)$, $f^{(k)}(f(e))$ is idempotent. But $f^{(k)}(f(e)) = f^{(k+1)}(e)$. $\square$

### 2.4 Congruence Preservation

**Theorem 4** (Formally verified as `iterNewtonMap_sub_mem_ideal`). *For any $e \in R$ and $k \geq 0$, the lifted idempotent satisfies*

$$f^{(k)}(e) - e \in (e^2 - e)$$

*where $(e^2 - e)$ denotes the principal ideal generated by $e^2 - e$.*

This ensures that the lifted idempotent maps to the same element as $e$ in the quotient $R/(e^2 - e)$.

### 2.5 Geometric Series and Nilpotent Inverses

**Theorem 5** (Formally verified as `geom_series_nilpotent_inv`). *If $x^n = 0$ in a commutative ring $R$, then*

$$(1 - x) \cdot \sum_{k=0}^{n-1} x^k = 1$$

*In particular, $1 - x$ is a unit with explicit inverse $1 + x + x^2 + \cdots + x^{n-1}$.*

This is the finite algebraic analogue of the geometric series $\frac{1}{1-x} = 1 + x + x^2 + \cdots$. Unlike the analytic version, no convergence issues arise — the series terminates because $x$ is nilpotent.

### 2.6 Stability of Units

**Theorem 6** (Formally verified as `isUnit_add_nilpotent`). *If $u$ is a unit and $n$ is nilpotent in a commutative ring, then $u + n$ is a unit.*

*Proof.* Write $u + n = u(1 + u^{-1}n)$. Since $n$ is nilpotent, so is $u^{-1}n$. By Theorem 5, $1 + u^{-1}n = 1 - (-u^{-1}n)$ is a unit. The product of units is a unit. $\square$

---

## 3. Discussion: Why This Matters

### For the General Reader

Imagine you have a fuzzy photograph of a black-and-white chessboard. Each pixel is *approximately* black or white, but noise has shifted the values slightly. You want to "clean up" the image so every pixel is exactly 0 (black) or 1 (white).

One approach: apply the function $f(t) = 3t^2 - 2t^3$ to each pixel value. Values near 0 get pushed toward 0; values near 1 get pushed toward 1. Moreover, the *error* (how far each pixel is from pure black or white) gets **squared** at each step. After just a few iterations, every pixel snaps to exactly 0 or 1.

This is precisely what the idempotent lifting theorem does, but in abstract algebra instead of image processing. The "pixels" are elements of a ring, the "noise" is a nilpotent ideal, and the "cleanup" is the Newton map $f(t) = 3t^2 - 2t^3$.

### For Mathematicians

The idempotent lifting theorem is a cornerstone result with far-reaching consequences:

1. **Hensel's Lemma.** The lifting of idempotents implies Hensel's Lemma for splitting polynomials modulo nilpotent ideals. If $\bar{f}(x) = \bar{g}(x)\bar{h}(x)$ is a factorization in $(R/I)[x]$ with $\gcd(\bar{g}, \bar{h}) = 1$, then the factorization lifts to $R[x]$. The key step constructs an idempotent in the endomorphism ring.

2. **The Krull–Schmidt Theorem.** Unique decomposition of modules into indecomposables relies on lifting idempotents from the endomorphism ring modulo its Jacobson radical.

3. **Algebraic K-Theory.** The group $K_0(R)$ classifies projective modules via idempotent matrices. The lifting theorem ensures that $K_0$ is invariant under nilpotent extensions: $K_0(R) \cong K_0(R/I)$ when $I$ is nilpotent.

4. **Deformation Theory.** In algebraic geometry, deforming a scheme $X_0$ over a base $\text{Spec}(k)$ to a scheme $X$ over $\text{Spec}(A)$ (where $A$ is an Artinian local ring with residue field $k$) requires lifting idempotents to decompose coherent sheaves.

### Historical Note

The Newton map approach to idempotent lifting appears implicitly in work of Fitting (1935) and explicitly in treatments by Lam and others. The connection to the smoothstep function seems to be a modern observation. The formal verification of these results in a proof assistant is, to our knowledge, new.

---

## 4. Concrete Examples

### 4.1 Idempotents in $\mathbb{Z}/12\mathbb{Z}$

By the Chinese Remainder Theorem, $\mathbb{Z}/12\mathbb{Z} \cong \mathbb{Z}/4\mathbb{Z} \times \mathbb{Z}/3\mathbb{Z}$. Each factor has exactly two idempotents ($0$ and $1$), so $\mathbb{Z}/12\mathbb{Z}$ has $2^2 = 4$ idempotents: $\{0, 1, 4, 9\}$.

The complementary pairs are $(4, 9)$ and $(0, 1)$, corresponding to the projections onto the two factors.

These results are formally verified in Lean:
- `zmod12_four_idempotent`: $4^2 \equiv 4 \pmod{12}$
- `zmod12_nine_idempotent`: $9^2 \equiv 9 \pmod{12}$
- `zmod12_complementary`: $4 + 9 \equiv 1 \pmod{12}$

### 4.2 Newton Iteration in $\mathbb{Z}/36\mathbb{Z}$

Starting from $e_0 = 10$ in $\mathbb{Z}/36\mathbb{Z}$:
- Defect: $10^2 - 10 = 90 \equiv 18 \pmod{36}$
- After one Newton step: $f(10) = 3 \cdot 100 - 2 \cdot 1000 = -1700 \equiv 28 \pmod{36}$
- Defect: $28^2 - 28 = 756 \equiv 0 \pmod{36}$ ✓

The element $28$ is a true idempotent, reached in a single iteration.

### 4.3 Geometric Series in $\mathbb{Z}/8\mathbb{Z}$

In $\mathbb{Z}/8\mathbb{Z}$, the element $x = 2$ is nilpotent: $2^3 = 8 \equiv 0$. The geometric series gives:

$$(1 - 2)^{-1} = 1 + 2 + 4 = 7 \pmod{8}$$

Verification: $7 \times 7 = 49 \equiv 1 \pmod{8}$. ✓

---

## 5. Applications

### 5.1 Parallel Computation via Ring Decomposition

Idempotent decompositions enable **parallel arithmetic**. In $\mathbb{Z}/n\mathbb{Z}$, if $e$ is a nontrivial idempotent, we can decompose any computation modulo $n$ into independent computations modulo the factors. This is the basis of:

- **RSA acceleration**: Computing $m^d \bmod n$ (where $n = pq$) can be parallelized by computing $m^d \bmod p$ and $m^d \bmod q$ separately, then combining via CRT.
- **Multi-precision arithmetic**: Large modular computations are split across smaller moduli.
- **Hardware design**: Residue Number Systems (RNS) use idempotent decomposition for carry-free parallel addition.

### 5.2 Error-Correcting Codes

Cyclic codes over finite fields are generated by **idempotent elements** in the group algebra $\mathbb{F}_q[x]/(x^n - 1)$. The idempotent lifting theorem ensures that codes defined modulo a prime $p$ can be lifted to codes over $\mathbb{Z}/p^k\mathbb{Z}$, enabling:

- **Lattice construction**: Lifting binary codes to integer lattices via Construction A.
- **Soft-decision decoding**: Working with multi-level codes that refine binary codes.

### 5.3 Numerical Linear Algebra

The unit perturbation theorem (Theorem 6) has direct applications to **condition number estimation** and **iterative refinement**:

- If $A$ is an invertible matrix and $E$ is a nilpotent perturbation (e.g., a strictly triangular error matrix), then $A + E$ is invertible with explicit inverse given by the geometric series $A^{-1} \sum_{k=0}^{n-1} (-A^{-1}E)^k$.
- This gives **exact** inverses for triangular perturbations, unlike the approximate Neumann series used for general perturbations.

### 5.4 p-adic Number Theory

The idempotent lifting theorem is equivalent to a special case of **Hensel's Lemma** for the polynomial $t^2 - t$. In the $p$-adic integers $\mathbb{Z}_p$, it guarantees that idempotents modulo $p$ lift to idempotents in $\mathbb{Z}_p$ — which is why $\mathbb{Z}_p$ has no nontrivial idempotents (since $\mathbb{F}_p$ has none, being a field).

More generally, for composite moduli, it explains why $\mathbb{Z}_n$ has the same number of idempotents as $\mathbb{Z}/n\mathbb{Z}$: they can all be lifted from the residue ring.

---

## 6. Formal Verification Details

### 6.1 Lean 4 Implementation

The formalization uses the Mathlib library for basic ring theory infrastructure. Key design decisions:

- **`IsIdempotentElem`**: We use Mathlib's predicate `IsIdempotentElem e`, defined as `e * e = e`.
- **Newton map**: Defined as `newtonMap (e : R) : R := 3 * e ^ 2 - 2 * e ^ 3` in any `CommRing R`.
- **Ring tactic**: The fundamental identity is proved by `ring`, which decides equalities in commutative rings.
- **Induction**: The general lifting theorem uses strong induction on the nilpotency order.

### 6.2 Proof Architecture

The proof has a clean layered structure:

1. **Algebraic identities** (`newtonMap_defect_sq`, `newtonMap_sub_self`): Proved by `ring`.
2. **Base case** (`newtonMap_isIdempotentElem`): Follows immediately from the squaring identity.
3. **Inductive lemma** (`defect_pow_of_newtonMap`): Uses the squaring identity and commutativity.
4. **Main theorem** (`iterNewtonMap_isIdempotentElem`): Induction on $k$, using the lemma.
5. **Congruence** (`iterNewtonMap_sub_mem_ideal`): Separate induction using `newtonMap_sub_self`.

### 6.3 Axioms Used

The formalization uses only the standard Lean 4 axioms:
- `propext` (propositional extensionality)
- `Quot.sound` (quotient soundness)
- `Classical.choice` (classical logic, used for unit constructions)
- `Lean.ofReduceBool` and `Lean.trustCompiler` (for `native_decide` in concrete computations)

No additional axioms are introduced.

---

## 7. Future Directions

1. **Non-commutative generalization**: The lifting theorem extends to non-commutative rings, but the proof is more involved (one needs the condition that the defect lies in the Jacobson radical). Formalizing this would require substantial development of radical theory.

2. **Constructive proof**: Our proof of `isUnit_add_nilpotent` uses classical logic. A fully constructive version would provide the inverse as a computable term.

3. **Higher-order smoothstep**: The polynomial $f(t) = 3t^2 - 2t^3$ is the degree-3 smoothstep. Higher-degree smoothsteps (e.g., $6t^5 - 15t^4 + 10t^3$) would give even faster convergence. Formalizing the family of smoothstep polynomials and their convergence rates is an interesting direction.

4. **Hensel's Lemma**: Generalizing from $t^2 - t = 0$ to arbitrary polynomials $g(t) = 0$ would yield a full formal proof of Hensel's Lemma, one of the most important tools in $p$-adic analysis.

---

## References

1. Atiyah, M.F. and Macdonald, I.G. *Introduction to Commutative Algebra*. Addison-Wesley, 1969.

2. Lam, T.Y. *A First Course in Noncommutative Rings*. Springer Graduate Texts in Mathematics, 2001.

3. The Mathlib Community. *Mathlib: A Unified Library of Mathematics Formalized in Lean 4*. https://github.com/leanprover-community/mathlib4

---

*All theorems in this paper have been formally verified in Lean 4 using the Mathlib library (version 4.28.0). The source code is available in `Catalog/Algebra/NewtonIdempotent.lean`.*
