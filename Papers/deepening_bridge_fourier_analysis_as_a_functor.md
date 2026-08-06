# Computational Evidence

Numerical exploration carried out *before* formalisation, to test the conjectures
of each research cycle on small groups `G = ℤ/n`.  Characters are
`ψ_a(g) = e^{2πi a g / n}`, and the transform used is the one later formalised,
`𝓕f(ψ) = Σ_g f(g) ψ(−g)`.

**These are floating-point explorations, not verifications.**  Every claim listed
here that is asserted as a theorem was afterwards proved in Lean 4 with no
`sorry` (see `Catalog/Computation/FourierFunctor/`); the numbers below only
served to select which conjectures to attempt.

## 1. Uncertainty principle: minimum of `|supp f| · |supp 𝓕f|`

4000 random sparse vectors per group, entries in `{±1, ±2, 3} + i·{0, ±1}`:

| n (= \|G\|) | 2 | 3 | 4 | 5 | 6 | 8 | 9 | 12 |
|---|---|---|---|---|---|---|---|---|
| observed min product | 2 | 3 | 4 | 5 | 6 | 8 | 9 | 12 |

No counterexample to `|G| ≤ |supp f|·|supp 𝓕f|` was found, and the bound was
attained in every group — evidence both for `donoho_stark` and for its
sharpness.  (Formalised: `donoho_stark`, `donoho_stark_sharp`.)

## 2. Equality case: subgroup indicators

| G | \|K\| | \|supp 1_K\| | \|supp 𝓕1_K\| | product |
|---|---|---|---|---|
| ℤ/6 | 2 | 2 | 3 | 6 |
| ℤ/6 | 3 | 3 | 2 | 6 |
| ℤ/12 | 4 | 4 | 3 | 12 |
| ℤ/8 | 4 | 4 | 2 | 8 |

The transform of a subgroup indicator is supported exactly on the annihilator,
whose size is `|G|/|K|`.  This suggested — and is now proved as —
`fourier_indicator` and `donoho_stark_equality_subgroup`.

## 3. Fourth-power identity `𝓕²f(x) = |G|·f(−x)`

Random complex `f`, maximum deviation over all `x`:

| n | 3 | 5 | 6 |
|---|---|---|---|
| max error | 2.6e−15 | 2.4e−15 | 5.5e−15 |

(Formalised: `fourier_fourier`, `fourier_four`.)

## 4. Plancherel `Σ_ψ ‖𝓕f ψ‖² = |G| Σ_g ‖f g‖²`

| n | Σ‖𝓕f‖² | \|G\|·Σ‖f‖² |
|---|---|---|
| 4 | 9.946978 | 9.946978 |
| 7 | 36.034111 | 36.034111 |

(Formalised: `plancherel`, `plancherel_complex`.)

## 5. Poisson summation `|G|·Σ_{k∈K} f k = |K|·Σ_{ψ∈K^⊥} 𝓕f ψ`

| G | \|K\| | \|K^⊥\| | \|G\|/\|K\| | discrepancy |
|---|---|---|---|---|
| ℤ/6 | 3 | 2 | 2 | 4.4e−15 |
| ℤ/12 | 4 | 3 | 3 | 1.9e−14 |
| ℤ/8 | 2 | 4 | 4 | 4.0e−15 |

Note `|K^⊥| = |G|/|K|` in every case — evidence for `card_annihilator`, which is
the quantitative form of exactness of duality.  (Formalised:
`poisson_summation`, `card_annihilator`.)

## 6. Convolution theorem `𝓕(f ⋆ g) = 𝓕f · 𝓕g`

| n | 5 | 6 |
|---|---|---|
| max error | 2.4e−15 | 9.4e−15 |

(Formalised: `fourier_conv`.)

## 7. Counterexample hunt

* Dropping `f ≠ 0` in the uncertainty principle immediately fails
  (`0 ≥ |G|` is false); the hypothesis is kept.
* Replacing pushforward (fibrewise summation) by pullback in the source functor
  of `fourierNatIso` does not even type-check in the covariant direction — a
  structural, not numerical, obstruction; this is why the group-algebra functor
  must be covariant via integration along fibres.
* Removing the `|G|⁻¹` normalisation from the inverse transform breaks
  `fourierInv_fourier` already for `n = 2`.

## 8. OEIS

No new integer sequence arises: the quantities encountered are `|G|`, `|K|` and
`|G|/|K|`, i.e. divisors, so no OEIS lookup is informative here.

## 9. Cycles 6–7: rigidity and Gauss sums (exploration)

*As with the rest of this file, the numbers below are exploratory hand
calculations that guided the formalisation; the machine-checked statements are
the Lean theorems named in each item.*

**Extremal supports on `ℤ/12`.**  Enumerating the divisor pattern of the
uncertainty product suggested that `|supp f|` is always a divisor of `|G|` at
equality:

| candidate `|supp f|` | 1 | 2 | 3 | 4 | 6 | 12 | 5 | 7 |
|---|---|---|---|---|---|---|---|---|
| equality attainable? | yes | yes | yes | yes | yes | yes | no | no |

The "no" entries are exactly the non-divisors, which is what
`card_support_dvd_of_equality` and `donoho_stark_strict_of_not_dvd` now prove in
general; the "yes" entries are realised by the cosets of the subgroup of that
order (`donoho_stark_equality_coset`).  The converse — that these are the *only*
extremal functions — is `donoho_stark_rigidity`.

**Quadratic Gauss sums.**  With `ψ(x) = e^{2πix/N}`:

| N | 3 | 5 | 7 | 9 | 15 |
|---|---|---|---|---|---|
| `|∑_x ψ(x²)|²` | 3 | 5 | 7 | 9 | 15 |

matching `quadratic_gauss_sum_normSq` (`= N` for odd `N`).  For even `N` the
pattern fails (`N = 2` gives `0` for the non-trivial character), which is why
oddness is a hypothesis: it is exactly what makes `2` a unit of `ℤ/N`.

**Uncertainty product of the quadratic phase.**  For `N = 3, 5, 7` the function
`x ↦ ψ(x²)` and its transform are nowhere zero, so the product of support sizes
is `N²`, the maximum possible — proved in general as
`quadPhase_support_product`.

## Cycle 9 addendum: non-Fourier flat kernels

Before formalising `abstract_uncertainty` we tested, by hand on small examples,
whether the Donoho–Stark constant really tracks the *coherence* `μν` of a
kernel pair rather than the group order.  (As before, the tables below are
exploration; every claim that is actually verified is a Lean theorem.)

| kernel `k` on `n` points | entry modulus `μ` | inversion kernel `l` | `ν` | predicted bound `(μν)⁻¹` |
|---|---|---|---|---|
| Fourier matrix of `ℤ/n` | `1` | `n⁻¹ · ψ(g)` | `n⁻¹` | `n` |
| normalised Fourier matrix | `n^{-1/2}` | conjugate transpose | `n^{-1/2}` | `n` |
| `2 × 2` Hadamard | `2^{-1/2}` | conjugate transpose | `2^{-1/2}` | `2` |
| `4 × 4` real Hadamard | `2^{-1}` | conjugate transpose | `2^{-1}` | `4` |
| identity matrix (`n ≥ 2`) | `1` | identity | `1` | `1` (bound vacuous) |

The last row is the informative one: the identity is a perfectly invertible
transform with `|supp f| = |supp (T f)| = 1` available, and the abstract bound
correctly degenerates to `1 ≤ |supp f| · |supp (T f)|`.  This ruled out the
naive guess "any invertible transform obeys `n ≤ |supp f| · |supp (T f)|`" and
led to the coherence-weighted statement that was proved.

For the `2 × 2` Hadamard matrix the prediction `2 ≤ |supp f| · |supp (T f)|` was
checked on the four sparsest inputs before formalisation, and is now the theorem
`hadamard2_uncertainty`:

| `f` | `(1,0)` | `(0,1)` | `(1,1)` | `(1,-1)` |
|---|---|---|---|---|
| `|supp f|` | 1 | 1 | 2 | 2 |
| `|supp (T f)|` | 2 | 2 | 1 | 1 |
| product | 2 | 2 | 2 | 2 |

Every entry attains the bound, matching `flat_kernel_card_bound`: for a flat
kernel the bound `1 ≤ μν·|H|` is an equality, so Dirac masses are extremal.
