# The Order-Theoretic Core of the Cook–Reckhow Program, with a Fibonacci Separation Bridge

## Abstract

We develop, from first principles, the order theory underlying the Cook–Reckhow program
in propositional proof complexity. Abstracting a proof system to a completeness-witnessing
map equipped with a size measure, we define the *p-simulation* relation and prove it is a
genuine **preorder**. The structural heart of the result is the identification of
transitivity with closure of the polynomial blow-up class under composition. We register
mutual simulation (*p-equivalence*) as an equivalence relation whose quotient is the
**poset of p-degrees**. We then bridge this abstract order to elementary number theory:
the Fibonacci sequence grows super-polynomially, and this single arithmetic fact yields a
**separation theorem** — any family of theorems with linear-size proofs in one system but
Fibonacci-size lower bounds in another witnesses non-simulation. We isolate the only
arithmetic input (domination by a polynomially bounded function is polynomially bounded),
recover the Fibonacci statement as one instance of a **generic separation template**
parametric in the hardness function, and exhibit two concrete proof systems realizing the
separation, proving the p-degree poset has at least two distinct points. All results have
been formalized and machine-checked with zero `sorry` and only the standard foundational
axioms.

**Keywords:** proof complexity, Cook–Reckhow program, p-simulation, preorder,
p-degrees, Fibonacci numbers, super-polynomial separation, antisymmetrization.

---

## 1. Introduction

### 1.1 The Cook–Reckhow abstraction

A *propositional proof system*, in the sense of Cook and Reckhow, is a polynomial-time
computable surjection from strings ("proofs") onto the set of propositional tautologies
("theorems"). The surjectivity encodes *completeness* (every tautology has a proof) and
the polynomial-time computability encodes *soundness checkability* (one can efficiently
verify that a given proof certifies a given theorem). Cook and Reckhow's foundational
observation is that the existence of a *polynomially bounded* proof system — one in which
every tautology has a proof of size polynomial in the tautology — is equivalent to
`NP = coNP`. The program they initiated seeks super-polynomial *lower bounds* for ever
stronger concrete systems, climbing toward this equivalence.

The relation that organizes the entire program is **p-simulation**: `P` p-simulates `Q`
when `Q`-proofs translate into `P`-proofs of the same theorem with at most polynomial
blow-up. Separating two systems means proving that no such translation exists, which is
always achieved by exhibiting a family of theorems hard for one and easy for the other.

### 1.2 Contribution

This paper formalizes the *order-theoretic skeleton* of this program in a way that is
deliberately stripped of the computability layer, isolating the purely structural and
growth-theoretic content. Our contributions are:

1. A clean axiomatization of abstract proof systems and the p-simulation relation
   (Section 2), and a proof that simulation is a **preorder** (Theorem 3.3), with the
   conceptual observation that transitivity *is* composition-closure of the blow-up class.
2. The registration of p-equivalence as an equivalence relation and the identification of
   its quotient as the **poset of p-degrees** (Section 4).
3. A **Fibonacci growth bridge**: an elementary exponential lower bound on Fibonacci
   numbers, hence super-polynomiality, hence a separation theorem (Section 5).
4. A **generic separation template** parametric in the hardness function, recovering the
   Fibonacci case as a single instance, and a **concrete realization** by two explicit
   proof systems, proving the p-degree poset is non-trivial (Section 6).

All statements have been formalized and verified with `sorry = 0`, depending only on the
axioms `propext`, `Classical.choice`, and `Quot.sound`.

---

## 2. Definitions

### 2.1 The polynomial blow-up class

We must first fix what "polynomial" means as a class of functions `ℕ → ℕ`. The naive
choice `f(n) ≤ (n+1)^k` fails to be closed under composition because it cannot dominate a
constant greater than `1` at `n = 0`. The following shifted definition repairs this.

> **Definition 2.1 (Polynomially bounded).** A function `f : ℕ → ℕ` is *polynomially
> bounded*, written `PolyBounded f`, if there exists `k : ℕ` such that
> `f(n) + 1 ≤ (n + 2)^k` for all `n`.

> **Definition 2.2 (Blow-up function).** A function `f : ℕ → ℕ` is a *blow-up function*,
> written `PolyMono f`, if it is both monotone and polynomially bounded.

The base `n + 2 ≥ 2` and the `+1` slack are what make Definition 2.1 robust at small
inputs; monotonicity in Definition 2.2 is the additional ingredient transitivity needs to
chain two size bounds.

### 2.2 Abstract proof systems

> **Definition 2.3 (Proof system).** For a type `Thm` of theorems, a *proof system* is a
> structure
> `ProofSystem Thm := (Proof : Type, proves : Proof → Thm, size : Proof → ℕ,`
> `complete : Surjective proves)`.
> The field `proves` assigns to each proof the theorem it certifies; `size` measures proof
> length; `complete` witnesses that every theorem has at least one proof.

This is the Cook–Reckhow definition with the computability layer abstracted away: we keep
completeness (surjectivity) and the size measure, the two ingredients that simulation
actually constrains.

### 2.3 Simulation

> **Definition 2.4 (p-simulation).** For proof systems `P, Q` over the same `Thm`,
> `P` *p-simulates* `Q`, written `Simulates P Q`, if there is a blow-up function
> `f` (i.e. `PolyMono f`) such that for every `Q`-proof `q` there is a `P`-proof `p` with
> `P.proves p = Q.proves q` and `P.size p ≤ f(Q.size q)`.

> **Definition 2.5 (p-equivalence).** `PEquiv P Q := Simulates P Q ∧ Simulates Q P`.

---

## 3. The simulation preorder

### 3.1 Closure of the blow-up class

> **Lemma 3.1 (Identity is a blow-up).** `PolyBounded (fun n ↦ n)`, and indeed
> `PolyMono (fun n ↦ n)`.
>
> *Proof sketch.* Take `k = 1`: `n + 1 ≤ (n+2)^1` is immediate. Monotonicity of the
> identity is trivial. ∎

> **Lemma 3.2 (Composition closure).** If `PolyBounded f` and `PolyBounded g`, then
> `PolyBounded (fun n ↦ f (g n))`. Consequently `PolyMono` is closed under composition.
>
> *Proof sketch.* Let `f(m) + 1 ≤ (m+2)^a` and `g(n) + 1 ≤ (n+2)^b`. First bound the
> inner argument: `g(n) + 2 ≤ (n+2)^b + 1 ≤ 2(n+2)^b ≤ (n+2)^{b+1}`. Then
> `f(g(n)) + 1 ≤ (g(n)+2)^a ≤ ((n+2)^{b+1})^a = (n+2)^{a(b+1)}`. So `k = a(b+1)` works.
> Monotonicity is preserved because the composition of monotone functions is monotone. ∎

Lemma 3.2 is the algebraic engine of the entire theory. It is the *same statement* as
transitivity of simulation, viewed through the dictionary "blow-up class ↔ relation."

### 3.2 The preorder

> **Theorem 3.3 (Simulation is a preorder).** `Simulates` is reflexive and transitive; it
> therefore equips `ProofSystem Thm` with a `Preorder` structure (`P ≤ Q ↔ Simulates P Q`).
>
> *Proof sketch.*
> *Reflexivity.* `Simulates P P` via the identity blow-up (Lemma 3.1): each proof `q`
> simulates itself with `size ≤ id (size q)`.
> *Transitivity.* Suppose `Simulates P Q` with blow-up `f` and `Simulates Q R` with
> blow-up `g`. Given an `R`-proof `r`, pull it back through `g` to a `Q`-proof `q` of the
> same theorem with `Q.size q ≤ g(R.size r)`, then through `f` to a `P`-proof `p` of the
> same theorem with `P.size p ≤ f(Q.size q)`. By monotonicity of `f`,
> `P.size p ≤ f(Q.size q) ≤ f(g(R.size r))`. The composite blow-up `f ∘ g` is a blow-up
> function by Lemma 3.2, establishing `Simulates P R`. ∎

---

## 4. p-equivalence and the poset of p-degrees

> **Theorem 4.1 (p-equivalence is an equivalence relation).** `PEquiv` is reflexive,
> symmetric, and transitive, and is registered as a `Setoid` on `ProofSystem Thm`.
>
> *Proof sketch.* Reflexivity and transitivity follow from Theorem 3.3 (the latter by
> composing simulations in both directions); symmetry is immediate from the conjunctive
> definition. ∎

> **Definition 4.2 (p-degrees).** The *p-degrees* are the equivalence classes of `PEquiv`,
> i.e. the elements of the quotient `ProofSystem Thm / PEquiv`.

Because `Simulates` is a preorder and `PEquiv` is exactly its symmetric part, `PEquiv`
coincides with the antisymmetry relation `AntisymmRel (· ≤ ·)` of the preorder. Hence the
quotient carries Mathlib's canonical `PartialOrder` via the `Antisymmetrization`
construction:

> **Proposition 4.3 (Antisymmetrization).** `PEquiv P Q ↔ AntisymmRel (· ≤ ·) P Q`
> (definitionally). Therefore the poset of p-degrees is
> `Antisymmetrization (ProofSystem Thm) (· ≤ ·)`, equipped with its library
> `PartialOrder` instance.

This is the cleaned-up object the Cook–Reckhow program studies: a partial order whose
height and width encode the central separation questions of proof complexity.

---

## 5. The Fibonacci bridge

### 5.1 An exponential lower bound

> **Lemma 5.1 (Doubling bound).** For all `n`, `2^n ≤ F(2n + 1)`, where `F` is the
> Fibonacci sequence (`F(0) = 0`, `F(1) = 1`, `F(m+2) = F(m+1) + F(m)`).
>
> *Proof sketch.* Induction on `n`. Base: `2^0 = 1 ≤ 1 = F(1)`. Step: using
> `2(m+1)+1 = (2m+1)+2` and `F(k+2) = F(k+1) + F(k) ≥ 2F(k)` (since `F` is monotone),
> `F(2(m+1)+1) ≥ 2·F(2m+1) ≥ 2·2^m = 2^{m+1}` by the inductive hypothesis. ∎

### 5.2 Super-polynomiality

> **Theorem 5.2 (Fibonacci is not polynomially bounded).** `¬ PolyBounded Nat.fib`.
>
> *Proof sketch.* Suppose `F(n) + 1 ≤ (n+2)^k` for all `n`. Substituting `n = 2m+1` and
> using Lemma 5.1 gives `2^m ≤ F(2m+1) ≤ (2m+3)^k`. But exponentials dominate
> polynomials: the ratio `(2m+3)^k / 2^m → 0` as `m → ∞` (a consequence of the standard
> fact that `m^k / 2^m → 0`, transported through `(2m+3)^k = (2 + 3/m)^k · m^k`). Hence for
> large `m`, `(2m+3)^k < 2^m`, contradicting `2^m ≤ (2m+3)^k`. ∎

> **Corollary 5.3 (No polynomial dominates Fibonacci).** If `F(n) ≤ f(n)` for all `n`, then
> `¬ PolyBounded f`.
>
> *Proof sketch.* If `f` were polynomially bounded with exponent `k`, then `F(n) + 1 ≤
> f(n) + 1 ≤ (n+2)^k`, making `F` polynomially bounded, contradicting Theorem 5.2. ∎

### 5.3 The separation theorem

> **Theorem 5.4 (Separation via Fibonacci lower bounds).** Let `P, Q` be proof systems and
> `t : ℕ → Thm` a family of theorems. Suppose:
> - (*easy for `Q`*) there are `Q`-proofs `q(n)` with `Q.proves (q n) = t n` and
>   `Q.size (q n) ≤ n`;
> - (*hard for `P`*) every `P`-proof `pf` with `P.proves pf = t n` has `F(n) ≤ P.size pf`.
>
> Then `¬ Simulates P Q`.
>
> *Proof sketch.* Suppose a blow-up `f` witnesses `Simulates P Q`. For each `n`, simulate
> `q(n)` to obtain a `P`-proof `p` of `t(n)` with `P.size p ≤ f(Q.size (q n)) ≤ f(n)` (the
> last step by monotonicity of `f` and `Q.size(q n) ≤ n`). Hardness gives `F(n) ≤ P.size
> p ≤ f(n)`. Thus `f` dominates `F` pointwise, so `¬ PolyBounded f` by Corollary 5.3,
> contradicting that `f` is a blow-up function. ∎

---

## 6. Generic template and concrete realization

### 6.1 The single arithmetic input

> **Lemma 6.1 (Domination is polynomially bounded).** If `s(n) ≤ f(n)` for all `n` and
> `PolyBounded f`, then `PolyBounded s`.
>
> *Proof sketch.* From `f(n) + 1 ≤ (n+2)^k` and `s(n) ≤ f(n)` we get `s(n) + 1 ≤ f(n) + 1
> ≤ (n+2)^k`. ∎

Lemma 6.1 is the *only* arithmetic fact the separation argument uses; everything else is
order theory. Corollary 5.3 is its instance `s = Nat.fib`.

### 6.2 The generic separation template

> **Theorem 6.2 (Generic separation).** Let `P, Q` be proof systems, `t : ℕ → Thm`,
> `q : ℕ → Q.Proof` with `Q.proves (q n) = t n` and `Q.size (q n) ≤ n`. Let `s : ℕ → ℕ`
> satisfy `¬ PolyBounded s`, and suppose every `P`-proof `pf` of `t n` has `s(n) ≤
> P.size pf`. Then `¬ Simulates P Q`.
>
> *Proof sketch.* Identical to Theorem 5.4 with `F` replaced by `s`: a hypothetical
> blow-up `f` would dominate `s` (`s(n) ≤ f(n)` for all `n`), so `PolyBounded s` by
> Lemma 6.1 — contradicting `¬ PolyBounded s`. ∎

> **Corollary 6.3.** Theorem 5.4 is the instance `s = Nat.fib` of Theorem 6.2, via
> Theorem 5.2.

The template makes explicit that Fibonacci was never special: *any* non-polynomial
hardness function separates. Replacing `Nat.fib` by quasi-polynomial, sub-exponential, or
exponential growth rates instantly yields new separations with no change to the order
structure.

### 6.3 Two concrete proof systems over `ℕ`

Take `Thm = ℕ`, where the natural number `n` stands for the `n`-th theorem.

> **Definition 6.4 (Linear system).** `linSystem : ProofSystem ℕ` has `Proof = ℕ`,
> `proves = id`, `size = id`, and completeness from `Surjective id`.

> **Definition 6.5 (Fibonacci system).** `fibSystem : ProofSystem ℕ` has `Proof = ℕ`,
> `proves = id`, `size = Nat.fib`, and completeness from `Surjective id`.

Both are complete because `proves = id` is surjective; they share the same theorems but
assign radically different sizes to the canonical proof of `n`.

> **Theorem 6.6 (Concrete separation).** `¬ Simulates fibSystem linSystem`. Hence
> `∃ P Q : ProofSystem ℕ, ¬ Simulates P Q`.
>
> *Proof sketch.* Apply Theorem 6.2 with `P = fibSystem`, `Q = linSystem`, `t = id`,
> `q = id`, and `s = Nat.fib` (non-polynomial by Theorem 5.2). The "easy for `Q`"
> hypotheses are `linSystem.proves (id n) = n` and `linSystem.size (id n) = n ≤ n`, both
> immediate. For "hard for `P`": a `fibSystem`-proof `pf` of `n` has `pf = n` (since
> `proves = id`), so `fibSystem.size pf = F(n) ≥ F(n)`. ∎

### 6.4 Non-triviality of the p-degree poset

> **Theorem 6.7 (At least two p-degrees).** The poset
> `Antisymmetrization (ProofSystem ℕ) (· ≤ ·)` has at least two distinct elements; the
> images of `fibSystem` and `linSystem` are distinct.
>
> *Proof sketch.* If the two systems mapped to the same p-degree they would be
> `PEquiv`, in particular `Simulates fibSystem linSystem`, contradicting Theorem 6.6.
> Under Proposition 4.3, distinctness in the antisymmetrization is exactly the failure of
> `PEquiv`. ∎

---

## 7. Algorithms

The development is non-constructive in its separations (it refutes the *existence* of a
simulation) but its building blocks are fully effective. We record the natural algorithmic
companions, all of which appear in the accompanying demonstration code.

**(A) Polynomial-bound certification.** Given `f` (as a callable) and bounds `(N, K)`,
search for the least `k ≤ K` such that `f(n) + 1 ≤ (n+2)^k` for all `n ≤ N`; report the
witnessing exponent or "no bound found in range." This is the computational shadow of
`PolyBounded`.

**(B) Composition-exponent computation.** Given polynomial witnesses `a` for `f` and `b`
for `g`, return `a·(b+1)` — the exponent produced by Lemma 3.2 — and verify it certifies
`f ∘ g` on a finite range.

**(C) Fibonacci doubling-bound verifier.** Compute `F(2n+1)` and `2^n` and check
`2^n ≤ F(2n+1)` (Lemma 5.1) over a range.

**(D) Separation crossover finder.** Given a candidate polynomial blow-up `(n+2)^k` and a
hardness function `s`, find the least `n` with `s(n) > (n+2)^k`, exhibiting the input at
which the simulation budget is exceeded — the concrete failure point underlying
Theorem 6.2.

---

## 8. Applications

- **A unifying lens on lower bounds.** Every super-polynomial proof-size lower bound in
  the literature (resolution, cutting planes, bounded-depth Frege, …) instantiates the
  generic template (Theorem 6.2) as a hardness function `s`, automatically yielding a
  separation in the p-degree poset. The labor-intensive part is always *finding* `s`; the
  order-theoretic consequence is free.
- **A machine-checked foundation.** The preorder/poset structure provides a verified base
  on which formalized proof-complexity results can be stated as comparisons of p-degrees.
- **A growth-class laboratory.** Because only Lemma 3.2 (closure under composition) and
  Theorem 5.2 (`Nat.fib` non-polynomial) are used, the entire theory is parametric in the
  blow-up class, enabling study of quasi-polynomial and sub-exponential simulations by
  swapping the class.

---

## 9. Discussion

The conceptual punchline is a reduction of *qualitative* separation phenomena to
*quantitative* growth theory. The relation "`P` fails to p-simulate `Q`" is equivalent to
"the required blow-up escapes the polynomial class," which is a statement purely about
function growth. This is why the separation argument is parametric in the hardness
function and why Fibonacci — a concrete, well-understood super-polynomial sequence — is a
natural first witness rather than an essential one.

A subtle but important modeling choice is the definition of `PolyBounded` as
`f(n) + 1 ≤ (n+2)^k`. The shift makes the class closed under composition with no
edge-case at `n = 0`, which is precisely the property that makes transitivity of
simulation hold on the nose. The lesson generalizes: the *right* definition of the blow-up
class is one engineered to be composition-closed, and any such class yields a preorder.

---

## 10. Future work

See the "Future Directions" compilation accompanying this package for the full program. In
brief: (1) an infinite strict chain of p-degrees from a sequence of pairwise
non-dominating growth rates; (2) a strict collapse/separation dichotomy for two-element
antichains; (3) the full partial-order structure on p-degrees and its (non-)lattice
properties; (4) closure-class robustness — abstracting the blow-up class to any
composition-closed, super-polynomially-bounded class and tracking where Fibonacci-style
separations survive; and (5) number-theoretic refinements of the Carmichael
primitive-divisor companion (entry-point spectrum for prime indices, composite tail).

---

## 11. Conclusion

We have built the order-theoretic core of the Cook–Reckhow program as a self-contained,
machine-verified theory: p-simulation is a preorder, p-equivalence its symmetric part, and
the quotient a genuine partial order of p-degrees. We bridged this abstract structure to
elementary number theory, showing that the super-polynomial growth of the Fibonacci
sequence separates proof systems, isolated the single arithmetic fact responsible
(domination preserves polynomial boundedness), and realized the separation concretely,
proving the p-degree poset is non-trivial. The Fibonacci bridge is one instance of a
generic template: every super-polynomial hardness witness is a separation, and the search
for such witnesses is the science Cook and Reckhow began.
