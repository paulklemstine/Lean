# Future Directions: From Difference Set Gram Identities to a Certified Design-Operator Correspondence

This document identifies five falsifiable scientific hypotheses arising from the certified theorem that difference sets satisfying $v = 4(k - \lambda)$ produce Hadamard matrices. Each hypothesis is specific enough to fail and bold enough to matter.

---

## Hypothesis A: Symmetric-Design Orthogonality Criterion

**Conjecture:** Every symmetric balanced incomplete block design (BIBD) with parameters $(v, k, \lambda)$ satisfying $v = 4(k - \lambda)$ yields a Hadamard matrix through the sign-matrix construction, independent of whether the design arises from a group difference set.

**Precise statement:** Let $\mathcal{B} = (X, \mathcal{D})$ be a symmetric $(v, k, \lambda)$-BIBD (i.e., $|\mathcal{D}| = v$ and the incidence matrix $B$ satisfies $B B^\top = (k - \lambda) I + \lambda J$). Define the sign matrix $A = 2B - J$. If $v = 4(k - \lambda)$, then $A A^\top = v I$.

**Test:** Formalize the theorem `symmetric_BIBD_hadamard_of_v_eq_four_mul_k_sub_lam` using an abstract BIBD incidence structure (no group required). The proof should follow from the matrix identity $(2B - J)(2B - J)^\top = 4BB^\top - 4kJ + vJ$ and the BIBD Gram relation $BB^\top = (k-\lambda)I + \lambda J$.

**Pass/fail criterion:** The theorem compiles without sorry in Lean 4 with only standard axioms.

**Impact:** This would decouple the Hadamard construction from group theory entirely, opening it to designs constructed by non-algebraic methods (e.g., geometric, recursive, or randomized constructions). It would subsume the current theorem as a special case, since every difference set design is a symmetric BIBD.

---

## Hypothesis B: Paley–Menon Unification

**Conjecture:** The Paley construction (quadratic residues mod $p$ for $p \equiv 3 \pmod{4}$) and Menon constructions both produce Hadamard matrices as instances of the single abstract criterion $v = 4(k - \lambda)$, applied to difference sets in different groups.

**Precise statement:** For $p \equiv 3 \pmod{4}$ prime, the set of quadratic residues $Q_p = \{x^2 : x \in \mathbb{F}_p^\times\}$ is a $(p, (p-1)/2, (p-3)/4)$-difference set in $(\mathbb{Z}/p\mathbb{Z}, +)$. The "augmented" Paley matrix of order $p + 1$ is Hadamard if and only if $p + 1 = 4((p-1)/2 - (p-3)/4)$, which simplifies to $p + 1 = 4 \cdot (p+1)/4$, always true. Furthermore, this can be derived from `differenceSet_hadamard_of_v_eq_four_mul_k_sub_lam` applied to an appropriately extended difference set in an augmented group.

**Test:**
1. Certify that $Q_p$ is a $((p, (p-1)/2, (p-3)/4))$-difference set for $p = 7, 11, 23$.
2. Verify the parameter criterion $p + 1 = 4 \cdot ((p-1)/2 - (p-3)/4)$ for all $p \equiv 3 \pmod 4$.
3. Refactor both the Menon and Paley proofs to terminate in the same `differenceSet_hadamard_of_v_eq_four_mul_k_sub_lam` lemma.

**Pass/fail criterion:** Both families derive their Hadamard property from one shared abstract lemma, with no case-specific matrix calculation.

**Impact:** This would establish that the distinction between "Paley Hadamard" and "Menon Hadamard" is an artifact of the construction method, not the underlying mathematics. The true invariant is the parameter relation, not the algebraic origin.

---

## Hypothesis C: Conference-Matrix Frontier

**Conjecture:** When the off-diagonal coefficient $v - 4(k - \lambda)$ of the sign-matrix Gram identity is $\pm 1$, the sign matrix is a *conference matrix* (a $\{0, \pm 1\}$-matrix $C$ with zero diagonal satisfying $CC^\top = (v-1)I$), up to diagonal modification.

**Precise statement:** If $D$ is a $(v, k, \lambda)$-difference set with $v - 4(k - \lambda) = -1$, then the matrix $A' = A - I$ (where $A$ is the sign matrix and $I$ the identity) satisfies $A' (A')^\top = (v-1) I$.

**Test:**
1. Compute $v - 4(k-\lambda)$ for the Singer $(7, 3, 1)$-difference set: $7 - 4 \cdot 2 = -1$. ✓ (candidate)
2. Construct $A' = A - I$ for this case and verify $A'(A')^\top = 6I$.
3. Formalize a general `differenceSet_conference_of_v_eq_four_mul_k_sub_lam_minus_one` theorem.

**Pass/fail criterion:** A formal theorem producing certified conference matrices from difference sets with $v - 4(k - \lambda) = \pm 1$, verified for at least one non-trivial example.

**Impact:** This would extend the "design compiler" paradigm to a second important class of structured matrices, demonstrating that the Gram identity is not merely a Hadamard theorem but a general matrix synthesis tool.

---

## Hypothesis D: Projective-Plane Extraction from Singer Data

**Conjecture:** The incidence matrix of a $(q^2 + q + 1, q + 1, 1)$-Singer difference set directly certifies a finite projective plane of order $q$, i.e., every pair of distinct "points" (group elements) is contained in exactly one "line" (translate of $D$).

**Precise statement:** Let $D$ be a $(q^2+q+1, q+1, 1)$-difference set in a cyclic group $G$. Define "lines" as the $v$ translates $\{gD : g \in G\}$. Then:
1. Every line has exactly $q+1$ points.
2. Every pair of distinct points lies on exactly 1 line.
3. There exist 4 points, no 3 collinear.

These are the axioms of a projective plane of order $q$.

**Test:** For the Singer $(7, 3, 1)$-difference set $D = \{0, 1, 3\}$ in $\mathbb{Z}/7\mathbb{Z}$:
1. Certify all 7 translates: $\{0,1,3\}, \{1,2,4\}, \{2,3,5\}, \{3,4,6\}, \{4,5,0\}, \{5,6,1\}, \{6,0,2\}$.
2. Verify axioms (1)-(3).
3. Formalize `IsFanoPlane (singerTranslates D)` from `IsDifferenceSet D 7 3 1`.

**Pass/fail criterion:** The Fano plane axioms are derived formally from `IsDifferenceSet D 7 3 1` in Lean 4.

**Impact:** This would demonstrate that the difference set infrastructure can certify not just matrices but entire geometric structures, opening a pathway from number-theoretic data to certified finite geometry.

---

## Hypothesis E: Character-Theoretic Automation over Finite Fields

**Conjecture:** A formally certified character-sum API over $\mathrm{GF}(q)$ for prime powers $q$ can automatically generate difference sets whose Gram identities produce strongly regular graphs and Hadamard matrices, reducing construction to pure computation.

**Precise statement:** For $q$ a prime power with $q \equiv 3 \pmod{4}$, the quadratic character $\chi : \mathrm{GF}(q)^\times \to \{+1, -1\}$ defines a difference set $D = \{x \in \mathrm{GF}(q)^\times : \chi(x) = 1\}$ with parameters $(q, (q-1)/2, (q-3)/4)$. A certified implementation of $\chi$ for $\mathrm{GF}(q)$ with $q = p^n$ (not just primes) enables:
1. Automatic difference set certification: `instance : IsDifferenceSet (quadraticResidues (GF q)) q ((q-1)/2) ((q-3)/4)`
2. Automatic Hadamard matrix synthesis via `differenceSet_hadamard_of_v_eq_four_mul_k_sub_lam`.

**Test:**
1. Implement the quadratic character for $\mathrm{GF}(9) = \mathbb{F}_3[x]/(x^2 + 1)$.
2. Extract the quadratic residue difference set in $\mathrm{GF}(9)^+ \cong \mathbb{Z}/3\mathbb{Z} \times \mathbb{Z}/3\mathbb{Z}$.
3. Verify parameters $(9, 4, 1)$ and note $9 \neq 4(4-1) = 12$ (not Hadamard).
4. For $\mathrm{GF}(11)$: verify $(11, 5, 2)$ and $11 \neq 4 \cdot 3 = 12$ (not Hadamard, but conference candidate since $11 - 12 = -1$).

**Pass/fail criterion:** A certified quadratic character over at least one non-prime finite field, producing a verified difference set. If the field has $q \equiv 3 \pmod 4$, the Gram identity should be automatically instantiated.

**Impact:** This would close the loop between number theory and matrix synthesis: finite field arithmetic → character sums → difference sets → Gram identity → structured matrices. It represents the first step toward a fully automated "combinatorial design synthesizer" backed by formal proofs.

---

## Priority Ordering

1. **Hypothesis A** (BIBD generalization) — Highest impact, most direct extension of current work.
2. **Hypothesis C** (Conference matrices) — Most concrete and testable, with a known candidate.
3. **Hypothesis B** (Paley-Menon unification) — Architecturally important but requires quadratic residue infrastructure.
4. **Hypothesis D** (Projective planes) — Beautiful but requires geometric axiom formalization.
5. **Hypothesis E** (Character theory) — Most ambitious, requires substantial finite field API work.

---

## Timeline Estimate

- **Hypothesis A:** 1-2 weeks (matrix algebra over abstract incidence matrices)
- **Hypothesis C:** 1-2 weeks (concrete computation + small formal extension)
- **Hypothesis B:** 2-4 weeks (requires `legendreSym` / quadratic residue API)
- **Hypothesis D:** 3-5 weeks (projective plane axioms + incidence geometry)
- **Hypothesis E:** 4-8 weeks (finite field character API + automation layer)
