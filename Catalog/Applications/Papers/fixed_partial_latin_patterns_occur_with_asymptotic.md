# Theorem Trace (internal anti-hallucination ledger)

Every claim in `ARTICLE.md` and `RESEARCH_PAPER.md` must trace to one of the
Lean declarations below. No result is stated in the prose that does not appear here.

| Lean name | Kind | Mathematical statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|---|
| `LatinSquare n` | structure/def | An `n×n` array `val : Fin n → Fin n → Fin n` with every row injective (`row_inj`) and every column injective (`col_inj`). | "What a Latin square is" section | Definition 1 |
| `LatinSquare.ext` | theorem | Two Latin squares are equal iff their underlying arrays agree. | (implicit, not named) | Remark after Definition 1 |
| `DecidableEq (LatinSquare n)` | instance | Equality of Latin squares is decidable. | not stated | Remark (finiteness) |
| `LatinSquare.equivSubtype` | def | `LatinSquare n` is in bijection with the subtype of arrays satisfying row/column injectivity. | not stated | Lemma (finiteness scaffold) |
| `Fintype (LatinSquare n)` | instance | There are finitely many Latin squares of order `n`. | "finitely many" | Proposition 2 (finiteness) |
| `LatinSquare.permAct` | def | `(permAct σ L).val r c = σ (L.val r c)`: relabel symbols by `σ ∈ Perm (Fin n)`; preserves row/column injectivity. | "relabelling symbols" | Definition 3 |
| `LatinSquare.permAct_one` | theorem | `permAct 1 L = L`. | (implicit) | Lemma 4 (action axioms) |
| `LatinSquare.permAct_mul` | theorem | `permAct (σ*τ) L = permAct σ (permAct τ L)`. | (implicit) | Lemma 4 (action axioms) |
| `LatinSquare.fiberEquiv` | def | For symbols `s,t`, `Equiv.swap s t` gives a bijection `{L // L.val r c = s} ≃ {L // L.val r c = t}`. | "the swap trick" | Theorem 5 (fiber bijection) |
| `LatinSquare.sigmaEquiv` | def | `LatinSquare n ≃ Σ t : Fin n, {L // L.val r c = t}`: partition by the symbol in cell `(r,c)`. | "sorting by one cell" | Lemma 6 (cell partition) |
| `LatinSquare.card_eq_mul_card_fiber` | theorem | For any `r c s : Fin n`, `card (LatinSquare n) = n * card {L // L.val r c = s}`. | Main theorem | Theorem 7 (Exact one-cell uniformity) |

## Scope honesty note

The Phase A Lean output proves the **exact** `k = 1` case (one prescribed cell)
of the broader pattern conjecture, and it proves it as an exact identity, not
merely asymptotically. The prose must:
- present `card_eq_mul_card_fiber` as the proved main theorem (exact `1/n`);
- present the general "fixed pattern with probability `n^{-k}`" statement as a
  conjecture / motivation, clearly labelled as not (yet) proved, and explain
  that `k = 1` is the verified base case.
No grander claim than `card_eq_mul_card_fiber` is asserted as proved.
