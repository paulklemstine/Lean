# Future Directions — Computational Complexity as Physical Law

The Lean development in `Geometry/ComplexityPhysics.lean` establishes a small but
fully verified bridge between complexity theory and thermodynamics:

* a **polynomial resource algebra** (`PolyBounded`) closed under constants,
  identity, addition, multiplication, and composition (`polyBounded_comp`) — the
  formal kernel of the Extended Church–Turing thesis;
* **microscopic reversibility ⇔ injectivity** (`reversible_iff_injective`) and
  the strict phase-space collapse of irreversible maps
  (`irreversible_decreases_phase_space`);
* a **bit-entropy** calculus (`bitEntropy`, `erasure_lowers_entropy`);
* a Maxwell-demon cycle whose Landauer postulate makes the **Second Law a
  theorem** (`second_law_holds`, `strict_sort_forces_dissipation`), generalized
  to arbitrary finite families of cycles (`second_law_multicycle`); and
* the impossibility of an efficient, dissipation-free demon (`no_free_demon`),
  with a boundary witness (`idleDemon`) certifying that the strictness hypothesis
  is essential.

The following conjectures are concrete, falsifiable next steps. Each one is
stated so that it can be turned directly into a Lean target.

## Direction 1 — Quantitative Landauer from first principles

Right now Landauer's principle enters as a single structure field. The next step
is to *derive* the inequality `ΔS_mem ≥ ΔS_gas` from the combinatorics of
`irreversible_decreases_phase_space`: model the demon's measurement as an
injection of gas microstates into memory microstates, and prove that closing the
cycle (resetting memory via a non-injective `reset` map) forces an environmental
entropy increase of at least `bitEntropy gasBefore − bitEntropy gasAfter`.
**The key insight is** that the demon's recorded correlation is itself a finite
injection, so the erasure cost is *exactly* the image-cardinality drop quantified
by `irreversible_decreases_phase_space`, converting Landauer from postulate to
corollary. **Why now?** All the finite-cardinality machinery
(`card_image_le`, `Finite.injective_iff_bijective`) and the entropy monotonicity
lemmas are already proven in the file, so the derivation is a recombination of
existing results rather than new theory.

## Direction 2 — Polynomial-hierarchy collapse as a closure fixed point

`polyBounded_comp` says polynomial budgets compose. Conjecture: a Turing
reduction class that is closed under composition *and* contains one
`NP`-complete decider must collapse to `P`, expressible as a fixed point of the
composition operator on `PolyBounded`. **The key insight is** that
oracle-reduction chaining is literally function composition of resource bounds,
so `P = NP` is equivalent to `PolyBounded` being a *fixed point* of the
"add one oracle layer" endofunctor — a purely algebraic statement about the class
proved in Part I. **Why now?** The composition-closure theorem is already in
hand; what remains is to formalize a `ReductionClosed` predicate and prove the
collapse as an induction over reduction depth, reusing `polyBounded_comp` at each
step.

## Direction 3 — A reversible (Bennett) computer pays nothing until it forgets

Conjecture: a computation realized entirely by injective endomaps on a finite
state space can be run at zero entropy cost, and the *total* dissipation of any
computation equals `bitEntropy` of the states it ultimately erases — independent
of intermediate work. **The key insight is** that
`reversible_iff_injective` already pins reversibility to injectivity, so the
dissipation functional factors through the *non-injective part* of the
computation only, making "compute freely, pay only to forget" a theorem about the
kernel of the transition map. **Why now?** The reversibility equivalence and the
strict-collapse lemma are proven; the remaining work is to define a composite
transition map and show its dissipation telescopes over reversible steps.

## Direction 4 — Tightness and a genuine counterexample regime

`no_free_demon` forbids zero-cost strict sorting, and `idleDemon` shows
non-strict cycles can be free. Conjecture: the entropy *deficit* a demon may run
before violating the Second Law is exactly `bitEntropy memBefore` — i.e. a demon
with a `k`-bit memory can transiently lower gas entropy by up to `k` bits, but no
more, before erasure forces repayment. **The key insight is** that the memory
register's finite capacity caps the recordable correlation, so the maximal
transient violation is the register's own `bitEntropy`, turning the qualitative
`no_free_demon` into a sharp quantitative bound. **Why now?** The asymmetric
boundary behaviour (strict vs. idle) is already isolated in the current file, so
the sharp threshold is the natural quantitative refinement of two theorems we
have already proved.

## Direction 5 — Speculative capstone: an entropic lower bound conjecture for search

Conjecture (entropic ECT): any physical process that, on inputs of size `n`,
isolates one designated microstate out of `2^n` must dissipate at least `n` bits
of entropy *unless* its resource function is super-polynomial — formally, a
`DemonCycle`-style witness with `gasBefore = 2^n`, `gasAfter = 1`, and
`PolyBounded` resource use cannot have `memAfter ≤ memBefore`. **The key insight
is** that exponential search compresses `n` bits of phase space, so by
`strict_sort_forces_dissipation` it must pay `n` bits of erasure; a polynomial
machine cannot both pay this cost and stay within a polynomial budget, giving a
thermodynamic shadow of `P ≠ NP`. **Why now?** Every ingredient — the polynomial
algebra, the strict-dissipation theorem, and `no_free_demon` — is already
formalized and sorry-free, so this capstone is assembled from verified parts
rather than built from scratch.
