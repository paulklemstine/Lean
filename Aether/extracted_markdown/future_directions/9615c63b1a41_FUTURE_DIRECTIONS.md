# Future Directions

## Synthesis

The Master Optimizer Theorem establishes convergent rewriting as a universal interface for certified algebraic optimization. The five directions below extend this foundation along complementary axes: (1) cost-optimality asks whether convergent normal forms are not just correct but *optimal*; (2) equality saturation connects the quotient factorization theorem to modern e-graph engines; (3) Knuth-Bendix completion automates the construction of convergent systems; (4) Gröbner bases bridge to computational algebra; (5) a grand challenge unifies these threads into a single certified algebraic computation framework. Each direction is falsifiable, builds on specific catalog results, and opens new domain bridges.

---

## Direction 1: Cost-Minimality of Convergent Normal Forms

**Conjecture:** For a convergent rewrite system R equipped with a well-founded reduction ordering ≻ compatible with a syntactic cost function c : T → ℕ (where l ≻ r implies c(l) > c(r) for every rule l → r), the normal form nf(t) is cost-minimal among all terms equivalent to t under EqvGen(R).

Formally: ∀ t u, EqvGen R t u → IsNormalForm R u → c(nf(t)) ≤ c(u).

**Test:** For each of 1000 randomly generated convergent rewrite systems over small signatures (≤ 5 ops, ≤ 10 rules), enumerate all terms equivalent to random inputs up to bounded derivation depth. Compare c(nf(t)) with all equivalent normal forms. Any u with c(u) < c(nf(t)) refutes the conjecture.

**Impact:** If true, convergent rewriting is not just a correct optimizer but an *optimal* optimizer — the best possible canonical form under any cost model compatible with the termination ordering. This would provide formal justification for preferring convergent rewriting over equality saturation in settings where a compatible cost model exists.

**Catalog References:**
- `Pythagorean/ConvergentRewriteOptimizer.lean`: `convergent_rewrite_induces_optimizer`, `nf_unique_of_confluent`

**Proof Strategy:** Attempt proof by contradiction. If u is equivalent to nf(t) with c(u) < c(nf(t)), then by the equivalence, there exists a path from nf(t) to u through EqvGen(R). Factor this path through joinability (using confluence). Since nf(t) is a normal form, the join must go through nf(t) → ... → v ← ... ← u. The ordering compatibility forces c to decrease along rewrite steps, creating a contradiction with c(u) < c(nf(t)).

**Domain Bridges:** Compiler optimization (cost = instruction count), symbolic algebra (cost = polynomial degree), circuit optimization (cost = gate count).

**Lineage:** Extends `convergent_rewrite_induces_optimizer` from semantic preservation to semantic + cost optimality.

**Ambition:** Grand challenge — false in general but may hold for specific, practically important classes of systems.

---

## Direction 2: Equality Saturation Extraction Correctness

**Conjecture:** For a convergent rewrite system R and an e-graph G saturated by R, extracting the cheapest representative from each e-class yields a term semantically equivalent to any other representative — i.e., the extraction function is a certified optimizer in the sense of the Master Optimizer Theorem.

**Test:** Implement bounded e-graph saturation for 100 random convergent systems. For each system, saturate an e-graph with 1000 random terms, extract cheapest representatives using a monotone cost model, and compare eval(extract(t)) with eval(t) across 100 random algebras. Any mismatch refutes the soundness claim.

**Impact:** Would provide the first machine-verified correctness proof for equality saturation extraction, connecting the e-graph literature (Willsey et al., 2021) to the convergent rewriting framework.

**Catalog References:**
- `Pythagorean/ConvergentRewriteOptimizer.lean`: `nf_constant_on_eqvGen`, `quotientNf_mk`, `eval_eq_of_nf_eq`

**Proof Strategy:** Model the e-graph as the quotient Quot(EqvGen R). Show that extraction is a section of the quotient map (like nf). By `nf_constant_on_eqvGen`, any section that is constant on equivalence classes preserves semantics. The key lemma is that e-graph saturation computes exactly EqvGen(R) — this requires proving that saturation is complete (no missing equivalences) for convergent systems.

**Domain Bridges:** SMT solvers, compiler optimization (egg framework), program synthesis.

**Lineage:** Directly extends the quotient factorization theorem to the e-graph setting.

**Ambition:** Solid extension — high confidence of correctness, but formalization is technically demanding.

---

## Direction 3: Certified Knuth-Bendix Completion

**Conjecture:** The Knuth-Bendix completion procedure, when it terminates, produces a convergent rewrite system. Composing completion with the Master Optimizer Theorem yields an automated pipeline: input equational axioms → output certified optimizer.

**Test:** Run completion on 500 sets of random equations over small signatures. For each completed system, verify convergence (bounded confluence check + termination check) and verify that the master theorem holds empirically (normalize random terms, compare evaluations).

**Impact:** Would automate the construction of certified optimizers from equational specifications, eliminating the need to manually construct convergent systems.

**Catalog References:**
- `Pythagorean/ConvergentRewriteOptimizer.lean`: `CertifiedNormalizer`, `convergent_rewrite_induces_optimizer`
- `Catalog/Pythagorean/VerifiedCompilerSynthesis.lean`: `adjoint_semantics_principle`

**Proof Strategy:** Formalize the completion procedure as a function from equation sets to rewrite systems. Prove: (1) each completion step preserves the equational theory, (2) if completion terminates, the output is confluent, (3) termination of the output system follows from the termination ordering used to orient equations. The hardest part is formalizing the critical pair lemma.

**Domain Bridges:** Automated theorem proving, universal algebra, group theory (word problems).

**Lineage:** Extends `CertifiedNormalizer` from a manually constructed certificate to an automatically generated one.

**Ambition:** Solid extension — well-understood mathematics, but substantial formalization effort.

---

## Direction 4: Gröbner Bases as Convergent Polynomial Rewriting

**Conjecture:** Buchberger's algorithm produces a convergent rewrite system on the polynomial ring k[x₁,...,xₙ], and the Master Optimizer Theorem specializes to: for any polynomial p and any ideal I, the Gröbner normal form of p evaluates identically to p at every point of the variety V(I).

**Test:** For 100 random polynomial ideals in k[x,y,z] (k = Z/p for small primes p), compute Gröbner bases using Buchberger's algorithm, normalize random polynomials, and verify eval(nf(p)) = eval(p) at 1000 random points. Any mismatch refutes the application of the master theorem to polynomial rewriting.

**Impact:** Would establish the formal connection between convergent rewriting and computational algebraic geometry, unifying two major traditions in symbolic computation.

**Catalog References:**
- `Pythagorean/ConvergentRewriteOptimizer.lean`: `ring_rewrite_nf_preserves_eval`, `convergent_rewrite_induces_optimizer`

**Proof Strategy:** Model polynomial reduction as a rewrite system on the type `MvPolynomial σ R`. Show that S-polynomial reduction preserves ideal membership (soundness), and that Buchberger's criterion guarantees confluence. Termination follows from the well-ordering on leading monomials. Then instantiate the master theorem.

**Domain Bridges:** Algebraic geometry (ideal membership), robotics (kinematics constraints), cryptography (algebraic attacks).

**Lineage:** Extends `ring_rewrite_nf_preserves_eval` from the toy `RingExpr` type to Mathlib's `MvPolynomial`.

**Ambition:** Grand challenge — requires significant new infrastructure connecting rewriting to Mathlib's polynomial algebra.

---

## Direction 5: Universal Certified Algebraic Computation Framework

**Conjecture:** Every finitely presented equational theory admits a certified optimizer: either a convergent rewrite system (via completion) or a quotient-based normalizer (via the master theorem applied to a partial completion). The framework subsumes constant folding, polynomial simplification, equality saturation, and Gröbner reduction as special cases.

**Test:** Collect 50 equational theories from the literature (groups, rings, lattices, Boolean algebras, etc.). For each, attempt completion and optimizer construction. Measure: (a) fraction of theories where completion succeeds, (b) fraction where the resulting optimizer is empirically correct on 10,000 test evaluations.

**Impact:** Would establish convergent rewriting as the universal backend for certified algebraic computation — a single framework replacing dozens of ad hoc correctness proofs.

**Catalog References:**
- `Pythagorean/ConvergentRewriteOptimizer.lean`: all main theorems
- `Catalog/Pythagorean/VerifiedCompilerSynthesis.lean`: `InterpreterSpec`, `adjoint_semantics_principle`

**Proof Strategy:** Define a type class `CertifiedTheory` packaging an equational theory, a (possibly partial) convergent system, and the soundness proof. Show that the master theorem applies whenever the system is convergent. For incomplete systems, use the quotient factorization to provide partial optimization guarantees.

**Domain Bridges:** All of: compiler optimization, symbolic algebra, SMT, theorem proving, physics (operator normal ordering), quantum computing (circuit optimization).

**Lineage:** Unifies all four preceding directions into a single architecture.

**Ambition:** Grand challenge — paradigm-shifting if achieved, requiring years of formalization effort.
