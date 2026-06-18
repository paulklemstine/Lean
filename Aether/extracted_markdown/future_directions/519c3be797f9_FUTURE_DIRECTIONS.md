# Future Directions: Recurrence Spectrum Theory

## Synthesis

This research cycle introduced the **Recurrence Spectrum** — a novel mathematical structure that packages the complete period structure of a dynamical system into a single formal object. The spectrum records which minimal periods are realized, provides witnessing periodic points, and supports structural analysis through spectral dimension and entropy.

The cycle's key results established the *non-emptiness* of the recurrence spectrum for continuous interval maps (via the Interval Fixed Point Theorem), *period propagation* through multiples and divisibility, *orbit containment* for periodic trajectories, and *finite bounds* on periodic orbit complexity. For the logistic map, we proved invariance of the unit interval, fixed-point existence, and computed both trivial and nontrivial fixed points. We also formalized the Sharkovsky ordering and proved basic forcing relationships (period 3 forces periods 1 and 2; all odd periods ≥ 3 force period 1).

The most promising cross-domain connection is between the Recurrence Spectrum and **topological entropy**. The growth rate of periodic point counts $|\text{Fix}(f^n)|$ is intimately connected to topological entropy $h(f)$, and formalizing this connection would establish the Recurrence Spectrum as a *complete* complexity invariant for one-dimensional dynamics. This bridges dynamical systems theory (Physics/Bridges domain) with information-theoretic measures (EML/Computation domain). The Sharkovsky ordering formalization also connects to the existing `finite_state_orbit_periodic` theorem in `Bridges/ModularCFDynamics.lean`, which establishes periodicity for finite-state dynamics — our bijective periodicity theorem generalizes and sharpens this.

---

### Direction 1: Full Formalization of Sharkovsky's Theorem

**Conjecture**: If $f: [a,b] \to [a,b]$ is continuous and has a periodic point of period $n$, then for every positive integer $m$ with $n \trianglelefteq_S m$ in the Sharkovsky ordering, $f$ also has a periodic point of period $m$.

**Test**: Formalize the complete proof of Sharkovsky's theorem in Lean 4. The key intermediate result is: if $f$ has a period-3 orbit $a < b < c$ with $f(a) = b$, $f(b) = c$, $f(c) = a$ (or any permutation), then $f$ has periodic points of all periods. Verify by constructing explicit periodic points for periods 1 through 10 in the logistic map at $r = 3.83$.

**Impact**: Sharkovsky's theorem is one of the deepest results in one-dimensional dynamics. A complete Lean 4 formalization would be a significant contribution to the Mathlib library and would immediately unlock downstream results about chaotic dynamics, Li-Yorke chaos, and symbolic dynamics.

**Catalog References**: `Bridges/ModularCFDynamics.lean` (finite_state_orbit_periodic), `Novelty/RecurrenceSpectrum/Core.lean` (sharkovskyLE, sharkovsky_3_forces_1)

**Proof Strategy**: The standard proof uses the "Stefan ordering" on periodic orbits and constructs intermediate value intervals. Key lemmas needed:
1. If $f$ has a period-3 orbit with specific monotonicity, there exist subintervals $I_0, I_1$ such that $f(I_0) \supseteq I_0 \cup I_1$ and $f(I_1) \supseteq I_0$.
2. Symbolic dynamics: for any binary sequence, there exists a point whose orbit visits $I_0$ and $I_1$ in the prescribed pattern.
3. A point with orbit pattern $(I_1, I_0, I_0, \ldots, I_0)$ of length $n$ has minimal period $n$.

**Domain Bridges**: Dynamical Systems <-> Combinatorics (symbolic dynamics), Dynamical Systems <-> Topology (IVT, connectedness)

**Lineage**: Extends this cycle's `interval_fixed_point`, `sharkovsky_3_forces_1`, `sharkovsky_odd_forces_1`

**Ambition**: grand_challenge

---

### Direction 2: Spectral Entropy Equals Topological Entropy

**Conjecture**: For a continuous piecewise-monotone map $f: [0,1] \to [0,1]$ with $\ell$ laps (maximal monotone pieces), the spectral entropy $h_{\text{spec}}(f) := \lim_{n \to \infty} \frac{1}{n} \log |\text{Fix}(f^n)|$ equals the topological entropy $h_{\text{top}}(f) = \lim_{n \to \infty} \frac{1}{n} \log \ell_n$, where $\ell_n$ is the lap count of $f^n$.

**Test**: Compute both quantities numerically for the logistic map at $r = 4$ (where $h_{\text{top}} = \log 2$) and at $r = 3.83$ (period-3 window, $h_{\text{top}} \approx 0.38$). Verify they agree to at least 3 decimal places.

**Impact**: This would establish the Recurrence Spectrum as a *complete invariant* for the complexity of piecewise-monotone interval maps, making the spectral entropy a computable proxy for topological entropy.

**Catalog References**: `Novelty/RecurrenceSpectrum/Core.lean` (periodic_point_count_le, spectrum_contains_one), `EML/AdvancedTheory.lean` (ensemble_complexity_additive)

**Proof Strategy**: The equality is known classically (Misiurewicz-Szlenk theorem). Formalize:
1. Define lap count and topological entropy via open covers.
2. Prove $|\text{Fix}(f^n)| \leq \ell_n + 1$ (each lap contributes at most one fixed point of $f^n$).
3. Prove the reverse inequality using the variational principle: the measure of maximal entropy concentrates on periodic orbits.

**Domain Bridges**: Dynamical Systems <-> Information Theory (entropy), Dynamical Systems <-> Ergodic Theory

**Lineage**: Extends this cycle's spectral entropy definitions and periodic point counting

**Ambition**: grand_challenge

---

### Direction 3: Recurrence Spectrum of Continuous Maps on Trees

**Conjecture**: For continuous maps on finite trees (1-dimensional CW-complexes), the set of minimal periods realized is a tail in a generalized Sharkovsky ordering that depends on the combinatorial structure of the tree.

**Test**: For the triod (Y-shaped tree with 3 branches meeting at a vertex), compute the set of possible period sets for continuous self-maps. Verify that the analog of "period 3 implies all periods" fails or requires modification.

**Impact**: Trees are the natural generalization of intervals for one-dimensional dynamics. Understanding period-forcing on trees would extend the Recurrence Spectrum framework to a much wider class of spaces.

**Catalog References**: `Novelty/RecurrenceSpectrum/Core.lean` (RecurrenceSpectrum, isSharkovskyClosed), `Bridges/ModularCFDynamics.lean`

**Proof Strategy**: 
1. Define a "tree map" as a continuous self-map of a finite graph with no cycles.
2. Classify period sets for maps on the triod (known to differ from interval maps — Alsedà, Llibre, Misiurewicz).
3. Define a generalized Sharkovsky ordering for each tree type.
4. Prove that the recurrence spectrum of a tree map is a tail in this ordering.

**Domain Bridges**: Dynamical Systems <-> Graph Theory, Dynamical Systems <-> Algebraic Topology (fundamental group of graphs)

**Lineage**: Extends the Sharkovsky ordering formalization from this cycle

**Ambition**: extension

---

### Direction 4: Orbit Counting for the Logistic Map via Symbolic Dynamics

**Conjecture**: For the full logistic map $f_4(x) = 4x(1-x)$, the number of minimal period-$n$ orbits is $\frac{1}{n} \sum_{d | n} \mu(n/d) \cdot 2^d$, matching the necklace counting formula for binary strings under the Möbius function $\mu$.

**Test**: Compute the number of minimal period-$n$ orbits for $n = 1, \ldots, 12$ both numerically (by finding periodic points of $f_4$) and via the formula. They should agree exactly.

**Impact**: This connects the Recurrence Spectrum to combinatorics and number theory via the Möbius function, establishing that periodic orbit counting in chaotic dynamics reduces to a purely combinatorial problem.

**Catalog References**: `Novelty/RecurrenceSpectrum/Core.lean` (orbit_subset_finiteOrbit, period_divides), `Cryptography/MasterFormula.lean` (complement_density_fixed_points)

**Proof Strategy**:
1. Establish the semiconjugacy between $f_4$ and the doubling map $x \mapsto 2x \pmod{1}$ via $h(x) = \sin^2(\pi x / 2)$.
2. Periodic orbits of the doubling map correspond to binary strings under cyclic equivalence.
3. Count binary necklaces using Burnside's lemma / Möbius inversion.
4. Transfer the count back to $f_4$ via the semiconjugacy.

**Domain Bridges**: Dynamical Systems <-> Number Theory (Möbius function), Dynamical Systems <-> Combinatorics (necklace counting), Dynamical Systems <-> Cryptography (symbolic dynamics ↔ binary sequences)

**Lineage**: Extends logistic map analysis from this cycle

**Ambition**: extension

---

### Direction 5: Categorical Recurrence Spectra

**Conjecture**: The assignment $f \mapsto \mathcal{R}(f)$ defines a functor from the category of dynamical systems (with semiconjugacies as morphisms) to a category of "period structures" (downward-closed subsets of the Sharkovsky ordering, with inclusions as morphisms). This functor preserves products and detects topological conjugacy classes.

**Test**: Verify functoriality on three concrete examples: (a) the identity map, (b) the doubling map, (c) the logistic map at $r = 3.83$. Check that semiconjugate systems have compatible recurrence spectra.

**Impact**: A categorical framework would make the Recurrence Spectrum a natural invariant in the sense of category theory, enabling systematic computation via functorial properties and connecting to existing categorical structures in Mathlib.

**Catalog References**: `Novelty/RecurrenceSpectrum/Core.lean` (RecurrenceSpectrum), `Bridges/TannakaClosureReconstruction.lean` (categorical reconstruction techniques)

**Proof Strategy**:
1. Define the category of dynamical systems: objects are pairs $(X, f)$, morphisms $h: (X, f) \to (Y, g)$ are continuous maps with $h \circ f = g \circ h$.
2. Define the category of Sharkovsky tails.
3. Show that semiconjugacy preserves periods: if $h \circ f = g \circ h$ and $f^n(x) = x$, then $g^n(h(x)) = h(x)$.
4. Prove the functor preserves products using coordinate-wise dynamics.

**Domain Bridges**: Dynamical Systems <-> Category Theory, Dynamical Systems <-> Algebra (group actions)

**Lineage**: Extends the RecurrenceSpectrum definition from this cycle, connects to Tannaka reconstruction in Bridges

**Ambition**: extension
