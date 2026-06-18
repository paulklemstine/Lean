# Future Directions: The Tropical Determinant and the Assignment Problem

`Catalog/Tropical/TropicalDeterminant.lean` now contains a self-contained nucleus
for the tropical (min-plus) determinant over `WithTop ℤ`,
`tropDet A = minₛ ∑ᵢ A i (σ i)` — the optimal value of the linear assignment
problem. The proven results are: the single-assignment upper bound
(`tropDet_le_permSum`), attainment of the minimum (`exists_perm_eq_tropDet`),
the tropical Hadamard / row-minimum lower bound (`tropDet_hadamard`), transpose
invariance (`tropDet_transpose`), the full `Sₙ × Sₙ` row/column symmetry
(`tropDet_row_col_perm`), submultiplicativity under the min-plus matrix product
(`tropDet_submul`), the zero-diagonal/nonnegative characterization
(`tropDet_zero_diag_eq_zero`), and a closed form for additively-separable
(rank-1) cost matrices (`tropDet_separable`). Every invariance is driven by one
reindexing lemma, `tropDet_eq_inf_comp`, which says the assignment minimum is
unchanged by any bijection of the permutation group.

## 0. Adversarial result: the original "Hadamard gap ⇔ rank-1" conjecture is FALSE

The seed program (its Direction 1) conjectured that the Hadamard gap
`tropDet A − ∑ᵢ minⱼ A i j` vanishes *exactly* when `A` is tropical rank-1
(`A i j = u i + v j`, the `k = 1` case of `IsTropFactorization` in
`Catalog/Tropical/Basic.lean`). We refuted **both** implications, with formal
witnesses:

* `rankOne_gap_can_be_positive` — the rank-1 matrix `A i j = vⱼ`, `v = (0,10)`,
  has `tropDet = 10` but row-minimum sum `0`, so the gap is `10 ≠ 0`. The reason
  is structural: `tropDet_separable` gives `tropDet = ∑ᵢ uᵢ + ∑ⱼ vⱼ`, whereas the
  row-minimum bound only sees `∑ᵢ uᵢ + n·minⱼ vⱼ`; these differ unless `v` is
  constant. Rank-1 is *not* the same as "the column minimum is achievable in one
  column".
* `gap_zero_not_rankOne` — the identity-like matrix (`0` on the diagonal, `⊤`
  off) has gap `0` (`tropDet = 0` by `tropDet_zero_diag_eq_zero`) yet is not
  rank-1, because two finite diagonal entries would force a finite off-diagonal
  entry, contradicting the `⊤`s (cf. `tropFactorRank_encodeDiag` in
  `Catalog/Tropical/Basic.lean`, which shows this matrix has factor rank `2`).

This refutation reshapes the program: the gap is governed by a *combinatorial
matching* condition, not by additive separability. Direction 1 below states the
corrected, still-falsifiable conjecture; Directions 2–5 carry forward the
genuinely open extensions.

## 1. The true Hadamard-gap criterion: a Hall / SDR condition on the argmin graph

Replace the refuted rank-1 criterion with the correct one. For each row `i` let
`argminᵢ = { j : A i j = minⱼ' A i j' }` be the set of columns achieving that
row's minimum, and build the bipartite graph `G_A` with an edge `i — j` whenever
`j ∈ argminᵢ`. Conjecture: the Hadamard gap is zero **iff** `G_A` has a perfect
matching (equivalently, by Hall's theorem, every set of `k` rows collectively
touches at least `k` argmin-columns), provided all row minima are finite.

**The key insight is** that `∑ᵢ minⱼ A i j = tropDet A` forces a *single*
permutation `σ` to realize every row's minimum simultaneously — i.e. `σ` is a
system of distinct representatives for the `argminᵢ` — which is exactly a perfect
matching in `G_A`; the rank-1 case was only ever a sufficient *special* shape and
the identity-like counterexample is a non-rank-1 matrix whose `G_A` still has a
perfect matching. **Why now?** Both sides are formalized (`tropDet`,
`hadamardBound`, `tropDet_hadamard`), Hall's Marriage Theorem
(`Finset.all_card_le_biUnion_card_iff_exists_injective`) is in Mathlib, and the
two refuting witnesses already pin down what the correct statement must and must
not imply, so the equivalence can be assembled and stress-tested immediately.

## 2. Strict multiplicativity over a supertropical / ghost layer

`tropDet_submul` is the inequality `tropDet (A⊗B) ≤ tropDet A + tropDet B`. Over a
supertropical semiring, where each scalar carries a "ghost" bit recording whether
its defining minimum is attained uniquely, conjecture the inequality upgrades to
an equality `sdet (A⊗B) = sdet A + sdet B` exactly when the optimal assignments
for `A` and `B` compose without a ghost collision.

**The key insight is** that our proof of `tropDet_submul` constructs the witness
assignment `σ.trans τ` *explicitly* (using the proven `exists_perm_eq_tropDet`),
so the slack between the two sides is precisely the failure of `σ` and `τ` to be
jointly optimal — the quantity a ghost layer is designed to detect. **Why now?**
The explicit witness makes the equality condition computable, and only a small
supertropical scalar wrapper around `WithTop ℤ` needs to be added on top of the
existing `permSum`/`tropDet` machinery.

## 3. Tropical Cauchy–Binet for rectangular cost matrices

Extend `permSum`/`tropDet` to the minimum-cost *partial* assignment of `k` chosen
rows of an `n × m` matrix (an injective partial map rows → columns), and
conjecture a tropical Cauchy–Binet identity: the min-cost `k`-assignment of `A⊗B`
equals `min` over `k`-subsets `S` of the intermediate index set of
(min-cost `k`-assignment of the `A`-block on `S`) `+` (min-cost `|S|`-assignment of
the `B`-block on `S`).

**The key insight is** that the single composed assignment `σ.trans τ` used in
`tropDet_submul` generalizes to a sum over an intermediate index *subset* `S`,
exactly mirroring the classical Cauchy–Binet expansion of `det(AB)` over
`k`-subsets, with `min` replacing the field sum. **Why now?** The square case is
the `k = n = m` specialization of the already-proven `tropDet_submul`, so the
proof skeleton (pick optimal partial assignments, reindex through `S`, recombine)
is validated; only the bookkeeping for partial maps remains.

## 4. The tropical Birkhoff set and its permutation-matrix vertices

`tropDet_zero_diag_eq_zero` shows nonnegative zero-diagonal matrices satisfy
`tropDet = 0`, and `tropDet_row_col_perm` gives an `Sₙ × Sₙ` action. Define the
tropical Birkhoff set `Bₙ = { A : ∀ i j, 0 ≤ A i j ∧ tropDet A = 0 }` and
conjecture (i) `Bₙ` is closed under tropical convex combination
`(c ⊙ A) ⊕ (d ⊙ B)` with `min(c,d) = 0` (entrywise `min` of additively-shifted
matrices), and (ii) its tropical extreme points are exactly the `n!` permutation
patterns (`0` on a permutation graph, `⊤` elsewhere).

**The key insight is** that membership `tropDet A = 0` is controlled by
`tropDet_submul` and `tropDet_hadamard` under entrywise `min`, while the
permutation-pattern vertices are precisely the `tropDet_row_col_perm` orbit of the
identity-like matrix shown non-rank-1 in `gap_zero_not_rankOne`. **Why now?**
Every ingredient — `tropDet`, the symmetry action, the zero-diagonal membership
test, and a concrete permutation-pattern witness — is already proven, so only the
convex-closure lemma is open.

## 5. From determinant to spectrum: minimum mean cycle weight

The tropical eigenvalue `λ*(A) = min over cyclic permutations of (cycle weight)/
(cycle length)` is the minimum mean cycle weight of the weighted digraph of `A`.
Restricting `permSum` from arbitrary permutations to single cycles and normalizing
by length yields `λ*`. Conjecture a spectral submultiplicativity
`λ*(A⊗B) ≤ λ*(A) + λ*(B)`, and that every `A ∈ Bₙ` (Direction 4) has `λ*(A) = 0`.

**The key insight is** that every permutation decomposes into disjoint cycles, so
`permSum A σ` is literally a sum of cycle weights; the determinant optimum and the
mean-cycle optimum are two restrictions of the *same* combinatorial program, and
the per-cycle reindexing is the local analogue of the global
`tropDet_eq_inf_comp` reindexing. **Why now?** `permSum`, `tropDet_le_permSum`,
and `tropDet_eq_inf_comp` are in place, and cycle decomposition of `Equiv.Perm`
(`Equiv.Perm.cycleType`, `Equiv.Perm.cycleFactorsFinset`) is available in Mathlib,
making the restriction from permutations to cycles a concrete next step toward
tropical spectral theory.
