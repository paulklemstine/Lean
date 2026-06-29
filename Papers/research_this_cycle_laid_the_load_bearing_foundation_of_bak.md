# The Coset Foundation of Baker–Norine Divisor Theory on Finite Graphs

## Abstract

We develop, from first principles, the load-bearing algebraic foundation of
Baker–Norine divisor theory on a finite simple graph. Working over an arbitrary
finite vertex set, we define the space of divisors, the graph Laplacian
(chip-firing operator), the degree, genus, canonical divisor, and the
Brill–Noether number, and we establish the complete *homomorphism layer* of the
theory: the Laplacian `f ↦ lap G f` from firing patterns `V → ℤ` to divisors is
an additive, constant-killing map whose image lies in the degree-zero divisors.
From these five facts alone — and nothing else — we derive that chip-firing
(linear) equivalence is a genuine equivalence relation, that degree is a class
invariant, and that divisors of negative degree have empty linear systems (the
easy direction of graph Riemann–Roch, rank `−1`). The single genuinely
combinatorial theorem is a discrete maximum principle: on a *connected* graph the
kernel of the Laplacian is exactly the constant firing patterns. On the
numerical side we prove four identities governing the Brill–Noether number
`ρ(g,r,d) = g − (r+1)(g − d + r)` — Serre-duality invariance, the genus-zero
product formula, an exact unit-degree increment, and strict monotonicity in
degree — which together pin down the arithmetic that any full graph Riemann–Roch
theorem must satisfy. The structural thesis of this work is that the entire
algebraic layer of divisor theory is *the coset relation of a single
homomorphism*, and that conservation of chips is *pure antisymmetry of flow*
across an undirected edge.

**Keywords:** chip-firing, abelian sandpile, graph Laplacian, divisor theory,
Picard group, Jacobian of a graph, discrete maximum principle, Riemann–Roch,
Brill–Noether number, tropical geometry.

---

## 1. Introduction

Baker and Norine (2007) established a remarkable dictionary between the theory of
divisors on algebraic curves and a purely combinatorial game on finite graphs.
In their framework, an integer-valued function on the vertices of a graph plays
the role of a divisor; the graph Laplacian plays the role of "divisor of a
rational function"; linear equivalence becomes the relation of being reachable by
chip-firing moves; and the combinatorial genus `g = |E| − |V| + 1` plays the
role of the genus of a curve. Their central achievement is a graph-theoretic
Riemann–Roch theorem with an exact analogue of the classical statement, including
a canonical divisor of degree `2g − 2`.

The purpose of this paper is to isolate and prove rigorously the *foundational
layer* on which the whole theory rests, and to expose its surprisingly thin
logical skeleton. Our main structural observation is twofold:

1. **The algebraic theory is the coset relation of one homomorphism.** Once one
   knows that the Laplacian is additive (`lap_add`), kills constants
   (`lap_const`), respects negation (`lap_neg`), is silent on the zero pattern
   (`lap_zero`), and lands in degree zero (`lap_deg_zero`), the equivalence-
   relation structure of chip-firing, the invariance of degree, and the easy
   direction of Riemann–Roch follow *purely formally*. The three equivalence
   axioms are literally `lap_zero`, `lap_neg`, `lap_add`; degree invariance is
   literally `lap_deg_zero`.

2. **Conservation of chips is antisymmetry of flow.** The degree-zero property,
   often proved by a handshake/degree-counting argument, requires nothing of the
   sort. It is the antisymmetry of the local flow `f(v) − f(u)` under the
   symmetric adjacency relation: the involution `(v,u) ↦ (u,v)` on ordered
   adjacent pairs negates every summand while permuting the index set, forcing
   the total to equal its own negative.

The one place where genuine combinatorics — specifically, connectivity — is
unavoidable is the determination of the Laplacian kernel. We prove the discrete
maximum principle: on a connected graph the kernel is exactly the constants.

We close with the numerical layer: four exact identities for the Brill–Noether
number that any future rank/Riemann–Roch formula must respect.

All results in this paper have been formally verified.

---

## 2. Divisors, degree, and the algebraic operations

Throughout, `V` is a vertex type; for degree and Laplacian results we take `V`
finite, and `G : SimpleGraph V` a simple graph with decidable adjacency.

**Definition 2.1 (Divisor).** A *divisor* on `V` is a function
`D : V → ℤ`. We write `D.coeff v` for its value at `v`. Divisors form an
additive commutative group under pointwise operations:
`(D + E).coeff v = D.coeff v + E.coeff v`, `(−D).coeff v = − D.coeff v`, and
the zero divisor has `0.coeff v = 0`. Two divisors are equal iff their coefficient
functions agree (extensionality).

**Definition 2.2 (Effective divisor).** A divisor `D` is *effective*, written
`Effective D`, if `0 ≤ D.coeff v` for every vertex `v`.

**Definition 2.3 (Degree).** For finite `V`, the *degree* of a divisor is the
sum of its coefficients:
> `divisorDegree D = Σ_{v ∈ V} D.coeff v`.

Degree is a group homomorphism `Divisor V → ℤ`:

- `divisorDegree 0 = 0`;
- `divisorDegree (D + E) = divisorDegree D + divisorDegree E`;
- `divisorDegree (−D) = − divisorDegree D`.

Each follows from the corresponding linearity property of finite sums.

**Definition 2.4 (Single-vertex divisor).** For `v₀ : V` and `k : ℤ`, the
divisor `singleVertexDivisor v₀ k` places `k` chips on `v₀` and `0` elsewhere:
its coefficient at `w` is `k` if `w = v₀` and `0` otherwise.

---

## 3. The graph Laplacian and the homomorphism layer

**Definition 3.1 (Graph Laplacian / chip-firing operator).** For a firing
pattern `f : V → ℤ`, the *Laplacian* of `f` is the divisor
> `(lap G f).coeff v = Σ_{u ∈ N(v)} ( f(v) − f(u) )`,
where `N(v)` is the neighbour set of `v`. Interpreting `f(v)` as the number of
times vertex `v` fires, `lap G f` is the net change in chip counts produced by
firing every vertex `f(v)` times.

The following five facts constitute the entire homomorphism layer.

**Lemma 3.2 (`lap_zero`).** `lap G 0 = 0`.
*Proof.* Each summand is `0 − 0 = 0`. ∎

**Lemma 3.3 (`lap_const`).** For any constant `c : ℤ`, `lap G (fun _ ↦ c) = 0`.
*Proof.* Each summand is `c − c = 0`. This is the seed of the kernel
computation in §5. ∎

**Lemma 3.4 (`lap_add`, additivity).** For firing patterns `f, g`,
`lap G (f + g) = lap G f + lap G g`.
*Proof.* Coefficient-wise,
`(f+g)(v) − (f+g)(u) = (f(v) − f(u)) + (g(v) − g(u))`; split the sum. ∎

**Lemma 3.5 (`lap_neg`, negation).** `lap G (−f) = − lap G f`.
*Proof.* `lap` is `ℤ`-linear; each summand negates. ∎

**Theorem 3.6 (`lap_deg_zero`, conservation of chips).** For every firing
pattern `f`, `divisorDegree (lap G f) = 0`.

*Proof sketch.* Expand the degree as a double sum over ordered adjacent pairs:
> `Σ_{v} Σ_{u ∈ N(v)} ( f(v) − f(u) )`.
Reindex via the involution `σ(v,u) = (u,v)` on the set of ordered adjacent
pairs. Because adjacency is symmetric, `σ` is a bijection of the index set onto
itself, and it sends the summand `f(v) − f(u)` to `f(u) − f(v) = −(f(v) − f(u))`.
Hence the double sum equals its own negation, so it is `0`. No degree counting or
handshake lemma is needed; the result is the antisymmetry of flow across an
undirected edge. ∎

**Remark 3.7 (encoding discipline).** Two earlier encodings obscured this
argument: a weighted multigraph `V → V → ℤ` carrying explicit symmetry data, and
the "physicist's" form `deg(v)·f(v) − Σ_{u∈N(v)} f(u)`. Both hide the per-edge
antisymmetry that makes Theorem 3.6 immediate. The form
`Σ_{u∈N(v)}(f(v) − f(u))` is the one in which the involution argument is a single
reindexing.

---

## 4. Linear equivalence and the easy direction of Riemann–Roch

**Definition 4.1 (Linear / chip-firing equivalence).** Divisors `D` and `E` are
*linearly equivalent*, written `D ~ E`, if there is a firing pattern `f` with
> `E = D + lap G f`.

Equivalently, `E − D` lies in the image of the Laplacian.

**Theorem 4.2 (`linEquiv_equivalence`, `linSetoid`).** Linear equivalence is an
equivalence relation on `Divisor V`.

*Proof.* The three axioms are exactly the homomorphism facts:
- *Reflexivity*: `D = D + lap G 0` by Lemma 3.2.
- *Symmetry*: if `E = D + lap G f`, then `D = E + lap G (−f)` by Lemma 3.5,
  since `lap G (−f) = − lap G f`.
- *Transitivity*: if `E = D + lap G f` and `F = E + lap G g`, then
  `F = D + lap G (f + g)` by Lemma 3.4. ∎

We package this as a setoid `linSetoid G`, so the quotient
`Quotient (linSetoid G)` — the discrete **Picard group** — is a well-defined
type.

**Theorem 4.3 (`linEquiv_deg`, degree is an invariant).** If `D ~ E`, then
`divisorDegree D = divisorDegree E`.
*Proof.* From `E = D + lap G f`, additivity of degree gives
`divisorDegree E = divisorDegree D + divisorDegree (lap G f)`, and the second
term is `0` by Theorem 3.6. ∎

**Theorem 4.4 (`neg_deg_no_effective_equiv`, easy Riemann–Roch).** If
`divisorDegree D < 0`, then no divisor equivalent to `D` is effective.
*Proof.* An effective divisor has degree `≥ 0`, being a sum of non-negative
coefficients. By Theorem 4.3 every divisor equivalent to `D` has degree
`divisorDegree D < 0`, hence cannot be effective. ∎

In Baker–Norine language, Theorem 4.4 is precisely the statement that a divisor
of negative degree has **rank `−1`** (empty linear system) — the base case from
which the full rank function is built.

---

## 5. The discrete maximum principle: the Laplacian kernel

Facts 3.2–3.6 hold on *any* finite graph. The kernel computation, by contrast,
requires connectivity and is the one genuinely combinatorial theorem of the
foundation.

**Lemma 5.1 (`lap_max_principle`).** If `f` attains its maximum at `v` (i.e.
`f(u) ≤ f(v)` for all `u`), then `(lap G f).coeff v ≥ 0`.
*Proof.* Each summand `f(v) − f(u) ≥ 0`, so the sum is `≥ 0`. ∎

**Lemma 5.2 (`lapNeighborConst`, local equality case).** Suppose `lap G f = 0`
and `f` attains its global maximum at `v`. Then `f(u) = f(v)` for every neighbour
`u` of `v`.
*Proof.* Silence at `v` gives `Σ_{u∈N(v)} (f(v) − f(u)) = 0`. Each term is
`≥ 0` because `v` is a global maximum. A sum of non-negative terms equal to zero
forces every term to vanish: `f(v) − f(u) = 0` for each neighbour. ∎

**Lemma 5.3 (`reachClosed`).** Let `S ⊆ V` be closed under adjacency (if
`v ∈ S` and `u ∼ v` then `u ∈ S`). Then `S` is closed under reachability: if
`v ∈ S` and there is a walk from `v` to `w`, then `w ∈ S`.
*Proof.* Induction on the length of the walk, applying the adjacency-closure
hypothesis at each step. ∎

**Theorem 5.4 (`lap_kernel_const_of_connected`, `lap_kernel_iff_const`).** Let
`G` be a connected graph. Then `lap G f = 0` if and only if `f` is constant.

*Proof.* The backward direction is Lemma 3.3. For the forward direction, let
`m = max_v f(v)` (attained since `V` is finite), and let
`S = { v : f(v) = m }` be the maximal level set, which is nonempty. We claim `S`
is closed under adjacency. If `v ∈ S`, then `f` attains its global maximum at
`v`, so by Lemma 5.2 every neighbour `u` satisfies `f(u) = f(v) = m`, i.e.
`u ∈ S`. By Lemma 5.3, `S` is closed under reachability. Since `G` is connected,
every vertex is reachable from any fixed element of `S`, so `S = V`. Therefore
`f` is identically `m`, i.e. constant. ∎

**Remark 5.5 (where connectivity enters).** The entire dependence on
connectivity is the final step "every vertex is reachable from `S`." The
arithmetic content is the local equality case (Lemma 5.2); the propagation is the
purely set-theoretic closure argument (Lemma 5.3). This clean separation is the
methodological point of §5.

**Remark 5.6 (consequence: finiteness of the Jacobian).** Theorem 5.4 states
that on a connected graph the kernel of the Laplacian (over `ℤ`, and a fortiori
over `ℝ`) is one-dimensional — the constants. Equivalently, the image of the
Laplacian has finite index in the degree-zero divisors. This is exactly the
mechanism that forces the **Jacobian group** `Jac(G)` (the degree-zero part of
`Quotient (linSetoid G)`) to be finite, and connects to the matrix–tree theorem
`|Jac(G)| = #(spanning trees of G)`. The development of `Jac(G)` as a finite
abelian group is the natural next step built directly on Theorems 4.2, 4.3, and
5.4.

---

## 6. Genus, the canonical divisor, and the Brill–Noether number

**Definition 6.1 (Genus).** The *combinatorial genus* of `G` is the first Betti
number
> `genus G = |E(G)| − |V| + 1`.

**Definition 6.2 (Canonical divisor).** The *canonical divisor* `canonicalDivisor`
assigns to each vertex `deg(v) − 2`:
> `canonicalDivisor.coeff v = deg(v) − 2`.

By the handshake lemma `Σ_v deg(v) = 2|E|`, the canonical divisor has degree
`2|E| − 2|V| = 2g − 2`, the discrete analogue of the degree of the canonical
class on a curve of genus `g`.

**Definition 6.3 (Brill–Noether number).** For integers `g, r, d`,
> `bnNumber g r d = ρ(g,r,d) = g − (r + 1)(g − d + r)`.

In algebraic geometry, `ρ(g,r,d)` is the expected dimension of the variety
`W^r_d` of line bundles of degree `d` with at least `r+1` sections on a curve of
genus `g`; non-negativity of `ρ` is the threshold for generic existence.

We prove four exact identities.

**Theorem 6.4 (`bnNumber_serre_duality`).**
> `ρ(g, r, d) = ρ(g, g − 1 − d + r, 2g − 2 − d)`.

*Proof sketch.* Set `r' = g − 1 − d + r` and `d' = 2g − 2 − d`. Then
`g − d' + r' = g − (2g − 2 − d) + (g − 1 − d + r) = 1 + r`, so
`ρ(g, r', d') = g − (r' + 1)(g − d' + r') = g − (g − d + r)(1 + r) =
g − (r + 1)(g − d + r) = ρ(g, r, d)`. ∎

This is the numerical shadow of Serre duality: trading `D` for `K − D` (degree
`2g − 2 − d`, rank shifted by Riemann–Roch) leaves the Brill–Noether obstruction
unchanged.

**Theorem 6.5 (`bnNumber_genus_zero`).**
> `ρ(0, r, d) = (r + 1)(d − r)`.

*Proof.* `ρ(0,r,d) = 0 − (r+1)(0 − d + r) = −(r+1)(r − d) = (r+1)(d − r)`. ∎

**Theorem 6.6 (`bnNumber_succ_d`, unit increment).**
> `ρ(g, r, d + 1) = ρ(g, r, d) + (r + 1)`.

*Proof.* `ρ(g,r,d+1) = g − (r+1)(g − d − 1 + r) = g − (r+1)(g − d + r) + (r+1) =
ρ(g,r,d) + (r+1)`. ∎

**Theorem 6.7 (`bnNumber_strict_mono_d`).** For `r ≥ 0`, the map
`d ↦ ρ(g, r, d)` is strictly increasing.
*Proof.* Immediate from Theorem 6.6: each unit step adds `r + 1 ≥ 1 > 0`. ∎

The increment `r + 1` is precisely the predicted jump in the dimension of the
linear system when one adds a chip, and so Theorem 6.6 pins the numerical target
that a full graph Riemann–Roch rank function must hit.

---

## 7. Algorithms

The foundation is constructive; the following procedures are implied directly by
the definitions and theorems above and are realized in the accompanying demo.

**Algorithm 7.1 (Fire a vertex / apply the Laplacian).** Given a firing pattern
`f` and the graph, compute `lap G f` by summing `f(v) − f(u)` over neighbours `u`
of each `v`. Complexity `O(|V| + |E|)` per evaluation. This is the engine for all
chip movement.

**Algorithm 7.2 (Degree and effectivity checks).** Compute `divisorDegree D` by
summing coefficients (`O(|V|)`); check `Effective D` by testing non-negativity of
all coefficients (`O(|V|)`). Together with Theorem 4.4 these give an immediate
`O(|V|)` certificate of "no effective representative" whenever `deg D < 0`.

**Algorithm 7.3 (Kernel test via the maximum principle).** To test whether a
firing pattern is silent on a connected graph, Theorem 5.4 reduces the question
to "is `f` constant?", an `O(|V|)` check. Conversely, to find the level-set
propagation explicitly, perform a breadth-first flood from the argmax, adding a
neighbour whenever it ties the running maximum; on a silent pattern over a
connected graph the flood fills the whole graph (`O(|V| + |E|)`).

**Algorithm 7.4 (Brill–Noether tabulation).** Evaluate `ρ(g, r, d)` directly,
and use the recurrence `ρ(g, r, d+1) = ρ(g, r, d) + (r+1)` (Theorem 6.6) to
tabulate a degree row in `O(1)` per entry, with Serre duality (Theorem 6.4) as a
free correctness cross-check.

---

## 8. Applications and discussion

**The Picard and Jacobian groups.** Theorem 4.2 makes
`Pic(G) = Quotient (linSetoid G)` a well-defined type and, via the descent of
pointwise addition through additivity of `lap`, an abelian group. Theorem 4.3
shows degree descends to a homomorphism `Pic(G) → ℤ`; its kernel is the Jacobian
`Jac(G)`. Theorem 5.4 supplies the finiteness mechanism (Remark 5.6), opening the
matrix–tree theorem `|Jac(G)| = #(spanning trees)` and a computable model of the
abelian sandpile group.

**Toward full Riemann–Roch.** Theorem 4.4 is the base case `rank = −1` for
`deg < 0`, and Theorem 6.6 encodes the exact `+(r+1)` increment that rank should
exhibit, so the numerical target `rank D − rank(K − D) = deg D − g + 1` is pinned
down before the combinatorics begin. The two missing ingredients are (i) unique
`q`-reduced representatives via Dhar's burning algorithm — whose uniqueness is the
equality case of the maximum principle (Lemma 5.2) — and (ii) a Dhar duality
between `D` and `K − D`.

**Tropical specialization.** Baker's specialization lemma shows divisor rank can
only increase under specialization from a curve to its dual graph, so a
combinatorial obstruction lifts to a geometric one. Theorem 6.4 (Serre duality of
`ρ`) is exactly the numerical invariant any specialization must respect; hence the
liftability obstruction `ρ(g,r,d) ≥ 0` can be tested entirely tropically.

**Physical interpretation.** The chip-firing operator is the discrete Laplacian
governing the abelian sandpile model. Theorem 5.4 is the statement that a
connected sandpile has a one-dimensional harmonic space (the constants), the
discrete maximum principle underlying both relaxation dynamics and the
electrical-network analogy `lap` ↔ Kirchhoff matrix.

---

## 9. Future work

A detailed program of five research directions — finiteness of the graph
Jacobian, Dhar's burning algorithm and unique `q`-reduced representatives, the
full Baker–Norine Riemann–Roch theorem, a quantitative maximum principle and
spectral gap, and specialization-invariance of the Brill–Noether obstruction —
is recorded alongside this paper. Each is engineered to build directly on the
theorems established here, with the discrete maximum principle (Theorem 5.4) and
the Serre-duality identity (Theorem 6.4) as the structural load-bearing inputs.

---

## 10. Conclusion

The algebraic theory of divisors on a finite graph is, at bottom, the coset
relation of a single additive, degree-zero, constant-killing homomorphism — the
graph Laplacian. Its equivalence-relation structure, its degree invariant, and
the easy direction of Riemann–Roch are formal consequences of five elementary
facts; conservation of chips is nothing more than antisymmetry of flow across an
undirected edge. The one combinatorial input, connectivity, enters at a single
identifiable step in the discrete maximum principle, which characterizes the
Laplacian kernel as the constants and supplies the finiteness mechanism for the
Jacobian. On the numerical side, four exact Brill–Noether identities fix the
arithmetic skeleton of the full theory. Together these results form a thin,
rigorously verified foundation on which the complete Baker–Norine Riemann–Roch
theory, and its tropical applications, can be erected.

---

## References

- M. Baker and S. Norine, *Riemann–Roch and Abel–Jacobi theory on a finite
  graph*, Advances in Mathematics, 2007.
- M. Baker, *Specialization of linear systems from curves to graphs*, Algebra &
  Number Theory, 2008.
- D. Dhar, *Self-organized critical state of sandpile automaton models*, Physical
  Review Letters, 1990.
