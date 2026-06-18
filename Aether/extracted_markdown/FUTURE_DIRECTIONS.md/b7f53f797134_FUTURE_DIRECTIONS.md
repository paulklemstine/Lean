# Future Directions — Reverse Mathematics of Ramsey's Theorem for Pairs

## Synthesis

This cycle repaired and extended the catalog's reverse-mathematics module on
Ramsey's theorem for pairs. The pre-existing module
`Shared/ReverseMath/Implications.lean` depended on a `Shared.ReverseMath.Defs`
file that was absent from the project, so the whole development was
unbuildable. We reconstructed `Defs.lean` from the exact usage sites (recovering
`PairColoring`, `IsHomogeneous`, `pairColoringOfUnary`, `IsStable`, and the
principles `RT1_2_Bool`, `RT1_k`, `RT2_2`, `SRT2_2`, `COH`), restoring the
catalog's 9 theorems, and then added the missing *foundational atoms* of the
RT²₂ programme in `Shared/ReverseMath/SeetapunHierarchy.lean`:

1. **`coh_proof`** — the cohesiveness principle **COH** holds in CIC, by a
   genuine nested-pigeonhole construction (a ⊆-decreasing tower of infinite sets
   deciding each `Rᵢ`, plus a strictly increasing diagonal selector).
2. **`pairColoringOfUnary_stable`** + **`srt2_2_implies_rt1_2_genuine`** — the
   min-colouring is *stable*, which lets the reduction SRT²₂ → RT¹₂ be carried
   out *honestly* through SRT²₂ (the catalog's version silently bypassed its own
   hypothesis).
3. **`rt2_k_proof`** — the infinite Ramsey theorem for pairs with **k** colours,
   the multicolour generalization of `rt2_2_proof`, via Erdős–Rado over `RT¹ₖ`.
4. **`rt2_2_iff_srt2_2_and_coh`** — the Cholak–Jockusch–Slaman equivalence
   `RT²₂ ↔ SRT²₂ ∧ COH`, now with COH supplied as a theorem rather than assumed.

## Results Summary

| Result | File | Status |
|---|---|---|
| `coh_proof : COH` | `SeetapunHierarchy.lean` | proved (axioms: propext, Classical.choice, Quot.sound) |
| `pairColoringOfUnary_stable` | `SeetapunHierarchy.lean` | proved |
| `srt2_2_implies_rt1_2_genuine` | `SeetapunHierarchy.lean` | proved (uses the hypothesis) |
| `rt2_k_proof : RT2_k k` | `SeetapunHierarchy.lean` | proved |
| `rt2_2_iff_srt2_2_and_coh` | `SeetapunHierarchy.lean` | proved |
| `Defs.lean` (reconstructed) | `Defs.lean` | builds `Implications.lean` again |

All main results are `sorry`-free and depend only on the standard CIC axioms.

---

## Direction 1 — Hypergraph Ramsey: `RTⁿₖ` for all arities

The current development stops at pairs (arity 2). The natural next object is
`RTⁿₖ`: every `k`-colouring of `n`-element subsets of `ℕ` has an infinite
homogeneous set. Conjecture: `∀ n k, 0 < k → RTⁿₖ` is provable in CIC by
induction on `n`, the base case `n = 1` being `rt1_k_proof` and the step reusing
the Erdős–Rado skeleton of `rt2_k_proof` with the "tail colouring"
`a ↦ (colour of the (n−1)-sets extended by a)`.

The key insight is that the inductive step of Erdős–Rado is *colour-agnostic*:
the only place arity enters is in forming, from an `(n+1)`-colouring `c` and a
fixed minimum `a`, the `n`-colouring `c_a(x) = c(a, x)` on the remaining points —
so the proof of `rt2_k_proof` is literally the `n = 1 → n = 2` instance of a
single uniform recursion. This is *falsifiable*: a failure would show up as an
arity where the tail-colouring reduction does not preserve homogeneity.

Why now? `rt2_k_proof` already isolates the reusable one-step lemma (pick an
element, pigeonhole the tail colours, recurse); generalizing the index from
`ℕ → ℕ → Fin k` to `Finset ℕ → Fin k` restricted to `n`-sets is a mechanical
refactor that the existing proof structure invites.

## Direction 2 — A computable counterexample certifying `RT¹ₖ ⇏ RT²₂`

The catalog records, as metamathematical remarks (`rt1_2_does_not_trivially_yield_rt2_2`,
`srt2_2_strictly_weaker_note`), the separations that make RT²₂ interesting:
RT¹₂ does not imply RT²₂, and SRT²₂ does not imply COH, over RCA₀. These are
currently `True`. Conjecture: one can formalize, *inside Lean*, a recursion-
theoretic witness object — a computable 2-colouring of pairs all of whose
infinite homogeneous sets compute `∅'` — as an explicit function plus a proof
that no homogeneous set is `Δ⁰₁`.

The key insight is that the separation is not about provability in CIC (where
everything here is a theorem) but about the *complexity of the witnesses*: the
right Lean formalization replaces "RCA₀ ⊬" with "every homogeneous set has
Turing degree `≥ 0'`", a statement that is concrete, quantitative, and
falsifiable by exhibiting a low homogeneous set.

Why now? We now own clean `Prop`-level statements of every principle and a
constructive Erdős–Rado proof; layering a `Computable`/`Turing`-degree predicate
on top of `IsHomogeneous` is the minimal addition needed to state the
separations honestly.

## Direction 3 — Stable colourings have *limit colourings*

`IsStable C` says each row `c(i, ·)` is eventually constant. Conjecture: every
stable `PairColoring` induces a total `limitColour : ℕ → Bool` with
`∀ i, ∃ N, ∀ j ≥ N, C.color i j = limitColour i`, and SRT²₂ is *equivalent* to
"RT¹₂ applied to `limitColour`" — i.e. SRT²₂ ↔ RT¹₂ over this vocabulary,
strengthening `srt2_2_implies_rt1_2_genuine` to a biconditional.

The key insight is that stability collapses the binary problem to a unary one
pointwise: the limit colouring is the genuine bridge, and `pairColoringOfUnary`
is exactly the section of this collapse (its limit colouring is `f` itself).

Why now? `pairColoringOfUnary_stable` already exhibits the canonical stable
colouring whose limit is `f`; defining `limitColour` via `Nat.find`/choice on the
stability witness and proving the round-trip is a short, self-contained next
step that converts an implication into an equivalence.

## Direction 4 — Quantitative finite Ramsey from the infinite proof

The Erdős–Rado construction in `rt2_k_proof` is "infinitary" but its one-step
lemma is finite: from `N` points one extracts a long monochromatic-tail chain.
Conjecture: extracting the *finite* content of `rt2_k_proof` yields a Lean proof
of the finite Ramsey number bound `R_k(m) ≤ k^{k·m}` (tower-free, Erdős–Rado
style) with an explicit, `#eval`-able upper bound function.

The key insight is that the diagonal selector in the infinite proof, truncated
at depth `m`, *is* the finite pigeonhole iteration that bounds `R_k(m)`; the
infinite homogeneous set is the `m → ∞` limit of finite homogeneous chains.

Why now? The infinite proof is in hand and already factored through a single
"pick + pigeonhole the tail" lemma; making that lemma quantitative (counting how
much of `S` survives one step) turns it directly into a recurrence for the
finite Ramsey number, which is then a decidable arithmetic fact.

## Direction 5 — `COH` as a fixed point: cohesive sets via filters

Our `coh_proof` builds a cohesive set by an explicit tower + diagonal. Conjecture:
the same set arises as a member of any nonprincipal ultrafilter refining the
"co-decided" filter generated by the tower, giving a one-line `Filter`-theoretic
proof of COH and, more importantly, a reusable lemma
`exists_cohesive_of_filter` connecting `COH` to Mathlib's `Filter`/`Ultrafilter`
API.

The key insight is that "almost contained in `Rᵢ` or almost disjoint from it"
is precisely the statement that the cohesive set is `Rᵢ`-decided *in the cofinite
filter*; an ultrafilter chooses one side of every `Rᵢ` coherently, which is
exactly cohesiveness.

Why now? We have a concrete cohesive set and the exact decidedness invariant it
satisfies (`C (i+1) ⊆ Rᵢ ∨ Disjoint (C (i+1)) Rᵢ`); recognizing this invariant
as an ultrafilter condition is the bridge to Mathlib's filter library and would
let later cycles import cohesiveness as a black box.
