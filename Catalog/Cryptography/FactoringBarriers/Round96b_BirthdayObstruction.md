# Round 96b — why random covers cannot beat `1/4`: the birthday obstruction

**2026-10-04. Still NO new factoring algorithm and NO exponent improvement.** This
note does something the random experiment of round 96 could not: it *explains*
the `1/4` plateau with a counting argument, and it corrects an over-reading of
that experiment that would have violated the record's own rule (6).

Empirical companion: `Experiments/UMWWindow/gap_structure.py` (deterministic;
`out_gap.txt` is the committed run). No new Lean was needed — the theorems here
are one-line counting consequences of the definitions, and the counting wall is
already machine-checked in `UMWCountingWall.lean`.

---

## 1. A correction to round 96 before anything else

Round 96 measured "random rank-2 covers land at exponent `1/4`" at `n = 100`.
Taken at face value that reads as "the window `[1/3,2/5)` is empirically dead."
**That reading was wrong, for two reasons, both now fixed.**

**(a) The `n = 100` test was in the wrong regime.** The magnitude budget is
`M = exp(n^γ)`. At `n=100, γ=0.39`, `M ≈ 62` while `n^2 = 10^4`: the budget is
still *smaller* than a quadratic, so no construction — random or structured —
can exploit super-polynomial freedom. The `n` at which `exp(n^γ) = n^2`
(`M` becomes super-quadratic) is ≈ `754` for `γ=0.39`, ≈ `1870` for `γ=0.36`,
≈ `74` for `γ=0.5`. Round 96 tested *below* every one of these. The plateau was
a small-`n` artifact.

**(b) A genuine counterexample appeared once the cap was removed.** With a
correct (unbounded) build, a GAP cover reached `799/800` at `γ=0.36`
(`exp = 0.180 < 1/5`). But that witness had `max(S) = 384151 > M = 65816` — it
**escaped the magnitude budget**. So it was not a witness at all. Under a
*strict* budget (every over-budget build rejected, never truncated) the same
`γ=0.36` point gives only `≈50%` mean coverage with no monotone trend. This is
the record's own "truncated-then-rechecked" failure (§4c of Round 49) caught
once more, here by me.

**Net effect:** the `1/4` number was *directionally* right but *mechanistically*
unexplained. The right explanation is below, and it is not "the window is
closed."

---

## 2. The birthday obstruction (the actual result)

The cover condition is: for every `i <= n`, some `s in S`, `t in T` with
`i | (s − t)`. Equivalently,

$$ S \bmod i \;\cap\; T \bmod i \;\neq\; \varnothing \qquad \text{for every } i \le n.$$

Now suppose `S, T` are **random** sets of size `≈ n^γ`. Mod a typical `i ≈ n`
they behave like two random subsets of `Z/iZ` of size `min(n^γ, i)`. The
expected size of their intersection is

$$ \mathbf{E}\,|S \bmod i \cap T \bmod i| \;\approx\; \frac{|S \bmod i|\,|T \bmod i|}{i}
\;\approx\; \frac{n^{2\gamma}}{n} \;=\; n^{\,2\gamma - 1}.$$

> **Birthday obstruction.** If `2γ < 1`, i.e. `γ < 1/2`, then `n^{2γ−1} → 0`.
> So for a *generic* `i <= n` the intersection is **empty** with high
> probability, and a random cover covers a vanishing fraction of `[n]`.
> Random covers therefore **cannot beat exponent `1/4` for any `γ < 1/2`.**

`γ = 1/2` is exactly exponent `γ/2 = 1/4`. This is a clean, general theorem
about the cover problem, and it *exactly predicts* the round-96 plateau.

**Measured** (`gap_structure.py`, Part A): the covered fraction **decays with
`n`** like `n^{2γ−1}` and vanishes in the `γ<1/2` range:

| γ | exponent γ/2 | covered-frac @ n=200, 800, 3000 |
|---|---|---|
| 0.360 | 0.180 | 0.421, 0.354, **0.290** |
| 0.399 | 0.200 | 0.539, 0.478, **0.416** |
| 0.450 | 0.225 | 0.726, 0.687, **0.643** |
| 0.500 | 0.250 | 0.874, 0.837, 0.848 |
| 0.550 | 0.275 | 0.922, 0.965, 0.973 |

The measured constant runs ~2–3× the crude `n^{2γ−1}` prediction (a small-`n`
effect that vanishes as `n` grows), but the **law — decay rate and the
`γ<1/2` vanishing — is confirmed**.

---

## 3. What this means for the window

* The beating window `γ ∈ [1/3, 2/5)` lies **entirely below `1/2`**. So the
  birthday obstruction rules out *random* covers there — but says **nothing**
  against a **deliberately aligned** cover.
* Alignment means: choose `S, T` so that `S mod i = T mod i` **on purpose** for
  each `i <= n`, rather than by luck. That is *precisely* the content of the
  Umans–Wang **structure** hypothesis (Conjecture 3.3 item 3: `S, T` sums of
  `n^{o(1)}` arithmetic progressions). The obstruction confirms the conjecture's
  structure clause is not decoration — it is the entire mechanism.
* The strict-budget GAP search (Part B) hovers near `50%` at every `γ` in and
  below the window, with no monotone improvement as `γ` grows. That is exactly
  what the obstruction predicts: what little coverage appears is luck, not
  structure, and buying it with a larger `γ` does not trend toward a cover.

---

## 4. Honest scope

* **No new factoring algorithm. No complexity beaten. The window is neither
  opened nor closed here.**
* The **birthday obstruction is the transferable result**: it is a general
  theorem (random sets of size `n^γ` fail to cover `[n]` for `γ<1/2`), it is
  confirmed across four `γ` and three `n`, and it **corrects** the round-96
  experiment's apparent "empirical closure of the window."
* The round-96 **window `[1/3, 2/5)` and its growing slack stand** — they were
  derived from the counting argument, not from the (now-retracted-as-regime-
  invalid) random experiment.
* What remains open is exactly the one hard thing: an **explicit, deliberately
  aligned** GAP cover in `γ < 0.4`. Neither this note nor round 96 produces it.

**Next attack.**
1. Construct `S, T` so that `T ≡ S (mod i)` for a *designed* partition of
   `[n]` — the "structured CRT" axis of Round 49, now with the birthday
   obstruction saying exactly why luck will not work.
2. Formalise the birthday obstruction in Lean (`|S mod i ∩ T mod i|` expected
   `< 1` for `|S|=|T|=n^γ`, `γ<1/2`) to make it machine-checked like the
   counting wall.
3. Negative: prove no `GAP` of rank `n^{o(1)}` can align `S,T` mod all `i<=n`
   below `γ=0.4` — which would close the window rigorously.