# Computational evidence: the extremal collision probability of a 2-universal family

Setting.  A family of hash functions `h : Ω → K → V` indexed by a finite
probability space `(Ω, L)`, with `m = |V|` buckets and a key set `S` of size
`n ≥ 2`.  Write

```
Coll  = { ω : two distinct keys of S collide under h ω }
X(ω)  = number of ordered pairs of distinct keys of S colliding under h ω
```

Two universality axioms:

* **CW** (Carter–Wegman, inequality only): `P(h x = h y) ≤ 1/m` for `x ≠ y ∈ S`;
* **EX** (exact / pairwise independent): `P(h x = h y) = 1/m` for `x ≠ y ∈ S`.

The union bound gives `P(Coll) ≤ C(n,2)/m`.  The question addressed here is the
converse: *how small can `P(Coll)` be, over all families satisfying the axiom?*

---

## 1. Small-case calculations: the affine family over `ZMod p`

For `h_{a,b}(x) = a x + b` over `ZMod p` (uniform over the `p²` pairs `(a,b)`),
two distinct keys collide iff `a = 0`, and *some* pair of `n ≥ 2` distinct keys
collides iff `a = 0`.  Hence the number of colliding indices is `p` out of `p²`.

| `p` | colliding indices | total indices | `P(Coll)` | union bound `C(p,2)/p` |
|-----|-------------------|---------------|-----------|------------------------|
| 2   | 2                 | 4             | 0.5       | 0.5                    |
| 3   | 3                 | 9             | 0.333…    | 1.0                    |
| 5   | 5                 | 25            | 0.2       | 2.0                    |
| 7   | 7                 | 49            | 0.142857… | 3.0                    |
| 11  | 11                | 121           | 0.0909…   | 5.0                    |
| 13  | 13                | 169           | 0.0769…   | 6.0                    |

The counts in rows `p = 2,3,5,7` are kernel-checked by `decide` in
`Catalog/Pythagorean/UnionBoundConverse/Evidence.lean`
(`affine_collision_count_two/three/five/seven`); the probabilities are theorems
(`affine_collisionProb_two/three/five/seven`), not floating-point evaluations.

Observation: `P(Coll) = 1/p` *exactly*, and it does **not** depend on how many
keys are hashed (2 keys or all `p` keys give the same number), whereas the
union bound grows like `n²/2p` and becomes vacuous already for `n ≳ √p`.

---

## 2. Counterexample hunt against a stronger conjecture

Conjecture tested and **refuted**: "for every CW 2-universal family,
`P(Coll) ≥ 1/m`".

Counterexample: the deterministic one-element family consisting of a single
function injective on `S` (possible whenever `n ≤ m`).  It satisfies
`P(h x = h y) = 0 ≤ 1/m` and `P(Coll) = 0`.  Formalised as
`exists_injective_sub2Universal`.  Consequently the `1/m` bound requires
*exactness* (equivalently, pairwise independence), which is what the main
theorem assumes.

Conjecture tested and **refuted**: "the extremal value decreases with the
number of keys".  Refuted by the affine family: for `p = 7` the value is `1/7`
both for 2 keys and for all 7 keys (`extremal_value_key_independent`).

---

## 3. Exhaustive optimisation over all exactly 2-universal families (small `n`, `m`)

For a key set of size `n` and `m` buckets, an exactly 2-universal family is
*exactly* a probability vector `w` on the `mⁿ` functions `[n] → [m]` with

```
∑_f w_f = 1 ,      ∑_{f : f(x)=f(y)} w_f = 1/m   for each of the C(n,2) pairs.
```

Minimising `∑_{f not injective} w_f` is therefore a small linear program.  All
basic feasible solutions were enumerated exactly (rational arithmetic, vertex
enumeration over the `1 + C(n,2)` active constraints).  This is an exploratory
computation, not a Lean-checked one.

| `n` | `m` | LP optimum (exact) | `1/m` | union bound `C(n,2)/m` |
|-----|-----|--------------------|-------|------------------------|
| 2   | 2   | 1/2                | 1/2   | 1/2                    |
| 3   | 2   | 1                  | 1/2   | 3/2                    |
| 4   | 2   | 1                  | 1/2   | 3                      |
| 2   | 3   | 1/3                | 1/3   | 1/3                    |
| 3   | 3   | 1/3                | 1/3   | 1                      |
| 2   | 4   | 1/4                | 1/4   | 1/4                    |
| 3   | 4   | 1/4                | 1/4   | 3/4                    |

---

## 4. The conjectured value, to the digit

Reading off Section 3 and Section 1:

```
   min over exactly 2-universal families of P(Coll)  =  1/m      for 2 ≤ n ≤ m
                                                     =  1        for n > m
```

Numerically, for the cases computed:

| `(n, m)` | LP optimum | conjectured `1/m` | agreement |
|----------|-----------|-------------------|-----------|
| (2, 2)   | 0.500000  | 0.500000          | exact     |
| (2, 3)   | 0.333333  | 0.333333          | exact     |
| (3, 3)   | 0.333333  | 0.333333          | exact     |
| (2, 4)   | 0.250000  | 0.250000          | exact     |
| (3, 4)   | 0.250000  | 0.250000          | exact     |
| (3, 2)   | 1.000000  | 1 (pigeonhole)    | exact     |
| (4, 2)   | 1.000000  | 1 (pigeonhole)    | exact     |

Every optimum sits on `1/m` to the last digit, with the pigeonhole regime
`n > m` degenerating to `1`.  This is the conjecture that the Lean development
proves:

* lower bound for all families: `inv_card_le_collisionProb` (reverse Markov
  applied to the collision counter `X`, using `E[X] = n(n-1)/m` and
  `X ≤ n(n-1)`);
* attainment: `affine_collisionProb`, `affineVia_collisionProb` (prime bucket
  counts) and `mix_collisionProb` (arbitrary bucket counts, via the
  bijection–constant mixture);
* both regimes together: `extremal_collision_value` and its prime-free version
  `extremal_collision_value_general`.

### Lab notes

* The first formulation attempted was `P(Coll) ≥ 1/m` under the Carter–Wegman
  inequality axiom.  Relaxing the LP's equality constraints to inequalities
  admits the explicit feasible point "unit mass on one injective map", of
  objective value `0`, which forced the switch to the exact axiom; the
  refutation is now the theorem `exists_injective_sub2Universal`.
* The second surprise was the `n`-independence: the LP optima for `(2,3)` and
  `(3,3)` are both `1/3`, and for `(2,4)` and `(3,4)` both `1/4`.  This ruled
  out any conjecture of the form `c(n)/m` with `c` increasing, and pointed
  directly at the reverse Markov proof, whose ratio `E[X]/max X` is manifestly
  independent of `n`.
* Vertex enumeration cost: `(3,4)` required solving `C(64,4) = 635 376`
  rational `4 × 4` systems; `(3,5)` would need `C(125,4) ≈ 10^7` systems and was
  not attempted.

---

## 5. Sequence data

The quantities appearing are `p` (colliding indices of the affine family over
`ZMod p`, i.e. A000040 read as the primes themselves) and `p²` (A001248); the
optimal probabilities form the sequence `1/m`, whose numerators are constant.
No nontrivial new integer sequence arises, so no OEIS entry is claimed.

---

## 6. What the numerics do *not* show

The LP enumeration only covers `n, m ≤ 4`, and vertex enumeration scales as
`C(mⁿ, 1 + C(n,2))`, so it cannot be pushed much further.  The general
statement is therefore proved rather than computed; the numerics served to fix
the correct constant (`1/m`, not `C(n,2)/m` and not `0`) and to detect that the
inequality-only Carter–Wegman axiom admits value `0`, which changed the
formulation of the main theorem.
