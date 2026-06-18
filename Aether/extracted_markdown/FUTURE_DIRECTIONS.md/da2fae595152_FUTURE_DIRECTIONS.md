# Future Directions: Spectral Chain Framework

## What was established (this cycle)

The file `Computation/SpectralChain/Core.lean` builds, from first principles, a
formally verified bridge across four mathematical domains for **finite reversible
Markov chains**. Every main theorem compiles with `sorry = 0` and depends only on
the standard axioms `propext`, `Classical.choice`, `Quot.sound`.

The cornerstone object is `ReversibleChain`: a stationary distribution `π`, a
stochastic kernel `P`, and detailed balance `π_i P_ij = π_j P_ji`. On top of it we
define the edge weight `weight i j = π_i P_ij`, the stationary `mean`, the `Var`iance,
the `DirichletForm` (energy), the cut flow `flowOut`, the set measure `piSet`, and a
`SpectralGapCert` (a Poincaré certificate `γ · Var(f) ≤ E(f)`).

The proven results form a genuine geometry → spectral → probability chain:

- **`weight_symm`** — detailed balance is exactly symmetry of the edge weight.
- **`Var_eq_double_sum`** — the variance double-sum identity
  `Var(f) = ½ ∑_{i,j} π_i π_j (f_i − f_j)²`.
- **`flowOut_symm`** — the flow out of a cut equals the flow into it.
- **`DirichletForm_indicator` / `Var_indicator`** — for a set indicator the energy is
  the cut flow `flowOut(S)` and the variance collapses to `π(S)(1 − π(S))`.
- **`cheeger_easy_inequality`** — the *easy* direction of the discrete Cheeger
  inequality: any Poincaré gap obeys `γ ≤ 2 · flowOut(S)/π(S)`. This is the key
  cross-domain bridge (geometry controls spectrum).
- **`mixingBound_antitone` / `mixing_diverges_at_zero_gap`** — the spectral-gap mixing
  bound `(1/γ)·log(n/ε)` is antitone in `γ`, and diverges to `+∞` as `γ → 0⁺`: the
  structural phase-transition statement.

A concrete `twoState` chain (`π = (½,½)`, `P ≡ ½`) instantiates the framework with
real numbers, and `cheeger_hard_direction_conjecture` records the shape of the open
hard half of Cheeger's inequality as a `sorry`ed target.

---

## Direction 1: The hard direction of Cheeger's inequality

The framework proves `γ ≤ 2h` (where `h` is the conductance); the missing companion
is `h²/2 ≤ γ`, already stubbed as `cheeger_hard_direction_conjecture`. **The key
insight is** that the proof is not a certificate manipulation at all but a
*construction*: from the eigenfunction realizing the gap one extracts an ordered
level-set sweep, and a discrete co-area identity rewrites `DirichletForm(f)` as an
integral of the cut flows `flowOut({f ≥ t})` over the threshold `t`. Bounding each
level-set conductance below by `h` and applying Cauchy–Schwarz yields the quadratic
loss `h²/2`. **Why now?** The pieces it consumes — `flowOut`, `piSet`,
`DirichletForm`, `Var`, and the `SpectralGapCert` interface — are all in place and
already proven mutually compatible by `DirichletForm_indicator` and `Var_indicator`;
the only genuinely new lemma needed is the finite co-area formula
`DirichletForm(f) = ∑_t flowOut({f ≥ t}) · Δt`, which is a finite telescoping sum.

## Direction 2: Geometric (variance) contraction from the gap

The Poincaré certificate should imply quantitative convergence:
`Var(Pᵗ f) ≤ (1 − γ)^{2t} · Var(f)`, where `P` acts on observables by
`(Pf)(i) = ∑_j P_ij f(j)`. **The key insight is** that reversibility makes `P`
self-adjoint in the weighted inner product `⟨f,g⟩_π = ∑_i π_i f_i g_i`, so the
Dirichlet form is `⟨(I−P)f, f⟩_π` and the Poincaré inequality is precisely the
statement that `I − P` is bounded below by `γ` on the mean-zero subspace; one
contraction step then iterates. **Why now?** `Var`, `mean`, and `DirichletForm` are
defined exactly so that `DirichletForm(f) = ⟨(I−P)f,f⟩_π`; formalizing the weighted
inner-product space `L²(π)` over the finite `V` (a `Finset`-indexed inner product,
fully within current Mathlib) turns the spectral gap into an operator-norm bound and
unlocks the whole self-adjoint finite-dimensional toolkit.

## Direction 3: A log-Sobolev layer above the spectral gap

Mixing under a log-Sobolev constant `α` improves the bound to
`t_mix(ε) ≤ (1/2α)·log log(1/ε)`, a doubly-logarithmic speed-up over the spectral
`(1/γ)·log(n/ε)`. **The key insight is** that `α` and `γ` are *ordered*
(`α ≤ γ ≤ 2α` for product chains), so a `LogSobolevCert` structure — mirroring
`SpectralGapCert` but certifying `Ent(f²·π) ≤ (2/α)·DirichletForm(f)` via the
entropy functional `Ent(g) = ∑_i π_i g_i log g_i − (∑ π_i g_i) log(∑ π_i g_i)` — slots
directly into the existing `mixingBound` comparison machinery. **Why now?**
`mixingBound` and `mixingBound_antitone` already provide the apparatus for comparing
two mixing formulas; the analogue of `mixing_diverges_at_zero_gap` for `α` would
quantify the gap between the two regimes, and the entropy functional needs only
`Real.log` and `Finset.sum`, both already imported.

## Direction 4: Explicit gaps for small constraint-satisfaction chains

The framework currently has one numeric instance (`twoState`). The natural next test
is the swap Markov chain on small grid puzzles — 3×3 Latin squares, 4×4 Shidoku —
whose solution counts (≤ 288 for Shidoku) are tiny. **The key insight is** that for
`n ≤ 4` the transition kernel is an explicit *rational* matrix, so detailed balance,
`piSet`, and `flowOut` are decidable rational computations, and a verified Poincaré
constant can be exhibited as a `SpectralGapCert` whose `poincare` field is discharged
by finite case analysis rather than analysis. **Why now?** `ReversibleChain` and
`SpectralGapCert` are records with purely arithmetic obligations; `twoState` already
demonstrates that the obligations are dischargeable by `norm_num`, so scaling to a
genuine CSP chain is a matter of bookkeeping, and it would yield the framework's
first *non-trivial* numerical conductance / gap pair to plug into
`cheeger_easy_inequality`.

## Direction 5: Tropical lower bounds on the spectral gap

The classical gap is expensive (Cheeger optimizes over exponentially many cuts),
whereas the tropical (min-plus) eigenvalue of a structured non-negative matrix — the
minimum cycle mean — is computable in polynomial time. **The key insight is** that
for CSP transition graphs the min-plus spectral radius lower-bounds the mixing speed
through the same cut structure that `flowOut` already measures, giving combinatorial
gap certificates that bypass the worst-case quadratic loss in Cheeger. **Why now?**
The repository already contains tropical-algebra infrastructure
(`Catalog/Tropical/`, `Catalog/Computation/Spectral.lean` with `minDiag`/`tropPow`
cycle-cost bounds); bridging `ReversibleChain.weight` to a tropical matrix and
relating `minDiag` of its powers to `flowOut` would connect two independent parts of
the codebase and produce a cheap, verified lower bound feeding into a future
`SpectralGapCert`.
