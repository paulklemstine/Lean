# Future Research Directions

## Synthesis

This research cycle formalized three pillars connecting quantum mechanics to the periodic table: (1) the Pythagorean sum-of-odd-numbers identity as the source of 2n² shell degeneracy, (2) the well-foundedness of the Madelung (n+l, n) filling order, and (3) the binomial coefficient formula C(N+3,3) for harmonic oscillator cumulative shell closures. These were unified through the SpectralShellSystem abstraction, which captures periodic-table-like partitions in full generality.

The most promising cross-domain connection is between the discrete SpectralShellSystem framework and the existing Catalog work on spectral gaps and Lorentzian spectral theory. The cumulative filling function is mathematically analogous to a spectral counting function (Weyl's law), and the strict monotonicity theorem mirrors the positivity of spectral gaps. This suggests a unified framework where both atomic shell structure and graph expansion properties are governed by the same abstract spectral principles — the key bridge being that both involve counting eigenvalues below a threshold, with the threshold determining "period" boundaries.

The highest breakthrough potential lies in Direction 1: deriving the Madelung rule from a Hamiltonian with screened Coulomb potential. This 90-year-old open problem in atomic physics has never been resolved from first principles. Even a partial result — such as proving the rule for hydrogen-like potentials with specific screening functions — would be a significant contribution. The Madelung well-foundedness proof from this cycle provides the order-theoretic foundation needed; what remains is connecting it to spectral theory of Schrödinger operators.

---

### Direction 1: Deriving the Madelung Rule from Screened Coulomb Spectra

**Conjecture**: For a radial Schrödinger equation with potential V(r) = -Z_eff(r)/r where Z_eff : ℝ → ℝ is positive and monotonically decreasing (modeling electron shielding), the eigenvalues E_{n,l} satisfy the Madelung ordering: E_{n₁,l₁} < E_{n₂,l₂} whenever n₁+l₁ < n₂+l₂, or n₁+l₁ = n₂+l₂ and n₁ < n₂.

**Test**: Compute eigenvalues numerically for specific screening functions (e.g., Thomas-Fermi: Z_eff(r) = Z·φ(r/a) where φ is the Thomas-Fermi function). Verify the (n+l, n) ordering holds for the first 20 subshells. Identify the class of screening functions for which exceptions occur (these correspond to the known Madelung rule violations in elements like Cr and Cu).

**Impact**: Would resolve a foundational open problem in theoretical chemistry. If false in general, characterizing the exception space would explain why certain elements violate the aufbau principle. This connects order theory (well-foundedness) to spectral theory (eigenvalue ordering) in a way that could yield new results about eigenvalue monotonicity.

**Catalog References**: `Physics/QuantumShells.lean` (MadelungLt, madelung_wellFounded)

**Proof Strategy**: 
1. Define a formal framework for radial Schrödinger operators with screened Coulomb potentials.
2. Use perturbation theory: for pure Coulomb (hydrogen), E_{n,l} depends only on n, so the ordering is trivially satisfied. Screening breaks the l-degeneracy.
3. Show that for "sufficiently gentle" screening, the l-splitting is monotone in l for fixed n, which forces the Madelung ordering.
4. Key lemma needed: for monotonically decreasing Z_eff, the centrifugal barrier l(l+1)/r² raises energy more for higher l within the same n+l group.

**Domain Bridges**: Order theory (well-foundedness) ↔ Spectral theory (eigenvalue ordering) ↔ Chemistry (aufbau principle)

**Lineage**: Builds on madelung_wellFounded and MadelungLt from this cycle's Physics/QuantumShells.lean.

**Ambition**: grand_challenge

---

### Direction 2: Spectral Counting Functions and Weyl's Law Discretization

**Conjecture**: The SpectralShellSystem.cumulative function satisfies a discrete analogue of Weyl's asymptotic law. Specifically, for the electronic shell system with multiplicity(n) = 2(n+1)², the cumulative function satisfies cumulative(n) ~ (2/3)n³ as n → ∞. More precisely, 3·cumulative(n) / (n+1)³ → 2 as n → ∞.

**Test**: Compute the ratio 3·cumulative(n) / ((n+1)(n+2)(2n+3)/3) for n = 1 to 100 and verify it equals 1 exactly (not just asymptotically — verify the exact formula cumulative(n) = (n+1)(n+2)(2n+3)/3). Then prove the asymptotic statement formally using Lean's Filter.Tendsto.

**Impact**: Would establish a rigorous bridge between discrete shell-filling and continuous spectral asymptotics. This connects the periodic table to the mathematical theory of spectral counting functions, which governs eigenvalue distribution in differential operators. Could lead to a unified framework where Weyl's law and shell degeneracy are special cases of a single counting principle.

**Catalog References**: `Physics/QuantumShells.lean` (SpectralShellSystem, cumulative_strictMono, electronic_cumulative), `Bridges/QuantumLorentzianBridge.lean` (spectral gap connections)

**Proof Strategy**:
1. Prove the exact formula cumulative(n) = (n+1)(n+2)(2n+3)/3 from the sum-of-squares formula.
2. Define the asymptotic ratio and prove convergence using Mathlib's Filter.Tendsto.
3. Generalize: for multiplicity(n) = a·n^d + lower order, prove cumulative(n) ~ a·n^{d+1}/(d+1).
4. Connect to Weyl's law: if the multiplicity sequence arises from eigenvalue spacings of a Laplacian on a d-dimensional domain, the cumulative formula should recover the Weyl coefficient.

**Domain Bridges**: Combinatorics (shell counting) ↔ Analysis (Weyl asymptotics) ↔ Spectral geometry (eigenvalue distribution)

**Lineage**: Builds on sum_sq_formula, electronic_cumulative, and SpectralShellSystem from this cycle.

**Ambition**: extension

---

### Direction 3: Period-Doubling as a Topological Invariant

**Conjecture**: The period-doubling phenomenon in the Madelung filling order (period lengths 2, 8, 8, 18, 18, 32, 32, ...) is a topological invariant: any continuous deformation of the filling order that preserves well-foundedness and respects subshell grouping must produce the same pattern of doubled period lengths.

**Test**: Define a parameterized family of well-orders on ℕ × ℕ interpolating between the Madelung order and other natural orders (e.g., (n, l) lexicographic). Compute the period-length sequence for each. Check whether the doubling pattern persists or breaks. A single counterexample disproves the conjecture.

**Impact**: If true, would show that period doubling is not an accident of the specific (n+l, n) rule but a necessary consequence of any "reasonable" shell-filling scheme. This would explain why alternative periodic table arrangements (Janet's left-step table, Stowe's physicist's table) all exhibit the same period doubling despite different orderings of subshells within each period.

**Catalog References**: `Physics/QuantumShells.lean` (MadelungLt, madelung_wellFounded, madelung_trichotomy)

**Proof Strategy**:
1. Define a formal notion of "shell-filling order": a well-order on ℕ × ℕ respecting certain symmetry constraints (e.g., all (n, l) with same n+l are contiguous).
2. Prove that any such order produces the same set of Madelung group capacities.
3. Key lemma: the capacity of Madelung group g depends only on which (n, l) pairs have n+l = g and l ≤ n-1, which is determined by the constraint set, not the internal ordering.
4. The doubling then follows from the algebraic identity relating adjacent group capacities.

**Domain Bridges**: Order theory (well-orders) ↔ Topology (deformation invariance) ↔ Chemistry (periodic table variants)

**Lineage**: Builds on MadelungLt well-foundedness and trichotomy from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Generalized Magic Numbers via Polynomial Shell Systems

**Conjecture**: For the "d-dimensional harmonic oscillator shell system" with degeneracy C(N+d-1, d-1), the cumulative formula is C(N+d, d), and the resulting magic numbers form a d-dimensional Pascal simplex. The d=3 case is the nuclear physics result C(N+3, 3); the d=2 case gives triangular numbers; the d=1 case gives consecutive integers.

**Test**: Prove the identity ∑_{k=0}^{N} C(k+d-1, d-1) = C(N+d, d) for general d ∈ ℕ using the hockey stick identity. Compute magic numbers for d = 2, 3, 4, 5 and verify they match C(N+d, d).

**Impact**: Would generalize nuclear magic numbers to arbitrary dimensions, potentially relevant for quantum dots (d=2), cold atom systems in optical lattices (variable effective dimension), and mathematical physics of higher-dimensional harmonic oscillators. The hockey stick identity provides a clean combinatorial proof.

**Catalog References**: `Physics/QuantumShells.lean` (hoDegeneracy, ho_cumulative_eq_choose, choose_three_formula)

**Proof Strategy**:
1. State the d-dimensional degeneracy: dDegeneracy(d, N) = C(N+d-1, d-1).
2. Prove the hockey stick identity: ∑_{k=0}^{N} C(k+r, r) = C(N+r+1, r+1) by induction on N using Pascal's rule.
3. Instantiate at r = d-1 to get the cumulative formula.
4. Define a d-dimensional SpectralShellSystem and verify it satisfies all axioms.
5. Compute magic number sequences for d = 1 through 5.

**Domain Bridges**: Combinatorics (Pascal's triangle) ↔ Nuclear physics (magic numbers) ↔ Quantum information (quantum dots)

**Lineage**: Builds on ho_cumulative_eq_choose and the induction-via-Pascal approach from this cycle.

**Ambition**: extension

---

### Direction 5: Madelung Order Anomalies and Transition Metal Chemistry

**Conjecture**: The Madelung rule violations (elements where the actual ground-state electron configuration differs from the Madelung prediction, such as Cr: [Ar]3d⁵4s¹ instead of [Ar]3d⁴4s²) occur precisely at the subshells where the energy gap between consecutive Madelung-ordered subshells is minimized. Formally: define the "Madelung gap" at position k as E_{σ(k+1)} - E_{σ(k)} where σ is the Madelung ordering of subshells. The conjecture states that violations occur only when this gap is below a computable threshold depending on Z.

**Test**: Compute Madelung gaps numerically for Z = 1 to 120 using Hartree-Fock energies from NIST. Identify all elements where the ground-state configuration differs from Madelung prediction. Check whether every violation corresponds to a gap below the threshold. The threshold should scale approximately as Z^{-1/3} based on Thomas-Fermi scaling.

**Impact**: Would provide a quantitative criterion for when the Madelung rule fails, replacing the qualitative understanding currently used in chemistry education. Could also predict which superheavy elements (Z > 118) will violate the Madelung rule, guiding experimental searches.

**Catalog References**: `Physics/QuantumShells.lean` (MadelungLt, madelung_wellFounded, orbitalDegeneracy)

**Proof Strategy**:
1. Formalize a database of known electron configurations (Z = 1 to 118).
2. Identify Madelung violations computationally.
3. Define the gap function using a parameterized energy model.
4. Prove that for sufficiently large Z, the gap decreases monotonically.
5. Establish the threshold criterion and verify against known data.

**Domain Bridges**: Order theory (ordering anomalies) ↔ Computational chemistry (Hartree-Fock) ↔ Nuclear physics (superheavy elements)

**Lineage**: Builds on the Madelung ordering framework from this cycle.

**Ambition**: extension
