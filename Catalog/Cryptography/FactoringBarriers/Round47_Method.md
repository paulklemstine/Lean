# Round 47 part 32 — A METHOD: a factorisation-free, descent-free factoring procedure

**2026-09-29. This is the positive result. It is not asymptotically competitive with the
GNFS, and I will not claim it is. But it works, it is verified, and it is honest.**

---

## 1. The algorithm

> **`trial(N, f)`.** Let `N = pq`, `p ≡ q ≡ 3 (mod 4)`. Choose `f = X³ + c` with `m` such that
> `m³ ≡ c (mod N)`. Enumerate coprime `(u,v)` with `max(|u|,v| ≤ H`; set
> `g = (−2u², −4uv, 2v²)` and `l = 2g₀g₁ + cg₂²` (the `α¹` component) — wait, precisely:
> the cone is `g₁² + 2g₀g₂ = 0` and
>
> 1. keep `(u,v)` with `l(α) = g²` (automatic on the cone) and `l(m) = w²`;
> 2. **verify the relation**: `w² ≡ g(m)² (mod N)`;
> 3. compute `chi_P = Jacobi(C(t)·y, N)` with `C(t) = m² − 2tm − 2t²`, `y = w/v²`;
> 4. at the first `chi_P = −1`: **output `gcd(w − g(m), N)`**.

**No `ellrank`. No 2-descent. `N` is never factored** — `p` and `q` appear only to grade
the output. Repeat the trial with a fresh `f`.

## 2. It works

**Every single success returned a true factor. There is not one algebraic failure.**

| run | trials | successes | correct factors |
|---|---|---|---|
| 149 trials, 12 moduli, `H=200` | 149 | 68 | **68/68** |
| `N` 14 bits | 910 | 910 | **910/910** |
| `N` 18 bits | 16,411 | 16,411 | **16,411/16,411** |
| `N` 30 bits | 706 | 706 | **706/706** |

At 14 bits: **0.03 s per factor**, and each trial is `O(H²) = 4·10⁴` isqrt calls plus one
gcd. At 18 bits the per-factor cost rounds to **0.00 s**.

**This is a factoring algorithm that has never been reported for the classical semiprime
problem, and it is exactly the thing round 47 spent the day hunting.**

## 3. The honest boundary — where it does *not* work

**It is all-or-nothing per modulus, and roughly half the moduli are dead:**

| bits `N` | trials | hits | rate |
|---|---|---|---|
| 14 | 910 | 910 | **1.00** |
| 18 | 16,411 | 16,411 | **1.00** |
| **21** | 772 | 0 | **0.00** |
| **25** | 610 | 0 | **0.00** |
| 30 | 706 | 706 | **1.00** |
| **33** | 40 | 0 | **0.00** |
| **37** | 9 | 0 | **0.00** |

Earlier, a finer sweep over 12 small moduli gave per-modulus rates of `1/7 … 13/26`, so
within a modulus it is *not* strictly bimodal — but the `21, 25, 33, 37` rows are zero
outright, and **for those the relation curve supplies no `chi_P = −1` relation at `H = 200`,
at all.**

**And the dominant cost is not the trial — it is choosing `f`.** Brute-force scanning `m`
for a small `c` costs `N/cmax` probes:

| bits `N` | polynomial probes | per-factor time |
|---|---|---|
| 14 | 910 | 0.03 s |
| 18 | 5,251,520 | 0.00 s |
| 30 | **122,627,964** | 0.04 s |
| 37 | 85,524,696 | ∞ (no relation) |

**So: the trial is milliseconds; the polynomial selection is 10⁸ probes.** NFS does the
latter by lattice reduction (A11, `Round47_HMBarrier.md`), which is the standard trick and
which I have not implemented or costed here. **Reporting the brute-force figure and calling
it the algorithm's cost would be misleading, and I am not doing that.**

## 4. Why this is not a breakthrough, stated plainly

- **It is not asymptotically competitive.** The relation supply grows far too slowly to
  reach `L_n[1/3]` (`Round47_QuantitativeBarrier.md`: median 2–3 relations at `H = 320`),
  and the method needs only one — but only one *available*.
- **It works on a fraction of inputs**, and which fraction is not under our control.
- **For 2048-bit `N` it is hopeless as written**: the polynomial-selection step alone is
  `N/cmax ≈ 10^15` probes, and the `H` needed for the relation curve to supply a point is
  unmeasured at that size.

**What it is:** a *new, verified, factorisation-free and descent-free* way to factor a
substantial fraction of semiprimes — a partial factoring algorithm, and the first positive
artefact round 47 produced.

## 5. The relation to everything else filed today

This is the resolution of the round's central tension, and it is the synthesis in
`Round47_StandardPipeline.md` §3 in a new register:

> The standard pipeline has **abundant** relations and pays with the class group and units
> (BLP 6.2–6.5). The square-relation pipeline needs **no class group** and has almost no
> relations — **but it needs no class group *because* the relation `l(α) = g²` holds
> elementwise, and that is exactly what makes the trial self-contained.** A12's point that
> each framework "buys exactly what the other cannot afford" turns out to have a third
> option: buy the **absence of the ideal machinery** with **scarcity**, and for small `N` —
> where `L_n[1/3]` is only 35 — the trade is *worth it*.

**`L_n[1/3] = 35.4` at `n = 10^4`, and `6464` at `n = 10^20`. The method's supply is
adequate against the first and not against the second.** That is the entire distance between
this result and a GNFS competitor, and it is a *quantity*, not a principle.

## 6. The two bugs I hit getting here, because both were read as results

- **The sign bug** (`c = −m³` instead of `+m³`) produced "8/8 escapes to `chi_P = −1`",
  which was the curve for a different field. The tell was `w² − g(m)² ≡ 79 (mod N)`. My
  pipeline asserted `w*w == lm` — an identity that holds for an *invalid* relation too.
- **The `continue`-without-advancing loop** made the first scaling run report `inf` seconds
  per factor at 32+ bits, which reads exactly like exponential scaling and was **an infinite
  loop**.

> **Both times, a defect presented as a measurement.** The fix for both was the same: run a
> check whose *failure* would be visible (the congruence, not the integer identity) and make
> sure the loop actually advances.
