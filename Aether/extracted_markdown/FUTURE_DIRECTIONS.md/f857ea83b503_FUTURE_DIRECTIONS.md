# Future Directions — Topological Quantum Computing: Braiding Universality

(Cycle output for `Catalog/Physics/TopologicalQuantum/JonesBraidRepresentation.lean`.)

## Synthesis

This cycle isolated and proved the *algebraic heart* of topological quantum
computing: the fact that braiding anyons yields a **consistent** representation of
the braid group. The existing catalog file `Catalog/Bridges/BraidingUniversality.lean`
already had braid words, the Kauffman loop value `loopValue A = -A² - A⁻²`, an
abstract `BraidRep₂` structure, Solovay–Kitaev convergence bounds, and density
*criteria* — but it never exhibited a single concrete assignment of matrices to
generators that actually satisfies Artin's braid relations. Likewise
`Catalog/Applications/Jones.lean` builds the Jones polynomial from the Kauffman
bracket but does not connect it to a braid-group action. We bridged these two by
formalizing the **Temperley–Lieb construction** of the Kauffman/Jones
representation in an *arbitrary* unital ℂ-algebra: with `δ = -(a²+a⁻²)` (exactly
the catalog's `loopValue`) and `σᵢ = a·1 + a⁻¹·eᵢ`, we proved invertibility,
the Yang–Baxter / braid relation `σ₁σ₂σ₁ = σ₂σ₁σ₂`, far-commutation, and the
Hecke quadratic relation `σ² = (a-a⁻³)σ + a⁻²·1`.

The key structural insight that emerged is that **the loop value `δ` is the unique
scalar that makes everything close up**: in the invertibility proof the coefficient
of `e` is `a² + a⁻² + δ`, which vanishes *precisely* because `δ = -(a²+a⁻²)`; in
the braid relation the cubic terms collapse only because `eᵢeⱼeᵢ = eᵢ` *and* the
loop value cancels the quadratic `eᵢeᵢ = δ·eᵢ` contributions, leaving a normal
form `a³·1 + a·e₁ + a·e₂ + a⁻¹·(e₁e₂) + a⁻¹·(e₂e₁)` that is manifestly symmetric
in `1↔2`. This "symmetric normal form" is the real reason braid relations hold and
is the structural template for the conjectures below. The Hecke quadratic relation
then pins the eigenvalues to `{a, -a⁻³}`, whose ratio `-a⁴` is the algebraic dial
controlling universality.

What we deliberately did *not* close is density itself: proving the braid image is
dense in SU(2) needs faithfulness of the representation plus quantitative
approximation (Solovay–Kitaev), neither of which is yet available abstractly. We
recorded the precise algebraic seed — `-a⁴` not a root of unity ⇒ infinite order —
as `tl_density_seed_conjecture`. This is the natural next target and the rest of
the directions orbit it.

## Results Summary

- `tl_sigma_mul_tau`: proved — `σ` has the explicit right inverse `τ = a⁻¹·1 + a·e`, the cancellation forced by the loop value `δ`.
- `tl_tau_mul_sigma`: proved — the matching left inverse, so `σ` is two-sided invertible.
- `tl_sigma_isUnit`: proved — packages the above into `IsUnit σ`, so every braid generator maps to a unit and the whole braid group acts.
- `tl_braid_relation`: proved — the Yang–Baxter / braid relation `σ₁σ₂σ₁ = σ₂σ₁σ₂`, the defining relation of `B₃` and the core consistency of anyon braiding.
- `tl_far_commutation`: proved — the `|i-j|≥2` Artin relation `σ₁σ₃ = σ₃σ₁`; together with the braid relation this is a full braid-group representation.
- `tl_hecke_quadratic`: proved — `σ² = (a-a⁻³)·σ + a⁻²·1`, eigenvalues `{a,-a⁻³}`, showing the representation factors through the Hecke algebra `Hₙ(q)`, `q=-a⁴` (Jones' route to `V(L)`).
- `tl_density_seed_conjecture`: conjecture (sorry) — if `-a⁴` is not a root of unity then `σ` has infinite multiplicative order, the algebraic precondition for density in SU(2).

## Research Directions

### Direction 1: Prove the density seed (infinite order from a non-root-of-unity eigenvalue ratio)
**Hypothesis**: In any ℂ-algebra `R` with TL generators, if `e ≠ 0`, `e ≠ δ·1`, and `-a⁴` is not a root of unity, then `σ = a·1 + a⁻¹·e` satisfies `σⁿ ≠ 1` for all `n ≥ 1` (`tl_density_seed_conjecture`).
**Test**: Use the Hecke quadratic relation to show `σⁿ = pₙ·σ + qₙ·1` with `pₙ, qₙ` Chebyshev-like polynomials in the eigenvalues `a, -a⁻³`; then `σⁿ = 1` forces `aⁿ = (-a⁻³)ⁿ = 1`, i.e. `(-a⁴)ⁿ = 1`, contradicting the hypothesis once `e, 1` are shown linearly independent (which `e ≠ 0, e ≠ δ·1` provides). The key insight is that the Hecke quadratic already diagonalizes `σ` abstractly, so powers stay in the 2-dimensional span `⟨1, e⟩` and the eigenvalue ratio `-a⁴` is the only obstruction.
**Why now**: We just proved `tl_hecke_quadratic`, which gives the exact recursion `σ² = (a-a⁻³)σ + a⁻²·1` needed to reduce `σⁿ` to the `⟨1,e⟩` plane — the hard structural step is done.
**If true**: Establishes the first rigorous "non-trivial dynamics" of braiding in this framework and is the cornerstone for any SU(2)-density statement.
**If false**: Would reveal a hidden finite-order degeneracy (e.g. `1` and `e` failing to be independent), refining exactly which `(a,e)` give faithful braiding.

### Direction 2: A concrete 2×2 unitary realization with `eᵢ` rank-one projectors
**Hypothesis**: Taking `R = Matrix (Fin 2) (Fin 2) ℂ` (or `Fin 3`), `e₁, e₂` explicit `δ`-scaled projectors, and `a` on the unit circle, the resulting `σᵢ` are unitary and satisfy all of `tl_braid_relation`, `tl_far_commutation` vacuously/where applicable, giving an honest unitary braid representation.
**Test**: Define `e = δ • (v ⊗ v*)/‖v‖²` for a unit vector and verify `e*e = δ·e` and unitarity of `σ` by `decide`/`norm_num` on the matrix entries, then instantiate the abstract theorems. The key insight is that our theorems are stated over a *general* algebra, so a single matrix instantiation immediately upgrades them to a unitary-gate statement with zero re-proving.
**Why now**: The abstract layer is finished and axiom-clean; instantiation is pure plug-in and exercises the generality we built in.
**If true**: Connects the algebra directly to `BraidingUniversality.BraidRep₂` and to actual quantum gates, closing the loop with the existing catalog structure.
**If false**: Pinpoints a unitarity obstruction (e.g. `|a|=1` insufficient), guiding the correct inner-product normalization for anyonic braiding.

### Direction 3: Build the braid-word homomorphism `Bₙ → Rˣ` and reprove Markov invariance
**Hypothesis**: The assignment `σᵢ ↦ (a·1 + a⁻¹·eᵢ : Rˣ)` extends to a group homomorphism on braid words (`BraidingUniversality.BraidWord`) that is invariant under Markov moves, yielding a link invariant equal to `Jones` from `Catalog/Applications/Jones.lean` up to normalization.
**Test**: Define `eval` on words using `tl_sigma_isUnit`, prove `eval (w₁ ++ w₂) = eval w₁ * eval w₂` and conjugation/stabilization invariance of a Markov trace `tr(eval w)`. The key insight is that the Hecke quadratic relation is exactly the relation under which the Ocneanu/Markov trace is well-defined, so trace invariance is forced by `tl_hecke_quadratic`.
**Why now**: We have invertibility (`tl_sigma_isUnit`) and the Hecke relation, the two ingredients a Markov trace requires; `Jones.lean` supplies the target invariant to match.
**If true**: Produces, inside Lean, the Jones polynomial *as a trace of a braid representation* — the historically original definition — unifying the `Applications/Jones.lean` and `Bridges/BraidingUniversality.lean` threads.
**If false**: Isolates which Markov move breaks, exposing the precise normalization (writhe factor `(-A³)^{-w}`) needed to repair invariance.

### Direction 4: Generalize the base field to an arbitrary commutative ring with the loop value invertible
**Hypothesis**: All four proved theorems hold verbatim with `ℂ` replaced by any commutative ring `k` and `a` a unit of `k` (so `δ` and the eigenvalues live in `k`), i.e. the construction is characteristic-free.
**Test**: Re-state with `variable {k : Type*} [CommRing k] {R : Type*} [Ring R] [Algebra k R]` and a unit `a : kˣ`; re-run the algebraic proofs, replacing `field_simp [ha]`/`mul_inv_cancel₀` by unit lemmas. The key insight is that every step used only `a·a⁻¹ = 1` and ring distributivity — never analytic properties of ℂ — so the proofs should transfer mechanically.
**Why now**: The proofs we just obtained are purely algebraic (`smul`/`ring`/`abel`), making the generalization low-risk and immediately testable.
**If true**: Opens Temperley–Lieb / Jones representations over `ℤ[a,a⁻¹]`, `𝔽_p`, and `p`-adic fields, enabling modular and arithmetic topological-quantum phenomena.
**If false**: Reveals a hidden use of characteristic 0 or of `ℂ`-specific cancellation, sharpening the minimal hypotheses for braiding consistency.

### Direction 5: Quantitative Solovay–Kitaev on the proved generators
**Hypothesis**: Combining `tl_density_seed_conjecture` (infinite order) with the catalog's `BraidingUniversality.solovay_kitaev_depth_bound` gives an explicit `O(log^c(1/ε))` braid-word length to ε-approximate any target unit in the closure of `⟨σ₁, σ₂⟩`.
**Test**: Formalize the SK recursion using the commutator identities (`BraidingUniversality.jacobi_identity`, `commutator_antisymm`) on the proved generators and bound the word length by induction; verify the bound numerically for small ε. The key insight is that we now have *honest* generators satisfying the braid relations, so SK can be run on them rather than on an abstract placeholder.
**Why now**: The convergence skeleton (`solovay_kitaev_depth_bound`, `sk_exponent_growth`) already exists in the catalog and only lacked a concrete generating set, which this cycle provides.
**If true**: Completes the chain "braid relations ⇒ infinite order ⇒ density ⇒ efficient approximation", the full statement of braiding universality.
**If false**: Identifies whether the obstruction is density (group too small) or efficiency (net too sparse), separating the two halves of universality.
