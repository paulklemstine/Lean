# Future Directions — The Sphere-Packing (Hamming) Bound

## Synthesis

This cycle formalised the classical **sphere-packing bound** of coding theory
directly on top of Mathlib's `hammingDist`, in the file
`Cryptography/SpherePackingBound.lean`. The central organising idea is that a
`t`-error-correcting code is exactly a packing of pairwise-disjoint Hamming
balls of radius `t`, and that the *volume* of each ball is a single,
centre-independent constant once the alphabet carries an additive group
structure. Factoring the volume out of the packing argument cleanly separates
the geometric content (disjointness via the triangle inequality) from the
combinatorial bookkeeping (`card_biUnion` over a pairwise-disjoint family),
which is what makes the bound `|C| · V(t) ≤ q^n` fall out so transparently.

## Results Summary

* `hammingBall_disjoint`: radius-`t` balls with centres at distance `≥ 2t+1` are
  disjoint — the geometric heart of the argument.
* `hammingDist_add_left` / `hammingBall_card_translate`: translation invariance
  of Hamming distance and hence centre-independence of ball volume over any
  finite `AddCommGroup` alphabet.
* `spherePacking_bound`: the abstract bound `|C| · V(t) ≤ |ambient space|` for an
  arbitrary finite Hamming space.
* `hamming_bound_qary`: the textbook `q`-ary form `|C| · V(t) ≤ q^n` for codes in
  `Fin n → ZMod q`.

All four are proved with `sorry = 0` and depend only on the standard axioms
`propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. The explicit ball-volume formula `V(t) = Σ_{i≤t} C(n,i)(q-1)^i`
Right now `V(t)` appears in the bound as the abstract cardinality of a ball.
The key insight is that the Hamming sphere of radius exactly `i` in `Fin n →
ZMod q` is in bijection with (choice of `i` coordinates) × (nonzero values in
each), so its size is `C(n,i)(q-1)^i` and the ball is the partial sum. Proving
`(hammingBall 0 t).card = ∑ i ∈ Finset.range (t+1), n.choose i * (q-1)^i` would
turn `hamming_bound_qary` into the literal closed-form Hamming bound. **Why
now?** With disjointness and translation invariance already in hand, this is the
one remaining ingredient separating the abstract inequality from the form quoted
in every textbook, and it is a self-contained `Finset` counting exercise.

### 2. Perfect codes and the equality case
The key insight is that equality `|C| · V(t) = q^n` holds **iff** the radius-`t`
balls *tile* the cube, i.e. every word lies in exactly one ball. Formalising
`isPerfect C t ↔ C.card * (hammingBall 0 t).card = q^n` (with `isPerfect` saying
the balls cover `univ`) would characterise perfect codes abstractly, and set up
the eventual verification that the Hamming `[7,4,3]` and Golay codes meet the
bound. **Why now?** The disjointness lemma already gives `≤`; the equality
analysis only needs the complementary "covering ⇒ ≥" direction, reusing the same
`card_biUnion` skeleton.

### 3. The Singleton bound and the Singleton defect, side by side
The key insight is that the same `Finset`-projection technique underlying ball
counting also yields the Singleton bound `|C| ≤ q^(n-d+1)` by projecting
codewords onto any `n-d+1` coordinates and showing the projection is injective.
Stating both bounds in one file lets us prove the **Singleton defect** inequality
relating them and identify MDS codes as the Singleton-tight case. **Why now?**
Mathlib already has the injectivity infrastructure for `Function.Injective` on
restricted Pi-types, so the projection argument is within reach and naturally
complements the packing bound proved here.

### 4. Generalising the alphabet from `ZMod q` to arbitrary finite modules
The key insight is that nothing in `spherePacking_bound` uses the *ring*
structure of `ZMod q` — only the finite `AddCommGroup`. So the bound holds for
codes over any finite abelian group alphabet, and even for mixed-alphabet
("polyalphabetic") codes `∀ i, β i` with different `β i` per coordinate. Proving
a `hamming_bound_mixed` specialisation with `∏ i, Fintype.card (β i)` on the
right would make this explicit. **Why now?** The abstract theorem is *already*
stated at this generality; only a thin `Fintype.card_pi` wrapper is missing, so
this is low-cost, high-coverage generalisation.

### 5. Asymptotic / rate form of the bound
The key insight is that taking logarithms of `|C| · V(t) ≤ q^n` and dividing by
`n` converts the packing bound into a bound on the **code rate** `R = log_q|C|/n`
in terms of the relative distance `δ = d/n`, yielding the asymptotic Hamming
bound `R ≤ 1 - H_q(δ/2)` where `H_q` is the `q`-ary entropy. The first concrete
step is bounding `V(t)` above by `q^{n·H_q(t/n)}` using the binomial-entropy
estimate. **Why now?** Once direction 1 supplies the closed form for `V(t)`, the
entropy estimate is a clean real-analysis lemma, opening a bridge from this
discrete combinatorics file to Mathlib's analytic `Real.log`/entropy API.
