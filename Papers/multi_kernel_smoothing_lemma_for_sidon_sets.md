# Computational Evidence — Sidon sets, additive energy, and the representation kernel

All computations below were run with exact integer/`Finset` arithmetic (no
floating point). A finite set `s ⊆ ℤ` is **Sidon** when all pairwise sums are
distinct. We write:

* `E[s]` = additive energy = `#{(a,b,c,d) ∈ s⁴ : a+b = c+d}` (`Finset.addEnergy`);
* `r_s(x)` = representation kernel = `#{(a,b) ∈ s² : a+b = x}`;
* `s+s` = sumset = `{a+b : a,b ∈ s}`.

## 1. Additive energy: the exact Sidon value and the strict gap

Claim under test: `E[s] + |s| = 2|s|²` **iff** `s` is Sidon; and `E[s] + |s| ≥ 2|s|²`
always (universal lower bound).

| set `s`            | Sidon? | `|s|` | `E[s]` | `2|s|² − |s|` | `E[s]` vs bound |
|--------------------|:------:|:-----:|:------:|:-------------:|:---------------:|
| `{0,1,3,7}`        | yes    | 4     | 28     | 28            | equal (tight)   |
| `{0,1,2}` (AP)     | no     | 3     | 19     | 15            | `19 > 15`       |
| `{0,1,2,3}` (AP)   | no     | 4     | 44     | 28            | `44 > 28`       |
| `{0,2,5,11,13}`    | no     | 5     | 53     | 45            | `53 > 45`       |

Every row satisfies `E[s] ≥ 2|s|² − |s|`, with **equality exactly on the Sidon
row**. This is the content of `addEnergy_ge` and `sidon_iff_addEnergy`.

## 2. Representation kernel `r_s(x)` is two-valued for Sidon sets

For the Sidon set `s = {0,1,3,7}` the nonzero values of `r_s` are:

```
x : 0 1 2 3 4 6 7 8 10 14
r : 1 2 1 2 2 2 2 2  2  1      (doubles 0,2,6,14 → r=1; all others r=2)
```

Maximum is `2`, and `r_s(x)=1` occurs precisely at the doubles `2a`
(`a ∈ {0,1,3,7} → 0,2,6,14`). This matches `sidon_repCount_le_two` and
`sidon_repCount_eq_one_iff`.

For the non-Sidon `s = {0,1,2,3}` the kernel exceeds `2`: `r_s(3) = 4`
(pairs `(0,3),(1,2),(2,1),(3,0)`), so the bound `≤ 2` is genuinely special to
Sidon sets.

## 3. Sumset size

Claim: for Sidon `s`, `2·|s+s| = |s|(|s|+1)`.

| set `s`         | Sidon? | `2·|s+s|` | `|s|(|s|+1)` | match? |
|-----------------|:------:|:---------:|:------------:|:------:|
| `{0,1,3,7}`     | yes    | 20        | 20           | yes    |
| `{0,1,2,3}` (AP)| no     | 14        | 20           | no     |
| `{0,2,5,11,13}` | no     | 28        | 30           | no     |

Equality holds exactly on the Sidon row — the content of `sidon_sumset_card`.

## 4. Counterexample hunt

The universal lower bound `E[s] ≥ 2|s|² − |s|` was tested on all AP witnesses,
random small sets, and the geometric family `{2⁰,…,2^{k-1}}` (a Sidon set for
every `k`); **no counterexample was found**, consistent with the proved theorem.
The *equality* `E[s] + |s| = 2|s|²` was found to fail for every non-Sidon set
tested and to hold for every Sidon set tested, confirming the biconditional.

## 5. OEIS note

The maximum size `F(N)` of a Sidon set contained in `{1,…,N}` is the classical
Sidon extremal function (OEIS A005282-adjacent perfect-difference-set data);
this file studies the *energy/kernel* invariants that govern its extremal
behaviour rather than the sequence `F(N)` itself, so no new sequence is claimed.
