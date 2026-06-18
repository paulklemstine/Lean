# Future Directions — Transfinite Game Values of Infinite Chess

## Synthesis of findings

`Catalog/Logic/InfiniteChessOrdinalValues.lean` formalizes the *ordinal game value*
`v(P)` of transfinite open games — the abstraction that drives infinite chess (chess
on an infinite board). White tries to force a won position (`win`); White's moves are
forced (`wmove`), while Black, to move (`bmove`), may delay by choosing any natural
number. The value is the Evans–Hamkins min/sup ordinal recursion, here specialized so
that *all* transfinite complexity lives in Black's choices:

```
v(win)       = 0
v(wmove g)   = v(g) + 1
v(bmove f)   = ⨆ n, (v(f n) + 1)
```

The work establishes a clean *algebra of positions* and uses it to realize an explicit
hierarchy of game values:

- `gval_omegaPuzzle`: a position of value exactly `ω` (the Evans–Hamkins ω-puzzle).
- `gval_graft`: a grafting combinator is **additive**, `v(graft G H) = v(H) + v(G)`.
- `gval_gmul`: `n`-fold sequencing multiplies, `v(gmul n G) = v(G) · n`.
- `gval_gpow`: an explicit position of value exactly `ω^k`, for every `k : ℕ`.
- `gval_omegaOmega`: a diagonal position of value exactly `ω^ω`.
- `gameValues_unbounded_below_omega_omega`: the values `ω^k` are unbounded below
  `ω^ω`, and `ω^ω` is itself attained.

The decisive structural fact is the **left-continuity** of ordinal addition and
multiplication (`isNormal_add_right`, `isNormal_mul_right`): it is exactly what makes
grafting additive and Black's diagonal supremum jump to the next power — while the
*failure* of right-continuity faithfully explains why a finite suffix appended after an
`ω`-puzzle is "absorbed". This sits directly atop the catalog's ordinal-analysis line:
it reuses the well-foundedness viewpoint of `Logic/TransfiniteRefinement.lean` and
populates the low segment `[ω, ω^ω)` that lives far beneath the Veblen tower
`ω < ε₀ < Γ₀` recorded in `Logic/StronglyCriticalOrdinals.lean`, while giving concrete
ordinal-valued instances for the infinite-game framework of `Logic/GaleStewartCore.lean`.

## Results summary

| Theorem | Statement |
|---|---|
| `gval_omegaPuzzle` | `v(omegaPuzzle) = ω` |
| `gval_graft` | `v(graft G H) = v(H) + v(G)` |
| `gval_gmul` | `v(gmul n G) = v(G) · n` |
| `gval_gpow` | `v(gpow k) = ω^k` |
| `gval_omegaOmega` | `v(omegaOmega) = ω^ω` |
| `gameValues_unbounded_below_omega_omega` | `∀ k, ∃ P, v(P) = ω^k < v(omegaOmega) = ω^ω` |

## Research directions

### 1. Surjectivity onto a proper initial segment of the ordinals

Conjecture: the value map `gval` is *surjective onto an initial segment* — for every
ordinal `α < ω^ω` there is a `Game P` (definable from `α`'s Cantor normal form) with
`v(P) = α`, and more boldly the realizable values form a downward-closed set. The
present file pins the "milestones" `ω^k`; the gap is the dense interior, e.g.
`ω^2·3 + ω·5 + 7`. **The key insight is** that Cantor normal form is built from exactly
the three operations the position algebra already realizes — `+` (graft), `·n` (gmul),
and the diagonal supremum (`bmove`) — so a structural recursion on CNF should assemble a
witness position term-by-term. **Why now?** `gval_graft` and `gval_gmul` give the two
non-trivial algebraic identities in verified form; only a CNF-driven assembly function
and a downward-closure lemma remain, both finite inductions.

### 2. Climbing past ω^ω to ε₀ via a value-reflecting fixed point

Conjecture: enriching the move structure (allowing Black to choose a previously
constructed *position*, not just a number) yields games of value `ω^(ω^ω)`, `ω^ω^ω`, …,
and a single self-referential "tower" position of value exactly `ε₀`. **The key insight
is** that `bmove (fun k => gpow k)` already performs one exponential jump `sup_k ω^k =
ω^ω`; iterating the *same* diagonal construction on the previous level is precisely the
`ω ↦ ω^ω ↦ ω^(ω^ω)` recursion whose supremum is `ε₀`. **Why now?** `gval_omegaOmega`
demonstrates the jump is formally controllable, and `Logic/StronglyCriticalOrdinals.lean`
already supplies `ε₀` (`epsilon0`) and `ω < ε₀ < Γ₀`, giving a ready-made target to
connect to and a sharp upper landmark to test against.

### 3. A genuine White-choice model and a minimax (determinacy) theorem

Conjecture: re-introducing branching White moves with the `min` rule
(`v(wmove f) = ⨅ i, (v(f i) + 1)`) leaves all values in this file unchanged (White's
extra options never help when the forced line is already optimal), and the resulting
two-player value satisfies a *determinacy/minimax* identity: `v(P)` equals both the
least White-forcing ordinal and the Black-optimal supremum. **The key insight is** that
the ordinal value is a well-founded game rank, so `Ordinal.lt_wf` (used pervasively in
`Logic/TransfiniteRefinement.lean`) should drive an induction showing the `min`/`sup`
recursion is the unique fixed point of the strategic value. **Why now?** The `inf` side
needs only `Ordinal`'s conditionally-complete structure, already exercised here for
`sup`; pairing it with the existing well-foundedness lemmas makes the determinacy proof a
finite assembly rather than new theory.

### 4. Sharp non-achievability: no position has value a "limit-of-limits" gap

Conjecture (falsifiable): in the *countably-branching* model used here, no `Game` has
value an uncountable ordinal, and the achievable values are exactly the ordinals
`< ω_1^{CK}`-style bound determined by the branching cardinality — concretely, replacing
`ℕ` by an index type of cardinality `κ` raises the ceiling to `ω^ω` computed in the
`κ`-ary normal form, and *no further*. **The key insight is** that `Ordinal.bddAbove_range`
(the lemma making every `bmove` supremum legitimate) ties the reachable values directly to
the cofinality of the index type. **Why now?** Every supremum in the file is already
mediated by `bddAbove_range`, so a cardinality-parameterized version of `Game` would
expose the ceiling as a single cofinality computation — a clean, decidable falsification
target (find a position exceeding the bound, or prove the bound).

### 5. Computable normal-form invariant and decidability of value comparison

Conjecture: there is a *computable* normal form `nf : Game → CNF` with
`v(P) = ⟦nf P⟧`, making `v(P) ≤ v(Q)` and `v(P) = v(Q)` decidable for the finite-term
positions generated by `wmove`, `graft`, `gmul`, `bmove`. **The key insight is** that the
three value identities (`+`, `·n`, diagonal `sup`) are exactly the constructors of an
ordinal Cantor normal form below `ω^ω`, so the value of any term-built position is a
finite symbolic ordinal that can be compared lexicographically. **Why now?** With
`gval_graft`, `gval_gmul`, `gval_gpow` proven, the soundness of such a normal form is a
direct structural induction; only the `CNF` datatype and its comparison need to be
written, turning transfinite-chess value comparison into a verified decision procedure.
