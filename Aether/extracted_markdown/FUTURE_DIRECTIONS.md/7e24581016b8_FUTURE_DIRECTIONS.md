# Future Directions: Ordinal Collapse Theory

## Falsifiable Scientific Hypotheses

### Hypothesis 1: Completeness to ε₀

**Conjecture**: An enriched tree constructor with ordinal-indexed children realizes all ordinals below ε₀ = sup{ω, ω^ω, ω^(ω^ω), ...}, the proof-theoretic ordinal of Peano arithmetic.

**Test**: Define an iterated exponential tower:
```
omegaTowerTree : ℕ → InfBranchTree
omegaTowerTree 0 = omegaPowTree 1  -- ω
omegaTowerTree (n+1) = node (fun k => mulByNat (omegaTowerTree n) k)
```
Prove `rank(omegaTowerTree n)` equals the n-th iterated exponential tower ω↑↑n. Then define `epsilonZeroTree = node (fun n => omegaTowerTree n)` and prove `rank(epsilonZeroTree) = ε₀`.

**Likely obstruction**: The CNF representation must be generalized to *hereditary* Cantor normal form, where exponents are themselves ordinals in CNF. The bookkeeping for nested CNF terms and their tree realizations requires a mutual recursion between ordinal evaluation and tree construction that may not terminate in the current framework.

**Impact**: Would establish tree-theoretic semantics for the entire proof-theoretic hierarchy of first-order arithmetic, connecting ordinal collapse theory to Gentzen's consistency proof.

---

### Hypothesis 2: CNF Uniqueness / Normal-Form Injectivity

**Conjecture**: For strictly descending exponent lists with positive coefficients, `cnfValue L₁ = cnfValue L₂` implies `L₁ = L₂`. That is, the CNF evaluation function is injective on valid normal forms.

**Test**: First prove injectivity for single-term lists (`cnfValue [(a₁,n₁)] = cnfValue [(a₂,n₂)] → a₁ = a₂ ∧ n₁ = n₂`), then extend by induction on list length. The key step is showing that the leading term of a CNF determines the ordinal's Cantor normal form uniquely.

**Likely obstruction**: Requires either importing Mathlib's ordinal CNF theory (if available) or reconstructing the uniqueness proof from scratch. The main difficulty is showing that ω^n₁ · a₁ + β = ω^n₂ · a₂ + γ implies n₁ = n₂ and a₁ = a₂ when n₁ ≥ n₂ and the remainder terms have smaller leading exponents. This uses ordinal division, which may not be directly available.

**Impact**: Would upgrade the realizability theorem from a surjection (every CNF ordinal has a tree) to a bijection (the tree assignment is canonical), enabling certified ordinal comparison by tree structure.

---

### Hypothesis 3: Monotone Limit-Rank Synthesis Schema

**Conjecture**: For any monotone ℕ-indexed sequence of trees t₀, t₁, t₂, ... with rank(tₙ) < rank(tₙ₊₁), the tree `node(fun n => tₙ)` has rank exactly `sup_n rank(tₙ)`. That is, the node constructor with a monotone child sequence realizes the ordinal supremum.

**Test**: Verify for three specific families:
1. `tₙ = chain(n)`: rank(node ...) should equal ω. (Already proved as omegaTree.)
2. `tₙ = omegaPowTree(n)`: rank should equal ω^ω. (Already proved.)
3. `tₙ = cnfTree([(1, n), (n, 0)])`: rank should equal sup_n (ω^n + n).

The general proof would show:
```
sup_n succ(rank(tₙ)) = sup_n rank(tₙ)
```
whenever the sequence is cofinal below a limit ordinal.

**Likely obstruction**: The identity `sup_n succ(αₙ) = sup_n αₙ` holds when sup_n αₙ is a limit ordinal, but the proof requires showing that monotonicity of the original sequence implies the supremum is a limit (or handling the successor case separately). This is a standard ordinal fact but may require careful formalization.

**Impact**: Would provide a reusable schema for constructing trees with arbitrary limit ordinal ranks, reducing all future limit-stage proofs to verification of monotonicity and supremum computation.

---

### Hypothesis 4: Ordinal Rank as a Complete Invariant for Recursive Evaluation Traces

**Conjecture**: For a suitable class of recursive programs (e.g., primitive recursive functions with an ordinal termination measure below ω^ω), the tree rank of the evaluation trace equals the ordinal termination measure.

**Test**: Define a simple recursive evaluator:
```
def evalTrace : Program → Input → InfBranchTree
```
that records the tree of recursive calls made during evaluation. Prove that for programs with termination measure α ∈ CNF:
```
rank(evalTrace p x) ≤ α
```
and that equality is achieved for some worst-case input.

**Likely obstruction**: Defining a sufficiently general `Program` type and `evalTrace` function that is both meaningful and tractable for formalization. The trace tree must be well-founded by construction, which requires the program's termination to be proved as a precondition.

**Impact**: Would establish a formal bridge between ordinal analysis (a branch of mathematical logic) and program analysis (a branch of computer science), with trees as the mediating structure.

---

### Hypothesis 5: Collapse/Realizability Duality — Resource-Bounded Ordinal Spectra

**Conjecture**: The structural parameters controlling the finite branching collapse (`natDepth ≤ 2^height`) determine sharp bounds on which CNF ordinals are realizable by trees with bounded branching or bounded local complexity.

Specifically: a tree with branching bounded by b at each node and height bounded by h can realize ordinals up to exactly b^h (as a natural number), and conversely, realizing ordinal ω^n requires unbounded branching (already known) but also specific patterns of branching growth. The ordinal spectrum of a resource-bounded tree class is:
```
Spec(b, h) = {rank(t) : t has branching ≤ b, height ≤ h} = [0, b^h]
```
For unbounded branching with bounded height h:
```
Spec(∞, h) = [0, h] ⊂ ω
```
(by the universal collapse theorem).

**Test**: Prove the exact characterization `Spec(b, h) = [0, b^h]` for finitely branching trees, and then characterize the transition to transfinite spectra as branching and height constraints are relaxed. Show that `Spec(∞, ∞) ⊇ [0, ω^ω]` (the current result) and conjecture `Spec(∞, ∞) = Ord` (all ordinals are realizable).

**Likely obstruction**: The lower bound (constructing trees achieving specific ranks within resource bounds) requires careful combinatorial arguments. The upper bound for finite branching may require König's lemma or compactness arguments.

**Impact**: Would establish a complete classification of "which ordinals can be built with which resources," turning ordinal realizability into a resource-bounded complexity theory for transfinite structures.
