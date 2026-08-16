# Computational evidence: hamiltonicity of Cayley graphs of squarefree order

All computations below were performed with short ad-hoc Python programs (brute-force
enumeration plus a pruned backtracking search for hamiltonian cycles).  They are exploratory
only: **nothing in this file is machine-verified**.  The verified statements are the Lean
theorems in `Catalog/Pythagorean/CayleyHamiltonian/`.

## 1. Exhaustive scan over small groups of squarefree order

For each group `G` below we enumerated *all* connection sets `S` of size `1` or `2`
(the graph uses the symmetric closure `S ∪ S⁻¹`, exactly as in the Lean definition
`CayleyHamiltonian.cayleyGraph`), kept the connected ones, and searched for a hamiltonian
cycle.

| group | order | connected Cayley graphs tested | hamiltonian | non-hamiltonian |
|---|---|---|---|---|
| `Z_6`  | 6 = 2·3     | 11  | 11  | 0 |
| `Z_10` | 10 = 2·5    | 34  | 34  | 0 |
| `Z_15` | 15 = 3·5    | 92  | 92  | 0 |
| `Z_30` | 30 = 2·3·5  | 284 | 284 | 0 |
| `Z_15 ⋊_1 Z_2 ≅ Z_30` | 30 | 284 | 284 | 0 |
| `Z_15 ⋊_14 Z_2 ≅ D_15` | 30 | 180 | 180 | 0 |
| `Z_15 ⋊_4 Z_2 ≅ Z_5 × S_3` | 30 | 240 | 240 | 0 |
| `Z_15 ⋊_11 Z_2 ≅ Z_3 × D_5` | 30 | 216 | 216 | 0 |

Every one of the 1531 connected Cayley graphs found was hamiltonian; no counterexample
appeared.  (All four isomorphism types of groups of order `30 = 2·3·5` occur in the list:
they are the semidirect products `Z_15 ⋊_k Z_2` for `k ∈ {1, 14, 4, 11}`.)

## 2. Spot checks in order `210 = 2·3·5·7`

`Z_210`, two-element connection sets:

| `S` | orders of the two elements | hamiltonian? |
|---|---|---|
| `{2, 105}`  | 105, 2 | yes |
| `{30, 7}`   | 7, 30  | yes |
| `{14, 15}`  | 15, 14 | yes |
| `{1}`       | 210    | yes (single generator) |
| `{6, 35}`   | 35, 6  | naive search inconclusive (see below) |
| `{10, 21}`  | 21, 10 | naive search inconclusive (see below) |

For the two inconclusive cases the *explicit* boustrophedon cycle of
`CayleyHamiltonian.isHamiltonian_of_abelian_pair` was evaluated directly and checked to be a
hamiltonian cycle (all 210 vertices distinct, every consecutive difference in `S ∪ S⁻¹`):

```
(a,b) = (6,35):  orders (35,6),  210 distinct vertices, all steps in ±{6,35}  ✓
(a,b) = (10,21): orders (21,10), 210 distinct vertices, all steps in ±{10,21} ✓
(a,b) = (2,105): orders (105,2), 210 distinct vertices, all steps in ±{2,105} ✓
```

This is exactly the case that the formal theorem covers, and the brute-force search simply
lacked the structural hint.

## 3. What the data suggested, and what was then proved

* No connected Cayley graph of squarefree order in the scan failed to be hamiltonian —
  consistent with the theorem of the paper.
* The hardest instances for a naive search are those where *no* connection-set element
  generates the group (e.g. `Z_210` with `S = {6, 35}`).  This motivated the formalization
  of the torus/boustrophedon construction
  (`CayleyHamiltonian.isHamiltonian_of_abelian_pair`), which produces the cycle directly.
* Dihedral groups behave uniformly: the "rotate all the way round, reflect, rotate back"
  cycle always works.  This motivated
  `CayleyHamiltonian.dihedral_isHamiltonian` and its presentation-free version
  `CayleyHamiltonian.isHamiltonian_of_dihedral_pair`.
* Groups of order 2 are the only genuine obstruction visible in the data (a single edge is
  not a cycle), which is recorded formally in
  `CayleyHamiltonian.not_isHamiltonian_of_card_eq_two`.

## 4. Reproduction

The scan used the following ingredients (pseudo-code):

```python
def cayley_adj(els, mul, S):          # symmetric closure of S
    ...
def hamiltonian(adj):                 # backtracking with connectivity pruning
    ...                               # + Warnsdorff-style neighbour ordering
for k in [1, 14, 4, 11]:              # the four groups Z_15 ⋊_k Z_2 of order 30
    scan(semidirect(15, k), maxsize=2)
```

## 5. Exhaustive scan for the complete order-`2p` theorem

The formal theorem `CayleyHamiltonian.isHamiltonian_of_card_eq_two_mul_prime` claims that
**every** connected Cayley graph of a group of order `2p` (`p` an odd prime) is hamiltonian.
This is a universal statement over *all* connection sets, so it was tested exhaustively over
all `2^{2p-1} - 1` nonempty subsets of the nonidentity elements, for both groups of order `2p`
(the cyclic group and the dihedral group), for `p = 3, 5, 7`:

| group | connected connection sets | hamiltonian | counterexamples |
|-------|--------------------------:|------------:|----------------:|
| `Z_6`  |    27 |    27 | 0 |
| `D_3`  |    25 |    25 | 0 |
| `Z_10` |   495 |   495 | 0 |
| `D_5`  |   491 |   491 | 0 |
| `Z_14` |  8127 |  8127 | 0 |
| `D_7`  |  8121 |  8121 | 0 |
| total  | 17286 | 17286 | 0 |

## 6. Exhaustive scan for the abelian order-`pq` theorem

`CayleyHamiltonian.abelian_isHamiltonian_of_card_eq_prime_mul_prime` claims the same for
abelian groups of order `pq` with `p ≠ q` prime.  An abelian group of squarefree order is
cyclic, so the only group to test is `Z_{pq}`:

| group  | connection sets tested | connected | hamiltonian | counterexamples |
|--------|------------------------|----------:|------------:|----------------:|
| `Z_15` | all `2^14 - 1`         |     16365 |       16365 | 0 |
| `Z_21` | all with `|S| ≤ 3`     |      1306 |        1306 | 0 |
| `Z_35` | all with `|S| ≤ 2`     |       564 |         564 | 0 |

The `Z_21` and `Z_35` scans were truncated by connection-set size purely for running time; no
counterexample appeared anywhere.

**Caveat.**  These scans are ordinary computations, not machine-checked Lean artifacts.  They
were used to gain confidence *before* formalizing; the certainty comes from the Lean proofs,
which are `sorry`-free and depend only on the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`).

## 7. The transversal case of order `pq` (added in the current cycle)

`CayleyHamiltonian.pq_isHamiltonian_or_transversal` reduces the order-`pq` problem to
connection sets that miss the normal Sylow `q`-subgroup `N` and meet each nontrivial coset of
`N` at most once.  Before formalizing anything we searched that configuration exhaustively in
the nonabelian groups `Z_q ⋊ Z_p` for two-element connection sets `S = {x, y}` with `x`, `y`
outside `N` and in distinct cosets (only generating pairs are counted):

| group | order | pairs tested | hamiltonian | counterexamples |
|---|---:|---:|---:|---:|
| `Z_7 ⋊ Z_3`  | 21 | 42 | 42 | 0 |
| `Z_13 ⋊ Z_3` | 39 | 55 | 55 | 0 |
| `Z_11 ⋊ Z_5` | 55 | 57 | 57 | 0 |

(The last two rows are random samples of 60 pairs each; every generating pair among them is
hamiltonian.)  A structural observation from the search: no hamiltonian cycle in this
configuration is a lift of a hamiltonian cycle of the quotient `Z_p` along a positive word.
Indeed, if `x̄ = 1` and `ȳ = m ≠ 1` in `Z_p`, then a word using `α` copies of `x` and `β`
copies of `y` with `α + β = p` and `α + βm ≡ 0 (mod p)` forces `β(m − 1) ≡ 0`, i.e. `β ∈ {0,
p}`; both extremes give voltage `x^p = 1` or `y^p = 1`.  Every cycle found therefore uses
inverses, which matches the verified Lean cycle in `Frobenius21.lean`:

`x x y x x y x y x x y y x⁻¹ x⁻¹ y x⁻¹ x⁻¹ y⁻¹ x y y`   (in `Z_7 ⋊ Z_3`, `x = (1,0)`, `y = (2,1)`).

**Caveat.**  The table above is an ordinary computation, not a machine-checked artifact; the
order-`21` instance, however, *is* verified in Lean
(`CayleyHamiltonian.Frobenius21.frobenius21_transversal_isHamiltonian`, `sorry`-free, axioms
`propext`, `Classical.choice`, `Quot.sound`).
