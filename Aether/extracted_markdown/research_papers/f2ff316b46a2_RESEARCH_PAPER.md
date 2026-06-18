# A Tropical Spectral Langlands Correspondence for Finite Residuated Semimodules

## Abstract

We develop, and verify with full formal rigor, a tropical analogue of the spectral
side of the Langlands correspondence for actions of an abstract index set `H` on a
finite lattice `M`. The central object is a **residuated action**: a family of
monotone self-maps `act_h : M → M`, each equipped with a right adjoint (residual)
`res_h`, so that `(act_h, res_h)` is a Galois connection. From this data we manufacture
a family of closure operators `cl_h = res_h ∘ act_h`, whose fixed points (the *closed*
elements) form the spectrum of the action. Our main results are: (i) every residuated
action canonically yields a *closure spectrum object*; (ii) the *tropical character*
`χ(h) = cl_h(⊤)` is the largest closed element; (iii) each *simple summand* (an
irreducible, closure-prime stable element) induces a *closure eigenmeasure* via an
indicator functional valued in `WithBot ℤ`; and (iv) **the resulting summand-to-eigenmeasure
map is injective** — distinct irreducible building blocks always produce distinct
spectral measurements. This injection is the tropical analogue of the Satake map. We
complement these with a coarse classification result (spectral size is determined by
the count of closed elements) and fully computed two-element examples. All statements
are theorems in a constructive, idempotent, inverse-free setting; they require neither
subtraction nor multiplication, only the lattice order and adjunctions.

**Keywords.** Tropical mathematics, idempotent semirings, residuation, Galois
connections, closure operators, Langlands correspondence, Satake isomorphism, spectral
theory, finite lattices, max-plus algebra.

---

## 1. Introduction

### 1.1 Motivation

The Langlands program asserts deep dictionaries between automorphic objects and
spectral / Galois data. A recurring structural theme, independent of the analytic
heavy machinery, is that **the irreducible constituents of a symmetry are faithfully
encoded by the measurements (characters, Hecke eigenvalues, spectral functionals) they
support.** The Satake isomorphism is the prototypical incarnation: it identifies the
spherical Hecke algebra with a ring of characters of a dual group, turning
representation-theoretic atoms into spectral coordinates.

*Tropical mathematics* replaces the field operations `(+, ×)` by the idempotent
operations `(max, +)` (or `(min, +)`). Linear algebra over a field becomes lattice
theory and residuation; smooth representations become monotone residuated actions on
ordered semimodules. It is therefore natural to ask whether the *structural* core of a
Langlands-type correspondence — a faithful map from irreducible summands to spectral
functionals — survives tropicalization. This paper answers in the affirmative for
finite residuated semimodules and proves the result constructively.

### 1.2 Contributions

1. A self-contained axiomatization of **residuated actions** on finite lattices and
   their induced **closure spectra** (Section 3).
2. A complete theory of the **tropical character** `χ(h) = cl_h(⊤)`, including its
   closedness and extremality (Section 4).
3. The **summand-to-eigenmeasure construction** via indicator functionals, with proofs
   of monotonicity, normalization, and closure-invariance (Section 5).
4. The **main injectivity theorem** (tropical Satake map), and its corollary for finite
   semimodules (Section 6).
5. A coarse **classification** by spectral size and fully worked **two-element
   examples** with computed spectra (Section 7).

All results are formally verified; the prose below states each theorem with its full
mathematical content and a proof sketch.

---

## 2. Preliminaries: order, residuation, closure

Throughout, `M` denotes a partially ordered set; in the finiteness results `M` is a
finite lattice with bottom `⊥` and (where needed) top `⊤`. We write `x ≤ y` for the
order and `x ⊔ y` for joins.

**Definition 2.1 (Galois connection).** A pair of maps `f : M → M` and `g : M → M` on a
poset is a *(monotone) Galois connection* `f ⊣ g` if for all `x, y`,
> `f(x) ≤ y  ⟺  x ≤ g(y).`
Then `f` (the left adjoint) and `g` (the right adjoint) are each monotone, and `g` is
the *residual* of `f`.

**Definition 2.2 (Closure operator).** A map `c : M → M` is a *closure operator* if it
is (a) *extensive*: `x ≤ c(x)`; (b) *monotone*; and (c) *idempotent*: `c(c(x)) = c(x)`.

**Fact 2.3 (Composition is closure).** For any Galois connection `f ⊣ g`, the
composite `c = g ∘ f` is a closure operator. (Extensivity is the unit of the
adjunction; idempotence follows from the triangle identities.)

These are exactly the order-theoretic facts our development rests on; in the formal
artifact they are supplied by the ambient library's `GaloisConnection.closureOperator`,
`ClosureOperator.le_closure`, `ClosureOperator.monotone`, and `ClosureOperator.idempotent`.

---

## 3. Residuated actions and closure spectra

### 3.1 The fundamental structure

**Definition 3.1 (Residuated action).** A *residuated action* of an index type `H` on a
poset `M` is a structure `ρ` consisting of:
- a forward action `act : H → M → M`;
- a residual `res : H → M → M`;
- a witness `gc` that for every `h : H`, `act h ⊣ res h` is a Galois connection.

This is the tropical analogue of a representation of a Hecke algebra: the action
preserves order (it is "linear" over the idempotent semiring), and the residual
guarantees well-defined backward inference.

**Derived facts.**
- `act_mono (h) : Monotone (act h)` — the action is monotone (left adjoints are
  monotone).
- `res_mono (h) : Monotone (res h)` — the residual is monotone (right adjoints are
  monotone).

**Definition 3.2 (Closure operator of the action).** For each `h`, define
> `closureOp ρ h = res h ∘ act h`,
a closure operator on `M` by Fact 2.3.

**Definition 3.3 (Closed elements).** An element `x` is *closed under `h`*, written
`IsClosed ρ h x`, if `closureOp ρ h x = x`. Equivalently (unfolding the closure),
`res h (act h x) = x`. The *closed set* `closedSet ρ h = {x | IsClosed ρ h x}`.

**Proposition 3.4 (Basic closure laws).** For every `h` and `x`:
1. `closure_of_fixed`: if `IsClosed ρ h x` then `closureOp ρ h x = x` (definitional).
2. `closureOp_mono`: `closureOp ρ h` is monotone.
3. `closure_isClosed`: `IsClosed ρ h (closureOp ρ h x)` — closures are closed.
4. `le_closure`: `x ≤ closureOp ρ h x` — extensivity.
5. `closure_idempotent`: `closureOp ρ h (closureOp ρ h x) = closureOp ρ h x`.

*Proof sketch.* (1) is the definition of `IsClosed`. (2)–(5) are the closure-operator
laws transported through `Fact 2.3`; idempotence (5) immediately gives (3). ∎

### 3.2 The closure spectrum object

**Definition 3.5 (Closure spectrum).** A *closure spectrum object* over `(H, M)` is a
family `cl : H → ClosureOperator M`. It packages the spectral data of an action
independently of how it was produced — the output of the "Satake-tropical functor."

**Theorem 3.6 (Spectrum from action).** *Every residuated action `ρ` of `H` on a poset
`M` induces a closure spectrum object; in particular `ClosureSpectrum H M` is nonempty.*

*Proof.* Take `cl := closureOp ρ`. Each `closureOp ρ h` is a closure operator by
Fact 2.3, so the assignment is a valid `ClosureSpectrum`. ∎

This is the formal statement `closureSpectrum_of_residualAction`. It is the structural
backbone: representation-theoretic data (a residuated `H`-action) is transformed
functorially into closure-theoretic data.

### 3.3 Finiteness of the spectrum

Assume now `M` is finite with decidable order. Define the **closed finset**
> `closedFinset ρ h = { x ∈ univ | closureOp ρ h x = x }`,
and the **spectral size** `spectralSize ρ h = #{ x | closureOp ρ h x = x }`.

**Proposition 3.7.**
1. `mem_closedFinset`: `x ∈ closedFinset ρ h ⟺ IsClosed ρ h x`.
2. `spectralSize_eq_closedFinset_card`: `spectralSize ρ h = (closedFinset ρ h).card`.
3. `closedFinset_nonempty`: if `M` is nonempty then `closedFinset ρ h` is nonempty.

*Proof sketch.* (1) and (2) unfold the definitions (both `closedFinset` and
`spectralSize` are the same `Finset.filter`). For (3), pick any `x₀ : M`; then
`closureOp ρ h x₀` is closed by `closure_isClosed` (Prop. 3.4(3)), hence lies in the
finset. ∎

Thus the spectrum of a finite residuated action is a nonempty finite set of closed
elements — never void.

---

## 4. The tropical character

Assume `M` has a top element `⊤`.

**Definition 4.1 (Tropical character).** The *tropical character* of `ρ` at `h` is
> `χ(h) := tropicalCharacter ρ h = closureOp ρ h ⊤`.

This is the tropical analogue of the trace/character: the closure of the maximal state.

**Theorem 4.2 (Character is closed).** *For all `h`, `IsClosed ρ h (χ(h))`.*

*Proof.* `χ(h) = closureOp ρ h ⊤`, and the closure of any element is closed by
idempotence (Prop. 3.4(5),(3)). ∎  *(Formal: `tropicalCharacter_is_closed`.)*

**Theorem 4.3 (Character is the largest closed element).** *For all `h` and every closed
`x` (i.e. `IsClosed ρ h x`), `x ≤ χ(h)`.*

*Proof.* Since `x ≤ ⊤` and `closureOp ρ h` is monotone and extensive,
`x ≤ ⊤ ≤ closureOp ρ h ⊤ = χ(h)`; concretely `le_top` followed by `le_closure ρ h ⊤`.
∎  *(Formal: `tropicalCharacter_largest_closed`.)*

Hence `χ(h)` is the maximum of the spectrum `closedSet ρ h`: it is itself closed and
dominates every closed element. In lattice terms it is the top of the sublattice of
closed elements.

### 4.1 Multiplicative refinement

To model a genuine Hecke *algebra* action we record compatibility with a monoid
structure on `H`.

**Definition 4.4 (Multiplicative residuated action).** A `MulResidualAction` over a
monoid `H` extends a residuated action with:
- `act_mul`: `act (h₁ * h₂) x = act h₁ (act h₂ x)` for all `h₁, h₂, x`;
- `act_one`: `act 1 x = x` for all `x`.

**Theorem 4.5 (Identity closure is trivial).** *For a multiplicative residuated action,
`closureOp ρ 1 = id`; that is, `closureOp ρ 1 x = x` for all `x`.*

*Proof sketch.* By `act_one`, `act 1 = id`, so `closureOp ρ 1 x = res 1 (act 1 x) =
res 1 x`. The Galois connection at `1` gives `res 1 x ≤ x` (from `act 1 (res 1 x) =
res 1 x ≤ x`) and `x ≤ res 1 x` (from `act 1 x = x ≤ x`); antisymmetry yields equality.
∎  *(Formal: `MulResidualAction.closureOp_one`.)*

So the spectral identity at the monoid unit is the identity closure: every element is
closed under `1`, and the whole lattice is its own spectrum at the unit — exactly as the
identity Hecke operator should behave.

---

## 5. Simple summands and closure eigenmeasures

We now isolate the irreducible "objects" and the "spectral functionals" between which
the correspondence runs. Assume `M` is a `SemilatticeSup` with `⊥` and decidable order.

**Definition 5.1 (Simple summand).** A *simple summand* of `ρ` is a structure with:
- `val : M`, the underlying element;
- `ne_bot`: `val ≠ ⊥`;
- `closed_all`: `IsClosed ρ h val` for all `h` (stable under every generator);
- `closure_prime`: for all `h, x`, `val ≤ closureOp ρ h x ⟹ val ≤ x`.

The `closure_prime` axiom says the summand cannot be *created* by closure: if it is
visible after closing `x`, it was already below `x`. (In a distributive lattice, closed
join-irreducible elements automatically satisfy this.) Simple summands are the tropical
eigenlines — the irreducible constituents of the action.

**Definition 5.2 (Closure eigenmeasure).** A *closure eigenmeasure* for `ρ` is a
functional `μ : M → WithBot ℤ` with:
- `mono`: `μ` is monotone;
- `bot_map`: `μ(⊥) = ⊥` (i.e. `−∞`);
- `closure_invariant`: `μ(closureOp ρ h x) = μ(x)` for all `h, x`.

`WithBot ℤ` is the integers extended by a least element `−∞`, the natural value range in
the `(max, +)` setting. Closure-invariance is the spectral compatibility condition: the
measurement depends only on the closed shadow of a state.

**Definition 5.3 (Summand indicator).** For a simple summand `s`, define
`summandIndicator ρ s : M → WithBot ℤ` by
> `μ_s(x) = 0`  if `s.val ≤ x`,  and  `μ_s(x) = ⊥` otherwise.

This is the characteristic functional of the principal up-set of `s`, valued in
`{0, −∞}`. It probes presence/absence of the atom `s`.

**Lemma 5.4 (Indicator is monotone).** `summandIndicator ρ s` *is monotone.*

*Proof.* If `x ≤ y` and `s.val ≤ x`, then `s.val ≤ y` by transitivity, so both sides are
`0`. Otherwise the left side is `⊥`, the least element. ∎  *(`summandIndicator_mono`.)*

**Lemma 5.5 (Indicator normalizes).** `summandIndicator ρ s ⊥ = ⊥`.

*Proof.* If `s.val ≤ ⊥` then `s.val = ⊥`, contradicting `s.ne_bot`. Hence the predicate
fails and the value is `⊥`. ∎  *(`summandIndicator_bot`.)*

**Lemma 5.6 (Indicator is closure-invariant).** *For all `h, x`,*
`summandIndicator ρ s (closureOp ρ h x) = summandIndicator ρ s x`.

*Proof.* Two cases.
- If `s.val ≤ x`: by extensivity `x ≤ closureOp ρ h x`, so `s.val ≤ closureOp ρ h x`;
  both sides equal `0`.
- If `¬ (s.val ≤ x)`: suppose for contradiction `s.val ≤ closureOp ρ h x`. By
  `closure_prime` this forces `s.val ≤ x`, a contradiction. Hence the predicate fails on
  the closure too, and both sides equal `⊥`.
∎  *(`summandIndicator_closure_invariant`.)* This is the step where `closure_prime` is
essential.

**Construction 5.7 (Eigenmeasure of a summand).** Combining Lemmas 5.4–5.6, the
indicator `μ_s` satisfies all three eigenmeasure axioms, so
> `summandToEigenmeasure ρ s := ⟨μ_s, mono, bot_map, closure_invariant⟩`
is a `ClosureEigenmeasure ρ`. This defines a map
`Φ : SimpleSummand ρ → ClosureEigenmeasure ρ`.

---

## 6. The spectral correspondence (tropical Satake map)

**Theorem 6.1 (Injectivity — main result).** *The map
`Φ = summandToEigenmeasure ρ : SimpleSummand ρ → ClosureEigenmeasure ρ` is injective.*

*Proof.* Suppose `Φ(s₁) = Φ(s₂)`, i.e. the underlying functionals agree:
`μ_{s₁} = μ_{s₂}` as functions `M → WithBot ℤ`.

Evaluate at the two summand elements. Since `s₂.val ≤ s₂.val`, we have
`μ_{s₂}(s₂.val) = 0`, hence by the assumed equality `μ_{s₁}(s₂.val) = 0`. By the
definition of the indicator, `μ_{s₁}(s₂.val) = 0` means `s₁.val ≤ s₂.val`. Symmetrically,
from `μ_{s₁}(s₁.val) = 0` and the equality, `μ_{s₂}(s₁.val) = 0`, giving
`s₂.val ≤ s₁.val`. By antisymmetry of `≤`, `s₁.val = s₂.val`. As a simple summand is
determined by its underlying element (its remaining fields are propositions over
`val`), `s₁ = s₂`. ∎  *(Formal: `summandToEigenmeasure_injective`.)*

**Theorem 6.2 (Finite spectral correspondence).** *If `M` is a finite
`SemilatticeSup` with `⊥` and decidable order, then `summandToEigenmeasure ρ` is
injective.* This is the finite-semimodule tropical Satake correspondence.

*Proof.* Immediate specialization of Theorem 6.1. ∎  *(`spectral_correspondence_injective`.)*

**Interpretation.** Theorem 6.1 is the structural heart of a Langlands-type dictionary:
*the irreducible building blocks (simple summands) are faithfully recorded by the
spectral functionals (eigenmeasures) they induce.* Two distinct atoms never share a
fingerprint, so the atoms are recoverable from their measurements. The construction is
maximally economical: the fingerprint is the crude `{0, −∞}` indicator, yet it already
separates all summands.

---

## 7. Classification and examples

### 7.1 Spectral-size classification

**Theorem 7.1 (Spectral size ⟺ closed count).** *For residuated actions `ρ_M` on `M`
and `ρ_N` on `N` (both finite, decidable) and a generator `h`,*
> `spectralSize ρ_M h = spectralSize ρ_N h  ⟺  (closedFinset ρ_M h).card = (closedFinset ρ_N h).card.`

*Proof.* Both sides are equal by `spectralSize_eq_closedFinset_card` (Prop. 3.7(2)),
which identifies `spectralSize` with the cardinality of `closedFinset`. ∎
*(`spectralSize_determines_closedCount`.)*

So the coarsest spectral invariant — the size of the spectrum — is precisely the count
of equilibria, and it is an honest invariant comparing actions across different
underlying lattices.

### 7.2 The two-element lattice

Let `M = Bool` with `false < true`, the minimal nontrivial lattice, and `H = Unit`.

**Example 7.2 (Identity action).** `boolIdentityAction` has `act _ x = x`,
`res _ x = x`, with `gc` the identity Galois connection. Then `closureOp = id`, so:
- `boolIdentity_all_closed`: *every* `x : Bool` is closed.
- `boolIdentity_spectralSize`: `spectralSize boolIdentityAction () = 2`.

Both `false` and `true` are equilibria; the spectrum has size `2`.

**Example 7.3 (Constant-false action).** `boolConstFalseAction` has `act _ _ = false`
and `res _ _ = true`; the Galois connection holds because `false ≤ b` always and
`a ≤ true` always. Then `closureOp _ x = res(act x) = true` for all `x`, so:
- `boolConstFalse_closed_true`: `true` is closed.
- `boolConstFalse_spectralSize`: `spectralSize boolConstFalseAction () = 1`.

Only `true` survives as an equilibrium; the spectrum has size `1`. The tropical
character here is `χ(()) = closureOp () ⊤ = true`, the unique closed element, in
agreement with Theorem 4.3.

These two actions, distinguished by spectral size `2` versus `1`, are the smallest
witnesses to Theorem 7.1.

---

## 8. Discussion

### 8.1 What makes this "Langlands-shaped"

Three features mirror the spectral side of the classical theory:
1. **Atoms ↔ spectra.** Simple summands play the role of irreducible (cuspidal/spherical)
   constituents; closure eigenmeasures play the role of Hecke eigensystems / Satake
   parameters. Theorem 6.1 is the faithful-encoding statement.
2. **A distinguished character.** `χ(h) = cl_h(⊤)` is the canonical, maximal spectral
   object, the analogue of the character that crowns a representation; at the identity
   `χ` reduces correctly (Theorem 4.5).
3. **Functoriality.** Theorem 3.6 exhibits a transform "action ↦ closure spectrum,"
   the tropical Satake functor, sending representation-side data to spectral-side data.

### 8.2 Economy of hypotheses

The development is strikingly austere. It uses **no subtraction, no division, no
multiplication on `M`** — only the partial order, adjunctions, and (for finiteness)
decidability. Idempotency is built in: `(max, +)` arithmetic is the native habitat. This
is precisely why the results transfer to settings where field structure is unavailable:
program analysis, scheduling, database dependency theory, and constraint propagation,
all of which are governed by Galois connections and closure operators.

### 8.3 Limitations

- We prove **injectivity**, not surjectivity, of the Satake map. A full bijection would
  require characterizing which eigenmeasures are *extremal* (join-prime) and showing each
  arises from a summand.
- `closure_prime` is taken as a hypothesis on summands. In distributive lattices it is
  automatic for closed join-irreducibles; in general lattices it is a genuine condition.
- The eigenmeasures are valued in `WithBot ℤ` with a two-valued indicator; richer,
  multi-valued spectral functionals are not yet exploited.

---

## 9. Future work

1. **Surjectivity and a Satake isomorphism.** Identify the extremal closure eigenmeasures
   and prove every one is a summand indicator (up to scaling), upgrading Theorem 6.1 to a
   bijection — a genuine tropical Satake isomorphism.
2. **Multiplicative spectra.** Develop the full theory of `MulResidualAction`: show the
   tropical character is multiplicative, `χ(h₁ h₂)` relates to `χ(h₁), χ(h₂)`, and the
   eigenmeasures form a commutative idempotent algebra (the tropical Hecke algebra).
3. **Distributive automaticity.** Prove that in distributive `M`, closed join-irreducible
   elements are automatically closure-prime, removing the hypothesis and connecting to
   Birkhoff duality.
4. **Geometric models.** Instantiate `M` as the lattice of tropical polytopes / matroid
   flats, where closure operators become tropical convex hulls and the spectrum acquires
   polyhedral meaning.
5. **Quantitative spectra.** Replace the `{0, −∞}` indicator with `WithBot ℤ`-graded
   multiplicities, building a tropical character ring with addition `max` and
   multiplication `+`, and relate spectral sizes to dimensions.

---

## 10. Conclusion

We have established, with complete formal verification, the spectral core of a tropical
Langlands correspondence for finite residuated semimodules. From a residuated action we
canonically extract a closure spectrum; its tropical character `cl_h(⊤)` is the maximal
closed element; and each irreducible simple summand is faithfully recorded by an
indicator eigenmeasure, the assignment being injective (the tropical Satake map). A
spectral-size classification and explicit two-element computations ground the theory. The
entire edifice rests on order and adjunction alone — no inverses, no field — demonstrating
that the Langlands pattern "objects are determined by their spectra" persists into the
leanest, idempotent arithmetic of `max` and `+`.
