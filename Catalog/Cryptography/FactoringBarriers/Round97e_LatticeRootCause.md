# Round 97e — the multivariate gap is irreducibly a lattice question

**2026-10-04. NO new factoring algorithm and NO exponent improvement.** This round
(a) root-causes the Coppersmith lattice failures of 97c/97d, (b) corrects a
mis-framing I introduced mid-round, and (c) sharpens the open question to its
irreducible core.

Empirical companion: `Experiments/UMWWindow/coppersmith_lattice.py`
(deterministic, `out_cop.txt`); the architectural diagnosis is in the file
docstring.

---

## 1. Root cause of the lattice failures (97c → 97d → here)

Three separate issues, each found by instrumenting:

1. **The "hangs" were not the lattice.** They were a slow **trial-division**
   `is_prime()` (O(√n) per candidate ⇒ ~2³² ops for a 64-bit prime). With
   Miller–Rabin primality the shift-polynomial + `fpylll` skeleton is instant.
   *Mis-diagnosis cost rounds 97c–97d.*
2. **The Howgrave–Graham scaling is not the bug.** I suspected the `X^{D−k}` vs
   `X^k` (Cauchy–Schwarz) direction; tested both — identical (both give 0
   vanishing rows). Not the cause.
3. **The real bug is architectural: evaluating the SCALED row.** The lattice is
   built from *scaled* rows `c_k·X^k` (or `c_k·X^{D−k}`); those are a
   metric device, not polynomials in `x`. My validation evaluated the **scaled
   vector** at `x_0` — but scaling changes the polynomial, so `eval(scaled,x_0)`
   is nonzero even when the underlying lattice element vanishes at `x_0`. A
   correct implementation must either (a) recover the *unscaled* polynomial via
   the LLL **transformation matrix** (each reduced row is a linear combination of
   the original rows), or (b) root-find on the reduced vectors directly when the
   scaling is the identity. I confirmed the **pre-LLL rows all satisfy
   `g(x_0) ≡ 0 (mod N)`** — the lattice itself is correct; only my recovery path
   was wrong.

Even with the transformation-matrix reconstruction, Coppersmith's guarantee needs
`m, t` scaled to `≈ N^{β/d}`, a regime I did not reach within this session's
budget. So the lattice remains **unvalidated**, and per rule (5) I still make no
quantitative claim from it.

## 2. A correction I owe the record

Mid-round I framed the `n/4` wall as **information-theoretic** ("below `n/4`
known bits the top bits do not uniquely determine `p` among divisors"). I then
tested it and it is **false**: for a semiprime `N=pq`, the interval of numbers
sharing the top `k` bits of `p` (length `X = 2^{n/2−k} < p`) contains **only
`p`**, because any second divisor of `N` in that window would share bits with `p`
yet be coprime to it — impossible. Measured: `1` consistent divisor at every `k`
tested (`k=1…n/4`, `n=40,48`).

> **Correction:** raw uniqueness of the factor from its top bits is **never** the
> binding constraint for a semiprime. The `n/4` wall is **purely a lattice-
> solving phenomenon** — *only* Coppersmith's method breaks the genuine ambiguity
> of `f(x)=x+p_0 ≡ 0 mod p` at exactly `X < N^{β²}`. This is exactly why
> CHHS could prove it **degree-free and lattice-free**: the wall is a statement
> about the existence of a short auxiliary polynomial, not about information.

## 3. Sharpening of the open question (the round's contribution)

Combined with round 97b (`p/q` bit-coupling ⇒ splitting the leak is a
re-encoding), the open multivariate sub-`N^{1/4}` gap is now pinned precisely:

* It is **not** a richer-leak question (97b: excluded).
* It is **not** a raw-information question (this round: excluded — uniqueness is
  free).
* It is **irreducibly a lattice question**: does a **coupled multivariate
  auxiliary-polynomial system** — jointly chosen shift polynomials in the two
  coupled unknowns, exploiting `p·q=N` — admit a short-enough combination to
  reach `|x| < N^{1/4}` on **fewer than `n/4` known bits**?

This is the sharpest statement of the live problem the record now carries, and it
explains why no combinatorial or information-theoretic probe can advance it: the
obstacle is the *geometry of the shift-polynomial lattice*, and the only valid
instrument is a correct LLM-based solver.

## 4. Honest scope

* **No new factoring algorithm. No complexity beaten.** The multivariate gap is
  neither closed nor attacked quantitatively.
* New: a precise root-cause for the lattice failures (§1), a self-correction of
  a mis-framing (§2), and a sharp reduction of the open question to its lattice
  core (§3).
* **Not claimed:** the multivariate gap is open/solved. Only that the two cheap
  routes to it (richer leak, raw information) are both excluded.

**Next attack.** One of:
1. Implement a **validated** Coppersmith lattice with `m,t ~ N^{β/d}` and the
   transformation-matrix recovery path (§1.3), OR adopt a reference implementation
   (PARI/Sage/Coq `small_roots`). This unblocks the quantitative threshold.
2. Given a validated univariate lattice, build the **coupled bivariate** system
   and sweep `X` for the multivariate threshold. Below `N^{1/4}` ⇒ a sub-`N^{1/4}`
   attack; at `N^{1/4}` ⇒ CHHS extends to the bivariate class. **Either is a
   real contribution to the live question.**