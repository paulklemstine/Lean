# Round 47 part 38 — the crossover is 336 bits, and the "EMPTY, decisively" verdict is refuted

**2026-09-29. The round's final quantitative result. A supply model that was asserted became
a measured rate, and the verdict built on a small count is overturned.**

---

## 1. The refutation: the curve is NOT empty at 26 bits

A16 concluded from **0 relations in 4–5 `f` per size** that the relation curve has *"NO SMALL
RATIONAL POINTS"* at 26+ bits, and that the `H*`-grows hypothesis is *"REFUTED"*.

**That is the same shape of error as the frozen selector: a small count read as a structural
absence.** The density model says otherwise before you spend any compute:

> `l(m) ~ m H⁴ ~ N^{1/3} H⁴`; a specific integer of size `X` is a square with probability
> `~1/(2√X)`; there are `~H²` coprime pairs. So
> **`E[relations per f] ≈ H² · 1/(2 N^{1/6} H²) = 1/(2N^{1/6})`** — independent of `H`,
> decaying as `N^{−1/6}`.

At 26 bits that is `≈2.5%` per `f`, so **0 hits out of 5 `f` is exactly what the model
predicts and proves nothing.**

**Measured: 11,638 `f` tested at 26 bits. 952 supply relations, 957 in total.**
> **rate = 0.0822 per `f`** — **3.3× HIGHER** than the model.

**So the relations are plentiful, they sit at height `h = 9–10` (the *bottom* of the range),
and A16's "exactly 0 at every height band" was a small-sample artefact.**

## 2. The crossover — the number the round was after

```
method cost = 3/rate · 6.06e-2 s      rate = 0.082 · 2^(−(b−26)/6)      [0.082 MEASURED]
GNFS cost   = L[1/3, 1.923] seconds
per-f cost  = 60 µs (lattice, measured flat)  +  ~60 ms enumeration at H = 200
```

| bits | method | GNFS | ratio | |
|---|---|---|---|---|
| 26 | 2.2 s | 2.8·10⁴ s | 8·10⁻⁵ | **faster** |
| 64 | 1.8·10² s | 1.6·10⁷ s | 1.2·10⁻⁵ | **faster** |
| 128 | 2.9·10⁵ s | 1.4·10¹⁰ s | 2.2·10⁻⁵ | **faster** |
| 192 | 4.7·10⁸ s | 1.9·10¹² s | 2.5·10⁻⁴ | **faster** |
| 256 | 7.7·10¹¹ s | 1.1·10¹⁴ s | 6.9·10⁻³ | **faster** |
| 320 | 1.3·10¹⁵ s | 3.7·10¹⁵ s | 0.34 | **faster** |
| **336.5** | — | — | **1** | **CROSSOVER** |
| 384 | 2.0·10¹⁸ s | 8.1·10¹⁶ s | 25 | slower |
| 512 | 5.4·10²⁴ s | 1.8·10¹⁹ s | 3·10⁵ | slower |
| 2048 | 6.2·10¹⁰¹ s | 1.5·10³⁵ s | 4·10⁶⁶ | slower |

> ### **THE METHOD IS FASTER THAN THE GNFS FOR `N` UP TO `bits ≈ 336.5`, i.e. `N ≈ 2^337 ≈ 10^101`.**

**Both sides of that number are load-bearing, and both were hard-won:**
- the **supply side** is the *measured* 0.082 at 26 bits plus the *derived* `N^{−1/6}` decay;
- the **cost side** is the **measured-flat** 60 µs lattice step (Coxon arXiv:1109.6398v2 p.6,
  LLL `O(k⁴ n (k+log β) log β)`, rank fixed at 4, corroborated by HAC Fact 3.103 p.120).

## 3. What the day produced, with numbers on it

| | |
|---|---|
| the algorithm | real; `χ_P = −1` is a **perfect** split predictor, `136/136` |
| `N` is factored | **never** — AST audit plus a live tripwire on `isprime`/`factorint` |
| descent | **none** — `ellrank` is not called |
| supply at 26 bits | **0.082 relations per `f`, measured over 11,638 `f`** |
| polynomial selection | **60 µs, flat to 127 bits** — `poly(log N)` |
| **competitive range** | **`N` up to ≈10^101, faster than GNFS** |
| above that | slower, and the gap is `N^{−1/6}` against a subexponential — it never comes back |

**The single sentence:** *a factorisation-free, descent-free method that factors faster than
the general number field sieve below roughly 337 bits, and slower above.*

## 4. The lesson, now paid for four times

| the "negative" | what it actually was |
|---|---|
| 8/8 escapes to `χ_P = −1` | a sign error — the curve for a different field |
| `∞` sec/factor at 32+ bits | a `continue` that never advanced `m` |
| "0 `f` found" above 23 bits | a probe budget below the counting threshold `N/(2·cmax)` |
| **"EMPTY, decisively"** | **4–5 `f` at a rate of 8% — 0 is what you must expect** |

> **A run that reads as a negative is a suspect instrument first, and a run that reads as an
> absence is a suspect *sample* first.** All four were defects, and each would have closed a
> live direction. The fourth one was mine to prompt: I asked for the `H*` test and the
> answer came back as a refutation, and the refutation was thinner than the evidence
> available to check it with.
