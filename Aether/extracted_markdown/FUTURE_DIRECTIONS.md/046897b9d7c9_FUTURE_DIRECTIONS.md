# Future Directions — The Gauss-Sum Bridge between Even Lattices and Binary Codes

## Synthesis

The `SmoothPoincare` family in `Catalog/Applications/SmoothPoincare/` builds the smooth/
topological gap in dimension 4 from two parallel towers:

* the **lattice tower** — `IntersectionForms.lean` / `DirectSum.lean` /
  `DirectSumObstruction.lean`: even unimodular forms (`E8form`, `E8E8form`), the
  Donaldson obstruction `even_not_stdDiagonalizable`, and the rank-divisible-by-8
  miracle;
* the **code tower** — `TopologicalCodes.lean` / `SelfDualLength.lean` /
  `MinimumDistance.lean`: the doubly-even self-dual `[8,4,4]` Hamming code, the bridge
  `doublyEven_selfOrthogonal`, the weight enumerator `1 + 14x⁴ + x⁸`, and length
  divisibility by 4.

Every prior lab notebook in the code tower flagged the same gap: the mod-4 length
theorem (`SelfDualLength.selfDual_doublyEven_length_div_four`) is **not sharp**; the
true constant is 8 (Gleason), and reaching it "is the genuinely harder,
weight-enumerator/invariant-theory step." This cycle closes exactly that gap.

The new file `Catalog/Applications/SmoothPoincare/GleasonLength.lean` proves, fully
`sorry`-free and for arbitrary length `n`:

> **`doublyEven_selfDual_length_div_eight`** — every binary doubly-even self-dual code
> has length divisible by 8.

The proof is a self-contained formalization of the classical **Gauss-sum / MacWilliams**
argument over `ℂ`, never invoking external invariant theory:

1. `csgn`/`bchar` set up the additive character `(-1)^⟨x,c⟩`;
2. `char_orthogonality` proves the standard "nontrivial character sums to zero" on the
   self-dual (hence *linear*) code, via the involution `c ↦ c + c₀`;
3. `fourier_iwt` computes the discrete Fourier transform of `x ↦ Iʷᵗ⁽ˣ⁾` by
   per-coordinate factorization, giving `(1+I)^{n−w}(1−I)^w`, which `fourier_iwt_doublyEven`
   collapses to `(1+I)ⁿ` using `1−I = (−I)(1+I)` and `(−I)^w = 1`;
4. `card_eq_onePlusI_pow` evaluates the double sum two ways to obtain the master
   identity `(|C| : ℂ) = (1+I)ⁿ`;
5. `eight_dvd_of_pos_real_pow` reads off `8 ∣ n` from the fact that `|C|` is a *positive
   real* sitting on the `(1+I)`-tower of period 8 (`(1+I)⁴ = −4`, `(1+I)⁸ = 16`).

This is the precise code-side mirror of the lattice statement "positive-definite even
unimodular lattices have rank divisible by 8," with `E8 ↔ Hamming[8,4,4]` the minimal
witnesses on each side.

## Results Summary

* `doublyEven_selfDual_length_div_eight` — main theorem, arbitrary `n`, axioms
  `propext / Classical.choice / Quot.sound` only.
* `card_eq_onePlusI_pow` — the master Gauss-sum identity `(|C| : ℂ) = (1+I)ⁿ`, a reusable
  engine for any doubly-even self-dual code.
* `char_orthogonality`, `fourier_iwt`, `fourier_iwt_doublyEven` — standalone MacWilliams
  infrastructure usable for further weight-enumerator work.
* `hamming_length_div_eight` — corollary recovering `8 ∣ 8` for the Hamming code from the
  *general* theorem (not by hand), exactly as `E8`'s obstruction is derived from
  `E8_even`.

## Research Directions

### 1. The full MacWilliams identity and Gleason's structure theorem

The pieces `char_orthogonality` and `fourier_iwt` already are the entire engine of the
MacWilliams transform; what is missing is to package them into the genuine identity
`W_{C^⊥}(x,y) = |C|⁻¹ W_C(x+y, x−y)` on the two-variable weight enumerator, and then to
prove Gleason's theorem that the weight enumerator of a doubly-even self-dual code is a
polynomial in the two basic invariants `W_{Hamming[8]}` and `W_{Golay[24]}`.
**The key insight is** that the present `card_eq_onePlusI_pow` is the evaluation of the
MacWilliams identity at the single character `y = I`; replacing `I` by a formal variable
turns the same double-sum/character-orthogonality computation into the full bivariate
transform with *no new ideas*, only bookkeeping over a polynomial ring. **Why now?**
Because the hard analytic kernel (character orthogonality on a self-dual code, and the
per-coordinate Fourier factorization) is now formalized and reusable; the remaining work
is algebraic and squarely in Mathlib's `MvPolynomial`/`Finset` comfort zone.

### 2. Construction A: make the lattice↔code bridge a theorem, not an analogy

So far the two towers are linked by *narrative* ("the Hamming code is the mod-2 shadow of
E8"). Promote this to a Lean theorem: define Construction A, `L(C) = {v ∈ ℤⁿ : v mod 2 ∈ C}/√2`,
and prove `C` doubly-even self-dual ⟺ `L(C)` even unimodular, transporting
`doublyEven_selfDual_length_div_eight` to a *new proof* of "even unimodular ⟹ rank
divisible by 8" that is independent of the lattice-side Donaldson machinery.
**The key insight is** that divisibility-by-8 is a single invariant computed identically
on both sides — `wt mod 4` on codes and the diagonal `Q(v) mod 2` on lattices — so the
mod-8 obstruction should *factor through* Construction A as one shared `ℤ/8` class.
**Why now?** Both endpoints are already formalized (`E8form`/`E8_even` on one side,
`GleasonLength` on the other); only the functor between them is missing, and proving an
equivalence between two already-proved facts is far cheaper than proving either afresh.

### 3. Sharpness and a classification at length 8

`doublyEven_selfDual_length_div_eight` gives a necessary condition; is it the *only*
constraint, and is the Hamming code the *unique* doubly-even self-dual code of length 8?
Conjecture: every doubly-even self-dual binary code of length 8 is monomially equivalent
to `Hamming[8,4,4]`, and there is exactly one such code up to permutation.
**The key insight is** that the master identity pins `(|C| : ℂ) = (1+I)⁸ = 16`, so any
length-8 example has exactly 16 words with weight enumerator forced to `1 + 14x⁴ + x⁸` —
the enumerator is *determined*, not assumed, which should rigidify the code to a unique
one. **Why now?** The weight enumerator is already nailed (`MinimumDistance.lean`
`hamming_weightEnum_*`), so the classification reduces to a finite, `decide`-able search
over generator matrices constrained by a known spectrum.

### 4. The mod-2 reduction of `E8 ⊕ E8` versus `D16⁺` as distinct length-16 codes

`DirectSum.lean` proves `E8E8form` is even, unimodular, and *not* standard-diagonalizable.
On the code side this predicts two inequivalent doubly-even self-dual codes of length 16
(the shadows of `E8⊕E8` and of `D16⁺`), both forced by `GleasonLength` to have length
divisible by 8. Conjecture: their *weight enumerators agree* but the codes are
inequivalent — the first genuinely "MacWilliams-invisible" separation in the catalog.
**The key insight is** that Gleason's theorem makes the length-16 weight enumerator
*unique* (a fixed polynomial in the degree-8 invariant), so weight data alone *cannot*
distinguish the two codes — separation must come from a finer invariant such as the
automorphism group order. **Why now?** Direction 1's enumerator machinery plus the
already-formalized `E8E8_not_stdDiagonalizable` give both the obstruction to weight-based
separation and a concrete second example to compare against.

### 5. Type II ⟹ a `ℤ/8`-valued signature and the Rokhlin connection

The number 8 in `GleasonLength` and the number 16 in Rokhlin's theorem (signature of a
smooth spin 4-manifold is divisible by 16) are the same arithmetic phenomenon one
categorical level apart. Define a `ℤ/8`-valued invariant of a doubly-even self-dual code
as the class of `n` and prove it equals the Gauss-sum phase `arg((1+I)ⁿ)/(π/4)`.
**The key insight is** that `eight_dvd_of_pos_real_pow` already isolates this phase as the
*only* obstruction, so the invariant is literally the discrete logarithm of the master
identity's right-hand side — a number already computed inside the proof. **Why now?**
The phase is sitting unused inside `card_eq_onePlusI_pow`; exposing it as a named
invariant turns a proof step into a reusable bridge toward a formal Rokhlin-type
signature theorem on the lattice tower.
