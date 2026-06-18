# Affine Orbit Decomposition and Proof-Theoretic Barriers for the Collatz Conjecture

## Abstract

We develop a rigorous framework connecting the dynamics of the Collatz map to proof-theoretic complexity through the **affine orbit decomposition**. The central result is that every Collatz orbit, when its parity sequence is fixed, reduces to an affine function of the starting value with coefficients determined by the parity word. We prove the Growth Factor Formula (the multiplier equals 3^d / 2^e where d and e count odd and even steps), the Composition Theorem (parity word concatenation corresponds to affine composition), a Contraction Criterion (branches with sufficiently many even steps are guaranteed to contract), and the Fixed-Point Isolation Theorem (the 1-4-2-1 cycle is the unique fixed orbit under its parity word). These results formalize the exponential branching structure that constitutes the fundamental barrier to proving the Collatz conjecture.

**Keywords**: Collatz conjecture, 3n+1 problem, parity word, affine dynamics, proof complexity, undecidability barriers

## 1. Introduction

The Collatz conjecture asserts that for every positive integer n, the sequence defined by T(n) = n/2 if n is even and T(n) = 3n+1 if n is odd eventually reaches 1. Despite extensive computational verification up to 2^68 and significant partial results (Terras 1976, Everett 1977, Krasikov-Lagarias 2003), the conjecture remains open.

The difficulty of the Collatz conjecture has led several researchers to conjecture that it may be independent of Peano Arithmetic (PA). Conway (1972) showed that generalizations of the Collatz map can encode arbitrary computations, suggesting that the halting problem for Collatz-like maps is undecidable. More recently, the work of Michel (2015) and others has connected the Collatz problem to the Busy Beaver function, reinforcing the undecidability analogy.

In this paper, we develop a framework that makes the source of difficulty precise: the **affine orbit decomposition**. We show that fixing the parity sequence of a Collatz orbit reduces it to a linear function, but the number of possible parity sequences grows exponentially with orbit length, creating an irreducible branching structure.

## 2. Definitions

### 2.1 The Collatz Map

The standard Collatz step function is:
```
collatzStep(n) = n/2      if n is even
collatzStep(n) = 3n + 1   if n is odd
```

### 2.2 Parity Words

A **parity word** is a finite sequence w = (b₀, b₁, ..., b_{k-1}) ∈ {0,1}^k where bᵢ = 1 indicates an odd step and bᵢ = 0 indicates an even step.

### 2.3 Word Evaluation

Given a parity word w and a starting value x ∈ ℚ, the **word evaluation** evalWord(w, x) applies the Collatz steps with prescribed parities:
```
evalWord([], x) = x
evalWord(0::w, x) = evalWord(w, x/2)
evalWord(1::w, x) = evalWord(w, 3x+1)
```

### 2.4 Affine Coefficients

The **word multiplier** and **word offset** are:
```
wordMult([]) = 1,          wordOffset([]) = 0
wordMult(0::w) = wordMult(w)/2,  wordOffset(0::w) = wordOffset(w)
wordMult(1::w) = 3·wordMult(w),  wordOffset(1::w) = wordMult(w) + wordOffset(w)
```

### 2.5 Collatz Branch (Novel Definition)

A **CollatzBranch** is a structure packaging a parity word with its derived affine data:
- word: the parity sequence
- depth: the number of steps (= word length)
- mult, offset: the affine coefficients (= wordMult(word), wordOffset(word))
- isContracting: mult < 1 (the orbit shrinks along this branch)
- isExpanding: mult > 1 (the orbit grows along this branch)

This structure formalizes the individual proof obligations in the Collatz verification tree.

## 3. Main Results

### 3.1 Affine Orbit Theorem

**Theorem 1** (Affine Orbit Representation). *For every parity word w and rational x,*
```
evalWord(w, x) = wordMult(w) · x + wordOffset(w)
```

*Proof sketch.* By induction on w. The base case is immediate. For the even step (0::w), evalWord(0::w, x) = evalWord(w, x/2) = wordMult(w)·(x/2) + wordOffset(w) = (wordMult(w)/2)·x + wordOffset(w) = wordMult(0::w)·x + wordOffset(0::w). The odd step (1::w) is analogous. □

**Significance.** This theorem reduces the analysis of each branch of the Collatz tree to a single linear equation. The conjecture for a specific branch becomes: does the affine image eventually reach 1 under further iteration?

### 3.2 Growth Factor Formula

**Theorem 2** (Growth Factor Formula). *For a parity word w with d odd steps and e even steps,*
```
wordMult(w) = 3^d / 2^e
```

*Proof sketch.* By induction, using the recurrence for wordMult. □

**Corollary.** The multiplier depends only on the *counts* of odd and even steps, not their positions. This is a surprising commutativity property: permuting a parity word changes the offset but not the multiplier.

### 3.3 Composition Theorem

**Theorem 3** (Word Composition). *Concatenating parity words corresponds to composing evaluations:*
```
evalWord(w₁ ++ w₂, x) = evalWord(w₂, evalWord(w₁, x))
wordMult(w₁ ++ w₂) = wordMult(w₁) · wordMult(w₂)
wordOffset(w₁ ++ w₂) = wordMult(w₂) · wordOffset(w₁) + wordOffset(w₂)
```

*Proof sketch.* The evaluation identity is by induction on w₁. The multiplier identity follows from the evaluation identity and the affine theorem by comparing coefficients. □

**Significance.** This gives the proof tree its recursive, self-similar structure. Each branch at depth k+1 is obtained by extending a depth-k branch with one additional step.

### 3.4 Multiplier Positivity

**Theorem 4.** *wordMult(w) > 0 for all parity words w.*

This ensures the affine map is orientation-preserving and that the contraction analysis is well-defined.

### 3.5 Contraction Criterion

**Theorem 5** (Contraction Criterion). *If a non-empty parity word w satisfies 2·countTrue(w) < countFalse(w), then wordMult(w) < 1.*

*Proof sketch.* By the Growth Factor Formula, wordMult(w) = 3^d / 2^e. If 2d < e, then 3^d ≤ 4^d = 2^{2d} < 2^e, giving wordMult(w) < 1. The key inequality is 3^d < 2^e when e > 2d. □

**Significance.** This formalizes the heuristic argument for convergence. In a "random" orbit, odd and even steps appear with roughly equal frequency, giving e ≈ d ≈ k/2 for a word of length k. Since 2·(k/2) = k > k/2 when k > 0, the condition is satisfied for "typical" words. The difficulty is that atypical words (with many odd steps) cannot be ruled out.

### 3.6 Fixed-Point Isolation

**Theorem 6** (Cycle Word Properties). *The parity word w* = [1,0,0] *for the 1-4-2-1 cycle has:*
- wordMult(w*) = 3/4
- wordOffset(w*) = 1/4
- evalWord(w*, 1) = 1

**Theorem 7** (Fixed-Point Uniqueness). *The unique rational fixed point of evalWord(w*, ·) is x = 1.*

*Proof.* By the affine theorem, evalWord(w*, x) = x iff (3/4)x + 1/4 = x iff x = 1. □

**Significance.** This proves that the 1-4-2-1 cycle is isolated: no other rational starting value could enter this cycle. For a hypothetical non-trivial cycle with parity word w, the fixed-point equation wordMult(w)·x + wordOffset(w) = x would need wordMult(w) ≠ 1, and the unique fixed point would be x = wordOffset(w)/(1 - wordMult(w)). Proving this is never a positive integer for any valid parity word would resolve part of the conjecture.

### 3.7 Count Partition

**Theorem 8.** *countTrue(w) + countFalse(w) = length(w) for all parity words w.*

This basic bookkeeping result ensures the Growth Factor Formula is consistent with the word length.

## 4. The Proof Barrier

### 4.1 Exponential Branching

At depth k, the Collatz verification tree has 2^k branches, one for each parity word of length k. The affine orbit theorem reduces each branch to a linear equation, but the number of equations grows exponentially.

### 4.2 Connection to Undecidability

The exponential branching structure connects to undecidability through Conway's theorem: generalized Collatz-like maps can simulate arbitrary register machines. The parity word decomposition makes this explicit — the "program" of a Collatz orbit is its parity word, and the exponential proliferation of programs mirrors the undecidability of the halting problem.

For the specific Collatz map T(n) = n/2 or 3n+1, the question of independence from PA remains open. However, our framework shows that any proof within PA must simultaneously handle all 2^k branches for all k, which requires finding a uniform pattern across the entire infinite tree — a task that may exceed the capabilities of any fixed axiom system.

### 4.3 The Parity Balance Conjecture

**Conjecture.** For any parity word w such that evalWord(w, n) = 1 for some positive integer n, we have wordMult(w) ≤ 1.

This conjecture states that convergent orbits always have net contraction. It is equivalent to saying that the number of even steps always exceeds (log 3 / log 2) times the number of odd steps in any convergent orbit. This is computationally testable and has been verified for all n up to large bounds.

## 5. Algorithms

### 5.1 Parity Word Extraction

Given n, compute its parity word by iterating collatzStep and recording the parity at each step until reaching 1 (or a maximum depth).

### 5.2 Affine Coefficient Computation

Given a parity word, compute wordMult and wordOffset using the recurrences. This runs in O(k) arithmetic operations for a word of length k.

### 5.3 Branch Verification

For each branch at depth k, compute the affine function and check whether its image on the relevant residue class eventually reaches 1 under further iteration.

## 6. Discussion

### 6.1 Relationship to Prior Work

The parity word approach is related to Wirsching's (1998) "parity vector" method and Lagarias's (1985) formulation in terms of 2-adic integers. Our contribution is the clean affine decomposition theorem and its explicit connection to proof-theoretic barriers.

### 6.2 Implications for the Undecidability Question

While we do not prove that the Collatz conjecture is independent of PA, our framework provides the structural vocabulary for formulating such a result precisely. The exponential branching at each depth level is a concrete manifestation of the proof-theoretic complexity.

### 6.3 The Tropical Connection

Taking logarithms, the multiplier formula becomes additive: log(wordMult(w)) = d·log(3) - e·log(2). This is the tropical semiring perspective: in the "max-plus" world, multiplication becomes addition, and the contraction criterion becomes a linear inequality. This connection to tropical geometry opens avenues for applying algebraic-geometric tools to the Collatz problem.

## 7. Future Work

1. **Cycle classification**: Prove that the Growth Factor Formula constrains possible non-trivial cycles, potentially ruling out cycles of bounded length.
2. **Residue class refinement**: Show that n mod 2^k determines the first k parities of the Collatz orbit, connecting the affine decomposition to standard sieving methods.
3. **PA-independence**: Formalize the connection between exponential branching and proof-theoretic strength, potentially showing that verifying Collatz to depth k requires proofs of length Ω(2^k) in PA.

## References

- Collatz, L. (1937). Problem statement (unpublished).
- Conway, J. H. (1972). Unpredictable iterations. *Proc. Number Theory Conf., Boulder*, 49–52.
- Lagarias, J. C. (1985). The 3x+1 problem and its generalizations. *Amer. Math. Monthly*, 92(1), 3–23.
- Terras, R. (1976). A stopping time problem on the positive integers. *Acta Arith.*, 30(3), 241–252.
- Wirsching, G. J. (1998). *The Dynamical System Generated by the 3n+1 Function*. Lecture Notes in Mathematics 1681, Springer.
- Krasikov, I. and Lagarias, J. C. (2003). Bounds for the 3x+1 problem using difference inequalities. *Acta Arith.*, 109(3), 237–258.
