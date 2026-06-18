# Future Directions: Dynamical Ramanujan Theory

## Synthesis

The results established in this cycle — the prime decomposition theorem, periodic point formula, quadratic residue dichotomy, and composite obstruction — form the foundation of a new research program connecting arithmetic dynamics to spectral graph theory. The central insight is that the squaring map over finite fields generates expansion phenomena comparable to classical Ramanujan objects, while composites fail for structural reasons (idempotent fragmentation) that can be detected both algebraically and spectrally.

The directions below form a coherent ladder: Directions 1–2 are near-term extensions building directly on our catalog theorems, Directions 3–4 are ambitious conjectures requiring new mathematical infrastructure, and Direction 5 is a grand-challenge conjecture that would establish polynomial dynamics as a systematic source of optimal expanders.

All five directions share a common thread: using the interplay between algebraic structure (ring decomposition, character theory) and dynamical behavior (orbits, mixing, expansion) to discover new spectral phenomena over finite fields.

---

## Direction 1: Spectral Bound via Character Sum Formalization

**Conjecture:** For odd primes $p$, the second eigenvalue of the unit squaring graph $\Gamma_{\text{sq}}^\times(\mathbb{F}_p)$ satisfies
$$\lambda_2 \leq 2\sqrt{p-1} + O(1).$$
More precisely, the nontrivial eigenvalues of the adjacency operator on the multiplicative core are controlled by Gauss sums and satisfy the Weil bound.

**Test:** Formalize the Hasse-Weil bound for multiplicative character sums over $\mathbb{F}_p$ in Lean 4, then express the adjacency operator in terms of character eigenspaces and derive the bound. Alternatively, prove the trace bound $\text{tr}(A^{2k}) \leq C \cdot (p-1) \cdot p^k$ for the mean-zero part, which implies $\lambda_2 \leq C' \sqrt{p}$ by the $2k$-th root.

**Impact:** This would be the first formally verified spectral bound for a polynomial dynamical graph, establishing that polynomial dynamics is a rigorous source of expander-like behavior. It would open the door to certified expansion certificates for cryptographic protocols based on modular squaring.

**Catalog References:**
- `Pythagorean/DynamicalRamanujan.lean`: `units_pow_eq_one_card`, `prime_sq_periodic_card`
- `Pythagorean/SpectralGap.lean`: `prime_sq_idempotents_eq_zero_or_one`

**Proof Strategy:** Use Strategy A (exponent linearization): via a primitive root, transport the unit squaring adjacency to the doubling map on $\mathbb{Z}/(p-1)\mathbb{Z}$. Diagonalize the adjacency operator using additive characters on the cyclic group. Each eigenvalue becomes a sum of two character values evaluated at 1 and $2^{-1}$ (or contributes to gcd strata when 2 is not invertible mod $p-1$). Apply Weil's bound to control these sums.

**Domain Bridges:** Number theory (character sums) ↔ Spectral graph theory (eigenvalue bounds) ↔ Cryptography (certified expansion).

**Lineage:** Extends `units_pow_eq_one_card` and `prime_powEq_self_card` from cyclic group counting to cyclic group spectral decomposition.

**Ambition:** Grand challenge — requires formalizing Weil bounds, which are not yet in Mathlib.

---

## Direction 2: Higher-Degree Power Maps and Generalized Periodic Point Formula

**Conjecture:** For any $k \geq 2$ and prime $p$, the $k$-th power map $x \mapsto x^k$ on $\mathbb{F}_p$ satisfies:
$$|\{x \in \mathbb{F}_p : x^{k^m} = x\}| = 1 + \gcd(k^m - 1, p - 1)$$
and the corresponding unit power graph has $\lambda_2 = O_k(\sqrt{p})$.

**Test:** Prove the periodic point formula for general $k$ (this should be a direct generalization of our $k = 2$ proof). Then compute spectra for the $k$-th power graph on primes $p < 5000$ for $k \in \{2, 3, 5, 7\}$ and check whether the $\lambda_2/\sqrt{p}$ ratio is uniformly bounded.

**Impact:** Would establish that *all* prime power maps produce near-Ramanujan expansion, not just squaring. This generalizes the Dynamical Ramanujan phenomenon from a single example to a family parameterized by $k$.

**Catalog References:**
- `Pythagorean/DynamicalRamanujan.lean`: `prime_powEq_self_card` (base case $k = 2$)
- `Pythagorean/SpectralGap.lean`: `prime_sq_idempotents_eq_zero_or_one` (structural primality input)

**Proof Strategy:** The periodic point formula proof generalizes directly: replace $2^m$ with $k^m$ throughout. For the spectral bound, the exponent linearization strategy carries over: $x \mapsto x^k$ becomes $j \mapsto kj$ on the exponent group, and the adjacency operator becomes $U_k + U_k^*$ where $U_k$ is the $k$-fold shift.

**Domain Bridges:** Arithmetic dynamics ($k$-th power maps) ↔ Finite group representations (generalized characters) ↔ Additive combinatorics (generalized sum-product phenomena).

**Lineage:** Direct extension of `prime_sq_periodic_card`.

**Ambition:** Solid extension — the periodic point formula is provable now; the spectral bound is more challenging.

---

## Direction 3: Quantitative Composite Spectral Suppression

**Conjecture:** For composite $n$ with $\omega(n) \geq 2$ distinct prime factors, the spectral gap of the squaring graph satisfies:
$$\text{gap}(\Gamma_{\text{sq}}(n)) \leq \text{gap}(\Gamma_{\text{sq}}(p)) \cdot \left(1 - \frac{c}{\omega(n)}\right)$$
for some absolute constant $c > 0$ and for any prime $p$ of comparable size. More precisely, the Cheeger constant satisfies $h(\Gamma_{\text{sq}}(n)) \leq C / 2^{\omega(n)}$.

**Test:** Compute spectral gaps for all $n \leq 10^4$ and plot gap versus $\omega(n)$ controlling for size. Fit the decay rate. If the decay is sub-exponential in $\omega(n)$, the conjecture fails; if it is exponential, it holds.

**Impact:** Would give a quantitative connection between number-theoretic complexity ($\omega(n)$) and graph-theoretic expansion, potentially yielding a spectral compositeness test with complexity depending on $\omega(n)$.

**Catalog References:**
- `Pythagorean/DynamicalRamanujan.lean`: `composite_sqInvariant_obstruction`, `idempotent_invariant_set`
- `Pythagorean/SpectralGap.lean`: `arithmetic_fragmentation_theorem`

**Proof Strategy:** Use the CRT decomposition $\mathbb{Z}/n\mathbb{Z} \cong \prod_i \mathbb{Z}/p_i^{a_i}\mathbb{Z}$. The squaring graph on the product is a tensor product (or strong product) of the factor graphs. Bound the spectrum of the product using the spectra of the factors, showing that each additional factor introduces a spectral defect.

**Domain Bridges:** Ring decomposition (CRT) ↔ Graph products (tensor spectrum) ↔ Information theory (multi-coordinate memory retention).

**Lineage:** Extends `composite_sqInvariant_obstruction` from qualitative to quantitative.

**Ambition:** Solid extension — the qualitative version is proved; the quantitative version requires spectral product estimates.

---

## Direction 4: Algebraic Correspondence Spectral Theory

**Conjecture:** The spectral zeta function of the squaring graph $\Gamma_{\text{sq}}^\times(\mathbb{F}_p)$ can be expressed in terms of the Hasse-Weil zeta function of the algebraic correspondence $C: y = x^2$ on $\mathbb{A}^1 \times \mathbb{A}^1$ over $\mathbb{F}_p$. Specifically:
$$\det(I - tA) = \prod_i (1 - \alpha_i t)$$
where the $\alpha_i$ are algebraic integers related to the eigenvalues of Frobenius on the étale cohomology of the iterated correspondence.

**Test:** Compute $\det(I - tA)$ explicitly for primes $p < 100$ and check whether the roots are algebraic integers of the predicted type. Compare with known Frobenius eigenvalues on the relevant cohomology groups (which for $y = x^2$ are essentially quadratic Gauss sums).

**Impact:** Would establish a formal bridge between spectral graph theory and arithmetic algebraic geometry, showing that graph eigenvalues of polynomial dynamical systems are *arithmetic invariants* of algebraic correspondences. This is a paradigm-shifting connection.

**Catalog References:**
- `Pythagorean/DynamicalRamanujan.lean`: `prime_sq_periodic_card` (trace formula = point counts on correspondence)

**Proof Strategy:** Express $\text{tr}(A^m)$ as a point count on the $m$-fold iterated correspondence $x_0 \to x_1 \to \cdots \to x_m = x_0$ where each arrow is $x_{i+1} = x_i^2$ or $x_i = x_{i+1}^2$. Apply the Grothendieck-Lefschetz trace formula to relate this to Frobenius eigenvalues on cohomology.

**Domain Bridges:** Algebraic geometry (correspondences, cohomology) ↔ Spectral graph theory (zeta functions) ↔ Number theory (Weil conjectures).

**Lineage:** The periodic point formula is already a trace formula; this direction lifts it to the cohomological level.

**Ambition:** Grand challenge — requires substantial algebraic geometry infrastructure.

---

## Direction 5: Universal Polynomial Expander Theorem

**Conjecture:** For any polynomial $f \in \mathbb{Z}[x]$ of degree $d \geq 2$ and any sequence of primes $p_1 < p_2 < \cdots$, the family of undirected graphs $\Gamma_f(p_i)$ (with edge relation $f(x) = y$ or $f(y) = x$) restricted to the appropriate dynamical core forms an **expander family**: there exists $\epsilon > 0$ depending only on $d$ such that the normalized spectral gap is $\geq \epsilon$ for all sufficiently large $p_i$.

**Test:** Compute spectra for $f(x) = x^2 + 1$, $f(x) = x^3$, $f(x) = x^2 + x$, and $f(x) = x^3 - x$ over primes $p < 5000$. Plot normalized spectral gaps. If any family shows gap → 0, the conjecture fails for that polynomial. If all families show bounded-below gap, the conjecture is supported.

**Impact:** Would establish polynomial dynamics over finite fields as a universal source of expander graphs, comparable to the Margulis and LPS constructions but using the elementary operation of polynomial evaluation. This would be a foundational result connecting algebraic dynamics to combinatorics.

**Catalog References:**
- `Pythagorean/DynamicalRamanujan.lean`: entire theorem suite (provides the base case $f(x) = x^2$)
- `Pythagorean/SpectralGap.lean`: `arithmetic_fragmentation_theorem` (composite obstruction method)

**Proof Strategy:** For the squaring case, use exponent linearization + character sums. For general $f$, the key tool is the Weil bound for curves: the graph of $f(x) = y$ defines a curve in $\mathbb{A}^2$, and walk counts translate to point counts on fiber products of this curve. The Weil bound gives $O(\sqrt{p})$ bounds on these counts, which translate to eigenvalue bounds.

**Domain Bridges:** Algebraic geometry (Weil conjectures for curves) ↔ Arithmetic dynamics (polynomial iteration) ↔ Theoretical computer science (expander constructions) ↔ Cryptography (hash function expansion properties).

**Lineage:** Represents the ultimate generalization of the Dynamical Ramanujan program initiated in this cycle.

**Ambition:** Grand challenge — resolution would be a major result in combinatorics and number theory.
