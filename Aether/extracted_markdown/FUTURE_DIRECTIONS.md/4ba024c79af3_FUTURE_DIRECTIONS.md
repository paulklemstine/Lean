# Future Directions

## 1. Closing the Remaining Sorry

### Wall's Theorem (Highest Priority)
The single remaining sorry requires **Wall's Lifting-the-Exponent Lemma** for
Fibonacci sequences: for prime q | F(m) with entry point α(q) dividing m,
$$v_q(F(km)) = v_q(F(m)) + v_q(k)$$
where $v_q$ is the q-adic valuation.

**Recommended approach:** Formalize this using the matrix representation
$\begin{pmatrix} 1 & 1 \\ 1 & 0 \end{pmatrix}^n$ over q-adic integers $\mathbb{Z}_q$.
The key steps are:
1. Show the Fibonacci matrix modulo $q$ is diagonal when $q | F(m)$
2. Lift to $\mathbb{Z}/q^2\mathbb{Z}$ using the expansion $(D + qE)^k$
3. Extract the valuation from the off-diagonal entry

This is roughly 200-400 lines of Lean 4 and would immediately close the sorry.

### Cyclotomic Fibonacci Theory
An alternative path uses the **primitive part** $\Phi_n = \prod_{d|n} F(d)^{\mu(n/d)}$
and shows $\Phi_n > 1$ for $n > 12$. This requires:
- Connecting $\Phi_n$ to cyclotomic polynomials evaluated at the golden ratio
- Establishing lower bounds on these evaluations
- This approach would also give stronger quantitative bounds

## 2. Extensions of Carmichael's Theorem

### Lucas Sequences
Carmichael's theorem generalizes to Lucas sequences $U_n(P, Q)$ defined by
$U_0 = 0$, $U_1 = 1$, $U_{n+2} = PU_{n+1} - QU_n$. The Fibonacci case is
$P = 1, Q = -1$. Formalizing the general case would cover:
- Pell numbers ($P = 2, Q = -1$)
- Mersenne-related sequences ($P = 3, Q = 2$, giving $2^n - 1$)
- General linear recurrences

### Quantitative Bounds
How large is the smallest primitive prime divisor? For prime n, it equals
$\text{minFac}(F(n))$, which grows like $n$ on average. For composite n, the
bounds are less understood. Formalizing effective lower bounds on primitive
divisors would have applications to Diophantine equations.

### Effective Zsygmondy Theorem
The classical Zsygmondy theorem states that $a^n - b^n$ has a primitive prime
divisor for $n > 6$ when $a > b > 0$ (with finitely many exceptions). Formalizing
this would unify Carmichael's theorem with Mersenne prime theory.

## 3. Cross-Domain Connections

### Applications to Group Theory
Primitive divisors of Lucas sequences are used to establish:
- Lower bounds on the order of elements in linear groups
- Classification results for finite simple groups
- Existence of generators for cyclic groups $(\mathbb{Z}/n\mathbb{Z})^*$

Formalizing these connections would bridge number theory and algebra in Lean.

### Cryptographic Applications
The Fibonacci sequence modulo n (Pisano period) relates to:
- Fibonacci-based pseudorandom number generators
- The security analysis of certain lattice-based cryptosystems
- Period analysis in polynomial-time algorithms for factoring

### Algebraic Number Theory
The entry point function $\alpha(p)$ for Fibonacci is closely related to:
- The splitting behavior of $p$ in $\mathbb{Q}(\sqrt{5})$
- The Legendre symbol $\left(\frac{5}{p}\right)$
- Quadratic reciprocity via Fibonacci

The identity $\alpha(p) | p - \left(\frac{p}{5}\right)$ connects primitive
divisors to quadratic residues.

## 4. Formalization Infrastructure Needs

### Missing from Mathlib
Several mathematical building blocks needed for the full proof are not yet in
Mathlib:
1. **p-adic valuations of Fibonacci numbers** — Wall's theorem
2. **Cyclotomic polynomials for integer sequences** — the Fibonacci analogue
3. **Möbius function on divisor lattices** — for the primitive part formula
4. **Matrix lifting mod prime powers** — for the LTE proof

### Recommended Mathlib Contributions
- `Nat.fib_entry_point` — the rank of apparition function
- `Nat.fib_valuation` — Wall's formula for p-adic valuations
- `Nat.fib_primitive_part` — the cyclotomic Fibonacci integer $\Phi_n$
- `Nat.fib_primitive_divisor` — Carmichael's theorem itself

## 5. Open Problems Encountered

1. **Computational limits**: Can `native_decide` be pushed beyond 75,000 for
   `primPart` verification? The bottleneck is GCD computation on numbers with
   ~15,000+ digits.

2. **Lucas number primitive parts**: Is $\Lambda_m > 1$ for all $m > 3$?
   This is the Lucas analogue of Carmichael's theorem and would simplify the
   even-composite case.

3. **Effective bounds**: For composite n, what is the smallest primitive prime
   divisor of F(n) in terms of n? The answer involves the Euler totient function
   and the number of divisors.

4. **Higher-order recurrences**: Does an analogue of Carmichael's theorem hold
   for Tribonacci numbers or other linear recurrences of order ≥ 3?
