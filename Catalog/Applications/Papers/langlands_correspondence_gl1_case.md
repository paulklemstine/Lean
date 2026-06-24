# THEOREM TRACE (internal anti-hallucination ledger)

All names below are taken verbatim from the Phase A Lean output. No other
theorems are stated as results in the prose deliverables.

| Lean name | Kind | Mathematical statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|---|
| `LanglandsGL1.artinIso` | def | Artin reciprocity, cyclotomic case: a group isomorphism $\mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q}) \cong (\mathbb{Z}/n\mathbb{Z})^\times$. | "The reciprocity dictionary" section | Definition 3.1 / Theorem 4.1 |
| `LanglandsGL1.galois_abelian` | thm | For $a,b \in \mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q})$, $ab = ba$ (the Galois group is abelian). | "Why everything commutes" section | Theorem 4.2 |
| `LanglandsGL1.precompMulEquiv` | def | For a group isomorphism $e : G \cong H$ and commutative target $M$, precomposition gives an isomorphism of character groups $(H \to M) \cong (G \to M)$. | implicit (functoriality) | Lemma 3.3 |
| `LanglandsGL1.langlandsGL1` | def | The GL(1) correspondence: $\widehat{(\mathbb{Z}/n\mathbb{Z})^\times} \cong \big(\mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q}) \to \mathbb{C}^\times\big)$, i.e. Dirichlet characters $\cong$ 1-dim Galois reps, via $\chi \mapsto \chi \circ (\text{Artin map})$. | "The main theorem" section | Theorem 4.3 (main) |
| `LanglandsGL1.card_dirichlet_eq_totient` | thm | $\#\{\text{Dirichlet characters mod } n \text{ over } \mathbb{C}\} = \varphi(n)$. | "Counting characters" section | Theorem 4.4 |
| `LanglandsGL1.card_galois_reps_eq_totient` | thm | $\#\{\text{1-dim complex reps of } \mathrm{Gal}(\mathbb{Q}(\zeta_n)/\mathbb{Q})\} = \varphi(n)$. | "Counting characters" section | Theorem 4.5 |
| `LanglandsGL1.card_galois_reps_prime` | thm | For prime $p$, that count is $p - 1$. | concrete example | Corollary 4.6 |
| `HeckeFactorization.heckeFactorization` | def | For coprime $m,k$: $\widehat{(\mathbb{Z}/mk)^\times} \cong \widehat{(\mathbb{Z}/m)^\times} \times \widehat{(\mathbb{Z}/k)^\times}$ (CRT local–global factorization). | "Splitting into primes" section | Theorem 4.7 |

Notes:
- The base field throughout is $\mathbb{Q}$; the extension field $L$ is any field with
  `IsCyclotomicExtension {n} ℚ L`, i.e. a copy of $\mathbb{Q}(\zeta_n)$.
- Hypotheses faithfully reproduced: `NeZero n` (so $\zeta_n$ exists), `Field L`.
- The unconditionality over $\mathbb{Q}$ comes from `Polynomial.cyclotomic.irreducible_rat`.
