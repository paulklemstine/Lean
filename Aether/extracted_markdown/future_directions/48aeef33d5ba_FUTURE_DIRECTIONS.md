# Future Directions — Inverse Stereographic Cryptography

## Synthesis

This cycle attacked the project concept *"Inverse Stereographic Cryptography: Projection
as a One-Way Function"* by replacing the vague slogan "pole-finding is as hard as SVP"
with a **precise, fully formalized chain of identifications** in
`Catalog/Cryptography/InverseStereoCrypto.lean`:

> shortest vector of a key lattice  ⟺  Gaussian representation `b² + c² = p`  ⟺
> denominator of the public rational point on `S¹`.

The geometric one-way map `invStereo : ℝ → S¹` is proved *injective*
(`invStereo_injective`), so — adversarially — it carries **no** hardness by itself: every
bit of security has to live in the arithmetic of the **key lattice**
`stereoLattice p a = { (x,y) : p ∣ y − a·x }`. We then proved that lattice has
determinant `p` (`stereoLattice_det`), that the isotropy condition `p ∣ a² + 1` forces the
Euclidean norm form to take values in `p·ℤ` on the whole lattice (`stereoLattice_norm_dvd`),
and that consequently every nonzero lattice vector has squared length `≥ p`
(`stereoLattice_svp_lower_bound`). Finally the grand synthesis
`stereo_svp_two_squares_bridge` shows that for every prime `p ≢ 3 (mod 4)` this bound is
*achieved* by a two-squares vector, which stereographically projects to a circle point of
denominator `p`.

The decisive adversarial finding is a **boundary**: the construction of the isotropic
residue `a` (and hence the whole bridge) exists **iff** `−1` is a quadratic residue mod
`p`, i.e. iff `p ≢ 3 (mod 4)` — exactly Fermat's congruence. For `p ≡ 3 (mod 4)` the
scheme has *no* isotropic lattice and the SVP-anchor silently collapses. This is not a bug;
it is the true domain of validity, and it is what the directions below stress-test.

## Results Summary (all `sorry = 0`, axioms: `propext, Classical.choice, Quot.sound`)

- `invStereo_mem_circle`, `invStereo_injective`, `invStereo_rational` — the projection is
  an injective map onto `S¹` whose rational form has denominator `b² + c²`.
- `stereoLattice_det`, `stereoLattice_basis_spans` — the key lattice is `ℤ²`-index-`p`
  with explicit basis `(1,a), (0,p)`.
- `stereoLattice_norm_dvd`, `stereoLattice_svp_lower_bound` — isotropy ⇒ norm² ∈ `p·ℤ` ⇒
  every nonzero vector has norm² `≥ p` (the SVP gap collapses to exactly `p`).
- `two_squares_prime_nonzero`, `isotropic_residue_exists`, `stereo_svp_two_squares_bridge`
  — Fermat realizability + residue construction + the full SVP ↔ two-squares ↔ circle
  identification.

These extend the Geometry/Stereographic catalog (`inv_stereo_on_circle`,
`euclid_pythagorean_from_stereo`, `stereo_critical_line`, `stereo_gcd_factor_extraction`)
by attaching a *lattice* and an *SVP optimality statement* to the rational points the
catalog already studies, and they connect to the Cryptography catalog's lattice-hardness
theme by exhibiting a concrete, isotropic 2D lattice whose SVP optimum is number-theoretic.

## Falsifiable Research Directions

### 1. Exact SVP uniqueness: the shortest vector is unique up to the 8 unit symmetries.
Conjecture: for prime `p ≡ 1 (mod 4)`, the nonzero vectors of `stereoLattice p a` (for the
isotropic `a`) attaining norm² `= p` are *exactly* the 8 images of `(b,c)` under the
dihedral unit group `{±1, ±i, swap}` of `ℤ[i]`, and no others — i.e. SVP here has a unique
solution modulo Gaussian units. **The key insight is** that isotropy pins norm² to `p·k`
with `k ≥ 1`, so `k = 1` solutions correspond bijectively to representations `b² + c² = p`,
which are unique up to units by the Gaussian-integer factorization of `p`. **Why now?**
We already have `stereoLattice_norm_dvd` and `stereoLattice_svp_lower_bound`; the missing
piece is `Int.Prime`/`GaussianInt` uniqueness of two-squares, which is in Mathlib
(`Nat.Prime.sq_add_sq` plus `ZMod` square-root uniqueness), so this is a near-term, fully
provable strengthening from "a shortest vector exists" to "the shortest vector is essentially
unique."

### 2. The `p ≡ 3 (mod 4)` impossibility: no isotropic key exists, so the bridge provably fails.
Conjecture: for prime `p ≡ 3 (mod 4)` there is **no** `a` with `p ∣ a² + 1`, hence
`stereoLattice p a` is *never* isotropic and its SVP optimum is `1` (the standard basis
vectors), decoupled from `p`. **The key insight is** that `p ∣ a² + 1` is solvable iff
`−1` is a QR mod `p`, governed by `ZMod.exists_sq_eq_neg_one_iff`, which is false exactly
when `p % 4 = 3`. **Why now?** This is the exact adversarial negation of
`isotropic_residue_exists`; formalizing the impossibility direction turns our "construction
silently fails" comment into a theorem and cleanly delimits the scheme's parameter regime —
a high-value, low-risk falsification target.

### 3. Higher dimensions: `S^{n-1}` projection and the diagonal isotropic lattice.
Conjecture: the `n`-dimensional key lattice
`L = { x ∈ ℤⁿ : p ∣ ⟨a, x⟩ }` with a vector `a` satisfying `p ∣ 1 + Σ aᵢ²` has the property
that `p ∣ ‖x‖²` for all `x ∈ L`, giving an SVP lower bound `‖x‖² ≥ p`, and the optimum is a
sum-of-`n`-squares representation of `p`. **The key insight is** that the 2D proof
(`x²(1 + a²) ≡ 0`) generalizes to `‖x‖² ≡ x_n²(1 + Σ aᵢ²) (mod p)` once one coordinate is
eliminated using the linear congruence. **Why now?** Sum-of-four-squares is *always*
solvable (`Nat.sum_four_squares`), so unlike the 2D case the `n ≥ 4` bridge would have **no**
congruence obstruction — a structurally different, and possibly cryptographically stronger,
regime worth mapping out.

### 4. Lattice-determinant ↔ Hermite-gap quantification of one-wayness.
Conjecture: the ratio (shortest-vector norm²)/(det) for the isotropic key lattice equals
`p / p = 1`, i.e. the lattice is "as dense as possible" along its short direction, and this
Hermite-type invariant is *exactly* what an attacker must overcome — recovering `a` from the
public circle point is equivalent to reaching the `λ₁² = det` floor. **The key insight is**
that `stereoLattice_det = p` and `stereoLattice_svp_lower_bound = p` coincide, so the
Hermite ratio is pinned to `1`, making the scheme's hardness a statement about *achieving*
the Minkowski/Hermite bound rather than approximating it. **Why now?** Both numerator and
denominator are already formalized as exactly `p`; assembling them into a single
`hermite_ratio_eq_one` theorem is immediate and yields a clean, quantitative one-wayness
invariant to carry into reduction proofs.

### 5. A genuine search-to-decision reduction for "pole detection".
Conjecture: deciding whether a given point `q ∈ ℚ²` on `S¹` arose from an isotropic key with
modulus `p` (the *decision* "pole-detection" problem) is polynomial-time equivalent to
*finding* the short vector (the *search* SVP), via the denominator map
`q ↦ den(q) = b² + c²`. **The key insight is** that `invStereo_rational` makes the reduced
denominator of the public point literally equal to the squared length of the secret short
vector, so denominator extraction is a length oracle and length-oracle ⇒ vector-recovery is
the classical SVP self-reduction. **Why now?** The Cryptography catalog already contains
search-vs-decision scaffolding (`SearchDecision.lean`); plugging the proven identity
`den = ‖shortest vector‖²` into that scaffolding is the natural next formal step toward the
original concept's headline claim of an actual SVP ⇄ pole-finding reduction.
