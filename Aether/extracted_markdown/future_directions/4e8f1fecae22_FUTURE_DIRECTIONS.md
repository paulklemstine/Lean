# Future Directions: Tropical Spectral Theory

## Synthesis

This cycle establishes the **complete spectral theorem for `2×2` min-plus
matrices** in Lean 4, in `Catalog/Tropical/SpectralEigenvalue2x2.lean`. Building
on the spectral fragment of `Catalog/Tropical/MinPlusAlgebra.lean`
(`IsTropicalEigenpair`, `tropMatVecMul`, `tropical_eigenpair_from_diagonal`), we
upgrade *sufficient conditions* for an eigenpair to a *full biconditional
characterisation*: a real number `λ` is a tropical eigenvalue of a `2×2` matrix
`A` **iff** `λ = min(A₀₀, A₁₁, (A₀₁+A₁₀)/2)`, the minimum mean over the three
simple cycles of the complete digraph on two vertices.

The proof cleanly separates the two halves of the classical max-plus/min-plus
Perron–Frobenius picture:

* an **averaging** upper bound (`tropical_eigval_2x2_le`) that holds for *every*
  eigenpair — summing the two cross inequalities cancels the eigenvector and
  pins `2λ ≤ A₀₁+A₁₀`; and
* a **critical-cycle** lower bound / existence half: each coordinate's `min`
  must be attained, forcing `λ ∈ {A₀₀, A₁₁, (A₀₁+A₁₀)/2}`
  (`tropical_eigval_2x2_unique`), and the active cycle yields an explicit
  eigenvector (`tropical_eigval_2x2_witness`).

## Results Summary

| Theorem | Statement |
| --- | --- |
| `tropMatVec2_apply` | `(A ⊗ v)(i) = min (A i 0 + v 0) (A i 1 + v 1)` on `Fin 2`. |
| `tropical_eigval_2x2_le` | Every tropical eigenvalue `λ` of `A` satisfies `λ ≤ min(A₀₀, A₁₁, (A₀₁+A₁₀)/2)`. |
| `tropical_eigval_2x2_unique` | Every tropical eigenvalue equals `min(A₀₀, A₁₁, (A₀₁+A₁₀)/2)` — uniqueness. |
| `tropical_eigval_2x2_witness` | The formula is realised by an explicit eigenvector (3 critical-cycle constructions). |
| `tropical_eigval_2x2_iff` | `(∃ v, IsTropicalEigenpair A λ v) ↔ λ = min(A₀₀, A₁₁, (A₀₁+A₁₀)/2)`. |

All five compile with `sorry = 0` and depend only on `propext`,
`Classical.choice`, `Quot.sound`.

---

## Direction 1 — The minimum-cycle-mean formula for general `n×n` matrices

**Conjecture.** For every `A : Matrix (Fin n) (Fin n) ℝ`, the (unique, for
irreducible `A`) tropical eigenvalue equals
`λ(A) = min_{k=1..n} ( (minₖ-step closed walk weight) / k )`, the minimum cycle
mean of the weighted digraph of `A`. Our `tropical_eigval_2x2_iff` is the `n=2`
instance, with the three cycles `0→0`, `1→1`, `0→1→0`.

**The key insight is** that min-plus matrix multiplication *composes shortest
walks*: `(Aᵏ)_{ii}` is the minimum weight of a length-`k` closed walk at `i`, so
`min_i (Aᵏ)_{ii} / k` ranges exactly over cycle means as `k` varies, and the
overall minimum is attained at some `k ≤ n` because any longer closed walk
decomposes into a simple cycle plus a shorter closed walk of no greater mean.

**Why now?** The `2×2` proof isolates the two mechanisms (averaging bound +
critical-cycle witness) in their simplest non-degenerate form, and the existing
`tropMatMul_assoc` in `MinPlusAlgebra.lean` already gives the associativity
needed to define `Aᵏ` unambiguously. The concrete next step is a lemma
`minPlusPow_diag_eq_min_closed_walk` proved by induction on `k`, after which the
`n×n` eigenvalue theorem reduces to the combinatorial "cycle-decomposition"
inequality. **Falsifiable:** a single random `3×3` matrix where the eigenvalue
(computed by power iteration) differs from `min_{k≤3} tr⊗(Aᵏ)/k` refutes it.

## Direction 2 — Eigenvalue is the limit of normalised iterate averages

**Conjecture.** For irreducible `A` and any start `x`, the iterate average
`(tropMatVecMul-iterate A x k)(i) / k → λ(A)` as `k → ∞`, uniformly in `i`, with
`λ(A) = min(A₀₀, A₁₁, (A₀₁+A₁₀)/2)` in the `2×2` case. This is the *cycle-time
theorem* of discrete-event systems and connects directly to the throughput
results in `Catalog/Tropical/Throughput.lean`.

**The key insight is** that once an eigenvector `v` exists (which we now prove
unconditionally for `n=2`), translation equivariance of `tropMatVecMul`
(`tropMatVecMul_shift` in `MinPlusAlgebra.lean`) sandwiches an arbitrary start
`x` between `v + c₋` and `v + c₊`; iterating each adds exactly `kλ`, so the
average is squeezed onto `λ`.

**Why now?** We have eigenvector *existence* (`tropical_eigval_2x2_witness`) and
the shift lemma already in the catalog, which are exactly the two ingredients a
squeeze argument needs. The next step is `tropIterate_average_tendsto`, a
`Filter.Tendsto` statement provable from a two-sided `|iterate - kλ - v| ≤ C`
bound. **Falsifiable:** any `2×2` example where the simulated average converges
to something other than `min(A₀₀, A₁₁, (A₀₁+A₁₀)/2)` refutes it.

## Direction 3 — Tropical determinant multiplicativity (Cauchy–Binet)

**Conjecture.** Define `tdet(A) = min_{σ ∈ Sₙ} Σᵢ A_{i,σ(i)}` (the optimal
assignment cost). Then `tdet(A ⊗ B) = tdet(A) + tdet(B)`, i.e. the tropical
determinant is multiplicative for min-plus matrix product. For `n=2` this reads
`tdet(A⊗B) = min(A₀₀,A₀₁+...) ... = tdet A + tdet B` and is checkable by hand.

**The key insight is** that a permutation of the product `A⊗B` routes each row
through an intermediate vertex, and `minPlus`-associativity lets the
`(σ,τ)`-decomposition telescope: the optimum assignment of `A⊗B` factors as an
optimum assignment of `A` followed by one of `B`, because composing two
permutations is again a permutation and any other routing is sub-optimal.

**Why now?** `tropMatMul_assoc` and the `Finset.inf'` / `Finset.exists_min_image`
API exercised in this cycle are precisely the tools for an induction over
`Equiv.Perm (Fin n)`. Start with `n=2` (a four-case `min` identity, well within
`grind`/`linarith`), then generalise. **Falsifiable:** any random `A,B` with
`tdet(A⊗B) ≠ tdet A + tdet B` refutes it.

## Direction 4 — Critical-graph classification of the eigenvector cone

**Conjecture.** The set of tropical eigenvectors for the eigenvalue
`λ(A)`, together with `−∞`-padding, forms a tropical cone whose dimension equals
the number of strongly connected components of the *critical graph* (edges lying
on minimum-mean cycles). For `2×2`: the eigenvector is unique up to an additive
constant **iff** the critical graph is strongly connected, which happens exactly
when the `2`-cycle `0→1→0` is the unique critical cycle (`(A₀₁+A₁₀)/2 < A₀₀, A₁₁`).

**The key insight is** that our three witness constructions in
`tropical_eigval_2x2_witness` are *exactly indexed by the critical cycle*: a
self-loop being critical decouples a vertex (giving a free additive parameter and
hence a 2-dimensional cone), whereas the strict `2`-cycle case rigidly links the
two coordinates via `v₁ - v₀ = (A₁₀-A₀₁)/2` (a 1-dimensional cone).

**Why now?** The case split is already explicit in the proof; promoting it to a
theorem `eigenvector_unique_iff_twoCycle_strict` only requires formalising "unique
up to additive constant" as `∀ v w, IsTropicalEigenpair A λ v → IsTropicalEigenpair A λ w → ∃ c, ∀ i, w i = v i + c`.
**Falsifiable:** exhibiting two `2×2` eigenvectors differing non-constantly while
the `2`-cycle is the strict minimum would refute it.

## Direction 5 — Tropical Cayley–Hamilton / power stabilisation

**Conjecture.** For `A` normalised so that `λ(A) = 0` (subtract the eigenvalue
from every entry), the min-plus power sequence stabilises: `Aⁿ = Aⁿ⁻¹` after at
most `n` steps for irreducible `A`. For `2×2` this is `Ã² = Ã` once
`min(Ã₀₀, Ã₁₁, (Ã₀₁+Ã₁₀)/2) = 0`, the tropical analogue of Cayley–Hamilton.

**The key insight is** that after normalisation every cycle mean is `≥ 0`, so no
closed walk can strictly improve on a shorter one; any walk of length `> n` must
revisit a vertex and can be short-circuited without increasing weight, capping
the effective shortest-walk length at `n`.

**Why now?** Normalisation is just `A - λ·1`, and our `tropical_eigval_2x2_iff`
delivers `λ` in closed form, so the `2×2` instance becomes a finite `min`
identity provable by `grind`/`linarith` after the entries are shifted. The
general statement then needs a "no-improving-long-walk" lemma, the same
combinatorial core as Direction 1. **Falsifiable:** a normalised irreducible
`A` with `Aⁿ ≠ Aⁿ⁻¹` refutes it.
