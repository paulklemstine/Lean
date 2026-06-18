# Future Directions — Zeta Functions of Graphs and the Graph Riemann Hypothesis

## Synthesis

This cycle pinned down the precise mathematical content hiding inside the slogan
"Graph Riemann Hypothesis". Stripping away the analytically delicate Euler
product `∏_λ (1 − λ^{-s})^{-1}`, the Ihara determinant formula reveals that every
nontrivial pole of a `(q+1)`-regular graph's zeta function is a root of a single
real quadratic `q·u² − λ·u + 1`, one quadratic per adjacency eigenvalue `λ`.
The whole "Riemann Hypothesis" — every nontrivial pole on the critical circle
`|u| = 1/√q` — collapses onto the **sign of one discriminant**, `λ² − 4q`.

The file `GraphZetaRamanujan.lean` proves, with zero `sorry` and only the
standard axioms:

- `critical_line_iff_critical_circle` — the change of variables `u = q^{-s}`
  turns the Riemann line `Re(s) = 1/2` into the circle `|u| = 1/√q`.
- `ramanujan_imp_RH` / `RH_imp_ramanujan` / `RH_iff_ramanujan` — the
  eigenvalue-level equivalence: all poles of the factor of `λ` sit on the
  critical circle **iff** `|λ| ≤ 2√q` (the Ramanujan bound).
- `spectrum_RH_iff_ramanujan` — lifting the equivalence to the whole spectrum:
  the zeta function satisfies RH iff the graph is Ramanujan.
- `perron_off_critical_circle` + `two_sqrt_lt_add_one` — the Perron eigenvalue
  `q+1` always produces an off-circle pole (`u = 1`), justifying the word
  "nontrivial" and matching the trivial-zero phenomenon of the classical zeta.

This extends the single-second-eigenvalue spectral-gap inequalities of
`Algebra/ExpanderWalk/Amplification.lean` and
`Algebra/ClassicalGroupExpanders.lean` into a full *biconditional* between an
analytic pole-location property and a combinatorial eigenvalue bound.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `RH_iff_ramanujan` | RH for one eigenvalue ⟺ `|λ| ≤ 2√q` | proved |
| `spectrum_RH_iff_ramanujan` | RH for spectrum ⟺ Ramanujan graph | proved |
| `critical_line_iff_critical_circle` | `Re(s)=1/2` ⟺ `|q^{-s}|=1/√q` | proved |
| `perron_off_critical_circle` | top eigenvalue gives trivial pole | proved |
| `two_sqrt_lt_add_one` | `2√q < q+1` for `q ≠ 1` | proved |

## Research Directions

### 1. The functional equation as a spectral involution

The classical zeta function obeys `ξ(s) = ξ(1−s)`. For the graph factor, the map
`u ↦ 1/(qu)` exchanges the two roots of `q·u² − λ·u + 1`, and on the critical
circle it is exactly conjugation `u ↦ ū`. The key insight is that the functional
equation `s ↦ 1−s` is *not* an external symmetry imposed on the zeta function —
it is the Vieta involution `u ↦ 1/(qu)` on the root pair, which fixes the
critical circle pointwise-as-a-set. **Conjecture:** for every eigenvalue `λ`, the
multiset of poles `{u : q u² − λ u + 1 = 0}` is invariant under `u ↦ 1/(qu)`, and
this involution is an isometry of the critical circle iff `|λ| ≤ 2√q`. This is
falsifiable: a single eigenvalue with `|λ| > 2√q` whose root pair is still
swapped isometrically would refute it. *Why now?* The two-root structure is
already fully formalized in `RH_imp_ramanujan`; the involution is one `field_simp`
away, and proving it would give the graph analog of the completed zeta's
functional equation for free.

### 2. Counting eigenvalues on the circle = counting closed non-backtracking walks

The logarithmic derivative of the Ihara zeta counts closed non-backtracking
walks (`N_m` = number of length-`m` such walks = `∑_λ` of `m`-th power-sum of the
reciprocal poles). The key insight is that the Ramanujan condition is equivalent
to **square-root cancellation** in these walk counts: `|N_m − (main term)| =
O(m · q^{m/2})` for all `m` iff every eigenvalue obeys `|λ| ≤ 2√q`. **Conjecture:**
define `N_m(λ) = u₁^{-m} + u₂^{-m}` from the two poles; then `|N_m(λ)| ≤ 2 q^{m/2}`
for all `m ≥ 1` iff `|λ| ≤ 2√q`. This is directly testable in Lean by induction on
`m` using the Newton/Chebyshev recurrence `N_{m+1} = (λ/q)·N_m − (1/q)·N_{m-1}`,
which is a clean integer-coefficient recurrence. *Why now?* It converts the
analytic RH into an explicit, computable, decidable-per-`m` inequality, opening
the door to `decide`-style verification for concrete graphs (the `n = 20, 50, 100`
random `d`-regular experiments requested in the concept).

### 3. The Alon–Boppana floor: Ramanujan is the boundary, not the interior

LPS Ramanujan graphs are *optimal*: no infinite family can beat `2√q`. The key
insight is that `2√q` is simultaneously the discriminant threshold of this file
and the Alon–Boppana lower bound, so the critical circle is a genuine *boundary*
in spectral space, not an arbitrary cutoff. **Conjecture:** for any `ε > 0` there
is no infinite family of connected `(q+1)`-regular graphs with second eigenvalue
`λ₂ ≤ 2√q − ε`; equivalently, the radius `1/√q` is the infimum over families of
the largest nontrivial pole modulus. A falsifiable Lean target: prove the finite
obstruction — for a `(q+1)`-regular graph on `n` vertices, `λ₂ ≥ 2√q · (1 −
c·log q / log n)` — which already implies the asymptotic statement. *Why now?* The
trace method (`Tr A^{2k} ≥ (number of closed walks)`) needed for Alon–Boppana
reuses exactly the closed-walk machinery of Direction 2 and the catalog's
`TraceCounting` results in `MachineLearning/TraceCounting.lean`.

### 4. Directed graphs: where the critical *circle* fattens into an annulus

For a genuinely directed graph the adjacency matrix is non-normal and its
eigenvalues `λ` are complex, so the quadratic `q u² − λ u + 1` has complex
coefficients and the two roots no longer multiply onto a single circle in a
conjugation-symmetric way. The key insight is that the directed Ramanujan
condition must replace the critical *circle* by a critical *annulus* whose width
is governed by the *non-normality* (departure from `A A* = A* A`) of the
adjacency matrix. **Conjecture:** for a `d`-out-regular digraph, all nontrivial
poles satisfy `q^{-1/2} · e^{-δ} ≤ |u| ≤ q^{-1/2} · e^{δ}` where `δ` measures
non-normality, and `δ = 0` (poles back on the circle) iff `A` is normal *and*
every eigenvalue obeys `|λ| ≤ 2√q`. This is falsifiable on small explicit
digraphs (directed cycles with chords). *Why now?* The undirected equivalence is
now a theorem; the directed case is the wide-open frontier named in the concept,
and the complex-coefficient quadratic is a small, self-contained generalization
of `iharaFactor`.

### 5. Cayley digraphs: the spectrum is the character table

For an abelian group `G` with connection set `S`, the Cayley graph's eigenvalues
are `λ_χ = ∑_{s∈S} χ(s)` over characters `χ`. The key insight is that the Graph
Riemann Hypothesis for `Cay(G,S)` becomes a statement *purely about character
sums*: it holds iff `|∑_{s∈S} χ(s)| ≤ 2√(|S|−1)` for every nontrivial character
`χ` — i.e. a Weil-type square-root-cancellation bound on a group character sum.
**Conjecture:** `Cay(ℤ/nℤ, {±1, ±g, …})` is Ramanujan iff the associated
exponential sums `∑ cos(2πk·s/n)` obey the `2√(d−1)` bound for all `k ≠ 0`, and
this fails for arithmetic progressions but holds for "Sidon-like" connection
sets. This is directly computable and falsifiable for fixed `n`. *Why now?* It
fuses this file's spectral equivalence with the catalog's character-theoretic
expander results (`Algebra/ClassicalGroupExpanders.lean`), turning a number-
theoretic conjecture into a finite character-sum verification — the most concrete
cross-domain bridge from the RH world to combinatorial group theory.
