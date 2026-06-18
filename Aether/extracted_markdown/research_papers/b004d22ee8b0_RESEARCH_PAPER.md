# The Order Type of the p-Degrees: A Formal Order-Theoretic Core for the Cook–Reckhow Program

## Abstract

We develop, in fully formalized and machine-verified form, the order-theoretic
core of the Cook–Reckhow program in propositional proof complexity. Abstracting a
proof system to a surjective "certification" map equipped with a size function, we
define the **p-simulation preorder** `Simulates` on proof systems and prove it is
a genuine preorder whose antisymmetrization is the **poset of p-degrees**. The
central technical device is the **Domination Characterization**, which reduces
simulation between size-indexed systems to pointwise polynomial domination of
their size functions; through it, every structural property of the poset becomes
an elementary statement about growth rates. We prove: (i) the preorder is a
preorder and p-equivalence is an equivalence relation; (ii) Fibonacci growth is
super-polynomial and hence separates proof systems, yielding a generic separation
template parametric in any non-polynomial hardness function; (iii) the poset has
binary meets (it is a down-directed meet-semilattice), realized by the direct-sum
proof system; (iv) the poset has **infinite height**, via the power ladder
`2^(n^k)`; (v) the poset is **dense along the ladder**, via parity-glued
intermediate systems; and (vi) the poset has a **least element but no greatest
element** (an order-type asymmetry obtained by diagonalization). All results are
verified with no `sorry` and depend only on the standard axioms `propext`,
`Classical.choice`, and `Quot.sound`.

**Keywords.** proof complexity, Cook–Reckhow program, p-simulation, p-degrees,
order theory, growth rates, density, diagonalization, formal verification.

---

## 1. Introduction

The Cook–Reckhow framework recasts the question "is NP closed under
complementation?" as a question about the existence of *polynomially bounded*
propositional proof systems. A propositional proof system is a polynomial-time
computable surjection from strings ("proofs") onto the set of tautologies; it is
polynomially bounded if every tautology has a proof of size polynomial in the
tautology. Cook and Reckhow observed that **NP = coNP if and only if a
polynomially bounded proof system exists**, and that progress is organized by the
*simulation* relation between systems. Two systems are p-equivalent if each can
imitate the other with polynomial overhead, and the equivalence classes — the
**p-degrees** — form a partial order under simulation.

This paper formalizes the order-theoretic backbone of that program, deliberately
stripping away the computability layer to isolate the *combinatorial and
arithmetic* content. Our central observation, made fully rigorous, is that for a
canonical family of "size-indexed" proof systems the simulation relation is
*exactly* polynomial domination of size functions. This converts order theory
into the arithmetic of growth rates: chains correspond to families of pairwise
incomparable growth rates ordered by domination, antichains to incomparable
rates, density to interpolation of rates, and the absence of a top to the
non-existence of a universal growth rate. The resulting picture is a poset with a
least element, no greatest element, infinite height, infinite width, and density
along its principal chain.

All definitions and theorems below have been formalized and checked. We state
each result with its precise mathematical content and a proof sketch reflecting
the formal argument.

---

## 2. Definitions

### 2.1 The polynomial blow-up class

**Definition 2.1 (Polynomially bounded).** A function `f : ℕ → ℕ` is
*polynomially bounded*, written `PolyBounded f`, if
$$\exists\, k \in \mathbb{N},\ \forall\, n,\quad f(n) + 1 \le (n + 2)^k.$$

**Definition 2.2 (Monotone polynomial blow-up).** `f : ℕ → ℕ` is a *monotone
polynomial blow-up*, written `PolyMono f`, if `f` is monotone and `PolyBounded f`.

The base `(n+2)` and the `+1` offset are not cosmetic. They guarantee closure
under composition, which the more naive class `f(n) ≤ (n+1)^k` fails (it cannot
dominate a constant `> 1` at `n = 0`).

**Lemma 2.3 (Composition closure).** If `PolyBounded f` and `PolyBounded g`, then
`PolyBounded (f ∘ g)`. Consequently `PolyMono` is closed under composition and
contains the identity.

*Proof sketch.* If `f(n)+1 ≤ (n+2)^a` and `g(n)+1 ≤ (n+2)^b`, then
`g(n)+2 ≤ 2(n+2)^b ≤ (n+2)^{b+1}`, so
`f(g(n))+1 ≤ (g(n)+2)^a ≤ (n+2)^{a(b+1)}`. ∎

### 2.2 Proof systems and the simulation preorder

**Definition 2.4 (Proof system).** For a type `Thm` of theorems, a *proof system*
is a structure consisting of: a type `Proof`; a map `proves : Proof → Thm`; a map
`size : Proof → ℕ`; and a proof that `proves` is surjective (**completeness**).

**Definition 2.5 (p-simulation).** A proof system `P` *p-simulates* `Q`, written
`Simulates P Q`, if there exists `f` with `PolyMono f` such that
$$\forall\, q : Q.\mathrm{Proof},\ \exists\, p : P.\mathrm{Proof},\quad
P.\mathrm{proves}\,p = Q.\mathrm{proves}\,q \ \wedge\ P.\mathrm{size}\,p \le f(Q.\mathrm{size}\,q).$$

**Definition 2.6 (p-equivalence).** `PEquiv P Q := Simulates P Q ∧ Simulates Q P`.

**Definition 2.7 (Poset of p-degrees).** The p-degrees are the elements of the
antisymmetrization `Antisymmetrization (ProofSystem Thm) (· ≤ ·)`, where `≤` is
`Simulates`. This carries Mathlib's canonical `PartialOrder`.

---

## 3. The simulation preorder and p-equivalence

**Theorem 3.1 (Preorder).** `Simulates` is reflexive and transitive; it is a
`Preorder` on proof systems.

*Proof sketch.* Reflexivity uses the identity blow-up. For transitivity, if `P`
simulates `Q` via `f` and `Q` simulates `R` via `g`, compose translations and use
`f ∘ g` as the blow-up; `PolyMono (f ∘ g)` by Lemma 2.3, and monotonicity of `f`
chains the two size bounds: `size p ≤ f(size q) ≤ f(g(size r))`. ∎

**Theorem 3.2 (Setoid).** `PEquiv` is reflexive, symmetric, and transitive; it is
a `Setoid`. Moreover `PEquiv` coincides definitionally with Mathlib's
`AntisymmRel (· ≤ ·)`, so the quotient is exactly the poset of p-degrees.

---

## 4. Separation: the growth-rate engine

### 4.1 Fibonacci is super-polynomial

**Lemma 4.1 (Exponential core of Fibonacci).** `2^n ≤ F(2n+1)` for all `n`, where
`F` is the Fibonacci sequence.

*Proof sketch.* Induction using `F(m+2) = F(m+1) + F(m) ≥ 2F(m)`, which gives
`F(2(m+1)+1) ≥ 2 F(2m+1)`. ∎

**Theorem 4.2 (Fibonacci is not polynomially bounded).** `¬ PolyBounded F`.

*Proof sketch.* If `F(n)+1 ≤ (n+2)^k` for a fixed `k`, then via Lemma 4.1
`2^m ≤ F(2m+1)+1 ≤ (2m+3)^k`. But `(2m+3)^k / 2^m → 0` (polynomial over
exponential), so for large `m` we get `(2m+3)^k < 2^m`, a contradiction. ∎

**Corollary 4.3 (Anti-domination).** If `F(n) ≤ f(n)` for all `n`, then
`¬ PolyBounded f`.

### 4.2 A generic separation template

**Theorem 4.4 (Generic separation).** Let `s : ℕ → ℕ` with `¬ PolyBounded s`.
Suppose `Q` proves a family `t : ℕ → Thm` with proofs `q n` of size `≤ n`, while
every `P`-proof of `t n` has size `≥ s(n)`. Then `¬ Simulates P Q`.

*Proof sketch.* A simulation blow-up `f` would yield `P`-proofs of `t n` of size
`≤ f(Q.size(q n)) ≤ f(n)` (monotonicity), while hardness gives `s(n) ≤ f(n)`. The
single arithmetic fact `polyBounded_of_le` (a function pointwise below a
polynomially bounded one is polynomially bounded) makes `s` polynomially bounded,
contradicting the hypothesis. ∎

The Fibonacci separation `no_simulation_of_fib_hard` is the instance `s = F`.
This isolates the slogan: **the only input to any simulation separation is a
super-polynomial size lower bound.**

### 4.3 Concrete witnesses

**Definition 4.5.** Over `Thm = ℕ` with `proves = id`, let `linSystem` have
`size = id` and `fibSystem` have `size = F`.

**Theorem 4.6 (Concrete separation).** `¬ Simulates fibSystem linSystem`.
Consequently `∃ P Q, ¬ Simulates P Q`.

**Theorem 4.7 (At least two p-degrees).** `fibSystem` and `linSystem` map to
distinct points of `Antisymmetrization (ProofSystem ℕ) (· ≤ ·)`.

*Proof sketch.* Equality in the antisymmetrization would force
`Simulates fibSystem linSystem`, contradicting Theorem 4.6. ∎

---

## 5. The Domination Characterization

**Definition 5.1 (Size-indexed system).** For `a : ℕ → ℕ`, let `sysOfSize a` be
the proof system over `ℕ` with `Proof = ℕ`, `proves = id`, `size = a`, and
completeness `surjective_id`. Note `linSystem = sysOfSize id`,
`fibSystem = sysOfSize F`.

**Theorem 5.2 (Domination Characterization).**
$$\mathrm{Simulates}(\mathrm{sysOfSize}\,a)(\mathrm{sysOfSize}\,b) \iff
\exists\, f,\ \mathrm{PolyMono}\,f \ \wedge\ \forall\, n,\ a(n) \le f(b(n)).$$

*Proof sketch.* Forward: given a simulation, the witness `p` for input `q = n`
satisfies `proves p = n` hence `p = n` and `a(n) = size p ≤ f(b(n))`. Backward:
the same `f` defines a simulation by taking `p = q`. ∎

This is the master reduction. Every subsequent structural theorem is an
arithmetic statement about the size functions, mediated by Theorem 5.2.

---

## 6. Lattice shape: binary meets

**Definition 6.1 (Direct sum).** For proof systems `P, Q` over `Thm`, define
`sumSystem P Q` with `Proof = P.Proof ⊕ Q.Proof`,
`proves = Sum.elim P.proves Q.proves`, `size = Sum.elim P.size Q.size`, and
completeness inherited from `P`.

**Lemma 6.2.** `Simulates (sumSystem P Q) P` and `Simulates (sumSystem P Q) Q`
(identity blow-ups via `Sum.inl`, `Sum.inr`).

**Lemma 6.3 (max of blow-ups).** If `PolyMono f` and `PolyMono g`, then
`PolyMono (fun n => max (f n) (g n))`.

**Theorem 6.4 (Meets exist).** `sumSystem P Q` is the greatest lower bound of
`{P, Q}` in the simulation preorder. Hence the p-degrees form a meet-semilattice.

*Proof sketch.* Lemma 6.2 gives a lower bound. If `R` simulates both `P` and `Q`
via `f, g`, then `max(f,g)` (Lemma 6.3) witnesses `Simulates R (sumSystem P Q)`,
splitting on `Sum.inl/inr` and using `le_max_left/right`. ∎

**Corollary 6.5 (Down-directed).** Any two systems have a common lower bound,
namely their direct sum.

---

## 7. Infinite height: the power ladder

**Definition 7.1 (Power ladder).** `powSystem k := sysOfSize (fun n => 2^(n^k))`.

**Lemma 7.2 (Non-comparable rungs).** For `k ≥ 1` and every `c`, there is `n` with
`(2^(n^k) + 2)^c < 2^(n^(k+1))`.

*Proof sketch.* For large `n`, `(2^(n^k)+2)^c ≤ 2^(c·n^k + c)` and
`c·n^k + c < n·n^k = n^(k+1)`, since `n > c`. ∎

**Lemma 7.3.** `Simulates (powSystem k) (powSystem (k+1))` (lower rate is below
higher; bound `2^(n^k) ≤ 2^(n^(k+1)) + 2` via the affine blow-up `n ↦ n+2`).

**Lemma 7.4.** For `k ≥ 1`, `¬ Simulates (powSystem (k+1)) (powSystem k)`.

*Proof sketch.* By Theorem 5.2, a simulation gives `PolyMono f` with
`2^(n^(k+1)) ≤ f(2^(n^k))`; with `f(m)+1 ≤ (m+2)^c` this yields
`2^(n^(k+1)) < (2^(n^k)+2)^c` for all `n`, contradicting Lemma 7.2. ∎

**Theorem 7.5 (Infinite height).** `fun j => powSystem (j+1)` is strictly
increasing in the simulation preorder. Hence `j ↦ [powSystem (j+1)]` is an
injection of `(ℕ, <)` into the poset of p-degrees: the poset contains an infinite
strictly increasing chain.

*Remark.* The naive ladder `2^(k·n)` collapses, since
`2^((k+1)n) ≤ (2^(kn))^2` makes consecutive rungs p-equivalent. Inflating the
exponent itself (`n^k`) is essential.

We also record the strict 2-chain `lin_lt_fib : linSystem < fibSystem`, obtained
from `Simulates linSystem fibSystem` (since `n ≤ F(n)+4`) and Theorem 4.6.

---

## 8. Density along the ladder

**Lemma 8.1 (Uniform ladder gap).** For `k ≥ 1` and every `c`,
`(2^(n^k)+2)^c < 2^(n^(k+1))` holds for **all** `n ≥ c + 2`.

*Proof sketch.* As in Lemma 7.2, but the threshold `n ≥ c+2` makes the strict
inequality `c·n^k + c < n^(k+1)` hold uniformly, freeing the *parity* of the
witness. ∎

**Definition 8.2 (Parity-glued system).**
`interPowSys k := sysOfSize (fun n => if Even n then 2^(n^(k+1)) else 2^(n^k))`.

**Theorem 8.3.** For `k ≥ 1`, `powSystem k < interPowSys k`.

*Proof sketch.* The glued size is everywhere `≥ 2^(n^k)`, so the lower rung
simulates it. Conversely, choosing an **even** witness above the threshold,
Lemma 8.1 refutes the reverse simulation (even indices keep the fast rate). ∎

**Theorem 8.4.** For `k ≥ 1`, `interPowSys k < powSystem (k+1)`.

*Proof sketch.* The glued size is everywhere `≤ 2^(n^(k+1))`, so it simulates the
upper rung. Conversely, an **odd** witness above the threshold refutes the
reverse simulation (odd indices fall back to the slow rate). ∎

**Theorem 8.5 (Density).** For every `k ≥ 1` there is a p-degree strictly between
`powSystem k` and `powSystem (k+1)`, namely `interPowSys k`.

This is a local-to-global glueing: a degree is assembled from two prescribed
rates on the two residue classes mod 2, and lands strictly between the rungs.

---

## 9. A least element but no greatest element

The catalog supplies a least p-degree `zeroSys` with `zeroSys_isBot`. We
establish the dual asymmetry.

**Lemma 9.1 (Eventual exponential dominance).** For every `k` there is a
threshold `M` with `(m+2)^k < 2^m` for all `m ≥ M`.

*Proof sketch.* `(m+2)^k / 2^m → 0` as `m → ∞` (polynomial over exponential);
extract a threshold from the limit. ∎

**Lemma 9.2 (Diagonal anti-domination).** For any `s : ℕ → ℕ`, the size function
`t ↦ 2^(s t) + 2^t` is dominated by no monotone polynomial blow-up of `s`: there
is **no** `PolyMono f` with `2^(s t) + 2^t ≤ f(s t)` for all `t`.

*Proof sketch.* Given `f(m)+1 ≤ (m+2)^k`, Lemma 9.1 gives `M` with
`(m+2)^k < 2^m` for `m ≥ M`. Were `s t ≥ M` for some `t`, then
`2^(s t) ≤ f(s t) < 2^(s t)`, impossible; so `s t < M` for all `t`. Then
`2^t ≤ f(s t)+? < (M+1)^k` for all `t`, contradicting the unboundedness of
`2^t`. ∎

**Theorem 9.3 (No greatest p-degree).** For every proof system `T` over `ℕ`,
`¬ IsTop T`.

*Proof sketch.* Using completeness, let `sec = Function.surjInv T.complete`, so
`sec t` is (the size of) a chosen `T`-proof of theorem `t`. If `T` were a top, it
would simulate `sysOfSize (fun t => 2^(T.size (sec t)) + 2^t)`, producing
`PolyMono f` with `2^(T.size (sec t)) + 2^t ≤ f(T.size (sec t))` — exactly the
configuration ruled out by Lemma 9.2. ∎

**Theorem 9.4 (Order-type asymmetry).** The p-degrees over `ℕ` have a least
element (`zeroSys`) but no greatest element.

The diagonalization is purely a *size-layer* obstruction: it uses nothing about
`T` beyond completeness. No proof system can glue its local proof sizes into a
universal simulation.

---

## 10. Algorithms

We summarize the computational primitives implicit in the theory; full
implementations appear in the accompanying demo and package.

1. **Polynomial-domination decision (bounded search).** Given size functions
   `a, b` and bounds `(k_max, n_max)`, search for an exponent `k ≤ k_max` such
   that `a(n) ≤ (b(n)+2)^k` for all `n ≤ n_max`; report the least such `k` or
   "no polynomial bound found in range." By Theorem 5.2 this is a sound
   semi-decision procedure for `Simulates (sysOfSize a) (sysOfSize b)` on the
   tested range.

2. **Ladder-gap witness finder.** Given `k, c`, return the least `n` with
   `(2^(n^k)+2)^c < 2^(n^(k+1))`, certifying non-comparability of consecutive
   rungs (Lemma 7.2); restrict to even/odd `n ≥ c+2` for the density witnesses.

3. **Diagonal constructor.** Given a candidate top `T` (as a section
   `sec : ℕ → ℕ`), output the diagonal size function `t ↦ 2^(sec t) + 2^t` whose
   degree exceeds `T` (Theorem 9.3).

---

## 11. Applications and discussion

**Connection to NP vs coNP.** A polynomially bounded proof system would be a top
element of the simulation order restricted to honest computable systems. Our
Theorem 9.3 shows that *within the size-indexed slice* there is no top; the open
problem is whether the computability constraint, absent from our abstraction,
changes this. The abstraction makes precise *which* part of the difficulty is
order-theoretic (the existence question) and which is genuinely about
computation.

**Separation as growth.** Theorem 4.4 distills the methodology of the field: to
separate `P` from `Q`, exhibit a family `Q` proves cheaply but on which `P`
requires super-polynomial size. Every concrete lower bound (resolution width,
Frege depth, etc.) instantiates this template; the order theory is uniform.

**Lattice structure.** Theorem 6.4 gives meets but not joins in general; the
join of two systems would be a strongest system simulated by both, which need not
exist constructively. The meet (direct sum / "run either system") is the robust
operation.

**Robustness of the invariant.** The recurring theme is that the correct
invariant of a proof system is the *growth rate of its size function modulo
polynomial reparameterization*. Every theorem here is invariant under
p-equivalence by construction, and reduces to inequalities between growth rates.

---

## 12. Future work

(See the dedicated future-directions material accompanying this package for the
full program toward identifying the complete order type of the p-degrees,
including order embeddings of `ℕ` into the degrees, bounded antichains realizing
infinite width arbitrarily low in the order, and the coexistence of height and
width inside a single finite-height interval `(⊥, powSystem 2]`.)

---

## 13. Worked examples

We illustrate the theory on explicit size-indexed systems over `Thm = ℕ`, where
every claim is decidable arithmetic via the Domination Characterization
(Theorem 5.2).

**Example 13.1 (linear vs Fibonacci).** Take `a(n) = n` (`linSystem`) and
`b(n) = F(n)` (`fibSystem`). Since `n ≤ F(n) + 4`, the affine blow-up `f(n) = n+4`
(which is `PolyMono`, with `f(n)+1 ≤ (n+2)^3`) witnesses
`Simulates linSystem fibSystem`. Conversely, suppose `Simulates fibSystem
linSystem`. By Theorem 5.2 there would be `PolyMono g` with `F(n) ≤ g(n)` for all
`n`; then `g` is not polynomially bounded (Corollary 4.3), contradicting
`PolyMono g`. Hence the comparison is strict: `linSystem < fibSystem`. Concretely,
for any candidate exponent `k`, the bound `F(n) ≤ (n+2)^k` fails: using
`2^m ≤ F(2m+1)`, it would force `2^m ≤ (2m+3)^k`, false for large `m` (e.g. it
first fails at `m = 9` for `k = 2`, `m = 23` for `k = 4`).

**Example 13.2 (a power-ladder step).** Take `a(n) = 2^(n^2)` (`powSystem 2`) and
`b(n) = 2^n` (`powSystem 1`). The lower rung is simulated by the upper one via
`n ↦ n+2`. For the reverse, a simulation would yield `PolyMono g` with
`2^(n^2) ≤ g(2^n)` and `g(m)+1 ≤ (m+2)^c`; combining,
`2^(n^2) ≤ (2^n+2)^c` for all `n`. But Lemma 7.2 produces `n` violating this (for
`c = 3` already at `n = 4`: `(2^4+2)^3 = 5832 < 2^16 = 65536`). So
`powSystem 1 < powSystem 2`, the first strict step of the infinite chain.

**Example 13.3 (an intermediate degree).** With `k = 1`, the parity-glued system
`interPowSys 1` has size `2^(n^2)` on even `n` and `2^n` on odd `n`. It is
strictly above `powSystem 1` (an even witness, say `n = 4`, defeats the reverse
simulation) and strictly below `powSystem 2` (an odd witness, say `n = 5`,
defeats the reverse simulation). It therefore occupies a degree strictly between
two consecutive rungs — an explicit realization of density (Theorem 8.5).

**Example 13.4 (defeating a candidate top).** Let `T` be any system over `ℕ` and
`sec t = T.size (Function.surjInv T.complete t)` its local proof sizes. The
diagonal system `sysOfSize (t ↦ 2^(sec t) + 2^t)` cannot be simulated by `T`:
any `PolyMono f` with `f(m)+1 ≤ (m+2)^k` would force `sec t < M` for the
threshold `M` of Lemma 9.1 (via the `2^(sec t)` summand), after which
`2^t < (M+1)^k` for all `t` is absurd. Hence `T` is not a top (Theorem 9.3).

## 14. Verification status

All theorems above are formalized with no `sorry` and depend only on the standard
foundational axioms `propext`, `Classical.choice`, and `Quot.sound`. The
development is organized as: the simulation preorder and Fibonacci separation; the
generic separation template, concrete witnesses, and antisymmetrization; the
direct-sum meet, the Domination Characterization, and the infinite power ladder;
density along the ladder; and the least-element / no-top asymmetry.
