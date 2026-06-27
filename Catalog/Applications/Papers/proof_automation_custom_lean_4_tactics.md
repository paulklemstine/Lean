# Computational Evidence — Proof Automation Tactics

Concise numerical evidence gathered before formalizing the three tactics
(`tropical_simp`, `number_theory_decide`, `spectral_bound`).

## 1. `tropical_simp` — min-plus identities

Working over `Tropical ℤ` with `a ⊕ b = min a b`, `a ⊙ b = a + b`.

| identity | check at `(a,b,c) = (1,4,2)` (where relevant) | holds? |
|---|---|---|
| `a ⊕ a = a` | `min 1 1 = 1` | ✓ |
| `a ⊙ (b ⊕ c) = a⊙b ⊕ a⊙c` | `1 + min 4 2 = min 5 3 = 3` | ✓ |
| `(a ⊕ b)² = a² ⊕ b²` (freshman) | `2·min 1 4 = 2 = min 2 8` | ✓ |
| `(a ⊕ b)³ = a³ ⊕ b³` | `3·min 1 4 = 3 = min 3 12` | ✓ |

Freshman's dream boundary: the identity `n • min p q = min (n•p) (n•q)` was
spot-checked for `n ∈ {0,1,2,3,5}` and random `p,q ∈ [-5,5]`; it holds whenever
`n ≥ 0` and **fails for negative scalars** (e.g. `(-1)·min 1 4 = -1 ≠ min(-1,-4) = -4`).
This pins the hypothesis `0 ≤ (n:ℤ)` used in the proof.

## 2. `number_theory_decide` — small cases + Pisano periodicity

Fibonacci residues (period = first `p>0` with `F p ≡ 0`, `F(p+1) ≡ 1`):

| modulus `m` | Fibonacci residues `F 0..` | Pisano period |
|---|---|---|
| 2 | 0 1 1 **0 1 1** … | 3 |
| 3 | 0 1 1 2 0 2 2 1 **0 1** … | 8 |
| 5 | 0 1 1 2 3 0 3 3 1 4 0 4 4 3 2 0 2 2 4 1 **0 1** | 20 |

Seeds verified: `F 3 = 2 ≡ 0 (mod 2)`, `F 4 = 3 ≡ 1 (mod 2)`;
`F 8 = 21 ≡ 0 (mod 3)`, `F 9 = 34 ≡ 1 (mod 3)`. (OEIS A001175 = Pisano periods:
1, 3, 8, 6, 20, 24, 16, 12, 24, 60, … — matches the table.)

Carmichael small case: `561 = 3·11·17`, squarefree, and `(p−1) ∣ 560` for each
prime (`2|560`, `10|560`, `16|560`) — Korselt's criterion, all decidable.
`561` is composite and `gcd(561,560)=1`.

## 3. `spectral_bound` — Gershgorin discs

`A2 = [[2,1],[1,2]]`: characteristic polynomial `(2−λ)² − 1`, eigenvalues
`λ = 1, 3`. Gershgorin disc of each row: center `2`, radius `1` → `[1,3]`.
The eigenvalues `1` and `3` sit on the boundary, so the bound `|λ − 2| ≤ 1` is
**sharp** (cannot be tightened by Gershgorin alone).

`D3 = [[5,1,1],[1,5,1],[1,1,5]]`: each off-diagonal row sum is `2 < 5`
(strict diagonal dominance) → no Gershgorin disc contains `0` → `det ≠ 0`.
Direct check: `det D3 = 5³ + 2 − 3·5 = 125 + 2 − 15·... = 112 ≠ 0` (and indeed
eigenvalues are `4, 4, 7`, all positive).

## Counterexample hunt

* Freshman's dream with negative exponent-scalar: falsified (see §1) — informs the
  `0 ≤ n` hypothesis.
* Pisano "period = p" with wrong seeds: e.g. `(m,p)=(2,2)` has `F 2 = 1 ≢ 0`, so
  the seed hypothesis fails and the periodicity theorem is (correctly) not
  applicable — no false instance produced.
* Gershgorin sharpness: searched balanced `2×2` symmetric matrices; the bound is
  attained exactly when off-diagonal magnitudes are equal, never violated.

No counterexample to any *stated* theorem was found; all stated hypotheses are
necessary where flagged.
