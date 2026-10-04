# Round 49 — the AP-cover reduction: prefactorisation is not needed

**2026-10-03. Round 49 produced no new factoring algorithm and no exponent
improvement. It produced a simplification of the only known route past Harvey's
`N^{1/5}`, a sharp negative result about the simplest instance of that route, and
two corrections to my own work — one of them to a theorem I had drafted and would
otherwise have published wrong.**

Machine-checked companion: `APCoverReduction.lean` (13 declarations, **0 `sorry`,
0 `axiom`**, typechecked against Mathlib at Lean 4.33.1 from
`~/prove2me_workspace`). Empirical companion:
`_scratch/r49/verify{,2,3,4}.py` — four versions, because three of my tests
were wrong on the first attempt and each is documented below.

---

## 1. The frontier, verified from primary sources

| algorithm | bound | source |
|---|---|---|
| deterministic (record) | `N^{1/5+o(1)}` | Harvey, arXiv:2010.05450, *Math. Comp.* **90**(332):2937–2950 |
| deterministic, conditional | `N^{1/6+o(1)}` | Umans–Wang, arXiv:2511.10851 (13 Nov 2025) — **only if** their `(α,β)`-Divisor Conjecture holds at `α=β=1/3` |
| rigorous probabilistic | `L_N[1/2,1]` | Lenstra–Pomerance |
| heuristic (practical) | `L_N[1/3,(64/9)^{1/3}]` | GNFS |

**Reading the primary sources changed two things I had assumed.**

### 1a. Oznovich–Lee Volk does *not* improve Harvey's exponent

arXiv:2506.07668 (v3, 11 Oct 2025) lowers the target order for the
high-order-element step from `D ≥ N^{2/5}` to `D ≥ N^{1/6}`, at the same
`D^{1/2+o(1)}` cost. Harvey's Prop. 2.7 is invoked with `D := ⌈N^{2/5}⌉`
precisely to feed `Algorithm 4.2`, and Prop. 4.3 notes "the cost … is
negligible". So the new threshold is satisfied by the *same* `D`, changes
nothing about the `r`/`m` balance, and does **not** yield an exponent
improvement. Their abstract claims Hittmeir's algorithm "played a crucial role"
in Harvey's work; it does not follow that the improvement composes.

### 1b. Harvey's `N^{1/6}` target is exactly the `r`-term

I re-derived Harvey's cost balance from the paper (Prop. 4.2 and its proof, p. 11):

```
cost = O( (N^{1/2}/(r^{1/2}m) + r)·lg⁴N + m·lg²N )
```

All four terms are `Θ(N^{1/5})` at `r = m = N^{1/5}` — the optimum is
**over-determined**, not merely balanced. That is why §7-undecuples-XXXVII's
"irreducible `m` gcds" is the right diagnosis: the `r lg N` term in the
giant-step count `s = Θ(N^{1/2}/(r^{1/2}m) + r)` is what forces `r ≤ N^{1/5}`
once Strassen's `(N/r)^{1/4}` term is included. **This is a re-derivation of a
known barrier, not a new one**, and I record it only because it confirms the
repo's existing claim from the primary text rather than from a summary.

---

## 2. THE RESULT: prefactorisation is not needed for factoring

### 2a. What Umans–Wang assume

Umans–Wang Theorem 5.2 requires three properties of a sequence `A₁..A_k`:

1. every integer `≤ n` divides `∏Aᵢ`;
2. interval products `∏_{i=a}^{b}Aᵢ mod d` are computable fast;
3. **"given an integer i, there exists a function f that returns the prime
   factors of Aᵢ in time `Õ(n^γ)`."**

Their Theorem 5.5 (`γ = max(α,β)+o(1)`, so `N^{1/6}` at `α=β=1/3`) rests on
all three. Property 3 is what forces their Conjecture 5.1 — the **Strong
Prefactored** `(α,β)`-Divisor Conjecture — and it is the least plausible
hypothesis in the chain. Why they need it: their algorithm computes
`N₀ = gcd(∏Aᵢ, N)` and then wants "the list of primes that divide `N₀`", which
they get by factoring the `Aᵢ` (p. 17, "we obtain the prime factors of `Aᵢ` by
Property 3").

### 2b. What is actually sufficient

**Property 3 is never needed.** Factoring only needs *a* nontrivial factor at
each step, not the prime list. Take `n = ⌊√N⌋` and suppose (1) holds. Then

> `gcd(N, ∏Aᵢ)` is `> 1` whenever `N` is composite — because
> `minFac N ≤ ⌊√N⌋` divides `n!`, hence divides `∏Aᵢ`, hence divides the gcd.
> If that gcd is a **proper** divisor we recurse on it and on `N/gcd`.
> If it equals `N`, a **binary descent** on the index interval recovers a member
> `Aᵢ` with `gcd(N,Aᵢ) > 1` — again with no factorisation.

Formally (`APCoverReduction.lean`, all machine-checked):

| declaration | content |
|---|---|
| `cover_factorial` | `n!` covers `[1,n]` — the cover is free (Strassen instance) |
| `minFac_le_sqrt` | `N.minFac ≤ ⌊√N⌋` for composite `N` |
| **`gcd_factors_or_full`** | composite `N` ∧ cover ⇒ `1 < gcd N V` ∧ (`gcd < N` ∨ `N ∣ V`) |
| **`descent_factor`** | `N > 1`, `N ∣ L.prod` ⇒ `∃ x ∈ L, 1 < gcd N x`. No factorisation of the `x`. |
| `descent_ap` | the descent specialised to a progression `b + i·c` |
| `ap_two_leaf` / `ap_two_leaf_dvd` | the descent's one corner: `N ∣ Aᵢ ∧ N ∣ Aⱼ`, `0 < j−i < N` ⇒ (`1 < gcd(N,c) < N`) ∨ (`N ∣ c`) |

**Verification that it is not vacuous.** `descent_factor` factors *every*
composite `N ≤ 4000` correctly (3997/3997) using only `b=0, c=1, k=⌊√N⌋`,
median 1 rising-factorial evaluation per semiprime, 0 degenerate fallbacks.

### 2c. What this does and does not buy

**Does:** removes Property 3 — hence Conjecture 5.1 — from the factoring chain.
That is a *simplification*, not an exponent improvement. Umans–Wang's
`(α,β)`-Divisor Conjecture (Conjecture 3.3) remains the live obstruction, and
their Lemma 5.3 still needs `Õ((log d)(n^α + n^β))` to produce `S ∪ T mod d`.

**Does not:** give an algorithm. The cover condition plus a cheap
interval-product routine is still a hard construction — that is Umans–Wang's
open problem and it is untouched.

**Honest scope:** the conjecture they need is now the *only* hypothesis, which
raises the value of attacking it but does not lower the bar.

---

## 3. THE RESULT: the consecutive AP cannot beat `α = 1−2β`

`c = 1`, so the progression is `{y+1, …, y+k}` with `y = −b`. The cover
condition becomes a **pure CRT condition on `y`**, with no search:

> for every maximal prime power `m = p^⌊log_p n⌋ ≤ n`, the residue `y mod m`
> must admit an `i ∈ [1,k]` with `i ≡ −y (mod m)`. So `m ≤ k` is free, and
> `m > k` admits **exactly `k` residues**.

**Density is exact** (verified to 8 decimal places, `T12c`):

```
D = ∏_{k < m ≤ n} (k / m),   m maximal prime powers.
n=15 β=⅓ k=6 : 38880 / 360360    = 0.10789211   = D  EXACT
n=16 β=.45 k=12: 498951 / 720720  = 0.69230769   = D  EXACT
n=16 β=.3 k=5 : 15625 / 720720   = 0.02167971   = D  EXACT
n=18 β=⅓ k=7 : 588245 / 12252240 = 0.04801122   = D  EXACT
```

So the least admissible `y` satisfies `y ≈ 1/D`, and

```
ln y ≈ (n/ln n)·ln(n/k)  →  n·(1−2β)   at k = n^{2β}
```

**α ≥ 1−2β is the floor, and for `c = 1` it is the only bound there is.** With
`α = β = 1/3` one needs `|b| ≈ e^{n/3}` — computable only in `~n` time. **The
`α = β = 1/3` construction, if it exists, must use `c ≠ 1` or a genuine
difference set `S − T` with `|S|, |T| ≥ 2`.** That is a narrowing of the
search space, not a construction.

---

## 4. Correcting my own work — three defects, all caught by the tests

The repo's rule (7) is *"render the page"*; the analogue here is **never trust
a test that has never failed.**

### 4a. `gcd(N, ∏Aᵢ) = N` for 29.7 % of composites — my theorem was too strong

v1 asserted "`gcd(N, n!)` is a **proper** nontrivial factor of every composite
`N`". Exhaustive check over `N ≤ 3000`: **184 failures**, starting at
`N = 30` (`⌊√30⌋ = 5`, `primorial(5) = 30`, so the gcd is `30`). v1's
explanation — "at most one prime factor of `N` is `≤ √N`" — is **false**: `30 =
2·3·5` has three.

Corrected and measured (`T8`): over the 17737 composites `≤ 20000`, **5272
(29.7 %) have `gcd(N, ⌊√N⌋!) = N`**, and *every one* has all prime factors
`≤ √N`. Examples: `24, 30, 36, 40, 45, 48, 56, 60, 63, 64, 70, 72`.

This is why `gcd_factors_or_full` carries a disjunction and why `descent_factor`
is not optional. `APCoverReduction.lean` machine-checks both alternatives and
both worked examples (`example_proper`: `gcd 1333 36! = 31`;
`example_degenerate`: `gcd 36 6! = 36`).

### 4b. My Möbius sieve was wrong, and it faked a counterexample

v1/v2 tested `rad(n!) = ∏_m lcm(⌊n^{1/m}⌋)^{μ(m)}` and reported **57/60
failures**. The identity is **true**; my sieve loop ran `for j in range(2*i, …)`
so it never set `μ(p) = −1` for primes, and every prime read as `μ = +1`. After
fixing: **all `n ≤ 150` exact.**

The same loop printed the density test correctly by luck for `n = 15, 16` and
wrongly for `n = 16, β = 0.3` — that second mismatch was the one real clue, and
it was a genuine bug: the product must run over **maximal** prime powers, since
the constraints for `2, 4, 8` are implied by the one for `16`.

### 4c. `T11` reported 100 % failures — twice, for different reasons

| attempt | reported | actual bug |
|---|---|---|
| v3 | 0 cases | construction never produced two divisible terms |
| v4 | 247026 failures | tested `c ∣ N` (`N % c`) when the theorem says `N ∣ c` (`c % N`) |
| v4 | 351000 failures | missing the `j − i < N` gap hypothesis |
| v4 | **0 failures** | — |

Final: **946491 constructed pairs, 0 failures**; disjunct 1 on 381927 cases, 0
failures. The Lean theorem `ap_two_leaf_dvd` and the corrected test now agree.

### 4d. A defect in Umans–Wang's Definition 3.1

> **Definition 3.1.** *A set `A` of positive integers satisfies the
> `n`-divisor property if for all `i ∈ {1,…,n}` there exists `a ∈ A` such that
> `i ∣ a`.*

`A = {0}` satisfies this, since `i ∣ 0` for all `i`. Their `A = {s − t}` is
built from `S, T ⊆ Z⁺` with no disjointness requirement, so `S ∩ T ≠ ∅` makes
the whole thing vacuous. **My own brute force hit this**: it reported
`y_min = 1` for *every* β, because `b = −1, c = 1` gives `A_1 = 0`.

**This does not invalidate their theorem** — the constructions they actually
need are non-vacuous — but a reader checking Definition 3.1 against a candidate
family must exclude `0 ∈ A`. Worth reporting to the authors.

---

## 5. Two exact identities, verified

Both classical, both confirmed here, both relevant because they are the only
formulas that relate `lcm` and `rad` without division:

```
n! = ∏_{m=1}^{n} lcm(1, …, ⌊n/m⌋)                     exact for all n ≤ 60
rad(n!) = ∏_m lcm(1, …, ⌊n^{1/m}⌋)^{μ(m)}             exact for all n ≤ 150
```

The second is Möbius inversion of `v_p(lcm(1..X)) = ⌊log_p X⌋`, using
`∑_{m ≤ L} μ(m)⌊L/m⌋ = 1`. `rad(n!) = ∏_p p` is what a *primorial* computes,
and `lcm(1..n) = ∏_e P(⌊n^{1/e}⌋)` turns the primorial into `O(log n)` lcm
terms — the only known reason to believe the primorial is not exponentially
harder than the factorial modulo `N`.

---

## 6. Verdict

**No new factoring algorithm. No exponent improvement.** The round produced:

1. a verified frontier map, and a **closed** question (does Oznovich–Lee Volk
   improve Harvey? — **no**);
2. a **simplification** of the only known route past `N^{1/5}`: the
   prefactorisation hypothesis is unnecessary, machine-checked, and the
   remainder of the conjectural content is now isolated;
3. a **sharp negative result**: consecutive APs cannot beat `α = 1−2β`, so any
   `α=β=1/3` construction must be genuinely two-dimensional;
4. three corrections to my own work, of which (a) would have been a published
   false theorem and (d) is a defect in the target paper's Definition 3.1.

**Next attack, in order of expected value.**

- **(A) The `c ≠ 1` cover.** Section 3 says this is the only remaining axis.
  The condition is `∃ x, ∀ m : gcd(x, m) = 1 ∧ x mod m ∈ [1,k]`, a CRT
  problem over `∏_{m>k} m ≈ e^n` with `∏` of `k` choices each — density `D`,
  but a *structured* CRT solution is not a random one, and section 3 shows the
  random solution is far too large. Whether Umans–Wang's conjecture is exactly
  a structured-CRT-solution question is worth an hour with a solver.
- **(B) Interval products at no prefactorisation cost.** `Lemma 5.3` is the
  remaining hypothesis. If interval products could be had from a cover with
  `|S|,|T| = n^β` and no factorisation requirement at all, the chain would be
  *fully* conjectural in one object instead of two.
- **(C) Negative.** Section 3's argument generalises to *any* `b, c` with
  `gcd(c, P(n)) = 1`: the number of `x` with `x mod m ∈ [1,k]` for all maximal
  prime powers `m > k` is at most `∏ k`, so *some* `x` satisfies the cover, but
  proving one is *small* requires the `α = 1−2β` barrier to be non-tight. A
  rigorous bound here would close §3 for all `c` at once.

**Do not restart the ladder** (§ Round 48). The right instrument remains a
cheap measurement of a *cover*, not of a factor: `n`-dependent, `O(1)`-event,
and — per §4a — it must distinguish the `gcd = N` case from the proper case or
it will report the 29.7 % smooth instances as failures.