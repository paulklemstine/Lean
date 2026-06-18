# Future Directions: Tropical AC Canonical Forms

## 1. Extend Canonicalization to ACI (AC + Idempotence of min)

**Hypothesis:** The `min` operation is idempotent (`min a a = a`), creating semantic equalities not captured by AC alone. A canonicalization procedure that also quotients by idempotence would handle a strictly larger fragment.

**Proof Strategy:**
- Replace multiset-based children lists with *sets* (deduplicated sorted lists) for `tmin` nodes.
- After flattening and sorting, remove duplicates from `tmin` children.
- Prove that this extended normalizer is sound and complete for the ACI congruence.
- The key difficulty: idempotence interacts nontrivially with nested `add` subterms.

**Cross-Domain Connections:** ACI normalization connects to lattice theory (min as meet) and to BDD/ZDD construction in Boolean function manipulation, where idempotent operations are canonicalized via hash-consing.

---

## 2. Integrate Distributivity via Knuth–Bendix Completion

**Hypothesis:** The full equational theory of `(ℝ, min, +)` includes distributivity `a + min(b, c) = min(a+b, a+c)`. A completion-based approach can extend the AC normalizer to handle this identity.

**Proof Strategy:**
- Define oriented rewrite rules for distributivity (e.g., always distribute `+` over `min`).
- Prove termination using a suitable measure (e.g., number of `add`-above-`min` patterns).
- Prove local confluence by analyzing critical pairs between AC rules and distributivity.
- The canonical form after completion would be a "sum of minima" normal form, analogous to DNF in Boolean logic.

**Cross-Domain Connections:** This connects to Gröbner basis theory for commutative algebra, where completion yields canonical polynomial representatives. In the tropical setting, the analogous object is the "tropical polynomial normal form."

---

## 3. Build a Reflection Tactic Using `normalize_ca`

**Hypothesis:** The canonical form theorem can be used to build a proof-producing tactic that automatically proves AC-equivalences of tropical expressions by computation.

**Proof Strategy:**
- Define a decidable `TropExpr` type with computable comparison (using rational approximations or exact rational arithmetic instead of `ℝ`).
- Implement a `reflect` function that maps Lean expressions to `TropExpr`.
- Use `normalize_ca_complete` as the reflection theorem: if `normalize_ca (reflect e₁) = normalize_ca (reflect e₂)` (checked by `native_decide`), then `e₁ = e₂`.
- Package as a Lean 4 tactic `tropical_ac`.

**Cross-Domain Connections:** This mirrors the `ring` tactic architecture (Horner normal forms for polynomial equality) and the `omega` tactic (Presburger arithmetic). A `tropical_ac` tactic would be the first certified automation for tropical algebra.

---

## 4. Define Certified Tropical Polynomial Normal Forms

**Hypothesis:** Tropical polynomials `p(x₁,...,xₙ) = min(a₁ + c₁₁x₁ + ... + c₁ₙxₙ, ..., aₖ + cₖ₁x₁ + ... + cₖₙxₙ)` admit a canonical "Newton polytope" representation that extends the AC normal form.

**Proof Strategy:**
- Define a `TropPoly` type as a sorted list of (coefficient vector, constant) pairs.
- Normalize by sorting lexicographically and removing dominated terms (those never achieving the minimum).
- Prove soundness and completeness for the full tropical polynomial identity `∀ x, p(x) = q(x)`.
- This requires the geometric insight that tropical polynomial identity is equivalent to Newton polytope equality.

**Cross-Domain Connections:** Newton polytopes appear in algebraic geometry (toric varieties), optimization (linear programming duality), and phylogenetics (tree space geometry). Certified tropical polynomial normal forms would bridge formal verification with these application domains.

---

## 5. Connect Canonical Tropical Syntax to Shortest-Path Circuit Extraction

**Hypothesis:** Tropical expressions encode shortest-path computations in weighted graphs. The AC canonical form corresponds to a canonical circuit representation for shortest-path programs, enabling certified common-subexpression elimination.

**Proof Strategy:**
- Define a graph semantics for `TropExpr`: `tmin` is path choice (take the shorter), `add` is path concatenation (sum weights).
- Show that AC-equivalent expressions compute the same shortest-path function.
- Prove that the canonical form minimizes the number of distinct subexpressions (up to AC), enabling optimal memoization.
- Connect to dynamic programming: the canonical form is a canonical DP table.

**Cross-Domain Connections:** This links to circuit complexity (VP vs. VNP in the tropical semiring), compiler optimization (CSE and instruction scheduling), and operations research (network flow algorithms). A certified tropical circuit optimizer could verify correctness of shortest-path algorithm implementations.
