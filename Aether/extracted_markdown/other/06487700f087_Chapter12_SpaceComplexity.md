# Chapter 12: Space Complexity

## 12.1 A Different Resource

Time is not the only computational resource. **Space** — the amount of memory used during
a computation — is equally fundamental, and leads to a different but deeply connected
complexity theory.

Space complexity has its own surprises: some problems that seem to require a lot of time
can be solved in very little space, and vice versa. The interplay between time and space
is one of the richest areas of complexity theory.

## 12.2 Definitions

**Definition**. A Turing machine `M` runs in space `S(n)` if for every input of length `n`,
`M` uses at most `S(n)` cells on its work tape(s). (The input tape is read-only and does
not count toward space usage.)

**Definition**:
- `SPACE(S(n))` = languages decidable in space `O(S(n))`
- `NSPACE(S(n))` = languages decidable by an NTM in space `O(S(n))`
- `L = SPACE(log n)` — logarithmic space
- `NL = NSPACE(log n)` — nondeterministic logarithmic space
- `PSPACE = ⋃ₖ SPACE(nᵏ)` — polynomial space

## 12.3 Fundamental Relationships

**Theorem (Space-Time Relationships)**:

```
L ⊆ NL ⊆ P ⊆ NP ⊆ PSPACE ⊆ EXPTIME
```

- `L ⊆ P`: A logspace machine makes at most polynomially many distinct configurations
  (state × head position × tape content), so it halts in polynomial time.
- `NP ⊆ PSPACE`: To check if an NTM accepts, systematically try all branches of the
  nondeterministic computation, reusing space between branches.
- `PSPACE ⊆ EXPTIME`: A machine using polynomial space has at most exponentially many
  configurations, so it halts in exponential time (or loops, which we can detect).

We know that `L ≠ EXPTIME` (by a diagonalization argument), but the individual separations
`L ≠ NL`, `NL ≠ P`, `P ≠ NP`, `NP ≠ PSPACE`, `PSPACE ≠ EXPTIME` are all open!

## 12.4 PSPACE-Completeness

**Definition**. A language `B` is **PSPACE-complete** if `B ∈ PSPACE` and every `A ∈ PSPACE`
is polynomial-time reducible to `B`.

**Theorem (TQBF is PSPACE-complete)**. The language of True Quantified Boolean Formulas:

> `TQBF = {⟨φ⟩ : φ is a true fully quantified Boolean formula}`

is PSPACE-complete.

Example: `∀x. ∃y. (x ∨ y) ∧ (¬x ∨ ¬y)` is true (for each `x`, choose `y = ¬x`).

TQBF generalizes SAT by allowing universal quantifiers. While SAT asks "is there an
assignment?", TQBF asks "for all assignments to some variables, does there exist
assignments to others, such that...?"

## 12.5 Games and PSPACE

PSPACE-complete problems naturally arise from **two-player games**:

- **Generalized chess** (on an n×n board): PSPACE-complete (actually EXPTIME-complete)
- **Generalized checkers**: PSPACE-complete
- **Generalized Go**: PSPACE-complete (actually EXPTIME-complete)
- **Geography**: PSPACE-complete
- **Hex**: PSPACE-complete

The connection is natural: a game with alternating moves (player 1 / player 2) corresponds
to alternating quantifiers (∃ / ∀) in TQBF.

## 12.6 Savitch's Theorem

**Theorem (Savitch, 1970)**. `NSPACE(S(n)) ⊆ SPACE(S(n)²)` for `S(n) ≥ log n`.

*Proof idea*. The key question is: can configuration `C₁` reach configuration `C₂` in at
most `t` steps using space `S(n)`?

Use the recursive strategy: `C₁` can reach `C₂` in `t` steps iff there exists a midpoint
configuration `C_m` such that `C₁` reaches `C_m` in `t/2` steps and `C_m` reaches `C₂`
in `t/2` steps.

This recursion has depth `O(log t)`, and each level requires `O(S(n))` space to store
the configuration. Since `t ≤ 2^{O(S(n))}`, the total space is `O(S(n)²)`. ∎

**Corollary**. `PSPACE = NPSPACE` — determinism and nondeterminism are polynomially
related for space (unlike the situation for time, where we don't know if P = NP).

## 12.7 The Immerman–Szelepcsényi Theorem

**Theorem (Immerman–Szelepcsényi, 1987)**. `NSPACE(S(n)) = co-NSPACE(S(n))` for
`S(n) ≥ log n`.

This was a major surprise: nondeterministic space classes are closed under complement!
In particular, `NL = co-NL`.

The proof uses an ingenious inductive counting technique: to verify that a string is *not*
in the language, the NTM counts the number of reachable configurations and verifies that
none of them is accepting.

## 12.8 Logspace Reductions

For problems in NL and L, polynomial-time reductions are too powerful (they could solve
the problem outright). We use **logspace reductions** instead:

**Definition**. `A ≤_L B` if there is a function `f` computable in logarithmic space such
that `w ∈ A ↔ f(w) ∈ B`.

**NL-complete problems**:
- **PATH**: Given a directed graph and two vertices `s` and `t`, is there a path from `s`
  to `t`?
- **2-SAT**: Given a 2-CNF Boolean formula, is it satisfiable?

**Theorem**. PATH is NL-complete.

## 12.9 L and NL

The class L (logspace) is remarkably restrictive yet surprisingly powerful:

**Problems in L**:
- Recognizing regular languages
- Addition and multiplication of integers
- Checking if a graph is connected (Reingold, 2005 — a major breakthrough!)

**The L vs NL Question**: Is L = NL? This is the space analogue of P vs NP, and it is
equally open. Since NL ⊆ P, resolving L vs NL would be a step toward resolving P vs NP.

## 12.10 The Space Hierarchy

**Space Hierarchy Theorem**. For any space-constructible function `S(n)`:

> `SPACE(o(S(n))) ⊊ SPACE(S(n))`

This theorem guarantees that more space genuinely helps: there are problems solvable in
`n²` space but not in `n` space, problems solvable in `2ⁿ` space but not in `nᵏ` space,
and so on.

Combined with the analogous Time Hierarchy Theorem (`TIME(o(T(n))) ⊊ TIME(T(n) · log T(n))`),
these results provide the few unconditional separations we have in complexity theory.

---

*"Savitch's theorem is the space complexity analogue of a result that we would dearly love
to prove for time complexity — but cannot."*
— Christos Papadimitriou
