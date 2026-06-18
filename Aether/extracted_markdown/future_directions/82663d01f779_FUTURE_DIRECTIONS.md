# Future Directions: Sums of Three Cubes — Local-Global Geometry

## Conjecture 1: Weak Local-Global Admissibility

**Conjecture.** For every integer $k$ with $k \bmod 9 \notin \{4, 5\}$, the congruence $x^3 + y^3 + z^3 \equiv k \pmod{n}$ is soluble for every positive integer $n$.

**Why it matters.** If true, this would show that the mod 9 obstruction is the *only* local obstruction — there is no prime $p$ and no residue class (admissible mod 9) that fails $p$-adically. This would sharply delineate the boundary between local and global difficulty: the equation $x^3 + y^3 + z^3 = k$ would satisfy a "local everywhere" condition for all admissible $k$, and the entire difficulty of representation would be purely global.

**Test.** For each admissible $k$ in $\{0, 1, \ldots, 100\}$, verify solvability of $x^3 + y^3 + z^3 \equiv k \pmod{p^e}$ for all primes $p \leq 50$ and exponents $e \leq 5$. If any admissible $k$ fails for some prime power modulus, the conjecture is refuted.

**Impact.** A proof would formalize that Hasse-principle failure for this equation is entirely a global (Brauer-Manin-type) phenomenon, not detectable by any single local condition.

---

## Conjecture 2: Positive Density of Admissible Integers, Zero Density of Representable Integers

**Conjecture.** The natural density of $\{k \in \mathbb{Z} : k \bmod 9 \notin \{4,5\}\}$ is exactly $7/9$. The natural density of $\{k \in \mathbb{Z} : \exists\, x,y,z,\; x^3+y^3+z^3 = k\}$, if it exists, is strictly less than $7/9$ — and heuristics suggest it may equal $7/9$ (i.e., density 1 among admissible integers).

**Why it matters.** The first claim (density $7/9$) is elementary and formalizable. The second part connects to deep conjectures of Heath-Brown and others: among admissible $k$, *almost all* should be representable. This would mean the global obstruction, while real, is sparse.

**Test.** Compute the fraction of admissible integers in $[1, N]$ that have known representations, for $N = 10^3, 10^4, 10^5$, using existing databases of solutions. Compare to $7/9 \approx 0.7778$.

**Impact.** Formalizing even the density $7/9$ result provides certified arithmetic statistics infrastructure. The deeper conjecture, if approached, would connect formal verification to analytic number theory.

---

## Conjecture 3: Heavy-Tailed Height Distribution

**Conjecture.** For admissible $k$, the minimal height $H(k) = \min\{\max(|x|, |y|, |z|) : x^3+y^3+z^3=k\}$ (when a representation exists) is not polynomially bounded in $|k|$. Specifically, there exist infinitely many admissible $k$ with $H(k) > |k|^{100}$.

**Why it matters.** This captures the computational hardness of the problem. The famous case $k = 42$ required $|x| \approx 10^{16}$, while $42$ itself is tiny. A formal understanding of height distribution would connect Diophantine geometry to computational complexity.

**Test.** Using the Booker-Sutherland database, plot $\log H(k)$ vs $\log |k|$ for all known solutions with $|k| \leq 1000$. Fit a regression and check whether polynomial growth is plausible. The case $k = 3$ (with $H = 5.6 \times 10^{15}$) provides a concrete data point.

**Impact.** If formalized even partially, this would connect the certified local-global framework to computational complexity theory and search algorithm design.

---

## Conjecture 4: Symmetry-Reduced Search Speedup

**Conjecture.** After applying the symmetry reduction $|x| \leq |y| \leq |z|$ and filtering out forbidden residues mod 9, the average number of triples examined to find a representation (when one exists within a search bound $B$) drops by a factor of at least $6 \times (9/7) \approx 7.7$ compared to naive exhaustive search over $[-B, B]^3$.

**Why it matters.** This connects the formal obstruction theory directly to algorithmic efficiency. The factor of 6 comes from the permutation symmetry of three variables (breaking the $S_3$ symmetry), and $9/7$ comes from congruence filtering. Together they should yield a provable speedup.

**Test.** Benchmark naive search vs. symmetry-reduced + congruence-filtered search for all admissible $k \leq 100$ with solutions having $H(k) \leq 10^4$. Measure wall-clock time ratios and compare to the predicted factor.

**Impact.** A formalized speedup theorem would be one of the first certified algorithm optimizations for a Diophantine search problem.

---

## Conjecture 5: Generic Local Smoothness of the Cubic Surface

**Conjecture.** For $k \neq 0$ and any prime $p \geq 5$, the affine cubic surface $X_k : x^3 + y^3 + z^3 = k$ over $\mathbb{F}_p$ is smooth (the gradient $(3x^2, 3y^2, 3z^2)$ does not vanish at any $\mathbb{F}_p$-point of $X_k$) unless $p \mid k$ and $(0,0,0)$ is a point (i.e., $k = 0$). For $p = 2, 3$, the surface may have singularities due to the vanishing of $3$ in characteristic $\leq 3$.

**Why it matters.** Smoothness over $\mathbb{F}_p$ is a prerequisite for Hensel lifting, which in turn guarantees local $p$-adic solubility. If the surface is smooth at every $\mathbb{F}_p$-point for all $p \geq 5$, then by Hensel's lemma, any $\mathbb{F}_p$-solution lifts to a $\mathbb{Z}_p$-solution — and the only local obstruction comes from $p = 3$ (which is the mod 9 obstruction).

**Test.** For each prime $p \in \{5, 7, 11, 13, 17, 19, 23\}$ and each $k \in \{1, \ldots, p-1\}$, enumerate all $\mathbb{F}_p$-points of $X_k$ and verify that the gradient is nonzero at each. A single counterexample refutes the conjecture.

**Impact.** A formal proof would establish the geometric foundation for the claim that "the only elementary local obstruction is mod 9," connecting our algebraic number theory results to the geometry of cubic hypersurfaces.
