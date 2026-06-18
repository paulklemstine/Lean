# Future Directions: Diagonal Obstruction Calculus

## Synthesis

The diagonal obstruction calculus established in this work provides a formal, computationally certified framework for studying local representability of diagonal Diophantine equations $\sum x_i^n = k$. The five proven theorems—global-to-local descent, divisibility monotonicity, surjectivity completeness, unit power symmetry, and CRT composition—form an interlocking system that reduces the infinite landscape of local obstructions to a finite, structured computation over prime powers. The following directions extend this foundation in five distinct ways: two grand challenges that would reshape the interaction between formal verification and number theory, and three solid extensions that build directly on the established theorems.

---

## Direction 1: Formalize the p-adic Density and Singular Series Connection

**Conjecture:** For fixed $n, s$ with $s$ sufficiently large relative to $n$, the product $\prod_{p} \beta_p(n, s, k)$ over all primes $p$ converges absolutely, where $\beta_p(n, s, k) = \lim_{a \to \infty} p^{-a(s-1)} \cdot |\{x \in (\mathbb{Z}/p^a\mathbb{Z})^s : \sum x_i^n \equiv k \pmod{p^a}\}|$ is the local $p$-adic density.

**Test:** Compute $\beta_p(4, 4, k)$ for primes $p \leq 50$ and exponents $a \leq 8$. Verify numerical convergence of the partial products. For $s = 4, n = 4$, the singular series should diverge for $k$ in certain residue classes modulo high powers of 2, reflecting the persistent 2-adic obstruction.

**Impact:** This would be the first formal connection between the finite obstruction calculus (Theorems 1–5) and the analytic number theory of the Hardy-Littlewood circle method. It transforms the discrete `UniversallySurjectiveMod` predicate into a quantitative density measure.

**Catalog References:** `Pythagorean/DiagonalObstruction.lean` (Theorems 3.1, 3.7), `Algebra/SumThreeCubes/LocalObstruction.lean`.

**Proof Strategy:** Define $\beta_p$ as a limit of normalized counts over $(\mathbb{Z}/p^a\mathbb{Z})^s$. Use the divisibility descent theorem to show the sequence is monotone in a suitable sense. Prove convergence using Hensel's lemma lifting for smooth fibers. The CRT composition theorem provides the product formula.

**Domain Bridges:** Analytic number theory (singular series), $p$-adic analysis (Hensel lifting), formal verification (certified convergence).

**Lineage:** Extends Theorem 5 (CRT composition) into the analytic domain.

**Ambition:** Grand challenge — would constitute the first formal verification of a component of the Hardy-Littlewood circle method.

**The key insight is** that the finite `UniversallySurjectiveMod` predicate is the zero-th order approximation to a rich quantitative theory, and the transition from Boolean surjectivity to real-valued density requires formalizing $p$-adic limits within the obstruction framework.

**Why now?** Mathlib's $p$-adic analysis library has matured to the point where limits in $\mathbb{Q}_p$ and completions of $\mathbb{Z}$ are available. The obstruction calculus provides the finite-level foundation that the analytic theory needs as input.

---

## Direction 2: Automated Obstruction Classification via Decidability

**Conjecture:** For each fixed degree $n$ and variable count $s$, there exists a finite set $\mathcal{P}(n,s)$ of "critical" prime powers such that $\mathrm{UniversallySurjectiveMod}(n, s, m)$ holds if and only if $m$ has no prime power factor in $\mathcal{P}(n,s)$.

**Test:** For $(n,s) = (4,4)$, verify computationally that $\mathcal{P}(4,4) = \{2^3, 2^4, 2^5, \ldots, 5^2, 5^3, \ldots\}$ stabilizes: there exists $A(p)$ such that for $a \geq A(p)$, the surjectivity status of $p^a$ is determined by that of $p^{A(p)}$. Compute $A(p)$ for primes $p \leq 30$.

**Impact:** This would give a *decision procedure* for local admissibility: to check whether $k$ is everywhere locally admissible, one only needs to check finitely many moduli.

**Catalog References:** `Pythagorean/DiagonalObstruction.lean` (Theorem 3.7, `universally_surjective_mul_of_coprime`).

**Proof Strategy:** Use Hensel's lemma to show that for $p \nmid n$ and $a$ sufficiently large, the lifting property ensures surjectivity stabilizes. For $p \mid n$, the ramified case requires separate analysis. The finiteness of $\mathcal{P}(n,s)$ follows from the fact that all but finitely many primes are unramified.

**Domain Bridges:** Computational complexity (decidability), algebraic number theory (ramification), logic (formalized decision procedures).

**Lineage:** Directly extends the CRT composition theorem and the experimental findings.

**Ambition:** Grand challenge — connects formal verification to algorithmic number theory.

**The key insight is** that the CRT theorem reduces surjectivity to prime powers, and Hensel's lemma reduces prime powers to a finite initial segment, giving a doubly-finite reduction.

**Why now?** The CRT composition theorem is now formally verified, providing the first half of the reduction. Hensel's lemma is available in Mathlib for $p$-adic integers.

---

## Direction 3: Orbit Structure and Representation-Theoretic Obstruction Analysis

**Conjecture:** For prime $p$ and degree $n$ with $\gcd(n, p-1) = d$, the representable residue set $R(n, s, p)$ is a union of cosets of the subgroup of $d$-th powers in $(\mathbb{Z}/p\mathbb{Z})^\times$, and the number of missing cosets is determined by $s$ and $d$ alone.

**Test:** For $n = 4$, verify that at primes $p \equiv 1 \pmod{4}$ (where $d = 4$), the missing residues form a union of cosets of the index-4 subgroup. Compute the coset decomposition for $p = 5, 13, 17, 29, 37$.

**Impact:** This would connect the additive obstruction theory to the *representation theory* of finite abelian groups, providing algebraic explanations for computational observations.

**Catalog References:** `Pythagorean/DiagonalObstruction.lean` (Theorem 3.5, `diagonal_residue_sums_unit_power_invariant`).

**Proof Strategy:** The unit power symmetry theorem (Theorem 3.5) shows $R(n,s,m)$ is a union of orbits under $n$-th power units. For prime $p$, the $n$-th power units form the unique subgroup of index $\gcd(n, p-1)$ in $\mathbb{F}_p^\times$. Characterize which cosets are representable using character sum estimates (Gauss sums).

**Domain Bridges:** Finite group theory (coset decomposition), representation theory (characters of cyclic groups), algebraic geometry (points on varieties over finite fields).

**Lineage:** Extends Theorem 4 (unit power symmetry) with structural content.

**Ambition:** Solid extension — within reach using existing character sum theory.

**The key insight is** that the unit power symmetry theorem already provides the group action; what remains is to classify the orbits using the arithmetic of finite fields.

**Why now?** The symmetry theorem is proven. Character sum estimates for diagonal forms over finite fields are classical (Weil, Deligne) and could be formalized with moderate effort.

---

## Direction 4: Local Obstructions for Non-Diagonal Forms

**Conjecture:** The obstruction calculus generalizes to arbitrary homogeneous forms $F(x_1, \ldots, x_s) = k$ where $F$ is a degree-$n$ form over $\mathbb{Z}$. The global-to-local principle, divisibility descent, and CRT composition hold verbatim, with `DiagonalLocalAdmissible` replaced by `FormLocalAdmissible F k m := ∃ x : Fin s → ZMod m, F(x) = k`.

**Test:** Implement the generalized framework for the Fermat cubic surface $x^3 + y^3 + z^3 + w^3 = k$ (non-diagonal due to symmetry considerations) and the norm form $N_{K/\mathbb{Q}}(x) = k$ for number fields $K$. Verify that Theorems 1–3 generalize with identical proofs.

**Impact:** This would extend the obstruction calculus from additive number theory to the broader setting of arithmetic geometry, covering quadratic forms, norm forms, and general hypersurfaces.

**Catalog References:** `Pythagorean/DiagonalObstruction.lean` (all theorems — the proofs are essentially form-independent).

**Proof Strategy:** The proofs of Theorems 1–3 use only the ring homomorphism property of $\mathbb{Z} \to \mathbb{Z}/m\mathbb{Z}$, which preserves any polynomial evaluation. Abstract the proof pattern to a general "polynomial local admissibility" framework parameterized by a polynomial $F$.

**Domain Bridges:** Arithmetic geometry (local-global principles for varieties), algebraic number theory (norm forms), physics (lattice models with polynomial Hamiltonians).

**Lineage:** Generalizes all five theorems to non-diagonal forms.

**Ambition:** Solid extension — the proofs are nearly identical, requiring only abstraction.

**The key insight is** that none of the five theorems use the diagonal structure of $\sum x_i^n$ in an essential way; they use only that it is a polynomial evaluated via a ring homomorphism.

**Why now?** The diagonal theory is complete and verified. The abstraction is straightforward and would immediately provide a reusable framework for all polynomial Diophantine equations.

---

## Direction 5: Quantum Diagonal Sums and Discrete Energy Shell Problems

**Conjecture:** The diagonal residue sum set $R(n, s, m)$ admits a Fourier-analytic characterization: $r \in R(n,s,m)$ if and only if $\sum_{\chi} \hat{f}_n(\chi)^s \chi(r) \neq 0$, where $\hat{f}_n$ is the discrete Fourier transform of the $n$-th power indicator function on $\mathbb{Z}/m\mathbb{Z}$.

**Test:** Compute the Fourier transform of the fourth-power indicator function modulo $m = 16, 25, 32$. Verify that the inverse transform of $\hat{f}_4^4$ is supported exactly on $R(4, 4, m)$.

**Impact:** This connects the combinatorial obstruction theory to harmonic analysis on finite groups, opening a path to proving asymptotic density results and establishing connections to quantum information theory (where diagonal sums appear in the analysis of quantum circuits over finite fields).

**Catalog References:** `Pythagorean/DiagonalObstruction.lean` (Definition 2.5, Theorem 3.9).

**Proof Strategy:** The convolution theorem for finite abelian groups says that the indicator function of $R(n,s,m)$ is the $s$-fold convolution of the $n$-th power indicator. Its Fourier transform is the $s$-th power of the Fourier transform of the single-variable indicator. Formalize using Mathlib's discrete Fourier transform on `ZMod m`.

**Domain Bridges:** Harmonic analysis (Fourier transform on finite groups), quantum computing (diagonal unitaries), statistical mechanics (partition functions as power sums).

**Lineage:** Provides an analytic perspective complementing the algebraic Theorems 1–5.

**Ambition:** Solid extension with speculative applications to physics.

**The key insight is** that the iterated sumset computation in Algorithm 1 is exactly discrete convolution, and the Fourier transform diagonalizes convolution, giving closed-form characterizations of representability.

**Why now?** Discrete Fourier analysis on finite groups is well-developed in Mathlib. The connection to quantum computing provides interdisciplinary motivation that could attract new collaborators.
