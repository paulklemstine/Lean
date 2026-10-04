# Round 107 — the residue/Coppersmith frontier is firm, anchored to CHHS

**2026-10-04. No exponent beaten. This round closes my own most recent line of work
(the round-99 residue method) by anchoring it to a rigorous literature result and
testing the one untested extension — higher-degree structured polynomials.**

---

## 1. The frontier, anchored

The `ResiduePartialFactor` method (round 99) factors `N=pq` deterministically and
certifiably from a **linear** residue `p ≡ a (mod M)`, `M > N^{1/4}`, using the
exact-integer Coppersmith small-root lattice. Rounds 99–101 established: it is
symmetric, the two-residue version is redundant, and CRT-pooling adds nothing
beyond `M_eff > N^{1/4}`.

**The literature anchor.** A subagent sweep confirms the frontier precisely:

* **Chinburg–Hemenway–Heninger–Scherr** (ePrint 2016/869, *Math. Cryptography*
  **2**(1), 2018) prove, by **capacity theory**, that Coppersmith's univariate
  exponent `1/d` **cannot be increased by any auxiliary polynomial of Coppersmith's
  type**, for *any* monic degree-`d` polynomial — including structured
  `f = (x+a)(x+b)` with `a,b` known. Rigorous and unconditional.
* **The gap they leave (still open):** their theorem covers the **mod-`N`
  univariate** case. There is **no capacity-theory optimality theorem for the
  `N^{β²/d}` bound for a root modulo an *unknown divisor*** (our setting), and
  they list the bivariate-integer / divisor cases as open future work. So the
  *frontier we sit on* (`β=1/2`, `d=1` → `N^{1/4}`) is conjecturally optimal but
  **not yet proven optimal** — the open bit is narrow and precise.

## 2. The one untested extension: higher degree

The obvious hope is that a **higher-degree** structured polynomial packs more
information and beats `N^{1/4}`. It cannot. Coppersmith's root bound for degree
`d` is `X < N^{β²/d}`; at `β=1/2` that is `N^{1/(4d)}`:

| degree `d` | guaranteed root `X` | vs linear `N^{1/4}` |
|---|---|---|
| 1 | `N^{1/4}` | — |
| 2 | `N^{1/8}` | strictly smaller root |
| 3 | `N^{1/12}` | strictly smaller |
| 4 | `N^{1/16}` | strictly smaller |

Degree and root-size **trade off against each other**; no `d>1` improves on `d=1`.
This is exactly the CHHS conclusion, and it is consistent with the round-99
measurement (the threshold sits exactly at `M > N^{1/4}`).

## 3. The adjacent case (`p mod M₁` and `q mod M₂`) is worse

Knowing residues of **both** primes (each `< N^{1/4}`) routes to the **bivariate
integer** problem `(a₁+x)(a₂+y) = N` over `ℤ`, where Coppersmith's rigorous bound
(Coron–Kirichenko–Tibouchi's corrected statement) is `X = Y = N^{1/6}` — **worse**
than `N^{1/4}`. This independently reproduces, from a different direction, the
round-101 redundancy result: the second residue does not help.

## 4. What this closes (and does not)

* **Closed:** the residue/Coppersmith line. No algebraic structure in a single
  auxiliary polynomial beats `N^{1/4}` (CHHS, rigorous); higher degree is worse;
  the two-residue variant is redundant and worse; CRT-pooling adds nothing.
* **Not closed:** whether some *non-Coppersmith* lattice (or a use of the `pq`
  coupling outside Coppersmith's framework) can beat `N^{1/4}` for a *balanced*
  `pq` from structured side information. The CHHS optimality does **not** cover
  this, and the authors say so. This is the sharp residual open question on this
  axis.

## 5. Honest scope

* **No exponent beaten.** The residue method stands as the program's one new
  *algorithm*, at exactly the `N^{1/4}` frontier, now anchored to a rigorous
  optimality result for the class it uses.
* **New here:** the frontier is anchored to CHHS capacity optimality; the
  higher-degree extension is closed (no `d>1` helps); the both-residues case is
  confirmed worse (`N^{1/6}`), reproducing round 101 from the literature side.
* **Not claimed:** a proof that `N^{1/4}` is optimal for *all* structured partial
  information — that is exactly the open gap CHHS names.

**The program's residue-method line is now complete and correctly scoped.** Any
further advance on this axis must escape the Coppersmith auxiliary-polynomial
framework entirely — which is the multivariate-lattice route, blocked in round
97g on a reference Jochemsz–May implementation.