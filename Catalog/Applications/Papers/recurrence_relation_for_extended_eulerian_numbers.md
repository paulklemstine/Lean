# Theorem Trace (internal anti-hallucination ledger)

Every name below is taken verbatim from the Phase A Lean output. No result is
stated in ARTICLE.md or RESEARCH_PAPER.md that is not in this table.

## CombFoundations.lean

| Lean name | Mathematical statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `choose_succ_succ_cast` | $\binom{n+2}{j+1}=\binom{n+1}{j}+\binom{n+1}{j+1}$ (Pascal, over $\mathbb{R}$) | yes (Pascal's rule) | yes (Lemma 1) |
| `choose_absorb_cast` | $(j+1)\binom{n+1}{j+1}=(n+1)\binom{n}{j}$ (absorption, over $\mathbb{R}$) | yes (absorption) | yes (Lemma 2) |
| `alt_binom_pascal_split` | $\sum_{i<m+2}(-1)^i\binom{n+2}{i}(c-i)^q = \sum_{i<m+2}(-1)^i\binom{n+1}{i}(c-i)^q - \sum_{j<m+1}(-1)^j\binom{n+1}{j}(c-1-j)^q$ | yes (split) | yes (Lemma 3) |
| `alt_binom_absorb_sum` | $\sum_{i<m+1}(-1)^i\binom{n+1}{i} i\,(c-i)^q = -(n+1)\sum_{j<m}(-1)^j\binom{n}{j}(c-1-j)^q$ | yes (absorb) | yes (Lemma 4) |
| `alt_binom_pascal_recombine` | $\sum_{j<m+1}(-1)^j\binom{n}{j}(d-j)^q-\sum_{j<m}(-1)^j\binom{n}{j}(d-1-j)^q=\sum_{j<m+1}(-1)^j\binom{n+1}{j}(d-j)^q$ | yes (recombine) | yes (Lemma 5) |

## ExtendedEulerian.lean

| Lean name | Mathematical statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `A` (def) | $A(n,k,s)=\sum_{i=0}^{k}(-1)^i\binom{n+1}{i}(k+1-i-s)^n$ | yes (Definition) | yes (Definition 1) |
| `A_eq` | $A(n,k,s)=\sum_{i=0}^{k}(-1)^i\binom{n+1}{i}((k+1-s)-i)^n$ (rebased form) | yes | yes (Prop. 1) |
| `A_zero_zero` | $A(0,0,s)=1$ | yes | yes (Prop. 2) |
| `A_zero_succ` | $A(0,k+1,s)=0$ | yes | yes (Prop. 3) |
| `A_at_zero` | $A(n,0,s)=(1-s)^n$ | yes | yes (Prop. 4) |
| `A_recurrence` | $A(n+1,k+1,s)=(k+2-s)A(n,k+1,s)+(n-k+s)A(n,k,s)$ | yes (Main Theorem) | yes (Theorem 1) |
