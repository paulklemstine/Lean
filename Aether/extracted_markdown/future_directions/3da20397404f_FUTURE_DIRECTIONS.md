# FUTURE_DIRECTIONS — Zeta Functions of Directed Graphs and the Graph Riemann Hypothesis

## Synthesis

This cycle settled the *spectral core* of the Graph Riemann Hypothesis and, crucially, located
exactly where the directed theory diverges from the classical undirected one. The central
discovery is that the "Riemann Hypothesis ⟺ Ramanujan" equivalence for the Ihara zeta is, at the
level of a single eigenvalue, **a discriminant-sign statement about a quadratic**: the Ihara
factor `q u² − λ u + 1` has both roots on the critical circle `|u| = q^{-1/2}` (i.e.
`normSq u = q⁻¹`) **iff** `λ² ≤ 4q`. The famous Ramanujan constant `2√q` is nothing more than the
threshold `λ² = 4q` at which the discriminant of this quadratic changes sign; below it the two
roots are complex conjugates of equal modulus `1/√q`, above it they are distinct reals of unequal
modulus. We proved this equivalence in full (`ihara_factor_root_RH_iff_ramanujan`) and globalised
it over an arbitrary real spectrum (`ihara_RH_iff_ramanujan_spectrum`), recovering the
Lubotzky–Phillips–Sarnak setting.

The decisive structural insight came from the Critic. The naive way to "go directed" is to keep
the same quadratic but allow complex `λ` and replace `λ² ≤ 4q` by the disk bound
`normSq λ ≤ 4q`. We proved this is **false** (`directed_ramanujan_naive_extension_false`): the
purely imaginary eigenvalue `λ = 2i` (with `q = 1`) satisfies the disk bound yet sends the root
`u = i(1+√2)` off the critical circle. The reason is sharp: the `⇐` direction in the real case
relied on `conj u` being the *second* root, pairing the two roots into a conjugate pair of equal
modulus; a non-real `λ` destroys this pairing. This tells us the correct directed Riemann
Hypothesis is governed by the **Bowen–Lanford zeta** `det(1 − u·A)⁻¹`, whose poles are the inverse
eigenvalues, and whose RH is the clean *circle* condition `normSq λ = q` — which we proved exactly
(`digraph_bowen_lanford_RH_iff_circle`), with no regularity or reality hypothesis at all.

The remaining mystery is therefore **combinatorial, not analytic**: for the Bowen–Lanford zeta the
RH is elementary, so all the depth of the directed Ramanujan problem is hidden in the question of
*which directed graphs have their non-Perron spectrum on the circle* `|λ| = √(d−1)`. We isolated
this as the cycle's open conjecture (`directed_ramanujan_conjecture`), stated over the genuine
complex spectrum of a `d`-out-regular adjacency matrix. The general-multiset version is provably
false (§5), so any proof *must* exploit the rigidity of nonnegative integer matrices with constant
row sums — i.e. Perron–Frobenius structure. That is the single missing ingredient the next cycle
should attack.

## Results Summary

- `bowen_lanford_zeta_inv_eq_zero_iff`: proved — the directed (Bowen–Lanford) zeta reciprocal
  vanishes exactly at inverse eigenvalues, giving the poles ↔ eigenvalues dictionary.
- `digraph_bowen_lanford_RH_iff_circle`: proved — directed-graph RH holds iff every nonzero
  eigenvalue lies on the critical circle `normSq λ = q` (fully general complex spectra).
- `ramanujan_imp_circle`: proved — Ramanujan bound `λ² ≤ 4q` forces every Ihara-factor root onto
  the critical circle (the `⇐` half of the heart theorem).
- `circle_imp_ramanujan`: proved — roots on the critical circle force the Ramanujan bound (the
  `⇒` half, via an explicit positive-discriminant counterexample construction).
- `ihara_factor_root_RH_iff_ramanujan`: proved — **the heart**: single-eigenvalue Ihara RH ⟺
  Ramanujan `λ² ≤ 4q`, exposing `2√q` as a discriminant threshold.
- `ihara_RH_iff_ramanujan_spectrum`: proved — the global undirected/Hermitian Ramanujan-graph
  equivalence over a whole real spectrum.
- `directed_ramanujan_naive_extension_false`: disproved (negation proved) — the naive complex
  disk-bound extension fails; witness `λ = 2i`, `q = 1`, root `i(1+√2)`.
- `directed_ramanujan_conjecture`: conjecture (`sorry`) — the genuine directed Ramanujan bridge:
  for a `d`-out-regular digraph, spectrum-on-circle ⟺ disk bound `normSq λ ≤ 4(d−1)`.

## Research Directions

### Direction 1: Perron–Frobenius rigidity for the directed Ramanujan bridge
**Hypothesis**: For a `d`-out-regular digraph adjacency matrix (nonnegative integer entries,
constant row sums `d`), every non-Perron eigenvalue satisfies `normSq λ ≤ 4(d−1)` **iff** every
non-Perron eigenvalue satisfies `normSq λ = d−1` — i.e. the disk bound and the circle condition
coincide on genuine digraph spectra (`directed_ramanujan_conjecture`).
**Test**: Discharge the `sorry` using Perron–Frobenius (Mathlib's `Matrix` spectral API) to pin the
Perron root at `λ = d` and bound the rest; or *disprove* it by exhibiting a small explicit `0/1`
circulant whose spectrum lands strictly inside the disk but off the circle.
**Why now**: This cycle reduced the entire problem to exactly this combinatorial rigidity — the
analytic half is fully proved and the general-multiset version is already shown false, so the only
remaining lever is matrix integrality + constant row sums.
**The key insight is** that the directed Ramanujan condition cannot be the disk `|λ| ≤ 2√(d−1)`
(§5 kills that); it must be the circle `|λ| = √(d−1)`, and digraph integrality is what could force
the two to agree.
**If true**: a purely combinatorial Riemann Hypothesis for directed graphs, computable from the
adjacency matrix alone.
**If false**: the counterexample pinpoints the smallest digraph separating "RH" from "Ramanujan",
seeding a refined (weaker) combinatorial invariant.

### Direction 2: Circulant / directed-Cayley spectra as an exactly solvable laboratory
**Hypothesis**: For a directed Cayley graph of a finite abelian group with connection set `S`, the
eigenvalues are the character sums `∑_{s∈S} χ(s)`, and the Bowen–Lanford RH (`normSq λ = |S|−1`
for non-trivial `χ`) holds iff `S` is a "perfect difference-like" set making all non-trivial
character sums equimodular.
**Test**: Specialise `digraph_bowen_lanford_RH_iff_circle` to the character-sum spectrum and
search computationally over small abelian groups (`ℤ/n`, `n ≤ 100`) for connection sets achieving
the circle condition; formalise the cyclic case `ℤ/n` where eigenvalues are `∑ ω^{s}`.
**Why now**: `digraph_bowen_lanford_RH_iff_circle` already reduces RH to a clean circle condition
on eigenvalues, and for abelian Cayley graphs those eigenvalues are explicit character sums.
**The key insight is** that for abelian digraphs the spectrum is *combinatorially transparent*, so
the RH circle condition becomes a concrete equimodularity statement about character sums.
**If true**: an infinite explicit family of directed Ramanujan graphs with provable RH.
**If false**: shows abelian symmetry is too rigid, pushing the search to non-abelian Cayley graphs.

### Direction 3: The boundary case `λ² = 4q` and zeta multiplicities
**Hypothesis**: At the Ramanujan boundary `λ² = 4q` the Ihara factor has a *double* root at the
real point `u = λ/(2q)` on the critical circle, so the boundary eigenvalues are precisely those
producing higher-order zeros of the zeta function on the critical line.
**Test**: Strengthen `ihara_factor_root_RH_iff_ramanujan` to track root multiplicity — prove that
`λ² = 4q` ⟺ the factor is a perfect square `q(u − λ/(2q))²`, and `λ² < 4q` ⟺ two simple conjugate
roots.
**Why now**: the `⇐` proof already isolates the real double-root case `λ² = 4q`; promoting it to a
multiplicity statement is a short formal step from what is proved.
**The key insight is** that the Ramanujan *equality* is exactly the locus of repeated zeta zeros —
the graph analog of a multiple zero of the Riemann zeta on the critical line.
**If true**: a clean dictionary between eigenvalue degeneracy and zeta-zero order.
**If false**: reveals a subtlety in the `u`-to-`s` change of variables worth formalising.

### Direction 4: From single factor to the full Ihara determinant `(1−u²)^{r−1}∏(qu²−λu+1)`
**Hypothesis**: The "trivial zeros" of the Ihara zeta are exactly the roots of `(1−u²)^{r−1}`
(at `u = ±1`), and the full RH — all *non-trivial* zeros on the critical circle — is equivalent to
`ihara_RH_iff_ramanujan_spectrum` applied to the adjacency spectrum, with the trivial factor
contributing only `u = ±1`.
**Test**: Define the full reciprocal zeta as a product `(1−u²)^{r−1} * ∏ iharaFactor` over the
spectrum, prove its zero set decomposes as `{±1} ∪ ⋃_λ roots(iharaFactor)`, and derive global RH.
**Why now**: `bowen_lanford_zeta_inv_eq_zero_iff` already gives the product-zero machinery; the
Ihara product needs the same `Multiset.prod_eq_zero_iff` plus the proved factor analysis.
**The key insight is** that separating the trivial factor `(1−u²)^{r−1}` from the eigenvalue
factors is what makes "non-trivial zeros" a precise, checkable notion.
**If true**: a complete formal statement of the Ihara-zeta RH, not just its eigenvalue core.
**If false**: identifies an eigenvalue (e.g. `±2√q` colliding with `u=±1`) where trivial and
non-trivial zeros interact.

### Direction 5: Quantitative spectral gap and the Alon–Boppana boundary
**Hypothesis**: For an infinite family of `d`-regular graphs, the second-largest `|λ|` cannot stay
below `2√(d−1) − ε` for fixed `ε > 0` as `n → ∞` (Alon–Boppana), so Ramanujan graphs sit exactly
at the RH boundary of Direction 3, and "near-RH" zeta zeros approach the critical circle at an
optimal rate.
**Test**: Formalise an Alon–Boppana lower bound on `max_{λ≠d}|λ|` via trace growth
`tr(A^{2k}) ≥ (#closed walks)`, then read it through `ihara_factor_root_RH_iff_ramanujan` as a
statement that zeta zeros cannot retreat from the critical circle.
**Why now**: the eigenvalue↔zeta-zero dictionary is now a proved equivalence, so any spectral-gap
bound transfers verbatim into a statement about zeta zeros.
**The key insight is** that Alon–Boppana is the graph analog of a *zero-free region*: it forbids
zeta zeros from moving strictly inside the critical circle, mirroring zero-free regions for the
classical zeta.
**If true**: connects optimal spectral gaps to optimal zero-distribution, closing the analogy with
analytic number theory.
**If false**: an over-Ramanujan family would be a sensational counterexample worth isolating.
