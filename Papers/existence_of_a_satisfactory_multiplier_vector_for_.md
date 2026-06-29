# Computational Evidence — Satisfactory Multipliers for 2D Lacunary Distance Graphs

Notation: `‖x‖_𝕋 = torusNorm x = |x - round x|` is the distance from `x` to the
nearest integer (`0 ≤ ‖x‖_𝕋 ≤ 1/2`).  For a displacement set `D` we seek a
multiplier `α` with `inf_{d∈D} ‖⟪d, α⟫‖_𝕋 ≥ δ > 0`.

## 1. The geometric residue pattern (engine of the existence theorem)

Because `q ≡ -1 (mod q+1)`, the residues `q^k mod (q+1)` alternate `1, q, 1, q, …`.
Both residues sit at distance `1/(q+1)` from an integer, so with `α = 1/(q+1)`:

```
q = 2  (modulus 3):  q^k mod 3      = 1, 2, 1, 2, 1, 2, ...
                     ‖q^k/3‖_𝕋      = 1/3 for every k          (δ = 1/3)
q = 3  (modulus 4):  q^k mod 4      = 1, 3, 1, 3, 1, 3, ...
                     ‖q^k/4‖_𝕋      = 1/4 for every k          (δ = 1/4)
q = 4  (modulus 5):  q^k mod 5      = 1, 4, 1, 4, 1, 4, ...
                     ‖q^k/5‖_𝕋      = 1/5 for every k          (δ = 1/5)
```

These were checked in Lean with `#eval (List.range 6).map (fun k => 3^k % 4)`
giving `[1, 3, 1, 3, 1, 3]`, and similarly for `q = 2`.  The pattern is the
content of `geom_residue_min` and the exact identity `geometric_torusNorm_eq`.

Conclusion: a *single rational* multiplier `α = 1/(q+1)` handles the entire
infinite geometric sequence **exactly**, with `δ = 1/(q+1)`.  No nested-interval
or limiting construction is required.

## 2. Two-dimensional interleaved set

`D = {(q^k, 0)} ∪ {(0, q^k)}`, multiplier `α = (1/(q+1), 1/(q+1))`:

```
d = (q^k, 0):  ⟪d, α⟫ = q^k/(q+1)   →  ‖·‖_𝕋 = 1/(q+1)
d = (0, q^k):  ⟪d, α⟫ = q^k/(q+1)   →  ‖·‖_𝕋 = 1/(q+1)
```

Both coordinates of `α` are essential: setting `α₂ = 0` fails on every `(0,q^k)`
(inner product `0`, torus norm `0`).  This is the content of
`exists_geometric_multiplier_2D` and certifies that the result is genuinely
two-dimensional, not a disguised 1-D statement.

## 3. Counterexample hunt — when does NO multiplier exist?

We tested the *non-lacunary* extreme `D = {1, 2, 3, …}` (all positive integers).

* `α` rational `= p/q`:  `‖q·α‖_𝕋 = ‖p‖_𝕋 = 0`, so `δ = 0`.
* `α` irrational:  the orbit `{n·α mod 1}` is equidistributed; for every `N`
  Dirichlet gives some `1 ≤ n ≤ N` with `‖n·α‖_𝕋 ≤ 1/(N+1) → 0`.

So `inf_n ‖n·α‖_𝕋 = 0` for **every** real `α`: the full integer sequence admits
**no** satisfactory multiplier.  This is `full_integer_sequence_no_multiplier`
and shows the positive `δ` of §1 is a genuine dividend of lacunarity.

## 4. OEIS note

The residue cycle `1, q, 1, q, …` (period 2) of `q^k mod (q+1)` is the order-2
behaviour of `-1` modulo `q+1`; no nontrivial OEIS sequence is involved (the
torus-norm sequence is the constant `1/(q+1)`).

## 5. Summary table

| Displacement set `D`            | best `α`              | `δ`        | status            |
|---------------------------------|-----------------------|------------|-------------------|
| `{q^k}` (1-D geometric)         | `1/(q+1)`             | `1/(q+1)`  | proved (exact)    |
| `{(q^k,0)} ∪ {(0,q^k)}` (2-D)   | `(1/(q+1),1/(q+1))`   | `1/(q+1)`  | proved (exact)    |
| `{1,2,3,…}` (all integers)      | none                  | `0`        | proved impossible |
