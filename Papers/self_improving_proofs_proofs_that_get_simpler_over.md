# Computational Evidence: Self-Improving Proofs

The refinement theory is discrete and finite, so the relevant evidence is a
direct calculation of complexities along a refinement chain and a check of the
structural claims on small cases. All numbers below are reproduced by the
formal development (`SelfImprovingProofs.lean`).

## 1. The √2 refinement chain

Complexity `C(P) = length + depth + numLemmas`:

| Proof             | length | depth | numLemmas | C(P) |
|-------------------|--------|-------|-----------|------|
| `sqrt2_verbose`      | 40 | 12 | 8 | **60** |
| `sqrt2_intermediate` | 20 |  6 | 3 | **29** |
| `sqrt2_streamlined`  |  1 |  1 | 0 | **2**  |

The chain `60 → 29 → 2` is strictly decreasing, so each step is a genuine
refinement, and `2` is the minimum — the terminal / simplest proof of the three.

## 2. Step-bound spot check

For a strictly decreasing chain the bound `C(P_n) + n ≤ C(P_0)` holds:

- `n = 1`: `29 + 1 = 30 ≤ 60` ✓
- `n = 2`: `2  + 2 = 4  ≤ 60` ✓

More generally a strictly decreasing `ℕ`-chain from `c` has at most `c` steps;
sampling `c = 0,1,2,3` confirms maximum chain lengths `0,1,2,3` respectively.

## 3. Eventual-constancy sampling

Non-increasing sequences tested for the "eventually constant" claim
`∃ N, ∀ n ≥ N, f n = f N`:

- `f = 5,3,3,1,1,1,1,…` stabilizes at `N = 3`, value `1`.
- `f = 7,7,7,…` stabilizes at `N = 0`, value `7`.
- `f n = max(4 - n, 0)` i.e. `4,3,2,1,0,0,…` stabilizes at `N = 4`, value `0`.

Every sampled non-increasing `ℕ`-sequence reaches a final constant value, as the
general theorem predicts.

## 4. Counterexample hunt (uniqueness of the simplest proof)

Testing whether "minimal complexity ⇒ unique proof": the two artifacts
`⟨0,0,0,trivial⟩` and `⟨0,0,0,True.intro⟩` both certify `True` at complexity `0`
yet are distinct records. This is a genuine counterexample to uniqueness, so the
theory only claims uniqueness of the *value* `Cmin`, not of the proof object.

## 5. OEIS note

The maximal-chain-length sequence for a strictly decreasing `ℕ`-process started
at `c` is simply `0,1,2,3,4,…` (the identity, A001477); no deeper sequence
arises, which is itself evidence that the finite step bound is exactly `c` and
cannot be improved.
