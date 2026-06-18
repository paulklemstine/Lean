# Future Directions — Beal's Conjecture via Modular Obstructions

## Synthesis

This cycle repaired and extended the project's Beal development. The two
existing files (`MachineLearning/Beal/PrimitiveReduction.lean` and
`MachineLearning/Beal/Monotonicity.lean`) depended on a module
`Speculative.Beal.Defs` that did not exist, so neither compiled. We supplied
the missing definitions — `BealConjecture` and `PrimitiveResidueSolution` —
and then built a new file, `MachineLearning/Beal/ModularObstruction.lean`,
that turns the abstract `PrimitiveResidueSolution` predicate into a working
proof technique.

The central new idea is the **reduction bridge**
(`primitiveResidueSolution_of_coprime_solution`): a primitive integer solution
of `A^x + B^y = C^z` reduces, modulo any `N` coprime to the bases, to a
solution living entirely in the unit group of `ZMod N`. This converts an
infinite Diophantine question into a *finite, decidable* search. We exploited
it to give a fully machine-checked proof that `A^3 + B^3 = C^3` has no solution
with `3 ∤ A, 3 ∤ B, 3 ∤ C` — the residue core of Fermat's Last Theorem for
exponent three — via the decidable obstruction `¬ PrimitiveResidueSolution 9
3 3 3`. Crucially, the contrasting witness `PrimitiveResidueSolution 5 3 3 3`
shows the method has real arithmetic content: obstructions are a property of
the (exponents, modulus) pair, not a formal triviality.

## Results Summary

- `Speculative/Beal/Defs.lean`: `BealConjecture`, `PrimitiveResidueSolution`.
- `primitiveResidueSolution_of_coprime_solution`: the reduction bridge.
- `no_primitiveResidueSolution_cubes_mod9`: decidable cubic obstruction at 9.
- `primitiveResidueSolution_cubes_mod5`: contrasting residue solution at 5.
- `no_primitiveResidueSolution_cubes_of_nine_dvd`: obstruction propagates to
  every multiple of 9 (uses the catalog's `Monotonicity`).
- `flt3_no_coprime_to_three_solution` / `three_dvd_some_of_cubic_solution`:
  the cubic special case and its common-factor reformulation.
- `beal_common_factor_of_not_coprime_AB`: Beal's conclusion holds whenever the
  bases are not coprime (uses the catalog's `PrimitiveReduction`).

All main results are `sorry`-free and depend only on `propext`,
`Classical.choice`, and `Quot.sound`.

## Bold, Falsifiable Directions

### 1. An obstruction modulus for every odd-exponent triple
Conjecture: for every triple of odd exponents `(x, y, z)` each `> 2`, there is
an explicit modulus `N = N(x,y,z)` with `¬ PrimitiveResidueSolution N x y z`.
The key insight is that for odd `n` the image of the `n`-th power map on
`(ZMod p^k)ˣ` collapses to a subgroup of index `gcd(n, p^{k-1}(p-1))`, and for
suitable primes that image is so thin that no `a^x + b^y` can land on a `z`-th
power. Why now? We already have the decidable machinery and the propagation
lemma; one only needs a Lean function `obstructionModulus : ℕ × ℕ × ℕ → ℕ`
plus a `decide`-backed lemma per residue class, so this is a finite, automatable
extension rather than new theory.

### 2. Beal's conjecture is equivalent to a residue-density statement
Conjecture: a primitive integer counterexample to Beal exists **iff** for every
`N` there is a primitive residue solution mod `N` (a "consistent" residue
system), and these residue solutions glue to a finite-index profinite point.
The key insight is that the reduction bridge is the easy direction; the hard
direction is a local-global compactness statement over `∏_p ZMod p^k`, so the
conjecture is a Hasse-principle obstruction question. Why now? The `Defs` and
bridge make the two sides expressible in the *same* vocabulary
(`PrimitiveResidueSolution`), so the equivalence can be stated and the easy
direction proved immediately, isolating exactly where new mathematics is needed.

### 3. Sharp threshold: the smallest obstructing modulus grows polynomially
Conjecture: for the diagonal triple `(n,n,n)`, the least `N` with
`¬ PrimitiveResidueSolution N n n n` is `O(n^2)` and is always a prime power
`p^k` with `p ≡ 1 mod n`. The key insight is that obstructions are densest at
primes where the `n`-th power map has small image, i.e. `p ≡ 1 (mod n)`, and the
needed multiplicity `k` is controlled by how `n` divides `p-1`. Why now? This is
directly testable: a short `#eval` search over `n ≤ 30` either confirms the
`O(n^2)` prime-power pattern or produces an immediate counterexample, making it
a cheap, high-information experiment to seed the next cycle.

### 4. Mixed exponents with a `2` collapse the obstruction
Conjecture: whenever one exponent equals `2` (the Pythagorean-flavored case),
*no* finite modulus obstructs — `PrimitiveResidueSolution N x 2 z` holds for all
`N`, reflecting the abundance of squares. The key insight is that the square map
on `(ZMod p)ˣ` has image of index exactly `2`, so `b^2` ranges over a full
quadratic-residue half and sums `a^x + b^2` cover everything; this links the
Beal residue framework to the catalog's `Pythagorean` library. Why now? It is a
falsifiable *negative* prediction (any obstructing modulus refutes it) and it
forges a concrete bridge between the `Beal` and `Pythagorean` catalog domains.

### 5. A certified `decide`-driven verifier for bounded Beal search
Conjecture: there is a Lean-verified procedure that, given a bound `B`, proves
"no primitive solution with all bases `≤ B` and exponents in a fixed finite set"
purely by composing residue obstructions — never touching the giant integers.
The key insight is that obstruction monotonicity (`no_..._of_dvd`) lets a single
small modulus certify infinitely many base values at once, so a finite set of
moduli can cover an entire bounded box. Why now? The propagation lemma is
already proved; wrapping it in a `Decidable`-style covering argument turns the
project's "verify computationally up to 1000" goal into a *proof*, not a
numerical check.
