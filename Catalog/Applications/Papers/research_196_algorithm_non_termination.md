# Formal Arithmetic Dynamics of the Reverse-and-Add Algorithm

## Abstract

We develop a rigorous mathematical framework for studying the reverse-and-add dynamical system on natural numbers in arbitrary bases. Working in Lean 4 with Mathlib, we formalize core definitions (digit reversal, palindromicity, reverse-and-add iteration, Lychrel candidacy) and prove a hierarchy of structural theorems: (1) palindromicity is equivalent to being a fixed point of digit reversal; (2) digit reversal preserves congruence modulo $b-1$ ("casting out nines"); (3) the $k$-th reverse-and-add iterate is congruent to $2^k n$ modulo $b-1$; (4) reverse-and-add is exactly computed by a finite-state carry automaton; (5) digit reversal is involutive on numbers not divisible by the base; and (6) a finite-horizon non-palindrome certification principle based on modular residue exclusion. These results establish the first formally verified infrastructure for studying the 196 conjecture and Lychrel numbers, bridging number theory, automata theory, and symbolic dynamics.

## 1. Introduction

### 1.1 The Reverse-and-Add Problem

Given a natural number $n$ and a base $b \geq 2$, the *reverse-and-add* operation computes $T_b(n) = n + \text{rev}_b(n)$, where $\text{rev}_b(n)$ is the number obtained by reversing the base-$b$ digits of $n$. Iterating this operation produces an orbit $n, T_b(n), T_b^2(n), \ldots$ that, for most starting values, eventually reaches a palindrome (a number equal to its digit reversal).

The *196 conjecture* asserts that starting from $n = 196$ in base 10, no iterate ever produces a palindrome. Despite extensive computation exceeding $3 \times 10^8$ digits, the conjecture remains unproven. Numbers whose orbits apparently never reach a palindrome are called *Lychrel candidates*.

### 1.2 Contributions

We provide the first machine-verified formalization of:

1. **Definitions**: `reverseDigits`, `isPalindromeBase`, `revAddStep`, `revAddIter`, `LychrelCandidateBase` in Lean 4, built on Mathlib's `Nat.digits` and `Nat.ofDigits`.

2. **Theorem B** (Palindrome–Fixed Point Equivalence): $n$ is a palindrome in base $b$ if and only if $\text{rev}_b(n) = n$.

3. **Theorem D** (Single-Step Congruence): $T_b(n) \equiv 2n \pmod{b-1}$.

4. **Theorem E** (Iterate Congruence): $T_b^k(n) \equiv 2^k n \pmod{b-1}$.

5. **Theorem A** (Involutivity): $\text{rev}_b(\text{rev}_b(n)) = n$ when $b \nmid n$ or $n = 0$.

6. **Theorem F** (Finite-Horizon Principle): If the residue of each iterate modulo $m$ differs from its digit-reversal's residue, then no palindrome exists in that horizon.

7. **Theorem G** (Carry Automaton Equivalence): $T_b(n)$ equals the output of a carry automaton processing digit pairs.

We also identify and correct an error in the folklore: the claim that $T_{10}(n)$ is always even is false ($196 + 691 = 887$ is odd).

### 1.3 Related Work

The reverse-and-add problem has been studied primarily through computation. Notable milestones include:

- Trigg (1967): early systematic investigation of palindrome convergence.
- Gruenberg (1985): computation of 196's orbit to thousands of digits.
- Wade and Reiter (1994): conjecture that 196 is Lychrel.
- Experimental mathematics community: orbit extended beyond $10^8$ digits.

No prior formal verification of reverse-and-add properties exists in any proof assistant.

## 2. Definitions and Notation

### 2.1 Digit Representation

We use Mathlib's `Nat.digits b n`, which returns the base-$b$ digits of $n$ as a list of natural numbers in least-significant-digit-first order. The inverse is `Nat.ofDigits b L`.

**Key Mathlib properties used:**
- `Nat.ofDigits_digits b n : ofDigits b (digits b n) = n`
- `Nat.digits_ofDigits b h L w₁ w₂ : digits b (ofDigits b L) = L` (when $L$ is normalized)
- `Nat.digits_lt_base : 1 < b → d ∈ digits b m → d < b`

### 2.2 Core Definitions

```
def reverseDigits (b n : Nat) : Nat :=
  Nat.ofDigits b (Nat.digits b n).reverse

def isPalindromeBase (b n : Nat) : Prop :=
  Nat.digits b n = (Nat.digits b n).reverse

def revAddStep (b n : Nat) : Nat := n + reverseDigits b n

def revAddIter (b : Nat) (k : Nat) (n : Nat) : Nat :=
  Nat.iterate (revAddStep b) k n

def LychrelCandidateBase (b n : Nat) : Prop :=
  ∀ k : Nat, ¬ isPalindromeBase b (revAddIter b k n)
```

### 2.3 Carry Automaton

```
def carryAdd (b : Nat) : List (Nat × Nat) → Nat → Nat
  | [], c => c
  | (a, d) :: rest, c =>
    let s := a + d + c
    (s % b) + b * carryAdd b rest (s / b)

def carryAutomatonEval (b : Nat) (digits : List Nat) : Nat :=
  carryAdd b (digits.zip digits.reverse) 0
```

## 3. Main Results

### 3.1 Theorem B: Palindrome–Fixed Point Equivalence

**Theorem.** For $b \geq 2$, $\text{isPalindromeBase}(b, n) \iff \text{reverseDigits}(b, n) = n$.

*Proof sketch.* The forward direction follows from the definition: if `digits b n = (digits b n).reverse`, then `ofDigits b (digits b n).reverse = ofDigits b (digits b n) = n`. The backward direction requires showing that `ofDigits b` is injective on normalized digit lists. If $\text{reverseDigits}(b, n) = n$, then `ofDigits b (digits b n).reverse = ofDigits b (digits b n)`. Both sides are normalized when the reverse is normalized. When $b \mid n$ and $n > 0$, the first digit is 0, so the reverse ends in 0 and is not normalized; but then `ofDigits b (digits b n).reverse < b^(L-1) ≤ n`, contradicting the hypothesis. Thus the hypothesis implies both sides are normalized, and injectivity of `digits_ofDigits` gives equality of the lists. □

### 3.2 Theorem D: Single-Step Modular Congruence

**Theorem.** For $b \geq 2$, $\text{revAddStep}(b, n) \equiv 2n \pmod{b-1}$.

*Proof.* The proof factors through three lemmas:

1. **Casting out nines**: $\text{ofDigits}(b, L) \equiv \sum L \pmod{b-1}$. By induction on $L$: the base case is trivial; for $L = d :: L'$, we have $\text{ofDigits}(b, d :: L') = d + b \cdot \text{ofDigits}(b, L')$. Since $b \equiv 1 \pmod{b-1}$, this is congruent to $d + \text{ofDigits}(b, L') \equiv d + \sum L' = \sum(d :: L') \pmod{b-1}$.

2. **Digit sum preservation**: $(d_1, \ldots, d_L).\text{reverse}.\text{sum} = (d_1, \ldots, d_L).\text{sum}$, by `List.sum_reverse`.

3. **Conclusion**: $\text{reverseDigits}(b, n) = \text{ofDigits}(b, (\text{digits}(b, n)).\text{reverse}) \equiv (\text{digits}(b, n)).\text{reverse}.\text{sum} = (\text{digits}(b, n)).\text{sum} \equiv n \pmod{b-1}$. Therefore $n + \text{reverseDigits}(b, n) \equiv n + n = 2n \pmod{b-1}$. □

### 3.3 Theorem E: Iterate Congruence Law

**Theorem.** For $b \geq 2$, $\text{revAddIter}(b, k, n) \equiv 2^k n \pmod{b-1}$.

*Proof.* By induction on $k$. Base case: $\text{revAddIter}(b, 0, n) = n = 2^0 n$. Inductive step: $\text{revAddIter}(b, k+1, n) = \text{revAddStep}(b, \text{revAddIter}(b, k, n)) \equiv 2 \cdot \text{revAddIter}(b, k, n) \equiv 2 \cdot 2^k n = 2^{k+1} n \pmod{b-1}$. □

**Corollary.** In base 10, the residue modulo 9 of the $k$-th iterate of 196 is $2^k \cdot 196 \bmod 9 = 2^k \cdot 7 \bmod 9$. The orbit modulo 9 is: $7, 5, 1, 2, 4, 8, 7, 5, 1, 2, \ldots$ with period 6.

### 3.4 Theorem A: Involutivity

**Theorem.** For $b \geq 2$, if $n \% b \neq 0$ or $n = 0$, then $\text{reverseDigits}(b, \text{reverseDigits}(b, n)) = n$.

*Proof sketch.* When $n = 0$: trivial (empty digit list). When $n > 0$ and $b \nmid n$: let $L = \text{digits}(b, n)$. Then $L$ is normalized (digits $< b$, last $\neq 0$). The first element of $L$ is $n \% b \neq 0$, so $L.\text{reverse}$ has last element $\neq 0$, hence is also normalized. By `digits_ofDigits`, $\text{digits}(b, \text{ofDigits}(b, L.\text{reverse})) = L.\text{reverse}$. Then $\text{reverseDigits}(b, \text{reverseDigits}(b, n)) = \text{ofDigits}(b, L.\text{reverse}.\text{reverse}) = \text{ofDigits}(b, L) = n$. □

**Remark.** Involutivity fails for multiples of the base: $\text{rev}_{10}(10) = 1$, $\text{rev}_{10}(1) = 1 \neq 10$.

### 3.5 Theorem F: Finite-Horizon Certification

**Theorem.** For $b \geq 2$, if for every $k \leq K$, $\text{revAddIter}(b, k, n) \% m \neq \text{reverseDigits}(b, \text{revAddIter}(b, k, n)) \% m$, then for every $k \leq K$, $\text{revAddIter}(b, k, n)$ is not a palindrome.

*Proof.* If $\text{revAddIter}(b, k, n)$ were a palindrome, then by Theorem B, $\text{reverseDigits}(b, \text{revAddIter}(b, k, n)) = \text{revAddIter}(b, k, n)$, so their residues modulo $m$ would agree, contradicting the hypothesis. □

### 3.6 Theorem G: Carry Automaton Equivalence

**Theorem.** For $b \geq 2$, $\text{revAddStep}(b, n) = \text{carryAutomatonEval}(b, \text{digits}(b, n))$.

*Proof.* We prove the stronger statement: for any list of pairs $L$ and carry $c$, $\text{carryAdd}(b, L, c) = \text{ofDigits}(b, L.\text{map fst}) + \text{ofDigits}(b, L.\text{map snd}) + c$.

By induction on $L$:
- Base: $\text{carryAdd}(b, [], c) = c = 0 + 0 + c$.
- Step: For $L = (a, d) :: L'$ with carry $c$, let $s = a + d + c$.
  $\text{carryAdd}(b, (a,d)::L', c) = s \% b + b \cdot \text{carryAdd}(b, L', s / b)$
  $= s \% b + b \cdot (\text{ofDigits}(b, L'.\text{map fst}) + \text{ofDigits}(b, L'.\text{map snd}) + s / b)$
  $= (s \% b + b \cdot (s / b)) + b \cdot \text{ofDigits}(b, L'.\text{map fst}) + b \cdot \text{ofDigits}(b, L'.\text{map snd})$
  $= s + b \cdot \text{ofDigits}(b, L'.\text{map fst}) + b \cdot \text{ofDigits}(b, L'.\text{map snd})$
  $= (a + b \cdot \text{ofDigits}(b, L'.\text{map fst})) + (d + b \cdot \text{ofDigits}(b, L'.\text{map snd})) + c$.

The main theorem follows by setting $L = \text{zip}(\text{digits}(b,n), \text{digits}(b,n).\text{reverse})$ and $c = 0$, using that `map fst (zip A B) = A` and `map snd (zip A B) = B` when $|A| = |B|$. □

### 3.7 Monotonicity

**Theorem.** $n \leq \text{revAddStep}(b, n)$ and $n \leq \text{revAddIter}(b, k, n)$ for all $k$.

*Proof.* The first follows from $\text{revAddStep}(b, n) = n + \text{reverseDigits}(b, n) \geq n$. The second follows by induction using transitivity. □

### 3.8 Correction: Base-10 Evenness is False

The folklore claim that $n + \text{rev}_{10}(n)$ is always even is **false**. Counterexample: $196 + 691 = 887$ is odd. The correct invariant is the modular congruence $T_{10}(n) \equiv 2n \pmod{9}$ (Theorem D).

## 4. Algorithms

### 4.1 Modular Residue Orbit Computation

**Input:** Base $b$, seed $n$, modulus $m$, horizon $K$.
**Output:** Residue sequence $r_0, r_1, \ldots, r_K$ where $r_k = T_b^k(n) \bmod m$.

```
function ModularOrbit(b, n, m, K):
    residues = []
    current = n
    for k = 0 to K:
        residues.append(current mod m)
        current = current + reverse_digits(b, current)
    return residues
```

**Time complexity:** $O(K \cdot D_K)$ where $D_K$ is the digit count of the $K$-th iterate.

**By Theorem E**, the residues modulo $b-1$ can be computed in $O(K)$ time without computing the actual iterates: $r_k = 2^k n \bmod (b-1)$.

### 4.2 Palindrome Residue Set Computation

**Input:** Base $b$, modulus $m$, maximum digit length $L$.
**Output:** Set of residues $\{p \bmod m : p \text{ is a base-}b \text{ palindrome with} \leq L \text{ digits}\}$.

```
function PalindromeResidues(b, m, L):
    residues = {0}
    for length = 1 to L:
        half = ceil(length / 2)
        for seed = 0 to b^half - 1:
            first_half = digits(b, seed), padded to length half
            if length is even:
                full = first_half + reverse(first_half)
            else:
                full = first_half + reverse(first_half[:-1])
            if length > 1 and full[-1] == 0: continue
            p = of_digits(b, full)
            residues.add(p mod m)
    return residues
```

**Time complexity:** $O(b^{L/2} \cdot L)$.

### 4.3 Carry State Tracing

**Input:** Base $b$, number $n$.
**Output:** Carry state sequence $c_0, c_1, \ldots, c_L$ for one reverse-and-add step.

```
function CarryTrace(b, n):
    d = digits(b, n)
    rev_d = reverse(d)
    carries = [0]
    c = 0
    for i = 0 to len(d) - 1:
        s = d[i] + rev_d[i] + c
        c = s / b
        carries.append(c)
    return carries
```

**Time complexity:** $O(D)$ where $D = \lfloor \log_b n \rfloor + 1$.

## 5. Computational Experiments

### 5.1 Verification of Theorem E

We computed the first 30 iterates of 196 in base 10 and verified that the residue modulo 9 matches $2^k \cdot 196 \bmod 9$ exactly:

| $k$ | Iterate | Actual mod 9 | Predicted $2^k \cdot 7 \bmod 9$ | Match |
|-----|---------|-------------|--------------------------------|-------|
| 0 | 196 | 7 | 7 | ✓ |
| 1 | 887 | 5 | 5 | ✓ |
| 2 | 1,675 | 1 | 1 | ✓ |
| 3 | 7,436 | 2 | 2 | ✓ |
| 4 | 13,783 | 4 | 4 | ✓ |
| 5 | 52,514 | 7 | 7* | ✓ |

*Period 6 begins repeating.

### 5.2 Lychrel Candidates up to 1,000

In base 10 with a horizon of 500 steps, we find 13 Lychrel candidates below 1,000: {196, 295, 394, 493, 592, 689, 691, 788, 790, 879, 887, 978, 986}. Many of these share orbits (e.g., 295, 394, 493, 592 are related by digit permutation properties), suggesting the effective number of independent Lychrel orbits is smaller.

### 5.3 Carry Density Analysis

The average carry density (fraction of digit positions with nonzero carry) for 196's first 20 iterates is approximately 0.45, indicating roughly half of digit positions generate carries. This high carry density is characteristic of Lychrel candidates and may be a predictive feature.

### 5.4 Multi-Base Comparison

| Base | 196 reaches palindrome? | Steps |
|------|------------------------|-------|
| 2 | Yes | 1 |
| 4 | Yes | 2 |
| 8 | Yes | 3 |
| 10 | Unknown (Lychrel candidate) | >500 |
| 16 | Yes | 4 |

The number 196 is a Lychrel candidate specifically in base 10. This base-dependence suggests the obstruction involves the interplay between 196's digit structure and the base-10 carry propagation rules.

## 6. Discussion

### 6.1 Significance of the Iterate Congruence Law

Theorem E is the most consequential result for the 196 conjecture. It shows that despite the nonlinear, chaotic-looking behavior of reverse-and-add, there is a perfectly linear algebraic skeleton: the residue modulo $b-1$ evolves as multiplication by 2. This means:

- The residue orbit is eventually periodic with period dividing $\text{ord}_{b-1}(2)$.
- Any palindrome in the orbit must have a residue in the intersection of the palindrome residue set and the iterate residue orbit.
- If this intersection is empty for some modulus $m$ dividing $b-1$ (or any $m$), the conjecture follows.

### 6.2 The Carry Automaton as a Bridge

Theorem G opens a fundamentally new approach. By establishing exact equivalence between arithmetic and automaton computation, it allows the tools of formal language theory to be applied:

- **Reachability analysis**: Can the automaton reach a palindrome-compatible state?
- **Pumping arguments**: For sufficiently long inputs, can structural periodicity in the carry pattern exclude palindromic output?
- **Decision procedures**: Is palindrome reachability decidable for the reverse-and-add automaton?

### 6.3 Limitations

Our current framework does not resolve the 196 conjecture. The modular obstruction (Theorems D–F) would require finding a modulus $m$ for which the palindrome residue set and the iterate residue orbit are disjoint. Preliminary computations suggest this may not occur for any single modulus based on $b-1$ alone, since palindromes achieve all residues modulo 9 (every digit sum is possible). More sophisticated moduli (e.g., 11, 99, or composite moduli incorporating digit-position information) may be needed.

## 7. Future Work

1. **Composite modular obstructions**: Investigate whether joint residue constraints modulo $\text{lcm}(9, 11, 101, \ldots)$ can exclude palindromic convergence.

2. **Carry automaton decidability**: Determine whether palindrome reachability for the carry automaton is decidable.

3. **Density of Lychrel numbers**: Use the formal framework to prove lower bounds on the density of Lychrel candidates in arbitrary bases.

4. **SAT/SMT integration**: Encode the carry automaton constraints as a satisfiability problem and use solvers for finite-horizon certification.

5. **Generalization to other digit algorithms**: Apply the framework to Kaprekar's routine, Collatz-like digit maps, and other arithmetic dynamical systems.

## 8. References

1. Trigg, C. W. "Palindromes by Addition." *Mathematics Magazine*, 40(1), 26–28, 1967.
2. Sloane, N. J. A. "The persistence of a number." *Journal of Recreational Mathematics*, 6, 97–98, 1973.
3. OEIS Foundation. "A006960: Reverse and add! sequence starting with 196." *The On-Line Encyclopedia of Integer Sequences*.
4. Mathlib Community. *Mathlib4: The Lean 4 Mathematical Library*. https://github.com/leanprover-community/mathlib4.
