# Tropical Descriptive Complexity: Formula Evaluation over Annotated Words is Tropically Recognizable

## Abstract

We establish a tropical (min-plus) analogue of the classical Büchi–Elgot–Trakhtenbrot correspondence between logical definability and automata recognizability. Specifically, we define a syntax of quantitative tropical formulas over annotated words—words enriched with boolean annotations for free variables—and prove that every such formula evaluates to a tropically recognizable series. The proof proceeds by structural induction on formulas, with each constructor (constants, per-position costs, existential and universal position predicates, minimum, and summation) corresponding to an explicit tropical automaton construction. The main theorem is fully formalized and machine-verified. We provide algorithms for formula-to-automaton compilation with explicit state complexity bounds, and demonstrate applications to quantitative model checking, sequence analysis, and constrained optimization.

**Keywords:** tropical semiring, min-plus automata, weighted automata, descriptive complexity, annotated words, free variables, recognizable series, structural induction

## 1. Introduction

### 1.1 Background

The classical theorem of Büchi [1], Elgot [2], and Trakhtenbrot [3] establishes a fundamental correspondence between monadic second-order (MSO) logic and finite automata over finite words: a language is MSO-definable if and only if it is regular (recognizable by a finite automaton). This result is a cornerstone of automata theory and has far-reaching applications in verification, database theory, and computational logic.

A central technique in the proof is the *annotation method*: free variables in a formula are encoded as additional boolean tracks in an extended alphabet. A word over the base alphabet σ with an assignment of variables to positions is represented as a word over the annotated alphabet σ × {0,1}^k, where k is the number of free variables. This encoding reduces formulas with free variables to sentences over a larger alphabet.

In parallel, the theory of *weighted automata* extends classical automata to semiring-valued computations [4, 5]. A weighted automaton over a semiring (S, ⊕, ⊗) assigns to each word a value computed as the ⊕-sum (over all runs) of the ⊗-product (over all transitions) of weights. When the semiring is the *tropical semiring* (ℝ≥0∞, min, +), the automaton computes the minimum-cost accepting path—the fundamental operation in shortest-path algorithms, dynamic programming, and optimization.

### 1.2 Contribution

We bridge these two theories by proving that every quantitative formula in a natural tropical formula syntax, when evaluated on annotated words, yields a tropically recognizable series. Our contributions are:

1. **Formal definitions** of annotated symbols, tropical weighted automata, tropical formulas, and tropical recognizability (Section 2).
2. **Explicit automaton constructions** for each formula constructor: constants (1 state), letter costs (1 state), existential predicates (2 states), universal predicates (1 state), minimum (disjoint union), and addition (Cartesian product) (Section 3).
3. **Main theorem** (Theorem 1): every tropical formula evaluates to a tropically recognizable function, proved by structural induction (Section 4).
4. **Complete machine verification** of the theorem and all supporting lemmas using an interactive proof assistant (Section 5).
5. **Algorithms** for formula-to-automaton compilation with complexity analysis (Section 6).
6. **Applications** to quantitative monitoring, sequence analysis, and constrained routing (Section 7).

### 1.3 Related Work

The theory of weighted automata over semirings is surveyed in [4]. Droste and Gastin [6] established weighted MSO logic over arbitrary semirings, giving a Büchi-like characterization of recognizable formal power series. Our work differs in focusing specifically on the tropical semiring and providing machine-verified proofs with explicit automaton constructions.

The annotation method for encoding free variables originates in the classical Büchi–Elgot–Trakhtenbrot proof and is standard in automata-theoretic model checking [7].

Tropical mathematics has connections to algebraic geometry [8], phylogenetics [9], and neural networks [10]. Our work provides new connections to descriptive complexity and formal verification.

## 2. Definitions and Notation

### 2.1 Annotated Symbols

**Definition 1** (Annotated Symbol). Given a base alphabet σ and a set of variables Var, an *annotated symbol* is a pair (a, ann) where a ∈ σ and ann : Var → Bool. The annotated alphabet is Σ = σ × Bool^Var.

An *annotated word* w = (a₁, ann₁) ··· (aₙ, annₙ) ∈ Σ* encodes both a base word a₁···aₙ and, for each variable v ∈ Var, the set of positions {i : annᵢ(v) = true} where v is "active."

**Definition 2** (Decoded Structure). The *decoding* of an annotated word w extracts:
- baseWord(w) = a₁···aₙ, the underlying word
- varPositions(w, v) = {i : annᵢ(v) = true}, the positions of variable v

### 2.2 Tropical Weighted Automaton

**Definition 3** (Tropical Automaton). A *tropical weighted automaton* over alphabet α is a tuple A = (S, init, δ, final) where:
- S is a finite set of states
- init : S → ℝ≥0∞ assigns initial costs
- δ : S × α × S → ℝ≥0∞ assigns transition costs
- final : S → ℝ≥0∞ assigns terminal costs

The *run cost* from state q on word w is defined recursively:
```
runCost(A, [], q)    = final(q)
runCost(A, a·w, q)   = inf_{q' ∈ S} (δ(q, a, q') + runCost(A, w, q'))
```

The *evaluation* of A on word w is:
```
eval(A, w) = inf_{q ∈ S} (init(q) + runCost(A, w, q))
```

This computes the minimum-cost path through the automaton.

**Definition 4** (Tropical Recognizability). A function f : α* → ℝ≥0∞ is *tropically recognizable* if there exists a tropical automaton A such that eval(A, w) = f(w) for all w ∈ α*.

### 2.3 Tropical Formulas

**Definition 5** (Tropical Formula). The set of *tropical formulas* over alphabet α is defined inductively:

| Constructor | Notation | Semantics |
|---|---|---|
| const c | c | eval(const c, w) = c |
| letterCost f | Σf | eval(Σf, w) = Σᵢ f(wᵢ) |
| existsPos p | ∃p | eval(∃p, w) = 0 if ∃i: p(wᵢ), else ⊤ |
| forallPos p | ∀p | eval(∀p, w) = 0 if ∀i: p(wᵢ), else ⊤ |
| tmin φ ψ | φ ⊓ ψ | eval(φ ⊓ ψ, w) = min(eval(φ,w), eval(ψ,w)) |
| tplus φ ψ | φ ⊕ ψ | eval(φ ⊕ ψ, w) = eval(φ,w) + eval(ψ,w) |

Here ⊤ = +∞ represents infeasibility, and ⊤ + x = ⊤ for all x.

## 3. Automaton Constructions

### 3.1 Constant Automaton

**Construction.** For constant c ∈ ℝ≥0∞:
- States: S = {q₀} (singleton)
- init(q₀) = c, δ(q₀, a, q₀) = 0, final(q₀) = 0

**Lemma 1.** runCost(constAut(c), w, q₀) = 0 for all w.

*Proof.* By induction on w. Base: final(q₀) = 0. Step: inf_{q'} (0 + runCost(w, q')) = runCost(w, q₀) = 0 by IH. □

**Corollary.** eval(constAut(c), w) = c + 0 = c for all w.

### 3.2 Letter-Cost Automaton

**Construction.** For f : α → ℝ≥0∞:
- States: S = {q₀}
- init(q₀) = 0, δ(q₀, a, q₀) = f(a), final(q₀) = 0

**Lemma 2.** runCost(letterCostAut(f), w, q₀) = Σᵢ f(wᵢ).

*Proof.* Induction on w. Base: 0 = Σ∅. Step: f(a) + Σᵢ f(wᵢ) = Σᵢ f((a·w)ᵢ). □

### 3.3 Existential Automaton

**Construction.** For predicate p : α → Bool:
- States: S = {0, 1} (Bool), where 0 = "not seen", 1 = "seen"
- init(0) = 0, init(1) = ⊤
- δ(0, a, 0) = 0, δ(0, a, 1) = (if p(a) then 0 else ⊤)
- δ(1, a, 1) = 0, δ(1, a, 0) = ⊤
- final(0) = ⊤, final(1) = 0

**Lemma 3.** runCost(existsAut(p), w, true) = 0 for all w.

*Proof.* Induction on w. The only finite-cost transition from state 1 goes to state 1. □

**Lemma 4.** runCost(existsAut(p), w, false) = (if w.any(p) then 0 else ⊤).

*Proof.* Induction on w. Base: final(false) = ⊤ = (if [].any(p) then 0 else ⊤). Step: runCost(a·w, false) = min(0 + runCost(w, false), (if p(a) then 0 else ⊤) + 0). If p(a): min(runCost(w,false), 0) = 0. If ¬p(a): min(runCost(w,false), ⊤) = runCost(w,false) = (if w.any(p) then 0 else ⊤) by IH. □

**Lemma 5.** eval(existsAut(p), w) = (if w.any(p) then 0 else ⊤).

*Proof.* eval = inf_b (init(b) + runCost(w,b)) = min(0 + runCost(w,false), ⊤ + 0) = runCost(w,false). □

### 3.4 Universal Formula Reduction

**Lemma 6.** (if w.all(p) then 0 else ⊤) = Σᵢ (if p(wᵢ) then 0 else ⊤).

*Proof.* If all p(wᵢ): sum of zeros = 0. If some ¬p(wᵢ): sum includes ⊤, so sum = ⊤. □

Hence forallPos(p) is semantically equivalent to letterCost(λa. if p(a) then 0 else ⊤), and recognizability follows from §3.2.

### 3.5 Disjoint Union (Minimum)

**Construction.** Given A₁ = (S₁, ...) and A₂ = (S₂, ...):
- States: S = S₁ ⊔ S₂
- Block-diagonal structure: no cross-component transitions (cost ⊤)

**Lemma 7.** runCost(minAut(A₁,A₂), w, inl(q)) = runCost(A₁, w, q).

*Proof.* Induction on w, using the fact that transitions from inl(q) to inr(q') cost ⊤. The iInf over S₁ ⊕ S₂ decomposes by iInf_sum into inf over S₁ ⊓ inf over S₂, with the S₂ component being ⊤. □

**Lemma 8.** eval(minAut(A₁,A₂), w) = min(eval(A₁,w), eval(A₂,w)).

*Proof.* By iInf_sum: inf over S₁⊔S₂ = (inf over S₁) ⊓ (inf over S₂). □

### 3.6 Product Automaton (Addition)

**Construction.** Given A₁ = (S₁, ...) and A₂ = (S₂, ...):
- States: S = S₁ × S₂
- init(q₁,q₂) = init₁(q₁) + init₂(q₂)
- δ((q₁,q₂), a, (q₁',q₂')) = δ₁(q₁,a,q₁') + δ₂(q₂,a,q₂')
- final(q₁,q₂) = final₁(q₁) + final₂(q₂)

**Lemma 9.** runCost(addAut(A₁,A₂), w, (q₁,q₂)) = runCost(A₁,w,q₁) + runCost(A₂,w,q₂).

*Proof.* Induction on w. Base: immediate. Step: by IH, the inner runCost decomposes, and then:

inf_{(q₁',q₂')} (δ₁(q₁,a,q₁') + δ₂(q₂,a,q₂') + runCost₁(w,q₁') + runCost₂(w,q₂'))
= inf_{(q₁',q₂')} ((δ₁(q₁,a,q₁') + runCost₁(w,q₁')) + (δ₂(q₂,a,q₂') + runCost₂(w,q₂')))

The key algebraic lemma (Lemma 10) then decomposes this into the sum of component infima. □

**Lemma 10** (Product Infimum Decomposition). For f : ι₁ → ℝ≥0∞ and g : ι₂ → ℝ≥0∞ with ι₁, ι₂ finite:

inf_{(i,j) ∈ ι₁×ι₂} (f(i) + g(j)) = (inf_i f(i)) + (inf_j g(j))

*Proof.* The ≥ direction: for all (i,j), f(i) + g(j) ≥ inf f + inf g. The ≤ direction: (inf f) + (inf g) = inf_i (f(i) + inf g) = inf_i inf_j (f(i) + g(j)) = inf_{(i,j)} (f(i) + g(j)), using ENNReal.add_iInf and iInf_prod. □

**Lemma 11.** eval(addAut(A₁,A₂), w) = eval(A₁,w) + eval(A₂,w).

*Proof.* Expand eval, apply Lemma 9, rearrange by commutativity/associativity of addition, then apply Lemma 10. □

## 4. Main Theorem

**Theorem 1** (Formula Evaluation is Tropically Recognizable). For every tropical formula φ over alphabet α, the function w ↦ eval(φ, w) is tropically recognizable.

*Proof.* By structural induction on φ:
- **const c**: By Corollary of Lemma 1 and the constant automaton.
- **letterCost f**: By Lemma 2 and the letter-cost automaton.
- **existsPos p**: By Lemma 5 and the existential automaton.
- **forallPos p**: By Lemma 6 (reduction to letterCost) and Lemma 2.
- **tmin φ ψ**: By IH, φ and ψ are recognizable. By Lemma 8, min is recognizable.
- **tplus φ ψ**: By IH, φ and ψ are recognizable. By Lemma 11, sum is recognizable. □

**Corollary 1** (Annotated Words). For every formula φ with free variables from Var over base alphabet σ, the function
```
w ↦ eval(φ, w)   for w ∈ (σ × Bool^Var)*
```
is tropically recognizable.

*Proof.* Instantiate Theorem 1 with α = AnnotatedSymbol(σ, Var). □

### 4.1 State Complexity

From the proof, we extract explicit state bounds:

| Formula | States |
|---|---|
| const c | 1 |
| letterCost f | 1 |
| existsPos p | 2 |
| forallPos p | 1 |
| φ ⊓ ψ | |S_φ| + |S_ψ| |
| φ ⊕ ψ | |S_φ| · |S_ψ| |

For a formula of depth d with n leaves:
- Under pure min: O(n) states (linear in formula size)
- Under pure plus: O(2^n) states (exponential)
- Mixed: intermediate, depending on the tree structure

## 5. Machine Verification

The entire theorem—including all definitions, lemma statements, and proofs—is formalized and verified. The formalization comprises approximately 300 lines of code with zero unproven assumptions.

The key technical challenges in the formalization were:
1. Defining tropical automata with existentially quantified finite state types
2. Proving the product infimum decomposition (Lemma 10) using properties of ENNReal
3. Handling the iInf over sum types (Lemma 7) using the iInf_sum lemma

The axioms used are only the standard foundational axioms (propext, Classical.choice, Quot.sound).

## 6. Algorithms

### 6.1 Formula-to-Automaton Compilation

```
Algorithm: COMPILE(φ, Σ)
Input: Tropical formula φ, alphabet Σ
Output: Tropical automaton A with eval(A, ·) = eval(φ, ·)

match φ with
| const c     → return ConstAut(c)          // 1 state
| letterCost f → return LetterCostAut(f)    // 1 state
| existsPos p → return ExistsAut(p)         // 2 states
| forallPos p → return LetterCostAut(λa. if p(a) then 0 else ⊤)  // 1 state
| tmin φ ψ   → return DisjointUnion(COMPILE(φ), COMPILE(ψ))     // |S₁|+|S₂|
| tplus φ ψ  → return Product(COMPILE(φ), COMPILE(ψ))           // |S₁|·|S₂|
```

**Time complexity of compilation:** O(|φ| · |Σ| · N²) where N is the resulting state count.

**Time complexity of evaluation:** O(|w| · N²) per word w, using the Viterbi-style DP algorithm.

### 6.2 Matrix Semantics

The automaton evaluation can be expressed as a tropical matrix product:

eval(A, a₁···aₙ) = init^T ⊗ M(a₁) ⊗ ··· ⊗ M(aₙ) ⊗ final

where M(a)_{q,q'} = δ(q, a, q') is the N×N transition matrix for symbol a, and ⊗ denotes tropical matrix multiplication: (A⊗B)_{ij} = min_k (A_{ik} + B_{kj}).

This gives an alternative O(|w| · N³) evaluation algorithm via matrix chain multiplication, which can be improved to O(|w| · N^ω) using fast tropical matrix multiplication (where ω is the matrix multiplication exponent).

## 7. Applications

### 7.1 Quantitative Model Checking

Given a system trace as a word over an event alphabet and a quantitative specification as a tropical formula, the compiled automaton serves as a *weighted monitor* that computes the specification cost by reading the trace left-to-right. This extends classical runtime verification to quantitative settings.

**Example.** Specification: "the total latency is minimized, subject to the constraint that a firewall is traversed." Formula: letterCost(latency) ⊕ existsPos(is_firewall). Compiled automaton: 2 states, linear-time evaluation.

### 7.2 Sequence Analysis

Annotated words model biological sequences with marked features (binding sites, motifs, modifications). Tropical formulas express cost functions like:
- "GC content" = letterCost(λs. if s ∈ {G,C} then 1 else 0)
- "binding site exists" = existsPos(is_binding)
- "minimum cost: GC content vs binding existence" = tmin of the above

### 7.3 Constrained Routing

Network paths are words over edge alphabets. Annotations encode route constraints (firewall requirements, security levels). Tropical formulas express constrained shortest-path costs, compiled to automata for efficient evaluation.

## 8. Discussion

### 8.1 Relationship to Weighted MSO

Droste and Gastin [6] established a general weighted MSO/automata correspondence over arbitrary semirings. Our theorem can be viewed as a self-contained tropical instance of their framework, with three distinguishing features:
1. **Machine verification**: our proofs are fully formalized
2. **Explicit constructions**: we provide concrete automata for each constructor
3. **Annotation mechanism**: we make the free-variable encoding explicit

### 8.2 Limitations

Our current formula syntax does not include:
- **Position quantification**: ∃i. φ(i) where φ depends on position i (requires projection)
- **Successor/order predicates**: i < j, succ(i) = j
- **Weighted quantifiers**: inf_i φ(i) over positions (the deepest projection lemma)

Adding these would require the technically challenging *projection* construction for tropical automata, which involves taking infima over fibers of an alphabet projection. This is the natural next step.

### 8.3 State Complexity Lower Bounds

The exponential blowup under addition (product construction) raises the question: is this necessary? For the boolean analogue, exponential blowups are known to be unavoidable for certain formulas (via communication complexity arguments). We conjecture similar lower bounds hold in the tropical case.

## 9. Future Work

1. **Full tropical Büchi–Elgot–Trakhtenbrot theorem**: characterize exactly which recognizable series are definable by tropical formulas, establishing a converse to Theorem 1.
2. **Projection and weighted quantifiers**: extend the formula syntax with existential quantification over positions and prove closure of tropical recognizability under projection.
3. **Automaton minimization**: develop a tropical Myhill-Nerode theory for the compiled automata, yielding unique minimal automata.
4. **Thermodynamic lifting**: define finite-temperature semantics via log-sum-exp and show that the tropical automaton arises as the zero-temperature limit.
5. **Complexity lower bounds**: prove exponential state lower bounds for specific formula families.

## References

[1] J.R. Büchi. "Weak second-order arithmetic and finite automata." Zeitschrift für mathematische Logik und Grundlagen der Mathematik 6 (1960): 66–92.

[2] C.C. Elgot. "Decision problems of finite automata design and related arithmetics." Transactions of the American Mathematical Society 98 (1961): 21–51.

[3] B.A. Trakhtenbrot. "Finite automata and the logic of one-place predicates." Siberian Mathematical Journal 3 (1962): 103–131.

[4] M. Droste, W. Kuich, H. Vogler (eds.). "Handbook of Weighted Automata." Springer, 2009.

[5] J. Sakarovitch. "Elements of Automata Theory." Cambridge University Press, 2009.

[6] M. Droste, P. Gastin. "Weighted automata and weighted logics." Theoretical Computer Science 380 (2007): 69–86.

[7] W. Thomas. "Languages, automata, and logic." In Handbook of Formal Languages, Vol. 3, Springer, 1997.

[8] D. Maclagan, B. Sturmfels. "Introduction to Tropical Geometry." American Mathematical Society, 2015.

[9] L. Pachter, B. Sturmfels. "Tropical geometry of statistical models." PNAS 101 (2004): 16132–16137.

[10] P. Zhang, M. Naitzat, L.P. Lim. "Tropical geometry of deep neural networks." ICML 2018.
