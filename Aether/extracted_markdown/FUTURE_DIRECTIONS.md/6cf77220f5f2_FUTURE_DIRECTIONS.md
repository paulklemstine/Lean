# Future Directions — Collatz Reachability and Proof-Theoretic Barriers

The file `Catalog/Logic/CollatzOddReduction.lean` lifts the pointwise structural
results of `Logic.CollatzModularDynamics` (powers of two, fixed points, short
cycles) to the global *reachability* relation `Reaches n := ∃ k, C^[k] n = 1`, and
proves a clean structural reduction: the Collatz conjecture is **equivalent** to
its restriction to odd positive integers (`collatz_iff_odd`), powered by the
doubling-invariance lemma `reaches_double`. The following conjectures extend this
reachability framework. Each is stated to be testable and falsifiable: either a
formal Lean proof closes it, or a single explicit numeric counterexample refutes
it.

## 1. The 2-adic seed reduction is sharp: residue-2 reduction fails

**Conjecture.** There is *no* analogue of `reaches_double` modulo 3, i.e. the
statement "`Reaches (3 * n) ↔ Reaches n` for all `n`" is **false**, and a small
explicit `n` witnesses the failure of the forward implication's naive proof.

The key insight is that doubling invariance is special: it works only because
`C (2*n) = n` is an *exact* one-step retraction, whereas multiplication by 3 lands
on an odd number whose first Collatz step *expands* rather than contracts. Probing
which arithmetic operations admit a `reaches_*` invariance lemma isolates exactly
the structural feature (a contracting retraction `C ∘ op = id`) that the reduction
exploits.

**Why now?** We already have `C_two_mul : C (2 * n) = n` as the lone algebraic
identity behind the entire reduction; testing its non-existence for other
multipliers is a direct, mechanical extension that pins down the boundary of the
method, and is decidable by `#eval` search for any candidate counterexample.

## 2. Bounded-stopping reachability is decidable and monotone

**Conjecture.** Define `ReachesIn b n := ∃ k ≤ b, (C^[k]) n = 1`. Then for every
bound `b`, the predicate `ReachesIn b` is `Decidable`, and the doubling lemma
refines quantitatively to `ReachesIn (b+1) (2*n) ↔ ReachesIn b n` for `n > 0`.

The key insight is that `reaches_double` actually carries a *step-count*: doubling
costs exactly one extra Collatz step, so the existential bound shifts by one. This
upgrades the qualitative equivalence to an exact arithmetic relation between
stopping times of `n` and `2n`.

**Why now?** Our proof of `reaches_double` already produces the witness `k+1` from
`k` explicitly (via `Function.iterate_succ_apply`), so the step-counting version is
a quantitative annotation of a proof we have in hand, and decidability follows from
bounded search.

## 3. Total stopping time of odd seeds dominates the conjecture's complexity

**Conjecture.** Let `T n` be the least `k` with `(C^[k]) n = 1` (defined when
`Reaches n`). Then `T (2*n) = T n + 1` for `n > 0`, and consequently the supremum
of `T` over any interval `[1, N]` is attained at an *odd* number once `N ≥ 2`.

The key insight is that even inputs are never "harder" than their odd halves: every
even number simply inherits its odd seed's trajectory with one cheap halving step
prepended, so the genuine dynamical complexity lives entirely on the odd skeleton —
the same skeleton our `collatz_iff_odd` identifies as the logically sufficient
sub-problem.

**Why now?** With `collatz_iff_odd` proving odd numbers are *logically* sufficient,
the natural follow-up is that they are also *quantitatively* extremal; `reaches_double`
gives the `+1` recurrence needed for the stopping-time identity directly.

## 4. The Syracuse map has no cycle through any power of two except the trivial one

**Conjecture.** Strengthen `syracuse_no_fixed_point`: the only periodic point of
`syracuse` that is a power of two is `1` itself, and more generally `syracuse` has
no positive 2-cycle (`syracuse (syracuse n) = n` forces `n ∈ {1, 2}` and these are
not genuine 2-cycles).

The key insight is that the accelerated map compresses the `1 → 4 → 2 → 1` Collatz
cycle into the much shorter `1 → 2 → 1` orbit, so ruling out short Syracuse cycles
is strictly easier than for `C` and reduces to a finite modular case analysis of
`(3n+1)/2` against `n` — exactly the `split_ifs <;> omega` pattern that closed the
fixed-point case.

**Why now?** `syracuse_no_fixed_point` already demonstrates that the period-1 case
is a one-line modular argument; the period-2 case is the immediate next rung and
shares the same proof skeleton.

## 5. Reachability is the largest C-backward-closed set containing 1

**Conjecture.** `Reaches` is exactly the smallest set `S` with `1 ∈ S` and the
backward-closure property `C n ∈ S → n ∈ S`; equivalently, `Reaches` is the
reflexive-transitive backward orbit of `1`. Formally, `Reaches n ↔
Relation.ReflTransGen (fun a b => C a = b) n 1`.

The key insight is that our two helper lemmas `reaches_one` and
`reaches_of_reaches_C` are precisely the *constructors* of the inductive backward
orbit, so reachability is not merely *implied by* but *characterized as* the
inductive closure — turning an existential-over-iterates definition into a clean
relational one amenable to relation-algebra reasoning.

**Why now?** We have already isolated the two closure rules as standalone lemmas;
recognizing them as the generators of `Relation.ReflTransGen` is a structural
repackaging that unlocks Mathlib's substantial `ReflTransGen` API for all downstream
Collatz reachability work.
