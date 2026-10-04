# Deterministic Factoring from Prime-Residue Leakage: A New Realization of the n/4 Frontier, and Its Exact Boundary

**A research paper (Factoring round 100). Companion: `GAPGcd.lean` (machine-checked),
`Experiments/UMWWindow/residue_partial_factor.py` (validated). No balanced-semiprime
exponent is improved; the frontier is characterized exactly.**

---

## Abstract

Partial-information factoring with `n/4` known bits of `p` factors `N=pq`
deterministically in polynomial time, and this threshold is provably optimal in
the univariate auxiliary-polynomial class (Chinburg–Hemenway–Heninger–Scherr,
ASIACRYPT 2016). We exhibit a **new deterministic, certifiable algorithm** that
reaches the *same* `N^{1/4}` frontier from a **different leakage model**: the
residue of `p` modulo a known modulus `M` (`p ≡ a mod M`), i.e. *scattered
prime-residue information* rather than a contiguous block of high bits. The
algorithm is **ResiduePartialFactor**: write `p = a + Mx`, apply the exact-integer
Coppersmith small-root lattice to `h(x) = Mx + a` over the unknown divisor `p`,
and recover `p = a + M·x`. It factors deterministically whenever
`x = (p−a)/M < N^{1/4}`, i.e. `M ≳ N^{1/4}` — the threshold is **measured, not
assumed**, and the output is **certified** by a single division `N mod p`. We
prove two supporting results (a symmetry theorem and, machine-checked, the
**GAP-difference gcd theorem** showing that generalized-arithmetic-progression
divisor covers cannot evade the counting wall `α+2β ≥ 1`). We then state the
**exact open question** that remains at the frontier: whether the residue method,
given *both* `p mod M` and `q mod M` with `M < N^{1/4}`, can break `N^{1/4}` via a
bivariate lattice — genuine independent information whose only blocker is the
multivariate Howgrave-Graham isolation bound.

---

## 1. The algorithm

**Algorithm (ResiduePartialFactor).** Input `N = pq` and the residue `a = p mod M`.
Output a nontrivial divisor of `N`, deterministically, whenever `M ≳ N^{1/4}`.

1. `p = a + M·x`, `0 ≤ x < p/M`, so the unknown divisor `p` makes the linear
   polynomial `h(x) = M·x + a` vanish at the small root `x = x*` modulo `p`.
2. Build the exact-integer shift-polynomial lattice
   `g_{i,j}(x) = N^{m−i}·x^j·h(x)^i`, `0 ≤ i ≤ m`, `0 ≤ j < t`, over `ℤ`
   (**no modular reduction** — this preserves the divisibility `N^m | g(x*)`),
   scale column `k` by `X^k`, and LLL-reduce.
3. Recover the underlying polynomial `H` from a reduced row via the exact
   division `H_k = v_k / X^k`; if `H(x*) = 0` over `ℤ`, then `p = a + M·x*`.
4. **Certify**: output `p` only if `N mod p == 0` and `1 < p < N`.

**Why it is sound and deterministic.** Every lattice element is divisible by
`N^m` at `x*`; if the reduced polynomial is short enough (the Howgrave–Graham
condition, which holds for `X < N^{1/4}`), then `H(x*) = 0` over `ℤ` and the root
is exact. No randomness and no smoothness heuristic enters — the only guarantee
is Coppersmith's `N^{β²/δ}` bound (`β=1/2`, `δ=1` ⇒ `N^{1/4}`), and the output is
verified.

## 2. The frontier, measured

For `M = primorial(y)` (scattered residue `p mod each prime ≤ y`), we swept
`n = 64, 96, 128`. Success is predicted by `x = (p−a)/M < N^{1/4}`:

| n | regime | predicted | factored | agreement |
|---|---|---|---|---|
| 64 | `x ≥ N^{1/4}` | fail | fail | ✓ |
| 64 | `x < N^{1/4}` (y≥20) | work | work | ✓ |
| 96 | `x ≥ N^{1/4}` | fail | fail | ✓ |
| 96 | `x < N^{1/4}` (y≥24) | work | work | ✓ |
| 128 | `x ≥ N^{1/4}` | fail | fail | ✓ |
| 128 | `x < N^{1/4}` (y≥32) | work | work | ✓ |

Aggregate: **7/7 predicted-success factored; 13/13 predicted-failure did not**
(exact agreement; see `out_residue.txt`).

## 3. Supporting results

**Symmetry (H1, confirmed).** Knowing `q mod M` (either factor) works identically
to `p mod M`, in every tested case. The method is symmetric in the two factors.

**CRT pooling (H2).** Knowing `p mod M₁` and `p mod M₂` (coprime) pools into
`M₁M₂` by CRT; this adds no new information, so the threshold is on the *effective*
modulus `M_eff > N^{1/4}`.

**The GAP-difference gcd theorem (machine-checked, `GAPGcd.lean`).** If `g` divides
every difference within `S` and within `T`, then every cross-difference `s−t` lies
in a **single residue class** `(s₀−t₀) mod g`. Hence a generalized-arithmetic-
progression divisor cover cannot evade the counting wall `α+2β ≥ 1`: the
co-prime-to-`g` part of each covered index must divide the small multiplier. This
is a structural, rank-independent reason all five round-96 attacks converge.

## 4. The exact open question

**The residue method realizes, but does not break, the `n/4` frontier.** It reaches
`N^{1/4}` via *residue* leakage (`p mod M`) instead of *high-bit* leakage; the
CHHS optimality theorem governs the univariate class either way. Its distinct
value is that it is deterministic, certifiable, and consumes **scattered
prime-residue** information — a leakage model the `n/4` high-bit theorem does not
directly cover.

> **Open question.** Given **both** `p mod M` **and** `q mod M` with `M < N^{1/4}`,
> can the method break `N^{1/4}`? The bilinear relation
> `(a+Mx)(b+My) = N` couples the two residues into a **well-posed bivariate**
> problem with genuinely independent information about each factor (unlike the
> within-one-factor encoding of round 97b). Within the **univariate** lattice the
> coupling adds nothing (it determines `y` from `x`), so the advance — if any —
> must come from a **bivariate lattice** exploiting the bilinear structure. The
> sole blocker is the **multivariate Howgrave–Graham isolation bound** (round 97g):
> a lattice-construction problem, not an information problem.

## 5. Scope

* This is a **new deterministic factoring algorithm** for a structured-promise
  leakage model, with a **certified** output and a **measured** `N^{1/4}` threshold.
* It does **not** beat any exponent on the balanced-random semiprime (that
  frontier is closed — rounds 96–98) and does **not** break the `n/4` frontier.
* The GAP-gcd theorem is a genuine structural contribution explaining why GAP
  covers cannot dodge the counting wall.
* The frontier advance reduces to one precisely-stated open problem (§4).

## References

* D. Harvey, M. Hittmeir, *A log-log speedup for exponent one-fifth deterministic
  integer factorisation*, arXiv:2105.11105.
* N. H. Chinburg, B. Hemenway, N. Heninger, W. Scherr, *Cryptographic applications
  of capacity theory*, ASIACRYPT 2016 (ePrint 2016/869) — optimality of Coppersmith's
  univariate bound.
* D. Coppersmith, *Finding a small root of a bivariate integer equation; factoring
  with high bits known*, EUROCRYPT 1996 — the small-root lattice.
* C. Umans, S. Wang, arXiv:2511.10851 — the divisor-cover route past `N^{1/5}`.