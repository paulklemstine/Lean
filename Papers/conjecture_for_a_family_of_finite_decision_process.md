# Computational Evidence — Fluctuation-Robust Demon Impossibility

Target statement (Conjecture 4 of the research direction, now a theorem in
`Catalog/Computation/FluctuationRobustDemon.lean`):

> For finite-memory demons obeying a Crooks/Jarzynski-type fluctuation relation, the
> probability that the **total** work over `n` independently erased bits falls below
> `n · w` (with `w` strictly below the free-energy threshold `ΔF`) decays exponentially
> in `n`, uniformly over every control strategy:
> `P(∑ᵢ Wᵢ ≤ n·w) ≤ exp(-n·β·(ΔF - w))`.

## 1. Small-case calculations — the explicit "coin demon"

Take a two-outcome protocol with `p(cheap) = p(expensive) = 1/2` and

* `W_cheap = ΔF - log(3/2)/β`   (strictly **below** the threshold)
* `W_exp   = ΔF + log(2)/β`.

With `β = 1.7`, `ΔF = 0.9`:

| quantity | value |
|---|---|
| `⟨e^{-βW}⟩` | `0.216535667316007…` |
| `e^{-βΔF}` | `0.216535667316007…` |
| `⟨W⟩` | `0.98461…` |
| `ΔF` | `0.9` |

So the Jarzynski equality holds exactly (to machine precision), the mean work exceeds
`ΔF` as the second law demands, **and yet a single run beats the threshold with
probability exactly `1/2`.**  This confirms the physical premise of the conjecture:
single-shot Landauer violations are real and have constant probability.

## 2. Repetition kills the advantage

Set `w = W_cheap`, so `ΔF - w = log(3/2)/β`.  Since every trajectory costs at least
`W_cheap`, the total-work deficit event `∑ Wᵢ ≤ n·W_cheap` happens iff *all* `n` bits take
the cheap branch, i.e. with exact probability `2^{-n}`.  The theorem's bound is
`exp(-n log(3/2)) = (2/3)^n`.

| `n` | exact `P(deficit)` | bound `(2/3)^n` | valid? |
|---|---|---|---|
| 1 | 0.5 | 0.6667 | ✓ |
| 2 | 0.25 | 0.4444 | ✓ |
| 3 | 0.125 | 0.2963 | ✓ |
| 5 | 0.03125 | 0.13169 | ✓ |
| 10 | 9.7656e-4 | 1.7342e-2 | ✓ |
| 20 | 9.5367e-7 | 3.0073e-4 | ✓ |

Exponential decay in `n`, as conjectured; no counterexample.

## 3. Counterexample hunt / tightness

Random search over two- and three-outcome protocols renormalised to satisfy the Jarzynski
equality produced no violation of the bound.  Structurally the bound is *asymptotically
tight*: put mass `q` at work exactly `w` and mass `1-q` at work `M`.  Jarzynski forces
`q e^{-βw} + (1-q) e^{-βM} = e^{-βΔF}`, so as `M → ∞` one gets
`q → e^{-β(ΔF-w)}`, matching the one-shot bound `P(W ≤ w) ≤ e^{-β(ΔF-w)}`.
Independent repetition then makes `P(∑Wᵢ ≤ n w) → e^{-nβ(ΔF-w)}` exactly.  Hence the
constant in the exponent cannot be improved.

## 4. Uniformity check

The bound `exp(-nβ(ΔF-w))` contains no reference to the outcome spaces, to the probability
vectors, or to the work functions — only to `β`, `ΔF`, `w`, `n`.  This is what makes it
uniform over *every* control strategy (in particular every polynomial-time one), and it is
reflected in the Lean statement `FluctDemon.deficit_concentration`, where the systems
`S : ∀ i, WorkSystem (Ω i)` are universally quantified with heterogeneous outcome types.

## 5. No OEIS sequence

The objects here are real-valued (exponential-average) quantities; no integer sequence
arises, so no OEIS lookup applies.

---

# Addendum (this cycle): adaptive demons

The bound above assumed **independent** protocols.  This cycle removes that assumption, so
before formalising we checked the adaptive case by hand on the smallest genuinely
history-dependent example.

## A6. The two-stage adaptive coin

Strategy `FluctDemon.trueAdaptiveCoin`: run the coin protocol; if the *expensive* branch
occurs (work `ΔF + log 2/β`), switch to the deterministic protocol `surePay` which always
pays exactly `ΔF`; if the *cheap* branch occurs (work `ΔF - log(3/2)/β`), run the coin
again.  Both continuations obey the Jarzynski equality at the same `(β, ΔF)`, and the two
stages use *different* work systems depending on the observed history, so the
product-form theorem of the previous cycle does not apply.

Threshold `t = 2·(ΔF - log(3/2)/β)`, i.e. `w = ΔF - log(3/2)/β` per bit.

| first outcome | prob | work | remaining budget | continuation | success prob |
|---|---|---|---|---|---|
| expensive | 1/2 | `ΔF + log2/β` | `ΔF - 2log(3/2)/β - log2/β` | `surePay` pays `ΔF` | 0 |
| cheap | 1/2 | `ΔF - log(3/2)/β` | `ΔF - log(3/2)/β` | coin | 1/2 |

Total exact deficit probability `= 1/2·0 + 1/2·1/2 = 1/4`, against the theorem's bound
`exp(-2 log(3/2)) = (2/3)² = 4/9 ≈ 0.4444`.  Consistent, with slack — adaptivity did not
help the demon.  Both numbers are now theorems, not numerics:
`FluctDemon.trueAdaptiveCoin_deficitProb` (`= 1/4`) and `FluctDemon.trueAdaptiveCoin_bound`
(`≤ exp(-2 log(3/2))`).

## A7. Counterexample hunt for adaptivity

We looked for an adaptive two-stage strategy beating `e^{-2β(ΔF-w)}`, by letting the
second-stage protocol depend on the first outcome and re-optimising its sub-threshold mass.
None exists, and the formal reason is now proved: the tree-level exponential average
`⟨e^{-β·(total work)}⟩` equals `e^{-nβΔF}` *identically* for any compliant tree
(`FluctDemon.AdaptiveDemon.expWorkAvg_eq`), so Markov's inequality applies verbatim.  The
demon's freedom to adapt changes the distribution of the total work but not its exponential
average, which is the only quantity the bound uses.

## A8. Where the argument would break

Only one direction of the Jarzynski equality is used.  The Lean development therefore
states the main bound under the weaker one-sided hypothesis
`FluctDemon.AdaptiveDemon.Dissipative`, namely `⟨e^{-βW}⟩ ≤ e^{-βΔF}` at every stage
(`FluctDemon.adaptive_deficit_bound_of_dissipative`), with Jarzynski compliance as the
equality corollary.  A node that is *less* dissipative than `ΔF` breaks the induction at
exactly that stage, which is the sharp sense in which per-stage dissipation is the only
hypothesis being used.

---

# Addendum B — stopping-time (unbounded-horizon) demons

This addendum records the evidence gathered for
`Catalog/Computation/StoppingTimeDemon.lean`, which resolves Conjecture 2 of the previous
`FUTURE_DIRECTIONS.md`: demons that decide *when to stop* rather than erasing a prescribed
number of bits.  All numbers below are now theorems in that file, not floating-point
experiments.

## B1. The model quantities behave like probabilities

Sanity checks proved rather than sampled:

* `StoppingDemon.deepProb_zero` — `P(N ≥ 0) = 1` for every tree;
* `StoppingDemon.deepProb_nonneg`, `deepProb_le_one`;
* `StoppingDemon.deepDeficitProb_le_deepProb` — the "cheap run" event is contained in
  `{N ≥ m}`, hence `deepDeficitProb ≤ 1`;
* `StoppingDemon.rateDeficitProb_eq_shift` — the random threshold `w·N` is the fixed
  threshold `0` on the work scale shifted by `w`, which is what makes the induction go
  through.

These pin down the recursive definitions as the intended conditional-expectation
recursions; without them the main bound could be satisfied by an accidentally trivial
quantity.

## B2. A demon with a genuinely random stopping time (`coinStop`)

Run the coin protocol; halt if the *expensive* outcome occurs, otherwise run the coin once
more.  So `N ∈ {1, 2}` with probability `1/2` each.

| quantity | exact value | Lean theorem |
|---|---|---|
| `E[N]` | `3/2` | `coinStop_meanStages` |
| `P(N ≥ 2)` | `1/2` | `coinStop_deepProb_two` |
| `E[total work]` | `(3/2)·ΔF + (3/4)·log(4/3)/β` | `coinStop_meanTotalWork` |
| Wald bound `ΔF·E[N]` | `(3/2)·ΔF` | `stopping_wald` |
| Wald slack | `(3/4)·log(4/3)/β ≈ 0.21576/β` | `coinStop_wald_strict` |
| `P(total ≤ w·N, N ≥ 2)` at `w = ΔF - log(3/2)/β` | `1/4` | `coinStop_rateDeficitProb` |
| proved bound at `m = 2` | `(2/3)² = 4/9 ≈ 0.4444` | `coinStop_rate_bound` |

The Wald inequality is therefore satisfied strictly, and the concentration bound with
slack: stopping early does not help the demon.

## B3. Unbounded horizon: the `geoStop` family

`geoStop β ΔF n` runs the coin protocol repeatedly and halts the moment the expensive
outcome appears, up to a horizon `n`.  The event "ran all `n` stages and averaged below
`w = ΔF - log(3/2)/β`" is exactly "`n` cheap outcomes in a row".

| `n` | exact `P` = `(1/2)^n` | bound `(2/3)^n` | ratio |
|---|---|---|---|
| 1 | 0.500000 | 0.666667 | 0.7500 |
| 2 | 0.250000 | 0.444444 | 0.5625 |
| 3 | 0.125000 | 0.296296 | 0.4219 |
| 4 | 0.062500 | 0.197531 | 0.3164 |
| 5 | 0.031250 | 0.131687 | 0.2373 |
| 6 | 0.015625 | 0.087791 | 0.1780 |
| 7 | 0.007812 | 0.058528 | 0.1335 |
| 8 | 0.003906 | 0.039018 | 0.1001 |
| 9 | 0.001953 | 0.026012 | 0.0751 |
| 10 | 0.000977 | 0.017342 | 0.0563 |

The exact column is the theorem `geoStop_rateDeficitProb` (`= (1/2)^n` for every `n`) and
the bound column is `geoStop_bound`.  Both exact value and bound decay exponentially, with
rates `log 2 ≈ 0.6931` and `log(3/2) ≈ 0.4055`; the ratio decays like `(3/4)^n`, so this
family is *not* extremal — consistent with Conjecture 1 (the exact large-deviation rate) of
the previous cycle, which remains open.

## B4. Counterexample hunt for stopping rules

We looked for a stopping rule that beats `exp(-mβ(ΔF-w))`: a demon that halts precisely
after cheap outcomes, one that halts after a fixed cheap prefix, and one that keeps going
only after expensive outcomes (trying to "average away" the deficit).  None beats the
bound, and the structural reason is now proved: passing to the shifted work scale
(`rateDeficitProb_eq_shift`) turns any stopping rule into a fixed-threshold event on a tree
whose every node is dissipative at `ΔF - w ≥ 0`, and `stopping_deficit_bound` applies
verbatim.  Halting is just an extra branch in the tree, and a halting branch can only
*lose* the deficit event unless the required `m` has already been reached.

## B5. Where the argument would break

* `0 ≤ ΔF` is used only to handle the degenerate requirement `m = 0` (halting immediately);
  for `m ≥ 1` the induction never needs it.
* `w ≤ ΔF` is needed for the shifted tree to remain dissipative; for `w > ΔF` the shifted
  free energy is negative and the exponential bound exceeds `1`, i.e. becomes vacuous —
  as it should, since a demon paying more than `ΔF` per bit is not violating anything.
* Only the one-sided hypothesis `⟨e^{-βW}⟩ ≤ e^{-βΔF}` (`StoppingDemon.Dissipative`) is
  used, so Jarzynski compliance is a strict special case.

---

# Addendum C — Crooks-completeness (this cycle)

The claim under test is the converse of `FluctDemon.jarzynski_of_crooks`: given a finite
work system `S = (p, W)` on `Ω` with `∑_ω p(ω) e^{-βW(ω)} = e^{-βΔF}`, does there exist a
reverse system `(q, W_rev)` and a reversal `flip : Ω ≃ Ω` with `W_rev ∘ flip = -W` and
`p(ω) = e^{β(W(ω)-ΔF)} q(flip ω)`?

## C1. The equations are linear and already solved

The Crooks relation determines `q` outright:

```
q(flip ω) = p(ω) · e^{-β(W(ω) - ΔF)}     and     W_rev(flip ω) = -W(ω).
```

Nonnegativity is automatic, and the only nontrivial requirement is normalisation:

```
∑_σ q(σ) = e^{βΔF} ∑_ω p(ω) e^{-βW(ω)} = e^{βΔF} · e^{-βΔF} = 1,
```

which is *exactly* the Jarzynski equality.  So the search for a counterexample reduces to
the search for a Jarzynski-compliant system whose reverse weights fail to normalise, and
there is none.  This is `FluctDemon.reverseSystem` / `FluctDemon.crooksCompletion`, and the
equivalence is `FluctDemon.jarzynski_iff_exists_crooks`.  The second clause of the original
conjecture (a system with no Crooks partner must have an outcome of zero forward and
nonzero reverse probability) is therefore **vacuous**: no such system exists, and in fact
`FluctDemon.reverseSystem_prob_pos` shows the constructed partner charges the time reverse
of every outcome the forward protocol charges.

## C2. Small case: the coin demon (exact numbers, all verified in Lean)

Take `Ω = Bool`, `p ≡ 1/2`, `W(true) = ΔF + log 2 / β`, `W(false) = ΔF - log(3/2)/β`
(the catalog's `coinDemon`), and `flip = id`.  The forced reverse probabilities are

| outcome `ω` | `p(ω)` | `e^{-β(W(ω)-ΔF)}` | `q(ω)` |
|---|---|---|---|
| `true`  | 1/2 | 1/2 | **1/4** |
| `false` | 1/2 | 3/2 | **3/4** |

Sum `= 1`, as forced by Jarzynski (`coinCrooks_rev_prob_true`, `coinCrooks_rev_prob_false`).

## C3. The sharpened one-shot bound is exactly attained

For the same data at threshold `w = ΔF - log(3/2)/β`:

| quantity | value |
|---|---|
| true deficit probability `P(W ≤ w)` | `1/2` (`coinCrooks_deficit_eq`) |
| reverse mass of the reversed deficit event | `3/4` (`coinCrooks_revDeficitMass`) |
| Crooks-sharpened bound `e^{-β(ΔF-w)} · (reverse mass)` | `(2/3)·(3/4) = 1/2` — **exact** |
| unsharpened Chernoff bound `e^{-β(ΔF-w)}` | `2/3` |

So the reverse-mass factor of `FluctDemon.crooks_deficit_le_rev` is precisely the slack in
the earlier `single_deficit_bound`, and the strict-improvement lemma
`FluctDemon.crooks_deficit_strict` is non-vacuous
(`coinCrooks_sharpened_lt_unsharpened`: `1/2 < 2/3`).

## C4. Counterexample hunt

We looked for (i) a Jarzynski system with no Crooks partner — impossible by C1; (ii) a
Crooks pair whose reverse half violates Jarzynski at `-ΔF` — impossible, this is now the
theorem `FluctDemon.crooks_rev_jarzynski`, proved from the detailed relation alone; and
(iii) two distinct Crooks partners for the same `(fwd, flip)` — impossible by
`FluctDemon.crooks_rev_unique`, since the relation determines `q` pointwise.  No
counterexample exists in the finite model; the whole content of "Crooks-ness" over
"Jarzynski-ness" in this model is the *choice of reversal*, which is free.
