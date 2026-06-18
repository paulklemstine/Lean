# Future Directions — Numerical Monsters Bestiary (Bridges domain)

This research cycle established a verified core for digit-combinatorial
"monsters": vampire numbers (`Vampire.lean`), the narcissistic / Harshad /
Kaprekar families plus a narcissistic finiteness bound (`Bestiary.lean`), and
cross-monster bridges (`CrossMonster.lean`). The following conjectures are bold,
precise, and falsifiable, intended to drive the next cycles.

## C1. Sharp narcissistic finiteness bound (tighten 60 → 39)
We proved `narcissistic_lt : IsNarcissistic n → n < 10^60`. The true maximal
narcissistic number is the 39-digit `115132219018763992565095597973971522401`.
**Conjecture.** `IsNarcissistic n → n < 10^39`, and this is sharp (the bound is
attained). *Testable*: strengthen `pow_ineq` to the sharp crossover index and add
a `native_decide` certificate that the 39-digit champion is narcissistic while no
40-digit one exists by the length argument.

## C2. Infinitude vs. finiteness dichotomy across families
Harshad numbers are infinite (every power of ten is Harshad, digit sum `1`),
whereas narcissistic numbers are finite (C1). **Conjecture.** A digit-family
defined by `n = Σ f(dᵢ)` with `f` *bounded* (independent of digit count) is
infinite, while one with `f` depending on the digit count (like narcissistic) is
finite. *Testable*: formalize "digit-additive family with bounded weights" and
prove an infinitude theorem covering Harshad and digit-sum-fixed-point families
in one stroke.

## C3. Vampire density and the multiplicative/additive bridge
We showed vampirism does **not** imply the Harshad property
(`vampire_not_harshad_6880`). **Conjecture.** Infinitely many vampire numbers are
Harshad numbers, and infinitely many are not; moreover the proportion of vampires
≤ N that are Harshad tends to a constant strictly between 0 and 1. *Testable
first step*: exhibit an explicit infinite family of vampires (e.g. of the shape
`(10^k·a)(10^k·b)` patterns) and decide the Harshad property along it.

## C4. Pseudovampires and prime-fang vampires
Our `vampire_not_prime` shows every vampire is composite. Refine the factor
structure. **Conjecture.** There exist infinitely many vampire numbers both of
whose fangs are prime ("prime vampire numbers", e.g. `117067 = 167 × 701`), and
the smallest is `117067`. *Testable*: extend `IsVampire` with a `fangsPrime`
predicate, certify `117067`, and prove minimality over the relevant range by the
same `isVampireB`-style executable bridge used for `least_vampire`.

## C5. Kaprekar fixed points and the 6174 vortex (cross to dynamics)
Beyond Kaprekar *numbers* lies the Kaprekar *routine* `K(n) = (desc digits) −
(asc digits)`. **Conjecture.** Every 4-digit number with at least two distinct
digits reaches the fixed point `6174` under iteration of `K` in at most `7`
steps, and `6174` is its unique nonzero fixed point. *Testable*: define `K` as an
executable function, prove `K 6174 = 6174` and uniqueness by `native_decide` over
4-digit inputs, then bound the iteration depth — a genuine bridge from static
digit predicates to discrete dynamics.
