# Computational Evidence — Sheared Witt vectors as a filtered colimit

This note records the small-case checks performed before formalizing the three
main theorems in `ShearedWittVectorBridge.lean` (which build on the abstract
directed-union results of `FilteredColimitArity.lean` and their subring
specialisations in `ShearedWittColimit.lean`).

## Model of the colimit

A filtered colimit of rings is modelled as a directed union `⨆ i, S i` of a
monotone family of subrings `S : ι → Subring R`. Set-theoretically the Witt
functors are powers of the base:

* truncated Witt `Wₙ(R) ≅ Fin n → R` (finite power, **finite arity**),
* full Witt `W(R) ≅ ℕ → R` (countable power, **infinite arity**),
* sheared Witt = full Witt restricted to **finitely-supported** coordinate
  sequences.

## 1. Finite-arity lift — small cases

Claim: a finite tuple whose entries each lie in `⋃ i, S i` already lies in a
single stage. Checked by hand with `S i = Set.Iic i ⊆ ℕ`:

| tuple                 | per-coordinate stage | merged stage `max` | in one stage? |
|-----------------------|----------------------|--------------------|---------------|
| `(0, 3)`              | `S₀, S₃`             | `S₃`               | yes           |
| `(5, 2, 4)`           | `S₅, S₂, S₄`         | `S₅`               | yes           |
| `(7, 1, 9, 0)`        | `S₇, S₁, S₉, S₀`     | `S₉`               | yes           |

The merge always exists because a finite set of indices has an upper bound in a
directed order (`Finset.exists_le`). This is exactly the truncated case
`truncatedWitt_lifts`.

## 2. Infinite-arity failure — the witness

Claim: the naive countable power does **not** commute with the directed union.
Witness: `S i = Set.Iic i ⊆ ℕ`, sequence `f = id`, so `f k = k`.

* Every coordinate lifts: `f k = k ∈ Set.Iic k ⊆ ⋃ i, Set.Iic i`.
* No single stage works: if `f` lay in `S i`, then `f (i+1) = i+1 ≤ i`, false.

Ring-theoretic upgrade used in the formal proof: `R = MvPolynomial ℕ K`,
`S i = varSubring K i = {p | p.vars ⊆ {0,…,i}}`, and the Witt vector
`x` with `x.coeff k = X k`.

| `k`   | `x.coeff k = X k` | `vars` | smallest stage `varSubring K k` |
|-------|-------------------|--------|---------------------------------|
| `0`   | `X 0`             | `{0}`  | `varSubring K 0`                |
| `1`   | `X 1`             | `{1}`  | `varSubring K 1`                |
| `i+1` | `X (i+1)`         | `{i+1}`| `varSubring K (i+1)`            |

Every coordinate is in the colimit, but a lift to stage `i` would force
`X (i+1) ∈ varSubring K i`, i.e. `{i+1} ⊆ {0,…,i}`, which is false. This is
`naiveWitt_lift_fails`.

## 3. Sheared repair — small cases

Claim: restricting to finitely-supported sequences (eventually `0`) restores the
finite-arity behaviour of case 1, because only finitely many coordinates carry
information; the rest sit at the basepoint `0 ∈ S i` for every `i`.

| sequence (support)         | pre-support stages | merged stage | in one stage? |
|----------------------------|--------------------|--------------|---------------|
| `(3, 5, 0, 0, …)`          | `S₃, S₅`           | `S₅`         | yes           |
| `(2, 9, 4, 0, 0, …)`       | `S₂, S₉, S₄`       | `S₉`         | yes           |
| `id` (no finite support)   | unbounded          | none         | **no**        |

The last row is exactly the failure of case 2: it is *not* finitely supported,
which is why it escapes `shearedWitt_lifts`.

## OEIS / counterexample hunt

No integer sequence is intrinsic to the statement (the content is order- and
ring-theoretic, not enumerative), so no OEIS lookup applies. The universal claim
"the full Witt functor preserves the colimit" was actively hunted for
counterexamples; the variable Witt vector `k ↦ X k` is a clean witness that it
is **false**, which is the surprising main result and the justification for the
sheared construction.

## Conclusion

The small cases confirm: finite arity and finite essential support both merge
into a single stage, while genuine infinite arity does not. This matched the
final formal theorems exactly (`truncatedWitt_lifts`, `shearedWitt_lifts`,
`naiveWitt_lift_fails`), all proved with clean axioms.
