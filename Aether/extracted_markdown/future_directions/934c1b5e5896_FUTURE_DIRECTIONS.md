# Future Directions — Arithmetic Mirror Symmetry for Calabi–Yau

## Synthesis

This cycle established a fully verified *combinatorial skeleton* of mirror symmetry.
We modeled a Calabi–Yau `d`-fold by its **Hodge diamond** — an array `hᵖᵠ : ℕ → ℕ → ℕ`
subject to three axioms that any genuine Hodge diamond satisfies: conjugation symmetry
(`hᵖᵠ = hᵠᵖ`), Serre duality (`hᵖᵠ = h^{d-p,d-q}`), and finite support on `[0,d]²`.
The **mirror** operation is the single combinatorial move `hᵖᵠ ↦ h^{d-p,q}` (vertical
reflection of the diamond). The deliverables (`Core.lean`) prove, with `sorry = 0` and
only the standard axioms `{propext, Classical.choice, Quot.sound}`:

* `mirror` is **closed** inside the class of Calabi–Yau diamonds (the reflection again
  satisfies conjugation symmetry, Serre duality, and finite support);
* `mirror_involutive` — mirroring is an involution;
* `picardRank_mirror` — the **arithmetic mirror slogan**: the Picard rank `h^{1,1}` of
  the mirror equals `h^{d-1,1}` of the original, the Hodge number that governs rational
  curve counts (complex deformations on one side ↔ Kähler/curve data on the other);
* `eulerChar_mirror` — the **topological mirror law** `χ(Y) = (-1)^d χ(X)`;
* a worked **K3** example: a self-mirror diamond with `χ(K3) = 24` and Picard rank `20`.

The central lesson is structural: the closure of the Calabi–Yau axioms under mirroring
forces conjugation symmetry and Serre duality to be used *together* — the identity
`h^{d-p,q} = h^{q,d-p} = h^{d-q,p}` (`reflect_eq`) is the algebraic fingerprint of the
mirror being an involution. This isolates exactly which facts about mirror symmetry are
formal/combinatorial and which require honest geometry (curve counting, Hodge theory,
zeta functions). Everything below is a falsifiable extension of this skeleton.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `reflect_eq` | `h^{d-p,q} = h^{d-q,p}` | proved |
| `mirror` (closure) | reflection is again a `CalabiYau` | proved |
| `mirror_involutive` | `mirror ∘ mirror = id` | proved |
| `picardRank_mirror` | `picardRank (mirror X) = h^{d-1,1}(X)` | proved |
| `eulerChar_mirror` | `χ(Y) = (-1)^d χ(X)` | proved |
| `K3_eulerChar` | `χ(K3) = 24` | proved |
| `K3_self_mirror_picard` | `picardRank(mirror K3) = picardRank K3` | proved |

---

## Direction 1 — A "stringy" mirror invariant: the Hodge–Euler polynomial is mirror-palindromic

Define the two-variable Hodge–Euler polynomial `E(u,v) = Σ_{p,q} hᵖᵠ uᵖ vᵠ` and conjecture
that the mirror exchanges it by `E_Y(u,v) = uᵈ · E_X(u⁻¹, v)` (clearing denominators,
`E_Y(u,v) = Σ_{p,q} h^{d-p,q} uᵖ vᵠ`), and that `eulerChar` is recovered as `E(-1,-1)`.
This refines `eulerChar_mirror` from the single value `χ` to the whole bigraded generating
function, and predicts that `E` is *bidegree-symmetric* under the combined mirror + Serre
symmetries. **The key insight is** that `eulerChar_mirror` is merely the `u=v=-1`
specialization of an identity that holds *coefficientwise*, so the entire Hodge polynomial,
not just its Euler number, transforms by a clean monomial substitution. **Why now?** The
`reflect_eq` machinery and the guarded reflection already give termwise control of the
diamond; promoting the scalar sum `eulerChar` to a `Polynomial (Polynomial ℤ)` (or
`MvPolynomial (Fin 2) ℤ`) is a direct, low-risk reindexing using the same
`Finset.sum_range_reflect` pattern that closed `eulerChar_mirror`.

## Direction 2 — Mirror symmetry as an involution on a *moduli groupoid*, with `h^{p,q}` a complete invariant in low dimension

Promote `CalabiYau d` to a category whose isomorphisms are Hodge-diamond-preserving
equivalences, and conjecture that `mirror` extends to an *involutive autoequivalence* of
this category; moreover, for `d ≤ 2`, two diamonds are mirror-equivalent iff their
`(h^{1,1}, h^{d-1,1})` pairs are swapped. This upgrades the pointwise `mirror_involutive`
to a functorial statement and pins down when the combinatorial mirror is a *complete*
invariant. **The key insight is** that for surfaces (`d=2`) the diamond is determined by
the two numbers `h^{1,1}` and `h^{2,0}`, so the mirror involution becomes a literal
transposition on a 2-dimensional invariant — making "is `Y` a mirror of `X`?" decidable.
**Why now?** `mirror_involutive` already proves the object-level involution; wrapping it in
a `CategoryTheory` `Equivalence` (with the identity-squared witness) is a contained formal
exercise, and the `d=2` classification is finite-case `decide`-able exactly like the K3
example.

## Direction 3 — The arithmetic side: a zeta-function functional equation forced by Poincaré duality

Model the local zeta numerator of a smooth proper variety as a list of "Frobenius
eigenvalue" weights and conjecture that Poincaré duality (the arithmetic analogue of the
`vanish`/`serre` axioms) forces the **functional equation** `P(q^{d}/t) = ± (q^{d}/t)^{B}
· P(t)/q^{…}`, i.e. the numerator is *palindromic* up to the predicted weight twist, where
`B` is the relevant Betti number. Concretely: formalize that a degree-`B` integer polynomial
whose roots come in pairs `α ↔ q^{w}/α` is reciprocal, and connect `B` to `Σ hᵖᵠ`.
**The key insight is** that the same reflection symmetry `p ↦ d-p` that drives mirror
symmetry on Hodge numbers is, on the arithmetic side, exactly the eigenvalue pairing
`α ↦ q^{d}/α` of the Weil conjectures — so the *combinatorial* palindrome we already control
is the shadow of the *zeta* functional equation. **Why now?** The palindrome/reciprocal
half is pure polynomial algebra (`Polynomial.reverse`, root-pairing) that current tactics
handle well, and it provides the first honest bridge from the formalized Hodge skeleton to
the "modularity of CY zeta functions" goal without needing étale cohomology.

## Direction 4 — Counting rational curves: a verified instanton-number recursion in genus 0

Introduce a formal Gromov–Witten / instanton sequence `n_k : ℕ → ℤ` attached to a diamond
and conjecture that the "number of rational curves" generating series is governed by a
mirror-map recursion whose *leading* coefficient is exactly `picardRank (mirror X) =
h^{d-1,1}(X)` — i.e. the first instanton number equals the mirror Picard rank, upgrading the
slogan `picardRank_mirror` from an equality of integers to the first term of a recursively
defined sequence. Test it on the quintic threefold (`d=3`) where the predicted `n_1 = 2875`
is classical. **The key insight is** that `picardRank_mirror` already certifies the *base
case* of the curve-counting recursion, so the open content is purely the *recursion step*,
which can be specified combinatorially before any geometry is invoked. **Why now?** With the
base case formally nailed and the quintic numbers available as a concrete falsification
target, one can encode the recursion as a `Nat`-indexed sequence and check the first few
instanton numbers by `decide`/`norm_num`, immediately confirming or refuting the proposed
recursion shape.

## Direction 5 — Stringy Euler numbers and the orbifold mirror: `χ_str(X) = (-1)^d χ_str(Y)` survives quotient singularities

Extend `eulerChar` to a **stringy/orbifold Euler number** that includes twisted (age-shifted)
sectors of a finite group action, and conjecture that the topological mirror law
`χ(Y) = (-1)^d χ(X)` persists verbatim for `χ_str`, even when the underlying diamonds come
from singular quotients `X/G` where the naive `χ` fails. This stress-tests how robust
`eulerChar_mirror` is once the strict `vanish` support hypothesis is relaxed to allow
fractional age gradings. **The key insight is** that the `(-1)^d` sign in `eulerChar_mirror`
came *only* from the reflection `p ↦ d-p` and was independent of the precise values `hᵖᵠ`,
so it should be *invariant under any sector decomposition* that respects the reflection —
predicting the law survives orbifolding. **Why now?** Our proof of `eulerChar_mirror`
factors the sign out termwise (`sign_reflect`) before touching the Hodge values, so adding a
finite family of age-shifted summands is a direct generalization: re-run the same
`sum_range_reflect` + `sign_reflect` argument over an enlarged index set.
