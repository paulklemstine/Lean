# A Measure-Theory-Free Theory of Expected Empirical Rademacher Complexity over the Boolean Hypercube

## Abstract

We develop a fully finite, measure-theory-free account of the **expected**
empirical Rademacher complexity of a finite hypothesis class. The Rademacher
expectation is realized not as an abstract integral against a probability
measure, but as an honest arithmetic mean over the Boolean hypercube
`{true, false}ⁿ` of cardinality `2ⁿ`. No σ-algebra, no measurable space, and no
Lebesgue integral is invoked at any point; "expectation" is `Σ ⋯ / 2ⁿ`.

The conceptual spine of the theory is a **duality**: a Rademacher sign vector is
a character of the elementary abelian group `(ℤ/2)ⁿ`, and averaging over signs is
a pairing against the uniform measure on its dual. The decisive structural fact
is a single **sign-flip involution** `b ↦ ¬b`, realized as an explicit
permutation of the hypercube, which negates every correlation and thereby forces
the raw mean correlation to vanish identically. From this one symmetry, together
with a coordinatewise magnitude bound transported through the supremum operator,
we derive a complete suite of foundational results: a duality identity, the
collapse of singleton classes, nonnegativity, monotonicity, a basic uniform upper
bound, and positive homogeneity. We give precise statements, proof sketches,
algorithms for exact computation on small instances, numerical illustrations, and
a detailed program of five future directions (Massart's logarithmic refinement,
Talagrand contraction, multilayer spectral composition, symmetrization, and a
PAC-Bayes bridge).

**Keywords:** Rademacher complexity, statistical learning theory, generalization,
Boolean hypercube, character duality, sign-flip involution, finite probability.

---

## 1. Introduction

### 1.1 Motivation

A central object of statistical learning theory is the *capacity* of a hypothesis
class: an intrinsic measure of how flexibly the class can fit arbitrary, even
purely random, target labels. The canonical capacity measure is the **Rademacher
complexity**. Its operational meaning is sharp and intuitive: it quantifies how
well the best member of a class can correlate with a random ±1 labeling of the
data. A class whose Rademacher complexity is large can fit noise and therefore
overfits; a class whose Rademacher complexity is small enjoys provable
generalization guarantees relating empirical risk to true risk.

The standard definitions of Rademacher complexity are stated measure-theoretically,
with an expectation `𝔼_σ` over i.i.d. Rademacher signs. For a *finite* sample of
size `n`, however, this expectation is a finite average over the `2ⁿ` sign
patterns, and there is no genuine need for the apparatus of measure theory. This
paper takes that observation seriously and rebuilds the foundational layer of the
theory entirely within finite, constructive combinatorics. The payoff is twofold:
the proofs become strikingly elementary, and the underlying *symmetry* — the
sign-flip involution — is exposed as the single mechanism driving the entire
theory.

### 1.2 Contributions

We define the expected empirical Rademacher complexity as a literal arithmetic
mean over the Boolean hypercube and prove the following self-contained results.

1. **Coordinatewise correlation bound** (Theorem 4.1): `|corr(σ, h)| ≤ B`
   whenever every coordinate satisfies `|hᵢ| ≤ B`, for `n > 0`.
2. **Duality identity** (Theorem 4.2): for every fixed `h`, the sum of
   correlations over all `2ⁿ` sign patterns is exactly `0`.
3. **Singleton collapse** (Theorem 4.3): a one-element class has expected
   complexity exactly `0`.
4. **Nonnegativity** (Theorem 4.4): a class containing the zero hypothesis has
   nonnegative expected complexity.
5. **Monotonicity** (Theorem 4.5): expected complexity is monotone under class
   inclusion.
6. **Basic upper bound** (Theorem 4.6): `Rₙ(H) ≤ B` under a uniform
   coordinatewise bound `B`.
7. **Positive homogeneity** (Theorem 4.7): `Rₙ(c·H) = c · Rₙ(H)` for `c ≥ 0`.

Each result is fully formal and machine-verifiable, depending only on the three
standard foundational axioms (propositional extensionality, the axiom of choice,
and quotient soundness). In what follows we present the definitions and the
mathematical content with proof sketches.

---

## 2. Preliminaries and notation

Throughout, `n` denotes a fixed natural number, the sample size. We write `ℝ` for
the real numbers.

- **The Boolean hypercube.** The set of sign patterns is the function space
  `Fin n → Bool`, the `n`-fold Boolean cube. It has exactly `2ⁿ` elements. We
  denote a generic element by `σ` and call it a *sign vector* or *Rademacher
  vector*.
- **Hypotheses.** A *hypothesis* is a vector `h : Fin n → ℝ`, interpreted as the
  fingerprint of a predictor evaluated on the `n` sample points. A *hypothesis
  class* is a finite set `H : Finset (Fin n → ℝ)` of hypotheses.
- **Supremum over a class.** For a nonempty finite class `H`, we write
  `H.sup'(f)` for the maximum of a real-valued function `f` over the members of
  `H`. (Finiteness and nonemptiness make this an honest maximum, attained at some
  member.)

---

## 3. Core definitions

### Definition 3.1 (Sign of a Boolean)

The real sign attached to a Boolean is

```
sgn(b) = +1   if b = true,
sgn(b) = −1   if b = false.
```

Two immediate facts, used repeatedly:

- **Involution negation:** `sgn(¬b) = − sgn(b)` for every `b`.
- **Unit magnitude:** `|sgn(b)| = 1` for every `b`.

Both are verified by case analysis on the two values of `b`.

### Definition 3.2 (Rademacher correlation)

For a sign vector `σ : Fin n → Bool` and a hypothesis `h : Fin n → ℝ`, the
**Rademacher correlation** is the empirical average

```
corr(σ, h) = ( Σᵢ sgn(σᵢ) · hᵢ ) / n.
```

This is the inner product of the sign pattern with the hypothesis, normalized by
the sample size. It measures how strongly the predictor `h` aligns (in sign and
magnitude) with the random labeling encoded by `σ`.

### Definition 3.3 (Expected empirical Rademacher complexity)

For a nonempty finite class `H`, the **expected empirical Rademacher complexity**
is

```
Rₙ(H) = ( Σ_{σ ∈ {true,false}ⁿ}  max_{h ∈ H} corr(σ, h) )  /  2ⁿ.
```

In words: for each of the `2ⁿ` sign patterns we record the *best* correlation any
hypothesis in `H` achieves, and then we average that best-in-class value uniformly
over all sign patterns. The outer division by `2ⁿ` is exactly the uniform
expectation over the hypercube — realized as plain counting, with each pattern
weighted `1/2ⁿ`.

### Definition 3.4 (Sign-flip involution)

The **sign-flip involution** is the permutation of the hypercube that negates
every coordinate:

```
flip(σ)ᵢ = ¬(σᵢ)   for every coordinate i.
```

Because pointwise Boolean negation is an involution (`¬¬b = b`), and because a
product of involutions acting coordinatewise is again an involution, `flip` is a
bijection of `{true,false}ⁿ` onto itself with `flip ∘ flip = id`. Structurally,
`flip` is the coordinatewise lift (via the product structure of the function
space) of the unique nontrivial automorphism of a single `Bool` factor; this is
the precise sense in which a *local* per-coordinate symmetry assembles into a
*global* symmetry of the whole cube.

---

## 4. Main results

### Theorem 4.1 (Coordinatewise correlation bound)

> Let `n > 0`, let `σ` be any sign vector, and let `h` be a hypothesis with
> `|hᵢ| ≤ B` for every coordinate `i`. Then `|corr(σ, h)| ≤ B`.

**Proof sketch.** Expand the definition and bound the magnitude of the average.
Since `|corr(σ, h)| = |Σᵢ sgn(σᵢ)·hᵢ| / n`, apply the triangle inequality to the
numerator: `|Σᵢ sgn(σᵢ)·hᵢ| ≤ Σᵢ |sgn(σᵢ)·hᵢ|`. Each summand factors as
`|sgn(σᵢ)|·|hᵢ| = 1·|hᵢ| = |hᵢ| ≤ B` because `|sgn| = 1`. Hence the numerator is
at most `n·B`, and dividing by the positive quantity `n` yields the bound. The
hypothesis `n > 0` is essential: the normalization by `n` makes the `n = 0` case
degenerate, so the bound is stated honestly for positive sample sizes. ∎

### Theorem 4.2 (Duality identity — vanishing mean correlation)

> For every fixed hypothesis `h`, summing the correlation over all sign patterns
> gives exactly zero:
> ```
> Σ_{σ ∈ {true,false}ⁿ}  corr(σ, h) = 0.
> ```

**Proof sketch.** Let `S` denote the sum. Reindex the sum by the sign-flip
bijection `flip`: since `flip` is a permutation of the index set, summing
`corr(flip(σ), h)` over all `σ` produces the same total `S` (we are summing the
same multiset of terms in a permuted order). On the other hand, flipping negates
every sign, `sgn(¬σᵢ) = −sgn(σᵢ)`, so each term satisfies
`corr(flip(σ), h) = −corr(σ, h)`; summing gives `−S`. Equating the two
evaluations, `S = −S`, whence `2S = 0` and `S = 0`. The entire argument is the
invariance of a finite sum under a sign-reversing involution. ∎

This identity is the keystone. It expresses, in finite combinatorial terms, the
fact that a single predictor has zero *expected* correlation with a uniform random
sign labeling — the centering property at the foundation of all sharper
concentration arguments.

### Theorem 4.3 (Singleton collapse)

> For every hypothesis `h`, the expected complexity of the one-element class is
> zero: `Rₙ({h}) = 0`.

**Proof sketch.** When `H = {h}`, the maximum `max_{h' ∈ H} corr(σ, h')` is just
`corr(σ, h)` for each `σ`. Therefore `Rₙ({h}) = (Σ_σ corr(σ, h)) / 2ⁿ`, and the
numerator vanishes by Theorem 4.2. ∎

Interpretation: capacity is a property of *choice*, not of any individual
predictor. A class with no freedom of selection has zero ability to fit noise.

### Theorem 4.4 (Nonnegativity)

> If the zero hypothesis `0` (predicting `0` on every point) belongs to `H`, then
> `Rₙ(H) ≥ 0`.

**Proof sketch.** For each sign pattern `σ`, the in-class maximum dominates the
correlation of any particular member, in particular the zero hypothesis:
`max_{h ∈ H} corr(σ, h) ≥ corr(σ, 0)`. But `corr(σ, 0) = (Σᵢ sgn(σᵢ)·0)/n = 0`.
So every summand of the outer sum is `≥ 0`, the sum is `≥ 0`, and dividing by the
positive `2ⁿ` preserves the sign. ∎

### Theorem 4.5 (Monotonicity)

> If `H ⊆ H′` (with both nonempty), then `Rₙ(H) ≤ Rₙ(H′)`.

**Proof sketch.** For each fixed `σ`, the maximum over the larger set is at least
the maximum over the smaller set: `max_{h ∈ H} corr(σ, h) ≤ max_{h ∈ H′} corr(σ, h)`,
since every competitor available to `H` is also available to `H′`. Summing this
inequality over all `σ` and dividing by `2ⁿ` (a positive constant) yields the
claim. ∎

Interpretation: enlarging the model's vocabulary can only increase its capacity
to fit random labels — the formal counterpart of the maxim that larger model
classes overfit more readily.

### Theorem 4.6 (Basic upper bound)

> If `n > 0` and every hypothesis in `H` satisfies `|hᵢ| ≤ B` for all coordinates
> `i`, then `Rₙ(H) ≤ B`.

**Proof sketch.** By Theorem 4.1, every correlation appearing inside the supremum
satisfies `corr(σ, h) ≤ |corr(σ, h)| ≤ B`. Hence for each `σ` the in-class maximum
is at most `B` (a supremum over values each `≤ B` is `≤ B`). Summing the `2ⁿ`
bounds gives a numerator at most `2ⁿ·B`, and dividing by `2ⁿ` yields `Rₙ(H) ≤ B`. ∎

The bound is honest but worst-case: it is tight only for the single-hypothesis
situation and ignores the size of the class. Massart's refinement (Section 7)
replaces it by a far smaller `O(B·√(ln m / n))` bound for classes of `m` members.

### Theorem 4.7 (Positive homogeneity)

> For a non-negative scalar `c ≥ 0`, scaling every hypothesis by `c` scales the
> complexity by `c`: `Rₙ(c·H) = c · Rₙ(H)`, where `c·H = { c·h : h ∈ H }`.

**Proof sketch.** Correlation is linear in its hypothesis argument:
`corr(σ, c·h) = c · corr(σ, h)`. For `c ≥ 0`, scaling by `c` is monotone, so it
commutes with the maximum: `max_{h ∈ H} corr(σ, c·h) = c · max_{h ∈ H} corr(σ, h)`.
Summing over `σ` and dividing by `2ⁿ` factors the constant `c` out of the whole
expression. ∎

This identity is the `L = 1` base case of the multilayer spectral composition
program (Direction 3 below): it describes exactly how one linear layer, scaled by
its operator norm, scales the complexity it transmits.

---

## 5. The unifying principle

It is worth emphasizing how few ingredients drive the entire theory. There are
precisely two springs.

- **The sign-flip involution** (Definition 3.4) yields the duality identity
  (Theorem 4.2) and, as its immediate shadow, the singleton collapse
  (Theorem 4.3). Mechanically, it is the invariance of a finite sum under a
  sign-reversing permutation.
- **The pointwise unit-magnitude bound** `|sgn| = 1`, transported through the
  averaging and the supremum operator, yields the correlation bound (Theorem 4.1),
  nonnegativity (Theorem 4.4), monotonicity (Theorem 4.5), the uniform upper
  bound (Theorem 4.6), and homogeneity (Theorem 4.7).

The supremum operator `max_{h ∈ H}` is the "gluing functor" that lifts
coordinatewise scalar facts into class-level inequalities: monotonicity of the
supremum gives Theorem 4.5, its dominance over individual members gives
Theorem 4.4, and its commutation with non-negative scaling gives Theorem 4.7.

### The character-theoretic reading

The structure is not an accident. The hypercube `{true,false}ⁿ`, under
coordinatewise XOR, is the elementary abelian 2-group `(ℤ/2)ⁿ`. Through the sign
map `sgn`, each sign vector becomes a `±1`-valued *character* of this group, and
the correlation `corr(σ, h)` is the pairing of that character against the
"signal" `h`. The sign-flip involution `flip` is the action of the global element
`(1,1,…,1) ∈ (ℤ/2)ⁿ`, and the duality identity is the statement that pairing any
fixed signal against the full character group averages to zero — the orthogonality
of the trivial and nontrivial characters. The measure-free theory developed here
is thus a concrete, computational shadow of finite Fourier analysis on
`(ℤ/2)ⁿ`, in which "the mean correlation vanishes" is the elementary case of
character orthogonality.

---

## 6. Algorithms

The finiteness of the construction makes every quantity exactly computable on
small instances. We record the two core algorithms.

### Algorithm 6.1 (Exact expected Rademacher complexity by hypercube enumeration)

**Input.** A sample size `n`; a finite class `H` given as a list of real vectors
of length `n`.
**Output.** The exact value `Rₙ(H)`.

**Method.** Enumerate all `2ⁿ` sign patterns. For each pattern, compute the
correlation of every hypothesis and take the maximum. Average the `2ⁿ` maxima.
The complexity is `Θ(2ⁿ · |H| · n)` time and `Θ(n)` working space (streaming over
patterns). This is the literal, definitional computation and serves as ground
truth against which any closed-form bound is checked.

### Algorithm 6.2 (Duality-identity verification)

**Input.** A sample size `n` and a single hypothesis `h`.
**Output.** The sum `Σ_σ corr(σ, h)`, which Theorem 4.2 predicts is `0`.

**Method.** Pair each sign pattern with its bitwise complement and observe that
the two correlations cancel exactly; summing over the `2ⁿ⁻¹` complementary pairs
gives `0` by construction. The algorithm both verifies the identity numerically
and exhibits the involution that proves it.

---

## 7. Future directions

The foundational layer above is deliberately the first chapter of a larger
program. We outline five concrete continuations, each leveraging exactly the
machinery established here.

**Direction 1 — Massart's logarithmic refinement.** The bound `Rₙ(H) ≤ B` is
tight only in the single-hypothesis worst case; for a class of cardinality `m`
the truth is dramatically smaller, `Rₙ(H) ≤ B·√(2 ln m)/√n`. Replacing the crude
"supremum `≤ B`" step with an exponential-moment (Hoeffding) argument should yield
exactly this `√(ln m)` dependence. The key is that the supremum over a finite
class, after passing through `exp(λ·)`, turns into a *sum* over the class, so the
union bound becomes a sum-over-class estimate and the only analytic input is the
sub-Gaussian moment generating function of a single ±1-weighted coordinate.
Theorem 4.1 already supplies the coordinatewise bound Hoeffding's lemma consumes,
and Theorem 4.2 supplies the zero-mean centering it requires.

**Direction 2 — Lipschitz contraction (Talagrand).** For a 1-Lipschitz map `φ`
with `φ(0) = 0`, the expected complexity of `φ ∘ H` should not exceed that of `H`:
`Rₙ(φ∘H) ≤ Rₙ(H)`, with ReLU as the canonical instance. The contraction can be
proved one coordinate at a time using the *same* sign-flip involution: pairing a
sign pattern with the bit-flip of a single coordinate reduces the Lipschitz
inequality to the scalar fact `|φ(a) − φ(a′)| ≤ |a − a′|`.

**Direction 3 — Inductive multilayer spectral composition.** For an `L`-layer
linear network with per-layer operator-norm bounds `C₁,…,C_L` and 1-Lipschitz
activations, the sum of squared output correlations should be bounded by
`(∏ₗ Cₗ²)` times the sum of squared input correlations. This is a clean induction
on `L`: each step composes one spectral bound with the Direction-2 contraction,
so the product `∏ Cₗ²` accumulates multiplicatively with no cross terms.
Theorem 4.7 is the `L = 1` base case.

**Direction 4 — Generalization gap via symmetrization.** Defining empirical and
ghost-sample risks over a finite data distribution, one conjectures the
symmetrization inequality `𝔼[sup_{h∈H}|R(h) − R̂(h)|] ≤ 2·Rₙ(H)`. For a finitely
supported data law, swapping a real sample point with its ghost copy is literally
one coordinate of the sign-flip involution, so classical measure-theoretic
symmetrization collapses to a re-indexing of a finite sum. The duality identity
(Theorem 4.2) is exactly the singleton shadow of this bound.

**Direction 5 — PAC-Bayes bridge through KL divergence.** Defining the KL
divergence of two distributions over a finite hypothesis set via finite sums and
logarithms, one targets a McAllester-style bound
`𝔼_Q[R(h)] ≤ 𝔼_Q[R̂(h)] + √((KL(Q‖P) + ln(n/δ)) / (2(n−1)))`. The `ln m` term of
Massart's lemma is the special case `KL(uniform‖uniform) = ln m`, so the
finite-class bound and the PAC-Bayes bound become two evaluations of one
divergence functional, making the Rademacher and PAC-Bayes formalizations
directly composable.

---

## 8. Discussion

The contribution of this work is not a single hard theorem but a *reorganization*:
it shows that the foundational layer of Rademacher complexity for finite samples
needs no measure theory at all, and that its entire edifice rests on one symmetry
of the Boolean hypercube. Three consequences are worth highlighting.

First, **transparency**. Every result reduces to either the sign-flip involution
or the unit-magnitude bound. A reader who understands "flip all the coins" and
"the average of things at most `B` is at most `B`" understands the whole theory.

Second, **constructivity**. Because expectation is a finite sum, every quantity is
exactly computable, and the proofs are constructive. This makes the theory an
ideal didactic and computational substrate: one can numerically verify each
theorem on concrete instances, as the accompanying demonstrations do.

Third, **composability**. The same involution that proves the duality identity is
the per-coordinate symmetry needed for the contraction principle (Direction 2),
which in turn drives the multilayer composition bound (Direction 3). The homogeneity
law (Theorem 4.7) is precisely the single-layer base case of that induction. The
theory is thus engineered to grow: each foundational lemma is the seed of a
sharper successor.

The principal limitation is computational: exact enumeration over the hypercube is
exponential in `n`, so the framework is a tool for proof, pedagogy, and small-scale
verification rather than large-scale numerical estimation. The asymptotic regime
is precisely where the future directions — especially Massart's lemma — take over,
trading exact enumeration for sharp closed-form bounds.

---

## 9. Conclusion

We have presented a complete, self-contained, measure-theory-free foundation for
the expected empirical Rademacher complexity of finite hypothesis classes over the
Boolean hypercube. The theory comprises seven results — a coordinatewise bound, a
duality identity, singleton collapse, nonnegativity, monotonicity, a uniform upper
bound, and positive homogeneity — all flowing from a single sign-flip involution
and a single pointwise magnitude bound. Beyond their immediate content, these
results expose the character-theoretic skeleton of Rademacher complexity and lay
the groundwork for sharper refinements, contraction principles, multilayer
composition, symmetrization, and PAC-Bayes bridges. The lesson is that one of the
most important capacity measures in learning theory is, at its core, the simple
arithmetic of flipping every coin at once.
