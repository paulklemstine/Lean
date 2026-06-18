# Future Directions — Sheaf-Theoretic Data Integration

## Synthesis

This cycle formalized the claim that *a database with missing entries is a partial
section of a sheaf*. The presheaf in question assigns to each set of columns `S`
the database fragments observed on `S` (modelled, with deliberate first-principles
economy, as total functions seen through agreement `AgreeOn S`). Its restriction
maps are column projections. We proved that this presheaf is in fact a **sheaf**:
the separation axiom (`gluing_unique`) and the gluing axiom (`gluing_exists`)
both hold, and they combine into the equalizer biconditional `sheafCondition`:

> a family of database fragments extends to one global record **iff** the
> fragments are pairwise compatible on the columns they share.

The everyday corollary `merge_two` is the database-merge rule: two fragments fuse
into a consistent record exactly when they agree on the shared key columns. On the
probabilistic side, `observe_all_prob` proves the completeness power law
`P(all N cells observed) = (1 - r)^N` as the mass of the all-observed atom of a
product of Bernoulli measures, grounding the conjectured `P(sheaf) = (1 - r)^N`.

This work extends `Cryptography.CellularSheafCohomology`: that file handles the
constant sheaf on a *graph* (global sections = `H0`, gluing along walks); this file
handles the *powerset* sheaf of database fragments and isolates the gluing axiom
itself as a standalone, reusable equalizer statement.

## Results Summary

- `gluing_unique` — separation: a gluing is unique on the union of column sets.
- `gluing_exists` — gluing: pairwise-compatible fragments glue to a global record.
- `sheafCondition` — the equalizer biconditional (gluable ↔ compatible).
- `merge_two` — two-fragment merge rule via the shared columns.
- `observe_all_prob` — `P(all N cells observed) = (1 - r)^N`.

## Research Directions

### 1. Cohomological obstruction to imputation (`H¹ ≠ 0` ⇒ no consistent fill-in)

The sheaf condition says gluability equals pairwise compatibility, but real
databases can be *locally* consistent yet *globally* obstructed when three or more
fragments form a cycle of agreements that cannot be simultaneously satisfied. The
key insight is that this obstruction is precisely the first Čech cohomology group
`Ȟ¹` of the database sheaf over the cover by column sets, and `Ȟ¹ = 0` is the
exact condition under which "locally consistent" upgrades to "globally fillable."
Falsifiable form: construct a cover and fragments that are pairwise compatible but
have no global section, and show the obstruction class in `Ȟ¹` is nonzero; conversely
prove `Ȟ¹ = 0 → existence of a global section` for the powerset cover. **Why now?**
We already have the gluing/separation pair (`gluing_exists`, `gluing_unique`),
which are exactly the `H⁰`-level statements; the Čech complex over a finite cover
is a short, explicit chain complex, so the `H¹` obstruction is immediately within
reach of the same `AgreeOn` machinery.

### 2. From "all observed" to the full sheaf-success law over a constraint complex

`observe_all_prob` computes the probability that *every* cell is present. The real
conjecture `P(sheaf) = (1 - r)^{C(n,k)}` is about overlapping *constraints*, not
cells. The key insight is that when the `C(n,k)` overlap constraints are
probabilistically independent, the sheaf-success event is an intersection of
independent events, so its probability factors as `(1 - r)` raised to the number
of binding constraints — i.e. the power law is a statement about the independence
structure of the nerve of the cover, not about cells. Falsifiable form: prove
`P(⋂ᵢ Cᵢ) = (1 - r)^m` for `m` independent constraint events via
`ProbabilityTheory.iIndepSet`, and exhibit a dependent-constraint counterexample
where the law fails. **Why now?** The product-measure / `Measure.pi` toolchain
used in `observe_all_prob` generalizes directly to `iIndep`, and Mathlib's
independence API (`iIndepSet.meas_iInter`) makes the factorization a short step.

### 3. The merge rule as a metric: closest global section and imputation error

`merge_two` gives a *yes/no* mergeability test. The imputation method wants the
*closest* global section when exact gluing fails. The key insight is that over a
metric value space the set of global sections is a closed (indeed affine, for
linear constraints) subset, so a unique nearest global section exists and the
imputation error is the distance to that set — turning imputation into a genuine
projection problem. Falsifiable form: prove existence and uniqueness of a nearest
global section for a finite database over `ℝ`-valued columns with linear
restriction maps, and bound the imputation error by the maximal pairwise
overlap-disagreement. **Why now?** The global-section predicate `IsGluing` is
already a linear condition in the value type; combining it with Mathlib's
`Submodule` and projection-onto-closed-convex-set lemmas closes the loop between
this algebraic file and a quantitative imputation guarantee.

### 4. Monotonicity of fillability in the column cover (a Galois connection)

Refining the cover (observing more, smaller column groups) can only *increase* the
set of consistency constraints and hence *shrink* the space of global sections —
mirroring `H0_antitone` from the graph file. The key insight is that the map
`cover ↦ {global sections}` is an antitone Galois-type connection between the
lattice of covers and the lattice of section spaces, so coarsening a database
schema is left adjoint to forgetting constraints. Falsifiable form: prove
`cover₁ refines cover₂ → GlobalSections(cover₁) ⊆ GlobalSections(cover₂)` and
identify the adjoint that recovers the finest cover inducing a given section
space. **Why now?** `AgreeOn.mono` already encodes the order-reversing behaviour at
the fragment level; lifting it to whole covers is a direct structural induction.

### 5. Cryptographic reading: secret-sharing as a database sheaf

A `(t, n)` threshold secret-sharing scheme is a database whose columns are shares
and whose global sections are exactly the consistent reconstructions of the secret.
The key insight is that the sheaf condition rephrases *reconstruction* (any `t`
shares glue to the same secret) and *privacy* (fewer than `t` shares admit many
incompatible global sections) as `H⁰`-existence and `H⁰`-non-uniqueness statements
over the access structure's cover. Falsifiable form: model Shamir sharing as a
database sheaf over `𝔽_q`-columns and prove that authorized subsets have a unique
gluing while unauthorized subsets have `≥ q` distinct gluings. **Why now?** This
file's `gluing_unique`/`gluing_exists` are exactly the two halves of the
reconstruction/privacy dichotomy, and the catalog already contains finite-field
and secret-sharing-adjacent machinery to connect to.
