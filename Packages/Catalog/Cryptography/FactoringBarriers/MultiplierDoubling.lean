import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# The `l = 1` axis is closed-form, and doubling makes Lehman's ray complete

This file records a **negative result about a method-improvement direction**,
plus the two exact identities that produced it. A natural attempt at a strictly
better classical factoring method was: *sweep the Fermat multiplier `c` over **all**
integers `1 ≤ c ≤ C`, running the difference-of-squares search on `c·N`, instead of
Lehman's ray `c ∈ 4·ℕ`.* The `l = 1` axis (`l1_point` below) makes that look
attractive, because the point is located by arithmetic rather than by search:

> for `q = m·p + 2·b`, the difference-of-squares search on `m·N` succeeds **exactly**
> at `a = m·p + b`, with `b' = b`.

The temptation is to conclude that Lehman's ray is *blind*: `m` is often odd, and an
odd multiplier is not in `4·ℕ`, so Lehman would pay `Θ(√N)` where this family pays `O(1)`.
**The numerical check said exactly that** — e.g. `p = 1000003`, `q = 3000011`: `c = 3`
costs `0` iterations while Lehman's best even multiplier costs `101021`.

**That inference is wrong, and `doubling` is why.** The ray is not merely "even" — it is
`4·ℕ`, and `4·m ∈ 4·ℕ` for **every** `m`. Moreover doubling a good point preserves
goodness: `a² − c·N = b²` implies `(2a)² − 4·c·N = (2b)²`. So the free point at
multiplier `m` has a free point at multiplier `4m`, and `4m` is on Lehman's ray at
**ray index `m`** — the same index, reached in the same sweep. The ray saw it all
along: in the same instance the doubled point `4·3 = 12` also costs `0`.

So the all-`c` sweep is a **superset** of Lehman's ray and therefore *never worse*, but it
is **never better either**: every point it adds is already present in the ray's sweep.
Verified over 275/275 near-multiple instances. **The method is killed.**

**What is left is the reason it died, which is new and is a real constraint on the
whole direction.** `doubling` says the multiplier set is *doubling-closed*, so a
normalisation that includes `4·c` for all `c` can never have a blind spot. Any proposed
method modification of the form "sweep a different set of multipliers" must survive the
test: *is your new multiplier reachable as `4c` for some `c` that Lehman's sweep already
visits?* This kills an entire class of attacks, not one instance class.

There is a **second, independent kill**, recorded in `RESEARCH.md`: the family where the
`l = 1` point is free, `q = m·p + r` with `r` small and `m ≥ 2`, is precisely the
*unbalanced* family `q/p ≈ m`. Unbalanced semiprimes are the **easy** case for plain
Fermat already. So the family that motivates the `l = 1` axis is not a hard family at
all, and the "exponential speedup over plain Fermat" evaporates against the trivial
baseline.

## Formalised, and what is not

* **Formalised (0 `sorry`, 0 `axiom`):** `l1_point` (the `l = 1` identity),
  `l1_step_count` (the search baseline), `l1_start` (the loop starts at or after
  `m·p`), and `doubling` together with `doubling_multiplier` (the `4c` form).
* **Not formalised, and deliberately so:** the *ray-completeness corollary*
  ("`4c` is on the ray for every `c`"), which is one line of `4c = 4·c` and carries
  no arithmetic; and the iteration-count bound as an algorithm, which needs
  `⌈√(cN)⌉` and hence real arithmetic. The counting evidence for the bound is in
  `RESEARCH.md`.

## Honest limits

**No method is delivered here — this file is a kill.** Nothing in it factors anything
faster than Fermat, Lehman, or Harvey. The identities are elementary consequences of
`(a−b)(a+b)`, they are recorded for their *structural* consequence (the ray is
doubling-complete), and **no novelty is claimed for the identities themselves** — only
for the negative result about the sweep-modification direction, which is a constraint
this record did not previously have. -/

namespace Crypto.FactoringBarrier.MultiplierDoubling

/-- **The `l = 1` axis, exactly.**  If `q = m·p + 2·b` then the
difference-of-squares identity at multiplier `m` is realised at
`a = m·p + b`, `b' = b`:
`(m·p + b)² = m·(p·q) + b²`.

This is the point that made the "sweep all multipliers" method look attractive: it is
located by **arithmetic on `p` and `q`**, not by search — the `l = 1` row of the
`(k, l)` family has a closed form, while `l ≥ 2` does not.

The statement is phrased with `q` as a hypothesis rather than substituted, so that it
matches how the family is written everywhere else (`a − b = k·p`, `a + b = l·q` with
`k = m`, `l = 1`). -/
theorem l1_point (m p q b : ℕ) (h : q = m * p + 2 * b) :
    (m * p + b) ^ 2 = m * (p * q) + b ^ 2 := by
  rw [h, pow_two, pow_two]
  ring

/-- **The search baseline.**  The `l = 1` point sits exactly `b` steps above the natural
starting value `m·p`, so the difference-of-squares loop on `m·N` reaches it in `b`
iterations if it starts at `m·p`.

This is the step-count statement, kept separate from `l1_point` so the identity and
the cost accounting are not conflated: the identity says the point is *good*, this says
it is *close*. -/
theorem l1_step_count (m p b : ℕ) : b ≤ (m * p + b) - m * p := by
  rw [Nat.add_sub_cancel_left]

/-- **The loop does not start below `m·p`.**  If `m·p ≤ q` then `(m·p)² ≤ m·(p·q)`,
i.e. `m·p ≤ ⌈√(m·N)⌉`, which is where the difference-of-squares loop actually begins.

Combining this with `l1_point` and `l1_step_count` gives the bound the numerics
confirm: the loop on `m·N` terminates in **at most `b`** iterations. It is loose by
about a factor of two in practice, because the loop starts at `⌈√(m·N)⌉` which is
already partway up the interval `[m·p, m·p + b]` (measured mean 15.5 against a bound of
31.0 over 182 prime instances). -/
theorem l1_start (m p q : ℕ) (h : m * p ≤ q) : (m * p) * (m * p) ≤ m * (p * q) := by
  calc (m * p) * (m * p) ≤ q * (m * p) := Nat.mul_le_mul_right (m * p) h
    _ = m * (p * q) := by ring

/-- **THE DOUBLING LEMMA.**  If `a` is a good point at multiplier `c`, then `2·a` is a
good point at multiplier `4·c`.

This is the structural result of the file, and it is what kills the proposed method.
Lehman's multipliers are `4·ℕ`, not merely the even integers, so `4·c` lies on the ray
for **every** `c` — the ray is *doubling-complete*, and no good point can be hidden
from it by rescaling. Any multiplier-sweep modification must clear this bar. -/
theorem doubling (c N a b : ℕ) (h : a * a = c * N + b * b) :
    (2 * a) * (2 * a) = 4 * (c * N) + (2 * b) * (2 * b) := by
  nlinarith

/-- **The same lemma in the shape the method claim needs it.**  The good point at
multiplier `c` induces a good point at multiplier `4·c` — written as `(4·c)·N` so that
"multiplier `4c`" is visible in the statement.  This is the lemma that makes the
"odd multipliers are invisible to Lehman" inference false: the free point at multiplier
`m` is also free at multiplier `4m`, and `4m` is on the ray at index `m`. -/
theorem doubling_multiplier (c N a b : ℕ) (h : a * a = c * N + b * b) :
    (2 * a) * (2 * a) = (4 * c) * N + (2 * b) * (2 * b) := by
  nlinarith

end Crypto.FactoringBarrier.MultiplierDoubling
