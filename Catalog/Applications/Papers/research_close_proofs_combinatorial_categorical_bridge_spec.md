# Combinatorial Species as Functors and the Exponential Generating Function Bridge

## Abstract

We formalize a fragment of André Joyal's theory of *combinatorial species* together with
the classical correspondence to *analytic functors* and *exponential generating functions*
(EGFs). A species is modeled in skeletal form as a family of finite "structure types"
`F[n]`, one for each natural number `n`, equipped with a functorial action of the symmetric
group `Sₙ` realizing relabelling. To each species we associate its counting sequence
`n ↦ |F[n]|` and its exponential generating function `EGF(F) = ∑ₙ (|F[n]| / n!) Xⁿ`. The
core of the work is a ring-homomorphism dictionary between the algebra of species and the
ring of formal power series over the rationals: the EGF is additive over the disjoint-union
(sum) of species, and multiplicative over the structural Day-convolution product. The
product law rests on a cardinality identity — the number of structures of the product
species equals the *binomial convolution* of the counting sequences — together with the
elementary factorial identity `n! = C(n, i)·i!·j!` for `i + j = n`. We compute two
fundamental examples: the species of sets has EGF equal to the exponential power series
`exp`, and the species of linear orders has EGF equal to the geometric series `1/(1−X)`. All
results have been formally verified; this paper presents the mathematical content with
self-contained proof sketches.

**Keywords:** combinatorial species, exponential generating function, analytic functor,
binomial convolution, Day convolution, enumerative combinatorics, formal power series.

---

## 1. Introduction

Generating functions are the central computational tool of enumerative combinatorics. Given
a sequence `(aₙ)` counting some family of structures, one studies the analytic or formal
object that has `(aₙ)` as its coefficients. Two encodings dominate: the *ordinary*
generating function `∑ aₙ Xⁿ`, suited to *unlabelled* structures, and the *exponential*
generating function `∑ aₙ Xⁿ/n!`, suited to *labelled* structures. The recurring empirical
fact — that natural combinatorial operations correspond to natural algebraic operations on
generating functions — cried out for a structural explanation.

André Joyal supplied it in 1981 with the theory of *espèces de structures* (species of
structures). The key conceptual shift is to regard a combinatorial structure not as a mere
counting sequence but as a **functor** from the groupoid of finite sets and bijections to
the category of finite sets. Relabelling the underlying set induces a bijection of
structures, functorially. This functorial data is invisible to the counting sequence but is
exactly what makes the operations of *sum*, *product*, *substitution*, and *derivative* on
species correspond — provably and uniformly — to the corresponding operations on EGFs.

This paper formalizes the first rung of that correspondence: the **sum** and **product**
laws and the two foundational examples (sets and linear orders). We work in skeletal form,
fixing for each `n` the label set to be a fixed `n`-element set, and encoding functoriality
as a group action of the symmetric group `Sₙ`. The mathematical content is elementary but
the formalization pins down every coercion and cardinality count, providing a
machine-checked foundation on which the deeper laws (substitution / the Exponential Formula,
cycle-index series, λ-ring structure) can be built.

### Contributions

1. A formal definition of the exponential generating function `egf` of a counting sequence
   and of the binomial convolution `binConv`.
2. The **sum law** `egf_add` and the **product law** `egf_mul`, the latter establishing that
   `egf` carries binomial convolution to multiplication of power series.
3. A skeletal definition of `Species` as a finite structure family with a symmetric-group
   action, together with the species of sets and of linear orders.
4. The computations `EGF_setSpecies` (`= exp`) and `egf_linearOrderSpecies` (`= 1/(1−X)`).
5. The cardinality theorem `card_prodSpecies` for the structural (Day-convolution) product,
   and the resulting full bridge `egf_card_prodSpecies`.

---

## 2. Exponential generating functions of counting sequences

We work over the field of rationals `ℚ` and with the ring `ℚ⟦X⟧` of formal power series in
one indeterminate. For a power series `S` we write `[Xⁿ] S` for its coefficient of `Xⁿ`.

**Definition 2.1 (EGF).** For a counting sequence `a : ℕ → ℚ`, the *exponential generating
function* of `a` is the formal power series

```
egf(a) := ∑ₙ (aₙ / n!) Xⁿ ,   i.e.   [Xⁿ] egf(a) = aₙ / n! .
```

In the formalization this is `PowerSeries.mk (fun n => a n / n!)`, and the coefficient
formula `[Xⁿ] egf(a) = aₙ / n!` holds definitionally (`coeff_egf`).

**Definition 2.2 (Binomial convolution).** For sequences `a, b : ℕ → ℚ`, their *binomial*
(or *exponential*) *convolution* is

```
(a ⋆ b)ₙ := ∑_{i + j = n} C(n, i) · aᵢ · bⱼ ,
```

where the sum ranges over the antidiagonal `{(i, j) : i + j = n}` and `C(n, i)` is the
binomial coefficient. This is the sequence `binConv a b` in the formalization.

The binomial convolution is the counting sequence of the *product* of species (Section 5);
the two definitions above are precisely engineered so that the EGF intertwines them with the
ring operations of `ℚ⟦X⟧`.

---

## 3. The sum and product laws

### 3.1 Additivity

**Theorem 3.1 (Sum law, `egf_add`).** For all `a, b : ℕ → ℚ`,

```
egf(a + b) = egf(a) + egf(b),
```

where `(a + b)ₙ = aₙ + bₙ`.

*Proof.* Compare coefficients of `Xⁿ`. The left side is `(aₙ + bₙ)/n!`; the right side is
`aₙ/n! + bₙ/n!`. These are equal by distributivity of division over addition in `ℚ`. ∎

Combinatorially, this is the analytic shadow of the *disjoint union* (sum) of species: if a
structure is "an `F`-structure or a `G`-structure," the counts add termwise, hence the EGFs
add.

### 3.2 Multiplicativity — the combinatorial–analytic bridge

**Theorem 3.2 (Product law, `egf_mul`).** For all `a, b : ℕ → ℚ`,

```
egf(a ⋆ b) = egf(a) · egf(b).
```

Equivalently, `egf` is a ring homomorphism from `(ℕ → ℚ, +, ⋆)` to `ℚ⟦X⟧`.

*Proof.* Compare coefficients of `Xⁿ`. By the Cauchy-product formula for power series,

```
[Xⁿ] (egf(a) · egf(b)) = ∑_{i + j = n} ([Xⁱ] egf(a)) · ([Xʲ] egf(b))
                       = ∑_{i + j = n} (aᵢ / i!) · (bⱼ / j!).
```

On the other side,

```
[Xⁿ] egf(a ⋆ b) = (a ⋆ b)ₙ / n! = (1/n!) · ∑_{i + j = n} C(n, i) · aᵢ · bⱼ.
```

It suffices to show the two summands agree for each pair `(i, j)` with `i + j = n`. Using
`C(n, i) = n! / (i! · (n−i)!)` (and `j = n − i`),

```
(1/n!) · C(n, i) · aᵢ · bⱼ = (1/n!) · (n! / (i! j!)) · aᵢ · bⱼ = (aᵢ / i!) · (bⱼ / j!).
```

Summing over the antidiagonal yields the claim. In the formalization the decisive step is
`Nat.cast_choose`, expressing `C(n, i)` over `ℚ` as `n! / (i!·(n−i)!)`, after which
`field_simp` and `ring` close the goal. ∎

The product law is the heart of the bridge. The left-hand side is a purely combinatorial
operation (the binomial convolution, which we will see arises from splitting label sets in
all possible ways); the right-hand side is the ordinary product of formal power series. The
factorial denominators in the EGF are exactly calibrated so that the binomial weights on the
combinatorial side dissolve into multiplication on the analytic side. The single underlying
identity is `n! = C(n, i) · i! · j!` for `i + j = n`.

---

## 4. Two foundational examples

### 4.1 The species of sets and the exponential

**Theorem 4.1 (`egf_const_one`).** The EGF of the constant-one sequence equals the
exponential power series:

```
egf(fun n ↦ 1) = exp(ℚ),
```

where `exp(ℚ) = ∑ₙ Xⁿ/n!` is the formal exponential.

*Proof.* For every `n`, `[Xⁿ] egf(1) = 1/n!`, while `[Xⁿ] exp(ℚ) = 1/n!` by definition of
the exponential power series (the structure map `algebraMap ℚ ℚ` being the identity). The
coefficients coincide. ∎

This is the prototype dictionary entry: the *species of sets* `E`, which has exactly one
structure on every label set (the set itself), has counting sequence the constant `1` and
hence EGF `eˣ`.

### 4.2 The species of linear orders and the geometric series

**Theorem 4.2 (`egf_linearOrderSpecies`).** The EGF of the factorial sequence satisfies

```
(1 − X) · egf(fun n ↦ n!) = 1,
```

i.e. `egf(n!) = 1/(1−X)`, the geometric series.

*Proof.* Since `[Xⁿ] egf(n!) = n!/n! = 1`, the series `egf(n!)` is `∑ₙ Xⁿ`. Multiplying by
`(1 − X)` telescopes: the constant term is `1`, and for `n ≥ 1` the coefficient is
`1 − 1 = 0`. Hence the product is `1`. In the formalization one splits on `n = 0` versus
`n ≥ 1` and simplifies, using `Nat.factorial_ne_zero` to justify the division. ∎

Combinatorially, there are `n!` linear orders on `n` labels, so the *species of linear
orders* `L` has counting sequence `n!` and EGF `1/(1−X)`.

---

## 5. Species as functors and the structural product

### 5.1 The skeletal definition

**Definition 5.1 (Species).** A *combinatorial species* (skeletal form) consists of:

- a family `obj : ℕ → Type`, where `obj n` is the (finite) set of structures on a fixed
  `n`-element label set;
- a proof that each `obj n` is finite (`Fintype (obj n)`);
- for each `n`, a monoid homomorphism `act n : Equiv.Perm (Fin n) →* Equiv.Perm (obj n)`,
  the *relabelling action* of the symmetric group `Sₙ` on the structure set.

The `act` field encodes functoriality on the core groupoid of finite sets: it is the data
that makes a species more than a sequence of numbers. (For the EGF results of this paper the
action is not needed — the EGF sees only cardinalities — but it is the load-bearing
ingredient for cycle-index series and unlabelled enumeration; see Section 7.)

**Definition 5.2 (Counting sequence and EGF of a species).** For a species `F`,

```
coeffSeq(F)(n) := |F.obj n|   (the cardinality as a natural number),
EGF(F) := egf (fun n ↦ (coeffSeq(F)(n) : ℚ)).
```

**Definition 5.3 (Two species).**

- The **species of sets** `setSpecies`: `obj n = Unit` for every `n` (one structure per
  label set), with the trivial action. Its counting sequence is constant `1`
  (`coeffSeq_setSpecies`).
- The **species of linear orders** `linearOrderSpecies`: `obj n = Equiv.Perm (Fin n)` (a
  linear order on `n` labels is identified with a bijection to `Fin n`, of which there are
  `n!`), with the action by left translation. Its counting sequence is `n!`
  (`coeffSeq_linearOrderSpecies`, via `Fintype.card_perm`).

**Theorem 5.4 (`EGF_setSpecies`).** `EGF(setSpecies) = exp(ℚ)`.

*Proof.* The counting sequence of `setSpecies` is the constant `1`, so its EGF is
`egf(fun n ↦ 1)`, which equals `exp(ℚ)` by Theorem 4.1. ∎

### 5.2 The structural product (Day convolution)

**Definition 5.5 (Structural product).** For structure families `A, B : ℕ → Type` with
finite fibers, the *product species* on `n` labels is

```
(A · B)[n] := Σ_{S : Finset (Fin n)} A[|S|] × B[n − |S|],
```

the dependent sum over all subsets `S` of the `n` labels, placing an `A`-structure on `S`
and a `B`-structure on its complement. This is the *Day convolution* of the two species.

**Theorem 5.6 (Cardinality of the product, `card_prodSpecies`).**

```
|(A · B)[n]| = ∑_{i + j = n} C(n, i) · |A[i]| · |B[j]|.
```

*Proof.* By `Fintype.card_sigma` and `Fintype.card_prod`, the left side is

```
∑_{S ⊆ [n]} |A[|S|]| · |B[n − |S|]|,
```

a sum over all `2ⁿ` subsets. Group the subsets by their cardinality `k = |S|`: the number of
subsets of `[n]` of size `k` is `C(n, k)` (`Finset.card_powersetCard`). Hence the sum
collapses to

```
∑_{k=0}^{n} C(n, k) · |A[k]| · |B[n − k]|,
```

which, reindexed over the antidiagonal `{(i, j) : i + j = n}`, is the binomial convolution.
In the formalization this is the only step requiring real combinatorial work: one rewrites
the sum over `Finset (Fin n)` as a `biUnion` over cardinality classes, applies
`card_powersetCard`, and reindexes via `Finset.Nat.sum_antidiagonal_eq_sum_range_succ_mk`. ∎

**Theorem 5.7 (The bridge, `egf_card_prodSpecies`).** The EGF of the structural product of
two species is the product of their EGFs:

```
egf (fun n ↦ |(A · B)[n]|) = egf(fun n ↦ |A[n]|) · egf(fun n ↦ |B[n]|).
```

*Proof.* By Theorem 5.6 the counting sequence of the product species is the binomial
convolution `binConv (|A[·]|) (|B[·]|)`. Apply the product law (Theorem 3.2). ∎

This is the full combinatorial–analytic bridge for the product: the *structural* operation
on functors (Day convolution) and the *analytic* operation on power series (Cauchy product)
agree exactly, with the binomial convolution `card_prodSpecies` as the connecting tissue.

---

## 6. The dictionary

Collecting the results, the EGF defines a homomorphism from the algebra of species to
`ℚ⟦X⟧`:

| Species operation / object       | Power-series counterpart      | Theorem                  |
|----------------------------------|-------------------------------|--------------------------|
| disjoint union `F + G`           | `EGF(F) + EGF(G)`             | `egf_add` (3.1)          |
| structural product `F · G`       | `EGF(F) · EGF(G)`            | `egf_mul` / `card_prodSpecies` / `egf_card_prodSpecies` (3.2, 5.6, 5.7) |
| species of sets `E`              | `exp = eˣ`                    | `EGF_setSpecies` (5.4)   |
| species of linear orders `L`     | `1/(1−X)`                     | `egf_linearOrderSpecies` (4.2) |

Each row is a proven equivalence. The sum and product laws together state that the EGF is a
ring homomorphism `(ℕ → ℚ, +, ⋆) → ℚ⟦X⟧`, turning the combinatorics of building structures
into the arithmetic of power series.

---

## 6.5 Worked examples

We illustrate the dictionary on three concrete computations, each of which is a special case
of the theorems above and each of which can be checked numerically (see the accompanying
numerical demonstrations).

**Example 6.5.1 (Squaring the exponential).** Take `A = B = E`, the species of sets, with
counting sequence the constant `1`. The structural product `E · E` places a set structure on
a subset `S` and another on its complement — which amounts to *choosing the subset* `S`
itself. By Theorem 5.6 its count is `∑_{i+j=n} C(n,i)·1·1 = ∑ᵢ C(n,i) = 2ⁿ`. On the analytic
side, `EGF(E)·EGF(E) = exp · exp = exp(2X)`, whose `n`-th coefficient is `2ⁿ/n!`. Dividing
the count `2ⁿ` by `n!` matches exactly: the familiar law of exponents `eˣ·eˣ = e^{2X}` is, in
this light, the statement that `n` labels can be two-coloured in `2ⁿ` ways.

**Example 6.5.2 (Sets times linear orders).** Take `A = E` (sets, EGF `exp`) and `B = L`
(linear orders, EGF `1/(1−X)`). The product count is
`∑_{i+j=n} C(n,i)·1·j! = ∑_{i=0}^{n} C(n,i)·(n−i)! = ∑_{k=0}^{n} n!/k!` (substituting
`k = i`). On the analytic side, `EGF(E·L) = exp/(1−X)`, whose `n`-th coefficient is the
partial sum `∑_{k=0}^{n} 1/k!` — the truncations of the series for `e`. Multiplying by `n!`
recovers `∑_{k=0}^{n} n!/k!`, confirming Theorem 5.7. The integer counts are
`1, 2, 5, 16, 65, 326, 1957, …` — the number of *arrangements* (sequences of distinct
elements) drawn from an `n`-set, the OEIS sequence of "arrangement numbers."

**Example 6.5.3 (Squaring the geometric series).** Take `A = B = L`. The product count is
`∑_{i+j=n} C(n,i)·i!·j! = ∑_{i=0}^{n} n! = (n+1)·n!`. Dividing by `n!` gives `n+1`, matching
`1/(1−X)² = ∑ₙ (n+1)Xⁿ`. Combinatorially, an `(L·L)`-structure cuts the labels into an
ordered first block and an ordered second block; once the relative order of all `n` labels is
fixed (`n!` ways) the only remaining choice is *where* to cut, of which there are `n+1`
positions.

These examples show the dictionary is not merely formal: each algebraic identity among
generating functions decodes into a concrete counting statement, and conversely.

---

## 7. Applications

**Analysis of algorithms.** EGFs are the standard vehicle for average-case analysis (e.g.
the expected number of comparisons in quicksort, the height of random binary search trees).
The product and sum laws justify the symbolic-method calculus used throughout the field.

**The Exponential Formula.** The substitution law (a natural next step, see Section 8)
specializes to `EGF("sets of connected G-things") = exp(EGF(G))`. This single identity
simultaneously counts permutations by cycle type, labelled graphs by connected components,
and forests by trees.

**Statistical mechanics and chemistry.** Cluster expansions in statistical physics and the
enumeration of chemical isomers (Pólya theory) are both governed by species; the EGF handles
the labelled case and the cycle-index refinement (Section 7 below) handles the unlabelled,
symmetry-quotiented case.

**Random generation.** The recursive structure of species underlies "Boltzmann samplers"
for the uniform random generation of large combinatorial objects, used in software testing
and probabilistic combinatorics.

---

## 8. Discussion and future work

The present formalization establishes the additive and multiplicative laws and the two
canonical examples. Three natural extensions complete the theory.

**1. The substitution (composition) law.** Define the substitution
`(F ∘ G)[n] = Σ_{π ∈ Part(n)} F[π] × ∏_{B ∈ π} G[B]`, where `π` ranges over set partitions
of the `n` labels, and prove that its EGF is the plethystic composition `EGF(F) ∘ EGF(G)`
(requiring `G` to have zero constant term). Specializing `F = E` recovers the Exponential
Formula. The cardinality theorem `card_prodSpecies` already isolates the one hard step —
counting subsets by cardinality — and substitution iterates it over an entire set partition,
so `|(F ∘ G)[n]|` is a sum over partitions of multinomial coefficients times products of
`|G[·]|`, exactly the coefficient extraction in plethystic composition.

**2. Cycle-index series and unlabelled enumeration (Pólya theory).** Replace the EGF by the
*cycle-index series*
`Z_F = ∑ₙ (1/n!) ∑_{σ ∈ Sₙ} |Fix(F[σ])| · p₁^{c₁(σ)} p₂^{c₂(σ)} ⋯` in the ring of symmetric
functions, and prove `Z_{F+G} = Z_F + Z_G`, `Z_{F·G} = Z_F · Z_G`. Specializing
`pₖ ↦ xᵏ` yields the ordinary generating function counting *unlabelled* structures, while
`p₁ ↦ x, p_{k≥2} ↦ 0` recovers the EGF. Here the `act` field of the `Species` structure —
unused by the EGF theorems — becomes load-bearing: it is precisely the data the cycle index
needs.

**3. λ-ring / RingHom structure.** Package the entire dictionary as a single ring
homomorphism from a suitably defined semiring of species (with `+` and `·`) into `ℚ⟦X⟧`, and
ultimately exhibit the λ-ring structure that organizes derivatives, pointing, and the
combinatorial logarithm.

Each direction turns a currently-elementary fragment into a richer invariant and connects to
existing libraries (set partitions, symmetric functions, multivariate polynomials), moving
toward a complete, machine-checked theory of analytic functors.

---

## 9. Conclusion

We have given a self-contained, formally verified account of the foundational layer of
Joyal's bridge between combinatorial species and exponential generating functions: the EGF
is additive over species sum and multiplicative over the structural product, sends the
species of sets to `exp` and the species of linear orders to `1/(1−X)`. The mathematics is
classical, but the formalization fixes every cardinality count and coercion, yielding a
rigorous base on which the substitution law, cycle-index theory, and λ-ring structure can be
erected. The recurring moral is Joyal's: by remembering how a structure transforms under
relabelling — by treating it as a functor — the empirical magic of generating functions
becomes a theorem.

---

## References (classical, for orientation only — this paper is self-contained)

- A. Joyal, *Une théorie combinatoire des séries formelles*, Advances in Mathematics, 1981.
- F. Bergeron, G. Labelle, P. Leroux, *Combinatorial Species and Tree-like Structures*,
  Cambridge University Press, 1998.
- P. Flajolet, R. Sedgewick, *Analytic Combinatorics*, Cambridge University Press, 2009.
