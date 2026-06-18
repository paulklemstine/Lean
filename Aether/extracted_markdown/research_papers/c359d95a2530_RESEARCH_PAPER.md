# The Order-Theoretic Core of the Cook–Reckhow Program: Simulation Preorder, Lattice Structure, Density, and Holographic Proof Metrics

## Abstract

We develop, in a fully formal and self-contained way, the order-theoretic foundations of
the Cook–Reckhow theory of propositional proof systems. Abstracting a proof system away
from its computability layer to a completeness-witnessing map equipped with a size
function, we define the **p-simulation preorder** and prove it is a genuine preorder whose
antisymmetrization is the **poset of p-degrees**. We establish: (i) a concrete two-point
separation driven by the super-polynomiality of Fibonacci growth; (ii) the existence of
binary meets via the direct-sum proof system, exhibiting the order as down-directed; (iii)
an exact arithmetic characterization of simulation for size-indexed systems as *polynomial
domination of size functions*; (iv) an infinite strictly increasing chain of power-tower
systems, proving the poset has infinite height; (v) a **density theorem** producing a
p-degree strictly between every pair of consecutive ladder rungs via a parity-glued
construction; and (vi) a **holographic** Lipschitz law for proof metrics, with an
exactness result on the chain theory. All results are constructive and have been verified
in a proof assistant, depending only on the standard foundational axioms.

---

## 1. Introduction

The Cook–Reckhow framework (1979) is the standard abstract setting for propositional proof
complexity. A propositional proof system is a polynomial-time surjection from strings
("proofs") onto the set of tautologies ("theorems"). The central structural question — *is
there a proof system that p-simulates every other?* — is equivalent to NP = coNP, and so
sits among the foundational open problems of complexity theory.

This paper isolates and develops the *order-theoretic core* of that program. We deliberately
strip the computability layer: a proof system becomes a surjective map `proves : Proof →
Thm` together with a size function `size : Proof → ℕ`. What remains is precisely the data
needed to define and study the simulation order. Within this clean setting we prove a suite
of structural theorems describing the geometry of the poset of p-degrees, and we add a
metric/holographic layer modeling proof distance under translation.

The contributions are organized as follows. Section 2 fixes the polynomial blow-up class
and the proof-system structure. Section 3 builds the simulation preorder and p-equivalence.
Section 4 establishes a concrete separation from Fibonacci growth. Section 5 constructs
binary meets. Section 6 gives the domination characterization and the infinite ladder.
Section 7 proves density. Section 8 develops holographic proof metrics. Sections 9–11
discuss algorithms, applications, and future work.

---

## 2. Preliminaries: the blow-up class and proof systems

### 2.1 Polynomially bounded blow-ups

**Definition 2.1 (PolyBounded).** A function `f : ℕ → ℕ` is *polynomially bounded* if there
is an exponent `k : ℕ` with
```
f n + 1 ≤ (n + 2)^k   for all n.
```
The base `n + 2` (rather than `n`) removes the `n = 0` corner case and makes the class
closed under composition without side conditions.

**Definition 2.2 (PolyMono).** A function `f` is a *blow-up* if it is monotone **and**
polynomially bounded: `PolyMono f := Monotone f ∧ PolyBounded f`.

**Lemma 2.3 (Identity).** `id` is a blow-up. *(Take `k = 1`.)*

**Lemma 2.4 (Composition closure).** If `f` and `g` are polynomially bounded, so is
`n ↦ f(g n)`.

*Proof sketch.* If `f m + 1 ≤ (m+2)^a` and `g n + 1 ≤ (n+2)^b`, then `g n + 2 ≤
2·(n+2)^b ≤ (n+2)^(b+1)`, so
`f(g n) + 1 ≤ (g n + 2)^a ≤ ((n+2)^(b+1))^a = (n+2)^(a(b+1))`. ∎

**Lemma 2.5.** Blow-ups are closed under composition: `PolyMono f → PolyMono g →
PolyMono (f ∘ g)`. *(Monotonicity composes; apply Lemma 2.4.)* Monotonicity is the
property that makes transitivity of simulation go through.

### 2.2 Abstract proof systems

**Definition 2.6 (ProofSystem).** For a theorem type `Thm`, a *proof system* consists of a
type `Proof`, a map `proves : Proof → Thm`, a map `size : Proof → ℕ`, and a proof that
`proves` is surjective (*completeness*: every theorem has a proof).

This is the Cook–Reckhow notion with the polynomial-time computability requirement
abstracted into the explicit `size` function and the blow-up class of Section 2.1.

---

## 3. The simulation preorder and the poset of p-degrees

**Definition 3.1 (Simulates).** For proof systems `P, Q` over the same `Thm`, `P`
**p-simulates** `Q`, written `Simulates P Q` (and `P ≥ Q` in the order), iff there is a
blow-up `f` with
```
∀ q : Q.Proof, ∃ p : P.Proof,  P.proves p = Q.proves q  ∧  P.size p ≤ f (Q.size q).
```
That is, every Q-proof is translatable to a P-proof of the *same* theorem with at most a
polynomial increase in size.

**Theorem 3.2 (Preorder).** `Simulates` is reflexive and transitive, hence a preorder.

*Proof sketch.* Reflexivity uses the identity blow-up (Lemma 2.3): each proof simulates
itself. Transitivity composes blow-ups: given `Simulates P Q` via `f` and `Simulates Q R`
via `g`, the witness for `Simulates P R` is `f ∘ g`, which is a blow-up by Lemma 2.5; the
size bound chains by monotonicity of `f`. ∎

**Definition 3.3 (p-equivalence).** `PEquiv P Q := Simulates P Q ∧ Simulates Q P`.

**Theorem 3.4.** `PEquiv` is an equivalence relation (reflexive, symmetric, transitive),
i.e. a `Setoid` on proof systems.

**Definition 3.5 (p-degrees).** The **poset of p-degrees** is the antisymmetrization of the
simulation preorder, `Antisymmetrization (ProofSystem Thm) (· ≤ ·)`, carrying the induced
partial order. By **Theorem 3.6**, `PEquiv P Q ↔ AntisymmRel (· ≤ ·) P Q`, so p-degrees are
exactly the p-equivalence classes.

---

## 4. A concrete separation from Fibonacci growth

### 4.1 Super-polynomiality of Fibonacci

**Lemma 4.1 (Exponential lower bound).** `2^n ≤ F(2n+1)` for all `n`, where `F` is the
Fibonacci sequence.

*Proof sketch.* From `F(m+2) = F(m+1) + F(m) ≥ 2·F(m)`, induction gives
`F(2n+1) ≥ 2^n · F(1) = 2^n`. ∎

**Theorem 4.2 (Fibonacci is not polynomially bounded).** `¬ PolyBounded F`.

*Proof sketch.* Suppose `F n + 1 ≤ (n+2)^k` for all `n`. Specializing at `n = 2m+1` and
using Lemma 4.1 gives `2^m ≤ (2m+3)^k`. But `m ↦ (2m+3)^k / 2^m → 0` (a polynomial divided
by an exponential, via the standard little-o estimate
`isLittleO_pow_const_const_pow_of_one_lt`), so for large `m` we get `(2m+3)^k < 2^m`, a
contradiction. ∎

**Corollary 4.3 (No polynomial domination).** If `F n ≤ f n` for all `n`, then `f` is not
polynomially bounded. *(Otherwise `F` would be too.)*

### 4.2 The separation theorem

**Theorem 4.4 (Separation via Fibonacci lower bounds).** Let `P, Q` be proof systems, let
`t : ℕ → Thm` be a family of theorems, and suppose:
- `Q` proves each `t n` with a proof `q n` of size `≤ n`;
- every `P`-proof of `t n` has size `≥ F n`.

Then `P` does **not** p-simulate `Q`.

*Proof sketch.* A simulation with blow-up `f` would yield, for each `n`, a `P`-proof of
`t n` of size `≤ f(Q.size(q n)) ≤ f n` (monotonicity), but also `≥ F n`; hence `F n ≤ f n`
for all `n`. By Corollary 4.3, `f` is not polynomially bounded — contradicting that it is a
blow-up. ∎

### 4.3 The linear vs. Fibonacci systems

**Definition 4.5.** Over `Thm = ℕ` with `proves = id`:
- `linSystem` has `size = id` (`size(n) = n`);
- `fibSystem` has `size = F` (`size(n) = F(n)`).

**Theorem 4.6 (Concrete separation).** `¬ Simulates fibSystem linSystem`.

*Proof sketch.* Instantiate Theorem 4.4 with `t = q = id`: `linSystem` proves `n` in size
`n`, while the only `fibSystem`-proof of `n` has size `F n`. ∎

**Theorem 4.7 (Non-trivial poset).** `fibSystem` and `linSystem` map to *distinct* points
of the poset of p-degrees. Hence the order has at least two elements.

---

## 5. Binary meets: the direct-sum proof system

**Definition 5.1 (Direct sum).** For `P, Q` over `Thm`, the **direct sum** `P ⊕ Q` has
`Proof := P.Proof ⊕ Q.Proof`, with `proves` and `size` read off componentwise
(`Sum.elim`). Completeness is inherited from `P`.

**Lemma 5.2 (Max closure).** If `f, g` are blow-ups, so is `n ↦ max(f n, g n)`. *(Monotone
as a max of monotones; polynomially bounded with exponent `k₁ + k₂ + 1`.)*

**Lemma 5.3.** `P ⊕ Q` p-simulates both `P` and `Q` (inject via `Sum.inl` / `Sum.inr` with
the identity blow-up).

**Lemma 5.4 (Universal property).** If `R` simulates both `P` and `Q` (via `f₁, f₂`), then
`R` simulates `P ⊕ Q` via the blow-up `n ↦ max(f₁ n, f₂ n)` (Lemma 5.2).

**Theorem 5.5 (Binary meets exist).** `P ⊕ Q` is the greatest lower bound of `{P, Q}` in
the simulation preorder: `IsGLB {P, Q} (P ⊕ Q)`. Consequently the poset of p-degrees has
binary meets.

**Theorem 5.6 (Down-directed).** Any two proof systems have a common lower bound (their
direct sum); the simulation preorder is down-directed.

---

## 6. Size-indexed systems, the domination law, and infinite height

### 6.1 The master reduction

**Definition 6.1 (sysOfSize).** For `a : ℕ → ℕ`, the system `sysOfSize a` over `ℕ` has
`proves = id` and `size = a`. (Thus `linSystem = sysOfSize id`, `fibSystem = sysOfSize F`.)

**Theorem 6.2 (Domination characterization).**
```
Simulates (sysOfSize a) (sysOfSize b)  ↔  ∃ f, PolyMono f ∧ ∀ n, a n ≤ f (b n).
```
*Proof sketch.* Forward: the simulation witness `f` works directly because `proves = id`
forces the simulating proof of `n` to be `n` itself, so its size is `a n ≤ f(b n)`.
Backward: the same `f` exhibits a simulation. ∎

This reduces every question about simulation between size-indexed systems to a purely
arithmetic question about *polynomial domination of size functions*, the engine for all
that follows.

### 6.2 The strict 2-chain

**Theorem 6.3.** `linSystem < fibSystem` strictly: `linSystem` simulates `fibSystem`
(`n ≤ F n + 4`, a linear bound) but not conversely (Theorem 4.6). Thus the poset has height
≥ 2.

### 6.3 The power-tower ladder

**Definition 6.4 (powSystem).** `powSystem k := sysOfSize (n ↦ 2^(n^k))`.

**Lemma 6.5 (Ladder gap).** For `k ≥ 1` and every exponent `c`, there exists `n` with
```
(2^(n^k) + 2)^c < 2^(n^(k+1)).
```
*Proof sketch.* `(2^(n^k)+2)^c ≤ 2^(c(n^k+1))`, and the exponent `c(n^k+1)` is beaten by
`n^(k+1) = n·n^k` once `n` exceeds a threshold (e.g. `n = c+2`), since the extra factor `n`
overtakes the constant `c`. ∎

**Lemma 6.6.** `powSystem k` simulates `powSystem (k+1)` (because `2^(n^k) ≤ 2^(n^(k+1)) +
2`), but for `k ≥ 1` the converse fails by Lemma 6.5 and Theorem 6.2.

**Theorem 6.7 (Strict ladder step).** For `k ≥ 1`, `powSystem k < powSystem (k+1)`.

**Theorem 6.8 (Infinite height).** `j ↦ powSystem (j+1)` is strictly increasing, and its
image consists of *distinct* p-degrees (the map `j ↦ [powSystem (j+1)]` into the
antisymmetrization is injective). Hence the poset of p-degrees contains an infinite
strictly increasing chain.

---

## 7. Density of the ladder

The infinite ladder might suggest a discrete spectrum of degrees. It is not: the order is
dense along the ladder.

**Lemma 7.1 (Uniform ladder gap).** For `k ≥ 1` and every `c`,
`(2^(n^k) + 2)^c < 2^(n^(k+1))` holds for **all** `n ≥ c + 2` (a *uniform* strengthening of
Lemma 6.5, valid on a whole tail rather than at a single witness).

**Definition 7.2 (Parity-glued system).**
```
interPowSys k := sysOfSize (n ↦ if Even n then 2^(n^(k+1)) else 2^(n^k)).
```
It runs at the *upper* rate on even indices and the *lower* rate on odd indices.

**Theorem 7.3.** For `k ≥ 1`, `powSystem k < interPowSys k`.

*Proof sketch.* Simulation `powSystem k ≤ interPowSys k` holds because the glued size is
everywhere `≥ 2^(n^k)`. The strictness (no reverse simulation) uses Lemma 7.1 at an *even*
witness `n`, where the glued system runs at the faster upper rate that the lower rung cannot
polynomially match. ∎

**Theorem 7.4.** For `k ≥ 1`, `interPowSys k < powSystem (k+1)`.

*Proof sketch.* Simulation `interPowSys k ≤ powSystem (k+1)` holds because the glued size is
everywhere `≤ 2^(n^(k+1))`. The strictness uses Lemma 7.1 at an *odd* witness
`n = 2(c+2)+1`, where the glued system falls back to the slower lower rate, which cannot
polynomially reproduce the upper rung's relentless cost. ∎

**Theorem 7.5 (Density).** For every `k ≥ 1` there is a p-degree `S` with
```
powSystem k  <  S  <  powSystem (k+1),
```
namely `S = interPowSys k`. Consecutive rungs of the ladder are never adjacent.

---

## 8. Holographic proof metrics

We now equip theories with a metric and study how it transforms under translation.

**Definition 8.1 (Implicational theory).** An `ImplTheory α` is a relation `T : α → α → Prop`
("one axiom step"). Its **derivability** relation `Derivable T` is the reflexive-transitive
closure `ReflTransGen T`. A length-graded derivation `DerivOfLen T a b k` is a path of
exactly `k` steps from `a` to `b`.

**Definition 8.2 (Proof metric).** `minDerivLen T a b := sInf { k | DerivOfLen T a b k }`,
the length of the shortest derivation — i.e. the graph distance in the axiom-step graph.

**Definition 8.3 (Chain theory).** `chainT a b := (b = a + 1)`: the path `0 → 1 → 2 → ⋯`.

**Theorem 8.4 (Chain metric).** For `a ≤ b`, `minDerivLen chainT a b = b - a`. *(The unique
derivation walks up one step at a time.)*

**Definition 8.5 (Translation).** A *translation* `T → S` is a map `map : α → β` with a
*stretch* `stretch : ℕ` such that every axiom step `T a b` is realized by a target
derivation `DerivOfLen S (map a) (map b) j` of length `j ≤ stretch`. This is the
length-graded, system-to-system morphism abstracting p-simulation on the metric side.

**Theorem 8.6 (Holographic propagation — Lipschitz functoriality).** If `φ` realizes each
source axiom step by an `S`-derivation of length `≤ L`, then every length-`k` source
derivation `a ⊢ b` maps to a target derivation `φ a ⊢ φ b` of length `≤ L·k`.

*Proof sketch.* Induction on the source derivation. The empty derivation maps to `refl`
(length `0 ≤ L·0`). Each additional axiom step contributes a target sub-derivation of
length `≤ L`, composed with the running derivation; the running bound advances from `L·k` to
`L·k + L = L·(k+1)`. ∎

**Theorem 8.7 (Boundary shadow — the metric is L-Lipschitz).** Under a stretch-`L`
translation `φ`, whenever `a ⊢ b` is derivable,
```
minDerivLen S (φ a) (φ b)  ≤  L · minDerivLen T a b.
```
*Proof sketch.* Realize the minimal source derivation (`sInf` is attained since the set is
nonempty), push it through Theorem 8.6 to a target derivation of length `≤ L · minDerivLen
T a b`, and bound the target infimum above by that length. ∎

**Theorem 8.8 (Compositionality).** A stretch-`L` translation `T → S` (via `φ`) followed by
a stretch-`M` translation `S → U` (via `ψ`) realizes each source axiom step by a
`U`-derivation of length `≤ M·L`. *(Stretches multiply — the metric form of transitivity of
simulation, derived from Theorem 8.6 rather than reproved.)*

**Theorem 8.9 (Holographic exactness on the chain).** The doubling map `n ↦ 2n` is a
stretch-2 translation of `chainT`, and for `a ≤ b`,
```
minDerivLen chainT (2a) (2b)  =  2 · minDerivLen chainT a b.
```
*Proof sketch.* Both sides evaluate via Theorem 8.4: the left is `2b - 2a` and the right is
`2(b - a)`, equal by arithmetic. ∎ Thus the Lipschitz bound of Theorem 8.7 is *attained* on
the chain: it is the extremal, zero-slack proof geometry.

---

## 9. Algorithms

The theory is constructive and yields directly executable procedures over size-indexed
systems (`sysOfSize`), where simulation reduces to polynomial domination (Theorem 6.2).

1. **Polynomial-domination tester.** Given size functions `a, b` and a candidate exponent
   bound, search for an exponent `k` and constant witnessing `a n ≤ ((b n)+2)^k` on a finite
   prefix; absence of a bound (as `n` grows) certifies separation. (Used to *witness*
   Theorems 4.6, 6.7.)

2. **Ladder-gap witness finder.** Given `k ≥ 1` and exponent `c`, return the threshold
   `n = c + 2` past which `(2^(n^k)+2)^c < 2^(n^(k+1))` (Lemma 7.1), the explicit certificate
   of strictness.

3. **Density constructor.** Given consecutive rungs `powSystem k` and `powSystem (k+1)`,
   output the interpolating size function of `interPowSys k` and the even/odd witnesses
   verifying both strict inequalities (Theorem 7.5).

4. **Proof-metric / holography evaluator.** On a finite implicational theory, compute
   `minDerivLen` by breadth-first search and verify the Lipschitz bound `minDerivLen S (φ a)
   (φ b) ≤ L · minDerivLen T a b` for a given translation (Theorems 8.6–8.9).

---

## 10. Applications and discussion

- **Geography of proof complexity.** Every concrete separation (resolution vs. cutting
  planes, bounded-depth Frege vs. Frege, …) is the assertion that two specific points of
  this poset fail to simulate one another. The structural theorems here (preorder, meets,
  infinite height, density, holography) describe the universal terrain in which such
  results live.

- **The Cook–Reckhow question.** Existence of a p-optimal proof system (one that simulates
  all others) is equivalent to NP = coNP. Our results show the order is at least
  down-directed (meets exist) and of infinite height with dense ladders — structural
  features any candidate optimal system must dominate.

- **Holography as a design principle.** Theorem 8.6 says fine-grained ("bulk") derivation
  structure controls coarse ("boundary") proof distance with a multiplicative stretch
  constant; Theorem 8.9 identifies the chain as the tight case. This is a clean, reusable
  bridge between length-graded proof theory and metric geometry on graphs.

- **Robustness of the abstraction.** Because the polynomial blow-up class is closed under
  composition and pointwise maximum (Lemmas 2.4, 5.2), the order theory is insensitive to
  the precise polynomial-time details that the Cook–Reckhow definition usually carries.

---

## 11. Future work

The natural next layer is a full *representation and duality* theory of p-degrees, lifting
the size-indexed picture to abstract lattice operations:

- Identify abstract meets and joins of size-degrees with *pointwise* minimum and maximum of
  growth functions, reconciling the direct-sum ("run-both") meet with the pointwise-minimum
  meet up to p-equivalence (uniqueness of greatest lower bounds).
- Prove the size-degrees form a **distributive lattice** with operations computed
  pointwise — a duality dictionary translating order-theoretic statements about p-degrees
  into arithmetic statements about growth rates, with the join-of-blow-ups algebra
  (`max` closure) as the only nontrivial ingredient.
- Establish that the simulation preorder has **no top element** (no weakest degree) by a
  single diagonalization: against any candidate section `s` of a system's proof sizes, the
  size-indexed system `2^(s n) + n` escapes every polynomial blow-up of `s`, unifying the
  bounded- and unbounded-section regimes into one witness ("exponential eventually beats
  polynomial").

These would complete the order-type analysis: a distributive, down-directed, dense,
infinitely tall poset of p-degrees with no top, fully dual to the arithmetic of growth
rates.

---

## 12. Formalization note

All definitions and theorems above have been formally verified in the Lean proof
assistant, with no unproved placeholders, depending only on the standard foundational
axioms (`propext`, `Classical.choice`, `Quot.sound`). The development comprises the
simulation preorder and p-degrees, the Fibonacci separation, the direct-sum meet, the
domination law and power-tower ladder, the density theorem, and the holographic proof
metric.
