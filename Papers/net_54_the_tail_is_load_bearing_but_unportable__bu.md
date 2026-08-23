# Computational evidence for the NET-54 formalisation

All arithmetic below is over exact rationals and is *certified inside Lean*: every
number quoted here appears in a theorem in `Catalog/Probability/` that compiles with
no `sorry` and only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`).
Nothing in this file is an unchecked scratch computation.

## 1. The measured table (input data, NET-54)

Cross-parent top-1 prediction agreement baseline: `β = agr(A,B) = 0.8327`.

| arm | ΔCE vs host | agr(H, base A) | agr(H, instruct B) |
|---|---|---|---|
| base←inst **L22/23** (tail) | +0.4652 | 0.5845 | 0.5443 |
| base←inst L10/11 (bulk) | +0.0043 | 0.9635 | 0.8385 |
| inst←base **L22/23** (tail) | +0.5455 | 0.5887 | 0.6289 |
| inst←base L10/11 (bulk) | −0.0164 | 0.8459 | 0.9495 |

## 2. Derived quantities (each is the content of a proved theorem)

Novelty floor (`novelFrac_ge_baseline_sub_agree`): `novel ≥ β − min(agr(H,A), agr(H,B))`.

| arm | `β − min` | certified novelty floor |
|---|---|---|
| tail, base←inst | 0.8327 − 0.5443 | **0.2884** |
| tail, inst←base | 0.8327 − 0.6289 | **0.2038** |
| bulk, base←inst | 0.8327 − 0.8385 | −0.0058 (vacuous) |
| bulk, inst←base | 0.8327 − 0.8459 | −0.0132 (vacuous) |

So the certificate fires on exactly the two tail arms and on neither bulk arm: the
collapse is a property of L22/23, not of transplanting.

Sharing budget (`agreeFrac_triangle`): ceiling on `agr(H,A) + agr(H,B)` is `1 + β = 1.8327`.

| arm | measured sum | gap to ceiling |
|---|---|---|
| tail, base←inst | 1.1288 | **0.7039** |
| bulk, base←inst | 1.8020 | **0.0307** |
| tail, inst←base | 1.2176 | 0.6151 |
| bulk, inst←base | 1.7954 | 0.0373 |

Ratio of wasted budget, tail vs bulk (base←inst): `0.7039 / 0.0307 = 22.9…`, certified
as `≥ 22×` in `net54_tail_at_least_22x_less_shareable`.

Mean sharing ceiling for `k` fine-tunes (`sharing_ceiling_mean`): `(1+β)/2 = 0.91635`.
The bulk arm attains mean `0.9010`, i.e. **98.3 % of the geometric optimum**.

Margin-failure fraction (`net54_margin_failure_fraction`): `1 − 0.5443 = 0.4557`.

Cost localisation (`cost_localization`) at `Δ = 0.4652`, cap `C = 2` nats:
`Δ/(2C) = 0.1163` of windows must individually lose `≥ Δ/2 = 0.2326` nats.

## 3. Consistency / realizability check

Is the measured tail profile realizable at all by three genuine prediction functions?
Yes — and this is proved, not asserted, in
`Catalog/Probability/TailTransplantRealizability.lean`, by an explicit five-class
index set of 10000 positions:

| class | size | parents | hybrid | contributes to |
|---|---|---|---|---|
| 0 | 5000 | `A = B` | follows both | agr(A,B), agr(H,A), agr(H,B) |
| 1 | 3327 | `A = B` | novel | agr(A,B), novelty |
| 2 | 845 | `A ≠ B` | follows `A` | agr(H,A) |
| 3 | 443 | `A ≠ B` | follows `B` | agr(H,B) |
| 4 | 385 | `A ≠ B` | novel | novelty |

Check: `agr(A,B) = (5000+3327)/10000 = 0.8327`; `agr(H,A) = (5000+845)/10000 = 0.5845`;
`agr(H,B) = (5000+443)/10000 = 0.5443`; `novel = (3327+385)/10000 = 0.3712`.
Certificate floor 0.2884 ≤ realized 0.3712, with strict slack — so the bound is neither
vacuous nor tight on this profile (`net54_realized_beats_certificate`).

## 4. Counterexample hunt

Two claims were tested for falsity before being formalised, and one was discarded:

* *"The tail-swap agreement numbers must violate the triangle inequality if the tail
  carried no identity."* — **False.** `1.1288 ≤ 1.8327`, so the profile is perfectly
  consistent with the Hamming geometry; the collapse is empirical, not arithmetic.
  This is recorded as `net54_profile_budget_slack` rather than as an impossibility.
* *"A hybrid whose agreements are both low must disagree with both parents on more
  than half of the positions."* — **False in general**: the certificate only yields
  `β − min(...)`, and the realization above shows `0.3712 < 0.5`. The formalised bound
  is therefore the honest one.

## 5. Dissociation experiment (analytic, formalised)

For the symmetric pair `q₁ = (½+t, ½−t)`, `q₂ = (½−t, ½+t)` against a uniform truth,
the cross-entropies are *equal for every* `t ∈ (0,½)` while the top-1 decisions are
opposite. Hence `ΔCE = 0` cannot certify agreement — the bulk arm's `0.9635` agreement
is independent evidence (`zero_cost_full_disagreement`).

## 6. Second-cycle checks

Balanced sharing (`BalancedSharingOptimum.lean`). Splitting the parents' disagreement
set `D` (size `d = (1-β)N = 1673` positions out of 10000) in half and following the
donor on one half gives a shared model with

`agr(H,A) = (N - ⌊d/2⌋)/N = 0.9164`, `agr(H,B) = (N - ⌈d/2⌉)/N = 0.9163`,

so `agr(H,A) + agr(H,B) = 1 + β` exactly (the ceiling) and the two agreements differ
by at most `1/N`. The measured tail hybrid holds only `0.5443` with its donor, so it
forfeits `> 0.372` of simultaneously achievable agreement — certified in
`net54_balanced_serving_value`.

Swap-site separation (`TransplantDoseResponse.lean`). From the two host-side numbers
alone, `0.9635 - 0.5845 = 0.3790`, so the bulk and tail hybrids differ on at least
`37.90 %` of positions — more than the `16.73 %` separating the two parents. Certified
in `net54_bulk_and_tail_hybrids_far_apart` and `net54_hybrids_further_than_parents`.

## 7. Third-cycle checks: the sharing phase transition (`MultiFineTuneSharingPhase.lean`)

The pairwise ceiling `(1+β)/2` is independent of the number `k` of fine-tunes served
from one shared model. The multiplicity count of this cycle adds a `k`-dependent
bound: any shared model's mean agreement `M` satisfies `k M² ≤ M + (k−1)β`, i.e.

`M ≤ M*(k) := (1 + √(1 + 4k(k−1)β)) / (2k)`.

At the measured cross-parent baseline `β = 0.8327` (`(1+β)/2 = 0.91635`,
`√β = 0.912524`):

| `k` | `M*(k)` | binding bound |
|---|---|---|
| 2 | 0.941990 | pairwise ceiling 0.91635 |
| 3 | 0.930153 | pairwise ceiling 0.91635 |
| 4 | 0.925094 | pairwise ceiling 0.91635 |
| 8 | 0.918373 | pairwise ceiling 0.91635 |
| 11 | 0.916699 | pairwise ceiling 0.91635 |
| **12** | **0.916335** | **multiplicity bound** |
| 20 | 0.914770 | multiplicity bound |
| 100 | 0.912964 | multiplicity bound |
| 1000 | 0.912568 | multiplicity bound |

The crossover is at `k = 2/(1 − β) = 11.9546…`, so `k = 12` is the first family size
whose ceiling is provably unreachable — matching the closed-form threshold
`k(1 − β) > 2` of `sharing_strict_decay`, and the capacity statement
`net54_sharing_capacity_le_eleven`. The `k = 100` row is the numerical content of
`net54_hundred_finetunes_bound` (`0.912964 ≤ 0.913`). The limit of the table is `√β`,
which `sqrt_lt_ceiling` proves is strictly below `(1+β)/2` for every `β < 1`.

**Saturation check (the extremal hub family).** For the `k`-position hub family
(`k` fine-tunes each deviating from a common consensus at one distinct position),
`β = 1 − 2/k` and `M = 1 − 1/k`, giving `k M² − M − (k−1)β = 0` exactly:

| `k` | `β = 1 − 2/k` | `M = 1 − 1/k` | `k M² − M − (k−1)β` |
|---|---|---|---|
| 2 | 0 | 0.5 | 0 |
| 3 | 0.333333 | 0.666667 | 0 |
| 5 | 0.6 | 0.8 | 0 (4.4e−16 in floating point) |
| 12 | 0.833333 | 0.916667 | 0 (−1.8e−15 in floating point) |

So the quadratic bound is attained for every `k`, and simultaneously the pairwise
ceiling is attained (`M = (1+β)/2` there): the threshold `k(1 − β) = 2` is exactly the
point where the two coincide. This is certified in Lean, without floating point, by
`hub_attains_sharing_ceiling` and `hub_saturates_multiplicity_bound`.

**Counterexample hunt.** The natural guess that the ceiling simply *decays like* `1/k`
for all `k` is false: below the threshold there is no decay at all (the hub family
attains `(1+β)/2` for every `k` with `k(1 − β) ≤ 2`). The decay is a genuine phase
transition, not a smooth degradation — which is why the formalised statement is
conditioned on `k(1 − β) > 2` rather than on `k` alone.

## 8. Fourth-cycle checks: the capacity curve and the rigidity of extremal families

**The two bounds cross exactly at the threshold** (`SharingCapacityCurve.lean`). The
closed-form curve `M*(k) = (1 + √(1 + 4k(k−1)β))/(2k)` is not uniformly stronger than
the pairwise ceiling `(1+β)/2`; a short scan shows the crossing:

| `k` | `β` | `k(1−β)` | curve `M*(k)` | ceiling `(1+β)/2` | operative bound |
|---|---|---|---|---|---|
| 2 | 0.5 | 1.0000 | 0.809017 | 0.75000 | ceiling |
| 3 | 0.5 | 1.5000 | 0.767592 | 0.75000 | ceiling |
| 5 | 0.8 | 1.0000 | 0.906226 | 0.90000 | ceiling |
| 12 | 0.8327 | 2.0076 | 0.916335 | 0.91635 | curve |

Below the threshold the ceiling wins, above it the curve wins, and the two agree
exactly at `k(1−β) = 2` (where the hub family attains both). This refutes the
plausible-looking conjecture "the multiplicity bound subsumes the pairwise bound",
and is why the formalised statements are `capacityCurve_lt_ceiling` (above threshold)
and `ceiling_lt_capacityCurve` (below threshold) rather than a single inequality.
The two NET-54 rows are certified in Lean by `net54_twelve_finetunes_curve`
(`≤ 0.91634`) and `net54_hundred_finetunes_curve` (`≤ 0.91297`), sharpening the
previous cycle's `0.91635` and `0.913`.

**Quantisation of extremal budgets** (`SharingRigidity.lean`). Rigidity forces
`β = c(c−1)/(k(k−1))` with `c ≤ k` an integer. For `k = 12` (denominator `132`) the
complete list of extremal budgets is

`0, 0, 0.015152, 0.045455, 0.090909, 0.151515, 0.227273, 0.318182, 0.424242,
0.545455, 0.681818, 0.833333, 1`

for `c = 0, 1, …, 12`. The measured baseline `β = 0.8327` would need
`c(c−1) = 0.8327 × 132 = 109.9164`, which is not a product of consecutive integers —
the nearest extremal budgets are `0.681818` (`c = 10`) and `0.833333` (`c = 11`). So
no family of twelve fine-tunes at the measured budget can be extremal; this is proved
in Lean by `net54_no_saturating_family_of_twelve` (by enumerating `c ≤ 12`), and the
general statement — irrational budgets are never extremal — is
`no_saturation_of_irrational_budget`.

**Saturation check for the rigidity hypothesis.** The hub family satisfies the
saturation predicate in its summed form `(∑ᵢ agr(H,Aᵢ))² = ∑ᵢ agr(H,Aᵢ) + k(k−1)β`:
with `∑ᵢ agr = k − 1` and `β = 1 − 2/k` both sides equal `(k−1)²`. Certified as
`hub_saturates`, so the rigidity theorems are non-vacuous for every `k ≥ 2`.

## 9. Fifth-cycle checks: the complete `c`-design converse (`SharingExtremalDesigns.lean`)

The quantisation theorem of §8 is only a *necessary* condition. To test whether it is
also sufficient, the complete `c`-design was enumerated exhaustively: positions are the
`C(k,c)` blocks (the `c`-element subsets of the `k` fine-tunes), fine-tune `i` emits the
distinguished token `0` on exactly the blocks containing `i` and its own private token
`i+1` elsewhere, and the shared model is the constant hub `0`.

For every `2 ≤ c ≤ k ≤ 6` (all 20 cases) the enumeration gives, exactly in rationals:

| `k` | `c` | pairwise `β` | mean agreement `M` | `c(c−1)/(k(k−1))` | `c/k` | saturates `kM² = M+(k−1)β` | `capacityCurve k β` |
|---|---|---|---|---|---|---|---|
| 3 | 2 | 1/3 | 2/3 | 1/3 | 2/3 | yes | 0.666667 |
| 4 | 2 | 1/6 | 1/2 | 1/6 | 1/2 | yes | 0.5 |
| 4 | 3 | 1/2 | 3/4 | 1/2 | 3/4 | yes | 0.75 |
| 5 | 2 | 1/10 | 2/5 | 1/10 | 2/5 | yes | 0.4 |
| 5 | 3 | 3/10 | 3/5 | 3/10 | 3/5 | yes | 0.6 |
| 5 | 4 | 3/5 | 4/5 | 3/5 | 4/5 | yes | 0.8 |
| 6 | 2 | 1/15 | 1/3 | 1/15 | 1/3 | yes | 0.333333 |
| 6 | 3 | 1/5 | 1/2 | 1/5 | 1/2 | yes | 0.5 |
| 6 | 4 | 2/5 | 2/3 | 2/5 | 2/3 | yes | 0.666667 |
| 6 | 5 | 2/3 | 5/6 | 2/3 | 5/6 | yes | 0.833333 |

(the diagonal cases `c = k` all give the degenerate `β = M = 1`.) In every row the
pairwise agreement is the *same* for all `C(k,2)` pairs, `M` equals `c/k`, saturation is
exact in rational arithmetic, and `M` coincides with the capacity curve at that budget.
Note also that the `c = k−1` row of each block reproduces the hub family of §8
(`β = 1 − 2/k`, `M = 1 − 1/k`), so the design family strictly extends it.

These are exactly the statements proved in Lean, for all `k` and `c`, by
`design_agree_pair`, `design_agree_hub`, `design_saturates`,
`quantised_values_are_exactly_realised`, `capacityCurve_at_quantised_budget` and
`design_on_capacityCurve`; the Lean proofs run through the `Nat.choose` double counts
`Σ_i |{blocks ∋ i}| = k·C(k−1,c−1)` and `|{blocks ⊇ {i,j}}| = C(k−2,c−2)`, so the table
above is a finite corroboration of a theorem, not the evidence for it. Combined with
`saturation_quantised` (§8) the extremal set is now **classified**: a pair `(β, M)` is
realised by a saturating family iff it is one of the quantised pairs.
