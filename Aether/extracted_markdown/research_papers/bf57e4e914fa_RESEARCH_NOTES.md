# Research Notes: Pythagorean Computation Formalization

## Oracle Team Structure

### Oracle Alpha — Historical & Foundational Research
**Assignment:** Survey the mathematical foundations from Babylonian mathematics to modern formalization.

**Key Findings:**
- Plimpton 322 (c. 1800 BCE) contains 15 Pythagorean triples, suggesting Babylonian knowledge of the parametrization
- Euclid's Elements Book X provides the first systematic treatment
- Berggren (1934) discovered the ternary tree structure; independently found by Barning (1963) and Hall (1970)
- The connection to Lorentz geometry was noted by Apóstol (1986) and developed by numerous authors

### Oracle Beta — Algebraic Structure
**Assignment:** Investigate the algebraic underpinnings: why do the Berggren matrices work?

**Key Findings:**
1. The Berggren matrices preserve the Lorentz form Q(a,b,c) = a² + b² − c²
2. This means they are elements of O(2,1;ℤ), the integer Lorentz group
3. The 2×2 reductions M₁, M₂, M₃ act on Euclid parameters (m,n)
4. M₁ and M₃ generate the theta group Γ_θ, an index-3 subgroup of SL(2,ℤ)
5. **Verified in Lean:** `berggren_A_lorentz`, `berggren_B_lorentz`, `berggren_C_lorentz`

### Oracle Gamma — Computational Experiments
**Assignment:** Enumerate, count, and analyze the distribution of primitive triples.

**Experimental Results:**
| N     | Count | N/(2π) | Ratio  |
|-------|-------|--------|--------|
| 100   | 16    | 15.9   | 1.005  |
| 500   | 80    | 79.6   | 1.005  |
| 1000  | 158   | 159.2  | 0.993  |
| 5000  | 792   | 795.8  | 0.995  |
| 10000 | 1593  | 1591.5 | 1.001  |

**Conclusion:** The asymptotic formula #{primitive triples with c ≤ N} ~ N/(2π) is confirmed computationally with ratio converging to 1.

### Oracle Delta — Number-Theoretic Properties
**Assignment:** Investigate divisibility and parity constraints.

**Verified Theorems (all machine-checked in Lean 4):**
1. **Even leg:** In any Pythagorean triple, at least one of a, b is even (`pyth_even_leg`)
2. **Divisibility by 3:** In any Pythagorean triple, 3 | a or 3 | b (`pyth_div_by_3`)
3. **Divisibility by 5:** In any Pythagorean triple, 5 | a or 5 | b or 5 | c (`pyth_div_by_5`)
4. **Product divisibility:** The product abc is always divisible by 60

**Proof technique:** All three proofs use modular arithmetic case analysis. For example, squares mod 3 are {0, 1}, so if neither a nor b is divisible by 3, then a² + b² ≡ 2 (mod 3), but c² ≡ 0 or 1 (mod 3), contradiction.

### Oracle Epsilon — The Factoring Connection
**Assignment:** Formalize how Pythagorean triples relate to integer factoring.

**Key Result:** For an odd composite n, the number of Pythagorean triples with leg n reveals factors of n. Specifically:
- If n is prime, there is exactly one triple: (n, (n²−1)/2, (n²+1)/2)
- If n is composite, additional triples expose non-trivial factors via GCD

**Verified:** `prime_unique_triple`, `composite_multiple_triples` in `PythagoreanFactoring.lean`

### Oracle Zeta — Pairing Theory
**Assignment:** Develop the theory of "paired" Pythagorean triples sharing a hypotenuse.

**Key Result:** The Brahmagupta–Fibonacci identity (a²+b²)(c²+d²) = (ac−bd)²+(ad+bc)² = (ac+bd)²+(ad−bc)² gives two sum-of-squares representations of any composite hypotenuse, yielding paired triples. The GCD of the cross-terms factors the hypotenuse.

**Examples verified computationally:**
- c = 65 = 5×13: triples (33,56,65) and (63,16,65), factor = gcd(60,65) = 5
- c = 85 = 5×17: triples (13,84,85) and (77,36,85), factor = gcd(75,85) = 5
- c = 221 = 13×17: triples (21,220,221) and (171,140,221), factor = gcd(204,221) = 17

---

## Hypothesis → Experiment → Validation Cycle

### Iteration 1: Core Identity
- **Hypothesis:** The Pythagorean equation is equivalent to a difference-of-squares factorization.
- **Experiment:** State and prove `pyth_fundamental_identity`.
- **Result:** ✅ Proved by `nlinarith`. Both directions verified.

### Iteration 2: Berggren Preservation
- **Hypothesis:** All three Berggren transforms preserve Q(a,b,c) = 0, not just Q itself.
- **Experiment:** Prove `berggren_A_lorentz`, `berggren_B_lorentz`, `berggren_C_lorentz`.
- **Result:** ✅ All three proved by `ring` (they are polynomial identities, independent of the triple being Pythagorean).

### Iteration 3: Parity Constraints
- **Hypothesis:** Every Pythagorean triple has 3|a or 3|b, and 5|a or 5|b or 5|c.
- **Experiment:** Prove `pyth_div_by_3` and `pyth_div_by_5`.
- **Result:** ✅ Proved by exhaustive case analysis on residues mod 3 (resp. mod 5), using `interval_cases` in Lean.

### Iteration 4: Counting Asymptotics
- **Hypothesis:** The count of primitive triples with c ≤ N is approximately N/(2π).
- **Experiment:** Compute for N = 100, 500, 1000, 5000, 10000.
- **Result:** ✅ Ratio converges to 1.00, confirming the Lehmer (1900) asymptotic formula.

### Iteration 5: Factoring via Triples
- **Hypothesis:** An odd prime has exactly one Pythagorean triple as a leg.
- **Experiment:** Prove `prime_unique_triple`.
- **Result:** ✅ Proved by analyzing divisors of p² (only 1 and p² form a valid pair).

---

## File Inventory

| File | Contents | Status |
|------|----------|--------|
| `PythagoreanComputation.lean` | Core formalization: identities, Berggren tree, parity, Lorentz | ✅ No sorries |
| `PythagoreanTriples.lean` | Basic triples, Euclid's formula, Berggren preservation | ✅ Builds |
| `BerggrenTree.lean` | Tree structure, path-based enumeration | ✅ Builds |
| `Berggren.lean` | 3×3 and 2×2 matrices, determinants, Lorentz form | ✅ Builds |
| `PythagoreanFactoring.lean` | Factoring connection, primality characterization | ✅ Builds |
| `PythagoreanPairing.lean` | Paired triples, Brahmagupta–Fibonacci, Gaussian integers | ✅ Builds |
| `TeamResearch.lean` | Cross-team results: Pauli, Hopf, quaternions, octonions | ✅ Builds |
| `demos/pythagorean_demo.py` | Interactive computational demos | ✅ Runs |
| `demos/pythagorean_visuals.py` | SVG visualization generator | ✅ Generates 5 figures |

---

## Key Axioms Used

All proofs depend only on the standard Lean 4 axioms:
- `propext` (propositional extensionality)
- `Classical.choice` (classical logic)
- `Quot.sound` (quotient soundness)

No `sorry`, no custom axioms, no `@[implemented_by]`.
