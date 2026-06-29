# Theorem Trace — Quadratic Reciprocity, multiple proofs

This internal file lists every theorem/lemma/definition name appearing in the
Phase A Lean output, its mathematical statement, and where it is stated in the
human-facing documents. No result outside this table appears as a claimed
theorem in `ARTICLE.md` or `RESEARCH_PAPER.md`.

| Lean name | Mathematical statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|
| `QuadraticReciprocity.Eisenstein.legendreSym_eq_neg_one_pow_sum` | For distinct odd primes $p,q$: $\left(\frac{q}{p}\right) = (-1)^{\sum_{x=1}^{(q-1)/2} \lfloor xp/q \rfloor}$ (the Eisenstein lattice-point expansion). | Yes — "counting points under a line" section | Yes — Lemma 1 (Eisenstein expansion) |
| `QuadraticReciprocity.Eisenstein.quadratic_reciprocity` | For distinct odd primes $p,q$: $\left(\frac{q}{p}\right)\left(\frac{p}{q}\right) = (-1)^{\lfloor p/2\rfloor \lfloor q/2\rfloor}$, via lattice counting. | Yes — main theorem, geometric proof | Yes — Theorem 1 (geometric proof) |
| `QuadraticReciprocity.GaussSum.gauss_sum_sq_value` | For a non-trivial quadratic character $\chi$ of a finite field $F$ and a primitive additive character $\psi$: $g(\chi,\psi)^2 = \chi(-1)\,|F|$. | Yes — "the magic square" section | Yes — Lemma 2 (Gauss-sum square) |
| `QuadraticReciprocity.GaussSum.quadratic_reciprocity` | For distinct odd primes $p,q$: $\left(\frac{q}{p}\right)\left(\frac{p}{q}\right) = (-1)^{\lfloor p/2\rfloor \lfloor q/2\rfloor}$, via the quadratic Gauss sum / Frobenius. | Yes — main theorem, algebraic proof | Yes — Theorem 2 (Gauss-sum proof) |
| Supplementary laws (`Supplementary.lean`, per Phase A future directions) | $\left(\frac{-1}{p}\right)$ determined by $p \bmod 4$; $\left(\frac{2}{p}\right)$ determined by $p \bmod 8$. | Yes — "two warm-up laws" section | Yes — Section on supplementary laws |

Notes:
- The exponent $\lfloor p/2\rfloor\lfloor q/2\rfloor$ equals $\frac{p-1}{2}\cdot\frac{q-1}{2}$ for odd primes (since $\lfloor p/2\rfloor = (p-1)/2$).
- `gauss_sum_sq_value` is stated for a general finite field with a non-trivial quadratic character and primitive additive character; the prose specialises it to $F=\mathbb{Z}/p$.
- The supplementary laws' exact Lean identifiers were not exposed in the (truncated) Phase A text, so they are described by their mathematical content only and are NOT used as `key_results` entries in `PACKAGE.json`.
