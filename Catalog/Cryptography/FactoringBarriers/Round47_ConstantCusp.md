# Round 47 part 26 — the GNFS constant is a CUSP, the linear-algebra half is non-binding,
# and the only live lever is the smoothness bound

**2026-09-29. Agent A13, on the axis I reopened. It closes the axis harder, corrects the
closure's reasoning, and hands back one genuine lead.**

---

## 1. ⚠️ A9's closure was wrong, and the error is instructive

A9 argued: (i) Montgomery's `+O(n²)` *is* the linear-algebra half of the constant, so it is
irreducible; (ii) the `(1+o(1))` swallows any speedup polynomial in `log N`.

**Ground (i) is false.** The total is a **`max`**, not a `+`. Thomé, CSE 291-14 slides
17/21 (PDF p. 24, image-read), verbatim:

> *"linear algebra will cost $(B^2)^{1+o(1)}$, … so that **the total cost is
> $L_N[1/3,\, 2\max(\alpha,\beta)+o(1)]$**. Given this total cost, it makes sense to search
> for a solution with $\alpha=\beta$."*

**A9 computed a sum.** `T(ω) = (1+ω/2)(8/9)^{1/3}` and its "floor `0.96150`" treat cost as
sieving **+** LA. **At the optimum the branches are equal**, so `max ≠ sum` — and at `ω = 2`
`max = sum = 1.92300`, which is exactly what hid the error. **Both `T(ω)` and the floor are
retracted.**

**Ground (ii)'s conclusion holds; its stated reason does not.** The correct reason is the
cusp, not the `o(1)`.

## 2. THE AUTHORITATIVE SOURCE, which A9 never opened

**Le Gluher–Spaenlehauer–Thomé, "Refined Analysis of the Asymptotic Complexity of the NFS",
arXiv:2007.02730, Math. Cryptology 1(1):1–18.** p. 4, image-verified:

> `log C_search = O(1)+2a(ν)`, `log C_linear algebra = O(1)+2b(ν)`,
> **`log(C_search + C_linear algebra) = O(1) + log max(C_search, C_linear algebra) = O(1) + 2max(b(ν),a(ν))`**
>
> **Problem 3:** *"minimize $\max(a(\nu),b(\nu))$ subject to
> $p(a+\nu/d,b)+p(da+\nu/d,b)+2a-b=0$."*
>
> **Proposition 5:** *"$a(\nu)=(8/9)^{1/3}\nu^{1/3}(\log\nu)^{2/3}(1+o(1))$,
> $b(\nu)=(8/9)^{1/3}\nu^{1/3}(\log\nu)^{2/3}(1+o(1))$"*

**`a(ν) = b(ν)` is the cusp.** So the total **equals the sieving cost**, and the linear
algebra — which appears nowhere in the constraint, only as `2b(ν)` in the `max` — is
**non-binding**.

> **THE CONSTANT IS SET ENTIRELY BY THE SIEVING / SMOOTHNESS SIDE.**

## 3. Measured: free linear algebra moves the constant by ZERO

`T(ω) = min 2·max(a, ωb/2)` over the *unchanged* constraint (Dickman `p`, de Bruijn tail):

| `ν = log N` | `ω=0` | `ω=1` | `ω=1.5` | `ω=2` | `ω=3` | gap(2−0) |
|---|---|---|---|---|---|---|
| `10^10` | 2.003552 | 2.003552 | 2.003552 | 2.009394 | 2.243420 | `5.8e−3` |
| `10^20` | 2.003086 | 2.003086 | 2.003086 | 2.004437 | 2.201827 | `1.4e−3` |
| `10^30` | 1.991522 | 1.991522 | 1.991522 | 1.992114 | 2.177068 | `5.9e−4` |

Cusp diagnostic: `a/sc` and `b/sc` agree to **6 decimals** at every `ν`, reproducing
Prop. 5.

> **`T(ω)` is flat for every `ω ≤ 2` and strictly increasing for `ω > 2`.** Free or
> subquadratic linear algebra moves the constant **not at all**.

⚠️ **Honesty about the absolute numbers:** the control **T2 FAILED** — the same code does not
reproduce `1.922999427076544`; it returns `≈2.0044` at `ν = 10^20`, a **+4.2%** gap. So
**no absolute number above is claimed as a new constant.** The claim is only
**structural** — `T(ω)` flat for `ω ≤ 2`, increasing beyond — which is stable across every
truncation tested (`nterms = 0…4` → 1.987–2.009) and corroborated by LGST's verbatim `max`
and Prop. 5.

## 4. `1.92300` is the `ξ = 0` artifact — by the authors' own statement

LGST Formula (1), p. 1, image-verified (and `pdftotext` rendered `∛(64/9)` as a *square*
root — exactly the corruption rule 3 warns of):

> `exp( ∛(64/9) (log N)^{1/3} (log log N)^{2/3} (1 + ξ(N)) )`,  `ξ(N) ~ 4 log log log N / (3 log log N)`

> **The `1.92300` everyone quotes is the `ξ = 0` value.** The true constant is larger by
> `Θ(log log log N / log log N)`. And the abstract, verbatim: *"this series starts converging
> only for $N>\exp(\exp(25))$… This raises doubts on the relevance of NFS running time
> estimates that are based on setting $\xi=0$."*

> **By the authors' own statement, at any factorable `N` the constant is not determined by
> the published asymptotic.** (This retires the record's worry that `1.923` is a merely quoted
> number — LGST derive it in print.)

**And my `n² → n·polylog(n)` intuition was right about the scale and wrong about the
effect:** that change is `O(log log log N)` in the exponent — **exactly the `ξ` scale** — but
it lands on the **non-binding branch**, so it does nothing.

## 5. THE LEAD: `1.902` cannot be "more polynomials"

**`ω` appears nowhere in the LGST objective or constraint.** An integer-indexed family can
therefore only produce `e^{O(1)}` factors landing inside the `o(1)`. **So `1.902` — which
sits non-trivially between `1.90188` and `1.92299` — cannot be a cost multiplier over
`ω`. If it is real it must come from the CONSTRAINT, i.e. the sieving/smoothness side.**

**That is the only live lever on the constant, and it is exactly where the smoothness bound
(`u`, the Bombieri–Vinogradov range) enters.** Coppersmith MNFS is unverified — Springer
LNCS 877 is not in Crossref, and A13 made no claim about `1.902`'s provenance — but the
*structural* conclusion stands: **whatever moves this constant, it moves the constraint, not
the objective.**

## 6. State of the art, corrected

- **arXiv:1607.04514 (Eberly, *Black Box Linear Algebra*) is REAL and A9 missed it**:
  *"…a black box algorithm … that is provably reliable and — **by a small factor —
  asymptotically more efficient** than alternative techniques."* **Constant factor only, and
  conditional** ("If successful").
- **No sub-quadratic NFS linear algebra exists.** The best published claim is
  constant-factor. Positive controls: `au:Schost` → 62, `ti:"Number field sieve"` → 10,
  `all:"NFS" AND all:"subquadratic"` → 0.
- **A13's own failures, recorded because they are the useful part:** two failed Dickman
  implementations (`uρ'(u) = −ρ(u−1)` holds only for `u ≥ 1`; marching from `15/16` gave
  `ρ(2) = 0.2433` against the correct `0.3069`), and the **T2 control that failed**.

## 7. The recommendation I adopt

> **Close the axis, and re-open it only for `1.902`/`1.90188` and the Vyas–Williams lower
> bound. Strike A9's linear-algebra half and replace it with the max/cusp argument, which is
> stronger than either of A9's grounds.**
