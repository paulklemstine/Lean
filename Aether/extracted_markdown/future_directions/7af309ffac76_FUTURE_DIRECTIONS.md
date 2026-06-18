# Future Directions: Tropical AC Canonical Forms

## 1. Extend Canonicalization from AC to ACI (Idempotence of min)

**Hypothesis:** The tropical min operation satisfies `min(a, a) = a`. Adding idempotence quotients to the AC normalizer produces a strictly more powerful decision procedure.

**Proof Strategy:**
- Extend `normalize_ca` to deduplicate sorted children after flattening (remove adjacent duplicates in the sorted list for `tmin` nodes).
- The soundness proof extends directly since `min(a, a) = a`.
- Completeness requires defining `ACIEquiv` with an additional `tmin_idem` constructor and showing the deduplication step respects it.
- Idempotence follows from the same rebuild-sorted argument since deduplication of a deduplicated list is identity.

**Cross-Domain Connection:** Idempotent semirings arise in shortest-path algorithms (Floyd-Warshall), lattice theory, and formal language theory (regular expressions under union).

**Estimated Difficulty:** Medium. The main new ingredient is showing that deduplication commutes with sorting.

---

## 2. Integrate Distributivity via Knuth-Bendix Completion

**Hypothesis:** The tropical distributive law `a + min(b, c) = min(a + b, a + c)` can be oriented as a rewrite rule and integrated into a convergent completion procedure.

**Proof Strategy:**
- Define oriented rewrite rules for distributivity (expand or factor).
- Analyze critical pairs between AC rules and distributivity.
- Either prove confluence directly or implement a completion loop.
- The resulting normal form would canonicalize a strictly larger fragment of tropical equivalence.

**Cross-Domain Connection:** This connects to Gröbner basis theory for polynomial rings, where distributivity is handled via S-polynomial reduction. A tropical analogue would yield "tropical Gröbner bases."

**Estimated Difficulty:** Hard. Critical pair analysis for AC + distributivity is nontrivial, and termination of the oriented distributivity rule requires careful measure design.

---

## 3. Build a Reflection Tactic Using normalize_ca

**Hypothesis:** The completeness theorem `ACEquiv e₁ e₂ → normalize_ca e₁ = normalize_ca e₂` can power a proof-producing tactic that solves tropical AC goals by computation.

**Proof Strategy:**
- Define a `reify` function that converts Lean expressions involving `min` and `+` on `ℝ` into `TropExpr` terms.
- Apply `normalize_ca` to both sides.
- Use `native_decide` or `decide` (after making `ble` decidable on a computable fragment) to check syntactic equality.
- The soundness theorem provides the correctness certificate.

**Cross-Domain Connection:** This mirrors the `ring` tactic for commutative rings and the `omega` tactic for linear arithmetic. A `tropical` tactic would automate a class of min-plus identities.

**Estimated Difficulty:** Medium-Hard. The main challenge is efficient reification and handling the noncomputable aspects of ℝ (may need to restrict to ℚ or parametrize).

---

## 4. Certified Tropical Polynomial Normal Form

**Hypothesis:** Tropical polynomials (finite min-plus expressions with integer/rational coefficients and monomial structure) admit a computable canonical form that decides equivalence.

**Proof Strategy:**
- Define tropical monomials as `(coefficient, exponent vector)` pairs under the tropical semiring.
- A tropical polynomial is a finite min of monomials.
- Canonical form: sorted list of monomials with dominated monomials removed.
- Prove that two tropical polynomials are semantically equal iff their canonical forms are equal (this is the tropical analogue of the Fundamental Theorem of Algebra for polynomials).

**Cross-Domain Connection:** Tropical polynomials define piecewise-linear functions, which are the building blocks of ReLU neural networks. Canonical forms for tropical polynomials would enable certified neural network simplification.

**Estimated Difficulty:** Hard. The dominance elimination step requires geometric arguments about tropical hypersurfaces.

---

## 5. Connect Canonical Tropical Syntax to Shortest-Path Circuit Extraction

**Hypothesis:** The AC canonical form for tropical expressions directly corresponds to an optimized circuit representation for shortest-path computations, enabling certified common-subexpression elimination.

**Proof Strategy:**
- Model shortest-path computations as tropical matrix expressions.
- Show that AC normalization identifies and merges redundant sub-computations.
- Prove that the canonical form minimizes the number of distinct subexpressions (up to AC equivalence).
- Connect to tropical circuit complexity lower bounds.

**Cross-Domain Connection:** This bridges formal verification of algorithms with tropical algebra, potentially enabling certified optimizers for dynamic programming and network routing.

**Estimated Difficulty:** Medium. The circuit extraction is conceptually straightforward; the minimality proof is the main challenge.
