# Computational Evidence — Dream Logic (Deepening)

All new results concern (a) a **finite** four-element algebra `FOUR` and (b) point-set
topology of closed sets. The finite claims are decidable and were checked by exhaustive
case analysis (`cases <;> ...`, equivalently `decide`) inside Lean; the topological claims
were checked against small models. This document records the underlying data.

## 1. The bilattice `FOUR` (carrier `{tt, ff, both, neither}`)

Two orders:

* Truth order `tle`: `ff < {both, neither} < tt` (both/neither incomparable).
* Knowledge order `kle`: `neither < {tt, ff} < both` (tt/ff incomparable).

Operation tables (verified by `#eval` / case analysis):

Truth meet `tmeet` (= conjunction):

|      | tt | ff | both | neither |
|------|----|----|------|---------|
| tt   | tt | ff | both | neither |
| ff   | ff | ff | ff   | ff      |
| both | both| ff| both | ff      |
| neither| neither| ff | ff | neither |

Knowledge meet `kmeet` (= consensus ⊗):

|      | tt | ff | both | neither |
|------|----|----|------|---------|
| tt   | tt | neither | tt | neither |
| ff   | neither | ff | ff | neither |
| both | tt | ff | both | neither |
| neither | neither | neither | neither | neither |

`neg` swaps `tt↔ff`, fixes `both`, `neither`. `conf` swaps `both↔neither`, fixes `tt`,`ff`.

### Checks performed
* **Interlacing** (bilattice axioms): each of `tmeet, tjoin` is monotone for `kle`, and each
  of `kmeet, kjoin` is monotone for `tle`. Verified over all `4^4 = 256` quadruples.
* **Negation**: order-reversing for `tle`, order-preserving for `kle`; De Morgan for both
  lattices. Verified over all `4^2 = 16` pairs.
* **Designation** `{tt, both}`: a filter of the truth lattice (top ∈, upward closed, closed
  under `tmeet`). Verified over all pairs.
* **Paraconsistency**: `tmeet both (neg both) = both` is designated, but `ff` is not
  designated and is not entailed — so a contradiction is non-explosive.
* **Paracompleteness**: `tjoin neither (neg neither) = neither` is not designated.

No counterexamples to any stated identity were found in the exhaustive search.

## 2. Closed-set topology (general spaces)

Model proposition over `ℝ`: `A = [0,1]`, `pneg A = closure Aᶜ = (-∞,0] ∪ [1,∞)`.

* `A ∪ pneg A = ℝ` (excluded middle survives). ✓
* `A ∩ pneg A = {0, 1} = frontier A` (gluts = boundary). ✓
* `A` is closed but **not** open ⇒ the glut set is nonempty (paraconsistency criterion). ✓
* Family `{1/(n+1)}` converges to `0 ∉ {1/(n+1)}`; each singleton is closed but
  `⋃ₙ {1/(n+1)}` is not closed (missing limit `0`). ✓  This is the general
  `not_isClosed_iUnion_singleton_of_tendsto` instantiated on ℝ.

### Boundary case (guards against a false conjecture)
The tempting claim "no gluts anywhere ⇔ discrete space" is **false**: the two-point
indiscrete space has closed sets only `∅, univ`, both with empty frontier (no gluts), yet
is not discrete. The formal statement was therefore corrected to
"no gluts anywhere ⇔ every closed set is open" (`no_glut_everywhere_iff`).

## OEIS
No integer sequence is central to these results; the objects are a fixed 4-element algebra
and general topological spaces, so an OEIS lookup is not applicable.
