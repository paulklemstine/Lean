# Computational evidence

All experiments below were run before the corresponding Lean formalization, on the
same finite objects that the theorems describe.  Every claim that survived the
experiments is now a machine-checked theorem in `Catalog/Combinatorics/`; the
experiments themselves are *not* proofs and are reported only as the evidence that
guided the statements.

---

## 1. Inclusion of finite-height tag-sensitive theories
(`Catalog/Combinatorics/DepthVectorInclusion.lean`)

Objects: height functions `c : tags → ℕ` on two tags, the tag-sensitive Kripke
semantics `satC c` (world `m` sees `n` iff `n < m` and `m ≤ c i`), and the theory
`capC c N` of formulas valid at the worlds `0, …, N`.

### 1a. Formula sweep (misleading, kept as a caution)

All 746 formulas of size ≤ 6 over two tags, for `N ≤ 3` and heights ≤ `N + 2`.
Comparing "inclusion of theories restricted to these formulas" with the level
agreement criterion produced 50 apparent mismatches, e.g. `N = 2`, `d = (0,1)`,
`d' = (1,2)`.  Hand analysis of that case produced the separating formula

```
□₀⊥ → (¬□₁⊥ → ¬□₁²⊥)          (13 nodes)
```

which is far outside the enumerated size range.  Conclusion: brute-force formula
sweeps of feasible size are *not* a reliable test here; the discriminators have the
nested "guard + depth probe" shape.

### 1b. Bisimulation sweep (decisive)

For two tags, `N = 0, 1, 2, 3, 4` and all heights ≤ `N + 2`, the greatest bisimulation
between the finite pointed models was computed by partition refinement (bisimilarity
= modal equivalence for these image-finite models), and inclusion of the theories was
read off as "every world of the small model is bisimilar to some world of the large
model".

| N | height range | pairs tested | mismatches with the level-agreement criterion |
|---|--------------|--------------|-----------------------------------------------|
| 0 | 0–2          | 81           | 0 |
| 1 | 0–3          | 256          | 0 |
| 2 | 0–4          | 625          | 0 |
| 3 | 0–5          | 1296         | 0 |
| 4 | 0–6          | 2401         | 0 |

This is the evidence for `capC_inclusion_iff`.

### 1c. The counterexample to the conjectured criterion

`N = 3`, `c = (1, 2, 1, 1, …)`, `c' = (2, 3, 2, 2, …)`, formula
`wit = □₁³⊥ → (¬□₁²⊥ → ¬□₀²⊥)`:

```
truth of wit at worlds 0,1,2,3 under c' : True  True  True  True     (provable)
truth of wit at worlds 0,1,2,3 under c  : True  True  False True     (refuted)
conjectured condition 1 (pointwise depth growth)  : True
conjectured condition 2 (order preservation)      : True
```

Formalized as `inclusion_criterion_conjecture_false`.

---

## 2. Box depth on the standard frame
(`Catalog/Combinatorics/BoxDepthReflection.lean`)

All 2074 formulas of size ≤ 7 and box depth ≤ 3 over two tags, evaluated at the worlds
`m ≤ 6` of the standard frame `(ℕ, <)`:

* violations of `sat m a = sat (min m (boxDepth a)) a` : **0**;
* smallest formula separating world `n-1` from world `n`:

  | n | separator | box depth |
  |---|-----------|-----------|
  | 1 | `□⊥`      | 1 |
  | 2 | `□□⊥`     | 2 |
  | 3 | `□□□⊥`    | 3 |

So the only obstruction to depth-`d` reflection at height `n` is the iterated boxed
falsum `□ⁿ⊥`, which is exactly what `capSysN_depthReflection_iff` says.

---

## 3. Reflection strength versus graph reachability
(`Catalog/Combinatorics/TransferReachability.lean`)

All 512 digraphs on three tags.  For each digraph `E` and each source `i`, the
two-world model `capC c 1` with `c t = 0` iff `t` is reachable from `i` was built and
checked:

* every axiom `□_s⊥ → □_t⊥` (`s → t` an edge) valid in the model: **512/512 digraphs,
  all sources**;
* the set of transfer implications valid in the model equals the reflexive–transitive
  closure of `E` at that source: **0 mismatches**.

This is the countermodel construction used in `reach_of_thm`.

---

## 4. Completeness of assumption-plus-ex-falso semantics
(`Catalog/Combinatorics/AssumptionCompleteness.lean`)

All satisfaction tables with `w ≤ 4` worlds and `n ≤ 4` observables — 74 954 tables.

| tested claim | violations |
|--------------|-----------|
| complete ⟺ some world satisfies all observables ("omni-world") | 0 |
| size of the smallest unrealizable consistent set = `min over worlds (#observables the world fails)` | **42 058** (false) |
| size of the smallest unrealizable consistent set = transversal number of the hypergraph of world-complements | 0 |

Observed sizes of minimal witnesses: every value `1, …, n` occurs, the value `n` being
attained by the "each world misses exactly one observable" table.  That table is the
family `missSem k` of the Lean file, and the two surviving claims are
`assumption_complete_iff`, `unrealizable_iff_transversal` and `missSem_helly`.

---

### Reproduction

The experiments are short self-contained scripts (formula enumeration, partition
refinement for bisimilarity, and exhaustive table enumeration) over the same finite
data described above; they use only the Python standard library.  Their role in this
project was hypothesis selection: everything asserted as a result is proved in Lean
without `sorry`.
