# Computational Evidence — Mixed-Radix / Factorial Bridge

This cycle closes the three open placeholders that connected the general
**mixed-radix positional number system** to the special-case **factorial
number system**. Before formalizing the bridge, the underlying identities were
checked on small cases.

## 1. Running product of bases equals the factorial

For bases `b i = i + 1`, the running product `∏_{j<i} b j` should equal `i!`.

| i | ∏_{j<i}(j+1) | i! |
|---|--------------|----|
| 0 | 1            | 1  |
| 1 | 1            | 1  |
| 2 | 1·2 = 2      | 2  |
| 3 | 1·2·3 = 6    | 6  |
| 4 | 1·2·3·4 = 24 | 24 |

Agreement is exact, confirming the place values of the two systems coincide.

## 2. Value agreement

Take digits `c = (c0, c1, c2, c3) = (0, 1, 2, 1)`.

- Factorial value: `0·0! + 1·1! + 2·2! + 1·3! = 0 + 1 + 4 + 6 = 11`.
- Mixed-radix value with bases `(1,2,3,4)`: `0·1 + 1·1 + 2·2 + 1·6 = 11`.

The two values match, as the place-value table predicts.

## 3. Validity agreement

Factorial validity requires `c i ≤ i`; mixed-radix validity with `b i = i + 1`
requires `c i < i + 1`. These are the same constraint (`c i ≤ i ⇔ c i < i+1`),
verified on the digit range: for `i = 3`, valid digits are `{0,1,2,3}` under both
definitions.

## 4. Consequence

Because place values, values, and validity all agree, uniqueness of factorial
representations is a strict instance of uniqueness of mixed-radix representations.
The small-case checks above match the closed-form proofs, so no counterexample
search was warranted for the finite instances; the general statements are proved
outright rather than by enumeration.
