# Computational Evidence — Differential & Wide-Trail Bounds

Concise numerical support for the formalized claims. All checks below are also
discharged formally in the `.lean` files (by `decide` for the finite witnesses,
or by general proof for the universal claims).

## 1. DDT entries are even; differential uniformity ≥ 2

Small case: `G = H = GF(2)² ≅ (ZMod 2)²` (a 2-bit S-box). For any permutation
`F` and any nonzero input difference `a`, each DDT row sums to `|G| = 4` and
every entry is even, so the maximal entry over the row is `≥ 2`.

| row sum `Σ_b DDT(a,b)` | parity of entries | forced max entry |
|---|---|---|
| `4` (`= |G|`) | all even (`ddt_even`) | `≥ 2` (`diff_uniformity_ge_two`) |

Interpretation: max differential probability `≥ 2/|G|`. For the AES S-box
(`|G| = 256`, uniformity `4`) this is `4/256 = 2⁻⁶`; the universal floor is
`2/256 = 2⁻⁷`. (The AES-specific value `4` is conjecture C2.)

## 2. The branch-number factorization `25 = 5²`

Wide-trail accounting per round of the canonical minimal trail:

| state | pattern | active bytes `wt` | active columns `colActive` |
|---|---|---|---|
| `a₁` | one byte | `1` | `1` |
| `a₂` | one full column | `4` | `1` |
| `a₃` | full state | `16` | `4` |
| `a₄` | one byte per column | `4` | `4` |
| total | — | **`25`** | — |

Checks (all hold with **equality**, confirming tightness):
- Round 1 branch: `colWeight(a₁) + colWeight(a₂) = 1 + 4 = 5 = B`.
- Round 3 branch: `colWeight(a₃) + colWeight(a₄) = 4 + 1 = 5 = B`.
- Super-box branch: `colActive(a₂) + colActive(a₄) = 1 + 4 = 5 = B`.
- Bound: `B² = 25` and `wt(a₁)+wt(a₂)+wt(a₃)+wt(a₄) = 1+4+16+4 = 25`.

Formal counterpart: `AESFourRound.aes_four_round_tight` (states `t1..t4` over
`ZMod 2`, every condition checked by finite evaluation) and
`AESFourRound.tight_trail_weight`.

## 3. Counterexample hunt

- "Some S-box has max DP `= 1/|G|`" (perfect resistance): **refuted** by
  `diff_uniformity_ge_two` (evenness forces `≥ 2/|G|`).
- "Four rounds can have `< 25` active S-boxes under the branch/super-box
  hypotheses": **refuted** by `four_round_bound` (`B² ≤ total`).
- "The `25` bound is loose": **refuted** by the explicit `1-4-16-4` witness
  attaining exactly `25`.

## 4. OEIS

The minimal active-S-box counts for `4k` AES rounds, `25, 50, 75, …` (i.e.
`25k`), are a simple arithmetic progression and not a distinctive OEIS entry;
the structural content is the factor `25 = (branch number)²`, not the sequence.
