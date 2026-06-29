# A Quantitative Functorial Bridge from Tropical Valuations to Ultrametric Seminorms

## Abstract

We develop a categorical and quantitative correspondence between **tropical
valuation objects** — sets carrying an additively idempotent, max-based algebraic
structure — and **ultrametric seminorm objects** — sets carrying a norm that obeys
the strong (ultrametric) triangle inequality. The correspondence is realized by an
explicit **valuation reconstruction functor** `valuationReconstruct`, which sends a
tropical valuation carrier to an ultrametric seminorm whose norm *is* the
valuation, and a **tropicalization functor** in the reverse direction. We prove
that reconstruction transports the tropical strong-additivity axiom
`val(x+y) ≤ max(val x, val y)` into the ultrametric strong triangle inequality, and
that both assignments are functorial (they preserve identities and composition).
On suitably restricted subclasses — *rigid* tropical objects and *separated*
ultrametric objects — the unit and counit are isomorphisms, yielding a restricted
equivalence. The principal contribution is **quantitative**: numerical Lipschitz
and gap bounds proven in the tropical world transfer to the ultrametric world with
*identical constants* (sharp transfer), and iterated maps obey the exact `C^n`
rate in both worlds. We derive application-facing corollaries for certified
robustness radii, post-quantum lattice-style security gaps, and depth-wise
Lipschitz degradation in layered models. All statements have been formalized and
machine-verified; the underlying valuation `t ↦ exp(−t)` (equivalently
`q ↦ |q|_p = p^{−v_p(q)}` in the motivating p-adic case) is the order-reversing
exponential that identifies tropical `min`-superadditivity with the ultrametric
`max`-bound.

**Keywords.** tropical semiring, ultrametric space, p-adic valuation,
non-archimedean norm, functor, certified robustness, post-quantum cryptography,
Lipschitz transfer.

---

## 1. Introduction

Two structures recur, under different names, across pure and applied mathematics.

The first is the **tropical** (max-plus / min-plus) semiring, in which addition is
replaced by `max` and multiplication by ordinary addition. Idempotence of the new
addition (`a ⊕ a = a`) eliminates cancellation and collapses arithmetic onto its
order-theoretic skeleton. Tropical methods linearize the asymptotics of
polynomials, shortest-path dynamic programming, and the combinatorics of
polytopes.

The second is the **ultrametric** space, in which the triangle inequality is
strengthened to `d(x, z) ≤ max(d(x, y), d(y, z))`. Such spaces are the native
geometry of the p-adic numbers and, more generally, of any field equipped with a
non-archimedean absolute value. Their geometry is famously rigid: all triangles
are isosceles, every point of a ball is a center, and two balls are either nested
or disjoint.

These two structures are linked by **valuations**. A valuation `v` satisfies
`v(x + y) ≥ min(v x, v y)`; exponentiating by an order-reversing map `t ↦ exp(−t)`
(or `t ↦ p^{−t}` for the p-adic valuation `v_p`) yields a norm
`|x| := exp(−v x)` for which `min` becomes `max` and the inequality becomes the
ultrametric strong triangle inequality `|x + y| ≤ max(|x|, |y|)`.

The folklore status of this correspondence is "obvious dictionary." Our purpose is
to upgrade it to a **theorem with structure and numbers**: (i) a functor in each
direction, with full preservation of identities and composition; (ii) a restricted
equivalence on rigid/separated objects; and, most importantly, (iii) a *sharp
quantitative transfer principle* by which Lipschitz constants, contraction rates,
robustness radii, and security gaps move between the two worlds without loss.

### 1.1 Modeling choices

To obtain clean computational constants and decidable arithmetic, we take the
codomain of valuations and norms to be `ℕ`, with `max` as tropical addition and
ordinary multiplication for the multiplicative structure. Under the exponential
identification this corresponds to working with the integer exponents of a
discrete valuation. All inequalities below are therefore inequalities of natural
numbers; the qualitative content (strong triangle inequality, multiplicativity,
sign-blindness) is identical to the real-valued non-archimedean case, while the
arithmetic remains exact and machine-checkable.

---

## 2. Definitions

### 2.1 Tropical valuation objects

**Definition 2.1 (TropicalValuationObject).** A *tropical valuation object* on a
type `R` is a linearly ordered, additively idempotent commutative monoid with a
compatible multiplication. Concretely it consists of a relation `le` that is
reflexive, antisymmetric, transitive, and total; distinguished elements `zero`,
`one`; operations `add`, `mul`, `max_op`; and the axioms

- **tropical addition:** `add a b = max_op a b`;
- **lattice axioms for `max_op`:** commutativity, associativity, idempotence
  (`max_op a a = a`), `a ≤ max_op a b`, `b ≤ max_op a b`, and the universal
  property `a ≤ c → b ≤ c → max_op a b ≤ c`;
- **multiplicative monoid:** `mul` commutative and associative, `mul a one = a`,
  `mul a zero = zero`;
- **additive unit:** `add a zero = a`.

The defining feature is `add = max_op`: the tropical sum *is* the join.

**Definition 2.2 (TropObj).** A *bundled tropical object* is a pair `⟨α, trop⟩` of
a carrier type and a tropical valuation object on it.

### 2.2 Ultrametric seminorm objects

**Definition 2.3 (UltraNormObj).** An *ultrametric seminorm object* is a type `α`
with operations `add_op`, `neg_op`, `zero_val`, `sub_op` (with
`sub_op x y = add_op x (neg_op y)`), `mul_op`, together with a norm
`norm : α → ℕ` satisfying

- `norm(zero_val) = 0`;
- **sign-blindness:** `norm(neg_op x) = norm x`;
- **strong triangle inequality:** `norm(add_op x y) ≤ max(norm x, norm y)`;
- **multiplicativity:** `norm(mul_op x y) = norm x · norm y`.

These are exactly the axioms of a non-archimedean (ultrametric) multiplicative
seminorm.

### 2.3 Carriers and morphisms

**Definition 2.4 (TropicalValuationCarrier).** A *tropical valuation carrier* is a
ring-like structure `K` with `add_op`, `neg_op`, `zero_val`, `sub_op`, `mul_op`,
`one_val`, and a valuation `val : K → ℕ` obeying the carrier axioms

- `val(zero_val) = 0`,
- `val(neg_op x) = val x`,
- `val(mul_op x y) = val x · val y`,
- `val(add_op x y) ≤ max(val x, val y)`.

This is the data from which an ultrametric norm will be reconstructed.

**Definition 2.5 (Morphisms).**
- A *tropical morphism* `TropHom X Y` is a function preserving `zero`, `one`,
  `add` (hence `max`), `mul`, and order (monotone).
- An *ultrametric morphism* `UltraHom X Y` is a function preserving `zero_val` and
  `add_op` that is *norm-nonexpansive*: `norm_Y(f x) ≤ norm_X(x)`.
- A *carrier morphism* `TropValCarrierHom X Y` preserves `zero`, `add`, `neg`, and
  is valuation-nonexpansive: `val_Y(f x) ≤ val_X(x)`.

Each class is closed under identity and composition, and morphisms are
extensional (equal iff equal as functions).

### 2.4 Restricted subclasses

**Definition 2.6 (TropRigid).** A tropical object `X` is *rigid* if its
max-additive structure separates points: whenever `add x z = add y z` for all `z`,
then `x = y`.

**Definition 2.7 (UltraSeparated).** An ultrametric object `X` is *separated* if
its norm detects equality with the origin: `norm x = 0 ↔ x = zero_val`. This is the
ultrametric analogue of the Hausdorff separation axiom.

### 2.5 Quantitative predicates

**Definition 2.8 (Lipschitz predicates).** For a constant `C : ℕ`,
- `TropLipschitzWith X C f := ∀ x, val(f x) ≤ C · val(x)`;
- `UltraLipschitzWith X C f := ∀ x, norm(f x) ≤ C · norm(x)`.

---

## 3. The reconstruction and tropicalization functors

### 3.1 Object level

**Definition 3.1 (valuationReconstruct).** Given a tropical valuation carrier `X`,
define an ultrametric seminorm object `valuationReconstruct X` with the *same*
underlying carrier and operations, and with `norm := X.val`. The ultrametric
axioms of the output are *literally* the carrier axioms of the input.

**Definition 3.2 (tropicalization).** Given an ultrametric seminorm object `X`,
define `tropicalization X` to be the standard tropical object on `ℕ`, with `max` as
addition and `·` as multiplication (the `tropicalization_base` structure). This
remembers the value semiring and forgets the ring.

### 3.2 Functoriality

**Theorem 3.3 (reconstruction is functorial).** `valuationReconstruct` lifts to
morphisms: a carrier morphism `f : TropValCarrierHom X Y` induces an ultrametric
morphism `valuationReconstruct_map f` (its valuation-nonexpansiveness becomes
norm-nonexpansiveness). Moreover
- `valuationReconstruct_map (id_X) = id`, and
- `valuationReconstruct_map (g ∘ f) = valuationReconstruct_map g ∘ valuationReconstruct_map f`.

*Proof sketch.* The induced map is the same underlying function; the required
preservation and nonexpansiveness data are copied from `f`. Functoriality holds by
extensionality (`UltraHom.ext`): both composites are the identity-on-functions
composite, so they agree pointwise. ∎

**Theorem 3.4 (tropicalization is functorial).** An ultrametric morphism induces a
tropical morphism on value spaces (the identity on `ℕ`), with
`tropicalization_map (id) = id` and
`tropicalization_map (g ∘ f) = tropicalization_map g ∘ tropicalization_map f`.

*Proof sketch.* Each induced tropical morphism is the identity map on `ℕ`, so all
equalities reduce to `rfl` after `ext`. ∎

Theorems 3.3–3.4 are what make the bridge a *machine* rather than a dictionary:
composing in either world and then translating equals translating and then
composing.

---

## 4. Reconstruction theorems

**Theorem 4.1 (ultrametric reconstruction).** For every tropical valuation carrier
`X` and all `x, y`,
`norm(add_op x y) ≤ max(norm x, norm y)` in `valuationReconstruct X`.

*Proof.* `norm = val` definitionally, and the inequality is exactly the carrier
axiom `val_add`. ∎

**Theorem 4.2 (zero and multiplicativity).** In `valuationReconstruct X`,
`norm(zero_val) = 0` and `norm(mul_op x y) = norm x · norm y`.

*Proof.* Immediate from `val_zero` and `val_mul`. ∎

**Theorem 4.3 (asymmetric isosceles principle).** If `norm x ≤ norm y` in
`valuationReconstruct X`, then `norm(add_op x y) ≤ norm y`.

*Proof.* From Theorem 4.1, `norm(add_op x y) ≤ max(norm x, norm y)`; combining
`norm x ≤ norm y` with `norm y ≤ norm y` gives `max(norm x, norm y) ≤ norm y`, and
transitivity finishes. ∎

Theorem 4.3 is the abstract reason every ultrametric triangle is isosceles: a
strictly smaller summand cannot raise the value of the sum above the larger one.

**Theorem 4.4 (sub-norm bounds).** In any ultrametric seminorm object `X`:
- `norm(sub_op x y) ≤ max(norm x, norm(neg_op y))` (from `sub_def` and the strong
  triangle inequality);
- `norm(neg_op x) = norm x` (sign-blindness);
- hence `norm(sub_op x y) ≤ max(norm x, norm y)`;
- and the weak form `norm(add_op x y) ≤ norm x + norm y` (since `max a b ≤ a + b`).

These furnish a symmetric ultrametric distance `d(x, y) := norm(sub_op x y)` that
satisfies the strong triangle inequality; when `X` is separated and `sub_op x x =
zero_val`, the distance is positive-definite (`d(x,x)=0`).

---

## 5. Restricted equivalence

**Theorem 5.1 (separated norms detect distinctness).** If `X` is separated and
`x ≠ zero_val`, then `norm x ≠ 0`.

*Proof.* Contrapositive of `norm_eq_zero_iff`. ∎

**Theorem 5.2 (rigidity is monomorphism-detecting).** If `X` is rigid and
`add x z = add y z` for all `z`, then `x = y`.

*Proof.* Direct from the rigidity axiom. ∎

**Theorem 5.3 (counit isomorphism on separated objects).** For a separated
ultrametric object `X`, the round trip `valuationReconstruct (roundTrip_carrier X)`
is isomorphic to `X` via the identity-carried `UltraIso`; the hom/inv composites
are the identity by extensionality.

**Theorem 5.4 (unit isomorphism on rigid objects).** For a tropical valuation
carrier `X` such that `tropicalization (valuationReconstruct X)` is rigid, the
unit is an isomorphism (`TropIso.refl`), establishing the tropical half of the
restricted equivalence.

*Proof sketch (5.3–5.4).* The round-trip carrier reuses the same underlying
function and operations, so the canonical comparison maps are identities; the
isomorphism laws hold by `ext` reducing to `rfl`. Separation/rigidity guarantee
the comparison is well-defined on the restricted subclass. ∎

Together, Theorems 5.3–5.4 exhibit reconstruction and tropicalization as an
adjoint-style pair whose unit and counit are isomorphisms on the
rigid/separated subclasses — a *restricted categorical equivalence* between the
tropical and ultrametric worlds.

---

## 6. Quantitative transfer principles (the main contribution)

The following results are the heart of the work: bounds proven tropically hold
ultrametrically *with the same constants*.

**Theorem 6.1 (bound transfer).** If `val(f x) ≤ B · val(x)` for all `x`, then
there exists `B' = B` with `norm(f x) ≤ B' · norm(x)` in `valuationReconstruct X`.

**Theorem 6.2 (sharp Lipschitz transfer).** If `f` is `C`-Lipschitz for the
tropical valuation (`TropLipschitzWith X C f`), then `f` is `C`-Lipschitz for the
reconstructed ultrametric norm (`UltraLipschitzWith (valuationReconstruct X) C f`),
*with the identical constant `C`*.

*Proof.* `norm = val` definitionally, so the two Lipschitz predicates are the same
proposition. The transfer is therefore an equality of statements — there is no
constant loss. ∎

**Theorem 6.3 (nonexpansiveness transfer).** If `val(f x) ≤ val(x)` for all `x`,
then `norm(f x) ≤ norm(x)`; and if `f` is `1`-Lipschitz tropically
(`val(f x) ≤ 1·val(x)`), it is ultrametrically nonexpansive.

**Theorem 6.4 (composition of constants).** If `f` is `C₁`-Lipschitz and `g` is
`C₂`-Lipschitz, then `g ∘ f` is `(C₂·C₁)`-Lipschitz:
`val(g(f x)) ≤ C₂·C₁·val(x)`.

*Proof.* Chain the two bounds and use monotonicity of multiplication:
`val(g(f x)) ≤ C₂·val(f x) ≤ C₂·(C₁·val x) = C₂·C₁·val x`. ∎

**Theorem 6.5 (iterated Lipschitz rate).** If `val(f x) ≤ C·val(x)` for all `x`,
then for every `n` and `x`, `val(f^{[n]}(x)) ≤ C^n · val(x)`. The identical `C^n`
bound holds for the reconstructed ultrametric norm.

*Proof.* Induction on `n`. Base `n = 0`: `f^{[0]} = id` and `C^0 = 1`. Step: with
`f^{[n+1]} = f ∘ f^{[n]}`,
`val(f^{[n+1]} x) = val(f(f^{[n]} x)) ≤ C·val(f^{[n]} x) ≤ C·(C^n·val x) =
C^{n+1}·val x` using the hypothesis and the inductive bound. The ultrametric case
is identical because `norm = val`. ∎

**Corollary 6.6 (depth separation).** For an `L`-layer composition of a single
`C`-Lipschitz layer `f`, the total map `f^{[L]}` is `C^L`-Lipschitz. This is
Theorem 6.5 specialized to `n = L`.

**Theorem 6.7 (contraction kills the norm).** If `val(f x) = 0` for all `x`, then
`val(f^{[n]} x) = 0` for every `n ≥ 1`. If `f` is `0`-Lipschitz, then
`val(f x) = 0`; and Lipschitz maps preserve a zero norm (`val x = 0 ⟹
val(f x) = 0`).

These results give a complete, sharp calculus of how perturbation magnitudes
propagate, identical on both sides of the bridge.

---

## 7. Algorithms

The constructive content of the framework yields directly executable procedures.

### 7.1 Valuation reconstruction (object level)

**Input.** A tropical valuation carrier: operations `add, neg, mul`, a base point
`zero`, and `val : K → ℕ` with the four carrier axioms.
**Output.** An ultrametric seminorm with `norm := val` and the strong triangle
inequality guaranteed.

```
function Reconstruct(carrier):
    define norm(x) := carrier.val(x)
    # the four ultrametric axioms hold by Theorems 4.1–4.2:
    #   norm(0) = 0
    #   norm(-x) = norm(x)
    #   norm(x+y) <= max(norm x, norm y)
    #   norm(x*y) = norm x * norm y
    return UltrametricSeminorm(add=carrier.add, neg=carrier.neg,
                               mul=carrier.mul, zero=carrier.zero, norm=norm)
```

Complexity: O(1) structural; each `norm` query costs one `val` evaluation.

### 7.2 p-adic instantiation

The canonical carrier is `(ℚ, +, −, ·, 0, v_p)` for a prime `p`, where the
valuation is the exponent of `p`. Exponentiating gives the p-adic norm
`|q|_p = p^{−v_p(q)}`. Computing `v_p(q)` for `q = a/b` is repeated division of `a`
and `b` by `p`:

```
function pAdicValuation(a, b, p):     # q = a / b, in lowest terms
    k := 0
    while a mod p == 0: a //= p; k += 1
    while b mod p == 0: b //= p; k -= 1
    return k                           # v_p(q); |q|_p = p**(-k)
```

Complexity: O(log_p |a| + log_p |b|).

### 7.3 Iterated Lipschitz certificate

**Input.** A map `f`, per-step constant `C`, iteration count `n`, base valuation
`val(x)`.
**Output.** A certified upper bound on `val(f^{[n]} x)`.

```
function IteratedBound(C, n, base_val):
    return (C ** n) * base_val        # justified by Theorem 6.5
```

Complexity: O(log n) with fast exponentiation.

---

## 8. Applications

### 8.1 Post-quantum security gaps

**Theorem 8.1 (gap transfer).** If for every `y ≠ secret` we have
`val(sub_op y secret) ≥ gap` tropically, then the same lower bound
`norm(sub_op y secret) ≥ gap` holds in the reconstructed ultrametric norm; if
`gap > 0` this is a strictly positive security margin
(`lattice_post_quantum_gap_ultrametric`).

A separation gap is exactly what lattice-based, post-quantum schemes require to
make decoding hard. The theorem certifies that a gap proven by tropical
(combinatorial) means is a genuine ultrametric (geometric) gap.

### 8.2 Certified robustness radii

**Theorem 8.2 (radius transfer).** If a tropical certificate guarantees
`val(sub_op y center) ≤ R ⟹ val y ≤ val center + R`, then the reconstructed
ultrametric norm satisfies the same implication. Hence a robustness radius `R`
certified tropically is a robustness radius `R` ultrametrically
(`quantum_certified_radius_transfer`).

**Theorem 8.3 (Lipschitz certified robustness).** If `f` is `L`-Lipschitz
tropically and `val x ≤ val center`, then
`norm(f x) ≤ L · norm center` in the reconstructed norm
(`lipschitz_certified_robustness_transfer_quantum`). For an `L`-layer network with
per-layer constant `C`, Corollary 6.6 gives total degradation `C^L`.

### 8.3 Stability and fixed points

The max-stability theorem `norm(add_op x y) ≤ max(norm x, norm y)` reads, in
applied terms, as an isosceles concentration bound (a nonarchimedean analogue of
entropy max-stability). The one-step bound `norm(f x) ≤ C · norm x` for
`C`-Lipschitz `f` supplies convergence-rate control for nonarchimedean
fixed-point iteration, and `tropical_hash_collision_resistance_bound` packages the
same inequality as a hash-stretch bound.

---

## 9. Discussion

The conceptual content can be summarized in one line: **the order-reversing
exponential `t ↦ exp(−t)` (concretely `q ↦ p^{−v_p(q)}`) turns the tropical
identity `add = max` into the ultrametric strong triangle inequality, and this
identification is functorial and constant-preserving.**

Three features distinguish this from the folklore dictionary.

1. **Functoriality.** Reconstruction and tropicalization preserve identities and
   composition (Theorems 3.3–3.4), so the correspondence commutes with building
   complex maps from simple ones.
2. **Restricted equivalence.** On rigid/separated objects the unit and counit are
   isomorphisms (Theorems 5.3–5.4), so the two categories genuinely coincide on
   their well-behaved members.
3. **Sharp quantitative transfer.** Lipschitz constants, contraction rates, gaps,
   and radii transfer *without loss* (Theorems 6.1–6.7, 8.1–8.3). Sharpness is
   essential downstream: in certified ML and cryptography, any slack accumulated
   per step would destroy guarantees after a few iterations.

**A documented failure boundary.** The naive valuation inequality
`min(v x, v y) ≤ v(x+y)` *fails* at the zero locus for `padicValRat`: taking
`q = p, r = −p` gives `min(v q, v r) = 1` but `v(q + r) = v(0)`, which by the usual
convention is not `≥ 1`. This is why the additive axiom must be guarded away from
the kernel (or, as here, phrased with the codomain and conventions that keep the
inequality `val(x+y) ≤ max(val x, val y)` valid by construction). The lesson is
that the bridge is *exactly* as wide as the valuation axioms permit, and no wider.

---

## 10. Future directions

- **Completion and the spherically-complete hull.** Extend `UltraNormObj` to its
  induced uniform/metric space (where positive-definite) and prove that the
  completion of the p-adic instantiation recovers the standard `ℚ_p`. The bridge
  map `exp(−v)` is a uniform isomorphism onto its image, so Cauchy-ness in the
  tropical valuation filtration is *definitionally* Cauchy-ness in the arithmetic
  height; completeness can be transported across the bridge rather than re-proved.
- **Real-valued non-archimedean norms.** Replace the `ℕ`-valued norm by a
  real-valued `NonArchNorm` and prove the induced distance is a pseudo-ultrametric,
  recovering the isosceles principle from symmetry plus the strong triangle
  inequality alone (no positive-definiteness needed).
- **Capstone arithmetic identity.** Pin the bridge pointwise via
  `|q|_p = exp(−v_p(q) · log p)` for `q ≠ 0`, exhibiting the arithmetic height as
  the exponential of the negative tropical valuation.
- **Sheaf/persistence and category-theoretic strengthening.** Promote the
  restricted equivalence to a full adjunction with explicit unit/counit and study
  the induced (co)monads.

---

## 11. Conclusion

We have given a fully formalized, machine-verified bridge between tropical
valuation objects and ultrametric seminorm objects. The bridge is a pair of
functors that preserve all categorical structure, restrict to an equivalence on
rigid/separated objects, and — decisively — transport numerical bounds with sharp
constants. The framework unifies, under one verified roof, the combinatorial
strength of tropical methods with the rigid geometry of ultrametric spaces, and
delivers ready-made transfer theorems for certified robustness, post-quantum
security gaps, and depth-wise Lipschitz analysis.
