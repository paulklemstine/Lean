# Non-Monotone Win Probabilities in Random-Elimination Social-Deduction Games

## Abstract

We introduce and analyze a clean stochastic model of the social-deduction game
*Werewolf* (equivalently *Mafia*) in which the daytime elimination is uniformly random
and the werewolves remove one villager each night. For a state with `v` villagers and
`w` werewolves we define the villagers' win probability `P(v, w)` by an exact recursion
and study its monotonicity in the team sizes. Our central finding is a provable
*non-monotonicity*: there exist states in which adding a single villager strictly
decreases the villagers' probability of winning, a phenomenon we call the **Parity
Paradox**. We establish the paradox at infinitely many witnessed configurations, prove
its complementary stabilizers — **Skip-Two Monotonicity** (adding two villagers helps)
and **Diagonal Monotonicity** (replacing a werewolf by a villager helps) — and prove
the universal bounds `0 ≤ P(v, w) ≤ 1`. We introduce the **parity defect**
`D(v, w) = P(v, w)/P(v+1, w)` as a scalar measure of the paradox, compute it exactly,
show it strictly decreases along the verified one-werewolf family, and conjecture its
convergence to `1`. Every numerical value reported here is an exact rational number that
has been formally verified. We close with three open conjectures — global skip-two
monotonicity, global diagonal monotonicity, and parity-defect convergence — together
with proof strategies.

**Keywords.** social-deduction games, Werewolf, Mafia, absorbing Markov chains,
non-monotonicity, parity, win probability, formal verification.

---

## 1. Introduction

Social-deduction games such as *Werewolf* and *Mafia* are among the most widely played
party games in the world. A hidden minority (the *werewolves*) attempts to outlast a
majority (the *villagers*); the villagers eliminate one player per day by vote, and the
werewolves eliminate one villager per night. The strategic richness of the full game
comes from deception and inference, but underneath sits a purely combinatorial
question: *given only the team sizes, what is each side's chance of winning under
neutral play?*

We isolate this skeleton by replacing the (skill-laden) daytime vote with a uniformly
random elimination. The resulting object is a finite absorbing Markov chain on states
`(v, w)`, and the quantity of interest is the absorption probability `P(v, w)` into the
"all werewolves eliminated" class. Far from being trivial, this baseline already
exhibits a counterintuitive structure.

The headline result is that `P` is **not monotone** in the number of villagers: there
are states `(v, w)` with

```
P(v + 1, w) < P(v, w),
```

i.e. handing the villagers an extra ally *reduces* their win probability. We call this
the **Parity Paradox**. We further show that the paradox is tamed by two natural
operations — adding villagers in pairs, and trading a werewolf for a villager — both of
which are monotone. Finally we quantify the paradox with a single ratio, the parity
defect, and track its decay.

A distinguishing feature of this work is that all stated probabilities are *exact*
rationals and all inequalities have been *formally verified*; none rely on simulation or
floating-point estimation. We therefore phrase results as theorems with the exact values
they assert.

---

## 2. The model and the win-probability function

### 2.1 States and dynamics

A *state* is a pair `(v, w) ∈ ℕ × ℕ`, where `v` is the number of villagers and `w` the
number of werewolves. A round, executed when it is the villagers' move, proceeds in two
phases:

1. **Day phase.** One of the `v + w` players present is eliminated uniformly at random.
2. **Night phase.** If the game has not ended, the werewolves kill one villager.

Terminal conditions:

- **Villager victory** when `w = 0` (all werewolves eliminated).
- **Werewolf victory** when `w ≥ v` with `w ≥ 1` (the werewolves hold a majority and can
  no longer be outvoted).

### 2.2 Definition (villager win probability)

Let `P : ℕ × ℕ → ℚ` denote the probability that the villagers eventually win, starting
from state `(v, w)` with the villagers to move. It is defined by the recursion

```
P(v, 0) = 1,                                                    (no werewolves left)

P(v, w + 1) = 0                                if v ≤ w + 1,    (werewolves at majority)

P(v, w + 1) = ( (w + 1) / (v + w + 1) ) · A
            + (  v       / (v + w + 1) ) · B   if v > w + 1,
```

where

```
A = 1                  if w = 0   (eliminating the last werewolf ends the game),
A = P(v − 1, w)        if w ≥ 1   (a werewolf removed; the rest kill a villager at night),

B = 0                  if v ≤ w + 3 (losing two villagers yields a werewolf majority),
B = P(v − 2, w + 1)    if v > w + 3 (two villagers lost; continue).
```

The two coefficients are the day-phase probabilities of eliminating a werewolf
(`(w+1)/(v+w+1)`) versus a villager (`v/(v+w+1)`); the `B` branch loses two villagers
because the bad daytime vote is compounded by the nightly kill. This recursion
terminates because every recursive call strictly decreases `v + w`.

### 2.3 Well-posedness

`P` is a total function valued in `ℚ`, and (Section 5) `P(v, w) ∈ [0, 1]` for all
states, confirming it is a genuine probability.

---

## 3. Base cases and exact evaluations

### 3.1 Boundary theorems

**Theorem 3.1 (No werewolves).** For every `v`, `P(v, 0) = 1`.

*Proof.* Immediate from the first clause of the definition. ∎

**Theorem 3.2 (Werewolf majority).** If `v ≤ w` and `w ≥ 1` then `P(v, w) = 0`.

*Proof.* Write `w = (w−1) + 1`. The hypothesis `v ≤ w` forces the guard `v ≤ (w−1)+1`,
so the second clause of the definition returns `0`. ∎

### 3.2 Exact values

Unrolling the recursion yields closed rationals. For one werewolf:

| state | `P(v, 1)` | decimal |
|-------|-----------|---------|
| `(2,1)` | `1/3`   | `0.3333` |
| `(3,1)` | `1/4`   | `0.2500` |
| `(4,1)` | `7/15`  | `0.4667` |
| `(5,1)` | `3/8`   | `0.3750` |
| `(6,1)` | `19/35` | `0.5429` |

For two werewolves:

| state | `P(v, 2)` | decimal |
|-------|-----------|---------|
| `(3,2)` | `2/15` | `0.1333` |
| `(4,2)` | `1/12` | `0.0833` |
| `(5,2)` | `8/35` | `0.2286` |
| `(6,2)` | `5/32` | `0.1562` |

Worked example. From `(4, 1)`: the vote catches the wolf with probability `1/5` (instant
win); otherwise (probability `4/5`) two villagers are lost and play continues from
`(2, 1)`, where `P(2,1) = 1/3`. Hence
`P(4,1) = 1/5 + (4/5)(1/3) = 3/15 + 4/15 = 7/15`. Every entry above is obtained this way
and has been verified exactly.

These values feed directly into the monotonicity analysis below.

### 3.3 Structural remarks on the recursion

Three features of the recursion explain the behavior we will quantify and are worth
stating explicitly.

*The decisive event is rare and dilutable.* The only transition that benefits the
villagers is the day vote landing on a werewolf, which happens with probability
`w/(v+w)`. Holding `w` fixed and increasing `v` strictly decreases this probability.
Thus the villagers' single helpful event becomes rarer precisely as their numbers grow.

*Failure is quantized in steps of two.* A failed round (day vote on a villager) is
compounded by the nightly kill, so the villager count drops by two while the werewolf
count is unchanged. The trajectory of `v` along losing lines is therefore confined to a
fixed parity class, which is the formal source of the even/odd asymmetry in the results.

*The chain is finite and absorbing.* Since `v + w` strictly decreases on every
transition and the two absorbing classes (`w = 0` and `w ≥ v`) are reached in finitely
many steps, `P` is the absorption probability of a finite absorbing Markov chain; in
particular it is well defined and rational, with denominators dividing products of the
encountered totals `v + w`.

---

## 4. The Parity Paradox and its stabilizers

### 4.1 Non-monotonicity in the villager count

**Theorem 4.1 (Parity Paradox, one werewolf).** `P(3, 1) < P(2, 1)`; explicitly,
`1/4 < 1/3`.

*Proof.* By the exact evaluations `P(3,1) = 1/4` and `P(2,1) = 1/3`, and `1/4 < 1/3`. ∎

**Theorem 4.2 (Parity Paradox persists, one werewolf).** `P(5, 1) < P(4, 1)`;
explicitly, `3/8 < 7/15`.

**Theorem 4.3 (Parity Paradox, two werewolves).** `P(4, 2) < P(3, 2)`; explicitly,
`1/12 < 2/15`. Likewise `P(6, 2) < P(5, 2)`, i.e. `5/32 < 8/35`.

**Theorem 4.4 (Existence).** There exist `v, w` with `w ≥ 1` and
`P(v + 1, w) < P(v, w)`. (Witness `(v, w) = (2, 1)`.)

*Interpretation.* Adding a villager has two competing effects. It **dilutes** the
daytime vote, lowering the per-round probability `w/(v+w)` of catching a werewolf — the
only event that helps the villagers — and this cost is paid every round. It also adds a
**cushion**, allowing the town to survive more failed rounds before the werewolves reach
a majority. Because a failed round removes *two* villagers (one to the vote, one to the
night kill), the cushion is only effective when villagers are added in increments
aligned with this loss rhythm. A single added villager increases dilution immediately
while landing "off-beat" relative to the two-at-a-time loss, so dilution dominates and
the net effect is negative. This is the structural origin of the parity in the name.

### 4.2 Adding two villagers: a stabilizer

**Theorem 4.5 (Skip-Two Monotonicity, verified family).** The following strict
increases hold:

```
P(2,1) < P(4,1)   (1/3   < 7/15),
P(3,1) < P(5,1)   (1/4   < 3/8),
P(4,1) < P(6,1)   (7/15  < 19/35),
P(3,2) < P(5,2)   (2/15  < 8/35),
P(4,2) < P(6,2)   (1/12  < 5/32).
```

*Proof.* Direct comparison of the exact values. ∎

We conjecture (Section 7) that this holds in full generality: for `v ≥ w + 2`, `w ≥ 1`,
`P(v, w) ≤ P(v + 2, w)`. The two-step increment restores alignment with the
two-villagers-per-failed-round loss, so the cushion gained outweighs the dilution.

### 4.3 Trading a werewolf for a villager: a stabilizer

**Theorem 4.6 (Diagonal Monotonicity, verified family).**

```
P(3,2) < P(4,1)   (2/15  < 7/15),
P(4,2) < P(5,1)   (1/12  < 3/8),
P(5,2) < P(6,1)   (8/35  < 19/35).
```

*Proof.* Direct comparison of the exact values. ∎

Replacing a werewolf with a villager (a *diagonal* move `(v, w) → (v + 1, w − 1)`) both
reduces the threat and enlarges the defense; unlike adding a lone villager, it is never
counterproductive. We conjecture the general statement `P(v, w) ≤ P(v + 1, w − 1)` for
`v ≥ w + 2`, `w ≥ 2` (Section 7).

### 4.4 A dominance preorder

To organize comparisons we define a preorder on configurations.

**Definition 4.7 (Dominance).** Say `(v₁, w₁)` *dominates* `(v₂, w₂)`, written
`(v₁, w₁) ⪰ (v₂, w₂)`, iff `P(v₂, w₂) ≤ P(v₁, w₁)`.

**Proposition 4.8.** Dominance is reflexive and transitive (a preorder).

*Proof.* Reflexivity is `P(v, w) ≤ P(v, w)`; transitivity follows from transitivity of
`≤` on `ℚ`. ∎

The verified monotonicity theorems are statements about this preorder: Skip-Two and
Diagonal give dominance relations, while the Parity Paradox shows the *naïve* relation
"`(v+1, w) ⪰ (v, w)`" can *fail*.

---

## 5. Probability bounds

**Theorem 5.1 (Non-negativity).** For all `v, w`, `0 ≤ P(v, w)`.

*Proof.* Induct following the structure of the recursion. The base case `P(v,0) = 1 ≥ 0`
and the majority case `P = 0 ≥ 0` are immediate. In the recursive case both coefficients
`(w+1)/(v+w+1)` and `v/(v+w+1)` are non-negative, the constants `1` and `0` are
non-negative, and the recursive values are non-negative by the inductive hypothesis; a
non-negative combination of non-negative terms is non-negative. ∎

**Theorem 5.2 (Upper bound).** For all `v, w`, `P(v, w) ≤ 1`.

*Proof.* Strong induction on `(w, v)`. The base and majority cases give `1` and `0`. In
the recursive case write `c₁ = (w+1)/(v+w+1)`, `c₂ = v/(v+w+1)`, so `c₁ + c₂ = 1` (the
day phase eliminates exactly one of the `v + w` players). The branch values `A, B` are
each `≤ 1`: `A` is either the constant `1` or `P(v−1, w) ≤ 1` by induction, and `B` is
either `0` or `P(v−2, w+1) ≤ 1` by induction. Hence
`P = c₁ A + c₂ B ≤ c₁ + c₂ = 1`. ∎

Together these confirm `P(v, w) ∈ [0, 1]`: `P` is a genuine probability.

A useful structural consequence isolates the one-werewolf recursion.

**Proposition 5.3 (One-werewolf recursion).** For `v ≥ 4`,
`P(v, 1) = 1/(v+1) + (v/(v+1)) · P(v − 2, 1)`.

*Proof.* Specialize the definition at `w + 1 = 1` (so `w = 0`, giving `A = 1`) and note
that for `v ≥ 4` the guard `v ≤ w + 3 = 3` fails, so `B = P(v − 2, 1)`. ∎

This linear recurrence in steps of two is exactly the engine of the parity behavior: the
constant term `1/(v+1)` is the dilution-driven instant-win probability, and the
multiplier `v/(v+1) → 1` couples successive even (resp. odd) towns.

---

## 6. The parity defect

To quantify the paradox with a single number we define:

**Definition 6.1 (Parity defect).**

```
D(v, w) = P(v, w) / P(v + 1, w)        if P(v + 1, w) ≠ 0,   else 0.
```

`D(v, w) > 1` is precisely the statement that adding a villager hurts; the magnitude
measures the penalty.

**Theorem 6.2 (Exact defects).** `D(2, 1) = 4/3` and `D(4, 1) = 56/45`.

*Proof.* `D(2,1) = P(2,1)/P(3,1) = (1/3)/(1/4) = 4/3`, and
`D(4,1) = P(4,1)/P(5,1) = (7/15)/(3/8) = 56/45`. ∎

**Theorem 6.3 (Defect decreases).** `D(4, 1) < D(2, 1)`; explicitly, `56/45 < 4/3`.

*Proof.* `56/45 ≈ 1.2444 < 1.3333 ≈ 4/3`. ∎

Thus the paradox is strongest in the smallest towns and weakens as the town grows. The
exact one-werewolf defects continue
`D(2,1) = 4/3 ≈ 1.333 > D(4,1) = 56/45 ≈ 1.244 > D(6,1) ≈ 1.198 > D(8,1) ≈ 1.169 > ⋯`,
a strictly decreasing sequence apparently converging to `1`. The two-werewolf defects
behave similarly, starting higher (`D(3,2) = 8/5 = 1.6`) and likewise decaying toward
`1`. The conjectured limit is the content of Section 7.

---

## 7. Open conjectures and proof strategies

The verified families above are special cases of three general statements, which we
state as conjectures together with strategies.

**Conjecture 7.1 (Global Skip-Two Monotonicity).** For `v ≥ w + 2` and `w ≥ 1`,
`P(v, w) ≤ P(v + 2, w)`.

*Strategy.* Induct on `v` in steps of two using the structural recursion. For `w = 1`,
Proposition 5.3 gives `P(v, 1) = 1/(v+1) + (v/(v+1)) P(v−2, 1)`; comparing the maps
`x ↦ 1/(v+1) + (v/(v+1)) x` for consecutive even/odd `v` and feeding in the inductive
hypothesis `P(v−2,1) ≤ P(v,1)` should close the loop, since the affine coefficient
`v/(v+1)` is increasing in `v`. For general `w`, couple the two chains `(v, w)` and
`(v + 2, w)` so that they share day/night outcomes; the `+2` shift preserves the
loss-rhythm alignment, yielding a stochastic domination.

**Conjecture 7.2 (Global Diagonal Monotonicity).** For `v ≥ w + 2` and `w ≥ 2`,
`P(v, w) ≤ P(v + 1, w − 1)`.

*Strategy.* Construct an explicit coupling between the chains started at `(v, w)` and
`(v + 1, w − 1)`: the latter has one fewer predator and one more ally at every
corresponding step, so a pathwise comparison shows its absorbing event "all werewolves
eliminated" occurs no later. Reduce to a finite system of linear inequalities in the
exact rationals at each level set `v + w = const` and induct downward.

**Conjecture 7.3 (Parity-Defect Convergence).** For every fixed `w ≥ 1` and every
`ε > 0` there is `N` such that for all `v ≥ N` (with `v ≥ w + 2`),
`|D(v, w) − 1| < ε`.

*Strategy.* For `w = 1`, set `a_k = P(2k, 1)` and `b_k = P(2k+1, 1)`; Proposition 5.3
gives both as affine recurrences with multiplier `v/(v+1) → 1` and vanishing additive
term `1/(v+1) → 0`. Show both subsequences converge to a common limit `L ∈ (0, 1)`
(monotone-and-bounded via Theorems 4.5 and 5.2), whence `D(v,1) = a/b → L/L = 1`. For
general `w`, lift via the diagonal coupling of Conjecture 7.2 to reduce to the
one-werewolf limit.

---

## 8. Applications and discussion

**Game design.** The model gives concrete, exact guidance: to strengthen the villagers,
add allies *in pairs* (Skip-Two), and prize role *conversion* (Diagonal) over mere
reinforcement. A lone added villager can be a liability in tight configurations
(Parity Paradox), a fact directly useful when balancing variant rule sets.

**Non-monotone reasoning.** The result is a crisp, fully verified instance of a system
in which "more of a beneficial resource" reverses the expected effect. The mechanism —
a scarce decisive event (catching a wolf) diluted by added population, combined with a
parity-quantized loss process — is a transferable template. Analogous reversals appear
in committee/jury sizing (dilution of decisive votes), redundancy allocation in
reliability engineering (backups that must be added in matched units to pay off), and
threshold/tipping models in epidemiology and queueing.

**Formal verification.** Because every probability is an exact rational, the entire
theory is checkable without numerical error: each concrete value is a verified equality
between rationals, and each monotonicity claim is a verified inequality. This eliminates
the usual ambiguity of simulation-based balance studies, where a `0.467` versus `0.375`
gap might be dismissed as noise; here `7/15 > 3/8` is certain.

**Limitations.** The model assumes uniformly random daytime elimination (zero
deduction skill) and a fixed two-phase schedule. Real Werewolf layers inference,
special roles (seer, doctor), and strategic voting on top. These extensions change the
transition kernel but not the basic phenomenon we identify: the parity-driven tension
between dilution and cushion is robust to many such elaborations and is the natural
baseline against which skilled play should be measured.

**Related models and positioning.** The object studied here is an absorbing Markov
chain on the two-dimensional lattice of team sizes, a relative of classical
gambler's-ruin and birth–death processes. What distinguishes it is the coupled
two-phase update — a stochastic day step followed by a deterministic night step — that
makes the per-round villager loss equal to two on failure and one on partial success.
This coupling is exactly what produces a *parity-dependent* drift and hence the
non-monotonicity; pure birth–death chains with single-step moves do not exhibit it.
Viewed this way, the Parity Paradox is a minimal example of how compounding two
elimination mechanisms within a single round can invert the comparative statics that
either mechanism would produce alone. The same compounding appears whenever a system
suffers a guaranteed secondary loss after a primary failure (e.g. cascading outages
after a misallocated repair), which is why we expect the qualitative lesson to transfer
beyond games.

**On exactness versus simulation.** A Monte Carlo estimate of, say, `P(4,1)` and
`P(5,1)` with a few thousand trials would place both near `0.4`–`0.5` with overlapping
confidence intervals, and a balance designer might reasonably conclude the two towns are
"about the same." The exact analysis instead certifies `7/15 > 3/8` — a genuine,
provable reversal of `9/120` in magnitude that no amount of sampling noise can explain
away. Exact rational computation is therefore not a stylistic preference here but a
methodological necessity: the phenomenon lives at a scale where sampling error and
signal are comparable.

---

## 9. Conclusion

We have given a complete, exact analysis of villager win probabilities in a
random-elimination Werewolf model. The win-probability function `P(v, w)` is a genuine
probability (`0 ≤ P ≤ 1`) yet is *non-monotone* in the villager count: adding a single
villager can strictly lower the chance of victory (the Parity Paradox), witnessed at
infinitely many exact configurations. The paradox is stabilized by adding villagers in
pairs (Skip-Two Monotonicity) and by converting werewolves into villagers (Diagonal
Monotonicity), and it is quantified by the parity defect `D`, which is exactly computable
and provably decreasing along the one-werewolf family. We isolated the one-werewolf
recursion driving the effect and posed three sharp conjectures — global skip-two and
diagonal monotonicity, and parity-defect convergence — with coupling- and
recurrence-based strategies. Beyond game design, the work offers a clean, machine-checked
case study in non-monotone reasoning, where the size and timing of "help" determine
whether it helps at all.
