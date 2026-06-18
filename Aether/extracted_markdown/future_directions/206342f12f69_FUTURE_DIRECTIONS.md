# Future Directions

## Hypothesis 1: Leading Coefficient Extraction Lemma

**Conjecture**: For any multivariate polynomial P ∈ F[X₁,...,Xₙ] of total degree d, base point x, and direction v:

    Polynomial.coeff (restrictToLine P x v) d = MvPolynomial.eval v (homogeneousComponent d P)

where restrictToLine P x v = MvPolynomial.eval₂ Polynomial.C (fun i => C(xᵢ) + X·C(vᵢ)) P.

**Test**: Verify computationally for all polynomials of degree ≤ 3 over F₃ in 2 variables by exhaustive enumeration. This can be done by comparing the coefficient of t^d in the expanded product with the evaluation of the filtered monomial sum. The identity should hold in all cases. A computer algebra system check takes < 1 second.

**Impact**: If formalized, this single lemma would close the Dvir finite-field Kakeya lower bound |K| ≥ q^n/n!, completing the first machine-verified proof of this landmark result. All other components of the proof are already formalized.

---

## Hypothesis 2: Finite-Field Extremizer Classification

**Conjecture**: For n = 2 and prime q, every minimum-size Kakeya set K ⊆ F_q² with |K| = min achievable is affinely equivalent to a set obtained by choosing one line per direction class from a fixed pencil of lines through a common point, then taking the union.

**Test**: Exhaustively enumerate minimum Kakeya sets in F_q² for q = 2, 3, 5, 7. Classify them up to affine automorphisms Aut(F_q²). Check whether all minimizers belong to a single orbit or finitely many orbits. For q = 2, the minimum is 3 out of 4 points; for q = 3, enumerate all subsets of size 7 in F_3² and classify. The computation is feasible for q ≤ 7.

**Impact**: Would reveal the algebraic structure of extremal Kakeya configurations, potentially identifying a polynomial-based construction that achieves the minimum. This would connect to the polynomial method in a new direction — not just lower bounds but optimal constructions.

---

## Hypothesis 3: Incidence Energy Threshold for Kakeya Configurations

**Conjecture**: For a family of N = (q^n - 1)/(q - 1) lines in distinct direction classes in F_q^n, with union P = ∪ℓ, the multiplicity energy E = Σ_{x ∈ P} m(x)² satisfies:

    E ≥ N · q + Ω(N² · q / |P|)

where m(x) = |{ℓ : x ∈ ℓ}|. In particular, if |P| < c·N·q for some constant c < 1, then E exceeds the "random baseline" N·q by a factor growing polynomially in N.

**Test**: Compute E for random and structured line families over F_q² for q = 3, 5, 7, 11. Compare the energy of configurations achieving near-minimal union sizes with the energy of random configurations. Plot E/N·q against |P|/N·q to identify the threshold behavior. The computation requires O(N²·q) time per configuration.

**Impact**: A proven energy threshold would provide an alternative approach to Kakeya-type lower bounds through Cauchy-Schwarz arguments, bypassing the polynomial method entirely. It would also connect Kakeya theory to additive combinatorics via the Balog-Szemerédi-Gowers framework.

---

## Hypothesis 4: Polynomial Partitioning in Finite-Field Grid Models

**Conjecture**: Given N points and N lines in F_q² with many incidences, there exists a polynomial of degree O(N^{1/3}) in two variables that partitions F_q² into cells, each containing O(N^{2/3}) points, with the total number of line-cell crossings bounded by O(N^{2/3} · degree).

**Test**: Implement degree-d polynomial partitioning for F_q² grid models: for each degree d, search for polynomials of degree d that partition the point set into cells of roughly equal size. Measure the quality of the partition (variance in cell sizes, number of boundary incidences) for random and adversarial point configurations over F_q for q = 7, 11, 13. Compare with the theoretical predictions of the Guth-Katz polynomial partitioning theorem.

**Impact**: A formalized polynomial partitioning in Lean would be a major step toward formalizing the Guth-Katz distance theorem and related incidence geometry results. It would require extending our MvPolynomial infrastructure with algebraic geometry tools (zero set decomposition, cell counting).

---

## Hypothesis 5: Entropy Formulation of the Kakeya Lower Bound

**Conjecture**: There exists an information-theoretic inequality equivalent to a weak finite-field Kakeya bound: if X is a random variable uniformly distributed on a Kakeya set K ⊆ F_q^n, and V is a uniformly random nonzero direction, and T is the unique parameter t such that X lies on the Kakeya line in direction V (i.e., X = base_V + T·V), then:

    H(X) ≥ H(V) + H(T) - O(log n)

where H denotes Shannon entropy. Since H(V) ≈ n log q and H(T) = log q, this gives H(X) ≥ (n+1) log q - O(log n), hence |K| ≥ q^{n+1} / poly(n), which is stronger than the Dvir bound for large n.

**Test**: Construct the random variables (X, V, T) explicitly for Kakeya sets over F_3², F_5², F_3³. Compute H(X), H(V), H(T), and the mutual information I(V; T | X). Verify whether the inequality H(X) ≥ H(V) + H(T) - O(log n) holds, and measure the tightness of the bound. If the inequality fails, identify the correction term and reformulate.

**Impact**: An entropy formulation would connect Kakeya theory to information theory and network coding, potentially enabling new proof techniques based on data processing inequalities. It would also provide a conceptual framework for understanding why direction diversity forces large sets.
