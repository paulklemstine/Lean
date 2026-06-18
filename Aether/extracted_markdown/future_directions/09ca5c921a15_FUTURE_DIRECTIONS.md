# Future Directions: Tropical Kernel Mean Embeddings

## 1. Tropical MMD Pseudometric from Witness Discrepancy Count

The `witnessDiscrepancyCount` currently returns a natural number — the count of generators on which two laws disagree. A natural extension is to define a *tropical maximum mean discrepancy* (MMD) that is a genuine pseudometric on maxitive laws:

```
tropicalMMD(μ, ν) := sup_{f ∈ A} |evalMaxitiveLaw μ f - evalMaxitiveLaw ν f|
```

where `|·|` is a suitable absolute value on the ordered semiring `S` (e.g., truncated subtraction for `ℕ`). Key questions:

- **Triangle inequality**: Does `tropicalMMD` satisfy the triangle inequality? Under what conditions on `S`?
- **Metric vs. pseudometric**: When is `tropicalMMD = 0 ⟹ μ = ν` (i.e., when is the feature set *characteristic*)?
- **Convergence**: Can we define tropical analogues of convergence in MMD for sequences of maxitive laws?

The formalized `congruenceWitnessDist_eq_zero_iff` theorem already gives the zero-level-set characterization.

## 2. Universal/Characteristic Feature Criterion for Maxitive Laws

In classical KME theory, a kernel is *characteristic* if the KME map is injective — distinct probability measures have distinct embeddings. The tropical analogue asks:

**Question**: For which generator sets `A` is the map `μ ↦ (f ↦ evalMaxitiveLaw μ f)_{f ∈ A}` injective?

The max-plus demo shows that coordinate basis vectors `{e_i}` make the embedding injective (since `evalMaxitiveLaw μ e_i = μ(i)`). More generally:

- Characterize *tropical characteristic sets*: generator sets `A` for which the tropical KME is injective.
- Prove that the coordinate basis is universal (already clear from the definition).
- Study minimal characteristic sets and their cardinality — what is the minimum `|A|` needed?
- Extend to infinite-dimensional feature spaces with compact approximation.

## 3. Hahn–Banach Style Dual Separation for Idempotent KMEs

The generated algebra separation theorem shows that disagreement in the algebra reduces to disagreement on generators. This is a *finite* separation principle. The deeper question is whether there exists a *functional-analytic* version:

**Conjecture**: For a suitably defined idempotent semimodule structure on the space of features, there exists a tropical analogue of the Hahn–Banach separation theorem: if two maxitive laws disagree on a continuous feature, there exists a continuous *linear* (in the tropical sense) functional that separates them.

This connects to:
- Litvinov-Maslov idempotent functional analysis
- Tropical convexity and separation theorems (Develin–Sturmfels)
- Cohen–Gaubert–Quadrat theory of max-plus spectral theory

## 4. Witness Complexity Bounds in Terms of Generator Rank

The demo shows empirically that discrepancy count grows with generator set size. Formally:

- **Upper bound**: `witnessDiscrepancyCount A μ ν ≤ |A|` (trivial).
- **Lower bound**: For "generic" laws μ ≠ ν, what fraction of generators separate them? The demo suggests convergence to a constant fraction.
- **Tropical VC dimension**: Define a tropical analogue of VC dimension for generator sets and prove uniform convergence bounds.
- **Algorithmic complexity**: What is the complexity of finding a *minimum* separating generator set?

## 5. Extension to Compact Idempotent Convex Spaces via Choquet-Type Representation

The current theory works with finite sample spaces. The natural extension is:

- Replace `Fintype ι` with a compact topological space.
- Replace `Finset.sup` with a supremum over a compact set (which exists by continuity/semicontinuity).
- Develop a tropical Choquet representation: every maxitive capacity on a compact space can be represented as a tropical integral against a "maximizing measure."
- Connect to Shilkret's maxitive integrals and possibility theory.

This would yield a complete tropical analogue of the classical theory:
- Classical: probability measure → RKHS embedding → Hilbert space separation
- Tropical: maxitive capacity → tropical KME → idempotent semimodule separation

The formal infrastructure built here (generated algebras, agreement propagation, witness extraction) provides the finite skeleton that such a theory can be built upon via topological limits.
