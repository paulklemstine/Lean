# Chapter 11: Time Complexity — P and NP

## 11.1 From Possibility to Efficiency

So far, we have asked: *can* a problem be solved? Now we ask: *how quickly* can it be
solved? This shift — from computability to complexity — transforms our subject from a
branch of logic into the foundation of practical computer science.

A function might be computable in principle but require more time than the age of the
universe to evaluate on moderately sized inputs. Complexity theory makes this distinction
precise by classifying problems according to the *resources* (time, space, randomness,
communication, etc.) needed to solve them.

## 11.2 Measuring Time

**Definition**. A Turing machine `M` runs in time `T(n)` if for every input of length `n`,
`M` halts within `T(n)` steps.

**Definition**. `TIME(T(n))` is the class of languages decidable by a TM running in time
`O(T(n))`.

The exact running time depends on the machine model (single-tape TM, multi-tape TM, RAM),
but polynomial differences don't matter:

**Theorem (Linear Speedup)**. For any TM running in time `T(n)`, there exists an
equivalent TM running in time `εT(n) + n + 2` for any `ε > 0`.

**Theorem (Tape Compression)**. Changing the number of tapes changes the running time by
at most a polynomial factor.

These results motivate the polynomial/exponential divide as the "right" boundary between
efficient and inefficient computation.

## 11.3 The Class P

**Definition**. `P = ⋃ₖ TIME(nᵏ)` — the class of languages decidable in polynomial time.

P is widely regarded as the class of "efficiently solvable" problems. It includes:

- **Sorting**: Given a list, sort it. `O(n log n)`
- **Shortest path**: Given a graph and two vertices, find the shortest path. `O(n²)` or
  better.
- **Matching**: Given a bipartite graph, find a maximum matching. `O(n³)` or better.
- **Primality**: Given a number, is it prime? `O(n¹²)` originally (AKS), improved since.
- **Linear programming**: Given a system of linear inequalities, find a feasible solution.
  Polynomial (Khachiyan, 1979).
- **Context-free language membership**: Given a CFG and a string, is the string in the
  language? `O(n³)` (CYK algorithm).

## 11.4 The Class NP

**Definition**. `NP` is the class of languages `L` for which there exists a polynomial-time
**verifier** `V` and a polynomial `p` such that:

> `w ∈ L ↔ ∃c (|c| ≤ p(|w|) ∧ V accepts ⟨w, c⟩)`

The string `c` is called a **certificate** (or **witness**). The idea: even if finding a
solution is hard, *verifying* a proposed solution is easy.

Equivalently, NP is the class of languages decided by a nondeterministic TM in polynomial
time. (The nondeterminism "guesses" the certificate.)

**Examples**:
- **SAT**: Given a Boolean formula, is it satisfiable? Certificate: a satisfying
  assignment.
- **CLIQUE**: Given a graph and integer `k`, does it contain a clique of size `k`?
  Certificate: the `k` vertices.
- **SUBSET-SUM**: Given integers and a target `t`, is there a subset summing to `t`?
  Certificate: the subset.
- **HAMILTONIAN PATH**: Given a graph, is there a path visiting every vertex exactly once?
  Certificate: the path.
- **COMPOSITE**: Given `n`, is `n` composite? Certificate: a nontrivial factor.
  (Actually, COMPOSITE is also in P, since PRIMES is in P.)

## 11.5 P vs NP

The question **P = NP?** asks whether every problem whose solutions can be *verified*
efficiently can also be *solved* efficiently.

This is arguably the most important open problem in mathematics and computer science. It is
one of the seven Clay Millennium Prize Problems, carrying a $1,000,000 prize.

**Intuition for P ≠ NP**: Finding a proof seems harder than checking a proof. Composing a
symphony seems harder than appreciating one. Solving a jigsaw puzzle seems harder than
verifying a completed puzzle.

**Intuition for P = NP**: Maybe we just haven't been clever enough. The discovery that
PRIMES ∈ P (AKS, 2002) and that linear programming is in P (Khachiyan, 1979) shows that
problems once thought to require exponential time can sometimes be solved efficiently.

**Current Status**: Virtually all experts believe P ≠ NP, but no proof exists. We cannot
even prove superlinear lower bounds for most natural problems!

## 11.6 NP-Completeness

**Definition**. A language `B` is **NP-hard** if every language `A ∈ NP` satisfies
`A ≤_P B` (polynomial-time many-one reducibility).

**Definition**. A language `B` is **NP-complete** if `B ∈ NP` and `B` is NP-hard.

NP-complete problems are the "hardest" problems in NP. If *any* NP-complete problem is in
P, then *all* of NP is in P (i.e., P = NP).

## 11.7 The Cook–Levin Theorem

**Theorem (Cook, 1971; Levin, 1973)**. SAT is NP-complete.

*Proof sketch*. The key idea is that the computation of any polynomial-time NTM can be
encoded as a Boolean formula. Given an NTM `M` running in time `p(n)`:

1. Create Boolean variables for each cell of the computation tableau (state, tape symbol,
   head position at each time step).
2. Write clauses ensuring the initial configuration matches the input.
3. Write clauses ensuring each step follows the transition function.
4. Write clauses ensuring the final state is accepting.

The resulting formula is satisfiable iff `M` accepts the input. The formula has size
polynomial in `p(n)`, and the reduction runs in polynomial time. ∎

## 11.8 The Web of NP-Completeness

After Cook proved SAT was NP-complete, Richard Karp (1972) showed that 21 natural
combinatorial problems are NP-complete by giving polynomial reductions from SAT. Today,
thousands of NP-complete problems are known:

```
SAT
├── 3-SAT
│   ├── CLIQUE
│   │   ├── VERTEX-COVER
│   │   └── INDEPENDENT-SET
│   ├── 3-COLORING
│   └── SUBSET-SUM
│       ├── KNAPSACK
│       └── PARTITION
├── HAMILTONIAN-PATH
│   └── TRAVELING-SALESMAN
├── INTEGER-PROGRAMMING
└── ...
```

## 11.9 Coping with NP-Completeness

Since (assuming P ≠ NP) NP-complete problems have no polynomial-time algorithms, how do
we solve them in practice?

1. **Approximation algorithms**: Find solutions within a guaranteed factor of optimal.
   (e.g., 2-approximation for VERTEX-COVER)
2. **Parameterized complexity**: If a parameter `k` is small, an algorithm running in
   `f(k) · nᶜ` might be practical. (Fixed-parameter tractability)
3. **Average-case analysis**: Maybe the hard instances are rare. (Random SAT instances are
   often easy.)
4. **Heuristics**: SAT solvers (DPLL, CDCL) work amazingly well on practical instances
   despite worst-case exponential behavior.
5. **Restriction**: Many NP-complete problems become polynomial on restricted inputs (e.g.,
   graph coloring on interval graphs, SAT on 2-SAT instances).

## 11.10 The Complexity Zoo

NP is just one of hundreds of complexity classes. Here are a few of the most important:

| Class        | Definition                                      |
|-------------|------------------------------------------------|
| P           | Polynomial-time decidable                       |
| NP          | Polynomial-time verifiable                      |
| co-NP       | Complement of NP problems                       |
| BPP         | Probabilistic polynomial time (bounded error)   |
| RP          | Randomized polynomial time (one-sided error)    |
| ZPP         | Zero-error probabilistic polynomial time        |
| PSPACE      | Polynomial space                                |
| EXPTIME     | Exponential time                                |
| #P          | Counting problems associated with NP            |
| PH          | Polynomial hierarchy (generalization of NP)     |
| IP          | Interactive proofs                              |
| BQP         | Bounded-error quantum polynomial time           |

The relationships among these classes form the "complexity zoo" — a rich and largely
uncharted landscape. Most of the suspected separations (P ≠ NP, NP ≠ co-NP, P ≠ PSPACE,
etc.) remain unproven.

---

*"If P = NP, then the world would be a profoundly different place than we usually assume
it to be. There would be no special value in 'creative leaps,' no fundamental gap between
solving a problem and recognizing the solution once it's found."*
— Scott Aaronson
