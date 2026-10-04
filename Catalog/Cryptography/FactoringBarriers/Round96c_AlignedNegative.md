# Round 96c — the aligned construction: a negative result, and where it dies

**2026-10-04. Still NO new factoring algorithm and NO exponent improvement.** This
note pushes on the one channel round 96b left open — a **deliberately aligned**
GAP divisor cover — and reports an honest **negative result**: hill-climb
alignment finds full covers at `n=800` inside the beating window, but the cover
**does not persist as `n` grows**. It also *rules out* the simplest alignment
(single-point CRT) with a quantitative lcm-overshoot.

Empirical companion: `Experiments/UMWWindow/aligned_construct.py` (deterministic;
`out_aligned.txt` is the committed run). No new Lean: the obstructions here are
counting/measurement facts, and the counting wall is already machine-checked in
`UMWCountingWall.lean`.

---

## 1. What was attempted

The cover condition (from round 96b) is: for every `i ≤ n`, some `s∈S, t∈T`
with `i ∣ (s−t)`. A **rank-2 GAP cover** is

$$ S = \mathrm{AP}(a_1,d_1,L_1)+\mathrm{AP}(a_2,d_2,L_2),\quad
   T = \mathrm{AP}(b_1,e_1,L_1)+\mathrm{AP}(b_2,e_2,L_2),$$

so `|S| = |T| = L_1 L_2 ≈ n^γ`, each a sum of two APs (rank 2, satisfying the
Umans–Wang structure clause). The magnitude budget `M = exp(n^γ)` is enforced
**strictly**: any build whose largest element exceeds `M` is rejected, never
truncated. Coverage = fraction of `i ∈ [2,n]` dividing some difference.

---

## 2. A clean negative: single-point CRT alignment is infeasible

The simplest "aligned" idea is `T = {t_0}` and choose `S` so that, for every
maximal prime power `m = p^⌊log_p n⌋ ≤ n`, some `s ≡ t_0 (mod m)`. One `s` can
absorb many `m`'s only if their lcm is within budget. Partitioning the `139`
maximal prime powers (at `n=800, γ=0.39`) into bundles:

| quantity | value |
|---|---|
| maximal prime powers `≤ n` | 139 |
| bundles needed (`≈ n^{1−γ}`) | 59 |
| max per-bundle lcm | **4.85 × 10⁸** |
| budget `M = exp(n^γ)` | 7.73 × 10⁵ |

The per-bundle lcm **overshoots the budget by ~600×**. So a single-point `T`
**cannot** cover in the window — confirming, on this axis, that `T` must be a
genuine rank-2 GAP, exactly as Round 49's narrowing predicted.

---

## 3. The positive-looking hit, and why it dies

Hill-climbing the eight GAP generators does find, at `n=800, γ=0.36`
(`exponent = 0.180 < 1/5`), a **complete cover of every `i ∈ [2,800]`** in
roughly half the seeds, with `max(S), max(T) ≤ M` verified. This looked like a
sub-`1/5` construction. It is not.

**Scaling test** (same search, larger `n`, strict budget):

| `n` | γ=0.36 (exp 0.180) | γ=0.399 (exp 0.200) |
|---|---|---|
| 800 | 43% (seed-luck reaches 100%) | 61% (seed-luck reaches 100%) |
| 2000 | 39% | 58% |
| 5000 | **35%** | **54%** |

The full cover **does not persist**: coverage sits at 35–61% and *decays* with
`n`. The `n=800` full cover is a **small-n lucky hit**, not a scalable
construction — the same failure mode as round 96's budget-escape, caught here
by simply running larger.

For the record, the mechanism of the lucky hit: the winning `S,T` had all
`81` differences large (`~5×10⁴`) and *rich in small divisors*, so each
difference covered many `i`. That is luck about divisor structure, not
deliberate residue alignment, and it evaporates with `n`.

---

## 4. What this means

* **Hill-climb alignment buys a constant factor, not an exponent.** It improves
  the coverage *constant* over the random baseline of round 96b, but the
  covered fraction still decays in `n`, so it does not deliver an asymptotic
  cover below `γ = 1/2` (exponent `1/4`), let alone below `0.4`.
* This is **consistent with, but does not prove,** the round-96b birthday
  obstruction applying to *every* `n^γ`-sized cover for `γ < 1/2`. Proving that
  for structured GAPs is exactly the open negative I would want next.
* The **beating window `γ ∈ [1/3, 2/5)` remains un-entered by any construction
  found here.** The counting wall (round 96, machine-checked) is not the
  binding obstacle to a *specific* aligned cover; the obstacle is that no
  cover of these sizes has been exhibited.

---

## 5. Honest scope

* **No new factoring algorithm. No complexity beaten. Window not opened.**
* The single-point CRT overshoot (§2) is a clean, quantitative exclusion of the
  simplest alignment family.
* The scaling death of the hill-climb hit (§3) is the round's substantive
  result, and it is a **kill**: a promising-looking sub-`1/5` witness at small
  `n` that does not survive scaling. Recorded because a future agent will
  rediscover the `n=800` "799/800" and should know it is a fluke.
* **Not claimed:** that no GAP cover exists below `γ=0.4`; only that hill-climb
  alignment does not produce one, and that the small-`n` full cover is not a
  scalable phenomenon.

**Next attack.**
1. **Prove** the birthday obstruction for GAP covers: if `|S|=|T|=n^γ`,
   `γ<1/2`, and both are sums of `O(1)` APs, then some `i≤n` is uncovered.
   This would *close the window rigorously* — the single highest-value move.
2. Machine-check that obstruction in Lean (extending `UMWCountingWall.lean`).
3. If (1) is false, a counterexample search at moderate `n` with the gap
   enlarged to rank 3–4 APs, tracked strictly by budget and by `n`-scaling.