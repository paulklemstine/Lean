# Computational Evidence — Phantom Topologies (Non-Metrizable Cycle)

Concise validation performed before formalizing the refutation of the
"non-metrizable ⇒ ≥ 3 observers" conjecture.

## 1. Opens of the two Sierpiński observers on `Bool`

Enumerating the 4 subsets of `Bool = {false, true}`:

| U          | `false∈U→true∈U` (sierpTrue) | `true∈U→false∈U` (sierpFalse) |
|------------|------------------------------|-------------------------------|
| ∅          | ✓ (vacuous)                  | ✓ (vacuous)                   |
| {true}     | ✓ (vacuous, false∉U)         | ✗ (true∈U, false∉U)           |
| {false}    | ✗ (false∈U, true∉U)          | ✓ (vacuous, true∉U)           |
| {true,false}=univ | ✓                     | ✓                             |

- `sierpTrue` opens = {∅, {true}, univ}.
- `sierpFalse` opens = {∅, {false}, univ}.
- **Intersection** (sets open for BOTH) = {∅, univ} = the indiscrete topology `⊤`.

So the consensus (agreement) of the two observers is exactly the indiscrete space,
confirming the two-observer computation before formalizing it.

## 2. Strictness check

`{true}` is `sierpTrue`-open but not indiscrete-open, so `sierpTrue ≠ ⊤`; combined
with `sierpTrue ≤ ⊤` this gives `sierpTrue < ⊤`. Symmetrically `sierpFalse < ⊤`.
Both observers are genuinely sharper than reality — the representation is a real
phantom representation, not a duplication.

## 3. Non-metrizability check

Under `⊤` the only opens are ∅ and univ, so no open set contains `true` without
containing `false`: the two points are topologically inseparable. Hence the space
is not `T0`. Every metrizable space is `T0` (points at positive distance are
separated by balls), so the indiscrete two-point space is non-metrizable.

## 4. Counterexample-hunt conclusion

The original claim "every non-metrizable space requires at least 3 observers" is
tested on the smallest non-metrizable space (2 points, indiscrete). It fails: the
space has phantom number 2. No search over larger spaces is needed — a single
minimal counterexample refutes the universal claim. This is exactly the statement
formalized in `Catalog/Novelty/PhantomTopologyNonMetrizable.lean`.

## 5. OEIS

No integer sequence is central to this cycle (the objects are small finite
topologies), so no OEIS lookup applies.
