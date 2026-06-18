# Future Directions: The Library of Babel, Coding-Theoretic Frontier

The file `Catalog/Novelty/GilbertVarshamov.lean` closes the two-sided sandwich on code
size inside the combinatorial Library-of-Babel framework (`Word A L = Fin L → Fin A`,
Hamming metric): the **sphere-packing / Hamming upper bound** `hamming_packing`
(`|C| · V(r) ≤ A^L`) and the **Gilbert–Varshamov lower bound** `gilbert_varshamov`
(`A^L ≤ |C| · V(d-1)`), combined in `code_size_sandwich`. The structural engine is the
exact ball-volume formula `ball_card_eq` (`V(r) = Σ_{k≤r} C(L,k)(A-1)^k`, proved via the
exact sphere count `sphere_card`) together with the homogeneity result `ball_card_uniform`.
These rest on `Catalog/Novelty/BabelFoundations.lean` (`hammingDist_triangle`,
`hammingSphere`/`hammingBall`, `sphere_size_sum`). The following directions extend that
work; each is testable (it can be formalized and either proved or refuted in Lean).

## 1. The Singleton bound and MDS codes

Conjecture: for any `d`-separated code `C ⊆ Word A L` with `1 ≤ d ≤ L`, one has
`C.card ≤ A ^ (L - d + 1)`, and equality (MDS codes, e.g. Reed–Solomon) holds iff the
restriction of `C` to any `L - d + 1` coordinates is a bijection onto `Word A (L-d+1)`.
**The key insight is** that erasing `d - 1` coordinates cannot make two codewords collide,
because two distinct codewords differ in at least `d` positions, so the projection onto the
remaining `L - d + 1` coordinates is injective — turning a *metric* separation hypothesis
into a *cardinality* statement via `Finset.card_le_card_of_injOn`. **Why now?** Our
`Separated` predicate already exposes pairwise distance `≥ d`, and `hammingDist` is literally
the cardinality of the disagreement set, so the injectivity-after-projection argument is a
direct `Finset` computation with the infrastructure already in this file — no new analytic
machinery is needed.

## 2. The Plotkin bound via average pairwise distance

Conjecture: if the minimum distance satisfies `A * d > (A - 1) * L`, then any `d`-separated
code obeys `C.card ≤ A*d / (A*d - (A-1)*L)` (integer form). **The key insight is** a
double-counting of the quantity `Σ_{x,y ∈ C} hammingDist x y`: summing per coordinate, each
coordinate contributes at most `(1 - 1/A) · |C|²` to the total disagreement, while
separation forces the total to be at least `d · |C| · (|C| - 1)`; comparing the two bounds
pins `|C|`. **Why now?** The per-coordinate decomposition `hammingDist x y =
Σ_i [x i ≠ y i]` is exactly the `Finset.filter`-cardinality identity used throughout
`GilbertVarshamov.lean`, and the symbol-collision count per coordinate is a finite convexity
fact provable by `Finset` manipulation, so the only new ingredient is the algebraic
rearrangement — well within reach.

## 3. Asymptotic rate versus the entropy bound

Conjecture: with relative distance `δ = d / L` and rate `R = log_A (C.card) / L`, the
ball-volume formula yields `R ≥ 1 - H_A(δ) - o(1)` (Gilbert–Varshamov rate) where
`H_A` is the `A`-ary entropy, and the sphere-packing bound yields the matching upper
envelope `R ≤ 1 - H_A(δ/2) + o(1)`. **The key insight is** that the *proven* exact sum
`ballSize A L r = Σ_{k≤r} C(L,k)(A-1)^k` is squeezed between `A^{L·H_A(r/L)}` up to a
polynomial factor, so the entire asymptotic theory reduces to a clean entropy estimate of a
truncated binomial sum. **Why now?** We no longer have to *assume* the volume formula — it is
established as `ball_card_eq`, so the remaining task is purely the real-analytic asymptotics
of `Σ C(L,k)(A-1)^k`, for which Mathlib's `Nat.choose` bounds and `Real.log`/`Real.exp`
calculus are available.

## 4. Greedy construction achieving the Gilbert–Varshamov bound

Conjecture: for every `A, L, d` there *exists* a code `C` with `IsMaximal C d`, and hence
(by `gilbert_varshamov`) with `A^L ≤ C.card · V(d-1)`; i.e. the GV lower bound is not merely
an inequality about hypothetical maximal codes but is *attained* by an explicit greedy
process. **The key insight is** that maximality is an existence statement on the finite
lattice of subsets of `Word A L`: start from `∅` and keep inserting any word that preserves
`d`-separation; since `Word A L` is finite the process terminates at an `IsMaximal` code, so
`Finset.exists_maximal`-style well-foundedness converts our conditional bound into an
unconditional existence theorem. **Why now?** `IsMaximal` is already defined and
`gilbert_varshamov` already consumes it, so the missing piece is exactly one finiteness/
greedy-termination lemma — a self-contained induction on `Finset.card` — after which the
existence of GV-optimal codes follows for free.

## 5. Perfect codes and the equality case of sphere-packing

Conjecture: a `(2r+1)`-separated code satisfies `C.card · V(r) = A^L` (a *perfect* code,
e.g. Hamming and Golay codes) **iff** the radius-`r` balls about codewords *partition*
`Word A L` — equivalently, iff `C` is simultaneously packing-tight and a maximal
`(2r+1)`-code whose covering radius equals `r`. **The key insight is** that our two
inequalities have a shared geometric witness: `hamming_sum_bound` uses ball *disjointness*
and `gv_sum_bound` uses ball *covering*, so equality in the sphere-packing bound is precisely
the coincidence "disjoint **and** covering" = tiling, which forces `r = d - 1` and collapses
the sandwich `code_size_sandwich` to a single value. **Why now?** Both halves of the sandwich
are formalized with explicit `biUnion` cardinality reasoning, so characterizing equality is a
matter of tracking when `Finset.card_le_card` and `Finset.card_biUnion_le` become equalities
(subset becomes equality; the union’s card equals the sum) — purely combinatorial conditions
already present in the proofs.
