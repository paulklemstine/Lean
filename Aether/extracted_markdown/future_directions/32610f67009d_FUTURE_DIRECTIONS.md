# Future Directions: Automated Search for Bridge Morphisms

## 1. Enriched Invariant Semantics over Ordered Semirings

**Hypothesis:** Replacing `ℕ`-valued invariants with invariants valued in canonically ordered commutative semirings (e.g., `ℝ≥0`, tropical semirings, or lattice-valued invariants) would unify height bounds, security parameters, tropical valuations, and proof-complexity measures under a single transport calculus.

**Proof Strategy:**
- Generalize `TheorySpec` to `TheorySpecOrd β` for `[OrderedCommMonoid β]`.
- Prove that transport, composition, and soundness theorems all hold at this generality.
- Instantiate with `β = ℝ≥0` for real-valued invariants (Lipschitz constants, security levels).
- Instantiate with `β = ℤ ∪ {-∞}` for tropical valuations.
- Show that the ℕ specialization is a retract of the general theory.

**Cross-Domain Connections:** This opens bridges between tropical geometry (where valuations are inherently `ℤ`-valued), learning theory (where margins and Rademacher complexity are `ℝ`-valued), and cryptographic security (where advantage bounds are `ℝ≥0`-valued).

**Concrete Next Step:** Formalize `TheorySpecOrd` (already sketched in `Search.lean`), prove the full category laws, and instantiate on at least two domain-bridging examples with real-valued invariants.

---

## 2. Graph Search over the Full Catalog

**Hypothesis:** The collection of all `TheorySpec` instances in the catalog, together with all `TheoryHom` morphisms, forms a directed graph whose connected components reveal hidden mathematical analogies. Automated path search in this graph can discover indirect bridges that no human would anticipate.

**Proof Strategy:**
- Build a metaprogram that enumerates all `TheorySpec` definitions in the project.
- For each pair, attempt to synthesize a `SearchCertificate` by trying identity maps, projections, and simple compositions with `omega`/`linarith`/`nlinarith` as proof backends.
- Store successful certificates in a graph data structure.
- Prove: if a path exists from A to B in the graph, then `A.lowerBound ≤ B.inv (path.map x)` for all A-witnesses x.

**Cross-Domain Connections:** This is analogous to knowledge graph completion in AI, where link prediction discovers implicit relationships. Here, the "links" are mathematically certified.

**Concrete Next Step:** Implement a `MetaM`-level tactic `discover_bridges` that, given two `TheorySpec` names, attempts up to 3-hop searches and reports all found paths.

---

## 3. Adjunctions and Galois Connections Between Theories

**Hypothesis:** Some pairs of theories are not merely connected by one-directional morphisms but by adjunctions: a morphism `f : A → B` and a morphism `g : B → A` such that `f ∘ g` and `g ∘ f` satisfy approximation inequalities. This would capture the bidirectional nature of many mathematical dualities (e.g., Legendre transform, Fourier duality, tropical-algebraic correspondence).

**Proof Strategy:**
- Define `TheoryAdj (A B : TheorySpec)` as a pair of morphisms with approximate round-trip properties.
- Prove that adjunctions compose.
- Show that an adjunction `A ⇌ B` implies mutual lower-bound transfer with quantitative loss bounds.
- Instantiate on the height-dimension adjunction (height embeds into dimension, dimension projects back with +1 loss).

**Cross-Domain Connections:** Galois connections are the foundation of abstract interpretation in program verification. This would create a formal bridge between mathematical invariant theory and software verification methodology.

**Concrete Next Step:** Define `TheoryAdj`, prove composition and transfer theorems, and instantiate on height ⇌ dimension.

---

## 4. Cryptography ↔ Learning ↔ Tropical Triads via Composed Morphisms

**Hypothesis:** The bridge graph Height → Dimension → Security already hints at a three-way connection between arithmetic learning theory (heights), tropical geometry (dimensions), and cryptographic security (security parameters). A full triad would show that hardness results in any one domain automatically imply hardness results in the other two.

**Proof Strategy:**
- Formalize the tropical valuation as a `TheorySpec` with `inv = tropical_degree`.
- Build a morphism from tropical specs to security specs via dimension bounds.
- Build a morphism from learning specs (Lipschitz/margin bounds) to height specs.
- Compose to get a certified triad: Learning → Height → Dimension → Security.
- Prove: any new lower bound in learning theory automatically yields a new lower bound in cryptographic security.

**Cross-Domain Connections:** This would formalize the emerging intuition in theoretical computer science that learning hardness and cryptographic hardness are two faces of the same coin (cf. computational learning theory hardness from crypto assumptions).

**Concrete Next Step:** Build the tropical-to-security morphism using existing `dimension_security_theorem`, then compose with `affine_map_lipschitz_from_height` to get the full triad.

---

## 5. Theorem Embeddings from Syntax: Automatic TheorySpec Extraction

**Hypothesis:** Many theorem statements in the catalog have the implicit structure of a `TheorySpec` — they assert a lower bound on some quantity for all elements satisfying some predicate. A metaprogram could automatically extract `TheorySpec` instances from theorem signatures by pattern-matching on the syntactic form `∀ x, P x → n ≤ f x`.

**Proof Strategy:**
- Write a `MetaM` procedure that inspects a theorem's type.
- Pattern-match on universal quantification, implication with a predicate, and inequality with a constant.
- Extract `α`, `Witness`, `inv`, `lowerBound`, and wrap the theorem's proof as `sound`.
- Automatically populate the bridge graph.

**Cross-Domain Connections:** This is a form of mathematical information extraction, analogous to knowledge extraction from natural language in NLP. It would enable the catalog to "discover its own hidden analogies" as new theorems are added.

**Concrete Next Step:** Implement a `extractTheorySpec` tactic that takes a theorem name and produces a `TheorySpec` instance, then test on 10 catalog theorems.

---

## Summary

| Direction | Difficulty | Impact | Dependencies |
|-----------|-----------|--------|-------------|
| 1. Enriched invariants | Medium | High | None |
| 2. Graph search | Medium | Very High | Direction 1 (optional) |
| 3. Adjunctions | Hard | High | None |
| 4. Triads | Medium | Very High | Direction 2 |
| 5. Syntax extraction | Hard | Transformative | Direction 2 |

The recommended order is 1 → 2 → 4 → 3 → 5, with direction 5 as the long-term goal that would make the entire framework self-sustaining.
