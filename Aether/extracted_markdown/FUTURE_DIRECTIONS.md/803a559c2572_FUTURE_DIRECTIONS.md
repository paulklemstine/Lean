# Future Directions — Reverse Mathematics of Ramsey's Theorem

This cycle formalized, with complete proofs and no `sorry`, the combinatorial
core of `RT²₂` in `Catalog/Logic/ReverseMathRamsey.lean`:

* `infinite_pigeonhole_bool` / `infinite_pigeonhole` — the infinite pigeonhole
  principle `RT¹` for `Bool` and for `Fin k`;
* `infinite_ramsey_pairs` — `RT²₂`, every two-colouring of the pairs of `ℕ`
  admits an infinite homogeneous set, via the classical pivot construction
  (`pt`, `color`, `seqSet`, `color_pt`);
* `RT2_imp_RT1` — the easy reversal `RT²₂ ⟹ RT¹₂`, proved as a genuine proof
  transformation (not via the standalone pigeonhole lemma).

These extend the catalog's finite Ramsey work (`HypergraphRamsey`,
`hyper_ramsey_counting_lower_bound`, `RamseyProp_*` in `Algebra/Recursion.lean`)
from the finitary, counting side to the infinitary, set-existence side that
reverse mathematics actually classifies. The following directions are testable
and falsifiable: each predicts a specific Lean statement that should (or should
not) be provable from the foundations laid here.

## 1. The full infinite Ramsey theorem `RTⁿ_k` by induction on exponent

Conjecture: the statement "every `k`-colouring of the `n`-element subsets of `ℕ`
has an infinite homogeneous set" is provable for all `n, k` by induction on `n`,
with the base case `n = 1` being `infinite_pigeonhole` and the step reusing the
`seqSet`/`pt` pivot machinery with the inductive hypothesis applied to the
"link" colouring `c'(s) = c(pt n :: s)`. The key insight is that the entire
inductive step is *already present* in `color_pt`: the colour attached to a
pivot is exactly a lower-arity colouring of the remaining pivots, so the present
file is the `n = 2` instance of a uniform recursion. Why now? With `RT²₂` closed
constructively and the pivot recursion isolated as reusable lemmas, the
exponent induction is a mechanical generalization rather than a new idea, and it
would give Mathlib its first infinite Ramsey theorem at arbitrary arity.

## 2. Stable Ramsey `SRT²₂` and the `COH` decomposition `RT²₂ ↔ SRT²₂ + COH`

Conjecture: define a colouring `c` to be *stable* if `fun j => c i j` is
eventually constant for each `i`; then (a) `SRT²₂` (Ramsey restricted to stable
colourings) is provable directly from `infinite_pigeonhole` applied to the
limit colour `lim_j c i j`, and (b) `RT²₂` is equivalent over a cohesive
principle `COH` to `SRT²₂`. The key insight is that on a *cohesive* set every
two-colouring becomes stable, so the hard content of `RT²₂` factors cleanly into
a "cohesiveness" step (build the cohesive set) and a "stable" step (pigeonhole on
limits). Why now? Our `seqSet` construction already produces a tower of nested
infinite sets — exactly the data a cohesive set is assembled from — so the
factorization can be read off the existing definitions, making the
Cholak–Jockusch–Slaman decomposition formalizable without new combinatorics.

## 3. Non-implication `RT¹ ⇏ RT²₂` and the Seetapun separation `RT²₂ ⇏ ACA₀`

Conjecture: there is no proof of `infinite_ramsey_pairs` from
`infinite_pigeonhole` alone (relative to a base theory), and, sharper, `RT²₂`
does not imply arithmetical comprehension. A falsifiable Lean proxy: exhibit a
*computable* colouring all of whose infinite homogeneous sets compute `0'`
fails — i.e. formalize Seetapun's construction of a computable `c` with a
homogeneous set that does not compute the halting problem. The key insight is
that homogeneous sets can be kept "low" by forcing with finite conditions, so
the jump of a homogeneous set need not exceed `0'`. Why now? The reversal
`RT2_imp_RT1` shows the *easy* direction is a one-line transformation; the
contrast makes the genuine logical gap precise and motivates encoding Turing
reducibility (available via `Computation/` in the catalog) against our explicit
`pt`/`color` witnesses.

## 4. Computable bounds on homogeneous sets: a `low₂` / `Δ⁰₃` witness

Conjecture: for computable `c`, the homogeneous set produced by
`infinite_ramsey_pairs` is `Δ⁰₃`, and can be improved to `low₂`
(Cholak–Jockusch–Slaman). A testable formal target: replace `Classical.choice`
in `exists_color`/`col` by an explicit `Nat.rec`-definable selection (least
colour with an infinite class, decided along a `Σ⁰₂` predicate) and prove the
resulting `pt` is `Δ⁰₃`-definable. The key insight is that the only
non-effective step in our proof is the choice of `col`, and that choice is a
single bit decidable from a `Σ⁰₂` question about `c`, so the construction is
arithmetically definable at a bounded level. Why now? The proof is already
*structured* around one choice per stage (`col c (seqSet c n)`); quantifying its
logical complexity is a direct audit of one definition rather than a rebuild.

## 5. Finite Ramsey from infinite via compactness — bridge to the catalog bounds

Conjecture: the finite Ramsey theorem (the existence of `R(k,k)` underlying
`hyper_ramsey_counting_lower_bound` and `RamseyProp_choose`) follows from
`infinite_ramsey_pairs` by a König's-lemma / `WKL₀` compactness argument,
yielding a *non-constructive* existence proof to sit alongside the catalog's
explicit counting bounds. A falsifiable target: prove `∀ k, ∃ N, RamseyProp N k`
using `infinite_ramsey_pairs` plus compactness of `2^{[N]²}`, and check the two
proofs agree on small values via `decide`. The key insight is that an infinite
homogeneous set, truncated, certifies arbitrarily large finite homogeneous sets,
so finiteness is recovered by compactness rather than by counting. Why now? The
catalog already contains both the finite Ramsey predicate (`RamseyProp`) and the
infinite theorem proved here, so the bridge connects two existing, independently
verified bodies of work — exactly the cross-domain synthesis that maximizes
value.
