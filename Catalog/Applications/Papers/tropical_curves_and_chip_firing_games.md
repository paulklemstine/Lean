# Theorem Trace (internal anti-hallucination record)

Source of truth: `Catalog/FINAL/Tropical/ChipFiring/NonCircular.lean`.
Every claim in `ARTICLE.md` and `RESEARCH_PAPER.md` must trace to one of the
entries below. No theorem may be invented or upgraded into a grander claim.

## Definitions

| Lean name | Mathematical statement | Article location | Paper location |
|-----------|------------------------|------------------|----------------|
| `ChipFiring.divisorDegree` | `deg D = ∑_{v} D(v)` for `D : V → ℤ` | "Divisors and degree" | Def. 2.1 |
| `ChipFiring.lap` | `lap f v = ∑_{w ~ v} (f v − f w)` | "Firing moves" | Def. 2.2 |
| `ChipFiring.canonicalDivisor` | `K(v) = deg(v) − 2` | "The canonical divisor" | Def. 2.3 |
| `ChipFiring.genus` | `g = |E| − |V| + 1` | "Genus" | Def. 2.4 |

## Theorems / Lemmas (all proved in Lean)

| Lean name | Mathematical statement | Article location | Paper location |
|-----------|------------------------|------------------|----------------|
| `ChipFiring.sum_source_eq_sum_target` | `∑_v ∑_{w~v} f(v) = ∑_v ∑_{w~v} f(w)` | "The bookkeeping trick" | Lemma 3.1 |
| `ChipFiring.deg_lap_eq_zero` | `∑_v lap f v = 0` | "Conservation of chips" | Thm. 3.2 |
| `ChipFiring.deg_canonicalDivisor_eq_two_genus_sub_two` | `∑_v K(v) = 2g − 2` | "The 2g − 2 law" | Thm. 3.3 |

## Explicitly NOT proved (do not claim as theorems)

- Full tropical Riemann–Roch `r(D) − r(K−D) = deg D − g + 1` — open (Future Direction 2).
- Riemann inequality `r(D) ≥ deg D − g` — open (Future Direction 1).
- Baker–Norine rank closed forms on `Kₙ` — open (Future Direction 3).

These appear only as motivation / future work, never as established results.
