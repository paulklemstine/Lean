# Future Research Directions

## Synthesis

This research cycle established the precise algebraic equivalence between the MDS (Maximum Distance Separable) property of matrices and the strongest form of the discrete uncertainty principle. We formally proved, with machine-verified Lean 4 proofs, that a square matrix M over a field satisfies |supp(f)| + |supp(Mf)| ≥ n + 1 for every nonzero f if and only if every square submatrix of M has nonzero determinant. This result unifies three previously separate domains: Fourier uncertainty from harmonic analysis, the Singleton bound from coding theory, and submatrix invertibility from linear algebra.

The most promising cross-domain connection is the chain from the polynomial root bound (already formalized in `Algebra/RootBound.lean`) through Vandermonde MDS to the uncertainty principle (formalized in `Algebra/MDSUncertainty.lean`), and further to the existing Fourier uncertainty principle (`Algebra/FourierAnalysis/Theorems.lean`). The Catalog now has three formally verified links in this chain; the missing link — proving that specific constructions (Vandermonde, DFT) are MDS — is the highest-priority next step because it would connect all existing results into a single unified proof pipeline.

The MDS conjecture from finite geometry offers the richest vein for future work: it constrains how large MDS matrices can be over finite fields, which translates (via our equivalence) into fundamental limits on uncertainty principles in discrete settings. Resolving even partial cases would have implications across coding theory, combinatorics, and harmonic analysis.

---

### Direction 1: Vandermonde Matrices Are MDS

**Conjecture**: Over a field F of characteristic 0, the n×n Vandermonde matrix V_{ij} = α_i^j with distinct nonzero evaluation points α_0, ..., α_{n-1} is MDS. That is, every square submatrix of V has nonzero determinant.

**Test**: (a) Verify computationally for specific small cases (n ≤ 6, rational evaluation points). (b) Attempt to prove using the Schur polynomial representation of generalized Vandermonde determinants. (c) Check whether the result extends to positive characteristic with sufficiently large fields.

**Impact**: This would close the logical gap between the polynomial root bound (already formalized) and the MDS-uncertainty equivalence (proved this cycle). Combined with the existing Fourier uncertainty theorem, it would give a complete formal chain: root bound → Vandermonde MDS → DFT MDS → Fourier uncertainty. This would be the first fully machine-verified proof of the polynomial-algebraic origin of Fourier uncertainty.

**Catalog References**: `Algebra/RootBound.lean` (root bound), `Algebra/MDSUncertainty.lean` (MDS-uncertainty equivalence), `Algebra/FourierAnalysis/Theorems.lean` (Fourier uncertainty)

**Proof Strategy**: 
1. Define the Vandermonde matrix as `fun i j : Fin n => α (i) ^ (j : ℕ)` for a function `α : Fin n → F`.
2. Prove that a generalized Vandermonde determinant (selecting rows I and columns J with |I| = |J| = k) factors as `(∏_{i ∈ I} α_i^{min J}) · s_λ(α_{i₁}, ..., α_{iₖ}) · ∏_{a < b} (α_{iₐ} - α_{iᵦ})` where s_λ is a Schur polynomial.
3. Show that Schur polynomials with distinct positive arguments are nonzero (in characteristic 0).
4. Alternatively, use the Cauchy-Binet formula to relate Vandermonde submatrix determinants to minors of a related matrix.

**Domain Bridges**: Algebraic geometry (Schur polynomials, symmetric functions) ↔ Coding theory (Reed-Solomon MDS) ↔ Harmonic analysis (DFT uncertainty)

**Lineage**: Builds on the MDS-uncertainty equivalence from this cycle and the root bound from `Algebra/RootBound.lean`.

**Ambition**: extension

---

### Direction 2: The MDS Conjecture over Finite Fields

**Conjecture** (Segre, 1955): Over a finite field F_q with q elements, an MDS matrix of size n × n can exist only if n ≤ q + 1 (with the exception that n ≤ q + 2 is possible when q is even and n = q + 2 corresponds to a hyperoval).

**Test**: (a) Enumerate all n×n matrices over F_q for small q and n to find the maximum n for which MDS matrices exist. (b) Formalize the known proof for the case q prime (Ball, 2012). (c) Attempt to formalize the connection between MDS codes and arcs in projective geometry.

**Impact**: This is one of the central open problems in combinatorial coding theory. Via our MDS-uncertainty equivalence, it translates into: *the strongest additive uncertainty |supp(f)| + |supp(Mf)| ≥ n + 1 can be achieved over F_q only for n ≤ q + 1.* A formal proof (even of partial cases) would be a significant contribution to both coding theory and the formal mathematics community.

**Catalog References**: `Algebra/MDSUncertainty.lean` (MDS definition and characterization), `Algebra/RootBound.lean` (polynomial root bound over finite fields)

**Proof Strategy**: 
1. For the prime case (Ball's proof), the key tool is the polynomial method: represent the dual code as evaluations of polynomials, then use the Hasse derivative and the root bound to constrain the code parameters.
2. For the general case, connect to the theory of arcs in PG(k-1, q) — sets of points in projective space where no k+1 lie in a hyperplane.
3. Formalize the Singleton bound as a theorem about linear codes: minimum distance d ≤ n - k + 1 for a [n, k, d] code.

**Domain Bridges**: Finite geometry (arcs, projective planes) ↔ Coding theory (MDS codes, Singleton bound) ↔ Combinatorics (polynomial method)

**Lineage**: Extends the MDS definition and properties from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Entropic Uncertainty Principles

**Conjecture**: For an MDS matrix M ∈ F_q^{n×n}, the Shannon entropy H(f) + H(Mf) ≥ log(n + 1) for every nonzero probability vector f (appropriately normalized). More precisely, the Rényi entropy version H_α(f) + H_β(Mf) ≥ C(α, β, n) for conjugate exponents should yield a tight bound that reduces to the support bound in the limit α, β → 0.

**Test**: (a) Compute the entropy bound numerically for small MDS matrices (DFT matrices of prime order 5, 7, 11). (b) Compare with the Maassen-Uffink bound from quantum information. (c) Check whether the MDS property is sufficient for the entropic bound, or whether additional structure is needed.

**Impact**: Entropic uncertainty principles are central to quantum key distribution (QKD) security proofs and quantum information theory. Connecting MDS matrices to entropic bounds would bridge discrete algebra to quantum cryptography. If the conjecture holds, it would show that MDS matrices are optimal not just for support uncertainty but for information-theoretic uncertainty.

**Catalog References**: `Algebra/MDSUncertainty.lean` (MDS-support uncertainty), `Algebra/FourierAnalysis/Theorems.lean` (Parseval identity, which relates to L² norms and hence to entropy)

**Proof Strategy**:
1. Define Shannon and Rényi entropies for vectors over finite fields (treating |f(i)|² / ‖f‖² as a probability distribution).
2. Relate the support bound to the 0-Rényi entropy (which equals log of support size).
3. Use log-concavity or majorization arguments to interpolate between support bounds and L² bounds (Parseval).
4. For the MDS case, exploit the fact that MDS matrices maximize "spreading" to get tight entropic bounds.

**Domain Bridges**: Quantum information (entropic uncertainty, QKD) ↔ Coding theory (MDS codes) ↔ Information theory (entropy, channel capacity)

**Lineage**: Extends the MDS-uncertainty equivalence by moving from support size to entropy.

**Ambition**: grand_challenge

---

### Direction 4: MDS Matrices from Algebraic Curves

**Conjecture**: The evaluation matrix of the space of global sections of a line bundle of degree d on a smooth projective curve of genus g over F_q, evaluated at n rational points, is MDS if and only if n ≤ d - 2g + 2 (the Goppa bound). This connects the MDS property to the Riemann-Roch theorem.

**Test**: (a) Verify for elliptic curves (g = 1) over small finite fields. (b) Check whether the Goppa codes from Hermitian curves achieve MDS for the predicted parameters. (c) Formalize the connection between the Riemann-Roch theorem and the minimum distance of algebraic geometry codes.

**Impact**: This would provide a rich family of MDS matrix constructions beyond Vandermonde/Reed-Solomon, and connect the MDS-uncertainty framework to algebraic geometry. It would also explain why the MDS conjecture has the form n ≤ q + 1: this is the Hasse-Weil bound for rational points on curves of genus 0 (i.e., the projective line, which gives Reed-Solomon codes).

**Catalog References**: `Algebra/MDSUncertainty.lean`, `Algebra/RootBound.lean`

**Proof Strategy**:
1. Define algebraic geometry codes (Goppa codes) as evaluation codes from line bundles.
2. Use the Riemann-Roch theorem to compute the dimension of the code.
3. Apply the Goppa bound (minimum distance ≥ n - d) to establish MDS for appropriate parameters.
4. Connect back to the MDS-uncertainty equivalence.

**Domain Bridges**: Algebraic geometry (curves, line bundles, Riemann-Roch) ↔ Coding theory (Goppa codes) ↔ Harmonic analysis (uncertainty on algebraic curves)

**Lineage**: Extends the MDS framework to algebraic geometry codes.

**Ambition**: extension

---

### Direction 5: Multiplicative vs. Additive Uncertainty Gap

**Conjecture**: For an n×n matrix M over a field F, define the multiplicative uncertainty ratio ρ(M) = min_{f≠0} |supp(f)| · |supp(Mf)| / n and the additive uncertainty gap δ(M) = min_{f≠0} (|supp(f)| + |supp(Mf)|) - 1. Then ρ(M) ≥ (δ(M)/n)² (a "reverse AM-GM" for uncertainty), and this bound is tight for certain MDS matrices.

**Test**: (a) Compute ρ(M) and δ(M) for all n×n matrices over F_2, F_3 for n ≤ 5. (b) Find the extremal matrices that minimize ρ for a given δ (or vice versa). (c) Check whether the conjectured inequality holds and whether it is tight.

**Impact**: The existing Fourier uncertainty theorem (`uncertainty_principle_finite_abelian`) gives the multiplicative bound, while our new result gives the additive bound. Understanding the gap between them would clarify when each form is more informative, with applications to compressed sensing (where additive bounds give better recovery guarantees) and coding theory (where multiplicative bounds relate to list-decoding capacity).

**Catalog References**: `Algebra/MDSUncertainty.lean` (additive uncertainty), `Algebra/FourierAnalysis/Theorems.lean` (multiplicative uncertainty)

**Proof Strategy**:
1. Formalize the AM-GM inequality for support sizes: |supp(f)| + |supp(Mf)| ≥ 2√(|supp(f)| · |supp(Mf)|).
2. Show this implies ρ ≥ ((δ+1)/2n)² as a direct consequence.
3. Construct extremal examples showing tightness (e.g., using circulant matrices or DFT matrices).

**Domain Bridges**: Harmonic analysis (Fourier uncertainty) ↔ Compressed sensing (RIP, sparse recovery) ↔ Coding theory (list decoding)

**Lineage**: Directly connects the multiplicative bound (existing) with the additive bound (this cycle).

**Ambition**: extension
