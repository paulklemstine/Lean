# The Order-Theoretic Core of the Cook–Reckhow Program: Meets, Height, and the Poset of p-Degrees

## Abstract

The Cook–Reckhow framework recasts the comparison of proof systems as an ordering
by *polynomial simulation*: one system is at least as strong as another when it
can re-derive every theorem of the other with at most a polynomial blow-up in
proof size. Antisymmetrizing this preorder produces the **poset of p-degrees**,
an efficiency-aware analogue of the Turing degrees. This paper develops the
order-theoretic core of that poset. We work with an abstract notion of proof
system (a type of proofs equipped with a conclusion map, a size function, and a
completeness witness) and the simulation relation defined through monotone,
polynomially bounded *blow-up functions*. Our central technical device is the
**domination characterization**: for size-indexed systems over `ℕ`, simulation is
*exactly* polynomial domination of size functions. From this single reduction we
extract four structural results. (1) **Meets exist**: the direct-sum system is the
greatest lower bound of any pair, so the p-degrees form a meet-semilattice and the
simulation preorder is down-directed. (2) **A strict separation**: the linear
degree lies strictly below the Fibonacci degree. (3) **Infinite height**: the cost
functions `n ↦ 2^(n^k)` form an infinite strictly increasing chain, and these
descend to genuinely distinct p-degrees. (4) A diagnosis of why the natural
exponential ladder `2^(kn)` *collapses*, clarifying the right invariant. We
situate these results within a broader program — least elements, infinite
antichains (width), density, and the failure of joins — and indicate the route
toward determining the full order type of the p-degrees. All results are
formalized and machine-checked.

---

## 1. Introduction

Cook and Reckhow (1979) observed that the existence of a polynomially bounded
proof system for the propositional tautologies is equivalent to NP = coNP. This
turned the informal comparison of proof methods into a precise mathematical order
and launched proof complexity as a quantitative discipline. The objects of study
are *proof systems*; the morphisms of interest are *polynomial simulations*; and
the resulting structure is a preorder on systems whose antisymmetrization we call
the **poset of p-degrees**.

The analogy with computability theory is exact in spirit. There, the Turing
reducibility preorder antisymmetrizes to the Turing degrees, whose order type has
been studied for decades. Here, polynomial simulation antisymmetrizes to the
p-degrees, whose order type is comparatively uncharted. The questions are the same
in form: Is there a least degree? A greatest? How tall are the chains (height)?
How wide are the antichains (width)? Are there meets and joins? Is the order
dense? Is it total?

This paper answers several of these questions for an abstract, fully formalized
model and isolates the *engine* — the domination characterization — that makes the
rest routine. The philosophy is that **order-theoretic facts about proof power
reduce to growth-rate facts about size functions**, and that almost the entire
order-theoretic core can be derived from this reduction together with one analytic
input (exponential beats polynomial).

### Contributions

1. A clean abstract model of proof systems and the simulation preorder via
   monotone polynomial blow-up functions (Section 3).
2. The **domination characterization** `simulates_sysOfSize_iff` reducing
   simulation between size-indexed systems to polynomial domination (Section 4).
3. **Meets**: the direct-sum construction is the greatest lower bound; the
   p-degrees form a meet-semilattice (Section 5).
4. The **linear/Fibonacci separation** as a strict 2-chain (Section 6).
5. **Infinite height** via the polynomial-exponent ladder `2^(n^k)`, plus a
   failure analysis of the collapsing ladder `2^(kn)` (Section 7).
6. A synthesis with the surrounding program — bottom element, infinite width,
   density, failure of joins — and the path to the full order type (Sections 8–9).

---

## 2. Related Work and Context

The qualitative theory of proof systems — comparison by mere provability,
realized by union (join) and intersection (meet) of proof objects, with a
completeness/soundness maximality phenomenon at the top — is the backdrop against
which the quantitative refinement lives. In that qualitative world a system is a
type of proofs with a conclusion map and a size, provability is existence of a
proof with a given conclusion, simulation is set-inclusion of provable formulas,
and union/intersection give a genuine lattice. The Cook–Reckhow refinement keeps
the proof objects honest (carrying sizes) so that the *quantitative* blow-up can
be transported. This paper is concerned exclusively with the quantitative order.

---

## 3. The Model

### 3.1 Proof systems

> **Definition 3.1 (Proof system).** A *proof system* over a type `Thm` of
> theorems is a structure
> ```
> structure ProofSystem (Thm : Type u) where
>   Proof    : Type v
>   proves   : Proof → Thm
>   size     : Proof → ℕ
>   complete : ∀ t : Thm, ∃ p : Proof, proves p = t
> ```
> i.e. a type of proof objects, a map recording which theorem each proof
> establishes, a size (resource cost) function, and a completeness witness
> guaranteeing every theorem has at least one proof.

The completeness field is the abstract stand-in for "the system proves all the
truths we care about"; the quantitative theory then asks *how large* those proofs
must be.

### 3.2 Polynomial blow-up functions

Polynomial simulation is mediated by admissible "slow-down" functions on sizes.

> **Definition 3.2 (Monotone polynomial blow-up).** A function `f : ℕ → ℕ`
> is a *monotone polynomial blow-up*, written `PolyMono f`, if `f` is monotone and
> polynomially bounded in the explicit monomial sense:
> ```
> PolyMono f  :≡  Monotone f ∧ ∃ k : ℕ, ∀ n, f n + 1 ≤ (n + 2) ^ k.
> ```

The shift to `n + 2` and the `+1` avoid degenerate base cases (`0^0`, `1^k`) and
make the class robustly closed under the operations we need. The identity map is a
blow-up (`polyMono_id`).

> **Lemma 3.3 (Closure under pointwise max).** If `PolyMono f` and `PolyMono g`,
> then `PolyMono (fun n => max (f n) (g n))`.
>
> *Proof sketch.* Monotonicity of the max is immediate from monotonicity of each
> argument. For the polynomial bound, take exponents `k₁, k₂` witnessing the
> bounds for `f, g`; then `k₁ + k₂ + 1` works for the max, since
> `(n+2)^{k₁}, (n+2)^{k₂} ≤ (n+2)^{k₁+k₂+1}` and `max(f n, g n) + 1` is bounded by
> whichever of the two bounds is larger. ∎

### 3.3 Simulation

> **Definition 3.4 (Simulation / p-simulation).** A system `R` *simulates* a
> system `P`, written `Simulates R P`, if there is a monotone polynomial blow-up
> `f` and, for every `P`-proof `q`, an `R`-proof `p` with the same conclusion and
> size at most `f` of the original:
> ```
> Simulates R P  :≡  ∃ f, PolyMono f ∧
>                       ∀ q : P.Proof, ∃ p : R.Proof,
>                         R.proves p = P.proves q ∧ R.size p ≤ f (P.size q).
> ```

`Simulates` is reflexive (use `f = id`) and transitive (compose blow-ups), hence a
**preorder**. Its antisymmetrization
`Antisymmetrization (ProofSystem Thm) (· ≤ ·)`
is the **poset of p-degrees**; we write `[P]` for the degree of `P` and use
`toAntisymmetrization` for the quotient map.

---

## 4. The Domination Characterization

The decisive simplification restricts attention to *size-indexed* systems over
`ℕ`.

> **Definition 4.1 (Size-indexed system).** For `a : ℕ → ℕ`, let `sysOfSize a` be
> the proof system over `ℕ` with `Proof = ℕ`, `proves = id`, `size = a`, and
> completeness given by surjectivity of the identity. Concrete instances:
> `linSystem := sysOfSize (fun n => n)` and `fibSystem := sysOfSize Nat.fib`.

> **Theorem 4.2 (Domination characterization, `simulates_sysOfSize_iff`).**
> For all `a, b : ℕ → ℕ`,
> ```
> Simulates (sysOfSize a) (sysOfSize b) ↔ ∃ f, PolyMono f ∧ ∀ n, a n ≤ f (b n).
> ```
>
> *Proof sketch.* (⇒) A simulation supplies a blow-up `f` and, for each input `n`
> (which is its own proof in `sysOfSize b`), a proof of the same conclusion in
> `sysOfSize a`; since `proves = id`, the conclusion fixes the proof to be `n`
> itself, and the size bound reads `a n ≤ f (b n)`. (⇐) Conversely, given such an
> `f`, the identity translation `q ↦ q` preserves conclusions and satisfies the
> size bound by hypothesis. ∎

This is the master reduction: every question about simulation among size-indexed
systems becomes a question about *polynomial domination of size functions*,
`a ≤ f ∘ b` for some monotone polynomial `f`. All separations below are now
elementary growth-class facts.

---

## 5. Lattice Shape: Meets Exist

### 5.1 The direct-sum system

> **Definition 5.1 (Direct sum).** For proof systems `P, Q` over the same `Thm`,
> the *direct sum* `sumSystem P Q` has `Proof = P.Proof ⊕ Q.Proof`, with `proves`
> and `size` defined by `Sum.elim` (read off componentwise), and completeness
> inherited from `P`. Operationally: a proof is a `P`-proof or a `Q`-proof, and you
> run whichever you like.

> **Lemma 5.2.** `Simulates (sumSystem P Q) P` and `Simulates (sumSystem P Q) Q`.
>
> *Proof sketch.* Use the identity blow-up and the injection `Sum.inl`
> (resp. `Sum.inr`): a `P`-proof embeds into the sum with identical conclusion and
> size. ∎

> **Lemma 5.3 (Universal property).** If `Simulates R P` and `Simulates R Q`, then
> `Simulates R (sumSystem P Q)`.
>
> *Proof sketch.* Let `f₁, f₂` be the two blow-ups. Use `f = max f₁ f₂`, which is a
> monotone polynomial blow-up by Lemma 3.3. A sum-proof is `inl q` or `inr q`;
> translate it via `R`'s translation of `P` (resp. `Q`), and bound its size by
> `f₁` (resp. `f₂`), hence by the max. ∎

> **Theorem 5.4 (Meets exist, `isGLB_sumSystem`).** In the simulation preorder,
> `sumSystem P Q` is the greatest lower bound of `{P, Q}`:
> `IsGLB {P, Q} (sumSystem P Q)`.
>
> *Proof sketch.* Lower bound: Lemma 5.2. Greatest among lower bounds: Lemma 5.3,
> applied to any `R` simulating both members. ∎

> **Corollary 5.5 (Down-directedness, `simulation_directed`).** Every pair `P, Q`
> has a common lower bound (their direct sum). Hence the p-degrees form a
> **meet-semilattice**, with `[P] ∧ [Q] = [sumSystem P Q]`.

The semantic reading: the meet of two strengths is realized by the union of their
proof repertoires, paying, on each translation, the *max* of the two blow-ups —
i.e. a pointwise-min in strength.

---

## 6. A Strict Separation: Linear below Fibonacci

> **Lemma 6.1 (`simulates_lin_fib`).** `Simulates linSystem fibSystem`.
>
> *Proof sketch.* By Theorem 4.2 it suffices to dominate `id` by a polynomial in
> `Nat.fib`. The blow-up `f n = n + 4` (monotone, linear, hence `PolyMono`) works:
> for each input `m`, the identity size `m` is bounded using `m ≤ F(m) + 4`
> (equivalently `Nat.le_fib_add_one`). Intuitively, Fibonacci proofs are *small*,
> so re-proving them with linear cost is cheap. ∎

> **Lemma 6.2 (`not_simulates_fib_lin`).** `¬ Simulates fibSystem linSystem`.
>
> *Proof sketch.* A simulation would, by Theorem 4.2, give a monotone polynomial
> `f` with `F(n) ≤ f(n)` for all `n`. But the Fibonacci numbers grow
> super-polynomially: no monotone polynomial blow-up dominates `Nat.fib`
> (`no_poly_bound_dominates_fib`). Contradiction. ∎

> **Theorem 6.3 (Strict 2-chain, `lin_lt_fib`).** `linSystem < fibSystem` in the
> simulation preorder.
>
> *Proof.* Lemmas 6.1 and 6.2 give `≤` without `≥`. ∎

This is the prototypical separation: the harder cost (faster growth) is *not*
dominated by any polynomial in the easier one.

---

## 7. Infinite Height

### 7.1 The collapsing ladder (failure analysis)

A first attempt at an infinite chain takes cost functions `2^(k·n)`. It
**collapses**: `2^((k+1)·n) ≤ (2^(k·n))²`, so by Theorem 4.2 each rung
polynomially dominates (indeed squares to) the next *and* vice versa — all rungs
are p-equivalent, a single degree. The lesson: moving a parameter into the *linear
coefficient* of an exponential yields polynomially comparable growth. To separate,
push the parameter into the *exponent of the exponent*.

### 7.2 The polynomial-exponent ladder

> **Definition 7.1.** `powSystem k := sysOfSize (fun n => 2 ^ (n ^ k))`.

> **Lemma 7.2 (Super-polynomial gap, `pow_pow_succ_gap`).** For `k ≥ 1` and every
> exponent `c`, there exists `n` with
> ```
> (2 ^ (n ^ k) + 2) ^ c < 2 ^ (n ^ (k + 1)).
> ```
>
> *Proof sketch.* For `c = 0` take `n = 1`. For `c ≥ 1`, choose `n = c + 2`. Then
> `(2^(n^k) + 2) ≤ 2^(n^k + 1)`, so the left side is at most `2^(c·(n^k + 1))`;
> meanwhile the right side is `2^(n^(k+1)) = 2^(n·n^k)`. Since `n = c + 2 > c` and
> `k ≥ 1`, we have `n·n^k > c·(n^k + 1)`, giving the strict inequality after
> comparing exponents. The crux is `n^(k+1) = n·n^k` outrunning `c·n^k + c` once
> `n > c`. ∎

> **Lemma 7.3 (Lower rung simulates upper, `simulates_powSystem_succ`).**
> `Simulates (powSystem k) (powSystem (k+1))`.
>
> *Proof sketch.* By Theorem 4.2, dominate `2^(n^k)` by a polynomial in
> `2^(n^(k+1))`. Since `n^k ≤ n^(k+1)` for all `n`, in fact
> `2^(n^k) ≤ 2^(n^(k+1)) + 2` with the small linear blow-up `f n = n + 2`. ∎

> **Lemma 7.4 (Upper rung fails to simulate lower,
> `not_simulates_powSystem_succ`).** For `k ≥ 1`,
> `¬ Simulates (powSystem (k+1)) (powSystem k)`.
>
> *Proof sketch.* A simulation gives, via Theorem 4.2, a monotone polynomial
> blow-up `f` with `2^(n^(k+1)) ≤ f(2^(n^k))`. The polynomial bound on `f` yields
> an exponent `c` with `f(m) + 1 ≤ (m + 2)^c`; instantiating at `m = 2^(n^k)` and
> using Lemma 7.2 produces an `n` violating the bound. Contradiction. ∎

> **Theorem 7.5 (Strict rungs, `powSystem_lt_succ`).** For `k ≥ 1`,
> `powSystem k < powSystem (k+1)`.

> **Theorem 7.6 (Infinite height, `powSystem_strictMono`).** The map
> `j ↦ powSystem (j+1)` is strictly increasing in the simulation preorder.
> Consequently the poset of p-degrees contains an infinite strictly increasing
> chain.
>
> *Proof.* `strictMono_nat_of_lt_succ` applied to Theorem 7.5 (each rung index is
> `≥ 1`). ∎

> **Theorem 7.7 (Distinct degrees, `powSystem_pdegrees_injective`).** The map
> `j ↦ [powSystem (j+1)]` is injective into
> `Antisymmetrization (ProofSystem ℕ) (· ≤ ·)`.
>
> *Proof sketch.* If two indices mapped to the same degree, the systems would be
> mutually simulating, contradicting the strict monotonicity of Theorem 7.6 in
> whichever direction the indices differ. ∎

Thus the height ladder is not merely a chain in the preorder; it injects into the
genuine poset of degrees.

---

## 8. Synthesis: The Emerging Order Type

The two structural pillars established above — **meets** (Section 5) and
**infinite height** (Section 7) — combine with adjacent results in the program to
sketch the order type of the p-degrees:

- **Bottom element.** The size-`0` system simulates every proof system over `ℕ`
  (its proofs cost nothing, so any blow-up dominates), making it a least p-degree,
  strictly below the entire height ladder.
- **Infinite width.** Partitioning `ℕ` into infinitely many infinite "spike sets"
  by 2-adic valuation and planting an exponential spike `2^n` on the `i`-th set
  yields systems `spikeSys i` that are *pairwise incomparable*: for each pair,
  each cost function outruns any polynomial in the other on its own spikes. This
  is an infinite antichain of distinct p-degrees, so the simulation order is **not
  total**.
- **Density.** A parity-thinned size function (Fibonacci on the evens, linear on
  the odds) is a degree strictly between `linSystem` and `fibSystem`, witnessing
  local density at the Fibonacci separation.
- **Joins fail.** Binary meets always exist (Section 5), but binary joins do not
  in general — the p-degrees are a meet-semilattice that is *not* a lattice.

The single analytic input underlying width and the height collapse/non-collapse
is the fact that *exponential beats polynomial*: for all `a, k` there is `m` with
`(2m + a)^k < 2^m`. Everything else is the domination characterization plus
elementary order theory.

---

## 9. Discussion and Future Work

### 9.1 The right invariant

The recurring moral is that the correct invariant for size-indexed systems is
**polynomial domination of size functions**. Under it:
- meets ↔ pointwise `max` of blow-ups (= pointwise `min` of strengths);
- height ↔ chains of growth rates that are *not* polynomially comparable;
- width ↔ families of growth rates pairwise non-comparable on disjoint supports.
The polynomial-exponent ladder `2^(n^k)` works precisely because
`n^(k+1) = n·n^k` is super-polynomial in `n^k`, whereas `2^(kn)` collapses.

### 9.2 Toward the full order type

The natural next targets, building on the established core:
1. **Joins, precisely.** Characterize which pairs of degrees admit joins, and
   describe the obstruction in growth-rate terms.
2. **Embeddings.** Determine which countable posets embed into the p-degrees;
   the bottom + infinite height + infinite width + density already force a rich
   universal structure.
3. **Definable cuts and density everywhere.** Extend the single Fibonacci density
   witness to a uniform density theorem between arbitrary comparable degrees.
4. **Connections to concrete systems.** Map standard propositional proof systems
   (resolution, cutting planes, Frege, Polynomial Calculus, Sum-of-Squares) into
   this abstract poset and locate the established towers and antichains among them.

### 9.3 Significance

The order-theoretic core of the Cook–Reckhow program — its preorder, meets,
strict separations, and infinite height — is here assembled into a single
formally verified theory, with the domination characterization as its engine.
This provides a stable foundation on which finer questions about the order type
of the p-degrees can be posed and settled.

---

## 10. Summary of Results

| Result | Statement |
| --- | --- |
| `simulates_sysOfSize_iff` | simulation of size-indexed systems = polynomial domination of size functions |
| `polyMono_max` | pointwise max of monotone polynomial blow-ups is one |
| `isGLB_sumSystem` | direct sum is the greatest lower bound of a pair (meets exist) |
| `simulation_directed` | the simulation preorder is down-directed |
| `lin_lt_fib` | linear degree strictly below Fibonacci degree |
| `pow_pow_succ_gap` | consecutive rungs `2^(n^k)` are not polynomially comparable |
| `powSystem_lt_succ` | each ladder step is a strict increase |
| `powSystem_strictMono` | infinite strictly increasing chain (infinite height) |
| `powSystem_pdegrees_injective` | the chain descends to distinct p-degrees |

All statements are formalized and machine-checked with no remaining gaps.
