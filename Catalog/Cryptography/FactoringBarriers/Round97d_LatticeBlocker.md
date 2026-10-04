# Round 97d — the validated-lattice blocker: an honest implementation failure

**2026-10-04. NO new factoring algorithm and NO complexity improvement.** Round 97c
identified the prerequisite for any quantitative work on the open multivariate
sub-`N^{1/4}` gap: a **validated** univariate Coppersmith lattice — one that
provably recovers a known small root before any claim is trusted. This round
attempted to build it and **failed its own known-root validation.** The failure
is recorded rather than shipped.

Empirical companion: `Experiments/UMWWindow/coppersmith_lattice.py`
(deterministic, `out_cop.txt`).

---

## 1. What I attempted

The Howgrave-Graham / Jochemsz–May univariate small-root lattice:

* shift polynomials `g_{i,j}(x) = x^j · N^{m−i} · f(x)^i`, `0≤i≤m`, `0≤j<t`;
* integer lattice of coefficient vectors, weighted by `X^{D−k}` (degree `D`);
* LLL reduction (`fpylll`, provably fast — the earlier "hangs" in my 97c
  attempts were a slow **trial-division** `is_prime`, not the lattice);
* a correct construction must yield a reduced row `h` with `h(x_0)=0` for a
  **known** small root `x_0`, once `X` is inside the Coppersmith bound
  `X < N^{β²/d}`.

## 2. The failure

Known-root validation, linear `f=x−x_0` and quadratic `f=(x−x_0)(x−x_1)`,
`X` well inside the bound, sweeping `(m,t)` and scale:

| f | N | X | vanishing rows @ x₀ |
|---|---|---|---|
| linear | 24b | 64 | 0, 0, 0 (m=1,2,3) |
| linear | 32b | 128 | 0, 0, 0, 0 (m=1,2,3,4) |
| quadratic | 24b | 64 | 0, 0, 0 (m=1,2,3) |
| quadratic | 32b | 256 | 0, 0, 0 (m=2,3,4) |

**All zeros.** A correct Howgrave-Graham lattice must return `>0` here. So the
construction is mis-scaled in this implementation — candidate causes are the
`X^{D−k}` weighting direction, the placement of `N^{m−i}`, the monic reduction,
or the required `m,t ∼ N^{β/d}` regime, none of which I isolated. Per the
record's rule (5) (*never trust a test that has never failed*), I make **no
quantitative claim** and use this lattice for nothing downstream.

## 3. What is established (unchanged)

* **The multivariate sub-`N^{1/4}` gap is open** (round 97): CHHS proved only the
  *univariate* auxiliary-polynomial class optimal.
* **The "split the leak" family is excluded** (round 97b): `p/q` bit-coupling
  (verified 2000/2000 + 3000/3000) makes it a re-encoding of the univariate
  problem.
* The lattice attack is therefore **blocked on implementation trust**, and the
  blocker is now precisely characterised (this file + the diagnosis in §2).

## 4. Honest scope

* **No new factoring algorithm. No complexity beaten.** The multivariate gap is
  neither closed nor attacked quantitatively.
* The one process lesson worth recording: **an implementation prerequisite must
  itself be validated before it is relied upon.** Round 97c correctly flagged
  "validated Coppersmith lattice first"; this round shows that flag was
  load-bearing — had I built a bivariate lattice on this unvalidated base and
  reported a threshold, it would have been a fabricated result (exactly the
  failure mode the record's rules exist to prevent).

**Next attack (concrete, for a future round).** Build the lattice from a
*reference* (a published Coq/Sage/PARI `small_roots`, or a textbook
implementation with its test suite) rather than from scratch; validate it
recovers a known root; then scale `m,t ∼ N^{β/d}`; only then attempt the
bivariate system. The diagnosis in §2 is the starting point, not a conclusion.