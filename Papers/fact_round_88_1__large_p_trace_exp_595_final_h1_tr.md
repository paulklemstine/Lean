# Computational evidence — ECM stage-1 order completion vs. the collision floor

All numbers below were produced by `#eval` inside this Lean project (kernel-evaluated
`ℕ` arithmetic, no external scripts, no floating point). The script is reproduced at the
end; it uses only the definitions of `Catalog/Shared/ECMStage1*.lean`. Rates and
positions are reported in per-mille (integer division), so `226` means `0.226`.

Model. Following the standard picture, the group of points of a curve over `𝔽_p` has an
order `m` in the Hasse interval `[p+1-2√p, p+1+2√p]`; we sweep *all* `4⌊√p⌋+1` candidate
orders in that interval (a deterministic census, not a sample), and for each order use
the exact quantities proved in the Lean files:

* firing count at bound `B` = `gcd(m, k(B))`, `k(B) = stage1Scalar B`
  (`ECMStage1.card_firingSet`);
* firing position of the smooth part = `π(lpf(gcd(m,k(B)))) / π(B)`
  (`ECMStage1.firingCutoff_isLeast`).

## 1. Small-case sanity checks

| quantity | value |
|---|---|
| `stage1Scalar 10` | `2520 = 2³·3²·5·7` |
| `π(50)` | `15` |
| staircase `C ↦ gcd(720, stage1 10 C)`, `C = 0..10` | `1, 1, 8, 72, 72, 360, 360, 360, 360, 360, 360` |
| staircase `C ↦ gcd(5040, stage1 50 C)`, `C = 0..12` | `1, 1, 16, 144, 144, 720, 720, 5040, 5040, …` |

The staircases jump only at `C ∈ {2,3,5}` resp. `{2,3,5,7}` — exactly the prime divisors
of the order that are `≤ B`, which is the content of
`ECMStage1.jumpSet_eq_primeFactors_filter`. Of the four schedule primes below `B = 10`,
only three do anything for `m = 720`; of the fifteen primes below `B = 50`, only four do
anything for `m = 5040`. This is the "flat in `B1frac`" behaviour, visible in a single
cell.

## 2. Rate census over the Hasse interval

`p = 1009` (125 candidate orders):

| `B` | 8 | 32 | 58 |
|---|---|---|---|
| mean firing rate `gcd(m,k(B))/m` | `0.012` | `0.226` | `0.335` |
| orders that are fully `B`-powersmooth | `0/125` | `26/125` | `40/125` |
| collision heuristic `1.44·B/p` | `0.011` | `0.045` | `0.082` |

`p = 65521` (1021 candidate orders):

| `B` | 40 | 128 | 230 |
|---|---|---|---|
| mean firing rate | `0.021` | `0.143` | `0.229` |
| collision heuristic `1.44·B/p` | `0.0009` | `0.0028` | `0.0050` |

Reading. At the larger scale the exact order-completion rate exceeds the collision
heuristic by factors `23×`, `51×`, `46×`; at the smaller scale by `1.1×`, `5.0×`, `4.1×`.
The excess *grows* with scale, which is the opposite of a collapse toward the collision
baseline. The theorem `ECMStage1.orderCompletion_exceeds_collision_baseline` turns this
comparison into an unconditional implication (`1 - exp(-x) ≤ x`), and
`orderCompletion_beats_collision_heuristic` records an explicit `>25×` instance.

## 3. Firing-position census (early fire)

Normalized position `π(lpf(smooth part))/π(B)`, over the same Hasse censuses:

| | `p = 1009` | | | `p = 65521` | | |
|---|---|---|---|---|---|---|
| `B` | 8 | 32 | 58 | 40 | 128 | 230 |
| median position | `0.500` | `0.272` | `0.187` | `0.250` | `0.129` | `0.100` |
| fraction with position `≥ 0.8` | `0.144` | `0.104` | `0.080` | `0.090` | `0.062` | `0.053` |

Reading. Medians are well below `0.5` and *decrease* with the dose, and the late tail is
below `15%` everywhere — the same qualitative shape at both scales, deepening with dose.
The `p = 1009, B = 8` cell has median exactly `0.5`, which is the small-schedule artefact
one expects (`π(8) = 4`, so positions are quantized to quarters).

## 4. Counterexample hunt

* *Claim tested*: "the firing count is monotone in the bound." A census over all
  `1 ≤ m < 2000` and `B ≤ 100` found `0` orders with any decrease — and it is now a
  theorem (`ECMStage1.gcd_stage1Scalar_dvd_of_le`).
* *Claim tested*: "the firing count changes at every schedule prime." Refuted immediately
  by `m = 720`, `B = 10` at `C = 7` (count stays `360`); the exact statement of when it
  changes is `ECMStage1.jumpSet_eq_primeFactors_filter`.
* *Claim tested*: "splitting the order into two cyclic factors cannot increase the
  firing count." Refuted: `m₁ = m₂ = 4`, `k = 2` gives `gcd(16,2) = 2 < 4 = gcd(4,2)²`.
  The correct inequality is `ECMStage1.rank_two_fires_at_least_as_often`.

No OEIS sequence is involved: the objects here are `gcd(m, k(B))` staircases, which are
two-parameter families rather than a single integer sequence.

## 5. The evaluation script

```lean
import Catalog.Shared.ECMStage1DoseResponse
open ECMStage1

def primesUpto (C : ℕ) : List ℕ := (List.range (C+1)).filter Nat.Prime
def piC (C : ℕ) : ℕ := (primesUpto C).length
def smoothPart (m B : ℕ) : ℕ := Nat.gcd m (stage1Scalar B)
def lpfN (n : ℕ) : ℕ := n.primeFactors.sup id
def hasseOrders (p : ℕ) : List ℕ :=
  let s := Nat.sqrt p
  (List.range (4*s+1)).map (fun i => p + 1 - 2*s + i)
def rateFull (p B : ℕ) : ℕ × ℕ :=
  let l := hasseOrders p
  ((l.filter (fun m => smoothPart m B == m)).length, l.length)
def meanRate1000 (p B : ℕ) : ℕ :=
  let l := hasseOrders p
  (l.map (fun m => 1000 * smoothPart m B / m)).sum / l.length
def positions (p B : ℕ) : List ℕ :=
  (hasseOrders p).map (fun m => 1000 * piC (lpfN (smoothPart m B)) / piC B)
def median (l : List ℕ) : ℕ := (l.mergeSort (· ≤ ·)).getD (l.length/2) 0
def tail80 (l : List ℕ) : ℕ := 1000 * (l.filter (fun x => 800 ≤ x)).length / l.length

#eval (meanRate1000 1009 8, meanRate1000 1009 32, meanRate1000 1009 58)
#eval (median (positions 1009 8), median (positions 1009 32), median (positions 1009 58))
#eval (tail80 (positions 1009 8), tail80 (positions 1009 32), tail80 (positions 1009 58))
#eval (meanRate1000 65521 40, meanRate1000 65521 128, meanRate1000 65521 230)
#eval (median (positions 65521 40), median (positions 65521 128), median (positions 65521 230))
#eval (tail80 (positions 65521 40), tail80 (positions 65521 128), tail80 (positions 65521 230))
#eval (List.range 11).map (fun C => Nat.gcd 720 (stage1 10 C))
```

Status of these numbers: they are kernel evaluations of computable definitions, so they
are reliable as arithmetic, but they are *evidence*, not proof. Every claim that this
project asserts as a result is a theorem in `Catalog/Shared/ECMStage1*.lean` with no
`sorry` and only the standard axioms.
