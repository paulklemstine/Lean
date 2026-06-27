# Computational Evidence — Erdős–Rényi Threshold Phenomena

Supports `Catalog/Probability/ErdosRenyiThreshold.lean`. All claims below are *also*
proved formally in that file; the numbers here are sanity checks.

## 1. Total mass is a probability distribution (`weight_sum_eq_one`)
For `m` independent slots, `∑_{S⊆[m]} p^{|S|}(1-p)^{m-|S|} = (p+(1-p))^m = 1`.
- m=1: `p + (1-p) = 1`. ✓
- m=2: `(1-p)^2 + 2p(1-p) + p^2 = 1`. ✓
- m=3, p=1/2: `8 · (1/2)^3 = 1`. ✓

## 2. Marginal of a fixed slot-set (`prob_contains_subset`)
P(all of `T` present) `= p^{|T|}`, independent of `m`.
- T a single edge: `p`. ✓  T two edges: `p^2`. ✓

## 3. Expected number of edges (`expectation_card`)
E[#present slots] `= m·p`. For `G(n,p)`, `m = C(n,2)`, so E[#edges] `= C(n,2)·p`.
- n=4, p=1/2: `C(4,2)·1/2 = 6·1/2 = 3`. ✓
- n=10, p=1/n=0.1: `45·0.1 = 4.5` (linear regime around the connectivity scale). ✓

## 4. Subgraph first moment (`expectation_subgraph_count_uniform`)
For a family `𝒯` of targets each using `k` slots, E[#present targets] `= |𝒯|·p^k`.
For triangles in `G(n,p)`: `|𝒯| = C(n,3)` triangles, each `k=3` edges, so
E[#triangles] `= C(n,3)·p^3`.
- Threshold check `p = c/n`: `C(n,3)·(c/n)^3 → c^3/6`, a constant — the classic
  triangle threshold at `p ~ 1/n`. For `p = o(1/n)`, E → 0 (a.a.s. triangle-free).

## 5. First-moment / union bound (`first_moment_threshold`)
P(some target appears) `≤ ∑_T p^{|T|}` = E[#targets]. Whenever E → 0 the appearance
probability → 0. Uniform case: if `|𝒯|·p^k → 0`, a.a.s. no copy.

## 6. Probabilistic existence (`exists_avoiding_all`)
If `∑_T p^{|T|} < 1` then a configuration avoiding *every* target exists. This is the
Erdős deletion-free lower-bound engine (e.g. Ramsey `R(k,k) > 2^{k/2}` style bounds):
with `𝒯` the monochromatic cliques and `p=1/2`, `C(n,k)·2^{1-C(k,2)} < 1` forces a
2-colouring with no monochromatic `k`-clique.

## Counterexample hunt
No counterexamples expected: every statement is an exact identity or a Markov/union
bound with the `0 ≤ p ≤ 1` hypothesis. Formal proofs confirm (standard axioms only).
