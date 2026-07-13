# Computational Evidence: Analogy as Residuation

Small-case checks supporting the adjunction and reconstruction claims for the min-plus
map `F(v)_i = min_k (A[i,k] + v_k)` and its max-plus residual `G(w)_k = max_i (w_i - A[i,k])`.

## 1×1 case

With `A = [a]`, `F(v) = a + v` and `G(w) = w - a`. Then:

* `G(F(v)) = (a + v) - a = v` — the round trip is the identity, so the analogy is *perfect*
  and fidelity is maximal. This matches `trop_counit_le` holding with equality.
* `F(G(w)) = a + (w - a) = w` — also identity, so this analogy is a two-way structural
  equivalence.

## 2×2 numeric case

Take
```
A = [[0, 3],
     [3, 0]],   w = (0, 0).
```
Then `G(w)_k = max_i (w_i - A[i,k])`:

* `G(w)_0 = max(0 - 0, 0 - 3) = 0`
* `G(w)_1 = max(0 - 3, 0 - 0) = 0`, so `G(w) = (0, 0)`.

Now `F(G(w))_i = min_k (A[i,k] + G(w)_k)`:

* `F(G(w))_0 = min(0 + 0, 3 + 0) = 0`
* `F(G(w))_1 = min(3 + 0, 0 + 0) = 0`, so `F(G(w)) = (0, 0)`.

This confirms the lower-bound reconstruction inequality `w ≤ F(G(w))` (here with equality),
i.e. `trop_unit_le`.

## Round-trip inflation on the source side

Take the same `A` and `v = (0, 5)`. Then:

* `F(v)_0 = min(0 + 0, 3 + 5) = 0`, `F(v)_1 = min(3 + 0, 0 + 5) = 3`, so `F(v) = (0, 3)`.
* `G(F(v))_0 = max(0 - 0, 3 - 3) = 0`, `G(F(v))_1 = max(0 - 3, 3 - 0) = 3`,
  so `G(F(v)) = (0, 3)`.

Here `G(F(v)) = (0, 3) ≤ (0, 5) = v` pointwise, confirming `trop_counit_le`
(`A♯(A ⊗ v) ≤ v`), and the coordinate `1` is *not* recovered (`3 ≠ 5`), illustrating that
fidelity can be strictly below the source size when the map is genuinely lossy.

## Counterexample hunt (perfectness is not automatic)

The example above already exhibits a non-perfect analogy: the second coordinate is lost.
Thus `fidelity < card` can occur, so the equivalence `fidelity = card ↔ perfect` is a
genuine (non-vacuous) characterization rather than a triviality.

## Notes

No infinite search or OEIS sequence is involved; the claims are structural identities and
inequalities over ordered abelian groups, and the finite fidelity statement is a counting
equivalence. The hand computations above match every formalized inequality and the sharp
fidelity characterization.
