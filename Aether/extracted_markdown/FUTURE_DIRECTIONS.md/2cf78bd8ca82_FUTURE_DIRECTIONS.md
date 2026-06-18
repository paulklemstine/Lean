# Future Directions: Certified Hadamard–Design Factory

## Hypothesis 1: Paley Type II Formalization

**Conjecture:** For every prime power *q* ≡ 1 (mod 4), the Paley Type II construction yields a certified Hadamard matrix of order 2(*q* + 1) in Lean 4. Specifically, the doubled block matrix
$$H = \begin{pmatrix} Q + I & Q - I \\ Q - I & -(Q + I) \end{pmatrix}$$
satisfies *H* · *Hᵀ* = 2(*q* + 1) · *I*, where *Q* is the Jacobsthal matrix over 𝔽_q.

**Test:** Formalize the case *q* = 5 (giving order 12) and *q* = 9 (giving order 20) using `GaloisField` in Mathlib. The *q* = 9 case is the critical test since it requires working with a non-prime finite field.

**Impact:** If true, this doubles the density of certified Hadamard orders from the Paley family alone. Combined with Kronecker closure, it would push coverage of multiples of 4 above 85% up to order 10,000.

**Key obstacles:** Mathlib's `GaloisField` API may lack the quadratic character and Jacobi sum infrastructure currently available for `ZMod p`. Quantify the gap: how many lemmas need porting?

---

## Hypothesis 2: Difference Set Generalization

**Conjecture:** The formal machinery built for quadratic residues extends to a generic theorem: if *D* ⊂ *G* is a (*v*, *k*, *λ*)-difference set in an abelian group *G* of order *v*, then the ±1 incidence matrix *A* defined by *A_{g,h}* = 1 if *g* − *h* ∈ *D* and −1 otherwise satisfies *A* · *Aᵀ* = (*k* − *λ*) · *I* + *λ* · *J*.

**Test:** 
1. Instantiate on the Paley residue set (quadratic residues in 𝔽_p for *p* ≡ 3 mod 4) and verify it recovers the Jacobsthal Gram identity.
2. Instantiate on the Singer difference set in ℤ/7ℤ, *D* = {1, 2, 4} (a (7, 3, 1)-difference set), and verify the corresponding matrix identity.
3. Identify whether the proof of the generic theorem requires any character-theoretic input or is purely combinatorial.

**Impact:** A generic difference set → matrix identity theorem would be a reusable foundation for formalizing projective planes (Singer), Menon–Hadamard difference sets, and McFarland constructions. It would transform the Paley formalization from a one-off result into a platform.

---

## Hypothesis 3: Strongly Regular Graph Extraction

**Conjecture:** The Paley Jacobsthal matrix canonically yields a formally certified strongly regular graph (or tournament) package. Specifically, for *p* ≡ 3 (mod 4), the adjacency matrix of the Paley tournament satisfies the eigenvalue relations expected of a doubly regular tournament with parameters (*p*, (*p*−1)/2, (*p*−5)/4, (*p*−1)/4).

**Test:**
1. Define the Paley tournament adjacency matrix *A_{ij}* = (1 + Q_{ij})/2 with diagonal 0.
2. Derive the regularity: every vertex has out-degree (*p*−1)/2.
3. Verify the quadratic eigenvalue equation *A²* = ((*p*−1)/4) · *J* + ((*p*−1)/4) · *A* + ((*p*+1)/4) · (*I* − *A*) for *p* = 7, 11, 19.
4. Prove the general eigenvalue relation formally.

**Impact:** Provides a machine-verified source of strongly regular graphs/tournaments for spectral graph theory. The Paley graph for *p* ≡ 1 (mod 4) is one of the most-studied strongly regular graphs; the tournament version is its oriented analogue.

**Falsification criterion:** If the eigenvalue relation fails for any test prime, the tournament parametrization is incorrect and needs revision.

---

## Hypothesis 4: Density of Certified Hadamard Orders

**Conjecture:** Sylvester + Paley Type I + Paley Type II + Kronecker closure certify at least 85% of all multiples of 4 up to 10,000, and at least 80% up to 100,000.

**Test:**
1. Compute exact coverage using the Paley Type I pipeline only (primes *p* ≡ 3 mod 4), Sylvester (powers of 2), and Kronecker products. Our current computation shows ~81% at bound 10,000.
2. Add Paley Type II (primes and prime powers *q* ≡ 1 mod 4) and recompute.
3. Identify the "hardest" uncovered orders: those that require constructions beyond Sylvester + Paley + Kronecker.
4. Compare the coverage density against the lower bound predicted by the prime number theorem applied to both Paley families.

**Numerical predictions to validate:**
- Paley I alone: ~50 certified orders per 500 (from prime density)
- Paley I + II: ~75 certified orders per 500
- After Kronecker: 80%+ of multiples of 4

**Impact:** Quantifies the gap between the "easy" certified orders and the full Hadamard conjecture. Identifies specific target orders (e.g., 668, the smallest open case) that require fundamentally new methods.

---

## Hypothesis 5: Finite Harmonic Analysis Generalization

**Conjecture:** The quadratic character correlation lemma (∑ χ(t)χ(t+a) = −1 for *a* ≠ 0) generalizes to arbitrary nontrivial multiplicative characters of order *d* > 2 over finite fields, in the form:
$$\sum_{t \in \mathbb{F}_q} \chi(t) \cdot \overline{\chi(t+a)} = -1 \quad \text{for } a \neq 0$$
where χ has order *d* | (*q* − 1) and *d* > 1.

**Test:**
1. Verify computationally for cubic characters (order 3) over 𝔽_7 and 𝔽_13.
2. Determine whether the identity holds with the same constant (−1) or whether the value depends on the character order *d*.
3. If the generalization holds, formalize it using Mathlib's `MulChar` API and derive the quadratic case as a corollary.

**Falsification criterion:** If ∑ χ(t)·χ̄(t+a) ≠ −1 for some cubic character and nonzero *a*, the conjecture is false in its stated form. Determine the correct generalization (likely involving Jacobi sums of higher order).

**Impact:** A general correlation identity for multiplicative characters would enable:
- Conference matrices from higher-order characters
- Generalized Paley constructions (Type III, IV, etc.)
- Connections to Weil's theorem on exponential sums over finite fields
- Formal verification of the Hasse–Davenport relation

---

## Priority Ordering

1. **Hypothesis 4** (Density): Purely computational, immediately testable, provides quantitative guidance for all other directions.
2. **Hypothesis 2** (Difference sets): Moderate formalization effort, high reuse value, directly extends the current codebase.
3. **Hypothesis 1** (Paley Type II): Significant formalization effort but well-understood mathematics; the main risk is Mathlib API gaps for non-prime finite fields.
4. **Hypothesis 3** (SRG extraction): Moderate effort, connects to graph theory applications.
5. **Hypothesis 5** (Harmonic analysis): Highest mathematical depth, most likely to fail in its stated form, but most transformative if successful.

---

## Success Metrics

A direction is considered **confirmed** if:
- The Lean formalization compiles without sorry
- The axiom trace shows only standard axioms
- At least one non-trivial instantiation is verified

A direction is considered **refuted** if:
- A concrete counterexample is produced (computationally or formally)
- The counterexample is documented with an explanation of why the hypothesis fails

A direction is considered **blocked** if:
- The required Mathlib infrastructure is identified but absent
- The gap is precisely characterized (specific missing lemmas listed)
- A workaround is proposed but estimated to exceed the scope of a single cycle
