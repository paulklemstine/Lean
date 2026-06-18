# Future Directions: Density, Lattices, and the Honest Top of the p-Degree Poset

## Synthesis

This cycle (`Catalog/Logic/ProofComplexity/SimulationChain.lean`) turned the *two-point*
non-triviality of the previous cycle into a full *order-theoretic skeleton* of the simulation
preorder of Cook–Reckhow proof systems, and along the way **settled two of the previous cycle's
five conjectures** — one positively, one by refutation.

The pivot was a single structural device: the uniform family `sizeSystem g` (a proof of `n`
*is* `n`, with size `g n`), which subsumes the ad-hoc `linSystem = sizeSystem id` and
`fibSystem = sizeSystem Nat.fib` from `SimulationDegrees.lean`. The growth characterization
`simulates_sizeSystem_iff` shows that simulation between two such systems is *exactly* a
polynomial-domination comparison of their size functions: `sizeSystem g` p-simulates
`sizeSystem h` iff some monotone polynomially-bounded `f` satisfies `g n ≤ f (h n)` for all `n`.
This collapses questions about the p-degree poset into questions about the quasi-order of
growth rates under polynomial domination — a purely arithmetic object.

Two consequences followed.

1. **Direction 1 (an unbounded strict chain) is now a theorem.** Iterating the Fibonacci gap,
   `growthChain k = Nat.fib^[k]`, produces systems whose degrees form an infinite strictly
   increasing chain (`exists_strictMono_pdegree_chain`), so the poset of p-degrees is `Infinite`
   (`pdegrees_infinite`). The cheap direction of each strict step is the additive bound
   `n ≤ Nat.fib n + 1` (`nat_le_fib_add_one`); the expensive direction is the eventual
   polynomial-domination failure `(n+2)^k < Nat.fib n` for large `n` (`fib_eventually_gt_poly`),
   reused along the unbounded range of each chain level (`growthChain_unbounded`).

2. **Direction 4 (no p-optimal system) is refuted — with a sharper truth.** In the unrestricted
   abstract model the constant-size system `sizeSystem (fun _ => 0)` p-simulates *every* system
   over `ℕ` (`sizeSystem_zero_isBot`): it is a least element of the simulation preorder, i.e. a
   p-optimal system *does* exist abstractly. The previous cycle's diagonalization argument fails
   precisely because it tacitly assumed size functions cannot vanish. The honest content of the
   Cook–Reckhow optimality question is therefore *not* order-theoretic but lives in the
   *honesty/complexity constraints* one places on `size` — which Direction 4′ below makes precise.

## Results Summary

| Theorem | Statement |
|---|---|
| `sizeSystem` | Uniform family of proof systems over `ℕ`: proof of `n` is `n`, size `g n` |
| `simulates_sizeSystem_iff` | Simulation of size systems = polynomial-domination of growth rates |
| `simulates_sizeSystem_of_le` | Pointwise `g ≤ h` already yields simulation |
| `sizeSystem_zero_isBot` | The zero-size system is a least element (p-optimal) — refutes Direction 4 |
| `nat_le_fib_add_one` | `n ≤ Nat.fib n + 1` (cheap blow-up direction) |
| `fib_eventually_gt_poly` | `Nat.fib` eventually exceeds every fixed polynomial |
| `growthChain` / `_mono` / `_unbounded` | The iterated-Fibonacci tower and its monotonicity/unboundedness |
| `simulates_chain_succ` / `not_simulates_chain_succ` | Consecutive levels are strictly comparable |
| `exists_strictMono_pdegree_chain` | An infinite strictly increasing chain of p-degrees |
| `pdegrees_infinite` | The poset of p-degrees is infinite |

---

## Direction 1′ — The p-degree poset is order-dense

We exhibited an infinite strict chain; the next falsifiable claim is that the simulation order is
**dense**: whenever `⟦sizeSystem g⟧ < ⟦sizeSystem h⟧`, there is a size system strictly between
them. The key insight is that `simulates_sizeSystem_iff` reduces density to a *growth
interpolation* problem — given `g` polynomially dominated by `h` but not conversely, one needs an
intermediate rate `m` with `g ≼ m ≼ h` and both dominations strict, and the geometric mean of
exponents (e.g. `m n = Nat.fib^[1] (g n) ⊔ ...`, or `m = ` a "half-iterate" of the Fibonacci gap)
is the natural candidate. Why now? The chain already realizes the *discrete* skeleton
`growthChain k`; density only asks to subdivide one step, and the two load-bearing lemmas
`nat_le_fib_add_one` and `fib_eventually_gt_poly` are exactly the tools needed to certify that a
proposed interpolant is strictly between its neighbours, so the whole problem is now a
self-contained growth-rate inequality rather than anything about proof systems.

## Direction 2′ — The p-degree poset is not a lattice

The conjecture, inherited and now made constructible, is that
`Antisymmetrization (ProofSystem ℕ) (· ≤ ·)` is **not** a lattice: there are two incomparable
p-degrees with no least upper bound. The key insight is that incomparability is now manufacturable
through `simulates_sizeSystem_iff`: take `g` that is super-polynomially large on the even integers
and linear on the odd ones, and `h` the swap; then neither `g ≼ h` nor `h ≼ g`, because any
polynomial blow-up would have to absorb a Fibonacci gap on an unbounded index set, contradicting
`fib_eventually_gt_poly`. Why now? Every ingredient is in place — the size-system family makes the
two witnesses explicit, `not_simulates_chain_succ` is the exact template for the two
non-simulations, and Mathlib's `SemilatticeSup` predicate turns "no least upper bound" into a
finite refutation over the four explicit degrees `⟦g⟧, ⟦h⟧` and two candidate joins.

## Direction 3′ — A `GrowthClass` typeclass making the order parametric in the blow-up class

The entire development used only three facts about the polynomial class: it contains the identity,
it is closed under composition, and it is closed downward under pointwise domination
(`polyBounded_id`, `polyBounded_comp`, `polyBounded_of_le`). The conjecture is that abstracting
these into `class GrowthClass (C : (ℕ → ℕ) → Prop)` yields a simulation `Preorder` and a p-degree
poset for *every* such class, with the infinite-chain theorem surviving verbatim whenever
`¬ C Nat.fib`. The key insight is that the chain construction is *generic over the gap*: replace
`Nat.fib` by any `s ∉ C` for which `n ≤ s n + 1` and "`s` eventually escapes `C` on unbounded
ranges" hold, and `exists_strictMono_pdegree_chain` re-runs unchanged. Why now? The three closure
lemmas are already isolated as standalone statements, so promoting them to typeclass fields is
mechanical, and it would let the next cycle locate *where in the growth hierarchy* (polynomial,
quasi-polynomial `2^{(log n)^c}`, sub-exponential) the first strict separation appears.

## Direction 4′ — Honest p-optimality: restoring the diagonalization

Because `sizeSystem_zero_isBot` shows the unrestricted model has a least (p-optimal) element, the
genuine Cook–Reckhow question must forbid the vanishing-size loophole. The falsifiable conjecture
is: under an **honesty hypothesis** `H P : ∀ pf, |P.proves pf| ≤ P.size pf` (the size of a proof is
at least the size of the theorem it certifies, for a fixed encoding `|·| : ℕ → ℕ` that is itself
unbounded), there is **no** p-optimal system over `ℕ` — for any honest candidate `P` one builds
`sizeSystem (fun n => |n| + Nat.fib n)`, which `P` cannot p-simulate. The key insight is that the
honesty bound reintroduces a *floor* on proof size that the diagonal Fibonacci gap can exceed,
exactly the ingredient the abstract refutation was missing. Why now? `no_simulation_of_hard`
already reduces non-simulation to `¬ PolyBounded s`, and `fib_eventually_gt_poly` supplies the
super-polynomial diagonal, so the only new content is threading the honesty hypothesis through the
existential — a clean, well-posed addition rather than a new theory.

## Direction 5′ — The growth quasi-order embeds as a sub-poset of p-degrees

The map `g ↦ ⟦sizeSystem g⟧` sends the quasi-order of growth rates under polynomial domination
into the p-degree poset. The conjecture is that this map is an **order embedding** of
`(ℕ → ℕ) / (polynomial domination)` onto a sub-poset of the p-degrees, i.e. it is injective on
degrees and reflects the order. The key insight is that `simulates_sizeSystem_iff` is *precisely*
the statement that the map is full and faithful for the order relation — `⟦sizeSystem g⟧ ≤
⟦sizeSystem h⟧` holds iff `g` is polynomially dominated by `h` — so the embedding claim is now a
two-line corollary plus an injectivity argument powered by `not_simulates_chain_succ`. Why now?
This reframes the whole order-theoretic program: every structural question about p-degrees of size
systems (chains, antichains, density, lattice failure) becomes a question about the much more
concrete growth quasi-order, which classical growth-rate theory already understands, turning the
proof-complexity poset into a faithful mirror of Hardy-field-style growth comparison.
