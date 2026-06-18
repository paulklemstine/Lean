# Future Directions: The Borsuk-Ulam–Arrow Bridge

## Synthesis

This research cycle established a formal bridge between Arrow's impossibility theorem and topological obstruction theory. The key discovery is that the *extremal lemma* — showing that Pareto + IIA forces extremal behavior on profiles with extremal voter rankings — is the precise social-choice analogue of the Borsuk-Ulam obstruction. We proved this lemma by constructing specific permutations via `Equiv.swap`, demonstrating that the space of strict linear orders with its antipodal involution has sufficient structure to drive impossibility results.

The most promising cross-domain connection is between **Kendall distance geometry** and **preference space curvature**. Our proof that the antipodal order achieves maximal Kendall distance (Theorem `kendall_reverse_maximal`) provides a quantitative handle on the "diameter" of the preference sphere. Combined with the Condorcet curvature framework from the existing `ArrowCurvature/Defs.lean` catalog entry, this opens a path toward a full **Riemannian social choice theory** where Arrow-type impossibilities are classified by topological invariants.

The highest breakthrough potential lies in Direction 1: formalizing the complete Arrow proof by proving the "dictator from pivot" step. This would be the first complete machine-verified proof of Arrow's theorem and would establish a template for formalizing other impossibility theorems (Gibbard-Satterthwaite, Sen's liberal paradox).

---

### Direction 1: Complete Formalization of Arrow's Impossibility Theorem

**Conjecture**: The pivotal voter identified by `ArrowProof.pivotal_exists` is a dictator. Specifically: if voter j is pivotal for alternative b (meaning j's switch from "b last" to "b first" flips the social ranking of b), then j determines the social ranking of ALL pairs (a,c) — not just pairs involving b.

**Test**: Formalize the "dictator from pivot" proof in Lean 4. The key step is showing that for any pair (a,c) where a ≠ b and c ≠ b, the pivotal voter j's preference on (a,c) determines the social preference. This requires constructing a profile where: (i) voters before j rank b first with c > a, (ii) voter j ranks a > b > c, (iii) voters after j rank b last with c > a. Then use IIA to relate this profile to the pivotal profile.

**Impact**: First complete machine-verified proof of Arrow's impossibility theorem. Establishes that social choice impossibility is a *theorem* of Lean's type theory, not just an informal argument.

**Catalog References**: `Bridges/BorsukUlamArrow/Defs.lean`, `Bridges/BorsukUlamArrow/Arrow.lean`, `Catalog/Bridges/ArrowCurvature/Defs.lean`

**Proof Strategy**: 
1. Define a helper lemma `mk_profile_with_constraints` that constructs an SLO given constraints on the relative ordering of 3 alternatives (a, b, c). This requires building `Fin n ≃ Fin n` instances via composition of `Equiv.swap`.
2. Use this helper to construct the profile described in the Test section.
3. Apply IIA twice: once to relate to the "b first" pivotal profile, once to the "b last" profile.
4. Use transitivity of the social ranking to derive the dictator property.

**Domain Bridges**: Social Choice Theory <-> Algebraic Topology (obstruction classes), Social Choice <-> Combinatorics (permutation construction)

**Lineage**: Builds on `ArrowProof.extremal_lemma` and `ArrowProof.pivotal_exists` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Gibbard-Satterthwaite via Topological Obstruction

**Conjecture**: The Gibbard-Satterthwaite theorem (any surjective, strategy-proof social choice function on ≥3 alternatives is dictatorial) can be derived from the same topological obstruction that drives Arrow's theorem. Specifically, strategy-proofness + surjectivity implies IIA + Pareto on the induced SWF, so Gibbard-Satterthwaite is a corollary of Arrow.

**Test**: Define `SCF` (social choice function: Profile → Fin n), `Surjective`, and `StrategyProof` in Lean 4. Prove that any surjective strategy-proof SCF induces a Pareto + IIA SWF, then apply Arrow's theorem.

**Impact**: Unification of two major impossibility theorems under a single topological framework. This would formalize Reny's (2001) observation that the two theorems are "essentially equivalent."

**Catalog References**: `Bridges/BorsukUlamArrow/Defs.lean` (SCF definition already present)

**Proof Strategy**:
1. Given a strategy-proof surjective SCF F, define the induced SWF: for each pair (a,b), determine the social preference by checking which of a or b F selects from profiles where a and b are the top two choices.
2. Show the induced SWF satisfies Pareto (from surjectivity + strategy-proofness).
3. Show the induced SWF satisfies IIA (from strategy-proofness: changing irrelevant alternatives doesn't affect the outcome).
4. Apply Arrow's theorem.

**Domain Bridges**: Game Theory <-> Topology, Mechanism Design <-> Algebraic Topology

**Lineage**: Extends Direction 1 (requires Arrow's theorem as a black box).

**Ambition**: extension

---

### Direction 3: Riemannian Social Choice — Curvature Classification of Domain Restrictions

**Conjecture**: The set of domain restrictions on preference profiles that admit non-dictatorial fair aggregation is precisely characterized by the vanishing of a discrete curvature invariant (Condorcet curvature). Specifically: a domain D ⊆ L(n)^k admits a Pareto + IIA SWF if and only if the Condorcet curvature is zero for all profiles in D.

**Test**: 
1. Verify for single-peaked domains (known to have curvature 0 and admit majority rule).
2. Verify for the full unrestricted domain with n=3, k=3 (known to have positive curvature and require dictatorship).
3. Test for "single-crossing" domains and "value-restricted" domains.

**Impact**: Would provide a complete geometric classification of "possible democracy" — identifying exactly which preference structures allow fair aggregation and which do not.

**Catalog References**: `Catalog/Bridges/ArrowCurvature/Defs.lean` (CondorcetCurvature, curvature_zero_iff_no_majority_cycle), `Bridges/BorsukUlamArrow/Defs.lean` (kendallDist, condorcetCycleCount)

**Proof Strategy**:
1. Formalize single-peaked domains in Lean 4.
2. Prove that single-peaked domains have Condorcet curvature 0 (Black's theorem — already in catalog as `single_peaked_majority_transitive`).
3. Define the curvature classification: domain D is "flat" iff ∀ P ∈ D, condorcetCurvature(P) = 0.
4. Prove: flat domains admit non-dictatorial Pareto + IIA SWFs (specifically, majority rule).
5. Prove: non-flat domains require dictatorship.

**Domain Bridges**: Riemannian Geometry <-> Social Choice Theory, Discrete Curvature <-> Voting Theory

**Lineage**: Extends the curvature framework from `ArrowCurvature/Defs.lean` and the Kendall distance geometry from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Tropical Social Choice — Valuations and Preference Aggregation

**Conjecture**: The Kendall distance on the preference space has a natural tropical interpretation: it equals the tropical distance in a tropical polytope whose vertices correspond to strict linear orders. Under this interpretation, Arrow's theorem becomes a statement about the non-existence of certain tropical barycenters.

**Test**: 
1. Represent each SLO as a point in ℝ^(n choose 2) (one coordinate per pair, +1 or -1 for the direction of preference).
2. Show that the Kendall distance equals the L1 distance in this representation.
3. Show that the convex hull of all SLO representations is a permutohedron.
4. Show that Arrow's conditions constrain the "social barycenter" to a vertex (dictator).

**Impact**: Would connect social choice theory to tropical geometry and the existing catalog of tropical results (OperadicTropicalization, TropicalPersistenceRealizationDuality).

**Catalog References**: `Bridges/OperadicTropicalization.lean`, `Bridges/AlgebraTropicalGeometry/TropicalPersistenceRealizationDuality.lean`, `Bridges/BorsukUlamArrow/Defs.lean`

**Proof Strategy**:
1. Define the tropical embedding of L(n) into ℝ^(n choose 2).
2. Prove that Kendall distance = L1 distance under this embedding.
3. Relate Arrow's axioms to constraints on tropical barycenters.
4. Show that the only feasible barycenter is a vertex (dictator).

**Domain Bridges**: Tropical Geometry <-> Social Choice Theory, Permutohedra <-> Voting Systems

**Lineage**: Bridges the Kendall distance results from this cycle with the tropical geometry catalog.

**Ambition**: extension

---

### Direction 5: Quantitative Arrow — How Close Can We Get to Fairness?

**Conjecture**: For any SWF satisfying Pareto but NOT IIA, there exists a quantitative bound on how many pairwise social preferences can be "wrong" (disagree with the dictator's preference). Specifically: if F satisfies Pareto and agrees with IIA on all but ε fraction of profiles, then F agrees with some dictator on at least (1 - f(ε)) fraction of profiles, where f(ε) → 0 as ε → 0.

**Test**: For n=3, k=2, enumerate all SWFs satisfying Pareto. For each, compute the "IIA violation rate" (fraction of profile pairs where IIA fails) and the "dictatorial agreement rate" (maximum over d of the fraction of profiles where F agrees with dictator d). Plot the relationship.

**Impact**: Would provide a quantitative version of Arrow's theorem, showing that "approximate fairness" implies "approximate dictatorship." This connects to the literature on "approximate social choice" and "judgement aggregation."

**Catalog References**: `Bridges/BorsukUlamArrow/Defs.lean`, `Bridges/ArrowCurvature/Defs.lean`

**Proof Strategy**:
1. Define the IIA violation measure: |{(P,Q,a,b) : IIA fails}| / |{(P,Q,a,b)}|.
2. Define the dictatorial agreement measure: max_d |{(P,a,b) : F(P).pref(a,b) ↔ P(d).pref(a,b)}|.
3. Prove a stability bound using the ultrafilter structure of decisive coalitions.
4. The key insight: "almost IIA" implies "almost ultrafilter" implies "almost dictator."

**Domain Bridges**: Quantitative Topology <-> Social Choice, Stability Theory <-> Voting

**Lineage**: Extends the concentration_iff_arrow result from this cycle.

**Ambition**: extension
