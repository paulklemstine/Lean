# Future Directions: Metric Filtration Rank Profiles as Tropical Valuation Objects

These conjectures continue the research cycle begun in
`Catalog/Tropical/MetricFiltrationRankProfiles.lean`, which proves that the rank
profile `rankEndo T i k = finrank (range (transEndo T i k))` of a discrete
filtration (single–ambient–space model) is squeezed between a min-plus
submultiplicative upper bound (`rankEndo_submult`, `trop_rankEndo_submult`) and a
Frobenius/Sylvester additive lower bound (`rankEndo_sylvester`), and that the
classical TDA rank invariant `rankIv` is monotone under interval restriction
(`rankIv_mono_restrict`).

Each conjecture below is stated so that it can be turned directly into a Lean
`theorem ... := by sorry` skeleton.

## C1 — Dependent-family generalisation
The whole theory should lift from the single-ambient-space model (all spaces
equal to `V`) to a genuine persistence module `X : ℕ → Type` with step maps
`step i : X i →ₗ[K] X (i+1)`. Conjecture: with transitions defined by
`Nat.add`-recursion and the codomain transport `Nat.add_assoc ▸ ·`, the
statements `rankEndo_submult`, `rankEndo_sylvester`, and `rankIv_mono_restrict`
hold verbatim, where `finrank V` in the Sylvester bound is replaced by
`finrank (X (i+k))` (the dimension of the *intermediate* space). Testable:
formalize `structure PersMod` with instance fields and re-prove the sandwich.

## C2 — Möbius/barcode nonnegativity (structure theorem)
For `i ≤ j`, define the box (mixed second difference)
`mult T i j = rankIv T i j - rankIv T (i-1) j - rankIv T i (j+1) + rankIv T (i-1) (j+1)`.
Conjecture: `0 ≤ mult T i j` for every persistence module over a field (with the
convention `rankIv T i j = 0` for `i > j`). Equivalently, the rank invariant of a
pointwise-finite-dimensional persistence module is the cumulative-rank transform
of a nonnegative barcode multiplicity (Möbius inversion over the interval poset).
This is the formal content of "rank invariant ⟺ barcode" and would require a
two-dimensional Sylvester/diamond inequality strengthening `rankEndo_sylvester`.

## C3 — Tropical idempotency / ultrametric law for the persistent rank
Let `ρ T i = ⨅ k, rankEndo T i k` be the stable (persistent) rank from level `i`,
shown to exist by `rankEndo_eventually_const`. Conjecture: `ρ` satisfies the
tropical *idempotent* law `ρ T i = rankEndo T i k` for all `k ≥ N(i)`, and the
two-variable persistent rank `R∞ T i j := ⨅ m, rankIv T i (j+m)` is an
**ultrametric-style valuation**: `R∞ T i k ≥ min (R∞ T i j) (R∞ T j k)` reversed,
i.e. `R∞ T i k ≤ min (R∞ T i j) (R∞ T j k)` with equality whenever the middle
level `j` is past the stabilisation threshold. This pins down exactly when the
min-plus submultiplicativity `rankEndo_submult` is an equality.

## C4 — Tropical-semiring homomorphism, not merely lax
`trop_rankEndo_submult` shows `tropRank` is a *lax* (sub-multiplicative) morphism
into `Tropical (WithTop ℕ)`. Conjecture: it is a genuine semiring *homomorphism*
(equality in submultiplicativity, `rankEndo T i (k+l) = min (rankEndo T i k)
(rankEndo T (i+k) l)`) **iff** every step map `T (i+m)` for `0 ≤ m < k+l` is
either injective on the relevant image or has rank governed entirely by one
endpoint — precisely, iff no rank is lost in the "interior" of the interval.
Formalize the iff and characterize the equality locus combinatorially (it should
match the set of barcode death-times in `[i, i+k+l]`).

## C5 — Stability / Lipschitz bound in the tropical metric
Equip rank profiles with the tropical (min-plus) sup-metric
`d(R, R') = sup_{i,k} |R i k - R' i k|`. Conjecture: if two filtrations `T, T'`
have step maps that agree except at a single index `m` where
`finrank (range (T m)) = finrank (range (T' m)) ± 1`, then
`d(rankEndo_T, rankEndo_T') ≤ 1`. More generally, the rank profile is
1-Lipschitz with respect to the number of altered steps — a discrete tropical
analogue of the persistence stability theorem. Testable as a Lean theorem
bounding `|rankEndo T i k - rankEndo T' i k|` by the number of indices where the
step ranks differ.
