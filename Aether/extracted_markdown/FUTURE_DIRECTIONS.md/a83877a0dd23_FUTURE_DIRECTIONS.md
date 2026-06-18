# Future Directions

This cycle delivered two coupled bodies of work: a new, fully-proven formalization
of **paraconsistent dream logic** (`Catalog/Logic/DreamLogic.lean`) and a repair of
the **Carmichael / Fibonacci primitive-divisor** chain (`Catalog/Shared/CarmichaelHelper.lean`,
plus build fixes in `lakefile.toml` and `Catalog/Shared/Fib_gcd_identity.lean`). The
prime-index case of Carmichael's theorem is now proven from scratch, and both priority
targets (`CarmichaelComposite`, `Fib_gcd_identity`) compile. The work below charts the
next cycle.

## 1. Close the composite tail of Carmichael's theorem (`n > 10000`)

The single remaining `sorry` in `Catalog/Shared/CarmichaelProof.lean` is the infinite
tail of `fib_carmichael_composite`: for every *composite* `n > 10000`, the Fibonacci
number `F(n)` has a primitive prime divisor. The finite range `13 ≤ n ≤ 10000` is
already discharged by a verified `native_decide` computation of the primitive part;
only the unbounded tail is open.

**The key insight is** that `F(n) = ∏_{d ∣ n} Φ(n,d)` where `Φ(n,·)` is the integer
*Fibonacci cyclotomic value*, the `Φ` are pairwise almost-coprime, and a prime divides
`Φ(n,n)` non-primitively *only* when it divides `n` — and then exactly to the first
power. Hence the only obstruction to a primitive divisor is the size inequality
`|Φ(n,n)| > P(n)` (the largest prime factor), which follows from the Lucas growth
bound `|Φ(n,n)| ≥ ((1+√5)/2)^{φ(n)-1}` once `φ(n)` is large — and `φ(n) ≥ √(n/2)`
makes this automatic for `n > 10000`.

**Why now?** With the prime case, the entry-point lemmas (`fibEntryPt_dvd_of_fib_dvd`,
`primitive_of_entryPt_eq`), and the computational `primPart` infrastructure already in
place, the missing piece is precisely the *cyclotomic value* and its size bound. This
is a well-scoped, self-contained module to build next: define `Φ`, prove the divisor
product `∏_{d∣n} Φ(n,d) = F(n)`, prove the LTE multiplicity bound, then the golden-ratio
size estimate. The decomposition is falsifiable lemma-by-lemma (each `Φ` identity can be
unit-tested on small `n` with `#eval`).

## 2. Classical recapture for dream consequence

`PEntails` (preferred-model, consistency-first consequence) is proven non-monotone
(`dream_nonmonotone`) and cumulative (`dream_cautious_monotone`). The natural next
theorem is **classical recapture**: on any classically satisfiable premise set,
`PEntails Γ φ` coincides exactly with *classical* two-valued entailment.

**The key insight is** that `HasClassicalModel Γ` collapses the disjunction in `PEntails`
to its left branch, and `Classical2` valuations are in bijection with Boolean
assignments under which `eval` reduces to ordinary propositional evaluation — so the
four-valued semantics is conservative over classical logic whenever no contradiction
is present.

**Why now?** The infrastructure (`Classical2`, `TwoValued`, `classical_regime_explodes`)
already isolates the two-valued fragment; recapture is the theorem that makes
"dream logic = classical logic until you contradict yourself" precise and falsifiable
(it predicts that *every* classical tautology is `PEntails`-derivable from a consistent
context, and conversely).

## 3. AGM-style belief retraction inside dream logic

The headline phenomenon — adding `p` forces retraction of `q` — invites a genuine
**belief-revision operator** `revise : List (Form α) → Form α → List (Form α)` whose
preferred-model consequences satisfy analogues of the AGM postulates (success,
inclusion, vacuity, consistency-preservation).

**The key insight is** that minimizing *gluts* (atoms assigned the value `B`) gives a
canonical preference order on FDE models, and retraction is exactly the move from the
glut-free preferred set to the minimal-glut preferred set when new information makes
the former empty — so revision is a *change of preferred-model class*, not a syntactic
deletion.

**Why now?** `dream_cautious_monotone` already supplies one half of AGM-cumulativity
(cautious monotony); pairing it with a *cut* lemma yields a full cumulative consequence
relation, the standard bridge between non-monotonic logic and belief revision. The
postulates are individually testable as Lean theorems on the existing `PEntails`.

## 4. A parametric bilattice family and a paraconsistency–primitivity bridge

Generalize `V4` from one "told-true / told-false" Boolean pair to a lattice-valued pair
over an arbitrary bounded distributive lattice `L`, yielding a family of De Morgan
bilattices `V(L)`. Conjecture: non-explosion and `PEntails`-non-monotonicity persist
for every nontrivial `L`, and fail exactly when `L` is the two-element lattice.

**The key insight is** that explosion fails **iff** negation has a fixed point (the glut
`B = ¬B`), and the existence of such a fixed point is a purely *order-theoretic*
property of `L` — connecting the logical phenomenon to the algebraic structure already
formalized via `V4.neg_glut` and `V4.neg_neg` (a De Morgan involution). This is the same
"unique distinguished element" pattern as the *entry point* `z(p)` in the Carmichael
work: a primitive prime divisor is the order-minimal index, just as a glut is the
negation-fixed value.

**Why now?** The `V4` algebra is already proven to be a De Morgan algebra; abstracting
`Bool` to `L` is a mechanical generalization that turns three concrete theorems into a
parametrized family, and the fixed-point characterization of non-explosion is a crisp,
falsifiable equivalence.

## 5. A sound and complete proof calculus for FDE dream entailment

Define a Gentzen-style (or tableau) calculus `⊢c` for the plain relation `Entails`
and prove **soundness and completeness**: `Γ ⊢c φ ↔ Entails Γ φ`. Then lift it to a
*default* calculus matching `PEntails`.

**The key insight is** that FDE's four values factor as two independent Boolean
coordinates (`t` and `f`), so a sequent calculus splits into two ordinary classical
derivations — completeness reduces to two copies of Boolean completeness, which is
already within reach of Mathlib's decidability tooling.

**Why now?** With `eval`, `Entails`, and the witness-construction technique
(`explosion_fails`, `disjunctive_syllogism_fails`) established, a finite-model-property
proof of completeness is directly accessible, and it would make the entire dream-logic
file a self-contained, machine-checked metatheory rather than a semantic fragment.
