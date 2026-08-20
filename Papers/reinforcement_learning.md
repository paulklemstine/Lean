# Computational Evidence — Neurosymbolic RLHF / PPO-ptx Objective

All numbers below were produced by `Float` evaluation inside Lean 4 (`#eval`) before
the formal proofs were attempted; they are *evidence*, not verification. Everything
they suggest is proved formally and `sorry`-free in
`Catalog/Shared/NeuroSymbolicRLHFObjective.lean` and
`Catalog/Shared/NeuroSymbolicRLHFRobustness.lean`.

## Test instance

Three-element response space, SFT reference and neurosymbolic reward

```
ref = [0.5, 0.3, 0.2]        r = [1.0, 0.0, 2.0]        (min r = 0, max r = 2)
```

## 1. The tilted (softmax) policy is a probability vector

`gibbs 1.0 = [0.433268, 0.095634, 0.471098]`, sum `= 1.000000`.
(Proved: `gibbs_isPosProb`.)

## 2. Variational principle: the tilted policy attains the free energy

| quantity | value |
|---|---|
| `Objective(gibbs 1.0)` | `1.143252` |
| `freeEnergy 1.0 = β log Z` | `1.143252` |

Competitor policies, all strictly worse (counterexample hunt for
"some other policy beats the softmax policy" — none found):

| policy | objective |
|---|---|
| `[0.4, 0.3, 0.3]`    | `0.967618` |
| `[0.2, 0.2, 0.6]`    | `1.005184` |
| `[1/3, 1/3, 1/3]`    | `0.934417` |
| `[0.6, 0.1, 0.3]`    | `1.078829` |

(Proved: `rlhfObj_gibbs`, `rlhfObj_le_freeEnergy`, `rlhfObj_eq_freeEnergy_iff`.)

## 3. Monotonicity of the optimal value in the KL coefficient β

| β | 0.25 | 0.5 | 1 | 2 | 4 | 10 |
|---|---|---|---|---|---|---|
| `freeEnergy β` | `1.608954` | `1.351155` | `1.143252` | `1.023271` | `0.961598` | `0.924570` |

Strictly decreasing, and squeezed between `E_ref[r] = 0.9` and `max r = 2`;
the values approach `E_ref[r] = 0.9` as `β → ∞` and `max r = 2` as `β → 0`.
(Proved: `freeEnergy_antitone_beta`, `freeEnergy_mem_Icc`.)

## 4. Reward improvement and sandwich at β = 1

`E_ref[r] = 0.900000  ≤  freeEnergy = 1.143252  ≤  E_gibbs[r] = 1.375464  ≤  max r = 2`.
(Proved: `expected_ref_le_freeEnergy`, `gibbs_expected_reward_ge`, `freeEnergy_le_of_le`.)

## 5. Drift bound `β · KL(π* ‖ ref) ≤ max r − min r = 2`

| β | 0.25 | 0.5 | 1 | 2 |
|---|---|---|---|---|
| `β·KL(π*‖ref)` | `0.346321` | `0.360895` | `0.232212` | `0.122804` |

All comfortably below `2`; the bound is not tight for this instance but is
attained in the limit of a two-point space with an extreme reward gap.
(Proved: `gibbs_kl_drift_le`.)

## 6. Composition of tilts (group action)

With a second reward `s = [0.7, -1.2, 0.3]`:

```
tilt (tilt ref r) s = [0.567582, 0.018738, 0.413680]
tilt ref (r + s)    = [0.567582, 0.018738, 0.413680]
```

Identical to machine precision.
(Proved: `gibbs_add`, `rlhf_sequential`.)

## 7. Pinsker estimates (cycle 5)

Termwise estimate `a log(a/b) − a + b − 3(a−b)²/(2(a+2b))` (must be `≥ 0`):

| (a, b) | (0.5, 1) | (2, 1) | (1, 0.1) | (0.1, 1) | (5, 0.2) | (1.001, 1) |
|---|---|---|---|---|---|---|
| value | `0.003426` | `0.011294` | `0.390085` | `0.091170` | `4.894379` | `0.000000` |

(The value at `a = b` is `0` to machine precision, confirming that the estimate
is tight to second order — which is why the constant `3/2` is the right one.)

Pinsker slack `2·KL(p‖q) − ‖p−q‖₁²` (must be `≥ 0`):

| (p, q) | value |
|---|---|
| `([.5,.3,.2], [.2,.3,.5])` | `0.189774` |
| `([.9,.05,.05], [.1,.45,.45])` | `0.955559` |
| `([1,0,0], [.34,.33,.33])` | `0.415219` |
| `([.4,.4,.2], [.39,.41,.2])` | `0.000100` |

(Proved: `xlogx_sub_ge`, `kl_term_ge`, `klDivFin_pinsker`, `gibbs_l1_drift_sqrt`.)

## 8. OEIS

No integer sequence arises in this problem (all objects are real-valued
distributions and free energies), so no OEIS lookup is applicable.
