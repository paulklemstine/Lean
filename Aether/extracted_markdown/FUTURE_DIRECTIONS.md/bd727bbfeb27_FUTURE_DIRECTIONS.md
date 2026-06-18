# Future Directions: Falsifiable Hypotheses for Beal Obstruction Theory

This document identifies five specific, testable scientific hypotheses arising from the formally verified CRT compression theory and cubic obstruction certificates. Each hypothesis is falsifiable: it can be confirmed by proof, refuted by counterexample, or bounded by computation.

---

## Hypothesis 1: Finiteness of Cubic Obstructing Primes

**Conjecture:** The set of primes $p$ satisfying $\neg\mathrm{PRS}(p, 3, 3, 3)$ is exactly $\{2, 7, 13\}$.

**Precise statement:**
```
∀ p : ℕ, Nat.Prime p → p > 13 → PrimitiveResidueSolution p 3 3 3
```

**Test protocol:**
1. Extend the computational search to all primes $p \leq 10^6$ using the optimized power-image algorithm.
2. For primes $p \equiv 1 \pmod{3}$, compute $|C_p| = (p-1)/3$ and verify that $(C_p + C_p) \cap C_p \neq \emptyset$.
3. Attempt a proof via additive combinatorics: for $|C_p| \geq 5$ (i.e., $p \geq 16$), apply the Cauchy-Davenport theorem to bound $|C_p + C_p| \geq \min(p, 2|C_p| - 1)$. When $2(p-1)/3 - 1 > p - 1 - (p-1)/3$, the sumset is too large to avoid $C_p$.

**Refutation criterion:** A single prime $p > 13$ with $\neg\mathrm{PRS}(p, 3, 3, 3)$ refutes the conjecture.

**Impact:** If true, this completely classifies the obstruction landscape for cubes: the only obstructing moduli are those divisible by 2, 7, or 13. Combined with the CRT compression theorem, this gives a complete characterization of all obstructing moduli for $(3,3,3)$.

---

## Hypothesis 2: Cauchy-Davenport Threshold for Subgroup Sumset Avoidance

**Conjecture:** For any prime $p \equiv 1 \pmod{3}$ with $p > 13$, the cube subgroup $C_p$ of index 3 in $(\mathbb{Z}/p\mathbb{Z})^\times$ satisfies $(C_p + C_p) \cap C_p \neq \emptyset$.

**Precise statement:**
```
∀ p : ℕ, Nat.Prime p → p % 3 = 1 → p > 13 →
  ∃ a b c ∈ cube_image p, a + b ≡ c [MOD p]
```

**Test protocol:**
1. Apply the Cauchy-Davenport theorem: for $A, B \subseteq \mathbb{Z}/p\mathbb{Z}$ with $|A|, |B| \geq 1$, $|A + B| \geq \min(p, |A| + |B| - 1)$.
2. With $|C_p| = (p-1)/3$, we get $|C_p + C_p| \geq \min(p, 2(p-1)/3 - 1)$.
3. For $p \geq 19$, $2(p-1)/3 - 1 \geq 11 > (p-1)/3 + 1$, so the sumset covers more than one coset.
4. The sumset $C_p + C_p$ has $\geq 2(p-1)/3 - 1$ elements in $\mathbb{Z}/p\mathbb{Z}$ (including possibly 0), and $C_p$ has $(p-1)/3$ elements among the $p-1$ units. When $2(p-1)/3 - 1 > 2(p-1)/3$, some element of $C_p + C_p$ must lie in $C_p$ by pigeonhole.
5. Make this rigorous and formalize in Lean.

**Refutation criterion:** A counterexample prime $p > 13$ with $p \equiv 1 \pmod 3$ and empty intersection, or a flaw in the Cauchy-Davenport bound for this structured setting.

**Impact:** Proves Hypothesis 1 and gives a structural explanation for *why* only three primes obstruct cubes. This would be a theorem in additive combinatorics of multiplicative subgroups.

---

## Hypothesis 3: Uniform Local-Global Decomposition for Polynomial Predicates

**Conjecture:** For any fixed multivariate polynomial $f \in \mathbb{Z}[X_1, \ldots, X_k]$ and coprime $M, N$, the predicate "there exist units $u_1, \ldots, u_k \in (\mathbb{Z}/n\mathbb{Z})^\times$ with $f(u_1, \ldots, u_k) = 0$" decomposes as:
$$\text{Solvable mod } MN \iff \text{Solvable mod } M \wedge \text{Solvable mod } N.$$

**Precise statement:**
```
theorem polynomial_CRT_iff
    {M N : ℕ} (hcop : Nat.Coprime M N)
    (f : MvPolynomial (Fin k) ℤ) :
    (∃ u : Fin k → ZMod (M * N), (∀ i, IsUnit (u i)) ∧ MvPolynomial.eval u f = 0) ↔
    (∃ u : Fin k → ZMod M, (∀ i, IsUnit (u i)) ∧ MvPolynomial.eval u f = 0) ∧
    (∃ v : Fin k → ZMod N, (∀ i, IsUnit (v i)) ∧ MvPolynomial.eval v f = 0)
```

**Test protocol:**
1. Generalize the proof of `primitiveResidueSolution_mul_iff` from the specific polynomial $X^x + Y^y - Z^z$ to arbitrary polynomials.
2. The proof strategy should be identical: use `ZMod.chineseRemainder` to transfer the ring isomorphism, and `Prod.isUnit_iff` for the unit condition.
3. Verify the generalization compiles in Lean.

**Refutation criterion:** This should be provable by the same method. A failure would indicate a subtlety with polynomial evaluation across the CRT isomorphism (unlikely given Lean's ring hom infrastructure).

**Impact:** Transforms the CRT compression theorem from a result about specific Beal-type equations into a **universal decomposition principle** for unit-valued polynomial equations over $\mathbb{Z}/N\mathbb{Z}$. This would be the foundational theorem of "modular obstruction geometry."

---

## Hypothesis 4: Obstruction Density for Higher Exponents

**Conjecture:** For each odd prime exponent $n$, the obstructing primes for signature $(n, n, n)$ have the form $p \equiv 1 \pmod{n}$ (with the possible exception of $p = 2$), and the number of such obstructing primes is finite for each $n$.

**Precise data to collect:**

| Signature | Obstructing primes ≤ 1000 (predicted pattern) |
|-----------|-----------------------------------------------|
| (3,3,3) | 2, 7, 13 (congruent to 1 mod 3) |
| (5,5,5) | 2, 11, 41, 71, ... (congruent to 1 mod 5) |
| (7,7,7) | 2, 29, 71, ... (congruent to 1 mod 7) |

**Test protocol:**
1. For $n \in \{3, 5, 7, 11, 13\}$, compute all obstructing primes $p \leq 10{,}000$.
2. Verify that non-trivial obstructions occur only at $p \equiv 1 \pmod{n}$.
3. Check whether the count stabilizes (suggesting finiteness) or grows (suggesting infinitude).
4. For the $n$-th power subgroup of index $n$ in $(\mathbb{Z}/p\mathbb{Z})^\times$ (when $n \mid p - 1$), compute the sumset self-intersection.
5. Apply Cauchy-Davenport or Dias da Silva–Hamidoune bounds to determine the critical subgroup size beyond which avoidance is impossible.

**Refutation criterion:** Finding an obstructing prime $p \not\equiv 1 \pmod{n}$ and $p \neq 2$, or finding infinitely many obstructing primes for some $n$.

**Impact:** A complete structural theory of obstruction-by-exponent would yield a family of certified impossibility theorems, one for each Fermat exponent.

---

## Hypothesis 5: ABC + Residue Hybrid Finiteness

**Conjecture:** Under $\mathrm{IntAbcBound}(K)$ for some explicit $K$, the following program terminates and produces a proof of Beal's conjecture for all sufficiently large exponent triples:

1. Use the ABC threshold theorem to reduce to $\min(x, y, z) \leq 3K$.
2. For each remaining signature $(x, y, z)$ with $\min \leq 3K$, search for an obstructing modulus $N$.
3. If found, the obstruction proves nonexistence for primitive solutions coprime to $N$.
4. For remaining cases, apply descent or other methods.

**Test protocol (conditional on ABC):**
1. Fix $K = 2$ (a moderately strong ABC hypothesis).
2. The threshold theorem gives $\min(x, y, z) \leq 6$, leaving finitely many signatures.
3. For each signature with $\min \in \{3, 4, 5, 6\}$, search for obstructing primes up to $10^6$.
4. Catalog which signatures have obstructions and which don't.
5. For unobstructed signatures, determine whether more sophisticated local-global methods (Hensel lifting, $p$-adic analysis) can fill the gap.

**Refutation criterion:** A signature $(x, y, z)$ with $\min \leq 6$ that has no obstructing modulus at any prime power up to $10^6$. This would indicate that pure residue methods are insufficient and global techniques are necessary.

**Impact:** If the hybrid program succeeds for even one non-trivial value of $K$, it demonstrates that Beal-type impossibility theorems can be reduced to finite certified computation — a paradigm shift in the attack on these conjectures.

---

## Priority Ranking

1. **Hypothesis 2** (Cauchy-Davenport threshold) — Most likely provable with current Lean infrastructure; would immediately resolve Hypothesis 1.
2. **Hypothesis 1** (Finiteness of cubic obstructors) — Computationally verifiable up to large bounds; likely follows from Hypothesis 2.
3. **Hypothesis 3** (Polynomial CRT generalization) — Direct generalization of existing proof; mostly software engineering.
4. **Hypothesis 4** (Higher exponents) — Requires significant computational investment; pattern recognition needed.
5. **Hypothesis 5** (ABC hybrid) — Most ambitious; conditional on ABC; would be a landmark if completed.

---

## Methodology Notes

All computational experiments should be run with dual verification:
- Python implementation for exploration and pattern discovery
- Lean `native_decide` or proof-by-reflection for formal certification

The CRT compression theorem ensures that all computations can be decomposed to prime powers, making large-scale search tractable.
