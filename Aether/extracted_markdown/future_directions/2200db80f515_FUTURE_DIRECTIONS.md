# Future Directions: Modular Data, Verlinde Fusion, and the Anyon–Group Dictionary

The new file `Catalog/Physics/TopologicalOrderVerlinde.lean` extends
`Catalog/Physics/TopologicalOrderGenus.lean` from the *kinematic* half of the abelian
anyon dictionary (ground-state degeneracy `GSD A g = |A|^g` and the unitary modular
S-matrix `S_{a,b} = (1/√d) χ_a(b)`) to the *dynamical* half: the **Verlinde formula**.
We proved that for any abelian anyon theory the S-matrix diagonalizes the fusion rules
and the resulting fusion coefficient is exactly the group law,
`∑_x (S_{ax} S_{bx} conj S_{cx}) / S_{0x} = δ_{a+b,c}`, together with the identification
of the total quantum dimension `D = √d = (S_{0,0})⁻¹` and a fully unconditional cyclic
(`ZMod n`) specialization. The arguments rest squarely on the catalog lemma
`ModularBraiding.chi_orthogonality` (character orthogonality) and on the structural
`ModularBraiding.smatrix_unitary`. The directions below are the natural next frontier.

## 1. The T-matrix, the modular group, and the chiral central charge mod 8

A modular *braiding* is only half of the modular data; the missing piece is the
topological spin / twist `θ_a`, packaged as a diagonal **T-matrix** `T_{a,b} = θ_a δ_{a,b}`
with `θ_a` a root of unity. The conjecture: for an abelian theory built from a quadratic
form `q : A → ℚ/ℤ` with associated bicharacter `χ_a(b) = e^{2πi B(a,b)}`, the matrices
`S` and `T` satisfy the defining relations of `SL(2,ℤ)` *projectively*:
`(ST)^3 = e^{2πi c/8} S^2` and `S^4 = 1`, where `c` is the chiral central charge mod 8
determined by the Gauss sum `∑_a θ_a = √d · e^{2πi c/8}`.

**The key insight is** that on an abelian theory both `S` and `T` are literally character
sums, so the entire (projective) `SL(2,ℤ)` action reduces to *quadratic Gauss-sum
identities*, which are finite, decidable, and already partly in Mathlib's `GaussSum` API —
turning a deep TQFT statement into elementary finite Fourier analysis.

**Why now?** We already have `S` unitary and the orthogonality engine; adding a `Tmatrix`
field (a homomorphism `A → rootsOfUnity`) to `ModularBraiding` is a one-structure
extension, and the Gauss-sum reciprocity needed for `(ST)^3` is exactly the regime where
the subagent excels (closed-form character manipulation).

## 2. Anyon condensation as a quotient, and a Lagrangian-subgroup classification of gappable boundaries

A bosonic subgroup `L ≤ A` on which the braiding restricts trivially (`χ_a(b) = 1` for
all `a,b ∈ L`) can be "condensed", producing a new abelian theory on `L^⊥ / L`. The
conjecture: the condensed theory `A // L` is again modular iff `L` is **Lagrangian**
(`L = L^⊥`, equivalently `|L|^2 = |A|`), and in that case it is *trivial* (`GSD = 1` on
every surface) — i.e. Lagrangian subgroups are in bijection with gapped boundaries of the
`A`-theory, and `GSD_{A//L} g = (|A|/|L|^2)^g`.

**The key insight is** that condensation is just the additive-character restriction–
induction adjunction: `L^⊥` is the annihilator of `L` under the braiding bicharacter, so
the whole theory of gapped boundaries becomes the duality theory of finite abelian groups,
where `|L|·|L^⊥| = |A|` is provable directly from `chi_orthogonality`.

**Why now?** Our `ModularBraiding.nondeg`/`chi_injective` already encode nondegeneracy as
a perfect pairing; defining `L^⊥` and proving `|L^⊥| = |A|/|L|` is the immediate next
lemma, and it falsifiably predicts the GSD-reduction formula above which can be checked
against `toricCode_GSD` (where `L = ⟨e⟩` or `⟨m⟩` gives `GSD = 1`).

## 3. A Verlinde formula for non-abelian anyons via the fusion ring of a finite group

The proven `verlinde_fusion` says abelian fusion = group addition. The conjecture: for the
(non-abelian) **Dijkgraaf–Witten / quantum-double** theory of a finite group `G`, whose
anyons are pairs (conjugacy class, irrep of the centralizer), the same Verlinde sum over
the character table reproduces the structure constants of the *fusion ring*, and the total
quantum dimension is `D = |G|` (not `√|G|`). Concretely: `N_{ab}^c = ∑_x S_{ax}S_{bx}
\overline{S_{cx}} / S_{0x}` are non-negative integers equal to the Clebsch–Gordan
multiplicities.

**The key insight is** that our abelian proof only used (i) characters multiply when labels
add and (ii) row-orthogonality; for a general finite group the *second* still holds
verbatim (column orthogonality of the character table), so the abelian proof is the rank-1
shadow of a theorem whose only new ingredient is replacing the group law by the class-
algebra product.

**Why now?** Mathlib has `MonoidAlgebra`, `Classical` character theory, and
`Finset.sum`-based orthogonality; the abelian file is the template, and the integrality of
the Verlinde coefficients is a sharp, falsifiable target (a single negative or non-integer
output would refute the formula for the chosen `S`).

## 4. Genus-`g` partition functions and a topological-invariance (cut-and-glue) law

We proved `GSD A g = |A|^g` and connected-sum multiplicativity. The conjecture: the full
genus-`g` partition vector assembled from `S` and `T` is a **mapping-class-group
invariant**, and in particular the dimension formula refines to the Verlinde dimension
`dim V_g = ∑_a (S_{0,a})^{2-2g}`, which for an abelian theory collapses to
`∑_a (√d)^{2g-2} = d^{g-1}·d = d^g`, *reproving* `GSD_eq_pow` from modular data alone.

**The key insight is** that `S_{0,a} = 1/√d` is constant across anyons (our
`Smatrix_zero_left`), so the otherwise-formidable Verlinde dimension formula degenerates to
a single power of `d`; this gives an independent, S-matrix-based derivation of the genus
degeneracy and a cross-check linking Section 1 and Section 2 of the file.

**Why now?** Both inputs already exist as theorems (`GSD_eq_pow`, `Smatrix_zero_left`); the
only new object is the finite sum `∑_a (S_{0,a})^{2-2g}` and the algebraic identity that it
equals `d^g`, which is immediately within reach and makes the genus law a *corollary* of
modular data rather than an independent postulate.

## 5. Stability of the gap: the spectral-gap / error-correction threshold of the abelian code

The degeneracy `d^g` is the logical-qubit count of the associated stabilizer/CSS code. The
conjecture: the associated abelian quantum code has code distance bounded below by the
shortest non-contractible cycle and the logical operators are exactly the characters `χ_a`
acting on the torus algebra; consequently the number of correctable errors grows linearly
in system size while the logical space stays at fixed dimension `d^g`.

**The key insight is** that the logical operators *are* the braiding characters already in
the file — Wilson/'t Hooft loops are evaluations `χ_a(·)` — so distance bounds become
statements about the support of nontrivial characters, i.e. about the minimum Hamming
weight in the group code generated by `A`, a purely combinatorial quantity.

**Why now?** The catalog already contains coding-theory infrastructure
(MacWilliams/Krawtchouk in `Physics/QuantumMacWilliams`), so bridging `GSD` to a concrete
distance bound connects two existing catalog domains and yields a falsifiable inequality
(a single code instance violating the predicted distance would refute it).
