# Computational Evidence — Merkle–Damgård Collision Preservation

## Setup
The Merkle–Damgård (MD) hash iterates a compression function
`f : State → Block → State` over a message (a list of blocks) starting from an IV:
`mdHash f iv [b₁,…,bₙ] = f(…f(f(iv,b₁),b₂)…,bₙ)`  (a left fold).

**Claim under test.** If two *equal-length* messages `m₁ ≠ m₂` hash to the same
value, then `f` has a *compression collision*: distinct `(s,b) ≠ (s',b')`
with `f s b = f s' b'`.

## Small-case calculations (multiplicative model f s b = s·b, iv = 1)
Here `mdHash` of a list is its product.

| m₁          | m₂          | len | product | distinct? | extracted f-collision            |
|-------------|-------------|-----|---------|-----------|----------------------------------|
| [6, 35]     | [10, 21]    | 2   | 210     | yes       | (6,35) vs (10,21): 6·35 = 10·21  |
| [2, 9]      | [3, 6]      | 2   | 18      | yes       | (2,9) vs (3,6): 2·9 = 3·6        |
| [4, 9]      | [6, 6]      | 2   | 36      | yes       | (4,9) vs (6,6): 4·9 = 6·6        |
| [12]        | [12]        | 1   | 12      | no (equal)| none (hypothesis m₁≠m₂ fails)    |

Every equal-length, distinct, equal-product pair yields a compression collision
of multiplication, confirming the extraction direction concretely.

## Counterexample hunt — why "equal length" is required
Plain MD (no length padding) is NOT collision resistant across *different*
lengths. With f s b = s·b, iv = 1:
- m₁ = [6] (product 6) and m₂ = [2,3] (product 6) collide but have different
  lengths; the naive recursion bottoms out comparing the IV with an internal
  state, which is a *free-start*/IV collision, not a genuine compression
  collision. This is exactly why the classical theorem assumes equal length
  (or uses MD strengthening / length padding). Our formal theorem therefore
  carries the `m₁.length = m₂.length` hypothesis, which is faithful and tight.

## Pigeonhole sanity check
Any compression function on finite types with `1 < card Block` and
`State` nonempty must have a collision: the domain `State × Block` is strictly
larger than the codomain `State`. This confirms collision resistance is
necessarily a *computational* (not information-theoretic) notion — collisions
always exist; finding them is the hard part.

## Conclusion
The equal-length MD extraction claim survives all tested cases; the
unequal-length counterexample pins down the precise boundary of the theorem.
