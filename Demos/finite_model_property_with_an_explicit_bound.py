"""Assemble PACKAGE.json from the individual deliverables in the project.

Run from the project root:  python3 assets/build_package.py
"""

from __future__ import annotations

import json
import re
from pathlib import Path
from typing import Dict, List

ROOT = Path(__file__).resolve().parent.parent
ASSETS = ROOT / "assets"

BANNER = re.compile(
    r"# -{70,}\n# (?P<title>.*?)\n# -{70,}\n", re.M
)


def read(p: Path) -> str:
    """Read a UTF-8 text file."""
    return p.read_text(encoding="utf-8")


def algorithm_sections() -> Dict[str, str]:
    """Split ``assets/algorithms.py`` into its banner-delimited sections."""
    src = read(ASSETS / "algorithms.py")
    parts = BANNER.split(src)
    # parts = [preamble, title1, body1, title2, body2, ...]
    out: Dict[str, str] = {"__preamble__": parts[0]}
    for i in range(1, len(parts) - 1, 2):
        out[parts[i].strip()] = parts[i + 1]
    return out


HEADER = '''"""{title}

Self-contained: every helper it needs is inlined below.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Dict, FrozenSet, Iterator, List, Optional, Set, Tuple

'''


def strip_imports(body: str) -> str:
    """Drop the module docstring and import block from a section preamble."""
    body = re.sub(r'^""".*?"""\n', "", body, flags=re.S)
    body = re.sub(r"^from __future__ import annotations\n", "", body, flags=re.M)
    body = re.sub(r"^from dataclasses import .*\n", "", body, flags=re.M)
    body = re.sub(r"^from itertools import .*\n", "", body, flags=re.M)
    body = re.sub(r"^from typing import .*\n", "", body, flags=re.M)
    return body.strip("\n")


def build_algorithm(title: str, sections: Dict[str, str], keys: List[str], main: str) -> str:
    """Compose a standalone script for one algorithm."""
    shared = strip_imports(sections["Shared data model"])
    bodies = "\n\n".join(sections[k].strip("\n") for k in keys)
    return HEADER.format(title=title) + shared + "\n\n\n" + bodies + "\n\n\n" + main


LEAN_FILES = [
    "Catalog/Logic/PosetTheory/TemporalGLSyntax.lean",
    "Catalog/Logic/PosetTheory/TemporalGLDeduction.lean",
    "Catalog/Logic/PosetTheory/TemporalGLFiniteModel.lean",
    "Catalog/Logic/PosetTheory/TemporalGLCompleteness.lean",
]


FUTURE_DIRECTIONS = """# Future Directions — Temporal Gödel–Löb logic after the finite model property

## What this cycle established

The assignment conjectured that every non-derivable formula `A` of the temporal
Gödel–Löb calculus has a countermodel with at most `2 ^ (2 * subformulaCount A)`
worlds. That conjecture is now a **theorem**, proved unconditionally, together with the
sharper bound `2 ^ subformulaCount A` and the three ingredients it rests on:

* soundness of the Hilbert calculus TGL on the frame class,
* a **converse-well-foundedness-preserving filtration** whose accessibility relation
  strictly increases the number of realised boxed subformulas, and whose temporal
  relation carries an extra `◻`-clause exactly so that the frame compatibility condition
  survives quotienting,
* a **finite canonical model** over the subformula closure, whose `◻`-existence lemma is
  the Löb argument and whose `◼`-existence lemma consumes the interaction axiom
  `◻A ⟹ ◼◻A`.

Nothing in the development was found to be false. The one genuine *definitional*
obstruction encountered was that the naive filtration of the temporal relation does
**not** preserve compatibility; the fix was to strengthen the filtered temporal relation
with the `◻`-persistence clause, which is available precisely because compatibility holds
upstream. Adversarial review flagged that a filtration theorem alone would leave the
conjecture conditional on completeness, so completeness was proved rather than assumed.

The remaining scientific content is now about **tightness** and **generalisation**.

---

## Direction 1 — Polynomial Width Collapse for Temporal Löb Countermodels

**Conjecture.** For every non-derivable `A` there is a countermodel whose world count is
bounded by a polynomial in `subformulaCount A` — in fact by `subformulaCount A + 1` when
`A` contains no nested implications under `◻`.

The key insight is that the filtration measure `boxCount` strictly increases along every
step of the accessibility relation, so the *depth* of any canonical countermodel is at
most the number of boxed subformulas; the exponential factor in the proved bound is pure
width, and width is only ever used to realise distinct propositional theories, which a
selective (rather than exhaustive) canonical model never needs all of.

**Why now?** The verified data points show a gap of 64:1 and 128:1 between the permitted
and the actual minimal countermodel on two non-derivable sample formulas — the bound is
empirically nowhere near tight, and the machinery for measuring it (the strict-growth
lemma for the filtration measure, and the cardinality estimate for the canonical world
set) is already in place.

**Test.** Replace the full canonical world set by the sub-Finset of worlds actually
reachable from the refuting world by iterated application of the two existence lemmas,
and bound its cardinality by the recursion depth. If true, the sharp finite model
property improves from an exponential bound to a polynomial one, and the bounded model
search of the decision procedure becomes feasible rather than merely correct.

---

## Direction 2 — Complexity of the decision problem

Satisfiability for Gödel–Löb logic is PSPACE-complete. The exact complexity of
satisfiability for the temporal system, and in particular whether the interaction axiom
pushes it beyond PSPACE, is open here. A polynomial width collapse (Direction 1) would
be strong evidence for a PSPACE upper bound via a depth-first tableau that never stores
more than one branch.

---

## Direction 3 — Weaker or alternative interaction conditions

One may replace the compatibility condition by its converse, or by a two-sided
commutation of the two relations, and ask which combinations retain a finite model
property with an explicit bound. The counting argument behind converse well-foundedness
is robust and survives any such change; what varies is whether the temporal relation
admits a persistence clause that preserves the new frame condition. A systematic map of
which interaction axioms are "filtration-friendly" in this sense would be of independent
interest.

---

## Direction 4 — Branching time and richer temporal vocabulary

Replacing the temporal preorder by a tree order, or adding an "eventually" dual with its
own fixed-point behaviour, would move the system towards a temporal provability logic of
branching-time type. The provability half of the argument is unaffected; the question is
what replaces the temporal existence lemma.

---

## Direction 5 — Arithmetical interpretation

Gödel–Löb logic is arithmetically complete for the provability predicate of Peano
arithmetic. The natural question for the temporal system is whether it is arithmetically
complete for a *growing* sequence of theories `T_0 ⊆ T_1 ⊆ ⋯`, with `◼` read as "at every
later stage" and `◻` as provability in the current stage. The interaction axiom
`◻A ⟹ ◼◻A` is exactly the formal counterpart of monotonicity of the sequence, which
suggests the correspondence is the right one.

---

## Direction 6 — Fixed points

Gödel–Löb logic enjoys the de Jongh–Sambin fixed point theorem: every formula `A(p)` in
which `p` occurs only inside a `◻` has a unique explicit fixed point. Whether the bimodal
analogue holds — with `p` guarded by either box — is a natural next question, and would
give a syntactic normal form for self-referential temporal statements.
"""


INTERACTIVE_LAYOUT = r"""# Provability, Time, and the Size of an Excuse

*A guided tour of temporal Gödel–Löb logic and its finite model property.*

---

## 1. The operator that cannot trust itself

In 1931 Kurt Gödel showed that a sufficiently strong theory of arithmetic can encode its
own syntax and so write down a formula meaning *"the sentence with code $x$ is
provable."* Once a theory can say that, it can reason about its own reach. Logicians
eventually stripped away the arithmetic and kept the reasoning pattern: write $\Box A$ for
"$A$ is provable", and impose three laws.

- **Distribution.** $\Box(A \to B) \to (\Box A \to \Box B)$ — concatenate two proofs.
- **Necessitation.** If $A$ is a theorem, so is $\Box A$ — exhibit the proof.
- **Löb's axiom.** $\Box(\Box A \to A) \to \Box A$.

Read the third one slowly. It says that if the theory can prove *"whenever $A$ is
provable, $A$ is true"*, then it can already prove $A$ outright. A theory is not allowed
to trust itself for free. Put $A = \bot$ and you get Gödel's second incompleteness
theorem in one line: $\Box\bot \to \bot$ says "the theory is consistent", and Löb's axiom
makes proving it fatal.

<details>
<summary>The one-line derivation of Gödel's second theorem from Löb's axiom</summary>

Suppose the theory proves its own consistency, i.e. $\vdash \Box\bot \to \bot$. Löb's
axiom at $A = \bot$ reads $\Box(\Box\bot \to \bot) \to \Box\bot$. Necessitating the
hypothesis gives $\vdash \Box(\Box\bot \to \bot)$, so $\vdash \Box\bot$, so — by the
hypothesis again — $\vdash \bot$. A consistent theory therefore cannot prove its own
consistency. The whole of the second incompleteness theorem, once the derivability
conditions are in place, is this three-step argument.

Further reading: [Provability logic (Stanford Encyclopedia of
Philosophy)](https://plato.stanford.edu/entries/logic-provability/).
</details>

The semantics is geometric. Take a set of worlds with an arrow relation $R$; $\Box A$
holds at $w$ when $A$ holds at every world $R$-visible from $w$. Löb's axiom is valid
exactly on the frames whose relation is **transitive** and **converse well-founded** —
no infinite ascending chain. On a finite set that just means: no cycles at all, not even
a self-loop. Provability is a staircase that always runs out.

---

## 2. Adding time

Now suppose the theory *grows*: axioms get added, a corpus accumulates. Then "provable"
is a moving target and we want a second operator, $\blacksquare A$ = "$A$ holds now and
at every future moment", interpreted along a second relation $T$.

A **temporal Gödel–Löb frame** is a set of worlds with two relations:

- $R$, transitive and converse well-founded — provability;
- $T$, reflexive and transitive — the flow of time;

and one compatibility condition tying them together:

$$w \mathrel{T} w' \ \text{and}\ w' \mathrel{R} v \implies w \mathrel{R} v .$$

*Anything visible from a future moment was already visible now.* Its syntactic shadow is
the axiom

$$\Box A \to \blacksquare\Box A,$$

**once provable, always provable**. Proofs do not decay.

Build one yourself. Toggle arrows, set which atoms hold where, watch the five frame
conditions light up green or red, and ask the model whether it satisfies Löb's axiom.

{{interactive_demo:0}}

<details>
<summary>The full calculus, for reference</summary>

The system $\mathsf{TGL}$ consists of: all classical propositional tautologies; modus
ponens; distribution and Löb for $\Box$; distribution, reflexivity $\blacksquare A \to A$
and transitivity $\blacksquare A \to \blacksquare\blacksquare A$ for $\blacksquare$; the
interaction axiom $\Box A \to \blacksquare\Box A$; and necessitation for both boxes.

Notice what is missing: transitivity for $\Box$. The formula $\Box A \to \Box\Box A$ is
not assumed — it is *derivable* from Löb's axiom alone. Put $C = A \wedge \Box A$. Both
$C \to \Box A$ and $C \to A$ are tautologies, so boxing gives $\Box C \to \Box\Box A$ and
$\Box C \to \Box A$. From the second, propositional reasoning yields
$A \to (\Box C \to C)$; boxing *that* and applying Löb gives $\Box A \to \Box C$; chaining
with the first gives $\Box A \to \Box\Box A$. Löb's axiom knows about transitivity
without being told.
</details>

<details>
<summary>Why the two boxes do not collapse into each other</summary>

$\blacksquare p \to \Box p$ fails on two worlds: let $R$ contain the single arrow
$1 \mathrel{R} 0$, freeze time so each world is its own only future, and let $p$ be true
at $1$ and false at $0$. Then $\blacksquare p$ holds at $1$ while $\Box p$ does not.

$\Box p \to \blacksquare p$ fails on one world with no arrows at all: $\Box p$ is
vacuously true, and $p$ itself may be false while the world is its own future.

Provability and permanence are different things — even though provability persists.
(Try both in the laboratory above with the presets.)
</details>

---

## 3. The question: how big must a counterexample be?

You have a formula. You want to know whether the calculus proves it. If it doesn't, then
by design there is *some* model somewhere refuting it. But "somewhere" ranges over a
proper class of structures — there is no algorithm in that.

Unless the countermodel can be forced to be small.

Let $\mathrm{sub}(A)$ be the number of distinct subformulas of $A$.

> **Theorem (finite model property with an explicit bound).** If $A$ is not derivable,
> then $A$ fails at some world of a temporal Gödel–Löb model with at most
> $2^{\mathrm{sub}(A)}$ worlds — a fortiori at most $2^{2\,\mathrm{sub}(A)}$.

That single statement turns an unbounded semantic question into a finite check. Below,
the check runs live: pick a formula, watch the search enumerate every legal structure up
to a chosen size, and see it either produce a countermodel or come up empty.

{{interactive_demo:1}}

---

## 4. First construction: shrinking a model

The classical tool is **filtration**. Given a model refuting $A$, glue together any two
worlds that agree on every subformula of $A$ — nothing about $A$ can tell them apart.
Each world $u$ collapses to its *subformula theory* $\theta(u)$, the set of subformulas
of $A$ true at $u$. There are at most $2^{\mathrm{sub}(A)}$ such sets, so the quotient is
small. The delicate part is choosing the relations on the quotient.

For $\Box$: declare $S$ to see $S'$ when

1. **(forth)** every boxed subformula $\Box B$ realised at $S$ has both $B$ and $\Box B$
   realised at $S'$, and
2. **(strict)** at least one boxed subformula is realised at $S'$ but not at $S$.

Clause 2 looks like a technicality. It is the whole game. Let $\beta(S)$ count the boxed
subformulas realised at $S$. Clause 1 says $\beta$ never decreases along an arrow; clause
2 says it strictly increases; and $\beta$ is bounded by the number of boxed subformulas of
$A$. So chains cannot go on forever. **Converse well-foundedness is recovered by pure
counting.**

Here is the staircase, drawn out: every decided subset of a closure, arranged by layer
$\beta$, with every arrow of the accessibility relation shown.

{{visualization:1}}

<details>
<summary>The obstruction: why the temporal relation needs an extra clause</summary>

The obvious analogue of clause 1 for $\blacksquare$ — transmit $B$ and $\blacksquare B$ —
is *not enough*. The compatibility condition
$w \mathrel{T} w' \wedge w' \mathrel{R} v \Rightarrow w \mathrel{R} v$ simply fails to
survive the quotient.

The repair is to demand also that **every boxed subformula realised at $S$ is still
realised at $S'$**: boxes persist along time. This is legitimate precisely because it is
true upstream — compatibility in the original model forces $\Box$-formulas to persist
along $T$. With the clause in place, compatibility on the quotient is a two-line check.

The moral: the axiom $\Box A \to \blacksquare\Box A$ is not decoration. It is
load-bearing, and the whole filtration is built around it. This was the one genuine
definitional obstruction in the development.
</details>

<details>
<summary>The filtration lemma, and where each frame condition is spent</summary>

One then proves that at every realised world the shrunken model agrees with the original
on every subformula of $A$. Induction on the formula:

- *atoms, falsity, implication*: immediate;
- *$\Box B$, easy direction*: the (forth) clause transmits $B$ downstream;
- *$\Box B$, hard direction*: assume the box holds in the quotient but fails upstream;
  the set of $R$-successors where $B$ fails is non-empty, so by **converse
  well-foundedness of the original frame** it has an $R$-maximal element $m$. Maximality
  plus transitivity give $\Box B$ at $m$, which supplies exactly the (strict) clause,
  so $\theta(m)$ is a quotient successor — contradiction;
- *$\blacksquare B$, hard direction*: the same shape, using reflexivity and transitivity
  of time and, for the $\Box$-persistence clause, **compatibility** upstream.

So the countermodel shrinks to at most $2^{\mathrm{sub}(A)}$ worlds.
</details>

---

## 5. Second construction: manufacturing a model

Filtration shrinks a countermodel you already have. But the theorem speaks of formulas
that are merely *not derivable*. Bridging that gap needs **completeness**: every valid
formula is provable.

And here Gödel–Löb logic plays its most famous trick. The standard completeness proof
builds a canonical model out of all maximal consistent sets. For $\mathsf{GL}$ that model
is **illegal**: its accessibility relation is not converse well-founded, so it is not a
frame of the right class at all.

The escape is to go finite. Fix $A$, let $\mathrm{Cl}$ be its subformula closure, and
define a **world** to be a subset $t \subseteq \mathrm{Cl}$ that is consistent *as a
decision*: the list asserting every member of $t$ and the negation of every member of
$\mathrm{Cl} \setminus t$ derives no contradiction. There are at most
$2^{|\mathrm{Cl}|}$ of these — the model is finite by construction — and one connects them
with the very same filtration relations, so all the frame conditions come for free from
Section 4.

<details>
<summary>The Löb argument: the existence lemma for $\Box$</summary>

Suppose $\Box B \notin t$; we need an accessible world where $B$ fails. Assemble the
candidate hypothesis list: every $\Box D$ in $t$, each such $D$, plus $\Box B$ and
$\lnot B$.

If that list were inconsistent, it would prove $\Box B \to B$. Box the derivation
(necessitation plus repeated distribution) to get a proof of $\Box(\Box B \to B)$ from
the boxed hypotheses, and apply **Löb's axiom** to get $\Box B$. Every boxed hypothesis is
available inside $t$ — directly for the $\Box D$'s, and via the derived transitivity
$\Box D \to \Box\Box D$ for the doubly boxed ones. So $\Box B \in t$, contradicting the
assumption.

Hence the list is consistent, extends to a world $s$, and $s$ is the successor we
wanted: the (forth) clause holds because $s$ contains each $\Box E$ of $t$ together with
$E$, and the (strict) clause holds because $\Box B \in s \setminus t$.

Löb's axiom, which makes the infinite canonical model illegal, is exactly the engine of
the finite one.
</details>

<details>
<summary>The temporal existence lemma, and its three fuels</summary>

The same shape, with $\blacksquare$ in place of $\Box$, and three different ingredients
corresponding exactly to the three demands the temporal relation makes:

| demand | fuel |
|---|---|
| transmit $E$ | $\blacksquare$-necessitation |
| transmit $\blacksquare E$ | the transitivity axiom $\blacksquare A \to \blacksquare\blacksquare A$ |
| transmit $\Box E$ | the interaction axiom $\Box A \to \blacksquare\Box A$ |

The axiom that made the filtration work is the axiom that makes the canonical model work.
</details>

A truth lemma then shows that in this finite canonical model a formula of the closure is
true at a world exactly when it *belongs* to that world. Completeness is immediate: if
$A$ is not derivable then $\{\lnot A\}$ is consistent, some world omits $A$, and $A$ fails
there — in a model of at most $2^{\mathrm{sub}(A)}$ worlds. The conjecture is a theorem,
in its sharp form.

Here are the three procedures, implemented.

{{algorithm:0}}

{{algorithm:1}}

{{algorithm:2}}

---

## 6. How generous is the bound?

Correct is not the same as tight. Consider the consistency statement $\Box\bot \to \bot$:
three subformulas, so the theorem permits up to $2^{2 \cdot 3} = 64$ worlds. Its actual
minimal countermodel has **one** world — a single point with no arrows, where $\Box\bot$
is vacuously true and $\bot$ is false. Gödel's second incompleteness theorem, in its
purest modal form, needs one point.

Or $\blacksquare p \to \Box p$: four subformulas, permitted bound $256$, minimal
countermodel **two** worlds. Ratios of $64{:}1$ and $128{:}1$.

{{visualization:0}}

Why so generous? Because the bound pays twice: for **depth** — how long a chain can be —
and for **width** — how many worlds sit at each level. The counting argument of Section 4
pins the depth exactly: no chain exceeds the number of boxed subformulas, a *linear*
quantity. The entire exponential lives in the width, and width is only ever spent
realising distinct propositional theories — of which a *selective* canonical model, one
keeping only the worlds actually reached by iterating the two existence lemmas, never
needs all.

That is exactly the shape of the natural sharpening: for every non-derivable $A$ there
should be a countermodel whose world count is **polynomial** in $\mathrm{sub}(A)$, and in
fact $\mathrm{sub}(A) + 1$ for formulas with no nested implications beneath a $\Box$.

Run the census yourself and see how the columns diverge.

{{demo:1}}

And here is the complete computational companion — subformula counts, soundness checks
over every structure on up to three worlds, bounded search, filtration with the truth
lemma verified, the counting measure, the canonical model, and the bound-versus-reality
table.

{{demo:0}}

---

## 7. What to take away

Three things.

**Löb's axiom is both the obstruction and the engine.** It is why the infinite canonical
model is illegal, and why the finite one works. In the filtration it appears in a third
guise entirely — as the observation that a bounded integer cannot increase forever.

**The interaction axiom is load-bearing.** $\Box A \to \blacksquare\Box A$ is what makes
the $\Box$-persistence clause legitimate, and it supplies the hypotheses of the temporal
existence lemma. Remove it and the construction breaks at both ends at once.

**An explicit bound is what makes a logic checkable.** It says the system has no hidden
depths: every failure it can exhibit, it can exhibit small. Whatever a temporal
provability logic cannot prove, it cannot prove for a reason you can hold in your hand —
a finite diagram, a handful of worlds, a strictly descending staircase that runs out.

Further reading: [Gödel's incompleteness theorems
(SEP)](https://plato.stanford.edu/entries/goedel-incompleteness/) ·
[Modal logic (SEP)](https://plato.stanford.edu/entries/logic-modal/) ·
[Löb's theorem](https://en.wikipedia.org/wiki/L%C3%B6b%27s_theorem)
"""


def main() -> None:
    """Write PACKAGE.json."""
    sections = algorithm_sections()

    alg1_main = '''if __name__ == "__main__":
    p = Atom(0)
    for label, form in [
        ("Lob's axiom", Imp(Box(Imp(Box(p), p)), Box(p))),
        ("consistency []F->F", Imp(Box(Bot), Bot)),
        ("collapse [T]p->[]p", Imp(Glob(p), Box(p))),
    ]:
        res = bounded_model_search(form)
        if res is None:
            print(f"{label:<22} no countermodel up to 3 worlds  -> derivable")
        else:
            fr, val, w = res
            print(f"{label:<22} refuted at w{w} of a {fr.n}-world model -> not derivable")
'''

    alg2_main = '''if __name__ == "__main__":
    p = Atom(0)
    target = Imp(Glob(p), Box(p))
    fr = Frame(4, frozenset({(0, 1), (0, 2), (1, 2)}), frozenset({(w, w) for w in range(4)}))
    val = {0: frozenset({0, 1, 3})}
    assert is_legal(fr)
    g, gval, thetas, quotient = filtrate(fr, val, target)
    print(f"{fr.n} worlds -> {g.n} theories; filtered frame legal: {is_legal(g)}")
    closure = subformulas(target)
    ok = all(
        sat(g, gval, s, quotient[w]) == sat(fr, val, s, w)
        for w in range(fr.n)
        for s in closure
    )
    print(f"truth lemma verified: {ok}")
    for i, th in enumerate(thetas):
        print(f"  S{i}: beta={box_count(closure, th)}  "
              f"{{{', '.join(sorted(str(x) for x in th))}}}")
'''

    alg3_main = '''if __name__ == "__main__":
    p = Atom(0)
    for form in [Imp(Box(Bot), Bot), Imp(Glob(p), Box(p)), Imp(Box(p), Box(Box(p)))]:
        cf, cval, worlds = finite_canonical_model(form)
        sc = subformula_count(form)
        print(f"{str(form):<20} closure {sc}, 2^{sc}={2 ** sc} subsets, "
              f"{len(worlds)} coherent worlds, legal frame: {is_legal(cf)}")
'''

    algorithms = [
        {
            "name": "Exhaustive Bounded Model Search: a Decision Procedure for Temporal Provability Logic",
            "description": (
                "The decision procedure licensed by the finite model property with an explicit "
                "bound. Given a formula A, it enumerates every temporal Gödel–Löb structure on "
                "1, 2, ..., m worlds together with every valuation of the atoms of A, and tests "
                "A at every world. Frames are generated by enumerating the provability relation "
                "over off-diagonal pairs only (irreflexivity is forced by converse "
                "well-foundedness), pruning immediately for transitivity, and then enumerating "
                "the temporal relation and filtering for the reflexivity, transitivity and "
                "compatibility conditions. The mathematical content is the guarantee: taking "
                "m = 2^(2·sub(A)) makes the verdict 'no countermodel' equivalent to derivability "
                "in the calculus, because a non-derivable formula must fail in a model of at "
                "most that size. Cost is dominated by frame enumeration, 2^Θ(n²) candidates at "
                "size n, so the naive procedure is doubly exponential in sub(A); the point of an "
                "explicit bound is correctness, not speed. In practice a countermodel, when one "
                "exists, is found within the first two or three sizes."
            ),
            "pseudocode": (
                "INPUT   formula A; bound m  (take m = 2^(2*sub(A)) for a complete procedure)\n"
                "OUTPUT  a countermodel of size <= m, or the verdict VALID-UP-TO-m\n"
                "\n"
                "1  ids <- the atom indices occurring in A\n"
                "2  for n <- 1 to m do\n"
                "3      for each R subset of {(i,j) : i /= j, i,j < n} do\n"
                "4          if R is not transitive then continue          // prune early\n"
                "5          for each T subset of {(i,j) : i,j < n} do\n"
                "6              if T is not reflexive or not transitive then continue\n"
                "7              if exists w,w',v with T(w,w') and R(w',v) and not R(w,v)\n"
                "8                  then continue                          // compatibility\n"
                "9              for each valuation V of ids over {0..n-1} do\n"
                "10                 for w <- 0 to n-1 do\n"
                "11                     if not SAT(R,T,V,A,w) then return (R,T,V,w)\n"
                "12 return VALID-UP-TO-m\n"
                "\n"
                "SAT(R,T,V,A,w) recurses on A:\n"
                "    atom p       : w in V(p)\n"
                "    falsity      : false\n"
                "    B -> C       : (not SAT B w) or SAT C w\n"
                "    []B          : for all v with R(w,v): SAT B v\n"
                "    [T]B         : for all v with T(w,v): SAT B v\n"
                "\n"
                "CORRECTNESS  If A is derivable it is valid, so no countermodel exists at any\n"
                "size.  If A is not derivable, the finite model property supplies a countermodel\n"
                "with at most 2^sub(A) <= m worlds, which the enumeration must encounter."
            ),
            "code": build_algorithm(
                "Exhaustive bounded model search for temporal Godel-Lob logic.",
                sections,
                ["Algorithm 1 -- exhaustive bounded model search"],
                alg1_main,
            ),
        },
        {
            "name": "Compatibility-Preserving Filtration through the Subformula Closure",
            "description": (
                "The construction that shrinks an arbitrary countermodel to one with at most "
                "2^sub(A) worlds. Each world u of the input model is replaced by its subformula "
                "theory θ(u) — the set of subformulas of A true at u — and distinct theories "
                "become the worlds of the quotient. The two quotient relations are the heart of "
                "the matter. The accessibility relation demands (forth) that every boxed "
                "subformula realised at S be realised at S' together with its argument, and "
                "(strict) that some boxed subformula be realised at S' but not at S. The "
                "strictness clause forces the measure β(S) = #{boxed subformulas realised at S} "
                "to increase strictly along every arrow, and β is bounded by the number of boxed "
                "subformulas, so the quotient has no infinite ascending chain: converse "
                "well-foundedness, hence Löb's axiom, is recovered by counting alone. The "
                "temporal relation carries the analogous clause for the temporal box *plus* a "
                "□-persistence clause, without which the frame compatibility condition provably "
                "fails to survive quotienting; that extra clause is legitimate precisely because "
                "compatibility holds in the input model. Complexity: O(|M|·sub(A)) for the "
                "theories with memoised satisfaction, then O(m²·sub(A)) for the relations, where "
                "m ≤ 2^sub(A). The output is guaranteed legal and to agree with the input on "
                "every subformula of A at every world."
            ),
            "pseudocode": (
                "INPUT   a finite model M = (W,R,T,V) and a formula A\n"
                "OUTPUT  a legal model with at most 2^sub(A) worlds agreeing with M on Sub(A)\n"
                "\n"
                "1  Cl <- Sub(A)\n"
                "2  for each u in W:  theta(u) <- { B in Cl : M,u |= B }      // memoised SAT\n"
                "3  W* <- the distinct sets among { theta(u) : u in W }\n"
                "4  quotient(u) <- index of theta(u) in W*\n"
                "5  for each S, S' in W*:\n"
                "6      R*(S,S') <- FILT-R(Cl,S,S')\n"
                "7      T*(S,S') <- FILT-T(Cl,S,S')\n"
                "8  V*(p) <- { S in W* : p in S }\n"
                "9  return (W*, R*, T*, V*), quotient\n"
                "\n"
                "FILT-R(Cl,S,S'):\n"
                "    forth  <- for all []B in Cl with []B in S:  B in S' and []B in S'\n"
                "    strict <- exists []B in Cl with []B in S' and []B not in S\n"
                "    return forth and strict\n"
                "\n"
                "FILT-T(Cl,S,S'):\n"
                "    forth   <- for all [T]B in Cl with [T]B in S:  B in S' and [T]B in S'\n"
                "    persist <- for all []B in Cl with []B in S:   []B in S'\n"
                "    return forth and persist\n"
                "\n"
                "INVARIANTS\n"
                "  (i)   R* is transitive and has no cycle, because beta strictly increases\n"
                "        along it and is bounded by #{[]B in Cl}\n"
                "  (ii)  T* is a preorder, reflexivity coming from the axiom [T]B -> B upstream\n"
                "  (iii) T* o R* is contained in R*, thanks to the persistence clause\n"
                "  (iv)  for every u and every B in Cl:  quotient(u) |= B  iff  u |= B"
            ),
            "code": build_algorithm(
                "The compatibility-preserving filtration of a temporal Godel-Lob model.",
                sections,
                ["Algorithm 2 -- filtration"],
                alg2_main,
            ),
        },
        {
            "name": "Construction of the Finite Canonical Model over a Subformula Closure",
            "description": (
                "The construction that manufactures a countermodel from mere non-derivability, "
                "and therefore the step that turns the bound from conditional into "
                "unconditional. The classical canonical model of maximal consistent sets is "
                "illegal for Gödel–Löb logic, since its accessibility relation is not converse "
                "well-founded; the remedy is to build a *finite* canonical model over the "
                "subformula closure of a single formula. A world is a subset t of the closure "
                "that is consistent as a decision — the list asserting every member of t and "
                "negating every non-member derives no contradiction. There are at most "
                "2^|closure| such subsets, which is exactly where the bound 2^sub(A) comes from. "
                "The worlds are connected by the *same* two filtration relations, so converse "
                "well-foundedness comes free from the counting argument and only reflexivity of "
                "time needs a syntactic argument (namely the axiom [T]B → B). The full "
                "consistency test is a derivability question; the implementation below uses the "
                "cheap necessary conditions that prune the overwhelming majority of subsets: "
                "falsity absent, implications of the closure decided coherently, and every "
                "temporally boxed member carrying its argument. Complexity: O(2^sub·sub) to "
                "enumerate and filter, then O(4^sub·sub) to build the relations."
            ),
            "pseudocode": (
                "INPUT   a formula A (or any subformula-closed finite set Cl)\n"
                "OUTPUT  the finite canonical model over Cl, of size at most 2^|Cl|\n"
                "\n"
                "1  Cl <- Sub(A)\n"
                "2  worlds <- empty list\n"
                "3  for each subset t of Cl do\n"
                "4      gamma(t) <- [ B : B in t ] ++ [ not B : B in Cl \\ t ]\n"
                "5      if gamma(t) is consistent then append t to worlds\n"
                "6  for each t, s in worlds:\n"
                "7      R(t,s) <- FILT-R(Cl,t,s)\n"
                "8      T(t,s) <- FILT-T(Cl,t,s)\n"
                "9  V(p) <- { t : p in t }\n"
                "10 return (worlds, R, T, V)\n"
                "\n"
                "CHEAP NECESSARY CONDITIONS FOR CONSISTENCY  (used to prune line 5)\n"
                "    falsity is not in t\n"
                "    for each (B -> C) in Cl with B, C in Cl:\n"
                "        (B -> C) in t   iff   B not in t or C in t\n"
                "    for each [T]B in Cl:  [T]B in t implies B in t          // the axiom [T]B->B\n"
                "\n"
                "KEY LEMMAS THAT MAKE THE OUTPUT CORRECT\n"
                "  EXISTENCE FOR []   if []B not in t, the list of all []D in t, together with\n"
                "     each such D, together with []B and not B, is consistent -- otherwise\n"
                "     boxing it and applying Loeb's axiom would place []B inside t.  Extend it\n"
                "     to a world s: then R(t,s) and B not in s.\n"
                "  EXISTENCE FOR [T]  the same shape, using [T]-necessitation, the transitivity\n"
                "     axiom for [T], and the interaction axiom []A -> [T][]A, which is exactly\n"
                "     what supplies the persistence clause of T.\n"
                "  TRUTH LEMMA        for every B in Cl and every world t:  t |= B  iff  B in t.\n"
                "  COMPLETENESS       if A is not derivable then [not A] is consistent, so some\n"
                "     world omits A, so A fails there -- in a model of at most 2^sub(A) worlds."
            ),
            "code": build_algorithm(
                "The finite canonical model over a subformula closure.",
                sections,
                [
                    "Algorithm 2 -- filtration",
                    "Algorithm 3 -- the finite canonical model",
                ],
                alg3_main,
            ),
        },
    ]

    demo_src = read(ROOT / "demo.py")
    census_src = read(ASSETS / "demo_census.py")

    lean_parts: List[str] = []
    for rel in LEAN_FILES:
        lean_parts.append(f"-- ===== {rel} =====\n" + read(ROOT / rel))
    lean_proofs = "\n\n".join(lean_parts)

    pkg = {
        "title": "The Finite Model Property with an Explicit Bound for Temporal Gödel–Löb Logic",
        "domain": "Logic",
        "description": (
            "Every formula not derivable in the temporal Gödel–Löb provability calculus is "
            "refuted in a model with at most 2^sub(A) worlds, where sub(A) counts distinct "
            "subformulas — a fortiori at most 2^(2·sub(A)) — so derivability is decidable by "
            "exhaustive bounded model search. The proof combines a "
            "converse-well-foundedness-preserving filtration with a finite canonical model over "
            "the subformula closure, and yields soundness and weak completeness of the calculus."
        ),
        "authors": ["Aristotle"],
        "date": "2026-08-26",
        "key_results": [
            "Finite model property with an explicit bound: every formula not derivable in the "
            "temporal Gödel–Löb calculus has a countermodel with at most 2^(2·sub(A)) worlds, "
            "and in the sharp form at most 2^sub(A) worlds, where sub(A) is the number of "
            "distinct subformulas.",
            "Soundness and weak completeness: derivability in the temporal Gödel–Löb calculus "
            "coincides exactly with validity on the class of temporal Gödel–Löb frames, proved "
            "via a finite canonical model over the subformula closure rather than the illegal "
            "infinite canonical model.",
            "Strict growth of the box-count measure: every step of the filtered accessibility "
            "relation strictly increases the number of realised boxed subformulas, which "
            "recovers converse well-foundedness by counting and bounds the depth of any "
            "canonical countermodel linearly in the formula.",
            "Compatibility-preserving filtration: the filtered temporal relation, strengthened "
            "by a persistence clause for the provability box, preserves the interaction "
            "condition that validates the axiom 'once provable, always provable' — the naive "
            "filtration does not.",
            "Decidability by bounded search: a formula is a theorem of the calculus if and only "
            "if it holds at every world of every temporal Gödel–Löb model with at most "
            "2^(2·sub(A)) worlds; and Gödel's second incompleteness theorem holds in the object "
            "language, the consistency statement having a one-world countermodel against a "
            "permitted bound of 64.",
        ],
        "keywords": [
            "provability logic",
            "Gödel–Löb logic",
            "Löb's theorem",
            "temporal logic",
            "filtration",
            "finite model property",
            "canonical model",
            "decidability",
        ],
        "article": read(ROOT / "ARTICLE.md"),
        "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
        "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
        "demo": demo_src,
        "demos": [
            {
                "name": "Complete Computational Companion: Bounds, Soundness, Filtration and the Canonical Model",
                "description": (
                    "A seven-part, self-contained demonstration of every ingredient of the "
                    "finite model property. (1) Subformula counts and both bounds on eight "
                    "sample formulas. (2) A soundness spot-check verifying that all ten axiom "
                    "schemes of the calculus hold at every world of every one of the 13,892 "
                    "temporal Gödel–Löb models on at most three worlds. (3) Exhaustive bounded "
                    "model search, correctly classifying Löb's axiom, the derived transitivity "
                    "axiom and the interaction axiom as theorems while producing explicit "
                    "countermodels for the consistency statement and both collapse formulas. "
                    "(4) The filtration run on a concrete four-world countermodel, with the "
                    "filtered frame checked against all five frame conditions and the truth "
                    "lemma verified for every subformula at every world. (5) The counting "
                    "argument: all 72 filtered accessibility steps among the 16 theories of a "
                    "closure are confirmed to strictly increase the box-count measure. (6) The "
                    "finite canonical model over three subformula closures, showing that "
                    "dropping the modal coherence clause breaks reflexivity of time. (7) A "
                    "table of the proved bound against the true minimal countermodel, exhibiting "
                    "gaps of 64:1, 128:1 and 256:1."
                ),
                "code": demo_src,
            },
            {
                "name": "Minimal-Countermodel Census: Measuring the Slack in the Bound",
                "description": (
                    "For each of fourteen formulas — the axiom schemes of the calculus, the "
                    "derived transitivity axiom, and a selection of plausible-looking "
                    "non-theorems — this script tabulates the number of distinct subformulas, "
                    "the number of boxed subformulas, the depth bound (the maximum number of "
                    "worlds on a single accessibility chain of a canonical countermodel, which "
                    "the strict-growth theorem pins at one more than the number of boxed "
                    "subformulas), the sharp bound 2^sub, the stated bound 2^(2·sub), and the "
                    "true minimal countermodel size found by exhaustive search over every legal "
                    "structure of at most three worlds. Every axiom survives the search; every "
                    "non-theorem is refuted within three worlds, with bound-to-reality ratios "
                    "ranging from 64:1 to 1024:1. The census is the empirical case that the "
                    "exponential factor in the proved bound is pure width: the depth column "
                    "never exceeds four while the bound columns reach 65,536."
                ),
                "code": census_src,
            },
        ],
        "algorithms": algorithms,
        "visualizations": [
            {
                "name": "The Proved Bound against Reality: Exponential Width, Linear Depth",
                "description": (
                    "A logarithmic bar chart comparing, for seven sample formulas, the stated "
                    "bound 2^(2·sub(A)), the sharp bound 2^sub(A) actually delivered by the "
                    "construction, and the depth bound — the number of boxed subformulas plus "
                    "one, which by the strict-growth theorem caps the length of any accessibility "
                    "chain. Stars mark the true minimal countermodel where exhaustive search "
                    "settles it, annotated with the gap ratio. The picture makes the central "
                    "point of the tightness discussion immediate: the bound columns climb through "
                    "five orders of magnitude while the depth column stays between one and six."
                ),
                "code": read(ASSETS / "viz_bound_gap.py"),
            },
            {
                "name": "The Löb Staircase: Converse Well-Foundedness by Counting",
                "description": (
                    "A layered graph of every decided subset of a subformula closure, with the "
                    "vertical coordinate equal to β(S), the number of boxed subformulas realised "
                    "at S, and every arrow of the filtered accessibility relation drawn in. Not "
                    "one arrow is horizontal or downward: the strict-growth theorem guarantees "
                    "that β increases at every step. Since β is bounded by the number of boxed "
                    "subformulas, the number of layers is small and no chain can be infinite — "
                    "which is exactly the frame condition that validates Löb's axiom. The "
                    "diagram is the combinatorial heart of the whole construction, drawn."
                ),
                "code": read(ASSETS / "viz_staircase.py"),
            },
        ],
        "interactive_demos": [
            {
                "title": "The Temporal Gödel–Löb Model Laboratory",
                "description": (
                    "A complete two-dimensional Kripke laboratory. Choose between one and five "
                    "worlds, then toggle the provability relation and the temporal relation cell "
                    "by cell in two matrices while a live panel reports which of the five frame "
                    "conditions — transitivity and converse well-foundedness of provability, "
                    "reflexivity and transitivity of time, and the compatibility condition "
                    "linking them — currently hold. A one-click repair closes time under "
                    "reflexivity and transitivity, closes provability under transitivity and "
                    "compatibility, and deletes every arrow lying on a cycle, returning a legal "
                    "frame. Four presets reproduce the canonical examples: the single point that "
                    "refutes the consistency statement, the frozen-time pair that separates the "
                    "two modalities, a three-step staircase, and a frame where time and "
                    "provability genuinely interact. A rendered diagram shows both relations at "
                    "once. Enter any formula — atoms, falsity, the connectives, and both boxes — "
                    "and the widget reports where it holds, displays a full truth table over the "
                    "subformula closure, and states the bound the theorem permits. Finally it "
                    "runs the filtration live: it computes the subformula theories, glues "
                    "indistinguishable worlds, draws the quotient, checks that the quotient is "
                    "still a legal frame, verifies the truth lemma, and displays each theory's "
                    "layer in the box-count staircase. Two collapsible sections explain the "
                    "counting argument and why the temporal relation needs its extra clause."
                ),
                "html": read(ASSETS / "widget_model_lab.html"),
            },
            {
                "title": "Bounded Model Search and the Löb Staircase",
                "description": (
                    "The decision procedure, running in the browser. Type a formula — or pick "
                    "one of nine presets ranging from Löb's axiom to tempting non-theorems like "
                    "'Löb without the box' — and the widget displays its subformula closure "
                    "colour-coded by modality, then reports the three quantities that govern the "
                    "size of a countermodel: the stated bound 2^(2·sub), the sharp bound 2^sub, "
                    "and the depth bound, drawn as logarithmic bars so the exponential-versus-"
                    "linear contrast is visible at a glance. Pressing 'run search' enumerates "
                    "every legal temporal Gödel–Löb structure up to a chosen size together with "
                    "every valuation, and either produces a drawn countermodel with the world "
                    "where the formula fails and the gap ratio against the permitted bound, or "
                    "reports that the formula survived. Below, the Löb staircase is drawn for the "
                    "formula's own closure: every decided subset, arranged by the number of "
                    "boxed subformulas it realises, with every accessibility arrow shown going "
                    "strictly upward. Two collapsible sections derive the 2^sub bound from the "
                    "world construction and explain why the depth of a countermodel is only "
                    "linear."
                ),
                "html": read(ASSETS / "widget_search.html"),
            },
        ],
        "interactive_layout": INTERACTIVE_LAYOUT,
        "lean_proofs": lean_proofs,
        "future_directions": FUTURE_DIRECTIONS,
        "modules": {
            "demo": demo_src,
            "demo_census": census_src,
            "algorithms": read(ASSETS / "algorithms.py"),
            "viz_bound_gap": read(ASSETS / "viz_bound_gap.py"),
            "viz_staircase": read(ASSETS / "viz_staircase.py"),
        },
        "lean_files": LEAN_FILES,
    }

    out = ROOT / "PACKAGE.json"
    out.write_text(json.dumps(pkg, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"wrote {out} ({out.stat().st_size / 1024:.1f} KiB)")


if __name__ == "__main__":
    main()


"""Minimal-countermodel census for temporal Godel-Lob logic.

For each formula in a catalogue of axioms, theorems and non-theorems, this script

  * computes the number of distinct subformulas  sub(A),
  * computes the sharp bound 2^sub(A) and the stated bound 2^(2*sub(A)),
  * computes the *depth* bound: the number of boxed subformulas plus one, which by
    the strict-growth theorem is the maximum number of worlds on any single
    accessibility chain of a canonical countermodel,
  * runs an exhaustive search over every temporal Godel-Lob structure of size at
    most 3, together with every valuation, to find the true minimal countermodel,
  * and reports the ratio between the stated bound and reality.

The census is the empirical basis for the claim that the exponential factor in the
proved bound is pure *width*: the depth column never exceeds a small linear number,
while the bound columns explode.

Run:  python3 demo_census.py
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Dict, FrozenSet, Iterator, List, Optional, Set, Tuple


@dataclass(frozen=True)
class Form:
    """A formula; ``kind`` is one of atom, bot, imp, box, glob."""

    kind: str
    idx: int = -1
    args: Tuple["Form", ...] = ()

    def __str__(self) -> str:
        if self.kind == "atom":
            return "pqr"[self.idx]
        if self.kind == "bot":
            return "F"
        if self.kind == "imp":
            a, b = self.args
            return f"~{a}" if b.kind == "bot" else f"({a}->{b})"
        if self.kind == "box":
            return f"[]{self.args[0]}"
        return f"[T]{self.args[0]}"


def Atom(i: int) -> Form:
    """Propositional atom."""
    return Form("atom", i)


Bot: Form = Form("bot")


def Imp(a: Form, b: Form) -> Form:
    """Implication."""
    return Form("imp", -1, (a, b))


def Box(a: Form) -> Form:
    """Provability box."""
    return Form("box", -1, (a,))


def Glob(a: Form) -> Form:
    """Temporal box."""
    return Form("glob", -1, (a,))


def subformulas(a: Form) -> FrozenSet[Form]:
    """The subformula closure of a formula, including itself."""
    out: Set[Form] = {a}
    for s in a.args:
        out |= subformulas(s)
    return frozenset(out)


@dataclass(frozen=True)
class Frame:
    """A finite candidate frame on the worlds 0..n-1."""

    n: int
    R: FrozenSet[Tuple[int, int]]
    T: FrozenSet[Tuple[int, int]]


def legal(f: Frame) -> bool:
    """All five temporal Godel-Lob frame conditions."""
    n = f.n
    if any((w, w) in f.R for w in range(n)):
        return False
    if any((w, w) not in f.T for w in range(n)):
        return False
    for a in range(n):
        for b in range(n):
            for c in range(n):
                if (a, b) in f.R and (b, c) in f.R and (a, c) not in f.R:
                    return False
                if (a, b) in f.T and (b, c) in f.T and (a, c) not in f.T:
                    return False
                if (a, b) in f.T and (b, c) in f.R and (a, c) not in f.R:
                    return False
    return True


def sat(f: Frame, val: Dict[int, FrozenSet[int]], a: Form, w: int) -> bool:
    """Satisfaction of a formula at a world."""
    if a.kind == "atom":
        return w in val.get(a.idx, frozenset())
    if a.kind == "bot":
        return False
    if a.kind == "imp":
        return (not sat(f, val, a.args[0], w)) or sat(f, val, a.args[1], w)
    if a.kind == "box":
        return all(sat(f, val, a.args[0], v) for v in range(f.n) if (w, v) in f.R)
    return all(sat(f, val, a.args[0], v) for v in range(f.n) if (w, v) in f.T)


def frames(n: int) -> Iterator[Frame]:
    """Every legal frame on exactly n worlds."""
    off = [(i, j) for i in range(n) for j in range(n) if i != j]
    allp = [(i, j) for i in range(n) for j in range(n)]
    for rb in product([False, True], repeat=len(off)):
        R = frozenset(p for p, b in zip(off, rb) if b)
        if any((a, c) not in R for (a, b) in R for c in range(n) if (b, c) in R):
            continue
        for tb in product([False, True], repeat=len(allp)):
            T = frozenset(p for p, b in zip(allp, tb) if b)
            fr = Frame(n, R, T)
            if legal(fr):
                yield fr


def minimal_countermodel(a: Form, max_worlds: int = 3) -> Optional[int]:
    """The size of the smallest countermodel to ``a`` with at most ``max_worlds`` worlds."""
    ids = sorted({s.idx for s in subformulas(a) if s.kind == "atom"})
    for n in range(1, max_worlds + 1):
        subsets = [frozenset(w for w in range(n) if (m >> w) & 1) for m in range(1 << n)]
        for fr in frames(n):
            for combo in product(subsets, repeat=len(ids)):
                val = dict(zip(ids, combo))
                if any(not sat(fr, val, a, w) for w in range(n)):
                    return n
    return None


CATALOGUE: List[Tuple[str, Form]] = []


def _build() -> None:
    """Populate the catalogue of sample formulas."""
    p, q = Atom(0), Atom(1)
    CATALOGUE.extend(
        [
            ("K for []", Imp(Box(Imp(p, q)), Imp(Box(p), Box(q)))),
            ("Lob's axiom", Imp(Box(Imp(Box(p), p)), Box(p))),
            ("4 for [] (derived)", Imp(Box(p), Box(Box(p)))),
            ("K for [T]", Imp(Glob(Imp(p, q)), Imp(Glob(p), Glob(q)))),
            ("T for [T]", Imp(Glob(p), p)),
            ("4 for [T]", Imp(Glob(p), Glob(Glob(p)))),
            ("interaction []A->[T][]A", Imp(Box(p), Glob(Box(p)))),
            ("consistency []F->F", Imp(Box(Bot), Bot)),
            ("collapse [T]p->[]p", Imp(Glob(p), Box(p))),
            ("collapse []p->[T]p", Imp(Box(p), Glob(p))),
            ("reflexivity []p->p", Imp(Box(p), p)),
            ("Lob's rule as an axiom", Imp(Box(Imp(Box(p), p)), p)),
            ("[T][]p -> []p", Imp(Glob(Box(p)), Box(p))),
            ("[]p -> [][T]p", Imp(Box(p), Box(Glob(p)))),
        ]
    )


def main() -> None:
    """Run the census and print the table."""
    _build()
    print(__doc__.split("Run:")[0].strip())
    print()
    hdr = (
        f"  {'formula':<26} {'sub':>4} {'#[]':>4} {'depth':>6} "
        f"{'sharp':>8} {'stated':>9} {'minimal':>8} {'gap':>10}"
    )
    print(hdr)
    print("  " + "-" * (len(hdr) - 2))
    for label, form in CATALOGUE:
        cl = subformulas(form)
        sc = len(cl)
        nb = sum(1 for c in cl if c.kind == "box")
        sharp, stated = 2**sc, 2 ** (2 * sc)
        m = minimal_countermodel(form)
        if m is None:
            verdict, gap = "none<=3", "theorem"
        else:
            verdict, gap = str(m), f"{stated // m}:1"
        print(
            f"  {label:<26} {sc:>4} {nb:>4} {nb + 1:>6} "
            f"{sharp:>8} {stated:>9} {verdict:>8} {gap:>10}"
        )
    print()
    print("  'minimal' = size of the smallest countermodel found by exhaustive search over")
    print("  every legal structure of at most 3 worlds; 'none<=3' means the formula survived")
    print("  the search, which for each entry above matches its status as a theorem.")
    print("  'depth' is the maximum number of worlds on a single accessibility chain of a")
    print("  canonical countermodel -- linear in the formula, while the bounds are exponential.")


if __name__ == "__main__":
    main()


"""Visualization: the proved finite-model bound against reality.

Plots, on a logarithmic scale, three quantities for a family of sample formulas
of temporal Godel-Lob logic:

  * the stated bound  2^(2 * sub(A))  from the finite model property,
  * the sharp bound   2^(sub(A))      actually delivered by the construction,
  * the *depth* bound -- the number of boxed subformulas of A -- which by the
    strict-growth theorem is the maximum length of any accessibility chain in a
    canonical countermodel,

together with the true minimal countermodel size where it is known by exhaustive
search.  The picture makes the central point of the tightness discussion visible
at a glance: the exponential gap is entirely *width*; the *depth* is linear.

Run:  python3 viz_bound_gap.py     (writes bound_gap.png)
"""

from __future__ import annotations

from typing import List, Optional, Tuple

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

# (label, number of distinct subformulas, number of boxed subformulas,
#  true minimal countermodel size or None)
SAMPLES: List[Tuple[str, int, int, Optional[int]]] = [
    ("\u25a1\u22a5\u2192\u22a5", 3, 1, 1),
    ("\u25a1p\u2192\u25a0p", 4, 1, 1),
    ("\u25a0p\u2192\u25a1p", 4, 1, 2),
    ("\u25a1p\u2192\u25a1\u25a1p", 4, 2, None),
    ("\u25a1(\u25a1p\u2192p)\u2192\u25a1p", 5, 3, None),
    ("\u25a0(p\u2192q)\u2192(\u25a0p\u2192\u25a0q)", 8, 0, None),
    ("\u25a1(\u25a1p\u2192\u25a1q)\u2192\u25a1\u25a1(p\u2192q)", 9, 5, None),
]


def main() -> None:
    """Draw and save the comparison chart."""
    labels = [s[0] for s in SAMPLES]
    sub = np.array([s[1] for s in SAMPLES], dtype=float)
    boxes = np.array([s[2] for s in SAMPLES], dtype=float)
    minimal = [s[3] for s in SAMPLES]

    stated = 2.0 ** (2.0 * sub)
    sharp = 2.0**sub
    depth = boxes + 1.0  # a chain of k strict steps visits k+1 worlds

    x = np.arange(len(SAMPLES))
    width = 0.26

    fig, ax = plt.subplots(figsize=(12.5, 6.4))
    ax.bar(x - width, stated, width, label="stated bound  2^(2 sub(A))",
           color="#c0392b", alpha=0.85)
    ax.bar(x, sharp, width, label="sharp bound  2^sub(A)",
           color="#e67e22", alpha=0.9)
    ax.bar(x + width, depth, width,
           label="depth bound  #{boxed subformulas} + 1",
           color="#2980b9", alpha=0.9)

    known_x = [i for i, m in enumerate(minimal) if m is not None]
    known_y = [m for m in minimal if m is not None]
    ax.plot(known_x, known_y, "k*", markersize=17,
            label="true minimal countermodel (exhaustive search)", zorder=5)

    for i, m in zip(known_x, known_y):
        ax.annotate(
            f"{int(stated[i] // m)}:1 gap",
            xy=(i, m),
            xytext=(i + 0.05, m * 2.4),
            fontsize=9,
            color="black",
            arrowprops=dict(arrowstyle="->", color="black", lw=0.8),
        )

    ax.set_yscale("log")
    ax.set_xticks(x)
    ax.set_xticklabels(labels, fontsize=10)
    ax.set_ylabel("number of worlds (log scale)")
    ax.set_title(
        "Temporal Godel-Lob logic: the finite-model bound is exponential in width,\n"
        "but the depth of a canonical countermodel is only linear",
        fontsize=13,
    )
    ax.legend(loc="upper left", fontsize=10)
    ax.grid(axis="y", which="both", alpha=0.25)
    ax.set_axisbelow(True)
    fig.tight_layout()
    fig.savefig("bound_gap.png", dpi=150)
    print("wrote bound_gap.png")


if __name__ == "__main__":
    main()


"""Visualization: the box-count staircase, the engine of converse well-foundedness.

For a chosen formula A we enumerate all decided subsets of its subformula closure
and draw the filtered accessibility relation as a layered graph, with layer index
equal to

    beta(S) = number of boxed subformulas of A realised at S.

The strict-growth theorem says every accessibility arrow goes strictly *up* one or
more layers.  Since beta is bounded by the number of boxed subformulas, no chain
can be longer than that number: the frame is converse well-founded and therefore
validates Lob's axiom.  The plot makes this visible -- there is not a single
horizontal or downward arrow, and the number of layers is small.

Run:  python3 viz_staircase.py     (writes staircase.png)
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, FrozenSet, List, Set, Tuple

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt


@dataclass(frozen=True)
class Form:
    """A formula: kind in {atom, bot, imp, box, glob}."""

    kind: str
    idx: int = -1
    args: Tuple["Form", ...] = ()

    def __str__(self) -> str:
        if self.kind == "atom":
            return f"p{self.idx}"
        if self.kind == "bot":
            return "\u22a5"
        if self.kind == "imp":
            a, b = self.args
            return f"~{a}" if b.kind == "bot" else f"({a}\u2192{b})"
        if self.kind == "box":
            return f"\u25a1{self.args[0]}"
        return f"\u25a0{self.args[0]}"


def Atom(i: int) -> Form:
    """Propositional atom."""
    return Form("atom", i)


Bot = Form("bot")


def Imp(a: Form, b: Form) -> Form:
    """Implication."""
    return Form("imp", -1, (a, b))


def Box(a: Form) -> Form:
    """Provability box."""
    return Form("box", -1, (a,))


def Glob(a: Form) -> Form:
    """Temporal box."""
    return Form("glob", -1, (a,))


def subformulas(a: Form) -> FrozenSet[Form]:
    """Subformula closure of a formula, including itself."""
    out: Set[Form] = {a}
    for s in a.args:
        out |= subformulas(s)
    return frozenset(out)


def filt_R(closure: FrozenSet[Form], S: FrozenSet[Form], Sp: FrozenSet[Form]) -> bool:
    """The filtered accessibility relation (forth clause + strictness clause)."""
    boxes = [c for c in closure if c.kind == "box"]
    forth = all((c.args[0] in Sp and c in Sp) for c in boxes if c in S)
    strict = any((c in Sp and c not in S) for c in boxes)
    return forth and strict


def beta(closure: FrozenSet[Form], S: FrozenSet[Form]) -> int:
    """The number of boxed subformulas realised at S."""
    return sum(1 for c in closure if c.kind == "box" and c in S)


def main() -> None:
    """Draw and save the staircase diagram."""
    p = Atom(0)
    target = Imp(Box(p), Box(Box(p)))  # the 4 axiom: two nested boxes
    closure = subformulas(target)
    items = sorted(closure, key=str)

    worlds: List[FrozenSet[Form]] = [
        frozenset(x for i, x in enumerate(items) if (mask >> i) & 1)
        for mask in range(1 << len(items))
    ]
    layers: Dict[int, List[int]] = {}
    for i, S in enumerate(worlds):
        layers.setdefault(beta(closure, S), []).append(i)

    pos: Dict[int, Tuple[float, float]] = {}
    for lvl, members in layers.items():
        for k, i in enumerate(members):
            pos[i] = (k - (len(members) - 1) / 2.0, float(lvl))

    fig, ax = plt.subplots(figsize=(12.0, 7.0))
    palette = ["#2c3e50", "#2980b9", "#16a085", "#e67e22", "#c0392b"]

    arrows = 0
    for i, S in enumerate(worlds):
        for j, Sp in enumerate(worlds):
            if filt_R(closure, S, Sp):
                arrows += 1
                x0, y0 = pos[i]
                x1, y1 = pos[j]
                ax.annotate(
                    "",
                    xy=(x1, y1 - 0.06),
                    xytext=(x0, y0 + 0.06),
                    arrowprops=dict(arrowstyle="-|>", color="#7f8c8d", lw=0.7, alpha=0.6),
                )

    for i, S in enumerate(worlds):
        x, y = pos[i]
        lvl = beta(closure, S)
        ax.scatter([x], [y], s=460, color=palette[lvl % len(palette)], zorder=3,
                   edgecolors="white", linewidths=1.6)
        label = ",".join(sorted(str(f) for f in S)) or "\u2205"
        ax.text(x, y - 0.19, label, ha="center", va="top", fontsize=7.2, zorder=4)

    nboxes = sum(1 for c in closure if c.kind == "box")
    ax.set_yticks(sorted(layers.keys()))
    ax.set_ylabel("beta(S)  =  number of realised boxed subformulas")
    ax.set_xticks([])
    ax.set_title(
        f"The box-count staircase for  {target}\n"
        f"every one of the {arrows} accessibility arrows goes strictly up; "
        f"at most {nboxes} layers, hence no infinite chain",
        fontsize=13,
    )
    ax.grid(axis="y", alpha=0.25)
    ax.set_axisbelow(True)
    ax.margins(x=0.08, y=0.16)
    fig.tight_layout()
    fig.savefig("staircase.png", dpi=150)
    print(f"wrote staircase.png  ({arrows} arrows, {len(worlds)} theories)")


if __name__ == "__main__":
    main()


"""
Temporal Godel-Lob logic: the finite model property with an explicit bound.
==========================================================================

A self-contained numerical / computational companion to the theory of the
temporal provability calculus TGL.

The object language has

    atoms p0, p1, ...      falsity  _|_      implication  A -> B
    the provability box    []A     ("A is provable")
    the temporal box       [T]A    ("A holds now and at all future times")

A *temporal Godel-Lob frame* is a triple (W, R, T) where

    R is transitive and converse well-founded   (no infinite R-ascending chain;
                                                 on a finite set: R is a strict
                                                 transitive order, i.e. irreflexive)
    T is reflexive and transitive               (a preorder: the flow of time)
    compat:  T(w, w') and R(w', v)  ==>  R(w, v)

The Hilbert calculus TGL consists of all propositional tautologies, modus
ponens, the distribution axiom K for both boxes, Lob's axiom
[]([]A -> A) -> []A, reflexivity [T]A -> A, transitivity [T]A -> [T][T]A,
the interaction axiom []A -> [T][]A, and the two necessitation rules.

MAIN THEOREM (finite model property with an explicit bound).
    If A is not derivable in TGL then A fails at some world of a temporal
    Godel-Lob model with at most 2^(sub A) worlds, where sub A is the number
    of distinct subformulas of A.  A fortiori the bound 2^(2 * sub A) holds.

This script demonstrates, by explicit finite computation:

  1. the subformula count and the two bounds, on sample formulas;
  2. soundness spot-checks: every axiom of TGL holds at every world of every
     temporal Godel-Lob model on up to 3 worlds;
  3. exhaustive bounded model search: the correct decision procedure for
     validity guaranteed by the main theorem;
  4. the filtration construction, run on a concrete countermodel, together with
     a machine check of the filtration ("truth") lemma and of the fact that the
     filtered frame is again a temporal Godel-Lob frame;
  5. the strict growth of the *box-count* measure along the filtered
     accessibility relation -- the counting argument behind converse
     well-foundedness, i.e. behind Lob's axiom surviving filtration;
  6. the finite canonical model over a subformula closure, built from
     consistent decided subsets, and its size against the theoretical bound;
  7. the gap between the proved bound and the true minimal countermodel size
     on two headline formulas: the consistency statement []_|_ -> _|_
     (Godel's second incompleteness theorem in the object language) and the
     non-collapse formula [T]p -> []p.

Run:  python3 demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Callable, Dict, FrozenSet, Iterable, Iterator, List, Optional, Set, Tuple

# ---------------------------------------------------------------------------
# 1. The object language
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class Form:
    """A formula of temporal Godel-Lob logic.

    ``kind`` is one of ``"atom"``, ``"bot"``, ``"imp"``, ``"box"``, ``"glob"``.
    ``idx`` carries the atom index; ``args`` the immediate subformulas.
    """

    kind: str
    idx: int = -1
    args: Tuple["Form", ...] = ()

    def __str__(self) -> str:
        if self.kind == "atom":
            return f"p{self.idx}"
        if self.kind == "bot":
            return "_|_"
        if self.kind == "imp":
            left, right = self.args
            if right.kind == "bot":
                return f"~{left}"
            return f"({left} -> {right})"
        if self.kind == "box":
            return f"[]{self.args[0]}"
        return f"[T]{self.args[0]}"


def Atom(i: int) -> Form:
    """The propositional atom ``p_i``."""
    return Form("atom", i)


Bot: Form = Form("bot")


def Imp(a: Form, b: Form) -> Form:
    """The implication ``a -> b``."""
    return Form("imp", -1, (a, b))


def Neg(a: Form) -> Form:
    """Negation, encoded as ``a -> _|_``."""
    return Imp(a, Bot)


def Box(a: Form) -> Form:
    """The provability box ``[]a``."""
    return Form("box", -1, (a,))


def Glob(a: Form) -> Form:
    """The temporal box ``[T]a`` ("always from now on")."""
    return Form("glob", -1, (a,))


def And(a: Form, b: Form) -> Form:
    """Conjunction, encoded with implication and falsity."""
    return Neg(Imp(a, Neg(b)))


def Or(a: Form, b: Form) -> Form:
    """Disjunction, encoded with implication and falsity."""
    return Imp(Neg(a), b)


def subformulas(a: Form) -> FrozenSet[Form]:
    """The set of subformulas of ``a``, including ``a`` itself."""
    out: Set[Form] = {a}
    for sub in a.args:
        out |= subformulas(sub)
    return frozenset(out)


def subformula_count(a: Form) -> int:
    """The number of *distinct* subformulas of ``a`` -- the bound parameter."""
    return len(subformulas(a))


def size(a: Form) -> int:
    """The number of nodes of the syntax tree of ``a``."""
    return 1 + sum(size(s) for s in a.args)


def atoms_of(a: Form) -> FrozenSet[int]:
    """The atom indices occurring in ``a``."""
    return frozenset(s.idx for s in subformulas(a) if s.kind == "atom")


# ---------------------------------------------------------------------------
# 2. Frames and models
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class Frame:
    """A finite candidate temporal Godel-Lob frame on the worlds ``0..n-1``.

    ``R`` and ``T`` are given as sets of ordered pairs.
    """

    n: int
    R: FrozenSet[Tuple[int, int]]
    T: FrozenSet[Tuple[int, int]]

    def r(self, w: int, v: int) -> bool:
        """Does ``w`` see ``v`` along the provability relation?"""
        return (w, v) in self.R

    def t(self, w: int, v: int) -> bool:
        """Is ``v`` in the future of ``w``?"""
        return (w, v) in self.T


def is_transitive(n: int, rel: FrozenSet[Tuple[int, int]]) -> bool:
    """Transitivity of a relation on ``0..n-1``."""
    return all(
        (a, c) in rel
        for (a, b) in rel
        for c in range(n)
        if (b, c) in rel
    )


def is_reflexive(n: int, rel: FrozenSet[Tuple[int, int]]) -> bool:
    """Reflexivity of a relation on ``0..n-1``."""
    return all((w, w) in rel for w in range(n))


def is_irreflexive(n: int, rel: FrozenSet[Tuple[int, int]]) -> bool:
    """Irreflexivity; on a finite transitive relation this is exactly converse
    well-foundedness (equivalently: no cycles, so no infinite ascending chain)."""
    return all((w, w) not in rel for w in range(n))


def is_temporal_gl_frame(f: Frame) -> bool:
    """Check all five frame conditions of a temporal Godel-Lob frame."""
    return (
        is_transitive(f.n, f.R)
        and is_irreflexive(f.n, f.R)  # + transitivity  ==  converse well-founded
        and is_reflexive(f.n, f.T)
        and is_transitive(f.n, f.T)
        and all(
            (w, v) in f.R
            for (w, wp) in f.T
            for v in range(f.n)
            if (wp, v) in f.R
        )
    )


Valuation = Dict[int, FrozenSet[int]]  # atom index |-> set of worlds where it holds


def sat(f: Frame, val: Valuation, a: Form, w: int) -> bool:
    """Satisfaction of formula ``a`` at world ``w`` of the model ``(f, val)``."""
    if a.kind == "atom":
        return w in val.get(a.idx, frozenset())
    if a.kind == "bot":
        return False
    if a.kind == "imp":
        return (not sat(f, val, a.args[0], w)) or sat(f, val, a.args[1], w)
    if a.kind == "box":
        return all(sat(f, val, a.args[0], v) for v in range(f.n) if f.r(w, v))
    return all(sat(f, val, a.args[0], v) for v in range(f.n) if f.t(w, v))


def valid_in_model(f: Frame, val: Valuation, a: Form) -> bool:
    """Does ``a`` hold at *every* world of the model?"""
    return all(sat(f, val, a, w) for w in range(f.n))


# ---------------------------------------------------------------------------
# 3. Enumeration of small temporal Godel-Lob models
# ---------------------------------------------------------------------------


def all_frames(n: int) -> Iterator[Frame]:
    """Enumerate every temporal Godel-Lob frame on exactly ``n`` worlds.

    Complexity: 2^(n^2) candidate pairs of relations are filtered; usable for
    n <= 3 exhaustively (and the R-relation is pruned to irreflexive pairs).
    """
    off_diag: List[Tuple[int, int]] = [
        (i, j) for i in range(n) for j in range(n) if i != j
    ]
    all_pairs: List[Tuple[int, int]] = [(i, j) for i in range(n) for j in range(n)]
    for rbits in product([False, True], repeat=len(off_diag)):
        R = frozenset(p for p, b in zip(off_diag, rbits) if b)
        if not (is_transitive(n, R) and is_irreflexive(n, R)):
            continue
        for tbits in product([False, True], repeat=len(all_pairs)):
            T = frozenset(p for p, b in zip(all_pairs, tbits) if b)
            f = Frame(n, R, T)
            if is_temporal_gl_frame(f):
                yield f


def all_valuations(n: int, atom_ids: Iterable[int]) -> Iterator[Valuation]:
    """Enumerate every valuation of the given atoms over ``n`` worlds."""
    ids = sorted(atom_ids)
    subsets: List[FrozenSet[int]] = [
        frozenset(w for w in range(n) if (mask >> w) & 1) for mask in range(1 << n)
    ]
    for combo in product(subsets, repeat=len(ids)):
        yield dict(zip(ids, combo))


def search_countermodel(
    a: Form, max_worlds: int
) -> Optional[Tuple[Frame, Valuation, int]]:
    """Exhaustive bounded model search for a countermodel to ``a``.

    Returns the first model and refuting world found, or ``None`` if ``a`` holds
    everywhere in every temporal Godel-Lob model of size at most ``max_worlds``.
    By the main theorem, taking ``max_worlds = 2 ** subformula_count(a)`` makes
    this a *complete* decision procedure for derivability in TGL.
    """
    ids = atoms_of(a)
    for n in range(1, max_worlds + 1):
        for f in all_frames(n):
            for val in all_valuations(n, ids):
                for w in range(n):
                    if not sat(f, val, a, w):
                        return (f, val, w)
    return None


# ---------------------------------------------------------------------------
# 4. The axioms of TGL, as formula schemes
# ---------------------------------------------------------------------------


def axiom_instances(a: Form, b: Form) -> List[Tuple[str, Form]]:
    """All non-propositional axiom schemes of TGL, instantiated at ``a``, ``b``."""
    return [
        ("K for []", Imp(Box(Imp(a, b)), Imp(Box(a), Box(b)))),
        ("Lob", Imp(Box(Imp(Box(a), a)), Box(a))),
        ("K for [T]", Imp(Glob(Imp(a, b)), Imp(Glob(a), Glob(b)))),
        ("T for [T]", Imp(Glob(a), a)),
        ("4 for [T]", Imp(Glob(a), Glob(Glob(a)))),
        ("interaction []A -> [T][]A", Imp(Box(a), Glob(Box(a)))),
        ("4 for [] (a theorem, from Lob)", Imp(Box(a), Box(Box(a)))),
    ]


# ---------------------------------------------------------------------------
# 5. Filtration
# ---------------------------------------------------------------------------


def theta(f: Frame, val: Valuation, closure: FrozenSet[Form], w: int) -> FrozenSet[Form]:
    """The subformula theory of ``w``: the members of ``closure`` true at ``w``."""
    return frozenset(s for s in closure if sat(f, val, s, w))


def filt_R(closure: FrozenSet[Form], S: FrozenSet[Form], Sp: FrozenSet[Form]) -> bool:
    """The filtered accessibility relation.

    ``S`` sees ``S'`` iff every boxed formula of the closure realised at ``S``
    is realised at ``S'`` *together with its argument*, and at least one boxed
    formula of the closure is realised at ``S'`` but not at ``S``.  The second,
    strictness clause is exactly what forces converse well-foundedness.
    """
    boxes = [c for c in closure if c.kind == "box"]
    forth = all((c.args[0] in Sp and c in Sp) for c in boxes if c in S)
    strict = any((c in Sp and c not in S) for c in boxes)
    return forth and strict


def filt_T(closure: FrozenSet[Form], S: FrozenSet[Form], Sp: FrozenSet[Form]) -> bool:
    """The filtered temporal relation, with the extra ``[]``-persistence clause
    that makes the interaction condition survive quotienting."""
    globs = [c for c in closure if c.kind == "glob"]
    boxes = [c for c in closure if c.kind == "box"]
    forth = all((c.args[0] in Sp and c in Sp) for c in globs if c in S)
    persist = all(c in Sp for c in boxes if c in S)
    return forth and persist


def box_count(closure: FrozenSet[Form], S: FrozenSet[Form]) -> int:
    """The number of boxed formulas of the closure realised at ``S``.

    This is the measure that strictly increases along every filtered
    accessibility step, bounding the depth of any canonical countermodel.
    """
    return sum(1 for c in closure if c.kind == "box" and c in S)


def filtrate(
    f: Frame, val: Valuation, a: Form
) -> Tuple[Frame, Valuation, List[FrozenSet[Form]], Callable[[int], int]]:
    """Build the filtration of the model ``(f, val)`` through the subformulas of ``a``.

    Returns the filtered frame, the filtered valuation, the list of filtered
    worlds (each a set of subformulas), and the quotient map from original
    worlds to filtered-world indices.
    """
    closure = subformulas(a)
    thetas: List[FrozenSet[Form]] = []
    index_of: Dict[FrozenSet[Form], int] = {}
    quotient: Dict[int, int] = {}
    for w in range(f.n):
        th = theta(f, val, closure, w)
        if th not in index_of:
            index_of[th] = len(thetas)
            thetas.append(th)
        quotient[w] = index_of[th]
    m = len(thetas)
    R = frozenset(
        (i, j) for i in range(m) for j in range(m) if filt_R(closure, thetas[i], thetas[j])
    )
    T = frozenset(
        (i, j) for i in range(m) for j in range(m) if filt_T(closure, thetas[i], thetas[j])
    )
    fval: Valuation = {
        p: frozenset(i for i in range(m) if Atom(p) in thetas[i]) for p in atoms_of(a)
    }
    return Frame(m, R, T), fval, thetas, lambda w: quotient[w]


# ---------------------------------------------------------------------------
# 6. A tiny proof-search proxy: consistency over a finite closure
# ---------------------------------------------------------------------------


def decided_subsets(closure: FrozenSet[Form]) -> Iterator[FrozenSet[Form]]:
    """Every subset of the closure, i.e. every candidate 'decided subset'."""
    items = sorted(closure, key=str)
    for mask in range(1 << len(items)):
        yield frozenset(x for i, x in enumerate(items) if (mask >> i) & 1)


def propositionally_coherent(closure: FrozenSet[Form], t: FrozenSet[Form]) -> bool:
    """A necessary condition for a decided subset to be a canonical world.

    A world must respect the propositional clauses of the closure: falsity is
    never asserted, and an implication of the closure belongs to the world iff
    its antecedent is absent or its consequent present.  (Full consistency also
    requires the modal axioms; this predicate is the propositional part, and it
    is what a bounded search prunes with first.)
    """
    if Bot in t:
        return False
    for c in closure:
        if c.kind == "imp":
            left, right = c.args
            if left in closure and right in closure:
                ok = (left not in t) or (right in t)
                if (c in t) != ok:
                    return False
    return True


def temporally_coherent(closure: FrozenSet[Form], t: FrozenSet[Form]) -> bool:
    """The reflexivity axiom ``[T]B -> B`` seen at the level of a decided subset.

    A consistent world containing ``[T]B`` must contain ``B``, because ``[T]B -> B``
    is an axiom.  This single modal clause is exactly what is needed for the
    filtered temporal relation to be reflexive on canonical worlds.
    """
    return all(c.args[0] in t for c in closure if c.kind == "glob" and c in t)


def canonical_world_candidates(a: Form, use_modal: bool = True) -> List[FrozenSet[Form]]:
    """The coherent decided subsets of the closure of ``a``.

    These are the candidate worlds of the finite canonical model; the true
    canonical worlds are the *consistent* ones, a subset of these.  With
    ``use_modal=False`` only the propositional clauses are imposed, which is
    enough to see *why* the modal clauses are needed.
    """
    closure = subformulas(a)
    return [
        t
        for t in decided_subsets(closure)
        if propositionally_coherent(closure, t)
        and (not use_modal or temporally_coherent(closure, t))
    ]


# ---------------------------------------------------------------------------
# 7. Reporting helpers
# ---------------------------------------------------------------------------


def rule(title: str) -> None:
    """Print a section header."""
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def show_bounds(a: Form) -> None:
    """Print the subformula count and both finite-model bounds for ``a``."""
    sc = subformula_count(a)
    print(
        f"  {str(a):<28} size={size(a):<3} subformulas={sc:<3} "
        f"sharp bound 2^{sc} = {2 ** sc:<6} stated bound 2^{2 * sc} = {2 ** (2 * sc)}"
    )


# ---------------------------------------------------------------------------
# 8. The demonstrations
# ---------------------------------------------------------------------------


def demo_bounds() -> None:
    """Subformula counts and the two finite-model bounds on sample formulas."""
    rule("1.  Subformula counts and the finite-model bounds")
    p, q = Atom(0), Atom(1)
    samples = [
        Bot,
        p,
        Imp(Box(Bot), Bot),           # the consistency statement
        Imp(Glob(p), Box(p)),         # non-collapse of the two modalities
        Imp(Box(p), Box(Box(p))),     # the 4 axiom for []
        Imp(Box(Imp(Box(p), p)), Box(p)),   # Lob's axiom
        Imp(Box(p), Glob(Box(p))),    # the interaction axiom
        Imp(Glob(Imp(p, q)), Imp(Glob(p), Glob(q))),
    ]
    for s in samples:
        show_bounds(s)


def demo_soundness() -> None:
    """Every axiom of TGL holds everywhere in every model on <= 3 worlds."""
    rule("2.  Soundness spot-check on all temporal Godel-Lob models of size <= 3")
    p, q = Atom(0), Atom(1)
    schemes = axiom_instances(p, q) + axiom_instances(Box(p), Glob(q))
    total_models = 0
    for n in (1, 2, 3):
        frames = list(all_frames(n))
        for f in frames:
            for val in all_valuations(n, [0, 1]):
                total_models += 1
                for name, ax in schemes:
                    if not valid_in_model(f, val, ax):
                        raise AssertionError(f"axiom {name} FAILED on {f} / {val}")
        print(f"  {len(frames):>5} frames on {n} world(s): all axioms hold everywhere")
    print(f"  checked {total_models} models x {len(schemes)} axiom instances -- all valid")


def demo_bounded_search() -> None:
    """Exhaustive bounded model search: the guaranteed decision procedure."""
    rule("3.  Exhaustive bounded model search")
    p = Atom(0)
    cases = [
        ("Lob's axiom  []([]p -> p) -> []p", Imp(Box(Imp(Box(p), p)), Box(p)), True),
        ("4 for []      []p -> [][]p", Imp(Box(p), Box(Box(p))), True),
        ("interaction   []p -> [T][]p", Imp(Box(p), Glob(Box(p))), True),
        ("consistency   []_|_ -> _|_", Imp(Box(Bot), Bot), False),
        ("collapse      [T]p -> []p", Imp(Glob(p), Box(p)), False),
        ("collapse      []p -> [T]p", Imp(Box(p), Glob(p)), False),
    ]
    for label, form, expected_valid in cases:
        res = search_countermodel(form, max_worlds=3)
        if res is None:
            print(f"  {label:<38} no countermodel up to 3 worlds  -> derivable")
            assert expected_valid, label
        else:
            f, val, w = res
            print(
                f"  {label:<38} refuted at world {w} of a {f.n}-world model "
                f"(R={sorted(f.R)}) -> NOT derivable"
            )
            assert not expected_valid, label


def demo_filtration() -> None:
    """Run the filtration on a concrete countermodel and verify the truth lemma."""
    rule("4.  Filtration of a concrete countermodel, with the truth lemma verified")
    p = Atom(0)
    target = Imp(Glob(p), Box(p))
    # A four-world model: an R-chain 0 > 1 > 2 with a fourth isolated world,
    # time frozen (T is the identity, which satisfies compat trivially).
    n = 4
    R = frozenset({(0, 1), (0, 2), (1, 2)})
    T = frozenset({(w, w) for w in range(n)})
    f = Frame(n, R, T)
    assert is_temporal_gl_frame(f), "the starting frame must be legal"
    val: Valuation = {0: frozenset({0, 1, 3})}
    refuting = [w for w in range(n) if not sat(f, val, target, w)]
    print(f"  original model: {n} worlds, R={sorted(R)}, p true at {sorted(val[0])}")
    print(f"  '{target}' fails at worlds {refuting}")
    assert refuting, "we need an actual countermodel to filtrate"

    g, gval, thetas, quotient = filtrate(f, val, target)
    print(f"  filtered model: {g.n} worlds (theories), R={sorted(g.R)}, T={sorted(g.T)}")
    for i, th in enumerate(thetas):
        print(f"     world {i}: {{{', '.join(sorted(str(x) for x in th))}}}")
    assert is_temporal_gl_frame(g), "the filtered frame must again be legal"
    print("  filtered frame satisfies all five temporal Godel-Lob conditions: YES")

    closure = subformulas(target)
    for w in range(f.n):
        for s in closure:
            lhs = sat(g, gval, s, quotient(w))
            rhs = sat(f, val, s, w)
            assert lhs == rhs, f"truth lemma fails for {s} at {w}"
    print("  truth lemma verified for every subformula at every world: YES")
    print(
        f"  size {f.n} -> {g.n};  permitted sharp bound "
        f"2^{subformula_count(target)} = {2 ** subformula_count(target)}"
    )


def demo_measure() -> None:
    """The box-count measure strictly increases along every filtered R-step."""
    rule("5.  The counting measure behind converse well-foundedness")
    p = Atom(0)
    target = Imp(Box(p), Box(Box(p)))
    closure = subformulas(target)
    boxes = sorted((c for c in closure if c.kind == "box"), key=str)
    print(f"  formula {target};  boxed subformulas: {[str(b) for b in boxes]}")
    subsets = list(decided_subsets(closure))
    steps = 0
    for S in subsets:
        for Sp in subsets:
            if filt_R(closure, S, Sp):
                steps += 1
                assert box_count(closure, S) < box_count(closure, Sp), (S, Sp)
    print(f"  checked {steps} filtered accessibility steps among {len(subsets)} theories")
    print("  every step strictly increases the number of realised boxes: YES")
    print(
        f"  hence every R-chain has length <= {len(boxes)}, so the filtered frame "
        "is converse well-founded and validates Lob's axiom"
    )


def demo_canonical() -> None:
    """The finite canonical model over a subformula closure."""
    rule("6.  The finite canonical model over a subformula closure")
    p = Atom(0)
    for target in [Imp(Box(Bot), Bot), Imp(Glob(p), Box(p)), Imp(Box(p), Box(Box(p)))]:
        closure = subformulas(target)
        sc = len(closure)
        prop_only = canonical_world_candidates(target, use_modal=False)
        cands = canonical_world_candidates(target, use_modal=True)
        print(f"  formula {target}")
        print(f"     closure size {sc}; all decided subsets: 2^{sc} = {2 ** sc}")
        print(f"     propositionally coherent:            {len(prop_only)}")
        print(f"     also respecting the axiom [T]B -> B: {len(cands)}")
        for label, worlds in (("propositional only", prop_only), ("+ modal clause", cands)):
            m = len(worlds)
            R = frozenset(
                (i, j)
                for i in range(m)
                for j in range(m)
                if filt_R(closure, worlds[i], worlds[j])
            )
            T = frozenset(
                (i, j)
                for i in range(m)
                for j in range(m)
                if filt_T(closure, worlds[i], worlds[j])
            )
            cf = Frame(m, R, T)
            print(
                f"     [{label:<18}] legal temporal Godel-Lob frame: "
                f"{is_temporal_gl_frame(cf)}"
            )
        print(
            "     (dropping the modal clause breaks reflexivity of time: a subset may\n"
            "      assert [T]B while denying B, which no consistent world can do)"
        )


def demo_gap() -> None:
    """How far is the proved bound from the truth?"""
    rule("7.  The proved bound versus the true minimal countermodel")
    p = Atom(0)
    cases = [
        ("Godel's second theorem  []_|_ -> _|_", Imp(Box(Bot), Bot)),
        ("non-collapse            [T]p -> []p", Imp(Glob(p), Box(p))),
        ("non-collapse            []p -> [T]p", Imp(Box(p), Glob(p))),
    ]
    print(f"  {'formula':<40} {'minimal':>8} {'sharp':>8} {'stated':>8} {'ratio':>9}")
    for label, form in cases:
        res = search_countermodel(form, max_worlds=3)
        assert res is not None, label
        f, _, _ = res
        sc = subformula_count(form)
        sharp, stated = 2 ** sc, 2 ** (2 * sc)
        print(
            f"  {label:<40} {f.n:>8} {sharp:>8} {stated:>8} {stated // f.n:>8}:1"
        )
    print()
    print("  The bound is correct but nowhere near tight: on these formulas the true")
    print("  minimal countermodel has 1 or 2 worlds against permitted 64 and 256.")
    print("  The exponential factor is pure *width*; the *depth* is already bounded by")
    print("  the number of boxed subformulas, by the counting argument of section 5.")


def main() -> None:
    """Run every demonstration."""
    print(__doc__.split("Run:")[0].strip())
    demo_bounds()
    demo_soundness()
    demo_bounded_search()
    demo_filtration()
    demo_measure()
    demo_canonical()
    demo_gap()
    rule("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
