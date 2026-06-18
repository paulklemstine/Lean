# Future Directions — Tropical Brill–Noether Theory

## Synthesis of this cycle

We formalized **tropical Brill–Noether theory in genus 1** from the ground up, modelling
the genus-1 tropical curve as the cycle graph `Cₙ` and identifying its Picard group with
the Jacobian `ℤ/n` through the Abel–Jacobi map. Two self-contained Lean files were
produced:

* `JacobianDivisors.lean` — divisors as `ZMod n → ℤ`, degree, the Abel–Jacobi map `aj`,
  linear equivalence, Riemann's theorem (every positive-degree divisor is equivalent to an
  effective one), and the chip-firing consistency theorem (`principal_linEquiv_zero`:
  every Laplacian/principal divisor is trivial in the Jacobian).
* `Genus1.lean` — the Baker–Norine rank `bnRank` (defined honestly as a supremum over the
  combinatorial rank predicate, *not* by its closed form), the complete closed-form rank
  computation in all degree regimes, tropical **Riemann–Roch** (`riemann_roch_genus_one`),
  and the **Brill–Noether existence theorem** (`brillNoether_genus_one`): a divisor of
  degree `d` and rank `≥ r` exists iff `ρ = g − (r+1)(g−d+r) ≥ 0`.

### Results summary

| Result | Statement |
|---|---|
| `exists_effective_of_degree_pos` | `deg D ≥ 1 ⟹ D` is linearly equivalent to an effective divisor |
| `principal_linEquiv_zero` | chip-firing ⟹ Jacobian-trivial (Abel–Jacobi consistency) |
| `bnRank_of_degree_pos/neg/zero_*` | exact Baker–Norine rank in every degree regime |
| `riemann_roch_genus_one` | `r(D) − r(K − D) = deg D − g + 1`, `g = 1`, `K = 0` |
| `brillNoether_genus_one` | `∃` degree-`d` rank-`≥ r` divisor `⟺ ρ ≥ 0` |

All main theorems compile with `sorry = 0` and depend only on `propext`,
`Classical.choice`, and `Quot.sound`.

---

## Direction 1 — Cools–Draisma–Payne–Robeva for the chain of loops (arbitrary genus)

Generalize the genus-1 result to a *chain of `g` loops* with generic edge lengths, the
combinatorial backbone of the CDPR proof. The conjecture: a generic chain-of-loops curve
of genus `g` carries a divisor of degree `d` and Baker–Norine rank `r` **iff**
`ρ = g − (r+1)(g − d + r) ≥ 0`. This is directly falsifiable by `#eval`-style enumeration
on small chains (e.g. `g = 2, 3`) before any proof effort: count which `(d, r)` pairs are
realizable and compare with the sign of `ρ`.

The key insight is that on a chain of loops, reduced divisors are encoded by the lengths
of the loops, and the existence of a `gʳ_d` reduces to a purely combinatorial
lattice-point / lingering-lattice-path count — exactly the structure our `aj`-image
argument exploits one loop at a time.

Why now? We already have the genus-1 atom (`Cₙ` with its `ℤ/n` Jacobian) fully formalized;
a chain of loops is an iterated fiber product of these atoms, so the `degree`/`aj`
bookkeeping generalizes coordinatewise and the genus-1 file becomes the inductive base case.

## Direction 2 — The hard half of Abel–Jacobi: chip-firing = Jacobian equivalence

We proved the *easy* direction `principal_linEquiv_zero` (principal divisors are trivial
in `(degree, aj)`). Conjecture the converse on `Cₙ`: **every** degree-0 divisor `D` with
`aj D = 0` is principal, i.e. `D = fire f` for some `f : ZMod n → ℤ`. Equivalently, the
image of the cycle Laplacian is exactly `ker(aj) ∩ {deg = 0}`. This is falsifiable: a
single explicit degree-0, `aj`-trivial divisor that is provably not a Laplacian would kill
it (we predict none exists).

The key insight is that the Laplacian of `Cₙ` has Smith normal form `diag(1,…,1,n,0)`, so
its image has index exactly `n` inside the degree-0 lattice, matching `|ℤ/n| = n`; the two
subgroups therefore coincide by a pure cardinality/cokernel argument.

Why now? Proving this upgrades our *definition* of `LinEquiv` (currently the Jacobian
description) into a *theorem* about genuine chip-firing, closing the last modelling gap and
making the genus-1 development self-justifying rather than Abel–Jacobi–assuming.

## Direction 3 — Clifford's theorem and the special-divisor bound

For *special* divisors (`0 ≤ deg D ≤ 2g − 2` with `r(D) ≥ 0` and `r(K−D) ≥ 0`), conjecture
the tropical Clifford inequality `r(D) ≤ deg D / 2`, with equality characterizing the
hyperelliptic locus. In genus 1 our closed form already gives `r(D) = deg D − 1`, so
Clifford is sharp only at `deg D ∈ {0, 2}`; the conjecture is the general-genus
generalization. Falsifiable by exhibiting a special divisor with `r(D) > deg D / 2`.

The key insight is that Clifford's bound follows from sub-additivity of rank under
addition of divisors, `r(D) + r(K−D) ≤ r(K) = g − 1`, combined with our Riemann–Roch
identity — a structural inequality rather than a curve-specific estimate.

Why now? Our `riemann_roch_genus_one` is the `g = 1` instance of `r(D) − r(K−D) = deg D − g + 1`;
formalizing rank sub-additivity on `Cₙ` is the one missing lemma needed to bootstrap
Clifford, and it lives entirely within the divisor API we have built.

## Direction 4 — Baker's specialization: tropical rank bounds classical rank

Formalize the *specialization inequality* bridging to classical algebraic geometry: for a
divisor `𝒟` on a smooth curve over a valued field specializing to a divisor `D` on the dual
graph, `rank_classical(𝒟) ≤ rank_tropical(D)`. Conjecture the genus-1 sharp case: for an
elliptic curve with multiplicative reduction (dual graph `Cₙ`), equality holds for all
divisor classes. Falsifiable by any class where the tropical rank strictly exceeds the
classical one in genus 1.

The key insight is that specialization is *monotone* precisely because reduction sends
effective divisors to effective divisors and global sections inject into their reductions —
the same effectivity-preservation our `not_linEquiv_effective_*` lemmas formalize tropically.

Why now? Our rank is defined through effectivity of `D − E` over `Cₙ`, which is the exact
combinatorial shadow of the classical `h⁰` semicontinuity; the genus-1 closed form gives a
concrete target against which to calibrate the inequality.

## Direction 5 — Tropical gonality and the Brill–Noether gonality formula

Define the *gonality* `gon(Cₙ) = min { deg D : D effective, r(D) ≥ 1 }` and conjecture
`gon(Cₙ) = 2` for all `n ≥ 2` (matching the classical fact that an elliptic curve is
2-gonal), with the divisor `2·[0]` realizing it. More boldly, conjecture the chain-of-loops
generalization `gon = ⌊g/2⌋ + 2` — the tropical Brill–Noether gonality bound. Falsifiable
by computing realizable `(deg, rank ≥ 1)` pairs on small graphs.

The key insight is that gonality is the smallest `d` with `ρ(g, 1, d) ≥ 0`, so the
gonality formula is *literally a corollary of Brill–Noether existence* with `r = 1` — our
`brillNoether_genus_one` already pins `gon(Cₙ) = 2` since `ρ(1,1,d) ≥ 0 ⟺ d ≥ 2`.

Why now? Direction 5 needs no new machinery in genus 1 — it is a one-line specialization of
`brillNoether_genus_one` to `r = 1` — making it the ideal warm-up that immediately tests the
chain-of-loops generalization in Direction 1.
