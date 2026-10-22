# Computational evidence: probe-local per-layer budgets

Model: the setting of `Probability.NET59TVCore` and `Probability.NET59HybridEpistasis`. Layers are Markov channels on a finite state space with rational weights, and damage is total variation distance. Every number below is stated and checked by a Lean declaration in `Catalog/Applications/NET59ProbeBudgets/`. None of it comes from an unchecked script.

## 1. Small cases

| State space | Probe set | Spans? | What Lean verifies | Declaration |
|---|---|---|---|---|
| `Fin 2` | `{bern 1/2}` (one balanced held-out input) | no | `idK` and `flipK` give identical responses at the probe, but `tv(idK 0, flipK 0) = 1` | `ProbeDesign.lean`, LabNotes, first `example` |
| `Fin 2` | `{bern 1/4, bern 3/4}` | yes | `d0 = 3/2·bern 1/4 − 1/2·bern 3/4` | `lab_d0_combination` |
| `Fin 2` | same | yes | joint damage from `d0` ≤ `3/2·traj(bern 1/4) + 1/2·traj(bern 3/4)` for every stack pair (ℓ¹ amplification 2) | LabNotes, second `example` |
| `Fin 2`, any depth `n+3` | any inputs at all | n/a | masked witness: solo profile `0` at every input and every layer; joint damage `17/1000` at every input | `MaskingSuffix.lean`, LabNotes `example` |
| any `α`, `m < |α|` probes | `Fin m → Dist α` | never | a stack pair that agrees exactly on the window but has damage `1` elsewhere | `small_window_never_certifies` |

## 2. OEIS

Not applicable. No integer sequence comes up. The only count in the results is the minimum number of probes, which is exactly `|α|` (`diracProbes_spans`, `card_le_of_spans`).

## 3. Counterexample hunt

The original conjecture says that every finitely-probed budget fails. That conjecture is false as stated, and the Lean results show why:

* If the state space is finite, the `|α|` Dirac probes span. The Dirac-sum and design budgets are probe-local, calibrated and sound (`diracProbes_suffice`, `designBudget_sound`). So some finitely-probed budgets succeed.
* On a one-point state space every budget that vanishes on equal layers is sound. This corner case is the reason the `Subsingleton α` disjunct appears in `probe_budget_dichotomy`.
* The correct statement is the dichotomy. A sound, calibrated, probe-local budget exists **iff** the probes span (or `|α| = 1`).

A further corner case appeared during formalization. With `m = 0` probes on a one-point space we have `m < |α|`, yet no damage is possible. For this reason `small_window_never_certifies` assumes `Nontrivial α`.

## 4. Table: what each kind of measurement certifies

| Measurement | Sound for the measured input? | Sound for all inputs? |
|---|---|---|
| uniform worst-case per layer | yes | yes (`budget_sound_iff_uniform_le`) |
| layer-output perturbation on the input's own intact trajectory | yes (`joint_le_trajectoryCost`) | iff the window spans (`trajectory_window_dichotomy`) |
| per-layer response at fixed probe states | n/a | iff the probes span (`probe_budget_dichotomy`) |
| output-level solo ablation | **no** (`masking_suffix`, `solo_certificate_unsound`) | no |
