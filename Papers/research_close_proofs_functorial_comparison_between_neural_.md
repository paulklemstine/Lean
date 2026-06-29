# A Functorial Comparison of Neural Observation Pseudometrics and Proof Spectra

## Abstract

We develop a precise correspondence between three a priori different notions of
behavioral indistinguishability for state machines whose states and outputs
carry semiring structure: (i) the **analytic** notion, a state pseudometric
whose zero locus records indistinguishability; (ii) the **coalgebraic** notion,
the Myhill–Nerode behavioral equivalence of an observation system; and (iii) the
**algebraic-geometric** notion, a semiring congruence regarded as a datum of a
proof spectrum. Our central structural observation is that, for *algebraic
neural observation systems* — systems whose layers and read-out are semiring
homomorphisms preserving `0`, `+`, `*` — the behavior map is a homomorphism in
the state argument, and consequently behavioral equivalence is automatically a
semiring congruence. We prove a comparison theorem identifying all three notions
on the nose, and we promote the construction to a **functor**: morphisms that
intertwine the dynamics push congruences forward, identities go to identities,
and composition is respected. Finally we show that the observation pseudometric,
which is `{0,1}`-valued and only a pseudometric on raw states, descends to a
genuine **metric** on the behavioral quotient, with full separation. We close
with applications to certified neural compression and a program of open
conjectures connecting primality, Zariski transport, and graded ultrametric
refinements.

**Keywords.** behavioral equivalence, Myhill–Nerode, semiring congruence, proof
spectrum, pseudometric, functor, neural state compression, coalgebra.

---

## 1. Introduction

Behavioral indistinguishability — the inability of any experiment to separate
two internal states — is a load-bearing concept across automata theory,
coalgebra, concurrency, cryptography, and the semantics of learned models. It
underlies state minimization, the meaning of cryptographic indistinguishability,
and the modern view of "compression" as quotienting by what cannot be observed.

This paper studies behavioral equivalence for a class of machines that carry
*algebraic* structure on both their state space and their output space, and it
relates three independently natural formalizations:

1. **Metric.** An observation pseudometric `obsDist` whose kernel
   `{(x,y) : obsDist(x,y)=0}` records indistinguishability.
2. **Coalgebraic.** The Myhill–Nerode behavioral equivalence `≈` of an
   observation system: agreement of read-outs across all input contexts.
3. **Algebraic-geometric.** A semiring congruence in the sense of
   proof-theoretic algebraic geometry, i.e. a point datum of a proof spectrum.

The contribution is to show these three are not merely analogous but *equal*,
that the correspondence is functorial in the systems, and that the pseudometric
matures into an honest metric on the behavioral quotient. All results have been
formalized and machine-checked; in this paper we present the mathematics with
proof sketches.

### 1.1 Background and context

The three viewpoints we unify each have long, independent pedigrees.

*Coalgebra and Myhill–Nerode.* In the classical Myhill–Nerode theorem, the
states of a minimal automaton are the equivalence classes of inputs under
"same residual language." The coalgebraic reformulation replaces languages by
*behaviors* — the function sending each input continuation to the observed
output — and identifies states with the same behavior. This is exactly
bisimilarity for the deterministic-observation functor, and quotienting by it
yields the minimal realization. Our systems are the *semiring-weighted* case,
where outputs live in a semiring `K` and the behavior records a `K`-value per
context.

*Universal algebra and congruences.* A congruence is the kernel of a
homomorphism: precisely the equivalence relations one may quotient by to obtain
another algebra of the same signature. For semirings this means compatibility
with `+` and `·`. The surprise exploited here is that a *semantic* relation
("same behavior") turns out to be a congruence purely because the behavior map
is a homomorphism in the state — a fact that fails for non-algebraic systems.

*Proof-theoretic algebraic geometry.* Semiring congruences play the role that
ideals play for commutative rings: there is a notion of *prime* congruence, a
spectrum of primes carrying a Zariski-style topology, and a Galois connection
between sets of congruence-relations and their "varieties." Realizing a neural
behavior as a congruence therefore places it as a concrete datum in this
spectral world, the entry point for importing geometric machinery.

*Metric semantics.* Quantitative semantics routinely replaces equivalence by
distance, supporting robustness and approximation arguments. The pseudometric
we use is the coarsest such structure — discrete — but it already exposes the
kernel identity, and it sharpens to a true metric after quotienting.

The novelty is not any one of these strands but their *exact* coincidence and
its functoriality, made precise and verified below.

---

## 2. Algebraic neural observation systems

### 2.1 Definition

Throughout, `R` and `K` are semirings and `α` is an alphabet of input symbols.

**Definition 2.1 (Algebraic neural observation system).**
An *algebraic neural observation system* `N` over `(R, K, α)` consists of:

- a family of **layers** `step : R → α → R`, written `step(x, a)`; and
- a **read-out** `observe : R → K`,

subject to the homomorphism laws, for all `a ∈ α` and `x, y ∈ R`:

- `step(0, a) = 0`,
- `step(x + y, a) = step(x, a) + step(y, a)`,
- `step(x · y, a) = step(x, a) · step(y, a)`,
- `observe(0) = 0`,
- `observe(x + y) = observe(x) + observe(y)`,
- `observe(x · y) = observe(x) · observe(y)`.

We deliberately do **not** require preservation of the multiplicative unit `1`.
Behavioral equivalence inspects only sums and products of states under the
read-out, never the state's unit; demanding `step(1, a) = 1` would be an unused
and frequently false hypothesis. This minimality is borne out below: all
congruence axioms hold using only the six laws above.

### 2.2 The behavior map

**Definition 2.2 (Behavior).** For `x ∈ R` and a context (word) `w = a₁⋯aₙ ∈
List α`, the *behavior of `x` on `w`* is

> `behavior(x, w) = observe( foldl(step, x, w) )`,

where `foldl(step, x, [a₁,…,aₙ]) = step(…step(step(x, a₁), a₂)…, aₙ)`. In
particular `behavior(x, []) = observe(x)`.

**Lemma 2.3 (Fold preserves the algebra).** For every word `w`:

- `foldl(step, 0, w) = 0`,
- `foldl(step, x + y, w) = foldl(step, x, w) + foldl(step, y, w)`,
- `foldl(step, x · y, w) = foldl(step, x, w) · foldl(step, y, w)`.

*Proof sketch.* Induct on `w` (using the right-fold/reverse recursion). The base
case is trivial; the inductive step applies the corresponding `step` law to the
accumulated state, since a composite of additive (resp. multiplicative, resp.
zero-preserving) maps has the same property. ∎

**Proposition 2.4 (Behavior is a homomorphism in the state).** For every word
`w`:

- `behavior(0, w) = 0`,
- `behavior(x + y, w) = behavior(x, w) + behavior(y, w)`,
- `behavior(x · y, w) = behavior(x, w) · behavior(y, w)`.

*Proof sketch.* Apply `observe` to Lemma 2.3 and use that `observe` is a
semiring homomorphism. ∎

Proposition 2.4 is the structural lever for everything that follows.

---

## 3. The behavior congruence: the functor object

### 3.1 Behavioral equivalence

**Definition 3.1 (Behavioral equivalence kernel).** Define the relation

> `behaviorRel(x, y)  :⟺  ∀ w ∈ List α,  behavior(x, w) = behavior(y, w)`.

Reflexivity, symmetry, and transitivity are immediate, so `behaviorRel` is an
equivalence relation. It coincides with the coalgebraic Myhill–Nerode
equivalence `weighted_neural_equiv` of the underlying weighted observation
system.

### 3.2 Compatibility with the operations

Recall that a **semiring congruence** on `R` is an equivalence relation `~`
satisfying, whenever `a ~ b` and `c ~ d`,

> `a + c ~ b + d`  and  `a · c ~ b · d`.

**Theorem 3.2 (Behavioral equivalence is a congruence).** `behaviorRel` is a
semiring congruence on `R`.

*Proof sketch.* The equivalence axioms are formal. For additive compatibility,
suppose `a ~ b` and `c ~ d`. For any word `w`, Proposition 2.4 gives
`behavior(a + c, w) = behavior(a, w) + behavior(c, w) = behavior(b, w) +
behavior(d, w) = behavior(b + d, w)`, hence `a + c ~ b + d`. Multiplicative
compatibility is identical with `·` in place of `+`. ∎

We denote the resulting congruence `behaviorCongruence(N) ∈ SRCong R`. By
construction it is a datum of the *proof spectrum* over `R` in the sense of
proof-theoretic algebraic geometry, where the objects are semiring congruences
(the analogues of ideals), prime congruences are geometric points, and a Galois
connection furnishes Zariski-closed provability loci.

**Proposition 3.3 (Zero-class).** The zero-class of `behaviorCongruence(N)` is
exactly the set of *behaviorally null* states:

> `{x : R | behaviorRel(x, 0)} = {x : R | ∀ w, behavior(x, w) = 0}`.

*Proof sketch.* By Proposition 2.4, `behavior(0, w) = 0`, so `behaviorRel(x, 0)`
unfolds to `∀ w, behavior(x, w) = 0`. ∎

### 3.3 The depth filtration

**Definition 3.4 (Depth-`k` equivalence).** Let
`neural_equiv_upto(k)(x, y) :⟺ ∀ w, |w| ≤ k → behavior(x, w) = behavior(y, w)`.

**Theorem 3.5 (Kernel as the limit of finite observers).**

> `behaviorRel(x, y)  ⟺  ∀ k ∈ ℕ, neural_equiv_upto(k)(x, y)`.

*Proof sketch.* Forward: restrict the universal statement over all words to
words of length `≤ k`. Backward: any word has some finite length `k`, so
agreement at all depths forces agreement on it; this is the
`neural_equiv_of_all_upto` reconstruction. ∎

Theorem 3.5 exhibits the proof-spectrum congruence as the intersection of a
converging sequence of finite-depth partition refinements, with the familiar
`O(|α|^k)` observation budget at depth `k`.

---

## 4. Functoriality

### 4.1 Morphisms of algebraic neural systems

**Definition 4.1 (Morphism).** A morphism `f : N → M` of algebraic neural
systems over a common alphabet `α` and output semiring `K` is a state map
`f : R → S` intertwining the dynamics and read-out:

- `f(step_N(x, a)) = step_M(f(x), a)` for all `x, a`;
- `observe_N(x) = observe_M(f(x))` for all `x`.

No compatibility of `f` with `+` or `·` is required; only the dynamics and the
window must be intertwined. Such an `f` is exactly a `NeuralHom` of the
underlying observation coalgebras.

**Theorem 4.2 (Behavior preservation).** For every `x ∈ R` and word `w`,

> `behavior_N(x, w) = behavior_M(f(x), w)`.

*Proof sketch.* Reduce to the coalgebraic statement
`neural_hom_preserves_behavior`: intertwining `step` makes the two folds agree
state-by-state, and intertwining `observe` makes the read-outs agree. ∎

**Corollary 4.3 (Functoriality on objects).** If `behaviorRel_N(x, y)` then
`behaviorRel_M(f(x), f(y))`. Hence `N ↦ behaviorCongruence(N)` is functorial:
morphisms push congruences forward.

*Proof sketch.* For each `w`, rewrite both sides by Theorem 4.2 and apply the
hypothesis `behaviorRel_N(x, y)` at `w`. ∎

### 4.2 The category structure

**Definition 4.4 (Identity and composition).**

- The **identity** `id_N : N → N` has underlying state map the identity; the
  intertwining laws hold by `rfl`.
- The **composite** `f ∘ g : N → P` of `g : N → M` and `f : M → P` has
  underlying state map `f.toFun ∘ g.toFun`; the intertwining laws follow by
  rewriting along those of `g` and then `f`.

**Proposition 4.5 (Extensionality).** Two morphisms with equal underlying state
maps are equal. *Proof sketch.* Destruct both structures; the proof fields are
propositions, so equality of the data forces equality of the morphisms. ∎

With identities, associative composition, and extensionality, algebraic neural
systems and their intertwining morphisms form a **category**.

**Theorem 4.6 (The pushforwards are functorial).** Write `algBehavior(f)` and
`behaviorCongruence_map(f)` for the underlying state pushforward of `f` (the
action of the behavior and congruence functors on morphisms). Then:

- `algBehavior(id_N) = id` and `behaviorCongruence_map(id_N) = id`;
- `algBehavior(f ∘ g) = algBehavior(f) ∘ algBehavior(g)` and
  `behaviorCongruence_map(f ∘ g) = behaviorCongruence_map(f) ∘
  behaviorCongruence_map(g)`.

*Proof sketch.* Each pushforward is the underlying state map `f.toFun`, and the
identity/composition statements hold definitionally (`rfl`) from
Definition 4.4. ∎

---

## 5. The observation pseudometric and the comparison theorem

### 5.1 The pseudometric

**Definition 5.1 (Observation pseudometric).**

> `obsDist(x, y) = 0` if `behaviorRel(x, y)`, and `obsDist(x, y) = 1` otherwise.

**Theorem 5.2 (Pseudometric axioms).** `obsDist` is a pseudometric:

- `obsDist(x, y) ≥ 0`;
- `obsDist(x, x) = 0`;
- `obsDist(x, y) = obsDist(y, x)`;
- `obsDist(x, z) ≤ obsDist(x, y) + obsDist(y, z)`.

*Proof sketch.* Non-negativity and self-distance are by definition and
reflexivity. Symmetry holds because `behaviorRel` is symmetric. For the triangle
inequality, the only failing configuration would have the left side `1` and the
right side `0`, forcing `x ≈ y`, `y ≈ z`, but `x ̸≈ z`, contradicting
transitivity. ∎

It is genuinely a *pseudo*metric: behaviorally distinct internal states may
coincide at distance `0` while being unequal as elements of `R`.

### 5.2 The comparison theorem

**Theorem 5.3 (Kernel = congruence).**

> `obsDist(x, y) = 0  ⟺  behaviorCongruence(N).rel(x, y)`.

*Proof sketch.* Both sides unfold to `behaviorRel(x, y)`. ∎

**Theorem 5.4 (Three faces of one kernel).** For all `x, y ∈ R`:

> `obsDist(x, y) = 0  ⟺  weighted_neural_equiv(x, y)`  and
> `weighted_neural_equiv(x, y)  ⟺  behaviorCongruence(N).rel(x, y)`.

That is, the **metric kernel**, the **Myhill–Nerode behavioral equivalence**,
and the **proof-spectrum semiring congruence** are one and the same relation;
the pseudometric quotient, the coalgebraic quotient, and the algebraic quotient
coincide.

---

## 6. Quotient descent: from pseudometric to metric

### 6.1 The behavior setoid

**Definition 6.1 (Behavior setoid).** Let `behaviorSetoid(N)` be the setoid on
`R` whose relation is `a ≈ b :⟺ obsDist(x,y)=0`, equivalently
`behaviorRel(a, b)`. The setoid axioms follow from Theorem 5.2: reflexivity from
`obsDist(a,a)=0`; symmetry from `obsDist` symmetry; transitivity from the
triangle inequality together with non-negativity (if `obsDist(a,b)=0` and
`obsDist(b,c)=0` then `obsDist(a,c)=0`).

**Lemma 6.2 (Invariance).** `obsDist` is constant on setoid classes: if
`a₁ ≈ a₂` and `b₁ ≈ b₂` then `obsDist(a₁, b₁) = obsDist(a₂, b₂)`.

*Proof sketch.* Translate the setoid relations into `behaviorRel` via
Theorem 5.3. If `a₁ ≈ b₁`, then transitivity gives `a₂ ≈ b₂` (compose
`a₂ ≈ a₁ ≈ b₁ ≈ b₂`), so both sides are `0`; otherwise both are `1` by the
contrapositive. In either case the two values agree. ∎

### 6.2 The quotient metric

**Definition 6.3 (Neural quotient).** Let `NeuralQuotient(N) = R / behaviorSetoid(N)`,
the Myhill–Nerode / proof-spectrum quotient: states modulo behavioral
indistinguishability.

**Definition 6.4 (Descended distance).** By Lemma 6.2, `obsDist` lifts uniquely
to `quotObsDist : NeuralQuotient(N)² → ℝ` with
`quotObsDist([a], [b]) = obsDist(a, b)`.

**Theorem 6.5 (Metric on the quotient).** `quotObsDist` is a metric:

- `quotObsDist(X, X) = 0`;
- `quotObsDist(X, Y) = quotObsDist(Y, X)`;
- `quotObsDist(X, Z) ≤ quotObsDist(X, Y) + quotObsDist(Y, Z)`;
- **Separation:** `quotObsDist(X, Y) = 0  ⟺  X = Y`.

*Proof sketch.* The first three axioms descend from Theorem 5.2 by quotient
induction (choosing representatives). For separation: `quotObsDist([a],[b]) = 0`
means `obsDist(a, b) = 0`, i.e. `a ≈ b` in the setoid, which is exactly
`[a] = [b]` by soundness/exactness of the quotient. ∎

Thus the only defect of `obsDist` — failure of separation — is precisely cured
by quotienting, and the resulting space is the canonical metric realization of
behavior. Moreover, by Corollary 4.3 every morphism descends to a well-defined
map of quotients that is non-expanding for `quotObsDist` (it never increases
observation distance, since it preserves the underlying behavior relation).

---

## 7. Algorithms

### 7.1 Behavior signature and depth-bounded equivalence

By Theorem 3.5, behavioral equivalence is the limit of depth-bounded
equivalences. For a finite alphabet `α` and decidable equality on `K`, depth-`k`
equivalence is decidable by enumerating all `O(|α|^k)` words of length `≤ k` and
comparing read-outs. This yields a partition-refinement procedure: maintain a
partition of states, refine it by depth until it stabilizes, and the stable
partition is the behavior congruence restricted to the explored states.

### 7.2 Quotient construction (minimization)

Given a finite set of states, compute the behavior congruence by partition
refinement (§7.1), then form the quotient by choosing one representative per
class. The result is the minimal realization; the descended metric
`quotObsDist` is the discrete metric on the set of classes.

---

## 7.3 A worked example

To make the constructions concrete, take the Boolean semiring `B = {0,1}` with
`+ = OR`, `· = AND`, and state space `R = B^4`, output space `K = B`. Over `B^n`,
the componentwise semiring homomorphisms `B^n → B^k` are exactly the *wirings*:
each output coordinate is either constant `0` or a copy of one input coordinate.
(Any output equal to the OR of two distinct inputs fails to preserve AND, so
single-source wirings exhaust the homomorphisms.) This gives a faithful, fully
algebraic family of systems.

Consider the system with two input symbols and the layers

> `step(x, a) = (x₁, x₀, x₀, x₁)`,  `step(x, b) = (x₀, x₁, x₁, x₀)`,  read-out
> `observe(x) = x₀`.

Neither layer nor the read-out ever reads input coordinates `2` or `3`; those
bits are *unobservable*. Consequently any two states agreeing on coordinates
`0` and `1` are behaviorally indistinguishable. The `16` states therefore
collapse to exactly `4` behavior classes, indexed by `(x₀, x₁)`. The behavior
congruence is `x ~ y ⟺ x₀ = y₀ ∧ x₁ = y₁`; one checks directly that it is
compatible with componentwise OR and AND, as Theorem 3.2 guarantees. The
observation pseudometric is `0` within each class and `1` across classes, and
the quotient metric `quotObsDist` is the discrete metric on the four classes,
with separation holding by construction. This example is exercised numerically
in the accompanying demonstrations, where every theorem of this paper is checked
exhaustively on it.

## 8. Applications

- **Certified neural compression.** The quotient `NeuralQuotient(N)` is the
  minimal state machine with identical behavior. Collapsing the behavior
  congruence discards exactly the internal distinctions that no input context
  can reveal, a principled and observably-lossless compression.

- **A common currency across fields.** The comparison theorem lets a result
  about distances, congruences, or spectral points be transported to the other
  two settings. Lipschitz/robustness statements (metric), quotient/minimization
  statements (algebra), and prime/Zariski statements (geometry) become
  interchangeable.

- **Behavioral geometry via proof spectra.** Realizing behavior as a point datum
  of a proof spectrum invites the import of Zariski topology, prime
  decomposition, and Galois connections into the analysis of distinguishability.

- **Stability under re-encoding.** Functoriality means that any architecture
  refactor that intertwines the dynamics carries the behavioral geometry with it
  and never expands observation distance.

---

## 9. Discussion and future work

The bridge as developed is `{0,1}`-valued on the metric side and `Prop`-valued
on the functorial side. The following directions sharpen each face.

**C1. Primality as read-out null-detection.** Behavioral congruences are not
automatically *prime*, even over integral domains: from
`∀ w, behavior(a·b, w) = 0` and the absence of zero-divisors one only obtains, for
*each* `w`, a disjunction `behavior(a,w)=0 ∨ behavior(b,w)=0`, which does not
factor through to a global disjunction. A sufficient condition is that the
read-out *detects nullity* along reachable states. Conjecture: for systems whose
reachable behavior values generate `K` multiplicatively, the behavior congruence
is prime **iff** the read-out detects nullity — so the condition is essentially
necessary, not merely sufficient.

**C2. A metric-space-valued functor.** Upgrade the quotient metric of §6 to a
`MetricSpace` instance and show that morphisms induce `1`-Lipschitz
(non-expansive) maps of metric quotients, promoting the `Prop`-level functor to a
functor into the category of metric spaces.

**C3. Graded ultrametric refinement.** The discrete `obsDist` was chosen because
the natural depth-graded distance `2^{-(\text{first separating depth})}` is
ill-defined when no finite depth separates the states. Using the antitone depth
filtration, define `gradDist(x, y) = 2^{-\inf\{k : ¬\,neural\_equiv\_upto(k)(x,y)\}}`
with the empty-set convention giving `0`. Conjecture: `gradDist` is a genuine
**ultrametric** (strong triangle inequality) whose kernel is again the behavior
congruence, refining `obsDist` while agreeing with it on the kernel.

**C4. Functorial Galois/Zariski transport.** When `f.toFun` is a semiring
homomorphism, conjecture that `f` induces a continuous `Spec(f) : ProofSpectrum
S → ProofSpectrum R` for which the behavioral prime congruence is natural,
`Spec(f)(behaviorPrimeCongruence M) = behaviorPrimeCongruence N`, with
`zariskiClosed` pulling back along it — making the bridge a morphism of spectral
spaces.

---

## 10. Conclusion

For algebraic neural observation systems, behavioral indistinguishability admits
three faithful descriptions — an observation pseudometric of distance zero, a
coalgebraic Myhill–Nerode equivalence, and a semiring congruence in a proof
spectrum — and these coincide exactly. The correspondence is functorial:
intertwining morphisms push congruences forward, identities and composition are
respected, and the construction descends to a genuine metric on the behavioral
quotient. Distance, logic, and geometry, so often pursued in isolation, here
name a single object.
