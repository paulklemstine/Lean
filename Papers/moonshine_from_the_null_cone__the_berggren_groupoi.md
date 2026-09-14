# Computational evidence — Moonshine from the null cone (Phase A, cycle v19c)

All numerical claims below were subsequently **re-proved in Lean** in
`Catalog/MachineLearning/BerggrenLorentzReflections.lean`,
`Catalog/MachineLearning/BerggrenEvenLatticeEmbedding.lean`,
`Catalog/MachineLearning/BerggrenNiemeierMoonshine.lean` and
`Catalog/MachineLearning/BerggrenHolyConstruction.lean`.
The exploratory computations here are *not* the verification; the Lean files are.

## 1. The Berggren generators are unit-reflection words

With `⟨v,w⟩ = v₁w₁ + v₂w₂ − v₃w₃` and `s_r(x) = x − 2⟨x,r⟩r`:

| vector `r`   | `⟨r,r⟩` |
|--------------|---------|
| `(1,0,0)`    | 1 |
| `(0,1,0)`    | 1 |
| `(1,−1,−1)`  | 1 |
| `(1,1,−1)`   | 1 |
| `(−1,1,−1)`  | 1 |

Random-vector checks (and then a Lean proof) give

```
mA = s_(1,0,0) ∘ s_(1,−1,−1)                    det = +1  (2 reflections)
mC = s_(0,1,0) ∘ s_(−1,1,−1)                    det = +1  (2 reflections)
mB = s_(1,0,0) ∘ s_(0,1,0) ∘ s_(1,1,−1)         det = −1  (3 reflections)
```

Every reflection vector has **odd** norm 1.  Since an even lattice (such as `II(25,1)`)
has no odd-norm vectors, the literal embedding of `(ℤ³, a²+b²−c²)` into `II(25,1)` is
impossible — this is the parity obstruction proved as
`BerggrenStars.no_isometry_into_even_lattice`.  Rescaling the form by `2` turns these five
unit vectors into norm-`2` **roots**, the same species that generates reflection groups of
even Lorentzian lattices.

## 2. Ternary branching vs. the hole structure of the Leech lattice

Level counts of the free ternary Berggren tree, and ball sizes:

| depth `n` | nodes at depth `n` = `3ⁿ` | nodes at depth `≤ n` |
|---|---|---|
| 0 | 1 | 1 |
| 1 | 3 | 4 |
| 2 | 9 | 13 |
| 3 | 27 | 40 |
| 4 | 81 | 121 |
| 5 | 243 | 364 |

Neither sequence contains `23` (deep-hole classes of the Leech lattice) nor `24`
(Niemeier lattices).  Both sequences skip those values permanently, since `3ⁿ` is odd and
never divisible by 23, and the ball sizes jump `13 → 40`.

## 3. Which integers are Berggren hypotenuses?

Enumerating the tree to depth 5 (`364` nodes) and sorting hypotenuses:

```
5, 13, 17, 25, 29, 37, 41, 53, 61, 65, 73, 85, 89, 97, 101, 109, 125, 137, 145,
149, 157, 169, 173, 185, 193, 205, 221, 229, 233, 241, …
```

* every value is `≡ 1 (mod 4)`  — **no counterexample found**;
* no value has a prime factor `≡ 3 (mod 4)` — **no counterexample found**.

Both observations are theorems: `node_hyp_emod_four` and
`node_hyp_not_dvd_prime_three_mod_four`.  The sequence of primitive hypotenuses is
A008846 in spirit (hypotenuses of primitive Pythagorean triples).

### Counterexample hunt against moonshine numerics

We tested whether the head data of the McKay–Thompson series can be Berggren
hypotenuses.  Factorisations:

| quantity | value | `mod 4` | factorisation | prime `≡ 3 (4)` |
|---|---|---|---|---|
| `j` coefficient `c(1)` | 196884 | 0 | `2²·3³·1823` | 3 |
| Monster head dim | 196883 | 3 | `47·59·71` | 47 |
| `j` coefficient `c(2)` | 21493760 | 0 | `2¹¹·5·2099` | 2099 |
| Monster dim 2 | 21296876 | 0 | `2²·31·41·59·71` | 31 |
| deep holes | 23 | 3 | `23` | 23 |
| Niemeier lattices | 24 | 0 | `2³·3` | 3 |

Every one of them is divisible by a prime `≡ 3 (mod 4)`, hence **none** is a Berggren
hypotenuse.  (A near miss in the other direction: `196885 = 5 · 13² · 233`, all primes
`≡ 1 (mod 4)`, *is* a hypotenuse.)

## 4. The holy construction at a node

For the root `ρ = (3,4,5)` (isotropic) and `τ = (2,1,2)`:

```
⟨τ, ρ⟩ = 6 + 4 − 10 = 0        ⟨τ, τ⟩ = 4 + 1 − 4 = 1
ρ = 1·ρ + 0·τ                   τ = 0·ρ + 1·τ
det of the change of basis from the naive basis {(4,−3,0), (−1,2,1)} of ρ^⊥ is −1
```

so `{ρ, τ}` is a unimodular basis of `ρ^⊥` and the quotient `ρ^⊥/ℤρ` carries the form
`y ↦ y²`: the rank-one unimodular lattice, i.e. `A₁ = ⟨2⟩` after the even rescaling.
Conway's holy construction in `II(25,1)` instead produces the rank-24 **rootless** Leech
lattice.  This is the sharpest available statement of what the Berggren tree does and does
not share with moonshine.
