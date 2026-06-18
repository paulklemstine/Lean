# Future Directions: Clause-Space Certificates for Propositional Refutations

## Synthesis

The clause-space certificate framework establishes a new interface between proof complexity, finite-state reachability, and certified computation. By modeling bounded-memory proof search as a transition system over clause configurations, we have shown that space-bounded refutability admits a finite, checkable geometry: certificates are paths in a configuration graph, soundness follows from a semantic invariant, and the search space is explicitly bounded by combinatorial counting (3^n consistent clauses, yielding C(3^n, s) configurations of size ≤ s).

The five directions below exploit this geometric structure in complementary ways. Directions 1–2 push toward practical impact (solver integration and lower bounds). Directions 3–4 extend the theory to richer proof systems and continuous relaxations. Direction 5 is a grand challenge connecting clause space to circuit complexity—a bridge that, if successful, would link two of the deepest open problems in theoretical computer science.

All directions reference the core theorems formalized in `Pythagorean/ClauseSpace.lean`.

---

## Direction 1: Polynomial Certificate Search Within the Configuration Graph

**Conjecture:** For every unsatisfiable CNF `F` on `n` variables with clause-space complexity `s`, BFS over the configuration graph `G(F, s)` finds a valid space certificate in at most `O(|R(F,s)|²)` transition examinations, where `R(F, s)` is the set of reachable configurations.

**Test:** Enumerate all unsatisfiable CNFs on ≤ 5 variables. For each formula and each `s ∈ {1, ..., 6}`, run BFS and record:
- Number of transitions examined.
- |R(F, s)|.
- Certificate length.

Fit a polynomial `p(x) = ax^b` to the (|R(F,s)|, transitions) data. The conjecture predicts `b ≤ 2`.

**Impact:** If true, this gives an explicit polynomial-time algorithm (in the size of the reachable state space) for finding space certificates. This is nontrivial because BFS over the *full* configuration graph has exponential cost, but BFS restricted to reachable configurations may be tractable.

**Catalog References:** `Pythagorean/ClauseSpace.lean` — `spaceCertificate_complete`, `numConsistentClauses_le_three_pow`.

**Proof Strategy:** Show that the reachable subgraph has bounded diameter (polynomial in |R(F,s)|). This would follow if every reachable configuration has a "short return path" to the initial state—a claim related to reversibility of the transition system.

**Domain Bridges:** Graph theory (BFS complexity), combinatorial optimization (state-space search).

**Lineage:** Extends the completeness theorem (Theorem 2) and counting bound (Theorem 5).

**Ambition:** 🟡 Solid extension — directly testable with existing code, likely provable for restricted formula classes.

---

## Direction 2: Formalized Space Lower Bounds via Certificate Non-Existence

**Conjecture:** For the Tseitin formulas `T(G, c)` on an expander graph `G` with `n` vertices and odd charge `c`, any space certificate requires `s ≥ Ω(n)`. Equivalently, the configuration graph `G(T(G,c), s)` has no path from `∅` to a goal configuration for `s < cn` (for an explicit constant `c > 0`).

**Test:** Construct Tseitin formulas on small expander graphs (n = 6, 8, 10). For each, run exhaustive BFS with increasing `s` and record the minimum `s` at which a certificate exists. Compare with `cn`.

**Impact:** The first *formally verified* space lower bound in proof complexity. Prior lower bounds [Ben-Sasson 2009, Nordström 2013] are proved on paper; this would provide machine-checked certainty.

**Catalog References:** `Pythagorean/ClauseSpace.lean` — `clauseSpaceRefutable_sound`, `spacePotential_bounded`, `certificate_monotone_in_space`.

**Proof Strategy:** Formalize the width-space relationship: `space(F ⊢ ⊥) ≥ width(F ⊢ ⊥) - max_clause_width(F) + 1`. Then use known width lower bounds for Tseitin formulas. The key lemma is that any narrow refutation can be converted to a low-space refutation, and conversely, high-width formulas require high space.

**Domain Bridges:** Algebraic topology (Tseitin formulas encode cycle spaces), spectral graph theory (expander properties).

**Lineage:** Extends the soundness theorem (Theorem 1) and monotonicity (Theorem 3).

**Ambition:** 🔴 Grand challenge — requires formalizing substantial proof complexity machinery.

---

## Direction 3: Space Certificates for Extended Resolution

**Conjecture:** The space certificate framework extends to extended resolution (ER) with an analogous soundness-completeness theorem. Moreover, ER-space certificates can be exponentially shorter than resolution-space certificates for the same formula.

**Test:** Define ER-space steps (adding extension variables and their defining clauses). Implement the extended checker. Compare certificate lengths for known hard formulas (pigeonhole, Tseitin) between resolution and ER.

**Impact:** Extended resolution is the proof system underlying modern CDCL solvers. Space certificates for ER would directly apply to practical SAT solving.

**Catalog References:** `Pythagorean/ClauseSpace.lean` — `SpaceStep`, `SpaceCertificate`, `certificateChecks`.

**Proof Strategy:** Add a fourth step action `extend(v, c₁, c₂)` that introduces a fresh variable `v` and its defining clauses. The soundness proof requires showing that the extension preserves satisfiability equivalence, not just entailment.

**Domain Bridges:** Circuit complexity (extension variables correspond to intermediate gates), automated reasoning (CDCL clause learning).

**Lineage:** Directly extends the core definitions in §2–3 of the formalization.

**Ambition:** 🟡 Solid extension — the definitions are straightforward; the challenge is proving the exponential separation.

---

## Direction 4: Continuous Relaxations and Entropy of the Configuration Graph

**Conjecture:** The logarithm of the number of reachable configurations `log |R(F, s)|` behaves as a *space entropy* that satisfies a subadditivity inequality: for two independent subformulas `F₁, F₂`, `log |R(F₁ ∧ F₂, s)| ≤ log |R(F₁, s)| + log |R(F₂, s)|`.

**Test:** Compute `|R(F, s)|` for pairs of independent random 3-SAT formulas and their conjunction. Test the subadditivity inequality. Compute the entropy ratio `log |R(F₁ ∧ F₂, s)| / (log |R(F₁, s)| + log |R(F₂, s)|)` and check if it is ≤ 1.

**Impact:** Would establish a formal analogy between clause space and thermodynamic entropy, opening connections to statistical physics of random SAT.

**Catalog References:** `Pythagorean/ClauseSpace.lean` — `numConsistentClauses_le_three_pow`, `spacePotential_bounded`.

**Proof Strategy:** If `F₁` and `F₂` share no variables, reachable configurations of `F₁ ∧ F₂` decompose as products of reachable configurations of the components. The subadditivity then follows from `|A × B| = |A| · |B|`.

**Domain Bridges:** Statistical mechanics (partition functions), information theory (entropy subadditivity), random SAT (phase transitions).

**Lineage:** Extends the counting bound (Theorem 5) to a dynamic measure.

**Ambition:** 🟡 Solid extension for independent formulas; 🔴 grand challenge for correlated formulas.

---

## Direction 5: Clause Space and Circuit Depth — A Complexity Bridge

**Conjecture:** For any Boolean function `f`, the minimum clause space of a resolution refutation of `¬f` (encoded as a CNF) is polynomially related to the minimum depth of a Boolean circuit computing `f`.

More precisely: `space(¬f ⊢ ⊥) ≥ Ω(depth(f)^{1/2})`.

**Test:** Compute clause space for CNF encodings of known functions (parity, majority, threshold) on small inputs. Compare with circuit depth. Look for violations of the conjectured bound.

**Impact:** This would be a major bridge between proof complexity and circuit complexity—two fields that have developed largely independently. A proof would imply new circuit lower bounds from space lower bounds, and vice versa.

**Catalog References:** `Pythagorean/ClauseSpace.lean` — `clauseSpaceRefutable_sound`, `certificate_monotone_in_space`, `numConsistentClauses_le_three_pow`.

**Proof Strategy:** The connection runs through *pebbling*: resolution space is related to black-white pebbling number [Nordström 2013], and pebbling number is related to circuit depth for certain graph families. The conjecture asserts this relationship extends beyond pebbling formulas to general Boolean functions.

**Domain Bridges:** Circuit complexity (depth, fan-in), combinatorial optimization (pebbling games), computational complexity (P vs NC, space vs depth).

**Lineage:** Builds on the entire framework — space certificates provide the formal language for stating and testing the conjecture.

**Ambition:** 🔴 Grand challenge — would resolve (or refute) a new conjecture at the intersection of proof complexity and circuit complexity. Computational testing can immediately identify counterexamples or build evidence.
