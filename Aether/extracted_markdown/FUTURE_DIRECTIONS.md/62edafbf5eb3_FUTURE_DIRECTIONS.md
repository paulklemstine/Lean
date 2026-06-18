# Future Directions: Topological Order, Genus Degeneracy, and Modular Data

The file `Catalog/Physics/TopologicalOrderGenus.lean` establishes, for an *abelian*
anyon theory whose anyon types form a finite abelian group `A` with `d = |A|`:

* the ground-state degeneracy law `GSD A g = d ^ g` on a genus-`g` surface, together
  with its per-handle recursion (`GSD_handle`), connected-sum multiplicativity
  (`GSD_connected_sum`), torus value (`GSD_torus`), and identification with the complex
  dimension of the free ground-state Hilbert space `(Fin g → A) →₀ ℂ` (`GSD_eq_finrank`);
* the **unitarity** of the modular S-matrix `S_{a,b} = (1/√d) · χ_a(b)` built from a
  nondegenerate braiding bicharacter (`ModularBraiding.smatrix_unitary`), via character
  orthogonality on `A` (`ModularBraiding.chi_orthogonality`); and
* a **fully worked example**: the explicit `cyclicBraiding (ZMod n)` realizing the
  discrete Fourier S-matrix `(1/√n) exp(2πi ab/n)`, whose unitarity is therefore
  *unconditional* (`cyclic_smatrix_unitary`), plus the cross-file bridge
  `toricCode_GSD : GSD (ZMod 2 × ZMod 2) g = 4^g` matching the catalog result
  `ToricCode.ground_space_dim`.

These results extend `ToricCode.ground_space_dim` (the `ℤ/2` toric code, fixed at `4`
on the torus) from one concrete lattice model to *all* abelian anyon theories and *all*
genera, and supply the previously missing braiding/modular-data half of the story. The
directions below push toward the full anyon–TQFT dictionary.

## Direction 1 — Symmetry of the cyclic S-matrix and the explicit `ZMod n` character table

Now that `cyclicBraiding n` is constructed, prove the remaining hallmarks of modular
data for it: symmetry `S_{a,b} = S_{b,a}` (immediate from `a*b = b*a`), the conjugation
relation `S_{-a,b} = conj S_{a,b}`, and the value `S_{0,b} = 1/√n` identifying the
vacuum row with the (constant) quantum-dimension vector. **The key insight is** that all
of these are pointwise identities of the additive character `b ↦ exp(2πi ab/n)`, so each
reduces to an `AddChar`/`mulShift` rewrite plus the `Complex.conj_ofReal` /
`AddChar.map_neg_eq_conj` lemmas already exercised in the unitarity proof. **Why now?**
The hard analytic content (orthogonality, unitarity) is finished; these are the cheap
algebraic corollaries that complete the worked example into a full modular-data table,
and they require no new Mathlib machinery.

## Direction 2 — The T-matrix and an `SL(2,ℤ)` representation on the torus

Adjoin the topological-spin / T-matrix `T_{a,b} = θ_a · δ_{a,b}` with `θ_a = exp(πi q(a))`
for a quadratic refinement `q` of the braiding, and prove the modular relations
`(ST)³ = c·S²` and `S⁴ = 1` on the `GSD A 1 = |A|`-dimensional torus ground-state space.
**The key insight is** that the torus ground states carry a projective representation of
the mapping class group `SL(2,ℤ) = π₀ Diff⁺(T²)`, with `S` and `T` the images of the two
Dehn-twist generators, so the modular relations are *forced* by the topology of the
torus rather than postulated. **Why now?** With `smatrix_unitary` and a diagonal `T` in
hand, the relations reduce to finite Gauss-sum identities over `A`, exactly the regime
where Mathlib's `AddChar`/`gaussSum` machinery (e.g. `AddChar.sum_mulShift`) is strong;
this is the smallest nontrivial mapping-class-group representation to formalize.

## Direction 3 — The Verlinde formula and non-abelian genus degeneracy

Generalize `GSD_eq_pow` to the full Verlinde formula `GSD(g) = ∑_a (S_{0,a})^{2-2g}`,
which for abelian theories collapses to `d^g` (all `S_{0,a} = 1/√d`) but for non-abelian
modular categories yields the dimension of the space of genus-`g` conformal blocks, and
prove the Verlinde fusion identity `N_{ab}^c = ∑_x S_{ax}S_{bx} conj(S_{cx})/S_{0x}`.
**The key insight is** that diagonalizing the commutative fusion algebra by the unitary
S-matrix turns the topological recursion (cutting a genus-`g` surface into pairs of
pants) into an eigenvalue computation, so degeneracy is a *trace* `∑_a λ_a^{2g-2}` of the
fusion operators. **Why now?** Our `smatrix_unitary` already provides precisely the
orthonormal eigenbasis the Verlinde formula needs; extending the anyon model from a
group to a based commutative `ℂ`-algebra with nonnegative integer structure constants is
the natural next data-structure step, and the abelian case is an instant sanity check
against `GSD_eq_pow`.

## Direction 4 — Toric code as a hyperbolic braiding and bridge to the chain complex

We have already proven `toricCode_GSD : GSD (ZMod 2 × ZMod 2) g = 4^g`. Complete the
bridge by exhibiting the toric-code braiding as the *hyperbolic* (symplectic)
bicharacter `((e₁,m₁),(e₂,m₂)) ↦ (-1)^{e₁m₂ + e₂m₁}`, verifying it satisfies the
`ModularBraiding` axioms (bilinearity and nondegeneracy), and deriving its unitary
S-matrix from `smatrix_unitary`. **The key insight is** that the mutual `e`–`m` statistics
of the toric code are encoded by a nondegenerate symplectic form, whose nondegeneracy is
the algebraic shadow of the geometric linking of `e` and `m` loops on the torus.
**Why now?** It is a direct cross-file bridge: it ties the new abstract degeneracy and
braiding theorems to the already-formalized chain-complex toric code
(`ToricCode.ground_space_dim`), validating both formalizations against each other on the
canonical example, and the `(-1)^{...}` character is realizable in Mathlib as a product
of two `ZMod 2` standard characters.

## Direction 5 — Degeneracy as a topological invariant: ground states from `H¹(Σ_g; A)`

Replace the chosen basis `Fin g → A` by the gauge-theoretic ground-state space
`H¹(Σ_g; A) ≅ A^{2g}` of flat `A`-connections and prove the discrete-gauge-theory
degeneracy `|A|^{2g}` (Dijkgraaf–Witten), then show our `d^g` law (`GSD_eq_pow`) is the
*holomorphic/chiral half* obtained after imposing a Lagrangian (maximal isotropic)
polarization of the intersection form on `H¹`. **The key insight is** that the symplectic
intersection pairing on `H¹(Σ_g; A)` makes the full flat-connection space `A^{2g}` a
phase space, and quantization picks out a Lagrangian of dimension `g`, recovering exactly
the `d^g` we proved. **Why now?** Mathlib's group-cohomology and finite-abelian-group
APIs are mature enough to define `H¹(Σ_g; A)` for the surface-group presentation
`⟨a_i, b_i | ∏ [a_i, b_i]⟩`, so the `|A|^{2g}` count is within reach and would place our
combinatorial `GSD` on a genuinely topological footing.
