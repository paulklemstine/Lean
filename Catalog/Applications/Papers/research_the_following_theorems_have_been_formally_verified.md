# Exact Finite-Height Collapse and the Ordinal Arithmetic Ladder for Well-Founded Trees

## Abstract

We establish two main results in ordinal collapse theory for well-founded trees. First, the **Exact Height-Depth Law**: for research objects (finite trees with atom, compose, bootstrap, and oracle constructors), the natural depth satisfies `natDepth(R) ≤ 2^height(R)`, and this bound is tight — balanced binary composition trees achieve exact equality. This sharpens the previous bound of `2^(height+1)` and identifies balanced binary trees as the canonical extremizers. Second, the **Ordinal Tower Realization Theorem**: for every natural number `n`, there exists a constructively defined infinitely branching tree with ordinal rank exactly `ω^n`. This is established via two new tree operations — ordinal addition by pattern grafting (`addByPattern`) and ordinal multiplication by iteration (`mulByPattern`) — which satisfy `rank(addByPattern(s, t)) = rank(t) + rank(s)` and `rank(mulByPattern(s, k)) = rank(s) · k`. All results have been formally verified with machine-checked proofs using no axioms beyond the standard foundations (propext, choice, Quot.sound).

**Keywords:** ordinal analysis, well-founded trees, exact extremal bounds, ordinal arithmetic, termination certificates, formal verification

---

## 1. Introduction

### 1.1 Motivation

Ordinal-valued complexity measures on well-founded structures arise naturally in proof theory (derivation heights, proof-theoretic ordinals), computer science (termination analysis, program complexity), and combinatorics (extremal tree problems). A fundamental question is: given structural constraints on a tree (bounded height, bounded branching, bounded nesting), what ordinal ranks are achievable?

Previous work established a framework of *research objects* — finite trees with four constructors — and proved several foundational results:
- The Finite Branching Collapse Theorem: all research objects have depth < ω.
- The Bridge Theorem: computable natural depth equals ordinal depth.
- Height stratification: height ≤ n implies depth ≤ 2^(n+1).
- Spectrum sharpness: every natural number is realized as a depth.
- Transfinite escape: the omega tree achieves rank exactly ω.
- Affine growth: successor-law operators produce linear depth iteration.

However, two significant gaps remained:
1. The height-depth bound 2^(n+1) was known to have slack, but the exact extremal formula was open.
2. The only transfinite rank achieved was ω. Whether higher ordinals (ω², ω³, ω^n) could be explicitly constructed was unknown.

### 1.2 Contributions

This paper closes both gaps:

1. **Exact finite-height collapse** (§3): We prove `natDepth(R) ≤ 2^height(R)` for all research objects R, and construct balanced binary trees achieving exact equality. This gives the sharp extremal law for the finite regime.

2. **Ordinal arithmetic on trees** (§4): We define two new operations — addByPattern (ordinal addition) and mulByPattern (ordinal multiplication) — and prove they satisfy the expected ordinal arithmetic identities.

3. **Ordinal tower realization** (§5): We construct `omegaPowTree(n)` with rank exactly ω^n for every n ∈ ℕ, building the first ordinal arithmetic ladder in the theory.

4. **Complete formal verification** (§6): All results are machine-checked, using only standard foundational axioms.

### 1.3 Related Work

The ordinal analysis of well-founded trees has a long history. Dershowitz and Manna (1979) introduced ordinal-based termination proofs for programs. Buchholz (1987) and Rathjen (1990s) developed ordinal notation systems for proof theory. Cichon and Tahhan Bittar (1998) studied derivation heights in term rewriting.

Our work differs in that we provide *constructive witnesses* (concrete tree objects) for each ordinal rank, rather than abstract existence proofs. The addByPattern and mulByPattern operations give a computational handle on ordinal arithmetic that is directly implementable and formally verifiable.

---

## 2. Definitions and Notation

### 2.1 Research Objects

A research object is an element of the inductive type:

```
ResearchObject ::=
  | atom(n : ℕ)
  | compose(A : RO, B : RO)
  | bootstrap(A : RO)
  | oracleNode(arity : ℕ, deps : Fin(arity) → RO)
```

### 2.2 Depth Functions

The **ordinal depth** is defined recursively:
- `researchDepth(atom n) = 1`
- `researchDepth(compose A B) = researchDepth(A) + researchDepth(B)`
- `researchDepth(bootstrap A) = succ(researchDepth(A))`
- `researchDepth(oracleNode arity deps) = sup_{i < arity} succ(researchDepth(deps(i)))`

The **natural depth** `natDepth` is the computable ℕ-valued version, which equals `researchDepth` when cast to ordinals (Bridge Theorem).

### 2.3 Height

The **height** of a research object is the maximum nesting depth:
- `height(atom n) = 0`
- `height(compose A B) = max(height(A), height(B)) + 1`
- `height(bootstrap A) = height(A) + 1`
- `height(oracleNode 0 _) = 1`
- `height(oracleNode (n+1) deps) = max_{i} height(deps(i)) + 1`

### 2.4 Infinitely Branching Trees

An `InfBranchTree` is either a `leaf` (rank 0) or `node(children : ℕ → InfBranchTree)` with rank `sup_{i:ℕ} succ(rank(children(i)))`.

---

## 3. Exact Finite-Height Collapse

### 3.1 The Upper Bound

**Theorem 3.1** (Exact Height-Depth Law). *For every research object R:*
$$\text{natDepth}(R) \leq 2^{\text{height}(R)}.$$

*Proof sketch.* By structural induction on R.

- **Atom:** `natDepth = 1 = 2^0 = 2^height`. ✓
- **Compose(A, B):** `natDepth = natDepth(A) + natDepth(B) ≤ 2^h(A) + 2^h(B)` by IH. Since `max(a,b) ≤ h(A)` or `h(B)`, we have `2^h(A) + 2^h(B) ≤ 2 · 2^max(h(A),h(B)) = 2^(max(h(A),h(B))+1) = 2^height(compose)`. ✓
- **Bootstrap(A):** `natDepth(A) + 1 ≤ 2^h(A) + 1 ≤ 2^(h(A)+1)` since `2^n + 1 ≤ 2^(n+1)` for all n ≥ 0. ✓
- **OracleNode(0, _):** `natDepth = 0 ≤ 2^1`. ✓
- **OracleNode(k+1, deps):** Each child contributes `natDepth(deps(i)) + 1 ≤ 2^h(deps(i)) + 1`. Since `h(deps(i)) ≤ max_j h(deps(j))`, we get `2^h(deps(i)) + 1 ≤ 2^max + 1 ≤ 2^(max+1) = 2^height`. ✓  □

### 3.2 The Extremizer

**Definition 3.2.** The *balanced binary tree* is defined recursively:
- `balancedTree(0) = atom(0)`
- `balancedTree(n+1) = compose(balancedTree(n), balancedTree(n))`

**Theorem 3.3** (Extremizer Properties).
1. `height(balancedTree(n)) = n`
2. `natDepth(balancedTree(n)) = 2^n`

*Proof.* Both by straightforward induction. For (1): `height(compose(B,B)) = max(n,n) + 1 = n + 1`. For (2): `natDepth(compose(B,B)) = 2^n + 2^n = 2^(n+1)`. □

**Corollary 3.4** (Exact Extremal Law). *For every n ∈ ℕ:*
$$\max\{\text{natDepth}(R) : \text{height}(R) = n\} = 2^n.$$

### 3.3 Ordinal Transfer

**Theorem 3.5.** *For every research object R:*
$$\text{researchDepth}(R) \leq 2^{\text{height}(R)}$$
*as ordinals, where the right side is the natural number 2^height(R) cast to an ordinal.*

This follows immediately from Theorem 3.1 and the Bridge Theorem.

---

## 4. Ordinal Arithmetic on Trees

### 4.1 Ordinal Addition: addByPattern

**Definition 4.1.** Given trees `pattern` and `base`, define:
- `addByPattern(leaf, base) = base`
- `addByPattern(node(f), base) = node(i ↦ addByPattern(f(i), base))`

This replaces every leaf of `pattern` with a copy of `base`.

**Theorem 4.2** (Ordinal Addition). *For all InfBranchTrees pattern and base:*
$$\text{rank}(\text{addByPattern}(\text{pattern}, \text{base})) = \text{rank}(\text{base}) + \text{rank}(\text{pattern}).$$

*Proof sketch.* By structural induction on pattern.

Base case: `addByPattern(leaf, base) = base`, and `rank(base) + 0 = rank(base)`. ✓

Inductive step: `addByPattern(node(f), base) = node(i ↦ addByPattern(f(i), base))`.
```
rank = sup_i succ(rank(addByPattern(f(i), base)))
     = sup_i succ(rank(base) + rank(f(i)))          [by IH]
     = sup_i (rank(base) + succ(rank(f(i))))         [by Ordinal.add_succ]
     = rank(base) + sup_i succ(rank(f(i)))           [by right-continuity]
     = rank(base) + rank(node(f)).                    □
```

The key step uses the fact that ordinal addition `α + (·)` is a normal function (strictly increasing and continuous), so `α + sup_i β_i = sup_i (α + β_i)` when the range is bounded above. For ℕ-indexed ordinals, boundedness is automatic.

### 4.2 Ordinal Multiplication: mulByPattern

**Definition 4.3.** Given a tree `pattern` and k ∈ ℕ:
- `mulByPattern(pattern, 0) = leaf`
- `mulByPattern(pattern, k+1) = addByPattern(pattern, mulByPattern(pattern, k))`

**Theorem 4.4** (Ordinal Multiplication). *For all InfBranchTrees pattern and k ∈ ℕ:*
$$\text{rank}(\text{mulByPattern}(\text{pattern}, k)) = \text{rank}(\text{pattern}) \cdot k.$$

*Proof.* By induction on k. Base: rank = 0 = α · 0. Step:
```
rank(mulByPattern(s, k+1)) = rank(mulByPattern(s, k)) + rank(s)    [Theorem 4.2]
                            = rank(s) · k + rank(s)                  [IH]
                            = rank(s) · (k + 1).                      □
```

---

## 5. The Ordinal Tower Realization

### 5.1 Construction

**Definition 5.1.** The omega-power tree is defined recursively:
- `omegaPowTree(0) = chain(1)` (a single node with all-leaf children, rank 1)
- `omegaPowTree(n+1) = node(k ↦ mulByPattern(omegaPowTree(n), k))`

### 5.2 Main Theorem

**Theorem 5.2** (Ordinal Tower Realization). *For every n ∈ ℕ:*
$$\text{rank}(\text{omegaPowTree}(n)) = \omega^n.$$

*Proof sketch.* By induction on n.

**Base case** (n = 0): `omegaPowTree(0) = chain(1)`, and `rank(chain(1)) = 1 = ω^0`. ✓

**Inductive step:** Assume `rank(omegaPowTree(n)) = ω^n`. Then:
```
rank(omegaPowTree(n+1)) = sup_{k:ℕ} succ(rank(mulByPattern(omegaPowTree(n), k)))
                         = sup_{k:ℕ} succ(ω^n · k)
                         = sup_{k:ℕ} (ω^n · k + 1).
```

We show this equals `ω^(n+1) = ω^n · ω`:

**Upper bound:** Each `ω^n · k + 1 ≤ ω^n · (k+1) ≤ ω^n · ω = ω^(n+1)`, since `ω^n ≥ 1`.

**Lower bound:** For any `α < ω^(n+1) = ω^n · ω`, since ω is a limit ordinal, there exists k ∈ ℕ with `α < ω^n · k`. Then `α < ω^n · k ≤ ω^n · k + 1 ≤ sup`.

Therefore `sup_{k:ℕ} (ω^n · k + 1) = ω^(n+1)`. □

**Corollary 5.3.** *For every n ∈ ℕ, there exists an InfBranchTree t with rank(t) = ω^n.*

**Corollary 5.4.** *There exists an InfBranchTree of rank ω².*

### 5.3 The Phase Diagram

Combining the tower realization with the existing collapse theorems yields the complete phase diagram:

| Structural constraint | Achievable ranks |
|---|---|
| Finite branching (any height) | Exactly {0, 1, 2, ...} = ordinals < ω |
| ℕ-branching, height ≤ n | Ordinals ≤ n |
| ℕ-branching, 1 nesting layer | Up to ω |
| ℕ-branching, d nesting layers | Up to ω^d |

---

## 6. Formal Verification

All results in this paper have been formally verified in Lean 4 with Mathlib. The development consists of three files:

1. **Defs.lean** (~120 lines): Core definitions of ResearchObject, InfBranchTree, all depth/height/rank functions, and tree operations.
2. **ExactCollapse.lean** (~110 lines): Exact height-depth law, extremizer construction, bridge theorem.
3. **OrdinalLadder.lean** (~140 lines): Chain rank, omega tree rank, addByPattern/mulByPattern rank theorems, omega-power tree rank.

The proofs use only standard axioms: `propext`, `Classical.choice`, and `Quot.sound`. No custom axioms, `sorry`, or `@[implemented_by]` annotations are used.

### 6.1 Proof Architecture

The key technical challenge in the ordinal ladder proof is establishing the right-continuity identity:
$$\alpha + \sup_i \beta_i = \sup_i (\alpha + \beta_i)$$

This is derived from the fact that ordinal addition `α + (·)` is a normal function (`Order.IsNormal`), using `Order.IsNormal.map_iSup` with boundedness provided by `Ordinal.bddAbove_range`.

The omega-power tree rank proof uses `Ordinal.mul_le_iff_of_isSuccLimit` to establish the upper bound, exploiting the fact that ω is a successor-limit ordinal.

---

## 7. Applications

### 7.1 Termination Certificates

The ordinal ladder provides explicit ranking functions for recursive programs:
- Simple recursion: rank function into ω (natural numbers).
- Doubly nested recursion: rank function into ω².
- d-fold nested recursion: rank function into ω^d.

The balanced tree extremizer shows that the worst-case derivation length at height n is exactly 2^n, providing tight complexity bounds for recursive programs.

### 7.2 Proof-Theoretic Ordinals

The omega-power trees provide constructive witnesses for the proof-theoretic strength of subsystems of arithmetic:
- Bounded arithmetic fragments: ordinals below ω^k for fixed k.
- Primitive Recursive Arithmetic: ordinal ω^ω (the limit of our ladder).
- Peano Arithmetic: ordinal ε₀ (requires transfinite iteration beyond our current construction).

### 7.3 Term Rewriting

In term rewriting systems, termination is proved by mapping terms to a well-founded ordering. Our constructions provide:
- The exact bound 2^n on derivation length at height n (tight).
- Explicit ordinal-valued ranking functions for nested rewriting rules.
- A classification scheme: the nesting depth of a rewrite system determines which ordinal level is needed for its termination proof.

---

## 8. Discussion and Open Problems

### 8.1 Sharpness of the Extremal Law

The exact formula `max depth at height n = 2^n` reveals that balanced binary composition is the canonical maximizer. This is analogous to the fact that balanced binary trees minimize depth in sorting networks, and that balanced formulas maximize circuit complexity. The universality of this phenomenon across different formalisms is suggestive of a deeper structural principle.

### 8.2 Beyond ω^ω

Our ordinal ladder reaches ω^n for every finite n. The natural next targets are:
- **ω^ω**: the supremum of the ladder. This requires iterating the omegaPowTree construction itself.
- **ε₀ = sup_n ω↑↑n**: the first fixed point of α ↦ ω^α. This requires transfinite recursion beyond the current framework.
- **Cantor Normal Form realizability**: Can every ordinal below ω^ω be constructed as a tree rank?

### 8.3 Ordinal Arithmetic Completeness

The addByPattern and mulByPattern operations raise the question: can we also realize ordinal exponentiation as a tree operation? If so, the tree algebra would form a complete computational model for ordinal arithmetic below some threshold.

---

## 9. Future Work

1. **CNF Realizability**: Prove that every ordinal in Cantor Normal Form with finite support is realizable as a tree rank.
2. **ω^ω Realization**: Construct a tree with rank ω^ω by iterating the omega-power construction.
3. **Extremal Symmetry Classification**: Prove that balanced binary trees are the *unique* maximizers of depth at each height.
4. **Ordinal Exponentiation on Trees**: Define a tree operation whose rank semantics is ordinal exponentiation.
5. **Automated Termination Analysis**: Use the phase diagram to build automated tools that classify the termination complexity of recursive programs.

---

## References

1. N. Dershowitz and Z. Manna. *Proving termination with multiset orderings.* Communications of the ACM, 22(8):465–476, 1979.

2. W. Buchholz. *An independence result for (Π¹₁-CA)+BI.* Annals of Pure and Applied Logic, 33:131–155, 1987.

3. M. Rathjen. *The realm of ordinal analysis.* In S.B. Cooper and J.K. Truss, eds., Sets and Proofs, Cambridge University Press, 1999.

4. E.A. Cichon and E. Tahhan Bittar. *Ordinal recursive bounds for Higman's theorem.* Theoretical Computer Science, 201(1-2):63–84, 1998.

5. G. Cantor. *Beiträge zur Begründung der transfiniten Mengenlehre.* Mathematische Annalen, 46:481–512, 1895.

---

## Appendix: Complete Theorem Statements

```
-- Exact finite-height collapse
theorem natDepth_le_two_pow_height (R : ResearchObject) :
    natDepth R ≤ 2 ^ height R

theorem balancedTree_height (n : ℕ) : height (balancedTree n) = n

theorem balancedTree_natDepth (n : ℕ) : natDepth (balancedTree n) = 2 ^ n

theorem natDepth_sup_eq_two_pow (n : ℕ) :
    (∃ R, height R = n ∧ natDepth R = 2 ^ n) ∧
    (∀ R, height R ≤ n → natDepth R ≤ 2 ^ n)

theorem researchDepth_le_two_pow_height (R : ResearchObject) :
    researchDepth R ≤ (2 ^ height R : ℕ)

-- Ordinal arithmetic on trees
theorem addByPattern_rank (pattern base : InfBranchTree) :
    (addByPattern pattern base).rank = base.rank + pattern.rank

theorem mulByPattern_rank (pattern : InfBranchTree) (k : ℕ) :
    (mulByPattern pattern k).rank = pattern.rank * (k : Ordinal)

-- Ordinal tower
theorem rank_omegaPowTree (n : ℕ) :
    (omegaPowTree n).rank = omega0 ^ (n : Ordinal)

theorem exists_tree_of_rank_eq_omega_pow (n : ℕ) :
    ∃ t : InfBranchTree, t.rank = omega0 ^ (n : Ordinal)
```
