# Round 58 — He–Sahai refute the Umans–Wang AP conjecture; the route survives on a knife edge

**2026-10-03. A paper I did not know about refutes the arithmetic-progression
version of the conjecture that Rounds 49 and 50 were built around. I verified it
from the PDF, worked out exactly what survives, and fixed an error of my own.**

Verified source: Xinjie He and Amit Sahai, *Refuting a Conjecture of Umans and
Wang on Arithmetic-Progression Divisor Covers*, **arXiv:2608.06681v1**, 7 Aug 2026.
Extracted and read: `_scratch_newalg/hesahai.txt`. Cross-read against
`uw.txt` (Umans–Wang, arXiv:2511.10851).

---

## 1. The refutation

He–Sahai, **Theorem 1.1** (verbatim from the PDF):

> Let `n` tend to infinity … and let `A_n = {b_n + i c_n : 0 ≤ i < L_n}` be an
> arithmetic progression with the `n`-divisor property. Put `H_n = max A_n`. If
> `log H_n = o(√n)`, then
> ```
> L_n ≥ ( √(8/27) − o(1) ) · n^{3/4} / √(log n).
> ```

**Corollary 1.2** (verbatim):

> Fix `α, β ≥ 0` with `α < 1/2`, `β < 3/8`. There is no unbounded sequence of
> integers `n` admitting positive `n`-divisor arithmetic progressions satisfying
> `L_n ≤ n^{2β+o(1)}`, `H_n ≤ exp(n^{α+o(1)})`.
>
> *"In particular, for every sufficiently large `n` there is no such progression
> under the stronger literal bounds `L_n ≤ n^{2β}` and `H_n ≤ exp(n^α)`."*

**Unconditional.** Only analytic input is the prime number theorem. The proof
uses primes in a fixed band below `√n` to turn semiprime divisibility into a finite
incidence structure, then a bounded-degree linear-space estimate (Lemma 2.1,
`v ≤ Δ(Δ−1)+1`, proved in-paper, in the spirit of de Bruijn–Erdős).

**This kills `(α,β) = (1/3,1/3)`** — precisely the point that would have given
deterministic `N^{1/6}` via Umans–Wang Theorem 5.5. The margin is not marginal:
He–Sahai's lower bound is `n^{3/4}/√(log n)` against the `n^{2/3}` required, a
ratio `n^{1/12}/√(log n) → ∞`.

---

## 2. What survives — Remark 4.2, verbatim

> **Remark 4.2 (What has and has not been disproved).** Proposition 3.4 of
> Umans and Wang [4] shows that the Arithmetic Progression Version implies the
> Strong `(α,β)`-Divisor Conjecture; **no converse is asserted.** The result
> above consequently does not disprove the full Strong `(1/3,1/3)`-Divisor
> Conjecture. A difference of two higher-rank generalized arithmetic progressions
> need not be a one-dimensional progression. The decisive step above uses
>
> ```
> (u + ic) − (u + jc) = (i − j)c.
> ```
>
> For a rank-two progression, the corresponding difference contains two
> independent coefficients, and the at-most-one-intersection argument does not
> follow.

So: the refutation is **exactly one-dimensional**, and Umans–Wang's Theorem 5.5
assumes the **rank-2 Strong Prefactored** conjecture (Conj. 5.1), not the AP
version. **The conditional `N^{1/6}` bound is not refuted.** But its most
accessible construction route now is.

---

## 3. My own contribution: the surviving window is a single point

Combining He–Sahai Cor. 1.2 with Umans–Wang's own counting constraint (§3:
`α ≥ 1 − 2β`), a point `(α,β)` survives **and** yields a factoring improvement iff

```
α < 1/2     (so log H = n^α = o(√n), satisfying Thm 1.1's hypothesis)
β ≥ 3/8     (else Cor. 1.2 refutes the AP version)
α ≥ 1 − 2β  (Umans–Wang §3)
```

Minimising the resulting exponent `max(α,β)/2` over that region
(`_scratch/r58/window.py`):

| | |
|---|---|
| refuted `(1/3, 1/3)` | exponent `1/6 = 0.1667` — **gone** |
| **surviving optimum `(1/4, 3/8)`** | exponent **`3/16 = 0.1875`** |
| Harvey's record | `1/5 = 0.2000` |

**But `(1/4, 3/8)` is not an interior point — it is exactly He–Sahai's boundary.**
Remark 4.3, verbatim: *"Corollary 1.2 makes no claim when `β = 3/8`. Indeed, the
lower bound `L ≫ n^{3/4}/√(log n)` does not exclude `L ≤ n^{3/4}`."*

And Umans–Wang's counting constraint is **exactly tight** there: `α + 2β = 1/4 +
3/4 = 1`, zero slack.

> **The entire surviving arithmetic-progression route is one knife-edge point
> `(1/4, 3/8)`, sitting simultaneously on He–Sahai's boundary and on
> Umans–Wang's counting boundary.** Any `β > 3/8` is safe but strictly worse;
> any `β < 3/8` is refuted.

That is a sharper statement than either paper makes about the other's content,
and it is a consequence I derived rather than read.

---

## 4. An error of mine, found by a subagent

Round 54 stated RSA-260 was **872 bits**. It is **862** (260 decimal digits). I
wrote the bit count from memory instead of computing `⌈260·log₂10⌉`. Corrected in
place in `Round54_Practicality.md` with a visible annotation.

The subagent's other correction is methodologically useful: *"any claimed
factoring advance whose supporting evidence is a press summary rather than a
fetched primary document should be labelled `UNVERIFIED`."* The RSA-260
*date* (Sept 2026, ~4900 GPU-days) currently rests on a Wikipedia-tier source in
our own corpus. **I have not verified it from a primary source and am not
asserting it.**

---

## 5. What I did *not* do, and a note on the fan-out

I fanned out three research subagents. **Two reported having no web access** and
answered from memory; I verified their two most consequential claims (the
He–Sahai paper exists and says what is claimed; the RSA-260 bit count) directly
against primary sources. The third **declined to answer rather than fabricate
verbatim quotes from a PDF it could not read** — the correct call, and I extracted
the paper myself and asked it to read the `.txt`.

**The one substantive claim from a memory-only agent that I have *not*
independently verified:** that rigorous smooth-number bounds (`Ψ(x,y) =
xρ(u)(1+O(log(u+1)/log y))`, Hildebrand 1986) are *not* the NFS bottleneck, and
that the real unproven step is "enough relations form a cycle in the relation
graph." That is plausible and consistent with Lee–Venkatesan's own caveat, but
it is a memory claim and I flag it as such rather than laundering it into the
record.

---

## 6. Verdict

**No new factoring algorithm. No improved bound.** But this round is the most
consequential of the ten, because it **removes a conditional result from the
board** that two earlier rounds were organised around:

- **Umans–Wang's conditional `N^{1/6}` is untouched** (rank-2 version not
  refuted), but **its AP construction route is dead at `(1/3,1/3)`**.
- The AP route's entire surviving window is the single point `(1/4, 3/8)`,
  giving at best `N^{3/16}` — and only if the rank-1 conjecture holds exactly on
  He–Sahai's boundary.

**This retroactively changes Rounds 49 and 50.** Round 49 §3 proved that
*consecutive* APs (`c = 1`) cannot beat `α = 1 − 2β`. He–Sahai proves far more —
that **no** AP works at `(1/3,1/3)`, at any `c` — and my Round 49 result should be
cited as the weak special case it is. Round 50 §6 ranked "the `c ≠ 1` cover" as
the top open item; that priority is now void for rank-1.

**Open, in order of expected value:**
1. **Rank-2 additive separability** — the residue He–Sahai explicitly leaves
   alive, and now the *only* route to any `N^{1/6}`-type result via
   Umans–Wang.
2. **The `N^{1/6}` pair-count question** (Round 50), unchanged.
3. **NFS non-triviality** (Rounds 55–57), unchanged.

Item 1 is the one that moved, and it moved because of work I did not know about
until a subagent told me to look. That is the honest lesson of this round: my
literature monitoring had a gap, and the gap had consequences.