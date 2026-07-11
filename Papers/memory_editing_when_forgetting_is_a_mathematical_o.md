# Computational Evidence — Memory Editing

The central claims are structural (pigeonhole, submonoid closure, first
isomorphism theorem), so the evidence stage is kept brief and confirmatory.

## 1. Small cases of forced loss

Model streams over a one-letter alphabet as the natural numbers under addition
(the free monoid on one generator), and a memory `f(n) = n mod m` into `Z/mZ`
(the compressed representation, of size `m`).

- `m = 2`: streams `0` and `2` collapse (`f 0 = f 2 = 0`); shortest confused pair
  has length gap `2`.
- `m = 3`: `f 0 = f 3`, `f 1 = f 4`, etc.; every residue class is an infinite
  confused family.
- `m = 5`: `0 ≡ 5 ≡ 10 …`; number of length-`≤ ℓ` streams per class is about
  `ℓ / 5`, matching Direction 1's density heuristic `k^ℓ / n` with `k = 1`.

In every case, with the stream space infinite and the representation finite, two
distinct streams are confused — consistent with `finite_memory_forces_loss`.

## 2. Confusion is a submonoid

Using `f(n) = n mod 3`, the confused pairs `{(a,b) | a ≡ b mod 3}` are closed
under coordinatewise addition: `(0,3)` and `(1,4)` are confused, and their sum
`(1,7)` satisfies `1 ≡ 7 mod 3`. The empty pair `(0,0)` is confused. This
matches the submonoid laws proved in `confusion`.

## 3. Quotient faithfulness

For `f(n) = n mod 3`, the quotient of the naturals by the confusion congruence has
exactly three classes, and the induced map to `Z/3Z` is a bijection onto the
image — no two distinct classes share a representation. This is the finite
witness of `kerLift_lossless` / `compressedEquivQuotient`.

## 4. Sequence note

The counts of distinct representations reachable by length-`≤ ℓ` streams under a
mod-`m` memory are eventually constant at `m`, the trivial "capped at capacity"
sequence; no nontrivial OEIS entry is implicated, which is expected because the
finite-memory bound caps the reachable set at the representation size.

No counterexample to any stated theorem was found in the sampled cases.
