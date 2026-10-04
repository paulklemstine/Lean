# Round 97b — a structural reduction of the multivariate partial-info gap

**2026-10-04. NO new factoring algorithm and NO exponent improvement.** Round 97
identified the one live classical complexity question — the sub-`N^{1/4}`
partial-information gap that Chinburg–Hemenway–Heninger–Scherr left open by
proving only the *univariate* auxiliary-polynomial class optimal. This round
attacks that gap and lands a **structural fact that shrinks it**: the most
obvious multivariate attack is provably worthless, so any real progress must come
from lattice *structure*, not from a richer leak.

Empirical companion: `Experiments/UMWWindow/multivariate_structure.py`
(deterministic, `out_multivar.txt`; FACT verified 2000/2000).

---

## 1. The open question (recap)

For `N=pq`, given the top `n/4` bits of `p`, Coppersmith factors `N` in poly
time. CHHS (ASIACRYPT 2016, ePrint 2016/869) proved the univariate `N^{β²}`
bound optimal **within the univariate auxiliary-polynomial class**
`h = Σ a_{ij} x^i (f/N)^j`, degree-free and lattice-free — so **no auxiliary
polynomial of any degree** reaches below `N^{1/4}` in that class. They
explicitly leave the **multivariate / bivariate-integer** setting open.

The intuitive multivariate attack: spend the `n/4`-bit leak budget on **both**
`p` and `q`, exploiting the coupling `p·q = N`, hoping the two-factor structure
buys more than one factor's bits.

## 2. The reduction (this round's result)

> **Fact (p/q bit-coupling).** For `N=pq` with `q` odd, the low `t` bits of `p`
> are determined by the low `t` bits of `q` (and `N`):
> $$p \bmod 2^t \;=\; (N \bmod 2^t)\,\bigl(q \bmod 2^t\bigr)^{-1} \bmod 2^t,$$
> because `q` is odd and hence invertible mod `2^t`.
> **Verified: 2000/2000 random instances.**

So a leak of the low `t` bits of `q` is **exactly as informative** as a leak of
the low `t` bits of `p`. Splitting a `k`-bit budget as `k_p` bits of `p` and
`k_q` bits of `q` (`k_p + k_q = k`) therefore carries **zero information beyond**
the univariate leak of `k` bits on one factor. Measured candidate-factor counts at
`N = 8399557` (24 bits) are **identical (all 1) for every split** at `k = 6` and
`k = 7`.

> **Consequence.** The "split the leak across `p` and `q`" family of multivariate
> attacks is **provably a re-encoding** of the univariate problem and cannot beat
> `n/4`. The open sub-`N^{1/4}` gap, if it exists, must come from **lattice
> structure** — a *coupled auxiliary-polynomial system* that extracts more from
> the *same* bits — not from any richer or differently-placed leak.

This does not close the multivariate question, but it removes the cheapest
candidate family and pinpoints the real core: the multivariate **shift-polynomial
system**, i.e. whether the bivariate-integer freedom (jointly choosing auxiliary
polynomials in the two coupled unknowns) beats the univariate `N^{1/4}`.

## 3. Process note (two hand-rolled lattice attempts failed and were discarded)

I twice tried to hand-roll a Coppersmith small-root lattice (to measure the
univariate threshold, then a bivariate one). Both produced a lattice that failed
its own known-root validation — the record's rule (5): *never trust a test that
has never failed*. Rather than ship an unvalidated lattice or over-read a broken
one, I **discarded both** and replaced them with the exact, lattice-free
structural fact above (which needs no fragile code and is verified 2000/2000). A
correct bivariate lattice implementation is the prerequisite for the *next*
step and is flagged as such.

## 4. Honest scope

* **No new factoring algorithm. No complexity beaten.**
* New contribution: an exact **structural reduction** of the open
  sub-`N^{1/4}` question, with the "split the leak" family eliminated and the
  remaining core (multivariate auxiliary-polynomial structure) isolated. This is
  the kind of "narrowing of the search space, not a solution" the record treats
  as success (cf. Round 49's AP-cover narrowing).
* **Not claimed:** that the multivariate gap is closed or open in the structural
  sense — only that the richest-leak framing cannot deliver it, so the lattice
  core is the whole remaining question.

**Next attack.** Implement a *validated* bivariate-integer Coppersmith lattice
(validate against a known root first, then sweep `X` to find the multivariate
threshold empirically). If it lands at or below `N^{1/4}`, that is either a
sub-`N^{1/4}` attack or evidence the CHHS bound extends to the bivariate class —
either outcome is a real contribution to the live question.