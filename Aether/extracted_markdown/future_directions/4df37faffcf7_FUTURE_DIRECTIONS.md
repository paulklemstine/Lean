# Future Directions: Submultiplicative Growth and Tropical Bridges

## Synthesis

This cycle established the formal infrastructure connecting submultiplicative sequences (arising from self-avoiding walk enumeration) to subadditive analysis (Fekete's lemma) and tropical algebra (min-plus convergence). The central achievement is the **Fekete–Tropical Bridge Theorem**: for a submultiplicative sequence with growth rate μ, the tropical envelope e(n) = log a(n) − nμ is both non-negative and subadditive, precisely characterizing the tropical convergence boundary. This theorem was fully machine-verified along with its prerequisites: the logarithmic conversion from submultiplicative to subadditive sequences, power bounds a(kn) ≤ a(n)^k for k ≥ 1, the Fekete growth rate computation for geometric sequences, growth rate upper bounds, and closure of growth systems under multiplication.

The irrationality of the Nienhuis constant √(2+√2) was proved via a clean cascade argument (√2 irrational → 2+√2 irrational → √(2+√2) irrational), its minimal polynomial x⁴ − 4x² + 2 = 0 was verified, and the absence of rational roots was established. These results connect to the Catalog's tropical infrastructure — the polynomial encodes algebraic structure that has a piecewise-linear tropical shadow, and the growth system formalism provides the analytic backbone for connective constant theory.

The highest breakthrough potential lies in **Direction 1** (tropical spectral bounds), which would use tropical matrix theory to derive new connective constant estimates — connecting the GrowthSystem formalism to the spectral walk bounds already in the catalog. **Direction 2** (subadditive ergodic theorems) would generalize the Fekete–Tropical Bridge to random environments. **Direction 3** (envelope periodicity) proposes a testable conjecture connecting algebraic degree of growth rates to envelope structure.

---

### Direction 1: Tropical Spectral Bounds for Connective Constants

**Conjecture**: For a lattice with adjacency matrix A, the connective constant μ satisfies the tropical spectral bound μ ≤ trop_ρ(A), where trop_ρ(A) is the tropical spectral radius (maximum cycle mean in the directed graph weighted by −log of edge weights). Moreover, for vertex-transitive lattices, equality holds: μ = trop_ρ(A).

**Test**: Compute trop_ρ(A) for the hexagonal lattice adjacency matrix and compare with the known value √(2+√2) ≈ 1.848. For the square lattice, compute trop_ρ and compare with the numerical estimate μ ≈ 2.638. A discrepancy would disprove equality; the inequality direction should always hold.

**Impact**: If true, this would provide a purely combinatorial/tropical method for computing or bounding connective constants, potentially yielding new exact values for lattices where no exact connective constant is known. If false, the failure mode would reveal what additional structure (beyond the adjacency matrix) determines the connective constant.

**Catalog References**: `Pythagorean/IharaZeta/Theorems.lean` (spectral walk count bounds), `MachineLearning/TropicalNTKDynamics.lean` (tropical matrix operations), `Pythagorean/SubadditiveGrowth.lean` (GrowthSystem, growthRate_le_log_base)

**Proof Strategy**: 
1. Define tropical spectral radius for non-negative matrices as max cycle mean.
2. Prove that the GrowthSystem growth rate is bounded by the log of the classical spectral radius (this follows from seq_le_base_pow and the spectral radius formula ρ(A) = lim ‖A^n‖^{1/n}).
3. Use the tropical spectral theorem (max cycle mean = tropical eigenvalue) to convert the bound.
4. For vertex-transitive graphs, exploit symmetry to show the walk count per vertex is exactly a(n) = c_n(G)/|V| times the number of vertices, tightening the bound.

**Domain Bridges**: Tropical geometry ↔ Spectral graph theory ↔ Combinatorial enumeration

**Lineage**: Builds on GrowthSystem.growthRate_le_log_base and spectral_walk_count_bound from the catalog.

**Ambition**: grand_challenge

---

### Direction 2: Subadditive Ergodic Theory and Random Growth Systems

**Conjecture**: For a sequence of i.i.d. random submultiplicative sequences {a_ω : ℕ → ℝ_{>0}}, the almost-sure growth rate μ_∞ = lim (1/n) log a_ω(n) exists and equals E[log a_ω(1)] (the expected log of the first term), generalizing Kingman's subadditive ergodic theorem to the multiplicative setting with a tropical interpretation.

**Test**: Simulate 10,000 random submultiplicative sequences where each a(1) is drawn from a log-normal distribution and a(n) is constructed recursively to be submultiplicative. Verify that the empirical growth rate concentrates around E[log a(1)]. Check whether the tropical envelope e_ω(n) satisfies a CLT (central limit theorem).

**Impact**: This would connect the deterministic Fekete–Tropical Bridge to probability theory, providing a framework for analyzing self-avoiding walks in random environments (e.g., on percolation clusters). The tropical envelope CLT would be entirely new.

**Catalog References**: `Pythagorean/SubadditiveGrowth.lean` (GrowthSystem, envelope_nonneg, envelope_subadditive)

**Proof Strategy**:
1. Formalize i.i.d. submultiplicative cocycles using Mathlib's measure theory.
2. Apply Kingman's subadditive ergodic theorem (which may need to be formalized) to the log-transformed sequence.
3. Show that the random tropical envelope e_ω(n) = log a_ω(n) − nμ_∞ satisfies Var(e_ω(n)) = O(n) under moment conditions.
4. Apply a martingale CLT to the envelope increments.

**Domain Bridges**: Subadditive analysis ↔ Ergodic theory ↔ Random media

**Lineage**: Builds on GrowthSystem and the Fekete–Tropical Bridge from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Tropical Envelope Periodicity and Algebraic Growth Rates

**Conjecture**: For a submultiplicative integer sequence a : ℕ → ℤ_{>0} whose growth rate μ is algebraic of degree d over ℚ, the tropical envelope e(n) = log a(n) − nμ satisfies: for every prime p, the sequence ⌊e(n)/ε⌋ mod p is eventually periodic with period dividing p^{d-1} − 1, where ε > 0 is a fixed precision parameter depending on the minimal polynomial of μ.

**Test**: For the hexagonal lattice SAW counts (d = 4, μ = √(2+√2)), compute e(n) for n up to 30 (using known exact counts) and check periodicity of ⌊e(n)·10^6⌋ mod 2, mod 3, mod 5. For geometric sequences (d = 1 when the base is rational), verify that e(n) = 0 identically (trivially periodic).

**Impact**: If true, this would provide an algebraic characterization of growth rates via the dynamics of the envelope — connecting number theory (algebraic degree) to combinatorics (walk counts) via tropical analysis. This would be a new structural result about submultiplicative sequences. If false, understanding the failure mode would clarify what additional information beyond algebraic degree determines envelope behavior.

**Catalog References**: `Pythagorean/SubadditiveGrowth.lean` (envelope_subadditive, envelope_nonneg), `Pythagorean/NienhuisIrrationality.lean` (nienhuis_minimal_poly, nienhuis_no_rational_root)

**Proof Strategy**:
1. Establish p-adic properties of the envelope for algebraic growth rates.
2. Use the minimal polynomial to derive recurrence relations for e(n) modulo primes.
3. Apply the theory of linear recurrences over finite fields to establish periodicity.
4. Bound the period using properties of the Galois group of the minimal polynomial.

**Domain Bridges**: Tropical analysis ↔ Number theory ↔ Combinatorial enumeration

**Lineage**: Builds on the Fekete–Tropical Bridge and Nienhuis constant results from this cycle.

**Ambition**: extension

---

### Direction 4: Irreducibility Certificates for Connective Constant Polynomials

**Conjecture**: The minimal polynomial x⁴ − 4x² + 2 of the Nienhuis constant is irreducible over ℚ, certifying that √(2+√2) has algebraic degree exactly 4. More generally, for the family of "nested radical" connective constants μ_k = √(2 + μ_{k-1}) with μ_0 = 0, the minimal polynomial of μ_k has degree 2^k and is irreducible over ℚ.

**Test**: For k = 1 (μ₁ = √2, degree 2), k = 2 (μ₂ = √(2+√2), degree 4), and k = 3 (μ₃ = √(2+√(2+√2)), degree 8), explicitly construct the minimal polynomials and verify irreducibility using the Eisenstein criterion or by checking irreducibility modulo small primes.

**Impact**: This would establish a tower of algebraic extensions ℚ ⊂ ℚ(μ₁) ⊂ ℚ(μ₂) ⊂ ... where each extension has degree 2, creating a "connective constant tower" with explicit Galois-theoretic structure. The Galois groups would be iterated wreath products of ℤ/2ℤ.

**Catalog References**: `Pythagorean/NienhuisIrrationality.lean` (nienhuis_minimal_poly, nienhuis_no_rational_root)

**Proof Strategy**:
1. Show x⁴ − 4x² + 2 is Eisenstein at p = 2 after a suitable substitution, or use Mathlib's `Irreducible` API.
2. Derive the general recurrence: if μ_k satisfies p_k(x) = 0, then μ_{k+1} satisfies p_{k+1}(x) = p_k(x² − 2) = 0.
3. Prove irreducibility by induction using the fact that p_k is irreducible and the substitution x → x² − 2 preserves irreducibility under appropriate conditions.
4. Compute Galois groups as iterated wreath products.

**Domain Bridges**: Algebraic number theory ↔ Galois theory ↔ Self-avoiding walk theory

**Lineage**: Directly extends nienhuis_minimal_poly and nienhuis_no_rational_root from this cycle.

**Ambition**: extension

---

### Direction 5: Discrete Holomorphicity and Parafermionic Observables

**Conjecture**: The parafermionic observable F(z) = Σ_{ω: a→z} x^{|ω|} e^{−iσW(ω)} on the medial lattice of the hexagonal lattice satisfies a discrete Cauchy-Riemann equation at x = 1/√(2+√2) and σ = 5/8, where the sum is over self-avoiding walks from a fixed vertex a to z, |ω| is the walk length, and W(ω) is the winding angle.

**Test**: On a small hexagonal lattice (e.g., 6×6 with appropriate boundary), enumerate all self-avoiding walks of length ≤ 10, compute F(z) at the critical point x = 1/μ_hex, and verify the discrete Cauchy-Riemann equation Σ_{z ∈ ∂face} F(z)(z_out − z_in) = 0 for each face of the medial lattice. A violation on any face would disprove the conjecture (for that lattice size).

**Impact**: This would formalize the mathematical core of the Duminil-Copin–Smirnov proof that established μ_hex = √(2+√2). Discrete holomorphicity is the key technique, and its formalization would open the door to attacking other lattice problems (e.g., square lattice) by identifying the correct observable.

**Catalog References**: `Pythagorean/SubadditiveGrowth.lean` (GrowthSystem framework), `Pythagorean/NienhuisIrrationality.lean` (nienhuis_sq, nienhuis_minimal_poly)

**Proof Strategy**:
1. Define the medial lattice of a planar graph.
2. Formalize self-avoiding walks with winding angle tracking.
3. Define the parafermionic observable as a complex-valued function on medial vertices.
4. Prove the discrete Cauchy-Riemann equation using local cancellation arguments at each face.
5. Use the observable to derive the critical point equation, recovering μ_hex = √(2+√2).

**Domain Bridges**: Complex analysis ↔ Statistical mechanics ↔ Graph theory ↔ Tropical analysis

**Lineage**: Builds on the Nienhuis constant results and GrowthSystem framework. This is the "deep" direction connecting to the Duminil-Copin–Smirnov proof.

**Ambition**: grand_challenge
