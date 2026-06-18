# Future Directions: Local-Global Obstruction Framework for Additive Diophantine Problems

## Conjecture 1: Periodic Predicate Universal Density Theorem

**Conjecture:** For any periodic predicate $P : \mathbb{Z} \to \mathrm{Prop}$ with period $m > 0$ (i.e., $P(k) \iff P(k + m)$ for all $k$) having exactly $a$ admissible residues among $\{0, 1, \ldots, m-1\}$, the natural density is exactly $a/m$:

$$\lim_{N \to \infty} \frac{\#\{n \in [0,N) : P(n)\}}{N} = \frac{a}{m}.$$

Moreover, the counting function satisfies $|m \cdot \mathrm{count}(N) - a \cdot N| \leq m - 1$.

**Test:** Formalize in Lean 4 a general `PeriodicPred m P` structure and prove the density theorem. Instantiate for the three-cubes problem (m=9, a=7), sum-of-three-squares mod 8 (m=8, a=7), and sum-of-four-fourth-powers mod 16.

**Impact:** If true and formalized, this creates a one-line proof of density for any periodic Diophantine obstruction, eliminating repeated ad hoc arguments. It would form the foundation of a formal sieve-theoretic library.

---

## Conjecture 2: Exceptional Set Zero Density

**Conjecture:** Let $E(N) = \#\{k \in [1, N] : k \text{ is admissible but not representable as } x^3+y^3+z^3\}$. Then:

$$\frac{E(N)}{N} \to 0 \quad \text{as } N \to \infty.$$

More precisely, we conjecture $E(N) = o(N^{1-\epsilon})$ for some $\epsilon > 0$.

**Test:** Compute $E_B(N) = \#\{k \in [1,N] : k \text{ admissible}, \neg\mathrm{boundedSearch}(B, k)\}$ for increasing $B$ and $N$. If $E_B(N)/N$ decreases as $B$ grows (for fixed $N$), this supports the conjecture. Specifically:
- Compute for $N = 10^3, 10^4$ and $B = 10^2, 10^3, 10^4$.
- Track the ratio $E_B(N)/\mathrm{admissibleCount}(N)$ as a function of $B$.

**Impact:** A proof (even partial) would be a major advance in analytic number theory. Even strong computational evidence would inform conjectures about the growth rate of the exceptional set.

---

## Conjecture 3: Multi-Modulus Obstruction Completeness for Three Cubes

**Conjecture:** The mod-9 obstruction is the *only* congruence obstruction for sums of three cubes. That is, for every prime $p \neq 3$ and every $k$ with $\gcd(k, p) = 1$, the equation $x^3 + y^3 + z^3 \equiv k \pmod{p}$ has solutions. More strongly, for every modulus $m$ not divisible by 9, every residue class modulo $m$ is achievable.

**Test:**
1. Computationally verify for all primes $p \leq 1000$ that the sum of three cubes achieves all residues mod $p$ (except when $p = 3$, where it misses residues $\equiv \pm 1 \pmod{3}$, lifting to the mod-9 obstruction).
2. Formalize a proof for specific small primes (e.g., $p = 2, 5, 7, 11, 13$) that all residues are achieved.
3. Attempt a general proof using Chevalley–Warning or Weil estimates for the number of solutions to $x^3+y^3+z^3 \equiv k \pmod{p}$.

**Impact:** Confirming this would establish that the mod-9 filter captures *all* local information — the singular series for three cubes reduces to a single factor at $p = 3$. This connects directly to the circle method and would be a valuable formalization target.

---

## Conjecture 4: Admissible Saturation Under Growing Search Bounds

**Conjecture:** Define $R_B(N) = \#\{k \in [1,N] : \mathrm{boundedSearch}(B, k) \text{ succeeds}\}$. Then for $B = N^{1/3 + \epsilon}$:

$$\frac{R_B(N)}{\mathrm{admissibleCount}(N)} \to 1 \quad \text{as } N \to \infty.$$

This says that "most" admissible integers up to $N$ can be represented using cubes of size at most $N^{1/3 + \epsilon}$.

**Test:**
- For $N = 100, 500, 1000$, compute $R_B(N)/\mathrm{admissibleCount}(N)$ for $B = N^{1/3}, N^{1/2}, N$.
- Plot the saturation curve as a function of $B/N^{1/3}$.
- Identify the "hard cases" — admissible integers requiring $B \gg N^{1/3}$ — and study their distribution (do they cluster near specific residue classes or have arithmetic structure?).

**Impact:** Understanding the relationship between $B$ and the coverage ratio is essential for designing efficient search algorithms. If confirmed, this conjecture would provide quantitative guidance for computational searches.

---

## Conjecture 5: Structure Theorem for Hard Cases

**Conjecture:** Among admissible integers $k \leq N$ that are *not* $B$-representable for $B = N$, a positive proportion satisfy $k \equiv 3 \pmod{9}$ or $k \equiv 6 \pmod{9}$ — the residue classes where all three cube residues must contribute a specific pattern (e.g., all three cubes must be $\equiv 1 \pmod{3}$ to reach $k \equiv 3$).

**Test:**
1. For $N = 1000$ and $B = 1000$, compute the mod-9 distribution of non-representable admissible integers.
2. Compare with the uniform distribution (each admissible class contributing 1/7 of cases).
3. Check whether the hard cases (e.g., 33, 42, 114, 165, 390, 579, 627, 633, 732, 906, 921) show a non-uniform mod-9 distribution.

**Impact:** If certain residue classes produce harder instances, this could inform targeted search strategies and might connect to deeper structural features of the problem (e.g., the Brauer–Manin obstruction for diagonal cubic surfaces).

---

## Implementation Roadmap

### Phase 1 (Near-term, 1–2 months)
- Formalize Conjecture 1 (periodic predicate density) as a general Lean 4 library.
- Run computational tests for Conjecture 3 (multi-modulus completeness) up to $p = 100$.
- Implement efficient bounded search in compiled code for Conjecture 4 testing.

### Phase 2 (Medium-term, 3–6 months)
- Formalize Chevalley–Warning theorem in Lean 4 for use in Conjecture 3.
- Build a formal `Sieve` structure connecting local densities to global density predictions.
- Extend the framework to sums of four cubes, sums of three squares, etc.

### Phase 3 (Long-term, 6–12 months)
- Connect to the circle method: formalize the singular series for Waring-type problems.
- Formalize verified certificates for specific hard cases (e.g., formally prove 33 ∈ Rep using the known representation).
- Develop the exceptional-set theory toward partial results on Conjecture 2.
