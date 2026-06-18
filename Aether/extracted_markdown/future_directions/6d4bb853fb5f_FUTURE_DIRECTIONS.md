# Future Directions: Ordinal Collapse Theory

## Status of Current Results

The following theorems have been formally verified (all sorry-free, standard axioms only):

### Exact Finite-Height Collapse
- **natDepth_le_two_pow_height**: `natDepth(R) ≤ 2^height(R)` for all research objects.
- **balancedTree_height/natDepth**: Balanced trees achieve `height = n`, `natDepth = 2^n`.
- **natDepth_sup_eq_two_pow**: Combined extremal law — 2^n is both achievable and maximal.
- **researchDepth_le_two_pow_height**: Ordinal version via bridge theorem.

### Ordinal Arithmetic on Trees
- **addByPattern_rank**: `rank(addByPattern(s, t)) = rank(t) + rank(s)` (ordinal addition).
- **mulByPattern_rank**: `rank(mulByPattern(s, k)) = rank(s) · k` (ordinal multiplication).

### Ordinal Tower Realization
- **rank_omegaPowTree**: `rank(omegaPowTree(n)) = ω^n` for all n ∈ ℕ.
- **exists_tree_of_rank_eq_omega_pow**: Every ω^n is constructively realized.
- **exists_tree_of_rank_eq_omega_sq**: Concrete milestone — ω² exists.

### Previously Verified (Catalog)
- Finite Branching Collapse, Bridge Theorem, Height Stratification, Spectrum Sharpness,
  Universal Collapse, Transfinite Escape, Affine Growth, Strict Monotonicity.

---

## Hypothesis 1: Cantor Normal Form Realizability

**Conjecture.** Every ordinal below ω^ω that can be expressed in Cantor Normal Form with finite coefficients is realizable as the rank of an InfBranchTree. Specifically, for every list `[(a₁,n₁), ..., (aₖ,nₖ)]` with `n₁ > n₂ > ... > nₖ` and `aᵢ ∈ ℕ⁺`, there exists a tree with rank `a₁·ω^n₁ + a₂·ω^n₂ + ... + aₖ·ω^nₖ`.

**Test.** Define:
```
def cnfTree : List (ℕ × ℕ) → InfBranchTree
  | [] => .leaf
  | (a, n) :: rest => addByPattern (mulByPattern (omegaPowTree n) a) (cnfTree rest)
```
Verify `rank(cnfTree L)` equals the CNF value for all lists with coefficients/exponents ≤ 3. This reduces to proving that addByPattern composes correctly with mulByPattern and that the descending exponent order ensures no ordinal "collisions."

**Obstruction.** Ordinal addition is not commutative: `ω + 1 ≠ 1 + ω`. The addByPattern operation computes `rank(base) + rank(pattern)`, with the base on the left. The order of stacking in cnfTree must match the standard CNF convention (largest terms first). A subtle mismatch in stacking order would produce the wrong ordinal.

**Impact if true.** This would establish InfBranchTrees as a *complete constructive notation system* for ordinals below ω^ω, connecting directly to proof-theoretic ordinal notation systems and enabling automated ordinal reasoning.

---

## Hypothesis 2: Omega-to-the-Omega Realization

**Conjecture.** There exists an InfBranchTree with rank exactly ω^ω. Specifically:
```
def omegaToOmegaTree : InfBranchTree :=
  .node (fun n => omegaPowTree n)
```
has `rank(omegaToOmegaTree) = ω^ω`.

**Test.** Prove:
```
theorem rank_omegaToOmega : omegaToOmegaTree.rank = omega0 ^ omega0
```
The lower bound should follow from `le_ciSup` and `rank_omegaPowTree`. The upper bound requires showing that `sup_n (ω^n + 1) = ω^ω`, which needs the cofinality of ω^ω being ω.

**Obstruction.** The upper bound requires `∀ α < ω^ω, ∃ n, α < ω^n + 1`. This follows from the definition of ω^ω = sup_n ω^n, but the formal proof needs careful ordinal arithmetic (specifically that ω^ω is a limit and the sequence ω^n is cofinal). The Mathlib API for `Ordinal.opow` with limit exponents may require navigation.

**Impact if true.** This would cross the boundary from "ordinal ladder" to "ordinal limit point," reaching the proof-theoretic ordinal of Primitive Recursive Arithmetic. It would demonstrate that the omegaPowTree construction naturally extends beyond individual ω^n values.

---

## Hypothesis 3: Extremal Symmetry Uniqueness

**Conjecture.** Among all research objects of height exactly n, the balanced binary tree is the *unique* maximizer of natDepth, up to relabeling of atoms. That is: if `height(R) = n` and `natDepth(R) = 2^n`, then R is structurally isomorphic to `balancedTree(n)`.

**Test.** Define structural isomorphism:
```
def structIso : ResearchObject → ResearchObject → Prop
  | .atom _, .atom _ => True
  | .compose A B, .compose A' B' => structIso A A' ∧ structIso B B'
  | .bootstrap A, .bootstrap A' => structIso A A'
  | .oracleNode n f, .oracleNode n' f' => n = n' ∧ ∀ i, structIso (f i) (f' (i.cast ...))
  | _, _ => False
```
Prove:
```
theorem balanced_unique_maximizer (R : ResearchObject) (h : height R = n) (d : natDepth R = 2^n) :
    structIso R (balancedTree n)
```

**Obstruction.** Oracle nodes of arity 1 with a single child can mimic bootstrap (both add 1 to depth). An oracle node `oracleNode 1 (fun _ => A)` has `natDepth = natDepth(A) + 1` and `height = height(A) + 1`, just like `bootstrap(A)`. So the "balanced" maximizer might not be unique — there could be alternative maximizers using oracle nodes instead of compose/bootstrap.

The likely resolution: restrict to objects using only compose and atom (the "pure composition" fragment). In this fragment, balanced binary trees should be provably unique maximizers.

**Impact if true.** Would establish a strong universality principle: the most complex finite structure at any height is necessarily the most symmetric one. This connects to circuit complexity lower bounds and information-theoretic optimality.

---

## Hypothesis 4: Collapse Threshold Classification

**Conjecture.** The achievable ranks of InfBranchTrees are exactly:
- Under the "d-layer countable branching grammar" (omegaPowTree iterated d times): exactly the ordinals < ω^d.
- Under the full InfBranchTree type: exactly all countable ordinals (ordinals < ω₁).

More precisely: for every countable ordinal α, there exists an InfBranchTree with rank α.

**Test.** For the first claim, prove:
```
theorem achievable_ranks_below_omega_pow (d : ℕ) (α : Ordinal) (hα : α < omega0 ^ d) :
    ∃ t : InfBranchTree, t.rank = α
```
For the second, prove realizability for specific ordinals: ω+1, ω·2, ω²+ω+1, etc.

**Obstruction.** For general countable ordinals, the construction requires transfinite recursion on the target ordinal, building the tree by cases on whether α is 0, a successor, or a limit. For successor ordinals, `addRank t 1` suffices. For limit ordinals, a cofinal ω-sequence must be constructively extracted. The main difficulty is that not every limit ordinal has a canonical ω-cofinal sequence — one must use the axiom of choice or a canonical enumeration.

**Impact if true.** Would establish InfBranchTrees as a universal model for countable ordinal ranks, analogous to how Turing machines are universal for computation. This would have applications in descriptive set theory (Borel hierarchy levels correspond to tree ranks) and automata theory (acceptance conditions classified by ordinal rank).

---

## Hypothesis 5: Ordinal Exponentiation as Tree Operation

**Conjecture.** There exists a tree operation `expTree : InfBranchTree → InfBranchTree → InfBranchTree` satisfying:
```
rank(expTree s t) = rank(s) ^ rank(t)
```
for all trees s, t (where ^ denotes ordinal exponentiation).

**Test.** A candidate definition:
```
def expTree (base : InfBranchTree) : InfBranchTree → InfBranchTree
  | .leaf => chain 1  -- rank(base)^0 = 1
  | .node f => .node (fun i => mulByPattern (expTree base (f i)) ???)
```
The difficulty is in the recursive case: ordinal exponentiation `α^(sup β_i)` involves limits of products, which don't decompose as simply as sums.

Verify for small cases:
- `expTree (chain 2) (chain 3)` should have rank 8 = 2^3.
- `expTree omegaTree (chain 2)` should have rank ω^2 = ω².
- `expTree omegaTree omegaTree` should have rank ω^ω.

**Obstruction.** Ordinal exponentiation α^β is defined by transfinite recursion on β:
- α^0 = 1
- α^(β+1) = α^β · α
- α^λ = sup_{β<λ} α^β for limit λ

The successor case uses multiplication (which we have), but the limit case requires taking suprema over tree-indexed families, which creates a circular dependence: we need the tree structure of the exponent to guide the construction, but the exponent *is* a tree.

A possible resolution: define `expTree base exponent` by structural recursion on the exponent tree, using mulByPattern for successor steps and direct node construction for limit steps. This mirrors the ordinal definition if we can show that `node(f)` acts as a limit.

**Impact if true.** Would complete the ordinal arithmetic trilogy (addition, multiplication, exponentiation) on trees. Combined with CNF realizability, this would give a fully constructive ordinal calculator up to ε₀, with direct applications to proof-theoretic ordinal analysis and automated termination proving.

---

## Priority Ordering

1. **Hypothesis 2** (ω^ω realization) — Highest priority. Likely provable with current tools. Would be a clean extension of rank_omegaPowTree.

2. **Hypothesis 1** (CNF realizability) — High priority. Requires proving addByPattern composes correctly with descending CNF terms. Foundation for all further ordinal arithmetic.

3. **Hypothesis 4** (collapse threshold) — Medium priority. The "every countable ordinal" direction is ambitious but would be transformative.

4. **Hypothesis 3** (extremal uniqueness) — Medium priority. Conceptually clean but technically fiddly due to oracle node alternatives.

5. **Hypothesis 5** (ordinal exponentiation) — Lower priority but highest reward. Difficult due to the limit case of exponentiation.
