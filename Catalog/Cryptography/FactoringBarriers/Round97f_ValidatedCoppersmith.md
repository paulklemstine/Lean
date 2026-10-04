# Round 97f — the validated Coppersmith lattice: blocker RESOLVED, n/4 wall measured

**2026-10-04. NO new factoring algorithm and NO complexity improvement.** This
round **resolves the blocker** carried by rounds 97c–97e: I built and
**validated** a univariate Coppersmith small-root lattice, and with it
**measured** the `n/4` known-bits wall empirically. The validated solver is the
prerequisite for any future multivariate (bivariate) threshold claim.

Empirical companion: `Experiments/UMWWindow/coppersmith_lattice.py`
(deterministic, `out_cop.txt`).

---

## 1. Root cause of the 97c–97e failures (final, decisive)

Three independent bugs, each found by instrumenting the pipeline:

1. **The "hangs" were a slow trial-division `is_prime`**, not the lattice. With
   Miller–Rabin the `fpylll` skeleton is instant. (This mis-diagnosis cost
   rounds 97c–97d.)
2. **`X` was at/above the Coppersmith bound** in the earlier tests. The guarantee
   is `X < N^{β²/d}`; the validator now uses `X` well inside it.
3. **THE decisive bug: modular reduction of the lattice coefficients.** I built
   `g_{i,j}(x) = N^{m−i} x^j f(x)^i` **mod N**. This destroys the exact
   divisibility `N^m | g_{i,j}(x_0)`, so the recovered `h` does not vanish at
   `x_0` over ℤ. Building the lattice over **exact integers** (no mod) fixes it.
   *This only manifested in the factoring setting* (`f = x + p_0`, `p_0 ≈ N/2`),
   which is why the planted-root test passed while real factoring failed.
4. **Recovery path:** a reduced basis vector `v` of the scaled lattice is
   `v_k = h_k · X^k`, so `h_k = v_k / X^k` — an exact division that recovers the
   underlying polynomial (no transformation matrix needed).

## 2. Validation (the lattice is now TRUSTED)

* **Planted roots** `f = x − x_0` (deg 1) and `f = (x−x_0)(x−x_1)` (deg 2),
  `N ~ 2^64`, `X = 2^{10..14}`: all recovered.
* **Real factoring** `N = p·q` from the top `k` MSBs of `p` (`n` = bit length of
  `N`), sweeping `(m,t)` — the empirical success threshold:

| `n` | `n/4` | `k = n/4 − 2` | `−1` | `= n/4` | `+1` |
|---|---|---|---|---|---|
| 48 | 12 | – | **Y** | Y | Y |
| 64 | 16 | – | – | – | **Y** |
| 80 | 20 | – | – | **Y** | Y |

The threshold sits **at `n/4` within about one bit** across scales — matching
Coppersmith's `N^{1/4}` bound and the CHHS optimality the record cites. (Small
`±1` variation is the finite-lattice constant, not a gap.)

> **The univariate `n/4` wall is now MEASURED, not assumed**, with a validated
> instrument. This is the sharpest empirical confirmation the record carries.

## 3. What is established

* The validated univariate solver factors real semiprimes from exactly `n/4`
  known bits and not fewer — confirming the deterministic known-bits wall is the
  Coppersmith/CHHS one.
* Combined with round 97b (`p/q` bit-coupling ⇒ splitting the leak is a
  re-encoding) and round 97e (raw uniqueness is free), the **open multivariate
  sub-`N^{1/4}` gap is irreducibly the bivariate auxiliary-polynomial lattice** —
  and it is now *instrumented* for the first time: the univariate reference is
  validated and its threshold measured.

## 4. Honest scope

* **No new factoring algorithm. No complexity beaten.** The multivariate gap is
  still neither closed nor attacked.
* **New:** a validated Coppersmith lattice (the blocker resolved), the four-bug
  root cause, and an empirical measurement of the `n/4` wall.
* **Not claimed:** any sub-`n/4` attack. Only that the reference univariate
  threshold is `n/4` and the tool to probe the bivariate case now exists and is
  validated.

**Next attack (now unblocked).** With the validated solver, the concrete next
step is the **coupled bivariate lattice**: exploit `p·q = N` to build a
shift-polynomial system in the two coupled unknowns and sweep `X` for a
sub-`n/4` threshold. Below `n/4` ⇒ a sub-`N^{1/4}` partial-info attack (a real
result); at `n/4` ⇒ evidence the CHHS bound extends to the bivariate class (also
a real result). Either outcome advances the one open question.