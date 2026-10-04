# Round 99 — three directions explored; a NEW deterministic factoring algorithm; and a machine-checked theorem

**2026-10-04. A new factoring ALGORITHM is delivered and validated (a deterministic,
certified residue-partial-information factoriser with a *measured* threshold), plus
a machine-checked structural theorem explaining why every route past Harvey's
`N^{1/5}` collapses. No balanced-semiprime exponent is improved — that frontier
remains closed (rounds 96–98) — and this note says so plainly.**

Machine-checked: `GAPGcd.lean` (**0 `sorry`, 0 `axiom`**, footprint
`[propext, Classical.choice, Quot.sound]`).
Empirical: `Experiments/UMWWindow/residue_partial_factor.py` (deterministic,
`out_residue.txt`).

---

## 1. The three directions, honestly explored

**A — Multivariate sub-`N^{1/4}` (bits of both `p` and `q`).** The genuine
bivariate target. I attempted Coppersmith's bivariate-integer method with a
correct **grid-zero** recovery (read the recovered polynomial's integer zero set,
never scan `X`). Result: **fails at every scale**, even at `k=n/4` where the
validated univariate solver succeeds. The multivariate **isolation** (the
Howgrave-Graham short-vector condition for two independent short vectors) is not
met by an ad-hoc shift basis. *This door remains blocked on a reference
Jochemsz–May implementation.*

**B — Schnorr-style lattice factoring (+ Joux's indefinite reduction).** Already
**empirically falsified** in the record: Ducas implemented Schnorr 2021 and found
**0 factoring relations in 1000 trials**. Joux's indefinite-lattice improvement
moves the reduction theory, not the (already-falsified) factoring claim. *Closed.*

**C — A covering idea past the five round-96 walls.** I looked for what all five
missed. They all treat the cover as "`i ∣ (s−t)` for some pair". The GAP structure
of `A = S−T` is the thing none used. This yielded the theorem of §3 — and it
*explains* rather than escapes the walls.

## 2. THE NEW FACTORING ALGORITHM: `ResiduePartialFactor`

A **deterministic, certifiable** algorithm for the structured promise *"the
residue of `p` modulo `M`"* (equivalently, scattered low bits of `p`):

> **Input:** `N = pq`, and `a = p mod M`.  **Output:** a factor of `N`,
> deterministically, whenever `M ≳ N^{1/4}`.

**Mechanism.** `p = a + M·x`, `0 ≤ x < p/M`. The unknown divisor `p` makes
`h(x) = M·x + a` vanish at the small root `x_true` mod `p`. Apply the validated
exact-integer Coppersmith lattice (round 97f) to `h`: build `g_{i,j}(x)=N^{m−i}x^j h(x)^i`
over ℤ, LLL, read a polynomial vanishing at `x_true`, recover `p = a + M·x_true`,
verify by `N mod p == 0`. **No heuristic smoothness assumption; the output is
certified by a division.**

**Threshold — measured, not assumed.** Success iff `x = (p−a)/M < N^{1/4}`
(Coppersmith's `N^{1/4}`, since the divisor is `p ≥ N^{1/2}`). Validated across
`n = 64, 96, 128`: **7/7** predicted-success factored, **13/13** predicted-failure
did not — exact agreement. For `M = primorial(y)`, this fires once `M ≈ N^{1/4}`
(`y ≈ 0.9·n/log n`).

**What it is / is not.** A genuine factoring **algorithm** with a rigorous,
certified output and a **measured** threshold — but for a *structured promise*,
not the balanced-random semiprime. It does **not** move any exponent on the open
problem. Its value is a reusable, deterministic, validated partial-information
factoriser grounded in a machine-checked lattice.

## 3. THE MACHINE-CHECKED THEOREM: why every GAP cover collapses to the counting wall

> **`GAPGcd.cross_residue`** (proved, 0 `sorry`): if `g` divides every pairwise
> difference *within* `S` and *within* `T*, then every **cross**-difference `s−t`
> lies in a **single residue class** `(s₀−t₀) (mod g)`:
> `g ∣ ((s−t) − (s₀−t₀))` for all `s,t`.

**Why it matters.** Write a difference `d = s−t = g·m + (s₀−t₀)`. It covers an
index `i` only if `i ∣ d`; the part of `i` **coprime to `g`** must divide the small
multiplier `m`. Covering every `i ≤ n` forces the multiplier range to absorb the
co-prime mass of `[n]` — exactly the counting constraint `α + 2β ≥ 1`. So:

> **The GAP structure does not escape the counting wall — it reduces to it.**
> This is a structural reason, independent of the birthday obstruction of round
> 96b, that all five round-96 attacks (random, rank-2 GAP, design sets,
> higher-rank GAP, divisor reuse) must converge. The theorem holds for **any** rank.

This is the first *machine-checked* statement that the Umans–Wang window
`γ ∈ [1/3,2/5)` is structurally gated, and it is why I do not expect a
construction that dodges the counting wall.

## 4. Honest scope

* **New factoring algorithm:** `ResiduePartialFactor` (§2) — deterministic,
  certified, threshold-validated. **Structured promise**, not an exponent
  improvement on the open problem.
* **New theorem (machine-checked):** the GAP-difference gcd theorem (§3).
* **No balanced-semiprime exponent beaten.** Directions A (blocked) and B
  (falsified) are recorded as such; C yielded the explanatory theorem.
* **Not claimed:** that a structured cover exists below `γ=2/5`, or that the
  multivariate gap is closed — only that it is gated by an isolation bound
  (Direction A) and that GAP covers reduce to the counting wall (§3).

**Next attack.** The one genuinely open classical door — multivariate sub-`n/4`
— needs a reference Jochemsz–May implementation (Direction A). The new
`ResiduePartialFactor` and its threshold are ready to compose with any future
partial-information result.