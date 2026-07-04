# Computational Evidence: Bipartite Partial Duals via All-Crossing Directions

This note records the small-case evidence gathered before formalizing the GF(2)
characterization of bipartite partial duals of orientable hypermaps.

## 1. Model and small-case calculations

We model the medial interlacement of a hypermap on hyperedge set `E` by a symmetric
`GF(2)` form `J : E → E → 𝔽₂`, and assemble the local "all strands cross" constraints into
the operator `crossOp(x)_e = Σ_{e'} J_{e e'} x_{e'}`.

* **All-crossing directions** = solutions of `crossOp Φ = 0`  (kernel of `crossOp`).
* **Bipartite partial duals** (fixing a reference twist `t`) = `{A : crossOp A = crossOp t}`
  = the coset `t + ker(crossOp)`.
* **Crossing set map** `C(Φ) = Φ + t`.

### Worked example (`Examples.lean`, `E = Fin 2`, `J ≡ 1`, `t = (1,0)`)

Here `crossOp x = (x₀ + x₁, x₀ + x₁)`.

| direction `x` | `crossOp x` | all-crossing? | bipartite dual? |
|---------------|-------------|---------------|-----------------|
| (0,0)         | (0,0)       | yes           | no              |
| (1,1)         | (0,0)       | yes           | no              |
| (1,0)         | (1,1)       | no            | yes             |
| (0,1)         | (1,1)       | no            | yes             |

* All-crossing directions: `{(0,0), (1,1)}` — a 1-dimensional kernel, **2** elements.
* Bipartite partial duals: `{(1,0), (0,1)}` — the coset `t + ker`, **2** elements.
* `C` maps `(0,0) ↦ (1,0)` and `(1,1) ↦ (0,1)`: a bijection onto the bipartite duals.

This confirms `#bipartite duals = #all-crossing directions = 2^{dim ker}` in a case where
the count is a nontrivial `2`, not `1`. These memberships are all machine-checked by
decision procedures in `Examples.lean`.

## 2. Parity dichotomy for a single hyperedge

An all-crossing direction around a hyperedge of length `ℓ` is a proper 2-colouring of its
boundary cycle `C_ℓ`. Small cases:

| `ℓ` | `C_ℓ` 2-colourable? | even? |
|-----|---------------------|-------|
| 3   | no  (χ = 3)          | no    |
| 4   | yes (χ = 2)          | yes   |
| 5   | no  (χ = 3)          | no    |
| 6   | yes (χ = 2)          | yes   |

Perfect agreement `2`-colourable ⇔ even — matching `allCrossingLocal_iff_even`.
Checked concretely for `ℓ = 3` (fails) and `ℓ = 4` (succeeds) in `Examples.lean`.

## 3. Counterexample hunt

* The universal claim "an all-crossing direction exists ⇔ all hyperedges even" survives
  every odd-length probe: any odd hyperedge forces boundary chromatic number `3`, killing
  2-colourability. No counterexample found; the odd case is exactly the obstruction.
* The characterization "bipartite dual ⇔ `A = C(Φ)` for an all-crossing `Φ`" survives
  because both families are cosets of the *same* subspace `ker(crossOp)`, so translation by
  the fixed reference twist is a bijection. No counterexample found.

## 4. Sequence note

The cardinality `#bipartite duals = 2^{dim ker(crossOp)}` is a power of two; over the family
of `E`-indexed data these counts range over `{1, 2, 4, 8, …}`, i.e. the powers of two
(OEIS A000079), reflecting the affine-subspace structure. This is a structural observation,
not an OEIS lookup match to the topic itself.

All numerical claims above are backed by machine-checked statements in the accompanying
Lean files.
