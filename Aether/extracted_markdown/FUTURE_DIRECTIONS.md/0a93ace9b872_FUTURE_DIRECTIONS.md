# Future Research Directions

## Building on the Fibonacci Primitive Divisor Formalization

---

### 1. Complete Carmichael's Theorem for Composite Indices

**Status**: The prime-index case (`fib_prime_has_primitive`) is fully proved. The composite case remains.

**Strategy**: For composite $n > 12$, the proof requires showing that $F_n$ has prime factors
beyond those appearing in $F_d$ for proper divisors $d \mid n$. Two approaches:

- **Growth bound approach**: Show that $F_n > \prod_{d \mid n, d < n} F_d$ for $n > 12$ composite.
  The formalized bounds (`fib_exponential_lower_bound`, `fib_mul_le_fib_add`) provide the foundation.
  The missing piece is a careful counting argument about divisor sums.

- **Cyclotomic Fibonacci approach**: Define the Fibonacci analogs of cyclotomic polynomials
  $\Phi_n^{\text{Fib}}$ such that $F_n = \prod_{d \mid n} \Phi_d^{\text{Fib}}$. Show
  $\Phi_n^{\text{Fib}} > 1$ for $n > 12$.

**Difficulty**: Medium-High. The infrastructure is in place; the main challenge is the
divisor product bound.

---

### 2. Generalize to Lucas Sequences

**Goal**: Extend all results from the Fibonacci sequence to general Lucas sequences $U_n(P, Q)$
defined by $U_0 = 0, U_1 = 1, U_{n+2} = P \cdot U_{n+1} - Q \cdot U_n$.

**Key theorems to generalize**:
- Entry point characterization: $p \mid U_n \iff z(p) \mid n$
- LTE: $v_p(U_{nk}) = v_p(U_k) + v_p(n)$ (under appropriate conditions)
- Primitive divisor existence (the Bilu-Hanrot-Voutier theorem)

**Connection**: The Bilu-Hanrot-Voutier theorem (2001) completely classifies which Lucas
sequences lack primitive divisors. Formalizing this would be a landmark result.

---

### 3. Tropical Semiring Infrastructure

**Goal**: Develop a general theory of tropical semiring homomorphisms in Lean 4.

**Specific targets**:
- Define the tropical semiring $(\mathbb{Z} \cup \{\infty\}, \min, +)$ as a Lean structure
- Show that $v_p$ is a tropical semiring homomorphism
- Develop tropical convexity theory (tropical polytopes, tropical linear algebra)
- Connect to Newton polygons and tropical algebraic geometry

**Application**: Tropical methods provide elegant proofs in combinatorics, optimization,
and algebraic geometry. A formal tropical library would have broad applications.

---

### 4. p-adic Valuation Calculus

**Goal**: Develop a comprehensive formal library for p-adic valuation identities.

**Key results to formalize**:
- General Lifting-the-Exponent lemma for $v_p(a^n - b^n)$ and $v_p(a^n + b^n)$
- The LTE for $p = 2$ (which has different behavior)
- Applications to IMO/competition number theory problems
- Connection to Hensel's lemma and p-adic analysis

**Status**: Our `fib_lte` proves a Fibonacci-specific instance. The general LTE for
integers would be a powerful tool.

---

### 5. Pisano Periods and Fibonacci Modular Arithmetic

**Goal**: Formalize the theory of Pisano periods $\pi(m) = $ period of $F_n \mod m$.

**Key results**:
- $\pi(p)$ divides $p^2 - 1$ for primes $p \neq 5$ (partially formalized via `entry_point_dvd_sq_sub_one`)
- $\pi(p) = p - 1$ iff $p \equiv \pm 1 \pmod{5}$ (Wall's conjecture connection)
- $\pi(p^k) = p^{k-1} \pi(p)$ (LTE gives this!)
- Multiplicativity: $\pi(\text{lcm}(m,n)) = \text{lcm}(\pi(m), \pi(n))$ for coprime $m, n$

**Connection**: Our LTE theorem directly implies $\pi(p^k) = p^{k-1}\pi(p)$ for odd primes,
demonstrating the deep connection between LTE and Pisano period theory.

---

### 6. Matrix Methods in Formal Number Theory

**Goal**: Develop reusable infrastructure for the "matrix method" in number theory.

Our proof of `entry_point_dvd_sq_sub_one` uses the Fibonacci matrix and its eigenvalues
over algebraic closures of finite fields. This pattern appears in many other contexts:

- Recurrence sequence divisibility (Lucas, Lehmer, generalized)
- Order of elements in GL_n(F_q)
- Algebraic number theory (units in number fields)

**Deliverable**: A library of lemmas about matrix powers over finite fields, eigenvalue
bounds, and Frobenius action.

---

### 7. Cross-Domain Bridges

**Observed connections during this research**:

1. **Tropical ↔ p-adic**: The ultrametric inequality is the tropical semiring axiom.
   This suggests that p-adic analysis can be systematically "tropicalized."

2. **Fibonacci ↔ Algebraic Geometry**: The Frobenius argument for entry point bounds
   is really about the structure of $\mathbb{F}_{p^2}^{\times}$. This connects to
   the theory of elliptic curves (which also use Frobenius).

3. **LTE ↔ Iwasawa Theory**: The Lifting-the-Exponent lemma has analogs in Iwasawa theory,
   where one studies how p-adic valuations behave in towers of number fields. Formalizing
   this connection would bridge elementary and advanced number theory.

4. **Primitive Divisors ↔ ABC Conjecture**: The existence of primitive divisors is related
   to the ABC conjecture. Stronger forms of primitive divisor theorems could potentially
   lead to partial results toward ABC.

---

### 8. Computational Verification Extension

**Goal**: Extend the computational verification range for Carmichael's theorem.

Currently, specific cases (n = 3, 4, 5, 7) are verified by computation. Using `native_decide`
or certified computation, one could verify all cases up to n = 10000 or beyond, providing
a computational backup for the theoretical proof.

---

### 9. Open Problems Encountered

1. **Wall's Conjecture**: Is $\pi(p^2) = p \cdot \pi(p)$ for all primes $p$? This is
   equivalent to asking whether $p^2 \nmid F_{\pi(p)}$. Despite being verified for all
   primes up to $10^{14}$, this remains open.

2. **Full Carmichael for composites**: While the prime case is proved, the composite case
   requires additional growth bounds that we did not complete.

3. **Effective entry point computation**: Given a prime $p$, can we efficiently compute
   $z(p)$ without searching? The bound $z(p) \mid p^2 - 1$ helps, but a direct formula
   involving the Legendre symbol $\left(\frac{5}{p}\right)$ would be more useful.

---

### Priority Ranking

| Priority | Direction | Impact | Difficulty |
|----------|-----------|--------|------------|
| 1 | Complete Carmichael (composite case) | High | Medium |
| 2 | General LTE for integers | High | Medium |
| 3 | Pisano period theory | Medium | Low-Medium |
| 4 | Lucas sequence generalization | High | High |
| 5 | Tropical semiring library | Medium | Medium |
| 6 | Matrix methods library | Medium | Low |

---

*These directions build directly on the formalized theorems in `RequestProject/FibPrimitiveDivisor.lean`.
The most impactful next step is completing Carmichael's theorem for composite indices.*
