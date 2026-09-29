# Round 47 part 7 — the repaired measurement, and the honest verdict

> ## ⚠️ CORRECTED IN PART — see `Round47_PricingCorrection.md`
>
> Two figures below are WRONG and are retracted there: "`~L_n[1/3] ≈ 2.5e35`" and the
> implied "worse than GNFS by a constant". My helper returned the **exponent** of the `L`,
> not the `L`. The correct demand at `N = 10^20` is `L[1/3,1] = 6464` — which matches the
> record's own `B = L_n(1/3) = 6463.8` — and the naive pricing then points the *other* way,
> toward a ~100x constant-factor win. Everything else in this file (the 73%, the median 2,
> `N^2 | disc(E)`, the six retractions, and the verdict that this is not a factoring method
> today) stands unchanged.


**2026-09-29. `Round47_Circularity.md` showed the 62% figure was measured through a rank
computation on a curve with `N² | disc`. This re-measures it with no factorisation
anywhere. The number goes UP, not down — but the context changes what it means.**

---

## 1. The clean measurement

**No factorisation of `N`, no rank computation, no PARI.** Pure enumeration of coprime
`(u,v)` with `max(|u|,|v|) ≤ H`; for each, test `l(m) = w²` and evaluate
`chi_P = Jacobi(C(t)·y, N)`, which needs no factors.

`H = 60`, 12 moduli, 8 `(m, P, Q)` each, `P ≠ 0` exercised throughout:

| | |
|---|---|
| **`chi_P = −1` within `H`** | **70/96 = 73%** of `(N,f)` |
| relations per `(N,f)` at `H=60` | **median 2**, max 13 |
| `Hmin` among successes | **median 11**, max 55 |

Per-modulus: 7/8, 6/8, 7/8, 5/8, 5/8, 5/8, 6/8, 6/8, 5/8, 5/8, 7/8, 6/8 — consistent
across all twelve, no modulus is an outlier.

**This replaces the 62%.** It is *higher* (73% vs 62%), and it is measured on a cleaner
sample — many `(m,f)` per modulus rather than one. The 62% was not wrong so much as
**measured through an instrument that may have used the answer**.

## 2. What the two numbers together mean

**One relation factors `N`.** That is verified end-to-end and it is not circular: given a
point of the quartic with `chi_P = −1`, the relation `l`, the integer `w` with `l(m) = w²`,
and `gcd(w − g(m), N)` return `p` and `q`. Nothing in that chain touches a factorisation.

**But there is no redundancy.** Median **2** relations per `(N,f)`. An NFS needs
`~L_n[1/3] ≈ 2.5e35`; the `L[1/2,1]` rigorous line needs `~2^{√(log N log log N)}`. **Two is
not a margin — it is a coin-flip on a 73% event, repeated.**

So the honest description of the artefact is:

> **A verified, factorization-free reduction from "a rational point of a specific genus-1
> curve with a negative Jacobi symbol" to "a factor of `N`", together with a clean
> measurement that such a point exists within height 60 for 73% of tested `(N,f)`, and a
> clean measurement that the relation space at that height holds a *median of 2* elements.**

## 3. The scaling data point, which is negative

The rank-computation scaling measurement **timed out** (`scaling2.py`, exit 143) after
27 minutes without completing its size ladder. `ellrank` on curves whose coefficients grow
like `N²` is not scaling usefully. That is a data point *against* the basis-based route, and
it is consistent with `Round47_Circularity.md`: the 2-descent has to work at the bad primes
`p`, `q`, and it is not cheap there.

The smoothness measurement likewise timed out on `factorint` of the large `B(t)` values.
`Round47_ChebotarevAndRetraction.md` §2 already carries the analytic answer from A5 —
smoothness is **not** the binding constraint (the box `|t| ≤ (L_n[1/3]/8)^{1/6}` holds only
`O(10²)` Mordell–Weil points against `2.5e35` relations, short by 33 orders of magnitude).

## 4. The verdict on the round

**What is real and new:**

1. The relation space of the cubic NFS is **exactly the rational points of a genus-1 curve**,
   with the cone `g1² + 2g0g2 − Pg2² = 0` rationally parametrised. Derived and verified to
   1155/1155.
2. Its Jacobian is **explicit**: `Y² = V² + UW` with `U = 2x−2m²−P`, `V = mx+mP/2+Q`,
   `W = x²/2−P²/8+mQ/2`, reducing **exactly** to `Y² = x³ − 3mcx + c² + m³c` at `P=0`.
3. The branch character is **explicit**: `chi_P = Jacobi(C(t)·y, N)`, and that identity is
   **Lee–Venkatesan's own definition** (p.38) — no novelty claimed for it.
4. `chi_P = −1` yields a factor by a **verified, factorization-free** algebraic chain.
5. The obstruction is **73% likely to be absent** at height 60, measured cleanly.
6. `disc(E) = 27c²(c−m³)²` and `N² | disc(E)` always — a sharp structural constraint on any
   descent-based attack, found by me, against my own method.

**What is not there:** a factoring method. Not because the algebra is wrong — it is verified
to the digit — but because the relation space has **no redundancy at accessible heights**,
and the descent that would exploit the group structure runs into the bad primes it is
supposed to find.

**The one-line version of the remaining problem:** *the relations are too few.* The
structure is genus-1 and the curve is explicit, but a genus-1 curve has `Θ(H)` points of
height `≤ H` and an NFS needs `L_n[1/3]`. Closing that gap is not a matter of cleverness in
this direction.

## 5. Retractions filed this round, against myself

| claim | status |
|---|---|
| `chi_P` constant ⟺ `C(t)A(t)` square in `Q(t)` | **REFUTED** — 13/24; non-trivial on `Q(E)` does not imply non-trivial on `E(Q)` |
| CLAIM 47 (rank > 0 ⇒ `chi_P = −1` exists) | **REFUTED** — rank 0 in 10%; `chi⁻¹(−1)` is not Zariski-open |
| 62% success rate | **WITHDRAWN** and replaced by 73% measured factorisation-free |
| "decidable failures" via a certified basis | **WITHDRAWN** — a basis needs the 2-Selmer group, which needs `p`, `q` |
| "12/12 factors recovered" as a *method* | **DOWNGRADED** — the algebra is verified; the point-finding step used an instrument of doubtful independence |
| smoothness of `B(t)` as "the remaining gate" | **DOWNGRADED** — it is not the binding constraint; relation *count* is |
